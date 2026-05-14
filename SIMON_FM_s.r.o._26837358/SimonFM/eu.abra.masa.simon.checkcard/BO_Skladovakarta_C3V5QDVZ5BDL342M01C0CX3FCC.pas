{
Vyvolává se po změně každé položky. A to vždy.
}
procedure _AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
begin
  if (AFieldCode=self.GetFieldCode('U_SendToES')) and (self.GetFieldValueAsBoolean('U_SendToES'))  and not(avalue.AsBoolean=AOriginalValue.AsBoolean) then begin
     self.SetFieldValueAsBoolean('X_ESCard',True);
     self.SetFieldValueAsBoolean('X_PPC_reklama',True);
     self.SetFieldValueAsBoolean('X_Free_store_pickup',True);
  end;
  if (AFieldCode=self.GetFieldCode('X_Extended_Warranty')) and (self.GetFieldValueAsBoolean('X_Extended_Warranty')) then
   self.SetFieldValueAsString('X_heureka_extended_warranty','36');
  if (AFieldCode=self.GetFieldCode('X_nedostupne')) and (self.GetFieldValueAsBoolean('X_nedostupne'))  and not(avalue.AsBoolean=AOriginalValue.AsBoolean) then
   self.SetFieldValueAsBoolean('X_PPC_reklama',false);
  if (AFieldCode=self.GetFieldCode('X_nedostupne')) and not(self.GetFieldValueAsBoolean('X_nedostupne')) and not(avalue.AsBoolean=AOriginalValue.AsBoolean) then
   self.SetFieldValueAsBoolean('X_PPC_reklama',true);
  if (AFieldCode=self.GetFieldCode('X_NES_FreeTransport')) and (self.GetFieldValueAsBoolean('X_NES_FreeTransport')) then
   self.SetFieldValueAsBoolean('X_Free_delivery',true);
  if (AFieldCode=self.GetFieldCode('X_NES_FreeTransport')) and not(self.GetFieldValueAsBoolean('X_NES_FreeTransport')) then
   self.SetFieldValueAsBoolean('X_Free_delivery',False);
end;

begin
end.