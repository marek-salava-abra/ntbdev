{
Umožňuje ovlivnit validaci.

procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mKoef, mNC:Extended;
begin
  if self.GetFieldValueAsInteger('RowType')=3 then begin
    if (self.GetFieldValueAsFloat('StoreCard_ID.X_NC_1')+self.GetFieldValueAsFloat('StoreCard_ID.X_NC_2'))>0 then begin
      if self.GetFieldValueAsFloat('Quantity')>0 then mKoef:=self.GetFieldValueAsFloat('StoreCard_ID.X_Koeficient_1');
      if self.GetFieldValueAsFloat('Quantity')>2 then mKoef:=self.GetFieldValueAsFloat('StoreCard_ID.X_Koeficient_2');
      if self.GetFieldValueAsFloat('Quantity')>4 then mKoef:=self.GetFieldValueAsFloat('StoreCard_ID.X_Koeficient_3');
      if self.GetFieldValueAsFloat('Quantity')>6 then mKoef:=self.GetFieldValueAsFloat('StoreCard_ID.X_Koeficent_4');
      if self.GetFieldValueAsFloat('Quantity')>8 then mKoef:=self.GetFieldValueAsFloat('StoreCard_ID.X_Koeficient_5');
      if self.GetFieldValueAsString('Parent_ID.TransportationType_ID.Code')='8' then
       mNC:= self.GetFieldValueAsFloat('StoreCard_ID.X_NC_2') else mNC:= self.GetFieldValueAsFloat('StoreCard_ID.X_NC_1');
      self.SetFieldValueAsFloat('X_NCPrace',mKoef*mNC);
    end;
  end;
end; }

begin
end.