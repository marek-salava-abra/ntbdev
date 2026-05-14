const
  DBNavigator_Button_Insert = 7;
  DBNavigator_Button_Add    = 8;
  DBNavigator_Button_Delete = 9;

////////////////////////////////////////////////////////////////////////////////
//zavolani procedury pomoci udalosti (abych nemusel mit vlozenou unitu s pozacovanou funkci do unity)
procedure RunNotifyEvent(SiteForm: TSiteForm; NameNotifyEvent: string);
var
  b: TButton;
begin
  b:= TButton.Create(SiteForm);
  try
    b.OnClick:= NameNotifyEvent;
    b.Click
  finally
    b.free;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//Nastavi focus na kontrol zadaneho jmena a vyvola vyjimku
procedure RaiseExceptionAndFocus(Form: TForm; ControlName: string; Text: string);
var
  Control: TWinControl;
begin
  Control:= TWinControl(Form.FindComponent(ControlName));
  if(Assigned(Control))then
    Control.SetFocus;

  RaiseException(Text);
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//vraci pozici vlevo, kde konci contro
function Control_Right(control: TControl): integer;
begin
  result:= control.Left+control.Width;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//vraci pozici dole, kde konci contro
function Control_Bottom(control: TControl): integer;
begin
  result:= control.Top+control.Height;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//vytvoreni Panel
function Create_Panel(AOwner: TComponent; AParent: TWinControl;
  ATop, ALeft, AWidth, AHeight: integer; AName: string;
  AAlign: TAlign = alClient; AColor: integer = nil): TPanel; //clBtnFace
begin
  Result:= TPanel.Create(AOwner);
  Result.Parent := AParent;
  Result.Name   := AName;
  Result.Caption:= '';
  Result.Top    := ATop;
  Result.Left   := ALeft;
  Result.Width  := AWidth;
  Result.Height := AHeight;
  Result.Align  := AAlign;
  if(AColor <> nil)then begin
    Result.ParentColor:= false;
    Result.PanelColor:= pcCustom;
    Result.Color:= AColor;
  end else
    Result.PanelColor  := pcTransparent;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
function Create_TabSheet(APageControl: TPageControl; AName, ACaption: string):TTabSheet;
begin
  Result:= TTabSheet.Create(APageControl.Owner);
  Result.Parent := APageControl;
  Result.PageControl:= APageControl;
  Result.Name   := AName;
  Result.Caption:= ACaption;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//vytvoreni Buttonu
function Create_Button(AOwner: TComponent; AParent: TWinControl;
  ATop, ALeft, AWidth, AHeight: integer;
  AName, ACaption: string;
  AModalResult: integer): TButton;
begin
  Result             := TButton.Create(AOwner);
  Result.Top         := ATop;
  Result.Left        := ALeft;
  if(AWidth <> 0)then
    Result.Width       := AWidth;
  if(AHeight <> 0)then
    Result.Height      := AHeight;
  Result.Name        := AName;
  Result.Caption     := ACaption;
  Result.ModalResult := AModalResult;
  Result.Parent      := AParent;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
function Create_ActionButton(aSiteForm: TSiteForm;
  AName, ACaption, AHint, ACategory, ATextTag: string;
  AKeepApart: boolean;
  AOnExecute, AOnUpdate: string): TAction;
begin
  result := ASiteForm.GetNewAction;
  result.ShowControl  := True;
  result.ShowMenuItem := True;
  result.Category     := ACategory;
  result.Name         := AName;
  result.Caption      := ACaption;
  result.Hint         := AHint;
  result.TextTag      := ATextTag;
  result.KeepApart    := AKeepApart;
  if(AOnExecute <> '')then
    result.OnExecute    := AOnExecute;
  if(AOnUpdate <> '')then
    result.OnUpdate     := AOnUpdate;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//vytvoreni Label
function Create_Label(AOwner: TComponent; AParent: TWinControl;
  ATop, ALeft, aWidth, AHeight: integer;
  AName, ACaption: string): TLabel;
begin
  Result:= TLabel.Create(AOwner);
  Result.Parent:= AParent;
  Result.Caption:= aCaption;
  Result.Name:= AName;
  Result.Top:= ATop;
  Result.Left:= ALeft;
  Result.AutoSize:= aWidth = 0;
  if(aWidth <> 0)then
    result.Width := aWidth;
  if(AHeight <> 0)then
    result.Height := AHeight;
  Result.Transparent:= true;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//vytvori a vrati jednoduchy formular s tlactky OK/Zrusit
function Create_FormOKCancel(aOwner: TComponent; var aPanel: TPanel;
  aCaption: string; aWidth, aHeight: integer) : TForm;

  //----------------------------------------------------------------------------
  procedure _FormOKCancel_onDestroy(Sender: TForm);
  var
    mContainer: TNxObjectContainer;
    Context: TNxContext;
  begin
    mContainer:= TNxObjectContainer(Sender.FindComponent('defaultContainer'));
    Context:= TNxContext(mContainer.GetObject('Context'));
    if(Assigned(Context))then begin
      Context.free;
    end;
  end;
  //----------------------------------------------------------------------------

