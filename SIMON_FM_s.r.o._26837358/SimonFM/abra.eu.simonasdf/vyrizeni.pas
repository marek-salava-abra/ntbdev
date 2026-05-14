uses 'abra.eu.simonasdf.zalohy';

procedure CreateDeposit(Sender: TObject; Index: integer);
Var
 mActivity, mFirm:TNxCustomBusinessObject;
 mZalohaPPZ_ID, mZalohaFV_ID:String;
 msite: TSiteForm;
 mOS: TNxCustomObjectSpace;
 mZalohaFloat:Extended;
 mPPZBO, mFVBO:TNxCustomBusinessObject;
 mlist: TStringList;
 
 

begin
    mSite :=TComponent(Sender).DynSite;
    mOs:=msite.CompanyObjectSpace;
    mActivity:=TDynSiteForm(mSite).CurrentObject;
    mFirm:=mOS.CreateObject(Class_Firm);
    mlist:=TStringList.Create;
    if NxMessageBox('Dotaz', 'Přejete si vytvořit zálohu k dokladu '+mActivity.DisplayName+' pro firmu '+mActivity.GetFieldValueAsString('Firm_ID.name')+'?', mdConfirm, mdbYesNo, 0, 0, False, msite)=mrYes then begin
    if not(NxIsEmptyOID(mActivity.GetFieldValueAsString('U_ServiceFirm_ID'))) then begin
    mfirm.Load(mActivity.GetFieldValueAsString('U_ServiceFirm_ID'),nil);
    mZalohaFloat:=mfirm.GetFieldValueAsFloat('U_zaloha_oprava');
    if not(mZalohaFloat>0) then begin
      NxShowMessage('Info','Záloha na firmě '+mfirm.GetFieldValueAsString('Name')+' není nastavena', mdWarning,false,msite);
       exit;

    end;
    if mActivity.GetFieldValueAsFloat('U_zaloha')>0 then begin
      NxShowMessage('Info','Záloha již byla vytvořena', mdWarning,false,msite);
       exit;
    end;
    
      if Index=0 then begin
        mZalohaPPZ_ID:= CreateDepositPPZ(mos, mActivity.GetFieldValueAsString('Firm_ID'), mActivity.GetFieldValueAsString('Person_ID'),'Záloha '+mActivity.DisplayName,mZalohaFloat,mActivity.DisplayName,mActivity.OID, mActivity.GetFieldValueAsString('Division_ID'));
        if not(NxIsEmptyOID(mZalohaPPZ_ID)) then begin
          mPPZBO:=mOS.CreateObject(Class_CashReceived);
          mPPZBO.Load(mZalohaPPZ_ID,nil);
          mActivity.SetFieldValueAsString('U_doklad',mPPZBO.DisplayName);
          mActivity.SetFieldValueAsFloat('U_zaloha',mZalohaFloat);
          mActivity.Save;
        end;
         mlist.Add(mPPZBO.OID);
         if NxMessageBox('Dotaz', 'Založil jsem pokladní příjem '+mPPZBO.DisplayName+'. Chcete ho vytisknout?', mdConfirm, mdbYesNo, 0, 0, False, msite)=mrYes then
          CFxReportManager.PrintByIDs(msite.SiteContext,mList,'0Z4R1NY0FJDL3BLX00C5OG4NF4','3000000101',rtoPreview,pekPDF,'','');
      end;
      if Index=1 then begin
      mZalohaFV_ID:= CreateDepositFV(mos, mActivity.GetFieldValueAsString('Firm_ID'), mActivity.GetFieldValueAsString('Person_ID'),'Záloha '+mActivity.DisplayName,mZalohaFloat,mActivity.DisplayName,mActivity.OID, mActivity.GetFieldValueAsString('Division_ID'));
        if not(NxIsEmptyOID(mZalohaFV_ID)) then begin
          mFVBO:=mOS.CreateObject(Class_IssuedInvoice);
          mFVBO.Load(mZalohaFV_ID,nil);
          mActivity.SetFieldValueAsString('U_doklad',mFVBO.DisplayName);
          mActivity.SetFieldValueAsFloat('U_zaloha',mZalohaFloat);
          mActivity.Save;
        end;
         mlist.Add(mFVBO.OID);
         if NxMessageBox('Dotaz', 'Založil jsem fakturu '+mPPZBO.DisplayName+'. Chcete ji vytisknout?', mdConfirm, mdbYesNo, 0, 0, False, mSite)=mrYes then
          CFxReportManager.PrintByIDs(msite.SiteContext,mList,'40SBPEINEFD13ACM03KIU0CLP4','5200000101',rtoPreview,pekPDF,'','');
      end;
    end;
    end;
