uses 'eu.abra.boma.netcentrum.common';

function CheckFor01(OS: TNxCustomObjectSpace; LogStr: TStringList): Boolean;
const cPath = '\\abraserver\SolidniObchod\Zalohy';
var
  mList: TStringList;
  i: Integer;
  mBO: TNxCustomBusinessObject;
  mZLOID: TNxOID;

  procedure addLog(aLog: String);
  begin
    LogStr.Add(CFxDateTime.DateTimeToISO8601(Now) + '(CheckFor01): ' + aLog);
  end;
begin
  Result := True;
  try
    if FileExists(NxAddSlash(cPath)+'ListOf01.tsl') then
    begin
      mList := TStringList.Create;
      try
        mList.LoadFromFile(NxAddSlash(cPath)+'ListOf01.tsl');
        for i := mList.Count -1 downto 0 do
        begin
          mBO := OS.CreateObject(Class_IssuedDepositInvoice);
          try
            mZLOID := mList[i];
            if mBO.Test(mZLOID) then
            begin
              mBO.Load(mZLOID, nil);
              mBO.SetFieldValueAsInteger('X_WEB_STAV_DOKLADU',2);
              mBO.Save;
              mList.Delete(i);
            end else begin
              addLog(format('Err - %s v G4 neexistuje!',[mList[i]]));
              mList.Delete(i);
              Result := False;
            end;
          finally
            mBO.Free;
          end;
        end;
      finally
        mList.SaveToFile(NxAddSlash(cPath)+'ListOf01.tsl')
      end;
    end;
  except
    Result := False;
    addLog('Err - ' + ExceptionMessage);
  end;
end;

procedure  ImportOrdersB2C(OS: TNxCustomObjectSpace;  var Success: Boolean; var LogInfoStr: String);
const
  cDynSource = 'S4STXJVRM3DL35J301C0CX3F40';
  cReportCZK_ID = '3R00000201';
  cReportEUR_ID = '3R00000201';
var
  mOID: string;
  mFileList: TStrings;
  i, j, mCurrentShop: Integer;
  mXML: Variant;
  mShopStr: String;
  mObj: TNxCustomBusinessObject;
  mObjectSpace: TNxCustomObjectSpace;
  mSite: TSiteForm;
  mInfoList,mErrs: TStringList;
  mSave: Boolean;
  mDocManager: TNxDocumentImportManager;
  mParams: TNxParameters;
  mCintext: TNxContext;
  mIDS, mEmails: TStringList;
  mReport_ID, mFilename: String;
