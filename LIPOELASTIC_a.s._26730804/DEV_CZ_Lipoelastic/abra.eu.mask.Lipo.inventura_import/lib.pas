 Var
mTyp_obchodu:string;
  mXMLHead : TNxScriptingXMLWrapper;
  mSite : TSiteForm;
  mDoklad : string;
  i,ii : integer;
  mres,mres1,mr2: TStringList;
  mID: String;
  aaaaa: string;
  x:integer;
  aa:Double;
  mrResult:string;
  mfirm,mfirm_office: TNxCustomBusinessObject;
  mrow: TNxCustomBusinessObject;
  mbusorder: TNxCustomBusinessObject;
  maddress: TNxCustomBusinessObject;
  mBO_SP: TNxCustomBusinessObject;
  mID_Store,mID_StoreCard,mIDdoklad,mID_odberatel, mID_dodavatel, mID_Docqueue, mID_BusOrder,mID_Division, mID_VatCountry,mID_Country, mID_Currency,mID_Vatrate,mID_Row: string;
  aresult:Boolean;
  mexistuje:string;
  oprava : boolean;
  mMon : TNxCustomBusinessMonikerCollection;
   mForm : TForm;
  mBtn : TButton;
  mLbl : TLabel;
  mEdtIC, mEdtDIC,mEdtName,mEdtStreet,mEdtCity,mEdtPostCode,mEdtCountry : TEdit;
  cbSrcUnits, cbDstUnits, cbStores, cbDivisions : TEdit;
  mP1, mP2, mP3 : TPanel;
  mI_modalresult:integer;
  mS_code:string;
  mList,mRowList:TStringList;
  mtext:string;
  mID_kost_symbol,mID_payment,mID_delivery:string;
  mCountryName:string;
  mtoESL:boolean;
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




function getIDfromfieldDF(os:TNxCustomObjectSpace;R_polozka:string;table:string;Polozka1:string;value1: String;Polozka2:string;value2:String;Polozka3:string;value3:string):String;
var
    mR : TStrings;
const
    cSQL2 = 'SELECT %s FROM %s WHERE %s=''%s'' AND %s=''%s''';
begin
    Result := '';
    mR := TStringList.Create;
    try
       if nxisblank(Polozka2) then begin
            os.SQLSelect(Format('SELECT %s FROM %s WHERE %s=''%s''', [r_polozka,table,polozka1,value1]), mR);
       end else begin
            os.SQLSelect(Format('SELECT %s FROM %s WHERE %s=''%s'' AND %s=''%s'' AND %s=''%s''', [r_polozka,table,polozka1,value1,polozka2,value2,polozka3,value3]), mR);
       end;
        if mR.Count > 0 then begin
            Result := mR.Strings[0];
        end else begin
            Result:='';
        end;
    finally
        mR.Free;
    end;
end;



function CheckAdrees(msite:TSiteForm;mXMLHead:TNxScriptingXMLWrapper;i:integer;mbo_sp:TNxCustomBusinessObject):string;
    var
    mfieldValue,mr:TStringList;
    mParameters : TNxParameters;
    mid:string;
    mCode,mname,mUlice,mdic,mMesto,mPSC,mICO,mmobil,mtel,mKont_os1,memail,mFax:string;
    _ss:Variant;
    ii:integer;
    begin
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


        mICO:=mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].umisteni.firma.ico');
        mdic:=mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].umisteni.firma.dic');

        mname:=mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].umisteni.firma.Name');
        mulice:=mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].umisteni.firma.ICO');
        mmesto:=mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].umisteni.firma.mesto');
        mpsc:=mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].umisteni.firma.psc');
        mtel:=mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].umisteni.firma.tel');
        memail:=mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].umisteni.firma.email');
        mmobil:=mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].umisteni.firma.mobil');
        mfax:=mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].umisteni.firma.fax');
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
                            for ii := 0 to mr.Count - 1 do begin
                                _ss.Add(mr.Strings[ii]);
                            end;
                              //NxShowSimpleMessage('mr' + mr.Strings[0],nil);
                              //NxShowSimpleMessage('_SS' + _SS.strings[0],nil);
                               mID := mroll.SingleSelectFromSelected2(_ss, '`Doplneni adresy', mr.Strings[0]);
                         end;


                        if not NxIsEmptyOID(mid) then begin
                           mbo_SP.SetFieldValueAsString('X_ID_zakaznika_ID',mid); // použití nové adresy servisu
                          // mbo.Save;
                        end;

                    end else begin
                        NxShowSimpleMessage('Adresa ještě neexistuje',nil);
                        //mid:=GetFirmID_TOP(msite.BaseObjectSpace,msite,mCode,mNAme,mUlice,mMesto,mPSC,mICO,mmobil,mtel
                        //      ,mfax,mICO,memail);
                        //     if not NxIsEmptyOID(mid) then begin
                        //         mbo.SetFieldValueAsString('X_ID_zakaznika_ID',mid); // použití nové adresy servisu
                        //      end;
                    end;
          finally
              mr.free;
          end;


       // mfieldfield.Strings[pozice]

