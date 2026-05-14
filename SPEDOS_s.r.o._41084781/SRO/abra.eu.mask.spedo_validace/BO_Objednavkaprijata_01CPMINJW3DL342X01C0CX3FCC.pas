const
msql_ext_num= 'SELECT ExternalNumber FROM ReceivedOrders where ExternalNumber= ''%s'' ORDER BY ExternalNumber DESC' ;



{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
mr: TStringList;
begin
if self.GetFieldValueAsString('ExternalNumber')<>'' then begin
    if osNew in Self.State then begin  // při založení nové objednávky
        mR := TstringList.Create;
        try
            self.ObjectSpace.SQLSelect(Format(msql_ext_num, [self.GetFieldValueAsString('ExternalNumber')]), mR);   //kontrola Externího čísla
            if mR.Count>0 then begin
                self.AddValidateError(self.GetFieldCode('ExternalNumber'),'Pro uvedené externí číslo ' + mR.Strings[0] + ' již existuje doklad');       // cy
                aresult:=False;
                exit;
            end;
        finally
        mr.Free;
        end;
    end;
end;
end;

begin
end.