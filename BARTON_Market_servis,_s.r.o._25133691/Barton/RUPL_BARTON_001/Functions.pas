
Const
   cDocQueue_DL_ID = 'P600000101'; //DL
   cDocQueue_VPZ_ID = '2900000101'; //VPZ
   cStoreGateway_ID = '1010000101'; // Vyskladnovací místo
   cStoreMan_ID = '5000000101'; // Skladním

   cNxSameGoodsInPositionStrategyID = '{BD31E23F-18B7-43B9-93B6-B652714090F1}';
   cNxOldestStorageStrategyID = '{37A351FA-D60D-4A98-9A58-1FD1ACAD5339}';
   cNxFreePositionsStrategyID = '{CBF7FC08-CAB3-4172-9A01-A7456BD4BC35}';
   cNxMinimumPositionsStrategyID = '{C8F75D91-DDC3-40B4-A89E-24CDCBBDD523}';
   cNxAccessibilityInputStrategyID = '{4F47491B-EAFC-4B9E-A905-45B7471C6723}';
   cNxAccessibilityOutputStrategyID = '{0881618E-DF24-4A2E-87BC-DD75BD1E3F51}';
   cNxMinimumAccessiblePositionsStrategyID = '{96BA5D26-14C5-4704-AF1A-157438752679}';
   cNxFreeNoPreferredPositionsStrategyID = '{CFF06E40-E587-4DFF-9680-880751B3F359}';



procedure  AUTO_Create_DL_From_OP(OS: TNxCustomObjectSpace;  var Success: Boolean; var LogInfoStr: String);
var
   mLog: TStringList;
   mSQL: String;
   mList: TStringList;
   i: Integer;
begin
   Success := True;
   LogInfoStr := '';

   mLog:= TStringList.Create;
   mList:= TStringList.Create;
   try
      mLog.Add('');

      mSQL:= 'Select ID '+
             'From ReceivedOrders '+
             'Where (IsAvailableForDelivery = ''A'') and (Confirmed = ''A'') and (Closed = ''N'') and (Revided_ID IS NULL) and (X_ STAV_ROZDELIT = 1) '+
             'and ID = ''H1B1000101'' ';

      OS.SQLSelect(mSQL,mList);
      if mList.Count > 0 then
      begin
         For i:= 0 to mList.Count - 1 do
         begin
            Create_DL_From_OP(OS,mLog,mList[i]);
         end;
      end;

      mLog.Add('');
      mLog.Add('Dokončeno');
      LogInfoStr:= mLog.Text;
   finally
      mLog.Free;
      mList.Free;
   end;
end;

{
   Procedura, která Načte OP, projde její řádky, jestli jsou skladem, a založí DL podle X_Položky na typu skladové karty
}
procedure Create_DL_From_OP(OS: TNxCustomObjectSpace;VAR mLog: TStringList; mID: String);
var
   i,j: Integer;
   mTypeList: TStringList;
   mSelectedRows: TStringList;
   mValidateErrors: TStringList;

   mReceivedOrder: TNxCustomBusinessObject;
   mRows: TNxCustomBusinessMonikerCollection;
   mRow: TNxCustomBusinessObject;

   mRowsDL: TNxCustomBusinessMonikerCollection;

   mSQL: String;
   mStoredQuantity,mNeedQuantity, mLogQuantity: Double;
   mRowCount,mRowDelCount: Integer;

   mImportMan: TNxDocumentImportManager;
   mInputParams: TNxParameters;

   mImportMan2: TNxDocumentImportManager;
   mInputParams2: TNxParameters;

   mAbraOLE,mObject:Variant;
