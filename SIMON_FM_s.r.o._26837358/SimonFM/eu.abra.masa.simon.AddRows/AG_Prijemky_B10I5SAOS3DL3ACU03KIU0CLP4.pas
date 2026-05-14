

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mCAction: TBasicAction;
  mAList: TActionList;
  i : integer;
begin
  mAList := Self.GetMainActionList;
  {for i := 0 to mAList.ActionCount-1 do begin
    mCAction := mALIst.Actions[i];
    if (mCAction.Name = 'actBarCodeReader') then
      TBasicAction(mCAction).ShortCut :=  TextToShortCut ('Ctrl+Q');
  end;}

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Dle EAN';
  mAction.ShortCut := TextToShortCut('Ctrl+Y'); //16450;
  mAction.Hint := 'dohledá řádek';
  mAction.Category := 'tabDetail';
  mAction.OnExecute := @BarCodeOnExecute;
end;




procedure BarCodeOnExecute(Sender : TComponent);


var
  mControl: TControl;
  mStrBatchCode, mOID : string;
  mSite: TSiteForm;
  mGrid : TMultiGrid;
  mActiveDataSet : TNxDataDataSet;
  mDataset: TNxRowsObjectDataSet;
  SL : TStringList;
  i : integer;
  mImportManager: TNxDocumentImportManager;
  mInputParams: TNxParameters;
  mParam: TNxParameter;
  mBO:TNxCustomBusinessObject;
  mIORowsFound, mStoreCardList, mIOList:TStringList;
  mIO_ID, mStoreCard_ID: string;
begin
  mSite := tcomponent(Sender).DynSite;
  if not BarCodeDialog(mStrBatchCode, mSite) then
    exit;
  mBO:=TDynSiteForm(mSite).CurrentObject;
  mGrid := TMultiGrid(NxFindChildControl(mSite.MainPanel, 'grdRows'));
  if not Assigned(mGrid) then begin
    NxShowMessage('info','Nenalezen dbgrid řádků.',mdInformation,false,mSite);
    exit;
  end;
  if NxIsEmptyOID(mbo.GetFieldValueAsString('Firm_ID')) then begin
    NxShowMessage('info','Není vybrána firma do příjemky.',mdInformation,false,mSite);
    exit;
  end;
  mStoreCardList:=TStringList.Create;
  msite.BaseObjectSpace.SQLSelect(format('select sc.id from storecards sc left join storeunits su on su.parent_id=sc.id left join storeeans se on se.parent_id=su.id where sc.hidden=''N'' and se.ean=''%s'' ',[mStrBatchCode]),mStoreCardList);
  if mStoreCardList.count=0 then begin
    NxShowSimpleMessage('Nepovedlo se dohledat kartu s EAN '+mStrBatchCode,mSite);
    exit;
  end;
  mStoreCard_ID:=mStoreCardList.strings[0];
  mIORowsFound:=TStringList.create;
  mSite.BaseObjectSpace.SQLSelect(format('SELECT A.ID FROM IssuedOrders2 A JOIN issuedorders IO ON IO.id = A.parent_id '+
                                         'JOIN Firms F ON F.id = IO.firm_id  WHERE A.RowType=3 '+
                                         'AND ((F.ID=''%s'' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID=''%s'')) ) AND (IO.DocQueue_ID=''1Z00000101'') AND (A.StoreCard_ID = ''%s'' ) AND (IO.closed = ''N'' ) '+
                                         'AND ( (  A.DeliveredQuantity = 0  OR  (A.DeliveredQuantity < A.Quantity AND A.DeliveredQuantity > 0) ) '+
                                         ')  AND ((''N'' = ''A'') OR ((''N'' = ''N'') AND (A.Revided_ID IS NULL)) )) ',[mbo.GetFieldValueAsString('Firm_ID'),mbo.GetFieldValueAsString('Firm_ID'),mStoreCard_ID]),mIORowsFound);
  if mIORowsFound.count=0 then begin
    NxShowSimpleMessage('Nenašel jsem objednávku ',mSite);
    exit;
  end;
  mIO_ID:=msite.BaseObjectSpace.SQLSelectFirstAsString(format('Select parent_id from issuedorders2 where id=''%s'' ',[mIORowsFound.strings[0]]));
  mIOList:=TStringList.Create;
  for i:=0 to mIORowsFound.count-1 do begin
   mIOList.Add(msite.BaseObjectSpace.SQLSelectFirstAsString(format('Select parent_id from issuedorders2 where id=''%s'' ',[mIORowsFound.strings[i]])))
  end;
         mControl:= mSite.FindChildControl('tabRows.grdRows');
         mDataset := TNxRowsObjectDataSet(TMultiGrid(mControl).DataSource.DataSet);
         if Assigned(mDataset) then begin
         mDataSet.DisableControls;
          try
                //mActiveDataSet.SeekID(mStrBatchCode);
                mInputParams := TNxParameters.Create;
                mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows'); // jen povolene radky
                mParam.AsString := mIORowsFound.Text;
                mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
                mParam.AsString := mIO_ID;
                mImportManager := NxCreateDocumentImportManager(mSite.BaseObjectSpace, Class_IssuedOrder, Class_ReceiptCard);
                try
                      mImportManager.OutputDocument := mBO;
                      mImportManager.AddInputDocuments(mIOList);
                      mImportManager.LoadParams(mInputParams);
                      //mImportManager.ExecuteWizard(mSite);
                      mImportManager.Execute;
                      //mImportManager.CheckOutputDocument;
                      //mImportManager.OutputDocument.Save;
                except
                 NxShowSimpleMessage(ExceptionMessage,mSite);

                end;
                 TDynSiteForm(mSite).ActiveDataSet.UpdateFields; //Aby se o změně dozvěděl hlavičkový dataset
                 mDataSet.RefreshAndRestoreLastSelectedItem;
                 mDataset.Last;
                 mDataSet.EnableControls;

          except

          end;
        end;
