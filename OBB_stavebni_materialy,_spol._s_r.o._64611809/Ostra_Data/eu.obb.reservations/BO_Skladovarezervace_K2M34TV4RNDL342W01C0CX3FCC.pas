{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
var
 mRowBO:TNxCustomBusinessObject;
begin
  if self.GetFieldValueAsFloat('Supplied')>0 then begin
    mRowBO:=self.ObjectSpace.CreateObject(Class_ReceivedOrderRow);
    mRowBO.Load(self.GetFieldValueAsString('Owner_ID'),nil);
    if mRowBO.GetFieldValueAsString('X_StockType_ID')='2000000101' then begin
      self.SetFieldValueAsFloat('Reserved',self.GetFieldValueAsFloat('Supplied'));
    end;
    mRowBO.free;
  end;
end;

begin
end.