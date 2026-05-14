uses 'abra.eu.API.digitalizace.Libs','abra.eu.API.digitalizace.Function';
const
mSQL_officeEAN='select ro2.id from STOREEANS SE left join StoreUnits SU on SU.id=se.Parent_id left join Storecards SC on sc.id=su.parent_id left join Receivedorders2 RO2 on ro2.storecard_id=sc.id left join Receivedorders RO on ro.id=ro2.parent_id where (RO.closed = ''N'' ) and ((RO2.Quantity - Ro2.DeliveredQuantity-Ro2.X_vychystano)>=0) and ((ro2.X_specifikace_id is null) and (ro2.X_ExternalSpecification ='''')) and (se.EAN=%s and (RO.FirmOffice_ID in (%s)))';
mSQL_DokladEAN='select ro2.id from STOREEANS SE left join StoreUnits SU on SU.id=se.Parent_id left join Storecards SC on sc.id=su.parent_id left join Receivedorders2 RO2 on ro2.storecard_id=sc.id left join Receivedorders RO on ro.id=ro2.parent_id where (RO.closed = ''N'' ) and ((RO2.Quantity - Ro2.DeliveredQuantity-Ro2.X_vychystano)>=0) and ((ro2.X_specifikace_id is null) and (ro2.X_ExternalSpecification ='''')) and  (se.EAN=%s and (RO.ID in (%s)))';
mSQL_SCEAN='select sc.id from STOREEANS SE left join StoreUnits SU on SU.id=se.Parent_id left join Storecards SC on sc.id=su.parent_id where (se.EAN=%s)';

mSQL_DokladDLEAN='select SD2.id from STOREEANS SE left join StoreUnits SU on SU.id=se.Parent_id left join Storecards SC on sc.id=su.parent_id left join Storedocuments2 SD2 on SD2.storecard_id=sc.id left join Storedocuments SD on SD.id=SD2.parent_id where ((SD2.Quantity - SD2.DeliveredQuantity)>=0) and (se.EAN=%s and (SD.ID in (%s)))';
mSQLIO2_officeEAN='select ro2.id from STOREEANS SE left join StoreUnits SU on SU.id=se.Parent_id left join Storecards SC on sc.id=su.parent_id left join Issuedorders2 RO2 on ro2.storecard_id=sc.id left join Issuedorders RO on ro.id=ro2.parent_id where (RO.closed = ''N'' ) and ((RO2.Quantity - Ro2.DeliveredQuantity-Ro2.X_vychystano)>=0) and ((ro2.X_specifikace_id is null) and (ro2.X_ExternalSpecification ='''')) and  (se.EAN=%s and (RO.FirmOffice_ID in (%s)))';
mSQLIO2_DokladEAN='select ro2.id from STOREEANS SE left join StoreUnits SU on SU.id=se.Parent_id left join Storecards SC on sc.id=su.parent_id left join Issuedorders2 RO2 on ro2.storecard_id=sc.id left join Issuedorders RO on ro.id=ro2.parent_id where (RO.closed = ''N'' ) and ((RO2.Quantity - Ro2.DeliveredQuantity-Ro2.X_vychystano)>=0) and ((ro2.X_specifikace_id is null) and (ro2.X_ExternalSpecification ='''')) and  (se.EAN=%s and (RO.ID in (%s)))';

mSQL_Storesubcards='select ssc.id from StoreSubCards SSC where SSC.StoreCard_ID=%S and SSC.Store_ID=%S)';
mSQL_office='select max(ro2.id),ro2.Storecard_ID,max(l.code) from STOREEANS SE left join StoreUnits SU on SU.id=se.Parent_id left join Storecards SC on sc.id=su.parent_id left join StoreSubCards SSC on ((SSC.StoreCard_ID=sc.id) and (SSC.Store_ID=%S)) left join Locations L on l.id=ssc.Location_ID left join Receivedorders2 RO2 on ro2.storecard_id=sc.id left join Receivedorders RO on ro.id=ro2.parent_id where (RO.closed = ''N'' ) and ((ro2.X_specifikace_id is null) and (ro2.X_ExternalSpecification ='''')) and  ((sc.Storecardcategory_ID<>' + QuotedStr('1A00000101') + ') and (sc.Storecardcategory_ID<>' + QuotedStr('9000000101') + '))  and (ro2.X_specifikace_id is null) and  ((RO2.Quantity - Ro2.DeliveredQuantity-Ro2.X_vychystano)>0) and ((RO.FirmOffice_ID in (%s))) group by l.code,ro2.Storecard_ID order by l.code,ro2.Storecard_ID';
mSQL_Doklad='select max(ro2.id),ro2.Storecard_ID,l.code from STOREEANS SE left join StoreUnits SU on SU.id=se.Parent_id left join Storecards SC on sc.id=su.parent_id left join StoreSubCards SSC on ((SSC.StoreCard_ID=sc.id) and (SSC.Store_ID=%S)) left join Locations L on l.id=ssc.Location_ID left join Receivedorders2 RO2 on ro2.storecard_id=sc.id left join Receivedorders RO on ro.id=ro2.parent_id where (RO.closed = ''N'' ) and ((ro2.X_specifikace_id is null) and (ro2.X_ExternalSpecification ='''')) and ((RO2.Quantity - Ro2.DeliveredQuantity-Ro2.X_vychystano)>0) and ((sc.Storecardcategory_ID<>' + QuotedStr('1A00000101') + ') and (sc.Storecardcategory_ID<>' + QuotedStr('9000000101') + '))  and  ((RO.ID in (%s))) group by l.code,ro2.Storecard_ID order by l.code,ro2.Storecard_ID';

