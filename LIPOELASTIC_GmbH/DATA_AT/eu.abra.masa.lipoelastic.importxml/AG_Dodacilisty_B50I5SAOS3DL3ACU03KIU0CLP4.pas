uses '.fce';


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
 mStoreBatchName, mExpiryDateString:string;
 mExpiryDate:Extended;
 mRORowList, mErrList:TStringList;
 mImportManager: TNxDocumentImportManager;
 mInputParams: TNxParameters;
 mParam: TNxParameter;
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
       mXMLHead:=TNxScriptingXMLWrapper.Create;
       mXMLHead.loadFromFile(mOpenDlg.Files[i]);
         for j:=0 to mXMLHead.getElementsCountInArray('Deliveries.Delivery')-1 do begin
           mExternalNumber:=mXMLHead.getAttributeValue('Deliveries.Delivery['+IntToStr(j)+'].DeliveryLine[0]','SalesOrderNumber');
           mRORowList:=TStringList.create;
           mRO_ID:=mOS.SQLSelectFirstAsString('Select id from receivedorders where externalNumber='+QuotedStr(mExternalNumber),'');
           for k:=0 to mXMLHead.getElementsCountInArray('Deliveries.Delivery['+IntToStr(j)+'].DeliveryLine')-1 do begin
             mSCEAN:=mXMLHead.getAttributeValue('Deliveries.Delivery['+IntToStr(j)+'].DeliveryLine['+IntToStr(k)+'].Item','code');
             mSCName:= mXMLHead.getElementAsString('Deliveries.Delivery['+IntToStr(j)+'].DeliveryLine['+IntToStr(k)+'].Item.Description');
             mStoreCard_ID:=GetStoreCard(mos, mSCEAN,mSCName);
             mRORow_ID:=mOS.SQLSelectFirstAsString('Select ro2.id from receivedorders2 ro2 where ro2.parent_id='+
                                                   QuotedStr(mRO_ID)+' and ro2.StoreCard_ID='+QuotedStr(mStoreCard_ID),'');
             mRORowList.Add(mRORow_ID);
           end;
           if not(NxIsEmptyOID(mRO_ID)) then begin
                 //začátek DIM
                  mInputParams := TNxParameters.Create;
                  mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                  mParam.AsString := '9000000101';
                  mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows'); // jen povolene radky
                  mParam.AsString := mRORowList.Text;
                  mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
                  mParam.AsString := mRO_ID;
                  mImportManager := NxCreateDocumentImportManager(mOS, Class_ReceivedOrder, Class_BillOfDelivery);
                  try
                    mImportManager.AddInputDocument(mRO_ID);
                    mImportManager.LoadParams(mInputParams);
                    mImportManager.Execute;
                    mImportManager.CheckOutputDocument;
                    if Assigned(mImportManager.OutputDocument) then begin
                      mImportManager.OutputDocument.SetFieldValueAsString('DocQueue_ID', '9000000101');
                      mImportManager.OutputDocument.SetFieldValueAsDateTime('DocDate$Date',mCompileDate(mXMLHead.getAttributeValue('Deliveries.Delivery['+IntToStr(j)+']','EntryDate')));
                      mImportManager.OutputDocument.SetFieldValueAsString('Period_ID',GetPeriodID(mOS,mImportManager.OutputDocument.GetFieldValueAsDateTime('DocDate$Date')));
                      mImportManager.OutputDocument.SetFieldValueAsString('X_ExactNumber',mXMLHead.getAttributeValue('Deliveries.Delivery['+IntToStr(j)+']','DeliveryNumber'));
                      mImportManager.OutputDocument.SetFieldValueAsString('X_TrackingNumber',AnsiLeftStr(mXMLHead.getAttributeValue('Deliveries.Delivery['+IntToStr(j)+']','TrackingNumber'),30));
                      mRows:=mImportManager.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportManager.OutputDocument.GetFieldCode('Rows'));
                      for l:=0 to mrows.Count-1 do begin
                      mRowBO:=mRows.BusinessObject[l];
                      //řešení šarží
                         for k:=0 to mXMLHead.getElementsCountInArray('Deliveries.Delivery['+IntToStr(j)+'].DeliveryLine')-1 do begin
                           mSCEAN:=mXMLHead.getAttributeValue('Deliveries.Delivery['+IntToStr(j)+'].DeliveryLine['+IntToStr(k)+'].Item','code');
                           mSCName:= mXMLHead.getElementAsString('Deliveries.Delivery['+IntToStr(j)+'].DeliveryLine['+IntToStr(k)+'].Item.Description');
                           mStoreCard_ID:=GetStoreCard(mos, mSCEAN,mSCName);
                           mBODQuantity:=NxIBStrToFloat(mXMLHead.getAttributeValue('Deliveries.Delivery['+IntToStr(j)+'].DeliveryLine['+IntToStr(k)+']','Quantity'));
                           if mRowBO.GetFieldValueAsString('StoreCard_ID')=mStoreCard_ID then begin
                            mDocRowBatches:=mRowBO.GetLoadedCollectionMonikerForFieldCode(mRowBO.GetFieldcode('DocRowBatches'));
                            if (mBODQuantity>0) and (mDocRowBatches.count=0) then begin
                             //if ElementExists(mXMLHead,'Deliveries.Delivery['+IntToStr(j)+'].DeliveryLine['+IntToStr(k)+'].BatchNumbers') then begin
                             try
                               for m:=0 to mXMLHead.getElementsCountInArray('Deliveries.Delivery['+IntToStr(j)+'].DeliveryLine['+IntToStr(k)+'].BatchNumbers.BatchNumberLine')-1 do begin
                                 mStoreBatchName:=mXMLHead.getAttributeValue('Deliveries.Delivery['+IntToStr(j)+'].DeliveryLine['+IntToStr(k)+'].BatchNumbers.BatchNumberLine['+IntToStr(m)+'].BatchNumber','BatchNumber');
                                 mExpiryDate:=Date;
                                 try
                                  mExpiryDateString:=mXMLHead.getAttributeValue('Deliveries.Delivery['+IntToStr(j)+'].DeliveryLine['+IntToStr(k)+'].BatchNumbers.BatchNumberLine['+IntToStr(m)+'].BatchNumber','ExpiryDate');
                                  mExpiryDate:=mCompileDate(mExpiryDateString);
                                 except

                                 end;
                                 mQuantity:=NxIBStrToFloat(mXMLHead.getAttributeValue('Deliveries.Delivery['+IntToStr(j)+'].DeliveryLine['+IntToStr(k)+'].BatchNumbers.BatchNumberLine['+IntToStr(m)+']','Quantity'));
                                 mStoreBatch_ID:=GetOrCreateSB_ID(mOS,mStoreCard_ID, mStoreBatchName,mExpiryDate);
                                 mDocRowBatches:=mRowBO.GetLoadedCollectionMonikerForFieldCode(mRowBO.GetFieldcode('DocRowBatches'));
                                 mDRBBo:=mDocRowBatches.AddNewObject;
                                 mDRBBo.Prefill;
                                 mDRBBO.SetFieldValueAsString('StoreBatch_ID',mStoreBatch_ID);
                                 mDRBBo.SetFieldValueAsFloat('Quantity',mQuantity);
                               end;
                             except

                             end;
                             mRowBO.SetFieldValueAsFloat('Quantity', mBODQuantity);
                            end;
                           end;
                          end;
                      //konec šarží
                      end;
                      mImportManager.OutputDocument.save;
                      mImportManager.free;
                    end;
                  except
                    mErrList.add('________________________________________');
                    mErrList.add('doklad objednávky '+mExternalNumber+'   doklad delivery '+mXMLHead.getAttributeValue('Deliveries.Delivery['+IntToStr(j)+']','DeliveryNumber'));
                    mErrlist.add(ExceptionMessage);
                    mErrList.add('****************************************');
                  end;
              end else begin
                    mErrList.add('________________________________________');
                    mErrList.add('doklad objednávky '+mExternalNumber+'   doklad delivery '+mXMLHead.getAttributeValue('Deliveries.Delivery['+IntToStr(j)+']','DeliveryNumber'));
                    mErrlist.add('doklad objednávky se nepovedlo dohledat');
                    mErrList.add('****************************************');
              end;
         end;
       mXMLHead.free;
       WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(mCount));
       WaitWin.StepIt;
      end;
      WaitWin.Stop;
     except
      WaitWin.Stop;
      NxShowSimpleMessage(ExceptionMessage,mSite);
  end;
 end;
 mErrList.SaveToFile('C:\AbraDE\'+FormatDateTime('YYYYMMDDHHNNSS',Now)+'error.txt');
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

begin
end.