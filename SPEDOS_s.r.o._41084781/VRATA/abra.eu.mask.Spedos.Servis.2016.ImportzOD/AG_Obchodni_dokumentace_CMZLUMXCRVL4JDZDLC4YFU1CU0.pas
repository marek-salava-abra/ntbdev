procedure _AfterSave_PostHook(Self: TRollSiteForm);
var
mi:integer;
mbx:boolean;
begin
    mi:=self.BaseObjectSpace.SQLExecute('update receivedorders2 set DeliveryDate$Date=' + quotedstr(NxFloatToIBStr(TBusRollSiteForm(self).CurrentObject.GetFieldValueAsDateTime('X_Datum_vyroby$date'))) +
    ' where X_parent_id=' + quotedstr(TBusRollSiteForm(self).CurrentObject.oid));
        mi:=self.BaseObjectSpace.SQLExecute('update issuedorders2 set DeliveryDate$Date=' + quotedstr(NxFloatToIBStr(TBusRollSiteForm(self).CurrentObject.GetFieldValueAsDateTime('X_Datum_vyroby$date'))) +
    ' where X_parent_id=' + quotedstr(TBusRollSiteForm(self).CurrentObject.oid));

end;

procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
  mCode: integer;
  mi:integer;
begin
  mCode := Self.GetFieldCode('X_Datum_vyroby$date');
  if AFieldCode = mCode then begin
        NxShowSimpleMessage('změna data',nil);
    if AOriginalValue.AsDateTime <> AValue.AsDateTime then
       mi:=self.ObjectSpace.SQLExecute('update receivedorders2 set DeliveryDate$Date=' + quotedstr(NxFloatToIBStr(AValue.AsDateTime)) + ' where X_vyrobek=' + quotedstr(self.oid));

  end;
end;


begin
end.