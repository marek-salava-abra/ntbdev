{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
 mBO:TNxCustomBusinessObject;
 mUser:TNxCustomBusinessObject;
 mDivision_ID:String;
begin
   mBO:=Self;
   mUser:=mbo.ObjectSpace.CreateObject(Class_SecurityUser);
   mUser.Load(NxGetActualUserID_1(mBO),nil);
   mDivision_ID:=muser.GetFieldValueAsString('X_division_ID');
  if AFieldCode=self.GetFieldCode('RowType') then begin
    self.SetFieldValueAsString('Division_ID',mDivision_ID);
    if not(NxIsEmptyOID(self.GetFieldValueAsString('Parent_ID.FirmOffice_ID.X_BusTransaction_ID'))) and NxIsEmptyOID(self.GetFieldValueAsString('BusTransaction_ID')) then begin
      self.SetFieldValueAsString('BusTransaction_ID',self.GetFieldValueAsString('Parent_ID.FirmOffice_ID.X_BusTransaction_ID'));

    end;
    if not(NxIsEmptyOID(self.GetFieldValueAsString('Parent_ID.Firm_ID.X_BusTransaction_ID'))) and NxIsEmptyOID(self.GetFieldValueAsString('BusTransaction_ID')) then begin
      self.SetFieldValueAsString('BusTransaction_ID',self.GetFieldValueAsString('Parent_ID.Firm_ID.X_BusTransaction_ID'));

    end;
  end;
end;



{
Vyvolává se bezprostředně před provedením softvalidace objektu.
}
procedure BeforeSoftValidate_Hook(Self: TNxCustomBusinessObject);
begin
  //if not(self.GetFieldValueAsFloat('TAmount')=Trunc(self.GetFieldValueAsFloat('TAmount'))) then self.SetFieldValueAsFloat('TAmount',NxRoundByValue(self.GetFieldValueAsFloat('TAmount'),ctArithmetic,1));
end;

begin
end.