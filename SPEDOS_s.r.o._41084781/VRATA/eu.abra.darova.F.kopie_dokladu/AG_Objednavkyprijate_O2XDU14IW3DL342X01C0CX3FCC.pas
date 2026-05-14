function NewDL(ABO: TNxCustomBusinessObject): string;
var
  mDL: TNxCustomBusinessObject;
  i, mPosIndex: integer;
  mMon: TNxCustomBusinessMonikerCollection;
  mRow, mNewRow: TNxCustomBusinessObject;
  mList: TStringList;
  mText: string;
begin
  result := '';
  mDL := ABO.ObjectSpace.CreateObject('E03ZNUMDTCC4PDAUIEY1MBTJC0');
  try
    mDL.New;
    mDL.Prefill;
    mDL.SetFieldValueAsString('Firm_ID', ABO.GetFieldValueAsString('Firm_ID'));
    mDL.SetFieldValueAsString('Description', ABO.GetFieldValueAsString('Description'));
    // DocQueue_ID se prebirat neda a v demodatech se ani se automaticky neprednastavi
    // (protoze obsahuji vice rad pro dodaci listy)
    // => pouzijeme OID rady DL z demodat - pro pouziti v jinych datech je treba
    // toto OID v kodu skriptu nahradit existujicim
    mDL.SetFieldValueAsString('DocQueue_ID', 'U100000101');
    // ted projdeme radky - nejlepe v poradi radek prijemky
    mMon := ABO.GetLoadedCollectionMonikerForFieldCode(ABO.GetFieldCode('ROWS'));
    mList := TStringList.Create;
    try
      for i := 0 to mMon.Count-1 do begin
        mRow := mMon.BusinessObject[i];
        mPosIndex := mRow.GetFieldValueAsInteger('PosIndex');
        mList.AddObject(NxPadL(IntToStr(mPosIndex), 6, '0'), mRow);
      end;
      mList.Sort;
      mMon := mDL.GetLoadedCollectionMonikerForFieldCode(mDL.GetFieldCode('ROWS'));
      for i := 0 to mList.Count-1 do begin
        mRow := TNxCustomBusinessObject(mList.Objects[i]);
        if mRow.GetFieldValueAsInteger('RowType')=3 then begin
                  mNewRow := mMon.AddNewObject;
                  mNewRow.SetFieldValueAsInteger('RowType',3 );
                  mNewRow.SetFieldValueAsString('Store_ID', mRow.GetFieldValueAsString('Store_ID'));
                  mNewRow.SetFieldValueAsString('StoreCard_ID', mRow.GetFieldValueAsString('StoreCard_ID'));
                  mNewRow.SetFieldValueAsString('QUnit', mRow.GetFieldValueAsString('QUnit'));
                  mNewRow.SetFieldValueAsFLoat('UnitRate', mRow.GetFieldValueAsFloat('UnitRate'));
                  mNewRow.SetFieldValueAsFLoat('Quantity', mRow.GetFieldValueAsFloat('Quantity'));
                  //mNewRow.SetFieldValueAsString('Text', mRow.GetFieldValueAsString('Text'));
                  mNewRow.SetFieldValueAsString('Division_ID', 'D000000101');         // 702
                  mNewRow.SetFieldValueAsString('BusOrder_ID', mRow.GetFieldValueAsString('BusOrder_ID'));
                  mNewRow.SetFieldValueAsString('BusTransaction_ID', mRow.GetFieldValueAsString('BusTransaction_ID'));
        end;
      end;
    finally
      mList.Free;
    end;
    TDynSiteForm.ShowDynFormWithNewDocument('B10I5SAOS3DL3ACU03KIU0CLP4',NxCreateContext(mDL.ObjectSpace), mDL);
  finally
    mDL.Free;
  end;
end;

function NewPHV(ABO: TNxCustomBusinessObject): string;
var
  mDL: TNxCustomBusinessObject;
  i, mPosIndex: integer;
  mMon: TNxCustomBusinessMonikerCollection;
  mRow, mNewRow: TNxCustomBusinessObject;
  mList: TStringList;
  mText: string;
