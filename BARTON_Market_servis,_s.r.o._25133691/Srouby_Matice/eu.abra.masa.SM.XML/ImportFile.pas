uses '.fce', '.Progress';

function ImportFile(mFilename:String; AOS:TNxCustomObjectSpace; aSite:TSiteForm; aFirm_ID, aStore_ID, aDivision_ID, aDocQueue_ID, aDescription:String):String;
var
  mXMLHead : TNxScriptingXMLWrapper;
  i,k :Integer;
  mStoreCard_ID, mStoreCard_Code,mMessage:String;
  mReceiptCardBO, mReceiptCardRowBO, mStoreCardBO:TNxCustomBusinessObject;
  mRows:TNxCustomBusinessMonikerCollection;
  mCardList:TStringList;
begin
  mXMLHead := TNxScriptingXMLWrapper.Create;
  mXMLHead.loadFromFile(mFilename);
  // zacatek SalesLine
  for i:=0 to mXMLHead.getElementsCountInArray('IssuedInvoice')-1 do begin
     mReceiptCardBO:=AOS.CreateObject(Class_ReceiptCard);
     mReceiptCardBO.New;
     mReceiptCardBO.Prefill;
     mReceiptCardBO.SetFieldValueAsString('Firm_ID', aFirm_ID);
     mReceiptCardBO.SetFieldValueAsString('DocQueue_id',aDocQueue_ID);
     mReceiptCardBO.SetFieldValueAsString('Currency_ID',mXMLHead.getAttributeValue('IssuedInvoice['+inttostr(i)+'].Currency','ID'));
     mReceiptCardBO.SetFieldValueAsString('Description', aDescription);
     mRows:=mReceiptCardBO.GetCollectionMonikerForFieldCode(mReceiptCardBO.GetFieldCode('Rows'));
     try
       ProgressInit(aSite, 'Kontroluji položky...', mXMLHead.getElementsCountInArray('IssuedInvoice['+inttostr(i)+'].Rows.row'));
        mCardList:=TstringList.Create;
        for k:=0 to  mXMLHead.getElementsCountInArray('IssuedInvoice['+inttostr(i)+'].Rows.row')-1 do begin
         mStoreCard_Code:=mXMLHead.getElementAsString('IssuedInvoice['+inttostr(i)+'].Rows.row['+inttostr(k)+'].StoreCard.Code');
         mStoreCard_id:=GetSToreCard_ID(AOS,mStoreCard_Code);
         if NxIsEmptyOID(mStoreCard_ID) then mCardList.Add(mStoreCard_Code);

        ProgressSetPos(k+1);
        end;
     ProgressDispose();
     except
       ProgressDispose();
     end;
     if mCardList.count>0 then begin
           mMessage:='Nenalezené položky: ';
           for i:=0 to mCardList.count-1 do begin
             mMessage:=mMessage+#13+#10+mCardList.Strings[i];

           end;
           NxShowSimpleMessage(mMessage,aSite);
           exit;

     end;
     mCardList.free;
     ProgressInit(aSite, 'Importuji položky...', mXMLHead.getElementsCountInArray('IssuedInvoice['+inttostr(i)+'].Rows.row'));
     for k:=0 to  mXMLHead.getElementsCountInArray('IssuedInvoice['+inttostr(i)+'].Rows.row')-1 do begin

        mStoreCard_Code:=mXMLHead.getElementAsString('IssuedInvoice['+inttostr(i)+'].Rows.row['+inttostr(k)+'].StoreCard.Code');
        mStoreCard_id:=GetSToreCard_ID(AOS,mStoreCard_Code);
        if NxIsEmptyOID(mStoreCard_ID) then begin
         NxShowSimpleMessage('Nebyla nalezena karta s kódem '+mStoreCard_Code,nil);
         ProgressDispose();
         exit;
        end;
        if not(NxIsEmptyOID(mStoreCard_ID)) then begin
          mReceiptCardRowBO:=mrows.AddNewObject;
          mReceiptCardRowBO.SetFieldValueAsInteger('RowType',3);
          mReceiptCardRowBO.SetFieldValueAsString('Store_ID',aStore_ID);
          mReceiptCardRowBO.SetFieldValueAsString('Storecard_ID',mStoreCard_ID);
          mReceiptCardRowBO.SetFieldValueAsFloat('Quantity',mXMLHead.getElementAsFloat('IssuedInvoice['+inttostr(i)+'].Rows.row['+inttostr(k)+'].Quantity'));
          mReceiptCardRowBO.SetFieldValueAsFloat('UnitPRice',mXMLHead.getElementAsFloat('IssuedInvoice['+inttostr(i)+'].Rows.row['+inttostr(k)+'].UnitPrice'));
          mReceiptCardRowBO.SetFieldValueAsString('Division_ID',aDivision_ID);
        end;
        ProgressSetPos(k+1);
     end;
     ProgressDispose();
     mReceiptCardBO.save;
     mReceiptCardbo.Free;
  end;
end;
begin
end.