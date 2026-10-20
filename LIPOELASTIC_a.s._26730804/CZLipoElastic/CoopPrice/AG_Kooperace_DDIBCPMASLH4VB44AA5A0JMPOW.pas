procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction:= Self.GetNewAction;
  mAction.Name:= 'actPrice';
  mAction.Caption:= '## Doplní cenu ##';
  mAction.Category:= 'tabList';
  mAction.OnExecute:= @InsertPrice;
end;

Procedure InsertPrice(sender:TComponent);
var
 mSite:TSiteForm;
 mList:TStringList;
 i:Integer;
 mPrice:Extended;
 mBO:TNxCustomBusinessObject;
 mOS:TNxCustomObjectSpace;
begin
 mSite:=TComponent(sender).DynSite;
 mOS:=TDynSiteForm(mSite).BaseObjectSpace;
 mList:=TStringList.Create;
 TDynSiteForm(mSite).List.GetSelectedId(mList);
 if mList.count>0 then begin
   mPrice:=NxIBStrToFloat(InputBox('Cena','kolik?','5',mSite));
   for i:=0 to mList.count-1 do begin
     mBO:=mOS.CreateObject(Class_PLMCooperation);
     mBO.Load(mlist.strings[i],nil);
     mBO.SetFieldValueAsFloat('RealWorkPrice',mPrice);
     mBO.SetFieldValueAsBoolean('CompletePrices',True);
     mBO.Save;
     mBO.Free;
   end;
 end;
end;

begin
end.