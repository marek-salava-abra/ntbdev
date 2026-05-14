const
  cRequest = 'TAKE: CRED:';
  cEndRequest = '(WA/RESTApplication/ProfilingRequest) Request stop:';
  cURL = 'Request start:';
  cScript = ' {';
  cException = '(ExceptionHook) Message:';

procedure InitSite_Hook(Self: TSiteForm);

  //mSiteForm: TForm;


begin
  AddButton(Self,true,true,'APILogParser', 'Vyčte z logu jen potřebné řádky a převede do XML', 'tabList', @LogParser);

end;


procedure LogParser(Sender:TComponent);
var
  mList, mLog, mResult : TStringList;
  i,j,o, mLast, mHeader, mPos,mCountBracket : integer;
  mXML : TNxScriptingXMLWrapper;
  mTime, mURL, mHost, mLogin, mBody, mStatus,mResultStr, mMethod, mTimeStr, mDateStr,mRequestID, mPartXMLPath ,mXMLPath, mFileName, mPart: string;
  mTempStr, mDatabase,mExceptionMessage: string;
  mscript, mbreak :boolean ;
  mStartDate, mEndDate: TDateTime;
  mMemory: TMemoryStream;
begin
  mMemory:= TMemoryStream.Create;

  mFileName := '';
  if PromptForFileName(mFileName, '*.*','*.*','Log','',false, Sender.Site) then
  try
    mList := TStringList.Create();
    mResult := TStringList.Create;
    mResult.Add('StartTime;RID;URL;Time;Method;Status;Error;Database;Login;Body;StartLine;EndLine');
    //mMemory.LoadFromFile(mFileName);
    //mMemory.GetBytes
    //mList.LoadFromStream
    mList.LoadFromFile(mFileName, TEncoding.UTF8);

   i := 0;
   WaitWin.SetMax(mList.Count-1);
   WaitWin.StartProgress('Zpracování logu','Načtení souboru',mList.Count - 1);
    while i < mList.Count - 1 do
    begin
      WaitWin.StepIt;
      if NxAt(cRequest,mList[i]) > 0 then
      begin
      // next step
        mLogin:= '';
        mDatabase:= '';
        mMethod:= '';
        mURL:= '';
        mStatus:= '';
        mTime:= '';

        mRequestID:= Copy(mList[i], NxSearch(mList[i],'rid:',[srall],0)+4,36);
        mPos:= NxSearch(mList[i],'CRED:',[srall],0);
        mTempStr:= Copy(mList[i], mPos+6,NxSearch(mList[i],'rid:',[srall],0));
        mDatabase:= NxToken(mTempStr, ';');
        mLogin:= NxToken(mTempStr, ';');


        //OutputDebugString('mDatabase: ' +mDatabase);
        //OutputDebugString('mTempStr: ' +mTempStr);
        //OutputDebugString('mPOS: ' +inttostr(mPOS));
        //OutputDebugString('mRequestID: ' +mRequestID);
        //OutputDebugString('mLogin: ' +mLogin);


        j := i;
        mLast := 0 ;
        while (j < mList.Count - 1) and (mLast = 0)  do
        begin
          if (NxAt(cURL,mList[j]) > 0) and (Copy(mList[j], NxSearch(mList[j],'rid:',[srall],0)+4,36) = mRequestID) then mHeader:= j;
          if (NxAt(cEndRequest,mList[j]) > 0) and (Copy(mList[j], NxSearch(mList[j],'rid:',[srall],0)+4,36) = mRequestID) then mLast := j;
          if (mHeader > 0) and (mLast>0 )
            then break;
          j := j + 1;
        end;



        if mLast > 0 then
        begin
          // vyčtení dat z hlavičky
          mPos:= NxSearch(mList[mHeader],'Request start:',[srall],0);
          mTempStr:= Copy(mList[mHeader], mPos+15, NxSearch(mList[mHeader],'rid:',[srall],0) -  (mPos+15));
          mMethod:= NxToken(mTempStr, ' ');
          mURL:= mTempStr;

          //vyčtení dat z konečného řádku
          mPos:= NxSearch(mList[mLast],'Request stop:',[srall],0);
          mTempStr:= Copy(mList[mLast], mPos+21,NxSearch(mList[mLast],'rid:',[srall],0) - (mPos+21));
          mStatus:= NxToken(mTempStr, ' ');
          mPos:= NxSearch(mList[mLast],'time:',[srall],0);
          mTempStr:= Copy(mList[mLast], mPos+6,NxSearch(mList[mLast],'rid:',[srall],0) - (mPos+6));
          mTime:= NxToken(mTempStr, ' ');

          mBody:= '';
          mBreak:= false;

          j := mHeader+1;
          while (j < mLast) and (mBreak = false)  do
          begin
            //if mBreak = False then begin
              if (mMethod = 'PUT') or (mMethod = 'POST') or (mMethod = 'GET') then begin
                if NxIsBlank(mBody) then begin
                  if(NxAt(cScript,mList[j]) > 0) then begin
                    o:= j;
                    //while (o < mlast) and (Copy(mlist[o],0,1) =' ') do begin
                    mCountBracket:= 0;
                    repeat
                      mCountBracket:= mCountBracket +(NxCharCount('{',mlist[o]) - NxCharCount('}',mlist[o]));
                      mBody:= mBody + Trim(mlist[o]);
                      o:= o + 1;
                    until (o = mlast) or (mCountBracket = 0);

                    mBreak:= true;
                  end;
                end;
              end
              else
                mBreak:= true;
            //end;

            j := j + 1;
          end;

          mExceptionMessage:= '';
          if not (mStatus IN ['200', '201', '204']) then begin
            for j:= mHeader to mLast do begin
              if(NxAt(cException,mList[j]) > 0) then begin
                o:= j+1;
                while (o < mlast) and (Copy(mlist[o],0,1) =' ') do begin
                  mExceptionMessage:= mExceptionMessage + Trim(mlist[o]) +' ';
                  o:= o + 1;
                end;
              end;
            end;
          end;

          mResultStr:= NxLeft(mlist[i],19)+';'+ mRequestID+';'+ mURL + ';'+ mTime +';'+ mMethod+';' +mStatus+ ';'+mExceptionMessage+';'+mDatabase +';'+mLogin +';'+mBody+';'+inttostr(mHeader+1)+';'+inttostr(mLast+1);
          mResult.Add(mResultStr);

        end;

        //mResultStr:= NxLeft(mlist[i],23)+';'+ mRequestID+';'+ mURL + ';'+ mTime +';'+ mMethod+';' +mStatus+ ';'+mHost+';'+mDatabase +';'+mLogin +';'+mBody+';'+inttostr(mHeader+1)+';'+inttostr(mLast+1);
        //mResult.Add(mResultStr);
      end;
      i := i + 1;
    end;
    //mXML.SaveToFile(mFileName+'_parsed.xml','utf-8');
    mResult.SaveToFile(mFilename+'_parsed.csv',TEncoding.UTF8);
    ShowMessage('hotovo');
  finally
    mList.Free;
    mResult.Free;
    //mXML.Free;
    WaitWin.Stop;
  end;
