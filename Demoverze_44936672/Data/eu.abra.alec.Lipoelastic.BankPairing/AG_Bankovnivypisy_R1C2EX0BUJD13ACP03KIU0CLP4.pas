uses '.lib';

procedure FormCreate_Hook(Self: TSiteForm);
var A: TBasicAction;
begin
  A := Self.GetNewAction;
  A.Caption := '## Bank pairing ##';
  //A.Hint := 'Označ a zpracuj doklady';
  A.ShowControl := True;
  A.Category := 'tabDetail';
  A.OnExecute := @RunSelectDocs;
end;

begin
end.