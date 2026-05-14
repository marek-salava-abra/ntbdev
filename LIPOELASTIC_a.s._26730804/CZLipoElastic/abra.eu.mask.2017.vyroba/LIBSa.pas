function CreateProgressInfo(AForm: TForm; AProcCount: Integer; AInfo: string): TForm;
var
  mForm: TForm;
  mProgr: TProgressBar;
  mLabel: TLabel;
begin
  mForm := TForm.Create(AForm);
  with mForm do begin
    Width := 380;
    Height := 131;
    Caption := 'Prubeh zpracovani';
    Position := poScreenCenter;//OwnerFormCenter;
    FormStyle := fsStayOnTop;
    BorderStyle := bsDialog;
    with TLabel.Create(mForm) do begin
      Parent := mForm;
      Left := 8;
      Top := 16;
      Width := 300;
      Height := 16;
      //AutoSize := False;
      Name := 'lblInfoLabel';
      Caption := AInfo;
      Transparent := True;
      //WordWrap := True;
      Font.Height := -13;
      Font.Style := [fsBold];
      Tag := 3;
    end;
    with TProgressBar.Create(mForm) do begin
      Parent := mForm;
      Left := 8;
      Top := 48;
      Width := 353;
      Height := 33;
      Tag := 3;
      Name := 'pgInfoBar';
      Max := AProcCount;
      Position := 0;
    end;
  end;
  Result := mForm;
end;



function GetFloatFromTable(xSite:TSiteForm;Msql:string;mstorecard_ID:string;mfiltr:string):double;
var
mr_local:tstringlist;
begin
    mr_local:=tstringlist.create;
    try
       xsite.BaseObjectSpace.SQLSelect(format(Msql,[quotedstr(mstorecard_ID),mfiltr]),mr_local) ;
       if NxIBStrToFloat(mr_local.Strings[0])> 0 then begin
            result:=NxIBStrToFloat(mr_local.Strings[0])
       end else begin
            result:=0;
       end     ;
    finally
       mr_local.free;
    end;
end;

function GetStringFromTable(xSite:TSiteForm;Msql:string;mstoreean:string;mfiltr:string):string;
var
mr_local:tstringlist;
begin
    result:='';
    mr_local:=tstringlist.create;
    try
       xsite.BaseObjectSpace.SQLSelect(format(Msql,[quotedstr(mstoreean),mfiltr]),mr_local) ;
       if mr_local.count>0 then result:=(mr_local.Strings[0]) ;
    finally
       mr_local.free;
    end;
end;


function GetDocument_ID(xSite:TSiteForm;mtable:string;mDocNumber:string):string;
var
mr_local:tstringlist;
mDocqueue_code,mOrdnumbe_code,mPeriod_code:string;
begin
  mDocqueue_code:='';
  mOrdnumbe_code:='';
  mPeriod_code:='';

  mDocqueue_code:=NxLeft(mDocNumber,NxAt('-',mDocNumber)-1);
  mOrdnumbe_code:=Copy(mDocNumber,NxAt('-',mDocNumber)+1,NxAt('/',mDocNumber)-NxAt('-',mDocNumber)-1);
  mPeriod_code:=Copy(mDocNumber,NxAt('/',mDocNumber)+1,100) ;

  if (mDocqueue_code='') or
     (mOrdnumbe_code='') or
     (mPeriod_code= '') then begin
     NxShowSimpleMessage('Dokladnení v korektním formátu',nil);
     result:='';
  end else begin

              mr_local:=TStringList.create;
              try
                 xsite.BaseObjectSpace.SQLSelect(format('select a.id from %s A left join Periods p on p.id=A.Period_ID left join DocQueues DQ on DQ.id=A.DocQueue_ID where DQ.code=%s and A.ordnumber=%s and P.code=%s',
                 [mtable,quotedstr(mDocqueue_code),mOrdnumbe_code ,
                         quotedstr(mPeriod_code)]),mr_local) ;
                 if mr_local.count=0 then result:='';
                 if mr_local.count=1 then result:= mr_local.Strings[0];
                 if mr_local.count>1 then result:= 'Více';

              finally
                 mr_local.free;
              end;
  end;
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


