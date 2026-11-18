{
Umožňuje ovlivnit validaci.
}
{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
begin
  if NxIsBlank(self.GetFieldValueAsString('ExternalNumber')) then begin
    if not(NxIsBlank(self.GetFieldValueAsString('X_B2BNumber'))) then
       self.SetFieldValueAsString('ExternalNumber',self.GetFieldValueAsString('X_B2BNumber'))
    else begin
      if self.GetFieldValueAsString('DocQueue_ID.Code')='OP' then
       self.SetFieldValueAsString('ExternalNumber',self.GetFieldValueAsString('Period_ID.Code')+AnsiRightStr('0000'+IntToStr(self.GetFieldValueAsInteger('OrdNumber')),5)+'1');
      if self.GetFieldValueAsString('DocQueue_ID.Code')='OPB' then
       self.SetFieldValueAsString('ExternalNumber',self.GetFieldValueAsString('Period_ID.Code')+AnsiRightStr('0000'+IntToStr(self.GetFieldValueAsInteger('OrdNumber')),5)+'2');
    end;
  end;
end;


begin
end.