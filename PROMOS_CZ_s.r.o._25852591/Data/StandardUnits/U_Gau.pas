var
  Gau_Form   : TForm;
  Gau_Prg    : TProgressBar;
  Gau_Lab    : TLabel;
  Gau_Stop   : boolean;
  Gau_RecMax : integer;
  Gau_RecAkt : integer;
  Gau_Step : integer;

////////////////////////////////////////////////////////////////////////////////
//aForm - muzu predat bud konkretniho parenta, nebo Aktualni siteform, ze ktereho se parent zjisti
// pripadne muzu zadat nil - pok vznikne formular bez praenta
procedure GauInit(aForm: TForm; Max: integer; Caption: string; AStepBy : Integer = 1);
var
  Butt: TButton;
  Panel: TPanel;
  mLabel: TLabel;
  mParentForm: TForm;
begin
  Gau_RecMax:= Max;
  Gau_RecAkt:= 0;

  Gau_Stop:= false;
  Gau_Step := AStepBy;

  if(aForm <> nil)then begin
    //muzu predat bud konkretniho parenta, nebo Aktualni siteform, ze ktereho se parent zjisti
    if(aForm is TSiteForm)then
      mParentForm := TSiteForm(aForm).GetSiteAppForm
    else
      mParentForm := aForm;
  end else begin
    mParentForm:= nil;
  end;

  //vytvorim formular
  Gau_Form:= TForm.Create(mParentForm);
  Gau_Form.ClientWidth:= 500;

  //pokud neni parentem SiteForm, tak udelam zarovnam na stred
  if(aForm is TSiteForm)then begin
    Gau_Form.Parent:= mParentForm;
    Gau_Form.BorderStyle:= bsNone;
    Gau_Form.Left        := mParentForm.Left + mParentForm.Width - Gau_Form.Width - (Gau_Form.Width - Gau_Form.ClientWidth);
    Gau_Form.Top         := mParentForm.Top + (Gau_Form.Height - Gau_Form.ClientHeight);
  end else begin
    Gau_Form.Scaled      := False;
    Gau_Form.Position    := poScreenCenter;
    Gau_Form.BorderStyle := bsToolWindow;
    Gau_Form.OnCloseQuery:= @Gau_Form_CloseQuery;
  end;;

  //zahlavi okna
  Panel:= TPanel.Create(Gau_Form);
  Panel.Parent := Gau_Form;
  Panel.Height := 25;
  Panel.Align  := alTop;
  Panel.Color  := clGray;
  Panel.Caption:= '';

  mLabel:= TLabel.Create(Gau_Form);
  mLabel.Parent     := Panel;
  mLabel.Transparent:= true;
  mLabel.Font.Color := clBlack;
  mLabel.Font.Style := [fsBold];
  mLabel.top        := 8;
  mLabel.left       := 5;
  mLabel.Caption    := Caption;

  Gau_Prg:= TProgressBar.Create(Gau_Form);
  Gau_Prg.Parent       := Gau_Form;
  Gau_Prg.Left         := 10;
  Gau_Prg.Width        := Gau_Form.ClientWidth - (2 * Gau_Prg.Left);
  Gau_Prg.Top          := Panel.Height+10;
  Gau_Prg.Max          := Max;
  Gau_Prg.Position     := 0;

  Gau_Lab:= TLabel.Create(Gau_Form);
  Gau_Lab.Parent       := Gau_Form;
  Gau_Lab.Left         := 10;
  Gau_Lab.Top          := Gau_Prg.Top + Gau_Prg.Height + 10;
  Gau_Lab.Caption      := 'Záznam: '+IntToStr(Gau_RecAkt)+'/'+IntToStr(Gau_RecMax);

  Butt:= TButton.Create(Gau_Form);
  Butt.Parent       := Gau_Form;
  Butt.Left         := (Gau_Form.ClientWidth div 2) - (Butt.Width div 2);
  Butt.Top          := Gau_Prg.Top + Gau_Prg.Height + 5;
  Butt.Caption      := 'Přerušit';
  Butt.OnClick      := 'Gau_DoStop';

  Gau_Form.ClientHeight:= Panel.Height + Gau_Prg.Height + Butt.Height + 20;

  Gau_Form.Caption     := Caption;
  Gau_Form.Show;
end;//GauInit
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
function Gau: boolean;
begin
  if(Assigned(Gau_Form))then begin
    //doslo k preruseni
    result:= not Gau_Stop;
    Gau_RecAkt:= Gau_RecAkt+1;
    if Gau_Step = 1 then
    begin
      Gau_Lab.Caption      := 'Záznam: '+IntToStr(Gau_RecAkt)+'/'+IntToStr(Gau_RecMax);

      Gau_Prg.Position:= Gau_Prg.Position+1;
      Application.ProcessMessages;
    end else
    begin
      if Gau_RecAkt mod Gau_Step = 0 then
      begin
        Gau_Lab.Caption      := 'Záznam: '+IntToStr(Gau_RecAkt)+'/'+IntToStr(Gau_RecMax);

        Gau_Prg.Position:= Gau_Prg.Position+Gau_Step;
        Application.ProcessMessages;
      end;
    end;
  end else begin
    //pokud neni spusteny formular s gaugou, tak se chovam tak,
    //jako ze nedoslo k preruseni a nic jineho nedelam
    result:= true;
  end;
end;//Gau
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
procedure GauClose;
begin
  if(Assigned(Gau_Form))then begin
    Gau_Form.Free;
    Gau_Form:= nil;
  end;
end;//GauClose
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
procedure Gau_DoStop;
begin
  Gau_Stop:= true;
end;//Gau_DoStop
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
procedure Gau_Form_CloseQuery(Sender: TForm; var CanClose: Boolean);
begin
  //nedovolim zavrit formular jinak nez tlacitkem prerusit
  CanClose:= false;
end;
////////////////////////////////////////////////////////////////////////////////

begin
end.