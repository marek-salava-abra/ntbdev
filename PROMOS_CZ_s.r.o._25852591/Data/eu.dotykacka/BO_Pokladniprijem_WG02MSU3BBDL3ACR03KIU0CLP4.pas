{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mRows:TNxCustomBusinessMonikerCollection;
 mDLBO:TNxCustomBusinessObject;
begin
  if osNew in self.state then begin
    if not(NxIsBlank(self.GetFieldValueAsString('X_dotykackaID'))) then begin
       mRows:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows'));
       if not(NxIsEmptyOID(mRows.BusinessObject[0].GetFieldValueAsString('Provide_ID'))) then begin
         mDLBO:=self.ObjectSpace.CreateObject(Class_BillOfDelivery);
         mDLBO.load(mRows.BusinessObject[0].GetFieldValueAsString('Provide_ID'),nil);
         mdlbo.SetFieldValueAsString('CreatedBy_ID',self.GetFieldValueAsString('CreatedBy_ID'));
         mDLBO.SetFieldValueAsString('Description',self.GetFieldValueAsString('X_dotykackaID'));
         mdlbo.save;
         mdlbo.free;
       end;
    end;
  end;
end;

begin
end.