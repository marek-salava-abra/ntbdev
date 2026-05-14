

// Formulář typu modální dialog
// ------------------------------------------------------------------------------

function CreateFormDialog(AName, ACaption: String;
                          AParent: TWinControl;
                          AWidth, AHeight: Integer; ): TForm;
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


function CreateButton(AName, ACaption: string;
                      AParent: TWinControl;
                      ALeft, ATop, AWidth, AHeight: Integer;
                      AVisibled,AEnabled:boolean;
                      AFontSize: Integer; AFontStyles: TFontStyles;AFontColor:TColor;
                      AModalResult: integer;
                      ADefault: Boolean
                      ): TButton;
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

function CreateHeadPanel(AName, ACaption:string;
                         AParent: TWinControl;
                         ALeft, ATop, AWidth, AHeight: Integer;
                         AVisibled,AEnabled:boolean;AColor:TColor;
                         AFontSize: Integer; AFontStyles: TFontStyles;AFontColor:TColor): TPanel;
var
  mPanel: TPanel;
begin
  mPanel := TPanel.Create(AParent);
  with mPanel do begin
    Name := 'pnl_'+AName;
    Caption:= '';
    Parent := AParent;
    Align := alTop;
    Left := ALeft;
    Top := ATop;
    Width := AWidth;
    Height := AHeight;
    BevelOuter := bvNone;
    PanelColor := AColor;
  end;

      with TBevel.Create(AParent) do
      begin
        Name := 'blv_'+AName;
        Parent := AParent;
        Left := ALeft+5;
        Top := ATop+5;
        Width := AWidth-5;
        Height := AHeight-5;
        Align := alTop;
        Shape := bsTopLine;
      end;


end;



// Popisek
// ------------------------------------------------------------------------------

function CreateLabel(AName, ACaption: String;
                     AParent: TWinControl;
                     ALeft, ATop, AWidth, AHeight: Integer;
                     AVisibled,AEnabled:boolean;
                     AFontSize: Integer; AFontStyles: TFontStyles;AFontColor:TColor): TLabel;
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
                    AParent: TWinControl;
                    ALeft, ATop, AWidth, AHeight: Integer;
                    ALblWidth: Integer; ADefaultValue: string;
                    AEditToNewLine: Boolean = False;
                    AVisibled,AEnabled:boolean;
                    AFontSize: Integer; AFontStyles: TFontStyles;AFontColor:TColor): TEdit;
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
                        ALeft, ATop, AWidth, AHeight: Integer; ALblWidth: Integer; ADefaultValue: TDate; AParent: TWinControl;
                        AEditToNewLine: Boolean = False;
                        AVisibled,AEnabled:boolean;
                        AFontSize: Integer; AFontStyles: TFontStyles;AFontColor:TColor): TDateEdit;
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


function CreateDateTimeEdit(AName, ACaption: string;
                            AParent: TWinControl;
                            ALeft, ATop, AWidth, AHeight: Integer;

                            ALblWidth: Integer; ADefaultValue: TDateTime;
                            AVisibled,AEnabled:boolean;
                            AFontSize: Integer; AFontStyles: TFontStyles;AFontColor:TColor ;
                            AEditToNewLine: Boolean = False): TDateTimeEdit;
var
  mLbl: TLabel;
  mTime:TTimeEdit;
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

  Result:= TDateTimeEdit.Create(AParent);
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

  Result.Datetime:= ADefaultValue;



end;


function CreateTimeEdit(AName, ACaption: string;
                        AParent: TWinControl;
                        ALeft, ATop, AWidth, AHeight: Integer;
                        ALblWidth: Integer; ADefaultValue: TTime;
                        AVisibled,AEnabled:boolean;
                        AFontSize: Integer; AFontStyles: TFontStyles;AFontColor:TColor;
                        AEditToNewLine: Boolean = False): TtimeEdit;
var
  mLbl: TLabel;
  mtime:TTimeEdit;
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

  Result:= TTimeedit.Create(AParent);
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

  Result.time:= ADefaultValue;
end;

// NxComboAdresEdit
// ------------------------------------------------------------------------------

function CreateNxComboAdresEdit(AName, ACaption: string;
                                AParent: TWinControl;
                                ALeft, ATop, AWidth, AHeight,
                                ALblWidth, ABevelWidth: Integer;
                                AClassID, ATextField, AControlField, AID: string;
                                AParam: string = ''; AChange: string ='';
                                AVisibled,AEnabled:boolean;
                                AFontSize: Integer; AFontStyles: TFontStyles;AFontColor:TColor): TRollComboEdit;
