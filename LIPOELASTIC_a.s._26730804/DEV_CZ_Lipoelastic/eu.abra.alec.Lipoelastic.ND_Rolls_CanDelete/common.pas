procedure _CanDelete_Hook(Self: TRollSiteForm; var ACanDelete: Boolean);
var
  mSQL, mValue_ID: String;
begin
  mSQL:= Format('SELECT TOP 1 ID FROM DefRollData WHERE CLSID = ''%s'' AND X_RollValueID = ''%s''',
                [Class_BO_Relations, TBusRollSiteForm(Self).CurrentObject.OID]);

  mValue_ID:= Self.BaseObjectSpace.SQLSelectFirstAsString(mSQL);
  if not NxIsEmptyOID(mValue_ID) then
  begin
    ACanDelete:= False;
    NxShowSimpleMessage('Záznam nelze smazat. Je použit jako parametr u skladových karet.', Self);
  end;
end;

begin
end.