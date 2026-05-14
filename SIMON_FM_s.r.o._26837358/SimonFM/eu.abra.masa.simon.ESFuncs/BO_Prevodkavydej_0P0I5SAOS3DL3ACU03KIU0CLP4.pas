const
  cLogStoreDocQueue_ID = '6RE0000101';
  cStoreGateWay_ID = '1000000101';

procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mImportMan:TNxDocumentImportManager;
 mInputParams:TNxParameters;
 mParam:TNxParameter;
 mDestStore_ID, mIT_ID, mNPZ_ID:String;
 mRows:TNxCustomBusinessMonikerCollection;
 i:integer;
 mAbraOLE,mObject:Variant;
 mITBO:TNxCustomBusinessObject;
begin
// inteligentně napsat pro přesun po Save vyřízené Převodky výdej
  if (self.GetFieldValueAsString('DocQueue_ID')='6RC0000101') then begin    //vyřízené PVES
   if self.GetFieldValueAsString('PMState_ID')='SDDEF00000' then begin
    try
       mDestStore_ID:=self.ObjectSpace.SQLSelectFirstAsString('Select id from stores where id='+QuotedStr(self.GetFieldValueAsString('U_DestinationStore')),'');
       if not(NxIsEmptyOID(mDestStore_ID)) and (mDestStore_ID in ['2D00000101','1E00000101']) then begin
                      mInputParams := TNxParameters.Create;
                      mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                      mParam.AsString := '7RB0000101';                                                    //PPCT
                      mParam := mInputParams.GetOrCreateParam(dtString, 'Store_ID');
                      mParam.AsString := mDestStore_ID;
                      mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
                      mParam.AsString := self.OID;
                      mImportMan:=NxCreateDocumentImportManager(self.ObjectSpace,Class_OutgoingTransfer,Class_IncomingTransfer);
                      mImportMan.AddInputDocument(Self.OID);
                      mImportMan.LoadParams(mInputParams);
                      mImportMan.Execute;
                      mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', '7RB0000101');
                      mImportMan.OutputDocument.save;
                      self.ObjectSpace.SQLExecute('update storedocuments set pmstate_id='+QuotedStr('2000000001')+' where id='+QuotedStr(mImportMan.OutputDocument.OID));
                      mImportMan.free;
       end;
       if not(NxIsEmptyOID(mDestStore_ID)) and (mDestStore_ID='4P00000101') then begin
                      mInputParams := TNxParameters.Create;
                      mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                      mParam.AsString := 'X200000101';                                                    //PP03
                      mParam := mInputParams.GetOrCreateParam(dtString, 'Store_ID');
                      mParam.AsString := mDestStore_ID;
                      mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
                      mParam.AsString := self.OID;
                      mImportMan:=NxCreateDocumentImportManager(self.ObjectSpace,Class_OutgoingTransfer,Class_IncomingTransfer);
                      mImportMan.AddInputDocument(Self.OID);
                      mImportMan.LoadParams(mInputParams);
                      mImportMan.Execute;
                      mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', 'X200000101');
                      mImportMan.OutputDocument.save;
                      mIT_ID:=mImportMan.OutputDocument.OID;
                      self.ObjectSpace.SQLExecute('update storedocuments set pmstate_id='+QuotedStr('2000000001')+' where id='+QuotedStr(mImportMan.OutputDocument.OID));
                      //mImportMan.free;
                      //NxShowSimpleMessage('jdu dělat polohy',nil);
                        mNPZ_ID:=self.ObjectSpace.SQLSelectFirstAsString('Select id from logstoredocuments where storedocument_id='+Quotedstr(mIT_ID),'');
                        //NxShowSimpleMessage('jdu dělat polohy ID: '+mNPZ_ID,nil);
                        if NxIsEmptyOID(mNPZ_ID) then begin
                            try
                              mInputParams := TNxParameters.Create;
                              mParam := mInputParams.GetOrCreateParam(dtString, 'StoreGateWay_ID');
                              mParam.AsString := cStoreGateWay_ID;
                              mParam := mInputParams.GetOrCreateParam(dtString,'DocQueue_ID');
                              mParam.AsString := cLogStoreDocQueue_ID;
                              mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
                              mParam.AsString := mIT_ID;
                              mParam := mInputParams.GetOrCreateParam(dtBoolean, 'AutoPrefillPosition');
                              mParam.AsBoolean := True;
                              mParam := mInputParams.GetOrCreateParam(dtInteger, 'PrefillType');
                              mParam.AsInteger := 0;
                              mImportMan := NxCreateDocumentImportManager(self.ObjectSpace, Class_IncomingTransfer, Class_LogStoreInput);
                              mImportMan.AddInputDocument(mIT_ID);
                              mImportMan.LoadParams(mInputParams);
                              mImportMan.Execute;
                              mRows:=mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
                              for i:=0 to mrows.Count-1 do begin
                                mRows.BusinessObject[i].SetFieldValueAsString('StorePosition_ID','5060000101');
                              end;
                              mImportMan.OutputDocument.Save;
                              //provedeni NPZ na skladu VO
                              {mAbraOLE := GetAbraOLEApplication;
                              mObject := mAbraOLE.CreateObject(Class_LogStoreInput);
                              try
                                mObject.MakeExecuted(mImportMan.OutputDocument.OID);
                              finally
                                mObject := nil;
                              end;
                              mImportMan.free;
                              mITBO := self.ObjectSpace.CreateObject(Class_IncomingTransfer);
                              mITBO.Load(mIT_ID,nil);
                              mITBO.SetFieldValueAsString('PMState_ID','SDDEF00000');
                              mITBO.save;
                              mITBO.free; }
                            except
                              NxShowSimpleMessage(ExceptionMessage,nil);
                            end;
                       end;
       end;
    except

    end;
   end;
  end;
  if (self.GetFieldValueAsString('DocQueue_ID')='Z200000101') then begin    //vyřízené PV03
   if self.GetFieldValueAsString('PMState_ID')='SDDEF00000' then begin
    try
       mDestStore_ID:=self.ObjectSpace.SQLSelectFirstAsString('Select id from stores where id='+QuotedStr(self.GetFieldValueAsString('U_DestinationStore')),'');
        if not(NxIsEmptyOID(mDestStore_ID)) and (mDestStore_ID in ['2D00000101','1E00000101']) then begin
                      mInputParams := TNxParameters.Create;
                      mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                      mParam.AsString := '7RB0000101';                                                    //PP03
                      mParam := mInputParams.GetOrCreateParam(dtString, 'Store_ID');
                      mParam.AsString := mDestStore_ID;
                      mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
                      mParam.AsString := self.OID;
                      mImportMan:=NxCreateDocumentImportManager(self.ObjectSpace,Class_OutgoingTransfer,Class_IncomingTransfer);
                      mImportMan.AddInputDocument(Self.OID);
                      mImportMan.LoadParams(mInputParams);
                      mImportMan.Execute;
                      mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', '7RB0000101');
                      mImportMan.OutputDocument.SetFieldValueAsString('PMState_ID','SDDEF00000');
                      mImportMan.OutputDocument.save;
                      mIT_ID:=mImportMan.OutputDocument.OID;
         end;
         if not(NxIsEmptyOID(mDestStore_ID)) and (mDestStore_ID='1L00000101') then begin
                      mInputParams := TNxParameters.Create;
                      mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                      mParam.AsString := '7RC0000101';                                                    //PPEs
                      mParam := mInputParams.GetOrCreateParam(dtString, 'Store_ID');
                      mParam.AsString := mDestStore_ID;
                      mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
                      mParam.AsString := self.OID;
                      mImportMan:=NxCreateDocumentImportManager(self.ObjectSpace,Class_OutgoingTransfer,Class_IncomingTransfer);
                      mImportMan.AddInputDocument(Self.OID);
                      mImportMan.LoadParams(mInputParams);
                      mImportMan.Execute;
                      mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', '7RC0000101');
                      mImportMan.OutputDocument.save;
                      mIT_ID:=mImportMan.OutputDocument.OID;
                      self.ObjectSpace.SQLExecute('update storedocuments set pmstate_id='+QuotedStr('2000000001')+' where id='+QuotedStr(mImportMan.OutputDocument.OID));
                      //mImportMan.free;
                      //NxShowSimpleMessage('jdu dělat polohy',nil);
                        mNPZ_ID:=self.ObjectSpace.SQLSelectFirstAsString('Select id from logstoredocuments where storedocument_id='+Quotedstr(mIT_ID),'');
                        //NxShowSimpleMessage('jdu dělat polohy ID: '+mNPZ_ID,nil);
                        if NxIsEmptyOID(mNPZ_ID) then begin
                            try
                              mInputParams := TNxParameters.Create;
                              mParam := mInputParams.GetOrCreateParam(dtString, 'StoreGateWay_ID');
                              mParam.AsString := cStoreGateWay_ID;
                              mParam := mInputParams.GetOrCreateParam(dtString,'DocQueue_ID');
                              mParam.AsString := cLogStoreDocQueue_ID;
                              mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
                              mParam.AsString := mIT_ID;
                              mParam := mInputParams.GetOrCreateParam(dtBoolean, 'AutoPrefillPosition');
                              mParam.AsBoolean := True;
                              mParam := mInputParams.GetOrCreateParam(dtInteger, 'PrefillType');
                              mParam.AsInteger := 0;
                              mImportMan := NxCreateDocumentImportManager(self.ObjectSpace, Class_IncomingTransfer, Class_LogStoreInput);
                              mImportMan.AddInputDocument(mIT_ID);
                              mImportMan.LoadParams(mInputParams);
                              mImportMan.Execute;
                              mRows:=mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
                              for i:=0 to mrows.Count-1 do begin
                                mRows.BusinessObject[i].SetFieldValueAsString('StorePosition_ID','3010000101');
                              end;
                              mImportMan.OutputDocument.Save;
                              //provedeni NPZ na skladu VO
                              {mAbraOLE := GetAbraOLEApplication;
                              mObject := mAbraOLE.CreateObject(Class_LogStoreInput);
                              try
                                mObject.MakeExecuted(mImportMan.OutputDocument.OID);
                              finally
                                mObject := nil;
                              end;
                              mImportMan.free;
                              mITBO := self.ObjectSpace.CreateObject(Class_IncomingTransfer);
                              mITBO.Load(mIT_ID,nil);
                              mITBO.SetFieldValueAsString('PMState_ID','SDDEF00000');
                              mITBO.save;
                              mITBO.free;}
                            except
                              //NxShowSimpleMessage(ExceptionMessage,nil);
                            end;
                       end;
       end;
    except

    end;
   end;
  end;
  if (self.GetFieldValueAsString('DocQueue_ID')='6RB0000101') then begin    //vyřízené PVCT
   if self.GetFieldValueAsString('PMState_ID')='SDDEF00000' then begin
    try
       mDestStore_ID:=self.ObjectSpace.SQLSelectFirstAsString('Select id from stores where id='+QuotedStr(self.GetFieldValueAsString('U_DestinationStore')),'');
        if not(NxIsEmptyOID(mDestStore_ID)) and (mDestStore_ID='4P00000101') then begin
                      mInputParams := TNxParameters.Create;
                      mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                      mParam.AsString := 'X200000101';                                                    //PP03
                      mParam := mInputParams.GetOrCreateParam(dtString, 'Store_ID');
                      mParam.AsString := mDestStore_ID;
                      mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
                      mParam.AsString := self.OID;
                      mImportMan:=NxCreateDocumentImportManager(self.ObjectSpace,Class_OutgoingTransfer,Class_IncomingTransfer);
                      mImportMan.AddInputDocument(Self.OID);
                      mImportMan.LoadParams(mInputParams);
                      mImportMan.Execute;
                      mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', 'X200000101');
                      mImportMan.OutputDocument.save;
                      mIT_ID:=mImportMan.OutputDocument.OID;
                      //self.ObjectSpace.SQLExecute('update storedocuments set pmstate_id='+QuotedStr('2000000001')+' where id='+QuotedStr(mImportMan.OutputDocument.OID));
                      //mImportMan.free;
                      //NxShowSimpleMessage('jdu dělat polohy',nil);
                        mNPZ_ID:=self.ObjectSpace.SQLSelectFirstAsString('Select id from logstoredocuments where storedocument_id='+Quotedstr(mIT_ID),'');
                        //NxShowSimpleMessage('jdu dělat polohy ID: '+mNPZ_ID,nil);
                        if NxIsEmptyOID(mNPZ_ID) then begin
                            try
                              mInputParams := TNxParameters.Create;
                              mParam := mInputParams.GetOrCreateParam(dtString, 'StoreGateWay_ID');
                              mParam.AsString := cStoreGateWay_ID;
                              mParam := mInputParams.GetOrCreateParam(dtString,'DocQueue_ID');
                              mParam.AsString := cLogStoreDocQueue_ID;
                              mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
                              mParam.AsString := mIT_ID;
                              mParam := mInputParams.GetOrCreateParam(dtBoolean, 'AutoPrefillPosition');
                              mParam.AsBoolean := True;
                              mParam := mInputParams.GetOrCreateParam(dtInteger, 'PrefillType');
                              mParam.AsInteger := 0;
                              mImportMan := NxCreateDocumentImportManager(self.ObjectSpace, Class_IncomingTransfer, Class_LogStoreInput);
                              mImportMan.AddInputDocument(mIT_ID);
                              mImportMan.LoadParams(mInputParams);
                              mImportMan.Execute;
                              mRows:=mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
                              for i:=0 to mrows.Count-1 do begin
                                mRows.BusinessObject[i].SetFieldValueAsString('StorePosition_ID','5060000101');
                              end;
                              mImportMan.OutputDocument.Save;
                              //provedeni NPZ na skladu VO
                              mAbraOLE := GetAbraOLEApplication;
                              mObject := mAbraOLE.CreateObject(Class_LogStoreInput);
                              try
                                mObject.MakeExecuted(mImportMan.OutputDocument.OID);
                              finally
                                mObject := nil;
                              end;
                              mImportMan.free;
                              mITBO := self.ObjectSpace.CreateObject(Class_IncomingTransfer);
                              mITBO.Load(mIT_ID,nil);
                              mITBO.SetFieldValueAsString('PMState_ID','SDDEF00000');
                              mITBO.save;
                              mITBO.free;
                            except
                              NxShowSimpleMessage(ExceptionMessage,nil);
                            end;
                       end;
       end;
      if not(NxIsEmptyOID(mDestStore_ID)) and (mDestStore_ID='1L00000101') then begin
                      mInputParams := TNxParameters.Create;
                      mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                      mParam.AsString := '7RC0000101';                                                    //PPEs
                      mParam := mInputParams.GetOrCreateParam(dtString, 'Store_ID');
                      mParam.AsString := mDestStore_ID;
                      mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
                      mParam.AsString := self.OID;
                      mImportMan:=NxCreateDocumentImportManager(self.ObjectSpace,Class_OutgoingTransfer,Class_IncomingTransfer);
                      mImportMan.AddInputDocument(Self.OID);
                      mImportMan.LoadParams(mInputParams);
                      mImportMan.Execute;
                      mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', '7RC0000101');
                      mImportMan.OutputDocument.save;
                      mIT_ID:=mImportMan.OutputDocument.OID;
                      self.ObjectSpace.SQLExecute('update storedocuments set pmstate_id='+QuotedStr('2000000001')+' where id='+QuotedStr(mImportMan.OutputDocument.OID));
                      //mImportMan.free;
                      //NxShowSimpleMessage('jdu dělat polohy',nil);
                        mNPZ_ID:=self.ObjectSpace.SQLSelectFirstAsString('Select id from logstoredocuments where storedocument_id='+Quotedstr(mIT_ID),'');
                        //NxShowSimpleMessage('jdu dělat polohy ID: '+mNPZ_ID,nil);
                        if NxIsEmptyOID(mNPZ_ID) then begin
                            try
                              mInputParams := TNxParameters.Create;
                              mParam := mInputParams.GetOrCreateParam(dtString, 'StoreGateWay_ID');
                              mParam.AsString := cStoreGateWay_ID;
                              mParam := mInputParams.GetOrCreateParam(dtString,'DocQueue_ID');
                              mParam.AsString := cLogStoreDocQueue_ID;
                              mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
                              mParam.AsString := mIT_ID;
                              mParam := mInputParams.GetOrCreateParam(dtBoolean, 'AutoPrefillPosition');
                              mParam.AsBoolean := True;
                              mParam := mInputParams.GetOrCreateParam(dtInteger, 'PrefillType');
                              mParam.AsInteger := 0;
                              mImportMan := NxCreateDocumentImportManager(self.ObjectSpace, Class_IncomingTransfer, Class_LogStoreInput);
                              mImportMan.AddInputDocument(mIT_ID);
                              mImportMan.LoadParams(mInputParams);
                              mImportMan.Execute;
                              mRows:=mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
                              for i:=0 to mrows.Count-1 do begin
                                mRows.BusinessObject[i].SetFieldValueAsString('StorePosition_ID','3010000101');
                              end;
                              mImportMan.OutputDocument.Save;
                              //provedeni NPZ na skladu VO
                              {mAbraOLE := GetAbraOLEApplication;
                              mObject := mAbraOLE.CreateObject(Class_LogStoreInput);
                              try
                                mObject.MakeExecuted(mImportMan.OutputDocument.OID);
                              finally
                                mObject := nil;
                              end;
                              mImportMan.free;
                              mITBO := self.ObjectSpace.CreateObject(Class_IncomingTransfer);
                              mITBO.Load(mIT_ID,nil);
                              mITBO.SetFieldValueAsString('PMState_ID','SDDEF00000');
                              mITBO.save;
                              mITBO.free;}
                            except
                              //NxShowSimpleMessage(ExceptionMessage,nil);
                            end;
                       end;
       end;
    except

    end;
   end;
  end;
end;

begin
end.