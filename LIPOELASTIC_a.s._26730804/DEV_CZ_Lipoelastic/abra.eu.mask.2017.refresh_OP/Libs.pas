function getquantity(self:TNxCustomBusinessObject):double;
var
mr:tstringlist;
begin
   // počet
   try
      mr:=TStringList.create;
      self.ObjectSpace.SQLSelect('Select sum((ro2.quantity*ro2.unitrate)) from receivedorders2 ro2 left join storecards SC on sc.id=ro2.storecard_id where ro2.parent_id='
       + quotedstr(self.oid) + ' and (ro2.rowtype=3) and sc.Storecardcategory_ID<>' + quotedstr('9000000101'),mr);
      if NxIBStrToFloat(mr.Strings[0])>0 then begin
          result:=NxIBStrToFloat(mr.Strings[0]);
      end;
   finally
      mr.free;
   end;
end;

function getinstore(self:TNxCustomBusinessObject):double;
var
mr:tstringlist;
mpocet:double;
mMon:TNxCustomBusinessMonikerCollection;
i:integer;
begin
   mpocet:=0;
   mMon := self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('ROWS'));
        for i := 0 to mMon.Count - 1 do begin
            if mMon.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.Storecardcategory_ID')<>'~00000000G' then begin
              mr:=TStringList.create;
              try
                  self.ObjectSpace.SQLSelect(format('Select sum(quantity) from storesubcards where StoreCard_ID=''%S'' and Store_ID=''%S''',[mMon.BusinessObject[i].GetFieldValueAsString('StoreCard_ID'),mMon.BusinessObject[i].GetFieldValueAsString('Store_ID')])
                  ,mr);

                        if NxIBStrToFloat(mr.Strings[0])>0 then begin
                           if NxIBStrToFloat(mr.Strings[0])>=((mMon.BusinessObject[i].GetFieldValueAsFloat('Quantity') * mMon.BusinessObject[i].GetFieldValueAsFloat('Unitrate')) -
                                (mMon.BusinessObject[i].GetFieldValueAsFloat('DeliveredQuantity') * mMon.BusinessObject[i].GetFieldValueAsFloat('Unitrate')) ) then begin
                                  mpocet:=mpocet+(((mMon.BusinessObject[i].GetFieldValueAsFloat('Quantity') * mMon.BusinessObject[i].GetFieldValueAsFloat('Unitrate')) -
                                (mMon.BusinessObject[i].GetFieldValueAsFloat('DeliveredQuantity') * mMon.BusinessObject[i].GetFieldValueAsFloat('Unitrate')) ));
                           end else begin
                                  mpocet:=mpocet + NxIBStrToFloat(mr.Strings[0]);
                           end;
                        end;
              finally
                 mr.free;
              end;
            end;

        end;
        result:=mpocet;
end;

function getreservation(self:TNxCustomBusinessObject):double;
var
mr:tstringlist;
begin
   // počet
   try
      mr:=TStringList.create;
      self.ObjectSpace.SQLSelect('select sum(r.Reserved) from receivedorders2 RO2 left join receivedorders ro on ro.id=ro2.parent_ID left join reservations R on r.Owner_ID=ro2.id  where ro.id =' + quotedstr(self.oid),mr);
      if NxIBStrToFloat(mr.Strings[0])>0 then begin
          result:=NxIBStrToFloat(mr.Strings[0]);
      end;
   finally
      mr.free;
   end;
end;

function getlogistic(self:TNxCustomBusinessObject):double;
var
mr:tstringlist;
begin
   try
      mr:=TStringList.create;
      self.ObjectSpace.SQLSelect('Select sum((X_vychystano*unitrate)) from receivedorders2 ro2 left join storecards SC on sc.id=ro2.storecard_id where ro2.parent_id='
       + quotedstr(self.oid) + ' and (ro2.rowtype=3) and sc.Storecardcategory_ID<>' + quotedstr('~00000000G'),mr);
      if NxIBStrToFloat(mr.Strings[0])>0 then begin
          result:= NxIBStrToFloat(mr.Strings[0]);
      end;
   finally
      mr.free;
   end;
end;

function getdelivered(self:TNxCustomBusinessObject):double;
var
mr:tstringlist;
begin
   // počet
   try
      mr:=TStringList.create;
      self.ObjectSpace.SQLSelect('Select sum((DeliveredQuantity*unitrate)) from receivedorders2 ro2 left join storecards SC on sc.id=ro2.storecard_id where ro2.parent_id='
       + quotedstr(self.oid) + ' and (ro2.rowtype=3) and sc.Storecardcategory_ID<>' + quotedstr('~00000000G'),mr);
      if NxIBStrToFloat(mr.Strings[0])>0 then begin
          result:=NxIBStrToFloat(mr.Strings[0]);
      end;
   finally
      mr.free;
   end;

end;

begin
end.