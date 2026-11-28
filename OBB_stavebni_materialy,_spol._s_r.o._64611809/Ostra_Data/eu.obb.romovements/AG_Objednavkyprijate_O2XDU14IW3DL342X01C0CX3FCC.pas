procedure InitSite_Hook(Self: TSiteForm);
var
  mBut, mBut2: TBasicAction;

begin
  if not Assigned(Self.BaseObjectSpace) then
    exit;

mBut:= Self.GetNewAction;
mBut.ShowControl := True;
mBut.ShowMenuItem := True;
mBut.Caption := 'Pokrytí objednávky';
mBut.Category := 'tabList';
mBut.OnExecute := @ROMovements;

end;

procedure ROmovements(sender:TComponent);
var
  mSite:TSiteForm;

begin
  mSite:=TComponent(Sender).DynSite;
  mSite.ShowSite('T2FWDKF0NSSOBC2KLELLUBPBXW', False, 'QueryByUserDynSQLCondition;A.Parent_ID = '+QuotedStr(TDynSiteForm(msite).CurrentObject.OID));
end;

begin
end.