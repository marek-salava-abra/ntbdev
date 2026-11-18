uses 'eu.masa.import.progress';


procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Import CSV';
  mAction.Items.Add('Import DSV');
  mAction.Hint := 'Import z textového souboru';
  mAction.Category := 'tabDetail';
  mAction.OnExecuteItem := @ImportTXT_OnExecute;
end;


procedure ImportTXT_OnExecute(Sender : TComponent; Index : integer);
var
  mSite : TSiteForm;
  mOpenDlg : TOpenDialog;
  mList : TStringList;
  mBO : TNxCustomBusinessObject;
  mGRows : TMultiGrid;
  mStore_ID : string;
begin
  mSite := NxFindSiteForm(TComponent(Sender));
  mOpenDlg := TOpenDialog.Create(Sender);
  try
    if mOpenDlg.Execute then begin
      mList := TStringLIst.Create;
      try
        mList.LoadFromFile(mOpenDlg.FileName);
        //Import_AddRows(ARows : TNxCustomBusinessMonikerCollection; AList : TStringList; ADivision_ID : string; AStore_ID : string)
        mBO := TDynSiteForm(mSite).CurrentObject;
        Import_AddRows(mBO.GetCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows')), mList, mSite, mBO);
        // po přidání řádku provedu refresh
        mGRows := TMultiGrid(NxFindChildControl(NxGetSiteAppForm(mSite), 'grdRows'));
        TNxCustomAccountedDocument(mBO).RecalculateDocument;
        if Assigned(mGRows) then
            mGRows.DataSource.DataSet.Refresh;
         TDynSiteForm(msite).ActiveDataSet.UpdateFields;

      finally
        mList.Free;
      end;
      ShowMessage('Import dokončen.');
    end else
      ShowMessage('Import přerušen.');
  finally
    mOpenDlg.Free;
  end;
end;


function scrStorecard_ID(AOS : TNxCustomObjectSpace; AOrderRow_ID : string) : string;
const
  cSQL = 'SELECT ID FROM Storecards where code=''%s'' and hidden=''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [AOrderRow_ID]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function scrStore_ID(AOS : TNxCustomObjectSpace; AOrderRow_ID : string) : string;
const
  cSQL = 'SELECT ID FROM Stores where code=''%s'' and hidden=''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [AOrderRow_ID]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

procedure Import_AddRows(var ARows : TNxCustomBusinessMonikerCollection;var AList : TStringList;var aSite:TSiteForm;var aBO:TNxCustomBusinessObject);
var
  i : Integer;
  mRowBO : TNxCustomBusinessObject;
  Invoice_no,Invoice_date,Customer,Marks,Colli,Collitype,Content,Grossweight,Billing_Weight:string;
  LDM,CBM,Department,Traffic,Transport,Trip,Consignment_Number,Customer_Ref1,Customer_Ref2,Terms,Shipper_Name:string;
  Shipper_Address1,Shipper_Address2,Shipper_Address3,Shipper_Address4,Shipper_Country,Shipper_Postcode,Consignee_Name:string;
  Consignee_Address1,Consignee_Address2,Consignee_Address3,Consignee_Address4,Consignee_Country,Consignee_Postcode:String;
  Delivery_Date,Pickup_Date,Equipment1,Equipment2,Equipment_Type,Account_Code,Text,Exchange_Rate,Currency,VAT_Amount:string;
  Amount,Calculation_and_texts,Sub_Customer, myStr : string;
  mQuantity, mprice : double;
  mDQCode,mPeriodCode, mOrdNumber, mTempStr:string;
  mList:TStringList;
begin
  ProgressInit(aSite, 'import položek...', aList.count);
  for i := 0 to AList.Count - 1 do begin
    myStr := Alist.strings[i];
    Invoice_no:=NxTrapstr(myStr,';');
    Invoice_date:=NxTrapstr(myStr,';');
    Customer:=NxTrapstr(myStr,';');
    Marks:=NxTrapstr(myStr,';');
    Colli:=NxTrapstr(myStr,';');
    Collitype:=NxTrapstr(myStr,';');
    Content:=NxTrapstr(myStr,';');
    Grossweight:=NxTrapstr(myStr,';');
    Billing_Weight:=NxTrapstr(myStr,';');
    LDM:=NxTrapstr(myStr,';');
    CBM:=NxTrapstr(myStr,';');
    Department:=NxTrapstr(myStr,';');
    Traffic:=NxTrapstr(myStr,';');
    Transport:=NxTrapstr(myStr,';');
    Trip:=NxTrapstr(myStr,';');
    Consignment_Number:=NxTrapstr(myStr,';');
    Customer_Ref1:=NxTrapstr(myStr,';');
    Customer_Ref2:=NxTrapstr(myStr,';');
    Terms:=NxTrapstr(myStr,';');
    Shipper_Name:=NxTrapstr(myStr,';');
    Shipper_Address1:=NxTrapstr(myStr,';');
    Shipper_Address2:=NxTrapstr(myStr,';');
    Shipper_Address3:=NxTrapstr(myStr,';');
    Shipper_Address4:=NxTrapstr(myStr,';');
    Shipper_Country:=NxTrapstr(myStr,';');
    Shipper_Postcode:=NxTrapstr(myStr,';');
    Consignee_Name:=NxTrapstr(myStr,';');
    Consignee_Address1:=NxTrapstr(myStr,';');
    Consignee_Address2:=NxTrapstr(myStr,';');
    Consignee_Address3:=NxTrapstr(myStr,';');
    Consignee_Address4:=NxTrapstr(myStr,';');
    Consignee_Country:=NxTrapstr(myStr,';');
    Consignee_Postcode:=NxTrapstr(myStr,';');
    Delivery_Date:=NxTrapstr(myStr,';');
    Pickup_Date:=NxTrapstr(myStr,';');
    Equipment1:=NxTrapstr(myStr,';');
    Equipment2:=NxTrapstr(myStr,';');
    Equipment_Type:=NxTrapstr(myStr,';');
    Account_Code:=NxTrapstr(myStr,';');
    Text:=NxTrapstr(myStr,';');
    Exchange_Rate:=NxTrapstr(myStr,';');
    Currency:=NxTrapstr(myStr,';');
    VAT_Amount:=NxTrapstr(myStr,';');
    Amount:=NxTrapstr(myStr,';');
    Calculation_and_texts:=NxTrapstr(myStr,';');
    Sub_Customer:=NxTrapstr(myStr,';');

    if (NxIBStrToFloat(Amount) > 0) then begin
      mRowBO := ARows.AddNewObject;
      mRowBO.Prefill;
      mRowBO.SetFieldValueAsString('VatRate_ID','02100X0000');
      mrowBo.SetFieldValueAsString('Division_ID','1000000101');
      mRowBO.SetFieldValueAsFloat('TAmountWithoutVAT',NxIBStrToFloat(Amount));
      mRowBO.SetFieldValueAsString('Text',TEncoding.NormalizeUnicodeString(Content+' '+Text));
      if (AnsiLeftStr(Content,1)='D') or (AnsiLeftStr(Content,1)='P') then begin
       if NxSearch(Content,',',[srAll],0)=0 then begin
          mList:=TStringList.create;
          mTempStr:=content;
          mDQCode:=NxToken(Content,'-');
          mOrdNumber:=NxToken(Content,'/');
          mPeriodCode:=Content;
          if not(NxIsBlank(mPeriodCode)) then begin
          if (AnsiLeftStr(mTempStr,1)='D') then
           Asite.GetFakeBusinessObject.ObjectSpace.SQLSelect(format('Select sd2.BusProject_id from storedocuments sd /*left*/ join StoreDocuments2 sd2 on sd2.parent_id=sd.id /*left*/ join periods p on p.id=sd.period_id /*left*/ join docqueues dq on dq.id=sd.docqueue_id where sd.documenttype=''%s'' and dq.code=''%s'' and p.code=''%s'' and sd.ordnumber=%s',['21',UpperCase(mDQCode),mPeriodCode,mOrdNumber]),mList);
          if (AnsiLeftStr(mTempStr,1)='P') then
           Asite.GetFakeBusinessObject.ObjectSpace.SQLSelect(format('Select sd2.BusProject_id from storedocuments sd /*left*/ join StoreDocuments2 sd2 on sd2.parent_id=sd.id /*left*/ join periods p on p.id=sd.period_id /*left*/ join docqueues dq on dq.id=sd.docqueue_id where sd.documenttype=''%s'' and dq.code=''%s'' and p.code=''%s'' and sd.ordnumber=%s',['22',UpperCase(mDQCode),mPeriodCode,mOrdNumber]),mList);
          end;
          if mlist.count>0 then mRowBO.SetFieldValueAsString('BusProject_ID', mlist.strings[0]);
          mlist.free;
       end;
      end;
    // TNxCustomAccountedDocument(aBO).RecalculateDocument;
    end;
  ProgressSetPos(i+1);
  end;
  ProgressDispose();
end;

begin
end..