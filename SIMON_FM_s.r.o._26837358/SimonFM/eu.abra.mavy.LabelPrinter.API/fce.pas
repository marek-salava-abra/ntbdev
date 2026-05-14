uses 'eu.abra.mavy.libs.common', 'eu.abra.mavy.LabelPrinter.API.consts.consts';
const
  cLicensedOrgIdentNumber = '26837358';

function GetToken: string;
var
  mWinHTTP: Variant;
  mJson: TJSONSuperObject;
  mToken,mRequest: string;
begin
  try
    mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
    mWinHTTP.Open('POST', cURL + '/connect/token');
    mWinHTTP.SetRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    mRequest := 'grant_type=' + cGrant_type + '&';
    mRequest := mRequest + 'client_id=' + cClient_ID + '&';
    mRequest := mRequest + 'client_secret=' + cClient_Secret + '&';
    mRequest := mRequest + 'scope=' + cScope;
    mWinHTTP.Send(mRequest);
    if mWinHTTP.Status <> 200 then begin    //kód <> 200 = dotaz vůbec neprošel
      if CFxNxRuntime.NxGetEnvironmentType = reRuntimeExe then ShowMessage('Nebylo možné vygenerovat přístupový token: ' + IntToStr(mWinHTTP.Status) +': '+ mWinHTTP.StatusText + ' '+mWinHTTP.ResponseText);
    end
    else begin
      mJson := TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
      mToken := mJSon.S['access_token'];
      Result:= mToken;
    end;
  except
    if CFxNxRuntime.NxGetEnvironmentType = reRuntimeExe then ShowMessage('Nastala neočekávaná chyba při získávání tokenu: '+ExceptionMessage);
  end;
end;

function CorrectPhoneNumber(aNumber1:String;aNumber2:String):String;
var mNumber: String;
begin
  if Length(aNumber1)=0 then mNumber:=aNumber2
    else mNumber:=aNumber1;
  mNumber:=NxSearchReplace(mNumber,' ','',[srAll]);
  Result:=mNumber;
end;

function API_GET(AURL:string): TJSONSuperObject;
var
  mWinHTTP: Variant;
  mToken,mRequest: string;
begin
  try
    mToken:= GetToken;
    if NxIsBlank(mToken) then
      exit;
    mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
    mWinHTTP.Open('GET', cURL + AURL);
    mWinHTTP.SetRequestHeader('Content-Type', 'application/json');
    mWinHTTP.SetRequestHeader('Authorization', 'Bearer '+mToken);
    mWinHTTP.Send('');
    Result := TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
  except
    if CFxNxRuntime.NxGetEnvironmentType = reRuntimeExe then ShowMessage('Při GET dotazu do LabelPrinter nastala neočekávaná chyba: '+ExceptionMessage);
  end;
end;

function PrintIssuedInvoice(AContext: TNxContext; ADocumentID, aDYNSQL: String; AReportID: String): TBytes;
var
  mTempDir: String;
  mIDs: TStrings;
  mFileName: String;
begin
  mIDs := TStringList.Create;
  try
    mIDs.Add(ADocumentID);
    Result := CFxReportManager.PrintByIDsToBytes(AContext, mIDs, aDYNSQL, AReportID, pekPDF);
  finally
    mIDs.Free;
  end;
end;

function GetDataFromUser(AOS: TNxCustomObjectSpace; AID, AFieldName:string):string;
var
  mUser: TNxCustomBusinessObject;
begin
  try
    mUser := AOS.CreateObject(Class_SecurityUser);
    mUser.Load(AID, nil);
    if mUser.HasField(AFieldName) then
      Result:= mUser.GetFieldValueAsString(AFieldName)
    else
      Result:= '';
  finally
    mUser.Free;
  end;
end;

Function ImportLPStates(Sender: TObject): boolean;
var
  mSite: TSiteForm;
  mBO: TNxCustomBusinessObject;
  i,mColor: integer;
  mOS: TNxCustomObjectSpace;
  mName,mCode: string;
  mList: TStringList;
