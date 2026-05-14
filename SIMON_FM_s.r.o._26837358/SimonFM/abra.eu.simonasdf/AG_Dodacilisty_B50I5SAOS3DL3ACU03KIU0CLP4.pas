procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mMAction : TMultiAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Vytvoř vratku';
  mAction.Hint := 'K danému záznamu vytvoří vratku a převodku';
  mAction.Category := 'tabDetail, tabList';
  mAction.OnExecute := @CreateVR;
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Vyřídit';
  mAction.Hint := 'Vyřídí dodací list';
  mAction.Category := 'tabDetail, tabList';
  mAction.OnExecute := @CloseBOD;
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Změna ceny';
  mAction.Hint := 'Změní cenu na řádku DL';
  mAction.Category := 'tabDetail';
  mAction.OnExecute := @ChangePrice;
  //mAction.OnUpdate := @CreateDocumentOnUpdate;
end;
procedure CloseBOD(Sender: TObject);
var
 msite: TSiteForm;
 mBOD:TNxCustomBusinessObject;

begin
if Sender is TComponent then begin
    mSite := TComponent(Sender).DynSite;
    if Assigned(mSite) and (mSite is TDynSiteForm) then begin
    mBOD:=TDynSiteForm(mSite).CurrentObject;
    msite.BaseObjectSpace.SQLExecute(Format('update storedocuments set finished=''A'' where id=''%s'' ',[mBOD.OID]));
    end;
end;
end;

Procedure ChangePrice(Sender: TObject);
var
  mSite: TDynSiteForm;
  mBO, mBORow : TNxCustomBusinessObject;
  mGRows : TMultiGrid;
  mDataSet : TDataset;
  mPrice: Extended;
  mDialog:Boolean;
begin
     mPrice:=0;
     mSite := TComponent(Sender).DynSite;
     mBO := TDynSiteForm(mSite).CurrentObject;
     mGRows := TMultiGrid(NxFindChildControl(NxGetSiteAppForm(mSite), 'grdRows'));
     if Assigned(mGRows) then begin
          mDataSet:= mGRows.DataSource.DataSet;
          mBORow:=TNxObjectDataset(mDataset).CurrentObject;
          mPrice:=mBORow.getFieldValueAsFloat('U_CenasDPH2');
          PriceData(msite,mPrice,mDialog);
          mBORow.SetFieldValueAsFloat('U_CenasDPH2',mPrice);
          mbo.Save;
     end;
     mDataSet.Refresh;
end;



procedure CreateVR(Sender: TObject);
var
 msite: TSiteForm;
 mImportMan: TNxDocumentImportManager;
 mOS: TNxCustomObjectSpace;
 mInputParams: TNxParameters;
 mParam: TNxParameter;
 mBillOfDelivery, mOutGoingTransfer, mBillOfDeliveryRow, mOTRow,mRelation, mReceiptCard:TNxCustomBusinessObject;
 mBoDRows, mOTRows:TNxCustomBusinessMonikerCollection;
 mFirm_ID,mStore_ID, mRefundedBillOfDelivery_ID, mOT_ID,mReceiptCard_ID, mActivity_ID, mRefundedReceiptCard_ID:String;
 i:Integer;
 mDialog, mVratit:Boolean;
 mStringList: TStringList;
 
begin
 mDialog:=False;
 mOT_ID:='';
 mSite := TComponent(Sender).DynSite;
 mOs:=msite.CompanyObjectSpace;
 mBillOfDelivery:=TDynSiteForm(mSite).CurrentObject;
 if not(Assigned(mBillOfDelivery)) then exit;
 if not(mBillOfDelivery.GetFieldValueAsString('DocQueue_ID')='1X10000101') then begin
    ShowMessage('Dodací list není z řady DLR, nelze tvořit vratku a převodku.');
    exit;
    
 end;
 mBoDRows:=mBillOfDelivery.GetLoadedCollectionMonikerForFieldCode(mBillOfDelivery.GetFieldCode('Rows'));
 for i:=0 to mBoDRows.count-1 do begin
    mBillOfDeliveryRow:=mBoDRows.BusinessObject[i];
    if not(mBillOfDeliveryRow.GetFieldValueAsString('Store_ID')='1K00000101') then begin
        if NxMessageBox('Info', 'DLR nemá řádky z reklamačního skladu', mdConfirm, mdbOk, 0, 0, False, msite)=mrOk then
       exit;
    end;
 end;
