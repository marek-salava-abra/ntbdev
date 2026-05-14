uses
  '_Books_NoDevelUsr.uScSiteFunc';

const
  cInDebug = False;
  cAppName = 'IndividualDiscounts';

var
  fCLSID: string;

procedure ShowDebugMessage(AMessage: string);
begin
  if cInDebug then begin
      OutputDebugString(Format('%s : %s',[cAppName, VarToStr(AMessage)]));
  end;
end;

procedure ComputeIndividualDiscounts(var ARow: TNxCustomBusinessObject; AForceRecalculate, AForFirm: Boolean);
var
  mHeader: TNxCustomBusinessObject;
  mMon: TNxBusinessMoniker;
  mBoolValue, mContinue: Boolean;
  mRowMenu_OID, mFirm_OID, mSQL, mSuperiorMenu_OID, mValue, mStrValue: string;
  mDiscount: Extended;
  mValues: TStrings;
  mContext: TNxContext;
  mClearDiscounts: Boolean;
  mSpecialOID: string;
begin
  ShowDebugMessage('Skript pocitani ind. slevy na radku spusten.');
  mClearDiscounts := False;
  // testovani CheckBit state BO resi stavy osDeleted (3) a osMarkForDelete (4)
  if (not NxCheckBit(ARow.State, 3)) and (not NxCheckBit(ARow.State, 4)) then begin
    if ARow.GetFieldValueAsInteger('RowType') = 3 then begin
      //ShowDebugMessage('Jsem uvnitr telicka na pocitani. Zjistuje se hlavicka radku.');
      mHeader := TNxNotPositionedRowBusinessObject(ARow).Header.BusinessObject;
      mBoolValue := mHeader.GetFieldValueAsBoolean('X_DONT_USE_MENUDISCOUNT');
      if {not }mBoolValue then begin
        // na hlavicce dokladu je pocitani slev povoleno -> pokracuji
        mMon := ARow.GetMonikerForFieldCode(ARow.GetFieldCode('StoreCard_ID'));
        if not mMon.IsNull and ((mMon.OID <> '') and (mMon.OID <> '0000000000')) then begin
          ShowDebugMessage('Skript pocitani ind. slevy - skl karta je ok');
          mBoolValue := mMon.BusinessObject.GetFieldValueAsBoolean('X_DONT_USE_MENU_DISCOUNT');
          if not mBoolValue then begin
            ShowDebugMessage('Skript pocitani ind. slevy - na hlavicce je nastaveno pouzivani slevy');
            // na skladove karte je pocitani slev povoleno -> pokracuji
            mBoolValue := ARow.GetFieldValueAsBoolean('X_DISCOUNTEVALUED');
            if (not mBoolValue) or AForceRecalculate then begin
              ShowDebugMessage('Skript pocitani ind. slevy - pokracuji, protoze na radku jeste sleva nebyla pocitana nebo je proces spusten jako prepocitani slev a to se pak provadi vzdy');
              // pokracuji, protoze na radku jeste sleva nebyla pocitana nebo je proces spusten jako prepocitani slev a to se pak provadi vzdy
              mRowMenu_OID := mMon.BusinessObject.GetFieldValueAsString('StoreMenuItem_ID');
              mFirm_OID := mHeader.GetFieldValueAsString('Firm_ID');
              mValues := TStringList.Create;
              try
                mContext := NxCreateContext_1(ARow);
                mContinue := True;
                mSpecialOID := '';
                mDiscount := 0;
                //while (mDiscount = 0) and mContinue do begin
                while (mSpecialOID = '') and mContinue do begin

                  mSQL := 'select ID from DefRollData where CLSID = ''QCMDDCC1QJE4V2CYU1YUPVBLFS'' and Hidden = ''N'' ' +
                          'and X_StoreMenu_ID = ''%s'' and ' +
                          '(X_Firm_ID IN (SELECT ID FROM Firms WHERE ID = ''%s'' OR Firm_ID = ''%s''))';
                  mSQL := Format(mSQL, [mRowMenu_OID, mFirm_OID, mFirm_OID]);
                  mValues.Clear;
                  mContext.SQLSelect(mSQL, mValues);
                  mSpecialOID := '';
                  if mValues.Count > 0 then
                    mSpecialOID := Trim(mValues.Strings[0]);

                  mSQL := 'select X_Discount from DefRollData where CLSID = ''QCMDDCC1QJE4V2CYU1YUPVBLFS'' and Hidden = ''N'' ' +
                          'and X_StoreMenu_ID = ''%s'' and ' +
                          '(X_Firm_ID IN (SELECT ID FROM Firms WHERE ID = ''%s'' OR Firm_ID = ''%s''))';
                  mSQL := Format(mSQL, [mRowMenu_OID, mFirm_OID, mFirm_OID]);
                  mValues.Clear;
                  mContext.SQLSelect(mSQL, mValues);
                  mValue := '';
                  if mValues.Count > 0 then
                    mValue := Trim(mValues.Strings[0]);
                  if mValue <> '' then
                    mDiscount := StrToFloat(mValue);
                  //if mDiscount = 0 then begin
                  if mSpecialOID = '' then begin
                    // ted jeste testneme, zda na urovni menu neni nastaven priznak a pokud ano proces zastavime
                    mSQL := 'select X_DisableIndividualDiscount from StoreMenu where ID = ''%s''';
                    mSQL := Format(mSQL, [mRowMenu_OID]);
                    mValues.Clear;
                    mContext.SQLSelect(mSQL, mValues);
                    mStrValue := '';
                    if mValues.Count > 0 then begin
                      mStrValue := Trim(mValues.Strings[0]);
                      if mStrValue = 'A' then
                        mContinue := False;
                    end;
                    if mContinue then begin
                      // sleva nezadana, zjistime tedy nadrazene oid menu a zkusime to znovu, i pro skryte
                      mSQL := 'select Parent_ID from StoreMenu where ID = ''%s''';
                      mSQL := Format(mSQL, [mRowMenu_OID]);
                      mValues.Clear;
                      mContext.SQLSelect(mSQL, mValues);
                      mSuperiorMenu_OID := '';
                      if mValues.Count > 0 then
                        mSuperiorMenu_OID := Trim(mValues.Strings[0]);
                      if NxIsEmptyOID(mSuperiorMenu_OID) then
                        // tohle znamena, ze jsem to jiz provedl na rootu menu -> konec procesu
                        mContinue := False
                      else
                        mRowMenu_OID := mSuperiorMenu_OID;
                    end;
                  end;
                end;
              finally
                mValues.Free;
              end;
              // a nakonec ulozim vysledek na radkovy objekt
              if AForFirm and (mDiscount = 0) then begin
                if mSpecialOID <> '' then
                  ARow.SetFieldValueAsBoolean('X_DISCOUNTEVALUED', True);
                ARow.SetFieldValueAsFloat('X_MENUDISCOUNT', 0);
              end
              else begin
                mBoolValue := ARow.GetFieldValueAsBoolean('X_DISCOUNTEVALUED');
                if (not mBoolValue) or AForFirm then begin
                  ShowDebugMessage('Sleva spoctena a ZAPISUJE se. Sleva: ' + FloatToStr(mDiscount));
                  ARow.SetFieldValueAsFloat('X_MENUDISCOUNT', mDiscount);
                end;
                ARow.SetFieldValueAsBoolean('X_DISCOUNTEVALUED', True);
              end;
              // nasilne vyvolani prepocitani celeho dokladu pomoci dirty
              // pri schozeni se zavola metoda recalculatedocument v uBusAbra, coz je otreba pro prepocet castek
              // nemelo by to mit zadne vedlejsi ucinky
              try
                mHeader.SetFieldValueAsBoolean('Dirty', True);
              finally
                mHeader.SetFieldValueAsBoolean('Dirty', False);
              end;
              ShowDebugMessage('Sleva spoctena. Sleva: ' + FloatToStr(mDiscount));
            end;
          end
          else
            mClearDiscounts := True;
        end;
      end
      else
        mClearDiscounts := True;
    end
    else
      mClearDiscounts := True;
    if mClearDiscounts then begin
      ShowDebugMessage('Kompletni vynulovani ind.slev');
      ARow.SetFieldValueAsFloat('X_MENUDISCOUNT', 0);
      ARow.SetFieldValueAsBoolean('X_DISCOUNTEVALUED', False);
      try
        mHeader.SetFieldValueAsBoolean('Dirty', True);
      finally
        mHeader.SetFieldValueAsBoolean('Dirty', False);
      end;
    end;
  end;
