procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
  mRows:  TNxCustomBusinessMonikerCollection;
  mRowBO, mBO: TNxCustomBusinessObject;
  i: integer;
  mOtherStore: boolean;

begin
 if not(self.GetFieldValueAsString('DocQueue_ID') in ['7RB0000101','7RC0000101','X200000101']) then begin
  mBO:= Self.ObjectSpace.CreateObject(Class_IncomingTransfer);
  mBO.Load(Self.OID, nil);
    if mBO.GetFieldValueAsString('PMState_ID')='1000000001' then begin
     if not (osSaving in mBO.InternalState) then mBO.PMChangeState('SDDEF00000');
    end;
  end;

  if self.GetFieldValueAsString('DocQueue_ID') in ['7RC0000101'] then begin
  mBO:= Self.ObjectSpace.CreateObject(Class_IncomingTransfer);
  mBO.Load(Self.OID, nil);
    if mBO.GetFieldValueAsString('PMState_ID')='1000000001' then begin
     if not (osSaving in mBO.InternalState) then mBO.PMChangeState('2000000001');
    end;
  end;
end;

begin
end.