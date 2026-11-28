procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := '## Import XLS ##';
  mAction.Hint := 'Vloží řádky z XLS, struktura kód, množství';
  mAction.Category := 'tabDetail';
  mAction.OnExecute := @InsertRows;
end;

Procedure InsertRows(Sender:TComponent);
var
  mSite: TSiteForm;
  mControl: TControl;
  mDataset: TNxRowsObjectDataSet;
  mRow: TNxCustomBusinessObject;
  mQuantity:Extended;
  mStore_ID, mDivision_ID, mStoreCard_ID:string;
  mOpenDlg: TOpenDialog;
  mExcel, mWB, mSheet: Variant;
  i,k:integer;
  mOS:TNxCustomObjectSpace;
  mNotFoundCards: TStringList;
begin
    mSite := TComponent(Sender).DynSite;
    mOS:=TDynSiteForm(mSite).BaseObjectSpace;
    mOpenDlg:=TOpenDialog.Create(sender);
    mOpenDlg.Title := 'Import z Excelu';
    mOpenDlg.Filter := 'Soubory aplikace Excel (*.xls, *.xlsx)| *.xls;*.xlsx';
    if mOpenDlg.Execute then begin
      mStore_ID:='6200000101';
      mDivision_ID:='1000000101';
      if GetInputIDS(mSite, mStore_ID, mDivision_ID) then begin
       if NxIsEmptyOID(mStore_ID) or NxIsEmptyOID(mDivision_ID) then begin
          NxShowSimpleMessage('Nevyplněny údaje, ukončuji.',mSite);
          exit;
       end else begin
        try
          mNotFoundCards:=TStringList.Create;
          mExcel := CreateOleObject('Excel.Application');
          mWB := mExcel.Workbooks.Open(mOpenDlg.FileName);
          mSheet := mWB.Sheets[1];
          mControl:= mSite.FindChildControl('tabRows.grdRows');
          mDataset := TNxRowsObjectDataSet(TMultiGrid(mControl).DataSource.DataSet);
          k:=mSheet.UsedRange.Rows.Count+1;
          if Assigned(mDataset) then  begin
            mDataSet.DisableControls;
            WaitWin.StartProgress('Čekejte, prosím ...', '', k);
            i:=2;
               while i<mSheet.UsedRange.Rows.Count+1 do begin
                mStoreCard_ID:=mOS.SQLSelectFirstAsString('Select id from storecards where hidden=''N'' and code='+QuotedStr(VarToStr(mSheet.Cells[i, 1])),'');
                mQuantity:=NxIBStrToFloat(VarToStr(mSheet.Cells[i, 2]));
                if not(NxIsEmptyOID(mStoreCard_ID)) then begin
                  mRow := mDataSet.CreateBusinessObject;
                  mRow.Prefill;
                  mRow.SetFieldValueAsInteger('RowType',3);
                  mRow.SetFieldValueAsString('Store_Id',mStore_ID);
                  mRow.SetFieldValueAsString('Division_ID',mDivision_ID);
                  mRow.SetFieldValueAsString('Storecard_Id',mStoreCard_ID);
                  mRow.SetFieldValueAsFloat('UnitQuantity', mQuantity);
                end else begin
                  if Trim(VarToStr(mSheet.Cells[i, 1])) <> '' then
                    mNotFoundCards.Add(VarToStr(mSheet.Cells[i, 1]));
                end;
                Inc(i);
                WaitWin.ChangeText(IntToStr(i) + ' / ' + IntToStr(k));
                WaitWin.StepIt;
               end;
            WaitWin.stop;
          end;
        finally
          if not VarIsEmpty(mWB) and not VarIsClear(mWB) then begin
            mWB.Close(False); // False = uložit změny? Ne, soubor jen čteme
          end;
          if not VarIsEmpty(mExcel) and not VarIsClear(mExcel) then begin
            mExcel.Quit;
          end;
          TDynSiteForm(mSite).ActiveDataSet.UpdateFields; //Aby se o změně dozvěděl hlavičkový dataset
          mDataset.RefreshAndRestoreLastSelectedItem;
          mDataSet.EnableControls;
          if mNotFoundCards.Count > 0 then begin
            NxShowSimpleMessage('Import dokončen, ale následující kódy skladových karet nebyly v systému nalezeny a nebyly importovány:'+nxCrLf +
                                mNotFoundCards.Text, mSite);
          end;
          mNotFoundCards.Free;
        end;
       end;
      end;
    end;
