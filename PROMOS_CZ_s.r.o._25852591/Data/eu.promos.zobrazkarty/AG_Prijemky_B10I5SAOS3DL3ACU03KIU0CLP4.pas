procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2, mAction3: TBasicAction;
  mUser : TNxCustomBusinessObject;
begin
  if not Assigned(Self.BaseObjectSpace) then
    exit;


    mAction3 := Self.GetNewAction;
    mAction3.ShowControl := True;
    mAction3.ShowMenuItem := True;
    mAction3.Caption := 'Sklad. karty';
    mAction3.Hint := 'Zobrazí skladové karty';
    mAction3.Category := 'tabList';
    mAction3.OnExecute := @StoreCards;
  end;

procedure StoreCards(Sender: TObject);
var
mSite: TSiteForm;
mPR: TNxCustomBusinessObject;
mRows: TNxCustomBusinessMonikerCollection;
i: integer;
mRollParams: TNxParameters;
mList: TStringList;
begin
if Sender is TComponent then begin
    mSite := TComponent(Sender).DynSite;
    if Assigned(mSite) and (mSite is TDynSiteForm) then begin
      mPR := TDynSiteForm(mSite).CurrentObject;
      mRollParams := TNxParameters.Create;
      mList := TStringList.Create;
      mRows:= mpr.GetLoadedCollectionMonikerForFieldCode(mPR.GetFieldCode('Rows'));
      for i:=0 to mrows.Count-1 do begin

         mlist.Add(mrows.BusinessObject[i].GetFieldValueAsString('StoreCard_ID'));

      end;
    mRollParams.GetOrCreateParam(dtString, '_Allowed', pkInput).AsString :=NxStringsToCkListStr(mList);
    mRollParams.NewFromDataType(dtBoolean, '_InOtherSlot', pkInput).AsBoolean := True;
    NxShowRoll(mSite.SiteContext, 'S3WZQKDB5FDL342M01C0CX3FCC', mRollParams, 0, '', nil);
    end;
  end;
end;

begin
end.