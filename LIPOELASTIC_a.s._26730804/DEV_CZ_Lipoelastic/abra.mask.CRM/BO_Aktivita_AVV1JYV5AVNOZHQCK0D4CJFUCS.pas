
{
Vyvolává se při předvyplňování hodnot daného objektu.
}
procedure Prefill_Hook(Self: TNxCustomBusinessObject);
begin
self.SetFieldValueAsDateTime('NextContact$DATE',self.getFieldValueAsDateTime('SheduledStart$Date'))   ;
self.SetFieldValueAsDateTime('TradeDate$DATE',self.getFieldValueAsDateTime('SheduledStart$Date'))   ;
end;


begin
end.