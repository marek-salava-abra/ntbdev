{procedure _CanEdit_Hook(Self: TDynSiteForm; var ACanEdit: Boolean);
var
 mUser:TNxCustomBusinessObject;
begin
  mUser:=self.CurrentObject.ObjectSpace.CreateObject(Class_SecurityUser);
  mUser.Load(NxGetActualUserID(self.CurrentObject.ObjectSpace),nil);
  if mUser.GetFieldValueAsBoolean('U_CorrectionDenial') then begin
   if self.CurrentObject.GetFieldValueAsBoolean('Closed') then begin
    ACanEdit:=true;
    end
   else begin ACanEdit:=false;
   NxShowSimpleMessage('Nemáte právo opravovat čerpanou objednávky',Self);
   end;
  end;
end; }

begin
end.