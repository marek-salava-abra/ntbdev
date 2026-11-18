uses 'eu.abra.mforce.fce';

{
Umožňuje ovlivnit validaci.
 }
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
begin
  if not(self.GetFieldValueAsBoolean('U_prijato_lisarem')) and (self.GetFieldValueAsString('X_Status')='2I00000101') then begin
     CreateTransfer(self,Self.OID);
     self.SetFieldValueAsBoolean('U_prijato_lisarem',true);
     AResult:=true;
  end;
end;

procedure CreateTransfer(ABO:TNxCustomBusinessObject; ReceivedOrder_ID:String);
Var
 mReceivedOrder, mOutGoingTransfer, mOTRow:TNxCustomBusinessObject;
 mOT_ID, mSourceStore_ID, mStore_ID, mLisar_ID:String;
 mOS:TNxCustomObjectSpace;
 mOTRows,MRORows:TNxCustomBusinessMonikerCollection;
 mImportMan: TNxDocumentImportManager;
 mInputParams: TNxParameters;
 mParam: TNxParameter;
 i:integer;
begin
  mOS:= ABO.ObjectSpace;
  mReceivedOrder:=mOS.CreateObject(Class_ReceivedOrder);
  mReceivedOrder.Load(ReceivedOrder_ID,nil);
  MRORows:= mReceivedOrder.GetLoadedCollectionMonikerForFieldCode(mReceivedOrder.GetFieldCode('Rows'));
  mLisar_ID:=scrGetLisar_ID(mReceivedOrder.ObjectSpace,mReceivedOrder.OID);
  mStore_ID:=scrGetStore_ID(mReceivedOrder.ObjectSpace, mLisar_ID);
  mSourceStore_ID:=scrGetSourceStore_ID(mReceivedOrder.ObjectSpace, mLisar_ID);
 if not(NxIsEmptyOID(mStore_ID)) and not(NxIsEmptyOID(ReceivedOrder_ID))  then begin
    try
    mOutGoingTransfer:=mos.CreateObject(Class_OutgoingTransfer);
    mOutGoingTransfer.New;
    mOutGoingTransfer.Prefill;
    mOutGoingTransfer.SetFieldValueAsString('Firm_ID',mReceivedOrder.GetFieldValueAsString('Firm_ID'));
    if (mSourceStore_ID='2000000101') then mOutGoingTransfer.SetFieldValueAsString('DocQueue_ID','L000000101');    //bohumín
    if (mSourceStore_ID='3000000101') then mOutGoingTransfer.SetFieldValueAsString('DocQueue_ID','B300000101');    //Praha
    mOutGoingTransfer.SetFieldValueAsString('Description', mReceivedOrder.DisplayName);
    mOTRows:=mOutGoingTransfer.GetCollectionMonikerForFieldCode(mOutGoingTransfer.GetFieldCode('Rows'));
    for i:=0 to MRORows.count-1 do begin
     if MRORows.BusinessObject[i].GetFieldValueAsInteger('RowType')=3 then begin
     mOTRow:=mOTRows.AddNewObject;
     mOTRow.SetFieldValueAsInteger('RowType',MRORows.BusinessObject[i].GetFieldValueAsInteger('RowType'));
     mOTRow.SetFieldValueAsString('Store_ID',mSourceStore_ID);
     mOTRow.SetFieldValueAsString('StoreCard_ID',MRORows.BusinessObject[i].GetFieldValueAsString('StoreCard_ID'));
     mOTRow.SetFieldValueAsFloat('Quantity',MRORows.BusinessObject[i].GetFieldValueAsFloat('Quantity'));
     mOTRow.SetFieldValueAsString('Qunit',MRORows.BusinessObject[i].GetFieldValueAsString('Qunit'));
     mOTRow.SetFieldValueAsString('Division_ID',MRORows.BusinessObject[i].GetFieldValueAsString('Division_ID'));
     mOTRow.SetFieldValueAsString('BusOrder_ID',MRORows.BusinessObject[i].GetFieldValueAsString('BusOrder_ID'));
     mOTRow.SetFieldValueAsString('BusTransaction_ID',MRORows.BusinessObject[i].GetFieldValueAsString('BusTransaction_ID'));
     mOTRow.SetFieldValueAsString('BusProject_ID',MRORows.BusinessObject[i].GetFieldValueAsString('BusProject_ID'));
     mOTRow.SetFieldValueAsString('Provide_ID',ReceivedOrder_ID);
     end;
    end;
    mOutGoingTransfer.save;
    mOT_ID:=mOutGoingTransfer.OID;
    finally
    mOutGoingTransfer.free;
    end;
  end;
  try
    mInputParams := TNxParameters.Create;
    try

      //ShowMessage(mReceiptCard.DisplayName);
      mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
      mParam.AsString := '1H10000101';
      mParam := mInputParams.GetOrCreateParam(dtString, 'Store_ID');
      mParam.AsString := mStore_ID;

      mImportMan := NxCreateDocumentImportManager(mOS, Class_OutgoingTransfer,Class_IncomingTransfer);
      try
        mImportMan.AddInputDocument(mOT_ID);
        mImportMan.LoadParams(mInputParams);
        mImportMan.Execute;
        mImportMan.CheckOutputDocument;
        if Assigned(mImportMan.OutputDocument) then begin
          mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', '1H10000101'); // musi byt...
          //mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID', mBillOfDelivery.GetFieldValueAsString('Firm_ID'));

          mImportMan.OutputDocument.Save;
          //mRefundedBillOfDelivery_ID:=mImportMan.OutputDocument.OID;
        end;
      finally
        mImportMan.Free;
      end;
    finally
      mInputParams.Free;
    end;
  except
    // Roberte - chybu poziram - event se vola opakovane, pri opakovanem volani managera na OP, ktera jiz ma DL vytvoren, manager generuje vyjimku
    //ShowMessage('Chyba DL z OP: ' + ExceptionMessage);
  end;
end;

begin
end.