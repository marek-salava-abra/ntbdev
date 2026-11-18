  uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse',
       '_Knihovny_ALL.VisualForms';





 procedure Userdata(Sender: TObject;index:integer);
var
  mSite: TSiteForm;
  mDBGrid : TDBGrid;
 mTabList: TTabSheet;
  mObj, mObj2,mbonew: TNxCustomBusinessObject;
  i: integer;
  mOLE, mRoll, mOResult: Variant;
  mid_reportx:tstringlist;
  mr,mr0:tstringlist;
  mBO:TNxCustomBusinessObject;
  mi:integer;
  mBookmark : TBookmarkList;
  mIBookmark:integer;
  mICount:integer;
  mids:string;
  mString:string;
   mform:TForm;
 result:integer;
 mPECurrency,mFirm,mSpec,mObal,mMat4,mMat5,mPurchaseCurrency_ID:TRollComboEdit;
 mPEcode,mPEname,mPEspec,mPArtikl,mPMat5,mPQUnit:TEdit;
 mBtn:TButton;
 mBcurrency,mBDelete,mBFirm,mBSpec,mBObal,mBEcode,mBEname,mBEspec,mBArtikl,mBQUnit:Boolean;
 mCHcurrency,mCHDelete,mCHFirm,mCHSpec,mCHObal,mCHEcode,mCHEname,mCHEspec,mCHArtikl,mCHMain,mCHQUnit,mCHPurchaseCurrency_ID:TCheckBox;
 mSCurency,mSFirm,mSSpec,mSObal,mSPEcode,mSPEname,mSPEspec,mSPArtikl,mSPQUnit:string;
 mPPurchaseDate:TDateEdit;
 mFirmName:string;
 mBSave:boolean;
 mPocetZmen:integer;
 mBMain:boolean;
 mStorecard_ID:string;
 mSPCurrency:string;


begin
  mids:='';
  if Sender is TComponent then mSite := TComponent(Sender).Site;

