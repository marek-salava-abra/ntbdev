procedure FormCreate_Hook(Self: TSiteForm);
var
  mAct: TBasicAction;
begin
  mAct := Self.GetNewAction;
  mAct.Caption := 'TEST EID';
  mAct.Category := 'tabList';
  mAct.OnExecute := @TestEID;
end;

Procedure TestEID(sender:TComponent);
var
 mSite:TSiteForm;
 mBO, mExtBO:TNxCustomBusinessObject;
 mString:string;
 mExIDs:TNxCustomBusinessMonikerCollection;
begin
 mSite:=TComponent(sender).BusRollSite;
 mBO:=TBusRollSiteForm(mSite).CurrentObject;
 if Assigned(mBO) then begin
   mString:=InputBox('zadejte údaje','test', 'výchozí hodnota',mSite);
   if not(NxIsBlank(mString)) then begin
     mExIDs:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('ExternalIDs'));
     mExtBO:=mExIDs.AddNewObject;
     mExtBO.Prefill;
     mExtBO.SetFieldValueAsString('ExternalID',mString);
     mbo.save;
   end;
 end;
end;

begin
end.