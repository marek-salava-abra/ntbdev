uses '.fce';

{
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction:TAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImpXML';
  mAction.Caption := '##Import XML##';
  mAction.Hint := 'Naimportuje XML data';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportXML;
end;
}

Procedure ImportXML(Sender:TComponent);
var
 mSite:TSiteForm;
 mOpenDlg: TOpenDialog;
 mOS:TNxCustomObjectSpace;
 i,j,k,l,m,mCount:integer;
 mXMLHead:TNxScriptingXMLWrapper;
 mBO, mRowBO, mFirmBO, mDRBBo:TNxCustomBusinessObject;
 mStreet, mCity, mPostCode, mFirmOffice_ID, mOrder_ID, mStore_ID:string;
 mCodeEan, mSCName,mStoreCard_ID,mVATName:string;
 mRows, mDocRowBatches:TNxCustomBusinessMonikerCollection;
 mQuantity, mBODQuantity:extended;
 mSQLStreet,mSQLPostCode, mSQLCity, mStoreCode:string;
 mContactFirstName, mContactLastName, mContactEmail: string;
 mPerson_ID, mFPerson_ID, mRO_ID, mRORow_ID, mExternalNumber, mSCEAN, mStoreBatch_ID: string;
 mStoreBatchName, mExpiryDateString, mPayCode, mTransCode, mPayment_ID, mTrans_ID, mSD2_ID, mFileName, mInvoice_ID:string;
 mExpiryDate:Extended;
 mRORowList, mErrList:TStringList;
 mImportManager: TNxDocumentImportManager;
 mInputParams: TNxParameters;
 mParam: TNxParameter;
 mInvoiceBO, mInvoiceRowBO:TNxCustomBusinessObject;
 mDelete:Boolean;
