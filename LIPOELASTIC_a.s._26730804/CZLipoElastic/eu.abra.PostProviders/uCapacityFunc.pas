uses
  'eu.abra.PostProviders.uConst';

//prevede objem z jedne jednotky na m3
function GetCapacityInM3(const ACapacity: Extended; const ACapacityUnit:Integer): Extended;
begin
  Result:= ACapacity / cCapacityUnitFromm3[ACapacityUnit];
end;

begin
end.