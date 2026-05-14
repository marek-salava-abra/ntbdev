uses
 'abra.eu.simonasdf.service', 'abra.eu.simonasdf.odvoz', 'abra.eu.simonasdf.vyrizeni', 'abra.eu.simonasdf.reklamace', 'abra.eu.simonasdf.complete';


procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mMAction : TMultiAction;
begin
  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Půjčovna';
  mMAction.Hint := 'Tvorba PPZ nebo DLSE';
  mMAction.Category := 'tabDetail, tabList';
  //mMAction.OnUpdate := @CreateDocumentOnUpdate;
  mMAction.OnExecuteItem := @MultiAkceExecuteItem3;
  mMAction.Items.Add('Tvorba PP');
  mMAction.Items.Add('Tvorba DL');
  mMAction.Items.Add('Tvorba FV');
  
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Nový servis';
  mAction.Hint := 'Založí aktivitu, PRS, a skladovou kartu';
  mAction.Category := 'tabList';
  mAction.OnExecute := @CreateNewService;
  //mAction.OnUpdate := @CreateDocumentOnUpdate;
  
  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Akce s aktivitama';
  mMAction.Hint := 'Vychystání, odvezení a přivezení servisovaných předmětů';
  mMAction.Category := 'tabList';
  //mMAction.OnUpdate := @CreateDocumentOnUpdate;
  mMAction.OnExecuteItem := @MultiAkceExecuteItem;
  mMAction.Items.Add('Vychystání');
  mMAction.Items.Add('Odvezení');
  mMAction.Items.Add('Přivezení');
  
  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Vyřízení servisu';
  mMAction.Hint := 'Tvorba PPZ nebo DLSE';
  mMAction.Category := 'tabList';
  //mMAction.OnUpdate := @CreateDocumentOnUpdate;
  mMAction.OnExecuteItem := @MultiAkceExecuteItem2;
  mMAction.Items.Add('Tvorba PPZ');
  mMAction.Items.Add('Tvorba DLSE');
  mMAction.Items.Add('Tvorba FV02');
  
  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Záloha servis';
  mMAction.Hint := 'Tvorba PPZ nebo DLSE';
  mMAction.Category := 'tabList';
  //mMAction.OnUpdate := @CreateDocumentOnUpdate;
  mMAction.OnExecuteItem := @CreateDeposit;
  mMAction.Items.Add('Tvorba PPZ');
  mMAction.Items.Add('Tvorba FV02');
  
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Reklamace';
  mAction.Hint := 'Založí aktivitu, dohledá skladovou kartu a vytvoří vratku na sklad';
  mAction.Category := 'tabList';
  mAction.OnExecute := @CreateNewReclamation;

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Kompl. ceny';
  mAction.Hint := 'Nastaví na příjemce příznak kompletní cena';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ComplPrice;
  //mAction.OnUpdate := @CreateDocumentOnUpdate;

end;


procedure MultiAkceExecuteItem3(Sender: TObject; Index: integer);
begin
   if Index= 0 then CreateCashOnExecute(Sender);
   if Index=1 then CreateBillOfDeliOnExecute(sender);
   if index=2 then CreateIIOnExecute(sender);

end;


procedure FillRow(AActivityBO : TNxCustomBusinessObject; ARows : TNxCustomBusinessMonikerCollection; ADeviceFieldName : string; AAmountFieldName : string; AIncomeType_ID : string);
var
  mID : string;
  mDevice : TNxCustomBusinessObject;
  mNewRow: TNxCustomBusinessObject;
  mQuantity : double;
