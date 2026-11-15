{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mRows:TNxCustomBusinessMonikerCollection;
 i:integer;
 mReservation_ID, mOrder_ID:string;
 mOS:TNxCustomObjectSpace;
 mQuantity:Extended;
 mResBO:TNxCustomBusinessObject;
begin
  mRows:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows'));
  mOS:=self.ObjectSpace;
  for i:=0 to mRows.Count-1 do begin
   if mRows.BusinessObject[i].GetFieldValueAsString('Store_ID')='4P00000101' then begin
      mOrder_ID:=mOS.SQLSelectFirstAsString('select source_id from receivedorderstoISSUEDORDERS where target_id='+QuotedStr(mrows.BusinessObject[i].OID),'');
      if not(NxIsEmptyOID(mOrder_ID)) then begin
         mQuantity:=mOS.SQLSelectFirstAsExtended('Select quantity from receivedorders2 where id='+QuotedStr(mOrder_ID),0);
         if (mRows.BusinessObject[i].GetFieldValueAsFloat('Quantity')>=mQuantity) and (mRows.BusinessObject[i].GetFieldValueAsFloat('DeliveredQuantity')=0) then begin
           mReservation_ID:=mOS.SQLSelectFirstAsString('Select id from reservations where ownerkind=0 and owner_id='+QuotedStr(mOrder_ID),'');
           if not(NxIsEmptyOID(mReservation_ID)) then begin
              mResBO:=mOS.CreateObject(Class_Reservation);
              mresbo.Load(mReservation_ID,nil);
              mResBO.SetFieldValueAsFloat('Reserved',0);
              mresbo.save;
              mresbo.Free;
           end;
         end;
      end;
   end;
  end;
end;

begin
end.