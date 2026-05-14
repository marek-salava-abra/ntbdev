  function CheckFieldValue(Self: TNxCustomBusinessObject;R_polozka:string;table:string;Polozka:string;value: String):String;
var
    mR : TStrings;
const
    cSQL = 'SELECT %s FROM %s WHERE %s=''%s''';
begin
    Result := '';
    mR := TStringList.Create;
    try
        Self.ObjectSpace.SQLSelect(Format(cSQL, [r_polozka,table,polozka,value]), mR);
        if mR.Count > 0 then Result := mR.Strings[0];
    finally
        mR.Free;
    end;
end;

  function CheckDynFieldValue(Self: TNxCustomBusinessObject;R_polozka:string;table:string;Polozka:string;value: String):String;
var
    mR : TStrings;
const
    cDSQL = 'SELECT %s FROM %s WHERE hidden=''N'' and  %s=''%s''';
begin
    Result := '';
    mR := TStringList.Create;
    try
        Self.ObjectSpace.SQLSelect(Format(cDSQL, [r_polozka,table,polozka,value]), mR);
        if mR.Count > 0 then Result := mR.Strings[0];
    finally
        mR.Free;
    end;
end;

 function CheckFieldUserValue(Self: TNxCustomBusinessObject;R_polozka:string;table:string;Polozka:string;value: String;mclsid:string;clsvalue: String):String;
var
    mR : TStrings;
const
    cSQL = 'SELECT %s FROM %s WHERE %s=''%s'' AND %s=''%s''';
begin
    Result := '';
    mR := TStringList.Create;
    try
        Self.ObjectSpace.SQLSelect(Format(cSQL, [r_polozka,table,polozka,value,mclsid,clsvalue]), mR);
        if mR.Count > 0 then Result := mR.Strings[0];
    finally
        mR.Free;
    end;
end;



function NxSetFieldString(ABO : TNxCustomBusinessObject; const AName : string; const AValue : string) : boolean;
var
  mStr : string;
  mDelka:String;
  mSubBO : TNxCustomBusinessObject;
begin
  if pos('.', AName) > 0 then begin
    mStr := copy(AName, 1, pos('.', AName) - 1);
    Result := ABO.HasField(mStr);
    if Result then begin
      mSubBO := ABO.GetMonikerForFieldCode(ABO.GetFieldCode(mStr)).BusinessObject;
      mStr := copy(AName, pos('.', AName) + 1, Length(AName));
      Result := NxSetFieldString(mSubBO, mStr, AValue);
    end;
  end else begin
    Result := ABO.HasField(AName);
    if Result then
       ABO.SetFieldValueAsString(AName, AValue)
  end;
end;
function NxSetFieldInteger(ABO : TNxCustomBusinessObject; const AName : string; const AValue : Integer) : boolean;
var
  mStr : string;
  mDelka:String;
  mSubBO : TNxCustomBusinessObject;
begin
  if pos('.', AName) > 0 then begin
    mStr := copy(AName, 1, pos('.', AName) - 1);
    Result := ABO.HasField(mStr);
    if Result then begin
      mSubBO := ABO.GetMonikerForFieldCode(ABO.GetFieldCode(mStr)).BusinessObject;
      mStr := copy(AName, pos('.', AName) + 1, Length(AName));
      Result := NxSetFieldInteger(mSubBO, mStr, AValue);
    end;
  end else begin
    Result := ABO.HasField(AName);
    if Result then
       ABO.SetFieldValueAsInteger(AName, AValue)
  end;
end;
function NxSetFieldfloat(ABO : TNxCustomBusinessObject; const AName : string; const AValue : Double) : boolean;
var
  mStr : string;
  mDelka:String;
  mSubBO : TNxCustomBusinessObject;
begin
  if pos('.', AName) > 0 then begin
    mStr := copy(AName, 1, pos('.', AName) - 1);
    Result := ABO.HasField(mStr);
    if Result then begin
      mSubBO := ABO.GetMonikerForFieldCode(ABO.GetFieldCode(mStr)).BusinessObject;
      mStr := copy(AName, pos('.', AName) + 1, Length(AName));
      Result := NxSetFieldfloat(mSubBO, mStr, AValue);
    end;
  end else begin
    Result := ABO.HasField(AName);
    if Result then
       ABO.SetFieldValueAsFloat(AName, AValue)
  end;
end;
function NxSetFieldboolean(ABO : TNxCustomBusinessObject; const AName : string; const AValue : Boolean) : boolean;
var
  mStr : string;
  mDelka:String;
  mSubBO : TNxCustomBusinessObject;
begin
  if pos('.', AName) > 0 then begin
    mStr := copy(AName, 1, pos('.', AName) - 1);
    Result := ABO.HasField(mStr);
    if Result then begin
      mSubBO := ABO.GetMonikerForFieldCode(ABO.GetFieldCode(mStr)).BusinessObject;
      mStr := copy(AName, pos('.', AName) + 1, Length(AName));
      Result := NxSetFieldboolean(mSubBO, mStr, AValue);
    end;
  end else begin
    Result := ABO.HasField(AName);
    if Result then
       ABO.SetFieldValueAsBoolean(AName, AValue)
  end;
end;

function NxSetFielddateTime(ABO : TNxCustomBusinessObject; const AName : string; const AValue : Date) : boolean;
var
  mStr : string;
  mDelka:String;
  mSubBO : TNxCustomBusinessObject;
begin
  if pos('.', AName) > 0 then begin
    mStr := copy(AName, 1, pos('.', AName) - 1);
    Result := ABO.HasField(mStr);
    if Result then begin
      mSubBO := ABO.GetMonikerForFieldCode(ABO.GetFieldCode(mStr)).BusinessObject;
      mStr := copy(AName, pos('.', AName) + 1, Length(AName));
      Result := NxSetFielddateTime(mSubBO, mStr, AValue);
    end;
  end else begin
    Result := ABO.HasField(AName);
    if Result then
       ABO.SetFieldValueAsDateTime(AName, AValue)
  end;
end;

procedure ParseHead(AStru : TNxParameters; const ADescription : string; const ASeparator: string; const AData : string; AHead:TStringList);
// rozdělení parametrů sloupců pro import
var
    mStr, mToken : string;
    mPos, i : integer;
begin
    mStr := AData;
    try
        NxTokenToStrings(ADescription, ASeparator, AHead);
        for i := 0 to AHead.Count- 1 do begin
            mPos := AnsiPos(ASeparator, mStr);
            if mPos = 0 then mPos := Length(mStr) + 1;
            mToken := NxLeft(mStr, mPos - 1);
            mStr := copy(mStr, mPos + 1, Length(mStr) - mPos);
        end;
    finally
  end;
end;

procedure Parsevalue(AStru : TNxParameters; const ADescription : string; const ASeparator: string; const AData : string; AHead:TStringList;sloupcu:integer);
// rozdělení hodnot pro import
var
    mStr, mToken : string;
    mPos, i : integer;
begin
    mStr := AData;
    try
        for i := 0 to sloupcu - 1 do begin
            mPos := AnsiPos(ASeparator, mStr);
            if mPos = 0 then mPos := Length(mStr) + 1;
                AHead.Add(NxLeft(mStr, mPos - 1));
                mStr := copy(mStr, mPos + 1, Length(mStr) - mPos);
            end;
        finally
  end;
end;



begin
end.