function GetDate(Sender: TComponent;xSite:TSiteForm) : Date;
var
  mForm : TForm;
  mBtn : TButton;
  mlb2 : TLabel;
  mEdtSrc:TDateEdit;
begin
        try
              mForm := TForm.Create(xSite);            // formulář
                mForm.BorderIcons := [biSystemMenu];
                mForm.Width := 240;  // sirka
                mForm.Height := 100; // vyska
                mForm.Caption := 'Zadej datum servisu';
                    mLb2 := TLabel.Create(mForm);         // položka řada
                    mLb2.Caption := 'Zadej datum:';
                    mLb2.Left := 30;
                    mLb2.Top := 10;
                    mLb2.Name := 'lblDocQueues';
                    mForm.InsertControl(mLb2);
                        mEdtSrc := TDateEdit.Create(mForm);
                        mEdtSrc.Left := 100;
                        mEdtSrc.Top := 10;
                        mEdtSrc.Width := 100;
                        mEdtSrc.Name := 'edtDate';
                        mEdtSrc.Date:= date;
                        mForm.InsertControl(mEdtSrc);
                  mBtn := TButton.Create(mForm);            // tlačítko OK
                        mBtn.Width := 75;
                        mBtn.Height := 25;
                        mBtn.Caption := 'OK';
                        mBtn.ModalResult := mrOk;
                        mBtn.Cancel := False;
                        mBtn.Default := True;
                        mBtn.Left :=  mForm.Width - 2*(mBtn.Width+2) - 20;
                        mBtn.Top := mForm.Height - mBtn.Height - 40;
                        mBtn.Name := 'btnOK';
                        mForm.InsertControl(mBtn);
                    mBtn := TButton.Create(mForm);          // tlačítko storno
                        mBtn.Width := 75;
                        mBtn.Height := 25;
                        mBtn.Caption := 'Storno';
                        mBtn.ModalResult := mrCancel;
                        mBtn.Cancel := True;
                        mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;;
                        mBtn.Top := mForm.Height - mBtn.Height - 40;
                        mBtn.Name := 'btnCancel';
                        mForm.InsertControl(mBtn);

           if mForm.ShowModal(xSite) = mrOK then begin
                result:=mEdtSrc.Date;
           end;
        finally;
          mForm.Free;
        end;
end;

// Formulář typu modální dialog
// ------------------------------------------------------------------------------


// Memo box
// ------------------------------------------------------------------------------

function SQLSelectValue(SQLObjectSpace : TNxCustomObjectSpace; query : String;) : String;
var
  mList : TStrings;
begin
  Result := '';
  mList := TStringList.Create;
  try
    SQLObjectSpace.SQLSelect(query, mList);
    if mList.Count > 0 then begin
      if (NxLeft(mList.Strings[0], 1) = '"') and (NxRight(mList.Strings[0], 1) = '"') then begin
        Result := NxExtractQuotedString(mList.Strings[0], '"');
      end else begin
        Result := mList.Strings[0];
      end;
    end;
  finally
    mList.Free;
  end;
end;