begin
  result := '';
  mDL := ABO.ObjectSpace.CreateObject('E03ZNUMDTCC4PDAUIEY1MBTJC0');
  try
    mDL.New;
    mDL.Prefill;
    mDL.SetFieldValueAsString('Firm_ID', ABO.GetFieldValueAsString('Firm_ID'));
    mDL.SetFieldValueAsString('Description', ABO.GetFieldValueAsString('Description'));
    // DocQueue_ID se prebirat neda a v demodatech se ani se automaticky neprednastavi
    // (protoze obsahuji vice rad pro dodaci listy)
    // => pouzijeme OID rady DL z demodat - pro pouziti v jinych datech je treba
    // toto OID v kodu skriptu nahradit existujicim
    mDL.SetFieldValueAsString('DocQueue_ID', 'U100000101');
    // ted projdeme radky - nejlepe v poradi radek prijemky
    mMon := ABO.GetLoadedCollectionMonikerForFieldCode(ABO.GetFieldCode('ROWS'));
    mList := TStringList.Create;
    try
      for i := 0 to mMon.Count-1 do begin
        mRow := mMon.BusinessObject[i];
        mPosIndex := mRow.GetFieldValueAsInteger('PosIndex');
        mList.AddObject(NxPadL(IntToStr(mPosIndex), 6, '0'), mRow);
      end;
      mList.Sort;
      mMon := mDL.GetLoadedCollectionMonikerForFieldCode(mDL.GetFieldCode('ROWS'));
      for i := 0 to mList.Count-1 do begin
        mRow := TNxCustomBusinessObject(mList.Objects[i]);
        if mRow.GetFieldValueAsInteger('RowType')=3 then begin
                  if mRow.getFieldValueAsString('Storecard_ID.code')=mRow.getFieldValueAsString('X_group_macro_id.name') then begin
                          mNewRow := mMon.AddNewObject;
                          mNewRow.SetFieldValueAsInteger('RowType',3 );
                          mNewRow.SetFieldValueAsString('Store_ID', mRow.GetFieldValueAsString('Store_ID'));
                          mNewRow.SetFieldValueAsString('StoreCard_ID', mRow.GetFieldValueAsString('StoreCard_ID'));
                          mNewRow.SetFieldValueAsString('QUnit', mRow.GetFieldValueAsString('QUnit'));
                          mNewRow.SetFieldValueAsFLoat('UnitRate', mRow.GetFieldValueAsFloat('UnitRate'));
                          mNewRow.SetFieldValueAsFLoat('Quantity', mRow.GetFieldValueAsFloat('Quantity'));
                          //mNewRow.SetFieldValueAsString('Text', mRow.GetFieldValueAsString('Text'));
                          mNewRow.SetFieldValueAsString('Division_ID', 'D000000101');         // 702
                          mNewRow.SetFieldValueAsString('BusOrder_ID', mRow.GetFieldValueAsString('BusOrder_ID'));
                  mNewRow.SetFieldValueAsString('BusTransaction_ID', mRow.GetFieldValueAsString('BusTransaction_ID'));
                  end;
        end;
      end;
    finally
      mList.Free;
    end;
    TDynSiteForm.ShowDynFormWithNewDocument('B10I5SAOS3DL3ACU03KIU0CLP4',NxCreateContext(mDL.ObjectSpace), mDL);
  finally
    mDL.Free;
  end;
end;



procedure NewPHVExecute(Sender: TObject);
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
        mID := NewPHV(mObj);
        if not NxIsEmptyOID(mID) then
          mSite.ShowDynForm('B10I5SAOS3DL3ACU03KIU0CLP4', Nil, Nil, False, 'DoEdit;'+mID);
      end;
    finally
      mObj.Free;
    end;
  end;
end;

procedure NewDLExecute(Sender: TObject);
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
        mID := NewDL(mObj);
        if not NxIsEmptyOID(mID) then
          mSite.ShowDynForm('B10I5SAOS3DL3ACU03KIU0CLP4', Nil, Nil, False, 'DoEdit;'+mID);
      end;
    finally
      mObj.Free;
    end;
  end;
end;

procedure NewPHVUpdate(Sender: TObject);
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
  mAction: TAction;
begin
  // Vytorime novou jednoduchou akci
  mAction := Self.GetNewAction;
  mAction.Name := 'actPrijemHV';
  // Nastavime, aby se tato akce zobrazovala jako tlacitko
  mAction.ShowControl := True;
  // Nastavime, aby se tato akce zobrazila v menu
  mAction.ShowMenuItem := True;
  // Nastavime nadpis tlacitka
  mAction.Caption := 'Příjem hotového výrobku';
  // Nastavime hint
  mAction.Hint := 'Vytvoří příjem hotového výrobku podle aktuální OP.';
  // Nastavime, aby se tato akce nabizela na zalozkach Seznam a Detail
  mAction.Category := 'tabDetail, tabList';
  // Nastavime udalost, ktera se vykona pri spusteni teto akce
  mAction.OnExecute := @NewDLExecute;
  // Nastavime udalost, v niz muzeme nastavovat dostupnost teho akce
  mAction.OnUpdate := @NewDLUpdate;



   // Vytorime novou jednoduchou akci
  mAction := Self.GetNewAction;
  mAction.Name := 'actPrijemHVMacro';
  // Nastavime, aby se tato akce zobrazovala jako tlacitko
  mAction.ShowControl := True;
  // Nastavime, aby se tato akce zobrazila v menu
  mAction.ShowMenuItem := True;
  // Nastavime nadpis tlacitka
  mAction.Caption := 'Příjem hotového výrobku macro';
  // Nastavime hint
  mAction.Hint := 'Vytvoří příjem hotového výrobku podle aktuální OP.';
  // Nastavime, aby se tato akce nabizela na zalozkach Seznam a Detail
  mAction.Category := 'tabDetail, tabList';
  // Nastavime udalost, ktera se vykona pri spusteni teto akce
  mAction.OnExecute := @NewPHVExecute;
  // Nastavime udalost, v niz muzeme nastavovat dostupnost teho akce
  mAction.OnUpdate := @NewPHVUpdate;


end;

begin
end.