uses
  '_Books_803.uScFunc';
//  '_Books_803.uScPersistParam';
//  '_Books_803.uScDialog';

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
  mDynSite := TDynSiteForm(NxFindSiteForm(TControl(Sender)));
  if not Assigned(mDynSite) then begin
    NxShowSimpleMessage(
      'Nenašel se objekt "TNxSiteform"!'#13#10'Nelze provést požadovaný úkol.',nil);
    exit;
  end;
  try
    ss := TStringList.Create;
    ss2 := TStringList.Create;
    case Index of
      0,1: begin
        mO := TNxHeaderBusinessObject(mDynSite.CurrentObject);
        if not Assigned(mO) or (mO.Rows.Count < 2) then begin
          NxShowMessage('Info','Není co třídit',mdInformation,false,mDynSite);
          //SimpleMessageII(mDynSite, mtInformation, 'Není co třídit.');
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
        mDS := GetCurrentRowDataset(mDynSite);
        mDS.Refresh;
      end;
    end;
  finally
    ss.Free;
    ss2.Free;
    NxShowMessage('info','Seřazeno',mdInformation,false,mDynSite);
  end;
end;

procedure InitSite_Hook(Self: TSiteForm);
var
  mMAction: TMultiAction;
  mAction: TBasicAction;
  mAList: TActionList;
  i: integer;
  mAct: TBasicAction;
  mUser : TNxCustomBusinessObject;
begin
  if not Assigned(Self.BaseObjectSpace) then
    exit;


  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Hint := 'Řazení objednávky';
  mMAction.Caption := 'Řazeni OV';
  mMAction.Items.Add('Řazení OV');
  mMAction.Category := 'tabList';
  mMAction.OnExecuteItem := @onMyExecute;

end;

begin
end.
