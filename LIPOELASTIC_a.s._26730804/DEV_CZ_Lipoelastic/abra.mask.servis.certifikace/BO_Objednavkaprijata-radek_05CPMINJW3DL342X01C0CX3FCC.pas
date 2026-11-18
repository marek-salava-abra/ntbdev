uses 'EU.Aabra.Mask.Validace.lib';

 procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
mr:TStringList;
begin

        if self.GetFieldValueAsinteger('RowType') = 3 then begin
                if self.GetFieldValueAsString('Storecard_ID.X_obchodni_pripad') = '2N10000101' then begin
                    if not NxIsEmptyOID(self.GetFieldValueAsString('parent_ID.person_ID')) then begin
                            mr:=TStringList.Create;
                            try
                            //     self.ObjectSpace.SQLSelect('SELECT A.ID FROM DefRollData A WHERE A.CLSID = ' + quotedstr('LZVISPIWYGE4HIAJ5PX0LGPWWC') +
                            //       ' AND ((exists (SELECT 1 FROM USERDATA WHERE FIELDCODE=2000003 AND CLSID=' + quotedstr('LZVISPIWYGE4HIAJ5PX0LGPWWC') +
                            //     ' AND ID = A.ID AND (STRINGFIELDVALUE = ' + quotedstr(self.GetFieldValueAsString('Parent_id.Person_id')) +
                            //     '))) AND (exists (SELECT 1 FROM USERDATA WHERE FIELDCODE=2000007 AND CLSID=' + quotedstr('LZVISPIWYGE4HIAJ5PX0LGPWWC') +
                            //     ' AND ID = A.ID AND (STRINGFIELDVALUE = ' + quotedstr('2N10000101') + '))) )',mr);



        self.ObjectSpace.SQLSelect('SELECT a.id FROM DefRollData A WHERE  A.CLSID = ''LZVISPIWYGE4HIAJ5PX0LGPWWC'' AND (a.X_person_ID='+quotedstr(self.GetFieldValueAsString('parent_ID.person_ID'))+' AND (exists (SELECT 1 FROM USERDATA WHERE FIELDCODE=2000003 AND CLSID=''LZVISPIWYGE4HIAJ5PX0LGPWWC'' AND ID = A.ID AND (  ( STRINGFIELDVALUE = ''5'' ) ))))' ,mr);






                                 if mr.count=0 then begin
                                          Self.AddValidateError(Self.GetFieldCode('itemtype'), 'Položka osoba ' + self.GetFieldValueAsString('parent_ID.person_ID.Lastname') +' nemá certifikaci.');
                                          //NxShowSimpleMessage('Osoba necertifikovaná',nil);
                                          AResult:=false;
                                 end else begin
                                          Self.ClearValidateErrors;
                                          //NxShowSimpleMessage('Osoba certifikovaná',nil);
                                          AResult := true;
                                 end;
                            finally
                                mr.free;
                            end;
                     end else begin

                            Self.AddValidateError(Self.GetFieldCode('Storecard_ID'), 'Položka osoba je nutná pro certifikaci.');
                            AResult:=false;
                     end;

                  end;
          end;


end;


begin
end.