end;



procedure MultiAkceExecuteItem2(Sender: TObject; Index: integer);
var
  mReceiptCard_ID, mCashReceived_ID, mBillOfDelivery_ID, mIssuedInvoice_ID, mFirma_ID: String;
  msite: TSiteForm;
  mActivity, mRelation, mReceiptCard, mCashReceived, mBillOfDelivery, mIssuedInvoice: TNxCustomBusinessObject;
  mOS: TNxCustomObjectSpace;
  mStringList:TstringList;
  mPrice, mQuantity: Extended;
  mText, mPoznamka: String;
  mOpGarance, mCastOPGarance, mPlacOprava,mInfoZak,mInfoVO,mNerent, mDialog: Boolean;
begin
  mSite := TComponent(Sender).DynSite;
    mOs:=msite.CompanyObjectSpace;
    mActivity:=TDynSiteForm(mSite).CurrentObject;
    mReceiptCard_ID:=scrReceiptcard_ID(mOS,mActivity.GetFieldValueAsString('ID'));
    mPrice:= scrGetStoreCardPrice_ID(mOS,mActivity.GetFieldValueAsString('U_ServicedStoreCard_ID'));
    if NxIsEmptyOID(mReceiptCard_ID) then begin
        showmessage('Aktivita '+mActivity.DisplayName+' nemá připojen doklad PRS. Nelze vyřídit.');
        exit;
    end;
    mFirma_ID:=mActivity.GetFieldValueAsString('Firm_ID');
    if NxIsEmptyOID(mFirma_ID) then mFirma_ID:='AAA1000000';
    mReceiptCard:=mOS.CreateObject('E03ZNUMDTCC4PDAUIEY1MBTJC0');
    mReceiptCard.Load(mReceiptCard_ID,nil);
    mQuantity:=0;
    mQuantity:=srcGetQuantity(mos,mActivity.GetFieldValueAsString('U_ServicedStoreCard_ID'));
    if mQuantity=0 then begin
        NxShowMessage('Info','Nemám na skladě žádné množství, nemohu pokračovat ve vyřízení dokladu.', mdWarning,false,msite);
       exit;
    end;

    
      if Index=0 then begin
            if mPrice=0 then begin
             NxShowMessage('Info','Nemám cenu v ceníku, nemohu pokračovat ve vyřízení dokladu.', mdWarning,false,msite);
            exit;
            end;
            mText:= 'Aktivita '+mActivity.DisplayName+' má k sobě příjemku '+mReceiptCard.DisplayName+'. Cena v ceníku s DPH je '+FloatToStr(mPrice*1.21)+'. Chcete založit doklad PPZ?';
            AddServiceData2(msite,mText, mPoznamka, mOpGarance, mCastOPGarance, mPlacOprava,mInfoZak,mInfoVO,mNerent, mDialog);
            if not(mDialog) then begin
            if NxMessageBox('Info', 'Ruším založení PPZ.', mdConfirm, mdbOk, 0, 0, False, msite)=mrOk then
            exit;
          end;
        if mdialog then begin
            //ShowMessage('Tvorim PPZ '+mReceiptCard_ID);
            mCashReceived_ID:= CreatePPZ(mOS,mReceiptCard_ID, mFirma_ID, mActivity.DisplayName,mActivity.GetFieldValueAsFloat('U_zaloha'),mActivity.GetFieldValueAsString('U_doklad'));
            //ShowMessage('vytvoreno '+mCashReceived_ID);
            mRelation := mOS.CreateObject('01ZXNDSYDVD135SA02K2CQM5AW');
            mRelation.New;
            mRelation.SetFieldValueAsString('LEFTSIDE_ID', mActivity.OID);
            mRelation.SetFieldValueAsString('RIGHTSIDE_ID', mCashReceived_ID);
            mRelation.SetFieldValueAsInteger('REL_DEF', 1213);
            mRelation.Save;
            mRelation.free;
            mCashReceived:=mOS.CreateObject('WG02MSU3BBDL3ACR03KIU0CLP4');
            mCashReceived.Load(mCashReceived_ID,nil);
            if NxMessageBox('Dotaz', 'Založil jsem '+mCashReceived.DisplayName+'. Chcete jej vytisknout?', mdConfirm, mdbYesNo, 0, 0, False, msite)=mrYes then begin
                mStringList:=TStringList.Create;
                mStringList.Add(mCashReceived.oid);

                CFxReportManager.PrintByIDs(msite.SiteContext,mStringList,'0Z4R1NY0FJDL3BLX00C5OG4NF4','3000000101',rtoPreview,pekPDF,'','');
            end;

            
        end;
        if mActivity.GetFieldValueAsDateTime('U_privezeno')<100 then mActivity.SetFieldValueAsDateTime('U_privezeno',now);
        mActivity.SetFieldValueAsInteger('Status',2);
        mActivity.SetFieldValueAsBoolean('U_oprava_v_garanci',mOpGarance);
        mActivity.SetFieldValueAsBoolean('U_placena_oprava',mPlacOprava);
        mActivity.SetFieldValueAsBoolean('U_info_zakaznik',mInfoZak);
        mActivity.SetFieldValueAsBoolean('U_info_VO',mInfoVO);
        mActivity.SetFieldValueAsBoolean('U_cast_garance',mCastOPGarance);
        mActivity.SetFieldValueAsBoolean('U_nerent_oprava',mNerent);
        mActivity.SetFieldValueAsString('U_ServiceStatus_ID','2B50000101');
        mActivity.save;
        mActivity.free;
      end;
      if Index=1 then begin
        mText:= 'Aktivita '+mActivity.DisplayName+' má k sobě příjemku '+mReceiptCard.DisplayName+'. Chcete založit doklad DLSE?';
            AddServiceData2(msite, mText, mPoznamka, mOpGarance, mCastOPGarance, mPlacOprava, mInfoZak, mInfoVO, mNerent, mDialog);
            if not(mDialog) then begin
             NxShowMessage('Info','Ruším založení DLSE.', mdWarning,false,msite);
            exit;
          end;
        if mDialog then begin


            mBillOfDelivery_ID:= CreateDLSE(mOS,mReceiptCard_ID,mFirma_ID, mActivity.DisplayName, mPoznamka);

            mRelation := mOS.CreateObject('01ZXNDSYDVD135SA02K2CQM5AW');
            mRelation.New;
            mRelation.SetFieldValueAsString('LEFTSIDE_ID', mActivity.OID);
            mRelation.SetFieldValueAsString('RIGHTSIDE_ID', mBillOfDelivery_ID);
            mRelation.SetFieldValueAsInteger('REL_DEF', 1238);
            mRelation.Save;
            mRelation.free;
            mBillOfDelivery:=mOS.CreateObject('050I5SAOS3DL3ACU03KIU0CLP4');
            mBillOfDelivery.Load(mBillOfDelivery_ID,nil);
            if NxMessageBox('Dotaz', 'Založil jsem '+mBillOfDelivery.DisplayName+'. Chcete jej vytisknout?', mdConfirm, mdbYesNo, 0, 0, False, msite)=mrYes then begin
                mStringList:=TStringList.Create;
                mStringList.Add(mBillOfDelivery.oid);

                CFxReportManager.PrintByIDs(msite.SiteContext,mStringList,'05DOXDMCSZDL3FUD00C5OG4NF4','8000000101',rtoPreview,pekPDF,'','');
            end;
        end;
        if mActivity.GetFieldValueAsDateTime('U_privezeno')<100 then mActivity.SetFieldValueAsDateTime('U_privezeno',now);
        mActivity.SetFieldValueAsInteger('Status',2);
        mActivity.SetFieldValueAsBoolean('U_oprava_v_garanci',mOpGarance);
        mActivity.SetFieldValueAsBoolean('U_placena_oprava',mPlacOprava);
        mActivity.SetFieldValueAsBoolean('U_info_zakaznik',mInfoZak);
        mActivity.SetFieldValueAsBoolean('U_info_VO',mInfoVO);
        mActivity.SetFieldValueAsBoolean('U_cast_garance',mCastOPGarance);
        mActivity.SetFieldValueAsBoolean('U_nerent_oprava',mNerent);
        mActivity.SetFieldValueAsString('U_ServiceStatus_ID','2B50000101');
        mActivity.save;
        mActivity.free;
      end;
     if Index=2 then begin
            if mPrice=0 then begin
              if NxMessageBox('Info', 'Nemám cenu v ceníku, nemohu pokračovat ve vyřízení dokladu.', mdConfirm, mdbOk, 0, 0, False, msite)=mrOk then
            exit;
            end;
        mText:= 'Aktivita '+mActivity.DisplayName+' má k sobě příjemku '+mReceiptCard.DisplayName+'. Chcete založit doklad FV02?';
            AddServiceData2(msite,mText, mPoznamka, mOpGarance, mCastOPGarance, mPlacOprava,mInfoZak,mInfoVO,mNerent, mDialog);
            if not(mDialog) then begin
            NxShowMessage('Info','Ruším založení FV02.', mdWarning,false,msite);
            exit;
          end;
        if mdialog then begin

            mIssuedInvoice_ID:= CreateFV02(mOS,mReceiptCard_ID,mFirma_ID, mActivity.DisplayName,mActivity.GetFieldValueAsFloat('U_zaloha'),mActivity.GetFieldValueAsString('U_doklad'));

            mRelation := mOS.CreateObject('01ZXNDSYDVD135SA02K2CQM5AW');
            mRelation.New;
            mRelation.SetFieldValueAsString('LEFTSIDE_ID', mActivity.OID);
            mRelation.SetFieldValueAsString('RIGHTSIDE_ID', mIssuedInvoice_ID);
            mRelation.SetFieldValueAsInteger('REL_DEF', 1200);
            mRelation.Save;
            mRelation.free;
            mIssuedInvoice:=mOS.CreateObject('O3BDOKTWEFD13ACM03KIU0CLP4');
            mIssuedInvoice.Load(mIssuedInvoice_ID,nil);
            if NxMessageBox('Dotaz', 'Založil jsem '+mIssuedInvoice.DisplayName+'. Chcete ji vytisknout?', mdConfirm, mdbYesNo, 0, 0, False, msite)=mrYes then begin
                mStringList:=TStringList.Create;
                mStringList.Add(mIssuedInvoice.oid);

                CFxReportManager.PrintByIDs(msite.SiteContext,mStringList,'40SBPEINEFD13ACM03KIU0CLP4','5200000101',rtoPreview,pekPDF,'','');
            end;
        end;
        if mActivity.GetFieldValueAsDateTime('U_privezeno')<100 then mActivity.SetFieldValueAsDateTime('U_privezeno',now);
        mActivity.SetFieldValueAsInteger('Status',2);
        mActivity.SetFieldValueAsBoolean('U_oprava_v_garanci',mOpGarance);
        mActivity.SetFieldValueAsBoolean('U_placena_oprava',mPlacOprava);
        mActivity.SetFieldValueAsBoolean('U_info_zakaznik',mInfoZak);
        mActivity.SetFieldValueAsBoolean('U_info_VO',mInfoVO);
        mActivity.SetFieldValueAsBoolean('U_cast_garance',mCastOPGarance);
        mActivity.SetFieldValueAsBoolean('U_nerent_oprava',mNerent);
        mActivity.SetFieldValueAsString('U_ServiceStatus_ID','2B50000101');
        mActivity.save;
        mActivity.free;
      end;
  
