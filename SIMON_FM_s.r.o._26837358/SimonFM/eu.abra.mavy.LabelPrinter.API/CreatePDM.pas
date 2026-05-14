uses 'eu.abra.mavy.libs.common', 'eu.abra.mavy.LabelPrinter.API.consts.consts','eu.abra.mavy.LabelPrinter.API.fce';

procedure MassCreateDocs(ASite: TDynSiteForm; AObjCLSID: string);
var
  mList, mDocsList: TStrings;
  i,a: integer;
  mObject: TNxCustomBusinessObject;
  mOID: string;
  mForm: TForm;
begin
  mList := TStringList.Create;
  mDocsList := TStringList.Create;
  a:=0;
  try
    ASite.FillListWithSelectedRows(mList);
    for i := 0 to mList.Count - 1 do begin
      mObject := ASite.BaseObjectSpace.CreateObject(AObjCLSID);
      try
        mObject.Load(mList.Strings[i], nil);
        if mObject.GetFieldValueAsBoolean('TransportationType_ID.X_LP_SendToLabelPrinter') then begin
          mOID := CreatePDMDoc(ASite.BaseObjectSpace, mObject, AObjCLSID, True, True);
          if mOID <> '' then
            mDocsList.Add(mOID);
        end
        else begin
          a:= a + 1
        end;
      finally
        mObject.Free;
      end;
    end;
    if CFxNxRuntime.NxGetEnvironmentType = reRuntimeExe then ShowMessage('Počet vytvořených dokladů odeslané pošty: ' + IntToStr(mDocsList.Count) + '/'+IntTostr(mList.Count)+'.'+#13#10+'Z toho '+IntToStr(a)+' se způsobem dopravy, který se neodesílá');
  finally
    mList.Free;
    mDocsList.Free;
  end;
end;

function CreatePDMDoc(AObjectSpace: TNxCustomObjectSpace; ASourceObject: TNxCustomBusinessObject; AObjCLSID: string; ATransaction, ACheckOriginal: boolean): string;
var
  mUseWeight: Boolean;
  mPDMObject, mRelation, mOrderBO,mInvoiceBO: TNxCustomBusinessObject;
  mPaymentKind, mRelDef: integer;
  mSQL: string;
  mValues, mValidateErr: TStringList;
  mContinue, mSupportZasilkovna: Boolean;
  mRes: integer;
  mCurrencyCode, mInvoice_ID, mOrder_ID, mOrderNumber, mIssuedContentOID, mZasilkovnaOP_OID: string;
  mInsuredValue, mCODAmount: Extended;
begin
  Result := '';
  case AObjCLSID of
    'O3BDOKTWEFD13ACM03KIU0CLP4' : mRelDef := 1400; // FV
    '01CPMINJW3DL342X01C0CX3FCC' : mRelDef := 1431; // OP
    '050I5SAOS3DL3ACU03KIU0CLP4' : mRelDef := 1438; // DL
    '0PDOXDMCSZDL3FUD00C5OG4NF4' : mRelDef := 1443; //PRV
  end;

  mValues := TStringList.Create;
  try
    mSQL := 'select LeftSide_ID from Relations where Rel_Def = %s and RightSide_ID = ''%s''';
    mSQL := Format(mSQL, [IntToStr(mRelDef), ASourceObject.OID]);
    AObjectSpace.SQLSelect(mSQL, mValues);
    mContinue := True;
    if (mValues.Count > 0) and ACheckOriginal then begin
      mContinue := False;
      mRes := NxMessageBox('Dotaz', Format('K dokladu %s již existuje balík. Přejete si přesto vytvořit další?', [ASourceObject.DisplayName]),
        mdConfirm, mdbYesNo, 1, nil, False, nil);
      if mRes = mrYes then
        mContinue := True;
    end;
    if mContinue then begin
      try
        if ATransaction then AObjectSpace.StartTransaction(taReadCommited);
        try
          mPDMObject := AObjectSpace.CreateObject(Class_PDMIssuedDoc);
          try
            mPDMObject.New;
            mPDMObject.Prefill;
            if not NxIsEmptyOID(cSender_ID) then
              mPDMObject.SetFieldValueAsString('Sender_ID', cSender_ID);
            mPDMObject.SetFieldValueAsString('DocQueue_ID', cPDM_DocQueue_OID);
            mPDMObject.SetFieldValueAsString('Note', ASourceObject.GetFieldValueAsString('X_LP_ExpeditionNote'));
            mPDMObject.SetFieldValueAsString('Firm_ID', ASourceObject.GetFieldValueAsString('Firm_ID'));
            mPDMObject.SetFieldValueAsString('FirmOffice_ID', ASourceObject.GetFieldValueAsString('FirmOffice_ID'));
            mPDMObject.SetFieldValueAsString('Person_ID', ASourceObject.GetFieldValueAsString('Person_ID'));
            mPDMObject.SetFieldValueAsInteger('TargetAddressType', 1);
            mPDMObject.SetFieldValueAsString('X_LP_State_ID', cDefaultState_ID);

            //Zdrojový doklad je dodací list, takže musím většinu infomrací čerpat z OP.
            // - Zdrojová OP se bere z prvního řádku dodacího listu
            // - Pokud neexistuje vazba na OP, tak ukončuji skript
            if AObjCLSID = '050I5SAOS3DL3ACU03KIU0CLP4' then begin
              mOrder_ID:= SQLSingleSelect(AObjectSpace,'SELECT First 1 Provide_ID FROM StoreDocuments2 WHERE Parent_ID = '+QuotedStr(ASourceObject.OID)+' ORDER BY PosIndex' );
              if NxIsEmptyOID(mOrder_ID) then begin
                if CFxNxRuntime.NxGetEnvironmentType = reRuntimeExe then ShowMessage('Dodací list '+ASourceObject.DisplayName+' nemá vazbu k žádné OP, balík nelze vytvořit');
                exit;
              end
              else begin
                mOrderBO:= AObjectSpace.CreateObject(Class_ReceivedOrder);
                mOrderBO.Load(mOrder_ID, nil);
                mPDMObject.SetFieldValueAsString('VarSymbol', StripOnlyNumbers(mOrderBO.GetFieldValueAsString('ExternalNumber')));
                mPDMObject.SetFieldValueAsString('X_LP_OrderNumber', mOrderBO.GetFieldValueAsString('ExternalNumber'));
                mPDMObject.SetFieldValueAsString('X_LP_Source_ID', ASourceObject.OID);
                mPDMObject.SetFieldValueAsString('X_LP_SourceCLSID', Class_BillOfDelivery);
                mPDMObject.SetFieldValueAsString('BankAccount_ID', mOrderBO.GetFieldValueAsString('BankAccount_ID'));
                mPDMObject.SetFieldValueAsString('ConstSymbol_ID', mOrderBO.GetFieldValueAsString('ConstSymbol_ID'));
                mInsuredValue:=  mOrderBO.GetFieldValueAsFloat('Amount');
                mCODAmount:=  mOrderBO.GetFieldValueAsFloat('Amount');
                mPaymentKind := mOrderBO.GetFieldValueAsInteger('PaymentType_ID.PaymentKind');
                mCurrencyCode := mOrderBO.GetFieldValueAsString('Currency_ID.Code');
                mOrderBO.Free;
              end;
            end;

            //Zdrojový doklad je převodka výdej
            if AObjCLSID = '0P0I5SAOS3DL3ACU03KIU0CLP4' then begin
                //mPDMObject.SetFieldValueAsString('VarSymbol', StripOnlyNumbers(mOrderBO.GetFieldValueAsString('ExternalNumber')));
                //mPDMObject.SetFieldValueAsString('X_LP_OrderNumber', mOrderBO.GetFieldValueAsString('ExternalNumber'));
                mPDMObject.SetFieldValueAsString('X_LP_Source_ID', ASourceObject.OID);
                mPDMObject.SetFieldValueAsString('X_LP_SourceCLSID', Class_OutgoingTransfer);
                //mPDMObject.SetFieldValueAsString('BankAccount_ID', mOrderBO.GetFieldValueAsString('BankAccount_ID'));
                //mPDMObject.SetFieldValueAsString('ConstSymbol_ID', mOrderBO.GetFieldValueAsString('ConstSymbol_ID'));
                mInsuredValue:=  0;
                mCODAmount:= 0;
                mPaymentKind := 1;
                mCurrencyCode := '0000CZK000';
            end;

            //Zdrojový doklad je faktura vydaná, je potřeba dohledat číslo OP
            if AObjCLSID = 'O3BDOKTWEFD13ACM03KIU0CLP4' then begin
              mSQL:= 'SELECT Distinct(RO.ExternalNumber) FROM IssuedInvoices2 II2'+
                      ' LEFT JOIN StoreDocuments2 SD2 ON II2.ProvideRow_ID = SD2.ID'+
                      ' LEFT JOIN ReceivedOrders RO ON SD2.Provide_ID = RO.ID'+
                      ' WHERE SD2.FlowType = 21 and II2.Parent_ID = ' +QuotedStr(ASourceObject.OID);
              mOrderNumber:= SQLSingleSelect(AObjectSpace,mSQL);

              // Pole číslo objednávky je povinné
              if NxIsBlank(mOrderNumber) then
                mPDMObject.SetFieldValueAsString('X_LP_OrderNumber', ASourceObject.GetFieldValueAsString('VarSymbol'))
              else
                mPDMObject.SetFieldValueAsString('X_LP_OrderNumber', mOrderNumber);

              mPDMObject.SetFieldValueAsString('VarSymbol', ASourceObject.GetFieldValueAsString('VarSymbol'));   //FV
              mPDMObject.SetFieldValueAsString('X_LP_Source_ID', ASourceObject.OID);
              mPDMObject.SetFieldValueAsString('X_LP_SourceCLSID', Class_IssuedInvoice );
              mPDMObject.SetFieldValueAsString('BankAccount_ID', ASourceObject.GetFieldValueAsString('BankAccount_ID'));
              mPDMObject.SetFieldValueAsString('ConstSymbol_ID', ASourceObject.GetFieldValueAsString('ConstSymbol_ID'));
              mInsuredValue := ASourceObject.GetFieldValueAsFloat('Amount');
              mCODAmount:=  ASourceObject.GetFieldValueAsFloat(cCODInvoiceFieldName);
              mPaymentKind := ASourceObject.GetFieldValueAsInteger('PaymentType_ID.PaymentKind');
              mCurrencyCode := ASourceObject.GetFieldValueAsString('Currency_ID.Code');
            end;

            //Zdrojový doklad je objednávka přijatá
            if AObjCLSID = '01CPMINJW3DL342X01C0CX3FCC'then begin
              if cGetInvoiceDataForOrders then begin
                mSQL:= 'SELECT DISTINCT(A.Parent_ID) FROM IssuedInvoices2 A'+
                        ' LEFT JOIN StoreDocuments SD ON SD.ID=A.Provide_ID'+
                        ' LEFT JOIN StoreDocuments2 SD2 ON SD2.Parent_ID=SD.ID'+
                        ' WHERE SD.DocumentType=21 and SD2.Provide_ID= ' + QuotedStr(ASourceObject.OID);
                mInvoice_ID:= SQLSingleSelect(AObjectSpace,mSQL);
                if not NxIsEmptyOID(mInvoice_ID) then begin
                  mInvoiceBO:= AObjectSpace.CreateObject(Class_IssuedInvoice);
                  mInvoiceBO.Load(mInvoice_ID, nil);
                  mPDMObject.SetFieldValueAsString('VarSymbol', mInvoiceBO.GetFieldValueAsString('VarSymbol'));
                  mInsuredValue := mInvoiceBO.GetFieldValueAsFloat('Amount');
                  mCODAmount:= mInvoiceBO.GetFieldValueAsFloat(cCODInvoiceFieldName);
                  mCurrencyCode := mInvoiceBO.GetFieldValueAsString('Currency_ID.Code');
                end
                else begin
                  mPDMObject.SetFieldValueAsString('VarSymbol', StripOnlyNumbers(ASourceObject.GetFieldValueAsString('ExternalNumber')));
                  mInsuredValue := ASourceObject.GetFieldValueAsFloat('Amount');
                  mCODAmount:=  ASourceObject.GetFieldValueAsFloat('Amount');
                  mCurrencyCode := ASourceObject.GetFieldValueAsString('Currency_ID.Code');
                end;
              end
              else begin
                mPDMObject.SetFieldValueAsString('VarSymbol', StripOnlyNumbers(ASourceObject.GetFieldValueAsString('ExternalNumber')));
                mInsuredValue := ASourceObject.GetFieldValueAsFloat('Amount');
                mCODAmount:=  ASourceObject.GetFieldValueAsFloat('Amount');
                mCurrencyCode := ASourceObject.GetFieldValueAsString('Currency_ID.Code');
              end;
              mPDMObject.SetFieldValueAsString('X_LP_OrderNumber', ASourceObject.GetFieldValueAsString('ExternalNumber')); //OP
              mPDMObject.SetFieldValueAsString('X_LP_Source_ID', ASourceObject.OID);
              mPDMObject.SetFieldValueAsString('X_LP_SourceCLSID', Class_ReceivedOrder );
              mPDMObject.SetFieldValueAsString('BankAccount_ID', ASourceObject.GetFieldValueAsString('BankAccount_ID'));
              mPDMObject.SetFieldValueAsString('ConstSymbol_ID', ASourceObject.GetFieldValueAsString('ConstSymbol_ID'));
              mPaymentKind := ASourceObject.GetFieldValueAsInteger('PaymentType_ID.PaymentKind');
            end;


            if cUseWeight and ASourceObject.HasField(cWeightFieldName) then begin
              mPDMObject.SetFieldValueAsFloat('Weight', ASourceObject.GetFieldValueAsFloat(cWeightFieldName));
              mPDMObject.SetFieldValueAsInteger('WeightUnit', 1);   //kg (LP podporuje jen kg)
            end;

            mPDMObject.SetFieldValueAsString('Description', Format('Balík k dokladu: %s', [ASourceObject.DisplayName]));

            mPDMObject.SetFieldValueAsString('PostProvider_ID', ASourceObject.GetFieldValueAsString('TransportationType_ID.X_LP_PDMPostProvider_ID'));
            mIssuedContentOID := ASourceObject.GetFieldValueAsString('TransportationType_ID.X_LP_ServiceCode_ID');

            //Cena zásilky
            if mCurrencyCode = 'CZK' then
              mPDMObject.SetFieldValueAsFloat('InsuredValue', NxRoundByValue(mInsuredValue,ctUp, 1)) //cena zásilky se zaohrouhlením na celé koruny
            else
              mPDMObject.SetFieldValueAsFloat('InsuredValue', mInsuredValue);                         //cena zásilky bez zaokrouhlení

            //dobírka
            if (mPaymentKind = 3) and (mCODAmount > cInsuredTolerance)  then begin
              if mCurrencyCode = 'CZK' then
                mPDMObject.SetFieldValueAsFloat('CashOnDelivery', NxRoundByValue(mCODAmount,ctUp, 1)) //dobírka se zaokrouhlením na celé koruny
              else
                mPDMObject.SetFieldValueAsFloat('CashOnDelivery', mCODAmount);                         //dobírka bez zaokrouhlení
              if not NxIsEmptyOID(ASourceObject.GetFieldValueAsString('TransportationType_ID.X_LP_COD_ServiceCode_ID')) then
                mIssuedContentOID := ASourceObject.GetFieldValueAsString('TransportationType_ID.X_LP_COD_ServiceCode_ID');
            end;
            mPDMObject.SetFieldValueAsString('IssuedContent_ID', mIssuedContentOID);

            if mPDMObject.GetFieldValueAsFloat('Amount') = 0 then // HACK - nepoužíváme, ale občas je cena nula a to neprochází validací.
              mPDMObject.SetFieldValueAsFloat('Amount', 1);

            if mPDMObject.Validate then begin
              mPDMObject.Save;
              Result := mPDMObject.OID;
              if ATransaction then AObjectSpace.Commit;
              // ulozeni relace
              mRelation := AObjectSpace.CreateObject('01ZXNDSYDVD135SA02K2CQM5AW');
              try
                mRelation.New;
                mRelation.Prefill;
                mRelation.SetFieldValueAsInteger('Rel_Def', mRelDef);
                mRelation.SetFieldValueAsString('LeftSide_ID', Result);
                mRelation.SetFieldValueAsString('RightSide_ID', ASourceObject.OID);
                mRelation.Save;
              finally
                mRelation.Free;
              end;
            end
            else begin
              mValidateErr:= TStringList.Create;
              mPDMObject.GetValidateErrors(mValidateErr);
              if CFxNxRuntime.NxGetEnvironmentType = reRuntimeExe then ShowMessage('Validace objektu odeslané pošty neprošla: '+mValidateErr.CommaText);
              mValidateErr.Free;
            end;
          finally
            mPDMObject.Free;
          end;

        except
          if ATransaction then AObjectSpace.RollBack;
          RaiseException(ExceptionMessage);
        end;
      finally

      end;
    end;
  finally
    mValues.Free;
  end;
end;

procedure ShowSelectedForm(ASite: TDynSiteForm; AOIDs: TStrings; AObjCLSID: string);
var
  mPars: TNxParameters;
  mParameter: TNxParameter;
  mListOIDs, mSourceList, mValues: TStrings;
  mSQL: string;
  mRelDef, i, x: integer;
  mObjectSpace: TNxCustomObjectSpace;
begin
  mListOIDs := TStringList.Create;
  mSourceList := TStringList.Create;
  mValues := TStringList.Create;
  try
    if Assigned(AOIDs) then begin
      // naplneni seznamu dle predaneho seznamu
    end
    else begin
      // pro oznacene zaznamy dle relace
      mObjectSpace := ASite.BaseObjectSpace;
      case AObjCLSID of
        'O3BDOKTWEFD13ACM03KIU0CLP4' : mRelDef := 1400; // FV
        '01CPMINJW3DL342X01C0CX3FCC' : mRelDef := 1431; // OP
        '050I5SAOS3DL3ACU03KIU0CLP4' : mRelDef := 1438; // DL
        '0PDOXDMCSZDL3FUD00C5OG4NF4' : mRelDef := 1443; //PRV
      end;
      ASite.FillListWithSelectedRows(mSourceList);
      for i := 0 to mSourceList.Count - 1 do begin
        mSQL := 'select LeftSide_ID from Relations where Rel_Def = %s and RightSide_ID = ''%s''';
        mSQL := Format(mSQL, [IntToStr(mRelDef), mSourceList.Strings[i]]);
        mObjectSpace.SQLSelect(mSQL, mValues);
        for x := 0 to  mValues.Count - 1 do begin
          if mListOIDs.IndexOf(mValues.Strings[x]) = -1 then
            mListOIDs.Add(mValues.Strings[x]);
        end;
      end;
    end;
    if mListOIDs.Count > 0 then begin
      mPars := TNxParameters.Create;
      try
        mPars.NewFromDataType(dtString, '_SelectionCaption', pkUnknown).AsString := 'Odeslaná pošty k vybraným záznamům';
        mParameter := mPars.NewFromDataType(dtList, '_DefaultSelection', pkUnknown);
        mParameter := mParameter.AsList.NewFromDataType(dtList, 'CONDITIONS', pkUnknown);
        mParameter := mParameter.AsList.NewFromDataType(dtList, 'ID', pkUnknown);
        mParameter.AsList.NewFromDataType(dtInteger, 'USEDKIND', pkUnknown).AsInteger := 3; //ckList
        mParameter.AsList.NewFromDataType(dtString, 'VALUELIST', pkUnknown).AsString := NxStringsTockListStr(mListOIDs);
        ASite.ShowDynForm('QVSAA1X2BWEOHH22MEPGEAGI0W', mPars, nil, True, '');
      finally
        mPars.Free;
      end;
    end
    else
      if CFxNxRuntime.NxGetEnvironmentType = reRuntimeExe then ShowMessage('Pro označené záznamy neexistují žádné doklady odeslané pošty.');
  finally
    mListOIDs.Free;
    mSourceList.Free;
    mValues.Free;
  end;
end;

begin
end.