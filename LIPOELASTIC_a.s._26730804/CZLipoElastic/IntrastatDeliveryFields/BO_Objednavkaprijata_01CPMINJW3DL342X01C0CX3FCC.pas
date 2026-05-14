{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
begin
  if self.GetFieldValueAsInteger('TradeType')=2 then begin
    try
     if NxIsEmptyOID(self.GetFieldValueAsString('IntrastatDeliveryTerm_ID'))
       then self.SetFieldValueAsString('IntrastatDeliveryTerm_ID','3001000000');
     if NxIsEmptyOID(self.GetFieldValueAsString('IntrastatTransportationType_ID'))
       then self.SetFieldValueAsString('IntrastatTransportationType_ID','4000000000');
     if NxIsEmptyOID(self.GetFieldValueAsString('IntrastatTransactionType_ID'))
       then self.SetFieldValueAsString('IntrastatTransactionType_ID','0101000000');
    except
    end;
  end;
end;

begin
end.