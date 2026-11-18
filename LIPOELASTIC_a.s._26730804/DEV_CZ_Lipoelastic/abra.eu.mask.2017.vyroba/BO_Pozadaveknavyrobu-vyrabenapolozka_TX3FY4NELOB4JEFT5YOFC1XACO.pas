{
Vyvolává se při předvyplňování hodnot daného objektu.
}
{
Umožňuje ovlivnit korekci hodnot polí.
}
procedure Correct_Hook(Self: TNxCustomBusinessObject);
begin
      NxShowSimpleMessage('A',nil);
  if NxIsEmptyOID(self.GetFieldValueAsString('RoutineStoreCard_ID')) then begin
         NxShowSimpleMessage('Není tp , doplnuji ' +    self.GetFieldValueAsString('Owner_ID.StoreCard_ID'),nil);
  end;
end;

procedure Prefill_Hook(Self: TNxCustomBusinessObject);
begin
 // NxShowSimpleMessage('A',nil);
 // if NxIsEmptyOID(self.GetFieldValueAsString('RoutineStoreCard_ID')) then begin
 //        NxShowSimpleMessage('Není tp , doplnuji ' +    self.GetFieldValueAsString('Owner_ID.StoreCard_ID'),nil);
 // end;
end;

begin
end.