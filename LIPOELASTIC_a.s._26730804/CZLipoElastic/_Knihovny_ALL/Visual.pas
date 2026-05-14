// Přidání tlačítka na panel funkcí

function AddFunctionButton(ASite: TSiteForm; AShowControl, AShowMenuItem: Boolean; ACaption, AHint, ACategory: String; AOnExecute: Pointer): TBasicAction;
var
  mAction: TBasicAction;
begin
  Result := nil;
  if Assigned(ASite) then begin
    mAction := ASite.GetNewAction;
    if Assigned(mAction) then begin
      mAction.ShowControl := AShowControl;
      mAction.ShowMenuItem := AShowMenuItem;
      mAction.Caption := ACaption;
      mAction.Hint := AHint;
      mAction.Category := ACategory;
      mAction.OnExecute := AOnExecute;
    end;
    Result := mAction;
  end;
end;


function AddActionButton(ASite: TSiteForm; AShowControl, AShowMenuItem: Boolean; AName, ACaption, AHint, ACategory: String; AOnExecute: Pointer): TBasicAction;
var
  mAction: TBasicAction;
begin
  Result := nil;
  if Assigned(ASite) then begin
    mAction := ASite.GetNewAction;
    if Assigned(mAction) then begin
      mAction.ShowControl := AShowControl;
      mAction.ShowMenuItem := AShowMenuItem;
      mAction.Name := AName;
      mAction.Caption := ACaption;
      mAction.Hint := AHint;
      mAction.Category := ACategory;
      mAction.OnExecute := AOnExecute;
    end;
    Result := mAction;
  end;
end;


// Tlačítko multiakce
// AItems - string akcí oddělených ,
function AddMultiActionButton(ASite: TSiteForm; AShowControl, AShowMenuItem: Boolean; AName, ACaption, AItems, AHint, ACategory: String; AOnExecute: Pointer): TMultiAction;
var
  mAction: TMultiAction;
begin
  Result := nil;
  if Assigned(ASite) then begin
    mAction := ASite.GetNewMultiAction;
    if Assigned(mAction) then begin
      mAction.ShowControl := AShowControl;
      mAction.ShowMenuItem := AShowMenuItem;
      mAction.Name := AName;
      mAction.Caption := ACaption;
      mAction.Hint := AHint;
      mAction.Category := ACategory;
      mAction.OnExecuteItem := AOnExecute;
      mAction.Items.CommaText := AItems;
    end;
    Result := mAction;
  end;
end;

// obyč tlačítko
// CreateButton(mPanel.Owner, mPanel, 0, mPanel.Width-220, 100, 20, 'Caption', 1);
{
function CreateButton(AOwner: TComponent; AParent: TWinControl; ATop, ALeft, AWidth, AHeight: integer; ACaption: string; AModalResult: integer): TButton;
begin
  Result := TButton.Create(AOwner);
  Result.Top := ATop;
  Result.Left := ALeft;
  Result.Width := AWidth;
  Result.Height := AHeight;
  Result.Caption := ACaption;
  Result.ModalResult := AModalResult;
  Result.Parent := AParent;
end;
}

// refresh řádků

procedure RefreshRowsGrid(ASite: TSiteForm);
var
  mComponent: TComponent;
  mDataSet: TDataSet;
begin
  mComponent := ASite.FindComponent('dtRows');
  if Assigned(mComponent) then begin
    if mComponent is TDataSet then begin
      mDataSet := TDataSet(mComponent);
      mDataSet.Refresh;
    end else
      //ShowMessage('dtRows neni typu TDataSet');
      exit;
  end else
    //ShowMessage('Nepodarilo se najit dtRows');
    exit;
end;


