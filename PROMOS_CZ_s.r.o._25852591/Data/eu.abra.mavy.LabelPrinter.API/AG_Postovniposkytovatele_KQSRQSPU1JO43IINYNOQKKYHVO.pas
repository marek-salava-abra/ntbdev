uses 'eu.abra.mavy.libs.common', 'eu.abra.mavy.LabelPrinter.API.fce', 'eu.abra.mavy.LabelPrinter.API.consts.consts';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  if CheckLicence(Self.SiteContext) then begin
    mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := 'Import LP';
    mAction.Hint := 'Importuje přepravce z LP';
    mAction.Category := 'tabList';
    mAction.OnExecute := @ImportOnExecute;
  end;
end;


procedure ImportOnExecute(Sender: TObject);
var
  mSite: TSiteForm;
  mBO, mRow, mContentType : TNxCustomBusinessObject;
  mRows : TNxCustomBusinessMonikerCollection;
  i,a : integer;
  mIssuedContentType_ID, mPostProvider_ID : string;
  mOS: TNxCustomObjectSpace;
  mWinHTTP: Variant;
  mJson: TJSONSuperObject;
  mShippersArray,mShipperRowsArray : TJSONSuperObjectArray;
  mToken,mRequest: string;
begin
  if Sender is TComponent then begin
    try
      mSite := TComponent(Sender).Site;
      mOS := mSite.SiteContext.GetObjectSpace;
      try
        mToken:= GetToken;
        if NxIsBlank(mToken) then
          exit;
        mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
        mWinHTTP.Open('GET', cURL + '/shippers');
        mWinHTTP.SetRequestHeader('Content-Type', 'application/json');
        mWinHTTP.SetRequestHeader('Authorization', 'Bearer '+mToken);
        mWinHTTP.Send('');
        if mWinHTTP.Status <> 200 then begin    //kód <> 200 = dotaz vůbec neprošel
          ShowMessage('Chyba při načítání dat z LP: ' + IntToStr(mWinHTTP.Status) +': '+ mWinHTTP.StatusText);
          exit;
        end
        else begin
          mJson := TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
          mShippersArray:= mJson.A['data'];
          for i:= 0 to mShippersArray.Length - 1 do begin
            if mShippersArray.O[i].S['code'] = '-' then continue;
            mPostProvider_ID:= SQLSingleSelect(mOS, 'SELECT ID FROM PDMPostProviders WHERE X_LP_Code ='+QuotedStr(mShippersArray.O[i].S['code'])+' and Hidden = ''N''');
            if NxIsEmptyOID(mPostProvider_ID) then begin
              mBO:= mOS.CreateObject(Class_PDMPostProvider);
              mBO.New;
              mBO.SetFieldValueAsString('Code', NxLeft(mShippersArray.O[i].S['code'],10));
              mBO.SetFieldValueAsString('X_LP_Code', mShippersArray.O[i].S['code']);
              mBO.SetFieldValueAsString('Name', mShippersArray.O[i].S['name']);
              mRows := mBo.GetLoadedCollectionMonikerForFieldCode(mBo.GetFieldCode('Rows'));
              mShipperRowsArray:= mShippersArray.O[i].A['services'];
              for a:= 0 to mShipperRowsArray.Length -1 do begin
                mRow:= mRows.AddNewObject;
                mRow.Prefill;
                mIssuedContentType_ID:= SQLSingleSelect(mOS, 'SELECT ID FROM PDMIssuedContentTypes WHERE Hidden = ''N'' and X_LP_Shipper = '+QuotedStr(mShippersArray.O[i].S['code'])+' and X_LP_Code = '+QuotedStr(mShipperRowsArray.O[a].S['code']));
                if NxIsEmptyOID(mIssuedContentType_ID) then begin
                  mContentType:= mOS.CreateObject(Class_PDMIssuedContentType);
                  mContentType.New;
                  mContentType.SetFieldValueAsString('Code', NxLeft(mShipperRowsArray.O[a].S['code'],10));
                  mContentType.SetFieldValueAsString('X_LP_Code', mShipperRowsArray.O[a].S['code']);
                  mContentType.SetFieldValueAsString('Name', mShipperRowsArray.O[a].S['name']);
                  mContentType.SetFieldValueAsString('X_LP_Shipper', mShippersArray.O[i].S['code']);
                  mContentType.Save;
                  mIssuedContentType_ID:= mContentType.OID;
                  mContentType.Free;
                end;
                mRow.SetFieldValueAsString('IssuedContentType_ID', mIssuedContentType_ID);
                mRow.SetFieldValueAsString('PriceList_ID', cPDMPriceListID);
              end;
              mBO.Save;
              mBO.Free;
            end;
          end;
        end;
      except
        ShowMessage('Při importu dat z LP nastala neočekávaná chyba: '+ExceptionMessage);
      end;
    finally
    end;
    ShowMessage('Import číselníků proběhl úspěšně');
    TBusRollSiteForm(mSite).RefreshData;
  end;
end;

begin
end.