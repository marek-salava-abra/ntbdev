procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mMAction: TMultiAction;
begin
  // Vytorime novou jednoduchou akci
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := '## Přidání XLS ##';
  mAction.Hint := 'Přidání řádků z excelu';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportXLS;
end;

Procedure ImportXLS(sender:TComponent);
var
 mSite:TSiteForm;
 mOpenDlg: TOpenDialog;
 mOS:TNxCustomObjectSpace;
 mExcel, mWB, mSheet: Variant;
 i,j,k,l: integer;
 mID, mWorker_ID, mWLWorklog_ID:string;
 mWorkLogBO:TNxCustomBusinessObject;
 mDate, mBeginDate, mEndDate:Extended;
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
                 if not(NxIsBlank(mID)) then begin
                  mWorker_ID:=mOS.SQLSelectFirstAsString('select id from WLWorkers where hidden='+Quotedstr('N')+' and ExternalID='+Quotedstr(mID),'');
                  if not(NxIsEmptyOID(mWorker_ID)) then begin
                    mDate:=StrToDate(VarToStr(mSheet.Cells[i, 7]));
                    mBeginDate:=mDate+NxIBStrToFloat(VarToStr(mSheet.Cells[i, 8]));
                    mEndDate:=mDate+NxIBStrToFloat(VarToStr(mSheet.Cells[i, 9]));
                    mWLWorklog_ID:=mOS.SQLSelectFirstAsString('Select id from wlworklogs where worker_id='+QuotedStr(mWorker_ID)+' and BeginDate$DATE>='+NxFloatToIBStr(mdate)+' and BeginDate$DATE<'+NxFloatToIBStr(mdate+1),'');
                    if NxIsEmptyOID(mWLWorklog_ID) then begin
                      mWorkLogBO:=mOS.CreateObject(Class_WLWorkLog);
                      mWorkLogBO.New;
                      mWorkLogBO.Prefill;
                      mWorkLogBO.SetFieldValueAsString('Worker_ID',mWorker_ID);
                      mWorkLogBO.SetFieldValueAsString('EntryType_ID','1000000000');
                      mWorkLogBO.SetFieldValueAsDateTime('BeginDate$Date',mBeginDate);
                      mWorkLogBO.SetFieldValueAsDateTime('EndDate$Date',mEndDate);
                      mWorkLogBO.save;
                      mWorkLogBO.free;
                    end;
                    if not(NxIsEmptyOID(mWLWorklog_ID)) then begin
                      mWorkLogBO:=mOS.CreateObject(Class_WLWorkLog);
                      mWorkLogBO.Load(mWLWorklog_ID);
                      mWorkLogBO.SetFieldValueAsDateTime('BeginDate$Date',mBeginDate);
                      mWorkLogBO.SetFieldValueAsDateTime('EndDate$Date',mEndDate);
                      mWorkLogBO.save;
                      mWorkLogBO.free;
                    end;
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