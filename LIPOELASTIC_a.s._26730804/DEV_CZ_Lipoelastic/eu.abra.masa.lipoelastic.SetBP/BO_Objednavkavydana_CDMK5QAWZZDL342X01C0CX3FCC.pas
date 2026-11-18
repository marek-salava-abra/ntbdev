{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
 mBusProject_ID, mDivision_ID:String;
 mRows:TNxCustomBusinessMonikerCollection;
 i:integer;
begin
 if CFxNxRuntime.NxGetEnvironmentType=reRuntimeExe then begin
  if (AFieldCode=self.GetFieldCode('Firm_ID')) and not(AValue.AsString=AOriginalValue.AsString) then begin
    mBusProject_ID:='';
    mDivision_ID:='';
    if not(NxIsEmptyOID(self.GetFieldValueAsString('Firm_ID'))) then begin
     mBusProject_ID:=self.GetFieldValueAsString('Firm_ID.X_BusProject_ID');
     if not(NxIsEmptyOID(mBusProject_ID)) then begin
      mDivision_ID:=self.GetFieldValueAsString('Firm_ID.X_BusProject_ID.Division_ID');
     end;
    end;
    mRows:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows'));
     for i:=0 to mRows.count-1 do begin
       if not(nxisemptyoid(mBusProject_ID)) then mRows.BusinessObject[i].SetFieldValueAsString('BusProject_ID',mBusProject_ID);
       if not(nxisemptyoid(mDivision_ID)) then mRows.BusinessObject[i].SetFieldValueAsString('Division_ID',mDivision_ID);
    end;
  end;
 end;
end;

begin
end.