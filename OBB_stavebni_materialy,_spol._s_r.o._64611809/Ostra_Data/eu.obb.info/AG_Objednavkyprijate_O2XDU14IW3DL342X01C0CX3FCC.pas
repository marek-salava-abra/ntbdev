procedure _InitSelf_PostHook(Self: TSiteForm);
var
  // mDataSet: TDataSet;
  // mColumn: TColumn;
  mPage: TTabSheet;
  mControl: TControl;
  // mGrid: TNxDBGrid;
  mUserFormPage: TTabSheet;
  mUser:TNxCustomBusinessObject;
begin
  if not(NxIsEmptyOID(NxGetActualUserID(self.BaseObjectSpace))) then begin
  mUser:=self.BaseObjectSpace.CreateObject(Class_SecurityUser);
  mUser.Load(NxGetActualUserID(self.BaseObjectSpace),nil);
  if not(mUser.GetFieldValueAsBoolean('U_info')) then begin
  try
    mControl := NxFindChildControl(Self.MainPanel, 'tabDetail');
    mControl := NxFindChildControl(TWinControl(mControl), 'pnDetail');
    mControl := NxFindChildControl(TWinControl(mControl), 'pgcDetail');
    mUserFormPage := TTabSheet(NxFindChildControl(TWinControl(mControl),'tabSellingInformation'));
    if Assigned(mUserFormPage) then begin
      // Def.formular na prvni zalozku
      //mUserFormPage.PageIndex := 0;
      mUserFormPage.TabVisible := false;

    end;
  finally
  end;
  end;
  end;
end;

begin
end.