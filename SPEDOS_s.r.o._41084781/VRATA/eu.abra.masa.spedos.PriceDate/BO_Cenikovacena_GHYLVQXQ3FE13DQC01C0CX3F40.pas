{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
var
 mOrigValue:Extended;
begin
  self.GetOriginalValue_1('Amount',mOrigValue);
  if not(self.GetFieldValueAsFloat('Amount')=mOrigValue) then begin
    //NxShowSimpleMessage('S',nil);
    self.SetFieldValueAsDateTime('X_CorrectedAt',now);
  end;
end;

procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mOrigValue:Extended;
begin
  self.GetOriginalValue_1('Amount',mOrigValue);
  if not(self.GetFieldValueAsFloat('Amount')=mOrigValue) then begin
    //NxShowSimpleMessage('S',nil);
    self.SetFieldValueAsDateTime('X_CorrectedAt',now);
  end;
end;



begin
end.