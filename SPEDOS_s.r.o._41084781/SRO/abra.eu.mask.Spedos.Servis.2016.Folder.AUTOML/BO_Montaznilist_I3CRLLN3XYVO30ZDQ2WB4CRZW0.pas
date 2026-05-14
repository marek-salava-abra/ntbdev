  uses 'abra.eu.mask.Spedos.Servis.2016_funkce.const',
       'abra.eu.mask.Spedos.Servis.2016_funkce.funkce';

const
  constStoragePath = '\\192.168.0.36\abra\Servis';
  constNewDirStr = '%s\%s';




procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
  mCode: integer;
  mresult:Boolean;
begin
  // Zjistime kod polozky Nazev


                        if DirectoryExists(Format('%s', [constStoragePath]))  then begin   // uloziste je pristupne
                                mResult:=DirectoryExists(Format('%s\%s', [constStoragePath, self.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID')]));
                                if  not mresult then begin    // servisovaný objekt
                                        mResult:=NxCreateDir(Format('%s\%s', [constStoragePath, self.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID')]));
                                        //ShowMessage(Format('%s\%s', [constStoragePath, self.GetFieldValueAsString('ServicedObject_ID')]));

                                end;
                                mResult:=DirectoryExists(Format('%s\%s\%s', [constStoragePath, self.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID'),'Servisni listy']));
                                if not mresult then begin    // servisní list
                                        mResult:=NxCreateDir(Format('%s\%s\%s', [constStoragePath, self.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID'),'Servisni listy']));
                                        //ShowMessage(Format('%s\%s\%s', [constStoragePath, self.GetFieldValueAsString('ServicedObject_ID'),'Servisni listy']));

                                end;
                                mResult:=DirectoryExists(Format('%s\%s\%s\%s', [constStoragePath, self.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID'),'Servisni listy',self.GetFieldValueAsString('ID')]));
                                if not mresult then begin    // servisní list
                                        mResult:=NxCreateDir(Format('%s\%s\%s\%s', [constStoragePath, self.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID'),'Servisni listy',self.GetFieldValueAsString('ServiceDocument_ID')]));
                                end;
                                mResult:=DirectoryExists(Format('%s\%s\%s\%s\%s', [constStoragePath, self.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID'),'Servisni listy',self.GetFieldValueAsString('ServiceDocument_ID'),'ML']));
                                if not mresult then begin    // servisní list
                                        mResult:=NxCreateDir(Format('%s\%s\%s\%s\%s', [constStoragePath, self.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID'),'Servisni listy',self.GetFieldValueAsString('ServiceDocument_ID'),'ML']));
                                end ;

                                mResult:=DirectoryExists(Format('%s\%s\%s\%s\%s\%s', [constStoragePath, self.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID'),'Servisni listy',self.GetFieldValueAsString('ServiceDocument_ID'),'ML',self.oid]));
                                if not mresult then begin    // servisní list
                                        mResult:=NxCreateDir(Format('%s\%s\%s\%s\%s\%s', [constStoragePath, self.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID'),'Servisni listy',self.GetFieldValueAsString('ServiceDocument_ID'),'ML',self.oid]));
                                end ;


  end;
  end;

procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
  mCode: integer;
  mresult:Boolean;
  mfile:string;
  mi:integer;
begin
  // Zjistime kod polozky Nazev
  mCode := Self.GetFieldCode('X_protokol');
  if AFieldCode = mCode then begin
    if length(trim(AValue.AsString)) = 6 then


                        if DirectoryExists(Format('%s', [constStoragePath]))  then begin   // uloziste je pristupne
                                mResult:=DirectoryExists(Format('%s\%s', [constStoragePath, self.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID')]));
                                if  not mresult then begin    // servisovaný objekt
                                        mResult:=NxCreateDir(Format('%s\%s', [constStoragePath, self.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID')]));
                                        //ShowMessage(Format('%s\%s', [constStoragePath, self.GetFieldValueAsString('ServicedObject_ID')]));

                                end;
                                mResult:=DirectoryExists(Format('%s\%s\%s', [constStoragePath, self.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID'),'Servisni listy']));
                                if not mresult then begin    // servisní list
                                        mResult:=NxCreateDir(Format('%s\%s\%s', [constStoragePath, self.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID'),'Servisni listy']));
                                        //ShowMessage(Format('%s\%s\%s', [constStoragePath, self.GetFieldValueAsString('ServicedObject_ID'),'Servisni listy']));

                                end;
                                mResult:=DirectoryExists(Format('%s\%s\%s\%s', [constStoragePath, self.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID'),'Servisni listy',self.GetFieldValueAsString('ID')]));
                                if not mresult then begin    // servisní list
                                        mResult:=NxCreateDir(Format('%s\%s\%s\%s', [constStoragePath, self.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID'),'Servisni listy',self.GetFieldValueAsString('ServiceDocument_ID')]));
                                end;
                                mResult:=DirectoryExists(Format('%s\%s\%s\%s\%s', [constStoragePath, self.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID'),'Servisni listy',self.GetFieldValueAsString('ServiceDocument_ID'),'ML']));
                                if not mresult then begin    // servisní list
                                        mResult:=NxCreateDir(Format('%s\%s\%s\%s\%s', [constStoragePath, self.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID'),'Servisni listy',self.GetFieldValueAsString('ServiceDocument_ID'),'ML']));
                                end ;

                                mResult:=DirectoryExists(Format('%s\%s\%s\%s\%s\%s', [constStoragePath, self.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID'),'Servisni listy',self.GetFieldValueAsString('ServiceDocument_ID'),'ML',self.oid]));
                                if not mresult then begin    // servisní list
                                        mResult:=NxCreateDir(Format('%s\%s\%s\%s\%s\%s', [constStoragePath, self.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID'),'Servisni listy',self.GetFieldValueAsString('ServiceDocument_ID'),'ML',self.oid]));
                                end ;
                        end;


  end;



//  if nxisblank(self.getFieldValueAsString('X_Spedos_formular')) and
//                                             not nxisblank(trim(AValue.AsString))
//                                          then begin
//                                              mfile:='';
//                                                       mfile:=autocopy_protocol(self);
//                                                       if mfile='' then begin
//                                                           mfile:=manualcopy_protocol(self);
//                                                       end;
//                                                       if mfile<>'' then begin
//                                                          mi:=self.ObjectSpace.SQLExecute('update ServiceAssemblyForms set X_Spedos_formular=' + quotedstr(mfile) + ' and id=' + quotedstr(self.oid));
                                                          //self.SetFieldValueAsString('X_Spedos_formular',mfile);
                                                          //TDynSiteForm(self).ActiveDataSet.RefreshCurrentItem;
//                                                        end;
//                                           end;


end;





begin
end.