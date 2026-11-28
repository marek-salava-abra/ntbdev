



{procedure _CanEdit_Hook(Self: TDynSiteForm; var ACanEdit: Boolean);
var
 mUser:TNxCustomBusinessObject;
begin
  mUser:=self.CurrentObject.ObjectSpace.CreateObject(Class_SecurityUser);
  mUser.Load(NxGetActualUserID(self.CurrentObject.ObjectSpace),nil);
  if mUser.GetFieldValueAsBoolean('U_CorrectionDenial') then begin
   if (((self.CurrentObject.GetFieldValueAsDateTime('DocDate$Date')+1)<date) or (self.CurrentObject.GetFieldValueAsFloat('PaidAmount')=0)) then begin
    ACanEdit:=true;
    end
   else begin ACanEdit:=false;
   NxShowSimpleMessage('Nemáte právo opravovat zaplacený doklad nebo starý doklad',Self);
   end;
  end;
end; }

procedure _CanEdit_Hook(Self: TDynSiteForm; var ACanEdit: Boolean);
var
 mUser:TNxCustomBusinessObject;
begin
  mUser:=self.CurrentObject.ObjectSpace.CreateObject(Class_SecurityUser);
  mUser.Load(NxGetActualUserID(self.CurrentObject.ObjectSpace),nil);
  if mUser.GetFieldValueAsBoolean('U_CorrectionDenial') then begin
  //NxShowSimpleMessage('Test',Self);
   if (((self.CurrentObject.GetFieldValueAsDateTime('DocDate$Date')+1)>date) and (self.CurrentObject.GetFieldValueAsFloat('PaidAmount')=0)) then begin
    ACanEdit:=true;
    end
   else begin ACanEdit:=false;
   NxShowSimpleMessage('Oprava zamítnuta.Faktura není vystavena dnes nebo je již hrazena.',Self);
   end;
  end;
end;

begin
end.