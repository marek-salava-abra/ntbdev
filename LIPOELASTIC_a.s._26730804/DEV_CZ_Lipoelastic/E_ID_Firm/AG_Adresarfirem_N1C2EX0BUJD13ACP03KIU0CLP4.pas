

procedure _AfterCloneRec_Hook(Self: TRollSiteForm);
begin
  //  NxShowSimpleMessage('After clone',nil);
  TBusRollSiteForm(self).CurrentObject.SetFieldValueAsString('X_E_ID','');
  if NxIsEmptyOID(TBusRollSiteForm(self).CurrentObject.getFieldValueAsString('X_E_ID')) then begin
         TBusRollSiteForm(self).CurrentObject.SetFieldValueAsString('X_E_ID',TBusRollSiteForm(self).CurrentObject.OID);
  end;
end;





procedure _AfterNewRec_Hook(Self: TRollSiteForm);
begin
    if NxIsEmptyOID(TBusRollSiteForm(self).CurrentObject.getFieldValueAsString('X_E_ID')) then begin
         TBusRollSiteForm(self).CurrentObject.SetFieldValueAsString('X_E_ID',TBusRollSiteForm(self).CurrentObject.OID);
  end;
end;

procedure _AfterSave_PostHook(Self: TRollSiteForm);
var
mi:integer;
begin

  if nxisemptyoid(TBusRollSiteForm(self).CurrentObject.GetFieldValueAsString('X_E_ID')) then begin
      mi:= TBusRollSiteForm(self).BaseObjectSpace.SQLExecute('update firms set X_E_ID=' + quotedstr(TBusRollSiteForm(self).CurrentObject.oid) + ' where id=' + quotedstr(TBusRollSiteForm(self).CurrentObject.oid));
  end;

 self.Refresh;
end;

begin
end.