end;




function getIDfromfield(os:TNxCustomObjectSpace;R_polozka:string;table:string;Polozka1:string;value1: String;Polozka2:string;value2:String):String;
var
    mR : TStrings;
const
    cSQL2 = 'SELECT %s FROM %s WHERE %s=''%s'' AND %s=''%s''';
begin
    Result := '';
    mR := TStringList.Create;
    try
       if nxisblank(Polozka2) then begin
            os.SQLSelect(Format('SELECT %s FROM %s WHERE %s=''%s''', [r_polozka,table,polozka1,value1]), mR);
       end else begin
            os.SQLSelect(Format('SELECT %s FROM %s WHERE %s=''%s'' AND %s=''%s''', [r_polozka,table,polozka1,value1,polozka2,value2]), mR);
       end;
        if mR.Count > 0 then begin
            Result := mR.Strings[0];
        end else begin
            Result:='';
        end;
    finally
        mR.Free;
    end;
end;


function getIDsfromfield(os:TNxCustomObjectSpace;R_polozka:string;table:string;Polozka1:string;value1: String;Polozka2:string;value2:String):TStringList;
var
    mR : TStringList;
const
    cSQL2 = 'SELECT %s FROM %s WHERE %s=''%s'' AND %s=''%s''';
begin
    mR := TStringList.Create;
    try
       if nxisblank(Polozka2) then begin
            os.SQLSelect(Format('SELECT %s FROM %s WHERE %s=''%s''', [r_polozka,table,polozka1,value1]), mR);
       end else begin
            os.SQLSelect(Format('SELECT %s FROM %s WHERE %s=''%s'' AND %s=''%s''', [r_polozka,table,polozka1,value1,polozka2,value2]), mR);
       end;
        if mR.Count > 0 then begin
            Result := mR;
        end;
    finally
        mR.Free;
    end;
end;



function GetFirmID_TOP(os:TNxCustomObjectSpace;msite:TSiteForm;mCode:string;mNAme:string;mUlice:string;mMesto:string;mPSC:string;mICO:string;mkont_tel1:string;mkont_tel2:string;mKont_os1:string;mKont_os2:string;mKont_mail:string;mXMLHead:TNxScriptingXMLWrapper):string;
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

 //           if index=0 then begin
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
                    if mUlice='' then mEdtStreet.text := '' else mEdtStreet.Text := mUlice;
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
                  // if index=0 then begin
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
                   // end;

              end;
              if mI_modalresult=mrCancel then begin              // zruš přenos
                 ShowMessage('Import adresy byl uživatelsky přerušen');
                 exit;
              end;

            finally
              mForm.Free;
              end;

         //end;

end;

function Import_BusOrder(msite:TSiteForm;mXMLHead:TNxScriptingXMLWrapper;i:integer;mbo_sp:TNxCustomBusinessObject):String;
var
   mBO_BusOrder:TNxCustomBusinessObject;
   mID:string;
begin

// zakazka

                       if not nxisblank(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].zakazka')) then begin
                              mID:='';
                              mID:=getIDfromfield(msite.BaseObjectSpace,'ID','BusOrders','Code',mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].zakazka'),'Hidden','N');
                              if NxIsEmptyOID(mID) then begin
                                  NxShowSimpleMessage('Zakázka není vytvořena, přejete si vyplnit',nil);
                                  if NxIsEmptyOID(mID) then begin
                                        mBO_BusOrder:=msite.BaseObjectSpace.CreateObject('K2WTYL304VD13ACL03KIU0CLP4');
                                        try
                                           mBO_BusOrder.new;
                                           mBO_BusOrder.Prefill;
                                           mBO_BusOrder.SetFieldValueAsString('Code',mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].zakazka'));
                                           mBO_BusOrder.SetFieldValueAsString('Name', mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].umisteni.firma.name')+','+
                                                   mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].umisteni.firma.mesto'));
                                           mBO_BusOrder.SetFieldValueAsString('Firm_ID', mbo_SP.getFieldValueAsString('PayerFirm_ID'));
                                           mBO_BusOrder.SetFieldValueAsString('Person_ID', mbo_SP.getFieldValueAsString('Person_ID'));
                                           mBO_BusOrder.save;
                                           Result:=mBO_BusOrder.oid;
                                        finally
                                           mBO_BusOrder.free;
                                        end;
                                   end;
                               end;

                         end else begin

                         NxShowSimpleMessage('Není uvedena zakázka - chcete vytvořit novou?',nil);

                         end;


