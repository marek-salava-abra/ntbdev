{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
   mAktivita:TNxCustomBusinessObject;
begin
if self.GetFieldValueAsString('ActivityType_ID')='D100000101' then begin
    if (self.GetFieldValueAsInteger('status')=2) and (self.GetFieldValueAsDateTime('RealEnd$Date')>10000) then begin
        try
        mAktivita:=self.ObjectSpace.CreateObject('AVV1JYV5AVNOZHQCK0D4CJFUCS');
                                        mAktivita.New;
                                        mAktivita.Prefill;
                                        mAktivita.SetFieldValueAsString('ActivityArea_ID', self.GetFieldValueAsString('ActivityArea_ID'));
                                        mAktivita.SetFieldValueAsString('ActivityType_ID', self.GetFieldValueAsString('ActivityType_ID'));
                                        mAktivita.SetFieldValueAsString('ActQueue_ID', self.GetFieldValueAsString('ActQueue_ID'));

                                        mAktivita.SetFieldValueAsString('ActivityProcess_ID', self.GetFieldValueAsString('ActivityProcess_ID'));
                                        mAktivita.SetFieldValueAsString('SolverRole_ID', self.GetFieldValueAsString('SolverRole_ID'));
                                        mAktivita.SetFieldValueAsString('Description', self.GetFieldValueAsString('Description'));
                                        mAktivita.SetFieldValueAsString('Person_ID', self.GetFieldValueAsString('Person_ID'));
                                        mAktivita.SetFieldValueAsString('X_skoleni', self.GetFieldValueAsString('X_skoleni'));

                                        mAktivita.SetFieldValueAsString('Division_ID',self.GetFieldValueAsString('Division_ID'));
                                        mAktivita.SetFieldValueAsString('Subject', self.GetFieldValueAsString('Subject'));
                                        mAktivita.SetFieldValueAsInteger('Status', 1);
                                        mAktivita.SetFieldValueAsDateTime('SheduledStart$Date',IncMonth(self.getFieldValueAsDateTime('RealStart$Date'),strtoint(self.GetFieldValueAsString('X_skoleni.code'))));
                                        mAktivita.SetFieldValueAsDateTime('SheduledEnd$Date', IncMonth(self.getFieldValueAsDateTime('RealEnd$Date'),strtoint(self.GetFieldValueAsString('X_skoleni.code'))));
                                        mAktivita.SetFieldValueAsDateTime('RealStart$Date', 1);
                                        mAktivita.SetFieldValueAsDateTime('RealEnd$Date', 1);
                                        mAktivita.Save;
        finally
            mAktivita.free;
        end;
end;

end;
end;


{
Umožňuje ovlivnit validaci.
}
{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
begin
    if self.GetFieldValueAsString('ActivityType_ID')='D100000101' then begin
          self.SetFieldValueAsString('Subject',self.GetFieldValueAsString('X_skoleni.Name'));
    end;
end;

procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
  if self.GetFieldValueAsString('ActivityType_ID')='D100000101' then begin
      if (self.GetFieldValueAsInteger('status')=2) and (self.GetFieldValueAsDateTime('RealEnd$Date')<10000)then begin
           self.SetFieldValueAsDateTime('RealEnd$Date',Now());
      end;
  end;
end;

begin
end.