var
  gFormForShow: TForm;
  gFormForShowTextObject: TLabel;

//Dialog ....
//Pokud je pouze vytvořit, vrátí objekt labelu, jinak vrátí mrResult
//Vystředí dialog podle Ownera
//ANameButtons, AText - jako Text ze StringListu
//Automatické formátování pozic tlačítek a textu
//Možnost přiřadit shortcuty pro tlačítka - přiřazování je podle pořadí ve vstupních parametrech
//Result vrací pořadí (od 1) stisknutého tlačítka
//Pokud budou existovat v OLE dokumentech obrázky (BMP) s názvy SCPicture-Information, ... tak se
//  budou zobrazovat v dialogu podle hodnoty AmtType
//SCPicture-Backround je BMP obrázek pro možné pozadí dialogu
function Dialog(AOS: TNxCustomObjectSpace; AmtType: Integer; AOwner: TComponent; ANameButtons,
  ATitle, AText: string; AShortCuts: array of Integer; AAnimatedPicture: Boolean = False;
  AAnimatedBackroundPicture: Boolean = False; AOnlyCreate: Boolean = False;
  AAligment: TAlignment = taCenter; AOnClick: Pointer = nil): Variant;
const
  cMinWidth = 300;
  cMaxWidth = 900;
  cMinHeight = 150;
  cPictureSize = 80;
  cBorderSize = 20;
  cMaxCountRow = 30;
var
  mForm: TForm;
  mName: String;
  ss, ss2: TStringList;
  mCanvas: TCanvas;
  i, j, k, mCalcWidthForm, mCalcHeightForm, mCountRowsCaption, mLeft: Integer;
  e, e1, mDiffWidthButt: Extended;
  mPicture, mBackroundPicture: TPicture;
//  mAPicture, mBackroundAPicture: TGIFImage;
  mIsPicture, mIsBackroundPicture: Boolean;
  mBorderSizeText: Integer;
  mButtonResult: Integer;
  mScrollBox: TScrollBox;
  mTextHeight, mOrigCountRowsCaption: Integer;

  procedure OnKeyDownForm(Sender: TObject; var Key: Word; Shift: TShiftState);
  var
    mButton: TButton;
    mForm: TForm;
  begin
    mForm := TForm(Sender);
    mButton := TButton(NxFindChildControl(mForm, 'C' + IntToStr(Key)));
    if Assigned(mButton) then begin
      if Key = mButton.Tag then begin
        mForm.ModalResult := mButton.ModalResult;
        mButtonResult := mButton.ModalResult;
        mForm.Close;
      end;
    end;
  end;