end;

Function GetInputIDS(var ASite : TSiteform; var aStore_ID, aDivision_ID:String):Boolean;
var
    mLabel, mCBCCStore, mCBCCDivision: TLabel;
    mAllowed:TStringList;
    mButOk, mButCancel : TButton;
    mResult, mCount : integer;
    mForm : TForm;
    mCBStores, mCBDivisions:TRollComboEdit;
    mED:TEdit;
 begin
 if ASite <> nil then begin
    Result:=False;
    mCount:=0;
    mForm:= TForm.Create(ASite);
    mForm.Width:= 510;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Info:';
    mForm.OnCloseQuery:= @OnFormCloseAction;


    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Sklad:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mCBCCStore:= TLabel.Create(mForm);
    mCBCCStore.Parent:= mForm;
    mCBCCStore.Left:= 236;
    mCBCCStore.Top:= (mCount*25)+12;
    mCBCCStore.Width:= 255;

    mCBStores:= TRollComboEdit.Create(mForm);
    mCBStores.Parent:= mForm;
    mCBStores.ClassID:= Roll_Stores;
    mCBStores.Complete:= True;
    mCBStores.Prefilling:= pmNone;
    mCBStores.TextField:= 'Code';  // položka podle které se bude vyhledávat
    mCBStores.Top:= (mCount*25)+10;
    mCBStores.Left:= 140;
    mCBStores.Width:= 80;
    mCBStores.Parameters.Clear;
    mCBStores.ConnectedControl:= mCBCCStore;
    mCBStores.ConnectedControlField:= 'Name';
    mCBStores.DataText:=aStore_ID;
    if not NxIsEmptyOID(aStore_ID) then mCBStores.Refresh;


    mCount:= mCount+1;

    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Středisko:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mCBCCDivision:= TLabel.Create(mForm);
    mCBCCDivision.Parent:= mForm;
    mCBCCDivision.Left:= 236;
    mCBCCDivision.Top:= (mCount*25)+12;
    mCBCCDivision.Width:= 255;

    mCBDivisions:= TRollComboEdit.Create(mForm);
    mCBDivisions.Parent:= mForm;
    mCBDivisions.ClassID:= Roll_Divisions;
    mCBDivisions.Complete:= True;
    mCBDivisions.Prefilling:= pmNone;
    mCBDivisions.TextField:= 'Code';  // položka podle které se bude vyhledávat
    mCBDivisions.Top:= (mCount*25)+10;
    mCBDivisions.Left:= 140;
    mCBDivisions.Width:= 80;
    mCBDivisions.Parameters.Clear;
    mCBDivisions.ConnectedControl:= mCBCCDivision;
    mCBDivisions.ConnectedControlField:= 'Name';
    mCBDivisions.DataText:=aDivision_ID;
    if not NxIsEmptyOID(aStore_ID) then mCBStores.Refresh;


    mCount:= mCount+1;

    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Default:= true;
    mButOk.Caption := 'OK';
    mButOk.Top := (mCount*25)+20;
    mButOk.Left := 252;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Zrušit';
    mButCancel.Top := (mCount*25)+20;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;
    mForm.Height:= (mCount*25)+95;

    mResult := mForm.ShowModal(ASite);
    if mResult = 1 then begin
         aStore_ID:=mCBStores.DataText;
         aDivision_ID:=mCBDivisions.DataText;
         Result:=True;
     end;
    mAllowed.free;
    mForm.free;
  end;
end;

procedure OnFormCloseAction(Sender: TObject; var Action: TCloseAction);
begin
  if Action = caHide then TForm(Sender).ModalResult := mrCancel;
end;


begin
end.