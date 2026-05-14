uses 'eu.abra.roeh.Logio.Lib',
  'eu.abra.roeh.Logio.AutoServ';

procedure actTesFTP(Self: TAction{TBasicAction});
var
 S : string;
 Str : TStringList;
 OS: TNxCustomObjectSpace;
 mPath : String;
 mSuc :Boolean;
begin
  OS := TSiteForm(Self.Owner).BaseObjectSpace;
//ladeni
   AutoLoadInventoroSubCards (OS,mSuc,S);
  exit;
  //konec laděni

  mPath := GetParamValue(OS,'PATH');
  ShowMessage('Cesta:' + mPath);
  Str := TStringList.Create;
  Try
  Str.Text := 'Pokusný Export';
  Str.SaveToFile(mPath + 'Test.txt');
  if CFxInternet.FTPPutFile(GetParamValue(OS,'FTP_IP'),GetParamValue(OS,'FTP_PORT'),GetParamValue(OS,'FTP_DIR')+'test.txt',mPath + 'Test.txt',GetParamValue(OS,'FTP_USER'),GetParamValue(OS,'FTP_PASS')) then begin
    ShowMessage('Export dat na FTP proběhl');
   DeleteFile(mPath + 'TestExp.txt');
  if CFxInternet.FTPGetFile(GetParamValue(OS,'FTP_IP'),GetParamValue(OS,'FTP_PORT'),GetParamValue(OS,'FTP_DIR')+'test.txt',mPath + 'TestExp.txt',GetParamValue(OS,'FTP_USER'),GetParamValue(OS,'FTP_PASS')) then
    ShowMessage('Import dat z FTP proběhl')
  else ShowMessage('CHYBA: Import dat z FTP neprobehl');
  end else ShowMessage('CHYBA: Export dat na FTP selhal');
  finally
    Str.Free;
  end;
end;

procedure InitSite_Hook(Self: TSiteForm);
var
    mAct: {TBasicAction}TAction;
begin
   CreateInitRecord(Self.BaseObjectSpace);
   if IsSupervisor(Self.BaseObjectSpace) then begin
     mAct:= Self.GetNewAction;
     mAct.Name:= 'actTestFTP';
     mAct.Caption:= 'Test FTP';
     mAct.Category:= 'tabList';
     mAct.OnExecute:= @actTesFTP;
   end;
end;

begin
end.