end;





  function CheckFieldValue(Self: TNxCustomBusinessObject;R_polozka:string;table:string;Polozka:string;value: String):String;
var
    mR : TStrings;
const
    cSQL = 'SELECT %s FROM %s WHERE %s=''%s''';
begin
    Result := '';
    mR := TStringList.Create;
    try
        Self.ObjectSpace.SQLSelect(Format(cSQL, [r_polozka,table,polozka,value]), mR);
        if mR.Count > 0 then Result := mR.Strings[0];
    finally
        mR.Free;
    end;
end;

  function CheckDynFieldValue(Self: TNxCustomBusinessObject;R_polozka:string;table:string;Polozka:string;value: String):String;
var
    mR : TStrings;
const
    cDSQL = 'SELECT %s FROM %s WHERE hidden=''N'' and  %s=''%s''';
begin
    Result := '';
    mR := TStringList.Create;
    try
        Self.ObjectSpace.SQLSelect(Format(cDSQL, [r_polozka,table,polozka,value]), mR);
        if mR.Count > 0 then Result := mR.Strings[0];
    finally
        mR.Free;
    end;
end;

 function CheckFieldUserValue(Self: TNxCustomBusinessObject;R_polozka:string;table:string;Polozka:string;value: String;mclsid:string;clsvalue: String):String;
var
    mR : TStrings;
const
    cSQL = 'SELECT %s FROM %s WHERE %s=''%s'' AND %s=''%s''';
begin
    Result := '';
    mR := TStringList.Create;
    try
        Self.ObjectSpace.SQLSelect(Format(cSQL, [r_polozka,table,polozka,value,mclsid,clsvalue]), mR);
        if mR.Count > 0 then Result := mR.Strings[0];
    finally
        mR.Free;
    end;
end;



function NxSetFieldString(ABO : TNxCustomBusinessObject; const AName : string; const AValue : string) : boolean;
var
  mStr : string;
  mDelka:String;
  mSubBO : TNxCustomBusinessObject;
begin
  if pos('.', AName) > 0 then begin
    mStr := copy(AName, 1, pos('.', AName) - 1);
    Result := ABO.HasField(mStr);
    if Result then begin
      mSubBO := ABO.GetMonikerForFieldCode(ABO.GetFieldCode(mStr)).BusinessObject;
      mStr := copy(AName, pos('.', AName) + 1, Length(AName));
      Result := NxSetFieldString(mSubBO, mStr, AValue);
    end;
  end else begin
    Result := ABO.HasField(AName);
    if Result then
       ABO.SetFieldValueAsString(AName, AValue)
  end;
end;
function NxSetFieldInteger(ABO : TNxCustomBusinessObject; const AName : string; const AValue : Integer) : boolean;
var
  mStr : string;
  mDelka:String;
  mSubBO : TNxCustomBusinessObject;
begin
  if pos('.', AName) > 0 then begin
    mStr := copy(AName, 1, pos('.', AName) - 1);
    Result := ABO.HasField(mStr);
    if Result then begin
      mSubBO := ABO.GetMonikerForFieldCode(ABO.GetFieldCode(mStr)).BusinessObject;
      mStr := copy(AName, pos('.', AName) + 1, Length(AName));
      Result := NxSetFieldInteger(mSubBO, mStr, AValue);
    end;
  end else begin
    Result := ABO.HasField(AName);
    if Result then
       ABO.SetFieldValueAsInteger(AName, AValue)
  end;
end;
function NxSetFieldfloat(ABO : TNxCustomBusinessObject; const AName : string; const AValue : Double) : boolean;
var
  mStr : string;
  mDelka:String;
  mSubBO : TNxCustomBusinessObject;
