uses 'abra.eu.simonasdf.service';

procedure CreateNewReclamation(Sender: TObject);
var
 msite: TSiteForm;
 mOS:TNxCustomObjectSpace;
 mActivity, mReceiptCardBO, mReceiptCardrowBO, mRelation, mUser, mReceivedInvoice: TNxCustomBusinessObject;
 mStoreCard_ID, mFirm_ID,mDivision_ID, mPerson_ID, mResponsiblePerson_ID, mActivity_OID, mActivityNumber, mFirmDelivery_ID:String;
 mMemo, mDescription, mDocuments :String;
 mDialog:Boolean;
 mQuantity: Extended;
 mRows:TNxCustomBusinessMonikerCollection;
 mStringList:TStringList;
 mZpusob, mZpusobDescription, mReceiptCard_ID,mBillOfDelivery_ID, mFPVarSymbol, mReceiptCardBOD_ID, mOldFirmDelivery_ID, mFP_ID:String;
 
begin
 mSite := TComponent(Sender).DynSite;
 mOs:=msite.CompanyObjectSpace;
 mStoreCard_ID:='';
 mQuantity:=1;
    try
    ReclamationData(msite, mFirm_ID, mPerson_ID, mStoreCard_ID, mMemo, mDescription, mDocuments, mResponsiblePerson_ID, mDialog, mQuantity, mZpusob,mZpusobDescription, mFirmDelivery_ID);

    if not(mDialog) then begin
        NxShowMessage('Info','Ruším založení aktivity', mdWarning,false,msite);

       exit;
    end;
    if NxIsEmptyOID(mStoreCard_ID) then begin
        NxShowMessage('Info','Ruším založení aktivity, není vyplněna skladová karta', mdWarning,false,msite);
       exit;
    end;
    mActivity:=mOS.CreateObject('AVV1JYV5AVNOZHQCK0D4CJFUCS');
    mActivity.New;
    mActivity.Prefill;
    muser:= mOS.CreateObject('22AHIVDVAVE13C5S00CA141B44');
    mUser.Load(NxGetActualUserID_1(mActivity), nil);
    mDivision_ID:=mUser.GetFieldValueAsString('X_Division_ID');
    muser.Free;
    mActivity.SetFieldValueAsString('ActivityArea_ID','1100000101');
    mActivity.SetFieldValueAsString('ActivityType_ID','1100000101');
    mActivity.SetFieldValueAsString('ActQueue_ID','1200000101');
    if not(NxIsEmptyOID(mFirm_ID)) then mActivity.SetFieldValueAsString('Firm_ID',mFirm_id);
    if NxIsEmptyOID(mFirm_ID) then mActivity.SetFieldValueAsString('Firm_ID','AAA1000000');
    mActivity.SetFieldValueAsString('Person_ID',mPerson_ID);
    mActivity.SetFieldValueAsString('Division_ID',mDivision_ID);
    mActivity.SetFieldValueAsString('BusTransaction_ID','1000000101');
    mActivity.SetFieldValueAsString('SolverRole_ID','1100000101');
    mActivity.SetFieldValueAsString('Description',mMemo);
    mActivity.SetFieldValueAsDateTime('SheduledDuration$DATE',15);
    if not(mZpusob='výměna zboží') then mActivity.SetFieldValueAsInteger('Status',1)
    else mActivity.SetFieldValueAsInteger('Status',2);
    mActivity.SetFieldValueAsString('U_AddDescription', mDescription);
    mActivity.SetFieldValueAsString('U_documents', mDocuments);
    mActivity.SetFieldValueAsString('U_zpusob',mZpusob);
    mActivity.SetFieldValueAsString('Answer',mZpusobDescription);
    mActivity.SetFieldValueAsString('U_servicedstorecard_ID', mStoreCard_ID);
    //ShowMessage(mOdpovednaosoba_ID);
    mActivity.SetFieldValueAsString('U_odpovednaosoba_ID',mResponsiblePerson_ID);
    mActivity.Save;
    mActivity_OID:=mActivity.OID;
    mActivityNumber:=mActivity.DisplayName;
    mActivity.free;
    if not(mZpusob='výměna zboží') then begin
    if NxMessageBox('Dotaz', 'Založil jsem reklamaci '+mActivityNumber+'. Chcete zboží přijmout na reklamační sklad?', mdConfirm, mdbYesNo, 0, 0, False, msite)=mrYes then begin
     mReceiptCardBO:=mOS.CreateObject('E03ZNUMDTCC4PDAUIEY1MBTJC0');
     mReceiptCardBO.New;
     mReceiptCardBO.Prefill;
     if NxIsEmptyOID(mFirm_id) then mReceiptCardBO.SetFieldValueAsString('Firm_ID','AAA1000000');
     if not(NxIsEmptyOID(mFirm_id)) then mReceiptCardBO.SetFieldValueAsString('Firm_ID',mFirm_id);
     mReceiptCardBO.SetFieldValueAsString('DocQueue_ID','1T10000101');
     mReceiptCardBO.SetFieldValueAsString('Person_ID',mPerson_ID);
     mReceiptCardBO.SetFieldValueAsString('Description', mActivityNumber);
     mrows:=mReceiptCardBO.GetCollectionMonikerForFieldCode(mReceiptCardBO.GetFieldCode('Rows'));
     mReceiptCardROWBO:=mrows.AddNewObject;
     mReceiptCardROWBO.SetFieldValueAsInteger('RowType',3);
     mReceiptCardROWBO.SetFieldValueAsString('Store_ID','1K00000101');
     mReceiptCardROWBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
     mReceiptCardROWBO.SetFieldValueAsString('Division_ID',mDivision_ID);
     mReceiptCardROWBO.SetFieldValueAsString('BusTransaction_ID','1000000101');
     mReceiptCardrowBO.SetFieldValueAsBoolean('CompletePrices',True);
     mReceiptCardROWBO.SetFieldValueAsFloat('Quantity',mQuantity);
     mReceiptCardBO.save;
     mReceiptCard_ID:=mReceiptCardBO.OID;

     mRelation := mOS.CreateObject('01ZXNDSYDVD135SA02K2CQM5AW');
      mRelation.New;
      mRelation.SetFieldValueAsString('LEFTSIDE_ID', mActivity_OID);
      mRelation.SetFieldValueAsString('RIGHTSIDE_ID', mReceiptCardBO.OID);
      mRelation.SetFieldValueAsInteger('REL_DEF', 1245);
      mRelation.Save;
     mRelation.free;
     mReceiptCardBO.free;
     mOldFirmDelivery_ID:=scrGetOldFirm_ID(mos,mFirmDelivery_ID);
     mReceiptCardBOD_ID:=ScrGetReceiptCard_ID(mos,mFirmDelivery_ID, mOldFirmDelivery_id, mStoreCard_ID);
     mFP_ID:=scrReceivedInvoice_ID(mOS,mReceiptCardBOD_ID);
     if not(NxIsEmptyOID(mFP_ID)) then begin
     mReceivedInvoice:=mos.CreateObject(Class_ReceivedInvoice);
     mReceivedInvoice.Load(mFP_ID,nil);
     mFPVarSymbol:=mReceivedInvoice.GetFieldValueAsString('VarSymbol');
     end;
     mBillOfDelivery_ID:=CreateDLR(mOS,mReceiptCard_ID,mFirmDelivery_ID,mFPVarSymbol,NxLeft(mMemo,100));
     if not(NxIsEmptyOID(mBillOfDelivery_ID)) then begin
     Try
      mRelation := mOS.CreateObject('01ZXNDSYDVD135SA02K2CQM5AW');
      mRelation.New;
      mRelation.SetFieldValueAsString('LEFTSIDE_ID', mActivity_OID);
      mRelation.SetFieldValueAsString('RIGHTSIDE_ID', mBillOfDelivery_ID);
      mRelation.SetFieldValueAsInteger('REL_DEF', 1238);
      mRelation.Save;
      mRelation.free;
     Except
      NxshowSimpleMessage(ExceptionMessage,msite);
     end;
     if NxMessageBox('Dotaz', 'Založil jsem dodací list k reklamaci '+mActivityNumber+'. Chcete jej vytisknout?', mdConfirm, mdbYesNo, 0, 0, False, msite)=mrYes then begin
     if not(NxIsEmptyOID(mBillOfDelivery_ID)) then begin
        mStringList:=TStringList.Create;
        mStringList.Add(mBillOfDelivery_ID);
        CFxReportManager.PrintByIDs(msite.SiteContext,mStringList,'05DOXDMCSZDL3FUD00C5OG4NF4','1A50000101',rtoPreview,pekPDF,'','');
     end;
    end;
    end;
    end;
     end;
    if NxMessageBox('Dotaz', 'Založil jsem reklamaci '+mActivityNumber+'. Chcete ji vytisknout?', mdConfirm, mdbYesNo, 0, 0, False, msite)=mrYes then begin
     if not(NxIsEmptyOID(mActivity_OID)) then begin
        mStringList:=TStringList.Create;
        mStringList.Add(mActivity_OID);
        CFxReportManager.PrintByIDs(msite.SiteContext,mStringList,'YAQO3JZE02Y4L1PJGSXVJE41A4','1T40000101',rtoPreview,pekPDF,'','');
     end;
    end;

    
    
    
    finally
    RefreshDataset(TDBGrid(NxFindChildControl(TWinControl(NxFindChildControl(mSite.GetSiteAppForm, 'pnList')), 'grdList')));
    end;
 
 
