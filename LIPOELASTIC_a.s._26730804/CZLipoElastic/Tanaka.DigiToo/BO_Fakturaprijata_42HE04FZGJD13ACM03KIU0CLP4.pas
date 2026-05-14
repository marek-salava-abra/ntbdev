uses
  'Tanaka.DigiToo.Common';

procedure _AfterDwarfSave_Hook(Self: TNxCustomBusinessObject; ADwarfCode: Integer);
begin
  ChangePaymentStatus(Self, ADwarfCode);
end;

procedure BeforeDelete_Hook(Self: TNxCustomBusinessObject);
var
  lmRows: TNxCustomBusinessMonikerCollection;
  loRow: TNxCustomBusinessObject;
  lcSQL: string;
  i: integer;
begin
  lmRows:= Self.GetLoadedCollectionMonikerForFieldCode(Self.GetFieldCode('Rows'));
  for i:=0 to lmRows.Count-1 do begin
    loRow:= lmRows.BusinessObject[i];
    lcSQL:= 'Update StoreDocuments2 set X_ReceivedInvoiceRow_ID='' '' where X_ReceivedInvoiceRow_ID='+QuotedStr(loRow.OID);
    try
      Self.ObjectSpace.SQLExecute(lcSQL);
    except
    end;
  end;
end;

begin
end.