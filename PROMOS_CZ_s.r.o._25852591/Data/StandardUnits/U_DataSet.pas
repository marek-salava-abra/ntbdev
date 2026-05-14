(*uses
  'StandardUnits.U_Gau';

///////////////////////////////////////////////////////////////////////////////
function DataSet_GetHeaderCSV(DS: TDataSet; Delimiter: char = ';'; StringQuote: boolean = false): string;
var
  i: integer;
begin
  result:= '';

  for i := 0 to DS.FieldList.Count - 1 do begin
    if(StringQuote)then begin
      if(i = 0)then
        result:= AnsiQuotedStr(DS.FieldList.Fields[i].FieldName, '"')
      else
        result:= result + Delimiter + AnsiQuotedStr(DS.FieldList.Fields[i].FieldName,'"');

    end else begin
      if(i = 0)then
        result:= DS.FieldList.Fields[i].FieldName
      else
        result:= result+Delimiter+DS.FieldList.Fields[i].FieldName;
    end;
  end;
end;//DataSet_GetHeader
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
//zapise hlavicku do streamu. Stream necisti, proste tam data zapise
procedure DataSet_WriteStreamCSVHeader(DS: TDataSet; var streamResult: TStream;
  Delimiter: char = ';'; StringQuote: boolean = false);
var
  i: integer;
begin
  for i := 0 to DS.FieldList.Count - 1 do begin
    if(i <> 0)then
      NxWriteString(streamResult, Delimiter);

    if(StringQuote)then
      NxWriteString(streamResult, AnsiQuotedStr(DS.FieldList.Fields[i].FieldName, '"'))
    else
      NxWriteString(streamResult, DS.FieldList.Fields[i].FieldName);
  end;
end;//DataSet_WriteStreamCSVHeader
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
//ForceTextFormat - prida na zacatek rovna se a tim vynuti potlaceni formatovani v excelu
function DataSet_GetDataCSV(DS: TDataSet; Delimiter: char = ';'; StringQuote: boolean = false; NahradLF : Boolean = False; ForceTextFormat: boolean = false): string;
var
  i    : integer;
  value: string;
  aux  : string;
begin
  result:= '';

  for i := 0 to DS.FieldList.Count - 1 do begin
    value:= DS.FieldList.Fields[i].AsString;
{    //pokud obsahuje uvozovky, tak zavru do uvozovek a zdvojim uvozovky
    if(Pos('"', value) > 0)then begin
      aux  := TrimRight(value)+'"';
      value:= '"';
      while(aux <> '')do begin
        value:= value+Copy(aux, 1, pos('"', aux));
        aux  := copy(aux, pos('"', aux)+1, length(aux));
        if(aux <> '')then value:= value+'"';
      end;

    //pokud obsahuje strednik, tak zavru do uvozovek
    end else if(Pos(';', value) > 0)then begin
      value:= '"'+value+'"';
    end;    }

    //orezani z prava
    if(DS.FieldList.Fields[i].DataType in [ftString, ftMemo, ftWideString, ftWideMemo])then
    begin
      value:= NxTrimR(value, ' ');
      if NahradLF then
      begin
        Value := NXSearchReplace(value, chr(10), ' ', [srAll]);
        Value := NXSearchReplace(value, chr(13), ' ', [srAll]);
      end;
    end;

    if((StringQuote AND (DS.FieldList.Fields[i].DataType in [ftString, ftMemo, ftWideString, ftWideMemo])) //string a mam uzavirat vzdy
      OR (Pos('"', value) >0) OR (Pos(';', value)>0))then   //uzaviram jen pokud obsahuje nevhodne znaky
      value:= AnsiQuotedStr(value,'"');

    //pridam na zacatek =. Ale jen tehdy, pokud neobsahuje zank ;. To se pak totiz hodnota neinterpretuje jako jeden sloupec
    if(ForceTextFormat AND (DS.FieldList.Fields[i].DataType in [ftString, ftMemo, ftWideString, ftWideMemo])) AND
     (pos(Delimiter, DS.FieldList.Fields[i].AsString) = 0)
    then
      value:= '='+value;

    if(i = 0)then
      result:= value
    else
      result:= result+Delimiter+value;
  end;
end;//DataSet_GetDataCSV
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
//ForceTextFormat - prida na zacatek rovna se a tim vynuti potlaceni formatovani v excelu
procedure DataSet_WriteStreamCSVData(DS: TDataSet; var streamResult: TStream;
  Delimiter: char = ';'; StringQuote: boolean = false; NahradLF : Boolean = False; ForceTextFormat: boolean = false);
var
  i    : integer;
  value: string;
  aux  : string;
begin
  for i := 0 to DS.FieldList.Count - 1 do begin
    value:= DS.FieldList.Fields[i].AsString;
    //orezani z prava
    if(DS.FieldList.Fields[i].DataType in [ftString, ftMemo, ftWideString, ftWideMemo])then
    begin
      value:= NxTrimR(value, ' ');
      if NahradLF then
      begin
        Value := NXSearchReplace(value, chr(10), ' ', [srAll]);
        Value := NXSearchReplace(value, chr(13), ' ', [srAll]);
      end;
    end;

    if((StringQuote AND (DS.FieldList.Fields[i].DataType in [ftString, ftMemo, ftWideString, ftWideMemo])) //string a mam uzavirat vzdy
      OR (Pos('"', value) >0) OR (Pos(';', value)>0))then   //uzaviram jen pokud obsahuje nevhodne znaky
      value:= AnsiQuotedStr(value,'"');

    //pridam na zacatek =. Ale jen tehdy, pokud neobsahuje zank ;. To se pak totiz hodnota neinterpretuje jako jeden sloupec
    if(ForceTextFormat AND (DS.FieldList.Fields[i].DataType in [ftString, ftMemo, ftWideString, ftWideMemo])) AND
     (pos(Delimiter, DS.FieldList.Fields[i].AsString) = 0)
    then
      value:= '='+value;

    if(i <> 0)then
      NxWriteString(streamResult, Delimiter);
    NxWriteString(streamResult, value);
  end;
end;//DataSet_WriteStreamCSVData*)
///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
//vytvoreni fieldu v datasetu
function DataSet_AddField(DS: TDataSet; FieldName: string;
                           FieldType:TFieldType; FieldSize: integer): TField;
var
  mFieldDef: TFieldDef;
  mField   : TField;
begin
  //MData.FieldDefs.Add('FileName', ftString, 40, True);  //toto nefunguje (nalezeno na netu)

  //toto je ze zdrojaku
  //Vytvooí se nová definice fieldu
  mFieldDef := TFieldDef.Create(DS.FieldDefs, FieldName, FieldType, FieldSize, true, 0);

  //Z Definice fieldu se vytvooí Field v datasetu
  mField           := mFieldDef.CreateField(DS, nil, 'fld_'+FieldName, False); //DoNotLocalize
  mField.ReadOnly  := False;
  mField.Size      := FieldSize;
  if  FieldName='' then
    fieldName:='NotDefinedName'+inttostr(ds.FieldCount);
  mField.FieldName := FieldName;
  mField.FieldKind := fkData; //Bude typu Data
  mField.Required  := false;

  result:= mField;
end;//DataSet_AddField
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
//vytvoreni fieldu v datasetu - rozsirene parametry
function DataSet_AddFieldExt(DS: TDataSet; FieldName: string;
                           FieldType:TFieldType; FieldSize: integer;
                           Visible: boolean; Alignment: tAlignment;
                           DisplayLabel: string; DisplayWidth: integer;
                           FieldKind: TFieldKind = fkData): TField;
var
  mFieldDef: TFieldDef;
  mField   : TField;
begin
  //MData.FieldDefs.Add('FileName', ftString, 40, True);  //toto nefunguje (nalezeno na netu)

  //toto je ze zdrojaku
  //Vytvooí se nová definice fieldu
  mFieldDef := TFieldDef.Create(DS.FieldDefs, FieldName, FieldType, FieldSize, true, 0);

  //Z Definice fieldu se vytvooí Field v datasetu
  mField           := mFieldDef.CreateField(DS, nil, 'fld_'+FieldName, False); //DoNotLocalize
  mField.ReadOnly  := False;
  mField.Size      := FieldSize;
  mField.FieldName := FieldName;
  mField.FieldKind := FieldKind;
  mField.Required  := false;
  mField.Visible   := Visible;
  mField.Alignment := Alignment;
  mField.DisplayLabel := DisplayLabel;
  if(DisplayWidth <> 0)then  mField.DisplayWidth:= DisplayWidth;

  result:= mField;
end;//DataSet_AddFieldExt
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
//vytvoreni hlavicky dle definice (vsechno string)
//Header - code=S10,mnoz=F,pocet=I
//Header rozsirena definice:
// - za typem (ktery je povinny pokud je uvedeno "=" a je vzdy hned za "=") moho nasledovat nepovinne parametry
// - ukazka: ID=S10;NotVisible,Person_Name=S60;Alignment=R;Label=Pracovník;Width=100;Kind=C
//  * NotVisible         - v gridu bude schovany
//  * Alignment=R/L/C    - v gridu bude doprava/doleva/centrovane
//  * Label=ahoj\szdar   - v gridu bude mit sloupec nazev ahoj POZOR, nemohu zde pouzit mezeru. Misto ni pisu \s (jako space)
//  * Width=10           - v gridu bude sirka slouce 10
//  * Kind=C             - TFieldKind. Standardne fkData/ Muze btl ale i fkCalculate (takze D, C, I, A)
procedure DataSet_CreataHeader(DS: TDataSet; Header: String);
var
 j: integer;
 jx: integer;
 sl: TStringList;
 slVal: TStringList;
 valTyp: string;
 valVisible: boolean;
 valAlignment: TAlignment;
 valLabel: string;
 valWidth: integer;
 valKind: TFieldKind;
begin
  //pokud je definovany Header, tak udalam hlavicku z nej
  if(trim(Header) <> '')then begin
    sl:= TStringList.Create;
    sl.StrictDelimiter:= true;
    sl.CommaText:= Header;

    slVal:= TStringList.Create;
    slVal.Delimiter:= ';';
    slVal.StrictDelimiter:= true;

    for j:= 0 to sl.Count - 1 do begin
      slVal.DelimitedText:= sl.ValueFromIndex[j];
      if(slVal.Count = 0)then RaiseException('Chyba při volání procedury "DataSet_CreataHeader". Nesprávná definice parametru "Header".');

      //prvni je vzdy typ pripadne velikost (toto je povinne)
      valTyp:= slVal.Strings[0];

      //dale mohou nasledovat hodnoty:
      //NotVisible
      //Alignment=R/L/C
      //Label=ahoj
      //Width

      //implicitni hodnoty
      valVisible:= true;
      valLabel  := sl.Names[j];
      valWidth  := 0;
      valKind   := fkData;

      //implicitni zarovnani podel typu
      case copy(valTyp,1,1) of
        'F','I','R','D','T','C': valAlignment:= taRightJustify;
        else valAlignment:= taLeftJustify;
      end;

      for jx:= 1 to slVal.Count - 1 do begin
        if(slVal.Strings[jx] = 'NotVisible')then begin
          valVisible:= false;
        end else if(pos('Alignment=', slVal.Strings[jx]) = 1)then begin
          case copy(slVal.Strings[jx], 11, 1) of
            'R': valAlignment:= taRightJustify;
            'C': valAlignment:= taCenter;
            'L': valAlignment:= taLeftJustify;
          end;
        end else if(pos('Label=', slVal.Strings[jx]) = 1)then begin
          valLabel:= AnsiReplaceStr(copy(slVal.Strings[jx], 7, 100), '\s', ' ');
        end else if(pos('Width=', slVal.Strings[jx]) = 1)then begin
          valWidth:= StrToIntDef(copy(slVal.Strings[jx], 7, 100), 0);
        end else if(pos('Kind=', slVal.Strings[jx]) = 1)then begin
          case copy(slVal.Strings[jx], 6, 1) of
            'D': valKind:= fkData;
            'C': valKind:= fkCalculated;
            'I': valKind:= fkInternalCalc;
            'A': valKind:= fkAggregate;
          end;
        end;
      end;

      case copy(valTyp,1,1) of
        'W', //kompatibilita s KOSMASEM
        'S': DataSet_AddFieldExt(DS, sl.Names[j], ftWideString, StrToInt(trim(copy(valTyp, 2, 10))), valVisible, valAlignment, valLabel, valWidth, valKind); //ftString
        'I': DataSet_AddFieldExt(DS, sl.Names[j], ftInteger   , 0, valVisible, valAlignment, valLabel, valWidth, valKind); //ftInteger
        'D': DataSet_AddFieldExt(DS, sl.Names[j], ftDate      , 0, valVisible, valAlignment, valLabel, valWidth, valKind); //ftDate
        'T': DataSet_AddFieldExt(DS, sl.Names[j], ftTime      , 0, valVisible, valAlignment, valLabel, valWidth, valKind); //ftTime
        'C': DataSet_AddFieldExt(DS, sl.Names[j], ftDateTime  , 0, valVisible, valAlignment, valLabel, valWidth, valKind); //ftDateTime
        'F': DataSet_AddFieldExt(DS, sl.Names[j], ftFloat     , 0, valVisible, valAlignment, valLabel, valWidth, valKind); //ftFloat
        'R': DataSet_AddFieldExt(DS, sl.Names[j], ftCurrency  , 0, valVisible, valAlignment, valLabel, valWidth, valKind); //ftCurrency
        'B': DataSet_AddFieldExt(DS, sl.Names[j], ftBoolean   , 0, valVisible, valAlignment, valLabel, valWidth, valKind); //ftBoolean
        'E', //kompatibilita s KOSMASEM
        'M': DataSet_AddFieldExt(DS, sl.Names[j], ftWideMemo  , 0, valVisible, valAlignment, valLabel, valWidth, valKind); //ftWideMemo
        'L': DataSet_AddFieldExt(DS, sl.Names[j], ftBlob      , 0, valVisible, valAlignment, valLabel, valWidth, valKind); //ftBlob

        else DataSet_AddField(DS, sl.Names[j], ftWideString, StrToInt(trim(sl.ValueFromIndex[j]))); //ftString
      end;

      //ShowMessage(sl.Strings[j]);
    end;
    sl.free;
    slVal.free;
  end;

  //otevru pro pridavani
  DS.Open;
end;//DataSet_CreataHeader
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
//FileType = csv, xls, tab=txt soubor oddeleny tabulatorem
//Header - prazdna = nacte se z 1. radku
(*procedure DataSet_LoadWithProfGrid(FileType: string; Form: TForm; DS: TDataSet; FileName: string; Header: String; Sheet: variant);
var
 ProfGrid: tProfGrid;
 i, j, ji: integer;
 maxlen  : integer;
 RowStart: integer;
 ColStart: integer;
 sl: TStringList;
 aux: string;
begin
  if(not FileExists(FileName))then
      RaiseException('File not found: '+FileName);

  ColStart:= DS.FieldList.Count; //v datasetu jiz mohou byt rucne pridany sloupce

  ProfGrid:= tProfGrid.Create(Form);
  try
    ProfGrid.Parent := Form;
    ProfGrid.Visible:= false;
    ProfGrid.RowCount:=-1;
    ProfGrid.ColCount:=-1;

    //pokud mam header (vim kolik je sloupcu), tak vsem nastavim format text=@
    if(trim(Header) <> '')then begin
      //zjistim a nastavim pocet sloupcu
      sl:= TStringList.Create;
      sl.CommaText:= Header;
      ProfGrid.ColCount:= sl.Count;
      sl.free;
      //nastavim format
      for j:= 0 to ProfGrid.ColCount - 1 do begin
        ProfGrid.Cols[j].Format:= '@';
        ProfGrid.Cols[j].FixedRowsFormat:= '@'; //toto nevim jesteli je potreba
      end;
    end else begin
      //pokud nedefinuju hlavicku, tak nevim kolik je sloupcu a pak nemuzu nastavit formatovani
      //alespon nevim jak
    end;

    //import
    case FileType of
      'csv': ProfGrid.LoadFromCSV(FileName,0,0,Encoding_cp1250);
      'tab': ProfGrid.LoadFromTabDelimited(FileName);
      'xls': ProfGrid.ImportFromExcelFile(FileName, Sheet);
      else RaiseException('FileType not upported: '+FileType);
    end;

    //pokud je definovany Header, tak udalam hlavicku z nej
    if(trim(Header) <> '')then begin
      RowStart:= 0;
      sl:= TStringList.Create;
      sl.CommaText:= Header;
      for j:= 0 to sl.Count - 1 do begin
        case copy(sl.ValueFromIndex[j], 1, 1) of
          'W',
          'S': DataSet_AddField(DS, sl.Names[j], ftWideString, StrToInt(trim(copy(sl.ValueFromIndex[j], 2, 10)))); //ftString
          'I': DataSet_AddField(DS, sl.Names[j], ftInteger   , 0); //ftInteger
          'D': DataSet_AddField(DS, sl.Names[j], ftDate      , 0); //ftDate
          'T': DataSet_AddField(DS, sl.Names[j], ftTime      , 0); //ftTime
          'C': DataSet_AddField(DS, sl.Names[j], ftDateTime  , 0); //ftDateTime
          'F': DataSet_AddField(DS, sl.Names[j], ftFloat     , 0); //ftFloat
          'E',
          'M': DataSet_AddField(DS, sl.Names[j], ftWideMemo  , 0); //ftWideMemo

          else DataSet_AddField(DS, sl.Names[j], ftWideString, StrToInt(trim(sl.ValueFromIndex[j]))); //ftString
        end;
        //ShowMessage(sl.Strings[j]);
      end;
      sl.free;
    //jinak z prvniho radku CSV
    end else begin
      RowStart:= 1;
      for j:= 0 to ProfGrid.ColCount - 1 do begin
        maxlen:= 1;
        for ji:= 1 to ProfGrid.RowCount-1 do begin
          if(length(ProfGrid.Cells[j, ji].Text) > maxlen)then
            maxlen:= length(ProfGrid.Cells[j, ji].Text);
        end;
        DataSet_AddField(DS, ProfGrid.Cells[j, 0].Text, ftWideString, maxlen);
        //ShowMessage('('+IntToStr(i)+','+IntToStr(j)+')'+ProfGrid.Cells[j, i].Text);
      end;
    end;

    //test ze je prvni radek neprazdny (ProfGrid totiz obsahuje vzdy min. 1 radek a 1. sloupec)
    for j:= 0 to ProfGrid.ColCount - 1 do
      aux:= aux + trim(ProfGrid.Cells[j, RowStart].Text);

    if(aux <> '')then begin
      DS.Open;
      for i:= RowStart to ProfGrid.RowCount - 1 do begin
        DS.Append;
        for j:= ColStart to min(DS.Fields.Count, ProfGrid.ColCount) - 1 do begin
          if  DS.Fields[j].dataType=ftfloat then
            DS.Fields[j].AsFloat:= NxStrToFloat(ReplaceStr(ProfGrid.Cells[j-ColStart, i].Text,'.',','), ',')
          else
            DS.Fields[j].AsString:= ProfGrid.Cells[j-ColStart, i].Text;
          //ShowMessage('('+IntToStr(i)+','+IntToStr(j)+')'+ProfGrid.Cells[j, i].Text);
        end;
        DS.Post;
      end;
    end;
  finally
    ProfGrid.free;
  end;
end;//DataSet_LoadWithProfGrid
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
//nacte CSV file do datesetu
//Header - prazdna = nacte se z 1. radku
procedure DataSet_LoadFromCSV(Form: TForm; DS: TDataSet; FileName: string; Header: String);
begin
  DataSet_LoadWithProfGrid('csv', Form, DS, FileName, Header, 0);
end;//DataSet_LoadFromCSV
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
//nacte CSV file oddeleny TABulatorem do datesetu
//Header - prazdna = nacte se z 1. radku
procedure DataSet_LoadFromCSVtab(Form: TForm; DS: TDataSet; FileName: string; Header: String);
begin
  DataSet_LoadWithProfGrid('tab', Form, DS, FileName, Header, 0);
end;//DataSet_LoadFromCSVtab
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
//nacte XLS file do datesetu
//Header - prazdna = nacte se z 1. radku
procedure DataSet_LoadFromXLS(Form: TForm; DS: TDataSet; FileName: string; Header: String; Sheet: variant = 1);
begin
  DataSet_LoadWithProfGrid('xls', Form, DS, FileName, Header, Sheet);
end;//DataSet_LoadFromXLS
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
//ForceTextFormat - prida na zacatek rovna se a tim vynuti potlaceni formatovani v excelu
procedure DataSet_SaveToCSV(DS: TDataSet; FileName: string;
  SaveHeader: boolean; Delimiter: char = ';'; StringQuote: boolean = false; NahradLF : Boolean = False; ForceTextFormat: boolean = false; encoding: TEncoding = nil);
var
  sl: TStringList;
begin
  sl:= TStringList.Create();
  try
    //ulozit hlavicku?
    if(SaveHeader)then begin
      sl.Add(DataSet_GetHeaderCSV(DS, Delimiter, StringQuote));
    end;

    //ulozim data
    if(DS.Active)then begin
      DS.First;
      while(not DS.Eof)do begin
        sl.Add(DataSet_GetDataCSV(DS, Delimiter, StringQuote, NahradLF, ForceTextFormat));
        DS.next;
      end;
    end;

    sl.SaveToFile(Filename, encoding);
  finally
    sl.free;
  end;
end;//DataSet_SaveToCSV
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
//vyexportuje dataset do podoby CSV a zapise je do streamu.
//Ten musi byt vytvoreny. Stream se nenuluje, datase do nej pridaji
//ForceTextFormat - prida na zacatek rovna se a tim vynuti potlaceni formatovani v excelu
procedure DataSet_WriteStreamCSV(DS: TDataSet; var streamResult: TStream;
  SaveHeader: boolean; Delimiter: char = ';'; StringQuote: boolean = false;
  NahradLF : Boolean = False; ForceTextFormat: boolean = false);
begin
  //ulozit hlavicku?
  if(SaveHeader)then begin
    DataSet_WriteStreamCSVHeader(DS, streamResult, Delimiter, StringQuote);
    NxWriteString(streamResult, #13#10);
  end;

  //ulozim data
  if(DS.Active)then begin
    DS.First;
    while(not DS.Eof)do begin
      DataSet_WriteStreamCSVData(DS, streamResult, Delimiter, StringQuote, NahradLF, ForceTextFormat);
      NxWriteString(streamResult, #13#10);
      DS.next;
    end;
  end;
end;//DataSet_SaveToCSV
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
//! nejsou osetrene nestandardni znaky (, ")
//konstanty pro formaty souboru excelu
//xlCSV, xlExcel5, ....
procedure DataSet_SaveToXLS(Form: TForm; DS: TDataSet; FileName: string; SaveHeader: boolean; FileFormat: integer = xlExcel5);
var
  ProfGrid: tProfGrid;
  sl: TStringList;
begin
  sl:= TStringList.Create;
  ProfGrid:= tProfGrid.Create(Form);
  try
    ProfGrid.Parent := Form;
    ProfGrid.Visible:= false;
    ProfGrid.RowCount:= DS.RecordCount;
    ProfGrid.ColCount:= 1;

    //ulozit hlavicku?
    if(SaveHeader)then begin
      ProfGrid.RowCount:= DS.RecordCount + 1;
      sl.Add(DataSet_GetHeaderCSV(DS, chr(9)));
    end;

    //ulozim data
    if(DS.Active)then begin
      DS.First;
      while(not DS.Eof)do begin
        sl.Add(DataSet_GetDataCSV(DS, chr(9)));
        DS.next;
      end;
    end;

    ProfGrid.LoadFromStrings(sl);
    if(not ProfGrid.ExportToExcelFile(FileName, FileFormat))then
      RaiseException('Chyba poi ukládání souboru: '+FileName);
  finally
    ProfGrid.free;
    sl.free;
  end;
end;//DataSet_SaveToXLS
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
//tato funkce by se mela volat jen na unikatni radek
//najde radek s hodnotou v pozadovanem poli a zustane stat na tomto radku
function DataSet_GetRowByKey(DS: TDataSet; FieldName, Value: string): boolean;
begin
  result:= false;

  if(DS.Active)then begin
    DS.First;
    while(not DS.Eof)do begin
      if(trimRight(DS.FieldByName(FieldName).Value) <> trimRight(Value))then begin
        DS.next;
        continue;
      end;
      result:= true;
      break;
    end;
  end;
end;//DataSet_GetRowKey
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
//nastaveni hlavicky dle jineho datasetu
procedure DataSet_CreataHeaderFromDS(aDesc, aSource: TDataSet);
var
  i: integer;
begin
  NxCloneFields(aSource, aDesc); //existuje standardni funkce. Nevim jestli vola OPEN

  {for i := 0 to aSource.FieldList.Count - 1 do
    DataSet_AddField(aDesc, aSource.FieldList.Fields[i].FieldName, aSource.FieldList.Fields[i].DataType, aSource.FieldList.Fields[i].Size);
  }
  aDesc.Open;
end;//DataSet_CreataHeaderFromDS
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
//prekopirovani hodnod aktualniho radku do ciloveho datasetu
//MUSI MIT STEJNOU STRUKTURU (i poradi sloupcu)
procedure DataSet_FieldFromDS(aDesc, aSource: TDataSet);
var
  i: integer;
begin
  for i := 0 to aSource.FieldList.Count - 1 do begin
    aDesc.Fields[i].AsVariant:= aSource.Fields[i].AsVariant;
  end;
end;//DataSet_FieldFromDS
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
function DataSet_FieldExist(DS: TDataSet; name: string): boolean;
var
  i: integer;
begin
  result:= false;
  for i := 0 to DS.FieldList.Count - 1 do begin
    if(AnsiUpperCaseFileName(DS.Fields[i].FieldName) <> AnsiUpperCaseFileName(name))then continue;
    result:= true;
    break;
  end;
end;//DataSet_FieldExist
///////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////
//nastaveni jiz existujici hlavicky
//Header - FIELDNAME;PARAMETR=HODNOTA[;PARAMETR=HODNOTA][,FIELDNAME;PARAMETR=HODNOTA[;PARAMETR=HODNOTA]]
// - ukazka: ID;NotVisible,Person_Name;Alignment=R;Label=Pracovník;Width=100
//  * NotVisible         - v gridu bude schovany
//  * Alignment=R/L/C    - v gridu bude doprava/doleva/centrovane
//  * Label=ahoj zdar    - v gridu bude mit sloupec nazev ahoj zdar
//  * Width=10           - v gridu bude sirka slouce 10
procedure DataSet_SetHeader(DS: TDataSet; Header: String);
var
{ j: integer;
 jx: integer;
 sl: TStringList;
 slVal: TStringList; }
 aFieldName: string;
 aField: tfield;

 aHeaders: string;
 aHeader : string;
 aValues : string;
 aValue  : string;

begin
  //pokud je definovany Header, tak udalam hlavicku z nej
  if(trim(Header) <> '')then begin
    aHeaders:= trim(Header)+',';//pridam zarazku

    while(pos(',', aHeaders) > 1)do begin
      aHeader:= copy(aHeaders, 1, pos(',', aHeaders)-1);
      aHeaders:= copy(aHeaders, pos(',', aHeaders)+1, 200);

      //prvni je vzdy FieldName
      aValues:= aHeader;
      if(pos(';', aValues) <= 1)then continue;
      aFieldName:= copy(aValues, 1, pos(';', aValues)-1);
      aField:= ds.FieldByName(aFieldName);

      aValues:= copy(aValues, pos(';', aValues)+1, 500)+';'; //pridam zarazku

      //dale mohou nasledovat hodnoty:
      //NotVisible
      //Alignment=R/L/C
      //Label=ahoj
      //Width

      while(pos(';', aValues) > 1)do begin
        aValue:= copy(aValues, 1, pos(';', aValues)-1);
        aValues:= copy(aValues, pos(';', aValues)+1, 200);

        if(aValue = 'NotVisible')then begin
          aField.Visible:= false;
        end else if(pos('Alignment=', aValue) = 1)then begin
          case copy(aValue, 11, 1) of
            'R': aField.Alignment:= taRightJustify;
            'C': aField.Alignment:= taCenter;
            'L': aField.Alignment:= taLeftJustify;
          end;
        end else if(pos('Label=', aValue) = 1)then begin
          aField.DisplayLabel:= AnsiReplaceStr(copy(aValue, 7, 100), '\s', ' ');
        end else if(pos('Width=', aValue) = 1)then begin
          aField.DisplayWidth:= StrToIntDef(copy(aValue, 7, 100), 0);
        end;
      end;

      //ShowMessage(sl.Strings[j]);
    end;
  end;
end;//DataSet_CreataHeader
///////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//Grid - pokud je predan, vezmou se z nej sloupce
//aExcelApp - pokud si predam, budu pracovat s timto a nezavru jej. Jinak si vytvorim vlastni a zavru
procedure DataSet_ExportToXlsOLE(Form: TForm; ds: TDataSet; ColumnAutoFit: boolean; SheetName: string = 'Export'; Grid: TDBGrid = nil; aExcelApp: Variant = nil);
  //----------------------------------------------------------------------------
  function getXlsAligment(Alignment: TAlignment): integer;
  begin
    case Alignment of
      taLeftJustify : result:= 2;
      taCenter      : result:= 3;
      taRightJustify: result:= 4;
      else  result:= 2;
    end;
  end;
  //----------------------------------------------------------------------------

var
  mExcelApp     : Variant;
  Radek, Sloupec,Sloupec1: integer;
  fields: Variant;
begin
  if not ds.Active then
    exit;

  if(VarType(aExcelApp) = varByte)then //vyzkousel jsem, ze pokud je do Variant prirazen nil, tak je hodnota 17 = varByte
    mExcelApp := CreateOleObject('Excel.Application')
  else
    mExcelApp:= aExcelApp;
  fields:= nil;

  mExcelApp.Workbooks.Add;
  mExcelApp.Visible := False;
  mExcelApp.Sheets(1).Name := SheetName;
  try
    //hlavicka
    if(Grid = nil)then begin
      //hlavicka z datasetu
      fields:= VarArrayCreate([0,DS.FieldList.Count- 1], varInteger);
      Sloupec1:= 0;

      for Sloupec := 0 to DS.FieldList.Count - 1 do begin
        if(not DS.FieldList.Fields[Sloupec].Visible)then continue;
        if(DS.FieldList.Fields[Sloupec].DisplayWidth <> 0)then begin
          if(DS.FieldList.Fields[Sloupec].DisplayWidth > 255)then
            mExcelApp.Columns(Sloupec1+1).ColumnWidth        := 255
          else
            mExcelApp.Columns(Sloupec1+1).ColumnWidth        := DS.FieldList.Fields[Sloupec].DisplayWidth;
        end;
        mExcelApp.Columns(Sloupec1+1).HorizontalAlignment:= getXlsAligment(DS.FieldList.Fields[Sloupec].Alignment);
        mExcelApp.Cells(1, Sloupec1+1).Value             := DS.FieldList.Fields[Sloupec].DisplayLabel;
        mExcelApp.Cells(1, Sloupec1+1).Font.Bold         := True;

        fields[Sloupec1]:= Sloupec;
        Sloupec1:=Sloupec1+1;
      end;
    end else begin
      //hlavicka z gridu
      fields:= VarArrayCreate([0,Grid.FieldCount- 1], varInteger);
      Sloupec1:= 0;

      for Sloupec := 0 to Grid.Columns.Count- 1 do begin
        if(not Grid.Columns.Items[Sloupec].Visible)then continue;
        if(Grid.Columns.Items[Sloupec].Width <> 0)then begin
          if(Grid.Columns.Items[Sloupec].Width > 255)then
            mExcelApp.Columns(Sloupec1+1).ColumnWidth        := 255
          else
            mExcelApp.Columns(Sloupec1+1).ColumnWidth        := Grid.Columns.Items[Sloupec].Width;
        end;
        mExcelApp.Columns(Sloupec1+1).HorizontalAlignment:= getXlsAligment(Grid.Columns.Items[Sloupec].Alignment);
        mExcelApp.Cells(1, Sloupec1+1).Value             := Grid.Columns.Items[Sloupec].Title.Caption;
        mExcelApp.Cells(1, Sloupec1+1).Font.Bold         := True;

        fields[Sloupec1]:= ds.FieldByName(Grid.Columns.Items[Sloupec].FieldName).Index;
        Sloupec1:=Sloupec1+1;
      end;

    end;

    if(Assigned(Form))then
    	GauInit(Form, ds.RecordCount, 'Export dat do excelu...');
  	try
      ds.DisableControls;
      ds.first;
      Radek := 2;
      while(not ds.eof)do begin
        if(Assigned(Form)) AND (not gau)then break;
        for Sloupec := 0 to Sloupec1 - 1 do begin
          case DS.FieldList.Fields[fields[Sloupec]].DataType of
            ftInteger : begin
              mExcelApp.Cells(Radek, Sloupec+1).Value:= DS.FieldList.Fields[fields[Sloupec]].AsInteger;
              mExcelApp.Cells(Radek, Sloupec+1).NumberFormat:= '# ##0';
            end;

            ftDate    : mExcelApp.Cells(Radek, Sloupec+1).Value:= DS.FieldList.Fields[fields[Sloupec]].AsDateTime;

            ftTime    : mExcelApp.Cells(Radek, Sloupec+1).Value:= DS.FieldList.Fields[fields[Sloupec]].AsDateTime;

            ftDateTime: mExcelApp.Cells(Radek, Sloupec+1).Value:= DS.FieldList.Fields[fields[Sloupec]].AsDateTime;

            ftFloat: begin
              mExcelApp.Cells(Radek, Sloupec+1).Value:= DS.FieldList.Fields[fields[Sloupec]].AsFloat;
              mExcelApp.Cells(Radek, Sloupec+1).NumberFormat:= '# ##0,00';
            end;

            ftCurrency: begin
              mExcelApp.Cells(Radek, Sloupec+1).Value:= DS.FieldList.Fields[fields[Sloupec]].AsCurrency;
              mExcelApp.Cells(Radek, Sloupec+1).NumberFormat:= '# ##0,00';
            end;

            ftBoolean : mExcelApp.Cells(Radek, Sloupec+1).Value:= DS.FieldList.Fields[fields[Sloupec]].AsBoolean;

            else begin
              //pokud je text mozne prevest na cislo, tak pred nej pridam apostrof
              if(DS.FieldList.Fields[fields[Sloupec]].AsString = '0')or
                (StrToFloatDef(DS.FieldList.Fields[fields[Sloupec]].AsString,0) <> 0)then
                mExcelApp.Cells(Radek, Sloupec+1).Value:= ''''+DS.FieldList.Fields[fields[Sloupec]].AsString
              else
                mExcelApp.Cells(Radek, Sloupec+1).Value:= DS.FieldList.Fields[fields[Sloupec]].AsString;
              mExcelApp.Cells(Radek, Sloupec+1).NumberFormat:= '@';
            end;
          end;
        end;

        Radek := Radek + 1;
        ds.next;
      end;

      //autofit sloupcu
      if(ColumnAutoFit)then begin
        mExcelApp.Cells.EntireColumn.AutoFit;

        //zkontroluju, jestli neni nejakej pripiz sirokej. pripadne jej zmensim
        for Sloupec := 0 to Sloupec1-1 do begin
          if(mExcelApp.Columns(Sloupec+1).ColumnWidth > 100)then
            mExcelApp.Columns(Sloupec+1).ColumnWidth:= 100;
        end;
      end;
    finally
      ds.EnableControls;
      if(Assigned(Form))then
        GauClose;
    end;
  finally
 	  //mExcelApp.Visible := true;
    VarClear(fields); //je zverejneno do skriptu od verze 9.01.01

      if(VarType(aExcelApp) = varByte)then begin //nebly poslan v parametru = nil
      mExcelApp.Quit;
      mExcelApp:= nil;
    end;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//AOOApp - pokud si predam, budu pracovat s timto
procedure DataSet_ExportToOpenOfficeOLE(Form: TForm; ds: TDataSet; ColumnAutoFit, ColumnFormat: boolean; SheetName: string = 'Export'; AOOApp: Variant = nil);
var
  mOOApp: Variant;
  mOODesktop: Variant;
  mOODocument: Variant;
  mOODocument1: Variant;
  mOOParams: Variant;
  mOOSaveParams: Variant;
  mOODispatcher: Variant;
  mOOSheet : Variant;
  mOOCell : Variant;
  mFileName : String;
  mNames: TStringList;
  I : Integer;
  mDF: TField;

  function iCreateOOValue(AOOApp: Variant; AName: string; AValue: variant): variant;
  begin
    Result :=  AOOApp.Bridge_GetStruct('com.sun.star.beans.PropertyValue');
    Result.Name := AName;
    Result.Value := AValue;
  end;
  function iGetOONumberFormatId(mOOApp: Variant; AOODoc: Variant; ANumberFormat: String): Variant;
  var
    mCharLocale: Variant;
    mNumberFormats: Variant;
    mFormatId: Integer;
  begin
    mCharLocale := mOOApp.Bridge_GetStruct('com.sun.star.lang.Locale');
    mCharLocale.Language := '';
    mCharLocale.Country := '';

    // OO pada, kdyz je ve formatovacim retezci mezera, ale pritom tam patri
    //ANumberFormat := StringReplace(ANumberFormat, ' ', ',', [rfReplaceAll]);
    mNumberFormats := AOODoc.NumberFormats;
    mFormatId := mNumberFormats.queryKey(ANumberFormat, mCharLocale, true);
    if mFormatId = -1 then
    begin
      try
        mFormatId := mNumberFormats.addNew(ANumberFormat, mCharLocale);
      except
        mFormatId := 4;
      end;
    end;
    Result := mFormatId;
  end;
  function iConvertDelphiFormatToExcelFormat(ADelphiFormat: String): String;
  var
    mExcelFormat, mTail: String;
    i, mDecimalPlaces: Integer;
    mDelphiFormat: String;
  begin
    // pokud je format prazdny, vracime @
    if ADelphiFormat = '' then
    begin
      Result := '@';
      exit;
    end;

    if pos(';', ADelphiFormat) = 0 then
      mDelphiFormat := ADelphiFormat
    else
      mDelphiFormat := copy(ADelphiFormat, 1, pos(';', ADelphiFormat) - 1);

    // nejdriv poresime oddelovac tisicu
    if pos(',', mDelphiFormat) = 0 then
      mExcelFormat := '0'
    else
      mExcelFormat := '# ##0';

    // pak pocet desetinnych mist
    if pos('.', mDelphiFormat) <> 0 then
    begin
      mTail := copy(mDelphiFormat, pos('.', mDelphiFormat) + 1, length(mDelphiFormat));
      mDecimalPlaces := 0;
      for i := 1 to length(mTail) do
        if mTail[i] = '0' then
          Inc(mDecimalPlaces);
      if mDecimalPlaces > 0 then
        mExcelFormat := mExcelFormat + ',';
      for i := 1 to mDecimalPlaces do
        mExcelFormat := mExcelFormat + '0';
    end;
    Result := mExcelFormat;
  end;

begin
  if not ds.Active then
    exit;

  if(VarType(AOOApp) = varByte)then //vyzkousel jsem, ze pokud je do Variant prirazen nil, tak je hodnota 17 = varByte
    mOOApp := CreateOleObject('com.sun.star.ServiceManager')
  else
    mOOApp:= AOOApp;

  mFileName := NxCorrectPath(NxGetTempDir)+CFxGuid.CreateNew+'.csv';
  if FileExists(mFileName) then
    DeleteFile(mFileName);
  DataSet_SaveToCSV(ds, mFileName, True, Chr(9), False, True);
  mOODesktop := mOOApp.CreateInstance('com.sun.star.frame.Desktop');
  mNames := TStringList.Create;
  try
    mOOParams := VarArrayCreate([0, 2], varVariant);
    mOOParams[0]:= iCreateOOValue(mOOApp, 'FilterName', 'Text - txt - csv (StarCalc)');
    mOOParams[1]:= iCreateOOValue(mOOApp, 'FilterOptions', '9,34,0,1,1/1/1/1/1/1/1/1');
    mOOParams[2]:= iCreateOOValue(mOOApp, 'Hidden', true);
    mOODocument := mOODesktop.loadComponentFromURL(
      'file:///' + StringReplace(mFileName, '\', '/', [rfReplaceAll]),
      '_blank', 0, mOOParams);
    VarClear(mOOParams);
    //vytvoření prázdného
//    mOOParams := VarArrayCreate([0, -1], varVariant);
//    mOODocument := mOODesktop.loadComponentFromURL('private:factory/scalc','_Default', 0, mOOParams); //Vytvoreni dokumentu

//název záložky
    mOODocument1 := mOODocument.CurrentController.Frame;
    mOODispatcher := mOOApp.CreateInstance('com.sun.star.frame.DispatchHelper');
    mOOParams := VarArrayCreate([0, 0], varVariant);
    mOOParams[0]:= iCreateOOValue(mOOApp, 'Name', SheetName);
    mOODispatcher.executeDispatch(mOODocument1, '.uno:RenameTable', '', 0, mOOParams);

//příklad pro změnu konkrétní buňky
{    mOOSheet := mOODocument.GetSheets().GetByIndex(0); //Vyhledani zalozky v dokumentu podle cisla cisluje se od 0
    mOOCell := mOOSheet.GetCellByPosition(0,0);  //Vyhledani bunky na zalozce podle pozice cislo sloupce ,cislo radku
    mOOCell.setString('HelloWord');            //Zapsani textu do bunky
    mOOCell := mOOSheet.GetCellByPosition(0,1);
    mOOCell.SetValue(345);                      //Zapsani cisla do bunky
    mOOCell := mOOSheet.GetCellByPosition(0,2);
    mOOCell.SetValue(854);
    mOOCell := mOOSheet.GetCellByPosition(0,3);
    mOOCell.SetFormula('=A2+A3');               //Zapsani vzorce do bunky
}
    ds.GetFieldNames(mNames);
    //formátování
    if ColumnFormat then
    begin
      For I := 0 to mNames.Count - 1 do
      begin
        mDF := ds.FindField(mNames[I]);
        if Assigned(mDF) then
        begin
          mDF := ds.FieldByName(mNames[I]);
          if mDF is TNumericField then
            mOODocument.getSheets.getByIndex(0).getColumns.getByIndex(i).setPropertyValue('NumberFormat',
              iGetOONumberFormatId(mOOApp, mOODocument, iConvertDelphiFormatToExcelFormat(TNumericField(mDF).DisplayFormat)));
          if mDF.DataType in [ftString, ftWideString] then
            mOODocument.getSheets.getByIndex(0).getColumns.getByIndex(i).setPropertyValue('NumberFormat',
              iGetOONumberFormatId(mOOApp, mOODocument, iConvertDelphiFormatToExcelFormat('')));
        end;
      end;
    end;
    //autofit sloupcu, zkontroluju, jestli neni nejakej moc sirokej, pripadne ho zmensim
    if ColumnAutoFit then
    begin
      for i := 0 to mNames.Count - 1 do
      begin
        mOODocument.getSheets.getByIndex(0).getColumns.getByIndex(i).setPropertyValue('OptimalWidth', True);  //DoNotLocalize
      end;
    end;
//zápis dokumentu
//    mOOSaveParams := VarArrayCreate([0, -1], varVariant);
//    mOODocument.StoreAsURL('file:///'+_FileName,mOOSaveParams);

  finally
    mOODocument.getCurrentController.getFrame.getContainerWindow.setVisible(true);
    mNames.Free;
    mNames := nil;
    VarClear(mOOParams);
  end;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//vytvori datasource a dataset na predanem formulari
procedure Create_DSDT(
  AOwner : TComponent;
  var ds : TDataSource;
  var dt : TMemTable;
  AName  : string;
  AHeader: string
  );
begin
  dt:= TMemTable.Create(AOwner);
  dt.Name:= 'dt'+AName;
  DataSet_CreataHeader(dt, AHeader);

  ds:= TDataSource.Create(AOwner);
  ds.Name:= 'ds'+AName;
  ds.DataSet:= dt;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//zalogovani datasetu
procedure DataSet_LogWrite(log: TNxCustomLog; logLevel: TNxLogLevel; ds: TDataSet; descr: string = '');
var
  sl: TMemoryStream;
begin
  if(log.Level >= logLevel)then begin
    sl:= TMemoryStream.create();
    try
      if(descr <> '')then
        log.WriteEvent(logDebug, descr);

      if(ds.active)then begin
        DataSet_WriteStreamCSV(ds,sl,true);
        log.WriteEvent(logLevel, NxReadString(sl));
      end else begin
        log.WriteEvent(logLevel, '===PRAZDNY DATASET===');
      end;
    finally
      sl.free;
    end;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//vlozi novy z radek a zkopiruje hodnoty z aktualniho
procedure DataSet_AppendCurrent(Dataset:Tdataset);
var
  aField : Variant;
  i      : Integer;
begin
  // Create a variant Array
  aField := VarArrayCreate(
               [0,DataSet.Fieldcount-1],
                             VarVariant);
  // read values into the array
  for i := 0 to (DataSet.Fieldcount-1) do
  begin
     aField[i] := DataSet.fields[i].Value ;
  end;
  DataSet.Append ;
  // Put array values into new the record
  for i := 0 to (DataSet.Fieldcount-1) do
  begin
     DataSet.fields[i].Value := aField[i] ;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//precteni radku ze streamu. Po precteni stojim na dalsim radku.
function Stream_ReadLine(Stream: TStream; var Line: string; Encoding: TEncoding = TEncoding.ANSI): boolean;
const
  BUF_LEN = 1024;
var
  buffer: Pointer;
  mLine: TMemoryStream;
  bufLen: LongInt;
  i: LongInt;

  ch1: string;
x:integer;
  LBuffer: string;
  endLine: boolean;
begin
  result := False;
  mLine:= TMemoryStream.Create;
  try
    SetLength(LBuffer, BUF_LEN);
    buffer:= @LBuffer;
    bufLen:= Stream.Read(buffer, BUF_LEN);
    result:= bufLen > 0;
    i:= 0;
    endLine:= false;

    while(bufLen > 0) and (not endLine) do begin
      ch1:= Encoding.GetString(TEncoding.Unicode.GetBytes(LBuffer));
      for i:= 1 to bufLen do begin
        if(ch1[i] in [#13, #10])then begin
          if(ch1[i] = #13) and (i < bufLen) then begin
            if(ch1[i+1] = #10)then
              inc(i);
          end;
          endLine:= true;
          break;
        end;
        NxWriteString(mLine, ch1[i]);
      end;
      if(endLine)then break;
      //nejsem na konci radku ani na konci souboru
      if(bufLen > 0) and (Stream.Position < Stream.Size)then
        bufLen:= Stream.Read(buffer, BUF_LEN)
      else
        break;
    end;

    Stream.Seek_1(-(bufLen-i), soCurrent);

    Line:= NxReadString(mLine);
  finally
    mLine.Free;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//nacteni CSV do datasetu pomoci binarniho cteni souboru po blocich (TFileStream)
//na konci datasetu mohou byt definovany sloupce s nazvem XX_..., ty nejsou v csv souboru a pri nacitani se ignoruji.
//-specialne sloupec XX_RowIndex - bude se plnit cislem radku
procedure DataSet_LoadFromCSV1(
  aFile: string;
  dt: TDataSet;

  HeaderRow: integer = 0; //hodnota vetsi nez 0 udava radek s hlavickou. Hlavicka muze byt vyuzita pro naparovani sloupcu na dataset (tj. ze nemusim mit v DS vsechny sloupce)
    //mapuje se bud podle DisplayLabel (pokud je neprazdny) nebo podle FieldName
  FromRow: integer = 1; //data zacinaji na radku
  Encoding: TEncoding = TEncoding.ANSI;
  slError: TStringList = nil; //sem se plni chyby pri cteni, pokud se nepodarila pretypovat nejaka hodnota ve sloupci. V pripade chyby se radek vlozi, ale hosnota sloupce bude defaultni (tj. nula, false nebo prazdny text)

  delimiter: char = ';'; //oddelovac sloupcu
  DecimalSep: char = '.';
  BoolValTrue: string = 'A';
  QuoteChar : char = '"';

  HeaderFieldMapping: string = ''; //mapovani nazvu fieldu v DS na sloupec v CSV (sloupce cislovane od 1 nebo A). Text ve tvaru: 'Smlouva=3,Quantity=H'
  Form: TForm = nil; //slouzi pouze pro zobrazeni gaugy. Muze byt nil, pak se gauga nezobrazi
  ccaRowSize: integer = 1;  //zhruba delka radku. Pouzije se pro vypocteni poctu zaznamu do GAU
  aEnableEmptyValue: boolean = false //prazdnou hodnotu beru jako nulu (u cisla a datumu)
);
var
  mFile: TFileStream;
begin
  mFile:= TFileStream.Create(aFile, fmOpenRead);
  try
    DataSet_LoadFromCSV1a(mFile, dt, HeaderRow, FromRow, Encoding, slError, delimiter, DecimalSep, BoolValTrue, QuoteChar, HeaderFieldMapping, Form, ccaRowSize, aEnableEmptyValue);
  finally
    mFile.free;
  end;
end;

////////////////////////////////////////////////////////////////////////////////
//stena jako DataSet_LoadFromCSV1a, ale vola se s parametrem TStream)
procedure DataSet_LoadFromCSV1a(
  mFile: TStream;
  dt: TDataSet;

  HeaderRow: integer = 0; //hodnota vetsi nez 0 udava radek s hlavickou. Hlavicka muze byt vyuzita pro naparovani sloupcu na dataset (tj. ze nemusim mit v DS vsechny sloupce)
    //mapuje se bud podle DisplayLabel (pokud je neprazdny) nebo podle FieldName
  FromRow: integer = 1; //data zacinaji na radku
  Encoding: TEncoding = TEncoding.ANSI;
  slError: TStringList = nil; //sem se plni chyby pri cteni, pokud se nepodarila pretypovat nejaka hodnota ve sloupci. V pripade chyby se radek vlozi, ale hosnota sloupce bude defaultni (tj. nula, false nebo prazdny text)

  delimiter: char = ';'; //oddelovac sloupcu
  DecimalSep: char = '.';
  BoolValTrue: string = 'A';
  QuoteChar : char = '"';

  HeaderFieldMapping: string = ''; //mapovani nazvu fieldu v DS na sloupec v CSV (sloupce cislovane od 1 nebo A). Text ve tvaru: 'Smlouva=3,Quantity=H'
  Form: TForm = nil; //slouzi pouze pro zobrazeni gaugy. Muze byt nil, pak se gauga nezobrazi
  ccaRowSize: integer = 1;  //zhruba delka radku. Pouzije se pro vypocteni poctu zaznamu do GAU
  aEnableEmptyValue: boolean = false //prazdnou hodnotu beru jako nulu (u cisla a datumu)
);
var
  ln: string;

  aux: TMemoryStream;
  slLine: TStringList;
  row: integer;
  i,j: integer;
  PocSloupcu: integer;
  lsCol: string;
  err: string;
  FLD_RowIndex: TField;
  fld: TField;
  dtFields: Variant;
  auxS: string;
  auxI: integer;
  slHeaderFieldMapping: TStringList;
begin
  //na konci muzu mit specialni pole pojmenovane XX_... Ty nejsou v souboru
  PocSloupcu:= 0;
  for i:= 0 to dt.FieldList.Count-1 do begin
    if(pos('XX_', dt.FieldList.Fields[i].FieldName) = 1)then break;
    inc(PocSloupcu);
  end;

  FLD_RowIndex:= dt.Fields.FindField('XX_RowIndex');
  aux:= TMemoryStream.Create;
  slLine:= TStringList.Create;
  slHeaderFieldMapping:= TStringList.Create;
  dtFields:= VarArrayCreate([0, PocSloupcu-1], varInteger);
  try
    //mam definici mapovani-prevezmu ji
    if(HeaderFieldMapping <> '')then begin
      slHeaderFieldMapping.StrictDelimiter:= true;
      slHeaderFieldMapping.CommaText:= HeaderFieldMapping;
      for i:= 0 to PocSloupcu-1 do begin
        auxS:= slHeaderFieldMapping.Values[dt.FieldList.Fields[i].FieldName];
        if(auxS = '')then
          dtFields[i]:= -1
        else if(TryStrToInt(auxS, auxI))then
          dtFields[i]:= auxI-1 //potrebuji cislovani od nuly
        else begin
          //je zde pismeno sloupce odpovidajici excelu
          if(Length(auxS) = 1)then
            dtFields[i]:= ord(auxS) - ord('A')
          else //max. 2 znaky A - ZZ
            dtFields[i]:= (ord(auxS[2]) - ord('A')) + (26 * (ord(auxS[1]) - ord('A') + 1));
        end;
      end;
    //pokud nemam radek s hlavickou, tak predpokladam strukturu 1:1
    end else if(HeaderRow = 0)then begin
      for i:= 0 to PocSloupcu-1 do begin
        dtFields[i]:= i;
      end;
    end;

    slLine.Delimiter:= delimiter;
    slLine.StrictDelimiter:= true;
    if(Form <> nil)then GauInit(Form, mFile.Size/ccaRowSize, 'Load file ...', 50);
    try
      row:= 0;
      while(Stream_ReadLine(mFile, ln, Encoding))do begin
        inc(row);

        //hlavicka - naparovani sloupcu na sloupce DS. Pokud je nula, tak predpokladam 1:1 (viz vyse).
        if(row = HeaderRow) and (HeaderFieldMapping = '')then begin
          slLine.QuoteChar:= QuoteChar;
          slLine.DelimitedText:= ln;
          for i:= 0 to PocSloupcu-1 do begin
            dtFields[i]:= -1;
            fld:= dt.FieldList.Fields[i];
            //pokud mam DisplayLabel, tak beru toto, jinak FieldName
            if(fld.DisplayLabel <> '')then auxS:= fld.DisplayLabel else auxS:= fld.FieldName;

            for j:= 0 to slLine.count-1 do begin
              if(auxS <> slLine[j])then continue;
              dtFields[i]:= j; //pro poradove cislo fieldu si ulozim index v CSV
              break;
            end;
            if(dtFields[i] = -1)then
              slError.Append('V CSV souboru nebyl nalzen sloupec "'+auxS+'"');
          end;
        end;

        //data zacinaji zde
        if(row < FromRow)then
          continue;
        if(ln = '')then
          continue;

//        NxWriteString(aux, ln+#13#10);

        dt.Append;
        slLine.QuoteChar:= QuoteChar;
        slLine.DelimitedText:= ln;
        //slError.Append(slLine.Text);
        //slError.Append('========================================================');
        for i:= 0 to min(PocSloupcu, slLine.Count)-1 do begin
          if(dtFields[i] = -1)then continue;
          err:= '';
          fld:= dt.FieldList.Fields[i];
          lsCol:= slLine[dtFields[i]];

          //prazdna hodnota -> nulova hodnota
          if(trim(lsCol) = '') and (aEnableEmptyValue)then begin
            case fld.DataType of
              ftDateTime : fld.AsDateTime:= 0;
              ftTime     : fld.AsDateTime:= 0;
              ftDate     : fld.AsDateTime:= 0;
              ftFloat    : fld.AsFloat:= 0;
              ftCurrency : fld.AsCurrency:= 0;
              ftInteger  : fld.AsInteger:= 0;
              ftBoolean  : fld.AsBoolean:= false;
              else         fld.AsString  := '';
            end;

          end else begin
            try
              case fld.DataType of
                ftDateTime : if(not TryStrToDateTime(ReplaceStr(lsCol,'/','.'), fld.AsDateTime))then err:= 'není datum a čas';
                ftTime     : if(not TryStrToDateTime(lsCol, fld.AsDateTime))then err:= 'není čas';
                ftDate     : if(not TryStrToDate(ReplaceStr(lsCol,'/','.'), fld.AsDateTime))then err:= 'není datum';
                ftFloat    : if(not TryStrToFloat(ReplaceStr(ReplaceStr(ReplaceStr(lsCol, decimalSep, ','),'Kč',''), ' ', ''), fld.AsFloat))then err:= 'není float';
                ftCurrency : if(not TryStrToCurr (ReplaceStr(ReplaceStr(ReplaceStr(lsCol, decimalSep, ','),'Kč',''), ' ', ''), fld.AsCurrency))then err:= 'není currency';
                ftInteger  : if(not TryStrToInt  (ReplaceStr(ReplaceStr(ReplaceStr(lsCol, decimalSep, ','),'Kč',''), ' ', ''), fld.AsInteger))then err:= 'není integer';
                ftBoolean  : fld.AsBoolean := lsCol = boolValTrue;
                else         fld.AsString  := trim(lsCol);
              end;
              if(slError <> nil) and (err<>'')then
                slError.Append('Hodnota; '+lsCol+';'+err+';Řádek;'+IntToStr(row)+';Sloupec;'+IntToStr(dtFields[i]+1)+' ('+fld.FieldName+')');
            except
              if(slError <> nil)then
                slError.Append('Hodnota;'+lsCol+';'+ExceptionMessage+';Řádek;'+IntToStr(row)+';Sloupec;'+IntToStr(dtFields[i]+1)+' ('+fld.FieldName+')');
            end;
          end;
        end;
        if(Assigned(FLD_RowIndex))then FLD_RowIndex.AsInteger:= row;
        dt.Post;
        if(Form <> nil) and (not gau)then break;
      end;
    finally
      if(Form <> nil)then GauClose;
    end;
  finally
    VarClear(dtFields);
    slLine.free;
    aux.free;
    slHeaderFieldMapping.free;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//smaze radek a stoji na dalsim zaznamu NEBO je na konci (pokud byl posledni)
procedure DataSet_DeleteRow(dt: TDataSet);
var
  eof: boolean;
begin
  //kontrola zda jsem posledni
  dt.next;
  eof:= dt.eof;
  if(not eof)then dt.Prior; //kdyz nejsem posledni, tak se musim vratit
  dt.Delete; //samzu
  if(eof)then dt.next; //pokud jsem smazal posledni, tak nahle stojim na predchozim radku ktery jsem jiz zpracoval, takze ten musim odradkovat, abych odjel na konec
end;
////////////////////////////////////////////////////////////////////////////////
*)
begin
end.