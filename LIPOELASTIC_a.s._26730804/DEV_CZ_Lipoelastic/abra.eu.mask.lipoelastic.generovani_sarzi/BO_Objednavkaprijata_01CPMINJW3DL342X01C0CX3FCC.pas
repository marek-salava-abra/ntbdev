


{
Vyvolává se po fyzickém vymazání vlastního objektu z databáze.
}
procedure AfterDelete_Hook(Self: TNxCustomBusinessObject);
var
mr:tstringlist;
mi:integer;
begin
       mr:=TStringList.create;
           try
               self.ObjectSpace.SQLSelect('SELECT distinct id as hodnota FROM DefRollData where CLSID=' + quotedstr('SLARSB0H4CK4T32XPZTP33J3XS') +
                ' and code='+quotedstr(self.oid) ,mr);

                if mr.count>0 then begin
                     mi:=self.ObjectSpace.SQLExecute('delete FROM DefRollData where CLSID=' + quotedstr('SLARSB0H4CK4T32XPZTP33J3XS') + ' and code='+quotedstr(self.oid));
                end;
           finally
               mr.free;
           end;


end;

begin
end.