if not(nxisemptyOID(ScrGetRefundedBillOfDelivery_ID(mOS,mBillOfDelivery.OID))) then begin
     if NxMessageBox('Info', 'Dodací list má již vratku', mdConfirm, mdbOk, 0, 0, False, msite)=mrOk then
       exit;

 end;
 
 StoreData(msite, mStore_ID, mDialog, mVratit);
 if not(mDialog) then begin
       if NxMessageBox('Info', 'Ruším založení vratky a převodu', mdConfirm, mdbOk, 0, 0, False, msite)=mrOk then
       exit;
    end;
 try
    mInputParams := TNxParameters.Create;
    try

      //ShowMessage(mReceiptCard.DisplayName);
      mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
      mParam.AsString := '2L10000101';
      mParam := mInputParams.GetOrCreateParam(dtString, 'Firm_ID');
      mParam.AsString := mBillOfDelivery.GetFieldValueAsString('Firm_ID');

      mImportMan := NxCreateDocumentImportManager(mOS, Class_BillOfDelivery,Class_RefundedBillOfDelivery);
      try
        mImportMan.AddInputDocument(mBillOfDelivery.OID);
        mImportMan.LoadParams(mInputParams);
        mImportMan.Execute;
        mImportMan.CheckOutputDocument;
        if Assigned(mImportMan.OutputDocument) then begin
          mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', '2L10000101'); // musi byt...
          mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID', mBillOfDelivery.GetFieldValueAsString('Firm_ID'));

          mImportMan.OutputDocument.Save;
          mRefundedBillOfDelivery_ID:=mImportMan.OutputDocument.OID;
        end;
      finally
        mImportMan.Free;
      end;
    finally
      mInputParams.Free;
    end;
  except
  end;
  //if not(not(NxIsEmptyOID(mStore_ID)) and not(NxIsEmptyOID(mRefundedBillOfDelivery_ID)) and not(mVratit)) then begin
  //   ShowMessage('Něco se nepovedlo');
  //  exit;
  //end;
  if mVratit and not(NxIsEmptyOID(mRefundedBillOfDelivery_ID)) then begin
   mActivity_ID:=scrActivity_ID(mos,mBillOfDelivery.OID);
   if not(NxIsEmptyOID(mActivity_ID)) then  mReceiptCard_ID:=scrReceiptcard_ID(mOS,mActivity_ID);
   if not(NxIsEmptyOID(mReceiptCard_ID)) then begin
     try
    mInputParams := TNxParameters.Create;
    try
      mReceiptCard:=mos.CreateObject(Class_ReceiptCard);
      mReceiptCard.Load(mReceiptCard_ID,nil);
      
      //ShowMessage(mReceiptCard.DisplayName);
      mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
      mParam.AsString := '1V10000101';
      mParam := mInputParams.GetOrCreateParam(dtString, 'FirmOffice_ID');
      mParam.AsString := mReceiptCard.GetFieldValueAsString('FirmOffice_ID');
      mParam := mInputParams.GetOrCreateParam(dtString, 'Person_ID');
      mParam.AsString := mReceiptCard.GetFieldValueAsString('Person_ID');

      mImportMan := NxCreateDocumentImportManager(mOS, Class_ReceiptCard,Class_RefundedReceiptCard);
      try
        mImportMan.AddInputDocument(mReceiptCard_ID);
        mImportMan.LoadParams(mInputParams);
        mImportMan.Execute;
        mImportMan.CheckOutputDocument;
        if Assigned(mImportMan.OutputDocument) then begin
          mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', '1V10000101'); // musi byt...
          mImportMan.OutputDocument.SetFieldValueAsString('FirmOffice_ID', mReceiptCard.GetFieldValueAsString('FirmOffice_ID'));
          mImportMan.OutputDocument.SetFieldValueAsString('Person_ID', mReceiptCard.GetFieldValueAsString('Person_ID'));
          mImportMan.OutputDocument.Save;
          mRefundedReceiptCard_ID:=mImportMan.OutputDocument.OID;
          mRelation := mOS.CreateObject('01ZXNDSYDVD135SA02K2CQM5AW');
          mRelation.New;
      mRelation.SetFieldValueAsString('LEFTSIDE_ID', mActivity_ID);
      mRelation.SetFieldValueAsString('RIGHTSIDE_ID', mRefundedReceiptCard_ID);
      mRelation.SetFieldValueAsInteger('REL_DEF', 1267);
      mRelation.Save;
     mRelation.free;
     mReceiptCard.free;
        if NxMessageBox('Dotaz', 'Založil jsem vratku příjemky '+mImportMan.OutputDocument.DisplayName+'. Chcete ji vytisknout?', mdConfirm, mdbYesNo, 0, 0, False, msite)=mrYes then begin
          if not(NxIsEmptyOID(mRefundedReceiptCard_ID)) then begin
        mStringList:=TStringList.Create;
        mStringList.Add(mRefundedReceiptCard_ID);
        CFxReportManager.PrintByIDs(msite.SiteContext,mStringList,'VADQ0NX0IZDOL5HOBSJHGQJAHW','1B50000101',rtoPreview,pekPDF,'','');
     end;
    end;
        end;
      finally
        mImportMan.Free;
      end;
    finally
      mInputParams.Free;
    end;
  except
    // Roberte - chybu poziram - event se vola opakovane, pri opakovanem volani managera na OP, ktera jiz ma DL vytvoren, manager generuje vyjimku
    //ShowMessage('Chyba DL z OP: ' + ExceptionMessage);
  end;
  end;
  
  
  
  end;
  if not(NxIsEmptyOID(mStore_ID)) and not(NxIsEmptyOID(mRefundedBillOfDelivery_ID)) and not(mVratit) then begin
    try
    mOutGoingTransfer:=mos.CreateObject(Class_OutgoingTransfer);
    mOutGoingTransfer.New;
    mOutGoingTransfer.Prefill;
    mOutGoingTransfer.SetFieldValueAsString('Firm_ID',mBillOfDelivery.GetFieldValueAsString('Firm_ID'));
    mOutGoingTransfer.SetFieldValueAsString('DocQueue_ID','R200000101');
    mOutGoingTransfer.SetFieldValueAsString('Description', mBillOfDelivery.DisplayName);
    mOTRows:=mOutGoingTransfer.GetCollectionMonikerForFieldCode(mOutGoingTransfer.GetFieldCode('Rows'));
    for i:=0 to mBoDRows.count-1 do begin
     mOTRow:=mOTRows.AddNewObject;
     mOTRow.SetFieldValueAsInteger('RowType',mBoDRows.BusinessObject[i].GetFieldValueAsInteger('RowType'));
     mOTRow.SetFieldValueAsString('Store_ID',mBoDRows.BusinessObject[i].GetFieldValueAsString('Store_ID'));
     mOTRow.SetFieldValueAsString('StoreCard_ID',mBoDRows.BusinessObject[i].GetFieldValueAsString('StoreCard_ID'));
     mOTRow.SetFieldValueAsFloat('Quantity',mBoDRows.BusinessObject[i].GetFieldValueAsFloat('Quantity'));
     mOTRow.SetFieldValueAsString('Qunit',mBoDRows.BusinessObject[i].GetFieldValueAsString('Qunit'));
     mOTRow.SetFieldValueAsString('Division_ID',mBoDRows.BusinessObject[i].GetFieldValueAsString('Division_ID'));
     mOTRow.SetFieldValueAsString('BusTransaction_ID',mBoDRows.BusinessObject[i].GetFieldValueAsString('BusTransaction_ID'));
    end;
    mOutGoingTransfer.save;
    mOT_ID:=mOutGoingTransfer.OID;
    finally
    mOutGoingTransfer.free;
    end;
  end;
 try
    mInputParams := TNxParameters.Create;
    try

      //ShowMessage(mReceiptCard.DisplayName);
      mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
      mParam.AsString := 'Q200000101';
      mParam := mInputParams.GetOrCreateParam(dtString, 'Store_ID');
      mParam.AsString := mStore_ID;

      mImportMan := NxCreateDocumentImportManager(mOS, Class_OutgoingTransfer,Class_IncomingTransfer);
      try
        mImportMan.AddInputDocument(mOT_ID);
        mImportMan.LoadParams(mInputParams);
        mImportMan.Execute;
        mImportMan.CheckOutputDocument;
        //NxShowSimpleMessage(mStore_ID,msite);
        if Assigned(mImportMan.OutputDocument) then begin
          mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', 'Q200000101');

          mImportMan.OutputDocument.Save;
        end;
      finally
        mImportMan.Free;
      end;
    finally
      mInputParams.Free;
    end;
  except
    // Roberte - chybu poziram - event se vola opakovane, pri opakovanem volani managera na OP, ktera jiz ma DL vytvoren, manager generuje vyjimku
    //ShowMessage('Chyba DL z OP: ' + ExceptionMessage);
  end;
  
  NxShowMessage('Info','Hotovo',mdInformation,false,msite);
  
