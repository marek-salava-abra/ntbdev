uses 'eu.abra.boma.netcentrum.maildoc';

procedure _BeforeValidate_PreHook(Self: TNxCustomBusinessObject);
begin
  if Length(Self.GetFieldValueAsString('X_ID_transakce_nom'))>0 then begin
    Self.SetFieldValueAsBoolean('X_ID_transakce',True);
    Self.SetFieldValueAsInteger('X_Stav_Dokladu',cNormal);
  end;
  //RaiseException(mOID);
end;


{
Vyvolává se na konci uložení objektu (i v případě výskytu výjimky)
}
{
procedure _FinalizeSave_PreHook(Self: TNxCustomBusinessObject);
//procedure _SaveChildren_PostHook(Self: TNxCustomBusinessObject);
var
  mErr: String;
  mCon: TNxContext;
begin
  mErr:='';
  if Self.GetFieldValueAsString('DocQueue_ID')=cOPN then begin
    if Self.GetFieldValueAsInteger('X_WEB_Stav_Dokladu')=5 then begin
      mCon:=NxCreateContext_1(Self);
      try
        if not(CreateAndSendbyINI(mCon, Self, 5, mErr, Self.GetFieldValueAsString('X_WEB_Email'))) then Self.SetFieldValueAsString('X_SendMail_Note',mErr);
      finally
        mCon.Free;
      end;
    end;
  end;
end;
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
  // kontrola na správné vyplnění řady dokladu
  if (not(Self.GetFieldValueAsString('Firm_ID')=cFirm_ID) and
      ((Self.GetFieldValueAsString('DocQueue_ID')=cOPN) or
        (Self.GetFieldValueAsString('DocQueue_ID')=cOPRN))) or
     ((Self.GetFieldValueAsString('Firm_ID')=cFirm_ID) and
      not((Self.GetFieldValueAsString('DocQueue_ID')=cOPN) or
        (Self.GetFieldValueAsString('DocQueue_ID')=cOPRN))) then begin
    Self.AddValidateError(Self.GetFieldCode('Firm_ID'),cErrText);
    AResult:=False;
  end;
end;

procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
  mMon: TNxCustomBusinessMonikerCollection;
  mCard: TNxCustomBusinessObject;
  i: Integer;
begin
  if (Self.GetFieldValueAsInteger('X_WEB_Stav_Dokladu')<>1) then exit;
  if (Self.GetFieldValueAsString('Firm_ID')=cFirm_ID) and
     (Length(Self.GetFieldValueAsString('X_WEB_OrgIdentNumber'))>0) and
     (Self.GetFieldValueAsInteger('X_WEB_Stav_Dokladu')=1) then
  begin
    //je to firma, musíme exportovat do G3
    exportFirm(Self, cFirmsPath);
  end;
  if Self.GetFieldValueAsString('Firm_ID')=cFirmTS_ID then
  begin
    if (Length(Self.GetFieldValueAsString('X_WEB_OrgIdentNumber'))>0) then
      exportFirm(Self, cFirmsPathTS);
    mMon := Self.GetLoadedCollectionMonikerForFieldCode(Self.GetFieldCode('Rows'));
    for i:= 0 to mMon.Count -1 do
    begin
      if mMon.BusinessObject[i].GetFieldValueAsInteger('RowType') = 3 then
      begin
        exportCards(mMon.BusinessObject[i].GetMonikerForFieldCode(mMon.BusinessObject[i].GetFieldCode('StoreCard_ID')).BusinessObject, cCardsPathTS);
      end;
    end;
  end;
end;

procedure exportCards(Self: TNxCustomBusinessObject; aPath: String);
var
  myXML: TNxScriptingXMLWrapper;
  mCardList: TStringList;
begin
  myXML := TNxScriptingXMLWrapper.Create;
  mCardList:= TStringList.Create;
  try
    myXML.CreateEmpty('StoreCard');
    myXML.setElementAsString('Code',Self.GetFieldValueAsString('Code'));
    myXML.setElementAsString('Name',Self.GetFieldValueAsString('Name'));
    myXML.setElementAsString('EAN',Self.GetFieldValueAsString('EAN'));
    myXML.setElementAsString('GuaranteeLength',Self.GetFieldValueAsString('GuaranteeLength'));
    myXML.setElementAsString('GuaranteeLengthCorporate',Self.GetFieldValueAsString('GuaranteeLengthCorporate'));
    myXML.setElementAsString('GuaranteeUnitName',Self.GetFieldValueAsString('GuaranteeUnitName'));
    myXML.setElementAsString('GuaranteeUnitNameCorporate',Self.GetFieldValueAsString('GuaranteeUnitNameCorporate'));
    myXML.setElementAsString('IntrastatCommodity_ID',Self.GetFieldValueAsString('IntrastatCommodity_ID.Code'));
    myXML.setElementAsString('IntrastatCurrentPrice',Self.GetFieldValueAsString('IntrastatCurrentPrice'));
    myXML.setElementAsString('IntrastatCurrentPriceLimit',Self.GetFieldValueAsString('IntrastatCurrentPriceLimit'));
    myXML.setElementAsString('IntrastatExtraType_ID',Self.GetFieldValueAsString('IntrastatExtraType_ID'));
    myXML.setElementAsString('IntrastatInputStatistic_ID',Self.GetFieldValueAsString('IntrastatInputStatistic_ID'));
    myXML.setElementAsString('IntrastatOutputStatistic_ID',Self.GetFieldValueAsString('IntrastatOutputStatistic_ID'));
    myXML.setElementAsString('IntrastatRegion_ID',Self.GetFieldValueAsString('IntrastatRegion_ID'));
    myXML.setElementAsString('IntrastatUnitCode',Self.GetFieldValueAsString('IntrastatUnitCode'));
    myXML.setElementAsString('IntrastatUnitRate',Self.GetFieldValueAsString('IntrastatUnitRate'));
    myXML.setElementAsString('IntrastatUnitRateRef',Self.GetFieldValueAsString('IntrastatUnitRateRef'));
    myXML.setElementAsString('IntrastatWeight',Self.GetFieldValueAsString('IntrastatWeight'));
    myXML.setElementAsString('IntrastatWeightUnit',Self.GetFieldValueAsString('IntrastatWeightUnit'));
    myXML.setElementAsString('VATRate',Self.GetFieldValueAsString('VATRate'));
    myXML.setElementAsString('VATRate_ID',Self.GetFieldValueAsString('VATRate_ID'));
//    myXML.setElementAsString('X_WEB_USER',Self.GetFieldValueAsString('X_WEB_USER'));
//    myXML.setElementAsString('X_WEB_VATIdentNumber',Self.GetFieldValueAsString('X_WEB_VATIdentNumber'));
//      myXML.setElementAsString('ID', Self.GetFieldValueAsString('Firm_ID')

    if not FileExists(NxAddSlash(aPath)+Self.OID+'.XML') then myXML.saveToFile(NxAddSlash(aPath)+Self.OID+'.XML');

//    if FileExists(NxAddSlash(aPath)+ 'ListOfCards.tsl') then mCardList.LoadFromFile(NxAddSlash(aPath)+'ListOfCards.tsl');
//    if mCardList.IndexOf(Self.OID) = -1 then
//    begin
//      mCardList.Append(Self.OID+'.XML');
//      myXML.saveToFile(NxAddSlash(aPath)+Self.OID+'.XML');
//      mCardList.SaveToFile(NxAddSlash(aPath)+'ListOfCards.tsl');
//    end;
  finally
    myXML.Free;
    mCardList.Free;
  end;
end;

procedure exportFirm(Self: TNxCustomBusinessObject; aPath: String);
var
  myXML: TNxScriptingXMLWrapper;
  mDirList: TStringList;
begin
  myXML := TNxScriptingXMLWrapper.Create;
  mDirList := TStringList.Create;
  try
    myXML.CreateEmpty('Firm');
    myXML.setElementAsString('X_Poznamka_web',Self.GetFieldValueAsString('X_Poznamka_web'));
    myXML.setElementAsString('X_WEB_DCity',Self.GetFieldValueAsString('X_WEB_DCity'));
    myXML.setElementAsString('X_WEB_DCountry',Self.GetFieldValueAsString('X_WEB_DCountry'));
    myXML.setElementAsString('X_WEB_DFirm',Self.GetFieldValueAsString('X_WEB_DFirm'));
    myXML.setElementAsString('X_WEB_DFirm_xx',Self.GetFieldValueAsString('X_WEB_DFirm_xx'));
    myXML.setElementAsString('X_WEB_DName',Self.GetFieldValueAsString('X_WEB_DName'));
    myXML.setElementAsString('X_WEB_DPostCode',Self.GetFieldValueAsString('X_WEB_DPostCode'));
    myXML.setElementAsString('X_WEB_DStreet',Self.GetFieldValueAsString('X_WEB_DStreet'));
    myXML.setElementAsString('X_WEB_Email',Self.GetFieldValueAsString('X_WEB_Email'));
    myXML.setElementAsString('X_WEB_Firm',Self.GetFieldValueAsString('X_WEB_Firm'));
    myXML.setElementAsString('X_WEB_Firm_xx',Self.GetFieldValueAsString('X_WEB_Firm_xx'));
    myXML.setElementAsString('X_Web_ICD',Self.GetFieldValueAsString('X_Web_ICD'));
    myXML.setElementAsString('X_WEB_IICity',Self.GetFieldValueAsString('X_WEB_IICity'));
    myXML.setElementAsString('X_WEB_IICountry',Self.GetFieldValueAsString('X_WEB_IICountry'));
    myXML.setElementAsString('X_WEB_IIName',Self.GetFieldValueAsString('X_WEB_IIName'));
    myXML.setElementAsString('X_WEB_IIPostCode',Self.GetFieldValueAsString('X_WEB_IIPostCode'));
    myXML.setElementAsString('X_WEB_IIStreet',Self.GetFieldValueAsString('X_WEB_IIStreet'));
    myXML.setElementAsString('X_WEB_OrgIdentNumber',Self.GetFieldValueAsString('X_WEB_OrgIdentNumber'));
    myXML.setElementAsString('X_WEB_Phone',Self.GetFieldValueAsString('X_WEB_Phone'));
    myXML.setElementAsString('X_WEB_Stav_Dokladu',Self.GetFieldValueAsString('X_WEB_Stav_Dokladu'));
    myXML.setElementAsString('X_WEB_USER',Self.GetFieldValueAsString('X_WEB_USER'));
    myXML.setElementAsString('X_WEB_VATIdentNumber',Self.GetFieldValueAsString('X_WEB_VATIdentNumber'));
//      myXML.setElementAsString('ID', Self.GetFieldValueAsString('Firm_ID')
    if FileExists(NxAddSlash(aPath)+ 'ListOfFirms.tsl') then mDirList.LoadFromFile(NxAddSlash(aPath)+'ListOfFirms.tsl');
    mDirList.Append(Self.GetFieldValueAsString('X_WEB_OrgIdentNumber')+'.XML');
    myXML.saveToFile(NxAddSlash(aPath)+Self.GetFieldValueAsString('X_WEB_OrgIdentNumber')+'.XML');
    mDirList.SaveToFile(NxAddSlash(aPath)+'ListOfFirms.tsl');
  finally
    myXML.Free;
    mDirList.Free;
  end;
end;

begin
end.