begin
 mSite:=TComponent(Sender).DynSite;
 mOS:=mSite.BaseObjectSpace;
 mOpenDlg:=TOpenDialog.Create(sender);
 mOpenDlg.Title := 'Import z XML';
 mOpenDlg.Filter := 'Soubory XML (*.xml)| *.xml';
 mOpenDlg.Options := [ofAllowMultiSelect];
 mErrList:=tstringlist.Create;
 if mOpenDlg.Execute then begin
  try
    mCount:=mOpenDlg.Files.Count;
    WaitWin.StartProgress('Čekejte, prosím ...', '', mCount);
      for i:=0 to mOpenDlg.Files.Count-1 do begin
       mErrList.Clear;
       mXMLHead:=TNxScriptingXMLWrapper.Create;
       mXMLHead.loadFromFile(mOpenDlg.Files[i]);
         for j:=0 to mXMLHead.getElementsCountInArray('Invoices.Invoice')-1 do begin
            mInvoice_ID:=mOS.SQLSelectFirstAsString('Select id from issuedinvoices where varsymbol='+QuotedStr(mXMLHead.getAttributeValue('Invoices.Invoice['+IntToStr(j)+']','invoicenumber')),'');
            if NxIsEmptyOID(mInvoice_ID) then begin
                 if mXMLHead.getAttributeValue('Invoices.Invoice['+IntToStr(j)+']','type')='8020' then begin
                   mExternalNumber:=mXMLHead.getAttributeValue('Invoices.Invoice['+IntToStr(j)+']','ordernumber');
                   mRO_ID:=mOS.SQLSelectFirstAsString('Select id from receivedorders where externalNumber='+QuotedStr(mExternalNumber),'');
                     if not(NxIsEmptyOID(mRO_ID)) then begin
                         mRORowList:=TStringList.Create;
                         mRORowList.clear;
                         mPayCode:=mXMLHead.getAttributeValue('Invoices.Invoice['+IntToStr(j)+'].PaymentCondition','code');
                         mPayment_ID:=mOS.SQLSelectFirstAsString('Select id from paymenttypes where code='+QuotedStr(mPayCode),'');
                         mTransCode:=mXMLHead.getAttributeValue('Invoices.Invoice['+IntToStr(j)+'].ShippingMethod','code');
                         mTrans_ID:=mOS.SQLSelectFirstAsString('Select id from transportationtypes where code='+QuotedStr(mTransCode),'');
                         for k:=0 to mXMLHead.getElementsCountInArray('Invoices.Invoice['+IntToStr(j)+'].InvoiceLine')-1 do begin
                          mCodeEan:=mXMLHead.getAttributeValue('Invoices.Invoice['+IntToStr(j)+'].InvoiceLine['+IntToStr(k)+'].Item','code');
                          mSCName:= mXMLHead.getElementAsString('Invoices.Invoice['+IntToStr(j)+'].InvoiceLine['+IntToStr(k)+'].Item.Description');
                          mStoreCard_ID:=GetStoreCard(mOS, mCodeEan,mSCName);
                          if not(NxIsEmptyOID(mStoreCard_ID)) then begin
                            mRORow_ID:=mOS.SQLSelectFirstAsString('Select ro2.id from receivedorders2 ro2 left join storedocuments2 sd2 on sd2.providerow_id=ro2.id where ro2.storecard_id='
                                                                  +QuotedStr(mStoreCard_ID)+' and ro2.parent_id='+QuotedStr(mRO_ID)+' and not exists(select ii2.id from issuedinvoices2 ii2 where providerow_id=sd2.id)' ,'');
                            if not(NxIsEmptyOID(mRORow_ID)) then begin
                              if mRORowList.IndexOf(mRORow_ID)<0 then mRORowList.add(mRORow_ID);
                            end;
                          end;
                         end;
                         //if mExternalNumber='20211885' then NxShowSimpleMessage('Řádky OP '+mXMLHead.getAttributeValue('Invoices.Invoice['+IntToStr(j)+']','invoicenumber')+#13#10+mRORowList.Text,mSite);
                         //začátek DIM
                          mInputParams := TNxParameters.Create;
                          mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                          mParam.AsString := 'G000000101';
                          mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows'); // jen povolene radky
                          mParam.AsString := mRORowList.Text;
                          mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
                          mParam.AsString := mRO_ID;
                          mImportManager := NxCreateDocumentImportManager(mOS, Class_ReceivedOrder, Class_IssuedInvoice);
                          try
                            mImportManager.AddInputDocument(mRO_ID);
                            mImportManager.LoadParams(mInputParams);
                            mImportManager.Execute;
                            //mImportManager.ExecuteWizard(msite);
                            mImportManager.CheckOutputDocument;
                            if Assigned(mImportManager.OutputDocument) then begin
                              mImportManager.OutputDocument.SetFieldValueAsString('DocQueue_ID', 'G000000101');
                              mImportManager.OutputDocument.SetFieldValueAsString('Firm_ID', mos.SQLSelectFirstAsString('Select firm_id from receivedorders where id='+QuotedStr(mro_id),''));
                              mImportManager.OutputDocument.SetFieldValueAsDateTime('DocDate$Date',mCompileDate(mXMLHead.getElementAsString('Invoices.Invoice['+IntToStr(j)+'].InvoiceDate')));
                              mImportManager.OutputDocument.SetFieldValueAsDateTime('DueDate$Date',mCompileDate(mXMLHead.getElementAsString('Invoices.Invoice['+IntToStr(j)+'].DueDate')));
                              mImportManager.OutputDocument.SetFieldValueAsString('Period_ID',GetPeriodID(mOS,mImportManager.OutputDocument.GetFieldValueAsDateTime('DocDate$Date')));
                              mImportManager.OutputDocument.SetFieldValueAsString('VarSymbol',mXMLHead.getAttributeValue('Invoices.Invoice['+IntToStr(j)+']','invoicenumber'));
                              mImportManager.OutputDocument.SetFieldValueAsString('BankAccount_ID','2000000101');
                              mRows:=mImportManager.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportManager.OutputDocument.GetFieldCode('Rows'));
                              for l:=0 to mRows.count-l do begin
                                 mDelete:=True;
                                 for k:=0 to mXMLHead.getElementsCountInArray('Invoices.Invoice['+IntToStr(j)+'].InvoiceLine')-1 do begin
                                  mCodeEan:=mXMLHead.getAttributeValue('Invoices.Invoice['+IntToStr(j)+'].InvoiceLine['+IntToStr(k)+'].Item','code');
                                  mSCName:= mXMLHead.getElementAsString('Invoices.Invoice['+IntToStr(j)+'].InvoiceLine['+IntToStr(k)+'].Item.Description');
                                  mStoreCard_ID:=GetStoreCard(mOS, mCodeEan,mSCName);
                                  if not(NxIsEmptyOID(mStoreCard_ID)) then begin
                                    mSD2_ID:=mOS.SQLSelectFirstAsString('Select sd2.id from receivedorders2 ro2 left join storedocuments2 sd2 on sd2.providerow_id=ro2.id where ro2.storecard_id='
                                                                          +QuotedStr(mStoreCard_ID)+' and ro2.parent_id='+QuotedStr(mRO_ID)+' and not exists(select ii2.id from issuedinvoices2 ii2 where providerow_id=sd2.id)' ,'');
                                    if mDelete then begin
                                     if mRows.BusinessObject[l].GetFieldValueAsString('ProvideRow_ID')=mSD2_ID then mDelete:=False;

                                    end;
                                  end;
                                 end;
                                 if mDelete then mRows.BusinessObject[l].MarkForDelete;
                              end;
                              mImportManager.OutputDocument.save;
                              mImportManager.free;
                            end;
                          except
                            mErrList.add('________________________________________');
                            mErrList.add('typ dokladu: ' +mXMLHead.getAttributeValue('Invoices.Invoice['+IntToStr(j)+']','type'));
                            mErrList.add('doklad objednávky '+mExternalNumber+'   doklad invoice '+mXMLHead.getAttributeValue('Invoices.Invoice['+IntToStr(j)+']','invoicenumber'));
                            mErrlist.add(ExceptionMessage);
                            mErrList.add('****************************************');
                          end;
                      end else begin
                            mErrList.add('________________________________________');
                            mErrList.add('typ dokladu: ' +mXMLHead.getAttributeValue('Invoices.Invoice['+IntToStr(j)+']','type'));
                            mErrList.add('doklad objednávky '+mExternalNumber+'   doklad invoice '+mXMLHead.getAttributeValue('Invoices.Invoice['+IntToStr(j)+']','invoicenumber'));
                            mErrlist.add('doklad objednávky se nepovedlo dohledat');
                            mErrList.add('****************************************');
                      end;

                 end else begin
                     // záporné faktury není typ 8020
                     try
                       mInvoiceBO:=mOS.CreateObject(Class_IssuedInvoice);
                       mInvoiceBO.new;
                       mInvoiceBO.Prefill;
                       mInvoiceBO.SetFieldValueAsString('DocQueue_ID','G000000101');
                       mInvoiceBO.SetFieldValueAsDateTime('DocDate$Date',mCompileDate(mXMLHead.getElementAsString('Invoices.Invoice['+IntToStr(j)+'].InvoiceDate')));
                       mInvoiceBO.SetFieldValueAsDateTime('DueDate$Date',mCompileDate(mXMLHead.getElementAsString('Invoices.Invoice['+IntToStr(j)+'].DueDate')));
                       mInvoiceBO.SetFieldValueAsString('Period_ID',GetPeriodID(mOS,mInvoiceBO.GetFieldValueAsDateTime('DocDate$Date')));
                       mInvoiceBO.SetFieldValueAsString('BankAccount_ID','2000000101');
                       mInvoiceBO.SetFieldValueAsString('VarSymbol',mXMLHead.getAttributeValue('Invoices.Invoice['+IntToStr(j)+']','invoicenumber'));
                       mInvoiceBO.SetFieldValueAsString('Firm_ID', GetOrCreateFirm(mOS,
                                                                            mXMLHead.getAttributeValue('Invoices.Invoice['+IntToStr(j)+'].OrderedBy','ID'),
                                                                            mXMLHead.getAttributeValue('Invoices.Invoice['+IntToStr(j)+'].OrderedBy','code'),
                                                                            mXMLHead.getElementAsString('Invoices.Invoice['+IntToStr(j)+'].OrderedBy.Name')));
                       mVATName:='';
                       if ElementExists(mXMLHead,'Invoices.Invoice['+IntToStr(j)+'].InvoiceLine[0].UnitPrice.VAT.Description') then
                        mVATName:=mXMLHead.getElementAsString('Invoices.Invoice['+IntToStr(j)+'].InvoiceLine['+IntToStr(0)+'].UnitPrice.VAT.Description');
                       if mVATName='B2B - DE - Umsatzsteuer 0%' then begin
                         mInvoiceBO.SetFieldValueAsInteger('TradeType',2);
                         mInvoiceBO.SetFieldValueAsString('Country_ID','00000DE000');
                       end;
                       if mVATName='B2B DE Umsatzsteuer 20%' then begin
                         mInvoiceBO.SetFieldValueAsInteger('TradeType',4);
                         mInvoiceBO.SetFieldValueAsString('Country_ID','00000DE000');
                       end;
                       if mVATName='B2C DE Umsatzsteuer 19%' then begin
                         mInvoiceBO.SetFieldValueAsInteger('TradeType',7);
                         mInvoiceBO.SetFieldValueAsString('Country_ID','00000DE000');
                       end;
                       if ElementExists(mXMLHead,'Invoices.Invoice['+IntToStr(j)+'].Description') then
                        mInvoiceBO.SetFieldValueAsString('Description',AnsiLeftStr(mXMLHead.getElementAsString('Invoices.Invoice['+IntToStr(j)+'].Description'),50));
                       mRows:=mInvoiceBO.GetLoadedCollectionMonikerForFieldCode(mInvoiceBO.GetFieldCode('Rows'));
                        for k:=0 to mXMLHead.getElementsCountInArray('Invoices.Invoice['+IntToStr(j)+'].InvoiceLine')-1 do begin
                          mInvoiceRowBO:=mRows.AddNewObject;
                          mInvoiceRowBO.Prefill;
                          mInvoiceRowBO.SetFieldValueAsInteger('RowType',2);
                          mInvoiceRowBO.SetFieldValueAsString('Text',mXMLHead.getElementAsString('Invoices.Invoice['+IntToStr(j)+'].InvoiceLine['+IntToStr(k)+'].Item.Description'));
                          mInvoiceRowBO.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('Invoices.Invoice['+IntToStr(j)+'].InvoiceLine['+IntToStr(k)+'].quantity')));
                          mInvoiceRowBO.SetFieldValueAsString('Qunit','stk');
                          mInvoiceRowBO.SetFieldValueAsFloat('UnitPrice',NxIBStrToFloat(mXMLHead.getElementAsString('Invoices.Invoice['+IntToStr(j)+'].InvoiceLine['+IntToStr(k)+'].UnitPrice.value')));
                          if mInvoiceBO.GetFieldValueAsInteger('TradeType')=1 then
                           mInvoiceRowBO.SetFieldValueAsString('VatRate_ID','02000XAT00');
                          if mInvoiceBO.GetFieldValueAsInteger('TradeType')=2 then
                           mInvoiceRowBO.SetFieldValueAsString('VatRate_ID','~000000001');
                          if mInvoiceBO.GetFieldValueAsInteger('TradeType')=4 then
                           mInvoiceRowBO.SetFieldValueAsString('VatRate_ID','02000XAT00');
                          if mInvoiceBO.GetFieldValueAsInteger('TradeType')=7 then
                           mInvoiceRowBO.SetFieldValueAsString('VatRate_ID','01900XDE00');
                          mInvoiceRowBO.SetFieldValueAsString('Division_ID','1000000101');
                        end;
                       mInvoiceBO.save;
                       mInvoiceBO.free;
                     except
                        mErrList.add('________________________________________');
                        mErrList.add('typ dokladu: ' +mXMLHead.getAttributeValue('Invoices.Invoice['+IntToStr(j)+']','type'));
                        mErrList.add('doklad objednávky '+mExternalNumber+'   doklad invoice '+mXMLHead.getAttributeValue('Invoices.Invoice['+IntToStr(j)+']','invoicenumber'));
                        mErrlist.add(ExceptionMessage);
                        mErrList.add('****************************************');
                     end;
                     // konec
                  end;
                 end;
        end;
       mXMLHead.free;
       mFileName:=ChangeFileExt(ExtractFileName(mOpenDlg.Files[i]),'');
       if mErrList.count>0 then mErrList.SaveToFile('C:\AbraDE\'+mFileName+'INerror.txt');
       WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(mCount));
       WaitWin.StepIt;
      end;
      WaitWin.Stop;
     except
      WaitWin.Stop;
      NxShowSimpleMessage(ExceptionMessage,mSite);
  end;
 end;
 mErrList.SaveToFile('C:\AbraDE\'+FormatDateTime('YYYYMMDDHHNNSS',Now)+'INerror.txt');
end;

function GetOrCreateSB_ID(var aOS:TNxCustomObjectSpace; var aStoreCard_ID, aName:string; var aDate:Extended):string;
var
 mBO:TNxCustomBusinessObject;
 mStoreBatch_ID:string;
begin
  Result:='';
  mStoreBatch_ID:=aos.SQLSelectFirstAsString('Select id from storebatches where name='+QuotedStr(aName)+' and storecard_id='+QuotedStr(aStoreCard_ID)+' and ExpirationDate$Date='+IntToStr(trunc(aDate)),'');
  if NxIsEmptyOID(mStoreBatch_ID) then begin
    mBO:=aOS.CreateObject(Class_StoreBatch);
    mBO.New;
    mBO.Prefill;
    mBO.SetFieldValueAsString('StoreCard_ID',aStoreCard_ID);
    mBO.SetFieldValueAsString('Name',aName);
    mBO.SetFieldValueAsDateTime('ExpirationDate$Date',aDate);
    mBO.SetFieldValueAsBoolean('SerialNumber',false);
    mBO.save;
    mStoreBatch_ID:=mbo.oid;
    mbo.free;
  end;
  Result:=mStoreBatch_ID;
end;


Function GetStoreCard(var aOS:TNxCustomObjectSpace; var aCode, aName:string;):string;
var
 mBO, mVATrateBO:TNxCustomBusinessObject;
 mStoreCard_ID:string;
 mUnits, mVATRates:TNxCustomBusinessMonikerCollection;
begin
 if NxIsNumeric(aCode) and (Length(aCode)=13) then begin
   mStoreCard_ID:=aOS.SQLSelectFirstAsString('SELECT  A.id FROM StoreCards A WHERE (((A.EAN LIKE N'+QuotedStr(aCode)+' ESCAPE '+QuotedStr('~')+') OR '+
                                             '(A.ID IN (SELECT SU.Parent_ID FROM StoreEANs SE JOIN StoreUnits SU ON SE.Parent_Id = SU.Id '+
                                             'WHERE SU.Parent_ID = A.ID AND SE.Ean LIKE N'+QuotedStr(aCode)+' ESCAPE '+QuotedStr('~')+')))) AND A.Hidden = '+Quotedstr('N'),'');
 end
  else mStoreCard_ID:=aOS.SQLSelectFirstAsString('Select id from storecards where code='+QuotedStr(aCode)+' and name like N'+QuotedStr(aName)+' and hidden='+QuotedStr('N'),'');

 Result:=mStoreCard_ID;
end;

Function GetOrCreateFirm(var aOS:TNxCustomObjectSpace; var EID, eCode, eName:string;):string;
var
 mBO:TNxCustomBusinessObject;
 mFirm_ID:string;
begin
 mFirm_ID:=aOS.SQLSelectFirstAsString('Select id from firms where hidden=''N'' and Firm_ID is null and X_ID_Exact='+QuotedStr(EID),'');
 if NxIsEmptyOID(mFirm_ID) then begin
   mBO:=aOS.CreateObject(Class_Firm);
   mBO.New;
   mBO.Prefill;
   mbo.SetFieldValueAsString('Code', eCode);
   mBO.SetFieldValueAsString('Name', eName);
   mBO.SetFieldValueAsString('X_ID_Exact', EID);
   mbo.save;
   mFirm_ID:=mbo.OID;
   mbo.free;
 end;
 Result:=mFirm_ID;
end;

begin
end.