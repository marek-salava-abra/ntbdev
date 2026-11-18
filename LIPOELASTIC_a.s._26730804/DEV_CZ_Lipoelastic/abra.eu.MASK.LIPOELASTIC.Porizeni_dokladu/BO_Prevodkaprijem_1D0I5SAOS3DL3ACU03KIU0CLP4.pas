procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
var
  mExe : string;
begin
  if osNew in Self.State then begin
    self.SetFieldValueAsString('X_Porizeni',UpperCase(ExtractFileName(ParamStr(0))));
     if self.getFieldValueAsString('X_Porizeni')='WSSERVERKERNEL.EXE'  then begin
        //self.setFieldValueAsString('DocQueue_ID',self.GetFieldValueAsString
    end;
  end;
end;

begin
end.