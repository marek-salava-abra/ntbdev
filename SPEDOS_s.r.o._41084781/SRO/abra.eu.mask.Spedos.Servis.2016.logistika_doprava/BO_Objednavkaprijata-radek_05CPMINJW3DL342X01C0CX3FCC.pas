
//procedure _AfterDataChange_PostHook(Self: TNxCustomBusinessObject);
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
var
mresult:boolean;
mi:integer;
mvzdalenost:string;
begin
 if self.GetFieldValueAsString('parent_id.docqueue_ID')='2I00000101' then begin
      if not NxIsEmptyOID(self.GetFieldValueAsstring('X_Vzdalenost_psc')) then begin
          if self.GetFieldValueAsInteger('parent_id.U_nakladka')=1 then begin
                  if self.GetFieldValueAsFloat('X_Vzdalenost_psc.X_vzdalenost_Spedos')<2 then begin
                       mresult:=InputQuery('Zadejte vzdálenost','Vzdálenost ze Spedosu',mvzdalenost);
                       if mresult then begin
                           mi:=self.ObjectSpace.SQLExecute('update PostOffices set X_vzdalenost_spedos=' + mvzdalenost +
                            ' where id=' + quotedstr(self.GetFieldValueAsString('X_Vzdalenost_psc')))
                       end;
                  end;
          end;
          if self.GetFieldValueAsInteger('parent_id.U_nakladka')=2 then begin
                  if self.GetFieldValueAsFloat('X_Vzdalenost_psc.X_vzdalenost_Jezerany')<2 then begin
                       mresult:=InputQuery('Zadejte vzdálenost','Vzdálenost ze Jezeřan',mvzdalenost);
                       if mresult then begin
                           mi:=self.ObjectSpace.SQLExecute('update PostOffices set X_vzdalenost_Jezerany=' + mvzdalenost +
                            ' where id=' + quotedstr(self.GetFieldValueAsString('X_Vzdalenost_psc')))
                       end;
                  end;
          end;
          if self.GetFieldValueAsInteger('parent_id.U_nakladka')=3 then begin
                  if self.GetFieldValueAsFloat('X_Vzdalenost_psc.X_vzdalenost_Hlucinka')<2 then begin
                       mresult:=InputQuery('Zadejte vzdálenost','Vzdálenost z Hlučinky',mvzdalenost);
                       if mresult then begin
                           mi:=self.ObjectSpace.SQLExecute('update PostOffices set X_vzdalenost_Hlucinka=' + mvzdalenost +
                            ' where id=' + quotedstr(self.GetFieldValueAsString('X_Vzdalenost_psc')))
                       end;
                  end;
          end;
      end;
  end;
end;

begin
end.