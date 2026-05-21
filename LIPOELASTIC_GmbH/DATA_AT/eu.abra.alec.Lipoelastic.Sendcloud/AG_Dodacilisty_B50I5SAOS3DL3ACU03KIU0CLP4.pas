uses '.lib';
{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction:= Self.GetNewMultiAction;
  mAction.Name:= 'actSendcloud';
  mAction.Items.Add('## SC - Create parcel ##');
  mAction.Items.Add('Show PDM Issued documents');
  mAction.Caption:= '## SC - Create parcel ##';
  mAction.Category:= 'tabList';
  mAction.OnExecuteItem:= @SendcloudActions;
end;


procedure _CanDelete_Hook(Self: TDynSiteForm; var ACanDelete: Boolean);
var
  mPDMIssuedDoc_ID: string;
begin
  mPDMIssuedDoc_ID:= Self.BaseObjectSpace.SQLSelectFirstAsString('SELECT R.LeftSide_ID FROM Relations R WHERE R.REL_DEF = 1438 AND R.RightSide_ID = '+QuotedStr(Self.CurrentObject.OID));
  if not NxIsEmptyOID(mPDMIssuedDoc_ID) then
  begin
    ACanDelete:= False;
    NxShowSimpleMessage('Document cannot be deleted! This document is linked to sent mail (Sendcloud).', Self);
  end;
end;


procedure SendcloudActions(sender: TComponent; AIndex: Integer);
begin
  case AIndex of
    0: CreateParcelsForSelectedItems(Sender);
    1: ShowPDMDocsForSelectedDocuments(Sender);
  end;
end;


procedure CreateParcelsForSelectedItems(Sender: TComponent);
var
  mSite: TSiteForm;
  mOS: TNxCustomObjectSpace;
  mBO: TNxCustomBusinessObject;
  mList: TStringList;
  mJSON: TJSONSuperObject;
  mLog: string;
  i: Integer;
begin
  mSite:= Sender.Site;
  mOS:= mSite.BaseObjectSpace;

  mLog:= '';

  mList:= TStringList.Create;
  mJSON:= TJSONSuperObject.Create;
  try
    TDynSiteForm(mSite).FillListWithSelectedRows(mList);

    mBO:= mOS.CreateObject(Class_BillOfDelivery);
    try
      for i:= 0 to mList.Count -1 do
      begin
        mBO.Load(mList[i], nil);

        CreatePDMIssuedDoc(mBO, mLog);
      end;

    finally
      mBO.Free;
    end;

    //mJSON:= CreateParcelsBatch_JSON(mOS, mList, TDynSiteForm(mSite).CurrentObject.CLSID, mLog);
    //NxShowSimpleMessage(mJSON.AsString, mSite);

  if not NxIsBlank(mLog) then
    NxShowSimpleMessage(mLog, mSite)
  else
    NxShowSimpleMessage('Complete', mSite);

  finally
    mJSON.Free;
    mList.Free;
  end;
end;

procedure ShowPDMDocsForSelectedDocuments(Sender: TComponent);
var
  mSite: TSiteForm;
  mOS: TNxCustomObjectSpace;
  mList: TStringList;
begin
  mSite:= Sender.Site;
  mOS:= mSite.BaseObjectSpace;

  mList:= TStringList.Create;
  try
    TDynSiteForm(mSite).FillListWithSelectedRows(mList);
    if (mList.Count > 0) and (mList.Count < 1000) then
      ShowPDMIssuedDocs(mOS, 1438, mList, mSite);
  finally
    mList.Free;
  end;
end;


procedure ShowPDMIssuedDocs(AOS: TNxCustomObjectSpace; ARel_Def: integer; AList: TStringList; ASite: TSiteForm);
var
  mPDMDocsList: TStringList;
  i: Integer;
begin
  //adding quotes to the original list
  for i:= 0 to AList.Count -1 do
    AList[i]:= QuotedStr(AList[i]);

  mPDMDocsList:= TStringList.Create;
  try
    AOS.SQLSelect(Format(
      ' SELECT DISTINCT LeftSide_ID FROM Relations '+
      ' WHERE Rel_Def = %d '+
      ' AND RightSide_ID IN (%s) ',
      [ARel_Def, AList.CommaText]), mPDMDocsList);

    for i:= 0 to mPDMDocsList.Count -1 do
      mPDMDocsList[i]:= QuotedStr(mPDMDocsList[i]);

    if mPDMDocsList.Count > 0 then
    begin
      TDynSiteForm(ASite).ShowSite(Site_PDMIssuedDocs, true, Format('QueryByUserDynSQLCondition;A.ID in (%s);Doklady k: %s',[mPDMDocsList.CommaText, AList.Text]));
    end;
  finally
    mPDMDocsList.Free;
  end;
end;


begin
end.