uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse';

var
    result:boolean;
    mresult:boolean;
    mBookmark : TBookmarkList;
    mBustrasaction_ID:string;




function iSelectDocqueue(AOLE: Variant;mparam:string;) : TNxOID;
var
  mRoll : variant;
  mXX : string;
begin
  Result := '';
  mXX := '0000000000';
  mRoll := AOLE.GetRoll('W2XNBCJK3ZD13ACL03KIU0CLP4', 0);
  mRoll.Params.Add(mparam);
  Result := mRoll.SelectDialog2(False, mXX);
end;



function iSelectReport(mProgPoint:string) : TNxOID;
var
  mOLE, mRoll, mOResult: Variant;
begin
            mOLE:= GetAbraOLEApplication;
              mOResult:= mOLE.CreateStrings;
                  mRoll:=mOLE.GetRoll('4CQONRMN0ND13BYP02K2DBYMG4', 0);
                  mRoll.Params.Add('_PROGPOINT=' + mProgPoint);
                  mRoll.multiSelectDialog(False,mOResult) ;
                      result:=mOResult.text ;
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

function iPrintDocument(Obj:TNxCustomBusinessObject;ADynCLSID:string;ReportID:string;Acontext:TNxContext;mprintlist:TStrings;AName:string;Adir:string):string;
var
        mOLEApp: Variant;
        mCommand: Variant;
        mCond: Variant;
        FName:string;
        mbo: TNxCustomBusinessObject;
        mDynCLSID:string;
        mr:tstringlist;
begin
        if  NxIsBlank(trim(ADynCLSID)) then begin
            mr:=tstringlist.create;
            try
                 obj.ObjectSpace.SQLSelect('select DataSource from Reports where id=' + quotedstr(ReportID),mr);
                 if mr.count>0 then mDynCLSID := mr.Strings[0] ;
            finally
                mr.free;
            end;

       end else begin
            mDynCLSID:=ADynCLSID;
        end;

       { try
                mOLEApp := GetAbraOLEApplication;
                        mCommand := mOLEApp.CreateCustomCommand(mDynCLSID);  // ZL
                        mCond := mCommand.ConstraintByID('ID');
                        mCond.UsedKind := 1;
                        mCond.Value := QuotedStr(Obj.OID);
                mCommand.Execute;
        finally
        end;
        if not (mCommand.RowSets[0].EOF) then
                begin
                        FName:=GetFileNameBOLog(Obj,aname);
                        mCommand.Print(ReportID,8,adir,FName);

                end; }
                NxPrintByIDs(Acontext, mPrintList, mDynCLSID, ReportID, rtofile, pekpdf, adir, FName) ;
                result:=adir+FName;
end;

procedure mPrintToAll(Sender: TAction; Index: integer);
var
 mresult:Boolean;
 mtext:string;
 mbo:TNxCustomBusinessObject;
 mSite: TSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 self:TNxCustomBusinessObject;
 i,ii:integer;
  mr,mIDs_MLRow:TStringList;
   mForm: TDynSiteForm;
   mMon: TNxCustomBusinessMonikerCollection;
   mRow, mNewRow,mbo1: TNxCustomBusinessObject;
   mdate:Double;
   mdoc_number:string;
   mcount:integer;
   mfile:string;
   mpath:string;
   mBtn : TButton;
  mLbl : TLabel;
  cbStores : TComboBox;
  mRg : TRadioGroup;
  mRbS, mRbA : TRadioButton;
  mActualRow : TBookmark;
  mReport_ID:string;
  mmesage:string;
  mParam:string;
  mid_report:string;
  mOLE, mRoll, mOResult: Variant;
  mStringlist:tstringlist;
  mid:string;
  mfilename:string;
begin
  mparam:='';

  mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');

  mid_report:=iSelectReport('44V53DORW3DL342X01C0CX3FCC') ;

    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu

    if mid_report<>'' then begin

              if mBookmark.count=0 then begin
                         //mIportmanager(TDynSiteForm(mSite).CurrentObject,mDocQueue_ID);
                          mStringlist:=TStringList.create;
                                       try
                                            mStringlist.Add(TDynSiteForm(mSite).CurrentObject.oid);
                                            mfilename:=Format('%s_%s_%s_', [TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_id.code'),
                                                     inttostr(TDynSiteForm(mSite).CurrentObject.GetFieldValueAsInteger('Ordnumber')),
                                                     TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Period_id.code'),
                                                     ]);

                                            mid:=iPrintDocument(TDynSiteForm(mSite).CurrentObject,'',mid_report,NxCreateContext(msite.BaseObjectSpace),mStringlist,mfilename,'c:\A');
                                       finally
                                          mStringlist.free;
                                       end;
              end else begin
                   ProgressInit(msite, 'Zpracování souboru ' + '', 100);
                   for i := 0 to mBookmark.Count- 1 do begin
                                    ProgressSetPos(1+NxFloor(i/mBookmark.Count*99), inttostr(i) +' z '+inttostr(mBookmark.Count));
                                    mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                                    mStringlist:=TStringList.create;
                                       try
                                            mStringlist.Add(TDynSiteForm(mSite).CurrentObject.oid);
                                            mfilename:=Format('%s_%s_%s_%s', [TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_id.code'),
                                                     inttostr(TDynSiteForm(mSite).CurrentObject.GetFieldValueAsInteger('Ordnumber')),
                                                     TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Period_id.code'),
                                                     TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Varsymbol'),
                                                     ]);


                                            mid:=iPrintDocument(TDynSiteForm(mSite).CurrentObject,'',mid_report,NxCreateContext(msite.BaseObjectSpace),mStringlist,mfilename,'c:\A');
                                       finally
                                          mStringlist.free;
                                       end;
                   end;
                   ProgressDispose()   ;
              end;


             NxShowSimpleMessage('Bylo vytvořeno  ' + inttostr(mBookmark.Count) + ' doklad(ů)' ,nil) ;


          end;
