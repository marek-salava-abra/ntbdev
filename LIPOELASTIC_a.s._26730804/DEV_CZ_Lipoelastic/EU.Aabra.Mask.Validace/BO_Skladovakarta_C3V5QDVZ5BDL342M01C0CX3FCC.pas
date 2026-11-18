{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
mstring:string;
mr:tstringlist;
i:integer;
os:TNxCustomObjectSpace;
mtext:string;
begin
mstring:='';
  if ((AnsiPos(chr(13),self.GetFieldValueAsString('EAN'))>0) or (AnsiPos(chr(10),self.GetFieldValueAsString('EAN'))>0))  then begin
      NxShowSimpleMessage('V EAN jsou netisknutelné znaky bránící uložení záznamu , budou odstraněny ',nil);
      mstring:= self.GetFieldValueAsString('EAN');
      mstring:=ReplaceText(mstring,chr(13),'');
      mstring:=ReplaceText(mstring,chr(10),'');
      self.setFieldValueAsString('EAN',mstring);
  end;

end;







{
Vyvolává se bezprostředně před provedením metody SoftDelete.
}
{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
  mr:tstringlist;
  i:integer;
  mBO:TNxCustomBusinessObject;
begin
    if self.GetFieldValueAsBoolean('X_E_commerce') then begin
        mr:=TStringList.Create;
        try
            {self.ObjectSpace.SQLSelect('Select id from storecards where X_parent_id=' + QuotedStr(self.oid),mr);
             }
            self.ObjectSpace.SQLSelect('select sc.id from storecards sc  '+
                                       'left join USERDATA UD2 on 2000024=UD2.FIELDCODE AND '+ QuotedStr('C3V5QDVZ5BDL342M01C0CX3FCC')+'=UD2.CLSID AND sc.ID = ud2.id '+
                                       'left join Defrolldata v on UD2.StringFieldValue COLLATE Czech_CS_AS=v.id '+
                                       'where sc.X_parent_id=' + QuotedStr(self.oid) +' and (v.name<>''CUSTOMIZE'' or v.name is null)', mR);

                if mr.count>0 then begin
                      for i:=0 to mr.count-1 do begin
                          mbo:=self.ObjectSpace.CreateObject('C3V5QDVZ5BDL342M01C0CX3FCC');
                          try
                                mbo.load(mr.strings[i],nil);
                                  mbo.SetFieldValueAsBoolean('X_E_commerce',self.GetFieldValueAsBoolean('X_E_commerce'));
                                  mbo.save;
                           finally
                                mbo.free;
                           end;
                      end;

                end;

        finally
            mr.free;
        end;
    end;
end;

procedure BeforeSoftDelete_Hook(Self: TNxCustomBusinessObject);
var
mr:tstringlist;
i:integer;
os:TNxCustomObjectSpace;
mtext:string;
begin

end;

begin
end.





begin
end.