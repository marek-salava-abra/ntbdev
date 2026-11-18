uses '.lib';

{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
{
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction:= Self.GetNewMultiAction;
  mAction.Name:= 'actPLMWorkPlaceSync';
  mAction.Caption:= '##Synchronizovat do SK##';
  mAction.Items.Add('##Synchronizovat do SK##');
  mAction.Category:= 'tabList';
  mAction.OnExecuteItem:= @exePLMWorkPlaceSync;
end;
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction:= Self.GetNewAction;
  mAction.Name:= 'CreateObjectJSON';
  mAction.Caption:= '## Synchronizovat s SK ##';
  mAction.Category:= 'tabList';
  mAction.OnExecute:= @CreateObjectJSON;
end;


procedure exePLMWorkPlaceSync(Sender: TComponent);
var
  mSite: TSiteForm;
  mBO: TNxCustomBusinessObject;
  mOS: TNxCustomObjectSpace;
  mList, mParentsList, mChildrenList: TStringList;
  mResultStrc, mQuotedIDs, mResultStr: String;
  i: Integer;
begin
  mResultStr:= '';
  mSite:= Sender.Site;
  mOS:= mSite.BaseObjectSpace;
  mQuotedIDs:= '';
  mList:= TStringList.Create;
  mParentsList:= TStringList.Create;
  mChildrenList:= TStringList.Create;
  try
    mSite.FillListWithSelectedRows(mList);
    for i:= 0 to mList.Count -1 do begin
      mQuotedIDs:= mQuotedIDs + QuotedStr(mList[i]) + ',';
    end;
    mQuotedIDs:= NxLeft(mQuotedIDs, Length(mQuotedIDs) -1);

    mOS.SQLSelect('SELECT ID FROM PLMWorkPlaces WHERE ID in ('+mQuotedIDs+') AND X_Parent_ID IS NULL', mParentsList);
    mOS.SQLSelect('SELECT ID FROM PLMWorkPlaces WHERE ID in ('+mQuotedIDs+') AND X_Parent_ID IS NOT NULL', mChildrenList);
    mBO:= mOS.CreateObject(Class_PLMWorkPlace);
    try
      for i:= 0 to mList.Count -1 do begin
        mBO.Load(mList[i], nil);
        PLMWorkPlaceAPISync(mBO, mResultStr);
      end;
    finally
      mBO.Free;
    end;
    //NxShowSimpleMessage('Synchronizace proběhla u '+IntToStr(mList.Count)+' karet.'+nxCrLf+mResultStr, mSite);
  finally
    mList.Free;
    mParentsList.Free;
    mChildrenList.Free;
  end;
end;

begin
end.