uses 'eu.abra.mavy.libs.common', 'eu.abra.mavy.libs.progress';
{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.Name := 'PricesImport';
  mAction.Caption := 'Import ceníku CSV';
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Category := 'tablist';
  mAction.Hint := 'Importuje ceník ve formátu CSV';
  mAction.OnExecute := @exeSupplierPricesImport2;
end;


procedure exeSupplierPricesImport2(Sender: TComponent);
var
  mBO, mBORow: TNxCustomBusinessObject;
  mRows: TNxCustomBusinessMonikerCollection;
  mOS: TNxCustomObjectSpace;
  mSite: TDynSiteForm;
  mOpenDlg: TOpenDialog;
  mFirm_ID, mSupplierCode, mSupplierName, mSupplierUnit, mPrice, mCurrency, mVAT, mTieredPrices, mDateStr, mSCUnitCode, mQUnit_ID, mExcelFileName, mCountryCode: string;
  mDeliveryTime, mMinQuantity, mSCCode, mSCName, mSCUnit, mStoreCard_ID, mPriceListCode, mPriceListName, mPriceListCurrency, mCountry_ID, mTempStr, mCurrency_ID: string;
  mVATFloat: Extended;
  mDate: TDateTime;
  mList: TStringList;
  mExcel, objWorkbook, mXLS: Variant;
  i,j, mCont: integer;
begin
  mSite:= TComponent(Sender).DynSite;
  mOS:= mSite.BaseObjectSpace;
  mList:= TStringList.Create;
  //SQLMultiSelect(mOS, 'SELECT ID FROM Firms WHERE Hidden = ''N''', mFirmIDs);

  mOpenDlg := TOpenDialog.Create(Sender);
  mOpenDlg.Filter := 'Soubor importu (*.CSV,*.csv)|*.CSV;*.csv';
  //mOpenDlg.Options := [ofAllowMultiSelect];
  if mOpenDlg.Execute then mExcelFileName := mOpenDlg.FileName else Exit;

  try
    mList.LoadFromFile(mOpenDlg.FileName);
    if mList.Count>0 then begin
      mTempStr:=            mlist.Strings[1];
      mFirm_ID:=            CdTokenEx(mTempStr, ';');
      mCountryCode:=         CdTokenEx(mTempStr, ';');
      mPriceListCode:=      CdTokenEx(mTempStr, ';');
      mPriceListName:=      CdTokenEx(mTempStr, ';');
      //mPriceListCurrency:=  CdTokenEx(mTempStr, ';');
      mDateStr:=            CdTokenEx(mTempStr, ';');
      if NxIsBlank(mDateStr) then mDate:= Trunc(Date) else mDate:= StrToDate(mDateStr);
      if StrToInt(SQLSingleSelect(mOS, 'SELECT COUNT(ID) FROM Firms WHERE ID ='+QuotedStr(mFirm_ID))) < 1 then begin
        ShowMessage('Firma nenalezena v adresáři firem');
        Exit;
      end;

      mBO:= mOS.CreateObject(Class_SupplierPriceList);
      try
        mBO.New;
        mBO.Prefill;
        mBO.SetFieldValueAsString('Code', mPriceListCode);
        mBO.SetFieldValueAsString('Name', mPriceListName);
        mBO.SetFieldValueAsString('Firm_ID', mFirm_ID);
        mBO.SetFieldValueAsDateTime('ValidFromDate$DATE', mDate);
        //mBO.SetFieldValueAsString('Country_ID', SQLSingleSelect(mOS, 'SELECT ID FROM Countries WHERE Code='+QuotedStr(mCountryCode));
        mRows:= mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
        ProgressInit(mSite, 'Zakládám řádky...', mList.Count-1);
        for i:=4 to mList.Count-1 do begin
          mTempStr:=       mlist.Strings[i];
          mSupplierCode:=  CdTokenEx(mTempStr, ';');
          mSupplierName:=  CdTokenEx(mTempStr, ';');
          mSupplierUnit:=  CdTokenEx(mTempStr, ';');
          mPrice:=         CdTokenEx(mTempStr, ';');
          mCurrency:=      CdTokenEx(mTempStr, ';');
          mVAT:=           CdTokenEx(mTempStr, ';');
          mTieredPrices:=  CdTokenEx(mTempStr, ';');
          mDeliveryTime:=  CdTokenEx(mTempStr, ';');
          mMinQuantity:=   CdTokenEx(mTempStr, ';');
          mSCCode:=        CdTokenEx(mTempStr, ';');
          mSCName:=        CdTokenEx(mTempStr, ';');
          mSCUnit:=        CdTokenEx(mTempStr, ';');

          if NxIsValidFloat(mVAT, 0) then mVATFloat:= StrToFloat(mVAT) else mVATFloat:= 0;
          mStoreCard_ID:= SQLSingleSelect(mOS, 'SELECT ID FROM StoreCards WHERE Code = '+QuotedStr(mSCCode)+' ORDER BY Hidden DESC');
          mQUnit_ID:= SQLSingleSelect(mOS, 'SELECT SU.ID FROM StoreUnits SU JOIN StoreCards SC ON SC.ID = SU.Parent_ID WHERE SU.Code ='+QuotedStr(mSCUnit)+' AND SC.ID='+QuotedStr(mStoreCard_ID));
          if NxIsEmptyOID(mQUnit_ID) then continue;

          mCurrency_ID:= SQLSingleSelect(mOS, 'SELECT ID FROM Currencies WHERE Code ='+QuotedStr(mCurrency));

          mBORow:= mRows.AddNewObject;
          if not NxIsEmptyOID(mStoreCard_ID) then begin
            mBORow.SetFieldValueAsString('StoreCard_ID', mStoreCard_ID);
            mBORow.SetFieldValueAsString('StoreUnit_ID', mQUnit_ID);
          end;
          mBORow.SetFieldValueAsString('Code', mSupplierCode);
          if not NxIsBlank(mSupplierUnit) then mBORow.SetFieldValueAsString('QUnit', mSupplierUnit);
          //mBORow.SetFieldValueAsString('Supplier_ID', fSuppOID);
          mBORow.SetFieldValueAsString('Name', mSupplierName);
          mBORow.SetFieldValueAsString('Currency_ID', mCurrency_ID);
          mBORow.SetFieldValueAsFloat('VATRate', mVATFloat);
          mBORow.SetFieldValueAsFloat('PurchasePrice', StrToFloat(mPrice));
          ProgressSetPos(i);
        end;
        mBO.Save;
      finally
        mBO.Free;
      end;
    end;
  except
    ShowMessage(ExceptionMessage);
    ProgressDispose();
  end;
  ProgressDispose();
  mOpenDlg.Free;
  mSite.RefreshData;
end;

{
function GetLatestCode(AOS: TNxCustomObjectSpace; ATable: string): string;
const
  mSQL = 'SELECT Code FROM %s ORDER BY Code DESC';
  mSQL2 = 'SELECT COUNT(Code) FROM %s';
var
  mList, mCount : TStringList;
begin
  mList := TStringList.Create;
  mCount := TStringList.Create;
  try
    AOS.SQLSelect(Format(mSQL, [ATable]), mList);
    AOS.SQLSelect(Format(mSQL2, [ATable]), mCount);
    if mList.Count > 0 then begin
      if NxIsNumeric(mList.Strings[0]) then begin
        Result := NxPadL(IntToStr(StrToInt(mList.Strings[0]) + 1), 3, '0');
      end else begin
        Result := NxPadL(mCount.Strings[0], 3, '0');
      end;
    end;
  finally
    mList.Free;
    mCount.Free;
  end;
end;
}
{
function GetStoreCard_ID(AOS: TNxCustomObjectSpace; ACode: string): string;
const
  mSQL = 'SELECT ID FROM StoreCards WHERE Hidden = ''N'' AND Code = ''%s''';
var
  mSQLResult, mCode: string;
begin
  Result:= '';
  Format(mSQL, [ACode]);
  mSQLResult:= SQLSingleSelect(AOS, mSQL);
  if not NxIsBlank(mSQLResult) then begin
    Result:= mSQLResult;
  end;
end;
}
{
function GetMainUnit_ID(AOS: TNxCustomObjectSpace; AStoreCard_ID: string): string;
const
  mSQL = 'SELECT SU.ID FROM StoreUnits SU JOIN StoreCards SC ON SC.ID = SU.Parent_ID WHERE SU.Parent_ID = ''%s'' AND SC.MainUnitCode = SU.Code';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(mSQL, [AStoreCard_ID]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:='';
  finally
    mList.Free;
  end;
end;
}
{function GetStoreUnit(AOS : TNxCustomObjectSpace; aCode, aParent_ID: string) : string;
const
  cSQL = 'SELECT ID FROM StoreUnits WHERE Hidden = ''N'' AND upper(code)=''%s'' and Parent_ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [UpperCase(aCode),aParent_ID]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:='';
  finally
    mList.Free;
  end;
end;
}

Function CdTokenEx(var AStr: string; const ASeparators: string): string;
var
  i: Integer;
begin
  i := NxCharPos(ASeparators, AStr);
  if i > 0 then begin
    Result := Copy(AStr, 1, i-1);
    Delete(AStr, 1, i-1);
    Delete(AStr, 1, Length(ASeparators));
  end
  else
  begin
    Result := AStr;
    AStr := '';
  end;
  Result := NxTrim(Result, '"');
  Result := NxTrim(Result, '''');
end;


begin
end.