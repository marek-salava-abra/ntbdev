{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mRows:TNxCustomBusinessMonikerCollection;
 i:integer;
 mRowBO,mReservationBO:TNxCustomBusinessObject;
begin
  if self.GetFieldValueAsString('DocQueue_ID.Code')='OP97' then begin
    mRows:=self.GetLoadedCollectionMonikerForFieldCode(Self.GetFieldCode('Rows'));
    for i:=0 to mRows.count-1 do begin
       mRowBO:=mrows.BusinessObject[i];
       if mRowBO.GetFieldValueAsString('Store_ID.Code')='97' then begin
         mRowBO.SetFieldValueAsFloat('Reservation_ID.Reserved',0);
       end else begin
         mRowBO.SetFieldValueAsFloat('Reservation_ID.Reserved',mRowBO.GetFieldValueAsFloat('Quantity'));
       end;
    end;
  end;
end;

begin
end.