{
Vyvolává se po fyzickém vymazání vlastního objektu z databáze.
}
procedure AfterDelete_Hook(Self: TNxCustomBusinessObject);
begin
  self.ObjectSpace.SQLExecute('Delete from defrolldata where x_value_id='+QuotedStr(self.OID)+' and clsid='+Quotedstr('2TIIQXNXIXK4B5CZUIZ20K2W10'));
end;

begin
end.