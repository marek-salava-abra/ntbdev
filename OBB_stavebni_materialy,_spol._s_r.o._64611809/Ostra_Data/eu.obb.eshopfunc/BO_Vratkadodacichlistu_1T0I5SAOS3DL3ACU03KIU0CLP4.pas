
{procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mBO, mRowBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 i:integer;
begin
  if self.GetFieldValueAsString('DocQueue_ID.Code')='VR97' then begin
      mRows:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows'));
      for i:=0 to mrows.count-1 do begin
        mRowBO:=mRows.BusinessObject[i];
        if mRowBO.GetFieldValueAsFloat('DeliveredQuantity')=0 then mRowBO.MarkForDelete;
      end;
  end;
end;      }

begin
end.