end;

function CreatePPZ(AOS:  TNxCustomObjectSpace; AHeader:string; AFirm_ID:String; ADescription:String; aAmount:Double; aDocument:string): string;
var
  mImportMan: TNxDocumentImportManager;
  mOS: TNxCustomObjectSpace;
  mInputParams: TNxParameters;
  mParam: TNxParameter;
  mCollRows, mPPZRows: TNxCustomBusinessMonikerCollection;
  i: integer;
  mList: TStringList;
  mRow: TNxCustomBusinessObject;
  mReceiptCard:TNxCustomBusinessObject;
  mCashReceived, mCashReceivedRows: TNxCustomBusinessObject;
  mCashReceived_ID:String;
begin
  mOS := AOS;
  try
    mInputParams := TNxParameters.Create;
    mList := TStringList.Create;
    try
      mReceiptCard:=mOS.CreateObject('E03ZNUMDTCC4PDAUIEY1MBTJC0');
      mReceiptCard.Load(AHeader,nil);
      mCollRows := mReceiptCard.GetLoadedCollectionMonikerForFieldCode(mReceiptCard.GetFieldCode('Rows'));
      for i := 0 to mCollRows.Count - 1 do begin
        mRow := mCollRows.BusinessObject(i);
        if mRow.GetFieldValueAsInteger('RowType') = 3 then begin
          if (not (osDeleted in mRow.State)) and (not (osMarkForDelete in mRow.State)) then begin

            mList.Add(mRow.OID);
          end;
        end;
      end;
      mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
      mParam.AsString := '7100000101';
      mParam := mInputParams.GetOrCreateParam(dtString, 'CashDesk_ID');
      mParam.AsString := '1000000101';
      mParam := mInputParams.GetOrCreateParam(dtString, 'StoreDocQueue_ID');
      mParam.AsString := '2I10000101';
      mParam := mInputParams.GetOrCreateParam(dtString, 'Firm_ID');
      mParam.AsString := AFirm_ID;
      mImportMan := NxCreateDocumentImportManager(mOS, Class_ReceiptCard, Class_CashReceived);
      try
        mImportMan.AddInputDocument(AHeader);
        mImportMan.LoadParams(mInputParams);
        mImportMan.Execute;
        mImportMan.CheckOutputDocument;
        if Assigned(mImportMan.OutputDocument) then begin
          mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', '7100000101'); // musi byt...
          mImportMan.OutputDocument.SetFieldValueAsString('CashDesk_ID', '1000000101');
          mImportMan.OutputDocument.SetFieldValueAsString('StoreDocQueue_ID','2I10000101');
          mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID', AFirm_ID);
          mImportMan.OutputDocument.SetFieldValueAsString('Description',ADescription);

          mImportMan.OutputDocument.Save;
          mCashReceived_ID:=mImportMan.OutputDocument.OID;
          Result:=mImportMan.OutputDocument.OID;
        end;
      finally
        mImportMan.Free;
      end;
      if aAmount>0 then begin
         mCashReceived:= mos.CreateObject(Class_CashReceived);
         mCashReceived.load(mCashReceived_ID,nil);
         //ShowMessage(mCashReceived.DisplayName);
         mPPZRows:= mCashReceived.GetLoadedCollectionMonikerForFieldCode(mCashReceived.GetFieldCode('Rows'));
         mCashReceivedRows:=mPPZRows.AddNewObject;
         mCashReceivedRows.SetFieldValueAsInteger('RowType',1);
         mCashReceivedRows.SetFieldValueAsString('Text', 'Odúčtování manipulačního poplatku z dokladu '+aDocument);
         mCashReceivedRows.SetFieldValueAsFloat('TotalPrice', -aAmount);

         mCashReceivedRows.SetFieldValueAsString('VatRate_ID','02100X0000');
         mCashReceivedRows.SetFieldValueAsString('Division_ID','5100000101');
         mCashReceivedRows.SetFieldValueAsString('BusTransaction_ID','1000000101');
         mCashReceivedRows.SetFieldValueAsString('IncomeType_ID','1300000101');
         mCashReceived.save;
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