var
  mForm : TForm;
  mPanel: TPanel;
  mContainer: TNxObjectContainer;
begin
  mForm := TForm.Create(aOwner);
  try
    mContainer:= TNxObjectContainer.Create(mForm);
    mContainer.Name:= 'defaultContainer';
    if(aOwner is TSiteForm)then begin
      mContainer.AddObject('Context', NxCreateContext(TSiteForm(aOwner).BaseObjectSpace));
      mForm.onDestroy:= @_FormOKCancel_onDestroy;
    end;

    mForm.Caption     := aCaption;
    //mForm.FormStyle   := fsStayOnTop;
    //mForm.BorderStyle := bsDialog;  //kdyz je bsDialog, tak zmizi ikona z ALT+TAB, coz je nezadouci
    mForm.ClientWidth       := aWidth;
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
    mPanel.Height := 35;
    mPanel.TabOrder:= 2;
    //mPanel.ParentColor:= false;
    //mPanel.PanelColor:= pcCustom;
    //mPanel.Color:= 1573070;

    Create_Button(mForm, mPanel, 5, mForm.Width - 70 - 70 - 20 - 20, 70, 25, 'bOK', 'OK', 1);
    Create_Button(mForm, mPanel, 5, mForm.Width - 70 - 20          , 70, 25, 'bCancel', 'Zrušit', 2);

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
end;//Create_FormOKCancel
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
function Create_LabelPanel(
  AOwner : TComponent;
  AParent: TWinControl;
  ATop, ALeft, AWidth, AHeight: integer;
  AName, ACaption: string;
  AFixedLeftDistance: integer = -1;
  AHint: string = ''
): TPanel;
var
  mPanel : TPanel;
  mLabel : TLabel;
begin
  //podkladovy panel
  mPanel:= TPanel.Create(AOwner);
  mPanel.Parent:= AParent;
  mPanel.Caption     := '';
  mPanel.Top         := ATop;
  mPanel.Left        := ALeft;
  mPanel.Width       := AWidth;
  mPanel.PanelColor  := pcTransparent;

  if(AHeight <> 0)then
    mPanel.Height      := AHeight
  else
    mPanel.Height      := 21;

  if(AHint<>'')then begin
    mPanel.ShowHint:= true;
    mPanel.Hint:= AHint;
  end;

  //label
  mLabel:= TLabel.Create(AOwner);
  mLabel.AutoSize   := true;
  mLabel.Caption    := ACaption;
  mLabel.Parent     := mPanel;
  mLabel.Top        := ((mPanel.Height - mLabel.Height) div 2);
  mLabel.Left       := 0;
  mLabel.Transparent:= true;
  mLabel.Visible    := ACaption <> '';

  //pevna sirka labelu
  if(AFixedLeftDistance <> -1)then begin
    mLabel.AutoSize:= false;
    mLabel.Width:= AFixedLeftDistance;
  end else begin
    //neni pevna sirka, vypnu autosize a zvetsim, aby tam byla mala mezera
    mLabel.AutoSize:= false;
    mLabel.Width:= mLabel.Width+3;
  end;

  result:= mPanel;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//vytvoreni TNumEditMovablePanel
function Create_DBNumEditPanel(
  AOwner : TComponent;
  AParent: TWinControl;
  ATop, ALeft, AWidth, AHeight: integer;
  AName, ACaption: string;
  ADataSource: TDataSource; ADataField: string;
  aHasButton : boolean = false;
  AFixedLeftDistance: integer = -1): TNumEdit;

  //----------------------------------------------------------------------------
  procedure KeyDown(Sender: TNumEdit; var Key: Word; Shift: TShiftState);
  Var
    i: integer;
  begin
    if(Key = vk_f2)then begin
      Sender.Button.Click;
    end;
  end;
  //----------------------------------------------------------------------------

var
  mPanel : TPanel;
  mLabel : TLabel;
  mEdit  : TNumEdit;
begin
  //podkladovy panel s labelem
  mPanel:= Create_LabelPanel(AOwner, AParent, ATop, ALeft, AWidth, AHeight, '', ACaption, AFixedLeftDistance);
  mLabel:= TLabel(mPanel.Controls[0]);

  //edit
  mEdit:= TNumEdit.Create(AOwner);
  mEdit.Parent     := mPanel;
  mEdit.Name       := aName;
  mEdit.Top        := 0;
  if(mLabel.Visible)then
    mEdit.Left     := mLabel.Left+mLabel.Width+3
  else
    mEdit.Left     := 0;
  mEdit.Height     := mPanel.Height;
  mEdit.Width      := AWidth - mEdit.Left;
  mEdit.DataSource := ADataSource;
  mEdit.DataField  := ADataField;
  mEdit.HasButton  := aHasButton;

  if(aHasButton)then
    mEdit.OnKeyDown  := @KeyDown;

  result:= mEdit;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//vytvoreni TTextEditMovablePanel
function Create_DBEditPanel(
  AOwner: TComponent;
  AParent: TWinControl;
  ATop, ALeft, AWidth, AHeight: integer;
  AName, ACaption: string;
  ADataSource: TDataSource; ADataField: string;
  AFixedLeftDistance: integer = -1
  ): TEdit;
