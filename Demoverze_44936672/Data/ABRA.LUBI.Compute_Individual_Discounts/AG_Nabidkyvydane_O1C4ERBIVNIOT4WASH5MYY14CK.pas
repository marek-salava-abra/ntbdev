uses
  'ABRA.LUBI.Compute_Individual_Discounts.uIndividualDiscounts',
  '_Books_NoDevelUsr.uScSiteFunc';

procedure FormCreate_Hook(Self: TSiteForm);
begin
  //ShowMessage('FormCreate');
  //AddCheckBox(self); lubi problematicke
  AddButton(Self, 'LN2RG42OWZVODHSAIXNA5PY1PS');
  AddEditButton(Self, 'LN2RG42OWZVODHSAIXNA5PY1PS');
end;

{
Vyvolává se po provedení metody CloseQuery. Pomocí tohoto háčku je možné ovlivnit, zda je možné agendu/formulář zavřít.
}
procedure FormCloseQuery_Hook(Self: TSiteForm; var CanClose: Boolean);
begin
  FreeAllObjects(Self);
end;

 // reseni stisnuti tlacitka na aktualizaci cen
procedure _InitSelf_PostHook(Self: TSiteForm);
var
  mAction, mComponent: TContainedAction;
  mControl, chkDiscounts, chkFrozenDiscounts: TControl;
  mActList: TActionList;
  i: integer;
begin
  AddCheckBox(self);

  mComponent := nil;
  mActList := self.GetMainActionList;
  for i := 0 to mActList.ActionCount - 1 do begin
    mAction := mActList.Actions(i);
    if mAction.Name = 'actUpdateFirm' then begin
      mComponent := mAction;
      mComponent.OnExecute := @ActualizeDiscountsOnExecute;
    end;
  end;
end;

procedure ActualizeDiscountsOnExecute(Sender: TObject);
var
  mSite: TDynSiteForm;
  mDataSet: TNxCustomObjectDataSet;
  mObject: TNxCustomBusinessObject;
  i: integer;
  mCollection: TNxCustomBusinessMonikerCollection;
  mRow: TNxCustomBusinessObject;
begin
  mSite := TDynSiteForm(NxFindSiteForm(TComponent(Sender)));
  mDataSet := TNxCustomObjectDataSet(mSite.ActiveDataSet);
  mObject := mDataSet.CurrentObject;
  mCollection := mObject.GetLoadedCollectionMonikerForFieldCode(mObject.GetFieldCode('Rows'));
  for i := 0 to mCollection.Count - 1 do begin
    mRow := mCollection.BusinessObject(i);
    mRow.Invalidate;
    mRow.SetFieldValueAsBoolean('X_DISCOUNTEVALUED', False);
    ComputeIndividualDiscounts(mRow, True, False);
  end;
  try
    mDataSet.UpdateFields();
  except
    // pozrani pripadne chyby
  end;
  NxShowMessage('ULMER - Individuální slevy', 'Bylo provedeno přepočítání individuálních slev dle menu na dokladu případně i s přepočtem ostatních slev dle volby.', mdInformation, false, nil);
end;

begin
end.