//  if Sender is TAction then mSite := NxFindSiteForm(Sender);

    if not Assigned(mSite) then begin
         NxMessageBox('Chyba', 'Agenda nebyla dohledána', mdConfirm, mdbOkCancel, 0, 0, true, nil) ;
         nxbeep(btfailure);
         exit;
    end else begin
        mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
            if mTabList = nil then begin
                  RaiseException('tabList nenalezen');
                  NxMessageBox('Chyba', 'abList nenalezen', mdConfirm, mdbOkCancel, 0, 0, true, nil) ;
                  nxbeep(btfailure);
                  exit;
            end else begin
            mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
                if mDBGrid = nil then begin
                      RaiseException('DBGrid nenalezen');
                      NxMessageBox('Chyba', 'DBGrid nenalezen', mdConfirm, mdbOkCancel, 0, 0, true, nil) ;
                      nxbeep(btfailure);
                      exit;
                end else begin
                      mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
                      mIBookmark:=0;

                   mPocetZmen:=0;


                     if index=0 then begin
                         mform:=CreateFormDialoga('mform', 'Úprava odběratele ',mSite, 500, 300);
                         try
                          mBDelete:=false;
                          mBFirm:=false;
                          mBSpec:=false;
                          mBObal:=false;
                          mBEcode:=false;
                          mBEname:=false;
                          mBEspec:=false;
                          mBArtikl:=false;

                           mSFirm:='';
                                   mSSpec:='';
                                   mSObal:='';

                                   mSPEcode:='';
                                   mSPEname:='';
                                   mSPEspec:='';
                                   mSPArtikl:='';

                           mCHDelete:=CreateCheckBoxa('mCHDelete','Smazat odběratele ', false, 20, 13,120,20, mform);

                           mFirm:=CreateNxComboEdita('xFirm', 'Firma:',mform,  150,  10, 250, 250, 50, 80, 'O3OWQQYWYJCL3J0B01K0LEIOE0', 'code', 'Name', 'ID', '','');

                           mCHEcode:=CreateCheckBoxa('mCHEcode','Použít ', false, 5, 53,120,20, mform);
                           mPEcode:=CreateEdita('mPEcode', 'Ext. kód', 70, 50, 200, 80, '', mform,false) ;

                           mCHEname:=CreateCheckBoxa('mCHEname','Použít ', false, 5, 78,120,20, mform);
                           mPEname:=CreateEdita('mPEname', 'Ext. název', 70, 75, 200, 80, '', mform,false) ;

                           mCHEspec:=CreateCheckBoxa('mCHEspec','Použít ', false, 5, 103,120,20, mform);
                           mPEspec:=CreateEdita('mPEspec', 'Ext. specifikace', 70, 100, 200, 80, '', mform,false) ;

                           mCHSpec:=CreateCheckBoxa('mCHSpec','Použít ', false, 5, 143,120,20, mform);
                           mSpec:=CreateNxComboEdita('xSpec', 'Specifikace:',mform,  70,  140, 350, 250, 80, 120, 'IBGRYEM5IROOPEEER2TDCGTCKC', 'code', 'Name', 'ID', '','');

                           mCHObal:=CreateCheckBoxa('mCHObal','Použít ', false, 5, 168,120,20, mform);
                           mObal:=CreateNxComboEdita('xObal', 'Obal:',mform,  70,  165, 350, 250, 80, 120, 'S3WZQKDB5FDL342M01C0CX3FCC', 'code', 'Name', 'ID', '','');

                           mCHArtikl:=CreateCheckBoxa('mCHArtikl','Použít ', false, 5, 193,120,20, mform);
                           mPArtikl:=CreateEdita('mPArtikl', 'Artikl:', 70,190, 200, 80, '', mform,false) ;

                            mBtn := TButton.Create(mForm);mBtn.Width := 200 ;mBtn.Height := 40;mBtn.Caption := 'Zápis'; mBtn.ModalResult := 2; mBtn.Cancel := False;mBtn.Default := True;mBtn.Left:=30;mBtn.Top :=220 ;mBtn.Name := 'btnOK';mForm.InsertControl(mBtn);
                            mBtn := TButton.Create(mForm);mBtn.Width := 200 ;mBtn.Height := 40;mBtn.Caption := 'Storno';mBtn.ModalResult := 99;mBtn.Cancel := False;mBtn.Left := 270;mBtn.Top := 220;mBtn.Name := 'btn99';mForm.InsertControl(mBtn);


                            //  ab:= CreateEdita('slozeni', 'Poměr',mform, 300,30, 30, 50,100, '155455',false,true,true,10, [fsBold],255) ;

                               Result := mForm.ShowModal(mSite);
                               if result= 2 then begin
                                   if nxisemptyoid(mFirm.DataText) then begin
                                       NxShowSimpleMessage('Bez zadané firmy nejde pokračovat',nil);


                                       exit;
                                   end else begin
                                           mSFirm:=mFirm.DataText;
                                           mSSpec:=mSpec.DataText;
                                           mSObal:=mObal.DataText;

                                           mSPEcode:=mPEcode.Text;
                                           mSPEname:=mPEname.Text;
                                           mSPEspec:=mPEspec.Text;
                                           mSPArtikl:=mPArtikl.Text;

                                           mBDelete:=false;
                          mBDelete:=mCHDelete.Checked;
                          mBFirm:=mCHFirm.Checked;
                          mBSpec:=mCHSpec.Checked;
                          mBObal:=mCHObal.Checked;
                          mBEcode:=mCHEcode.Checked;
                          mBEname:=mCHEname.Checked;
                          mBEspec:=mCHEspec.Checked;
                          mBArtikl:=mCHArtikl.Checked;

                                   end;
                               end;


                               if result= 99 then begin
                                   NxShowSimpleMessage('Operace byla přerušena uživatelem',nil);
                                   exit;
                               end;
                         finally
                             mform.free;
                         end;
                     end;



                     // dodavatel
                     if index=2 then begin
                         mform:=CreateFormDialoga('mform', 'Úprava dodavatele ',mSite, 500, 300);
                         try
                          mBDelete:=false;
                          mBMain:=false;
                          mBFirm:=false;
                          mBSpec:=false;
                          mBObal:=false;
                          mBEcode:=false;
                          mBEname:=false;
                          mBEspec:=false;
                          mBArtikl:=false;

                           mSFirm:='';
                                   mSSpec:='';
                                   mSObal:='';

                                   mSPEcode:='';
                                   mSPEname:='';
                                   mSPEspec:='';
                                   mSPArtikl:='';
                                   mSPQUnit:='';
                           mCHDelete:=CreateCheckBoxa('mCHDelete','Smazat dodavatele ', false, 20, 13,120,20, mform);
                           mCHMain:=CreateCheckBoxa('mCHMain','Hlavní dodavatel ', false, 350, 13,120,20, mform);

                           mFirm:=CreateNxComboEdita('xFirm', 'Firma:',mform,  150,  10, 250, 250, 50, 80, 'O3OWQQYWYJCL3J0B01K0LEIOE0', 'code', 'Name', 'ID', '','');

                           mCHEcode:=CreateCheckBoxa('mCHEcode','Použít ', false, 5, 53,120,20, mform);
                           mPEcode:=CreateEdita('mPEcode', 'Ext. kód', 70, 50, 200, 80, '', mform,false) ;

                           mCHEname:=CreateCheckBoxa('mCHEname','Použít ', false, 5, 78,120,20, mform);
                           mPEname:=CreateEdita('mPEname', 'Ext. název', 70, 75, 200, 80, '', mform,false) ;



                           mCHQUnit:=CreateCheckBoxa('mCHQUnit','Použít ', false, 5, 103,120,20, mform);
                           mPQUnit:=CreateEdita('mPQUnit', 'Jednotka', 70, 100, 200, 80, '', mform,false) ;


                           mCHPurchaseCurrency_ID:=CreateCheckBoxa('mCHPurchaseCurrency_ID','Použít ', false, 5, 128,120,20, mform);
                           mPurchaseCurrency_ID:=CreateNxComboEdita('xPurchaseCurrency_ID', 'Měna:',mform,  70,  125, 350, 250, 80, 120, 'C3XF0UG5UNCL33N2010DELDFKK', 'code', 'Name', 'ID', '','');



                          // mCHObal:=CreateCheckBoxa('mCHObal','Použít ', false, 5, 128,120,20, mform);
                         //  mObal:=CreateNxComboEdita('xObal', 'Měna:',mform,  70,  125, 350, 250, 80, 120, 'C3XF0UG5UNCL33N2010DELDFKK', 'code', 'Name', 'ID', '','');






                         //   mbonew.SetFieldValueAsFloat('DeliveryTime',0)  ;

                         //   mbonew.SetFieldValueAsFloat('MinimalQuantity',0);
                         //    mCHMinimalQuantity:=CreateCheckBoxa('mCHMinimalQuantity','Použít ', false, 5, 53,120,20, mform);
                        //   mPMinimalQuantity:=CreateEdita('mPMinimalQuantity', 'Minimální množství', 70, 50, 200, 80, '', mform,false) ;



                      //   mbonew.SetFieldValueAsFloat('UnitRate',1);
                      //   mCHUnitRate:=CreateCheckBoxa('mCHUnitRate','Použít ', false, 5, 78,120,20, mform);
                      //   mPUnitRate:=CreateEdita('mPUnitRate', 'vztah', 70, 75, 200, 80, '', mform,false) ;