begin
  Success := True;
  LogInfoStr := '';
  //mExeDir := cSourcePath;
  //mOldDir := GetConstAsString('cXWPostImportPath');
  mInfoList := TStringList.Create;
  mFileList := TStringList.Create;
  mErrs := TStringList.Create;
  try
    mObjectSpace := OS;
    try
      //synchro s G3
      Success := CheckFor01(OS,mInfoList);
      //staré importy
      NxGetFileList(cSourcePath, mFileList, '*.XML');
      mInfoList.Add('Zpracování souborů z adresáře ' + cSourcePath);
      mInfoList.Add(NxReplicate('-',Length(cSourcePath) + Length('Zpracování souborů z adresáře ')));
      mInfoList.Add('');
      if mFileList.Count = 0 then begin
        mInfoList.Add('Nebyly nalezeny žádné XML soubory pro import. KONEC.');
        LogInfoStr:=mInfoList.Text;
        Exit;
      end;
      mInfoList.Add('Byly nalezeny celkem ' + IntToStr(mFileList.Count) + ' soubory ke zpracování.');
      mInfoList.Add('');

      for i := 0 to mFileList.Count - 1 do begin
        mErrs.Clear;
        mInfoList.Add('-- ' + IntToStr(i+1) + '/' + IntToStr(mFileList.Count) + ' ---');
        mInfoList.Add('');
        mInfoList.Add('Zpracování souboru ' + mFileList[i] + ' ...');
        mXML := CreateOLEObject('Msxml2.DOMDocument');
        mXML.load(NxAddSlash(cSourcePath) + mFileList[i]);
        mObj := mObjectSpace.CreateObject(Class_ReceivedOrder); //Objednávka přijatá
        try
          mOID:=ImportOrder(mObjectSpace, mXML, mErrs, mSave);
          if mSave then mObj.Load(mOID,nil);
          //mObj := CreateBO_IIFromXML(mXML, mOLE, mPars, mOS, True, mInfoList, mFileList[i]);
          mInfoList.Add('Ukládání Objednávky přijaté ...');
          //For j:=0 to mErrs.Count -2 do
          if mErrs.Count>0 then
            mInfoList.AddStrings(mErrs);
          //mObj.Save;
          mInfoList.Add(' ');
          If mSave then begin
            //mObj.Save;
            mShopStr:=TNxHeaderBusinessObject(mObj).Rows.FirstBusinessObject.GetFieldValueAsString('BusOrder_ID.X_Zkratka');
            mInfoList.Add('--> Uložen doklad ' + mObj.DisplayName + ' <--');
            {if mObj.GetFieldValueAsString('PaymentType_ID')=cPlatbaZalohy then begin
              if TNxHeaderBusinessObject(mObj).Rows.FirstBusinessObject.GetFieldValueAsBoolean('BusOrder_ID.X_ISSolight') then begin
                // jdeme vytvořit zálohový list
                mDocManager:=NxCreateDocumentImportManager(OS,Class_ReceivedOrder,Class_IssuedDepositInvoice);
                try
                  mParams:=TNxParameters.Create;
                  try
                    mDocManager.SaveParams(mParams);
                    mParams.ParamByName('DocQueue_ID').AsString:='B000000201';
                    mDocManager.LoadParams(mParams);
                  finally
                    mParams.Free;
                  end;
                  mDocManager.AddInputDocument(mObj.OID);
                  mDocManager.SelectedHeader:=mObj;
                  mDocManager.Execute;
                  mDocManager.OutputDocument.Save;
                  mInfoList.Add('--> Uložen ZLV ' + mDocManager.OutputDocument.DisplayName + ' <--');
                  if NxIsValidEMail(mObj.GetFieldValueAsString('X_WEB_Email'),False) then begin
                    try
                      if mObj.GetFieldValueAsString('Currency_ID')='0000CZK000' then mReport_ID:=cReportCZK_ID
                      else mReport_ID:=cReportEUR_ID;
                      try
                        mIDS:=TStringList.Create;
                        mIDS.Append(mDocManager.OutputDocument.OID);
                        mCintext:=NxCreateContext(OS);
                        mFilename:=StringReplace(mDocManager.OutputDocument.DisplayName,'/','-',[srAll]) + '.pdf';
                        CFxReportManager.PrintByIDs(mCintext,mIDS,cDynSource,mReport_ID,rtoFile,pekPDF,NxAddSlash(cZalohaPath)+mShopStr,mFilename);
                        try
                          mEmails:=TStringList.Create;
                          mEmails.LoadFromFile(NxAddSlash(NxAddSlash(cZalohaPath)+mShopStr)+'ZLmail.txt');
                          mEmails.Insert(0,mFilename+'='+QuotedStr(mObj.GetFieldValueAsString('X_WEB_Email')));
                          mEmails.SaveToFile(NxAddSlash(NxAddSlash(cZalohaPath)+mShopStr)+'ZLmail.txt');
                        finally
                          mEmails.Free;
                        end;
                      finally
                        mIDS.Free;
                      end;
                    except
                      mInfoList.Append('Nepodařilo se vytisknout zálohový list.');
                      mInfoList.Append(ExceptionMessage);
                      Success:=False;
                    end;
                  end else begin
                    mInfoList.Add('Chybný email, mail nebude se ZL nebude poslán!');
                    Success:=False;
                  end;
                finally
                  mDocManager.Free;
                end;
                if not(RenameFile(NxAddSlash(cSourcePath) + mFileList[i], NxAddSlash(Format(cDonePath,[mShopStr])) + mFileList[i])) then begin
                  mInfoList.Add(Format('Nepodařilo se přesunout soubor %s do adresáře %s!',[mFileList[i],Format(cDonePath,[mShopStr])]));
                  Success:=False;
                end;
              end else begin
                if not(RenameFile(NxAddSlash(cSourcePath) + mFileList[i], NxAddSlash(NxAddSlash(cZalohaPath)+mShopStr) + mFileList[i])) then begin
                  mInfoList.Add(Format('Nepodařilo se přesunout soubor %s do adresáře %s!',[mFileList[i],NxAddSlash(cZalohaPath)]));
                  Success:=False;
                end;
              end;
            end else begin}
              if not(RenameFile(NxAddSlash(cSourcePath) + mFileList[i], NxAddSlash(Format(cDonePath,[mShopStr])) + mFileList[i])) then begin
                mInfoList.Add(Format('Nepodařilo se přesunout soubor %s do adresáře %s!',[mFileList[i],Format(cDonePath,[mShopStr])]));
                Success:=False;
              end;
            //end;
          end else begin
            mInfoList.Add('--> Neuloženo, zkontrolujte chybové hlášení.  <--');
            Success:=False;
          end;
          mInfoList.Add('');
        finally
          mObj.Free;
        end;
      end;
      LogInfoStr:=mInfoList.Text;
    except
      LogInfoStr:=LogInfoStr + #13#10 + ExceptionMessage;
      Success := False;
    end;
  finally
    mFileList.Free;
    mInfoList.Free;
    mErrs.Free;
  end;
end;

begin
end.