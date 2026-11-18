procedure InitSite_Hook(Self: TSiteForm);
var
  mAction:TAction;
  mAction2:TMultiAction;
begin

  mAction2 := Self.GetNewMultiAction;
  mAction2.ShowControl := True;
  mAction2.ShowMenuItem := True;
  mAction2.Name := 'actImpSC';
  mAction2.Caption := '##XLS import##';
  mAction2.Items.Add('##XLS import##');
  mAction2.Items.Add('Import alternativních rozměrů');
  mAction2.Items.Add('Import cen MICHELIN');
  mAction2.Hint := 'naimportuje data z XLS ke skladovým kartám';
  mAction2.Category := 'tabList';
  mAction2.OnExecuteItem := @ImportDataSC;

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImpCatSC';
  mAction.Caption := '##XLS import kategorií##';
  mAction.Hint := 'naimportuje kategorie z XLS ke skladovým kartám';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportKategorieSC;
end;

Procedure ImportDataSC(sender:TComponent;index:Integer);
var
 mSite:TSiteForm;
 mOpenDlg: TOpenDialog;
 mOS:TNxCustomObjectSpace;
 mExcel, mWB, mSheet: Variant;
 i,j,k,l: integer;
 mID, mStoreCard_ID, mCAI, mPID:string;
 mStoreCardBO:TNxCustomBusinessObject;
 mPrice:extended;
