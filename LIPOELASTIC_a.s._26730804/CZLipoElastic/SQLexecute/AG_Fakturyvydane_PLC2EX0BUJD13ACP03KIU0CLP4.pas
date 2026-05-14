uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse';
var
     mBookmark : TBookmarkList;

procedure NewSQLExecute(Sender: TAction; Index: integer);
var
 mbo,mobj:TNxCustomBusinessObject;
 mSite: TSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 i,j:integer;
   mForm: TDynSiteForm;
   mtext:string;
   mB_Result:boolean;
   mi:integer;
   mMon:TNxCustomBusinessMonikerCollection;
   mstring:string;
begin
 // mtext:='Description=' + quotedstr('');
  mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    mstring:=InputBox('Zadej novou dobu splatnosti', 'dnů ' , mstring);
    if mstring='' then exit;
   // mB_Result:=InputQuery('Zadaj parametry', 'Změna ', mtext);
    if mBookmark.count=0 then begin
     mobj:= TDynSiteForm(mSite).CurrentObject;
    //mi:=TDynSiteForm(msite).BaseObjectSpace.SQLExecute('Update Issuedinvoices set ' + mstring + ' where id=' + QuotedStr(mobj.oid)) ;
                              mi:=TDynSiteForm(msite).BaseObjectSpace.SQLExecute('Update Issuedinvoices set DueDate$DATE= ' + NxFloatToIBStr(mobj.GetFieldValueAsDateTime('DocDate$DATE') + NxIBStrToFloat(mstring)) + ' where id=' + QuotedStr(mobj.oid)) ;


                           //   NxShowSimpleMessage(  ,nil);

                               {   mMon := TDynSiteForm(mSite).CurrentObject.GetLoadedCollectionMonikerForFieldCode(TDynSiteForm(mSite).CurrentObject.GetFieldCode('ROWS'));
                                    ProgressInit(msite, 'Doplnění šarží ' , 100);
                                      for j:= 0 to mMon.count -1 do begin
                                           ProgressSetPos(1+NxFloor(j/mMon.count), inttostr(j) +' z '+inttostr(mMon.count));

                                                //mMon.BusinessObject[j].SetFieldValueAsstring('VATIndex_ID','7000000000');
                                      end;
                                      ProgressDispose();    }

                              TDynSiteForm(mSite).ActiveDataSet.RefreshCurrentItem ;



    end else begin
         for i := 0 to mBookmark.Count- 1 do begin
                          mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                          mobj:= TDynSiteForm(mSite).CurrentObject;
                          // mi:=TDynSiteForm(msite).BaseObjectSpace.SQLExecute('Update Issuedinvoices set ' + mstring + ' where id=' + QuotedStr(mobj.oid)) ;
                                                   mi:=TDynSiteForm(msite).BaseObjectSpace.SQLExecute('Update Issuedinvoices set DueDate$DATE= ' + NxFloatToIBStr(mobj.GetFieldValueAsDateTime('DocDate$DATE') + NxIBStrToFloat(mstring)) + ' where id=' + QuotedStr(mobj.oid)) ;
                        {  mMon := TDynSiteForm(mSite).CurrentObject.GetLoadedCollectionMonikerForFieldCode(TDynSiteForm(mSite).CurrentObject.GetFieldCode('ROWS'));
                                    ProgressInit(msite, 'Doplnění šarží ' , 100);
                                      for j:= 0 to mMon.count -1 do begin
                                           ProgressSetPos(1+NxFloor(j/mMon.count), inttostr(j) +' z '+inttostr(mMon.count));

                                                //mMon.BusinessObject[j].SetFieldValueAsstring('VATIndex_ID','7000000000');
                                      end;
                                      ProgressDispose();     }




                         TDynSiteForm(mSite).ActiveDataSet.RefreshCurrentItem ;
         end;

    end;


end;


procedure InitSite_Hook(Self: TDynSiteForm);
var
mAction: TAction;
  mMAction: TMultiAction;
begin

  mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
 mMAction.Caption := 'Zápis SQL execute';
  mMAction.Items.Add('Hlavička');
  mMAction.Items.Add('Řádek');
  mMAction.Items.Add('Šarže');
  mMAction.Hint := 'SQL EXECUTE pro vybrané doklady';
  mMAction.Category := 'tabList';
  mMAction.Items.Add('Intrastat dodací podmínky');

  mmAction.OnExecuteItem:= @NewSQLExecute;



end;


begin
end.