// mbonew.SetFieldValueAsDateTime('PurchaseDate$DATE',date());
 // mCHPurchaseDate:=CreateCheckBoxa('mCHPurchaseDate','Použít ', false, 5, 78,120,20, mform);

  //mPPurchaseDate:=CreateDateEditA(mPPurchaseDate, 'Datum nákupu',
  //70, 75, 200, 80, now(), mform, false): TDateEdit;





            //               mPPurchaseDate:=CreateEdita('mPPurchaseDate', 'Nákup', 70, 75, 200, 80, '', mform,false) ;

//mbonew.SetFieldValueAsFloat('PurchasePrice',NxIBStrToFloat(mfieldValue.Strings[1]));
//  mCHPurchasePrice:=CreateCheckBoxa('mCHPurchasePrice','Použít ', false, 5, 53,120,20, mform);
//                           mPPurchasePrice:=CreateEdita('mPPurchasePrice', 'Nákupní cena', 70, 50, 200, 80, '', mform,false) ;

//mbonew.SetFieldValueAsFloat('UnitPurchasePrice',NxIBStrToFloat(mfieldValue.Strings[1]));
//  mCHUnitPurchasePrice:=CreateCheckBoxa('mCHUnitPurchasePrice','Použít ', false, 5, 53,120,20, mform);
//                           mPUnitPurchasePrice:=CreateEdita('mPUnitPurchasePrice', 'Jednotka nákupu', 70, 50, 200, 80, '', mform,false) ;


