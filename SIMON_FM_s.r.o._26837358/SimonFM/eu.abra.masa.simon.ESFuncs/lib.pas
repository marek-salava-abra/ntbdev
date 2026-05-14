Const
      cDescription = 'Aut. zdanění';
      cRowtext = 'Zdanění zálohy: ';
      cDZL_DocQueue_ID = 'B200000101'; //řada dokladu DZV   //1E00000101
      cVATRate_ID = '02100X0000';  //21% DPH

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

procedure CheckPayment (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
  mList, mPrintList, mFileList:TStringList;
  mOrderBO, mZLVBO, mDZVBO, mRowBO:TNxCustomBusinessObject;
  i,j:integer;
  mRows:TNxCustomBusinessMonikerCollection;
  mBool, mNotOnStore,mZapornaMarze:Boolean;
  mAmount, mAvailableQuantity,mOrderedQuantity, mStorePrice:Extended;
  mZLV_ID, mDZVE_ID, mSubject, mBody, mFileName, mFileName2, mTO:string;
begin
  mList:=TStringList.Create;
  os.SQLSelect(format('SELECT a.receivedorder_id FROM IssuedDInvoices A '+
                      'left join receivedorders ro on ro.id=a.receivedorder_id '+
                      'WHERE (A.Amount  <= A.PaidAmount) '+
                      'AND (EXISTS (SELECT 1 FROM PaymentsForDocument_VIEW PFD   WHERE (PFD.DocDate$DATE >= %s) and (PFD.DocDate$DATE < %s) '+
                      'and PFD.PDocumentType = '+QuotedStr('10')+' and PFD.PDocument_ID = A.ID)) and ro.pmstate_id='+QuotedStr('5010000101')+' and ro.docqueue_id='+Quotedstr('1W10000101'),[IntToStr(Trunc(date-15)), IntToStr(trunc(date+1))]),mList);
  if mList.count>0 then begin
   for i:=0 to mlist.count-1 do begin
    mOrderBO:=OS.CreateObject(Class_ReceivedOrder);
    mOrderBO.Load(mlist.Strings[i],nil);
    mRows:=mOrderBO.GetLoadedCollectionMonikerForFieldCode(mOrderBO.GetFieldCode('Rows'));
        for j:=0 to mrows.Count-1 do begin
          mRowBO:=mRows.BusinessObject[j];
          if mRowBO.GetFieldValueAsInteger('RowType')=3 then begin
           if not(mNotOnStore) then begin
            mAvailableQuantity:=GetAvailableQuantity(OS,mRowBO.GetFieldValueAsString('Store_ID'), mRowBO.GetFieldValueAsString('StoreCard_ID'))
                               {+GetAvailableQuantity(self.ObjectSpace,'4P00000101', mRowBO.GetFieldValueAsString('StoreCard_ID'))
                               +GetAvailableQuantity(self.ObjectSpace,'1E00000101', mRowBO.GetFieldValueAsString('StoreCard_ID'))
                               +GetAvailableQuantity(self.ObjectSpace,'2D00000101', mRowBO.GetFieldValueAsString('StoreCard_ID'))} ;
            mOrderedQuantity:=GetOrderedQuantity(OS,mRowBO.GetFieldValueAsString('StoreCard_ID'), mRowBO.OID,mRowBO.GetFieldValueAsString('Store_ID'), mOrderBO.GetFieldValueAsDateTime('CreatedAt$DATE'));
            if (mAvailableQuantity-mOrderedQuantity-mRowBO.GetFieldValueAsFloat('Quantity'))<0 then mNotOnStore:=True;
           end;
           if not mZapornaMarze then begin
             mStorePrice:=GetStorePrice(OS,mRowBO.GetFieldValueAsString('Store_ID'), mRowBO.GetFieldValueAsString('StoreCard_ID'));
             if mStorePrice>mRowBO.GetFieldValueAsFloat('UnitPrice') then mZapornaMarze:=True;
           end;
          end;
        end;
    if mNotOnStore then mOrderBO.SetFieldValueAsString('PMState_ID','2030000101') else
    mOrderBO.SetFieldValueAsString('PMState_ID','2000000101');
    mOrderBO.SetFieldValueAsString('U_OrderState_ID','90F7000101');
    mOrderBO.Save;
    // tlačítko DZVE
      mZLV_ID:=OS.SQLSelectFirstAsString('Select id from issueddinvoices where receivedorder_id='+QuotedStr(mOrderBO.OID),'');
      if not(NxIsEmptyOID(mZLV_ID)) then begin
        mZLVBO:=OS.CreateObject(Class_IssuedDepositInvoice);
        mZLVBO.Load(mZLV_ID,nil);
        if not(mZLVBO.GetFieldValueAsString('Currency_ID.Code')='EUR') then begin
        OutputDebugString('zálohový list vydaný '+mZLVBO.DisplayName);
        mDZVE_ID:=CreateDocDZL(mZLVBO, mZLVBO.GetFieldValueAsFloat('PaidAmount')- mZLVBO.GetFieldValueAsFloat('UsedAmount'), mOrderBO.OID, Date);
          mPrintList:=TStringList.create;
          mFileList:=TStringList.Create;
          mDZVBO:=OS.CreateObject(Class_VATIssuedDepositInvoice);
          mDZVBO.Load(mDZVE_ID,nil);
          mTO:=mDZVBO.GetFieldValueAsString('FirmOffice_ID.Address_ID.Email');
          mSubject:='Daňový zálohový list #CISLO# k přijaté objednávce #CISOB# ';
          mBody:=mOrderBO.GetFieldValueAsString('U_OrderState_ID.X_Note');
          mSubject:=NxSearchReplace(mSubject,'#CISLO#',mDZVBO.DisplayName,[srAll]);
          mSubject:=NxSearchReplace(mSubject,'#CISOB#',mOrderBO.GetFieldValueAsString('ExternalNumber'),[srAll]);
          mBody:=NxSearchReplace(mBody,'#CISOBJ#',mOrderBO.GetFieldValueAsString('ExternalNumber'),[srAll]);
          mBody:=NxSearchReplace(mBody,'#CISLOFAKTURY#',mDZVBO.DisplayName,[srAll]);
          mBody:=NxSearchReplace(mBody,'#VARSYMBOL#',mDZVBO.GetFieldValueAsString('VarSymbol'),[srall]);
          mBody:=NxSearchReplace(mBody,'#DATUMVYSTAVENI#',FormatDateTime('d.m.yyyy',mDZVBO.GetFieldValueAsdateTime('DocDate$Date')),[srall]);
          mBody:=NxSearchReplace(mBody,'#DATUMSPLATNOSTI#',FormatDateTime('d.m.yyyy',mDZVBO.GetFieldValueAsdateTime('DueDate$Date')),[srall]);
          mBody:=NxSearchReplace(mBody,'#CASTKA#',FormatFloat('0.00,',mDZVBO.GetFieldValueAsFloat('amount')),[srall]);
          mBody:=NxSearchReplace(mBody,'#TEMP#','',[srall]);
          //mZLVBO.Load(mZLV_ID,nil);
          mPrintList.Add(mDZVBO.OID);
          mFileName:=NxSearchReplace(mDZVBO.DisplayName,'/','-',[srAll]);
          mFileName2:=NxSearchReplace(mOrderBO.DisplayName,'/','-',[srAll]);
          CFxReportManager.PrintByIDs(NxCreateContext_1(mDZVBO), mPrintList, GetDynSource(OS,'3280000101'), '3280000101', rtoFile, pekPDF, NxGetTempDir, mFileName + '.pdf');
          mPrintList.Clear;
          mPrintList.Add(mOrderBO.OID);
          CFxReportManager.PrintByIDs(NxCreateContext_1(mOrderBO), mPrintList, '40V53DORW3DL342X01C0CX3FCC', '4VD0000101', rtoFile, pekPDF, NxGetTempDir, mFileName2 + '.pdf');
          SendInternalMail(OS, mTO,'','',
                             mSubject,mBody,
                             NxGetTempDir+'\'+ mFileName + '.pdf',NxGetTempDir+'\'+ mFileName2 + '.pdf',mDZVBO.GetFieldValueAsString('Firm_ID'),
                             mDZVBO.GetLoadedCollectionMonikerForFieldCode(mDZVBO.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('Division_ID'),
                             mDZVBO.GetLoadedCollectionMonikerForFieldCode(mDZVBO.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('BusTransaction_ID'), '1300000101', mOrderBO.OID, mOrderBO.GetFieldValueAsString('U_OrderState_ID'));
          DeleteFile(NxGetTempDir+'\'+ mFileName + '.pdf');
          DeleteFile(NxGetTempDir+'\'+ mFileName2 + '.pdf');
          mPrintList.Free;
        end;
      end;
    // tlačítko DZVE
    mOrderBO.Free;
   end;
  end;
  Success := True;
  LogInfoStr := '';
end;


Function CreateDocDZL(AZL:TNxCustomBusinessObject; mAMount: double; mOP_ID: string; ADate: Double):string;
var mManager : TNxDocumentImportManager ;
  mParams : TNxParameters;
  mRow, mRow_OP, mOP, mUsage : TNxCustomBusinessObject;
  mRows, mRows_OP : TNxCustomBusinessMonikerCollection;
  mDate: TDateTime;
  mRowText, mVatRate_ID, mUsageID, mQuery, mAccID : string;
  mList : TStringList;
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
    OutputDebugString('zálohový list vydaný '+AZL.DisplayName+' '+mOP.displayname);
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
    mManager.OutputDocument.SetFieldValueAsDateTime('VATDate$DATE', mDate);
    mManager.OutputDocument.SetFieldValueAsSTring('FirmOffice_ID', azl.GetFieldValueAsString('FirmOffice_ID'));
    //mManager.OutputDocument.SetFieldValueAsString('X_ContractNumber', mOP.GetFieldValueAsString('X_ContractNumber'));
    mManager.OutputDocument.SetFieldValueAsString('Description', NxLeft('Zúčtování '+AZL.DisplayName, 50));
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
    Result := mManager.OutputDocument.OID;

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
       // CFxAccounting.ReAccount(Class_IssuedDepositUsage, mList);
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

 procedure SendInternalMail(AOS:TNxCustomObjectSpace; ATo:String; ACC:String; ABCC:String;
                           ASubject:String; ABody:String; AAtachement, AAtachement2:String; AFirm_ID:String; ADivision_ID:String; ABusTransaction_ID:String; aAccount_ID:string;
                           aOrder_ID, aOrderState_ID:string);
Var
  mMailBO, mUserXLink:TNxCustomBusinessObject;
  mMRecipients:TNxCustomBusinessMonikerCollection;
  mMailRecipient:TNxCustomBusinessObject;
begin
  if not(ato='') then begin
     mMailBO:=AOS.CreateObject('5C1HWDQDR3J4NAAYZRO5PWHLWK');
     mMailBO.New;
     mMailBO.Prefill;
     mMailBO.SetFieldValueAsString('EmailAccount_ID',aAccount_ID);
     mMailBO.SetFieldValueAsString('Subject',ASubject);
     mMailBO.SetFieldValueAsString('BodySavedAs','1');
     mMailbo.SetFieldValueAsInteger('SentState',1);
     mMailBO.SetFieldValueAsString('Body',ABody);
     mMailBO.SetFieldValueAsString('Firm_ID',AFirm_ID);
     mMailBO.SetFieldValueAsString('Division_ID',ADivision_ID);
     mMailBO.SetFieldValueAsString('BusTransaction_ID',ABusTransaction_ID);
     mMailBO.SetFieldValueAsString('X_OrderState_ID',aOrderState_ID);
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
      TNxEmailSent(mMailBO).AttachFile(AAtachement);

     end;

     if not(AAtachement2='') then begin
      TNxEmailSent(mMailBO).AttachFile(AAtachement2);

     end;

     if aOrderState_ID='9C92000101' then begin
          if FileExists('d:\AbraGen\dokumenty\reklamacni-rad-simon-eshop.pdf') then
            TNxEmailSent(mMailBO).AttachFile('d:\AbraGen\dokumenty\reklamacni-rad-simon-eshop.pdf');
          if FileExists('d:\AbraGen\dokumenty\op-e-shop-simon-k-25.2.2026.pdf') then
            TNxEmailSent(mMailBO).AttachFile('d:\AbraGen\dokumenty\op-e-shop-simon-k-25.2.2026.pdf');
     end;

     mMailBO.Save;
     if not(NxIsEmptyOID(aOrder_ID)) then begin
     mUserXLink := aOS.CreateObject(Class_UserXLink);
      try
        mUserXLink.New;
        mUserXLink.Prefill;
        mUserXLink.SetFieldValueAsString('SourceCLSID', Class_ReceivedOrder);
        mUserXLink.SetFieldValueAsString('Source_ID', aOrder_ID);
        mUserXLink.SetFieldValueAsString('DestinationCLSID', Class_EmailSent);
        mUserXLink.SetFieldValueAsString('Destination_ID', mMailBO.OID);
        mUserXLink.SetFieldValueAsBoolean('DisplayAsSystem', True);
        mUserXLink.SetFieldValueAsString('Description',ASubject);
        mUserXLink.Save;
      finally
        mUserXLink.Free;
      end;
     end;
     mMailBO.free;

  end;
end;

function GetAvailableQuantity(AOS : TNxCustomObjectSpace; aStore_ID, aStoreCard_ID : string) : Extended;
const
  cSQL = 'SELECT Sum(Quantity-Bookedquantity) FROM StoreSubCards WHERE Store_ID=''%s'' and StoreCard_ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aStore_ID, aStoreCard_ID]), mList);
    if mList.Count > 0 then
      Result := NxIBStrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;

function GetOrderedQuantity(AOS : TNxCustomObjectSpace; aStoreCard_ID, ARow_ID, aStore_ID : string; ADate: Extended) : Extended;
const
  DecimalSeparator= '.';
  cSQL = 'SELECT SUM(Quantity-deliveredQuantity) FROM ReceivedOrders2 RO2 LEFT JOIN ReceivedOrders RO ON RO.ID = RO2.Parent_ID '+
          'WHERE RO.Confirmed = ''A'' and RO.Closed = ''N'' and RO2.StoreCard_ID = ''%s'' and RO2.ID <> ''%s'' and RO2.Store_ID = ''%s'' and CreatedAt$Date < %s  ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aStoreCard_ID, ARow_ID, aStore_ID ,NxFloatToIBStr(ADate)]), mList);
    if mList.Count > 0 then
      Result := NxIBStrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;

function GetStorePrice(AOS : TNxCustomObjectSpace; aStore_ID, aStoreCard_ID : string) : Extended;
const
  cSQL = 'SELECT AverageStorePrice FROM StoreSubCards WHERE Store_ID=''%s'' and StoreCard_ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aStore_ID, aStoreCard_ID]), mList);
    if mList.Count > 0 then
      Result := NxIBStrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;

begin
end.