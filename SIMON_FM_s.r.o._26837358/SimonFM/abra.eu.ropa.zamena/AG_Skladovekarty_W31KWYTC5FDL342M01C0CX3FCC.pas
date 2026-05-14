uses 'abra.eu.ropa.zamena.lib';


Var
  gModalResult : integer;

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TAction;
  mUser : TNxCustomBusinessObject;
begin
  if not Assigned(Self.BaseObjectSpace) then
    exit;
  mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');
  mUser.Load(Self.CompanyCache.GetUserID, nil);
  //if (mUser.GetFieldCode('U_StoreChanges')>0) and mUser.GetFieldValueAsBoolean('U_StoreChanges') then begin
    mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := 'Záměna';
    mAction.Hint := 'Provede převod mezi skladovými kartami.';
    mAction.Category := 'tabList';
    mAction.OnExecute := @ImportOnExecute;
    //mAction.OnUpdate := @ImportOnUpdate;
  //end;
end;


procedure ImportOnUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := True;
end;


function iSelectStoreCard(AOLE: Variant) : TNxOID;
var
  mRoll : variant;
  mXX : string;
begin
  Result := '';
  mXX := '0000000000';
  mRoll := AOLE.GetRoll('S3WZQKDB5FDL342M01C0CX3FCC', 0);
  Result := mRoll.SelectDialog2(False, mXX);
end;


procedure ImportOnExecute(Sender: TObject);
var
  mSite: TSiteForm;
  mSrcSC, mDstSC : TNxCustomBusinessObject;
  mOID, mStore_Code, mDivision_Code : string;
  mSrcQuantity, mDstQuantity : Double;
  mSrcUnit, mDstUnit : string;
  mDate : TDateTime;
