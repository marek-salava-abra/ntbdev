  uses 'abra.eu.mask.Spedos.Servis.2016_funkce.const',
       'abra.eu.mask.Spedos.Servis.2016_funkce.funkce';

procedure _AfterSetFieldValue_PreHook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter);

begin
  if AFieldCode = Self.GetFieldCode('text') then begin
    if nxisemptyoid(self.getFieldValueAsString('VATRate_ID')) then self.SetFieldValueAsString('VATRate_ID','02100X0000');
  end;
end;



procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
mresult:boolean;
mr:TStringList;
MBO:TNxCustomBusinessObject;
zapis:Boolean;

begin
if self.GetFieldValueAsString('parent_ID.ServiceDocument_ID.ServiceType_ID')='2300000101' then begin
     zapis:=false;
    if self.GetFieldValueAsInteger('Itemtype')=0 then begin
          if (self.GetFieldValueAsString('StoreCard_id')='11J1000101') or (self.GetFieldValueAsString('StoreCard_id')='2ZI1000101') then begin
           mr:=TStringList.Create;
              self.ObjectSpace.SQLSelect('select id from CRMActivities where x_parent_id=' + quotedstr(self.GetFieldValueAsString('ID')),mr);
              if mr.Count=1 then begin
                 try
                    mbo:=self.ObjectSpace.CreateObject('AVV1JYV5AVNOZHQCK0D4CJFUCS');
                    mbo.Load(mr.Strings[0],nil);
                    if mbo.GetFieldValueAsString('SolverRole_ID')<>self.GetFieldValueAsString('workerrole_ID') then begin
                    zapis:=true;
                     if ladit then NxShowSimpleMessage('Změna prac na ML',nil);
                    end;
                    if mbo.GetFieldValueAsDateTime('Realend$Date')<> self.GetFieldValueAsDateTime('X_Konec_prace') then begin
                    zapis:=true;
                    // NxShowSimpleMessage('Změna doby na ML',nil);
                    end;
                    if mbo.GetFieldValueAsDateTime('RealStart$Date')<> (self.GetFieldValueAsDateTime('X_konec_prace')- EncodeTime(self.GetFieldValueAsInteger('WorkHoursPlanned'),0,0,0)) then zapis:=true;
                    if trunc(HoursBetween(mbo.GetFieldValueAsDateTime('Realend$Date'),mbo.GetFieldValueAsDateTime('Realstart$Date'))) <> trunc(self.GetFieldValueAsFloat('WorkHoursPlanned')) then zapis:=true;
                 finally
                 end;


              end else begin
                   zapis:=true;
              end;
              if zapis then begin


                mresult:=NxCRM(0,Self,self.GetFieldValueAsString('WorkerRole_ID'),
                        (self.GetFieldValueAsDateTime('X_konec_prace')- EncodeTime(1,0,0,0)),
                        self.GetFieldValueAsDateTime('X_konec_prace'),'','');
                        //(self.GetFieldValueAsDateTime('X_konec_prace')- EncodeTime(self.GetFieldValueAsInteger('WorkHoursPlanned'),0,0,0)),
              end;
        end;

    end;
    end;
end;





procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
mcode:integer;
mr:tstringlist;
mBO_ID:string;
MBO:TNxCustomBusinessObject;
mStore_id:string;
begin
if self.GetFieldValueAsString('parent_ID.ServiceDocument_ID.ServiceType_ID')='2300000101' then begin
    if AFieldCode = self.GetFieldValueAsInteger('ItemType') then begin
         if avalue.AsInteger<>AOriginalValue.AsInteger then begin
            if avalue.AsInteger=0 then begin
               Self.setFieldValueAsFloat('X_Radkova_sleva',Self.GetFieldValueAsFloat('Parent_ID.ServiceDocument_ID.X_Discount_sluzby'));
            end;
            if avalue.AsInteger=1 then begin
               Self.setFieldValueAsFloat('X_radkova_sleva',Self.GetFieldValueAsFloat('Parent_ID.ServiceDocument_ID.X_Discount'));
            end;

        end;
     end;
    if (AFieldCode = Self.GetFieldCode('Storecard_id')) and (self.GetFieldValueAsInteger('ItemType')<>1) then begin
       //Self.setFieldValueAsFloat('X_Radkova_sleva',Self.GetFieldValueAsFloat('Parent_ID.ServiceDocument_ID.X_Discount_sluzby'));
    end;

    if (AFieldCode = Self.GetFieldCode('Storecard_id')) and (self.GetFieldValueAsInteger('ItemType')=1) then begin
        if avalue.Asstring<>AOriginalValue.AsString then begin
           //Self.setFieldValueAsFloat('X_radkova_sleva',Self.GetFieldValueAsFloat('Parent_ID.ServiceDocument_ID.X_Discount'));

        end;

       if (Self.GetFieldValueAsString('StoreCard_ID')='1GJ1000101') or  (Self.GetFieldValueAsString('StoreCard_ID')='1FD1000101') or (Self.GetFieldValueAsString('StoreCard_ID')='92E0000101') or (Self.GetFieldValueAsString('StoreCard_ID')='17T0000101') then
          Self.setFieldValueAsFloat('X_radkova_sleva',0);
    {                   mr:=tstringlist.Create;
                      try
                           //self.ObjectSpace.SQLSelect('select (SR.X_store_ID) from ServiceAssemblyForms2 SA2 left join SecurityRoles SR on SR.id=SA2.X_workerrole_ID where SA2.parent_ID=' + QuotedStr(self.GetFieldValueAsString('Parent_ID')) + ' and SR.X_Store_ID<>'+ quotedstr('2000000101')+' and SR.X_Store_ID<>'+ quotedstr('0000000000'),mr);
                           self.ObjectSpace.SQLSelect('select max(SA2.store_ID) from ServiceAssemblyForms2 SA2 where SA2.parent_ID=' + QuotedStr(self.GetFieldValueAsString('Parent_ID')),mr);
                          //NxShowSimpleMessage(self.GetFieldValueAsString('parent_ID.X_Monter1_ID.X_store_ID'),nil);


                          if mr.count>0 then begin
                                  if (mr.Strings[0]<>'') and (mr.Strings[0]<>'0000000000') then begin

                                       self.SetFieldValueAsString('Store_ID',mr.Strings[0]);
                                  end;
                          end else begin
                      finally
                         mr.free;
                      end;

                  //end;
        //end;          }
        if self.GetFieldValueAsFloat('Quantity')=0 then self.SetFieldValueAsFloat('Quantity',1);
        if nxisemptyoid(self.getFieldValueAsString('Store_ID')) then begin
          if not nxisemptyoid(self.GetFieldValueAsString('parent_ID.X_Monter1_ID')) then begin
              self.SetFieldValueAsString('Store_ID',self.GetFieldValueAsString('parent_ID.X_Monter1_ID.X_store_ID'));
          end;
        end;
  end;

     if (AFieldCode = Self.GetFieldCode('WorkHoursReal')) and (self.GetFieldValueAsString('StoreCard_ID')='54W0000101') then begin
        if AValue.AsFloat<>AOriginalValue.AsFloat then begin
           if self.GetFieldValueAsFloat('WorkHoursPlanned')=0 then self.SetFieldValueAsFloat('WorkHoursPlanned',AValue.asfloat);
        end;
     end;
     if (AFieldCode = Self.GetFieldCode('WorkerRole_ID')) then begin
        if AValue.Asstring<>AOriginalValue.Asstring then begin
           self.SetFieldValueAsstring('X_Osoba',self.GetFieldValueAsstring('WorkerRole_ID.Name'));
        end;
     end;
     if (AFieldCode = Self.GetFieldCode('Store_ID')) then begin
        if AValue.Asstring<>AOriginalValue.Asstring then begin
           self.SetFieldValueAsstring('X_sklad',self.GetFieldValueAsstring('Store_ID.Code'));
        end;
     end;
     if (AFieldCode = Self.GetFieldCode('Quantity')) then begin
        if AValue.AsFloat<>AOriginalValue.AsFloat then begin
                if self.GetFieldValueAsinteger('Parent_ID.ServiceDocument_ID.GuarantyRepair')=2 then begin
                    self.SetFieldValueAsFloat('UnitPriceWithoutVAT',0);
                    self.SetFieldValueAsFloat('UnitPriceWithVAT',0);
                end;

        end;
     end;
     if (AFieldCode = Self.GetFieldCode('X_Storno1')) then begin
        if AValue.AsBoolean<>AOriginalValue.AsBoolean then begin
                if AValue.AsBoolean then begin
                        self.SetFieldValueAsFloat('QuantityDelivered',self.GetFieldValueAsFloat('Quantity')) ;
                        self.SetFieldValueAsBoolean('X_storno',true) ;
                        self.SetFieldValueAsFloat('UnitPriceWithoutVAT',0);
                        self.SetFieldValueAsFloat('UnitPriceWithVAT',0);
                        self.SetFieldValueAsinteger('ToInvoiceType',1);
                        self.SetFieldValueAsinteger('IsInvoiced',2);
                        end else begin
                             self.SetFieldValueAsFloat('QuantityDelivered',0);
                             self.SetFieldValueAsinteger('ToInvoiceType',0);
                             self.SetFieldValueAsinteger('IsInvoiced',0);
                             self.SetFieldValueAsBoolean('X_storno',false) ;
                        end;

        end;
     end;



end;
end;

{
Vyvolává se před fyzickým vymazáním vlastního objektu z databáze.
}
{
procedure BeforeDelete_Hook(Self: TNxCustomBusinessObject);
var
mr1:tstringlist;
begin
   self.ObjectSpace.SQLSelect(format('select (io2.Quantity-io2.DeliveredQuantity) from IssuedOrders2 IO2 left join IssuedOrders IO on io.id=io2.parent_id where' +
                                            ' io2.store_id=%s and io2.storecard_id=%s ' +
                                            ' io.Closed=%s and io.DocQueue_ID=%s and io2.X_parent_ID=%s',[QuotedStr('M000000101'),QuotedStr(Self.GetFieldValueAsString('StoreCard_ID')),quotedstr('N')
                                            ,'1Q10000101',Self.GetFieldValueAsString('ID')]),mr1);
                              if mr1.Count>0 then begin
                                   self.AddValidateError(self.GetFieldCode('X_storno'),'Zboží je již zajištěno, nelze vymazat, pouze stornovat') ;
                                   exit;
                              end;
end;
 }



{
Umožňuje ovlivnit to, zda je možné objekt vymazat.
}
{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
begin
if self.GetFieldValueAsString('parent_ID.ServiceDocument_ID.ServiceType_ID')='2300000101' then begin
           self.SetFieldValueAsstring('X_Osoba',copy(self.GetFieldValueAsstring('WorkerRole_ID.Name'),1,10));
           self.SetFieldValueAsstring('X_sklad',copy(self.GetFieldValueAsstring('Store_ID.Code'),1,10));
           self.SetFieldValueAsBoolean('X_storno',self.getFieldValueAsBoolean('X_storno1'));
           self.SetFieldValueAsstring('U_description',copy(self.getFieldValueAsstring('X_description'),1,149));
end;

end;

{
Vyvolává se bezprostředně před provedením softvalidace objektu.
}
procedure BeforeSoftValidate_Hook(Self: TNxCustomBusinessObject);
begin
    if nxisemptyoid(self.getFieldValueAsString('VATRate_ID')) then self.SetFieldValueAsString('VATRate_ID','02100X0000');
end;

procedure CanDelete_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin

end;

procedure New_Hook(Self: TNxCustomBusinessObject);
var
mr:tstringlist;
mBO_ID:string;
MBO:TNxCustomBusinessObject;
mStore_id:string;
begin
if self.GetFieldValueAsString('parent_ID.ServiceDocument_ID.ServiceType_ID')='2300000101' then begin
  if Self.GetFieldValueAsinteger('Itemtype')=1 then begin
        if not nxisemptyoid(Self.GetFieldValueAsstring('Parent_ID.X_Monter1_ID.X_store_id')) then begin
                         mStore_id:=Self.GetFieldValueAsstring('Parent_ID.X_Monter1_ID.X_store_id');
                         self.SetFieldValueAsString('Store_ID',mStore_id);
                         if ladit then NxShowSimpleMessage(mStore_id,nil);
        end else begin
                         self.SetFieldValueAsString('Store_ID','M000000101');

        end;

end;
  if Self.GetFieldValueAsinteger('Itemtype')>1 then begin
        self.SetFieldValueAsString('VATRate_ID','02100X0000');
  end;
end;
end;



{
Vyvolává se při předvyplňování hodnot daného objektu.
}
procedure Prefill_Hook(Self: TNxCustomBusinessObject);
var
mr:tstringlist;
mBO_ID:string;
MBO:TNxCustomBusinessObject;
mStore_id:string;
begin
if self.GetFieldValueAsString('parent_ID.ServiceDocument_ID.ServiceType_ID')='2300000101' then begin
  Self.setFieldValueAsFloat('X_Radkova_sleva',
               Self.GetFieldValueAsFloat('Parent_ID.ServiceDocument_ID.X_Discount'));
//  if Self.GetFieldValueAsinteger('Itemtype')=1 then begin
  if not nxisemptyoid(self.GetFieldValueAsString('parent_ID.X_Monter1_ID')) then begin
          self.SetFieldValueAsString('Store_ID',self.GetFieldValueAsString('parent_ID.X_Monter1_ID.X_store_ID'));
  end;
    if Self.GetFieldValueAsinteger('Itemtype')>1 then begin
        self.SetFieldValueAsString('VATRate_ID','02100X0000');
  end;
end;
end;

{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
if self.GetFieldValueAsString('parent_ID.ServiceDocument_ID.ServiceType_ID')='2300000101' then begin
      if nxisemptyoid(self.GetFieldValueAsString('VATRate_ID')) then self.setFieldValueAsString('VATRate_ID','02100X0000')  ;

      if self.GetFieldValueAsInteger('Itemtype')=1 then begin
          //self.GetFieldValueAsString('Qunit')<>self.GetFieldValueAsString('Storecard_ID.MainUnitCode');
          //addvalidate('Pro skladovou kartu musí být určena pouze hlavní jednotka')
      end;
      if self.GetFieldValueAsInteger('Itemtype')=4 then begin
          if self.GetFieldValueAsFloat('quantity')=0 then begin
              if self.GetFieldValueAsFloat('WorkHoursReal')<>0 then  self.SetFieldValueAsFloat('quantity',self.GetFieldValueAsFloat('WorkHoursReal'));
          end;
      end;
end;
end;


begin
end.