end;

procedure AddButton(ASite: TSiteForm; AShowControl, AShowMenuItem: Boolean; ACaption, AHint, ACategory: String; AOnExecute: Pointer);
var
  mAction: TBasicAction;
begin
  if Assigned(ASite) then begin
    mAction := ASite.GetNewAction;
    if Assigned(mAction) then begin
      mAction.ShowControl := AShowControl;
      mAction.ShowMenuItem := AShowMenuItem;
      mAction.Caption := ACaption;
      mAction.Hint := AHint;
      mAction.Category := ACategory;
      mAction.OnExecute := AOnExecute;
    end;
  end;
end;

function ISODateTimeToDateTime(AISODateTime: string): TDateTime;
var
  mY, mM, mD, mHH, mMM, mSS, mNN: Integer;
begin
  mY := StrToInt(Copy(AISODateTime, 1, 4));
  mM := StrToInt(Copy(AISODateTime, 6, 2));
  mD := StrToInt(Copy(AISODateTime, 9, 2));
  mHH := StrToInt(Copy(AISODateTime, 12, 2));
  mMM := StrToInt(Copy(AISODateTime, 15, 2));
  mSS := StrToInt(Copy(AISODateTime, 18, 2));
  mNN := StrToInt(Copy(AISODateTime, 21, 3));
  Result := EncodeDateTime(mY, mM, mD, mHH, mMM, mSS, mNN);
end;
begin
end.