
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
  mRows:  TNxCustomBusinessMonikerCollection;
  mRowBO, mBO: TNxCustomBusinessObject;
  i: integer;
  mOtherStore: boolean;

begin
 if not(NxGetActualUserID_1(self) in ['1730000101','SUPER00000']) then begin
  mBO:= Self.ObjectSpace.CreateObject(Class_IncomingTransfer);
  mBO.Load(Self.OID, nil);
    if mBO.GetFieldValueAsString('PMState_ID')='2000000001' then begin
     if not (osSaving in mBO.InternalState) then mBO.PMChangeState('SDDEF00000');
    end;
  end;
end;

begin
end.