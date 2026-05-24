procedure InitSite_Hook(Self: TSiteForm);
var
  mAction:TAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actCreateSC';
  mAction.Caption := '## Založí karty dle XLS ##';
  mAction.Hint := 'založení karet dle XLS';
  mAction.Category := 'tabList';
  mAction.OnExecute := @CreateSC;
  {
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actInsertSC';
  mAction.Caption := '## Doplní jednotku ##';
  mAction.Hint := 'doplní jednotku dle XLS';
  mAction.Category := 'tabList';
  mAction.OnExecute := @InsertSCUnit;}
end;

Procedure InsertSCUnit(Sender:TComponent);
var
 mSite:TSiteForm;
 mOpenDlg: TOpenDialog;
 mOS:TNxCustomObjectSpace;
 mExcel, mWB, mSheet: Variant;
 i,j,k,l: integer;
 mCode, mStoreCard_ID:string;
 mSCBO, mUnitBO, mStorePriceBO, mStorePriceRowBO:TNxCustomBusinessObject;
 mUnits, mStorePrices:TNxCustomBusinessMonikerCollection;
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
          While i<k+1 do begin
               mCode:=VarToStr(mSheet.Cells[i, 1]);
               mStoreCard_ID:=mOS.SQLSelectFirstAsString('Select id from storecards where code='+QuotedStr(mCode)+' and hidden=''N'' ', '');
               if not(NxIsEmptyOID(mStoreCard_ID)) then begin
                 mSCBO:=mOS.CreateObject(Class_StoreCard);
                 mSCBO.load(mStoreCard_ID,nil);
                 mUnits:=mSCBO.GetLoadedCollectionMonikerForFieldCode(mSCBO.GetFieldCode('StoreUnits'));
                 mUnitBO:=mUnits.AddNewObject;
                 mUnitBO.SetFieldValueAsString('Code',VarToStr(mSheet.Cells[i, 3]));
                 mUnitBO.SetFieldValueAsFloat('UnitRate', NxIBStrToFloat(VarToStr(mSheet.Cells[i, 2])));
                 mSCBO.save;
                 mscbo.free;
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

