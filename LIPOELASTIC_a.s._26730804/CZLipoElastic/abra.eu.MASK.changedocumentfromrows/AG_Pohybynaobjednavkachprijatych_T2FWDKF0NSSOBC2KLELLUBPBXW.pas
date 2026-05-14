

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
      // if not(mUser.GetFieldValueAsBoolean('X_funkce_ctecky')) then begin
                mMAction := Self.GetNewMultiAction;
                mMAction.ShowControl := True;
                mMAction.ShowMenuItem := True;
                mMAction.Hint := '';
                mMAction.Caption := 'Změna dokumentu';
                mMAction.Items.Add('Změna dokumentu');
                mMAction.Category := 'tabList';
                mMAction.OnExecuteItem := @ChangedocumentClick;

         {
                mMAction := Self.GetNewMultiAction;
                mMAction.ShowControl := True;
                mMAction.ShowMenuItem := True;
                mMAction.Hint := '';
                mMAction.Caption := 'Nová OV3';
                mMAction.Items.Add('Vytvoření nové OV3 customize');
                mMAction.Category := 'tabList';
                mMAction.OnExecuteItem := @NewOVClick;
         end;  }
   finally
      muser.free;
   end;
end;




procedure ChangedocumentClick(sender: TBasicAction;index: Integer);
var
  mBO_row : TNxCustomBusinessObject;
  i:integer;
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
  mHead1: TNxCustomBusinessObject;
  mHead : TNxHeaderBusinessObject;
  mRows: TNxCustomBusinessMonikerCollection;
  mRow: TNxCustomBusinessObject;
  mi:integer;
begin
    mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    if mBookmark.count=0 then Pocet_zaznamu:=1;
    if mBookmark.count>0 then Pocet_zaznamu:=mBookmark.count;
    Pot_zaznam:='';

    Xresult:= (InputQuery('Nastavení', 'Zadej id nového dokladu',Pot_zaznam));
               if Xresult then begin
                          if mBookmark.Count = 0 then begin
                              opakovani:=mBookmark.Count;
                          end;
                          if mBookmark.Count >0 then opakovani:=mBookmark.Count-1;
                                  for i := 0 to opakovani do begin // projdu vsechny oznacene zaznamy
                                          if mBookmark.Count > 0 then begin
                                              mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                                              mBO_Row := TDynSiteForm(mSite).CurrentObject;
                                          end else begin
                                              mBO_Row := TDynSiteForm(mSite).CurrentObject;
                                          end;
                                      mi:=TDynSiteForm(mSite).BaseObjectSpace.SQLExecute('update receivedorders2 set parent_id=' + quotedstr(Pot_zaznam)  + ' where id=' + quotedstr(TDynSiteForm(mSite).CurrentObject.oid))
                                  end;



                 end;
end;





begin
end.