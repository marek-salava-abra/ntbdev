procedure RoundingAmount (AObj: TNxCustomBusinessObject);
var
 mBO:TNxCustomBusinessObject;
 mVatRate, mAmount, mAmountVAT:Extended;
begin
     mVatRate:=AObj.GetFieldValueAsFloat('Parent_ID.StoreCard_ID.VATRate');
     mAmount:=AObj.GetFieldValueAsFloat('Amount');
     mAmountVAT:= ((100+mVatRate)/100)*mAmount;
     mAmountVAT:=NxRoundByValue(mAmountVAT,ctArithmetic,1);
     mAmount:=mAmountVAT/((100+mVatRate)/100);
     AObj.SetFieldValueAsFloat('Amount',mAmount);
end;




begin
end.