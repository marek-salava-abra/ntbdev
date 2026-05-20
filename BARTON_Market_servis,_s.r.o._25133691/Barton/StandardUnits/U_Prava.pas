const
  PARAM_EludeObjectRights = 'XBGC42IYSBL4P3UCAHPCI52T4W'; //Obchazet prava k objektum
  PARAM_SUPERVISOR = 'G1TDNZSKTVCL33N2010DELDFKK';
  PARAM_POUZIT     = '533UQUMUUIR4V0IBPS1ZQQBASS';
  PARAM_ZOBRAZIT   = 'TVB5REWXKGQONGZSYNXN4OGEKO';

////////////////////////////////////////////////////////////////////////////////
//vrati zda je aktualni uzivatel v roli - NERESI NADRIZENE ROLE
//aSupervisorIgnore = true - ignoruje privilegium Supervisor
function haveActUsrRole(aOS: TNxCustomObjectSpace; aRole_id: string; aSupervisorIgnore: boolean = false): boolean;
var
  List    : TStringList;
  sql: string;
begin
  try
    List := TStringList.create;
    sql:=
      'SELECT role_id '+
      'FROM SecurityUserRoleLinks '+
      'WHERE user_id=' + QuotedStr(NxGetActualUserID(aOS))+' AND role_id='+QuotedStr(aRole_id)+' ';

      //nebo ma privilegium Supervisor
      if(not aSupervisorIgnore)then
      sql:= sql+
        'UNION '+
        'select role_id from SecurityPrivilegeRights '+
        'where ClassID=''G1TDNZSKTVCL33N2010DELDFKK'' '+
        'and role_id in (SELECT role_id '+
        '  FROM SecurityUserRoleLinks '+
        '  WHERE user_id='+QuotedStr(NxGetActualUserID(aOS))+') ';

    aOS.SQLSelect(sql, List);

    result:= List.Count > 0;
  finally
    List.free;
  end;
end;//haveActUsrRole
////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// pomocna funkce pro tuto unitu
//vypise obsah parametru stringlistu
//odstranim Listy
//v nazvu parametru ponecham jen vse pred dvojteckou (je tam clsid)
procedure getParameterRightsToList(aParams: TNxParameters; var sl: TStringList);
  //----------------------------------------------------------------------------
  procedure getParama(aLevel: integer; aParams: TNxParameters; var aSl: TStringList);
  var
    i: integer;
    name: string;
  begin
    if(aLevel >= 20)then exit;

    for i := 0 to aParams.Count - 1 do begin
      if(aParams.Params[I].DataType = dtList)then begin
        //nevypisuju, zanorim se
        getParama(aLevel+1, aParams.Params[I].AsList, sl);
      end else begin
        name:= aParams.Params[I].Name;
        if(pos(':', name) > 0)then
          name:= copy(Name, 1, pos(':', name)-1);
        sl.Add(
          name+
          '='+aParams.Params[i].AsString);
      end;
    end;
  end;//getParama
  //----------------------------------------------------------------------------

begin
  getParama(0, aParams, sl);
end;
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
function havePrivilegium(OS: TNxCustomObjectSpace; aCLSID, aUser_ID: string):boolean;
var
  sl: tstringList;
begin
  sl:= TStringList.Create;
  try
    OS.SQLSelect(
      'Select 1 '+
      'from SECURITYUSERROLELINKS u '+
      'join SECURITYPRIVILEGERIGHTS A on u.ROLE_ID=a.ROLE_ID '+
      'WHERE '+
      '  u.USER_ID='+QuotedStr(aUser_ID)+
      '  and A.ClassID='+QuotedStr(aCLSID)
      , sl
    );
    result:= sl.Count > 0;
  finally
    sl.free;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//je uzivatel supervisor
