const
 cExport_ID='IHE0000101';
 cInvoiceRegForm_ID='T220000101';
 cInvoiceNoRegForm_ID='S220000101';
 cBODForm_ID='Y410000101';
 cDocumentDriver='1100000101';  //vytvořená samostatná kategorie ISDOC vydaný, nastavení v něm, hlavně vypnout podpis
 cHTMLInvoice = '1000000101';
 cHTMLBillOfDelivery = '3000000101';

function GetDynSource (AOS : TNxCustomObjectSpace; AValue : string) : String;

const
  cSQL = 'SELECT DataSource FROM Reports WHERE ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [ AValue]), mList);
    if mList.Count > 0 then
      Result := (mList.Strings[0]);
  finally
    mList.Free;
  end;
end;

function GetDynSourceEx (AOS : TNxCustomObjectSpace; AValue : string) : String;

const
  cSQL = 'SELECT DataSource FROM EXPORTS WHERE ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [ AValue]), mList);
    if mList.Count > 0 then
      Result := (mList.Strings[0]);
  finally
    mList.Free;
  end;
end;

function GetDynSourceE (AOS : TNxCustomObjectSpace; AValue : string) : String;

const
  cSQL = 'SELECT DataSource FROM B2BEXPORTS WHERE ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [ AValue]), mList);
    if mList.Count > 0 then
      Result := (mList.Strings[0]);
  finally
    mList.Free;
  end;
end;

begin
end.