var mLbl, mLbl1,
    mLblChange: TLabel;
    MED_ulice,mED_Mesto,mED_PSc,mED_telefon,mED_kontakt,MED_Email:tedit;
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
  mLbl1.Left:= ALeft +AWidth ;
  mLbl1.AutoSize:= False;
  mLbl1.Caption:= '';
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
  Result.Left:= ALeft + ALblWidth;

   MED_ulice:= TEdit.Create(AParent);
  MED_ulice.Parent:= AParent;
  MED_ulice.Top:= ATop + 10 + mLbl1.Height;
  MED_ulice.Left:= ALeft  ;
  MED_ulice.AutoSize:= False;
  MED_ulice.Text:= 'Ulice hlavní';
  MED_ulice.Width:= AWidth;
  MED_ulice.Visible:= true;
  MED_ulice.enabled:= true;
  MED_ulice.Height:=15;


  MED_Mesto:= TEdit.Create(AParent);
  MED_Mesto.Parent:= AParent;
  MED_Mesto.Top:= MED_ulice.Top +15 ;
  MED_Mesto.Left:= ALeft  ;
  MED_Mesto.AutoSize:= False;
  MED_Mesto.Text:= 'Město';
  MED_Mesto.Width:= AWidth;
  MED_Mesto.Visible:= true;
  MED_Mesto.enabled:= true;
  MED_Mesto.Height:=15;

  MED_Psc:= TEdit.Create(AParent);
  MED_Psc.Parent:= AParent;
  MED_Psc.Top:= MED_Mesto.Top+15;
  MED_Psc.Left:= ALeft  ;
  MED_Psc.AutoSize:= False;
  MED_Psc.Text:= 'PSČ';
  MED_Psc.Width:= AWidth;
  MED_Psc.Visible:= true;
  MED_Psc.enabled:= true;
  MED_Psc.Height:=15;

  MED_Kontakt:= TEdit.Create(AParent);
  MED_Kontakt.Parent:= AParent;
  MED_Kontakt.Top:= MED_Psc.top+15;
  MED_Kontakt.Left:= ALeft  ;
  MED_Kontakt.AutoSize:= False;
  MED_Kontakt.Text:= 'Kontakt';
  MED_Kontakt.Width:= AWidth;
  MED_Kontakt.Visible:= true;
  MED_Kontakt.enabled:= true;
  MED_Kontakt.Height:=15;

  MED_Telefon:= TEdit.Create(AParent);
  MED_Telefon.Parent:= AParent;
  MED_Telefon.Top:= MED_Kontakt.Top+15;
  MED_Telefon.Left:= ALeft  ;
  MED_Telefon.AutoSize:= False;
  MED_Telefon.Text:= 'Telefon';
  MED_Telefon.Width:= AWidth;
  MED_Telefon.Visible:= true;
  MED_Telefon.enabled:= true;
  MED_Telefon.Height:=15;

  MED_Email:= TEdit.Create(AParent);
  MED_Email.Parent:= AParent;
  MED_Email.Top:= MED_Telefon.Top+15;
  MED_Email.Left:= ALeft  ;
  MED_Email.AutoSize:= False;
  MED_Email.Text:= 'Email';
  MED_Email.Width:= AWidth;
  MED_Email.Visible:= true;
  MED_Email.enabled:= true;
  MED_Email.Height:=15;



  if AControlField <> '' then
  begin
    Result.ConnectedControlField:= AControlField;
    Result.ConnectedControl:= MED_ulice;
    Result.ConnectedControl:= MED_mesto;
    Result.ConnectedControl:= MED_psc;
    Result.ConnectedControl:= MED_kontakt;
    Result.ConnectedControl:= MED_telefon;
    Result.ConnectedControl:= MED_email;
  end;

  if AName <> '' then
    Result.Name:= 'ced_' + AName;
  Result.DataText:= AID;
  Result.Width:= AWidth - ALblWidth - ABevelWidth;







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


  mLbl1.Left:= mLbl1.Left + 10;
  mLbl1.Width:= mLbl1.Width - 10;
end;


// NxComboEdit
// ------------------------------------------------------------------------------

function CreateNxComboEdit(AName, ACaption: string;
                           AParent: TWinControl;
                           ALeft, ATop, AWidth, AHeight,
                           ALblWidth, ABevelWidth: Integer;
                           AClassID, ATextField, AControlField, AID: string;
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
  mLbl1.Left:= ALeft +AWidth ;
  mLbl1.AutoSize:= False;
  mLbl1.Caption:= '';
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
  Result.Left:= ALeft + ALblWidth;
  if AControlField <> '' then
  begin
    Result.ConnectedControlField:= AControlField;
    Result.ConnectedControl:= mLbl1;
  end;

  if AName <> '' then
    Result.Name:= 'ced_' + AName;
  Result.DataText:= AID;
  Result.Width:= AWidth - ALblWidth - ABevelWidth;


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


  mLbl1.Left:= mLbl1.Left + 10;
  mLbl1.Width:= mLbl1.Width - 10;
end;


// TCheckBox
// ------------------------------------------------------------------------------

function CreateCheckBox(AName, ACaption: string;
                        AParent: TWinControl;
                        ALeft, ATop, AWidth, AHeight: Integer;
                        ADefaultValue: Boolean): TCheckBox;
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

function CreateComboBox(AName, ACaption: string; ALeft, ATop, AWidth, AHeight: Integer; ALblWidth: Integer;
  ADefaultValue, AValues: string; AParent: TWinControl): TComboBox;
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

  Result:= TComboBox.Create(AParent);
  Result.Parent:= AParent;
  Result.Top:= ATop;
  Result.Left:= ALeft + ALblWidth;
  Result.Items.Text:= AValues;

  if AName <> '' then
    Result.Name:= 'cbx_' + AName;
  Result.Width:= AWidth - ALblWidth;

  Result.Text:= '';
  Result.ItemIndex:= -1;
  Result.ItemIndex:=
    Result.Items.IndexOf(ADefaultValue);
end;





begin
end.