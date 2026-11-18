{
Umožňuje ovlivnit validaci.
}
{
Vyvolává se při předvyplňování hodnot daného objektu.
}
procedure Prefill_Hook(Self: TNxCustomBusinessObject);
begin
    // NxShowSimpleMessage('Vyráběná položka,  Prefill_Hook ' + Self.GetFieldValueAsString('ID') +  Self.GetFieldValueAsString('Owner_ID.StoreCard_ID'), nil);
end;



begin
end.