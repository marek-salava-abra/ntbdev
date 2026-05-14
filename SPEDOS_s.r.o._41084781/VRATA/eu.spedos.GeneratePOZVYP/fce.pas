function ElementExist(mXMLHead : TNxScriptingXMLWrapper; AName: string): Boolean;

begin
  try
    if mXMLHead.getElementAsString(AName)<>'' then Result:= True;
  except
   Result:= False;
  end;
end;

function GetBusOrder_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT ID FROM BusOrders WHERE Code=''%s'' and hidden=''N''  ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:='';
  finally
    mList.Free;
  end;
end;

function GetStoreCard_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT ID FROM StoreCards WHERE Code=''%s'' and hidden=''N''  ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:='';
  finally
    mList.Free;
  end;
end;

function GetSN(AOS : TNxCustomObjectSpace; aVyrCislo : string; mOrder:integer;) : string;

var
  mPrefix,mSuffix:string;
begin
  Result:=aVyrCislo;
  if mOrder>0 then begin
    mPrefix:=NxToken(aVyrCislo,'-');
    mSuffix:=NxToken(aVyrCislo,'-');
    Result:=mPrefix+'-'+AnsiRightStr('0000'+ IntToStr(StrToInt(mSuffix)+mOrder),4);
  end;
end;

function GetIDV(AOS : TNxCustomObjectSpace; aIDV : string; mOrder:integer;) : string;

var
  mPrefix,mSuffix:string;
begin
  mPrefix:=AnsiLeftStr(aIDV,1);
  mSuffix:=AnsiRightStr(aIDV,7);
  Result:=mPrefix+AnsiRightStr('0000000'+ IntToStr(StrToInt(mSuffix)+mOrder),7);
end;

function GetDivision_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT ID FROM Divisions WHERE Code=''%s'' and hidden=''N''  ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:='';
  finally
    mList.Free;
  end;
end;

function GetOBDVRow_ID(AOS : TNxCustomObjectSpace; aStoreCard_ID, aBusOrder_ID, aPozice_ID : string) : string;
const
  cSQL = 'SELECT ID FROM ReceivedOrders2 WHERE StoreCard_ID=''%s'' and BusOrder_ID=''%s'' and X_Pozice_OD=''%s''  ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aStoreCard_ID, aBusOrder_ID, aPozice_ID]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:='';
  finally
    mList.Free;
  end;
end;

function GetPosition_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT ID FROM defrolldata WHERE Code=''%s'' and clsid=''QGK21PXOQRT4ZEPWEBIC0KFCDO'' and hidden=''N''  ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:='';
  finally
    mList.Free;
  end;
end;

function GetCountSerial(AOS : TNxCustomObjectSpace; aCode : string) : Integer;
const
  cSQL = 'SELECT * FROM PLMProduceRequests A WHERE (exists (SELECT 1 FROM USERDATA WHERE FIELDCODE=2000001 AND CLSID=''IVJSI1K34CJORFG1QBJOMTSVAG'' AND ID = A.ID AND (Upper(STRINGFIELDVALUE Collate UTF8) LIKE ''%s'' ESCAPE ''~'')))';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Count
      else Result:=0;
  finally
    mList.Free;
  end;
end;

function GetSerialOD (AOS: TNxCustomObjectSpace; aID_Montaz_vyrobky:string): string;
var
 mJSON: TJSONSuperObject;
 mWinHTTP: Variant;
begin
             mJSON:= TJSONSuperObject.CreateNew;
             if not(NxIsBlank(aID_Montaz_vyrobky)) then begin
             mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
             mWinHTTP.Open('GET','https://sod.spedos.cz/api/api.abra-get-vyrobek.php?ID_montaz_vyrobky='+aID_Montaz_vyrobky);
             mWinHTTP.SetRequestHeader('Authorization','Basic YUJyYTpza1M4Zi1zeFI=');
             mWinHTTP.Send();
             mJSON:= TJSONSuperObject.CreateNew;
             mJSON := TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
             //NxShowSimpleMessage(mJSON.AsString,nil);
             Result:=mJSON.S['vyrobni_cislo'];
     end;
