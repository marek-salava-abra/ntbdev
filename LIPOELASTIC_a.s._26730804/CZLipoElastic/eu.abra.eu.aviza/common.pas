uses
  'eu.abra.eu.aviza.consts',
  'eu.abra.eu.aviza.libs',
  'eu.abra.eu.aviza.rolls',
  'eu.abra.eu.aviza.xml',
  'eu.abra.eu.aviza.uLicence';

const
  //konstanta s příponami pro jednotlivé tentonoc :]
  cExtensions = [
                 'Soubory TXT (*.txt)|*.txt', {0 - PPL}
                 'Soubory XML (*.xml)|*.xml', {1 - Česká spořitelna}
                 '', {2 - ČSOB}
                 'Soubory TXT (*.txt)|*.txt', {3 - CETELEM}
                 'Soubory TXT (*.txt)|*.txt', {4 - Česká pošta}
                 'Soubory CSV (*.csv)|*.csv', {5 - Pošta bez hranic}
                 'Soubory CSV (*.csv)|*.csv|Soubory TXT (*.txt)|*.txt', {6 - Unicredit Bank}
                 '', {7 - Komerční banka}
                 'Soubory CSV (*.csv)|*.csv' {8 - PayU}
                ];
  cTitle = 'Vyberte soubor s avízy';
  //Fieldy datasetu
  cDatum = 'Datum';
  cVarSymbol = 'Variabilni symbol';
  cVarSymbolRow = 'Variabilni symbol radek';
  cSpecSymbolRow = 'Specificky symbol radek';
  cCisloZasilky = 'Cislo zasilky';
  cCastka = 'Castka';
  cCelaCastka = 'Cela Castka';
  cMena = 'Mena';
  cCredit = 'Kredit';
  cCisloObjednavky = 'Cislo objednavky';
  cAutorizacniKod = 'Autorizacni kod';
  cPoplatky = 'Poplatky';
  cPoplatkyCelkem = 'Poplatky celkem';
  cText = 'Text';
  
  cNoPDM = False; // zda nedohledavat placene doklad faktur pres doklady odeslane posty
  cInDebug = False;
  cUseDebugger = True;
  cAppName = 'eu.abra.rama.aviza';

var
  gLog: TStrings;

procedure ShowDebugMessage(AMessage: Variant);
begin
  if cInDebug then begin
    if cUseDebugger then
      OutputDebugString(Format('%s : %s',[cAppName, VarToStr(AMessage)]))
    else
      ShowMessage(Format('%s : %s',[cAppName, VarToStr(AMessage)]));
  end;
end;

procedure Log(AMessage: String);
begin
  //ShowMessage(AMessage);
  if Assigned(gLog) then
    gLog.Add(AMessage);
end;

procedure MoveToRow(ADynSite: TDynSiteForm; ARowIDs: TStrings);
var
  mParams: TNxParameters;
  mParam: TNxParameter;
begin
  mParams := TNxParameters.Create;
  try
    mParams.NewFromDataType(dtString, '_SelectionCaption', pkUnknown).AsString := 'Rozpadle radky';
    mParam := mParams.NewFromDataType(dtList, '_DefaultSelection', pkUnknown) ;
    mParam := mParam.AsList.NewFromDataType(dtList, 'CONDITIONS', pkUnknown) ;
    mParam := mParam.AsList.NewFromDataType(dtList, 'ID', pkUnknown) ;
    mParam.AsList.NewFromDataType(dtInteger, 'USEDKIND', pkUnknown).AsInteger := 3; //3 = ckList
    mParam.AsList.NewFromDataType(dtString, 'VALUELIST', pkUnknown).AsString := NxStringsToCkListStr(ARowIDs);
    ShowDynForm('YS3KIBIU3544PG40KBQWXWKBAS', ADynSite.SiteContext, mParams, nil, true);
  finally
    mParams.Free;
  end;
end;

function DataSetRowToString(ADataSet: TDataSet): String;
var
  mResult: String;
  i: Integer;
begin
  mResult := '';
  if not ADataSet.Eof then begin
    for i := 0 to ADataSet.FieldCount - 1 do begin
      mResult := mResult + Format('%s - %s', [NxPadR(ADataSet.Fields[i].Name, 30, ' '), VarToStr(ADataSet.Fields[i].AsVariant)]) + #13#10;
    end;
    Result := mResult;
  end;
end;

procedure PrefillDataSetFileds(ADataSet: TDataSet);
begin
  ADataSet.Fields.Clear;
  ADataSet.FieldDefs.Add(cDatum, ftDate);
  ADataSet.FieldDefs.Add(cVarSymbol, ftString, 20);
  ADataSet.FieldDefs.Add(cCisloZasilky, ftString, 20);
  ADataSet.FieldDefs.Add(cCastka, ftFloat, 0);
  ADataSet.FieldDefs.Add(cCelaCastka, ftFloat, 0);
  ADataSet.FieldDefs.Add(cPoplatky, ftFloat, 0);
  ADataSet.FieldDefs.Add(cPoplatkyCelkem, ftFloat, 0);
  ADataSet.FieldDefs.Add(cMena, ftString, 3);
  ADataSet.FieldDefs.Add(cCredit, ftBoolean, 0);
  ADataSet.FieldDefs.Add(cCisloObjednavky, ftString, 24);
  ADataSet.FieldDefs.Add(cAutorizacniKod, ftString, 30);
  ADataSet.FieldDefs.Add(cText, ftString, 50);
  ADataSet.FieldDefs.Add(cVarSymbolRow, ftString, 20);
  ADataSet.FieldDefs.Add(cSpecSymbolRow, ftString, 20);
  ADataSet.Open;
end;

procedure LoadFixedSizeIntoStrings(ALine: String; AStrings: TStrings; ALengths: array of Integer);
var
  i, mCurr, mLen: Integer;
begin
  AStrings.Clear;
  mCurr := 1;
  for i := 0 to Length(ALengths)-1 do begin
    mLen := ALengths[i];
    AStrings.Add(Trim(Copy(ALine, mCurr, mLen)));
    Inc(mCurr, mLen);
  end;
end;

procedure LoadCetelemData(AFileName: String; ADataSet: TDataSet);
var
  mFileLines, mSummaryFields, mHeaderFields, mFields: TStringList;
  i: Integer;
  mLine: String;
begin
  mFileLines := TStringList.Create;
  try
    mFileLines.LoadFromFile(AFileName);
    if mFileLines.Count > 2 then begin
      mSummaryFields := TStringList.Create;
      try
        mHeaderFields := TStringList.Create;
        try
          //Hlavicka
          LoadFixedSizeIntoStrings(mFileLines.Strings[0], mHeaderFields, [1,10,4,10,4,16,6,12,9]);
          //Paticka
          LoadFixedSizeIntoStrings(mFileLines.Strings[mFileLines.Count-1], mSummaryFields, [1,6,12]);
          mFields := TStringList.Create;
          try
            for i := 1 to mFileLines.Count - 2 do begin
              mFields.Clear;
              mLine := mFileLines.Strings[i];
              LoadFixedSizeIntoStrings(mLine, mFields, [1,10,7,8,17,10,10,10,12,3,10,12]);
              ADataSet.Append;
              ADataset.FieldByName(cDatum).AsDateTime := StrToDate(mFields.Strings[1]);
            end;
          finally
            mFields.Free;
          end;
        finally
          mHeaderFields.Free;
        end;
      finally
        mSummaryFields.Free;
      end;
    end;
  finally
    mFileLines.Free;
  end;
end;

procedure LoadMUZOData(AFileName: String; ADataSet: TDataSet);
var
  mFileLines, mFields, mSummaryFields: TStringList;
  mSummaryLine, mLine, mVarSymbol: String;
  i, mLineCode, mSummaryIndex: Integer;

  procedure iFillSummaryForRow(AIndex: Integer);
  var
    mIndex: Integer;
  begin
    if mSummaryIndex < AIndex then begin
      mIndex := AIndex;
      while Copy(mFileLines.Strings[mIndex], 1, 2) <> '04' do
        Inc(mIndex);
      mSummaryIndex := mIndex;
      LoadFixedSizeIntoStrings(mFileLines.Strings[mIndex], mSummaryFields, [2,10,4,16,2,16,16,2]);
    end;
  end;

  function iExtractDate(AString: String): TDateTime;
  begin
    Result := EncodeDate(StrToInt(Copy(AString,1,4)),StrToInt(Copy(AString,5,2)),StrToInt(Copy(AString,7,2)));
  end;

