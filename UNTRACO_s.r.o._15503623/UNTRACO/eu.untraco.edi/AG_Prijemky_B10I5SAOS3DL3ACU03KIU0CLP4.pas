uses 'eu.untraco.edi.fce';


procedure InitSite_Hook(Self: TSiteForm);
var
  mBut, mBut2: TBasicAction;

begin
  if not Assigned(Self.BaseObjectSpace) then
    exit;

mBut:= Self.GetNewAction;
mBut.ShowControl := True;
mBut.ShowMenuItem := True;
mBut.Caption := 'EDI import';
mBut.Category := 'tabList';
mBut.OnExecute := @Import;

end;


procedure _AfterDeleteRecs_Hook(Self: TDynSiteForm);
begin

end;

procedure Import (sender:TComponent);
var
 mSite:TSiteForm;
 mList, mListOV, mListROV:TStringList;
 mOpenDlg:TOpenDialog;
 mOS:TNxCustomObjectSpace;
 i,j:Integer;
 mReceiptCardBO, mRowBO, mOVRow:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mOVName, mOVCode, mOVOrdnumber,mOVPeriod,mDocument_ID, mStoreCard_ID:String;
begin
  mSite:=TComponent(Sender).DynSite;
   if Assigned(msite) then begin
     mOS:=TDynSiteForm(mSite).GetFakeBusinessObject.ObjectSpace;
     mOpenDlg := TOpenDialog.Create(TComponent(Sender));
     mOpenDlg.Options:=([ofAllowMultiSelect]);
     mOpenDlg.DefaultExt:='txt';
        if mOpenDlg.Execute then begin
         for i:=0 to mOpenDlg.files.Count-1 do begin
             mList:=TStringList.Create;
             mlist.LoadFromFile(mOpenDlg.files[i]);
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
             mReceiptCardBO.SetFieldValueAsString('RDocumentType','IO');
             mRows:=mReceiptCardBO.GetCollectionMonikerForFieldCode(mReceiptCardBO.GetFieldCode('Rows'));
              for j:=2 to mList.Count-1 do begin
                if AnsiLeftStr(mlist.strings[j],3)='LIN' then begin
                   mStoreCard_ID:=GetSToreCard_ID(mos,trim(copy(mlist.Strings[j],10,25)));
                   //if not(NxIsEmptyOID(mStoreCard_ID)) then begin
                   mRowBO:=mrows.AddNewObject;
                   mRowBO.Prefill;
                   mRowBO.SetFieldValueAsString('Store_ID','1000000101');
                   mRowBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
                   mrowbo.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(mlist.Strings[j],63,12))*GetStoreUnitRate(mos,mRowBO.GetFieldValueAsString('StoreCard_ID')));
                   mRowBO.SetFieldValueAsFloat('TotalPrice',NxIBStrToFloat(copy(mlist.Strings[j],118,12)));
                   mRowBO.SetFieldValueAsFloat('UnitPrice', 0);
                   mrowbo.SetFieldValueAsString('Division_ID','1000000101');
                   //mrowbo.SetFieldValueAsString('OriginCountry_ID','00000DK000');
                   mrowbo.SetFieldValueAsString('OriginCountry_ID',mRowBO.GetFieldValueAsString('StoreCard_ID.Country_ID'));
                  //
                   mRowBO.SetFieldValueAsString('U_lin',trim(copy(mlist.Strings[j],4,6)));
                   mListROV:=TStringList.Create;
                   mOS.SQLSelect(format('Select id from issuedorders2 where parent_id=''%s'' and storecard_id=''%s'' ',[mDocument_ID, mRowBO.GetFieldValueAsString('StoreCard_ID')]),mListROV);
                   if mListROV.count>0 then begin
                   mOVRow:=mos.CreateObject(Class_IssuedOrderRow);
                   movrow.Load(mListROV.strings[0],nil);
                   mOVRow.SetFieldValueAsFloat('DeliveredQuantity', mOVRow.GetFieldValueAsFloat('DeliveredQuantity')+mrowbo.GetFieldValueAsFloat('Quantity'));
                   movrow.save;
                   mRowBO.SetFieldValueAsString('ProvideRow_ID',mListROV.strings[0]);
                   mRowBO.SetFieldValueAsString('ProvideRowType','IO');
                   //mRowBO.SetFieldValueAsString('Provide_ID',mDocument_ID);
                   end;
                   mlistrov.Free;
                  // end;
                end;
              end;
             mReceiptCardBO.save;
             mos.SQLExecute(Format('update storedocuments2 set Provide_ID=''%s'' where parent_id=''%s'' ',[mDocument_ID,mReceiptCardBO.OID]));
             mReceiptCardBO.free;
         end;
        end;
       TDynSiteForm(mSite).RefreshData;
   end;
end;

begin
end.