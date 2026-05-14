procedure BeforeAnalyzeInputRow_Hook(AContext: TNxContext; aDocument: TNxCustomBusinessObject; aMode: byte; aInputRow: string);
const
mprevodkavydej='9RN0000101';
mprevodkaprijem='ARN0000101';

var
  mQ : TStringList;
mSourceStore_ID, mDestinationStore_id, mStoreCard_ID, mStoreBatch_ID,mprevodkavydej_ID: string;
mprevodkarows, mprevodkarowsSN: TNxCustomBusinessMonikerCollection;
mPrevodkaradek, mprevodkaSN, mprevodkavydejBO: TNxCustomBusinessObject;
mImportMan: TNxDocumentImportManager;
mInputParams: TNxParameters;
mParam: TNxParameter;
mContext: TNxContext;
mOLE: TNxCustomObjectSpace;

begin

  try
    if Length(aInputRow)=8 then begin
      mQ := TStringList.Create;
      try
        aDocument.ObjectSpace.SQLSelect(Format('SELECT ssb.Store_ID FROM StoreSubBatches ssb left join StoreBatches sb on sb.id=ssb.storebatch_id  WHERE ssb.quantity=1 and sb.name=''%s'' ', [aInputRow])
                                        , mQ);
        if mQ.Count > 0 then
          mSourceStore_id := mQ.Strings[0];
          aDocument.ObjectSpace.SQLSelect(Format('SELECT sb.StoreCard_ID FROM StoreBatches sb where sb.name=''%s'' ', [aInputRow])
                                        , mQ);
        if mQ.Count > 0 then
          mStoreCard_id := mQ.Strings[0];
          aDocument.ObjectSpace.SQLSelect(Format('SELECT sb.ID FROM StoreBatches sb where sb.name=''%s'' ', [aInputRow])
                                        , mQ);
        if mQ.Count > 0 then
          mStoreBatch_id := mQ.Strings[0];
          mDestinationStore_id:=aDocument.GetMonikerForFieldCode(aDocument.GetFieldCode('Shop_ID')).BusinessObject.GetFieldValueAsString('Store_ID');
        if not(mSourceStore_ID=mDestinationStore_id) then begin
        //  aDocument.SetFieldValueAsString('Firm_id',mFirm_ID);
        mContext:=NxCreateNotLoggedContext_1(aDocument);
        mContext.LogOn('Supervisor','ropamasa');
        mOle:= mContext.GetObjectSpace;
         mprevodkavydejBO:=mContext.GetObjectSpace.CreateObject(Class_OutgoingTransfer);
                        mprevodkavydejBO.ExplicitTransaction:=False;
                        mprevodkavydejBO.New;
                        mprevodkavydejBO.Prefill;
                        mprevodkavydejBO.SetFieldValueAsString('Docqueue_id',mprevodkavydej);
                        mprevodkavydejBO.SetFieldValueAsString('Firm_id',aDocument.GetMonikerForFieldCode(aDocument.GetFieldCode('Shop_ID')).BusinessObject.GetFieldValueAsString('Firm_ID'));
                        //mprevodkavydejBO.Save;
                        mprevodkarows:=mprevodkavydejBO.GetCollectionMonikerForFieldCode(mprevodkavydejBO.GetFieldCode('rows'));
                          mPrevodkaradek:=mprevodkarows.AddNewObject;
                          mPrevodkaradek.Prefill;
                          mPrevodkaradek.SetFieldValueAsString('Store_ID', mSourceStore_ID);
                          mPrevodkaradek.SetFieldValueAsString('StoreCard_ID', mStoreCard_ID);
                          mPrevodkaradek.SetFieldValueAsFloat('Quantity',1);
                          mprevodkaradek.SetFieldValueAsString('Division_ID',aDocument.GetMonikerForFieldCode(aDocument.GetFieldCode('VirtualPos_ID')).BusinessObject.GetFieldValueAsString('Division_ID'));
                          mprevodkarowsSN:=mPrevodkaradek.GetCollectionMonikerForFieldCode(mPrevodkaradek.GetFieldCode('DocRowBatches'));
                            mprevodkaSN:=mprevodkarowsSN.AddNewObject;
                            mprevodkaSN.SetFieldValueAsBoolean('NewBatch',False);
                            mprevodkaSN.SetFieldValueAsString('StoreBatch_ID',mStoreBatch_ID);
                            mprevodkaSN.SetFieldValueAsFloat('Quantity',1);

                        mprevodkavydejBO.save;
                        mprevodkavydej_ID:=mprevodkavydejBO.OID;
                        mprevodkavydejBO.free;
                        // zavolame documentimportmanagera
                        mInputParams := TNxParameters.Create;
                        mParam :=  mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                        mParam.AsString := mprevodkaprijem;
                        mParam :=  mInputParams.GetOrCreateParam(dtString, 'Store_ID');
                        mParam.AsString := mDestinationStore_id;
                        mImportMan := NxCreateDocumentImportManager(mOLE, Class_OutgoingTransfer, Class_IncomingTransfer);
                        mImportMan.AddInputDocument(mprevodkavydej_ID);
                        mImportMan.LoadParams(mInputParams);
                        mImportMan.Execute;
                        mImportMan.OutputDocument.save;

                  mContext.free;
                end;



        //ShowMessage('Převedl jsem kartu, pípněte ji ještě jednou '+mprevodkavydej_ID);
      finally
        mQ.Free;

      end;

    end;
  except
    NxScriptingLog.WriteEvent(logError, 'AfterSearchStoreCardError_Hook: ' + ExceptionMessage);
  end;
end;

begin
end.