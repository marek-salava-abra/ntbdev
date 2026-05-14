uses 'eu.dotykacka.fce';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actDotykacka';
  mAction.Caption := 'Dotykacka';
  mAction.Hint := 'Pošli do Dotykačky';
  mAction.Category := 'tabList';
  mAction.OnExecute := @SendDotyk;
end;

Procedure SendDotyk(sender:TComponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mList:TStringList;
 mBO:TNxCustomBusinessObject;
 i:integer;
begin
  mSite:=TComponent(sender).BusRollSite;
  mOS:=mSite.BaseObjectSpace;
  mList:=tstringlist.create;
  TBusRollSiteForm(mSite).list.GetSelectedId(mlist);
  if mList.Count>0 then begin
   WaitWin.StartProgress('Čekejte, prosím ...', '', mList.Count);
    for i:=0 to mlist.count-1 do begin
       mBO:=mOS.CreateObject(Class_Firm);
       mBO.Load(mlist.strings[i],nil);
       CreateOrUpdateFirm(mBO);
       mBO.Free;
       WaitWin.ChangeText(IntToStr(i) + ' / ' + IntToStr(mList.Count));
       WaitWin.StepIt;
    end;
   WaitWin.Stop;
   NxShowSimpleMessage('Nahráno nebo aktualizováno '+IntToStr(mlist.count)+' firem.',mSite);
  end;
end;

begin
end.