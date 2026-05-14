

{
Vyvolává se v průběhu vytváření shell-okna. Context je již k dispozici.
}
procedure OnCreate_Hook(AShellForm: TShellForm);
var
  mpnTop: TPanel;
  mpnUser: TPanel;
  mWidth: Integer;
  mBtnOk: TControl;
  mParentForm: TForm;
  mUserName: string;
  mFormName: string;
  mFirmName:string;
  mConnectionName:string;
begin


  mUserName := AShellForm.Context.GetCompanyCache.GetUserName;

  mConnectionName:= AShellForm.context.GetObjectSpace.GetConnectionName;

  mFormName := '';
  mBtnOK := TControl(AShellForm.FindComponent('btnOK'));
  if Assigned(mBtnOk) then
  begin
    mParentForm := mBtnOk.FindParentForm;
    if Assigned(mParentForm) then
    begin
      mFormName := mParentForm.Name;
    end;
  end;



  mpnTop := TPanel(AShellForm.FindComponent('pnTop'));
  mWidth := 0;
  if Assigned(mpnTop) then
  begin
    mWidth := mpnTop.Width;
  end;
  mpnUser := TPanel.Create(AShellForm);
  mpnUser.Parent := AShellForm;
  mpnUser.Name := 'mpnUser';
  mpnUser.Left := 0;
  mpnUser.Top := 25;
  mpnUser.Width := mWidth;
  mpnUser.Height := 40;
  mpnUser.Align := alTop;
  mpnUser.BorderStyle := 1;
  mpnUser.BorderWidth := 2;
  mpnUser.Caption := 'Uživatel: ' + mUserName + ' ( v databázi: LIPOELASTIC )';
  mpnUser.PanelColor := pcCustom;
  mpnUser.Color := clFuchsia;
  mpnUser.ParentColor := False;
  mpnUser.ParentFont := False;
  mpnUser.Font.Height := -25;
  mpnUser.Font.Style := [fsBold];


  AShellForm.WindowState := wsMaximized;
end;


procedure OnShow_Hook(AShellForm: TShellForm);
var
  mpnTreeTop: TPanel;
begin
  mpnTreeTop := TPanel(AShellForm.FindComponent('pnTreeTop'));
  if Assigned(mpnTreeTop) then
  begin
    mpnTreeTop.Color := clPurple;
  end;
end;

begin
end.