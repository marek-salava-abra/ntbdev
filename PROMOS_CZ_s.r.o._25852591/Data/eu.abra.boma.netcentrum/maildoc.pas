uses 'eu.abra.boma.netcentrum.consts';

procedure BOD_SendMail_NetCentrum_dep(var Self: TNxHeaderBusinessObject);
var
  i: Integer;
  mRO, mBOD: TNxCustomBusinessObject;
  mROIDs: TStringList;
  mOID: String;
  mCon: TNxContext;
begin
  if (Self.GetFieldValueAsString('Firm_ID')=cFirm_ID) then begin
    mROIDs:=TStringList.Create;
    try
      for i:=0 to Self.Rows.Count -1 do begin
       mOID:=Self.Rows.BusinessObject[i].GetFieldValueAsString('Provide_ID');
        if mROIDs.IndexOf(mOID)= -1 then
          if not(NxIsEmptyOID(mOID)) then
            mROIDs.Append(mOID);
      end;
      mCon:=NxCreateContext_1(Self);
      try
        for i:=0 to mROIDs.Count -1 do begin
          mRO:=Self.ObjectSpace.CreateObject('01CPMINJW3DL342X01C0CX3FCC'); //OP
          try
            mRO.Load(mROIDs[i],nil);
            if Self.GetFieldValueAsBoolean('X_PredanoPP') then begin
              if mRO.GetFieldValueAsInteger('X_WEB_Stav_Dokladu')<4 then begin
                mRO.SetFieldValueAsInteger('X_WEB_Stav_Dokladu',4);
                CreateAndSendByINI_dep(mCon, Self, 4, mOID, mRO.GetFieldValueAsString('X_WEB_Email'));
              end;
            end;
            if (mRO.GetFieldValueAsInteger('X_WEB_Stav_Dokladu')=2) and (Self.GetFieldValueAsInteger('U_SendMail')=1) then begin
              if not(CreateAndSendByINI_dep(mCon, Self, 2, mOID, mRO.GetFieldValueAsString('X_WEB_Email'))) then
                Self.SetFieldValueAsString('U_SendMail_Note',mOID);
            end;
            if mRO.NeedSave then mRO.Save;
          finally
            mRO.Free;
          end;
        end;
      finally
        mCon.Free;
      end;
    finally
      mROIDs.Free;
    end;
  end;
end;

procedure II_SendMail_NetCentrum_dep(var Self: TNxHeaderBusinessObject);
var
  i: Integer;
  mRO,mRowBO: TNxCustomBusinessObject;
  mROIDs, mRowBOs: TStringList;
  mOID, mMailAddress: String;
  mCon: TNxContext;
begin
  mRowBOs:=TStringList.Create;
  mROIDs:=TStringList.Create;
  try
    for i:=0 to Self.Rows.Count -1 do begin
     mOID:=Self.Rows.BusinessObject[i].GetFieldValueAsString('ProvideRow_ID');
      if mRowBOs.IndexOf(mOID)= -1 then
        if not(NxIsEmptyOID(mOID)) then
          mRowBOs.Append(mOID);
    end;
    for i:=0 to mRowBOs.Count -1 do begin
      mRowBO:=Self.ObjectSpace.CreateObject('0H0I5SAOS3DL3ACU03KIU0CLP4'); //řádek DL
      try
        mRowBO.Load(mRowBOs[i],nil);
        mOID:=mRowBO.GetFieldValueAsString('Provide_ID');
        if mROIDs.IndexOf(mOID)= -1 then
          if not(NxIsEmptyOID(mOID)) then
            mROIDs.Append(mOID);
      finally
        mRowBO.Free;
      end;
    end;
    for i:=0 to mROIDs.Count -1 do begin
      mRO:=Self.ObjectSpace.CreateObject('01CPMINJW3DL342X01C0CX3FCC'); //OP
      try
        mRO.Load(mROIDs[i],nil);
        if mRO.GetFieldValueAsInteger('X_WEB_Stav_Dokladu')<3 then begin
          if mRO.GetFieldValueAsString('Firm_ID')=cFirm_ID then begin
            mCon:=NxCreateContext_1(Self);
            try
              if not(CreateAndSendByINI_DEP(mCon, Self, 3, mOID, mRO.GetFieldValueAsString('X_WEB_Email')))
                then Self.SetFieldValueAsString('X_SendMail_Note',mOID);
            finally
              mCon.Free;
            end;
            mRO.SetFieldValueAsInteger('X_WEB_Stav_Dokladu',3);
          end;
        end;
        if mRO.NeedSave then mRO.Save;
      finally
        mRO.Free;
      end;
    end;
  finally
    mRowBOs.Free;
    mROIDs.Free;
  end;
end;

