uses '.fce';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImportPic';
  mAction.Caption := 'Import PICS';
  mAction.Hint := 'Naimportuje obrázek z Gen CZ dle ID';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportPic;
end;

Procedure ImportPic(sender:TComponent);
var
  mSite:TSiteForm;
  mID:string;
begin
  mSite:=TComponent(sender).BusRollSite;
  mID:=InputBox('zadejte id','ID','',msite);
  NxShowsimplemessage(ImportImage(msite.BaseObjectSpace,mid),mSite);;
end;

begin
end.