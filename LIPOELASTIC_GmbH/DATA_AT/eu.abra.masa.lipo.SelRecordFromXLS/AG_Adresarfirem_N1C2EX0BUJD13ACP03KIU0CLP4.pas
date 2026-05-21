procedure InitSite_Hook(Self: TSiteForm);
var
  mMAction: TMultiAction;
  mAction:TAction;
begin

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actSelXLS';
  mAction.Caption := '##Mark according to XLS##';
  mAction.Hint := 'Marking records from XLS, marking by name';
  mAction.Category := 'tabList';
  mAction.OnExecute := @SelectXLS;
end;


Procedure SelectXLS(Sender:TComponent);
var
 mSite:TSiteForm;
 mOpenDlg: TOpenDialog;
 mOS:TNxCustomObjectSpace;
 mExcel, mWB, mSheet: Variant;
 i,j,k,l: integer;
 mCode, mRecord_ID:string;
 mGrid:TDBGrid;
 mActiveDataSet:TNxDataDataSet;
 mDir:string;
begin
  mSite := TComponent(Sender).Site;
  mOS:=msite.BaseObjectSpace;
  mOpenDlg:=TOpenDialog.Create(sender);
  mOpenDlg.Title := 'Data from Excel';
  mOpenDlg.Filter := 'Excel files (*.xls, *.xlsx)| *.xls;*.xlsx';
  if mOpenDlg.Execute then begin
    try
      mExcel := CreateOleObject('Excel.Application');
      mWB := mExcel.Workbooks.Open(mOpenDlg.FileName);
      mSheet := mWB.Sheets[1];
      k:=mSheet.UsedRange.Rows.Count;
       i:=2;
          WaitWin.StartProgress('Please, wait ...', '', k);
              mGrid := TDBGrid(NxFindChildControl(mSite.MainPanel, 'grdList'));
              if not Assigned(mGrid) then begin
                NxShowMessage('info','Nenalezen dbgrid řádků.',mdInformation,false,mSite);
                exit;
              end;
              mActiveDataSet := TNxDataDataSet(mGrid.DataSource.DataSet);
              mActiveDataSet.DisableControls;
               while i<k+1 do begin
                 mCode:=VarToStr(mSheet.Cells[i, 1]);
                 if not(NxIsBlank(mCode)) then begin
                  mRecord_ID:=mOS.SQLSelectFirstAsString('Select id from firms where hidden=''N'' and firm_id is null and name='+QuotedStr(mCode),'');
                  if not(NxIsEmptyOID(mRecord_ID)) then begin
                   //mActiveDataSet.SeekID(mStoreCard_ID);
                   mGrid.SelectRows_1(mRecord_ID);
                  end;
                 end;
               Inc(i);
               WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(k));
               WaitWin.StepIt;
          end;
          mActiveDataSet.EnableControls;
          WaitWin.Stop;
          mWB.Close;
    finally

    end;
   end;
end;

begin
end.