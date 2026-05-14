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



function GetFirmID_TOP(os:TNxCustomObjectSpace;msite:TSiteForm;mCode:string;mNAme:string;mUlice1:string;mMesto:string;mPSC:string;mICO:string;mkont_tel1:string;mkont_tel2:string;mKont_os1:string;mKont_os2:string;mKont_mail:string;index:integer):string;
var
mresult:boolean;
mForm : TForm;
mfirm:TNxCustomBusinessObject;
  mBtn : TButton;
  mLbl,mLbl1,mLbl2,mLbl3,mLbl4,mLbl5 : TLabel;
  EdtsIC,mEdtIC, mEdtDIC,mEdtName,EdtsName,mEdtStreet,EdtSstreet,mEdtCity,EdtSCity,mEdtPostCode,EdtSPostCode,mEdtCountry,EdtSCountry : TEdit;
  medtSemail,medtSKont_os1,medtSKont_os2,medtSKont_tel1,medtSKont_tel2 : TEdit;
  mI_modalresult:integer;
  mra:tstringlist;
  mFirm_ID:string;
begin
// odberatel

            if index=0 then begin
              mForm := TForm.Create(nil);
              try
                    mForm.Width := 400;  // sirka
                    mForm.Height := 500; // vyska - dopočítívá se na závěr
                    mForm.Caption := 'Kontrola adres';

                    mLbl := TLabel.Create(mForm);
                    mLbl.Caption := 'Údaj'  ;
                    mLbl.Left := 20;
                    mLbl.Top := 20;
                    mLbl.Name := 'lblPopis';
                    mForm.InsertControl(mLbl);

                    mLbl := TLabel.Create(mForm);
                    mLbl.Caption := 'IČ'  ;
                    mLbl.Left := 20;
                    mLbl.Top := 50;
                    mLbl.Name := 'lblIco';
                    mForm.InsertControl(mLbl);

                    //mLbl := TLabel.Create(mForm);
                    //mLbl.Caption := 'DIČ:'  ;
                    //mLbl.Left := 20;
                    //mLbl.Top := 80;
                    //mLbl.Name := 'lblDIC';
                    //mForm.InsertControl(mLbl);

                    mLbl := TLabel.Create(mForm);
                    mLbl.Caption := 'Název:'  ;
                    mLbl.Left := 20;
                    mLbl.Top := 110;
                    mLbl.Name := 'lblName';
                    mForm.InsertControl(mLbl);


                    mLbl := TLabel.Create(mForm);
                    mLbl.Caption := 'Ulice:'  ;
                    mLbl.Left := 20;
                    mLbl.Top := 140;
                    mLbl.Name := 'lblSTreet';
                    mForm.InsertControl(mLbl);

                    mLbl := TLabel.Create(mForm);
                    mLbl.Caption := 'Město:'  ;
                    mLbl.Left := 20;
                    mLbl.Top := 170;
                    mLbl.Name := 'lblCity';
                    mForm.InsertControl(mLbl);

                    mLbl := TLabel.Create(mForm);
                    mLbl.Caption := 'PSČ'  ;
                    mLbl.Left := 20;
                    mLbl.Top := 200;
                    mLbl.Name := 'lblPostcode';
                    mForm.InsertControl(mLbl);

                    mLbl1 := TLabel.Create(mForm);
                    mLbl1.Caption := 'Osoba 1:'  ;
                    mLbl1.Left := 20;
                    mLbl1.Top := 230;
                    mLbl1.Name := 'lbl1';
                    mForm.InsertControl(mLbl1);

                    mLbl2 := TLabel.Create(mForm);
                    mLbl2.Caption := 'Osoba 2:'  ;
                    mLbl2.Left := 20;
                    mLbl2.Top := 260;
                    mLbl2.Name := 'lbl2';
                    mForm.InsertControl(mLbl2);

                    mLbl3 := TLabel.Create(mForm);
                    mLbl3.Caption := 'Telefon :'  ;
                    mLbl3.Left := 20;
                    mLbl3.Top := 290;
                    mLbl3.Name := 'lbl3';
                    mForm.InsertControl(mLbl3);

                    mLbl4 := TLabel.Create(mForm);
                    mLbl4.Caption := 'Telefon :'  ;
                    mLbl4.Left := 20;
                    mLbl4.Top := 320;
                    mLbl4.Name := 'lbl4';
                    mForm.InsertControl(mLbl4);

                    mLbl5 := TLabel.Create(mForm);
                    mLbl5.Caption := 'Email :'  ;
                    mLbl5.Left := 20;
                    mLbl5.Top := 350;
                    mLbl5.Name := 'lbl5';
                    mForm.InsertControl(mLbl5);

                    mLbl := TLabel.Create(mForm);
                    mLbl.Caption := 'Import:'  ;
                    mLbl.Left := 80;
                    mLbl.Top := 20;
                    mLbl.Name := 'lblImp_popis';
                    mForm.InsertControl(mLbl);

                    mEdtIC := TEdit.Create(mForm);
                    mEdtIC.Left := 80;
                    mEdtIC.Top := 50;
                    mEdtIC.Width := 100;
                    mEdtIc.Name := 'edtSIC';
                    if mico='' then mEdtIc.Text := '' else mEdtIc.Text  := mico;
                    mEdtIc.Name := 'edtSIC';
                    mForm.InsertControl(mEdtIc);

                    //mEdtDIC := TEdit.Create(mForm);
                    //mEdtDIC.Left := 80;
                    //mEdtDIC.Top := 80;
                    //mEdtDIC.Width := 100;
                    //mEdtDIC.Text  := mdi;
                    //mEdtDIc.Name := 'edtSDIC';
                    //mForm.InsertControl(mEdtDIc);

                    mEdtName := TEdit.Create(mForm);
                    mEdtName.Left := 80;
                    mEdtName.Top := 110;
                    mEdtName.Width := 250;
                    mEdtName.Name := 'edtSName';
                    if mname='' then mEdtName.Text := '' else mEdtName.Text := mName;
                    mForm.InsertControl(mEdtName);


                    mEdtStreet:= TEdit.Create(mForm);
                    mEdtStreet.Left := 80;
                    mEdtStreet.Top := 140;
                    mEdtStreet.Width := 250;
                    mEdtStreet.Name := 'edtSStreet';
                    if mUlice1='' then mEdtStreet.text := '' else mEdtStreet.Text := mUlice1;
                    mForm.InsertControl(mEdtStreet);


                    mEdtCity := TEdit.Create(mForm);
                    mEdtCity.Left := 80;
                    mEdtCity.Top := 170;
                    mEdtCity.Width := 250;
                    mEdtCity.Name := 'edtSCity';
                    if mMesto='' then mEdtCity.text := '' else mEdtCity.Text := mMesto;
                    mForm.InsertControl(mEdtCity);

                    mEdtPostCode := TEdit.Create(mForm);
                    mEdtPostCode.Left := 80;
                    mEdtPostCode.Top := 200;
                    mEdtPostCode.Width := 100;
                    mEdtPostCode.Name := 'edtSPostcode';
                    if mPSC='' then mEdtPostCode.text := '' else mEdtPostCode.Text := mPSC;
                    mForm.InsertControl(mEdtPostCode);

                    medtSKont_os1 := TEdit.Create(mForm);
                    medtSKont_os1.Left := 80;
                    medtSKont_os1.Top := 230;
                    medtSKont_os1.Width := 100;
                    medtSKont_os1.Name := 'edtSKont_os1';
                    if mKont_os1='' then medtSKont_os1.text := '' else medtSKont_os1.Text := mKont_os1;
                    mForm.InsertControl(medtSKont_os1);

                    medtSKont_os2 := TEdit.Create(mForm);
                    medtSKont_os2.Left := 80;
                    medtSKont_os2.Top := 260;
                    medtSKont_os2.Width := 100;
                    medtSKont_os2.Text := mKont_os2;
                    medtSKont_os2.Name := 'edtSKont_os2';
                    if mKont_os2='' then medtSKont_os2.text := '' else medtSKont_os2.Text := mKont_os2;
                    mForm.InsertControl(medtSKont_os2);

                    medtSkont_tel1 := TEdit.Create(mForm);
                    medtSkont_tel1.Left := 80;
                    medtSkont_tel1.Top := 290;
                    medtSkont_tel1.Width := 100;
                    medtSkont_tel1.Text := mkont_tel1;
                    medtSkont_tel1.Name := 'edtSkont_tel1';
                    if mkont_tel1='' then medtSkont_tel1.text := '' else medtSkont_tel1.Text := mkont_tel1;
                    mForm.InsertControl(medtSkont_tel1);

                    medtSkont_tel2 := TEdit.Create(mForm);
                    medtSkont_tel2.Left := 80;
                    medtSkont_tel2.Top := 320;
                    medtSkont_tel2.Width := 100;
                    medtSkont_tel2.Text := mkont_tel2;
                    medtSkont_tel2.Name := 'edtSkont_tel2';
                    if mkont_tel2='' then medtSkont_tel2.text := '' else medtSkont_tel2.Text := mkont_tel2;
                    mForm.InsertControl(medtSkont_tel2);

                    medtSemail := TEdit.Create(mForm);
                    medtSemail.Left := 80;
                    medtSemail.Top := 350;
                    medtSemail.Width := 100;
                    medtSemail.Name := 'edtSemail';
                    if mKont_mail='' then medtSemail.text := '' else medtSemail.Text := mKont_mail;
                    mForm.InsertControl(medtSemail);



                    mBtn := TButton.Create(mForm);
                    mBtn.Width := 75;
                    mBtn.Height := 25;
                    mBtn.Caption := 'Založit nový';
                    mBtn.Left := 120;
                    mBtn.Top := mForm.Height - mBtn.Height - 60;
                    mBtn.Visible := True;
                    mBtn.ModalResult := mrYes;
                    mBtn.Default := True;
                    mBtn.Cancel := False;
                    mBtn.Name := 'btnyes';
                    mForm.InsertControl(mBtn);

                    mBtn := TButton.Create(mForm);
                    mBtn.Width := 75;
                    mBtn.Height := 25;
                    mBtn.Caption := 'Zrušit';
                    mBtn.Left := 220;
                    mBtn.Top := mForm.Height - mBtn.Height - 60;
                    mBtn.Visible := True;
                    mBtn.ModalResult := mrCancel;
                    mBtn.Cancel := True;
                    mBtn.Name := 'btnCancel';
                    mForm.InsertControl(mBtn);

                    mI_modalresult:=mForm.ShowModal(msite) ;



              if mI_modalresult=mrOk then begin                  // použit
                 mresult:=InputQuery('Potvrzení', 'Zadaná adresa bude založena, jste si jisti','');
                      if mresult then begin
                             result:=mfirm.oid;
                             ShowMessage('Dohledaná adresa byla založena');
                      end else begin
                             result:='';
                             exit;
                      end;
                 //ShowMessage(inttostr(mI_modalresult));
              end;
               if mI_modalresult=mrYes then begin                 // založ
                   if index=0 then begin
                             mfirm:= OS.CreateObject('MAQQH2FVJOTO1EMQZHDTY0CWOW');
                            try
                                mFirm.New;
                                mFirm.Prefill;
                                mFirm.SetFieldValueAsString('Code', medtIC.text);
                                mFirm.SetFieldValueAsString('Name', medtName.text);
                                mFirm.SetFieldValueAsString('U_ulice1',medtStreet.text);
                                mFirm.SetFieldValueAsString('U_mesto',medtCity.text);
                                mFirm.SetFieldValueAsString('U_psc',medtPostcode.text);
                                mFirm.SetFieldValueAsString('U_ico',medtIC.Text);
                                mFirm.SetFieldValueAsString('U_kont_tel1',mkont_tel1);
                                mFirm.SetFieldValueAsString('U_kont_tel2',mkont_tel2);
                                mFirm.SetFieldValueAsString('U_kont_os1',mKont_os1);
                                mFirm.SetFieldValueAsString('U_kont_os2',mKont_os2);
                                mFirm.SetFieldValueAsString('U_kont_mail',mKont_mail);
                                mfirm.Save;
                                result:=mfirm.oid;
                             //mhead.SetFieldValueAsString('Firm_ID',mfirm.oid);
                            finally
                                mfirm.Free;
                            end;
                            //ShowMessage(inttostr(mI_modalresult));
                    end;

              end;
              if mI_modalresult=mrCancel then begin              // zruš přenos
                 ShowMessage('Import adresy byl uživatelsky přerušen');
                 exit;
              end;

            finally
              mForm.Free;
              end;

         end;


         if index=1 then begin
                             mra:=TStringList.create;
                                  try
                                       os.SQLSelect('select id from firms where OrgIdentNumber =' + QuotedStr(medtIC.text) + ' and hidden=' + QuotedStr('N') + ' and Firm_ID is null' ,mra);
                                       if mra.count>0 then begin
                                             result:=mra.Strings[0];
                                       end else begin
                                             result:='';
                                             NxShowSimpleMessage('Firma s IČ : ' + QuotedStr(medtIC.text) + ' a názvem ' + QuotedStr(medtName.text) + ' neexistuje, prosím založte ji a uložte do SP',nil);

                                       end;

                                  finally
                                     mra.free;
                                  end;
                            { mfirm:= OS.CreateObject('4K3EXM5PQBCL35CH000ILPWJF4');
                            try
                                mFirm.New;
                                mFirm.Prefill;
                                mFirm.SetFieldValueAsString('OrgIdentNumber',medtIC.text);
                                mFirm.SetFieldValueAsString('Code', medtIC.text);
                                mFirm.SetFieldValueAsString('Name', medtName.text);
                                mFirm.SetFieldValueAsString('ResidenceAddress_ID.Street',medtStreet.text);
                                mFirm.SetFieldValueAsString('ResidenceAddress_ID.City',medtCity.text);
                                mFirm.SetFieldValueAsString('ResidenceAddress_ID.U_psc',medtPostcode.text);
                                //mFirm.SetFieldValueAsString('VATIdentNumber',mdi);

                                mFirm.SetFieldValueAsString('ResidenceAddress_ID.PhoneNumber1',mkont_tel1);
                                mFirm.SetFieldValueAsString('ResidenceAddress_ID.PhoneNumber2',mkont_tel2);
                                mFirm.SetFieldValueAsString('ResidenceAddress_ID.Recipient',mKont_os1);
                                mFirm.SetFieldValueAsString('ResidenceAddress_ID.Location',mKont_os2);
                                mFirm.SetFieldValueAsString('ResidenceAddress_ID.EMail',mKont_mail);
                                mfirm.Save;
                                result:=mfirm.oid;
                                NxShowSimpleMessage('Záznam byl přidán do adresáře, prosím zkontrolujte správnost pomocí ARES.',nil)
                             //mhead.SetFieldValueAsString('Firm_ID',mfirm.oid);
                            finally
                                mfirm.Free;
                            end;
                            //ShowMessage(inttostr(mI_modalresult));      }
                    end;






end;

  function CheckPayerFirms(mbo:TNxCustomBusinessObject;msite:TSiteForm;index:integer):boolean;
var
    mfieldValue,mr:TStringList;
    mParameters : TNxParameters;
    mid:string;
    mCode,mname,mUlice,mdic,mMesto,mPSC,mICO,mmobil,mtel,mKont_os1,memail,mFax:string;
begin
    mr:=TStringList.Create;
    try
       mbo.ObjectSpace.SQLSelect('select id from firms where id=' + quotedstr(mbo.GetFieldValueAsString('Payerfirm_ID')) + ' and hidden=''N'' and Firm_id is null',mr);
          if mr.count>0 then begin
                NxShowSimpleMessage('Dohledána',nil);
                mid:=mr.Strings[0] ;
          end ;

    finally
        mr.free;
    end;

    mr:=TStringList.Create;
    try
       mbo.ObjectSpace.SQLSelect('select id from firms where id=' + quotedstr(mbo.GetFieldValueAsString('Payerfirm_ID')) + ' and hidden=''A'' and Firm_id is null',mr);
          if mr.count>0 then begin
              NxShowSimpleMessage('Skrytá firma',nil);
              mid:=mr.Strings[0] ;;
          end ;

    finally
        mr.free;
    end;

    mr:=TStringList.Create;
    try
       mbo.ObjectSpace.SQLSelect('select Firm_ID from firms where id=' + quotedstr(mbo.GetFieldValueAsString('Payerfirm_ID')) + ' and Firm_id is not null',mr);
          if mr.count>0 then begin
              mid:=mr.Strings[0] ;;
          end ;

    finally
        mr.free;
    end;
    if mid<>'' then begin
       if mid <> mbo.getFieldValueAsString('Firm_ID') then mbo.SetFieldValueAsString('Firm_ID',mid);
       if mid <> mbo.getFieldValueAsString('PayerFirm_ID') then mbo.SetFieldValueAsString('payerFirm_ID',mid);
       mbo.save;
    end;




end;






function CheckFirms(mbo:TNxCustomBusinessObject;msite:TSiteForm;index:integer):boolean;
var
    mfieldValue,mr:TStringList;
    mParameters : TNxParameters;
    mid:string;
    mCode,mname,mUlice,mdic,mMesto,mPSC,mICO,mmobil,mtel,mKont_os1,memail,mFax:string;
begin
    mfieldValue:= TStringList.Create;
    try
        if not (nxisblank(mbo.GetFieldValueAsString('U_Platce_OD')) or (mbo.GetFieldValueAsString('U_Platce_OD')=';;;;;;;;;')) then begin

             Parsevalue(mParameters, mbo.GetFieldValueAsString('U_Platce_OD'),';',mbo.GetFieldValueAsString('U_Platce_OD'),mfieldValue,10);
                      mID:='';
                      mICO:=' ';
                      mdic:=' ';
                      mname:=' ';
                      mulice:=' ';
                      mmesto:=' ';
                      mpsc:=' ';
                      mtel:=' ';
                      memail:=' ';
                      mmobil:=' ';
                      mfax:=' ';


                      mICO:=mfieldValue.Strings[0];
                      mdic:=mfieldValue.Strings[1];

                      mname:=mfieldValue.Strings[2];
                      mulice:=mfieldValue.Strings[3];
                      mmesto:=mfieldValue.Strings[4];
                      mpsc:=mfieldValue.Strings[5];
                      mtel:=mfieldValue.Strings[6];
                      memail:=mfieldValue.Strings[7];
                      mmobil:=mfieldValue.Strings[8];
                      mfax:=mfieldValue.Strings[9];
                                mr:=TStringList.create;
                                try

                                    msite.BaseObjectSpace.SQLSelect('SELECT A.ID FROM Firms A WHERE NAme ='+ quotedstr(mName) + ' and hidden=' + QuotedStr('N') + ' and firm_ID is null' ,mr);
                                          if mr.count>0 then begin
                                              NxShowSimpleMessage('Firma s názvem ' + quotedstr(mName) + ' již existuje',nil);
                                              mID:=mr.Strings[0];

                                              if not NxIsEmptyOID(mid) then begin
                                                 mbo.SetFieldValueAsString('Firm_ID',mid); // použití nové firmy
                                                 mbo.SetFieldValueAsString('PayerFirm_ID',mid); // použití nové firmy
                                                 mbo.Save;
                                              end;

                                          end else begin
                                              NxShowSimpleMessage('Firma s IČ : ' + QuotedStr(mICO) + ' a názvem ' + QuotedStr(mname) + ' neexistuje, prosím založte ji a uložte do SP',nil);
                                              //mid:=GetFirmID_TOP(msite.BaseObjectSpace,msite,mCode,mNAme,mUlice,mMesto,mPSC,mICO,mmobil,mtel
                                              //      ,mfax,mICO,memail,index);
                                              //      if not NxIsEmptyOID(mid) then begin
                                              //         mbo.SetFieldValueAsString('Firm_ID',mid); // použití nové firmy
                                              //         mbo.SetFieldValueAsString('PayerFirm_ID',mid); // použití nové firmy
                                              //         mbo.Save;
                                              //      end;
                                          end;
                                finally
                                    mr.free;
                                end;
         end;
                             // mfieldfield.Strings[pozice]
    finally
        mfieldValue.free;
    end;

     mbo.Refresh;
     msite.Refresh;
//     msite.
//     ActiveDataSet.seekid(mbo.oid);



end;











    function CheckAdrees(mbo:TNxCustomBusinessObject;msite:TSiteForm;index:integer):boolean;
    var
    mfieldValue,mr:TStringList;
    mParameters : TNxParameters;
    mid:string;
    mCode,mname,mUlice,mdic,mMesto,mPSC,mICO,mmobil,mtel,mKont_os1,memail,mFax:string;
    _ss:Variant;
    i:integer;
    begin
    mfieldValue:= TStringList.Create;
    try
        if not (nxisblank(mbo.GetFieldValueAsString('U_Umisteni_OD')) or (mbo.GetFieldValueAsString('U_Umisteni_OD')=';;;;;;;;;')) then begin

             Parsevalue(mParameters, mbo.GetFieldValueAsString('U_Umisteni_OD'),';',mbo.GetFieldValueAsString('U_Umisteni_OD'),mfieldValue,10);
        mICO:=' ';
        mdic:=' ';
        mname:=' ';
        mulice:=' ';
        mmesto:=' ';
        mpsc:=' ';
        mtel:=' ';
        memail:=' ';
        mmobil:=' ';
        mfax:=' ';


        mICO:=mfieldValue.Strings[0];
        mdic:=mfieldValue.Strings[1];

        mname:=mfieldValue.Strings[2];
        mulice:=mfieldValue.Strings[3];
        mmesto:=mfieldValue.Strings[4];
        mpsc:=mfieldValue.Strings[5];
        mtel:=mfieldValue.Strings[6];
        memail:=mfieldValue.Strings[7];
        mmobil:=mfieldValue.Strings[8];
        mfax:=mfieldValue.Strings[9];
          mr:=TStringList.create;
          try

              msite.BaseObjectSpace.SQLSelect('SELECT A.ID FROM DefRollData A WHERE A.CLSID = ' + quotedstr('MAQQH2FVJOTO1EMQZHDTY0CWOW') +
                            ' and (exists (SELECT 1 FROM USERDATA WHERE FIELDCODE=2000001 AND CLSID=' + quotedstr('MAQQH2FVJOTO1EMQZHDTY0CWOW') +
                            ' AND ID = A.ID AND (STRINGFIELDVALUE ='+ quotedstr(mulice)+')))'+
                            ' and (exists (SELECT 1 FROM USERDATA WHERE FIELDCODE=2000002 AND CLSID=' + quotedstr('MAQQH2FVJOTO1EMQZHDTY0CWOW') +
                            ' AND ID = A.ID AND (STRINGFIELDVALUE ='+ quotedstr(mmesto)+')))'+
                            '',mr);
                    if mr.count>0 then begin
                        if mr.count=1 then begin
                             mID:=mr.Strings[0];
                        end else begin
                            NxShowSimpleMessage('Adresa již existuje' + inttostr(mr.count),nil);
                            mOLE := GetAbraOLEApplication;
                            mroll := mOLE.GetAgenda('LYTNYJI2TZJ41HQGZPE1M5IK5G');
                            _ss := mOLE.CreateStrings;
                            for i := 0 to mr.Count - 1 do begin
                                _ss.Add(mr.Strings[i]);
                            end;
                              NxShowSimpleMessage('mr' + mr.Strings[0],nil);
                              NxShowSimpleMessage('_SS' + _SS.strings[0],nil);
                               mID := mroll.SingleSelectFromSelected2(_ss, '`Doplneni adresy', mr.Strings[0]);
                                NxShowSimpleMessage('ID' + mid,nil);
                                //mOLE := GetAbraOLEApplication;
                                //mRoll := mOLE.NxGetRoll('BTYHA5DHLTDO14H21XNZM2CPIK',0);
                                //mID := mRoll.SingleSelectFromSelected2(mr, 'Dohledani adresy', mr);
                                //mID := mRoll.SingleSelect2('QueryByUserDynSQLCondition;A.ID=' + QuotedSTr(mr.Strings[0]) + ';xxx','aaa' )  ;
                                //mID:=iSelectZakaznik(msite.GetAbraOLEApplication);

                                //if not NxIsEmptyOID(mResOID) then
                                //Result := mResOID;
                               // msite.ShowSite('LYTNYJI2TZJ41HQGZPE1M5IK5G',true,'FilterByUserDynsqlCondition;a.id='+Quotedstr(mr.strings[0])+';Omezeni');
                          end;










                        if not NxIsEmptyOID(mid) then begin
                           mbo.SetFieldValueAsString('X_ID_zakaznika_ID',mid); // použití nové adresy servisu
                           mbo.Save;
                        end;

                    end else begin
                        NxShowSimpleMessage('Adresa ještě neexistuje',nil);
                        mid:=GetFirmID_TOP(msite.BaseObjectSpace,msite,mCode,mNAme,mUlice,mMesto,mPSC,mICO,mmobil,mtel
                              ,mfax,mICO,memail,index);
                             if not NxIsEmptyOID(mid) then begin
                                 mbo.SetFieldValueAsString('X_ID_zakaznika_ID',mid); // použití nové adresy servisu
                                 mbo.Save;
                              end;
                    end;
          finally
              mr.free;
          end;

        end;
       // mfieldfield.Strings[pozice]
    finally
        mfieldValue.free;
    end;
    end;


    function iSelectZakaznik(AOLE: Variant) : TNxOID;
var
  mRoll4 : variant;
  mXX4 : string;
begin
  Result := '';
  mXX4 := '3QF3000101';
  mRoll4 := AOLE.GetRoll('BTYHA5DHLTDO14H21XNZM2CPIK', 0);
  Result := mRoll4.SelectDialog2(False, mXX4);
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
   mlist:TStringList;
   mfirm_ID,mPayerFirm_ID:string;
   mI_adres:integer;
   mS_Adress_OLD:string;
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
                  if index=0 then mresult:=CheckAdrees(mbo,msite,index);
                  if index=1 then mresult:=CheckFirms(mbo,msite,index);
                  if index=3 then mresult:=CheckPayerFirms(mbo,msite,index);
        end else begin
            for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
                    mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                    mBO := TBusRollSiteForm(mSite).CurrentObject;
                       if index=0 then mresult:=CheckAdrees(mbo,msite,index);
                       if index=1 then mresult:=CheckFirms(mbo,msite,index);
                       if index=3 then mresult:=CheckPayerFirms(mbo,msite,index);
            end;
        end;
TBusRollSiteForm(mSite).CurrentObject.Refresh  ;
TBusRollSiteForm(mSite).RefreshData;
mDBGrid.Refresh;

//     msite.ActiveDataSet.seekid(mbo.oid);
//     msite.ActiveDataSet.RefreshAndRestoreLastSelectedItem;
end;

procedure InitSite_Hook(Self: TSiteForm);
var
mAction: TAction;
  mMAction: TMultiAction;
  mUserFilter: Boolean;
  mUser: TNxCustomBusinessObject;
begin

     mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Akceptace adresy';
  mMAction.Hint := 'Akceptace adresy';
  mMAction.Category := 'tabList';
  mMAction.OnExecuteItem := @SloucitExecuteItem;
  mMAction.Items.Add('Umístění (servis)');
  mMAction.Items.Add('Plátce (abra)');
  mMAction.Items.Add('');
  mMAction.Items.Add('Kontrola fakturačních adres');


end;


procedure Parsevalue(AStru : TNxParameters; const ADescription : string; const ASeparator: string; const AData : string; AHead:TStringList;sloupcu:integer);
// rozdělení hodnot pro import
var
    mStr, mToken : string;
    mPos, i : integer;
    mLbl : TLabel;
  mEdtIC, mEdtDIC,mEdtName,mEdtStreet,mEdtCity,mEdtPostCode,mEdtCountry : TEdit;
begin
    mStr := AData;
    try
        for i := 0 to sloupcu - 1 do begin
            mPos := AnsiPos(ASeparator, mStr);
            if mPos = 0 then mPos := Length(mStr) + 1;
                AHead.Add(NxLeft(mStr, mPos - 1));
                mStr := copy(mStr, mPos + 1, Length(mStr) - mPos);
            end;
        finally
  end;
end;


begin
end.