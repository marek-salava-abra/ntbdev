

// Formulář typu modální dialog
// ------------------------------------------------------------------------------

function CreateFormDialog(AName, ACaption: String; AWidth, AHeight: Integer; AParent: TWinControl): TForm;
var
  mForm: TForm;
begin
  mForm := TForm.Create(AParent);
  mForm.Name := 'fm_'+AName;
  mForm.Caption := ACaption;
  mForm.FormStyle := fsStayOnTop;
  mForm.BorderStyle := bsDialog;
  mForm.Position := poScreenCenter;
  mForm.Width := AWidth;
  mForm.Height := AHeight;
  mForm.Scaled := False;

  Result := mForm;
end;


// Tlačítko
// ------------------------------------------------------------------------------


function CreateButton(AName, ACaption: string; AModalResult: integer; ALeft, ATop, AWidth, AHeight: Integer; ADefault: Boolean; AParent: TWinControl): TButton;
begin
  Result := TButton.Create(AParent);
  Result.Parent := AParent;
  Result.Name := 'btn_'+AName;
  Result.Caption := ACaption;
  Result.Top := ATop;
  Result.Left := ALeft;
  Result.Width := AWidth;
  Result.Height := AHeight;
  Result.Default := ADefault;
  Result.ModalResult := AModalResult;
end;



// Bílý panel s titulkem a textem
// ------------------------------------------------------------------------------

function CreateHeadPanel(AName, ACaption, AText: String; AWidth, AHeight: Integer; AParent: TWinControl): TPanel;
var
  mLbl, mLbl2: TLabel;
  mPanel: TPanel;
begin
  mPanel := TPanel.Create(AParent);
  with mPanel do begin
    Name := 'pnl_'+AName;
    Caption:= '';
    Parent := AParent;
    Align := alTop;
    Left := 0;
    Top := 0;
    Height := AHeight;
    BevelOuter := bvNone;
    PanelColor := pcWizardWhite;
  end;

      with TBevel.Create(AParent) do
      begin
        Name := 'bvlBottom';
        Parent := AParent;
        Left := 0;
        Top := 70;
        Width := AWidth;
        Height := 5;
        Align := alTop;
        Shape := bsTopLine;
      end;

  mLbl := TLabel.Create(mPanel);
  with mLbl do begin
    Name := 'lbl_'+AName;
    Caption := ACaption;
    Parent := mPanel;
    Left := 10;
    Top := 10;
    Height := 16;
    Width := AWidth-20;
    Font.Height := -13;
    Font.Name := 'MS Sans Serif';
    Font.Style := [fsBold];
    ParentFont := False;
    Transparent := True;
  end;

  mLbl2 := TLabel.Create(mPanel);
  with mLbl2 do begin
    Name := 'lbl2_'+AName;
    Caption := AText;
    Parent := mPanel;
    Left := 10;
    Top := 30;
    Height := 35;
    Width := AWidth-20;
    Font.Height := -11;
    Font.Name := 'MS Sans Serif';
    ParentFont := False;
    Transparent := True;
    WordWrap := true;

  end;
end;



// Popisek
// ------------------------------------------------------------------------------

function CreateLabel(AName, ACaption: String; ALeft, ATop, AWidth, AFontSize: Integer; AFontStyles: TFontStyles; AParent: TWinControl): TLabel;
var mLbl: TLabel;
  mFont: TFont;
begin
  mLbl:= TLabel.Create(AParent);
  mLbl.Name:= 'lbl_'+AName;
  mLbl.Parent:= AParent;
  mLbl.Top:= ATop;
  mLbl.Left:= ALeft;
  if AWidth <> -1 then
  begin
    mLbl.AutoSize:= False;
    mLbl.Width:= AWidth;
  end else
    mLbl.AutoSize:= True;
  mLbl.Caption:= ACaption;

  mFont := mLbl.Font;
  if AFontSize >= 0 then
    mFont.Size := AFontSize;
  mFont.Style := AFontStyles;

  Result:= mLbl;
end;


// Edit box
// ------------------------------------------------------------------------------

function CreateEdit(AName, ACaption: string;
  ALeft, ATop, AWidth: Integer; ALblWidth: Integer; ADefaultValue: string; AParent: TWinControl;
  AEditToNewLine: Boolean = False): TEdit;
var mLbl: TLabel;
begin
  mLbl:= TLabel.Create(AParent);
  mLbl.Parent:= AParent;
  mLbl.Top:= ATop + 3;
  mLbl.Left:= ALeft;
  mLbl.AutoSize:= False;
  if AName <> '' then
    mLbl.Name:= 'lbl_' + AName;
  if ALblWidth > -1 then
  begin
    mLbl.Width:= ALblWidth
  end else
  begin
    mLbl.AutoSize:= True;
    ALblWidth:= mLbl.Width + 10;
  end;
  mLbl.Caption:= ACaption;

  Result:= TEdit.Create(AParent);
  Result.Parent:= AParent;
  if not AEditToNewLine then
  begin
    Result.Top:= ATop;
    Result.Left:= ALeft + ALblWidth;
    Result.Width:= AWidth - ALblWidth;
  end else
  begin
    mLbl.Top:= ATop;
    Result.Top:= ATop + mLbl.Height + 2;
    Result.Width:= AWidth;
    Result.Left:= ALeft;
  end;
  if AName <> '' then
    Result.Name:= 'ed_' + AName;

  Result.Text:= ADefaultValue;
