{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mBO:TNxCustomBusinessObject;
 mList:TStringList;
begin
  //NxShowSimpleMessage(self.GetFieldValueAsString('PDocumentType')+' '+self.GetFieldValueAsString('VarSymbol'),nil);
  if self.GetFieldValueAsString('PDocumentType')='10' then begin
     mList:=TStringList.Create;
     self.ObjectSpace.SQLSelect(format('select id from issueddinvoices where varsymbol=''%s'' ',[self.GetFieldValueAsString('VarSymbol')]),mList);
     if mlist.count>0 then begin
     mBO:=self.ObjectSpace.CreateObject(Class_IssuedDepositInvoice);
     mBO.Load(mList.strings[0],nil);
     //NxShowSimpleMessage(mbo.DisplayName,nil);
     mBo.SetFieldValueAsBoolean('X_Paid',true);
     mbO.save;
     mbo.free;
     end;
     mlist.free;
  end;
end;

begin
end.
