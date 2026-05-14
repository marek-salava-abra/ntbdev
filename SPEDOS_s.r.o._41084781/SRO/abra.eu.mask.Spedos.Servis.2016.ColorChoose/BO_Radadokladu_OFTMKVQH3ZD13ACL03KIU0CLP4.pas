

{
Vyvoláva sa po zmene každej položky. A to len, pokiaľ k tejto zmene nedochádza vďaka načítaniu objektu z databázy alebo vďaka vytváraniu kópie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
begin
  if (AFieldCode=Self.GetFieldCode('X_Color')) and (AValue.AsInteger<>AOriginalValue.AsInteger) then begin
    //UpdateChildColors(Self);
  end;
end;


begin
end.