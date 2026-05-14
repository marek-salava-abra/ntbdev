////////////////////////////////////////////////////////////////////////////////

{
// automatické provedení dokladu - nakone vypnuto
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
  mOLEApp: GetAbraOLEApplication;
  doLogStoreOutput: Variant;
begin
  mOLEApp := GetAbraOLEApplication;
  doLogStoreOutput := mOLEApp.CreateObject(Class_LogStoreOutput);
  doLogStoreOutput.MakeExecuted(Self.OID);
end;
}

////////////////////////////////////////////////////////////////////////////////

begin
end.