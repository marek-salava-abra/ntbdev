{
Vyvolává se před fyzickým vymazáním vlastního objektu z databáze.
}
procedure BeforeDelete_Hook(Self: TNxCustomBusinessObject);
var
mi:integer;
begin
   mi:=self.ObjectSpace.SQLExecute('update receivedorders2 set X_Pozice_OD=' + QuotedStr('') + ' where X_Pozice_OD=' + quotedstr(self.oid));
end;



procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
var
mr:tstringlist;
begin

   if NxIsBlank(self.getFieldValueAsString('X_field5')) then begin
            mr:=TStringList.create;
            try
                  self.ObjectSpace.SQLSelect('Select ro.id from receivedorders RO left join receivedorders2 RO2 on RO2.parent_ID=RO.ID where ro2.X_Pozice_OD=' + QuotedStr(self.oid),mr);
                  if mr.count=0 then begin

                  end else begin
                      self.SetFieldValueAsString('X_field5',mr.Strings[0]);
                  end;
            finally
                mr.free;
            end;
    end;
end;


procedure BeforeSoftValidate_Hook(Self: TNxCustomBusinessObject);
var
mr:tstringlist;
begin

   if NxIsBlank(self.getFieldValueAsString('X_field5')) then begin
            mr:=TStringList.create;
            try
                  self.ObjectSpace.SQLSelect('Select ro.id from receivedorders RO left join receivedorders2 RO2 on RO2.parent_ID=RO.ID where ro2.X_Pozice_OD=' + QuotedStr(self.oid),mr);
                  if mr.count=0 then begin

                  end else begin
                      self.SetFieldValueAsString('X_field5',mr.Strings[0]);
                  end;
            finally
                mr.free;
            end;
    end;
end;

begin
end.