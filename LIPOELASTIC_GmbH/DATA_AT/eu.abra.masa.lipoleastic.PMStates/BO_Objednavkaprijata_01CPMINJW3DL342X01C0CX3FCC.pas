uses '.const';

//B2B pokud na firmě zákaz vydávání posunout automaticky z accepted do on hold
{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
  if self.GetFieldValueAsBoolean('Firm_ID.X_DenialOfDispatch') then self.SetFieldValueAsString('PMState_ID','~000000203');
  AResult:=true;
end;

{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
begin
  //Nastaví potvrzeno po tom co je OP zkontrolována
  if (Self.DifferentFromOriginal_1('PMState_ID')) and (Self.GetFieldValueAsString('PMState_ID') = cPMSTATE_ID_1020_Checked) then
  begin
    Self.SetFieldValueAsBoolean('Confirmed', True);
  end;

  //Změní stav při manuálním vystavení DL
  if (Self.GetFieldValueAsString('PMState_ID') in [cPMSTATE_ID_1040_Ready_to_be_picked, cPMSTATE_ID_1045_Scanning, cPMSTATE_ID_1060_Partially_Dispatched])
    and (Self.GetFieldValueAsBoolean('Closed') = True) then
  begin
    Self.SetFieldValueAsString('PMState_ID', cPMSTATE_ID_1050_Scanned);
  end;

  //Nastaví vyřízeno po tom co je OP cancelled
  if (Self.DifferentFromOriginal_1('PMState_ID')) and (Self.GetFieldValueAsString('PMState_ID') = cPMSTATE_ID_1199_Cancelled) then
  begin
    Self.SetFieldValueAsBoolean('Closed', True);
  end;
end;


begin
end.