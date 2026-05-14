var
    mFSazba_hod_den,mFDoprava_km,mF_doprava_pausal,mFSazba_hod:double;
    mBO_BusProject:TNxCustomBusinessObject;
    mF_pausal_prace,mF_pausal_Vyjezd,mF_prace,mF_km:double;
    // doby + termíny
    mF_doba:double;
    mRows : TNxCustomBusinessMonikerCollection;
    result:boolean;
    mresult:boolean;
      mBookmark : TBookmarkList;
    mBustrasaction_ID:string;





    procedure FVExecuteItem(Sender: TAction; Index: integer);
var
 mresult:Boolean;
 mtext:string;
 mbo:TNxCustomBusinessObject;
 mSite: TSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 self:TNxCustomBusinessObject;
 i,ii:integer;
  mr,mIDs_MLRow:TStringList;
   mForm: TDynSiteForm;
   mMon: TNxCustomBusinessMonikerCollection;
   mRow, mNewRow,mbo1: TNxCustomBusinessObject;
   mdate:Double;
   mr2:tstringlist;
   mi:integer;
begin
  mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
          try
                  if mBookmark.count=0 then begin                 // pro aktuální záznam
                     mBO := TDynSiteForm(mSite).CurrentObject;
                     mr:=TStringList.create;
                     try

                         msite.BaseObjectSpace.SQLSelect('select id from VATIssuedDInvoices2 where parent_id=' + quotedstr(mbo.OID) + ' AND Division_ID=' + quotedstr('O000000101'),mr);

                         if mr.count>0 then begin
                               mr2:=TStringList.create;
                                  try
                                    msite.BaseObjectSpace.SQLSelect('select id from VATIssuedDInvoices2 where parent_id=' + quotedstr(mbo.OID) + ' AND Division_ID<>' + quotedstr('O000000101'),mr) ;
                                    if mr2.count>0 then begin

                                       NxShowSimpleMessage('Na dokladu je i jiné středisko než "300", doklad nebude změněn.',nil);
                                    end else begin
                                        mi:=msite.BaseObjectSpace.SQLExecute('update VATIssuedDInvoices2 set division_ID=' +quotedstr('3W00000101') + ' where parent_id=' + quotedstr(mbo.OID) + ' AND Division_ID=' + quotedstr('O000000101'));
                                        NxShowSimpleMessage('Proběhla změna na řádcích dokladu, změna se projeví po občerstvení',nil);
                                    end;
                                  finally

                                     mr2.free;
                                  end;
                         end else begin
                             NxShowSimpleMessage('Na dokladu není řádek se střediskem "300", není co měnit',nil);
                         end;
                     finally
                       mr.free;
                     end;

                  end else begin
                          for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy           // pro ozbačené záznamy
                                  mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));

                                  mBO := TDynSiteForm(mSite).CurrentObject;

                                   mr:=TStringList.create;
                                   try

                                       msite.BaseObjectSpace.SQLSelect('select id from VATIssuedDInvoices2 where parent_id=' + quotedstr(mbo.OID) + ' AND Division_ID=' + quotedstr('O000000101'),mr);

                                       if mr.count>0 then begin
                                             mr2:=TStringList.create;
                                                try
                                                  msite.BaseObjectSpace.SQLSelect('select id from VATIssuedDInvoices2 where parent_id=' + quotedstr(mbo.OID) + ' AND Division_ID<>' + quotedstr('O000000101'),mr) ;
                                                  if mr2.count>0 then begin

                                                    // NxShowSimpleMessage('Na dokladu je i jiné středisko než "200", doklad nebude změněn.',nil);
                                                  end else begin
                                                      mi:=msite.BaseObjectSpace.SQLExecute('update VATIssuedDInvoices2 set division_ID=' +quotedstr('3W00000101') + ' where parent_id=' + quotedstr(mbo.OID) + ' AND Division_ID=' + quotedstr('O000000101'));
                                                     // NxShowSimpleMessage('Proběhla změna na řádcích dokladu, změna se projeví po občerstvení',nil);
                                                  end;
                                                finally

                                                   mr2.free;
                                                end;
                                       end else begin
                                           NxShowSimpleMessage('Na dokladu není řádek se střediskem "300", není co měnit',nil);
                                       end;
                                   finally
                                     mr.free;
                                   end;


                          end;
                  end;
              finally

              end;



end;







procedure InitSite_Hook(Self: TSiteForm);
var
mAction: TAction;
  mMAction: TMultiAction;
  mUserFilter: Boolean;
  mUser: TNxCustomBusinessObject;
begin
  mUserFilter:=false;
  mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');            // přihlášený uživatel
  try
      mUser.Load(Self.CompanyCache.GetUserID, nil);
            if mUser.GetFieldValueAsString('Name')='Supervisor' then mUserFilter:= true;
  finally
    mUser.Free;
  end;
{  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Fakturace / záruka';
  mAction.Hint := 'Vytvoří fakturu vydanou';
  mAction.Category := 'tabList';
  mAction.OnExecute:= @FVExecuteItem;

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Fakturace / záruka i nulové';
  mAction.Hint := 'Vytvoří fakturu vydanou';
  mAction.Category := 'tabList';
  mAction.OnExecute:= @FVExecuteItemwithnull;


  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Fakturace -logistika';
  mAction.Hint := 'Vytvoří fakturu vydanou';
  mAction.Category := 'tabList';
  mAction.OnExecute:= @FVExecuteItemLOG;


//  mAction := Self.GetNewAction;
//  mAction.ShowControl := True;
//  mAction.ShowMenuItem := True;
//  mAction.Caption := 'Zobraz fakturu';
//  mAction.Hint := 'Zobrazí vystavenou fakturu';
//  mAction.Category := 'tabList';
//  mAction.OnExecute := @FVShowExecuteItem;

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Povolit znovu fakturovat';
  mAction.Hint := 'Částečná fakturace';
  mAction.Category := 'tabList';
  mAction.OnExecute := @FVeditItem;  }

   mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Fakt 300/300x';
  mMAction.Hint := 'Operace dispečera servisu';
  mMAction.Category := 'tabList';
//  mMAction.OnUpdate := @FVOnExekute;
  mMAction.OnExecuteItem := @FVOnExekute;
  mMAction.Items.Add('Zmena střediska 300/300x');


end;

procedure FVOnExekute(Sender: TAction;index:integer;);
begin
FVExecuteItem(sender,index);

end ;



begin
end.