uses
  '_Books_NoDevelUsr.uScSiteFunc';

const
  cInDebug = False;

procedure ShowDebugMessage(AMessage: string);
begin
  if cInDebug then
    ShowMessage(AMessage);
end;


// pridani check boxu na detail agend
procedure _InitSelf_PostHook(Self: TSiteForm);
var
  mComponent: TCheckBox;
  mControl, chkDiscounts, chkFrozenDiscounts: TControl;
  mLeft, mTop: Integer;
  AForm: TSiteForm;
begin
  AForm := Self;
  MemberSiteForm(AForm);
  mControl := NxFindChildControl(AForm, 'chkIndividualDiscounts');
  if VarIsNull(mControl) then
    mComponent := TCheckBox(mControl)
  else
    mComponent := nil;
  if not VarIsNull(mComponent) then begin
    chkDiscounts := NxFindChildControl(AForm, 'chkDiscountsExcluded');
    mLeft := chkDiscounts.Left;
    chkDiscounts.Top := chkDiscounts.Top - 3;
    mTop := chkDiscounts.Top;
    //gbDiscounts.Height := gbDiscounts.Height + 22;
    //chkFrozenDiscounts := NxFindChildControl(AForm, 'chkFrozenDiscounts');
    //if Assigned(chkFrozenDiscounts) then
    //  chkFrozenDiscounts.Top := chkFrozenDiscounts.Top + 22;
    mComponent := TCheckBox.Create(AForm);
    mComponent.Parent := TWinControl(NxFindChildControl(AForm, 'pnHeader')); // main panel
    mComponent.Name := 'chkIndividualDiscounts';
    //SetPropValue(mComponent, 'Alignment', taLeftJustify);
    //mComponent.Alignment := 0;
    mComponent.Left := mLeft;//352;
    mComponent.Top := 252;//mTop - 4;//349;
    mComponent.Width := 165;//126;
    mComponent.Height := 17;
    mComponent.Caption := 'Neaplikovat slevu "Dle menu"';
    mComponent.TabOrder := 37;
    mComponent.OnClick := @chkDiscountsOnClick;
  end;
  NxSetReadOnly([mComponent], True);
  SetLocalSiteObject(mComponent, 'SCchkIndividualDiscounts', AForm);

  TBusRollSiteForm(AForm).DataSet.AfterScroll := @DatasetAfterScroll;
  TBusRollSiteForm(AForm).DataSet.BeforePost := @DatasetBeforePost;
  TBusRollSiteForm(AForm).DataSet.AfterCancel := @DatasetAfterCancel;
end;

procedure DatasetAfterScroll(DataSet: TDataSet);
var
  mDataSet: TNxCustomObjectDataSet;
  mObject: TNxCustomBusinessObject;
  mCheckBox: TControl;
begin
  try
    ShowDebugMessage('DatasetAfterScroll');
    mDataSet := TNxCustomObjectDataSet(DataSet);
    mObject := mDataSet.CurrentObject;
    mCheckBox := GetLocalSiteObject('SCchkIndividualDiscounts', nil);
    if not VarIsNull(mCheckBox) then begin
      ShowDebugMessage('chk nalezen na situ => nastavuje se hodnota');
      TCheckBox(mCheckBox).Checked := mObject.GetFieldValueAsBoolean('X_DONT_USE_MENU_DISCOUNT');
    end;
  except
    ShowDebugMessage('Skript: Skryta chyba v DT Scroll eventu');
  end;
end;

procedure DatasetBeforePost(DataSet: TDataSet);
var
  mDataSet: TNxCustomObjectDataSet;
  mObject: TNxCustomBusinessObject;
  mValue: string;
  mCheckBox: TControl;
begin
  try
    ShowDebugMessage('DatasetBeforePost');
    mDataSet := TNxCustomObjectDataSet(DataSet);
    mObject := mDataSet.CurrentObject;
    mCheckBox := GetLocalSiteObject('SCchkIndividualDiscounts', nil);
    if not VarIsNull(mCheckBox) then
      mObject.SetFieldValueAsBoolean('X_DONT_USE_MENU_DISCOUNT', TCheckBox(mCheckBox).Checked);
  except
    ShowDebugMessage('Skript: Skryta chyba v DT BeforePost eventu');
  end;
end;

procedure DatasetAfterCancel(DataSet: TDataSet);
var
  mDataSet: TNxCustomObjectDataSet;
  mObject: TNxCustomBusinessObject;
  mCheckBox: TControl;
begin
  try
    ShowDebugMessage('DatasetAfterCancel');
    mDataSet := TNxCustomObjectDataSet(DataSet);
    mObject := mDataSet.CurrentObject;
    mCheckBox := GetLocalSiteObject('SCchkIndividualDiscounts', nil);
    if not VarIsNull(mCheckBox) then
      TCheckBox(mCheckBox).Checked := mObject.GetFieldValueAsBoolean('X_DONT_USE_MENU_DISCOUNT');
  except
    ShowDebugMessage('Skript: Skryta chyba v DT AfterCancel eventu');
  end;
end;

{
Vyvolává se po provedení metody CloseQuery. Pomocí tohoto háčku je možné ovlivnit, zda je možné agendu/formulář zavřít.
}
procedure FormCloseQuery_Hook(Self: TSiteForm; var CanClose: Boolean);
begin
  UnMemberSiteForm(Self);
end;

procedure chkDiscountsOnClick(Sender: TObject);
var
  mCheckBox: TCheckBox;
  mSite: TBusRollSiteForm;
  mDataSet: TNxCustomObjectDataSet;
  mObject: TNxCustomBusinessObject;
begin
  ShowDebugMessage('chkDiscountsOnClick');
  mCheckBox := TCheckBox(Sender);
  mSite := TBusRollSiteForm(NxFindSiteForm(mCheckBox));
  mDataSet := TNxCustomObjectDataSet(mSite.DataSet);
  mObject := mDataSet.CurrentObject;
  mObject.SetFieldValueAsBoolean('X_DONT_USE_MENU_DISCOUNT', mCheckBox.Checked);
end;

begin
end.