begin
  mForm := TForm.Create(AOwner);
  ss := TStringList.Create;
  ss2 := TStringList.Create;
  if not AAnimatedPicture then
    mPicture := TPicture.Create
{  else
    mAPicture := TGIFImage.Create};
{  if AAnimatedBackroundPicture then
    mBackroundAPicture := TGIFImage.Create
  else}
    mBackroundPicture := TPicture.Create;
  try
    ss.Text := ANameButtons;
    ss2.Text := AText;
{    if AAnimatedPicture then
      mIsPicture := LoadAnimatedGIF(AOS, AmtType, mAPicture)
    else}
      mIsPicture := LoadPicture(AOS, AmtType, mPicture);
{    if AAnimatedBackroundPicture then
      mIsBackroundPicture := LoadAnimatedGIF(AOS, mtCustom, mBackroundAPicture)
    else}
      mIsBackroundPicture := LoadPicture(AOS, mtCustom, mBackroundPicture);
    if mIsPicture then
      mBorderSizeText := cBorderSize * 2 + cPictureSize
    else
      mBorderSizeText := cBorderSize * 2;

    with mForm do begin
      BorderStyle := bsDialog;
      BorderIcons := 0;
      Caption := ATitle;
      Color := clBtnFace;
      Position := poOwnerFormCenter;
      Scaled := False;
      Font.Size := 12;
      KeyPreview := True;
      OnKeyDown := @OnKeyDownForm;
    end;
    mCanvas := mForm.Canvas;
    // výpočet šířky formu dle textu
    mCalcWidthForm := cMinWidth;
    mCountRowsCaption := ss2.Count;
    for i:=0 to ss2.Count-1 do begin
      Inc(mCountRowsCaption, mCanvas.TextWidth(ss2[i]) div (cMaxWidth - mBorderSizeText));
      if mCanvas.TextWidth(ss2[i]) div (cMaxWidth - mBorderSizeText) > 0 then
        mCalcWidthForm := cMaxWidth
      else
        if mCalcWidthForm < mCanvas.TextWidth(ss2[i]) + mBorderSizeText then
          mCalcWidthForm := mCanvas.TextWidth(ss2[i]) + mBorderSizeText;
    end;
    mOrigCountRowsCaption := mCountRowsCaption;
    if mCountRowsCaption > cMaxCountRow then
      mCountRowsCaption := cMaxCountRow;
    // výpočet šířky formu dle tlačítek
    mDiffWidthButt := 1;
    j := 0;
    for i:=0 to ss.Count-1 do
      Inc(j, mCanvas.TextWidth(ss[i]) + cBorderSize);
    if j + (ss.Count-1) * cBorderSize + cBorderSize*2 > cMaxWidth then
      mDiffWidthButt := (cMaxWidth - cBorderSize*2) / (j + (ss.Count-1) * cBorderSize);
    if j + (ss.Count-1) * cBorderSize + cBorderSize*2 > mCalcWidthForm then
      mCalcWidthForm := j + (ss.Count-1) * cBorderSize + cBorderSize*2
    else
      mDiffWidthButt := (mCalcWidthForm - cBorderSize*2) / (j + (ss.Count-1) * cBorderSize);
    if mCalcWidthForm < cMinWidth then
      mCalcWidthForm := cMinWidth;
    if mCalcWidthForm > cMaxWidth then
      mCalcWidthForm := cMaxWidth;
    // výpočet výšky formu
    mCalcHeightForm := (mCountRowsCaption+1) * mCanvas.TextHeight(AText) + 80;

    with mForm do begin
      ClientHeight := mCalcHeightForm;
      ClientWidth := mCalcWidthForm;
    end;

    if mIsBackroundPicture then
{      if AAnimatedBackroundPicture then with TRxGIFAnimator.Create(mForm) do begin
        Parent := mForm;
        Left := 0;
        Top := 0;
//        Width := mForm.Width;
//        Height := mForm.Height;
        Center := True;
        Stretch := True;
        Transparent := True;
        AutoSize := False;
        Image := mBackroundAPicture;
        if Width < mForm.Width then
          Left := (mForm.Width - Width) div 2;
        if Height < mForm.Height then
          Top := (mForm.Height - Height) div 2;
//        AsyncDrawing := True;
        Animate := True;
        SendToBack;
      end
      else} with TImage.Create(mForm) do begin
        Parent := mForm;
        Left := 0;
        Top := 0;
        Width := mForm.Width;
        Height := mForm.Height;
        Center := True;
        Stretch := True;
        Transparent := True;
        AutoSize := False;
        Picture := mBackroundPicture;
        SendToBack;
      end;
    i := 12;
    if mIsPicture then
{      if AAnimatedPicture then with TRxGIFAnimator.Create(mForm) do begin
        Parent := mForm;
        e := cPictureSize / mAPicture.Width;
        e1 := (mCanvas.TextHeight(AText) * mCountRowsCaption + 12) / mAPicture.Height;
        if e1 < e then
          e := e1;
        Height := Round(e * mAPicture.Height);
        Width := Round(e * mAPicture.Width);
        Left := 6 + (cPictureSize - Width) div 2;
        Top := 6 + ((mCanvas.TextHeight(AText) * mCountRowsCaption + 12) - Height) div 2;;
        i := Top + Height;
        AutoSize := False;
        Center := True;
        Stretch := True;
        Transparent := True;
//        AsyncDrawing := True;
        Image := mAPicture;
        Animate := True;
      end
      else }with TImage.Create(mForm) do begin
        Parent := mForm;
        e := cPictureSize / mPicture.Width;
        e1 := (mCanvas.TextHeight(AText) * mCountRowsCaption + 12) / mPicture.Height;
        if e1 < e then
          e := e1;
        Height := Round(e * mPicture.Height);
        Width := Round(e * mPicture.Width);
        Left := 6 + (cPictureSize - Width) div 2;
        Top := 6 + ((mCanvas.TextHeight(AText) * mCountRowsCaption + 12) - Height) div 2;;
        i := Top + Height;
        AutoSize := False;
        Center := True;
        Stretch := True;
        Proportional := True;
        Transparent := True;
        Picture := mPicture;
      end;

    mScrollBox := TScrollBox.Create(mForm);
    with mScrollBox do begin
      Parent := mForm;
      BorderStyle := bsNone;
      if mIsPicture then
        Left := mBorderSizeText - cBorderSize - 4
      else
        Left := cBorderSize - 4;
      Top := 12;
      Width := mForm.Width - Left - cBorderSize + 12;
      Height := mCanvas.TextHeight(AText) * mCountRowsCaption;
      if i < Top + Height then
        i := Top + Height;
      BringToFront;
    end;
    gFormForShowTextObject := TLabel.Create(mForm);
    with gFormForShowTextObject do begin
      Parent := mScrollBox;
      AutoSize := False;
      Align := alTop;
      Height := mCanvas.TextHeight(AText) * mOrigCountRowsCaption;
      Alignment := AAligment;
      Caption := AText;
      WordWrap := True;
    end;
    with TBevel.Create(mForm) do begin
      Parent := mForm;
      Left := cBorderSize;
      Top := i + 15;
      Width := mForm.Width - cBorderSize*2 - 6;
      Height := 6;
      i := Top + Height;
      Style := bsRaised;
      Shape := bsFrame;
      BringToFront;
    end;
    mLeft := cBorderSize;
    for j:=0 to ss.Count-1 do begin
      if ss[j] = '' then
        continue;
      with TButton.Create(mForm) do begin
        Parent := mForm;
        Left := mLeft;
        Top := i + cBorderSize;
        Width := mCanvas.TextWidth(ss[j]) + cBorderSize;
        Width := Round(Width * mDiffWidthButt);
        Inc(mLeft, Width + Round(cBorderSize * mDiffWidthButt));
        k := (mCanvas.TextWidth(ss[j]) + 10) div Width + 1;
        Height := (mCanvas.TextHeight(ss[j]) + 15) * k;
        Caption := ss[j];
        ModalResult := j+1;
        Default := ss.Count = 1;
        TabOrder := j+1;
        WordWrap := mDiffWidthButt < 1;
        if mForm.ClientHeight < Top + Height + 20 then
          mForm.ClientHeight := Top + Height + 20;
        if VarArrayHighBound(AShortCuts, 1) >= j then begin
          Tag := AShortCuts[j];
          Name := 'C' + IntToStr(Tag);
        end
        else
          Tag := -1;
      end;
    end;
    mButtonResult := -1;
    gFormForShow := mForm;
    if not AOnlyCreate then begin
      Result := mForm.ShowModal(mForm);
      if mButtonResult <> -1 then
        Result := mButtonResult;
    end
    else
      Result := -1;
  finally
    ss.Free;
    ss2.Free;
    if not AAnimatedPicture then begin
      mPicture.Free;
      mBackroundPicture.Free;
    end
    else begin
