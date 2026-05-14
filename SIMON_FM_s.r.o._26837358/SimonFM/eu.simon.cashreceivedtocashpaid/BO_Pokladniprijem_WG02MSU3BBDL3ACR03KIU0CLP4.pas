


{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mRowBO, mBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
begin
 if osNew in self.State then begin
    if self.GetFieldValueAsString('DocQueue_ID')=('7J10000101') then begin

      if Copy(self.GetFieldValueAsString('Description'),0,5)='Tržba' then begin
       try
       mbo:=self.ObjectSpace.CreateObject(Class_CashPaid);
       mbo.New;
       mbo.Prefill;
       mbo.SetFieldValueAsString('CashDesk_ID','1600000101');
       mbo.SetFieldValueAsString('Docqueue_ID','8J10000101');
       mbo.SetFieldValueAsBoolean('VatDocument',False);
       mbo.SetFieldValueAsString('Description',self.GetFieldValueAsString('Description'));
       mRows:=mBO.GetCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows'));
       mRowBO:=mrows.AddNewObject;
       mRowBO.SetFieldValueAsString('Division_ID','4100000101');
       mRowBO.SetFieldValueAsString('Text',self.GetFieldValueAsString('Description')+ 'ze dne '+FormatDateTime('d.m.yyyy',self.GetFieldValueAsDateTime('DocDate$Date')));
       mRowBO.SetFieldValueAsFloat('Tamount',self.GetFieldValueAsFloat('Amount'));
       mrowbo.SetFieldValueAsString('ExpenseType_ID','Q100000101');
       mRowBO.SetFieldValueAsString('BusTransaction_ID','1000000101');

       mbo.save;
       finally

       end;
      end;
    end;
 end;



end;

begin
end.