const
 cMailLogin='abra';
 cMailPassword='SLVrata561';
 cMailSMTP='posta.spedos.cz';
 cEmail='maler@spedos.cz';
 cMailFrom='abra@spedos.cz';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAct, mAct2: TBasicAction;
  mAlist:TActionList;
  i:Integer;
begin
  mAlist:=self.GetMainActionList;
  mAct := Self.GetNewAction;
  mAct.Caption := 'Export nabídky ND';
  mAct.Category := 'tabList';
  mAct.OnExecute := @ExportND;
end;

function GetDynSource (AOS : TNxCustomObjectSpace; AValue : string) : String;
const
  cSQL = 'SELECT DataSource FROM Reports WHERE ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [ AValue]), mList);
    if mList.Count > 0 then
      Result := (mList.Strings[0]);
  finally
    mList.Free;
  end;
end;

function GetDynSourceE (AOS : TNxCustomObjectSpace; AValue : string) : String;

const
  cSQL = 'SELECT DataSource FROM Exports WHERE ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [ AValue]), mList);
    if mList.Count > 0 then
      Result := (mList.Strings[0]);
  finally
    mList.Free;
  end;
end;

Procedure ExportND(Sender:TComponent);
var
 mSite:TSiteForm;
 mBO, mRowBO:TNxCustomBusinessObject;
 mExportList:tstringlist;
 mFileName, mTo,mDir, mfileName2,mDivision_ID,mBusOrder_id:string;
 mRows:TNxCustomBusinessMonikerCollection;
 i:integer;
