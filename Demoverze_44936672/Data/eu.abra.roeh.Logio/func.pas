uses  'eu.abra.roeh.Logio.ConstVar';
//const
// cGdsCLSIDBO = 'MS5KWM12OJS4ZH4XSJTL2UGM30'; // Bussines object číselníku, kde jsou parametry


function GetVat(Const iVat: string):real;
begin
  if NxIsNumeric(iVat) and (iVat <> '') then
    Result := StrToFloat(iVat)
  else
    Result := 0;
end;
function GetDefaultDivision(const mDiv:String):string;
begin
if (Trim(mDiv) = '') or (mDiv = '0000000000') then Result := cDefaultDivision
   Else Result := mDiv;
end;

function CatChar(mS:string):string;
var
 N : integer;
begin
  Result := '';
  For N := 1 to Length(mS) do
    if mS[N] in ['0'..'9'] then Result := Result + mS[N];
end;

function CopyLT(const mS:String;const N:integer):string;
begin
  Result := Copy(Trim(mS),1,N);
end;

function GetId(iOS:TNxCustomObjectSpace;const itable,iField,iValue:string):string;
var
    Str: TStringList;
begin
  Result := '';
  Str := TStringList.Create;
  try
    iOS.SQLSelect('select id from '+ iTable+' a where a.Hidden <> ''A'' and Upper(a.'+iField+') =''' + UpperCase(iValue) + '''',Str);
    if Str.Count >0 then Result := Str.Strings(0);
  finally
    Str.Free;
  end;
end;

function GetFirmId(iOS:TNxCustomObjectSpace;const iField,iValue:string;const NotHidden:Boolean):string;
var
    Str: TStringList;
    S:String;
begin
  Result := '';
  Str := TStringList.Create;
  try
    S := 'select id from Firms a where a.Hidden <> ''A'' and Upper(a.'+iField+') =''' + UpperCase(iValue) + '''';
    if NotHidden then S := S + ' and (a.Firm_ID is null)';

    iOS.SQLSelect(S,Str);
    if Str.Count >0 then Result := Str.Strings(0);
  finally
    Str.Free;
  end;
end;

function GetDod(iOS:TNxCustomObjectSpace;const iStoreCard,iFirm:string):string;
var
    Str: TStringList;
    S : string;
begin
  Result := '';
  Str := TStringList.Create;
  try
    s := 'select id from Suppliers a where a.StoreCard_ID = '''+ iStoreCard +''' and ((a.Firm_ID = ''' +iFirm+''') or (a.Firm_ID in (select f.ID from firms f where f.Firm_ID = '''+iFirm+'''))) order by a.PurchaseDate$DATE desc';
    iOS.SQLSelect(S,Str);
    if Str.Count >0 then Result := Str[0];
  finally
    Str.Free;
  end;
end;

function GetSahareDod(iOS:TNxCustomObjectSpace;const iStoreCard:string):string;
var
    Str: TStringList;
    S : string;
begin
  Result := '';
  Str := TStringList.Create;
  try
    s := 'select Max(Firm_id) from Suppliers a where a.StoreCard_ID = '''+ iStoreCard +''' and DoDemand = ''A''';
    iOS.SQLSelect(S,Str);
    if Str.Count >0 then Result := Str[0];
  finally
    Str.Free;
  end;
end;

function GetIdFloat(iOS:TNxCustomObjectSpace;const itable,iField:string; const iValue:Real):String;
var
    Str: TStringList;
begin
  Result := '';
  Str := TStringList.Create;
  try
    iOS.SQLSelect('select id from '+ iTable+' a where a.Hidden <> ''A'' and a.'+iField+' =' + FloatToStr(iValue),Str);
    if Str.Count >0 then Result := Str.Strings(0);
  finally
    Str.Free;
  end;
end;

function PeriodId(iOS:TNxCustomObjectSpace;iDate:TdateTime):string;
var
 Str: TStringList;
begin
  Str := TStringList.Create;
  try
    iOS.SQLSelect('Select id from periods p  where p.DateFrom$DATE <= ' + FloatToStr(iDate) + ' and  DateTo$DATE>= '+ FloatToStr(iDate),Str);
    if Str.Count >0 then Result := Str.Strings[0]
      else Result := '0000000000';
  finally
    Str.Free;
  end;
end;

function CreateBusOrderID(iOS:TNxCustomObjectSpace;const iStr:String):string;
var
  iBO : TNxCustomBusinessObject;
begin
   iBO := iOS.CreateObject('K2WTYL304VD13ACL03KIU0CLP4');
   try
     iBo.New;
     iBo.Prefill;
     iBo.SetFieldValueAsString('CODE',iStr);
     iBo.SetFieldValueAsString('Name',iStr);
     iBo.Save;
     Result := iBo.GetFieldValueAsString('ID');
   finally
      iBO.Free;
   end;
end;

function GetParamValue(iOS:TNxCustomObjectSpace;const iStr:String):string;
var
  Str: TStringList;
begin
  Result := '';
  Str := TStringList.Create;
  try
    iOS.SQLSelect('Select Name from defrollData d where d.CLSID = ''KPZKXIYXBTROHDBEJN2GCFZU3K'' and Upper(code) =''' + UpperCase(iStr)+'''',Str);
    if Str.Count > 0  then Result := Trim(Str.Strings(0));
    if Result = '""' then Result := '';
  finally
    Str.Free;
  end;
end;

function GedID(mStr : TStringList):string;
Var
  i : integer;
  S : string;
begin
  S := '';
  for i := 0 to mStr.Count - 1 do S := S + ',''' + mStr.Strings[i]+ '''';
  Delete(S,1,1);
  Result := S;
end;

////////////////////////////////////////////////////////////////////////////////
/// Tabulka SELDAT /////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
function GetFirstRecordFromSQL(AOS: TNxCustomObjectSpace; ASQL: String): String;
var
  mSQLRes: TStrings;
begin
  Result := '';
  mSQLRes := TStringList.Create;
  try
    AOS.SQLSelect(ASQL, mSQLRes);
    if mSQLRes.Count > 0 then
      Result := mSQLRes.Strings[0]
  finally
    mSQLRes.Free;
  end;
end;

procedure AddStringsToSelDat(AOS : TNxCustomObjectSpace; AStation_ID: String; AValues: TStringList);
// Přidá do SelDat hodnoty ze StringListu pod AStation
var
  mStation_ID : String;
  i : Integer;
begin
  mStation_ID := GetFirstRecordFromSQL(AOS, 'Select ID from SelDef where ID = ''' + AStation_ID + '''');
  if NxIsEmptyOID(mStation_ID) then begin
    mStation_ID := AStation_ID;
    AOS.SQLExecute('Insert into SelDef (ID, Station) values ('''+ mStation_ID +''', ''GeneratedByScript'')');
  end;
  For i:=0 to AValues.Count-1 do begin
    AOS.SQLExecute('Insert into SelDat (Sel_ID, Obj_ID) values ('''+ mStation_ID + ''', ''' + AValues.Strings[i] + ''')');
  end;
end;

procedure ClearSelDat(AOS : TNxCustomObjectSpace; AStation_ID: String);
// Smaže ze SelDat hodnoty pod AStation
begin
  AOS.SQLExecute('Delete from SelDef where ID = ''' + AStation_ID + '''');
end;

procedure StringsToSelDat(AOS : TNxCustomObjectSpace; AStation_ID: String; AValues: TStringList);
begin
  ClearSelDat(AOS, AStation_ID);
  AddStringsToSelDat(AOS, AStation_ID, AValues);
end;

begin
end.