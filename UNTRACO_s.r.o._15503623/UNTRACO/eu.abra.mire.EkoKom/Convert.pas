uses
  'eu.abra.mire.EkoKom.Settings',
  'eu.abra.mire.EkoKom.Lib',
  'eu.abra.mire.EkoKom.Progress';

{
  Převede nastavení obalů ze staré verze EKOKOM 2021
}
procedure DataConversion(ASite : TSiteForm; ASpace : TNxCustomObjectSpace);
var
  mData : TMemoryDataset;
  mCnt : Integer;
  i : Integer;
  mConvertCount: Integer;
begin
  mConvertCount := 0;
  InitSettings(ASpace);

  if NxMessageBox(Application.Title, 'Opravdu chcete zahájit převod dat ze staré verze výkazů pro EKO-KOM 2021 a vyšší?',
                  mdConfirm, mdbYesNo, 0, nil, false, ASite) <> mrYes
  then begin
    Exit;
  end;

  if not IsConvertDataAvailable(ASpace) then
  begin
    NxShowSimpleMessage('Tato funkce slouží k převodu nastavení obalů ze staré verze výkazů pro EKO-KOM. ' +
      'Ve vašem systému však nebyla tato verze instalována.', ASite);
    Exit;
  end;

  // Zahájíme převod
  ProgressInit(ASite, 'Převod nastavení...', 10);

  mData := TMemoryDataset.Create(nil);

  try
    ProgressSetPos(0);

    i := 0;
    mCnt := StrToInt(GetDataScalar(ASpace, 'SELECT COUNT(*) FROM STORECARDS WHERE X_EKO_MaterialObalu = 0 AND Category = 4', '0'));
    if mCnt > 0 then
    begin
      ProgressSetMax(mCnt + 1);
      ProgressSetPos(1);
      ASpace.SQLSelect2('SELECT ID FROM STORECARDS WHERE X_EKO_MaterialObalu = 0 AND Category = 4', mData);
      mData.First();
      while not mData.EOF do
      begin
        if DataConversion_Convert(ASpace, mData.FieldByName('ID').AsString) then
          mConvertCount := mConvertCount + 1;
        mData.Next();
        i := i + 1;
        ProgressSetPos(1 + i);
      end;
    end;

    if mConvertCount > 0 then
      NxShowSimpleMessage('Převod nastavení obalů byl dokončen.'  + #13#10 +
                          'Bylo převedeno ' + IntToStr(mConvertCount) + ' záznamů.' + #13#10 +
                          'Převod se pokusil nastavit některé nové položky, které bylo možné vyplnit.' + #13#10 + #13#10 +
                          'Prosím, proveďte kontrolu a případné doplnění položek na záložkách "EKO-KOM" a "Formuláře" ("EKO-KOM v2") v agendě skladové karty.' , ASite)
    else
      NxShowSimpleMessage('Nebyly nalezeny žádné záznamy k opravě nastavení obalů.', ASite);

  finally
    ProgressDispose();
    mData.Free();
  end;

end;

function DataConversion_Convert(ASpace: TNxCustomObjectSpace; AID: string): Boolean;
var
  mStoreCard: TNxCustomBusinessObject;
  mValid : Boolean;
  mMaterial: Integer;
  mSkupinaMaterialu: Integer;
  mObsahujeNapoje: Boolean;
  mBarvaNapojovehoObalu: Integer;
  mBarva: Integer;
  mOldMaterial: Integer;
  mObjem: Integer;
  mDruhNapojovehoObalu: Integer;
