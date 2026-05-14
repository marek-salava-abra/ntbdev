

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

 function FNCreateMemo(AName, ACaption: string;
  ALeft, ATop, AWidth, AHeight: Integer; ALblWidth: Integer; ADefaultValue: string; AParent: TWinControl;
  AEditToNewLine: Boolean = False; AVisibled,AEnabled:boolean; AFontSize: Integer; AFontStyles: TFontStyles;AFontColor:TColor): TMemo;
var
mLbl: TLabel;
mFont: TFont;
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

  Result:= TMemo.Create(AParent);
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
  Result.Height := AHeight;
  if AName <> '' then
    Result.Name:= 'ed_' + AName;
  Result.enabled:=AEnabled ;
  Result.Visible:=AVisibled;
  mFont := Result.Font;
    //mfont.:=left;
  if AFontSize >= 0 then begin
     mFont.Size := AFontSize;
     mFont.Style := AFontStyles;
  end;






  Result.Text:= ADefaultValue;
end;




 function FNResult_string(xSite:TSiteForm;
                          mTop:integer;mLeft:integer;mWith:integer;mHeight:integer;mLabel:string;
                          mPopis,mString:string;mbutton8,mbutton7,mbutton6,mbutton5,mbutton4,mbutton3,mbutton2,mbutton1:string):string;
var
      mForm : TForm;
      mBtn1,mBtn2,mBtn3,mBtn4,mBtn5,mBtn6,mBtn7,mBtn8 : TButton;
      mLbl : TLabel;
      mBarCodeEdt : TEdit;
      i:integer;
      xresult:Variant;
      //mSCEdt:TRollComboEdit;
      mSCEdt:TEdit;
      ABarCode,mbarcode:string;
      mi_resulta:integer;
      mBatch_id,mStorecard_id,m_umisteni,mjednotka:string;
      mr,mr1:tstringlist;
      mBO,mSSC:TNxCustomBusinessObject;
      mi_SQL:integer;
      mStrins_id,mS_doklady:string;
      mMemNote:TMemo;
      mNumberButton:Integer;
