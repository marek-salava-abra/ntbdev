procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImportEAN';
  mAction.Caption := 'Import EAN';
  mAction.Hint := 'Naimportuje EAN z XLS (pozor jen z prvního listu)';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportData;
end;

Procedure ImportData(sender:TComponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mList:TStringList;
 mBO, mUnitBO:TNxCustomBusinessObject;
 mUnits:TNxCustomBusinessMonikerCollection;
 i,j,k,l,m,n,o:integer;
 mOpenDlg:TOpenDialog;
 mExcel, mWB, mSheet: Variant;
 mEAN, mCode, mCode2, mCode3, mCode4:String;
 mParent_ID:string;
begin
  mSite:=TComponent(sender).BusRollSite;
  mOS:=mSite.BaseObjectSpace;
  //GetData(msite, k,l,m);
  if True then begin
    mOpenDlg := TOpenDialog.Create(Sender);
    mOpenDlg.Title := 'Import z Excelu';
      mOpenDlg.Filter := 'Soubory aplikace Excel (*.xls, *.xlsx)| *.xls;*.xlsx';
      if mOpenDlg.Execute then begin
        try
          j:=0;
          mExcel := CreateOleObject('Excel.Application');
          mWB := mExcel.Workbooks.Open(mOpenDlg.FileName);
          mSheet := mWB.Sheets[1];
          n:=mSheet.UsedRange.Rows.Count;
           WaitWin.StartProgress('Čekejte, prosím ...', '',  n);
                 i:=2;          //doopravdy druhý řádek XLS
                   while i<n+1 do begin
                    mCode:=AnsiLeftStr(VarToStr(mSheet.Cells[i, 1]),30);
                    mCode2:=AnsiLeftStr(VarToStr(mSheet.Cells[i, 2]),30);
                    mCode3:=AnsiLeftStr(VarToStr(mSheet.Cells[i, 3]),30);
                    mCode4:=AnsiLeftStr(VarToStr(mSheet.Cells[i, 4]),30);
                    If not(nxisblank(mcode)) and NxIsBlank(mCode2) and NxIsBlank(mCode3) and NxIsBlank(mCode4) then begin
                      mBO:=mOS.CreateObject(Class_StoreMenuItem);
                      mbo.New;
                      mBO.prefill;
                      mbo.SetFieldValueAsString('Text',mCode);
                      mbo.save;
                      mbo.free;
                    end;
                    If not(nxisblank(mcode)) and not(NxIsBlank(mCode2)) and NxIsBlank(mCode3) and NxIsBlank(mCode4) then begin
                      mBO:=mOS.CreateObject(Class_StoreMenuItem);
                      mbo.New;
                      mBO.prefill;
                      mbo.SetFieldValueAsString('Text',mCode2);
                      mbo.SetFieldValueAsString('Parent_id',mos.SQLSelectFirstAsString('Select id from storemenu where text='+QuotedStr(mcode)+' and hidden='+QuotedStr('N'),''));
                      mbo.save;
                      mbo.free;
                    end;
                    If not(nxisblank(mcode)) and not(NxIsBlank(mCode2)) and not(NxIsBlank(mCode3)) and NxIsBlank(mCode4) then begin
                      mBO:=mOS.CreateObject(Class_StoreMenuItem);
                      mbo.New;
                      mBO.prefill;
                      mbo.SetFieldValueAsString('Text',mCode3);
                      mbo.SetFieldValueAsString('Parent_id',mos.SQLSelectFirstAsString('Select id from storemenu where text='+QuotedStr(mcode2)+' and hidden='+QuotedStr('N'),''));
                      mbo.save;
                      mbo.free;
                    end;
                    If not(nxisblank(mcode)) and not(NxIsBlank(mCode2)) and not(NxIsBlank(mCode3)) and not(NxIsBlank(mCode4)) then begin
                      mBO:=mOS.CreateObject(Class_StoreMenuItem);
                      mbo.New;
                      mBO.prefill;
                      mbo.SetFieldValueAsString('Text',mCode4);
                      mbo.SetFieldValueAsString('Parent_id',mos.SQLSelectFirstAsString('Select id from storemenu where text='+QuotedStr(mcode3)+' and hidden='+QuotedStr('N'),''));
                      mbo.save;
                      mbo.free;
                    end;
                    j:=j+1;
                    WaitWin.ChangeText(IntToStr(i) + ' / ' + IntToStr(n));
                    WaitWin.StepIt;
                    inc(i);
                   end;
                //mWB.save;
                mWB.Close;
        finally
         WaitWin.Stop;
        end;

       NxShowSimpleMessage('Nahráno '+IntToStr(j)+' objektů z celkového počtu '+IntToStr(n)+'.',mSite);
      end;
  end;
end;

Function GetData(var ASite : TSiteform; var aCode, aEAN, aResult:integer;):Boolean;
var
    mLabel: TLabel;
    mNumEd1, mNumEd2:TNumEdit;
    mButOk, mButCancel : TButton;
    mResult : integer;
    mForm : TForm;

begin
 Result:=false;
 if ASite <> nil then begin
    Result:=False;
    mForm:= TForm.Create(ASite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Left:= 300;
    mForm.Top:= 300;
    mForm.Width:= 300;
    mForm.Height:= 140;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Výchozí sloupce pro import:';



    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Kód:';
    mLabel.Top := 10;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mNumEd1 := TNumEdit.Create(mForm);
    mNumEd1.Left := 80;
    mNumEd1.Top := 10;
    mNumEd1.Width := 80;
    mNumEd1.Value := aCode;
    mNumEd1.DecimalPlaces:= 0;
    mNumEd1.Parent := mForm;

    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'EAN:';
    mLabel.Top := 35;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mNumEd2 := TNumEdit.Create(mForm);
    mNumEd2.Left := 80;
    mNumEd2.Top := 35;
    mNumEd2.Width := 80;
    mNumEd2.Value := aCode;
    mNumEd2.DecimalPlaces:= 0;
    mNumEd2.Parent := mForm;

    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'OK';
    mButOk.Top := 75;
    mButOk.Left := 52;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Zrušit';
    mButCancel.Top := 75;
    mButCancel.Left := 120;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;


    mResult := mForm.ShowModal(ASite);
    if mResult = 1 then begin
         aResult:=1;
         aCode :=trunc(mNumEd1.value);
         aEAN  :=trunc(mNumEd2.value);
         Result:=true;
    end;
    mForm.free;
  end;
end;




begin
end.