end;




procedure mSourceToTarget(Sender: TAction; Index: integer);
var
 mresult:Boolean;
 mtext:string;
 mbo:TNxCustomBusinessObject;
 mSite: TSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 self:TNxCustomBusinessObject;
 i,ii:integer;
  mr,mIDs_MLRow:TStringList;
   mForm: TDynSiteForm;
   mMon: TNxCustomBusinessMonikerCollection;
   mRow, mNewRow,mbo1: TNxCustomBusinessObject;
   mdate:Double;
   mdoc_number:string;
   mcount:integer;
   mfile:string;
   mpath:string;
   mBtn : TButton;
  mLbl : TLabel;
  cbStores : TComboBox;
  mRg : TRadioGroup;
  mRbS, mRbA : TRadioButton;
  mActualRow : TBookmark;
  mDocQueue_ID:string;
  mmesage:string;
  mParam:string;
begin
  mparam:='';
  if index=0 then mParam:= '@@DocumentType=03';
  if index=1 then mParam:= '@@DocumentType=21';
  if index=2 then mParam:= '@@DocumentType=22';
  if index=3 then mParam:= '@@DocumentType=10';
  if index=4 then mParam:= '@@DocumentType=IO';

  mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu

    mDocQueue_ID:='';
    mDocQueue_ID := iSelectDocqueue(mSite.GetAbraOLEApplication,mParam);
    if mDocQueue_ID<>'' then begin
              mr:=TStringList.create;
              try
                       msite.BaseObjectSpace.SQLSelect('select code from DocQueues where id=' + QuotedStr(mDocQueue_ID),mr);
                       if mr.count>0 then mmesage:=mr.Strings[0] + '-';

              finally
                 mr.free;
              end;
              if mBookmark.count=0 then begin
                         //mIportmanager(TDynSiteForm(mSite).CurrentObject,mDocQueue_ID);
                         mmesage:=mmesage + ', ' + mIportmanager(TDynSiteForm(mSite),TDynSiteForm(mSite).CurrentObject,mDocQueue_ID,index);
              end else begin
                   ProgressInit(msite, 'Zpracování souboru ' + '', 100);
                   for i := 0 to mBookmark.Count- 1 do begin
                                    ProgressSetPos(1+NxFloor(i/mBookmark.Count*99), inttostr(i) +' z '+inttostr(mBookmark.Count));
                                    mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));

                                    mmesage:=mmesage + ', ' + mIportmanager(TDynSiteForm(mSite),TDynSiteForm(mSite).CurrentObject,mDocQueue_ID,index);
                   end;
                   ProgressDispose()   ;
              end;


             NxShowSimpleMessage('Byl vytvořen doklad(y)' + mmesage + '/' + TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Period_id.Code')
                            ,nil) ;


          end;
end;





function mIportmanager(mSite:tdynsiteform;Self: TNxCustomBusinessObject;mDocQueue_ID:string;index:integer):string;
Var
mresult:Boolean;
mOP_ID: string;
  mParams, mP : TNxParameters;
  mPar : TNxParameter;
  mManager : TNxDocumentImportManager ;
  mRow,mbo, mRow_OP, mOP : TNxCustomBusinessObject;
  mRows, mRows_OP : TNxCustomBusinessMonikerCollection;
  ii:integer;
  mmesage:string;
  mValidateList:tstringlist;
  mText:string;
