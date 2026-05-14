procedure New_SPOnExecute(Sender: TObject);
var
  mSite: TSiteForm;
  mGrid: TMultiGrid;
  mControl: TControl;
  mDataSource: TDataSource;
  mDataset: TNxRowsObjectDataSet;
  mForm: TForm;
  mObjectSpace: TNxCustomObjectSpace;
  mr:Tstringlist;
  i:integer;
  mole:variant;
  mOResult:variant;
  mroll:variant;
  mfilter:string;
begin
  if Sender is TComponent then begin
    try
      mSite := NxFindSiteForm(TComponent(Sender));
      if not TDynSiteForm(mSite).Edit then begin
        ShowMessage('Akce vytvoření SP je přístupná jen v editaci dokladu.');
        Exit;
      end;
      mObjectSpace := mSite.BaseObjectSpace;
      mForm:= NxGetSiteAppForm(mSite);
      mControl:= NxFindChildControl(mForm, 'tabDetail');
      mControl := NxFindChildControl(TWinControl(mControl), 'grdRows');
      mGrid := TMultiGrid(mControl);
      mDataSource := mGrid.DataSource;
      mDataset := TNxRowsObjectDataSet(mDataSource.DataSet);
      if Assigned(mDataset) then begin
        // hodnoty z datasetu
        {if not Assigned(mDataset.ActiveItem) then begin
          ShowMessage('Akci rozpadu je možné spustit jen pokud existuje řádek pro rozpad.');
          Exit;
        end;
        }
          mr:=TStringList.create;
        try
                  mOLE:= GetAbraOLEApplication;
                  mOResult:= mOLE.CreateStrings;
                  mRoll:=mOLE.GetRoll('5315B3YAPMNOB0FIRUCLXSJ52O', 0);
                mfilter:='FilterX_Row_OP='+mDataset.CurrentObject.GetFieldValueAsString('id') ;
                mRoll.Params.Add(quotedstr(mfilter));
                //AParams.NewFromDataType(dtString, 'Pokus').AsString := mPart;

              if not mRoll.multiSelectDialog(False,mOResult) then Exit;


        finally
           mr.free;
        end;
      end;
    except
      ShowMessage('Při vytváření servisovaného předmětu došlo k problémům: ' + ExceptionMessage);
    end;
  end;
end;


procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actSHOW_Servisovany_predmet';
  mAction.Caption := 'Upravit SP';
  mAction.Hint := 'Zobrazí servisované předměty k objednávce';
  mAction.Category := 'tabDetail';
  // Nastavime udalost, ktera se vykona pri spusteni teto akce
  mAction.OnExecute := @New_SPOnExecute;
  //mAction.OnUpdate := @btnOnUpdate;
  //mAction.ShortCut := TextToShortCut('Ctrl+Z');
  //mAction.ShortCutCtrlNumber := True;
end;


begin
end.






