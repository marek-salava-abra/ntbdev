const
mstav=15;

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

function iSelectSP(AOLE: Variant) : TNxOID;
var
  mRoll4 : variant;
  mXX4 : string;
begin
  Result := '';
  mXX4 := '0000000000';
  mRoll4 := AOLE.GetRoll('5315B3YAPMNOB0FIRUCLXSJ52O', 0);
  Result := mRoll4.SelectDialog2(False, mXX4);
end;

function iSelectFirm(AOLE: Variant) : TNxOID;
var
  mRoll4 : variant;
  mXX4 : string;
begin
  Result := '';
  mXX4 := '0000000000';
  mRoll4 := AOLE.GetRoll('O3OWQQYWYJCL3J0B01K0LEIOE0', 0);
  Result := mRoll4.SelectDialog2(False, mXX4);
end;

function iSelectPerson(AOLE: Variant) : TNxOID;
var
  mRoll4 : variant;
  mXX4 : string;
begin
  Result := '';
  mXX4 := '0000000000';
  mRoll4 := AOLE.GetRoll('K1MQ4TFKGJD13E3C01K0LEIOE0', 0);
  Result := mRoll4.SelectDialog2(False, mXX4);
end;

function iSelectVyrobce(AOLE: Variant) : TNxOID;
var
  mRoll4 : variant;
  mXX4 : string;
begin
  Result := '';
  mXX4 := '0000000000';
  mRoll4 := AOLE.GetRoll('JQFREQ2PSRR4JCMPNFHSFR4CUW', 0);
  Result := mRoll4.SelectDialog2(False, mXX4);
end;
function iSelectZarizeni(AOLE: Variant) : TNxOID;
var
  mRoll4 : variant;
  mXX4 : string;
begin
  Result := '';
  mXX4 := '0000000000';
  mRoll4 := AOLE.GetRoll('5315B3YAPMNOB0FIRUCLXSJ52O', 0);
  Result := mRoll4.SelectDialog2(False, mXX4);
end;
function iSelectDruh_zarizeni(AOLE: Variant) : TNxOID;
var
  mRoll4 : variant;
  mXX4 : string;
begin
  Result := '';
  mXX4 := '0000000000';
  mRoll4 := AOLE.GetRoll('OK0LLHL0N3XOZAY32NMT53J5CS', 0);
  Result := mRoll4.SelectDialog2(False, mXX4);
end;

function iSelectZakaznik(AOLE: Variant) : TNxOID;
var
  mRoll4 : variant;
  mXX4 : string;
begin
  Result := '';
  mXX4 := '0000000000';
  mRoll4 := AOLE.GetRoll('BTYHA5DHLTDO14H21XNZM2CPIK', 0);
  Result := mRoll4.SelectDialog2(False, mXX4);
end;

function iSelectOpravovana_cast(AOLE: Variant) : TNxOID;
var
  mRoll4 : variant;
  mXX4 : string;
begin
  Result := '';
  mXX4 := '0000000000';
  mRoll4 := AOLE.GetRoll('OUEB4BJORIN45JPJNHBQJKNPEO', 0);
  Result := mRoll4.SelectDialog2(False, mXX4);
end;

function iSelectPricina_poruchy(AOLE: Variant) : TNxOID;
var
  mRoll4 : variant;
  mXX4 : string;
begin
  Result := '';
  mXX4 := '0000000000';
  mRoll4 := AOLE.GetRoll('TTZJ1YL0TITOBATZ1LP5DR4JL0', 0);
  Result := mRoll4.SelectDialog2(False, mXX4);
end;
function iSelectTyp_poruchy(AOLE: Variant) : TNxOID;
var
  mRoll4 : variant;
  mXX4 : string;
begin
  Result := '';
  mXX4 := '0000000000';
  mRoll4 := AOLE.GetRoll('PKBMVIW4APGOFFSRJ5VDZWLPAG', 0);
  Result := mRoll4.SelectDialog2(False, mXX4);
end;


begin
end.