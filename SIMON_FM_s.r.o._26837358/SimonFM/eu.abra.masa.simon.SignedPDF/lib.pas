const
 cRootDir='\\terminal\Signotec_hotovo\';



{GetRootDir}



function GetRootDir(AReportHelper:TNxQRScriptHelper):String;
begin
  Result:=cRootDir;
end;

procedure MoveAndMail(OS: TNxCustomObjectSpace; var ProcessContinue: Boolean; Directory: string; FileName: string);
var
 mCode, mOrdnumber, mPeriodCode, mTempFileName, mObject_ID:string;
 mBO, mTextBO:TNxCustomBusinessObject;
 mSubject, mMailText, mTo, mNote, mOrigPMState_ID:string;
begin
 try
  ProcessContinue := True;
  mTempFileName:=FileName;
  mCode:=NxTrapStr(mTempFileName,'-');
  mOrdnumber:=NxTrapStr(mTempFileName,'-');
  mPeriodCode:=NxTrapStr(mTempFileName,'.');
  if (AnsiLeftStr(mCode,2)='DL') and (Length(mCode)>1) then begin
    if not(DirectoryExists(cRootDir+'Dodaci_listy')) then CreateDir(cRootDir+'Dodaci_listy');
    if not(DirectoryExists(cRootDir+'Dodaci_listy\'+mPeriodCode)) then CreateDir(cRootDir+'Dodaci_listy\'+mPeriodCode);
    if not(DirectoryExists(cRootDir+'Dodaci_listy\'+mPeriodCode+'\'+mCode)) then CreateDir(cRootDir+'Dodaci_listy\'+mPeriodCode+'\'+mCode);
    if not(DirectoryExists(cRootDir+'Dodaci_listy\'+mPeriodCode+'\'+mCode+'\'+mCode+'-'+mOrdnumber+'-'+mPeriodCode)) then
       CreateDir(cRootDir+'Dodaci_listy\'+mPeriodCode+'\'+mCode+'\'+mCode+'-'+mOrdnumber+'-'+mPeriodCode);
    if DirectoryExists(cRootDir+'Dodaci_listy\'+mPeriodCode+'\'+mCode+'\'+mCode+'-'+mOrdnumber+'-'+mPeriodCode) then
      NxCopyFile(Directory+'\'+FileName,cRootDir+'Dodaci_listy\'+mPeriodCode+'\'+mCode+'\'+mCode+'-'+mOrdnumber+'-'+mPeriodCode+'\'+FileName);
    mObject_ID:=OS.SQLSelectFirstAsString('select sd.id from storedocuments sd left join docqueues dq on dq.id=sd.docqueue_id left join periods p on p.id=sd.period_id where dq.code='
                                          +QuotedStr(mCode)+' and sd.ordnumber='+mOrdnumber+' and p.code='+QuotedStr(mPeriodCode),'');
    if not(NxIsEmptyOID(mObject_ID)) then begin
        mBO:=OS.CreateObject(Class_BillOfDelivery);
        mbo.Load(mObject_ID,nil);
        mTextBO:=OS.CreateObject('DCHDUXZ0S3RO1DVWDVB0PD51U0');
        mTextBO.Load('M1JB000101',nil);
        mSubject:=mTextBO.GetFieldValueAsString('X_Subject');
        mMailText:=mTextBO.GetFieldValueAsString('X_Note');
        mTO:=mBO.GetFieldValueAsString('Firm_ID.ElectronicAddress_ID.Email');
        //mNote:=' cílový email: '+mTo;
        mNote:='';
        SendInternalMail(OS, mTo,'','marek.zizka@simonfm.cz',
                                       mSubject+' dodací list '+mbo.DisplayName+mNote,mMailText,
                                       cRootDir+'Dodaci_listy\'+mPeriodCode+'\'+mCode+'\'+mCode+'-'+mOrdnumber+'-'+mPeriodCode+'\'+FileName ,'',mbo.GetFieldValueAsString('Firm_ID'),
                                       mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('Division_ID'),
                                       mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('BusTransaction_ID'), '2300000101');
        mBO.SetFieldValueAsBoolean('U_PDFSigned',True);

        //pokud bude procesní stav v expedici a osobní odběr, změnit stav na dodáno a najít objednávku a změnit stav na dodáno
        if (mbo.GetFieldValueAsString('DocQueue_ID.Code')='DL03') then begin
         mbo.GetOriginalValue('PMState_ID',mOrigPMState_ID);
         if mOrigPMState_ID='5080000101' then
          mBO.SetFieldValueAsString('PMState_ID','8080000101');
        end;
        mBO.Save;
        mbo.free;
    end;
  end;
   if (AnsiLeftStr(mCode,2)='SV') and (Length(mCode)>1) then begin
    if not(DirectoryExists(cRootDir+'Servis_velkoobchod')) then CreateDir(cRootDir+'Servis_velkoobchod');
    if not(DirectoryExists(cRootDir+'Servis_velkoobchod\'+mPeriodCode)) then CreateDir(cRootDir+'Servis_velkoobchod\'+mPeriodCode);
    if not(DirectoryExists(cRootDir+'Servis_velkoobchod\'+mPeriodCode+'\'+mCode)) then CreateDir(cRootDir+'Servis_velkoobchod\'+mPeriodCode+'\'+mCode);
    if not(DirectoryExists(cRootDir+'Servis_velkoobchod\'+mPeriodCode+'\'+mCode+'\'+mCode+'-'+mOrdnumber+'-'+mPeriodCode)) then
       CreateDir(cRootDir+'Servis_velkoobchod\'+mPeriodCode+'\'+mCode+'\'+mCode+'-'+mOrdnumber+'-'+mPeriodCode);
    if DirectoryExists(cRootDir+'Servis_velkoobchod\'+mPeriodCode+'\'+mCode+'\'+mCode+'-'+mOrdnumber+'-'+mPeriodCode) then
      NxCopyFile(Directory+'\'+FileName,cRootDir+'Servis_velkoobchod\'+mPeriodCode+'\'+mCode+'\'+mCode+'-'+mOrdnumber+'-'+mPeriodCode+'\'+FileName);
    mObject_ID:=OS.SQLSelectFirstAsString('select sd.id from crmactivities sd left join CRMACTIVITYQUEUES dq on dq.id=sd.actqueue_id left join periods p on p.id=sd.period_id where dq.code='
                                          +QuotedStr(mCode)+' and sd.ordnumber='+mOrdnumber+' and p.code='+QuotedStr(mPeriodCode),'');
    if not(NxIsEmptyOID(mObject_ID)) then begin
        mBO:=OS.CreateObject(Class_CRMActivity);
        mbo.Load(mObject_ID,nil);
        mTextBO:=OS.CreateObject('DCHDUXZ0S3RO1DVWDVB0PD51U0');
        mTextBO.Load('M1JB000101',nil);
        mSubject:=mTextBO.GetFieldValueAsString('X_Subject');
        mMailText:=mTextBO.GetFieldValueAsString('X_Note');
        mTO:=mBO.GetFieldValueAsString('Firm_ID.ElectronicAddress_ID.Email');
        mNote:=' cílový email: '+mTo;
        SendInternalMail(OS, 'marek.zizka@simonfm.cz;mario.zizka@simonfm.cz','','',
                                       mSubject+' servisní list '+mbo.DisplayName +mNote,mMailText,
                                       cRootDir+'Servis_velkoobchod\'+mPeriodCode+'\'+mCode+'\'+mCode+'-'+mOrdnumber+'-'+mPeriodCode+'\'+FileName ,'',mbo.GetFieldValueAsString('Firm_ID'),
                                       mbo.GetFieldValueAsString('Division_ID'),
                                       mbo.GetFieldValueAsString('BusTransaction_ID'), '2300000101');
        mBO.SetFieldValueAsBoolean('U_PDFSigned',True);
        mBO.Save;
        mbo.free;
    end;
  end;
  if (AnsiLeftStr(mCode,2)='S') and (Length(mCode)=1) then begin
    if not(DirectoryExists(cRootDir+'Servis')) then CreateDir(cRootDir+'Servis');
    if not(DirectoryExists(cRootDir+'Servis\'+mPeriodCode)) then CreateDir(cRootDir+'Servis\'+mPeriodCode);
    if not(DirectoryExists(cRootDir+'Servis\'+mPeriodCode+'\'+mCode)) then CreateDir(cRootDir+'Servis\'+mPeriodCode+'\'+mCode);
    if not(DirectoryExists(cRootDir+'Servis\'+mPeriodCode+'\'+mCode+'\'+mCode+'-'+mOrdnumber+'-'+mPeriodCode)) then
       CreateDir(cRootDir+'Servis\'+mPeriodCode+'\'+mCode+'\'+mCode+'-'+mOrdnumber+'-'+mPeriodCode);
    if DirectoryExists(cRootDir+'Servis\'+mPeriodCode+'\'+mCode+'\'+mCode+'-'+mOrdnumber+'-'+mPeriodCode) then
      NxCopyFile(Directory+'\'+FileName,cRootDir+'Servis\'+mPeriodCode+'\'+mCode+'\'+mCode+'-'+mOrdnumber+'-'+mPeriodCode+'\'+FileName);
    mObject_ID:=OS.SQLSelectFirstAsString('select sd.id from crmactivities sd left join CRMACTIVITYQUEUES dq on dq.id=sd.actqueue_id left join periods p on p.id=sd.period_id where dq.code='
                                          +QuotedStr(mCode)+' and sd.ordnumber='+mOrdnumber+' and p.code='+QuotedStr(mPeriodCode),'');
    if not(NxIsEmptyOID(mObject_ID)) then begin
        mBO:=OS.CreateObject(Class_CRMActivity);
        mbo.Load(mObject_ID,nil);
        mTextBO:=OS.CreateObject('DCHDUXZ0S3RO1DVWDVB0PD51U0');
        mTextBO.Load('M1JB000101',nil);
        mSubject:=mTextBO.GetFieldValueAsString('X_Subject');
        mMailText:=mTextBO.GetFieldValueAsString('X_Note');
        mTO:=mBO.GetFieldValueAsString('Firm_ID.ElectronicAddress_ID.Email');
        mNote:=' cílový email: '+mTo;
        SendInternalMail(OS, 'marek.zizka@simonfm.cz;mario.zizka@simonfm.cz','','',
                                       mSubject+' servisní list '+mbo.DisplayName+mNote,mMailText,
                                       cRootDir+'Servis\'+mPeriodCode+'\'+mCode+'\'+mCode+'-'+mOrdnumber+'-'+mPeriodCode+'\'+FileName ,'',mbo.GetFieldValueAsString('Firm_ID'),
                                       mbo.GetFieldValueAsString('Division_ID'),
                                       mbo.GetFieldValueAsString('BusTransaction_ID'), '2300000101');
        mBO.SetFieldValueAsBoolean('U_PDFSigned',True);
        mBO.Save;
        mbo.free;
    end;
  end;
  if (AnsiLeftStr(mCode,2)='P') and (Length(mCode)=1) then begin
    if not(DirectoryExists(cRootDir+'Pujcovna')) then CreateDir(cRootDir+'Pujcovna');
    if not(DirectoryExists(cRootDir+'Pujcovna\'+mPeriodCode)) then CreateDir(cRootDir+'Pujcovna\'+mPeriodCode);
    if not(DirectoryExists(cRootDir+'Pujcovna\'+mPeriodCode+'\'+mCode)) then CreateDir(cRootDir+'Pujcovna\'+mPeriodCode+'\'+mCode);
    if not(DirectoryExists(cRootDir+'Pujcovna\'+mPeriodCode+'\'+mCode+'\'+mCode+'-'+mOrdnumber+'-'+mPeriodCode)) then
       CreateDir(cRootDir+'Pujcovna\'+mPeriodCode+'\'+mCode+'\'+mCode+'-'+mOrdnumber+'-'+mPeriodCode);
    if DirectoryExists(cRootDir+'Pujcovna\'+mPeriodCode+'\'+mCode+'\'+mCode+'-'+mOrdnumber+'-'+mPeriodCode) then
      NxCopyFile(Directory+'\'+FileName,cRootDir+'Pujcovna\'+mPeriodCode+'\'+mCode+'\'+mCode+'-'+mOrdnumber+'-'+mPeriodCode+'\'+FileName);
    mObject_ID:=OS.SQLSelectFirstAsString('select sd.id from crmactivities sd left join CRMACTIVITYQUEUES dq on dq.id=sd.actqueue_id left join periods p on p.id=sd.period_id where dq.code='
                                          +QuotedStr(mCode)+' and sd.ordnumber='+mOrdnumber+' and p.code='+QuotedStr(mPeriodCode),'');
    if not(NxIsEmptyOID(mObject_ID)) then begin
        mBO:=OS.CreateObject(Class_CRMActivity);
        mbo.Load(mObject_ID,nil);
        mTextBO:=OS.CreateObject('DCHDUXZ0S3RO1DVWDVB0PD51U0');
        mTextBO.Load('M1JB000101',nil);
        mSubject:=mTextBO.GetFieldValueAsString('X_Subject');
        mMailText:=mTextBO.GetFieldValueAsString('X_Note');
        mTO:=mBO.GetFieldValueAsString('Firm_ID.ElectronicAddress_ID.Email');
        mNote:=' cílový email: '+mTo;
        SendInternalMail(OS, 'marek.zizka@simonfm.cz;mario.zizka@simonfm.cz','','',
                                       mSubject+' půjčovna '+mbo.DisplayName+mNote,mMailText,
                                       cRootDir+'Pujcovna\'+mPeriodCode+'\'+mCode+'\'+mCode+'-'+mOrdnumber+'-'+mPeriodCode+'\'+FileName ,'',mbo.GetFieldValueAsString('Firm_ID'),
                                       mbo.GetFieldValueAsString('Division_ID'),
                                       mbo.GetFieldValueAsString('BusTransaction_ID'), '2300000101');
        mBO.SetFieldValueAsBoolean('U_PDFSigned',True);
        mBO.Save;
        mbo.free;
    end;
  end;
 except
   NxCopyFile(Directory+'\'+FileName,'\\terminal\Signotec\Unable2Process\'+FileName);
   CFxLog.SaveLog(NxCreateContext(OS), 'ERR', 'Signed PDF'+FileName, ExceptionMessage, ltScripting, Now);
 end;

end;

procedure SendInternalMail(AOS:TNxCustomObjectSpace; ATo:String; ACC:String; ABCC:String;
                           ASubject:String; ABody:String; AAtachement, AAtachement2:String; AFirm_ID:String; ADivision_ID:String; ABusTransaction_ID:String; aAccount_ID:string);
Var
  mMailBO:TNxCustomBusinessObject;
  mMRecipients:TNxCustomBusinessMonikerCollection;
  mMailRecipient:TNxCustomBusinessObject;
begin
  if not(ato='') then begin
     mMailBO:=AOS.CreateObject('5C1HWDQDR3J4NAAYZRO5PWHLWK');
     mMailBO.New;
     mMailBO.Prefill;
     mMailBO.SetFieldValueAsString('EmailAccount_ID',aAccount_ID);
     mMailBO.SetFieldValueAsString('Subject',ASubject);
     mMailBO.SetFieldValueAsString('BodySavedAs','1');
     mMailbo.SetFieldValueAsInteger('SentState',1);
     mMailBO.SetFieldValueAsString('Body',ABody);
     mMailBO.SetFieldValueAsString('Firm_ID',AFirm_ID);
     mMailBO.SetFieldValueAsString('Division_ID',ADivision_ID);
     mMailBO.SetFieldValueAsString('BusTransaction_ID',ABusTransaction_ID);
     mMRecipients:=mMailBO.GetCollectionMonikerForFieldCode(mMailBO.GetFieldCode('Recipients'));

     mMailRecipient:=mMRecipients.AddNewObject;
     mMailRecipient.SetFieldValueAsString('Email',ATo);
     mMailRecipient.SetFieldValueAsInteger('EmailType',0);
     if not(acc='') then begin
     mMailRecipient:=mMRecipients.AddNewObject;
     mMailRecipient.SetFieldValueAsString('Email',ACC);
     mMailRecipient.SetFieldValueAsInteger('EmailType',1);
     end;
     if not(ABCC='') then begin
     mMailRecipient:=mMRecipients.AddNewObject;
     mMailRecipient.SetFieldValueAsString('Email',ABCC);
     mMailRecipient.SetFieldValueAsInteger('EmailType',2);
     end;

     if not(AAtachement='') then begin
      TNxEmailSent(mMailBO).AttachFile(AAtachement);

     end;

     if not(AAtachement2='') then begin
      TNxEmailSent(mMailBO).AttachFile(AAtachement2);

     end;



     mMailBO.Save;
     mMailBO.free;

  end;
end;

begin
end.