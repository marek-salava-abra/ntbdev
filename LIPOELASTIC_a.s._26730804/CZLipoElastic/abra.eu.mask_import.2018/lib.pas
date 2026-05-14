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
  mfirm,mfirm_office,mBO_FirmOffice: TNxCustomBusinessObject;
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
  mID_firm_office:string;
  mSQUnit:string;
  mStringCisloPopisne:string;

  function TranslateUnicode(mString:string):string;
begin
        //mString:=NxRemoveDiacritics(mString);
              try
              mString:=NxSearchReplace(mString,CHR(39),'',[srCase,srAll]);    //
              finally

              end;

              mString:=NxSearchReplace(mString,'^','',[srCase,srAll]);    //	Vokáň/Stříška
              mString:=NxSearchReplace(mString,'`','',[srCase,srAll]);    //	Obrácená čárka
              mString:=NxSearchReplace(mString,'~','',[srCase,srAll]);    //	Vlnovka
              mString:=NxSearchReplace(mString,'€','',[srCase,srAll]);    //	Znak Eura
              mString:=NxSearchReplace(mString,'“','',[srCase,srAll]);    //	Dvojité uvozovky
              mString:=NxSearchReplace(mString,'…','',[srCase,srAll]);    //	Trojitá tečka
              mString:=NxSearchReplace(mString,'†','',[srCase,srAll]);    //	Křížek
              mString:=NxSearchReplace(mString,'‡','',[srCase,srAll]);    //	Dvojitý křížek
              mString:=NxSearchReplace(mString,'‰','',[srCase,srAll]);    //	Promile
              mString:=NxSearchReplace(mString,'‹','',[srCase,srAll]);    //
              mString:=NxSearchReplace(mString,'Ś','S',[srCase,srAll]);    //	Velké s s čárkou
              mString:=NxSearchReplace(mString,'o','o',[srCase,srAll]);    //
              mString:=NxSearchReplace(mString,'›','',[srCase,srAll]);    //
              mString:=NxSearchReplace(mString,'ś','s',[srCase,srAll]);    //	Malé s s čárkou
              mString:=NxSearchReplace(mString,'ź','z',[srCase,srAll]);    //	Malé z s čárkou
              mString:=NxSearchReplace(mString,'ˇ','',[srCase,srAll]);    //	Háček
              mString:=NxSearchReplace(mString,'Ł','',[srCase,srAll]);    //	Znak Libry
              mString:=NxSearchReplace(mString,'¤','',[srCase,srAll]);    //
              mString:=NxSearchReplace(mString,'Ą','A',[srCase,srAll]);    //
              mString:=NxSearchReplace(mString,'¦','',[srCase,srAll]);    //
              mString:=NxSearchReplace(mString,'§','',[srCase,srAll]);    //	Paragraf
              mString:=NxSearchReplace(mString,'¨','',[srCase,srAll]);    //	Přehláska
              mString:=NxSearchReplace(mString,'©','',[srCase,srAll]);    //	Symbol Copyright
              mString:=NxSearchReplace(mString,'Ş','S',[srCase,srAll]);    //
              mString:=NxSearchReplace(mString,'®','',[srCase,srAll]);    //	Symbol Registered
              mString:=NxSearchReplace(mString,'Ż','Z',[srCase,srAll]);    //
              mString:=NxSearchReplace(mString,'°','',[srCase,srAll]);    //	Stupeň
              mString:=NxSearchReplace(mString,'±','',[srCase,srAll]);    //
              mString:=NxSearchReplace(mString,'ł','',[srCase,srAll]);    //
              mString:=NxSearchReplace(mString,'µ','u',[srCase,srAll]);    //
              mString:=NxSearchReplace(mString,'ą','a',[srCase,srAll]);    //
              mString:=NxSearchReplace(mString,'ş','s',[srCase,srAll]);    //
              mString:=NxSearchReplace(mString,'“','',[srCase,srAll]);    //
              mString:=NxSearchReplace(mString,'Ľ','L',[srCase,srAll]);    //
              mString:=NxSearchReplace(mString,'˝','',[srCase,srAll]);    //
              mString:=NxSearchReplace(mString,'ľ','l',[srCase,srAll]);    //
              mString:=NxSearchReplace(mString,'ż','z',[srCase,srAll]);    //
              mString:=NxSearchReplace(mString,'Ŕ','R',[srCase,srAll]);    //	Velké r s čárkou
              mString:=NxSearchReplace(mString,'Â','A',[srCase,srAll]);    //	Velké a se stříškou
              mString:=NxSearchReplace(mString,'Ă','A',[srCase,srAll]);    //
              mString:=NxSearchReplace(mString,'Ä','A',[srCase,srAll]);    //	Velké přehlasované a
              mString:=NxSearchReplace(mString,'Ĺ','L',[srCase,srAll]);    //	Velké l s čárkou
              mString:=NxSearchReplace(mString,'Ć','C',[srCase,srAll]);    //	Velké c s čárkou
              mString:=NxSearchReplace(mString,'Ç','C',[srCase,srAll]);    //
              mString:=NxSearchReplace(mString,'Ę','E',[srCase,srAll]);    //
              mString:=NxSearchReplace(mString,'Ë','E',[srCase,srAll]);    //	Velké přehlasované e
              mString:=NxSearchReplace(mString,'Î','I',[srCase,srAll]);    //	Velké i se stříškou
              mString:=NxSearchReplace(mString,'Đ','D',[srCase,srAll]);    //
              mString:=NxSearchReplace(mString,'Ń','N',[srCase,srAll]);    //	Velké n s čárkou
              mString:=NxSearchReplace(mString,'Ô','O',[srCase,srAll]);    //	Velké o se stříškou
              mString:=NxSearchReplace(mString,'Ő','O',[srCase,srAll]);    //
              mString:=NxSearchReplace(mString,'Ö','O',[srCase,srAll]);    //	Velké přehlasované o
              mString:=NxSearchReplace(mString,'Ű','U',[srCase,srAll]);    //
              mString:=NxSearchReplace(mString,'Ü','U',[srCase,srAll]);    //	Velké přehlasované u
              mString:=NxSearchReplace(mString,'Ţ','T',[srCase,srAll]);    //
              mString:=NxSearchReplace(mString,'ß','B',[srCase,srAll]);    //	Ostré s
              mString:=NxSearchReplace(mString,'ŕ','r',[srCase,srAll]);    //	Malé r s čárkou
              mString:=NxSearchReplace(mString,'â','a',[srCase,srAll]);    //	Malé a se stříškou
              mString:=NxSearchReplace(mString,'ă','a',[srCase,srAll]);    //
              mString:=NxSearchReplace(mString,'ä','a',[srCase,srAll]);    //	Malé přehlasované a
              mString:=NxSearchReplace(mString,'ĺ','l',[srCase,srAll]);    //	Malé l s čárkou
              mString:=NxSearchReplace(mString,'ć','c',[srCase,srAll]);    //	Malé c s čárkou
              mString:=NxSearchReplace(mString,'ç','c',[srCase,srAll]);    //
              mString:=NxSearchReplace(mString,'ę','e',[srCase,srAll]);    //
              mString:=NxSearchReplace(mString,'ë','e',[srCase,srAll]);    //	Malé přehlasované e
              mString:=NxSearchReplace(mString,'î','i',[srCase,srAll]);    //	Malé i se stříškou
              mString:=NxSearchReplace(mString,'đ','d',[srCase,srAll]);    //
              mString:=NxSearchReplace(mString,'ń','n',[srCase,srAll]);    //	Malé n s čárkou
              mString:=NxSearchReplace(mString,'ô','o',[srCase,srAll]);    //	Malé o se stříškou
              mString:=NxSearchReplace(mString,'ő','o',[srCase,srAll]);    //
              mString:=NxSearchReplace(mString,'ö','o',[srCase,srAll]);    //	Malé přehlasované o
              mString:=NxSearchReplace(mString,'ű','u',[srCase,srAll]);    //
              mString:=NxSearchReplace(mString,'ü','u',[srCase,srAll]);    //	Malé přehlasované u
              mString:=NxSearchReplace(mString,'ţ','t',[srCase,srAll]);    //
   try
                  mString:=NxSearchReplace(mString,chr(228),'o',[srCase,srAll]);    // malé o s vlnovkou
                  mString:=NxSearchReplace(mString,chr(134),'a',[srCase,srAll]);    // malé a s kroužkem
                  mString:=NxSearchReplace(mString,chr(143),'A',[srCase,srAll]);
                  mString:=NxSearchReplace(mString,chr(186),'o',[srCase,srAll]);    // Velké O přeškrnuté
                  mString:=NxSearchReplace(mString,chr(186),'o',[srCase,srAll]);    // Velké O přeškrnuté
                  mString:=NxSearchReplace(mString,chr(241),'ň',[srCase,srAll]);    // Velké O přeškrnuté



