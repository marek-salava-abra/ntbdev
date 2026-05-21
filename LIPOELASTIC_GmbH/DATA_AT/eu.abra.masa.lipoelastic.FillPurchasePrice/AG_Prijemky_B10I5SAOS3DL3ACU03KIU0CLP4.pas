procedure InitSite_Hook(Self: TSiteForm);
var
  mAction:TAction;
begin

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actFillPrice';
  mAction.Caption := '##Doplní cenu##';
  mAction.Hint := 'Doplní cenu';
  mAction.Category := 'tabList';
  mAction.OnExecute := @FillPrice;
end;

Procedure FillPrice(Sender:TComponent);
var
 mSite:TSiteForm;
 mList:TStringList;
 i,j:Integer;
 mBO, mRowBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mOS:TNxCustomObjectSpace;
 mSupplierPrice:extended;
begin
 mSite:=TComponent(Sender).DynSite;
 mOS:=TDynSiteForm(mSite).BaseObjectSpace;
 mList:=TStringList.Create;
 TDynSiteForm(mSite).List.GetSelectedId(mList);
 if mList.count>0 then begin
   WaitWin.StartProgress('Please, wait ...', '', mList.Count);
    for i:=0 to mlist.count-1 do begin
      mBO:=mOS.CreateObject(Class_ReceiptCard);
      mBO.load(mlist.Strings[i],nil);
      mRows:=mbo.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
      for j:=0 to mRows.Count-1 do begin
        mRowBO:=mRows.BusinessObject[j];
        mSupplierPrice:=mOS.SQLSelectFirstAsExtended('select purchaseprice from SupplierPriceLists2 where parent_id=''~000000307'' and  StoreCard_ID='+QuotedStr(mRowBO.GetFieldValueAsString('StoreCard_ID')),0);
        if mSupplierPrice>0 then mRowBO.SetFieldValueAsFloat('UnitPrice', mSupplierPrice);
      end;
      mBO.save;
      mBO.free;
      WaitWin.ChangeText(IntToStr(1+i) + ' / ' + IntToStr(mList.Count));
      WaitWin.StepIt;
    end;
    WaitWin.Stop;
 end;
end;

begin
end.