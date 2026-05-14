function ShowPriceListForm(ASite: TSiteForm; const AStoreCardsList: TStringList;
                          var APriceListIDs: TStringList; var APriceDefIDs: TStringList;
                          var ACoeficient: Extended; var AValidFromDate: TDateTime): Boolean;
var
  mFrm: TForm;
  mComboPriceList, mComboPriceDefs: TRollComboEdit;
  mChkNewValidFrom: TCheckBox;
  mDateValidFrom: TDateEdit;
  mEditCoef: TNumEdit;
  mLblPriceList, mLblDateValidFrom, mLblCoef, mLblPriceDef: TLabel;
  mBtnOK, mBtnStorno: TButton;
  mAllowedPriceLists, mSelectedSCList: TStringList;
  i: integer;
begin
  Result := False;
  mAllowedPriceLists:= TStringList.Create;
  mSelectedSCList:= TStringList.Create;
  mFrm := TForm.Create(ASite);
  try
    mSelectedSCList.Assign(AStoreCardsList);
    for i:= 0 to mSelectedSCList.Count-1 do
      mSelectedSCList[i]:= QuotedStr(mSelectedSCList[i]);

    ASite.BaseObjectSpace.SQLSelect(Format(
      ' SELECT DISTINCT SP.PriceList_ID FROM StorePrices SP '+
      ' JOIN Firms F ON F.PriceList_ID = SP.PriceList_ID '+
      ' WHERE StoreCard_ID in (%s) ',
      [mSelectedSCList.CommaText]), mAllowedPriceLists);

    mFrm.Caption := 'Přepočet cen';
    mFrm.Position := poScreenCenter;
    mFrm.Width := 400;
    mFrm.Height := 280;
    mFrm.BorderStyle := bsDialog;

    mLblPriceList := TLabel.Create(mFrm);
    mLblPriceList.Parent := mFrm;
    mLblPriceList.Caption := 'Vyberte ceníky';
    mLblPriceList.Left := 20;
    mLblPriceList.Top := 10;

    mComboPriceList := TRollComboEdit.Create(mFrm);
    mComboPriceList.Parent := mFrm;
    mComboPriceList.Name:= 'rcePriceLists';
    mComboPriceList.Left := 20;
    mComboPriceList.Top := 30;
    mComboPriceList.Width := 350;
    mComboPriceList.ClassID:= Roll_PriceLists;
    mComboPriceList.Parameters.Add('_Allowed='+mAllowedPriceLists.Text);
    mComboPriceList.Hint := 'Vyberte ceníky';
    mComboPriceList.MultiChoice:= True;
    mComboPriceList.ForcedField:= True;
    mComboPriceList.Complete:= True;
    mComboPriceList.TextField:= 'name';
    mComboPriceList.Text:= '';
    mComboPriceList.OnChange:= @ComboPriceList_OnChange;

    {
    mLblPriceDef := TLabel.Create(mFrm);
    mLblPriceDef.Parent := mFrm;
    mLblPriceDef.Caption := 'Vyberte definice cen';
    mLblPriceDef.Left := 20;
    mLblPriceDef.Top := 60;

    mComboPriceDefs := TRollComboEdit.Create(mFrm);
    mComboPriceDefs.Parent := mFrm;
    mComboPriceDefs.Name:= 'rcePriceDefs';
    mComboPriceDefs.Left := 20;
    mComboPriceDefs.Top := 80;
    mComboPriceDefs.Width := 350;
    mComboPriceDefs.ClassID:= Roll_PriceDefinitions;
    mComboPriceDefs.Hint := 'Vyberte definice';
    mComboPriceDefs.MultiChoice:= True;
    mComboPriceDefs.ForcedField:= True;
    mComboPriceDefs.Complete:= True;
    mComboPriceDefs.TextField:= 'name';
    mComboPriceDefs.Text:= '';
    }
    {
    mChkNewValidFrom := TCheckBox.Create(mFrm);
    mChkNewValidFrom.Parent := mFrm;
    mChkNewValidFrom.Name:= 'tchbNewValidity';
    mChkNewValidFrom.Caption := 'Přidat novou platnost s datem od';
    mChkNewValidFrom.Width:= 200;
    mChkNewValidFrom.Left := 20;
    mChkNewValidFrom.Top := 120;
    mChkNewValidFrom.Checked:= false;
    mChkNewValidFrom.OnClick := @ToggleDateValidFrom;
    }

    mLblDateValidFrom := TLabel.Create(mFrm);
    mLblDateValidFrom.Parent := mFrm;
    mLblDateValidFrom.Caption := 'Založení nové platnosti od';
    mLblDateValidFrom.Left := 20;
    mLblDateValidFrom.Top := 120;

    mDateValidFrom := TDateEdit.Create(mFrm);
    mDateValidFrom.Parent := mFrm;
    mDateValidFrom.Name:= 'tdeValidFrom';
    mDateValidFrom.Left := 270;
    mDateValidFrom.Top := 118;
    mDateValidFrom.Width := 100;
    //mDateValidFrom.Enabled:= false;
    mDateValidFrom.Hint := 'Datum platnosti od';

    mLblCoef := TLabel.Create(mFrm);
    mLblCoef.Parent := mFrm;
    mLblCoef.Caption := 'Koeficient přepočtu (původní cena * koeficient)';
    mLblCoef.Left := 20;
    mLblCoef.Top := 150;

    mEditCoef := TNumEdit.Create(mFrm);
    mEditCoef.Parent := mFrm;
    mEditCoef.Left := 270;
    mEditCoef.Top := 145;
    mEditCoef.Width := 100;
    //mEditCoef.EditMask:= '9999,99;1;_';
    mEditCoef.Text := '1,00';
    mEditCoef.Hint := 'Koeficient přepočtu';
    mEditCoef.DecimalPlaces:= 2;
    mEditCoef.ThousandSepar:= true;
    mEditCoef.FormatOnEditing:= true;
    //mEditCoef.OnKeyPress := @ValidateFloatInput;


    mBtnOK := TButton.Create(mFrm);
    mBtnOK.Parent := mFrm;
    mBtnOK.Caption := 'OK';
    //mBtnOK.ModalResult := mrOk;
    mBtnOK.Left := 100;
    mBtnOK.Top := 200;
    mBtnOK.Width := 80;
    mBtnOK.OnClick:= @ValidateForm;

    mBtnStorno := TButton.Create(mFrm);
    mBtnStorno.Parent := mFrm;
    mBtnStorno.Caption := 'Storno';
    mBtnStorno.ModalResult := mrCancel;
    mBtnStorno.Left := 200;
    mBtnStorno.Top := 200;
    mBtnStorno.Width := 80;

    if mFrm.ShowModal(ASite) = mrOk then begin
      APriceListIDs.Text:= mComboPriceList.DataText;
      AValidFromDate:= mDateValidFrom.Date;
      ACoeficient:= StrToFloatDef(mEditCoef.Text, 1.00);
      //APriceDefIDs:= mComboPriceDefs.DataText;
      Result:= True;
    end;

  finally
    mAllowedPriceLists.Free;
    mSelectedSCList.Free;
    mFrm.Free;
  end;