begin
  if pos('.', AName) > 0 then begin
    mStr := copy(AName, 1, pos('.', AName) - 1);
    Result := ABO.HasField(mStr);
    if Result then begin
      mSubBO := ABO.GetMonikerForFieldCode(ABO.GetFieldCode(mStr)).BusinessObject;
      mStr := copy(AName, pos('.', AName) + 1, Length(AName));
      Result := NxSetFieldfloat(mSubBO, mStr, AValue);
    end;
  end else begin
    Result := ABO.HasField(AName);
    if Result then
       ABO.SetFieldValueAsFloat(AName, AValue)
  end;
end;
function NxSetFieldboolean(ABO : TNxCustomBusinessObject; const AName : string; const AValue : Boolean) : boolean;
var
  mStr : string;
  mDelka:String;
  mSubBO : TNxCustomBusinessObject;
begin
  if pos('.', AName) > 0 then begin
    mStr := copy(AName, 1, pos('.', AName) - 1);
    Result := ABO.HasField(mStr);
    if Result then begin
      mSubBO := ABO.GetMonikerForFieldCode(ABO.GetFieldCode(mStr)).BusinessObject;
      mStr := copy(AName, pos('.', AName) + 1, Length(AName));
      Result := NxSetFieldboolean(mSubBO, mStr, AValue);
    end;
  end else begin
    Result := ABO.HasField(AName);
    if Result then
       ABO.SetFieldValueAsBoolean(AName, AValue)
  end;
end;

function NxSetFielddateTime(ABO : TNxCustomBusinessObject; const AName : string; const AValue : Date) : boolean;
var
  mStr : string;
  mDelka:String;
  mSubBO : TNxCustomBusinessObject;
begin
  if pos('.', AName) > 0 then begin
    mStr := copy(AName, 1, pos('.', AName) - 1);
    Result := ABO.HasField(mStr);
    if Result then begin
      mSubBO := ABO.GetMonikerForFieldCode(ABO.GetFieldCode(mStr)).BusinessObject;
      mStr := copy(AName, pos('.', AName) + 1, Length(AName));
      Result := NxSetFielddateTime(mSubBO, mStr, AValue);
    end;
  end else begin
    Result := ABO.HasField(AName);
    if Result then
       ABO.SetFieldValueAsDateTime(AName, AValue)
  end;
end;

procedure ParseHead(AStru : TNxParameters; const ADescription : string; const ASeparator: string; const AData : string; AHead:TStringList);
// rozdělení parametrů sloupců pro import
var
    mStr, mToken : string;
    mPos, i : integer;
begin
    mStr := AData;
    try
        NxTokenToStrings(ADescription, ASeparator, AHead);
        for i := 0 to AHead.Count- 1 do begin
            mPos := AnsiPos(ASeparator, mStr);
            if mPos = 0 then mPos := Length(mStr) + 1;
            mToken := NxLeft(mStr, mPos - 1);
            mStr := copy(mStr, mPos + 1, Length(mStr) - mPos);
        end;
    finally
  end;
end;

procedure Parsevalue(AStru : TNxParameters; const ADescription : string; const ASeparator: string; const AData : string; AHead:TStringList;sloupcu:integer);
// rozdělení hodnot pro import
var
    mStr, mToken : string;
    mPos, i : integer;
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


