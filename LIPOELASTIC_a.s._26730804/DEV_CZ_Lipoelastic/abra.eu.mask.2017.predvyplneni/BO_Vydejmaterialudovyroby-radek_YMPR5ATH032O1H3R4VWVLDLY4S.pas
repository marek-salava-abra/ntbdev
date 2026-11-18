uses 'abra.eu.mask.2017.predvyplneni.funkce','EU.Aabra.Mask.Validace.lib';

procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
  mCode: integer;
  mdivision,mBustransaction_ID,mBusProject_ID: string;
begin
  //if self.GetFieldValueAsInteger('RowType')=3 then begin
         if mCode= Self.GetFieldCode('Storecard_ID') then begin
                      mdivision:=(Self.GetFieldValueAsString('Store_id.X_BusDivision_ID'));
                      Self.SetFieldValueAsString('Division_id',mdivision );
                      if not NxIsEmptyOID((Self.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))) then begin
                             mBustransaction_ID:=(Self.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'));
                             Self.SetFieldValueAsString('BusTransaction_id',mBustransaction_ID );
                      end;

                      mBusProject_ID:=GetProject_ID(self);
                      if not nxisblank(mBusProject_ID) then Self.SetFieldValueAsString('BusProject_id',mBusProject_ID);

          end;


  //       end;
  //end else begin
  //
  //end;

end;

{
procedure BeforeSoftValidate_Hook(Self: TNxCustomBusinessObject);
var
  mdivision: string;
begin
  if (self.GetFieldValueAsString('StoreCard_id.X_BusDivision_ID')='3300000101') or
     (self.GetFieldValueAsString('StoreCard_id.X_BusDivision_ID')='2W10000101') then begin
                    Self.SetFieldValueAsString('Division_id','3300000101');
  end else begin
      mdivision:=(Self.GetFieldValueAsString('Store_id.X_BusDivision_ID'));
      Self.SetFieldValueAsString('Division_id',mdivision );
  end;
end;

 }



procedure AfterSoftValidate_Hook(Self: TNxCustomBusinessObject);
var
  mCode: integer;
  mr:tstringlist;
  mBO:TNxCustomBusinessObject;
  mDivision_id,mBusOrder_ID,mBustransaction_ID,mBusProject_ID,mbo_id:string;
begin
        if true then begin
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

        end;




end;







{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
var
  mCode: integer;
  mr:tstringlist;
  mBO:TNxCustomBusinessObject;
  mDivision_id,mBusOrder_ID,mBustransaction_ID,mBusProject_ID,mbo_id:string;
begin
        if true then begin
                //Self.SetFieldValueAsString('BusOrder_id','');
                //Self.SetFieldValueAsString('BusProject_id','');
                mbo_id:='';

                mBustransaction_ID:=(Self.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'));
                Self.SetFieldValueAsString('BusTransaction_id',mBustransaction_ID );

               mBusOrder_ID:=GetBusOrder_ID(self);
                if not nxisblank(mBusOrder_ID) then self.SetFieldValueAsString('BusOrder_id',mBusOrder_ID);
                mBusProject_ID:=GetProject_ID(self);
                if not nxisblank(mBusProject_ID) then Self.SetFieldValueAsString('BusProject_id',mBusProject_ID);

        end;



end;

begin
end.
