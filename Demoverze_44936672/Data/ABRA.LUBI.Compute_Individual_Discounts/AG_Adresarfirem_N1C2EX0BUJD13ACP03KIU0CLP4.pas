const
  cInDebug = False;

procedure ShowDebugMessage(AMessage: string);
begin
  if cInDebug then
    ShowMessage(AMessage);
end;

{
Vyvolává se po vytvoření instance formuláře.
}

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TNxAction;
  mMAction: TNxMultiAction;
begin
  mAction := self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Slevy dle menu';
  mAction.Hint := 'Otevře číselník nastavení individuální slev pro aktuální firmu';
  mAction.Category := 'tabList,tabDetail';
  mAction.OnExecute := @IndDiscountsRollOnExecute;
  mAction.OnUpdate := @IndDiscountsRollOnUpdate;
end;

procedure IndDiscountsRollOnExecute(Sender: TObject; ACLSID: string);
var
  mRollSite: TBusRollSiteForm;
  mSite: TSiteForm;
  mOLE: Variant;
  mAllIDs, mSQL: string;
  mAgenda: Variant;
  mXX: String;
  mID, mOID: string;
  mDataSet: TNxCustomObjectDataSet;
  mObject: TNxCustomBusinessObject;
  mValues: TStrings;
  mIDList : TStringList;
  mContext: TNxContext;
  i: integer;
  mParams : TNxParameters;
  mRoll: TNxCustomRoll;
begin
  mOLE := GetAbraOLEApplication;
  //mCheckBox := TCheckBox(Sender);
  mSite := NxFindSiteForm(TNxAction(Sender));
  mRollSite := TBusRollSiteForm(mSite);
  mDataSet := TNxCustomObjectDataSet(mRollSite.DataSet);
  mObject := mDataSet.CurrentObject;
  mContext := NxCreateContext_1(mObject);
  mOID := mObject.GetFieldValueAsString('ID');
  ShowDebugMessage('FirmOID: ' + mOID);
  // SQLko pro Excluded
  mSQL := 'select ID from DefRollData where CLSID = ''QCMDDCC1QJE4V2CYU1YUPVBLFS'' and Hidden = ''N'' and ' +
          '(not (X_Firm_ID IN (SELECT ID FROM Firms WHERE ID = ''%s'' OR Firm_ID = ''%s'')))';
  // SQLko pro Allowed
  //mSQL := 'select ID from DefRollData where CLSID = ''QCMDDCC1QJE4V2CYU1YUPVBLFS'' and Hidden = ''N'' and ' +
  //        '(not (X_Firm_ID IN (SELECT ID FROM Firms WHERE ID = ''%s'' OR Firm_ID = ''%s'')))';
  mSQL := Format(mSQL, [mOID, mOID]);
  ShowDebugMessage('SQL: ' + mSQL);
  mValues := TStringList.Create;
  try
    mIDList := TStringList.Create;
    try
      mParams := TNxParameters.Create;
      try
        mContext.SQLSelect(mSQL, mValues);
        // lubi stale neumime...
        // v Nexu se otevirani ciselniku resi pomoci TNxRollMastera - ve skriptingu neni
        {For i := 0 to mValues.Count - 1 do
          //If not ASelection.Find(mSQLRes.Strings[i], A) then
          mIDList.Add(mValues.Strings[i]);
        mIDList.Delimiter := ';';
        // Pokud se použije _Allowed, zahlásí to, že eíselník je omezen, pokud _Excluded tak ne :)
        ShowDebugMessage('nastavovani parametru');
        mParams.NewFromDataType(dtString, '_Excluded', pkUnknown).AsString := mIDList.DelimitedText;
        ShowDebugMessage('vlastni otevirani ciselniku');

        mRoll := mSite.GetRoll('LFCQQPZHNF04XALP0ELUEEJEKK', 0);
        // toto nelze pouzit - padne na Assert v uBusRol - typ vkList resi vizualno, cili RollMaster ??
        mRoll.Validate(mContext, vkList, mParams, nil);
        //mSite.ShowDynForm('LFCQQPZHNF04XALP0ELUEEJEKK', mParams, nil, False, '');
        }
        // lubi vraceno zpet...
        // a jedeme zase pres OLE...
        mAllIDs := '';
        for i := 0 to mValues.Count - 1 do begin
          mID := NxTrim(mValues.Strings(i), '"');
          if mAllIDs = '' then
            mAllIDs := mAllIDs + mID
          else
            mAllIDs := mAllIDs + ',' + mID;
        end;
        mAgenda := mOLE.GetRoll('LFCQQPZHNF04XALP0ELUEEJEKK', 0);
        //mAgenda.Params.Add('_Allowed=' + mAllIDs);
        // POZOR!!! Excluded umoznuje do omezeneho ciselniku pridavat zaznamy, _Allowed NE!!!
        mAgenda.Params.Add('_Excluded=' + mAllIDs);
        mAgenda.Params.Add('_CurrentFirm=' + mOID);
        mAgenda.SelectDialog(True, mXX);
      finally
        mParams.Free;
      end;
    finally
      mIDList.Free;
    end;
  finally
    mValues.Free;
  end;
end;

procedure IndDiscountsRollOnUpdate(Sender: TObject);
var
  mSite: TSiteForm;
begin
  if Sender is TComponent then begin
    mSite := NxFindSiteForm(TComponent(Sender));
    if Assigned(mSite) then begin
      if mSite is TBusRollSiteForm then begin
        TNxAction(Sender).Enabled := Not TBusRollSiteForm(mSite).Dataset.EOF
          and Not TBusRollSiteForm(mSite).Edit;
      end;
    end;
  end;
end;

begin
end.