uses 'eu.spedos.PEVaPEP.progress';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mMAction: TMultiAction;
begin
  // Vytorime novou jednoduchou akci
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Přidání CSV';
  mAction.Hint := 'Přidání řádků CSV';
  mAction.Category := 'tabDetail';
  mAction.OnExecute := @InsertRow;
end;

Procedure InsertRow(sender:TComponent);
var
 mSite:TSiteForm;
 mList:TStringList;
 i:integer;
 mOpenDlg:TOpenDialog;
 mOS:TNxCustomObjectSpace;
 mControl: TControl;
 mDataset: TNxRowsObjectDataSet;
 mRow: TNxCustomBusinessObject;
 mStoreCode, mStoreCardCode, mTempStr:String;
 mStore_ID, mStoreCard_ID:String;
 mQuantity:Extended;
begin
 try
     mSite:=TComponent(sender).DynSite;
     mOS:=msite.BaseObjectSpace;
     if not(TDynSiteForm(mSite).Edit) then begin
        NxShowSimpleMessage('Nejste ve stavu editace, řádky nepůjde vložit.',mSite);
        exit;
     end;
        mOpenDlg:=TOpenDialog.Create(sender);
        mOpenDlg.Title := 'Import z CSV';
        mOpenDlg.Filter := 'Soubory s daty (*.csv)| *.csv';
        if mOpenDlg.Execute then begin
          mList:=TStringList.Create;
          mList.LoadFromFile(mOpenDlg.FileName);
          if mList.Count>2 then begin
              try
               mControl:= mSite.FindChildControl('tabRows.grdRows');
               mDataset := TNxRowsObjectDataSet(TMultiGrid(mControl).DataSource.DataSet);

               if Assigned(mDataset) then begin
                  mDataSet.DisableControls;
                  ProgressInit(mSite, 'Zakládám řádky...', mList.count);
                  for i:=1 to mList.count-1 do begin
                    mTempStr:=mList.Strings[i];
                    mStoreCode:=NxTrapStr(mTempStr,';');
                    mStoreCardCode:=NxTrapStr(mTempStr,';');
                    mQuantity:= NxIBStrToFloat(NxTrapStr(mTempStr,';'));
                    mStore_ID:=GetStore_ID(mOS, mStoreCode);
                    mStoreCard_ID:=GetStoreCard_ID(mOS, mStoreCardCode);
                    if not(NxIsEmptyOID(mStoreCard_ID)) and not(NxIsEmptyOID(mStore_ID)) and (mQuantity>0) then begin
                      mRow := mDataSet.CreateBusinessObject;
                      mRow.Prefill;
                      mRow.SetFieldValueAsString('Store_ID',mStore_ID);
                      mRow.SetFieldValueAsString('StoreCard_ID', mStoreCard_ID);
                      mRow.SetFieldValueAsFloat('Quantity', mQuantity);
                      mRow.SetFieldValueAsString('Division_ID','D000000101');
                    end;
                   ProgressSetPos(i);
                  end;
                  ProgressDispose();
               end;

              finally
                TDynSiteForm(mSite).ActiveDataSet.UpdateFields; //Aby se o změně dozvěděl hlavičkový dataset
                mDataset.RefreshAndRestoreLastSelectedItem;
                mDataSet.EnableControls;
              end;
          end;
        end;
  Except
   ProgressDispose();
   NxShowSimpleMessage(ExceptionMessage,mSite);
  end;
end;

begin
end.