begin
  if Sender is TComponent then begin
    try
      mSite := TComponent(Sender).Site;
      mOS := mSite.SiteContext.GetObjectSpace;
      mList:= TstringList.Create;
      mList.Add('0;Před odesláním;12632256');
      mList.Add('1;Netištěný;16744703');
      mList.Add('2;Tištěný;65280');
      mList.Add('3;Stornovaný;255');
      mList.Add('4;Připravený;16777088');
      mList.Add('5;Nenačtený;32896');
      mList.Add('6;Spojený;8421440');
      mList.Add('7;Tištěný s chybou;33023');
      for i:=0 to mList.Count - 1 do begin
        mBO:= mOS.CreateObject(Class_LabelPrinter_States);
        mBO.New;
        mCode:= NxToken(mList.Strings[i],';');
        mName:= NxToken(mList.Strings[i],';');
        mColor:= StrToInt(mList.Strings[i]);
        mBO.SetFieldValueAsString('Code', mCode);
        mBO.SetFieldValueAsString('Name', mName);
        mBO.SetFieldValueAsInteger('X_BackgroundColor', mColor);
        mBO.Save;
      end;
    ShowMessage('Import stavů proběhl úspěšně');
    TBusRollSiteForm(mSite).RefreshData;
    finally
      mBO.Free;
      mList.Free;
    end;
  end;
end;

function StripOnlyNumbers(s:string):string;
var
  i,j:Integer;
begin
  for i:=1 to Length(s) do begin
    if (s[i] in ['0','1','2','3','4','5','6','7','8','9']) then
    begin
     result:= result + s[i];
    end;
  end;
end;

function ImportFromLP(AOS: TNxCustomObjectSpace; AList: TStringList; var ALogInfoStr: string):boolean;
var
  mBO, mSourceBO : TNxCustomBusinessObject;
  i, mPocetZmen : integer;
  mWinHTTP: Variant;
  mJson: TJSONSuperObject;
  mDataArray,mShipperRowsArray : TJSONSuperObjectArray;
  mErrorMsg, mStatus, mID, mToken,mState_ID,mBarcode, mStateCode,mTrackingURL : string;
  mDelivered,mPrintedAt: TDateTime;
  mIsInClosingDay: boolean;