end;

// metody pro vytvoreni a obhospodarovani tlacitka na prepocet slev na agendach
procedure AddButton(AForm: TSiteForm; ACLSID: string);
var
  mAction: TNxAction;
begin
  fCLSID := ACLSID;
  mAction := AForm.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Přepočet slevy';
  mAction.Hint := 'Přepočítá individuální slevy dle skladového menu na všech řádcích označených dokladů';
  mAction.Category := 'tabList';
  mAction.OnExecute := @IndDiscountsOnExecute;
  mAction.OnUpdate := @IndDiscountsOnUpdate;
end;

procedure IndDiscountsOnExecute(Sender: TObject; ACLSID: string);
var
  mSite: TSiteForm;
  mDocs: TStrings;
  mObject: TNxCustomBusinessObject;
  i, x: integer;
  mCollection: TNxCustomBusinessMonikerCollection;
  mRow: TNxCustomBusinessObject;
begin
  if Sender is TComponent then begin
    mSite := NxFindSiteForm(TComponent(Sender));
    if Assigned(mSite) then begin
      if mSite is TDynSiteForm then begin
        mDocs := TStringList.Create;
        try
          TDynSiteForm(mSite).FillListWithSelectedRows(mDocs);
          for x := 0 to mDocs.Count - 1 do begin
            mObject := mSite.BaseObjectSpace.CreateObject(fCLSID);
            try
              mObject.Load(mDocs.Strings[x], nil);
              mObject.Invalidate;
              // rows
              mCollection := mObject.GetLoadedCollectionMonikerForFieldCode(mObject.GetFieldCode('Rows'));
              for i := 0 to mCollection.Count - 1 do begin
                mRow := mCollection.BusinessObject(i);
                mRow.Invalidate;
                mRow.SetFieldValueAsBoolean('X_DISCOUNTEVALUED', False);
                ComputeIndividualDiscounts(mRow, True, False);
              end;
              ShowDebugMessage('Save na hlave');
              mObject.Invalidate;
              mObject.Save;
              ShowDebugMessage('Save na hlave - konec');
            finally
              mObject.Free;
            end;
          end;
          TDynSiteForm(mSite).RefreshData;
        finally
          mDocs.Free;
        end;
      end;
    end;
  end;
