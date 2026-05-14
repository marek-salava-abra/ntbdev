uses '.fce';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mMAction: TMultiAction;
begin
  // Vytorime novou jednoduchou akci
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := '## Import Pohoda ##';
  mAction.Hint := 'Naimportuje skladové karty z Pohody';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportXML;
end;

Procedure ImportXML(sender:TComponent);
var
 mSite:TSiteForm;
 mOpenDlg: TOpenDialog;
 mOS:TNxCustomObjectSpace;
 mXMLWrapper:TNxScriptingXMLWrapper;
 mFileName, mTempFile, mNote, mText:string;
 i:integer;
 mBytes: TBytes;
 mMemory:TMemoryStream;
 mList:TStringList;
begin
  mSite := TComponent(Sender).Site;
  mOS:=msite.BaseObjectSpace;
  mOpenDlg:=TOpenDialog.Create(sender);
  mOpenDlg.Title := 'Import z XML';
  mOpenDlg.Filter := 'Soubory skladových karet z Pohody (*.xml)| *.xml';
  if mOpenDlg.Execute then begin
     mFileName:=mOpenDlg.FileName;
     ImportFile(mOS, mfileName);
  end;
end;

begin
end.