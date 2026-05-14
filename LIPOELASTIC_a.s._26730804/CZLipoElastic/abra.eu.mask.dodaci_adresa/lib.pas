 Var
  mSite : TDynSiteForm;
  i,ii : integer;
  maddress: TNxCustomBusinessObject;
   mForm : TForm;
  mBtn : TButton;
  mLbl : TLabel;
  mEdtIC,mEdtPCP, mEdtDIC,mEdtName,mEdtStreet,mEdtCity,mEdtPostCode,mEdtCountry, mEdtTel1, mEdtLoc : TEdit;
  mI_modalresult:integer;
  mS_code:string;


function  Mformx(xSite:TSiteForm;mLabel:string;mDescription:string;mbuton1:string;mbuton2:string;mbuton3:string;mbuton4:string):Variant;
var
mform:tform;
mBtn : TButton;
mlabel2:TLabel;
begin
            mForm := TForm.Create(xsite);
                                  mForm.Caption := mLabel;
                                  mForm.FormStyle := fsStayOnTop;
                                  mForm.BorderStyle := bsDialog;
                                  mForm.Width := 420;
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
                                      mBtn.ModalResult := mrOk;
                                      mBtn.Cancel := False;
                                      mBtn.Default := True;
                                      mBtn.Left :=  mForm.Width - 4*(mBtn.Width+2) - 20;
                                      mBtn.Top := mForm.Height - mBtn.Height - 40;
                                      mBtn.Name := 'btnOK';
                                      mForm.InsertControl(mBtn);
                                end;

                                if not NxIsBlank(mbuton2) then begin
                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := 90;
                                    mBtn.Height := 25;
                                    mBtn.Caption := mbuton2;
                                    mBtn.ModalResult := mrYes;
                                    mBtn.Cancel := False;
                                    mBtn.Default := True;
                                    mBtn.Left :=  mForm.Width - 3*(mBtn.Width+2) - 20;
                                    mBtn.Top := mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'btnyes';
                                    mForm.InsertControl(mBtn);
                                end;

                                if not NxIsBlank(mbuton3) then begin
                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := 90;
                                    mBtn.Height := 25;
                                    mBtn.Caption := mbuton3;
                                    mBtn.ModalResult := mrCancel;
                                    mBtn.Cancel := False;
                                    mBtn.Default := True;
                                    mBtn.Left :=  mForm.Width - 2*(mBtn.Width+2) - 20;
                                    mBtn.Top := mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'btnCancel';
                                    mForm.InsertControl(mBtn);
                                    end;
                                if not NxIsBlank(mbuton4) then begin
                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := 90;
                                    mBtn.Height := 25;
                                    mBtn.Caption := mbuton4;
                                    mBtn.ModalResult := mrIgnore;
                                    mBtn.Cancel := True;
                                    mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;;
                                    mBtn.Top := mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'btnIgnore';
                                    mForm.InsertControl(mBtn);

                                end;

                                result:=mForm.ShowModal(xSite)



end;



