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
  mAction.Name := 'actSyncOrdersAPI';
  mAction.Caption := '##Odeslat do BMS##';
  mAction.Hint := 'Odesle objednávku na vzdálené API v JSON formátu';
  mAction.Category := 'tabList';
  mAction.OnExecute := @SyncOrdersAPI;
end;

procedure SyncOrdersAPI(Sender:TComponent);
var
  mSite: tSiteForm;
  mHeaderJSON, mRowJSON, mResultJSON, mStoreCardJSON: TJSONSuperObject;
  mStoreCardArray: TJSONSuperObjectArray;
  mBO, mRowBO: TNxCustomBusinessObject;
  i,j,k, l: integer;
  mRows: TNxCustomBusinessMonikerCollection;
  mErrorMessage, mStoreCardCode, mStoreCardID:String;
  mList, mReceiptCardList:TStringList;
  mNotFoundCards:TStringList;
begin
  mSite:=TComponent(Sender).DynSite;
  mList:=TStringList.Create;
  mErrorMessage:='';
  mReceiptCardList:=TStringList.create;
  TDynSiteForm(mSite).List.GetSelectedId(mReceiptCardList);
  if mReceiptCardList.count>0 then begin
   mNotFoundCards:=TStringList.Create;
   mNotFoundCards.Clear;
   for l:=0 to mReceiptCardList.count-1 do begin
      mBO:=msite.BaseObjectSpace.CreateObject(Class_ReceiptCard);
      mBO.load(mReceiptCardList.strings[l],nil);
      if Assigned(mBO) then begin
        // Načtení a příprava řádků dokladu
          mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
        try
          // Kontrola existence skladových karet na vzdáleném API
          WaitWin.StartProgress('Kontrola položek, čekejte ...', '', mRows.Count);

          for i:=0 to mRows.count-1 do begin
            mRowBO:=mRows.BusinessObject[i];

            if not(NxIsEmptyOID(mRowBO.GetFieldValueAsString('StoreCard_ID'))) then begin
              mStoreCardCode:=mRowBO.GetFieldValueAsString('StoreCard_ID.Code');

              // GET dotaz na vzdálené API - kontrola existence skladové karty
              mStoreCardJSON:=API_GET('https://api.barton.cz:8444/barton/Storecards?select=id&where=code eq '+QuotedStr(mStoreCardCode)+' and hidden eq ''N''');

              if Assigned(mStoreCardJSON) then begin
                mStoreCardArray:=mStoreCardJSON.AsArray;
                k:=mStoreCardArray.Length;

                if k=1 then
                  mStoreCardID:=mStoreCardArray.O[0].S['id']
                else
                  mStoreCardID:='';

                // Kontrola, zda je ID prázdné
                if NxIsEmptyOID(mStoreCardID) then begin
                  if mNotFoundCards.IndexOf(mStoreCardCode)=-1 then
                    mNotFoundCards.Add('Řádek '+ IntToStr(i+1) + ': ' + mStoreCardCode);
                end;
              end;
            end;
            WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(mRows.Count));
            WaitWin.StepIt;
          end;
          WaitWin.Stop;

          // Pokud byly nalezeny nenalezené karty, zastavit a vypsat chybu

      except

      end;
       if mNotFoundCards.count>0 then begin
        WaitWin.Stop;
        NxShowSimpleMessage('Skladové karty neexistují v Š&M:'+ #13#10 + #13#10 + mNotFoundCards.Text + #13#10 + #13#10 + 'Synchronizace byla zrušena.',mSite);
        mNotFoundCards.Free;
        exit;
      end;
      mNotFoundCards.Free;
    end;
    for l:=0 to mReceiptCardList.count-1 do begin
      mBO:=msite.BaseObjectSpace.CreateObject(Class_ReceiptCard);
      mBO.load(mReceiptCardList.strings[l],nil);
      mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
      try
        if Assigned(mBO) then begin
           if l=0 then begin
            // Příprava hlavičky dokladu v JSON
            mHeaderJSON:=TJSONSuperObject.Create;
            mHeaderJSON.S['Code']:=mBO.DisplayName;
            mHeaderJSON.S['DocumentNumber']:=mBO.displayname;
            //mHeaderJSON.S['ExternalNumber']:=mBO.GetFieldValueAsString('ExternalNumber');
            //mHeaderJSON.DT8601['CreatedOn']:=mBO.GetFieldValueAsDateTime('CreatedOn');
            mHeaderJSON.S['Description']:=mBO.GetFieldValueAsString('Description');
            //mHeaderJSON.S['FirmCode']:=mBO.GetFieldValueAsString('Firm_ID.Code');
            //mHeaderJSON.S['FirmName']:=mBO.GetFieldValueAsString('Firm_ID.Name');
            mHeaderJSON.S['FirmOrgIdentNumber']:='25133691';
            mHeaderJSON.S['IssuedOrder_ID']:=mBO.OID;
            mHeaderJSON.O['Rows'] := mHeaderJSON.CreateJSONArray;
           end;
            for i:=0 to mRows.count-1 do begin
              mRowBO:=mRows.BusinessObject[i];
              if mRowBO.GetFieldValueAsInteger('RowType') in [2,3] then begin
                mRowJSON:=TJSONSuperObject.Create;
                mRowJSON.I['RowNumber']:=i+1;
                mRowJSON.I['RowType']:=mRowBO.GetFieldValueAsInteger('RowType');
                mRowJSON.S['StoreCardCode']:=mRowBO.GetFieldValueAsString('StoreCard_ID.Code');
                mRowJSON.S['StoreCardName']:=mRowBO.GetFieldValueAsString('StoreCard_ID.Name');
                mRowJSON.D['Quantity']:=mRowBO.GetFieldValueAsFloat('Quantity');
                mRowJSON.S['QUnit']:=mRowBO.GetFieldValueAsString('Qunit');
                mRowJSON.S['Text']:=mRowBO.GetFieldValueAsString('Text');
                mRowJSON.S['Row_ID']:=mRowBO.OID;
                mHeaderJSON.A['Rows'].Add(mRowJSON);
              end;
            end;
         end;
         mbo.free;

        except

         // NxShowSimpleMessage('Chyba při zpracování: '+ExceptionMessage, mSite);
        end;
      end;
   end;
   mResultJSON:= TJSONSuperObject.Create;
   mResultJSON:= API_POST(mHeaderJSON, 'IssuedOrders');  // Parametr 'IssuedOrders' přizpůsobte
   TDynSiteForm(mSite).RefreshData;

end;
    if mErrorMessage <> '' then
      NxShowSimpleMessage('Chyby při synchronizaci:'+#13#10+mErrorMessage, mSite)
    else
      NxShowSimpleMessage('Synchronizace dokladů byla dokončena.', mSite);
end;

begin
end.