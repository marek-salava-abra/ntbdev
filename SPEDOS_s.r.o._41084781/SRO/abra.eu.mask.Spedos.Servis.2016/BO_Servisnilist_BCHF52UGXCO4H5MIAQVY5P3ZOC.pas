  uses 'abra.eu.mask.Spedos.Servis.2016_funkce.const',
       'abra.eu.mask.Spedos.Servis.2016_funkce.funkce';


var
       mdatepomoc:double;

procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
mr:tstringlist;
mBO:TNxCustomBusinessObject;
begin
mdatepomoc:=0;
if self.GetFieldValueAsString('ServiceType_ID')='2300000101' then begin
  if AFieldCode = Self.GetFieldCode('ServicedObject_ID') then begin
     mbo:=self.ObjectSpace.CreateObject('OWHN2TMXL2COJJ3LKNBV4OVSTC');
     try

         mbo.load(AValue.AsString,nil);
             if not nxisblank(mbo.GetFieldValueAsstring('X_id_zakaznika_id')) then Self.SetFieldValueAsstring('X_id_zakaznika_id', mbo.GetFieldValueAsstring('X_id_zakaznika_id'));
             if not nxisblank(mbo.GetFieldValueAsstring('PayerFirm_ID')) then  Self.SetFieldValueAsstring('PayerFirm_ID', mbo.GetFieldValueAsstring('PayerFirm_ID'));
             if not nxisblank(mbo.GetFieldValueAsstring('Firm_ID')) then  Self.SetFieldValueAsstring('Firm_ID', mbo.GetFieldValueAsstring('Firm_ID'));
             if not nxisblank(mbo.GetFieldValueAsstring('FirmOffice_ID')) then  Self.SetFieldValueAsstring('FirmOffice_ID', mbo.GetFieldValueAsstring('FirmOffice_ID'));
             if not nxisblank(mbo.GetFieldValueAsstring('PayerFirmOffice_ID')) then  Self.SetFieldValueAsstring('PayerFirmOffice_ID', mbo.GetFieldValueAsstring('PayerFirmOffice_ID'));
             if not nxisblank(mbo.GetFieldValueAsstring('PayerPerson_ID')) then  Self.SetFieldValueAsstring('PayerPerson_ID', mbo.GetFieldValueAsstring('PayerPerson_ID'));
             if not nxisblank(mbo.GetFieldValueAsstring('X_person_ID')) then  Self.SetFieldValueAsstring('X_person_ID', mbo.GetFieldValueAsstring('X_person_ID'));
             if not nxisblank(mbo.GetFieldValueAsString('code')) then  self.SetFieldValueAsString('ServicedObjectIDCode',mbo.GetFieldValueAsString('code'));
             if not nxisblank(mbo.GetFieldValueAsString('Name')) then  self.SetFieldValueAsString('ServicedObjectText',mbo.GetFieldValueAsString('Name'));

      finally
         mbo.free;
      end;
            if (AOriginalValue.AsString <> AValue.AsString) then  begin
                     try
                     Self.SetFieldValueAsDateTime('PromisedDeadLine$DATE', trunc(now) + (encodetime(15,30,0,0)+2));

                             if (Self.GetFieldValueAsString('Docqueue_id')='4B20000101') Or           // SL05
                                 //(Self.GetFieldValueAsString('Docqueue_id')='6B20000101') Or          // SL07
                                 //(Self.GetFieldValueAsString('Docqueue_id')='7B20000101') or          // SL08 obj
                                 (Self.GetFieldValueAsString('Docqueue_id')='8B20000101') or          // SL09
                                 (Self.GetFieldValueAsString('Docqueue_id')='9B20000101')          // SL10
                                 //(Self.GetFieldValueAsString('Docqueue_id')='AB20000101')             // SL11 obj
                                 then begin
                                      Self.SetFieldValueAsString('X_Objednani','dle smlouvy '+Self.GetFieldValueAsString('Busproject_ID.Code')) ;
                                      if (not nxisemptyoid(Self.GetFieldValueAsString('ServicedObject_ID.BusProject_id'))) then begin
                                          Self.SetFieldValueAsFloat('X_discount', Self.GetFieldValueAsFloat('ServicedObject_ID.BusProject_id.X_SlevyND'));
                                          Self.SetFieldValueAsFloat('X_discount_sluzby', Self.GetFieldValueAsFloat('ServicedObject_ID.BusProject_id.X_Slevy_Sluzby'));
                                      end else begin
                                          self.SetFieldValueAsFloat('X_discount',0);
                                      end;
                                 end else begin
                                      if (not nxisemptyoid(Self.GetFieldValueAsString('ServicedObject_ID.BusProject_id'))) then begin
                                              Self.SetFieldValueAsFloat('X_discount', Self.GetFieldValueAsFloat('ServicedObject_ID.BusProject_id.X_SlevyND'));
                                              Self.SetFieldValueAsFloat('X_discount_sluzby', Self.GetFieldValueAsFloat('ServicedObject_ID.BusProject_id.X_Slevy_Sluzby'));
                                      end else begin
                                          self.SetFieldValueAsFloat('X_discount',0);
                                      end;
                                      if not nxisblank(Self.GetFieldValueAsString('ServicedObject_ID.X_Celorocni_objednavky')) then begin
                                          Self.SetFieldValueAsString('X_Objednani',Self.GetFieldValueAsString('ServicedObject_ID.X_Celorocni_objednavky'));
                                      end else begin

                                      end;
                                  end;


                     finally
                     end;


            end;
  end;
