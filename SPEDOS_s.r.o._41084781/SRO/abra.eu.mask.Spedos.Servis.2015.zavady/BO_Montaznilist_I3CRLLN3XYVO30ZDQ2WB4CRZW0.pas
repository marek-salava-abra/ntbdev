
{
Vyvolává se bezprostředně před provedením softvalidace objektu.

procedure BeforeSoftValidate_Hook(Self: TNxCustomBusinessObject);
var
   mr:tstringlist ;
   mtext,mtext_pomoc:string;
   mnedohledano:boolean;
begin
//if self.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='1A20000101' then begin

if not NxIsBlank(self.GetFieldValueAsString('X_Zavada_code')) then begin
   if Length(self.GetFieldValueAsString('X_Zavada_code'))=7 then begin
                           mnedohledano:=true;

                           mtext:= copy(self.GetFieldValueAsString('X_Zavada_code'),1,2);
                           while mnedohledano do begin
                                 mr:=tstringlist.create;
                                 try
                                         self.ObjectSpace.SQLSelect('SELECT (A.ID) FROM DefRollData A WHERE A.CLSID = ' + quotedstr('UAM5BGU23YMOF4QOEHZYGUML1C') + ' and code=' + quotedstr(mtext),mr) ;
                                          if mr.count>0 then begin
                                             self.setFieldValueAsString('X_Pricina_poruchy_ID',mr.Strings[0]);
                                             mnedohledano:=false;
                                             if mtext<>copy(self.GetFieldValueAsString('X_Zavada_code'),1,2) then begin
                                                self.SetFieldValueAsString('X_Zavada_code',mtext+copy(self.GetFieldValueAsString('X_Zavada_code'),3,5));
                                             end;
                                          end;
                                          if mnedohledano then begin
                                                InputQuery('Oprava','Kód pro příčinu poruchy '+quotedstr(mtext) +' nebyl nalezen.Zadejte jiný.',mtext,nil)  ;
                                          end;
                                  finally
                                      mr.free;
                                  end;
                           end;

                          mnedohledano:=true;
                         mtext:= copy(self.GetFieldValueAsString('X_Zavada_code'),3,2);
                         while mnedohledano do begin
                                 mr:=tstringlist.create;
                                 try
                                         self.ObjectSpace.SQLSelect('SELECT (A.ID) FROM DefRollData A WHERE A.CLSID = ' + quotedstr('H2WTBSP5ZWVOB1UVQHWUI1ABKK') + ' and code=' + quotedstr(mtext),mr) ;
                                        if mr.count>0 then begin
                                           self.setFieldValueAsString('X_Typ_poruchy_ID',mr.Strings[0]);
                                           mnedohledano:=false;
                                           if mtext<>copy(self.GetFieldValueAsString('X_Zavada_code'),3,2) then begin
                                                self.SetFieldValueAsString('X_Zavada_code',copy(self.GetFieldValueAsString('X_Zavada_code'),1,2)+mtext+copy(self.GetFieldValueAsString('X_Zavada_code'),5,3));
                                             end;
                                        end;
                                        if mnedohledano then begin
                                           InputQuery('Oprava','Kód pro typ poruchy '+quotedstr(mtext) +' nebyl nalezen.Zadejte jiný.',mtext,nil) ;
                                        end;
                                  finally
                                          mr.free;
                                  end;
                         end;

                          mnedohledano:=true;

                           mtext:= copy(self.GetFieldValueAsString('X_Zavada_code'),5,3);
                           while mnedohledano do begin
                                 mr:=tstringlist.create;
                                 try

                                         self.ObjectSpace.SQLSelect('SELECT (A.ID) FROM DefRollData A WHERE A.CLSID = ' + quotedstr('FOJ2LARQEZ34F1WPAVKBORUFOC') + ' and code=' + quotedstr(mtext),mr) ;
                                          if mr.count>0 then begin
                                             self.setFieldValueAsString('X_Opravovana_cast_ID',mr.Strings[0]);
                                             mnedohledano:=false;
                                             if mtext<>copy(self.GetFieldValueAsString('X_Zavada_code'),5,3) then begin
                                                self.SetFieldValueAsString('X_Zavada_code',copy(self.GetFieldValueAsString('X_Zavada_code'),1,4)+mtext);
                                             end;

                                          end;
                                          if mnedohledano then begin
                                            InputQuery('Oprava','Kód pro opravovanou část '+quotedstr(mtext) +' nebyl nalezen.Zadejte jiný.',mtext,nil)
                                          end;
                                  finally
                                      mr.free;
                                  end;
                            end;
                    //self.setFieldValueAsString('X_Zavada_code','');
   end else begin
      NxShowSimpleMessage('Kód nemá předepsaných 7 číslic',nil);
       self.setFieldValueAsString('X_Zavada_code','');
   end;
//end;
end;
end;
       }
begin
end.