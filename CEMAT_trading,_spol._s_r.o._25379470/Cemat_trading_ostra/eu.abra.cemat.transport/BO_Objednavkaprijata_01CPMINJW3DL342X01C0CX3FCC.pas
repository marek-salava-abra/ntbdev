procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
mhead, mrow, mCurrentRowBO: TNxCustomBusinessObject;
mhead2: TNxCustomHeaderBusinessObject;
mrows: TNxCustomBusinessMonikerCollection;
i: integer;
delivery_used: boolean;
Store_id, BusOrder_id, BusTransaction_ID: string;

begin
  delivery_used:=false;
   try

                mHead2 := TNxHeaderBusinessObject(self);

                for i := 0 to (mhead2.GetCollectionMonikerForFieldCode(mHead2.GetFieldCode('Rows')).Count - 1) do begin
                        mCurrentRowBO := mhead2.GetCollectionMonikerForFieldCode(mHead2.GetFieldCode('Rows')).BusinessObject(i);
                        if mCurrentRowBO.GetFieldValueAsInteger('RowType')=3 then begin
                        if mCurrentRowBO.GetMonikerForFieldCode(mCurrentRowBO.GetFieldCode('StoreCard_ID')).BusinessObject.GetFieldValueAsString('StoreCardCategory_ID')='1800000101' then delivery_used:=true;
                        if i=0 then begin
                           Store_id:=mCurrentRowBO.GetFieldValueAsString('Store_ID');
                           BusOrder_id:=mCurrentRowBO.GetFieldValueAsString('BusOrder_ID');
                           BusTransaction_ID:=mCurrentRowBO.GetFieldValueAsString('BusTransaction_ID');
                        end;
                        if (delivery_used=true) and (mCurrentRowBO.GetMonikerForFieldCode(mCurrentRowBO.GetFieldCode('StoreCard_ID')).BusinessObject.GetFieldValueAsString('StoreCardCategory_ID')='1800000101') then begin
                        mCurrentRowBO.SetFieldValueAsString('StoreCard_id',self.GetMonikerForFieldCode(self.GetFieldCode('TransportationType_ID')).BusinessObject.GetFieldValueAsString('X_delivery_storecard'));
                        //delivery_used:=false;
                        end;
                        if (delivery_used=true) and NxIsEmptyOID(self.GetMonikerForFieldCode(self.GetFieldCode('TransportationType_ID')).BusinessObject.GetFieldValueAsString('X_delivery_storecard')) then begin
                        mCurrentRowBO.MarkForDelete;
                        end;
                        end;
                        //showmessage(mCurrentRowBO.GetFieldValueAsString('id'));
               end;
        finally

        end;




   if (delivery_used=false) and (self.GetFieldValueAsBoolean('X_delivery_use')=true) and ((not NxIsEmptyOID(self.GetMonikerForFieldCode(self.GetFieldCode('TransportationType_ID')).BusinessObject.GetFieldValueAsString('X_delivery_storecard')))) then begin
   try

      mhead:= self;
      mRows := mHead.GetCollectionMonikerForFieldCode(mHead.GetFieldCode('Rows'));
      mrow:= mrows.AddNewObject;

                mrow.Prefill;
                mrow.SetFieldValueAsInteger('RowType', 3);
                if not (Store_id='') then mrow.setFieldValueAsString('Store_ID',Store_id)
                else
                mrow.setFieldValueAsString('Store_ID','3000000101');
                mrow.SetFieldValueAsString('StoreCard_ID', self.GetMonikerForFieldCode(self.GetFieldCode('TransportationType_ID')).BusinessObject.GetFieldValueAsString('X_delivery_storecard'));
                mrow.SetFieldValueAsFloat('Quantity',1);
                mrow.SetFieldValueAsString('Division_ID', '1000000101');
                if not (BusOrder_id='') then mrow.SetFieldValueAsString('BusOrder_ID', BusOrder_id)
                else
                mrow.SetFieldValueAsString('BusOrder_ID', '8000000101');
                if not (BusTransaction_id='') then mrow.SetFieldValueAsString('BusTransaction_ID', BusTransaction_ID)
                else
                mrow.SetFieldValueAsString('BusTransaction_ID', '1000000101');

   finally
    AResult:=True;
   end;
   end;
end;

begin
end.