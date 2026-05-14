uses
  'eu.simon.OBVtoPR.fce';


{

procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
 mOS:TNxCustomObjectSpace;
 mOrder_ID, mOrderRow_ID:String;
 mImportMan:TNxDocumentImportManager;
 mInputParams: TNxParameters;
 mGRows:TMultiGrid;
 mParam: TNxParameter;
 j: integer;
mReceivedOrder:TNxCustomBusinessObject;
mRORows:TNxCustomBusinessMonikerCollection;
begin
  if
   (AFieldCode=self.GetFieldCode('Quantity')) and
   (AValue<>AOriginalValue) and
   (self.GetFieldValueAsBoolean('Parent_ID.U_SearchOrder')) and NxIsEmptyOID(self.GetFieldValueAsString('ProvideRow_ID')) and not(NxIsEmptyOID(self.GetFieldValueAsString('StoreCard_ID')))
   then begin
      mOS:=self.ObjectSpace;
      mOrderRow_ID:=scrOrderRow_id(mOS,self.GetFieldValueAsString('parent_id.firm_id'),self.GetFieldValueAsString('StoreCard_ID'));
      if not(NxIsEmptyOID(mOrderRow_ID)) then begin
        mOrder_ID:=scrOrder_ID(mOS,mOrderRow_ID);
        self.SetFieldValueAsString('Provide_ID',mOrder_ID);
        self.SetFieldValueAsString('ProvideRow_ID',mOrderRow_ID);
        mReceivedOrder:=self.ObjectSpace.CreateObject(Class_IssuedOrder);
       if not(NxIsEmptyOID(self.GetFieldValueAsString('Provide_ID'))) then begin
       mReceivedOrder.Load(self.GetFieldValueAsString('Provide_ID'),nil);
       mRORows:=mReceivedOrder.GetLoadedCollectionMonikerForFieldCode(mReceivedOrder.GetFieldCode('Rows'));
       for j:= 0 to mRORows.Count-1 do begin
        if (self.GetFieldValueAsString('ProvideRow_ID')=mRORows.BusinessObject[j].oid) then
         mRORows.BusinessObject[j].SetFieldValueAsFloat('DeliveredQuantity',mRORows.BusinessObject[j].getfieldvalueasfloat('DeliveredQuantity')+self.GetFieldValueAsFloat('Quantity'));
         mRORows.BusinessObject[j].Invalidate;

       end;
       mReceivedOrder.Invalidate;
       mReceivedOrder.save;
       if Assigned(mReceivedOrder) then mReceivedOrder.Free;
       end;
      end;

   end;

end;









Umožňuje ovlivnit validaci.

procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mOS:TNxCustomObjectSpace;
 mOrder_ID, mOrderRow_ID:String;
 mImportMan:TNxDocumentImportManager;
 mInputParams: TNxParameters;
 mGRows:TMultiGrid;
 mParam: TNxParameter;
 j: integer;
mReceivedOrder:TNxCustomBusinessObject;
mRORows:TNxCustomBusinessMonikerCollection;
begin
  if
   (self.GetFieldValueAsBoolean('Parent_ID.U_SearchOrder')) and NxIsEmptyOID(self.GetFieldValueAsString('ProvideRow_ID')) and not(NxIsEmptyOID(self.GetFieldValueAsString('StoreCard_ID')))
   then begin
      mOS:=self.ObjectSpace;
      mOrderRow_ID:=scrOrderRow_id(mOS,self.GetFieldValueAsString('parent_id.firm_id'),self.GetFieldValueAsString('StoreCard_ID'),self.GetFieldValueAsString('Store_ID'));
     try
      if not(NxIsEmptyOID(mOrderRow_ID)) then begin
        mOrder_ID:=scrOrder_ID(mOS,mOrderRow_ID);
        self.SetFieldValueAsString('Provide_ID',mOrder_ID);
        self.SetFieldValueAsString('ProvideRow_ID',mOrderRow_ID);
        self.SetFieldValueAsString('ProvideRowType','IO');
        mReceivedOrder:=self.ObjectSpace.CreateObject(Class_IssuedOrder);
       if not(NxIsEmptyOID(self.GetFieldValueAsString('Provide_ID'))) then begin
       mReceivedOrder.Load(self.GetFieldValueAsString('Provide_ID'),nil);
       mRORows:=mReceivedOrder.GetLoadedCollectionMonikerForFieldCode(mReceivedOrder.GetFieldCode('Rows'));
       for j:= 0 to mRORows.Count-1 do begin
        if (self.GetFieldValueAsString('ProvideRow_ID')=mRORows.BusinessObject[j].oid) then
         mRORows.BusinessObject[j].SetFieldValueAsFloat('DeliveredQuantity',mRORows.BusinessObject[j].getfieldvalueasfloat('DeliveredQuantity')+self.GetFieldValueAsFloat('Quantity'));
         mRORows.BusinessObject[j].Invalidate;
         self.SetFieldValueAsString('U_info', mRORows.BusinessObject[j].GetFieldValueAsString('U_info'));
         self.SetFieldValueAsString('U_info2', mRORows.BusinessObject[j].GetFieldValueAsString('U_info2'));
       end;
       mReceivedOrder.Invalidate;
       mReceivedOrder.save;
       if Assigned(mReceivedOrder) then mReceivedOrder.Free;
       end;
      end;
     except
     end;
    end;
end;  }

begin
end.