uses 'eu.abra.masa.lipo.TBL.dlg', 'eu.abra.masa.lipo.TBL.lib';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actShowChanges';
  mAction.Caption := 'Zobrazit změny';
  mAction.Hint := 'Zobrazí změny stavů na přepravce';
  mAction.Category := 'tabList';
  mAction.OnExecute := @Showchanges;

  mAction:= Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actGenerateTransportBoxes';
  mAction.Caption := 'Generovat přepravky';
  mAction.Hint := 'Vygeneruje přepravky ve vybraném typu';
  mAction.Category := 'tabList';
  mAction.OnExecute := @GenerateTransportBoxes;
end;

Procedure ShowChanges(sender:tcomponent);
var
 mSite:TSiteForm;
 mBO:TNxCustomBusinessObject;
 mOS:TNxCustomObjectSpace;
 msql:string;
 mParams:TNxParameters;
 mList:TStringList;
begin
 mSite:=TComponent(sender).BusRollSite;
 mOS:=msite.BaseObjectSpace;
 mBO:=TBusRollSiteForm(mSite).CurrentObject;
 if Assigned(mBO) then begin
   mParams:=TNxParameters.Create;
   mList:=TStringList.Create;
   msql:='Select id from defrolldata where clsid=''EWCAAHGDFUM45DTBKYBXWOA304'' and X_TransportBox_id=''%s'' ';
   mOS.SQLSelect(Format(mSql,[mbo.OID]),mList);
   mParams.GetOrCreateParam(dtString, '_Allowed', pkInput).AsString := mlist.DelimitedText;
   NxShowRoll(NxCreateContext_1(mBO),'AIAQPCDHQFOO5BPYJJ5FCQ0S44',mParams,1,'',mSite);
 end;
end;

procedure GenerateTransportBoxes(Sender: TComponent);
var
  mSite:TSiteForm;
  mBO:TNxCustomBusinessObject;
  mOS:TNxCustomObjectSpace;
  mFormResult: boolean;
  mType_ID, mPrefix, mCode, mLB_ID: string;
  i, mQuantity: integer;
begin
  mSite:=TComponent(sender).BusRollSite;
  mOS:=msite.BaseObjectSpace;
  mLB_ID:= '';
  mPrefix:= 'LB';
  mFormResult:= GetGeneratorForm(mSite, mType_ID, mQuantity);
  if (mFormResult = true) and (mQuantity > 0) then begin
    for i:=0 to mQuantity -1 do begin
      mBO:= mOS.CreateObject(Class_TransportBoxesLipoBO);
      try
        mBO.New;
        mBO.Prefill;
        mCode:= GetLatestCode(mOS, 'DefRollData', Class_TransportBoxesLipoBO, mPrefix, 4);
        mBO.SetFieldValueAsString('Code', mCode);
        mBO.SetFieldValueAsString('Name', mCode);
        mBO.SetFieldValueAsString('X_TransportBoxType_ID', mType_ID);
        mBO.SetFieldValueAsString('X_State_ID', '~000000IP7');
        mBO.Save;
      finally
        mLB_ID:= mBO.OID;
        mBO.Free;
      end;
    end;
    NxShowSimpleMessage('Přepravky vygenerovány',mSite);
  end;
  TBusRollSiteForm(mSite).RefreshData;
  TBusRollSiteForm(mSite).DataSet.SeekID(mLB_ID);
end;

procedure _AfterEditRec_Hook(Self: TRollSiteForm);
begin
  DisableControlWithNameOnSite(Self.GetSiteAppForm, ['edCode', 'edName']);
  if not(osNew in TBusRollSiteForm(Self).CurrentObject.State) then begin
    DisableControlWithNameOnSite(Self.GetSiteAppForm, ['edX_TransportBoxType_ID']);
  end else begin
    AllowControlWithNameOnSite(Self.GetSiteAppForm, ['edX_TransportBoxType_ID']);
  end;