end;

function GetIDVyrobkuOD (AOS: TNxCustomObjectSpace; aVyrobniCislo:string): string;
var
 mJSON: TJSONSuperObject;
 mWinHTTP: Variant;
begin
             mJSON:= TJSONSuperObject.CreateNew;
             if not(NxIsBlank(aVyrobniCislo)) then begin
             mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
             mWinHTTP.Open('GET','https://sod.spedos.cz/api/api.abra-get-vyrobek.php?vyrobni_cislo='+aVyrobniCislo);
             mWinHTTP.SetRequestHeader('Authorization','Basic YUJyYTpza1M4Zi1zeFI=');
             mWinHTTP.Send();
             mJSON:= TJSONSuperObject.CreateNew;
             mJSON := TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
             //NxShowSimpleMessage(mJSON.AsString,nil);
             Result:=mJSON.S['ID_montaz_vyrobky'];
     end;
end;

procedure SplitString(var Input: string; var Part1, Part2: string);
var
  ColonPos: Integer;
begin
  ColonPos := Pos('@', Input); // Nalezení pozice
  if ColonPos > 0 then
  begin
    // Extrahování části před
    Part1 := Copy(Input, 1, ColonPos - 1);
    // Extrahování části za
    Part2 := Copy(Input, ColonPos + 1, Length(Input) - ColonPos);
  end
  else
  begin
    // Pokud dvojtečka není nalezena, obě části zůstávají prázdné
    Part1 := '';
    Part2 := '';
  end;
end;

function GetNewSerial(AOS : TNxCustomObjectSpace; aCode, OPPozice_ID : string) : string;
const
  cSQL = 'SELECT name FROM defrolldata WHERE Code=''%s'' and X_OP_Pozice=''%s'' and clsid=''XNAVPBFTCRO4BBYJZ2FN14T51O'' and hidden=''N''  ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode, OPPozice_ID]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:='';
  finally
    mList.Free;
  end;
end;

function GetPhase_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT ID FROM plmphases WHERE Code=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:='1100000101';
  finally
    mList.Free;
  end;
end;

function GetWorkPlace_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT ID FROM plmworkplaces WHERE Code=''%s'' and hidden=''N''  ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:='';
  finally
    mList.Free;
  end;
end;

function GetOrder_ID(AOS : TNxCustomObjectSpace; ApoziceOD, aStoreCard_ID : string) : string;
const
  cSQL = 'SELECT Parent_ID FROM ReceivedOrders2 WHERE X_Pozice_OD=''%s'' and StoreCard_ID=''%s''  ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [ApoziceOD, aStoreCard_ID]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:='';
  finally
    mList.Free;
  end;
end;

function GetFirm_ID(AOS : TNxCustomObjectSpace; ApoziceOD, aStoreCard_ID : string) : string;
const
  cSQL = 'SELECT ro.Firm_ID FROM ReceivedOrders ro left join receivedorders2 ro2 on ro.id=ro2.parent_id WHERE ro2.X_Pozice_OD=''%s'' and ro2.StoreCard_ID=''%s''  ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [ApoziceOD, aStoreCard_ID]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:='';
  finally
    mList.Free;
  end;
end;

function GetStore_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT ID FROM Stores WHERE Code=''%s'' and hidden=''N''  ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:='';
  finally
    mList.Free;
  end;
end;

function GetBT_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT ID FROM BusTransactions WHERE Code=''%s'' and hidden=''N'' and closed=''N''  ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:='';
  finally
    mList.Free;
  end;
end;


function GetPeriodID(AOS: TNxCustomObjectSpace; ADate: TDate): string;
var
  mSQL: string;
  mStr: TStrings;