{mbonew.SetFieldValueAsString('PurchaseCurrency_ID','0000EUR000');
mCHPurchaseCurrency_ID:=CreateCheckBoxa('mCHPurchaseCurrency_ID','Použít ', false, 5, 143,120,20, mform);
                           mPurchaseCurrency_ID:=CreateNxComboEdita('xPurchaseCurrency_ID', 'Měna:',mform,  70,  140, 350, 250, 80, 120, 'IBGRYEM5IROOPEEER2TDCGTCKC', 'code', 'Name', 'ID', '','');


//mbonew.SetFieldValueAsFloat('PurchaseCurrRate',26.10);
  mCHPurchaseCurrRate:=CreateCheckBoxa('mCHPurchaseCurrRate','Použít ', false, 5, 53,120,20, mform);
                           mPPurchaseCurrRate:=CreateEdita('mPPurchaseCurrRate', 'Kurz', 70, 50, 200, 80, '', mform,false) ;


//                                                                    mbonew.SetFieldValueAsBoolean('DoDemand',False);
//                                                                    mbonew.SetFieldValueAsBoolean('IsApproved',true);

                                                     }
                            mBtn := TButton.Create(mForm);mBtn.Width := 200 ;mBtn.Height := 40;mBtn.Caption := 'Zápis'; mBtn.ModalResult := 2; mBtn.Cancel := False;mBtn.Default := True;mBtn.Left:=30;mBtn.Top :=220 ;mBtn.Name := 'btnOK';mForm.InsertControl(mBtn);
                            mBtn := TButton.Create(mForm);mBtn.Width := 200 ;mBtn.Height := 40;mBtn.Caption := 'Storno';mBtn.ModalResult := 99;mBtn.Cancel := False;mBtn.Left := 270;mBtn.Top := 220;mBtn.Name := 'btn99';mForm.InsertControl(mBtn);


                            //  ab:= CreateEdita('slozeni', 'Poměr',mform, 300,30, 30, 50,100, '155455',false,true,true,10, [fsBold],255) ;

                               Result := mForm.ShowModal(mSite);
                               if result= 2 then begin
                                   if nxisemptyoid(mFirm.DataText) then begin
                                       NxShowSimpleMessage('Bez zadané firmy nejde pokračovat',nil);


                                       exit;
                                   end else begin
                                           mSFirm:=mFirm.DataText;
                                           mSSpec:=mSpec.DataText;
                                           mSCurency:=mObal.DataText;

                                           mSPEcode:=mPEcode.Text;
                                           mSPEname:=mPEname.Text;
                                           mSPEspec:=mPEspec.Text;
                                           mSPArtikl:=mPArtikl.Text;
                                           mSPQUnit:=mPQUnit.text;
                                           mSCurency:=mPurchaseCurrency_ID.DataText;

                                           mBDelete:=false;
                                                mBDelete:=mCHDelete.Checked;
                                                mBFirm:=mCHFirm.Checked;
                                                mBSpec:=mCHSpec.Checked;
                                                mBObal:=mCHObal.Checked;
                                                mBEcode:=mCHEcode.Checked;
                                                mBEname:=mCHEname.Checked;
                                                mBEspec:=mCHEspec.Checked;
                                                mBArtikl:=mCHArtikl.Checked;
                                                mBMain:=mCHMain.Checked ;
                                                mBcurrency:=mCHPurchaseCurrency_ID.Checked;





                                   end;
                               end;


                               if result= 99 then begin
                                   NxShowSimpleMessage('Operace byla přerušena uživatelem',nil);
                                   exit;
                               end;
                         finally
                             mform.free;
                         end;
                     end;


                     // **** konec dodavatel
                     mFirmName:='';
                     mr:=TStringList.create;
                     try
                           msite.BaseObjectSpace.SQLSelect('select code||name from firms where id=' + quotedstr(mSFirm),mr);
                           if mr.count>0 then begin
                               mFirmName:= mr.Strings[0];
                           end;
                     finally
                         mr.free;
                     end;


                     if mBookmark.count>0 then begin
                           mIBookmark:=mBookmark.count-1;
                           ProgressInit(msite, 'Zpracování dat firmy ' +  mFirmName, 100);
                      end;

                           if (index=2) then begin
                               if (mIBookmark=0) then begin
                                      NxShowSimpleMessage('Pro práci musí být označen aspoň 1 záznam. ',nil);
                                      exit;
                               end;
                               mobj:=TBusRollSiteForm(msite).CurrentObject;
                           end;



                      for mICount:=0 to mIBookmark do begin
                          if mBookmark.count>0 then begin
                               mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(mICount));
                               ProgressSetPos(1+NxFloor(mICount/mBookmark.Count*99), inttostr(mICount) +' z '+inttostr(mBookmark.Count));
                                mobj:=TBusRollSiteForm(msite).CurrentObject;
                                mStorecard_ID:=mobj.oid;
                          end;

                          // **** odběratel
                          if index=0 then begin
                                      mr:=tstringlist.create;
                                      try
                                           msite.BaseObjectSpace.SQLSelect('Select sb.id from Subscribers sb JOIN Firms F ON F.ID=sb.Firm_ID where sb.StoreCard_ID = ' + QuotedStr(TBusRollSiteForm(msite).CurrentObject.oid) +
                                           ' and (F.ID=' + quotedstr(mSFirm) +' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID=' + quotedstr(mSFirm) + ')))'    ,mr);
            //                                  NxShowSimpleMessage('Select id from Subscribers where StoreCard_ID = ' + QuotedStr(TBusRollSiteForm(msite).CurrentObject.oid) + ' and Firm_ID=' + quotedstr(mSFirm),nil);

                                              if mr.count>0 then begin

                                                                    mbonew:= msite.BaseObjectSpace.CreateObject('W5U50LCWKJDL331C00C5OG4NF4');
                                                                       try
                                                                              //              NxShowSimpleMessage('odběratel dohledán , upravuji',nil);
                                                                               mbonew.load(mr.Strings[0],nil );
                                                                               mbsave:=false;
                                                                                            if not mBDelete then begin

                                                                                                    if mBEcode then begin
                                                                                                        if mbonew.getFieldValueAsString('ExternalNumber')<>mSPEcode then begin
                                                                                                              mbonew.SetFieldValueAsString('ExternalNumber',mSPEcode);
                                                                                                              mBSave:=True;
                                                                                                        end;
                                                                                                    end;
                                                                                                    if mBEname then begin
                                                                                                        if mbonew.getFieldValueAsString('Name')<>mSPEname then begin
                                                                                                              mbonew.SetFieldValueAsString('Name',mSPEname);
                                                                                                              mBSave:=True;
                                                                                                        end;
                                                                                                    end;
                                                                                                    if mBEspec then begin
                                                                                                        if mbonew.getFieldValueAsString('ExternalSpecification')<>mSPEspec then begin
                                                                                                              mbonew.SetFieldValueAsString('ExternalSpecification',mSPEspec);
                                                                                                              mBSave:=True;
                                                                                                        end;
                                                                                                    end;

                                                                                                    if mBObal then begin
                                                                                                        if mbonew.getFieldValueAsString('X_Krabicka_ID')<>mSObal then begin
                                                                                                              mbonew.SetFieldValueAsString('X_Krabicka_ID',mSObal);
                                                                                                              mBSave:=True;
                                                                                                        end;

                                                                                                    end;
                                                                                                    if mBSpec then begin
                                                                                                        if mbonew.getFieldValueAsString('X_Specifikace_id')<>mSSpec then begin
                                                                                                              mbonew.SetFieldValueAsString('X_Specifikace_id',mSSpec);
                                                                                                              mBSave:=True;
                                                                                                        end;

                                                                                                    end;
                                                                                                    if mBArtikl then begin
                                                                                                        if mbonew.getFieldValueAsString('X_Artikl')<>mSPArtikl then begin
                                                                                                               mbonew.SetFieldValueAsString('X_Artikl',mSPArtikl);
                                                                                                               mBSave:=True;
                                                                                                        end;


                                                                                                    end;

                                                                                                    if mbsave then begin
                                                                                                        mbonew.save;
                                                                                                        mPocetZmen:=mPocetZmen+1;
                                                                                                        //NxShowSimpleMessage('oprava',nil);
                                                                                                    end;

                                                                                             end else begin
                                                                                                   mbonew.Delete;
                                                                                                   mPocetZmen:=mPocetZmen+1;
                                                                                                 //  NxShowSimpleMessage('mazani',nil);
                                                                                            end;


                                                                       finally
                                                                              mbonew.free;
                                                                       end;
                                              end else begin
                                                  mbonew:= msite.BaseObjectSpace.CreateObject('W5U50LCWKJDL331C00C5OG4NF4');
                                                           try
                                                               //    NxShowSimpleMessage('odběratel nedohledán, zakládám ',nil);
                                                                       if not mBDelete then begin
                                                                                mbonew.new;
                                                                                mbonew.Prefill;
                                                                                       mbonew.SetFieldValueAsString('Storecard_ID',TBusRollSiteForm(msite).CurrentObject.oid);
                                                                                       mbonew.SetFieldValueAsString('Firm_ID',mSFirm);
                                                                                                  if mBEcode then mbonew.SetFieldValueAsString('ExternalNumber',mSPEcode);
                                                                                                    if mBEname then mbonew.SetFieldValueAsString('Name',mSPEname);
                                                                                                    if mBEspec then mbonew.SetFieldValueAsString('ExternalSpecification',mSPEspec);

                                                                                                    if mBObal then mbonew.SetFieldValueAsString('X_Krabicka_ID',mSObal);
                                                                                                    if mBSpec then mbonew.SetFieldValueAsString('X_Specifikace_id',mSSpec);
                                                                                                    if mBArtikl then mbonew.SetFieldValueAsString('X_Artikl',mSPArtikl);
                                                                                mbonew.save;
                                                                                mPocetZmen:=mPocetZmen+1;
                                                                                //NxShowSimpleMessage('novy',nil);
                                                                       end;

                                                           finally
                                                                  mbonew.free;
                                                           end;

                                              end;
                                      finally
                                          mr.free;
                                      end;

                          end;



                          // **** dodavatel
                          if index=2 then begin
