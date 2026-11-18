var
mresult,cresult:Boolean;
mSite: TSiteForm;
{
Vyvolává se po vytvoření instance formuláře.
}
procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Category := 'tabList,tabDetail';
  mAction.Caption := 'Zmena mnozstvi';
  mAction.OnExecute := @NewDescriptionClick;


end;





procedure NewDescriptionClick(Sender: TBasicAction);
var
  mBO: TNxCustomBusinessObject;
  mBO1: TNxCustomBusinessObject;
   mSite: TSiteForm;
  mControl : TControl;
  mDBGrid : TDBGrid;
  mBookmark : TBookmarkList;
  i : integer;
  opakovani:integer;
  mTabList: TTabSheet;
  mr:TStringList;
  Pocet_zaznamu:Integer;
  pocet:string;
  mi:Integer;


begin
     mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    mBO := TDynSiteForm(mSite).CurrentObject;
    pocet:='0';
    pocet:=InputBox('ZAdejte množství', 'Cílové množství na šarži',pocet);
                    // NxShowSimpleMessage(pocet,nil);
                   if mBookmark.Count>0 then begin
                        for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
                            mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                            mi:=msite.BaseObjectSpace.SQLExecute('update StoreSubBatches set Quantity=' + pocet + ' where id=' + QuotedStr(TDynSiteForm(mSite).CurrentObject.OID));
                                  TDynSiteForm(msite).ActiveDataSet.RefreshCurrentItem      ;

                                //NxShowSimpleMessage('update StoreSubBatches set Quantity=' + pocet + ' where id=' + QuotedStr(TDynSiteForm(mSite).CurrentObject.OID),nil);




                        end;
                     end else begin
                            mi:=msite.BaseObjectSpace.SQLExecute('update StoreSubBatches set Quantity=' + pocet + ' where id=' + QuotedStr(TDynSiteForm(mSite).CurrentObject.OID));


                               // NxShowSimpleMessage('update StoreSubBatches set Quantity=' + pocet + ' where id=' + QuotedStr(TDynSiteForm(mSite).CurrentObject.OID),nil);

                                 TDynSiteForm(msite).ActiveDataSet.RefreshCurrentItem      ;
                     end;



        // mbo.SetFieldValueAsFloat('MainUnitQuantity', NxStrToFloat(pocet));
        //       mbo.save;

end;




begin
end.