function CreateMemo(AName, ACaption: string;
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



function CreateFormDialog(AName, ACaption: String;
                          AParent: TWinControl;
                          AWidth, AHeight: Integer; ): TForm;
var
  mForm: TForm;
  var
mFont: TFont;
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


function CreateButton(AName, ACaption: string; AModalResult: integer;
                      AParent: TWinControl;
                      ALeft, ATop, AWidth, AHeight: Integer;
                      AVisibled,AEnabled:boolean;
                      AFontSize: Integer; AFontStyles: TFontStyles;AFontColor:TColor;
                      ABorderColor:Tcolor;
                      ADefault: Boolean ;ACancel: Boolean
                      ): TButton;
 var
mFont: TFont;
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
  mFont := Result.Font;
  if AFontSize >= 0 then begin
     mFont.Size := AFontSize;
     mFont.Style := AFontStyles;
  end;
    Result.Cancel := ACancel;

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
  mFont := mLbl.Font;
  if AFontSize >= 0 then
     mFont.Size := AFontSize;
     mFont.Style := AFontStyles;
  if AWidth <> -1 then
  begin
    mLbl.AutoSize:= true;
    mlbl.Alignment:=taCenter;
    mLbl.Width:= AWidth;
  end else
    mLbl.AutoSize:= True;
  mLbl.Caption:= ACaption;




  Result:= mLbl;
end;


function CreateEdit(AName, ACaption: string;
                    AParent: TWinControl;
                    ALeft, ATop, AWidth, AHeight: Integer;
                    ALblWidth: Integer; ADefaultValue: string;
                    AEditToNewLine: Boolean = False;
                    AVisible,AEnabled:boolean;
                    AFontSize: Integer; AFontStyles: TFontStyles;AFontColor:TColor): TEdit;
var
 mLbl: TLabel;
 mFont: TFont;
 mtedit:tedit;
begin
  mLbl:= TLabel.Create(AParent);
  mLbl.Parent:= AParent;
  mLbl.Top:= ATop + 5;
  mLbl.Left:= ALeft;
  mlbl.Alignment:=taCenter;
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
  Result.enabled:=AEnabled ;
  Result.Visible:=AVisible;
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


    mFont := Result.Font;
    //mfont.:=left;
  if AFontSize >= 0 then begin
     mFont.Size := AFontSize;
     mFont.Style := AFontStyles;
  end;

  Result.Text:= ADefaultValue ;
end;


function CreateEdit_noformat(AName, ACaption: string;
                    AParent: TWinControl;
                    ALeft, ATop, AWidth, AHeight: Integer;
                    ALblWidth: Integer; ADefaultValue: string;
                    AEditToNewLine: Boolean = False;
                    AVisible,AEnabled:boolean;
                    AFontSize: Integer; AFontStyles: TFontStyles;AFontColor:TColor): TEdit;
var
 mLbl: TLabel;
 mFont: TFont;
 mtedit:tedit;
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
  Result.enabled:=AEnabled ;
  Result.Visible:=AVisible;
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


    mFont := Result.Font;
    //mfont.:=left;
  if AFontSize >= 0 then begin
     mFont.Size := AFontSize;
     //mFont.Style := AFontStyles;
  end;

  Result.Text:= ADefaultValue ;
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
  //mLbl.Caption:= ACaption;

  mLbl1:= TLabel.Create(AParent);
  mLbl1.Parent:= AParent;
  mLbl1.Top:= ATop + 5;
  mLbl1.Left:= ALeft +AWidth ;
  mLbl1.AutoSize:= False;
  //mLbl1.Caption:= '';
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
  MED_ulice.EditText:= 'Ulice hlavní';
  MED_ulice.Width:= AWidth;
  MED_ulice.Visible:= true;
  MED_ulice.enabled:= true;
  MED_ulice.Height:=15;


  MED_Mesto:= TEdit.Create(AParent);
  MED_Mesto.Parent:= AParent;
  MED_Mesto.Top:= MED_ulice.Top +15 ;
  MED_Mesto.Left:= ALeft  ;
  MED_Mesto.AutoSize:= False;
  MED_Mesto.EditText:= 'Město';
  MED_Mesto.Width:= AWidth;
  MED_Mesto.Visible:= true;
  MED_Mesto.enabled:= true;
  MED_Mesto.Height:=15;

  MED_Psc:= TEdit.Create(AParent);
  MED_Psc.Parent:= AParent;
  MED_Psc.Top:= MED_Mesto.Top+15;
  MED_Psc.Left:= ALeft  ;
  MED_Psc.AutoSize:= False;
  MED_Psc.EditText:= 'PSČ';
  MED_Psc.Width:= AWidth;
  MED_Psc.Visible:= true;
  MED_Psc.enabled:= true;
  MED_Psc.Height:=15;

  MED_Kontakt:= TEdit.Create(AParent);
  MED_Kontakt.Parent:= AParent;
  MED_Kontakt.Top:= MED_Psc.top+15;
  MED_Kontakt.Left:= ALeft  ;
  MED_Kontakt.AutoSize:= False;
  MED_Kontakt.EditText:= 'Kontakt';
  MED_Kontakt.Width:= AWidth;
  MED_Kontakt.Visible:= true;
  MED_Kontakt.enabled:= true;
  MED_Kontakt.Height:=15;

  MED_Telefon:= TEdit.Create(AParent);
  MED_Telefon.Parent:= AParent;
  MED_Telefon.Top:= MED_Kontakt.Top+15;
  MED_Telefon.Left:= ALeft  ;
  MED_Telefon.AutoSize:= False;
  MED_Telefon.EditText:= 'Telefon';
  MED_Telefon.Width:= AWidth;
  MED_Telefon.Visible:= true;
  MED_Telefon.enabled:= true;
  MED_Telefon.Height:=15;

  MED_Email:= TEdit.Create(AParent);
  MED_Email.Parent:= AParent;
  MED_Email.Top:= MED_Telefon.Top+15;
  MED_Email.Left:= ALeft  ;
  MED_Email.AutoSize:= False;
  MED_Email.EditText:= 'Email';
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
    //mLblChange.Caption:= AChange;
    Result.OnChange:= @NxDBComboEditChange;
  end;


  mLbl1.Left:= mLbl1.Left + 10;
  mLbl1.Width:= mLbl1.Width - 10;
end;


function ADRCreateNxComboEdit(AName, ACaption: string;
                           AParent: TWinControl;
                           ALeft, ATop, AWidth, AHeight,
                           ALblWidth, ABevelWidth: Integer;
                           AClassID, ATextField, AControlField, AID: string;
                           AParam: string = ''; AChange: string =''): TRollComboEdit;
var mLbl,
    mLblChange: TLabel;
    mLbl1:TEdit;
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

  mLbl1:= TEdit.Create(AParent);
  mLbl1.Parent:= AParent;
  mLbl1.Top:= ATop + 5;
  mLbl1.Left:= ALeft +AWidth ;
  mLbl1.AutoSize:= False;
  mLbl1.EditText:= '';
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
    //mLblChange.Caption:= AChange;
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
                           AParam: string = ''; AChange: string ='';
                           AVisibled,AEnabled:boolean;
                           AFontSize: Integer; AFontStyles: TFontStyles;AFontColor:TColor): TRollComboEdit;
