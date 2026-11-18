uses '.API';
{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
  mJSON: TJSONSuperObject;
begin
  if (osNew in Self.State) then begin
    if not(NxIsEmptyOID(Self.GetFieldValueAsString('U_SKIssuedInvoice_ID'))) then begin
      mJSON:=TJSONSuperObject.Create;
      mJSON.S['U_ReceivedInvoice_CZ']:= Self.DisplayName;
      API_PUT(mJSON, 'IssuedInvoices', Self.GetFieldValueAsString('U_SKIssuedInvoice_ID'));
    end;
  end;
end;

{
Vyvoláva sa po fyzickom vymazaní vlastného objektu z databázy.
}

procedure AfterDelete_Hook(Self: TNxCustomBusinessObject);
var
 mJSON:TJSONSuperObject;
 mID:string;
begin
  self.GetOriginalValue('U_SKIssuedInvoice_ID',mID);
  if not(NxIsEmptyOID(mID)) then begin
     mJSON:=TJSONSuperObject.Create;
     mJSON.S['U_ReceivedInvoice_CZ']:='';
     API_PUT(mJSON, 'IssuedInvoices', mID);
  end;
end;


begin
end.