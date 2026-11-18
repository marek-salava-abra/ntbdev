uses '.API';

{
Vyvoláva sa po fyzickom vymazaní vlastného objektu z databázy.
}
procedure AfterDelete_Hook(Self: TNxCustomBusinessObject);
var
 mJSON:TJSONSuperObject;
 mIDSK, mIDAT:string;
begin
  self.GetOriginalValue('U_SKIssuedOrder_ID',mIDSK);
  self.GetOriginalValue('U_ATIssuedOrder_ID',mIDAT);
  if not(NxIsEmptyOID(mIDSK)) then begin
     mJSON:=TJSONSuperObject.Create;
     mJSON.S['X_ExternalDocument']:='';
     mJSON.DT8601['X_SendDate$Date']:=0;
     API_PUT(mJSON, 'IssuedOrders', mIDSK,0);
  end;
  if not(NxIsEmptyOID(mIDAT)) then begin
     mJSON:=TJSONSuperObject.Create;
     mJSON.S['X_ExternalDocument']:='';
     mJSON.DT8601['X_SendDate$Date']:=0;
     API_PUT(mJSON, 'IssuedOrders', mIDAT,2);
  end;
end;



{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mBool:Boolean;
 mJSON:TJSONSuperObject;
 mIDAT:string;
begin
  self.GetOriginalValue_3('Confirmed',mBool);
  if not(mBool) and self.GetFieldValueAsBoolean('Confirmed') then begin
    mIDAT:=self.GetFieldValueAsString('U_ATIssuedOrder_ID');
    if not(NxIsEmptyOID(mIDAT)) then begin
     mJSON:=TJSONSuperObject.Create;
     mJSON.B['Confirmed']:=self.GetFieldValueAsBoolean('Confirmed');
     API_PUT(mJSON, 'IssuedOrders', mIDAT,2);
    end;
  end;
end;

begin
end.