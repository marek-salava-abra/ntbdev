function GetVatRate_ID(AOS : TNxCustomObjectSpace; AValue : string) : string;
const
  cSQL = 'SELECT ID FROM Vatrates where tariff=%s';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='01500X0000';
    AOS.SQLSelect(Format(cSQL, [ AValue]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function GetPrice_ID(AOS : TNxCustomObjectSpace; AValue : string) : string;
const
  cSQL = 'SELECT ID FROM Defrolldata where clsid=''TKLNUZLSDWF41HYRETBTQDF1P0'' and X_code=''%s''';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    if not Assigned(AOS) then NxShowSimpleMessage('ne',nil);
    Result:='';
    AOS.SQLSelect(Format(cSQL, [ AValue]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function GetPriceAmount(AOS : TNxCustomObjectSpace; AValue : string) : Extended;
const
  cSQL = 'SELECT x_Price FROM Defrolldata where clsid=''TKLNUZLSDWF41HYRETBTQDF1P0'' and ID=''%s''';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:=0;
    AOS.SQLSelect(Format(cSQL, [ AValue]), mList);
    if mList.Count > 0 then
      Result := StrToFloat(mList.Strings[0]);
  finally
    mList.Free;
  end;
end;

function scrGetOrCreatePrice(var AOS: TNxCustomObjectSpace; var aName, aCode:string): String;
var
 mBO:TNxCustomBusinessObject;
 mPrice_ID:string;
 mOS:TNxCustomObjectSpace;
begin
   mBO:= aos.CreateObject('TKLNUZLSDWF41HYRETBTQDF1P0');
   mOS:=mbo.ObjectSpace;
   mPrice_ID:=GetPrice_ID(mOS,aCode);
   if NxIsEmptyOID(mPrice_ID) then begin

      mbo.New;
      mbo.Prefill;
      mbo.SetFieldValueAsString('X_code',aCode);
      mbo.SetFieldValueAsString('Name', LeftStr(aName,50));
      mbo.Save;
      mPrice_ID:=mbo.OID;
      mbo.Free;


   end;
   Result:=mPrice_ID;
end;


begin
end.