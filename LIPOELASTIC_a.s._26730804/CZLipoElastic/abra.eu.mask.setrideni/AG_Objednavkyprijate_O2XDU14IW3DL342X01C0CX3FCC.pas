uses 'EU.Aabra.Mask.Validace.lib';
function NewDL(mDL: TNxCustomBusinessObject;index:integer): string;
var
  i, mPosIndex: integer;
  mMon: TNxCustomBusinessMonikerCollection;
  mRow, mNewRow: TNxCustomBusinessObject;
  mList: TStringList;
  mText: string;
begin
  result := '';

  try
    mMon := mDL.GetLoadedCollectionMonikerForFieldCode(mDL.GetFieldCode('ROWS'));
    mList := TStringList.Create;
    try
      for i := 0 to mMon.Count-1 do begin
        mRow := mMon.BusinessObject[i];
        if index=0 then mtext := mRow.GetFieldValueAsstring('Storecard_ID.X_typ_produktu');
        if index=1 then mtext := mRow.GetFieldValueAsstring('Storecard_ID.Name');
        if index=2 then mtext := mRow.GetFieldValueAsstring('Storecard_ID.Code');
        if index=3 then mtext := mRow.GetFieldValueAsstring('Storecard_ID.Ean');
        mList.AddObject(mtext, mRow);
      end;
      mList.Sort;
      for i := 0 to mList.Count-1 do begin
        mRow := TNxCustomBusinessObject(mList.Objects[i]);
        mRow.SetFieldValueAsInteger('posindex',i);
        mrow.Save;
      end;

    finally
      mList.Free;
    end;
    mDL.ClearValidateErrors;
    if Not mDL.Validate() then begin
      mList := TStringList.Create;
      try
        mDL.GetValidateErrors(mList);
        mText := mList.Text;
        NxToken(mText, '=');
        MessageDlg('Doklad nelze setřídit z těchto důvodů:' + #13#10 + mText,
          mtWarning, [mbOK], 0);
      finally
        mList.Free;
      end;
    end else begin
      mDL.Save;
      result := mDL.OID;
    end;
  finally
  end;
end;

procedure NewDLExecute(Sender: TObject;index:integer);
var
  mSite: TDynSiteForm;
  mObj: TNxCustomBusinessObject;
  mID: string;
begin
  if Sender is TComponent then begin
    //OutputDebugString('Sender je TComponent.');
    mSite := TComponent(Sender).DynSite;
    //OutputDebugString('Nalezen nadřízený SiteForm.');

    // Ziskame aktualni objekt (TNxCustomBusinessObject)
    mObj := mSite.CurrentObject;
    try
      if Assigned(mObj) then
      begin
        mID := NewDL(mObj,index);
        if not NxIsEmptyOID(mID) then
            if index=0 then NxShowSimpleMessage('Setřídění podle typu proběhlo korektně',nil);
            if index=1 then NxShowSimpleMessage('Setřídění podle názvu proběhlo korektně',nil);
            if index=2 then NxShowSimpleMessage('Setřídění podle kódu proběhlo korektně',nil);
            if index=3 then NxShowSimpleMessage('Setřídění podle Ean proběhlo korektně',nil);
      end;
    finally
      mObj.Free;
    end;
  end;
end;

procedure NewDLUpdate(Sender: TObject);
var
  mSite: TDynSiteForm;
  mObj: TNxCustomBusinessObject;
begin
  //OutputDebugString('Jsem v OnUpdate.');
  //OutputDebugString('Sender je '+Sender.ClassName+'.');
  // Zjistime, zda je Sender typu TComponent
  if Sender is TComponent then begin
    //OutputDebugString('Sender je TComponent.');
    // Vyhledame SiteForm (TSiteForm) na kterem je dana akce
    mSite := TComponent(Sender).DynSite;
    if Assigned(mSite) then begin
      //OutputDebugString('Nalezen nadřízený SiteForm.');

      // akce je k dispozici pouze v pripade, ze je v datasetu nejaky zaznam
      // a v pripade, ze neni zahajena editace
      mObj := mSite.CurrentObject;
      try
        TAction(Sender).Enabled := not mSite.Edit and Assigned(mObj);
      finally
        mObj.Free;
      end;
    end;
  end;
end;

procedure FormCreate_Hook(Self: TSiteForm);
var
  mmAction: TMultiAction;
begin
mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Setřídění řádku dokladu';
          mMAction.Caption := 'Setřídění řádku dokladu';
          mMAction.Items.Add('Typu skladové karty');
          mMAction.Items.Add('Názvu');
          mMAction.Items.Add('Kódu');
          mMAction.Items.Add('EAN');

          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @NewDLExecute;
          mmAction.OnExecute := @NewDLExecute;

end;

begin
end.