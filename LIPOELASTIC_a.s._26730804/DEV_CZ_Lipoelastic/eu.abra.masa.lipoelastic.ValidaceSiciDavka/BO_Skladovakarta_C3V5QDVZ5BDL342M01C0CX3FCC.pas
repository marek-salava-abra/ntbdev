{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mOrig:Extended;
begin
  self.GetOriginalValue_1('X_davka_sici', mOrig);
  if not(mOrig=self.GetFieldValueAsFloat('X_davka_sici')) and (AnsiLeftStr(self.GetFieldValueAsString('X_SynchronizedAtCountries'),1)='1')
   then NxShowSimpleMessage('upozornění na potřebu změny karty v SK databázi a i změnu na příslušné MP kartě',nil);
end;

begin
end.