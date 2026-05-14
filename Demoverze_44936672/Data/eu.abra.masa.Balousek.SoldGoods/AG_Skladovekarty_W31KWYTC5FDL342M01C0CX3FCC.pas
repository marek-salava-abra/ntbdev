uses '.fce';

procedure InitSite_Hook(Self: TSiteForm);
var
    mAction: TAction;
begin
    mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := '## SoldGoods ##';
    mAction.Hint := 'Vrátí množství z procedury SoldGoods';
    mAction.Category := 'tabList';
    mAction.OnExecute := @CalcQuantity;
end;

Procedure CalcQuantity(Sender:TComponent);
var
 mSite:TSiteForm;
 mBO:TNxCustomBusinessObject;
 mQuantity:Extended;
begin
 mSite:=TComponent(Sender).BusRollSite;
 mBO:=TBusRollSiteForm(mSite).CurrentObject;
 if Assigned(mBO) then begin
    mQuantity:=GetQuantityFromSG(msite.BaseObjectSpace, mBO.OID);
    NxShowSimpleMessage(FloatToStr(mQuantity),mSite);
 end;
end;


begin
end.