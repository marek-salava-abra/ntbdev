uses '.lib';

// ===== SYNCHRONIZACE OBJEDÁVEK VYDANÝCH Z FIRMY =====
// Skript slouží pro odesílání dokladů objedávek vydaných v JSON formátu na vzdálené API
// Odesílané údaje zahrnují: hlavičku dokladu a řádky s detailem

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actGetCardOverAPI';
  mAction.Caption := '##Karta z BMS##';
  mAction.Hint := 'Dohledá kartu na BMS a založí';
  mAction.Category := 'tabList';
  mAction.OnExecute := @GetCardOverAPI;
end;

Procedure GetCardOverAPI(sender:tcomponent);
var
  mSite: TSiteForm;
  mCode, mStoreCardID, mRemoteStoreCardID: string;
  mStoreCardJSON, mResultJSON, mJSON: TJSONSuperObject;
  mStoreCardArray: TJSONSuperObjectArray;
  mList: TStringList;
  mBO, mUnitBO, mEANBO: TNxCustomBusinessObject;
  mUnits, mEANs: TNxCustomBusinessMonikerCollection;
begin
  mSite := TComponent(Sender).BusRollSite;
  mCode := Trim(InputBox('BMS skladová karta', 'Zadejte kód skladové karty', ''));
  if mCode = '' then
    Exit;

  mStoreCardID := mSite.BaseObjectSpace.SQLSelectFirstAsString(
    'Select id from storecards where code='+QuotedStr(mCode)+' and hidden=''N''', '');

  if not NxIsEmptyOID(mStoreCardID) then
  begin
    NxShowSimpleMessage('Skladová karta ''' + mCode + ''' již existuje v aktuální databázi.', mSite);
  
    Exit;
  end;

  mRemoteStoreCardID := '';
  mStoreCardJSON := API_GET(
    'https://api.barton.cz:8444/barton/Storecards?select=id,code,name&where=code eq '+QuotedStr(mCode)+' and hidden eq ''N''');
  try
    mStoreCardArray := mStoreCardJSON.AsArray;
    if mStoreCardArray.Length = 1 then
    begin
      mRemoteStoreCardID := mStoreCardArray.O[0].S['id'];
    end else begin
      NxShowSimpleMessage('Karta podle kódu ' + mCode + ' nebyla nalezena na BMS.', mSite);
      Exit;
    end;
  finally
    mStoreCardJSON.Free;
  end;

  if not(NxIsEmptyOID(mRemoteStoreCardID)) then
  begin
    mJSON := TJSONSuperObject.Create;
    try
      mJSON.S['id']:=mremoteStoreCardID;
      mResultJSON := API_POST(mJSON, 'StoreCards', True);
    finally
      //mJSON.Free;
    end;

    try
      Nxshowsimplemessage('InputJson'+mJSON.AsString+NxCrlF+'ResultJSON '+mResultJSON.AsString, mSite);
      if Assigned(mResultJSON) and (mResultJSON.I['error_code']>0) then
         NxShowsimplemessage('Chyba při založení skladové karty. '+inttostr(mResultJSON.I['error_code'])+nxcrlf+mresultjson.S['description'], mSite);
      if Assigned(mResultJSON) and not NxIsEmptyOID(mResultJSON.S['ID']) then
      begin
       NxShowsimplemessage(mresultjson.AsString, mSite);
       {
        mBO:= mSite.BaseObjectSpace.CreateObject(Class_StoreCard);
        mBO.new;
        mBO.prefill;

        mbo.save;
        mStoreCardID := mbo.OID;
        mBO.free;
        TBusRollSiteForm(mSite).DataSet.SeekID(mStoreCardID);}
      end
      else
      begin
        NxShowSimpleMessage('Chyba při založení skladové karty: ' + mResultJSON.S['Code'] + ' ' + mResultJSON.S['Status'], mSite);
        Exit;
      end;
    finally
      mResultJSON.Free;
    end;
  end
  else
  begin
    NxShowSimpleMessage('Skladová karta již existuje na BMS: ' + mCode, mSite);
  end;

end;

begin
end.