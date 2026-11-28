procedure _CanEdit_Hook(Self: TDynSiteForm; var ACanEdit: Boolean);
var
 mUser:TNxCustomBusinessObject;
begin
  mUser:=self.CurrentObject.ObjectSpace.CreateObject(Class_SecurityUser);
  mUser.Load(NxGetActualUserID(self.CurrentObject.ObjectSpace),nil);
  if mUser.GetFieldValueAsBoolean('U_CorrectionDenial') then begin
   if not(osNew in self.CurrentObject.State) then begin

  if (((self.CurrentObject.GetFieldValueAsDateTime('DocDate$Date')+1)>date) and (self.CurrentObject.GetFieldValueAsBoolean('IsAvailableForDelivery'))) then begin
    ACanEdit:=true;
    end
   else begin ACanEdit:=false;
   NxShowSimpleMessage('Oprava zamítnuta.Dodací list není vystaven dnes nebo je svázaný s fakturou.',Self);
   end;

   end;
  end;
end;

begin
end.