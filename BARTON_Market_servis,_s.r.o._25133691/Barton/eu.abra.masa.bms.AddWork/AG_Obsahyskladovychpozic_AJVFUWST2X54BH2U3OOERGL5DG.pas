procedure InitSite_Hook(Self: TSiteForm);
var
  mAct: TBasicAction;
begin


  mAct := Self.GetNewAction;
  mAct.Caption := '##přeměna s prací##';
  mAct.Category := 'tabList';
  mAct.OnExecute := @AddWork;
end;

Procedure AddWork(Sender:TComponent);
var
 mBO:TNxCustomBusinessObject;
 mOS:TNxCustomObjectSpace;
 mList, mlog:TStringList;
 i:integer;
 mOTBO, mOTRowBO, mITRowBO, mPosRow:TNxCustomBusinessObject;
 mOTRows, mITRows, mPosRows:TNxCustomBusinessMonikerCollection;
 mSite:TSiteForm;
 mQuantity, mAvailableQ:Extended;
 mWorkSC_ID,mITBO_ID:string;
 mInputParams : TNxParameters;
 mParam: TNxParameter;
 mImportMan:TNxDocumentImportManager;
 mAbraOLE,mObject:Variant;
 mITBO:TNxHeaderBusinessObject;
begin
  mSite:=TComponent(Sender).DynSite;
  mOS:=TDynSiteForm(mSite).BaseObjectSpace;
  mList:=TStringList.Create;
  mLog:=TStringList.Create;
  TDynSiteForm(mSite).list.GetSelectedId(mList);
  mWorkSC_ID:='P1T3000101';
  if mlist.Count>0 then begin
    WaitWin.StartProgress('Čekejte, vkládám ...', '', mlist.Count);
    for i:=0 to mList.count-1 do begin
    try
          mBO:=mOS.CreateObject(Class_LogStoreContent);
          mBO.Load(mList.Strings[i],nil);
           mOTBO:=mos.CreateObject(Class_OutgoingTransformation);
           mOTBO.New;
           mOTBO.prefill;
           mOTBO.SetFieldValueAsString('Description', 'Doplnění práce k položce '+mBO.GetFieldValueAsString('StoreCard_ID.code')+' '+mBO.GetFieldValueAsString('Parent_ID.Code'));
           mOTRows:=mOTBO.GetLoadedCollectionMonikerForFieldCode(mOTBO.GetFieldCode('Rows'));
           mQuantity:=mOS.SQLSelectFirstAsExtended('Select spm2.quantity from SPMNorms spm left join SPMNorms2 spm2 on spm.id=spm2.parent_id where spm2.storecard_id='+QuotedStr(mWorkSC_ID)+
                                                   ' and spm.storecard_id='+QuotedStr(mBO.GetFieldValueAsString('StoreCard_ID')),1);

           mAvailableQ:=mbo.GetFieldValueAsFloat('Quantity');
           mOTRowBO:=mOTRows.AddNewObject;
           mOTRowBO.prefill;
           mOTRowBO.SetFieldValueAsString('Store_ID', mBO.GetFieldValueAsString('Parent_ID.Store_ID'));
           mOTRowBO.SetFieldValueAsString('StoreCard_ID',mBO.GetFieldValueAsString('StoreCard_ID'));
           mOTRowBO.SetFieldValueAsFloat('Quantity',mAvailableQ);
           mOTRowBO:=mOTRows.AddNewObject;
           mOTRowBO.prefill;
           mOTRowBO.SetFieldValueAsString('Store_ID', '1220000101');
           mOTRowBO.SetFieldValueAsString('StoreCard_ID',mWorkSC_ID);
           mOTRowBO.SetFieldValueAsFloat('Quantity',mAvailableQ*mQuantity);
           mOTBO.save;
           //polohování mOTBO
               try
                  mInputParams := TNxParameters.Create;
                  mParam := mInputParams.GetOrCreateParam(dtString, 'StoreGateWay_ID');
                  mParam.AsString := '1010000101';
                  mParam := mInputParams.GetOrCreateParam(dtString,'DocQueue_ID');
                  mParam.AsString := '2900000101';
                  mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
                  mParam.AsString := mOTBO.OID;
                  mParam := mInputParams.GetOrCreateParam(dtBoolean, 'AutoPrefillPosition');
                  mParam.AsBoolean := false;

                  mImportMan := NxCreateDocumentImportManager(mOS, Class_OutgoingTransformation, Class_LogStoreOutput);
                  mImportMan.AddInputDocument(mOTBO.oid);
                  mImportMan.LoadParams(mInputParams);
                  mImportMan.Execute;
                    mPosRows := mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
                    OutputDebugString('RowsCount: '+inttostr(mPosRows.Count));
                    for i:=0 to mPosRows.Count-1 do begin
                      mPosRow:= mPosRows.BusinessObject(i);
                      OutputDebugString('řádek: '+IntToStr(i+1)+' | ' + mPosRow.GetFieldValueAsString('StoreCard_ID.Name'));
                      mPosRow.SetFieldValueAsString('StorePosition_ID', mbo.GetFieldValueAsString('Parent_ID'));
                      mPosRow.SetFieldValueAsFloat('InPositionQuantity', mPosRow.GetFieldValueAsFloat('RestQuantity'));
                    end;
                  mImportMan.OutputDocument.Save;
                  mAbraOLE := GetAbraOLEApplication;
                  mObject := mAbraOLE.CreateObject(Class_LogStoreOutput);
                  try
                    mObject.MakeExecuted(mImportMan.OutputDocument.OID);
                  except
                    NxShowSimpleMessage('Nepovedlo se provést doklad',nil);
                  end;
                  mImportMan.free;
                except
                  NxShowSimpleMessage(ExceptionMessage,nil);
                end;
           //konec polohování
           //tvorba mITBO
               mInputParams := TNxParameters.Create;
               mParam :=  mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
               mParam.AsString := 'UB00000101';
               mImportMan := NxCreateDocumentImportManager(msite.BaseObjectSpace, Class_OutgoingTransformation, Class_IncomingTransformation);
               try
                  mImportMan.AddInputDocument(mOTBO.OID);
                  mImportMan.LoadParams(mInputParams);
                  mImportMan.Execute;
                  mImportMan.CheckOutputDocument;
                  if Assigned(mImportMan.OutputDocument) then begin
                    mITBO:=TNxHeaderBusinessObject(mImportMan.OutputDocument);
                    mITBO.SetFieldValueAsString('DocQueue_ID', 'UB00000101'); // musi byt...
                    mITBO.SetFieldValueAsInteger('AutoFillRowsPriceTransCoef',0);
                    mITRows:=mitbo.rows;
                    mITRows.DeleteAll;
                    mITRowBO:=mITRows.AddNewObject;
                    mITRowBO.Prefill;
                    mITRowBO.SetFieldValueAsString('Store_ID', mBO.GetFieldValueAsString('Parent_ID.Store_ID'));
                    mITRowBO.SetFieldValueAsString('StoreCard_ID',mBO.GetFieldValueAsString('StoreCard_ID'));
                    mITRowBO.SetFieldValueAsFloat('Quantity',mAvailableQ);
                    mITRowBO.SetFieldValueAsFloat('PercentPriceTransformationCoef',100);
                  end;
                  mImportMan.OutputDocument.save;
                  mITBO_ID:=mImportMan.OutputDocument.OID;
                  mImportMan.Free;
                    mInputParams := TNxParameters.Create;
                    mParam := mInputParams.GetOrCreateParam(dtString, 'StoreGateWay_ID');
                    mParam.AsString := '2010000101';
                    mParam := mInputParams.GetOrCreateParam(dtString,'DocQueue_ID');
                    mParam.AsString := '1900000101';
                    mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
                    mParam.AsString := mITBO_ID;
                    mParam := mInputParams.GetOrCreateParam(dtBoolean, 'AutoPrefillPosition');
                    mParam.AsBoolean := False;

                    mImportMan := NxCreateDocumentImportManager(mOS, Class_IncomingTransformation, Class_LogStoreInput);
                    mImportMan.AddInputDocument(mITBO_ID);
                    mImportMan.LoadParams(mInputParams);
                    mImportMan.Execute;
                    OutputDebugString('After importmanager execute');
                    mPosRows := mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
                    OutputDebugString('RowsCount: '+inttostr(mPosRows.Count));
                    for i:=0 to mPosRows.Count-1 do begin
                      mPosRow:= mPosRows.BusinessObject(i);
                      OutputDebugString('řádek: '+IntToStr(i+1)+' | ' + mPosRow.GetFieldValueAsString('StoreCard_ID.Name'));
                      mPosRow.SetFieldValueAsString('StorePosition_ID', mbo.GetFieldValueAsString('Parent_ID'));
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


               except
                 NxShowSimpleMessage(ExceptionMessage,nil);
               end;

          mbo.free;
       except
        mlog.add(DateTimeToStr(now)+#13#10+#13#10+ExceptionMessage);
       end;
    WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(mlist.Count));
    WaitWin.StepIt;
    end;
   WaitWin.stop;
   CFxLog.SaveLog(NxCreateContext(mOS),'LOGIE','chyba addwork',mlog.Text,2,Now)
  end;
end;

begin
end.