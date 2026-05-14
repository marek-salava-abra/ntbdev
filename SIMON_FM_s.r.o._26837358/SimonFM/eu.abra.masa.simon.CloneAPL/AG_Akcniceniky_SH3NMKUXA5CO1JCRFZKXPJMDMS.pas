procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actMailZLV';
  mAction.Caption := 'CLONE';
  mAction.Hint := 'tlačítko';
  mAction.Category := 'tabList';
  mAction.OnExecute := @CloneAPL;
end;

Procedure CloneAPL(sender:tcomponent);
var
 mBO,mNewBO, mStorePrice, mNewStorePrice:TNxCustomBusinessObject;
 i:integer;
 mSite:TSiteForm;
 mList:TStringList;
 mOS:TNxCustomObjectSpace;
 mAPL_ID:string;
begin
 mSite:=TComponent(sender).BusRollSite;
 mOS:=mSite.BaseObjectSpace;
 mBO:=TBusRollSiteForm(mSite).CurrentObject;
 if Assigned(mBO) then begin
     mNewBO:=mBO.Clone;
     mNewBO.save;
     mAPL_ID:=mNewBO.OID;
     mNewBO.free;
     mList:=TStringList.Create;
     mOS.SQLSelect('Select id from actionstoreprices where pricelist_id='+QuotedStr(mBO.OID),mList);
     for i:=0 to mList.count-1 do begin
       mStorePrice:=mOS.CreateObject(Class_ActionStorePrice);
       mStorePrice.load(mList.Strings[i],nil);
       mNewStorePrice:=mStorePrice.Clone;
       mNewStorePrice.SetFieldValueAsString('PriceList_ID',mAPL_ID);
       mNewStorePrice.save;
       mStorePrice.free;
       mNewStorePrice.free;
     end;
 end;
end;


begin
end.