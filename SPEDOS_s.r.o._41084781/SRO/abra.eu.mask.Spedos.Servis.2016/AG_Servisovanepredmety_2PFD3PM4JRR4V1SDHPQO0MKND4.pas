uses 'abra.eu.mask.Spedos.Servis.2016_funkce.funkce';

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
          mOLE, mRoll, mOResult: Variant;
    mids:tstringlist;

procedure _AfterSave_PostHook(Self: TRollSiteForm);
var
mI_Result:integer;
mbusOrder_ID:string;
begin


  if NxIsEmptyOID(TBusRollSiteForm(self).CurrentObject.GetFieldValueAsString('BusOrder_ID')) then begin

      //mI_Result:=NxMessageBox('Potvrzení', 'Není uvedena zakázka - chcete založit?', mdStop, mdbOk, 2, [mdpSystemModal], False, nil);
      //NxShowSimpleMessage(inttostr(mI_Result),nil);
      //NxShowSimpleMessage('Není uvedena zakázka - nová zakázka bude založena utomaticky.' ,nil);


      mI_Result:=Mformx(self,'Potvrzení.','Není uvedena zakázka - chcete založit?', 'Založit','','','Dohledat');
                 if (mI_Result=1)  then begin
                      mbusOrder_ID:= GetBusOrder_ID(TBusRollSiteForm(self).CurrentObject);
                 if not nxisblank(mbusorder_Id) then
                      mI_Result:=self.BaseObjectSpace.SQLExecute('update ServicedObjects set BusOrder_ID=' + quotedstr(mbusOrder_ID) + ' where id=' + quotedstr(TBusRollSiteForm(self).CurrentObject.oid));
                 //SetFieldValueAsString('BusOrder_ID',mbusOrder_ID) ;
                 end;
                 if (mI_Result=5) then begin
                    mids:= TStringList.Create;
                    try

                          mOLE:= GetAbraOLEApplication;
                          mOResult:= mOLE.CreateStrings;
                          mRoll:= mOLE.GetRoll('03OXHKRF4VD13ACL03KIU0CLP4', 0);
                          if not mRoll.multiselectdialog(true, mOResult) then Exit;
                            mids.Text:= mOResult.Text;


                          if mids.count>0 then if mids.Strings[0]<>'' then mI_Result:=self.BaseObjectSpace.SQLExecute('update ServicedObjects set BusOrder_ID=' + quotedstr(mids.Strings[0]) + ' where id=' + quotedstr(TBusRollSiteForm(self).CurrentObject.oid));
                    finally
                        mids.free;
                    end;
                 end;


   end;

   self.Refresh;

end;

procedure FVExecuteItem(Sender: TAction; Index: integer);
var
 mresult:Boolean;
 mtext:string;
 mImportMan:TNxDocumentImportManager;
 mbo:TNxCustomBusinessObject;
 mSite: TSiteForm;
  mDBGrid : TDBGrid;
    mTabList: TTabSheet;
  self:TNxCustomBusinessObject;
  i,ii:integer;
  mr,mIDs_MLRow:TStringList;
   mForm: TRollSiteForm;
   mMon: TNxCustomBusinessMonikerCollection;
   mRow, mNewRow,mbo1: TNxCustomBusinessObject;
   mdate:Double;
