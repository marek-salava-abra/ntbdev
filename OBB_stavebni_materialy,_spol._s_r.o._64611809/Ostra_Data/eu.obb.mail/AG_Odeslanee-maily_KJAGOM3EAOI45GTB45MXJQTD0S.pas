procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TAction;
  i : integer;
begin

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Vložit výchozí text';
  mAction.ShortCut := TextToShortCut('Ctrl+W'); //16450;
  mAction.Hint := 'Vložit výchozí text';
  mAction.Category := 'tabDetail';
  mAction.OnExecute := @SetPodpis;
    //mAction.OnUpdate := @ImportOnUpdate;

end;

Procedure SetPodpis(Sender:Tcomponent);
var
 mSite: TSiteForm;

begin
  mSite:=TComponent(Sender).DynSite;
  TDynSiteForm(mSite).CurrentObject.SetFieldValueAsString('Body',TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('EmailAccount_ID.DefaultText'));
  TDynSiteForm(msite).ActiveDataSet.RefreshCurrentItem;
end;


{procedure _AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
begin
  if osNew in self.State then begin
     if (AFieldCode=self.GetFieldCode('Subject')) and not(AValue.AsString=AOriginalValue.AsString) then begin
         //NxShowSimpleMessage('Jsem tu ' +self.GetFieldValueAsString('Body')+ '    délka '+inttostr(Length(self.GetFieldValueAsString('Body'))),nil);
         self.SetFieldValueAsString('Body',Self.GetFieldValueAsString('EmailAccount_ID.DefaultText'));

     end;
  end;
end; }

begin
end.