begin
//  mQuantity := integer(AActivityBO.GetFieldValueAsDateTime('RealEnd$DATE'));
//  mQuantity :=  NxRoundByValue(AActivityBO.GetFieldValueAsDateTime('RealEnd$DATE'), ctNone, 1 ) - NxRoundByValue(AActivityBO.GetFieldValueAsDateTime('RealStart$DATE'), ctNone, 1 );
  mQuantity := NxFloor(AActivityBO.GetFieldValueAsDateTime('RealEnd$DATE')) - NxFloor(AActivityBO.GetFieldValueAsDateTime('RealStart$DATE')) + 1;
  mQuantity := 1;
  if ADeviceFieldName <> '' then begin
    if not NxIsEmptyOID(AActivityBO.GetFieldValueAsString(ADeviceFieldName)) then begin
      mNewRow := ARows.AddNewObject;
      mNewRow.SetFieldValueAsInteger('RowType', 2);
      mNewRow.SetFieldValueAsFloat('Quantity', mQuantity);
      mNewRow.SetFieldValueAsString('Division_ID', AActivityBO.GetFieldValueAsString('Division_ID'));
      mNewRow.SetFieldValueAsString('VATRate_ID', '02100X0000');
      mNewRow.SetFieldValueAsFloat('UnitPrice', AActivityBO.GetFieldValueAsFloat(AAmountFieldName));
      mID := AActivityBO.GetFieldValueAsString(ADeviceFieldName);
      if not NxIsEmptyOID(mID) then begin
        mDevice := AActivityBO.ObjectSpace.CreateObject('11CZ0SV0RRW4PABA135VLXC3IO');
        mDevice.Load(mID, nil);
        mNewRow.SetFieldValueAsString('Text', AActivityBO.GetFieldValueAsString('Subject') + ' ' + mDevice.GetFieldValueAsString('Name') );
      end else
        mNewRow.SetFieldValueAsString('Text', AActivityBO.GetFieldValueAsString('Subject'));
      if not NxIsEmptyOID(AIncomeType_ID) then
        mNewRow.SetFieldValueAsString('IncomeType_ID', AIncomeType_ID);
      if NxIsEmptyOID(AActivityBO.GetFieldValueAsString('BusTransaction_ID')) then
        mNewRow.SetFieldValueAsString('BusTransaction_ID', '5000000101')
      else
        mNewRow.SetFieldValueAsString('BusTransaction_ID', AActivityBO.GetFieldValueAsString('BusTransaction_ID'));
    end;
  end;
  if (ADeviceFieldName = '') and (AActivityBO.GetFieldValueAsFloat(AAmountFieldName) <> 0) then begin
      mNewRow := ARows.AddNewObject;
      mNewRow.SetFieldValueAsInteger('RowType', 1);
      mNewRow.SetFieldValueAsString('Division_ID', AActivityBO.GetFieldValueAsString('Division_ID'));
      mNewRow.SetFieldValueAsString('VATRate_ID', '02100X0000');
      mNewRow.SetFieldValueAsFloat('TotalPrice', AActivityBO.GetFieldValueAsFloat(AAmountFieldName));
      mNewRow.SetFieldValueAsString('Text', AActivityBO.GetFieldValueAsString('Subject'));
      if not NxIsEmptyOID(AIncomeType_ID) then
        mNewRow.SetFieldValueAsString('IncomeType_ID', AIncomeType_ID);
      if NxIsEmptyOID(AActivityBO.GetFieldValueAsString('BusTransaction_ID')) then
        mNewRow.SetFieldValueAsString('BusTransaction_ID', '5000000101')
      else
        mNewRow.SetFieldValueAsString('BusTransaction_ID', AActivityBO.GetFieldValueAsString('BusTransaction_ID'));
  end;
end;

procedure CreateCashOnExecute(Sender: TObject);
var
  mSite: TSiteForm;
  mObj : TNxCustomBusinessObject;
  mCashReceived, mRelation, mActivityType, mCashReceivedRow: TNxCustomBusinessObject;
  mMon: TNxCustomBusinessMonikerCollection;
  mPars : TNxParameters;
  mFirm_id: String;
  mPar: TNxParameter;
  mSQL:String;
  mRentalDeviceBO:TNxCustomBusinessObject;
  mRetntalList:TStringList;
  i:Integer;
