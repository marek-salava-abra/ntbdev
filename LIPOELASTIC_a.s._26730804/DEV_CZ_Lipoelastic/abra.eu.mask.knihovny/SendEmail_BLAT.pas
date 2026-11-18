const
    path='';
    instpath='';
    muser='mehacek@seynam.cy';
    mpasw='meloun';
    mserver='seznam.cz';


    {muser='pcsupportcz.smtp@client.virtualzone.eu';
    mpasw='5mv8LH^iN#qr';
    mserver='smtp.virtualzone.eu';
                                  }
  cMailer = '%s\blat\blat.exe ';

procedure iSendMail_blat(AFrom: string;ATo: string; ACC: string; ABCC: string;
                         ASubject: string; ABody: string;AFiles: String; APriority: Integer = 1);
var
    mRecipients: string;
    mAttachments: string;
    mBodyFilename: string;
    mSubjFilename: string;
    mCmd: string;
    i: Integer;
    xx:string;
begin
    mBodyFilename := '';
    try
      mSubjFilename := '';
      try
        ATo:='mehacek@seznam.cz'  ;
        mRecipients := ' -to ' + ATo;        // adresati
        if ACC <> '' then mRecipients := mRecipients + ' -cc ' + ACC;   // kopie
        if ABCC <> '' then mRecipients := mRecipients + ' -bcc ' + ABCC;  // skyryta kopie
                  // přílohy
        mCmd :=
                Format(cMailer, [NxDelPathDelimiter(ExtractFilePath(ParamStr(0)))]) +
                ' -server '+mserver+' -f '+AFrom+mRecipients+' -u '+mUser+' -pw '+mpasw+' -charset windows-1250 -mime'+
                NxIIfStr(mSubjFilename = '',
                Format(' -subject "%s"', [ASubject]),
                Format(' -subject @%s', [mSubjFilename])) +
                ' -body ' + '"' + Abody + '"' +        ' -from ' + AFrom +
                mRecipients +
                NxIIfStr(APriority <> 1, Format(' -priority %d', [NxIIfInt(APriority < 1, 0, 1)]), '');
        inputbox('test','Test',mCmd);
        // ShowMessage(mCmd);                    // **********************
        NxScriptingLog.WriteEvent(logDebug, 'abra.eu.mask.knihovny/SendEmail_BLAT.iSendMail_blat() cmd=' + mCmd);
        NxExecFile(mCmd, True, True);         // zavolame blat ;
      finally
        iDeleteTempFile(mSubjFilename);
      end;
    finally
      iDeleteTempFile(mBodyFilename);
    end;
  //function iSaveToTempFile(AText: string): string;
  //var
  //  mStrings: TStrings;
  //begin
  //end;
end;


procedure iDeleteTempFile(AFilename: string);
begin
  if (AFilename <> '') and FileExists(AFilename) then
    DeleteFile(AFilename);
end;



begin
end.