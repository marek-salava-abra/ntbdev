{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
begin
  if osNew in self.State then begin
     if Assigned(self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('PaymentOrderDocuments'))) and
       (self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('PaymentOrderDocuments')).count>0) and
      (self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('PaymentOrderDocuments')).BusinessObject[0].GetFieldValueAsString('PDocumentType')='04') then begin
       self.SetFieldValueAsString('Description', NxLeft(
       'SimonFM '+self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('PaymentOrderDocuments')).BusinessObject[0].GetFieldValueAsString('PDocument_ID.DisplayName')
       +' '+self.GetFieldValueAsString('Firm_id.Name'),50)
       );
       end;
  end;
end;

begin
end.