var
  mPanel : TPanel;
  mLabel : TLabel;
  mEdit  : TEdit;
begin
  //podkladovy panel s labelem
  mPanel:= Create_LabelPanel(AOwner, AParent, ATop, ALeft, AWidth, AHeight, '', ACaption, AFixedLeftDistance);
  mLabel:= TLabel(mPanel.Controls[0]);

  //edit
  mEdit:= TEdit.Create(AOwner);
  mEdit.Parent     := mPanel;
  mEdit.Name       := aName;
  mEdit.Top        := 0;
  if(mLabel.Visible)then
    mEdit.Left     := mLabel.Left+mLabel.Width+3
  else
    mEdit.Left     := 0;
  mEdit.Height     := mPanel.Height;
  mEdit.Width      := AWidth - mEdit.Left;
  mEdit.DataSource := ADataSource;
  mEdit.DataField  := ADataField;

  result:= mEdit;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//vytvoreni TDateEditMovablePanel
function Create_DBDateEditPanel(
  AOwner: TComponent;
  AParent: TWinControl;
  ATop, ALeft, AWidth, AHeight: integer;
  AName, ACaption: string;
  ADataSource: TDataSource; ADataField: string;
  AFixedLeftDistance: integer = -1
  ): TDateEdit;
var
  mPanel : TPanel;
  mLabel : TLabel;
  mEdit  : TDateEdit;
begin
  //podkladovy panel s labelem
  mPanel:= Create_LabelPanel(AOwner, AParent, ATop, ALeft, AWidth, AHeight, '', ACaption, AFixedLeftDistance);
  mLabel:= TLabel(mPanel.Controls[0]);

  //edit
  mEdit:= TDateEdit.Create(AOwner);
  mEdit.Parent     := mPanel;
  mEdit.Name       := aName;
  mEdit.Top        := 0;
  if(mLabel.Visible)then
    mEdit.Left     := mLabel.Left+mLabel.Width+3
  else
    mEdit.Left     := 0;
  mEdit.Height     := mPanel.Height;
  mEdit.Width      := AWidth - mEdit.Left;
  mEdit.DataSource := ADataSource;
  mEdit.DataField  := ADataField;

  result:= mEdit;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//vytvoreni TDBComboBox
function Create_DBComboBoxPanel(
  AOwner: TComponent;
  AParent: TWinControl;
  ATop, ALeft, AWidth, AHeight: integer;
  AName, ACaption: string;
  ADataSource: TDataSource; ADataField: string;
  AItems, AValues: string;
  AFixedLeftDistance: integer = -1
  ): TComboBox;
var
  mPanel : TPanel;
  mLabel : TLabel;
  mEdit  : TComboBox;
begin
  //podkladovy panel s labelem
  mPanel:= Create_LabelPanel(AOwner, AParent, ATop, ALeft, AWidth, AHeight, '', ACaption, AFixedLeftDistance);
  mLabel:= TLabel(mPanel.Controls[0]);

  //edit
  mEdit:= TComboBox.Create(AOwner);
  mEdit.Parent     := mPanel;
  mEdit.Name       := aName;
  mEdit.Top        := 0;
  if(mLabel.Visible)then
    mEdit.Left     := mLabel.Left+mLabel.Width+3
  else
    mEdit.Left     := 0;
  mEdit.Height     := mPanel.Height;
  mEdit.Width      := AWidth - mEdit.Left;
  mEdit.DataSource := ADataSource;
  mEdit.DataField  := ADataField;
  mEdit.Items.DelimitedText:= AItems;
  mEdit.Values.DelimitedText:= AValues;

  result:= mEdit;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//vytvoreni Label
function Create_DBCheckBox(
  AOwner: TComponent;
  AParent: TWinControl;
  ATop, ALeft, AWidth, AHeight: integer;
  AName, ACaption: string;
  ADataSource: TDataSource; ADataField: string
  ): TCheckBox;

  //----------------------------------------------------------------------------
  //Osetreni standardni chyby, kdy se hned po kliu hodnota neprepise do DS. Prepise re az po zmene fokusu.
  procedure TCheckBox_OnClick(Sender: TCheckBox);
  begin
    if(Assigned(Sender.DataSource)) AND
      (Assigned(Sender.DataSource.DataSet)) AND
      (Sender.DataSource.DataSet.State = dsEdit) AND
      (Sender.DataSource.DataSet.FieldByName(Sender.DataField).AsBoolean <> Sender.Checked)
    then begin
      Sender.DataSource.DataSet.FieldByName(Sender.DataField).AsBoolean:= Sender.Checked;
    end;
  end;
  //----------------------------------------------------------------------------
begin
  Result:= TCheckBox.Create(AOwner);
  Result.Parent:= AParent;
  Result.Name:= AName;
  Result.Caption:= aCaption;
  Result.Top:= ATop;
  Result.Left:= ALeft;
  if(aWidth <> 0)then
    result.Width := aWidth;
  Result.DataSource:= ADataSource;
  Result.DataField:= ADataField;

  if(Assigned(ADataSource))then
    Result.onClick:= @TCheckBox_OnClick;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//vytvoreni TDBTextMovablePanel - jako text je pouzit TDBEdit (lze kopirovat)