//                          exit   ;
                                      mr:=tstringlist.create;
                                      try
                                           msite.BaseObjectSpace.SQLSelect('Select sb.id from Suppliers sb JOIN Firms F ON F.ID=sb.Firm_ID where sb.StoreCard_ID = ' + QuotedStr(TBusRollSiteForm(msite).CurrentObject.oid) +
                                           ' and (F.ID=' + quotedstr(mSFirm) +' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID=' + quotedstr(mSFirm) + ')))'    ,mr);
            //                                  NxShowSimpleMessage('Select id from Subscribers where StoreCard_ID = ' + QuotedStr(TBusRollSiteForm(msite).CurrentObject.oid) + ' and Firm_ID=' + quotedstr(mSFirm),nil);

                                              if mr.count>0 then begin

                                                                    mbonew:= msite.BaseObjectSpace.CreateObject('O0F5OHLYGNDL342T01C0CX3FCC');
                                                                       try
                                                                                         //   NxShowSimpleMessage('dodavatel dohledán , pracuji',nil);
                                                                               mbonew.load(mr.Strings[0],nil );
                                                                                            if mBDelete then begin
                                                                                                    mbonew.Delete;
//                                                                                                     NxShowSimpleMessage('dodavatel dohledán , mažu',nil);
                                                                                                     mPocetZmen:=mPocetZmen + 1;
                                                                                            end else begin
                                                                                                    if mBEcode then mbonew.SetFieldValueAsString('ExternalNumber',mSPEcode);
                                                                                                    if mBEname then mbonew.SetFieldValueAsString('Name',mSPEname);
                                                                                                    if mBcurrency then mbonew.SetFieldValueAsString('PurchaseCurrency_ID',mSCurency);


                                                                                                    mbonew.save;
                                                                                                     //NxShowSimpleMessage('dodavatel dohledán , opravuji',nil);
                                                                                                     mPocetZmen:=mPocetZmen + 1;
                                                                                            end;


                                                                       finally
                                                                              mbonew.free;
                                                                       end;
                                              end else begin
                                                  mbonew:= msite.BaseObjectSpace.CreateObject('O0F5OHLYGNDL342T01C0CX3FCC');
                                                               try


                                                                                    mbonew.new;
                                                                                    mbonew.Prefill;
                                                                                    mbonew.SetFieldValueAsString('StoreCard_ID',mStorecard_ID);
                                                                                    mbonew.SetFieldValueAsString('Firm_ID',mSFirm);
                                                                                    if mBcurrency then begin
                                                                                       mbonew.SetFieldValueAsString('PurchaseCurrency_ID',mSCurency);
                                                                                    end else begin
                                                                                              if nxisemptyoid(mbonew.getFieldValueAsString('PurchaseCurrency_ID')) then begin
                                                                                                      if NxIsEmptyOID(mbonew.getFieldValueAsString('Firm_ID.Currency_ID')) then begin
                                                                                                        mbonew.SetFieldValueAsString('PurchaseCurrency_ID','0000CZK000');
                                                                                                      end else begin
                                                                                                        mbonew.SetFieldValueAsString('PurchaseCurrency_ID',mbonew.getFieldValueAsString('Firm_ID.Currency_ID'));
                                                                                                      end;
                                                                                              end;
                                                                                    end;
                                                                                    mbonew.SetFieldValueAsDateTime('PurchaseDate$DATE',date());
                                                                                    mbonew.SetFieldValueAsString('QUnit',mbonew.getFieldValueAsString('StoreCard_ID.MainUnitCode'));
                                                                                    mbonew.SetFieldValueAsFloat('UnitRate',1);
                                                                                    //mbonew.Prefill;


                                                                                    //mbonew.SetFieldValueAsFloat('PurchaseCurrRate',26.10);
                                                                                    //mbonew.SetFieldValueAsString('PurchaseCurrency_ID','0000EUR000');

                                                                                    mbonew.SetFieldValueAsFloat('UnitPurchasePrice',0);
                                                                                    mbonew.SetFieldValueAsFloat('PurchasePrice',0);

                                                                                    mbonew.SetFieldValueAsBoolean('DoDemand',False);
                                                                                    mbonew.SetFieldValueAsBoolean('IsApproved',true);

                                                                                   mbonew.SetFieldValueAsFloat('DeliveryTime',0)  ;
                                                                                   mbonew.SetFieldValueAsFloat('MinimalQuantity',0);
                                                                                       mbonew.save;

                                                                                 mi:=msite.BaseObjectSpace.SQLExecute('update storecards set MainSupplier_ID=' + QuotedStr(mbonew.oid) + ' where id=' + QuotedStr(mStorecard_ID))  ;

                                                                                 mPocetZmen:=mPocetZmen + 1;



                                                               finally
                                                                         mbonew.free;
                                                               end;

                                              end;
                                      finally
                                          mr.free;
                                      end;

                          end;


                      end;
                      if mBookmark.count>0 then  begin ProgressDispose()   ;
                          NxShowSimpleMessage('Pro firmu ' + mFirmName + ' bylo provedeno ' + inttostr(mPocetZmen) + ' změn. ',nil);
                      end;
                end;
            end;
    end;



