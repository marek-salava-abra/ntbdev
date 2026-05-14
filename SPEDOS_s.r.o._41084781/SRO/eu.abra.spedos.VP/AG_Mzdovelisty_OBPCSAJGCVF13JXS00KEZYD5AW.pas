uses '.progress', '.mail';

procedure InitSite_Hook(Self: TSiteForm);
var
  mBut, mBut2: TBasicAction;
  mUser:TNxCustomBusinessObject;
begin
  if not Assigned(Self.BaseObjectSpace) then
    exit;
mBut:= Self.GetNewAction;
mBut.ShowControl := True;
mBut.ShowMenuItem := True;
mBut.Caption := 'Výplatní pásky emailem';
mBut.Category := 'tabList';
mBut.OnExecute := @SendEmailVL;

end;

Procedure SendEmailVL(Sender:TComponent);
var
 mSite:TSiteForm;
 mBO:TNxCustomBusinessObject;
 mOS:TNxCustomObjectSpace;
 mVLList, mPrintList:TStringList;
 i:integer;
 mPDFFileName, mZipFileName: string;
 mZIP: TZipFile;
 mTempDir:String;
 mFileName:String;
 mReport_ID, mDivision_ID:string;
begin
 mSite:=TComponent(Sender).DynSite;
 mOS:=TDynSiteForm(mSite).BaseObjectSpace;
 mVLList:=TStringList.create;
 TDynSiteForm(mSite).List.GetSelectedId(mVLList);
 mReport_ID:='2K80000101';
 mDivision_ID:='O000000101';
 if mVLList.count>0 then begin
 if NxMessageBox('Dotaz','Přejete si odeslat '+IntToStr(mVLList.count)+' výplatních pásek?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin

   ProgressInit(mSite, 'Tisk do PDF a odesílání...', mVLList.Count);
      try
           for i := 0 to mVLList.Count- 1 do begin
            mBO:=mOS.CreateObject(Class_WageListPartial);
            mBO.load(mVLList.Strings[i],nil);
           // if mbo.GetFieldValueAsBoolean('Employee_ID.U_paska_emailem') then begin
              if NxIsValidEMail(mbo.GetFieldValueAsString('Employee_ID.X_Email_paska'),False) then begin
               if not(NxIsBlank(mbo.GetFieldValueAsString('Employee_ID.X_heslo'))) then begin
                mPrintList:=TStringList.create;
                mPrintList.Add(mbo.OID);
                mTempDir:=NxGetTempDir;
                mFileName:=NxSearchReplace(mbo.GetFieldValueAsString('WagePeriod_ID.Code'),'/','-',[srAll]);
                CFxReportManager.PrintByIDs(NxCreateContext(mOS), mPrintList, GetDynSource(mOS,mReport_ID), mReport_ID, rtoFile, pekPDF, mTempDir, mFileName + '.pdf');
                mPDFFileName:=mTempDir+'\'+mFileName+'.pdf';
                mzipFileName:=mTempDir+'\'+mFileName+'_secure.pdf';
                if FileExists(mPDFFileName) then DeleteFile(mPDFFileName);
                if FileExists(mzipFileName) then DeleteFile(mzipFileName);
                NxExecFile('\\192.168.0.80\abra_gen\PDFtk\bin\Pdftk.exe'+ ' "' + mPDFFileName + '" output "' + mZipFileName + '" ' + 'encrypt_128bit user_pw '+mbo.GetFieldValueAsString('Employee_ID.X_heslo'), True, True, True);
                SendInternalMail(mOS,mbo.GetFieldValueAsString('Employee_ID.X_Email_paska'),
                           '','',
                           'Výplatní páska za '+mFileName,'Výplatní páska',mZipFileName, '',
                           mDivision_ID,'');
                mPrintList.free;
                DeleteFile(mPDFFileName);
                DeleteFile(mZipFileName);
               end;
               if (NxIsBlank(mbo.GetFieldValueAsString('Employee_ID.X_heslo'))) then begin
                mPrintList:=TStringList.create;
                mPrintList.Add(mbo.OID);
                mTempDir:=NxGetTempDir;
                mFileName:=NxSearchReplace(mbo.GetFieldValueAsString('WagePeriod_ID.Code'),'/','-',[srAll]);
                CFxReportManager.PrintByIDs(NxCreateContext(mOS), mPrintList, GetDynSource(mOS,mReport_ID), mReport_ID, rtoFile, pekPDF, mTempDir, mFileName + '.pdf');
                mPDFFileName:=mTempDir+'\'+mFileName+'.pdf';

                SendInternalMail(mOS,mbo.GetFieldValueAsString('Employee_ID.X_Email_paska'),
                           '','',
                           'Výplatní páska za '+mFileName,'Výplatní páska je zaheslována heslem (výchozí heslo je část rodného čísla za lomítkem)',mPDFFileName, '',
                           mDivision_ID,'');
                mPrintList.free;
                DeleteFile(mPDFFileName);
               end;
              end;
           // end;
            mbo.Free;
          ProgressSetPos(i+1);
          end;
      Except
       ProgressDispose();
      end;
   ProgressDispose();
 end;
 NxShowSimpleMessage('Hotovo',mSite);
 end;
end;


begin
end.