var mLbl, mLbl1,
    mLblChange: TLabel;
    mFont: TFont;
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
      mFont := Result.Font;
  if AFontSize >= 0 then begin
     mFont.Size := AFontSize;
     mFont.Style := AFontStyles;
  end;

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

function mBO_Create_Search(xSite:TSiteForm;mCLSID:string;mtable:string;mID:string;mNew:boolean):TNxCustomBusinessObject ;
var
mr:tstringlist;
msql:string;
mBO:TNxCustomBusinessObject;
begin
   if mid<>'' then begin
         msql:='select id from %s where id=%s';
         mr:=tstringlist.create;
         try
            xsite.BaseObjectSpace.SQLSelect(format(msql,[mtable,quotedstr(mid)]),mr);
            if mr.count=0 then begin
               mid:='';
            end;
         finally
            mr.free;
         end;
    end;

   mbo:=xsite.BaseObjectSpace.CreateObject(QuotedStr(mCLSID));
   try
      if mnew then begin
          if mid='' then begin
             mBO.new;
             mBO.Prefill;
          end else begin
              mBO.load(mid,nil);
          end;
      end else begin
          if mid='' then begin
             NxShowSimpleMessage('Objekt nenalezen', nil);
          end else begin
              mBO.load(mid,nil);
          end;
      end;
      result:=mbo;
    finally
       mbo.free;
    end;
end;






begin
end.