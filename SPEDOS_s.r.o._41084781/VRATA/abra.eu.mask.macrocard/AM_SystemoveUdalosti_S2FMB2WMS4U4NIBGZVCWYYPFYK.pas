procedure MacrocardDecomposition_Hook(Self: TNxContext; ARow: TNxCustomBusinessObject; AMacrocard: TNxCustomBusinessObject; AComponent: TNxCustomBusinessObject);
var
  mMon:TNxCustomBusinessMonikerCollection;
  mBoolean:boolean;
begin
   try
  if (self.GetCompanyCache.GetUserID='3C00000101')  or (self.GetCompanyCache.GetUserID='M100000101')  then begin

        arow.setFieldValueAsString('X_Group_macro_ID',AMacrocard.oid);

                     if uppercase(AMacrocard.GetFieldValueAsString('Specification2'))='ND' then begin

                                   if AComponent.GetFieldValueAsBoolean('X_Stop_quantity') then arow.SetFieldValueAsFloat('Quantity',AComponent.getFieldValueAsFloat('UnitQuantity'));


                                   if not NxIsEmptyOID(AComponent.getFieldValueAsString('Storecard_ID.X_store_id')) then begin
                                       arow.SetFieldValueAsstring('Store_id',AComponent.getFieldValueAsString('Storecard_ID.X_store_id'));
                                   end;


                                   if AComponent.getFieldValueAsString('Storecard_ID.name')=AMacrocard.GetFieldValueAsString('name') then begin
                                         arow.SetFieldValueAsFloat('Quantity',AComponent.getFieldValueAsFloat('UnitQuantity'));
                                        //arow.SetFieldValueAsFloat('DeliveredQuantity',arow.getFieldValueAsFloat('Quantity'));
                                          // NxShowSimpleMessage('Hlavní karta',nil);
                                   end else begin

                                   end;
                                   if AComponent.GetFieldValueAsBoolean('X_Voba') then begin
                                      mBoolean:= InputQuery('Použít položku',AComponent.GetFieldValueAsString('Storecard_id.name'),'') ;
                                            if not mBoolean then begin
                                                    //NxShowSimpleMessage('Mazani',nil);
                                                    arow.MarkForDelete;
                                            end;
                                    end;
                      end;

    end;
    finally

    end;
end;

begin
end.