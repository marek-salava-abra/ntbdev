//Zde je problém s rychlostí. Prdlužuje čas zobrazení formuláře. Najít alternativu

//Vzhledem k počtu opakování se snažím načíst a sržet seznam
uses
  'eu.abra.PostProviders.uConst',
  'eu.abra.PostProviders.uSQLFunc';

procedure GetScripts(AOS : TNxCustomObjectSpace; ARun: integer; AScripts: TStringList);
const
  cSQLGetScript = 'select A.X_PC_ScriptName from DefRollData A '+
                  'where A.CLSID = %s and A.X_PC_Run = %s and A.Hidden = ''N'' '+
                  'order by A.X_PC_ScriptName';
var
  mSQL : string;
begin
  mSQL := Format(cSQLGetScript, [QuotedStr(Class_BOPackageSetting), IntToStr(ARun)]);
  AOS.SQLSelect(mSQL, AScripts);
end;


procedure GetScriptsButton(AOS : TNxCustomObjectSpace; ARun: integer; AScripts: TStringList);
const
  cSQLGetScript = 'select A.X_PC_ScriptName,A.Name from DefRollData A '+
                  'where A.CLSID = %s and A.X_PC_Run = %s and A.Hidden = ''N'' '+
                  'order by A.X_PC_ScriptName';
var
  mSQL : string;
  mList, mCol:TStringList;
  i:Integer;
begin
  mList := TStringList.Create;
  mCol := TStringList.Create;
  mSQL := Format(cSQLGetScript, [QuotedStr(Class_BOPackageSetting), IntToStr(ARun)]);
  AOS.SQLSelect(mSQL, mList);
  try
    for i:= 0 to mList.Count() -1 do
    begin
      NxTrapStrToStrings(mList[i], ';', mCol);
      if mCol.Count = 2 then
        AScripts.Values[mCol[1]] := NxTrim(mCol[0], '"');
    end;
  finally
    mList.Free;
    mCol.free;
  end;

end;

{
  Spustí definovaný script, který se vykoná nad datasety
}
procedure RunScript(AOS : TNxCustomObjectSpace; APackagesDataSet, AHeaderDataSet, AContentDataSet: TDataSet; ARun: integer = 0);
var
  mScript : string;
  mScripts: TStringList;
  i: integer;
begin
  CFxProfiler.EnterProc('postprovider.CustomScript', 'RunScript');
  if ARun = cScriptNone then
    exit;
  mScripts := TStringList.Create;
  try
    GetScripts(AOS, ARun, mScripts);

    for i:= 0 to mScripts.Count - 1 do begin
      mScript := mScripts[i];

      if mScript <> '' then
        CFxScriptingEngine.CallScript(mScript, [ObjToInt(AOS), ObjToInt(APackagesDataSet), ObjToInt(AHeaderDataSet), ObjToInt(AContentDataSet), ARun]);
    end;


  finally
    mScripts.Free;
  end;
  CFxProfiler.ExitProc('postprovider.CustomScript', 'RunScript');
end;

{
  Spustí definovaný script, který se vykoná nad datasety
}
function RunScript_PrintHook(AOS : TNxCustomObjectSpace; var ABOPDM: TNxCustomBusinessObject; ARun: integer = 0):String;
var
  mScript : string;
  mScripts: TStringList;
  i: integer;
begin
  CFxProfiler.EnterProc('postprovider.CustomScript', 'RunScript_PrintHook');
  Result := '';
  if ARun = cScriptNone then
    exit;
  mScripts := TStringList.Create;
  try
    GetScripts(AOS, ARun, mScripts);

    for i:= 0 to mScripts.Count - 1 do begin
      mScript := mScripts[i];

      if mScript <> '' then
        Result := CFxScriptingEngine.CallScript(mScript, [ObjToInt(AOS), ObjToInt(ABOPDM)]);
    end;


  finally
    mScripts.Free;
  end;
  CFxProfiler.ExitProc('postprovider.CustomScript', 'RunScript_PrintHook');
end;


{
  Spustí definovaný script, který se vykoná nad datasety
}
procedure RunScript_Content(AOS : TNxCustomObjectSpace; AContentDataSet: TDataSet; AField :TField; ARun: integer = 0);
var
  mScript : string;
  mScripts: TStringList;
  i: integer;
begin
  CFxProfiler.EnterProc('postprovider.CustomScript', 'RunScript_Content');
  if ARun = cScriptNone then
    exit;
  mScripts := TStringList.Create;
  try
    GetScripts(AOS, ARun, mScripts);

    for i:= 0 to mScripts.Count - 1 do begin
      mScript := mScripts[i];

      if mScript <> '' then
        CFxScriptingEngine.CallScript(mScript, [ObjToInt(AOS), ObjToInt(AContentDataSet),ObjToInt(AField)]);
    end;


  finally
    mScripts.Free;
  end;
  CFxProfiler.ExitProc('postprovider.CustomScript', 'RunScript_Content');
end;







begin
end.