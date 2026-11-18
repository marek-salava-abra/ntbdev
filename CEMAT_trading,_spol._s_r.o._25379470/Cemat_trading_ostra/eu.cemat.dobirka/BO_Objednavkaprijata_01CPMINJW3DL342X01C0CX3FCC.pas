{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}

procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
 mRowBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mDataSet: TDataSet;
begin
  if (AFieldCode=self.GetFieldCode('Firm_ID')) and not(AValue.AsString=AOriginalValue.AsString) then self.SetFieldValueAsString('PaymentType_ID','1000000101');
  if (AFieldCode=self.GetFieldCode('PaymentType_ID')) and not(AValue.AsString=AOriginalValue.AsString) then begin
   try
    if self.GetFieldValueAsString('PaymentType_ID.Code')='D1' then begin
       mRows:=self.GetLoadedCollectionMonikerForFieldCode(Self.GetFieldCode('Rows'));
       mRowBO:=mRows.AddNewObject;
       mRowBO.SetFieldValueAsInteger('RowType',3);
       mRowBo.SetFieldValueAsString('StoreCard_ID','61Y1000101');
       mRowBO.SetFieldValueAsFloat('Quantity',1);
       mRowBO.SetFieldValueAsString('Division_ID','1000000101');
       if GlobParams.ParamExist('CematDSPointer') then   begin
          mDataSet := TDataSet(GlobParams.ParamByName('CematDSPointer').AsInteger);
          if mDataSet <> nil then begin
              mDataSet.Refresh;
              mDataSet.Resync(rmCenter);
          end;
       end;
    end;
    finally


  end;
 end;
end;

begin
end.