begin
  mSummaryIndex := -1;
  mFileLines := TStringList.Create;
  try
    mSummaryFields := TStringList.Create;
    try
      mFileLines.LoadFromFile(AFileName);
      mFields := TStringList.Create;
      try
        for i := 0 to mFileLines.Count - 1 do begin
          mLine := mFileLines.Strings[i];
          mLineCode := StrToInt(Copy(mLine, 1, 2));
          case mLineCode of
            1 : //Hlavicka - ustredi obchodnika
            begin
              LoadFixedSizeIntoStrings(mLine, mFields, [2,16,30,10,6]);
            end;
            2 : //Hlavicka - obchodni misto
            begin
              LoadFixedSizeIntoStrings(mLine, mFields, [2,16,30,16,20,4]);
            end;
            3 : //Transakce
            begin
              LoadFixedSizeIntoStrings(mLine, mFields, [2,10,6,8,6,9,24,16,2,16,16,2]);
              iFillSummaryForRow(i);
              ADataSet.Append;
              ADataSet.FieldByName(cVarSymbol).AsString := NxTrimL(mFields.Strings[5], '0');
              ADataSet.FieldByName(cMena).AsString := 'CZK';
              ADataSet.FieldByName(cDatum).AsDateTime := iExtractDate(mFields.Strings[3]);
              ADataSet.FieldByName(cCastka).AsFloat := NxIBStrToFloat(mFields.Strings[7]);
              ADataSet.FieldByName(cCredit).AsBoolean := NxCompareText(mFields.Strings[8], 'CR');
              ADataSet.FieldByName(cCisloObjednavky).AsString := mFields.Strings[6];
              ADataSet.FieldByName(cCelaCastka).AsFloat := NxIBStrToFloat(mSummaryFields.Strings[6]);
              ADataSet.FieldByName(cText).AsString := 'Karetní transakce -';
              ADataSet.FieldByName(cVarSymbolRow).AsString := NxTrim(NxTrimL(mFields.Strings[6], '0 '), ' ');
              ADataSet.FieldByName(cPoplatkyCelkem).AsFloat := NxIBStrToFloat(mSummaryFields.Strings[5]);
              ADataSet.FieldByName(cPoplatky).AsFloat := -NxIBStrToFloat(mFields.Strings[9]);
            end;
            4 : //Sumar
            begin
              LoadFixedSizeIntoStrings(mLine, mFields, [2,10,4,16,2,16,16,2]);
            end;
            5 : //Soucet za vypis
            begin
              LoadFixedSizeIntoStrings(mLine, mFields, [2,16,6,13,2,13,13,2]);
            end;
            6 : //Soucet za ustredi obchodnika
            begin
              LoadFixedSizeIntoStrings(mLine, mFields, [2,16,6,13,2,13,13,2]);
            end;
            else
              RaiseException('Nedefinovany typ radku '+QuotedStr(Copy(mLine, 1, 2)));
          end;
        end;
      finally
        mFields.Free;
      end;
    finally
      mSummaryFields.Free;
    end;
  finally
    mFileLines.Free;
  end;
end;

procedure LoadCSData(AFileName: String; ADataSet: TDataSet);
var
  i, j: Integer;
  mCelaCastka, mPoplatky: Double;
  mVarSymbol, mBatchID, mCurrency: String;
  //XML
  mXML: Variant;
  mListSummaryAdvice, mListDetailAdvice: Variant;
  mNode, mSummaryNode,mHeaderNode, mRecordNode: Variant;
begin
  mXML := gLoadXMLFile(AFileName);
  mSummaryNode := mXML.selectSingleNode('//Document/DetailAdvice/Summary');
  //mSummaryNode := mXML.selectSingleNode('//Document/SummaryAdvice/Summary');
    mHeaderNode  := mXML.selectSingleNode('//Document/SummaryAdvice/Record');
  mVarSymbol := mHeaderNode.selectSingleNode('VarSymbol').text;
  mPoplatky := NxIBStrToFloat(mSummaryNode.selectSingleNode('Charge').text);
  //mCelaCastka := NxIBStrToFloat(mSummaryNode.selectSingleNode('Amount').text) - mPoplatky;
  // PESA 2012-08-09 - RONEho oprava RetailAmount vs. Amount
  //mCelaCastka := NxIBStrToFloat(mSummaryNode.selectSingleNode('Amount').text);
  mCelaCastka := NxIBStrToFloat(mSummaryNode.selectSingleNode('RetailAmount').text);

  mListSummaryAdvice := mXML.selectNodes('//Document/DetailAdvice/Record');
  for i := 0 to mListSummaryAdvice.length - 1 do begin
    mNode := mListSummaryAdvice.item[i];
    if CompareText(mNode.nodeName, 'Record')=0 then begin
      ADataSet.Append;
       ADataSet.FieldByName(cVarSymbol).AsString := NxTrimL(mVarSymbol, '0');
      //mVarSymbol := mNode.selectSingleNode('VarSymbol').text;
      //mBatchID := mNode.selectSingleNode('BatchId').text;
      //mCurrency := mNode.selectSingleNode('Currency').text;
      ADataSet.FieldByName(cVarSymbolRow).AsString := mNode.selectSingleNode('CardNo').text;
      ADataSet.FieldByName(cMena).AsString := 'CZK';
      ADataSet.FieldByName(cDatum).AsDateTime := StrToDate(mNode.selectSingleNode('TransDate').text);
      // PESA 2012-08-09 - RONEho oprava RetailAmount vs. Amount
      //ADataSet.FieldByName(cCastka).AsFloat := NxIBStrToFloat(mNode.selectSingleNode('Amount').text);
      ADataSet.FieldByName(cCastka).AsFloat := NxIBStrToFloat(mNode.selectSingleNode('RetailAmount').text);
      ADataSet.FieldByName(cPoplatky).AsFloat := -NxIBStrToFloat(mNode.selectSingleNode('Charge').text);
      ADataSet.FieldByName(cPoplatkyCelkem).AsFloat := -mPoplatky;
      ADataSet.FieldByName(cText).AsString := 'uhrada za karty';
      //mCelaCastka := NxIBStrToFloat(mNode.selectSingleNode('SettleAmount').text);
      ADataSet.FieldByName(cCelaCastka).AsFloat := mCelaCastka;
    end;
  end;
end;

procedure LoadPPLData(AFileName: String; ADataSet: TDataSet);
var
  mFileLines, mLineCols: TStringList;
  mVarSymbol, mLine: String;
  mDate: TDate;
  i: Integer;
  mTotalAmount: Double;
begin
  mFileLines := TStringList.Create;
  try
    mFileLines.LoadFromFile(AFileName);
    mLineCols := TStringList.Create;
    try
      mTotalAmount := 0;
      for i := 0 to mFileLines.Count - 1 do begin
        mLine := mFileLines.Strings[i];
        mLineCols.Clear;
        NxTokenToStrings(mLine, ';', mLineCols);
        if i<>0 then begin
          mTotalAmount := mTotalAmount + StrToFloat(mLineCols.Strings[1]);
        end;
      end;
      for i := 0 to mFileLines.Count - 1 do begin
        mLine := mFileLines.Strings[i];
        mLineCols.Clear;
        NxTokenToStrings(mLine, ';', mLineCols);
        if i=0 then begin
          //hlavicka
          mVarSymbol := mLineCols.Strings[0];
          mDate := StrToDate(mLineCols.Strings[6]);
        end else begin
          //radky
          ADataSet.Append;
          ADataSet.FieldByName(cDatum).AsDateTime := mDate;
          ADataSet.FieldByName(cVarSymbol).AsString := NxTrimL(mVarSymbol, '0');
          ADataSet.FieldByName(cVarSymbolRow).AsString := NxTrimL(mLineCols.Strings[3], '0');
          ADataSet.FieldByName(cCisloZasilky).AsString := mLineCols.Strings[0];
          ADataSet.FieldByName(cCastka).AsFloat := StrToFloat(mLineCols.Strings[1]);
          ADataSet.FieldByName(cMena).AsString := mLineCols.Strings[2];
          ADataSet.FieldByName(cCelaCastka).AsFloat := mTotalAmount;
        end;
      end;
    finally
      mLineCols.Free;
    end;
  finally
    mFileLines.Free;
  end;
end;

procedure VacusPositionToStrings(mLine:String; mLineCols: TStringList;const mRowType:integer);
{RowType 0 - hlavička, 1 - běžný řádek, 2- patička}
const
cMaxRow =  3;
var
 I: integer;
begin
  for i := 0 to cMaxRow do mLineCols.Add('');
  case mRowType of
    0:begin
      mLineCols.Strings[0] := Trim(Copy(mLine,16,10));
      mLineCols.Strings[1] := Trim(Copy(mLine,2,10));
      end;
    1:begin
       mLineCols.Strings[0] := Trim(Copy(mLine,2,13));
       mLineCols.Strings[1] := Trim(Copy(mLine,31,11));
       mLineCols.Strings[2] := 'CZK';
       mLineCols.Strings[3] := Trim(Copy(mLine,42,10));
      end;
  end;
end;

procedure LoadPPLVacusData(AFileName: String; ADataSet: TDataSet);
var
  mFileLines, mLineCols: TStringList;
  mVarSymbol, mLine: String;
  mDate: TDate;
  i: Integer;
  mTotalAmount: Double;