//                  mString:=NxSearchReplace(mString,'%','',[srCase,srAll]);    // (znak procenta)
//                  mString:=NxSearchReplace(mString,'&','',[srCase,srAll]);    // (Ampersand)
//                  mString:=NxSearchReplace(mString,'?','',[srCase,srAll]);    // (Otazník)
//                  mString:=NxSearchReplace(mString,'^','',[srCase,srAll]);    // (Circumflex přízvuk nebo stříška)
//                  mString:=NxSearchReplace(mString,'¤','',[srCase,srAll]);    // (obecný znak měny)
//                  mString:=NxSearchReplace(mString,'ţ','t',[srCase,srAll]);
   finally

   end;

     result:=mString;
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

Function IsTagExist(mXMLHead : TNxScriptingXMLWrapper;mElement:string):boolean;
var
mstring:string;
begin
result:=true;
    try
          mstring:=mXMLHead.getElementAsString(mElement);
          result:=true;
    except
          result:=false;
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


function GetFirmID_TOP(os:TNxCustomObjectSpace;mXMLHead:TNxScriptingXMLWrapper;msite:TDynSiteForm;mid_county:string;mtyp_Eshopu:string):string;
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
                                OS.SQLSelect(format('SELECT ID FROM Firms A WHERE (A.Name=''%s'') AND (A.Hidden=''N'') and (A.Firm_ID is null) order by id', [TranslateUnicode((mXMLHead.getElementAsString('ABRADocument.Customer.Name')))]), mRes);      //hledám id firmy

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
                                                  // zakomentováno MASA 6.1.2026
                                                  {
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
                                                                mEdtIc.Text  := TranslateUnicode(mXMLHead.getElementAsString('ABRADocument.Customer.OrgIdentNumber'))  ;
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
                                                      mEdtName.Text := TranslateUnicode(mXMLHead.getElementAsString('ABRADocument.Customer.Name'));
                                                      mEdtName.Name := 'edtSName';
                                                      mForm.InsertControl(mEdtName);


                                                      mEdtStreet:= TEdit.Create(mForm);
                                                      mEdtStreet.Left := 80;
                                                      mEdtStreet.Top := 140;
                                                      mEdtStreet.Width := 250;
                                                      mEdtStreet.Text := TranslateUnicode(mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.Street'));
                                                      mEdtStreet.Name := 'edtSStreet';
                                                      mForm.InsertControl(mEdtStreet);


                                                      mEdtCity := TEdit.Create(mForm);
                                                      mEdtCity.Left := 80;
                                                      mEdtCity.Top := 170;
                                                      mEdtCity.Width := 250;
                                                      mEdtCity.Text := TranslateUnicode(mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.City'));
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
                                                          mLbl.Caption := (mFirm.GetFieldValueAsString('Name'))  ;
                                                          mLbl.Left := 350;
                                                          mLbl.Top := 110;
                                                          mLbl.Name := 'lblDName';
                                                          mForm.InsertControl(mLbl);


                                                          mLbl := TLabel.Create(mForm);
                                                          mLbl.Caption := (mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.GetFieldValueAsString('Street'));
                                                          mLbl.Left := 350;
                                                          mLbl.Top := 140;
                                                          mLbl.Name := 'lblDSTreet';
                                                          mForm.InsertControl(mLbl);

                                                          mLbl := TLabel.Create(mForm);
                                                          mLbl.Caption := (mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.GetFieldValueAsString('City'))   ;
                                                          mLbl.Left := 350;
                                                          mLbl.Top := 170;
                                                          mLbl.Name := 'lblDCity';
                                                          mForm.InsertControl(mLbl);

                                                          mLbl := TLabel.Create(mForm);
                                                          mLbl.Caption := (mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.GetFieldValueAsString('PostCode'))  ;
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
                                                        mI_modalresult:=mrCancel;
                                                  // end else begin
                                                  //      if mForm.ShowModal = mrOK then begin
                                                  //          mI_modalresult:=mrOk;
                                                  //      end else begin
                                                  //          mI_modalresult:=mrYes;
                                                  //      end;
                                                  //  end;

                                                 //mI_modalresult:=mBtn.ModalResult;

                                                if mI_modalresult=mrCancel then begin
                                                    result:='';
                                                    exit;
                                                end;


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
                                                 }
                                                 if true then begin
                                                     mfirm:= OS.CreateObject('4K3EXM5PQBCL35CH000ILPWJF4');
                                                    try

                                                          if mtyp_Eshopu='OPZE' then begin
                                                                mS_Code:= '0005420';
                                                          end else begin
                                                                mRes1 := TStringList.Create;
                                                                try
                                                                    OS.SQLSelect('SELECT max(code) FROM Firms A WHERE substring(Code, 1, 1)=' + quotedstr('0'), mRes1);
                                                                    //ShowMessage(mres1.Strings[0]);
                                                                    mS_code:= NxPadL(inttostr(StrToInt(copy(mres1.Strings[0],2,7))+1),7,'0');
                                                                    //ShowMessage(mS_code);
                                                                finally
                                                                    mres1.free;
                                                                end;
                                                           end;
                                                        mS_Code:= '0005420';
                                                        mFirm.New;
                                                        mFirm.Prefill;

                                                        mFirm.SetFieldValueAsString('Code', mS_Code);

                                                        mFirm.SetFieldValueAsString('Name', TranslateUnicode(copy(mXMLHead.getElementAsString('ABRADocument.Customer.Name'),1,200)));
                                                        mFirm.SetFieldValueAsString('OrgIdentNumber',copy(mXMLHead.getElementAsString('ABRADocument.Customer.OrgIdentNumber'),1,15));
                                                        mFirm.SetFieldValueAsString('VATIdentNumber', copy(mXMLHead.getElementAsString('ABRADocument.Customer.VATOrgIdentNumber'),1,20));
                                                        mFirm.SetFieldValueAsString('X_BusOrder_ID',copy(mXMLHead.getElementAsString('ABRADocument.Obchodnik'),1,10));
                                                        mFirm.SetFieldValueAsString('X_BusProject_ID', copy(mXMLHead.getElementAsString('ABRADocument.Obchod'),1,10));
                                                        mFirm.SetFieldValueAsString('ElectronicAddress_ID.EMail',mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.Email'));

                                                        mFirm.SetFieldValueAsString('ResidenceAddress_ID.X_Location',TranslateUnicode(copy(mXMLHead.getElementAsString('ABRADocument.Customer.AllName'),1,100)));
                                                        mFirm.SetFieldValueAsString('ResidenceAddress_ID.Location',(copy(mXMLHead.getElementAsString('ABRADocument.Customer.AllName'),1,100)));

                                                        mFirm.SetFieldValueAsString('ResidenceAddress_ID.PostCode',TranslateUnicode(copy(mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.PostCode'),1,9)));
                                                        mFirm.SetFieldValueAsString('ResidenceAddress_ID.X_Street',(copy(mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.Street'),1,60)));
                                                        mFirm.SetFieldValueAsString('ResidenceAddress_ID.Street',TranslateUnicode(copy(mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.Street'),1,60)));
                                                        //mFirm.SetFieldValueAsString('ResidenceAddress_ID.EMail',TranslateUnicode(copy(mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.email'),1,200)));


                                                        mFirm.SetFieldValueAsString('ResidenceAddress_ID.X_City',(copy(mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.City'),1,60)));
                                                        mFirm.SetFieldValueAsString('ResidenceAddress_ID.City',TranslateUnicode(copy(mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.City'),1,60)));

                                                        mCountryName:=getIDfromfield(os,'Name','Countries','Code',mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.CountryCode'),'Hidden','N');

                                                        mFirm.SetFieldValueAsString('ResidenceAddress_ID.Country',mcountryname);
                                                        mFirm.SetFieldValueAsString('ResidenceAddress_ID.CountryCode',mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.CountryCode'));
                                                        mFirm.SetFieldValueAsString('ResidenceAddress_ID.PhoneNumber1',mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.Tel1'));
                                                        mFirm.SetFieldValueAsString('ResidenceAddress_ID.PhoneNumber2',mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.Tel2'));
                                                        mFirm.SetFieldValueAsString('ResidenceAddress_ID.EMail',mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.email'));
                                                        mFirm.SetFieldValueAsString('ResidenceAddress_ID.X_BusProject_ID',mXMLHead.getElementAsString('ABRADocument.Obchod'));
                                                        mFirm.SetFieldValueAsString('ResidenceAddress_ID.X_BusOrder_ID',mXMLHead.getElementAsString('ABRADocument.Obchodnik'));
                                                        if (mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.CountryCode')<>'CZ') and
                                                           (mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.CountryCode')<>'') and
                                                           (mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.CountryCode')<>'SK') then begin
                                                            mFirm.SetFieldValueAsInteger('X_Stitek',1);
                                                        end else begin
                                                            mFirm.SetFieldValueAsInteger('X_Stitek',0);
                                                        end;
                                                        if (mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.CountryCode')='IT') then begin
                                                            mFirm.SetFieldValueAsInteger('X_JazykDokladu',2);
                                                        end;
                                                        if (mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.CountryCode')='US') then begin
                                                            mFirm.SetFieldValueAsInteger('X_JazykDokladu',3);
                                                        end;
                                                        if (mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.CountryCode')='FR') then begin
                                                            mFirm.SetFieldValueAsInteger('X_JazykDokladu',4);
                                                        end;
                                                        mFirm.SetFieldValueAsBoolean('X_Email_notification',true);

                                                                     //***************
                                                          if NxIsEmptyOID(mFirm.getFieldValueAsstring('X_AccRegion_ID')) then begin
                                                                case mXMLHead.getElementAsString('ABRADocument.Obchodnik') of
                                                                       '1700000101': begin
                                                                                 mFirm.SetFieldValueAsstring('X_AccRegion_ID','~000001DYV');
                                                                                 end;
                                                                       '2700000101': begin
                                                                                 mFirm.SetFieldValueAsstring('X_AccRegion_ID','~000001DYX');
                                                                                 end;
                                                                       '3G90000101': begin
                                                                                 mFirm.SetFieldValueAsString('X_AccRegion_ID','~000001DZ3');
                                                                                 end;
                                                                        '~000000201': begin
                                                                                 mFirm.SetFieldValueAsString('X_AccRegion_ID','~000001DYX');
                                                                                 end;

                                                                end;
                                                            end;






                                                        mfirm.Save;
                                                        result:=mfirm.oid;

                                                       // zakomentováno MASA 6.1.2026
                                                      //  ShowMessage('Nová firma byla založena s kódem: ' + mS_Code);
                                                       if not nxisblank(trim(mXMLHead.getElementAsString('ABRADocument.Customer.AllName'))) then begin
                                                            mfirm_office:=OS.CreateObject('AT011EZZ5DFO115YJ1HCZJDXJ4');
                                                            mr2:=tstringlist.create;
                                                            try
                                                               os.SQLSelect('select id from FirmOffices where Parent_ID=' + quotedstr(mfirm.oid),mr2);
                                                               if mr2.count>0 then begin
                                                                     if mr2.count=1 then begin
                                                                        mfirm_office.load(mr2.Strings[0],nil);
                                                                             mfirm_office.SetFieldValueAsString('Name',TranslateUnicode(trim(mXMLHead.getElementAsString('ABRADocument.Customer.AllName'))));
                                                                             mfirm_office.SetFieldValueAsString('X_code',TranslateUnicode(trim(mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'))));
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
var
mBResult:boolean;
begin
// odberatel
        if mXMLHead.getElementAsString('ABRADocument.Customer')='' then begin    // kontrolliji ID
               if mXMLHead.getElementAsString('ABRADocument.Customer.Name')<>'' then begin // kontroluji název firmy
                        os.CreateObject('4K3EXM5PQBCL35CH000ILPWJF4');
                        mRes := TStringList.Create;
                        try
                                OS.SQLSelect(format('SELECT ID FROM Firms A WHERE (Name=''%s'') AND (A.Hidden=''N'') and (Firm_ID is null) order by id', [TranslateUnicode(mXMLHead.getElementAsString('ABRADocument.Customer.Name'))]), mRes);      //hledám id firmy
                                if mRes.Count = 1 then begin       // záznam nalezen
                                       mfirm:= OS.CreateObject('4K3EXM5PQBCL35CH000ILPWJF4');
                                              mID := mRes.Strings[0];
                                              mFirm.Load(mID,nil) ;
                                              if (mFirm.GetFieldValueAsString('ResidenceAddress_ID.PostCode') = mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.PostCode')) AND
                                                (mFirm.GetFieldValueAsString('ResidenceAddress_ID.Street') = TranslateUnicode(mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.Street'))) AND
                                                (mFirm.GetFieldValueAsString('ResidenceAddress_ID.City') = TranslateUnicode(mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.City'))) then begin
                                                        result := mID;
                                                        mID_odberatel:=mID;
                                              end;

                                end;
                                if mRes.Count > 1 then begin       // záznam nalezen

                                         for ii:=0 to mRes.count-1 do begin
                                              mfirm:= OS.CreateObject('4K3EXM5PQBCL35CH000ILPWJF4');
                                              mID := mRes.Strings[ii];
                                              mFirm.Load(mID,nil) ;
                                              if (mFirm.GetFieldValueAsString('ResidenceAddress_ID.PostCode') = mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.PostCode')) AND
                                                (mFirm.GetFieldValueAsString('ResidenceAddress_ID.Street') = TranslateUnicode(mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.Street'))) AND
                                                (mFirm.GetFieldValueAsString('ResidenceAddress_ID.City') = TranslateUnicode(mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.City'))) then begin
                                                        result := mRes.Strings[ii];
                                                        mID_odberatel:=mRes.Strings[ii];
                                              end;

                                         end;

                                end;

                                 if mID_odberatel='' then begin                // zaznam neexistuje založím nový
                                        mfirm:= OS.CreateObject('4K3EXM5PQBCL35CH000ILPWJF4');
                                        try
                                                mFirm.New;
                                                mFirm.Prefill;
                                                mFirm.SetFieldValueAsString('Code', '');
                                                mFirm.SetFieldValueAsString('Code', '0005420');
                                                mFirm.SetFieldValueAsString('Name', copy(TranslateUnicode(mXMLHead.getElementAsString('ABRADocument.Customer.Name')),1,200));
                                                mFirm.SetFieldValueAsString('X_Name', copy(mXMLHead.getElementAsString('ABRADocument.Customer.Name'),1,100));
                                                mFirm.SetFieldValueAsString('OrgIdentNumber',copy(mXMLHead.getElementAsString('ABRADocument.Customer.OrgIdentNumber'),1,15));
                                                mFirm.SetFieldValueAsString('VATIdentNumber', copy(mXMLHead.getElementAsString('ABRADocument.Customer.VATOrgIdentNumber'),1,20));
                                                mFirm.SetFieldValueAsString('X_BusOrder_ID',copy(mXMLHead.getElementAsString('ABRADocument.Obchodnik'),1,10));
                                                mFirm.SetFieldValueAsString('X_BusProject_ID', copy(mXMLHead.getElementAsString('ABRADocument.Obchod'),1,20));
                                                mFirm.SetFieldValueAsString('ResidenceAddress_ID.PostCode',copy(mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.PostCode'),1,9));
                                                mFirm.SetFieldValueAsString('ResidenceAddress_ID.X_Location',copy((mXMLHead.getElementAsString('ABRADocument.Customer.AllName')),1,100));
                                                mFirm.SetFieldValueAsString('ResidenceAddress_ID.Location',copy(TranslateUnicode(mXMLHead.getElementAsString('ABRADocument.Customer.AllName')),1,100));


                                                mFirm.SetFieldValueAsString('ResidenceAddress_ID.X_Street',copy((mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.Street')),1,60));
                                                mFirm.SetFieldValueAsString('ResidenceAddress_ID.Street',copy(TranslateUnicode(mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.Street')),1,60));


                                                mFirm.SetFieldValueAsString('ResidenceAddress_ID.X_City',copy((mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.City')),1,60));
                                                mFirm.SetFieldValueAsString('ResidenceAddress_ID.City',copy(TranslateUnicode(mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.City')),1,60));

                                                mFirm.SetFieldValueAsString('ResidenceAddress_ID.CountryCode',mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.CountryCode'));
                                                mFirm.SetFieldValueAsString('ResidenceAddress_ID.PhoneNumber1',mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.Tel1'));
                                                {VK--mFirm.SetFieldValueAsString('ResidenceAddress_ID.X_BusProject',mXMLHead.getElementAsString('ABRADocument.Obchod'));
                                                mFirm.SetFieldValueAsString('ResidenceAddress_ID.X_BusOrder',mXMLHead.getElementAsString('ABRADocument.Obchodnik'));}
                                                mFirm.SetFieldValueAsString('ResidenceAddress_ID.Email',mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.Email'));


                                                mFirm.SetFieldValueAsString('ElectronicAddress_ID.EMail',mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.Email'));

                                                mCountryName:=getIDfromfield(os,'Name','Countries','Code',mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.CountryCode'),'Hidden','N');
                                                mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('Country',mCountryName);

                                               if (mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.CountryCode')<>'CZ') and
                                                           (mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.CountryCode')<>'') and
                                                           (mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.CountryCode')<>'SK') then begin
                                                            mFirm.SetFieldValueAsInteger('X_Stitek',1);
                                                        end else begin
                                                            mFirm.SetFieldValueAsInteger('X_Stitek',0);
                                                            // *************************************    oprava 15.7.2024

                                                            if (((isTagExist(mXMLHead ,'ABRADocument.Customer.DeliveryAddress.PickupPointID'))) and (mXMLHead.getElementAsString('ABRADocument.Customer.DeliveryAddress.PickupPointID')<>'')) then begin
                                                                //mStringCisloPopisne:=copy(mFirm.GetFieldValueAsString('ResidenceAddress_ID.Street'),NxAtR(' ',mFirm.GetFieldValueAsString('ResidenceAddress_ID.Street')),100);
                                                                //mFirm.SetFieldValueAsString('ResidenceAddress_ID.Street',mStringCisloPopisne);
                                                            end else begin
                                                                     mStringCisloPopisne:='';
                                                                      mStringCisloPopisne:=copy(mFirm.GetFieldValueAsString('ResidenceAddress_ID.Street'),NxAtR(' ',mFirm.GetFieldValueAsString('ResidenceAddress_ID.Street')),100);
                                                                      mStringCisloPopisne:=NxSearchReplace(mStringCisloPopisne,'/','',[srCase,srAll]);
                                                                      mStringCisloPopisne:=NxSearchReplace(mStringCisloPopisne,'\','',[srCase,srAll]);
                                                                      try
                                                                     if NxIBStrToFloat(mStringCisloPopisne)>0 then begin
                      //                                                  NxShowSimpleMessage(mStringCisloPopisne,nil);
                                                                     end else begin
                                                                           mStringCisloPopisne:=mFirm.GetFieldValueAsString('ResidenceAddress_ID.Street');
                                                                           if InputQuery('Možný problém v importu' + mXMLHead.getElementAsString('ABRADocument.ExternalNumber') , 'Adresa ' + trim(mXMLHead.getElementAsString('ABRADocument.Customer.Name')) + ' / ' +chr(10) + trim(mXMLHead.getElementAsString('ABRADocument.Customer.ResidenceAddress.Tel1'))  +' je:', mStringCisloPopisne) then begin
                                                                              mFirm.SetFieldValueAsString('ResidenceAddress_ID.Street',mStringCisloPopisne);
                                                                           end;
                                                                     end;
                                                                       finally

                                                                       end;
                                                             end;

                                                        end;

                                                mFirm.SetFieldValueAsBoolean('X_Email_notification',true);



                                                   //***************
                                                if NxIsEmptyOID(mFirm.GetFieldValueAsString('X_AccRegion_ID')) then begin
                                                      case mXMLHead.getElementAsString('ABRADocument.Obchodnik') of
                                                             '1700000101': begin
                                                                       mFirm.SetFieldValueAsString('X_AccRegion_ID','~000001DYV');
                                                                       end;
                                                             '2700000101': begin
                                                                       mFirm.SetFieldValueAsString('X_AccRegion_ID','~000001DYX');
                                                                       end;
                                                             '3G90000101': begin
                                                                       mFirm.SetFieldValueAsString('X_AccRegion_ID','~000001DZ3');
                                                                       end;

                                                      end;
                                                  end;


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
                                                                             mfirm_office.SetFieldValueAsString('Name',TranslateUnicode(trim(mXMLHead.getElementAsString('ABRADocument.Customer.AllName'))));
                                                                             mfirm_office.SetFieldValueAsString('X_code',TranslateUnicode(trim(mXMLHead.getElementAsString('ABRADocument.Customer.FirmOffice'))));
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