begin
    mSite := NxFindSiteForm(TComponent(Sender));
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    mids:= TStringList.Create;
    try
         if index=0 then begin
              mOLE:= GetAbraOLEApplication;
              mOResult:= mOLE.CreateStrings;
              mRoll:= mOLE.GetRoll('ZX20VMNR1NV4N30K2MRDAXLRN4', 0);
              if not mRoll.multiselectdialog(true, mOResult) then Exit;
                mids.Text:= mOResult.Text;
         end;
         if index=1 then begin
              mOLE:= GetAbraOLEApplication;
              mOResult:= mOLE.CreateStrings;
              mRoll:= mOLE.GetRoll('03OXHKRF4VD13ACL03KIU0CLP4', 0);
              if not mRoll.multiselectdialog(true, mOResult) then Exit;
                mids.Text:= mOResult.Text;
         end;
         if index=2 then begin
              mOLE:= GetAbraOLEApplication;
              mOResult:= mOLE.CreateStrings;
              mRoll:= mOLE.GetRoll('0BOXHKRF4VD13ACL03KIU0CLP4', 0);
              if not mRoll.multiselectdialog(true, mOResult) then Exit;
                mids.Text:= mOResult.Text;
         end;
         if index=3 then begin
              mOLE:= GetAbraOLEApplication;
              mOResult:= mOLE.CreateStrings;
              mRoll:= mOLE.GetRoll('BTYHA5DHLTDO14H21XNZM2CPIK', 0);
              if not mRoll.multiselectdialog(true, mOResult) then Exit;
                mids.Text:= mOResult.Text;
         end;
         if index=4 then begin
              mOLE:= GetAbraOLEApplication;
              mOResult:= mOLE.CreateStrings;
              mRoll:= mOLE.GetRoll('K1MQ4TFKGJD13E3C01K0LEIOE0', 0);
              if not mRoll.multiselectdialog(true, mOResult) then Exit;
                mids.Text:= mOResult.Text;
         end;
         if index=5 then begin
              mOLE:= GetAbraOLEApplication;
              mOResult:= mOLE.CreateStrings;
              mRoll:= mOLE.GetRoll('O3OWQQYWYJCL3J0B01K0LEIOE0', 0);
              if not mRoll.multiselectdialog(true, mOResult) then Exit;
                mids.Text:= mOResult.Text;
         end;
         if index=6 then begin
              mOLE:= GetAbraOLEApplication;
              mOResult:= mOLE.CreateStrings;
              mRoll:= mOLE.GetRoll('K1MQ4TFKGJD13E3C01K0LEIOE0', 0);
              if not mRoll.multiselectdialog(true, mOResult) then Exit;
                mids.Text:= mOResult.Text;
         end;



        if not NxIsEmptyOID(mids.Strings[0]) then begin

                        //mtext:=InputBox('Zadej číslo objednávky','Číslo objednávky','');

                        if mBookmark.count=0 then begin
                            mBO := TBusRollSiteForm(mSite).CurrentObject;
                            if index=0 then mbo.SetFieldValueAsstring('BusProject_ID',mids.Strings[0]);
                            if index=1 then mbo.SetFieldValueAsstring('BusOrder_ID',mids.Strings[0]);
                            if index=2 then mbo.SetFieldValueAsstring('BusTransaction_ID',mids.Strings[0]);
                            if index=3 then mbo.SetFieldValueAsstring('X_id_zakaznika_id',mids.Strings[0]);
                            if index=4 then mbo.SetFieldValueAsstring('X_person_ID',mids.Strings[0]);
                            if index=5 then mbo.SetFieldValueAsstring('PayerFirm_id',mids.Strings[0]);
                            if index=6 then mbo.SetFieldValueAsstring('PayerPerson_id_ID',mids.Strings[0]);

                            mbo.Save;
                        end else begin
                            for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
                                    mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                                    mBO := TBusRollSiteForm(mSite).CurrentObject;
                                          if index=0 then mbo.SetFieldValueAsstring('BusProject_ID',mids.Strings[0]);
                                          if index=1 then mbo.SetFieldValueAsstring('BusOrder_ID',mids.Strings[0]);
                                          if index=2 then mbo.SetFieldValueAsstring('BusTransaction_ID',mids.Strings[0]);
                                          if index=3 then mbo.SetFieldValueAsstring('X_id_zakaznika_id',mids.Strings[0]);
                                          if index=4 then mbo.SetFieldValueAsstring('X_person_ID',mids.Strings[0]);
                                          if index=5 then mbo.SetFieldValueAsstring('PayerFirm_id',mids.Strings[0]);
                                          if index=6 then mbo.SetFieldValueAsstring('PayerPerson_id_ID',mids.Strings[0]);

                                    mbo.Save;
                            end;
                        end;
          end;
   finally

      mids.free;
   end;
 TBusRollSiteForm(mSite).RefreshData;
end;




