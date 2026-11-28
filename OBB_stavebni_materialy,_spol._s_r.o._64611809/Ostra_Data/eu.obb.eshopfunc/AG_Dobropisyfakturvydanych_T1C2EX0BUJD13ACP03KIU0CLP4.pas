uses 'eu.obb.eshopfunc.fce';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Převodka k DV97';
  mAction.Hint := 'Vytvoří převodku k dobropisu';
  mAction.Category := 'tabList';
  mAction.OnExecute := @CreateTransfer;
end;

Procedure CreateTransfer(sender:TComponent);
var
 mSite:TSiteForm;
 mBO:TNxCustomBusinessObject;
 mList:TStringList;
 mContext:TNxContext;
 mOS:TNxCustomObjectSpace;
begin
  mSite:=TComponent(sender).DynSite;
  mBO:=TDynSiteForm(mSite).CurrentObject;
  if Assigned(mBO) then begin
    if not(mbo.GetFieldValueAsString('DocQueue_ID.Code')='DV97') then begin
      NxShowSimpleMessage('Funkce je k dispozici pouze pro DV97.', mSite);
      exit;
    end;
    mlist:=TStringList.Create;
    mbo.ObjectSpace.SQLSelect(format('Select id from storedocuments where x_documentID=''%s'' ',[mbo.OID]),mList);
    if mlist.count>0 then begin
      NxShowSimpleMessage('Dobropis '+mbo.DisplayName+' již k sobě má převodku výdej. Ukončuji.', mSite);
      exit;
    end;
    if mList.count=0 then begin
       if NxMessageBox('Dotaz',' Přejete si vygenerovat převodku k '+mBO.DisplayName+'?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then
                CreateTransferFromICN(mBO);
    end;
  end;
end;

begin
end.