begin
  if Sender is TComponent then begin
    mSite := TComponent(Sender).BusRollSite;
    if Assigned(mSite) and (mSite is TBusRollSiteForm) then begin
      mSrcSC := TBusRollSiteForm(mSite).CurrentObject;
      if NxMessageBox('Dotaz',Format('Přejete si provést záměnu zboží %s za jinou?', [mSrcSC.GetFieldValueAsString('Code')]) , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
         mOID := iSelectStoreCard(mSite.GetAbraOLEApplication);
         if NxIsEmptyOID(mOID) then
           exit;
           
         if mOID = mSrcSC.OID then begin
           NxShowMessage('info','Záměna není možná, zdrojová a cílová karta jsou shodné.', mdWarning,false,msite);
           exit;
         end;
         mDstSC := mSrcSC.ObjectSpace.CreateObject('C3V5QDVZ5BDL342M01C0CX3FCC'); // StoreCard
         try
           if not mDstSC.Test(mOID) then begin
             NxShowMessage('info','Nebyla nalezena cílová skladová karta.', mdWarning,false,msite);
             exit;
           end;
           mDstSC.Load(mOID, nil);
           if not iShowQuantityDlg(mSrcSC, mSrcQuantity, mSrcUnit, mDstSC, mDstQuantity, mDstUnit, mStore_Code, mDivision_Code, mDate, mSite) then
             exit;

           if NxMessageBox('Dotaz',Format('Přejete si zaměnit %8.3f%s x %s za %8.3f%s x %s?', [mSrcQuantity, mSrcUnit, mSrcSC.GetFieldValueAsString('Code'), mDstQuantity, mDstUnit, mDstSC.GetFieldValueAsString('Code')]), mdConfirm, mdbYesNo, 0, 0, False, msite) = mrYes then begin
             DoProduction(mSrcSC, mSrcQuantity, mSrcUnit, mDstSC, mDstQuantity, mDstUnit,
                          iGetIDByCode(mSrcSC.ObjectSpace, 'Stores', mStore_Code), iGetIDByCode(mSrcSC.ObjectSpace, 'Divisions', mDivision_Code), mDate,mSite);
           end;
         finally
           mDstSC.Free;
         end;
      end;
     TBusRollSiteForm(mSite).RefreshData;
    end;

  end;
end;


function GetPeriod_ID(AOS : TNxCustomObjectSpace; ADate : TDateTime) : string;
var
  mPS : TNxParameters;
  mS : string;
begin
  Result := '';
  mPS := TNxParameters.Create;
  try
    mPS.NewFromDataType(dtInteger, 'TestDate').AsInteger := round(ADate);
    AOS.GetBusinessClass('C2QPAYUOXVCL3ACL03KIU0CLP4').GetStringFromClassAction(6, mPS, mS);
    Result := mS;
  finally
    mPS.Free;
  end;
end;


procedure DoProduction(ASrc : TNxCustomBusinessObject; ASrcQuantity : double; ASrcUnit : string;
                       ADst : TNxCustomBusinessObject; ADstQuantity : double; ADstUnit : string;
                       const AStore_ID : TNxOID; const ADivision_ID : TNxOID; ADocDate : TDateTime; ASite:TSiteForm);

  function iGetDocQueue_ID(AOS : TNxCustomObjectSpace; ACode : string; AType : string) : TNxOID;
  const
    cSQL = 'SELECT ID FROM DocQueues WHERE (Code = ''%s'') and (Hidden = ''N'') and (DocumentType = ''%s'')';
  Var
    mR : TStrings;
  begin
    Result := '';
    mR := TStringlist.Create;
    try
      AOS.SQLSelect(Format(cSQL, [ACode, AType]), mR);
      if mR.Count > 0 then
        Result := mR.strings[0];
    finally
      mR.Free;
    end;
  end;
                       
var
  mPT, mPT2 : TNxCustomBusinessObject;
  mVMV, mPHV : TNxCustomBusinessObject;
  mVMV_UnitRate, mPHV_UnitRate : double;
  mVMV_Row, mPHV_Row : TNxCustomBusinessObject;
  mContext : TNxContext;
  mOS : TNxCustomObjectSpace;
  mOID : TNxOID;
begin
  mContext := NxCreateContext_1(ASrc);
  mOS := mContext.GetObjectSpace;
  mPT := mOS.CreateObject('BJTSLF2T32F4HA2RDDJX0QAZLC'); // ProductionTask
  try
    iCheckUnit(ADst, ADstUnit, mPHV_UnitRate);
    iCheckUnit(ASrc, ASrcUnit, mVMV_UnitRate);
    mPT.New;
    mPT.SetFieldValueAsString('Store_ID', AStore_ID);
    mPT.SetFieldValueAsString('StoreCard_ID', ADst.OID);
    mPT.SetFieldValueAsFloat('Quantity', ASrcQuantity*mPHV_UnitRate);
    mPT.Save;
    mPT.Load(mPT.OID, nil);
    mPT2 := mPT.GetCollectionMonikerForFieldCode(mPT.GetFieldCode('Rows')).AddNewObject;
    mPT2.SetFieldValueAsString('Material_ID', ASrc.OID);
    mPT2.SetFieldValueAsString('Product_ID', ADst.OID);
    mVMV := mOS.CreateObject('2MV0SHPYLFJOL3D4WN02HCPX5S'); // MaterialDistribution
    try
      mVMV.New;
      mVMV.Prefill;
      if NxIsEmptyOID(mVMV.GetFieldValueAsString('DocQueue_ID')) then
        mVMV.SetFieldValueAsString('DocQueue_ID', iGetDocQueue_ID(mOS, 'VMVZ', '27'));
      mVMV.SetFieldValueAsDateTime('DocDate$Date', ADocDate);
      mVMV.SetFieldValueAsString('Firm_id','A610000101');
      mVMV.SetFieldValueAsString('Period_ID', GetPeriod_ID(mOS, ADocDate));
      mVMV_Row := mVMV.GetCollectionMonikerForFieldCode(mVMV.GetFieldCode('Rows')).AddNewObject;
      mVMV_Row.SetFieldValueAsInteger('RowType', 3);
      mVMV_Row.SetFieldValueAsString('Store_ID', AStore_ID);
      mVMV_Row.SetFieldValueAsString('Division_ID', ADivision_ID);
      mVMV_Row.SetFieldValueAsString('BusTransaction_ID', '1000000101');
      mVMV_Row.SetFieldValueAsString('StoreCard_ID', ASrc.OID);
      mVMV_Row.SetFieldValueAsFloat('Quantity', ASrcQuantity*mVMV_UnitRate);
      mPT2.SetFieldValueAsFloat('MaterialQuantity', ASrcQuantity*mVMV_UnitRate);
      mVMV_Row.SetFieldValueAsString('QUnit', ASrcUnit);
      mVMV_Row.SetFieldValueAsFloat('UnitRate', mVMV_UnitRate);
      mVMV_Row.GetMonikerForFieldCode(mVMV_Row.GetFieldCode('ProductionTask_ID')).BindToObject(mPT);
//mon      mVMV_Row.SetFieldValueAsString('ProductionTask_ID', mPT.OID);
      
      mPHV := mOS.CreateObject('C3DLAMUSDJNOLDWCDBSBM2GAI0'); // ProductReception
      try
        mPHV.New;
        mPHV.Prefill;
        if NxIsEmptyOID(mPHV.GetFieldValueAsString('DocQueue_ID')) then
          mPHV.SetFieldValueAsString('DocQueue_ID', iGetDocQueue_ID(mOS, 'PHVZ', '28'));
        mPHV.SetFieldValueAsDateTime('DocDate$Date', ADocDate);
        mPHV.SetFieldValueAsString('Firm_id','A610000101');
        mPHV.SetFieldValueAsString('Period_ID', GetPeriod_ID(mOS, ADocDate));
        mPHV_Row := mPHV.GetCollectionMonikerForFieldCode(mPHV.GetFieldCode('Rows')).AddNewObject;
        mPHV_Row.SetFieldValueAsInteger('RowType', 3);
        mPHV_Row.SetFieldValueAsString('BusTransaction_ID', '1000000101');
        mPHV_Row.SetFieldValueAsString('Store_ID', AStore_ID);
        iGetOrCreateStoreSubCard_ID(ADst, AStore_ID); // overim si zda existuje dilci skladova karta, pokud ne tak se zalozi
        mPHV_Row.SetFieldValueAsString('Division_ID', ADivision_ID);
        mPHV_Row.SetFieldValueAsString('StoreCard_ID', ADst.OID);
        mPHV_Row.SetFieldValueAsFloat('Quantity', ADstQuantity*mPHV_UnitRate);
        mPHV_Row.SetFieldValueAsBoolean('CompletePrices',true);
        mPHV_Row.SetFieldValueAsString('QUnit', ADstUnit);
        mPHV_Row.GetMonikerForFieldCode(mPHV_Row.GetFieldCode('ProductionTask_ID')).BindToObject(mPT);
//mon        mPHV_Row.SetFieldValueAsString('ProductionTask_ID', mPT.OID);

       mPT2.GetMonikerForFieldCode(mPT2.GetFieldCode('MaterialRow_ID')).BindToObject(mVMV_Row);
       mPT2.GetMonikerForFieldCode(mPT2.GetFieldCode('ProductRow_ID')).BindToObject(mPHV_Row);

//mPT2.SetFieldValueAsString('MaterialRow_ID', mVMV_Row.OID);
//mPT2.SetFieldValueAsString('ProductRow_ID', mPHV_Row.OID);


        mOS.StartTransaction(taReadCommited);
        try
          mPT.ExplicitTransaction := True;
          mVMV.ExplicitTransaction := True;
          mPHV.ExplicitTransaction := True;
          mVMV.Save;
          mPHV.Save;
          mPT.Save;
          mOS.Commit;
          NxShowMessage('Info','Záměna dokončena.',mdInformation,false,ASite);
        except
          mOS.RollBack;
          ShowMessage(ExceptionMessage);
        end;
      finally
        mPHV.Free;
      end;
    finally
      mVMV.Free;
    end;
  finally
    mPT.Free;
  end;
end;



function iShowQuantityDlg(ASrcSC : TNxCustomBusinessObject; var ASrcQuantity : double; var ASrcUnit : string;
                          ADstSC : TNxCustomBusinessObject; var ADstQuantity : double; var ADstUnit : string;
                          var AStore_Code : string; var ADivision_Code : string; var ADate : TDateTime; aSite:TSiteForm) : boolean;
  procedure iFillUnits(ASC : TNxCustomBusinessObject; AList : TStrings);
  var
    i : integer;
    mColl : TNxCustomBusinessMonikerCollection;
  begin
    mColl := ASC.GetLoadedCollectionMonikerForFieldCode(ASC.GetFieldCode('StoreUnits'));
    for i := 0 to mColl.Count - 1 do
      Alist.Add(mColl.BusinessObject[i].GetFieldValueAsString('Code'));
  end;
  
  procedure iFillStores(AOS : TNxCustomObjectSpace; AList : Tstrings);
  const
    cSQL = 'SELECT Code FROM Stores WHERE Hidden=''N'' ORDER BY Code';
  begin
    AOS.SQLSelect(cSQL, AList);
  end;
  
  procedure iFillDivisions(AOS : TNxCustomObjectSpace; AList : TStrings);
  const
    cSQL = 'SELECT Code FROM Divisions WHERE Hidden=''N'' ORDER BY Code';
  begin
    AOS.SQLSelect(cSQL, AList);
  end;


var
  mForm : TForm;
  mBtn : TButton;
  mLbl : TLabel;
  mEdtSrc, mEdtDst : TNumEdit;
  mEdtDate : TDateEdit;
  cbSrcUnits, cbDstUnits, cbStores, cbDivisions : TComboBox;
  mP1, mP2, mP3 : TPanel;
begin
  Result := False;
  if ASrcSC.GetFieldValueAsString('Code') = ADstSC.GetFieldValueAsString('Code') then begin
    ShowMessage('Zdrojová a cílová karta jsou stejné, záměna ukončena');
    exit;
  end;
  mForm := TForm.Create(aSite);
  try
    mForm.Width := 320;  // sirka
    mForm.Height := 290; // vyska - dopočítívá se na závěr
    mForm.Caption := Format('Počet %s ', [ASrcSC.GetFieldValueAsString('Code')]);
    
    begin
      mP1 := TPanel.Create(mForm);
      mP1.Name := 'pnSrc';
      mP1.Caption := '';
      mP1.Height := 90;
      mForm.InsertControl(mP1);
      mP1.Align := alTop;

      mLbl := TLabel.Create(mP1);
      mLbl.Caption := Format('Zdrojová karta:  %s (%s)', [ASrcSC.GetFieldValueAsString('Code'), ASrcSC.GetFieldValueAsString('Name')])  ;
      mLbl.Left := 8;
      mLbl.Top := 10;
      mLbl.Name := 'lblSrc';
      mP1.InsertControl(mLbl);

      mLbl := TLabel.Create(mP1);
      mLbl.Caption := 'Počet:'  ;
      mLbl.Left := 20;
      mLbl.Top := 39;
      mLbl.Name := 'lblSrcQuantity';
      mP1.InsertControl(mLbl);

      mEdtSrc := TNumEdit.Create(mP1);
      mP1.InsertControl(mEdtSrc);
      mEdtSrc.Left := 100;
      mEdtSrc.Top := 35;
      mEdtSrc.Width := 90;
      mEdtSrc.DecimalPlaces := 3;
      mEdtSrc.Name := 'edtSrcQuantity';

      mLbl := TLabel.Create(mP1);
      mLbl.Caption := 'Jednotka:';
      mLbl.Left := 20;
      mLbl.Top := 61;
      mLbl.Name := 'lblSrcQUnit';
      mP1.InsertControl(mLbl);

      cbSrcUnits := TComboBox.Create(mP1);
      cbSrcUnits.Left := 100;
      cbSrcUnits.Top := 57;
      cbSrcUnits.Width := 50;
      cbSrcUnits.Name := 'cbUnits';
      cbSrcUnits.Text := '';
      mP1.InsertControl(cbSrcUnits);
      iFillUnits(ASrcSC, cbSrcUnits.Items);
      if cbSrcUnits.Items.Count >= 0 then
        cbSrcUnits.ItemIndex := 0;
    end;

    begin
      mP2 := TPanel.Create(mForm);
      mP2.Name := 'pnDst';
      mP2.Caption := '';
      mP2.Height := 90;
      mP2.Top := mP1.Height;
      mForm.InsertControl(mP2);
      mP2.Align := alTop;

      mLbl := TLabel.Create(mP2);
      mLbl.Caption := Format('Cílová karta:  %s (%s)', [ADstSC.GetFieldValueAsString('Code'), ADstSC.GetFieldValueAsString('Name')])  ;
      mLbl.Left := 8;
      mLbl.Top := 10;
      mLbl.Name := 'lblDst';
      mP2.InsertControl(mLbl);

      mLbl := TLabel.Create(mP2);
      mLbl.Caption := 'Počet:'  ;
      mLbl.Left := 20;
      mLbl.Top := 39;
      mLbl.Name := 'lblDstQuantity';
      mP2.InsertControl(mLbl);

      mEdtDst := TNumEdit.Create(mP2);
      mP2.InsertControl(mEdtDst);
      mEdtDst.Left := 100;
      mEdtDst.Top := 35;
      mEdtDst.Width := 90;
//      mEdtDst.Text := '0,00';
      mEdtDst.DecimalPlaces := 3;
      mEdtDst.Name := 'edtDstQuantity';

      mLbl := TLabel.Create(mP2);
      mLbl.Caption := 'Jednotka:';
      mLbl.Left := 20;
      mLbl.Top := 61;
      mLbl.Name := 'lblDstQUnit';
      mP2.InsertControl(mLbl);

      cbDstUnits := TComboBox.Create(mP2);
      cbDstUnits.Left := 100;
      cbDstUnits.Top := 57;
      cbDstUnits.Width := 50;
      cbDstUnits.Name := 'cbDstUnits';
      cbDstUnits.Text := '';
      mP2.InsertControl(cbDstUnits);
      iFillUnits(ADstSC, cbDstUnits.Items);
      if cbDstUnits.Items.Count >= 0 then
        cbDstUnits.ItemIndex := 0;
    end;

    begin
      mP3 := TPanel.Create(mForm);
      mP3.Name := 'pnRolls';
      mP3.Caption := '';
      mP3.Height := 100;
      mP3.Top := mP1.Height + mP2.Height;
      mForm.InsertControl(mP3);
      mP3.Align := alTop;

      mLbl := TLabel.Create(mP3);
      mLbl.Caption := 'Sklad:'  ;
      mLbl.Left := 20;
      mLbl.Top := 12;
      mLbl.Name := 'lblStores';
      mP3.InsertControl(mLbl);

      cbStores := TComboBox.Create(mP3);
      cbStores.Left := 100;
      cbStores.Top := 10;
      cbStores.Width := 50;
      cbStores.Name := 'cbStore';
      cbStores.Text := '';
      mP3.InsertControl(cbStores);
      iFillStores(ASrcSC.ObjectSpace, cbStores.Items);
      if cbStores.Items.Count >= 0 then
        cbStores.ItemIndex := 0;
        
      mLbl := TLabel.Create(mP3);
      mLbl.Caption := 'Středisko:'  ;
      mLbl.Left := 20;
      mLbl.Top := 32;
      mLbl.Name := 'lblDivisions';
      mP3.InsertControl(mLbl);

      cbDivisions := TComboBox.Create(mP3);
      cbDivisions.Left := 100;
      cbDivisions.Top := 34;
      cbDivisions.Width := 50;
      cbDivisions.Name := 'cbDivision';
      cbDivisions.Text := '';
      mP3.InsertControl(cbDivisions);
      iFillDivisions(ASrcSC.ObjectSpace, cbDivisions.Items);
      if cbDivisions.Items.Count >= 0 then
        cbDivisions.ItemIndex := 0;

      mLbl := TLabel.Create(mP3);
      mLbl.Caption := 'Datum:'  ;
      mLbl.Left := 20;
      mLbl.Top := 54;
      mLbl.Name := 'lblDate';
      mP3.InsertControl(mLbl);
      
      mEdtDate := TDateEdit.Create(mP3);
      mP3.InsertControl(mEdtDate);
      mEdtDate.Left := 100;
      mEdtDate.Top := 56;
      mEdtDate.Width := 90;
      mEdtDate.Name := 'edDate';
      mEdtDate.Date := Date;
    end;

    mForm.Height := mP1.Height + mP2.Height + mP3.Height + 85;

    mBtn := TButton.Create(mForm);
    mBtn.Width := 75;
    mBtn.Height := 25;
    mBtn.Caption := 'Záměna';
    mBtn.Left := Round((mForm.Width - mBtn.Width)/2);
    mBtn.Top := mForm.Height - mBtn.Height - 45;
    mBtn.Visible := True;
    mBtn.OnClick := @FormQuantityOnExecute;
    mBtn.Name := 'btnDoProduction';
    mForm.InsertControl(mBtn);

    gModalResult := 0;
    mForm.ShowModal(aSite);
    Result := gModalResult = 1;
    if Result then begin
      if not NxIsValidFloat(mEdtSrc.Text, ASrcQuantity) then begin
        ShowMessage(Format('Zadaná hodnota %s není platné číslo.', [mEdtSrc.Text]));
        exit;
      end;
      if (cbSrcUnits.ItemIndex < 0) or ((cbSrcUnits.ItemIndex>=0) and NxIsBlank(cbSrcUnits.Items.Strings[cbSrcUnits.ItemIndex])) then begin
        ShowMessage('Není zvolená zdrojová jednotka!');
        exit;
      end;
      ASrcUnit := cbSrcUnits.Items.Strings[cbSrcUnits.ItemIndex];

      if not NxIsValidFloat(mEdtDst.Text, ADstQuantity) then begin
        ShowMessage(Format('Zadaná hodnota %s není platné číslo.', [mEdtDst.Text]));
        exit;
      end;
      if (cbDstUnits.ItemIndex < 0) or ((cbDstUnits.ItemIndex>=0) and NxIsBlank(cbDstUnits.Items.Strings[cbDstUnits.ItemIndex])) then begin
        ShowMessage('Není zvolená zdrojová jednotka!');
        exit;
      end;
      ADstUnit := cbDstUnits.Items.Strings[cbDstUnits.ItemIndex];
      
      AStore_Code := cbStores.Items.Strings[cbStores.ItemIndex];
      ADivision_Code := cbDivisions.Items.Strings[cbDivisions.ItemIndex];
      ADate := mEdtDate.Date;
    end;
  finally
    mForm.Free;
  end;
  if ASrcQuantity <= 0 then begin
    ShowMessage('Zdrojové množství musí být větší než 0.');
    Result := False;
  end;
  if ADstQuantity <= 0 then begin
    ShowMessage('Cílové množství musí být větší než 0.');
    Result := False;
  end;
end;


function iGetIDByCode(AOS : TNxCustomObjectSpace; const ATableName : string; ACode : string) : TNxOID;
const
  cSQL = 'SELECT ID FROM %s WHERE Code=''%s'' AND Hidden=''N''';
var
  mR : TStrings;
begin
  Result := '';
  mR := TStringlist.Create;
  try
    AOS.SQLSelect(Format(cSQL, [ATableName, ACode]), mR);
    if mR.Count > 0 then
      Result := mR.strings[0];
  finally
    mR.Free;
  end;
end;


procedure FormQuantityOnExecute(Sender: TButton);
begin
  gModalResult := 1;
  TForm(TControl(Sender).Owner).ModalResult := mrOK;
  TForm(TControl(Sender).Owner).Close;
end;

begin
end.