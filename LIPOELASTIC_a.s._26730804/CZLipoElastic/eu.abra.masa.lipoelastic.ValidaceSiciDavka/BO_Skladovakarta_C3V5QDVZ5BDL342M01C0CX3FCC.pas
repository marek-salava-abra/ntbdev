procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mOrig:Extended;
begin
  if CFxNxRuntime.NxGetEnvironmentType=reRuntimeExe then begin
   self.GetOriginalValue_1('X_davka_sici', mOrig);
   if not(mOrig=self.GetFieldValueAsFloat('X_davka_sici')) and (AnsiLeftStr(self.GetFieldValueAsString('X_SynchronizedAtCountries'),1)='1')
    then NxShowSimpleMessage('UPOZORNĚNÍ - zkontrolujte šicí dávku v SK Abře i na příslušných polotovarech (MP)',nil);
  end;
end;

begin
end.