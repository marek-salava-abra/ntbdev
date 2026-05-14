{
Umožňuje ovlivnit to, zda je možné objekt vymazat.
}
procedure CanDelete_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
mr:tstringlist;
begin
    mr:=tstringlist.Create;
    try
        self.ObjectSpace.SQLSelect('select max(DateTo$DATE) from VATClosings',mr);
        if StrToInt(mr.Strings[0]) = trunc(self.GetFieldValueAsDateTime('DateTo$DATE')) then begin
             aresult:=true;
        end else begin
            if InputQuery('Potvrzení','Uzávěrka není poslední, chcete přesto smazat?','') then begin
                AResult:=true;
            end else begin
                AResult:=false;
            end;
        end;
    finally
        mr.free;
    end;
end;

begin
end.