// jednoduchý messagebox
function CreateInfoMsgBox(ACaption: string; var ALabel: TLabel): TForm;
begin
  Result := TForm.Create(nil);
  try
    with Result do begin
      Caption := ACaption;
      Name := 'frmCaption';
      Position := poScreenCenter;
      Visible := false;
      Width := 300;
      Height := 100;
      FormStyle := fsStayOnTop;
    end;
    ALabel := TLabel.Create(Result);
    with ALabel do begin
      Name := 'lblMain';
      Align := alClient;
      Parent := Result;
      Alignment := taCenter;
      Layout := tlCenter;
      Caption := '';
    end;
  except
    Result.Free;
    Result := nil;
    RaiseException(ExceptionMessage);
  end;
end;



// logovací formulář
procedure CreateLogForm(AForm: TSiteForm; var mLogForm: TForm; var mLogMemo: TMemo);
begin
  mLogForm := TForm.Create(AForm);
  mLogMemo := TMemo.Create(mLogForm);

  with mLogForm do begin
    Left := 335;
    Top := 250;
    Width := 726;
    Height := 437;
    Caption := '';
    Color := clBtnFace;
    Font.Color := clWindowText;
    OldCreateOrder := False;
    PixelsPerInch := 96;
    FormStyle := fsStayOnTop;
  end;
  with mLogMemo do begin
    Parent := mLogForm;
    Left := 0;
    Top := 0;
    Width := 718;
    Height := 410;
    Align := alClient;
    TabOrder := 0;
    ScrollBars := ssVertical;
    Font.Name := 'Courier New';
    Font.Size := 10;
  end;
end;


// přesune focus na danou záložku
// př: Přesun na záložku Obsah
//   ParentControlName = 'pgcDetail'
//   TabName = 'tabRows'

procedure ActivateTab(SiteForm: TSiteForm; ParentControlName, TabName: string);
var
  mPC : TPageControl;
  mTS : TTabSheet;

begin
  mPC := TPageControl(SiteForm.FindChildControl(ParentControlName));
  mTS := TTabSheet(SiteForm.FindChildControl(TabName));
  if Assigned(mPC) and Assigned(mTS) then begin
    if mTS.PageIndex <> 0 then begin
      TPageControl(mPC).ActivePage := mTS;
    end;
  end;
end;


// Změní pozici fieldu v řádkovém multi gridu grdRows
// Self - Site form agendy
// AFieldName - Název fieldu
// ALine - cílová řádka
// APosition - cílová pozice

procedure MoveFieldInGrdRows(var Self: TSiteForm; AFiledName: string; ALine, APosition: integer;);
var
  mGridRows: TMultiGrid;
  mGridCol: TNxMultiGridCustomColumn;
  i: Integer;
begin

  mGridRows := TMultiGrid(Self.FindChildControl('grdRows'));
  for i:= 0 to mGridRows.ColumnCount -1 do begin
    mGridCol := mGridRows.Columns[i];
    if UpperCase(mGridCol.FieldName) = UpperCase(AFiledName) then begin
      mGridCol.Line := ALine;
      mGridCol.Order := APosition;
    end;
  end;

end;


// načtení aktuálních hodnot status baru
procedure GetSBar(ASite: TSiteForm; var ASbar: TControl; var AOriginalText: string; var AOriginalWidth: integer);
var
  mSBarColl: TCollection;
begin
  ASbar := ASite.FindChildControl('sbarSite');
  mSBarColl := TCollection(RTTI.GetObjectProp(ASbar, 'Panels'));
  AOriginalText := RTTI.GetStrProp(mSBarColl.Items[0], 'Text');
  AOriginalWidth := RTTI.GetPropValue(mSBarColl.Items[0], 'Width');
end;

// nastavení hodnot status baru
procedure SetSBar(ASbar: TControl; AText: String; AWidth: integer = 300);
var
  mSBarColl: TCollection;
begin
  mSBarColl := TCollection(RTTI.GetObjectProp(ASbar, 'Panels'));
  RTTI.SetPropValue(mSBarColl.Items[0], 'Width', AWidth);
  RTTI.SetStrProp(mSBarColl.Items[0], 'Text', AText);
  ASbar.Repaint;
  Application.ProcessMessages;
end;





begin
end.