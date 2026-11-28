procedure _CanEdit_Hook(Self: TDynSiteForm; var ACanEdit: Boolean);
var
 mUser:TNxCustomBusinessObject;
begin
  mUser:=self.CurrentObject.ObjectSpace.CreateObject(Class_SecurityUser);
  mUser.Load(NxGetActualUserID(self.CurrentObject.ObjectSpace),nil);
  if mUser.GetFieldValueAsBoolean('U_CorrectionDenial') then begin
   if ((self.CurrentObject.GetFieldValueAsDateTime('DocDate$Date')+1)>date) or (self.CurrentObject.GetFieldValueAsBoolean('Finished')) then begin
    ACanEdit:=true;
    end
   else begin ACanEdit:=false;
   NxShowSimpleMessage('Oprava zamítnuta.Vratka příjemky není vystavena dnes.',Self);
   end;
  end;
end;

begin
end.