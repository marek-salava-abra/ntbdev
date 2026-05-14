uses 'eu.spedos.DodCen.progress';


procedure InsertRow(Sender : TButton);
var
  mSite: TSiteForm;
  mControl: TControl;
  mDataset: TNxRowsObjectDataSet;
  mRow: TNxCustomBusinessObject;
  mOpenDlg:TOpenDialog;
  mOS:TNxCustomObjectSpace;
  mExcel, mWB, mSheet: Variant;
  i:integer;
  mVyrData, mStoreCard_ID,mStoreUnit_ID:string;
begin
  try
    mSite := TComponent(Sender).Site;
    mOS:=msite.BaseObjectSpace;
    if not(TDynSiteForm(mSite).Edit) then begin
       NxShowSimpleMessage('Nejste ve stavu editace, řádky nepůjde vložit.',mSite);
       exit;
    end;
    mOpenDlg:=TOpenDialog.Create(sender);
    mOpenDlg.Title := 'Import z Excelu';
    mOpenDlg.Filter := 'Soubory aplikace Excel (*.xls, *.xlsx)| *.xls;*.xlsx';
    if mOpenDlg.Execute then begin
      try

        mExcel := CreateOleObject('Excel.Application');
        mWB := mExcel.Workbooks.Open(mOpenDlg.FileName);
        mSheet := mWB.Sheets[1];
        mControl:= mSite.FindChildControl('tabRows.grdRows');
        mDataset := TNxRowsObjectDataSet(TMultiGrid(mControl).DataSource.DataSet);

        if Assigned(mDataset) then begin
          mDataSet.DisableControls;
          ProgressInit(mSite, 'Zakládám řádky...', mSheet.UsedRange.Rows.Count);
               i:=2;
               while i<mSheet.UsedRange.Rows.Count+1 do begin
                mStoreCard_ID:=GetStoreCard_ID(mOS,VarToStr(mSheet.Cells[i, 3]));
                mStoreUnit_ID:=GetStoreUnit(mOS,VarToStr(mSheet.Cells[i, 7]),mStoreCard_ID);
                if not(NxIsEmptyOID(mStoreCard_ID)) and not(NxIsEmptyOID(mStoreUnit_ID)) {and (NxIBStrToFloat(VarToStr(mSheet.Cells[i, 5]))>0)} then begin    //nelogicky nulová cena do ceníku 31.8.2023
                  mRow := mDataSet.CreateBusinessObject;
                  mRow.Prefill;
                  mRow.SetFieldValueAsString('Code', VarToStr(mSheet.Cells[i, 1]));
                  mRow.SetFieldValueAsString('Name', VarToStr(mSheet.Cells[i, 2]));
                  mRow.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
                  mRow.SetFieldValueAsString('StoreUnit_ID',mStoreUnit_ID);
                  mRow.SetFieldValueAsFloat('PurchasePrice',NxIBStrToFloat(VarToStr(mSheet.Cells[i, 5])));
                  mRow.SetFieldValueAsFloat('MinimalQuantity',NxIBStrToFloat(VarToStr(mSheet.Cells[i, 9])));
                  mRow.SetFieldValueAsInteger('DeliveryTime',trunc(NxIBStrToFloat(VarToStr(mSheet.Cells[i, 8]))));
                  mRow.SetFieldValueAsString('Qunit', VarToStr(mSheet.Cells[i, 7]));
                  mRow.SetFieldValueAsString('Currency_ID',GetCurrencyID(mOS,UpperCase(VarToStr(mSheet.Cells[i, 6]))));
                end;
                 if (NxIsEmptyOID(mStoreCard_ID)) and (NxIsEmptyOID(mStoreUnit_ID)) {and (NxIBStrToFloat(VarToStr(mSheet.Cells[i, 5]))>0)} then begin   //nelogicky nulová cena do ceníku 31.8.2023
                  mRow := mDataSet.CreateBusinessObject;
                  mRow.Prefill;
                  mRow.SetFieldValueAsString('Code', VarToStr(mSheet.Cells[i, 1]));
                  mRow.SetFieldValueAsString('Name', VarToStr(mSheet.Cells[i, 2]));
                  mRow.SetFieldValueAsFloat('PurchasePrice',NxIBStrToFloat(VarToStr(mSheet.Cells[i, 5])));
                  mRow.SetFieldValueAsFloat('MinimalQuantity',NxIBStrToFloat(VarToStr(mSheet.Cells[i, 9])));
                  mRow.SetFieldValueAsInteger('DeliveryTime',trunc(NxIBStrToFloat(VarToStr(mSheet.Cells[i, 8]))));
                  mRow.SetFieldValueAsString('Qunit', VarToStr(mSheet.Cells[i, 7]));
                  mRow.SetFieldValueAsString('Currency_ID',GetCurrencyID(mOS,UpperCase(VarToStr(mSheet.Cells[i, 6]))));
                end;
                Inc(i);
                ProgressSetPos(i);
              end;
              ProgressDispose();
              //konec importu
              mWB.Close;
          end;


      finally
      end;
    end;

  finally
    TDynSiteForm(mSite).ActiveDataSet.UpdateFields; //Aby se o změně dozvěděl hlavičkový dataset
    mDataset.RefreshAndRestoreLastSelectedItem;
    mDataSet.EnableControls;
  end;
end;

function GetStoreCard_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT ID FROM StoreCards WHERE code=''%s'' and hidden=''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:='';
  finally
    mList.Free;
  end;
end;

function GetCurrencyID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT ID FROM Currencies WHERE code=''%s'' and hidden=''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:='';
  finally
    mList.Free;
  end;
end;

function GetStoreUnit(AOS : TNxCustomObjectSpace; aCode, aParent_ID: string) : string;
const
  cSQL = 'SELECT ID FROM StoreUnits WHERE upper(code)=''%s'' and Parent_ID=''%s'' ';
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

{
Vyvolává se po vytvoření instance formuláře.
}
procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mMAction: TMultiAction;
begin
  // Vytorime novou jednoduchou akci
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Přidání XLS';
  mAction.Hint := 'Přidání řádků z excelu';
  mAction.Category := 'tabDetail';
  mAction.OnExecute := @InsertRow;
end;

begin
end.