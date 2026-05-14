Uses 'eu.abra.IssueOrderFromSubcards.fcesql', 'eu.abra.IssueOrderFromSubcards.CreateZamestnanec',
     'eu.abra.IssueOrderFromSubcards.Progress', 'eu.abra.IssueOrderFromSubcards.ZamTisk', 'eu.abra.IssueOrderFromSubcards.Theft';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TAction;
  mUser : TNxCustomBusinessObject;
begin
  if not Assigned(Self.BaseObjectSpace) then
    exit;
    mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');
    mUser.Load(Self.CompanyCache.GetUserID, nil);
    if (mUser.GetFieldCode('U_zamprod')>0) and mUser.GetFieldValueAsBoolean('U_zamprod') then begin
    mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := 'Krádež';
    mAction.Hint := 'Evidence ukradených věcí';
    mAction.Category := 'tabList';
    mAction.OnExecute := @CreateTheft;
    mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := 'Prodej Zaměst';
    mAction.Hint := 'Prodej zaměstnanci s tiskem a více položek';
    mAction.Category := 'tabList';
    mAction.OnExecute := @ZamTisk;
    mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := 'Spotřeba Firma';
    mAction.Hint := 'Vnitro spotřeba';
    mAction.Category := 'tabList';
    mAction.OnExecute := @ImportOnExecute;
    end;
    mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := 'Dodavatelé';
    mAction.Hint := 'Dodavatelé';
    mAction.Category := 'tabList';
    mAction.OnExecute := @RefreshSuppliers;
  end;


procedure ImportOnUpdate(Sender: TObject);
begin
  TBasicAction(Sender).Enabled := True;
end;

procedure ImportOnExecute(Sender: TObject);
var
 mSite:TsiteForm;
 mParams, mTemplates: TNxParameters;
 mPopis, mEan, mStoreCard_ID, mDivision_ID,mBusProject_ID, mStore_ID, mDisplayName: String;
 mQuantity:Extended;
 mDialog:Boolean;
 mUser, mStoreCard, mBillOfDelivery, mBillOfDeliveryRow:TNxCustomBusinessObject;
 mOS:TNxCustomObjectSpace;
 mRows:TNxCustomBusinessMonikerCollection;
begin
  mSite := TComponent(Sender).BusRollSite;
  mBusProject_ID:='';
  mStore_ID:='';
  mStoreCard_ID:='';
  mDialog:=false;
  mEan:='';
  mQuantity:=1;
  mPopis:='';
  mOs:=msite.CompanyObjectSpace;
  muser:= mOS.CreateObject('22AHIVDVAVE13C5S00CA141B44');
    mUser.Load(NxGetActualUserID(mOS), nil);
    mDivision_ID:=mUser.GetFieldValueAsString('X_Division_ID');
  SpotrebaData(msite,mBusProject_ID, mStore_ID, mStoreCard_ID,mEan, mDialog, mQuantity, mPopis, mUser);


    //muser.Free;

    if not(mDialog) then begin
       NxShowMessage('Info','Ruším založení firemní spotřeby', mdInformation,false,msite);
       exit;
    end;
    if NxIsEmptyOID(mStoreCard_ID) and not(mEAN='') then begin
      mStoreCard_ID:=scrGetStoreCard_ID(mOS, mEAN);

    end;
  mStoreCard:= mOS.CreateObject(Class_StoreCard);
    mStoreCard.Load(mStoreCard_ID,nil);
    if NxMessageBox('Dotaz', 'Chcete přidat '+mStoreCard.GetFieldValueAsString('Name')+' v počtu '+FloatToStr(mQuantity)+' do firemní spotřeby?', mdConfirm, mdbYesNo, 0, 0, False, msite)=mrYes then begin


            mBillOfDelivery:=mOS.CreateObject(Class_BillOfDelivery);
            mBillOfDelivery.New;
            mBillOfDelivery.Prefill;
            mBillOfDelivery.SetFieldValueAsString('Docqueue_ID','2B00000101');
            mBillOfDelivery.SetFieldValueAsString('Description',mPopis);
            mBillOfDelivery.SetFieldValueAsString('U_Odpis','4U00000101');
            mrows:=mBillOfDelivery.GetCollectionMonikerForFieldCode(mBillOfDelivery.GetFieldCode('Rows'));
            mBillOfDeliveryRow:=mrows.AddNewObject;
            mBillOfDeliveryRow.SetFieldValueAsInteger('RowType',3);
            mBillOfDeliveryRow.SetFieldValueAsString('Store_ID',mStore_ID);
            mBillOfDeliveryRow.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
            mBillOfDeliveryRow.SetFieldValueAsString('Division_ID',mDivision_ID);
            mBillOfDeliveryRow.SetFieldValueAsString('BusTransaction_ID','1000000101');
            mBillOfDeliveryRow.SetFieldValueAsString('BusProject_ID',mBusProject_ID);
            mBillOfDeliveryRow.SetFieldValueAsFloat('Quantity',mQuantity);
            mBillOfDelivery.save;
            mDisplayName:=mBillOfDelivery.DisplayName;
            mBillOfDelivery.Free;

        NxShowSimpleMessage('Založil jsem dodací list '+mDisplayName,mSite);
    end;

