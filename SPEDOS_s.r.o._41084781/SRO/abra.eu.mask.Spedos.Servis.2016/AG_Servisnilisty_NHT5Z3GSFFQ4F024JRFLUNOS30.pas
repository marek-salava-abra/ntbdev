


procedure _AfterSave_PostHook(msite: TDynSiteForm);
var
  i: integer;
  self,mBO_ml:TNxCustomBusinessObject;
  mr,mr2:TStringList;
begin
  self:=msite.CurrentObject;

   mr:=TStringList.Create;
                            try
                               self.ObjectSpace.SQLSelect('select id from ServiceAssemblyForms where ServiceDocument_ID=' + QuotedStr(self.oid),mr);
                               if mr.count=0 then begin
                                  mBO_ml:=self.ObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                                  try
                                      mBO_ml.new;
                                      mbo_ml.Prefill;
                                      mBO_ml.SetFieldValueAsString('ServiceDocument_ID',self.oid);
                                      mBO_ml.SetFieldValueAsInteger('OrdNumber',mr.count+1);
                                      mr2:=TStringList.Create;
                                      try
                                          self.ObjectSpace.SQLSelect('select id from ServiceWorkSpaces where code=' + QuotedStr(self.GetFieldValueAsString('Division_ID.code')),mr2);
                                          if mr2.count=1 then begin
                                             mBO_ml.SetFieldValueAsString('ServiceWorkSpace_ID',mr2.Strings[0]);
                                          end;
                                      finally
                                         mr2.free;
                                      end;
                                      mBO_ml.SetFieldValueAsinteger('AssemblyState',0);
                                      mBO_ml.SetFieldValueAsstring('X_State','3XQ1000101');
                                      mBO_ml.SetFieldValueAsstring('X_id_zakaznika_id',self.GetFieldValueAsString('X_id_zakaznika_id'));
                                      mBO_ml.SetFieldValueAsstring('X_ServicedObject_ID',self.GetFieldValueAsString('ServicedObject_ID'));
                                      mBO_ml.SetFieldValueAsDateTime('StartDate$DATE',self.GetFieldValueAsDateTime('docdate$date'));
                                      mBO_ml.SetFieldValueAsDateTime('EndDate$DATE',self.GetFieldValueAsDateTime('PromisedDeadLine$DATE'));
                                      mBO_ML.SetFieldValueAsstring('X_Docqueue_ID',self.GetFieldValueAsString('Docqueue_ID'));
                                      mBO_ML.SetFieldValueAsInteger('X_Ordnumber',self.GetFieldValueAsInteger('Ordnumber'));
                                      mBO_ML.SetFieldValueAsstring('X_Period_ID',self.GetFieldValueAsString('Period_ID'));
                                      mr2:=TStringList.Create;
                                      try
                                          self.ObjectSpace.SQLSelect('select id from SecurityRoles where ShortName=' + QuotedStr(self.GetFieldValueAsString('Division_ID.code')),mr2);
                                          if mr2.count=1 then begin
                                             mBO_ml.SetFieldValueAsString('ResponsibleRole_ID',mr2.Strings[0]);
                                          end;
                                      finally
                                         mr2.free;
                                      end;
                                      mBO_ml.save;
                                  finally
                                     mBO_ml.free;
                                  end;
                               end;
                            finally
                                mr.free;
                            end;


end;
begin
end.