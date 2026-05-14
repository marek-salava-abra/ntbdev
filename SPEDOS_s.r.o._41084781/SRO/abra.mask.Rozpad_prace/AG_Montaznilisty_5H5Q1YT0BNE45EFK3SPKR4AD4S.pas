uses
  'abra.mask.Rozpad_prace.Main',
  'abra.mask.Rozpad_prace.Books';

procedure RowDecayOnExecute(Sender: TObject);
var
  mSite: TSiteForm;
  mGrid: TdbGrid;
  mControl: TControl;
  mDataSource: TDataSource;
  mDataset: TNxRowsObjectDataSet;
  mForm: TForm;
  mObjectSpace: TNxCustomObjectSpace;
begin
  ShowDebugMessage('RowDecayOnExecute');
  if Sender is TComponent then begin
    try
      mSite := NxFindSiteForm(TComponent(Sender));
      if not TDynSiteForm(mSite).Edit then begin
        ShowMessage('Akce rozpadu je přístupná jen v editaci dokladu.');
        Exit;
      end;
      mObjectSpace := mSite.BaseObjectSpace;
      mForm:= NxGetSiteAppForm(mSite);
      mControl:= NxFindChildControl(mForm, 'tabDetail');
      mControl := NxFindChildControl(TWinControl(mControl), 'grdServiceAssemblyRows');
      mGrid := TdbGrid(mControl);
      mDataSource := mGrid.DataSource;
      mDataset := TNxRowsObjectDataSet(mDataSource.DataSet);
      if Assigned(mDataset) then begin
        // hodnoty z datasetu
        {if not Assigned(mDataset.ActiveItem) then begin
          ShowMessage('Akci rozpadu je možné spustit jen pokud existuje řádek pro rozpad.');
          Exit;
        end;
        }
        if mDataset.FieldByName('Itemtype').AsInteger <> 0 then begin
          ShowMessage('Akci rozpadu je možné spustit jen pro řádek typu 0.');
          Exit;
        end;
        RowDecay2(mObjectSpace, TDynSiteForm(mSite), mDataset);
        (*if not Assigned(mDataset.ActiveItem) then begin
          ShowMessage('Akci rozpadu je možné spustit jen pokud existuje řádek pro rozpad.');
          Exit;
        end;
        if NxIsEmptyOID(mDataset.ActiveObject.OID{CurrentObject.OID}) then begin
          ShowMessage('Akci rozpadu je možné spustit jen pokud existuje uložený řádek pro rozpad.');
          Exit;
        end
        else
          if mDataset.CurrentObject.GetFieldValueAsInteger('Itemtype') <> 0 then begin
            ShowMessage('Akci rozpadu je možné spustit jen pro řádek typu 0.');
            Exit;
          end;
        RowDecay(mObjectSpace, TDynSiteForm(mSite), mDataset.CurrentObject, mDataset);
        *)
      end;
    except
      ShowMessage('V průběhu rozpadu řádků ML došlo k chybě: ' + ExceptionMessage);
    end;
  end;
end;

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  ShowDebugMessage('Form Create hook');
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actRowDecay';
  mAction.Caption := 'Práce';
  mAction.Hint := 'Provede rozpad aktuálního řádku';
  mAction.Category := 'tabDetail';
  // Nastavime udalost, ktera se vykona pri spusteni teto akce
  mAction.OnExecute := @RowDecayOnExecute;
  //mAction.OnUpdate := @btnOnUpdate;
  //mAction.ShortCut := TextToShortCut('Ctrl+Z');
  //mAction.ShortCutCtrlNumber := True;
end;

procedure btnOnUpdate(Sender: TObject);
var
  mSite: TSiteForm;
begin
  {if Sender is TComponent then begin
    mSite := NxFindSiteForm(TComponent(Sender));
    if Assigned(mSite) then begin
      if mSite is TDynSiteForm then begin
        // akce je k dispozici pouze v pripade, ze je v datasetu nejaky zaznam
        // a v pripade, ze je zahajena editace
        TBasicAction(Sender).Enabled := Not TDynSiteForm(mSite).ActiveDataSet.EOF
          and TDynSiteForm(mSite).Edit;
      end;
    end;
  end;}
end;

begin
end.