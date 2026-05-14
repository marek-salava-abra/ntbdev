procedure OnMyExecute(Sender: TObject; Index: integer);
var
  mDynSite: TDynSiteForm;
  mO: TNxHeaderBusinessObject;
  mORow: TNxRowBusinessObject;
  mOSC: TNxCustomBusinessObject;
  i, mPOSIndex: integer;
  ss, ss2: TStringList;
  s, mSCName: String;
  mDS: TDataSet;
begin
  mDynSite := TDynSiteForm(NxFindSiteForm(TComponent(Sender)));
  if not Assigned(mDynSite) then begin
    NxShowSimpleMessage('Nenašel se objekt "TNxSiteform"!'#13#10'Nelze provést požadovaný úkol.',nil);
    exit;
  end;
  try
    ss := TStringList.Create;
    ss2 := TStringList.Create;
    if Index=0 then begin
        mO := TNxHeaderBusinessObject(mDynSite.CurrentObject);
        if not Assigned(mO) or (mO.Rows.Count < 2) then begin
          NxShowSimpleMessage('Není co třídit.',mDynSite);
          exit;
        end;
        for i:=0 to mO.Rows.Count-1 do begin
          mORow := TNxRowBusinessObject(mO.Rows.BusinessObject[i]);
          mPOSIndex := mORow.GetFieldValueAsInteger('POSIndex');
          if NxIsEmptyOID(mORow.GetFieldValueAsString('StoreCard_ID')) then
            mSCName := '_' + IntToStr(mPOSIndex)
          else begin
            mOSC := mORow.GetMonikerForFieldCode(mORow.GetFieldCode('StoreCard_ID')).BusinessObject;
            mSCName := mOSC.GetFieldValueAsString('Code');
          end;
          ss.Values[mSCName + mORow.OID] := mORow.OID + IntToStr(mPOSIndex);
        end;
        ss.Sort;
        for i:=0 to ss.Count-1 do begin
          s := Copy(ss.ValueFromIndex(i), 1, 10);
          ss2.Values[s] := IntToStr(i+1);
        end;
        for i:=0 to mO.Rows.Count-1 do begin
          mORow := TNxRowBusinessObject(mO.Rows.BusinessObject[i]);
          mORow.Position := StrToInt(ss2.Values[mORow.OID]);
        end;
        mo.save;
        NxShowSimpleMessage('Seřazeno', mDynSite);


    end;
    if Index=0 then begin
        mO := TNxHeaderBusinessObject(mDynSite.CurrentObject);
        if not Assigned(mO) or (mO.Rows.Count < 2) then begin
          NxShowSimpleMessage('Není co třídit.',mDynSite);
          exit;
        end;
        for i:=0 to mO.Rows.Count-1 do begin
          mORow := TNxRowBusinessObject(mO.Rows.BusinessObject[i]);
          mPOSIndex := mORow.GetFieldValueAsInteger('POSIndex');
          if NxIsEmptyOID(mORow.GetFieldValueAsString('StoreCard_ID')) then
            mSCName := '_' + IntToStr(mPOSIndex)
          else begin
            mOSC := mORow.GetMonikerForFieldCode(mORow.GetFieldCode('StoreCard_ID')).BusinessObject;
            mSCName := mOSC.GetFieldValueAsString('Name');
          end;
          ss.Values[mSCName + mORow.OID] := mORow.OID + IntToStr(mPOSIndex);
        end;
        ss.Sort;
        for i:=0 to ss.Count-1 do begin
          s := Copy(ss.ValueFromIndex(i), 1, 10);
          ss2.Values[s] := IntToStr(i+1);
        end;
        for i:=0 to mO.Rows.Count-1 do begin
          mORow := TNxRowBusinessObject(mO.Rows.BusinessObject[i]);
          mORow.Position := StrToInt(ss2.Values[mORow.OID]);
        end;
        mo.save;
        NxShowSimpleMessage('Seřazeno', mDynSite);


    end;
  finally
    ss.Free;
    ss2.Free;
  end;
end;


procedure InitSite_Hook(Self: TSiteForm);
var
  mMAction: TMultiAction;

  i: integer;
  mUser : TNxCustomBusinessObject;
begin
  if not Assigned(Self.BaseObjectSpace) then
    exit;


  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Hint := 'Řazení objednávky dle kódu';
  mMAction.Caption := 'Řazeni OV';
  mMAction.Items.Add('Řazení OV dle kódu');
  mMAction.Items.Add('Řazení OV dle Názvu');
  mMAction.Category := 'tabList';
  mMAction.OnExecuteItem := @onMyExecute;

end;

begin
end.
