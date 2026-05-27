Const
   cDocQueue_DL_ID = 'P600000101'; //DL
   cDocQueue_VPZ_ID = '2900000101'; //VPZ
   cStoreGateway_ID = '1010000101'; // Vyskladnovací místo
   cStoreMan_ID = '5000000101'; // Skladník

   cNxSameGoodsInPositionStrategyID = '{BD31E23F-18B7-43B9-93B6-B652714090F1}';
   cNxOldestStorageStrategyID = '{37A351FA-D60D-4A98-9A58-1FD1ACAD5339}';
   cNxFreePositionsStrategyID = '{CBF7FC08-CAB3-4172-9A01-A7456BD4BC35}';
   cNxMinimumPositionsStrategyID = '{C8F75D91-DDC3-40B4-A89E-24CDCBBDD523}';
   cNxAccessibilityInputStrategyID = '{4F47491B-EAFC-4B9E-A905-45B7471C6723}';
   cNxAccessibilityOutputStrategyID = '{0881618E-DF24-4A2E-87BC-DD75BD1E3F51}';
   cNxMinimumAccessiblePositionsStrategyID = '{96BA5D26-14C5-4704-AF1A-157438752679}';
   cNxFreeNoPreferredPositionsStrategyID = '{CFF06E40-E587-4DFF-9680-880751B3F359}';

procedure CreateBOD (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList,mValidateErrors, mLogs:TStringList;
 i:integer;
 mBO:TNxCustomBusinessObject;
 mImportMan, mImportMan2:TNxDocumentImportManager;
 mInputParams, mInputParams2:TNxParameters;
 mParam:TNxParameter;
begin
  mList:=TStringList.Create;
  mLogs:=TStringList.Create;
  mValidateErrors:= TStringList.Create;
  OS.SQLSelect('SELECT A.ID FROM ReceivedOrders A WHERE (A.IsAvailableForDelivery = ''A'')  AND (a.X_FromAPI=''A'')' , mList);
  if mlist.Count>0 then begin
   for i:=0 to mList.count-1 do begin
      mBO:=OS.CreateObject(Class_ReceivedOrder);
      mBO.Load(mlist.Strings[i],nil);
            mLogs.add('Objednávka '+mbo.DisplayName);
            try
              mImportMan := NxCreateDocumentImportManager(OS, Class_ReceivedOrder, Class_BillOfDelivery);
              mImportMan.AddInputDocument(mBO.OID);
              mImportMan.SelectedHeader:= mImportMan.InputDocuments[0];
              mInputParams := TNxParameters.Create;
              mParam := mInputParams.GetOrCreateParam(dtstring,'DocQueue_ID');
              mParam.AsString:=cDocQueue_DL_ID;
              mImportMan.LoadParams(mInputParams);
              mImportMan.Execute;
              mImportMan.OutputDocument.save;
                            try
                              mValidateErrors.Clear;
                              mImportMan2 := NxCreateDocumentImportManager(OS, Class_BillOfDelivery, Class_LogStoreOutput);
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
                                 mLogs.Add(' - Vytvořen polohovací doklad:'+mImportMan2.OutputDocument.DisplayName);
                              end else begin
                                 mImportMan2.OutputDocument.GetValidateErrors(mValidateErrors);
                                 mLogs.Add(' - Polohovací doklad nebylo možné uložit, chyby:'+mValidateErrors.Text);
                              end;
                           finally
                              mImportMan2.Free;
                           end;
            except
              mLogs.add('Výjimka '+ExceptionMessage);
            end;
            mLogs.Add('Dodací list '+mImportMan.OutputDocument.DisplayName);
   end;
  end;
  Success := True;
  LogInfoStr := ''+NxCrlf+mLogs.Text;
end;

begin
end.