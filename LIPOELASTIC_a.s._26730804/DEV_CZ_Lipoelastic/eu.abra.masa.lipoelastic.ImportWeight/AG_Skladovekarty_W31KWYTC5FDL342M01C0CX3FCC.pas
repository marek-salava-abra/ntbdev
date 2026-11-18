procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImportWeight';
  mAction.Caption := 'Import vah';
  mAction.Hint := 'Naimportuje data z xls, struktura ean,hm. intrastat, jednotka hmotnosti, hm. jednotka, jednotka hmotnosti';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportWeight;
end;

Procedure ImportWeight(sender:TComponent);
var
 mSite:TSiteForm;
 mOpenDlg: TOpenDialog;
 mOS:TNxCustomObjectSpace;
 mExcel, mWB, mSheet: Variant;
 i,j,k,l: integer;
 mEAN, mStoreCard_ID:string;
 mStoreCardBO, mUnitBO:TNxCustomBusinessObject;
 mStoreUnits:TNxCustomBusinessMonikerCollection;
begin
  mSite := TComponent(Sender).Site;
  mOS:=msite.BaseObjectSpace;
  mOpenDlg:=TOpenDialog.Create(sender);
  mOpenDlg.Title := 'Import z Excelu';
  mOpenDlg.Filter := 'Soubory aplikace Excel (*.xls, *.xlsx)| *.xls;*.xlsx';
  if mOpenDlg.Execute then begin
    try
      mExcel := CreateOleObject('Excel.Application');
      mWB := mExcel.Workbooks.Open(mOpenDlg.FileName);
      mSheet := mWB.Sheets[1];
      k:=mSheet.UsedRange.Rows.Count;
       i:=2;
          WaitWin.StartProgress('Čekejte, prosím ...', '', k);
               while i<k+1 do begin
                 mEAN:=VarToStr(mSheet.Cells[i, 1]);
                 if not(NxIsBlank(mEAN)) then begin
                  mStoreCard_ID:=mOS.SQLSelectFirstAsString('SELECT a.id FROM StoreCards A WHERE (((A.EAN LIKE N'+QuotedStr(mEAN)+' ESCAPE ''~'') '+
                                                            ' OR (A.id in (Select su.parent_id from storeunits su where su.EAN LIKE N'+QuotedStr(mEAN)+' ESCAPE ''~'')) '+
                                                            ' OR  (A.ID IN (SELECT SU.Parent_ID FROM StoreEANs SE JOIN StoreUnits SU ON SE.Parent_Id = SU.Id '+
                                                            ' WHERE SU.Parent_ID = A.ID AND SE.Ean LIKE N'+QuotedStr(mEAN)+' ESCAPE ''~'')) ) ) AND (A.Hidden = ''N'' )','');
                  if not(NxIsEmptyOID(mStoreCard_ID)) then begin
                    mStoreCardBO:=mOS.CreateObject(Class_StoreCard);
                    mStoreCardBO.Load(mstoreCard_ID,nil);
                    mStoreUnits:=mStoreCardBO.GetLoadedCollectionMonikerForFieldCode(mStoreCardBO.GetFieldCode('StoreUnits'));
                    for j:=0 to mStoreUnits.count-1 do begin
                      mUnitBO:=mStoreUnits.BusinessObject[j];
                      if mUnitBO.GetFieldValueAsString('EAN')=mEAN then begin
                        mUnitBO.SetFieldValueAsFloat('Weight',NxIBStrToFloat(VarToStr(mSheet.Cells[i, 4])));
                        if UpperCase(VarToStr(mSheet.Cells[i, 5]))='KG' then mUnitBO.SetFieldValueAsInteger('WeightUnit',1);
                        if UpperCase(VarToStr(mSheet.Cells[i, 5]))='G' then mUnitBO.SetFieldValueAsInteger('WeightUnit',0);
                        if UpperCase(VarToStr(mSheet.Cells[i, 5]))='T' then mUnitBO.SetFieldValueAsInteger('WeightUnit',2);
                      end;
                    end;
                    mStoreCardBO.SetFieldValueAsFloat('IntrastatWeight',NxIBStrToFloat(VarToStr(mSheet.Cells[i, 2])));
                     if UpperCase(VarToStr(mSheet.Cells[i, 3]))='KG' then mUnitBO.SetFieldValueAsInteger('IntrastatWeightUnit',1);
                     if UpperCase(VarToStr(mSheet.Cells[i, 3]))='G' then mUnitBO.SetFieldValueAsInteger('IntrastatWeightUnit',0);
                     if UpperCase(VarToStr(mSheet.Cells[i, 3]))='T' then mUnitBO.SetFieldValueAsInteger('IntrastatWeightUnit',2);
                    mStoreCardBO.save;
                    mStoreCardBO.free;
                  end;
                 end;
               Inc(i);
               WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(k));
               WaitWin.StepIt;
          end;
          WaitWin.Stop;
         mWB.Close;
    finally

    end;
   end;
end;


begin
end.