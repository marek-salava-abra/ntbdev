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
  mAction.Caption := 'Doplnění limitu';
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
  pocet:Integer;


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
    if mBookmark.count=0 then Pocet_zaznamu:=1;
    if mBookmark.count>0 then Pocet_zaznamu:=mBookmark.count;
         if mBookmark.Count = 0 then begin
            opakovani:=mBookmark.Count;
            //acode:= mBO.GetFieldValueAsString('id');
        end;

        if mBookmark.Count >0 then opakovani:=mBookmark.Count-1;

        for i := 0 to opakovani do begin // projdu vsechny oznacene zaznamy
                mBO := TDynSiteForm(mSite).CurrentObject;
            if mBookmark.Count > 0 then begin
                mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                mBO := TDynSiteForm(mSite).CurrentObject;
            end;;
                mr:=TStringList.Create;
                        try
                                mbo.ObjectSpace.SQLSelect('Select sum(ro2.quantity) from StoreDocuments2 RO2 left join Storedocuments RO on RO.ID=RO2.PArent_ID where ro.DocumentType =' + quotedstr('21') + ' and ro2.storecard_ID=' + quotedstr(mbo.GetFieldValueAsString('Storecard_ID')) +' and ro2.store_ID='+ quotedstr(mbo.GetFieldValueAsString('Store_ID')) + ' and ro.docdate$date>='+quotedstr(IntToStr(Round(now()-365))), mR);      //hledám id dokladu
                                //mbo.ObjectSpace.SQLSelect('Select count(ID) from Storecards ', mR);
                                pocet:= Round(strtofloat(mr.Strings[0])/12);
                                if pocet>=30 then begin
                                     mbo.SetFieldValueAsFloat('LowLimitQuantity',pocet);
                                end else begin
                                        if pocet>=5 then begin
                                                mbo.SetFieldValueAsFloat('LowLimitQuantity',pocet*2);
                                        end else begin
                                                mbo.SetFieldValueAsFloat('LowLimitQuantity',0);
                                        end;
                                end;

                                mbo.save;
                      finally
                         mr.free;
                        end;


        end;

end;




begin
end.