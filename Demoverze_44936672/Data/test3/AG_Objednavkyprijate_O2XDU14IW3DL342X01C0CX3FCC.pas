procedure FormCreate_Hook(Self: TSiteForm);

var
  mAction: TAction;
begin

    mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := 'CreateDoc';
    mAction.Hint := 'pokus';
    mAction.Category := 'tabList';
    mAction.OnExecute := @CreateDoc;
end;

Procedure CreateDoc(Sender:TComponent);
var
 mSite:TSiteForm;
 mReceivedOrderBO:TNxCustomBusinessObject;
 mImportMan: TNxDocumentImportManager;
 mInputParams: TNxParameters;
 mParam: TNxParameter;
 mOS:TNxCustomObjectSpace;
 mRows:TNxCustomBusinessMonikerCollection;
 mRowBO:TNxCustomBusinessObject;
 i,z, n:integer;
 mAvailableQty:extended;
begin
 mSite:=TComponent(Sender).DynSite;
 mReceivedOrderBO:=TDynSiteForm(mSite).CurrentObject;
 if Assigned(mReceivedOrderBO) then begin
                        mOS:=mReceivedOrderBO.ObjectSpace;
                        mInputParams := TNxParameters.Create;
                        mParam :=  mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                        mParam.AsString := 'Q600000101';
                        mParam :=  mInputParams.GetOrCreateParam(dtInteger, 'StoreQuantityKind');
                        mParam.AsInteger := 0;
                        mParam :=  mInputParams.GetOrCreateParam(dtString, 'Firm_ID');
                        mParam.AsString := mReceivedOrderBO.GetFieldValueAsString('Firm_ID');
                        mParam :=  mInputParams.GetOrCreateParam(dtString, 'FirmOffice_ID');
                        mParam.AsString := mReceivedOrderBO.GetFieldValueAsString('FirmOffice_ID');
                        mImportMan := NxCreateDocumentImportManager(mOS, Class_ReceivedOrder, Class_OutgoingTransfer);
                        mImportMan.LoadParams(mInputParams);
                        mImportMan.AddInputDocument(mReceivedOrderBO.OID);
                        mImportMan.Execute;
                        mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID','Q600000101');
                        mRows:=mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
                        for n:=0 to mRows.count-1 do begin
                           mRowBO:=mRows.BusinessObject[n];
                           mAvailableQty:=mOS.SQLSelectFirstAsExtended('Select sum(Quantity) from storesubcards where storecard_id='+QuotedStr(mRowBO.GetFieldValueAsString('StoreCard_ID'))+
                                                                       ' and store_id='+QuotedStr(mRowBO.GetFieldValueAsString('Store_ID')),0);
                           if not(mAvailableQty>0) then begin
                             mRowBO.MarkForDelete;
                           end else begin
                              if mAvailableQty<mRowBO.GetFieldValueAsFloat('Quantity') then mRowBO.SetFieldValueAsFloat('Quantity',mAvailableQty);
                           end;
                        end;
                        mImportMan.OutputDocument.save;
 end;
end;

function GetAvailableQTY(Self: TNxCustomObjectSpace; StoreID, StoreCardID: String):Extended;
var
  mSCList, mStores: TStringList;
  mAQtyList: array of double;
begin
  Result := 0;
  mSCList := TStringList.Create;
  mStores := TStringList.Create;
  try
    mSCList.Clear;
    mSCList.Add(StoreCardID);
    mStores.Add(StoreID);
    NxGetAvailableQuantity(Self,mSCList,mStores,Today,True,mAQtyList);
    Result := mAQtyList[0];
  finally
    mSCList.free;
    mStores.free;
  end;
end;

begin
end.