end;



// Datum edit box
// ------------------------------------------------------------------------------

function CreateDateEdit(AName, ACaption: string;
  ALeft, ATop, AWidth: Integer; ALblWidth: Integer; ADefaultValue: TDate; AParent: TWinControl;
  AEditToNewLine: Boolean = False): TDateEdit;
var
  mLbl: TLabel;
begin

  mLbl:= TLabel.Create(AParent);
  mLbl.Parent:= AParent;
  mLbl.Top:= ATop + 5;
  mLbl.Left:= ALeft;
  mLbl.AutoSize:= False;
  if AName <> '' then
    mLbl.Name:= 'lbl_' + AName;
  if ALblWidth > -1 then
  begin
    mLbl.Width:= ALblWidth
  end else
  begin
    mLbl.AutoSize:= True;
    ALblWidth:= mLbl.Width + 10;
  end;
  mLbl.Caption:= ACaption;

  Result:= TDateEdit.Create(AParent);
  Result.Parent:= AParent;
  if not AEditToNewLine then
  begin
    Result.Top:= ATop;
    Result.Left:= ALeft + ALblWidth;
    Result.Width:= AWidth - ALblWidth;
  end else
  begin
    mLbl.Top:= ATop;
    Result.Top:= ATop + mLbl.Height + 2;
    Result.Width:= AWidth;
    Result.Left:= ALeft;
  end;
  if AName <> '' then
    Result.Name:= 'ed_' + AName;

  Result.Date:= ADefaultValue;
end;



// NxComboEdit
// ------------------------------------------------------------------------------

function CreateNxComboEdit(AName, ACaption: string;
  ALeft, ATop, AWidth, ALblWidth, ABevelWidth: Integer;
  AClassID, ATextField, AControlField, AID: string;
  AParent: TWinControl;
  AParam: string = ''; AChange: string =''): TRollComboEdit;
var mLbl, mLbl1,
    mLblChange: TLabel;
begin
  if AID = '' then
    AID:= '0000000000';
  mLbl:= TLabel.Create(AParent);
  mLbl.Parent:= AParent;
  mLbl.Top:= ATop + 5;
  mLbl.Left:= ALeft;
  mLbl.AutoSize:= False;
  if AName <> '' then
    mLbl.Name:= 'lbl_' + AName;
  if ALblWidth > -1 then
  begin
    mLbl.Width:= ALblWidth
  end else
  begin
    mLbl.AutoSize:= True;
    ALblWidth:= mLbl.Width + 10;
  end;
  mLbl.Caption:= ACaption;

  mLbl1:= TLabel.Create(AParent);
  mLbl1.Parent:= AParent;
  mLbl1.Top:= ATop + 5;
  mLbl1.AutoSize:= False;
  mLbl1.Caption:= '';
  mLbl1.Left:= ALeft +AWidth-ALblWidth;
  if AName <> '' then
    mLbl1.Name:= 'lblBev_' + AName;
  mLbl1.Width:= ABevelWidth;
  mLbl1.Visible:= ABevelWidth > 0;

  Result:= TRollComboEdit.Create(AParent);
  Result.Parent:= AParent;
  Result.ClassID:= AClassID;
  Result.ForcedField:= True;
  Result.Prefilling:= pmNone;
  Result.TextField:= ATextField;
  Result.Parameters.Add(AParam);
  Result.Top:= ATop + 3;
  Result.Left:= ALeft + ALblWidth ;
  if AControlField <> '' then
  begin
    Result.ConnectedControlField:= AControlField;
    Result.ConnectedControl:= mLbl1;
  end;

  if AName <> '' then
    Result.Name:= 'ced_' + AName;
  Result.DataText:= AID;
  Result.Width:= AWidth - ALblWidth - ABevelWidth;

  {
  if (AChange <> '') and (AName <> '') then
  begin
    mLblChange:= TLabel.Create(AParent);
    mLblChange.Parent:= AParent;
    mLblChange.Top:= 0;
    mLblChange.Left:= 0;
    mLblChange.ViSible:= False;
    mLblChange.Name:= 'lblCh_' + AName;
    mLblChange.Caption:= AChange;
    Result.OnChange:= @NxDBComboEditChange;
  end;
  }

  mLbl1.Left:= mLbl1.Left + 10;
  mLbl1.Width:= mLbl1.Width - 10;
end;


// TCheckBox
// ------------------------------------------------------------------------------

function CreateCheckBox(AName, ACaption: string; ADefaultValue: Boolean;
  ALeft, ATop, AWidth, AHeight: Integer; AParent: TWinControl): TCheckBox;
