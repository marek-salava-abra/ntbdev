{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
{
Vyvolává se po fyzickém vymazání vlastního objektu z databáze.
}
procedure AfterDelete_Hook(Self: TNxCustomBusinessObject);
var
mi:integer;
begin
      mi:=self.ObjectSpace.SQLExecute('update issuedinvoices set X_uzamceno=''N'' where DocDate$DATE>=' +
               NxFloatToIBStr(self.GetFieldValueAsDateTime('DateFrom$DATE')) +
               ' and DocDate$DATE<=' + NxFloatToIBStr(self.GetFieldValueAsDateTime('DateTo$DATE'))) ;


end;

procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
mi:integer;
begin
      mi:=self.ObjectSpace.SQLExecute('update issuedinvoices set X_uzamceno=''A'' where DocDate$DATE>=' +
               NxFloatToIBStr(self.GetFieldValueAsDateTime('DateFrom$DATE')) +
               ' and DocDate$DATE<=' + NxFloatToIBStr(self.GetFieldValueAsDateTime('DateTo$DATE'))) ;

end;




begin
end.