mSQL_Doklad_quantity='select sum(ro2.quantity) from STOREEANS SE left join StoreUnits SU on SU.id=se.Parent_id left join Storecards SC on sc.id=su.parent_id left join Receivedorders2 RO2 on ro2.storecard_id=sc.id left join Receivedorders RO on ro.id=ro2.parent_id where (RO.closed = ''N'' ) and ((RO2.Quantity - Ro2.DeliveredQuantity-Ro2.X_vychystano)>=0) and ((ro2.X_specifikace_id is null) and (ro2.X_ExternalSpecification ='''')) and (se.EAN=%s and (RO.ID in (%s)))';
mSQL_Doklad_delivered='select sum(ro2.DeliveredQuantity) from STOREEANS SE left join StoreUnits SU on SU.id=se.Parent_id left join Storecards SC on sc.id=su.parent_id left join Receivedorders2 RO2 on ro2.storecard_id=sc.id left join Receivedorders RO on ro.id=ro2.parent_id where (RO.closed = ''N'' ) and ((RO2.Quantity - Ro2.DeliveredQuantity-Ro2.X_vychystano)>=0) and ((ro2.X_specifikace_id is null) and (ro2.X_ExternalSpecification ='''')) and  (se.EAN=%s and (RO.ID in (%s)))';
mSQL_Doklad_vychystano='select sum(ro2.x_vychystano) from STOREEANS SE left join StoreUnits SU on SU.id=se.Parent_id left join Storecards SC on sc.id=su.parent_id left join Receivedorders2 RO2 on ro2.storecard_id=sc.id left join Receivedorders RO on ro.id=ro2.parent_id where (RO.closed = ''N'' ) and ((RO2.Quantity - Ro2.DeliveredQuantity-Ro2.X_vychystano)>=0) and ((ro2.X_specifikace_id is null) and (ro2.X_ExternalSpecification ='''')) and  (se.EAN=%s and (RO.ID in (%s)))';

mSQL_Doklad_quantitysp='select sum(ro2.quantity) from STOREEANS SE left join StoreUnits SU on SU.id=se.Parent_id left join Storecards SC on sc.id=su.parent_id left join Receivedorders2 RO2 on ro2.storecard_id=sc.id left join Receivedorders RO on ro.id=ro2.parent_id where (RO.closed = ''N'' ) and ((RO2.Quantity - Ro2.DeliveredQuantity-Ro2.X_vychystano)>=0) and (se.EAN=%s and (RO.ID in (%s)))';
mSQL_Doklad_deliveredsp='select sum(ro2.DeliveredQuantity) from STOREEANS SE left join StoreUnits SU on SU.id=se.Parent_id left join Storecards SC on sc.id=su.parent_id left join Receivedorders2 RO2 on ro2.storecard_id=sc.id left join Receivedorders RO on ro.id=ro2.parent_id where (RO.closed = ''N'' ) and ((RO2.Quantity - Ro2.DeliveredQuantity-Ro2.X_vychystano)>=0) and  (se.EAN=%s and (RO.ID in (%s)))';
mSQL_Doklad_vychystanosp='select sum(ro2.x_vychystano) from STOREEANS SE left join StoreUnits SU on SU.id=se.Parent_id left join Storecards SC on sc.id=su.parent_id left join Receivedorders2 RO2 on ro2.storecard_id=sc.id left join Receivedorders RO on ro.id=ro2.parent_id where (RO.closed = ''N'' ) and ((RO2.Quantity - Ro2.DeliveredQuantity-Ro2.X_vychystano)>=0) and  (se.EAN=%s and (RO.ID in (%s)))';

mSQL_Doklad_zapis='select ro2.id from Receivedorders2 RO2 left join Receivedorders RO on ro.id=ro2.parent_id where (RO.closed = ''N'' ) and ((RO2.Quantity - Ro2.DeliveredQuantity-Ro2.X_vychystano)>0) and (ro2.storecard_id=%s and (RO.ID in (%s)))';
mSQL_Doklad_zapisDL='select ro2.id from Receivedorders2 RO2 left join Receivedorders RO on ro.id=ro2.parent_id where (RO.closed = ''N'' ) and ((RO2.Quantity - Ro2.DeliveredQuantity-Ro2.X_dodano)>0) and (ro2.storecard_id=%s and (RO.ID in (%s)))';
mSQL_DokladEANns='select ro2.id from STOREEANS SE left join StoreUnits SU on SU.id=se.Parent_id left join Storecards SC on sc.id=su.parent_id left join Receivedorders2 RO2 on ro2.storecard_id=sc.id left join Receivedorders RO on ro.id=ro2.parent_id where (RO.closed = ''N'' ) and ((RO2.Quantity - Ro2.DeliveredQuantity-Ro2.X_vychystano)>0) and  (se.EAN=%s and (RO.ID in (%s)))';

Var
mNUM_button:integer;
mBOWorker,mBOMachine:TNxCustomBusinessObject;
mBOOperace:TNxCustomBusinessObject;
mOperations:tstringlist;



function BarCodeDialogDL_krize(xSite:TSiteForm;mCLSID_DOC:string;mTBatches:boolean;
                       mTop:integer;mLeft:integer;mWith:integer;mHeight:integer;mLabel:string;
                       mTyp_prace:integer;mids:integer; mIDs_dDocument:string;
                       mbutton1,mbutton2,mbutton3,mbutton4:string;
                       Mbutton5:string):string;
var
      mForm : TForm;
      mBtn : TButton;
      mLbl : TLabel;
      mBarCodeEdt,mQuantityEdt,mUnitEdt,mLocEdt : TEdit;
      mQuanEdt,mDelQuanEdt,mStorQuanEdt,mVychQuanEdt:tedit;
      sum_mDelQuanEdt,sum_mStorQuanEdt,sum_mVychQuanEdt:tedit;
      i:integer;
      xresult:Variant;
      //mSCEdt:TRollComboEdit;
      mSCEdt:TEdit;
      ABarCode,mbarcode:string;
      mQuantity:double  ;
      mUnit:string;
      mpocet:double;
      mix_result:integer;
      mBatch_id,mStorecard_id,m_umisteni,mjednotka:string;
      mr,mr1:tstringlist;
      mBO,mSSC:TNxCustomBusinessObject;
      mStorQuan:double;
      mdodano,mvychystano,mskladem,mcelkem:double;
      SUM_mdodano,SUM_mvychystano,Sum_mskladem,Sum_mcelkem:double;
      mstorecard_text:string;
      mBO_Row_id:string;
      mi_SQL:integer;
      mTypSC:integer;
      mID_Batch,mID_Storecard:string;
      mBatchList,mrBatch:TStringList;
      mMemNote:tmemo;
      mpokracovat:Boolean;
      mxx:tstringlist ;
      ixi:integer;
      mpomoc_pocet:double;
      mBO_HeadRO_ID:string;
      mLL:tstringlist;
      mI_Resultxax:integer;
      mBO_Row_idx:string;
begin
      mBO_Row_idx:='';
      mpokracovat:=true;
      Result := '';
      i:=1;
      ABarCode := '.';
      mBarCode:='';
      mpocet:=0;
      mStorecard_id:='';
                      mBO_Row_idx:='';
                      mstorecard_text:='';
                      mdodano:=0 ;
                      mvychystano:=0;
                      mskladem:=0 ;
                      mcelkem:=0;
                      m_umisteni:='';

                     mjednotka:='';
                      mbarcode:='';
      mBO:=xsite.BaseObjectSpace.CreateObject('05CPMINJW3DL342X01C0CX3FCC');
      try
      while ABarCode <> '' do begin

       if mpokracovat then begin


                 mForm := TForm.Create(xsite);
                          try
                                        mForm.Caption := mLabel;mForm.FormStyle := fsStayOnTop;mForm.BorderStyle := bsDialog;
                                        if mTop>=0 then begin
                                          mForm.Top:= mTop;
                                          mForm.Left:= mLeft;
                                        end else begin
                                          mform.Position := poScreenCenter;
                                        end;

                                        mForm.Width := mWith;mForm.Height := mHeight;mForm.Scaled := False;
                                        mBarCodeEdt:=CreateEdit('mBarCodeEdt', 'Čarový kód',mform, 10,10,320,80,150,mBarCode,true,true,true,round(480/24), [fsBold],255) ;
                                        //mSCEdt:=CreateEdit('mSCEdt', 'Zboží.',mForm,10, 80, 300,80,50,AsString('Storecard_id.Name'),true,true,false,round(480/24),[fsBold],255);
                                        mMemNote := CreateMemo('ChMemNote','Zboží', 10, 80, 320,80, 150, mstorecard_text, mForm,true,true,False,round(480/36), [fsItalic],255);


                                        mLocEdt:=CreateEdit('mLocEdt', 'Umístění',mform, 10,200,320,80,150,m_umisteni,true,true,false,round(480/24), [fsBold],255) ;
                                        mBtn := TButton.Create(mForm);mBtn.Width := 65;mBtn.Height := 70;mBtn.Caption := '-';mBtn.ModalResult := 10;mBtn.Cancel := False;mBtn.Default := false;mBtn.Left:=10;mBtn.Top := 270;mBtn.Name := 'btnIgnore';mForm.InsertControl(mBtn);
                                        mQuantityEdt:=CreateEdit('mQuantityEdt', 'Množství',mForm,80, 270, 120,80,50,NxFloatToIBStr(mpocet),true,true,true,round(480/24),[fsBold],255);
                                        mBtn := TButton.Create(mForm);mBtn.Width := 65;mBtn.Height := 70;mBtn.Caption := '+';mBtn.ModalResult := 20;mBtn.Cancel := False;mBtn.Default := false;mBtn.Left:=260;mBtn.Top := 270;mBtn.Name := 'btnYea';mForm.InsertControl(mBtn);
                                        mUnitEdt:=CreateEdit('mUnitEdt', 'Jedn.',mForm,210, 270, 40,80,50,mjednotka,true,true,false,round(480/48),[fsBold],255);

                                        mcelkem:=mbo.GetFieldValueAsfloat('Quantity');
                                        mdodano:=mbo.GetFieldValueAsfloat('DeliveredQuantity');
                                        mvychystano:=mbo.GetFieldValueAsfloat('X_dodano');

                                        m_umisteni:=mbo.GetFieldValueAsString('X_specifikace_id.Name');

                                        mQuanEdt:=CreateEdit_noformat('mQuanEdt', 'Celkem',mform, 10,350,70,80,150,NxFloatToIBStr(mcelkem),true,true,false,round(120/10),[fsBold],255) ;
                                        mDelQuanEdt:=CreateEdit_noformat('mDelQuanEdt', 'Dodano',mform, 90,350,70,80,150,NxFloatToIBStr(mdodano),true,true,false,round(120/10),[fsBold],255) ;
                                        mStorQuanEdt:=CreateEdit_noformat('mStorQuanEdt', 'Skladem',mform, 170,350,70,80,150,NxFloatToIBStr(mskladem),true,true,false,round(120/10),[fsBold],255) ;
                                        mVychQuanEdt:=CreateEdit_noformat('mVychQuanEdt', 'Vychystano',mform, 270,350,70,80,150,NxFloatToIBStr(mvychystano),true,true,false,round(120/10),[fsBold],255) ;


                                     //   if ((mbo_ReceivedOrder_row.GetFieldValueAsInteger('Storecard_id.Category')=3) or (mbo_ReceivedOrder_row.GetFieldValueAsInteger('Storecard_id.Category')=2)) and (mTBatches) then begin
                                     //           mBtn := TButton.Create(mForm);mBtn.Width := 75;mBtn.Height := 40;
                                     //           if (mbo_ReceivedOrder_row.GetFieldValueAsInteger('Storecard_id.Category')=2) then mBtn.Caption := 'Sériové číslo';
                                     //           if (mbo_ReceivedOrder_row.GetFieldValueAsInteger('Storecard_id.Category')=3) then mBtn.Caption := 'Šarže';
                                     //
                                     //           mBtn.ModalResult := 99;mBtn.Cancel := True;mBtn.Left := 10;mBtn.Top := mForm.Height - mBtn.Height - 60;mBtn.Visible:=true;mBtn.Name := 'btnŠarže';mForm.InsertControl(mBtn);
                                     //   end;

                                       mBtn := TButton.Create(mForm);mBtn.ModalResult := 2;mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := mbutton1; mBtn.Cancel := False;mBtn.Default := True;mBtn.Left:=mForm.Width - 2*(mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 40;mBtn.Name := 'btnOK';mForm.InsertControl(mBtn);
                                       mBtn := TButton.Create(mForm);mBtn.ModalResult := 0;mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := mbutton2;mBtn.Cancel := True;mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 40;mBtn.Name := 'btnCancel';mForm.InsertControl(mBtn);
                                       //mBtn := TButton.Create(mForm);mBtn.ModalResult := 1;mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := 'Zápis';mBtn.Cancel := True;mBtn.Left := 10;mBtn.Top := mForm.Height - mBtn.Height - 40;mBtn.Name := 'btnyestoall';mForm.InsertControl(mBtn);
                                       mBtn := TButton.Create(mForm);mBtn.ModalResult := 22;mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := 'Přerušit';mBtn.Cancel := True;mBtn.Left := mForm.Width - 3*(mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 40;mBtn.Name := 'btn99';mForm.InsertControl(mBtn);

      //                                 mBtn := TButton.Create(mForm);mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := 'OK';mBtn.ModalResult := mrOk; mBtn.Cancel := False;mBtn.Default := True;mBtn.Left:=mForm.Width - 2*(mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 60;mBtn.Name := 'btnOK';mForm.InsertControl(mBtn);
      //                                 mBtn := TButton.Create(mForm);mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := 'Storno';mBtn.ModalResult := mrCancel;mBtn.Cancel := True;mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 60;mBtn.Name := 'btnCancel';mForm.InsertControl(mBtn);


                                       mix_result:= mForm.ShowModal(xsite);   // změna položky




                                       //if (mix_result = 2) then exit;
                                       if mix_result=10 then mpocet:=mpocet-1;
                                                nxbeep(btSuccess);
                                       if mix_result=20 then begin
                                             mpocet:=mpocet+1;
                                           if mpocet>mcelkem-mdodano-mvychystano then begin
                                              nxbeep(btfailure);
                                              NxShowSimpleMessage('Max množství pro položku je ' + NxFloatToIBStr(mcelkem-mdodano - mvychystano) +
                                               ,nil);
                                               mpocet:=mcelkem-mdodano-mvychystano;

                                           end else begin
                                             nxbeep(btSuccess);
                                           end;
                                        end;

                                        if (mix_result = 22) then begin
                                           //if mCLSID_DOC='05CPMINJW3DL342X01C0CX3FCC' then begin
                                                              // postupný zápis
                                                              mi_SQL:=xsite.BaseObjectSpace.SQLExecute('update receivedorders2 set x_dodano=' + NxFloatToIBStr(mpocet + mbo.GetFieldValueAsFloat('X_dodano')) + ' where id=' + QuotedStr(mBO_Row_idx));
                                                              nxbeep(btSuccess);
                                                              mBO_Row_idx:='';
                                                              mpocet:=0;
                                                        // end;
                                                          //NxShowSimpleMessage('překročení počtu - zápis',nil);
                                                                abarcode:='.';
                                                                mStorecard_id:='';
                                                                  mstorecard_text:='';
                                                                  mdodano:=0 ;
                                                                  mvychystano:=0;
                                                                  mskladem:=0 ;
                                                                  mcelkem:=0;
                                                                  m_umisteni:='';
                                                                  mBO_Row_idx:='';
                                                                  mbarcode:='.';

                                           exit;
                                       end ;



                                       if (mix_result=2) then begin
                                           mbarcode:=mBarCodeEdt.text;

                                           if (ABarCode=mBarCode) and (ABarCode<>'.')   then begin
                                               mpocet:=mpocet+1;
                                               //NxShowSimpleMessage('stejný kód - ' + NxFloatToIBStr(mpocet) + ' - ' + inttostr(mix_result) + ' - ' + ABarCode + '/' + mbarcode,nil);
                                               if mpocet>mcelkem-mdodano-mvychystano then begin

                                                         mpocet:=mcelkem-mdodano-mvychystano;
                                                         // zápis
                                                         //if mCLSID_DOC='05CPMINJW3DL342X01C0CX3FCC' then begin
                                                              mi_SQL:=xsite.BaseObjectSpace.SQLExecute('update receivedorders2 set x_dodano=' + NxFloatToIBStr(mpocet + mbo.GetFieldValueAsFloat('X_dodano')) + ' where id=' + QuotedStr(mBO_Row_idx));
                                                              mBO_Row_idx:='';
                                                              nxbeep(btSuccess);

                                                              mpocet:=0;
                                                         //end;
                                                          //NxShowSimpleMessage('překročení počtu - zápis',nil);
                                                                abarcode:='.';
                                                                mStorecard_id:='';
                                                                  mstorecard_text:='';
                                                                  mdodano:=0 ;
                                                                  mvychystano:=0;
                                                                  mskladem:=0 ;
                                                                  mcelkem:=0;
                                                                  m_umisteni:='';
                                                                  mBO_Row_idx:='';
                                                                  mbarcode:='.';
                                                                  mBO_Row_idx:='';

                                               end;

                                        end else begin
                                               //
                                               if true then begin
                                                  //NxShowSimpleMessage('jiná položka',nil);
                                                  if mStorecard_id<>'' then  begin
                                                      //if mCLSID_DOC='05CPMINJW3DL342X01C0CX3FCC' then begin
                                                              // postupný zápis
                                                              mi_SQL:=xsite.BaseObjectSpace.SQLExecute('update receivedorders2 set x_dodano=' + NxFloatToIBStr(mpocet + mbo.GetFieldValueAsFloat('X_dodano')) + ' where id=' + QuotedStr(mBO_Row_idx));
                                                              nxbeep(btSuccess);
                                                              mBO_Row_idx:='';

                                                              mpocet:=0;

                                                                mStorecard_id:='';
                                                                  mstorecard_text:='';
                                                                  mdodano:=0 ;
                                                                  mvychystano:=0;
                                                                  mskladem:=0 ;
                                                                  mcelkem:=0;
                                                                  m_umisteni:='';
                                                                  mBO_Row_idx:='';

                                                      //end;
                                                   end;
                                                           if mBO_Row_idx='' then begin
                                                                mll:=TStringList.create;
                                                                try
                                                                    //
                                                                    xsite.BaseObjectSpace.SQLSelect(format('select ro2.id|| '';'' ||ro.id|| '';'' ||DQ.Code || ''-'' || CAST(RO.OrdNumber AS VARCHAR(10)) || ''/'' || P.Code|| '';'' || '' množství : '' || CAST(round(RO2.Quantity - RO2.DeliveredQuantity - RO2.X_dodano,1) AS VARCHAR(10))  || '' - '' ||  F.name from STOREEANS SE left join StoreUnits SU on SU.id=se.Parent_id left join Storecards SC on sc.id=su.parent_id left join ReceivedOrders2 RO2 on ro2.storecard_id=sc.id left join ReceivedOrders RO on ro.id=ro2.parent_id left join firms F on f.id=ro.Firm_ID left join Docqueues DQ on dq.id=ro.docqueue_ID left join Periods P on p.id=ro.Period_ID where (RO.closed = ''N'' ) and ((RO2.Quantity - RO2.DeliveredQuantity - RO2.X_dodano)>0) and (se.EAN=%s and (RO.ID in (%s)))'
                                                                    ,[quotedstr(mbarcode),mIDs_dDocument])
                                                                      ,mLL);

                                                                    if mLL.Count>0 then begin

                                                                         mLL.Add('');
                                                                         mLL.Add('');
                                                                         mLL.Add('');
                                                                         mLL.Add('');
                                                                         mLL.Add('');
                                                                         mLL.Add('');
                                                                         mLL.Add('');
                                                                         mLL.Add('');
                                                                         mLL.Add('');
                                                                         mLL.Add('');

                                                                         mI_Resultxax:=mForm_FunctionDoklad(xsite,0,0,360,480,'Výběr','Objednávky','Nevykryté',
                                                                                mll.strings[0],
                                                                                mll.strings[1],
                                                                                mll.strings[2],
                                                                                mll.strings[3],
                                                                                mll.strings[4],
                                                                                mll.strings[5],
                                                                                mll.strings[6],
                                                                                mll.strings[7],
                                                                                mll.strings[8],
                                                                                'Zpět');

                                                                         //NxShowSimpleMessage(IntToStr(mI_Resultxax),nil);
                                                                         //NxShowSimpleMessage(copy(mll.strings[mI_Resultxax-1],21,20),nil);

                                                                         if (mI_Resultxax<>10) and (mI_Resultxax<>0) then begin
                                                                            mBO_Row_idx:=copy(mll.strings[mI_Resultxax-1],2,10);
                                                                            nxbeep(btSuccess);
                                                                         end else begin
                                                                            mBO_Row_idx:='';
                                                                            if mI_Resultxax=10 then begin
                                                                               NxShowSimpleMessage('Zadávání bylo přerušeno',nil);
                                                                               nxbeep(btfailure);
                                                                               end;
                                                                            if mI_Resultxax=0 then begin NxShowSimpleMessage('Doklad nebyl dohledán',nil);
                                                                                nxbeep(btfailure);
                                                                            end;

                                                                         end;
                                                                    end;

                                                                finally
                                                                   mll.free;
                                                                end;
                                                           end;

                                                                        if mBO_Row_idx<>'' then begin

                                                                                  mbo.load(mBO_Row_idx,nil);

                                                                                  mStorecard_id:=mbo.GetFieldValueAsString('storecard_id');
                                                                                  //NxShowSimpleMessage(mStorecard_id,nil);
                                                                                  mTypSC:=mbo.GetFieldValueAsInteger('storecard_id.category');
                                                                                  mstorecard_text:=mbo.GetFieldValueAsString('storecard_id.name');
                                                                                         mcelkem:=mbo.GetFieldValueAsfloat('Quantity');
                                                                                         mdodano:=mbo.GetFieldValueAsfloat('DeliveredQuantity');
                                                                                         mvychystano:=mbo.GetFieldValueAsfloat('X_dodano');

                                                                                  m_umisteni:=mbo.GetFieldValueAsString('X_specifikace_id.Name');
                                                                                  mjednotka:=mbo.GetFieldValueAsstring('Qunit') ;


                                                                                  mpocet:=mpocet+1;

                                                                                   ABarCode:=mbarcode;

                                                                       end;






                                                          {if mr.count=0 then begin
                                                                NxShowSimpleMessage('Ean není v dokladu čerpatelný',nil);
                                                                abarcode:='.';
                                                                mbarcode:='.';
                                                                mStorecard_id:='';
                                                                  mstorecard_text:='';
                                                                  mdodano:=0 ;
                                                                  mvychystano:=0;
                                                                  mskladem:=0 ;
                                                                  mcelkem:=0;
                                                                  m_umisteni:='';
                                                                  mBO_Row_id:='';
                                                                  mpocet:=0;
                                                            end;   }








                                               end;




                                       end;    // mi result=2


                  end;
                  finally
                      mForm.free;
                  end;
            end;  // pokračovat
      end;     // while
      finally
            mBO.free  ;
      end;



      xSite.Refresh;
      result:='A';

end;



function BarCode_document_Agenda(xSite:TSiteForm;mCLSID_DOC:string):string;
var
    mDBGrid : TDBGrid;
    mTabList: TTabSheet;
    i : integer;
    mBookmarkList:TBookmarkList ;
    mStrins_id:string;
begin
        mTabList:= TTabSheet(NxFindChildControl(xSite.MainPanel, 'tabList'));
        if mTabList = nil then RaiseException('tabList nenalezen');
        mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
        if mDBGrid = nil then RaiseException('DBGrid nenalezen');
       mBookmarkList := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu

          if mBookmarkList.count=0 then begin
              mStrins_id:=quotedstr(TDynSiteForm(xSite).CurrentObject.oid);

        end else begin
             for i := 0 to mBookmarkList.Count-1 do begin // projdu vsechny oznacene zaznamy
                  mDBGrid.DataSource.DataSet.GotoBookmark(mBookmarkList.items(i));
                      if i=0 then mStrins_id:=quotedstr(TDynSiteForm(xSite).CurrentObject.oid);
                      if i>0 then mStrins_id:=mStrins_id+',' + quotedstr(TDynSiteForm(xSite).CurrentObject.oid) ;


             end;
        end;
        result:=mStrins_id;
end;


function BarCode_batch(xSite:TSiteForm;mCLSID_DOC:string;
                          mTop:integer;mLeft:integer;mWith:integer;mHeight:integer;
                          mrow:TNxCustomBusinessObject;mLabel:string;mButton1,mbutton2,mbutton3,mbutton4:string):TStringList;
var
      mForm : TForm;
      mBtn : TButton;
      mLbl : TLabel;
      mBarCodeEdt : TEdit;
      i:integer;
      xresult:Variant;
      //mSCEdt:TRollComboEdit;
      mSCEdt:TEdit;
      ABarCode,mbarcode:string;
      mi_resulta:integer;
      mBatch_id,mStorecard_id,m_umisteni,mjednotka:string;
      mr,mr1:tstringlist;
      mBO,mSSC:TNxCustomBusinessObject;
      mi_SQL:integer;
      mStrins_id,mS_doklady:string;
      mMemNote:TMemo;
      mxx,mxb:tstringlist;
begin

      i:=1;
      ABarCode := '.';
      mBarCode:='';
     mStrins_id:='';
     mS_doklady:='';
      mi_resulta:=0;
     mxx:=tstringlist.create;
      while mi_resulta<>10 do begin

            try
           mForm := TForm.Create(xsite);
           if True then mForm.Color := clBtnFace else mForm.Color:= clRed ;
                                  mForm.Caption := mLabel;mForm.FormStyle := fsStayOnTop;mForm.BorderStyle := bsDialog;
                                  if mTop>=0 then begin
                                    mForm.Top:= mTop;
                                    mForm.Left:= mLeft;
                                  end else begin
                                    mform.Position := poScreenCenter;
                                  end;

                                  mForm.Width := mWith;mForm.Height := mHeight;mForm.Scaled := False;
                                  mBarCodeEdt:=CreateEdit('mBarCodeEdt', 'Čarový kód',mform, 10,10,300,80,150,'',true,true,true,round(480/24), [fsBold],255) ;



                                    mMemNote := CreateMemo('ChMemNote','Doklady', 10, 80, 300,250, 150, mS_doklady, mForm,true,true,false,round(480/24), [fsBold],255);




                                 mBtn := TButton.Create(mForm);mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := mButton1;mBtn.ModalResult := 1; mBtn.Cancel := False;mBtn.Default := True;mBtn.Left:=mForm.Width - 2*(mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 60;mBtn.Name := 'btnOK';mForm.InsertControl(mBtn);
                                 mBtn := TButton.Create(mForm);mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := mbutton2;mBtn.ModalResult := 10;mBtn.Cancel := True;mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 60;mBtn.Name := 'btnCancel';mForm.InsertControl(mBtn);

                                 mi_resulta:= mForm.ShowModal(xsite);   // změna položky

                                 if mi_resulta<>10 then begin
                                      abarcode:=mBarCodeEdt.text;


                                        if mi_resulta=1 then begin
                                            if mBarCodeEdt.text<>'' then begin
                                                   mxb:=tstringlist.create;
                                                   try
                                                        xsite.BaseObjectSpace.SQLSelect(format('select id from StoreBatches where name=%s and Storecard_id=%S',[quotedstr(mBarCodeEdt.text),quotedstr(mrow.GetFieldValueAsString('Storecard_id'))]), mxb);
                                                        if mr.count>0 then begin
                                                           mxx.Add(mBarCodeEdt.text);
                                                        end else begin
                                                           NxShowSimpleMessage('Šarže nedohledána',nil);
                                                           nxbeep(btfailure);
                                                        end;
                                                   finally
                                                       mxb.free;
                                                   end;
                                                   NxShowSimpleMessage(mBarCodeEdt.text,nil);
                                                   nxbeep(btSuccess);

                                            end;
                                        end;

                                end else begin
                                mi_resulta:=10;
                               end;
      finally
        mform.Free;
      end;
      end;
  result:= mxx;

end;



function BarCode_Worker(xSite:TSiteForm;mCLSID_DOC:string;
                          mTop:integer;mLeft:integer;mWith:integer;mHeight:integer;mLabel:string;
                          mID_doklad:string;mButton1,mbutton2,mbutton3,mbutton4:string):string;
var
      mForm : TForm;
      mBtn : TButton;
      mLbl : TLabel;
      mBarCodeEdt : TEdit;
      i:integer;
      xresult:Variant;
      //mSCEdt:TRollComboEdit;
      mSCEdt:TEdit;
      ABarCode,mbarcode:string;
      mi_resulta:integer;
      mBatch_id,mStorecard_id,m_umisteni,mjednotka:string;
      mr,mr1:tstringlist;
      mBO,mSSC:TNxCustomBusinessObject;
      mi_SQL:integer;
      mStrins_id,mS_doklady:string;
      mMemNote:TMemo;
begin
      Result :='' ;
      i:=1;
      ABarCode := '.';
      mBarCode:='';
     mStrins_id:='';
     mS_doklady:='';
     mID_doklad:='';
      mi_resulta:=0;
      while mi_resulta<>10 do begin

            try
           mForm := TForm.Create(xsite);
           if True then mForm.Color := clBtnFace else mForm.Color:= clRed ;
                                  mForm.Caption := mLabel;mForm.FormStyle := fsStayOnTop;mForm.BorderStyle := bsDialog;
                                  if mTop>=0 then begin
                                    mForm.Top:= mTop;
                                    mForm.Left:= mLeft;
                                  end else begin
                                    mform.Position := poScreenCenter;
                                  end;

                                  mForm.Width := mWith;mForm.Height := mHeight;mForm.Scaled := False;
                                  mBarCodeEdt:=CreateEdit('mBarCodeEdt', 'Čarový kód',mform, 10,10,300,80,150,'',true,true,true,round(480/24), [fsBold],255) ;
                                    mMemNote := CreateMemo('ChMemNote',mlabel, 10, 80, 300,250, 150, mS_doklady, mForm,true,true,false,round(480/24), [fsBold],255);

                                 mBtn := TButton.Create(mForm);mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := mButton1;mBtn.ModalResult := 1; mBtn.Cancel := False;mBtn.Default := True;mBtn.Left:=mForm.Width - 2*(mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 60;mBtn.Name := 'btnOK';mForm.InsertControl(mBtn);
                                 mBtn := TButton.Create(mForm);mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := mbutton2;mBtn.ModalResult := 10;mBtn.Cancel := True;mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 60;mBtn.Name := 'btnCancel';mForm.InsertControl(mBtn);

                                 mi_resulta:= mForm.ShowModal(xsite);   // změna položky

                               //  if mi_resulta<>10 then begin
                                      abarcode:=mBarCodeEdt.text;


                                        if mi_resulta=1 then begin
                                            if mBarCodeEdt.text<>'' then begin

                                                mr:= tstringlist.create;
                                                try
                                                        xsite.BaseObjectSpace.SQLSelect('select id from PLMWorkers where id=' + quotedstr(abarcode) ,mr);
                                                        if mr.count>0 then begin
                                                             mBOWorker.load(mr.Strings[0],nil);
                                                        end else begin
                                                            NxShowSimpleMessage('Uživatel není dohledán',xsite);
                                                            mBOWorker.load('6400000101',nil);
                                                        end;
                                                finally
                                                    mr.free;
                                                end;
                                            end;
                                        end;

                              //  end else begin
                                mi_resulta:=10;
                              // end;
      finally
        mform.Free;
      end;
      end;
  result:= mStrins_id;

end;


function BarCode_machine(xSite:TSiteForm;mCLSID_DOC:string;
                          mTop:integer;mLeft:integer;mWith:integer;mHeight:integer;mLabel:string;
                          mID_doklad:string;mButton1,mbutton2,mbutton3,mbutton4:string):string;
var
      mForm : TForm;
      mBtn : TButton;
      mLbl : TLabel;
      mBarCodeEdt : TEdit;
      i:integer;
      xresult:Variant;
      //mSCEdt:TRollComboEdit;
      mSCEdt:TEdit;
      ABarCode,mbarcode:string;
      mi_resulta:integer;
      mBatch_id,mStorecard_id,m_umisteni,mjednotka:string;
      mr,mr1:tstringlist;
      mBO,mSSC:TNxCustomBusinessObject;
      mi_SQL:integer;
      mStrins_id,mS_doklady:string;
      mMemNote:TMemo;
begin
      Result :='' ;
      i:=1;
      ABarCode := '.';
      mBarCode:='';
     mStrins_id:='';
     mS_doklady:='';
     mID_doklad:='';
      mi_resulta:=0;
      while mi_resulta<>10 do begin

            try
           mForm := TForm.Create(xsite);
           if True then mForm.Color := clBtnFace else mForm.Color:= clRed ;
                                  mForm.Caption := mLabel;mForm.FormStyle := fsStayOnTop;mForm.BorderStyle := bsDialog;
                                  if mTop>=0 then begin
                                    mForm.Top:= mTop;
                                    mForm.Left:= mLeft;
                                  end else begin
                                    mform.Position := poScreenCenter;
                                  end;

                                  mForm.Width := mWith;mForm.Height := mHeight;mForm.Scaled := False;
                                  mBarCodeEdt:=CreateEdit('mBarCodeEdt', 'Čarový kód',mform, 10,10,300,80,150,'',true,true,true,round(480/24), [fsBold],255) ;
                                    mMemNote := CreateMemo('ChMemNote',mlabel, 10, 80, 300,250, 150, mS_doklady, mForm,true,true,false,round(480/24), [fsBold],255);

                                 mBtn := TButton.Create(mForm);mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := mButton1;mBtn.ModalResult := 1; mBtn.Cancel := False;mBtn.Default := True;mBtn.Left:=mForm.Width - 2*(mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 60;mBtn.Name := 'btnOK';mForm.InsertControl(mBtn);
                                 mBtn := TButton.Create(mForm);mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := mbutton2;mBtn.ModalResult := 10;mBtn.Cancel := True;mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 60;mBtn.Name := 'btnCancel';mForm.InsertControl(mBtn);

                                 mi_resulta:= mForm.ShowModal(xsite);   // změna položky

                                // if mi_resulta<>10 then begin
                                      abarcode:=mBarCodeEdt.text;


                                        if mi_resulta=1 then begin
                                            if mBarCodeEdt.text<>'' then begin

                                                mr:= tstringlist.create;
                                                try
                                                        xsite.BaseObjectSpace.SQLSelect('select id from PLMWorkPlaces where id=' + quotedstr(mBarCodeEdt.text) ,mr);
                                                     if mr.count>0 then begin
                                                             result:=mr.Strings[0];
                                                        end else begin
                                                            NxShowSimpleMessage('Stroj není dohledán',xsite);
                                                            result:='3380000101';
                                                        end;
                                                finally
                                                    mr.free;
                                                end;
                                            end;

                                        end;

                                //end else begin
                                mi_resulta:=10;
                               //end;
      finally
        mform.Free;
      end;
      end;

end;


function BarCode_VP(xSite:TSiteForm;mCLSID_DOC:string;
                          mTop:integer;mLeft:integer;mWith:integer;mHeight:integer;mLabel:string;
                          mID_doklad:string;mButton1,mbutton2,mbutton3,mbutton4:string):string;
var
      mForm : TForm;
      mBtn : TButton;
      mLbl : TLabel;
      mBarCodeEdt : TEdit;
      i:integer;
      xresult:Variant;
      //mSCEdt:TRollComboEdit;
      mSCEdt:TEdit;
      ABarCode,mbarcode:string;
      mi_resulta:integer;
      mBatch_id,mStorecard_id,m_umisteni,mjednotka:string;
      mr,mr1:tstringlist;
      mBO,mSSC:TNxCustomBusinessObject;
      mi_SQL:integer;
      mStrins_id,mS_doklady:string;
      mMemNote:TMemo;
begin
      Result :='' ;
      i:=1;
      ABarCode := '.';
      mBarCode:='';
     mStrins_id:='';
     mS_doklady:='';
     mID_doklad:='';
      mi_resulta:=0;
      while mi_resulta<>10 do begin

            try
           mForm := TForm.Create(xsite);
           if True then mForm.Color := clBtnFace else mForm.Color:= clRed ;
                                  mForm.Caption := mLabel;mForm.FormStyle := fsStayOnTop;mForm.BorderStyle := bsDialog;
                                  if mTop>=0 then begin
                                    mForm.Top:= mTop;
                                    mForm.Left:= mLeft;
                                  end else begin
                                    mform.Position := poScreenCenter;
                                  end;

                                  mForm.Width := mWith;mForm.Height := mHeight;mForm.Scaled := False;
                                  mBarCodeEdt:=CreateEdit('mBarCodeEdt', 'Čarový kód',mform, 10,10,300,80,150,'',true,true,true,round(480/24), [fsBold],255) ;
                                    mMemNote := CreateMemo('ChMemNote',mlabel, 10, 80, 300,250, 150, mS_doklady, mForm,true,true,false,round(480/24), [fsBold],255);

                                 mBtn := TButton.Create(mForm);mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := mButton1;mBtn.ModalResult := 1; mBtn.Cancel := False;mBtn.Default := True;mBtn.Left:=mForm.Width - 2*(mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 60;mBtn.Name := 'btnOK';mForm.InsertControl(mBtn);
                                 mBtn := TButton.Create(mForm);mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := mbutton2;mBtn.ModalResult := 10;mBtn.Cancel := True;mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 60;mBtn.Name := 'btnCancel';mForm.InsertControl(mBtn);

                                 mi_resulta:= mForm.ShowModal(xsite);   // změna položky

                                      abarcode:=mBarCodeEdt.text;


                                    //    if mi_resulta=1 then begin
                                            if mBarCodeEdt.text<>'' then begin

                                                mID_doklad:=GetVP_ID(xSite,'PLMJobOrders',quotedstr(mBarCodeEdt.text));
                                                if  mID_doklad='' then begin
                                                     NxMessageBox('Chyba', 'Doklad není dohledán', mdConfirm, mdbOkCancel, 0, 0, true, nil) ;
                                                     nxbeep(btfailure);
                                                     result:= '';
                                                end else begin
                                                   //NxShowSimpleMessage(mID_doklad,nil);
                                                   result:= mID_doklad;
                                                   mi_resulta:=10
                                                 end;
                                            end;
                                    //    end;



      finally
        mform.Free;
      end;
      end;


end;











function BarCode_document(xSite:TSiteForm;mCLSID_DOC:string;
                          mTop:integer;mLeft:integer;mWith:integer;mHeight:integer;mLabel:string;
                          mID_doklad:string;mButton1,mbutton2,mbutton3,mbutton4:string):string;
var
      mForm : TForm;
      mBtn : TButton;
      mLbl : TLabel;
      mBarCodeEdt : TEdit;
      i:integer;
      xresult:Variant;
      //mSCEdt:TRollComboEdit;
      mSCEdt:TEdit;
      ABarCode,mbarcode:string;
      mi_resulta:integer;
      mBatch_id,mStorecard_id,m_umisteni,mjednotka:string;
      mr,mr1:tstringlist;
      mBO,mSSC:TNxCustomBusinessObject;
      mi_SQL:integer;
      mStrins_id,mS_doklady:string;
      mMemNote:TMemo;
begin
      Result :='' ;
      i:=1;
      ABarCode := '.';
      mBarCode:='';
     mStrins_id:='';
     mS_doklady:='';
     mID_doklad:='';
      mi_resulta:=0;
      while mi_resulta<>10 do begin

            try
           mForm := TForm.Create(xsite);
           if True then mForm.Color := clBtnFace else mForm.Color:= clRed ;
                                  mForm.Caption := mLabel;mForm.FormStyle := fsStayOnTop;mForm.BorderStyle := bsDialog;
                                  if mTop>=0 then begin
                                    mForm.Top:= mTop;
                                    mForm.Left:= mLeft;
                                  end else begin
                                    mform.Position := poScreenCenter;
                                  end;

                                  mForm.Width := mWith;mForm.Height := mHeight;mForm.Scaled := False;
                                  mBarCodeEdt:=CreateEdit('mBarCodeEdt', 'Čarový kód',mform, 10,10,300,80,150,'',true,true,true,round(480/24), [fsBold],255) ;
                                    mMemNote := CreateMemo('ChMemNote',mlabel, 10, 80, 300,250, 150, mS_doklady, mForm,true,true,false,round(480/24), [fsBold],255);

                                 mBtn := TButton.Create(mForm);mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := mButton1;mBtn.ModalResult := 1; mBtn.Cancel := False;mBtn.Default := True;mBtn.Left:=mForm.Width - 2*(mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 60;mBtn.Name := 'btnOK';mForm.InsertControl(mBtn);
                                 mBtn := TButton.Create(mForm);mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := mbutton2;mBtn.ModalResult := 10;mBtn.Cancel := True;mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 60;mBtn.Name := 'btnCancel';mForm.InsertControl(mBtn);

                                 mi_resulta:= mForm.ShowModal(xsite);   // změna položky

                                 if mi_resulta<>10 then begin
                                      abarcode:=mBarCodeEdt.text;


                                        if mi_resulta=1 then begin
                                            if mBarCodeEdt.text<>'' then begin
                                                mID_doklad:=GetDocument_ID(xSite,'ReceivedOrders',abarcode);
                                                if  (mID_doklad<>'') and (mID_doklad<>'Více') then begin


                                                            if mStrins_id<>'' then mStrins_id:=mStrins_id +',';
                                                            if mS_doklady<>'' then mS_doklady:=mS_doklady +',';


                                                            mStrins_id:=mStrins_id + QuotedStr(mID_doklad);
                                                            mS_doklady:=mS_doklady+ ' ' + abarcode;
                                                 end else begin
                                                     //NxShowSimpleMessage('Doklad není dohledán',nil);
                                                     NxMessageBox('Chyba', 'Doklad není dohledán', mdConfirm, mdbOkCancel, 0, 0, true, nil) ;
                                                     nxbeep(btfailure);

                                                 end;
                                            end;
                                        end;

                                end else begin
                                mi_resulta:=10;
                               end;
      finally
        mform.Free;
      end;
      end;
  result:= mStrins_id;

end;

function mForm_Function(xSite:TSiteForm;mTop:integer;mLeft:integer;mWith:integer;mHeight:integer;mLabel:string;mDescription:string;mDescription1:string;mbuton1:string;mbuton2:string;mbuton3:string;mbuton4:string;mbuton5:string;mbuton6:string;mbuton7:string;mbuton8:string;mbuton9:string;mbuton10:string):Variant;
var
mform:tform;
mBtn : TButton;
mlabel2,mlabel3:TLabel;
mFont: TFont;
mPocet:integer;
mpozice:Integer;
begin
mPocet:=1;
if mDescription<>'' then mPocet:=mpocet+1;
if mDescription1<>'' then mPocet:=mpocet+1;

if mbuton1<>'' then mPocet:=mpocet+1;
if mbuton2<>'' then mPocet:=mpocet+1;
if mbuton3<>'' then mPocet:=mpocet+1;
if mbuton4<>'' then mPocet:=mpocet+1;
if mbuton5<>'' then mPocet:=mpocet+1;
if mbuton6<>'' then mPocet:=mpocet+1;
if mbuton7<>'' then mPocet:=mpocet+1;
if mbuton8<>'' then mPocet:=mpocet+1;
if mbuton9<>'' then mPocet:=mpocet+1;
if mbuton10<>'' then mPocet:=mpocet+1;

            mForm := TForm.Create(xsite);
            try
                                  mpozice:=0;
                                  mForm.Caption := mLabel;
                                  mForm.FormStyle := fsStayOnTop;
                                  //mForm.BorderStyle := bsDialog;
                                  mForm.Left:= mLeft;
                                  mForm.Top := mTop;
                                  mForm.Width := mWith;
                                  if True then mForm.Color := clGreen else mForm.Color:= clRed ;     //clBtnFace
                                  mForm.Height := mHeight;
                                  mForm.Scaled := False;
                                  //mform.Position := poScreenCenter;



                                  if mDescription<>'' then begin

                                          CreateLabel('mLabel2', mDescription,mForm,
                                              10, mpozice*(round(mForm.Height/(mpocet))) +5, 340,round(mForm.Height/(mpocet)),
                                              True,False,
                                              round(480/24/(mpocet/4)),[fsBold],255);
                                              mpozice:=mpozice+1;
                                   end;
                                   if mDescription1<>'' then begin

                                          CreateLabel('mLabel3', mDescription1,mForm,
                                              10,mpozice*(round(mForm.Height/(mpocet))) , 340, round(mForm.Height/(mpocet)),
                                              True,False,
                                              round(480/24/(mpocet/4)),[fsBold],255);
                                              mpozice:=mpozice+1;
                                   end;





                                if mbuton1<>'' then begin

                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := mForm.Width-80;
                                      mBtn.Height := round(mForm.Height/(mpocet ));
                                    mBtn.Caption := mbuton1;
                                    mFont := mBtn.Font;
                                       mFont.Size := round(480/24/(mpocet/4));
                                       mFont.Style := [fsBold];

                                    mBtn.ModalResult := 1;
                                    mBtn.Cancel := False;
                                    mBtn.Default := false;
                                    mBtn.Left :=  round((mForm.Width - (mBtn.Width))/2-10) ;
                                    mBtn.Top :=mpozice*(round(mForm.Height/(mpocet)))-10 ; // // mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'mbuton1';
                                    mForm.InsertControl(mBtn);
                                    mpozice:=mpozice+1;
                                end;


                                if mbuton2<>'' then begin

                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := mForm.Width-80;
                                      mBtn.Height := round(mForm.Height/(mpocet ));
                                    mBtn.Caption := mbuton2;
                                    mFont := mBtn.Font;
                                       mFont.Size := round(480/24/(mpocet/4));
                                       mFont.Style := [fsBold];
                                    mBtn.ModalResult := 2;
                                    mBtn.Cancel := False;
                                    mBtn.Default := False;
                                    mBtn.Left :=  round((mForm.Width - (mBtn.Width))/2)-10 ;
                                    mBtn.Top :=mpozice*(mBtn.Height) -10; // mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'mbuton2';
                                    mForm.InsertControl(mBtn);
                                     mpozice:=mpozice+1;
                                end;

                                if mbuton3<>'' then begin

                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := mForm.Width-80;
                                      mBtn.Height := round(mForm.Height/(mpocet ));
                                    mBtn.Caption := mbuton3;
                                    mFont := mBtn.Font;
                                       mFont.Size := round(480/24/(mpocet/4));
                                       mFont.Style := [fsBold];
                                    mBtn.ModalResult := 3;
                                    mBtn.Cancel := False;
                                    mBtn.Default := False;
                                    mBtn.Left :=  round((mForm.Width - (mBtn.Width))/2) -10;
                                    mBtn.Top :=mpozice*(mBtn.Height)-10 ; // mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'mbuton3';
                                    mForm.InsertControl(mBtn);
                                    mpozice:=mpozice+1;
                                    end;


                                    if mbuton4<>'' then begin

                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := mForm.Width-80;
                                      mBtn.Height := round(mForm.Height/(mpocet ));
                                    mBtn.Caption := mbuton4;
                                    mFont := mBtn.Font;
                                       mFont.Size := round(480/24/(mpocet/4));
                                       mFont.Style := [fsBold];
                                    mBtn.ModalResult := 4;
                                    mBtn.Cancel := False;
                                    mBtn.Default := False;
                                    mBtn.Left :=  round((mForm.Width - (mBtn.Width))/2) -10;
                                    mBtn.Top :=mpozice*(mBtn.Height) -10; // mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'mbuton4';
                                    mForm.InsertControl(mBtn);
                                    mpozice:=mpozice+1;
                                    end;



                                    if mbuton5<>'' then begin

                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := mForm.Width-80;
                                      mBtn.Height := round(mForm.Height/(mpocet ));
                                    mBtn.Caption := mbuton5;
                                    mFont := mBtn.Font;
                                       mFont.Size := round(480/24/(mpocet/4));
                                       mFont.Style := [fsBold];
                                    mBtn.ModalResult := 5;
                                    mBtn.Cancel := False;
                                    mBtn.Default := False;
                                    mBtn.Left :=  round((mForm.Width - (mBtn.Width))/2) -10;
                                    mBtn.Top :=mpozice*(mBtn.Height)-10 ; // mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'mbuton5';
                                    mForm.InsertControl(mBtn);
                                    mpozice:=mpozice+1;
                                    end;


                                    if mbuton6<>'' then begin

                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := mForm.Width-80;
                                      mBtn.Height := round(mForm.Height/(mpocet ));
                                    mBtn.Caption := mbuton6;
                                    mFont := mBtn.Font;
                                       mFont.Size := round(480/24/(mpocet/4));
                                       mFont.Style := [fsBold];
                                    mBtn.ModalResult := 6;
                                    mBtn.Cancel := False;
                                    mBtn.Default := False;
                                    mBtn.Left :=  round((mForm.Width - (mBtn.Width))/2) -10;
                                    mBtn.Top :=mpozice*(mBtn.Height)-10; // mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'mbuton6';
                                    mForm.InsertControl(mBtn);
                                    mpozice:=mpozice+1;
                                    end;


                                    if mbuton7<>'' then begin

                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := mForm.Width-80;
                                      mBtn.Height := round(mForm.Height/(mpocet ));
                                    mBtn.Caption := mbuton7;
                                    mFont := mBtn.Font;
                                       mFont.Size := round(480/24/(mpocet/4));
                                       mFont.Style := [fsBold];
                                    mBtn.ModalResult := 7;
                                    mBtn.Cancel := False;
                                    mBtn.Default := False;
                                    mBtn.Left :=  round((mForm.Width - (mBtn.Width))/2) -10;
                                    mBtn.Top :=mpozice*(mBtn.Height)-10; // mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'mbuton7';
                                    mForm.InsertControl(mBtn);
                                    mpozice:=mpozice+1;
                                    end;


                                    if mbuton8<>'' then begin

                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := mForm.Width-80;
                                      mBtn.Height := round(mForm.Height/(mpocet ));
                                    mBtn.Caption := mbuton8;
                                    mFont := mBtn.Font;
                                       mFont.Size := round(480/24/(mpocet/4));
                                       mFont.Style := [fsBold];
                                    mBtn.ModalResult := 8;
                                    mBtn.Cancel := False;
                                    mBtn.Default := False;
                                    mBtn.Left :=  round((mForm.Width - (mBtn.Width))/2) -10;
                                    mBtn.Top :=mpozice*(mBtn.Height)-10 ; // mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'mbuton8';
                                    mForm.InsertControl(mBtn);
                                    mpozice:=mpozice+1;
                                    end;


                                    if mbuton9<>'' then begin

                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := mForm.Width-80;
                                      mBtn.Height := round(mForm.Height/(mpocet ));
                                    mBtn.Caption := mbuton9;
                                    mFont := mBtn.Font;
                                       mFont.Size := round(480/24/(mpocet/4));
                                       mFont.Style := [fsBold];
                                    mBtn.ModalResult := 9;
                                    mBtn.Cancel := False;
                                    mBtn.Default := False;
                                    mBtn.Left :=  round((mForm.Width - (mBtn.Width))/2) -10;
                                    mBtn.Top :=mpozice*(mBtn.Height)-10 ; // mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'mbuton9';
                                    mForm.InsertControl(mBtn);
                                    mpozice:=mpozice+1;
                                    end;

                                if mbuton10<>'' then begin

                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := mForm.Width-80;
                                      mBtn.Height := Round(mForm.Height/(mpocet));
                                    mFont := mBtn.Font;
                                       mFont.Size := round(480/24/(mpocet/4));
                                       mFont.Style := [fsBold];
                                    mBtn.Caption := mbuton10;
                                    mBtn.ModalResult := 10;
                                    mBtn.Cancel := True;
                                    mBtn.Left :=  round((mForm.Width - (mBtn.Width))/2)-10 ;
                                    mBtn.Top := mpozice*(round(mForm.Height/(mpocet)))-10 ; // // mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'mbuton10';
                                    mForm.InsertControl(mBtn);
                                    mpozice:=mpozice+1;

                                end;

                                result:=mForm.ShowModal(xSite)
                    finally

                  mform.free;
                    end;
end;





function mForm_FunctionDoklad(xSite:TSiteForm;mTop:integer;mLeft:integer;mWith:integer;mHeight:integer;mLabel:string;mDescription:string;mDescription1:string;mbuton1:string;mbuton2:string;mbuton3:string;mbuton4:string;mbuton5:string;mbuton6:string;mbuton7:string;mbuton8:string;mbuton9:string;mbuton10:string):Variant;
var
mform:tform;
mBtn : TButton;
mlabel2,mlabel3:TLabel;
mFont: TFont;
mPocet:integer;
mpozice:Integer;
mBarCodeEdtx:TEdit;
mdoklad:string;
mix:integer;
mpokracuj:boolean;
mID_doklad:string;
begin
mpokracuj:=True;
result:=0;

//while Result=0  do begin
      mPocet:=1;
      if mDescription<>'' then mPocet:=mpocet+1;
      if mDescription1<>'' then mPocet:=mpocet+1;

      if mbuton1<>'' then mPocet:=mpocet+1;
      if mbuton2<>'' then mPocet:=mpocet+1;
      if mbuton3<>'' then mPocet:=mpocet+1;
      if mbuton4<>'' then mPocet:=mpocet+1;
      if mbuton5<>'' then mPocet:=mpocet+1;
      if mbuton6<>'' then mPocet:=mpocet+1;
      if mbuton7<>'' then mPocet:=mpocet+1;
      if mbuton8<>'' then mPocet:=mpocet+1;
      if mbuton9<>'' then mPocet:=mpocet+1;
      if mbuton10<>'' then mPocet:=mpocet+1;

//      while mpokracuj do begin
            mForm := TForm.Create(xsite);
            try
                                  mpozice:=0;
                                  mForm.Caption := mLabel;
                                  mForm.FormStyle := fsStayOnTop;
                                  mForm.BorderStyle := bsDialog;
                                  mForm.Left:= mLeft;
                                  mForm.Top := mTop;
                                  mForm.Width := mWith;

                                  mForm.Height := mHeight;
                                  mForm.Scaled := False;
                                  //mform.Position := poScreenCenter;



                                  if mDescription<>'' then begin

                                          CreateLabel('mLabel2', mDescription,mForm,
                                              10, mpozice*(round(mForm.Height/(mpocet))) +5, 340,round(mForm.Height/(mpocet)),
                                              True,False,
                                              round(480/24/(mpocet/4)),[fsBold],255);
                                              mpozice:=mpozice+1;
                                   end;
                                   if mDescription1<>'' then begin

                                          CreateLabel('mLabel3', mDescription1,mForm,
                                              10,mpozice*(round(mForm.Height/(mpocet))) , 340, round(mForm.Height/(mpocet)),
                                              True,False,
                                              round(480/24/(mpocet/4)),[fsBold],255);
                                              mpozice:=mpozice+1;
                                   end;

                                mBarCodeEdtx:=CreateEdit('mBarCodeEdtx', '',mform, 10,10,300,80,150,'',true,true,true,round(480/24), [fsBold],255) ;




                                if mbuton1<>'' then begin

                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := mForm.Width-80;
                                      mBtn.Height := round(mForm.Height/(mpocet ));
                                    mBtn.Caption := copy(mbuton1,24,60);
                                    mbtn.WordWrap:= True;
                                    mFont := mBtn.Font;
                                       mFont.Size := round(480/24/(mpocet/4));
                                       mFont.Style := [fsBold];

                                    mBtn.ModalResult := 1;
                                    mBtn.Cancel := False;
                                    mBtn.Default := true;
                                    mBtn.Left :=  round((mForm.Width - (mBtn.Width))/2-10) ;
                                    mBtn.Top :=mpozice*(round(mForm.Height/(mpocet)))-10 ; // // mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'mbuton1';
                                    mForm.InsertControl(mBtn);
                                    mpozice:=mpozice+1;
                                end;


                                if mbuton2<>'' then begin

                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := mForm.Width-80;
                                      mBtn.Height := round(mForm.Height/(mpocet ));
                                    mBtn.Caption := copy(mbuton2,24,60);
                                    mbtn.WordWrap:= True;
                                    mFont := mBtn.Font;
                                       mFont.Size := round(480/24/(mpocet/4));
                                       mFont.Style := [fsBold];
                                    mBtn.ModalResult := 2;
                                    mBtn.Cancel := False;
                                    mBtn.Default := False;
                                    mBtn.Left :=  round((mForm.Width - (mBtn.Width))/2)-10 ;
                                    mBtn.Top :=mpozice*(mBtn.Height) -10; // mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'mbuton2';
                                    mForm.InsertControl(mBtn);
                                     mpozice:=mpozice+1;
                                end;

                                if mbuton3<>'' then begin

                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := mForm.Width-80;
                                      mBtn.Height := round(mForm.Height/(mpocet ));
                                    mBtn.Caption := copy(mbuton3,24,60);
                                    mbtn.WordWrap:= True;
                                    mFont := mBtn.Font;
                                       mFont.Size := round(480/24/(mpocet/4));
                                       mFont.Style := [fsBold];
                                    mBtn.ModalResult := 3;
                                    mBtn.Cancel := False;
                                    mBtn.Default := False;
                                    mBtn.Left :=  round((mForm.Width - (mBtn.Width))/2) -10;
                                    mBtn.Top :=mpozice*(mBtn.Height)-10 ; // mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'mbuton3';
                                    mForm.InsertControl(mBtn);
                                    mpozice:=mpozice+1;
                                    end;


                                    if mbuton4<>'' then begin

                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := mForm.Width-80;
                                      mBtn.Height := round(mForm.Height/(mpocet ));
                                    mBtn.Caption := copy(mbuton4,24,60);
                                    mbtn.WordWrap:= True;
                                    mFont := mBtn.Font;
                                       mFont.Size := round(480/24/(mpocet/4));
                                       mFont.Style := [fsBold];
                                    mBtn.ModalResult := 4;
                                    mBtn.Cancel := False;
                                    mBtn.Default := False;
                                    mBtn.Left :=  round((mForm.Width - (mBtn.Width))/2) -10;
                                    mBtn.Top :=mpozice*(mBtn.Height) -10; // mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'mbuton4';
                                    mForm.InsertControl(mBtn);
                                    mpozice:=mpozice+1;
                                    end;



                                    if mbuton5<>'' then begin

                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := mForm.Width-80;
                                      mBtn.Height := round(mForm.Height/(mpocet ));
                                    mbtn.WordWrap:= True;
                                    mBtn.Caption := copy(mbuton5,24,60);
                                    mFont := mBtn.Font;
                                       mFont.Size := round(480/24/(mpocet/4));
                                       mFont.Style := [fsBold];
                                    mBtn.ModalResult := 5;
                                    mBtn.Cancel := False;
                                    mBtn.Default := False;
                                    mBtn.Left :=  round((mForm.Width - (mBtn.Width))/2) -10;
                                    mBtn.Top :=mpozice*(mBtn.Height)-10 ; // mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'mbuton5';
                                    mForm.InsertControl(mBtn);
                                    mpozice:=mpozice+1;
                                    end;


                                    if mbuton6<>'' then begin

                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := mForm.Width-80;
                                      mBtn.Height := round(mForm.Height/(mpocet ));
                                    mBtn.Caption := copy(mbuton6,24,60);
                                    mbtn.WordWrap:= True;
                                    mFont := mBtn.Font;
                                       mFont.Size := round(480/24/(mpocet/4));
                                       mFont.Style := [fsBold];
                                    mBtn.ModalResult := 6;
                                    mBtn.Cancel := False;
                                    mBtn.Default := False;
                                    mBtn.Left :=  round((mForm.Width - (mBtn.Width))/2) -10;
                                    mBtn.Top :=mpozice*(mBtn.Height)-10; // mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'mbuton6';
                                    mForm.InsertControl(mBtn);
                                    mpozice:=mpozice+1;
                                    end;


                                    if mbuton7<>'' then begin

                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := mForm.Width-80;
                                      mBtn.Height := round(mForm.Height/(mpocet ));
                                    mBtn.Caption := copy(mbuton7,24,60);
                                    mbtn.WordWrap:= True;
                                    mFont := mBtn.Font;
                                       mFont.Size := round(480/24/(mpocet/4));
                                       mFont.Style := [fsBold];
                                    mBtn.ModalResult := 7;
                                    mBtn.Cancel := False;
                                    mBtn.Default := False;
                                    mBtn.Left :=  round((mForm.Width - (mBtn.Width))/2) -10;
                                    mBtn.Top :=mpozice*(mBtn.Height)-10; // mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'mbuton7';
                                    mForm.InsertControl(mBtn);
                                    mpozice:=mpozice+1;
                                    end;


                                    if mbuton8<>'' then begin

                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := mForm.Width-80;
                                      mBtn.Height := round(mForm.Height/(mpocet ));
                                    mBtn.Caption := copy(mbuton8,24,60);
                                    mbtn.WordWrap:= True;
                                    mFont := mBtn.Font;
                                       mFont.Size := round(480/24/(mpocet/4));
                                       mFont.Style := [fsBold];
                                    mBtn.ModalResult := 8;
                                    mBtn.Cancel := False;
                                    mBtn.Default := False;
                                    mBtn.Left :=  round((mForm.Width - (mBtn.Width))/2) -10;
                                    mBtn.Top :=mpozice*(mBtn.Height)-10 ; // mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'mbuton8';
                                    mForm.InsertControl(mBtn);
                                    mpozice:=mpozice+1;
                                    end;


                                    if mbuton9<>'' then begin

                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := mForm.Width-80;
                                      mBtn.Height := round(mForm.Height/(mpocet ));
                                    mBtn.Caption := copy(mbuton9,24,60);
                                    mbtn.WordWrap:= True;
                                    mFont := mBtn.Font;
                                       mFont.Size := round(480/24/(mpocet/4));
                                       mFont.Style := [fsBold];
                                    mBtn.ModalResult := 9;
                                    mBtn.Cancel := False;
                                    mBtn.Default := False;
                                    mBtn.Left :=  round((mForm.Width - (mBtn.Width))/2) -10;
                                    mBtn.Top :=mpozice*(mBtn.Height)-10 ; // mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'mbuton9';
                                    mForm.InsertControl(mBtn);
                                    mpozice:=mpozice+1;
                                    end;

                                if mbuton10<>'' then begin

                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := mForm.Width-80;
                                      mBtn.Height := Round(mForm.Height/(mpocet));
                                    mbtn.WordWrap:= True;
                                    mFont := mBtn.Font;
                                       mFont.Size := round(480/24/(mpocet/4));
                                       mFont.Style := [fsBold];
                                    mBtn.Caption := mbuton10;
                                    mBtn.ModalResult := 10;
                                    mBtn.Cancel := True;
                                    mBtn.Left :=  round((mForm.Width - (mBtn.Width))/2)-10 ;
                                    mBtn.Top := mpozice*(round(mForm.Height/(mpocet)))-10 ; // // mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'mbuton10';
                                    mForm.InsertControl(mBtn);
                                    mpozice:=mpozice+1;

                                end;

                                mix:=mForm.ShowModal(xSite) ;

                                if (mix<>10) and (mBarCodeEdtx.Text<>'') then begin
                                    //NxShowSimpleMessage(copy(mbuton2,24,Length(mBarCodeEdt.Text)) + '/'+ mBarCodeEdt.Text,nil);
                                    //NxShowSimpleMessage(BoolToStr(copy(mbuton2,24,Length(mBarCodeEdt.Text)) = mBarCodeEdt.Text),nil);
                                    result:=0;
                                    if mBarCodeEdtx.Text=copy(mbuton1,24,Length(mBarCodeEdtx.Text)) then result:=1;
                                    if mBarCodeEdtx.Text=copy(mbuton2,24,Length(mBarCodeEdtx.Text)) then result:=2;
                                    if mBarCodeEdtx.Text=copy(mbuton3,24,Length(mBarCodeEdtx.Text)) then result:=3;
                                    if mBarCodeEdtx.Text=copy(mbuton4,24,Length(mBarCodeEdtx.Text)) then result:=4;
                                    if mBarCodeEdtx.Text=copy(mbuton5,24,Length(mBarCodeEdtx.Text)) then result:=5;
                                    if mBarCodeEdtx.Text=copy(mbuton6,24,Length(mBarCodeEdtx.Text)) then result:=6;
                                    if mBarCodeEdtx.Text=copy(mbuton7,24,Length(mBarCodeEdtx.Text)) then result:=7;
                                    if mBarCodeEdtx.Text=copy(mbuton8,24,Length(mBarCodeEdtx.Text)) then result:=8;
                                    if mBarCodeEdtx.Text=copy(mbuton9,24,Length(mBarCodeEdtx.Text)) then result:=9;
                                     //NxShowSimpleMessage(inttostr(result),nil);
                                       if result=0 then mID_doklad:=GetDocument_ID(xSite,'ReceivedOrders',mBarCodeEdtx.Text);
                                end else begin
                                    result:=mix;
                                end;
                    finally

                  mform.free;
                    end;
    //  end;
//     end;
end;



function mForm_FunctionBatches(xSite:TSiteForm;mTop:integer;mLeft:integer;mWith:integer;mHeight:integer;mLabel:string;mDescription:string;mDescription1:string;mbuton1:string;mbuton2:string;mbuton3:string;mbuton4:string;mbuton5:string;mbuton6:string;mbuton7:string;mbuton8:string;mbuton9:string;mbuton10:string):Variant;
var
mform:tform;
mBtn : TButton;
mlabel2,mlabel3:TLabel;
mFont: TFont;
mPocet:integer;
mpozice:Integer;
mBarCodeEdtx:TEdit;
mdoklad:string;
mix:integer;
mpokracuj:boolean;
mID_doklad:string;
begin
mpokracuj:=True;
result:=0;

//while Result=0  do begin
      mPocet:=1;
      if mDescription<>'' then mPocet:=mpocet+1;
      if mDescription1<>'' then mPocet:=mpocet+1;

      if mbuton1<>'' then mPocet:=mpocet+1;
      if mbuton2<>'' then mPocet:=mpocet+1;
      if mbuton3<>'' then mPocet:=mpocet+1;
      if mbuton4<>'' then mPocet:=mpocet+1;
      if mbuton5<>'' then mPocet:=mpocet+1;
      if mbuton6<>'' then mPocet:=mpocet+1;
      if mbuton7<>'' then mPocet:=mpocet+1;
      if mbuton8<>'' then mPocet:=mpocet+1;
      if mbuton9<>'' then mPocet:=mpocet+1;
      if mbuton10<>'' then mPocet:=mpocet+1;

//      while mpokracuj do begin
            mForm := TForm.Create(xsite);
            try
                                  mpozice:=0;
                                  mForm.Caption := mLabel;
                                  mForm.FormStyle := fsStayOnTop;
                                  mForm.BorderStyle := bsDialog;
                                  mForm.Left:= mLeft;
                                  mForm.Top := mTop;
                                  mForm.Width := mWith;

                                  mForm.Height := mHeight;
                                  mForm.Scaled := False;
                                  //mform.Position := poScreenCenter;



                                  if mDescription<>'' then begin

                                          CreateLabel('mLabel2', mDescription,mForm,
                                              10, mpozice*(round(mForm.Height/(mpocet))) +5, 340,round(mForm.Height/(mpocet)),
                                              True,False,
                                              round(480/24/(mpocet/4)),[fsBold],255);
                                              mpozice:=mpozice+1;
                                   end;
                                   if mDescription1<>'' then begin

                                          CreateLabel('mLabel3', mDescription1,mForm,
                                              10,mpozice*(round(mForm.Height/(mpocet))) , 340, round(mForm.Height/(mpocet)),
                                              True,False,
                                              round(480/24/(mpocet/4)),[fsBold],255);
                                              mpozice:=mpozice+1;
                                   end;

                                mBarCodeEdtx:=CreateEdit('mBarCodeEdtx', '',mform, 10,10,300,80,150,'',true,true,true,round(480/24), [fsBold],255) ;




                                if mbuton1<>'' then begin

                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := mForm.Width-80;
                                      mBtn.Height := round(mForm.Height/(mpocet ));
                                    mBtn.Caption := copy(mbuton1,24,60);
                                    mbtn.WordWrap:= True;
                                    mFont := mBtn.Font;
                                       mFont.Size := round(480/24/(mpocet/4));
                                       mFont.Style := [fsBold];

                                    mBtn.ModalResult := 1;
                                    mBtn.Cancel := False;
                                    mBtn.Default := true;
                                    mBtn.Left :=  round((mForm.Width - (mBtn.Width))/2-10) ;
                                    mBtn.Top :=mpozice*(round(mForm.Height/(mpocet)))-10 ; // // mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'mbuton1';
                                    mForm.InsertControl(mBtn);
                                    mpozice:=mpozice+1;
                                end;


                                if mbuton2<>'' then begin

                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := mForm.Width-80;
                                      mBtn.Height := round(mForm.Height/(mpocet ));
                                    mBtn.Caption := copy(mbuton2,24,60);
                                    mbtn.WordWrap:= True;
                                    mFont := mBtn.Font;
                                       mFont.Size := round(480/24/(mpocet/4));
                                       mFont.Style := [fsBold];
                                    mBtn.ModalResult := 2;
                                    mBtn.Cancel := False;
                                    mBtn.Default := False;
                                    mBtn.Left :=  round((mForm.Width - (mBtn.Width))/2)-10 ;
                                    mBtn.Top :=mpozice*(mBtn.Height) -10; // mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'mbuton2';
                                    mForm.InsertControl(mBtn);
                                     mpozice:=mpozice+1;
                                end;

                                if mbuton3<>'' then begin

                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := mForm.Width-80;
                                      mBtn.Height := round(mForm.Height/(mpocet ));
                                    mBtn.Caption := copy(mbuton3,24,60);
                                    mbtn.WordWrap:= True;
                                    mFont := mBtn.Font;
                                       mFont.Size := round(480/24/(mpocet/4));
                                       mFont.Style := [fsBold];
                                    mBtn.ModalResult := 3;
                                    mBtn.Cancel := False;
                                    mBtn.Default := False;
                                    mBtn.Left :=  round((mForm.Width - (mBtn.Width))/2) -10;
                                    mBtn.Top :=mpozice*(mBtn.Height)-10 ; // mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'mbuton3';
                                    mForm.InsertControl(mBtn);
                                    mpozice:=mpozice+1;
                                    end;


                                    if mbuton4<>'' then begin

                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := mForm.Width-80;
                                      mBtn.Height := round(mForm.Height/(mpocet ));
                                    mBtn.Caption := copy(mbuton4,24,60);
                                    mbtn.WordWrap:= True;
                                    mFont := mBtn.Font;
                                       mFont.Size := round(480/24/(mpocet/4));
                                       mFont.Style := [fsBold];
                                    mBtn.ModalResult := 4;
                                    mBtn.Cancel := False;
                                    mBtn.Default := False;
                                    mBtn.Left :=  round((mForm.Width - (mBtn.Width))/2) -10;
                                    mBtn.Top :=mpozice*(mBtn.Height) -10; // mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'mbuton4';
                                    mForm.InsertControl(mBtn);
                                    mpozice:=mpozice+1;
                                    end;



                                    if mbuton5<>'' then begin

                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := mForm.Width-80;
                                      mBtn.Height := round(mForm.Height/(mpocet ));
                                    mbtn.WordWrap:= True;
                                    mBtn.Caption := copy(mbuton5,24,60);
                                    mFont := mBtn.Font;
                                       mFont.Size := round(480/24/(mpocet/4));
                                       mFont.Style := [fsBold];
                                    mBtn.ModalResult := 5;
                                    mBtn.Cancel := False;
                                    mBtn.Default := False;
                                    mBtn.Left :=  round((mForm.Width - (mBtn.Width))/2) -10;
                                    mBtn.Top :=mpozice*(mBtn.Height)-10 ; // mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'mbuton5';
                                    mForm.InsertControl(mBtn);
                                    mpozice:=mpozice+1;
                                    end;


                                    if mbuton6<>'' then begin

                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := mForm.Width-80;
                                      mBtn.Height := round(mForm.Height/(mpocet ));
                                    mBtn.Caption := copy(mbuton6,24,60);
                                    mbtn.WordWrap:= True;
                                    mFont := mBtn.Font;
                                       mFont.Size := round(480/24/(mpocet/4));
                                       mFont.Style := [fsBold];
                                    mBtn.ModalResult := 6;
                                    mBtn.Cancel := False;
                                    mBtn.Default := False;
                                    mBtn.Left :=  round((mForm.Width - (mBtn.Width))/2) -10;
                                    mBtn.Top :=mpozice*(mBtn.Height)-10; // mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'mbuton6';
                                    mForm.InsertControl(mBtn);
                                    mpozice:=mpozice+1;
                                    end;


                                    if mbuton7<>'' then begin

                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := mForm.Width-80;
                                      mBtn.Height := round(mForm.Height/(mpocet ));
                                    mBtn.Caption := copy(mbuton7,24,60);
                                    mbtn.WordWrap:= True;
                                    mFont := mBtn.Font;
                                       mFont.Size := round(480/24/(mpocet/4));
                                       mFont.Style := [fsBold];
                                    mBtn.ModalResult := 7;
                                    mBtn.Cancel := False;
                                    mBtn.Default := False;
                                    mBtn.Left :=  round((mForm.Width - (mBtn.Width))/2) -10;
                                    mBtn.Top :=mpozice*(mBtn.Height)-10; // mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'mbuton7';
                                    mForm.InsertControl(mBtn);
                                    mpozice:=mpozice+1;
                                    end;


                                    if mbuton8<>'' then begin

                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := mForm.Width-80;
                                      mBtn.Height := round(mForm.Height/(mpocet ));
                                    mBtn.Caption := copy(mbuton8,24,60);
                                    mbtn.WordWrap:= True;
                                    mFont := mBtn.Font;
                                       mFont.Size := round(480/24/(mpocet/4));
                                       mFont.Style := [fsBold];
                                    mBtn.ModalResult := 8;
                                    mBtn.Cancel := False;
                                    mBtn.Default := False;
                                    mBtn.Left :=  round((mForm.Width - (mBtn.Width))/2) -10;
                                    mBtn.Top :=mpozice*(mBtn.Height)-10 ; // mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'mbuton8';
                                    mForm.InsertControl(mBtn);
                                    mpozice:=mpozice+1;
                                    end;


                                    if mbuton9<>'' then begin

                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := mForm.Width-80;
                                      mBtn.Height := round(mForm.Height/(mpocet ));
                                    mBtn.Caption := copy(mbuton9,24,60);
                                    mbtn.WordWrap:= True;
                                    mFont := mBtn.Font;
                                       mFont.Size := round(480/24/(mpocet/4));
                                       mFont.Style := [fsBold];
                                    mBtn.ModalResult := 9;
                                    mBtn.Cancel := False;
                                    mBtn.Default := False;
                                    mBtn.Left :=  round((mForm.Width - (mBtn.Width))/2) -10;
                                    mBtn.Top :=mpozice*(mBtn.Height)-10 ; // mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'mbuton9';
                                    mForm.InsertControl(mBtn);
                                    mpozice:=mpozice+1;
                                    end;

                                if mbuton10<>'' then begin

                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := mForm.Width-80;
                                      mBtn.Height := Round(mForm.Height/(mpocet));
                                    mbtn.WordWrap:= True;
                                    mFont := mBtn.Font;
                                       mFont.Size := round(480/24/(mpocet/4));
                                       mFont.Style := [fsBold];
                                    mBtn.Caption := mbuton10;
                                    mBtn.ModalResult := 10;
                                    mBtn.Cancel := True;
                                    mBtn.Left :=  round((mForm.Width - (mBtn.Width))/2)-10 ;
                                    mBtn.Top := mpozice*(round(mForm.Height/(mpocet)))-10 ; // // mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'mbuton10';
                                    mForm.InsertControl(mBtn);
                                    mpozice:=mpozice+1;

                                end;

                                mix:=mForm.ShowModal(xSite) ;

                                if (mix<>10) and (mBarCodeEdtx.Text<>'') then begin
                                    //NxShowSimpleMessage(copy(mbuton2,24,Length(mBarCodeEdt.Text)) + '/'+ mBarCodeEdt.Text,nil);
                                    //NxShowSimpleMessage(BoolToStr(copy(mbuton2,24,Length(mBarCodeEdt.Text)) = mBarCodeEdt.Text),nil);
                                    result:=0;
                                    if mBarCodeEdtx.Text=copy(mbuton1,24,Length(mBarCodeEdtx.Text)) then result:=1;
                                    if mBarCodeEdtx.Text=copy(mbuton2,24,Length(mBarCodeEdtx.Text)) then result:=2;
                                    if mBarCodeEdtx.Text=copy(mbuton3,24,Length(mBarCodeEdtx.Text)) then result:=3;
                                    if mBarCodeEdtx.Text=copy(mbuton4,24,Length(mBarCodeEdtx.Text)) then result:=4;
                                    if mBarCodeEdtx.Text=copy(mbuton5,24,Length(mBarCodeEdtx.Text)) then result:=5;
                                    if mBarCodeEdtx.Text=copy(mbuton6,24,Length(mBarCodeEdtx.Text)) then result:=6;
                                    if mBarCodeEdtx.Text=copy(mbuton7,24,Length(mBarCodeEdtx.Text)) then result:=7;
                                    if mBarCodeEdtx.Text=copy(mbuton8,24,Length(mBarCodeEdtx.Text)) then result:=8;
                                    if mBarCodeEdtx.Text=copy(mbuton9,24,Length(mBarCodeEdtx.Text)) then result:=9;
                                     //NxShowSimpleMessage(inttostr(result),nil);
                                       if result=0 then mID_doklad:=GetDocument_ID(xSite,'ReceivedOrders',mBarCodeEdtx.Text);
                                end else begin
                                    result:=mix;
                                end;
                    finally

                  mform.free;
                    end;
    //  end;
//     end;
end;







function BarCodeOperation(xSite:TDynSiteForm;mworker_ID:string;mMachine_ID:string;
                       mbo_operation:TNxCustomBusinessObject;
                       mTop:integer;mLeft:integer;mWith:integer;mHeight:integer;mLabel:string;
                       mbutton1,mbutton2,mbutton3,mbutton4:string;
                       Mbutton5:string):Double;
var
      mForm : TForm;
      mBtn : TButton;
      mLbl : TLabel;
      mBarCodeEdt,mQuantityEdt,mUnitEdt,mLocEdt,mLocNextEdt : TEdit;
      mPracNextEdt,mPracEdt,mPracStart,mPracEnd,mPracDoba: Tedit;
      mRealizedTime,mMissedTime,mTAC,mTBC:tedit;
      sum_mDelQuanEdt,sum_mStorQuanEdt,sum_mVychQuanEdt:tedit;
      i:integer;
      xresult:Variant;
      //mSCEdt:TRollComboEdit;
      mSCEdt:TEdit;
      mOldBarCode,mBarCode:string;
      mQuantity:double  ;
      mUnit:string;
      mix_result:integer;
      mBatch_id,mStorecard_id,m_umisteni,mjednotka:string;
      mr,mr1:tstringlist;
      mBO,mSSC:TNxCustomBusinessObject;
      mStorQuan:double;
      SUM_mdodano,SUM_mvychystano,Sum_mskladem,Sum_mcelkem:double;
      mstorecard_text:string;
      mBO_Row_id:string;
      mi_SQL:integer;
      mTypSC:integer;
      mID_Batch,mID_Storecard:string;
      mBatchList,mrBatch:TStringList;
      mpocet_zapis:double;
      mMemNote,mMemCompetence,mMemMaterial,mMemOperation,mMemVyrPolozka:tmemo;
      mpokracovat:boolean;
      mll:tstringlist;
      mI_Resultxax:integer;
      mMaterial:string;
      mCompetence:string;
      mdoba:string;
      mBOListek:TNxCustomBusinessObject;
      mBoolean:boolean;
      mOldOperation:string;
      mBOOperaceNew,mBListek:boolean;
      mOperation_id:string;
      mSPracNext:string;
begin
      mpokracovat:=true;
      Result := 0;
      mpocet_zapis:=0;
      mBarCode:= '.';
      mOldBarCode:='';
      mBOOperaceNew:=true;
      mBOListek:=xsite.BaseObjectSpace.CreateObject('XTVGL0IK2F14PDPCEHMYNWX4T4');



      while (mBarCode<>'') do begin
       if mpokracovat then begin
             try
               mr1:=tstringlist.create;
                      try
                      xsite.BaseObjectSpace.SQLSelect('select id from PLMOperations where JobOrdersRoutines_ID=' + quotedstr(mBOOperace.oid) + ' and FinishedAt$DATE =0',mr1);
                          if mr1.count>0 then mBListek:=true
                      finally
                        mr1.free;
                      end;


                 if mBOOperaceNew then begin      // při změně operace
                             mSPracNext:='';
                             mr:=tstringlist.create;
                             try
                                 xsite.BaseObjectSpace.SQLSelect('SELECT WorkPlace.Name from PLMJobOrdersRoutines Routines' +
                                                                                ' join PLMWorkPlaces WorkPlace on WorkPlace.id=Routines.WorkPlace_ID ' +
                                                                                ' where Routines.Parent_ID=' + quotedstr(mBOOperace.GetFieldValueAsString('Parent_ID')) +
                                                                                ' AND Routines.ID<>' +QuotedStr(mBOOperace.oid) +
                                                                                ' AND Routines.X_closed=' +QuotedStr('N') +
                                                                                ' order by Routines.Phase_ID,Routines.PosIndex', mr) ;
                                if mr.count>0 then mSPracNext:=mr.Strings[0];
                             finally
                                 mr.free;
                             end;

                           //mMaterial:='';
                           //mCompetence:='';
                           //NxShowSimpleMessage('Kompetence pracovníka',nil);
                           mCompetence:=CheckCompetence(xsite,mBOOperace.oid,mWorker_ID);
                           //NxShowSimpleMessage('Hlavní materiál OK',nil);
                           mMaterial:=CheckBigMaterial(xsite,mBOOperace.oid);
                           //NxShowSimpleMessage('Spotřební materiál OK',nil);
                           //CheckMachineMaterial(msite,mOperace_OD);


                 end;
                 mForm := TForm.Create(xsite);
                 if mBListek then mForm.Color := clBtnFace else mForm.Color:= clRed ;
                                        mForm.Caption := mLabel;mForm.FormStyle := fsStayOnTop;mForm.BorderStyle := bsDialog;
                                        if mTop>=0 then begin
                                          mForm.Top:= mTop;
                                          mForm.Left:= mLeft;
                                        end else begin
                                          mform.Position := poScreenCenter;
                                        end;

                                        mForm.Width := mWith;mForm.Height := mHeight;mForm.Scaled := False;
                                        mBarCodeEdt:=CreateEdit('mBarCodeEdt', 'Operace',mform, 10,10,920,40,150,mBarCode,true,true,true,round(480/24), [fsBold],255) ;
                                        //mSCEdt:=CreateEdit('mSCEdt', 'Zboží.',mForm,10, 80, 300,80,50,mbo_ReceivedOrder_row.GetFieldValueAsString('Storecard_id.Name'),true,true,false,round(480/24),[fsBold],255);
                                        mMemVyrPolozka := CreateMemo('ChMemVyrPolozka','Vyráběná položka', 10, 80, 920,40, 150, mBOOperace.GetFieldValueAsString('Parent_ID.DisplayName') + ' - ' + mBOOperace.GetFieldValueAsString('Parent_ID.RoutineStoreCard_ID.Name') + ' v množství:' + NxFloatToIBStr(mBOOperace.GetFieldValueAsFloat('Parent_ID.Quantity')) , mForm,true,true,False,round(480/36), [fsItalic],255);

                                        mMemOperation := CreateMemo('ChMemOperation','Operace', 10, 140, 920,40, 150, mBOOperace.GetFieldValueAsString('Title'), mForm,true,true,False,round(480/36), [fsItalic],255);
                                        mMemNote := CreateMemo('ChMemNote','Postup', 10, 210, 920,120, 150, mBOOperace.GetFieldValueAsString('Note'), mForm,true,true,False,round(480/36), [fsItalic],255);

                                        mMemMaterial := CreateMemo('ChMemMaterial','Použité materiály', 10, 350, 440,80, 150, mMaterial, mForm,true,true,False,round(480/36), [fsItalic],255);
                                        mMemCompetence := CreateMemo('ChMemCompetence','Kompetence', 490, 350, 440,80, 150, mCompetence, mForm,true,true,False,round(480/36), [fsItalic],255);

                                        mLocEdt:=CreateEdit('mLocEdt', 'Pracoviště',mform, 10,460,710,40,150,mBOOperace.GetFieldValueAsString('WorkPlace_ID.Name'),true,true,false,round(480/24), [fsBold],255) ;

                                        mLocNextEdt:=CreateEdit('mLocNextEdt', 'Předat na',mform, 720,460,920,40,150,mSPracNext,true,true,false,round(480/24), [fsBold],255) ;

                                        mTAC:=CreateEdit('chTAC', 'Čistý čas',mform, 10,530,200,40,150,FormatDateTime('NN:SS',(mBOOperace.GetFieldValueAsFloat('TAC')*mBOOperace.GetFieldValueAsFloat('Parent_ID.Quantity'))/86400),true,true,false,round(480/24), [fsBold],255) ;
                                        mTBC:=CreateEdit('chTBC', 'Přípravný čas',mform, 240,530,200,40,150,FormatDateTime('NN:SS',mBOOperace.GetFieldValueAsFloat('TBC')/86400),true,true,false,round(480/24), [fsBold],255) ;
                                        mRealizedTime:=CreateEdit('chRealizedTime', 'Realizováno',mform, 480,530,200,40,150,FormatDateTime('NN:SS',mBOOperace.GetFieldValueAsFloat('RealizedTime')/86400),true,true,false,round(480/24), [fsBold],255) ;
                                        mMissedTime:=CreateEdit('chMissedTime', 'Zbývá',mform, 720,530,200,40,150,FormatDateTime('NN:SS',mBOOperace.GetFieldValueAsFloat('MissedTime')/86400),true,true,false,round(480/24), [fsBold],255) ;

                                        mr1:=tstringlist.create;
                                                 xsite.BaseObjectSpace.SQLSelect('select id from PLMOperations where JobOrdersRoutines_ID=' + quotedstr(mBOOperace.oid) + ' and FinishedAt$DATE =0',mr1);
                                                 mBOListek:=xsite.BaseObjectSpace.CreateObject('XTVGL0IK2F14PDPCEHMYNWX4T4');
                                                 try
                                                       if mr1.count>0 then begin
                                                             //NxShowSimpleMessage('Lístek existuje',nil);
                                                             mBOListek.load(mr1.strings[0],nil);
                                                             if (mBOListek.getFieldValueAsString('PerformedBy_ID')<>mWorker_ID) or
                                                                   (mBOListek.getFieldValueAsString('WorkPlace_ID')<>mMachine_ID) then begin  // lístek není určen pro osobu a stroj
                                                                       mBoolean:=InputQuery('Na operaci pracuje', mBOListek.GetFieldValueAsString('PerformedBy_ID.WorkerName') +
                                                                            '  na stroji ' + mBOListek.GetFieldValueAsString('WorkPlace_ID.Name') +
                                                                            ' Chcete předchozí lístek ukončit a začít nový','');
                                                                       if mBoolean then begin         // při rozpracovaném lístku ukončení a založení
                                                                             mBOListek.SetFieldValueAsDateTime('FinishedAt$DATE',now);
                                                                             mBOListek.SetFieldValueAsFloat('TotalTime',SecondOfTheHour(mBOListek.getFieldValueAsDateTime('FinishedAt$DATE')-mBOListek.getFieldValueAsDateTime('StartedAt$DATE')));
                                                                             mBOListek.save;

                                                                             mBOListek.new;
                                                                                 mBOListek.prefill;
                                                                                 mBOListek.SetFieldValueAsString('JobOrdersRoutines_ID',mBOOperace.oid);
                                                                                 mBOListek.SetFieldValueAsString('PerformedBy_ID',mWorker_ID);
                                                                                 mBOListek.SetFieldValueAsString('WorkPlace_ID',mMachine_ID);
                                                                                 mBOListek.SetFieldValueAsDateTime('StartedAt$DATE',now);
                                                                                 mBOListek.SetFieldValueAsString('SalaryClass_ID','2000000101');
                                                                              mBOListek.save;
                                                                       end;

                                                             end else begin         // ukončení lístku
                                                                       mBOListek.SetFieldValueAsDateTime('FinishedAt$DATE',now);
                                                                       mBOListek.SetFieldValueAsFloat('TotalTime',SecondOfTheHour(mBOListek.getFieldValueAsDateTime('FinishedAt$DATE')-mBOListek.getFieldValueAsDateTime('StartedAt$DATE')));
                                                                  mBOListek.save;
                                                                  mBOOperace.SetFieldValueAsBoolean('Ongoing',true);
                                                                  mBOOperace.save;
                                                             end;
                                                       end else begin
                                                             //NxShowSimpleMessage('Lístek neexistuje',nil);
                                                             mBOListek.new;
                                                             mBOListek.prefill;
                                                               mBOListek.SetFieldValueAsString('JobOrdersRoutines_ID',mBOOperace.oid);
                                                                   mBOListek.SetFieldValueAsString('PerformedBy_ID',mWorker_ID);
                                                                   mBOListek.SetFieldValueAsString('WorkPlace_ID',mMachine_ID);
                                                                   mBOListek.SetFieldValueAsDateTime('StartedAt$DATE',now);
                                                                   mBOListek.SetFieldValueAsString('SalaryClass_ID','2000000101');
                                                                   mBOListek.save;
                                                       end;
                                                 finally
                                                      mdoba:='';
                                                      if mBOListek.getFieldValueAsDateTime('FinishedAt$DATE')=0 then begin
                                                                                       mdoba:=FormatDateTime('HH:NN',now - mBOListek.getFieldValueAsDateTime('StartedAt$DATE')) ;
                                                                                       mBListek:=true;
                                                                                end else begin

                                                                                       mdoba:=FormatDateTime('HH:NN',(mBOListek.getFieldValueAsDateTime('FinishedAt$DATE') -mBOListek.getFieldValueAsDateTime('StartedAt$DATE'))) ;
                                                                                       mBListek:=false;
                                                                                end;
                                                      mPracEdt:=CreateEdit('ChPracEdt', 'Pracovník',mform, 10,590,440,40,150,mBOListek.GetFieldValueAsString('PerformedBy_ID.WorkerName'),true,mBListek,false,round(480/24), [fsBold],255) ;
                                                      mPracStart:=CreateEdit('CHmPracStart', 'Začátek',mform, 480,590,100,40,150,FormatDateTime('HH:NN',mBOListek.getFieldValueAsDateTime('StartedAt$DATE')),true,mBListek,false,round(480/24), [fsBold],255) ;
                                                      mPracEnd:=CreateEdit('CHPracEnd', 'Konec',mform, 600,590,100,40,150,FormatDateTime('HH:NN',mBOListek.getFieldValueAsDateTime('FinishedAt$DATE')),true,mBListek,false,round(480/24), [fsBold],255) ;
                                                      mPracDoba:=CreateEdit('chPracDoba', 'Doba',mform, 720,590,200,40,150,mdoba,true,mBListek,false,round(480/24), [fsBold],255) ;
                                                     mBOListek.free;
                                                 end;
                                       mBtn := TButton.Create(mForm);mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := mbutton1;mBtn.ModalResult := mrOk; mBtn.Cancel := False;mBtn.Default := True;mBtn.Left:=mForm.Width - 2*(mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 40;mBtn.Name := 'btnOK';mForm.InsertControl(mBtn);
                                       mBtn := TButton.Create(mForm);mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := mbutton2;mBtn.ModalResult := mrCancel;mBtn.Cancel := True;mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 40;mBtn.Name := 'btnCancel';mForm.InsertControl(mBtn);
                                       mBtn := TButton.Create(mForm);mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := 'Přerušit';mBtn.ModalResult := 22;mBtn.Cancel := True;mBtn.Left := mForm.Width - 3*(mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 40;mBtn.Name := 'btn99';mForm.InsertControl(mBtn);
                                       mBtn := TButton.Create(mForm);mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := 'Zápis';mBtn.ModalResult := 88;mBtn.Cancel := false;mBtn.Left := 10;mBtn.Top := mForm.Height - mBtn.Height - 40;mBtn.Name := 'btnyestoall';mForm.InsertControl(mBtn);
                                       mix_result:= mForm.ShowModal(xsite);   // změna položky

                                       if mix_result=1 then begin
                                             mbarcode:=mBarCodeEdt.text;
                                             if (mbarcode<>'') then begin
                                                         if mOldBarCode<>'.' then begin
                                                                  if mix_result=mrOk then begin
                                                                          mOperation_id:= GetOperation_ID(xsite,mBarCodeEdt.text,mMachine_ID,mWorker_ID,0);

                                                                          if mbo_operation.oid<>mOperation_id then begin
                                                                               if mOperation_id<>'' then begin
                                                                                      mBOOperace.load(mOperation_id,nil);
                                                                                      mBOOperaceNew:=true;
                                                                                      //NxShowSimpleMessage('Nová operace',nil);
                                                                               end else begin
                                                                                      NxShowSimpleMessage('Pro ento stroj není přiřazena operace',nil);
                                                                               end;
                                                                          end else begin
                                                                               mBOOperaceNew:=false;
                                                                          end;





                                                                    end;
                                                         end else begin
                                                                  mOldBarCode:=mbarcode;
                                                         end;
                                             end else begin
                                                  result:=mpocet_zapis;

                                             end;
                                        end;    // mbarcode=''
                                    //end;    // mi result=2


             finally
             mForm.free;
             end;
       end;

      end;

end;








function BarCodeDialogDL_pruvodce(xSite:TSiteForm;mCLSID_DOC:string;mTBatches:boolean;
                       mTop:integer;mLeft:integer;mWith:integer;mHeight:integer;mLabel:string;
                       mTyp_prace:integer;mids:integer; mIDs_dDocument:string;
                       mbutton1,mbutton2,mbutton3,mbutton4:string;
                       Mbutton5:string):string;
var
      mForm,mform1,mform2 : TForm;
      mBtn : TButton;
      mLbl : TLabel;
      mBarCodeEdt,mBarCodeEdt1,mQuantityEdt,mUnitEdt,mLocEdt,mLocEdt1 : TEdit;
      mQuanEdt,mDelQuanEdt,mStorQuanEdt,mVychQuanEdt:tedit;
      sum_mDelQuanEdt,sum_mStorQuanEdt,sum_mVychQuanEdt:tedit;
      i,ii:integer;
      xresult:Variant;
      //mSCEdt:TRollComboEdit;
      mSCEdt,mSCEdt1:TEdit;
      ABarCode,mbarcode:string;
      mQuantity:double  ;
      mUnit:string;
      mpocet:double;
      mix_result:integer;
      mBatch_id,mStorecard_id,m_umisteni,mjednotka:string;
      mr,mr1:tstringlist;
      mBO,mSSC:TNxCustomBusinessObject;
      mStorQuan:double;
      mdodano,mvychystano,mskladem,mcelkem:double;
      SUM_mdodano,SUM_mvychystano,Sum_mskladem,Sum_mcelkem:double;
      mstorecard_text:string;
      mBO_Row_id:string;
      mi_SQL:integer;
      mTypSC:integer;
      mID_Batch,mID_Storecard:string;
      mBatchList,mrBatch:TStringList;
      mMemNote,mMemNote1:tmemo;
      mpokracovat:Boolean;
      mix_result1:integer;
begin
      Result := '';

      ABarCode := '.';
      mBarCode:='';
      mpocet:=1;

      mbarcode:='';
      while ABarCode <> '' do begin
       if true then begin
             try

                 mForm := TForm.Create(xsite);
                                        mForm.Caption := mLabel;mForm.FormStyle := fsStayOnTop;mForm.BorderStyle := bsDialog;
                                        if mTop>=0 then begin
                                          mForm.Top:= mTop;
                                          mForm.Left:= mLeft;
                                        end else begin
                                          mform.Position := poScreenCenter;
                                        end;

                                        mForm.Width := mWith;mForm.Height := mHeight;mForm.Scaled := False;
                                        mBarCodeEdt:=CreateEdit('mBarCodeEdt', 'Čarový kód zboží',mform, 10,10,320,80,150,mBarCode,true,true,true,round(480/24), [fsBold],255) ;
                                        //mSCEdt:=CreateEdit('mSCEdt', 'Zboží.',mForm,10, 80, 300,80,50,AsString('Storecard_id.Name'),true,true,false,round(480/24),[fsBold],255);
                                        mMemNote := CreateMemo('ChMemNote','Identifikace zboží', 10, 80, 320,80, 150, mstorecard_text, mForm,true,true,False,round(480/36), [fsItalic],255);

                                       mBtn := TButton.Create(mForm);mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := mbutton1;mBtn.ModalResult := 2; mBtn.Cancel := False;mBtn.Default := True;mBtn.Left:=mForm.Width - 2*(mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 40;mBtn.Name := 'btnOK';mForm.InsertControl(mBtn);
                                       mBtn := TButton.Create(mForm);mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := mbutton2;mBtn.ModalResult := 0;mBtn.Cancel := True;mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 40;mBtn.Name := 'btnCancel';mForm.InsertControl(mBtn);

                                                     ;




                                       mix_result:= mForm.ShowModal(xsite);   // změna položky
                                       abarcode:=mBarCodeEdt.text;

                                       if mix_result=2 then begin
                                                mbarcode:=mBarCodeEdt.text;
                                                mr:=tstringlist.create;
                                                try
                                                    xsite.BaseObjectSpace.SQLSelect(format('select ro2.id from STOREEANS SE left join StoreUnits SU on SU.id=se.Parent_id left join Storecards SC on sc.id=su.parent_id left join Receivedorders2 RO2 on ro2.storecard_id=sc.id left join Receivedorders RO on ro.id=ro2.parent_id where (RO.closed = ''N'' ) and ((RO2.Quantity - Ro2.DeliveredQuantity)>=0)  and (se.EAN=%s and (RO.ID in (%s)))'
                                                    ,[quotedstr(mbarcode),mIDs_dDocument]),mr)
                                                    ;

                                                    try
                                                          mForm2 := TForm.Create(xsite);
                                                          mForm2.Caption := mLabel;mForm2.FormStyle := fsStayOnTop;mForm2.BorderStyle := bsDialog;
                                                          if mTop>=0 then begin
                                                            mForm2.Top:= mTop;
                                                            mForm2.Left:= mLeft;
                                                          end else begin
                                                            mform2.Position := poScreenCenter;
                                                          end;

                                                          mForm2.Width := mWith;mForm2.Height := mHeight;mForm2.Scaled := False;
                                                          mBarCodeEdt:=CreateEdit('mBarCodeEdt2', 'Čarový kód',mform2, 10,10,300,80,150,'',true,true,true,round(480/24), [fsBold],255) ;
                                                          //mSCEdt:=CreateEdit('mSCEdt', 'Doklady',mForm,10, 80, 340,80,50,mS_doklady,true,true,true,round(480/24),[fsBold],255);
                                                            //mMemNote:=CreateEdit('mSCEdt','Doklady',
                                                            //10,10,300,80,
                                                            //10,
                                                            //mS_doklady,
                                                            //mForm,true);


                                                            //mMemNote := CreateMemo('ChMemNote2','Doklady', 10, 80, 300,250, 150, mS_doklady, mForm2,true,true,false,round(480/24), [fsBold],255);


                                                           mBtn := TButton.Create(mForm2);mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := mButton1;mBtn.ModalResult := 1; mBtn.Cancel := False;mBtn.Default := True;mBtn.Left:=mForm2.Width - 2*(mBtn.Width+2) - 20;mBtn.Top := mForm2.Height - mBtn.Height - 60;mBtn.Name := 'btnOK';mForm2.InsertControl(mBtn);
                                                           mBtn := TButton.Create(mForm2);mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := mbutton2;mBtn.ModalResult := 10;mBtn.Cancel := True;mBtn.Left := mForm2.Width - (mBtn.Width+2) - 20;mBtn.Top := mForm2.Height - mBtn.Height - 60;mBtn.Name := 'btnCancel';mForm2.InsertControl(mBtn);

                                                           mix_result:= mForm2.ShowModal(xsite);   // změna položky

                                                  finally
                                                      mform2.free;
                                                  end;





























                                                   if mr.count>0 then begin

                                                      for ii:=0 to mr.count-1 do begin

                                                         mbo:=xsite.BaseObjectSpace.CreateObject('05CPMINJW3DL342X01C0CX3FCC');
                                                         try
                                                            mbo.load(mr.Strings[ii],nil);


                                                            mForm1 := TForm.Create(xsite);
                                                                mForm1.Caption := mLabel;mForm1.FormStyle := fsStayOnTop;mForm1.BorderStyle := bsDialog;
                                                                if mTop>=0 then begin
                                                                  mForm1.Top:= mTop;
                                                                  mForm1.Left:= mLeft;
                                                                end else begin
                                                                  mform1.Position := poScreenCenter;
                                                                end;

                                                                mForm1.Width := mWith;mForm1.Height := mHeight;mForm1.Scaled := False;
                                                                mBarCodeEdt1:=CreateEdit('mBarCodeEdt1', 'Čarový kód',mform1, 10,10,320,80,150,mBarCode,true,true,true,round(480/24), [fsBold],255) ;
                                                                //mSCEdt:=CreateEdit('mSCEdt', 'Objednávka',mForm,10, 80, 300,80,50,AsString('Storecard_id.Name'),true,true,false,round(480/24),[fsBold],255);
                                                                mMemNote1 := CreateMemo('ChMemNote1','Objednávka', 10, 80, 320,80, 150,
                                                                mbo.GetFieldValueAsString('parent_id.docqueue_id.code') + '-' + inttostr(mbo.GetFieldValueAsInteger('parent_id.ordnumber')) + '/'+
                                                                mbo.GetFieldValueAsString('parent_id.period_id.code')


                                                                , mForm1,true,true,False,round(480/24), [fsItalic],255);


                                                                mLocEdt1:=CreateEdit('mLocEdt1', 'Zboží',mform1, 10,200,320,80,150,mbo.GetFieldValueAsString('Storecard_ID.code') + ' - ' + mbo.GetFieldValueAsString('Storecard_ID.Name'),true,true,false,round(480/24), [fsBold],255) ;

                                                               mBtn := TButton.Create(mForm1);mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := mbutton1;mBtn.ModalResult := 2; mBtn.Cancel := False;mBtn.Default := True;mBtn.Left:=mForm1.Width - 2*(mBtn.Width+2) - 20;mBtn.Top := mForm1.Height - mBtn.Height - 40;mBtn.Name := 'btnOK';mForm1.InsertControl(mBtn);
                                                               mBtn := TButton.Create(mForm1);mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := mbutton2;mBtn.ModalResult := 0;mBtn.Cancel := True;mBtn.Left := mForm1.Width - (mBtn.Width+2) - 20;mBtn.Top := mForm1.Height - mBtn.Height - 40;mBtn.Name := 'btnCancel';mForm1.InsertControl(mBtn);


                                                               mix_result1:= mForm1.ShowModal(xsite);   // změna položky





                                                         finally
                                                           mbo.free;
                                                         end;

















                                                      end;



                                                   end;

                                                finally
                                                   mr.free;
                                                end;





                                       end;





             finally
                  ABarCode:=mBarCode;
             end;
                  mForm.free;

            end;
      end;

      xSite.Refresh;
      result:='A';

end;

 function BarCodeDialog_prepravka(xSite:TSiteForm;mCLSID_DOC:string;mTBatches:boolean;
                       mTop:integer;mLeft:integer;mWith:integer;mHeight:integer;mLabel:string;
                       mTyp_prace:integer;mids:integer; mIDs_dDocument:string;
                       mbutton1,mbutton2,mbutton3,mbutton4:string;
                       Mbutton5:string):string;
var
      mForm : TForm;
      mBtn : TButton;
      mLbl : TLabel;
      mBarCodeEdt,mQuantityEdt,mUnitEdt,mLocEdt : TEdit;
      mQuanEdt,mDelQuanEdt,mStorQuanEdt,mVychQuanEdt:tedit;
      sum_mDelQuanEdt,sum_mStorQuanEdt,sum_mVychQuanEdt:tedit;
      i:integer;
      xresult:Variant;
      //mSCEdt:TRollComboEdit;
      mSCEdt:TEdit;
      ABarCode,mbarcode:string;
      mQuantity:double  ;
      mUnit:string;
      mpocet:double;
      mix_result:integer;
      mBatch_id,mStorecard_id,m_umisteni,mjednotka:string;
      mr,mr1:tstringlist;
      mBO,mSSC:TNxCustomBusinessObject;
      mStorQuan:double;
      mdodano,mvychystano,mskladem,mcelkem:double;
      SUM_mdodano,SUM_mvychystano,Sum_mskladem,Sum_mcelkem:double;
      mstorecard_text:string;
      mBO_Row_id:string;
      mi_SQL:integer;
      mTypSC:integer;
      mID_Batch,mID_Storecard:string;
      mBatchList,mrBatch:TStringList;
      mMemNote:tmemo;
      mpokracovat:Boolean;
      mxx:tstringlist ;
      ixi:integer;
      mpomoc_pocet:double;
begin
      mpokracovat:=true;
      Result := '';
      i:=1;
      ABarCode := '.';
      mBarCode:='';
      mpocet:=0;
      mStorecard_id:='';
                      mBO_Row_id:='';
                      mstorecard_text:='';
                      mdodano:=0 ;
                      mvychystano:=0;
                      mskladem:=0 ;
                      mcelkem:=0;
                      m_umisteni:='';

                     mjednotka:='';
                      mbarcode:='';
      mBO:=xsite.BaseObjectSpace.CreateObject('05CPMINJW3DL342X01C0CX3FCC');
      try
      while ABarCode <> '' do begin

       if mpokracovat then begin


                 mForm := TForm.Create(xsite);
                          try
                                        if True then mForm.Color := clBtnFace else mForm.Color:= clRed ;
                                        mForm.Caption := mLabel;mForm.FormStyle := fsStayOnTop;mForm.BorderStyle := bsDialog;
                                        if True then mForm.Color := clBtnFace else mForm.Color:= clRed ;
                                        if mTop>=0 then begin
                                          mForm.Top:= mTop;
                                          mForm.Left:= mLeft;
                                        end else begin
                                          mform.Position := poScreenCenter;
                                        end;

                                        mForm.Width := mWith;mForm.Height := mHeight;mForm.Scaled := False;
                                        mBarCodeEdt:=CreateEdit('mBarCodeEdt', 'Čarový kód',mform, 10,10,320,80,150,mBarCode,true,true,true,round(480/24), [fsBold],255) ;
                                        //mSCEdt:=CreateEdit('mSCEdt', 'Zboží.',mForm,10, 80, 300,80,50,AsString('Storecard_id.Name'),true,true,false,round(480/24),[fsBold],255);
                                        mMemNote := CreateMemo('ChMemNote','Zboží', 10, 80, 320,80, 150, mstorecard_text, mForm,true,true,False,round(480/36), [fsItalic],255);


                                        mLocEdt:=CreateEdit('mLocEdt', 'Umístění',mform, 10,200,320,80,150,m_umisteni,true,true,false,round(480/24), [fsBold],255) ;
                                        mBtn := TButton.Create(mForm);mBtn.Width := 65;mBtn.Height := 70;mBtn.Caption := '-';mBtn.ModalResult := 10;mBtn.Cancel := False;mBtn.Default := false;mBtn.Left:=10;mBtn.Top := 270;mBtn.Name := 'btnIgnore';mForm.InsertControl(mBtn);
                                        mQuantityEdt:=CreateEdit('mQuantityEdt', 'Množství',mForm,80, 270, 120,80,50,NxFloatToIBStr(mpocet),true,true,true,round(480/24),[fsBold],255);
                                        mBtn := TButton.Create(mForm);mBtn.Width := 65;mBtn.Height := 70;mBtn.Caption := '+';mBtn.ModalResult := 20;mBtn.Cancel := False;mBtn.Default := false;mBtn.Left:=260;mBtn.Top := 270;mBtn.Name := 'btnYea';mForm.InsertControl(mBtn);
                                        mUnitEdt:=CreateEdit('mUnitEdt', 'Jedn.',mForm,210, 270, 40,80,50,mjednotka,true,true,false,round(480/48),[fsBold],255);

                                        mcelkem:=GetFloatFromTable(xSite,mSQL_Doklad_quantitysp,ABarCode,mIDs_dDocument);
                                        mdodano:=GetFloatFromTable(xSite,mSQL_Doklad_deliveredsp,ABarCode,mIDs_dDocument);
                                        mvychystano:=GetFloatFromTable(xSite,mSQL_Doklad_vychystanosp,ABarCode,mIDs_dDocument);

                                        mQuanEdt:=CreateEdit_noformat('mQuanEdt', 'Celkem',mform, 10,350,70,80,150,NxFloatToIBStr(mcelkem),true,true,false,round(120/10),[fsBold],255) ;
                                        mDelQuanEdt:=CreateEdit_noformat('mDelQuanEdt', 'Dodano',mform, 90,350,70,80,150,NxFloatToIBStr(mdodano),true,true,false,round(120/10),[fsBold],255) ;
                                        mStorQuanEdt:=CreateEdit_noformat('mStorQuanEdt', 'Skladem',mform, 170,350,70,80,150,NxFloatToIBStr(mskladem),true,true,false,round(120/10),[fsBold],255) ;
                                        mVychQuanEdt:=CreateEdit_noformat('mVychQuanEdt', 'Vychystano',mform, 270,350,70,80,150,NxFloatToIBStr(mvychystano),true,true,false,round(120/10),[fsBold],255) ;


                                     //   if ((mbo_ReceivedOrder_row.GetFieldValueAsInteger('Storecard_id.Category')=3) or (mbo_ReceivedOrder_row.GetFieldValueAsInteger('Storecard_id.Category')=2)) and (mTBatches) then begin
                                     //           mBtn := TButton.Create(mForm);mBtn.Width := 75;mBtn.Height := 40;
                                     //           if (mbo_ReceivedOrder_row.GetFieldValueAsInteger('Storecard_id.Category')=2) then mBtn.Caption := 'Sériové číslo';
                                     //           if (mbo_ReceivedOrder_row.GetFieldValueAsInteger('Storecard_id.Category')=3) then mBtn.Caption := 'Šarže';
                                     //
                                     //           mBtn.ModalResult := 99;mBtn.Cancel := True;mBtn.Left := 10;mBtn.Top := mForm.Height - mBtn.Height - 60;mBtn.Visible:=true;mBtn.Name := 'btnŠarže';mForm.InsertControl(mBtn);
                                     //   end;

                                       mBtn := TButton.Create(mForm);mBtn.ModalResult := 2;mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := mbutton1; mBtn.Cancel := False;mBtn.Default := True;mBtn.Left:=mForm.Width - 2*(mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 40;mBtn.Name := 'btnOK';mForm.InsertControl(mBtn);
                                       mBtn := TButton.Create(mForm);mBtn.ModalResult := 0;mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := mbutton2;mBtn.Cancel := True;mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 40;mBtn.Name := 'btnCancel';mForm.InsertControl(mBtn);
                                       mBtn := TButton.Create(mForm);mBtn.ModalResult := 1;mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := 'Zápis';mBtn.Cancel := False;mBtn.Left := 10;mBtn.Top := mForm.Height - mBtn.Height - 40;mBtn.Name := 'btnyestoall';mForm.InsertControl(mBtn);
                                       mBtn := TButton.Create(mForm);mBtn.ModalResult := 22;mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := 'Přerušit';mBtn.Cancel := False;mBtn.Left := mForm.Width - 3*(mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 40;mBtn.Name := 'btn99';mForm.InsertControl(mBtn);

      //                                 mBtn := TButton.Create(mForm);mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := 'OK';mBtn.ModalResult := mrOk; mBtn.Cancel := False;mBtn.Default := True;mBtn.Left:=mForm.Width - 2*(mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 60;mBtn.Name := 'btnOK';mForm.InsertControl(mBtn);
      //                                 mBtn := TButton.Create(mForm);mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := 'Storno';mBtn.ModalResult := mrCancel;mBtn.Cancel := True;mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 60;mBtn.Name := 'btnCancel';mForm.InsertControl(mBtn);


                                       mix_result:= mForm.ShowModal(xsite);   // změna položky


                                       //NxShowSimpleMessage(inttostr(mix_result),nil);

                                       //if (mix_result = 2) then exit;
                                       if mix_result=10 then mpocet:=mpocet-1;
                                       if mix_result=20 then begin
                                             mpocet:=mpocet+1;
                                           if mpocet>mcelkem-mdodano-mvychystano then begin
                                              NxShowSimpleMessage('Max množství pro položku je ' + NxFloatToIBStr(mcelkem-mdodano - mvychystano) +
                                               ,nil);
                                               nxbeep(btfailure);
                                               mpocet:=mcelkem-mdodano-mvychystano;
                                           end;
                                        end;

                                       if (mix_result = 22) then begin

                                                              // postupný zápis
                                                              mxx:=tstringlist.create;
                                                                   try
                                                                       xsite.BaseObjectSpace.SQLSelect(format(mSQL_Doklad_zapis,[quotedstr(mStorecard_id),mIDs_dDocument]),mxx) ;
                                                                         //NxShowSimpleMessage(inttostr(mxx.count),nil);
                                                                         if mxx.count>0 then begin
                                                                             for ixi:=0 to mxx.count-1 do begin
                                                                                  if mpocet>0 then begin
                                                                                      mbo.load(mxx.Strings[ixi],nil);
                                                                                      if mpocet<=mbo.GetFieldValueAsFloat('quantity') - mbo.GetFieldValueAsFloat('DeliveredQuantity')-mbo.GetFieldValueAsFloat('X_vychystano')  then begin
                                                                                           mi_SQL:=xsite.BaseObjectSpace.SQLExecute('update receivedorders2 set x_vychystano=' + NxFloatToIBStr(mpocet + mbo.GetFieldValueAsFloat('X_vychystano')) + ' where id=' + QuotedStr(mBO.OID));
                                                                                           mpocet:=0;
                                                                                      end else begin
                                                                                           mpomoc_pocet:=mbo.GetFieldValueAsFloat('Quantity') - mbo.GetFieldValueAsFloat('DeliveredQuantity')-mbo.GetFieldValueAsFloat('X_vychystano');

                                                                                           mi_SQL:=xsite.BaseObjectSpace.SQLExecute('update receivedorders2 set x_vychystano=' + NxFloatToIBStr(mpomoc_pocet+ mbo.GetFieldValueAsFloat('X_vychystano')) + ' where id=' + QuotedStr(mBO.OID));
                                                                                           mpocet:=mpocet-mpomoc_pocet;
                                                                                      end;
                                                                                   end;
                                                                             end;
                                                                         end;
                                                                   finally
                                                                       mxx.free;
                                                                   end;


                                                              mpocet:=0;

                                                          //NxShowSimpleMessage('překročení počtu - zápis',nil);
                                                                abarcode:='.';
                                                                mStorecard_id:='';
                                                                  mstorecard_text:='';
                                                                  mdodano:=0 ;
                                                                  mvychystano:=0;
                                                                  mskladem:=0 ;
                                                                  mcelkem:=0;
                                                                  m_umisteni:='';
                                                                  mBO_Row_id:='';
                                                                  mbarcode:='.';

                                           exit;
                                       mbarcode:='';
                                       abarcode:='';

                                       end ;




                                       if (mix_result=2) then begin
                                           mbarcode:=mBarCodeEdt.text;

                                           if (ABarCode=mBarCode) and (ABarCode<>'.')   then begin
                                               mpocet:=mpocet+1;
                                               //NxShowSimpleMessage('stejný kód - ' + NxFloatToIBStr(mpocet) + ' - ' + inttostr(mix_result) + ' - ' + ABarCode + '/' + mbarcode,nil);
                                               if mpocet>mcelkem-mdodano-mvychystano then begin

                                                         mpocet:=mcelkem-mdodano-mvychystano;
                                                         // zápis
                                                         if mCLSID_DOC='05CPMINJW3DL342X01C0CX3FCC' then begin
                                                              // postupný zápis
                                                              mxx:=tstringlist.create;
                                                                   try
                                                                       xsite.BaseObjectSpace.SQLSelect(format(mSQL_Doklad_zapis,[quotedstr(mStorecard_id),mIDs_dDocument]),mxx) ;
                                                                         //NxShowSimpleMessage(inttostr(mxx.count),nil);
                                                                         if mxx.count>0 then begin
                                                                             for ixi:=0 to mxx.count-1 do begin
                                                                                  if mpocet>0 then begin
                                                                                      mbo.load(mxx.Strings[ixi],nil);
                                                                                      if mpocet<=mbo.GetFieldValueAsFloat('quantity') - mbo.GetFieldValueAsFloat('DeliveredQuantity')-mbo.GetFieldValueAsFloat('X_vychystano')  then begin
                                                                                           mi_SQL:=xsite.BaseObjectSpace.SQLExecute('update receivedorders2 set x_vychystano=' + NxFloatToIBStr(mpocet + mbo.GetFieldValueAsFloat('X_vychystano')) + ' where id=' + QuotedStr(mBO.OID));
                                                                                           mpocet:=0;
                                                                                      end else begin
                                                                                           mpomoc_pocet:=0;
                                                                                           mpomoc_pocet:=mbo.GetFieldValueAsFloat('Quantity') - mbo.GetFieldValueAsFloat('DeliveredQuantity')-mbo.GetFieldValueAsFloat('X_vychystano');

                                                                                           mi_SQL:=xsite.BaseObjectSpace.SQLExecute('update receivedorders2 set x_vychystano=' + NxFloatToIBStr(mpomoc_pocet+ mbo.GetFieldValueAsFloat('X_vychystano')) + ' where id=' + QuotedStr(mBO.OID));
                                                                                           mpocet:=mpocet-mpomoc_pocet;
                                                                                      end;
                                                                                   end;
                                                                             end;
                                                                         end;
                                                                   finally
                                                                       mxx.free;
                                                                   end;


                                                              mpocet:=0;
                                                         end;
                                                          //NxShowSimpleMessage('překročení počtu - zápis',nil);
                                                                abarcode:='.';
                                                                mStorecard_id:='';
                                                                  mstorecard_text:='';
                                                                  mdodano:=0 ;
                                                                  mvychystano:=0;
                                                                  mskladem:=0 ;
                                                                  mcelkem:=0;
                                                                  m_umisteni:='';
                                                                  mBO_Row_id:='';
                                                                  mbarcode:='.';

                                               end;

                                        end else begin
                                               //
                                               if true then begin
                                                  //NxShowSimpleMessage('jiná položka',nil);
                                                  if mStorecard_id<>'' then  begin
                                                      if mCLSID_DOC='05CPMINJW3DL342X01C0CX3FCC' then begin
                                                              // postupný zápis
                                                              mxx:=tstringlist.create;
                                                                   try
                                                                       xsite.BaseObjectSpace.SQLSelect(format(mSQL_Doklad_zapis,[quotedstr(mStorecard_id),mIDs_dDocument]),mxx) ;
                                                                         //NxShowSimpleMessage(inttostr(mxx.count),nil);
                                                                         if mxx.count>0 then begin
                                                                             for ixi:=0 to mxx.count-1 do begin
                                                                                  if mpocet>0 then begin
                                                                                      mbo.load(mxx.Strings[ixi],nil);
                                                                                      if mpocet<=mbo.GetFieldValueAsFloat('quantity') - mbo.GetFieldValueAsFloat('DeliveredQuantity')-mbo.GetFieldValueAsFloat('X_vychystano')  then begin
                                                                                           mi_SQL:=xsite.BaseObjectSpace.SQLExecute('update receivedorders2 set x_vychystano=' + NxFloatToIBStr(mpocet + mbo.GetFieldValueAsFloat('X_vychystano')) + ' where id=' + QuotedStr(mBO.OID));
                                                                                           mpocet:=0;
                                                                                      end else begin
                                                                                           mpomoc_pocet:=0;
                                                                                           mpomoc_pocet:=mbo.GetFieldValueAsFloat('Quantity') - mbo.GetFieldValueAsFloat('DeliveredQuantity')-mbo.GetFieldValueAsFloat('X_vychystano');

                                                                                           mi_SQL:=xsite.BaseObjectSpace.SQLExecute('update receivedorders2 set x_vychystano=' + NxFloatToIBStr(mpomoc_pocet+ mbo.GetFieldValueAsFloat('X_vychystano')) + ' where id=' + QuotedStr(mBO.OID));
                                                                                           mpocet:=mpocet-mpomoc_pocet;
                                                                                      end;
                                                                                   end;
                                                                             end;
                                                                         end;
                                                                   finally
                                                                       mxx.free;
                                                                   end;

                                                              mpocet:=0;

                                                                mStorecard_id:='';
                                                                  mstorecard_text:='';
                                                                  mdodano:=0 ;
                                                                  mvychystano:=0;
                                                                  mskladem:=0 ;
                                                                  mcelkem:=0;
                                                                  m_umisteni:='';
                                                                  mBO_Row_id:='';

                                                     end;
                                                   end;
                                                  mr:=tstringlist.create;

                                                          try
                                                             xsite.BaseObjectSpace.SQLSelect(format(mSQL_DokladEANns,[quotedstr(mbarcode),mIDs_dDocument]),mr);

                                                                if mr.count>0 then begin
                                                                 try
                                                                  mbo.load(mr.Strings[0],nil);
                                                                  mBO_Row_id:=mbo.oid;

                                                                        mStorecard_id:=mbo.GetFieldValueAsString('storecard_id');
                                                                        //NxShowSimpleMessage(mStorecard_id,nil);
                                                                        mTypSC:=mbo.GetFieldValueAsInteger('storecard_id.category');
                                                                        mstorecard_text:=mbo.GetFieldValueAsString('storecard_id.name');
                                                                               mcelkem:=GetFloatFromTable(xSite,'Select sum(RO2.quantity) from Receivedorders2 RO2 where (Ro2.Storecard_id=%s) and (RO2.Parent_ID in (%s))',quotedstr(mbo.GetFieldValueAsString('Storecard_ID')),mIDs_dDocument);
                                                                               mdodano:=GetFloatFromTable(xSite,'Select sum(RO2.DeliveredQuantity) from Receivedorders2 RO2 where (Ro2.Storecard_id=%s) and (RO2.Parent_ID in (%s))',quotedstr(mbo.GetFieldValueAsString('Storecard_ID')),mIDs_dDocument);
                                                                               mvychystano:=GetFloatFromTable(xSite,'Select sum(X_Vychystano) from Receivedorders2 RO2 where (Ro2.Storecard_id=%s) and (RO2.Parent_ID in (%s))',quotedstr(mbo.GetFieldValueAsString('Storecard_ID')),mIDs_dDocument);

                                                                        mr1:=TStringList.create;
                                                                        Try
                                                                           xsite.BaseObjectSpace.SQLSelect('select id from StoreSubCards where StoreCard_ID =' + quotedstr(mStorecard_id) + ' and Store_id=' + quotedstr(mbo.GetFieldValueAsString('store_id')),mr1);

                                                                           if mr1.Count=1 then begin
                                                                               mSsc:=xsite.BaseObjectSpace.CreateObject('GAWVAN4GFNDL342T01C0CX3FCC');
                                                                               try
                                                                                    mssc.load( mr1.Strings[0],nil);
                                                                                    if NxIsEmptyOID(mssc.GetFieldValueAsString('Location_id')) then m_umisteni:='' else m_umisteni:=mssc.GetFieldValueAsString('Location_id.Code');
                                                                                       //mcelkem:=mbo.GetFieldValueAsfloat('Quantity');
                                                                                       //mdodano:=mbo.GetFieldValueAsfloat('DeliveredQuantity') ;

                                                                                       mskladem:=mssc.GetFieldValueAsfloat('Quantity') ;
                                                                                       mjednotka:=mbo.GetFieldValueAsstring('Qunit')
                                                                               finally
                                                                                //mssc.free;
                                                                               end;
                                                                           end ;
                                                                        finally
                                                                           mr1.free;
                                                                        end;

                                                                        mpocet:=mpocet+1;

                                                                         ABarCode:=mbarcode;


                                                                 finally

                                                                 end;
                                                            end ;
                                                            if mr.count=0 then begin
                                                                NxShowSimpleMessage('Ean není v dokladu čerpatelný',nil);
                                                                nxbeep(btfailure);
                                                                abarcode:='.';
                                                                mbarcode:='.';
                                                                mStorecard_id:='';
                                                                  mstorecard_text:='';
                                                                  mdodano:=0 ;
                                                                  mvychystano:=0;
                                                                  mskladem:=0 ;
                                                                  mcelkem:=0;
                                                                  m_umisteni:='';
                                                                  mBO_Row_id:='';
                                                                  mpocet:=0;
                                                            end;



                                                   finally
                                                       mr.free;
                                                   end;




                                              end;
                                              end;




                                       end;    // mi result=2


                  finally
                      mForm.free;
                  end;
            end;  // pokračovat
      end;     // while
      finally
            mBO.free  ;
      end;





      xSite.Refresh;
      result:='A';

end;















function BarCodeDialogDL_prepravka(xSite:TSiteForm;mCLSID_DOC:string;mTBatches:boolean;
                       mTop:integer;mLeft:integer;mWith:integer;mHeight:integer;mLabel:string;
                       mTyp_prace:integer;mids:integer; mIDs_dDocument:string;
                       mbutton1,mbutton2,mbutton3,mbutton4:string;
                       Mbutton5:string):string;
var
      mForm : TForm;
      mBtn : TButton;
      mLbl : TLabel;
      mBarCodeEdt,mQuantityEdt,mUnitEdt,mLocEdt : TEdit;
      mQuanEdt,mDelQuanEdt,mStorQuanEdt,mVychQuanEdt:tedit;
      sum_mDelQuanEdt,sum_mStorQuanEdt,sum_mVychQuanEdt:tedit;
      i:integer;
      xresult:Variant;
      //mSCEdt:TRollComboEdit;
      mSCEdt:TEdit;
      ABarCode,mbarcode:string;
      mQuantity:double  ;
      mUnit:string;
      mpocet:double;
      mix_result:integer;
      mBatch_id,mStorecard_id,m_umisteni,mjednotka:string;
      mr,mr1:tstringlist;
      mBO,mSSC:TNxCustomBusinessObject;
      mStorQuan:double;
      mdodano,mvychystano,mskladem,mcelkem:double;
      SUM_mdodano,SUM_mvychystano,Sum_mskladem,Sum_mcelkem:double;
      mstorecard_text:string;
      mBO_Row_id:string;
      mi_SQL:integer;
      mTypSC:integer;
      mID_Batch,mID_Storecard:string;
      mBatchList,mrBatch:TStringList;
      mMemNote:tmemo;
      mpokracovat:Boolean;
      mxx:tstringlist ;
      ixi:integer;
      mpomoc_pocet:double;
begin
      mpokracovat:=true;
      Result := '';
      i:=1;
      ABarCode := '.';
      mBarCode:='';
      mpocet:=0;
      mStorecard_id:='';
                      mBO_Row_id:='';
                      mstorecard_text:='';
                      mdodano:=0 ;
                      mvychystano:=0;
                      mskladem:=0 ;
                      mcelkem:=0;
                      m_umisteni:='';

                     mjednotka:='';
                      mbarcode:='';
      mBO:=xsite.BaseObjectSpace.CreateObject('05CPMINJW3DL342X01C0CX3FCC');
      try
      while ABarCode <> '' do begin

       if mpokracovat then begin


                 mForm := TForm.Create(xsite);
                          try
                                        mForm.Caption := mLabel;mForm.FormStyle := fsStayOnTop;mForm.BorderStyle := bsDialog;
                                        if mTop>=0 then begin
                                          mForm.Top:= mTop;
                                          mForm.Left:= mLeft;
                                        end else begin
                                          mform.Position := poScreenCenter;
                                        end;

                                        mForm.Width := mWith;mForm.Height := mHeight;mForm.Scaled := False;
                                        mBarCodeEdt:=CreateEdit('mBarCodeEdt', 'Čarový kód',mform, 10,10,320,80,150,mBarCode,true,true,true,round(480/24), [fsBold],255) ;
                                        //mSCEdt:=CreateEdit('mSCEdt', 'Zboží.',mForm,10, 80, 300,80,50,AsString('Storecard_id.Name'),true,true,false,round(480/24),[fsBold],255);
                                        mMemNote := CreateMemo('ChMemNote','Zboží', 10, 80, 320,80, 150, mstorecard_text, mForm,true,true,False,round(480/36), [fsItalic],255);


                                        mLocEdt:=CreateEdit('mLocEdt', 'Umístění',mform, 10,200,320,80,150,m_umisteni,true,true,false,round(480/24), [fsBold],255) ;
                                        mBtn := TButton.Create(mForm);mBtn.Width := 65;mBtn.Height := 70;mBtn.Caption := '-';mBtn.ModalResult := 10;mBtn.Cancel := False;mBtn.Default := false;mBtn.Left:=10;mBtn.Top := 270;mBtn.Name := 'btnIgnore';mForm.InsertControl(mBtn);
                                        mQuantityEdt:=CreateEdit('mQuantityEdt', 'Množství',mForm,80, 270, 120,80,50,NxFloatToIBStr(mpocet),true,true,true,round(480/24),[fsBold],255);
                                        mBtn := TButton.Create(mForm);mBtn.Width := 65;mBtn.Height := 70;mBtn.Caption := '+';mBtn.ModalResult := 20;mBtn.Cancel := False;mBtn.Default := false;mBtn.Left:=260;mBtn.Top := 270;mBtn.Name := 'btnYea';mForm.InsertControl(mBtn);
                                        mUnitEdt:=CreateEdit('mUnitEdt', 'Jedn.',mForm,210, 270, 40,80,50,mjednotka,true,true,false,round(480/48),[fsBold],255);

                                        mcelkem:=GetFloatFromTable(xSite,mSQL_Doklad_quantitysp,ABarCode,mIDs_dDocument);
                                        mdodano:=GetFloatFromTable(xSite,mSQL_Doklad_deliveredsp,ABarCode,mIDs_dDocument);
                                        mvychystano:=GetFloatFromTable(xSite,mSQL_Doklad_vychystanosp,ABarCode,mIDs_dDocument);

                                        mQuanEdt:=CreateEdit_noformat('mQuanEdt', 'Celkem',mform, 10,350,70,80,150,NxFloatToIBStr(mcelkem),true,true,false,round(120/10),[fsBold],255) ;
                                        mDelQuanEdt:=CreateEdit_noformat('mDelQuanEdt', 'Dodano',mform, 90,350,70,80,150,NxFloatToIBStr(mdodano),true,true,false,round(120/10),[fsBold],255) ;
                                        mStorQuanEdt:=CreateEdit_noformat('mStorQuanEdt', 'Skladem',mform, 170,350,70,80,150,NxFloatToIBStr(mskladem),true,true,false,round(120/10),[fsBold],255) ;
                                        mVychQuanEdt:=CreateEdit_noformat('mVychQuanEdt', 'Vychystano',mform, 270,350,70,80,150,NxFloatToIBStr(mvychystano),true,true,false,round(120/10),[fsBold],255) ;


                                     //   if ((mbo_ReceivedOrder_row.GetFieldValueAsInteger('Storecard_id.Category')=3) or (mbo_ReceivedOrder_row.GetFieldValueAsInteger('Storecard_id.Category')=2)) and (mTBatches) then begin
                                     //           mBtn := TButton.Create(mForm);mBtn.Width := 75;mBtn.Height := 40;
                                     //           if (mbo_ReceivedOrder_row.GetFieldValueAsInteger('Storecard_id.Category')=2) then mBtn.Caption := 'Sériové číslo';
                                     //           if (mbo_ReceivedOrder_row.GetFieldValueAsInteger('Storecard_id.Category')=3) then mBtn.Caption := 'Šarže';
                                     //
                                     //           mBtn.ModalResult := 99;mBtn.Cancel := True;mBtn.Left := 10;mBtn.Top := mForm.Height - mBtn.Height - 60;mBtn.Visible:=true;mBtn.Name := 'btnŠarže';mForm.InsertControl(mBtn);
                                     //   end;

                                       mBtn := TButton.Create(mForm);mBtn.ModalResult := 2;mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := mbutton1; mBtn.Cancel := False;mBtn.Default := True;mBtn.Left:=mForm.Width - 2*(mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 40;mBtn.Name := 'btnOK';mForm.InsertControl(mBtn);
                                       mBtn := TButton.Create(mForm);mBtn.ModalResult := 0;mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := mbutton2;mBtn.Cancel := True;mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 40;mBtn.Name := 'btnCancel';mForm.InsertControl(mBtn);
                                       mBtn := TButton.Create(mForm);mBtn.ModalResult := 1;mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := 'Zápis';mBtn.Cancel := false;mBtn.Left := 10;mBtn.Top := mForm.Height - mBtn.Height - 40;mBtn.Name := 'btnyestoall';mForm.InsertControl(mBtn);
                                       mBtn := TButton.Create(mForm);mBtn.ModalResult := 22;mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := 'Přerušit';mBtn.Cancel := false;mBtn.Left := mForm.Width - 3*(mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 40;mBtn.Name := 'btn99';mForm.InsertControl(mBtn);

      //                                 mBtn := TButton.Create(mForm);mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := 'OK';mBtn.ModalResult := mrOk; mBtn.Cancel := False;mBtn.Default := True;mBtn.Left:=mForm.Width - 2*(mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 60;mBtn.Name := 'btnOK';mForm.InsertControl(mBtn);
      //                                 mBtn := TButton.Create(mForm);mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := 'Storno';mBtn.ModalResult := mrCancel;mBtn.Cancel := True;mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 60;mBtn.Name := 'btnCancel';mForm.InsertControl(mBtn);


                                       mix_result:= mForm.ShowModal(xsite);   // změna položky




                                       //if (mix_result = 2) then exit;
                                       if mix_result=10 then mpocet:=mpocet-1;
                                       if mix_result=20 then begin
                                             mpocet:=mpocet+1;
                                           if mpocet>mcelkem-mdodano-mvychystano then begin
                                              NxShowSimpleMessage('Max množství pro položku je ' + NxFloatToIBStr(mcelkem-mdodano - mvychystano) +
                                               ,nil);
                                               nxbeep(btfailure);
                                               mpocet:=mcelkem-mdodano-mvychystano;
                                           end;
                                        end;

                                        if (mix_result = 1) then begin
                                           if mCLSID_DOC='05CPMINJW3DL342X01C0CX3FCC' then begin
                                                              // postupný zápis
                                                              mxx:=tstringlist.create;
                                                                   try
                                                                       xsite.BaseObjectSpace.SQLSelect(format(mSQL_Doklad_zapisDL,[quotedstr(mStorecard_id),mIDs_dDocument]),mxx) ;
                                                                         //NxShowSimpleMessage(inttostr(mxx.count),nil);
                                                                         if mxx.count>0 then begin
                                                                             for ixi:=0 to mxx.count-1 do begin
                                                                                  if mpocet>0 then begin
                                                                                      mbo.load(mxx.Strings[ixi],nil);
                                                                                      if mpocet<=mbo.GetFieldValueAsFloat('quantity') - mbo.GetFieldValueAsFloat('DeliveredQuantity')-mbo.GetFieldValueAsFloat('X_dodano')  then begin
                                                                                           mi_SQL:=xsite.BaseObjectSpace.SQLExecute('update receivedorders2 set x_dodano=' + NxFloatToIBStr(mpocet + mbo.GetFieldValueAsFloat('X_dodano')) + ' where id=' + QuotedStr(mBO.OID));
                                                                                           mpocet:=0;
                                                                                      end else begin
                                                                                           mpomoc_pocet:=mbo.GetFieldValueAsFloat('Quantity') - mbo.GetFieldValueAsFloat('DeliveredQuantity')-mbo.GetFieldValueAsFloat('X_dodano');

                                                                                           mi_SQL:=xsite.BaseObjectSpace.SQLExecute('update receivedorders2 set x_dodano=' + NxFloatToIBStr(mpomoc_pocet+ mbo.GetFieldValueAsFloat('X_dodano')) + ' where id=' + QuotedStr(mBO.OID));
                                                                                           mpocet:=mpocet-mpomoc_pocet;
                                                                                      end;
                                                                                   end;
                                                                             end;
                                                                         end;
                                                                   finally
                                                                       mxx.free;
                                                                   end;


                                                              mpocet:=0;
                                                         end;
                                                          //NxShowSimpleMessage('překročení počtu - zápis',nil);
                                                                abarcode:='.';
                                                                mStorecard_id:='';
                                                                  mstorecard_text:='';
                                                                  mdodano:=0 ;
                                                                  mvychystano:=0;
                                                                  mskladem:=0 ;
                                                                  mcelkem:=0;
                                                                  m_umisteni:='';
                                                                  mBO_Row_id:='';
                                                                  mbarcode:='.';


                                       end ;



                                        if (mix_result = 22) then begin
                                           if mCLSID_DOC='05CPMINJW3DL342X01C0CX3FCC' then begin
                                                              // postupný zápis
                                                              mxx:=tstringlist.create;
                                                                   try
                                                                       xsite.BaseObjectSpace.SQLSelect(format(mSQL_Doklad_zapisDL,[quotedstr(mStorecard_id),mIDs_dDocument]),mxx) ;
                                                                         //NxShowSimpleMessage(inttostr(mxx.count),nil);
                                                                         if mxx.count>0 then begin
                                                                             for ixi:=0 to mxx.count-1 do begin
                                                                                  if mpocet>0 then begin
                                                                                      mbo.load(mxx.Strings[ixi],nil);
                                                                                      if mpocet<=mbo.GetFieldValueAsFloat('quantity') - mbo.GetFieldValueAsFloat('DeliveredQuantity')-mbo.GetFieldValueAsFloat('X_dodano')  then begin
                                                                                           mi_SQL:=xsite.BaseObjectSpace.SQLExecute('update receivedorders2 set x_dodano=' + NxFloatToIBStr(mpocet + mbo.GetFieldValueAsFloat('X_dodano')) + ' where id=' + QuotedStr(mBO.OID));
                                                                                           mpocet:=0;
                                                                                      end else begin
                                                                                           mpomoc_pocet:=mbo.GetFieldValueAsFloat('Quantity') - mbo.GetFieldValueAsFloat('DeliveredQuantity')-mbo.GetFieldValueAsFloat('X_dodano');

                                                                                           mi_SQL:=xsite.BaseObjectSpace.SQLExecute('update receivedorders2 set x_dodano=' + NxFloatToIBStr(mpomoc_pocet+ mbo.GetFieldValueAsFloat('X_dodano')) + ' where id=' + QuotedStr(mBO.OID));
                                                                                           mpocet:=mpocet-mpomoc_pocet;
                                                                                      end;
                                                                                   end;
                                                                             end;
                                                                         end;
                                                                   finally
                                                                       mxx.free;
                                                                   end;


                                                              mpocet:=0;
                                                         end;
                                                          //NxShowSimpleMessage('překročení počtu - zápis',nil);
                                                                abarcode:='.';
                                                                mStorecard_id:='';
                                                                  mstorecard_text:='';
                                                                  mdodano:=0 ;
                                                                  mvychystano:=0;
                                                                  mskladem:=0 ;
                                                                  mcelkem:=0;
                                                                  m_umisteni:='';
                                                                  mBO_Row_id:='';
                                                                  mbarcode:='.';

                                           exit;
                                       end ;



                                       if (mix_result=2) then begin
                                           mbarcode:=mBarCodeEdt.text;

                                           if (ABarCode=mBarCode) and (ABarCode<>'.')   then begin
                                               mpocet:=mpocet+1;
                                               //NxShowSimpleMessage('stejný kód - ' + NxFloatToIBStr(mpocet) + ' - ' + inttostr(mix_result) + ' - ' + ABarCode + '/' + mbarcode,nil);
                                               if mpocet>mcelkem-mdodano-mvychystano then begin

                                                         mpocet:=mcelkem-mdodano-mvychystano;
                                                         // zápis
                                                         if mCLSID_DOC='05CPMINJW3DL342X01C0CX3FCC' then begin
                                                              // postupný zápis
                                                              mxx:=tstringlist.create;
                                                                   try
                                                                       xsite.BaseObjectSpace.SQLSelect(format(mSQL_Doklad_zapisdl,[quotedstr(mStorecard_id),mIDs_dDocument]),mxx) ;
                                                                         //NxShowSimpleMessage(inttostr(mxx.count),nil);
                                                                         if mxx.count>0 then begin
                                                                             for ixi:=0 to mxx.count-1 do begin
                                                                                  if mpocet>0 then begin
                                                                                      mbo.load(mxx.Strings[ixi],nil);
                                                                                      if mpocet<=mbo.GetFieldValueAsFloat('quantity') - mbo.GetFieldValueAsFloat('DeliveredQuantity')-mbo.GetFieldValueAsFloat('X_dodano')  then begin
                                                                                           mi_SQL:=xsite.BaseObjectSpace.SQLExecute('update receivedorders2 set x_dodano=' + NxFloatToIBStr(mpocet + mbo.GetFieldValueAsFloat('X_dodano')) + ' where id=' + QuotedStr(mBO.OID));
                                                                                           mpocet:=0;
                                                                                      end else begin
                                                                                           mpomoc_pocet:=mbo.GetFieldValueAsFloat('Quantity') - mbo.GetFieldValueAsFloat('DeliveredQuantity')-mbo.GetFieldValueAsFloat('X_dodano');

                                                                                           mi_SQL:=xsite.BaseObjectSpace.SQLExecute('update receivedorders2 set x_dodano=' + NxFloatToIBStr(mpomoc_pocet+ mbo.GetFieldValueAsFloat('X_dodano')) + ' where id=' + QuotedStr(mBO.OID));
                                                                                           mpocet:=mpocet-mpomoc_pocet;
                                                                                      end;
                                                                                   end;
                                                                             end;
                                                                         end;
                                                                   finally
                                                                       mxx.free;
                                                                   end;


                                                              mpocet:=0;
                                                         end;
                                                          //NxShowSimpleMessage('překročení počtu - zápis',nil);
                                                                abarcode:='.';
                                                                mStorecard_id:='';
                                                                  mstorecard_text:='';
                                                                  mdodano:=0 ;
                                                                  mvychystano:=0;
                                                                  mskladem:=0 ;
                                                                  mcelkem:=0;
                                                                  m_umisteni:='';
                                                                  mBO_Row_id:='';
                                                                  mbarcode:='.';

                                               end;

                                        end ;
                                        if (mix_result=0) then begin
                                               //
                                               if true then begin
                                                  //NxShowSimpleMessage('jiná položka',nil);
                                                  if mStorecard_id<>'' then  begin
                                                      if mCLSID_DOC='05CPMINJW3DL342X01C0CX3FCC' then begin
                                                              // postupný zápis
                                                              mxx:=tstringlist.create;
                                                                   try
                                                                       xsite.BaseObjectSpace.SQLSelect(format(mSQL_Doklad_zapisdl,[quotedstr(mStorecard_id),mIDs_dDocument]),mxx) ;
                                                                         //NxShowSimpleMessage(inttostr(mxx.count),nil);
                                                                         if mxx.count>0 then begin
                                                                             for ixi:=0 to mxx.count-1 do begin
                                                                                  if mpocet>0 then begin
                                                                                      mbo.load(mxx.Strings[ixi],nil);
                                                                                      if mpocet<=mbo.GetFieldValueAsFloat('quantity') - mbo.GetFieldValueAsFloat('DeliveredQuantity')-mbo.GetFieldValueAsFloat('X_dodano')  then begin
                                                                                           mi_SQL:=xsite.BaseObjectSpace.SQLExecute('update receivedorders2 set x_dodano=' + NxFloatToIBStr(mpocet + mbo.GetFieldValueAsFloat('X_dodano')) + ' where id=' + QuotedStr(mBO.OID));
                                                                                           mpocet:=0;
                                                                                      end else begin
                                                                                           mpomoc_pocet:=mbo.GetFieldValueAsFloat('Quantity') - mbo.GetFieldValueAsFloat('DeliveredQuantity')-mbo.GetFieldValueAsFloat('X_dodano');

                                                                                           mi_SQL:=xsite.BaseObjectSpace.SQLExecute('update receivedorders2 set x_dodano=' + NxFloatToIBStr(mpomoc_pocet+ mbo.GetFieldValueAsFloat('X_dodano')) + ' where id=' + QuotedStr(mBO.OID));
                                                                                           mpocet:=mpocet-mpomoc_pocet;
                                                                                      end;
                                                                                   end;
                                                                             end;
                                                                         end;
                                                                   finally
                                                                       mxx.free;
                                                                   end;

                                                              mpocet:=0;

                                                                mStorecard_id:='';
                                                                  mstorecard_text:='';
                                                                  mdodano:=0 ;
                                                                  mvychystano:=0;
                                                                  mskladem:=0 ;
                                                                  mcelkem:=0;
                                                                  m_umisteni:='';
                                                                  mBO_Row_id:='';

                                                     end;
                                                   end;
                                                  mr:=tstringlist.create;

                                                          try
                                                             xsite.BaseObjectSpace.SQLSelect(format('select ro2.id from STOREEANS SE left join StoreUnits SU on SU.id=se.Parent_id left join Storecards SC on sc.id=su.parent_id left join Receivedorders2 RO2 on ro2.storecard_id=sc.id left join Receivedorders RO on ro.id=ro2.parent_id where (RO.closed = ''N'' ) and ((RO2.Quantity - Ro2.DeliveredQuantity-Ro2.X_dodano)>0) and  (se.EAN=%s and (RO.ID in (%s)))',[quotedstr(mbarcode),mIDs_dDocument]),mr);

                                                                if mr.count>0 then begin
                                                                 try
                                                                  mbo.load(mr.Strings[0],nil);
                                                                  mBO_Row_id:=mbo.oid;

                                                                        mStorecard_id:=mbo.GetFieldValueAsString('storecard_id');
                                                                        //NxShowSimpleMessage(mStorecard_id,nil);
                                                                        mTypSC:=mbo.GetFieldValueAsInteger('storecard_id.category');
                                                                        mstorecard_text:=mbo.GetFieldValueAsString('storecard_id.name');
                                                                               mcelkem:=GetFloatFromTable(xSite,'Select sum(RO2.quantity) from Receivedorders2 RO2 where (Ro2.Storecard_id=%s) and (RO2.Parent_ID in (%s))',quotedstr(mbo.GetFieldValueAsString('Storecard_ID')),mIDs_dDocument);
                                                                               mdodano:=GetFloatFromTable(xSite,'Select sum(RO2.DeliveredQuantity) from Receivedorders2 RO2 where (Ro2.Storecard_id=%s) and (RO2.Parent_ID in (%s))',quotedstr(mbo.GetFieldValueAsString('Storecard_ID')),mIDs_dDocument);
                                                                               mvychystano:=GetFloatFromTable(xSite,'Select sum(X_dodano) from Receivedorders2 RO2 where (Ro2.Storecard_id=%s) and (RO2.Parent_ID in (%s))',quotedstr(mbo.GetFieldValueAsString('Storecard_ID')),mIDs_dDocument);

                                                                        mr1:=TStringList.create;
                                                                        Try
                                                                           xsite.BaseObjectSpace.SQLSelect('select id from StoreSubCards where StoreCard_ID =' + quotedstr(mStorecard_id) + ' and Store_id=' + quotedstr(mbo.GetFieldValueAsString('store_id')),mr1);

                                                                           if mr1.Count=1 then begin
                                                                               mSsc:=xsite.BaseObjectSpace.CreateObject('GAWVAN4GFNDL342T01C0CX3FCC');
                                                                               try
                                                                                    mssc.load( mr1.Strings[0],nil);
                                                                                    if NxIsEmptyOID(mssc.GetFieldValueAsString('Location_id')) then m_umisteni:='' else m_umisteni:=mssc.GetFieldValueAsString('Location_id.Code');
                                                                                       //mcelkem:=mbo.GetFieldValueAsfloat('Quantity');
                                                                                       //mdodano:=mbo.GetFieldValueAsfloat('DeliveredQuantity') ;

                                                                                       mskladem:=mssc.GetFieldValueAsfloat('Quantity') ;
                                                                                       mjednotka:=mbo.GetFieldValueAsstring('Qunit')
                                                                               finally
                                                                                //mssc.free;
                                                                               end;
                                                                           end ;
                                                                        finally
                                                                           mr1.free;
                                                                        end;

                                                                        mpocet:=mpocet+1;

                                                                         ABarCode:=mbarcode;


                                                                 finally

                                                                 end;
                                                            end ;
                                                            if mr.count=0 then begin
                                                                NxShowSimpleMessage('Ean není v dokladu čerpatelný',nil);
                                                                nxbeep(btfailure);
                                                                abarcode:='.';
                                                                mbarcode:='.';
                                                                mStorecard_id:='';
                                                                  mstorecard_text:='';
                                                                  mdodano:=0 ;
                                                                  mvychystano:=0;
                                                                  mskladem:=0 ;
                                                                  mcelkem:=0;
                                                                  m_umisteni:='';
                                                                  mBO_Row_id:='';
                                                                  mpocet:=0;
                                                            end;



                                                   finally
                                                       mr.free;
                                                   end;




                                              end;
                                              end;




                                       end;    // mi result=2



                  finally
                      mForm.free;
                  end;
            end;  // pokračovat
      end;     // while
      finally
            mBO.free  ;
      end;

      {

      if mCLSID_DOC='05CPMINJW3DL342X01C0CX3FCC' then begin
                                                              // postupný zápis
                                                              mxx:=tstringlist.create;
                                                                   try
                                                                       xsite.BaseObjectSpace.SQLSelect(format(mSQL_Doklad_zapisdl,[quotedstr(mStorecard_id),mIDs_dDocument]),mxx) ;
                                                                         //NxShowSimpleMessage(inttostr(mxx.count),nil);
                                                                         if mxx.count>0 then begin
                                                                             for ixi:=0 to mxx.count-1 do begin
                                                                                  if mpocet>0 then begin
                                                                                      mbo.load(mxx.Strings[ixi],nil);
                                                                                      if mpocet<=mbo.GetFieldValueAsFloat('quantity') - mbo.GetFieldValueAsFloat('DeliveredQuantity')-mbo.GetFieldValueAsFloat('X_dodano')  then begin
                                                                                           mi_SQL:=xsite.BaseObjectSpace.SQLExecute('update receivedorders2 set x_dodano=' + NxFloatToIBStr(mpocet + mbo.GetFieldValueAsFloat('X_dodano')) + ' where id=' + QuotedStr(mBO.OID));
                                                                                           mpocet:=0;
                                                                                      end else begin
                                                                                           mpomoc_pocet:=mbo.GetFieldValueAsFloat('Quantity') - mbo.GetFieldValueAsFloat('DeliveredQuantity')-mbo.GetFieldValueAsFloat('X_dodano');

                                                                                           mi_SQL:=xsite.BaseObjectSpace.SQLExecute('update receivedorders2 set x_dodano=' + NxFloatToIBStr(mpomoc_pocet+ mbo.GetFieldValueAsFloat('X_dodano')) + ' where id=' + QuotedStr(mBO.OID));
                                                                                           mpocet:=mpocet-mpomoc_pocet;
                                                                                      end;
                                                                                   end;
                                                                             end;
                                                                         end;
                                                                   finally
                                                                       mxx.free;
                                                                   end;

                                                              mpocet:=0;

                                                                mStorecard_id:='';
                                                                  mstorecard_text:='';
                                                                  mdodano:=0 ;
                                                                  mvychystano:=0;
                                                                  mskladem:=0 ;
                                                                  mcelkem:=0;
                                                                  m_umisteni:='';
                                                                  mBO_Row_id:='';

                                                     end;   }

      xSite.Refresh;
      result:='A';

end;



function BarCodeDialog_DL(xSite:TSiteForm;mBO_head:TNxCustomBusinessObject;mBO_rows:TNxCustomBusinessMonikerCollection;
                       mTop:integer;mLeft:integer;mWith:integer;mHeight:integer;mLabel:string;
                       mTyp_prace:integer;mids:integer; mIDs_dDocument:string;
                       mbutton1,mbutton2,mbutton3,mbutton4:string;
                       Mbutton5:string):string;
var
      mForm : TForm;
      mBtn : TButton;
      mLbl : TLabel;
      mBarCodeEdt,mQuantityEdt,mUnitEdt,mLocEdt : TEdit;
      mQuanEdt,mDelQuanEdt,mStorQuanEdt,mVychQuanEdt:tedit;
      sum_mDelQuanEdt,sum_mStorQuanEdt,sum_mVychQuanEdt:tedit;
      i:integer;
      xresult:Variant;
      //mSCEdt:TRollComboEdit;
      mSCEdt:TEdit;
      ABarCode,mbarcode:string;
      mQuantity:double  ;
      mUnit:string;
      mpocet:double;
      mix_result:integer;
      mBatch_id,mStorecard_id,m_umisteni,mjednotka:string;
      mr,mr1:tstringlist;
      mBO,mSSC,mBO_Row:TNxCustomBusinessObject;
      mStorQuan:double;
      mdodano,mvychystano,mskladem,mcelkem:double;
      SUM_mdodano,SUM_mvychystano,Sum_mskladem,Sum_mcelkem:double;
      mstorecard_text:string;
      mBO_Row_id:string;
      mi_SQL:integer;
      mTypSC:integer;
      mID_Batch,mID_Storecard:string;
      mBatchList,mrBatch:TStringList;
      mMemNote:tmemo;
      mObject:integer;
      mfind:boolean;
      msc_category,xa:integer;
      mlist_batch:tstringlist;
      mBO_Batches:TNxCustomBusinessMonikerCollection;
      mBO_batch:TNxCustomBusinessObject;

begin
      mNUM_button:=5;
      Result := '';
      msc_category:=0;
      i:=1;
      ABarCode := '.';
      mBarCode:='';
      mpocet:=1;
      mStorecard_id:='';
                      mBO_Row_id:='';
                      mstorecard_text:='';
                      mdodano:=0 ;
                      mvychystano:=0;
                      mskladem:=0 ;
                      mcelkem:=0;
                      m_umisteni:='';

                      SUM_mdodano:=0 ;
                      SUM_mvychystano:=0;
                      SUM_mskladem:=0 ;
                      SUM_mcelkem:=0;

                      mjednotka:='';
                      mbarcode:='';
      while ABarCode <> '' do begin
       try

           mForm := TForm.Create(xsite);
          if True then mForm.Color := clBtnFace else mForm.Color:= clRed ;
                                  mForm.Caption := mLabel;mForm.FormStyle := fsStayOnTop;mForm.BorderStyle := bsDialog;
                                  if mTop>=0 then begin
                                    mForm.Top:= mTop;
                                    mForm.Left:= mLeft;
                                  end else begin
                                    mform.Position := poScreenCenter;
                                  end;

                                  mForm.Width := mWith;mForm.Height := mHeight;mForm.Scaled := False;
                                  mBarCodeEdt:=CreateEdit('mBarCodeEdt', 'Čarový kód',mform, 10,10,320,80,150,mBarCode,true,true,true,round(480/24), [fsBold],255) ;
                                  mMemNote := CreateMemo('ChMemNote','Zboží', 10, 80, 320,80, 150, mstorecard_text, mForm,true,true,False,round(480/36), [fsItalic],255);


                                  mLocEdt:=CreateEdit('mLocEdt', 'Umístění',mform, 10,200,320,80,150,m_umisteni,true,true,false,round(480/24), [fsBold],255) ;
                                  mBtn := TButton.Create(mForm);mBtn.Width := 65;mBtn.Height := 70;mBtn.Caption := '-';mBtn.ModalResult := 10;mBtn.Cancel := False;mBtn.Default := false;mBtn.Left:=10;mBtn.Top := 270;mBtn.Name := 'btnIgnore';mForm.InsertControl(mBtn);
                                  mQuantityEdt:=CreateEdit('mQuantityEdt', 'Množství',mForm,80, 270, 120,80,50,NxFloatToIBStr(mpocet),true,true,true,round(480/24),[fsBold],255);
                                  mBtn := TButton.Create(mForm);mBtn.Width := 65;mBtn.Height := 70;mBtn.Caption := '+';mBtn.ModalResult := 20;mBtn.Cancel := False;mBtn.Default := false;mBtn.Left:=260;mBtn.Top := 270;mBtn.Name := 'btnYea';mForm.InsertControl(mBtn);
                                  mUnitEdt:=CreateEdit('mUnitEdt', 'Jedn.',mForm,210, 270, 40,80,50,mjednotka,true,true,false,round(480/48),[fsBold],255);

                                  mcelkem:=GetFloatFromTable(xSite,mSQL_Doklad_quantity,ABarCode,mIDs_dDocument);
                                  mdodano:=GetFloatFromTable(xSite,mSQL_Doklad_delivered,ABarCode,mIDs_dDocument);
                                  mvychystano:=GetFloatFromTable(xSite,mSQL_Doklad_vychystano,ABarCode,mIDs_dDocument);


                                  mQuanEdt:=CreateEdit_noformat('mQuanEdt', 'Celkem',mform, 10,350,70,80,150,NxFloatToIBStr(mcelkem),true,true,false,round(120/10),[fsBold],255) ;
                                  mDelQuanEdt:=CreateEdit_noformat('mDelQuanEdt', 'Dodano',mform, 90,350,70,80,150,NxFloatToIBStr(mdodano + mpocet),true,true,false,round(120/10),[fsBold],255) ;
                                  mStorQuanEdt:=CreateEdit_noformat('mStorQuanEdt', 'Skladem',mform, 170,350,70,80,150,NxFloatToIBStr(mskladem),true,true,false,round(120/10),[fsBold],255) ;
                                  mVychQuanEdt:=CreateEdit_noformat('mVychQuanEdt', 'Vychystano',mform, 270,350,70,80,150,NxFloatToIBStr(mvychystano),true,true,false,round(120/10),[fsBold],255) ;

                                  if msc_category<>0 then begin
                                          if (msc_category<>0) then begin
                                                  mBtn := TButton.Create(mForm);mBtn.Width := 75;mBtn.Height := 40;
                                                  if (msc_category=2) then mBtn.Caption := 'Sériové číslo';
                                                  if (msc_category=3) then mBtn.Caption := 'Šarže';

                                             //     mBtn.ModalResult := 81;mBtn.Cancel := false;mBtn.Left := 10;mBtn.Top := 350;mBtn.Visible:=true;mBtn.Name := 'btnŠarže';mForm.InsertControl(mBtn);
                                          end;
                                  end;



                                 mBtn := TButton.Create(mForm);mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := mbutton1;mBtn.ModalResult := 2; mBtn.Cancel := False;mBtn.Default := True;mBtn.Left:=mForm.Width - 2*(mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 40;mBtn.Name := 'btnOK';mForm.InsertControl(mBtn);
                                 mBtn := TButton.Create(mForm);mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := mbutton2;mBtn.ModalResult := 0;mBtn.Cancel := True;mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 40;mBtn.Name := 'btnCancel';mForm.InsertControl(mBtn);
                                 mBtn := TButton.Create(mForm);mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := 'Zápis';mBtn.ModalResult := 1;mBtn.Cancel := False;mBtn.Left := 10;mBtn.Top := mForm.Height - mBtn.Height - 40;mBtn.Name := 'btnyestoall';mForm.InsertControl(mBtn);
                                 mBtn := TButton.Create(mForm);mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := 'Přerušit';mBtn.ModalResult := 99;mBtn.Cancel := False;mBtn.Left := mForm.Width - 3*(mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 40;mBtn.Name := 'btn99';mForm.InsertControl(mBtn);
                                 //mBtn := TButton.Create(mForm);mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := 'Vytvoř doklad';mBtn.ModalResult := 99;mBtn.Cancel := False;mBtn.Left := mForm.Width - 3*(mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 40;mBtn.Name := 'btn99';mForm.InsertControl(mBtn);







//                                 mBtn := TButton.Create(mForm);mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := 'OK';mBtn.ModalResult := mrOk; mBtn.Cancel := False;mBtn.Default := True;mBtn.Left:=mForm.Width - 2*(mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 60;mBtn.Name := 'btnOK';mForm.InsertControl(mBtn);
//                                 mBtn := TButton.Create(mForm);mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := 'Storno';mBtn.ModalResult := mrCancel;mBtn.Cancel := True;mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 60;mBtn.Name := 'btnCancel';mForm.InsertControl(mBtn);


                                 mix_result:= mForm.ShowModal(xsite);   // změna položky
                                 //NxShowSimpleMessage(inttostr(mix_result),nil);
                                 if mix_result=10 then
                                      mpocet:=mpocet-1;

                                  if mix_result=20 then begin
                                       mpocet:=mpocet+1;
                                     if mpocet>=mcelkem+1-mdodano then begin
                                         NxShowSimpleMessage('Max množství pro položku je ' + NxFloatToIBStr(mcelkem-mdodano) +
                                         NxFloatToIBStr(mpocet) + ' - ' +NxFloatToIBStr(mcelkem-mdodano)
                                         ,nil);
                                         nxbeep(btfailure);
                                         mpocet:=mcelkem-mdodano ;
                                     end;
                                   end;



                                   if mix_result=1 then begin
                                     if mpocet>0 then begin
                                         mBO_rows.BusinessObject[mObject].SetFieldValueAsFloat('Quantity',mpocet);
                                     end;
                                   end;
                                    if mix_result=99 then begin
                                     if mpocet>0 then begin
                                         mBO_rows.BusinessObject[mObject].SetFieldValueAsFloat('Quantity',mpocet);
                                     end;
                                   end;




                                 if mix_result=81 then begin
                                     mlist_batch:=TStringList.create;
                                         try;
                                             //mBO_batches := mBO_rows.GetLoadedCollectionMonikerForFieldCode(mBO_rows.GetFieldCode('DocRowBatches'));
                                             mlist_batch:=
                                              BarCode_batch(xSite,'05CPMINJW3DL342X01C0CX3FCC',
                                                      0,0,360,480,
                                                      mBO_rows.BusinessObject[i],'Šarže pro: ' + mBO_rows.BusinessObject[i].GetFieldValueAsString('storecard_id.code'),'Ean','Pokračovat','','');

                                             //for xa:=0 to mlist_batch.count-1 do begin
                                             xa:=1;
                                                 mbo_batch := mBO_rows.BusinessObject[i].GetCollectionMonikerForFieldCode(mBO_rows.BusinessObject[i].GetFieldCode('DocRowBatches')).AddNewObject;
                                                  mBO_batch.Prefill;
                                                  mBO_batch.SetFieldValueAsinteger('PosIndex',xa);
                                                  mbo_batch.SetFieldValueAsString('StoreBatch_ID', '6TU1000101');
                                                  mbo_batch.SetFieldValueAsfloat('Quantity',1);
                                                  //mbo_batch.CopyFieldValueFrom(mFinishedProductRowBO, 'QUnit');
                                                  //mbo_batch.CopyFieldValueFrom(mFinishedProductRowBO, 'UnitRate');






                                                 {mbo_batch:=mBO_batches.AddNewObject;
                                                 mBO_batch.Prefill;
                                                 mBO_batch.SetFieldValueAsBoolean('NewBatch',true);
                                                 mBO_batch.SetFieldValueAsString('NewBatchName','AAAA');

                                                 mBO_batch.SetFieldValueAsfloat('Quantity',1);
                                                 mBO_batch.SetFieldValueAsString('StoreBatch_ID','AAAA');
                                                 mBO_batch.SetFieldValueAsString('StoreSubBatch_ID','AAAA');
                                                 //mBO_batch.SetFieldValueAsString('NewBatchName','AAAA');
                                                 //mBO_batch.SetFieldValueAsString('NewBatchName','AAAA');   }
                                             //end;
                                             //NxShowSimpleMessage('Počet šarží ' + inttostr(mlist_batch.count),nil)
                                         finally
                                             mlist_batch.free;
                                         end;
                                 end;


                                 if (mix_result=99) then begin
                                     mbarcode:='';
                                     ABarCode:='';
                                     exit;
                                 end ;


                                 if (mix_result=0) then begin
                                     mbarcode:='';
                                     ABarCode:='';
                                     exit;
                                 end ;

                                 if (mix_result<>0) and (mix_result<>1)  and (mix_result <> 99) and (mix_result<>10) and (mix_result<>20) then begin

                                       mbarcode:=mBarCodeEdt.text;
                                       if mbarcode<>'' then begin
                                                mr:=tstringlist.create;
                                                try
                                                      xsite.BaseObjectSpace.SQLSelect(format(mSQL_SCEAN,[quotedstr(mbarcode)]),mr);
                                                    //end;
                                                      if mr.count>0 then begin
                                                            mObject:=(-1);
                                                            mfind:=false;
                                                            for i:=0 to mBO_rows.Count-1 do begin
                                                                 if (mBO_rows.BusinessObject[i].GetFieldValueAsString('storecard_id')=mr.Strings[0]) then begin
                                                                    mfind:=true;
                                                                    try
                                                                              //mBO_Row:=mBO_rows.BusinessObject[i];
                                                                                    mObject:=i;
                                                                                    mStorecard_id:=mBO_rows.BusinessObject[i].GetFieldValueAsString('storecard_id');
                                                                                    msc_category:=mBO_rows.BusinessObject[i].GetFieldValueAsInteger('storecard_id.category');
                                                                                    mstorecard_text:=mBO_rows.BusinessObject[i].GetFieldValueAsString('storecard_id.name');
                                                                                    mr1:=TStringList.create;
                                                                                    Try
                                                                                       xsite.BaseObjectSpace.SQLSelect('select id from StoreSubCards where StoreCard_ID =' + quotedstr(mStorecard_id) + ' and Store_id=' + quotedstr(mBO_rows.BusinessObject[i].GetFieldValueAsString('store_id')),mr1);

                                                                                       if mr1.Count>0 then begin
                                                                                           mSsc:=xsite.BaseObjectSpace.CreateObject('GAWVAN4GFNDL342T01C0CX3FCC');
                                                                                           try
                                                                                                mssc.load(mr1.Strings[0],nil);
                                                                                                if NxIsEmptyOID(mssc.GetFieldValueAsString('Location_id')) then m_umisteni:='' else m_umisteni:=mssc.GetFieldValueAsString('Location_id.Code');

                                                                                                   mcelkem:=GetFloatFromTable(xSite,mSQL_Doklad_quantity,ABarCode,mIDs_dDocument);
                                                                                                   mdodano:=GetFloatFromTable(xSite,mSQL_Doklad_delivered,ABarCode,mIDs_dDocument);
                                                                                                   mvychystano:=GetFloatFromTable(xSite,mSQL_Doklad_vychystano,ABarCode,mIDs_dDocument);
                                                                                                   mskladem:=mssc.GetFieldValueAsfloat('Quantity') ;

                                                                                                   mjednotka:=mBO_rows.BusinessObject[i].GetFieldValueAsstring('Qunit')
                                                                                           finally
                                                                                            //mssc.free;
                                                                                           end;
                                                                                       end ;
                                                                                    finally
                                                                                       mr1.free;
                                                                                    end;
                                                                       finally
                                                                           mbo.free;
                                                                       end;
                                                                 end;

                                                            end;
                                                         if not mfind then begin
                                                              NxShowSimpleMessage('Ean není v dokladu čerpatelný',nil);
                                                              nxbeep(btfailure);
                                                              abarcode:='.';
                                                              mStorecard_id:='';
                                                                mstorecard_text:='';
                                                                mdodano:=0 ;
                                                                mvychystano:=0;
                                                                mskladem:=0 ;
                                                                mcelkem:=0;
                                                                m_umisteni:='';
                                                                mBO_Row_id:='';
                                                                mbarcode:='.';
                                                          end else begin
                                                               // NxShowSimpleMessage('Ean je nalezen',nil);

                                                          end;

                                                      end else begin
                                                         NxShowSimpleMessage('Ean skladové karty',nil);

                                                      end;



                                          finally
                                              mr.free;

                                          end;





                                                     if abarcode<>'.' then begin
                                                            if (mix_result=1) or (mix_result=2) then begin

                                                                      if (ABarCode=mBarCode) then begin
                                                                            mpocet:=mpocet+1;
                                                                            if mpocet>=mcelkem+1-mdodano then begin

                                                                                  NxShowSimpleMessage('Max množství pro položku je ' + NxFloatToIBStr(mcelkem-mdodano),nil);
                                                                                  nxbeep(btfailure);
                                                                                  mpocet:=mpocet-1 ;
                                                                            end;
                                                                      end else begin
                                                                            if mBO_Row_id<>'' then begin
                                                                                   //    NxShowSimpleMessage('Zápis' + NxFloatToIBStr(mpocet),nil) ;
                                                                                    if mObject>=0 then begin
                                                                                             mpocet:= mpocet + 1; // mBO_rows.BusinessObject[mObject].getFieldValueAsFloat('Quantity') + mpocet;
                                                                                             mBO_rows.BusinessObject[mObject].SetFieldValueAsFloat('Quantity',mpocet);
                                                                                             //mBO_rows.BusinessObject[mObject].Save;
                                                                                    end;
                                                                            end;
                                                                            mpocet:=0;
                                                                      end;
                                                                result:='A';
                                                                //end;

                                                                end;
                                                        end;
                                       if mix_result=0 then begin

                                                      ABarCode:='' ;
                                                      mBarCode:='' ;
                                                      result:='A';
                                                      exit;
                                       end else begin

                                                        if mObject>=0 then begin
                                                                                             //mpocet:= mpocet + 1; // mBO_rows.BusinessObject[mObject].getFieldValueAsFloat('Quantity') + mpocet;
                                                                                             mBO_rows.BusinessObject[mObject].SetFieldValueAsFloat('Quantity',mpocet);
                                                                                             //mBO_rows.BusinessObject[mObject].Save;
                                                                                    end;//mi_SQL:=xsite.BaseObjectSpace.SQLExecute('update storedocuments2 set x_vychystano=' + NxFloatToIBStr(mpocet) + ' where id=' + QuotedStr(mBO_Row_id));


                                       ABarCode:=mbarcode;
                                       end;
                                  end;    // mbarcode=''
                              end;    // mi result=2


       finally
            ABarCode:=mBarCode;
       end;
            mForm.free;

      end;


             if mObject>=0 then begin
                    mpocet:= mpocet + 1; //mBO_rows.BusinessObject[mObject].getFieldValueAsFloat('Quantity') + mpocet;
                    mBO_rows.BusinessObject[mObject].SetFieldValueAsFloat('Quantity',mpocet);
                    //mBO_rows.BusinessObject[mObject].Save;
             end;
      xSite.Refresh;
      result:='A';

end;

function BarCodeDialog_DL_lokace(xSite:TSiteForm;mBO_head:TNxCustomBusinessObject;mBO_rows:TNxCustomBusinessMonikerCollection;
                       mTop:integer;mLeft:integer;mWith:integer;mHeight:integer;mLabel:string;
                       mTyp_prace:integer;mids:integer; mIDs_dDocument:string;
                       mbutton1,mbutton2,mbutton3,mbutton4:string;
                       Mbutton5:string):string;
var
      mForm : TForm;
      mBtn : TButton;
      mLbl : TLabel;
      mBarCodeEdt,mQuantityEdt,mUnitEdt,mLocEdt : TEdit;
      mQuanEdt,mDelQuanEdt,mStorQuanEdt,mVychQuanEdt:tedit;
      sum_mDelQuanEdt,sum_mStorQuanEdt,sum_mVychQuanEdt:tedit;
      i:integer;
      xresult:Variant;
      //mSCEdt:TRollComboEdit;
      mSCEdt:TEdit;
      ABarCode,mbarcode:string;
      mQuantity:double  ;
      mUnit:string;
      mpocet:double;
      mix_result:integer;
      mBatch_id,mStorecard_id,m_umisteni,mjednotka:string;
      mr,mr1:tstringlist;
      mBO,mSSC,mBO_Row:TNxCustomBusinessObject;
      mStorQuan:double;
      mdodano,mvychystano,mskladem,mcelkem:double;
      SUM_mdodano,SUM_mvychystano,Sum_mskladem,Sum_mcelkem:double;
      mstorecard_text:string;
      mBO_Row_id:string;
      mi_SQL:integer;
      mTypSC:integer;
      mID_Batch,mID_Storecard:string;
      mBatchList,mrBatch:TStringList;
      mMemNote:tmemo;
      mObject:integer;
      mfind:boolean;
      msc_category,xa:integer;
      mlist_batch:tstringlist;
      mBO_Batches:TNxCustomBusinessMonikerCollection;
      mBO_batch:TNxCustomBusinessObject;
begin
      Result := '';
      msc_category:=0;
      i:=1;
      ABarCode := '.';
      mBarCode:='';
      mpocet:=1;
      mStorecard_id:='';
                      mBO_Row_id:='';
                      mstorecard_text:='';
                      mdodano:=0 ;
                      mvychystano:=0;
                      mskladem:=0 ;
                      mcelkem:=0;
                      m_umisteni:='';

                      SUM_mdodano:=0 ;
                      SUM_mvychystano:=0;
                      SUM_mskladem:=0 ;
                      SUM_mcelkem:=0;

                      mjednotka:='';
                      mbarcode:='';
      while ABarCode <> '' do begin
       try

           mForm := TForm.Create(xsite);
          if True then mForm.Color := clBtnFace else mForm.Color:= clRed ;
                                  mForm.Caption := mLabel;mForm.FormStyle := fsStayOnTop;mForm.BorderStyle := bsDialog;
                                  if mTop>=0 then begin
                                    mForm.Top:= mTop;
                                    mForm.Left:= mLeft;
                                  end else begin
                                    mform.Position := poScreenCenter;
                                  end;

                                  mForm.Width := mWith;mForm.Height := mHeight;mForm.Scaled := False;
                                  mBarCodeEdt:=CreateEdit('mBarCodeEdt', 'Čarový kód',mform, 10,10,320,80,150,mBarCode,true,true,true,round(480/24), [fsBold],255) ;
                                  mMemNote := CreateMemo('ChMemNote','Zboží', 10, 80, 320,80, 150, mstorecard_text, mForm,true,true,False,round(480/36), [fsItalic],255);


                                  mLocEdt:=CreateEdit('mLocEdt', 'Umístění',mform, 10,200,320,80,150,m_umisteni,true,true,false,round(480/24), [fsBold],255) ;
                                  mBtn := TButton.Create(mForm);mBtn.Width := 65;mBtn.Height := 70;mBtn.Caption := '-';mBtn.ModalResult := 10;mBtn.Cancel := False;mBtn.Default := false;mBtn.Left:=10;mBtn.Top := 270;mBtn.Name := 'btnIgnore';mForm.InsertControl(mBtn);
                                  mQuantityEdt:=CreateEdit('mQuantityEdt', 'Množství',mForm,80, 270, 120,80,50,NxFloatToIBStr(mpocet),true,true,true,round(480/24),[fsBold],255);
                                  mBtn := TButton.Create(mForm);mBtn.Width := 65;mBtn.Height := 70;mBtn.Caption := '+';mBtn.ModalResult := 20;mBtn.Cancel := False;mBtn.Default := false;mBtn.Left:=260;mBtn.Top := 270;mBtn.Name := 'btnYea';mForm.InsertControl(mBtn);
                                  mUnitEdt:=CreateEdit('mUnitEdt', 'Jedn.',mForm,210, 270, 40,80,50,mjednotka,true,true,false,round(480/48),[fsBold],255);

                                  mcelkem:=GetFloatFromTable(xSite,mSQL_Doklad_quantity,ABarCode,mIDs_dDocument);
                                  mdodano:=GetFloatFromTable(xSite,mSQL_Doklad_delivered,ABarCode,mIDs_dDocument);
                                  mvychystano:=GetFloatFromTable(xSite,mSQL_Doklad_vychystano,ABarCode,mIDs_dDocument);


                                  mQuanEdt:=CreateEdit_noformat('mQuanEdt', 'Celkem',mform, 10,350,70,80,150,NxFloatToIBStr(mcelkem),true,true,false,round(120/10),[fsBold],255) ;
                                  mDelQuanEdt:=CreateEdit_noformat('mDelQuanEdt', 'Dodano',mform, 90,350,70,80,150,NxFloatToIBStr(mdodano + mpocet),true,true,false,round(120/10),[fsBold],255) ;
                                  mStorQuanEdt:=CreateEdit_noformat('mStorQuanEdt', 'Skladem',mform, 170,350,70,80,150,NxFloatToIBStr(mskladem),true,true,false,round(120/10),[fsBold],255) ;
                                  mVychQuanEdt:=CreateEdit_noformat('mVychQuanEdt', 'Vychystano',mform, 270,350,70,80,150,NxFloatToIBStr(mvychystano),true,true,false,round(120/10),[fsBold],255) ;

                                  if msc_category<>0 then begin
                                          if (msc_category<>0) then begin
                                                  mBtn := TButton.Create(mForm);mBtn.Width := 75;mBtn.Height := 40;
                                                  if (msc_category=2) then mBtn.Caption := 'Sériové číslo';
                                                  if (msc_category=3) then mBtn.Caption := 'Šarže';

                                             //     mBtn.ModalResult := 81;mBtn.Cancel := false;mBtn.Left := 10;mBtn.Top := 350;mBtn.Visible:=true;mBtn.Name := 'btnŠarže';mForm.InsertControl(mBtn);
                                          end;
                                  end;
                                 mNUM_button:=4;
                                 mBtn := TButton.Create(mForm);mBtn.Width := trunc(mForm.Height-((mNUM_button+1)*12)/mNUM_button);mBtn.Height := 40;mBtn.Caption := mbutton1;mBtn.ModalResult := 2; mBtn.Cancel := False;mBtn.Default := True;mBtn.Left:=mForm.Width - 2*(mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 40;mBtn.Name := 'btnOK';mForm.InsertControl(mBtn);
                                 mBtn := TButton.Create(mForm);mBtn.Width := trunc(mForm.Height-((mNUM_button+1)*12)/mNUM_button);mBtn.Height := 40;mBtn.Caption := mbutton2;mBtn.ModalResult := 0;mBtn.Cancel := True;mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 40;mBtn.Name := 'btnCancel';mForm.InsertControl(mBtn);
                                 mBtn := TButton.Create(mForm);mBtn.Width := trunc(mForm.Height-((mNUM_button+1)*12)/mNUM_button);mBtn.Height := 40;mBtn.Caption := 'Zápis';mBtn.ModalResult := 1;mBtn.Cancel := False;mBtn.Left := 10;mBtn.Top := mForm.Height - mBtn.Height - 40;mBtn.Name := 'btnyestoall';mForm.InsertControl(mBtn);
                                 mBtn := TButton.Create(mForm);mBtn.Width := trunc(mForm.Height-((mNUM_button+1)*12)/mNUM_button);mBtn.Height := 40;mBtn.Caption := 'Přerušit';mBtn.ModalResult := 99;mBtn.Cancel := False;mBtn.Left := mForm.Width - 3*(mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 40;mBtn.Name := 'btn99';mForm.InsertControl(mBtn);








//                                 mBtn := TButton.Create(mForm);mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := 'OK';mBtn.ModalResult := mrOk; mBtn.Cancel := False;mBtn.Default := True;mBtn.Left:=mForm.Width - 2*(mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 60;mBtn.Name := 'btnOK';mForm.InsertControl(mBtn);
//                                 mBtn := TButton.Create(mForm);mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := 'Storno';mBtn.ModalResult := mrCancel;mBtn.Cancel := True;mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 60;mBtn.Name := 'btnCancel';mForm.InsertControl(mBtn);


                                 mix_result:= mForm.ShowModal(xsite);   // změna položky
                                 //NxShowSimpleMessage(inttostr(mix_result),nil);
                                 if mix_result=10 then
                                      mpocet:=mpocet-1;

                                  if mix_result=20 then begin
                                       mpocet:=mpocet+1;
                                     if mpocet>=mcelkem+1-mdodano then begin
                                         NxShowSimpleMessage('Max množství pro položku je ' + NxFloatToIBStr(mcelkem-mdodano) +
                                         NxFloatToIBStr(mpocet) + ' - ' +NxFloatToIBStr(mcelkem-mdodano)
                                         ,nil);
                                         nxbeep(btfailure);
                                         mpocet:=mcelkem-mdodano ;
                                     end;
                                   end;



                                   if mix_result=1 then begin
                                     if mpocet>0 then begin
                                         mBO_rows.BusinessObject[mObject].SetFieldValueAsFloat('Quantity',mpocet);
                                     end;
                                   end;
                                    if mix_result=99 then begin
                                     if mpocet>0 then begin
                                         mBO_rows.BusinessObject[mObject].SetFieldValueAsFloat('Quantity',mpocet);
                                     end;
                                   end;




                                 if mix_result=81 then begin
                                     mlist_batch:=TStringList.create;
                                         try;
                                             //mBO_batches := mBO_rows.GetLoadedCollectionMonikerForFieldCode(mBO_rows.GetFieldCode('DocRowBatches'));
                                             mlist_batch:=
                                              BarCode_batch(xSite,'05CPMINJW3DL342X01C0CX3FCC',
                                                      0,0,360,480,
                                                      mBO_rows.BusinessObject[i],'Šarže pro: ' + mBO_rows.BusinessObject[i].GetFieldValueAsString('storecard_id.code'),'Ean','Pokračovat','','');

                                             //for xa:=0 to mlist_batch.count-1 do begin
                                             xa:=1;
                                                 mbo_batch := mBO_rows.BusinessObject[i].GetCollectionMonikerForFieldCode(mBO_rows.BusinessObject[i].GetFieldCode('DocRowBatches')).AddNewObject;
                                                  mBO_batch.Prefill;
                                                  mBO_batch.SetFieldValueAsinteger('PosIndex',xa);
                                                  mbo_batch.SetFieldValueAsString('StoreBatch_ID', '6TU1000101');
                                                  mbo_batch.SetFieldValueAsfloat('Quantity',1);
                                                  //mbo_batch.CopyFieldValueFrom(mFinishedProductRowBO, 'QUnit');
                                                  //mbo_batch.CopyFieldValueFrom(mFinishedProductRowBO, 'UnitRate');






                                                 {mbo_batch:=mBO_batches.AddNewObject;
                                                 mBO_batch.Prefill;
                                                 mBO_batch.SetFieldValueAsBoolean('NewBatch',true);
                                                 mBO_batch.SetFieldValueAsString('NewBatchName','AAAA');

                                                 mBO_batch.SetFieldValueAsfloat('Quantity',1);
                                                 mBO_batch.SetFieldValueAsString('StoreBatch_ID','AAAA');
                                                 mBO_batch.SetFieldValueAsString('StoreSubBatch_ID','AAAA');
                                                 //mBO_batch.SetFieldValueAsString('NewBatchName','AAAA');
                                                 //mBO_batch.SetFieldValueAsString('NewBatchName','AAAA');   }
                                             //end;
                                             //NxShowSimpleMessage('Počet šarží ' + inttostr(mlist_batch.count),nil)
                                         finally
                                             mlist_batch.free;
                                         end;
                                 end;


                                 if (mix_result=99) then begin
                                     mbarcode:='';
                                     ABarCode:='';
                                     exit;
                                 end ;


                                 if (mix_result=0) then begin
                                     mbarcode:='';
                                     ABarCode:='';
                                     exit;
                                 end ;

                                 if (mix_result<>0) and (mix_result<>1)  and (mix_result <> 99) and (mix_result<>10) and (mix_result<>20) then begin

                                       mbarcode:=mBarCodeEdt.text;
                                       if mbarcode<>'' then begin
                                                mr:=tstringlist.create;
                                                try
                                                      xsite.BaseObjectSpace.SQLSelect(format(mSQL_SCEAN,[quotedstr(mbarcode)]),mr);
                                                    //end;
                                                      if mr.count>0 then begin
                                                            mObject:=(-1);
                                                            mfind:=false;
                                                            for i:=0 to mBO_rows.Count-1 do begin
                                                                 if (mBO_rows.BusinessObject[i].GetFieldValueAsString('storecard_id')=mr.Strings[0]) then begin
                                                                    mfind:=true;
                                                                    try
                                                                              //mBO_Row:=mBO_rows.BusinessObject[i];
                                                                                    mObject:=i;
                                                                                    mStorecard_id:=mBO_rows.BusinessObject[i].GetFieldValueAsString('storecard_id');
                                                                                    msc_category:=mBO_rows.BusinessObject[i].GetFieldValueAsInteger('storecard_id.category');
                                                                                    mstorecard_text:=mBO_rows.BusinessObject[i].GetFieldValueAsString('storecard_id.name');
                                                                                    mr1:=TStringList.create;
                                                                                    Try
                                                                                       xsite.BaseObjectSpace.SQLSelect('select id from StoreSubCards where StoreCard_ID =' + quotedstr(mStorecard_id) + ' and Store_id=' + quotedstr(mBO_rows.BusinessObject[i].GetFieldValueAsString('store_id')),mr1);

                                                                                       if mr1.Count>0 then begin
                                                                                           mSsc:=xsite.BaseObjectSpace.CreateObject('GAWVAN4GFNDL342T01C0CX3FCC');
                                                                                           try
                                                                                                mssc.load(mr1.Strings[0],nil);
                                                                                                if NxIsEmptyOID(mssc.GetFieldValueAsString('Location_id')) then m_umisteni:='' else m_umisteni:=mssc.GetFieldValueAsString('Location_id.Code');

                                                                                                   mcelkem:=GetFloatFromTable(xSite,mSQL_Doklad_quantity,ABarCode,mIDs_dDocument);
                                                                                                   mdodano:=GetFloatFromTable(xSite,mSQL_Doklad_delivered,ABarCode,mIDs_dDocument);
                                                                                                   mvychystano:=GetFloatFromTable(xSite,mSQL_Doklad_vychystano,ABarCode,mIDs_dDocument);
                                                                                                   mskladem:=mssc.GetFieldValueAsfloat('Quantity') ;

                                                                                                   mjednotka:=mBO_rows.BusinessObject[i].GetFieldValueAsstring('Qunit')
                                                                                           finally
                                                                                            //mssc.free;
                                                                                           end;
                                                                                       end ;
                                                                                    finally
                                                                                       mr1.free;
                                                                                    end;
                                                                       finally
                                                                           mbo.free;
                                                                       end;
                                                                 end;

                                                            end;
                                                         if not mfind then begin
                                                              NxShowSimpleMessage('Ean není v dokladu čerpatelný',nil);
                                                              nxbeep(btfailure);
                                                              abarcode:='.';
                                                              mStorecard_id:='';
                                                                mstorecard_text:='';
                                                                mdodano:=0 ;
                                                                mvychystano:=0;
                                                                mskladem:=0 ;
                                                                mcelkem:=0;
                                                                m_umisteni:='';
                                                                mBO_Row_id:='';
                                                                mbarcode:='.';
                                                          end else begin
                                                               // NxShowSimpleMessage('Ean je nalezen',nil);

                                                          end;

                                                      end else begin
                                                         NxShowSimpleMessage('Ean skladové karty',nil);

                                                      end;



                                          finally
                                              mr.free;

                                          end;





                                                     if abarcode<>'.' then begin
                                                            if (mix_result=1) or (mix_result=2) then begin

                                                                      if (ABarCode=mBarCode) then begin
                                                                            mpocet:=mpocet+1;
                                                                            if mpocet>=mcelkem+1-mdodano then begin

                                                                                  NxShowSimpleMessage('Max množství pro položku je ' + NxFloatToIBStr(mcelkem-mdodano),nil);
                                                                                  nxbeep(btfailure);
                                                                                  mpocet:=mpocet-1 ;
                                                                            end;
                                                                      end else begin
                                                                            if mBO_Row_id<>'' then begin
                                                                                   //    NxShowSimpleMessage('Zápis' + NxFloatToIBStr(mpocet),nil) ;
                                                                                    if mObject>=0 then begin
                                                                                             mpocet:= mpocet + 1; // mBO_rows.BusinessObject[mObject].getFieldValueAsFloat('Quantity') + mpocet;
                                                                                             mBO_rows.BusinessObject[mObject].SetFieldValueAsFloat('Quantity',mpocet);
                                                                                             //mBO_rows.BusinessObject[mObject].Save;
                                                                                    end;
                                                                            end;
                                                                            mpocet:=0;
                                                                      end;
                                                                result:='A';
                                                                //end;

                                                                end;
                                                        end;
                                       if mix_result=0 then begin

                                                      ABarCode:='' ;
                                                      mBarCode:='' ;
                                                      result:='A';
                                                      exit;
                                       end else begin

                                                        if mObject>=0 then begin
                                                                                             //mpocet:= mpocet + 1; // mBO_rows.BusinessObject[mObject].getFieldValueAsFloat('Quantity') + mpocet;
                                                                                             mBO_rows.BusinessObject[mObject].SetFieldValueAsFloat('Quantity',mpocet);
                                                                                             //mBO_rows.BusinessObject[mObject].Save;
                                                                                    end;//mi_SQL:=xsite.BaseObjectSpace.SQLExecute('update storedocuments2 set x_vychystano=' + NxFloatToIBStr(mpocet) + ' where id=' + QuotedStr(mBO_Row_id));


                                       ABarCode:=mbarcode;
                                       end;
                                  end;    // mbarcode=''
                              end;    // mi result=2


       finally
            ABarCode:=mBarCode;
       end;
            mForm.free;

      end;


             if mObject>=0 then begin
                    mpocet:= mpocet + 1; //mBO_rows.BusinessObject[mObject].getFieldValueAsFloat('Quantity') + mpocet;
                    mBO_rows.BusinessObject[mObject].SetFieldValueAsFloat('Quantity',mpocet);
                    //mBO_rows.BusinessObject[mObject].Save;
             end;
      xSite.Refresh;
      result:='A';

end;




function  mDialogForm(xSite:TSiteForm;mLabel:string;mDescription:string;mbuton1:string;mbuton2:string;mbuton3:string;mbuton4:string;mbuton5:string;mbuton6:string;mbuton7:string;mbuton8:string;mbuton9:string;mbuton10:string):Variant;
var
mform:tform;
mBtn : TButton;
mlabel2:TLabel;
begin
            mForm := TForm.Create(xsite);
                                  mForm.Caption := mLabel;
                                  mForm.FormStyle := fsStayOnTop;
                                  mForm.BorderStyle := bsDialog;
                                  mForm.Width := 400;
                                  mForm.Height := 100;
                                  mForm.Scaled := False;
                                  mform.Position := poScreenCenter;

                                  mLabel2 := TLabel.Create(mForm);
                                              mLabel2.Parent := mForm;
                                              mLabel2.Caption := mDescription;
                                              mLabel2.Top := 10;
                                              mLabel2.Left := 10;
                                              mLabel2.Height := 13;


                                if not NxIsBlank(mbuton1) then begin
                                      mBtn := TButton.Create(mForm);
                                      mBtn.Width := 90;
                                      mBtn.Height := 25;
                                      mBtn.Caption := mbuton1;
                                      mBtn.ModalResult := 1;
                                      mBtn.Cancel := False;
                                      mBtn.Default := True;
                                      mBtn.Left :=  mForm.Width - (4*(mBtn.Width+2)) - 20;
                                      mBtn.Top := mForm.Height - mBtn.Height - 40;
                                      mBtn.Name := 'mbuton1';
                                      mForm.InsertControl(mBtn);
                                end;

                                if not NxIsBlank(mbuton2) then begin
                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := 90;
                                    mBtn.Height := 25;
                                    mBtn.Caption := mbuton2;
                                    mBtn.ModalResult := 2;
                                    mBtn.Cancel := False;
                                    mBtn.Default := False;
                                    mBtn.Left :=  mForm.Width - 3*(mBtn.Width+2) - 20;
                                    mBtn.Top := mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'mbuton2';
                                    mForm.InsertControl(mBtn);
                                end;

                                if not NxIsBlank(mbuton3) then begin
                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := 90;
                                    mBtn.Height := 25;
                                    mBtn.Caption := mbuton3;
                                    mBtn.ModalResult := 3;
                                    mBtn.Cancel := False;
                                    mBtn.Default := False;
                                    mBtn.Left :=  mForm.Width - 2*(mBtn.Width+2) - 20;
                                    mBtn.Top := mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'mbuton3';
                                    mForm.InsertControl(mBtn);
                                    end;
                                if not NxIsBlank(mbuton4) then begin
                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := 90;
                                    mBtn.Height := 25;
                                    mBtn.Caption := mbuton4;
                                    mBtn.ModalResult := 4;
                                    mBtn.Cancel := False;
                                    mBtn.Default := False;
                                    mBtn.Left :=  mForm.Width - 2*(mBtn.Width+2) - 20;
                                    mBtn.Top := mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'mbuton4';
                                    mForm.InsertControl(mBtn);
                                    end;

                                if not NxIsBlank(mbuton5) then begin
                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := 90;
                                    mBtn.Height := 25;
                                    mBtn.Caption := mbuton5;
                                    mBtn.ModalResult := 5;
                                    mBtn.Cancel := False;
                                    mBtn.Default := False;
                                    mBtn.Left :=  mForm.Width - 2*(mBtn.Width+2) - 20;
                                    mBtn.Top := mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'mbuton5';
                                    mForm.InsertControl(mBtn);
                                    end;
                                if not NxIsBlank(mbuton6) then begin
                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := 90;
                                    mBtn.Height := 25;
                                    mBtn.Caption := mbuton6;
                                    mBtn.ModalResult := 6;
                                    mBtn.Cancel := False;
                                    mBtn.Default := False;
                                    mBtn.Left :=  mForm.Width - 2*(mBtn.Width+2) - 20;
                                    mBtn.Top := mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'mbuton6';
                                    mForm.InsertControl(mBtn);
                                    end;
                                if not NxIsBlank(mbuton7) then begin
                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := 90;
                                    mBtn.Height := 25;
                                    mBtn.Caption := mbuton7;
                                    mBtn.ModalResult := 7;
                                    mBtn.Cancel := False;
                                    mBtn.Default := False;
                                    mBtn.Left :=  mForm.Width - 2*(mBtn.Width+2) - 20;
                                    mBtn.Top := mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'mbuton7';
                                    mForm.InsertControl(mBtn);
                                    end;
                                if not NxIsBlank(mbuton8) then begin
                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := 90;
                                    mBtn.Height := 25;
                                    mBtn.Caption := mbuton8;
                                    mBtn.ModalResult := 8;
                                    mBtn.Cancel := False;
                                    mBtn.Default := False;
                                    mBtn.Left :=  mForm.Width - 2*(mBtn.Width+2) - 20;
                                    mBtn.Top := mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'mbuton8';
                                    mForm.InsertControl(mBtn);
                                    end;
                                if not NxIsBlank(mbuton9) then begin
                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := 90;
                                    mBtn.Height := 25;
                                    mBtn.Caption := mbuton9;
                                    mBtn.ModalResult := 9;
                                    mBtn.Cancel := False;
                                    mBtn.Default := False;
                                    mBtn.Left :=  mForm.Width - 2*(mBtn.Width+2) - 20;
                                    mBtn.Top := mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'mbuton9';
                                    mForm.InsertControl(mBtn);
                                    end;

                                if not NxIsBlank(mbuton10) then begin
                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := 90;
                                    mBtn.Height := 25;
                                    mBtn.Caption := mbuton10;
                                    mBtn.ModalResult := 10;
                                    mBtn.Cancel := True;
                                    mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;;
                                    mBtn.Top := mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'btn10';
                                    mForm.InsertControl(mBtn);

                                end;

                                result:=mForm.ShowModal(xSite)



end;




begin
end.