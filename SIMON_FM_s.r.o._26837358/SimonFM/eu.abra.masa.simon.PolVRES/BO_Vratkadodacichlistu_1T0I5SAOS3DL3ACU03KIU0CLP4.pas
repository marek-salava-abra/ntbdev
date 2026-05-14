{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
    mPosRow, mBO : TNxCustomBusinessObject;
    mImportMan:TNxDocumentImportManager;
    mAbraOLE,mObject:Variant;
    mRows, mPosRows: TNxCustomBusinessMonikerCollection;
    i : integer;
    mInputParams : TNxParameters;
    mParam: TNxParameter;
    mOS: TNxCustomObjectSpace;
begin
  if (self.GetFieldValueAsString('DocQueue_ID.Code')='VRES') and
   (self.GetFieldValueAsString('PMState_ID')='SDDEF00000') then begin
            mInputParams := TNxParameters.Create;
            mParam := mInputParams.GetOrCreateParam(dtString, 'StoreGateWay_ID');
            mParam.AsString := '1000000101';
            mParam := mInputParams.GetOrCreateParam(dtString,'DocQueue_ID');
            mParam.AsString := '6RE0000101';
            mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
            mParam.AsString := self.oid;
            mParam := mInputParams.GetOrCreateParam(dtBoolean, 'AutoPrefillPosition');
            mParam.AsBoolean := False;

            mImportMan := NxCreateDocumentImportManager(self.ObjectSpace, Class_RefundedBillOfDelivery, Class_LogStoreInput);
            mImportMan.AddInputDocument(self.oid);
            mImportMan.LoadParams(mInputParams);
            mImportMan.Execute;
            OutputDebugString('After importmanager execute');
            mPosRows := mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
            OutputDebugString('RowsCount: '+inttostr(mPosRows.Count));
            for i:=0 to mPosRows.Count-1 do begin
              mPosRow:= mPosRows.BusinessObject(i);
              OutputDebugString('řádek: '+IntToStr(i+1)+' | ' + mPosRow.GetFieldValueAsString('StoreCard_ID.Name'));
              mPosRow.SetFieldValueAsString('StorePosition_ID', 'BA10000101');
              mPosRow.SetFieldValueAsFloat('InPositionQuantity', mPosRow.GetFieldValueAsFloat('RestQuantity'));
            end;
            mImportMan.OutputDocument.Save;
            OutputDebugString('After save: '+ mImportMan.OutputDocument.OID);

            //provedení dokladu
            mAbraOLE := GetAbraOLEApplication;
            mObject := mAbraOLE.CreateObject(Class_LogStoreInput);
            try
              mObject.MakeExecuted(mImportMan.OutputDocument.OID);
            except
              NxShowSimpleMessage('Nepovedlo se provést doklad',nil);
            end;
            {
            mBO := mOS.CreateObject(Class_RefundedBillOfDelivery);
            mBO.Load(self.OID,nil);
            mBO.SetFieldValueAsString('PMState_ID','SDDEF00000');
            mbo.save;
            mbo.free; }

   end;
   if (self.GetFieldValueAsString('DocQueue_ID.Code')='VR03') and
   (self.GetFieldValueAsString('PMState_ID')='SDDEF00000') then begin
            mInputParams := TNxParameters.Create;
            mParam := mInputParams.GetOrCreateParam(dtString, 'StoreGateWay_ID');
            mParam.AsString := '1000000101';
            mParam := mInputParams.GetOrCreateParam(dtString,'DocQueue_ID');
            mParam.AsString := '6RE0000101';
            mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
            mParam.AsString := self.oid;
            mParam := mInputParams.GetOrCreateParam(dtBoolean, 'AutoPrefillPosition');
            mParam.AsBoolean := False;

            mImportMan := NxCreateDocumentImportManager(self.ObjectSpace, Class_RefundedBillOfDelivery, Class_LogStoreInput);
            mImportMan.AddInputDocument(self.oid);
            mImportMan.LoadParams(mInputParams);
            mImportMan.Execute;
            OutputDebugString('After importmanager execute');
            mPosRows := mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
            OutputDebugString('RowsCount: '+inttostr(mPosRows.Count));
            for i:=0 to mPosRows.Count-1 do begin
              mPosRow:= mPosRows.BusinessObject(i);
              OutputDebugString('řádek: '+IntToStr(i+1)+' | ' + mPosRow.GetFieldValueAsString('StoreCard_ID.Name'));
              mPosRow.SetFieldValueAsString('StorePosition_ID', '2070000101');
              mPosRow.SetFieldValueAsFloat('InPositionQuantity', mPosRow.GetFieldValueAsFloat('RestQuantity'));
            end;
            mImportMan.OutputDocument.Save;
            OutputDebugString('After save: '+ mImportMan.OutputDocument.OID);

            //provedení dokladu
            mAbraOLE := GetAbraOLEApplication;
            mObject := mAbraOLE.CreateObject(Class_LogStoreInput);
            try
              mObject.MakeExecuted(mImportMan.OutputDocument.OID);
            finally
              mObject := nil;
            end;
            {
            mBO := mOS.CreateObject(Class_RefundedBillOfDelivery);
            mBO.Load(self.OID,nil);
            mBO.SetFieldValueAsString('PMState_ID','SDDEF00000');
            mbo.save;
            mbo.free; }

   end;
end;

begin
end.