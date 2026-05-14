uses
  'REST_SkladTerm_Special.U_Const';

//Pomocne funkce na praci s JSONem
const
  //pro pouziti v zanorenych objektech - odklaz na rodice
  REST_XX_Parent_ID = 'XX_Parent_ID';

////////////////////////////////////////////////////////////////////////////////
//daum si v URL predavam ve formatu YYYYMMDD
function URLStrToDate(str: string): tDate;
var
  y,m,d: word;
begin
  result:= EncodeDateTime(
  StrToIntDef(copy(str, 1, 4), 0), //y
  StrToIntDef(copy(str, 5, 2), 0), //m
  StrToIntDef(copy(str, 7, 2), 0), //d
  0, //h
  0, //m
  0, //s
  0 //ms
  );
end;
////////////////////////////////////////////////////////////////////////////////

//##############################################################################
//##############################################################################
//JSON Formatovani
//##############################################################################
//##############################################################################

////////////////////////////////////////////////////////////////////////////////
//TODO - takto jsem si formatoval datum puvodne. Nove mozna pouziju funkce TJSONu,
// ale zatim nejak nefungujou, tak si budu datum posilat ve stringu
function REST_json_Date(aDate: tDate): string;
var
  y,m,d: word;
begin
  if(NxIsNullDate(aDate))then
    //result:= '/Date(0)/'
    result:= '0000-00-00'
  else begin
    //vrati string ve tvaru: "\/Date(1415804695549)\/"
    //result:= CFxDateTime.DateTimeToJsonDate(aDate);

    DecodeDate(aDate, y, m, d);
    //result:= Format('/Date(%d-%s-%s)/', [y, NxPadL(IntToStr(m), 2, '0'), NxPadL(IntToStr(d), 2, '0')]);
    result:= Format('%.4d-%.2d-%.2d', [y, m, d]);
  end;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
function REST_json_DateTime(aDate: TDateTime): string;
var
  y,m,d, hod, min, sec, msec: word;
begin
  if(NxIsNullDate(aDate))then
    //result:= '/Date(0)/'
    result:= '0000-00-00'
  else begin
    //vrati string ve tvaru: "\/Date(1415804695549)\/"
    //result:= CFxDateTime.DateTimeToJsonDate(aDate);

    DecodeDateTime(aDate, y, m, d, hod, min, sec, msec);
    //result:= Format('/Date(%d-%s-%s %d:%s)/', [y, NxPadL(IntToStr(m), 2, '0'), NxPadL(IntToStr(d), 2, '0'), hod, NxPadL(IntToStr(min), 2, '0')]);
    result:= Format('%.4d-%.2d-%.2d %.2d:%.2d', [y, m, d, hod, min]);
  end;
end;
////////////////////////////////////////////////////////////////////////////////

//##############################################################################
//##############################################################################
//JSON ZAPIS
//##############################################################################
//##############################################################################

////////////////////////////////////////////////////////////////////////////////
//zapsani hodnoty nezavisle na typu
// - podporuje typy string,boolean,integer,double, tdatetime
procedure REST_json_addValue(var result: TJSONSuperObject; key: string; value: variant; empty: boolean = false);
var
  posX: integer;
  bool, entered: boolean;
