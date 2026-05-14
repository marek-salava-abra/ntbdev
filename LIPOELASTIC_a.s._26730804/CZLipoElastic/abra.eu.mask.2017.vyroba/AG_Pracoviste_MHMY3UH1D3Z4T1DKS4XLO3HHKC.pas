var
mresult,cresult:Boolean;
mSite: TSiteForm;

procedure InitSite_Hook(Self: TBusRollSiteForm);
var
mAction: TAction;
  mMAction: TMultiAction;
begin
   mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := 'Spotřební materiál';
  mmAction.Hint := 'Spotřební materiál';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('Nový');
  mMAction.Items.Add('Doplnění');
  mMAction.Items.Add('Ukončení');
  mmAction.OnExecute:= @Material;
end;


procedure material(Sender: TAction; Index: integer);
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
   mOLE, mRoll, mOResult,mOLE1, mRoll1, mOResult1: Variant;
  mids1:TStringList;
  _ss,_ss1:Variant;
    ii:integer;
    mID,mID1:string;
    mBookmark : TBookmarkList;
    pocet_zaznamu,opakovani:integer;
    mr:tstringlist;
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


          mOLE := GetAbraOLEApplication;
                            mroll := mOLE.GetAgenda('W31KWYTC5FDL342M01C0CX3FCC');
                             mRoll.Params.Add('_StoreCardCategory_ID=' + quotedstr('~00000000A') );









                            _ss := mOLE.CreateStrings;

                               mID := mroll.SingleSelectFromSelected2(_ss, 'Vyber materiál', '');



           mOLE1 := GetAbraOLEApplication;
                            mroll1 := mOLE1.GetAgenda('005WXDGLTVDL342W01C0CX3FCC');
                           mRoll1.Params.Add('_StoreCard_ID=' + quotedstr(mID) );

                            _ss1 := mOLE1.CreateStrings;

                               mID1 := mroll1.SingleSelectFromSelected2(_ss1, 'Vyber šarži', '');




                                              if mBookmark.Count = 0 then begin



                                                          mr:=tstringlist.create;
                                                          try
                                                                msite.BaseObjectSpace.SQLSelect('SELECT A.ID FROM DefRollData A WHERE A.CLSID = ''V41BBXBZKB5415AA2GN4BFFCY0'' AND (a.X_WorkPlace_ID=' + QuotedStr(TBusRollSiteForm(mSite).CurrentObject.oid) +
                                                                             ') and (a.X_Storecard_ID=' + QuotedStr(mID) +
                                                                             ') and (a.X_BAtches=' + QuotedStr(mID1) + ')' +
                                                                            // ' and ((A.X_ABRADate <= '+NxFloatToIBStr(now)+' ) AND ((A.X_ISISRLASTDATE > '+NxFloatToIBStr(now)+')  or (A.X_ISISRLASTDATE = 0))) '

                                                                ,mr);
                                                                if mr.count>0 then begin
                                                                       NxShowSimpleMessage('Vyměnit spotřební materiá , nebo ukončit ' + inttostr(mr.count),msite);


                                                                        mbo:=msite.BaseObjectSpace.CreateObject('V41BBXBZKB5415AA2GN4BFFCY0');
                                                                        try
                                                                              mbo.load(mr.Strings[0],nil);
                                                                                //mbo.Prefill;
                                                                                //mbo.SetFieldValueAsDateTime('X_ABRADate',Now);
                                                                                mbo.SetFieldValueAsDateTime('X_ISISRLASTDATE',now+100);
                                                                                mbo.SetFieldValueAsString('X_WorkPlace_ID', TBusRollSiteForm(mSite).CurrentObject.oid);
                                                                                mbo.SetFieldValueAsString('X_Storecard_ID',mID);
                                                                                mbo.SetFieldValueAsString('X_Batches',mID1);
                                                                                mbo.SetFieldValueAsFloat('X_quantity',1);


                                                                                mbo.save;
                                                                        finally
                                                                                mbo.free
                                                                        end;

                                                                end else begin
                                                                      mbo:=msite.BaseObjectSpace.CreateObject('V41BBXBZKB5415AA2GN4BFFCY0');
                                                                        try
                                                                              mbo.new;
                                                                                mbo.Prefill;
                                                                                mbo.SetFieldValueAsDateTime('X_ABRADate',Now);
                                                                                //mbo.SetFieldValueAsDateTime('X_ISISRLASTDATE',now+100);
                                                                                mbo.SetFieldValueAsString('X_WorkPlace_ID', TBusRollSiteForm(mSite).CurrentObject.oid);
                                                                                mbo.SetFieldValueAsString('X_Storecard_ID',mID);
                                                                                mbo.SetFieldValueAsString('X_Batches',mID1);
                                                                                mbo.SetFieldValueAsFloat('X_quantity',1);

                                                                                NxShowSimpleMessage('Nový spotřební materiá , nebo ukončit ',msite);
                                                                                mbo.save;
                                                                        finally
                                                                                mbo.free
                                                                        end;
                                                                end;
                                                          finally
                                                             mr.free;
                                                          end;

                                                  end;

                                              for i := 0 to  mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy

                                                                mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                                                               // TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_spolecny_technpostup',mID);
                                                                TBusRollSiteForm(mSite).CurrentObject.save;




                                              end;





     NxShowSimpleMessage('Operace byla dokončena',nil);

end;





begin
end.







