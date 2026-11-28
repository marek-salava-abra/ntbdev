uses 'eu.abra.boma.inv_mailing.common';

procedure execBomaInvReports(Sender: TBasicAction);
var
  Success: Boolean;
  LogInfoString: String;
begin
  ProcessReports(Sender.Site.BaseObjectSpace, Success, LogInfoString);
  NxShowMessage('Výsledek', LogInfoString, mdInformation, False, Sender.Site.FindParentForm);
end;

{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}

procedure InitSite_Hook(Self: TSiteForm);
begin
  With Self.GetNewAction do
  begin
    Name := 'actBomaInvReports';
    Caption := 'Test pohledávek';
    Category := 'tabList';
    ShowControl := False;
    onExecute := @execBomaInvReports;
  end;
end;

begin
end.