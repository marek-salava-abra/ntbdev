

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Pohyby';
  mAction.Items.Add('Pohyby');
  mAction.Hint := 'Pohyby skladové karty';
  mAction.Category := 'tabDetail';
  mAction.OnExecuteItem := @ImportTXT_OnExecute;
  //mAction.OnUpdate := @ImportTXT_OnUpdate;
end;


procedure ImportTXT_OnExecute(Sender : TComponent; Index : integer);
var
  mSite : TSiteForm;
  mDataset: TNxRowsObjectDataSet;
  mList : TStringList;
  mBO, mRowObject : TNxCustomBusinessObject;
  mGRows : TMultiGrid;
  mStore_ID : string;
begin

  mSite := TComponent(Sender).DynSite;
  try

      try

        mBO := TDynSiteForm(mSite).CurrentObject;

        // po přidání řádku provedu refresh
        mGRows := TMultiGrid(NxFindChildControl(NxGetSiteAppForm(mSite), 'grdRows'));
         mDataSet := TNxRowsObjectDataSet(mGRows.DataSource.DataSet);
         if mDataSet.IsEmpty then exit;
         mRowObject := mDataSet.CurrentObject;
         if not Assigned(mRowObject) then exit;
         if NxIsEmptyOID(mRowObject.GetFieldValueAsString('StoreCard_ID')) then exit;
        mSite.ShowSite('05O2XT2S23E13HBT00C5OG4NF4', True, 'QueryByUserDynSQLCondition;A.Store_ID='+QuotedStr(mRowObject.GetFieldValueAsString('Store_ID'))+' and a.storecard_id='+QuotedStr(mRowObject.GetFieldValueAsString('StoreCard_ID'))+';Omezení za pohyby');
        //ShowMessage(mRowObject.GetFieldValueAsString('StoreCard_ID.Name'));

      finally

      end;


  finally
  end;
end;



begin
end.