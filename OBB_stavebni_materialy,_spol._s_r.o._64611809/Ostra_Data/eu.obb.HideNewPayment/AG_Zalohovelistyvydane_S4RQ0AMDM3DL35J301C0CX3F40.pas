
procedure FormShow_Hook(Self: TSiteForm);
var
  aList: TActionList;
  i: Integer;
  mUser:TNxCustomBusinessObject;
begin
   if not(NxIsEmptyOID(NxGetActualUserID(self.BaseObjectSpace))) then begin
   mUser:=self.BaseObjectSpace.CreateObject(Class_SecurityUser);
   mUser.Load(NxGetActualUserID(self.BaseObjectSpace),nil);
       if not(mUser.GetFieldValueAsBoolean('U_EET')) then begin
          aList := Self.GetMainActionList;
          for i:=0 to aList.ActionCount -1 do
              begin

                if aList.Actions[i].Name = 'actPaysNew' then aList.Actions[i].Category := 'DISABLE';
              end;
          end;
      end;
end;
begin
end.