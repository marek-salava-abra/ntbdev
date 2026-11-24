{
  The XLSX import is started from the Outgoing Substitutions list. For every
  batch difference, it also creates the linked Incoming Substitution.

  This agenda intentionally has no separate import action. This prevents a
  duplicate import and preserves the relationship between both documents.
}

procedure InitSite_Hook(Self: TSiteForm);
begin
  // Intentionally empty; incoming documents are created by the outgoing action.
end;


begin
end.
