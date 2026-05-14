
procedure InitSite_Hook(Self: TSiteForm);
var
  mMAction: TMultiAction;
  mAction: TBasicAction;
  mAList: TActionList;
  i: integer;
  mAct: TBasicAction;
  mUser : TNxCustomBusinessObject;
begin
  if not Assigned(Self.BaseObjectSpace) then
    exit;

  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Hint := 'Hromadný email';
  mMAction.Caption := 'Email';
  mMAction.Items.Add('Email');
  mMAction.Category := 'tabList';
  mMAction.OnExecuteItem := @MultiPrintOnExecute;
end;


procedure MultiprintOnExecute(Sender: TAction; Index: integer);
var
 mresult:Boolean;
 mtext:string;
 mImportMan:TNxDocumentImportManager;
 mbo:TNxCustomBusinessObject;
 mSite: TDynSiteForm;
  mDBGrid : TDBGrid;
    mTabList: TTabSheet;
  self:TNxCustomBusinessObject;
  i,ii:integer;
  mr,mIDs_MLRow:TStringList;
   mForm: TDynSiteForm;
   mMon: TNxCustomBusinessMonikerCollection;
   mRow, mNewRow,mbo1: TNxCustomBusinessObject;
   mdate:Double;
  mBookmark : TBookmarkList;
    mPrintList, mIDs : TStrings;
      mParamStr, mSoubor, ASubjectMail, Abodymail, mTo, AMailFrom, AMailAccount,AMailPassword,AServer,APORT : string;
  mPrintNotify,mPaska : TNxCustomBusinessObject;
ReportID:STRING;
mOS:TNxCustomObjectSpace;