begin
  mFileLines := TStringList.Create;
  try
    mFileLines.LoadFromFile(AFileName);
    mLineCols := TStringList.Create;
    try
      mTotalAmount := 0;
      for i := 1 to mFileLines.Count - 2 do begin
        mLine := mFileLines.Strings[i];
        mLineCols.Clear;
        VacusPositionToStrings(mLine,mLineCols,1);
        if i<>0 then begin
          mTotalAmount := mTotalAmount + StrToFloat(mLineCols.Strings[1]);
        end;
      end;
      for i := 0 to mFileLines.Count - 2 do begin
        mLine := mFileLines.Strings[i];
        mLineCols.Clear;
        if i=0 then begin
          //hlavicka
          VacusPositionToStrings(mLine,mLineCols,0);
          mVarSymbol := mLineCols.Strings[0];
          mDate := StrToDate(mLineCols.Strings[1]);
        end else begin
          //radky
          VacusPositionToStrings(mLine,mLineCols,1);
          ADataSet.Append;
          ADataSet.FieldByName(cDatum).AsDateTime := mDate;
          ADataSet.FieldByName(cVarSymbol).AsString := NxTrimL(mVarSymbol, '0');
          ADataSet.FieldByName(cVarSymbolRow).AsString := NxTrimL(mLineCols.Strings[3], '0');
          ADataSet.FieldByName(cCisloZasilky).AsString := mLineCols.Strings[0];
          ADataSet.FieldByName(cCastka).AsFloat := StrToFloat(mLineCols.Strings[1]);
          ADataSet.FieldByName(cMena).AsString := mLineCols.Strings[2];
          ADataSet.FieldByName(cCelaCastka).AsFloat := mTotalAmount;
        end;
      end;
    finally
      mLineCols.Free;
    end;
  finally
    mFileLines.Free;
  end;
end;

procedure LoadCeskaPostaData(AFileName: String; ADataSet: TDataSet);
var
  mFileLines, mLineCols: TStringList;
  mVarSymbol, mLine, mFileName: String;
  mDate: TDate;
  i, mTypLine: Integer;
  mSecCount, mSecCount2, mTotalCount: integer;
  mTotalAmount, mSecAmount, mSecAmount2, mTmpAmount: Double;
begin
  mFileName := ExtractFileName(AFileName);
  if (UpperCase(Copy(mFileName, 1, 4)) <> 'SBDT') then
    exit;
  mFileLines := TStringList.Create;
  try
    mFileLines.LoadFromFile(AFileName);
    mLineCols := TStringList.Create;
    try
      mTotalAmount := 0;
      mTotalCount := 0;
      for i := 0 to mFileLines.Count - 1 do begin
        mLine := mFileLines[i];
        mTypLine := StrToInt(Copy(mLine, 1, 1));
        {převodová věta
        1	Typ věty	1	vždy "1"
        2	Datum převodu	10	tvar DD.MM.RRRR
        3	Konstantní symbol převodu	4
        4	Variabilní symbol převodu	10
        5	Specifický symbol převodu	10
        6	Kód banky	4
        7	Předčíslí účtu	6
        8	Číslo účtu	10
        9	Počet plateb v převodu	6
        10	Úhrnná částka převodu	12	tvar KKKKKKKKK.HH
        }
        if (mTypLine = 1) then
        begin
          LoadFixedSizeIntoStrings(mLine, mLineCols, [1,10,4,10,10,4,6,10,6,12]);
          if (i <> 0) then
          begin
            if (mSecCount <> mSecCount2) then
              RaiseException('Počet plateb v sekci se liší.');
            if (mSecAmount <> mSecAmount2) then
              RaiseException('Souhrnná částka plateb v sekci se liší.');
          end;
          mSecAmount := CFxFloat.StrToFloat(mLineCols[9], '.');
          mSecCount := StrToInt(mLineCols[8]);
          mSecAmount2 := 0;
          mSecCount2 := 0;
        end
        {platební věta
        1	Typ věty	1	vždy "2"
        2	ID číslo zásilky	13
        3	Pošta dodání	6
        4	Datum dodání	10	tvar DD.MM.RRRR
        5	Částka platby	11	tvar KKKKKKKK.HH
        6	Variabilní symbol	10
        7	Specifický symbol	10
        }
        else if (mTypLine = 2) then
        begin
          LoadFixedSizeIntoStrings(mLine, mLineCols, [1,13,6,10,11,10,10]);
          mSecCount2 := mSecCount2 + 1;
          mTotalCount := mTotalCount + 1;
          mTmpAmount := CFxFloat.StrToFloat(mLineCols[4], '.');
          mSecAmount2 := mSecAmount2 + mTmpAmount;
          mTotalAmount := mTotalAmount + mTmpAmount;
        end
        {kontrolní věta
        1	Typ věty	1	vždy "3"
        2	Počet platebních vět v souboru	6
        3	Celková suma plateb	12	tvar KKKKKKKKK.HH
        }
        else if (mTypLine = 3) then
        begin
          LoadFixedSizeIntoStrings(mLine, mLineCols, [1,6,12]);
          if (mTotalCount <> StrToInt(mLineCols[1])) then
            RaiseException('Počet plateb v souboru se liší.');
          if (mTotalAmount <> CFxFloat.StrToFloat(mLineCols[2], '.')) then
            RaiseException('Souhrnná částka plateb v souboru se liší.');
        end;
      end;

      for i := 0 to mFileLines.Count - 1 do begin
        mLine := mFileLines[i];
        mTypLine := StrToInt(Copy(mLine, 1, 1));
        if (mTypLine = 1) then
        begin
          LoadFixedSizeIntoStrings(mLine, mLineCols, [1,10,4,10,10,4,6,10,6,12]);
          mDate := CFxDate.StrToDateEx(mLineCols[1], 'dd.mm.yyyy', '.');
          mVarSymbol := mLineCols[3];
          mSecAmount := CFxFloat.StrToFloat(mLineCols[9], '.');
        end
        else if (mTypLine = 2) then
        begin
          LoadFixedSizeIntoStrings(mLine, mLineCols, [1,13,6,10,11,10,10]);
          ADataSet.Append;
          ADataSet.FieldByName(cDatum).AsDateTime := mDate;
          ADataSet.FieldByName(cVarSymbol).AsString := NxTrimL(mVarSymbol, '0');
          ADataSet.FieldByName(cVarSymbolRow).AsString := NxTrimL(mLineCols[5], '0');
          ADataSet.FieldByName(cSpecSymbolRow).AsString := NxTrimL(mLineCols[6], '0');
          ADataSet.FieldByName(cCisloZasilky).AsString := mLineCols[1];
          ADataSet.FieldByName(cCastka).AsFloat := CFxFloat.StrToFloat(mLineCols[4], '.');
          ADataSet.FieldByName(cMena).AsString := 'CZK';
          ADataSet.FieldByName(cCelaCastka).AsFloat := mSecAmount;
        end;
      end;
    finally
      mLineCols.Free;
    end;
  finally
    mFileLines.Free;
  end;
end;

procedure LoadPostaBezHranicData(AFileName: String; ADataSet: TDataSet; AOS: TNxCustomObjectSpace);
var
  mFileLines, mLineCols: TStringList;
  mVarSymbol, mLine: String;
  mDate: TDate;
  i: Integer;
  mTotalAmount: Double;
begin
  mFileLines := TStringList.Create;
  try
    mFileLines.LoadFromFile(AFileName);
    mLineCols := TStringList.Create;
    try
      mTotalAmount := 0;
      for i := 1 to mFileLines.Count - 1 do begin
        mLine := mFileLines.Strings[i];
        mLineCols.Clear;
        NxTokenToStrings(mLine, ';', mLineCols);
        if i<>0 then begin
          mTotalAmount := mTotalAmount + StrToFloat(mLineCols.Strings[2]);
        end;
      end;
      for i := 1 to mFileLines.Count - 1 do begin
        mLine := mFileLines.Strings[i];
        mLineCols.Clear;
        NxTokenToStrings(mLine, ';', mLineCols);
        ADataSet.Append;
        ADataSet.FieldByName(cDatum).AsDateTime := CFxDate.StrToDateEx(mLineCols[4], 'dd.mm.yyyy', '.');
        ADataSet.FieldByName(cVarSymbol).AsString := NxTrimL(mLineCols[0], '0');
        ADataSet.FieldByName(cVarSymbolRow).AsString := NxTrimL(mLineCols[3], '0');
        ADataSet.FieldByName(cCisloZasilky).AsString := mLineCols[1];
        ADataSet.FieldByName(cCastka).AsFloat := StrToFloat(mLineCols[2]);
        ADataSet.FieldByName(cMena).AsString := GetFirstSQLResult('Select Cu.Code from Countries Co join Currencies Cu on Cu.ID = Co.Currency_ID where Co.Code = '+QuotedStr(UpperCase(mLineCols[5])),AOS);
        ADataSet.FieldByName(cCelaCastka).AsFloat := mTotalAmount;
      end;
    finally
      mLineCols.Free;
    end;
  finally
    mFileLines.Free;
  end;
end;

procedure LoadUnicreditBankData(AFileName: String; ADataSet: TDataSet);
var
  mFileLines, mLineCols: TStringList;
  mVarSymbol, mLine: String;
  i,j: Integer;
  mTotalAmount, mPoplatky: Double;
  mSeparator : string;
  mMena, mTmp: string;
  mIsSum: Boolean;
