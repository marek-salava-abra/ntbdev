

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
  mUser: TNxCustomBusinessObject;
  mC: TControl;
begin
  mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');            // přihlášený uživatel
  try
      mUser.Load(Self.CompanyCache.GetUserID, nil);
      //   if not(mUser.GetFieldValueAsBoolean('X_funkce_ctecky')) then begin
                mMAction := Self.GetNewMultiAction;
                mMAction.ShowControl := True;
                mMAction.ShowMenuItem := True;
                mMAction.Hint := '';
                mMAction.Caption := 'Nový DL bez vazby';
                mMAction.Items.Add('Objednávka přijatá');
                mMAction.Items.Add('Objednávka vydaná');
                mMAction.Items.Add('Příjemka');
                mMAction.Items.Add('Dodací list');
                mMAction.Items.Add('Převodly výdej');
                mMAction.Category := 'tabList';
                mMAction.OnExecuteItem := @NewDocClick;
      //   end;
   finally
      muser.free;
   end;
end;




function SQLSingleSelect(AOS: TNxCustomObjectSpace; ASQL: string; ALog: TStringList): string;
var
  mIDs: TStringList;
begin
  Result := '';

  if Assigned(AOS) and (ASQL <> '') then
  begin
    mIDs := TStringList.Create;
    try
      SQLMultiSelect(AOS, ASQL, mIDs, ALog);
      if mIDs.Count > 0 then
        Result := NxSearchReplace(mIDs.Strings[0], '"', '', [srAll]);
    finally
      mIDs.Free;
    end;
  end;
end;

procedure SQLMultiSelect(AOS: TNxCustomObjectSpace; ASQL: string; AIDs, ALog: TStringList);
begin
  try
    if Assigned(AIDs) and Assigned(AOS) and (ASQL <> '') then
      AOS.SQLSelect(ASQL, AIDs);
  except
    //WriteErrorLog(ALog, 'Nepodařilo se načíst data z databáze.' + #13#10 + #13#10 + ExceptionMessage);
  end;
end;





    function GetStoreDocQueueID(AOS: TNxCustomObjectSpace; AStoreID, AType: string; var ADocQueueID: string): Boolean;
begin
  Result := False;
  ADocQueueID := '';

  if not NxIsEmptyOID(AStoreID) then
  begin
    ADocQueueID := SQLSingleSelect(AOS, Format('Select SDQ.DocQueue_ID from StoresDocQueues SDQ left join docqueues DQ on dq.id=sdQ.DocQueue_ID where Store_id=%s and dq.Documenttype=%s' , [AStoreID, AType]), nil);
    Result := not NxIsEmptyOID(ADocQueueID);
  end;
end;









procedure NewDocClick(sender: TBasicAction;index: Integer);
var
  mBO_row : TNxCustomBusinessObject;
  i,ii,iii:integer;
  mSite: TSiteForm;
  mDBGrid : TDBGrid;
  mTabList: TTabSheet;
  mBookmark : TBookmarkList;
  Pot_zaznam : string;
  Xresult:Boolean;
  Pocet_zaznamu:integer;
  opakovani:integer;
  mStore_id:string;
  mDocQueue_ID:string;
  mHead : TNxHeaderBusinessObject;
  mRows,mMonBatchesSource,mMonBatchesTarget: TNxCustomBusinessMonikerCollection;
  mRow,mRowDocBatchSource,mRowDocBatchTarget: TNxCustomBusinessObject;
  magenda:string;
  mBO_CLSID:string;
  mlist:tstringlist;
  mtext:string;
  mText_doklad:string;
  mroll,mOle: Variant;
  _ss:TStrings;
  mDocumentType:string;
  mr:TStringList;
  mBoolean:boolean;
  mi:integer;

   mB_Result:boolean;

begin
    mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    mBO_Row := TDynSiteForm(mSite).CurrentObject;
   mtext:='nova sarže' + quotedstr('');

    mB_Result:=InputQuery('Zadaj parametry', 'Změna ', mtext);

                  if mBookmark.Count=0 then begin
                        if mB_Result then mi:=msite.BaseObjectSpace.SQLExecute('update DocRowBatches set StoreBatch_ID =' + quotedstr(mtext) + ' where id=' + QuotedStr(TDynSiteForm(mSite).CurrentObject.oid))  ;
                              //TBusRollSiteForm(msite).DataSet.RefreshCurrentItem;
                  end else begin
                          for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
                              mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                              if mB_Result then mi:=msite.BaseObjectSpace.SQLExecute('update DocRowBatches set StoreBatch_ID= ' + quotedstr(mtext) + ' where id=' + QuotedStr(TDynSiteForm(mSite).CurrentObject.oid)) ;
                              //TBusRollSiteForm(msite).DataSet.RefreshCurrentItem;
                          end;
                  end;

   end;





begin
end.














begin
end.