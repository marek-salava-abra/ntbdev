//hotove formulare

uses
  'StandardUnits.U_Components';

////////////////////////////////////////////////////////////////////////////////
//je tu hlavne pro kontrolu, z volam funkci spravne.
//pokud vim co delam, tak musu nastavit na FALSE
function HlasAN(txt: string; Form: TForm; CheckFormAssigned: boolean = true): boolean;
begin
  //kontrola, ze jsem si predal formular
  if(CheckFormAssigned)then begin
    if(not Assigned(Form))then
      RaiseException('CHYBA: funkkce HlasAN: Form=nil');
    if(not Assigned(Form.FindParentForm))then
      RaiseException('CHYBA: funkkce HlasAN: Form.FindParentForm=nil');
  end;

  result:= NxMessageBox('Dotaz', txt, mdConfirm, mdbYesNo, 0, 0, False, Form.FindParentForm) = mrYes;
end;//HlasAN
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//formular na zadani Datumu
function Form_Date(aForm: TForm; aCaption, aLabel: string; var datum: Tdate) : boolean;
var
  mForm  : TForm;
  mLab   : TLabel;
  mEd1   : TDateEdit;
  mPanel : TPanel;
  mResult: integer;

  procedure Form_OnKeyDown(Sender: TForm; var Key: Word; Shift: TShiftState);
  begin
    //ShowMessage(inttostr(key));
    if (length(shift)=0)and (key=VK_RETURN) then begin
      TButton(Sender.FindComponent('bOK')).SetFocus;
      Sender.ModalResult:=mrok;
      Key:= 0;
    end;
  end;

begin
  result := false;

  mForm:= Create_FormOKCancel(aForm, mPanel, aCaption, 350, 80);
  try
    mform.KeyPreview:=true;
    mform.OnKeyDown:= 'Form_OnKeyDown';

    mLab         := TLabel.Create(mForm);
    mLab.Left    := 10;
    mLab.Top     := 10;
    mLab.Caption := aLabel;
    mLab.Parent  := mPanel;
    mLab.Transparent:= true;

    mEd1         := TDateEdit.Create(mForm);
    mEd1.Width   := 170;
    mEd1.Left    := mForm.Width - 20 - mEd1.Width;
    mEd1.Top     := 8;
    mEd1.parent  := mPanel;
    mEd1.Date    := datum;

    //spustim fomrular
    mResult := mForm.Showmodal(aForm.FindParentForm);
    if mResult = 1 then
    begin
      result := true;
      datum := med1.Date;
    end;
  finally
    mForm.free;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//formular na zadani Datumu od/do
function Form_DateOdDo(aForm: TForm; aCaption, aLabelOd, aLabelDo: string; var datumOd,DatumDo: Tdate) : boolean;
var
  mForm  : TForm;
  mLab   : TLabel;
  mEd1,mEd2   : TDateEdit;
  mPanel : TPanel;
  mResult: integer;

  procedure Form_OnKeyDown(Sender: TForm; var Key: Word; Shift: TShiftState);
  begin
    //ShowMessage(inttostr(key));
    if (length(shift)=0)and (key=VK_RETURN) then begin
      TButton(Sender.FindComponent('bOK')).SetFocus;
      Sender.ModalResult:=mrok;
      Key:= 0;
    end;
  end;

begin
  result := false;

  mForm:= Create_FormOKCancel(aForm, mPanel, aCaption, 350, 110);
  try
    mform.KeyPreview:=true;
    mform.OnKeyDown:= 'Form_OnKeyDown';

    mLab         := TLabel.Create(mForm);
    mLab.Left    := 10;
    mLab.Top     := 10;
    mLab.Caption := aLabelOd;
    mLab.Parent  := mPanel;
    mLab.Transparent:= true;

    mEd1         := TDateEdit.Create(mForm);
    mEd1.Width   := 170;
    mEd1.Left    := mForm.Width - 20 - mEd1.Width;
    mEd1.Top     := 8;
    mEd1.parent  := mPanel;
    mEd1.Date    := datumOd;

    mLab         := TLabel.Create(mForm);
    mLab.Left    := 10;
    mLab.Top     := 40;
    mLab.Caption := aLabelDo;
    mLab.Parent  := mPanel;
    mLab.Transparent:= true;

    mEd2         := TDateEdit.Create(mForm);
    mEd2.Width   := 170;
    mEd2.Left    := mForm.Width - 20 - mEd2.Width;
    mEd2.Top     := 38;
    mEd2.parent  := mPanel;
    mEd2.Date    := datumDo;

    //spustim fomrular
    mResult := mForm.Showmodal(aForm.FindParentForm);
    if mResult = 1 then
    begin
      result := true;
      datumOd := med1.Date;
      datumDo := med2.Date;
    end;
  finally
    mForm.free;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//Formular na zadani desetinneho cisla