{function setParameterO(msite:TSiteForm;mXMLHead:TNxScriptingXMLWrapper;i:integer;mbo_sp:TNxCustomBusinessObject):Boolean;
var
mr:tstringlist;
II:integer;
mBO_DF,mBO1_DF:TNxCustomBusinessObject;
mpocet:integer;
mid:string;
begin
//NxShowSimpleMessage(typ + ' - ' + mbo_ID + popis.Strings[5]+ '-' + hodnota.Strings[5],nil);
if hodnota.count>=popis.count then begin
   mpocet:=popis.count;
end else begin
   mpocet:=hodnota.count;
end;

for ii := 3 to mpocet-1 do begin

               // číselník parametrů
                 mid:='';
                 mr:=tstringlist.create;
                 try

                      msite.BaseObjectSpace.SQLSelect('select id from defrolldata where CLSID=' + quotedstr('WLOHIKYCKUGOX1LFEEIQGD5NX0') + ' and X_field1=' +
                      quotedstr(popis.Strings[ii]) + ' and X_field5=' + quotedstr(typ),mr) ;

                      if mr.count=0 then begin
                          try
                                //NxShowSimpleMessage('param_zalozen',nil);
                                mBO_DF:=msite.BaseObjectSpace.CreateObject('WLOHIKYCKUGOX1LFEEIQGD5NX0');  // číselník parametrů
                                mBO_DF.new;
                                // založení nového parametru
                                mBO_DF.SetFieldValueAsString('code',inttostr(ii)); // popis
                                mBO_DF.SetFieldValueAsString('X_PosIndex',inttostr(ii)); // popis
                                mBO_DF.SetFieldValueAsString('Name',copy(popis.Strings[ii],1,50));
                                mBO_DF.SetFieldValueAsString('X_field1',copy(popis.Strings[ii],1,199));
                                mBO_DF.SetFieldValueAsString('X_field5',typ);
                                mBO_DF.save;
                                mid:=mbo_df.oid;
                           finally
                                mBO_DF.free;
                           end;

                     end else begin

                                // dohledání parametru
                                //NxShowSimpleMessage('param_dohledan',nil);
                                mid:=mr.Strings[0];
                     end;
                 finally
                            mr.free
                 end ;


                 if mid<>'' then begin
                      mr:=TStringList.create;
                      try
                          msite.BaseObjectSpace.SQLSelect('SELECT A.ID FROM DefRollData A where CLSID=' + quotedstr('L5NKMYE3ZLSOLEBABM5CCHGOIC') +  ' and X_ServicedObject_ID='+quotedstr(mBO_ID) + ' and X_field5='+quotedstr(typ) +
                                   ' AND (exists (SELECT 1 FROM USERDATA WHERE FIELDCODE=2000002 AND CLSID=' + quotedstr('L5NKMYE3ZLSOLEBABM5CCHGOIC') +  ' AND ID = A.ID AND (STRINGFIELDVALUE =' + quotedstr(mid)+')))',mr) ;
                          if mr.count=0 then begin
                                 try

                                      mBO1_DF:=msite.BaseObjectSpace.CreateObject('L5NKMYE3ZLSOLEBABM5CCHGOIC');        // založení hodnoty
                                      //NxShowSimpleMessage('založení nového parametru',nil);
                                      mBO1_DF.new;
                                      mBO1_DF.SetFieldValueAsString('code',inttostr(ii)); // popis
                                      mBO1_DF.SetFieldValueAsString('X_PosIndex',inttostr(ii)); // popis
                                      mBO1_DF.SetFieldValueAsString('Name',copy(popis.Strings[ii],1,50));
                                      mBO1_DF.SetFieldValueAsString('X_ServicedObject_ID',mBO_ID); // sp
                                      mBO1_DF.SetFieldValueAsString('U_Parametr_ID',mid);
                                      mBO1_DF.SetFieldValueAsString('X_field2', copy(hodnota.Strings[ii],1,199));   //
                                      mBO1_DF.SetFieldValueAsString('X_field5', typ);
                                      mBO1_DF.save;

                                 finally
                                      mBO1_DF.free;
                                 end;
                            end else begin
                                 try

                                      mBO1_DF:=msite.BaseObjectSpace.CreateObject('L5NKMYE3ZLSOLEBABM5CCHGOIC');        // založení hodnoty
                                      // oprava parametru
                                      mBO1_DF.load(mr.Strings[0],nil);
                                      mBO1_DF.SetFieldValueAsString('code',inttostr(ii)); // popis
//                                                                    mBO1_DF.SetFieldValueAsString('Name',copy(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].params['+inttostr(ii)+'].param.param_name'),1,80));
                                      mBO1_DF.SetFieldValueAsString('X_field2',copy(hodnota.Strings[ii],1,199));   //
                                      mBO1_DF.SetFieldValueAsString('X_field5',typ);
                                      mBO1_DF.save;

                                 finally
                                      mBO1_DF.free;
                                 end;
                            end;

                      finally
                          mr.free;
                      end;
                 end;


end;

result:=true;
end;
     }



function setParameterV(os:TNxCustomObjectSpace;mBO_ID:string;typ:string;Popis:TStringList;Hodnota:TStringList):Boolean;
var
mr:tstringlist;
II:integer;
mBO_DF,mBO1_DF:TNxCustomBusinessObject;
mpocet:integer;
mid:string;
begin
//NxShowSimpleMessage(typ + ' - ' + mbo_ID + popis.Strings[5]+ '-' + hodnota.Strings[5],nil);
if hodnota.count>=popis.count then begin
   mpocet:=popis.count;
