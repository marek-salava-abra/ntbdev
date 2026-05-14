 Var
mTyp_obchodu:string;
  mXMLHead : TNxScriptingXMLWrapper;
  mSite : TDynSiteForm;
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
  mbusorder,mbustransaction,mbusproject,mbankacount: TNxCustomBusinessObject;
  maddress: TNxCustomBusinessObject;
  mhead: TNxHeaderBusinessObject;
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



  procedure Parsevalue(const ADescription : string; const ASeparator: string; const AData : string; AHead:TStringList;sloupcu:integer);
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

 Function ErrtElementString(mXMLHead : TNxScriptingXMLWrapper;mElement:string):boolean;
var
mstring:string;
begin
result:=true;
    try
          mstring:=mXMLHead.getElementAsString(mElement);
          result:=false;
    except
          result:=true;
    end;

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


function GetFirmID_TOP(os:TNxCustomObjectSpace;mXMLHead:TNxScriptingXMLWrapper;msite:TDynSiteForm;mid_county:string):string;
var
mresult:boolean;
mEdtCountryCode:TEdit;
begin
// odberatel
        if mXMLHead.getElementAsString('ABRADocument.Customer')='' then begin    // kontrolliji ID
               if mXMLHead.getElementAsString('ABRADocument.Customer.Name')<>'' then begin // kontroluji název firmy
                        os.CreateObject('4K3EXM5PQBCL35CH000ILPWJF4');
                        mRes := TStringList.Create;
                        try
                                OS.SQLSelect(format('SELECT ID FROM Firms A WHERE Name=''%s'' AND A.Hidden=''N'' order by id', [(mXMLHead.getElementAsString('ABRADocument.Customer.Name'))]), mRes);      //hledám id firmy

                                if mRes.Count = 1 then begin       // záznam nalezen
                                       mfirm:= OS.CreateObject('4K3EXM5PQBCL35CH000ILPWJF4');
                                              mID := mRes.Strings[0];
                                              try
                                              mFirm.Load(mID,nil) ;
                                          {    if (mFirm.GetFieldValueAsString('ResidenceAddress_ID.PostCode') = mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.PostCode')) AND
                                                (mFirm.GetFieldValueAsString('ResidenceAddress_ID.Street') = mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.Street')) AND
                                                (mFirm.GetFieldValueAsString('ResidenceAddress_ID.City') = mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.City')) then begin
                                                        mID_odberatel := mRes.Strings[0];
                                                        mhead.SetFieldValueAsString('Firm_ID',mID_odberatel);
                                              end;  }
                                              finally

                                              end;

                                end;
                                if mRes.Count > 1 then begin       // záznam nalezen

                                         for ii:=0 to mRes.count-1 do begin
                                              mfirm:= OS.CreateObject('4K3EXM5PQBCL35CH000ILPWJF4');
                                              try
                                              mID := mRes.Strings[ii];
                                              mFirm.Load(mID,nil) ;
                                        {      if (mFirm.GetFieldValueAsString('ResidenceAddress_ID.PostCode') = mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.PostCode')) AND
                                                (mFirm.GetFieldValueAsString('ResidenceAddress_ID.Street') = mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.Street')) AND
                                                (mFirm.GetFieldValueAsString('ResidenceAddress_ID.City') = mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.City')) then begin
                                                        mID_odberatel := mRes.Strings[ii];
                                              end;  }
                                              finally
                                              end;
                                         end;
                                        result:=mID_odberatel;
                                end;

                                                mForm := TForm.Create(nil);
                                                try
                                                      mForm.Width := 700;  // sirka
                                                      mForm.Height := 350; // vyska - dopočítívá se na závěr
                                                      mForm.Caption := 'Kontrola firem';

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

                                                      mLbl := TLabel.Create(mForm);
                                                      mLbl.Caption := 'DIČ:'  ;
                                                      mLbl.Left := 20;
                                                      mLbl.Top := 80;
                                                      mLbl.Name := 'lblDIC';
                                                      mForm.InsertControl(mLbl);

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

                                                      mLbl := TLabel.Create(mForm);
                                                      mLbl.Caption := 'Země:'  ;
                                                      mLbl.Left := 20;
                                                      mLbl.Top := 230;
                                                      mLbl.Name := 'lblCountry';
                                                      mForm.InsertControl(mLbl);

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
                                                      if NxIsBlank(mXMLHead.getElementAsString('ABRADocument.Customer.OrgIdentNumber')) then begin
                                                                mEdtIc.Text  := ' ';
                                                      end else begin
                                                                mEdtIc.Text  := mXMLHead.getElementAsString('ABRADocument.Customer.OrgIdentNumber')  ;
                                                      end;
                                                      mEdtIc.Name := 'edtSIC';
                                                      mForm.InsertControl(mEdtIc);

                                                      mEdtDIC := TEdit.Create(mForm);
                                                      mEdtDIC.Left := 80;
                                                      mEdtDIC.Top := 80;
                                                      mEdtDIC.Width := 100;
                                                      if NxIsBlank(mXMLHead.getElementAsString('ABRADocument.Customer.VATOrgIdentNumber')) then begin
                                                                mEdtDIC.Text  := ' ';
                                                      end else begin
                                                                mEdtDIC.Text  := mXMLHead.getElementAsString('ABRADocument.Customer.VATOrgIdentNumber')  ;
                                                      end;
                                                        mEdtDIc.Name := 'edtSDIC';
                                                      mForm.InsertControl(mEdtDIc);

                                                      mEdtName := TEdit.Create(mForm);
                                                      mEdtName.Left := 80;
                                                      mEdtName.Top := 110;
                                                      mEdtName.Width := 250;
                                                      mEdtName.Text := mXMLHead.getElementAsString('ABRADocument.Customer.Name');
                                                      mEdtName.Name := 'edtSName';
                                                      mForm.InsertControl(mEdtName);


                                                      mEdtStreet:= TEdit.Create(mForm);
                                                      mEdtStreet.Left := 80;
                                                      mEdtStreet.Top := 140;
                                                      mEdtStreet.Width := 250;
                                                      mEdtStreet.Text := mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.Street');
                                                      mEdtStreet.Name := 'edtSStreet';
                                                      mForm.InsertControl(mEdtStreet);


                                                      mEdtCity := TEdit.Create(mForm);
                                                      mEdtCity.Left := 80;
                                                      mEdtCity.Top := 170;
                                                      mEdtCity.Width := 250;
                                                      mEdtCity.Text := mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.City');
                                                      mEdtCity.Name := 'edtSCity';
                                                      mForm.InsertControl(mEdtCity);

                                                      mEdtPostCode := TEdit.Create(mForm);
                                                      mEdtPostCode.Left := 80;
                                                      mEdtPostCode.Top := 200;
                                                      mEdtPostCode.Width := 100;
                                                      mEdtPostCode.Text := mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.Postcode');
                                                      mEdtPostCode.Name := 'edtSPostcode';
                                                      mForm.InsertControl(mEdtPostCode);

                                                      mEdtCountryCode := TEdit.Create(mForm);
                                                      mEdtCountryCode.Left := 80;
                                                      mEdtCountryCode.Top := 230;
                                                      mEdtCountryCode.Width := 100;
                                                      mEdtCountryCode.Text := mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.CountryCode');
                                                      mEdtCountryCode.Name := 'edtCountrycode';
                                                      mForm.InsertControl(mEdtCountryCode);

                                                      if mRes.Count >0 then begin

                                                          mLbl := TLabel.Create(mForm);
                                                          mLbl.Caption := 'Dohledáno'  ;
                                                          mLbl.Left := 350;
                                                          mLbl.Top := 20;
                                                          mLbl.Name := 'lblDPopis';
                                                          mForm.InsertControl(mLbl);

                                                          mLbl := TLabel.Create(mForm);
                                                          if NxIsBlank(mFirm.GetFieldValueAsString('OrgIdentNumber')) then begin
                                                                mLbl.Caption := 'Neuvedeno';
                                                          end else begin
                                                                mLbl.Caption := mFirm.GetFieldValueAsString('OrgIdentNumber')  ;
                                                          end;
                                                          mLbl.Left := 350;
                                                          mLbl.Top := 50;
                                                          mLbl.Name := 'lblDIco';
                                                          mForm.InsertControl(mLbl);

                                                          mLbl := TLabel.Create(mForm);
                                                          if NxIsBlank(mFirm.GetFieldValueAsString('VATIdentNumber')) then begin
                                                                mLbl.Caption := 'Neuvedeno';
                                                          end else begin
                                                                mLbl.Caption := mFirm.GetFieldValueAsString('VATIdentNumber')  ;
                                                          end;
                                                          mLbl.Left := 350;
                                                          mLbl.Top := 80;
                                                          mLbl.Name := 'lblDDIC';
                                                          mForm.InsertControl(mLbl);

                                                          mLbl := TLabel.Create(mForm);
                                                          mLbl.Caption := mFirm.GetFieldValueAsString('Name')  ;
                                                          mLbl.Left := 350;
                                                          mLbl.Top := 110;
                                                          mLbl.Name := 'lblDName';
                                                          mForm.InsertControl(mLbl);


                                                          mLbl := TLabel.Create(mForm);
                                                          mLbl.Caption := mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.GetFieldValueAsString('Street');
                                                          mLbl.Left := 350;
                                                          mLbl.Top := 140;
                                                          mLbl.Name := 'lblDSTreet';
                                                          mForm.InsertControl(mLbl);

                                                          mLbl := TLabel.Create(mForm);
                                                          mLbl.Caption := mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.GetFieldValueAsString('City')   ;
                                                          mLbl.Left := 350;
                                                          mLbl.Top := 170;
                                                          mLbl.Name := 'lblDCity';
                                                          mForm.InsertControl(mLbl);

                                                          mLbl := TLabel.Create(mForm);
                                                          mLbl.Caption := mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.GetFieldValueAsString('PostCode')  ;
                                                          mLbl.Left := 350;
                                                          mLbl.Top := 200;
                                                          mLbl.Name := 'lblDPostcode';
                                                          mForm.InsertControl(mLbl);

                                                          mLbl := TLabel.Create(mForm);
                                                          mLbl.Caption := mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.GetFieldValueAsString('Country')  ;
                                                          mLbl.Left := 350;
                                                          mLbl.Top := 230;
                                                          mLbl.Name := 'lblDCountry';
                                                          mForm.InsertControl(mLbl);

                                                          mBtn := TButton.Create(mForm);
                                                          mBtn.Width := 75;
                                                          mBtn.Height := 25;
                                                          mBtn.Caption := 'Použít';
                                                          mBtn.Left := 20;
                                                          mBtn.Top := mForm.Height - mBtn.Height - 30;
                                                          mBtn.Visible := True;
                                                          mBtn.ModalResult := mrOK;
                                                          mBtn.Cancel := False;
                                                          mBtn.Name := 'btnOK';
                                                          mForm.InsertControl(mBtn);
                                                end ;

                                                      mBtn := TButton.Create(mForm);
                                                      mBtn.Width := 75;
                                                      mBtn.Height := 25;
                                                      mBtn.Caption := 'Založit nový';
                                                      mBtn.Left := 120;
                                                      mBtn.Top := mForm.Height - mBtn.Height - 30;
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
                                                      mBtn.Top := mForm.Height - mBtn.Height - 30;
                                                      mBtn.Visible := True;
                                                      mBtn.ModalResult := mrCancel;
                                                      mBtn.Cancel := True;
                                                      mBtn.Name := 'btnCancel';
                                                      mForm.InsertControl(mBtn);

                                                      mI_modalresult:=mForm.ShowModal(msite) ;
                                                  // if mForm.ShowModal = mrCancel then begin
                                                  //      mI_modalresult:=mrCancel;
                                                  // end else begin
                                                  //      if mForm.ShowModal = mrOK then begin
                                                  //          mI_modalresult:=mrOk;
                                                  //      end else begin
                                                  //          mI_modalresult:=mrYes;
                                                  //      end;
                                                  //  end;

                                                 //mI_modalresult:=mBtn.ModalResult;

                                                if mI_modalresult=mrOk then begin                  // použit
                                                   mresult:=InputQuery('Potvrzení', 'Zadaná firma bude použita, jste si jisti','');
                                                        if mresult then begin
                                                               result:=mfirm.oid;
                                                               ShowMessage('Dohledaná firma byla použita');
                                                        end else begin
                                                               result:='';
                                                               exit;
                                                        end;
                                                   //ShowMessage(inttostr(mI_modalresult));
                                                end;
                                                 if mI_modalresult=mrYes then begin                 // založ
                                                     mfirm:= OS.CreateObject('4K3EXM5PQBCL35CH000ILPWJF4');
                                                    try
                                                            mRes1 := TStringList.Create;
                                                            OS.SQLSelect('SELECT max(code) FROM Firms A WHERE substring(Code,1,1)=' + quotedstr('0'), mRes1);
                                                            //ShowMessage(mres1.Strings[0]);
                                                            mS_code:= NxPadL(inttostr(StrToInt(copy(mres1.Strings[0],2,7))+1),7,'0');
                                                            //ShowMessage(mS_code);
                                                            mres1.free;

                                                        mFirm.New;
                                                        mFirm.Prefill;
                                                        mFirm.SetFieldValueAsString('Code', mS_Code);
                                                        mFirm.SetFieldValueAsString('Name', copy(mXMLHead.getElementAsString('ABRADocument.Customer.Name'),1,200));
                                                        mFirm.SetFieldValueAsString('OrgIdentNumber',copy(mXMLHead.getElementAsString('ABRADocument.Customer.OrgIdentNumber'),1,15));
                                                        mFirm.SetFieldValueAsString('VATIdentNumber', copy(mXMLHead.getElementAsString('ABRADocument.Customer.VATOrgIdentNumber'),1,20));
                                                        mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('Location',copy(mXMLHead.getElementAsString('ABRADocument.Customer.AllName'),1,100));
                                                        mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('PostCode',copy(mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.PostCode'),1,9));
                                                        mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('Street',copy(mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.Street'),1,60));
                                                        mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('City',copy(mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.City'),1,60));
                                                        mCountryName:=getIDfromfield(os,'Name','Countries','Code',mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.CountryCode'),'Hidden','N');

                                                        mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('Country',mcountryname);
                                                        mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('CountryCode',mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.CountryCode'));
                                                        mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('PhoneNumber1',mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.Tel1'));
                                                        mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('PhoneNumber2',mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.Tel2'));
                                                        mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('EMail',mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.email'));
                                                        if (mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.CountryCode')<>'CZ') and
                                                           (mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.CountryCode')<>'') and
                                                           (mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.CountryCode')<>'SK') then begin
                                                            mFirm.SetFieldValueAsInteger('X_Stitek',1);
                                                        end else begin
                                                            mFirm.SetFieldValueAsInteger('X_Stitek',0);
                                                        end;
                                                        mFirm.SetFieldValueAsBoolean('X_Email_notification',true);
                                                        mfirm.Save;
                                                        result:=mfirm.oid;


                                                        ShowMessage('Nová firma byla založena s kódem: ' + mS_Code);
                                                       if not nxisblank(trim(mXMLHead.getElementAsString('ABRADocument.Customer.AllName'))) then begin
                                                            mfirm_office:=OS.CreateObject('AT011EZZ5DFO115YJ1HCZJDXJ4');
                                                            mr2:=tstringlist.create;
                                                            try
                                                               os.SQLSelect('select id from FirmOffices where Parent_ID=' + quotedstr(mfirm.oid),mr2);
                                                               if mr2.count>0 then begin
                                                                     if mr2.count=1 then begin
                                                                        mfirm_office.load(mr2.Strings[0],nil);
                                                                             mfirm_office.SetFieldValueAsString('Name',trim(mXMLHead.getElementAsString('ABRADocument.Customer.AllName')));
                                                                             mfirm_office.save;
                                                                     end;
                                                               end;
                                                            finally
                                                               mr2.free;
                                                               mfirm_office.free;
                                                            end;

                                                        end;


                                                       //mhead.SetFieldValueAsString('Firm_ID',mfirm.oid);
                                                    finally
                                                        mfirm.Free;
                                                    end;
                                                    //ShowMessage(inttostr(mI_modalresult));
                                                end;
                                                if mI_modalresult=mrCancel then begin              // zruš přenos
                                                   ShowMessage('Import byl uživatelsky přerušen');
                                                   exit;
                                                end;

                                              finally
                                                mForm.Free;
                                                end;




                        finally
                                mRes.Free;
                        end;
                end;
        end;





end;


function GetFirmID_B2C(os:TNxCustomObjectSpace;mXMLHead:TNxScriptingXMLWrapper;msite:TDynSiteForm):string;
begin
// odberatel
        if mXMLHead.getElementAsString('ABRADocument.Customer')='' then begin    // kontrolliji ID
               if mXMLHead.getElementAsString('ABRADocument.Customer.Name')<>'' then begin // kontroluji název firmy
                        os.CreateObject('4K3EXM5PQBCL35CH000ILPWJF4');
                        mRes := TStringList.Create;
                        try
                                OS.SQLSelect(format('SELECT ID FROM Firms A WHERE Name=''%s'' AND A.Hidden=''N'' order by id', [(mXMLHead.getElementAsString('ABRADocument.Customer.Name'))]), mRes);      //hledám id firmy

                                if mRes.Count = 1 then begin       // záznam nalezen
                                       mfirm:= OS.CreateObject('4K3EXM5PQBCL35CH000ILPWJF4');
                                              mID := mRes.Strings[0];
                                              mFirm.Load(mID,nil) ;
                                              if (mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.GetFieldValueAsString('PostCode') = mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.PostCode')) AND
                                                (mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.GetFieldValueAsString('Street') = mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.Street')) AND
                                                (mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.GetFieldValueAsString('City') = mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.City')) then begin
                                                        result := mRes.Strings[0];
                                              end;

                                end;
                                if mRes.Count > 1 then begin       // záznam nalezen

                                         for ii:=0 to mRes.count-1 do begin
                                              mfirm:= OS.CreateObject('4K3EXM5PQBCL35CH000ILPWJF4');
                                              mID := mRes.Strings[ii];
                                              mFirm.Load(mID,nil) ;
                                              if (mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.GetFieldValueAsString('PostCode') = mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.PostCode')) AND
                                                (mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.GetFieldValueAsString('Street') = mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.Street')) AND
                                                (mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.GetFieldValueAsString('City') = mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.City')) then begin
                                                        result := mRes.Strings[ii];
                                              end;

                                         end;

                                end;

                                 if mID_odberatel='' then begin                // zaznam neexistuje založím nový
                                        mfirm:= OS.CreateObject('4K3EXM5PQBCL35CH000ILPWJF4');
                                        try
                                                mFirm.New;
                                                mFirm.Prefill;
                                                mFirm.SetFieldValueAsString('Code', '0005420');
                                                mFirm.SetFieldValueAsString('Name', copy(mXMLHead.getElementAsString('ABRADocument.Customer.Name'),1,200));
                                                mFirm.SetFieldValueAsString('OrgIdentNumber',copy(mXMLHead.getElementAsString('ABRADocument.Customer.OrgIdentNumber'),1,15));
                                                mFirm.SetFieldValueAsString('VATIdentNumber', copy(mXMLHead.getElementAsString('ABRADocument.Customer.VATOrgIdentNumber'),1,20));
                                                mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('PostCode',copy(mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.PostCode'),1,9));
                                                mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('Location',copy(mXMLHead.getElementAsString('ABRADocument.Customer.AllName'),1,100));
                                                mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('Street',copy(mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.Street'),1,60));
                                                mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('City',copy(mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.City'),1,60));
                                                mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('CountryCode',mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.CountryCode'));

                                                mCountryName:=getIDfromfield(os,'Name','Countries','Code',mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.CountryCode'),'Hidden','N');
                                                mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('Country',mCountryName);

                                               if (mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.CountryCode')<>'CZ') and
                                                           (mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.CountryCode')<>'') and
                                                           (mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.CountryCode')<>'SK') then begin
                                                            mFirm.SetFieldValueAsInteger('X_Stitek',1);
                                                        end else begin
                                                            mFirm.SetFieldValueAsInteger('X_Stitek',0);
                                                        end;
                                                mFirm.SetFieldValueAsBoolean('X_Email_notification',true);

                                                mfirm.Save;


                                                result:=mfirm.oid;

                                                if not nxisblank(trim(mXMLHead.getElementAsString('ABRADocument.Customer.AllName'))) then begin
                                                            mfirm_office:=OS.CreateObject('AT011EZZ5DFO115YJ1HCZJDXJ4');
                                                            mr2:=tstringlist.create;
                                                            try
                                                               os.SQLSelect('select id from FirmOffices where Parent_ID=' + quotedstr(mfirm.oid),mr2);
                                                               if mr2.count>0 then begin
                                                                     if mr2.count=1 then begin
                                                                        mfirm_office.load(mr2.Strings[0],nil);
                                                                             mfirm_office.SetFieldValueAsString('Name',trim(mXMLHead.getElementAsString('ABRADocument.Customer.AllName')));
                                                                             mfirm_office.save;
                                                                     end;
                                                               end;
                                                            finally
                                                               mr2.free;
                                                               mfirm_office.free;
                                                            end;

                                                        end;
                                        finally
                                                mfirm.Free;
                                        end;

                                end;
                        finally
                                mRes.Free;
                        end;
                end;
        end;



end;

begin
end.