end;

procedure IndDiscountsOnUpdate(Sender: TObject);
var
  mSite: TSiteForm;
begin
  // Zjistime, zda je Sender typu TComponent
  if Sender is TComponent then begin
    // Vyhledame SiteForm (TSiteForm) na kterem je dana akce
    mSite := NxFindSiteForm(TComponent(Sender));
    if Assigned(mSite) then begin
      // Pokud je SiteForm typu agenda, pretypujeme promennou
      if mSite is TDynSiteForm then begin
        // akce je k dispozici pouze v pripade, ze je v datasetu nejaky zaznam
        // a v pripade, ze neni zahajena editace
        TNxAction(Sender).Enabled := Not TDynSiteForm(mSite).ActiveDataset.EOF
          and Not TDynSiteForm(mSite).Edit;
      end;
    end;
  end;
end;

procedure RecalculateDiscountsForFirm(AHeader: TNxCustomBusinessObject);
var
  i: integer;
  mCollection: TNxCustomBusinessMonikerCollection;
  mRow: TNxCustomBusinessObject;
begin
  // rows
  mCollection := AHeader.GetLoadedCollectionMonikerForFieldCode(AHeader.GetFieldCode('Rows'));
  for i := 0 to mCollection.Count - 1 do begin
    mRow := mCollection.BusinessObject(i);
    ComputeIndividualDiscounts(mRow, True, True);
  end;
end;

// pridani check boxu na detail agend
procedure AddCheckBox(AForm: TSiteForm);
var
  mComponent: TCheckBox;
  mControl, gbDiscounts, chkFrozenDiscounts: TControl;
  mLeft, mTop: Integer;
begin
  ShowDebugMessage('AddCheckBox: MemberSiteForm');
  MemberSiteForm(AForm);
  mControl := NxFindChildControl(AForm, 'chkIndividualDiscounts');
  if VarIsNull(mControl) then
    mComponent := TCheckBox(mControl)
  else
    mComponent := nil;
  if not VarIsNull(mComponent) then begin
    gbDiscounts := NxFindChildControl(AForm, 'gbDiscounts');
    mLeft := gbDiscounts.Left;
    mTop := gbDiscounts.Top + gbDiscounts.Height;
    gbDiscounts.Height := gbDiscounts.Height + 22;
    chkFrozenDiscounts := NxFindChildControl(AForm, 'chkFrozenDiscounts');
    if Assigned(chkFrozenDiscounts) then
      chkFrozenDiscounts.Top := chkFrozenDiscounts.Top + 22;
    mComponent := TCheckBox.Create(AForm);
    mComponent.Parent := TWinControl(NxFindChildControl(AForm, 'pnHeader')); // main panel
    mComponent.Name := 'chkIndividualDiscounts';
    SetPropValue(mComponent, 'Alignment', taLeftJustify);
    //mComponent.Alignment := 0;
    mComponent.Left := mLeft + 7;//352;
    mComponent.Top := mTop - 4;//349;
    mComponent.Width := 201;//126;
    mComponent.Height := 17;
    mComponent.Caption := 'Slevy dle menu';
    mComponent.TabOrder := 27;
    mComponent.OnClick := @chkDiscountsOnClick;
  end;
  NxSetReadOnly([mComponent], True);
  SetLocalSiteObject(mComponent, 'chkIndividualDiscounts', AForm);
  ShowDebugMessage('AddCheckBox: SetLocalSiteObject');

  //ShowDebugMessage('hledam datasource');

  TDynSiteForm(AForm).ActiveDataSet.AfterScroll := @DatasetAfterScroll;
  TDynSiteForm(AForm).ActiveDataSet.BeforePost := @DatasetBeforePost;
  TDynSiteForm(AForm).ActiveDataSet.AfterCancel := @DatasetAfterCancel;