begin
      mNumberButton:=0;
      Result :='' ;
            try
           mForm := TForm.Create(xsite);
           if True then mForm.Color := clBtnFace else mForm.Color:= clRed ;
                                  mForm.Caption := mLabel;mForm.FormStyle := fsStayOnTop;mForm.BorderStyle := bsDialog;
                                  if mTop>=0 then begin
                                    mForm.Top:= mTop;
                                    mForm.Left:= mLeft;
                                  end else begin
                                    mform.Position := poScreenCenter;
                                  end;

                                  mForm.Width := mWith;mForm.Height := mHeight;mForm.Scaled := False;
                                  mMemNote := FNCreateMemo('ChMemNote',mPopis, 10, 20, mWith-40,mHeight-140, 80, mString, mForm,true,true,True,round(180/24), [fsNormal],255);


                                 if mbutton1<>'' then mNumberButton:= mNumberButton + 1;
                                 if mbutton2<>'' then mNumberButton:= mNumberButton + 1;
                                 if mbutton3<>'' then mNumberButton:= mNumberButton + 1;
                                 if mbutton4<>'' then mNumberButton:= mNumberButton + 1;
                                 if mbutton5<>'' then mNumberButton:= mNumberButton + 1;
                                 if mbutton6<>'' then mNumberButton:= mNumberButton + 1;
                                 if mbutton7<>'' then mNumberButton:= mNumberButton + 1;
                                 if mbutton8<>'' then mNumberButton:= mNumberButton + 1;


                                 if mbutton1<>'' then mBtn1 := TButton.Create(mForm);mBtn1.Width := Trunc((mWith-40)/mNumberButton);mBtn1.Height := 40;mBtn1.Caption := mbutton1;mBtn1.ModalResult := 2;mBtn1.Cancel := True; mBtn1.Left := 17;                       mBtn1.Top := mForm.Height - mBtn1.Height - 45;mBtn1.Name := 'btnCancel';mForm.InsertControl(mBtn1);
                                 if mbutton2<>'' then mBtn1 := TButton.Create(mForm);mBtn1.Width := Trunc((mWith-40)/mNumberButton);mBtn1.Height := 40;mBtn1.Caption := mbutton2;mBtn1.ModalResult := 1;mBtn1.Cancel := False;mBtn1.Left := 17 + (1*(mBtn1.Width+2)) ;mBtn1.Top := mForm.Height - mBtn1.Height - 45;mBtn1.Name := 'btnOK';mForm.InsertControl(mBtn1);

                                 if mbutton3<>'' then mBtn1 := TButton.Create(mForm);mBtn1.Width := Trunc((mWith-40)/mNumberButton);mBtn1.Height := 40;mBtn1.Caption := mbutton3;mBtn1.ModalResult := 3;mBtn1.Cancel := False;mBtn1.Left := mForm.Width - 35 - (mBtn1.Width *mNumberButton) + (2*(mBtn1.Width+2)) ;mBtn1.Top := mForm.Height - mBtn1.Height - 45;mBtn1.Name := 'btnYES';mForm.InsertControl(mBtn1);
                                 if mbutton4<>'' then mBtn1 := TButton.Create(mForm);mBtn1.Width := Trunc((mWith-40)/mNumberButton);mBtn1.Height := 40;mBtn1.Caption := mbutton4;mBtn1.ModalResult := 4;mBtn1.Cancel := False;mBtn1.Left := mForm.Width - 35 - (mBtn1.Width *mNumberButton) + (3*(mBtn1.Width+2)) ;mBtn1.Top := mForm.Height - mBtn1.Height - 45;mBtn1.Name := 'btnNo';mForm.InsertControl(mBtn1);
                                 if mbutton5<>'' then mBtn1 := TButton.Create(mForm);mBtn1.Width := Trunc((mWith-40)/mNumberButton);mBtn1.Height := 40;mBtn1.Caption := mbutton5;mBtn1.ModalResult := 5;mBtn1.Cancel := False;mBtn1.Left := mForm.Width - 35 - (mBtn1.Width *mNumberButton) + (4*(mBtn1.Width+2)) ;mBtn1.Top := mForm.Height - mBtn1.Height - 45;mBtn1.Name := 'btnNew';mForm.InsertControl(mBtn1);
                                 if mbutton6<>'' then mBtn1 := TButton.Create(mForm);mBtn1.Width := Trunc((mWith-40)/mNumberButton);mBtn1.Height := 40;mBtn1.Caption := mbutton6;mBtn1.ModalResult := 6;mBtn1.Cancel := False;mBtn1.Left := mForm.Width - 35 - (mBtn1.Width *mNumberButton) + (5*(mBtn1.Width+2)) ;mBtn1.Top := mForm.Height - mBtn1.Height - 45;mBtn1.Name := 'btnUpdate';mForm.InsertControl(mBtn1);
                                 if mbutton7<>'' then mBtn1 := TButton.Create(mForm);mBtn1.Width := Trunc((mWith-40)/mNumberButton);mBtn1.Height := 40;mBtn1.Caption := mbutton7;mBtn1.ModalResult := 7;mBtn1.Cancel := False;mBtn1.Left := mForm.Width - 35 - (mBtn1.Width *mNumberButton) + (6*(mBtn1.Width+2)) ;mBtn1.Top := mForm.Height - mBtn1.Height - 45;mBtn1.Name := 'btnSave';mForm.InsertControl(mBtn1);
                                 if mbutton8<>'' then mBtn1 := TButton.Create(mForm);mBtn1.Width := Trunc((mWith-40)/mNumberButton);mBtn1.Height := 40;mBtn1.Caption := mbutton8;mBtn1.ModalResult := 8;mBtn1.Cancel := False;mBtn1.Left := mForm.Width - 35 - (mBtn1.Width *mNumberButton) + (7*(mBtn1.Width+2)) ;mBtn1.Top := mForm.Height - mBtn1.Height - 45;mBtn1.Name := 'btnDelete';mForm.InsertControl(mBtn1);




                                 result:= IntToStr(mForm.ShowModal(xsite));   // změna položky

      finally
        mform.Free;
      end;



end;





begin
end.