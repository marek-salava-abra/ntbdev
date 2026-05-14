{
Vyvolává se po změně každé položky. A to pouze, pokud k této změně nedochází díky načítání objektu z databáze nebo díky vytváření kopie.
}
procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
Var
 mKusy, mPary:Extended;
begin
  if self.GetFieldValueAsInteger('RowType')=3 then begin
    if (AFieldCode=self.GetFieldCode('StoreCard_ID')) or (AFieldCode=self.GetFieldCode('Quantity')) then begin
     self.GetOriginalValue_1('quantity',mKusy);
     NxShowSimpleMessage(FloatToStr(mKusy),nil);
     self.GetOriginalValue_1('X_CountPar',mPary);
     if self.GetFieldValueAsString('Qunit')='ks' then self.SetFieldValueAsFloat('X_CountKS',self.GetFieldValueAsFloat('Quantity'));
     if self.GetFieldValueAsString('Qunit')='pár' then self.SetFieldValueAsFloat('X_CountPAR',self.GetFieldValueAsFloat('Quantity'));
     self.SetFieldValueAsFloat('Parent_ID.X_CountKS',self.GetFieldValueAsFloat('Parent_ID.X_CountKS')-mKusy+self.GetFieldValueAsFloat('X_CountKS'));
     self.SetFieldValueAsFloat('Parent_ID.X_CountPAR',self.GetFieldValueAsFloat('Parent_ID.X_CountPAR')-mPary+self.GetFieldValueAsFloat('X_CountPAR'));
    end;
  end;
end;


procedure AfterSoftDelete_Hook(Self: TNxCustomBusinessObject);
Var
 mKusy, mPary:Extended;
begin

  self.SetFieldValueAsFloat('Parent_ID.X_CountKS',self.GetFieldValueAsFloat('Parent_ID.X_CountKS')-mKusy);
  self.SetFieldValueAsFloat('Parent_ID.X_CountPAR',self.GetFieldValueAsFloat('Parent_ID.X_CountPAR')-mPary);
end;





begin
end.