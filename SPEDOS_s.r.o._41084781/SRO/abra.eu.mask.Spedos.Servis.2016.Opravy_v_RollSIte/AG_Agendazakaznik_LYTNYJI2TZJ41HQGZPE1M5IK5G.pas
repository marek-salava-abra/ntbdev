uses 'abra.eu.mask.Spedos.Servis.2016.Opravy_v_RollSIte.Funkce';

procedure DeleteExec(Sender: TAction;index:integer);
var
 mBO,mbo_target:TNxCustomBusinessObject;
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
               msite.BaseObjectSpace.SQLSelect('Select SO.id from ServicedObjects SO where SO.X_ID_zakaznika_ID='+quotedstr(mbo.oid) + ' or SO.X_id_zakobjednatel_ID='+quotedstr(mbo.oid),mr_sd);
               if mr_sd.count>0 then begin
               mI_SP:=mr_SD.Count;
               end;
           finally
               mr_sd.free;
           end;
           mI_SD:=0;
           mr_sd:=TStringList.create;
           try
               msite.BaseObjectSpace.SQLSelect('Select sd.id from ServiceDocuments SD left join ServiceDocStates SS on sd.ServiceDocState_ID=ss.id where sd.X_ID_zakaznika_ID='+quotedstr(mbo.oid) + ' and ss.PosIndex<=50',mr_sd);
               if mr_sd.count>0 then begin
               mI_SD:=mr_SD.Count;
               end;
            finally
                mr_sd.free;
            end;
            mI_SA:=0;
            mr_sd:=TStringList.create;
            try
               msite.BaseObjectSpace.SQLSelect('Select sd.id from ServiceAssemblyForms SA left join ServiceDocuments SD on SD.ID=SA.ServiceDocument_ID left join ServiceDocStates SS on sd.ServiceDocState_ID=ss.id where sA.X_ID_zakaznika_ID='+quotedstr(mbo.oid) + ' and ss.PosIndex<=50',mr_sd);
               if mr_sd.count>0 then begin
               mI_SA:=mr_SD.Count;
               end;
            finally
                mr_sd.free;
            end;

            if mi_SP+mi_SD+mi_SA=0 then begin
                 mI_Result:=Mformx(msite,'Pozor','Položka bude vymazána', 'Vymazat','','','Ponechat');
                if mI_Result=1 then mbo.Delete;
            end else begin
                 mI_Result:=Mformx(msite,'Upozornění. Smazat položku ?','Pozor, položka je použita v ' + inttostr(mI_SP) + ' servisovaných předmětech, v ' + inttostr(mI_SD) + ' servisních listech. Změnit ?', 'Vše a vymazat','Otevřené a skrýt','','Zrušit změny');
                 if (mI_Result=1) or (mI_Result=6) then begin
                    mID:=iSelectZakaznik(msite.GetAbraOLEApplication);
                           if mI_Result=1 then begin
                              if mID<>'' then begin
                                    if mI_SP>0 then begin
                                          mr_sd:=TStringList.create;
                                          try
                                               msite.BaseObjectSpace.SQLSelect('Select SO.id from ServicedObjects SO where SO.X_ID_zakaznika_ID='+quotedstr(mbo.oid)+ ' or SO.X_id_zakobjednatel_ID='+quotedstr(mbo.oid),mr_sd);
                                               if mr_sd.count>0 then begin
                                                    for I:=0 to mr_sd.count-1 do begin
                                                        mbo_target:=msite.BaseObjectSpace.CreateObject('OWHN2TMXL2COJJ3LKNBV4OVSTC');
                                                        try
                                                            mbo_target.load(mr_sd.Strings[i],nil);
                                                            if mbo_target.getFieldValueAsString('X_ID_zakaznika_ID')=mbo.oid then mbo_target.SetFieldValueAsString('X_ID_zakaznika_ID',mid);
                                                            if mbo_target.getFieldValueAsString('X_id_zakobjednatel_ID')=mbo.oid then mbo_target.SetFieldValueAsString('X_id_zakobjednatel_ID',mid);
                                                            //mbo_target.SetFieldValueAsString('X_ID_zakobjednatel_ID','');
                                                            mbo_target.save;
                                                        finally
                                                            mbo_target.free;
                                                        end;
                                                    end;
                                               end;
                                           finally
                                               mr_sd.free;
                                           end;
                                     end;
                                    //mi:=msite.BaseObjectSpace.SQLExecute('update ServicedObjects set X_ID_zakaznika_ID=' + quotedstr(mID) + ' where X_ID_zakaznika_ID=' + quotedstr(mbo.OID)) ;
                                    if mI_SD>0 then begin
                                        mr_sd:=TStringList.create;
                                          try
                                               msite.BaseObjectSpace.SQLSelect('Select SO.id from ServiceDocuments SO where SO.X_ID_zakaznika_ID='+quotedstr(mbo.oid),mr_sd);
                                               if mr_sd.count>0 then begin
                                                    for I:=0 to mr_sd.count-1 do begin
                                                        mbo_target:=msite.BaseObjectSpace.CreateObject('BCHF52UGXCO4H5MIAQVY5P3ZOC');
                                                        try
                                                            mbo_target.load(mr_sd.Strings[i],nil);
                                                            if mbo_target.getFieldValueAsString('X_ID_zakaznika_ID')=mbo.oid then mbo_target.SetFieldValueAsString('X_ID_zakaznika_ID',mid);
                                                            if mbo_target.getFieldValueAsString('X_id_zakobjednatel_ID')=mbo.oid then mbo_target.SetFieldValueAsString('X_id_zakobjednatel_ID',mid);
                                                            mbo_target.save;
                                                            mi:=msite.BaseObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_ID_zakaznika_ID='+quotedstr(mID) + ' where ServiceDocument_ID='+quotedstr(mr_sd.Strings[i]));

                                                        finally
                                                            mbo_target.free;
                                                        end;
                                                    end;
                                               end;
                                           finally
                                               mr_sd.free;
                                           end;

                                     end;




                               {     if mI_SA>0 then begin
                                           mr_sd:=TStringList.create;
                                          try
                                               msite.BaseObjectSpace.SQLSelect('Select SO.id from ServiceAssemblyForms SO where SO.X_ID_zakaznika_ID='+quotedstr(mbo.oid),mr_sd);
                                               if mr_sd.count>0 then begin
                                                    for I:=0 to mr_sd.count-1 do begin
                                                        mbo_target:=msite.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                                                        try
                                                            mbo_target.load(mr_sd.Strings[i],nil);
                                                            mbo_target.SetFieldValueAsString('X_ID_zakaznika_ID',mid);

                                                            mbo_target.save;
                                                        finally
                                                            mbo_target.free;
                                                        end;
                                                    end;
                                               end;
                                           finally
                                               mr_sd.free;
                                           end;



                                    end;  }


                              end;
                              mbo.Delete;
                           end;
                           if mI_Result=6 then begin
                              if mID<>'' then begin




                                    if mI_SP>0 then begin
                                          mr_sd:=TStringList.create;
                                          try
                                               msite.BaseObjectSpace.SQLSelect('Select SO.id from ServicedObjects SO where SO.X_ID_zakaznika_ID='+quotedstr(mbo.oid)+ ' or SO.X_id_zakobjednatel_ID='+quotedstr(mbo.oid),mr_sd);
                                               if mr_sd.count>0 then begin
                                                    for I:=0 to mr_sd.count-1 do begin
                                                        mbo_target:=msite.BaseObjectSpace.CreateObject('OWHN2TMXL2COJJ3LKNBV4OVSTC');
                                                        try
                                                            mbo_target.load(mr_sd.Strings[i],nil);
                                                            if mbo_target.getFieldValueAsString('X_ID_zakaznika_ID')=mbo.oid then mbo_target.SetFieldValueAsString('X_ID_zakaznika_ID',mid);
                                                            if mbo_target.getFieldValueAsString('X_id_zakobjednatel_ID')=mbo.oid then mbo_target.SetFieldValueAsString('X_id_zakobjednatel_ID',mid);
                                                            mbo_target.save;
                                                        finally
                                                            mbo_target.free;
                                                        end;
                                                    end;
                                               end;
                                           finally
                                               mr_sd.free;
                                           end;
                                    end;

                                    if mI_SD>0 then begin
                                          mr_sd:=TStringList.create;
                                          try
                                               msite.BaseObjectSpace.SQLSelect('Select x.id from ServiceDocuments x where x.X_ID_zakaznika_ID='+quotedstr(mbo.oid)+
                                               ' and (select ss.PosIndex from ServiceDocuments SD left join ServiceDocStates SS on ss.id=sd.ServiceDocState_ID where sd.X_ID_zakaznika_ID=' + quotedstr(mbo.OID) +
                                               ' and x.id=sd.id)>15',mr_sd);
                                               if mr_sd.count>0 then begin
                                                    for I:=0 to mr_sd.count-1 do begin
                                                        mbo_target:=msite.BaseObjectSpace.CreateObject('BCHF52UGXCO4H5MIAQVY5P3ZOC');
                                                        try
                                                            mbo_target.load(mr_sd.Strings[i],nil);
                                                            mbo_target.SetFieldValueAsString('X_ID_zakaznika_ID',mid);
                                                            //mbo_target.SetFieldValueAsString('X_ID_zakobjednatel_ID',mid);
                                                            mbo_target.save;
                                                            mi:=msite.BaseObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_ID_zakaznika_ID='+quotedstr(mID) + ' where ServiceDocument_ID='+quotedstr(mr_sd.Strings[i]));
                                                        finally
                                                            mbo_target.free;
                                                        end;
                                                    end;
                                               end;
                                           finally
                                               mr_sd.free;
                                           end;



                               //      mi:=msite.BaseObjectSpace.SQLExecute('update ServiceDocuments X set X.X_ID_zakaznika_ID=' + quotedstr(mID)  +
                               //           'where (select ss.PosIndex from ServiceDocuments SD left join ServiceDocStates SS on ss.id=sd.ServiceDocState_ID where sd.X_ID_zakaznika_ID=' + quotedstr(mbo.OID)
                               //           +' and x.id=sd.id)>15') ;
                                    end;

                                    if mI_SA>0 then  begin

                                    mi:=msite.BaseObjectSpace.SQLExecute('update ServiceAssemblyForms X set X.X_ID_zakaznika_ID=' + quotedstr(mID)  +

                                          ' where (select ss.PosIndex from ServiceDocuments SD left join left ServiceAssemblyForms SA on sa.ServiceDocument_ID=sd.id join ServiceDocStates SS on ss.id=sd.ServiceDocState_ID where SA.X_ID_zakaznika_ID=' + quotedstr(mbo.OID)
                                          +' and x.id=sd.id)>15') ;
                                    end;
                               //   update ServiceAssemblyForms set X_ID_zakaznika_ID=' + quotedstr(mID) + ' where X_ID_zakaznika_ID=' + quotedstr(mbo.OID)) ;
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
        for i:=0 to mBookmark.Count-1 do begin
            NxShowSimpleMessage('Funkce pracuje pouze s aktuálním záznameme, rosím odznačte ostatní',nil);
        end;
    end;


   TBusRollSiteForm(msite).RefreshData;
   mDBGrid.Refresh;

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
begin
  mAList := Self.GetMainActionList;
  for i := 0 to mAList.ActionCount-1 do begin
    mAction := mALIst.Actions[i];
    // Zcela odstranime funkci Opravit
    if (mAction.Name = 'actDelete') then begin
      mAction.Visible := False;
    end;
  end;
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


