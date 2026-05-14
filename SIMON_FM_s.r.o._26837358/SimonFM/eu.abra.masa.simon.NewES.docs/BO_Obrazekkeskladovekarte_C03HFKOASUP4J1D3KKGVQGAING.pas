

{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mBO:TNxCustomBusinessObject;
begin
 mBO:=self.ObjectSpace.CreateObject(Class_Picture);
 mBO.Load(self.GetFieldValueAsString('Picture_ID'));
 if not(NxIsBlank(self.GetFieldValueAsString('Parent_ID.X_AES_name_card'))) then
  mbo.SetFieldValueAsString('PictureTitle',self.GetFieldValueAsString('Parent_ID.X_AES_name_card')+' - '+IntToStr(self.GetFieldValueAsInteger('PosIndex')));
 mbo.save;
end;

procedure Prefill_Hook(Self: TNxCustomBusinessObject);
begin
  self.SetFieldValueAsBoolean('Picture_ID.ExternalFile',True);
end;

begin
end.