end;

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TAction;
  mMAction: TMultiAction;
begin
  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Úpravy pro partnery';
  mMAction.Hint := 'Umožní hromadně měnit parametry pro partnery ';
  mMAction.Category := 'tabList';
  mMAction.Items.Add('Odběratel');
   mMAction.Items.Add('');
  mMAction.Items.Add('Dodavatel');
  mMAction.OnExecuteItem := @Userdata;

end;


function CreateCheckBoxa(AName, ACaption: string; ADefaultValue: Boolean;
  ALeft, ATop, AWidth, AHeight: Integer; AParent: TWinControl): TCheckBox;
begin
  Result:= TCheckBox.Create(AParent);
  Result.Parent:= AParent;
  Result.Top:= ATop;
  Result.Left:= ALeft;
  if AName <> '' then
    Result.Name:= 'ch_' + AName;
  Result.Width:= AWidth;
  if AHeight > -1 then
    Result.Height:= AHeight;
  Result.Caption:= ACaption;
  Result.Checked:= ADefaultValue;
  Result.WordWrap:= True;
end;


function CreateEdita(AName, ACaption: string;
  ALeft, ATop, AWidth: Integer; ALblWidth: Integer; ADefaultValue: string; AParent: TWinControl;
  AEditToNewLine: Boolean = False): TEdit;
