procedure InitSite_Hook(Self: TSiteForm);
var
  mAction:TAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actCorrCode';
  mAction.Caption := '##Correct code##';
  mAction.Hint := 'Naimportuje množství z CSV';
  mAction.Category := 'tabList';
  mAction.OnExecute := @CorrectCode;
end;

Procedure CorrectCode(sender:tcomponent);
var
 mOS:TNxCustomObjectSpace;
 mSite:TSiteForm;
 mList:TStringList;
 i:integer;
 mCode:string;
 mBO:TNxCustomBusinessObject;
begin
 mSite:=TComponent(Sender).BusRollSite;
 mOS:=mSite.BaseObjectSpace;
 mList:=TStringList.Create;
 TBusRollSiteForm(mSite).List.GetSelectedId(mList);
 for i:=0 to mList.Count-1 do begin
   mBO:=mOS.CreateObject(class_firm);
   mbo.Load(mlist.Strings[i],nil);
   mCode:= IntToStr(StrToInt(mOS.SQLSelectFirstAsString('Select max(code) from firms where code like '+QuotedStr('11______'),''))+1);
   mBO.SetFieldValueAsString('Code',mCode);
   mBO.save;
   mbo.free;
 end;
end;
begin
end.