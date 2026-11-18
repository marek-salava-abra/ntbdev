var
  gProgressForm : TForm;

procedure ProgressInit(ASite : TSiteForm; ACaption : string; AMaxValue : Integer);
begin
  gProgressForm:= TForm.Create(ASite);
  gProgressForm.BorderStyle:= bsToolWindow;
  gProgressForm.Position:= poScreenCenter;
  gProgressForm.FormStyle := fsStayOnTop;
  gProgressForm.ClientWidth:= 220;
  gProgressForm.ClientHeight:= 40;
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

begin
end.