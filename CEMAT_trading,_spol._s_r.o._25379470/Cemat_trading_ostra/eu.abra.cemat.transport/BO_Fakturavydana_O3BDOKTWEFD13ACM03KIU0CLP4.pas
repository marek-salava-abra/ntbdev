procedure _BeforeSave_PreHook(Self: TNxCustomBusinessObject);
var
mhead, mrow, mCurrentRowBO: TNxCustomBusinessObject;
mhead2: TNxCustomHeaderBusinessObject;
mrows: TNxCustomBusinessMonikerCollection;
deliveryrow,orderrow,orderhead: TNxBusinessMoniker;
i: integer;
delivery_used, delivery_invoiced: boolean;
Store_id, BusOrder_id, BusTransaction_ID: string;

begin
  delivery_used:=false;
  delivery_invoiced:=true;
   try

                mHead2 := TNxHeaderBusinessObject(self);

                for i := 0 to (mhead2.GetCollectionMonikerForFieldCode(mHead2.GetFieldCode('Rows')).Count - 1) do begin
                        mCurrentRowBO := mhead2.GetCollectionMonikerForFieldCode(mHead2.GetFieldCode('Rows')).BusinessObject(i);
                        if (mCurrentRowBO.GetFieldValueAsInteger('RowType')=3) then begin
                        if (mCurrentRowBO.GetMonikerForFieldCode(mCurrentRowBO.GetFieldCode('StoreCard_ID')).BusinessObject.GetFieldValueAsString('StoreCardCategory_ID')='1800000101') then delivery_used:=true;
                        if i=0 then begin
                           Store_id:=mCurrentRowBO.GetFieldValueAsString('Store_ID');
                           BusOrder_id:=mCurrentRowBO.GetFieldValueAsString('BusOrder_ID');
                           BusTransaction_ID:=mCurrentRowBO.GetFieldValueAsString('BusTransaction_ID');
                        end;
                        if delivery_used=true then begin
                          delivery_invoiced:=self.GetFieldValueAsBoolean('U_delivery_invoiced');
                        if delivery_invoiced=false then begin
                        self.SetFieldValueAsFloat('X_delivery_amount',mCurrentRowBO.GetFieldValueAsFloat('TAmountWithoutVAT'));
                        mCurrentRowBO.MarkForDelete;
                        end;
                        //delivery_used:=false;
                        end;
                        end;
                        //showmessage(mCurrentRowBO.GetFieldValueAsString('id'));
               end;
        finally

        end;

end;

begin
end.