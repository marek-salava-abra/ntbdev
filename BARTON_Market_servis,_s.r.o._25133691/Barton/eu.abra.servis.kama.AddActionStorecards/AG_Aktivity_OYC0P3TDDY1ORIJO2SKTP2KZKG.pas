const cCLSID = 'REXI3SCQETNO3AGZSRRFN5CIMS';
      cActQueueID = '1000000101';
      cActQueueID2 = 'XXXXXXXXXX';

procedure InitSite_Hook(Self: TSiteForm);
var
  myAction: TBasicAction;
begin
  myAction := self.GetNewAction;
  myAction.Name := 'btnAddStorecards';
  myAction.Caption := 'Přidat karty hromadně';
  myAction.Hint := 'Přidá skladové karty do číselníku hromadně';
  myAction.Category := 'tabDetail';
  myAction.OnExecute := @AddStorecards;
  myAction.OnUpdate := @AddStorecardsUpdate;
end;

procedure AddStorecards(Sender: TObject);
var mFrm: TDynSiteForm;
  mActBO, mBO: TNxCustomBusinessObject;
  mSelected: Variant;
  i: integer;
  mSQL, mID: String;
begin
  mFrm := TDynSiteForm(TComponent(Sender).Site);
  if Assigned(mFrm) then begin
    mActBO := mFrm.CurrentObject;
    if Assigned(mActBO) then begin
      mSelected := GetAbraOLEStrings;
      try
        if GetIDsFromVisualRoll(mSelected) then begin
          for i:= 0 to mSelected.count -1 do begin
            mSQL := Format('Select ID as Hodnota from DefRollData where CLSID=%s and X_Storecard_ID=%s and X_Activity_ID=%s',
             [QuotedStr(cCLSID), QuotedStr(mSelected.Strings[i]), QuotedStr(mActBO.OID)]);
            mID := GetFirstRowFromSQL(mActBO.ObjectSpace, mSQL, '');
            if NxIsEmptyOID(mID) then begin
              mBO := mActBO.ObjectSpace.CreateObject(cCLSID);
              try
                mBO.New;
                mBO.SetFieldValueAsString('X_Activity_ID', mActBO.OID);
                mBO.SetFieldValueAsString('X_STRING_VALUE', mActBO.DisplayName);
                mBO.SetFieldValueAsString('X_Storecard_ID', mSelected.Strings[i]);
                mBO.Save;
              finally
                mBO.Free;
              end;
            end;
          end;
        end;
      finally
        mSelected := nil;
        mFrm.ActiveDataSet.RefreshAndRestoreLastSelectedItem;
      end;
    end;
  end;
end;

function GetFirstRowFromSQL(AOS: TNxCustomObjectSpace; ASQL: string; ADefault: Variant): Variant;
var
  mDataset: TDataset;
begin
  result := ADefault;
  mDataset := TMemoryDataset.Create(nil);
  try
    AOS.SQLSelect2(ASQL, mDataset);
    if mDataset.Active then begin
      mDataset.First;
      Result := mDataset.FieldValues['Hodnota'];
    end;
  finally
    mDataset.free;
  end;
end;

function GetIDsFromVisualRoll(var mSelected: Variant): Boolean;
var
  mRoll, mOLE: Variant;
begin
  result := false;
  mSelected := GetAbraOLEStrings;
  mOLE := GetAbraOLEApplication;
  mSelected.Clear;
  mRoll := mOLE.GetRoll(Roll_StoreCards, 1);
  Result := mRoll.MultiSelectDialog(True, mSelected);
  mRoll := nil;
  mOLE := nil;
end;


procedure AddStorecardsUpdate(Sender: TObject);
var
  mSite: TSiteForm;
begin
  if Sender is TComponent then begin
    mSite := TComponent(Sender).Site;
    if Assigned(mSite) then begin
      if mSite is TDynSiteForm then begin
        if Assigned(TDynSiteForm(mSite).CurrentObject) then
          TAction(Sender).Enabled := ((TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('ActQueue_ID') = cActQueueID) or
            (TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('ActQueue_ID') = cActQueueID2)) and not TDynSiteForm(mSite).Edit;
      end;
    end;
  end;
end;


begin
end.