begin
  mFileLines := TStringList.Create;
  try
    mSeparator := '';
    if UpperCase(ExtractFileExt(AFileName)) = '.CSV' then
      mSeparator := ';'
    else if UpperCase(ExtractFileExt(AFileName)) = '.TXT' then
      mSeparator := chr(9);
    if mSeparator = '' then
      RaiseException('Jsou povolené jen soubory s příponami *.txt a *.csv.');
    mFileLines.LoadFromFile(AFileName);
    mLineCols := TStringList.Create;
    try
      mTotalAmount := 0;
      for i := 0 to mFileLines.Count - 1 do begin
        mLine := mFileLines[i];
        mLineCols.Clear;
        NxTrapStrToStrings(mLine, mSeparator, mLineCols);
        if (mLineCols.Count = 0) then continue;
        if (mLineCols[0] = 'SUM') then begin
          mIsSUM := true;
          for j:= 2 to 16 do begin
            mIsSUM := (mIsSUM and (mLineCols[j] = ''));
            if not mIsSUM then break;
          end;
          if mIsSUM then begin
            //celková částka je 17, poplatky 18 a částka po odečtení poplatků 19
            mTmp := StringReplace(mLineCols[17],',','', [rfReplaceAll,rfIgnoreCase]);
            mTotalAmount := mTotalAmount + CFxFloat.StrToFloat(mTmp,'.');
            mTmp := StringReplace(mLineCols[18],',','', [rfReplaceAll,rfIgnoreCase]);
            mPoplatky := mPoplatky + CFxFloat.StrToFloat(mTmp,'.');
          end;
        end;
      end;
      mMena := '';
      //prvni dva radky jsou NAM to nas nemusi ted zajimat
      for i := 2 to mFileLines.Count - 1 do begin
        mLine := mFileLines[i];
        mLineCols.Clear;
        NxTrapStrToStrings(mLine, mSeparator, mLineCols);
        if (mLineCols.Count = 0) then continue;
        if (mLineCols[0] = 'STA') then begin
          mMena := mLineCols[4];
        end else if (mLineCols[0] = 'TRA') then begin
          ADataSet.Append;
          ADataSet.FieldByName(cDatum).AsDateTime := CFxDate.StrToDateEx(mLineCols[4], 'dd/mm/yyyy', '/');
          ADataSet.FieldByName(cVarSymbolRow).AsString := NxTrimL(mLineCols[7], '0');
          //celková částka je 8, poplatky 9 a částka po odečtení poplatků 10
          mTmp := StringReplace(mLineCols[8],',','', [rfReplaceAll,rfIgnoreCase]);
          ADataSet.FieldByName(cCastka).AsFloat := CFxFloat.StrToFloat(mTmp,'.');
          mTmp := StringReplace(mLineCols[9],',','', [rfReplaceAll,rfIgnoreCase]);
          ADataSet.FieldByName(cPoplatky).AsFloat := CFxFloat.StrToFloat(mTmp,'.');
          ADataSet.FieldByName(cMena).AsString := mMena;
          ADataSet.FieldByName(cCelaCastka).AsFloat := mTotalAmount;
          ADataSet.FieldByName(cPoplatkyCelkem).AsFloat := mPoplatky;
        end;
      end;
    finally
      mLineCols.Free;
    end;
  finally
    mFileLines.Free;
  end;
end;

procedure LoadKomercniBankaData(AFileName: String; ADataSet: TDataSet);
var
  mFileLines, mLineCols: TStringList;
  mVarSymbol, mLine, mTypeLine, mMena: String;
  mDate: TDate;
  i: Integer;
  mTotalAmount, mPoplatkyCelkem: Double;
begin
  mFileLines := TStringList.Create;
  try
    mFileLines.LoadFromFile(AFileName);
    mLineCols := TStringList.Create;
    try
      //zjistíme sumy
      mTotalAmount := 0;
      mPoplatkyCelkem := 0;
      //NxShowSimpleMessage(NxFloatToIBStr(mFileLines.Count),nil);
      for i := 0 to mFileLines.Count - 1 do begin
        mLine := mFileLines[i];
        //zjistíme jeli ok formát
        if (i = 0) then
          if (copy(mLine, 1, 7) <> '028001M') then
            exit;
        mLineCols.Clear;
        mTypeLine := Copy(mLine, 4, 3);

        if (mTypeLine = '010') then begin
          LoadFixedSizeIntoStrings(mLine, mLineCols, [3,3,17,1,17,1,17,1]);
          if mLineCols[3] = '+' then
            mTotalAmount := mTotalAmount + StrToFloat(mLineCols[2])/100
          else
            mTotalAmount := mTotalAmount - StrToFloat(mLineCols[2])/100;
          if mLineCols[5] = '+' then
            mPoplatkyCelkem := mPoplatkyCelkem + StrToFloat(mLineCols[4])/100
          else
            mPoplatkyCelkem := mPoplatkyCelkem - StrToFloat(mLineCols[4])/100;
        end;
      end;
      //NxShowSimpleMessage(NxFloatToIBStr(mPoplatkyCelkem),nil);

      for i := 1 to mFileLines.Count - 1 do begin
        mLine := mFileLines[i];

        mTypeLine := Copy(mLine, 4, 3);
        //zjistíme měnu a datum
        case mTypeLine of
          '002': mMena := Copy(mLine, 32, 3);

        end;

        //transakční řádek
        if (mTypeLine = '004') then begin
          mLineCols.Clear;

          LoadFixedSizeIntoStrings(mLine, mLineCols, [3,3,8,9,10,10,8,19,2,15,17,1,17,1,17,1,6]);
          ADataSet.Append;

          ADataSet.FieldByName(cDatum).AsDateTime := EncodeDate(strtoint(copy(mLineCols[6],5,4)), strtoint(copy(mLineCols[6],3,2)), strtoint(copy(mLineCols[6],1,2)));
//          ADataSet.FieldByName(cVarSymbol).AsString := NxTrimL(mLineCols[0], '0');
          ADataSet.FieldByName(cVarSymbolRow).AsString := NxTrimL(mLineCols[7], '0');
          ADataSet.FieldByName(cMena).AsString := mMena;
          if mLineCols[11] = '+' then
            ADataSet.FieldByName(cCastka).AsFloat := StrToFloat(mLineCols[10])/100
          else
            ADataSet.FieldByName(cCastka).AsFloat := -StrToFloat(mLineCols[10])/100;
          ADataSet.FieldByName(cCelaCastka).AsFloat := mTotalAmount;
          if mLineCols[13] = '+' then
            ADataSet.FieldByName(cPoplatky).AsFloat := StrToFloat(mLineCols[12])/100
          else
            ADataSet.FieldByName(cPoplatky).AsFloat := -StrToFloat(mLineCols[12])/100;
          ADataSet.FieldByName(cPoplatkyCelkem).AsFloat := mPoplatkyCelkem;
          ADataSet.FieldByName(cAutorizacniKod).AsString := mLineCols[16];
        end;
      end;
    finally
      mLineCols.Free;
    end;
  finally
    mFileLines.Free;
  end;
end;

procedure LoadPayUData(AFileName: String; ADataSet: TDataSet; AOS: TNxCustomObjectSpace);
var
  mFileLines, mLineCols: TStringList;
  mVarSymbol, mLine: String;
  mDate: TDate;
  i: Integer;
  mTotalAmount, mTotalFees: Double;

  function iExtractDate(AString: String): TDateTime;
  begin
    Result := EncodeDate(StrToInt(Copy(AString,1,4)),StrToInt(Copy(AString,6,2)),StrToInt(Copy(AString,9,2)));
  end;

begin
  mFileLines := TStringList.Create;
  try
    mFileLines.LoadFromFile(AFileName);
    mLineCols := TStringList.Create;
    try
      mTotalAmount := 0;
      for i := 0 to mFileLines.Count - 1 do begin
        mLine := mFileLines.Strings[i];
        NxShowSimpleMessage(mFileLines.Strings[i],nil);
        mLineCols.Clear;
        //NxTokenToStrings(mLine, ';', mLineCols);
        mLine := '"' + NxSearchReplace(NxSearchReplace(mLine, '"', '', [srAll]), ';', '";"', [srAll]) + '"';
        mLineCols.Delimiter := ';';
        //mLineCols.QuoteChar := ' ';
        mLineCols.DelimitedText := mLine;
        if i<>0 then begin
          mTotalAmount := mTotalAmount + StrToFloat(NxSearchReplace(mLineCols[3], '.', ',', [srAll]));
          if (mLineCols[17]<>'') then
            mTotalFees := mTotalFees + StrToFloat(NxSearchReplace(mLineCols[17], '.', ',', [srAll]));
        end;
      end;
      for i := 0 to mFileLines.Count - 1 do begin
        mLine := mFileLines.Strings[i];
        mLineCols.Clear;
        //NxTokenToStrings(mLine, ';', mLineCols);
        mLine := '"' + NxSearchReplace(NxSearchReplace(mLine, '"', '', [srAll]), ';', '";"', [srAll]) + '"';
        mLineCols.Delimiter := ';';
        //mLineCols.QuoteChar := ' ';


        mLineCols.DelimitedText := mLine;
        NxShowSimpleMessage(mLine,nil);


        ADataSet.Append;
        ADataSet.FieldByName(cDatum).AsDateTime := iExtractDate(mLineCols[1]);
