procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  // Vytorime novou jednoduchou akci
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := '@@Oprava HL.D./DOD.T./MQ z XLS';
  mAction.Hint := 'Přidání hlavního dodavatele, dodací doby a minimálního množství MQ z XLS souboru';
  mAction.Category := 'tabList';
  mAction.OnExecute := @UpdateSupplier;

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := '@@Oprava spod.limitu z XLS';
  mAction.Hint := 'import spodního limitu z XLS';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportLowLimitXLS;
end;

Procedure ImportLowLimitXLS (Sender:TComponent);
var
 mSite:TSiteForm;
 mOpenDlg:TOpenDialog;
 mOS:TNxCustomObjectSpace;
 mExcel, mWB, mSheet: Variant;
 i,j:integer;
 mStoreCard_ID, mStoreCode, mStore_ID, mStoreSubCard_ID:string;
 mSSCBO:TNxCustomBusinessObject;
begin
  mSite := TComponent(Sender).BusRollSite;
  mOS:=msite.BaseObjectSpace;
  mOpenDlg:=TOpenDialog.Create(sender);
  mOpenDlg.Title := 'Import z Excelu';
  mOpenDlg.Filter := 'Soubory aplikace Excel (*.xls, *.xlsx)| *.xls;*.xlsx';
    if mOpenDlg.Execute then begin
      try

        mExcel := CreateOleObject('Excel.Application');
        mWB := mExcel.Workbooks.Open(mOpenDlg.FileName);
        mSheet := mWB.Sheets[1];
        i:=2;
        j:=mSheet.UsedRange.Rows.Count;
        WaitWin.StartProgress('Čekejte, prosím ...', '',j);
        while i<mSheet.UsedRange.Rows.Count+1 do begin
                mStoreCard_ID:=mOS.SQLSelectFirstAsString('Select id from storecards where hidden='+Quotedstr('N')+' and code='+QuotedStr(VarToStr(mSheet.Cells[i, 2])),'');
                mStore_ID:=mOS.SQLSelectFirstAsString('Select id from stores where hidden='+Quotedstr('N')+' and code='+QuotedStr(VarToStr(mSheet.Cells[i, 1])),'');
                mStoreSubCard_ID:=mOS.SQLSelectFirstAsString('Select id from storesubcards where storecard_id='+Quotedstr(mStoreCard_ID)+' and store_id='+QuotedStr(mStore_ID),'');
                if not(NxIsEmptyOID(mStoreSubCard_ID)) and (NxIBStrToFloat(VarToStr(mSheet.Cells[i, 3]))>0) then begin
                  mSSCBO:=mOS.CreateObject(Class_StoreSubCard);
                  mSSCBO.Load(mStoreSubCard_ID,nil);
                  mSSCBO.SetFieldValueAsFloat('LowLimitQuantity',NxRoundByValue(NxIBStrToFloat(VarToStr(mSheet.Cells[i, 3])),ctArithmetic,1));
                  mSSCBO.save;
                  msscbo.free;
                end;
                inc(i);
                WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(j));
                WaitWin.StepIt;
        end;
        WaitWin.Stop;
        mWB.Close;
      finally

      end;
    end;
end;

Procedure UpdateSupplier (Sender:TComponent);
var
 mSite:TSiteForm;
 mOpenDlg:TOpenDialog;
 mOS:TNxCustomObjectSpace;
 mExcel, mWB, mSheet: Variant;
 i,j:integer;
 mStoreCard_ID, mStoreCode, mSupplier_ID, mFirm_ID:string;
 mSCBO, mSupplierBO:TNxCustomBusinessObject;
begin
  mSite := TComponent(Sender).BusRollSite;
  mOS:=msite.BaseObjectSpace;
  mOpenDlg:=TOpenDialog.Create(sender);
  mOpenDlg.Title := 'Import z Excelu';
  mOpenDlg.Filter := 'Soubory aplikace Excel (*.xls, *.xlsx)| *.xls;*.xlsx';
    if mOpenDlg.Execute then begin
      try

        mExcel := CreateOleObject('Excel.Application');
        mWB := mExcel.Workbooks.Open(mOpenDlg.FileName);
        mSheet := mWB.Sheets[1];
        i:=2;
        j:=mSheet.UsedRange.Rows.Count;
        WaitWin.StartProgress('Čekejte, prosím ...', '',j);
        while i<mSheet.UsedRange.Rows.Count+1 do begin
                mStoreCard_ID:=mOS.SQLSelectFirstAsString('Select id from storecards where hidden='+Quotedstr('N')+' and code='+QuotedStr(VarToStr(mSheet.Cells[i, 1])));
                if not(NxIsEmptyOID(mStoreCard_ID)) then begin
                  //NxShowSimpleMessage(mStoreCard_ID,nil);
                  mFirm_ID:='';
                  if not(NxIsBlank(VarToStr(mSheet.Cells[i, 2]))) then
                   mFirm_ID:=mOS.SQLSelectFirstAsString('Select id from firms where orgidentnumber='+QuotedStr(VarToStr(mSheet.Cells[i, 2]))+' and firm_id is null and hidden='+Quotedstr('N'),'');
                  if NxIsEmptyOID(mFirm_ID) then mFirm_ID:=mOS.SQLSelectFirstAsString('Select id from firms where vatidentnumber='+QuotedStr(VarToStr(mSheet.Cells[i, 2]))+' and firm_id is null and hidden='+Quotedstr('N'),'');
                  if not(NxIsEmptyOID(mFirm_ID)) then begin
                  //if not(NxIsEmptyOID(mFirm_ID)) and (NxIBStrToFloat(VarToStr(mSheet.Cells[i, 3]))>0) then begin //neimportovalo když nebyl sloupec C 24.8.2023
                     mSCBO:=mOS.CreateObject(Class_StoreCard);
                     mSCBO.Load(mStoreCard_ID,nil);
                     mSupplier_ID:=mOS.SQLSelectFirstAsString('Select id from suppliers where firm_id='+QuotedStr(mFirm_ID)+' and storecard_id='+Quotedstr(mStoreCard_ID),'');
                     mSupplierBO:=mOS.CreateObject(Class_Supplier);
                     if NxIsEmptyOID(mSupplier_ID) then begin
                       mSupplierBO.new;
                       mSupplierBO.Prefill;
                       mSupplierBO.SetFieldValueAsString('Firm_ID',mFirm_ID);
                       mSupplierBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
                       mSupplierBO.SetFieldValueAsString('Qunit',mSupplierBO.GetFieldValueAsString('StoreCard_ID.MainUnitCode'));
                     end else begin
                       mSupplierBO.Load(mSupplier_ID,nil);
                     end;
                     if (NxIBStrToFloat(VarToStr(mSheet.Cells[i, 3]))>0) then
                      mSupplierBO.SetFieldValueAsFloat('DeliveryTime',NxIBStrToFloat(VarToStr(mSheet.Cells[i, 3])));
                     if (NxIBStrToFloat(VarToStr(mSheet.Cells[i, 4]))>0) then
                      mSupplierBO.SetFieldValueAsFloat('MinimalQuantity',NxIBStrToFloat(VarToStr(mSheet.Cells[i, 4])));
                     mSupplierBO.Save;
                     mSCBO.SetFieldValueAsString('MainSupplier_ID',mSupplierBO.OID);
                     mscbo.save;
                     mSupplierBO.free;
                     mSCBO.free;
                  end;
                end;
                inc(i);
                WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(j));
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