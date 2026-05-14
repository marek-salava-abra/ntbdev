uses 'eu.abra.zde.fce';

procedure CheckXML (OS: TNxCustomObjectSpace; var ProcessContinue: Boolean; Email, EmailAttachment: TNxCustomBusinessObject);
Var
 mXMLHead:TNxScriptingXMLWrapper;
 mStore_ID, mDivision_ID, mDocqueue_ID,mDocqueueOT_ID, mFileName:String;
 i:integer;
 mReceivedOder, mRORow, mOTRow, mOutgoingTransfer:TNxCustomBusinessObject;  //přidání proměnné převodka výdej mOutgoingTransfer
 mRows, mOTRows:TNxCustomBusinessMonikerCollection;
 mFile, mReceivedOrder_ID, mStoreCard_ID, mFirm_ID, mStoreCode, mFinalStore_ID:string; //mStoreCode je kód cílového skladu
 mM:TMemoryStream;
 mInputParams:TNxParameters;
 mParam:TNxParameter;
 mImportMan: TNxDocumentImportManager;
 mOTDQ_ID: String;
 mStoreCardQuantity: Extended;
begin
  ProcessContinue := True;
  // Pokud se nejedná o přílohu v CSV, tak není co dělat
  mStore_ID:='2000000101'; //001
  mDivision_ID:='L000000101'; //
  mDocqueue_ID:='D100000101';
  mDocqueueOT_ID:='N000000101';

    if Assigned(EmailAttachment) then begin
      if UpperCase(NxRight(EmailAttachment.GetFieldValueAsString('FileName'),4)) <> '.XML' then
      exit
       else begin
          mM:= TMemoryStream.Create;
              try
              // Uložím CSV soubor z přílohy emailu do složky
              mFile := EmailAttachment.GetFieldValueAsString('FileName');
              mFileName := 'c:\abra\xml\' + mFile;
              mM.SetBytes(EmailAttachment.GetFieldValueAsBytes('BlobData'));
              mM.SaveToFile(mFileName);
            finally
              mM.Free;
             end;
   end;
   mXMLHead := TNxScriptingXMLWrapper.Create;
   mXMLHead.loadFromFile(mFileName);
   mReceivedOrder_ID:=GetOrder_ID(os,'ExternalNumber',mXMLHead.getElementAsString('Cislo'));     //objednávky přijaté
   if NxIsEmptyOID(mReceivedOrder_ID) then begin
    if mXMLHead.getElementsCountInArray('polozky.polozka')>0 then begin
     mFirm_ID:=GetFirm_ID(os,Email.GetFieldValueAsString('Sender')) ;
     if not(NxIsEmptyOID(mFirm_ID)) then begin
       mReceivedOder:=os.CreateObject(Class_ReceivedOrder);
       mReceivedOder.new;
       mReceivedOder.prefill;
       mReceivedOder.SetFieldValueAsString('DocQueue_ID',mDocqueue_ID);
       mReceivedOder.SetFieldValueAsString('Firm_ID',mFirm_ID);
       mReceivedOder.SetFieldValueAsString('ExternalNumber',mXMLHead.getElementAsString('Cislo'));
       mRows:=mReceivedOder.GetLoadedCollectionMonikerForFieldCode(mReceivedOder.GetFieldCode('Rows')); //vytvoří prázdnou kolekci řádků
        for i:=0 to mXMLHead.getElementsCountInArray('polozky.polozka')-1 do begin
         mStoreCard_ID:=GetStoreCard_ID(OS,mXMLHead.getElementAsString('polozky.polozka['+IntToStr(i)+'].Ean'));
          if not(NxIsEmptyOID(mStoreCard_ID)) then begin
           mRORow:=mrows.AddNewObject;
           mRORow.SetFieldValueAsInteger('RowType',3);
           mRoRow.SetFieldValueAsString('Store_ID',mStore_ID);
           mRORow.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
           mStoreCardQuantity:=OS.SQLSelectFirstAsExtended('Select QUANTITY from STORESUBCARDS where STORECARD_ID='+QuotedStr(mStoreCard_ID)+'and STORE_ID='+QuotedStr(mStore_ID),0);
           mrorow.SetFieldValueAsFloat('Quantity', NxIBStrToFloat(mXMLHead.getElementAsString('polozky.polozka['+IntToStr(i)+'].Mnozstvi')));
           mRORow.SetFieldValueAsString('Division_ID',mDivision_ID);
          end;
        end;
       mReceivedOder.save;
       mReceivedOder.free;
    end;
    end;
   end;
   mStoreCode:=OS.SqlSelectFirstAsString('Select code from stores where X_Versaco_code='+Quotedstr(mXMLHead.GetElementAsString('ID_prodejna')),'');
   mFinalStore_ID:=OS.SqlSelectFirstAsString('Select ID from stores where X_Versaco_code='+Quotedstr(mXMLHead.GetElementAsString('ID_prodejna')),'');
   mOTDQ_ID:=OS.SqlSelectFirstAsString('Select ID from docqueues where code='+Quotedstr('P'+mStoreCode),'');
   mOutgoingTransfer:=os.CreateObject(Class_OutgoingTransfer); //převodky výdej
   mOutgoingTransfer.new;
   mOutgoingTransfer.prefill;
   mOutgoingTransfer.SetFieldValueAsString('DocQueue_ID', mDocqueueOT_ID);
   mOutgoingTransfer.SetFieldValueAsString('Firm_ID',mFirm_ID);
   mOutgoingTransfer.SetFieldValueAsString('Description',mStoreCode);
   mOTRows:=mOutgoingTransfer.GetLoadedCollectionMonikerForFieldCode(mOutgoingTransfer.GetFieldCode('Rows'));
    for i:=0 to mXMLHead.getElementsCountInArray('polozky.polozka')-1 do begin
     mStoreCard_ID:=GetStoreCard_ID(OS,mXMLHead.getElementAsString('polozky.polozka['+IntToStr(i)+'].Ean'));
     if not(NxIsEmptyOID(mStoreCard_ID)) then begin
      mStoreCardQuantity:=OS.SQLSelectFirstAsExtended('Select QUANTITY from STORESUBCARDS where STORECARD_ID='+QuotedStr(mStoreCard_ID)+'and STORE_ID='+QuotedStr(mStore_ID),0);

       if mStoreCardQuantity > 0 then
        begin
          mOTRow:= mOTrows.AddNewObject;
          mOTRow.prefill;
          mOTRow.SetFieldValueAsString('Store_ID', mStore_ID);
          mOTRow.SetFieldValueAsString('StoreCard_ID', mStoreCard_ID);
          if mStoreCardQuantity > NxIBStrToFloat(mXMLHead.getElementAsString('polozky.polozka['+IntToStr(i)+'].Mnozstvi'))  then
            mOTrow.SetFieldValueAsFloat('Quantity', NxIBStrToFloat(mXMLHead.getElementAsString('polozky.polozka['+IntToStr(i)+'].Mnozstvi')))
          else
            mOTrow.SetFieldValueAsFloat('Quantity', mStoreCardQuantity);
          mOTRow.SetFieldValueAsString('Division_ID', mDivision_ID);
        end;

     end;
    end;
    mOutgoingTransfer.Save;
         mInputParams := TNxParameters.Create;
         //mOTDQ_ID:='P000000101';
         mParam := mInputParams.GetOrCreateParam(dtstring,'DocQueue_ID');
         mParam.AsString:=mOTDQ_ID;
         mParam := mInputParams.GetOrCreateParam(dtstring,'Store_ID');
         mParam.AsString:=mFinalStore_ID;
         mImportMan := NxCreateDocumentImportManager(OS, Class_OutgoingTransfer, Class_IncomingTransfer);
         mImportMan.AddInputDocument(mOutgoingTransfer.OID);
         mImportMan.LoadParams(mInputParams);
         mImportMan.Execute;
         mImportMan.CheckOutputDocument;
         mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', mOTDQ_ID);
         mImportMan.OutputDocument.Save;


   mOutgoingTransfer.free;
  end;
