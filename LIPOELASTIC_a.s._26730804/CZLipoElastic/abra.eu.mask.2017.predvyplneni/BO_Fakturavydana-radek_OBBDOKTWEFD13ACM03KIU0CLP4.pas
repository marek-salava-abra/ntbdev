uses 'abra.eu.mask.2017.predvyplneni.funkce', 'EU.Aabra.Mask.Validace.lib';

procedure AfterSoftValidate_Hook(Self: TNxCustomBusinessObject);
var
  mCode: integer;
  mr:tstringlist;
  mBO:TNxCustomBusinessObject;
  mDivision_id,mBusOrder_ID,mBustransaction_ID,mBusProject_ID,mbo_id:string;
begin
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




procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
  mCode: integer;
  mdivision: string;
begin
  //if nxisemptyoid(self.GetFieldValueAsstring('Division_ID')) then begin
         if ((Self.GetFieldValueAsInteger('Rowtype')<>3) and (Self.GetFieldValueAsInteger('Rowtype')<>2) and (Self.GetFieldValueAsInteger('Rowtype')<>5))  then begin
            if mCode = Self.GetFieldCode('BusProject_ID') then begin
                if AOriginalValue.AsString<>AValue.AsString then begin
                  Self.SetFieldValueAsString('Division_id',Self.GetFieldValueAsString('BusProject_ID.Division_ID'));
               //NxShowSimpleMessage('AAA',nil);
               //NxShowSimpleMessage(Self.GetFieldValueAsString('BusProject_ID.Division_ID'),nil);
                end;
            end;
         end
  //end;

end;

{
Vyvolává se bezprostředně před provedením softvalidace objektu.
}
procedure BeforeSoftValidate_Hook(Self: TNxCustomBusinessObject);
begin
      if ((Self.GetFieldValueAsInteger('Rowtype')<>3) and (Self.GetFieldValueAsInteger('Rowtype')<>2) and (Self.GetFieldValueAsInteger('Rowtype')<>5)) then Self.SetFieldValueAsString('Division_id',Self.GetFieldValueAsString('BusProject_ID.Division_ID'));


end;




{
Vyvolává se při předvyplňování hodnot daného objektu.
}
procedure Prefill_Hook(Self: TNxCustomBusinessObject);
begin
      self.SetFieldValueAsString('BusOrder_ID','');
      self.SetFieldValueAsString('BusTransaction_ID','');
      self.SetFieldValueAsString('BusProject_ID','');
      Self.SetFieldValueAsString('Division_ID','1N00000101');
end;

{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
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