begin
  mStoreCard := ASpace.CreateObject(Class_StoreCard);
  Result := False;
  try
    mStoreCard.Load(AID, nil);
    mMaterial := mStoreCard.GetFieldValueAsInteger('X_EKO_MaterialObalu');
    if mMaterial = 0 then //Pokud je materiál obalu již zadán, nebudeme měnit nastavení - nastavení již změnil uživatel
    begin
      //Načteme potřebné položky
      mOldMaterial := mStoreCard.GetFieldValueAsInteger('X_EKO_Material');
      mObjem := mStoreCard.GetFieldValueAsInteger('X_EKO_Objem');
      mDruhNapojovehoObalu := mStoreCard.GetFieldValueAsInteger('X_EKO_DruhNapojovehoObalu');
      mBarvaNapojovehoObalu := mStoreCard.GetFieldValueAsInteger('X_EKO_BarvaNapojovehoObalu');
      //Provedeme konverzi nových položek
      mMaterial := DataConversion_ConvertMaterial(mOldMaterial);
      if mMaterial > 0 then //Pokud je materiál nulový, nemá smysl pokračovat v konverzi ostatních položek
      begin
        mSkupinaMaterialu := DataConversion_ConvertGroupMaterial(mOldMaterial, mObjem);
        mBarva := DataConversion_ConvertColor(mBarvaNapojovehoObalu);
        mObsahujeNapoje := DataConversion_ConvertContainsDrinks(mDruhNapojovehoObalu);

        mStoreCard.SetFieldValueAsInteger('X_EKO_MaterialObalu', mMaterial);
        mStoreCard.SetFieldValueAsInteger('X_EKO_SkupinaMaterialu', mSkupinaMaterialu);
        mStoreCard.SetFieldValueAsInteger('X_EKO_BarvaObalu', mBarva);
        mStoreCard.SetFieldValueAsBoolean('X_EKO_ObsahujeNapoje', mObsahujeNapoje);

        mStoreCard.Save();
        Result := True;
      end;
    end;
  finally
    mStoreCard.Free();
  end;
end;
{
  Na základě původního materiálu vrátí nový materiál
}
function DataConversion_ConvertMaterial(AOldMaterial: Integer): Integer;
begin
  case AOldMaterial of
    0, 6, 12: //Plasty PET
      Result := 1;
    1, 7, 13: //Plasty PE
      Result := 2;
    2, 8, 14: //Plasty PVC
      Result := 7;
    3, 9, 15: //Plasty PP
      Result := 3;
    4, 10, 16: //Plasty PS
      Result := 4;
    5, 11, 17: //Plasty jiné
      Result := 8;
    18: //Papír - vlnitá lepenka
      Result := 20;
    19: //Papír
      Result := 18;
    20: //Sklo
      Result := 17;
    21, 23, 30: //Kovy FE
      Result := 12;
    22, 24, 31: //Kovy AL
      Result := 11;
    25: //Nápojový karton
      Result := 15;
    26: //Kompozitní materiál
      Result := 16;
    27: //Dřevo a dřevotříska
      Result := 23;
    28: //Textil
      Result := 25;
    29: //Jiné
      Result := 26;
    else
      Result := 0;
  end;
end;

{
  Na základě původního materiálu se pokusí vrátit skupinu materiálu
}
function DataConversion_ConvertGroupMaterial(AOldMaterial, AObjem: Integer): Integer;
begin
  if AObjem = 1 then
    Result := 1 //Nápojový obal do 3 litrů
  else if AObjem = 2 then
    Result := 2 //Nápojový obal nad 3 litry
  else if (AOldMaterial < 6) or (AOldMaterial = 28) then
    Result := 0 //Měkké plasty
  else if ((AOldMaterial > 11) and (AOldMaterial < 18)) or ((AOldMaterial > 22) and (AOldMaterial < 25))then
    Result := 2 //Pevné duté plasty nad 5L a Kovy nad 5L
  else
    Result := 1;
end;

{
  Na základě vyplnění druhu nápojového obalu vrací hodnotu položky X_EKO_ObsahujeNapoje
}
function DataConversion_ConvertContainsDrinks(ADruhNapojovehoObalu: Integer): Boolean;
begin
  if ADruhNapojovehoObalu > 0 then
    Result := True
  else
    Result := False;
end;

{
  Na základě vyplnění dbarvy nápojového obalu vrací hodnotu položky X_EKO_BarvaObalu
}
function DataConversion_ConvertColor(ABarvaNapojovehoObalu: Integer): Integer;
begin
  if ABarvaNapojovehoObalu = 1 then
    Result := 1
  else
    Result := 0;
end;

{
  Převede nastavení ze staré verze EKOKOM
}
procedure ConvertSettings(ASite : TSiteForm; ASpace : TNxCustomObjectSpace);
var
  mSQL : string;
  mData : TMemoryDataset;
  mCnt : Integer;
  mInvalidCards : TStringList;
  mStoreCardID : string;
  i : Integer;

begin

  InitSettings(ASpace);


  if NxMessageBox(Application.Title, 'Opravdu chcete zahájit převod nastavení ze staré verze výkazů pro EKO-KOM?',
                  mdConfirm, mdbYesNo, 0, nil, false, ASite) <> mrYes
