procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Odeslat API';
  mAction.Hint := 'Odešle do API';
  mAction.Category := 'tabList';
  mAction.OnExecute := @API;
end;

Procedure API(sender:TComponent);
var
 mSite:TSiteForm;
 mStream:TMemoryStream;
 mBO:TNxCustomBusinessObject;
begin
 mSite:=TComponent(sender).DynSite;
 mBO:=TDynSiteForm(mSite).CurrentObject;
 if Assigned(mBO) then begin
      mStream := TMemoryStream.Create;
                   if not(NxIsBlank(mbo.GetFieldValueAsString('U_ID_vyrobku'))) then
                   CFxInternet.HTTPPostBinary('https://sod.spedos.cz/api/api.abra-vyroba.php?',
                                              'user=aBra&password=skS8f-sxR&ID_montaz_vyrobky=' + mbo.GetFieldValueAsString('U_id_vyrobku') +
                                              '&cislo_vyrobniho_prikazu='+ mBO.DisplayName+
                                              '&abra_user=',mStream);
                                             //end;
                                             mStream.Free;

 end;
end;

begin
end.