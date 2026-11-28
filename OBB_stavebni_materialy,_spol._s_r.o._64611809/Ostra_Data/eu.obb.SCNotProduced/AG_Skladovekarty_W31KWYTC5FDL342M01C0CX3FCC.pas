procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actDelOLD';
  mAction.Caption := 'Navrhnout smazání';
  mAction.Hint := 'Navrhni již nevyráběné karty ke smazání';
  mAction.Category := 'tabList';
  mAction.OnExecute := @SetDelOld;
end;

Procedure SetDelOld(sender:TComponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mList:TStringList;
 mBO, mUser:TNxCustomBusinessObject;
 i:integer;
begin
  mSite:=TComponent(sender).BusRollSite;
  mOS:=mSite.BaseObjectSpace;
  mList:=tstringlist.create;
  TBusRollSiteForm(mSite).List.GetSelectedId(mList);
    if mList.Count>0 then begin
    mUser:=mOS.CreateObject(Class_SecurityUser);
    mUser.Load(NxGetActualUserID(mOS),nil);
    WaitWin.StartProgress('Čekejte, prosím ...', '', mList.Count);
      for i:=0 to mlist.count-1 do begin
         mBO:=mOS.CreateObject(Class_StoreCard);
         mBO.Load(mlist.strings[i],nil);
         mBO.SetFieldValueAsBoolean('U_DelOld',True);
         mBO.SetFieldValueAsString('U_DelOldName',mUser.GetFieldValueAsString('LoginName'));
         mbo.save;
         mBO.Free;
         WaitWin.ChangeText(IntToStr(i) + ' / ' + IntToStr(mList.Count));
         WaitWin.StepIt;
      end;
     WaitWin.Stop;
     NxShowSimpleMessage('Označeno '+IntToStr(mlist.count)+' karet.',mSite);
    end;
end;

begin
end.