///////////////////////////////////////////////////////////////////////////////
//vypise obsah parametru do souboru
function ParametersToString(aParams: TNxParameters): string;
var
  sl: TStringList;
var
  atDataType : array[0..22] of string;
  atParamKind: array[0..22] of string;

  //----------------------------------------------------------------------------
  procedure getParama(aLevel: integer; aParams: TNxParameters; var aSl: TStringList);
  var
    i: integer;
  begin
    if(aLevel >= 20)then exit;

    for i := 0 to aParams.Count - 1 do begin
      if(aParams.Params[I].DataType = dtList)then begin
        sl.Add(NxPadL('', aLevel, '-')+
          aParams.Params[I].Name+
          '(kind='+atParamKind[aParams.Params[I].Kind]+','+
          'type='+atDataType[aParams.Params[I].DataType]+')');

        //zanorim se
        getParama(aLevel+1, aParams.Params[I].AsList, sl);
      end else begin
        sl.Add(NxPadL('', aLevel, '-')+
          aParams.Params[I].Name+
          '(kind='+atParamKind[aParams.Params[I].Kind]+','+
          'type='+atDataType[aParams.Params[I].DataType]+')'+
          '='+aParams.Params[i].AsString);
        if(aParams.Params[I].AsList.Count > 0)then
          getParama(aLevel+1, aParams.Params[I].AsList, sl);
      end;
    end;
  end;//getParama
  //----------------------------------------------------------------------------

begin
  atDataType:= [
    'dtUnknown', 'dtString', 'dtSmallint', 'dtInteger', 'dtWord',
    'dtBoolean', 'dtFloat', 'dtCurrency', 'dtBCD', 'dtDate',
    'dtTime', 'dtDateTime', 'dtBytes', 'dtVarBytes', 'dtAutoInc',
    'dtBlob', 'dtMemo', 'dtGraphic', 'dtFmtMemo', 'dtTypedBinary',
    'dtCursor', 'dtGuid', 'dtList'
  ];
  atParamKind:= ['pkUnknown', 'pkInput' , 'pkOutput', 'pkInputOutput', 'pkResult'];

  sl:= TStringList.Create;
  try
    getParama(0, aParams, sl);
    result:= sl.Text;
  finally
    sl.free;
  end;
end;
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
//vypise obsah parametru do souboru
procedure ParametersToFile(aFile: string; aParams: TNxParameters);
var
  sl: TStringList;
var
  atDataType : array[0..22] of string;
  atParamKind: array[0..22] of string;

  //----------------------------------------------------------------------------
  procedure getParama(aLevel: integer; aParams: TNxParameters; var aSl: TStringList);
  var
    i: integer;
  begin
    if(aLevel >= 20)then exit;

    for i := 0 to aParams.Count - 1 do begin
      if(aParams.Params[I].DataType = dtList)then begin
        sl.Add(NxPadL('', aLevel, '-')+
          aParams.Params[I].Name+
          '(kind='+atParamKind[aParams.Params[I].Kind]+','+
          'type='+atDataType[aParams.Params[I].DataType]+')');

        //zanorim se
        getParama(aLevel+1, aParams.Params[I].AsList, sl);
      end else begin
        sl.Add(NxPadL('', aLevel, '-')+
          aParams.Params[I].Name+
          '(kind='+atParamKind[aParams.Params[I].Kind]+','+
          'type='+atDataType[aParams.Params[I].DataType]+')'+
          '='+aParams.Params[i].AsString);
        if(aParams.Params[I].AsList.Count > 0)then
          getParama(aLevel+1, aParams.Params[I].AsList, sl);
      end;
    end;
  end;//getParama
  //----------------------------------------------------------------------------

begin
  atDataType:= [
    'dtUnknown', 'dtString', 'dtSmallint', 'dtInteger', 'dtWord',
    'dtBoolean', 'dtFloat', 'dtCurrency', 'dtBCD', 'dtDate',
    'dtTime', 'dtDateTime', 'dtBytes', 'dtVarBytes', 'dtAutoInc',
    'dtBlob', 'dtMemo', 'dtGraphic', 'dtFmtMemo', 'dtTypedBinary',
    'dtCursor', 'dtGuid', 'dtList'
  ];
  atParamKind:= ['pkUnknown', 'pkInput' , 'pkOutput', 'pkInputOutput', 'pkResult'];

  sl:= TStringList.Create;
  try
    getParama(0, aParams, sl);
    sl.SaveToFile(aFile);
  finally
    sl.free;
  end;
end;
///////////////////////////////////////////////////////////////////////////////

begin
end.