begin
   mReceivedOrder:= OS.CreateObject(Class_ReceivedOrder);
   mTypeList:= TStringList.Create;
   mValidateErrors:= TStringList.Create;
   try
      mTypeList.Duplicates:= dupIgnore;
      mTypeList.Sorted:= True;
      if mReceivedOrder.Test(mID) then
      begin
         mReceivedOrder.Load(mID,nil);
         mRowCount:= 0;
         mRowDelCount:= 0;
         mLog.Add('Zpracovávám: '+mReceivedOrder.DisplayName);

         mRows:= mReceivedOrder.GetLoadedCollectionMonikerForFieldCode(mReceivedOrder.GetFieldCode('Rows'));
         For i:= 0 to mRows.Count - 1 do
         begin
            mRow:= mRows.BusinessObject(i);
            if mRow.GetFieldValueAsString('RowType') = '3' then
            if mRow.GetFieldValueAsFloat('DeliveredQuantity') < mRow.GetFieldValueAsFloat('Quantity') then
            begin
               mTypeList.Add(mRow.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID.X_ExpSkup'));
            end;
         end;

         mLog.Add(' - Obsahuje: '+IntToStr(mTypeList.Count)+' exp.skupin');

         For i:= 0 to mTypeList.Count - 1 do
         begin
            mLog.Add(' - Zpracovávám: '+mTypeList[i]);
            mSelectedRows:= TStringList.Create;
            try
               For j:= 0 to mRows.Count - 1 do
               begin
                  mRow:= mRows.BusinessObject(j);
                  if mRow.GetFieldValueAsString('StoreCard_ID.StoreCardCategory_ID.X_ExpSkup') = mTypeList[i] then
                  if mRow.GetFieldValueAsFloat('DeliveredQuantity') < mRow.GetFieldValueAsFloat('Quantity') then
                  begin
                     mSelectedRows.Add(mRow.OID);
                  end;
               end;

               if mSelectedRows.Count > 0 then
               begin
                  mImportMan := NxCreateDocumentImportManager(OS, Class_ReceivedOrder, Class_BillOfDelivery);
                  try
                     mInputParams := TNxParameters.Create;
                     mImportMan.AddInputDocument(mReceivedOrder.OID);
                     mImportMan.SelectedHeader:= mImportMan.InputDocuments[0];
                     mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID').AsString := cDocQueue_DL_ID;
                     mInputParams.GetOrCreateParam(dtString, 'SelectedRows').AsString := mSelectedRows.Text;

                     mImportMan.LoadParams(mInputParams);
                     mImportMan.Execute;

                    // mImportMan.OutputDocument.SetFieldValueAsString('Description',mReceivedOrder.DisplayName+' / '+mTypeList[i]);

                     mRowsDL:= mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
                     For j:= 0 to mRowsDL.Count - 1 do
                     begin
                        mRow:= mRowsDL.BusinessObject[j];
                        //Skladem
                        mSQL:= 'Select Quantity From StoreSubCards Where StoreCard_ID = '+QuotedStr(mRow.GetFieldValueAsString('StoreCard_ID'))+' and Store_ID = '+QuotedStr(mRow.GetFieldValueAsString('Store_ID'));
                        mStoredQuantity:= OS.SQLSelectFirstAsExtended(mSQL,0);

                        // Na pozicích
                        mSQL:= 'Select Sum(Quantity) From LogStoreContents LSC Join LogStorePositions LSP on LSP.ID = LSC.Parent_ID Where StoreCard_ID = '+QuotedStr(mRow.GetFieldValueAsString('StoreCard_ID'))+' and LSP.Store_ID = '+QuotedStr(mRow.GetFieldValueAsString('Store_ID'));
                        mLogQuantity:= OS.SQLSelectFirstAsExtended(mSQL,0);

                        //mNeedQuantity:= mRow.GetFieldValueAsFloat('Quantity') - mRow.GetFieldValueAsFloat('DeliveredQuantity');
                        mSQL:= 'Select sum(Quantity - DeliveredQuantity) From ReceivedOrders2 Where Parent_ID = '+QuotedStr(mReceivedOrder.OID)+' and StoreCard_ID = '+QuotedStr(mRow.GetFieldValueAsString('StoreCard_ID'))+' and Store_ID = '+QuotedStr(mRow.GetFieldValueAsString('Store_ID'));
                        mNeedQuantity:= OS.SQLSelectFirstAsExtended(mSQL,0);

                        if mStoredQuantity > 0 then
                        begin
                           if mStoredQuantity >= mNeedQuantity then
                           begin
                              // S řádkem nic nedělám, je ok
                              if mLogQuantity >= mNeedQuantity then
                              begin
                                 mRowCount:= mRowCount + 1;
                              end
                              else
                              begin
                                 mRow.MarkForDelete;
                                 mRowDelCount:= mRowDelCount + 1;
                                 mLog.Add('   - Skladovou kartu: '+mRow.GetFieldValueAsString('StoreCard_ID.DisplayName')+' nemůžu expedovat, není skladem na pozicích: '+FloatToStr(mLogQuantity)+', potřebuji: '+FloatToStr(mNeedQuantity));
                              end;
                           end
                           else
                           begin
                              mRow.MarkForDelete;
                              mRowDelCount:= mRowDelCount + 1;
                              mLog.Add('   - Skladovou kartu: '+mRow.GetFieldValueAsString('StoreCard_ID.DisplayName')+' nemůžu expedovat, není skladem: '+FloatToStr(mStoredQuantity)+', potřebuji: '+FloatToStr(mNeedQuantity));
                           end;
                        end
                        else
                        begin
                           mRow.MarkForDelete;
                           mRowDelCount:= mRowDelCount + 1;
                           mLog.Add('   - Skladovou kartu: '+mRow.GetFieldValueAsString('StoreCard_ID.DisplayName')+' nemůžu expedovat, není skladem');
                        end;
                     end;

                     if mRowCount > 0 then
                     begin
                        if mImportMan.OutputDocument.Validate then
                        begin
                           mImportMan.OutputDocument.Save;
                           mLog.Add(' - Založen doklad: '+mImportMan.OutputDocument.DisplayName);
                           mImportMan.OutputDocument.PMChangeState('2010000101');
                           mLog.Add(' - Nastaven procesní stav "Ke zpracování READY" dokladu:'+mImportMan.OutputDocument.DisplayName);
                           {
                           mImportMan2: TNxDocumentImportManager;
                           mInputParams2: TNxParameters;
                           }
                           mImportMan2 := NxCreateDocumentImportManager(OS, Class_BillOfDelivery, Class_LogStoreOutput);
                           try
                              mInputParams2 := TNxParameters.Create;
                              mImportMan2.AddInputDocument(mImportMan.OutputDocument.OID);
                              mImportMan2.SelectedHeader:= mImportMan2.InputDocuments[0];
                              mInputParams2.GetOrCreateParam(dtString, 'StoreGateway_ID').AsString := cStoreGateway_ID;
                              mInputParams2.GetOrCreateParam(dtString, 'DocQueue_ID').AsString := cDocQueue_VPZ_ID;
                              mInputParams2.GetOrCreateParam(dtString, 'StoreMan_ID').AsString := cStoreMan_ID;
                              mInputParams2.GetOrCreateParam(dtBoolean, 'AutoPrefillPosition').AsBoolean := True;
                              mInputParams2.GetOrCreateParam(dtString, 'Strategy_ID').AsString := cNxFreePositionsStrategyID;
                              mInputParams2.GetOrCreateParam(dtBoolean, 'IsAccessibilityLimitFilter').AsBoolean := False;
                              mInputParams2.GetOrCreateParam(dtInteger, 'AccessibilityLimit').AsInteger := 0;

                              mImportMan2.LoadParams(mInputParams2);
                              mImportMan2.Execute;
                              if mImportMan2.OutputDocument.Validate then
                              begin
                                 mImportMan2.OutputDocument.Save;
                                 mLog.Add(' - Vytvořen polohovací doklad:'+mImportMan2.OutputDocument.DisplayName);

                                 //provedení dokladu
                                 mAbraOLE := GetAbraOLEApplication;
                                 mObject := mAbraOLE.CreateObject(Class_LogStoreOutput);
                                 try
                                    mObject.MakeExecuted(mImportMan2.OutputDocument.OID);
                                 finally
                                    mObject := nil;
                                    mAbraOLE := nil;
                                 end;
                                 mLog.Add(' - Proveden polohovací doklad:'+mImportMan2.OutputDocument.DisplayName);


                              end
                              else
                              begin
                                 mImportMan2.OutputDocument.GetValidateErrors(mValidateErrors);
                                 mLog.Add(' - Polohovací doklad nebylo možné uložit, chyby:'+mValidateErrors.Text);
                              end;
                           finally
                              mImportMan2.Free;
                           end;
                        end
                        else
                        begin
                           mImportMan.OutputDocument.GetValidateErrors(mValidateErrors);
                           mLog.Add(' - Doklad nebylo možné uložit, chyby:'+mValidateErrors.Text);
                        end;
                     end
                     else
                     begin
                        mLog.Add(' - Doklad neukládám, neměl by žádné řádky');
                     end;
                  finally
                     mImportMan.Free;
                     mSelectedRows.Free;
                  end;
               end;
            finally
               mSelectedRows.Free;
            end;
         end;

         mReceivedOrder.Load(mID,nil);
         if (mRowCount > 0) and (mRowDelCount = 0) then mReceivedOrder.SetFieldValueAsInteger('X_STAV_ROZDELIT',3) // Vše rozděleno
                                                   else mReceivedOrder.SetFieldValueAsInteger('X_STAV_ROZDELIT',2); //ČÁST roozdělena
         mReceivedOrder.Save;
      end
      else
      begin
         mLog.Add('Chybné ID: '+mID);
      end;
   finally
      mReceivedOrder.Free;
      mTypeList.Free;
      mValidateErrors.Free;
   end;

   mLog.Add('');
end;

begin
end.