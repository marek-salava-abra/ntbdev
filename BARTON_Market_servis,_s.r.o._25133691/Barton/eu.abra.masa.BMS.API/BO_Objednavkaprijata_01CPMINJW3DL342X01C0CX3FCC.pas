uses '.lib';

procedure AfterDelete_Hook(Self: TNxCustomBusinessObject);
var
 mJSON:TJSONSuperObject;
 mIDBMS:string;
begin
  self.GetOriginalValue('X_IssuedOrderID',mIDBMS);
  if not(NxIsEmptyOID(mIDBMS)) then begin
     mJSON:=TJSONSuperObject.Create;
     mJSON.S['X_ExternalDocument']:='';
     mJSON.DT8601['X_SentDate$Date']:=0;
     API_PUT(mJSON, 'IssuedOrders', mIDBMS);
  end;
end;



{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mBool:Boolean;
 mJSON:TJSONSuperObject;
 mIDBMS:string;
begin
  self.GetOriginalValue_3('Confirmed',mBool);
  if not(mBool) and self.GetFieldValueAsBoolean('Confirmed') then begin
    mIDBMS:=self.GetFieldValueAsString('X_IssuedOrderID');
    if not(NxIsEmptyOID(mIDBMS)) then begin
     mJSON:=TJSONSuperObject.Create;
     mJSON.B['Confirmed']:=self.GetFieldValueAsBoolean('Confirmed');
     API_PUT(mJSON, 'IssuedOrders', mIDBMS);
    end;
  end;
end;

begin
end.