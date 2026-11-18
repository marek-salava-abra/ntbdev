uses 'eu.cemat.mailVL.progress', 'eu.cemat.mailVL.mail';

const
 mReport_ID = '3BK1000101';

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
begin
 mSite:=TComponent(Sender).DynSite;
 mOS:=TDynSiteForm(mSite).BaseObjectSpace;
 mVLList:=TStringList.create;
 TDynSiteForm(mSite).List.GetSelectedId(mVLList);

 if mVLList.count>0 then begin
 if NxMessageBox('Dotaz','Přejete si odeslat '+IntToStr(mVLList.count)+' výplatních pásek?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin

   ProgressInit(mSite, 'Tisk do PDF a odesílání...', mVLList.Count);
           for i := 0 to mVLList.Count- 1 do begin
            mBO:=mOS.CreateObject(Class_WageListPartial);
            mBO.load(mVLList.Strings[i],nil);
            if mbo.GetFieldValueAsBoolean('Employee_ID.U_paska_emailem') then begin
              if NxIsValidEMail(mbo.GetFieldValueAsString('Employee_ID.U_email'),False) then begin
               if not(NxIsBlank(mbo.GetFieldValueAsString('Employee_ID.U_heslo'))) then begin
                mPrintList:=TStringList.create;
                mPrintList.Add(mbo.OID);
                mTempDir:=NxGetTempDir;
                mFileName:=NxSearchReplace(mbo.GetFieldValueAsString('WagePeriod_ID.Code'),'/','-',[srAll])+'-'+mbo.GetFieldValueAsString('Employee_ID.Person_ID.PersonalNumber');
                CFxReportManager.PrintByIDs(NxCreateContext(mOS), mPrintList, GetDynSource(mOS,mReport_ID), mReport_ID, rtoFile, pekPDF, mTempDir, mFileName + '.pdf');
                mPDFFileName:=mTempDir+'\'+mFileName+'.pdf';
                mzipFileName:=mTempDir+'\'+mFileName+'.zip';
                mZIP := TZipFile.Create;
                try
                mZIP.Open(mZipFileName, zfomWrite);
                  if (mbo.GetFieldValueAsString('Employee_ID.U_heslo') <> '') then mZIP.Password := mbo.GetFieldValueAsString('Employee_ID.U_heslo');
                  mZIP.AddFile(mPDFFileName);
                  mZIP.Close;
               finally
                //mZIP.Free;
               end;
                SendInternalMail(mOS,mbo.GetFieldValueAsString('Employee_ID.U_email'),
                           '','',
                           'Výplatní páska za '+mFileName,'Výplatní páska',mZipFileName, '',
                           '1000000101','');
                mPrintList.free;
                DeleteFile(mPDFFileName);
                DeleteFile(mZipFileName);
               end;
              end;
            end;
            mbo.Free;
          ProgressSetPos(i+1);
          end;
   ProgressDispose();
 end;
 NxShowSimpleMessage('Hotovo',mSite);
 end;
end;


begin
end.