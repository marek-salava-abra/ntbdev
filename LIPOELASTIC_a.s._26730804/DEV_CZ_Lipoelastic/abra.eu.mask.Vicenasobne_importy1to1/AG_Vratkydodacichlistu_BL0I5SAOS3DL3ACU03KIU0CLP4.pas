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
  if index=0 then mParam:= '@@DocumentType=60';

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




{
Vyvolává se po načtení vlastností formuláře.
}
procedure LoadingProperties_Hook(Self: TSiteForm; AParams: TNxParameters);
begin

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
  ii,j:integer;
  mmesage:string;
  mValidateList:tstringlist;
  mText:string;
  mMon:TNxCustomBusinessMonikerCollection;
begin
                if index=0 then mManager := NxCreateDocumentImportManager(self.ObjectSpace,'1T0I5SAOS3DL3ACU03KIU0CLP4','W402MSU3BBDL3ACR03KIU0CLP4');   // op to fv

                mParams := TNxParameters.Create();
                try
                  mManager.AddInputDocument(self.OID);
                  mParams.GetOrCreateParam(dtString, 'DocQueue_ID').AsString := mDocQueue_ID;


                  mManager.LoadParams(mParams);
                  mManager.Execute;
                  mManager.OutputDocument.SetFieldValueAsString('Firm_ID',mManager.InputDocument.GetFieldValueAsString('Firm_ID'));
                  mManager.OutputDocument.SetFieldValueAsString('FirmOffice_ID',mManager.InputDocument.GetFieldValueAsString('FirmOffice_ID'));
                  mManager.OutputDocument.SetFieldValueAsString('Person_ID',mManager.InputDocument.GetFieldValueAsString('Person_ID'));
                  mManager.OutputDocument.SetFieldValueAsString('Description',mManager.InputDocument.GetFieldValueAsString('Description'));



                   if not NxIsEmptyOID(tDynSiteForm(mSite).CurrentObject.getFieldValueAsString('Firm_ID.X_BankAcount')) then begin
                                      mManager.OutputDocument.SetFieldValueAsString('BankAccount_ID',mManager.OutputDocument.getFieldValueAsString('Firm_ID.X_BankAcount'))
                                  end else begin
                                      mManager.OutputDocument.SetFieldValueAsString('BankAccount_ID','3000000101')  ;
                                  end;
                                  if not NxIsEmptyOID(mManager.OutputDocument.getFieldValueAsString('Firm_ID.X_TransportationType_ID')) then begin
                                      mManager.OutputDocument.SetFieldValueAsString('TransportationType_ID',mManager.OutputDocument.getFieldValueAsString('Firm_ID.X_TransportationType_ID'))  ;
                                  end else begin
                                      mManager.OutputDocument.SetFieldValueAsString('TransportationType_ID','2H00000101')  ;
                                  end;


                                  if not NxIsEmptyOID(mManager.OutputDocument.getFieldValueAsString('Firm_ID.X_IntrastatDeliveryTerm_ID')) then begin
                                      mManager.OutputDocument.SetFieldValueAsString('IntrastatDeliveryTerm_ID',mManager.OutputDocument.getFieldValueAsString('Firm_ID.X_IntrastatDeliveryTerm_ID'))  ;
                                  end else begin
                                      mManager.OutputDocument.SetFieldValueAsString('IntrastatDeliveryTerm_ID','3001000000')  ;
                                  end;

                                  if not NxIsEmptyOID(mManager.OutputDocument.getFieldValueAsString('Firm_ID.X_IntrastatTransactionType_ID')) then begin
                                      mManager.OutputDocument.SetFieldValueAsString('IntrastatTransactionType_ID',mManager.OutputDocument.getFieldValueAsString('Firm_ID.X_IntrastatTransactionType_ID'))  ;
                                  end else begin
                                      mManager.OutputDocument.SetFieldValueAsString('IntrastatTransactionType_ID','1001000000')  ;
                                  end;

                                  if not NxIsEmptyOID(mManager.OutputDocument.getFieldValueAsString('Firm_ID.X_IntrastatTransportationType_')) then begin
                                      mManager.OutputDocument.SetFieldValueAsString('IntrastatTransportationType_ID',mManager.OutputDocument.getFieldValueAsString('Firm_ID.X_IntrastatTransportationType_'))  ;
                                  end else begin
                                      mManager.OutputDocument.SetFieldValueAsString('IntrastatTransportationType_ID','4000000000')  ;
                                  end;

                                  mMon := mManager.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mManager.OutputDocument.GetFieldCode('ROWS'));
                                    //ProgressInit(msite, 'Doplnění šarží ' , 100);
                                      for j:= 0 to mMon.count -1 do begin
                                    //       ProgressSetPos(1+NxFloor(j/mMon.count), inttostr(j) +' z '+inttostr(mMon.count));
                                                mMon.BusinessObject[j].SetFieldValueAsinteger('ESLStatus',0);
                                                mMon.BusinessObject[j].SetFieldValueAsstring('VATIndex_ID','7000000000');
                                      end;
                                    //  ProgressDispose();










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

                                             if index=0 then TDynSiteForm(mSite).ShowDynFormWithNewDocument('T1C2EX0BUJD13ACP03KIU0CLP4', TDynSiteForm(mSite).SiteContext, mManager.OutputDocument);  // fv
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
  mmAction.Hint := 'VDL to DF 1:1';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('Vytvoření Dobropisu Faktur vydaných');

  mmAction.OnExecuteItem:= @mSourceToTarget;



end;

begin
end.