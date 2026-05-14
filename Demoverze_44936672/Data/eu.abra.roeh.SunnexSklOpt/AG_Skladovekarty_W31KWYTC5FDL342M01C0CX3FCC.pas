uses  'eu.abra.roeh.SunnexSklOpt.FuncSPM';
procedure PrepocetInvKompletace(Self: TBasicAction);
var
  mLogInfoStr : string;
  mSuccess : Boolean;
begin
 //CreateInventoroExport (TSiteForm(Self.Owner).BaseObjectSpace,mSuccess,mLogInfoStr);
// IntDateExportImportInv(TSiteForm(Self.Owner).BaseObjectSpace,Now,1);
//CreateInventoroExport (TSiteForm(Self.Owner).BaseObjectSpace,mSuccess,mLogInfoStr);
  MarginStoreCard(TSiteForm(Self.Owner).BaseObjectSpace);
  CreateMaterialsFromNorms(TSiteForm(Self.Owner).BaseObjectSpace);
end;

procedure InitSite_Hook(Self: TSiteForm);
var
  mAct: TBasicAction;
begin
  mAct:= Self.GetNewAction;
  mAct.Name:= 'actPrepocetInvKompletace';
  mAct.Caption:= 'Přepočet kompl.';
  mAct.Category:= 'tabList';
  mAct.OnExecute:= @PrepocetInvKompletace;  {}
end;

begin
end.