end;

function BarCodeDialog(var ABarCode : string; aSite:TSiteForm) : boolean;
var
  mForm : TForm;
  mBtn : TButton;
  mLbl : TLabel;
  mBarCodeEdt : TEdit;
begin
  Result := False;
  ABarCode := '';
  mForm := TForm.Create(Application.MainForm);
  mForm.BorderIcons := [biSystemMenu];
  mForm.Left := 30;
  mForm.Top := 50;
  mForm.Width := 290;  // sirka
  mForm.Height := 100; // vyska
  mForm.Caption := 'Výběr DL';

  mLbl := TLabel.Create(mForm);
  mLbl.Caption := 'EAN:';
  mLbl.Left := 10;
  mLbl.Top := 10;
  mLbl.Name := 'lblSerialNumber';
  mForm.InsertControl(mLbl);

  mBarCodeEdt := TEdit.Create(mForm);
  mBarCodeEdt.Left := 90;
  mBarCodeEdt.Top := 8;
  mBarCodeEdt.Width := mForm.Width - mBarCodeEdt.Left - 22; //140;
  mBarCodeEdt.Name := 'edtSerialNumber';
  mBarCodeEdt.Text := '';
  mForm.InsertControl(mBarCodeEdt);

  mBtn := TButton.Create(mForm);
  mBtn.Width := 75;
  mBtn.Height := 25;
  mBtn.Caption := 'OK';
  mBtn.ModalResult := mrOk;
  mBtn.Cancel := False;
  mBtn.Default := True;
  mBtn.Left :=  mForm.Width - 2*(mBtn.Width+2) - 20;
  mBtn.Top := mForm.Height - mBtn.Height - 40;
  mBtn.Name := 'btnOK';
  mForm.InsertControl(mBtn);

  mBtn := TButton.Create(mForm);
  mBtn.Width := 75;
  mBtn.Height := 25;
  mBtn.Caption := 'Storno';
  mBtn.ModalResult := mrCancel;
  mBtn.Cancel := True;
  mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;;
  mBtn.Top := mForm.Height - mBtn.Height - 40;
  mBtn.Name := 'btnCancel';
  mForm.InsertControl(mBtn);

  Result := mForm.ShowModal(Asite)= mrOK;
  if Result then
    ABarCode := mBarCodeEdt.Text;
end;



begin
end.