procedure SPExecuteItem(Sender: TAction; Index: integer);
var
 mresult:Boolean;
 mtext:string;
 mImportMan:TNxDocumentImportManager;
 mbo:TNxCustomBusinessObject;
 mSite: TSiteForm;
  mDBGrid : TDBGrid;
    mTabList: TTabSheet;
  self:TNxCustomBusinessObject;
  i,ii:integer;
  mr,mrx,mr2,mIDs_MLRow:TStringList;
   mForm: TRollSiteForm;
   mMon: TNxCustomBusinessMonikerCollection;
   mRow, mNewRow,mbo1: TNxCustomBusinessObject;
   mdate:Double;
   mstrings:String;
   mOLE_SP, mRoll_SP, mOResult_SP: Variant;
   mIDs_SP:TStringList;
   mSelected :TStrings;
begin
    mSite := TComponent(sender).BusRollSite;
      mbo:=TBusRollSiteForm(mSite).CurrentObject;
                  mSite.ShowSite('5315B3YAPMNOB0FIRUCLXSJ52O', True,
                  ''
                  )
end;












procedure SloucitExecuteItem(Sender: TAction; Index: integer);
var
 mresult:Boolean;
 mtext:string;
 mImportMan:TNxDocumentImportManager;
 mbo:TNxCustomBusinessObject;
 mSite: TSiteForm;
  mDBGrid : TDBGrid;
    mTabList: TTabSheet;
  self:TNxCustomBusinessObject;
  i,ii:integer;
  mr,mIDs_MLRow:TStringList;
   mForm: TRollSiteForm;
   mMon: TNxCustomBusinessMonikerCollection;
   mRow, mNewRow,mbo1: TNxCustomBusinessObject;
   mdate:Double;
   morig:string;
   mi:Integer;
begin
    mSite := NxFindSiteForm(TComponent(Sender));
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
       morig:=TBusRollSiteForm(mSite).CurrentObject.oid;
        if mBookmark.count=0 then begin
            mBO := TBusRollSiteForm(mSite).CurrentObject;
        end else begin
            for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
                    mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                    mBO := TBusRollSiteForm(mSite).CurrentObject;
                    mi:=msite.BaseObjectSpace.SQLExecute('update ServiceDocuments set ServicedObject_ID=' + quotedstr(morig) + ' where ServicedObject_ID=' + quotedstr(TBusRollSiteForm(mSite).CurrentObject.oid));
                    mi:=msite.BaseObjectSpace.SQLExecute('update ServiceAssemblyForms set x_ServicedObject_ID=' + quotedstr(morig) + ' where X_ServicedObject_ID=' + quotedstr(TBusRollSiteForm(mSite).CurrentObject.oid));
                    mi:=msite.BaseObjectSpace.SQLExecute('update DefRollData set x_ServicedObject_ID='+quotedstr(morig)+' where X_ServicedObject_ID=' + quotedstr(TBusRollSiteForm(mSite).CurrentObject.oid));

                    mbo.SetFieldValueAsBoolean('Hidden',true);
                    mbo.save;
            end;
        end;

 TBusRollSiteForm(mSite).Refresh;
 mDBGrid.Refresh;
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
  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Hromadná změna';
  mMAction.Hint := 'Hromadná změna položek';
  mMAction.Category := 'tabList';
  mMAction.OnExecuteItem := @FVExecuteItem;
  mMAction.Items.Add('Změna smlouvy');
  mMAction.Items.Add('Změna zakázky');
  mMAction.Items.Add('Změna obchodního případu');
  mMAction.Items.Add('Změna adresy provozovatele');
  mMAction.Items.Add('Změna osoby provozovatele');
  mMAction.Items.Add('Změna adresy plátce');
  mMAction.Items.Add('Změna osoby plátce');


   mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Připojený objekt';
  mMAction.Hint := 'Zobrazí připojené objekty';
  mMAction.Category := 'tabList';
  mMAction.OnExecuteItem := @SPExecuteItem;
  mMAction.Items.Add('Nadřízený');
  mMAction.Items.Add('Podřízený');

     mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Sloučit';
  mMAction.Hint := 'Sloučí vybrané objekty do aktiálního';
  mMAction.Category := 'tabList';
  mMAction.OnExecuteItem := @SloucitExecuteItem;
  mMAction.Items.Add('Sloučit');


end;


begin
end.