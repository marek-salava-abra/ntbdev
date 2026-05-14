procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mUserFilter:Boolean;
  mUserFilterTL:string;
  muser:TNxCustomBusinessObject;
begin
    mUserFilter:=true;
    mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');
    try
      mUser.Load(Self.CompanyCache.GetUserID, nil);
            mUserFilter:= copy(mUser.GetFieldValueAsstring('X_Button_parametr'),11,1)='1';

    finally
      mUser.Free;
    end;
        if mUserFilter then begin
              mAction := Self.GetNewAction;
              mAction.ShowControl := True;
              mAction.ShowMenuItem := True;
              mAction.Name := 'actEditBOExtNO';
              mAction.Caption := 'Povolení editace';
              mAction.Hint := 'Opraví číslo dokladu tak , aby bylo možno editovat';
              mAction.Category := 'tabList';
              mAction.OnExecute := @MarkedForEdit;
        end;
end;

procedure MarkedForEdit(Sender: TComponent);
var
  mSite: TSiteForm;
  mOS: TNxCustomObjectSpace;
  mBO, mRowBO: TNxCustomBusinessObject;
  mList, mListToShow: TStringList;
  i,j: Integer;
  mRows:TNxCustomBusinessMonikerCollection;
  mSync:Boolean;
  mstring:string;
begin
  mSite:= Sender.Site;
  mOS:= mSite.BaseObjectSpace;
  mList:= TStringList.Create;
  mListToShow:= TStringList.Create;
  mstring:='';
  try
    TDynSiteForm(mSite).FillListWithSelectedRows(mList);
    if NxMessageBox('Uprava', 'Přejete si povolit editaci ('+IntToStr(mList.Count)+') dokladů?. Pozor doklady by neměly být synchronizovány v jiném systému.', mdConfirm, mdbYesNo, mrNo, nil, false, mSite) = mrYes then begin
      for i:= 0 to mList.Count -1 do begin
        //mBO:= mOS.CreateObject(Class_BillOfDelivery);
        mbo:=TDynSiteForm(mSite).CurrentObject;
        try
          mBO.Load(mList[i], nil);
          if true then begin
//             NxShowSimpleMessage(mbo.GetFieldValueAsString('X_ExternalDocument'),nil);
             mstring:=mbo.GetFieldValueAsString('X_ExternalDocument');
             mString:=NxSearchReplace(mString,'-','_',[srCase,srAll]);
             mString:=NxSearchReplace(mString,'/','_',[srCase,srAll]);
             if mstring<>mbo.GetFieldValueAsString('X_ExternalDocument') then begin
                   mbo.SetFieldValueAsString('X_ExternalDocument',mstring);
                   mbo.Save;
             end;
//            mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
//            for j:=0 to mRows.count-1 do begin
//              mRowBO:=mRows.BusinessObject[j];
//            end;
          end;
        finally
          mBO.Free;
        end;
      end;
    end;
  finally
    TDynSiteForm(mSite).ActiveDataSet.RefreshCurrentItem;
    TDynSiteForm(mSite).RefreshData;
    mList.Free;
    mListToShow.Free;
  end;
end;



begin
end.