function CreateFV02(AOS:  TNxCustomObjectSpace; AHeader:string; AFirm_ID:String; ADescription:String; aAmount:Double; aDocument:string): string;
var
  mImportMan: TNxDocumentImportManager;
  mOS: TNxCustomObjectSpace;
  mInputParams: TNxParameters;
  mParam: TNxParameter;
  mCollRows, mIIRows: TNxCustomBusinessMonikerCollection;
  i: integer;
  mList: TStringList;
  mRow: TNxCustomBusinessObject;
  mReceiptCard:TNxCustomBusinessObject;
  mIssuedinvoice,mIssuedinvoiceRows: TNxCustomBusinessObject;
  mIssuedinvoice_ID:String;
begin
  mOS := AOS;
  try
    mInputParams := TNxParameters.Create;
    mList := TStringList.Create;
    try
      mReceiptCard:=mOS.CreateObject('E03ZNUMDTCC4PDAUIEY1MBTJC0');
      mReceiptCard.Load(AHeader,nil);
      mCollRows := mReceiptCard.GetLoadedCollectionMonikerForFieldCode(mReceiptCard.GetFieldCode('Rows'));
      for i := 0 to mCollRows.Count - 1 do begin
        mRow := mCollRows.BusinessObject(i);
        if mRow.GetFieldValueAsInteger('RowType') = 3 then begin
          if (not (osDeleted in mRow.State)) and (not (osMarkForDelete in mRow.State)) then begin

            mList.Add(mRow.OID);
          end;
        end;
      end;
      mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
      mParam.AsString := 'I100000101';
      mParam := mInputParams.GetOrCreateParam(dtString, 'BankAccount_ID');
      mParam.AsString := '1000000101';
      mParam := mInputParams.GetOrCreateParam(dtString, 'StoreDocQueue_ID');
      mParam.AsString := '2I10000101';
      mParam := mInputParams.GetOrCreateParam(dtString, 'PaymentType_ID');
      mParam.AsString := '6000000101';
      mParam := mInputParams.GetOrCreateParam(dtString, 'Firm_ID');
      mParam.AsString := AFirm_ID;
      mImportMan := NxCreateDocumentImportManager(mOS, Class_ReceiptCard, Class_IssuedInvoice);
      try
        mImportMan.AddInputDocument(AHeader);
        mImportMan.LoadParams(mInputParams);
        mImportMan.Execute;
        mImportMan.CheckOutputDocument;
        if Assigned(mImportMan.OutputDocument) then begin
          mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', 'I100000101'); // musi byt...
          mImportMan.OutputDocument.SetFieldValueAsString('BankAccount_ID', '1000000101');
          mImportMan.OutputDocument.SetFieldValueAsString('StoreDocQueue_ID','2I10000101');
          mImportMan.OutputDocument.SetFieldValueAsString('PaymentType_ID','6000000101');
          mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID', AFirm_ID);
          mImportMan.OutputDocument.SetFieldValueAsString('Description',ADescription);
          mImportMan.OutputDocument.Save;
          mIssuedinvoice_ID:=mImportMan.OutputDocument.OID;
          Result:=mImportMan.OutputDocument.OID;
        end;
      finally
        mImportMan.Free;
      end;
       if aAmount>0 then begin
         mIssuedinvoice:= mos.CreateObject(Class_IssuedInvoice);
         mIssuedinvoice.load(mIssuedinvoice_ID,nil);
         //ShowMessage(mCashReceived.DisplayName);
         mIIRows:= mIssuedinvoice.GetLoadedCollectionMonikerForFieldCode(mIssuedinvoice.GetFieldCode('Rows'));
         mIssuedinvoiceRows:=mIIRows.AddNewObject;
         mIssuedinvoiceRows.SetFieldValueAsInteger('RowType',1);
         mIssuedinvoiceRows.SetFieldValueAsString('Text', 'Odúčtování manipulačního poplatku z dokladu '+aDocument);
         mIssuedinvoiceRows.SetFieldValueAsFloat('TotalPrice', -aAmount);
         mIssuedinvoiceRows.SetFieldValueAsString('VatRate_ID','02100X0000');
         mIssuedinvoiceRows.SetFieldValueAsString('Division_ID','5100000101');
         mIssuedinvoiceRows.SetFieldValueAsString('BusTransaction_ID','1000000101');
         mIssuedinvoiceRows.SetFieldValueAsString('IncomeType_ID','1300000101');
         mIssuedinvoice.save;
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