begin
  if not (Sender is TComponent) then
    exit;
   mSite := TComponent(Sender).DynSite;
   mObj := TDynSiteForm(mSite).CurrentObject;
   if not(mobj.GetFieldValueAsString('ActQueue_ID')='2000000101') then begin
     NxShowSimpleMessage('Toto tlačítko slouží pouze pro půjčovnu',mSite);

     exit;
   end;
  if NxMessageBox('Dotaz', 'Přejete si automaticky vytvořit Pokladní příjem?', mdConfirm, mdbYesNo, 0, 0, False, mSite)=mrYes then begin

    if mSite is TDynSiteForm then begin
      //mObj := TDynSiteForm(mSite).CurrentObject;
      mFirm_id:=mObj.GetFieldValueAsString('Firm_ID');
      if mFirm_id='0000000000' then mFirm_id:='AAA1000000';
      mActivityType := mObj.ObjectSpace.CreateObject('SMOEDRFJASV4P4XCFPYBZ1UYYO');
      mActivityType.Load(mObj.GetFieldValueAsString('ActivityType_ID'), nil);

      // Vytvorime novou instanci business objektu Pokladní příjem
      mCashReceived := mObj.ObjectSpace.CreateObject('WG02MSU3BBDL3ACR03KIU0CLP4');
      mCashReceived.New;
      mCashReceived.Prefill;
      mCashReceived.SetFieldValueAsString('DocQueue_ID', mActivityType.GetFieldValueAsString('U_CashReceivedQueue_ID'));
      mCashReceived.SetFieldValueAsString('CashDesk_ID', mActivityType.GetFieldValueAsString('U_CashDesk_ID'));
      mCashReceived.SetFieldValueAsString('Firm_ID', mfirm_id);
      mCashReceived.SetFieldValueAsString('Description', mObj.GetFieldValueAsString('Subject'));
      mCashReceived.SetFieldValueAsBoolean('PricesWithVAT', True);
      mSQL:='Select ID from defrolldata where X_Activity_ID=''%s'' and clsid=''VFNPR04IPRQ41HGAGUTXNGLWYW'' ';
      mRetntalList:=TStringList.create;
      mCashReceived.ObjectSpace.SQLSelect(Format(mSQL,[mObj.OID]),mRetntalList);

      mMon := mCashReceived.GetLoadedCollectionMonikerForFieldCode(mCashReceived.GetFieldCode('ROWS'));
      for i:=0 to mRetntalList.Count-1 do begin
          mCashReceivedRow:=mMon.AddNewObject;
          mRentalDeviceBO:=mCashReceived.ObjectSpace.CreateObject('VFNPR04IPRQ41HGAGUTXNGLWYW');
          mRentalDeviceBO.Load(mRetntalList.Strings[i],nil);
          mCashReceivedRow.SetFieldValueAsInteger('RowType',1);
          mCashReceivedRow.SetFieldValueAsString('Text', 'Půjčení '+mRentalDeviceBO.GetFieldValueAsString('X_RentalDevice_ID.Name'));
          mCashReceivedRow.SetFieldValueAsFloat('TotalPrice',mRentalDeviceBO.GetFieldValueAsFloat('U_RentalAmount'));
          mCashReceivedRow.SetFieldValueAsString('VATRate_ID', '02100X0000');
          mCashReceivedRow.SetFieldValueAsString('BusTransaction_ID', mObj.GetFieldValueAsString('BusTransaction_ID'));
          mCashReceivedRow.SetFieldValueAsString('Division_id', mObj.GetFieldValueAsString('Division_ID'));
          mCashReceivedRow.SetFieldValueAsString('IncomeType_ID', mActivityType.GetFieldValueAsString('U_IncomeType_ID'));



      end;
      //FillRow(mObj, mMon, 'U_RentalDevice_ID', 'U_TotalRentalAmount1', mActivityType.GetFieldValueAsString('U_IncomeType_ID'));
      //FillRow(mObj, mMon, 'U_RentalDevice2_ID', 'U_TotalRentalAmount2', mActivityType.GetFieldValueAsString('U_IncomeType_ID'));
      //FillRow(mObj, mMon, 'U_RentalDevice3_ID', 'U_TotalRentalAmount3', mActivityType.GetFieldValueAsString('U_IncomeType_ID'));
      FillRow(mObj, mMon, '', 'U_ServiceAmount', mActivityType.GetFieldValueAsString('U_IncomeType_ID'));

      mCashReceived.Save;
      
      // vytvořím vazbu mezi Pokladním příjmem a Aktivitou
      mRelation := mObj.ObjectSpace.CreateObject('01ZXNDSYDVD135SA02K2CQM5AW');
      mRelation.New;
      mRelation.SetFieldValueAsString('LEFTSIDE_ID', mObj.OID);
      mRelation.SetFieldValueAsString('RIGHTSIDE_ID', mCashReceived.OID);
      mRelation.SetFieldValueAsInteger('REL_DEF', 1213);
      mRelation.Save;

      mPars := TNxParameters.Create;
      try
        mPars.NewFromDataType(dtString, '_SelectionCaption', pkUnknown).AsString := 'Nový pokladní příjem pro ' + mObj.DisplayName;
        mPar := mPars.NewFromDataType(dtList, '_DefaultSelection', pkUnknown) ; // DoNotLocalize
        mPar := mPar.AsList.NewFromDataType(dtList, 'CONDITIONS', pkUnknown);
        mPar := mPar.AsList.NewFromDataType(dtList, 'ID', pkUnknown) ; // DoNotLocalize
        mPar.AsList.NewFromDataType(dtInteger, 'USEDKIND', pkUnknown).AsInteger := 1;
        mPar := mPar.AsList.NewFromDataType(dtList, 'Values', pkUnknown);
        mPar.AsList.NewFromDataType(dtString, '{:VALUE}', pkUnknown).AsString := '''' + mCashReceived.OID + '''';
        
      if not NxIsEmptyOID(mCashReceived.OID) then
            mSite.ShowDynForm('S5C2EX0BUJD13ACP03KIU0CLP4', mPars, Nil, False, '')
      finally
        mPars.Free;
      end
    end;
  end;