function isSupervisor(OS: TNxCustomObjectSpace; User_ID: string):boolean;
{var
  pars: TNxParameters;
  slPar  : TStringList;
  CompanyCache: TNxCompanyCache;
  Context: TNxContext;
begin
  pars:= TNxParameters.Create;
  slPar:= TStringList.Create;
  Context:= NxCreateContext(OS);
  try
    CompanyCache:= Context.GetCompanyCache;
//    GetEffectiveObjectSecurityRights(CompanyCache, OS, 'x', 'x', User_ID, pars);
    GetEffectivePrivileges(CompanyCache, OS, User_ID, pars);
//    ParametersToFile('l:\Logs\Super'+User_ID+'.csv', pars);
    //presypu si do stringlistu a jako nazev necham jen CLSID
    getParameterRightsToList(pars, slPar);
    //ShowMessage(slPar.Values(PARAM_SUPERVISOR));
    result:= slPar.Values(PARAM_SUPERVISOR) = 'A'
  finally
    pars.free;
    slPar.free;
    Context.free;
  end;   }

begin
  result:= havePrivilegium(OS, PARAM_SUPERVISOR, User_ID);
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//ma uzivatel pravo zobrazit objekt CLSID?
//napr. CLSID zakazka = KYT0Q5QS1ND13ACL03KIU0CLP4
function canShowObject(OS: TNxCustomObjectSpace; aCLSID, aObject_ID, aUser_ID: string):boolean;
//pomoci standardni skriptove funkce - pomale ve verzi 9.2.3.
//  Neefektivne napsane v jadre (i kdyz zde nebyla zadna zmena). Vzdy totiz vytahuje vsechna prava pro vsechny objekty a oak dohleda jen pozadovany.
{var
  pars: TNxParameters;
  slPar  : TStringList;
  CompanyCache: TNxCompanyCache;
  Context: TNxContext;
begin
  pars:= TNxParameters.Create;
  slPar:= TStringList.Create;
  Context:= NxCreateContext(OS);
  try
    CompanyCache:= Context.GetCompanyCache;

    GetEffectiveObjectSecurityRights(CompanyCache, OS, aCLSID, aObject_ID, aUser_ID, pars);
//    ParametersToFile('l:\Logs\canShow'+User_ID+'.csv', pars);
    //presypu si do stringlistu a jako nazev necham jen CLSID
    getParameterRightsToList(pars, slPar);
    //ShowMessage(slPar.Values(PARAM_ZOBRAZIT));

    //privilegium Obchazet prava k objektum NEBO pravo na zakazku
    result:= (slPar.Values(PARAM_EludeObjectRights) = 'A') OR (slPar.Values(PARAM_ZOBRAZIT) = 'A')
  finally
    pars.free;
    slPar.free;
    Context.free;
  end; }

var
  sl: tstringList;
begin
  if(havePrivilegium(OS, PARAM_EludeObjectRights, aUser_ID))then begin
    result:= true;
    exit;
  end;

  sl:= TStringList.Create;
  try
    OS.SQLSelect(
      'Select case when max(BIN_AND(a.GrantedMask,1)) > 0 and max(BIN_AND(a.DeniedMask,1)) = 0 then ''A'' else ''N'' end '+
      'from SECURITYUSERROLELINKS u '+
      'join SecurityObjectRights A on u.ROLE_ID=a.ROLE_ID '+
      'WHERE '+
      '  u.USER_ID='+QuotedStr(aUser_ID)+
      '  and A.ClassID='+QuotedStr(aCLSID)+
      ' and A.ProgID='+QuotedStr(aObject_ID)
      , sl
    );
    result:= (sl.Count > 0) and (sl[0] = 'A');
  finally
    sl.free;
  end;
end;
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
//funkce pro volani z QR. Slouzi napr. k ovlivneni zobrazeni variantniho formulare
//NXScript('StandardUnits.U_Prava.QRCanShowObject', 'KYT0Q5QS1ND13ACL03KIU0CLP4', ID)
//napr. CLSID zakazka = KYT0Q5QS1ND13ACL03KIU0CLP4
function QRCanShowObject(AReportHelper:TNxQRScriptHelper; aCLSID, aObject_ID: string):Boolean;
begin
  result:= canShowObject(AReportHelper.ObjectSpace, aCLSID, aObject_ID, NxGetActualUserID(AReportHelper.ObjectSpace));
end;
////////////////////////////////////////////////////////////////////////////////


begin
end.