// GetFirstSQLResult('Select Cu.Code from Countries Co join Currencies Cu on Cu.ID = Co.Currency_ID where Co.Code = '+QuotedStr(UpperCase(mLineCols[5])),AOS);
        ADataSet.FieldByName(cVarSymbol).AsString := mLineCols[2];
        NxShowSimpleMessage(mLineCols[2],nil);
        ADataSet.FieldByName(cVarSymbolRow).AsString := mLineCols[2];
        ADataSet.FieldByName(cCisloZasilky).AsString := mLineCols[2];
        ADataSet.FieldByName(cCastka).AsFloat := StrToFloat(NxSearchReplace(mLineCols[3], '.', ',', [srAll]));
        ADataSet.FieldByName(cMena).AsString := mLineCols[2];
        ADataSet.FieldByName(cCelaCastka).AsFloat := mTotalAmount;
        ADataSet.FieldByName(cPoplatkyCelkem).AsFloat := mTotalFees;
      end;
    finally
      mLineCols.Free;
    end;
  finally
    mFileLines.Free;
  end;
end;

function ShowDataSet(ADataSet: TDataSet; AColumns: String = ''): Integer;
var
  mForm: TForm;
begin
  mForm := CreateShowDataForm(nil, ADataSet);
  try
    Result := mForm.ShowModal(nil);
  finally
    mForm.Free;
  end;
end;

function GetBankStatementRowForDSRow(ADataSet: TDataSet; AObjectSpace: TNxCustomObjectSpace): TNxOID;
const
  cSQLDaysBack = '180'; //kolik dni zpet budeme hledat
  cSQLFields = 'bs2.ID as "Identifikator", (dq.Code || ''-'' || bs.OrdNumber || ''/'' || p.Code) as "BV", bs2.Text as "Text", bs2.VarSymbol as "Var.Symbol", bs2.TAmount as "Celkem"';
  cSQLFromSection = 'from BankStatements2 bs2 inner join BankStatements bs on bs.id=bs2.parent_id inner join docqueues dq on dq.id=bs.docqueue_id inner join periods p on p.id=bs.period_id';
  cSQLCommonAndWhere = ' and (bs.DocDate$DATE+'+cSQLDaysBack+')>=IB_ENCODEDATE (EXTRACT (YEAR FROM CURRENT_DATE), EXTRACT (MONTH FROM CURRENT_DATE), EXTRACT (DAY FROM CURRENT_DATE))';
  cSQLVarSymbol = 'select '+cSQLFields+' '+cSQLFromSection+' where bs2.VarSymbol=';
  cSQLAmount = 'select '+cSQLFields+' '+cSQLFromSection+' where bs2.Amount=';
var
  mBankStatementRowID: String;
  mIDs: TStringList;
  mDataSet: TMemoryDataset;
  mForm: TForm;

  function iSQL(ASQL: String): String;
  begin
    Result := ASQL + cSQLCommonAndWhere;
  end;

