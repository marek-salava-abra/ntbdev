procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actCreateLog';
  mAction.Caption := '##Vytvoří log##';
  mAction.Hint := 'pokusný skript';
  mAction.Category := 'tabList';
  mAction.OnExecute := @CreateLog;
end;

Procedure CreateLog(Sender:TComponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mLog:TNxCustomBusinessObject;
begin
 mSite:=TComponent(Sender).DynSite;
 mOS:=TDynSiteForm(mSite).BaseObjectSpace;
 mLog:=mOS.CreateObject(Class_PRFLog);
 mLog.new;
 mlog.prefill;
 mLog.SetFieldValueAsString('DocQueue_ID','~000000B02');
 mlog.save;
end;

begin
end.