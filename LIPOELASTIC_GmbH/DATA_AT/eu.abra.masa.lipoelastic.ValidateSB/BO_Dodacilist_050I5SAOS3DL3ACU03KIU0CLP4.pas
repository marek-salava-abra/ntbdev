{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mRows, mDRBRows:TNxCustomBusinessMonikerCollection;
 mRowBO:TNxCustomBusinessObject;
 i,j:integer;
 mSBQuantity:Extended;
begin
  AResult:=True;
  if (CFxNxRuntime.NxGetEnvironmentType=reRuntimeExe) then begin
   // if NxGetActualUserID_1(Self)='~000000001' then begin
      mRows:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows'));
      for i:=0 to mRows.count-1 do begin
        mRowBO:=mRows.BusinessObject[i];
        if mRowBO.GetFieldValueAsInteger('RowType')=3 then begin
          if mRowBO.GetFieldValueAsInteger('StoreCard_ID.Category') in [1,2] then begin
            mSBQuantity:=0;
            mDRBRows:=mRowBO.GetLoadedCollectionMonikerForFieldCode(mRowBO.GetFieldCode('DocRowBatches'));
            for j:=0 to mDRBRows.count-1 do begin
              mSBQuantity:=mSBQuantity+mDRBRows.BusinessObject[j].GetFieldValueAsFloat('Quantity');
            end;
            if AResult and not(mSBQuantity=mRowBO.GetFieldValueAsFloat('Quantity')) then AResult:=False;
          end;
        end;
      end;
   // end;
  end;
  if not(AResult) then Self.AddValidateError(self.GetFieldCode('Description'),'Document has different quantity in batches than in rows.');
end;

begin
end.