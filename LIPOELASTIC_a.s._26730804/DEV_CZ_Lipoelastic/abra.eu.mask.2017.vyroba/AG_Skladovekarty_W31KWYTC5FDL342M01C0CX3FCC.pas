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
  mmAction.Caption := 'Společný kusovník';
  mmAction.Hint := 'Společný kusovník';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('Společný kusovník');
  mmAction.OnExecuteItem:= @kusovnik;

   mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := 'Společný technologický postup';
  mmAction.Hint := 'Společný technologický postup';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('Společný technologický postup');
  //mMAction.Items.Add('Založení kusovníků');
  mmAction.OnExecuteItem:= @Postup;
end;


procedure postup(Sender: TMultiAction; Index: integer);
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
   mOLE, mRoll, mOResult: Variant;
  mids1:TStringList;
  _ss:Variant;
    ii:integer;
    mID:string;
    mBookmark : TBookmarkList;
    pocet_zaznamu,opakovani:integer;
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
                            mroll := mOLE.GetAgenda('EY1VHUCFUEW455OMM2KXYUWR4K');
                            _ss := mOLE.CreateStrings;

                               mID := mroll.SingleSelectFromSelected2(_ss, 'Společný tech postup', TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_spolecny_technpostup'));

                                              if mBookmark.Count = 0 then begin


                                                                TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_spolecny_technpostup',mID);
                                                                TBusRollSiteForm(mSite).CurrentObject.save;

                                                  end;;

                                              for i := 0 to  mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy

                                                                mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                                                                TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_spolecny_technpostup',mID);
                                                                TBusRollSiteForm(mSite).CurrentObject.save;




                                              end;





     NxShowSimpleMessage('Operace byla dokončena',nil);

end;







procedure kusovnik(Sender: TMultiAction; Index: integer);
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
   mOLE, mRoll, mOResult: Variant;
  mids1:TStringList;
  _ss:Variant;
    ii:integer;
    mID:string;
    mBookmark : TBookmarkList;
    pocet_zaznamu,opakovani:integer;
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
                            mroll := mOLE.GetAgenda('NWWNX02WFV2ORFJOXIW4BHBLWG');
                            _ss := mOLE.CreateStrings;

                               mID := mroll.SingleSelectFromSelected2(_ss, 'Společný kusovník', TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_spolecny_kusovnik'));



                                          if mBookmark.Count = 0 then begin
                                                      mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));

                                                                TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_spolecny_kusovnik',mID);
                                                                TBusRollSiteForm(mSite).CurrentObject.save;

                                                  end;;



                                              for i := 0 to  mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
                                                                mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                                                                TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_spolecny_kusovnik',mID);
                                                                TBusRollSiteForm(mSite).CurrentObject.save;




                                              end;





     NxShowSimpleMessage('Operace byla dokončena',nil);

end;





begin
end.







