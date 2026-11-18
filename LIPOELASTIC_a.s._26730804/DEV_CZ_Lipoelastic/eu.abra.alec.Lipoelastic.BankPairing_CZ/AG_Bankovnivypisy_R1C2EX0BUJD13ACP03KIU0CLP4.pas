uses '.lib', '.docMatching';

procedure FormCreate_Hook(Self: TSiteForm);
var A: TBasicAction;
begin
  A := Self.GetNewAction;
  A.Caption := '## Bank pairing ##';
  //A.Hint := 'Označ a zpracuj doklady';
  A.Name:= 'BankPairingHelper';
  A.ShowControl := True;
  A.Category := 'tabDetail';
  A.OnExecute := @RunSelectDocs;
  A.OnUpdate:= @My_OnUpdate;

  A := Self.GetNewAction;
  A.Caption := '## Find matching doc ##';
  A.Name:= 'actFindMatchingDoc';
  A.ShowControl := True;
  A.Category := 'tabDetail';
  A.OnExecute := @FindMatchingDoc;
  A.OnUpdate:= @My_OnUpdate;
end;

procedure My_OnUpdate(Sender: TControl);
var
  mSite: TSiteForm;
begin
  mSite := NxFindSiteForm(Sender);
  if Assigned(mSite) then begin
    if mSite is TDynSiteForm then begin
      TBasicAction(Sender).Enabled := TDynSiteForm(mSite).Edit;
    end;
  end;
end;


begin
end.