begin
ReportID:= '2K80000101';
AMailAccount:='petrnkova@spedos.cz';
AMailFrom:='petrnkova@spedos.cz';
AMailPassword:='Faktury139-';
AServer:='posta.spedos.cz';
APort:='587';


    mSite := TComponent(Sender).DynSite;
    mOS:=msite.BaseObjectSpace;
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    mBO1 := TDynSiteForm(mSite).CurrentObject;

    if mBookmark.count=0 then begin
       try
        //mPrintList:=tstringlist.create;
               // mPrintList.Add(Format('%s', [TDynSiteForm(mSite).CurrentObject.OID]));
                          ReportID:= '2EB0000101';
                          if not NxIsEmptyOID(TDynSiteForm(msite).CurrentObject.GetFieldValueAsString('X_Print_id')) then ReportID:= TDynSiteForm(msite).CurrentObject.GetFieldValueAsString('X_Print_id');
                          mto:=TDynSiteForm(msite).CurrentObject.GetFieldValueAsString('Firm_ID.ElectronicAddress_ID.EMail');
                          //mto:='Martin.skacel@abra.eu';
                          AsubjectMail:='Faktura '+ TDynSiteForm(msite).CurrentObject.GetFieldValueAsString('Description');
                          ABodyMail:='Doklad je priložen jako příloha tohoto emailu';
                          mPrintList:=TStringList.create;
                          mPrintList.add(TDynSiteForm(msite).CurrentObject.OID);
                          mSoubor:=GetFileNameBO(TDynSiteForm(mSite).CurrentObject);
                          if mto<>'' then begin
                          //msoubor:= PrintDocument(TDynSiteForm(mSite).CurrentObject, ReportID);
                          CFxReportManager.PrintByIDs(NxCreateContext(mOS),mPrintList,GetDynSource(mOS,ReportID),ReportID,rtoFile,pekPDF,NxGetTempDir,mSoubor);
                          //msoubor:='\\192.168.0.80\abradata\Archiv\SRO\'+TDynSiteForm(msite).CurrentObject.GetFieldValueAsString('Period_ID.Code')+'\'+TDynSiteForm(msite).CurrentObject.GetFieldValueAsString('DocQueue_ID.Code') +'\'+
                          //
                          //            inttostr(TDynSiteForm(msite).CurrentObject.GetFieldValueAsInteger('Ordnumber'))+'_'+TDynSiteForm(msite).CurrentObject.GetFieldValueAsString('Docqueue_id.code')+'_'+
                          //            TDynSiteForm(msite).CurrentObject.GetFieldValueAsString('Period_id.code')+'_'+TDynSiteForm(msite).CurrentObject.GetFieldValueAsString('varsymbol')+'.pdf'     ;

                          //CFxInternet.SMTPSendMailWithMoreFiles(1,AMailAccount, AMailPassword, AServer,
                          //25, AMailFrom, mTo,'petrnkova@spedos.CZ','' ,ASubjectMail, ABodyMail,1, NxGetTempDir+'\'+mSoubor);
                          SendInternalMail(mOS,mTo,'petrnkova@spedos.cz',ASubjectMail,Abodymail,mSoubor,'','','','','');
                          mPrintList.Free;







                          end;

          finally
                //mPrintList.free;
          end;
    end else begin
       for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
                try

                mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                //mPrintList:=tstringlist.create;
                //mPrintList.Add(Format('%s', [TDynSiteForm(mSite).CurrentObject.OID]));
                ReportID:= '2EB0000101';
                          if not NxIsEmptyOID(TDynSiteForm(msite).CurrentObject.GetFieldValueAsString('X_Print_id')) then ReportID:= TDynSiteForm(msite).CurrentObject.GetFieldValueAsString('X_Print_id');


                          mto:=TDynSiteForm(msite).CurrentObject.GetFieldValueAsString('Firm_ID.ElectronicAddress_ID.EMail');
                          //mto:='Martin.skacel@abra.eu';
                          AsubjectMail:='Faktura '+ TDynSiteForm(msite).CurrentObject.GetFieldValueAsString('Description');
                          ABodyMail:='Doklad je priložen jako příloha tohoto emailu';
                          mPrintList:=TStringList.create;
                          mPrintList.add(TDynSiteForm(msite).CurrentObject.OID);
                          if mto<>'' then begin
                          mSoubor:=GetFileNameBO(TDynSiteForm(mSite).CurrentObject);
                          //msoubor:= PrintDocument(TDynSiteForm(mSite).CurrentObject, ReportID);
                          CFxReportManager.PrintByIDs(NxCreateContext(mOS),mPrintList,GetDynSource(mOS,ReportID),ReportID,rtoFile,pekPDF,NxGetTempDir,mSoubor);
                         // msoubor:='\\192.168.0.80\abradata\Archiv\SRO\'+TDynSiteForm(msite).CurrentObject.GetFieldValueAsString('Period_ID.Code')+'\'+TDynSiteForm(msite).CurrentObject.GetFieldValueAsString('DocQueue_ID.Code') +'\'+
                         //
                         //             inttostr(TDynSiteForm(msite).CurrentObject.GetFieldValueAsInteger('Ordnumber'))+'_'+TDynSiteForm(msite).CurrentObject.GetFieldValueAsString('Docqueue_id.code')+'_'+TDynSiteForm(msite).CurrentObject.GetFieldValueAsString('Period_id.code')+'_'+TDynSiteForm(msite).CurrentObject.GetFieldValueAsString('varsymbol')+'.pdf'           ;

                          //CFxInternet.SMTPSendMailWithMoreFiles(1,AMailAccount, AMailPassword, AServer,
                          //25, AMailFrom, mTo,'petrnkova@spedos.CZ','' ,ASubjectMail, ABodyMail,1, NxGetTempDir+'\'+mSoubor);
                          SendInternalMail(mOS,mTo,'petrnkova@spedos.cz',ASubjectMail,Abodymail,mSoubor,'','','','','');
                          mPrintList.free;







                          end;

          finally
                //mPrintList.free;
          end;

        end;;
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
     mMailBO.SetFieldValueAsString('EmailAccount_ID','1110000101');
     mMailBO.SetFieldValueAsString('Subject',ASubject);
     mMailbo.SetFieldValueAsInteger('SentState',1);
     mMailBO.SetFieldValueAsInteger('BodySavedAs',1);
     mMailBO.SetFieldValueAsString('Body',ABody);
     mMailBO.SetFieldValueAsString('Firm_ID',AFirm_ID);
     if not(NxIsEmptyOID(ADivision_ID))then mMailBO.SetFieldValueAsString('Division_ID',ADivision_ID);
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



function GetFileNameBO(mBO:TNxCustomBusinessObject):string;
var s:string;
begin
s:=mBO.GetFieldValueAsString('DisplayName');
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
function PrintDocument(Obj:TNxCustomBusinessObject;ReportID:string):string;
var DynCLSID:string;
  mOLEApp: Variant;
  mCommand: Variant;
  mCond: Variant;
  FName:string;
begin

DynCLSID:=Obj.DefaultDynSourceID;
mOLEApp := GetAbraOLEApplication;
mCommand := mOLEApp.CreateCustomCommand(DynCLSID);  // ZL
mCond := mCommand.ConstraintByID('ID');
mCond.UsedKind := 1;
mCond.Value := QuotedStr(Obj.OID);
mCommand.Execute;
if not (mCommand.RowSets[0].EOF) then
        begin
        FName:=GetFileNameBO(Obj);
        mCommand.Print(ReportID,8,NxGetTempDir,FName);
        end;

result:=NxGetTempDir+FName;
end;


begin
end.