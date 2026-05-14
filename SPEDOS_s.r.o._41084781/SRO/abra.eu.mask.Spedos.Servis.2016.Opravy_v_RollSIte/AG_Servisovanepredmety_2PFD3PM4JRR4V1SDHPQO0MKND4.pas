uses 'abra.eu.mask.Spedos.Servis.2016.Opravy_v_RollSIte.Funkce';

procedure DeleteExec(Sender: TAction;index:integer);
var
 mBO:TNxCustomBusinessObject;
    mTabList: TTabSheet;
    mBookmark : TBookmarkList;
 mDBGrid : TDBGrid;
 i:integer;
 mForm: TSiteForm;
 mOLE, mRoll, mOResult: Variant;
 mr,mr_sd:TStringList;
 mids:tstringlist;
 mID:string;
 mI_result:variant;
 mI_SP,mI_SD,mI_SA,mi,:integer;
 mIO_SP,mIO_SD,mIO_SA:integer;
 mresult:Boolean;
 msite:TSiteForm;
begin
    mSite := NxFindSiteForm(TComponent(Sender));
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    mid:='';

    if mBookmark.Count= 0 then begin
        mbo:=TBusRollSiteForm(mSite).CurrentObject;
        if mid='' then begin
           mI_SP:=0;
           mr_sd:=TStringList.create;
           try
               msite.BaseObjectSpace.SQLSelect('Select SO.id from ServicedObjects SO where SO.ID='+quotedstr(mbo.oid),mr_sd);
               if mr_sd.count>0 then begin
               mI_SP:=mr_SD.Count;
               end;
           finally
               mr_sd.free;
           end;
           mI_SD:=0;
           mr_sd:=TStringList.create;
           try
               msite.BaseObjectSpace.SQLSelect('Select sd.id from ServiceDocuments SD where sd.ServicedObject_ID='+quotedstr(mbo.oid),mr_sd);
               if mr_sd.count>0 then begin
               mI_SD:=mr_SD.Count;
               end;
            finally
                mr_sd.free;
            end;
            mI_SA:=0;
            mr_sd:=TStringList.create;
            try
               msite.BaseObjectSpace.SQLSelect('Select sa.id from ServiceAssemblyForms SA where sA.X_ServicedObject_ID='+quotedstr(mbo.oid),mr_sd);
               if mr_sd.count>0 then begin
               mI_SA:=mr_SD.Count;
               end;
            finally
                mr_sd.free;
            end;


            if mi_SD+mi_SA=0 then begin
                 mI_Result:=Mformx(msite,'Pozor','Položka bude vymazána', 'Vymazat','Skrýt','','Ponechat');
                if mI_Result=1 then begin

                    mbo.Delete;
                    msite.Refresh;
                    mdbgrid.DataSource.DataSet.Refresh;
                    mdbgrid.Refresh;
                    //msite.RefreshData;

                end;
                if mI_Result=6 then begin
                    mbo.SetFieldValueAsBoolean('Hidden',true);
                    mbo.Save;

                end;
            end else begin
                 mI_Result:=Mformx(msite,'Upozornění. Smazat položku ?','Pozor, položka je použita v ' + inttostr(mI_SD) + ' servisních listech, v ' + inttostr(mI_SA) + ' monntážních listech. Změnit ?', 'Vše a vymazat','Otevřené a skrýt','','Zrušit změny');
                 if (mI_Result=1) or (mI_Result=6) then begin
                    mID:=iSelectSP(msite.GetAbraOLEApplication);
                           if mI_Result=1 then begin
                              if mID<>'' then begin
                                    mi:=msite.BaseObjectSpace.SQLExecute('update DefRollData set X_ServicedObject_ID=' + quotedstr(mID) +
                                            ' WHERE CLSID = ' +quotedstr('L5NKMYE3ZLSOLEBABM5CCHGOIC') + ' AND (X_ServicedObject_ID = ' + quotedstr(mbo.OID));
                                    //if mI_SP>0 then mi:=msite.BaseObjectSpace.SQLExecute('update ServicedObjects set ServicedObject_ID=' + quotedstr(mID) + ' where ServicedObject_ID=' + quotedstr(mbo.OID)) ;
                                    if mI_SD>0 then mi:=msite.BaseObjectSpace.SQLExecute('update ServiceDocuments set ServicedObject_ID=' + quotedstr(mID) + ' where ServicedObject_ID=' + quotedstr(mbo.OID)) ;
                                    if mI_SA>0 then mi:=msite.BaseObjectSpace.SQLExecute('update ServiceAssemblyForms set X_ServicedObject_ID=' + quotedstr(mID) + ' where X_ServicedObject_ID=' + quotedstr(mbo.OID)) ;
                                    //mbo.SetFieldValueAsBoolean('Hidden',true);
                                    mbo.Delete;
                              end;
                           end;
                           if mI_Result=6 then begin
                              if mID<>'' then begin
                                    mi:=msite.BaseObjectSpace.SQLExecute('update DefRollData set X_ServicedObject_ID=' + quotedstr(mID) +
                                            ' WHERE CLSID = ' +quotedstr('L5NKMYE3ZLSOLEBABM5CCHGOIC') + ' AND (X_ServicedObject_ID = ' + quotedstr(mbo.OID));



                                    if mI_SD>0 then mi:=msite.BaseObjectSpace.SQLExecute('update ServiceDocuments X set X.ServicedObject_ID=' + quotedstr(mID)  +
                                          ' where (select ss.PosIndex from ServiceDocuments SD left join ServiceDocStates SS on ss.id=sd.ServiceDocState_ID where sd.ServicedObject_ID=' + quotedstr(mbo.OID)
                                          +' and x.id=sd.id)>15') ;

                                      if mI_SA>0 then mi:=msite.BaseObjectSpace.SQLExecute('update ServiceAssemblyForms X set X.X_ServicedObject_ID=' + quotedstr(mID)  +
                                          ' where (select ss.PosIndex from ServiceDocuments SD left join ServiceAssemblyForms SA on sa.ServiceDocument_ID=sd.id join ServiceDocStates SS on ss.id=sd.ServiceDocState_ID where SA.X_ServicedObject_ID=' + quotedstr(mbo.OID)
                                          +' and x.id=sd.id)>15') ;




                                    mbo.SetFieldValueAsBoolean('Hidden',True);
                                    mbo.Save ;
                              end;
                           end;
                      end;
                      if mI_Result=2 then begin
                                  mbo.SetFieldValueAsBoolean('Hidden',True);
                                  mbo.Save ;
                      end;
                       if mI_Result=5 then begin

                       end;

                 end;
            end;


    end else begin
        NxShowSimpleMessage('Funkce pracuje pouze s aktuálním záznamem, prosím odznačte ostatní',nil);
    end;

   msite.Refresh
   //TBusRollSiteForm(msite).RefreshData;
   //mDBGrid.Refresh;