begin
  result := '0000000000';
  mSQL := Format('SELECT RPeriod_ID FROM GetFirstPeriodByDates(%s, %s, %s)', [FloatToStr(Date), FloatToStr(Date), QuotedStr('0000000000')]);
  mStr := TStringList.Create;
  try
    AOS.SQLSelect(mSQL, mStr);
    if mStr.Count > 0 then
      result := mStr.Strings[0];
  finally
    mStr.Free;
  end;
end;

function CreateJobOrder(AOS: TNxCustomObjectSpace; AID: string): string;
var
  mOleApp: Variant;
  mGenReqObject: Variant;
  mDts: TDataset;
  mSQL, mPeriod_ID: string;

begin
  result := '';

  //nejprve si nagenerujeme požadavek - normy
  mOLEApp := GetAbraOLEApplication;
  mGenReqObject := mOleApp.CreateObject('@PLMProduceRequest');

  //vytvoření VYP
if true then begin
    mSQL := Format('Select P1.DocQueueForJO_ID, P1.TariffForJO_ID, P2.DocQueueForAWT_ID, P2.AccPresetDef_ID ' +
      ' from PLMPQParams P1 JOIN PLMJOSetParsQueues P2 ON P2.DocQueue_ID=P1.DocQueueForJO_ID where P1.DocQueue_ID=' +
      ' (Select max(DocQueue_ID) from PLMProduceRequests where id=%s)', [QuotedStr(AID)]);
    mDts := TMemoryDataset.Create(nil);
    try
      AOS.SQLSelect2(mSQL, mDts);
      if mDts.Active then begin
        mPeriod_ID := GetPeriodID(AOS, Date);
        mGenReqObject := mOleApp.CreateObject('@PLMProduceRequest');
        if mGenReqObject.GenerateJobOrder2(AID, mDts.FieldByName('DocQueueForJO_ID').AsString,
          mPeriod_ID, mDts.FieldByName('TariffForJO_ID').AsString, mDts.FieldByName('DocQueueForAWT_ID').AsString,
          mDts.FieldByName('AccPresetDef_ID').AsString) then
          result := mGenReqObject.Evaluate(AID, 'JobOrder_ID');
      end;
    finally
      mDts.free;
      mOleApp := nil;
      mGenReqObject := nil;
    end;
  end;
end;


function CreateJobOrder2(AOS: TNxCustomObjectSpace; AID: string): string;
var
  mOleApp: Variant;
  mGenReqObject: Variant;
  mDts: TDataset;
  mSQL, mPeriod_ID: string;
  aWarning, aError:string;
  mObject:TNxCustomBusinessObject;
  mHeaderObject:TNxHeaderBusinessObject;
begin
  result := '';
  mObject:=aOS.CreateObject(Class_PLMProduceRequest);
  mObject.Load(AID,nil);
  mHeaderObject:=TNxHeaderBusinessObject(mObject);
  //vytvoření VYP
if true then begin
    mSQL := Format('Select P1.DocQueueForJO_ID, P1.TariffForJO_ID, P2.DocQueueForAWT_ID, P2.AccPresetDef_ID ' +
      ' from PLMPQParams P1 JOIN PLMJOSetParsQueues P2 ON P2.DocQueue_ID=P1.DocQueueForJO_ID where P1.DocQueue_ID=' +
      ' (Select max(DocQueue_ID) from PLMProduceRequests where id=%s)', [QuotedStr(AID)]);
    mDts := TMemoryDataset.Create(nil);
    try
      AOS.SQLSelect2(mSQL, mDts);
      if mDts.Active then begin
        mPeriod_ID := GetPeriodID(AOS, Date);
        //mGenReqObject := mOleApp.CreateObject('@PLMProduceRequest');
          TNxPLMProduceRequest(mHeaderObject).GenerateJobOrder(mDts.FieldByName('DocQueueForJO_ID').AsString,
          mPeriod_ID, mDts.FieldByName('TariffForJO_ID').AsString, mDts.FieldByName('DocQueueForAWT_ID').AsString,
          mDts.FieldByName('AccPresetDef_ID').AsString,aWarning,aError);
          result := mHeaderObject.GetFieldValueAsString('JobOrder_ID');
      end;
    finally
      mDts.free;
      mOleApp := nil;
      mGenReqObject := nil;
    end;
  end;
