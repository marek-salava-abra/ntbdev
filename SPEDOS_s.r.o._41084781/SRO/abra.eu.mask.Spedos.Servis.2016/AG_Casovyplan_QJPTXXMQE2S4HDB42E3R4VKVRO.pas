  uses 'abra.eu.mask.Spedos.Servis.2016_funkce.funkce';


Var
mbo_CRM_activities:TNxCustomBusinessObject;
mbo_ServiceAssembyForms:TNxCustomBusinessObject;
mbo_ServiceAssembyFormRows:TNxCustomBusinessObject;
mr:tstringlist;
mID:string;
xSite: TSiteForm;
mDBGrid : TDBGrid;
mTabList: TTabSheet;
mBookmark : TBookmarkList;
mbo,mBO_SL,mBONew_SL:TNxCustomBusinessObject;
mBO_SecurityRole:TNxCustomBusinessObject;
mBO_BusProject:TNxCustomBusinessObject;
mBO_ml,mbo_ml1,mBONew_ML:TNxCustomBusinessObject;
mRows_ML,mRows_ML1: TNxCustomBusinessMonikerCollection;
mOLE_SP, mRoll_SP, mOResult_SP: Variant;
mOLE_SL, mRoll_SL, mOResult_SL: Variant;
mOLE_SML, mRoll_SML, mOResult_SML: Variant;
mOLE_ML, mRoll_ML, mOResult_ML: Variant;
mOLE_WorkerRole, mRoll_WorkerRole, mOResult_WorkerRole: Variant;
mIDs_SP,mIDs_SL,mIDs_ML,mIDs_MLRow,mIDs_WorkerRole,mIDs_Storecard:tstringlist;
mID_SP,mID_SL,mID_ML,mID_MLRow:string;
mID_WorkerRole,mID_Store,mID_StoreCard,mid_workSpace:string;
mI_SP,mI_SL,mI_ML,mI_MLRow:integer;
mML_State_ID,mOrigML_State_ID :string;
mD_ML_start,mD_ML_End,mD_SL_start,mD_SL_End,mD_CRM_start,mD_CRM_End:double;



function NxCRMnepr(msite:tsiteform;State:integer;mBO_ML_Row: TNxCustomBusinessObject;mTechnik_ID:string;mF_start:Date;mF_konec:Date;mdruh:string;mpopis:string ): boolean;
var
  MSum:integer;
  mhodnota:double;
  mr:tstringlist;
  mheaderBO:TNxCustomBusinessObject;
  zapis:Boolean;
  I:integer;
  mtime:double;
  mstav:boolean;
  mstring:string;
begin
 mstav:=false;
 zapis:=false;
 mr:=TStringList.Create;
     try
               mheaderBO:= mBO_ML_Row.ObjectSpace.CreateObject('AVV1JYV5AVNOZHQCK0D4CJFUCS');
               try
                 //  mBO_ML_Row.ObjectSpace.SQLSelect(Format('select id from CRMActivities where x_Parent_id= %s',[quotedstr(mBO_ML_Row.GetFieldValueAsString('ID'))]),mr);
                  {  if mr.count>1 then begin
                       for i := 0 to mR.Count - 1 do begin
                            mheaderBO.load(mr.Strings[0],nil);
                            mHeaderBO.Delete;
                            mstav:=false;
                       end;
                    end; }
                 //   if (mr.count=0) then begin
                        mHeaderBO.New;
                        mHeaderBO.Prefill;
                        mHeaderBO.SetFieldValueAsString('ActivityArea_ID', '2000000101');
                        mHeaderBO.SetFieldValueAsString('ActivityType_ID', '1100000101');
                        mHeaderBO.SetFieldValueAsString('ActQueue_ID', 'D100000101');
                        mHeaderBO.SetFieldValueAsString('X_druh_nepritomnosti', mdruh);
                        mHeaderBO.SetFieldValueAsDateTime('SheduledStart$Date',mF_start);
                        mHeaderBO.SetFieldValueAsDateTime('SheduledEnd$Date', mF_konec);
                        mHeaderBO.SetFieldValueAsDateTime('RealStart$Date',mF_start);
                        mHeaderBO.SetFieldValueAsDateTime('RealEnd$Date', mF_konec);
                        mHeaderBO.SetFieldValueAsString('SolverRole_ID', mTechnik_ID);

                        zapis:=true;

                         mstring:= copy(mpopis,1,99);
                        mHeaderBO.SetFieldValueAsString('Subject',mstring);




                            //mHeaderBO.SetFieldValueAsString('Firm_ID', '');
                            //mHeaderBO.SetFieldValueAsString('Person_ID', '');
                            //mHeaderBO.SetFieldValueAsString('Division_ID', '');
                     mheaderBO.Save;
                     result:=true;
                //     end;


                    if mr.count=1 then begin
                      mheaderBO.load(mr.Strings[0],nil);
                    end;

              finally
                  mheaderBO.free;

              end ;
       finally
           mr.free;
       end;
      msite.Refresh;
end;

 procedure InitSite_Hook(Self: TSiteForm);
var
mAction: TAction;
  mMAction,mMAction1: TMultiAction;
  mUserFilter: Boolean;
  mUser: TNxCustomBusinessObject;
begin
//  mUserFilter:=false;
//  mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');            // přihlášený uživatel
//  try
//      mUser.Load(Self.CompanyCache.GetUserID, nil);
//            if mUser.GetFieldValueAsString('Name')='Supervisor' then mUserFilter:= true;
//  finally
//    mUser.Free;
//  end;
  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Nový servisní list - průvodce';
  mMAction.Hint := 'Nový Servisní list';
  mMAction.Category := 'tabmain';
  mMAction.OnExecuteItem := @NEWSLExecuteItem;
  mMAction.Items.Add('Nový servisní list - zrychleně');
  mMAction.Items.Add('Nový montážní list');


  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Editace servisu';
  mMAction.Hint := 'Operace dispečera servisu';
  mMAction.Category := 'tabmain';
//  mMAction.OnUpdate := @DispecerOnupdate;
  mMAction.OnExecuteItem := @DispecerExecuteItem;
  mMAction.Items.Add('Zadání technika');
  mMAction.Items.Add('Rozpočet fakturace');
  mMAction.Items.Add('Zadání materiálu');
  mMAction.Items.Add('Přidání textového řádku');
  mMAction.Items.Add('Cenová nabídka');
  mMAction.Items.Add('Zajištění materiálu');
  mMAction.Items.Add('Vyskladnění materiálu');
  mMAction.Items.Add('Stav ML');
  mMAction.Items.Add('');
  mMAction.Items.Add('Doplnění čísla objednávky');
  mMAction.Items.Add('Odeslání k fakturaci');
  mMAction.Items.Add('');
  mMAction.Items.Add('Změna záruky');
  mMAction.Items.Add('Doplnění závady');

  mMAction1 := Self.GetNewMultiAction;
  mMAction1.ShowControl := True;
  mMAction1.ShowMenuItem := True;
  mMAction1.Caption := 'Připojení protokolu';
  mMAction1.Hint := 'Připojení protokolu';
  mMAction1.Category := 'tabmain';
  mMAction1.OnExecuteItem := @ProtokolExecuteItem;
  mMAction1.Items.Add('Protokol Spedos');
  mMAction1.Items.Add('Protokol Zákazník');
  mMAction1.Items.Add('Objednávka');
  mMAction1.Items.Add('Ostatní');


  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Nepřítomnost';
  mMAction.Hint := 'Nepřítomnost';
  mMAction.Category := 'tabMain';
  mMAction.OnExecuteItem := @NepritomnostOnExecute;

  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Poznámka';
  mMAction.Hint := 'Doplnění poznámky';
  mMAction.Category := 'tabMain';
  mMAction.OnExecuteItem := @NoteOnExecute;
  mMAction.Items.Add('Poznámka k ML');
  mMAction.Items.Add('Poznámka k SL');
  mMAction.Items.Add('Poznámka k SP');

  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'ML bez technika';
  mMAction.Hint := 'ML bez technika';
  mMAction.Category := 'tabmain';
  mMAction.OnExecuteItem := @ShowDocExecuteItem;
  mMAction.Items.Add('ML bez technika');
  mMAction.Items.Add('Neprovedené ML do dneška');
  mMAction.Items.Add('Aktuální ML');



  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Korekce';
  mMAction.Hint := 'Korekce kolizí';
  mMAction.Category := 'tabmain';
  mMAction.OnExecuteItem := @Kolize;
  mMAction.Items.Add('Korekce kolizí');

end;

procedure Kolize(Sender: Tcomponent; Index: integer);
var
L : TStringList;
mForm: TForm;
i:integer;
mr:tstringlist;
mresult:boolean;
xsite:TSiteForm;
mdate:date;
mDateinput:boolean;
mResult_mat:boolean;
mBO_MLNew:TNxCustomBusinessObject;
mrta:tstringlist;
mdir,mtargetdir,mfilename,mfilter,mfile:string;
aresult:boolean;
mi:integer;
mpotvrzeni:boolean;
mbo,mbo_CRM_activities:TNxCustomBusinessObject;
mtime_start:double;
mtime_End:double;
begin
  xsite:=NxFindSiteForm(Sender);
            l:=TStringList.create;
            try
                mtime_End:=EncodeTime(15,30,0,0);
                  //xDynSite:=TComponent(Sender).DynSite;
                  Sender.Site.List.GetSelectedID(L);
                  for i:=0 to l.count-1 do begin
                      mid:=l.Strings[i];
                      mbo_CRM_activities:=sender.site.BaseObjectSpace.CreateObject('AVV1JYV5AVNOZHQCK0D4CJFUCS');
                      Try
                          mbo_CRM_activities.load(mid,nil);
                          mtime_start:= mtime_End  - (mbo_CRM_activities.getFieldValueAsDateTime('SheduledEnd$Date') -
                          mbo_CRM_activities.getFieldValueAsDateTime('SheduledStart$Date'))    ;

                          mbo_CRM_activities.SetFieldValueAsDateTime('SheduledStart$Date',trunc(mbo_CRM_activities.getFieldValueAsDateTime('SheduledStart$Date')) + mtime_start);
                          mbo_CRM_activities.SetFieldValueAsDateTime('RealStart$Date',trunc(mbo_CRM_activities.getFieldValueAsDateTime('RealStart$Date')) + mtime_start);
                          mbo_CRM_activities.SetFieldValueAsDateTime('SheduledEnd$Date',trunc(mbo_CRM_activities.getFieldValueAsDateTime('SheduledEnd$Date')) + mtime_End);
                          mbo_CRM_activities.SetFieldValueAsDateTime('RealEnd$Date',trunc(mbo_CRM_activities.getFieldValueAsDateTime('RealEnd$Date')) + mtime_End);

                          //NxShowSimpleMessage(NxFloatToIBStr(trunc(mbo_CRM_activities.getFieldValueAsDateTime('SheduledEnd$Date')) + mtime_End),nil);
                          mbo_CRM_activities.save;




                           mi:=xsite.BaseObjectSpace.SQLExecute('update ServiceAssemblyForms2 set X_konec_prace=' + NxFloatToIBStr(mbo_CRM_activities.getFieldValueAsDateTime('RealEnd$Date')) +
                                ' where parent_id='+quotedstr(mbo_CRM_activities.GetFieldValueAsString('X_parent_head')) );



                              mi:=xsite.BaseObjectSpace.SQLExecute('update ServiceAssemblyForms set StartDate$DATE=' + NxFloatToIBStr(mbo_CRM_activities.getFieldValueAsDateTime('RealEnd$Date')) +
                                ',EndDate$Date=' + NxFloatToIBStr(mbo_CRM_activities.getFieldValueAsDateTime('RealEnd$Date')) +
                                ' where id='+quotedstr(mbo_CRM_activities.GetFieldValueAsString('X_parent_head')) );




                          mtime_End:=frac(mtime_start);


                      finally
                          mbo_CRM_activities.free;
                      end;

                   end;
            finally
                l.free;
            end;
            xsite.Refresh;
            xsite.Repaint;
end;