//    MessageDlg(
//    'Opravdu chcete zahájit převod nastavení ze staré verze výkazů pro EKO-KOM?',
//    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
  then begin
    Exit;
  end;

  if not IsConvertAvailable(ASpace) then
  begin
    NxShowSimpleMessage('Tato funkce slouží k převodu nastavení obalů ze staré verze výkazů pro EKO-KOM. ' +
      'Ve vašem systému však nebyla tato verze instalována.', ASite);
    Exit;
  end;

  if NxMessageBox(Application.Title, 'Přejete si před zahájením převodu odstranit stávající nastavení obalů pro novou verzi výkazů EKO-KOM? ',
                 mdConfirm, mdbYesNo, 0, nil, false, ASite) = mrYes
//  MessageDlg(
//    'Přejete si před zahájením převodu odstranit stávající nastavení obalů pro novou verzi výkazů EKO-KOM? ',
//    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  then begin
    ASpace.SQLExecute('DELETE FROM DefRollData WHERE CLSID = ' + QuotedStr(Class_EKOKOM) +
      ' AND Code <> ' + QuotedStr(cSettingsCode));
  end;

  // Zahájíme převod
  ProgressInit(ASite, 'Převod nastavení...', 10);

  mData := TMemoryDataset.Create(nil);
  mInvalidCards := TStringList.Create();

  try
    ProgressSetPos(0);

    i := 0;
    mCnt := StrToInt(GetDataScalar(ASpace,
      'SELECT COUNT(*) FROM StoreContainers WHERE X_Hmotnost_obalu > 0', '0'));

    if mCnt > 0 then
    begin
      ProgressSetMax(mCnt + 1);
      ProgressSetPos(1);

      ASpace.SQLSelect2(
        'SELECT ID FROM StoreContainers WHERE X_Hmotnost_obalu > 0', mData);

      mData.First();

      while not mData.EOF do
      begin
        if not ConvertContainer(ASpace, mData.FieldByName('ID').AsString, mStoreCardID) then
          mInvalidCards.Add(QuotedStr(mStoreCardID));

        mData.Next();
        i := i + 1;

        ProgressSetPos(1 + i);
      end;
    end;

    if mInvalidCards.Count = 0 then
      NxShowSimpleMessage('Převod nastavení byl dokončen. Bylo převedeno ' + IntToStr(mCnt) + ' záznamů.', ASite)
    else
    begin
      NxShowSimpleMessage('Převod nastavení byl dokončen. Bylo úspěšně převedeno ' + IntToStr(mCnt) + ' záznamů. ' + #13#10 +
        'Během převodu bylo nalezeno ' + IntToStr(mInvalidCards.Count) +
        ' chybně nastavených obalů. Zkontrolujte obaly těchto skladových karet a případně opravte jejich nastavení.', ASite);

      NxShowSite('W31KWYTC5FDL342M01C0CX3FCC',
        ASite.SiteContext, nil, nil, 0, False,
        'FilterByUserDynSQLCondition;A.ID IN (' + mInvalidCards.DelimitedText + ')');
    end;

  finally
    ProgressDispose();
    mData.Free();
    mInvalidCards.Free();
  end;

end;

{
  Převede nastavení z obalu jednotky, do obalu EKOKOM.
}
function ConvertContainer(ASpace : TNxCustomObjectSpace; AID : string; var AStoreCardID : string) : Boolean;
const
  cSQLUpdate = 'update storecards sc set sc.hidden = ''N'' where sc.hidden = ''A'' and sc.id =';
  cSQLUpdateBack = 'update storecards sc set sc.hidden = ''A'' where sc.hidden = ''N'' and sc.id =';
var
  mSrc : TNxCustomBusinessObject;
  mDest : TNxCustomBusinessObject;
  mCardCon: TNxCustomBusinessObject;
  mValid : Boolean;
  mIsSCHidden, mIsSCConHidden : boolean;
