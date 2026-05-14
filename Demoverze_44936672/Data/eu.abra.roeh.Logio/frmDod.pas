uses 'eu.abra.roeh.Logio.Lib';
var
aIdFirm : string;

procedure spDodavetelClick(Sender: TObject);
var
  mOLE, mRoll,mStr: Variant;
  mControl: TControl;
begin
  mOLE := GetAbraOLEApplication;
  mRoll := mOLE.GetRoll('O3OWQQYWYJCL3J0B01K0LEIOE0', 0);
  aIdFirm := mRoll.SelectDialog2(True, aIdFirm);
  if trim(aIdFirm) = '' then Exit;
  mControl := TSpeedButton(Sender).Parent.FindChildControl('edDodavatel');
  mStr := mOle.CreateStrings;
  mOle.SqlSelect('select name from firms where id =''' + aIDFirm + '''',mStr);
 if mStr.Count = 0 then TEdit(mControl).Text := ''
  else TEdit(mControl).Text := mStr.Strings[0];
end;

procedure ClearDoDemand(mBoDod:TNxCustomBusinessObject);
var
  mStr : TStringList;
  mSup: TNxCustomBusinessObject;
  N : Integer;
begin
  mSup := mBoDod.ObjectSpace.CreateObject(Class_Supplier);
  try
    mStr := TStringList.Create;
    try
      mSup.ObjectSpace.SQLSelect('select id from Suppliers where DoDemand= ''A'' and StoreCard_ID=''' + mBoDod.GetFieldValueAsString('StoreCard_id')+'''',mStr);
      for N := 0 to mStr.Count -1 do begin
        if mStr.Strings(N) <> mBoDod.OID then begin
          mSup.Load(mStr.Strings(N), nil);
          mSup.SetFieldValueAsBoolean('DoDemand',false);
          mSup.Save;
        end;
      end;
    finally
      mStr.free;
    end;
  finally
    mSup.Free;
  end;
end;


procedure ShowFrmDoda(mySiteFrm: TSiteForm; mIDs: TStringList);
var
  frmDodavat: TForm;
  spDodavetel: TSpeedButton;
  lbl1: TLabel;
  lblUnit: TLabel;
  Label1: TLabel;
  Label2: TLabel;
  Label3: TLabel;
  Label4: TLabel;
  edDodavatel: TEdit;
  edDodDoba: TNumEdit;{TNumEdit;}
  edUnit: TEdit;
  cbDodDoba: TCheckBox;
  cbUnit: TCheckBox;
  edPacking: TNumEdit;{TNumEdit;}
  cbPacking: TCheckBox;
  edCountPack: TNumEdit;{TNumEdit;}
  cbCountPack: TCheckBox;
  edPeriodOrder: TNumEdit;{TNumEdit;}
  cbPeriodOrder: TCheckBox;
  edErrDeliv: TNumEdit;{TNumEdit;}
  cbErrDeliv: TCheckBox;
  btnStorno: TButton;
  btnOK: TButton;
  
  mBoStoreCard, mBoDod : TNxCustomBusinessObject;
  mDodav_ID :string;
  N : Integer;
  mRollShare : Boolean;
  mF : TForm;
  mPB : TProgressBar;

begin
  aIdFirm := '';
  frmDodavat := TForm.Create(mySiteFrm);
  try
    spDodavetel := {TSpeedButton.}TSpeedButton.Create(frmDodavat);
    lbl1 := TLabel.Create(frmDodavat);
    lblUnit := TLabel.Create(frmDodavat);
    Label1 := TLabel.Create(frmDodavat);
    Label2 := TLabel.Create(frmDodavat);
    Label3 := TLabel.Create(frmDodavat);
    Label4 := TLabel.Create(frmDodavat);
    edDodavatel := TEdit.Create(frmDodavat);
    edDodDoba := {TNumEdit}TNumEdit.Create(frmDodavat);
    edUnit := TEdit.Create(frmDodavat);
    cbDodDoba := TCheckBox.Create(frmDodavat);
    cbUnit := TCheckBox.Create(frmDodavat);
    edPacking := {TNumEdit}TNumEdit.Create(frmDodavat);
    cbPacking := TCheckBox.Create(frmDodavat);
    edCountPack := {TNumEdit}TNumEdit.Create(frmDodavat);
    cbCountPack := TCheckBox.Create(frmDodavat);
    edPeriodOrder := {TNumEdit}TNumEdit.Create(frmDodavat);
    cbPeriodOrder := TCheckBox.Create(frmDodavat);
    edErrDeliv := {TNumEdit}TNumEdit.Create(frmDodavat);
    cbErrDeliv := TCheckBox.Create(frmDodavat);
    btnStorno := TButton.Create(frmDodavat);
    btnOK := TButton.Create(frmDodavat);
    with frmDodavat do
    begin
      Name := 'frmDodavat';
      Left := 427;
      Top := 200;
      BorderStyle := bsDialog;
      Caption := 'Nastavení dodavatele';
      ClientHeight := 252;
      ClientWidth := 280;
      Color := clBtnFace;
      OldCreateOrder := False;
      Position := poScreenCenter;
      PixelsPerInch := 96;
    end;
    with spDodavetel do
    begin
      Name := 'spDodavetel';
      Parent := frmDodavat;
      Left := 8;
      Top := 16;
      Width := 23;
      Height := 22;
      Caption := '...';
      OnClick := @spDodavetelClick;
    end;
    with lbl1 do
    begin
      Name := 'lbl1';
      Parent := frmDodavat;
      Left := 8;
      Top := 48;
      Width := 65;
      Height := 13;
      Caption := 'Dodací doba:';
    end;
    with lblUnit do
    begin
      Name := 'lblUnit';
      Parent := frmDodavat;
      Left := 8;
      Top := 72;
      Width := 47;
      Height := 13;
      Caption := 'Jednotka:';
    end;
    with Label1 do
    begin
      Name := 'Label1';
      Parent := frmDodavat;
      Left := 8;
      Top := 96;
      Width := 68;
      Height := 13;
      Caption := 'Kusů v balení:';
    end;
    with Label2 do
    begin
      Name := 'Label2';
      Parent := frmDodavat;
      Left := 8;
      Top := 120;
      Width := 63;
      Height := 13;
      Caption := 'Počet bal.:';
    end;
    with Label3 do
    begin
      Name := 'Label3';
      Parent := frmDodavat;
      Left := 8;
      Top := 144;
      Width := 59;
      Height := 13;
      Caption := 'Perioda obj.:';
    end;
    with Label4 do
    begin
      Name := 'Label4';
      Parent := frmDodavat;
      Left := 8;
      Top := 168;
      Width := 72;
      Height := 13;
      Caption := 'Odchylka dod.:';
    end;
    with edDodavatel do
    begin
      Name := 'edDodavatel';
      Parent := frmDodavat;
      Left := 56;
      Top := 16;
      Width := 209;
      Height := 21;
      ReadOnly := True;
      TabOrder := 0;
      Text:='';
    end;
    with edDodDoba do
    begin
      Name := 'edDodDoba';
      Parent := frmDodavat;
      Left := 95;
      Top := 48;
      Width := 49;
      Height := 21;
      TabOrder := 2;
      Value := 0;
      DecimalPlaces := 0;
      //DisplayFormat := '0';
    end;
    with cbDodDoba do
    begin
      Name := 'cbDodDoba';
      Parent := frmDodavat;
      Left := 165;
      Top := 48;
      Width := 97;
      Height := 17;
      Caption := 'Dodací doba';
      Checked := True;
      State := cbChecked;
      TabOrder := 3;
    end;
    with edUnit do
    begin
      Name := 'edUnit';
      Parent := frmDodavat;
      Left := 95;
      Top := 72;
      Width := 49;
      Height := 21;
      TabOrder := 1;
      Text := '';
    end;
    with cbUnit do
    begin
      Name := 'cbJednotka';
      Parent := frmDodavat;
      Left := 165;
      Top := 72;
      Width := 81;
      Height := 17;
      Caption := 'Jednotka';
      TabOrder := 4;
    end;
    with edPacking do
    begin
      Name := 'edPacking';
      Parent := frmDodavat;
      Left := 95;
      Top := 96;
      Width := 49;
      Height := 21;
      TabOrder := 5;
      Value := 0;
      DecimalPlaces := 0;
      //DisplayFormat := '0';
    end;
    with cbPacking do
    begin
      Name := 'cbPacking';
      Parent := frmDodavat;
      Left := 165;
      Top := 96;
      Width := 105;
      Height := 17;
      Caption := 'Kusů v balení';
      TabOrder := 6;
    end;
    with edCountPack do
    begin
      Name := 'edCountPack';
      Parent := frmDodavat;
      Left := 95;
      Top := 120;
      Width := 49;
      Height := 21;
      TabOrder := 7;
      Value := 1;
      DecimalPlaces := 0;
      //DisplayFormat := '0';
    end;
    with cbCountPack do
    begin
      Name := 'cbCountPack';
      Parent := frmDodavat;
      Left := 165;
      Top := 120;
      Width := 105;
      Height := 17;
      Caption := 'Počet balení';
      TabOrder := 8;
    end;
    with edPeriodOrder do
    begin
      Name := 'edPeriodOrder';
      Parent := frmDodavat;
      Left := 95;
      Top := 144;
      Width := 49;
      Height := 21;
      TabOrder := 9;
      Value := 0;
      DecimalPlaces := 0;
      //DisplayFormat := '0';
    end;
    with cbPeriodOrder do
    begin
      Name := 'cbPeriodOrder';
      Parent := frmDodavat;
      Left := 165;
      Top := 144;
      Width := 105;
      Height := 17;
      Caption := 'Period objednávání';
      Checked := True;
      State := cbChecked;
      TabOrder := 10;
    end;
    with edErrDeliv do
    begin
      Name := 'edErrDeliv';
      Parent := frmDodavat;
      Left := 95;
      Top := 168;
      Width := 49;
      Height := 21;
      TabOrder := 11;
      Value := 0;
      DecimalPlaces := 0;
      //DisplayFormat := '0';
    end;
    with cbErrDeliv do
    begin
      Name := 'cbErrDeliv';
      Parent := frmDodavat;
      Left := 165;
      Top := 168;
      Width := 105;
      Height := 17;
      Caption := 'Odchylka dodavatele';
      Checked := True;
      State := cbChecked;
      TabOrder := 12;
    end;
    with btnStorno do
    begin
      Name := 'btnStorno';
      Parent := frmDodavat;
      Left := 176;
      Top := 213;
      Width := 75;
      Height := 25;
      Cancel := True;
      Caption := 'Storno';
      ModalResult := 2;
      TabOrder := 13;
    end;
    with btnOK do
    begin
      Name := 'btnOK';
      Parent := frmDodavat;
      Left := 95;
      Top := 213;
      Width := 75;
      Height := 25;
      Caption := 'OK';
      Default := True;
      ModalResult := 1;
      TabOrder := 14;
    end;
  
   if frmDodavat.ShowModal(mySiteFrm) = mrOk then begin
     if aIdFirm = '' then
       ShowMessage('Není vybrán dodavatel', mySiteFrm)
     else begin
        // ověříme, že pracujeme se sdílenými číselníky - jinak přistupovat k hl. dodavateli
        mRollShare := UpperCase(GetParamValue(mySiteFrm.BaseObjectSpace,'ROLLSHARE')) = 'ANO';
        mF := TForm.createnew(mySiteFrm);
        try
          mPB := TProgressBar.CreateParented(mF.ClientHandle);
          mF.BorderStyle := bsSingle;
          mF.Caption := 'Aktualizace hl. dodavatele';
          mf.BorderIcons := 0;
          mF.Height := 70;
          mF.Width := 300;
          mf.Position := poScreenCenter;
          mPB.Parent := mF;
          mPB.Min := 0;
          mPB.Max :=  mIDs.Count - 1;
          mPB.Left := 20;
          mPB.Top := 15;
          mPB.Width := 255;
          mf.Show;
         for N := 0 to mIDs.Count - 1 do begin
           mBoStoreCard := mySiteFrm.BaseObjectSpace.CreateObject(Class_StoreCard);
           if (n mod 1000) = 0 then begin
             mPB.Position := N;
             Application.ProcessMessages;
           end;
           try
             mDodav_ID := GetDod(mySiteFrm.BaseObjectSpace,mIDs.Strings(N),aIdFirm);
             mBoDod := mySiteFrm.BaseObjectSpace.CreateObject(Class_Supplier);
          try
            if mDodav_ID = '' then begin // založíme dodavatele
              mBoDod.New;
              mBoDod.Prefill;
              mBoDod.SetFieldValueAsString('Firm_ID',aIdFirm);
              mBoDod.SetFieldValueAsString('StoreCard_ID',mIDs.Strings(N));
              mBoStoreCard.Load(mIDs.Strings(N),nil); // musí se na4íst 2x jinak řve na obj version
              mBoDod.SetFieldValueAsString('QUnit',mBoStoreCard.GetFieldValueAsString('MainUnitCode'));
            end else begin
               mBoDod.Load(mDodav_ID,nil);
               if mBoDod.GetFieldValueAsString('Firm_ID') <> aIdFirm then // ošetření zásadní opravy nad firmou - vymění se platný dodavatel
                 mBoDod.SetFieldValueAsString('Firm_ID',aIdFirm);
            end;
            if mRollShare then begin           // sestřelíme poptávatna dalších dodavatelých dané karty
               mBoDod.ObjectSpace.SQLExecute('update set DoDemand =false from Suppliers where StoreCard_ID=''' + mIDs.Strings(N)+'''');
            end;
            mBoDod.SetFieldValueAsBoolean('DoDemand',true);
            if cbDodDoba.Checked then
              mBoDod.SetFieldValueAsInteger('DeliveryTime',Round(edDodDoba.Value));
            if cbErrDeliv.Checked then
              mBoDod.SetFieldValueAsInteger('X_lt_std_provider',Round(edErrDeliv.Value));
            if cbPeriodOrder.Checked then
              mBoDod.SetFieldValueAsInteger('X_max_lt_provider',Round(edPeriodOrder.Value));
            if cbUnit.Checked then
              mBoDod.SetFieldValueAsString('QUnit',edUnit.Text);
            if cbPacking.Checked then
              mBoDod.SetFieldValueAsFloat('Packing',edPacking.Value);
            if cbCountPack.Checked then
              mBoDod.SetFieldValueAsFloat('MinimalQuantity',edCountPack.Value);
            mBoDod.Save;
            if mRollShare then ClearDoDemand(mBoDod);           // sestřelíme poptávatna dalších dodavatelých dané karty
            mDodav_ID := mBoDod.OID;
          finally
            mBoDod.Free;
          end;
      // ještě ověříme, že je nastaven jako hlavní dodavatel
             mBoStoreCard.Load(mIDs.Strings(N),nil); //
             if not mRollShare then begin
               if mBoStoreCard.GetFieldValueAsString('MainSupplier_ID')<> mDodav_ID then  mBoStoreCard.SetFieldValueAsString('MainSupplier_ID',mDodav_ID);
             end else mBoStoreCard.SetFieldValueAsString('MainSupplier_ID','0000000000');
             mBoStoreCard.Save;

        finally
          mBoStoreCard.Free;
        end;
      end;
      finally
        mF.Free;
      end;
    end; // Test na výber dodavatele
 end;
 finally
   frmDodavat.Free;
 end;
end;

procedure OpenFrm(mySiteFrm: TSiteForm);
var
    mSelected: TStringList;
begin
   mSelected:= TStringList.Create;
  try
    mySiteFrm.List.GetSelectedId(mSelected);
    ShowFrmDoda(mySiteFrm, mSelected);
  finally
    mSelected.Free;
  end;
end;


begin
end.