end;








Function ReclamationData(asite:tsiteform;var aFirm_id:string;var aPerson_id:string; var aStoreCard_ID:string; var aMemo:String;
                        var aAddDescription: string; var aDocuments:string;var AOdpovednaOsoba:String; var aDialog:Boolean; var aQuantity:Extended;
                        var aZpusob:String; var aZpusobDescription:String; var aFirmDelivery_ID:string):boolean;

 var mForm : TForm;
    mCbStoreCard, mCbFirmDelivery, mCbFirm, mCbPerson, mCbUser: TRollComboEdit;
    mCbCcStoreCard, mCbCcFirmDelivery, mCbCcFirm, mCbCcPerson, mCbCcUser: TLabel;
    mLabel3 : TLabel;
    mEd1, mEd2, mEd3, mEd4,mEd5, mEd8, med9 : TEdit;
    mEd6, mEd7, mEd10: TMemo;
    mNumEdit: TNumEdit;
    mButOk, mButCancel : TButton;
    mResult : integer;
    cbZpusob:TComboBox;
    mList:TStringList;
begin
    mlist:=TStringList.Create;
    mlist.Add('oprava zboží');
    mlist.Add('výměna zboží');
    mlist.Add('vrácení peněz');
    mlist.Add('jiné');
    
    
    
    mForm:= TForm.Create(asite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Width:= 520;
    mForm.Height:= 590;
    mForm.Caption := 'Zadejte údaje pro reklamaci';
    mForm.Position := poScreenCenter;

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Firma:';
    mLabel3.Top := 17;
    mLabel3.Left := 17;
    mLabel3.Height := 13;

    mCbCcFirm:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCcFirm.Parent:= mForm;
    //mCbCcFirm.BevelOuter:= bvLowered;
    mCbCcFirm.Left:= 228;
    mCbCcFirm.Top:= 15;
    mCbCcFirm.Width:= 255;

    mCbFirm:= TRollComboEdit.Create(mForm);
    mCbFirm.Parent:= mForm;

    mCbFirm.ClassID:= 'O3OWQQYWYJCL3J0B01K0LEIOE0';
    mCbFirm.Complete:= True;
    mCbFirm.ForcedField:= True;
    mCbFirm.Prefilling:= pmNone;
    mCbFirm.TextField:= 'Name';  // položka podle které se bude vyhledávat
    mCbFirm.Top:= 15;
    mCbFirm.Left:= 107;
    mCbFirm.Width:= 108;
    mCbFirm.ConnectedControl:= mCbCcFirm;
    mCbFirm.ConnectedControlField:= 'Name';  //položka která bude zobrazena v containeru

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Osoba:';
    mLabel3.Top := 37;
    mLabel3.Left := 17;
    mLabel3.Height := 13;

    mCbCcPerson:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCcPerson.Parent:= mForm;
    //mCbCcPerson.BevelOuter:= bvLowered;
    mCbCcPerson.Left:= 228;
    mCbCcPerson.Top:= 35;
    mCbCcPerson.Width:= 255;

    mCbPerson:= TRollComboEdit.Create(mForm);
    mCbPerson.Parent:= mForm;

    mCbPerson.ClassID:= 'K1MQ4TFKGJD13E3C01K0LEIOE0';
    mCbPerson.Complete:= True;
    mCbPerson.ForcedField:= True;
    mCbPerson.Prefilling:= pmNone;
    mCbPerson.TextField:= 'LastName';  // položka podle které se bude vyhledávat
    mCbPerson.Top:= 35;
    mCbPerson.Left:= 107;
    mCbPerson.Width:= 108;
    mCbPerson.ConnectedControl:= mCbCcPerson;
    mCbPerson.ConnectedControlField:= 'LastAndFirstName';  //položka která bude zobrazena v containeru

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Skl. karta:';
    mLabel3.Top := 57;
    mLabel3.Left := 17;
    mLabel3.Height := 13;

    mCbCcStoreCard:= TLabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCcStoreCard.Parent:= mForm;
    //mCbCcStoreCard.BevelOuter:= bvLowered;
    mCbCcStoreCard.Left:= 228;
    mCbCcStoreCard.Top:= 55;
    mCbCcStoreCard.Width:= 255;

    mCbStoreCard:= TRollComboEdit.Create(mForm);
    mCbStoreCard.Parent:= mForm;

    mCbStoreCard.ClassID:= 'S3WZQKDB5FDL342M01C0CX3FCC';
    mCbStoreCard.Complete:= True;
    mCbStoreCard.ForcedField:= True;
    mCbStoreCard.Prefilling:= pmNone;
    mCbStoreCard.TextField:= 'Code';  // položka podle které se bude vyhledávat
    mCbStoreCard.Top:= 55;
    mCbStoreCard.Left:= 107;
    mCbStoreCard.Width:= 108;
    mCbStoreCard.ConnectedControl:= mCbCcStoreCard;
    mCbStoreCard.ConnectedControlField:= 'Name';  //položka která bude zobrazena v containeru

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Množství:';
    mLabel3.Top := 79;
    mLabel3.Left := 17;
    mLabel3.Height := 13;
    
    mNumEdit:= TNumEdit.Create(mForm);
    mNumEdit.Parent :=mForm;
    mNumEdit.left := 107;
    mNumEdit.top := 79;
    mNumEdit.Value := aQuantity;


    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Popis:';
    mLabel3.Top := 99;
    mLabel3.Left := 17;
    mLabel3.Height := 13;

    mEd6 := TMemo.Create(mForm);
    mEd6.Left := 107;
    mEd6.Top := 99;
    mEd6.Width := 380;
    med6.Height:= 220;
    mEd6.Text := '';
    mEd6.Parent := mForm;

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Doklady';
    mLabel3.Top := 345;
    mLabel3.Left := 17;

    mEd8 := TEdit.Create(mForm);
    mEd8.Left := 107;
    mEd8.Top := 345;
    mEd8.Width := 380;
    mEd8.Text := '';
    mEd8.Parent := mForm;

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Odp. osoba:';
    mLabel3.Top := 380;
    mLabel3.Left := 17;
    mLabel3.Height := 13;

    mCbCcUser:= Tlabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCcUser.Parent:= mForm;
    //mCbCcUser.BevelOuter:= bvLowered;
    mCbCcUser.Left:= 228;
    mCbCcUser.Top:= 380;
    mCbCcUser.Width:= 255;

    mCbUser:= TRollComboEdit.Create(mForm);
    mCbUser.Parent:= mForm;

    mCbUser.ClassID:= 'G1W2A2CBNNDL3DZ403KIU0CLP4';
    mCbUser.Complete:= True;
    mCbUser.ForcedField:= True;
    mCbUser.Prefilling:= pmNone;
    mCbUser.TextField:= 'Name';  // položka podle které se bude vyhledávat
    mCbUser.Top:= 380;
    mCbUser.Left:= 107;
    mCbUser.Width:= 108;
    mCbUser.ConnectedControl:= mCbCcUser;
    mCbUser.ConnectedControlField:= 'Name';  //položka která bude zobrazena v containeru
    
    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Způs. reklamace:';
    mLabel3.Top := 408;
    mLabel3.Left := 17;
    mLabel3.Height := 13;
    
    cbZpusob := TComboBox.Create(mForm);
    cbZpusob.Left := 107;
    cbZpusob.Top := 404;
    cbZpusob.Width := 250;
    cbZpusob.Text := '';
    mForm.InsertControl(cbZpusob);
    cbZpusob.Items:=mlist;
    if cbZpusob.Items.Count >= 0 then begin
       cbZpusob.ItemIndex := 0;
    end;
    
    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Jiný z. rekl.:';
    mLabel3.Top := 433;
    mLabel3.Left := 17;
    mLabel3.Height := 13;

    mEd10 := TMemo.Create(mForm);
    mEd10.Left := 107;
    mEd10.Top := 433;
    mEd10.Width := 380;
    mEd10.Height:= 50;
    mEd10.Text := '';
    mEd10.Parent := mForm;
    
    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Dodavatel:';
    mLabel3.Top := 498;
    mLabel3.Left := 17;
    mLabel3.Height := 13;

    mCbCcFirmDelivery:= Tlabel.Create(mForm);  //Vytvoŕení containeru pro zobrazení výběru
    mCbCcFirmDelivery.Parent:= mForm;
    //mCbCcFirmDelivery.BevelOuter:= bvLowered;
    mCbCcFirmDelivery.Left:= 228;
    mCbCcFirmDelivery.Top:= 496;
    mCbCcFirmDelivery.Width:= 255;

    mCbFirmDelivery:= TRollComboEdit.Create(mForm);
    mCbFirmDelivery.Parent:= mForm;

    mCbFirmDelivery.ClassID:= 'O3OWQQYWYJCL3J0B01K0LEIOE0';
    mCbFirmDelivery.Complete:= True;
    mCbFirmDelivery.ForcedField:= True;
    mCbFirmDelivery.Prefilling:= pmNone;
    mCbFirmDelivery.TextField:= 'Name';  // položka podle které se bude vyhledávat
    mCbFirmDelivery.Top:= 496;
    mCbFirmDelivery.Left:= 107;
    mCbFirmDelivery.Width:= 108;
    mCbFirmDelivery.ConnectedControl:= mCbCcFirmDelivery;
    mCbFirmDelivery.ConnectedControlField:= 'Name';  //položka která bude zobrazena v containeru

    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'Ok';
    mButOk.Top := 520;
    mButOk.Left := 252;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Cancel';
    mButCancel.Top := 520;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;


    mResult := mForm.ShowModal(asite);
   // if mButCancel.OnC
    if mResult = 1 then begin
        aFirm_id:= mCbFirm.DataText;
        aFirmDelivery_ID:=mCbFirmDelivery.DataText;
        aPerson_id:= mCbPerson.DataText;
        if not(NxIsEmptyOID(mCbStoreCard.DataText)) then aStoreCard_ID:= mCbStoreCard.DataText;
        aMemo:=mEd6.Text;
        aDocuments:=mEd8.Text;
        aAddDescription:=med7.Text;
        aQuantity:= mNumEdit.Value;
        adialog:=true;
        AOdpovednaOsoba:=mCbUser.DataText;
        aZpusob:=cbZpusob.Text;
        aZpusobDescription:=med10.Text;
        end;
    if mResult=2 then aDialog:=False;

    //ShowMessage(mCb.DataText);
    //Result := mCb.DataText;
    mForm.free;

end;

function CreateDLR(AOS:  TNxCustomObjectSpace; AHeader:string; AFirm_ID:String; ADescription:String; aPoznamka:string): string;
var
  mImportMan: TNxDocumentImportManager;
  mOS: TNxCustomObjectSpace;
  mInputParams: TNxParameters;
  mParam: TNxParameter;
  mCollRows: TNxCustomBusinessMonikerCollection;
  i: integer;
  mList: TStringList;
  mRow: TNxCustomBusinessObject;
  mReceiptCard:TNxCustomBusinessObject;
begin
  mOS := AOS;
  try
    mInputParams := TNxParameters.Create;
    mList := TStringList.Create;
    try
      mReceiptCard:=mOS.CreateObject('E03ZNUMDTCC4PDAUIEY1MBTJC0');
      mReceiptCard.Load(AHeader,nil);
      //ShowMessage(mReceiptCard.DisplayName);
      mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
      mParam.AsString := '1X10000101';
      mParam := mInputParams.GetOrCreateParam(dtString, 'Firm_ID');
      mParam.AsString := AFirm_ID;

      mImportMan := NxCreateDocumentImportManager(mOS, Class_ReceiptCard, Class_BillOfDelivery);
      try
        mImportMan.AddInputDocument(AHeader);
        mImportMan.LoadParams(mInputParams);
        mImportMan.Execute;
        mImportMan.CheckOutputDocument;
        if Assigned(mImportMan.OutputDocument) then begin
          mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', '1X10000101'); // musi byt...
          mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID', AFirm_ID);
          mImportMan.OutputDocument.SetFieldValueAsString('Description',ADescription);
          mImportMan.OutputDocument.SetFieldValueAsString('U_poznamka',aPoznamka);
          //mImportMan.OutputDocument.SetFieldValueAsBoolean('Finished',True);
          mImportMan.OutputDocument.Save;
          Result:=mImportMan.OutputDocument.OID;
        end;
      finally
        mImportMan.Free;
      end;
    finally
      mInputParams.Free;
      mList.Free;
    end;
  except
    // Roberte - chybu poziram - event se vola opakovane, pri opakovanem volani managera na OP, ktera jiz ma DL vytvoren, manager generuje vyjimku
    //ShowMessage('Chyba DL z OP: ' + ExceptionMessage);
  end;
end;

function scrReceivedInvoice_ID(AOS : TNxCustomObjectSpace; AActivity_ID : string) : String;
const
  cSQL = 'SELECT LeftSide_ID  FROM Relations WHERE rel_def=1011 and RightSide_ID=''%s''';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [AActivity_ID]), mList);
    if mList.Count > 0 then
      Result := (mList.Strings[0]);
  finally
    mList.Free;
  end;
end;

function scrGetReceiptcard_ID(AOS : TNxCustomObjectSpace; AFirm_ID : string; AOldFirm_ID : string; aStoreCard_ID : string) : String;
const
  cSQL = 'SELECT SD.ID  FROM StoreDocuments sd left join storedocuments2 sd2 on sd2.parent_id=sd.id WHERE sd.documenttype=''20'' and (sd.Firm_ID=''%s'' or sd.firm_id=''%s'') and sd2.StoreCard_ID=''%s'' order by sd.docdate$date desc';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [Afirm_ID,AOldFirm_ID, aStoreCard_ID]), mList);
    if mList.Count > 0 then
      Result := (mList.Strings[0]);
  finally
    mList.Free;
  end;
end;

function scrGetOldFirm_ID(AOS : TNxCustomObjectSpace; AFirm_ID : string) : String;
const
  cSQL = 'SELECT ID  FROM Firms WHERE Firm_ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [Afirm_ID]), mList);
    if mList.Count > 0 then
      Result := (mList.Strings[0]);
  finally
    mList.Free;
  end;
end;

begin
end.