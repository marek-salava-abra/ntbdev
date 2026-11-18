{
Umožňuje ovlivnit validaci.
}{
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mFrac:Extended;
begin
  if CFxNxRuntime.NxGetEnvironmentType=reRuntimeExe then begin
   if not(self.GetFieldValueAsBoolean('Parent_ID.DocQueue_ID.X_NoCheckProdQty')) then begin
     if self.GetFieldValueAsInteger('RowType')=3 then begin
      if self.GetFieldValueAsFloat('StoreCard_ID.X_Davka_sici')>0 then begin
        mFrac:=Frac(Self.GetFieldValueAsFloat('Quantity')/self.GetFieldValueAsFloat('StoreCard_ID.X_Davka_sici'));
        if not(mFrac=0) then begin
          self.AddValidateError(self.GetFieldCode('Quantity'),'Zadané množství neodpovídá násobku šicí dávky '
          +floattostr(self.GetFieldValueAsFloat('StoreCard_ID.X_Davka_sici')));
          AResult:=False;
        end;
      end;
     end;
    end;
  end;
end;   }

begin
end.