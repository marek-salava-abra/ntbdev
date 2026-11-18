
{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
  var
mbo:TNxCustomBusinessObject;
mr:tstringlist;
i:integer;
begin
  if NxCreateContext(self.ObjectSpace).GetCompanyCache.GetUserID='SUPER00000' then begin

mr:=tstringlist.create;
        try
                 self.ObjectSpace.SQLSelect('Select Provide_ID from Storedocuments2 where parent_id=' + QuotedStr(self.oid) + ' group by Provide_ID' ,mr);
                 if mr.count>0 then begin
                       mbo:=self.ObjectSpace.CreateObject('01CPMINJW3DL342X01C0CX3FCC');
                       for i := 0 to mr.Count - 1 do begin
                             if not NxIsEmptyOID(mr.strings[i]) then begin
                                if (mr.strings[i]<>'0000000000') and (mr.strings[i]<>'') then begin
                                   try
                                       mbo.load(mr.Strings[i],nil);
                                       mbo.save;
                                   finally

                                   end;
                                   //NxShowSimpleMessage('Zapis DL',nil);
                                end;
                             end;
                       end;
                 end;


        finally
            mr.free;
        end;
        end;
end;




begin
end.