procedure SendZL(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
  mLogStr, mFileList, mMailList, mAdresy: TStringList;
  i,j, mIndex, mCurrentShop: Integer;
  mMailStr, mShopStr: String;
  mMail,mRecipients: TNxCustomBusinessObject;
  mMonRec, mMonAtt: TNxCustomBusinessMonikerCollection;
  mBody, mSubject: TStringList;
  mParams: TStringList;
  mSkip: Boolean;
begin
  Success := True;
  LogInfoStr := '';
  PreFillEmailAccounts;
  mLogStr:=TStringList.Create;
  try
    try
      for mCurrentShop:=1 to cShopsCount do begin
        mSkip:=False;
        mShopStr:=getShopStrFromCounter(mCurrentShop);
        mFileList:=TStringList.Create;
        try
          NxGetFileList(NxAddSlash(cZalohaPath)+mShopStr, mFileList, '*.pdf');
          mLogStr.Add('Zpracování souborů z adresáře ' + NxAddSlash(cZalohaPath)+mShopStr);
          mLogStr.Add(NxReplicate('-',Length(NxAddSlash(cZalohaPath)+mShopStr) + Length('Zpracování souborů z adresáře ')));
          mLogStr.Add('');
          if mFileList.Count = 0 then begin
            mLogStr.Add('Nebyly nalezeny žádné XML soubory pro import. KONEC.');
          end else begin
            mLogStr.Add('Byly nalezeny celkem ' + IntToStr(mFileList.Count) + ' soubory ke zpracování.');
            mLogStr.Add('');
            mMailList:=TStringList.Create;
            mMailList.LoadFromFile(NxAddSlash(NxAddSlash(cZalohaPath)+mShopStr)+'ZLmail.txt');
            try
              for i := 0 to mFileList.Count - 1 do begin
                try
                  //mLogStr.Append(mFileList[i]);
                  mIndex:=mMailList.IndexOfName(mFileList[i]);
                  if mIndex > -1 then begin
                    mSubject:=TStringList.Create;
                    mBody:=TStringList.Create;
                    mParams:=TStringList.Create;
                    try
                      if FileExists(NxAddSlash(cMailPath)+'ZL'+'-Subject_'+mShopStr+'.txt') then
                        mSubject.LoadFromFile(NxAddSlash(cMailPath)+'ZL'+'-Subject_'+mShopStr+'.txt')
                      else
                        if FileExists(NxAddSlash(cMailPath)+'ZL'+'-Subject.txt') then
                          mSubject.LoadFromFile(NxAddSlash(cMailPath)+'ZL'+'-Subject.txt');
                      if mSubject.Count>0 then begin
                        for j:=0 to mSubject.Count -1 do begin
                          mSubject[j]:=NxSearchReplace(mSubject[j],'%DisplayName',mFileList[i],[srAll]);
                          mSubject[j]:=NxSearchReplace(mSubject[j],'%DateTime',FormatDateTime('dd.mm.yyyy hh:nn',Now),[srAll]);
                          mSubject[j]:=NxSearchReplace(mSubject[j],'%Date',FormatDateTime('dd.mm.yyyy',Now),[srAll]);
                        end;
                      end else RaiseException('Nenalezena definice pro Subject (Předmět).');
                      //
                      if FileExists(NxAddSlash(cMailPath)+'ZL'+'-Body_'+mShopStr+'.txt') then
                        mBody.LoadFromFile(NxAddSlash(cMailPath)+'ZL'+'-Body_'+mShopStr+'.txt')
                      else
                        if FileExists(NxAddSlash(cMailPath)+'ZL'+'-Body.txt') then
                          mBody.LoadFromFile(NxAddSlash(cMailPath)+'ZL'+'-Body.txt');
                      if mBody.Count>0 then begin
                        NxTrapStrToStrings(mBody[0],';',mParams);
                        mBody.Delete(0);
                        for j:=0 to mBody.Count -1 do begin
                          mBody[j]:=NxSearchReplace(mBody[j],'%DisplayName',mFileList[i],[srAll]);
                          mBody[j]:=NxSearchReplace(mBody[j],'%DateTime',FormatDateTime('dd.mm.yyyy hh:nn',Now),[srAll]);
                          mBody[j]:=NxSearchReplace(mBody[j],'%Date',FormatDateTime('dd.mm.yyyy',Now),[srAll]);
                          mBody[j]:=NxSearchReplace(mBody[j],'%WWW',getCurrentShopWWW(OS,mCurrentShop),[srAll]);
                        end;
                      end else RaiseException('Nenalezena definice pro Obsah emailu.');
                      mMailStr:=NxExtractQuotedString(mMailList.ValueFromIndex[mIndex],'''');

                      mMail:=OS.CreateObject('5C1HWDQDR3J4NAAYZRO5PWHLWK'); //odeslaný mail
                      try
                        mMail.New;
                        mMail.Prefill;
                        mMail.SetFieldValueAsString('EmailAccount_ID',cEmailAccount_ID[mCurrentShop]);
                        mMail.SetFieldValueAsString('Firm_ID',cFirm_ID);
                        j:=mParams.IndexOfName('HTML');
                        if j>=0 then
                          if mParams.ValueFromIndex(j)='A' then
                            mMail.SetFieldValueAsInteger('BodySavedAs',1)
                          else
                            mMail.SetFieldValueAsInteger('BodySavedAs',0);
                        mMail.SetFieldValueAsString('Body',mBody.Text);
                        mMail.SetFieldValueAsString('Subject',mSubject[0]);
                        mMonRec:=mMail.GetLoadedCollectionMonikerForFieldCode(mMail.GetFieldCode('Recipients'));

                        mAdresy:=TStringList.Create;
                        try
                          NxTrapStrToStrings(mMailStr,';',mAdresy);
                          //if not(isAuto) and not(mSend) then mSend:=True;
                          for j:=0 to mAdresy.Count -1 do begin
                            if NxIsValidEMail(mAdresy[j],False) then begin
                              mRecipients:=mMonRec.AddNewObject;
                              mRecipients.Prefill;
                              mRecipients.SetFieldValueAsInteger('EmailType',0);
                              mRecipients.SetFieldValueAsString('Email',mAdresy[j]);
                            end;
                          end;
                        finally
                          mAdresy.Free;
                        end;

                        if mMonRec.Count > 0 then begin
                          TNxEmailSent(mMail).AttachFile(NxAddSlash(NxAddSlash(cZalohaPath)+mShopStr)+mFileList[i]);
                          mMail.SetFieldValueAsInteger('SentState',1);
                          mMail.Save;
                          mLogStr.Append(Format('Úspěšně odeslán mail %s dokladu %s.',[mMail.DisplayName,mFileList[i]]));
                          if FileExists(NxAddSlash(NxAddSlash(cZalohaPath)+mShopStr)+mFileList[i]) then
                            DeleteFile(NxAddSlash(NxAddSlash(cZalohaPath)+mShopStr)+mFileList[i]);
                        end;
                      finally
                        mMail.Free;
                      end;
                    finally
                      mSubject.Free;
                      mBody.Free;
                      mParams.Free;
                    end;
                  end else RaiseException('Nebyl dohledán email! Toto nesmí nastat. - ' + mFileList[i]);
                except
                  mLogStr.Append(ExceptionMessage);
                  Success:=False;
                end;
              end;
            finally
              mMailList.Free;
            end;
          end;
        finally
          mFileList.Free;
        end;
      end;
      CheckForStorno(OS,Success,mLogStr);
    except
      mLogStr.Append(ExceptionMessage);
      Success:=False;
    end;
  finally
    LogInfoStr:=mLogStr.Text;
    mLogStr.Free;
  end;
end;

procedure CheckForStorno(OS: TNxCustomObjectSpace; var Success: Boolean; var mLogStr: TStringList);
const
  cSQL='Select ID From ReceivedOrders where DocQueue_ID=''%s'' and Closed=''N'' and X_Stav_Dokladu in (2,3)';
var
  i,j,k: integer;
  mResults: TStringList;
  mRO, mRez, mRow: TNxCustomBusinessObject;
begin
  Success := True;
  try
    mResults:=TStringList.Create;
    try
      for i:=0 to mResults.Count -1 do begin
        mRO:=Os.CreateObject('01CPMINJW3DL342X01C0CX3FCC');
        try
          mRO.Load(mResults[i],nil);
          for j:=0 to mRO.GetLoadedCollectionMonikerForFieldCode(mRO.GetFieldCode('Rows')).Count -1 do begin
            mRow:=mRO.GetLoadedCollectionMonikerForFieldCode(mRO.GetFieldCode('Rows')).BusinessObject[j];
            mRez:=mRow.GetMonikerForFieldCode(mRow.GetFieldCode('Reservation_ID')).BusinessObject;
            if (CompareDateTime(Today,mRez.GetFieldValueAsDateTime('DateTo$DATE'))=1) and
                (mRez.GetFieldValueAsFloat('UnitReserved')>0) then begin
              mRO.SetFieldValueAsInteger('X_Stav_dokladu',4);
              mLogStr.Append('Doklad ' + mRO.DisplayName + ' byl Stornován z důvodu vypršení rezervace');
              break;
            end;
          end;
          if mRO.NeedSave then mRO.Save;
        finally
          mRO.Free;
        end;
      end;
    finally
      mResults.Free;
    end;
  except
    mLogStr.Append(ExceptionMessage);
    Success:=False;
  end;
end;

Function CreateAndSendByINI_DEP(mContext:TNxContext; var mCo: TNxcustomBusinessObject; Atype: Integer; var mErr: String; aMailAddress: String): Boolean;
// AType: 1 - Nová objednávka, 2 - Zpracovává se, 3 - Vyřízeno, 4 - Expedováno, 5 - Storno
var
  mINI: TCustomIniFile;
  mMail: TNxCustomBusinessObject;
  mResult, mValues, mAdresy: TStrings;
  mFirm, mRecipients, mAttachments, mContent, mBlob, mRow: TNxcustomBusinessObject;
  mMonRec, mMonAtt: TNxCustomBusinessMonikerCollection;
  i,j, mCurrentShop: Integer;
  mStav, mSQL, mSestava, mOZ, mS, mText, mOrigText, mShopStr: String;
  mGuid, mCLSID, mReport, mDynSource, mCurrencyCode, mSubject: String;
  mSend: Boolean;
  mErrs, mBody: TStringList;
  mParams: TStringList;
begin
  mSend:=true;
  Result:=True;
  PreFillEmailAccounts;
  mErrs:=TStringList.Create;
  try
    case Atype of
     1: begin
          mReport:='Firm_ID.X_ReportRO_ID';
          mDynSource:='40V53DORW3DL342X01C0CX3FCC';
        end;
     2: begin
          mReport:='Firm_ID.X_ReportBO_ID';
          mDynSource:='LCGT3EI1EXO4REH0DNRLOANM2O'; //DL - EAN
        end;
     3: begin
          mReport:='Firm_ID.X_Report_ID';
          mDynSource:='RZWOW4Z2N4CO5BX224LAAH1BKW'; //FV - EAN
        end;
     4: begin
          mReport:='Firm_ID.X_ReportPR_ID';
          mDynSource:='LCGT3EI1EXO4REH0DNRLOANM2O'; //DL - EAN
        end;
     5: begin
          mReport:='Firm_ID.X_ReportRO_ID';
          mDynSource:='40V53DORW3DL342X01C0CX3FCC';
        end;
     else RaiseException('Chybně zadaný AType');
    end;
    mShopStr:=TNxHeaderBusinessObject(mCo).Rows.FirstBusinessObject.GetFieldValueAsString('BusOrder_ID.X_Zkratka');
    mCurrencyCode:=TNxHeaderBusinessObject(mCo).Rows.FirstBusinessObject.GetFieldValueAsString('BusOrder_ID.X_Currency_ID.Code');
    mCurrentShop:=getCurrentShopFromStr(mShopStr);
    mParams:=TStringList.Create;
    mBody:=TStringList.Create;
    try
      mSend:=True;
      //Předmět
      mINI:=TIniFile.Create(NxAddSlash(cMailPath)+IntToStr(Atype)+'-subject.ini');
      try
        if mINI.SectionExists(mShopStr) then mSubject:=mINI.ReadString(mShopStr,'Subject','')
        else mSubject:=mINI.ReadString(mCurrencyCode,'Subject','');
        mSubject:=NxSearchReplace(mSubject,'%DisplayName',mCo.DisplayName,[srAll]);
        if (Atype=1) or (Atype=5) then
          mSubject:=NxSearchReplace(mSubject,'%ExternalNumber',mCo.GetFieldValueAsString('ExternalNumber'),[srAll]);
        if not((Atype=1) or (Atype=5)) then
          mSubject:=NxSearchReplace(mSubject,'%ExternalNumber',mCo.GetFieldValueAsString('X_ExternalNumber'),[srAll]);
        mSubject:=NxSearchReplace(mSubject,'%DateTime',FormatDateTime('dd.mm.yyyy hh:nn',Now),[srAll]);
        mSubject:=NxSearchReplace(mSubject,'%Date',FormatDateTime('dd.mm.yyyy',Now),[srAll]);
        mSubject:=NxSearchReplace(mSubject,'%RONumber',getRONumber2(mCO),[srAll]);
      finally
        mINI.Free;
      end;

      //
      if FileExists(NxAddSlash(cMailPath)+IntToStr(Atype)+'-Body_'+mShopStr+'.txt') then mBody.LoadFromFile(NxAddSlash(cMailPath)+IntToStr(Atype)+'-Body_'+mShopStr+'.txt')
      else mBody.LoadFromFile(NxAddSlash(cMailPath)+IntToStr(Atype)+'-Body_'+mCurrencyCode+'.txt');
      if mBody.Count > 0 then begin
        NxTrapStrToStrings(mBody[0],';',mParams);
        mBody.Delete(0);
        for i:=0 to mBody.Count -1 do begin
          mBody[i]:=NxSearchReplace(mBody[i],'%DisplayName',mCo.DisplayName,[srAll]);
          mBody[i]:=NxSearchReplace(mBody[i],'%WWW',TNxHeaderBusinessObject(mCo).Rows.FirstBusinessObject.GetFieldValueAsString('BusOrder_ID.Name'),[srAll]);
          mBody[i]:=NxSearchReplace(mBody[i],'%DateTime',FormatDateTime('dd.mm.yyyy hh:nn',Now),[srAll]);
          mBody[i]:=NxSearchReplace(mBody[i],'%Date',FormatDateTime('dd.mm.yyyy',Now),[srAll]);
          mBody[i]:=NxSearchReplace(mBody[i],'%RONumber',getRONumber2(mCO),[srAll]);
          if (Atype=1) or (Atype=5) then
            mBody[i]:=NxSearchReplace(mBody[i],'%ExternalNumber',mCo.GetFieldValueAsString('ExternalNumber'),[srAll]);
          if not((Atype=1) or (Atype=5)) then
            mBody[i]:=NxSearchReplace(mBody[i],'%ExternalNumber',mCo.GetFieldValueAsString('X_ExternalNumber'),[srAll]);
          mBody[i]:=NxSearchReplace(mBody[i],'%ROTotalPrice',FloatToStrF(mCo.GetFieldValueAsFloat('Amount'),ffNumber,15,2) + ' ' + mCurrencyCode,[srAll]);
        end;
        for i:=1 to mBody.Count -1 do begin
          if (NxSearch(mBody[i],'%Packages;',[srWord],0)<>0) and (Atype=4) then begin
            mOrigText:=Copy(mBody[i],11,Length(mBody[i]));
            mBody.Delete(i);
            mAdresy:=TStringList.Create;
            try
              mAdresy.Text:=mCo.GetFieldValueAsString('U_Packages');
              for j:=0 to mAdresy.Count -1 do begin
                mText:=mOrigText;
                mText:=NxSearchReplace(mText,'%PackCode',mAdresy[j],[srAll]);
                mBody.Insert(i,mText);
                Inc(i);
              end;
            finally
              mAdresy.Free;
            end;
            Inc(i,-1);
          end;
        {end;
        for i:=1 to mBody.Count -1 do begin}
          if NxSearch(mBody[i],'%Row3;',[srWord],0)<>0 then begin
            mOrigText:=Copy(mBody[i],7,Length(mBody[i]));
            mBody.Delete(i);
            for j:=0 to TNxHeaderBusinessObject(mCo).Rows.Count -1 do begin
              mRow:=TNxHeaderBusinessObject(mCo).Rows.BusinessObject[j];
              mText:=mOrigText;
              if mRow.GetFieldValueAsInteger('RowType')=3 then begin
                mText:=NxSearchReplace(mText,'%Code',mRow.GetFieldValueAsString('StoreCard_ID.Code'),[srAll]);
                mText:=NxSearchReplace(mText,'%Name',mRow.GetFieldValueAsString('StoreCard_ID.Name'),[srAll]);
                mText:=NxSearchReplace(mText,'%Quantity',FloatToStrF(mRow.GetFieldValueAsFloat('Quantity'),ffNumber,15,0),[srAll]);
                mText:=NxSearchReplace(mText,'%TotalPrice',FloatToStrF(mRow.GetFieldValueAsFloat('TotalPrice'),ffNumber,15,2) + ' ' + mCurrencyCode,[srAll]);
                mText:=NxSearchReplace(mText,'%UnitPrice',FloatToStrF(mRow.GetFieldValueAsFloat('UnitPrice'),ffNumber,15,2) + ' ' + mCurrencyCode,[srAll]);
                mBody.Insert(i,mText);
                Inc(i);
              end;
            end;
            Inc(i,-1);
          end;
        {end;
        for i:=1 to mBody.Count -1 do begin}
          if NxSearch(mBody[i],'%Row1;',[srWord],0)<>0 then begin
            mOrigText:=Copy(mBody[i],7,Length(mBody[i]));
            mBody.Delete(i);
            for j:=0 to TNxHeaderBusinessObject(mCo).Rows.Count -1 do begin
              mRow:=TNxHeaderBusinessObject(mCo).Rows.BusinessObject[j];
              mText:=mOrigText;
              if mRow.GetFieldValueAsInteger('RowType')=1 then begin
                mText:=NxSearchReplace(mText,'%TotalPrice',FloatToStrF(mRow.GetFieldValueAsFloat('TotalPrice'),ffNumber,15,2) + ' ' + mCurrencyCode,[srAll]);
                mText:=NxSearchReplace(mText,'%Text',mRow.GetFieldValueAsString('Text'),[srAll]);
                mBody.Insert(i,mText);
                Inc(i);
              end;
            end;
            Inc(i,-1);
          end;
        end;
      end else RaiseException('Nenalezena definice pro Body (Tělo emailu).');

      if (Atype=2) or (Atype=4) then
        mErrs.Text:=mCo.GetFieldValueAsString('U_SendMail_Note')
      else
        mErrs.Text:=mCo.GetFieldValueAsString('X_SendMail_Note');
      mErrs.Append(FormatDateTime('dd.mm.yyyy hh:nn:ss',Now));

      mMail:=mCo.ObjectSpace.CreateObject('5C1HWDQDR3J4NAAYZRO5PWHLWK'); //odeslaný mail
      try
        mMail.New;
        mMail.Prefill;
        mMail.SetFieldValueAsString('EmailAccount_ID',cEmailAccount_ID[mCurrentShop]);
        mMail.CopyFieldValuesFrom_1(mCo,['Firm_ID','FirmOffice_ID','Person_ID'],True);
        i:=mParams.IndexOfName('HTML');
        if i>=0 then
          if mParams.ValueFromIndex(i)='A' then
            mMail.SetFieldValueAsInteger('BodySavedAs',1)
          else
            mMail.SetFieldValueAsInteger('BodySavedAs',0);
        mMail.SetFieldValueAsString('Body',mBody.Text);
        mMail.SetFieldValueAsString('Subject',mSubject);
        mMonRec:=mMail.GetLoadedCollectionMonikerForFieldCode(mMail.GetFieldCode('Recipients'));

        mAdresy:=TStringList.Create;
        try
          NxTrapStrToStrings(aMailAddress,';',mAdresy);
          //if not(isAuto) and not(mSend) then mSend:=True;
          for j:=0 to mAdresy.Count -1 do begin
            if NxIsValidEMail(mAdresy[j],False) then begin
              mRecipients:=mMonRec.AddNewObject;
              mRecipients.Prefill;
              mRecipients.SetFieldValueAsInteger('EmailType',0);
              mRecipients.SetFieldValueAsString('Email',mAdresy[j]);
            end;
          end;
          mErrs.AddStrings(mAdresy);
        finally
          mAdresy.Free;
        end;

        if mMonRec.Count = 0 then begin
          mSend:=False;
          mErrs.Append('Nepodařilo se získat platnou e-mailovou adresu');
          if (Atype=2) or (Atype=4) then begin
            mCo.SetFieldValueAsInteger('U_SendMail',3);
            mCo.SetFieldValueAsString('U_SendMail_Note',mErrs.Text);
          end else begin
            mCo.SetFieldValueAsInteger('X_SendMail',3);
            mCo.SetFieldValueAsString('X_SendMail_Note',mErrs.Text);
          end;
          //mCo.Save;
        end;

        if mSend then begin
          i:=mParams.IndexOfName('Attachment');
          if i>=0 then
            if mParams.ValueFromIndex(i)='A' then begin
              i:=mParams.IndexOfName('Report_ID');
              if i>=0 then
                mSestava:=mParams.ValueFromIndex(i)
              else
                mSestava:=mCo.GetFieldValueAsString(mReport);
              If not(NxIsEmptyOID(mSestava)) then begin
                mValues:=TStringList.Create;
                try
                  mValues.Append(mCO.OID);
                  CFxReportManager.PrintByIDs(mContext, mValues, mDynSource, mSestava, rtoFile, pekPDF,cMailPath,NxSearchReplace(mCo.DisplayName,'/','-',[srAll]) + '.pdf');
                  TNxEmailSent(mMail).AttachFile(NxAddSlash(cMailPath)+NxSearchReplace(mCo.DisplayName,'/','-',[srAll]) + '.pdf');
                finally
                  mValues.Free
                end;
              end else RaiseException('Nebyla dohledána tisková sestava');
            end;

          mMail.SetFieldValueAsInteger('SentState',1);
          mMail.Save;
          mErrs.Append(Format('Úspěšně odeslán mail %s dokladu %s.',[mMail.DisplayName,mCo.DisplayName]));
          if (Atype=2) or (Atype=4) then begin
            mCo.SetFieldValueAsInteger('U_SendMail',2);
            mCo.SetFieldValueAsString('U_SendMail_Note',mErrs.Text);
          end else begin
            mCo.SetFieldValueAsInteger('X_SendMail',2);
            mCo.SetFieldValueAsString('X_SendMail_Note',mErrs.Text);
          end;

          //mCo.Save;
          if FileExists(NxAddSlash(cMailPath)+NxSearchReplace(mCo.DisplayName,'/','-',[srAll]) + '.pdf') then
            DeleteFile(NxAddSlash(cMailPath)+NxSearchReplace(mCo.DisplayName,'/','-',[srAll]) + '.pdf');
        end;
      finally
        mMail.Free;
      end;
      //if OS.InTransaction then OS.Commit;
    finally
      mParams.Free;
      mBody.Free;
    end;
    mErr:=mErrs.Text;
    //if mShowMemo then mMemo.Lines.AddStrings(mErrs);
    mErrs.Free;
  except
    //if OS.InTransaction then OS.RollBack;
    mErrs.Append(Format('Chyba při odesílání emailu: %s',[ExceptionMessage]));
    mErr:=mErrs.Text;
    //if mShowMemo then mMemo.Lines.AddStrings(mErrs);
    mErrs.Free;
    Result:=False;
  end;
end;

Function CreateAndSend(mContext:TNxContext; var mCo: TNxcustomBusinessObject; Atype: Integer; var mErr: String; aMailAddress: String): Boolean;
// AType: 1 - Nová objednávka, 2 - Zpracovává se, 3 - Vyřízeno, 4 - Expedováno, 5 - Storno
var
  mMail: TNxCustomBusinessObject;
  mResult, mValues, mAdresy: TStrings;
  mFirm, mRecipients, mAttachments, mContent, mBlob, mRow: TNxcustomBusinessObject;
  mMonRec, mMonAtt: TNxCustomBusinessMonikerCollection;
  i,j, mCurrentShop: Integer;
  mStav, mSQL, mSestava, mOZ, mS, mText, mOrigText, mShopStr: String;
  mGuid, mCLSID, mReport, mDynSource: String;
  mSend: Boolean;
  mErrs, mBody, mSubject: TStringList;
  mParams: TStringList;
begin
  mSend:=true;
  Result:=True;
  PreFillEmailAccounts;
  mErrs:=TStringList.Create;
  try
    case Atype of
     1: begin
          mReport:='Firm_ID.X_ReportRO_ID';
          mDynSource:='40V53DORW3DL342X01C0CX3FCC';
        end;
     2: begin
          mReport:='Firm_ID.X_ReportBO_ID';
          mDynSource:='LCGT3EI1EXO4REH0DNRLOANM2O'; //DL - EAN
        end;
     3: begin
          mReport:='Firm_ID.X_Report_ID';
          mDynSource:='RZWOW4Z2N4CO5BX224LAAH1BKW'; //FV - EAN
        end;
     4: begin
          mReport:='Firm_ID.X_ReportPR_ID';
          mDynSource:='LCGT3EI1EXO4REH0DNRLOANM2O'; //DL - EAN
        end;
     5: begin
          mReport:='Firm_ID.X_ReportRO_ID';
          mDynSource:='40V53DORW3DL342X01C0CX3FCC';
        end;
     else RaiseException('Chybně zadaný AType');
    end;
    mShopStr:=TNxHeaderBusinessObject(mCo).Rows.FirstBusinessObject.GetFieldValueAsString('BusOrder_ID.X_Zkratka');
    mCurrentShop:=getCurrentShopFromStr(mShopStr);
    mParams:=TStringList.Create;
    mSubject:=TStringList.Create;
    mBody:=TStringList.Create;
    try
      mSend:=True;
      //Předmět
      if FileExists(NxAddSlash(cMailPath)+IntToStr(Atype)+'-Subject.txt') then begin
        mSubject.LoadFromFile(NxAddSlash(cMailPath)+IntToStr(Atype)+'-Subject.txt');
        for i:=0 to mSubject.Count -1 do begin
          mSubject[i]:=NxSearchReplace(mSubject[i],'%DisplayName',mCo.DisplayName,[srAll]);
          if (Atype=1) or (Atype=5) then
            mSubject[i]:=NxSearchReplace(mSubject[i],'%ExternalNumber',mCo.GetFieldValueAsString('ExternalNumber'),[srAll]);
          if not((Atype=1) or (Atype=5)) then
            mSubject[i]:=NxSearchReplace(mSubject[i],'%ExternalNumber',mCo.GetFieldValueAsString('X_ExternalNumber'),[srAll]);
          mSubject[i]:=NxSearchReplace(mSubject[i],'%DateTime',FormatDateTime('dd.mm.yyyy hh:nn',Now),[srAll]);
          mSubject[i]:=NxSearchReplace(mSubject[i],'%Date',FormatDateTime('dd.mm.yyyy',Now),[srAll]);
        end;
      end else RaiseException('Nenalezena definice pro Subject (Předmět).');
      //
      if FileExists(NxAddSlash(cMailPath)+IntToStr(Atype)+'-Body.txt') then begin
        mBody.LoadFromFile(NxAddSlash(cMailPath)+IntToStr(Atype)+'-Body.txt');
        NxTrapStrToStrings(mBody[0],';',mParams);
        mBody.Delete(0);
        for i:=0 to mBody.Count -1 do begin
          mBody[i]:=NxSearchReplace(mBody[i],'%DisplayName',mCo.DisplayName,[srAll]);
          mBody[i]:=NxSearchReplace(mBody[i],'%WWW',TNxHeaderBusinessObject(mCo).Rows.FirstBusinessObject.GetFieldValueAsString('BusOrder_ID.Name'),[srAll]);
          mBody[i]:=NxSearchReplace(mBody[i],'%DateTime',FormatDateTime('dd.mm.yyyy hh:nn',Now),[srAll]);
          mBody[i]:=NxSearchReplace(mBody[i],'%Date',FormatDateTime('dd.mm.yyyy',Now),[srAll]);
          if (Atype=1) or (Atype=5) then
            mBody[i]:=NxSearchReplace(mBody[i],'%ExternalNumber',mCo.GetFieldValueAsString('ExternalNumber'),[srAll]);
          if not((Atype=1) or (Atype=5)) then
            mBody[i]:=NxSearchReplace(mBody[i],'%ExternalNumber',mCo.GetFieldValueAsString('X_ExternalNumber'),[srAll]);
          mBody[i]:=NxSearchReplace(mBody[i],'%ROTotalPrice',FloatToStrF(mCo.GetFieldValueAsFloat('LocalAmount'),ffCurrency,15,2),[srAll]);
        end;
        for i:=1 to mBody.Count -1 do begin
          if (NxSearch(mBody[i],'%Packages;',[srWord],0)<>0) and (Atype=4) then begin
            mOrigText:=Copy(mBody[i],11,Length(mBody[i]));
            mBody.Delete(i);
            mAdresy:=TStringList.Create;
            try
              mAdresy.Text:=mCo.GetFieldValueAsString('U_Packages');
              for j:=0 to mAdresy.Count -1 do begin
                mText:=mOrigText;
                mText:=NxSearchReplace(mText,'%PackCode',mAdresy[j],[srAll]);
                mBody.Insert(i,mText);
                Inc(i);
              end;
            finally
              mAdresy.Free;
            end;
            Inc(i,-1);
          end;
        {end;
        for i:=1 to mBody.Count -1 do begin}
          if NxSearch(mBody[i],'%Row3;',[srWord],0)<>0 then begin
            mOrigText:=Copy(mBody[i],7,Length(mBody[i]));
            mBody.Delete(i);
            for j:=0 to TNxHeaderBusinessObject(mCo).Rows.Count -1 do begin
              mRow:=TNxHeaderBusinessObject(mCo).Rows.BusinessObject[j];
              mText:=mOrigText;
              if mRow.GetFieldValueAsInteger('RowType')=3 then begin
                mText:=NxSearchReplace(mText,'%Code',mRow.GetFieldValueAsString('StoreCard_ID.Code'),[srAll]);
                mText:=NxSearchReplace(mText,'%Name',mRow.GetFieldValueAsString('StoreCard_ID.Name'),[srAll]);
                mText:=NxSearchReplace(mText,'%Quantity',FloatToStrF(mRow.GetFieldValueAsFloat('Quantity'),ffNumber,15,0),[srAll]);
                mText:=NxSearchReplace(mText,'%TotalPrice',FloatToStrF(mRow.GetFieldValueAsFloat('TotalPrice'),ffCurrency,15,2),[srAll]);
                mText:=NxSearchReplace(mText,'%UnitPrice',FloatToStrF(mRow.GetFieldValueAsFloat('UnitPrice'),ffCurrency,15,2),[srAll]);
                mBody.Insert(i,mText);
                Inc(i);
              end;
            end;
            Inc(i,-1);
          end;
        {end;
        for i:=1 to mBody.Count -1 do begin}
          if NxSearch(mBody[i],'%Row1;',[srWord],0)<>0 then begin
            mOrigText:=Copy(mBody[i],7,Length(mBody[i]));
            mBody.Delete(i);
            for j:=0 to TNxHeaderBusinessObject(mCo).Rows.Count -1 do begin
              mRow:=TNxHeaderBusinessObject(mCo).Rows.BusinessObject[j];
              mText:=mOrigText;
              if mRow.GetFieldValueAsInteger('RowType')=1 then begin
                mText:=NxSearchReplace(mText,'%TotalPrice',FloatToStrF(mRow.GetFieldValueAsFloat('TotalPrice'),ffCurrency,15,2),[srAll]);
                mText:=NxSearchReplace(mText,'%Text',mRow.GetFieldValueAsString('Text'),[srAll]);
                mBody.Insert(i,mText);
                Inc(i);
              end;
            end;
            Inc(i,-1);
          end;
        end;
      end else RaiseException('Nenalezena definice pro Subject (Předmět).');
      
      if (Atype=2) or (Atype=4) then
        mErrs.Text:=mCo.GetFieldValueAsString('U_SendMail_Note')
      else
        mErrs.Text:=mCo.GetFieldValueAsString('X_SendMail_Note');
      mErrs.Append(FormatDateTime('dd.mm.yyyy hh:nn:ss',Now));

      mMail:=mCo.ObjectSpace.CreateObject('5C1HWDQDR3J4NAAYZRO5PWHLWK'); //odeslaný mail
      try
        mMail.New;
        mMail.Prefill;
        mMail.SetFieldValueAsString('EmailAccount_ID',cEmailAccount_ID[mCurrentShop]);
        mMail.CopyFieldValuesFrom_1(mCo,['Firm_ID','FirmOffice_ID','Person_ID'],True);
        i:=mParams.IndexOfName('HTML');
        if i>=0 then
          if mParams.ValueFromIndex(i)='A' then
            mMail.SetFieldValueAsInteger('BodySavedAs',1)
          else
            mMail.SetFieldValueAsInteger('BodySavedAs',0);
        mMail.SetFieldValueAsString('Body',mBody.Text);
        mMail.SetFieldValueAsString('Subject',mSubject.Text);
        mMonRec:=mMail.GetLoadedCollectionMonikerForFieldCode(mMail.GetFieldCode('Recipients'));

        mAdresy:=TStringList.Create;
        try
          NxTrapStrToStrings(aMailAddress,';',mAdresy);
          //if not(isAuto) and not(mSend) then mSend:=True;
          for j:=0 to mAdresy.Count -1 do begin
            if NxIsValidEMail(mAdresy[j],False) then begin
              mRecipients:=mMonRec.AddNewObject;
              mRecipients.Prefill;
              mRecipients.SetFieldValueAsInteger('EmailType',0);
              mRecipients.SetFieldValueAsString('Email',mAdresy[j]);
            end;
          end;
          mErrs.AddStrings(mAdresy);
        finally
          mAdresy.Free;
        end;

        if mMonRec.Count = 0 then begin
          mSend:=False;
          mErrs.Append('Nepodařilo se získat platnou e-mailovou adresu');
          if (Atype=2) or (Atype=4) then begin
            mCo.SetFieldValueAsInteger('U_SendMail',3);
            mCo.SetFieldValueAsString('U_SendMail_Note',mErrs.Text);
          end else begin
            mCo.SetFieldValueAsInteger('X_SendMail',3);
            mCo.SetFieldValueAsString('X_SendMail_Note',mErrs.Text);
          end;
          //mCo.Save;
        end;

        if mSend then begin
          i:=mParams.IndexOfName('Attachment');
          if i>=0 then
            if mParams.ValueFromIndex(i)='A' then begin
              i:=mParams.IndexOfName('Report_ID');
              if i>=0 then
                mSestava:=mParams.ValueFromIndex(i)
              else
                mSestava:=mCo.GetFieldValueAsString(mReport);
              If not(NxIsEmptyOID(mSestava)) then begin
                mValues:=TStringList.Create;
                try
                  mValues.Append(mCO.OID);
                  CFxReportManager.PrintByIDs(mContext, mValues, mDynSource, mSestava, rtoFile, pekPDF,cMailPath,NxSearchReplace(mCo.DisplayName,'/','-',[srAll]) + '.pdf');
                  TNxEmailSent(mMail).AttachFile(NxAddSlash(cMailPath)+NxSearchReplace(mCo.DisplayName,'/','-',[srAll]) + '.pdf');
                finally
                  mValues.Free
                end;
              end else RaiseException('Nebyla dohledána tisková sestava');
            end;
            
          mMail.SetFieldValueAsInteger('SentState',1);
          mMail.Save;
          mErrs.Append(Format('Úspěšně odeslán mail %s dokladu %s.',[mMail.DisplayName,mCo.DisplayName]));
          if (Atype=2) or (Atype=4) then begin
            mCo.SetFieldValueAsInteger('U_SendMail',2);
            mCo.SetFieldValueAsString('U_SendMail_Note',mErrs.Text);
          end else begin
            mCo.SetFieldValueAsInteger('X_SendMail',2);
            mCo.SetFieldValueAsString('X_SendMail_Note',mErrs.Text);
          end;

          //mCo.Save;
          if FileExists(NxAddSlash(cMailPath)+NxSearchReplace(mCo.DisplayName,'/','-',[srAll]) + '.pdf') then
            DeleteFile(NxAddSlash(cMailPath)+NxSearchReplace(mCo.DisplayName,'/','-',[srAll]) + '.pdf');
        end;
      finally
        mMail.Free;
      end;
      //if OS.InTransaction then OS.Commit;
    finally
      mParams.Free;
      mSubject.Free;
      mBody.Free;
    end;
    mErr:=mErrs.Text;
    //if mShowMemo then mMemo.Lines.AddStrings(mErrs);
    mErrs.Free;
  except
    //if OS.InTransaction then OS.RollBack;
    mErrs.Append(Format('Chyba při odesílání emailu: %s',[ExceptionMessage]));
    mErr:=mErrs.Text;
    //if mShowMemo then mMemo.Lines.AddStrings(mErrs);
    mErrs.Free;
    Result:=False;
  end;
end;

begin
end.