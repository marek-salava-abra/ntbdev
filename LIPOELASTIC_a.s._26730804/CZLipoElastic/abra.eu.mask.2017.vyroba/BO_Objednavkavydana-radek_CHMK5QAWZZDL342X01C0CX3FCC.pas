 uses 'EU.Aabra.Mask.Validace.lib';

{
Umožňuje ovlivnit validaci.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
   mi:integer;
begin
  if self.GetFieldValueAsString('Parent_ID.DocQueue_ID')='7B10000101' then begin
      if self.GetFieldValueAsfloat('LocalTAmount')<> 0 then begin
            self.SetFieldValueAsfloat('UnitPrice',0);
            self.SetFieldValueAsfloat('TotalPrice',0);
            self.SetFieldValueAsfloat('TAmountWithoutVAT',0);
            self.SetFieldValueAsfloat('TAmount',0);
            self.SetFieldValueAsfloat('LocalTAmountWithoutVAT',0);
            self.SetFieldValueAsfloat('LocalTAmount',0);
      end;
  end;
  if osNew in self.State  then begin
       // mi:=self.ObjectSpace.SQLExecute('update FROM DefRollData set X_parent_ID='+ quotedstr('0000000000')
       //     + ' WHERE (CLSID = 'EC2R2HSFK5UOZ5MYVJWJOHUC4S' ) AND (UPPER(A.X_Parent_ID)=' + quotedstr('self.OID')) ;




        //if (self.GetFieldValueAsString('DocQueue_ID')='1540000101')  then begin
           //      self.SetFieldValueAsBoolean('Confirmed',false);

        //    end;
  end;
end;



begin
end.