end;



procedure CreateZamestnanec(Sender: TObject);
var
 msite: TSiteForm;
 mOS:TNxCustomObjectSpace;
 mActivity, mOutgoingTransfer, mOutgoingTransferRowBO, mRelation, mUser, mStoreCard: TNxCustomBusinessObject;
 mStoreCard_ID, mBusProject_ID,mDivision_ID, mStore_ID, mOutgoingTransfer_ID, mActivity_OID, mActivityNumber:String;
 mMemo, mDescription, mEAN :String;
 mDialog:Boolean;
 mQuantity, mCenaKK: Extended;
 mRows:TNxCustomBusinessMonikerCollection;
 mStringList:TStringList;
 mPrintList:TStringList;
 mText:string;

begin
 mSite := TComponent(Sender).BusRollSite;
 mOs:=msite.CompanyObjectSpace;
 mStoreCard_ID:='';
 mDialog:=false;
 mQuantity:=1;
    try
    ZamestnanciData(msite, mBusProject_ID, mStore_ID, mStoreCard_ID, mEAN, mDialog, mQuantity, mCenaKK);
    muser:= mOS.CreateObject('22AHIVDVAVE13C5S00CA141B44');
    mUser.Load(NxGetActualUserID(mOS), nil);
    mDivision_ID:=mUser.GetFieldValueAsString('X_Division_ID');
    muser.Free;

    if not(mDialog) then begin
       NxShowMessage('Info','Ruším založení Zaměstnaneckého prodeje', mdInformation,false,msite);
       exit;
    end;
    if NxIsEmptyOID(mStoreCard_ID) and not(mEAN='') then begin
      mStoreCard_ID:=scrGetStoreCard_ID(mOS, mEAN);
    
    end;
    if ((mStoreCard_ID='3I35000101') or (mStoreCard_ID='1J35000101')) and (mCenaKK=0) then begin
       NxShowMessage('Info','Ruším založení Zaměstnaneckého prodeje, nebyla vyplněna cena pro skladovou kartu', mdInformation,false,msite);
       exit;
    end;
    if NxIsEmptyOID(mStoreCard_ID) or NxIsEmptyOID(mBusProject_ID) then begin
       NxShowMessage('Info','Ruším založení Zaměstnaneckého prodeje, není vyplněna skladová karta, nebo zaměstnanec', mdInformation,false,msite);
       exit;
    end;
    mStoreCard:= mOS.CreateObject(Class_StoreCard);
    mStoreCard.Load(mStoreCard_ID,nil);
    if NxMessageBox('Dotaz', 'Chcete přidat '+mStoreCard.GetFieldValueAsString('Name')+' v počtu '+FloatToStr(mQuantity)+' do zaměstnaneckého prodeje?', mdConfirm, mdbYesNo, 0, 0, False, msite)=mrYes then begin
        mPrintList:=TStringList.create;
        mOutgoingTransfer_ID:=scrOutgoingTransfer_ID(mOS,(inttostr(NxExtractMonth(now))));
        if (NxExtractMonth(now))=1 then mText:='Leden';
        if (NxExtractMonth(now))=2 then mText:='Únor';
        if (NxExtractMonth(now))=3 then mText:='Březen';
        if (NxExtractMonth(now))=4 then mText:='Duben';
        if (NxExtractMonth(now))=5 then mText:='Květen';
        if (NxExtractMonth(now))=6 then mText:='Červen';
        if (NxExtractMonth(now))=7 then mText:='Červenec';
        if (NxExtractMonth(now))=8 then mText:='Srpen';
        if (NxExtractMonth(now))=9 then mText:='Září';
        if (NxExtractMonth(now))=10 then mText:='Říjen';
        if (NxExtractMonth(now))=11 then mText:='Listopad';
        if (NxExtractMonth(now))=12 then mText:='Prosinec';
        if NxIsEmptyOID(mOutgoingTransfer_ID) then begin
            mOutgoingTransfer:=mOS.CreateObject(Class_OutgoingTransfer);
            mOutgoingTransfer.New;
            mOutgoingTransfer.Prefill;
            mOutgoingTransfer.SetFieldValueAsString('Docqueue_ID','R200000101');
            mOutgoingTransfer.SetFieldValueAsString('Description','Drobný prodej MO '+mText+ ' '+ mOutgoingTransfer.GetFieldValueAsString('Period_ID.code'));
            mrows:=mOutgoingTransfer.GetCollectionMonikerForFieldCode(mOutgoingTransfer.GetFieldCode('Rows'));
            mOutgoingTransferRowBO:=mrows.AddNewObject;
            mOutgoingTransferRowBO.SetFieldValueAsInteger('RowType',3);
            mOutgoingTransferRowBO.SetFieldValueAsString('Store_ID',mStore_ID);
            mOutgoingTransferRowBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
            mOutgoingTransferRowBO.SetFieldValueAsString('Division_ID',mDivision_ID);
            mOutgoingTransferRowBO.SetFieldValueAsString('BusTransaction_ID','1000000101');
            mOutgoingTransferRowBO.SetFieldValueAsString('BusProject_ID',mBusProject_ID);
            mOutgoingTransferRowBO.SetFieldValueAsFloat('Quantity',mQuantity);
            mOutgoingTransferRowBO.SetFieldValueAsFloat('U_cenasdph2',mCenaKK);
            mOutgoingTransferRowBO.SetFieldValueAsString('U_user_id',NxGetActualUserID(mOS));
            mPrintList.Add(mOutgoingTransferRowBO.OID);
            mOutgoingTransfer.save;
            mOutgoingTransfer.Free;
        
        End;
        if not(NxIsEmptyOID(mOutgoingTransfer_ID)) then begin
            mOutgoingTransfer:=mOS.CreateObject(Class_OutgoingTransfer);
            mOutgoingTransfer.Load(mOutgoingTransfer_ID,nil);
            mrows:=mOutgoingTransfer.GetLoadedCollectionMonikerForFieldCode(mOutgoingTransfer.GetFieldCode('Rows'));
            mOutgoingTransferRowBO:=mrows.AddNewObject;
            mOutgoingTransferRowBO.SetFieldValueAsInteger('RowType',3);
            mOutgoingTransferRowBO.SetFieldValueAsString('Store_ID',mStore_ID);
            mOutgoingTransferRowBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
            mOutgoingTransferRowBO.SetFieldValueAsString('Division_ID',mDivision_ID);
            mOutgoingTransferRowBO.SetFieldValueAsString('BusTransaction_ID','1000000101');
            mOutgoingTransferRowBO.SetFieldValueAsString('BusProject_ID',mBusProject_ID);
            mOutgoingTransferRowBO.SetFieldValueAsFloat('Quantity',mQuantity);
            mOutgoingTransferRowBO.SetFieldValueAsFloat('U_cenasdph2',mCenaKK);
            mOutgoingTransferRowBO.SetFieldValueAsString('U_user_id',NxGetActualUserID(mOS));
            mPrintList.Add(mOutgoingTransferRowBO.OID);
            mOutgoingTransfer.save;
            mOutgoingTransfer.Free;
        End;
        // založit stringlist s ID řádku a pak udělat tisk toho řádku automaticky na tiskárnu která je v siti
        // PrintRowOoutgoingTransfer doplnit datum na řádek kdy byla položka
        // NxPrintByIDs(Self.Context, mIDs, CLSID, Report_ID, rtoPrint, pekARP, '\\192.168.101.10\Datamax_E4205e_01', '');
        //CFxReportManager.PrintByIDs(NxCreateContext_1(mOutgoingTransfer),mPrintList,'WBFDIVPW1ZE13HBT00C5OG4NF4','1Y50000101',rtoPreview,pekPDF, '', '');
        //CFxReportManager.PrintByIDs(NxCreateContext_1(mOutgoingTransfer),mPrintList,'WBFDIVPW1ZE13HBT00C5OG4NF4','1Y50000101',rtoPrint, pekPDF, '\\192.168.101.10\Datamax_E4205e_01', '');
        mPrintList.free;
        NxShowMessage('Info','Položka byla přidána', mdInformation,false,msite);
    end;
    finally

     mos.Free;

    end;

