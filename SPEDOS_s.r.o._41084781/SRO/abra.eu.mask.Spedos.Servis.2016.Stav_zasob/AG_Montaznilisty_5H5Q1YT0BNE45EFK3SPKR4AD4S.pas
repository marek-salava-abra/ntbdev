uses 'abra.eu.mask.Spedos.Servis.2016.Stav_zasob.const',
       'abra.eu.mask.Spedos.Servis.2016.Stav_zasob.funkce';
var
    mFSazba_hod_den,mFDoprava_km,mF_doprava_pausal,mFSazba_hod:double;
    mBO_BusProject:TNxCustomBusinessObject;
    mF_pausal_prace,mF_pausal_Vyjezd,mF_prace,mF_km:double;
    // doby + termíny
    mF_doba:double;
    mRows : TNxCustomBusinessMonikerCollection;
    result:boolean;
    mresult:boolean;

procedure LogistikExecuteItem(Sender: TAction; Index: integer);
var
 mSite : TSiteForm;
  mBO_source : TNxCustomBusinessObject;
  mID,mID_SO:string;
  mr:Tstringlist;
  i, mPosIndex: integer;
  mList: TStringList;
  mText: string;
  result:string;
  mParams : TNxParameters;
begin

end;



procedure StoreExecuteItem(Sender: TAction; Index: integer);
var
 mSite: TDynSiteForm;
begin
    mSite := TComponent(Sender).DynSite;
    if index=0 then begin
       Doplneni_zasob(TDynSiteForm(mSite).CurrentObject.ObjectSpace,true, '');
    end;

    if index=1 then begin
       Doplneni_zasob(TDynSiteForm(mSite).CurrentObject.ObjectSpace,true, '');
    end;
    if index=2 then begin
       Doplneni_zasob(TDynSiteForm(mSite).CurrentObject.ObjectSpace,true, '');
    end;
   TDynSiteForm(mSite).RefreshData;
end;



 procedure InitSite_Hook(Self: TSiteForm);
var
mAction: TAction;
  mMAction: TMultiAction;
  mUserFilter: Boolean;
  mUser: TNxCustomBusinessObject;
begin
  mUserFilter:=false;
  mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');            // přihlášený uživatel
  try
      mUser.Load(Self.CompanyCache.GetUserID, nil);
            if mUser.GetFieldValueAsString('Name')='Supervisor' then mUserFilter:= true;
  finally
    mUser.Free;
  end;
  {mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Stavy na skladech';
  mMAction.Hint := 'Aktualizuje stav na skladě';
  mMAction.Category := 'tabList';
  mMAction.OnExecuteItem := @StoreExecuteItem;
  mMAction.Items.Add('Bez ohledu na ostatní ML');
  mMAction.Items.Add('S ohledem na ostatní ML');
 }

end;


procedure FormCreate_Hook(Self: TSiteForm);
var
  mC: TControl;
begin
  mC := Self.MainPanel.FindChildControl('rgdisplaymodeofrows');
  if Assigned(mC) then begin
    TRadioGroup(mC).Visible:= false;
  end;
end;

begin
end.