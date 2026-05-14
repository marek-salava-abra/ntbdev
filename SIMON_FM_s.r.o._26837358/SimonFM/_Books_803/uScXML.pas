// odkaz http://msdn2.microsoft.com/en-us/library/ms757878.aspx
// odkaz na XMLNode - http://msdn2.microsoft.com/en-us/library/ms761386.aspx
var
  GXML: Variant;

// Vytvoření XMLDocument a načtení ze souboru, pokud je nalezen
// Pokud je AMessage = '', potom je to OK, jinak chybová zpráva
function CreateXMLDocument(AFile: string; var AMessage: string): Variant;
var
  i: integer;
  mXML: Variant;
  mPXML: Pointer;
begin
  Result := Null;
  AMessage := '';
  mXML := CreateOLEObject('Msxml2.DOMDocument');
  mXML.SetProperty('SelectionLanguage', 'XPath');
  mXML.PreserveWhitespace := True;
  if FileExists(AFile) then begin
    mXML.Load(AFile);
    if mXML.ParseError.ErrorCode <> 0 then
      AMessage := mXML.ParseError.Reason;
  end;
  Result := mXML;
  GXML := Result;
end;

function CreateXMLDocumentFromString(AXMLStr: string; var AMessage: string): Variant;
var
  i: integer;
  mXML: Variant;
  mPXML: Pointer;
begin
  Result := Null;
  AMessage := '';
  mXML := CreateOLEObject('Msxml2.DOMDocument');
  mXML.SetProperty('SelectionLanguage', 'XPath');
  mXML.PreserveWhitespace := True;
  mXML.LoadXML(AXMLStr);
  if mXML.ParseError.ErrorCode <> 0 then begin
    AMessage := mXML.ParseError.Reason;
  end;
  Result := mXML;
  GXML := Result;
end;

function CreateNewXMLDocument: Variant;
var
  i: integer;
  mXML: Variant;
begin
  mXML := CreateOLEObject('Msxml2.DOMDocument');
  mXML.SetProperty('SelectionLanguage', 'XPath');
  mXML.PreserveWhitespace := True;
  Result := mXML;
  GXML := Result;
end;

// Node podle cesty
// např.: //IssuedInvoice/BillOfDeliveryDocQueue_Code
function NodeFromXML(AXML: Variant; APath_Name: string): Variant;
var
  mColl: Variant;
begin
  Result := Null;
  mColl := AXML.SelectNodes(APath_Name);
  if mColl.Length > 0 then begin
//    Result := AXML.SelectSingleNode(APath_Name);
    Result := mColl.Item(0);
  end;
end;

// Text z Node podle cesty
// např.: //IssuedInvoice/BillOfDeliveryDocQueue_Code
function DataFromXML(AXML: Variant; APath_Name: string): string;
var
  mCurrNode: Variant;
begin
  Result := '';
  mCurrNode := NodeFromXML(AXML, APath_Name);
  if not VarIsNull(mCurrNode) then
    Result := mCurrNode.Text;
end;

// Text z podřízeného Node podle názvu
// např.: BillOfDeliveryDocQueue_Code
function ChildDataFromXML(AXML: Variant; AName: string): string;
var
  mCurrNode: Variant;
  mNodeList: Variant;
  i: Integer;
begin
  Result := '';
  mNodeList := AXML.ChildNodes;
  for i:=0 to mNodeList.Length-1 do begin
    mCurrNode := mNodeList.Item(i);
    if mCurrNode.NodeName = AName then begin
      Result := mCurrNode.Text;
      Exit;
    end;
  end;
end;

// Zapíše text do XML podle cesty
// např.: //IssuedInvoice/BillOfDeliveryDocQueue_Code
procedure DataToXML(AXML: Variant; APath_Name, AValue: string);
var
  mCurrNode: Variant;
begin
  mCurrNode := NodeFromXML(AXML, APath_Name);
  if not VarIsNull(mCurrNode) then
    mCurrNode.Text := AValue;
end;

// Zapíše text do podřízeného Node podle názvu
// např.: BillOfDeliveryDocQueue_Code
procedure ChildDataToXML(AXML: Variant; AName, AValue: string);
var
  mCurrNode: Variant;
  mNodeList: Variant;
  i: Integer;
begin
  mNodeList := AXML.ChildNodes;
  for i:=0 to mNodeList.Length-1 do begin
    mCurrNode := mNodeList.Item(i);
    if mCurrNode.NodeName = AName then begin
      mCurrNode.Text := AValue;
      Exit;
    end;
  end;
end;

// Vrátí NodeList podle zadané cesty - tedy list všech subnodů podle Path
function NodeListFromXML(AXML: Variant; APath: string): Variant;
begin
  Result := AXML.DocumentElement.SelectNodes(APath);
  //Nevím, jestli je ok - možná spíš použít ChildNodes, pokud nebude fungovat
end;

// Vrátí XML, které je nastaveno na pozici AIndex ve zdrojovém XML z NodeListu
// Použití např. pro řádky dokladu
function PartXMLByIndex(ANodeList: Variant; AIndex: integer): Variant;
var
  mNode: Variant;
  i, j: integer;
begin
  Result := Null;
  j := 0;
  for i:=0 to ANodeList.Length-1 do begin
    if (j = AIndex) and (ANodeList.Item(i).NodeType = 1) then begin
      Result := CreateOLEObject('Msxml2.DOMDocument');
//      Result.SetProperty('SelectionLanguage', 'XPath');
      Result.LoadXML(ANodeList.Item(i).XML);
      Exit;
    end;
    if ANodeList.Item(i).NodeType = 1 then
      Inc(j);
  end;
end;

//NEPOUŽÍVAT - je to nějaké nejasné!! Potřebuju to kvůli skriptingu
// Vrátí XML, které je nastaveno na pozici AIndex ve zdrojovém XML z NodeListu
// Použití např. pro řádky dokladu
function PartXMLByIndex2(ANodeList: Variant; AIndex: integer): Variant;
var
  mNode: Variant;
  i, j: integer;
begin
  Result := Null;
  j := 0;
  for i:=0 to ANodeList.Length-1 do begin
    if (j = AIndex) and (ANodeList.Item(i).NodeType = 1) then begin
      Result := ANodeList.Item(i);
//      ShowMessage(ANodeList.Item(i).XML);
      Exit;
    end;
    if ANodeList.Item(i).NodeType = 1 then
      Inc(j);
  end;
end;

begin
end.