end;

procedure CreateIIOnExecute(Sender: TObject);
var
  mSite: TSiteForm;
  mObj : TNxCustomBusinessObject;
  mCashReceived, mRelation, mActivityType, mCashReceivedRow: TNxCustomBusinessObject;
  mMon: TNxCustomBusinessMonikerCollection;
  mPars : TNxParameters;
  mFirm_id: String;
  mPar: TNxParameter;
    mSQL:String;
  mRentalDeviceBO:TNxCustomBusinessObject;
  mRetntalList:TStringList;
  i:Integer;
begin
  if not (Sender is TComponent) then
    exit;
      mSite := TComponent(Sender).DynSite;
      mObj := TDynSiteForm(mSite).CurrentObject;
   if not(mobj.GetFieldValueAsString('ActQueue_ID')='2000000101') then begin
     NxShowSimpleMessage('Toto tlačítko slouží pouze pro půjčovnu',mSite);

     exit;
   end;
  if NxMessageBox('Dotaz', 'Přejete si automaticky vytvořit Fakturu vydanou?', mdConfirm, mdbYesNo, 0, 0, False, mSite)=mrYes then begin

    if mSite is TDynSiteForm then begin
      //mObj := TDynSiteForm(mSite).CurrentObject;
      mFirm_id:=mObj.GetFieldValueAsString('Firm_ID');
      if mFirm_id='0000000000' then mFirm_id:='AAA1000000';
      mActivityType := mObj.ObjectSpace.CreateObject('SMOEDRFJASV4P4XCFPYBZ1UYYO');
      mActivityType.Load(mObj.GetFieldValueAsString('ActivityType_ID'), nil);

      // Vytvorime novou instanci business objektu Pokladní příjem
      mCashReceived := mObj.ObjectSpace.CreateObject('O3BDOKTWEFD13ACM03KIU0CLP4');
      mCashReceived.New;
      mCashReceived.Prefill;
      mCashReceived.SetFieldValueAsString('DocQueue_ID', 'I100000101');
      mCashReceived.SetFieldValueAsString('BankAccount_ID', '1000000101');
      mCashReceived.SetFieldValueAsString('Firm_ID', mfirm_id);
      mCashReceived.SetFieldValueAsString('PaymentType_ID','6000000101');
      mCashReceived.SetFieldValueAsString('Description', mObj.GetFieldValueAsString('Subject'));
      mCashReceived.SetFieldValueAsBoolean('PricesWithVAT', True);
      mSQL:='Select ID from defrolldata where X_Activity_ID=''%s'' and clsid=''VFNPR04IPRQ41HGAGUTXNGLWYW'' ';
      mRetntalList:=TStringList.create;
      mCashReceived.ObjectSpace.SQLSelect(Format(mSQL,[mObj.OID]),mRetntalList);

      mMon := mCashReceived.GetLoadedCollectionMonikerForFieldCode(mCashReceived.GetFieldCode('ROWS'));
      for i:=0 to mRetntalList.Count-1 do begin
          mCashReceivedRow:=mMon.AddNewObject;
          mRentalDeviceBO:=mCashReceived.ObjectSpace.CreateObject('VFNPR04IPRQ41HGAGUTXNGLWYW');
          mRentalDeviceBO.Load(mRetntalList.Strings[i],nil);
          mCashReceivedRow.SetFieldValueAsInteger('RowType',1);
          mCashReceivedRow.SetFieldValueAsString('Text', 'Půjčení '+mRentalDeviceBO.GetFieldValueAsString('X_RentalDevice_ID.Name'));
          mCashReceivedRow.SetFieldValueAsFloat('TotalPrice',mRentalDeviceBO.GetFieldValueAsFloat('U_RentalAmount'));
          mCashReceivedRow.SetFieldValueAsString('VATRate_ID', '02100X0000');
          mCashReceivedRow.SetFieldValueAsString('BusTransaction_ID', mObj.GetFieldValueAsString('BusTransaction_ID'));
          mCashReceivedRow.SetFieldValueAsString('Division_id', mObj.GetFieldValueAsString('Division_ID'));
          mCashReceivedRow.SetFieldValueAsString('IncomeType_ID', mActivityType.GetFieldValueAsString('U_IncomeType_ID'));



      end;
      //FillRow(mObj, mMon, 'U_RentalDevice_ID', 'U_TotalRentalAmount1', mActivityType.GetFieldValueAsString('U_IncomeType_ID'));
      //FillRow(mObj, mMon, 'U_RentalDevice2_ID', 'U_TotalRentalAmount2', mActivityType.GetFieldValueAsString('U_IncomeType_ID'));
      //FillRow(mObj, mMon, 'U_RentalDevice3_ID', 'U_TotalRentalAmount3', mActivityType.GetFieldValueAsString('U_IncomeType_ID'));
     FillRow(mObj, mMon, '', 'U_ServiceAmount', mActivityType.GetFieldValueAsString('U_IncomeType_ID'));

      mCashReceived.Save;

      // vytvořím vazbu mezi Pokladním příjmem a Aktivitou
      mRelation := mObj.ObjectSpace.CreateObject('01ZXNDSYDVD135SA02K2CQM5AW');
      mRelation.New;
      mRelation.SetFieldValueAsString('LEFTSIDE_ID', mObj.OID);
      mRelation.SetFieldValueAsString('RIGHTSIDE_ID', mCashReceived.OID);
      mRelation.SetFieldValueAsInteger('REL_DEF', 1200);
      mRelation.Save;

      mPars := TNxParameters.Create;
      try
        mPars.NewFromDataType(dtString, '_SelectionCaption', pkUnknown).AsString := 'Nová faktura vydaná pro ' + mObj.DisplayName;
        mPar := mPars.NewFromDataType(dtList, '_DefaultSelection', pkUnknown) ; // DoNotLocalize
        mPar := mPar.AsList.NewFromDataType(dtList, 'CONDITIONS', pkUnknown);
        mPar := mPar.AsList.NewFromDataType(dtList, 'ID', pkUnknown) ; // DoNotLocalize
        mPar.AsList.NewFromDataType(dtInteger, 'USEDKIND', pkUnknown).AsInteger := 1;
        mPar := mPar.AsList.NewFromDataType(dtList, 'Values', pkUnknown);
        mPar.AsList.NewFromDataType(dtString, '{:VALUE}', pkUnknown).AsString := '''' + mCashReceived.OID + '''';

      if not NxIsEmptyOID(mCashReceived.OID) then
            mSite.ShowDynForm('PLC2EX0BUJD13ACP03KIU0CLP4', mPars, Nil, False, '')
      finally
        mPars.Free;
      end
    end;
  end;
