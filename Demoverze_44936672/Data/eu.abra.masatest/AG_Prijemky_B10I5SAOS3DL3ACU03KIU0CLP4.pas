procedure FormCreate_Hook(Self: TSiteForm);

var
  mAction: TAction;
begin

    mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := 'CreateDoc';
    mAction.Hint := 'pokus';
    mAction.Category := 'tabList';
    mAction.OnExecute := @CreateDoc;
end;

Procedure CreateDoc(sender:tcomponent);
var
 mBO, mRowBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
begin
 mSite:=TComponent(sender).DynSite;
 mOS:=TDynSiteForm(mSite).BaseObjectSpace;
 mBO:=mOS.CreateObject(Class_ReceiptCard);
 mBO.new;
 mBO.prefill;
 mBO.SetFieldValueAsString('DocQueue_ID','O600000101');
 mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
 mRowBO:=mRows.AddNewObject;
 mrowBO.prefill;
 mRowBO.SetFieldValueAsString('Store_ID','2100000101');
 mRowBO.SetFieldValueAsString('StoreCard_ID','2100000101');
 mRowBO.SetFieldValueAsFloat('Quantity',2);
 mRowBO.SetFieldValueAsString('QUnit','kafe');
 mRowBO.SetFieldValueAsString('Division_ID','2100000101');
 mBO.save;
 mbo.free;
end;



begin
end.