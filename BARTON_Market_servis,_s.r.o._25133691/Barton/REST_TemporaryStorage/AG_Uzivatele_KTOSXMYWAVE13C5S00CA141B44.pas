uses
  'StandardUnits.U_GetId',
  'REST_SkladTerm.U_Translation';

procedure main_DoExecute(Sender: TComponent);
var
  mSiteForm: TBusRollSiteForm;
  mCount: Integer;
begin
  mSiteForm := Sender.BusRollSite;

  if not Assigned(mSiteForm.CurrentObject) then
    exit;

  mCount := SQLSelectInt(mSiteForm.BaseObjectSpace,
    'select count(*) ' +
    'from REST_TemporaryStorage ' +
    'where User_ID = ' + QuotedStr(mSiteForm.CurrentObject.OID ) +
    '  and Status = 0 '
  );

  if mCount = 0 then
    NxMessageBox(getString('reader_unblock'),
      Format(getString('reader_no_work_in_progress'), [mSiteForm.CurrentObject.GetFieldValueAsString('Name')]),
      mdInformation, mdbOk, 0, 0, False, mSiteForm.GetSiteAppForm)
  else begin
    if NxMessageBox(getString('reader_unblock'),
      Format(getString('reader_unblock_message'),
        [mSiteForm.CurrentObject.GetFieldValueAsString('Name'), mCount]),
      mdConfirm, mdbYesNo, 0, 0, False, mSiteForm.GetSiteAppForm) = mrYes then
    begin
      mSiteForm.BaseObjectSpace.SQLExecute(
        'update REST_TemporaryStorage ' +
        'set Status = 2 ' +
        'where User_ID = ' + QuotedStr(mSiteForm.CurrentObject.OID ) +
        '  and Status = 0 '
      );
    end;
  end;

end;

{
Vyvolává se po vytvoření instance formuláře.
}
procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl  := True;
  mAction.ShowMenuItem := True;
  mAction.Category     := 'tabList,tabDetail';
  mAction.Caption      := getString('reader_unblock');
  mAction.Name         := '_' + CFxGuid.CreateNew;
  mAction.onExecute    := @main_DoExecute;
end;

begin
end.