function CreateDLSE(AOS:  TNxCustomObjectSpace; AHeader:string; AFirm_ID:String; ADescription:String; aPoznamka:string): string;
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
      mParam.AsString := '2I10000101';
      mParam := mInputParams.GetOrCreateParam(dtString, 'Firm_ID');
      mParam.AsString := AFirm_ID;

      mImportMan := NxCreateDocumentImportManager(mOS, Class_ReceiptCard, Class_BillOfDelivery);
      try
        mImportMan.AddInputDocument(AHeader);
        mImportMan.LoadParams(mInputParams);
        mImportMan.Execute;
        mImportMan.CheckOutputDocument;
        if Assigned(mImportMan.OutputDocument) then begin
          mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', '2I10000101'); // musi byt...
          mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID', AFirm_ID);
          mImportMan.OutputDocument.SetFieldValueAsString('Description',ADescription);
          mImportMan.OutputDocument.SetFieldValueAsString('U_poznamka',aPoznamka);
          mImportMan.OutputDocument.SetFieldValueAsBoolean('Finished',True);
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



function scrReceiptcard_ID(AOS : TNxCustomObjectSpace; AActivity_ID : string) : String;
const
  cSQL = 'SELECT RightSide_ID  FROM Relations WHERE rel_def=1245 and LeftSide_ID=''%s''';
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


