uses '_Knihovny_ALL.Progress','Folder.lib';

const
idPublic='2420000101';
idSecurity='3420000101';
id3='';




procedure OnExec(Sender: TComponent);       // přidělení objectspace a zadání zdrojového souboru
var
    mCustomBusinessObject: TNxCustomBusinessObject;
    mHeaderBusinessObject : TNxHeaderBusinessObject;
    i : integer;
    mResult:Boolean;
    zadej:string;
    mfilename:string;
    mDirPublic,mDirSecurity,mfile:string;
    mfilter:string;
  mSite: TSiteForm;
  mPerson : TNxCustomBusinessObject;
  mString: string;
   constStoragePath:string;
  mr:tstringlist;
begin



    if Sender is TComponent then begin
          mSite := NxFindSiteForm(TComponent(Sender));
          if Assigned(mSite) and (mSite is TBusRollSiteForm) then begin
               mCustomBusinessObject:= TBusRollSiteForm(mSite).CurrentObject;
               TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsDateTime('X_DocumentaceDate$date',Now);
               TBusRollSiteForm(mSite).CurrentObject.save;
               mDirPublic:='';
               mr:=tstringlist.create;
                try
                        mSite.BaseObjectSpace.SQLSelect('select max(Directory) from FileQueues where id='+ quotedstr(idPublic),mr);    // public
                        if mr.count=1 then begin
                              mDirPublic:= mr.Strings[0];
                              mresult:= GetOrCreativeDirAndFilles(mDirPublic,mCustomBusinessObject.oid,'');
                              //if mresult then GetOrCreativeDirAndFilles(format('%s\%s',[mDirPublic,mCustomBusinessObject.oid]),'Norma',mDirPublic + '\!Vzor\Norma');
                              if mresult then GetOrCreativeDirAndFilles(format('%s\%s',[mDirPublic,mCustomBusinessObject.oid]),'Manual','');
                              //if mresult then GetOrCreativeDirAndFilles(format('%s\%s',[mDirPublic,mCustomBusinessObject.oid]),'Dokumenty','');


                        end;
                finally
                    mr.free;
                end;

                mDirSecurity:='';
                mr:=tstringlist.create;
                try
                        mSite.BaseObjectSpace.SQLSelect('select max(Directory) from FileQueues where id='+ quotedstr(idSecurity),mr);    // public
                        if mr.count=1 then begin
                              mDirSecurity:= mr.Strings[0];
                              mresult:= GetOrCreativeDirAndFilles(mDirSecurity,mCustomBusinessObject.oid,'');
                              if mresult then GetOrCreativeDirAndFilles(format('%s\%s',[mDirSecurity,mCustomBusinessObject.oid]),'Norma',mDirSecurity + '\!Vzor\Norma');
                              //if mresult then GetOrCreativeDirAndFilles(format('%s\%s',[mDirSecurity,mCustomBusinessObject.oid]),'Manual','');
                              if mresult then GetOrCreativeDirAndFilles(format('%s\%s',[mDirSecurity,mCustomBusinessObject.oid]),'Dokumenty','');
                        end;
                finally
                    mr.free;
                end;

          end;
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
          mMAction.Hint := 'Změna dokumentace';
          mMAction.Caption := 'Změna dokumentace';
          mMAction.Items.Add('Změna dokumentace');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec;
{        end;}



end;


begin
end.