end;

procedure DatasetAfterScroll(DataSet: TDataSet);
var
  mDataSet: TNxCustomObjectDataSet;
  mObject: TNxCustomBusinessObject;
  mCheckBox: TControl;
begin
  try
    //ShowDebugMessage('DatasetAfterScroll');
    mDataSet := TNxCustomObjectDataSet(DataSet);
    mObject := mDataSet.CurrentObject;
    mCheckBox := GetLocalSiteObject('chkIndividualDiscounts', nil);
    if not VarIsNull(mCheckBox) then begin
      //ShowDebugMessage('chk nalezen na situ => nastavuje se hodnota');
      TCheckBox(mCheckBox).Checked := mObject.GetFieldValueAsBoolean('X_DONT_USE_MENUDISCOUNT');
    end;
  except
    ShowDebugMessage('Skript: Skryta chyba v DT Scroll eventu');
  end;
end;

procedure DatasetBeforePost(DataSet: TDataSet);
var
  mDataSet: TNxCustomObjectDataSet;
  mObject: TNxCustomBusinessObject;
  mValue: string;
  mCheckBox: TControl;
begin
  try
    //ShowDebugMessage('DatasetBeforePost');
    mDataSet := TNxCustomObjectDataSet(DataSet);
    mObject := mDataSet.CurrentObject;
    mCheckBox := GetLocalSiteObject('chkIndividualDiscounts', nil);
    if not VarIsNull(mCheckBox) then
      mObject.SetFieldValueAsBoolean('X_DONT_USE_MENUDISCOUNT', TCheckBox(mCheckBox).Checked);
  except
    ShowDebugMessage('Skript: Skryta chyba v DT BeforePost eventu');
  end;
end;

procedure DatasetAfterCancel(DataSet: TDataSet);
var
  mDataSet: TNxCustomObjectDataSet;
  mObject: TNxCustomBusinessObject;
  mCheckBox: TControl;
begin
  try
    //ShowDebugMessage('DatasetAfterCancel');
    mDataSet := TNxCustomObjectDataSet(DataSet);
    mObject := mDataSet.CurrentObject;
    mCheckBox := GetLocalSiteObject('chkIndividualDiscounts', nil);
    if not VarIsNull(mCheckBox) then
      TCheckBox(mCheckBox).Checked := mObject.GetFieldValueAsBoolean('X_DONT_USE_MENUDISCOUNT');
  except
    ShowDebugMessage('Skript: Skryta chyba v DT AfterCancel eventu');
  end;
end;

procedure chkDiscountsOnClick(Sender: TObject);
var
  mCheckBox: TCheckBox;
  mDynSite: TDynSiteForm;
  mDataSet: TNxCustomObjectDataSet;
  mObject: TNxCustomBusinessObject;
  //mOldValue: Boolean;
  i: integer;
  mCollection: TNxCustomBusinessMonikerCollection;
  mRow: TNxCustomBusinessObject;
begin
  try
    ShowDebugMessage('chkDiscountsOnClick');
    mCheckBox := TCheckBox(Sender);
    mDynSite := TDynSiteForm(NxFindSiteForm(mCheckBox));
    mDataSet := TNxCustomObjectDataSet(mDynSite.ActiveDataSet);
    mObject := mDataSet.CurrentObject;
    //mOldValue := mObject.GetFieldValueAsBoolean('X_DONT_USE_MENUDISCOUNT');
    mObject.SetFieldValueAsBoolean('X_DONT_USE_MENUDISCOUNT', mCheckBox.Checked);
    //provedu nasilnou upravu slev okamzite
    //if mOldValue and (not mCheckBox.Checked) then begin
      ShowDebugMessage('Zrusil jsem pouzivani slev - prepcitavam vse, snad se to vynuluje');
      // rows
      mCollection := mObject.GetLoadedCollectionMonikerForFieldCode(mObject.GetFieldCode('Rows'));
      for i := 0 to mCollection.Count - 1 do begin
        mRow := mCollection.BusinessObject(i);
        ComputeIndividualDiscounts(mRow, True, False);
      end;
      // nasilny refresh
      ShowDebugMessage('Nasilny vizualni refresh udaju');
    //end;
  except
    ShowDebugMessage('chkDiscountsOnClick - doslo k chybe - pozrano');
  end;
