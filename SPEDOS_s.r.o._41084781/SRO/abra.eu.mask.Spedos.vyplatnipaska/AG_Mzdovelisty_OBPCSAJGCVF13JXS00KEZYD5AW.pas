
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
ReportID,:STRING;

begin
ReportID:= '2K80000101';
AMailAccount:='mzdy_abra';
AMailFrom:='mzdy_abra@spedos.cz';
AMailPassword:='Vodafone9';
AServer:='posta.spedos.cz';
APort:='587';


    mSite := TComponent(Sender).DynSite;
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    mBO1 := TDynSiteForm(mSite).CurrentObject;

    if mBookmark.count=0 then begin
       try
        mPrintList:=tstringlist.create;
                mPrintList.Add(Format('%s', [TDynSiteForm(mSite).CurrentObject.OID]));

                          mto:=TDynSiteForm(msite).CurrentObject.GetFieldValueAsString('WorkingRelation_ID.Employee_ID.X_Email_paska');

                          AsubjectMail:='Výplatní páska '+TDynSiteForm(msite).CurrentObject.GetFieldValueAsString('WorkingRelation_ID.Employee_ID.Person_ID.FullName');
                          ABodyMail:='Vyplatni paska je prilozena jako priloha tohoto emailu';

                          if mto<>'' then begin
                          msoubor:= PrintDocument(TDynSiteForm(mSite).CurrentObject, ReportID);
                          CFxInternet.SMTPSendMailWithMoreFiles(1,AMailAccount, AMailPassword, AServer,
                   25, AMailFrom, mTo,'CAMFRLOVA@SPEDOS.CZ','' ,ASubjectMail, ABodyMail,1, mSoubor);







                          end;

          finally
                mPrintList.free;
          end;
    end else begin
       for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
                try
                mPrintList:=tstringlist.create;
                mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                mPrintList.Add(Format('%s', [TDynSiteForm(mSite).CurrentObject.OID]));

                          mto:=TDynSiteForm(msite).CurrentObject.GetFieldValueAsString('WorkingRelation_ID.Employee_ID.X_Email_paska');

                          AsubjectMail:='Výplatní páska '+TDynSiteForm(msite).CurrentObject.GetFieldValueAsString('WorkingRelation_ID.Employee_ID.Person_ID.FullName');
                          ABodyMail:='Vyplatni paska je prilozena jako priloha tohoto emailu';

                          if TDynSiteForm(msite).CurrentObject.GetFieldValueAsString('WorkingRelation_ID.Employee_ID.X_Email_paska')<>'' then begin
                          msoubor:= PrintDocument(TDynSiteForm(mSite).CurrentObject, ReportID);
                          CFxInternet.SMTPSendMailWithMoreFiles(1,AMailAccount, AMailPassword, AServer,
                    25, AMailFrom, mTo,'CAMFRLOVA@SPEDOS.CZ','' ,ASubjectMail, ABodyMail,1, mSoubor);

                          end;

                finally
                    mPrintList.free;
                end;
        end;;
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