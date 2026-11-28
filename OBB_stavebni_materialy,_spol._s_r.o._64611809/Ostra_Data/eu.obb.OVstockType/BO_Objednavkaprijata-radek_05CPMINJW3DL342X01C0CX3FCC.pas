{
Vyvolává se bezprostředně před provedením softvalidace objektu.
}
procedure _BeforeValidate_PostHook(Self: TNxCustomBusinessObject);
begin
   if self.GetFieldValueAsInteger('RowType')<3 then begin

    self.SetFieldValueAsString('X_StockType_ID','1000000101');
  end;
end;



begin
end.