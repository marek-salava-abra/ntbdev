procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actSendAPISimon';
  mAction.Caption := '## Pošle do SIMON##';
  mAction.Hint := 'Odešle karty do Simonu označené položky';
  mAction.Category := 'tabList';
  mAction.OnExecute := @SendOverAPI2Simon;
end;

Procedure SendOverAPI2Simon(sender:TComponent);
var
 mSite:TSiteForm;
 mList:TStringList;
 i,j,k,l,m,n:integer;
 mOS:TNxCustomObjectSpace;
 mSCJSON, mSUJSON, mPicJSON, mResultJSON:TJSONSuperObject;
 mBO, mUnitBO, mPictureBO, mSCPictureBO, mTempPictureBO:TNxCustomBusinessObject;
 mUnits, mPictures:TNxCustomBusinessMonikerCollection;
 mPrice:Extended;
 mPicturePath:string;
begin
 mSite:=TComponent(sender).BusRollSite;
 mOS:=mSite.BaseObjectSpace;
 mList:=TStringList.Create;
 TBusRollSiteForm(mSite).List.GetSelectedId(mList);
 if mlist.Count>0 then begin
   if NxMessageBox('Dotaz','Přejete si odeslat '+IntToStr(mList.count)+' karet do Simon?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
     n:=mList.Count;
     k:=0;
     l:=0;
     m:=0;
     WaitWin.StartProgress('Čekejte, prosím ...', '',  n);
     mBO:=mOS.CreateObject(Class_StoreCard);
     for i:=0 to mlist.count-1 do begin
      mBO.Load(mlist.strings[i],nil);
      mSCJSON:=TJSONSuperObject.Create;
      mPrice:=mOS.SQLSelectFirstAsExtended( 'SELECT first 1 '#13#10 +
                                          '    sp2.Amount'#13#10 +
                                          'FROM PriceListValidities plv'#13#10 +
                                          'JOIN StorePrices sp '#13#10 +
                                          '    ON sp.PriceListValidity_ID = plv.ID'#13#10 +
                                          'JOIN StorePrices2 sp2 '#13#10 +
                                          '    ON sp2.Parent_ID = sp.ID'#13#10 +
                                          'WHERE plv.Parent_ID = ''1000000101'''#13#10 +
                                          '  AND sp.StoreCard_ID = '+QuotedStr(mbo.oid)+' '#13#10 +
                                          '  AND sp2.Price_ID = ''1000000101'''#13#10 +
                                          '  AND plv.ValidFromDate$Date <= (CURRENT_DATE - DATE ''1899-12-30'') + 1 '#13#10 +
                                          'ORDER BY plv.ValidFromDate$Date DESC',0);
      mSCJSON.S['Code']:=mBO.GetFieldValueAsString('Code');
      mSCJSON.S['Name']:=mBO.GetFieldValueAsString('Name');
      mSCJSON.S['MainUnitCode']:=mBO.GetFieldValueAsString('MainUnitcode');
      mSCJSON.S['VATRate_ID']:=mBO.GetFieldValueAsString('VATRate_ID');
      mSCJSON.S['Note']:=mBO.GetFieldValueAsString('Note');
      mSCJSON.O['Pictures']:=mSCJSON.CreateJSONArray;
      mPictures:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Pictures'));
       for j:=0 to mPictures.count-1 do begin
          mSCPictureBO:=mPictures.BusinessObject[j];
          mPictureBO:=mOS.CreateObject(Class_Picture);
          mPictureBO.Load(mSCPictureBO.GetFieldValueAsString('Picture_ID'),nil);
          mTempPictureBO:=mOS.CreateObject(Class_Picture);
          mTempPictureBO.new;
          mTempPictureBO.Prefill;
          mTempPictureBO.SetFieldValueAsString('PictureTitle','#'+mPictureBO.GetFieldValueAsString('PictureTitle'));
          mTempPictureBO.SetFieldValueAsBoolean('ExternalFile',False);
          mTempPictureBO.SetFieldValueAsString('PathAndFileName',mPictureBO.GetFieldValueAsString('PathAndFileName'));
          mTempPictureBO.save;
          mPicJSON:=TJSONSuperObject.Create;
          mPicJSON.S['name'] := mPictureBO.GetFieldValueAsString('PictureTitle');
          mPicJSON.B['isExternal'] := mPictureBO.GetFieldValueAsBoolean('ExternalFile');
          mPicJSON.S['PathAndFileName'] := mPictureBO.GetFieldValueAsString('PathAndFileName');
          mPicJSON.S['type'] := mPictureBO.GetFieldValueAsString('PictureType');
          mPicJSON.S['base64Data'] := decodePicture(loadPictureAndSaveToFile(mTempPictureBO.GetFieldValueAsBytes('BlobData')));
          mSCJSON.A['Pictures'].Add(mPicJSON);
          mTempPictureBO.delete;
        end;
       mUnits:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('StoreUnits'));
       mSCJSON.O['StoreUnits']:=mSCJSON.CreateJSONArray;
       for j:=0 to mUnits.count-1 do begin
         mUnitBO:=mUnits.BusinessObject[j];
         mSUJSON:=TJSONSuperObject.Create;
         mSUJSON.S['Code']:=mUnitBO.GetFieldValueAsString('Code');
         mSUJSON.D['Depth']:=mUnitBO.GetFieldValueAsFloat('Depth');
         mSUJSON.D['Height']:=mUnitBO.GetFieldValueAsFloat('Height');
         mSUJSON.D['Width']:=mUnitBO.GetFieldValueAsFloat('Width');
         mSUJSON.I['SizeUnit']:=mUnitBO.GetFieldValueAsInteger('SizeUnit');
         if not(AnsiLeftStr(mUnitBO.GetFieldValueAsString('EAN'),3)='200') then mSUJSON.S['EAN']:=mUnitBO.GetFieldValueAsString('EAN');
         if mUnitBO.GetFieldValueAsInteger('WeightUnit')=0 then begin
          mSUJSON.D['Weight']:=mUnitBO.GetFieldValueAsFloat('Weight')/1000;
          mSUJSON.I['WeightUnit']:= 1;
         end else begin
          mSUJSON.D['Weight']:=mUnitBO.GetFieldValueAsFloat('Weight');
          mSUJSON.I['WeightUnit']:= mUnitBO.GetFieldValueAsInteger('WeightUnit');
         end;
         mSCJSON.A['StoreUnits'].Add(mSUJSON);
       end;
      //mSCJSON.SaveToFile('C:\AbraGen\temp.json');
      mResultJSON:= API_POST(mSCJSON,'https://api.simonfm.cz/SimonFM/script/eu.abra.masa.API_IN/lib/StoreCards');
      k:=k+ mResultJSON.I['Found'];
      l:=l+ mResultJSON.I['NotFound'];
      m:=m+ mResultJSON.I['Err'];
      WaitWin.ChangeText(IntToStr(i) + ' / ' + IntToStr(n));
      WaitWin.StepIt;
     end;
     WaitWin.Stop;
     NxShowSimpleMessage('Celkem odesláno:  '+IntToStr(mList.count)+#13#10+
                         'Opraveno:         '+IntToStr(k)+#13#10+
                         'Vytvořeno:        '+IntToStr(l)+#13#10+
                         'Chyba:            '+IntToStr(m),mSite);
   end;
 end;
