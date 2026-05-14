

procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
  if not nxisemptyoid(self.GetFieldValueAsString('X_PrintReport_ID')) then begin
        AResult := False;

    Self.AddValidateError(Self.GetFieldCode('Docdate$date'), 'Faktura je již archivovaná');
  end;
end;

begin
end.