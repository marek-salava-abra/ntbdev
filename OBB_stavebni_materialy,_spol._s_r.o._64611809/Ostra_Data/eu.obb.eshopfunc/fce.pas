uses 'eu.obb.eshopfunc.lib';

Function CreateTransferFromICN(var aBO:TNxCustomBusinessObject;):string;
var
 mRows, mOTRows, mITRows:TNxCustomBusinessMonikerCollection;
 mOTBO, mOTRowBO, mRowBO, mOrderBO, mUserXLink:TNxCustomBusinessObject;
 i:integer;
 mOS:TNxCustomObjectSpace;
 mContext:TNxContext;
 mOT_ID, mOrder_ID:string;
 mInputParams:TNxParameters;
 mParam:TNxParameter;
 mImportMan:TNxDocumentImportManager;
 mCode, mDestStoreDR_ID, mStore_ID, mDQ_ID, mDivision_ID:string;
 mTransferOut, mTransferIN:string;
begin
     try
       mContext:=NxCreateNotLoggedContext(aBO.ObjectSpace);
       mContext.LogOn('Josef Novák','XDQcJZwc2SKRfZ1epob8');
       mOS:= mContext.GetObjectSpace;
       mOrder_ID:=GetOrderFromICN_ID(mOS,abo.oid);
       if not(NxIsEmptyOID(mOrder_ID)) then begin
         mOrderBO:=mOS.CreateObject(Class_ReceivedOrder);
         mOrderBO.Load(mOrder_ID,nil);
         mCode:=mOrderBO.GetFieldValueAsString('X_StockNumber');
         mDestStoreDR_ID:=GetDestStore_ID(mOS,mCode);
         mStore_ID:=GetStore_ID(mOS, mCode);
         mDQ_ID:=GetITDQ_ID(mOS,'SP'+mCode);
         mDivision_ID:=GetDivision_ID(mOS,mCode);
       end;
       mRows:=abo.GetLoadedCollectionMonikerForFieldCode(abo.GetFieldCode('Rows'));
       mOTBO:=mOS.CreateObject(Class_OutgoingTransfer);
       mOTBO.new;
       mOTBO.prefill;
       mOTBO.SetFieldValueAsString('DocQueue_ID','#00000080M');  //#### řada SV97 upraveno
       mOTBO.SetFieldValueAsString('Firm_ID','1IA0000101');
       mOTBO.SetFieldValueAsString('Createdby_ID',NxGetActualUserID_1(aBO));
       mOTBO.SetFieldValueAsString('U_Destination_Store',mDestStoreDR_ID);
       mOTBO.SetFieldValueAsString('Description',mOrderBO.DisplayName+' '+mOrderBO.GetFieldValueAsString('Externalnumber'));
       mOTRows:=mOTBO.GetLoadedCollectionMonikerForFieldCode(mOTBO.GetFieldCode('Rows'));
       for i:=0 to mRows.count-1 do begin
         mRowBO:=mRows.BusinessObject[i];
         if mRowBO.GetFieldValueAsInteger('RowType')=3 then begin
           if not(mRowBO.GetFieldValueAsString('StoreCard_ID.StoreAssortmentGroup_ID') in ['U300000101']) then begin
               mOTRowBO:=mOTRows.AddNewObject;
               mOTRowBO.Prefill;
               mOTRowBO.SetFieldValueAsString('Store_ID',mRowBO.GetFieldValueAsString('Store_ID'));
               mOTRowBO.SetFieldValueAsString('StoreCard_ID',mRowBO.GetFieldValueAsString('StoreCard_ID'));
               mOTRowBO.SetFieldValueAsFloat('Quantity',mRowBO.GetFieldValueAsFloat('Quantity'));
               mOTRowBO.SetFieldValueAsString('QUnit',mRowBO.GetFieldValueAsString('QUnit'));
               mOTRowBO.SetFieldValueAsString('Division_ID',mRowBO.GetFieldValueAsString('Division_ID'));
               mOTRowBO.SetFieldValueAsString('BusOrder_ID',mRowBO.GetFieldValueAsString('BusOrder_ID'));
               mOTRowBO.SetFieldValueAsString('BusTransaction_ID',mRowBO.GetFieldValueAsString('BusTransaction_ID'));
           end;
         end;
       end;
       mOTBO.SetFieldValueAsString('X_DocumentID',aBO.OID);
       mOTBO.save;
       mOT_ID:=mOTBO.OID;
       mTransferOut:=mOTBO.DisplayName;
       //mOTBO.free;
       try

        mInputParams := TNxParameters.Create;
        mParam :=  mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
        mParam.AsString := mDQ_ID;
        mParam :=  mInputParams.GetOrCreateParam(dtString, 'Store_ID');
        mParam.AsString := mStore_ID;
        mImportMan := NxCreateDocumentImportManager(mOS, Class_OutgoingTransfer, Class_IncomingTransfer);
        mImportMan.AddInputDocument(mOT_ID);
        mImportMan.LoadParams(mInputParams);
        mImportMan.Execute;
        mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID',mDQ_ID);
        mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID','1IA0000101');
        mImportMan.OutputDocument.SetFieldValueAsString('Createdby_ID',NxGetActualUserID_1(aBO));
        mImportMan.OutputDocument.SetFieldValueAsString('Description',mOTBO.GetFieldValueAsString('Description'));
        mImportMan.OutputDocument.SetFieldValueAsString('X_DocumentID',mOrderBO.OID);
        mITRows:=mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
        for i:=0 to mITRows.count-1 do begin
          mITrows.BusinessObject[i].SetFieldValueAsString('Division_ID',mDivision_ID);
        end;
        mImportMan.OutputDocument.save;
        mTransferIN:=mImportMan.OutputDocument.DisplayName;
        mUserXLink := mOS.CreateObject(Class_UserXLink);
      try
        mUserXLink.New;
        mUserXLink.Prefill;
        mUserXLink.SetFieldValueAsString('SourceCLSID', Class_ReceivedOrder);
        mUserXLink.SetFieldValueAsString('Source_ID', mOrderBO.OID);
        mUserXLink.SetFieldValueAsString('DestinationCLSID', Class_OutgoingTransfer);
        mUserXLink.SetFieldValueAsString('Destination_ID', mOT_ID);
        mUserXLink.SetFieldValueAsBoolean('DisplayAsSystem', True);
        mUserXLink.Save;
        mUserXLink.New;
        mUserXLink.Prefill;
        mUserXLink.SetFieldValueAsString('SourceCLSID', Class_ReceivedOrder);
        mUserXLink.SetFieldValueAsString('Source_ID', mOrderBO.OID);
        mUserXLink.SetFieldValueAsString('DestinationCLSID', Class_IncomingTransfer);
        mUserXLink.SetFieldValueAsString('Destination_ID', mImportMan.OutputDocument.OID);
        mUserXLink.SetFieldValueAsBoolean('DisplayAsSystem', True);
        mUserXLink.Save;
      finally
        mUserXLink.Free;
      end;
        mContext.free;
      finally
        NxShowSimpleMessage('Založeny doklady '+mTransferOut+' a '+mTransferIN,nil);
      end;
    except
      NxShowSimpleMessage('Nepovedla se tvorba převodky z DEUS na OBB. '+#13#10+ExceptionMessage,nil);
    end;
end;


begin
end.