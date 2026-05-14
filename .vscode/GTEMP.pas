procedure InitSite_Hook(Self: TSiteForm);
var
    mAction: TAction;
begin
    mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := '## Seřadit řádky ##';
    mAction.Hint := 'Seřadí řádky bankovního výpisu';
    mAction.Category := 'tabList';
    mAction.OnExecute := @SortRows;
    //nove tlacitko pro založení nového dokladu 
    maction := Self.GetNewAction;
    maction.showcontrol := true;





end;

procedure SortRows(Sender: TObject);
var
  mDynSite: TDynSiteForm;
  mO: TNxHeaderBusinessObject;
  mORow: TNxRowBusinessObject;
  mOSC: TNxCustomBusinessObject;
  i, mPOSIndex: integer;
  ss, ss2: TStringList;
  s, mSCName: String;
  mDS: TDataSet;
  mAmountStr:string;
begin
  mDynSite := TComponent(Sender).DynSite;
  try
    ss := TStringList.Create;
    ss2 := TStringList.Create;
    mO := TNxHeaderBusinessObject(TDynSiteForm(mDynSite).CurrentObject);
    if NxMessageBox('Dotaz', 'Seřadit '+mo.DisplayName+'?', mdConfirm, mdbYesNo, 0, 0, False, Nil)=mrYes then begin
        if not Assigned(mO) or (mO.Rows.Count < 2) then begin
          NxShowSimpleMessage('Není co třídit.',mDynSite);
          exit;
        end;
        for i:=0 to mO.Rows.Count-1 do begin
          mORow := TNxRowBusinessObject(mO.Rows.BusinessObject[i]);
          mPOSIndex := mORow.GetFieldValueAsInteger('POSIndex');
          mAmountStr:= NxFloatToIBStr(100*mORow.GetFieldValueAsFloat('LocalTAmount'));
          while Length(mAmountStr) < 13 do
                mAmountStr := '0' + mAmountStr;
          if mORow.GetFieldValueAsBoolean('Credit') then mSCName:='0'+mAmountStr else mSCName:='1'+mAmountStr;
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


begin
end.