function Form_Double(aForm: TForm; aCaption, aLabel: string; var number: double; aDecimalPlaces: Integer = 3) : boolean;
var
  mForm  : TForm;
  mLab   : TLabel;
  mEd1   : TNumEdit;
  mPanel : TPanel;
  mResult: integer;

  procedure Form_OnKeyDown(Sender: TForm; var Key: Word; Shift: TShiftState);
  begin
    //ShowMessage(inttostr(key));
    if (length(shift)=0)and (key=VK_RETURN) then begin
      TButton(Sender.FindComponent('bOK')).SetFocus;
      Sender.ModalResult:=mrok;
      Key:= 0;
    end;
  end;

begin
  result:= false;

  mForm:= Create_FormOKCancel(aForm, mPanel, aCaption, 350, 80);
  try
    mform.KeyPreview:=true;
    mform.OnKeyDown:= 'Form_OnKeyDown';

    mLab         := TLabel.Create(mForm);
    mLab.Left    := 10;
    mLab.Top     := 10;
    mLab.Caption := aLabel;
    mLab.Parent  := mPanel;
    mLab.Transparent:= true;

    mEd1         := TNumEdit.Create(mForm);
    mEd1.Left    := mForm.Width - 20 - 200;//110;
    mEd1.top     := mlab.Top+mlab.Height-med1.Height+4;
    mEd1.Width   := 200;
    mEd1.parent  := mPanel;
    mEd1.Value   := number;
    mEd1.DecimalPlaces := aDecimalPlaces;

    //spustim fomrular
    mResult := mForm.Showmodal(aForm.FindParentForm);
    if mResult = mrOk then
    begin
      result := true;
      number := mEd1.Value;
    end;
  finally
    mForm.free;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//Formular na zadani textu
function Form_Text(aForm: TForm; aCaption, aLabel: string; var text: string; aFormWidth: integer = 350; aLength: Integer = 0) : boolean;
var
  mForm  : TForm;
  mLab   : TLabel;
  mEd1   : TEdit;
  mPanel : TPanel;
  mResult: integer;

  procedure Form_OnKeyDown(Sender: TForm; var Key: Word; Shift: TShiftState);
  begin
    //ShowMessage(inttostr(key));
    if (length(shift)=0)and (key=VK_RETURN) then begin
      TButton(Sender.FindComponent('bOK')).SetFocus;
      Sender.ModalResult:=mrok;
      Key:= 0;
    end;
  end;

begin
  result:= false;

  mForm:= Create_FormOKCancel(aForm, mPanel, aCaption, aFormWidth, 80);
  try
    mform.KeyPreview:=true;
    mform.OnKeyDown:= 'Form_OnKeyDown';

    mLab         := TLabel.Create(mForm);
    mLab.Left    := 10;
    mLab.Top     := 10;
    mLab.Caption := aLabel;
    mLab.Parent  := mPanel;
    mLab.Transparent:= true;

    mEd1         := TEdit.Create(mForm);
    mEd1.Left    := mLab.Left + mLab.Width + 10;
    mEd1.top     := mlab.Top+mlab.Height-med1.Height+4;
    mEd1.Width   := mForm.Width - mEd1.Left - 20;
    mEd1.parent  := mPanel;
    mEd1.Text   := text;
    if(aLength > 0)then
      mEd1.MaxLength := aLength;

    //spustim fomrular
    mResult := mForm.Showmodal(aForm.FindParentForm);
    if mResult = mrOk then
    begin
      result := true;
      text := mEd1.Text;
    end;
  finally
    mForm.free;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

begin
end.