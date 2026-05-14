procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mImportMan:TNxDocumentImportManager;
 mInputParams:TNxParameters;
 mParam:TNxParameter;
 mDestStore_ID, mIncomingTransfer_ID:String;
 mIncomingTransferBO:TNxCustomBusinessObject;
begin
  if (self.GetFieldValueAsString('DocQueue_ID')='N000000101') then begin
   if self.GetFieldValueAsString('PMState_ID')='SDDEF00000' then begin
    try
       mDestStore_ID:=self.ObjectSpace.SQLSelectFirstAsString('Select id from stores where id='+QuotedStr(self.GetFieldValueAsString('U_DestinationStore')),'');
       if not(NxIsEmptyOID(mDestStore_ID)) then begin
                      mInputParams := TNxParameters.Create;
                      mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                      mParam.AsString := 'P000000101';
                      mParam := mInputParams.GetOrCreateParam(dtString, 'Store_ID');
                      mParam.AsString := mDestStore_ID;
                      mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
                      mParam.AsString := self.OID;
                      mImportMan:=NxCreateDocumentImportManager(self.ObjectSpace,Class_OutgoingTransfer,Class_IncomingTransfer);
                      mImportMan.AddInputDocument(Self.OID);
                      mImportMan.LoadParams(mInputParams);
                      mImportMan.Execute;
                      mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', 'P000000101');
                      mImportMan.OutputDocument.save;
                      //mImportMan.OutputDocument.PMChangeState('SDDEF00000');
                      mIncomingTransfer_ID:=mImportMan.OutputDocument.OID;
                      mImportMan.free;

                      if not(NxIsEmptyOID(mIncomingTransfer_ID)) then begin
                        mIncomingTransferBO:=self.ObjectSpace.CreateObject(Class_IncomingTransfer);
                        mIncomingTransferBO.Load(mIncomingTransfer_ID,nil);
                        mIncomingTransferBO.PMChangeState('SDDEF00000');
                        mIncomingTransferBO.free;
                      end;
       end;
    except

    end;
   end;
  end;
end;

begin
end.