function srcGetQuantity(AOS : TNxCustomObjectSpace; AStoreCard_ID : string) : Double;
const
  cSQL = 'SELECT sum(quantity)  FROM StoreSubCards WHERE StoreCard_ID=''%s''';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    Result:=0;
    AOS.SQLSelect(Format(cSQL, [AStoreCard_ID]), mList);
    if mList.Count > 0 then
      Result := StrToFloat(mList.Strings[0]);
  finally
    mList.Free;
  end;
end;

function scrGetStoreCardPrice_ID(AOS : TNxCustomObjectSpace; AStoreCard_ID : string) : Double;
const
  cSQL = 'SELECT sp2.Amount FROM StorePrices2 SP2 LEFT JOIN StorePrices SP ON SP.ID = SP2.Parent_ID WHERE SP2.Price_ID=''%s'' AND SP.PriceList_ID=''%s'' and sp.storecard_ID=''%s'' and sp2.qunit=''%s''';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    Result:=0;
    AOS.SQLSelect(Format(cSQL, ['1000000101','1000000101',AStoreCard_ID,'ks']), mList);
    if mList.Count > 0 then
      Result := StrToFloat(mList.Strings[0]);
  finally
    mList.Free;
  end;
end;

Function AddServiceData2(var asite:tsiteform;var aText:string;var aPoznamka:string;var aOpGarance:Boolean;var aCastOPGarance:Boolean;
                         var aPlacOprava:Boolean;var aInfoZak:Boolean;var aInfoVO:Boolean;var aNerent:Boolean;var aDialog:Boolean):boolean;

 var mForm : TForm;

    mLabel3 : TLabel;
    mEd1 : TEdit;
    mBEd01, mBEd02, mBEd03, mBEd04, mBEd05,mBEd06: TCheckBox;
    mButOk, mButCancel : TButton;
    mResult : integer;
