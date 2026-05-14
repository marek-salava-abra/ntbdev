uses 'eu.abra.boma.autoII.const';
const
  cFirm_ID='1CE0000201';   //NetCentrum
  cFirmTS_ID='1E23000201'; //Technistore
  c004Firm_ID='2D50000201'; //REGISTROVANÝ ZÁKAZNÍK
  cOPN='1V00000201';       //řada dokladu
  cOPRN='2V00000201';      //řada dokladu
  cOPB='1X00000201';       //řada dokladu
  cOP='3200000201'; //
  cErrText='Nelze použít tuto kombinaci řady dokladu a firmy.';
  cNormal=1;
  cPayU=2;
  cZL=3;
  cSTORNO=4;
  cVATRate='02100X0000';    //dph rpo dopravu
  cStore_ID='1000000201';
  cDivision_ID='1000000201';
  cPlatbaZalohy='1200000201';
  cKreditka='1000000201';
  cSourcePath='\\Abraserver\SolidniObchod';      //cesta, kde se vyskytují nové objednávky
  cDonePath='\\abraserver\SolidniObchod\OPN_%s_OLD'; //cesta, kam se zpracované objednávky uloží
  cZalohaPath='\\abraserver\SolidniObchod\Zalohy';//cesta, kam se ukládají objednávky čekající na zaplecení zálohy
  cMailPath='\\abraserver\SolidniObchod\mail';
  cFirmsPath='\\abraserver\SolidniObchod\Firmy'; //cesta kam ukládat firmy pro synchronizaci z G4 do G3
  cSourcePathTS='\\Abraserver\Technistore';      //cesta, kde se vyskytují nové objednávky
  cDonePathTS='\\abraserver\Technistore\OPN_%s_OLD'; //cesta, kam se zpracované objednávky uloží
  cZalohaPathTS='\\abraserver\Technistore\Zalohy';//cesta, kam se ukládají objednávky čekající na zaplecení zálohy
  cMailPathTS='\\abraserver\Technistore\mail';
  cFirmsPathTS='\\abraserver\Technistore\firms'; //cesta kam ukládat firmy pro synchronizaci z G4 do G3
  cCardsPathTS='\\abraserver\Technistore\storecards'; //cesta kam ukládat firmy pro synchronizaci z G4 do G3
  cCurrency_ID='0000CZK000';
  cIntrastatDeliveryTerm_ID='1001000000';
  cIntrastatTransactionType_ID='T001000000';
  cIntrastatTransportationType_ID='4000000000';
  cForeignConstSymbol='0000110000';
  cLocalConstSymbol='0000008000';
  cDopravneProj = '1000000201';
  
  cShopsCount=5;   //počet evidovaných e-shopů
  cstSQL_RO_II = 'select DQ.Code || ''-'' || RO.OrdNumber || ''/'' || P.Code || case length(RO.ExternalNumber) WHEN 0 then '''' ELSE '' ('' || RO.ExternalNumber || '')'' END ' +
  'from receivedorders RO ' +
  'join docqueues dq on dq.id=ro.docqueue_id ' +
  'join periods p on p.id=ro.period_id ' +
  'where RO.ID in ' +
  '(select distinct sd2.Provide_ID from storedocuments2 sd2 where sd2.id in ' +
  '(select distinct II2.ProvideRow_ID from issuedinvoices ii left join issuedinvoices2 ii2 on ii.id=ii2.parent_id where ii.id=''%s''))';
  cstSQL_RO_ICN = 'select DQ.Code || ''-'' || RO.OrdNumber || ''/'' || P.Code || case length(RO.ExternalNumber) WHEN 0 then '''' ELSE '' ('' || RO.ExternalNumber || '')'' END ' +
  'from receivedorders RO ' +
  'join docqueues dq on dq.id=ro.docqueue_id ' +
  'join periods p on p.id=ro.period_id ' +
  'where RO.ID in ' +
  '(select distinct sd2.Provide_ID from storedocuments2 sd2 where sd2.id in ' +
  '(select distinct II2.ProvideRow_ID from issuedinvoices ii left join issuedinvoices2 ii2 on ii.id=ii2.parent_id where ii2.id in ' +
  '(select distinct icn2.RSource_ID from issuedcreditnotes icn left join IssuedCreditNotes2 icn2 on icn.id=icn2.parent_id where icn.id=''%s'')))';
  cstSQL_RO_RO = 'select DQ.Code || ''-'' || RO.OrdNumber || ''/'' || P.Code || case length(RO.ExternalNumber) WHEN 0 then '''' ELSE '' ('' || RO.ExternalNumber || '')'' END ' +
  'from receivedorders RO ' +
  'join docqueues dq on dq.id=ro.docqueue_id ' +
  'join periods p on p.id=ro.period_id ' +
  'where RO.ID = ''%s''';
  cstSQL_RO_BOD = 'select DQ.Code || ''-'' || RO.OrdNumber || ''/'' || P.Code || case length(RO.ExternalNumber) WHEN 0 then '''' ELSE '' ('' || RO.ExternalNumber || '')'' END ' +
  'from receivedorders RO ' +
  'join docqueues dq on dq.id=ro.docqueue_id ' +
  'join periods p on p.id=ro.period_id ' +
  'where RO.ID in ' +
  '(select distinct sd2.Provide_ID from storedocuments2 sd2 where sd2.parent_id = ''%s'')';


var
  cEmailAccount_ID: array [1..cShopsCount] of String;

function getRONumber2(mCO: TNxCustomBusinessObject): String;
var
  mStrings: TStringList;
  mSQL : String;
begin
  Result:='';
  case mCO.CLSID of
    Class_IssuedInvoice: mSQL := NxSearchReplace(cstSQL_RO_II,'%s',mCO.OID,[srAll]);
    Class_IssuedCreditNote: mSQL := NxSearchReplace(cstSQL_RO_ICN,'%s',mCO.OID,[srAll]);
    Class_ReceivedOrder: mSQL := NxSearchReplace(cstSQL_RO_RO,'%s',mCO.OID,[srAll]);
    Class_BillOfDelivery: mSQL := NxSearchReplace(cstSQL_RO_BOD,'%s',mCO.OID,[srAll]);
    else mSQL := '';
  end;
  if Length(mSQL) > 0 then
  begin
    mStrings := TStringList.Create;
    try
      mCO.ObjectSpace.SQLSelect(mSQL,mStrings);
      if mStrings.Count > 0 then  Result := mStrings.CommaText else Result := '';
    finally
      mStrings.Free;
    end;
  end;
end;

procedure PreFillEmailAccounts;       //nastavení e-mailových účtů pro shopy
begin
  cEmailAccount_ID[1]:='1200000201';
  cEmailAccount_ID[2]:='1300000201';
  cEmailAccount_ID[3]:='1400000201';
  cEmailAccount_ID[4]:='1600000201';
  cEmailAccount_ID[5]:='1400000201';
end;

function getShopStrFromCounter(ACurrentShop: Integer): String;
begin
  case ACurrentShop of
  1: Result:='SO';
  2: Result:='VNC';
  3: Result:='CL';
  4: Result:='SOSK';
  5: Result:='CLSK';
  else RaiseException('Nepovolený počet shopů, je potřeba upravit definice.');
  end;
end;

function getCurrentShopFromStr(AShopStr: String): Integer;
begin
  case AShopStr of
  'SO': Result:=1;
  'VNC': Result:=2;
  'CL': Result:=3;
  'SOSK': Result:=4;
  'CLSK': Result:=5;
  else RaiseException('Nepovolená zkratka shopu, je potřeba upravit definice.');
  end;
end;

function getCurrentShopBO(OS:TNxCustomObjectSpace;AShop: Integer; var mBO: TNxCustomBusinessObject): Boolean;
var
  mCode: String;
  mResult: TStringList;
begin
  mCode:='N' + NxPadL(IntToStr(AShop),3,'0');
  mResult:=TStringList.Create;
  try
    OS.SQLSelect(Format('Select ID From BusOrders Where Hidden=''N'' and Code=''%s''',[mCode]),mResult);
    if mResult.Count=1 then begin
      Result:=True;
      mBO.Load(mResult[0],nil);
    end else Result:=False;
  finally
    mResult.Free;
  end;
end;

function getCurrentShopWWW(OS:TNxCustomObjectSpace;AShop: Integer): String;
var
  mBO: TNxCustomBusinessObject;
  mCode: String;
  mResult: TStringList;
begin
  mCode:='N' + NxPadL(IntToStr(AShop),3,'0');
  mResult:=TStringList.Create;
  try
    OS.SQLSelect(Format('Select Name From BusOrders Where Hidden=''N'' and Code=''%s''',[mCode]),mResult);
    if mResult.Count=1 then Result:=mResult[0]
    else RaiseException('Chyba při dohledání zakázky.');
  finally
    mResult.Free;
  end;
end;



begin
end.