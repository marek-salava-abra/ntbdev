{
Vyvolává se po uložení vlastních dat objektu do databáze.
}



procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var mr:tstringlist;
  mi,i:integer;
begin
mr:=TStringList.create;
            try
                  self.ObjectSpace.SQLSelect('select a.id||sd2.store_id from GeneralLedger A LEFT JOIN AccDocQueues ADQ ON ADQ.ID=A.AccDocQueue_ID LEFT JOIN Relations R ON R.RightSide_ID = A.ID '
                              + ' join relations Re on A.id=re.rightside_id join storedocuments2 sd2 on sd2.Parent_id=re.leftside_id '


                      + ' WHERE (A.AccDocQueue_ID IN (SELECT ID FROM  AccDocQueues WHERE DocumentType IN ('
                      +quotedstr('20') + ',' + quotedstr('21') + ',' + quotedstr('22') + ',' + quotedstr('23') + ',' + quotedstr('24') + ','
                      +quotedstr('25') + ',' + quotedstr('26') + ',' + quotedstr('27') + ',' + quotedstr('28') + ',' + quotedstr('29') + ','
                      +quotedstr('30') + ',' + quotedstr('36') + ',' + quotedstr('37') + ',' + quotedstr('38') + ',' + quotedstr('39') +'))) and a.X_store_ID is null'
                       + ' and a.id=' + quotedstr(self.oid)
                       ,mr);
                      if mr.count>0 then begin
                              for i:=0 to mr.count-1 do begin
                                  mi:=self.ObjectSpace.SQLExecute('update GeneralLedger set X_store_ID=' + QuotedStr(copy(mr.Strings[i],11,10)) + ' where id=' + quotedstr(copy(mr.Strings[i],1,10)))
                              end;

                      end;

            finally
                mr.free;
            end;
end;

begin
end.