end;

Procedure RefreshSuppliers(Sender:Tobject);

var
 mSupplierBO, mBO:TNxCustomBusinessObject;
 mSupplier_id, mfirm_ID,mStoreCard_id,mQunit:String;
 i:Integer;
 mSite:TSiteForm;
 mOpenDlg : TOpenDialog;
 mList : TStringList;
begin
   mSite := NxFindSiteForm(TComponent(Sender));
  mOpenDlg := TOpenDialog.Create(TComponent(Sender));
  try

    if mOpenDlg.Execute then begin
      mList := TStringLIst.Create;
      try
        mList.LoadFromFile(mOpenDlg.FileName);
        //Import_AddRows(ARows : TNxCustomBusinessMonikerCollection; AList : TStringList; ADivision_ID : string; AStore_ID : string)
        mBO := TBusRollSiteForm(mSite).DataSet.CurrentObject;
        ProgressInit(mSite, 'Nahrávám dodavatele ...', mList.count);
        for i:=1 to mlist.Count-1 do begin
             //mPodExtCode:=NxToken(mlist.Strings(i),';');
             mFirm_ID:=NxToken(mlist.Strings(i),';');
             mStoreCard_ID:=NxToken(mlist.Strings(i),';');
             mQunit:=NxToken(mlist.Strings(i),';');

              mSupplier_ID:=scrGetSupplier_ID(mbo.ObjectSpace,mFirm_ID,mStoreCard_ID);

              if (NxIsEmptyOID(mSupplier_ID)) then begin
                 mSupplierBO:= mbo.ObjectSpace.CreateObject(Class_Supplier);
                 mSupplierBO.New;
                 mSupplierBO.Prefill;
                 mSupplierBO.SetFieldValueAsString('Firm_ID',mFirm_ID);
                 mSupplierBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
                 mSupplierBO.SetFieldValueAsString('Qunit',mQunit);
                 mSupplierBO.Save;
                 mSupplierBO.free;

         ProgressSetPos(i+1);
        end;
        end;
      finally
        mList.Free;
      end;

      ProgressDispose();
      ShowMessage('Import dokončen.');
    end else
      ShowMessage('Import přerušen.');
   finally
    mOpenDlg.Free;
   end;


end;





begin
end.