end;

{
Vyvolává se před fyzickým zrušením instance.
}
procedure FormDestroy_Hook(Self: TSiteForm);
begin

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
               msite.BaseObjectSpace.SQLSelect('Select SO.id from ServicedObjects SO where SO.X_ID_zakaznika_ID='+quotedstr(mbo.oid),mr_sd);
               if mr_sd.count>0 then begin
               mI_SP:=mr_SD.Count;
               end;
           finally
               mr_sd.free;
           end;
           mI_SD:=0;
           mr_sd:=TStringList.create;
           try
               msite.BaseObjectSpace.SQLSelect('Select sd.id from ServiceDocuments SD left join ServiceDocStates SS on sd.ServiceDocState_ID=ss.id where sd.X_ID_zakaznika_ID='+quotedstr(mbo.oid) + ' and ss.PosIndex<=50',mr_sd);
               if mr_sd.count>0 then begin
               mI_SD:=mr_SD.Count;
               end;
           finally
                mr_sd.free;
           end;
            mI_SA:=0;
            mr_sd:=TStringList.create;
           try
               msite.BaseObjectSpace.SQLSelect('Select sd.id from ServiceAssemblyForms SA left join ServiceDocuments SD on SD.ID=SA.ServiceDocument_ID left join ServiceDocStates SS on sd.ServiceDocState_ID=ss.id where sA.X_ID_zakaznika_ID='+quotedstr(mbo.oid) + ' and ss.PosIndex<=50',mr_sd);
               if mr_sd.count>0 then begin
               mI_SA:=mr_SD.Count;
               end;
           finally
                mr_sd.free;
           end;
           mr_x:=TStringList.create;
           try
               msite.BaseObjectSpace.SQLSelect(
               'SELECT A.Name FROM DefRollData A WHERE A.CLSID = ''MAQQH2FVJOTO1EMQZHDTY0CWOW'' AND (exists (SELECT 1 FROM USERDATA WHERE FIELDCODE=2000001 AND CLSID=''MAQQH2FVJOTO1EMQZHDTY0CWOW'' AND ID = A.ID AND (STRINGFIELDVALUE = '+quotedstr(mbo.GetFieldValueAsString('U_Ulice1')) + ')))' +
                ' AND (exists (SELECT 1 FROM USERDATA WHERE FIELDCODE=2000002 AND CLSID=''MAQQH2FVJOTO1EMQZHDTY0CWOW'' AND ID = A.ID AND (STRINGFIELDVALUE = '
                +Quotedstr(mbo.GetFieldValueAsString('U_Mesto')) + '))) and a.id<>'+quotedstr(mbo.oid),mr_x);
               if mr_x.Count>0 then begin
               NxShowSimpleMessage('Pro uvedenou adresu již záznam existuje pro název ' + mr_x.Strings[0],nil);
               end;
           finally
                mr_x.free;
           end;




          if mi_SP+mi_SD+mi_SA=0 then begin


                 NxShowSimpleMessage('Položka není použita, je možné ji vymazat',nil);
            end else begin
                 mI_Result:=Mformx(msite,'Upozornění','Pozor, předmět je použit v ' + inttostr(mI_SP) + ' servisovaných předmětech, v ' + inttostr(mI_SD) + ' servisních listech a v ' + inttostr(mI_SA) +' motnážních listech', '','','','Zrušit');
            end;
      end;
      finally
      mr.free;
    end;
end;



begin
end.