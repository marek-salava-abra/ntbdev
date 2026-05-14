
uses 'eu.abra.masa.importtxt.imports2';


procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Import TXT';
  mAction.Items.Add('Ze skladu 90');
  mAction.Hint := 'Import z textového souboru';
  mAction.Category := 'tabDetail';
  mAction.OnExecuteItem := @ImportTXT_OnExecute;
  mAction.OnUpdate := @ImportTXT_OnUpdate;
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

  case Index of
    0 : mStore_ID := '2D00000101';
    1 : mStore_ID := '1000000101';
    else
      mStore_ID := '2D00000101';
  end;
  mSite := NxFindSiteForm(TComponent(Sender));
  mOpenDlg := TOpenDialog.Create(Sender);
  try
    if mOpenDlg.Execute then begin
      mList := TStringLIst.Create;
      try
        mList.LoadFromFile(mOpenDlg.FileName);
        //Import_AddRows(ARows : TNxCustomBusinessMonikerCollection; AList : TStringList; ADivision_ID : string; AStore_ID : string)
        mBO := TDynSiteForm(mSite).CurrentObject;
        Import_AddRows2(mBO.GetCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows')), mList, '1100000101', mStore_ID{'1400000101'});
        // po přidání řádku provedu refresh
        mGRows := TMultiGrid(NxFindChildControl(NxGetSiteAppForm(mSite), 'grdRows'));
        if Assigned(mGRows) then
            mGRows.DataSource.DataSet.Refresh;
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


begin
end..