begin

  mSrc := ASpace.CreateObject(Class_StoreContainer);
  mDest := ASpace.CreateObject(Class_EKOKOM);
  mCardCon := ASpace.CreateObject(Class_StoreCard);
  mValid := True;

  try
    mSrc.Load(AID, nil);
    mIsSCConHidden := mSrc.GetFieldValueAsBoolean('StoreCard_ID.Hidden');
    if mIsSCConHidden then
      ASpace.SQLExecute(cSQLUpdate+QuotedStr(mSrc.GetFieldValueAsString('StoreCard_ID')));

    mCardCon.Load(mSrc.GetFieldValueAsString('StoreCard_ID'), nil);

    mDest.New();

    AStoreCardID := mSrc.GetFieldValueAsString('Parent_ID.Parent_ID');

    mIsSCHidden := mSrc.GetFieldValueAsBoolean('Parent_ID.Parent_ID.Hidden');
    if mIsSCHidden then
      ASpace.SQLExecute(cSQLUpdate+QuotedStr(AStoreCardID));

    mDest.SetFieldValueAsString('X_EKO_StoreCard_ID', AStoreCardID);
    mDest.SetFieldValueAsString('X_EKO_StoreCardUnit', mSrc.GetFieldValueAsString('Parent_ID.Code'));
    mDest.SetFieldValueAsString('X_EKO_ContainerStoreCard_ID', mCardCon.OID);

    // Typ obchodu
    if mSrc.GetFieldValueAsInteger('X_Typ_Obchodu') > 0 then
    begin
      if mSrc.GetFieldValueAsInteger('X_Typ_Obchodu') <= 9 then
        mDest.SetFieldValueAsInteger('X_EKO_TypObchodu', 0)
      else
        mDest.SetFieldValueAsInteger('X_EKO_TypObchodu', 1);

      // Způsob užití
      if mSrc.GetFieldValueAsInteger('X_Typ_Obchodu') <= 9 then
        mDest.SetFieldValueAsInteger('X_EKO_ZpusobUziti', (mSrc.GetFieldValueAsInteger('X_Typ_Obchodu') - 1) div 3)
      else
        mDest.SetFieldValueAsInteger('X_EKO_ZpusobUziti', 0);

      // Způsob uvedení
      mDest.SetFieldValueAsInteger('X_EKO_ZpusobUvedeni', (mSrc.GetFieldValueAsInteger('X_Typ_Obchodu') - 1) mod 3);
    end
    else
      mValid := False;

    // Zpoplatnění
    if mSrc.GetFieldValueAsInteger('X_Sesit') > 0 then
      mDest.SetFieldValueAsInteger('X_EKO_ZpoplatneniObalu', mSrc.GetFieldValueAsInteger('X_Sesit') - 1)
    else
      mValid := False;

    // Opakovaně používaný
    mDest.SetFieldValueAsInteger('X_EKO_OpakovanePouzivany', 0);

    mDest.SetFieldValueAsFloat('X_EKO_UnitQuantity', mSrc.GetFieldValueAsFloat('UnitQuantity'));
    mDest.SetFieldValueAsFloat('X_EKO_Hmotnost', mSrc.GetFieldValueAsFloat('X_Hmotnost_obalu'));

    if mSrc.GetFieldValueAsFloat('UnitQuantity') = 0 then
      mValid := False;

    mDest.Save();

    if mSrc.GetFieldValueAsInteger('X_Typ_Obalu') > 0 then
    begin
      mCardCon.SetFieldValueAsInteger('X_EKO_Material', mSrc.GetFieldValueAsInteger('X_Typ_Obalu') - 1);
      mCardCon.Save();
    end;

  finally
    if mIsSCHidden then
      ASpace.SQLExecute(cSQLUpdateBack+QuotedStr(AStoreCardID));
    if mIsSCConHidden then
      ASpace.SQLExecute(cSQLUpdateBack+QuotedStr(mCardCon.OID));
    mSrc.Free();
    mDest.Free();
    mCardCon.Free();
  end;

  Result := mValid;

end;


{
  Vrací true pokud je dostupný převod nastavení ze staré verze
}
function IsConvertAvailable(ASpace : TNxCustomObjectSpace) : Boolean;
var
  mContainer : TNxCustomBusinessObject;
  mList : TStringList;
begin

  mList := TStringList.Create();
  mContainer := ASpace.CreateObject(Class_StoreContainer);

  try
    mContainer.GetUserFieldNames(mList, True);
    Result := mList.IndexOf('X_Typ_Obalu') <> -1;
  finally
    mContainer.Free();
    mList.Free();
  end;
end;

{
  Vrací true pokud je dostupný převod nastavení dat ze staré verze (2021)
}
function IsConvertDataAvailable(ASpace : TNxCustomObjectSpace) : Boolean;
var
  mStoreCard: TNxCustomBusinessObject;
  mList: TStringList;
begin
  mList := TStringList.Create();
  mStoreCard := ASpace.CreateObject(Class_StoreCard);
  try
    mStoreCard.GetUserFieldNames(mList, True);
    Result := mList.IndexOf('X_EKO_MaterialObalu') <> -1;
  finally
    mStoreCard.Free();
    mList.Free();
  end;
end;


begin
end.