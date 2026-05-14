 {
var
     mBookmark : TBookmarkList;

procedure primy_zapis(Sender: TAction; Index: integer);
var
 mbo:TNxCustomBusinessObject;
 mSite: TSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 i:integer;
   mForm: TBusRollSiteForm;
   mtext:string;
   mB_Result:boolean;
   mi:integer;
begin
  mtext:='Code=' + quotedstr('');
  mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    mbo:= TBusRollSiteForm(mSite).CurrentObject;
    mB_Result:=InputQuery('Zadaj parametry', 'Změna ', mtext);
    if mBookmark.count=0 then begin
               //if index=0 then begin

                              if mB_Result then mi:=msite.BaseObjectSpace.SQLExecute('update firms set ' + mtext + ' where id=' + QuotedStr(TBusRollSiteForm(mSite).CurrentObject.oid))  ;
                              TBusRollSiteForm(mSite).CurrentObject.Refresh;
    end else begin
         for i := 0 to mBookmark.Count- 1 do begin
                          mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                         //if index=0 then begin
                              if mB_Result then mi:=msite.BaseObjectSpace.SQLExecute('update firms set ' + mtext + ' where id=' + QuotedStr(TBusRollSiteForm(mSite).CurrentObject.oid)) ;
                          // end; //DolneniObalu(msite,TDynSiteForm(mSite).CurrentObject,index);
                          TBusRollSiteForm(mSite).CurrentObject.Refresh;

         end;

    end;





end;


procedure InitSite_Hook(Self: TBusRollSiteForm);
var
mAction: TAction;
  mMAction: TMultiAction;
begin
if (NxGetActualUserID(self.BaseObjectSpace)='SUPER00000') or (NxGetActualUserID(self.BaseObjectSpace)='1Z10000101') then begin
  mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := 'Přímý zápis';
  mmAction.Hint := 'Přímý zápis';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('Přímý zápis bez kontroly');
  mMAction.Items.Add('Přímý zápis s kontrolou');
  mmAction.OnExecute:= @primy_zapis;
end ;


end;
        }

begin
end.