procedure AfterSoftValidate_Hook(Self: TNxCustomBusinessObject);
begin
  if not(NxIsEmptyOID(self.GetMonikerForFieldCode(self.GetFieldCode('Parent_ID')).BusinessObject.GetMonikerForFieldCode(self.GetMonikerForFieldCode(self.GetFieldCode('Parent_ID')).BusinessObject.GetFieldCode('Firm_id')).BusinessObject.GetFieldValueAsString('U_BusTransaction_ID'))) then begin
  if not(self.GetFieldValueAsString('BusTransaction_ID')=self.GetMonikerForFieldCode(self.GetFieldCode('Parent_ID')).BusinessObject.GetMonikerForFieldCode(self.GetMonikerForFieldCode(self.GetFieldCode('Parent_ID')).BusinessObject.GetFieldCode('Firm_id')).BusinessObject.GetFieldValueAsString('U_BusTransaction_ID'))
  then ShowMessage('FV - Obchodní případ se neshoduje s přiděleným OP k firmě');
  end;
  if (((self.GetFieldValueAsString('Division_ID')='4100000101') and
     (self.getfieldvalueasinteger('RowType')=3) and not(Self.GetFieldValueAsString('Store_ID')='2D00000101')) and
    not((self.GetFieldValueAsString('Storecard_ID')='3I35000101') or  (self.GetFieldValueAsString('Storecard_ID')='1J35000101'))) then begin
     ShowMessage('Zkontrolujte středisko, je tam chyba');
     end;
end;

{
Vyvolává se bezprostředně před provedením softvalidace objektu.
}


procedure Prefill_Hook(Self: TNxCustomBusinessObject);
var
mUser: TNxCustomBusinessObject;

begin
  muser:= self.ObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');
    mUser.Load(NxGetActualUserID_1(self), nil);
    self.SetFieldValueAsString('Division_ID',mUser.GetFieldValueAsString('X_Division_ID'));
    self.SetFieldValueAsString('BusTransaction_ID',
    self.GetMonikerForFieldCode(self.GetFieldCode('Parent_ID')).BusinessObject.GetMonikerForFieldCode(self.GetMonikerForFieldCode(self.GetFieldCode('Parent_ID')).BusinessObject.GetFieldCode('Firm_id')).BusinessObject.GetFieldValueAsString('U_BusTransaction_ID')
    );
end;
{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);

begin
  if AFieldCode=self.GetFieldCode('StoreCard_ID') then begin

   if self.GetFieldValueAsString('Storecard_ID')='3I35000101' then self.SetFieldValueAsString('Division_ID','4100000101');
   if self.GetFieldValueAsString('Storecard_ID')='1J35000101' then self.SetFieldValueAsString('Division_ID','4100000101');
   if self.GetFieldValueAsString('Storecard_ID')='2J35000101' then self.SetFieldValueAsString('Division_ID','4100000101');

   end;
end;


procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin

   if self.GetFieldValueAsString('Storecard_ID')='3I35000101' then self.SetFieldValueAsString('Division_ID','4100000101');
   if self.GetFieldValueAsString('Storecard_ID')='1J35000101' then self.SetFieldValueAsString('Division_ID','4100000101');
   if self.GetFieldValueAsString('Storecard_ID')='2J35000101' then self.SetFieldValueAsString('Division_ID','4100000101');

   AResult:=True;

end;




begin
end.