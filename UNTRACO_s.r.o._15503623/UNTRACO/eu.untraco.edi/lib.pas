uses 'eu.untraco.edi.fce';

procedure ParseEDI (OS: TNxCustomObjectSpace; var ProcessContinue: Boolean; Directory: string; FileName: string);
var
 mSite:TSiteForm;
 mList, mListOV, mListROV:TStringList;
 mOpenDlg:TOpenDialog;
 mOS:TNxCustomObjectSpace;
 i,j:Integer;
 mReceiptCardBO, mRowBO, mOVRow:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mOVName, mOVCode, mOVOrdnumber,mOVPeriod,mDocument_ID, mStorecard_ID:String;

begin
  mOS:=OS;
  try
    mList:=TStringList.Create;
             mlist.LoadFromFile(Directory+'\'+FileName);
             if Trim(Copy(mlist.Strings[1],19,3))='380' then begin
             mReceiptCardBO:=mOS.CreateObject(Class_ReceiptCard);
             mReceiptCardBO.New;
             mReceiptCardBO.Prefill;
             mOVName:=Trim(Copy(mlist.Strings[1],99,15));
             if (NxSearch(mOVName,'-',[srAll],0)>0) and (NxSearch(mOVName,'/',[srAll],0)>0) then begin
             mOVCode:=NxToken(mOVName,'-');
             mOVOrdNumber:=NxToken(mOVName,'/');
             mOVPeriod:=mOVName;
             if not(NxIsBlank(mOVCode)) and not(NxIsBlank(mOVOrdnumber)) and not(NxIsBlank(mOVPeriod)) then begin
             mListOV:=TStringList.Create;
             mOS.SQLSelect(format('Select sd.id from issuedorders sd left join periods p on p.id=sd.period_id left join docqueues dq on dq.id=sd.docqueue_id where dq.code=''%s'' and p.code=''%s'' and sd.ordnumber=%s',[UpperCase(mOVCode),mOVPeriod,movOrdNumber]),mListOV);
             if mListov.count>0 then mDocument_ID:=mListov.Strings[0];
             end;
             end;
             mReceiptCardBO.SetFieldValueAsString('DocQueue_ID','J000000101');
             mReceiptCardBO.SetFieldValueAsString('Firm_ID','6P60000101');
             mReceiptCardBO.SetFieldValueAsString('Description',Copy(mlist.Strings[1],99,15)+' '+Copy(mlist.Strings[1],4,15));
             mReceiptCardBO.SetFieldValueAsInteger('TradeType',2);
             mReceiptCardBO.SetFieldValueAsString('Country_ID','00000DK000');
             mReceiptCardBO.SetFieldValueAsString('IntrastatDeliveryTerm_ID','3001000000');
             mReceiptCardBO.SetFieldValueAsString('IntrastatTransactionType_ID','1001000000');
             mReceiptCardBO.SetFieldValueAsString('IntrastatTransportationType_ID','2000000000');
             mRows:=mReceiptCardBO.GetCollectionMonikerForFieldCode(mReceiptCardBO.GetFieldCode('Rows'));
              for j:=2 to mList.Count-1 do begin
                if AnsiLeftStr(mlist.strings[j],3)='LIN' then begin
                   mStorecard_ID:=GetSToreCard_ID(mos,trim(copy(mlist.Strings[j],10,25)));
                  // if not(NxIsEmptyOID(mStorecard_ID)) then begin
                   mRowBO:=mrows.AddNewObject;
                   mRowBO.Prefill;
                   mRowBO.SetFieldValueAsString('Store_ID','1000000101');
                   mRowBO.SetFieldValueAsString('StoreCard_ID',mStorecard_ID);
                   mrowbo.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(mlist.Strings[j],63,12))*GetStoreUnitRate(mos,mRowBO.GetFieldValueAsString('StoreCard_ID')));
                   mRowBO.SetFieldValueAsFloat('TotalPrice',NxIBStrToFloat(copy(mlist.Strings[j],118,12)));
                   mRowBO.SetFieldValueAsFloat('UnitPrice', 0);
                   mrowbo.SetFieldValueAsString('Division_ID','1000000101');
                   mrowbo.SetFieldValueAsString('OriginCountry_ID',mRowBO.GetFieldValueAsString('StoreCard_ID.Country_ID'));
                   //mRowBO.SetFieldValueAsString('Provide_ID',mDocument_ID);
                   mRowBO.SetFieldValueAsString('U_lin',trim(copy(mlist.Strings[j],4,6)));
                   //NxShowSimpleMessage(mRowBO.GetFieldValueAsString('Qunit')+ mRowBO.GetFieldValueAsString('StoreCard_ID.Code'),nil);
                   mListROV:=TStringList.Create;
                   mOS.SQLSelect(format('Select id from issuedorders2 where parent_id=''%s'' and storecard_id=''%s'' ',[mDocument_ID, mRowBO.GetFieldValueAsString('StoreCard_ID')]),mListROV);
                   if mListROV.count>0 then begin
                   mOVRow:=mos.CreateObject(Class_IssuedOrderRow);
                   movrow.Load(mListROV.strings[0],nil);
                   mOVRow.SetFieldValueAsFloat('DeliveredQuantity', mOVRow.GetFieldValueAsFloat('DeliveredQuantity')+mrowbo.GetFieldValueAsFloat('Quantity'));
                   movrow.save;
                   mRowBO.SetFieldValueAsString('ProvideRow_ID',mListROV.strings[0]);
                   mRowBO.SetFieldValueAsString('ProvideRowType','IO');
                   end;
                   mlistrov.Free;
                  // end;
                end;
              end;
             mReceiptCardBO.save;
             mos.SQLExecute(Format('update storedocuments2 set Provide_ID=''%s'' where parent_id=''%s'' ',[mDocument_ID,mReceiptCardBO.OID]));
             SendInternalMail(OS, 'edilgc@untraco.cz','','',
                         'Zpracována příjemka číslo : '+mReceiptCardBO.DisplayName,'',
                         '',mReceiptCardBO.GetFieldValueAsString('Firm_ID'),
                         mReceiptCardBO.GetLoadedCollectionMonikerForFieldCode(mReceiptCardBO.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('Division_ID'),
                         mReceiptCardBO.GetLoadedCollectionMonikerForFieldCode(mReceiptCardBO.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('BusTransaction_ID'));
             mReceiptCardBO.free;
             end;
       finally

       end;



  ProcessContinue := True;
  
end;

procedure SendInternalMail(AOS:TNxCustomObjectSpace; ATo:String; ACC:String; ABCC:String; ASubject:String; ABody:String; AAtachement:String; AFirm_ID:String; ADivision_ID:String; ABusTransaction_ID:String);
Var
  mMailBO:TNxCustomBusinessObject;
  mMRecipients:TNxCustomBusinessMonikerCollection;
  mMailRecipient:TNxCustomBusinessObject;
begin
  if not(ato='') then begin
     mMailBO:=AOS.CreateObject('5C1HWDQDR3J4NAAYZRO5PWHLWK');
     mMailBO.New;
     mMailBO.Prefill;
     mMailBO.SetFieldValueAsString('EmailAccount_ID','1000000101');
     mMailBO.SetFieldValueAsString('Subject',ASubject);
     mMailbo.SetFieldValueAsInteger('SentState',1);
     mMailBO.SetFieldValueAsString('Body',ABody);
     mMailBO.SetFieldValueAsString('Firm_ID',AFirm_ID);
     mMailBO.SetFieldValueAsString('Division_ID',ADivision_ID);
     mMailBO.SetFieldValueAsString('BusTransaction_ID',ABusTransaction_ID);
     mMRecipients:=mMailBO.GetCollectionMonikerForFieldCode(mMailBO.GetFieldCode('Recipients'));

     mMailRecipient:=mMRecipients.AddNewObject;
     mMailRecipient.SetFieldValueAsString('Email',ATo);
     mMailRecipient.SetFieldValueAsInteger('EmailType',0);
     if not(acc='') then begin
     mMailRecipient:=mMRecipients.AddNewObject;
     mMailRecipient.SetFieldValueAsString('Email',ACC);
     mMailRecipient.SetFieldValueAsInteger('EmailType',1);
     end;
     if not(ABCC='') then begin
     mMailRecipient:=mMRecipients.AddNewObject;
     mMailRecipient.SetFieldValueAsString('Email',ABCC);
     mMailRecipient.SetFieldValueAsInteger('EmailType',2);
     end;
     if not(AAtachement='') then begin
      if FileExists(AAtachement) then TNxEmailSent(mMailBO).AttachFile(AAtachement);

     end;




     mMailBO.Save;
     mMailBO.free;

  end;
end;

begin
end.