end;

procedure ToggleDateValidFrom(Sender: TObject);
begin
  //TDateEdit(TCheckBox(Sender).Parent.FindChildControl('tdeValidFrom')).Enabled := TCheckBox(TCheckBox(Sender)).Checked;
end;

procedure ValidateFloatInput(Sender: TObject; var Key: Char);
var
  mEdit: TEdit;
begin
  mEdit:= TEdit(Sender);
  if not (Key in ['0'..'9', ',', #8]) then
    Key := #0 // Ignore invalid input
  else if (Key = ',') and (Pos(',', mEdit.Text) > 0) then
    Key := #0; // Prevent multiple decimal separators
end;

// Declare the ValidateForm function outside of ShowPriceListForm
procedure ValidateForm(Sender: TObject);
var
  mComboPriceList: TRollComboEdit;
  mValidFromDate: TDateEdit;
begin
  mComboPriceList:= TRollComboEdit(TButton(Sender).Parent.FindChildControl('rcePriceLists'));
  // Check if any price list is selected
  if NxIsBlank(mComboPriceList.DataText) then
  begin
    NxShowSimpleMessage('Nelze pokračovat! Prosím vyberte alespoň jeden ceník.', TButton(Sender).Parent.Site);
    mComboPriceList.SetFocus;
    Exit;
  end;

  mValidFromDate:= TDateEdit(TButton(Sender).Parent.FindChildControl('tdeValidFrom'));
  if mValidFromDate.Date < Date then
  begin
    NxShowSimpleMessage('Nelze pokračovat! Je potřeba zadat datum platnosti dnes nebo novější.', TButton(Sender).Parent.Site);
    mValidFromDate.SetFocus;
    exit;
  end;

  TForm(TButton(Sender).Parent).ModalResult:= mrOk;
end;

procedure ComboPriceList_OnChange(Sender: TObject);
var
  mValidFromDate: TDateTime;
  mPriceListIDs: TStringList;
  mSQL: string;
  i: integer;
begin
  mPriceListIDs:= TStringList.Create;
  mPriceListIDs.Delimiter:= ';';
  try
    mPriceListIDs.DelimitedText:= TRollComboEdit(Sender).DataText;
    if mPriceListIDs.Count > 0 then
    begin
      for i:= 0 to mPriceListIDs.Count -1 do
        mPriceListIDs[i]:= QuotedStr(mPriceListIDs[i]);

      mSQL:= Format('SELECT ValidFromDate$Date FROM PriceListValidities WHERE Parent_ID in (%s) ORDER BY ValidFromDate$Date DESC', [mPriceListIDs.CommaText]);
      //NxShowSimpleMessage(mSQL, TRollComboEdit(Sender).Site);
      mValidFromDate:= TRollComboEdit(Sender).Site.SiteContext.SQLSelectFirstAsExtended(mSQL);

      if mValidFromDate <= Date then
        mValidFromDate:= Date;

      TDateEdit(TRollComboEdit(Sender).Parent.FindChildControl('tdeValidFrom')).Date := mValidFromDate;
    end;
  finally
    mPriceListIDs.Free;
  end;
end;



begin
end.