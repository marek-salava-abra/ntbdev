function gCreateXMLDocument: Variant;
begin
  Result := CreateOLEObject('Msxml2.DOMDocument');
  //Result.SetProperty('SelectionLanguage', 'XPath');
  //Result.PreserveWhitespace := True;
end;


function gCreateXMLDocumentFromFile(AFile: string; var AMessage: string): Variant;
var
  mXML: Variant;
begin
  AMessage := '';
  mXML := gCreateXMLDocument;
  mXML.Load(AFile);
  if mXML.ParseError.ErrorCode <> 0 then begin
    Result := Null;
    AMessage := mXML.ParseError.Reason;
  end else
    Result := mXML;
end;

function gLoadXMLFile(AXMLFileName: String): Variant;
var
  mMessage: String;
begin
  Result := gCreateXMLDocumentFromFile(AXMLFileName, mMessage);
  if mMessage <> '' then
    RaiseException('Chyba XML:'#13+mMessage)
end;

begin
end.