function GetDelivery_adress(msite:TDynSiteForm;mid_adress:string):string;
var
mresult:boolean;
mEdtCountryCode:TEdit;
mBO_adress:TNxCustomBusinessObject;
mI_Result:integer;
begin
                                       mBO_adress:= msite.BaseObjectSpace.CreateObject('4C3EXM5PQBCL35CH000ILPWJF4');
                                           try
                                              if NxIsEmptyOID(mid_adress) then begin
                                                     mBO_adress.new;
                                                     mBO_adress.Prefill;
                                              end else begin
                                                  mBO_adress.Load(mid_adress,nil) ;
                                              end;

                                                mForm := TForm.Create(nil);
                                                try
                                                      mForm.Width := 400;  // sirka
                                                      mForm.Height := 350; // vyska - dopočítívá se na závěr
                                                      mForm.Caption := 'Kontrola adres';

                                                      mLbl := TLabel.Create(mForm);
                                                      mLbl.Caption := 'Údaj'  ;
                                                      mLbl.Left := 20;
                                                      mLbl.Top := 20;
                                                      mLbl.Name := 'lblPopis';
                                                      mForm.InsertControl(mLbl);

                                                      mLbl := TLabel.Create(mForm);
                                                      mLbl.Caption := 'PickUp point'  ;
                                                      mLbl.Left := 150;
                                                      mLbl.Top := 50;
                                                      mLbl.Name := 'lblPCP';
                                                      mForm.InsertControl(mLbl);


                                                      mLbl := TLabel.Create(mForm);
                                                      mLbl.Caption := 'IČ'  ;
                                                      mLbl.Left := 20;
                                                      mLbl.Top := 50;
                                                      mLbl.Name := 'lblIco';
                                                      mForm.InsertControl(mLbl);

                                                      mLbl := TLabel.Create(mForm);
                                                      mLbl.Caption := 'Jméno:'  ;
                                                      mLbl.Left := 20;
                                                      mLbl.Top := 80;
                                                      mLbl.Name := 'lblName';
                                                      mForm.InsertControl(mLbl);

                                                      mLbl := TLabel.Create(mForm);
                                                      mLbl.Caption := 'Doplň.údaj:'  ;
                                                      mLbl.Left := 20;
                                                      mLbl.Top := 110;
                                                      mLbl.Name := 'lblLoc';
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
                                                      mLbl.Caption := 'Telefon:'  ;
                                                      mLbl.Left := 20;
                                                      mLbl.Top := 260;
                                                      mLbl.Name := 'lblTel1';
                                                      mForm.InsertControl(mLbl);

                                                      mLbl := TLabel.Create(mForm);
                                                      mLbl.Caption := 'Dodací adresa:'  ;
                                                      mLbl.Left := 80;
                                                      mLbl.Top := 20;
                                                      mLbl.Name := 'lblImp_popis';
                                                      mForm.InsertControl(mLbl);



                                                      mEdtPCP := TEdit.Create(mForm);
                                                      mEdtPCP.Left := 220;
                                                      mEdtPCP.Top := 50;
                                                      mEdtPCP.Width := 120;
                                                      if mBO_adress.GetFieldValueAsString('X_PickupPoint')='' then mEdtPCP.Text :='' else mEdtPCP.Text := mBO_adress.GetFieldValueAsString('X_PickupPoint');
                                                      mEdtPCP.Name := '';
                                                      mForm.InsertControl(mEdtPCP);



                                                      mEdtName := TEdit.Create(mForm);
                                                      mEdtName.Left := 80;
                                                      mEdtName.Top := 80;
                                                      mEdtName.Width := 250;
                                                      if mBO_adress.GetFieldValueAsString('Recipient')='' then mEdtName.Text :='' else mEdtName.Text := mBO_adress.GetFieldValueAsString('Recipient');
                                                      mEdtName.Name := '';
                                                      mForm.InsertControl(mEdtName);

                                                      mEdtLoc := TEdit.Create(mForm);
                                                      mEdtLoc.Left := 80;
                                                      mEdtLoc.Top := 110;
                                                      mEdtLoc.Width := 250;
                                                      if mBO_adress.GetFieldValueAsString('Location')='' then mEdtLoc.Text :='' else mEdtLoc.Text := mBO_adress.GetFieldValueAsString('Location');
                                                      mEdtLoc.Name := '';
                                                      mForm.InsertControl(mEdtLoc);

                                                      mEdtStreet:= TEdit.Create(mForm);
                                                      mEdtStreet.Left := 80;
                                                      mEdtStreet.Top := 140;
                                                      mEdtStreet.Width := 250;
                                                      if mBO_adress.GetFieldValueAsString('Street')='' then mEdtStreet.Text :='' else mEdtStreet.Text := mBO_adress.GetFieldValueAsString('Street');
                                                      mEdtStreet.Name := '';
                                                      mForm.InsertControl(mEdtStreet);


                                                      mEdtCity := TEdit.Create(mForm);
                                                      mEdtCity.Left := 80;
                                                      mEdtCity.Top := 170;
                                                      mEdtCity.Width := 250;
                                                      if mBO_adress.GetFieldValueAsString('City')='' then mEdtCity.Text :='' else mEdtCity.Text := mBO_adress.GetFieldValueAsString('City');
                                                      mEdtCity.Name := '';
                                                      mForm.InsertControl(mEdtCity);

                                                      mEdtPostCode := TEdit.Create(mForm);
                                                      mEdtPostCode.Left := 80;
                                                      mEdtPostCode.Top := 200;
                                                      mEdtPostCode.Width := 100;
                                                      if mBO_adress.GetFieldValueAsString('Postcode')='' then mEdtPostCode.Text :='' else mEdtPostCode.Text := mBO_adress.GetFieldValueAsString('Postcode');
                                                      mEdtPostCode.Name := '';
                                                      mForm.InsertControl(mEdtPostCode);

                                                      mEdtCountryCode := TEdit.Create(mForm);
                                                      mEdtCountryCode.Left := 80;
                                                      mEdtCountryCode.Top := 230;
                                                      mEdtCountryCode.Width := 100;
                                                      if mBO_adress.GetFieldValueAsString('CountryCode')='' then mEdtCountryCode.Text :='' else mEdtCountryCode.Text := mBO_adress.GetFieldValueAsString('CountryCode');
                                                      mEdtCountryCode.Name := '';
                                                      mForm.InsertControl(mEdtCountryCode);

                                                      mEdtTel1 := TEdit.Create(mForm);
                                                      mEdtTel1.Left := 80;
                                                      mEdtTel1.Top := 260;
                                                      mEdtTel1.Width := 100;
                                                      if mBO_adress.GetFieldValueAsString('PhoneNumber1')='' then mEdtTel1.Text :='' else mEdtTel1.Text := mBO_adress.GetFieldValueAsString('PhoneNumber1');
                                                      mEdtTel1.Name := '';
                                                      mForm.InsertControl(mEdtTel1);

                                                      mBtn := TButton.Create(mForm);
                                                      mBtn.Width := 75;
                                                      mBtn.Height := 25;
                                                      mBtn.Caption := 'Upravit';
                                                      mBtn.Left := 120;
                                                      mBtn.Top := mForm.Height - mBtn.Height - 35;
                                                      mBtn.Visible := True;
                                                      mBtn.ModalResult := mrYes;
                                                      mBtn.Default := True;
                                                      mBtn.Cancel := False;
                                                      mBtn.Name := 'btnyes';
                                                      mForm.InsertControl(mBtn);

                                                      mBtn := TButton.Create(mForm);
                                                      mBtn.Width := 75;
                                                      mBtn.Height := 25;
                                                      mBtn.Caption := 'Zrušit změny';
                                                      mBtn.Left := 220;
                                                      mBtn.Top := mForm.Height - mBtn.Height - 35;
                                                      mBtn.Visible := True;
                                                      mBtn.ModalResult := mrCancel;
                                                      mBtn.Cancel := True;
                                                      mBtn.Name := 'btnCancel';
                                                      mForm.InsertControl(mBtn);

                                                      mI_modalresult:=mForm.ShowModal(msite) ;


                                                if mI_modalresult=mrYes then begin                  // použit

                                                    mBO_adress.setFieldValueAsString('Recipient',mEdtName.Text) ;
                                                    mBO_adress.setFieldValueAsString('X_PickupPoint',mEdtPCP.Text) ;
                                                    mBO_adress.setFieldValueAsString('Location',mEdtLoc.Text) ;
                                                    mBO_adress.setFieldValueAsString('Street',mEdtStreet.Text) ;
                                                    mBO_adress.setFieldValueAsString('City',mEdtCity.Text) ;
                                                    mBO_adress.setFieldValueAsString('Postcode',mEdtPostCode.Text) ;
                                                    mBO_adress.setFieldValueAsString('CountryCode',mEdtCountryCode.Text) ;
                                                    mBO_adress.setFieldValueAsString('PhoneNumber1',mEdtTel1.Text) ;
                                                    mBO_adress.save;

                                                    result:=mBO_adress.oid;

                                                    {
                                                     mI_Result:=Mformx(msite,'Potvrzení','Doplnění adress', 'Uložit','','','Zrušit');
                                                          if (mI_Result=1)  then begin
                                                              result:=mBO_adress.oid;
                                                          end;
                                                          if (mI_Result=5)  then begin
                                                               result:='';
                                                               exit;
                                                          end;
                                                   //ShowMessage(inttostr(mI_modalresult));   }
                                                end;

                                                if mI_modalresult=mrCancel then begin              // zruš přenos
                                                   result:='';
                                                   ShowMessage('Změny byly zrušeny uživatelem');
                                                   exit;
                                                end;

                                              finally
                                                mForm.Free;
                                                end;
                        finally
                                mBO_adress.Free;
                        end;
end;






function GetStitek(msite:TDynSiteForm;mid_adress:string;mLabel:string;mDescription:string;mbuton1:string;mbuton2:string;mbuton3:string;mbuton4:string):string;
var
mresult:boolean;
mEdtCountryCode:TEdit;
mBO_adress:TNxCustomBusinessObject;
mI_Result:integer;
begin
                                       mBO_adress:= msite.BaseObjectSpace.CreateObject('4C3EXM5PQBCL35CH000ILPWJF4');
                                           try
                                              if NxIsEmptyOID(mid_adress) then begin
                                                     mBO_adress.new;
                                                     mBO_adress.Prefill;
                                              end else begin
                                                  mBO_adress.Load(mid_adress,nil) ;
                                              end;

                                                mForm := TForm.Create(nil);
                                                try
                                                      mForm.Width := 400;  // sirka
                                                      mForm.Height := 350; // vyska - dopočítívá se na závěr
                                                      mForm.Caption := 'Položky na štítku';

                                                      mLbl := TLabel.Create(mForm);
                                                      mLbl.Caption := 'Údaj'  ;
                                                      mLbl.Left := 20;
                                                      mLbl.Top := 20;
                                                      mLbl.Name := 'lblPopis';
                                                      mForm.InsertControl(mLbl);

                                                      mLbl := TLabel.Create(mForm);
                                                      mLbl.Caption := 'PickUp point'  ;
                                                      mLbl.Left := 150;
                                                      mLbl.Top := 50;
                                                      mLbl.Name := 'lblPCP';
                                                      mForm.InsertControl(mLbl);


                                                      mLbl := TLabel.Create(mForm);
                                                      mLbl.Caption := 'IČ'  ;
                                                      mLbl.Left := 20;
                                                      mLbl.Top := 50;
                                                      mLbl.Name := 'lblIco';
                                                      mForm.InsertControl(mLbl);

                                                      mLbl := TLabel.Create(mForm);
                                                      mLbl.Caption := 'Jméno:'  ;
                                                      mLbl.Left := 20;
                                                      mLbl.Top := 80;
                                                      mLbl.Name := 'lblName';
                                                      mForm.InsertControl(mLbl);

                                                      mLbl := TLabel.Create(mForm);
                                                      mLbl.Caption := 'Doplň.údaj:'  ;
                                                      mLbl.Left := 20;
                                                      mLbl.Top := 110;
                                                      mLbl.Name := 'lblLoc';
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
                                                      mLbl.Caption := 'Telefon:'  ;
                                                      mLbl.Left := 20;
                                                      mLbl.Top := 260;
                                                      mLbl.Name := 'lblTel1';
                                                      mForm.InsertControl(mLbl);

                                                      mLbl := TLabel.Create(mForm);
                                                      mLbl.Caption := 'Dodací adresa:'  ;
                                                      mLbl.Left := 80;
                                                      mLbl.Top := 20;
                                                      mLbl.Name := 'lblImp_popis';
                                                      mForm.InsertControl(mLbl);



                                                      mEdtPCP := TEdit.Create(mForm);
                                                      mEdtPCP.Left := 220;
                                                      mEdtPCP.Top := 50;
                                                      mEdtPCP.Width := 120;
                                                      if mBO_adress.GetFieldValueAsString('X_PickupPoint')='' then mEdtPCP.Text :='' else mEdtPCP.Text := mBO_adress.GetFieldValueAsString('X_PickupPoint');
                                                      mEdtPCP.Name := '';
                                                      mForm.InsertControl(mEdtPCP);



                                                      mEdtName := TEdit.Create(mForm);
                                                      mEdtName.Left := 80;
                                                      mEdtName.Top := 80;
                                                      mEdtName.Width := 250;
                                                      if mBO_adress.GetFieldValueAsString('Recipient')='' then mEdtName.Text :='' else mEdtName.Text := mBO_adress.GetFieldValueAsString('Recipient');
                                                      mEdtName.Name := '';
                                                      mForm.InsertControl(mEdtName);

                                                      mEdtLoc := TEdit.Create(mForm);
                                                      mEdtLoc.Left := 80;
                                                      mEdtLoc.Top := 110;
                                                      mEdtLoc.Width := 250;
                                                      if mBO_adress.GetFieldValueAsString('Location')='' then mEdtLoc.Text :='' else mEdtLoc.Text := mBO_adress.GetFieldValueAsString('Location');
                                                      mEdtLoc.Name := '';
                                                      mForm.InsertControl(mEdtLoc);

                                                      mEdtStreet:= TEdit.Create(mForm);
                                                      mEdtStreet.Left := 80;
                                                      mEdtStreet.Top := 140;
                                                      mEdtStreet.Width := 250;
                                                      if mBO_adress.GetFieldValueAsString('Street')='' then mEdtStreet.Text :='' else mEdtStreet.Text := mBO_adress.GetFieldValueAsString('Street');
                                                      mEdtStreet.Name := '';
                                                      mForm.InsertControl(mEdtStreet);


                                                      mEdtCity := TEdit.Create(mForm);
                                                      mEdtCity.Left := 80;
                                                      mEdtCity.Top := 170;
                                                      mEdtCity.Width := 250;
                                                      if mBO_adress.GetFieldValueAsString('City')='' then mEdtCity.Text :='' else mEdtCity.Text := mBO_adress.GetFieldValueAsString('City');
                                                      mEdtCity.Name := '';
                                                      mForm.InsertControl(mEdtCity);

                                                      mEdtPostCode := TEdit.Create(mForm);
                                                      mEdtPostCode.Left := 80;
                                                      mEdtPostCode.Top := 200;
                                                      mEdtPostCode.Width := 100;
                                                      if mBO_adress.GetFieldValueAsString('Postcode')='' then mEdtPostCode.Text :='' else mEdtPostCode.Text := mBO_adress.GetFieldValueAsString('Postcode');
                                                      mEdtPostCode.Name := '';
                                                      mForm.InsertControl(mEdtPostCode);

                                                      mEdtCountryCode := TEdit.Create(mForm);
                                                      mEdtCountryCode.Left := 80;
                                                      mEdtCountryCode.Top := 230;
                                                      mEdtCountryCode.Width := 100;
                                                      if mBO_adress.GetFieldValueAsString('CountryCode')='' then mEdtCountryCode.Text :='' else mEdtCountryCode.Text := mBO_adress.GetFieldValueAsString('CountryCode');
                                                      mEdtCountryCode.Name := '';
                                                      mForm.InsertControl(mEdtCountryCode);

                                                      mEdtTel1 := TEdit.Create(mForm);
                                                      mEdtTel1.Left := 80;
                                                      mEdtTel1.Top := 260;
                                                      mEdtTel1.Width := 100;
                                                      if mBO_adress.GetFieldValueAsString('PhoneNumber1')='' then mEdtTel1.Text :='' else mEdtTel1.Text := mBO_adress.GetFieldValueAsString('PhoneNumber1');
                                                      mEdtTel1.Name := '';
                                                      mForm.InsertControl(mEdtTel1);





                               if not NxIsBlank(mbuton1) then begin
                                      mBtn := TButton.Create(mForm);
                                      mBtn.Width := 90;
                                      mBtn.Height := 25;
                                      mBtn.Caption := mbuton1;
                                      mBtn.ModalResult := mrOk;
                                      mBtn.Cancel := False;
                                      mBtn.Default := True;
                                      mBtn.Left :=  mForm.Width - 4*(mBtn.Width+2) - 20;
                                      mBtn.Top := mForm.Height - mBtn.Height - 40;
                                      mBtn.Name := 'btnOK';
                                      mForm.InsertControl(mBtn);

                                end;

                                if not NxIsBlank(mbuton2) then begin
                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := 90;
                                    mBtn.Height := 25;
                                    mBtn.Caption := mbuton2;
                                    mBtn.ModalResult := mrYes;
                                    mBtn.Cancel := False;
                                    mBtn.Default := True;
                                    mBtn.Left :=  mForm.Width - 3*(mBtn.Width+2) - 20;
                                    mBtn.Top := mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'btnyes';
                                    mForm.InsertControl(mBtn);
                                end;

                                if not NxIsBlank(mbuton3) then begin
                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := 90;
                                    mBtn.Height := 25;
                                    mBtn.Caption := mbuton3;
                                    mBtn.ModalResult := mrCancel;
                                    mBtn.Cancel := False;
                                    mBtn.Default := True;
                                    mBtn.Left :=  mForm.Width - 2*(mBtn.Width+2) - 20;
                                    mBtn.Top := mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'btnCancel';
                                    mForm.InsertControl(mBtn);
                                    end;
                                if not NxIsBlank(mbuton4) then begin
                                    mBtn := TButton.Create(mForm);
                                    mBtn.Width := 90;
                                    mBtn.Height := 25;
                                    mBtn.Caption := mbuton4;
                                    mBtn.ModalResult := mrIgnore;
                                    mBtn.Cancel := True;
                                    mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;;
                                    mBtn.Top := mForm.Height - mBtn.Height - 40;
                                    mBtn.Name := 'btnIgnore';
                                    mForm.InsertControl(mBtn);

                                end;


                                                      mI_modalresult:=mForm.ShowModal(msite) ;


                                                if mI_modalresult=mrYes then begin                  // použit

                                                    mBO_adress.setFieldValueAsString('Recipient',mEdtName.Text) ;
                                                    mBO_adress.setFieldValueAsString('X_PickupPoint',mEdtPCP.Text) ;
                                                    mBO_adress.setFieldValueAsString('Location',mEdtLoc.Text) ;
                                                    mBO_adress.setFieldValueAsString('Street',mEdtStreet.Text) ;
                                                    mBO_adress.setFieldValueAsString('City',mEdtCity.Text) ;
                                                    mBO_adress.setFieldValueAsString('Postcode',mEdtPostCode.Text) ;
                                                    mBO_adress.setFieldValueAsString('CountryCode',mEdtCountryCode.Text) ;
                                                    mBO_adress.setFieldValueAsString('PhoneNumber1',mEdtTel1.Text) ;
                                                    mBO_adress.save;

                                                    result:=mBO_adress.oid;

                                                    {
                                                     mI_Result:=Mformx(msite,'Potvrzení','Doplnění adress', 'Uložit','','','Zrušit');
                                                          if (mI_Result=1)  then begin
                                                              result:=mBO_adress.oid;
                                                          end;
                                                          if (mI_Result=5)  then begin
                                                               result:='';
                                                               exit;
                                                          end;
                                                   //ShowMessage(inttostr(mI_modalresult));   }
                                                end;

                                                if mI_modalresult=mrCancel then begin              // zruš přenos
                                                   result:='';
                                                   ShowMessage('Změny byly zrušeny uživatelem');
                                                   exit;
                                                end;

                                              finally
                                                mForm.Free;
                                                end;
                        finally
                                mBO_adress.Free;
                        end;
end;


begin
end.