end;

procedure UpdateCheckBox(AValue: Boolean);
var
  mCheckBox: TControl;
begin
  try
    ShowDebugMessage('UpdateCheckBox');
    mCheckBox := GetLocalSiteObject('chkIndividualDiscounts', nil);
    if not VarIsNull(mCheckBox) then
      TCheckBox(mCheckBox).Checked := AValue
    else
      ShowDebugMessage('UpdateCheckBox - siteobject nenalezen');
  except
    ShowDebugMessage('UpdateCheckBox - doslo k chybe - pozrano');
  end;
end;

// ----------------------------------------------------------------------------
// v editaci - metody pro vytvoreni a obhospodarovani tlacitka na prepocet slev na agende
procedure AddEditButton(AForm: TSiteForm; ACLSID: string);
var
  mAction: TNxAction;
begin
  fCLSID := ACLSID;
  mAction := AForm.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Přepočet ind.slevy';
  mAction.Hint := 'Přepočítá individuální slevy dle skladového menu na všech řádcích dokladu';
  mAction.Category := 'tabDetail';
  mAction.OnExecute := @EditIndDiscountsOnExecute;
  mAction.OnUpdate := @EditIndDiscountsOnUpdate;
end;

procedure EditIndDiscountsOnExecute(Sender: TObject; ACLSID: string);
var
  mSite: TDynSiteForm;
  mDataSet: TNxCustomObjectDataSet;
  mObject: TNxCustomBusinessObject;
  i: integer;
  mCollection: TNxCustomBusinessMonikerCollection;
  mRow: TNxCustomBusinessObject;
begin
  mSite := TDynSiteForm(NxFindSiteForm(TComponent(Sender)));
  mDataSet := TNxCustomObjectDataSet(mSite.ActiveDataSet);
  mObject := mDataSet.CurrentObject;
  mCollection := mObject.GetLoadedCollectionMonikerForFieldCode(mObject.GetFieldCode('Rows'));
  for i := 0 to mCollection.Count - 1 do begin
    mRow := mCollection.BusinessObject(i);
    mRow.Invalidate;
    mRow.SetFieldValueAsBoolean('X_DISCOUNTEVALUED', False);
    ComputeIndividualDiscounts(mRow, True, True);
  end;
  try
    mDataSet.UpdateFields();
  except
    // pozrani pripadne chyby pri update fields...
  end;
  NxShowMessage('ULMER - Individuální slevy (dle menu)', 'Bylo provedeno přepočítání pouze individuálních slev dle menu na editovaném dokladu.', mdInformation, false, nil);
end;

procedure EditIndDiscountsOnUpdate(Sender: TObject);
var
  mSite: TSiteForm;
begin
  // Zjistime, zda je Sender typu TComponent
  if Sender is TComponent then begin
    // Vyhledame SiteForm (TSiteForm) na kterem je dana akce
    mSite := NxFindSiteForm(TComponent(Sender));
    if Assigned(mSite) then begin
      // Pokud je SiteForm typu agenda, pretypujeme promennou
      if mSite is TDynSiteForm then begin
        // akce je k dispozici pouze v pripade, ze je v datasetu nejaky zaznam
        // a v pripade, ze JE zahajena editace
        TNxAction(Sender).Enabled := TDynSiteForm(mSite).Edit;
        //TNxAction(Sender).Enabled := {Not TDynSiteForm(mSite).ActiveDataset.EOF
        //  and }(TDynSiteForm(mSite).ActiveDataset.State in [dsEdit, dsInsert]);
        //  //and (TDynSiteForm(mSite).Edit or TDynSiteForm(mSite).New);
      end;
    end;
  end;
end;

procedure FreeAllObjects(ASite: TSiteForm);
begin
  ShowDebugMessage('FreeAllObjects');
  try
    UnMemberSiteForm(ASite);
  except
    ShowDebugMessage('FreeAllObjects - doslo k chybe - pozrano');
  end;
end;

begin
end.