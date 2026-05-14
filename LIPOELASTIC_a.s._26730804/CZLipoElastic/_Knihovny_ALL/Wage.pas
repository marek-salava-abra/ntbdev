uses
  '_Knihovny_ALL.SQL',
  '_Knihovny_ALL.Filesystem',
  '_Knihovny_ALL.DateTime';


// Pokusí se vrátit počáteční datum aktuálního (otevřeného) mzdového období.
// Pokud nenajde, vrátí počíteční datum aktuálního měsíce.

Function GetBeginOfActualWagePeriod(OS: TNxCustomObjectSpace): TDate;
var
  mQuery: string;
begin
  mQuery := 'SELECT DateFrom$DATE FROM WagePeriods WHERE WPeriodClosed = ''N'' ORDER BY DateFrom$Date';
  Result := NxIBStrToFloat(SQLSelectValue(OS, mQuery));
end;


// Pokusí se vrátit ID aktuálního (otevřeného) mzdového období.
// Pokud nenajde, vrátí prázdný string

Function GetActualWagePeriodID(OS: TNxCustomObjectSpace): String;
var
  mQuery: string;
begin
  mQuery := 'SELECT ID FROM WagePeriods WHERE WPeriodClosed = ''N'' ORDER BY DateFrom$Date';
  Result := SQLSelectValue(OS, mQuery);
end;



// Načtení ID mzdového období podle roku a měsíce
function GetWagePeriodIDByDate(OS: TNxCustomObjectSpace; AYear, AMonth: integer): string;
begin
  Result := SQLSelectValue(OS, 'SELECT ID FROM WagePeriods WHERE DateFrom$DATE = '+QuotedStr(NxFloatToIBStr(EncodeDate(AYear, AMonth, 1))));
end;


// Čištění duplicitně tvořených záznamů v historii mzdových položek

// Funkce projde poslední historické záznamy všech mzdových položek pro danou třídu a ID objektu (např. pro konkrétního zaměstnance)
// zjištěnou hodnotu porovná s předchozím záznamem a pokud je stejná, poslední záznam odmaže (protože je tam zbytečný).
// K této duplicitě záznamů dochází, pokud editujeme objekt s historickými položkami mimo agendu, tedy např. přes WS nebo OLE.
// Důvodem je to, že ABRA nejspíš při ukládání v agendě porovnává hodnotu položky na základě property TNxSiteForm.ViewedDate,
// která je nastavena vizuálním prvkem v agendě. Přes OLE nebo WS nastavena není, proto dojde k nesprávnému porovnání
// a hodnota se vloží do historie, přestože se vůbec nemění.

// Funkci je potřeba volat ihned po uložení daného objektu (např. zaměstnance)

procedure CleanDuplicitHistoryWGData(OS: TNxCustomObjectSpace; AClassID, AObjID: string);
var
  mFieldCodes, mSQLResult: TStringList;
  mData: TMemoryDataset;
  mQuery, mLastValue, mLogFile: string;
  i: integer;
  mLastDateFrom: double;
begin
  mFieldCodes := TStringList.Create;
  try
    mQuery := 'SELECT DISTINCT FieldCode FROM HistoryWGData WHERE CLSID = '+QuotedStr(AClassID)+' AND ID = '+QuotedStr(AObjID)+' ';
    mFieldCodes := SQLSelectValues(OS, mQuery);
    for i := 0 to mFieldCodes.Count - 1 do begin
      mQuery := 'SELECT A.* FROM ( '+
      '  SELECT D.ValidFrom$DATE, D.StringFieldValue FROM HistoryWGData D WHERE D.CLSID = '+QuotedStr(AClassID)+' '+
      '  AND D.ID = '+QuotedStr(AObjID)+' AND D.FieldCode = '+QuotedStr(mFieldCodes[i])+' ORDER BY D.ValidFrom$DATE DESC) A ';
      if NxIsOracle then mQuery := mQuery + ' WHERE RowNum <= 2 ' else mQuery := mQuery + ' ROWS 1 TO 2 ';
      mSQLResult := TStringList.Create;
      try
        OS.SQLSelect(mQuery, mSQLResult);
      finally
        mSQLResult.Free;
      end;
      mData := TMemoryDataset.Create(nil);
      try
        OS.SQLSelect2(mQuery, mData);
        if mData.RecordCount > 1 then begin
          mData.First;
          mLastValue := mData.FieldByName('StringFieldValue').Text;
          mLastDateFrom := mData.FieldByName('ValidFrom$DATE').AsFloat;
          mData.Next;
          if (mData.FieldByName('StringFieldValue').Text = mLastValue) then begin
            mQuery := 'DELETE FROM HistoryWGData '+
            'WHERE CLSID = '+QuotedStr(AClassID)+' '+
            'AND ID = '+QuotedStr(AObjID)+' '+
            'AND FieldCode = '+QuotedStr(mFieldCodes[i])+' '+
            'AND ValidFrom$DATE = '+QuotedStr(NxFloatToIBStr(mLastDateFrom))+' '+
            'AND StringFieldValue = '+QuotedStr(mLastValue)+' ';
            OS.SQLExecute(mQuery);
          end;
        end;
      finally
        mData.Free;
      end;
    end;
  finally
    mFieldCodes.Free;
  end;

end;


// vrátí hodnotu historické položky personalistiky
// Klíčem je CLSID, ID objektu, datum platnosti a FieldCode
// pokud není hodnota nalezena, nebo je prázdná, pokusí se dostat hodnotu přímo z tabulky objektu

// OS - ObjectSpace
// ClassID - ID třídy (zaměstnanec, prac. poměr)
// TableName - název tabulky (pro případné získání hodnoty přímo)
// ID - ID cílového objektu
// FieldCode - field kód položky (int)
// FieldName - název fieldu v tabulce (pro případné získání hodnoty přímo) - může být prázdné, potom se hodnota takto nezískává
// ValidDate - datum platnosti položky
// TableSpave - nepovinný název TableSpace

// Vrací hodnotu v textové podobě

function GetHistoryWGDataValue(OS: TNxCustomObjectSpace; ClassID, TableName, ID: string; FieldCode: integer; FieldName: string; ValidDate: TDateTime; TableSpace: string = ''): string;
var
  mQuery: string;
begin
  if (TableSpace <> '') then TableSpace := TableSpace + '.';

  mQuery := 'SELECT StringFieldValue FROM '+TableSpace+'HistoryWGData WHERE ID = '+QuotedStr(ID)+' AND '+
  'FieldCode = '+QuotedStr(IntToStr(FieldCode))+' AND '+
  'ValidFrom$DATE <= '+QuotedStr(NxFloatToIBStr(ValidDate))+' AND '+
  'CLSID = '+QuotedStr(ClassID)+' ORDER BY ValidFrom$DATE DESC';
  Result := SQLSelectValue(OS, mQuery);
  if (Result = '') and (FieldName <> '') then begin
    mQuery := 'SELECT '+FieldName+' FROM '+TableName+' WHERE ID = '+QuotedStr(ID);
    Result := SQLSelectValue(OS, mQuery);
  end;
end;


begin
end.