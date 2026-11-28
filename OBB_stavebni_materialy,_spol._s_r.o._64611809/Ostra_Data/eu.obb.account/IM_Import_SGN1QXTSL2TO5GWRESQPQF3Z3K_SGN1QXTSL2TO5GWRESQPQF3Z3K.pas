procedure AfterFillOptputRows_Hook(Self: TNxDocumentImportManager);
var
 mRows:TNxCustomBusinessMonikerCollection;
 i: integer;
begin
  mRows:=self.OutputDocument.GetLoadedCollectionMonikerForFieldCode(self.OutputDocument.GetFieldCode('Rows'));
  for i:=0 to mrows.count-1 do begin
    if (mrows.BusinessObject[i].GetFieldValueAsString('Text')='Vedlejší pořizovací náklady - Doprava') then  begin
        mrows.BusinessObject[i].SetFieldValueAsString('ExpenseType_ID','1600000101');
        mrows.BusinessObject[i].SetFieldValueAsString('VatRate_ID','02100X0000');
        mrows.BusinessObject[i].SetFieldValueAsFloat('VatRate',21);
    end;
  end;
end;

begin
end.