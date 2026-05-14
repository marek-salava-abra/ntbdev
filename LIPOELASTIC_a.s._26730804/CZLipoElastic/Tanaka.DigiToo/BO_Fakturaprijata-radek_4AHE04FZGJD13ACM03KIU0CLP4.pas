procedure BeforeDelete_Hook(Self: TNxCustomBusinessObject);
var
  lcSQL: string;
begin
  lcSQL:= 'Update StoreDocuments2 set X_ReceivedInvoiceRow_ID='' '' where X_ReceivedInvoiceRow_ID='+QuotedStr(Self.OID);
  try
    Self.ObjectSpace.SQLExecute(lcSQL);
  except
  end;
end;

begin
end.