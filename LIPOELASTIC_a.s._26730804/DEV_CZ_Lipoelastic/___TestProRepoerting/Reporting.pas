const
mSQL_dotaz='select %s from %s where clsid=%s and code=%s';
mSQL_FV_nezaplaceno_firm_ID='SELECT a.id FROM IssuedInvoices A JOIN Firms F ON F.ID=A.Firm_ID WHERE (  ( ((A.Amount>=0) and ((A.PaidAmount<=0) and ((A.Amount + A.PaidCreditAmount - A.PaidAmount -  A.CreditAmount) > 0))) or ((A.Amount <0) and ((A.PaidAmount>=0) and ((A.Amount + A.PaidCreditAmount - A.PaidAmount -  A.CreditAmount) < 0))) )  OR  ( ((A.Amount>=0) and ((A.PaidAmount >0) and ((A.Amount + A.PaidCreditAmount - A.PaidAmount -  A.CreditAmount) > 0))) or ((A.Amount <0) and ((A.PaidAmount <0) and ((A.Amount + A.PaidCreditAmount - A.PaidAmount -  A.CreditAmount) < 0))) )  OR  ( ((A.Amount>=0) and ((A.Amount + A.PaidCreditAmount - A.PaidAmount -  A.CreditAmount) < 0)) or ((A.Amount <0) and ((A.Amount + A.PaidCreditAmount - A.PaidAmount -  A.CreditAmount) > 0)) ) ) ' +
                             ' AND (F.ID=%s OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID=%s)) ) order by a.DueDate$DATE desc ';