end;

procedure CheckCSV (OS: TNxCustomObjectSpace; var ProcessContinue: Boolean; Email, EmailAttachment: TNxCustomBusinessObject);
Var
 mXMLHead:TNxScriptingXMLWrapper;
 mStore_ID, mDivision_ID, mDocqueue_ID,mDocqueueOT_ID, mFileName:String;
 i:integer;
 mReceivedOder, mRORow:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mFile, mReceivedOrder_ID, mStoreCard_ID, mFirm_ID:string;
 mM:TMemoryStream;
 mList:TStringList;
 mCode, mName, mEan, mQuantityStr, mPrice, mExtNum, mStoreMora:string;
 mQuantity:extended;
begin
  ProcessContinue := True;
  // Pokud se nejedná o přílohu v CSV, tak není co dělat
  mStore_ID:='2000000101'; //001
  mDivision_ID:='L000000101'; //
  mDocqueue_ID:='D100000101';
  mDocqueueOT_ID:='N000000101';
  if Assigned(EmailAttachment) then begin
  if UpperCase(NxRight(EmailAttachment.GetFieldValueAsString('FileName'),4)) <> '.CSV' then
    exit;
  begin
    mM:= TMemoryStream.Create;
    try
      // Uložím CSV soubor z přílohy emailu do složky
      mFile := EmailAttachment.GetFieldValueAsString('FileName');
      mFileName := 'c:\abra\csv\' + mFile;
      mM.SetBytes(EmailAttachment.GetFieldValueAsBytes('BlobData'));
      mM.SaveToFile(mFileName);
    finally
      mM.Free;
    end;
   end;
   mList := TStringList.Create;
   mList.loadFromFile(mFileName);
       mReceivedOder:=os.CreateObject(Class_ReceivedOrder);
       mReceivedOder.new;
       mReceivedOder.prefill;
       mReceivedOder.SetFieldValueAsString('DocQueue_ID',mDocqueue_ID);
      // mReceivedOder.SetFieldValueAsString('Firm_ID',mFirm_ID);
       mRows:=mReceivedOder.GetLoadedCollectionMonikerForFieldCode(mReceivedOder.GetFieldCode('Rows'));
        for i:=1 to mlist.Count-1 do begin
         mCode:=NxToken(mlist.strings[i],';');
         mName:=NxToken(mlist.strings[i],';');
         mEan:=NxToken(mlist.strings[i],';');
         mQuantity:=NxIBStrToFloat(NxToken(mlist.strings[i],';'));
         mPrice:=NxToken(mlist.strings[i],';');
         mExtNum:=NxToken(mlist.strings[i],';');
         mStoreMora:=NxToken(mlist.strings[i],';');
         if i=1 then begin
          if mStoreMora='1000' then mReceivedOder.SetFieldValueAsString('Firm_ID','F900000101') else mReceivedOder.SetFieldValueAsString('Firm_ID','E900000101')

         end;
         mStoreCard_ID:=GetStoreCard_ID(OS,mEan);
          if not(NxIsEmptyOID(mStoreCard_ID)) then begin
           mRORow:=mrows.AddNewObject;
           mRORow.SetFieldValueAsInteger('RowType',3);
           mRoRow.SetFieldValueAsString('Store_ID',mStore_ID);
           mRORow.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
           mrorow.SetFieldValueAsFloat('Quantity',mQuantity);
           mRORow.SetFieldValueAsString('Division_ID',mDivision_ID);
          end;
        end;
       mReceivedOder.SetFieldValueAsString('externalNumber',mExtNum);
       mReceivedOder.save;
       mReceivedOder.free;

  end;

end;

begin
end.