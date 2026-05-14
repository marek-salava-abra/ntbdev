procedure RoundingAmount (AObj: TNxCustomBusinessObject);
var
 mBO:TNxCustomBusinessObject;
 mVatRate, mAmount, mAmountVAT:Extended;
begin
     if AObj.GetFieldValueAsString('Price_ID')='1100000101' then begin
      mAmount:=AObj.GetFieldValueAsFloat('Amount');
      mAmount:=NxRoundByValue(mAmount,ctUp,0.1);
      AObj.SetFieldValueAsFloat('Amount',mAmount);
     end;
end;

begin
end.