begin
                if index=0 then mManager := NxCreateDocumentImportManager(self.ObjectSpace,'01CPMINJW3DL342X01C0CX3FCC','O3BDOKTWEFD13ACM03KIU0CLP4');   // op to fv
                if index=1 then mManager := NxCreateDocumentImportManager(self.ObjectSpace,'01CPMINJW3DL342X01C0CX3FCC','050I5SAOS3DL3ACU03KIU0CLP4');   // op to dl
                if index=2 then mManager := NxCreateDocumentImportManager(self.ObjectSpace,'01CPMINJW3DL342X01C0CX3FCC','0P0I5SAOS3DL3ACU03KIU0CLP4');   // op to prv
                if index=3 then mManager := NxCreateDocumentImportManager(self.ObjectSpace,'01CPMINJW3DL342X01C0CX3FCC','CDMK5QAWZZDL342X01C0CX3FCC');   // op to ov
                if index=4 then mManager := NxCreateDocumentImportManager(self.ObjectSpace,'01CPMINJW3DL342X01C0CX3FCC','WEN033MLM3DL35J301C0CX3F40');   // op to zl

                mParams := TNxParameters.Create();
                try
                  mManager.AddInputDocument(self.OID);
                  mParams.GetOrCreateParam(dtString, 'DocQueue_ID').AsString := mDocQueue_ID;


                  mManager.LoadParams(mParams);
                  mManager.Execute;
                  mManager.OutputDocument.SetFieldValueAsString('Description',mManager.InputDocument.GetFieldValueAsString('Description'));


                   if index=0 then mManager.OutputDocument.SetFieldValueAsString('StoreDocQueue_ID','8A10000101');
                   if index=3 then mManager.OutputDocument.SetFieldValueAsString('U_PrintLink',mManager.InputDocument.GetFieldValueAsString('U_PrintLink'));

                  //mManager.OutputDocument.SetFieldValueAsDateTime('DocDate$DATE', mDate);
                  //mRows := mManager.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mManager.OutputDocument.GetFieldCode('Rows'));
                  //for ii:=0 to mRows.Count-1 do begin
                  //    mRows.BusinessObject[ii].SetFieldValueAsstring('Store_ID',0);
                  //end;



                            mManager.OutputDocument.ClearValidateErrors;
                                      if Not mManager.OutputDocument.Validate() then begin
                                            mValidateList := TStringList.Create;
                                            try
                                               mManager.OutputDocument.GetValidateErrors(mValidateList);
                                               mText := mValidateList.Text;
                                               NxToken(mText, '=');
                                               MessageDlg('Automaticky vytvořený doklad nelze uložit z těchto důvodů:' + #13#10 + mText,

                                               mtWarning, [mbOK], 0);
                                             finally
                                               mValidateList.Free;
                                             end;
                                             //NxShowSimpleMessage('Chyba',nil);

                                             if index=0 then TDynSiteForm(mSite).ShowDynFormWithNewDocument('PLC2EX0BUJD13ACP03KIU0CLP4', TDynSiteForm(mSite).SiteContext, mManager.OutputDocument);  // fv
                                             if index=1 then TDynSiteForm(mSite).ShowDynFormWithNewDocument('B50I5SAOS3DL3ACU03KIU0CLP4', TDynSiteForm(mSite).SiteContext, mManager.OutputDocument);  // dl
                                             if index=2 then TDynSiteForm(mSite).ShowDynFormWithNewDocument('BD0I5SAOS3DL3ACU03KIU0CLP4', TDynSiteForm(mSite).SiteContext, mManager.OutputDocument);   // prv
                                             if index=3 then TDynSiteForm(mSite).ShowDynFormWithNewDocument('S4RQ0AMDM3DL35J301C0CX3F40', TDynSiteForm(mSite).SiteContext, mManager.OutputDocument);   // zl
                                             if index=4 then TDynSiteForm(mSite).ShowDynFormWithNewDocument('GF53HAH3WBDL3C5P00CA141B44', TDynSiteForm(mSite).SiteContext, mManager.OutputDocument);    // ov

                                             result:='Chyba';
                                      end else begin
                                          mManager.OutputDocument.Save;
                                           //NxShowSimpleMessage('Doklad uložen',nil);
                                      end;


                  result:= inttostr(mManager.OutputDocument.GetFieldValueAsInteger('Ordnumber'));



                 finally
                  mManager.Free;
                  mParams.free;
                 end;


end;



procedure InitSite_Hook(Self: TSiteForm);
var
mAction: TAction;
  mMAction: TMultiAction;
  mUserFilter: Boolean;
  mUser: TNxCustomBusinessObject;
begin
  mUserFilter:=false;
  mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');            // přihlášený uživatel
  try
      mUser.Load(Self.CompanyCache.GetUserID, nil);
            if mUser.GetFieldValueAsString('Name')='Supervisor' then mUserFilter:= true;
  finally
    mUser.Free;
  end;
  mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := 'Vícenásobný import dokladu 1:1';
  mmAction.Hint := 'OP to OV 1:1';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('Vytvoření Faktur vydaných');
  mMAction.Items.Add('Vytvoření Dodacího listu');
  mMAction.Items.Add('Vytvoření Převodky výdej');
  mMAction.Items.Add('Vytvoření Zálohových listů');
  mMAction.Items.Add('Vytvoření Objednávek vydaných');
  mmAction.OnExecuteItem:= @mSourceToTarget;



  mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := 'Vícenásobný Tisk/export dokladu';
  mmAction.Hint := 'Tisk/export po jednotlivém záznamu do více souborů';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('Tisk');
  mMAction.Items.Add('Export');

  mmAction.OnExecuteItem:= @mPrintToAll;



end;

begin
end.