Procedure CreateSC(Sender:TComponent);
var
 mSite:TSiteForm;
 mOpenDlg: TOpenDialog;
 mOS:TNxCustomObjectSpace;
 mExcel, mWB, mSheet: Variant;
 i,j,k,l: integer;
 mCode, mStoreCard_ID:string;
 mSCBO, mUnitBO, mStorePriceBO, mStorePriceRowBO:TNxCustomBusinessObject;
 mUnits, mStorePrices:TNxCustomBusinessMonikerCollection;
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
          While i<k+1 do begin
               mCode:=VarToStr(mSheet.Cells[i, 1]);
                 if not(NxIsBlank(mCode)) then begin
                  mSCBO:=mOS.CreateObject(Class_StoreCard);
                  mSCBO.new;
                  mSCBO.prefill;
                  mSCBO.SetFieldValueAsString('Code',mCode);
                  mSCBO.SetFieldValueAsString('Name',VarToStr(mSheet.Cells[i, 2]));
                  mSCBO.SetFieldValueAsString('Specification',VarToStr(mSheet.Cells[i, 16]));
                  mSCBO.SetFieldValueAsString('X_Name_35',AnsiLeftStr(VarToStr(mSheet.Cells[i, 2]),35));
                  mSCBO.SetFieldValueAsString('X_Rozmer',VarToStr(mSheet.Cells[i, 4]));
                  mSCBO.SetFieldValueAsInteger('X_Prumer',StrToInt(VarToStr(mSheet.Cells[i, 18])));
                  mSCBO.SetFieldValueAsInteger('X_DELKA',StrToInt(VarToStr(mSheet.Cells[i, 19])));
                  mSCBO.SetFieldValueAsInteger('X_TYP_ZAVITU',StrToInt(VarToStr(mSheet.Cells[i, 20])));
                  mSCBO.SetFieldValueAsString('X_DIN',AnsiLeftStr(VarToStr(mSheet.Cells[i, 22]),12));
                  mSCBO.SetFieldValueAsString('X_ISO',AnsiLeftStr(VarToStr(mSheet.Cells[i, 23]),12));
                  mSCBO.SetFieldValueAsString('X_CSN',AnsiLeftStr(VarToStr(mSheet.Cells[i, 24]),12));
                  if not(NxIsBlank(VarToStr(mSheet.Cells[i, 5]))) then
                   mSCBO.SetFieldValueAsString('X_BMS_Material_ID', mOS.SQLSelectFirstAsString('Select id from defrolldata where hidden=''N'' and clsid='+QuotedStr(Class_BMS_material)+
                                                                                               ' and code='+QuotedStr(VarToStr(mSheet.Cells[i, 5])),''));
                  if not(NxIsBlank(VarToStr(mSheet.Cells[i, 6]))) then
                   mscbo.SetFieldValueAsString('X_BMS_Skupina_ID', mOS.SQLSelectFirstAsString('Select id from defrolldata where hidden=''N'' and clsid='+QuotedStr(Class_BMS_skupina)+
                                                                                               ' and code='+QuotedStr(VarToStr(mSheet.Cells[i, 6])),''));
                  if not(NxIsBlank(VarToStr(mSheet.Cells[i, 15]))) then
                   mscbo.SetFieldValueAsString('X_BMS_povrchUprava_ID', mOS.SQLSelectFirstAsString('Select id from defrolldata where hidden=''N'' and clsid='+QuotedStr(Class_BMS_povrch_uprava)+
                                                                                               ' and code='+QuotedStr(VarToStr(mSheet.Cells[i, 15])),''));
                  if not(NxIsBlank(VarToStr(mSheet.Cells[i, 21]))) then
                   mscbo.SetFieldValueAsString('X_BMS_tvarhlava_ID', mOS.SQLSelectFirstAsString('Select id from defrolldata where hidden=''N'' and clsid='+QuotedStr(Class_BMS_tvar_hlavy)+
                                                                                               ' and code='+QuotedStr(VarToStr(mSheet.Cells[i, 21])),''));
                  if not(NxIsBlank(VarToStr(mSheet.Cells[i, 12]))) then
                   mscbo.SetFieldValueAsString('X_BMS_Obal_ID', mOS.SQLSelectFirstAsString('Select id from defrolldata where hidden=''N'' and clsid='+QuotedStr(Class_BMS_obal)+
                                                                                               ' and code='+QuotedStr(VarToStr(mSheet.Cells[i, 12])),''));
                  mscbo.SetFieldValueAsString('StoreMenuItem_ID',mOS.SQLSelectFirstAsString('Select id from storemenu where hidden=''N'' and parent_id is not null and text='+QuotedStr(VarToStr(mSheet.Cells[i, 9])),''));
                  mSCBO.SetFieldValueAsString('StoreAssortmentGroup_ID',mOS.SQLSelectFirstAsString('Select id from storeasSORTMENTGROUPs where hidden=''N'' and code='+QuotedStr(VarToStr(mSheet.Cells[i, 10])),''));
                  mSCBO.SetFieldValueAsString('StoreCardCategory_ID',mOS.SQLSelectFirstAsString('select id from storecardcategories where code='+
                                                                                                 QuotedStr(VarToStr(mSheet.Cells[i, 11])),'1100000101'));
                  mSCBO.SetFieldValueAsString('VatRate_ID',mOS.SQLSelectFirstAsString('select id from VatRates where tariff='+
                                                                                                 IntToStr(trunc(NxIBStrToFloat(VarToStr(mSheet.Cells[i, 7])))),'02100X0000'));
                  mUnits:=mSCBO.GetLoadedCollectionMonikerForFieldCode(mSCBO.GetFieldCode('StoreUnits'));
                  mUnitBO:=mUnits.BusinessObject[0];
                  mUnitBO.SetFieldValueAsString('Code',VarToStr(mSheet.Cells[i, 3]));
                  mUnitBO.SetFieldValueAsString('EAN',VarToStr(mSheet.Cells[i, 8]));
                  mUnitBO.SetFieldValueAsInteger('PLU',StrToInt(VarToStr(mSheet.Cells[i, 17])));
                  mSCBO.SetFieldValueAsString('MainUnitCode',VarToStr(mSheet.Cells[i, 3]));
                  mSCBO.save;
                  mStoreCard_ID:=mSCBO.OID;
                  mSCBO.free;
                  if NxIBStrToFloat(VarToStr(mSheet.Cells[i, 14]))>0 then begin
                    mStorePriceBO:=mOS.CreateObject(Class_StorePrice);
                    mStorePriceBO.new;
                    mStorePriceBO.prefill;
                    mStorePriceBO.SetFieldValueAsString('PriceList_ID','1000000101');
                    mStorePriceBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
                    mStorePrices:=mStorePriceBO.GetLoadedCollectionMonikerForFieldCode(mStorePriceBO.GetFieldCode('PriceRows'));
                    mStorePriceRowBO:=mStorePrices.AddNewObject;
                    mStorePriceRowBO.SetFieldValueAsString('Price_ID','1000000101');
                    mStorePriceRowBO.SetFieldValueAsFloat('Amount',NxIBStrToFloat(VarToStr(mSheet.Cells[i, 14])));
                    mStorePriceRowBO.SetFieldValueAsString('Qunit',VarToStr(mSheet.Cells[i, 3]));
                    mStorePriceBO.save;
                    mStorePriceBO.free;
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