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
               self.ObjectSpace.SQLSelect('SELECT distinct id as hodnota FROM DefRollData where CLSID=' + quotedstr('EC2R2HSFK5UOZ5MYVJWJOHUC4S') +
                ' and code='+quotedstr(self.oid) ,mr);

                if mr.count>0 then begin
                     mi:=self.ObjectSpace.SQLExecute('delete FROM DefRollData where CLSID=' + quotedstr('EC2R2HSFK5UOZ5MYVJWJOHUC4S') + ' and code='+quotedstr(self.oid));
                end;
           finally
               mr.free;
           end;


end;





{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
i ,mi: integer;
mr:tstringlist;
  mBO, mBO_PohybSarze, mBO_Sarze : TNxCustomBusinessObject;
  mMon : TNxCustomBusinessMonikerCollection;
begin
 // if self.GetFieldValueAsString('Createdby_ID')='SUPER00000' then begin
        mBO := self;
                          mMon := mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('ROWS'));
                          for i := 0 to mMon.Count - 1 do begin
                            if mMon.BusinessObject[i].getFieldValueAsInteger('Storecard_ID.category')=2 then begin
                                 //NxShowSimpleMessage('Sarže',msite);
                                 mr:= tstringlist.create;
                                 try
                                      self.ObjectSpace.SQLSelect('Select a.id from DefRollData A WHERE A.CLSID = ' + quotedstr('EC2R2HSFK5UOZ5MYVJWJOHUC4S') +
                                      ' AND (A.X_parent_id =' + QuotedStr(mMon.BusinessObject[i].OID) + ') and (a.code<>' + quotedstr(mbo.OID)+')' ,mr);
                                      if mr.count>0 then begin
                                        //if self.GetFieldValueAsString('Createdby_ID')='SUPER00000' then NxShowSimpleMessage(mr.strings[0],nil);
                                           self.ObjectSpace.SQLExecute('update DefRollData set X_parent_ID=null WHERE CLSID = ' + quotedstr('EC2R2HSFK5UOZ5MYVJWJOHUC4S') +
                                      ' AND (X_parent_id =' + QuotedStr(mMon.BusinessObject[i].OID) + ') and (code<>' + quotedstr(mbo.OID)+')');
                                      end;
                                 finally
                                     mr.free;
                                 end;
                             end;
                          end;
//    end;
end;



begin
end.