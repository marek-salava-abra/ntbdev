uses 'eu.obb.eshopfunc.fce';

procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mRows:TNxCustomBusinessMonikerCollection;
begin
  if self.GetFieldValueAsString('DocQueue_ID.Code')='DV97' then begin
   if (osNew in Self.state) and self.GetFieldValueAsBoolean('U_Generate') then begin
    if NxMessageBox('Dotaz',' Přejete si vygenerovat převodku k '+Self.DisplayName+'?' , mdConfirm, mdbYesNo, 0, 0, False, nil)= mrYes then begin
       CreateTransferFromICN(self);
    end;
   end;
  end;
end;

begin
end.