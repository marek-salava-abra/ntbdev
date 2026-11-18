uses 'abra.eu.mask.2017.predvyplneni.funkce',
       'EU.Aabra.Mask.Validace.lib';

procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
  mCode: integer;
  mdivision: string;
  mrsa:tstringlist;
begin
  if self.GetFieldValueAsInteger('RowType')=3 then begin
         if mCode= Self.GetFieldCode('Storecard_ID') then begin
                   if (AOriginalValue.AsString <> AValue.AsString) and (AValue.AsString<>'0000000000') and (AValue.AsString<>'') then begin
                      mdivision:=(Self.GetFieldValueAsString('Store_id.X_BusDivision_ID'));
                      Self.SetFieldValueAsString('Division_id',mdivision );
                   end;
         end;
  end else begin
         if mCode = Self.GetFieldCode('BusProject_ID') then begin
               Self.SetFieldValueAsString('Division_id',Self.GetFieldValueAsString('BusProject_ID.Division_ID'));
         end;
  end;

end;



procedure AfterSoftValidate_Hook(Self: TNxCustomBusinessObject);
var
  mCode: integer;
  mr:tstringlist;
  mBO:TNxCustomBusinessObject;
  mDivision_id,mBusOrder_ID,mBustransaction_ID,mBusProject_ID,mbo_id:string;
begin

if NxIsEmptyOID(Self.GetFieldValueAsString('X_ProvideRow_ID')) then Self.SetFieldValueAsString('X_ProvideRow_ID',self.oid) ;
        if Self.GetFieldValueAsInteger('Rowtype')=3 then begin
                //Self.SetFieldValueAsString('BusOrder_id','');
                //Self.SetFieldValueAsString('BusProject_id','');
                mbo_id:='';

                if not NxIsEmptyOID((Self.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))) then begin
                             mBustransaction_ID:=(Self.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'));
                             Self.SetFieldValueAsString('BusTransaction_id',mBustransaction_ID );
                end;
            mBusOrder_ID:=GetBusOrder_ID(self);
                  if not nxisblank(mBusOrder_ID) then self.SetFieldValueAsString('BusOrder_id',mBusOrder_ID);
            mBusProject_ID:=GetProject_ID(self);
                  if not nxisblank(mBusProject_ID) then Self.SetFieldValueAsString('BusProject_id',mBusProject_ID);

        end else begin

        end;




end;



{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
  if NxIsEmptyOID(Self.GetFieldValueAsString('X_ProvideRow_ID')) then Self.SetFieldValueAsString('X_ProvideRow_ID',self.oid) ;
   if Self.GetFieldValueAsInteger('Rowtype')=3 then begin
                //Self.SetFieldValueAsString('BusOrder_id','');
                //Self.SetFieldValueAsString('BusProject_id','');


                if not NxIsEmptyOID((Self.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))) then begin
                             mBustransaction_ID:=(Self.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'));
                             Self.SetFieldValueAsString('BusTransaction_id',mBustransaction_ID );
                end;
            mBusOrder_ID:=GetBusOrder_ID(self);
                  if not nxisblank(mBusOrder_ID) then self.SetFieldValueAsString('BusOrder_id',mBusOrder_ID);
            mBusProject_ID:=GetProject_ID(self);
                  if not nxisblank(mBusProject_ID) then Self.SetFieldValueAsString('BusProject_id',mBusProject_ID);

        end else begin

        end;
end;

begin
end.
