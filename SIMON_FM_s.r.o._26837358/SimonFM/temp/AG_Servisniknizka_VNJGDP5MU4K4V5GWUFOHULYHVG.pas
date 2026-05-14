procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actGenDZV';
  mAction.Caption := 'Generování DZV';
  mAction.Hint := 'Generuje DZV';
  mAction.Category := 'tabList';
  mAction.OnExecute := @GenDZV;
end;

Procedure GenDZV(Sender:TComponent);
var
 mSite:TSiteForm;
begin
 mSite:=TComponent(Sender).DynSite;
 GenerateDZV(mSite.BaseObjectSpace);
end;

procedure GenerateDZV(OS: TNxCustomObjectSpace);
var
 mList, mPrintList:TStringList;
 mZLVBO,mDZVBO:TNxCustomBusinessObject;
 i:integer;
 mDZV_ID, mFileName, mDir:string;
begin
  mList:=TStringList.Create;
  OS.SQLSelect('SELECT A.ID FROM IssuedDInvoices A WHERE (A.DocQueue_ID = '+QuotedStr('2C20000101')+') AND ((A.PaidAmount - A.UsedAmount) > 0 ) AND (a.X_VatRate_ID is not null) ',mList);
  if mList.count>0 then begin
    for i:=0 to mList.count-1 do begin
      mZLVBO:=os.CreateObject(Class_IssuedDepositInvoice);
      mZLVBO.Load(mList.strings[i],nil);
      mDZV_ID:=CreateDocDZL(mZLVBO, mZLVBO.GetFieldValueAsFloat('PaidAmount')- mZLVBO.GetFieldValueAsFloat('UsedAmount'), mZLVBO.GetFieldValueAsString('X_VatRate_ID'), Date);
      if not(NxIsEmptyOID(mDZV_ID)) then begin
          mDir:='D:\abragen\ZLV';
          mPrintList:=TStringList.create;
          mDZVBO:=OS.CreateObject(Class_VATIssuedDepositInvoice);
          mDZVBO.Load(mDZV_ID,nil);
          mPrintList.add(mDZVBO.OID);
          mFileName:=NxSearchReplace(mDZVBO.DisplayName,'/','-',[srAll])+'.pdf';
          CFxReportManager.PrintByIDs(NxCreateContext_1(mDZVBO),mPrintList,GetDynSource(OS,'FH00000001'),'FH00000001',rtoFile,pekPDF,mDir,mFileName);
          mPrintList.Free;

         { SendInternalMail(OS,mDZVBO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Email'),'','', 'Daňový zálohový list vydaný '+mDZVBO.DisplayName,
          'Daňový zálohový list vydaný',mDir+'\'+mFileName, mDZVBO.GetFieldValueAsString('Firm_ID'),
                   '2600000101','1000000101'); }
      end;
      mZLVBO.free;
    end;
  end;
  //Success := True;
  //LogInfoStr := '';
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

Function CreateDocDZL(AZL:TNxCustomBusinessObject; mAMount: double; mVatRate_ID: string; ADate: Double):string;
var mManager : TNxDocumentImportManager ;
  mParams : TNxParameters;
  mRow, mRow_OP, mOP, mUsage : TNxCustomBusinessObject;
  mRows, mRows_OP : TNxCustomBusinessMonikerCollection;
  mDate: TDateTime;
  mRowText, mUsageID, mQuery, mAccID : string;
  mList : TStringList;
begin
  result := '';
  mManager := NxCreateDocumentImportManager(AZL.ObjectSpace,Class_IssuedDepositInvoice,Class_VATIssuedDepositInvoice);
  mParams := TNxParameters.Create();
  //mList := tStringlist.create;
  try
    mRows_OP := AZL.GetLoadedCollectionMonikerForFieldCode(AZL.GetFieldCode('Rows'));
    mRow_OP := mRows_OP.BusinessObject[0];
    OutputDebugString('zálohový list vydaný '+AZL.DisplayName);
    mManager.AddInputDocument(AZL.OID);
    mParams.GetOrCreateParam(dtFloat, 'DepositAmount').AsFloat := mAmount;
    mParams.GetOrCreateParam(dtString, 'DocQueue_ID').AsString := 'B200000101';
    mParams.GetOrCreateParam(dtDateTime, 'VatDate').AsdateTime := mDate;
    mDate := ADate;
    mManager.LoadParams(mParams);
    mManager.Execute;
    mManager.OutputDocument.SetFieldValueAsDateTime('DocDate$DATE', mDate);
    mManager.OutputDocument.SetFieldValueAsDateTime('AccDate$DATE', mDate);
    mManager.OutputDocument.SetFieldValueAsDateTime('VATDate$DATE', mDate);
    mManager.OutputDocument.SetFieldValueAsBoolean('PricesWithVAT', True);
    mManager.OutputDocument.SetFieldValueAsString('Description', NxLeft('Zúčtování '+AZL.DisplayName, 50));
    mManager.OutputDocument.SetFieldValueAsString('CreatedBy_ID','4000000101');
    //JIPE doplněno dohledání období
     mManager.OutputDocument.SetFieldValueAsString('Period_ID',HledejID('ID','periods',
        'datefrom$date<=' + Floattostr(mManager.OutputDocument.GetFieldValueAsDateTime('DocDate$date'))
         + ' and dateto$date > ' + Floattostr(mManager.OutputDocument.GetFieldValueAsDateTime('DocDate$date')),'OID','',AZL.ObjectSpace));

    mRows := mManager.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mManager.OutputDocument.GetFieldCode('Rows'));
    mRow := mRows.AddNewObject;
    mRow.Prefill;
    mRow.SetFieldValueAsInteger('RowType',4);
    mRow.SetFieldValueAsString('Division_ID',mRow_OP.GetFieldValueAsString('Division_ID'));
    mRow.SetFieldValueAsString('BusOrder_ID',mRow_OP.GetFieldValueAsString('BusOrder_ID'));
    mRow.SetFieldValueAsString('BusTransaction_ID',mRow_OP.GetFieldValueAsString('BusTransaction_ID'));
    mRow.SetFieldValueAsString('VATRate_ID',mVatRate_ID);
    mRowText := mRow_OP.GetFieldValueAsString('Text');
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