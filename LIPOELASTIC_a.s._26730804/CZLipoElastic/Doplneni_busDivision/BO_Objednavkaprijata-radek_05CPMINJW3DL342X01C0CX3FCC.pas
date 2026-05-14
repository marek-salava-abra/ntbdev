uses 'EU.Aabra.Mask.Validace.lib';
var
mdivision: string;



{
Vyvolává se bezprostředně po provedení softvalidace objektu.
}
{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
 mBusProject_ID, mBusOrder_ID:string;
 mOS:TNxCustomObjectSpace;
begin
  mOS:=self.ObjectSpace;
  if (AFieldCode=self.GetFieldCode('StoreCard_ID')) and not(AValue.AsString=AOriginalValue.AsString) then begin
    if NxIsEmptyOID(self.GetFieldValueAsString('StoreCard_ID')) then begin
      self.SetFieldValueAsString('BusTransaction_ID', '');
      self.SetFieldValueAsString('BusOrder_ID','');
      self.SetFieldValueAsString('BusProject_ID','');
      self.SetFieldValueAsString('Division_ID','');
    end else begin
      //NxShowSimpleMessage('TEST',nil);
      if not(NxIsEmptyOID(self.GetFieldValueAsString('StoreCard_ID.X_BusTransaction_ID'))) then begin
        mBusProject_ID:=mOS.SQLSelectFirstAsString('Select X_BusProject_id from defrolldata where clsid='+QuotedStr(Class_Predvyplnovani)+' and X_firm_id='+
                                                   QuotedStr(self.GetFieldValueAsString('Parent_ID.Firm_ID'))+' and X_Office_ID='+
                                                   QuotedStr(self.GetFieldValueAsString('Parent_ID.FirmOffice_ID'))+' and X_BusTransaction_ID='+
                                                   QuotedStr(self.GetFieldValueAsString('StoreCard_ID.X_BusTransaction_ID')),'');
        if NxIsEmptyOID(mBusProject_ID) then
         mBusProject_ID:=mOS.SQLSelectFirstAsString('Select X_BusProject_id from defrolldata where clsid='+QuotedStr(Class_Predvyplnovani)+' and X_firm_id='+
                                                   QuotedStr(self.GetFieldValueAsString('Parent_ID.Firm_ID'))+' and X_BusTransaction_ID='+
                                                   QuotedStr(self.GetFieldValueAsString('StoreCard_ID.X_BusTransaction_ID')),'');
        mBusOrder_ID:=mOS.SQLSelectFirstAsString('Select X_BusOrder_id from defrolldata where clsid='+QuotedStr(Class_Predvyplnovani)+' and X_firm_id='+
                                                   QuotedStr(self.GetFieldValueAsString('Parent_ID.Firm_ID'))+' and X_Office_ID='+
                                                   QuotedStr(self.GetFieldValueAsString('Parent_ID.FirmOffice_ID'))+' and X_BusTransaction_ID='+
                                                   QuotedStr(self.GetFieldValueAsString('StoreCard_ID.X_BusTransaction_ID')),'');
        if NxIsEmptyOID(mBusOrder_ID) then
         mBusOrder_ID:=mOS.SQLSelectFirstAsString('Select X_BusOrder_id from defrolldata where clsid='+QuotedStr(Class_Predvyplnovani)+' and X_firm_id='+
                                                   QuotedStr(self.GetFieldValueAsString('Parent_ID.Firm_ID'))+' and X_BusTransaction_ID='+
                                                   QuotedStr(self.GetFieldValueAsString('StoreCard_ID.X_BusTransaction_ID')),'');
        {NxShowSimpleMessage('Select X_BusProject_id from defrolldata where clsid='+QuotedStr(Class_Predvyplnovani)+' and X_firm_id='+
                                                   QuotedStr(self.GetFieldValueAsString('Parent_ID.Firm_ID'))+' and X_Office_ID='+
                                                   QuotedStr(self.GetFieldValueAsString('Parent_ID.FirmOffice_ID'))+' and X_BusTransaction_ID='+
                                                   QuotedStr(self.GetFieldValueAsString('StoreCard_ID.X_BusTransaction_ID')), nil);  }
        if not(NxIsEmptyOID(mBusOrder_ID)) then self.SetFieldValueAsString('BusOrder_ID',mBusOrder_ID);
        if not(NxIsEmptyOID(mBusProject_ID)) then begin
         self.SetFieldValueAsString('BusProject_ID',mBusProject_ID);
         self.SetFieldValueAsString('Division_ID',self.GetFieldValueAsString('BusProject_ID.Division_ID'));
        end;
        self.SetFieldValueAsString('BusTransaction_ID',self.GetFieldValueAsString('StoreCard_ID.X_BusTransaction_ID'));
      end;
    end;
  end;
  if (AFieldCode=self.GetFieldCode('BusTransaction_ID')) and not(AValue.AsString=AOriginalValue.AsString) then begin
    try
     //NxShowSimpleMessage('TEST',nil);
      if NxIsEmptyOID(self.getFieldValueAsString('BusProject_ID')) then
       self.SetFieldValueAsString('BusProject_ID', self.GetFieldValueAsString('Parent_ID.Firm_ID.X_BusProject_ID'));
      if NxIsEmptyOID(self.getFieldValueAsString('BusOrder_ID')) then
       self.SetFieldValueAsString('BusOrder_ID', self.GetFieldValueAsString('Parent_ID.Firm_ID.X_BusOrder_ID'));
      if NxIsEmptyOID(self.getFieldValueAsString('Division_ID')) then
        self.SetFieldValueAsString('Division_ID', self.GetFieldValueAsString('Parent_ID.Firm_ID.X_BusProject_ID.Division_ID'));
    except

    end;
  end;
end;

procedure AfterSoftValidate_Hook(Self: TNxCustomBusinessObject);
begin
        if Self.GetFieldValueAsInteger('Rowtype')=3 then begin
          if NxIsEmptyOID(Self.GetFieldValueAsString('Division_id')) then begin
                  mdivision:=(Self.GetFieldValueAsString('Store_id.X_BusDivision_ID'));
                  Self.SetFieldValueAsString('Division_id',mdivision );
          end;
         end;
end;




procedure Prefill_Hook(Self: TNxCustomBusinessObject);
begin
//Self.SetFieldValueAsString('Division_id','1000000101' );
end;

begin
end.
