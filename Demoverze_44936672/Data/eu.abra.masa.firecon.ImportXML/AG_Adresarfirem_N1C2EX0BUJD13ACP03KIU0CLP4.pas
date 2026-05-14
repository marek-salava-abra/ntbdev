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
  mAction.Caption := '## Přidání XML ##';
  mAction.Hint := 'Otevře soubor z Aluprofu';
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
  mOpenDlg.Filter := 'Soubory výkresů (*.xml)| *.xml';
  if mOpenDlg.Execute then begin
     mFileName:=mOpenDlg.FileName;
     mList:=TStringList.Create;
     mList.LoadFromFile(mFileName);
     mList.Strings[0]:='<?xml version="1.0" encoding="windows-1250"?>';
     if mList.Strings[1]='<!DOCTYPE logiObj SYSTEM "logiObj.dtd" []>' then mlist.Strings[1]:='';
     mList.SaveToFile(mFileName);
     mXMLWrapper:=TNxScriptingXMLWrapper.Create;
     mXMLWrapper.loadFromFile(mFileName);
     for i:=0 to mXMLWrapper.getElementsCountInArray('Position')-1 do begin
       mNote:='';
       if ElementExists(mXMLWrapper,'Position['+IntToStr(i)+'].Description')
         then mXMLWrapper.getAttributeValue('Position['+IntToStr(i)+'].Description','Text');
       NxShowSimpleMessage('Řádek: '+IntToStr(i)+nxCrLf+mNote+NxCrLf+mXMLWrapper.getAttributeValue('Position['+IntToStr(i)+']','Name'),mSite)
     end;
  end;
end;

function ISO8859_1ToString(mMemory: TMemoryStream): string;
var
  i: LongInt;
  ch: Char;
begin
  SetLength(Result, mMemory.Size);
  mMemory.Position := 0;
  for i := 1 to mMemory.Size do
  begin
    mMemory.ReadBuffer(ch, 1);
    Result[i] := ch; // 1:1 převod ISO-8859-1 → znak
  end;
end;

begin
end.