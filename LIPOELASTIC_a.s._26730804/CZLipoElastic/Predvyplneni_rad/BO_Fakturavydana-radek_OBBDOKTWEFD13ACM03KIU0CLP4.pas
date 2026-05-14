
  {
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
  mCode: integer;
  mrsa,mr:tstringlist;
  msite:TSiteForm;
begin

    if (AFieldCode = Self.GetFieldCode('Storecard_ID')) then begin

          if ((self.GetFieldValueAsInteger('Parent_id.Tradetype')=7) and (nxisemptyoid(Self.getFieldValueAsString('VATIndex_ID')))) then begin
          NxShowSimpleMessage(self.GetFieldValueAsstring('VATRate_ID.ossgoodvatindex_ID'),NIL);
                 if nxisemptyoid(self.GetFieldValueAsstring('StoreCard_ID')) then begin
                       if self.GetFieldValueAsinteger('StoreCard_ID.OSSSupplyType')=2 then BEGIN
                       NxShowSimpleMessage('AAA',NIL);
                            Self.SetFieldValueAsString('VATIndex_ID', self.GetFieldValueAsstring('VATRate_ID.ossgoodvatindex_ID'));
                       END;
                       if self.GetFieldValueAsinteger('StoreCard_ID.OSSSupplyType')=1 then begin
                            Self.SetFieldValueAsString('VATIndex_ID', self.GetFieldValueAsstring('VATRate_ID.ossservicevatindex_ID'));
                            NxShowSimpleMessage('BBB',NIL);
                       end;
                 end;
          end;
    end;


  {
  if (AFieldCode = Self.GetFieldCode('Storecard_ID')) and (self.GetFieldValueAsInteger('RowType')=3) then begin
          if (self.GetFieldValueAsInteger('parent_id.Tradetype')=0) then begin
                           if nxisemptyoid(Self.GetFieldValueAsString('Storecard_ID.StoreCategory_ID.X_Tuzemsky')) then begin
                                   Self.SetFieldValueAsString('VATIndex_ID',Self.GetFieldValueAsString('Storecard_ID.StoreCategory_ID.X_Tuzemsky'));
                           end;
          end;
            if (self.GetFieldValueAsInteger('parent_id.Tradetype')=1) then begin
                           if nxisemptyoid(Self.GetFieldValueAsString('Storecard_ID.StoreCategory_ID.X_vEU')) then begin
                                   Self.SetFieldValueAsString('VATIndex_ID',Self.GetFieldValueAsString('Storecard_ID.StoreCategory_ID.X_vEu'));
                           end;
          end;

           if (self.GetFieldValueAsInteger('parent_id.Tradetype')=2) then begin
                           if nxisemptyoid(Self.GetFieldValueAsString('Storecard_ID.StoreCategory_ID.X_mimoEU')) then begin
                                   Self.SetFieldValueAsString('VATIndex_ID',Self.GetFieldValueAsString('Storecard_ID.StoreCategory_ID.X_mimoEu'));
                           end;
          end;

    end;

end;

  }






{
Vyvolává se při předvyplňování hodnot daného objektu.
}


{
Vyvolává se při předvyplňování hodnot daného objektu.
}
procedure Prefill_Hook(Self: TNxCustomBusinessObject);
var
mr:tstringlist;
begin
     if self.GetFieldValueAsInteger('Parent_id.TradeType')=7 then begin
            mr:=tstringlist.create;
                  try
                      self.ObjectSpace.SQLSelect('select ossgoodvatindex_ID from vatrates where country_ID=' + quotedstr(self.GetFieldValueAsString('Parent_ID.Country_ID')),mr);
                      if mr.count>0 then begin
                          Self.SetFieldValueAsString('VATIndex_ID',mr.Strings[0]);
                      end;
                  finally
                      mr.free;
                  end;
     end;
end;

procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin

    if ((self.GetFieldValueAsInteger('Parent_id.Tradetype')=7) ) then begin
       if not nxisemptyoid(self.GetFieldValueAsstring('Storecard_ID')) then begin
             if self.GetFieldValueAsinteger('Storecard_ID.OSSSupplyType')=2 then Self.SetFieldValueAsString('VATIndex_ID', self.GetFieldValueAsstring('VATRate_ID.ossgoodvatindex_ID'));
             if self.GetFieldValueAsinteger('Storecard_ID.OSSSupplyType')=1 then Self.SetFieldValueAsString('VATIndex_ID', self.GetFieldValueAsstring('VATRate_ID.ossservicevatindex_ID'));
       end;
    end;
end;

begin
end.


