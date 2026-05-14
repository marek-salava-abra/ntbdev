uses 'eu.abra.alec.FloresUserGen.fce';
{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
  var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.Name := 'FloresUserGen';
  mAction.Category := 'tabList,tabDetail';
  mAction.Caption := 'Gen. kód uživ.';
  mAction.ShowMenuItem := True;
  mAction.ShowControl := True;
  mAction.OnExecute := @generateUserCode;
end;

procedure generateUserCode(Sender: TObject);
var
  mSite: TSiteForm;
  mIDs: TStringList;
  i: integer;
  mBO: TNxCustomBusinessObject;
begin
  if Sender is TSiteForm then
    mSite := TSiteForm(Sender)
  else
    mSite := NxFindSiteForm(TComponent(Sender));
  if Assigned(mSite) and (mSite is TRollSiteForm) then
    begin
      mIDs:= TStringList.Create;
      mBO:= TBusRollSiteForm(mSite).CurrentObject;
      Try
        TRollSiteForm(mSite).FillListWithSelectedRows(mIDs);
        for i:= 0 to mIDs.Count -1 do begin
          mBO.Load(mIDs.Strings[i], nil);
          if mBO.GetFieldValueAsString('X_Password') = '' then mBO.SetFieldValueAsString('X_Password', GenerateNum(8)); //GenerateNum - lze nastavit délku kódu
          mBO.Save;
        end;
      finally
        mIDs.Free;
        mBO.Free;
        TBusRollSiteForm(mSite).RefreshData;
      end;
    end;
end;

begin
end.