var mLbl: TLabel;
begin
  mLbl:= TLabel.Create(AParent);
  mLbl.Parent:= AParent;
  mLbl.Top:= ATop + 5;
  mLbl.Left:= ALeft;
  mLbl.AutoSize:= False;
  if AName <> '' then
    mLbl.Name:= 'lbl_' + AName;
  if ALblWidth > -1 then
  begin
    mLbl.Width:= ALblWidth
  end else
  begin
    mLbl.AutoSize:= True;
    ALblWidth:= mLbl.Width + 10;
  end;
  mLbl.Caption:= ACaption;

  Result:= TEdit.Create(AParent);
  Result.Parent:= AParent;
  if not AEditToNewLine then
  begin
    Result.Top:= ATop;
    Result.Left:= ALeft + ALblWidth;
    Result.Width:= AWidth - ALblWidth;
  end else
  begin
    mLbl.Top:= ATop;
    Result.Top:= ATop + mLbl.Height + 2;
    Result.Width:= AWidth;
    Result.Left:= ALeft;
  end;
  if AName <> '' then
    Result.Name:= 'ed_' + AName;

  Result.Text:= ADefaultValue;
end;




function CreateNxComboEdita(AName, ACaption: string;
                           AParent: TWinControl;
                           ALeft, ATop, AWidth, AHeight,
                           ALblWidth, ABevelWidth: Integer;
                           AClassID, ATextField, AControlField, AID: string;
                           AParam: string = ''; AChange: string =''): TRollComboEdit;
