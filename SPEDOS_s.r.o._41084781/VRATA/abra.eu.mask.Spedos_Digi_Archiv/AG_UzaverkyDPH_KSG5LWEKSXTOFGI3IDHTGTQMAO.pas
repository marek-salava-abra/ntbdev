Var
    mSite: TSiteForm;
    mDBGrid : TDBGrid;
    mTabList: TTabSheet;
    mCustomBusinessObject: TNxCustomBusinessObject;

    mHeaderBusinessObject : TNxHeaderBusinessObject;
    i : integer;
    mResult:Boolean;
    mBookmarkList:TBookmarkList ;
    aid:string;

procedure _AfterSave_PostHook(Self: TDynSiteForm);
var
mi:integer;
begin
        mSite := self;
        mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
        if mTabList = nil then RaiseException('tabList nenalezen');
        mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
        if mDBGrid = nil then RaiseException('DBGrid nenalezen');
              //NxShowSimpleMessage(NxFloatToIBStr(TDynSiteForm(mSite).CurrentObject.GetFieldValueAsDateTime('DateFrom$DATE')),nil);

               mi:=msite.BaseObjectSpace.SQLExecute('update issuedinvoices set X_uzamceno=''A'' where DocDate$DATE>=' +
               NxFloatToIBStr(TDynSiteForm(mSite).CurrentObject.GetFieldValueAsDateTime('DateFrom$DATE')) +
               ' and DocDate$DATE<=' + NxFloatToIBStr(TDynSiteForm(mSite).CurrentObject.GetFieldValueAsDateTime('DateTo$DATE'))) ;








end;

begin
end.