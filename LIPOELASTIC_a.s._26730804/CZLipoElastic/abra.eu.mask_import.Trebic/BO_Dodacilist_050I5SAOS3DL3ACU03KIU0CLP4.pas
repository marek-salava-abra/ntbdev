

{
Vyvolává se po fyzickém vymazání vlastního objektu z databáze.
}
procedure AfterDelete_Hook(Self: TNxCustomBusinessObject);
var
mMon:TNxCustomBusinessMonikerCollection;
i:integer;
ii:integer;
begin
mMon := Self.GetLoadedCollectionMonikerForFieldCode(Self.GetFieldCode('ROWS'));
            if mMon.count>0 then begin
                 try
                    ii:= self.ObjectSpace.SQLExecute('update receivedorders set closed=''N'' where id=' + QuotedStr(mMon.BusinessObject[0].GetFieldValueAsString('Provide_ID')));
                 finally

                 end;
            end;
end;

begin
end.