end;

Function StoreData(asite:tsiteform;var aStore_id:string; var aDialog:Boolean; var aVratit:Boolean):boolean;

 var mForm : TForm;
    mCbStore: TRollComboEdit;
    mCbCcStore: TLabel;
    mLabel3 : TLabel;
    mBEd1: TCheckBox;
    mButOk, mButCancel : TButton;
    mResult : integer;

begin

    mForm:= TForm.Create(asite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Width:= 520;
    mForm.Height:= 150;
    mForm.Caption := 'Zadejte údaje pro převodku příjem';
    mForm.Position := poScreenCenter;

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Cíl. sklad:';
    mLabel3.Top := 17;
    mLabel3.Left := 17;
    mLabel3.Height := 13;

    mCbCcStore:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCcStore.Parent:= mForm;
    //mCbCcStore.BevelOuter:= bvLowered;
    mCbCcStore.Left:= 228;
    mCbCcStore.Top:= 15;
    mCbCcStore.Width:= 255;

    mCbStore:= TRollComboEdit.Create(mForm);
    mCbStore.Parent:= mForm;

    mCbStore.ClassID:= 'O3ZO2K155FDL3CL100C4RHECN0';
    mCbStore.Complete:= True;
    mCbStore.ForcedField:= True;
    mCbStore.Prefilling:= pmNone;
    mCbStore.TextField:= 'Code';  // položka podle které se bude vyhledávat
    mCbStore.Top:= 15;
    mCbStore.Left:= 107;
    mCbStore.Width:= 108;
    mCbStore.ConnectedControl:= mCbCcStore;
    mCbStore.ConnectedControlField:= 'Name';  //položka která bude zobrazena v containeru
    
    mBEd1:= TCheckBox.Create(mForm);
    mBEd1.Left := 17;
    mBEd1.Top := 44;
    mBEd1.Caption := 'Vrátit zákazníkovi?';
    mBEd1.Checked := False;
    mBEd1.Parent := mForm;
    mbed1.Width:=255;
    
        mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'Ok';
    mButOk.Top := 70;
    mButOk.Left := 252;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Cancel';
    mButCancel.Top := 70;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;


    mResult := mForm.ShowModal(asite);
   // if mButCancel.OnC
    if mResult = 1 then begin
        aStore_id:= mCbStore.DataText;
        aVratit:= mbed1.Checked;
        adialog:=true;

        end;
    if mResult=2 then aDialog:=False;

    //ShowMessage(mCb.DataText);
    //Result := mCb.DataText;
    mForm.free;

end;

Function PriceData(asite:tsiteform;var aPrice:Extended; var aDialog:Boolean;):boolean;

 var mForm : TForm;
    mCbStore: TComboEdit;
    mCbCcStore: TComboBevel;
    mLabel3 : TLabel;
    mBEd1: TCheckBox;
    mED: TNumEdit;
    mButOk, mButCancel : TButton;
    mResult : integer;

begin

    mForm:= TForm.Create(asite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Width:= 520;
    mForm.Height:= 150;
    mForm.Caption := 'Zadejte údaje pro změnu ceny';
    mForm.Position := poScreenCenter;

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Cena:';
    mLabel3.Top := 17;
    mLabel3.Left := 17;
    mLabel3.Height := 13;

    mED:= TNumEdit.Create(mForm);
    mED.Parent :=mForm;
    mED.left := 107;
    mED.top := 17;
    mED.Value := aPrice;
    mED.DecimalPlaces:=2;
    
    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'Ok';
    mButOk.Top := 70;
    mButOk.Left := 252;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Cancel';
    mButCancel.Top := 70;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;


    mResult := mForm.ShowModal(asite);
   // if mButCancel.OnC
    if mResult = 1 then begin
        aPrice:=mED.Value;
        adialog:=true;

        end;
    if mResult=2 then aDialog:=False;

    //ShowMessage(mCb.DataText);
    //Result := mCb.DataText;
    mForm.free;

end;



function scrReceiptcard_ID(AOS : TNxCustomObjectSpace; AActivity_ID : string) : String;
const
  cSQL = 'SELECT RightSide_ID  FROM Relations WHERE rel_def=1245 and LeftSide_ID=''%s''';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [AActivity_ID]), mList);
    if mList.Count > 0 then
      Result := (mList.Strings[0]);
  finally
    mList.Free;
  end;
end;

function scrActivity_ID(AOS : TNxCustomObjectSpace; BOD_ID : string) : String;
const
  cSQL = 'SELECT LeftSide_ID  FROM Relations WHERE rel_def=1238 and RightSide_ID=''%s''';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [BOD_ID]), mList);
    if mList.Count > 0 then
      Result := (mList.Strings[0]);
  finally
    mList.Free;
  end;
end;

function ScrGetRefundedBillOfDelivery_ID(AOS : TNxCustomObjectSpace; BOD_ID : string) : String;
const
  cSQL = 'SELECT ID  FROM StoreDocuments  WHERE documenttype=''23'' and rDocument_ID=''%s''';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [BOD_ID]), mList);
    if mList.Count > 0 then
      Result := (mList.Strings[0]);
  finally
    mList.Free;
  end;
end;
begin
end.