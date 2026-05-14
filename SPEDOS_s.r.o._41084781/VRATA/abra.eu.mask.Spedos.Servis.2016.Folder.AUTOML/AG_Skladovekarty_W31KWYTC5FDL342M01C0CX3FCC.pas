procedure OnExec(Sender: TComponent);       // přidělení objectspace a zadání zdrojového souboru
var
    mCustomBusinessObject: TNxCustomBusinessObject;
    mHeaderBusinessObject : TNxHeaderBusinessObject;
    i : integer;
    mResult:Boolean;
    zadej:string;
    mfilename:string;
    mdir,mfile:string;
    mfilter:string;
  mSite: TSiteForm;
  mPerson : TNxCustomBusinessObject;
  mString: string;
  mr:tstringlist;
  constStoragePath:string;
begin
    if Sender is TComponent then begin
          mSite := NxFindSiteForm(TComponent(Sender));
          if Assigned(mSite) and (mSite is TBusRollSiteForm) then begin
               mCustomBusinessObject:= TBusRollSiteForm(mSite).CurrentObject;
                constStoragePath:='';
                mr:=tstringlist.create;
                try
                        mSite.BaseObjectSpace.SQLSelect('select max(Directory) from FileQueues where id='+ quotedstr('1000000101'),mr);
                        if mr.count=1 then constStoragePath:=mr.Strings[0];
                finally
                    mr.free;
                end;




               try
                                  if DirectoryExists(Format('%s', [constStoragePath]))  then begin   // uloziste je pristupne
                                          mResult:=DirectoryExists(Format('%s\%s', [constStoragePath, mCustomBusinessObject.OID]));
                                          if  not mresult then begin    // servisovaný objekt
                                                  mResult:=NxCreateDir(Format('%s\%s', [constStoragePath, mCustomBusinessObject.OID]));
                                                  NxShowSimpleMessage('Úložiště je vytvořeno',nil);
                                          end else begin
                                                  NxShowSimpleMessage('Úložiště již existuje',nil);
                                          end;
                                  end;
                  finally
                  end;
           end;
    end;
end;



{
Vyvoláva sa po vykonaní inicializácie agendy/formulára. V tomto okamihu je už na formulári dostupný SiteContext.
}
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