function Create_DBTextPanel(
  AOwner: TComponent;
  AParent: TWinControl;
  ATop, ALeft, AWidth, AHeight: integer;
  AName, ACaption: string;
  ADataSource: TDataSource; ADataField: string;
  AFixedLeftDistance: integer = -1;
  AAlignment: TAlignment = taLeftJustify;   //todo - nefunguje nasaveni zarovnani
  AHint: string = '';
  AColor: TColor = clMoneyGreen;
  ABold: boolean = false
  ): TEdit;
var
  mPanel : TPanel;
  mLabel : TLabel;
  mEdit  : TEdit;
begin
  //podkladovy panel s labelem
  //zmensim implicitni vysku
  //if(AHeight=0)then AHeight:= 17;  //toto sem tu mem pokud jsem mel BorderStyle:= bsNone;
  mPanel:= Create_LabelPanel(AOwner, AParent, ATop, ALeft, AWidth, AHeight, '', ACaption, AFixedLeftDistance, AHint);
  mLabel:= TLabel(mPanel.Controls[0]);

  //edit - delam to editem, aby sel text kopirovat
  mEdit:= TEdit.Create(AOwner);
  mEdit.Parent     := mPanel;
  mEdit.Name       := aName;
  mEdit.TabStop    := false;
  mEdit.Top        := 0;
  if(mLabel.Visible)then
    mEdit.Left     := mLabel.Left+mLabel.Width+3
  else
    mEdit.Left     := 0;
//  mEdit.Height     := mPanel.Height;
  mEdit.Width      := AWidth - mEdit.Left;
  mEdit.DataSource := ADataSource;
  mEdit.DataField  := ADataField;

  //a nejake nastaveni navic
  NxSetReadOnly([mEdit], true);
  //mEdit.BorderStyle:= bsNone; //vypada blbe

  if(ABold)then
    mEdit.Font.Style:= [fsbold];

  //kdyz dam NxSetReadOnly, tak se  barva ignoruje.
  {
  mEdit.ParentColor:= false;
  if(AColor <> nil)then
    mEdit.Color:= AColor
  else if(AParent is TPanel)then
    mEdit.Color:= TPanel(AParent).Color;
  }


  result:= mEdit;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//vytvoreni TDBText - jako text je pouzit TDBText (nelze kopirovat, je to label)
function Create_DBTextLabelPanel(
  AOwner: TComponent;
  AParent: TWinControl;
  ATop, ALeft, AWidth, AHeight: integer;
  AName, ACaption: string;
  ADataSource: TDataSource; ADataField: string;
  AFixedLeftDistance: integer = -1;
  AAlignment: TAlignment = taLeftJustify;
  AHint: string = '';
  AColor: TColor = clMoneyGreen; //todo - nefunguje nasaveni barvy
  ABold: boolean = false
  ): TLabel;
var
  mPanel : TPanel;
  mLabel : TLabel;
  mEdit  : TLabel;
begin
  //podkladovy panel s labelem
  mPanel:= Create_LabelPanel(AOwner, AParent, ATop, ALeft, AWidth, AHeight, '', ACaption, AFixedLeftDistance, AHint);
  mLabel:= TLabel(mPanel.Controls[0]);

  //edit - delam to editem, aby sel text kopirovat
  mEdit:= TLabel.Create(AOwner);
  mEdit.Parent     := mPanel;
  mEdit.Name       := aName;
  if(mLabel.Visible)then
    mEdit.Left     := mLabel.Left+mLabel.Width+3
  else
    mEdit.Left     := 0;
  //mEdit.Height     := mPanel.Height;
  mEdit.Width      := AWidth - mEdit.Left;
  mEdit.Top        := mLabel.Top;
  mEdit.DataSource := ADataSource;
  mEdit.DataField  := ADataField;
  mEdit.Alignment  := AAlignment;
  mEdit.Transparent:= true;

  if(ABold)then
    mEdit.Font.Style:= [fsbold];

{  mEdit.ParentColor:= false;
  if(AColor <> nil)then
    mEdit.Color:= AColor
  else if(AParent is TPanel)then
    mEdit.Color:= TPanel(AParent).Color;
}
  result:= mEdit;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
function Create_DBMemo(
  AOwner: TComponent;
  AParent: TWinControl;
  ATop, ALeft, AWidth, AHeight: integer;
  AName, ACaption: string;
  ADataSource: TDataSource; ADataField: string;
  AFixedLeftDistance: integer = -1;
  AAlignment: TAlignment = taLeftJustify;   //todo - nefunguje nasaveni zarovnani
  AHint: string = '';
  AColor: TColor = clMoneyGreen;
  ABold: boolean = false;
  AFontSize: integer = 0;
  AFontColor : Integer = clBtnFace

): TMemo;
var
  mPanel : TPanel;
  mLabel : TLabel;
  mMemo  : TMemo;
