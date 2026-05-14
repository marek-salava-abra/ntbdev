procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
    self2:TNxCustomBusinessObject;
    mheaderBO,mDocQueue:TNxCustomBusinessObject;
    mR:tstringlist;
    mresult:Boolean;
    posun:double;
    mr1,mr2:TStringList;
    mBO_BusProject,mBO_ML:TNxCustomBusinessObject;
    mF_posun:Double;
    mD_posun,mD_posunZ:date;
    mI_posun:integer;
    i:integer;
    mr3:tstringlist;
begin


// * * *  generování následného servisu podle smlouvy
if (self.GetFieldValueAsString('DocQueue_ID')='4B20000101') or
   (self.GetFieldValueAsString('DocQueue_ID')='8B20000101') or
   (self.GetFieldValueAsString('DocQueue_ID')='9B20000101')




 then begin
   if self.GetFieldValueAsInteger('ServiceDocState_ID.PosIndex')>18 then begin
      if not NxIsEmptyOID(Self.GetFieldValueAsString('BusProject_ID')) then begin
          try
              mBO_BusProject:=self.ObjectSpace.CreateObject('QOKMKIQUJF34L3DUICTBWEDQJC');
              mBO_BusProject.load(Self.GetFieldValueAsString('BusProject_ID'),nil);
               if mBO_BusProject.GetFieldValueAsBoolean('X_Generovat_prohlidky') then begin
                   if mBO_BusProject.GetFieldValueAsFloat('X_Cetnost_PR')<>0 then begin      // počet prohlídek do roka
                        mD_posun:=NxIncMonth(self.getFieldValueAsDateTime('PromisedDeadLine$DATE'),trunc(mBO_BusProject.GetFieldValueAsFloat('X_Cetnost_PR')));
                    //    mD_posunZ:=self.getFieldValueAsDateTime('PromisedDeadLine$DATE') + (365/mBO_BusProject.GetFieldValueAsFloat('X_Cetnost_PR'));
                   end;
                     if pos(mBO_BusProject.GetFieldValueAsString('X_Obdobi_prohlidek'),'A')<>0 then begin   // korekce na období
                        // prohlidky
                        mI_posun:= NxGetMonth(mD_posun);
                        while (copy(mBO_BusProject.GetFieldValueAsString('X_Obdobi_prohlidek'),mi_posun,1)='A') and (i<=14) do begin
                            mD_posun:=NxIncMonth(mD_posun,1);
                            mD_posunZ:=NxIncMonth(mD_posunZ,1);
                            mI_posun:= NxGetMonth(mD_posun);
                            //NxShowSimpleMessage(inttostr(mI_posun),nil);
                            i:=i+1;
                        end;
                     end;
                     mr1:=tstringlist.Create;
                      try
                            self2:=Self.ObjectSpace.CreateObject('BCHF52UGXCO4H5MIAQVY5P3ZOC');    // založení nového sl
                            self2.ObjectSpace.SQLSelect(format('select sd.id from ServiceDocuments sd left join ServiceDocStates SS on ss.id=sd.ServiceDocState_ID where sd.ServicedObject_ID=%s and sd.Docqueue_ID=%s and ss.PosIndex<18 and sd.id<>%s',
                            [quotedstr(self.GetFieldValueAsString('ServicedObject_ID')),quotedstr(self.GetFieldValueAsString('DocQueue_ID')),quotedstr(self.OID)]),mr1);
                           if mr1.count>0 then begin
                                self2.load(mr1.Strings[0],nil);
                               self2.SetFieldValueAsDateTime('PromisedDeadLine$DATE',FloatToDateTime(trunc(md_posun))) ;
                                //self2.SetFieldValueAsString('AcceptedByUser_ID','2L00000101') ;
                                self2.save;
                            end else begin
                                self2.new;
                                            self2.Prefill;
                                            self2.SetFieldValueAsString('Docqueue_ID', self.GetFieldValueAsString('Docqueue_ID'));
                                            self2.SetFieldValueAsDateTime('Docdate$date', FloatToDateTime(trunc(md_posun)));

                                            self2.SetFieldValueAsstring('ServicedObjectIDCode','');
                                            self2.SetFieldValueAsstring('ServicedObjectText','');

                                            self2.SetFieldValueAsstring('ServicedObject_ID',self.GetFieldValueAsString('ServicedObject_ID'));
                                            self2.SetFieldValueAsstring('Firm_ID',self.GetFieldValueAsString('Firm_ID'));
                                            self2.SetFieldValueAsstring('PayerFirm_ID',self.GetFieldValueAsString('PayerFirm_ID'));
                                            self2.SetFieldValueAsstring('FirmOffice_ID',self.GetFieldValueAsString('FirmOffice_ID'));
                                            self2.SetFieldValueAsstring('PayerFirmOffice_ID',self.GetFieldValueAsString('PayerFirmOffice_ID'));
                                            self2.SetFieldValueAsString('Division_ID', self.GetFieldValueAsString('Division_ID'));
                                            self2.SetFieldValueAsString('BusOrder_ID', self.GetFieldValueAsString('ServicedObject_ID.BusOrder_ID'));
                                            self2.SetFieldValueAsString('BusTransaction_ID', self.GetFieldValueAsString('ServicedObject_ID.BusTransaction_ID'));
                                            self2.SetFieldValueAsString('BusProject_ID', self.GetFieldValueAsString('ServicedObject_ID.BusProject_ID'));
                                            //self2.SetFieldValueAsString('AcceptedByUser_ID', '1410000101');
                                            self2.SetFieldValueAsDateTime('PromisedDeadLine$DATE', FloatToDateTime(trunc(md_posun)));
                                            if (Self2.GetFieldValueAsString('Docqueue_id')='4B20000101') Or           // SL05
                                                   //(Self2.GetFieldValueAsString('Docqueue_id')='6B20000101') Or          // SL07
                                                   //(Self2.GetFieldValueAsString('Docqueue_id')='7B20000101') or          // SL08 obj
                                                   (Self2.GetFieldValueAsString('Docqueue_id')='8B20000101') or          // SL09
                                                   (Self2.GetFieldValueAsString('Docqueue_id')='9B20000101')          // SL10
                                                   //(Self2.GetFieldValueAsString('Docqueue_id')='AB20000101')             // SL11 obj
                                                   then begin
                                                   Self2.SetFieldValueAsString('X_Objednani','dle smlouvy '+Self2.GetFieldValueAsString('ServicedObject_ID.Busproject_ID.Code'));



                                            end else begin
                                                 if self2.GetFieldValueAsstring('ServicedObject_ID.X_Celorocni_objednavky')<>'' then begin
                                                     self2.SetFieldValueAsstring('X_objednani', self2.GetFieldValueAsstring('ServicedObject_ID.X_Celorocni_objednavky'));
                                                  end else begin

                                                  end;
                                             end;
                                            self2.SetFieldValueAsstring('ServiceDocState_ID','9900000101');
                                              // řádky montážního listu

                                            self2.Save ;
                                            mr3:=tstringlist.create;
                                            try
                                                    self.ObjectSpace.SQLSelect('select id from ServiceAssemblyForms where ServiceDocument_ID=' + quotedstr(self2.oid),mr3);
                                                    if mr3.count=0 then begin
                                                          mBO_ML:=self2.ObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                                                                try
                                                                   mBO_ML.new;
                                                                   mBO_ML.Prefill;
                                                                   mBO_ML.SetFieldValueAsDateTime('StartDate$DATE',self2.GetFieldValueAsDateTime('DocDate$DATE'));
                                                                   mBO_ML.SetFieldValueAsDateTime('EndDate$DATE',self2.GetFieldValueAsDateTime('PromisedDeadLine$DATE'));
                                                                   mBO_ML.SetFieldValueAsString('ServiceDocument_ID',self2.OID);
                                                                   mBO_ml.SetFieldValueAsstring('X_ServicedObject_ID',self2.GetFieldValueAsString('ServicedObject_ID'));
                                                                   mBO_ML.SetFieldValueAsstring('X_State','3XQ1000101');
                                                                   mBO_ML.SetFieldValueAsstring('X_ServicedObject_ID',self2.GetFieldValueAsString('ServicedObject_ID'));
                                                                   mBO_ML.SetFieldValueAsstring('X_id_zakaznika_id',self2.GetFieldValueAsString('X_id_zakaznika_id'));
                                                                   mBO_ML.SetFieldValueAsInteger('AssemblyState',0);
                                                                   mr2:=TStringList.Create;
                                                                   try
                                                                        self2.ObjectSpace.SQLSelect('select id from ServiceWorkSpaces where code=' + QuotedStr(self2.GetFieldValueAsString('Division_ID.code')),mr2);
                                                                        if mr2.count=1 then begin
                                                                           mBO_ml.SetFieldValueAsString('ServiceWorkSpace_ID',mr2.Strings[0]);
                                                                        end;
                                                                    finally
                                                                       mr2.free;
                                                                    end;
                                                                    mr2:=TStringList.Create;
                                                                    try
                                                                        self2.ObjectSpace.SQLSelect('select id from SecurityRoles where ShortName=' + QuotedStr(self2.GetFieldValueAsString('Division_ID.code')),mr2);
                                                                        if mr2.count=1 then begin
                                                                           mBO_ml.SetFieldValueAsString('ResponsibleRole_ID',mr2.Strings[0]);
                                                                        end;
                                                                    finally
                                                                        mr2.free;
                                                                    end;
                                                                   mBO_ML.SetFieldValueAsstring('X_Docqueue_ID',self2.GetFieldValueAsString('Docqueue_ID'));
                                                                    mBO_ML.SetFieldValueAsInteger('X_Ordnumber',self2.GetFieldValueAsInteger('Ordnumber'));
                                                                    mBO_ML.SetFieldValueAsstring('X_Period_ID',self2.GetFieldValueAsString('Period_ID'));
                                                                    mbo_ml.Save;
                                                               finally
                                                                   mBO_ML.free;
                                                               end;
                                                        end;

                                                 finally
                                                      mr3.free;
                                                 end;

                            end;
                      finally
                          mr1.free;
                          self2.free;

                      end;
              end;
              mBO_BusProject.free;
          finally

          end;


     end;
   end;
   end;
end;

{
Vyvolává se bezprostředně před provedením softvalidace objektu.
}
procedure BeforeSoftValidate_Hook(Self: TNxCustomBusinessObject);
begin
    if self.GetFieldValueAsString('ServiceDocState_ID')='C102000000' then self.SetFieldValueAsString('ServiceDocState_ID','D102000000');

end;

begin
end.