begin
 if index=0 then begin
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
                 mID:=VarToStr(mSheet.Cells[i, 1]);
                 if not(NxIsBlank(mID)) then begin
                  mStoreCard_ID:=mOS.SQLSelectFirstAsString('select id from storecards where hidden='+Quotedstr('N')+' and id='+Quotedstr(mID),'');
                  if not(NxIsEmptyOID(mStoreCard_ID)) then begin

                    mStoreCardBO:=mOS.CreateObject(Class_StoreCard);
                    mStoreCardBO.Load(mstoreCard_ID,nil);
                    mStoreCardBO.SetFieldValueAsString('U_StoreCard_ID',mOS.SQLSelectFirstAsString('select id from storecards where storecardcategory_id='+QuotedStr('3000000101')+' and hidden='+Quotedstr('N')+' and name='+Quotedstr(VarToStr(mSheet.Cells[i, 4])),''));
                    if not(NxIsBlank(VarToStr(mSheet.Cells[i, 5]))) then
                     mStoreCardBO.SetFieldValueAsString('U_RozmerA',VarToStr(mSheet.Cells[i, 5]));
                    if not(NxIsBlank(VarToStr(mSheet.Cells[i, 6]))) then
                     mStoreCardBO.SetFieldValueAsString('U_RozmerB',VarToStr(mSheet.Cells[i, 6]));
                    if not(NxIsBlank(VarToStr(mSheet.Cells[i, 7]))) then
                     mStoreCardBO.SetFieldValueAsString('U_RozmerC',VarToStr(mSheet.Cells[i, 7]));
                    if not(NxIsBlank(VarToStr(mSheet.Cells[i, 8]))) then
                     mStoreCardBO.SetFieldValueAsString('U_Pocet',VarToStr(mSheet.Cells[i, 8]));
                    if not(NxIsBlank(VarToStr(mSheet.Cells[i, 9]))) then
                     mStoreCardBO.SetFieldValueAsString('U_PopisProCRM',VarToStr(mSheet.Cells[i, 9]));
                    if not(NxIsBlank(VarToStr(mSheet.Cells[i, 10]))) then
                     mStoreCardBO.SetFieldValueAsString('U_s_v_material',VarToStr(mSheet.Cells[i, 10]));
                    if VarToStr(mSheet.Cells[i, 11])='Černá' then  mStoreCardBO.SetFieldValueAsInteger('U_cerna_nespin',1);
                    if VarToStr(mSheet.Cells[i, 11])='Nešpinící' then  mStoreCardBO.SetFieldValueAsInteger('U_cerna_nespin',2);
                    if VarToStr(mSheet.Cells[i, 12])='Ano' then mStoreCardBO.SetFieldValueAsBoolean('U_quick_loc_sit',True) else mStoreCardBO.SetFieldValueAsBoolean('U_quick_loc_sit',False);
                    if VarToStr(mSheet.Cells[i, 13])='Stavební' then  mStoreCardBO.SetFieldValueAsInteger('U_urceni',1);
                    if VarToStr(mSheet.Cells[i, 13])='VZV' then  mStoreCardBO.SetFieldValueAsInteger('U_urceni',2);
                    if VarToStr(mSheet.Cells[i, 13])='Zemědělské' then  mStoreCardBO.SetFieldValueAsInteger('U_urceni',3);
                    if not(NxIsBlank(VarToStr(mSheet.Cells[i, 14]))) then
                     mStoreCardBO.SetFieldValueAsString('U_RozmerproCRM',VarToStr(mSheet.Cells[i, 14]));
                    if VarToStr(mSheet.Cells[i, 15])='Ano' then mStoreCardBO.SetFieldValueAsBoolean('U_eshop',True) else mStoreCardBO.SetFieldValueAsBoolean('U_eshop',False);
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
 if index=1 then begin
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
                 mID:=VarToStr(mSheet.Cells[i, 1]);
                 if not(NxIsBlank(mID)) then begin
                  mStoreCard_ID:=mOS.SQLSelectFirstAsString('select id from storecards where hidden='+Quotedstr('N')+' and id='+Quotedstr(mID),'');
                  if not(NxIsEmptyOID(mStoreCard_ID)) then begin

                    mStoreCardBO:=mOS.CreateObject(Class_StoreCard);
                    mStoreCardBO.Load(mstoreCard_ID,nil);
                    if not(NxIsBlank(VarToStr(mSheet.Cells[i, 2]))) then
                     mStoreCardBO.SetFieldValueAsString('U_alternative_rozmer_1',VarToStr(mSheet.Cells[i, 2]));
                    if not(NxIsBlank(VarToStr(mSheet.Cells[i, 3]))) then
                     mStoreCardBO.SetFieldValueAsString('U_alternative_rozmer_2',VarToStr(mSheet.Cells[i, 3]));
                    if not(NxIsBlank(VarToStr(mSheet.Cells[i, 4]))) then
                     mStoreCardBO.SetFieldValueAsString('U_agri_TTTL',VarToStr(mSheet.Cells[i, 4]));
                    if not(NxIsBlank(VarToStr(mSheet.Cells[i, 5]))) then
                     mStoreCardBO.SetFieldValueAsString('U_agri_LISI',VarToStr(mSheet.Cells[i, 5]));
                    if not(NxIsBlank(VarToStr(mSheet.Cells[i, 6]))) then
                     mStoreCardBO.SetFieldValueAsString('U_agri_dezen',VarToStr(mSheet.Cells[i, 6]));
                    if not(NxIsBlank(VarToStr(mSheet.Cells[i, 7]))) then
                     mStoreCardBO.SetFieldValueAsString('U_agri_rafek',VarToStr(mSheet.Cells[i, 7]));
                    if not(NxIsBlank(VarToStr(mSheet.Cells[i, 8]))) then
                     mStoreCardBO.SetFieldValueAsString('U_agri_sirka_mm',VarToStr(mSheet.Cells[i, 8]));
                    if not(NxIsBlank(VarToStr(mSheet.Cells[i, 9]))) then
                     mStoreCardBO.SetFieldValueAsString('U_agri_vnejsi_prumer',VarToStr(mSheet.Cells[i, 9]));
                    if not(NxIsBlank(VarToStr(mSheet.Cells[i, 10]))) then
                     mStoreCardBO.SetFieldValueAsString('U_agri_polomer',VarToStr(mSheet.Cells[i, 10]));
                    if not(NxIsBlank(VarToStr(mSheet.Cells[i, 11]))) then
                     mStoreCardBO.SetFieldValueAsString('U_agri_obvod',VarToStr(mSheet.Cells[i, 11]));
                    if not(NxIsBlank(VarToStr(mSheet.Cells[i, 12]))) then
                     mStoreCardBO.SetFieldValueAsString('U_agri_nosnost_1',VarToStr(mSheet.Cells[i, 12]));
                    if not(NxIsBlank(VarToStr(mSheet.Cells[i, 13]))) then
                     mStoreCardBO.SetFieldValueAsString('U_agri_nosnost_2',VarToStr(mSheet.Cells[i, 13]));
                    if not(NxIsBlank(VarToStr(mSheet.Cells[i, 14]))) then
                     mStoreCardBO.SetFieldValueAsString('U_agri_tlak',VarToStr(mSheet.Cells[i, 14]));
                    if not(NxIsBlank(VarToStr(mSheet.Cells[i, 15]))) then
                     mStoreCardBO.SetFieldValueAsString('U_agri_vyska_dezenu',VarToStr(mSheet.Cells[i, 15]));
                    if not(NxIsBlank(VarToStr(mSheet.Cells[i, 16]))) then
                     mStoreCardBO.SetFieldValueAsString('U_agri_pocet_zubu',VarToStr(mSheet.Cells[i, 16]));
                    if not(NxIsBlank(VarToStr(mSheet.Cells[i, 17]))) then
                     mStoreCardBO.SetFieldValueAsString('U_li',VarToStr(mSheet.Cells[i, 17]));
                  if not(NxIsBlank(VarToStr(mSheet.Cells[i, 18]))) then
                     mStoreCardBO.SetFieldValueAsString('U_si',VarToStr(mSheet.Cells[i, 18]));
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
    except
     mWB.Close;
    end;
   end;
  end;
  if index=2 then begin
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
               mCAI:=VarToStr(mSheet.Cells[i, 1]);
               mPID:=VarToStr(mSheet.Cells[i, 2]);
               mPrice:=NxIBStrToFloat(VarToStr(mSheet.Cells[i, 3]));
               mStoreCard_ID:=mOS.SQLSelectFirstAsString('SELECT a.id FROM StoreCards A WHERE (A.Hidden = ''N'' ) AND '+
                                                         '(exists (SELECT 1 FROM USERDATA WHERE FIELDCODE=2000022 AND CLSID=''C3V5QDVZ5BDL342M01C0CX3FCC'' '+
                                                         ' AND ID = A.ID AND (STRINGFIELDVALUE LIKE '+QuotedStr(mCAI)+' ESCAPE ''~''))) ','');
               if NxIsEmptyOID(mStoreCard_ID) then
                mStoreCard_ID:=mOS.SQLSelectFirstAsString('SELECT a.id FROM StoreCards A WHERE (A.Hidden = ''N'' ) AND '+
                                                         '(exists (SELECT 1 FROM USERDATA WHERE FIELDCODE=2000023 AND CLSID=''C3V5QDVZ5BDL342M01C0CX3FCC'' '+
                                                         ' AND ID = A.ID AND (STRINGFIELDVALUE LIKE '+QuotedStr(mPID)+' ESCAPE ''~''))) ','');
               if not(NxIsEmptyOID(mStoreCard_ID)) then begin
                    mStoreCardBO:=mOS.CreateObject(Class_StoreCard);
                    mStoreCardBO.Load(mstoreCard_ID,nil);
                    if mPrice>0 then mStoreCardBO.SetFieldValueAsFloat('X_Price', mPrice);
                    if mStoreCardBO.NeedSave then mStoreCardBO.Save;
                    mStoreCardBO.Free;
               end;
               Inc(i);
               WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(k));
               WaitWin.StepIt;
          end;
          WaitWin.Stop;
         mWB.Close;
    Except
       WaitWin.Stop;
       mWB.Close;
    end;
   end;
  end;