begin
  //podkladovy panel s labelem
  mPanel:= Create_LabelPanel(AOwner, AParent, ATop, ALeft, AWidth, AHeight, '', ACaption, AFixedLeftDistance, AHint);
  mLabel:= TLabel(mPanel.Controls[0]);
  mLabel.Height:= 22;
  mLabel.Top:= 2;

  mMemo := TMemo.Create(AOwner);
  mMemo.Parent:= mPanel;
  mMemo.Name := AName;
  if(mLabel.Visible)then
    mMemo.Left     := mLabel.Left+mLabel.Width+3
  else
    mMemo.Left     := 0;
  //mMemo.Height     := mPanel.Height;
  mMemo.Width      := AWidth - mMemo.Left;
  //mMemo.Top        := mLabel.Top;
  mMemo.DataSource := ADataSource;
  mMemo.Align      := alRight;
  mMemo.DataField  := ADataField;
  mMemo.Alignment  := AAlignment;
  mMemo.Font.Color := AFontColor;

  if(ABold)then
    mMemo.Font.Style:= [fsbold];

  if AFontSize > 0 then
    mMemo.Font.Size := AFontSize;

{  mMemo.ParentColor:= false;
  if(AColor <> nil)then
    mMemo.Color:= AColor
  else if(AParent is TPanel)then
    mMemo.Color:= TPanel(AParent).Color;
}

  result:= mMemo;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//vytvoreni TNonObjectRollMovablePanel
{function Create_DBComboEditPanel(
  AOwner: TComponent;
  AParent: TWinControl;
  ATop, ALeft, AWidth, AHeight: integer;
  AName, ACaption: string;
  ADataSource: TDataSource; ADataField: string;
  aClassID: string;
  aCombo_TextField: string;
  aConnected_Field: string;
  AFixedLeftDistance: integer = -1
  ):  TRollComboEdit;

  //----------------------------------------------------------------------------
  procedure _ComboEditOnExit(Sender: TRollComboEdit);
  var
    mLabel1: TLabel;
  begin
    //pokud neni vybrano, tak vycistim label. Z nejakeho duvodu se to nedeje automaticky)
    if(NxIsEmptyOID(Sender.DataText))then begin
      //najdu label
      mLabel1:= TLabel(Sender.ConnectedControl);
      if(Assigned(mLabel1))then mLabel1.Caption:= '';
    end;
  end;
  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  procedure _ComboEditGetContext(Sender: TObject; var AContext: TNxContext);
  var
    i: integer;
    mContainer: TNxObjectContainer;
  begin
    AContext:= nil;

    //maximalne 10x
    for i:= 1 to 10 do begin
      if(Sender = nil)then break;

      if(Sender is TSiteForm)then begin
        AContext:= TSiteForm(Sender).SiteContext;
        break;
      end;

      if(Sender is TForm)then begin
        mContainer:= TNxObjectContainer(TForm(Sender).FindComponent('defaultContainer'));
        AContext:= TNxContext(mContainer.GetObject('Context'));
        break;
      end;

      if(not(Sender is TComponent))then break;
      Sender:= TComponent(Sender).Owner;
    end;
  end;
  //----------------------------------------------------------------------------

var
  mPanel : TPanel;
  mLabel : TLabel;
  mLabel1 : TLabel;
  mCombo  : TRollComboEdit;
begin
  //podkladovy panel s labelem
  mPanel:= Create_LabelPanel(AOwner, AParent, ATop, ALeft, AWidth, AHeight, '', ACaption, AFixedLeftDistance);
  mLabel:= TLabel(mPanel.Controls[0]);

  //edit
  mCombo:= TRollComboEdit.Create(AOwner);
  mCombo.Parent     := mPanel;
  mCombo.Name       := aName;
  mCombo.Text:= '';
  mCombo.ClassID    := aClassID;
  mCombo.Complete   := True;
  mCombo.ForcedField:= True;
  mCombo.Prefilling := pmNone;
  mCombo.OnExit:= @_ComboEditOnExit;
//TODO -- chyba OnGetContext - Sender je TObject a ne TRollComboEdit //
  mCombo.OnGetContext:= @_ComboEditGetContext;


  mCombo.Top        := 0;
  if(mLabel.Visible)then
    mCombo.Left     := mLabel.Left+mLabel.Width+3
  else
    mCombo.Left     := 0;
  mCombo.Height     := mPanel.Height;
  //pokud zobrazuju Connected_Field, tak nastavim tretinovou velikost
  if(aConnected_Field <> '')then
    mCombo.Width      := (AWidth - mCombo.Left) div 3
  else
    mCombo.Width      := (AWidth - mCombo.Left);

  result:= mCombo;

  //label
  if(aConnected_Field <> '')then begin
    mLabel1:= TLabel.Create(AOwner);
    mLabel1.Parent:= mPanel;
    mLabel1.Tag   := 1;
    mLabel1.Top   := mLabel.Top;
    mLabel1.Left  := mCombo.left+mCombo.Width+3;
    mLabel1.Width := mCombo.Width * 2;
    mLabel1.Height:= mPanel.Height;
    mLabel1.Caption := '';
    mLabel1.Transparent:= true;

    mCombo.ConnectedControl     := mLabel1;
    mCombo.ConnectedControlField:= aConnected_Field;
  end;

  mCombo.TextField  := aCombo_TextField;
  mCombo.DataField  := ADataField;
  mCombo.DataSource := ADataSource;
end;}
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//vytvoreni TDBRadioGroup
function Create_DBRadioGroup(
  AOwner: TComponent;
  AParent: TWinControl;
  ATop, ALeft, AWidth, AHeight: integer;
  AName, ACaption: string;
  ADataSource: TDataSource; ADataField: string
  ): TRadioGroup;
