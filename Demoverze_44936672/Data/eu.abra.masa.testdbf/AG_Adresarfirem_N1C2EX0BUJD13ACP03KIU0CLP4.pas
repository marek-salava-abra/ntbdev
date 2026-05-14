procedure FormCreate_Hook(Self: TSiteForm);
var
  mAct: TBasicAction;
begin
  mAct := Self.GetNewAction;
  mAct.Caption := 'Import DBF';
  mAct.Category := 'tabList';
  mAct.OnExecute := @ImportDBF;
end;

procedure ImportDBF(Sender: TBasicAction);
var
  mSite: TSiteForm;
  mListIDs: TStringList;
  mRes: String;
  mExcel: Variant;
  mOpenDialog: TOpenDialog;
  mLine: String;
  mBO:TNxCustomBusinessObject;
  mDBF:TDbf;
  i:Integer;
begin
  mSite := TComponent(Sender).BusRollSite;
  if Assigned(mSite) then begin
    mOpenDialog := TOpenDialog.Create(mSite);
    try
      mOpenDialog.Filter := 'Soubor s daty (*.dbf)|*.dbf';
      mOpenDialog.FileName := '';
      if mOpenDialog.Execute then begin
        mDBF := TDBF.Create(nil);
        mDBF.TableName:=mOpenDialog.FileName;
        mDBF.Open;
        mDBF.First;
          while not mDBF.Eof do begin
            NxShowSimpleMessage('Kód položky '+mDBF.FieldByName('TOW_KOD').AsString+'   cena:'+FloatToStr(mDBF.FieldByName('CE_SP_RAB').AsFloat),mSite);
            mDBF.Next;
          end;
      end;
    finally
    end;
  end;
end;


begin
end.