{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mRows:TNxCustomBusinessMonikerCollection;
 mBool:Boolean;
 i,j:Integer;
 mRowBO:TNxCustomBusinessObject;
 mAdd, mKoef:extended;
begin
  mRows:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows'));
  mBool:=True;
  mAdd:=0;
  for i:=0 to mRows.count-1 do begin
    mRowBO:=mRows.BusinessObject[i];
    if mRowBO.GetFieldValueAsInteger('RowType')=3 then begin
    if (mRowBO.GetFieldValueAsFloat('StoreCard_ID.X_NC_1')+mRowBO.GetFieldValueAsFloat('StoreCard_ID.X_NC_2'))>0 then begin
      if mRowBO.GetFieldValueAsFloat('Quantity')>0 then mKoef:=mRowBO.GetFieldValueAsFloat('StoreCard_ID.X_Koeficient_1');
      if mRowBO.GetFieldValueAsFloat('Quantity')>2 then mKoef:=mRowBO.GetFieldValueAsFloat('StoreCard_ID.X_Koeficient_2');
      if mRowBO.GetFieldValueAsFloat('Quantity')>4 then mKoef:=mRowBO.GetFieldValueAsFloat('StoreCard_ID.X_Koeficient_3');
      if mRowBO.GetFieldValueAsFloat('Quantity')>6 then mKoef:=mRowBO.GetFieldValueAsFloat('StoreCard_ID.X_Koeficent_4');
      if mRowBO.GetFieldValueAsFloat('Quantity')>8 then mKoef:=mRowBO.GetFieldValueAsFloat('StoreCard_ID.X_Koeficient_5');
      if mRowBO.GetFieldValueAsString('Parent_ID.TransportationType_ID.Code')='8' then begin
       if j=1 then begin
         mAdd:=0;
       end;
       if j=0 then begin
         mAdd:=298;
         j:=1
       end;

      end;
      mRowBO.SetFieldValueAsFloat('X_NCPrace',(mKoef*mRowBO.GetFieldValueAsFloat('StoreCard_ID.X_NC_1'))+mAdd);
    end;
  end;

  end;
end;

begin
end.