begin
  entered := False;
  //poresim typ
  case VarType(value) of
    //VAR_TYPE:258 = stirng
    //if(VarIsStr(value))then begin
    varString, varUString: begin
      //pripojim jen pokud neni prazdne
      //if((not empty) AND ((trim(value) = '') OR (value = '0000000000')))then exit;
      //value:= TrimRight(value);
      //value:= ReplaceStr(value,#10,'');
      //value:= ReplaceStr(value,#13,'\n');
      value:= ReplaceStr(value,#13#10,' ');

      //je v nazvu pole $NULL? odstranim
      posX:= pos('$NULL', key);
      if(posX > 0)then begin
        key:= copy(key, 1, posX-1);
        //pokud prazdny string, vlozim NULL hodnotu
        if(value <> '')then
          result.S[key]:= value
        else
          result.O[key]:= TJSONSuperObject.CreateByDataType(jtNull);
        entered := True;
      end;
      if ABRA then
      begin
        //je v nazvu pole $BOOL? odstranim
        posX:= pos('$BOOL', key);
        if(posX > 0)then
        begin
          key:= copy(key, 1, posX-1);
          if value = 'A' then
            result.B[key] := true
          else
            result.B[key] := false;
          entered := True;
        end;
      end;
      if not entered then
        result.S[key]:= value;
    end;

    //VAR_TYPE:11 = boolean
    //end else if(VarIsType(value, varBoolean))then begin
    varBoolean: begin
      //pripojim jen pokud neni prazdne
      //if((not empty) AND (not value))then exit; //pripojuju obe hodnoty

      //je v nazvu pole $BOOL? odstranim
      posX:= pos('$BOOL', key);
      if(posX > 0)then key:= copy(key, 1, posX-1);

      result.B[key]:= value;
    end;

    //VAR_TYPE:5 = float
    //end else if(VarIsType(value, varDouble) OR VarIsType(value, varCurrency))then begin
    varCurrency, varDouble: begin
      //pripojim jen pokud neni prazdne
      //if((not empty) AND (value = 0))then exit;//pripojuju obe hodnoty
      if ABRA then
      begin
        posX:= pos('$DATE', key);
        if(posX > 1)then
          result.S[copy(key, 1, posX-1)]:= REST_json_DateTime(value)
        else
          result.D[key]:= value;
      end
      else
        result.D[key]:= value;
    end;

    //VAR_TYPE:3
    //end else if(VarIsNumeric(value))then begin
    varByte, varInteger, varInt64, varLongWord, varShortInt, varSingle, varSmallint,varWord: begin
      //pripojim jen pokud neni prazdne
      //if((not empty) AND (value = 0))then exit; //pripojuju obe hodnoty
      result.I[key]:= value;
    end;

    //VAR_TYPE:7 = datum
    //end else if(VarType(value) = 7)then begin
    varDate: begin
      //if(NxIsNullDate(value))then exit; //nulovy datum si neposlu

      //datum? odstranim z klice $DATE
      posX:= pos('$DATE', key);
      if(posX > 1)then
        result.S[copy(key, 1, posX-1)]:= REST_json_DateTime(value)
      else
        result.S[key]:= REST_json_DateTime(value)
    end;

    //jeste nejakej typ jsem nepokryl?
    //end else begin
    else begin
      result.S[key]:= 'VAR_TYPE:'+IntToStr(VarType(value));
    end;
  end;
end;
////////////////////////////////////////////////////////////////////////////////


//##############################################################################
//##############################################################################
//JSON CTENI
// tyto funkce asi nejsou potreba. ZRUSIT???
//##############################################################################
//##############################################################################

////////////////////////////////////////////////////////////////////////////////
function REST_getJSONStr(json: TJSONSuperObject; key: string): string;
begin
  result:= json.S[key];

  //novy radek dostavam jen jako chr(10).
  //?? je to zde potreba
  //result:= ReplaceStr(result, chr(10), chr(13)+chr(10));
end;//getJSONStr
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
function REST_getJSONBool(json: TJSONSuperObject; key: string): Boolean;
begin
  result:= json.B[key];
end;//getJSONStr
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
function REST_getJSONDateTime(json: TJSONSuperObject; key: string): TDateTime;
var
  s: string;
begin
  result:= 0;

  //mam datum jako string. Musim z nej udelat datum  (2012-12-28 18:35)
  s:= json.S[key];
  if(length(s) < 10)then exit;

  Result:= EncodeDateTime(
    StrToInt(copy(s,1,4)), //yyyy
    StrToInt(copy(s,6,2)), //mm
    StrToInt(copy(s,9,2)), //dd
    StrToIntDef(copy(s,12,2), 0), //hh
    StrToIntDef(copy(s,15,2), 0), //mm
    StrToIntDef(copy(s,18,2), 0), //ss
    0  //ms
  );
end;//getJSONDateTime
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
function REST_jsonEscapeString(AInputStr: String): String;
begin
  // nejsem si jisty, ze tohle bude stacit
  Result := NxSearchReplace(AInputStr, '"', '\"', [srAll])
end;//jsonEscapeString
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
function REST_getJSONInt(json: TJSONSuperObject; key: string): integer;
begin
  result:= json.I[key];
end;//getJSONInt
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
function REST_getJSONDouble(json: TJSONSuperObject; key: string): double;
begin
  result:= json.D[key];
end;//getJSONDouble
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
function REST_setJSONStr(json: TJSONSuperObject; key, value: string): string;
begin
  json.S[key]:= value;
  result:= value;
end;
////////////////////////////////////////////////////////////////////////////////


//##############################################################################
//##############################################################################
//DALSI FUNKCE
//##############################################################################
//##############################################################################

////////////////////////////////////////////////////////////////////////////////
//preplnim si pole obsahujici objekt s primitivnima typama
//pole, ktere chci plnit si nastavim do hlavicky datasetu
//primarne se nazev pole v JSONu bere z DisplayLabel. Tim docilim jinych nazvu ve vyslednem datasetu
procedure REST_JsonToDataSet(aJSON: TJSONSuperObjectArray; ds: TDataSet);
var
  i,j: integer;
  FieldName: string;
  mRow: TJSONSuperObject;
begin
  for i:= 0 to aJSON.Length-1 do begin
    mRow:= aJSON.O[i];
    ds.Append;
    for j:= 0 to ds.FieldList.Count-1 do begin
      if(ds.FieldList.Fields[j].FieldName[1] = '_')then begin
        //zacina na podtrzitko - toto je pomocne pole. Neplni se z JSONu
      end else if(ds.FieldList.Fields[j].FieldName = 'jsonIndex')then begin
        //index
        ds.FieldList.Fields[j].Value:= i;
      end else begin
        //ostatni polozky z JSONu
        FieldName:= ds.FieldList.Fields[j].DisplayLabel;
        if(FieldName = '')then ds.FieldList.Fields[j].FieldName;
        case ds.FieldList.Fields[j].DataType of
          ftString,ftWideString,ftMemo,ftWideMemo:
            ds.FieldList.Fields[j].Value:= REST_getJSONStr(mRow, FieldName);
          ftInteger : ds.FieldList.Fields[j].Value:= REST_getJSONInt(mRow, FieldName);
          ftFloat   : ds.FieldList.Fields[j].Value:= REST_getJSONDouble(mRow, FieldName);
          ftDateTime: ds.FieldList.Fields[j].Value:= REST_getJSONDateTime(mRow, FieldName);
          ftBoolean : ds.FieldList.Fields[j].Value:= REST_getJSONBool(mRow, FieldName);
          else RaiseException('JsonToDataSet: pole: '+FieldName+', neznamy typ: '+IntToStr(ds.FieldList.Fields[j].DataType));
        end;
      end;
    end;
    ds.Post;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//vrati doklad v jeho minimalni podobe (id,displayname)
//pouziva se jako odpoved po vytvoreni/editaci dokladu
function REST_getJsonDocRespons(BO: TNxCustomBusinessObject): TBytes;
var
  json: TJSONSuperObject;
  res: variant;
begin
  json:= TJSONSuperObject.CreateByDataType(jtObject);
  try
    json.S['id']:= BO.OID;
    json.S['name']:= BO.DisplayName;
    res:= json.AsString;
    result:= TEncoding.UTF8.GetBytes(res);
  finally
    json.free;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//vytvori json objekt a naplni jej polozkama z radku datasetu
//IGNORUJI SE fieldy zacinajici na XX_
function REST_jsonCreate_FromDataSetRow(dt: TDataSet; jsonOwner: TJSONSuperObject; slRows: TStringList = nil): TJSONSuperObject;
var
  json: TJSONSuperObject;
  jsonObj: TJSONSuperObject;
  i, j: integer;
  auxI: integer;
  objName, objNameLast: string;
  objField: string;
  objIndex: integer;
  field: TField;
  dtRows: TMemTable;
  id: string;
  mCollectionName, mCollection2Name, mCollection2NamePart1, mCollection2NamePart2: String;
  slSubRows: TStringList;
begin
  json:= REST_JsonObject_Create(jtObject, jsonOwner);
  objNameLast:= '';

  for i:= 0 to dt.FieldCount-1 do begin
    field:= dt.FieldList.Fields[i];

    //ignotuju fildy zacinajici podtrzitekm
    if(copy(field.FieldName,1,3) = 'XX_')then continue;

    //nazev obsahuje tecku? je to podrizenej objekt
    auxI:= pos('.', field.FieldName);
    if(auxI > 0)then begin
      //nazev objektu je pred teckou
      objName:= copy(field.FieldName, 1, auxI-1);
      objField:= copy(field.FieldName, auxI+1, 100);

      //Nazev objektu stejny jako minule?
      if(objNameLast = objName)then begin
        //pokud nemam vytvorenej objekt, tak nic.
        if(jsonObj = nil)then continue;

      end else begin
        objNameLast:= objName;

        //pokud je prvni "id" a je prazdne, tak udelam null objekt a nic dalsiho nepridavam
        if((objField = 'id')OR(objField = 'id$NULL'))then begin
          if((field.Value = '') OR (field.Value = '0000000000'))then begin
            //null hodnota - udelam null objekt
            json.O[objName]:= TJSONSuperObject.CreateByDataType(jtNull);
            jsonObj:= nil;
            continue;
          end else if(field.Value = '----------')then begin
            //schvale si sem vratim pomlcku, pokud chci vlozit i ibjekt s null ID
            jsonObj:= REST_JsonObject_Create(jtObject, json);
            json.O[objName]:= jsonObj;
            jsonObj.O[objField]:= TJSONSuperObject.CreateByDataType(jtNull);
            continue;
          end else begin
            //id s hodnotou
            jsonObj:= REST_JsonObject_Create(jtObject, json);
            json.O[objName]:= jsonObj;
          end;
        end else begin
          jsonObj:= REST_JsonObject_Create(jtObject, json);
          json.O[objName]:= jsonObj;
        end;
      end;

      REST_json_addValue(jsonObj, objField, field.Value, true);
      continue;
    end;

    //nulove id? vlozim prazdno
    if (pos('_ID', UpperCase(field.FieldName)) = (Length(field.FieldName)-2))
      and (VarType(field.value) in [varString, varUString])
      and ((field.Value = '0000000000') or (field.Value = '          '))
    then begin
      json.S[field.FieldName]:= ''; //TJSONSuperObject.CreateByDataType(jtNull)
    end else begin
      REST_json_addValue(json, field.FieldName, field.Value, true);
    end;
  end;

  //mam i nejake radkove objekty?
  if(slRows <> nil)AND(slRows.Count > 0)then begin
    for i:= 0 to slRows.Count-1 do
    begin
      // chceme podporovat neomezeny pocet zanoreni podrizenych kolekci
      // podrizene kolekce budou v stringlistu slRows oznacene nadrizenou kolekci, teckou a nazvem svoji kolekce
      // tzn. zde preskakujeme polozky s teckou v nazvu
      // pri rekurzivnim volani pak predame vsechny odpovidajici podrizene zaznamy po odriznuti prefixu a tecky
      mCollectionName := slRows.Names[i];
      //gLog.WriteEvent(logDebug, 'rows collection name: ' + mCollectionName);
      if pos('.', mCollectionName) <> 0 then
        continue;

      jsonObj:= REST_JsonObject_Create(jtArray, json);

      dtRows:= TMemTable(slRows.Objects[i]);
      if(dtRows.Active)then begin
        id:= dt.FieldByName('id').AsString;
        //if dtRows.FindNearest([id]) then begin
        dtRows.SetRange([id], [id]);
        dtRows.First;
        while (not dtRows.eof) {AND (dtRows.FieldByName(XX_Parent_ID).AsString = id)}do
        begin
          slSubRows := TStringList.Create;
          try
            for j := 0 to slRows.Count - 1 do
            begin
              // hledame kolekce s teckou podrizene aktualni kolekci
              mCollection2Name := slRows.Names[j];
              if pos('.', mCollection2Name) = 0 then
                continue;
              //mCollection2NamePart1 := NxToken(mCollection2Name, '.');
              mCollection2NamePart1 := copy(mCollection2Name, 1, pos('.', mCollection2Name) - 1);
              mCollection2NamePart2 := copy(mCollection2Name, pos('.', mCollection2Name) + 1, 100);
              // pokud je prvni cast shodna s aktualni kolekci, je to jeji subkolekce
              if mCollection2NamePart1 = mCollectionName then
                slSubRows.AddObject(mCollection2NamePart2 + '=', slRows.Objects[j]);
            end;
            jsonObj.AsArray.Add(REST_jsonCreate_FromDataSetRow(dtRows, nil, slSubRows));
            dtRows.next;
          finally
            slSubRows.Free;
          end;
        end;
        //end;
      end;

      json.O[mCollectionName{slRows.Names[i]}]:= jsonObj;
    end;
  end;
  result:= json;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//vytvori json objekt pole a naplni jej radkama datasetu
function REST_jsonCreate_FromDataSet(dt: TDataSet; jsonOwner: TJSONSuperObject; slRows: TStringList = nil): TJSONSuperObject;
var
  i: integer;
  field: TField;
begin
  result:= REST_JsonObject_Create(jtArray, jsonOwner);

  if(dt.Active)then begin
    i:= 0;
    dt.First;
    while(not dt.eof)do begin
      result.AsArray.Add(REST_jsonCreate_FromDataSetRow(dt, jsonOwner, slRows));
      dt.next;
      Inc(i);
    end;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//vytvori jsonarray ze stringovych flagu (001010)
function REST_jsonCreate_FromFlags(flags: String; jsonOwner: TJSONSuperObject): TJSONSuperObject;
var
  i,j: integer;
  json: TJSONSuperObject;
begin
  j:= 0;
  result:= REST_JsonObject_Create(jtArray, jsonOwner);
  for i:= 1 to Length(flags) do
    if(flags[i]='1')then begin
      result.AsArray.S[j]:= IntToStr(i);
      inc(j);
    end;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//vytvori jsonarray s obsahem stringlistu
function REST_jsonCreate_FromStringList(sl: TStringList; jsonOwner: TJSONSuperObject): TJSONSuperObject;
var
  i: integer;
begin
  result:= REST_JsonObject_Create(jtArray, jsonOwner);
  for i:= 0 to sl.count-1 do
    result.AsArray.S(i):= sl.strings[i];
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//ocekava pole stringu a vraci stringlist s temato stringama
procedure REST_getStringList_FromJson(var sl: TStringList; arr: TJSONSuperObjectArray);
var
  i: integer;
begin
  for i:= 0 to arr.Length-1 do
    sl.Add(arr.S[i]);
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//test na existenci property
function REST_jsonExists(json: TJSONSuperObject; name: string): boolean;
begin
  result:= json.N[name].DataType <> jtNull;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
function REST_JsonObject_Create(jType: TJSONDataType; jsonOwner: TJSONSuperObject = nil): TJSONSuperObject;
begin
  if(Assigned(jsonOwner))then begin
    case jType of
      jtArray : result:= jsonOwner.CreateJSONArray;

      else begin
        //pokud je owner pole (cleny pole se uvolnuji vzdy), pouziju CreateByDataType, protoze je rychlejsi
        if(jsonOwner.DataType = jtArray)then
          result:=  TJSONSuperObject.CreateByDataType(jType)
        else
          result:= jsonOwner.CreateJSON;
      end;
    end;
  end else begin
    result:=  TJSONSuperObject.CreateByDataType(jType);
  end;
end;
////////////////////////////////////////////////////////////////////////////////

begin
end.