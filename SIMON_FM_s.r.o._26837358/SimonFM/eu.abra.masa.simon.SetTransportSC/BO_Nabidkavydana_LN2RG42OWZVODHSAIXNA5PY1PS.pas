{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
var
 mRows:TNxCustomBusinessMonikerCollection;
 i:Integer;
 mRowBO:TNxCustomBusinessObject;
 mInsertTrans:Boolean;
 mIncomeType_ID:string;
begin
  mIncomeType_ID:='1500000101';
  if (self.GetFieldValueAsFloat('LocalAmountWithoutVAT')<5000)
     and (self.GetFieldValueAsString('DocQueue_ID')='2900000101')
     and not(self.GetFieldValueAsBoolean('Firm_ID.X_NoTransport'))
     and not(self.GetFieldValueAsBoolean('X_NoTransport')) then begin
   if self.GetFieldValueAsString('TransportationType_ID.code') in ['VO1','VO4'] then begin
     mRows:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows'));
     mInsertTrans:=True;
     for i:=0 to mRows.count-1 do begin
           mRowBO:=mRows.BusinessObject[i];
           if (NxSearch(mRowbo.GetFieldValueAsString('Text'),'Dopravné',[srall],0)>0) and not(osMarkForDelete in mRowBO.State) then begin
            mInsertTrans:=False;
            break;
           end;
         end;
     if mInsertTrans then begin
      mRowBO:=mRows.AddNewObject;
      mRowBO.Prefill;
      mRowBO.SetFieldValueAsInteger('RowType',1);
      mRowBO.SetFieldValueAsString('Text','Dopravné');
      mRowBO.SetFieldValueAsFloat('TotalPrice',100);
      mRowBO.SetFieldValueAsString('VatRate_ID','02100X0000');
      //mRowBO.SetFieldValueAsString('IncomeType_ID',mIncomeType_ID);
      mRowBO.SetFieldValueAsString('Division_ID',mRows.BusinessObject[0].GetFieldValueAsString('Division_ID'));
      mRowBO.SetFieldValueAsString('BusOrder_ID',mRows.BusinessObject[0].GetFieldValueAsString('BusOrder_ID'));
      mRowBO.SetFieldValueAsString('BusTransaction_ID',mRows.BusinessObject[0].GetFieldValueAsString('BusTransaction_ID'));
     end;
   end;
  end;
end;

procedure Prefill_Hook(Self: TNxCustomBusinessObject);
begin
  self.SetFieldValueAsDateTime('ValidTill$DATE',Date+28); //2000000101
  self.SetFieldValueAsDateTime('SentDate$DATE',Date);
  self.SetFieldValueAsDateTime('DeadLineToSend$DATE',Date);
  Self.SetFieldValueAsString('ResponsibleRole_ID','6100000101');
  Self.SetFieldValueAsString('ActualSolverRole_ID','6100000101');
end;

begin
end.

begin
end.