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
  mAction.Caption := '##Synchronizovat objednávky##';
  mAction.Hint := 'Odesle objednávku na vzdálené API v JSON formátu';
  mAction.Category := 'tabList';
  mAction.OnExecute := @SyncOrdersAPI;
end;

procedure SyncOrdersAPI(Sender:TComponent);
var
  mSite: tSiteForm;
  mHeaderJSON, mRowJSON, mResultJSON: TJSONSuperObject;
  mBO, mRowBO: TNxCustomBusinessObject;
  i,j: integer;
  mRows: TNxCustomBusinessMonikerCollection;
  mErrorMessage:String;
  mList:TStringList;
begin
  mSite:=TComponent(Sender).DynSite;
  mList:=TStringList.Create;
  TDynSiteForm(mSite).List.GetSelectedId(mList);
  
  if mlist.Count>0 then begin
    mErrorMessage:='';
    WaitWin.StartProgress('Synchronizuji objednávky...', '', mList.Count);
    
    for j:=0 to mList.count-1 do begin
      mBO:=msite.BaseObjectSpace.CreateObject(Class_IssuedOrder);
      mBO.Load(mList.strings[j],nil);
      
      if Assigned(mBO) then begin
        try
          // Kontrola zda nebylo již odesláno
          if Not(NxIsBlank(mBO.GetFieldValueAsString('X_ExternalDocument'))) then begin
            NxShowSimpleMessage('Objednávka již byla synchronizována. Nelze odeslat znovu.',mSite);
            WaitWin.Stop;
            exit;
          end;

          // Příprava hlavičky dokladu v JSON
          mHeaderJSON:=TJSONSuperObject.Create;
          mHeaderJSON.S['Code']:=mBO.DisplayName;
          mHeaderJSON.S['DocumentNumber']:=mBO.GetFieldValueAsString('DocumentNumber');
          mHeaderJSON.S['ExternalNumber']:=mBO.GetFieldValueAsString('ExternalNumber');
          mHeaderJSON.DT8601['CreatedOn']:=mBO.GetFieldValueAsDateTime('CreatedOn');
          mHeaderJSON.S['Description']:=mBO.GetFieldValueAsString('Description');
          mHeaderJSON.S['FirmCode']:=mBO.GetFieldValueAsString('Firm_ID.Code');
          mHeaderJSON.S['FirmName']:=mBO.GetFieldValueAsString('Firm_ID.Name');
          mHeaderJSON.S['IssuedOrder_ID']:=mBO.OID;
          mHeaderJSON.O['Rows'] := mHeaderJSON.CreateJSONArray;

          // Načtení a příprava řádků dokladu
          mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
          
          for i:=0 to mRows.count-1 do begin
            mRowBO:=mRows.BusinessObject[i];
            mRowJSON:=TJSONSuperObject.Create;
            
            mRowJSON.I['RowNumber']:=i+1;
            mRowJSON.I['RowType']:=mRowBO.GetFieldValueAsInteger('RowType');
            mRowJSON.S['StoreCardCode']:=mRowBO.GetFieldValueAsString('StoreCard_ID.Code');
            mRowJSON.S['StoreCardName']:=mRowBO.GetFieldValueAsString('StoreCard_ID.Name');
            mRowJSON.D['Quantity']:=mRowBO.GetFieldValueAsFloat('Quantity');
            mRowJSON.S['QUnit']:=mRowBO.GetFieldValueAsString('Qunit');
            mRowJSON.S['Text']:=mRowBO.GetFieldValueAsString('Text');
            mRowJSON.S['Row_ID']:=mRowBO.OID;
            mRowJSON.D['Price']:=mRowBO.GetFieldValueAsFloat('Price');
            mRowJSON.D['Amount']:=mRowBO.GetFieldValueAsFloat('Amount');
            
            mHeaderJSON.A['Rows'].Add(mRowJSON);
          end;

          // UPRAVIT: Zadejte správné URL endpoint a typ dokladu
          mResultJSON:= TJSONSuperObject.Create;
          mResultJSON:= API_POST(mHeaderJSON, 'IssuedOrders');  // Parametr 'IssuedOrders' přizpůsobte

          // Uložení výsledku synchronizace
          if not(NxIsEmptyOID(mResultJSON.S['ID'])) then begin
            mBO.SetFieldValueAsString('X_ExternalDocument',mResultJSON.S['Code']);
            mBO.SetFieldValueAsBoolean('Issued',true);
            mBO.SetFieldValueAsDateTime('X_SendDate$Date',Now);
            mBO.save;
            TDynSiteForm(mSite).RefreshData;
          end else begin
            mErrorMessage:=mErrorMessage+#13#10+mResultJSON.S['Code'] + ' - Chyba při synchronizaci.';
          end;

          mBO.free;

        except
          WaitWin.Stop;
          NxShowSimpleMessage('Chyba při zpracování: '+ExceptionMessage, mSite);
        end;
      end;

      WaitWin.ChangeText(IntToStr(1+j) + ' / ' + IntToStr(mlist.Count));
      WaitWin.StepIt;
    end;
    
    WaitWin.Stop;
    
    if mErrorMessage <> '' then
      NxShowSimpleMessage('Chyby při synchronizaci:'+#13#10+mErrorMessage, mSite)
    else
      NxShowSimpleMessage('Synchronizace objednávek byla dokončena.', mSite);
  end;
end;

begin
end.