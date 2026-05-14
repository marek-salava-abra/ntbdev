procedure _SaveChanges_PreHook(Self: TDynSiteForm);
begin
  if (self.CurrentObject.GetFieldValueAsBoolean('Firm_ID.U_stop_fakturace')
     or self.CurrentObject.GetFieldValueAsBoolean('Firm_ID.U_blacklist')) and not(self.CurrentObject.GetFieldValueAsString('DocQueue_ID')='1X10000101')

  then begin


   NxShowSimpleMessage('Je vybrána která je buď na černé lsitině nebo má stop fakturace',self);
   self.CurrentObject.SetFieldValueAsString('Firm_ID','0000000000');
  end;
end;

begin
end.