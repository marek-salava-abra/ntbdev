    {
function GenIntEAN(ABO : TNxCustomBusinessObject; APrefix : String) : string;
var
  mContext: TNxContext;
  mList: TStrings;
  mSQLSelect : string;
  mEAN : string;
  mEANPrefix : string;
  mNumEAN : Longint;
  mEANLen : integer;
const
  cSQL =  'select max(cast(ib_string_left(ean, 12) as varchar(12)) ) from StoreUnits where ean like ''%s_______'' ';
begin
  Result := '';
    mSQLSelect := Format(cSQL, [APrefix]);
    mList := TStringList.Create;
    try
      mContext := NxCreateContext_1(ABO);
      try
        mContext.SQLSelect(mSQLSelect, mList);
      finally
        mContext.Free;
      end;
      if (mList.Count > 0) then begin
        mEAN := mList.Strings[0];
        mEAN := Trim(mEAN);
        mEANPrefix := NxLeft(mEAN, 6);
        mEANLen := Length(mEAN);
        mEAN := NxRight(mEAN, mEANLen - 6);
        mNumEAN := StrToInt(mEAN);
        mNumEAN := mNumEAN + 1;
        mEAN := IntToStr(mNumEAN);
        mEAN := NxPadL(mEAN, mEANLen - 6, '0');
        mEAN := mEANPrefix + mEAN;
        NxCorrectEAN13(mEAN);
        Result := mEAN;
      end;
    finally
      mList.Free;
    end;
end;







procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TNxAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Generuj EAN';
  mAction.Hint := 'Vygeneruje EAN';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportOnExecute;
  mAction.OnUpdate := @ImportOnUpdate;
end;


procedure ImportOnUpdate(Sender: TObject);
begin
  TNxAction(Sender).Enabled := True;
end;


procedure ImportOnExecute(Sender: TObject);
var
  mSite: TSiteForm;
  mBO : TNxCustomBusinessObject;
  mMainUnitCode : string;
  mUnits : TNxCustomBusinessMonikerCollection;
  i : integer;
  mUnit : TNxCustomBusinessObject;
  mEAN : string;
begin
  if Sender is TComponent then begin
    mSite := NxFindSiteForm(TComponent(Sender));
    if not (mSite is TRollSiteForm) then begin
      ShowMessage('nejsem dynsite');
      exit;
    end;
    
    if not Assigned(TBusRollSiteForm(mSite).CurrentObject) then begin
      ShowMessage('nemam aktualni object.');
      exit;
    end;
    
//    mBO := TBusRollSiteForm(mSite).CurrentObject.ObjectSpace.CreateObject('C3V5QDVZ5BDL342M01C0CX3FCC');
//    mBO.Load(TBusRollSiteForm(mSite).CurrentObject.OID, nil);
     mBO := TBusRollSiteForm(mSite).CurrentObject;
//    mBO := TBusRollSiteForm(mSite).CurrentObject.Clone;

  if NxIsBlank(mBO.GetFieldValueAsString('EAN')) then begin
    mMainUnitCode := mBO.GetFieldValueAsString('MainUnitCode');
    mUnits := mBO.GetCollectionMonikerForFieldCode(mBO.GetFieldCode('StoreUnits'));
    for i := 0 to mUnits.count - 1 do begin
      mUnit := mUnits.BusinessObject[i];
      if mUnit.GetFieldValueAsString('Code') = mMainUnitCode then begin
        mEAN := GenIntEAN(mBO, '222000');
        mUnit.SetFieldValueAsString('EAN', mEAN);
      end;
    end;
    mBO.Save;
    mSite.Refresh;
  end;

    
  end;
end;
            }

begin
end.