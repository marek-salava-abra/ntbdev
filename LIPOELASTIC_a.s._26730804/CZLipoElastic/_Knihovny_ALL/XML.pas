




function CreateNewXMLDocument(var AMessage: string): Variant;
var
  i: integer;
  mXML: Variant;
begin
  Result := Null;
  AMessage := '';
  mXML := CreateOLEObject('Msxml2.DOMDocument');
  //mXML.SetProperty('SelectionLanguage', 'XPath');
  mXML.PreserveWhitespace := True;
  Result := mXML;
end;


// SQL SELECT do XML
function SQLSelectToXML(SQLObjectSpace: TNxCustomObjectSpace; AQuery, AListName, AElementName: String): Variant;
var
  sqlResult: TMemoryDataset;
  i: Integer;
  fieldName, value, mMessage: String;
  fieldNames: TStrings;
  mXMLList, mXMLNode, mXMLRoot, mXMLError, mXMLMainNode, mXMLDoc: Variant;
begin
  fieldNames := TStringList.Create;
  try
    sqlResult := TMemoryDataset.Create(nil);
    try
      fieldName := '';
      value := '';

      mXMLDoc := CreateNewXMLDocument(mMessage);
      mXMLList := mXmlDoc.createElement(AListName);

      SQLObjectSpace.SQLSelect2(AQuery, sqlResult);

      if not sqlResult.eof then
      begin
        sqlResult.GetFieldNames(fieldNames);
        sqlResult.First;

        while not sqlResult.eof do begin
          mXMLMainNode := mXmlDoc.createElement(AElementName);
          mXMLList.appendChild(mXMLMainNode);
          for i := 0 to sqlResult.FieldCount - 1 do begin
            fieldName := fieldNames[i];
            value := sqlResult.Fields[i].AsString;
            mXMLNode := mXmlDoc.createElement(fieldName);
            mXMLNode.appendChild(mXmlDoc.createTextNode(value));
            mXMLMainNode.appendChild(mXMLNode);
          end;

          sqlResult.next;
        end;
      end;

    finally
      sqlResult.Free;
    end;

    Result:=mXMLList;

  finally
    fieldNames.Free;
  end;
end;




// Nastavení textového obsahu daného uzlu v XML dokumentu
// -----------------------------------------------------------------------------------------------------

procedure SetXMLNodeText(var AXMLDoc: variant; AXMLPath, AText: Variant);
var
  mXMLNode: variant;
begin
  mXMLNode := AXMLDoc.selectSingleNode(AXMLPath);
  mXMLNode.Text := AText;
end;


// Přidání XML uzlu do dané cesty v XML dokumentu. Cesta musí být jednoznačná (v případě násobných elementů se dá do prvního)
// Pokud je cesta prázdná, uzel se přidá přímo do rootu dokumentu
// -----------------------------------------------------------------------------------------------------

procedure AddXMLNode(var AXMLDoc: variant; AXMLPath: String; AXMLNode: variant);
var
  mXMLRootNode: variant;
begin
  if (AXMLPath <> '') then begin
    mXMLRootNode := AXMLDoc.selectSingleNode(AXMLPath);
    mXMLRootNode.appendChild(AXMLNode);
  end else begin
    AXMLDoc.appendChild(AXMLNode);
  end;
end;


// Přidání nového XML elementu s textovým obsahem do předané cesty v XML dokumentu
//   var AXMLDoc = XML dokument, do kterého se přidává
//   AXMLPath = cesta, kam se má nový element přidat
//   AXMLNodeName = Název nového XML elementu
//   AXMLNodeText = Textový obsah nového XML elementu
// -----------------------------------------------------------------------------------------------------

procedure AddXMLNodeText(var AXMLDoc: variant; AXMLPath: String; AXMLNodeName, AXMLNodeText: string);
var
  mXMLRootNode, mXMLNode: variant;
begin
  mXMLRootNode := AXMLDoc.selectSingleNode(AXMLPath);
  mXMLNode := AXMLDoc.createElement(AXMLNodeName);
  mXMLNode.Text := AXMLNodeText;
  mXMLRootNode.appendChild(mXMLNode);
end;

// Přidání nového XML elementu s textovým obsahem do předaného uzlu
//   AXMLDoc = XML dokument (kvůli CreateElement)
//   var AXMLNode = XML uzel, do kterého se přidává
//   AXMLNodeName = Název nového XML elementu
//   AXMLNodeText = Textový obsah nového XML elementu
// -----------------------------------------------------------------------------------------------------

procedure AddXMLNodeTextToNode(AXMLDoc: variant; var AXMLNode: variant; AXMLNodeName, AXMLNodeText: string);
var
  mXMLRootNode, mXMLNode: variant;
begin
  mXMLNode := AXMLDoc.createElement(AXMLNodeName);
  mXMLNode.Text := AXMLNodeText;
  AXMLNode.appendChild(mXMLNode);
end;


// Načtení textového obsahu daného XML elementu

function GetXMLNodeText(AXMLNode: variant; ANodeName: string): string;
var
  mNodes: Variant;
begin
  Result := '';
  mNodes := AXMLNode.getElementsByTagName(ANodeName);
  if mNodes.length > 0 then begin
    if mNodes.item[0].hasChildNodes then
      Result := mNodes.item[0].childNodes[0].text;
  end;
  //Result := AXMLNode.getElementsByTagName(ANodeName).childNodes[0].text;
end;

// Načtení textového obsahu daného XML elementu dle Path

function GetXMLNodeTextP(AXMLNode: variant; APath: string): string;
var
  mNodes: Variant;
begin
  Result := '';
  mNodes := AXMLNode.selectNodes(APath);
  if mNodes.length > 0 then begin
    if mNodes.item[0].hasChildNodes then
      Result := mNodes.item[0].childNodes[0].text;
  end;
end;

// Načtení textového obsahu daného XML elementu na i-té pozici v XMLNodeListu

function GetXMLNodeListText(AXMLNodeList: variant; i: integer; ANodeName: string): string;
begin
  Result := '';
  if AXMLNodeList.item[i].selectNodes(ANodeName).Length > 0 then begin
    if AXMLNodeList.item[i].selectSingleNode(ANodeName).hasChildNodes then begin
      Result := AXMLNodeList.item[i].selectSingleNode(ANodeName).childNodes[0].text;
    end;
  end;
  //Result := AXMLNodeList.item[i].getElementsByTagName(ANodeName).childNodes[0].text;
end;



// -------------------------------------------------------------------------------------------
// Pomocné funkce pro XML Wrapper



// Načtení elementu jako string, pokud existuje. Jinak vrátit default.

function XMLWGetElementAsStringDef(AXML: TNxScriptingXMLWrapper; AElement, ADefault: string): string;
begin
  if AXML.getElementsCountInArray(AElement) > 0 then begin
    Result := AXML.getElementAsString(AElement);
  end else begin
    Result := ADefault;
  end;
end;

// Vrátí XML objekt jako string, volitelně odstraní XML hlavičku

function XMLWAsString(AXML: TNxScriptingXMLWrapper; ARemoveHeader: boolean = true): string;
var
  mXMLBytes: TBytes;
  mXMLStr: string;
begin
  AXML.saveToBytes(mXMLBytes);
  mXMLStr := TEncoding.ANSI.GetString(mXMLBytes);
  if ARemoveHeader then NxToken(mXMLStr, #13#10);
  Result := mXMLStr;
end;




begin
end.