end;

function GetAmount(AOS : TNxCustomObjectSpace; aOID : string) : Extended;
const
  cSQL = 'SELECT sum(TAmount) FROM ReceivedOrders2 WHERE Parent_ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aOID]), mList);
    if mList.Count > 0 then
      Result := NxIBStrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;

function GetLocalAmount(AOS : TNxCustomObjectSpace; aOID : string) : Extended;
const
  cSQL = 'SELECT sum(LocalTAmount) FROM ReceivedOrders2 WHERE Parent_ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aOID]), mList);
    if mList.Count > 0 then
      Result := NxIBStrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;

function GetAmountWithoutVAT(AOS : TNxCustomObjectSpace; aOID : string) : Extended;
const
  cSQL = 'SELECT sum(TAmountWithoutVAT) FROM ReceivedOrders2 WHERE Parent_ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aOID]), mList);
    if mList.Count > 0 then
      Result := NxIBStrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;

function GetLocalAmountWithoutVAT(AOS : TNxCustomObjectSpace; aOID : string) : Extended;
const
  cSQL = 'SELECT sum(LocalTAmountWithoutVAT) FROM ReceivedOrders2 WHERE Parent_ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aOID]), mList);
    if mList.Count > 0 then
      Result := NxIBStrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;

procedure SendInternalMail(AOS:TNxCustomObjectSpace; ATo:String; ACC:String; ASubject:String; ABody:String; AAtachement, aAtachement2:String; AFirm_ID:String; ADivision_ID:String; ABusOrder_ID:String; AReplyTo:string;);
Var
  mMailBO:TNxCustomBusinessObject;
  mMRecipients:TNxCustomBusinessMonikerCollection;
  mMailRecipient:TNxCustomBusinessObject;
begin
  if not(ato='') then begin
     mMailBO:=AOS.CreateObject('5C1HWDQDR3J4NAAYZRO5PWHLWK');
     mMailBO.New;
     mMailBO.Prefill;
     mMailBO.SetFieldValueAsString('EmailAccount_ID','2100000101');
     mMailBO.SetFieldValueAsString('Subject',ASubject);
     mMailbo.SetFieldValueAsInteger('SentState',1);
     mMailBO.SetFieldValueAsInteger('BodySavedAs',1);
     mMailBO.SetFieldValueAsString('Body',ABody);
     mMailBO.SetFieldValueAsString('Firm_ID',AFirm_ID);
     if not(NxIsEmptyOID(ADivision_ID))then mMailBO.SetFieldValueAsString('Division_ID',ADivision_ID);
     mMailBO.SetFieldValueAsString('BusOrder_ID',ABusOrder_ID);
     mMailBO.SetFieldValueAsString('ReplyTo',AReplyTo);
     mMRecipients:=mMailBO.GetCollectionMonikerForFieldCode(mMailBO.GetFieldCode('Recipients'));

     mMailRecipient:=mMRecipients.AddNewObject;
     mMailRecipient.SetFieldValueAsString('Email',ATo);
     mMailRecipient.SetFieldValueAsInteger('EmailType',0);
     if not(acc='') then begin
     mMailRecipient:=mMRecipients.AddNewObject;
     mMailRecipient.SetFieldValueAsString('Email',ACC);
     mMailRecipient.SetFieldValueAsInteger('EmailType',1);
     end;
     if not(AAtachement='') then begin
      if FileExists(AAtachement) then TNxEmailSent(mMailBO).AttachFile(AAtachement);

     end;
     if not(AAtachement2='') then begin
      if FileExists(AAtachement2) then TNxEmailSent(mMailBO).AttachFile(AAtachement2);

     end;




     mMailBO.Save;
     mMailBO.free;

  end;
end;


begin
end.