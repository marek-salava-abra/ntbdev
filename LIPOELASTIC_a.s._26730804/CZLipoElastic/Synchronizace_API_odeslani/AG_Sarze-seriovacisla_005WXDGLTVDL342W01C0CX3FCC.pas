  uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse',
      '_Knihovny_ALL.head',
      'NxApiLib.lib','_GlobalSettings.Konstanty';

var
  mSite : TDynSiteForm;
  mfilter:string;
    mDoklad : string;
  i,ii : integer;
  mres,mres1,mr2: TStringList;
  mID: String;
  aaaaa: string;
  x:integer;
  aa:Double;
  mrResult:string;
  mfirm,mfirm_office: TNxCustomBusinessObject;
  mrow: TNxCustomBusinessObject;
  mbusorder,mbustransaction,mbusproject,mbankacount: TNxCustomBusinessObject;
  maddress: TNxCustomBusinessObject;
  mhead: TNxHeaderBusinessObject;
  mID_Store,mID_StoreCard,mIDdoklad,mID_odberatel, mID_dodavatel, mID_Docqueue, mID_BusOrder,mID_Division, mID_VatCountry,mID_Country, mID_Currency,mID_Vatrate,mID_Row: string;
  aresult:Boolean;
  mexistuje:string;
  oprava : boolean;
  mMon : TNxCustomBusinessMonikerCollection;
   mForm : TForm;
  mBtn : TButton;
  mLbl : TLabel;
  mEdtIC, mEdtDIC,mEdtName,mEdtStreet,mEdtCity,mEdtPostCode,mEdtCountry : TEdit;
  cbSrcUnits, cbDstUnits, cbStores, cbDivisions : TEdit;
  mP1, mP2, mP3 : TPanel;
  mI_modalresult:integer;
  mS_code:string;
  mList,mRowList:TStringList;
  mtext:string;
  mID_kost_symbol,mID_payment,mID_delivery:string;
  mCountryName:string;
  mtoESL:boolean;



 procedure Synchronizace(Sender: TObject;index:integer);
var
  mSite: TSiteForm;
  mDBGrid : TDBGrid;
 mTabList: TTabSheet;
  mObj, mObj2: TNxCustomBusinessObject;
  mOLE, mRoll, mOResult: Variant;
  mid_reportx:tstringlist;
  mr,mr0:tstringlist;
  self:TNxCustomBusinessObject;
  mi:integer;
  mBookmark : TBookmarkList;
  mIBookmark:integer;
  mICount:integer;
  mids:string;
 aString:string;
  mstring:string;
  ARequest:string;

  mQuery,mQueryID:string;
  mID:string;
  mNewQueryID:string;
  mSQL:string;
  i,ii,iii,x:integer;
  mTarget:string;
 mr1:tstringlist;
 mMonRows:TNxCustomBusinessMonikerCollection;
 mMonBatches:TNxCustomBusinessMonikerCollection;
 mjson,mTargetJson,mQueryJson:TJSONSuperObject;
 mboolean:boolean;
 mNewQueryrow:string;
 mParseListValue:tstringlist;

begin
  mids:='';
  if Sender is TComponent then mSite := TComponent(Sender).Site;
    if not Assigned(mSite) then begin
         NxMessageBox('Chyba', 'Agenda nebyla dohledána', mdConfirm, mdbOkCancel, 0, 0, true, nil) ;
         nxbeep(btfailure);
         exit;
    end else begin
        mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
            if mTabList = nil then begin
                  RaiseException('tabList nenalezen');
                  NxMessageBox('Chyba', 'abList nenalezen', mdConfirm, mdbOkCancel, 0, 0, true, nil) ;
                  nxbeep(btfailure);
                  exit;
            end else begin
            mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
                if mDBGrid = nil then begin
                      RaiseException('DBGrid nenalezen');
                      NxMessageBox('Chyba', 'DBGrid nenalezen', mdConfirm, mdbOkCancel, 0, 0, true, nil) ;
                      nxbeep(btfailure);
                      exit;
                end else begin
                      mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
                      mIBookmark:=0;
                      if mBookmark.count>0 then begin
                           mIBookmark:=mBookmark.count-1;
                           ProgressInit(msite, 'Zpracování dat ' + '', 100);
                      end;
                      for mICount:=0 to mIBookmark do begin
                          if mBookmark.count>0 then begin
                               mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(mICount));
                               ProgressSetPos(1+NxFloor(mICount/mBookmark.Count*99), inttostr(mICount) +' z '+inttostr(mBookmark.Count));
                          end;
                          self:=TBusRollSiteForm(msite).CurrentObject;    // načtení objektu
                          if index=0 then mtarget:=mTargetAPI + '/';

                          mString:=APINxSQL_String(msite.BaseObjectSpace,mtarget,'SELECT','ExpirationDate$Date','StoreBatches','ID=' + quotedstr(self.OID));
                          NxShowSimpleMessage(mstring,nil);
                          //mString:=APINxSQL_String(msite.BaseObjectSpace,mtarget,'UPDATE','CreatedBy_ID=' + QuotedStr('SUPER00000'),'StoreDocuments','ID=' + quotedstr(self.OID));



                          if Assigned(mDBGrid) then mDBGrid.DataSource.DataSet.Refresh;

                      end;
                      if mBookmark.count>0 then ProgressDispose ();

                end;
            end;
    end;
end;



procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TAction;
  mMAction: TMultiAction;
begin
  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Test api';
  mMAction.Hint := 'Test api ';
  mMAction.Category := 'tabList';
  mMAction.Items.Add('Návrat json ');
  mMAction.Items.Add('Návrat SQL json ');
  mMAction.OnExecuteItem := @Synchronizace;

end;

begin
end.





