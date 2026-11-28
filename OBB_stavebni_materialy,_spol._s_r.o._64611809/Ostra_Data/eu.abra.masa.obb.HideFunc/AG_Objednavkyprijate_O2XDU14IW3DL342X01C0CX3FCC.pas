{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mActionList: TActionList;
  i: Integer;
 mUser:TNxCustomBusinessObject;
begin
  mUser:=self.BaseObjectSpace.CreateObject(Class_SecurityUser);
  mUser.Load(NxGetActualUserID(self.BaseObjectSpace),nil);
  if not(muser.GetFieldValueAsBoolean('U_Saldo')) then begin
    mActionList := Self.GetMainActionList;
    for i := 0 to mActionList.ActionCount - 1 do
    begin
      if mActionList.Actions[i].Name = 'actCreateBySelected' then
      begin
        TMultiAction(mActionList.Actions[i]).Items[7] := '';
        Break;
      end;;
    end;
  end;
end;

begin
end.