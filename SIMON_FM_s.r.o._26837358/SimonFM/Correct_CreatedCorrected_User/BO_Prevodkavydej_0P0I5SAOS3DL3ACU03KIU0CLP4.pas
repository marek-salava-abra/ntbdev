uses
  'Correct_CreatedCorrected_User.U_Func';

procedure _BeforeSaveBlock_PostHook(Self: TNxCustomBusinessObject);
begin
  SetUser(Self, True);
end;

begin
end.