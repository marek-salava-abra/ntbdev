{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
begin
  if self.GetFieldValueAsString('DocQueue_ID')='8B10000101' then begin
      if osNew in self.State  then begin
           if self.GetFieldValueAsString('DocQueue_ID')='7B10000101' then begin
                self.SetFieldValueAsBoolean('WithPrices',false);
                self.SetFieldValueAsstring('Currency_ID','0000CZK000');
            end;

      end;
  end;
  if osNew in self.State  then begin


        //if (self.GetFieldValueAsString('DocQueue_ID')='1540000101')  then begin
           //      self.SetFieldValueAsBoolean('Confirmed',false);

        //    end;
  end;
end;

{
Vyvolává se poté, co se provede na objektu metoda New.
Původní kód: self.SetFieldValueAsBoolean('Confirmed',false)
}
procedure New_Hook(Self: TNxCustomBusinessObject);
begin
end;



{
Vyvolává se při předvyplňování hodnot daného objektu.
}
procedure Prefill_Hook(Self: TNxCustomBusinessObject);
begin
  self.SetFieldValueAsBoolean('WithPrices',false);
end;

begin
end.