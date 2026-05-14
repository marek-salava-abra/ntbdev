procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
  mRows:  TNxCustomBusinessMonikerCollection;
  mRowBO, mBO: TNxCustomBusinessObject;
  i: integer;
  mOtherStore: boolean;

begin
 if not(self.GetFieldValueAsString('DocQueue_ID') in ['6RB0000101','6RC0000101','Z200000101']) then begin
  mBO:= Self.ObjectSpace.CreateObject(Class_OutgoingTransfer);
  mBO.Load(Self.OID, nil);
    if mBO.GetFieldValueAsString('PMState_ID')='2000000001' then begin
     if not (osSaving in mBO.InternalState) then mBO.PMChangeState('SDDEF00000');
    end;
  end;
end;

begin
end.