end;

Procedure ImportKategorieSC(sender:TComponent);
var
 mSite:TSiteForm;
 mOpenDlg: TOpenDialog;
 mOS:TNxCustomObjectSpace;
 mExcel, mWB, mSheet: Variant;
 i,j,k,l: integer;
 mID, mStoreCard_ID:string;
 mStoreCardBO:TNxCustomBusinessObject;
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
                 mID:=VarToStr(mSheet.Cells[i, 1]);
                 //if i=2 then NxShowSimpleMessage('#'+VarToStr(mSheet.Cells[i, 1])+'#',nil);
                 if not(NxIsBlank(mID)) then begin
                  mStoreCard_ID:=mOS.SQLSelectFirstAsString('select id from storecards where hidden='+Quotedstr('N')+' and code='+Quotedstr(mID),'');
                  if not(NxIsEmptyOID(mStoreCard_ID)) then begin
                   //if i=2 then NxShowSimpleMessage(VarToStr(mSheet.Cells[i, 2]),nil);
                    mStoreCardBO:=mOS.CreateObject(Class_StoreCard);
                    mStoreCardBO.Load(mstoreCard_ID,nil);
                    if VarToStr(mSheet.Cells[i, 2])='A' then mStoreCardBO.SetFieldValueAsInteger('U_klasifikace',1);
                    if VarToStr(mSheet.Cells[i, 2])='B' then mStoreCardBO.SetFieldValueAsInteger('U_klasifikace',2);
                    if VarToStr(mSheet.Cells[i, 2])='C' then mStoreCardBO.SetFieldValueAsInteger('U_klasifikace',3);
                    if VarToStr(mSheet.Cells[i, 2])='D' then mStoreCardBO.SetFieldValueAsInteger('U_klasifikace',4);
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