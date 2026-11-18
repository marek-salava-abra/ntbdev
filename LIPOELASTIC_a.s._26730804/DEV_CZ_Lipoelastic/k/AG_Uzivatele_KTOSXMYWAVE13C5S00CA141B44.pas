procedure InitSite_Hook(Self: TSiteForm);
var
  mAct, mAct2: TBasicAction;
  i:Integer;
begin
  mAct := Self.GetNewAction;
  mAct.Caption := '##Sestavy##';
  mAct.Category := 'tabList';
  mAct.OnExecute := @Sestavy;

  mAct2:= Self.GetNewAction;
  mAct2.Caption := '##Formuláře##';
  mAct2.Category := 'tabList';
  mAct2.OnExecute := @Forms;

end;

Procedure Sestavy(Sender:tcomponent);
var
 mOle, mRoll, mSelected:Variant;
 mList:TStringList;
 i:integer;
 mBO:TNxCustomBusinessObject;
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
begin
 mSite:=TComponent(Sender).BusRollSite;
 mOS:=msite.BaseObjectSpace;
 mOle:=GetAbraOLEApplication;
 mSelected:=GetAbraOLEStrings;
 mRoll:=mOle.GetRoll('4CQONRMN0ND13BYP02K2DBYMG4',0);
 mRoll.Params.Add('_PROGPOINT=');
 if mRoll.multiselectdialog(True, mSelected) then begin
   for i:=0 to mSelected.count-1 do begin
    mBO:=mOS.CreateObject(Class_Report);
    mBO.Load(mSelected.strings[i],nil);
    mbo.SetFieldValueAsString('Title','#'+mbo.GetFieldValueAsString('Title'));
    mbo.save;
    mbo.free;
   end;
 end;
end;

Procedure Forms(Sender:tcomponent);
var
 mOle, mRoll, mSelected:Variant;
 mList:TStringList;
 i:integer;
 mBO:TNxCustomBusinessObject;
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
begin
 mSite:=TComponent(Sender).BusRollSite;
 mOS:=msite.BaseObjectSpace;
 mOle:=GetAbraOLEApplication;
 mSelected:=GetAbraOLEStrings;
 mRoll:=mOle.GetRoll('002GGOMG2JDO505F2PFP55TBCO',0);
 mRoll.Params.Add('_PROGPOINT=');

 if mRoll.multiselectdialog(True, mSelected) then begin
 {
   for i:=0 to mSelected.count-1 do begin
    mBO:=mOS.CreateObject(Class_Report);
    mBO.Load(mSelected.strings[i],nil);
    mbo.SetFieldValueAsString('Title','#'+mbo.GetFieldValueAsString('Title'));
    mbo.save;
    mbo.free;
   end;
 }
 end;

end;

begin
end.