end;








{
Vyvolává se po vytvoření instance formuláře.
}
procedure FormCreate_Hook(Self: TSiteForm);
var
mAList: TActionList;
  i: integer;
  mAction: TBasicAction;
   mMAction: TMultiAction;
  mC,mcc: TControl;
  mUserFilter: Boolean;
  mUser: TNxCustomBusinessObject;
begin
  mAList := Self.GetMainActionList;
  for i := 0 to mAList.ActionCount-1 do begin
    mAction := mALIst.Actions[i];
    if (mAction.Name = 'actDelete') then begin
      mAction.Visible := False;
    end;
  end;
// if (Self.CompanyCache.GetUserID='SUPER00000') or (Self.CompanyCache.GetUserID='2510000101') then begin
        mMAction := Self.GetNewMultiAction;
        mMAction.ShowControl := True;
        mMAction.ShowMenuItem := True;
        mMAction.Caption := 'Vymazat s kontrolou';
        mMAction.Hint := 'Vymazat s kontrolou';
        mMAction.Category := 'tabList';
        mMAction.OnExecuteItem := @DeleteExec;
        mMAction.Items.Add('Vymazání s kontrolou');

        mMAction := Self.GetNewMultiAction;
        mMAction.ShowControl := True;
        mMAction.ShowMenuItem := True;
        mMAction.Caption := 'Kontrola číselníků';
        mMAction.Hint := 'Kontrola číselníků';
        mMAction.Category := 'tabList';
        mMAction.OnExecuteItem := @CheckonExec;
        mMAction.Items.Add('Kontrola číselníků');
 //end;

end;

procedure CheckOnExec(Sender: TAction;index:integer);
var
 mBO:TNxCustomBusinessObject;
    mTabList: TTabSheet;
    mBookmark : TBookmarkList;
 mDBGrid : TDBGrid;
 i:integer;
 mForm: TSiteForm;
 mOLE, mRoll, mOResult: Variant;
 mr,mr_sd,mr_x:TStringList;
 mids:tstringlist;
 mID:string;
 mI_result:variant;
 mI_SP,mI_SD,mI_SA,mi,:integer;
 mIO_SP,mIO_SD,mIO_SA:integer;
 mresult:Boolean;
 msite:TSiteForm;
 mstring:TStrings;
begin
    mSite := NxFindSiteForm(TComponent(Sender));
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');

    mr:=tstringlist.create;
    try
         mbo:=TBusRollSiteForm(mSite).CurrentObject;
        if mid='' then begin
           mI_SP:=0;
           mr_sd:=TStringList.create;
           try
               msite.BaseObjectSpace.SQLSelect('Select SO.id from ServicedObjects SO where SO.id='+quotedstr(mbo.oid),mr_sd);
               if mr_sd.count>0 then begin
               mI_SP:=mr_SD.Count;
               end;
           finally
               mr_sd.free;
           end;
           mI_SD:=0;
           mr_sd:=TStringList.create;
           try
               msite.BaseObjectSpace.SQLSelect('Select sd.id from ServiceDocuments SD left join ServiceDocStates SS on sd.ServiceDocState_ID=ss.id where sd.ServicedObject_ID='+quotedstr(mbo.oid) + ' and ss.PosIndex<=50',mr_sd);
               if mr_sd.count>0 then begin
               mI_SD:=mr_SD.Count;
               end;
           finally
                mr_sd.free;
           end;
            mI_SA:=0;
            mr_sd:=TStringList.create;
           try
               msite.BaseObjectSpace.SQLSelect('Select sd.id from ServiceAssemblyForms SA left join ServiceDocuments SD on SD.ID=SA.ServiceDocument_ID left join ServiceDocStates SS on sd.ServiceDocState_ID=ss.id where sA.X_ServicedObject_ID='+quotedstr(mbo.oid) + ' and ss.PosIndex<=50',mr_sd);
               if mr_sd.count>0 then begin
               mI_SA:=mr_SD.Count;
               end;
           finally
                mr_sd.free;
           end;

          if mi_SP+mi_SD+mi_SA=0 then begin


                 NxShowSimpleMessage('Položka není použita, je možné ji vymazat',nil);
            end else begin
                 mI_Result:=Mformx(msite,'Upozornění','Pozor, položka je použita v ' + inttostr(mI_SD) + ' servisovaných listech, v ' + inttostr(mI_SA) +' motnážních listech', '','','','Zrušit');
            end;
      end;
      finally
      mr.free;
    end;
end;



begin
end.