var
  mRadioGroup  : TRadioGroup;
begin
  mRadioGroup:= TRadioGroup.Create(AOwner);
  mRadioGroup.Parent     := AParent;
  mRadioGroup.Name       := aName;
  mRadioGroup.Caption    := ACaption;
  mRadioGroup.Top        := aTop;
  mRadioGroup.Left       := aLeft;
  mRadioGroup.Width      := AWidth;
  if(AHeight <> 0)then
    mRadioGroup.Height     := aHeight;
  mRadioGroup.DataSource := ADataSource;
  mRadioGroup.DataField  := ADataField;

  result:= mRadioGroup;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//vytvoreni radiobutonu v boxu
//items = polozky oddelene carkou = '"Pouze malý","Pouze velký",Oba'
function Create_RadioGroup(
  AOwner: TComponent;
  AParent: TWinControl;
  ATop, ALeft, AWidth: integer;
  AName, ACaption, AItems: string
  ): TRadioGroup;
var
  mRadioGroup  : TRadioGroup;
begin
  mRadioGroup             := TRadioGroup.Create(AOwner);
  mRadioGroup.Top         := ATop;
  mRadioGroup.Left        := ALeft;
  mRadioGroup.Width       := AWidth;
  mRadioGroup.Name        := AName;
  mRadioGroup.Caption     := ACaption;
  mRadioGroup.Parent      := AParent;
  mRadioGroup.Columns     := 1;

  mRadioGroup.Items.DelimitedText := aItems;
  mRadioGroup.Height      := 10 + 20 * mRadioGroup.Items.Count;

  Result := mRadioGroup;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
function Create_DBNavigator(
  AOwner: TComponent;
  AParent: TWinControl;
  ATop, ALeft: integer;
  AName: string;
  ADBGrid: TDBGrid;
  ADataSource: TDataSource
  ): TDBNavigator;
var
  mNavigator  : TDBNavigator;
begin
  mNavigator:= TDBNavigator.Create(AOwner);
  mNavigator.Parent:= AParent;
  mNavigator.Top:= ATop;
  mNavigator.Left:= ALeft;
  mNavigator.DBGrid:= ADBGrid;
  mNavigator.DataSource:= ADataSource;
  mNavigator.Name:= AName;

  result:= mNavigator;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
function Create_DBGrid(
  aForm  : tForm;
  aParent: TWinControl;
  aName  : string; //jmeno bez prefixu. Jednotlivym komponentam pridam prefix (dt/ds/grd)
  aTop, aLeft, aWidth, aHeight: integer;
  aAlign: TAlign;
  aCaption: string; //pokud je zadano, tak se nejprve vytvori panel na ktery se umisti label a grid
  var dt: TDataSet;
  var ds: TDataSource //pokud predam vyvoreny ds, tak jej znovu jiz nevytvarim a pouziju tento.
    //zaroven v takovem pripade predpokladam, ze tento ds jiz ma nataveny dt (ten tedy nevytvaim a neprirazuji
    //takze jej nemusim predavat)
): TDBGrid;
var
  mPanel: TPanel;
  mPanelL: TPanel;
  lLabel: TLabel;
begin
  if(aCaption <> '')then begin
    mPanel := Create_Panel(aForm, aParent, aTop, aLeft, aWidth, aHeight, 'p'+aName, aAlign);
    mPanelL:= Create_Panel(aForm, mPanel, 0, 0, 0, 25, 'pLabel'+aName, alTop);
    lLabel := Create_Label(aForm, mPanelL, 5, 5, 0, 0, '', aCaption);
  end;

  //datasource
  if(not assigned(ds))then begin
    //dataset
    if(not assigned(dt))then begin
      dt      := TMemTable.Create(aForm);
      dt.Name := 'dt'+aName;
    end;

    ds         := TDataSource.Create(aForm);
    ds.Name    := 'ds'+aName;
    ds.DataSet := dt;
  end else begin
    //pokud jsem si predal ds, tak zpet vratim jeho dt.
    //(predpokladam ze jej ma ds prirazeny a nevytvarim jej)
    dt:= ds.DataSet;
  end;

  //grid
  result:= TDBGrid.Create(aForm);
  result.Name    := 'grd'+aName;
  result.datasource:= ds;

  //razeni pri kliku na sloupce
