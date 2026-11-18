uses 'EU.Aabra.Mask.Validace.lib';

procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
mr:tstringlist;
begin
  if not (osnew in self.State) then begin
     //firma
     mr:=tstringlist.create;
        try

             self.ObjectSpace.SQLSelect('select sd.id from storedocuments sd left join issuedinvoices2 ii2 on sd.id=ii2.Provide_ID left join issuedinvoices ii on ii.id=ii2.parent_id where ' +
                                        ' ii.id=' + quotedstr(self.oid) + ' and sd.firm_ID<>' + quotedstr(self.GetFieldValueAsString('firm_ID')) + ' group by sd.ID',mr);
             if mr.count>0 then begin

                  if NxGetActualUserID(self.ObjectSpace)<>'SUPER00000' then begin
                      //AResult := False;
                      Self.AddValidateError(Self.GetFieldCode('firm_ID'), 'NA DL je použita jiná firma než na FV');
                      NxShowSimpleMessage('NA DL je použita jiná firma než na FV',nil);
                  end;
                  //NxShowSimpleMessage('existuje více firem na DL',nil);
             end;
        finally
          mr.free;
        end;

     //provozovny

        mr:=tstringlist.create;
        try

             self.ObjectSpace.SQLSelect('select sd.id from storedocuments sd left join issuedinvoices2 ii2 on sd.id=ii2.Provide_ID left join issuedinvoices ii on ii.id=ii2.parent_id where ' +
                                        ' ii.id=' + quotedstr(self.oid) + ' and sd.FirmOffice_ID<>' + quotedstr(self.GetFieldValueAsString('FirmOffice_ID')) + ' group by sd.ID',mr);
             if mr.count>0 then begin
                  if NxGetActualUserID(self.ObjectSpace)<>'SUPER00000' then begin
                      //AResult := False;
                      Self.AddValidateError(Self.GetFieldCode('FirmOffice_ID'), 'NA DL je použita jiná provozovna než na FV');
                      NxShowSimpleMessage('Na DL je použita jiná provozovna než na FV',nil);
                  end;
             end;
        finally
          mr.free;
        end;

     //datum plnění


       mr:=tstringlist.create;
        try

             self.ObjectSpace.SQLSelect('select sd.id from storedocuments sd left join issuedinvoices2 ii2 on sd.id=ii2.Provide_ID left join issuedinvoices ii on ii.id=ii2.parent_id where ' +
                                        ' ii.id=' + quotedstr(self.oid) + ' and sd.DOCDate$DATE>' + quotedstr(
                                        inttostr(trunc(StrToDate(
                                        self.GetFieldValueAsString('VATDate$DATE')))+1)

                                        ) + ' group by sd.ID',mr);
             if mr.count>0 then begin
                AResult := False;
                Self.AddValidateError(Self.GetFieldCode('VATDate$DATE'), 'NA DL je uvedeno vyšší datum než je datum plnění');
             end;
        finally
          mr.free;
        end;
    end else begin
  //  self.setFieldValueAsDateTime('Docdate$date',now());

  end;
  if not self.GetFieldValueAsBoolean('VATDocument') then begin
       self.SetFieldValueAsBoolean('VATDocument',True) ;

  end;





end;









begin
end.