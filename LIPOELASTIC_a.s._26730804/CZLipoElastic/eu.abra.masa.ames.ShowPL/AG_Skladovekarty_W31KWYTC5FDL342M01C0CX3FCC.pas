procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actShowPL';
  mAction.Caption := 'Ukaž kusovník';
  mAction.Hint := 'Test';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ShowPL;

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actShowTP';
  mAction.Caption := 'Ukaž TP';
  mAction.Hint := 'Test';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ShowTP;
end;

Procedure ShowPL(Sender:tcomponent);
var
 mSite:TSiteForm;
 mBO:TNxCustomBusinessObject;
begin
 mSite:=TComponent(Sender).BusRollSite;
 mBO:=TBusRollSiteForm(mSite).CurrentObject;
 if Assigned(mBO) then begin
    mSite.ShowSite('NWWNX02WFV2ORFJOXIW4BHBLWG', True, 'QueryByUserDynSQLCondition;A.StoreCard_ID = '+Quotedstr(mbo.OID));
 end;
end;

Procedure ShowTP(Sender:tcomponent);
var
 mSite:TSiteForm;
 mBO:TNxCustomBusinessObject;
begin
 mSite:=TComponent(Sender).BusRollSite;
 mBO:=TBusRollSiteForm(mSite).CurrentObject;
 if Assigned(mBO) then begin
    mSite.ShowSite('EY1VHUCFUEW455OMM2KXYUWR4K', True, 'QueryByUserDynSQLCondition;A.StoreCard_ID = '+Quotedstr(mbo.OID));
 end;
end;

begin
end.