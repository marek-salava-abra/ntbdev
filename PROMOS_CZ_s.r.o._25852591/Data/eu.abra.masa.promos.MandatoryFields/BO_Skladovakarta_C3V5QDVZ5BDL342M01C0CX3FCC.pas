{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}

procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
var
 mMessage:string;
begin
  if CFxNxRuntime.NxGetEnvironmentType=reRuntimeExe then begin
    mMessage:='';
    if NxIsEmptyOID(self.GetFieldValueAsString('StoreMenuItem_ID')) then mMessage:=mMessage+nxCrLf+'Není vyplněno skladové menu';
    if NxIsEmptyOID(self.GetFieldValueAsString('Producer_ID')) then mMessage:=mMessage+nxCrLf+'Není vyplněn výrobce';
    if NxIsEmptyOID(self.GetFieldValueAsString('StoreAssortmentGroup_ID')) then mMessage:=mMessage+nxCrLf+'Není vyplněna sortimentní skupina';
    if not(NxIsBlank(mMessage)) then NxShowSimpleMessage(mMessage,nil);
  end;
end;

begin
end.