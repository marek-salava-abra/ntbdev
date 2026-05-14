uses 'eu.janek.translator_import.progress', 'eu.janek.translator_import.fce';

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Import  z CSV';
  mAction.Items.Add('Import z CSV');
  mAction.Hint := 'Import z textového souboru';
  mAction.Category := 'tabList';
  mAction.OnExecuteItem := @ImportTXT_OnExecute;
//  mAction.OnUpdate := @ImportTXT_OnUpdate;
end;


procedure ImportTXT_OnExecute(Sender : TComponent; Index : integer);
var
  mSite : TSiteForm;
  mOpenDlg : TOpenDialog;
  mList : TStringList;
  mBO : TNxCustomBusinessObject;
  mOS : TNxCustomObjectSpace;
  i: integer;
begin
  mSite := TComponent(Sender).BusRollSite;
  mOpenDlg := TOpenDialog.Create(Sender);
  try
    if mOpenDlg.Execute then begin
      mList := TStringLIst.Create;
      try
        mList.LoadFromFile(mOpenDlg.FileName);
        //Import_AddRows(ARows : TNxCustomBusinessMonikerCollection; AList : TStringList; ADivision_ID : string; AStore_ID : string)
        mBO := TBusRollSiteForm(mSite).CurrentObject;
        mOS:= mBO.ObjectSpace;
        if Index = 0 then
          ProgressInit(mSite, 'Import translátoru...', mList.count);
          for i := 0 to mList.Count - 1 do begin
           ImportTranslator(mos,mList.Strings[i]);
          ProgressSetPos(i+1);
          end;
          ProgressDispose();
      finally
        mList.Free;
      end;
      NxShowSimpleMessage('Import dokončen.',mSite);
    end else
      NxShowSimpleMessage('Import přerušen.',mSite);
  finally
    mOpenDlg.Free;
  end;
end;

begin
end.