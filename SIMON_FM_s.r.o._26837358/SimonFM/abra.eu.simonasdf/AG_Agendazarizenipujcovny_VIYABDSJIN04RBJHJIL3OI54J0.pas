procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mMAction : TMultiAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Zápůjčky zařízení';
  mAction.Hint := 'Zobrazí zapůjčení zařízení v reportech';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ShowItems;
  //mAction.OnUpdate := @CreateDocumentOnUpdate;
end;

procedure ShowItems(Sender: TObject);
Var
 mSite: TSiteForm;
 mObj : TNxCustomBusinessObject;
 mParams : TNxParameters;
 mR : TStringList;

begin
 mSite := TComponent(Sender).BusRollSite;
    if mSite is TBusRollSiteForm then begin
     mParams := TNxParameters.Create;
      try
        mR := TStringList.Create;

      mObj := TBusRollSiteForm(mSite).DataSet.CurrentObject;
      FillParamsForRow(mR, mObj);
      mR.Delimiter := ';';
      mParams.NewFromDataType(dtString, '_Allowed', pkUnknown).AsString := mR.DelimitedText;

      mSite.ShowDynForm('OE4MXRFEMWM4TFZZERF1A45NB0', mParams, nil, False, '');
      finally
      mr.Free;
      end;
    end;

end;

procedure FillParamsForRow(AList : TStringList; ARow : TNxCustomBusinessObject);
const
  cSQL = 'SELECT A.ID FROM DefRollData A WHERE A.CLSID=''VFNPR04IPRQ41HGAGUTXNGLWYW'' AND A.X_RentalDevice_ID=''%s'' ';
begin
  if Assigned(AList) then
    ARow.ObjectSpace.SQLSelect(Format(cSQL, [ARow.OID]), AList);
end;

begin
end.