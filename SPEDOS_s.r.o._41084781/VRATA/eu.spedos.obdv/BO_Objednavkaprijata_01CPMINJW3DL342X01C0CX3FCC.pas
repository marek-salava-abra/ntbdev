{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.

procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
var
 mRows:TNxCustomBusinessMonikerCollection;
 i:Integer;
 mAmount:Extended;
begin
  if self.GetFieldValueAsString('Currency_ID')='0000CZK000' then begin
    mRows:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows'));
    mAmount:=0;
    for i:=0 to mRows.CountOfNotDeleted-1 do begin
      mAmount:=mAmount+mrows.BusinessObject[i].GetFieldValueAsFloat('LocalTAmountWithoutVAT');
    end;
    Self.SetFieldValueAsFloat('LocalAmountWithoutVAT',mAmount);
  end;
end; }

begin
end.