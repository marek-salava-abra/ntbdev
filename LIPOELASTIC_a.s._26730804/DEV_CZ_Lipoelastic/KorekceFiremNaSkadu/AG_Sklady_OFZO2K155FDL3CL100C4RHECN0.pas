uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse',
      'NxApiLib.lib';

var
mBChange,cresult:Boolean;
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
  mAction.Caption := 'Korekce firem';
  mAction.OnExecute := @NewDescriptionClick;


end;





procedure NewDescriptionClick(Sender: TBasicAction);
var
  mBO,: TNxCustomBusinessObject;
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
  mResults:string;
begin
    mResults:='';
    pocet:=0;
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

        if mBookmark.Count >0 then begin
            opakovani:=mBookmark.Count-1;
            ProgressInit(mSite, 'Zpracování dat ' , 100);
        end;

        for i := 0 to opakovani do begin // projdu vsechny oznacene zaznamy
            mBChange:=false;
            if mBookmark.Count > 0 then begin
                mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                ProgressSetPos(1+NxFloor((i/mBookmark.Count)*99), inttostr(i) +' z '+inttostr(mBookmark.Count));
            end;;

                if not NxIsEmptyOID(TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsString('X_firm_id')) then begin       // není vyplněna firma
                      if not NxIsEmptyOID(TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsString('X_firm_id.Firm_ID')) then begin   // není hlavní firma v adresáři
                           mBChange:=true;
                      end;
                      if TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsBoolean('X_firm_id.Hidden') then begin   // není hlavní firma v adresáři
                           mBChange:=true;
                      end;
                      if mbchange then begin
                              mr:=TStringList.Create;
                                    try
                                        msite.BaseObjectSpace.SQLSelect('Select id from firms where Name=' + quotedstr(TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsString('X_firm_id.Name')) + ' and hidden=' + quotedstr('N') + ' AND Firm_ID is null',mr);
                                        if mr.count=1 then begin
                                               TBusRollSiteForm(msite).CurrentObject.SetFieldValueAsString('X_firm_id',mr.Strings[0]);
                                               TBusRollSiteForm(msite).CurrentObject.save;

                                               pocet:=pocet+1;
                                               mResults:= mResults +chr(13) + chr(10)
                                                         +'Opraveno - ' + TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsString('X_firm_id.Name')
                                                         + ' a sklad ' + TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsString('Code') + ' není dohledána firma';

                                        end else begin
                                           if mr.count=0 then begin
                                              mResults:= mResults +chr(13) + chr(10)
                                                         +'Pro firmu ' + TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsString('X_firm_id.Name')
                                                         + ' a sklad ' + TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsString('Code') + ' není dohledána firma';

                                           end else begin
                                               mResults:= mResults +chr(13) + chr(10)
                                                         +' Pro firmu ' + TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsString('X_firm_id.Name')
                                                         + ' a sklad ' + TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsString('Code') + ' existuje více firem ';
                                           end;
                                        end;




                                    finally
                                       mr.free;
                                      end;
                      end;
                end;
        end;
       if mBookmark.Count > 0 then ProgressDispose() ;

       if pocet>0 then begin
          mResults:= 'Bylo upraveno ' + inttostr(pocet) + ' záznamu.' +chr(13) + chr(10) + mResults;
       end else begin
          mResults:= 'Nebyl upraven žádný záznam. ' +chr(13) + chr(10) + mResults;
       end;
  mResults:=BarCode_document(mSite,'05CPMINJW3DL342X01C0CX3FCC',0,0,720,960, 'Operace dokončena','Výsledek : ',mResults,'Pokračovat','','');

end;




begin
end.