//      mAPicture.Free;
//      mBackroundAPicture.Free;
    end;
    if not AOnlyCreate then
      mForm.Free
    else
      Result := gFormForShowTextObject;
  end;
end;

function Dialog2(ASite: TSiteForm; AmtType: Integer; ANameButtons,
  AText: string; AAnimatedPicture: Boolean = False;
  AAnimatedBackroundPicture: Boolean = False; AOnlyCreate: Boolean = False;
  AAligment: TAlignment = taCenter; AOnClick: Pointer = nil): Variant;
var
  mTitle, s: string;
  mOS: TNxCustomObjectSpace;
  mForm: TForm;
  mA: array of Integer;
begin
  case AmtType of
    mtInformation: mTitle := 'Informace';
    mtConfirmation: mTitle := 'Dotaz / potvrzení';
    mtWarning: mTitle := 'Varování';
    mtError: mTitle := 'Chyba';
    else mTitle := '';
  end;
  if Assigned(ASite) then begin
    mOS := ASite.BaseObjectSpace;
    mForm := ASite.GetSiteAppForm;
  end
  else begin
    mOS := nil;
    mForm := nil;
  end;
  Result := Dialog(mOS, AmtType, mForm, ANameButtons, mTitle, AText, mA, AAnimatedPicture,
    AAnimatedBackroundPicture, AOnlyCreate, AAligment, AOnClick);