procedure ProtokolExecuteItem(Sender: Tcomponent; Index: integer);
var
L : TStringList;
mForm: TForm;
i:integer;
mr:tstringlist;
mresult:boolean;
xsite:TSiteForm;
mdate:date;
mDateinput:boolean;
mResult_mat:boolean;
mBO_MLNew:TNxCustomBusinessObject;
mrta:tstringlist;
mdir,mtargetdir,mfilename,mfilter,mfile:string;
aresult:boolean;
mi:integer;
mpotvrzeni:boolean;
mbo,mbo_CRM_activities:TNxCustomBusinessObject;
begin
  xsite:=NxFindSiteForm(Sender);
            L:=TStringList.create;
            //xDynSite:=TComponent(Sender).DynSite;
            Sender.Site.List.GetSelectedID(L);
            if true then begin
            // Length(trim(l.Text))=10 then begin
                mbo_CRM_activities:=sender.site.BaseObjectSpace.CreateObject('AVV1JYV5AVNOZHQCK0D4CJFUCS');
                Try
                    mid:=trim(l.Text);
                    mbo_CRM_activities.load(mid,nil);

                        if not NxIsEmptyOID(mbo_CRM_activities.GetFieldValueAsString('X_parent_head')) then begin
                              mbo:=sender.site.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                            try
                              mid:='';
                              mr:=tstringlist.create;
                                  //try
                                  //   mbo_CRM_activities.ObjectSpace.SQLSelect('select SA.id from ServiceAssemblyForms2 SA2 left join ServiceAssemblyForms SA on SA2.parent_id=SA.id where sa2.id=' +quotedstr(mbo_CRM_activities.GetFieldValueAsString('X_parent_ID')) + ' group by SA.id',mr);
                                  //   NxShowSimpleMessage(inttostr(mr.count),nil);
                                  //   if mr.count=1 then begin
                                          mbo.load(mbo_CRM_activities.GetFieldValueAsString('X_parent_head'),nil);



                                          mdir:=Trim(mbo.GetFieldValueAsString('ServiceWorkSpace_ID.X_Directory'));
                                          NxShowSimpleMessage(mdir,nil);
                                          if PromptForFileName(mFileName, mfilter, '', 'Importovaný protokol spedos', mdir, False) then begin
                                              mdir:=copy(mfilename,0,NxCharPosR('\',mfilename));
                                              mFile:=copy(mfilename,1+NxCharPosR('\',mfilename),Length(mfilename));
                                              ShowMessage(Format('Bude importován soubor %s %s', [mdir,mfile,]));
                                          end;

                                          //ImportFile(TDynSiteForm(mSite).CurrentObject.ObjectSpace, mfilename, mdir,mfile);

                                         mtargetdir:=(Format('%s\%s\%s\%s\%s\%s', ['\\192.168.0.36\abra\Servis', mbo.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID'),'Servisni listy',mbo.GetFieldValueAsString('ServiceDocument_ID'),'ML',mbo.oid]));

                                         aResult := True;
                                         aresult:=nxcopyfile(mfilename,mtargetdir+'\' + mFile);
                                         if Aresult= true then begin
                                             if index=0 then  mi:=mbo.ObjectSpace.SQLExecute('update ServiceAssemblyForms set X_Spedos_formular=' + quotedstr(mfile) + ' where id=' + quotedstr(mbo.oid)) ;
                                             if index=1 then  mi:=mbo.ObjectSpace.SQLExecute('update ServiceAssemblyForms set X_Zakaznik_formular=' + quotedstr(mfile) + ' where id=' + quotedstr(mbo.oid)) ;
                                             if index=2 then  mi:=mbo.ObjectSpace.SQLExecute('update ServiceAssemblyForms set X_objednavka_formular=' + quotedstr(mfile) + ' where id=' + quotedstr(mbo.oid)) ;





                                             aresult:=DeleteFile(mFileName);
                                             if not aresult then NxShowSimpleMessage('Doklad ' + quotedstr(mfilename)  + ' nemohl být automatickys smazán, prosím smažte jej ručně',nil);
                                         end else begin
                                             NxShowSimpleMessage('Doklad ' + quotedstr(mfilename)  + ' nemohl být automaticky zkopírován, prosím zkopírujtea následně smažte jej ručně',nil);
                                         end;
                            finally
                               mr.free;
                               mbo.free;
                            end;
                        end;
                  finally
                      mbo_CRM_activities.free;
                  end;
            end;

end;


procedure NoteOnExecute(Sender: TAction; Index: integer);
var
 L : TStringList;
 mid:string;
 mPars:TNxParameters;
 mPar:TNxParameter;
 msite:TSiteForm;
 mr2:TStringList;
begin
    L := TStringList.Create();
        try

            Sender.Site.List.GetSelectedID(L);
            if Length(trim(l.Text))=10 then begin
                mbo_CRM_activities:=sender.site.BaseObjectSpace.CreateObject('AVV1JYV5AVNOZHQCK0D4CJFUCS');
                Try
                    mid:=trim(l.Text);
                    mbo_CRM_activities.load(mid,nil);

                        if not NxIsEmptyOID(mbo_CRM_activities.GetFieldValueAsString('X_parent_ID')) then begin
                              mbo_ServiceAssembyForms:=sender.site.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                            try
                              mid:='';
                              mr:=tstringlist.create;
                                  try
                                     mbo_CRM_activities.ObjectSpace.SQLSelect('select SA.id from ServiceAssemblyForms2 SA2 left join ServiceAssemblyForms SA on SA2.parent_id=SA.id where sa2.id=' +quotedstr(mbo_CRM_activities.GetFieldValueAsString('X_parent_ID')),mr);
                                     if mr.count=1 then begin
                                          mbo_ServiceAssembyForms.load(mr.Strings[0],nil);

                                          if index=0 then begin         // ml
                                              NxShowSimpleMessage(copy(mbo_ServiceAssembyForms.GetFieldValueAsString('note'),1,254),nil);
                                          end;

                                          if index=1 then begin         // sl
                                              NxShowSimpleMessage(copy(mbo_ServiceAssembyForms.GetFieldValueAsString('ServiceDocument_ID.DamageDescription'),1,254),nil);
                                          end;

                                          if index=2 then begin         // sp
                                              NxShowSimpleMessage(copy(mbo_ServiceAssembyForms.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID.Note'),1,254),nil);
                                          end;

                                     end else begin
                                      NxShowSimpleMessage('Je dohledáno více záznamů, nelze pokračovat',nil);
                                     end;
                                  finally
                                      mr.free;
                                  end;


                            finally
                              mbo_ServiceAssembyFormRows.free;
                            end;

                        end else begin
                                   NxShowSimpleMessage('Doklad nemá vazbu na servis',nil);
                        end;


                    //NxShowSimpleMessage('id: ' + mbo.GetFieldValueAsString('subject'), nil);

                finally
                   mbo_CRM_activities.free;
                end;

            end else begin
                    NxShowSimpleMessage('Není vybrána pouze jedna zdojová aktivita',nil);
            end;
        finally
            L.Free;
        end;
end;


   procedure Nepritomnost(Sender: Tcomponent;index:integer;mbo:TNxCustomBusinessObject);
var
  mSite : TSiteForm;
  mForm : TForm;
  mBtn : TButton;
  mLblm,mLbl2,mLbl3,mLbl4,mLabel3,lbldruh : TLabel;
  cbStores,cbDruhy : TComboBox;
  mRg : TRadioGroup;
  mRbS, mRbA : TRadioButton;
  mBookmark : TNxBookmarkList;
  mDBGrid : TDBGrid;
  mActualRow : TBookmark;
  i : integer;
  mOrderRow: TNxCustomBusinessObject;
  mMon : TNxCustomBusinessMonikerCollection;
  mAList: TActionList;
  aSecurityRole_ID:string;
  mCbBT: TRollComboEdit;
    mCbCcBT: TLabel;
    mChange:boolean;
    mEdtDAte,mEdtDAte1:TDateTimeEdit;
    mEdtDAte01,mEdtDAte11:TTimeEdit;
    mEdtSrc:TEdit;
    mDateOd,mdateDo:double;
    aDruh_nepritomnosti,aDruh_nepritomnosti_ID:string;
    mresult:boolean;
begin
 mChange:=false;
 mSite := NxFindSiteForm(Sender);

   try
      mForm := TForm.Create(msite);
    mForm.Caption := 'Zadejte údaje';
    mForm.FormStyle := fsStayOnTop;
    mForm.BorderStyle := bsDialog;
    mForm.Width := 370;
    mForm.Height := 220;
    mForm.Scaled := False;
    mform.Position := poScreenCenter;

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Technik :';
    mLabel3.Top := 10;
    mLabel3.Left := 10;
    mLabel3.Height := 13;

      cbStores := TComboBox.Create(mForm);
      cbStores.Left := 100;
      cbStores.Top := 10;
      cbStores.Width := 200;
      cbStores.Name := 'cbStore';
      cbStores.Text := '';
      mForm.InsertControl(cbStores);
         iFillFiltrRoles(msite.BaseObjectSpace, cbStores.Items,quotedstr(msite.CompanyCache.GetUserID));
      if cbStores.Items.Count >= 0 then begin
        cbStores.ItemIndex := 0;
      end;

          mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Druh nepřítomnosti :';
    mLabel3.Top := 40;
    mLabel3.Left := 10;
    mLabel3.Height := 13;

      cbDruhy := TComboBox.Create(mForm);
      cbDruhy.Left := 100;
      cbDruhy.Top := 40;
      cbDruhy.Width := 200;
      cbDruhy.Name := 'cbDruh';
      cbDruhy.Text := '';
      mForm.InsertControl(cbDruhy);
         iFillDruhy(msite.BaseObjectSpace, cbDruhy.Items);
      if cbDruhy.Items.Count >= 0 then begin
        cbDruhy.ItemIndex := 0;
      end;


      mLbl2 := TLabel.Create(mForm);         // položka řada
                    mLbl2.Caption := 'Od :';
                    mLbl2.Left := 10;
                    mLbl2.Top := 70;
                    mLbl2.Name := 'lbldate';
      mForm.InsertControl(mLbl2);
                    mEdtDAte := TDateTimeEdit.Create(mForm);
                    mEdtDAte.Left := 100;
                    mEdtDAte.Top := 70;
                    mEdtDAte.Width := 100;
                    mEdtDAte.Name := 'edtDate';
                    mEdtDAte.DateTime:=trunc(Now);
                    mForm.InsertControl(mEdtDAte);

                    mEdtDAte01 := TTimeEdit.Create(mForm);
                    mEdtDAte01.Left := 210;
                    mEdtDAte01.Top := 70;
                    mEdtDAte01.Width := 100;
                    mEdtDAte01.Name := 'edtDate01';
                    mEdtDAte01.Time:=0.333333333333333;
                    mForm.InsertControl(mEdtDAte01);

      mLbl3 := TLabel.Create(mForm);         // položka řada
                    mLbl3.Caption := 'Do :';
                    mLbl3.Left := 10;
                    mLbl3.Top := 100;
                    mLbl3.Name := 'lblDoba';
                    mForm.InsertControl(mLbl3);
      mEdtDAte1 := TDateTimeEdit.Create(mForm);
                    mEdtDAte1.Left := 100;
                    mEdtDAte1.Top := 100;
                    mEdtDAte1.Width := 100;
                    mEdtDAte1.Name := 'edtDate1';
                    mEdtDAte1.DateTime:=trunc(Now);
                    mForm.InsertControl(mEdtDAte1);

      mEdtDAte11 := TTimeEdit.Create(mForm);
                    mEdtDAte11.Left := 210;
                    mEdtDAte11.Top := 100;
                    mEdtDAte11.Width := 100;
                    mEdtDAte11.Name := 'edtDate11';
                    mEdtDAte11.Time:=0.6875;
                    mForm.InsertControl(mEdtDAte11);

      mLbl4 := TLabel.Create(mForm);         // položka řada
                    mLbl4.Caption := 'Popis :';
                    mLbl4.Left := 10;
                    mLbl4.Top := 130;
                    mLbl4.Name := 'lbldruh';
      mForm.InsertControl(mLbl4);
      mEdtSrc := TEdit.Create(mForm);
                    mEdtSrc.Left := 100;
                    mEdtSrc.Top := 130;
                    mEdtSrc.Width := 250;
                    mEdtSrc.Name := 'mEdtSrc';
                    mEdtSrc.Text:='';
                    mForm.InsertControl(mEdtSrc);

  mBtn := TButton.Create(mForm);
  mBtn.Width := 75;
  mBtn.Height := 25;
  mBtn.Caption := 'OK';
  mBtn.ModalResult := mrOk;
  mBtn.Cancel := False;
  mBtn.Default := True;
  mBtn.Left :=  mForm.Width - 2*(mBtn.Width+2) - 20;
  mBtn.Top := mForm.Height - mBtn.Height - 40;
  mBtn.Name := 'btnOK';
  mForm.InsertControl(mBtn);

  mBtn := TButton.Create(mForm);
  mBtn.Width := 75;
  mBtn.Height := 25;
  mBtn.Caption := 'Storno';
  mBtn.ModalResult := mrCancel;
  mBtn.Cancel := True;
  mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;;
  mBtn.Top := mForm.Height - mBtn.Height - 40;
  mBtn.Name := 'btnCancel';
  mForm.InsertControl(mBtn);

      if mForm.ShowModal(mSite) = mrOK then begin
//       if (osNew in TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.State) or (osUpdated in TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.State) then begin
             mDateOd:=mEdtDAte.DateTime + mEdtDAte01.Time;
             mdateDo:=mEdtDAte1.DateTime +mEdtDAte11.Time ;
             mChange:=true;
             aSecurityRole_ID:=iGetIDByName(msite.BaseObjectSpace,'Securityroles', ReplaceStr(cbStores.Text,'"','')) ;
             aDruh_nepritomnosti_ID:=iGetIDByNameDF(msite.BaseObjectSpace,'DefRollData', 'CAMPKBJGKKXOR50C4FVP21UIV4',ReplaceStr(cbDruhy.Text,'"','')) ;
             aDruh_nepritomnosti:= copy( ReplaceStr(cbDruhy.Text,'"','') + ' - ' +mEdtSrc.Text,1,100);
             //iGetIDByDefrolldataName(TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.ObjectSpace,'Defrolldata',quotedstr('CAMPKBJGKKXOR50C4FVP21UIV4'), ReplaceStr(cbdruhy.Text,'"','')) ;

             mresult:=NxCRMnepr(msite,1,mBO,aSecurityRole_ID,mDateOd,mdateDo,aDruh_nepritomnosti_ID,aDruh_nepritomnosti);

 //       end;


     end;


   finally
   mForm.free;
   end;

  msite.Refresh;
end;



function iGetIDByName(AOS : TNxCustomObjectSpace; const ATableName : string; ACode : string) : TNxOID;
const
  cSQL = 'SELECT ID FROM %s WHERE Name=''%s'' AND Hidden=''N''';
var
  mR : TStrings;
begin
  Result := '';
  mR := TStringlist.Create;
  try
    AOS.SQLSelect(Format(cSQL, [ATableName, ACode]), mR);
    if mR.Count > 0 then
      Result := mR.strings[0];
  finally
    mR.Free;
  end;
end;

function iGetIDByNameDF(AOS : TNxCustomObjectSpace; const ATableName : string;ACLSID : string ;ACode : string) : TNxOID;
const
  cSQL = 'SELECT ID FROM %s WHERE CLSID = ''%s'' AND Name = ''%s'' and hidden=''N''';
var
  mR : TStrings;
begin
  Result := '';
  mR := TStringlist.Create;
  try
    AOS.SQLSelect(Format(cSQL, [ATableName, aclsid,ACode]), mR);
    if mR.Count > 0 then
      Result := mR.strings[0];
  finally
    mR.Free;
  end;
end;


procedure iFillDruhy(AOS : TNxCustomObjectSpace; AList : Tstrings);
  const
    cSQL = 'SELECT Name FROM DefRollData A WHERE A.CLSID = '+ quotedstr('CAMPKBJGKKXOR50C4FVP21UIV4') + ' and Hidden=''N'' ORDER BY Name';

  begin
//    NxShowSimpleMessage(cSQL,nil);
    AOS.SQLSelect(cSQL, AList);
  end;




  procedure iFillFiltrRoles(AOS : TNxCustomObjectSpace; AList : Tstrings;aname:string);
  const
    cSQL = 'SELECT Name FROM SecurityRoles WHERE Hidden=''N'' and X_Store_ID is not null ORDER BY Name';
  begin
    AOS.SQLSelect(format(cSQL,[aname]), AList);
//    NxShowSimpleMessage(format(cSQL,[aname]),nil);
  end;



procedure NepritomnostOnExecute(Sender: TComponent; Index: integer);
var
 L : TStringList;
 mid:string;
begin
    mbo_CRM_activities:=sender.site.BaseObjectSpace.CreateObject('AVV1JYV5AVNOZHQCK0D4CJFUCS');
    try
       Nepritomnost(Sender,index,mbo_CRM_activities);
    finally
       mbo_CRM_activities.free;
    end;
end;



procedure AfterSiteOpen_Hook(Self: TSiteForm);
begin

end;

procedure DispecerExecuteItem(Sender:Tcomponent; Index: integer);
var
 L : TStringList;
 mid:string;
 mPars:TNxParameters;
 mPar:TNxParameter;
 msite:TSiteForm;
 mr2:TStringList;
 mresult:Boolean;
 adate:Double;
 mdateinput:boolean;
 mResult_mat:boolean;
 mstav:string;
 smresult:string;
 mdate:double;
 mstate:string;
 morigstate:string;
 mr:tstringlist;
 mskupina:string;
 mi:integer;
 mr1:TStringList;
 mtext:string;
 mrxx:TStringList;
 ii:integer;
 mpotvrzeni:string;
 mr_sum:tstringlist;
 mID_zakaznika:string;
 xSite: TSiteForm;
 //xDynSite: TDynSiteForm;
mDBGrid : TDBGrid;
mTabList: TTabSheet;
mBookmark : TBookmarkList;
mbo,mBO_SL,mBONew_SL:TNxCustomBusinessObject;
mBO_SecurityRole:TNxCustomBusinessObject;
mBO_BusProject:TNxCustomBusinessObject;
mBO_ml,mbo_ml1,mBONew_ML:TNxCustomBusinessObject;
mRows_ML,mRows_ML1: TNxCustomBusinessMonikerCollection;
mOLE_SP, mRoll_SP, mOResult_SP: Variant;
mOLE_SL, mRoll_SL, mOResult_SL: Variant;
mOLE_SML, mRoll_SML, mOResult_SML: Variant;
mOLE_ML, mRoll_ML, mOResult_ML: Variant;
mOLE_WorkerRole, mRoll_WorkerRole, mOResult_WorkerRole: Variant;
mIDs_SP,mIDs_SL,mIDs_ML,mIDs_MLRow,mIDs_WorkerRole,mIDs_Storecard:tstringlist;
mID_SP,mID_SL,mID_ML,mID_MLRow:string;
mID_WorkerRole,mID_Store,mID_StoreCard,mid_workSpace:string;
mI_SP,mI_SL,mI_ML,mI_MLRow:integer;
mML_State_ID,mOrigML_State_ID :string;
mD_ML_start,mD_ML_End,mD_SL_start,mD_SL_End,mD_CRM_start,mD_CRM_End:double;
begin
    L := TStringList.Create();
        try
            xSite := TComponent(Sender).Site;
            //xDynSite:=TComponent(Sender).DynSite;
            Sender.Site.List.GetSelectedID(L);
            if Length(trim(l.Text))=10 then begin
                mbo_CRM_activities:=sender.site.BaseObjectSpace.CreateObject('AVV1JYV5AVNOZHQCK0D4CJFUCS');
                Try
                    mid:=trim(l.Text);
                    mbo_CRM_activities.load(mid,nil);

                        if not NxIsEmptyOID(mbo_CRM_activities.GetFieldValueAsString('X_parent_head')) then begin
                              mbo:=sender.site.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                            try
                              mid:='';
                              mr:=tstringlist.create;
                                  //try
                                  //   mbo_CRM_activities.ObjectSpace.SQLSelect('select SA.id from ServiceAssemblyForms2 SA2 left join ServiceAssemblyForms SA on SA2.parent_id=SA.id where sa2.id=' +quotedstr(mbo_CRM_activities.GetFieldValueAsString('X_parent_ID')) + ' group by SA.id',mr);
                                  //   NxShowSimpleMessage(inttostr(mr.count),nil);
                                  //   if mr.count=1 then begin
                                          mbo.load(mbo_CRM_activities.GetFieldValueAsString('X_parent_head'),nil);


                                                  mID_WorkerRole:='';
                                                  mID_StoreCard:='';
                                                  mid_workSpace:='';
                                                  mD_SL_start:= (date) + EncodeTime(7,0,0,0);
                                                  mD_SL_End:=(date) + encodetime(15,30,0,0);

                                                  mIDs_MLRow:=tstringlist.Create;
                                                  if index=0 then begin
                                                  mdateinput:=true;
                                                        mResult_mat:=true;
                                                        mIDs_WorkerRole:=TStringList.Create;
                                                              mOLE_WorkerRole:= GetAbraOLEApplication;
                                                              mOResult_WorkerRole:= mOLE_WorkerRole.CreateStrings;
                                                              mRoll_WorkerRole:= mOLE_WorkerRole.GetRoll('0FKKTBSSQKB4B3RLYBSJFFAFUW', 0);   // sp
                                                              if mRoll_WorkerRole.MultiSelectDialog(True, mOResult_WorkerRole) then mIDs_WorkerRole.Text:= mOResult_WorkerRole.Text;
                                                  end;
                                                 // if index=7 then begin
                                                 //     mstate:=iGetState(xSite);
                                                 // end;


                                                  if index=10 then begin
                                                     mr:=tstringlist.create;
                                                         try
                                                              mbo.ObjectSpace.sqlselect('Select max(X_skupina) from ServiceDocuments',mr);
                                                               if mr.count>0 then mskupina:=inttostr(strtoint(mr.strings[0])+1) else mskupina:='1';
                                                               mresult:=InputQuery('Odeslání k fakturaci - fakturační skupina', 'Automatická nová skupina, nebo zadej číslo existující :',mskupina);

                                                         finally
                                                             mr.free;
                                                         end;
                                                  end;

                                                          mOrigML_State_ID:=mbo.GetFieldValueAsString('X_state');
                                                          if nxstrtoint(mbo.GetFieldValueAsstring('ServiceDocument_ID.ServiceDocState_ID.posindex'))<20 then begin
                                                                      if index=0 then begin  //mMAction1.Items.Add('Zadání technika');
                                                                            mBO_ML:=xSite.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                                                                            try
                                                                                mBO_ML:= mbo;
                                                                                mRows_ML := mBO_ML.GetCollectionMonikerForFieldCode(mBO_ML.GetFieldCode('Rows'));
                                                                                mresult:=GetTechnik(xSite,mbo_ml,mRows_ML,mIDs_WorkerRole,mDateinput);
                                                                                if not mresult then begin
                                                                                    NxShowSimpleMessage('Při zadání technika došlo k chybě:',nil);
                                                                                end else begin
                                                                                    mBO_ML.SetFieldValueAsString('X_state','4U12000101');
                                                                                    mBO_ML.SetFieldValueAsinteger('AssemblyState',trunc(NxIBStrToFloat(mBO_ML.getFieldValueAsString('X_state.X_field2'))));

                                                                                 end;
                                                                                mBO_ml.save;
                                                                                   mi:=mbo.ObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' +QuotedStr(mBO_ML.getFieldValueAsString('X_state.X_field1'))+ ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;

                                                                                mID_ML:=mbo_ml.oid;
                                                                            finally
                                                                                mbo_ml.free;
                                                                            end;
                                                                      end;
                                                                      if index=1 then begin  //mMAction1.Items.Add('Rozpočet fakturace');
                                                                            mBO_ML:=xSite.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                                                                            try
                                                                                mBO_ML:= mbo;
                                                                                mRows_ML := mBO_ML.GetCollectionMonikerForFieldCode(mBO_ML.GetFieldCode('Rows'));
                                                                                mresult:=Fakturacni_ceny(mBO_ML,xSite,mRows_ML,mstav);
                                                                                if not mresult then begin
                                                                                    NxShowSimpleMessage('Při rozpočtu fakturace došlo k chybě:',nil);
                                                                                end else begin
                                                                                    mBO_ML.SetFieldValueAsString('X_state','3Q22000101');
                                                                                    mBO_ML.SetFieldValueAsinteger('AssemblyState',trunc(NxIBStrToFloat(mBO_ML.getFieldValueAsString('X_state.X_field2'))));
                                                                                    mBO_ml.save;
                                                                                    mID_ML:=mbo_ml.oid;
                                                                                    mi:=mbo.ObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' +QuotedStr(mBO_ML.getFieldValueAsString('X_state.X_field1'))+ ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                                                                end;

                                                                            finally
                                                                                mbo_ml.free;
                                                                            end;

                                                                      end;
                                                                      if index=2 then begin  //mMAction1.Items.Add('Zadání materiálu');
                                                                         mBO_ML:=xSite.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                                                                            try
                                                                                mBO_ML:= mbo;
                                                                                mRows_ML := mBO_ML.GetCollectionMonikerForFieldCode(mBO_ML.GetFieldCode('Rows'));
                                                                                mresult:=NEWMaterial(mBO_ml,xsite,mRows_ml);
                                                                                if not mresult then begin
                                                                                  NxShowSimpleMessage('Při zadávání materiálu došlo k chybě:',nil);
                                                                                end else begin
                                                                                    mBO_ML.SetFieldValueAsString('X_state','45W1000101');
                                                                                    mBO_ML.SetFieldValueAsinteger('AssemblyState',trunc(NxIBStrToFloat(mBO_ML.getFieldValueAsString('X_state.X_field2'))));
                                                                                 end;
                                                                                mBO_ml.save;
                                                                                   mi:=mbo.ObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_State=' + quotedstr('45W1000101') + ', AssemblyState=1 where id=' + QuotedStr(mBO_ML.oid));
                                                                                   mi:=mbo.ObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' +QuotedStr(mBO_ML.getFieldValueAsString('X_state.X_field1'))+ ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;

                                                                                mID_ML:=mbo_ml.oid;
                                                                            finally
                                                                                mbo_ml.free;
                                                                            end;


                                                                      end;
                                                                      if index=3 then begin  //mMAction1.Items.Add('textu');
                                                                      mBO_ML:=xSite.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                                                                            try
                                                                                mBO_ML:= mbo;
                                                                                mRows_ML := mBO_ML.GetCollectionMonikerForFieldCode(mBO_ML.GetFieldCode('Rows'));
                                                                                mresult:=NEWtext(mBO_ml,xsite,mRows_ml);
                                                                                if not mresult then begin
                                                                                  NxShowSimpleMessage('Při zadávání textu došlo k chybě:',nil);
                                                                                end else begin
                                                                                 end;
                                                                                mBO_ml.save;
                                                                               mID_ML:=mbo_ml.oid;
                                                                            finally
                                                                                mbo_ml.free;
                                                                            end;
                                                                      end;
                                                                      if index=4 then begin  //mMAction1.Items.Add('Cenová nabídka');
                                                                           mBO_ML:=xSite.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                                                                            try
                                                                                mBO_ML:= mbo;
                                                                                mRows_ML := mBO_ML.GetCollectionMonikerForFieldCode(mBO_ML.GetFieldCode('Rows'));
                                                                                   mrxx:=TStringList.create;
                                                                                   try
                                                                                          mbo.ObjectSpace.SQLSelect('select SA2.id from ServiceAssemblyForms2 SA2 left join ServiceAssemblyForms sa on SA.ID=sa2.Parent_ID where sa2.ToInvoiceType=0 and sa2.IsInvoiced=0 and sa.id=' + quotedstr(mBO_ML.OID)+' order by PosIndex',mrxx);
                                                                                          for ii := 0 to mrxx.Count-1 do begin // projdu vsechny oznacene zaznamy
                                                                                               mIDs_MLRow.Add(mrxx.Strings[ii]);
                                                                                          end;
                                                                                   finally

                                                                                       mrxx.free;
                                                                                   end;



                                                                                smresult:=CNExecuteItem(mBO_ML,TDynSiteForm(xSite),mRows_ml,mIDs_MLRow);
                                                                                if smresult='' then begin
                                                                                    NxShowSimpleMessage('Při cenové nabídce došlo k chybě:',nil);
                                                                                end else begin

                                                                                    mi:=mbo.ObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_State=' + quotedstr('4XQ1000101') + ', AssemblyState=1 where id=' + QuotedStr(mBO_ML.oid));
                                                                                    mi:=mbo.ObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' +QuotedStr('9000000101')+ ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;

                                                                                end;
                                                                                 mID_ML:=mbo_ml.oid;
                                                                            finally
                                                                                mbo_ml.free;
                                                                            end;
                                                                      end;
                                                                      if index=5 then begin  //mMAction1.Items.Add('Zajištění materiálu');
                                                                           mBO_ML:=mbo.ObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                                                                            try
                                                                                mdate:=getdate2(xsite);
                                                                                mBO_ML:= mbo;
                                                                                mRows_ML := mBO_ML.GetCollectionMonikerForFieldCode(mBO_ML.GetFieldCode('Rows'));
                                                                                smresult:=zajisteni_zasob(xSite,mBO_ML,mDate);
                                                                                //if smresult='' then NxShowSimpleMessage('Při cenové nabídce došlo k chybě:',nil);

                                                                                    //mBO_ml.save;
                                                                                    //mBO_ml.Refresh;

                                                                                mBO_ml.Refresh;
                                                                                mi:=mbo.ObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_Stav_objednani=1 where id=' + QuotedStr(mBO_ML.oid));
                                                                                mi:=mbo.ObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_State=' + quotedstr('3IS1000101') + ', AssemblyState=1 where id=' + QuotedStr(mBO_ML.oid));
                                                                                mi:=mbo.ObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' +QuotedStr('A102000000')+ ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                                                                mID_ML:=mbo_ml.oid;

                                                                            finally
                                                                                mbo_ml.free;
                                                                            end;
                                                                      end;
                                                                      if index=6 then begin  //mMAction1.Items.Add('Vyskladnění materiálu');
                                                                       mBO_ML:=mbo.ObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                                                                            try
                                                                                mdate:=getdate2(xsite);
                                                                                mBO_ML:= mbo;
                                                                                mRows_ML := mBO_ML.GetCollectionMonikerForFieldCode(mBO_ML.GetFieldCode('Rows'));
                                                                                smresult:=Vyskladneni_zasob(xSite,mBO_ML,mdate);
                                                                                mBO_ml.SetFieldValueAsString('X_State','3Q22000101');
                                                                                mBO_ml.Save;
                                                                                mi:=mbo.ObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_State=' + quotedstr('3Q22000101') + ', AssemblyState=1 where id=' + QuotedStr(mBO_ML.oid));
                                                                                mi:=mbo.ObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' +QuotedStr('A102000000')+ ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;

                                                                                //       mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_State=' + quotedstr('3Q22000101') + ', AssemblyState=1 where id=' + QuotedStr(mBO_ML.oid));

                                                                                //mBO_ML.SetFieldValueAsString('X_state','');
                                                                                //    mBO_ML.SetFieldValueAsinteger('AssemblyState',trunc(NxIBStrToFloat(mBO_ML.getFieldValueAsString('X_state.X_field2'))));
                                                                                //mBO_ml.save;

                                                                               mID_ML:=mbo_ml.oid;
                                                                            finally
                                                                                mbo_ml.free;
                                                                            end;
                                                                      end;
                                                                      if index=7 then begin  //mMAction1.Items.Add('Stav ML');
                                                                      mBO_ML:=sender.site.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                                                                            try
                                                                                mpotvrzeni:='ANO';
                                                                                mBO_ML:= mbo;
                                                                                mRows_ML := mBO_ML.GetCollectionMonikerForFieldCode(mBO_ML.GetFieldCode('Rows'));
                                                                                mOrigState:=mBO_ML.GetFieldValueAsstring('X_State');

                                                                                if mstate<>'' then begin

                                                                                      if (mstate='6XQ1000101') or (mstate='AXQ1000101')  or (mstate='3JS1000101') or  then begin
                                                                                                  // ** není vydán všechen materiál
                                                                                                  mr:=TStringList.create;
                                                                                                  try
                                                                                                     mbo.ObjectSpace.SQLSelect('Select sum(Quantity-QuantityDelivered) from ServiceAssemblyForms2 where ItemType =1 and x_storno=' + quotedstr('N') + 'and parent_id=' + quotedstr(mBO_ml.OID),mr);
                                                                                                     if strtoint(mr.Strings[0])<>0 then begin
                                                                                                        mpotvrzeni:=InputBox('Není vydán všechen materiál. ','Přesto pokračovat? ',mpotvrzeni, xsite);
                                                                                                        //mstav_rozprac:=copy(mstav_rozprac,1,3)+'A'+copy(mstav_rozprac,5,4)  ;

                                                                                                     end;
                                                                                                  finally
                                                                                                     mr.free;
                                                                                                  end;
                                                                                                  // na ML není uvedena žádná práce
                                                                                                  mr1:=TStringList.create;
                                                                                                  try
                                                                                                     mbo.ObjectSpace.SQLSelect('Select count(id) from ServiceAssemblyForms2 where (ItemType =4 and text=' + quotedstr('Práce - evidenční pro mzdy') + ')  or (ItemType =0 and storecard_id=' + quotedstr('2ZI1000101') +' )and parent_id=' + quotedstr(mbo.OID),mr1);
                                                                                                     if (mpotvrzeni='ANO') and (strtoint(mr1.Strings[0])=0) then begin
                                                                                                        mpotvrzeni:=InputBox('Není zadána žádná práce. ','Přesto pokračovat? ',mpotvrzeni, xsite);
                                                                                                        //mstav_rozprac:=copy(mstav_rozprac,1,1)+'A'+copy(mstav_rozprac,3,6)  ;
                                                                                                     end;
                                                                                                  finally
                                                                                                     mr1.free;
                                                                                                  end;
                                                                                                  // ** není rozpočítaná všechna práce
                                                                                                  mr2:=TStringList.create;
                                                                                                  try
                                                                                                    mbo.ObjectSpace.SQLSelect('Select count(id) from ServiceAssemblyForms2 where ItemType =0 and storecard_id=' + quotedstr('2ZI1000101') + 'and parent_id=' + quotedstr(mbo.OID),mr2);
                                                                                                     if (mpotvrzeni='ANO') and (strtoint(mr2.Strings[0])<>0) then begin
                                                                                                        mpotvrzeni:=InputBox('Není rozpočítaná práce žádná práce. ','Přesto pokračovat? ',mpotvrzeni, xsite);
                                                                                                        //mstav_rozprac:=copy(mstav_rozprac,1,2)+'A'+copy(mstav_rozprac,4,5)  ;
                                                                                                     end;
                                                                                                  finally
                                                                                                     mr2.free;
                                                                                                  end;
                                                                                                 end;

                                                                                                if UpperCase(Trim(mpotvrzeni))='ANO' then begin
                                                                                                    //mbo.setFieldValueAsstring('X_State',mstate);
                                                                                                    //mbo.SetFieldValueAsInteger('AssemblyState',StrToInt(mbo.getFieldValueAsstring('X_State.X_Field2')));
                                                                                                    if not nxisblank(copy(mbo_ML.GetFieldValueAsString('serviceDocument_id.ServicedObject_id.X_Ukonceni'),1,100)) then begin
                                                                                                        NxShowSimpleMessage('Upozornění: '+ trim(copy(mbo.GetFieldValueAsString('serviceDocument_id.ServicedObject_id.X_Ukonceni'),1,254)),nil);
                                                                                                    end;


                                                                                                end;

                                                                                                 if UpperCase(Trim(mpotvrzeni))='ANO' then begin
                                                                                                     mBO_ML.SetFieldValueAsDateTime('X_ClosedDate$DATE',date);
                                                                                                     mBO_ML.SetFieldValueAsstring('X_State',mstate);
                                                                                                     mBO_ML.SetFieldValueAsinteger('AssemblyState',trunc(NxIBStrToFloat(mBO_ML.getFieldValueAsString('X_state.X_field2'))));
                                                                                                     mBO_ML.save;
                                                                                                     mi:=mbo.ObjectSpace.SQLExecute('Update ServiceDocuments set X_VatDate=' +NxFloatToIBStr(mBO_ML.getFieldValueAsDateTime('EndDate$DATE'))+ ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                                                                      end else begin
                                                                                          mBO_ML.SetFieldValueAsstring('X_State',mstate);
                                                                                          mpotvrzeni:='A';
                                                                                          mBO_ML.SetFieldValueAsinteger('AssemblyState',trunc(NxIBStrToFloat(mBO_ML.getFieldValueAsString('X_state.X_field2'))));
                                                                                          mBO_ML.save;
                                                                                      end;


                                                                                      mID_ML:=mbo_ml.oid;
                                                                                      mr:=TStringList.create;
                                                                                      try


                                                                                            mbo.ObjectSpace.SQLSelect('select id from ServiceAssemblyForms where ServiceDocument_ID=' + QuotedStr(mBO_ML.GetFieldValueAsString('ServiceDocument_ID')) +
                                                                                                ' and x_state<>' + quotedstr('38S1000101')+ '  and x_state<>'+ quotedstr('6XQ1000101')
                                                                                                + '  and x_state<>'+ quotedstr('AXQ1000101')+ '  and x_state<>'+ quotedstr('3JS1000101')+ '  and x_state<>'+ quotedstr('3VW1000101')
                                                                                                + '  and x_state<>'+ quotedstr('3AU1000101')+ '  and x_state<>'+ quotedstr('8XQ1000101')+ '  and x_state<>'+ quotedstr('9XQ1000101')
                                                                                            ,mr) ;


                                                                                                if mr.count<1 then begin
                                                                                                    mi:=mbo.ObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' +QuotedStr(mBO_ML.getFieldValueAsString('X_state.X_field1'))+ ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                                                                                end;
                                                                                      finally
                                                                                          mr.free;
                                                                                      end;
                                                                                     end;

                                                                             finally
                                                                               mBO_ML.free;
                                                                             end;
                                                                      end;
                                                                      if index=8 then begin  //mMAction1.Items.Add('');
                                                                      end;
                                                          end;
                                                                      if index=9 then begin  //mMAction1.Items.Add('Doplnění čísla objednávky');
                                                                          mBO_ML:=sender.site.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                                                                            try
                                                                                mBO_ML:= mbo;
                                                                                     mtext:=mbo_ml.GetFieldValueAsString('ServiceDocument_ID.X_objednani');
                                                                                     mresult:=InputQuery('Číslo objednávky', 'Objednávka zákazníka :',mtext);
                                                                                     if mresult then  mi:=mbo.ObjectSpace.SQLExecute('Update ServiceDocuments set X_objednani=' + quotedstr(mtext) + ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                                                            finally
                                                                                mbo_ml.free;
                                                                            end;

                                                                      end;

                                                          if index=10 then begin  //mMAction1.Items.Add('Odeslání k fakturaci');
                                                              mBO_ML:=sender.site.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                                                                try
                                                                    mBO_ML:= mbo;
                                                                         mr1:=tstringlist.create;
                                                                            try
                                                                                mbo.ObjectSpace.SQLSelect('select id from ServiceAssemblyForms where ServiceDocument_ID=' + QuotedStr(mBO_ML.GetFieldValueAsString('ServiceDocument_ID')) +
                                                                                ' and x_state<>' + quotedstr('38S1000101')+ '  and x_state<>'+ quotedstr('6XQ1000101')
                                                                                + '  and x_state<>'+ quotedstr('AXQ1000101')+ '  and x_state<>'+ quotedstr('3JS1000101')+ '  and x_state<>'+ quotedstr('3VW1000101')
                                                                                + '  and x_state<>'+ quotedstr('3AU1000101')+ '  and x_state<>'+ quotedstr('8XQ1000101')+ '  and x_state<>'+ quotedstr('9XQ1000101')
                                                        ,mr1) ;
                                                                                if mr1.count=0 then begin

                                                                                              if mresult then begin
                                                                                                   mi:=mbo.ObjectSpace.SQLExecute('Update ServiceDocuments set X_skupina=' + mskupina + ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;

                                                                                                              mr_sum:=TStringList.create;
                                                                                                              try
                                                                                                               mbo.ObjectSpace.SQLSelect('select trunc(sum((SA2.UnitPriceWithoutVAT*SA2.Quantity) -(SA2.UnitPriceWithoutVAT*SA2.Quantity*0.01*SA2.X_radkova_sleva) ))  from ServiceAssemblyForms2 SA2 '
                                                                                                                                              +
                                                                                                                                              ' left join ServiceAssemblyForms SA on sa.id=SA2.Parent_ID left join ServiceDocuments SD on SD.id=SA.ServiceDocument_ID'

                                                                                                                                              +' where SA2.itemtype=1 and SA2.ToInvoiceType=0 and sd.GuarantyRepair<>2 and SD.ID=' + quotedstr(mbo.GetFieldValueAsString('ServiceDocument_ID')),mr_sum);
                                                                                                               if NxIBStrToFloat(mr_sum.strings[0])<>0 then

                                                                                                                     mi:=mbo.ObjectSpace.SQLExecute('Update ServiceDocuments set TotalMaterial=' +(mr_sum.strings[0]) + ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;

                                                                                                              finally
                                                                                                                  mr_sum.Free;
                                                                                                              end;

                                                                                                                mr_sum:=TStringList.create;
                                                                                                              try
                                                                                                               mbo.ObjectSpace.SQLSelect('select trunc(sum((SA2.UnitPriceWithoutVAT*SA2.WorkHoursReal) -(SA2.UnitPriceWithoutVAT*SA2.WorkHoursReal*0.01*SA2.X_radkova_sleva)) )  from ServiceAssemblyForms2 SA2 '
                                                                                                                                              +
                                                                                                                                              ' left join ServiceAssemblyForms SA on sa.id=SA2.Parent_ID left join ServiceDocuments SD on SD.id=SA.ServiceDocument_ID'

                                                                                                                                              +' where SA2.itemtype=0 and SA2.ToInvoiceType=0 and sd.GuarantyRepair<>2 and SD.ID=' + quotedstr(mbo.GetFieldValueAsString('ServiceDocument_ID')),mr_sum);
                                                                                                               if NxIBStrToFloat(mr_sum.strings[0])<>0 then
                                                                                                               mi:=mbo.ObjectSpace.SQLExecute('Update ServiceDocuments set TotalWork=' +mr_sum.strings[0] + ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;

                                                                                                               //mbo.SetFieldValueAsFloat('TotalWork',StrToFloat(mr_sum.strings[0]));

                                                                                                              finally
                                                                                                                  mr_sum.Free;
                                                                                                              end;

                                                                                                               mr_sum:=TStringList.create;
                                                                                                              try
                                                                                                               mbo.ObjectSpace.SQLSelect('select trunc(sum((SA2.UnitPriceWithoutVAT*sa2.quantity) -(SA2.UnitPriceWithoutVAT*sa2.quantity*0.01*SA2.X_radkova_sleva)) )  from ServiceAssemblyForms2 SA2 '
                                                                                                                                              +
                                                                                                                                              ' left join ServiceAssemblyForms SA on sa.id=SA2.Parent_ID left join ServiceDocuments SD on SD.id=SA.ServiceDocument_ID'

                                                                                                                                              +' where SA2.itemtype>1 and SA2.ToInvoiceType=0 and sd.GuarantyRepair<>2 and SD.ID=' + quotedstr(mbo.GetFieldValueAsString('ServiceDocument_ID')),mr_sum);
                                                                                                               if NxIBStrToFloat(mr_sum.strings[0])<>0 then
                                                                                                               mi:=mbo.ObjectSpace.SQLExecute('Update ServiceDocuments set TotalOther=' + mr_sum.strings[0] + ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;

                                                                                                              //  mbo.SetFieldValueAsFloat('',StrToFloat(mr_sum.strings[0]));

                                                                                                              finally
                                                                                                                  mr_sum.Free;
                                                                                                              end;

                                                                                                              mi:=mbo.ObjectSpace.SQLExecute('Update ServiceDocuments set TotalAmount=(TotalMaterial+TotalWork+TotalOther) where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;






                                                                                                   if mstate='6XQ1000101' then begin
                                                                                                        mi:=mbo.ObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' + QuotedStr('D102000000') + ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                                                                                       // mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_State=' + quotedstr('8XQ1000101') + ' where ServiceDocument_ID=' + QuotedStr(mBO_ML.GetFieldValueAsString('ServiceDocument_ID')) +
                                                                                                       //       ' and x_state<>'+ quotedstr('3Q22000101'));
                                                                                                        mi:=mbo.ObjectSpace.SQLExecute('Update ServiceAssemblyForms set AssemblyState=3 where ServiceDocument_ID=' + QuotedStr(mBO_ML.GetFieldValueAsString('ServiceDocument_ID')) +
                                                                                                              ' and x_state<>'+ quotedstr('3Q22000101'));

                                                                                                   end else begin
                                                                                                           mi:=sender.site.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' + QuotedStr('D102000000') + ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;

                                                                                                   end;
                                                                                              end;




                                                                                end else begin
                                                                                   NxShowSimpleMessage('Existují neukončené ML. Nejdříve je ukončete',nil)

                                                                                end
                                                                            finally
                                                                                mr1.free;
                                                                            end;


                                                                        //mBO_ML.save ;
                                                                        mID_ML:=mbo_ml.oid;
                                                                 finally
                                                                   mBO_ML.free;
                                                                 end;
                                                          end;
                                                          if index=11 then begin  //mMAction1.Items.Add('');
                                                          end;

                                                          if index=12 then begin  //mMAction1.Items.Add('Změna záruky');
                                                              if nxstrtoint(mbo.GetFieldValueAsstring('ServiceDocument_ID.ServiceDocState_ID.posindex'))<20 then begin
                                                                  mBO_ML:=mbo.ObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                                                                        try

                                                                            mBO_ML:= mbo;
                                                                            if mBO_ML.GetFieldValueAsInteger('ServiceDocument_ID.GuarantyRepair')=2 then begin
                                                                                  mi:=mbo.ObjectSpace.SQLExecute('Update ServiceDocuments set GuarantyRepair=3 where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                                                                  NxShowSimpleMessage('Proběhla změna na placenou opravu',nil);
                                                                            end else begin
                                                                                  mi:=mbo.ObjectSpace.SQLExecute('Update ServiceDocuments set GuarantyRepair=2 where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                                                                  NxShowSimpleMessage('Proběhla změna na garanční opravu',nil);
                                                                            end;
                                                                           mBO_ML.save ;
                                                                        mID_ML:=mbo_ml.oid;
                                                                         finally
                                                                           mBO_ML.free;
                                                                         end;
                                                                  end;
                                                          end;
                                                           if index=13 then begin  //mMAction1.Items.Add('Změna závady');
                                                              if nxstrtoint(mbo.GetFieldValueAsstring('ServiceDocument_ID.ServiceDocState_ID.posindex'))<20 then begin
                                                                  mBO_ML:=mbo.ObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                                                                        try
                                                                        mskupina:=copy(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID.DamageDescription'),1,254);
                                                                        mresult:=InputQuery('Zadejte závadu', 'Závada: ',mskupina);
                                                                            mBO_ML:= mbo;
                                                                            if mresult then begin
                                                                                  mi:=mbo.ObjectSpace.SQLExecute('Update ServiceDocuments set DamageDescription='+ quotedstr(mskupina) + ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                                                            end;
                                                                           mBO_ML.save ;
                                                                        mID_ML:=mbo_ml.oid;
                                                                         finally
                                                                           mBO_ML.free;
                                                                         end;
                                                                  end;
                                                          end;

















                                     //end else begin
                                     // NxShowSimpleMessage('Je dohledáno více záznamů, nelze pokračovat',nil);
                                     //end;
                                  //finally
                                  //    mr.free;
                                  //end;


                            finally
                              mbo_ServiceAssembyFormRows.free;
                            end;

                        end else begin
                                   NxShowSimpleMessage('Doklad nemá vazbu na servis',nil);
                        end;


                    //NxShowSimpleMessage('id: ' + mbo.GetFieldValueAsString('subject'), nil);

                finally
                   mbo_CRM_activities.free;
                end;

            end else begin
                    NxShowSimpleMessage('Není vybrána pouze jedna zdojová aktivita',nil);
            end;
        finally
            L.Free;
        end;
end;


procedure ShowDocExecuteItem(Sender:Tcomponent; Index: integer);
var
 mSite:TsiteForm;
 mList, mList2:TStringList;
 mParams: TNxParameters;
  mParam: TNxParameter;
  mcaption:string;
  mr:TStringList;
  m_workSpace_id:string;
begin
  mSite := TComponent(Sender).Site;
  mr:=TStringList.create;
  try
   msite.BaseObjectSpace.SQLSelect('select X_workSpace_id from SecurityUsers where id=' + quotedstr(msite.SiteContext.GetCompanyCache.GetUserID),mr);
     if mr.count>0 then begin
         m_workSpace_id:=mr.Strings[0];
     end;
  finally
      mr.free;
  end;


  mList :=TStringList.create;
  mList2 := TstringList.Create;
  if Assigned(msite) then begin
      msite.List.GetSelectedId(mList);
      // bez technika
      if index=0 then begin

         msite.BaseObjectSpace.SQLSelect('select distinct H.id from ServiceAssemblyForms H where h.AssemblyState<>3 And h.EndDate$DATE<='+ NxFloatToIBStr(Now + 30) + ' and h.ServiceWorkSpace_ID=' + quotedstr(m_workSpace_id),mlist2);
         mcaption:='Nezaplánované do 30 dní';
      end;
      // neprovedené do dneška
      if index=1 then begin
       msite.BaseObjectSpace.SQLSelect('select H.id from ServiceAssemblyForms H left join ServiceAssemblyForms2 R on r.parent_id=H.id where ((r.text<>' + quotedstr('Práce - evidenční pro mzdy')+ ')) and (h.EndDate$DATE<='+ NxFloatToIBStr(Now + 7)+')' + ' and h.ServiceWorkSpace_ID=' + quotedstr(m_workSpace_id) + ' group by h.id',mlist2);
       mcaption:='Neprovedené + 7 dnů';
      end;
      //  aktiální
      if index=2 then begin
         msite.BaseObjectSpace.SQLSelect('select distinct H.id from ServiceAssemblyForms H left join ServiceAssemblyForms2 R on r.parent_id=H.id left join CRMActivities CRM on crm.X_parent_head=h.id where crm.id=' + quotedstr(mlist.Strings[0]),mlist2);
         mcaption:='Aktuální ML ';
      end;
      if mlist2.Count>0 then begin
        mParams := TNxParameters.Create;
       try
        mParams.NewFromDataType(dtString, '_SelectionCaption', pkUnknown).AsString := mcaption;
        mParam := mParams.NewFromDataType(dtList, '_DefaultSelection', pkUnknown) ;
        mParam := mParam.AsList.NewFromDataType(dtList, 'CONDITIONS', pkUnknown) ;
        mParam := mParam.AsList.NewFromDataType(dtList, 'ID', pkUnknown) ;
        mParam.AsList.NewFromDataType(dtInteger, 'USEDKIND', pkUnknown).AsInteger := 3; //3 = ckList&#xD;
        mParam.AsList.NewFromDataType(dtString, 'VALUELIST', pkUnknown).AsString := NxStringsToCkListStr(mList2);
        ShowDynForm('5H5Q1YT0BNE45EFK3SPKR4AD4S',msite.SiteContext, mParams, nil, true);
       finally
        mParams.free;
       end;


      end;
 end;
end;

procedure iFillDocqueue(AOS : TNxCustomObjectSpace; AList : Tstrings;aname:string);
  const
    cSQL = 'SELECT Name FROM DocQueues WHERE Hidden=''N'' and DocumentType=''%s'' ORDER BY Name';
  begin
    AOS.SQLSelect(format(cSQL,[aname]), AList);
//    NxShowSimpleMessage(format(cSQL,[aname]),nil);
  end;

  procedure iFillDocqueue_code(AOS : TNxCustomObjectSpace; AList : Tstrings;aname:string;aCode:string);
  const
    cSQL = 'SELECT Name FROM DocQueues WHERE Hidden=''N'' and DocumentType=''%s'' and substring(Code from 1 for 2)=''%s'' ORDER BY Name';
  begin
    AOS.SQLSelect(format(cSQL,[aname,copy(acode,1,2)]), AList);
//    NxShowSimpleMessage(format(cSQL,[aname]),nil);
  end;


procedure iFillDivision(AOS : TNxCustomObjectSpace; AList : Tstrings;aname:string);
  const
    cSQL = 'SELECT Name FROM Divisions WHERE Hidden=''N'' and substring(name from 7 for 18)=''%s'' ORDER BY Name';
  begin
    AOS.SQLSelect(format(cSQL,[aname]), AList);
//    NxShowSimpleMessage(format(cSQL,[aname]),nil);
  end;



  function iGetCodeByName(AOS : TNxCustomObjectSpace; const ATableName : string; ACode : string) : TNxOID;
const
  cSQL = 'SELECT Code FROM %s WHERE Name=''%s'' AND Hidden=''N''';
var
  mR : TStrings;
begin
  Result := '';
  mR := TStringlist.Create;
  try
    AOS.SQLSelect(Format(cSQL, [ATableName, ACode]), mR);
    if mR.Count > 0 then
      Result := mR.strings[0];
  finally
    mR.Free;
  end;
end;


procedure NEWSLExecuteItem(Sender:Tcomponent; Index: integer);
var
mDamageDescription:string;
mForm: TForm;
i:integer;
mr:tstringlist;
mresult:boolean;
mdate:date;
mDateinput,mResult_mat:boolean;
mBO_MLNew:TNxCustomBusinessObject;
mrta:tstringlist;
mOLE_DV, mRoll_DV, mOResult_DV,mOLE_DQ, mRoll_DQ, mOResult_DQ,mOLE_WR, mRoll_WR, mOResult_WR: Variant;
mD_ML_start,mD_ML_End,mD_SL_start,mD_SL_End,mD_CRM_start,mD_CRM_End,mF_pausal_prace,mF_pausal_Vyjezd,mF_prace,mF_km,mFSazba_hod_den,mFDoprava_km,mF_doprava_pausal,mFSazba_hod:double;
   mF_doba,mF_Prace_od,mF_Prace_do,mF_Prac_doba_zac,mF_Prac_doba_kon:double;        // jen časová část
   mFSazba_Prace_pausal,mFSazba_Prace,mFSazba_Mimo,mFSazba_Vikend,mFSazba_Svatek,mFSazba_Doprava_km,mFSazba_Doprava_pausal,mFPriplatek3H:double;
   mF_Mnozstvi_Prace_pausal,F_Mnozstvi_Prace,mF_Mnozstvi_mimo,mF_Mnozstvi_vikend,mF_Mnozstvi_svatek,mF_Mnozstvi_Doprava_km,mF_Mnozstvi_Doprava_pausal:double;
  mstore_id:string;
   mDateFrom,mDateto,mDatezac,mDatekon,mPRzac,mPRkon:Double;
  msleva:double;
 mF_svatek,mF_vikend,mF_mimo,mFS_svatek,mFS_vikend,mFS_mimo,mFS_prace:double;
  mrole_id:string;
 mDnu:integer;
 mOpakovani:integer;
 mBO_ML_ROW:TNxCustomBusinessObject;
 mStore:string;
  mForm1 : TForm;
  mBtn : TButton;
  mKonecDAte:TDateTimeEdit;
  mKonecTime:TTimeEdit;
  mL_Technik,mL_Technik1,mL1_C_Protokol,mL1_pohotovost,mL1_C_Chyby,mL_technik_value,mL_technik1_value:TLabel;
  mL_operation,mL1_operation:TLabel ;
  mEd1_pohotovost:TCheckBox;
  mEd1_C_chyby,mEd1_C_protokol:tedit;
  mEd1_quantity,mEd_quantity,mEd_Unitprice,mEd_quantity1,mEd_Unitprice1,mEd_quantity2,mEd_Unitprice2,mEd_quantity3,mEd_Unitprice3,mEd_quantity4,mEd_Unitprice4,mEd_quantity5,mEd_Unitprice5,mEd_quantity6,mEd_Unitprice6,mEd_quantity7,mEd_Unitprice7,mEd_quantity8,mEd_Unitprice8,mEd_quantity9,mEd_Unitprice9,mEd_quantity10,mEd_Unitprice10,mED1_P_Cyklu:TEdit;
  mquantity:double;
  mWorkHoursReal:Double;
  mkorekce:Double;
  mpocet_km:Double;
  mLabel1,mLabel2,mLblm,mLbl1,mLbl2,mLbl0,mLbl3,mLabel3 ,mL1_P_Cyklu: TLabel;
  mEdtDAte:TDateEdit;
    mEdtDAte1:TTimeEdit;
    mID_WorkerRole,mid_workSpace:string;
    mEdtSrc:TEdit;
    mBO_BusProject:TNxCustomBusinessObject;
    mI_WorkerRole:integer;
    ID_result,mID_StoreCard:string;
    mkoeficient,mkoeficient_korekce:Double;
    mrGT:TStringList;
   mRows_MLNew:TNxCustomBusinessMonikerCollection;
   mIDs_DQ,mIDs_DV:tstringlist;
mRow,mNewRow, mbo1,mbo_ml_target_row,mOrderRow,mNewRows: TNxCustomBusinessObject;
mMon : TNxCustomBusinessMonikerCollection;
mWorkerRole_ID:string;
mPosIndex,mpocet,mpocet1,mI_MLRow:Integer;
mRow_Pomoc:TNxCustomBusinessObject;
mList_pomoc:tstringlist;
mi,i01,ii,mhour,mmin,msek,mmsek:integer;
mpausal,mpausal_oprava:double;
mCRMresult:Boolean;
mID_DV,mID_DQ:string;
cbDocqueues,cbDivisions: TComboBox;//TRollComboEdit;
mcode:string;
mxpomoc:double;
muser,mbo:TNxCustomBusinessObject;
mServiceType_ID:string;
mB_pokracovat:boolean;
xsite:TSiteForm;
l:TStringList;
begin
   mB_pokracovat:=false;
//
      mID_WorkerRole:='';
   mID_WorkerRole:='';
   mID_StoreCard:='';
   mid_workSpace:='';
   mD_SL_start:= (date) + EncodeTime(7,0,0,0);
   mD_SL_End:=(date) + encodetime(15,25,0,0);

    L := TStringList.Create;
        try
            xSite := TComponent(Sender).Site;
            //xDynSite:=TComponent(Sender).DynSite;
            Sender.Site.List.GetSelectedID(L);
            if Length(trim(l.Text))=10 then begin
                mbo_CRM_activities:=sender.site.BaseObjectSpace.CreateObject('AVV1JYV5AVNOZHQCK0D4CJFUCS');
                Try
                    mid:=trim(l.Text);
                    mbo_CRM_activities.load(mid,nil);

                        if not NxIsEmptyOID(mbo_CRM_activities.GetFieldValueAsString('X_parent_head')) then begin
                              mbo:=sender.site.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                            try
                              mid:='';
                              mr:=tstringlist.create;
                                  //try
                                  //   mbo_CRM_activities.ObjectSpace.SQLSelect('select SA.id from ServiceAssemblyForms2 SA2 left join ServiceAssemblyForms SA on SA2.parent_id=SA.id where sa2.id=' +quotedstr(mbo_CRM_activities.GetFieldValueAsString('X_parent_ID')) + ' group by SA.id',mr);
                                  //   NxShowSimpleMessage(inttostr(mr.count),nil);
                                  //   if mr.count=1 then begin
                                          mbo.load(mbo_CRM_activities.GetFieldValueAsString('X_parent_head'),nil);

                                              //NxShowSimpleMessage('ML' + mbo_CRM_activities.GetFieldValueAsString('X_parent_head'),nil);


    if index=0 then begin
              if (xsite.SiteContext.GetCompanyCache.GetLoginID='1410000101') then begin
                  mD_SL_start:= GetDate(Sender,xSite) ;
                  mD_SL_start:= trunc(mD_SL_start) + EncodeTime(7,0,0,0);
                  mD_SL_End:=trunc(mD_SL_start) + encodetime(15,30,0,0);
              end;


                                  mForm := TForm.Create(xsite);
                                  mForm.Caption := 'Zadejte údaje SL';
                                  mForm.FormStyle := fsStayOnTop;
                                  mForm.BorderStyle := bsDialog;
                                  mForm.Width := 550;
                                  mForm.Height := 170;
                                  mForm.Scaled := False;
                                  mform.Position := poScreenCenter;

                                  mLabel3 := TLabel.Create(mForm);
                                  mLabel3.Parent := mForm;
                                  mLabel3.Caption := 'Typ servisu :';
                                  mLabel3.Top := 10;
                                  mLabel3.Left := 10;
                                  mLabel3.Height := 13;


                                    cbDocqueues := TComboBox.Create(mForm);
                                    cbDocqueues.Left := 100;
                                    cbDocqueues.Top := 10;
                                    cbDocqueues.Width := 200;
                                    cbDocqueues.Name := 'cbDocqueue';
                                    cbDocqueues.Text := '';
                                    mForm.InsertControl(cbDocqueues);
                                    iFillDocqueue_code(xsite.BaseObjectSpace,cbDocqueues.Items,'SL','SL');
                                     if cbDocqueues.Items.Count >= 0 then begin
                                      cbDocqueues.ItemIndex := 0;
                                    end;

                                    if (xSite.CompanyCache.GetUserID='1810000101') or (xSite.CompanyCache.GetUserID='2020000101') or (xSite.CompanyCache.GetUserID='SUPER00000') then begin

                                                mLabel2 := TLabel.Create(mForm);
                                              mLabel2.Parent := mForm;
                                              mLabel2.Caption := 'Středisko :';
                                              mLabel2.Top := 40;
                                              mLabel2.Left := 10;
                                              mLabel2.Height := 13;

                                                cbDIvisions := TComboBox.Create(mForm);
                                                cbDIvisions.Left := 100;
                                                cbDIvisions.Top := 40;
                                                cbDIvisions.Width := 200;
                                                cbDIvisions.Name := 'cbDivision';
                                                cbDIvisions.Text := '';
                                                mForm.InsertControl(cbDivisions);
                                                   iFillDivision(xsite.BaseObjectSpace, cbDivisions.Items,'Servisní středisko');
                                                 if cbDIvisions.Items.Count >= 0 then begin
                                                  cbDivisions.ItemIndex := 0;
                                                end;








                                       end;

                                       mL_operation:= TLabel.Create(mForm);
                                                mL_operation.Parent := mForm;
                                                mL_operation.Caption := 'Poškození :';
                                                mL_operation.Top := 70;
                                                mL_operation.Left := 10;
                                                mL_operation.Height := 150;
                                                mL_operation.Width := 80;
                                                mEd_quantity := TEdit.Create(mForm);
                                                mEd_quantity.Left := 100;
                                                mEd_quantity.Top := 60;
                                                mEd_quantity.Width := 430;
                                                mEd_quantity.Name := 'mEd_quantity';
                                                mEd_quantity.Text:='';
                                                mForm.InsertControl(mEd_quantity);

                                mBtn := TButton.Create(mForm);
                                mBtn.Width := 75;
                                mBtn.Height := 25;
                                mBtn.Caption := 'OK';
                                mBtn.ModalResult := mrOk;
                                mBtn.Cancel := False;
                                mBtn.Default := True;
                                mBtn.Left :=  mForm.Width - 2*(mBtn.Width+2) - 20;
                                mBtn.Top := mForm.Height - mBtn.Height - 40;
                                mBtn.Name := 'btnOK';
                                mForm.InsertControl(mBtn);

                                mBtn := TButton.Create(mForm);
                                mBtn.Width := 75;
                                mBtn.Height := 25;
                                mBtn.Caption := 'Storno';
                                mBtn.ModalResult := mrCancel;
                                mBtn.Cancel := True;
                                mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;;
                                mBtn.Top := mForm.Height - mBtn.Height - 40;
                                mBtn.Name := 'btnCancel';
                                mForm.InsertControl(mBtn);

                                try
                                    if mForm.ShowModal(xSite) = mrOK then begin
                                         mB_pokracovat:=true;
                                         mDamageDescription:=mEd_quantity.Text;
                                         mID_DQ:=iGetIDByName(xsite.BaseObjectSpace,'Docqueues', ReplaceStr(cbDocqueues.Text,'"','')) ;
                                        //NxShowSimpleMessage( mID_DQ,nil);

                                        if (xsite.CompanyCache.GetUserID='1810000101') or (xsite.CompanyCache.GetUserID='2020000101') then begin
                                            mID_DV:=iGetIDByName(xsite.BaseObjectSpace,'Divisions', ReplaceStr(cbDivisions.Text,'"','')) ;
                                            mcode:=iGetcodeByName(xsite.BaseObjectSpace,'Divisions', ReplaceStr(cbDivisions.Text,'"','')) ;
                                        end else begin
                                            mUser := xsite.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');            // přihlášený uživatel
                                                  try
                                                      mUser.Load(xsite.CompanyCache.GetUserID, nil);
                                                            mID_DV:= mUser.GetFieldValueAsString('X_division_ID');
                                                            mcode:=mUser.GetFieldValueAsString('X_division_ID.code');

                                                  finally
                                                    mUser.Free;
                                                  end;
                                        end;
                                        //NxShowSimpleMessage( mID_DV,nil);
                                   end;
                                   finally

                                   end    ;
                                   mform.free;
                                  if not mB_pokracovat  then exit;


                  mOLE_SP:= GetAbraOLEApplication;
                  mOResult_SP:= mOLE_SP.CreateStrings;
                  mRoll_SP:= mOLE_SP.GetRoll('5315B3YAPMNOB0FIRUCLXSJ52O', 0);   // sp
                                    if not mRoll_SP.MultiSelectDialog(True, mOResult_SP) then Exit;
                                    mIDs_SP:= TStringList.Create;
                                    mIDs_WorkerRole:=TStringList.create;
                                    mIDs_Storecard:=TStringList.create;
                                    try
                                    mIDs_SP.Text:= mOResult_SP.Text;
                                        mdateinput:=true;
                                        mResult_mat:=true;
                                        mOLE_WorkerRole:= GetAbraOLEApplication;
                                              mOResult_WorkerRole:= mOLE_WorkerRole.CreateStrings;
                                                      mRoll_WorkerRole:= mOLE_WorkerRole.GetRoll('0FKKTBSSQKB4B3RLYBSJFFAFUW', 0);   // sp
                                                       if mRoll_WorkerRole.MultiSelectDialog(True, mOResult_WorkerRole) then mIDs_WorkerRole.Text:= mOResult_WorkerRole.Text;

                                        mIDs_SP.Text:= mOResult_SP.Text;



                                       // if nxisblank(mid_workSpace) then begin
                                            mr:=TStringList.Create;
                                            try
                                               mbo.ObjectSpace.SQLSelect('select id from ServiceWorkSpaces where code=' + QuotedStr(mcode),mr);
                                                        if mr.count>0 then mid_workSpace:=mr.Strings[0];
                                            finally
                                                mr.free;
                                            end;
                                        // end;

                                         //if nxisblank(mid_workerRole) then begin
                                            if  mIDs_WorkerRole.count>0 then begin
                                                mid_workerRole:=mIDs_WorkerRole.Strings[0];
                                            end else begin
                                                  mr:=TStringList.Create;
                                                  try
                                                    mbo.ObjectSpace.SQLSelect('select id from SecurityRoles where ShortName=' + QuotedStr(mcode),mr);
                                                    if mr.count>0 then begin
                                                        mid_workerRole:=mr.Strings[0] ;
                                                    end;
                                                  finally
                                                      mr.free;
                                                  end;
                                            end;
                                          //end;





                                        for mI_SP:=0 to mIDs_SP.count-1 do begin                  // cyklus SP

                                                      mID_SP:=mIDs_SP.Strings(mI_SP);
                                                      // vytvoření nového servisního listu
                                                      mServiceType_ID:='2300000101';
                                                      mID_SL:=Novy_SL(xsite,mID_SP,mD_SL_start,mD_SL_end,mID_DQ,mID_DV,mDamageDescription,mServiceType_ID);

                                                      mbo_SL:=mbo.ObjectSpace.CreateObject('BCHF52UGXCO4H5MIAQVY5P3ZOC');
                                                      try
                                                                   mbo_sl.Load(mID_SL,nil) ;  // použití již existujícího SL
                                                                     mIDs_ML:=tstringlist.create;
                                                                     try
                                                                              mbo.ObjectSpace.SQLSelect('select id from ServiceAssemblyForms where ServiceDocument_ID='+quotedstr(mID_SL),mIDs_ML);
                                                                              if mIDs_ML.count>0 then begin
                                                                                   mID_ML:=mIDs_ML.Strings[0];           // použití již existujícího ML
                                                                              end else begin

                                                                                    // založení nového ML
                                                                                    //mID_ML:=Novy_ML(mBO_SL,mid_workSpace,mid_workerRole,mD_SL_start,mD_SL_end);

                                                                                    mBO_ML:=mbo.ObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                                                                                    try
                                                                                       mBO_ML.new;
                                                                                       mBO_ML.Prefill;
                                                                                       mBO_ML.SetFieldValueAsDateTime('StartDate$DATE',mD_SL_start);
                                                                                       mBO_ML.SetFieldValueAsDateTime('EndDate$DATE',mD_SL_End);
                                                                                       mBO_ML.SetFieldValueAsDateTime('X_CreatedDate$DATE',date);
                                                                                       mBO_ML.SetFieldValueAsString('ServiceDocument_ID',mID_SL);
                                                                                       mBO_ML.SetFieldValueAsstring('X_State','35W1000101');
                                                                                       mBO_ML.SetFieldValueAsstring('X_ServicedObject_ID',mBO_SL.GetFieldValueAsString('ServicedObject_ID'));
                                                                                       mBO_ML.SetFieldValueAsstring('X_id_zakaznika_id',mBO_SL.GetFieldValueAsString('X_id_zakaznika_id'));
                                                                                       mBO_ML.SetFieldValueAsInteger('AssemblyState',0);

                                                                                       mBO_ML.SetFieldValueAsString('ServiceWorkSpace_ID',mid_workSpace);
                                                                                       mBO_ML.SetFieldValueAsString('ResponsibleRole_ID',mid_workerRole);
                                                                                      mBO_ML.SetFieldValueAsstring('X_State','3XQ1000101');

                                                                                      mBO_ML.SetFieldValueAsinteger('AssemblyState',0);

                                                                                      mBO_ML.SetFieldValueAsstring('X_Docqueue_ID',mBO_SL.GetFieldValueAsString('Docqueue_ID'));
                                                                                      mBO_ML.SetFieldValueAsInteger('X_Ordnumber',mBO_SL.GetFieldValueAsInteger('Ordnumber'));
                                                                                      mBO_ML.SetFieldValueAsstring('X_Period_ID',mBO_SL.GetFieldValueAsString('Period_ID'));
                                                                                      // zadání technika
                                                                                       if mIDs_WorkerRole.Count>0 then begin

                                                                                                    mF_prace_Od:=mD_SL_start;
                                                                                                    mF_prace_Do:=mD_SL_End;
                                                                                                    mF_doba:= 1 ;
                                                                                                    if mDateinput and false then begin         // opakující se doba
                                                                                                                mDateinput:=false;
                                                                                                                mForm := TForm.Create(xSite);
                                                                                                                mForm.Caption := 'Zadejte údaje';mForm.FormStyle := fsStayOnTop;mForm.BorderStyle := bsDialog;mForm.Width := 550;mForm.Scaled := False;mform.Position := poScreenCenter;
                                                                                                                mLbl2 := TLabel.Create(mForm);  mLbl2.Caption := 'Konec :';mLbl2.Left := 10;mLbl2.Top := 40;mLbl2.Name := 'lbldate';mForm.InsertControl(mLbl2);mEdtDAte := TDateEdit.Create(mForm);mEdtDAte.Left := 100;mEdtDAte.Top := 40;mEdtDAte.Width := 100;mEdtDAte.Name := 'edtDate';mEdtDAte.Date:=trunc(mD_SL_End);mForm.InsertControl(mEdtDAte);
                                                                                                                //mEdtDAte1 := TTimeEdit.Create(mForm);mEdtDAte1.Left := 210;mEdtDAte1.Top := 40;mEdtDAte1.Width := 100;mEdtDAte1.Name := 'edtDate1';mEdtDAte1.Time:=frac(mD_SL_End);mForm.InsertControl(mEdtDAte1);
                                                                                                                mLbl3 := TLabel.Create(mForm); mLbl3.Caption := 'Doba :';mLbl3.Left := 10;mLbl3.Top := 70;mLbl3.Name := 'lblDoba';mForm.InsertControl(mLbl3);mEdtSrc := TEdit.Create(mForm);mEdtSrc.Left := 100;mEdtSrc.Top := 70;mEdtSrc.Width := 100;mEdtSrc.Name := 'edtdoba';mEdtSrc.Text:=NxFloatToIBStr(mf_doba);mForm.InsertControl(mEdtSrc);
                                                                                                                mBtn := TButton.Create(mForm);mBtn.Width := 75; mBtn.Height := 25;mBtn.Caption := 'OK';mBtn.ModalResult := mrOk;mBtn.Cancel := False;mBtn.Default := True;mBtn.Left :=  mForm.Width - 2*(mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 40;mBtn.Name := 'btnOK';mForm.InsertControl(mBtn);
                                                                                                                mBtn := TButton.Create(mForm);mBtn.Width := 75;mBtn.Height := 25;mBtn.Caption := 'Storno';mBtn.ModalResult := mrCancel;mBtn.Cancel := True;mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 40;mBtn.Name := 'btnCancel';mForm.InsertControl(mBtn);
                                                                                                                if mForm.ShowModal(xSite) = mrOK then begin
                                                                                                                                mB_pokracovat:=true;
                                                                                                                                mF_doba:=NxIBStrToFloat(mEdtSrc.Text);
                                                                                                                                mD_ML_End:=mEdtDAte.Date+ encodetime(15,30,0,0);
                                                                                                                                /// *************************************************





                                                                                                                                mD_ML_start:=mD_ML_End - EncodeTime(trunc(mF_doba),trunc(frac(trunc(mF_doba)*60)),0,0);
                                                                                                                                mBO_ML.SetFieldValueAsDateTime('StartDate$DATE',mD_ML_start);
                                                                                                                                mBO_ML.SetFieldValueAsDateTime('EndDate$DATE',mD_ML_End);
                                                                                                                                if  not NxIsEmptyOID(mBO_ML.GetFieldValueAsString('ServiceDocument_ID.BusProject_ID')) then begin
                                                                                                                                        mF_pausal_prace:=0;mF_pausal_Vyjezd:=0;mFSazba_mimo:=0;mFSazba_vikend:=0;mFSazba_svatek:=0;mFDoprava_km:=0;mF_Prac_doba_zac:=0;mF_Prac_doba_kon:=0;
                                                                                                                                        // ceny z projektu
                                                                                                                                        try
                                                                                                                                                mBO_BusProject:=xsite.BaseObjectSpace.CreateObject('QOKMKIQUJF34L3DUICTBWEDQJC');
                                                                                                                                                if mBO_ML.GetFieldValueAsInteger('ServiceDocument_ID.ServicedObject_ID.X_Fakturacni_oblast')=0 then begin
                                                                                                                                                    NxShowSimpleMessage('Pozor, předmět není přiřazen do fakturační oblasti, ceny nemusí odpovídat, bude použit formát pro Čechy',nil);
                                                                                                                                                    mBO_BusProject.load('2130000101',nil);                                                                                    // max cena=čechy
                                                                                                                                                end;
                                                                                                                                                if mBO_ML.GetFieldValueAsInteger('ServiceDocument_ID.ServicedObject_ID.X_Fakturacni_oblast')=1 then begin     // čechy
                                                                                                                                                      mBO_BusProject.load('2130000101',nil);
                                                                                                                                                end;
                                                                                                                                                if mBO_ML.GetFieldValueAsInteger('ServiceDocument_ID.ServicedObject_ID.X_Fakturacni_oblast')=2 then begin      // morava
                                                                                                                                                      mBO_BusProject.load('3130000101',nil);
                                                                                                                                                end;
                                                                                                                                                mFSazba_prace:=mBO_BusProject.GetFieldValueAsFloat('X_Sazba_bezna');
                                                                                                                                                mF_pausal_prace:=mBO_BusProject.GetFieldValueAsFloat('X_Prevence_pausal');
                                                                                                                                                mF_pausal_Vyjezd:=mBO_BusProject.GetFieldValueAsFloat('X_Najezdni_pausal');
                                                                                                                                                if mF_pausal_Vyjezd=0 then  mFDoprava_km:=mBO_BusProject.GetFieldValueAsFloat('X_Sazba_bezna');
                                                                                                                                        finally
                                                                                                                                        mBO_BusProject.free;
                                                                                                                                        end;

                                                                                                                                end;
                                                                                                               end else begin
                                                                                                               mB_pokracovat:=false;
                                                                                                               end;
                                                                                                     end;   //opakující se doba;
                                                                                                     msleva:= mBO_ML.GetFieldValueAsInteger('ServiceDocument_ID.X_Discount_sluzby');
                                                                                                     {  try
                                                                                                          mrgt:=tstringlist.create;
                                                                                                          xsite.BaseObjectSpace.SQLSelect(format('select count(id) from ServiceAssemblyForms2 where parent_ID=%s and (itemtype=4 and text=%s) or (itemtype=0 and Storecard_ID=%s) ',[quotedstr(mbo_ml.OID),quotedstr('Práce - evidenční pro mzdy'),quotedstr('92E0000101')]),mrgt);
                                                                                                          if strtoint(mrgt.Strings[0])>0 then begin
                                                                                                             mkoeficient:=trunc(100/(strtoint(mrgt.Strings[0])+1));
                                                                                                             mkoeficient_korekce:=100-((strtoint(mrgt.Strings[0])+1)*mkoeficient);
                                                                                                          end else begin
                                                                                                             mkoeficient:=100;
                                                                                                             mkoeficient_korekce:=0;
                                                                                                          end;
                                                                                                       finally
                                                                                                          mr.free;
                                                                                                       end; }
                                                                                                       mRows_ML := mBO_ML.GetCollectionMonikerForFieldCode(mBO_ML.GetFieldCode('Rows'));
                                                                                                       if (mIDs_workerRole.count>0) and (mB_pokracovat) then begin
                                                                                                            for mI_WorkerRole:=0 to mIDs_workerRole.count-1 do begin
                                                                                                                  mID_WorkerRole:=mIDs_WorkerRole.Strings[mI_WorkerRole];
                                                                                                                { mr:=tstringlist.create;
                                                                                                                          try
                                                                                                                              xsite.BaseObjectSpace.SQLSelect('select min(SheduledStart$Date) from CRMActivities where SolverRole_ID='+ quotedstr(mID_WorkerRole) + ' and SheduledStart$Date>' + inttostr(trunc(mD_ML_End)) + ' and SheduledStart$Date<=' + inttostr((trunc(mD_ML_End)+1)) , mr);
                                                                                                                              if mr.count>0 then begin
                                                                                                                                   if frac(NxIBStrToFloat(mr.Strings[0]))<EncodeTime(5,0,0,0) then begin

                                                                                                                                   end else begin
                                                                                                                                      mD_ML_End:=trunc(mD_ML_End) + frac(NxIBStrToFloat(mr.Strings[0]));
                                                                                                                                   end;
                                                                                                                              end;
                                                                                                                          finally
                                                                                                                             mr.free;
                                                                                                                          end;
                                                                                                                   }
                                                                                                                        mD_ML_End:=trunc(mD_ML_End) +encodetime(15,30,0,0);
                                                                                                                       mBO_ML_ROW := mRows_ml.AddNewObject;
                                                                                                                                      mBO_ML_ROW.SetFieldValueAsinteger('itemtype',0);          // 0 práce , 1 skladová karta
                                                                                                                                      //mOrderRow.SetFieldValueAsString('serviceworkcategory_id','');
                                                                                                                                      mBO_ML_ROW.SetFieldValueAsString('WorkerRole_ID',mID_WorkerRole);
                                                                                                                                      mBO_ML_ROW.SetFieldValueAsString('X_WorkerRole_ID',mID_WorkerRole);
                                                                                                                                      mBO_ML_ROW.SetFieldValueAsString('X_Osoba',mBO_ML_ROW.GetFieldValueAsstring('WorkerRole_ID.Name'));
                                                                                                                                      mBO_ML_ROW.SetFieldValueAsString('Text','Práce');
                                                                                                                                      mBO_ML_ROW.SetFieldValueAsString('Store_id','2000000101');
                                                                                                                                      mBO_ML_ROW.SetFieldValueAsString('StoreCard_id','2ZI1000101');
                                                                                                                                      mBO_ML_ROW.SetFieldValueAsfloat('WorkHoursPlanned',mF_doba);
                                                                                                                                      mBO_ML_ROW.SetFieldValueAsfloat('X_konec_prace',mD_ML_End);
                                                                                                                                      mBO_ML_ROW.SetFieldValueAsfloat('X_Radkova_sleva',msleva);
                                                                                                                                      mdateto:=mD_ML_End;
                                                                                                                                             mD_ML_start:=mD_ML_End - EncodeTime(trunc(mF_doba),trunc(frac(trunc(mF_doba)*60)),0,0);

                                                                                                                                             mCRMresult:=NxCRM(0,mBO_ML_ROW,mID_WorkerRole,mD_ML_start,mD_ML_End,'','');
                                                                                                                                             if not mCRMresult then NxShowSimpleMessage('Při vytváření aktivity došlo k chybě',nil);
                                                                                                                                      mBO_ML_ROW.SetFieldValueAsfloat('X_Koeficient',100/mIDs_workerRole.count);
                                                                                                                                      mkoeficient_korekce:=0;
                                                                                                                                      if mFSazba_hod<>0 then mBO_ML_ROW.SetFieldValueAsfloat('UnitPriceWithoutVAT',mFSazba_hod);
                                                                                                                                      mBO_ML_ROW.SetFieldValueAsinteger('ToInvoiceType',0);
                                                                                                                  if mI_WorkerRole=0 then mkoeficient_korekce:=0
                                                                                                            end;
                                                                                                       mBO_ML.SetFieldValueAsstring('X_State','4U12000101');
                                                                                                       mBO_ML.SetFieldValueAsinteger('AssemblyState',1);
                                                                                                       mBO_ML.SetFieldValueAsstring('X_Monter1_ID',mID_WorkerRole);
                                                                                                mi:=mbo.ObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' +QuotedStr(mBO_ML.getFieldValueAsString('X_state.X_field1'))+ ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                                                                                       end;


                                                                                                          // rozpočet fakturace
                                                                                                       if (trunc(mBO_ml.GetFieldValueAsDateTime('EndDate$DATE'))<date) and (mB_pokracovat) and false  then begin
                                                                                                              if mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='1A20000101' then mBO_ML.SetFieldValueAsString('X_protokol_prefix','S');
                                                                                                              if mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='5B20000101' then mBO_ML.SetFieldValueAsString('X_protokol_prefix','S');
                                                                                                              if mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='4B20000101' then mBO_ML.SetFieldValueAsString('X_protokol_prefix','P');
                                                                                                              if mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='6B20000101' then mBO_ML.SetFieldValueAsString('X_protokol_prefix','P');
                                                                                                              if mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='7B20000101' then mBO_ML.SetFieldValueAsString('X_protokol_prefix','B');
                                                                                                              if mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='8B20000101' then mBO_ML.SetFieldValueAsString('X_protokol_prefix','B');
                                                                                                              if mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='9B20000101' then mBO_ML.SetFieldValueAsString('X_protokol_prefix','F');
                                                                                                              if mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='AB20000101' then mBO_ML.SetFieldValueAsString('X_protokol_prefix','F');
                                                                                                               if true then begin  // není fakturován
                                                                                                                        mF_pausal_prace:=0;mF_pausal_Vyjezd:=0;mFSazba_prace:=0;mFSazba_mimo:=0;mFSazba_vikend:=0;mFSazba_svatek:=0;mFDoprava_km:=0;mFPriplatek3H:=0;mPRzac:=0;mPRkon:=0;


                                                                                                                            // ceny z projektu

                                                                                                                               if not NxIsEmptyOID(mBO_ML.GetFieldValueAsString('ServiceDocument_ID.BusProject_ID')) then begin
                                                                                                                                      mBO_BusProject:=mBO_ML.ObjectSpace.CreateObject('QOKMKIQUJF34L3DUICTBWEDQJC');
                                                                                                                                     try
                                                                                                                                       mBO_BusProject.load(mBO_ML.GetFieldValueAsString('ServiceDocument_ID.BusProject_ID'),nil);
                                                                                                                                        if (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_id')='4B20000101') Or
                                                                                                                                         (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_id')='6B20000101') Or
                                                                                                                                         (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_id')='7B20000101') or
                                                                                                                                         (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_id')='8B20000101') or
                                                                                                                                         (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_id')='9B20000101') or
                                                                                                                                         (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_id')='AB20000101')
                                                                                                                                        then begin
                                                                                                                                                if(mBO_ML.GetFieldValueAsFloat('ServiceDocument_ID.BusProject_ID.X_Prevence_pausal')<>0) then mF_pausal_prace:=mBO_ML.GetFieldValueAsFloat('ServiceDocument_ID.BusProject_ID.X_Prevence_pausal');
                                                                                                                                        end;
                                                                                                                                        if(mBO_BusProject.GetFieldValueAsFloat('X_Najezdni_pausal')>0) then mF_pausal_Vyjezd:=mBO_BusProject.GetFieldValueAsFloat('X_Najezdni_pausal');
                                                                                                                                        if(mBO_BusProject.GetFieldValueAsFloat('X_Sazba_bezna')>0) then mFSazba_prace:=mBO_BusProject.GetFieldValueAsFloat('X_Sazba_bezna');
                                                                                                                                        if(mBO_BusProject.GetFieldValueAsFloat('X_Sazba_mimo_pd')>0) then mFSazba_mimo:=mBO_BusProject.GetFieldValueAsFloat('X_Sazba_mimo_pd');
                                                                                                                                        if(mBO_BusProject.GetFieldValueAsFloat('X_sazba_vikend')>0) then mFSazba_vikend:=mBO_BusProject.GetFieldValueAsFloat('X_sazba_vikend');
                                                                                                                                        if(mBO_BusProject.GetFieldValueAsFloat('X_sazba_vikend')>0) then mFSazba_svatek:=mBO_BusProject.GetFieldValueAsFloat('X_sazba_vikend');

                                                                                                                                        if mF_pausal_Vyjezd=0 then  begin
                                                                                                                                              if(mBO_BusProject.GetFieldValueAsFloat('X_Sazba_km')>0) then mFSazba_Doprava_km:=mBO_BusProject.GetFieldValueAsFloat('X_Sazba_km');
                                                                                                                                        end;
                                                                                                                                        if(mBO_BusProject.GetFieldValueAsFloat('X_Pr_OD')>0) then mPRzac:=mBO_BusProject.GetFieldValueAsFloat('X_PR_od');
                                                                                                                                        if(mBO_BusProject.GetFieldValueAsFloat('X_Pr_DO')>0) then mPRkon:=mBO_BusProject.GetFieldValueAsFloat('X_PR_do');
                                                                                                                                        if(mBO_BusProject.GetFieldValueAsFloat('X_Priplatek3hod')>0) then mFPriplatek3H:=mBO_BusProject.GetFieldValueAsFloat('X_Priplatek3hod');
                                                                                                                                  finally
                                                                                                                                    mBO_BusProject.free;
                                                                                                                                  end;

                                                                                                                             end else begin
                                                                                                                                    try
                                                                                                                                      // ceny z fakturační oblasti
                                                                                                                                      mBO_BusProject:=mBO_ML.ObjectSpace.CreateObject('QOKMKIQUJF34L3DUICTBWEDQJC');
                                                                                                                                      if mBO_ML.GetFieldValueAsInteger('ServiceDocument_ID.ServicedObject_ID.X_Fakturacni_oblast')=0 then begin
                                                                                                                                          NxShowSimpleMessage('Pozor, předmět není přiřazen do fakturační oblasti, ceny nemusí odpovídat, bude použit formát pro Čechy',nil);
                                                                                                                                          mBO_BusProject.load('2130000101',nil);                                                                                    // max cena=čechy
                                                                                                                                      end;
                                                                                                                                      if mBO_ML.GetFieldValueAsInteger('ServiceDocument_ID.ServicedObject_ID.X_Fakturacni_oblast')=1 then begin     // čechy
                                                                                                                                          mBO_BusProject.load('2130000101',nil);
                                                                                                                                      end;
                                                                                                                                      if mBO_ML.GetFieldValueAsInteger('ServiceDocument_ID.ServicedObject_ID.X_Fakturacni_oblast')=2 then begin      // morava
                                                                                                                                          mBO_BusProject.load('3130000101',nil);
                                                                                                                                      end;


                                                                                                                                      if mF_pausal_Vyjezd=0 then if(mBO_BusProject.GetFieldValueAsFloat('X_Najezdni_pausal')>0) then
                                                                                                                                            mF_pausal_Vyjezd:=mBO_BusProject.GetFieldValueAsFloat('X_Najezdni_pausal');
                                                                                                                                      if mFSazba_prace=0 then if(mBO_BusProject.GetFieldValueAsFloat('X_Sazba_bezna')>0) then
                                                                                                                                            mFSazba_prace:=mBO_BusProject.GetFieldValueAsFloat('X_Sazba_bezna');
                                                                                                                                      if mFSazba_mimo=0 then if(mBO_BusProject.GetFieldValueAsFloat('X_Sazba_mimo_pd')>0) then
                                                                                                                                          mFSazba_mimo:=mBO_BusProject.GetFieldValueAsFloat('X_Sazba_mimo_pd');
                                                                                                                                      if mFSazba_vikend=0 then if(mBO_BusProject.GetFieldValueAsFloat('X_sazba_vikend')>0) then
                                                                                                                                            mFSazba_vikend:=mBO_BusProject.GetFieldValueAsFloat('X_sazba_vikend');
                                                                                                                                      if mFSazba_svatek=0 then if(mBO_BusProject.GetFieldValueAsFloat('X_sazba_vikend')>0) then
                                                                                                                                            mFSazba_svatek:=mBO_BusProject.GetFieldValueAsFloat('X_sazba_vikend');

                                                                                                                                        if mF_pausal_Vyjezd=0 then  begin
                                                                                                                                              if mFSazba_Doprava_km=0 then if(mBO_BusProject.GetFieldValueAsFloat('X_Sazba_km')>0) then
                                                                                                                                               mFSazba_Doprava_km:=mBO_BusProject.GetFieldValueAsFloat('X_Sazba_km');
                                                                                                                                        end;



                                                                                                                                      if mPRzac=0 then if(mBO_BusProject.GetFieldValueAsFloat('X_Pr_OD')>0) then mPRzac:=mBO_BusProject.GetFieldValueAsFloat('X_PR_od');
                                                                                                                                      if mPRkon=0 then if(mBO_BusProject.GetFieldValueAsFloat('X_Pr_DO')>0) then mPRkon:=mBO_BusProject.GetFieldValueAsFloat('X_PR_do');
                                                                                                                                      if mFPriplatek3H=0 then mFPriplatek3H:=mBO_BusProject.GetFieldValueAsFloat('X_Priplatek3hod');

                                                                                                                                   finally
                                                                                                                                        mBO_BusProject.free;
                                                                                                                                   end;
                                                                                                                            end;

                                                                                                                            if (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='AB20000101') or (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='4B20000101') or (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='8B20000101') or (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='9B20000101')  or (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='6B20000101') or (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_id')='7B20000101') then begin
                                                                                                                                   //mrta:=tstringlist.create;
                                                                                                                                   //try
                                                                                                                                   //           mBO_ML.ObjectSpace.SQLSelect('select id from ServiceAssemblyForms2 where ItemType=0 and ((storecard_ID='+ QuotedStr('2ZI1000101')+
                                                                                                                                   //           ') or (storecard_ID='+ QuotedStr('11J1000101')+')) and (parent_id=' + quotedstr(mBO_ML.oid)+ ')',mrta);
                                                                                                                                   //        if mrta.count>0 then mpocet1:=mrta.count;
                                                                                                                                   //finally
                                                                                                                                   //     mrta.free;
                                                                                                                                   //end;

                                                                                                                                   if (mIDs_WorkerRole.count>0) and mB_pokracovat then begin
                                                                                                                                        mForm1 := TForm.Create(xSite);mForm1.Caption := 'Rozpočtení paušálu';mForm1.FormStyle := fsStayOnTop;mForm1.BorderStyle := bsDialog;
                                                                                                                                                mForm1.Width := 1350;mForm1.Height := 100;mForm1.Scaled := False;mform1.Position := poScreenCenter;
                                                                                                                                                mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := 'Počet tech.:';mL_Technik.Top := 12;mL_Technik.Left := 10;mL_Technik.Height := 13;
                                                                                                                                                mL_technik_value:= TLabel.Create(mForm1);mL_technik_value.Parent := mForm1;mL_technik_value.Caption := inttostr(mIDs_WorkerRole.count);mL_technik_value.Top := 12;mL_technik_value.Left := 80;mL_technik_value.Height := 13;mL_technik_value.Width := 50;
                                                                                                                                                mL_technik_value:= TLabel.Create(mForm1);mL_technik_value.Parent := mForm1;mL_technik_value.Caption := ('Konec práce');mL_technik_value.Top := 10;mL_technik_value.Left := 150;mL_technik_value.Height := 13;mL_technik_value.Width := 50;
                                                                                                                                                mKonecDAte := TDateTimeEdit.Create(mForm1);mKonecDAte.Left := 250;mKonecDAte.Top := 10;mKonecDAte.Width := 80;mKonecDAte.Name := 'mKonecDAte';mKonecDAte.DateTime:= mBO_ML.GetFieldValueAsDateTime('EndDate$DATE');mKonecDAte.Enabled:=true;mForm1.InsertControl(mKonecDAte);
                                                                                                                                                mKonecTime := TTimeEdit.Create(mForm1);mKonecTime.Left := 330;mKonecTime.Top := 10;mKonecTime.Width := 80;mKonecTime.Name := 'mKonecTime';mKonecTime.Time:= mBO_ML.GetFieldValueAsDateTime('EndDate$DATE');mKonecTime.Enabled:= True;
                                                                                                                                                mForm1.InsertControl(mKonecTime);
                                                                                                                                                mL_operation:= TLabel.Create(mForm1);mL_operation.Parent := mForm1;mL_operation.Caption := 'Cena :';mL_operation.Top := 10;mL_operation.Left := 450;mL_operation.Height := 150;mL_operation.Width := 80;
                                                                                                                                                mEd_quantity := TEdit.Create(mForm1);mEd_quantity.Left := 500;mEd_quantity.Top := 10;mEd_quantity.Width := 100;mEd_quantity.Name := 'mEd_quantity';mEd_quantity.Text:=NxFloatToIBStr(mF_pausal_prace);mForm1.InsertControl(mEd_quantity);
                                                                                                                                                mL1_operation:= TLabel.Create(mForm1); mL1_operation.Parent := mForm1;mL1_operation.Caption := 'Doprava :';mL1_operation.Top := 10; mL1_operation.Left := 550;mL1_operation.Height := 13;mL1_operation.Width := 150;
                                                                                                                                                mEd1_quantity := TEdit.Create(mForm1);mEd1_quantity.Left := 660;mEd1_quantity.Top := 10;mEd1_quantity.Width := 100;mEd1_quantity.Name := 'mEd1_quantity';mEd1_quantity.Text:='0';mForm1.InsertControl(mEd1_quantity);
                                                                                                                                                mL1_C_protokol:= TLabel.Create(mForm1);
                                                                                                                                                mL1_C_protokol.Parent := mForm1; mL1_C_protokol.Caption := 'Protokol :' + mBO_ML.getFieldValueAsString('X_protokol_prefix');mL1_C_protokol.Top := 14;mL1_C_protokol.Left := 800;mL1_C_protokol.Height := 13;mL1_C_protokol.Width := 60;
                                                                                                                                                mEd1_C_protokol := TEdit.Create(mForm1);mEd1_C_protokol.Left := 880;mEd1_C_protokol.Top := 10;mEd1_C_protokol.Width := 100;mEd1_C_protokol.Name := 'mEd1_C_protokol';mEd1_C_protokol.Text:=mBO_ML.GetFieldValueAsString('X_Protokol');mForm1.InsertControl(mEd1_C_protokol);
                                                                                                                                                mL1_C_chyby:= TLabel.Create(mForm1);mL1_C_chyby.Parent := mForm1;mL1_C_chyby.Caption := 'Závada :';mL1_C_chyby.Top := 14;mL1_C_chyby.Left := 1000;mL1_C_chyby.Height := 13;mL1_C_chyby.Width := 50;
                                                                                                                                                mEd1_C_chyby := TEdit.Create(mForm1);mEd1_C_chyby.Left := 1070;mEd1_C_chyby.Top := 10; mEd1_C_chyby.Width := 100;mEd1_C_chyby.Name := 'mEd1_C_chyby';mEd1_C_chyby.Text:=mBO_ML.GetFieldValueAsString('X_zavada_code');mForm1.InsertControl(mEd1_C_chyby);
                                                                                                                                                mL1_P_Cyklu:= TLabel.Create(mForm1);mL1_P_Cyklu.Parent := mForm1;mL1_P_Cyklu.Caption := 'Cyklů :';mL1_P_Cyklu.Top := 14;mL1_P_Cyklu.Left := 1190;mL1_P_Cyklu.Height := 13;mL1_P_Cyklu.Width := 50;
                                                                                                                                                mEd1_P_Cyklu := TEdit.Create(mForm1);mEd1_P_Cyklu.Left := 1250; mEd1_P_Cyklu.Top := 10;mEd1_P_Cyklu.Width := 80;mEd1_P_Cyklu.Name := 'mEd1_P_Cyklu';mEd1_P_Cyklu.Text:=inttostr(mBO_ML.GetFieldValueAsInteger('X_Pocet_cyklu'));mForm1.InsertControl(mEd1_P_Cyklu);
                                                                                                                                                mBtn := TButton.Create(mForm1);mBtn.Width := 75;mBtn.Height := 25;mBtn.Caption := 'OK';mBtn.ModalResult := mrOk;mBtn.Cancel := False;mBtn.Default := True;mBtn.Left :=  mForm1.Width - 2*(mBtn.Width+2) - 20;mBtn.Top := mForm1.Height - mBtn.Height - 40;mBtn.Name := 'btnOK';mForm1.InsertControl(mBtn);
                                                                                                                                                mBtn := TButton.Create(mForm1);mBtn.Width := 75;mBtn.Height := 25;mBtn.Caption := 'Storno';mBtn.ModalResult := mrCancel;mBtn.Cancel := True;mBtn.Left := mForm1.Width - (mBtn.Width+2) - 20;mBtn.Top := mForm1.Height - mBtn.Height - 40;mBtn.Name := 'btnCancel';mForm1.InsertControl(mBtn);

                                                                                                                                                   if mForm1.ShowModal(xSite) = mrOK then begin
                                                                                                                                                             mB_pokracovat:=true;
                                                                                                                                                             mpausal:=trunc(100/mIDs_WorkerRole.count)*0.01;
                                                                                                                                                             mpausal_oprava:=1-(mIDs_WorkerRole.count*mpausal);
                                                                                                                                                             mBO_ML.SetFieldValueAsString('X_zavada_code',mEd1_C_chyby.Text);
                                                                                                                                                                 mBO_ML.SetFieldValueAsString('X_Protokol',mEd1_C_protokol.Text);
                                                                                                                                                                 mBO_ML.SetFieldValueAsInteger('X_Pocet_cyklu',StrToInt(mEd1_P_Cyklu.Text));
                                                                                                                                                       mList_pomoc:= TStringList.Create;
                                                                                                                                                       try
                                                                                                                                                               for mI_MLRow := 0 to mRows_ML.Count - 1 do begin
                                                                                                                                                                    if (mRows_ML.BusinessObject[mI_MLRow].GetFieldValueAsinteger('itemtype')=0) and (mRows_ML.BusinessObject[mI_MLRow].GetFieldValueAsinteger('ToInvoiceType') =0 )then begin
                                                                                                                                                                          mWorkerRole_ID:=mRows_ML.BusinessObject[mI_MLRow].GetFieldValueAsString('X_WorkerRole_ID');

                                                                                                                                                                        if (mRows_ML.BusinessObject[mI_MLRow].GetFieldValueAsString('Storecard_ID')='11J1000101') or
                                                                                                                                                                              (mRows_ML.BusinessObject[mI_MLRow].GetFieldValueAsString('Storecard_ID')='2ZI1000101') then begin

                                                                                                                                                                              mList_pomoc.AddObject(mRows_ML.BusinessObject[mI_MLRow].OID, mRows_ML.BusinessObject[mI_MLRow]);
                                                                                                                                                                              mWorkHoursReal:=mpausal+mpausal_oprava ;
                                                                                                                                                                              mpocet_km:=NxIBStrToFloat(mEd1_quantity.text) ;
                                                                                                                                                                              mDateto:=trunc(mKonecDAte.DateTime) + frac((mKonecTime.Time));
                                                                                                                                                                              mstore:=mRows_ML.BusinessObject[mI_MLRow].GetFieldValueAsString('Store_id');
                                                                                                                                                                              mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('WorkHoursReal',mWorkHoursReal);
                                                                                                                                                                              mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('WorkHoursPlanned',mWorkHoursReal);
                                                                                                                                                                              mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('Quantity',mWorkHoursReal);
                                                                                                                                                                              mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('QuantityDelivered',mWorkHoursReal);
                                                                                                                                                                              mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsDateTime('X_konec_prace',mDateto);
                                                                                                                                                                              mPosIndex := mRows_ML.BusinessObject[mI_MLRow].GetFieldValueAsInteger('PosIndex');
                                                                                                                                                                              mquantity:=mWorkHoursReal;
                                                                                                                                                                              //mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('WorkHoursReal',1);
                                                                                                                                                                              mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsinteger('itemtype',4);
                                                                                                                                                                              mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsinteger('ToInvoiceType',1);
                                                                                                                                                                              mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsString('Text','Práce - evidenční pro mzdy');
                                                                                                                                                                              mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('WorkHoursPlanned',mWorkHoursReal);
                                                                                                                                                                              mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('Quantity',mWorkHoursReal);
                                                                                                                                                                              mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('QuantityDelivered',mWorkHoursReal);
                                                                                                                                                                              mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsString('Qunit','ks');
                                                                                                                                                                              //mRows_ML.BusinessObject[i].SetFieldValueAsinteger('IsInvoiced',1);
                                                                                                                                                                              mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsBoolean('X_storno',true);
                                                                                                                                                                              mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('UnitPriceWithVAT',0);
                                                                                                                                                                              mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('UnitPriceWithoutVAT',0);
                                                                                                                                                                              mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsString('WorkerRole_ID',mWorkerRole_ID);
                                                                                                                                                                        end;

                                                                                                                                                                    end;
                                                                                                                                                               end;
                                                                                                                                                               for i01 := 0 to mList_pomoc.Count-1 do begin
                                                                                                                                                                    mRow_Pomoc := TNxCustomBusinessObject(mList_pomoc.Objects[i01]);
                                                                                                                                                                    mWorkerRole_ID:=mRow_Pomoc.GetFieldValueAsString('WorkerRole_ID');

                                                                                                                                                                                      mNewRow := mRows_ML.AddNewObject;
                                                                                                                                                                                      mNewRow.SetFieldValueAsInteger('itemtype',0);          // 0 práce , 1 skladová karta
                                                                                                                                                                                      //mNewRow.SetFieldValueAsString('serviceworkcategory_id','');
                                                                                                                                                                                      mNewRow.SetFieldValueAsString('WorkerRole_ID',mWorkerRole_ID);
                                                                                                                                                                                      mNewRow.SetFieldValueAsString('X_WorkerRole_ID',mWorkerRole_ID);
                                                                                                                                                                                      mNewRow.SetFieldValueAsString('X_Osoba',mNewRow.GetFieldValueAsString('X_WorkerRole_ID.Name'));
                                                                                                                                                                                      mNewRow.SetFieldValueAsString('Text','Paušál práce');
                                                                                                                                                                                      mNewRow.SetFieldValueAsString('Store_id',mStore);
                                                                                                                                                                                      mNewRow.SetFieldValueAsString('StoreCard_id','1ZI1000101');
                                                                                                                                                                                      mNewRow.SetFieldValueAsfloat('WorkHoursPlanned',mpausal+mpausal_oprava);
                                                                                                                                                                                      mNewRow.SetFieldValueAsfloat('WorkHoursReal',mpausal+mpausal_oprava);
                                                                                                                                                                                      mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',NxIBStrToFloat(mEd_quantity.Text));
                                                                                                                                                                                      mNewRow.SetFieldValueAsfloat('X_radkova_sleva',0);
                                                                                                                                                                                      mNewRow.SetFieldValueAsDateTime('X_konec_prace',mDateto);
                                                                                                                                                                                      mpausal_oprava:=0;


                                                                                                                                                               End;
                                                                                                                                                         finally
                                                                                                                                                             mList_pomoc.free;
                                                                                                                                                         end;
                                                                                                                                                   end else begin
                                                                                                                                                   mB_pokracovat:=false;
                                                                                                                                                   end;
                                                                                                                                          end;
                                                                                                                                   //end;  //počet















                                                                                                                                 //paušál

                                                                                                                            end else begin

                                                                                                                                        mList_pomoc:= TStringList.Create;
                                                                                                                                        try
                                                                                                                                            for mI_MLRow:=0 to mRows_ML.count-1 do begin

                                                                                                                                                 if ((mRows_ML.BusinessObject[mI_MLRow].GetFieldValueAsinteger('itemtype')=0) and (mRows_ML.BusinessObject[mI_MLRow].GetFieldValueAsinteger('ToInvoiceType') =0 ) and ((mRows_ML.BusinessObject[mI_MLRow].GetFieldValueAsString('Storecard_ID')='11J1000101') or
                                                                                                                                                        (mRows_ML.BusinessObject[mI_MLRow].GetFieldValueAsString('Storecard_ID')='2ZI1000101'))) and mB_pokracovat then begin
                                                                                                                                                         mList_pomoc.AddObject(mRows_ML.BusinessObject[mI_MLRow].OID, mRows_ML.BusinessObject[mI_MLRow]);
                                                                                                                                                               mquantity:=mRows_ML.BusinessObject[mI_MLRow].getFieldValueAsFloat('WorkHoursReal');
                                                                                                                                                               mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsString('X_workerRole_id',mRows_ML.BusinessObject[mI_MLRow].getFieldValueAsString('WorkerRole_id'));
                                                                                                                                                               mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('WorkHoursPlanned',mquantity);
                                                                                                                                                               mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('Quantity',mquantity);
                                                                                                                                                               mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('QuantityDelivered',mquantity);
                                                                                                                                                               mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsinteger('itemtype',4);
                                                                                                                                                               mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsinteger('ToInvoiceType',1);
                                                                                                                                                               mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsString('Text','Práce - evidenční pro mzdy');
                                                                                                                                                               mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('WorkHoursPlanned',mquantity);
                                                                                                                                                               mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('Quantity',mquantity);
                                                                                                                                                               mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('QuantityDelivered',mquantity);
                                                                                                                                                               mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsString('Qunit','hod');

                                                                                                                                                               mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsBoolean('X_storno',true);
                                                                                                                                                               mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('UnitPriceWithVAT',0);
                                                                                                                                                               mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('UnitPriceWithoutVAT',0);
                                                                                                                                                               mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsDateTime('X_konec_prace',mDateto);

                                                                                                                                               end;

                                                                                                                                            end;
                                                                                                                                            for i01 := 0 to mList_pomoc.Count-1 do begin
                                                                                                                                                mRow_Pomoc := TNxCustomBusinessObject(mList_pomoc.Objects[i01]);
                                                                                                                                                mWorkerRole_ID:=mRow_Pomoc.GetFieldValueAsString('WorkerRole_ID');
                                                                                                                                                mBO_SecurityRole:=xSite.BaseObjectSpace.CreateObject('QRDGQ1DV2CU4D3TOUMORZ0LWIW');

                                                                                                                                                if mPRzac=0 then mPRzac:=EncodeTime(7,0,0,0);
                                                                                                                                                if mPRkon=0 then mPRkon:=EncodeTime(15,30,0,0);



                                                                                                                                                                      mForm1 := TForm.Create(xSite);
                                                                                                                                                                      try

                                                                                                                                                                          mForm1.Caption := 'Evidence pro mzdy';mForm1.FormStyle := fsStayOnTop;mForm1.BorderStyle := bsDialog;mForm1.Width := 1350;mForm1.Height := 100;mForm1.Scaled := False;mform1.Position := poScreenCenter;
                                                                                                                                                                              mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := 'Technik :';mL_Technik.Top := 14;mL_Technik.Left := 10;mL_Technik.Height := 13;
                                                                                                                                                                              mL_technik_value:= TLabel.Create(mForm1);mL_technik_value.Parent := mForm1;mL_technik_value.Caption := mRow_Pomoc.GetFieldValueAsString('X_WorkerRole_ID.Name');mL_technik_value.Top := 14;mL_technik_value.Left := 80;mL_technik_value.Height := 13;mL_technik_value.Width := 120;
                                                                                                                                                                              mL_technik1_value:= TLabel.Create(mForm1);mL_technik1_value.Parent := mForm1;mL_technik1_value.Caption := ('Konec práce');mL_technik1_value.Top := 14;mL_technik1_value.Left := 200;mL_technik1_value.Height := 13;mL_technik1_value.Width := 200;
                                                                                                                                                                              mKonecDAte := TDatetimeEdit.Create(mForm1);mKonecDAte.Left := 300;mKonecDAte.Top := 10;mKonecDAte.Width := 80;mKonecDAte.Name := 'mKonecDAte';mKonecDAte.DateTime:= trunc(mdateto); mKonecDAte.Enabled:=true;mForm1.InsertControl(mKonecDAte);
                                                                                                                                                                              mKonecTime := TTimeEdit.Create(mForm1);mKonecTime.Left := 380;mKonecTime.Top := 10;mKonecTime.Width := 80;mKonecTime.Name := 'mKonecTime';mKonecTime.Time:= frac(mDateto); mKonecTime.Enabled:= True;mForm1.InsertControl(mKonecTime);
                                                                                                                                                                              mL_operation:= TLabel.Create(mForm1);mL_operation.Parent := mForm1;mL_operation.Caption := 'Doba práce :';mL_operation.Top := 14;mL_operation.Left := 480;mL_operation.Height := 13;mL_operation.Width := 120;
                                                                                                                                                                              mEd_quantity := TEdit.Create(mForm1);mEd_quantity.Left := 570;mEd_quantity.Top := 10;mEd_quantity.Width := 30;mEd_quantity.Name := 'mEd_quantity'; mEd_quantity.Text:=NxFloatToIBStr(mF_doba);mForm1.InsertControl(mEd_quantity);
                                                                                                                                                                              mL1_operation:= TLabel.Create(mForm1); mL1_operation.Parent := mForm1;mL1_operation.Caption := 'Doprava :';mL1_operation.Top := 14;mL1_operation.Left := 630;mL1_operation.Height := 13;mL1_operation.Width := 80;
                                                                                                                                                                              mEd1_quantity := TEdit.Create(mForm1);mEd1_quantity.Left := 680;mEd1_quantity.Top := 10;mEd1_quantity.Width := 50;mEd1_quantity.Name := 'mEd1_quantity';mEd1_quantity.Text:=NxFloatToIBStr(mRow_Pomoc.GetFieldValueAsFloat('Quantity'));mForm1.InsertControl(mEd1_quantity);
                                                                                                                                                                              mEd1_Pohotovost := TCheckBox.Create(mForm1);mEd1_Pohotovost.Left := 750;mEd1_Pohotovost.Top := 12;mEd1_Pohotovost.Width := 100;mEd1_Pohotovost.Name := 'mEd1_Pohotovost';mEd1_pohotovost.Caption:='Pohotovost';if mRow_Pomoc.GetFieldValueAsBoolean('X_Pohotovost')= true then mEd1_Pohotovost.State:=1;if mRow_Pomoc.GetFieldValueAsBoolean('X_Pohotovost')= false then mEd1_Pohotovost.State:=0;mForm1.InsertControl(mEd1_Pohotovost);
                                                                                                                                                                              mL1_C_protokol:= TLabel.Create(mForm1);mL1_C_protokol.Parent := mForm1;mL1_C_protokol.Caption := 'Protokol :' + mBO_ML.getFieldValueAsString('X_protokol_prefix');mL1_C_protokol.Top := 14;mL1_C_protokol.Left := 840;mL1_C_protokol.Height := 13;mL1_C_protokol.Width := 60;
                                                                                                                                                                              mEd1_C_protokol := TEdit.Create(mForm1);mEd1_C_protokol.Left := 900;mEd1_C_protokol.Top := 10;mEd1_C_protokol.Width := 100;mEd1_C_protokol.Name := 'mEd1_C_protokol';mEd1_C_protokol.Text:=mBO_ML.GetFieldValueAsString('X_Protokol');mForm1.InsertControl(mEd1_C_protokol);
                                                                                                                                                                              mL1_C_chyby:= TLabel.Create(mForm1);mL1_C_chyby.Parent := mForm1;mL1_C_chyby.Caption := 'Závada :';mL1_C_chyby.Top := 14;mL1_C_chyby.Left := 1020;mL1_C_chyby.Height := 13;mL1_C_chyby.Width := 50;
                                                                                                                                                                              mEd1_C_chyby := TEdit.Create(mForm1);mEd1_C_chyby.Left := 1070;mEd1_C_chyby.Top := 10;mEd1_C_chyby.Width := 100;mEd1_C_chyby.Name := 'mEd1_C_chyby';mEd1_C_chyby.Text:=mBO_ML.GetFieldValueAsString('X_zavada_code');mForm1.InsertControl(mEd1_C_chyby);
                                                                                                                                                                              mL1_P_Cyklu:= TLabel.Create(mForm1);mL1_P_Cyklu.Parent := mForm1;mL1_P_Cyklu.Caption := 'Cyklů :';mL1_P_Cyklu.Top := 14;mL1_P_Cyklu.Left := 1190;mL1_P_Cyklu.Height := 13;mL1_P_Cyklu.Width := 50;
                                                                                                                                                                              mEd1_P_Cyklu := TEdit.Create(mForm1);mEd1_P_Cyklu.Left := 1250;mEd1_P_Cyklu.Top := 10;mEd1_P_Cyklu.Width := 80;mEd1_P_Cyklu.Name := 'mEd1_P_Cyklu';mEd1_P_Cyklu.Text:=inttostr(mBO_ML.GetFieldValueAsInteger('X_Pocet_cyklu'));mForm1.InsertControl(mEd1_P_Cyklu);
                                                                                                                                                                          mBtn := TButton.Create(mForm1);mBtn.Width := 75;mBtn.Height := 25;mBtn.Caption := 'OK';mBtn.ModalResult := mrOk;mBtn.Cancel := False;mBtn.Default := True;mBtn.Left :=  mForm1.Width - 2*(mBtn.Width+2) - 20;mBtn.Top := mForm1.Height - mBtn.Height - 40;mBtn.Name := 'btnOK';mForm1.InsertControl(mBtn);
                                                                                                                                                                          mBtn := TButton.Create(mForm1);mBtn.Width := 75;mBtn.Height := 25;mBtn.Caption := 'Storno';mBtn.ModalResult := mrCancel; mBtn.Cancel := True;mBtn.Left := mForm1.Width - (mBtn.Width+2) - 20; mBtn.Top := mForm1.Height - mBtn.Height - 40;mBtn.Name := 'btnCancel';mForm1.InsertControl(mBtn);

                                                                                                                                                                          if mForm1.ShowModal(xSite) = mrOK then begin
                                                                                                                                                                                   mB_pokracovat:=true;
                                                                                                                                                                                   mD_ML_End:=trunc(mKonecDAte.DateTime)+mKonectime.Time;
                                                                                                                                                                                   mDateto:=trunc(mKonecDAte.DateTime)+mKonectime.Time;

                                                                                                                                                                                   if mEd1_Pohotovost.State=0 then mRow_Pomoc.setFieldValueAsBoolean('X_Pohotovost',false);
                                                                                                                                                                                   if mEd1_Pohotovost.State=1 then mRow_Pomoc.setFieldValueAsBoolean('X_Pohotovost',True);
                                                                                                                                                                                   mBO_ML.SetFieldValueAsString('X_zavada_code',mEd1_C_chyby.Text);
                                                                                                                                                                                   mBO_ML.SetFieldValueAsString('X_Protokol',mEd1_C_protokol.Text);
                                                                                                                                                                                   mBO_ML.SetFieldValueAsInteger('X_Pocet_cyklu',StrToInt(mEd1_P_Cyklu.Text));


                                                                                                                                                                                   mWorkHoursReal:=NxIBStrToFloat(mEd_quantity.text) ;
                                                                                                                                                                                   mpocet_km:=NxIBStrToFloat(mEd1_quantity.text) ;
                                                                                                                                                                                   mDateto:=trunc(mKonecDAte.DateTime) + frac((mKonecTime.Time));
                                                                                                                                                                                   mRow_Pomoc.SetFieldValueAsFloat('WorkHoursReal',mWorkHoursReal);
                                                                                                                                                                                   mRow_Pomoc.SetFieldValueAsDateTime('X_konec_prace',mD_ML_End);

                                                                                                                                                                           end else begin
                                                                                                                                                                              mB_pokracovat:=false;
                                                                                                                                                                           end;
                                                                                                                                                                      finally
                                                                                                                                                                          mForm1.Free;
                                                                                                                                                                      end;
                                                                                                                                                                      msleva:=mRow_Pomoc.getFieldValueAsinteger('X_radkova_sleva');
                                                                                                                                                                      if ((mRow_Pomoc.getFieldValueAsFloat('WorkHoursReal')<=0) and (mWorkHoursReal<>0)) and (not mB_pokracovat) then begin
                                                                                                                                                                           if mB_pokracovat then nxShowSimpleMessage('Operace byla přerušena',nil) else  nxShowSimpleMessage('Není zadaná reálně odpracovaná doba, nelze pokračovat',nil);
                                                                                                                                                                      end else begin
                                                                                                                                                                            mstore:=mRow_Pomoc.getFieldValueAsString('Store_id');

                                                                                                                                                                               mDatefrom:=mDateto - EncodeTime(trunc(mF_doba),trunc(frac(trunc(mF_doba)*60)),0,0);
                                                                                                                                                                                  if mB_pokracovat then begin // není záruka
                                                                                                                                                                                              mF_svatek:=0;mF_vikend:=0;mF_mimo:=0;mF_prace:=0;mFS_svatek:=0;mFS_vikend:=0;mFS_mimo:=0;mFS_prace:=0;mDateZac:=frac(mPRzac);mDateKon:=frac(mPRkon);
                                                                                                                                                                                            if trunc(mDateto)=trunc(mDatefrom) then begin          // jednodenní operace
                                                                                                                                                                                                 mF_svatek:=Svatek(mBO_ML.ObjectSpace,mDatefrom,mDateto);
                                                                                                                                                                                                      if mF_svatek=0 then begin
                                                                                                                                                                                                          mF_vikend:=vikend(mBO_ML.ObjectSpace,mDatefrom,mDateto);
                                                                                                                                                                                                             if mF_vikend=0 then begin
                                                                                                                                                                                                               mF_Mimo:=Mimo(mBO_ML.ObjectSpace,frac(mDatefrom),frac(mDateto),frac(mDateZac),frac(mDateKon));
                                                                                                                                                                                                               mF_Prace:=Pracovni_doba(mBO_ML.ObjectSpace,frac(mDatefrom),frac(mDateto),frac(mDateZac),frac(mDateKon));
                                                                                                                                                                                                             end;
                                                                                                                                                                                                      end;
                                                                                                                                                                                                  mFS_svatek:=mFS_svatek+mF_svatek;
                                                                                                                                                                                                  mFS_vikend:=mFS_vikend+mF_vikend;
                                                                                                                                                                                                  mFS_Mimo:=mFS_Mimo+mF_Mimo;
                                                                                                                                                                                                  mFS_Prace:=mFS_Prace+mF_Prace;// jednodenní práce
                                                                                                                                                                                            end else begin
                                                                                                                                                                                                mDnu:=trunc(mDateto)-trunc(mDatefrom) ;
                                                                                                                                                                                                for II:=0 to mDnu do begin
                                                                                                                                                                                                   if (trunc(mDateFrom)+ii=trunc(mDatefrom)) or (trunc(mDateFrom)+ii=trunc(mDateto)) then begin       // necelý den
                                                                                                                                                                                                       if (trunc(mDateFrom)+ii=trunc(mDatefrom)) then begin  // první den
                                                                                                                                                                                                            //if ladit then NxShowSimpleMessage('První den',nil);
                                                                                                                                                                                                            mF_svatek:=Svatek(mBO_ML.ObjectSpace,mDatefrom,mDateto);
                                                                                                                                                                                                            if mF_svatek=0 then begin
                                                                                                                                                                                                                  mF_vikend:=vikend(mBO_ML.ObjectSpace,mDatefrom,trunc(mdatefrom)+1);
                                                                                                                                                                                                                  if mF_vikend=0 then begin
                                                                                                                                                                                                                        mF_Mimo:=Mimo(mBO_ML.ObjectSpace,frac(mDatefrom),1,frac(mDateZac),frac(mDateKon));
                                                                                                                                                                                                                        mF_Prace:=Pracovni_doba(mBO_ML.ObjectSpace,frac(mDatefrom),1,frac(mDateZac),frac(mDateKon));
                                                                                                                                                                                                                  end;
                                                                                                                                                                                                            end;
                                                                                                                                                                                                       end;
                                                                                                                                                                                                       if (trunc(mDateFrom)+ii=trunc(mDateto)) then begin    // poslední den
                                                                                                                                                                                                            mF_svatek:=Svatek(mBO_ML.ObjectSpace,trunc(mDateto),mDateto);
                                                                                                                                                                                                            //if ladit then NxShowSimpleMessage('Poslední den',nil);
                                                                                                                                                                                                            if mF_svatek=0 then begin
                                                                                                                                                                                                                  mF_vikend:=vikend(mBO_ML.ObjectSpace,trunc(mDateto),mDateto);
                                                                                                                                                                                                                  if mF_vikend=0 then begin
                                                                                                                                                                                                                        mF_Mimo:=Mimo(mBO_ML.ObjectSpace,0,frac(mDateto),frac(mDateZac),frac(mDateKon));
                                                                                                                                                                                                                        mF_Prace:=Pracovni_doba(mBO_ML.ObjectSpace,0,frac(mDateto),frac(mDateZac),frac(mDateKon));
                                                                                                                                                                                                                  end;
                                                                                                                                                                                                            end;
                                                                                                                                                                                                       end;
                                                                                                                                                                                                   end else begin    // celý den
                                                                                                                                                                                                      mF_svatek:=Svatek(mBO_ML.ObjectSpace,trunc(mDatefrom)+ii,trunc(mDatefrom)+1+ii);
                                                                                                                                                                                                            if mF_svatek=0 then begin
                                                                                                                                                                                                                  mF_vikend:=vikend(mBO_ML.ObjectSpace,trunc(mDatefrom)+ii,trunc(mDatefrom)+1+ii);
                                                                                                                                                                                                                  if mF_vikend=0 then begin
                                                                                                                                                                                                                       // if ladit then NxShowSimpleMessage('Celý den',nil);
                                                                                                                                                                                                                        mF_Mimo:=Mimo(mBO_ML.ObjectSpace,trunc(mDatefrom)+ii,trunc(mDatefrom)+1+ii,frac(mDateZac),frac(mDateKon));
                                                                                                                                                                                                                        mF_Prace:=Pracovni_doba(mBO_ML.ObjectSpace,trunc(mDatefrom)+ii,trunc(mDatefrom)+1+ii,frac(mDateZac),frac(mDateKon));
                                                                                                                                                                                                                  end;
                                                                                                                                                                                                            end;
                                                                                                                                                                                                      end;
                                                                                                                                                                                                  mFS_svatek:=mFS_svatek+mF_svatek;
                                                                                                                                                                                                  mFS_vikend:=mFS_vikend+mF_vikend;
                                                                                                                                                                                                  mFS_Mimo:=mFS_Mimo+mF_Mimo;
                                                                                                                                                                                                  mFS_Prace:=mFS_Prace+mF_Prace;


                                                                                                                                                                                                end;
                                                                                                                                                                                            end;
                                                                                                                                                                                            mkorekce:=0;
                                                                                                                                                                                            mFS_Prace:=NxIBStrToFloat(FormatDateTime('H',mFS_Prace)) + (NxIBStrToFloat(FormatDateTime('N',mFS_Prace))*(100/60));
                                                                                                                                                                                            mFS_Mimo:=NxIBStrToFloat(FormatDateTime('H',mFS_Mimo))+ (NxIBStrToFloat(FormatDateTime('N',mFS_Mimo))*(100/60));
                                                                                                                                                                                            if mfs_mimo<0 then begin
                                                                                                                                                                                               mFS_Prace:=mFS_Prace+mFS_Mimo;
                                                                                                                                                                                               mFS_Prace:=NxIBStrToFloat(FormatDateTime('H',mFS_Prace)) + (NxIBStrToFloat(FormatDateTime('N',mFS_Prace))*(100/60));
                                                                                                                                                                                               mFS_Mimo:=0;
                                                                                                                                                                                               end else begin
                                                                                                                                                                                               mFS_Mimo:=NxIBStrToFloat(FormatDateTime('H',mFS_Mimo))+ (NxIBStrToFloat(FormatDateTime('N',mFS_Mimo))*(100/60));
                                                                                                                                                                                            end;
                                                                                                                                                                                            mFS_svatek:=NxIBStrToFloat(FormatDateTime('H',mFS_svatek))+ (NxIBStrToFloat(FormatDateTime('N',mFS_svatek))*(100/60));
                                                                                                                                                                                            mFS_vikend:=NxIBStrToFloat(FormatDateTime('H',mF_vikend))+ (NxIBStrToFloat(FormatDateTime('N',mF_vikend))*(100/60));



                                                                                                                                                                                            if mWorkHoursReal<>(mFS_svatek+mFS_vikend +mFS_Mimo+mFS_Prace) then begin
                                                                                                                                                                                                    mkorekce:=mWorkHoursReal-(mFS_svatek+mFS_vikend+mFS_Mimo+mFS_Prace) ;
                                                                                                                                                                                                    if mFS_vikend+mFS_svatek>0 then begin
                                                                                                                                                                                                       mFS_vikend:=(mFS_vikend+mkorekce);
                                                                                                                                                                                                       mkorekce:=0;
                                                                                                                                                                                                    end;
                                                                                                                                                                                                    if mFS_Mimo>0 then begin
                                                                                                                                                                                                       mFS_Mimo:=(mFS_Mimo+mkorekce);
                                                                                                                                                                                                       mkorekce:=0;
                                                                                                                                                                                                    end else begin
                                                                                                                                                                                                           mFS_Prace:=mWorkHoursReal-(mFS_svatek+mFS_vikend+mFS_Mimo)
                                                                                                                                                                                                    end;
                                                                                                                                                                                            end;
                                                                                                                                                                                            mForm1 := TForm.Create(xSite);
                                                                                                                                                                                             try
                                                                                                                                                                                                  mForm1.Caption := 'Rozpočtení práce pro fakturaci';mForm1.FormStyle := fsStayOnTop;mForm1.BorderStyle := bsDialog;mForm1.Width := 450; mForm1.Height := 450;mForm1.Scaled := False;mForm1.Position := poScreenCenter;
                                                                                                                                                                                                  mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := 'Technik :';mL_Technik.Top := 12;mL_Technik.Left := 10;mL_Technik.Height := 13;
                                                                                                                                                                                                  mL_technik_value:= TLabel.Create(mForm1);mL_technik_value.Parent := mForm1;mL_technik_value.Caption := mRow_Pomoc.GetFieldValueAsString('X_WorkerRole_ID.Name');mL_technik_value.Top := 12;mL_technik_value.Left := 80;mL_technik_value.Height := 13;mL_technik_value.Width := 200;
                                                                                                                                                                                                  mL_technik_value:= TLabel.Create(mForm1);mL_technik_value.Parent := mForm1; mL_technik_value.Caption := ('Konec práce');mL_technik_value.Top := 10;mL_technik_value.Left := 150;mL_technik_value.Height := 13;mL_technik_value.Width := 200;
                                                                                                                                                                                                  mKonecDAte := TDateTimeEdit.Create(mForm1);mKonecDAte.Left := 230;mKonecDAte.Top := 10;mKonecDAte.Width := 80;mKonecDAte.Name := 'mKonecDAte';mKonecDAte.DateTime:= mDateto;mKonecDAte.Enabled:=false;mForm1.InsertControl(mKonecDAte);
                                                                                                                                                                                                  mKonecTime := TTimeEdit.Create(mForm1);mKonecTime.Left := 330;mKonecTime.Top := 10;mKonecTime.Width := 80;mKonecTime.Name := 'mKonecTime';mKonecTime.Time:= mDateto;mKonecTime.Enabled:= False;mForm1.InsertControl(mKonecTime);

                                                                                                                                                                                                   if true then begin
                                                                                                                                                                                                       mL_operation:= TLabel.Create(mForm1);mL_operation.Parent := mForm1;mL_operation.Caption := 'Práce paušál :';mL_operation.Top := 42;mL_operation.Left := 10;mL_operation.Height := 13;mL_operation.Width := 320;
                                                                                                                                                                                                       mEd_quantity := TEdit.Create(mForm1);mEd_quantity.Left := 150;mEd_quantity.Top := 42;mEd_quantity.Width := 80;mEd_quantity.Name := 'mEd_quantity';if mF_pausal_prace<>0 then mEd_quantity.Text:='0' else mEd_quantity.Text:='0' ;mForm1.InsertControl(mEd_quantity);
                                                                                                                                                                                                       mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1; mL_Technik.Caption := 'ks';mL_Technik.Top := 42;mL_Technik.Left := 240 ;mL_Technik.Height := 13;
                                                                                                                                                                                                       mEd_Unitprice:= TEdit.Create(mForm1);mEd_Unitprice.Left := 280;mEd_Unitprice.Top := 40;mEd_Unitprice.Width := 80;mEd_Unitprice.Name := 'mEd_Unitprice';mEd_Unitprice.Text:=NxFloatToIBStr(mF_pausal_prace);mForm1.InsertControl(mEd_Unitprice);
                                                                                                                                                                                                       mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := '  kč/j';mL_Technik.Top := 42;mL_Technik.Left := 360;mL_Technik.Height := 13;
                                                                                                                                                                                                   end;
                                                                                                                                                                                                   mxpomoc:=0;
                                                                                                                                                                                                   if mF_pausal_Vyjezd<>0 then begin
                                                                                                                                                                                                       mxpomoc:=1;
                                                                                                                                                                                                   end;
                                                                                                                                                                                                           if true then begin
                                                                                                                                                                                                               mL_operation:= TLabel.Create(mForm1);mL_operation.Parent := mForm1;mL_operation.Caption := 'Doprava paušál :';mL_operation.Top := 72;mL_operation.Left := 10;mL_operation.Height := 13;mL_operation.Width := 320;
                                                                                                                                                                                                               mEd_quantity1 := TEdit.Create(mForm1);mEd_quantity1.Left := 150;mEd_quantity1.Top := 70;mEd_quantity1.Width := 80;mEd_quantity1.Name := 'mEd_quantity1';mEd_quantity1.Text:=NxFloatToIBStr(mxpomoc) ;mForm1.InsertControl(mEd_quantity1);mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := 'ks';mL_Technik.Top := 72; mL_Technik.Left := 240 ;mL_Technik.Height := 13;
                                                                                                                                                                                                               mEd_Unitprice1:= TEdit.Create(mForm1);mEd_Unitprice1.Left := 280;mEd_Unitprice1.Top := 70;mEd_Unitprice1.Width := 80;mEd_Unitprice1.Name := 'mEd_Unitprice1';mEd_Unitprice1.Text:=NxFloatToIBStr(mF_pausal_Vyjezd);mForm1.InsertControl(mEd_Unitprice1);
                                                                                                                                                                                                               mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := '  kč/j';mL_Technik.Top := 72;mL_Technik.Left := 360;mL_Technik.Height := 13;
                                                                                                                                                                                                           end;

                                                                                                                                                                                       {            if false then begin
                                                                                                                                                                                                       mL_operation:= TLabel.Create(mForm1);mL_operation.Parent := mForm1;mL_operation.Caption := 'Pracovní doba :';mL_operation.Top := 102;mL_operation.Left := 10;mL_operation.Height := 13;mL_operation.Width := 320;
                                                                                                                                                                                                       mEd_quantity2 := TEdit.Create(mForm1);mEd_quantity2.Left := 150; mEd_quantity2.Top := 100;mEd_quantity2.Width := 80;mEd_quantity2.Name := 'mEd_quantity2';mEd_quantity2.Text:=NxFloatToIBStr(mf_doba);mForm1.InsertControl(mEd_quantity2);
                                                                                                                                                                                                       mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := 'ks';mL_Technik.Top := 102;mL_Technik.Left := 240 ;mL_Technik.Height := 13;
                                                                                                                                                                                                       mEd_Unitprice2:= TEdit.Create(mForm1);mEd_Unitprice2.Left := 280;mEd_Unitprice2.Top := 100;mEd_Unitprice2.Width := 80;mEd_Unitprice2.Name := 'mEd_Unitprice2';mEd_Unitprice2.Text:=NxFloatToIBStr(mf_doba);mForm1.InsertControl(mEd_Unitprice2);
                                                                                                                                                                                                       mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := '  kč/j';mL_Technik.Top := 102;mL_Technik.Left := 360;mL_Technik.Height := 13;
                                                                                                                                                                                                   end;
                                                                                                                                                                                       }
                                                                                                                                                                                                   if true then begin
                                                                                                                                                                                                       mL_operation:= TLabel.Create(mForm1);mL_operation.Parent := mForm1;mL_operation.Caption := 'Pracovní doba :';mL_operation.Top := 132;mL_operation.Left := 10;mL_operation.Height := 13;mL_operation.Width := 320;
                                                                                                                                                                                                       mEd_quantity3 := TEdit.Create(mForm1);mEd_quantity3.Left := 150;mEd_quantity3.Top := 130;mEd_quantity3.Width := 80; mEd_quantity3.Name := 'mFS_prace';mEd_quantity3.Text:=NxFloatToIBStr(mFS_Prace);
                                                                                                                                                                                                       mForm1.InsertControl(mEd_quantity3);mL_Technik:= TLabel.Create(mForm1); mL_Technik.Parent := mForm1;mL_Technik.Caption := 'hod';mL_Technik.Top := 132;mL_Technik.Left := 240 ; mL_Technik.Height := 13;
                                                                                                                                                                                                       mEd_Unitprice3:= TEdit.Create(mForm1);mEd_Unitprice3.Left := 280;mEd_Unitprice3.Top := 130;mEd_Unitprice3.Width := 80; mEd_Unitprice3.Name := 'mEd_Unitprice3';mEd_Unitprice3.Text:=NxFloatToIBStr(mFSazba_Prace);mForm1.InsertControl(mEd_Unitprice3);
                                                                                                                                                                                                       mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := '  kč/j';mL_Technik.Top := 132;mL_Technik.Left := 360;mL_Technik.Height := 13;
                                                                                                                                                                                                   end;

                                                                                                                                                                                                   if true then begin
                                                                                                                                                                                                        mL_operation:= TLabel.Create(mForm1); mL_operation.Parent := mForm1;mL_operation.Caption := 'Mimo pracovní dobu :'; mL_operation.Top := 162;mL_operation.Left := 10;mL_operation.Height := 13;mL_operation.Width := 320;
                                                                                                                                                                                                        mEd_quantity4 := TEdit.Create(mForm1);mEd_quantity4.Left := 150;mEd_quantity4.Top := 160;mEd_quantity4.Width := 80;mEd_quantity4.Name := 'mEd_quantity4'; mEd_quantity4.Text:=NxFloatToIBStr(mFS_mimo);mForm1.InsertControl(mEd_quantity4);
                                                                                                                                                                                                        mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := 'hod';mL_Technik.Top := 162;mL_Technik.Left := 240 ;mL_Technik.Height := 13;
                                                                                                                                                                                                        mEd_Unitprice4:= TEdit.Create(mForm1);mEd_Unitprice4.Left := 280;mEd_Unitprice4.Top := 160;mEd_Unitprice4.Width := 80;mEd_Unitprice4.Name := 'mEd_Unitprice4';mEd_Unitprice4.Text:=NxFloatToIBStr(mFSazba_Mimo);mForm1.InsertControl(mEd_Unitprice4);
                                                                                                                                                                                                        mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := '  kč/j';mL_Technik.Top := 162;mL_Technik.Left := 360;mL_Technik.Height := 13;
                                                                                                                                                                                                   end;

                                                                                                                                                                                                   if true then begin
                                                                                                                                                                                                        mL_operation:= TLabel.Create(mForm1);mL_operation.Parent := mForm1;mL_operation.Caption := 'Víkend + Svátek :';mL_operation.Top := 192;mL_operation.Left := 10;mL_operation.Height := 13;mL_operation.Width := 320;
                                                                                                                                                                                                        mEd_quantity5 := TEdit.Create(mForm1);mEd_quantity5.Left := 150;mEd_quantity5.Top := 190;mEd_quantity5.Width := 80;mEd_quantity5.Name := 'mEd_quantity5';mEd_quantity5.Text:=NxFloatToIBStr(mFS_Vikend);mForm1.InsertControl(mEd_quantity5);
                                                                                                                                                                                                        mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := 'hod';mL_Technik.Top := 192;mL_Technik.Left := 240 ;mL_Technik.Height := 13;
                                                                                                                                                                                                        mEd_Unitprice5:= TEdit.Create(mForm1);mEd_Unitprice5.Left := 280;mEd_Unitprice5.Top := 190;mEd_Unitprice5.Width := 80;mEd_Unitprice5.Name := 'mEd_Unitprice5';mEd_Unitprice5.Text:=NxFloatToIBStr(mFSazba_Vikend);mForm1.InsertControl(mEd_Unitprice5);
                                                                                                                                                                                                        mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := '  kč/j';mL_Technik.Top := 192;mL_Technik.Left := 360;mL_Technik.Height := 13;
                                                                                                                                                                                                   end;

                                                                                                                                                                                                   if false then begin
                                                                                                                                                                                                        mL_operation:= TLabel.Create(mForm1);mL_operation.Parent := mForm1;mL_operation.Caption := 'Práce paušál :';mL_operation.Top := 222;mL_operation.Left := 10;mL_operation.Height := 13;mL_operation.Width := 320;
                                                                                                                                                                                                        mEd_quantity6 := TEdit.Create(mForm1);mEd_quantity6.Left := 150;mEd_quantity6.Top := 220;mEd_quantity6.Width := 80;mEd_quantity6.Name := 'mEd_quantity6';mEd_quantity6.Text:=NxFloatToIBStr(mf_doba);mForm1.InsertControl(mEd_quantity6);
                                                                                                                                                                                                        mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := 'ks';mL_Technik.Top := 222;mL_Technik.Left := 240 ;mL_Technik.Height := 13;
                                                                                                                                                                                                        mEd_Unitprice6:= TEdit.Create(mForm1);mEd_Unitprice6.Left := 280;mEd_Unitprice6.Top := 220;mEd_Unitprice6.Width := 80;mEd_Unitprice6.Name := 'mEd_Unitprice6';mEd_Unitprice6.Text:=NxFloatToIBStr(mf_doba);mForm1.InsertControl(mEd_Unitprice6);
                                                                                                                                                                                                        mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := '  kč/j';mL_Technik.Top := 222;mL_Technik.Left := 360;mL_Technik.Height := 13;
                                                                                                                                                                                                   end;

                                                                                                                                                                                                   if true then begin
                                                                                                                                                                                                        mL_operation:= TLabel.Create(mForm1);mL_operation.Parent := mForm1;mL_operation.Caption := 'Doprava km :';mL_operation.Top := 252;mL_operation.Left := 10;mL_operation.Height := 13;mL_operation.Width := 320;
                                                                                                                                                                                                        mEd_quantity7 := TEdit.Create(mForm1);mEd_quantity7.Left := 150;mEd_quantity7.Top := 250;mEd_quantity7.Width := 80;mEd_quantity7.Name := 'mEd_quantity7';mEd_quantity7.Text:=NxFloatToIBStr(mpocet_km);mForm1.InsertControl(mEd_quantity7);
                                                                                                                                                                                                        mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := 'km';mL_Technik.Top := 252;mL_Technik.Left := 240 ;mL_Technik.Height := 13;
                                                                                                                                                                                                        mEd_Unitprice7:= TEdit.Create(mForm1);mEd_Unitprice7.Left := 280;mEd_Unitprice7.Top := 250;mEd_Unitprice7.Width := 80;mEd_Unitprice7.Name := 'mEd_Unitprice7';mEd_Unitprice7.Text:=NxFloatToIBStr(mFSazba_Doprava_km);mForm1.InsertControl(mEd_Unitprice7);
                                                                                                                                                                                                        mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := '  kč/km';mL_Technik.Top := 252;mL_Technik.Left := 360;mL_Technik.Height := 13;
                                                                                                                                                                                                   end;

                                                                                                                                                                                                   if false then begin
                                                                                                                                                                                                        mL_operation:= TLabel.Create(mForm1);mL_operation.Parent := mForm1;mL_operation.Caption := 'Práce paušál :';mL_operation.Top := 282;mL_operation.Left := 10;mL_operation.Height := 13;mL_operation.Width := 320;
                                                                                                                                                                                                        mEd_quantity8 := TEdit.Create(mForm1);mEd_quantity8.Left := 150;mEd_quantity8.Top := 280;mEd_quantity8.Width := 80;mEd_quantity8.Name := 'mEd_quantity8';mEd_quantity8.Text:=NxFloatToIBStr(mf_doba);mForm1.InsertControl(mEd_quantity8);
                                                                                                                                                                                                        mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := 'ks';mL_Technik.Top := 282;mL_Technik.Left := 240 ;mL_Technik.Height := 13;
                                                                                                                                                                                                        mEd_Unitprice8:= TEdit.Create(mForm1);mEd_Unitprice8.Left := 280;mEd_Unitprice8.Top := 280;mEd_Unitprice8.Width := 80;mEd_Unitprice8.Name := 'mEd_Unitprice8';mEd_Unitprice8.Text:=NxFloatToIBStr(mf_doba);mForm1.InsertControl(mEd_Unitprice8);
                                                                                                                                                                                                        mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := '  kč/j';mL_Technik.Top := 282;mL_Technik.Left := 360;mL_Technik.Height := 13;
                                                                                                                                                                                                   end;

                                                                                                                                                                                                   if true then begin
                                                                                                                                                                                                        mL_operation:= TLabel.Create(mForm1);mL_operation.Parent := mForm1;mL_operation.Caption := 'Výjezd do 3 hodin :';mL_operation.Top := 312;mL_operation.Left := 10;mL_operation.Height := 13; mL_operation.Width := 320;
                                                                                                                                                                                                        mEd_quantity9 := TEdit.Create(mForm1);mEd_quantity9.Left := 150;mEd_quantity9.Top := 310;mEd_quantity9.Width := 80;mEd_quantity9.Name := 'mEd_quantity9';mEd_quantity9.Text:=NxFloatToIBStr(0);mForm1.InsertControl(mEd_quantity9);
                                                                                                                                                                                                        mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := 'ks';mL_Technik.Top := 312;mL_Technik.Left := 240 ;mL_Technik.Height := 13;
                                                                                                                                                                                                        mEd_Unitprice9:= TEdit.Create(mForm1);mEd_Unitprice9.Left := 280;mEd_Unitprice9.Top := 310;mEd_Unitprice9.Width := 80;mEd_Unitprice9.Name := 'mEd_Unitprice9';mEd_Unitprice9.Text:=NxFloatToIBStr(mFPriplatek3H);mForm1.InsertControl(mEd_Unitprice9);
                                                                                                                                                                                                        mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := '  kč/j';mL_Technik.Top := 312;mL_Technik.Left := 360;mL_Technik.Height := 13;
                                                                                                                                                                                                   end;
                                                                                                                                                                                                  mBtn := TButton.Create(mForm1);mBtn.Width := 75;mBtn.Height := 25;mBtn.Caption := 'OK';mBtn.ModalResult := mrOk;mBtn.Cancel := False;mBtn.Default := True;mBtn.Left :=  mForm1.Width - 2*(mBtn.Width+2) - 20;mBtn.Top := mForm1.Height - mBtn.Height - 40;mBtn.Name := 'btnOK';mForm1.InsertControl(mBtn);
                                                                                                                                                                                                  mBtn := TButton.Create(mForm1);mBtn.Width := 75;mBtn.Height := 25;mBtn.Caption := 'Storno';mBtn.ModalResult := mrCancel;mBtn.Cancel := True;mBtn.Left := mForm1.Width - (mBtn.Width+2) - 20;mBtn.Top := mForm1.Height - mBtn.Height - 40;mBtn.Name := 'btnCancel';mForm1.InsertControl(mBtn);

                                                                                                                                                                                                  if mForm1.ShowModal(xSite) = mrOK then begin
                                                                                                                                                                                                        mB_pokracovat:=true;
                                                                                                                                                                                                        if NxIBStrToFloat(mEd_quantity.text)>0 then begin
                                                                                                                                                                                                                    mNewRow := mRows_ML.AddNewObject;mNewRow.SetFieldValueAsInteger('Posindex',i+55);mNewRow.SetFieldValueAsInteger('itemtype',0);mNewRow.SetFieldValueAsString('WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('X_WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('Text','Paušál práce');mNewRow.SetFieldValueAsString('Store_id',mStore);mNewRow.SetFieldValueAsString('StoreCard_id','1ZI1000101');mNewRow.SetFieldValueAsfloat('WorkHoursPlanned',NxIBStrToFloat(mEd_quantity.text));mNewRow.SetFieldValueAsfloat('WorkHoursReal',NxIBStrToFloat(mEd_quantity.text));mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',NxIBStrToFloat(mEd_Unitprice.Text));mNewRow.SetFieldValueAsfloat('X_radkova_sleva',0);mNewRow.SetFieldValueAsDateTime('X_konec_prace',mDateto);
                                                                                                                                                                                                                    mNewRow.SetFieldValueAsBoolean('X_Pohotovost',mRow_Pomoc.getFieldValueAsBoolean('X_Pohotovost'));//mNewRow.Save;mNewRow.free;
                                                                                                                                                                                                                end;
                                                                                                                                                                                                                if NxIBStrToFloat(mEd_quantity1.text)>0 then begin
                                                                                                                                                                                                                    mNewRow := mRows_ML.AddNewObject;mNewRow.SetFieldValueAsInteger('Posindex',i+60);mNewRow.SetFieldValueAsInteger('itemtype',0);mNewRow.SetFieldValueAsString('WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('X_WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('Text','Paušál doprava');mNewRow.SetFieldValueAsString('Store_id',mStore);mNewRow.SetFieldValueAsBoolean('X_Pohotovost',mRow_Pomoc.getFieldValueAsBoolean('X_Pohotovost'));mNewRow.SetFieldValueAsString('StoreCard_id','1FD1000101');mNewRow.SetFieldValueAsfloat('WorkHoursPlanned',NxIBStrToFloat(mEd_quantity1.text));mNewRow.SetFieldValueAsfloat('WorkHoursReal',NxIBStrToFloat(mEd_quantity1.text));mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',NxIBStrToFloat(mEd_Unitprice1.Text));mNewRow.SetFieldValueAsfloat('X_radkova_sleva',0);
                                                                                                                                                                                                                    mNewRow.SetFieldValueAsDateTime('X_konec_prace',mDateto);//mNewRow.Save;mNewRow.free;
                                                                                                                                                                                                                end;

                                                                                                                                                                                                                if NxIBStrToFloat(mEd_quantity.Text)=0 then begin
                                                                                                                                                                                                                          if NxIBStrToFloat(mEd_quantity3.text)>0 then begin
                                                                                                                                                                                                                                  mNewRow := mRows_ML.AddNewObject; mNewRow.SetFieldValueAsInteger('Posindex',i+65);mNewRow.SetFieldValueAsInteger('itemtype',0); mNewRow.SetFieldValueAsString('WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('X_WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('Text','Práce Pracovní doba');mNewRow.SetFieldValueAsString('Store_id',mStore);mNewRow.SetFieldValueAsString('StoreCard_id','17T0000101');mNewRow.SetFieldValueAsBoolean('X_Pohotovost',mRow_Pomoc.getFieldValueAsBoolean('X_Pohotovost'));mNewRow.SetFieldValueAsfloat('WorkHoursPlanned',NxIBStrToFloat(mEd_quantity3.text));mNewRow.SetFieldValueAsfloat('WorkHoursReal',NxIBStrToFloat(mEd_quantity3.text));mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',NxIBStrToFloat(mEd_Unitprice3.Text));mNewRow.SetFieldValueAsfloat('X_radkova_sleva',msleva);
                                                                                                                                                                                                                                  mNewRow.SetFieldValueAsDateTime('X_konec_prace',mDateto);//mNewRow.Save;mNewRow.free;
                                                                                                                                                                                                                              end;
                                                                                                                                                                                                                              if NxIBStrToFloat(mEd_quantity4.text)>0 then begin
                                                                                                                                                                                                                                  mNewRow := mRows_ML.AddNewObject;mNewRow.SetFieldValueAsInteger('Posindex',i+70);mNewRow.SetFieldValueAsInteger('itemtype',0); mNewRow.SetFieldValueAsString('WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('X_WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('Text','Práce mimo pracovní dobu');mNewRow.SetFieldValueAsString('Store_id',mStore);mNewRow.SetFieldValueAsString('StoreCard_id','17T0000101');mNewRow.SetFieldValueAsBoolean('X_Pohotovost',mRow_Pomoc.getFieldValueAsBoolean('X_Pohotovost'));mNewRow.SetFieldValueAsfloat('WorkHoursPlanned',NxIBStrToFloat(mEd_quantity4.text));mNewRow.SetFieldValueAsfloat('WorkHoursReal',NxIBStrToFloat(mEd_quantity4.text));mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',NxIBStrToFloat(mEd_Unitprice4.Text));mNewRow.SetFieldValueAsfloat('X_radkova_sleva',msleva);
                                                                                                                                                                                                                                  mNewRow.SetFieldValueAsDateTime('X_konec_prace',mDateto);//mNewRow.Save;mNewRow.free;
                                                                                                                                                                                                                              end;
                                                                                                                                                                                                                              if NxIBStrToFloat(mEd_quantity5.text)>0 then begin
                                                                                                                                                                                                                                  mNewRow := mRows_ML.AddNewObject;mNewRow.SetFieldValueAsInteger('itemtype',0);  mNewRow.SetFieldValueAsInteger('Posindex',i+75);mNewRow.SetFieldValueAsString('WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('X_WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('Text','Práce o víkendu+ svátek');mNewRow.SetFieldValueAsString('Store_id',mStore); mNewRow.SetFieldValueAsString('StoreCard_id','17T0000101');mNewRow.SetFieldValueAsfloat('WorkHoursPlanned',NxIBStrToFloat(mEd_quantity5.text));mNewRow.SetFieldValueAsfloat('WorkHoursReal',NxIBStrToFloat(mEd_quantity5.text));mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',NxIBStrToFloat(mEd_Unitprice5.Text));mNewRow.SetFieldValueAsfloat('X_radkova_sleva',msleva); mNewRow.SetFieldValueAsBoolean('X_Pohotovost',mRow_Pomoc.getFieldValueAsBoolean('X_Pohotovost'));
                                                                                                                                                                                                                                  mNewRow.SetFieldValueAsDateTime('X_konec_prace',mDateto);//mNewRow.Save;mNewRow.free;
                                                                                                                                                                                                                              end;
                                                                                                                                                                                                                end;
                                                                                                                                                                                                                if NxIBStrToFloat(mEd_quantity7.text)>0 then begin
                                                                                                                                                                                                                    mNewRow := mRows_ML.AddNewObject;mNewRow.SetFieldValueAsInteger('itemtype',0); mNewRow.SetFieldValueAsInteger('Posindex',i+80);mNewRow.SetFieldValueAsString('WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('X_WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('Store_id',mStore); mNewRow.SetFieldValueAsString('StoreCard_id','54W0000101');mNewRow.SetFieldValueAsfloat('WorkHoursPlanned',NxIBStrToFloat(mEd_quantity7.text));mNewRow.SetFieldValueAsfloat('WorkHoursReal',NxIBStrToFloat(mEd_quantity7.text));mNewRow.SetFieldValueAsfloat('X_radkova_sleva',0);mNewRow.SetFieldValueAsBoolean('X_Pohotovost',mRow_Pomoc.getFieldValueAsBoolean('X_Pohotovost'));if NxIBStrToFloat(mEd_quantity1.text)=0 then begin mNewRow.SetFieldValueAsString('Text','Doprava km');
                                                                                                                                                                                                                    mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',NxIBStrToFloat(mEd_Unitprice7.Text));end else begin mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',0);mNewRow.SetFieldValueAsString('Text','Doprava km (evidenční)');mNewRow.SetFieldValueAsfloat('ToInvoiceType',1);end;mNewRow.SetFieldValueAsDateTime('X_konec_prace',mDateto);
                                                                                                                                                                                                                    //mNewRow.Save;mNewRow.free;
                                                                                                                                                                                                                end;
                                                                                                                                                                                                                if NxIBStrToFloat(mEd_quantity9.text)>0 then begin
                                                                                                                                                                                                                    mNewRow := mRows_ML.AddNewObject;mNewRow.SetFieldValueAsInteger('Posindex',i+85);mNewRow.SetFieldValueAsInteger('itemtype',4); mNewRow.SetFieldValueAsString('WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('X_WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsBoolean('X_Pohotovost',mRow_Pomoc.getFieldValueAsBoolean('X_Pohotovost'));mNewRow.SetFieldValueAsfloat('Quantity',NxIBStrToFloat(mEd_quantity9.text));mNewRow.SetFieldValueAsfloat('X_radkova_sleva',0);if NxIBStrToFloat(mEd_quantity9.text)=0 then begin mNewRow.SetFieldValueAsString('Text','Výjezd příplatek');mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',NxIBStrToFloat(mEd_Unitprice9.Text));mNewRow.SetFieldValueAsfloat('ToInvoiceType',1);end else begin
                                                                                                                                                                                                                    mNewRow.SetFieldValueAsString('Text','Výjezd příplatek');
                                                                                                                                                                                                                    mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',NxIBStrToFloat(mEd_Unitprice9.Text));mNewRow.SetFieldValueAsfloat('ToInvoiceType',0);end;mNewRow.SetFieldValueAsDateTime('X_konec_prace',mDateto);
                                                                                                                                                                                                                    //mNewRow.Save;mNewRow.free;
                                                                                                                                                                                                                end;
                                                                                                                                                                                                  end else begin
                                                                                                                                                                                                     mB_pokracovat:=false;

                                                                                                                                                                                                        end; // tlačítko ok
                                                                                                                                                                                          finally
                                                                                                                                                                                              mForm1.free;
                                                                                                                                                                                          end;
                                                                                                                                                                           end else begin         // záruka
                                                                                                                                                                           {mNewRow := mRows_ML.AddNewObject;mNewRow.SetFieldValueAsFloat('WorkHoursReal',0);mNewRow.SetFieldValueAsinteger('itemtype',4);mNewRow.SetFieldValueAsString('WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('X_WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsinteger('ToInvoiceType',1);mNewRow.SetFieldValueAsString('Text','Práce - evidenční pro mzdy');mNewRow.SetFieldValueAsFloat('Quantity',mquantity);mNewRow.SetFieldValueAsString('Qunit','hod');mNewRow.SetFieldValueAsFloat('QuantityDelivered',mquantity);mNewRow.SetFieldValueAsBoolean('X_storno',true);mNewRow.SetFieldValueAsFloat('UnitPriceWithVAT',0);mNewRow.SetFieldValueAsFloat('UnitPriceWithoutVAT',0);mNewRow.SetFieldValueAsString('Store_id',mRow_Pomoc.GetFieldValueAsString('Store_id'));mNewRow.SetFieldValueAsString('StoreCard_id',mRow_Pomoc.GetFieldValueAsString('StoreCard_id'));mNewRow.SetFieldValueAsfloat('WorkHoursPlanned',mpocet_km);mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',0);mNewRow.SetFieldValueAsDateTime('X_konec_prace',mDateto);mNewRow.Save;mNewRow.free;


                                                                                                                                                                                                                if (mpocet_km)>0 then begin
                                                                                                                                                                                                                    mNewRow := mRows_ML.AddNewObject;mNewRow.SetFieldValueAsInteger('itemtype',0); mNewRow.SetFieldValueAsString('WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('X_WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('Store_id',mStore);mNewRow.SetFieldValueAsString('StoreCard_id','54W0000101');mNewRow.SetFieldValueAsfloat('WorkHoursPlanned',mpocet_km);mNewRow.SetFieldValueAsfloat('WorkHoursReal',mpocet_km);mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',0);mNewRow.SetFieldValueAsString('Text','Doprava km (evidenční)');mNewRow.SetFieldValueAsfloat('ToInvoiceType',1);mNewRow.SetFieldValueAsDateTime('X_konec_prace',mDateto);mNewRow.free;
                                                                                                                                                                                                                end; }
                                                                                                                                                                           end;                   // záruka


                                                                                                                                                                      end;   // zadání odpracované doby



                                                                                                                                            end;  // end for list

                                                                                                                                        finally
                                                                                                                                            mList_pomoc.free;
                                                                                                                                        end;
                                                                                                                             end;   //paušál
                                                                                                                       if mB_pokracovat then begin
                                                                                                                          mBO_ML.SetFieldValueAsstring('X_State','3Q22000101');
                                                                                                                          mBO_ML.SetFieldValueAsinteger('AssemblyState',1);
                                                                                                                          mi:=mbo.ObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' +QuotedStr(mBO_ML.getFieldValueAsString('X_state.X_field1'))+ ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                                                                                                       end;
                                                                                                                       end ;  // není fakturován

                                                                                                        end; // datum pro fakturaci

                                                                                       end;   // není zadán technik


                                                                                       // zadání materiálu
                                                                                      // if (mIDs_Storecard.count=0) and mResult_mat then begin
                                                                                      //            mResult_mat:=GetCheck(Sender,xSite,'Chcete zadat materiál','Zadat materiál','Pokračovat') ;
                                                                                      //            if mResult_mat then begin
                                                                                      //
                                                                                      //            mBO_ML.SetFieldValueAsstring('X_State','45W1000101');
                                                                                      //            mBO_ML.SetFieldValueAsinteger('AssemblyState',1);
                                                                                      //            end;
                                                                                      // end;


                                                                                   mID_ML:=mBO_ML.oid;
                                                                                   if mB_pokracovat then begin
                                                                                       mBO_ML.Save;
                                                                                   end else begin
                                                                                       NxShowSimpleMessage('Operace byla přerušena',xSite);
                                                                                   end;
                                                                                   //mBO_ML.Refresh;
                                                                                   finally
                                                                                      mBO_ML.free;
                                                                                   end;
                                                                               end;

                                                                     finally
                                                                              mIDs_ML.free;
                                                                     end;
                                                      finally
                                                         mbo_SL.free;
                                                      end;
                                        end;          // pro více SP
                                    finally
                                       mIDs_Storecard.Free;
                                       mIDs_SP.free;
                                       mIDs_WorkerRole.Free;
                                    end;

                                    //mBO_ML.Load(mid_ml,nil);
                                    //try
                                    //    mbo_ml.Save;
                                    //    mbo_ml.Refresh;
                                    //    mdbgrid.Refresh;
                                    //xsite.RefreshData;
                                    //xsite.ActiveDataSet.seekid(mID_ML);
                                    //xsite.ActiveDataSet.RefreshAndRestoreLastSelectedItem;
                                    //finally
                                    //
                                    //end;



        end;
  {      if index=1 then begin
                mD_SL_start:= date ;
                mD_SL_End:=mD_SL_start+1;
                try
                mBONew_SL:=xsite.BaseObjectSpace.CreateObject('BCHF52UGXCO4H5MIAQVY5P3ZOC');
                      mBONew_SL.New;
                      mBONew_SL.Prefill;
                      mboNew_SL.SetFieldValueAsDateTime('DocDate$DATE',mD_SL_start);
                      mboNew_SL.SetFieldValueAsDateTime('PromisedDeadLine$DATE', mD_SL_End);
                      mboNew_SL.SetFieldValueAsstring('Division_ID',mboNew_SL.getFieldValueAsstring('CreatedBy_ID.X_division_ID'));


                      xSite.ShowDynFormWithNewDocument('NHT5Z3GSFFQ4F024JRFLUNOS30', xSite.SiteContext, mBONew_SL);
                      mID_SL:=mBONew_SL.oid;

                      finally
                         mBONew_SL.free;
                      end;


        end;  }


            if index=1 then begin
                    mD_SL_start:= GetDate(Sender,xSite) ;
                    mD_SL_End:=mD_SL_start+1;
                //  montážní list
                      mbo_SL:=mBO.ObjectSpace.CreateObject('BCHF52UGXCO4H5MIAQVY5P3ZOC');
                           try
                                mbo_sl.Load(mbo.GetFieldValueAsString('ServiceDocument_ID'),nil) ;  // použití již existujícího SL

                                     if nxisblank(mid_workSpace) then begin
                                            mr:=TStringList.Create;
                                            try
                                               mbo.objectspace.SQLSelect('select id from ServiceWorkSpaces where code=' + QuotedStr(mbo.GetFieldValueAsString('Servicedocument_ID.Division_ID.code')),mr);
                                                        if mr.count>0 then mid_workSpace:=mr.Strings[0];
                                            finally
                                                mr.free;
                                            end;
                                         end;

                                         if nxisblank(mid_workerRole) then begin
                                            mr:=TStringList.Create;
                                            try
                                              mbo.ObjectSpace.SQLSelect('select id from SecurityRoles where ShortName=' + QuotedStr(mbo.GetFieldValueAsString('Servicedocument_ID.Division_ID.code')),mr);
                                              if mr.count>0 then begin
                                                  mid_workerRole:=mr.Strings[0]
                                              end;
                                            finally
                                                mr.free;
                                            end;
                                          end;
                                          // založení nového ML


                                          mID_ML:=Novy_ML(mBO_SL,mid_workSpace,mid_workerRole,mD_SL_start,mD_SL_End);
                               finally
                                  mbo_sl.free;
                               end;



    end;






                            finally
                                mr.free;
                                mbo.free;
                            end;
                        end;
               finally
                 mbo_CRM_activities.free;
               end;
            end;
  finally
    l.free;
  end;
end;

procedure NEWSLExecuteItem11(Sender:Tcomponent; Index: integer);
var
mDamageDescription:string;
mForm: TForm;
i:integer;
mr:tstringlist;
mresult:boolean;
mdate:date;
mDateinput,mResult_mat:boolean;
mBO_MLNew:TNxCustomBusinessObject;
mrta:tstringlist;
mOLE_DV, mRoll_DV, mOResult_DV,mOLE_DQ, mRoll_DQ, mOResult_DQ,mOLE_WR, mRoll_WR, mOResult_WR: Variant;
mD_ML_start,mD_ML_End,mD_SL_start,mD_SL_End,mD_CRM_start,mD_CRM_End,mF_pausal_prace,mF_pausal_Vyjezd,mF_prace,mF_km,mFSazba_hod_den,mFDoprava_km,mF_doprava_pausal,mFSazba_hod:double;
   mF_doba,mF_Prace_od,mF_Prace_do,mF_Prac_doba_zac,mF_Prac_doba_kon:double;        // jen časová část
   mFSazba_Prace_pausal,mFSazba_Prace,mFSazba_Mimo,mFSazba_Vikend,mFSazba_Svatek,mFSazba_Doprava_km,mFSazba_Doprava_pausal,mFPriplatek3H:double;
   mF_Mnozstvi_Prace_pausal,F_Mnozstvi_Prace,mF_Mnozstvi_mimo,mF_Mnozstvi_vikend,mF_Mnozstvi_svatek,mF_Mnozstvi_Doprava_km,mF_Mnozstvi_Doprava_pausal:double;
  mstore_id:string;
   mDateFrom,mDateto,mDatezac,mDatekon,mPRzac,mPRkon:Double;
  msleva:double;
 mF_svatek,mF_vikend,mF_mimo,mFS_svatek,mFS_vikend,mFS_mimo,mFS_prace:double;
  mrole_id:string;
 mDnu:integer;
 mOpakovani:integer;
 mBO_ML_ROW:TNxCustomBusinessObject;
 mStore:string;
  mForm1 : TForm;
  mBtn : TButton;
  mKonecDAte:TDateTimeEdit;
  mKonecTime:TTimeEdit;
  mL_Technik,mL_Technik1,mL1_C_Protokol,mL1_pohotovost,mL1_C_Chyby,mL_technik_value,mL_technik1_value:TLabel;
  mL_operation,mL1_operation:TLabel ;
  mEd1_pohotovost:TCheckBox;
  mEd1_C_chyby,mEd1_C_protokol:tedit;
  mEd1_quantity,mEd_quantity,mEd_Unitprice,mEd_quantity1,mEd_Unitprice1,mEd_quantity2,mEd_Unitprice2,mEd_quantity3,mEd_Unitprice3,mEd_quantity4,mEd_Unitprice4,mEd_quantity5,mEd_Unitprice5,mEd_quantity6,mEd_Unitprice6,mEd_quantity7,mEd_Unitprice7,mEd_quantity8,mEd_Unitprice8,mEd_quantity9,mEd_Unitprice9,mEd_quantity10,mEd_Unitprice10,mED1_P_Cyklu:TEdit;
  mquantity:double;
  mWorkHoursReal:Double;
  mkorekce:Double;
  mpocet_km:Double;
  mLabel1,mLabel2,mLblm,mLbl1,mLbl2,mLbl0,mLbl3,mLabel3 ,mL1_P_Cyklu: TLabel;
  mEdtDAte:TDateEdit;
    mEdtDAte1:TTimeEdit;
    mID_WorkerRole,mid_workSpace:string;
    mEdtSrc:TEdit;
    mBO_BusProject:TNxCustomBusinessObject;
    mI_WorkerRole:integer;
    ID_result,mID_StoreCard:string;
    mkoeficient,mkoeficient_korekce:Double;
    mrGT:TStringList;
   mRows_MLNew:TNxCustomBusinessMonikerCollection;
   mIDs_DQ,mIDs_DV:tstringlist;
mRow,mNewRow, mbo1,mbo_ml_target_row,mOrderRow,mNewRows: TNxCustomBusinessObject;
mMon : TNxCustomBusinessMonikerCollection;
mWorkerRole_ID:string;
mPosIndex,mpocet,mpocet1,mI_MLRow:Integer;
mRow_Pomoc:TNxCustomBusinessObject;
mList_pomoc:tstringlist;
mi,i01,ii,mhour,mmin,msek,mmsek:integer;
mpausal,mpausal_oprava:double;
mCRMresult:Boolean;
mID_DV,mID_DQ:string;
cbDocqueues,cbDivisions: TComboBox;//TRollComboEdit;
mcode:string;
mxpomoc:double;
muser,mbo:TNxCustomBusinessObject;
mServiceType_ID:string;
mB_pokracovat:boolean;
xsite:TSiteForm;
l:TStringList;
begin
   mB_pokracovat:=false;
//
      mID_WorkerRole:='';
   mID_WorkerRole:='';
   mID_StoreCard:='';
   mid_workSpace:='';
   mD_SL_start:= (date) + EncodeTime(7,0,0,0);
   mD_SL_End:=(date) + encodetime(15,30,0,0);

    L := TStringList.Create();
        try
            xSite := TComponent(Sender).Site;
            //xDynSite:=TComponent(Sender).DynSite;
            Sender.Site.List.GetSelectedID(L);
            if Length(trim(l.Text))=10 then begin
                mbo_CRM_activities:=sender.site.BaseObjectSpace.CreateObject('AVV1JYV5AVNOZHQCK0D4CJFUCS');
                Try
                    mid:=trim(l.Text);
                    mbo_CRM_activities.load(mid,nil);

                        if not NxIsEmptyOID(mbo_CRM_activities.GetFieldValueAsString('X_parent_head')) then begin
                              mbo:=sender.site.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                            try
                              mid:='';
                              mr:=tstringlist.create;
                                  //try
                                  //   mbo_CRM_activities.ObjectSpace.SQLSelect('select SA.id from ServiceAssemblyForms2 SA2 left join ServiceAssemblyForms SA on SA2.parent_id=SA.id where sa2.id=' +quotedstr(mbo_CRM_activities.GetFieldValueAsString('X_parent_ID')) + ' group by SA.id',mr);
                                  //   NxShowSimpleMessage(inttostr(mr.count),nil);
                                  //   if mr.count=1 then begin
                                          mbo.load(mbo_CRM_activities.GetFieldValueAsString('X_parent_head'),nil);

                                              NxShowSimpleMessage('ML' + mbo_CRM_activities.GetFieldValueAsString('X_parent_head'),nil);






                                                          if index=0 then begin
                                                                    if (xsite.SiteContext.GetCompanyCache.GetLoginID='1410000101') then begin
                                                                        mD_SL_start:= GetDate(Sender,xSite) ;
                                                                        mD_SL_start:= trunc(mD_SL_start) + EncodeTime(7,0,0,0);
                                                                        mD_SL_End:=trunc(mD_SL_start) + encodetime(15,30,0,0);
                                                                    end;


                                                                                        mForm := TForm.Create(xsite);
                                                                                        mForm.Caption := 'Zadejte údaje SL';
                                                                                        mForm.FormStyle := fsStayOnTop;
                                                                                        mForm.BorderStyle := bsDialog;
                                                                                        mForm.Width := 550;
                                                                                        mForm.Height := 170;
                                                                                        mForm.Scaled := False;
                                                                                        mform.Position := poScreenCenter;

                                                                                        mLabel3 := TLabel.Create(mForm);
                                                                                        mLabel3.Parent := mForm;
                                                                                        mLabel3.Caption := 'Typ servisu :';
                                                                                        mLabel3.Top := 10;
                                                                                        mLabel3.Left := 10;
                                                                                        mLabel3.Height := 13;


                                                                                          cbDocqueues := TComboBox.Create(mForm);
                                                                                          cbDocqueues.Left := 100;
                                                                                          cbDocqueues.Top := 10;
                                                                                          cbDocqueues.Width := 200;
                                                                                          cbDocqueues.Name := 'cbDocqueue';
                                                                                          cbDocqueues.Text := '';
                                                                                          mForm.InsertControl(cbDocqueues);
                                                                                          iFillDocqueue_code(xsite.BaseObjectSpace,cbDocqueues.Items,'SL','SL');
                                                                                           if cbDocqueues.Items.Count >= 0 then begin
                                                                                            cbDocqueues.ItemIndex := 0;
                                                                                          end;

                                                                                          if (xSite.CompanyCache.GetUserID='1810000101') or (xSite.CompanyCache.GetUserID='SUPER00000') then begin

                                                                                                      mLabel2 := TLabel.Create(mForm);
                                                                                                    mLabel2.Parent := mForm;
                                                                                                    mLabel2.Caption := 'Středisko :';
                                                                                                    mLabel2.Top := 40;
                                                                                                    mLabel2.Left := 10;
                                                                                                    mLabel2.Height := 13;

                                                                                                      cbDIvisions := TComboBox.Create(mForm);
                                                                                                      cbDIvisions.Left := 100;
                                                                                                      cbDIvisions.Top := 40;
                                                                                                      cbDIvisions.Width := 200;
                                                                                                      cbDIvisions.Name := 'cbDivision';
                                                                                                      cbDIvisions.Text := '';
                                                                                                      mForm.InsertControl(cbDivisions);
                                                                                                         iFillDivision(xsite.BaseObjectSpace, cbDivisions.Items,'Servisní středisko');
                                                                                                       if cbDIvisions.Items.Count >= 0 then begin
                                                                                                        cbDivisions.ItemIndex := 0;
                                                                                                      end;








                                                                                             end;

                                                                                             mL_operation:= TLabel.Create(mForm);
                                                                                                      mL_operation.Parent := mForm;
                                                                                                      mL_operation.Caption := 'Poškození :';
                                                                                                      mL_operation.Top := 70;
                                                                                                      mL_operation.Left := 10;
                                                                                                      mL_operation.Height := 150;
                                                                                                      mL_operation.Width := 80;
                                                                                                      mEd_quantity := TEdit.Create(mForm);
                                                                                                      mEd_quantity.Left := 100;
                                                                                                      mEd_quantity.Top := 60;
                                                                                                      mEd_quantity.Width := 430;
                                                                                                      mEd_quantity.Name := 'mEd_quantity';
                                                                                                      mEd_quantity.Text:='';
                                                                                                      mForm.InsertControl(mEd_quantity);

                                                                                      mBtn := TButton.Create(mForm);
                                                                                      mBtn.Width := 75;
                                                                                      mBtn.Height := 25;
                                                                                      mBtn.Caption := 'OK';
                                                                                      mBtn.ModalResult := mrOk;
                                                                                      mBtn.Cancel := False;
                                                                                      mBtn.Default := True;
                                                                                      mBtn.Left :=  mForm.Width - 2*(mBtn.Width+2) - 20;
                                                                                      mBtn.Top := mForm.Height - mBtn.Height - 40;
                                                                                      mBtn.Name := 'btnOK';
                                                                                      mForm.InsertControl(mBtn);

                                                                                      mBtn := TButton.Create(mForm);
                                                                                      mBtn.Width := 75;
                                                                                      mBtn.Height := 25;
                                                                                      mBtn.Caption := 'Storno';
                                                                                      mBtn.ModalResult := mrCancel;
                                                                                      mBtn.Cancel := True;
                                                                                      mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;;
                                                                                      mBtn.Top := mForm.Height - mBtn.Height - 40;
                                                                                      mBtn.Name := 'btnCancel';
                                                                                      mForm.InsertControl(mBtn);

                                                                                      try
                                                                                          if mForm.ShowModal(xSite) = mrOK then begin
                                                                                               mB_pokracovat:=true;
                                                                                               mDamageDescription:=mEd_quantity.Text;
                                                                                               mID_DQ:=iGetIDByName(xsite.BaseObjectSpace,'Docqueues', ReplaceStr(cbDocqueues.Text,'"','')) ;
                                                                                              //NxShowSimpleMessage( mID_DQ,nil);

                                                                                              if xsite.CompanyCache.GetUserID='1810000101' then begin
                                                                                                  mID_DV:=iGetIDByName(xsite.BaseObjectSpace,'Divisions', ReplaceStr(cbDivisions.Text,'"','')) ;
                                                                                                  mcode:=iGetcodeByName(xsite.BaseObjectSpace,'Divisions', ReplaceStr(cbDivisions.Text,'"','')) ;
                                                                                              end else begin
                                                                                                  mUser := xsite.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');            // přihlášený uživatel
                                                                                                        try
                                                                                                            mUser.Load(xsite.CompanyCache.GetUserID, nil);
                                                                                                                  mID_DV:= mUser.GetFieldValueAsString('X_division_ID');
                                                                                                                  mcode:=mUser.GetFieldValueAsString('X_division_ID.code');

                                                                                                        finally
                                                                                                          mUser.Free;
                                                                                                        end;
                                                                                              end;
                                                                                              //NxShowSimpleMessage( mID_DV,nil);
                                                                                         end;
                                                                                         finally

                                                                                         end    ;
                                                                                         mform.free;
                                                                                        if not mB_pokracovat  then exit;


                                                                        mOLE_SP:= GetAbraOLEApplication;
                                                                        mOResult_SP:= mOLE_SP.CreateStrings;
                                                                        mRoll_SP:= mOLE_SP.GetRoll('5315B3YAPMNOB0FIRUCLXSJ52O', 0);   // sp
                                                                                          if not mRoll_SP.MultiSelectDialog(True, mOResult_SP) then Exit;
                                                                                          mIDs_SP:= TStringList.Create;
                                                                                          mIDs_WorkerRole:=TStringList.create;
                                                                                          mIDs_Storecard:=TStringList.create;
                                                                                          try
                                                                                          mIDs_SP.Text:= mOResult_SP.Text;
                                                                                              mdateinput:=true;
                                                                                              mResult_mat:=true;
                                                                                              mOLE_WorkerRole:= GetAbraOLEApplication;
                                                                                                    mOResult_WorkerRole:= mOLE_WorkerRole.CreateStrings;
                                                                                                            mRoll_WorkerRole:= mOLE_WorkerRole.GetRoll('0FKKTBSSQKB4B3RLYBSJFFAFUW', 0);   // sp
                                                                                                             if mRoll_WorkerRole.MultiSelectDialog(True, mOResult_WorkerRole) then mIDs_WorkerRole.Text:= mOResult_WorkerRole.Text;

                                                                                              mIDs_SP.Text:= mOResult_SP.Text;



                                                                                             // if nxisblank(mid_workSpace) then begin
                                                                                                  mr:=TStringList.Create;
                                                                                                  try
                                                                                                     xsite.BaseObjectSpace.SQLSelect('select id from ServiceWorkSpaces where code=' + QuotedStr(mcode),mr);
                                                                                                              if mr.count>0 then mid_workSpace:=mr.Strings[0];
                                                                                                  finally
                                                                                                      mr.free;
                                                                                                  end;
                                                                                              // end;

                                                                                               //if nxisblank(mid_workerRole) then begin
                                                                                                  if  mIDs_WorkerRole.count>0 then begin
                                                                                                      mid_workerRole:=mIDs_WorkerRole.Strings[0];
                                                                                                  end else begin
                                                                                                        mr:=TStringList.Create;
                                                                                                        try
                                                                                                          xsite.BaseObjectSpace.SQLSelect('select id from SecurityRoles where ShortName=' + QuotedStr(mcode),mr);
                                                                                                          if mr.count>0 then begin
                                                                                                              mid_workerRole:=mr.Strings[0] ;
                                                                                                          end;
                                                                                                        finally
                                                                                                            mr.free;
                                                                                                        end;
                                                                                                  end;
                                                                                                //end;





                                                                                              for mI_SP:=0 to mIDs_SP.count-1 do begin                  // cyklus SP

                                                                                                            mID_SP:=mIDs_SP.Strings(mI_SP);
                                                                                                            // vytvoření nového servisního listu
                                                                                                            mServiceType_ID:='2300000101';
                                                                                                            mID_SL:=Novy_SL(xsite,mID_SP,mD_SL_start,mD_SL_end,mID_DQ,mID_DV,mDamageDescription,mServiceType_ID);

                                                                                                            mbo_SL:=xsite.BaseObjectSpace.CreateObject('BCHF52UGXCO4H5MIAQVY5P3ZOC');
                                                                                                            try
                                                                                                                         mbo_sl.Load(mID_SL,nil) ;  // použití již existujícího SL
                                                                                                                           mIDs_ML:=tstringlist.create;
                                                                                                                           try
                                                                                                                                    xsite.BaseObjectSpace.SQLSelect('select id from ServiceAssemblyForms where ServiceDocument_ID='+quotedstr(mID_SL),mIDs_ML);
                                                                                                                                    if mIDs_ML.count>0 then begin
                                                                                                                                         mID_ML:=mIDs_ML.Strings[0];           // použití již existujícího ML
                                                                                                                                    end else begin

                                                                                                                                          // založení nového ML
                                                                                                                                          //mID_ML:=Novy_ML(mBO_SL,mid_workSpace,mid_workerRole,mD_SL_start,mD_SL_end);

                                                                                                                                          mBO_ML:=xsite.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                                                                                                                                          try
                                                                                                                                             mBO_ML.new;
                                                                                                                                             mBO_ML.Prefill;
                                                                                                                                             mBO_ML.SetFieldValueAsDateTime('StartDate$DATE',mD_SL_start);
                                                                                                                                             mBO_ML.SetFieldValueAsDateTime('EndDate$DATE',mD_SL_End);
                                                                                                                                             mBO_ML.SetFieldValueAsDateTime('X_CreatedDate$DATE',date);
                                                                                                                                             mBO_ML.SetFieldValueAsString('ServiceDocument_ID',mID_SL);
                                                                                                                                             mBO_ML.SetFieldValueAsstring('X_State','35W1000101');
                                                                                                                                             mBO_ML.SetFieldValueAsstring('X_ServicedObject_ID',mBO_SL.GetFieldValueAsString('ServicedObject_ID'));
                                                                                                                                             mBO_ML.SetFieldValueAsstring('X_id_zakaznika_id',mBO_SL.GetFieldValueAsString('X_id_zakaznika_id'));
                                                                                                                                             mBO_ML.SetFieldValueAsInteger('AssemblyState',0);

                                                                                                                                             mBO_ML.SetFieldValueAsString('ServiceWorkSpace_ID',mid_workSpace);
                                                                                                                                             mBO_ML.SetFieldValueAsString('ResponsibleRole_ID',mid_workerRole);
                                                                                                                                            mBO_ML.SetFieldValueAsstring('X_State','3XQ1000101');

                                                                                                                                            mBO_ML.SetFieldValueAsinteger('AssemblyState',0);

                                                                                                                                            mBO_ML.SetFieldValueAsstring('X_Docqueue_ID',mBO_SL.GetFieldValueAsString('Docqueue_ID'));
                                                                                                                                            mBO_ML.SetFieldValueAsInteger('X_Ordnumber',mBO_SL.GetFieldValueAsInteger('Ordnumber'));
                                                                                                                                            mBO_ML.SetFieldValueAsstring('X_Period_ID',mBO_SL.GetFieldValueAsString('Period_ID'));
                                                                                                                                            // zadání technika
                                                                                                                                             if mIDs_WorkerRole.Count>0 then begin

                                                                                                                                                          mF_prace_Od:=mD_SL_start;
                                                                                                                                                          mF_prace_Do:=mD_SL_End;
                                                                                                                                                          mF_doba:= 1 ;
                                                                                                                                                          if mDateinput then begin         // opakující se doba
                                                                                                                                                                      mDateinput:=false;
                                                                                                                                                                      mForm := TForm.Create(xSite);
                                                                                                                                                                      mForm.Caption := 'Zadejte údaje';mForm.FormStyle := fsStayOnTop;mForm.BorderStyle := bsDialog;mForm.Width := 550;mForm.Scaled := False;mform.Position := poScreenCenter;
                                                                                                                                                                      mLbl2 := TLabel.Create(mForm);  mLbl2.Caption := 'Konec :';mLbl2.Left := 10;mLbl2.Top := 40;mLbl2.Name := 'lbldate';mForm.InsertControl(mLbl2);mEdtDAte := TDateEdit.Create(mForm);mEdtDAte.Left := 100;mEdtDAte.Top := 40;mEdtDAte.Width := 100;mEdtDAte.Name := 'edtDate';mEdtDAte.Date:=trunc(mD_SL_End);mForm.InsertControl(mEdtDAte);
                                                                                                                                                                      mEdtDAte1 := TTimeEdit.Create(mForm);mEdtDAte1.Left := 210;mEdtDAte1.Top := 40;mEdtDAte1.Width := 100;mEdtDAte1.Name := 'edtDate1';mEdtDAte1.Time:=frac(mD_SL_End);mForm.InsertControl(mEdtDAte1);
                                                                                                                                                                      mLbl3 := TLabel.Create(mForm); mLbl3.Caption := 'Doba :';mLbl3.Left := 10;mLbl3.Top := 70;mLbl3.Name := 'lblDoba';mForm.InsertControl(mLbl3);mEdtSrc := TEdit.Create(mForm);mEdtSrc.Left := 100;mEdtSrc.Top := 70;mEdtSrc.Width := 100;mEdtSrc.Name := 'edtdoba';mEdtSrc.Text:=NxFloatToIBStr(mf_doba);mForm.InsertControl(mEdtSrc);
                                                                                                                                                                      mBtn := TButton.Create(mForm);mBtn.Width := 75; mBtn.Height := 25;mBtn.Caption := 'OK';mBtn.ModalResult := mrOk;mBtn.Cancel := False;mBtn.Default := True;mBtn.Left :=  mForm.Width - 2*(mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 40;mBtn.Name := 'btnOK';mForm.InsertControl(mBtn);
                                                                                                                                                                      mBtn := TButton.Create(mForm);mBtn.Width := 75;mBtn.Height := 25;mBtn.Caption := 'Storno';mBtn.ModalResult := mrCancel;mBtn.Cancel := True;mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 40;mBtn.Name := 'btnCancel';mForm.InsertControl(mBtn);
                                                                                                                                                                      if mForm.ShowModal(xSite) = mrOK then begin
                                                                                                                                                                                      mB_pokracovat:=true;
                                                                                                                                                                                      mF_doba:=NxIBStrToFloat(mEdtSrc.Text);
                                                                                                                                                                                      mD_ML_End:=mEdtDAte.Date+ mEdtDAte1.Time;
                                                                                                                                                                                      /// *************************************************





                                                                                                                                                                                      mD_ML_start:=mD_ML_End - EncodeTime(trunc(mF_doba),trunc(frac(trunc(mF_doba)*60)),0,0);
                                                                                                                                                                                      mBO_ML.SetFieldValueAsDateTime('StartDate$DATE',mD_ML_start);
                                                                                                                                                                                      mBO_ML.SetFieldValueAsDateTime('EndDate$DATE',mD_ML_End);
                                                                                                                                                                                      if  not NxIsEmptyOID(mBO_ML.GetFieldValueAsString('ServiceDocument_ID.BusProject_ID')) then begin
                                                                                                                                                                                              mF_pausal_prace:=0;mF_pausal_Vyjezd:=0;mFSazba_mimo:=0;mFSazba_vikend:=0;mFSazba_svatek:=0;mFDoprava_km:=0;mF_Prac_doba_zac:=0;mF_Prac_doba_kon:=0;
                                                                                                                                                                                              // ceny z projektu
                                                                                                                                                                                              try
                                                                                                                                                                                                      mBO_BusProject:=xsite.BaseObjectSpace.CreateObject('QOKMKIQUJF34L3DUICTBWEDQJC');
                                                                                                                                                                                                      if mBO_ML.GetFieldValueAsInteger('ServiceDocument_ID.ServicedObject_ID.X_Fakturacni_oblast')=0 then begin
                                                                                                                                                                                                          NxShowSimpleMessage('Pozor, předmět není přiřazen do fakturační oblasti, ceny nemusí odpovídat, bude použit formát pro Čechy',nil);
                                                                                                                                                                                                          mBO_BusProject.load('2130000101',nil);                                                                                    // max cena=čechy
                                                                                                                                                                                                      end;
                                                                                                                                                                                                      if mBO_ML.GetFieldValueAsInteger('ServiceDocument_ID.ServicedObject_ID.X_Fakturacni_oblast')=1 then begin     // čechy
                                                                                                                                                                                                            mBO_BusProject.load('2130000101',nil);
                                                                                                                                                                                                      end;
                                                                                                                                                                                                      if mBO_ML.GetFieldValueAsInteger('ServiceDocument_ID.ServicedObject_ID.X_Fakturacni_oblast')=2 then begin      // morava
                                                                                                                                                                                                            mBO_BusProject.load('3130000101',nil);
                                                                                                                                                                                                      end;
                                                                                                                                                                                                      mFSazba_prace:=mBO_BusProject.GetFieldValueAsFloat('X_Sazba_bezna');
                                                                                                                                                                                                      mF_pausal_prace:=mBO_BusProject.GetFieldValueAsFloat('X_Prevence_pausal');
                                                                                                                                                                                                      mF_pausal_Vyjezd:=mBO_BusProject.GetFieldValueAsFloat('X_Najezdni_pausal');
                                                                                                                                                                                                      if mF_pausal_Vyjezd=0 then  mFDoprava_km:=mBO_BusProject.GetFieldValueAsFloat('X_Sazba_bezna');
                                                                                                                                                                                              finally
                                                                                                                                                                                              mBO_BusProject.free;
                                                                                                                                                                                              end;

                                                                                                                                                                                      end;
                                                                                                                                                                     end else begin
                                                                                                                                                                     mB_pokracovat:=false;
                                                                                                                                                                     end;
                                                                                                                                                           end;   //opakující se doba;
                                                                                                                                                           msleva:= mBO_ML.GetFieldValueAsInteger('ServiceDocument_ID.X_Discount_sluzby');
                                                                                                                                                           {  try
                                                                                                                                                                mrgt:=tstringlist.create;
                                                                                                                                                                xsite.BaseObjectSpace.SQLSelect(format('select count(id) from ServiceAssemblyForms2 where parent_ID=%s and (itemtype=4 and text=%s) or (itemtype=0 and Storecard_ID=%s) ',[quotedstr(mbo_ml.OID),quotedstr('Práce - evidenční pro mzdy'),quotedstr('92E0000101')]),mrgt);
                                                                                                                                                                if strtoint(mrgt.Strings[0])>0 then begin
                                                                                                                                                                   mkoeficient:=trunc(100/(strtoint(mrgt.Strings[0])+1));
                                                                                                                                                                   mkoeficient_korekce:=100-((strtoint(mrgt.Strings[0])+1)*mkoeficient);
                                                                                                                                                                end else begin
                                                                                                                                                                   mkoeficient:=100;
                                                                                                                                                                   mkoeficient_korekce:=0;
                                                                                                                                                                end;
                                                                                                                                                             finally
                                                                                                                                                                mr.free;
                                                                                                                                                             end; }
                                                                                                                                                             mRows_ML := mBO_ML.GetCollectionMonikerForFieldCode(mBO_ML.GetFieldCode('Rows'));
                                                                                                                                                             if (mIDs_workerRole.count>0) and (mB_pokracovat) then begin
                                                                                                                                                                  for mI_WorkerRole:=0 to mIDs_workerRole.count-1 do begin
                                                                                                                                                                        mID_WorkerRole:=mIDs_WorkerRole.Strings[mI_WorkerRole];
                                                                                                                                                                       mr:=tstringlist.create;
                                                                                                                                                                                try
                                                                                                                                                                                    xsite.BaseObjectSpace.SQLSelect('select min(SheduledStart$Date) from CRMActivities where SolverRole_ID='+ quotedstr(mID_WorkerRole) + ' and SheduledStart$Date>' + inttostr(trunc(mD_ML_End)) + ' and SheduledStart$Date<=' + inttostr((trunc(mD_ML_End)+1)) , mr);
                                                                                                                                                                                    if mr.count>0 then begin
                                                                                                                                                                                         if frac(NxIBStrToFloat(mr.Strings[0]))<EncodeTime(5,0,0,0) then begin

                                                                                                                                                                                         end else begin
                                                                                                                                                                                            mD_ML_End:=trunc(mD_ML_End) + frac(NxIBStrToFloat(mr.Strings[0]));
                                                                                                                                                                                         end;
                                                                                                                                                                                    end;
                                                                                                                                                                                finally
                                                                                                                                                                                   mr.free;
                                                                                                                                                                                end;


                                                                                                                                                                             mBO_ML_ROW := mRows_ml.AddNewObject;
                                                                                                                                                                                            mBO_ML_ROW.SetFieldValueAsinteger('itemtype',0);          // 0 práce , 1 skladová karta
                                                                                                                                                                                            //mOrderRow.SetFieldValueAsString('serviceworkcategory_id','');
                                                                                                                                                                                            mBO_ML_ROW.SetFieldValueAsString('WorkerRole_ID',mID_WorkerRole);
                                                                                                                                                                                            mBO_ML_ROW.SetFieldValueAsString('X_WorkerRole_ID',mID_WorkerRole);
                                                                                                                                                                                            mBO_ML_ROW.SetFieldValueAsString('X_Osoba',mBO_ML_ROW.GetFieldValueAsstring('WorkerRole_ID.Name'));
                                                                                                                                                                                            mBO_ML_ROW.SetFieldValueAsString('Text','Práce');
                                                                                                                                                                                            mBO_ML_ROW.SetFieldValueAsString('Store_id','2000000101');
                                                                                                                                                                                            mBO_ML_ROW.SetFieldValueAsString('StoreCard_id','2ZI1000101');
                                                                                                                                                                                            mBO_ML_ROW.SetFieldValueAsfloat('WorkHoursPlanned',mF_doba);
                                                                                                                                                                                            mBO_ML_ROW.SetFieldValueAsfloat('X_konec_prace',mD_ML_End);
                                                                                                                                                                                            mBO_ML_ROW.SetFieldValueAsfloat('X_Radkova_sleva',msleva);
                                                                                                                                                                                            mdateto:=mD_ML_End;
                                                                                                                                                                                                   mD_ML_start:=mD_ML_End - EncodeTime(trunc(mF_doba),trunc(frac(trunc(mF_doba)*60)),0,0);

                                                                                                                                                                                                   mCRMresult:=NxCRM(0,mBO_ML_ROW,mID_WorkerRole,mD_ML_start,mD_ML_End,'','');
                                                                                                                                                                                                   if not mCRMresult then NxShowSimpleMessage('Při vytváření aktivity došlo k chybě',nil);
                                                                                                                                                                                            mBO_ML_ROW.SetFieldValueAsfloat('X_Koeficient',100/mIDs_workerRole.count);
                                                                                                                                                                                            mkoeficient_korekce:=0;
                                                                                                                                                                                            if mFSazba_hod<>0 then mBO_ML_ROW.SetFieldValueAsfloat('UnitPriceWithoutVAT',mFSazba_hod);
                                                                                                                                                                                            mBO_ML_ROW.SetFieldValueAsinteger('ToInvoiceType',0);
                                                                                                                                                                        if mI_WorkerRole=0 then mkoeficient_korekce:=0
                                                                                                                                                                  end;
                                                                                                                                                             mBO_ML.SetFieldValueAsstring('X_State','4U12000101');
                                                                                                                                                             mBO_ML.SetFieldValueAsinteger('AssemblyState',1);
                                                                                                                                                             mBO_ML.SetFieldValueAsstring('X_Monter1_ID',mID_WorkerRole);
                                                                                                                                                      mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' +QuotedStr(mBO_ML.getFieldValueAsString('X_state.X_field1'))+ ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                                                                                                                                             end;


                                                                                                                                                                // rozpočet fakturace
                                                                                                                                                             if (trunc(mBO_ml.GetFieldValueAsDateTime('EndDate$DATE'))<date) and (mB_pokracovat) then begin
                                                                                                                                                                    if mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='1A20000101' then mBO_ML.SetFieldValueAsString('X_protokol_prefix','S');
                                                                                                                                                                    if mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='5B20000101' then mBO_ML.SetFieldValueAsString('X_protokol_prefix','S');
                                                                                                                                                                    if mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='4B20000101' then mBO_ML.SetFieldValueAsString('X_protokol_prefix','P');
                                                                                                                                                                    if mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='6B20000101' then mBO_ML.SetFieldValueAsString('X_protokol_prefix','P');
                                                                                                                                                                    if mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='7B20000101' then mBO_ML.SetFieldValueAsString('X_protokol_prefix','B');
                                                                                                                                                                    if mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='8B20000101' then mBO_ML.SetFieldValueAsString('X_protokol_prefix','B');
                                                                                                                                                                    if mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='9B20000101' then mBO_ML.SetFieldValueAsString('X_protokol_prefix','F');
                                                                                                                                                                    if mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='AB20000101' then mBO_ML.SetFieldValueAsString('X_protokol_prefix','F');
                                                                                                                                                                     if true then begin  // není fakturován
                                                                                                                                                                              mF_pausal_prace:=0;mF_pausal_Vyjezd:=0;mFSazba_prace:=0;mFSazba_mimo:=0;mFSazba_vikend:=0;mFSazba_svatek:=0;mFDoprava_km:=0;mFPriplatek3H:=0;mPRzac:=0;mPRkon:=0;


                                                                                                                                                                                  // ceny z projektu

                                                                                                                                                                                     if not NxIsEmptyOID(mBO_ML.GetFieldValueAsString('ServiceDocument_ID.BusProject_ID')) then begin
                                                                                                                                                                                            mBO_BusProject:=mBO_ML.ObjectSpace.CreateObject('QOKMKIQUJF34L3DUICTBWEDQJC');
                                                                                                                                                                                           try
                                                                                                                                                                                             mBO_BusProject.load(mBO_ML.GetFieldValueAsString('ServiceDocument_ID.BusProject_ID'),nil);
                                                                                                                                                                                              if (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_id')='4B20000101') Or
                                                                                                                                                                                               (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_id')='6B20000101') Or
                                                                                                                                                                                               (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_id')='7B20000101') or
                                                                                                                                                                                               (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_id')='8B20000101') or
                                                                                                                                                                                               (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_id')='9B20000101') or
                                                                                                                                                                                               (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_id')='AB20000101')
                                                                                                                                                                                              then begin
                                                                                                                                                                                                      if(mBO_BusProject.GetFieldValueAsFloat('X_Prevence_pausal')<>0) then mF_pausal_prace:=mBO_BusProject.GetFieldValueAsFloat('X_Prevence_pausal');
                                                                                                                                                                                              end;
                                                                                                                                                                                              if(mBO_BusProject.GetFieldValueAsFloat('X_Najezdni_pausal')>0) then mF_pausal_Vyjezd:=mBO_BusProject.GetFieldValueAsFloat('X_Najezdni_pausal');
                                                                                                                                                                                              if(mBO_BusProject.GetFieldValueAsFloat('X_Sazba_bezna')>0) then mFSazba_prace:=mBO_BusProject.GetFieldValueAsFloat('X_Sazba_bezna');
                                                                                                                                                                                              if(mBO_BusProject.GetFieldValueAsFloat('X_Sazba_mimo_pd')>0) then mFSazba_mimo:=mBO_BusProject.GetFieldValueAsFloat('X_Sazba_mimo_pd');
                                                                                                                                                                                              if(mBO_BusProject.GetFieldValueAsFloat('X_sazba_vikend')>0) then mFSazba_vikend:=mBO_BusProject.GetFieldValueAsFloat('X_sazba_vikend');
                                                                                                                                                                                              if(mBO_BusProject.GetFieldValueAsFloat('X_sazba_vikend')>0) then mFSazba_svatek:=mBO_BusProject.GetFieldValueAsFloat('X_sazba_vikend');

                                                                                                                                                                                              if mF_pausal_Vyjezd=0 then  begin
                                                                                                                                                                                                    if(mBO_BusProject.GetFieldValueAsFloat('X_Sazba_km')>0) then mFSazba_Doprava_km:=mBO_BusProject.GetFieldValueAsFloat('X_Sazba_km');
                                                                                                                                                                                              end;
                                                                                                                                                                                              if(mBO_BusProject.GetFieldValueAsFloat('X_Pr_OD')>0) then mPRzac:=mBO_BusProject.GetFieldValueAsFloat('X_PR_od');
                                                                                                                                                                                              if(mBO_BusProject.GetFieldValueAsFloat('X_Pr_DO')>0) then mPRkon:=mBO_BusProject.GetFieldValueAsFloat('X_PR_do');
                                                                                                                                                                                              if(mBO_BusProject.GetFieldValueAsFloat('X_Priplatek3hod')>0) then mFPriplatek3H:=mBO_BusProject.GetFieldValueAsFloat('X_Priplatek3hod');
                                                                                                                                                                                        finally
                                                                                                                                                                                          mBO_BusProject.free;
                                                                                                                                                                                        end;

                                                                                                                                                                                   end;

                                                                                                                                                                                    if NxIsEmptyOID(mBO_ML.GetFieldValueAsString('ServiceDocument_ID.BusProject_ID')) then begin
                                                                                                                                                                                          try
                                                                                                                                                                                            // ceny z fakturační oblasti
                                                                                                                                                                                            mBO_BusProject:=mBO_ML.ObjectSpace.CreateObject('QOKMKIQUJF34L3DUICTBWEDQJC');
                                                                                                                                                                                            if mBO_ML.GetFieldValueAsInteger('ServiceDocument_ID.ServicedObject_ID.X_Fakturacni_oblast')=0 then begin
                                                                                                                                                                                                NxShowSimpleMessage('Pozor, předmět není přiřazen do fakturační oblasti, ceny nemusí odpovídat, bude použit formát pro Čechy',nil);
                                                                                                                                                                                                mBO_BusProject.load('2130000101',nil);                                                                                    // max cena=čechy
                                                                                                                                                                                            end;
                                                                                                                                                                                            if mBO_ML.GetFieldValueAsInteger('ServiceDocument_ID.ServicedObject_ID.X_Fakturacni_oblast')=1 then begin     // čechy
                                                                                                                                                                                                mBO_BusProject.load('2130000101',nil);
                                                                                                                                                                                            end;
                                                                                                                                                                                            if mBO_ML.GetFieldValueAsInteger('ServiceDocument_ID.ServicedObject_ID.X_Fakturacni_oblast')=2 then begin      // morava
                                                                                                                                                                                                mBO_BusProject.load('3130000101',nil);
                                                                                                                                                                                            end;


                                                                                                                                                                                            if mF_pausal_Vyjezd=0 then if(mBO_BusProject.GetFieldValueAsFloat('X_Najezdni_pausal')>0) then
                                                                                                                                                                                                  mF_pausal_Vyjezd:=mBO_BusProject.GetFieldValueAsFloat('X_Najezdni_pausal');
                                                                                                                                                                                            if mFSazba_prace=0 then if(mBO_BusProject.GetFieldValueAsFloat('X_Sazba_bezna')>0) then
                                                                                                                                                                                                  mFSazba_prace:=mBO_BusProject.GetFieldValueAsFloat('X_Sazba_bezna');
                                                                                                                                                                                            if mFSazba_mimo=0 then if(mBO_BusProject.GetFieldValueAsFloat('X_Sazba_mimo_pd')>0) then
                                                                                                                                                                                                mFSazba_mimo:=mBO_BusProject.GetFieldValueAsFloat('X_Sazba_mimo_pd');
                                                                                                                                                                                            if mFSazba_vikend=0 then if(mBO_BusProject.GetFieldValueAsFloat('X_sazba_vikend')>0) then
                                                                                                                                                                                                  mFSazba_vikend:=mBO_BusProject.GetFieldValueAsFloat('X_sazba_vikend');
                                                                                                                                                                                            if mFSazba_svatek=0 then if(mBO_BusProject.GetFieldValueAsFloat('X_sazba_vikend')>0) then
                                                                                                                                                                                                  mFSazba_svatek:=mBO_BusProject.GetFieldValueAsFloat('X_sazba_vikend');

                                                                                                                                                                                              if mF_pausal_Vyjezd=0 then  begin
                                                                                                                                                                                                    if mFSazba_Doprava_km=0 then if(mBO_BusProject.GetFieldValueAsFloat('X_Sazba_km')>0) then
                                                                                                                                                                                                     mFSazba_Doprava_km:=mBO_BusProject.GetFieldValueAsFloat('X_Sazba_km');
                                                                                                                                                                                              end;



                                                                                                                                                                                            if mPRzac=0 then if(mBO_BusProject.GetFieldValueAsFloat('X_Pr_OD')>0) then mPRzac:=mBO_BusProject.GetFieldValueAsFloat('X_PR_od');
                                                                                                                                                                                            if mPRkon=0 then if(mBO_BusProject.GetFieldValueAsFloat('X_Pr_DO')>0) then mPRkon:=mBO_BusProject.GetFieldValueAsFloat('X_PR_do');
                                                                                                                                                                                            if mFPriplatek3H=0 then mFPriplatek3H:=mBO_BusProject.GetFieldValueAsFloat('X_Priplatek3hod');

                                                                                                                                                                                         finally
                                                                                                                                                                                              mBO_BusProject.free;
                                                                                                                                                                                         end;
                                                                                                                                                                                  end;

                                                                                                                                                                                  if (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='AB20000101') or (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='4B20000101') or (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='8B20000101') or (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='9B20000101')  or (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='6B20000101') or (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_id')='7B20000101') then begin
                                                                                                                                                                                         //mrta:=tstringlist.create;
                                                                                                                                                                                         //try
                                                                                                                                                                                         //           mBO_ML.ObjectSpace.SQLSelect('select id from ServiceAssemblyForms2 where ItemType=0 and ((storecard_ID='+ QuotedStr('2ZI1000101')+
                                                                                                                                                                                         //           ') or (storecard_ID='+ QuotedStr('11J1000101')+')) and (parent_id=' + quotedstr(mBO_ML.oid)+ ')',mrta);
                                                                                                                                                                                         //        if mrta.count>0 then mpocet1:=mrta.count;
                                                                                                                                                                                         //finally
                                                                                                                                                                                         //     mrta.free;
                                                                                                                                                                                         //end;

                                                                                                                                                                                         if (mIDs_WorkerRole.count>0) and mB_pokracovat then begin
                                                                                                                                                                                              mForm1 := TForm.Create(xSite);mForm1.Caption := 'Rozpočtení paušálu';mForm1.FormStyle := fsStayOnTop;mForm1.BorderStyle := bsDialog;
                                                                                                                                                                                                      mForm1.Width := 1350;mForm1.Height := 100;mForm1.Scaled := False;mform1.Position := poScreenCenter;
                                                                                                                                                                                                      mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := 'Počet tech.:';mL_Technik.Top := 12;mL_Technik.Left := 10;mL_Technik.Height := 13;
                                                                                                                                                                                                      mL_technik_value:= TLabel.Create(mForm1);mL_technik_value.Parent := mForm1;mL_technik_value.Caption := inttostr(mIDs_WorkerRole.count);mL_technik_value.Top := 12;mL_technik_value.Left := 80;mL_technik_value.Height := 13;mL_technik_value.Width := 50;
                                                                                                                                                                                                      mL_technik_value:= TLabel.Create(mForm1);mL_technik_value.Parent := mForm1;mL_technik_value.Caption := ('Konec práce');mL_technik_value.Top := 10;mL_technik_value.Left := 150;mL_technik_value.Height := 13;mL_technik_value.Width := 50;
                                                                                                                                                                                                      mKonecDAte := TDateTimeEdit.Create(mForm1);mKonecDAte.Left := 250;mKonecDAte.Top := 10;mKonecDAte.Width := 80;mKonecDAte.Name := 'mKonecDAte';mKonecDAte.DateTime:= mBO_ML.GetFieldValueAsDateTime('EndDate$DATE');mKonecDAte.Enabled:=true;mForm1.InsertControl(mKonecDAte);
                                                                                                                                                                                                      mKonecTime := TTimeEdit.Create(mForm1);mKonecTime.Left := 330;mKonecTime.Top := 10;mKonecTime.Width := 80;mKonecTime.Name := 'mKonecTime';mKonecTime.Time:= mBO_ML.GetFieldValueAsDateTime('EndDate$DATE');mKonecTime.Enabled:= True;
                                                                                                                                                                                                      mForm1.InsertControl(mKonecTime);
                                                                                                                                                                                                      mL_operation:= TLabel.Create(mForm1);mL_operation.Parent := mForm1;mL_operation.Caption := 'Cena :';mL_operation.Top := 10;mL_operation.Left := 450;mL_operation.Height := 150;mL_operation.Width := 80;
                                                                                                                                                                                                      mEd_quantity := TEdit.Create(mForm1);mEd_quantity.Left := 500;mEd_quantity.Top := 10;mEd_quantity.Width := 100;mEd_quantity.Name := 'mEd_quantity';mEd_quantity.Text:=NxFloatToIBStr(mF_pausal_prace);mForm1.InsertControl(mEd_quantity);
                                                                                                                                                                                                      mL1_operation:= TLabel.Create(mForm1); mL1_operation.Parent := mForm1;mL1_operation.Caption := 'Doprava :';mL1_operation.Top := 10; mL1_operation.Left := 550;mL1_operation.Height := 13;mL1_operation.Width := 150;
                                                                                                                                                                                                      mEd1_quantity := TEdit.Create(mForm1);mEd1_quantity.Left := 660;mEd1_quantity.Top := 10;mEd1_quantity.Width := 100;mEd1_quantity.Name := 'mEd1_quantity';mEd1_quantity.Text:='0';mForm1.InsertControl(mEd1_quantity);
                                                                                                                                                                                                      mL1_C_protokol:= TLabel.Create(mForm1);
                                                                                                                                                                                                      mL1_C_protokol.Parent := mForm1; mL1_C_protokol.Caption := 'Protokol :' + mBO_ML.getFieldValueAsString('X_protokol_prefix');mL1_C_protokol.Top := 14;mL1_C_protokol.Left := 800;mL1_C_protokol.Height := 13;mL1_C_protokol.Width := 60;
                                                                                                                                                                                                      mEd1_C_protokol := TEdit.Create(mForm1);mEd1_C_protokol.Left := 880;mEd1_C_protokol.Top := 10;mEd1_C_protokol.Width := 100;mEd1_C_protokol.Name := 'mEd1_C_protokol';mEd1_C_protokol.Text:=mBO_ML.GetFieldValueAsString('X_Protokol');mForm1.InsertControl(mEd1_C_protokol);
                                                                                                                                                                                                      mL1_C_chyby:= TLabel.Create(mForm1);mL1_C_chyby.Parent := mForm1;mL1_C_chyby.Caption := 'Závada :';mL1_C_chyby.Top := 14;mL1_C_chyby.Left := 1000;mL1_C_chyby.Height := 13;mL1_C_chyby.Width := 50;
                                                                                                                                                                                                      mEd1_C_chyby := TEdit.Create(mForm1);mEd1_C_chyby.Left := 1070;mEd1_C_chyby.Top := 10; mEd1_C_chyby.Width := 100;mEd1_C_chyby.Name := 'mEd1_C_chyby';mEd1_C_chyby.Text:=mBO_ML.GetFieldValueAsString('X_zavada_code');mForm1.InsertControl(mEd1_C_chyby);
                                                                                                                                                                                                      mL1_P_Cyklu:= TLabel.Create(mForm1);mL1_P_Cyklu.Parent := mForm1;mL1_P_Cyklu.Caption := 'Cyklů :';mL1_P_Cyklu.Top := 14;mL1_P_Cyklu.Left := 1190;mL1_P_Cyklu.Height := 13;mL1_P_Cyklu.Width := 50;
                                                                                                                                                                                                      mEd1_P_Cyklu := TEdit.Create(mForm1);mEd1_P_Cyklu.Left := 1250; mEd1_P_Cyklu.Top := 10;mEd1_P_Cyklu.Width := 80;mEd1_P_Cyklu.Name := 'mEd1_P_Cyklu';mEd1_P_Cyklu.Text:=inttostr(mBO_ML.GetFieldValueAsInteger('X_Pocet_cyklu'));mForm1.InsertControl(mEd1_P_Cyklu);
                                                                                                                                                                                                      mBtn := TButton.Create(mForm1);mBtn.Width := 75;mBtn.Height := 25;mBtn.Caption := 'OK';mBtn.ModalResult := mrOk;mBtn.Cancel := False;mBtn.Default := True;mBtn.Left :=  mForm1.Width - 2*(mBtn.Width+2) - 20;mBtn.Top := mForm1.Height - mBtn.Height - 40;mBtn.Name := 'btnOK';mForm1.InsertControl(mBtn);
                                                                                                                                                                                                      mBtn := TButton.Create(mForm1);mBtn.Width := 75;mBtn.Height := 25;mBtn.Caption := 'Storno';mBtn.ModalResult := mrCancel;mBtn.Cancel := True;mBtn.Left := mForm1.Width - (mBtn.Width+2) - 20;mBtn.Top := mForm1.Height - mBtn.Height - 40;mBtn.Name := 'btnCancel';mForm1.InsertControl(mBtn);

                                                                                                                                                                                                         if mForm1.ShowModal(xSite) = mrOK then begin
                                                                                                                                                                                                                   mB_pokracovat:=true;
                                                                                                                                                                                                                   mpausal:=trunc(100/mIDs_WorkerRole.count)*0.01;
                                                                                                                                                                                                                   mpausal_oprava:=1-(mIDs_WorkerRole.count*mpausal);
                                                                                                                                                                                                                   mBO_ML.SetFieldValueAsString('X_zavada_code',mEd1_C_chyby.Text);
                                                                                                                                                                                                                       mBO_ML.SetFieldValueAsString('X_Protokol',mEd1_C_protokol.Text);
                                                                                                                                                                                                                       mBO_ML.SetFieldValueAsInteger('X_Pocet_cyklu',StrToInt(mEd1_P_Cyklu.Text));
                                                                                                                                                                                                             mList_pomoc:= TStringList.Create;
                                                                                                                                                                                                             try
                                                                                                                                                                                                                     for mI_MLRow := 0 to mRows_ML.Count - 1 do begin
                                                                                                                                                                                                                          if (mRows_ML.BusinessObject[mI_MLRow].GetFieldValueAsinteger('itemtype')=0) and (mRows_ML.BusinessObject[mI_MLRow].GetFieldValueAsinteger('ToInvoiceType') =0 )then begin
                                                                                                                                                                                                                                mWorkerRole_ID:=mRows_ML.BusinessObject[mI_MLRow].GetFieldValueAsString('X_WorkerRole_ID');

                                                                                                                                                                                                                              if (mRows_ML.BusinessObject[mI_MLRow].GetFieldValueAsString('Storecard_ID')='11J1000101') or
                                                                                                                                                                                                                                    (mRows_ML.BusinessObject[mI_MLRow].GetFieldValueAsString('Storecard_ID')='2ZI1000101') then begin

                                                                                                                                                                                                                                    mList_pomoc.AddObject(mRows_ML.BusinessObject[mI_MLRow].OID, mRows_ML.BusinessObject[mI_MLRow]);
                                                                                                                                                                                                                                    mWorkHoursReal:=mpausal+mpausal_oprava ;
                                                                                                                                                                                                                                    mpocet_km:=NxIBStrToFloat(mEd1_quantity.text) ;
                                                                                                                                                                                                                                    mDateto:=trunc(mKonecDAte.DateTime) + frac((mKonecTime.Time));
                                                                                                                                                                                                                                    mstore:=mRows_ML.BusinessObject[mI_MLRow].GetFieldValueAsString('Store_id');
                                                                                                                                                                                                                                    mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('WorkHoursReal',mWorkHoursReal);
                                                                                                                                                                                                                                    mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('WorkHoursPlanned',mWorkHoursReal);
                                                                                                                                                                                                                                    mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('Quantity',mWorkHoursReal);
                                                                                                                                                                                                                                    mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('QuantityDelivered',mWorkHoursReal);
                                                                                                                                                                                                                                    mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsDateTime('X_konec_prace',mDateto);
                                                                                                                                                                                                                                    mPosIndex := mRows_ML.BusinessObject[mI_MLRow].GetFieldValueAsInteger('PosIndex');
                                                                                                                                                                                                                                    mquantity:=mWorkHoursReal;
                                                                                                                                                                                                                                    //mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('WorkHoursReal',1);
                                                                                                                                                                                                                                    mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsinteger('itemtype',4);
                                                                                                                                                                                                                                    mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsinteger('ToInvoiceType',1);
                                                                                                                                                                                                                                    mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsString('Text','Práce - evidenční pro mzdy');
                                                                                                                                                                                                                                    mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('WorkHoursPlanned',mWorkHoursReal);
                                                                                                                                                                                                                                    mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('Quantity',mWorkHoursReal);
                                                                                                                                                                                                                                    mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('QuantityDelivered',mWorkHoursReal);
                                                                                                                                                                                                                                    mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsString('Qunit','ks');
                                                                                                                                                                                                                                    //mRows_ML.BusinessObject[i].SetFieldValueAsinteger('IsInvoiced',1);
                                                                                                                                                                                                                                    mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsBoolean('X_storno',true);
                                                                                                                                                                                                                                    mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('UnitPriceWithVAT',0);
                                                                                                                                                                                                                                    mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('UnitPriceWithoutVAT',0);
                                                                                                                                                                                                                                    mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsString('WorkerRole_ID',mWorkerRole_ID);
                                                                                                                                                                                                                              end;

                                                                                                                                                                                                                          end;
                                                                                                                                                                                                                     end;
                                                                                                                                                                                                                     for i01 := 0 to mList_pomoc.Count-1 do begin
                                                                                                                                                                                                                          mRow_Pomoc := TNxCustomBusinessObject(mList_pomoc.Objects[i01]);
                                                                                                                                                                                                                          mWorkerRole_ID:=mRow_Pomoc.GetFieldValueAsString('WorkerRole_ID');

                                                                                                                                                                                                                                            mNewRow := mRows_ML.AddNewObject;
                                                                                                                                                                                                                                            mNewRow.SetFieldValueAsInteger('itemtype',0);          // 0 práce , 1 skladová karta
                                                                                                                                                                                                                                            //mNewRow.SetFieldValueAsString('serviceworkcategory_id','');
                                                                                                                                                                                                                                            mNewRow.SetFieldValueAsString('WorkerRole_ID',mWorkerRole_ID);
                                                                                                                                                                                                                                            mNewRow.SetFieldValueAsString('X_WorkerRole_ID',mWorkerRole_ID);
                                                                                                                                                                                                                                            mNewRow.SetFieldValueAsString('X_Osoba',mNewRow.GetFieldValueAsString('X_WorkerRole_ID.Name'));
                                                                                                                                                                                                                                            mNewRow.SetFieldValueAsString('Text','Paušál práce');
                                                                                                                                                                                                                                            mNewRow.SetFieldValueAsString('Store_id',mStore);
                                                                                                                                                                                                                                            mNewRow.SetFieldValueAsString('StoreCard_id','1ZI1000101');
                                                                                                                                                                                                                                            mNewRow.SetFieldValueAsfloat('WorkHoursPlanned',mpausal+mpausal_oprava);
                                                                                                                                                                                                                                            mNewRow.SetFieldValueAsfloat('WorkHoursReal',mpausal+mpausal_oprava);
                                                                                                                                                                                                                                            mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',NxIBStrToFloat(mEd_quantity.Text));
                                                                                                                                                                                                                                            mNewRow.SetFieldValueAsfloat('X_radkova_sleva',0);
                                                                                                                                                                                                                                            mNewRow.SetFieldValueAsDateTime('X_konec_prace',mDateto);
                                                                                                                                                                                                                                            mpausal_oprava:=0;


                                                                                                                                                                                                                     End;
                                                                                                                                                                                                               finally
                                                                                                                                                                                                                   mList_pomoc.free;
                                                                                                                                                                                                               end;
                                                                                                                                                                                                         end else begin
                                                                                                                                                                                                         mB_pokracovat:=false;
                                                                                                                                                                                                         end;
                                                                                                                                                                                                end;
                                                                                                                                                                                         //end;  //počet















                                                                                                                                                                                       //paušál

                                                                                                                                                                                  end else begin

                                                                                                                                                                                              mList_pomoc:= TStringList.Create;
                                                                                                                                                                                              try
                                                                                                                                                                                                  for mI_MLRow:=0 to mRows_ML.count-1 do begin

                                                                                                                                                                                                       if ((mRows_ML.BusinessObject[mI_MLRow].GetFieldValueAsinteger('itemtype')=0) and (mRows_ML.BusinessObject[mI_MLRow].GetFieldValueAsinteger('ToInvoiceType') =0 ) and ((mRows_ML.BusinessObject[mI_MLRow].GetFieldValueAsString('Storecard_ID')='11J1000101') or
                                                                                                                                                                                                              (mRows_ML.BusinessObject[mI_MLRow].GetFieldValueAsString('Storecard_ID')='2ZI1000101'))) and mB_pokracovat then begin
                                                                                                                                                                                                               mList_pomoc.AddObject(mRows_ML.BusinessObject[mI_MLRow].OID, mRows_ML.BusinessObject[mI_MLRow]);
                                                                                                                                                                                                                     mquantity:=mRows_ML.BusinessObject[mI_MLRow].getFieldValueAsFloat('WorkHoursReal');
                                                                                                                                                                                                                     mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsString('X_workerRole_id',mRows_ML.BusinessObject[mI_MLRow].getFieldValueAsString('WorkerRole_id'));
                                                                                                                                                                                                                     mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('WorkHoursPlanned',mquantity);
                                                                                                                                                                                                                     mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('Quantity',mquantity);
                                                                                                                                                                                                                     mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('QuantityDelivered',mquantity);
                                                                                                                                                                                                                     mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsinteger('itemtype',4);
                                                                                                                                                                                                                     mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsinteger('ToInvoiceType',1);
                                                                                                                                                                                                                     mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsString('Text','Práce - evidenční pro mzdy');
                                                                                                                                                                                                                     mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('WorkHoursPlanned',mquantity);
                                                                                                                                                                                                                     mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('Quantity',mquantity);
                                                                                                                                                                                                                     mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('QuantityDelivered',mquantity);
                                                                                                                                                                                                                     mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsString('Qunit','hod');

                                                                                                                                                                                                                     mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsBoolean('X_storno',true);
                                                                                                                                                                                                                     mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('UnitPriceWithVAT',0);
                                                                                                                                                                                                                     mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('UnitPriceWithoutVAT',0);
                                                                                                                                                                                                                     mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsDateTime('X_konec_prace',mDateto);

                                                                                                                                                                                                     end;

                                                                                                                                                                                                  end;
                                                                                                                                                                                                  for i01 := 0 to mList_pomoc.Count-1 do begin
                                                                                                                                                                                                      mRow_Pomoc := TNxCustomBusinessObject(mList_pomoc.Objects[i01]);
                                                                                                                                                                                                      mWorkerRole_ID:=mRow_Pomoc.GetFieldValueAsString('WorkerRole_ID');
                                                                                                                                                                                                      mBO_SecurityRole:=xSite.BaseObjectSpace.CreateObject('QRDGQ1DV2CU4D3TOUMORZ0LWIW');

                                                                                                                                                                                                      if mPRzac=0 then mPRzac:=EncodeTime(7,0,0,0);
                                                                                                                                                                                                      if mPRkon=0 then mPRkon:=EncodeTime(15,30,0,0);



                                                                                                                                                                                                                            mForm1 := TForm.Create(xSite);
                                                                                                                                                                                                                            try

                                                                                                                                                                                                                                mForm1.Caption := 'Evidence pro mzdy';mForm1.FormStyle := fsStayOnTop;mForm1.BorderStyle := bsDialog;mForm1.Width := 1350;mForm1.Height := 100;mForm1.Scaled := False;mform1.Position := poScreenCenter;
                                                                                                                                                                                                                                    mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := 'Technik :';mL_Technik.Top := 14;mL_Technik.Left := 10;mL_Technik.Height := 13;
                                                                                                                                                                                                                                    mL_technik_value:= TLabel.Create(mForm1);mL_technik_value.Parent := mForm1;mL_technik_value.Caption := mRow_Pomoc.GetFieldValueAsString('X_WorkerRole_ID.Name');mL_technik_value.Top := 14;mL_technik_value.Left := 80;mL_technik_value.Height := 13;mL_technik_value.Width := 120;
                                                                                                                                                                                                                                    mL_technik1_value:= TLabel.Create(mForm1);mL_technik1_value.Parent := mForm1;mL_technik1_value.Caption := ('Konec práce');mL_technik1_value.Top := 14;mL_technik1_value.Left := 200;mL_technik1_value.Height := 13;mL_technik1_value.Width := 200;
                                                                                                                                                                                                                                    mKonecDAte := TDatetimeEdit.Create(mForm1);mKonecDAte.Left := 300;mKonecDAte.Top := 10;mKonecDAte.Width := 80;mKonecDAte.Name := 'mKonecDAte';mKonecDAte.DateTime:= trunc(mdateto); mKonecDAte.Enabled:=true;mForm1.InsertControl(mKonecDAte);
                                                                                                                                                                                                                                    mKonecTime := TTimeEdit.Create(mForm1);mKonecTime.Left := 380;mKonecTime.Top := 10;mKonecTime.Width := 80;mKonecTime.Name := 'mKonecTime';mKonecTime.Time:= frac(mDateto); mKonecTime.Enabled:= True;mForm1.InsertControl(mKonecTime);
                                                                                                                                                                                                                                    mL_operation:= TLabel.Create(mForm1);mL_operation.Parent := mForm1;mL_operation.Caption := 'Doba práce :';mL_operation.Top := 14;mL_operation.Left := 480;mL_operation.Height := 13;mL_operation.Width := 120;
                                                                                                                                                                                                                                    mEd_quantity := TEdit.Create(mForm1);mEd_quantity.Left := 570;mEd_quantity.Top := 10;mEd_quantity.Width := 30;mEd_quantity.Name := 'mEd_quantity'; mEd_quantity.Text:=NxFloatToIBStr(mF_doba);mForm1.InsertControl(mEd_quantity);
                                                                                                                                                                                                                                    mL1_operation:= TLabel.Create(mForm1); mL1_operation.Parent := mForm1;mL1_operation.Caption := 'Doprava :';mL1_operation.Top := 14;mL1_operation.Left := 630;mL1_operation.Height := 13;mL1_operation.Width := 80;
                                                                                                                                                                                                                                    mEd1_quantity := TEdit.Create(mForm1);mEd1_quantity.Left := 680;mEd1_quantity.Top := 10;mEd1_quantity.Width := 50;mEd1_quantity.Name := 'mEd1_quantity';mEd1_quantity.Text:=NxFloatToIBStr(mRow_Pomoc.GetFieldValueAsFloat('Quantity'));mForm1.InsertControl(mEd1_quantity);
                                                                                                                                                                                                                                    mEd1_Pohotovost := TCheckBox.Create(mForm1);mEd1_Pohotovost.Left := 750;mEd1_Pohotovost.Top := 12;mEd1_Pohotovost.Width := 100;mEd1_Pohotovost.Name := 'mEd1_Pohotovost';mEd1_pohotovost.Caption:='Pohotovost';if mRow_Pomoc.GetFieldValueAsBoolean('X_Pohotovost')= true then mEd1_Pohotovost.State:=1;if mRow_Pomoc.GetFieldValueAsBoolean('X_Pohotovost')= false then mEd1_Pohotovost.State:=0;mForm1.InsertControl(mEd1_Pohotovost);
                                                                                                                                                                                                                                    mL1_C_protokol:= TLabel.Create(mForm1);mL1_C_protokol.Parent := mForm1;mL1_C_protokol.Caption := 'Protokol :' + mBO_ML.getFieldValueAsString('X_protokol_prefix');mL1_C_protokol.Top := 14;mL1_C_protokol.Left := 840;mL1_C_protokol.Height := 13;mL1_C_protokol.Width := 60;
                                                                                                                                                                                                                                    mEd1_C_protokol := TEdit.Create(mForm1);mEd1_C_protokol.Left := 900;mEd1_C_protokol.Top := 10;mEd1_C_protokol.Width := 100;mEd1_C_protokol.Name := 'mEd1_C_protokol';mEd1_C_protokol.Text:=mBO_ML.GetFieldValueAsString('X_Protokol');mForm1.InsertControl(mEd1_C_protokol);
                                                                                                                                                                                                                                    mL1_C_chyby:= TLabel.Create(mForm1);mL1_C_chyby.Parent := mForm1;mL1_C_chyby.Caption := 'Závada :';mL1_C_chyby.Top := 14;mL1_C_chyby.Left := 1020;mL1_C_chyby.Height := 13;mL1_C_chyby.Width := 50;
                                                                                                                                                                                                                                    mEd1_C_chyby := TEdit.Create(mForm1);mEd1_C_chyby.Left := 1070;mEd1_C_chyby.Top := 10;mEd1_C_chyby.Width := 100;mEd1_C_chyby.Name := 'mEd1_C_chyby';mEd1_C_chyby.Text:=mBO_ML.GetFieldValueAsString('X_zavada_code');mForm1.InsertControl(mEd1_C_chyby);
                                                                                                                                                                                                                                    mL1_P_Cyklu:= TLabel.Create(mForm1);mL1_P_Cyklu.Parent := mForm1;mL1_P_Cyklu.Caption := 'Cyklů :';mL1_P_Cyklu.Top := 14;mL1_P_Cyklu.Left := 1190;mL1_P_Cyklu.Height := 13;mL1_P_Cyklu.Width := 50;
                                                                                                                                                                                                                                    mEd1_P_Cyklu := TEdit.Create(mForm1);mEd1_P_Cyklu.Left := 1250;mEd1_P_Cyklu.Top := 10;mEd1_P_Cyklu.Width := 80;mEd1_P_Cyklu.Name := 'mEd1_P_Cyklu';mEd1_P_Cyklu.Text:=inttostr(mBO_ML.GetFieldValueAsInteger('X_Pocet_cyklu'));mForm1.InsertControl(mEd1_P_Cyklu);
                                                                                                                                                                                                                                mBtn := TButton.Create(mForm1);mBtn.Width := 75;mBtn.Height := 25;mBtn.Caption := 'OK';mBtn.ModalResult := mrOk;mBtn.Cancel := False;mBtn.Default := True;mBtn.Left :=  mForm1.Width - 2*(mBtn.Width+2) - 20;mBtn.Top := mForm1.Height - mBtn.Height - 40;mBtn.Name := 'btnOK';mForm1.InsertControl(mBtn);
                                                                                                                                                                                                                                mBtn := TButton.Create(mForm1);mBtn.Width := 75;mBtn.Height := 25;mBtn.Caption := 'Storno';mBtn.ModalResult := mrCancel; mBtn.Cancel := True;mBtn.Left := mForm1.Width - (mBtn.Width+2) - 20; mBtn.Top := mForm1.Height - mBtn.Height - 40;mBtn.Name := 'btnCancel';mForm1.InsertControl(mBtn);

                                                                                                                                                                                                                                if mForm1.ShowModal(xSite) = mrOK then begin
                                                                                                                                                                                                                                         mB_pokracovat:=true;
                                                                                                                                                                                                                                         mD_ML_End:=trunc(mKonecDAte.DateTime)+mKonectime.Time;
                                                                                                                                                                                                                                         mDateto:=trunc(mKonecDAte.DateTime)+mKonectime.Time;

                                                                                                                                                                                                                                         if mEd1_Pohotovost.State=0 then mRow_Pomoc.setFieldValueAsBoolean('X_Pohotovost',false);
                                                                                                                                                                                                                                         if mEd1_Pohotovost.State=1 then mRow_Pomoc.setFieldValueAsBoolean('X_Pohotovost',True);
                                                                                                                                                                                                                                         mBO_ML.SetFieldValueAsString('X_zavada_code',mEd1_C_chyby.Text);
                                                                                                                                                                                                                                         mBO_ML.SetFieldValueAsString('X_Protokol',mEd1_C_protokol.Text);
                                                                                                                                                                                                                                         mBO_ML.SetFieldValueAsInteger('X_Pocet_cyklu',StrToInt(mEd1_P_Cyklu.Text));


                                                                                                                                                                                                                                         mWorkHoursReal:=NxIBStrToFloat(mEd_quantity.text) ;
                                                                                                                                                                                                                                         mpocet_km:=NxIBStrToFloat(mEd1_quantity.text) ;
                                                                                                                                                                                                                                         mDateto:=trunc(mKonecDAte.DateTime) + frac((mKonecTime.Time));
                                                                                                                                                                                                                                         mRow_Pomoc.SetFieldValueAsFloat('WorkHoursReal',mWorkHoursReal);
                                                                                                                                                                                                                                         mRow_Pomoc.SetFieldValueAsDateTime('X_konec_prace',mD_ML_End);

                                                                                                                                                                                                                                 end else begin
                                                                                                                                                                                                                                    mB_pokracovat:=false;
                                                                                                                                                                                                                                 end;
                                                                                                                                                                                                                            finally
                                                                                                                                                                                                                                mForm1.Free;
                                                                                                                                                                                                                            end;
                                                                                                                                                                                                                            msleva:=mRow_Pomoc.getFieldValueAsinteger('X_radkova_sleva');
                                                                                                                                                                                                                            if ((mRow_Pomoc.getFieldValueAsFloat('WorkHoursReal')<=0) and (mWorkHoursReal<>0)) and (not mB_pokracovat) then begin
                                                                                                                                                                                                                                 if mB_pokracovat then nxShowSimpleMessage('Operace byla přerušena',nil) else  nxShowSimpleMessage('Není zadaná reálně odpracovaná doba, nelze pokračovat',nil);
                                                                                                                                                                                                                            end else begin
                                                                                                                                                                                                                                  mstore:=mRow_Pomoc.getFieldValueAsString('Store_id');

                                                                                                                                                                                                                                     mDatefrom:=mDateto - EncodeTime(trunc(mF_doba),trunc(frac(trunc(mF_doba)*60)),0,0);
                                                                                                                                                                                                                                        if mB_pokracovat then begin // není záruka
                                                                                                                                                                                                                                                    mF_svatek:=0;mF_vikend:=0;mF_mimo:=0;mF_prace:=0;mFS_svatek:=0;mFS_vikend:=0;mFS_mimo:=0;mFS_prace:=0;mDateZac:=frac(mPRzac);mDateKon:=frac(mPRkon);
                                                                                                                                                                                                                                                  if trunc(mDateto)=trunc(mDatefrom) then begin          // jednodenní operace
                                                                                                                                                                                                                                                       mF_svatek:=Svatek(mBO_ML.ObjectSpace,mDatefrom,mDateto);
                                                                                                                                                                                                                                                            if mF_svatek=0 then begin
                                                                                                                                                                                                                                                                mF_vikend:=vikend(mBO_ML.ObjectSpace,mDatefrom,mDateto);
                                                                                                                                                                                                                                                                   if mF_vikend=0 then begin
                                                                                                                                                                                                                                                                     mF_Mimo:=Mimo(mBO_ML.ObjectSpace,frac(mDatefrom),frac(mDateto),frac(mDateZac),frac(mDateKon));
                                                                                                                                                                                                                                                                     mF_Prace:=Pracovni_doba(mBO_ML.ObjectSpace,frac(mDatefrom),frac(mDateto),frac(mDateZac),frac(mDateKon));
                                                                                                                                                                                                                                                                   end;
                                                                                                                                                                                                                                                            end;
                                                                                                                                                                                                                                                        mFS_svatek:=mFS_svatek+mF_svatek;
                                                                                                                                                                                                                                                        mFS_vikend:=mFS_vikend+mF_vikend;
                                                                                                                                                                                                                                                        mFS_Mimo:=mFS_Mimo+mF_Mimo;
                                                                                                                                                                                                                                                        mFS_Prace:=mFS_Prace+mF_Prace;// jednodenní práce
                                                                                                                                                                                                                                                  end else begin
                                                                                                                                                                                                                                                      mDnu:=trunc(mDateto)-trunc(mDatefrom) ;
                                                                                                                                                                                                                                                      for II:=0 to mDnu do begin
                                                                                                                                                                                                                                                         if (trunc(mDateFrom)+ii=trunc(mDatefrom)) or (trunc(mDateFrom)+ii=trunc(mDateto)) then begin       // necelý den
                                                                                                                                                                                                                                                             if (trunc(mDateFrom)+ii=trunc(mDatefrom)) then begin  // první den
                                                                                                                                                                                                                                                                  //if ladit then NxShowSimpleMessage('První den',nil);
                                                                                                                                                                                                                                                                  mF_svatek:=Svatek(mBO_ML.ObjectSpace,mDatefrom,mDateto);
                                                                                                                                                                                                                                                                  if mF_svatek=0 then begin
                                                                                                                                                                                                                                                                        mF_vikend:=vikend(mBO_ML.ObjectSpace,mDatefrom,trunc(mdatefrom)+1);
                                                                                                                                                                                                                                                                        if mF_vikend=0 then begin
                                                                                                                                                                                                                                                                              mF_Mimo:=Mimo(mBO_ML.ObjectSpace,frac(mDatefrom),1,frac(mDateZac),frac(mDateKon));
                                                                                                                                                                                                                                                                              mF_Prace:=Pracovni_doba(mBO_ML.ObjectSpace,frac(mDatefrom),1,frac(mDateZac),frac(mDateKon));
                                                                                                                                                                                                                                                                        end;
                                                                                                                                                                                                                                                                  end;
                                                                                                                                                                                                                                                             end;
                                                                                                                                                                                                                                                             if (trunc(mDateFrom)+ii=trunc(mDateto)) then begin    // poslední den
                                                                                                                                                                                                                                                                  mF_svatek:=Svatek(mBO_ML.ObjectSpace,trunc(mDateto),mDateto);
                                                                                                                                                                                                                                                                  //if ladit then NxShowSimpleMessage('Poslední den',nil);
                                                                                                                                                                                                                                                                  if mF_svatek=0 then begin
                                                                                                                                                                                                                                                                        mF_vikend:=vikend(mBO_ML.ObjectSpace,trunc(mDateto),mDateto);
                                                                                                                                                                                                                                                                        if mF_vikend=0 then begin
                                                                                                                                                                                                                                                                              mF_Mimo:=Mimo(mBO_ML.ObjectSpace,0,frac(mDateto),frac(mDateZac),frac(mDateKon));
                                                                                                                                                                                                                                                                              mF_Prace:=Pracovni_doba(mBO_ML.ObjectSpace,0,frac(mDateto),frac(mDateZac),frac(mDateKon));
                                                                                                                                                                                                                                                                        end;
                                                                                                                                                                                                                                                                  end;
                                                                                                                                                                                                                                                             end;
                                                                                                                                                                                                                                                         end else begin    // celý den
                                                                                                                                                                                                                                                            mF_svatek:=Svatek(mBO_ML.ObjectSpace,trunc(mDatefrom)+ii,trunc(mDatefrom)+1+ii);
                                                                                                                                                                                                                                                                  if mF_svatek=0 then begin
                                                                                                                                                                                                                                                                        mF_vikend:=vikend(mBO_ML.ObjectSpace,trunc(mDatefrom)+ii,trunc(mDatefrom)+1+ii);
                                                                                                                                                                                                                                                                        if mF_vikend=0 then begin
                                                                                                                                                                                                                                                                             // if ladit then NxShowSimpleMessage('Celý den',nil);
                                                                                                                                                                                                                                                                              mF_Mimo:=Mimo(mBO_ML.ObjectSpace,trunc(mDatefrom)+ii,trunc(mDatefrom)+1+ii,frac(mDateZac),frac(mDateKon));
                                                                                                                                                                                                                                                                              mF_Prace:=Pracovni_doba(mBO_ML.ObjectSpace,trunc(mDatefrom)+ii,trunc(mDatefrom)+1+ii,frac(mDateZac),frac(mDateKon));
                                                                                                                                                                                                                                                                        end;
                                                                                                                                                                                                                                                                  end;
                                                                                                                                                                                                                                                            end;
                                                                                                                                                                                                                                                        mFS_svatek:=mFS_svatek+mF_svatek;
                                                                                                                                                                                                                                                        mFS_vikend:=mFS_vikend+mF_vikend;
                                                                                                                                                                                                                                                        mFS_Mimo:=mFS_Mimo+mF_Mimo;
                                                                                                                                                                                                                                                        mFS_Prace:=mFS_Prace+mF_Prace;


                                                                                                                                                                                                                                                      end;
                                                                                                                                                                                                                                                  end;
                                                                                                                                                                                                                                                  mkorekce:=0;
                                                                                                                                                                                                                                                  mFS_Prace:=NxIBStrToFloat(FormatDateTime('H',mFS_Prace)) + (NxIBStrToFloat(FormatDateTime('N',mFS_Prace))*(100/60));
                                                                                                                                                                                                                                                  mFS_Mimo:=NxIBStrToFloat(FormatDateTime('H',mFS_Mimo))+ (NxIBStrToFloat(FormatDateTime('N',mFS_Mimo))*(100/60));
                                                                                                                                                                                                                                                  if mfs_mimo<0 then begin
                                                                                                                                                                                                                                                     mFS_Prace:=mFS_Prace+mFS_Mimo;
                                                                                                                                                                                                                                                     mFS_Prace:=NxIBStrToFloat(FormatDateTime('H',mFS_Prace)) + (NxIBStrToFloat(FormatDateTime('N',mFS_Prace))*(100/60));
                                                                                                                                                                                                                                                     mFS_Mimo:=0;
                                                                                                                                                                                                                                                     end else begin
                                                                                                                                                                                                                                                     mFS_Mimo:=NxIBStrToFloat(FormatDateTime('H',mFS_Mimo))+ (NxIBStrToFloat(FormatDateTime('N',mFS_Mimo))*(100/60));
                                                                                                                                                                                                                                                  end;
                                                                                                                                                                                                                                                  mFS_svatek:=NxIBStrToFloat(FormatDateTime('H',mFS_svatek))+ (NxIBStrToFloat(FormatDateTime('N',mFS_svatek))*(100/60));
                                                                                                                                                                                                                                                  mFS_vikend:=NxIBStrToFloat(FormatDateTime('H',mF_vikend))+ (NxIBStrToFloat(FormatDateTime('N',mF_vikend))*(100/60));



                                                                                                                                                                                                                                                  if mWorkHoursReal<>(mFS_svatek+mFS_vikend +mFS_Mimo+mFS_Prace) then begin
                                                                                                                                                                                                                                                          mkorekce:=mWorkHoursReal-(mFS_svatek+mFS_vikend+mFS_Mimo+mFS_Prace) ;
                                                                                                                                                                                                                                                          if mFS_vikend+mFS_svatek>0 then begin
                                                                                                                                                                                                                                                             mFS_vikend:=(mFS_vikend+mkorekce);
                                                                                                                                                                                                                                                             mkorekce:=0;
                                                                                                                                                                                                                                                          end;
                                                                                                                                                                                                                                                          if mFS_Mimo>0 then begin
                                                                                                                                                                                                                                                             mFS_Mimo:=(mFS_Mimo+mkorekce);
                                                                                                                                                                                                                                                             mkorekce:=0;
                                                                                                                                                                                                                                                          end else begin
                                                                                                                                                                                                                                                                 mFS_Prace:=mWorkHoursReal-(mFS_svatek+mFS_vikend+mFS_Mimo)
                                                                                                                                                                                                                                                          end;
                                                                                                                                                                                                                                                  end;
                                                                                                                                                                                                                                                  mForm1 := TForm.Create(xSite);
                                                                                                                                                                                                                                                   try
                                                                                                                                                                                                                                                        mForm1.Caption := 'Rozpočtení práce pro fakturaci';mForm1.FormStyle := fsStayOnTop;mForm1.BorderStyle := bsDialog;mForm1.Width := 450; mForm1.Height := 450;mForm1.Scaled := False;mForm1.Position := poScreenCenter;
                                                                                                                                                                                                                                                        mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := 'Technik :';mL_Technik.Top := 12;mL_Technik.Left := 10;mL_Technik.Height := 13;
                                                                                                                                                                                                                                                        mL_technik_value:= TLabel.Create(mForm1);mL_technik_value.Parent := mForm1;mL_technik_value.Caption := mRow_Pomoc.GetFieldValueAsString('X_WorkerRole_ID.Name');mL_technik_value.Top := 12;mL_technik_value.Left := 80;mL_technik_value.Height := 13;mL_technik_value.Width := 200;
                                                                                                                                                                                                                                                        mL_technik_value:= TLabel.Create(mForm1);mL_technik_value.Parent := mForm1; mL_technik_value.Caption := ('Konec práce');mL_technik_value.Top := 10;mL_technik_value.Left := 150;mL_technik_value.Height := 13;mL_technik_value.Width := 200;
                                                                                                                                                                                                                                                        mKonecDAte := TDateTimeEdit.Create(mForm1);mKonecDAte.Left := 230;mKonecDAte.Top := 10;mKonecDAte.Width := 80;mKonecDAte.Name := 'mKonecDAte';mKonecDAte.DateTime:= mDateto;mKonecDAte.Enabled:=false;mForm1.InsertControl(mKonecDAte);
                                                                                                                                                                                                                                                        mKonecTime := TTimeEdit.Create(mForm1);mKonecTime.Left := 330;mKonecTime.Top := 10;mKonecTime.Width := 80;mKonecTime.Name := 'mKonecTime';mKonecTime.Time:= mDateto;mKonecTime.Enabled:= False;mForm1.InsertControl(mKonecTime);

                                                                                                                                                                                                                                                         if true then begin
                                                                                                                                                                                                                                                             mL_operation:= TLabel.Create(mForm1);mL_operation.Parent := mForm1;mL_operation.Caption := 'Práce paušál :';mL_operation.Top := 42;mL_operation.Left := 10;mL_operation.Height := 13;mL_operation.Width := 320;
                                                                                                                                                                                                                                                             mEd_quantity := TEdit.Create(mForm1);mEd_quantity.Left := 150;mEd_quantity.Top := 42;mEd_quantity.Width := 80;mEd_quantity.Name := 'mEd_quantity';if mF_pausal_prace<>0 then mEd_quantity.Text:='0' else mEd_quantity.Text:='0' ;mForm1.InsertControl(mEd_quantity);
                                                                                                                                                                                                                                                             mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1; mL_Technik.Caption := 'ks';mL_Technik.Top := 42;mL_Technik.Left := 240 ;mL_Technik.Height := 13;
                                                                                                                                                                                                                                                             mEd_Unitprice:= TEdit.Create(mForm1);mEd_Unitprice.Left := 280;mEd_Unitprice.Top := 40;mEd_Unitprice.Width := 80;mEd_Unitprice.Name := 'mEd_Unitprice';mEd_Unitprice.Text:=NxFloatToIBStr(mF_pausal_prace);mForm1.InsertControl(mEd_Unitprice);
                                                                                                                                                                                                                                                             mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := '  kč/j';mL_Technik.Top := 42;mL_Technik.Left := 360;mL_Technik.Height := 13;
                                                                                                                                                                                                                                                         end;
                                                                                                                                                                                                                                                         mxpomoc:=0;
                                                                                                                                                                                                                                                         if mF_pausal_Vyjezd<>0 then begin
                                                                                                                                                                                                                                                             mxpomoc:=1;
                                                                                                                                                                                                                                                         end;
                                                                                                                                                                                                                                                                 if true then begin
                                                                                                                                                                                                                                                                     mL_operation:= TLabel.Create(mForm1);mL_operation.Parent := mForm1;mL_operation.Caption := 'Doprava paušál :';mL_operation.Top := 72;mL_operation.Left := 10;mL_operation.Height := 13;mL_operation.Width := 320;
                                                                                                                                                                                                                                                                     mEd_quantity1 := TEdit.Create(mForm1);mEd_quantity1.Left := 150;mEd_quantity1.Top := 70;mEd_quantity1.Width := 80;mEd_quantity1.Name := 'mEd_quantity1';mEd_quantity1.Text:=NxFloatToIBStr(mxpomoc) ;mForm1.InsertControl(mEd_quantity1);mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := 'ks';mL_Technik.Top := 72; mL_Technik.Left := 240 ;mL_Technik.Height := 13;
                                                                                                                                                                                                                                                                     mEd_Unitprice1:= TEdit.Create(mForm1);mEd_Unitprice1.Left := 280;mEd_Unitprice1.Top := 70;mEd_Unitprice1.Width := 80;mEd_Unitprice1.Name := 'mEd_Unitprice1';mEd_Unitprice1.Text:=NxFloatToIBStr(mF_pausal_Vyjezd);mForm1.InsertControl(mEd_Unitprice1);
                                                                                                                                                                                                                                                                     mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := '  kč/j';mL_Technik.Top := 72;mL_Technik.Left := 360;mL_Technik.Height := 13;
                                                                                                                                                                                                                                                                 end;

                                                                                                                                                                                                                                             {            if false then begin
                                                                                                                                                                                                                                                             mL_operation:= TLabel.Create(mForm1);mL_operation.Parent := mForm1;mL_operation.Caption := 'Pracovní doba :';mL_operation.Top := 102;mL_operation.Left := 10;mL_operation.Height := 13;mL_operation.Width := 320;
                                                                                                                                                                                                                                                             mEd_quantity2 := TEdit.Create(mForm1);mEd_quantity2.Left := 150; mEd_quantity2.Top := 100;mEd_quantity2.Width := 80;mEd_quantity2.Name := 'mEd_quantity2';mEd_quantity2.Text:=NxFloatToIBStr(mf_doba);mForm1.InsertControl(mEd_quantity2);
                                                                                                                                                                                                                                                             mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := 'ks';mL_Technik.Top := 102;mL_Technik.Left := 240 ;mL_Technik.Height := 13;
                                                                                                                                                                                                                                                             mEd_Unitprice2:= TEdit.Create(mForm1);mEd_Unitprice2.Left := 280;mEd_Unitprice2.Top := 100;mEd_Unitprice2.Width := 80;mEd_Unitprice2.Name := 'mEd_Unitprice2';mEd_Unitprice2.Text:=NxFloatToIBStr(mf_doba);mForm1.InsertControl(mEd_Unitprice2);
                                                                                                                                                                                                                                                             mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := '  kč/j';mL_Technik.Top := 102;mL_Technik.Left := 360;mL_Technik.Height := 13;
                                                                                                                                                                                                                                                         end;
                                                                                                                                                                                                                                             }
                                                                                                                                                                                                                                                         if true then begin
                                                                                                                                                                                                                                                             mL_operation:= TLabel.Create(mForm1);mL_operation.Parent := mForm1;mL_operation.Caption := 'Pracovní doba :';mL_operation.Top := 132;mL_operation.Left := 10;mL_operation.Height := 13;mL_operation.Width := 320;
                                                                                                                                                                                                                                                             mEd_quantity3 := TEdit.Create(mForm1);mEd_quantity3.Left := 150;mEd_quantity3.Top := 130;mEd_quantity3.Width := 80; mEd_quantity3.Name := 'mFS_prace';mEd_quantity3.Text:=NxFloatToIBStr(mFS_Prace);
                                                                                                                                                                                                                                                             mForm1.InsertControl(mEd_quantity3);mL_Technik:= TLabel.Create(mForm1); mL_Technik.Parent := mForm1;mL_Technik.Caption := 'hod';mL_Technik.Top := 132;mL_Technik.Left := 240 ; mL_Technik.Height := 13;
                                                                                                                                                                                                                                                             mEd_Unitprice3:= TEdit.Create(mForm1);mEd_Unitprice3.Left := 280;mEd_Unitprice3.Top := 130;mEd_Unitprice3.Width := 80; mEd_Unitprice3.Name := 'mEd_Unitprice3';mEd_Unitprice3.Text:=NxFloatToIBStr(mFSazba_Prace);mForm1.InsertControl(mEd_Unitprice3);
                                                                                                                                                                                                                                                             mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := '  kč/j';mL_Technik.Top := 132;mL_Technik.Left := 360;mL_Technik.Height := 13;
                                                                                                                                                                                                                                                         end;

                                                                                                                                                                                                                                                         if true then begin
                                                                                                                                                                                                                                                              mL_operation:= TLabel.Create(mForm1); mL_operation.Parent := mForm1;mL_operation.Caption := 'Mimo pracovní dobu :'; mL_operation.Top := 162;mL_operation.Left := 10;mL_operation.Height := 13;mL_operation.Width := 320;
                                                                                                                                                                                                                                                              mEd_quantity4 := TEdit.Create(mForm1);mEd_quantity4.Left := 150;mEd_quantity4.Top := 160;mEd_quantity4.Width := 80;mEd_quantity4.Name := 'mEd_quantity4'; mEd_quantity4.Text:=NxFloatToIBStr(mFS_mimo);mForm1.InsertControl(mEd_quantity4);
                                                                                                                                                                                                                                                              mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := 'hod';mL_Technik.Top := 162;mL_Technik.Left := 240 ;mL_Technik.Height := 13;
                                                                                                                                                                                                                                                              mEd_Unitprice4:= TEdit.Create(mForm1);mEd_Unitprice4.Left := 280;mEd_Unitprice4.Top := 160;mEd_Unitprice4.Width := 80;mEd_Unitprice4.Name := 'mEd_Unitprice4';mEd_Unitprice4.Text:=NxFloatToIBStr(mFSazba_Mimo);mForm1.InsertControl(mEd_Unitprice4);
                                                                                                                                                                                                                                                              mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := '  kč/j';mL_Technik.Top := 162;mL_Technik.Left := 360;mL_Technik.Height := 13;
                                                                                                                                                                                                                                                         end;

                                                                                                                                                                                                                                                         if true then begin
                                                                                                                                                                                                                                                              mL_operation:= TLabel.Create(mForm1);mL_operation.Parent := mForm1;mL_operation.Caption := 'Víkend + Svátek :';mL_operation.Top := 192;mL_operation.Left := 10;mL_operation.Height := 13;mL_operation.Width := 320;
                                                                                                                                                                                                                                                              mEd_quantity5 := TEdit.Create(mForm1);mEd_quantity5.Left := 150;mEd_quantity5.Top := 190;mEd_quantity5.Width := 80;mEd_quantity5.Name := 'mEd_quantity5';mEd_quantity5.Text:=NxFloatToIBStr(mFS_Vikend);mForm1.InsertControl(mEd_quantity5);
                                                                                                                                                                                                                                                              mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := 'hod';mL_Technik.Top := 192;mL_Technik.Left := 240 ;mL_Technik.Height := 13;
                                                                                                                                                                                                                                                              mEd_Unitprice5:= TEdit.Create(mForm1);mEd_Unitprice5.Left := 280;mEd_Unitprice5.Top := 190;mEd_Unitprice5.Width := 80;mEd_Unitprice5.Name := 'mEd_Unitprice5';mEd_Unitprice5.Text:=NxFloatToIBStr(mFSazba_Vikend);mForm1.InsertControl(mEd_Unitprice5);
                                                                                                                                                                                                                                                              mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := '  kč/j';mL_Technik.Top := 192;mL_Technik.Left := 360;mL_Technik.Height := 13;
                                                                                                                                                                                                                                                         end;

                                                                                                                                                                                                                                                         if false then begin
                                                                                                                                                                                                                                                              mL_operation:= TLabel.Create(mForm1);mL_operation.Parent := mForm1;mL_operation.Caption := 'Práce paušál :';mL_operation.Top := 222;mL_operation.Left := 10;mL_operation.Height := 13;mL_operation.Width := 320;
                                                                                                                                                                                                                                                              mEd_quantity6 := TEdit.Create(mForm1);mEd_quantity6.Left := 150;mEd_quantity6.Top := 220;mEd_quantity6.Width := 80;mEd_quantity6.Name := 'mEd_quantity6';mEd_quantity6.Text:=NxFloatToIBStr(mf_doba);mForm1.InsertControl(mEd_quantity6);
                                                                                                                                                                                                                                                              mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := 'ks';mL_Technik.Top := 222;mL_Technik.Left := 240 ;mL_Technik.Height := 13;
                                                                                                                                                                                                                                                              mEd_Unitprice6:= TEdit.Create(mForm1);mEd_Unitprice6.Left := 280;mEd_Unitprice6.Top := 220;mEd_Unitprice6.Width := 80;mEd_Unitprice6.Name := 'mEd_Unitprice6';mEd_Unitprice6.Text:=NxFloatToIBStr(mf_doba);mForm1.InsertControl(mEd_Unitprice6);
                                                                                                                                                                                                                                                              mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := '  kč/j';mL_Technik.Top := 222;mL_Technik.Left := 360;mL_Technik.Height := 13;
                                                                                                                                                                                                                                                         end;

                                                                                                                                                                                                                                                         if true then begin
                                                                                                                                                                                                                                                              mL_operation:= TLabel.Create(mForm1);mL_operation.Parent := mForm1;mL_operation.Caption := 'Doprava km :';mL_operation.Top := 252;mL_operation.Left := 10;mL_operation.Height := 13;mL_operation.Width := 320;
                                                                                                                                                                                                                                                              mEd_quantity7 := TEdit.Create(mForm1);mEd_quantity7.Left := 150;mEd_quantity7.Top := 250;mEd_quantity7.Width := 80;mEd_quantity7.Name := 'mEd_quantity7';mEd_quantity7.Text:=NxFloatToIBStr(mpocet_km);mForm1.InsertControl(mEd_quantity7);
                                                                                                                                                                                                                                                              mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := 'km';mL_Technik.Top := 252;mL_Technik.Left := 240 ;mL_Technik.Height := 13;
                                                                                                                                                                                                                                                              mEd_Unitprice7:= TEdit.Create(mForm1);mEd_Unitprice7.Left := 280;mEd_Unitprice7.Top := 250;mEd_Unitprice7.Width := 80;mEd_Unitprice7.Name := 'mEd_Unitprice7';mEd_Unitprice7.Text:=NxFloatToIBStr(mFSazba_Doprava_km);mForm1.InsertControl(mEd_Unitprice7);
                                                                                                                                                                                                                                                              mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := '  kč/km';mL_Technik.Top := 252;mL_Technik.Left := 360;mL_Technik.Height := 13;
                                                                                                                                                                                                                                                         end;

                                                                                                                                                                                                                                                         if false then begin
                                                                                                                                                                                                                                                              mL_operation:= TLabel.Create(mForm1);mL_operation.Parent := mForm1;mL_operation.Caption := 'Práce paušál :';mL_operation.Top := 282;mL_operation.Left := 10;mL_operation.Height := 13;mL_operation.Width := 320;
                                                                                                                                                                                                                                                              mEd_quantity8 := TEdit.Create(mForm1);mEd_quantity8.Left := 150;mEd_quantity8.Top := 280;mEd_quantity8.Width := 80;mEd_quantity8.Name := 'mEd_quantity8';mEd_quantity8.Text:=NxFloatToIBStr(mf_doba);mForm1.InsertControl(mEd_quantity8);
                                                                                                                                                                                                                                                              mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := 'ks';mL_Technik.Top := 282;mL_Technik.Left := 240 ;mL_Technik.Height := 13;
                                                                                                                                                                                                                                                              mEd_Unitprice8:= TEdit.Create(mForm1);mEd_Unitprice8.Left := 280;mEd_Unitprice8.Top := 280;mEd_Unitprice8.Width := 80;mEd_Unitprice8.Name := 'mEd_Unitprice8';mEd_Unitprice8.Text:=NxFloatToIBStr(mf_doba);mForm1.InsertControl(mEd_Unitprice8);
                                                                                                                                                                                                                                                              mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := '  kč/j';mL_Technik.Top := 282;mL_Technik.Left := 360;mL_Technik.Height := 13;
                                                                                                                                                                                                                                                         end;

                                                                                                                                                                                                                                                         if true then begin
                                                                                                                                                                                                                                                              mL_operation:= TLabel.Create(mForm1);mL_operation.Parent := mForm1;mL_operation.Caption := 'Výjezd do 3 hodin :';mL_operation.Top := 312;mL_operation.Left := 10;mL_operation.Height := 13; mL_operation.Width := 320;
                                                                                                                                                                                                                                                              mEd_quantity9 := TEdit.Create(mForm1);mEd_quantity9.Left := 150;mEd_quantity9.Top := 310;mEd_quantity9.Width := 80;mEd_quantity9.Name := 'mEd_quantity9';mEd_quantity9.Text:=NxFloatToIBStr(0);mForm1.InsertControl(mEd_quantity9);
                                                                                                                                                                                                                                                              mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := 'ks';mL_Technik.Top := 312;mL_Technik.Left := 240 ;mL_Technik.Height := 13;
                                                                                                                                                                                                                                                              mEd_Unitprice9:= TEdit.Create(mForm1);mEd_Unitprice9.Left := 280;mEd_Unitprice9.Top := 310;mEd_Unitprice9.Width := 80;mEd_Unitprice9.Name := 'mEd_Unitprice9';mEd_Unitprice9.Text:=NxFloatToIBStr(mFPriplatek3H);mForm1.InsertControl(mEd_Unitprice9);
                                                                                                                                                                                                                                                              mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := '  kč/j';mL_Technik.Top := 312;mL_Technik.Left := 360;mL_Technik.Height := 13;
                                                                                                                                                                                                                                                         end;
                                                                                                                                                                                                                                                        mBtn := TButton.Create(mForm1);mBtn.Width := 75;mBtn.Height := 25;mBtn.Caption := 'OK';mBtn.ModalResult := mrOk;mBtn.Cancel := False;mBtn.Default := True;mBtn.Left :=  mForm1.Width - 2*(mBtn.Width+2) - 20;mBtn.Top := mForm1.Height - mBtn.Height - 40;mBtn.Name := 'btnOK';mForm1.InsertControl(mBtn);
                                                                                                                                                                                                                                                        mBtn := TButton.Create(mForm1);mBtn.Width := 75;mBtn.Height := 25;mBtn.Caption := 'Storno';mBtn.ModalResult := mrCancel;mBtn.Cancel := True;mBtn.Left := mForm1.Width - (mBtn.Width+2) - 20;mBtn.Top := mForm1.Height - mBtn.Height - 40;mBtn.Name := 'btnCancel';mForm1.InsertControl(mBtn);

                                                                                                                                                                                                                                                        if mForm1.ShowModal(xSite) = mrOK then begin
                                                                                                                                                                                                                                                              mB_pokracovat:=true;
                                                                                                                                                                                                                                                              if NxIBStrToFloat(mEd_quantity.text)>0 then begin
                                                                                                                                                                                                                                                                          mNewRow := mRows_ML.AddNewObject;mNewRow.SetFieldValueAsInteger('Posindex',i+55);mNewRow.SetFieldValueAsInteger('itemtype',0);mNewRow.SetFieldValueAsString('WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('X_WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('Text','Paušál práce');mNewRow.SetFieldValueAsString('Store_id',mStore);mNewRow.SetFieldValueAsString('StoreCard_id','1ZI1000101');mNewRow.SetFieldValueAsfloat('WorkHoursPlanned',NxIBStrToFloat(mEd_quantity.text));mNewRow.SetFieldValueAsfloat('WorkHoursReal',NxIBStrToFloat(mEd_quantity.text));mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',NxIBStrToFloat(mEd_Unitprice.Text));mNewRow.SetFieldValueAsfloat('X_radkova_sleva',0);mNewRow.SetFieldValueAsDateTime('X_konec_prace',mDateto);
                                                                                                                                                                                                                                                                          mNewRow.SetFieldValueAsBoolean('X_Pohotovost',mRow_Pomoc.getFieldValueAsBoolean('X_Pohotovost'));//mNewRow.Save;mNewRow.free;
                                                                                                                                                                                                                                                                      end;
                                                                                                                                                                                                                                                                      if NxIBStrToFloat(mEd_quantity1.text)>0 then begin
                                                                                                                                                                                                                                                                          mNewRow := mRows_ML.AddNewObject;mNewRow.SetFieldValueAsInteger('Posindex',i+60);mNewRow.SetFieldValueAsInteger('itemtype',0);mNewRow.SetFieldValueAsString('WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('X_WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('Text','Paušál doprava');mNewRow.SetFieldValueAsString('Store_id',mStore);mNewRow.SetFieldValueAsBoolean('X_Pohotovost',mRow_Pomoc.getFieldValueAsBoolean('X_Pohotovost'));mNewRow.SetFieldValueAsString('StoreCard_id','1FD1000101');mNewRow.SetFieldValueAsfloat('WorkHoursPlanned',NxIBStrToFloat(mEd_quantity1.text));mNewRow.SetFieldValueAsfloat('WorkHoursReal',NxIBStrToFloat(mEd_quantity1.text));mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',NxIBStrToFloat(mEd_Unitprice1.Text));mNewRow.SetFieldValueAsfloat('X_radkova_sleva',0);
                                                                                                                                                                                                                                                                          mNewRow.SetFieldValueAsDateTime('X_konec_prace',mDateto);//mNewRow.Save;mNewRow.free;
                                                                                                                                                                                                                                                                      end;

                                                                                                                                                                                                                                                                      if NxIBStrToFloat(mEd_quantity.Text)=0 then begin
                                                                                                                                                                                                                                                                                if NxIBStrToFloat(mEd_quantity3.text)>0 then begin
                                                                                                                                                                                                                                                                                        mNewRow := mRows_ML.AddNewObject; mNewRow.SetFieldValueAsInteger('Posindex',i+65);mNewRow.SetFieldValueAsInteger('itemtype',0); mNewRow.SetFieldValueAsString('WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('X_WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('Text','Práce Pracovní doba');mNewRow.SetFieldValueAsString('Store_id',mStore);mNewRow.SetFieldValueAsString('StoreCard_id','17T0000101');mNewRow.SetFieldValueAsBoolean('X_Pohotovost',mRow_Pomoc.getFieldValueAsBoolean('X_Pohotovost'));mNewRow.SetFieldValueAsfloat('WorkHoursPlanned',NxIBStrToFloat(mEd_quantity3.text));mNewRow.SetFieldValueAsfloat('WorkHoursReal',NxIBStrToFloat(mEd_quantity3.text));mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',NxIBStrToFloat(mEd_Unitprice3.Text));mNewRow.SetFieldValueAsfloat('X_radkova_sleva',msleva);
                                                                                                                                                                                                                                                                                        mNewRow.SetFieldValueAsDateTime('X_konec_prace',mDateto);//mNewRow.Save;mNewRow.free;
                                                                                                                                                                                                                                                                                    end;
                                                                                                                                                                                                                                                                                    if NxIBStrToFloat(mEd_quantity4.text)>0 then begin
                                                                                                                                                                                                                                                                                        mNewRow := mRows_ML.AddNewObject;mNewRow.SetFieldValueAsInteger('Posindex',i+70);mNewRow.SetFieldValueAsInteger('itemtype',0); mNewRow.SetFieldValueAsString('WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('X_WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('Text','Práce mimo pracovní dobu');mNewRow.SetFieldValueAsString('Store_id',mStore);mNewRow.SetFieldValueAsString('StoreCard_id','17T0000101');mNewRow.SetFieldValueAsBoolean('X_Pohotovost',mRow_Pomoc.getFieldValueAsBoolean('X_Pohotovost'));mNewRow.SetFieldValueAsfloat('WorkHoursPlanned',NxIBStrToFloat(mEd_quantity4.text));mNewRow.SetFieldValueAsfloat('WorkHoursReal',NxIBStrToFloat(mEd_quantity4.text));mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',NxIBStrToFloat(mEd_Unitprice4.Text));mNewRow.SetFieldValueAsfloat('X_radkova_sleva',msleva);
                                                                                                                                                                                                                                                                                        mNewRow.SetFieldValueAsDateTime('X_konec_prace',mDateto);//mNewRow.Save;mNewRow.free;
                                                                                                                                                                                                                                                                                    end;
                                                                                                                                                                                                                                                                                    if NxIBStrToFloat(mEd_quantity5.text)>0 then begin
                                                                                                                                                                                                                                                                                        mNewRow := mRows_ML.AddNewObject;mNewRow.SetFieldValueAsInteger('itemtype',0);  mNewRow.SetFieldValueAsInteger('Posindex',i+75);mNewRow.SetFieldValueAsString('WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('X_WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('Text','Práce o víkendu+ svátek');mNewRow.SetFieldValueAsString('Store_id',mStore); mNewRow.SetFieldValueAsString('StoreCard_id','17T0000101');mNewRow.SetFieldValueAsfloat('WorkHoursPlanned',NxIBStrToFloat(mEd_quantity5.text));mNewRow.SetFieldValueAsfloat('WorkHoursReal',NxIBStrToFloat(mEd_quantity5.text));mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',NxIBStrToFloat(mEd_Unitprice5.Text));mNewRow.SetFieldValueAsfloat('X_radkova_sleva',msleva); mNewRow.SetFieldValueAsBoolean('X_Pohotovost',mRow_Pomoc.getFieldValueAsBoolean('X_Pohotovost'));
                                                                                                                                                                                                                                                                                        mNewRow.SetFieldValueAsDateTime('X_konec_prace',mDateto);//mNewRow.Save;mNewRow.free;
                                                                                                                                                                                                                                                                                    end;
                                                                                                                                                                                                                                                                      end;
                                                                                                                                                                                                                                                                      if NxIBStrToFloat(mEd_quantity7.text)>0 then begin
                                                                                                                                                                                                                                                                          mNewRow := mRows_ML.AddNewObject;mNewRow.SetFieldValueAsInteger('itemtype',0); mNewRow.SetFieldValueAsInteger('Posindex',i+80);mNewRow.SetFieldValueAsString('WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('X_WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('Store_id',mStore); mNewRow.SetFieldValueAsString('StoreCard_id','54W0000101');mNewRow.SetFieldValueAsfloat('WorkHoursPlanned',NxIBStrToFloat(mEd_quantity7.text));mNewRow.SetFieldValueAsfloat('WorkHoursReal',NxIBStrToFloat(mEd_quantity7.text));mNewRow.SetFieldValueAsfloat('X_radkova_sleva',0);mNewRow.SetFieldValueAsBoolean('X_Pohotovost',mRow_Pomoc.getFieldValueAsBoolean('X_Pohotovost'));if NxIBStrToFloat(mEd_quantity1.text)=0 then begin mNewRow.SetFieldValueAsString('Text','Doprava km');
                                                                                                                                                                                                                                                                          mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',NxIBStrToFloat(mEd_Unitprice7.Text));end else begin mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',0);mNewRow.SetFieldValueAsString('Text','Doprava km (evidenční)');mNewRow.SetFieldValueAsfloat('ToInvoiceType',1);end;mNewRow.SetFieldValueAsDateTime('X_konec_prace',mDateto);
                                                                                                                                                                                                                                                                          //mNewRow.Save;mNewRow.free;
                                                                                                                                                                                                                                                                      end;
                                                                                                                                                                                                                                                                      if NxIBStrToFloat(mEd_quantity9.text)>0 then begin
                                                                                                                                                                                                                                                                          mNewRow := mRows_ML.AddNewObject;mNewRow.SetFieldValueAsInteger('Posindex',i+85);mNewRow.SetFieldValueAsInteger('itemtype',4); mNewRow.SetFieldValueAsString('WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('X_WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsBoolean('X_Pohotovost',mRow_Pomoc.getFieldValueAsBoolean('X_Pohotovost'));mNewRow.SetFieldValueAsfloat('Quantity',NxIBStrToFloat(mEd_quantity9.text));mNewRow.SetFieldValueAsfloat('X_radkova_sleva',0);if NxIBStrToFloat(mEd_quantity9.text)=0 then begin mNewRow.SetFieldValueAsString('Text','Výjezd příplatek');mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',NxIBStrToFloat(mEd_Unitprice9.Text));
                                                                                                                                                                                                                                                                          mNewRow.SetFieldValueAsfloat('ToInvoiceType',1);end else begin mNewRow.SetFieldValueAsString('Text','Výjezd příplatek');
                                                                                                                                                                                                                                                                          mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',NxIBStrToFloat(mEd_Unitprice9.Text));mNewRow.SetFieldValueAsfloat('ToInvoiceType',0);end;mNewRow.SetFieldValueAsDateTime('X_konec_prace',mDateto);
                                                                                                                                                                                                                                                                          //mNewRow.Save;mNewRow.free;
                                                                                                                                                                                                                                                                      end;
                                                                                                                                                                                                                                                        end else begin
                                                                                                                                                                                                                                                           mB_pokracovat:=false;

                                                                                                                                                                                                                                                              end; // tlačítko ok
                                                                                                                                                                                                                                                finally
                                                                                                                                                                                                                                                    mForm1.free;
                                                                                                                                                                                                                                                end;
                                                                                                                                                                                                                                 end else begin         // záruka
                                                                                                                                                                                                                                 {mNewRow := mRows_ML.AddNewObject;mNewRow.SetFieldValueAsFloat('WorkHoursReal',0);mNewRow.SetFieldValueAsinteger('itemtype',4);mNewRow.SetFieldValueAsString('WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('X_WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsinteger('ToInvoiceType',1);mNewRow.SetFieldValueAsString('Text','Práce - evidenční pro mzdy');mNewRow.SetFieldValueAsFloat('Quantity',mquantity);mNewRow.SetFieldValueAsString('Qunit','hod');mNewRow.SetFieldValueAsFloat('QuantityDelivered',mquantity);mNewRow.SetFieldValueAsBoolean('X_storno',true);mNewRow.SetFieldValueAsFloat('UnitPriceWithVAT',0);mNewRow.SetFieldValueAsFloat('UnitPriceWithoutVAT',0);mNewRow.SetFieldValueAsString('Store_id',mRow_Pomoc.GetFieldValueAsString('Store_id'));mNewRow.SetFieldValueAsString('StoreCard_id',mRow_Pomoc.GetFieldValueAsString('StoreCard_id'));mNewRow.SetFieldValueAsfloat('WorkHoursPlanned',mpocet_km);mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',0);mNewRow.SetFieldValueAsDateTime('X_konec_prace',mDateto);mNewRow.Save;mNewRow.free;


                                                                                                                                                                                                                                                                      if (mpocet_km)>0 then begin
                                                                                                                                                                                                                                                                          mNewRow := mRows_ML.AddNewObject;mNewRow.SetFieldValueAsInteger('itemtype',0); mNewRow.SetFieldValueAsString('WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('X_WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('Store_id',mStore);mNewRow.SetFieldValueAsString('StoreCard_id','54W0000101');mNewRow.SetFieldValueAsfloat('WorkHoursPlanned',mpocet_km);mNewRow.SetFieldValueAsfloat('WorkHoursReal',mpocet_km);mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',0);mNewRow.SetFieldValueAsString('Text','Doprava km (evidenční)');mNewRow.SetFieldValueAsfloat('ToInvoiceType',1);mNewRow.SetFieldValueAsDateTime('X_konec_prace',mDateto);mNewRow.free;
                                                                                                                                                                                                                                                                      end; }
                                                                                                                                                                                                                                 end;                   // záruka


                                                                                                                                                                                                                            end;   // zadání odpracované doby



                                                                                                                                                                                                  end;  // end for list

                                                                                                                                                                                              finally
                                                                                                                                                                                                  mList_pomoc.free;
                                                                                                                                                                                              end;
                                                                                                                                                                                   end;   //paušál
                                                                                                                                                                             if mB_pokracovat then begin
                                                                                                                                                                                mBO_ML.SetFieldValueAsstring('X_State','3Q22000101');
                                                                                                                                                                                mBO_ML.SetFieldValueAsinteger('AssemblyState',1);
                                                                                                                                                                                mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' +QuotedStr(mBO_ML.getFieldValueAsString('X_state.X_field1'))+ ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                                                                                                                                                             end;
                                                                                                                                                                             end ;  // není fakturován

                                                                                                                                                              end; // datum pro fakturaci

                                                                                                                                             end;   // není zadán technik


                                                                                                                                             // zadání materiálu
                                                                                                                                            // if (mIDs_Storecard.count=0) and mResult_mat then begin
                                                                                                                                            //            mResult_mat:=GetCheck(Sender,xSite,'Chcete zadat materiál','Zadat materiál','Pokračovat') ;
                                                                                                                                            //            if mResult_mat then begin
                                                                                                                                            //
                                                                                                                                            //            mBO_ML.SetFieldValueAsstring('X_State','45W1000101');
                                                                                                                                            //            mBO_ML.SetFieldValueAsinteger('AssemblyState',1);
                                                                                                                                            //            end;
                                                                                                                                            // end;


                                                                                                                                         mID_ML:=mBO_ML.oid;
                                                                                                                                         if mB_pokracovat then begin
                                                                                                                                             mBO_ML.Save;
                                                                                                                                         end else begin
                                                                                                                                             NxShowSimpleMessage('Operace byla přerušena',xSite);
                                                                                                                                         end;
                                                                                                                                         mBO_ML.Refresh;
                                                                                                                                         finally
                                                                                                                                            mBO_ML.free;
                                                                                                                                         end;
                                                                                                                                     end;

                                                                                                                           finally
                                                                                                                                    mIDs_ML.free;
                                                                                                                           end;
                                                                                                            finally
                                                                                                               mbo_SL.free;
                                                                                                            end;
                                                                                              end;          // pro více SP
                                                                                          finally
                                                                                             mIDs_Storecard.Free;
                                                                                             mIDs_SP.free;
                                                                                             mIDs_WorkerRole.Free;
                                                                                          end;
                                                                                          //mBO_ML.Load(mid_ml,nil);
                                                                                          //try
                                                                                          //    mbo_ml.Save;
                                                                                          //    mbo_ml.Refresh;
                                                                                          //    mdbgrid.Refresh;
                                                                                          //xsite.RefreshData;
                                                                                          //xsite.ActiveDataSet.seekid(mID_ML);
                                                                                          //xsite.ActiveDataSet.RefreshAndRestoreLastSelectedItem;
                                                                                          //finally
                                                                                          //
                                                                                          //end;



                                                              end;
                                                        {      if index=1 then begin
                                                                      mD_SL_start:= date ;
                                                                      mD_SL_End:=mD_SL_start+1;
                                                                      try
                                                                      mBONew_SL:=xsite.BaseObjectSpace.CreateObject('BCHF52UGXCO4H5MIAQVY5P3ZOC');
                                                                            mBONew_SL.New;
                                                                            mBONew_SL.Prefill;
                                                                            mboNew_SL.SetFieldValueAsDateTime('DocDate$DATE',mD_SL_start);
                                                                            mboNew_SL.SetFieldValueAsDateTime('PromisedDeadLine$DATE', mD_SL_End);
                                                                            mboNew_SL.SetFieldValueAsstring('Division_ID',mboNew_SL.getFieldValueAsstring('CreatedBy_ID.X_division_ID'));


                                                                            xSite.ShowDynFormWithNewDocument('NHT5Z3GSFFQ4F024JRFLUNOS30', xSite.SiteContext, mBONew_SL);
                                                                            mID_SL:=mBONew_SL.oid;

                                                                            finally
                                                                               mBONew_SL.free;
                                                                            end;


                                                              end;  }


                                                                  if index=1 then begin
                                                                          mD_SL_start:= GetDate(Sender,xSite) ;
                                                                          mD_SL_End:=mD_SL_start+1;
                                                                      //  montážní list
                                                                            mbo_SL:=mBO.ObjectSpace.CreateObject('BCHF52UGXCO4H5MIAQVY5P3ZOC');
                                                                                 try
                                                                                      mbo_sl.Load(mbo.GetFieldValueAsString('ServiceDocument_ID'),nil) ;  // použití již existujícího SL

                                                                                           if nxisblank(mid_workSpace) then begin
                                                                                                  mr:=TStringList.Create;
                                                                                                  try
                                                                                                     mbo.objectspace.SQLSelect('select id from ServiceWorkSpaces where code=' + QuotedStr(mbo.GetFieldValueAsString('Servicedocument_ID.Division_ID.code')),mr);
                                                                                                              if mr.count>0 then mid_workSpace:=mr.Strings[0];
                                                                                                  finally
                                                                                                      mr.free;
                                                                                                  end;
                                                                                               end;

                                                                                               if nxisblank(mid_workerRole) then begin
                                                                                                  mr:=TStringList.Create;
                                                                                                  try
                                                                                                    mbo.ObjectSpace.SQLSelect('select id from SecurityRoles where ShortName=' + QuotedStr(mbo.GetFieldValueAsString('Servicedocument_ID.Division_ID.code')),mr);
                                                                                                    if mr.count>0 then begin
                                                                                                        mid_workerRole:=mr.Strings[0]
                                                                                                    end;
                                                                                                  finally
                                                                                                      mr.free;
                                                                                                  end;
                                                                                                end;
                                                                                                // založení nového ML


                                                                                                mID_ML:=Novy_ML(mBO_SL,mid_workSpace,mid_workerRole,mD_SL_start,mD_SL_End);
                                                                                     finally
                                                                                        mbo_sl.free;
                                                                                     end;



                                                          end;


                            finally
                                mr.free;
                                mbo.free;
                            end;
                        end;
               finally
                 mbo_CRM_activities.free;
               end;
            end;
  finally
    l.free;
  end;
end;






begin
end.