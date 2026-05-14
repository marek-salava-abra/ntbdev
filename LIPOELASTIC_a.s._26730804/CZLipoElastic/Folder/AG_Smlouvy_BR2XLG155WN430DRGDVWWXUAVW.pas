uses '_Knihovny_ALL.Progress','Folder.lib';

const
idSecurity='4420000101';
id3='';





procedure OnExec(Sender: TAction; Index: integer);     // přidělení objectspace a zadání zdrojového souboru
var
    mCustomBusinessObject: TNxCustomBusinessObject;
    mHeaderBusinessObject : TNxHeaderBusinessObject;
    i : integer;
    mResult:Boolean;
    zadej:string;
    mfilename:string;
    mDirPublic,mDirSecurity,mfile:string;
    mfilter:string;
  mSite: TDynSiteForm;
  mDBGrid : TDBGrid;
 mTabList: TTabSheet;

  mPerson : TNxCustomBusinessObject;
  mString: string;
   constStoragePath:string;
  mr:tstringlist;

begin
             msite:=TComponent(Sender).DynSite;
                mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
                if mTabList = nil then RaiseException('tabList nenalezen');
                mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
                if mDBGrid = nil then RaiseException('DBGrid nenalezen');
                        mDirSecurity:='';
                        mr:=tstringlist.create;
                        try
                            mSite.BaseObjectSpace.SQLSelect('select max(Directory) from FileQueues where id='+ quotedstr(idSecurity),mr);    // public
                            if mr.count=1 then begin
                              mDirSecurity:= mr.Strings[0];
                              mresult:= GetOrCreativeDirAndFilles(mDirSecurity,TDynSiteForm(msite).CurrentObject.oid,'');
                            end;
                        finally
                            mr.free;
                        end;


end;




procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mMAction: TMultiAction;
  mCAction: TBasicAction;
  mAList: TActionList;
  i : integer;
  mUserFilter:Boolean;
  mUserFilterTL:string;
begin
    {mUserFilter:=true;
    mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');
    try
      mUser.Load(Self.CompanyCache.GetUserID, nil);
            mUserFilter:= mUser.GetFieldValueAsBoolean('ShortName');
            mUserFilterTL:= copy(mUser.GetFieldValueAsstring('ShortName'),1,1);
    finally
      mUser.Free;
    end;
        if (mUserFilterTL='S') or (mUserFilterTL='L')  then begin  }
          mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Založ adresář';
          mMAction.Caption := 'Založ adresář';
          mMAction.Items.Add('Založ adresář');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec;
{        end;}
end;


begin
end.