end;


function loadPictureAndSaveToFile(aBlobData: TBytes): String;
var
  mPicture: TPicture;
  mStream: TMemoryStream;
begin
  mStream := TMemoryStream.Create;
  mPicture := TPicture.Create;
  try
    NxCreateTempFile(Result);
    OutputDebugString(Result);
    mStream.SetBytes(aBlobData);
    mPicture.LoadMultiFormatFromStream(mStream);
    mPicture.SaveToFile(Result);
  finally
    mPicture.Free;
    mStream.Free;
  end;
end;

function decodePicture(aFileName: String): String;
var
  mStream: TMemoryStream;
begin
  mStream := TMemoryStream.Create;
  try
    mStream.LoadFromFile(aFileName);
    Result := EncodeBase64(mStream.GetBytes);
    DeleteFile(aFileName);
  finally
    mStream.Free;
  end;
end;

function API_POST(aJSON:TJSONSuperObject;aURL:string):TJSONSuperObject;
var
 mWinHTTP:Variant;
begin
  try
   mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
   mWinHTTP.Open('POST', aURL);
   mWinHTTP.SetRequestHeader('Content-Type', 'application/json');
   mWinHTTP.SetRequestHeader('Authorization','Basic UHJvbW9zOnByb21vcw==');
   mWinHTTP.Send(aJSON.AsJson);
   if mWinHTTP.status='200' then begin
     Result:=TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
   end else begin
     Result:=TJSONSuperObject.create;
     Result.S['status']:='error';
     Result.I['Found']:=0;
     Result.I['NotFound']:=0;
     Result.I['Err']:=1;
   end;
  except
   Result:=TJSONSuperObject.create;
   Result.S['status']:='error';
   Result.I['Found']:=0;
   Result.I['NotFound']:=0;
   Result.I['Err']:=1;
  end;
end;

begin
end.