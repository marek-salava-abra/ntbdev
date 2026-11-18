procedure MultiAkceExecuteItem(Sender: TObject; Index: integer);
var
mA:TNxCustomBusinessObject;
mNote,mName:string;
mSite: TSiteForm;
mParams, mTemplates, P: TNxParameters;
mRoot,mParam, mPar: TNxParameter;
muser,mBO: TNxCustomBusinessObject;

begin

if Sender is TComponent then begin
    //OutputDebugString('Sender je TComponent.');
    mSite := NxFindSiteForm(TComponent(Sender));
    if Assigned(mSite) then begin
      //OutputDebugString('Nalezen nadřízený SiteForm.');
      if mSite is TBusRollSiteForm then begin
        // Ziskame aktualni objekt (TNxCustomBusinessObject)
        mA := TBusRollSiteForm(mSite).DataSet.CurrentObject;
 end;
 end;
 end;
 if index=0 then begin
        mParams := TNxParameters.Create;
  try
    begin
    mTemplates := mParams.NewFromDataType(dtList, 'TemplateParams').AsList;
      if Assigned(mA) then

    end;
    mUser := mA.ObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');
    mUser.Load(msite.CompanyCache.GetUserID, nil);
    mTemplates.NewFromDataType(dtString, 'ActQueue_ID').AsString :=mUser.GetFieldValueAsString('U_crmdocqueue_id');
    mTemplates.NewFromDataType(dtString, 'Firm_id').AsString :=ma.oid;
    mTemplates.NewFromDataType(dtString, 'ActivityArea_ID').AsString := '1000000101';
    mTemplates.NewFromDataType(dtString, 'ActivityType_ID').AsString := '1300000101';
    mTemplates.NewFromDataType(dtString, 'SolverRole_ID').AsString:=muser.GetFieldValueAsString('U_solverID');
    mTemplates.NewFromDataType(dtString, 'ResolvedBy_id').asstring:=mUser.OID;
    mSite.ShowDynForm('OYC0P3TDDY1ORIJO2SKTP2KZKG', mParams, Nil, False, 'DoNewOnly');
  finally
    mParams.Free;
  end;
  end;


  if index=1 then begin
        mParams := TNxParameters.Create;

     P := TNxParameters.Create;
    try
      // Omezení...
      mRoot := P.NewFromDataType(dtList, '_DefaultSelection', pkUnknown) ; //DoNotLocalize
      mPar := mRoot.AsList.NewFromDataType(dtList, 'CONDITIONS', pkUnknown) ; //DoNotLocalize
      mPar := mPar.AsList.NewFromDataType(dtList, 'Firm_ID', pkUnknown) ; //DoNotLocalize
      mPar.AsList.NewFromDataType(dtInteger, 'USEDKIND', pkUnknown).AsInteger := 1; //integer( ckSingle ) ; //DoNotLocalize
      mPar := mPar.AsList.NewFromDataType(dtList, 'Values', pkUnknown) ; //DoNotLocalize
      mPar.AsList.NewFromDataType(dtString, '{:VALUE}', pkUnknown).AsString :=  '''' + mA.OID + '''' ;

      mPar := mRoot.AsList.NewFromDataType(dtList, 'ORDERS', pkUnknown); // DoNotLocalize
      mPar := mPar.AsList.NewFromDataType(dtList, 'ActivityNumber', pkInput); // DoNotLocalize
      mPar.AsList.GetOrCreateParam(dtInteger, 'UsedKind', pkInput).AsInteger := 2; //Ord(okAscending); //DoNotLocalize
      mPar.AsList.GetOrCreateParam(dtInteger, 'Order', pkInput).AsInteger := 0; //DoNotLocalize

      P.NewFromDataType(dtString, '_SelectionCaption', pkUnknown).AsString := 'Aktivity pro firmu ' + mA.DisplayName;
      mSite.ShowDynForm('OYC0P3TDDY1ORIJO2SKTP2KZKG', P, nil, False, '');
    finally
      P.Free;
    end;

  //try
    //begin
   // mTemplates := mParams.NewFromDataType(dtList, 'TemplateParams').AsList;
{      if Assigned(mA) then

    end;
    mParams.GetOrCreateParam(dtString,'Firm_id',pkInput).AsString:=mA.OID;
    ShowMessage(ma.oid);
    mSite.ShowDynForm('OYC0P3TDDY1ORIJO2SKTP2KZKG', mParams, Nil, False, '');
  finally
    mParams.Free;
  end;  }
  end;


end;

procedure OnNewActionExecute(Sender: TObject);
begin
  MultiAkceExecuteItem(Sender, 0);
end;

procedure OnListActionExecute(Sender: TObject);
begin
  MultiAkceExecuteItem(Sender, 1);
end;



procedure FormCreate_Hook(Self: TSiteForm);
var

  mAct: TNxAction;
  mMAction: TNxMultiAction;
begin

  mAct := Self.GetNewAction;
  mAct.Caption := 'Nová aktivita';
  mAct.Category := 'tabDetail, tabList';
  mAct.OnExecute := @OnNewActionExecute;

  mAct := Self.GetNewAction;
  mAct.Caption := 'Aktivity firma';
  mAct.Category := 'tabDetail, tabList';
  mAct.OnExecute := @OnListActionExecute;

  
{  // Vytorime novou multiakci
  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Aktivity';
  mMAction.Hint := 'Práce s aktivitama';
  mMAction.Category := 'tabDetail, tabList';
  mMAction.OnExecuteItem := @MultiAkceExecuteItem;
  mMAction.Items.Add('Nová aktivita');
  mMAction.Items.Add('Aktivity firma');
}
  
end;

begin
end.