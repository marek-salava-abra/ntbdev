{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mList:TStringList;
 mStoreCardBO:TNxCustomBusinessObject;
begin
 if not(self.GetFieldValueAsString('Store_ID')='5R10000101') then begin
  mList:=TStringList.Create;
  if self.GetFieldValueAsBoolean('StoreCard_ID.U_SendToES') then begin
     self.ObjectSpace.SQLSelect(Format('Select sum(Quantity) from storesubcards where storecard_id=''%s'' and not(store_id=''5R10000101'') ',[self.GetFieldValueAsString('StoreCard_ID')]),mList);
     if StrToFloat(mList.strings[0])=0 then
        self.ObjectSpace.SQLExecute('update storecards set X_ZeroDay='+NxFloatToIBStr(Now)+' where id='+QuotedStr(self.GetFieldValueAsString('StoreCard_ID')));
  end;
 end;
end;

begin
end.