begin
 msite:=TComponent(Sender).dynsite;
 mBO:=TDynSiteForm(mSite).CurrentObject;
 if Assigned(mBO) then begin
    if not(mbo.GetFieldValueAsString('Firm_ID.OrgIdentNumber') in ['31708587','27795357','27795152']) then begin
      NxShowSimpleMessage('Objednávka '+mbo.DisplayName+' není objednávka ND. Ukončuji.',mSite);
      exit;
    end;
    mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
    for i:=0 to mRows.count-1 do begin
      if i=0 then begin
        mDivision_ID:=mRows.BusinessObject[i].GetFieldValueAsString('Division_ID');
        mBusOrder_id:=mRows.BusinessObject[i].GetFieldValueAsString('BusOrder_ID');
      end;

    end;
    if NxMessageBox('Dotaz','Přejete si vyexportovat nabídku '+mbo.DisplayName+'?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
      mExportList:=TStringList.create;
      mExportList.add(mbo.OID);
      if mbo.GetFieldValueAsString('Firm_ID.OrgIdentNumber')='27795357' then begin
        mTo:='ndads@spedos.cz';
        mDir:='\\192.168.0.80\abradata\exchange\Nabidky\ADS\'
      end;
      if mbo.GetFieldValueAsString('Firm_ID.OrgIdentNumber')='31708587' then begin
        mTo:='ndsk@spedos.cz';
        mDir:='\\192.168.0.80\abradata\exchange\Nabidky\Slovensko\'
      end;
      if mbo.GetFieldValueAsString('Firm_ID.OrgIdentNumber')='27795152' then begin
        mTo:='ndvrata@spedos.cz';
        mDir:='\\192.168.0.80\abradata\exchange\Nabidky\Vrata\'
      end;
      mFileName:=NxSearchReplace(mbo.DisplayName,'/','-',[srall])+'.xml';
      mFileName2:=NxSearchReplace(mbo.DisplayName,'/','-',[srall])+'.pdf';
      CFxReportManager.ExportByIDs(NxCreateContext_1(mBO),mExportList,GetDynSourceE(mbo.ObjectSpace,'4NF0000101'),'4NF0000101',0,'',mDir+mFileName);
      CFxReportManager.PrintByIDs(NxCreateContext_1(mBO), mExportList, GetDynSource(mbo.ObjectSpace,'OU00000001'), 'OU00000001', rtoFile, pekPDF, NxGetTempDir, mFileName2);
      //export PDF do složky - Gajdoš
      if mbo.GetFieldValueAsString('Firm_ID.OrgIdentNumber')='27795152' then begin
      CFxReportManager.PrintByIDs(NxCreateContext_1(mBO), mExportList, GetDynSource(mbo.ObjectSpace,'OU00000001'), 'OU00000001', rtofile, pekPDF, mDir,mFileName2);
      end;
      //konec exportu do PDF
      try
      SendInternalMail(mBO.ObjectSpace, mTO,'',
                               'vyexportována nabídka '+mbo.DisplayName,'Byla vytvořena nová nabídka na náhradní díly.',
                               mDir+mFileName,NxGetTempDir+'\'+ mFileName2,mBO.GetFieldValueAsString('Firm_ID'),mDivision_ID,mBusOrder_id, '');
      except
        NxShowSimpleMessage('Něco se nepovedlo:'+#13#10+ExceptionMessage,mSite);
      end;
      //CFxInternet.SMSendMailWithMoreFiles(csOpenSSL,cMailLogin,cMailPassword,cMailSMTP,465,cMailFrom,mto,'','',
      // 'vyexportována objednávka '+mbo.DisplayName,'tady bude text',commAsText,NxGetTempDir+'\'+mFileName2);
      mbo.SetFieldValueAsBoolean('Issued',True);
      mbo.save;
      TDynSiteForm(mSite).ActiveDataSet.RefreshCurrentItem;
    end;
 end;
end;

procedure SendInternalMail(AOS:TNxCustomObjectSpace; ATo:String; ACC:String; ASubject:String; ABody:String; AAtachement, aAtachement2:String; AFirm_ID:String; ADivision_ID:String; ABusOrder_ID:String; AReplyTo:string;);
Var
  mMailBO:TNxCustomBusinessObject;
  mMRecipients:TNxCustomBusinessMonikerCollection;
  mMailRecipient:TNxCustomBusinessObject;
begin
  if not(ato='') then begin
     mMailBO:=AOS.CreateObject('5C1HWDQDR3J4NAAYZRO5PWHLWK');
     mMailBO.New;
     mMailBO.Prefill;
     mMailBO.SetFieldValueAsString('EmailAccount_ID','2100000101');
     mMailBO.SetFieldValueAsString('Subject',ASubject);
     mMailbo.SetFieldValueAsInteger('SentState',1);
     mMailBO.SetFieldValueAsInteger('BodySavedAs',1);
     mMailBO.SetFieldValueAsString('Body',ABody);
     mMailBO.SetFieldValueAsString('Firm_ID',AFirm_ID);
     mMailBO.SetFieldValueAsString('Division_ID',ADivision_ID);
     mMailBO.SetFieldValueAsString('BusOrder_ID',ABusOrder_ID);
     mMailBO.SetFieldValueAsString('ReplyTo',AReplyTo);
     mMRecipients:=mMailBO.GetCollectionMonikerForFieldCode(mMailBO.GetFieldCode('Recipients'));

     mMailRecipient:=mMRecipients.AddNewObject;
     mMailRecipient.SetFieldValueAsString('Email',ATo);
     mMailRecipient.SetFieldValueAsInteger('EmailType',0);
     if not(acc='') then begin
     mMailRecipient:=mMRecipients.AddNewObject;
     mMailRecipient.SetFieldValueAsString('Email',ACC);
     mMailRecipient.SetFieldValueAsInteger('EmailType',1);
     end;
     if not(AAtachement='') then begin
      if FileExists(AAtachement) then TNxEmailSent(mMailBO).AttachFile(AAtachement);

     end;
     if not(AAtachement2='') then begin
      if FileExists(AAtachement2) then TNxEmailSent(mMailBO).AttachFile(AAtachement2);

     end;




     mMailBO.Save;
     mMailBO.free;

  end;
end;
begin
end.