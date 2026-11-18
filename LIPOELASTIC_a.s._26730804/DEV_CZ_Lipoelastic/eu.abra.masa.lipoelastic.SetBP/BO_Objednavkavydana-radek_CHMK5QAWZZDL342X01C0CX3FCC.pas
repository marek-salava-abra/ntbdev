
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
 mBusProject_ID, mDivision_ID:String;
begin
  if CFxNxRuntime.NxGetEnvironmentType=reRuntimeExe then begin
    if (AFieldCode=self.GetFieldCode('StoreCard_ID')) and not(AValue.AsString=AOriginalValue.AsString) then begin
      if not(NxIsEmptyOID(self.GetFieldValueAsString('Parent_ID.Firm_ID'))) then begin
       mBusProject_ID:=self.GetFieldValueAsString('Parent_ID.Firm_ID.X_BusProject_ID');
       if not(NxIsEmptyOID(mBusProject_ID)) then begin
        mDivision_ID:=self.GetFieldValueAsString('Parent_ID.Firm_ID.X_BusProject_ID.Division_ID');
       end;
       if not(nxisemptyoid(mBusProject_ID)) then self.SetFieldValueAsString('BusProject_ID',mBusProject_ID);
       if not(nxisemptyoid(mDivision_ID)) then self.SetFieldValueAsString('Division_ID',mDivision_ID);
      end;
    end;
  end;
end;

begin
end.