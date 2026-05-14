procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
mi:integer;
mr2,mr:TStringList;
i:integer;
begin
{if self.GetFieldValueAsString('ActivityType_ID')='1100000101' then begin
       if self.GetFieldValueAsString('ActQueue_ID')<>'D100000101' then begin
                  mr2:=TStringList.create;
                  try
                      self.ObjectSpace.SQLSelect('select sa2.ID from CRMActivities A left join ServiceAssemblyForms2 Sa2 on SA2.id=A.X_parent_ID where sa2.parent_ID=(select max(parent_id) from ServiceAssemblyForms2 where id='
                      + quotedstr(self.GetFieldValueAsString('X_parent_id'))+')',mr2);
                      if mr2.count>0 then begin
                          if mr2.count>1 then begin
                              //NxShowSimpleMessage('Na práci je delegováno vícero techniků'+'přesunout všechny techniky'+'Ano',nil) ;
                              if true then begin
                                 //for i:=0 to mr2.count-1 do begin
                                     mr:=TStringList.create;
                                     try
                                         self.ObjectSpace.SQLSelect('Select X_konec_prace from ServiceAssemblyForms2 where parent_id='+quotedstr(self.getfieldvalueasstring('X_Parent_head')),mr) ;
                                         if mr.count>0 then begin
                                              if FloatToDateTime(NxIBStrToFloat(mr.Strings[0]))<>self.getfieldvalueasdatetime('SheduledEnd$Date') then begin
                                                    mi:=self.ObjectSpace.SQLExecute('Update ServiceAssemblyForms2 set X_konec_prace=' + NxFloatToIBStr(trunc(self.getfieldvalueasdatetime('SheduledEnd$Date'))) +'.'+copy(floattostr(frac(self.getfieldvalueasdatetime('SheduledEnd$Date'))),3,10) + ' where parent_id='+quotedstr(self.getfieldvalueasstring('X_Parent_head'))) ;
                                              end;
                                         end;
                                     finally
                                         mr.free;
                                     end;
                                     //mi:=self.ObjectSpace.SQLExecute('Update ServiceAssemblyForms2 set X_konec_prace=' + floattostr(trunc(self.getfieldvalueasdatetime('SheduledEnd$Date'))) +'.'+copy(floattostr(frac(self.getfieldvalueasdatetime('SheduledEnd$Date'))),3,10) + ' where id='+quotedstr(mr2.Strings[i])) ;
                                 //end;
                              end else begin
                                   mi:=self.ObjectSpace.SQLExecute('Update ServiceAssemblyForms2 set X_konec_prace=' + floattostr(trunc(self.getfieldvalueasdatetime('SheduledEnd$Date'))) +'.'+copy(floattostr(frac(self.getfieldvalueasdatetime('SheduledEnd$Date'))),3,10) + ' where parent_id='+quotedstr(self.getfieldvalueasstring('X_Parent_head'))) ;
                              end;
                           end;
                         // mi:=self.ObjectSpace.SQLExecute('update CRMActivities A set A.SheduledEnd$Date='+ floattostr(trunc(self.getfieldvalueasdatetime('SheduledEnd$Date'))) +'.'+copy(floattostr(frac(self.getfieldvalueasdatetime('RealEnd$Date'))),3,10)    +
                         // ' and A.id<>' +quotedstr(self.oid) + ' and a.X_Parent_head=' + quotedstr(self.GetFieldValueAsString('X_Parent_head'))+')');
                         // mi:=self.ObjectSpace.SQLExecute('update CRMActivities A set A.SheduledStart$Date='+ floattostr(trunc(self.getfieldvalueasdatetime('SheduledEnd$Date'))) +'.'+copy(floattostr(frac(self.getfieldvalueasdatetime('RealStart$Date'))),3,10)    +
                         // ' and A.id<>' +quotedstr(self.oid) + ' and a.X_Parent_head=' + quotedstr(self.GetFieldValueAsString('X_Parent_head'))+')');
                      end;
                  finally
                      mr2.free;
                  end;
            try
            mr:=TStringList.create;
                                     try
                                         self.ObjectSpace.SQLSelect('Select X_WorkerRole_ID from ServiceAssemblyForms2 where id='+quotedstr(self.getfieldvalueasstring('X_Parent_ID')),mr) ;
                                         if mr.count>0 then begin
                                              if mr.Strings[0]<>self.getfieldvalueasstring('SolverRole_ID') then begin
                                                    mi:=self.ObjectSpace.SQLExecute('Update ServiceAssemblyForms2 set WorkerRole_ID=' + quotedstr(self.getfieldvalueasstring('SolverRole_ID')) +
                                                    ' where id=' +quotedstr(self.getfieldvalueasstring('X_parent_ID'))) ;
                                                    mi:=self.ObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_Monter1_ID=' + quotedstr(self.getfieldvalueasstring('SolverRole_ID')) +
                                                          ' where id=' +quotedstr(self.getfieldvalueasstring('X_parent_head'))) ;

                                              end;
                                         end;
                                     finally
                                         mr.free;
                                     end;

            mr:=TStringList.create;
                                     try
                                         self.ObjectSpace.SQLSelect('Select X_konec_prace from ServiceAssemblyForms2 where parent_id='+quotedstr(self.getfieldvalueasstring('X_Parent_head')),mr) ;
                                         if mr.count>0 then begin
                                              if FloatToDateTime(NxIBStrToFloat(mr.Strings[0]))<>self.getfieldvalueasdatetime('SheduledEnd$Date') then begin
                                                    mi:=self.ObjectSpace.SQLExecute('Update ServiceAssemblyForms2 set X_konec_prace=' + floattostr(trunc(self.getfieldvalueasdatetime('SheduledEnd$Date'))) +'.'+copy(floattostr(frac(self.getfieldvalueasdatetime('SheduledEnd$Date'))),3,10) + ' where id='+quotedstr(self.getfieldvalueasstring('X_parent_ID'))) ;
                                                    mi:=self.ObjectSpace.SQLExecute('Update ServiceAssemblyForms set EndDate$DATE=' + floattostr(trunc(self.getfieldvalueasdatetime('SheduledEnd$Date'))) +'.'+copy(floattostr(frac(self.getfieldvalueasdatetime('SheduledEnd$Date'))),3,10) + ' where id='+quotedstr(self.getfieldvalueasstring('X_parent_head'))) ;
                                                    mi:=self.ObjectSpace.SQLExecute('Update ServiceAssemblyForms set StartDate$DATE=' + floattostr(trunc(self.getfieldvalueasdatetime('SheduledStart$Date'))) +'.'+copy(floattostr(frac(self.getfieldvalueasdatetime('SheduledStart$Date'))),3,10) + ' where id='+quotedstr(self.getfieldvalueasstring('X_parent_head'))) ;

                                              end;
                                         end;
                                     finally
                                         mr.free;
                                     end;


            finally
            end;
       end;
  end;
      }
end;



begin
end.