//zatim nepotrebuju
//  result.OnTitleClick:= @DBGrid_OnTitleClick;

  result.options:= [
    //dgEditing,dgAlwaysShowEditor,dgIndicator,
    dgColumnResize,dgTitles,
    dgColLines,dgRowLines,dgTabs,dgRowSelect,
    //dgAlwaysShowSelection,
    //dgConfirmDelete,dgCancelOnExit,dgMultiSelect
  ];

  if(aCaption <> '')then begin
    //umistim na panel
    result.Parent  := mPanel;
    result.Top     := 25;
    result.Left    := 0;
    result.Width   := 0;
    result.Height  := aHeight-25;
    result.Align   := alClient;
    result.Anchors := [akLeft, akRight, akTop, akBottom];
  end else begin
    result.Parent  := aParent;
    result.Top     := aTop;
    result.Left    := aLeft;
    result.Width   := aWidth;
    result.Height  := aHeight;
    result.Align   := aAlign;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
//vytvoreni hlavicky dle definice (vsechno string)
//Header - code=S10,mnoz=F,pocet=I
//Header rozsirena definice:
// - za typem (ktery je povinny pokud je uvedeno "=" a je vzdy hned za "=") moho nasledovat nepovinne parametry
// - ukazka: ID=S10;NotVisible,Person_Name=S60;Alignment=R;Label=Pracovník;Width=100
//  * NotVisible         - v gridu bude schovany
//  * Alignment=R/L/C    - v gridu bude doprava/doleva/centrovane
//  * Label=ahoj\szdar   - v gridu bude mit sloupec nazev ahoj POZOR, nemohu zde pouzit mezeru. Misto ni pisu \s (jako space)
//  * Width=10           - v gridu bude sirka slouce 10
procedure DBGrid_CreataColumns(Grd: TDBGrid; Header: String);
var
  j: integer;
  jx: integer;
  sl: TStringList;
  slVal: TStringList;
  valTyp: string;
  valVisible,valReadOnly: boolean;
  valAlignment: TAlignment;
  valLabel: string;
  valWidth: integer;
  col : TColumn;
begin
  //pokud je definovany Header, tak udalam hlavicku z nej
  if(trim(Header) <> '')then begin
    Header:= ReplaceStr(Header, ' ', '\s');
    sl:= TStringList.Create;
    sl.CommaText:= Header;

    slVal:= TStringList.Create;
    slVal.Delimiter:= ';';

    for j:= 0 to sl.Count - 1 do begin
      slVal.DelimitedText:= sl.ValueFromIndex[j];

      //prvni je vzdy typ pripadne velikost (toto je povinne)
      valTyp:= slVal.Strings[0];

      //dale mohou nasledovat hodnoty:
      //NotVisible
      //Alignment=R/L/C
      //Label=ahoj
      //Width

      //implicitni hodnoty
      valVisible:= true;
      valReadOnly:= false;
      valAlignment:= -1;
      valLabel  := sl.Names[j];
      valWidth  := 0;

      for jx:= 1 to slVal.Count - 1 do begin
        if(slVal.Strings[jx] = 'ReadOnly')then begin
          valReadOnly:=true
        end;
        if(slVal.Strings[jx] = 'NotVisible')then begin
          valVisible:= false;
        end else if(pos('Alignment=', slVal.Strings[jx]) = 1)then begin
          case copy(slVal.Strings[jx], 11, 1) of
            'R': valAlignment:= taRightJustify;
            'C': valAlignment:= taCenter;
            'L': valAlignment:= taLeftJustify;
          end;
        end else if(pos('Label=', slVal.Strings[jx]) = 1)then begin
          valLabel:= AnsiReplaceStr(copy(slVal.Strings[jx], 7, 100), '\s', ' ');
        end else if(pos('Width=', slVal.Strings[jx]) = 1)then begin
          valWidth:= StrToIntDef(copy(slVal.Strings[jx], 7, 100), 0);
        end;
      end;

      //pokud jsem neurcil zarovnani, tak jej urcim podle typu
      if(valAlignment = -1)then begin
        case copy(valTyp,1,1) of
          'S','T': valAlignment:= taLeftJustify;
          'I','D','C','F','R','B': valAlignment:= taRightJustify;
          else valAlignment:= taLeftJustify;
        end;
      end;

      //pokud jsem neurcil sirku, tak jej urcim podle typu
      if(valWidth = 0)then begin
        case copy(valTyp,1,1) of
          'S': valWidth:= StrToInt(trim(copy(valTyp, 2, 10)))*5;
          'I': valWidth:= 70;
          'D': valWidth:= 70;
          'T': valWidth:= 70;
          'C': valWidth:= 120;
          'F': valWidth:= 100;
          'R': valWidth:= 100;
          'B': valWidth:= 20;
          else valWidth:= 30;
        end;
      end;

      col := grd.Columns.Add;
      col.FieldName     := sl.Names[j];
      col.Visible       := valVisible;
      col.ReadOnly      := valReadOnly;
      col.Title.Caption := valLabel;
      col.Width         := valWidth;
      col.Alignment     := valAlignment;
//      col.read
      //col.ColExtender.DisplayType:= uddtCheck;//melo by to nastavit boolen jako checkbox, ale nefunguje
    end;
    sl.free;
    slVal.free;
  end;
