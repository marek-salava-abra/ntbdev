const
  cLogStoreDocQueue_ID = '7RE0000101';
  cStoreGateWay_ID = '1000000101';

procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
    mImportMan:TNxDocumentImportManager;
    mInputParams : TNxParameters;
    mParam: TNxParameter;
    mVPZ_ID:string;
begin
   if (self.GetFieldValueAsString('DocQueue_ID')='8RC0000101') and (osNew in self.State) then begin
      mVPZ_ID:=self.ObjectSpace.SQLSelectFirstAsString('Select id from logstoredocuments where storedocument_id='+Quotedstr(self.OID),'');
      if NxIsEmptyOID(mVPZ_ID) then begin
          try
            mInputParams := TNxParameters.Create;
            mParam := mInputParams.GetOrCreateParam(dtString, 'StoreGateWay_ID');
            mParam.AsString := cStoreGateWay_ID;
            mParam := mInputParams.GetOrCreateParam(dtString,'DocQueue_ID');
            mParam.AsString := cLogStoreDocQueue_ID;
            mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
            mParam.AsString := self.OID;
            mParam := mInputParams.GetOrCreateParam(dtBoolean, 'AutoPrefillPosition');
            mParam.AsBoolean := True;
            mParam := mInputParams.GetOrCreateParam(dtInteger, 'PrefillType');
            mParam.AsInteger := 0;
            mImportMan := NxCreateDocumentImportManager(self.ObjectSpace, Class_BillOfDelivery, Class_LogStoreOutput);
            mImportMan.AddInputDocument(self.oid);
            mImportMan.LoadParams(mInputParams);
            mImportMan.Execute;
            mImportMan.OutputDocument.Save;
            mImportMan.free;
          except
            //NxShowSimpleMessage(ExceptionMessage,nil);
          end;
     end;
  end;
  if (self.GetFieldValueAsString('DocQueue_ID')='U200000101') and (osNew in self.State) then begin
      mVPZ_ID:=self.ObjectSpace.SQLSelectFirstAsString('Select id from logstoredocuments where storedocument_id='+Quotedstr(self.OID),'');
      if NxIsEmptyOID(mVPZ_ID) then begin
          try
            mInputParams := TNxParameters.Create;
            mParam := mInputParams.GetOrCreateParam(dtString, 'StoreGateWay_ID');
            mParam.AsString := cStoreGateWay_ID;
            mParam := mInputParams.GetOrCreateParam(dtString,'DocQueue_ID');
            mParam.AsString := cLogStoreDocQueue_ID;
            mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
            mParam.AsString := self.OID;
            mParam := mInputParams.GetOrCreateParam(dtBoolean, 'AutoPrefillPosition');
            mParam.AsBoolean := True;
            mParam := mInputParams.GetOrCreateParam(dtInteger, 'PrefillType');
            mParam.AsInteger := 0;
            mImportMan := NxCreateDocumentImportManager(self.ObjectSpace, Class_BillOfDelivery, Class_LogStoreOutput);
            mImportMan.AddInputDocument(self.oid);
            mImportMan.LoadParams(mInputParams);
            mImportMan.Execute;
            mImportMan.OutputDocument.Save;
            mImportMan.free;
          except
            NxShowSimpleMessage(ExceptionMessage,nil);
          end;
     end;
  end;
end;

begin
end.