uses
  'Tanaka.DigiToo.Common';

procedure _AfterDwarfSave_Hook(Self: TNxCustomBusinessObject; ADwarfCode: Integer);
begin
  ChangePaymentStatus(Self, ADwarfCode);
end;

begin
end.