begin
  Result:= TCheckBox.Create(AParent);
  Result.Parent:= AParent;
  Result.Top:= ATop;
  Result.Left:= ALeft;
  if AName <> '' then
    Result.Name:= 'ch_' + AName;
  Result.Width:= AWidth;
  if AHeight > -1 then
    Result.Height:= AHeight;
  Result.Caption:= ACaption;
  Result.Checked:= ADefaultValue;
  Result.WordWrap:= True;
end;


// TComboBox
// ----------------------------------------------------------------------------

function CreateComboBox(AName, ACaption: string; ALeft, ATop, AWidth: Integer; ALblWidth: Integer;
  ADefaultValue: Integer; AValues: string; AParent: TWinControl): TComboBox;
var mLbl: TLabel;
begin
  mLbl:= TLabel.Create(AParent);
  mLbl.Parent:= AParent;
  mLbl.Top:= ATop + 3;
  mLbl.Left:= ALeft;
  mLbl.AutoSize:= False;
  if AName <> '' then
    mLbl.Name:= 'lbl_' + AName;
  if ALblWidth > -1 then
  begin
    mLbl.Width:= ALblWidth
  end else
  begin
    mLbl.AutoSize:= True;
    ALblWidth:= mLbl.Width + 10;
  end;
  mLbl.Caption:= ACaption;

  Result:= TComboBox.Create(AParent);
  Result.Parent:= AParent;
  Result.Top:= ATop;
  Result.Left:= ALeft + ALblWidth;
  Result.Items.Text := AValues;
  Result.ItemIndex := ADefaultValue;

  if AName <> '' then
    Result.Name:= 'cbx_' + AName;
  Result.Width:= AWidth - ALblWidth;

end;


// TRadioGroup
// ----------------------------------------------------------------------------
{
Example:
mTRadioGroup := CreateRadioGroup('FINERadioGrpName', 'Popisek vlevo', 'Popisek boxu', columns, left, right, width, height, label_width, default_index, 'Možnost1'#13#10'Možnost2', mForm);
}
function CreateRadioGroup(AName, ACaption, ABoxCaption: string; AColumns, ALeft, ATop, AWidth, AHeight: Integer; ALblWidth: Integer;
  ADefaultValue: Integer; AValues: string; AParent: TWinControl): TRadioGroup;
var mLbl: TLabel;
begin
  mLbl:= TLabel.Create(AParent);
  mLbl.Parent:= AParent;
  mLbl.Top:= ATop + 5;
  mLbl.Left:= ALeft;
  mLbl.AutoSize:= False;
  if AName <> '' then
    mLbl.Name:= 'lbl_' + AName;
  if ALblWidth > -1 then
  begin
    mLbl.Width:= ALblWidth
  end else
  begin
    mLbl.AutoSize:= True;
    ALblWidth:= mLbl.Width + 10;
  end;
  mLbl.Caption:= ACaption;

  Result:= TRadioGroup.Create(AParent);
  Result.Parent:= AParent;
  Result.Top:= ATop;
  Result.Left:= ALeft + ALblWidth;

  Result.Items.Text := AValues;
  Result.ItemIndex := ADefaultValue;

  if AName <> '' then
    Result.Name:= 'rg_' + AName;
  Result.Caption := ABoxCaption;
  Result.Columns := AColumns;
  Result.Width:= AWidth - ALblWidth;
  Result.Height:= AHeight;

end;

function CreateNumEdit(AName, ACaption: string;
  ALeft, ATop, AWidth: Integer; ALblWidth: Integer; ADefaultValue: double;
  ADecimalPlaces: Integer;
  AParent: TWinControl; AEditToNewLine: Boolean = False): TNumEdit;
var mLbl: TLabel;
begin
  mLbl:= TLabel.Create(AParent);
  mLbl.Parent:= AParent;
  mLbl.Top:= ATop + 5;
  mLbl.Left:= ALeft;
  mLbl.AutoSize:= False;
  if AName <> '' then
    mLbl.Name:= 'lbl_' + AName;
  if ALblWidth > -1 then
  begin
    mLbl.Width:= ALblWidth
  end else
  begin
    mLbl.AutoSize:= True;
    ALblWidth:= mLbl.Width + 10;
  end;
  mLbl.Caption:= ACaption;

  Result:= TNumEdit.Create(AParent);
  Result.Parent:= AParent;
  if not AEditToNewLine then
  begin
    Result.Top:= ATop;
    Result.Left:= ALeft + ALblWidth;
    Result.Width:= AWidth - ALblWidth;
  end else
  begin
    mLbl.Top:= ATop;
    Result.Top:= ATop + mLbl.Height + 2;
    Result.Width:= AWidth;
    Result.Left:= ALeft;
  end;
  if AName <> '' then
    Result.Name:= 'ed_' + AName;

  Result.DecimalPlaces := ADecimalPlaces;
  Result.ThousandSepar := true;
  Result.FormatOnEditing := true;

  Result.Value := ADefaultValue;
end;






begin
end.