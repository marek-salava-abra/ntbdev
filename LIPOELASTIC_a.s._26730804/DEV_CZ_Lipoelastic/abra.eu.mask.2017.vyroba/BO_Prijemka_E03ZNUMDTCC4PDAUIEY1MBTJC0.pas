uses 'EU.Aabra.Mask.Validace.lib';
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
  mName: string;
begin
  if ((self.GetFieldValueAsString('DocQueue_ID')='4910000101') or (self.GetFieldValueAsString('DocQueue_ID')='1A10000101')) and (self.GetFieldValueAsString('Firm_ID')<>'JJHF800101') then begin
        if self.GetFieldValueAsString('Currency_ID')<>'0000CZK000' then begin
            AResult := False;
            Self.AddValidateError(Self.GetFieldCode('Firm_ID'), 'Je správně uvedena firma, ( je použita jiná měna než CZK).');
        end;
  end;
end;

begin
end.