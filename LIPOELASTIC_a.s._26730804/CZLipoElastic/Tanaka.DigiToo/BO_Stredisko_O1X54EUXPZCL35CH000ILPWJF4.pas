procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
var
  lcCodePrev, lcCodeAct, lcNamePrev, lcNameAct: string;
begin
  Self.GetOriginalValue('Code', lcCodePrev);
  lcCodeAct:= Self.GetFieldValueasString('Code');
  Self.GetOriginalValue('Name', lcNamePrev);
  lcNameAct:= Self.GetFieldValueasString('Name');
  if (lcCodeAct<>lcCodePrev) or (lcNameAct<>lcNamePrev) then GlobParams.GetOrCreateParam(dtBoolean,'glDigitooSync_'+Self.CLSID+'_'+Self.OID).AsBoolean:= True;
end;

procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
  lbDigitooSync: boolean;
begin
  lbDigitooSync:= GlobParams.ParamAsBoolean('glDigitooSync_'+Self.CLSID+'_'+Self.OID, False);
  GlobParams.DeleteByName('glDigitooSync_'+Self.CLSID+'_'+Self.OID);
  if lbDigitooSync then begin
    CFxScriptingEngine.CallScript('Tanaka.DigiToo.Main.UpdateRegister',[
      Self.ObjectSpace
     , 'SELECT ID, Code||'': ''||Name AS Label FROM Divisions WHERE Hidden=''N'' ORDER BY NAME'
     , 'cost_center'
     ]);
  end;
end;

begin
end.