end;

procedure DisableControlWithNameOnSite(AParent: TWinControl; Const ANames: array of string);
var
  mControl: TControl;
  i: integer;
begin
  for i:= 0 to Length(ANames) - 1 do begin
    mControl := NxFindChildControl(AParent, ANames[i]);
    if Assigned(mControl) then begin
      DisableAllControlsOnControl(mControl);
    end;
  end;
end;

procedure DisableAllControlsOnControl(AComponent: TComponent);
var
  i: Integer;
begin
  for i := AComponent.ComponentCount-1 downto 0 do begin
    DisableAllControlsOnControl(AComponent.Components(i));
  end;
  if AComponent is TControl then begin
    TControl(AComponent).Enabled := false;
    TControl(AComponent).Refresh;
  end;
end;

procedure AllowControlWithNameOnSite(AParent: TWinControl; Const ANames: array of string);
var
  mControl: TControl;
  i: integer;
begin
  for i:= 0 to Length(ANames) -1 do begin;
    mControl := NxFindChildControl(AParent, ANames[i]);
    if Assigned(mControl) then begin
      AllowAllControlsOnControl(mControl);
    end;
  end;
end;

procedure AllowAllControlsOnControl(AComponent: TComponent);
var
  i: Integer;
begin
  for i := AComponent.ComponentCount-1 downto 0 do begin
    AllowAllControlsOnControl(AComponent.Components(i));
  end;
  if AComponent is TControl then begin
    TControl(AComponent).Enabled := true;
    TControl(AComponent).Refresh;
  end;
end;

procedure My_OnChange_pgcDataViews(Sender: TPageControl);
begin
  DisableControlWithNameOnSite(Sender.Site.GetSiteAppForm, ['edCode', 'edName']);
  if not(osNew in TBusRollSiteForm(Sender.Site.GetSiteAppForm).CurrentObject.State) then begin
    DisableControlWithNameOnSite(Sender.Site.GetSiteAppForm, ['edX_TransportBoxType_ID']);
  end;
end;

procedure _Refresh_Hook(Self: TRollSiteForm);
begin
  TBusRollSiteForm(Self).DataSet.RefreshCurrentItem;
end;

{
procedure _AfterEditRec_Hook(Self: TRollSiteForm);
var
  mList: TStringList;
begin
  mList:= TStringList.Create;
    DisableControlWithNameOnSite(Self.GetSiteAppForm, 'edCode');
    DisableControlWithNameOnSite(Self.GetSiteAppForm, 'edName');
  if not(osNew in TBusRollSiteForm(Self).CurrentObject.State) then begin
    DisableControlWithNameOnSite(Self.GetSiteAppForm, 'edX_TransportBoxType_ID');
  end else begin
    AllowControlWithNameOnSite(Self.GetSiteAppForm, 'edX_TransportBoxType_ID');
  end;
end;

procedure DisableControlWithNameOnSite(AParent: TWinControl; AName: String);
var
  mControl: TControl;
begin
  mControl := NxFindChildControl(AParent, AName);
  if Assigned(mControl) then begin
    DisableAllControlsOnControl(mControl);
  end else;
end;

procedure AllowControlWithNameOnSite(AParent: TWinControl; AName: String);
var
  mControl: TControl;
begin
  mControl := NxFindChildControl(AParent, AName);
  if Assigned(mControl) then begin
    AllowAllControlsOnControl(mControl);
  end else;
end;

procedure My_OnChange_pgcDataViews(Sender: TPageControl);
begin
   DisableControlWithNameOnSite(Sender.Site.GetSiteAppForm, 'edCode');
   DisableControlWithNameOnSite(Sender.Site.GetSiteAppForm, 'edName');
   DisableControlWithNameOnSite(Sender.Site.GetSiteAppForm, 'edX_TransportBoxType_ID');
end;
}

begin
end.