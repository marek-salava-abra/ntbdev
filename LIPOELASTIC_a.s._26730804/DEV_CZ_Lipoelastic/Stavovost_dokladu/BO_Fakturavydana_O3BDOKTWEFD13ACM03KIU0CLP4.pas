
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
  var
mbo:TNxCustomBusinessObject;
mr:tstringlist;
i:integer;
begin
  if NxCreateContext(self.ObjectSpace).GetCompanyCache.GetUserID='SUPER00000' then begin
      mr:=tstringlist.create;
              try
                       self.ObjectSpace.SQLSelect('Select sd2.Provide_ID from issuedinvoices2 II2 join Storedocuments2 SD2 on sd2.id=II2.ProvideRow_ID where ii2.parent_id=' + QuotedStr(self.oid)+ ' group by sd2.Provide_ID',mr);
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