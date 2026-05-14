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
               msite.BaseObjectSpace.SQLSelect('Select SO.id from ServicedObjects SO where SO.X_Vyrobce_ID='+quotedstr(mbo.oid),mr_sd);
               if mr_sd.count>0 then begin
               mI_SP:=mr_SD.Count;
               end;
           finally
               mr_sd.free;
           end;
           mI_SD:=0;
            mI_SA:=0;

            if mi_SP+mi_SD+mi_SA=0 then begin
                 mI_Result:=Mformx(msite,'Pozor','Položka bude vymazána', 'Vymazat','','','Ponechat');
                if mI_Result=1 then mbo.Delete;
            end else begin
                 mI_Result:=Mformx(msite,'Upozornění. Smazat položku ?','Pozor, položka je použita v ' + inttostr(mI_SP) +'. Změnit ?', 'Vše a vymazat','','','Zrušit změny');
                 if (mI_Result=1) or (mI_Result=6) then begin
                    mID:=iSelectVyrobce(msite.GetAbraOLEApplication);
                           if mI_Result=1 then begin
                              if mID<>'' then begin
                                    if mI_SP>0 then mi:=msite.BaseObjectSpace.SQLExecute('update ServicedObjects set X_Vyrobce_ID=' + quotedstr(mID) + ' where X_Vyrobce_ID=' + quotedstr(mbo.OID)) ;
                                    mbo.SetFieldValueAsBoolean('Hidden',True);
                                    mbo.Save ;
                              end;
                           end;
                                    mbo.SetFieldValueAsBoolean('Hidden',True);
                                    mbo.Save ;
                              end;
                           end;
                       if mI_Result=5 then begin

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
               msite.BaseObjectSpace.SQLSelect('Select SO.id from ServicedObjects SO where SO.X_Vyrobce_ID='+quotedstr(mbo.oid),mr_sd);
               if mr_sd.count>0 then begin
               mI_SP:=mr_SD.Count;
               end;
           finally
               mr_sd.free;
           end;
           mI_SD:=0;
            mI_SA:=0;
 {          mr_x:=TStringList.create;
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
           end;  }




          if mi_SP+mi_SD+mi_SA=0 then begin


                 NxShowSimpleMessage('Položka není použita, je možné ji vymazat',nil);
            end else begin
                 mI_Result:=Mformx(msite,'Upozornění','Pozor, předmět je použit v ' + inttostr(mI_SP) + ' servisovaných předmětech.', '','','','Zrušit');
            end;
      end;
      finally
      mr.free;
    end;
end;



begin
end.