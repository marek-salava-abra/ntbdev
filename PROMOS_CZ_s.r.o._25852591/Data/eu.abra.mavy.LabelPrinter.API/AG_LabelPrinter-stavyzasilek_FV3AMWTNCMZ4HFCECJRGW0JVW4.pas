uses 'eu.abra.mavy.LabelPrinter.API.fce';
var
  mColorDialog: TColorDialog;
  mButton, mButton2: TButton;
  mPanel, mPanel2: TPanel;
{
Vyvolává se po vytvoření instance formuláře.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mControl: TControl;
  mAction: TBasicAction;
begin
  FormCreate(Self);
  if Self is TBusRollSiteForm then
  begin
    mControl := NxFindChildControl(NxGetSiteAppForm(Self), 'grdList');
    if Assigned(mControl) and (mControl is TDBGrid) then
      TDBGrid(mControl).OnDrawColumnCell := @grdOrdersListDrawCell;
  end;
  if CheckLicence(Self.SiteContext) then begin
    mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := 'Import LP';
    mAction.Hint := 'Importuje přepravce z LP';
    mAction.Category := 'tabList';
    mAction.OnExecute := @ImportLPStates;
  end;


end;

procedure _MainDatasetAfterScroll_Hook(Self: TBusRollSiteForm);
begin
  ScrollDataset(Self);
end;


procedure ScrollDataset(ASiteForm:TBusRollSiteForm);
var
  mDataset: TDataset;
  mColorPanel: TPanel;
  mControl: TControl;
begin
  if Assigned(ASiteForm.CurrentObject) then begin
    mControl := NxFindChildControl(ASiteForm.MainPanel, 'tabDetail');
    if Assigned(mControl) then
      mControl := NxFindChildControl(TWinControl(mControl), 'pnDetail');
    if Assigned(mControl) then
      mColorPanel := TPanel(NxFindChildControl(TWinControl(mControl), 'pnJOColor'));
    if Assigned(mColorPanel) then
      mColorPanel.Color := ASiteForm.CurrentObject.GetFieldValueAsInteger('X_BackgroundColor');
  end;

  if Assigned(ASiteForm.CurrentObject) then begin
    mControl := NxFindChildControl(ASiteForm.MainPanel, 'tabDetail');
    if Assigned(mControl) then
      mControl := NxFindChildControl(TWinControl(mControl), 'pnDetail');
    if Assigned(mControl) then
      mColorPanel := TPanel(NxFindChildControl(TWinControl(mControl), 'pnJOColor2'));
    if Assigned(mColorPanel) then
      mColorPanel.Color := ASiteForm.CurrentObject.GetFieldValueAsInteger('X_FontColor');
  end;
end;


procedure grdOrdersListDrawCell(Sender: TObject;
  const Left, Top, Right, Bottom: Integer; DataCol: Integer; Column: TColumn;
  State: TGridDrawState);
var
  mDtSet: TDataset;
  mDbGrd: TDbGrid;
  mCanvas: TCanvas;
  mCnt: Double;
  mSite: TBusRollSiteForm;
begin
  mDtSet := Column.Grid.DataSource.DataSet;
  mDbGrd := TDbGrid(Column.Grid);
   mSite := TBusRollSiteForm(mDbGrd.Owner);
  mCanvas := mDbGrd.Canvas;
  if Assigned(mSite.CurrentObject) then begin
    if Column.FieldName = 'Code' then
    begin
        if mSite.CurrentObject.GetFieldValueAsInteger('X_BackgroundColor')>0 then
        begin
          //mCanvas.Font.Style := [fsBold];
          mCanvas.Font.Color := mSite.CurrentObject.GetFieldValueAsInteger('X_FontColor');
          mCanvas.Brush.Color := mSite.CurrentObject.GetFieldValueAsInteger('X_BackgroundColor');
        end else
        begin
          mCanvas.Font.Color := clWindowText;
          mCanvas.Brush.Color := clWindow;
        end;
        mDbGrd.DefaultDrawColumnCell(Left, Top, Right, Bottom, DataCol, Column, State);
    end;
  end;
end;

procedure FormCreate(ASiteForm:TSiteForm);
var
  mControl: TControl;
  mMasterEdit: TObjectComboEdit;
  mParent: TWinControl;
begin
  mControl := NxFindChildControl(ASiteForm.MainPanel, 'tabDetail');
  mControl := NxFindChildControl(TWinControl(mControl), 'pnDetail');
  //mControl := NxFindChildControl(TWinControl(mControl), 'pnDetailDefinable');
  mParent := TWinControl(mControl);

  mPanel := TPanel.create(ASiteForm);
  with mPanel do begin
    Parent := mParent;
    Name := 'pnJOColor';
    Left :=  420;
    Width := 57;
    Height := 25;
    Top :=  8;
    TabStop := false;
    Caption := '';
    PanelColor := pcCustom;
    ParentBackground := false;
    ParentColor := false;
    Color := clBlack;
  end;

  mButton := TButton.Create(ASiteForm);
  with mButton do begin
    Parent := mParent;
    Name := 'btnColor';
    Left :=  320;
    Width := 92;
    Height := 25;
    Top := 8;
    TabStop := false;
    Caption := 'Barva Pozadí';
    OnClick := @ChooseBackgroundColor
  end;
  mPanel2 := TPanel.create(ASiteForm);
  with mPanel2 do begin
    Parent := mParent;
    Name := 'pnJOColor2';
    Left :=  600;
    Width := 57;
    Height := 25;
    Top :=  8;
    TabStop := false;
    Caption := '';
    PanelColor := pcCustom;
    ParentBackground := false;
    ParentColor := false;
    Color := clBlack;
  end;

  mButton2 := TButton.Create(ASiteForm);
  with mButton2 do begin
    Parent := mParent;
    Name := 'btnColor2';
    Left :=  500;
    Width := 92;
    Height := 25;
    Top := 8;
    TabStop := false;
    Caption := 'Barva Fontu';
    OnClick := @ChooseFontColor
  end;
end;

procedure ChooseBackgroundColor(Sender: TComponent);
var
  mObj: TNxCustomBusinessObject;
begin
  mColorDialog := TColorDialog.Create(Sender);
  try
    if mColorDialog.Execute then begin
      mPanel.ParentColor := false;
      mPanel.Color := mColorDialog.Color;
      mObj := TBusRollSiteForm(NxFindSiteForm(TComponent(Sender))).CurrentObject;
      if Assigned(mObj) then
        mObj.SetFieldValueAsInteger('X_BackgroundColor', mColorDialog.Color);
    end
  finally
    mColorDialog.Free;
  end;
end;

procedure ChooseFontColor(Sender: TComponent);
var
  mObj: TNxCustomBusinessObject;
begin
  mColorDialog := TColorDialog.Create(Sender);
  try
    if mColorDialog.Execute then begin
      mPanel.ParentColor := false;
      mPanel.Color := mColorDialog.Color;
      mObj := TBusRollSiteForm(NxFindSiteForm(TComponent(Sender))).CurrentObject;
      if Assigned(mObj) then
        mObj.SetFieldValueAsInteger('X_FontColor', mColorDialog.Color);
    end
  finally
    mColorDialog.Free;
  end;
end;

begin
end.