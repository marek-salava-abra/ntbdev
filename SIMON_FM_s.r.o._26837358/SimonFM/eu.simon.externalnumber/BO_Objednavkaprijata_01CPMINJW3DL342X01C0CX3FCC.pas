
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
begin
  if osNew in self.State then begin
   if self.GetFieldValueAsString('DocQueue_ID.Code')='OPES' then begin
     if NxIsBlank(self.GetFieldValueAsString('ExternalNumber')) then
       self.SetFieldValueAsString('ExternalNumber',AnsiRightStr(self.GetFieldValueAsString('Period_ID.Code'),4)+AnsiRightStr('000000'+IntToStr(self.GetFieldValueAsInteger('Ordnumber')),6));
     end;
  end;
end;


begin
end.