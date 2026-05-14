var
  gProgressForm : TForm;
  mShowProgres:boolean;

 procedure ProgressDispose;
begin
  gProgressForm.Close();
end;

procedure ProgressSetMax(aValue: Integer);
begin
  TProgressBar(gProgressForm.FindChildControl('prgBar')).Max:= aValue;
end;

procedure ProgressSetPos(aValue: Integer; aText: string = '');
var
  mPrg: TProgressBar;
begin
  mPrg := TProgressBar(gProgressForm.FindChildControl('prgBar'));
  mPrg.Position:= aValue + 1;
  TLabel(gProgressForm.FindChildControl('lblCount')).Caption:= IntToStr(NxFloor((AValue/mPrg.Max)*100))+' %';
  TLabel(gProgressForm.FindChildControl('lblText')).Caption:= aText;
  mPrg.Repaint;

  gProgressForm.Refresh();
  gProgressForm.BringToFront();

  Application.ProcessMessages();
end;


  function CreateProgressInfo(AForm: TForm; AProcCount: Integer; AInfo: string): TForm;
var
  mForm: TForm;
  mProgr: TProgressBar;
  mLabel: TLabel;
begin
  mForm := TForm.Create(AForm);
  with mForm do begin
    Left := 50;
      Top := 200;
    Width := 760;
    Height := 150;
    Caption := 'Prubeh zpracovani';
    //Position := poScreenCenter;//OwnerFormCenter;


    FormStyle := fsStayOnTop;
    BorderStyle := bsDialog;
    with TLabel.Create(mForm) do begin
      Parent := mForm;
      Left := 8;
      Top := 16;
      Width := 600;
      Height := 32;
      //AutoSize := False;
      Name := 'lblInfoLabel';
      Caption := AInfo;
      Transparent := True;
      //WordWrap := True;
      Font.Height := -26;
      Font.Style := [fsBold];
      Tag := 3;
    end;
    with TProgressBar.Create(mForm) do begin
      Parent := mForm;
      Left := 8;
      Top := 48;
      Width := 706;
      Height := 66;
      Tag := 3;
      Name := 'pgInfoBar';
      Max := AProcCount;
      Position := 0;
    end;
  end;
  Result := mForm;
end;



procedure ProgressInit(ASite : TSiteForm; ACaption : string; AMaxValue : Integer);
begin
  gProgressForm:= TForm.Create(ASite);
  gProgressForm.BorderStyle:= bsToolWindow;
//  gProgressForm.Position:= poScreenCenter -50 ;
  gProgressForm.Left:=800;
  gProgressForm.Top:=800;
  gProgressForm.FormStyle := fsStayOnTop;
  gProgressForm.ClientWidth:= 240;
  gProgressForm.ClientHeight:= 80;
  gProgressForm.Caption := ACaption;

  with TProgressBar.Create(gProgressForm) do
  begin
    Parent:= gProgressForm;
    Left:= 2;
    Top:= gProgressForm.ClientHeight - Height - 20;
    Width:= gProgressForm.ClientWidth - 35;
    Name:= 'prgBar';
    Max := AMaxValue;
  end;

  with TLabel.Create(gProgressForm) do
  begin
    Parent:= gProgressForm;
    Left:= gProgressForm.ClientWidth - 30;
    Top:= gProgressForm.ClientHeight - Height - 20;
    autosize := true;
    Name:= 'lblCount';
    Caption := '';
  end;

  with TLabel.Create(gProgressForm) do
  begin
    Parent:= gProgressForm;
    Left:= 2;
    Top:= gProgressForm.ClientHeight - Height - 2;
    autosize := true;
    Name:= 'lblText';
    Caption := '';
  end;

  gProgressForm.Show;
  Application.ProcessMessages();
end;







begin
end.