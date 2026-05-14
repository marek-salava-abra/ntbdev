


procedure New_SP(AOS: TNxCustomObjectSpace; ASite: TDynSiteForm; mDataset: TNxRowsObjectDataSet);
 var
   self:TNxCustomBusinessObject;
  mHeaderBO: TNxHeaderBusinessObject;
  mResult:string;
adate:Date;
  mMon : TNxCustomBusinessMonikerCollection;
  mNewRow:TNxCustomBusinessObject;

begin


      mHeaderBO := TNxHeaderBusinessObject(aos.CreateObject('OWHN2TMXL2COJJ3LKNBV4OVSTC'));
        try
          mHeaderBO.New;
          mHeaderBO.Prefill;
          mHeaderBO.SetFieldValueAsString('Code', 'aaaa');
          mHeaderBO.SetFieldValueAsString('Name', 'aaaa');
          mHeaderBO.SetFieldValueAsString('X_Row_OP','aaaa');
          mHeaderBO.SetFieldValueAsString('OutdoorPlaceDescription', '');
          mHeaderBO.SetFieldValueAsString('Hidden','');
          mHeaderBO.SetFieldValueAsString('Note', '');
          mHeaderBO.SetFieldValueAsinteger('InformClientKind',0);

          mHeaderBO.SetFieldValueAsString('Firm_ID', mDataset.CurrentObject.GetFieldValueAsString('Parent_ID.Firm_id'));
          mHeaderBO.SetFieldValueAsString('FirmOffice_ID', mDataset.CurrentObject.GetFieldValueAsString('Parent_ID.FirmOffice_ID'));
          mHeaderBO.SetFieldValueAsString('Person_ID', mDataset.CurrentObject.GetFieldValueAsString('Parent_ID.Person_ID'));
          mHeaderBO.SetFieldValueAsString('OwnerFirm_ID', mDataset.CurrentObject.GetFieldValueAsString('Parent_ID.Firm_id'));
          mHeaderBO.SetFieldValueAsString('PayerFirm_ID', mDataset.CurrentObject.GetFieldValueAsString('Parent_ID.Firm_id'));
          mHeaderBO.SetFieldValueAsString('PayerFirmOffice_ID', mDataset.CurrentObject.GetFieldValueAsString('Parent_ID.FirmOffice_ID'));
          mHeaderBO.SetFieldValueAsString('PayerPerson_ID', mDataset.CurrentObject.GetFieldValueAsString('Parent_ID.Person_ID'));
          mHeaderBO.SetFieldValueAsString('PlaceAddress_ID', '');
          mHeaderBO.SetFieldValueAsString('X_ID', 'V'+mHeaderBO.oid);


          mHeaderBO.SetFieldValueAsString('BusOrder_ID', mDataset.CurrentObject.GetFieldValueAsString('BusOrder_ID'));
          mHeaderBO.SetFieldValueAsString('BusProject_ID', mDataset.CurrentObject.GetFieldValueAsString('BusProject_ID'));
          mHeaderBO.SetFieldValueAsString('BusTransaction_ID', mDataset.CurrentObject.GetFieldValueAsString('BusTransaction_ID'));

          //mHeaderBO.SetFieldValueAsinteger('ProductionYear', '');
          //mHeaderBO.SetFieldValueAsString('ServicedObjectType_ID', '');

          mHeaderBO.save;
//           TDynSiteForm.ShowDynFormWithNewDocument('B10I5SAOS3DL3ACU03KIU0CLP4', asite.SiteContext, mHeaderBO);
        finally

        end;
//      mForm.free;
//        mHeaderBO.Free;
end;



procedure New_SPOnExecute(Sender: TObject);
var
  mSite: TSiteForm;
  mGrid: TdbGrid;
  mControl: TControl;
  mDataSource: TDataSource;
  mDataset: TNxRowsObjectDataSet;
  mForm: TForm;
  mObjectSpace: TNxCustomObjectSpace;
  mr:Tstringlist;
  i:integer;
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
          mr:=TStringList.create;
        try
           mObjectSpace.SQLSelect('select sp_id from Servicedobjects where X_Row_OP=' + quotedstr(mDataset.CurrentObject.OID),mr);
           if mr.count<mDataset.CurrentObject.GetFieldValueAsFloat('Quantity') then begin

               for i:=mr.count to trunc(mDataset.CurrentObject.GetFieldValueAsFloat('Quantity')) do begin
                   New_SP(mObjectSpace, TDynSiteForm(mSite), mDataset);
               end;
           end else begin
               NxShowSimpleMessage('K řádku dokladu již existují servisované předměty. Nelze vytvořit další.',msite);
           end ;

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
  mAction.Name := 'actNew_Servisovany_predmet';
  mAction.Caption := 'Servisovany_predmet';
  mAction.Hint := 'Vytvoří servisované předměty k objednávce';
  mAction.Category := 'tabDetail';
  // Nastavime udalost, ktera se vykona pri spusteni teto akce
  mAction.OnExecute := @New_SPOnExecute;
  //mAction.OnUpdate := @btnOnUpdate;
  //mAction.ShortCut := TextToShortCut('Ctrl+Z');
  //mAction.ShortCutCtrlNumber := True;
end;


begin
end.