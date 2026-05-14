{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
var
 mOrigin:string;
begin
 mOrigin:='OTH';
 if CFxNxRuntime.NxGetEnvironmentType=reOLEAutomation then mOrigin:='OLE';
 if CFxNxRuntime.NxGetEnvironmentType=reRuntimeExe then mOrigin:='GEN';
 if CFxNxRuntime.NxGetEnvironmentType=reDebugger then mOrigin:='DEB';
 if CFxNxRuntime.NxGetEnvironmentType=reShell then mOrigin:='SHL';
 if CFxNxRuntime.NxGetEnvironmentType=reDelphi then mOrigin:='DPH';
 //if CFxNxRuntime.NxGetEnvironmentType=reWeb then mOrigin:='API';
 if CFxNxRuntime.NxGetEnvironmentType=reWebServices then mOrigin:='WSS';
 //if CFxNxRuntime.NxGetEnvironmentType=reTo then mOrigin:='DLL';
 if CFxNxRuntime.NxGetEnvironmentType=reToolExe then mOrigin:='EXE';
 if CFxNxRuntime.NxGetEnvironmentType=reAutoServer then mOrigin:='AUT';
 if NxIsBlank(self.GetFieldValueAsString('X_ComputerName')) then
   self.SetFieldValueAsString('X_ComputerName',mOrigin+' '+GetEnvironmentVariable('ComputerName'));
end;

begin
end.