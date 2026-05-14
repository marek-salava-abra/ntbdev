procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
var
 mRows:TNxCustomBusinessMonikerCollection;
 i:Integer;
 mRowBO:TNxCustomBusinessObject;
 mInsertTrans:Boolean;
 mIncomeType_ID:string;
begin
  mIncomeType_ID:='1500000101';
  if NxIsEmptyOID(self.GetFieldValueAsString('U_OrigOrderID')) then begin
      if (self.GetFieldValueAsFloat('LocalAmountWithoutVAT')<5000)
         and (self.GetFieldValueAsString('DocQueue_ID')='7RQ0000101')
         and not(self.GetFieldValueAsBoolean('Firm_ID.X_NoTransport'))
         and not(self.GetFieldValueAsBoolean('X_NoTransport')) then begin
       if self.GetFieldValueAsString('TransportationType_ID.code') in ['VO1','VO4'] then begin
         mRows:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows'));
         mInsertTrans:=True;
         for i:=0 to mRows.count-1 do begin
           mRowBO:=mRows.BusinessObject[i];
           if mInsertTrans and (NxSearch(mRowbo.GetFieldValueAsString('Text'),'Dopravné',[srall],0)>0) and not(osMarkForDelete in mRowBO.State) then mInsertTrans:=False;
         end;
         if mInsertTrans then begin
          mRowBO:=mRows.AddNewObject;
          mRowBO.Prefill;
          mRowBO.SetFieldValueAsInteger('RowType',1);
          mRowBO.SetFieldValueAsString('Text','Dopravné');
          mRowBO.SetFieldValueAsFloat('TotalPrice',100);
          mRowBO.SetFieldValueAsString('VatRate_ID','02100X0000');
          mRowBO.SetFieldValueAsString('IncomeType_ID',mIncomeType_ID);
          mRowBO.SetFieldValueAsString('Division_ID',mRows.BusinessObject[0].GetFieldValueAsString('Division_ID'));
          mRowBO.SetFieldValueAsString('BusOrder_ID',mRows.BusinessObject[0].GetFieldValueAsString('BusOrder_ID'));
          mRowBO.SetFieldValueAsString('BusTransaction_ID',mRows.BusinessObject[0].GetFieldValueAsString('BusTransaction_ID'));
         end;
       end;
      end;
   end;
end;

begin
end.