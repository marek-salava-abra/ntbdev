procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
var
  mExe : string;
begin
  if osNew in Self.State then begin
    self.SetFieldValueAsString('X_Porizeni',UpperCase(ExtractFileName(ParamStr(0))));
  end;
end;

begin
end.