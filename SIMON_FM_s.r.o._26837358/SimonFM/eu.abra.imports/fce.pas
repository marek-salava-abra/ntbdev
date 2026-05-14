Const
 cDivision_ID='1000000101';
 cDocQueue_ID='B200000101';
 cVatRate_ID='02100X0000';
 cDobirka=40;
 cFVDocQueue_ID='4100000101';
 cDLDocQueue_ID='K100000101';
 cHotovost_ID='7000000101';
 cPK_ID='1100000101';
 cUcet_ID='6000000101';
 cDobirka_ID='9000000101';

function GetFirm_ID(AOS : TNxCustomObjectSpace; aICO : string) : String;
const
  cSQL = 'SELECT id FROM firms WHERE orgidentnumber=''%s'' and hidden=''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [aICO]), mList);
    if mList.Count > 0 then
      Result := (mList.Strings[0]);
  finally
    mList.Free;
  end;
end;

function GetstoreCardCategory_ID(AOS : TNxCustomObjectSpace; aCode : string) : String;
const
  cSQL = 'SELECT id FROM StoreCardCategories WHERE Code=''%s'' and hidden=''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := (mList.Strings[0]);
  finally
    mList.Free;
  end;
end;

function GetStoreCard_ID(AOS : TNxCustomObjectSpace; aCode : string) : String;
const
  cSQL = 'SELECT id FROM StoreCards WHERE Code=''%s'' and hidden=''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := (mList.Strings[0]);
  finally
    mList.Free;
  end;
end;

function GetIntra_ID(AOS : TNxCustomObjectSpace; aCode : string) : String;
const
  cSQL = 'SELECT id FROM IntrastatCommodities WHERE Code=''%s'' and hidden=''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := (mList.Strings[0]);
  finally
    mList.Free;
  end;
end;

function GetStore_ID(AOS : TNxCustomObjectSpace; aCode : string) : String;
const
  cSQL = 'SELECT id FROM Stores WHERE Code=''%s'' and hidden=''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := (mList.Strings[0]);
  finally
    mList.Free;
  end;
end;

function GetStoreMenuItem_ID(AOS : TNxCustomObjectSpace; aCode : string) : String;
const
  cSQL = 'SELECT id FROM StoreMenu WHERE Text=''%s'' and hidden=''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := (mList.Strings[0]);
  finally
    mList.Free;
  end;
end;

function GetPrice_ID(AOS : TNxCustomObjectSpace; AStoreCard_ID, aPriceList_ID : string) : string;
const
  cSQL = 'SELECT ID FROM StorePrices WHERE StoreCard_ID=''%s'' and Pricelist_ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [AStoreCard_ID,aPriceList_ID]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:=''
  finally
    mList.Free;
  end;
end;

function GetOrCreateDealer(var mOS : TNxCustomObjectSpace;var  aCode, aName : STring) : String;
var
  mList : tstringlist;
  mDealer : TNxCustomBusinessObject;
begin
  Result := '';
  mList:=tstringlist.create;
  mOS.SQLSelect(format('select id from defrolldata where clsid=''MGBKSKZZWI04PD0USVYD0M0PCO'' and code=''%s'' and hidden=''N'' ',[aCode]),mlist);
  if mlist.Count>0 then Result:=mlist.Strings[0] else begin
    mDealer:=mOS.CreateObject('MGBKSKZZWI04PD0USVYD0M0PCO');
    mDealer.New;
    mDealer.Prefill;
    mDealer.SetFieldValueAsString('Code',aCode);
    mDealer.SetFieldValueAsString('Name',aName);
    mDealer.save;
    Result:=mDealer.OID;
    mDealer.free;
  end;
end;

function GetOrCreateBrand(var mOS : TNxCustomObjectSpace;var  aCode, aName : STring) : String;
var
  mList : tstringlist;
  mDealer : TNxCustomBusinessObject;
begin
  Result := '';
  mList:=tstringlist.create;
  mOS.SQLSelect(format('select id from defrolldata where clsid=''XAK5JAKPBKYOLHHU1W4XEKNLJG'' and code=''%s'' and hidden=''N'' ',[aCode]),mlist);
  if mlist.Count>0 then Result:=mlist.Strings[0] else begin
    mDealer:=mOS.CreateObject('XAK5JAKPBKYOLHHU1W4XEKNLJG');
    mDealer.New;
    mDealer.Prefill;
    mDealer.SetFieldValueAsString('Code',aCode);
    mDealer.SetFieldValueAsString('Name',aName);
    mDealer.save;
    Result:=mDealer.OID;
    mDealer.free;
  end;
end;

function GetOrCreateSort(var mOS : TNxCustomObjectSpace;var  aCode, aName : STring) : String;
var
  mList : tstringlist;
  mDealer : TNxCustomBusinessObject;
begin
  Result := '';
  mList:=tstringlist.create;
  mOS.SQLSelect(format('select id from defrolldata where clsid=''QREVRBGF1MSOHHVRMIXLGO224K'' and code=''%s'' and hidden=''N'' ',[aCode]),mlist);
  if mlist.Count>0 then Result:=mlist.Strings[0] else begin
    mDealer:=mOS.CreateObject('QREVRBGF1MSOHHVRMIXLGO224K');
    mDealer.New;
    mDealer.Prefill;
    mDealer.SetFieldValueAsString('Code',aCode);
    mDealer.SetFieldValueAsString('Name',aName);
    mDealer.save;
    Result:=mDealer.OID;
    mDealer.free;
  end;
end;


function GetOrCreateTyp(var mOS : TNxCustomObjectSpace;var  aCode, aName : STring) : String;
var
  mList : tstringlist;
  mDealer : TNxCustomBusinessObject;
begin
  Result := '';
  mList:=tstringlist.create;
  mOS.SQLSelect(format('select id from defrolldata where clsid=''Z2XYPI1UDPR4BEFLEGL0E4ZLL4'' and code=''%s'' and hidden=''N'' ',[aCode]),mlist);
  if mlist.Count>0 then Result:=mlist.Strings[0] else begin
    mDealer:=mOS.CreateObject('Z2XYPI1UDPR4BEFLEGL0E4ZLL4');
    mDealer.New;
    mDealer.Prefill;
    mDealer.SetFieldValueAsString('Code',aCode);
    mDealer.SetFieldValueAsString('Name',aName);
    mDealer.save;
    Result:=mDealer.OID;
    mDealer.free;
  end;
end;

begin
end.