  uses 'abra.eu.mask.function_libs.VisualForms';


procedure InitSite_Hook(Self: TSiteForm);
var
mAction: TAction;
  mMAction,mMAction1: TMultiAction;
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

    mMAction1 := Self.GetNewMultiAction;
  mMAction1.ShowControl := True;
  mMAction1.ShowMenuItem := True;
  mMAction1.Caption := 'xxEditace dokladu';
  mMAction1.Hint := 'xxxPráce s dokladem';
  mMAction1.Category := 'tabList';
  mMAction1.OnExecuteItem := @EDITSLExecuteItem;
  mMAction1.Items.Add('Zadání technika');

end;





  procedure EDITSLExecuteItem(Sender: Tcomponent; Index: integer);
 var
 xSite: TDynSiteForm;
mDBGrid : TDBGrid;
mTabList: TTabSheet;
mBookmark : TBookmarkList;
 mBO:TNxCustomBusinessObject;
 i:integer;
 mrow:TNxCustomBusinessObject;
 mI_ML:integer;
 mform:TForm;
 result:integer;
 resSettingsSubject:string;
 a: TLabel;
 b:TEdit;
 msloupec1,msloupec2,msloupec3,msloupec4,msloupec5:integer;
 mradek1,mradek2,mradek3,mradek4,mradek5,mradek6,mradek7:integer;
 begin
    xSite := TComponent(Sender).DynSite;
    mBO:=TDynSiteForm(xSite).CurrentObject;
    mTabList := TTabSheet(NxFindChildControl(xSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu



  //  if mBookmark.count=0 then begin
                   mform:=CreateFormDialog('mform', 'Servis',XSite, 1024, 800);
                        msloupec1:=10;
                        mradek1:=10;
                        mradek3:=350;
                        mradek4:=430;
                        mradek5:=520;
                        mradek6:=580;
                        mradek7:=650;
                        msloupec1:=0;
                        msloupec2:=300;
                        msloupec3:=600;
                        //CreateHeadPanel('SP', 'Servisovaný předmět',mForm, 0, 0,50,50,True,True,pcWizardWhite,22,[fsBold],pcWizardWhite)  ;
                                           CreateLabel('SP_label','Předmět',mform,msloupec1+5, 5, -1, -1, true ,true,10, [fsBold],255);

                                  //         CreateNxComboAdresEdit('Firm_id','Umisteni',mform,msloupec1+5, 30, 300, 300,
                                  //                                                            50, 100,
                                  //                                                            'O3OWQQYWYJCL3J0B01K0LEIOE0', 'Code', 'NAme', 'ID',
                                  //                                                            '','',
                                  //                                                            true,true,
                                  //                                                            22,[fsBold],255);
                        mradek2:=150;

                        //CreateHeadPanel('SD', 'Servisovaný předmět',mForm, 0, mradek2,0,150,True,True,pcWizardWhite,22,[fsBold],pcWizardWhite)  ;
                                           CreateLabel('SD_label','Servisní list:',mform,msloupec1+5, mradek2+5, -1, -1, true ,true,20, [fsBold],255);
                                           CreateLabel('SD_Docnumber',mbo.GetFieldValueAsString('servicedocument_ID.docqueue_ID.code') + '-' +  inttostr(mbo.GetFieldValueAsInteger('servicedocument_ID.ordnumber')) +'/' + mbo.GetFieldValueAsString('servicedocument_ID.Period_ID.code')
                                           ,mform,msloupec1 + 200, mradek2+5, -1, -1, true ,true,20, [fsBold],255);
                                           CreateDateTimeEdit('SLdate_od','Nahlášeno:',mform, msloupec3 , mradek2, 80, 80, 40, trunc(now),true,true, 10, [fsBold],255, true);
                                           CreateDateTimeEdit('SLdate_do','Opravit do:',mform, msloupec3+90 , mradek2, 80, 80, 40, trunc(now),true,true, 10, [fsBold],255, true);


                        //CreateHeadPanel('ML', 'Servisovaný předmět',mForm, 0, mradek3,0,150,True,True,pcWizardWhite,22,[fsBold],pcWizardWhite)  ;
                                           CreateLabel('ML_label','Výjezd',mform,msloupec1, mradek3+5, -1, -1, true ,true,20, [fsBold],255);
                                           CreateLabel('ML_Docnumber',mbo.GetFieldValueAsString('servicedocument_ID.docqueue_ID.code') + '-' +  inttostr(mbo.GetFieldValueAsInteger('servicedocument_ID.ordnumber')) +'/' + mbo.GetFieldValueAsString('servicedocument_ID.Period_ID.code') + '-' + inttostr(mbo.GetFieldValueAsInteger('ordnumber'))
                                                       ,mform,msloupec1 + 200, mradek3+5, -1, -1, true ,true,20, [fsBold],255);
                                           CreateDateTimeEdit('MLdate_do','Datum:',mform, msloupec3 , mradek3, 80, 80, 40, trunc(now),true,true, 10, [fsBold],255, true);
                                           CreateTimeEdit('MLtime_od','čas od:',mform,msloupec3 +90, mradek3, 80, 80, 40,frac(now),true,true, 10, [fsBold],255, true);
                                           CreateTimeEdit('MLtime_Do','čas do:',mform,msloupec3 + 180, mradek3,80 , 80, 40,frac(now),true,true, 10, [fsBold],255, true);

                                           CreateEdit('ML_protokol_prefix', 'Protokol',mform, msloupec1, mradek3+45, 70, 30,50, 'P',false,true,true,10, [fsBold],255) ;
                                           CreateEdit('ML_protokol', '',mform, msloupec1+20, mradek3+45, 100, 25,50, '784511',false,true,true,10, [fsBold],255) ;

                                           CreateEdit('ML_zavada', 'Závada',mform, msloupec2, mradek3+45, 150, 50,100, '51656r6516',false,true,true,10, [fsBold],255) ;
                                           CreateEdit('ML_cyklu', 'Počet cyklů',mform, msloupec3, mradek3+45, 150, 50,100, '155455',false,true,true,10, [fsBold],255) ;

                                           CreateLabel('ML_P_ev','Práce evidenční',mform,msloupec1, mradek4, -1, -1, true ,true,14, [fsBold],255);
                                              CreateNxComboEdit('ML_P_ev_T_1', 'Technik',mform, msloupec1,mradek4+20,150,25,40,0,'0FKKTBSSQKB4B3RLYBSJFFAFUW','Name','','ID','','');
                                              CreateDateTimeEdit('ML_P_ev_T1_date_do','Ukončeni',mform, msloupec1+160 , mradek4+20, 130, 40, 50, trunc(now),true,true, 10, [fsBold],255, false);
                                              CreateTimeEdit('ML_P_ev_T1_time_Do',':',mform,msloupec1 + 300, mradek4+20,50 , 80, 0,frac(now),true,true, 10, [fsBold],255, false);
                                              CreateEdit('ML_P_ev_T_1_plan', 'Plán',mform, msloupec1+350,mradek4+20,90,25,50,'1',false,true,true,10, [fsBold],255) ;
                                              CreateEdit('ML_P_ev_T_1_real', 'Real',mform, msloupec1+420,mradek4+20,90,25,50,'1',false,true,true,10, [fsBold],255) ;


                                           CreateLabel('ML_P_f','Práce fakturační',mform,msloupec3, mradek4, -1, -1, true ,true,14, [fsBold],255);



                                           // text
                                           CreateLabel('ML_text','Text',mform,msloupec1, mradek5, -1, -1, true ,true,14, [fsBold],255);
                                                CreateEdit('ML_text_text', 'Text',mform, msloupec1,mradek5+20,450,25,50,'1,0',false,true,true,10, [fsBold],255) ;

                                                    CreateEdit('ML_text_Q_1', 'Množství',mform, msloupec1+500,mradek5+20,90,25,50,'1,0',false,true,true,10, [fsBold],255) ;
                                                    CreateEdit('ML_text_JC_1', 'Cena/j',mform, msloupec1+600,mradek5+20,90,25,50,'1,0',false,true,true,10, [fsBold],255) ;
                                                    CreateEdit('ML_text_SL_1', 'Sleva %',mform, msloupec1+700,mradek5+20,90,25,50,'1,0',false,true,true,10, [fsBold],255) ;
                                                    CreateCheckBox('ML_text_F_1', 'Fakturovat',mform, msloupec1+800,mradek5+20,90,25,True);
                                                    createCheckBox('ML_text_ST_1', 'Storno',mform, msloupec1+880,mradek5+20,90,25,True);
                                                    CreateEdit('ML_text_Poz_1', 'Poznamka',mform, msloupec1,mradek5+45,800,25,50,'',false,true,true,10, [fsBold],255) ;
                                                    CreateNxComboEdit('ML_text_DO_1', 'Dodavatel',mform, msloupec1+800,mradek5+45,200,25,50,80,'O3OWQQYWYJCL3J0B01K0LEIOE0','Name','Code','ID','','');
                                           // materiál
                                           CreateLabel('ML_mat','Materiál',mform,msloupec1, mradek6, -1, -1, true ,true,14, [fsBold],255);

                                                CreateNxComboEdit('ML_M_Sk_1', 'Sklad',mform, msloupec1,mradek6+20,120,25,40,0,'O3ZO2K155FDL3CL100C4RHECN0','Name','Code','ID','','');
                                                    CreateNxComboEdit('ML_M_SC_1', 'Karta',mform, msloupec1+120,mradek6+20,250,25,50,80,'S3WZQKDB5FDL342M01C0CX3FCC','Code','name','ID','','');
                                                    CreateEdit('ML_M_Q_1', 'Množství',mform, msloupec1+500,mradek6+20,90,25,50,'1,0',false,true,true,10, [fsBold],255) ;
                                                    CreateEdit('ML_M_JC_1', 'Cena/j',mform, msloupec1+600,mradek6+20,90,25,50,'1,0',false,true,true,10, [fsBold],255) ;
                                                    CreateEdit('ML_M_SL_1', 'Sleva %',mform, msloupec1+700,mradek6+20,90,25,50,'1,0',false,true,true,10, [fsBold],255) ;
                                                    CreateCheckBox('ML_M_F_1', 'Fakturovat',mform, msloupec1+800,mradek6+20,90,25,True);
                                                    createCheckBox('ML_M_ST_1', 'Storno',mform, msloupec1+880,mradek6+20,90,25,True);
                                                    CreateEdit('ML_M_Poz_1', 'Poznamka',mform, msloupec1,mradek6+45,800,25,50,'',false,true,true,10, [fsBold],255) ;

                                                CreateNxComboEdit('ML_M_Sk_2', 'Sklad',mform, msloupec1,mradek6+70,120,25,40,0,'O3ZO2K155FDL3CL100C4RHECN0','Name','Code','ID','','');
                                                    CreateNxComboEdit('ML_M_SC_2', 'Karta',mform, msloupec1+120,mradek6+70,250,25,50,80,'S3WZQKDB5FDL342M01C0CX3FCC','Code','name','ID','','');
                                                    CreateEdit('ML_M_Q_2', 'Množství',mform, msloupec1+500,mradek6+70,90,25,50,'1,0',false,true,true,10, [fsBold],255) ;
                                                    CreateEdit('ML_M_JC_2', 'Cena/j',mform, msloupec1+600,mradek6+70,90,25,50,'1,0',false,true,true,10, [fsBold],255) ;
                                                    CreateEdit('ML_M_SL_2', 'Sleva %',mform, msloupec1+700,mradek6+70,90,25,50,'1,0',false,true,true,10, [fsBold],255) ;
                                                    CreateCheckBox('ML_M_F_2', 'Fakturovat',mform, msloupec1+800,mradek6+70,90,25,True);
                                                    createCheckBox('ML_M_ST_2', 'Storno',mform, msloupec1+880,mradek6+70,90,25,True);
                                                    CreateEdit('ML_M_Poz_2', 'Poznamka',mform, msloupec1,mradek6+95,800,25,50,'',false,true,true,10, [fsBold],255) ;

                                                CreateNxComboEdit('ML_M_Sk_3', 'Sklad',mform, msloupec1,mradek6+70,120,25,40,0,'O3ZO2K155FDL3CL100C4RHECN0','Name','Code','ID','','');
                                                    CreateNxComboEdit('ML_M_SC_3', 'Karta',mform, msloupec1+120,mradek6+120,250,25,50,80,'S3WZQKDB5FDL342M01C0CX3FCC','Code','name','ID','','');
                                                    CreateEdit('ML_M_Q_3', 'Množství',mform, msloupec1+500,mradek6+120,90,25,50,'1,0',false,true,true,10, [fsBold],255) ;
                                                    CreateEdit('ML_M_JC_3', 'Cena/j',mform, msloupec1+600,mradek6+120,90,25,50,'1,0',false,true,true,10, [fsBold],255) ;
                                                    CreateEdit('ML_M_SL_3', 'Sleva %',mform, msloupec1+700,mradek6+120,90,25,50,'1,0',false,true,true,10, [fsBold],255) ;
                                                    CreateCheckBox('ML_M_F_3', 'Fakturovat',mform, msloupec1+800,mradek6+120,90,25,True);
                                                    createCheckBox('ML_M_ST_3', 'Storno',mform, msloupec1+880,mradek6+120,90,25,True);
                                                    CreateEdit('ML_M_Poz_3', 'Poznamka',mform, msloupec1,mradek6+145,800,25,50,'',false,true,true,10, [fsBold],255) ;



                    //    CreateLabel('SP', 'Servisovaný předmět', 40, 40, 20,10,[fsBold],mform);
                        //CreateLabel('SPaa', 'Caption', 20, 10, 50, 10, [fsBold],mform);


                        //CreateEdit('dname', 'Caption', 10, 80, 80, 10, 'AAAA',mform,false);






                       // CreateDateEdit('mdatetime', 'datum čas', 10, 150, 80, 10, Now, mform,true);
                       // CreatetimeEdit('mtime', 'Čas', 250, 150, 80, 10, frac(Now), mform,true);
                      //  CreateCheckBox('mCheck', 'kontrola', true,10, 200, 80, 10,mform);
                      //  CreateComboBox('mcombobox', 'combobox', 10, 250, 80, 10,'AAAA', 'AAAA' ,mform);

                  //mLblDateFrom1 := CreateDateEdit('ETDateFrom1', '1. období:', 20, 90, 170, 70, nil, mForm);
                 // mLblDateTo1 := CreateDateEdit('ETDateTo1', '—', 200, 90, 110, 15, nil, mForm);
                 // mLblDateFrom2 := CreateDateEdit('ETDateFrom2', '2. období:', 20, 120, 170, 70, nil, mForm);
                 // mLblDateTo2 := CreateDateEdit('ETDateTo2', '—', 200, 120, 110, 15, nil, mForm);
              //        CreateLabel('lblLicence', '?', 280, 315, -1, mPage{mGrb});

             // CreateMemo('AlreadyBeenProcessed', 'AAAAAA', '', 10, 20, 150, 45, -1, mform, True);

              //    CreateCheckBox('CanEditII', resSettingsCanEditII, False, 10, 85, 50, mPage{mGrb});
              //CreateNxComboEdit('PDMDocQueue_ID', 'AAAA', 10, 80, 80, 10,150,'W2XNBCJK3ZD13ACL03KIU0CLP4', 'Code', 'Name','ID',  mform,'FilterDocumentType=P0','');
              //CreateNxComboAdresEdit('Storecard_ID', 'Skladová karta:', 10, 10, 350,50,100,120,150,'S3WZQKDB5FDL342M01C0CX3FCC', 'Code', 'Name', 'ID', mForm) ;
              //CreateNxComboAdresEdit('Storecard_ID', 'Skladová karta:', 10, 10, 350,50,100,'S3WZQKDB5FDL342M01C0CX3FCC', 'Code', 'Name', 'ID', mForm) ;


              //CreateNxComboDateEdit('Storecarda_ID', 'Skladová karta:', 400, 10, 350,120,150,120,150,'S3WZQKDB5FDL342M01C0CX3FCC', 'Code', 'Name', 'ID', mForm) ;
                 //  CreateNxComboEdit('PDMDocQueue_ID', 'AAAA', 'W2XNBCJK3ZD13ACL03KIU0CLP4', 'Code', 'Name', '', 10, 110, 490, 130, 310, mform, 'FilterDocumentType=P0');


              //    CreateNxComboEdit('PDMProvider_ID', resSettingsPDMProvider, 'IWIOZEFV3ZKOF1B5IQVYHLVBFK', 'Code', 'Name', '', 10, 140, 490, 130, 310, mPage{mGrb}, '');

              //    CreateComboBox('PrinterAll', resSettingsPrinterAll, '', Printer.Printers.Text, 10, 205, 460, 190, mPage{mGrb});

              //   CreateNumEdit('Postage', resSettingsPostage, '', 10, 235, 180, 130, mPage{mGrb});

              //    CreateEdit('Subject', resSettingsSubject, '', 10, 20, 200, 85, mform);
              //    CreateBevel('', 10, 340, 460, 5, bsTopLine, mPage);
              //    CreateCheckBox('AttachDocumentFromIIToMail', resAttachDocumentFromIIToMail, False, 10, 350, 460, mform);
              //    CreateNxComboEdit('DocumentDocQueueFromIIToMailID', resDocumentDocQueueFromIIToMailID, 'W2XNBCJK3ZD13ACL03KIU0CLP4', 'Code', 'Name', '', 10, 370, 715, 205, 460, mPage{mGrb}, 'FilterDocumentType=DO');
              //    CreateEdit('LinkedFilePath', resLinkedFilePath, '', 10, 400, 460, 205, mPage{mGrb});
              //CreateButton('ETnab', 'Cenova nabídka', 1, 1, 770, 80, 25, true, mForm);
              //CreateButton('ETtech', 'Technik', 2, 80, 770, 80, 25, true, mForm);
              //CreateButton('ETcen', 'Ceny', 3, 160, 770, 80, 25, true, mForm);
              //CreateButton('ETmat', 'Materiál', 4, 240, 770, 80, 25, true, mForm);
              //CreateButton('ETzaj', 'Materiál', 5, 320, 770, 80, 25, true, mForm);
              //CreateButton('ETuk', 'Ukončit', 6, 400, 770, 80, 25, true, mForm);
              //CreateButton('ETfa', 'Fakturace', 7, 480, 770, 80, 25, true, mForm);
              //CreateButton('ETza', 'Záruka', 8, 560, 770, 80, 25, true, mForm);





                 // CreateButton('ETOK', 'OK', 1, 270, 180, 80, 25, true, mForm);
                 // CreateButton('ETCancel', 'Storno', 2, 360, 180, 80, 25, false, mForm);
                  Result := mForm.ShowModal(xSite);
                     NxShowSimpleMessage(inttostr(result),nil);
                  //mDateFrom1 := mLblDateFrom1.Date;
                  //mDateTo1 := mLblDateTo1.Date;
                  //mDateFrom2 := mLblDateFrom2.Date;
                  //mDateTo2 := mLblDateTo2.Date;
                //finally
                  mForm.Free;
                //end;


  //        end;




 //   end else begin
 //       for mI_ML:= 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
 //          mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(mI_ML));
 //          mBO:= TDynSiteForm(xSite).CurrentObject;
 //       end;
 //   end;
end;


begin
end.