end;

function LoadPicture(AOS: TNxCustomObjectSpace; AmtType: Integer; APicture: TPicture): Boolean;
var
  mFileName: String;
  mBO, mBOData: TNxCustomBusinessObject;
  mPars: TNxParameters;
  mPar: TNxRawParameter;
  s, mID: String;
  ss: TStringList;
  mStream: TMemoryStream;
  mGraphic: TGraphic;
  mR: TNxReader;
begin
  Result := False;
  if not Assigned(AOS) then
    exit;
  mPars := TNxParameters.Create;
  mBOData := AOS.CreateObject('J0OKEDVUDLEOBHUIYFT3G31ERC'); //DocumentData
  ss := TStringList.Create;
  mStream := TMemoryStream.Create;
  mR := TNxReader.Create(mStream, 256);
  mGraphic := TBitmap.Create;
  try
    case AmtType of
      mtInformation: mFileName := 'SCPicture-Information';
      mtConfirmation: mFileName := 'SCPicture-Confirmation';
      mtWarning: mFileName := 'SCPicture-Warning';
      mtError: mFileName := 'SCPicture-Error';
      else mFileName := 'SCPicture-Backround';
    end;
    s := 'select Data_ID from DocumentContents where FileName = ''' + mFileName + '''';
    AOS.SQLSelect(s, ss);
    if (ss.Count = 0) or NxIsEmptyOID(ss[0]) then
      Exit
    else
      mID := ss[0];
    mBOData.Load(mID, nil);
    mPar := TNxRawParameter(TNxParameter.CreateFromDataType(dtVarBytes, 'BlobData', pkInput));
    mPars.Add(mPar);
    mBOData.GetFieldValues(mPars);
    mPar := TNxRawParameter(mPars.ParamByName('BlobData'));
    if Assigned(mPar) then begin
      if mPar.SaveDataToStream(mStream) then begin
        mStream.Position := 0;
        try
          mGraphic.LoadFromStream(mStream);
          APicture.Graphic := mGraphic;
//          LoadPictureFromStream(mStream, APicture);
          Result := not APicture.Graphic.Empty;
        except
        end;
      end;
    end
  finally
    mBOData.Free;
    mPars.Free;
    ss.Free;
    mStream.Free;
    mGraphic.Free;
  end;
end;
{
function LoadAnimatedGIF(AOS: TNxCustomObjectSpace; AmtType: Integer; AGIFImage: TGIFImage): Boolean;
var
  mFileName: String;
  mBO, mBOData: TNxCustomBusinessObject;
  mPars: TNxParameters;
  mPar: TNxRawParameter;
  s, mID: String;
  ss: TStringList;
  mStream: TMemoryStream;
  mR: TNxReader;
begin
  Result := False;
  if not Assigned(AOS) then
    exit;
  mPars := TNxParameters.Create;
  mBOData := AOS.CreateObject('J0OKEDVUDLEOBHUIYFT3G31ERC'); //DocumentData
  ss := TStringList.Create;
  mStream := TMemoryStream.Create;
  mR := TNxReader.Create(mStream, 256);
  try
    case AmtType of
      mtInformation: mFileName := 'SCAnimatedPicture-Information';
      mtConfirmation: mFileName := 'SCAnimatedPicture-Confirmation';
      mtWarning: mFileName := 'SCAnimatedPicture-Warning';
      mtError: mFileName := 'SCAnimatedPicture-Error';
      else mFileName := 'SCAnimatedPicture-Backround';
    end;
    s := 'select Data_ID from DocumentContents where FileName = ''' + mFileName + '''';
    AOS.SQLSelect(s, ss);
    if (ss.Count = 0) or NxIsEmptyOID(ss[0]) then
      Exit
    else
      mID := ss[0];
    mBOData.Load(mID, nil);
    mPar := TNxRawParameter(TNxParameter.CreateFromDataType(dtVarBytes, 'BlobData', pkInput));
    mPars.Add(mPar);
    mBOData.GetFieldValues(mPars);
    mPar := TNxRawParameter(mPars.ParamByName('BlobData'));
    if Assigned(mPar) then begin
      if mPar.SaveDataToStream(mStream) then begin
        mStream.Position := 0;
        try
          AGIFImage.LoadFromStream(mStream);
          Result := not AGIFImage.Empty;
        except
        end;
      end;
    end
  finally
    mBOData.Free;
    mPars.Free;
    ss.Free;
    mStream.Free;
  end;
end;
 }
procedure SimpleMessage(AOS: TNxCustomObjectSpace; AmtType: TMsgDlgType; AOwner: TComponent;
  AText: string; AAnimatedPicture: Boolean = False; AAnimatedBackroundPicture: Boolean = False;
  AOnlyCreate: Boolean = False);
var
  mTitle: string;
begin
  case AmtType of
    mtInformation: mTitle := 'Informace';
    mtConfirmation: mTitle := 'Dotaz / potvrzení';
    mtWarning: mTitle := 'Varování';
    mtError: mTitle := 'Chyba';
    else mTitle := '';
  end;
  Dialog(AOS, AmtType, AOwner, 'Pokračovat (ESC)', mTitle, AText, [VK_ESCAPE],
    AAnimatedPicture, AAnimatedBackroundPicture, AOnlyCreate);
end;

procedure SimpleMessageII(ASite: TSiteForm; AmtType: TMsgDlgType;
  AText: string; AAnimatedPicture: Boolean = False; AAnimatedBackroundPicture: Boolean = False;
  AOnlyCreate: Boolean = False; AWithoutButton: Boolean = False; AAligment: TAlignment = taCenter);
var
  mTitle, s: string;
  mOS: TNxCustomObjectSpace;
  mForm: TForm;
begin
  case AmtType of
    mtInformation: mTitle := 'Informace';
    mtConfirmation: mTitle := 'Dotaz / potvrzení';
    mtWarning: mTitle := 'Varování';
    mtError: mTitle := 'Chyba';
    else mTitle := '';
  end;
  if Assigned(ASite) then begin
    mOS := ASite.BaseObjectSpace;
    mForm := ASite.GetSiteAppForm;
  end
  else begin
    mOS := nil;
    mForm := nil;
  end;
  if not AWithoutButton then
    s := 'Pokračovat (ESC)'
  else
    s := '';
  Dialog(mOS, AmtType, mForm, s, mTitle, AText, [VK_ESCAPE], AAnimatedPicture,
    AAnimatedBackroundPicture, AOnlyCreate, AAligment);
end;

function SQLSel(AContext: TNxContext; ASQL: string; ADefault: Variant): Variant;
var
  s, mSQL: string;
  mDS: TMemoryDataset;
begin
  mDS := TMemoryDataset.Create(nil);
  try
    AContext.SQLSelect2(ASQL, mDS);
    if not mDS.EOF then begin
      case VarType(ADefault) of
        varEmpty, varNull: Result := ADefault;
        varInteger, varSmallint, varByte: Result := mDS.Fields[0].Value;
        varDouble, varDate: Result := mDS.Fields[0].Value;
        varString, varOleStr: Result := mDS.Fields[0].Value;
        varBoolean: Result := UpperCase(mDS.Fields[0].Value) = 'A';
        else Result := mDS.Fields[0].Value;
      end;
      if (VarType(Result) = varString) or (VarType(Result) = varOleStr) then begin
        s := Result;
        if (s <> '') and (s[1] = '"') and (s[Length(s)] = '"') then
          Result := Copy(s, 2, Length(s)-2);
      end;
    end
    else
      Result := ADefault;
  finally
    mDS.Free;
  end;
end;

begin
end.
