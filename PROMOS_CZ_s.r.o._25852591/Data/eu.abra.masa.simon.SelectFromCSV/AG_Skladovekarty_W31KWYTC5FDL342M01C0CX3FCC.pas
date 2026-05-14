procedure InitSite_Hook(Self: TSiteForm);
var
  mMAction: TMultiAction;
  mAction:TAction;
begin

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actSelCSV';
  mAction.Caption := '##Označit dle CSV##';
  mAction.Hint := 'Označí položky v seznamu dle CSV';
  mAction.Category := 'tabList';
  mAction.OnExecute := @SelectCSV;
end;


Procedure SelectCSV(Sender:TComponent);
var
 mSite:TSiteForm;
 mOpenDlg: TOpenDialog;
 mOS:TNxCustomObjectSpace;
 mExcel, mWB, mSheet: Variant;
 i,j,k,l: integer;
 mCode, mRecord_ID:string;
 mGrid:TDBGrid;
 mActiveDataSet:TNxDataDataSet;
 mList:TStringList;
begin
  mSite := TComponent(Sender).Site;
  mOS:=msite.BaseObjectSpace;
  mOpenDlg:=TOpenDialog.Create(sender);
  mOpenDlg.Title := 'Import z CSV';
  mOpenDlg.Filter := 'Soubory CSV (*.csv)| *.csv';
  if mOpenDlg.Execute then begin
    try
      //mExcel := CreateOleObject('Excel.Application');
      //mWB := mExcel.Workbooks.Open(mOpenDlg.FileName);
      //mSheet := mWB.Sheets[1];
      mList:=TStringList.Create;
      mList.LoadFromFile(mOpenDlg.FileName);
      k:=mList.Count;
          WaitWin.StartProgress('Čekejte, prosím ...', '', k);
              mGrid := TDBGrid(NxFindChildControl(mSite.MainPanel, 'grdList'));
              if not Assigned(mGrid) then begin
                NxShowMessage('info','Nenalezen dbgrid řádků.',mdInformation,false,mSite);
                exit;
              end;
              mActiveDataSet := TNxDataDataSet(mGrid.DataSource.DataSet);
              mActiveDataSet.DisableControls;
              for i:=1 to k-1 do begin
                 mCode:=NxTrapStrTrim(mlist.Strings[i],';');
                 if not(NxIsBlank(mCode)) then begin
                  mRecord_ID:=mOS.SQLSelectFirstAsString('Select id from StoreCards where hidden=''N'' and code='+QuotedStr(mCode),'');
                  if not(NxIsEmptyOID(mRecord_ID)) then mGrid.SelectRows_1(mRecord_ID);
                 end;
               Inc(i);
               WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(k));
               WaitWin.StepIt;
          end;
          mActiveDataSet.EnableControls;
          WaitWin.Stop;
         // mWB.Close;
    finally

    end;
   end;
end;

begin
end.