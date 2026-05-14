procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImport333';
  mAction.Caption := 'Import MENU';
  mAction.Hint := 'Naimportuje data z XLS';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportData;
end;

Procedure ImportData(sender:TComponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mList:TStringList;
 mBO, mMenuBO, mParamBO:TNxCustomBusinessObject;
 mFirmOffices:TNxCustomBusinessMonikerCollection;
 i,j:integer;
 mOpenDlg:TOpenDialog;
 mExcel, mWB, mSheet: Variant;
 mTempStr, mCode:String;
 mMenuID, mAbraMenuID:string;
begin
  mSite:=TComponent(sender).DynSite;
  mOS:=mSite.BaseObjectSpace;
  mList:=tstringlist.create;
  mOpenDlg := TOpenDialog.Create(Sender);
  mOpenDlg.Title := 'Import z Excelu';
    mOpenDlg.Filter := 'Soubory aplikace Excel (*.xls, *.xlsx)| *.xls;*.xlsx';
    if mOpenDlg.Execute then begin
      try
        j:=0;
        mExcel := CreateOleObject('Excel.Application');
        mWB := mExcel.Workbooks.Open(mOpenDlg.FileName);
        mSheet := mWB.Sheets[1];
         WaitWin.StartProgress('Čekejte, prosím ...', '',  mSheet.UsedRange.Rows.Count);
               i:=2;
                 while i<mSheet.UsedRange.Rows.Count+1 do begin
                  mMenuID:=VarToStr(mSheet.Cells[i, 15]);
                  mAbraMenuID:=mOS.SQLSelectFirstAsString('Select id from storemenu where id='+QuotedStr(mMenuID),'');
                  if not(NxIsEmptyOID(mAbraMenuID)) then begin
                    mCode:=AnsiRightStr('00'+VarToStr(mSheet.Cells[i, 19]),3);
                    mMenuBO:=mOS.CreateObject(Class_StoreMenuItem);
                    mMenuBO.Load(mAbraMenuID,nil);
                    mMenuBO.SetFieldValueAsString('X_ESPicture',VarToStr(mSheet.Cells[i, 17]));
                    mMenuBO.SetFieldValueAsString('X_AES_DESCRIPTION', VarToStr(mSheet.Cells[i, 5]));
                    mMenuBO.SetFieldValueAsString('X_ParamGroup_ID', mOS.SQLSelectFirstAsString('select id from defrolldata where hidden='+QuotedStr('N')+' and clsid='+QuotedStr('OD4JP4GMMNRO5DTOIFTDVCLISC')+' and code='+QuotedStr(mCode),''));
                    if VarToStr(mSheet.Cells[i, 18])='1' then mMenuBO.SetFieldValueAsBoolean('U_uvod',true) else mMenuBO.SetFieldValueAsBoolean('U_uvod',false);
                    mMenuBO.save;
                    mMenuBO.free;
                  end;
                  j:=j+1;
                  WaitWin.ChangeText(IntToStr(i) + ' / ' + IntToStr(msheet.usedrange.rows.Count));
                  WaitWin.StepIt;
                  inc(i);
                 end;
              //mWB.save;
              mWB.Close;
      finally
       WaitWin.Stop;
      end;

     NxShowSimpleMessage('Nahráno '+IntToStr(j)+' objektů.',mSite);
    end;

end;




begin
end.