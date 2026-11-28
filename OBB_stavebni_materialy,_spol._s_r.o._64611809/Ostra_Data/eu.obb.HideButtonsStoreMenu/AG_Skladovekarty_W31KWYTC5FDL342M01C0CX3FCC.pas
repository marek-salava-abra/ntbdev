{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  aList: TActionList;
  i: Integer;
  mUser:TNxCustomBusinessObject;
begin
  if not(NxIsEmptyOID(NxGetActualUserID(self.BaseObjectSpace))) then begin
   mUser:=self.BaseObjectSpace.CreateObject(Class_SecurityUser);
   mUser.Load(NxGetActualUserID(self.BaseObjectSpace),nil);
   if not(mUser.GetFieldValueAsBoolean('U_Skladova_karta')) then begin
    aList := Self.GetMainActionList;
      for i:=0 to aList.ActionCount -1 do begin
        if aList.Actions[i].Name = 'actAddStoreMenu' then aList.Actions[i].Category := 'DISABLE';
        if aList.Actions[i].Name = 'actRemoveStoreMenu' then aList.Actions[i].Category := 'DISABLE';
      end;
   end;
  end;
end;


begin
end.