//  if AFieldCode = Self.GetFieldCode('DocDate$DATE') then begin
//      if not (OsNew in Self.State) then begin
//            if (AOriginalValue.AsDateTime<> AValue.AsDateTime) and (mdatepomoc=0) then begin
//                if mdatepomoc=0 then mdatepomoc:=AOriginalValue.AsDateTime ;
//                      NxShowSimpleMessage('Položku datum není možno opravovat',nil);
//                      Self.SetFieldValueAsDateTime('DocDate$DATE',mdatepomoc);
//            end;
//      end;
//  end;

end;
end;





procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
begin
if self.GetFieldValueAsString('ServiceType_ID')='2300000101' then begin
  if self.GetFieldValueAsString('ServicedObject_ID.code')<>self.GetFieldValueAsString('ServicedObjectIDCode') then begin
     self.SetFieldValueAsString('ServicedObjectIDCode',self.GetFieldValueAsString('ServicedObject_ID.code'));
     self.SetFieldValueAsString('ServicedObjectText',self.GetFieldValueAsString('ServicedObject_ID.Name'));

  end;

  if (not nxisemptyoid(Self.GetFieldValueAsString('ServicedObject_ID.BusProject_id'))) then begin
                              Self.SetFieldValueAsFloat('X_discount', Self.GetFieldValueAsFloat('ServicedObject_ID.BusProject_id.X_SlevyND'));
                              Self.SetFieldValueAsFloat('X_discount_sluzby', Self.GetFieldValueAsFloat('ServicedObject_ID.BusProject_id.X_Slevy_Sluzby'));
                      end else begin
                          self.SetFieldValueAsFloat('X_discount',0);
                      end;

end;
end;

procedure BeforeSoftValidate_Hook(Self: TNxCustomBusinessObject);
begin
if self.GetFieldValueAsDateTime('X_CreatedDate$DATE')<100 then self.SetFieldValueAsDateTime('X_CreatedDate$DATE',now()) ;

end;

{
Vyvolává se poté, co se provede na objektu metoda New.
}
procedure New_Hook(Self: TNxCustomBusinessObject);
begin

end;

procedure Prefill_Hook(Self: TNxCustomBusinessObject);
begin
self.SetFieldValueAsString('ServiceType_ID','2300000101');
//if self.GetFieldValueAsString('ServiceType_ID')='2300000101' then begin
    Self.SetFieldValueAsString('Division_ID', Self.GetFieldValueAsString('CreatedBy_ID.X_Division_ID'));
    if ladit then NxShowSimpleMessage('Středisko: ' +Self.GetFieldValueAsString('CreatedBy_ID.X_Division_ID'),nil);
//end;
end;


  begin
  end.