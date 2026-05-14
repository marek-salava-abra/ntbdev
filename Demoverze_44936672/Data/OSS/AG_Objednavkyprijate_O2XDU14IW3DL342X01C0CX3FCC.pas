procedure FormCreate_Hook(Self: TSiteForm);

var
  mAction: TAction;
begin

    mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := 'OSS';
    mAction.Hint := 'OSS';
    mAction.Category := 'tabList';
    mAction.OnExecute := @CreateOSS;
  //end;
end;

Procedure CreateOSS(sender:TComponent);
var
 mSite:TSiteForm;
 mBO, mRowBO:TNxCustomBusinessObject;
 mOS:TNxCustomObjectSpace;
 mRows:TNxCustomBusinessMonikerCollection;
begin
 NxShowSimpleMessage(floattostr(EndOfTheMonth(trunc(Date))),nil);
end;

begin
end.