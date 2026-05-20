procedure InitSite_Hook(Self: TSiteForm);
var
  mAct: TBasicAction;
begin
  mAct := Self.GetNewAction;
  mAct.Name:='actDecompostion';
  mAct.Caption:='## ROZBALIT ##';
  mAct.Category:='tabList';
  mAct.OnExecute:=@Decomposition;
end;

Procedure Decomposition(Sender:TComponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mBO, mSCBO, mLogStoreContentBO:TNxCustomBusinessObject;
 mOTBO, mOTRowBO, mITRowBO, mPosRow, mSPMBO, mSPMRowBO, mDRBBO:TNxCustomBusinessObject;
 mOTRows, mITRows, mPosRows, mSPMRows, mDocRowBatches:TNxCustomBusinessMonikerCollection;
 mSPMNorm_ID, mLSC_ID, mITBO_ID, mBatch_ID:string;
 mQuantity, mMaxQuantity:extended;
 mOLE, mAgenda, mStrings: Variant;
 mLSCList:TStringList;
 i:Integer;
 mInputParams : TNxParameters;
 mParam: TNxParameter;
 mImportMan:TNxDocumentImportManager;
 mAbraOLE,mObject:Variant;
 mITBO:TNxHeaderBusinessObject;
begin
 mSite:=TComponent(Sender).BusRollSite;
 mOS:=TBusRollSiteForm(mSite).BaseObjectSpace;
 mSCBO:=TBusRollSiteForm(mSite).CurrentObject;
 if Assigned(mSCBO) then begin
   mSPMNorm_ID:=mOS.SQLSelectFirstAsString('Select id from spmnorms where storecard_id='+QuotedStr(mSCBO.OID),'');
   if not(NxIsEmptyOID(mSPMNorm_ID)) then begin
     mOLE:=mSite.GetAbraOLEApplication;
     mAgenda:=mOLE.GetAgenda('AJVFUWST2X54BH2U3OOERGL5DG');
     mLSCList:=TStringList.Create;
     mOS.SQLSelect('Select id from logstorecontents where storecard_id='+QuotedStr(mSCBO.OID), mLSCList);
     if mLSCList.count>0 then begin
       if mLSCList.count>1 then begin
         mStrings:=mOLE.CreateStrings;
         for i:=0 to mLSCList.count-1 do mStrings.Add(mLSCList.strings[i]);
         mLSC_ID:=mAgenda.SingleSelectFromSelected2(mStrings,'Pozice','');
       end else begin
         mLSC_ID:=mLSCList.Strings[0];
       end;
     end;
     if not(NxIsEmptyOID(mLSC_ID)) then begin
       mMaxQuantity:=mOS.SQLSelectFirstAsExtended('Select quantity from logstorecontents where id='+QuotedStr(mLSC_ID),0);
       mQuantity:=mMaxQuantity;
       if GetQuantity(mSite, mQuantity) then begin
         if (0<mQuantity) and (mQuantity<=mMaxQuantity) then begin
           mBO:=mOS.CreateObject(Class_LogStoreContent);
           mBO.Load(mLSC_ID,nil);
           mOTBO:=mos.CreateObject(Class_OutgoingTransformation);
           mOTBO.New;
           mOTBO.prefill;
           mOTBO.SetFieldValueAsString('Description', 'Rozbalení '+mSCBO.GetFieldValueAsString('Code'));
           mOTRows:=mOTBO.GetLoadedCollectionMonikerForFieldCode(mOTBO.GetFieldCode('Rows'));

           mOTRowBO:=mOTRows.AddNewObject;
           mOTRowBO.prefill;
           mOTRowBO.SetFieldValueAsString('Store_ID', mBO.GetFieldValueAsString('Parent_ID.Store_ID'));
           mOTRowBO.SetFieldValueAsString('StoreCard_ID',mBO.GetFieldValueAsString('StoreCard_ID'));
           mOTRowBO.SetFieldValueAsFloat('Quantity',mQuantity);
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
                    mITBO.SetFieldValueAsInteger('AutoFillRowsPriceTransCoef',3);
                    mITRows:=mitbo.rows;
                    mITRows.DeleteAll;
                    mSPMBO:=mOS.CreateObject(Class_SPMNorm);
                    mSPMBO.Load(mSPMNorm_ID,nil);
                    mSPMRows:=mSPMBO.GetLoadedCollectionMonikerForFieldCode(mSPMBO.GetFieldCode('Rows'));
                    for i:=0 to mSPMRows.count-1 do begin
                      mSPMRowBO:=mSPMRows.BusinessObject[i];
                      if not((AnsiLeftStr(mSPMRowBO.GetFieldValueAsString('StoreCard_ID.Code'),3)='996') or
                       (mSPMRowBO.GetFieldValueAsString('StoreCard_ID')='P1T3000101')) then begin
                       mITRowBO:=mITRows.AddNewObject;
                       mITRowBO.Prefill;
                       mITRowBO.SetFieldValueAsString('Store_ID', mBO.GetFieldValueAsString('Parent_ID.Store_ID'));
                       mITRowBO.SetFieldValueAsString('StoreCard_ID',mSPMRowBO.GetFieldValueAsString('StoreCard_ID'));
                       mITRowBO.SetFieldValueAsFloat('Quantity',mQuantity*mSPMRowBO.GetFieldValueAsFloat('Quantity'));
                       if mITRowBO.GetFieldValueAsInteger('StoreCard_ID.Category')=2 then begin
                         mDocRowBatches:=mITRowBO.GetLoadedCollectionMonikerForFieldCode(mITRowBO.GetFieldCode('DocRowBatches'));
                         mBatch_ID:=mOS.SQLSelectFirstAsString('Select id from storebatches where storecard_id='+QuotedStr(mITRowBO.GetFieldValueAsString('StoreCard_ID'))+
                                                               ' and hidden=''N'' ','');
                         mDRBBO:=mDocRowBatches.AddNewObject;
                         mDRBBO.prefill;
                         mDRBBO.SetFieldValueAsString('StoreBatch_ID', mBatch_ID);
                         mDRBBO.SetFieldValueAsFloat('Quantity', mITRowBO.GetFieldValueAsFloat('Quantity'));
                       end;
                       //mITRowBO.SetFieldValueAsFloat('PercentPriceTransformationCoef',100);
                      end;
                    end;
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
               TBusRollSiteForm(mSite).RefreshData;
               TBusRollSiteForm(mSite).DataSet.SeekID(mSCBO.OID);







         end else begin
           NxShowSimpleMessage('Nedostatečné množství na kartě a pozici.',mSite);
         end;
       end;
     end else begin
       NxShowSimpleMessage('Nebyla vybraná platná pozice, nelze rozbalit.',mSite);
     end;
   end else begin
     NxShowSimpleMessage('Karta '+mBO.DisplayName+' nemá normu pro kompletaci, nelze rozbalit.',mSite);
   end;
 end;
end;

Function GetQuantity(var ASite:TSiteForm; var aQuantity:Extended):Boolean;
var
  mLabel:TLabel;
  mNumEd:TNumEdit;
  mButOk, mButCancel : TButton;
  mResult, mCount : integer;
  mForm : TForm;
begin
  if ASite <> nil then begin
    Result:=False;
    mCount:=0;
    mForm:= TForm.Create(ASite);
    mForm.Width:= 410;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Údaje pro rozbalení:';
    mForm.OnCloseQuery:= @OnFormCloseAction;

    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Množství:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mNumEd := TNumEdit.Create(mForm);
    mNumEd.Left := 140;
    mNumEd.Top := (mCount*25)+10;
    mNumEd.Width := 80;
    mNumEd.Value := aQuantity;
    mNumEd.DecimalPlaces := 3;
    mNumEd.Parent := mForm;

    mCount:= mCount+1;

    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'OK';
    mButOk.Default := True;
    mButOk.Top := (mCount*25)+20;
    mButOk.Left := 152;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Zrušit';
    mButCancel.Top := (mCount*25)+20;
    mButCancel.Left := 220;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;
    mForm.Height:= (mCount*25)+95;

    mResult := mForm.ShowModal(ASite);
    if mResult = 1 then begin
     Result:=True;
     aQuantity:=mNumEd.value;
    end;
  end;
end;

procedure OnFormCloseAction(Sender: TObject; var Action: TCloseAction);
begin
  if Action = caHide then TForm(Sender).ModalResult := mrCancel;
end;


begin
end.