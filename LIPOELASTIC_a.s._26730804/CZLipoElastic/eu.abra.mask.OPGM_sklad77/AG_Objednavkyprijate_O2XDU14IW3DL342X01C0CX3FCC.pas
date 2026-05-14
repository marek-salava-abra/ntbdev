uses 'EU.Aabra.Mask.Validace.lib';







{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
 mMAction: TMultiAction;

begin
           mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Přeobjednání OPGM/OPTE';
          mMAction.Caption := 'Přeobjednání OPGM/OPTE';
          mMAction.Items.Add('Nový OPGM');
          mMAction.Items.Add('Nový OPTE');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @NewDLExecute;


end;

function NewDL(ABO: TNxCustomBusinessObject;msite:TDynSiteForm;index:integer): string;
var
  mDocHead: TNxCustomBusinessObject;
  i, mPosIndex: integer;
  mMon: TNxCustomBusinessMonikerCollection;
  mRow, mNewRow: TNxCustomBusinessObject;
  mList: TStringList;
  mText: string;
begin
  result := '';
  mDocHead := ABO.ObjectSpace.CreateObject('01CPMINJW3DL342X01C0CX3FCC');
  try
    mDocHead.New;
    mDocHead.Prefill;
    mDocHead.SetFieldValueAsString('Firm_ID', ABO.GetFieldValueAsString('Firm_ID'));
    mDocHead.SetFieldValueAsString('FirmOffice_ID', ABO.GetFieldValueAsString('FirmOffice_ID'));
    mDocHead.SetFieldValueAsString('Description', ABO.GetFieldValueAsString('Description'));
    mDocHead.SetFieldValueAsString('ExternalNumber', ABO.GetFieldValueAsString('ExternalNumber'));
    mDocHead.SetFieldValueAsString('TransportationType_ID', ABO.GetFieldValueAsString('TransportationType_ID'));
    mDocHead.SetFieldValueAsinteger('TradeType', ABO.GetFieldValueAsinteger('TradeType'));
    mDocHead.SetFieldValueAsString('TradeTypeDescription', ABO.GetFieldValueAsString('TradeTypeDescription'));
    mDocHead.SetFieldValueAsBoolean('VATDocument', ABO.GetFieldValueAsBoolean('VATDocument'));
    mDocHead.SetFieldValueAsString('VATCountry_ID', ABO.GetFieldValueAsString('VATCountry_ID'));
     mDocHead.SetFieldValueAsString('PaymentType_ID', ABO.GetFieldValueAsString('PaymentType_ID'));
    mDocHead.SetFieldValueAsString('Person_ID', ABO.GetFieldValueAsString('Person_ID'));

    mDocHead.SetFieldValueAsString('BankAccount_ID', ABO.GetFieldValueAsString('BankAccount_ID'));
    mDocHead.SetFieldValueAsString('ConstSymbol_ID', ABO.GetFieldValueAsString('ConstSymbol_ID'));
    mDocHead.SetFieldValueAsString('Country_ID', ABO.GetFieldValueAsString('Country_ID'));
    mDocHead.SetFieldValueAsBoolean('PricesWithVAT', ABO.GetFieldValueAsBoolean('PricesWithVAT'));
    //mDocHead.SetFieldValueAsFloat('CurrRate', ABO.GetFieldValueAsFloat('CurrRate'));

    mDocHead.SetFieldValueAsString('IntrastatDeliveryTerm_ID', ABO.GetFieldValueAsString('IntrastatDeliveryTerm_ID'));
    mDocHead.SetFieldValueAsString('IntrastatTransportationType_ID', ABO.GetFieldValueAsString('IntrastatTransportationType_ID'));

    mDocHead.SetFieldValueAsString('X_Delivery_Adress_ID', ABO.GetFieldValueAsString('X_Delivery_Adress_ID'));
    mDocHead.SetFieldValueAsString('U_PrintLink', ABO.GetFieldValueAsString('U_PrintLink'));

    // DocQueue_ID se prebirat neda a v demodatech se ani se automaticky neprednastavi
    // (protoze obsahuji vice rad pro dodaci listy)
    // => pouzijeme OID rady DL z demodat - pro pouziti v jinych datech je treba
    // toto OID v kodu skriptu nahradit existujicim
     if index=0 then mDocHead.SetFieldValueAsString('DocQueue_ID', '1020000101');
     if index=1 then mDocHead.SetFieldValueAsString('DocQueue_ID', '1U10000101');
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
      mMon := mDocHead.GetLoadedCollectionMonikerForFieldCode(mDocHead.GetFieldCode('ROWS'));
      for i := 0 to mList.Count-1 do begin
        mRow := TNxCustomBusinessObject(mList.Objects[i]);
        if ((mRow.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID.code') <>'PB') and
           (mRow.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID.code') <>'Px')) then begin
        mNewRow := mMon.AddNewObject;
        mNewRow.SetFieldValueAsInteger('RowType', mRow.GetFieldValueAsInteger('RowType'));
        if index=0 then mNewRow.SetFieldValueAsString('Store_ID', '1120000101');
        if index=1 then mNewRow.SetFieldValueAsString('Store_ID', '2Z00000101');
        mNewRow.SetFieldValueAsString('StoreCard_ID', mRow.GetFieldValueAsString('StoreCard_ID'));
        mNewRow.SetFieldValueAsString('QUnit', mRow.GetFieldValueAsString('QUnit'));
        mNewRow.SetFieldValueAsFLoat('UnitRate', mRow.GetFieldValueAsFloat('UnitRate'));
        mNewRow.SetFieldValueAsFLoat('Quantity', mRow.GetFieldValueAsFloat('Quantity'));
        mNewRow.SetFieldValueAsString('Text', mRow.GetFieldValueAsString('Text'));
        mNewRow.SetFieldValueAsString('Division_ID', mRow.GetFieldValueAsString('Division_ID'));
        mNewRow.SetFieldValueAsString('BusOrder_ID', mRow.GetFieldValueAsString('BusOrder_ID'));
        mNewRow.SetFieldValueAsString('BusTransaction_ID', mRow.GetFieldValueAsString('BusTransaction_ID'));
        mNewRow.SetFieldValueAsString('X_specifikace_ID', mRow.GetFieldValueAsString('X_specifikace_ID'));
        mNewRow.SetFieldValueAsString('X_ExternalSpecification', mRow.GetFieldValueAsString('X_ExternalSpecification'));
        mNewRow.SetFieldValueAsString('X_ReceivedOrderRow_ID', mRow.oid);

        end;
      end;
    finally
      mList.Free;
    end;
    mDocHead.ClearValidateErrors;
    if Not mDocHead.Validate() then begin
      mList := TStringList.Create;
      try
        mDocHead.GetValidateErrors(mList);
        mText := mList.Text;
        NxToken(mText, '=');
        mSite.ShowDynForm('O2XDU14IW3DL342X01C0CX3FCC', Nil, Nil, False, 'DoEdit;'+mDocHead.oid);
        if index=0 then MessageDlg('Automaticky vytvořený OPGM nelze uložit z těchto důvodů:' + #13#10 + mText, mtWarning, [mbOK], 0);
        if index=1 then MessageDlg('Automaticky vytvořený OPTE nelze uložit z těchto důvodů:' + #13#10 + mText, mtWarning, [mbOK], 0);
      finally
        mList.Free;
      end;
    end else begin
      mDocHead.Save;
      result := mDocHead.OID;
    end;
  finally
    mDocHead.Free;
  end;
end;

procedure NewDLExecute(Sender: TComponent;index:integer);
var
  mSite: TDynSiteForm;
  mObj: TNxCustomBusinessObject;
  mID: string;
begin
  if true then begin
    //OutputDebugString('Sender je TComponent.');
    msite:=TComponent(Sender).DynSite;
    //OutputDebugString('Nalezen nadřízený SiteForm.');

    // Ziskame aktualni objekt (TNxCustomBusinessObject)
    mObj := mSite.CurrentObject;
    try
      if Assigned(mObj) then
      begin
        mID := NewDL(mObj,msite,index);
        if not NxIsEmptyOID(mID) then
          mSite.ShowDynForm('O2XDU14IW3DL342X01C0CX3FCC', Nil, Nil, False, 'DoEdit;'+mID);
      end;
    finally
      mObj.Free;
    end;
  end;
end;

begin
end.