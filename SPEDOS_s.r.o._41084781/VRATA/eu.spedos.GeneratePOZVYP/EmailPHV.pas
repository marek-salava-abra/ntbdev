uses 'eu.spedos.GeneratePOZVYP.const', '.fce';

procedure SendPHV(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mFileName, mTempDir:string;
 mList:TStringList;
 mMessage:string;
begin
  mList:=Tstringlist.create;
  os.SQLSelect(format('select sd2.id from storedocuments sd left join storedocuments2 sd2 on sd.id=sd2.parent_id where sd.documenttype=''28'' and not(sd2.store_id=''1B00000101'') and sd.createdat$date>%s ',[IntToStr(Trunc(Date-1))+'.35416666']),mList);
  mMessage:=format('select sd.id from storedocuments sd left join storedocuments2 sd2 on sd.id=sd2.parent_id where sd.documenttype=''28'' and not(sd2.store_id=''1B00000101'') and sd.createdat$date>%s ',[IntToStr(Trunc(Date-1))+'.35416666']);
  if mlist.Count>0 then begin
        mTempDir:=NxGetTempDir;
        mFileName:='PHV_24hod';
        CFxReportManager.PrintByIDs(NxCreateContext(os), mList, 'WBFDIVPW1ZE13HBT00C5OG4NF4', '2OV1000101', rtoFile, pekPDF, mTempDir, mFileName + '.pdf');
        //CFxInternet.SMSendMailWithMoreFiles(csOpenSSL,cMailLogin,cMailPassword,cMailSMTP,587,cMailFrom,'vinklarkova@spedos.cz',
        // '','','Nové PHV ','',commAsText,mTempDir+'\'+mFileName+'.pdf');
        //CFxInternet.SMSendMailWithMoreFiles(csOpenSSL,cMailLogin,cMailPassword,cMailSMTP,587,cMailFrom,'sklad@spedos.cz',
        // '','','Nové PHV ','',commAsText,mTempDir+'\'+mFileName+'.pdf');
        //CFxInternet.SMSendMailWithMoreFiles(csOpenSSL,cMailLogin,cMailPassword,cMailSMTP,587,cMailFrom,'vaculikova@spedos.cz',
        // '','','Nové PHV ','',commAsText,mTempDir+'\'+mFileName+'.pdf');
        //CFxInternet.SMSendMailWithMoreFiles(csOpenSSL,cMailLogin,cMailPassword,cMailSMTP,587,cMailFrom,'miculkova@spedos.cz',
        // '','','Nové PHV ','',commAsText,mTempDir+'\'+mFileName+'.pdf');
        {CFxInternet.SMSendMailWithMoreFiles(csOpenSSL,cMailLogin,cMailPassword,cMailSMTP,465,cMailFrom,'marek.salava@abra.eu',
         '','','Nové PHV ',mList.DelimitedText,commAsText,mTempDir+'\'+mFileName+'.pdf');}
        SendInternalMail(OS,'vinklarkova@spedos.cz','','Nové PHV','',mTempDir+'\'+mFileName+'.pdf','','','','','');
        SendInternalMail(OS,'sklad@spedos.cz','','Nové PHV','',mTempDir+'\'+mFileName+'.pdf','','','','','');
        SendInternalMail(OS,'vaculikova@spedos.cz','','Nové PHV','',mTempDir+'\'+mFileName+'.pdf','','','','','');
        SendInternalMail(OS,'miculkova@spedos.cz','','Nové PHV','',mTempDir+'\'+mFileName+'.pdf','','','','','');
        DeleteFile(mTempDir+'\'+mFileName+'.pdf');

  end;
  if mlist.Count=0 then begin
        mTempDir:=NxGetTempDir;
        mFileName:='PHV_24hod';
        //CFxReportManager.PrintByIDs(NxCreateContext(os), mList, 'WBFDIVPW1ZE13HBT00C5OG4NF4', '2OV1000101', rtoFile, pekPDF, mTempDir, mFileName + '.pdf');
        {CFxInternet.SMSendMailWithMoreFiles(csOpenSSL,cMailLogin,cMailPassword,cMailSMTP,587,cMailFrom,'vinklarkova@spedos.cz',
         '','','Dnes nebylo žádné PHV ','',commAsText,'');
        CFxInternet.SMSendMailWithMoreFiles(csOpenSSL,cMailLogin,cMailPassword,cMailSMTP,587,cMailFrom,'sklad@spedos.cz',
         '','','Dnes nebylo žádné PHV','',commAsText,'');
        CFxInternet.SMSendMailWithMoreFiles(csOpenSSL,cMailLogin,cMailPassword,cMailSMTP,587,cMailFrom,'vaculikova@spedos.cz',
         '','','Dnes nebylo žádné PHV','',commAsText,'');
        CFxInternet.SMSendMailWithMoreFiles(csOpenSSL,cMailLogin,cMailPassword,cMailSMTP,587,cMailFrom,'miculkova@spedos.cz',
         '','','Dnes nebylo žádné PHV','',commAsText,'');   }
        SendInternalMail(OS,'vinklarkova@spedos.cz','','Dnes nebylo žádné PHV','','','','','','','');
        SendInternalMail(OS,'sklad@spedos.cz','','Dnes nebylo žádné PHV','','','','','','','');
        SendInternalMail(OS,'vaculikova@spedos.cz','','Dnes nebylo žádné PHV','','','','','','','');
        SendInternalMail(OS,'miculkova@spedos.cz','','Dnes nebylo žádné PHV','','','','','','','');

  end;
  Success := True;
  LogInfoStr := mMessage+#13#10+'Počet PHV '+IntToStr(mlist.count);
  mList.free;
end;

begin
end.