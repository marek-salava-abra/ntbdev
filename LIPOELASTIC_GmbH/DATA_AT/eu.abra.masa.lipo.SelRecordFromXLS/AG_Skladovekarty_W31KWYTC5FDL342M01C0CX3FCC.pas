const
  //cSQL_X_Aktivni = ' AND X_Aktivni = ''A'' ';
  cSQL_X_Aktivni = '';

procedure InitSite_Hook(Self: TSiteForm);
var
  mMAction: TMultiAction;
  mAction:TAction;
begin

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actSelCSV';
  mAction.Caption := '##Mark according to CSV##';
  mAction.Hint := 'Marking records from XLS, marking by code, from first row';
  mAction.Category := 'tabList';
  mAction.OnExecute := @SelectCSV;
end;

Procedure SelectCSV(Sender:TComponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mOpenDlg:TOpenDialog;
 mList:TStringList;
 i:integer;
 mRecord_ID, mDir:string;
 mGrid:TDBGrid;
 mActiveDataSet:TNxDataDataSet;
begin
  mSite := TComponent(Sender).Site;
  mOS:=msite.BaseObjectSpace;
  mDir:=NxEvalObjectExprAsStringDef(msite.GetFakeBusinessObject,'NxGetSpecialFolder(1)','');
  if DirectoryExists(mDir) then mDir:=mDir+'\ABRA_EXPORT\oznaceni';
  mOpenDlg:=TOpenDialog.Create(sender);
  mOpenDlg.Title := 'Import from CSV';
  if DirectoryExists(mDir) then mOpenDlg.InitialDir:=mDir;
  mOpenDlg.Filter := 'Import file (*.csv)| *.csv';
  if mOpenDlg.Execute then begin
     mList:=TStringList.Create;
     mList.LoadFromFile(mOpenDlg.FileName);
     if mList.count>0 then begin
        mGrid := TDBGrid(NxFindChildControl(mSite.MainPanel, 'grdList'));
        if not Assigned(mGrid) then begin
          NxShowMessage('info','Nenalezen dbgrid řádků.',mdInformation,false,mSite);
          exit;
        end;
        mActiveDataSet := TNxDataDataSet(mGrid.DataSource.DataSet);
        mActiveDataSet.DisableControls;
        WaitWin.StartProgress('Please, wait ...', '', mList.Count);
            for i:=0 to mlist.count-1 do begin
              mRecord_ID:=mOS.SQLSelectFirstAsString('Select id from StoreCards where hidden=''N'' '+cSQL_X_Aktivni+' and code='+QuotedStr(mList.strings[i]),'');
              if not(NxIsEmptyOID(mRecord_ID)) then mGrid.SelectRows_1(mRecord_ID);
              WaitWin.ChangeText(IntToStr(1+i) + ' / ' + IntToStr(mList.Count));
              WaitWin.StepIt;
            end;
        mActiveDataSet.EnableControls;
        WaitWin.Stop;
     end;
  end;
end;

begin
end.