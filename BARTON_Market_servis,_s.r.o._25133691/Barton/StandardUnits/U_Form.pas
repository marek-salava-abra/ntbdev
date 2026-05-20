//POZOR: Zastarala unita. Nove pouzivejte StandardForm.U_Components
var
  //toto musi byt globalni promenna, protoze udalost OnGeTNxContext ktera ji potrebuje,
  //nema zadny parametr (ObjectSpace), aby si jej mohla vyvorit.
  gFormContext: TNxContext;

  //Pouziti
  //je potreba pred vytvorenim fomrulare inicializovat kontext a po uvoleneni jej zase uvolnit
  (*
  gFormContext:= NxCreateContext(Self.BaseObjectSpace);
  mForm:= FormOKCancel(Self.GetSiteAppForm, mPanel, 'x', 300, 200);
  try
    xNaklZnacka:= Create_ComboEditLink(Self, mPanel, 'X_Ciselnik', 'O3ZO2K155FDL3CL100C4RHECN0',
      'Code', 'Name', 10, 10, 100, 'Nakl. znaeka:', 75);
    if(mForm.ShowModal = mrOk)then begin
    end;
  finally
    mForm.free;
    gFormContext.free;
  end;
  *)


////////////////////////////////////////////////////////////////////////////////
procedure ComboEditGetContext(Sender: TObject; var AContext: TNxContext);
begin
  AContext := gFormContext;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
{

NOVE V UNITE StandardForm.U_Func

function HlasAN(txt: string): boolean;
begin
  result:= NxMessageBox('Dotaz', txt, mdConfirm, mdbYesNo, 0, 0, False, Nil) = mrYes;
end;//HlasAN     }
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//vytvoreni Buttonu
function CreateButton(AOwner: TComponent; AParent: TWinControl; ATop, ALeft, AWidth, AHeight: integer; AName, ACaption: string; AModalResult: integer): TButton;
begin
  Result             := TButton.Create(AOwner);
  Result.Top         := ATop;
  Result.Left        := ALeft;
  Result.Width       := AWidth;
  Result.Height      := AHeight;
  Result.Name        := AName;
  Result.Caption     := ACaption;
  Result.ModalResult := AModalResult;
  Result.Parent      := AParent;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//vytvoreni TextEditu vcetne labelu
function Create_TextExit(
    aForm  : tForm;
    aParent: TWinControl;
    aName  : string;
    aTop, aLeft, aWidth: integer;
    aLabel: string; aLabelWidth: integer
  ): TEdit;
var
  mLabel : TLabel;
  mEdit  : TEdit;
begin
  if(aLabel <> '')then begin
    mLabel:= TLabel.Create(aForm);
    mLabel.Parent:= aParent;
    mLabel.Top   := aTop+3;
    mLabel.Left  := aLeft;
    mLabel.Width := aLabelWidth;
    mLabel.Caption := aLabel;
    mLabel.Transparent:= true;
  end;

  mEdit:= TEdit.Create(aForm);
  mEdit.Parent     := aParent;
  mEdit.Name       := aName;
  mEdit.Text       := '';
  mEdit.Top        := aTop;
  if (aLabel <> '') then
    mEdit.Left       := aLeft+aLabelWidth+5
  else
    mEdit.Left       := aLeft;
  mEdit.Width      := aWidth;

  result:= mEdit;
end;//CreateTextExit
////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
//vytvoreni TextEditu vcetne labelu
function Create_NumEdit(
    aForm  : tForm;
    aParent: TWinControl;
    aName  : string;
    aTop, aLeft, aWidth: integer;
    aLabel: string; aLabelWidth: integer
  ): TNumEdit;
var
  mLabel : TLabel;
  mEdit  : TNumEdit;
begin
  if(aLabel <> '')then begin
    mLabel:= TLabel.Create(aForm);
    mLabel.Parent:= aParent;
    mLabel.Top   := aTop+3;
    mLabel.Left  := aLeft;
    mLabel.Width := aLabelWidth;
    mLabel.Caption := aLabel;
    mLabel.Transparent:= true;
  end;

  mEdit:= TNumEdit.Create(aForm);
  mEdit.Parent     := aParent;
  mEdit.Name       := aName;
  mEdit.Text       := '';
  mEdit.Top        := aTop;
  if (aLabel <> '') then
    mEdit.Left       := aLeft+aLabelWidth+5
  else
    mEdit.Left       := aLeft;
  mEdit.Width      := aWidth;

  result:= mEdit;
end;//Create _NumExit
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//vytvoreni DateEditu vcetne labelu
function Create_DateEdit(
    aForm  : tForm;
    aParent: TWinControl;
    aName  : string;
    aTop, aLeft, aWidth: integer;
    aLabel: string; aLabelWidth: integer
  ): TDateEdit;
var
  mLabel : TLabel;
  mEdit  : TDateEdit;
begin
  if(aLabel <> '')then begin
    mLabel:= TLabel.Create(aForm);
    mLabel.Parent:= aParent;
    mLabel.Top   := aTop+3;
    mLabel.Left  := aLeft;
    mLabel.Width := aLabelWidth;
    mLabel.Caption := aLabel;
    mLabel.Transparent:= true;
  end;

  mEdit:= TDateEdit.Create(aForm);
  mEdit.Parent     := aParent;
  mEdit.Name       := aName;
  //mEdit.Date       := ;
  mEdit.Top        := aTop;
  if (aLabel <> '') then
    mEdit.Left       := aLeft+aLabelWidth+5
  else
    mEdit.Left       := aLeft;
  mEdit.Width      := aWidth;

  result:= mEdit;
end;//CreateDateExit
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//vytvoreni checkboxu
function Create_CheckBox(AOwner: TComponent; AParent: TWinControl; ATop, ALeft, AWidth, AHeight: integer; AName, ACaption: string): TCheckBox;
begin
  Result             := TCheckBox.Create(AOwner);
  Result.Top         := ATop;
  Result.Left        := ALeft;
  Result.Width       := AWidth;
  Result.Height      := AHeight;
  Result.Name        := AName;
  Result.Caption     := ACaption;
  Result.Parent      := AParent;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//vytvoreni radiobutonu v boxu
//items = polozky oddelene carkou = '"Pouze malý","Pouze velký",Oba'
function Create_RadioGroup(AOwner: TComponent; AParent: TWinControl; ATop, ALeft, AWidth: integer; AName, ACaption, aItems: string): TRadioGroup;
begin
  Result             := TRadioGroup.Create(AOwner);
  Result.Top         := ATop;
  Result.Left        := ALeft;
  Result.Width       := AWidth;
  Result.Name        := AName;
  Result.Caption     := ACaption;
  Result.Parent      := AParent;
  Result.Columns     := 1;

  Result.Items.DelimitedText:= aItems;
  Result.Height      := 10 + 20 * Result.Items.count;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Combo na vyber z ciselniku
//Vytvori kombo s linkem do ciselniku
{function Create_ComboEditLink(
    aForm  : TForm;
    aParent: TWinControl;
    aName, aClassID, aTextField: string;
    aConnectedTextField:String;
    aTop, aLeft, aWidth: integer;
    aLabel: string; aLabelWidth: integer
  ): TRollComboEdit;

  //----------------------------------------------------------------------------
  procedure ComboEditOnExit(Sender: TComponent);
  var
    mLabel1: TLabel;
    mComboEdit: TRollComboEdit;
  begin
    if not(Sender is TRollComboEdit) then
      exit;
    mComboEdit := TRollComboEdit(Sender);
    //pokud neni vybrano, tak vycistim label. Z nejakeho duvodu se to nedeje automaticky)
    if(NxIsEmptyOID(mComboEdit.DataText))then begin
      //najdu label
      mLabel1:= TLabel(mComboEdit.ConnectedControl);
      if(Assigned(mLabel1))then mLabel1.Caption:= '';
    end;
  end;
  //----------------------------------------------------------------------------
var
  mLabel : TLabel;
  mLabel1: TLabel;
  mCombo : TRollComboEdit;
begin
  if(aLabel <> '')then begin
    mLabel:= TLabel.Create(aForm);
    mLabel.Parent:= aParent;
    mLabel.Top   := aTop+3;
    mLabel.Left  := aLeft;
    mLabel.Width := aLabelWidth;
    mLabel.Caption := aLabel;
    mLabel.Transparent:= true;
  end;

  mLabel1:= TLabel.Create(aForm);
  mLabel1.Parent:= aParent;
  mLabel1.Tag   := 1;
  mLabel1.Top   := aTop+3;
  if (aLabel <> '') then
    mLabel1.Left  := aLeft+aLabelWidth+5+aWidth+2
  else
    mLabel1.Left  := aLeft+aWidth+2;
  mLabel1.Width   := 100;
  mLabel1.Caption := '';
  mLabel1.Transparent:= true;

  mCombo:= TRollComboEdit.Create(aForm);
  mCombo.Parent     := aParent;
  mCombo.Name       := aName;
  mCombo.ClassID    := aClassID;
  mCombo.TextField  := aTextField;
  mCombo.ConnectedControlField:= aConnectedTextField;
  mCombo.DataText   := '';
  mCombo.Text       := '';
  mCombo.Complete   := True;
  mCombo.ForcedField:= True;
  mCombo.Prefilling := pmNone;

  mCombo.OnExit:= @ComboEditOnExit;

  if(Assigned(gFormContext))then
    mCombo.OnGetContext:= @ComboEditGetContext;

  mCombo.Top        := aTop;
  if (aLabel <> '') then
    mCombo.Left       := aLeft+aLabelWidth+5
  else
    mCombo.Left       := aLeft;
  mCombo.Width      := aWidth;

  if Assigned (mLabel1) then
    mCombo.ConnectedControl     := mLabel1;
  result:= mCombo;
end; //Create_ComboEditLink}
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//najde na formulari komponentu a vrati jeji hodnotu
function Combo_GetValue(aForm: TForm; aName: string): string;
var
  cb: TRollComboEdit;
begin
  cb:= TRollComboEdit(aForm.FindComponent(aName));
  if(cb = nil)then
    RaiseException('Komponenta nenalezena: '+aName);

  if(cb.DataText = '0000000000')then  //prazdna hodnota
    result:= ''
  else
    result:= cb.DataText;
end;//Combo_GetValue
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//najde na formulari komponentu a nastavi jeji hodnotu
procedure Combo_SetValue(aForm: TForm; aName: string; aValue:string);
var
  cb: TRollComboEdit;
begin
  cb:= TRollComboEdit(aForm.FindComponent(aName));
  if(cb = nil)then
    RaiseException('Komponenta nenalezena: '+aName);
  cb.DataText := aValue;
end;//Combo_SetValue
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//vytvori a vrati jednoduchy formular s tlactky OK/Zrusit
function FormOKCancel(aOwner: TComponent; var aPanel: TPanel;
  aCaption: string; aWidth, aHeight: integer) : TForm;
var
  mForm : TForm;
  mPanel: TPanel;
begin
  mForm := TForm.Create(aOwner);
  try
    mForm.Caption     := aCaption;
    //mForm.FormStyle   := fsStayOnTop;
    //mForm.BorderStyle := bsDialog;  //kdyz je bsDialog, tak zmizi ikona z ALT+TAB, coz je nezadouci
    mForm.clientWidth       := aWidth;
    mForm.ClientHeight      := aHeight;
    mForm.Scaled      := False;
    mform.Position    := poScreenCenter;

    //PANEL - Tlacitka
    mPanel:= TPanel.Create(mForm);
    mPanel.Parent := mForm;
    mPanel.BottomInModalDialog:= true;
    mPanel.Name   := 'pTlacitka';
    mPanel.Caption:= '';
    mPanel.Align  := alBottom;
    mPanel.Height := 40;
    mPanel.TabOrder:= 2;

    CreateButton(mForm, mPanel, 8, mForm.Width - 70 - 70 - 20 - 20, 70, 25, 'bOK', 'OK', 1);
    CreateButton(mForm, mPanel, 8, mForm.Width - 70 - 20          , 70, 25, 'bCancel', 'Zrušit', 2);

    //PANEL - Hlavni
    aPanel:= TPanel.Create(mForm);
    aPanel.Parent := mForm;
    aPanel.Name   := 'pHlavni';
    aPanel.Caption:= '';
    aPanel.Align  := alClient;
    mPanel.TabOrder:= 1;

    result:= mForm;
  except
    mForm.free;
  end;
end;//FormOKCancel
////////////////////////////////////////////////////////////////////////////////

//vytvoreni DateEditu vcetne labelu
function Create_Label(
    aForm  : tForm;
    aParent: TWinControl;
    aName  : string;
    aTop, aLeft, aWidth: integer;
    aCaption: string
  ): TLabel;
var
  mLabel : TLabel;
begin
  mLabel:= TLabel.Create(aForm);
  mLabel.Parent:= aParent;
  mLabel.Top   := aTop;
  mLabel.Left  := aLeft;
  mLabel.Name  := aName;
  mLabel.Width := aWidth;
  mLabel.Caption := aCaption;
  mLabel.Transparent:= true;
  result := mLabel;
end;


////////////////////////////////////////////////////////////////////////////////
//formular na zadani Datumu
function FormDate(aCaption, aLabel: string; var datum: Tdate;parent:Tform) : boolean;
var
  mForm  : TForm;
  mLab   : TLabel;
  mEd1   : TDateEdit;
  mPanel : TPanel;
  mResult: integer;
begin
  result := false;

  mForm:= FormOKCancel(nil, mPanel, aCaption, 350, 110);
  try
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
    mResult := mForm.Showmodal(parent);
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
function FormDateOdDo(aCaption, aLabelOd, aLabelDo: string; var datumOd,DatumDo: Tdate;parent:Tform) : boolean;
var
  mForm  : TForm;
  mLab   : TLabel;
  mEd1,mEd2   : TDateEdit;
  mPanel : TPanel;
  mResult: integer;
begin
  result := false;

  mForm:= FormOKCancel(nil, mPanel, aCaption, 350, 140);
  try
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
    mResult := mForm.Showmodal(parent);
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
//*)
////////////////////////////////////////////////////////////////////////////////
//Formular na zadani desetinneho cisla
function FormDouble(aCaption, aLabel: string; var number: double; aDecimalPlaces: Integer = 3;parent:TForm=nil) : boolean;
var
  mForm  : TForm;
  mLab   : TLabel;
  mEd1   : TNumEdit;
  mPanel : TPanel;
  mResult: integer;
  procedure Form_OnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  begin
    //ShowMessage(inttostr(key));
    if (length(shift)=0)and (key=13) then
      mForm.ModalResult:=mrok;
  end;

begin
  result:= false;

  mForm:= FormOKCancel(parent, mPanel, aCaption, 350, 110);
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
    mEd1.Top     := 8;
    mEd1.top:=mlab.Top+mlab.Height-med1.Height+4;
    mEd1.Width   := 200;
    mEd1.parent  := mPanel;
    mEd1.Value   := number;
    mEd1.DecimalPlaces := aDecimalPlaces;

    //spustim fomrular
    mResult := mForm.Showmodal(parent);
    if mResult = 1 then
    begin
      result := true;
      number := mEd1.Value;
    end;
  finally
    mForm.free;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

begin
  gFormContext:= nil;
end.