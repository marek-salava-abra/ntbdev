procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin


  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actCheckInv';
  mAction.Caption := '## Check Invoices from XLS ##';
  mAction.Hint := 'data from XLS';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportDataXLS;
end;

Procedure ImportDataXLS(Sender:TComponent);
var
 mSite:TSiteForm;
 mOpenDlg: TOpenDialog;
 mOS:TNxCustomObjectSpace;
 i,j:integer;
 mExcel, mWB, mSheet: Variant;
 mVoucherCode,mFirmCode, mSalesRep, mVoucher_ID, mFirm_ID, mSales_ID:string;
 mVoucherBO, mFirmBO, mbusTransactionBO:TNxCustomBusinessObject;
begin
 mSite:=TComponent(Sender).DynSite;
 mOS:=mSite.BaseObjectSpace;
 mOpenDlg:=TOpenDialog.Create(sender);
 mOpenDlg.Title := 'Import XLS';
 mOpenDlg.Filter := 'Excel files (*.xls, *.xlsx)| *.xls;*.xlsx';
 if mOpenDlg.Execute then begin
  try
          mExcel := CreateOleObject('Excel.Application');
          mWB := mExcel.Workbooks.Open(mOpenDlg.FileName);
          mSheet := mWB.Sheets[1];
          i:=2;
          j:=mSheet.UsedRange.Rows.Count+1;
          WaitWin.StartProgress('Please, wait ...', '', j);
          while i<j  do begin
            WaitWin.ChangeText(IntToStr(i) + ' / ' + IntToStr(j));
            mFirmCode:=mOS.SQLSelectFirstAsString('Select f.code from issuedinvoices ii left join firms f on f.id=ii.firm_id where ii.varsymbol='+QuotedStr(mSheet.Cells[i, 1])+
                                                  ' and ii.amount='+NxFloatToIBStr(NxIBStrToFloat(mSheet.Cells[i, 4])),'');
            mSheet.Cells[i, 6]:=mFirmCode;
            inc(i);
            WaitWin.StepIt;
          end;
         WaitWin.Stop;
         mWB.save;
         mWB.close;

     except
      WaitWin.Stop;
      mWB.close;
      NxShowSimpleMessage(ExceptionMessage,msite);
  end;
 end;
end;

begin
end.