end;





procedure CreateBillOfDeliOnExecute(Sender: TObject);
var
  mSite: TSiteForm;
  mObj : TNxCustomBusinessObject;
  mBoD, mRelation, mActivityType, mRentalDevice_ID : TNxCustomBusinessObject;
  mMon: TNxCustomBusinessMonikerCollection;
  mNewRow: TNxCustomBusinessObject;
  mPars : TNxParameters;
  mPar: TNxParameter;
  mPoznamka: String;
  mDeviceList:TStringList;
  mSql:STring;
  i:Integer;
begin
  if not (Sender is TComponent) then
    exit;
   mSite := TComponent(Sender).DynSite;
   mObj := TDynSiteForm(mSite).CurrentObject;
   if not(mobj.GetFieldValueAsString('ActQueue_ID')='2000000101') then begin
     NxShowSimpleMessage('Toto tlačítko slouží pouze pro půjčovnu',mSite);

     exit;
   end;
  if NxMessageBox('Dotaz', 'Přejete si automaticky vytvořit Dodací list?', mdConfirm, mdbYesNo, 0, 0, False, mSite)=mrYes then begin


    DLSEData(mPoznamka, msite);
    if mSite is TDynSiteForm then begin

      mActivityType := mObj.ObjectSpace.CreateObject('SMOEDRFJASV4P4XCFPYBZ1UYYO');
      mActivityType.Load(mObj.GetFieldValueAsString('ActivityType_ID'), nil);
      // tady si dám dialog

      // Vytvorime novou instanci business objektu Pokladní příjem
      mBoD := mObj.ObjectSpace.CreateObject('050I5SAOS3DL3ACU03KIU0CLP4');
      mBoD.New;
      mBoD.Prefill;
      mBoD.SetFieldValueAsString('DocQueue_ID', mActivityType.GetFieldValueAsString('U_BillOfDeliveryQueue_ID'));
      if not(NxIsEmptyOID(mObj.GetFieldValueAsString('Firm_ID'))) then mBoD.SetFieldValueAsString('Firm_ID', mObj.GetFieldValueAsString('Firm_ID'));
      if (NxIsEmptyOID(mObj.GetFieldValueAsString('Firm_ID'))) then mBoD.SetFieldValueAsString('Firm_ID', 'AAA1000000');
      mBoD.SetFieldValueAsString('Description', mObj.GetFieldValueAsString('Subject'));
      mBoD.SetFieldValueAsString('U_poznamka',mPoznamka);

      mMon := mBoD.GetLoadedCollectionMonikerForFieldCode(mBoD.GetFieldCode('ROWS'));
      mDeviceList:=TStringList.Create;
      mSql:='Select d.ID from defrolldata d where d.clsid=''VFNPR04IPRQ41HGAGUTXNGLWYW'' and d.X_Activity_ID=''%s'' ';
      mBoD.ObjectSpace.SQLSelect(Format(mSql,[mObj.OID]),mDeviceList);
      for i:=0 to mDeviceList.Count-1 do begin
        mRentalDevice_ID:=mBoD.ObjectSpace.CreateObject('VFNPR04IPRQ41HGAGUTXNGLWYW');
        mRentalDevice_ID.Load(mDeviceList.strings[i],nil);
          mNewRow := mMon.AddNewObject;
          mNewRow.SetFieldValueAsInteger('RowType', 1);
          mNewRow.SetFieldValueAsString('Division_ID', mObj.GetFieldValueAsString('Division_ID'));
          mNewRow.SetFieldValueAsString('Text', NxPadR('Půjčovné za '+mRentalDevice_ID.GetFieldValueAsString('X_RentalDevice_ID.Name'),60,' ')+FloatToStr(mRentalDevice_ID.GetFieldValueAsFloat('U_rentalamount'))+' Kč s DPH');
          mNewRow.SetFieldValueAsFloat('U_cenasdph2',mRentalDevice_ID.GetFieldValueAsFloat('U_rentalamount'));
          if NxIsEmptyOID(mObj.GetFieldValueAsString('BusTransaction_ID')) then
            mNewRow.SetFieldValueAsString('BusTransaction_ID', '5000000101')
          else
           mNewRow.SetFieldValueAsString('BusTransaction_ID', mObj.GetFieldValueAsString('BusTransaction_ID'));
          mRentalDevice_ID.Free;
      end;
      {mNewRow := mMon.AddNewObject;
      mNewRow.SetFieldValueAsInteger('RowType', 1);
      mNewRow.SetFieldValueAsString('Division_ID', mObj.GetFieldValueAsString('Division_ID'));
//      mNewRow.SetFieldValueAsString('VATRate_ID', '01900X0000');
      mNewRow.SetFieldValueAsFloat('U_cenasdph2',
      mObj.GetFieldValueAsFloat('U_U_RentalAmount') +
      mObj.GetFieldValueAsFloat('U_U_RentalAmount2') +
      mObj.GetFieldValueAsFloat('U_U_RentalAmount3') +
      mObj.GetFieldValueAsFloat('U_ServiceAmount'));

      mNewRow.SetFieldValueAsString('Text', mObj.GetFieldValueAsString('Subject'));
      if NxIsEmptyOID(mObj.GetFieldValueAsString('BusTransaction_ID')) then
        mNewRow.SetFieldValueAsString('BusTransaction_ID', '5000000101')
      else
        mNewRow.SetFieldValueAsString('BusTransaction_ID', mObj.GetFieldValueAsString('BusTransaction_ID'));}



      mBoD.Save;

      // vytvořím vazbu mezi Dodacím listem a Aktivitou
      mRelation := mObj.ObjectSpace.CreateObject('01ZXNDSYDVD135SA02K2CQM5AW');
      mRelation.New;
      mRelation.SetFieldValueAsString('LEFTSIDE_ID', mObj.OID);
      mRelation.SetFieldValueAsString('RIGHTSIDE_ID', mBoD.OID);
      mRelation.SetFieldValueAsInteger('REL_DEF', 1238);
      mRelation.Save;

      mPars := TNxParameters.Create;
      try
        mPars.NewFromDataType(dtString, '_SelectionCaption', pkUnknown).AsString := 'Nový dodací list pro ' + mObj.DisplayName;
        mPar := mPars.NewFromDataType(dtList, '_DefaultSelection', pkUnknown) ; // DoNotLocalize
        mPar := mPar.AsList.NewFromDataType(dtList, 'CONDITIONS', pkUnknown);
        mPar := mPar.AsList.NewFromDataType(dtList, 'ID', pkUnknown) ; // DoNotLocalize
        mPar.AsList.NewFromDataType(dtInteger, 'USEDKIND', pkUnknown).AsInteger := 1;
        mPar := mPar.AsList.NewFromDataType(dtList, 'Values', pkUnknown);
        mPar.AsList.NewFromDataType(dtString, '{:VALUE}', pkUnknown).AsString := '''' + mBoD.OID + '''';

      if not NxIsEmptyOID(mBoD.OID) then
            mSite.ShowDynForm('B50I5SAOS3DL3ACU03KIU0CLP4', mPars, Nil, False, '')
      finally
        mPars.Free;
      end
    end;
  end;
