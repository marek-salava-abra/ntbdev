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
  mAction.Category := 'tabList';
  mAction.Caption := 'Hromadné vyskladnění';
  mAction.OnExecute := @NewDescriptionClick;


end;





procedure NewDescriptionClick(Sender: TBasicAction);
var
  mBO,mMon_Target: TNxCustomBusinessObject;
  mBO1: TNxCustomBusinessObject;
   mSite: TSiteForm;
  mControl : TControl;
  mDBGrid : TDBGrid;
  mBookmark : TBookmarkList;
  i ,ii: integer;
  opakovani:integer;
  mTabList: TTabSheet;
  mr:TStringList;
  Pocet_zaznamu:Integer;
  pocet:Integer;
  mMon:TNxCustomBusinessMonikerCollection;

begin
     mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    mBO := TBusRollSiteForm(mSite).CurrentObject;
    if mBookmark.count=0 then Pocet_zaznamu:=1;
    if mBookmark.count>0 then Pocet_zaznamu:=mBookmark.count;
         if mBookmark.Count = 0 then begin
            opakovani:=mBookmark.Count;
            //acode:= mBO.GetFieldValueAsString('id');
        end;

        if mBookmark.Count >0 then opakovani:=mBookmark.Count-1;

        for i := 0 to opakovani do begin // projdu vsechny oznacene zaznamy
            if mBookmark.Count > 0 then begin
                mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
            end;;

                mr:=TStringList.Create;
                        try
                                msite.BaseObjectSpace.SQLSelect('Select sc.id||ssc.quantity from storesubcards ssc left join Storecards sc on sc.id=SSC.storecard_ID where ssc.store_id=' + quotedstr(TBusRollSiteForm(mSite).CurrentObject.oid) + ' and sc.X_cena_precen>0 and ssc.quantity>0',
                                mr) ;
                               //InputQuery('AA','AAA','Select sc.id||ssc.quantity from storesubcards ssc left join Storecards sc on sc.id=SSC.storecard_ID where ssc.store_id=' + quotedstr(TBusRollSiteForm(mSite).CurrentObject.oid) + ' and sc.X_cena_precen>0 and ssc.quantity>0'
                               // )    ;
                               // NxShowSimpleMessage(inttostr(mr.count),nil);
                                mbo:=msite.BaseObjectSpace.CreateObject('2T0I5SAOS3DL3ACU03KIU0CLP4');
                                if mr.count>0 then begin

                                    mbo.New;
                                    mbo.Prefill;
                                    mbo.SetFieldValueAsString('docqueue_ID','D700000101');
                                    mbo.SetFieldValueAsString('Firm_id','17V3000101');
                                    //mMon:= mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('ROWS'));
                                          for ii := 0 to mr.Count - 1 do begin
                                                  mMon_Target:= mBO.GetCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows')).AddNewObject;
                                                  mMon_Target.Prefill;
                                                  mMon_Target.SetFieldValueAsString('Store_ID',TBusRollSiteForm(mSite).CurrentObject.oid); //text bude  ...
                                                  mMon_Target.SetFieldValueAsString('Storecard_ID',copy(mr.Strings[ii],1,10));
                                                  mMon_Target.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(mr.Strings[ii],11,10)));
                                                  //mMon_Target.SetFieldValueAsFloat('Unitprice',mMon_Target.getFieldValueAsFloat('Storecard_ID.X_cena_precen'));
                                                  mMon_Target.SetFieldValueAsString('Division_ID','1N00000101');
                                          end;




                                  //tDynSiteForm(msite).ShowDynFormWithNewDocument('BT0I5SAOS3DL3ACU03KIU0CLP4', msite.SiteContext, mBO);
                                mbo.save;

                                end;



                      finally
                         mr.free;
                        end;


        end;

end;




begin
end.