begin
  mDataSet := TMemoryDataset.Create(nil);
  try
    if ADataSet.FieldByName(cVarSymbol).AsString <> '' then begin
      //PPL
      AObjectSpace.SQLSelect2(iSQL(cSQLVarSymbol+QuotedStr(ADataSet.FieldByName(cVarSymbol).AsString)), mDataSet);
      if mDataSet.Eof then begin
        //jeste to prubneme podle castky
        AObjectSpace.SQLSelect2(iSQL(cSQLAmount+NxFloatToIBStr(ADataSet.FieldByName(cCelaCastka).AsFloat)), mDataSet);
      end;
    end;

    if mDataSet.Eof then begin
      //mDataSet.ClearFields; RUDU: tohle nefunguje dobře a je lepší pokaždé vytvořit nový DataSet
      mDataSet.Close;
      mDataSet.Free;
      mDataSet := TMemoryDataset.Create(nil);
      if ADataSet.FieldByName(cVarSymbolRow).AsString <> '' then begin
        AObjectSpace.SQLSelect2(iSQL(cSQLVarSymbol+QuotedStr(ADataSet.FieldByName(cVarSymbolRow).AsString)), mDataSet);
        if mDataSet.Eof then begin
          //jeste to prubneme podle castky
          AObjectSpace.SQLSelect2(iSQL(cSQLAmount+NxFloatToIBStr(ADataSet.FieldByName(cCastka).AsFloat)), mDataSet);
        end;
      end;
    end;

    //tady budou dalsi zpusoby hledani

    //posledni zpusob hledani bude podle castky
    if mDataSet.Eof then begin
      //mDataSet.ClearFields; RUDU: tohle nefunguje dobře a je lepší pokaždé vytvořit nový DataSet
      mDataSet.Close;
      mDataSet.Free;
      mDataSet := TMemoryDataset.Create(nil);
      if ADataSet.FieldByName(cCelaCastka).AsFloat <> 0 then begin
        AObjectSpace.SQLSelect2(
          iSQL(
            cSQLAmount+NxFloatToIBStr(ADataSet.FieldByName(cCelaCastka).AsFloat-ADataSet.FieldByName(cPoplatkyCelkem).AsFloat)
            ), mDataSet
          );
      end;
    end;



    { else if (ADataSet.FieldByName(cAutorizacniKod).AsString <> '') then begin
      AObjectSpace.SQLSelect2(iSQL(cSQLAmount+NxFloatToIBStr(ADataSet.FieldByName(cCelaCastka).AsFloat-ADataSet.FieldByName(cPoplatkyCelkem).AsFloat)), mDataSet);
    end else if (mDataSet.Eof) then begin
      //ToDo
    end else if (mDataSet.Eof) then begin
      //ToDo
    end else if (mDataSet.Eof) then begin
      AObjectSpace.SQLSelect2(iSQL(cSQLAmount+NxFloatToIBStr(ADataSet.FieldByName(cCelaCastka).AsFloat)), mDataSet);
    end else if (mDataSet.Eof) then
      RaiseException('Nespecifikovany typ pro vyhledavani na radku '+IntToSTr(ADataSet.RecNo));
      }
    if mDataSet.RecordCount > 1 then begin
      mForm := CreateShowDataForm(nil, mDataSet);
      try
        mForm.Caption := 'Dohledane radky BV - vyberte';
        if mForm.ShowModal(nil) = mrOk then begin
          mBankStatementRowID := mDataSet.FieldByName('Identifikator').AsString;
        end else begin
          RaiseException('Je treba zvolit spravny radek');
        end;
      finally
        mForm.Free;
      end;
    end else begin
      if mDataSet.Eof then begin
        //ToDO
        {Tady by se dalo doimplementovat to aby si uzivatel sam vybral ze vsechn moznych BV a jejich radku}
        RaiseException('Nepodarilo se dohledat zadny sparovatelny BV'#13'')
      end else begin
        mBankStatementRowID := mDataSet.FieldByName('Identifikator').AsString;
      end;
    end;
    {
    if not NxIsEmptyOID(mBankStatementRowID) then begin
      RaiseException('');
    end else
    }
    Result := mBankStatementRowID;
  finally
    mDataSet.Free;
  end;
end;

function GetPaidDocumentForDSRow(ADataSet: TDataSet; AObjectSpace: TNxCustomObjectSpace; var AResultID, AResultType: string; AAmount: Extended): Boolean;
const
  //PPL
  //cSQL1 = 'select id from issuedinvoices where X_PDMIssuedDocNumber=''%s''';
    cSQL1 = 'select i.id from PDMIssuedDocs a inner join Relations r on R.LEFTSIDE_ID= a.id and r.REL_DEF = 1400 inner join IssuedInvoices i on  i.ID = R.RIGHTSIDE_ID where a.Varsymbol = ''%s''';
  //CS - platební karty
  cSQL2 = 'select id from POSCashPaid where Description like ''%s'' and Amount = ''%s''';
  cSQL = 'select i.ID from IssuedInvoices i where i.Varsymbol = ''%s''';
var
  mID, mSQL: String;
  mResultList: TStringList;
  mPaidDocument: TNxCustomBusinessObject;
  i: integer;
  mNotPaidAmount: Extended;
  S : string;
  N : integer;
begin
  ShowDebugMessage('GetPaidDocumentForDSRow START');
  AResultID := '0000000000';
  mResultList := TStringList.Create;
  try
    if ADataSet.FieldByName(cCisloZasilky).AsString <> '' then begin
      if cNoPDM then begin
        ShowDebugMessage('BEZ PDM');
        mSQL := Format(cSQL, [ADataSet.FieldByName(cVarSymbolRow).AsString]);
        ShowDebugMessage('mSQL: ' + mSQL);
        AObjectSpace.SQLSelect(mSQL, mResultList);
        if mResultList.Count = 1 then begin
          mID := mResultList.Strings[0];
          ShowDebugMessage('03 mSQL res 1 zaznam: ' + mID);
          AResultType := '03';
          AResultID := mID;
        end
        else begin
          // ted dohledavam nezaplaceny doklad
          for i := 0 to mResultList.Count - 1 do begin
            mID := mResultList.Strings[i];
            mPaidDocument := AObjectSpace.CreateObject(Class_IssuedInvoice);
            try
              mPaidDocument.Load(mID, nil);
              mNotPaidAmount := mPaidDocument.GetFieldValueAsFloat('NotPaidAmount');
              ShowDebugMessage('AAmount: ' + FloatToStr(AAmount));
              ShowDebugMessage('mNotPaidAmount: ' + FloatToStr(mNotPaidAmount));
              if (mNotPaidAmount > 0) and (mNotPaidAmount  <= AAmount) then begin
                ShowDebugMessage('03 mSQL res vice nez 1 zaznam: ' + mID);
                AResultType := '03';
                AResultID := mID;
                Break;
              end;
            finally
              mPaidDocument.Free;
            end;
          end;
        end;
      end
      else begin
        // FV pres postu
        ShowDebugMessage('POMOCI PDM');
        mSQL := Format(cSQL1, [ADataSet.FieldByName(cVarSymbolRow).AsString]);
        ShowDebugMessage('mSQL: ' + mSQL);
        AObjectSpace.SQLSelect(mSQL, mResultList);
        if mResultList.Count = 1 then begin
          mID := mResultList.Strings[0];
          ShowDebugMessage('03 mSQL res 1 zaznam: ' + mID);
          AResultType := '03';
          AResultID := mID;
        end
        else begin
          // ted dohledavam nezaplaceny doklad
          for i := 0 to mResultList.Count - 1 do begin
            mID := mResultList.Strings[i];
            mPaidDocument := AObjectSpace.CreateObject(Class_IssuedInvoice);
            try
              mPaidDocument.Load(mID, nil);
              mNotPaidAmount := mPaidDocument.GetFieldValueAsFloat('NotPaidAmount');
              ShowDebugMessage('AAmount: ' + FloatToStr(AAmount));
              ShowDebugMessage('mNotPaidAmount: ' + FloatToStr(mNotPaidAmount));
              if (mNotPaidAmount > 0) and (mNotPaidAmount  <= AAmount) then begin
                ShowDebugMessage('03 mSQL res vice nez 1 zaznam: ' + mID);
                AResultType := '03';
                AResultID := mID;
                Break;
              end;
            finally
              mPaidDocument.Free;
            end;
          end;
        end;
      end;
    end
    else begin
      if AResultID='0000000000' then begin
        mSQL := Format(cSQL, [ADataSet.FieldByName(cVarSymbolRow).AsString]);
        ShowDebugMessage('mSQL: ' + mSQL);
        AObjectSpace.SQLSelect(mSQL, mResultList);
        if mResultList.Count = 1 then begin
          mID := mResultList.Strings[0];
          ShowDebugMessage('03 mSQL res 1 zaznam: ' + mID);
          AResultType := '03';
          AResultID := mID;
        end
        else begin
          // ted dohledavam nezaplaceny doklad
          for i := 0 to mResultList.Count - 1 do begin
            mID := mResultList.Strings[i];
            mPaidDocument := AObjectSpace.CreateObject(Class_IssuedInvoice);
            try
              mPaidDocument.Load(mID, nil);
              mNotPaidAmount := mPaidDocument.GetFieldValueAsFloat('NotPaidAmount');
              ShowDebugMessage('AAmount: ' + FloatToStr(AAmount));
              ShowDebugMessage('mNotPaidAmount: ' + FloatToStr(mNotPaidAmount));
              if (mNotPaidAmount > 0) and (mNotPaidAmount  <= AAmount) then begin
                ShowDebugMessage('03 mSQL res vice nez 1 zaznam: ' + mID);
                AResultType := '03';
                AResultID := mID;
                Break;
              end;
            finally
              mPaidDocument.Free;
            end;
          end;
        end;
      end;
      if AResultID='0000000000' then begin
        mSQL := Format(cSQL2, [NxSearchReplace(ADataSet.FieldByName(cVarSymbolRow).AsString,'X','_',[srAll]),ADataSet.FieldByName(cCastka).AsString]);
        mID := GetFirstSQLResult(mSQL, AObjectSpace, '');
        if not NxIsEmptyOID(mID) then begin
          ShowDebugMessage('VarSymbol: ' + ADataSet.FieldByName(cVarSymbolRow).AsString);
          ShowDebugMessage('mSQL: ' + mSQL);
          ShowDebugMessage('CP mSQL res: ' + mID);
          AResultType := 'CP';
          AResultID := mID;
        end;
       end;
        //Roeh neheldalo se podle celé sekvvence plat. karty tak jen podle konce
       if AResultID='0000000000' then begin
         S := UpperCase(ADataSet.FieldByName(cVarSymbolRow).AsString);
         while Pos('X',S)>0 do Delete(S,1,1);
         S := '%' + S;
        mSQL := Format(cSQL2, [S,ADataSet.FieldByName(cCastka).AsString]);
        mID := GetFirstSQLResult(mSQL, AObjectSpace, '');
        if not NxIsEmptyOID(mID) then begin
          ShowDebugMessage('VarSymbol: ' + ADataSet.FieldByName(cVarSymbolRow).AsString);
          ShowDebugMessage('mSQL: ' + mSQL);
          ShowDebugMessage('CP mSQL res: ' + mID);
          AResultType := 'CP';
          AResultID := mID;
        end;
      end;
    end;
      // lubi stary kod
      {if ADataSet.FieldByName(cCisloZasilky).AsString <> '' then begin
        //PPL
        mSQL := Format(cSQL1, [ADataSet.FieldByName(cVarSymbolRow).AsString]);
        //ShowDebugMessage('mSQL: ' + mSQL);
        mID := GetFirstSQLResult(mSQL, AObjectSpace, '');
        if not NxIsEmptyOID(mID) then begin
          ShowDebugMessage('VarSymbol: ' + ADataSet.FieldByName(cVarSymbolRow).AsString);
          ShowDebugMessage('mSQL: ' + mSQL);
          ShowDebugMessage('03 mSQL res: ' + mID);
          AResultType := '03';
          AResultID := mID;
        end;
      end else if AResultID='0000000000' then begin
        mSQL := Format(cSQL2, [NxSearchReplace(ADataSet.FieldByName(cVarSymbolRow).AsString,'X','_',[srAll]),ADataSet.FieldByName(cCastka).AsString]);
        mID := GetFirstSQLResult(mSQL, AObjectSpace, '');
        if not NxIsEmptyOID(mID) then begin
          ShowDebugMessage('VarSymbol: ' + ADataSet.FieldByName(cVarSymbolRow).AsString);
          ShowDebugMessage('mSQL: ' + mSQL);
          ShowDebugMessage('CP mSQL res: ' + mID);
          AResultType := 'CP';
          AResultID := mID;
          end;
      }
    {end else if (false) then begin
      //ToDO
    end else if (false) then begin
      //ToDO
    end else if (false) then begin
      //ToDO
    end else if (false) then begin
      RaiseException('Nespodarilo se dohledat placeny doklad z radku '+IntToSTr(ADataSet.RecNo));
    end;
    }
  finally
    mResultList.Free;
  end;
  Result := AResultID <> '0000000000';
  ShowDebugMessage('GetPaidDocumentForDSRow: ' + AResultID);
end;

procedure OnMultiExecute(Sender: TControl; Index: Integer);
var
  mDataSet: TDataSet;
  mFileName, mBSRowID, mVarSymbol: String;
  mFirstRow: Boolean;
  mSite: TSiteForm;
  mDynSite: TDynSiteForm;
  mObjectSpace: TNxCustomObjectSpace;
  mBSRow, mBSRow2, mBS, mPaidDocument, mDocQueue: TNxCustomBusinessObject;
  mRows: TNxCustomBusinessMonikerCollection;
  mParams, mParams2: TNxParameters;
  mPar: TNxParameter;
  mRowIDs: TStringList;
  mCode: Integer;
  mLogWindow: TForm;
  mPaidDocumentID,mPadDocumentType: string;
  mExtensions : string;
  s: string;
begin
  if not TestLicence(cIsVisual, s) then exit;
  NxWaitWinBreak;
  mLogWindow := CreateLogWindow(gLog);
  try
    try
      //mLogWindow.Visible := True;
      Log('Zahajen import aviza');
      if GetSiteFromControl(Sender, mSite) then begin
        mObjectSpace := mSite.BaseObjectSpace;
        mExtensions := '';
        if Index < Length(cExtensions) then
          mExtensions := cExtensions[Index];
        if mExtensions = '' then
          mExtensions := 'Všechny soubory (*.*)|*.*';
        if PromptForFileName(mFileName, mExtensions, '', cTitle) then begin
          Log('Soubor importu: ' + QuotedStr(mFileName));
          mRowIDs := TStringList.Create;
          try
            mDataSet := TMemoryDataset.Create(nil);
            try
              PrefillDataSetFileds(mDataSet);
              case Index of
                0 : begin
                  // Bude vhodné časem udělat přepínač kterou verzi formátu bereme
                  LoadPPLData(mFileName, mDataSet);
//                  LoadPPLVacusData(mFileName, mDataSet);
                end;
                1 : begin
                  LoadCSData(mFileName, mDataSet);
                end;
                2 : begin
                  LoadMUZOData(mFileName, mDataSet);
                end;
                3 : begin
                  LoadCetelemData(mFileName, mDataSet);
                end;
                4 : begin
                  LoadCeskaPostaData(mFileName, mDataSet);
                end;
                5 : begin
                  LoadPostaBezHranicData(mFileName, mDataSet, mObjectSpace);
                end;
                6 : begin
                  LoadUnicreditBankData(mFileName, mDataSet);
                end;
                7 : begin
                  LoadKomercniBankaData(mFileName, mDataSet);
                end;
                8 : begin
                  LoadPayUData(mFileName, mDataSet, mObjectSpace);
                end;
                else begin
                  ShowMessage('Není implementováno!');
                  Exit;
                end;
              end;
              //tady mame plny dataset
              if ShowDataSet(mDataSet, '') = mrCancel then begin
                Log('Storno');
                Exit;
              end;
{              mDataSet.First;
              if mDataSet.Eof then Exit;
              repeat
                mBSRowID := GetBankStatementRowForDSRow(mDataSet, mObjectSpace);
                if not NxIsEmptyOID(mBSRowID) then begin
                  mBSRow := mObjectSpace.CreateObject('OBSCO4S1BRD13FY1010DELDFKK');
                  try
                    mBSRow.Load(mBSRowID, nil);
                    if mBSRow.GetFieldValueAsBoolean('IsMultiPaymentRow') then
                      RaiseException('Dohledaný řádek je již rozpadlý (pravděpodobně už k importu tohoto souboru došlo dříve, nebo byl proveden ručně)');
                    mBS := TNxNotPositionedRowBusinessObject(mBSRow).Header.BusinessObject;
                    mCode := mBS.GetFieldCode('Rows');
                    mRows := mBS.GetLoadedCollectionMonikerForFieldCode(mCode);
                    //rozpadneme radek
                    //mBSRow.SetFieldValueAsBoolean('IsMultiPaymentRow', True);
                    mBSRow2 := mRows.BusinessObject[mRows.IndexOfOID(mBSRow.OID)];
                    mBSRow2.SetFieldValueAsBoolean('IsMultiPaymentRow', True);
                    mVarSymbol := mDataSet.FieldByName(cVarSymbol).AsString;
                    //tady klicka pro CETELEM, protoze oni maji jedno avizo k nekolika radkum BV
                    mFirstRow := true;
                    while (not mDataSet.Eof) and (mVarSymbol = mDataSet.FieldByName(cVarSymbol).AsString) do begin
                      if mFirstRow and (mDataSet.FieldByName(cPoplatkyCelkem).AsFloat>0) then begin
                        //pridame poplatky
                        mBSRow2 := mRows.AddNewObject;
                        mBSRow2.Prefill;
                        mBSRow2.SetFieldValueAsString('Text', 'Poplatky');
                        mBSRow2.SetFieldValueAsBoolean('Credit', true);
                        mBSRow2.CopyFieldValuesFrom_1(mBSRow, ['Division_ID'], true);
                        mBSRow2.SetFieldValueAsString('BankStatementRow_ID', mBSRowID);
                        if not SetFieldFromRoll(mSite.SiteContext, mBSRow2, 'Currency_ID', 'Code', mDataSet.FieldByName(cMena).AsString, nil) then
                          RaiseException('Nepodarilo se dohledat menu s kodem: '+mDataSet.FieldByName(cMena).AsString);
                        mBSRow2.SetFieldValueAsFloat('Amount', -mDataSet.FieldByName(cPoplatkyCelkem).AsFloat);
                        mFirstRow := false;
                      end;
                      mBSRow2 := mRows.AddNewObject;
                      mBSRow2.Prefill;
                      mBSRow2.CopyFieldValuesFrom_1(mBSRow, ['Division_ID'], true);
                      mBSRow2.SetFieldValueAsString('BankStatementRow_ID', mBSRowID);
                      mBSRow2.SetFieldValueAsString('Text', mDataSet.FieldByName(cText).AsString);
                      mBSRow2.SetFieldValueAsString('VarSymbol', mDataSet.FieldByName(cVarSymbolRow).AsString);
                      mBSRow2.SetFieldValueAsString('SpecSymbol', mDataSet.FieldByName(cSpecSymbolRow).AsString);
                      mBSRow2.SetFieldValueAsFloat('Amount', mDataSet.FieldByName(cCastka).AsFloat);
                      if not SetFieldFromRoll(mSite.SiteContext, mBSRow2, 'Currency_ID', 'Code', mDataSet.FieldByName(cMena).AsString, nil) then
                        RaiseException('Nepodarilo se dohledat menu s kodem: '+mDataSet.FieldByName(cMena).AsString);
                      if GetPaidDocumentForDSRow(mDataSet, mObjectSpace, mPaidDocumentID) then begin
                        mPaidDocument := mObjectSpace.CreateObject('O3BDOKTWEFD13ACM03KIU0CLP4');
                        try
                          if mPaidDocument.Test(mPaidDocumentID) then
                          begin
                            mPaidDocument.Load(mPaidDocumentID, nil);
                            mCode := mPaidDocument.GetFieldCode('DocQueue_ID');
                            mDocQueue := mPaidDocument.GetMonikerForFieldCode(mCode).BusinessObject;
                            mBSRow2.SetFieldValueAsString('PDocumentType', mDocQueue.GetFieldValueAsString('DocumentType'));
                            mBSRow2.SetFieldValueAsString('PDocument_ID', mPaidDocument.OID);
                          end;
                        finally
                          //v GetPaidDocumentForDSRow se objekt vytvari, je tedy treba jej i uvolnit
                          mPaidDocument.Free;
                        end;
                      end else begin
                        Log('Nepodarilo se dohledat placeny doklad pro radek:'#13+DataSetRowToString(mDataSet))
                      end;
                      mDataSet.Next;
                    end;
                    mBS.Save;
                    mRowIDs.Add(mBSRow.OID);
                  finally
                    mBSRow.Free;
                  end;
                end else begin
                  RaiseException('Nepodarilo se dohledat radek bank.vypisu');
                end;
              until mDataSet.Eof;
              MoveToRow(TDynSiteForm(mSite), mRowIDs);
            finally
              mDataSet.Free;
            end;
          finally
            mRowIDs.Free;
          end;
        end;
      end;
    except
      Log('Pri importu aviz doslo k chybe:');
      Log(ExceptionMessage);
      Log('');
      Log('Toto okno je treba zavrit rucne');
      mLogWindow.ShowModal;
    end;
    mLogWindow.Hide;
  finally
    mLogWindow.Free;
    gLog := nil;
    NxWaitWinUnBreak;
  end;
end;}
              mDataSet.First;
              if mDataSet.Eof then Exit;
              repeat
                mBSRowID := GetBankStatementRowForDSRow(mDataSet, mObjectSpace);
                if not NxIsEmptyOID(mBSRowID) then begin
                  mBSRow := mObjectSpace.CreateObject(Class_BankStatementRow);
                  try
                    mBSRow.Load(mBSRowID, nil);
                    if mBSRow.GetFieldValueAsBoolean('IsMultiPaymentRow') then
                      RaiseException('Dohledaný řádek je již rozpadlý (pravděpodobně už k importu tohoto souboru došlo dříve, nebo byl proveden ručně)');
                    mBS := TNxNotPositionedRowBusinessObject(mBSRow).Header.BusinessObject;
                    mCode := mBS.GetFieldCode('Rows');
                    mRows := mBS.GetLoadedCollectionMonikerForFieldCode(mCode);
                    //rozpadneme radek
                    //mBSRow.SetFieldValueAsBoolean('IsMultiPaymentRow', True);
                    mBSRow2 := mRows.BusinessObject[mRows.IndexOfOID(mBSRow.OID)];
                    mBSRow2.SetFieldValueAsBoolean('IsMultiPaymentRow', True);
                    mVarSymbol := mDataSet.FieldByName(cVarSymbol).AsString;
                    //tady klicka pro CETELEM, protoze oni maji jedno avizo k nekolika radkum BV
                    mFirstRow := ((Index= 1) or (Index= 6) or (Index= 2));  //česká spořitelna, ČSOB a unicreditbank
                    while (not mDataSet.Eof) and (mVarSymbol = mDataSet.FieldByName(cVarSymbol).AsString) do begin
                      if mFirstRow and (mDataSet.FieldByName(cPoplatkyCelkem).AsFloat>0) then begin
                        //pridame poplatky
                        mBSRow2 := mRows.AddNewObject;
                        mBSRow2.Prefill;
                        mBSRow2.SetFieldValueAsString('Text', 'Poplatky');
                        mBSRow2.SetFieldValueAsBoolean('Credit', true);
                        mBSRow2.CopyFieldValuesFrom_1(mBSRow, ['Division_ID'], true);
                        mBSRow2.SetFieldValueAsString('BankStatementRow_ID', mBSRowID);
                        if not SetFieldFromRoll(mSite.SiteContext, mBSRow2, 'Currency_ID', 'Code', mDataSet.FieldByName(cMena).AsString, nil) then
                          RaiseException('Nepodarilo se dohledat menu s kodem: '+mDataSet.FieldByName(cMena).AsString);
                        mBSRow2.SetFieldValueAsFloat('Amount', -mDataSet.FieldByName(cPoplatkyCelkem).AsFloat);
                        mFirstRow := false;
                      end;
                      mBSRow2 := mRows.AddNewObject;
                      mBSRow2.Prefill;
                      mBSRow2.CopyFieldValuesFrom_1(mBSRow, ['Division_ID'], true);
                      mBSRow2.SetFieldValueAsString('BankStatementRow_ID', mBSRowID);
                      mBSRow2.SetFieldValueAsString('Text', mDataSet.FieldByName(cText).AsString);
		                  mBSRow2.SetFieldValueAsString('VarSymbol',NxSearchReplace(mDataSet.FieldByName(cVarSymbolRow).AsString,'X','',[srAll]));

                      mBSRow2.SetFieldValueAsFloat('Amount', mDataSet.FieldByName(cCastka).AsFloat);
                      if not SetFieldFromRoll(mSite.SiteContext, mBSRow2, 'Currency_ID', 'Code', mDataSet.FieldByName(cMena).AsString, nil) then
                        RaiseException('Nepodarilo se dohledat menu s kodem: '+mDataSet.FieldByName(cMena).AsString);
                      if GetPaidDocumentForDSRow(mDataSet, mObjectSpace, mPaidDocumentID,mPadDocumentType, mBSRow2.GetFieldValueAsFloat('Amount')) then begin
                        if mPadDocumentType = '03' then mPaidDocument := mObjectSpace.CreateObject(Class_IssuedInvoice);
                        if mPadDocumentType = 'CP' then mPaidDocument := mObjectSpace.CreateObject(Class_POSCashPaid);
                        try
                          if (mPaidDocument.Test(mPaidDocumentID)) then
                          begin
                            mPaidDocument.Load(mPaidDocumentID, nil);
                            mCode := mPaidDocument.GetFieldCode('DocQueue_ID');
                            mDocQueue := mPaidDocument.GetMonikerForFieldCode(mCode).BusinessObject;
                            mBSRow2.SetFieldValueAsString('PDocumentType', mDocQueue.GetFieldValueAsString('DocumentType'));
                            mBSRow2.SetFieldValueAsString('PDocument_ID', mPaidDocument.OID);
                            ShowDebugMessage('PDocument_ID: ' + mPaidDocument.OID);
                          end;
                        finally
                          //v GetPaidDocumentForDSRow se objet vytvari, je tedy treba jej i uvolnit
                          mPaidDocument.Free;
                        end;
                      end else begin
                        Log('Nepodarilo se dohledat placeny doklad pro radek:'#13+DataSetRowToString(mDataSet))
                      end;
                      mDataSet.Next;
                    end;
                    mBS.Save;
                    mRowIDs.Add(mBSRow.OID);
                  finally
                    mBSRow.Free;
                  end;
                end else begin
                  RaiseException('Nepodarilo se dohledat radek bank.vypisu');
                end;
              until mDataSet.Eof;
              MoveToRow(TDynSiteForm(mSite), mRowIDs);
            finally
              mDataSet.Free;
            end;
          finally
            mRowIDs.Free;
          end;
        end;
      end;
    except
      Log('Pri importu aviz doslo k chybe:');
      Log(ExceptionMessage);
      Log('');
      Log('Toto okno je treba zavrit rucne');
      mLogWindow.ShowModal(nil);
    end;
    mLogWindow.Hide;
  finally
    mLogWindow.Free;
    gLog := nil;
    NxWaitWinUnBreak;
  end;
end;

function CreateShowDataForm(AParent: TForm; ADataSet: TDataSet): TForm;
var
  grdData: TDBGrid;
  pnBottom: TPanel;
  pnBottomRight: TPanel;
  btnOk: TButton;
  dsMain: TDataSource;
  Str : TStringList;
  i: integer;
begin
  Result := TForm.Create(AParent);
  grdData := TDBGrid.Create(Result);
  pnBottom := TPanel.Create(Result);
  pnBottomRight := TPanel.Create(Result);
  btnOk := TButton.Create(Result);
  dsMain := TDataSource.Create(Result);
  with Result do
  begin
    Name := 'frmShowData';
    Left := 192;
    Top := 179;
    Width := 827;
    Height := 457;
    Caption := 'Načtená data';
    Color := clBtnFace;
    Font.Color := clGreen;
    Font.Height := -13;
    Font.Name := 'MS Sans Serif';
    Font.Style := [fsBold];
    OldCreateOrder := False;
    PixelsPerInch := 96;
    Position := poDesktopCenter
  end;
  with pnBottom do
  begin
    Name := 'pnBottom';
    Caption := '';
    Parent := Result;
    Left := 0;
    Top := 380;
    Width := 811;
    Height := 41;
    Align := alBottom;
    BevelOuter := bvNone;
    TabOrder := 1;
  end;
  with pnBottomRight do
  begin
    Name := 'pnBottomRight';
    Caption := '';
    Parent := pnBottom;
    Left := 720;
    Top := 0;
    Width := 200;
    Height := 41;
    Align := alRight;
    BevelOuter := bvNone;
    TabOrder := 0;
  end;
  with btnOk do
  begin
    Name := 'btnOk';
    Parent := pnBottomRight;
    Left := 8;
    Top := 8;
    Width := 75;
    Height := 25;
    Caption := '&Ok';
    TabOrder := 0;
    ModalResult := mrOk;
  end;
  with TButton.Create(Result) do
  begin
    Name := 'btnCancel';
    Parent := pnBottomRight;
    Left := btnOk.Left + btnOk.Width + 8;
    Top := 8;
    Width := 75;
    Height := 25;
    Caption := '&Zrušit';
    TabOrder := 1;
    ModalResult := mrCancel;
  end;
  with dsMain do
  begin
    Name := 'dsMain';
    DataSet := ADataSet;
  end;
  // ROEH - rychlé skrití nepotřebných...
  Str := TStringList.Create;
  try
   ADataSet.FieldDefs.GetItemNames(Str);
   for i := 0 to Str.Count - 1 do begin
    if Str.Strings(i) = cCredit then ADataSet.FieldByName(cCredit).Visible := false;
    if Str.Strings(i) = cCisloObjednavky then ADataSet.FieldByName(cCisloObjednavky).Visible := false;
    if Str.Strings(i) = cAutorizacniKod then ADataSet.FieldByName(cAutorizacniKod).Visible := false;
    if Str.Strings(i)  = cPoplatky then ADataSet.FieldByName(cPoplatky).Visible := false;
    if Str.Strings(i) = cPoplatkyCelkem then ADataSet.FieldByName(cPoplatkyCelkem).Visible := false;
    if Str.Strings(i) = cText then ADataSet.FieldByName(cText).Visible := false;
  end;
  finally
    Str.Free;
  end;
  with grdData do
  begin
    Name := 'grdData';
    Parent := Result;
    Left := 0;
    Top := 0;
    Width := 811;
    Height := 380;
    Align := alClient;
    DataSource := dsMain;
    TabOrder := 0;
    TitleFont.Color := clGreen;
    TitleFont.Height := -13;
    TitleFont.Name := 'MS Sans Serif';
    Options := [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit];
    TitleFont.Style := [fsBold];
  end;
end;

function CreateLogWindow(var ALog: TStrings; ACreate: Boolean = true): TForm;
var
  frmLog: TForm;
  memLog: TMemo;
begin
  frmLog := TForm.Create(nil);
  try
    memLog := TMemo.Create(frmLog);
    with frmLog do
    begin
      Name := 'frmLog';
      Left := 511;
      Top := 235;
      Width := 575;
      Height := 471;
      Caption := 'Log';
      Color := clBtnFace;
      Font.Color := clWindowText;
      Font.Height := -11;
      Font.Name := 'MS Sans Serif';
      Visible := False;
      FormStyle := fsNormal;
      OldCreateOrder := False;
      Position := poScreenCenter;
      PixelsPerInch := 96;
    end;
    with memLog do
    begin
      Name := 'memLog';
      Parent := frmLog;
      Left := 0;
      Top := 0;
      Width := 559;
      Height := 435;
      Align := alClient;
      Lines.Clear;
      ReadOnly := True;
      ScrollBars := ssVertical;
      TabOrder := 0;
    end;
  except
    frmLog.Free;
    frmLog := nil;
    RaiseException(ExceptionMessage);
  end;
  ALog := memLog.Lines;
  Result := frmLog;
end;


begin
end.