end;

Function DLSEData(var mrozvoz_poznamka:string; var asite:TSiteForm):boolean;

 var
  mForm: TForm;
  mLab: TLabel;
  mEd1,mEd3,mEd5, mEd7: TEdit;
  mEd2, mEd4, mEd6: TDateEdit;
  mEd8, med9:TCheckBox;
  mResult: integer;
  mBut: TButton;
begin
  mForm := TForm.Create(asite);
  try
    mForm.Caption := 'Zadejte popis';
    mForm.FormStyle := fsStayOnTop;
    mForm.BorderStyle := bsDialog;
    mForm.Width := 350;
    mForm.Height := 120;
    mForm.Scaled := False;
    mForm.Position := poScreenCenter;
    mLab := TLabel.Create(mForm);
    mLab.Left := 10;
    mLab.Top := 5;
    mLab.Caption := 'Poznámka';
    mLab.Parent := mForm;
    mEd3 := TEdit.Create(mForm);
    mEd3.Left := 110;
    mEd3.Top := 5;
    mEd3.Width := 200;
    mEd3.Text := mRozvoz_Poznamka;
    mEd3.Parent := mForm;
    CreateButton(mForm, mForm, 50, 20, 70, 25, 'Cancel', 2);
    CreateButton(mForm, mForm, 50, 120, 70, 25, 'OK', 1);
    mResult := mForm.Showmodal(asite);
    if mResult = 1 then
      //ShowMessage('Řádně jste zadal:' + Chr(13) + Chr(10) + mEd1.Text + Chr(13) + Chr(10) + mEd2.Text);


      mRozvoz_poznamka:=mEd3.Text;


  finally
    mForm.Free;
  end;
end;


function CreateButton(AOwner: TComponent; AParent: TWinControl; ATop, ALeft, AWidth, AHeight: integer; ACaption: string; AModalResult: integer): TButton;
begin
  Result := TButton.Create(AOwner);
  Result.Top := ATop;
  Result.Left := ALeft;
  Result.Width := AWidth;
  Result.Height := AHeight;
  Result.Caption := ACaption;
  Result.ModalResult := AModalResult;
  Result.Parent := AParent;
end;


begin
end.