procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImportQ';
  mAction.Caption := 'Import Q';
  mAction.Hint := 'Import data from CSV';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportData;
end;

Procedure ImportData(Sender:TComponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mBO, mRowBO, mDRBBO:TNxCustomBusinessObject;
 i,m:integer;
 mList:TStringList;
 mOpenDlg:TOpenDialog;
 mRows, mDocRowBatches:TNxCustomBusinessMonikerCollection;
 mTempStr, mStore_ID, mStoreCard_ID, mQuantity, mStoreBatch_ID:string;
begin
  mSite:=TComponent(sender).DynSite;
  mOS:=mSite.BaseObjectSpace;
  mList:=tstringlist.create;
  mOpenDlg := TOpenDialog.Create(Sender);
  if mOpenDlg.Execute then begin
    mList.LoadFromFile(mOpenDlg.FileName);
    if mList.Count>0 then begin
      try
        m:=0;
        WaitWin.StartProgress('Please, wait ...', '', mList.Count);
        for i:=0 to mlist.count-1 do begin
           if m=0 then begin
             mBO:=mOS.CreateObject(Class_InventoryOverplus);
             mBO.new;
             mbo.prefill;
             mbo.SetFieldValueAsString('Period_ID','1000000101');
             mBO.SetFieldValueAsDateTime('DocDate$Date',StrToDate('25.11.2021'));
             mBO.SetFieldValueAsString('Firm_ID','AAA1000000');
             mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows'));
           end;
            mTempStr:=mList.Strings[i];
            mStore_ID:=NxTrapStrTrim(mTempStr,';');
            mStoreCard_ID:=NxTrapStrTrim(mTempStr,';');
            mQuantity:=NxTrapStrTrim(mTempStr,';');
            mStoreBatch_ID:=NxTrapStrTrim(mTempStr,';');
            mRowBO:=mRows.AddNewObject;
            mRowBO.Prefill;
            mRowBO.SetFieldValueAsString('Store_ID',mStore_ID);
            mRowBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
            mRowBO.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mQuantity));
            mRowBO.SetFieldValueAsString('Division_ID','1000000101');
            mRowBO.SetFieldValueAsFloat('UnitPrice',0);
            mRowBo.SetFieldValueAsFloat('TotalPrice',0);
            mRowBO.SetFieldValueAsBoolean('CompletePrices',true);
            if not(NxIsEmptyOID(mStoreBatch_ID)) then begin
              mDocRowBatches:=mRowBO.GetLoadedCollectionMonikerForFieldCode(mRowBO.GetFieldCode('DocRowBatches'));
              mDRBBO:=mDocRowBatches.AddNewObject;
              mDRBBO.SetFieldValueAsString('StoreBatch_ID',mStoreBatch_ID);
            end;
           inc(m);
           if (m=100) or (i=mlist.Count-1) then begin
             m:=0;
             mbo.save;
             mbo.free;
           end;
           WaitWin.ChangeText(IntToStr(1+i) + ' / ' + IntToStr(mList.Count));
           WaitWin.StepIt;
        end;
        WaitWin.stop;
      except
       WaitWin.stop;
       NxShowSimpleMessage(ExceptionMessage,mSite);
      end;
    end;
  end;
end;

begin
end.