end;//DataSet_CreataHeader
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
function Create_MultiGrid(
  aForm  : tForm;
  aParent: TWinControl;
  aName  : string; //jmeno bez prefixu. Jednotlivym komponentam pridam prefix (dt/ds/grd)
  aTop, aLeft, aWidth, aHeight: integer;
  aAlign: TAlign;
  aCaption: string; //pokud je zadano, tak se nejprve vytvori panel na ktery se umisti label a grid
  var dt: TDataSet;
  var ds: TDataSource //pokud predam vyvoreny ds, tak jej znovu jiz nevytvarim a pouziju tento.
    //zaroven v takovem pripade predpokladam, ze tento ds jiz ma nataveny dt (ten tedy nevytvaim a neprirazuji
    //takze jej nemusim predavat)
): TMultiGrid;
var
  mPanel: TPanel;
  lLabel: TLabel;
begin
  {if(aCaption <> '')then begin
    mPanel:= Create_Panel(aForm, aParent, aTop, aLeft, aWidth, aHeight, 'p'+aName, aAlign);
    lLabel:= Create_Label(aForm, mPanel, 5, 5, 0, '', aCaption);
  end; }

  //datasource
  if(not assigned(ds))then begin
    //dataset
    if(not assigned(dt))then begin
      dt      := TMemoryDataset.Create(aForm);
//      dt      := TkbmMemTable.Create(aForm);
      dt.Name := 'dt'+aName;
    end;

    ds         := TDataSource.Create(aForm);
    ds.Name    := 'ds'+aName;
    ds.DataSet := dt;
  end else begin
    //pokud jsem si predal ds, tak zpet vratim jeho dt.
    //(predpokladam ze jej ma ds prirazeny a nevytvarim jej)
    dt:= ds.DataSet;
  end;

  //grid
  result:= TMultiGrid.Create(aForm);
  result.Name    := 'grd'+aName;
  result.DataSource:= ds;
  {
  result.Options:= [
    goHeaders, goGap, goFixRowLines, goFixColLines, goRowLines, goColLines,
    goAllowDelete, goAllowInsert, goAllowAppend, goAllowEdit,
    goAlwaysShowEditor, goAlwaysShowSelection, goCancelOnExit, goMultiSelect, goRepaintAllLines,
    goKeepHighlightRowOnLostFocus,goClearHighlightRowOnLostFocus
  ];
  }
  if(aCaption <> '')then begin
    //umistim na panel
    result.Parent  := mPanel;
    result.Top     := 25;
    result.Left    := 0;
    result.Width   := 0;
    result.Height  := aHeight-25;
    result.Align   := alBottom;
    result.Anchors := [akLeft, akRight, akTop, akBottom];
  end else begin
    result.Parent  := aParent;
    result.Top     := aTop;
    result.Left    := aLeft;
    result.Width   := aWidth;
    result.Height  := aHeight;
    result.Align   := aAlign;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
{function MultiGrid_AddColumn_Roll(AOwner: TForm; AMultiGrid: TMultiGrid;
  AFieldName, ACaption: String; ALayout, ALine, AOrder, AWidth: Integer;
  AElastic, AReadOnly, AForcedField: Boolean; ATextField, AClassID: String): TNxMultiGridRollColumn;
begin
  Result := TNxMultiGridRollColumn.Create(AOwner);
  Result.Name := 'col' + AnsiReplaceStr(AFieldName, '.', '');
  Result.Caption := ACaption;
  Result.Layout := ALayout;
  Result.Line := ALine;
  Result.Order := AOrder;
  Result.Elastic := AElastic;
  Result.FieldName := AFieldName;
  Result.ReadOnly := AReadOnly;
  Result.Complete := True;
  Result.CompleteMinLength := 0;
  Result.TextField := ATextField;
  Result.ClassID := AClassID;
  Result.ForcedField := AForcedField;
  Result.SecurityMask := 0;
  Result.Width := AWidth;
  AMultiGrid.AddColumn(Result);

  if(AReadOnly)then Result.SetReadOnlyBackup;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
function MultiGrid_AddColumn_Common(AOwner: TForm; AMultiGrid: TMultiGrid;
  AFieldName, ACaption: String; ALayout, ALine, AOrder, AWidth: Integer;
  AElastic, AReadOnly: Boolean): TNxMultiGridColumn;
begin
  Result := TNxMultiGridColumn.Create(AOwner);
  Result.Name := 'col' + AnsiReplaceStr(AFieldName, '.', '');
  Result.Caption := ACaption;
  Result.Layout := ALayout;
  Result.Line := ALine;
  Result.Order := AOrder;
  Result.Elastic := AElastic;
  Result.FieldName := AFieldName;
  Result.ReadOnly := AReadOnly;
  Result.Complete := False;
  Result.CompleteMinLength := 0;
  Result.Width := AWidth;
  AMultiGrid.AddColumn(Result);

  if(AReadOnly)then Result.SetReadOnlyBackup;
end;         }
////////////////////////////////////////////////////////////////////////////////

begin
end.