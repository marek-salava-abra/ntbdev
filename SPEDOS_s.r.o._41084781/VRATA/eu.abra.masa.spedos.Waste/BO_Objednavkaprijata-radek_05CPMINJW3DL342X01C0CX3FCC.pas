{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
begin
  if self.GetFieldValueAsInteger('RowType')=3 then begin
    self.SetFieldValueAsString('X_WasteCategory_ID',self.GetFieldValueAsString('StoreCard_ID.WasteCategory_ID'));
  end;
  if (self.GetFieldValueAsInteger('RowType')=2) and not(NxIsEmptyOID(self.GetFieldValueAsString('X_StoreCard_ID'))) then begin
    self.SetFieldValueAsString('X_WasteCategory_ID',self.GetFieldValueAsString('StoreCard_ID.WasteCategory_ID'));
  end;
end;

begin
end.