procedure Create_report(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
  mBO : TNxCustomBusinessObject;
  mPrintList:TStringList;
  i : integer;
  aname:string;
  mEmailAccount_ID:string;
  mReport_ID:string;
  mSubject,mBody:string;
  mBodySavedAs,mSentState:integer;
  mEmail,mCopyEmail,mBccEmail:string;
  mFilename:string;
  mFirm_ID, mFirmOffice_ID, mPerson_ID, mDivision_ID:string;
  mSQL:string;
  mID:string;
  aFileName,mString:String;
begin
//  NxScriptingLog.EnterSection('abra.eu.mask.nazaplaceno1/Nezaplaceno1.Odeslani_dokladu_auto()', logNotice);
      LogInfoStr := '';
      mEmailAccount_ID:='3130000101';
      mDivision_ID:='1000000101';

      if DayOfTheMonth(now())=3 then begin
      // ******** report GMBH
      // *** parametry
                mFirm_ID:=QuotedStr('8FCG300101');mFirmOffice_ID:='';mPerson_ID:='';
                mEmail:=''; mCopyEmail:=''; mBccEmail:='';
                mFilename:='';
                mSubject:='';mBody:='';
                mBodySavedAs:= 1;mSentState:= 1;


          mSQL:=mSQL_FV_nezaplaceno_firm_ID;
          mID:='';
          mprintlist:=Tstringlist.create;
                try
                  OS.SQLSelect(format(mSQL,[mfirm_id,mfirm_id]), mprintlist);
                      if (mprintlist.Count>0) then begin
                          mBO := OS.CreateObject(Class_IssuedInvoice);
                          try
                                      mBO.load(mPrintList.Strings[0], nil) ;
                                      mBodySavedAs:= 1;mSentState:= 0;
                                      mReport_ID:='10A0000101';
                                      //mFirm_ID:=mBO.GetFieldValueAsString('Firm_ID') ; mFirmOffice_ID:=mBO.GetFieldValueAsString('FirmOffice_ID') ; mPerson_ID:=mBO.GetFieldValueAsString('Person_ID') ;
                                      mEmail:='mskacel'; mCopyEmail:=''; mBccEmail:='';
                                      mSubject:='Report from ' + FormatDateTime('DD.MM.YYYY',now);
                                      mBody:='Report from ' + FormatDateTime('DD.MM.YYYY',now);

                                      // **** vytvoření souboru
                                               aFileName := 'Report from ' + FormatDateTime('DD.MM.YYYY',now) +'.xls' ;
                                              try
                                                  //CFxReportManager.PrintByIDs(NxCreateContext(OS),mPrintList,'', mReport_ID, rtofile, pekExcel,NxGetTempDir,aFileName);
                                                  CFxReportManager.PrintByIDs(NxCreateContext(OS),mPrintList,'DCGGWH4VRREL3FWD002BG34ZPK', mReport_ID, rtofile, pekPDF,NxGetTempDir,aFileName);
                                                  mFilename:=NxGetTempDir+aFileName;
                                                  LogInfoStr:= LogInfoStr + chr(13) + ' Export salda pro firmu ' + mBO.GetFieldValueAsString('Firm_ID.name') + ' proběhl s ' + inttostr(mprintlist.count) + ' záznamy';
                                              except
                                                      LogInfoStr:= LogInfoStr + chr(13) + ' Export salda pro firmu ' + mBO.GetFieldValueAsString('Firm_ID.name') + ExceptionMessage + ' Chyba - Nevytvoření souboru';
                                              end;

                                     // **** Uložení emailu
                                              try
                                                  mString:='';
                                                  mString:= iSendMail(os, mSubject, mBody, mEmail, mCopyEmail,mBccEmail,mEmailAccount_ID, mFilename,mDivision_ID,mBO);
                                                  if mString<>'' then
                                                       LogInfoStr:= LogInfoStr + chr(13) + ' Export salda pro firmu ' + mBO.GetFieldValueAsString('Firm_ID.name') + ExceptionMessage + ' Email vytvořen'
                                                  else
                                                       LogInfoStr:= LogInfoStr + chr(13) + ' Export salda pro firmu ' + mBO.GetFieldValueAsString('Firm_ID.name') + ExceptionMessage + ' Chyba - Nevytvoření emailu';
                                              except
                                                  LogInfoStr:= LogInfoStr + chr(13) + ' Export salda pro firmu ' + mBO.GetFieldValueAsString('Firm_ID.name') + ExceptionMessage + ' Chyba - Nevytvořeí emailu';
                                              end;
                            finally
                                mBO.free;
                            end;
                      end;
                finally
                     mPrintList.Free;
                end;

      end;









      if DayOfTheMonth(now())=3 then begin
      // ******** report LTD
      // *** parametry
                mFirm_ID:=QuotedStr('8F5H700101');mFirmOffice_ID:='';mPerson_ID:='';
                mEmail:=''; mCopyEmail:=''; mBccEmail:='';
                mFilename:='';
                mSubject:='';mBody:='';
                mBodySavedAs:= 1;mSentState:= 1;


          mSQL:=mSQL_FV_nezaplaceno_firm_ID;
          mID:='';
          mprintlist:=Tstringlist.create;
                try
                  OS.SQLSelect(format(mSQL,[mfirm_id,mfirm_id]), mprintlist);
                      if (mprintlist.Count>0) then begin
                          mBO := OS.CreateObject(Class_IssuedInvoice);
                          try
                                      mBO.load(mPrintList.Strings[0], nil) ;
                                      mBodySavedAs:= 1;mSentState:= 0;
                                      mReport_ID:='1CG0000101';
                                      mFirm_ID:=mBO.GetFieldValueAsString('Firm_ID') ; mFirmOffice_ID:=mBO.GetFieldValueAsString('FirmOffice_ID') ; mPerson_ID:=mBO.GetFieldValueAsString('Person_ID') ;
                                      mEmail:='premes@lipoelastic.com'; mCopyEmail:=''; mBccEmail:='';
                                      mSubject:='Report from ' + FormatDateTime('DD.MM.YYYY',now);
                                      mBody:='Report from ' + FormatDateTime('DD.MM.YYYY',now);

                                      // **** vytvoření souboru
                                               aFileName := 'Report from ' + FormatDateTime('DD.MM.YYYY',now) +'.xls' ;
                                              try
                                                  //CFxReportManager.PrintByIDs(NxCreateContext(OS),mPrintList,'', mReport_ID, rtofile, pekExcel,NxGetTempDir,aFileName);
                                                  CFxReportManager.PrintByIDs(NxCreateContext(OS),mPrintList,'40SBPEINEFD13ACM03KIU0CLP4', mReport_ID, rtofile, pekExcel,NxGetTempDir,aFileName);
                                                  mFilename:=NxGetTempDir+aFileName;
                                                  LogInfoStr:= LogInfoStr + chr(13) + ' Export salda pro firmu ' + mBO.GetFieldValueAsString('Firm_ID.name') + ' proběhl s ' + inttostr(mprintlist.count) + ' záznamy';
                                              except
                                                      LogInfoStr:= LogInfoStr + chr(13) + ' Export salda pro firmu ' + mBO.GetFieldValueAsString('Firm_ID.name') + ExceptionMessage + ' Chyba - Nevytvoření souboru';
                                              end;

                                     // **** Uložení emailu
                                              try
                                                  mString:='';
                                                  mString:= iSendMail(os, mSubject, mBody, mEmail, mCopyEmail,mBccEmail,mEmailAccount_ID, mFilename,mDivision_ID,mBO);
                                                  if mString<>'' then
                                                       LogInfoStr:= LogInfoStr + chr(13) + ' Export salda pro firmu ' + mBO.GetFieldValueAsString('Firm_ID.name') + ExceptionMessage + ' Email vytvořen'
                                                  else
                                                       LogInfoStr:= LogInfoStr + chr(13) + ' Export salda pro firmu ' + mBO.GetFieldValueAsString('Firm_ID.name') + ExceptionMessage + ' Chyba - Nevytvoření emailu';
                                              except
                                                  LogInfoStr:= LogInfoStr + chr(13) + ' Export salda pro firmu ' + mBO.GetFieldValueAsString('Firm_ID.name') + ExceptionMessage + ' Chyba - Nevytvořeí emailu';
                                              end;
                            finally
                                mBO.free;
                            end;
                      end;
                finally
                     mPrintList.Free;
                end;

end;









if DayOfTheMonth(now())=3 then begin
      // ******** report BV
      // *** parametry
                mFirm_ID:=QuotedStr('AFTX600101');mFirmOffice_ID:='';mPerson_ID:='';
                mEmail:=''; mCopyEmail:=''; mBccEmail:='';
                mFilename:='';
                mSubject:='';mBody:='';
                mBodySavedAs:= 1;mSentState:= 1;


          mSQL:=mSQL_FV_nezaplaceno_firm_ID;
          mID:='';
          mprintlist:=Tstringlist.create;
                try
                  OS.SQLSelect(format(mSQL,[mfirm_id,mfirm_id]), mprintlist);
                      if (mprintlist.Count>0) then begin
                          mBO := OS.CreateObject(Class_IssuedInvoice);
                          try
                                      mBO.load(mPrintList.Strings[0], nil) ;
                                      mBodySavedAs:= 1;mSentState:= 0;
                                      mReport_ID:='1CG0000101';
                                      mFirm_ID:=mBO.GetFieldValueAsString('Firm_ID') ; mFirmOffice_ID:=mBO.GetFieldValueAsString('FirmOffice_ID') ; mPerson_ID:=mBO.GetFieldValueAsString('Person_ID') ;
                                      mEmail:='premes@lipoelastic.com'; mCopyEmail:=''; mBccEmail:='';
                                      mSubject:='Report from ' + FormatDateTime('DD.MM.YYYY',now);
                                      mBody:='Report from ' + FormatDateTime('DD.MM.YYYY',now);

                                      // **** vytvoření souboru
                                               aFileName := 'Report from ' + FormatDateTime('DD.MM.YYYY',now) +'.xls' ;
                                              try
                                                  //CFxReportManager.PrintByIDs(NxCreateContext(OS),mPrintList,'', mReport_ID, rtofile, pekExcel,NxGetTempDir,aFileName);
                                                  CFxReportManager.PrintByIDs(NxCreateContext(OS),mPrintList,'40SBPEINEFD13ACM03KIU0CLP4', mReport_ID, rtofile, pekExcel,NxGetTempDir,aFileName);
                                                  mFilename:=NxGetTempDir+aFileName;
                                                  LogInfoStr:= LogInfoStr + chr(13) + ' Export salda pro firmu ' + mBO.GetFieldValueAsString('Firm_ID.name') + ' proběhl s ' + inttostr(mprintlist.count) + ' záznamy';
                                              except
                                                      LogInfoStr:= LogInfoStr + chr(13) + ' Export salda pro firmu ' + mBO.GetFieldValueAsString('Firm_ID.name') + ExceptionMessage + ' Chyba - Nevytvoření souboru';
                                              end;

                                     // **** Uložení emailu
                                              try
                                                  mString:='';
                                                  mString:= iSendMail(os, mSubject, mBody, mEmail, mCopyEmail,mBccEmail,mEmailAccount_ID, mFilename,mDivision_ID,mBO);
                                                  if mString<>'' then
                                                       LogInfoStr:= LogInfoStr + chr(13) + ' Export salda pro firmu ' + mBO.GetFieldValueAsString('Firm_ID.name') + ExceptionMessage + ' Email vytvořen'
                                                  else
                                                       LogInfoStr:= LogInfoStr + chr(13) + ' Export salda pro firmu ' + mBO.GetFieldValueAsString('Firm_ID.name') + ExceptionMessage + ' Chyba - Nevytvoření emailu';
                                              except
                                                  LogInfoStr:= LogInfoStr + chr(13) + ' Export salda pro firmu ' + mBO.GetFieldValueAsString('Firm_ID.name') + ExceptionMessage + ' Chyba - Nevytvořeí emailu';
                                              end;
                            finally
                                mBO.free;
                            end;
                      end;
                finally
                     mPrintList.Free;
                end;
end;



if DayOfTheMonth(now())=3 then begin
        // ******** report srl
      // *** parametry
                mFirm_ID:=QuotedStr('8FP0700101');mFirmOffice_ID:='';mPerson_ID:='';
                mEmail:=''; mCopyEmail:=''; mBccEmail:='';
                mFilename:='';
                mSubject:='';mBody:='';
                mBodySavedAs:= 1;mSentState:= 1;


          mSQL:=mSQL_FV_nezaplaceno_firm_ID;
          mID:='';
          mprintlist:=Tstringlist.create;
                try
                  OS.SQLSelect(format(mSQL,[mfirm_id,mfirm_id]), mprintlist);
                      if (mprintlist.Count>0) then begin
                          mBO := OS.CreateObject(Class_IssuedInvoice);
                          try
                                      mBO.load(mPrintList.Strings[0], nil) ;
                                      mBodySavedAs:= 1;mSentState:= 0;
                                      mReport_ID:='1CG0000101';
                                      mFirm_ID:=mBO.GetFieldValueAsString('Firm_ID') ; mFirmOffice_ID:=mBO.GetFieldValueAsString('FirmOffice_ID') ; mPerson_ID:=mBO.GetFieldValueAsString('Person_ID') ;
                                      mEmail:='premes@lipoelastic.com'; mCopyEmail:=''; mBccEmail:='';
                                      mSubject:='Report from ' + FormatDateTime('DD.MM.YYYY',now) ;
                                      mBody:='Report from ' + FormatDateTime('DD.MM.YYYY',now);

                                      // **** vytvoření souboru
                                               aFileName := 'Report from ' + FormatDateTime('DD.MM.YYYY',now) +'.xls' ;
                                              try
                                                  //CFxReportManager.PrintByIDs(NxCreateContext(OS),mPrintList,'', mReport_ID, rtofile, pekExcel,NxGetTempDir,aFileName);
                                                  CFxReportManager.PrintByIDs(NxCreateContext(OS),mPrintList,'40SBPEINEFD13ACM03KIU0CLP4', mReport_ID, rtofile, pekExcel,NxGetTempDir,aFileName);
                                                  mFilename:=NxGetTempDir+aFileName;
                                                  LogInfoStr:= LogInfoStr + chr(13) + ' Export salda pro firmu ' + mBO.GetFieldValueAsString('Firm_ID.name') + ' proběhl s ' + inttostr(mprintlist.count) + ' záznamy';
                                              except
                                                      LogInfoStr:= LogInfoStr + chr(13) + ' Export salda pro firmu ' + mBO.GetFieldValueAsString('Firm_ID.name') + ExceptionMessage + ' Chyba - Nevytvoření souboru';
                                              end;

                                     // **** Uložení emailu
                                              try
                                                  mString:='';
                                                  mString:= iSendMail(os, mSubject, mBody, mEmail, mCopyEmail,mBccEmail,mEmailAccount_ID, mFilename,mDivision_ID,mBO);
                                                  if mString<>'' then
                                                       LogInfoStr:= LogInfoStr + chr(13) + ' Export salda pro firmu ' + mBO.GetFieldValueAsString('Firm_ID.name') + ExceptionMessage + ' Email vytvořen'
                                                  else
                                                       LogInfoStr:= LogInfoStr + chr(13) + ' Export salda pro firmu ' + mBO.GetFieldValueAsString('Firm_ID.name') + ExceptionMessage + ' Chyba - Nevytvoření emailu';
                                              except
                                                  LogInfoStr:= LogInfoStr + chr(13) + ' Export salda pro firmu ' + mBO.GetFieldValueAsString('Firm_ID.name') + ExceptionMessage + ' Chyba - Nevytvořeí emailu';
                                              end;
                            finally
                                mBO.free;
                            end;
                      end;
                finally
                     mPrintList.Free;
                end;

end;





      Success := True;
 //     LogInfoStr:= LogInfoStr + chr(13) + 'Odesláno ' + IntToStr(mEmailu)+ ' emailů z '+IntToStr(mZaznamu)+' vystavených';

//     NxScriptingLog.WriteEventFmt(logError, 'abra.eu.mask.nazaplaceno1/Nezaplaceno1.Odeslani_dokladu_auto(), Chyba:: %s', [ExceptionMessage]);

end;


Function iSendMail(AOS : TNxCustomObjectSpace; const ASubject : string; const ABody : string; ATo : string;mS_CopyEmail:string;mS_BccEmail:string; AFrom : string = '';afilename:string;mDivision_ID:string;mBO_source:TNxCustomBusinessObject):string;
var
  mbo,mRecipient : TNxCustomBusinessObject;
  mAttachmentColl: TNxCustomBusinessMonikerCollection ;
  mSL : TStringList;
  i : integer;
  mAttachments: TNxCustomBusinessMonikerCollection;
begin
  mBO := AOS.CreateObject('5C1HWDQDR3J4NAAYZRO5PWHLWK');
  try
    mBO.New;
    mBO.Prefill;
    if not NxIsBlank(AFrom) then
      mBO.SetFieldValueAsString('EmailAccount_ID',AFrom);
        mBO.SetFieldValueAsString('Firm_ID',mbo_source.GetFieldValueAsString('Firm_ID'));
        mBO.SetFieldValueAsString('FirmOffice_ID',mbo_source.GetFieldValueAsString('FirmOffice_ID'));
        mBO.SetFieldValueAsString('Person_ID',mbo_source.GetFieldValueAsString('Person_ID'));
        mBO.SetFieldValueAsString('Division_ID', mDivision_ID);


    mBO.SetFieldValueAsString('Subject','Report from ' + FormatDateTime('DD.MM.YYYY',now));
    mBO.SetFieldValueAsString('Body','Report from ' + FormatDateTime('DD.MM.YYYY',now));

    mBO.SetFieldValueAsInteger('BodySavedAs', 1);
    mBO.SetFieldValueAsInteger('SentState', 1);
    mSL := TStringList.Create;

    // *** adresát
    try
      NxTokenToStrings(ATO, ';', mSL);
      for i := 0 to mSL.Count - 1 do begin
        mRecipient := mBO.GetCollectionMonikerForFieldCode(mBO.GetFieldCode('Recipients')).AddNewObject;
        mRecipient.SetFieldValueAsInteger('EmailType', 0);
        mRecipient.SetFieldValueAsString('email', mSL.Strings[i]);
      end;
    finally
      mSL.Free;
    end;
// ****    kopie
    mSL := TStringList.Create;
    try
      NxTokenToStrings(mS_CopyEmail, ';', mSL);
      for i := 0 to mSL.Count - 1 do begin
        mRecipient := mBO.GetCollectionMonikerForFieldCode(mBO.GetFieldCode('Recipients')).AddNewObject;
        mRecipient.SetFieldValueAsInteger('EmailType', 1);
        mRecipient.SetFieldValueAsString('email', mSL.Strings[i]);
      end;
    finally
     mSL.Free;
    end;
// **** skrytá kopie
   mSL := TStringList.Create;
    try
      NxTokenToStrings(mS_BccEmail, ';', mSL);
      for i := 0 to mSL.Count - 1 do begin
        mRecipient := mBO.GetCollectionMonikerForFieldCode(mBO.GetFieldCode('Recipients')).AddNewObject;
        mRecipient.SetFieldValueAsInteger('EmailType', 2);
        mRecipient.SetFieldValueAsString('email', mSL.Strings[i]);
      end;
    finally
      mSL.Free;
    end;
    // **** přílohy
    if (afilename <> '') then begin
          mAttachments := mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Attachments'));
           mSL := TStringList.Create;
              try
                NxTokenToStrings(afilename, ';', mSL);
                for i := 0 to mSL.Count - 1 do begin
                   TNxEmailSent(mbo).AttachFile(mSL.Strings[i]);
        //             TNxEmailSent(mbo).AttachFile(afilename);
                end;
              finally
                mSL.Free;
              end;
    end;


   // **** uložení emailu
    mbo.save;
    result:=mbo.oid;
    finally
       mbo.free;
    end;
end;






function GetFileNameBOLog(mBO:TNxCustomBusinessObject;aname:string):string;
var s:string;
begin
        s:=aname;
        s:=NxRemoveDiacritics(s);
                while pos('.',s)>0 do delete(s,pos('.',s),1);
                while pos('/',s)>0 do delete(s,pos('/',s),1);
                while pos('-',s)>0 do delete(s,pos('-',s),1);
                while pos(':',s)>0 do delete(s,pos(':',s),1);
                while pos(',',s)>0 do delete(s,pos(',',s),1);
                while pos(' ',s)>0 do delete(s,pos(' ',s),1);
                while pos('"',s)>0 do delete(s,pos('"',s),1);
                result:=s+'.pdf';
end;





begin
end.