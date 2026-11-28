Const
      cDescription = 'Aut. zdanění';
      cRowtext = 'Záloha zboží: ';
      cDZL_Agenda = 'ZSR1DT11PBWOJ3MELFAGIQ22QO';
      cDZL_DocQueue_ID = '9100000101'; //řada dokladu DZV   /
      cVATRate_ID = '02100X0000';

procedure CreateDZV(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList, mDateList, mVATList:tstringlist;
 i,j:Integer;
 mZL, mOPBO, mOPRowBO:TNxCustomBusinessObject;
 mOP_ID:string;
 mDate, mAmount:Extended;
 mMessage:string;
 mCreate:boolean;
begin
  mMessage:='';
  mList:=TStringList.Create;
  os.SQLSelect(format('SELECT a.ID FROM IssuedDInvoices A '+
                      'left join issueddepositUsages B on a.id=b.Depositdocument_id '+
                      'WHERE (A.Amount  = A.PaidAmount) '+
                      'AND (EXISTS (SELECT 1 FROM PaymentsForDocument_VIEW PFD   WHERE (PFD.DocDate$DATE >= %s) and (PFD.DocDate$DATE < %s) '+
                      'and PFD.PDocumentType = '+QuotedStr('10')+' and PFD.PDocument_ID = A.ID)) and b.id is null and a.X_vazniky=''N'' ',[IntToStr(Trunc(date-7)), IntToStr(trunc(date+1))]),mList);
  if mlist.Count>0 then begin
    for i:=0 to mlist.count-1 do begin
            mZL:=OS.CreateObject(Class_IssuedDepositInvoice);
            mZL.Load(mList.Strings[i],nil);
            //je na ZL co zúčtovat
            mAmount :=  mZL.GetFieldValueAsFloat('PaidAmount')- mZL.GetFieldValueAsFloat('UsedAmount');
            if mAmount > 0 then begin
              mCreate:=True;
              mOP_ID := mZL.GetFieldValueAsString('ReceivedOrder_ID');
              if not(NxIsEmptyOID(mOP_ID)) then begin
                 mVATList:=TStringList.create;
                 os.SQLSelect(format('Select Min(vatrate) from receivedorders2 where parent_id=''%s'' ',[mOP_ID]),mVATList);
                 if NxIBStrToFloat(mVATList.strings[0])<21 then mCreate:=false;
              end;
              mDateList:=TStringList.Create;
              OS.SQLSelect(format('Select DocDate$Date from LastPaymentForDocument(''10'',''%s'') ',[mZL.OID]),mDateList);
              mDate:=NxIBStrToFloat(mDateList.strings[0]);
              if mCreate then begin //not NxIsEmptyOID(mOP_ID) then begin
                //createDZL
                try
                  CreateDocDZL(mZL,mAmount, mOP_ID, mDate);
                except
                 mMessage:=mMessage+#13#10+ExceptionMessage;
                end;
              end
              else begin
                //není vytvořeno z OP
              end;
            end
            else begin
              //není co zúčtovat
            end;

    end;
  end;
  Success := True;
  LogInfoStr := ''+mMessage;
end;

Function CreateDocDZL(AZL:TNxCustomBusinessObject; mAMount: double; mOP_ID: string; ADate: Double):string;
var mManager : TNxDocumentImportManager ;
  mParams : TNxParameters;
  mRow, mRow_OP, mOP, mUsage,mUserXLink : TNxCustomBusinessObject;
  mRows, mRows_OP, mRows2 : TNxCustomBusinessMonikerCollection;
  mDate: TDateTime;
  mRowText, mVatRate_ID, mUsageID, mQuery, mAccID : string;
  mList, mPrintList : TStringList;
  mCopy, mCarbonCopy, mFileName:string;

begin
  result := '';
  mManager := NxCreateDocumentImportManager(AZL.ObjectSpace,Class_IssuedDepositInvoice,Class_VATIssuedDepositInvoice);
  mOP := AZL.ObjectSpace.CreateObject(Class_ReceivedOrder);
  mParams := TNxParameters.Create();
  //mList := tStringlist.create;
  try
    if not NxIsEmptyOID(mOP_ID) then begin
      //potrebujeme radek objednávky
      mOP.Load(mOP_ID,nil);
      mRows_OP := mOP.GetLoadedCollectionMonikerForFieldCode(mOP.GetFieldCode('Rows'));
      mRow_OP := mRows_OP.BusinessObject[0];
      mVatRate_ID := mRow_OP.GetFieldValueAsString('VATRate_ID');
    end else begin //jinak to vememe z řádku ZL
      mRows_OP := AZL.GetLoadedCollectionMonikerForFieldCode(AZL.GetFieldCode('Rows'));
      mRow_OP := mRows_OP.BusinessObject[0];
      mVatRate_ID := cVATRate_ID;
    end;

    mManager.AddInputDocument(AZL.OID);
    mParams.GetOrCreateParam(dtFloat, 'DepositAmount').AsFloat := mAmount;
    mParams.GetOrCreateParam(dtString, 'DocQueue_ID').AsString := cDZL_DocQueue_ID;
    mParams.GetOrCreateParam(dtDateTime, 'VatDate').AsdateTime := mDate;
    mDate := ADate;
    mManager.LoadParams(mParams);
    mManager.Execute;
    mManager.OutputDocument.SetFieldValueAsDateTime('DocDate$DATE', mDate);
    mManager.OutputDocument.SetFieldValueAsDateTime('AccDate$DATE', mDate);
    mManager.OutputDocument.SetFieldValueAsDateTime('VATDate$DATE', mDate);
    mManager.OutputDocument.SetFieldValueAsBoolean('PricesWithVAT', True);
    //mManager.OutputDocument.SetFieldValueAsString('X_ContractNumber', mOP.GetFieldValueAsString('X_ContractNumber'));
    mManager.OutputDocument.SetFieldValueAsString('Description', NxLeft('záloha zboží '+AZL.DisplayName, 50));
    //JIPE doplněno dohledání období
     mManager.OutputDocument.SetFieldValueAsString('Period_ID',HledejID('ID','periods',
        'datefrom$date<=' + Floattostr(mManager.OutputDocument.GetFieldValueAsDateTime('DocDate$date'))
         + ' and dateto$date > ' + Floattostr(mManager.OutputDocument.GetFieldValueAsDateTime('DocDate$date')),'OID','',AZL.ObjectSpace));

    mRows := mManager.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mManager.OutputDocument.GetFieldCode('Rows'));
    mRow := mRows.AddNewObject;
    mRow.Prefill;
    mRow.SetFieldValueAsInteger('RowType',4);
    mRow.SetFieldValueAsString('Division_ID',mRow_OP.GetFieldValueAsString('Division_ID'));
    mRow.SetFieldValueAsString('VATRate_ID',mVatRate_ID);
    mRowText := cRowtext + AZL.GetFieldValueAsString('DisplayName');
    mRow.SetFieldValueAsString('Text',mRowText);
    mRow.SetFieldValueAsFloat('PaymentAmount',mAmount);
    mManager.OutputDocument.Save;
    mUserXLink := AZL.ObjectSpace.CreateObject(Class_UserXLink);
    try
      mUserXLink.New;
      mUserXLink.Prefill;
      mUserXLink.SetFieldValueAsString('SourceCLSID', Class_IssuedDepositInvoice);
      mUserXLink.SetFieldValueAsString('Source_ID', AZL.OID);
      mUserXLink.SetFieldValueAsString('DestinationCLSID', Class_VATIssuedDepositInvoice);
      mUserXLink.SetFieldValueAsString('Destination_ID', mManager.OutputDocument.OID);
      mUserXLink.SetFieldValueAsBoolean('DisplayAsSystem', True);
      mUserXLink.Save;
    finally
      mUserXLink.Free;
    end;


    Result := mManager.OutputDocument.OID;



      mCopy:='';
      mCarbonCopy:='';
      mRows2:=mManager.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mManager.OutputDocument.GetFieldCode('Rows'));
      if NxIsValidEMail(mManager.OutputDocument.GetFieldValueAsString('Firm_ID.X_bustransaction_ID.U_email'),false) then mCopy:=mManager.OutputDocument.GetFieldValueAsString('Firm_ID.X_bustransaction_ID.U_email');
      if NxIsValidEMail(mrows2.BusinessObject[0].GetFieldValueAsString('Division_ID.Address_id.email'),false) then mCarbonCopy:= mrows2.BusinessObject[0].GetFieldValueAsString('Division_ID.Address_id.email');
      //if mManager.OutputDocument.GetFieldValueAsFloat('PaidAmount')>=mManager.OutputDocument.GetFieldValueAsFloat('Amount') then begin
        mPrintList:=TStringList.Create;
        mPrintList.Add(mManager.OutputDocument.OID);
        mFileName:=NxSearchReplace(mManager.OutputDocument.DisplayName,'/','-',[srAll]);

        CFxReportManager.PrintByIDs(NxCreateContext_1(mManager.OutputDocument), mPrintList, GetDynSource(mManager.OutputDocument.ObjectSpace,'2310000101'), '2310000101', rtoFile, pekPDF, NxGetTempDir, mFileName + '.pdf');
        mPrintList.Clear;
        SendInternalMail(mManager.OutputDocument.ObjectSpace, 'ondrej.slosar@obb.cz;',
                             mCopy,
                             mCarbonCopy,
                             'Daňový doklad k zaplacené záloze'+mManager.OutputDocument.DisplayName+' pro firmu '+mManager.OutputDocument.GetFieldValueAsString('Firm_ID.Name'),
                             'Dobrý den, v příloze Vám zasíláme daňový doklad k zaplacené záloze na částku '+FormatFloat('0.00,',mManager.OutputDocument.GetFieldValueAsFloat('Amount'))+' '+mManager.OutputDocument.GetFieldValueAsString('Currency_ID.code')+' Tento email je zasílán automaticky, prosím neodpovídejte.' ,
                             NxGetTempDir+'\'+ mFileName + '.pdf',
                             mManager.OutputDocument.GetFieldValueAsString('Firm_ID'),
                             mrows.BusinessObject[0].GetFieldValueAsString('Division_ID'),
                             '');
        if NxIsValidEMail(mManager.OutputDocument.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.email'),false) then
         SendInternalMail(mManager.OutputDocument.ObjectSpace, mManager.OutputDocument.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.email'),
                             '',
                             '',
                             'Daňový doklad k zaplacené záloze '+mManager.OutputDocument.DisplayName+' pro firmu '+mManager.OutputDocument.GetFieldValueAsString('Firm_ID.Name'),
                             'Dobrý den, v příloze Vám zasíláme daňový doklad k zaplacené záloze na částku '+FormatFloat('0.00,',mManager.OutputDocument.GetFieldValueAsFloat('Amount'))+' '+mManager.OutputDocument.GetFieldValueAsString('Currency_ID.code')+' Tento email je zasílán automaticky, prosím neodpovídejte.' ,
                             NxGetTempDir+'\'+ mFileName + '.pdf',
                             mManager.OutputDocument.GetFieldValueAsString('Firm_ID'),
                             mrows.BusinessObject[0].GetFieldValueAsString('Division_ID'),
                             '');
         DeleteFile(NxGetTempDir+'\'+ mFileName + '.pdf');



    // FINE: úprava data zúčtování - nechtějí aktuální den, ale stejné datum jako zdanění
    mUsageID := HledejID('ID', 'IssuedDepositUsages', 'DepositDocument_ID = '+QuotedStr(AZL.OID)+' AND PDocument_ID = '+QuotedStr(mManager.OutputDocument.OID), '', '', AZL.ObjectSpace);
    if (not NxIsEmptyOID(mUsageID)) then begin
      mUsage := AZL.ObjectSpace.CreateObject(Class_IssuedDepositUsage);
      try
        mUsage.Load(mUsageID, nil);
        mUsage.SetFieldValueAsDateTime('PaymentDate$DATE', mDate);
        mUsage.SetFieldValueAsDateTime('AccDate$DATE', mDate);
        mUsage.Save;
      finally
        mUsage.Free;
      end;
      // doklad zúčtování musíme ručně přeúčtovat
      mList := tStringlist.create;
      try
        mList.Add(mUsageID);
        CFxAccounting.ReAccount(Class_IssuedDepositUsage, mList);
      finally
        mList.Free;
      end;

    end;


  finally
    mManager.Free;
    mOP.Free;
    mParams.free;
    //mList.Free;
  end;
end;

function GetDynSource (AOS : TNxCustomObjectSpace; AValue : string) : String;

const
  cSQL = 'SELECT DataSource FROM Reports WHERE ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [ AValue]), mList);
    if mList.Count > 0 then
      Result := (mList.Strings[0]);
  finally
    mList.Free;
  end;
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
     mMailBO.SetFieldValueAsString('EmailAccount_ID','3000000101');
     mMailBO.SetFieldValueAsString('Subject',ASubject);
     mMailbo.SetFieldValueAsInteger('SentState',1);
     mMailBO.SetFieldValueAsString('Body',ABody);
     mMailBO.SetFieldValueAsString('Firm_ID',AFirm_ID);
     mMailBO.SetFieldValueAsString('Division_ID',ADivision_ID);
     mMailBO.SetFieldValueAsString('BusTransaction_ID',ABusTransaction_ID);
     mMailBO.SetFieldValueAsBoolean('X_dont_delete',False);
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

Function HledejID(What,Where,When,Alias,Res:string;mOS:TNxCustomObjectSpace):string;
 var
  mResult:TStrings;
  mSQL:String;
 begin
   try
     mResult := TStringList.Create;
     mSQL := 'Select '+ What +' from '+ Where + ' Where '+ When;
      //ShowMessage(mSQL);
      mOS.SQLSelect(mSQL, mResult);
      if (mResult.Count > 0) then begin
        Result:=mResult.Strings[0] ;
      end
      else begin
        Result:=Res;
      end;
    finally
      mResult := Nil;
    end;
 end;


begin
end.