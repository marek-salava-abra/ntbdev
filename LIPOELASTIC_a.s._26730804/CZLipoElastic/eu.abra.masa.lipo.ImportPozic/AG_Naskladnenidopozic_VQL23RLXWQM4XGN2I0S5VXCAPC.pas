procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImportComGate';
  mAction.Caption := 'Import CSV';
  mAction.Hint := 'Naimportuje data z CSV';
  mAction.Category := 'tabDetail';
  mAction.OnExecute := @ImportData;
end;

Procedure ImportData(Sender:TComponent);
Var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mList:TStringList;
 i:integer;
 mOpenDlg:TOpenDialog;
 mControl: TControl;
 mDataset: TNxRowsObjectDataSet;
 mRow, mStoreCardBO:TNxCustomBusinessObject;
 mTempStr:string;
 mStoreCard_ID, mStoreBatch_ID,mQuantity:string;
begin
  mSite:=TComponent(sender).DynSite;
  mOS:=mSite.BaseObjectSpace;
  mList:=tstringlist.create;
  mOpenDlg := TOpenDialog.Create(Sender);
  if mOpenDlg.Execute then begin
    mList.LoadFromFile(mOpenDlg.FileName);
    if mList.Count>0 then begin
     mControl:= mSite.FindChildControl('tabRows.grdRows');
     mDataset := TNxRowsObjectDataSet(TMultiGrid(mControl).DataSource.DataSet);
         if Assigned(mDataset) then begin
           mDataSet.DisableControls;
           WaitWin.StartProgress('Čekejte, prosím ...', '', mList.Count);
            for i:=0 to mlist.count-1 do begin
           mTempStr:=mlist.Strings[i];
           mStoreCard_ID:=NxTrim(NxTrapStr(mTempStr,';'),'"');
           mStoreBatch_ID:=NxTrim(NxTrapStr(mTempStr,';'),'"');
           mQuantity:=NxTrim(NxTrapStr(mTempStr,';'),'"');
               mStoreCardBO:=mOS.CreateObject(class_storecard);
               mStorecardBO.Load(mStoreCard_ID,nil);
               if NxIsEmptyOID(mStoreBatch_ID) then begin
                 mRow := mDataSet.CreateBusinessObject;
                 mRow.Prefill;
                 mRow.SetFieldValueAsString('Store_ID','51F1000101');
                 mRow.SetFieldValueAsString('Storecard_ID',mStoreCard_ID);
                 mRow.SetFieldValueAsString('Qunit',mStoreCardBO.GetFieldValueAsString('MainUnitCode'));
                 mRow.SetFieldValueAsString('StorePosition_ID','~00000007H');
                 mRow.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mQuantity));

                end else begin
                 mRow := mDataSet.CreateBusinessObject;
                 mRow.Prefill;
                 mRow.SetFieldValueAsString('Store_ID','51F1000101');
                 mRow.SetFieldValueAsString('Storecard_ID',mStoreCard_ID);
                 mRow.SetFieldValueAsString('Qunit',mStoreCardBO.GetFieldValueAsString('MainUnitCode'));
                 mRow.SetFieldValueAsString('StorePosition_ID','~00000007H');
                 mRow.SetFieldValueAsString('StoreBatch_ID',mStoreBatch_ID);;
                 mRow.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mQuantity));
                end;
               mStoreCardBO.free;
           WaitWin.ChangeText(IntToStr(1+i) + ' / ' + IntToStr(mList.Count));
           WaitWin.StepIt;
        end;
           WaitWin.Stop;
           TDynSiteForm(mSite).ActiveDataSet.UpdateFields; //Aby se o změně dozvěděl hlavičkový dataset
           mDataset.RefreshAndRestoreLastSelectedItem;
           mDataSet.EnableControls;
          end;
       NxShowSimpleMessage('Nahráno '+IntToStr(mlist.count-1)+' řádků.',mSite);
      end;
  end;
end;

begin
end.