end else begin
   mpocet:=hodnota.count;
end;

for ii := 3 to mpocet-1 do begin

               // číselník parametrů
                 mid:='';
                 mr:=tstringlist.create;
                 try

                      os.SQLSelect('select id from defrolldata where CLSID=' + quotedstr('WLOHIKYCKUGOX1LFEEIQGD5NX0') + ' and X_field1=' +
                      quotedstr(popis.Strings[ii]) + ' and X_field5=' + quotedstr(typ),mr) ;

                      if mr.count=0 then begin
                          try
                                //NxShowSimpleMessage('param_zalozen',nil);
                                mBO_DF:=os.CreateObject('WLOHIKYCKUGOX1LFEEIQGD5NX0');  // číselník parametrů
                                mBO_DF.new;
                                // založení nového parametru
                                mBO_DF.SetFieldValueAsString('code',inttostr(ii)); // popis
                                mBO_DF.SetFieldValueAsString('X_PosIndex',inttostr(ii)); // popis
                                mBO_DF.SetFieldValueAsString('Name',copy(popis.Strings[ii],1,50));
                                mBO_DF.SetFieldValueAsString('X_field1',copy(popis.Strings[ii],1,199));
                                mBO_DF.SetFieldValueAsString('X_field5',typ);
                                mBO_DF.save;
                                mid:=mbo_df.oid;
                           finally
                                mBO_DF.free;
                           end;

                     end else begin

                                // dohledání parametru
                                //NxShowSimpleMessage('param_dohledan',nil);
                                mid:=mr.Strings[0];
                     end;
                 finally
                            mr.free
                 end ;


                 if mid<>'' then begin
                      mr:=TStringList.create;
                      try
                          os.SQLSelect('SELECT A.ID FROM DefRollData A where CLSID=' + quotedstr('L5NKMYE3ZLSOLEBABM5CCHGOIC') +  ' and X_ServicedObject_ID='+quotedstr(mBO_ID) + ' and X_field5='+quotedstr(typ) +
                                   ' AND (exists (SELECT 1 FROM USERDATA WHERE FIELDCODE=2000002 AND CLSID=' + quotedstr('L5NKMYE3ZLSOLEBABM5CCHGOIC') +  ' AND ID = A.ID AND (STRINGFIELDVALUE =' + quotedstr(mid)+')))',mr) ;
                          if mr.count=0 then begin
                                 try

                                      mBO1_DF:=os.CreateObject('L5NKMYE3ZLSOLEBABM5CCHGOIC');        // založení hodnoty
                                      //NxShowSimpleMessage('založení nového parametru',nil);
                                      mBO1_DF.new;
                                      mBO1_DF.SetFieldValueAsString('code',inttostr(ii)); // popis
                                      mBO1_DF.SetFieldValueAsString('X_PosIndex',inttostr(ii)); // popis
                                      mBO1_DF.SetFieldValueAsString('Name',copy(popis.Strings[ii],1,50));
                                      mBO1_DF.SetFieldValueAsString('X_ServicedObject_ID',mBO_ID); // sp
                                      mBO1_DF.SetFieldValueAsString('U_Parametr_ID',mid);
                                      mBO1_DF.SetFieldValueAsString('X_field2', copy(hodnota.Strings[ii],1,199));   //
                                      mBO1_DF.SetFieldValueAsString('X_field5', typ);
                                      mBO1_DF.save;

                                 finally
                                      mBO1_DF.free;
                                 end;
                            end else begin
                                 try

                                      mBO1_DF:=os.CreateObject('L5NKMYE3ZLSOLEBABM5CCHGOIC');        // založení hodnoty
                                      // oprava parametru
                                      mBO1_DF.load(mr.Strings[0],nil);
                                      mBO1_DF.SetFieldValueAsString('code',inttostr(ii)); // popis
//                                                                    mBO1_DF.SetFieldValueAsString('Name',copy(mXMLHead.getElementAsString('Vyrobek['+inttostr(i)+'].params['+inttostr(ii)+'].param.param_name'),1,80));
                                      mBO1_DF.SetFieldValueAsString('X_field2',copy(hodnota.Strings[ii],1,199));   //
                                      mBO1_DF.SetFieldValueAsString('X_field5',typ);
                                      mBO1_DF.save;

                                 finally
                                      mBO1_DF.free;
                                 end;
                            end;

                      finally
                          mr.free;
                      end;
                 end;


end;

result:=true;
end;


begin
end.