begin
  mForm:= TForm.Create(asite);  //Form mus=i být vytvářen na Site , kvuli přebráni Contextu
    mForm.Width:= 720;
    mForm.Height:= 200;
    mForm.Caption := 'Údaje pro vyřízení servisu';
    mForm.Position := poScreenCenter;

    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := aText;
    mLabel3.Top := 8;
    mLabel3.Left := 17;
    mLabel3.Height := 13;
    mLabel3.Width := 20;
    mLabel3.Font.Style := [fsBold];
    
    mLabel3 := TLabel.Create(mForm);
    mLabel3.Parent := mForm;
    mLabel3.Caption := 'Poznámka';
    mLabel3.Top := 39;
    mLabel3.Left := 17;
    mLabel3.Height := 13;

    mEd1 := TEdit.Create(mForm);
    mEd1.Left := 107;
    mEd1.Top := 37;
    mEd1.Width := 380;
    mEd1.Text := '';
    mEd1.Parent := mForm;
    
    
    mBEd01:= TCheckBox.Create(mForm);
    mBEd01.Left := 17;
    mBEd01.Top := 63;
    mBEd01.Caption := 'Opr. v garanci';
    mBEd01.Checked := False;
    mBEd01.Parent := mForm;

    mBEd02:= TCheckBox.Create(mForm);
    mBEd02.Left := 17;
    mBEd02.Top := 83;
    mBEd02.Caption := 'Část. garance';
    mBEd02.Checked := False;
    mBEd02.Parent := mForm;
    
    mBEd03:= TCheckBox.Create(mForm);
    mBEd03.Left := 157;
    mBEd03.Top := 63;
    mBEd03.Caption := 'Plac. oprava';
    mBEd03.Checked := False;
    mBEd03.Parent := mForm;

    mBEd04:= TCheckBox.Create(mForm);
    mBEd04.Left := 157;
    mBEd04.Top := 83;
    mBEd04.Caption := 'Nerent. oprava';
    mBEd04.Checked := False;
    mBEd04.Parent := mForm;
    
    mBEd05:= TCheckBox.Create(mForm);
    mBEd05.Left := 297;
    mBEd05.Top := 63;
    mBEd05.Caption := 'Info zák.';
    mBEd05.Checked := False;
    mBEd05.Parent := mForm;

    mBEd06:= TCheckBox.Create(mForm);
    mBEd06.Left := 297;
    mBEd06.Top := 83;
    mBEd06.Caption := 'Info VO';
    mBEd06.Checked := False;
    mBEd06.Parent := mForm;
    
    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'Ok';
    mButOk.Top := 129;
    mButOk.Left := 352;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Cancel';
    mButCancel.Top := 129;
    mButCancel.Left := 420;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;
    


    mResult := mForm.ShowModal(asite);
   // if mButCancel.OnC
    if mResult = 1 then begin
          aDialog:=true;
          aPoznamka:=mEd1.text;
          aOpGarance:=mBEd01.Checked;
          aCastOPGarance:=mBEd02.Checked;
          aPlacOprava:=mBEd03.Checked;
          aNerent:=mBEd04.Checked;
          aInfoZak:=mBEd05.checked;
          aInfoVO:=mBEd06.Checked;
        end;
    if mResult=2 then aDialog:=False;

    //ShowMessage(mCb.DataText);
    //Result := mCb.DataText;
    mForm.free;

end;

begin
end.