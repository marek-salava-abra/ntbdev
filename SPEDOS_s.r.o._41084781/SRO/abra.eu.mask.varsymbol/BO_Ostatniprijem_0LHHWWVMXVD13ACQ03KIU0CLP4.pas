{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
begin
  self.SetFieldValueAsString('varsymbol',(inttostr(self.GetFieldValueAsInteger('DocQueue_ID.PrefixVar')) +
  NxPadL(inttostr(self.GetFieldValueAsInteger('Period_id.SequenceNumber')),2,'0') +
  NxPadL(IntToStr(self.GetFieldValueAsInteger('ordnumber')),5,'0'))) ;
end;

begin
end.