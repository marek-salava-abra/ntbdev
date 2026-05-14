{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mRows:TNxCustomBusinessMonikerCollection;
 i:integer;
begin
  if osNew in self.state then begin
   if self.GetFieldValueAsString('Docqueue_ID.Code')='PRCT' then begin
    if self.GetFieldValueAsString('Description')='' then begin
      self.SetFieldValueAsString('Description',self.GetFieldValueAsString('CreatedBy_id.LoginName'));
    end;
    mRows:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows'));
    for i:=0 to mrows.count-1 do begin
      //mRows.BusinessObject[i].SetFieldValueAsBoolean('CompletePrices',false);
    end;
   end;
  end;
end;

begin
end.