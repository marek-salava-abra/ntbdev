procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
  mCode: integer;
begin
  // Zjistime kod polozky Nazev
  mCode := Self.GetFieldCode('DocQueue_ID');
  // Pokud se meni polozka Nazev
  if AFieldCode = mCode then begin
    // A pokud v polozce Poznamka totez co bylo puvodne v polozce Nazev
    // zmenime polozku Poznamka

    if self.GetFieldValueAsString('Firm_ID')='JJHF800101' then begin
            if AOriginalValue.AsString <> AValue.AsString then  begin
               if AValue.AsString='2B10000101' then begin
                     Self.SetFieldValueAsString('PaymentType_ID', 'G000000101');
                     Self.SetFieldValueAsString('IntrastatTransactionType_ID','6001000000')  ;
                     Self.SetFieldValueAsString('ReasonDescription','Vrácení ESHOP')  ;

               end;
            end;
    end;

  end;
end;

begin
end.
