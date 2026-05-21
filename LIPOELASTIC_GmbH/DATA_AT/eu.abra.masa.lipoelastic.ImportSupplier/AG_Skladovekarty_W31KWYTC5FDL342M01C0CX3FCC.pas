procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImportXLSSuplier';
  mAction.Caption := 'Bank Statement XLS';
  mAction.Hint := 'Import data from XLS file';
  mAction.Category := 'tabDetail';
  mAction.OnExecute := @ImportDataXLS;
end;

Procedure ImportDataXLS(Sender:TComponent);
Var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 i,j:integer;
 mOpenDlg:TOpenDialog;
 mBO:TNxCustomBusinessObject;
 mExcel, mWB, mSheet: Variant;
 mStoreCard_ID, mQunit:string;
begin
  mSite:=TComponent(sender).BusRollSite;
  mOS:=mSite.BaseObjectSpace;
  mOpenDlg := TOpenDialog.Create(Sender);
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
            mStoreCard_ID:=mOS.SQLSelectFirstAsString('Select id from storecards where code='+QuotedStr(VarToStr(mSheet.Cells[i,1])),'');
            if not(NxIsEmptyOID(mStoreCard_ID)) then begin
              mQunit:=mOS.SQLSelectFirstAsString('Select mainunitcode from storecards where id='+QuotedStr(mStoreCard_ID),'');
              mBO:=mOS.CreateObject(Class_Supplier);
              mBO.new;
              mbo.prefill;
              mbo.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
              mBO.SetFieldValueAsString('Firm_ID','~0000005LQ');
              mBO.SetFieldValueAsFloat('PurchasePrice', NxIBStrToFloat(VarToStr(mSheet.cells[i,8])));
              mBO.SetFieldValueAsString('QUnit',mQunit);
              mbo.SetFieldValueAsInteger('DeliveryTime',7);
              mBO.SetFieldValueAsFloat('MinimalQuantity',1);
              mbo.save;
              mbo.free;
            end;
           Inc(i);
           WaitWin.StepIt;
          end;
         WaitWin.Stop;
         mWB.close;

      except
        NxShowSimpleMessage(ExceptionMessage,mSite);
        mWB.close;
        WaitWin.Stop;
      end;
  end;
end;

begin
end.