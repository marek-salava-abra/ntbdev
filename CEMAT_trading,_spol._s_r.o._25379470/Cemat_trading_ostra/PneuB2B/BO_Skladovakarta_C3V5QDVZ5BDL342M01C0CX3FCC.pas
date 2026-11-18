procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);

begin
  if (Self.GetFieldValueAsString('U_pneu_B2B') <> '0') and (Self.GetFieldValueAsString('Producer_ID') = '0000000000') then begin
  ShowMessage('Pro úspěšný import na portál PneuB2B musí být vyplněn výrobce.'); exit; end;
end;

begin
end.