begin
  try
    mPocetZmen:= 0;
    mErrorMsg:= '';
    Result:= True;
    mBO := AOS.CreateObject(Class_PDMIssuedDoc);
    for i := 0 to AList.Count - 1 do begin
      try
        mDelivered:= 0;
        mPrintedAt:= 0;
        mBO.Load(AList.Strings[i], nil);
        mID:= mBO.GetFieldValueAsString('X_LP_ExternalID');
        if not NxIsBlank(mID) then begin
          if not (mBO.GetFieldValueAsString('X_LP_State_ID.Code') = '3') then begin
            mJSON:= API_GET('/shipments/'+mID);
            mStatus:= mJSON.S['code'];
            //ShowMessage(mJson.AsString);
            if mStatus = '200' then begin
              //***************TODO: je potřeba vyřešit načíání více než jeden balík **************
              mStateCode:= mJson.A['data'].O[0].O['state'].S['code'];
              {try
                mDelivered:= ISODateTimeToDateTime(mJson.A['data'].O[0].A['parcels'].O[0].S['delivered']);
              except
              end;
              try
                mPrintedAt:= ISODateTimeToDateTime(mJson.A['data'].O[0].S['printedAt']);
              except
              end; }
              if mJson.A['data'].O[0].A['parcels'].O[0].N['delivered'].DataType <> jtNull then
                mDelivered:= ISODateTimeToDateTime(mJson.A['data'].O[0].A['parcels'].O[0].S['delivered']);
              if mJson.A['data'].O[0].N['printedAt'].DataType <> jtNull then
                mPrintedAt:= ISODateTimeToDateTime(mJson.A['data'].O[0].S['printedAt']);
              mIsInClosingDay:= mJson.A['data'].O[0].A['parcels'].O[0].B['isInClosingDay'];
              mState_ID:= SQLSingleSelect(AOS, 'SELECT ID FROM DefRollData WHERE Code = '+ QuotedStr(mStateCode) + ' and CLSID = ''VB0Q5JB0CRD4V4HES4OTTIYVIK''');
              if not NxIsEmptyOID(mState_ID) then begin
                if not (mIsInClosingDay = mBO.GetFieldValueAsBoolean('X_LP_IsInClosingDay')) or
                   not (mState_ID = mBO.GetFieldValueAsString('X_LP_State_ID')) or
                   not (DateTimeToStr(mDelivered) = DateTimeToStr(mBO.GetFieldValueAsDateTime('X_LP_DeliveredAt'))) or
                   not (DateTimeToStr(mPrintedAt) = DateTimeToStr(mBO.GetFieldValueAsDateTime('X_LP_PrintedAt'))) then begin
                  mBarcode:=   mJson.A['data'].O[0].A['parcels'].O[0].S['trackingNumber'];
                  mTrackingURL:=   mJson.A['data'].O[0].A['parcels'].O[0].S['trackingUrl'];
                  mBO.SetFieldValueAsString('X_LP_State_ID', mState_ID);
                  mBO.SetFieldValueAsString('X_LP_Tracking_URL', mTrackingURL);
                  mBO.SetFieldValueAsString('X_LP_Barcode', mBarcode);
                  mBO.SetFieldValueAsBoolean('X_LP_IsInClosingDay', mIsInClosingDay);
                  if mDelivered> 0 then
                    mBO.SetFieldValueAsDateTime('X_LP_DeliveredAt', mDelivered);
                  if mPrintedAt> 0 then
                    mBO.SetFieldValueAsDateTime('X_LP_PrintedAt', mPrintedAt);
                  mBO.Save;

                  // uložení informací do zdrojového dokladu
                  try
                    mSourceBO:= AOS.CreateObject(mBO.GetFieldValueAsString('X_LP_SourceCLSID'));
                    mSourceBO.Load(mBO.GetFieldValueAsString('X_LP_Source_ID'),nil);
                    mSourceBO.SetFieldValueAsString('X_LP_State_ID', mState_ID);
                    mSourceBO.SetFieldValueAsString('X_LP_Barcode', mBarcode);
                    mSourceBO.SetFieldValueAsBoolean('X_LP_IsInClosingDay', mIsInClosingDay);
                    if mDelivered> 0 then
                      mSourceBO.SetFieldValueAsDateTime('X_LP_DeliveredAt', mDelivered);
                    if mPrintedAt> 0 then
                      mSourceBO.SetFieldValueAsDateTime('X_LP_PrintedAt', mPrintedAt);
                    mSourceBO.Save;
                  Except
                    mErrorMsg:= mErrorMsg + mBO.DisplayName+' - Při změně stavu na zdrojovém dokladu nastala chyba: '+ExceptionMessage + #13#10;
                  end;

                  mPocetZmen:= mPocetZmen + 1;
                end;
              end;
            end
            else begin
              if mStatus = '404' then begin
                mState_ID:= SQLSingleSelect(AOS, 'SELECT ID FROM DefRollData WHERE Code = ''3'' and CLSID = ''VB0Q5JB0CRD4V4HES4OTTIYVIK''');  //status storno
                mBO.SetFieldValueAsString('X_LP_Error_message', mBO.GetFieldValueAsString('X_LP_Error_Message')+#13#10+mJSON.A['errors'].O[0].S['message']);
                mBO.SetFieldValueAsBoolean('X_LP_IsError', True);
                mBO.SetFieldValueAsString('X_LP_Barcode', '');
                mErrorMsg:= mErrorMsg + mBO.DisplayName+' - ' + mJSON.A['errors'].O[0].S['message']+#13#10;
                mBO.SetFieldValueAsString('X_LP_State_ID', mState_ID);
                mBO.Save;
              end;
            end;
          end;
        end;
      except
        Result:= False;
        mErrorMsg:= mErrorMsg + 'Nastala neočekáváná při aktualizaci stavů z LP: ' + ExceptionMessage +#13#10;
      end;
    end;
  finally
    mBO.Free;
    if Assigned(mSourceBO) then mSourceBO.Free;
    mJSON.Free;
  end;
  if not NxIsBlank(mErrorMsg) then ALogInfoStr:= 'Chyba při aktualizaci stavu: '+#13#10+mErrorMsg;
  if mPocetZmen > 0 then AlogInfoStr:= ALogInfoStr + 'Import dat zásilek z Label Priner proběhl úspěšně.'#13#10'Počet změněných stavů: '+IntToStr(mPocetZmen);
end;

function CheckLicence(AContext: TNxContext): boolean;
var
  mCompanyOrgIdentNumber: String;
  //mContext: TNxContext;
begin
  Try
    //mContext:= NxCreateContext(AOS);
    mCompanyOrgIdentNumber:= AContext.GetCompanyCache.OrgIdentNumber;
    if cLicensedOrgIdentNumber = mCompanyOrgIdentNumber then
      Result:= True
    else
      Result:= False;
  finally
    //mContext.Free;
  end;
end;


begin
end.