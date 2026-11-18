procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Změna stavu (PMChangeState)';
  mAction.Category := 'tabList';
  mAction.OnExecute := @PMChangeState;

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Změna stavu (PMChangeStateByTransition)';
  mAction.Category := 'tabList';
  mAction. OnExecute := @PMChangeStateByTransition;
end;

procedure Done(const ASite: TDynSiteForm);
begin
  ASite.ActiveDataSet.CurrentItem.Selected := True;
  ASite.ActiveDataSet.CurrentItem.Refresh;
  ASite.ActiveDataSet.UpdateFields;
  NxShowSimpleMessage('Změna stavu dokončena', ASite.GetSiteAppForm);
end;

procedure PMChangeState(Sender : TObject);
var
  mSite: TDynSiteForm;
  mBO : TNxCustomBusinessObject;
begin
  mSite := TDynSiteForm(TComponent(Sender).Site);
  mBO := mSite.CurrentObject;
  mBO.PMChangeState('SDDEF00000'); // změnit dle hodnot PMStates.ID v konkrétní instalaci
  Done(mSite);
end;

procedure PMChangeStateByTransition(Sender : TObject);
var
  mSite: TDynSiteForm;
  mBO : TNxCustomBusinessObject;
begin
  mSite := TDynSiteForm(TComponent(Sender).Site);
  mBO := mSite.CurrentObject;
  mBO.PMChangeStateByTransition('2000000101'); // změnit dle hodnot PMStatesTransitions.ID v konkrétní instalaci
  Done(mSite);
end;

begin
end.