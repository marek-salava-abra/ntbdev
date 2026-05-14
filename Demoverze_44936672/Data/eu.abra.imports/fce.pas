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

begin
end.