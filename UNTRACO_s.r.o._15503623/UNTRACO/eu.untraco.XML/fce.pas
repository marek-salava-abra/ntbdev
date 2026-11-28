function GetStoreCard_ID(AOS : TNxCustomObjectSpace;aEAN : string;):string;
const
  cSQL = 'SELECT sc.id  FROM StoreCards sc left join storeunits su on sc.id=su.parent_id left join storeeans se on se.parent_id=su.id where se.ean=''%s'' and sc.Hidden=''N''';

var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [aEAN]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;


function GetFirm_ID(AOS : TNxCustomObjectSpace;aICO : string;):string;
const
  cSQL = 'SELECT ID FROM Firms where OrgIdentNumber=''%s'' and Hidden=''N''';

var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [aICO]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function GetFirm2_ID(AOS : TNxCustomObjectSpace;aICO : string;):string;
const
  cSQL = 'SELECT F.ID FROM Firms f left join firmoffices fo on f.id=fo.parent_id where fo.X_Partner_ID=''%s'' and F.Hidden=''N'' ';

var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [aICO]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;



function GetFirmXML_ID(AOS : TNxCustomObjectSpace;aGLN : string;):string;
const
  cSQL = 'SELECT  A.ID FROM Firms A WHERE (A.Hidden = ''N'' ) AND (A.Firm_ID||'''' is Null ) AND (exists (SELECT 1 FROM USERDATA WHERE FIELDCODE=2000002 AND CLSID=''4K3EXM5PQBCL35CH000ILPWJF4'' AND ID = A.ID AND (Upper(STRINGFIELDVALUE @{COLLATEORA_USING_NLS_COMP}) LIKE ''%s'' ESCAPE ''~''))) ';   //původně - (Upper(STRINGFIELDVALUE Collate PXW_CSY)

var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [aGLN]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function GetFO_ID(AOS : TNxCustomObjectSpace;aICO : string;):string;
const
  cSQL = 'SELECT FO.ID FROM Firms f left join firmoffices fo on f.id=fo.parent_id where fo.X_Partner_ID=''%s'' and F.Hidden=''N''';

var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [aICO]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function GetFirmOfficeXML_ID(AOS : TNxCustomObjectSpace;aFirm_ID, aEAN : string;):string;
const
  cSQL = 'SELECT A.ID FROM FirmOffices A where A.Parent_ID=''%s'' and (exists (SELECT 1 FROM USERDATA WHERE FIELDCODE=2000002 AND CLSID=''AT011EZZ5DFO115YJ1HCZJDXJ4'' AND ID = A.ID AND (Upper(STRINGFIELDVALUE @{COLLATEORA_USING_NLS_COMP}) LIKE ''%s'' ESCAPE ''~'')))';      //původně - (Upper(STRINGFIELDVALUE Collate PXW_CSY)

var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [aFirm_ID,aEAN]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function GetStoreUnit(AOS : TNxCustomObjectSpace;aEAN : string;):string;
const
  cSQL = 'SELECT su.code  FROM StoreCards sc left join storeunits su on sc.id=su.parent_id left join storeeans se on se.parent_id=su.id where se.ean=''%s'' and sc.Hidden=''N''';

var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [aEAN]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function GetStoreUnitRate(AOS : TNxCustomObjectSpace;aEAN : string;):Extended;
const
  cSQL = 'SELECT su.UnitRate  FROM StoreCards sc left join storeunits su on sc.id=su.parent_id where su.ean=''%s'' and sc.Hidden=''N''';

var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [aEAN]), mList);
    Result:=1;
    if mList.Count > 0 then
      Result := StrToFloat(mList.Strings[0]);
  finally
    mList.Free;
  end;
end;


begin
end.