var mLbl, mLbl1,
    mLblChange: TLabel;
begin
  if AID = '' then
    AID:= '0000000000';
  mLbl:= TLabel.Create(AParent);
  mLbl.Parent:= AParent;
  mLbl.Top:= ATop + 5;
  mLbl.Left:= ALeft;
  mLbl.AutoSize:= False;
  if AName <> '' then
    mLbl.Name:= 'lbl_' + AName;
  if ALblWidth > -1 then
  begin
    mLbl.Width:= ALblWidth
  end else
  begin
    mLbl.AutoSize:= True;
    ALblWidth:= mLbl.Width + 10;
  end;
  mLbl.Caption:= ACaption;

  mLbl1:= TLabel.Create(AParent);
  mLbl1.Parent:= AParent;
  mLbl1.Top:= ATop + 5;
  mLbl1.Left:= ALeft +AWidth ;
  mLbl1.AutoSize:= False;
  mLbl1.Caption:= '';
  if AName <> '' then
    mLbl1.Name:= 'lblBev_' + AName;
  mLbl1.Width:= ABevelWidth;
  mLbl1.Visible:= ABevelWidth > 0;

  Result:= TRollComboEdit.Create(AParent);
  Result.Parent:= AParent;
  Result.ClassID:= AClassID;
  Result.ForcedField:= True;
  Result.Prefilling:= pmNone;
  Result.TextField:= ATextField;
  Result.Parameters.Add(AParam);
  Result.Top:= ATop + 3;
  Result.Left:= ALeft + ALblWidth;
  if AControlField <> '' then
  begin
    Result.ConnectedControlField:= AControlField;
    Result.ConnectedControl:= mLbl1;
  end;

  if AName <> '' then
    Result.Name:= 'ced_' + AName;
  Result.DataText:= AID;
  Result.Width:= AWidth - ALblWidth - ABevelWidth;


  if (AChange <> '') and (AName <> '') then
  begin
    mLblChange:= TLabel.Create(AParent);
    mLblChange.Parent:= AParent;
    mLblChange.Top:= 0;
    mLblChange.Left:= 0;
    mLblChange.ViSible:= False;
    mLblChange.Name:= 'lblCh_' + AName;
    mLblChange.Caption:= AChange;
    Result.OnChange:= @NxDBComboEditChange;
  end;


  mLbl1.Left:= mLbl1.Left + 10;
  mLbl1.Width:= mLbl1.Width - 10;
end;



  function CreateFormDialoga(AName, ACaption: String;
                          AParent: TWinControl;
                          AWidth, AHeight: Integer; ): TForm;
var
  mForm: TForm;
begin
  mForm := TForm.Create(AParent);
  mForm.Name := 'fm_'+AName;
  mForm.Caption := ACaption;
  mForm.FormStyle := fsStayOnTop;
  mForm.BorderStyle := bsDialog;
  mForm.Position := poScreenCenter;
  mForm.Width := AWidth;
  mForm.Height := AHeight;
  mForm.Scaled := False;

  Result := mForm;
end;



function CreateDateEditA(AName, ACaption: string;
  ALeft, ATop, AWidth: Integer; ALblWidth: Integer; ADefaultValue: TDate; AParent: TWinControl;
  AEditToNewLine: Boolean = False): TDateEdit;
var
  mLbl: TLabel;
begin

  mLbl:= TLabel.Create(AParent);
  mLbl.Parent:= AParent;
  mLbl.Top:= ATop + 5;
  mLbl.Left:= ALeft;
  mLbl.AutoSize:= False;
  if AName <> '' then
    mLbl.Name:= 'lbl_' + AName;
  if ALblWidth > -1 then
  begin
    mLbl.Width:= ALblWidth
  end else
  begin
    mLbl.AutoSize:= True;
    ALblWidth:= mLbl.Width + 10;
  end;
  mLbl.Caption:= ACaption;

  Result:= TDateEdit.Create(AParent);
  Result.Parent:= AParent;
  if not AEditToNewLine then
  begin
    Result.Top:= ATop;
    Result.Left:= ALeft + ALblWidth;
    Result.Width:= AWidth - ALblWidth;
  end else
  begin
    mLbl.Top:= ATop;
    Result.Top:= ATop + mLbl.Height + 2;
    Result.Width:= AWidth;
    Result.Left:= ALeft;
  end;
  if AName <> '' then
    Result.Name:= 'ed_' + AName;

  Result.Date:= ADefaultValue;
end;



begin
end.





