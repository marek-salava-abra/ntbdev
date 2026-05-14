

procedure InitSite_Hook(Self: TSiteForm);

var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.Name := 'actCreateCoop';
  mAction.Caption := 'Vytvoření Kooperace';
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Category := 'tabDetail';
  mAction.Hint := 'Vygeneruje doklady';
  mAction.OnExecute := @CreateCOOP;
end;


Procedure CreateCoop(Sender:TComponent);
var
 mSite:TSiteForm;
 mBO, mRowBO, mPLMPLBO, mPLMRowBO:TNxCustomBusinessObject;
 mRows, mPLRows:TNxCustomBusinessMonikerCollection;
 i,j:Integer;
 mList, mQuantityList:TStringList;
 mOS:TNxCustomObjectSpace;
 mOTBO, mOTRowBO,mITBO, mITRowBO, mUserXLink:TNxCustomBusinessObject;
 mOTRows, mITRows:TNxCustomBusinessMonikerCollection;
 mInputParams: TNxParameters;
 mParam: TNxParameter;
 mImportMan: TNxDocumentImportManager;
 mTotalKoef, mQuantity:Extended;
 mNotOnStock:Boolean;
 mMessage:string;
begin
 mSite:=TComponent(Sender).DynSite;
 mBO:=TDynSiteForm(mSite).CurrentObject;
 mOS:=mSite.BaseObjectSpace;
 if assigned(mBO) then begin
   Try
     mMessage:='';
     mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows'));
     //kontrola před spuštěním
       mQuantityList:=TStringList.create;
       mNotOnStock:=false;
       for i:=0 to mRows.Count-1 do begin
        mRowBO:=mRows.BusinessObject[i];
        mList:=TStringList.Create;
        mOS.SQLSelect('Select distinct(parent_id) from plmpiecelists2 where storecard_id='+QuotedStr(mRowBO.GetFieldValueAsString('StoreCard_ID')),mList);
        if mList.Count=1 then  begin
         try
             mPLMPLBO:=mOS.CreateObject(Class_PLMPieceList);
             mPLMPLBO.Load(mlist.Strings[0],nil);
             mPLRows:=mPLMPLBO.GetLoadedCollectionMonikerForFieldCode(mPLMPLBO.GetFieldCode('Rows'));
             for j:=0 to mPLRows.Count-1 do begin
               mPLMRowBO:=mPLRows.BusinessObject[j];
               mQuantity:=mOS.SQLSelectFirstAsExtended('Select quantity from storesubcards where storecard_id='+QuotedStr(mPLMRowBO.GetFieldValueAsString('StoreCard_ID'))+
                                        ' and Store_ID='+QuotedStr(mRowBO.GetFieldValueAsString('Store_ID')),0);
               if mQuantity<(mRowBO.GetFieldValueAsFloat('Quantity')*mPLMRowBO.GetFieldValueAsFloat('Quantity')) then begin
                mQuantityList.add('Karta '+mPLMRowBO.GetFieldValueAsString('StoreCard_ID.Code')+'  nemá dostatečnou zásobu pro kompletaci');
                mNotOnStock:=True;
               end;
             end;
         finally
            mPLMPLBO.free;
         end;
        end else begin
          mQuantityList.add('Karta '+mPLMRowBO.GetFieldValueAsString('StoreCard_ID.Code')+' nemá právě jeden kusovník');
        end;
       end;
     //konec kontroly
     if mQuantityList.Count>0 then begin
       for i:=0 to mQuantityList.count-1 do begin
         mMessage:=mMessage+#13#10+mQuantityList.strings[i];
       end;
       if mNotOnStock then begin
          mMessage:='Není dostatek materiálu, nejde pokračovat'+#13#10+#13#10+mMessage;
          NxShowSimpleMessage(mMessage,mSite);
          exit;
         end else begin
          mMessage:='Níže vypsané položky nemají kusovník,lze pokračovat. '+#13#10+#13#10+mMessage;
          NxShowSimpleMessage(mMessage,mSite);
       end;
     end;
     for i:=0 to mRows.Count-1 do begin
       mRowBO:=mRows.BusinessObject[i];
       mList:=TStringList.Create;
       mOS.SQLSelect('Select distinct(parent_id) from plmpiecelists2 where storecard_id='+QuotedStr(mRowBO.GetFieldValueAsString('StoreCard_ID')),mList);
       if mList.Count=1 then  begin
         try
             mOTBO:=mOS.CreateObject(Class_OutgoingTransformation);
             mOTBO.New;
             mOTBO.Prefill;
             mOTBO.SetFieldValueAsString('Firm_ID','AG21000101');
             mOTRows:=mOTBO.GetLoadedCollectionMonikerForFieldCode(mOTBO.GetFieldCode('Rows'));
             mPLMPLBO:=mOS.CreateObject(Class_PLMPieceList);
             mPLMPLBO.Load(mlist.Strings[0],nil);
             mPLRows:=mPLMPLBO.GetLoadedCollectionMonikerForFieldCode(mPLMPLBO.GetFieldCode('Rows'));
             for j:=0 to mPLRows.Count-1 do begin
               mPLMRowBO:=mPLRows.BusinessObject[j];
               mOTRowBO:=mOTRows.AddNewObject;
               mOTRowBO.Prefill;
               mOTRowBO.SetFieldValueAsString('Store_ID',mRowBO.GetFieldValueAsString('Store_ID'));
               mOTRowBO.SetFieldValueAsString('StoreCard_ID',mPLMRowBO.GetFieldValueAsString('StoreCard_ID'));
               mOTRowBO.SetFieldValueAsFloat('Quantity',mRowBO.GetFieldValueAsFloat('Quantity')*mPLMRowBO.GetFieldValueAsFloat('Quantity'));
               mOTRowBO.SetFieldValueAsString('Division_ID',mRowBO.GetFieldValueAsString('Division_ID'));
               mOTRowBO.SetFieldValueAsString('BusOrder_ID',mRowBO.GetFieldValueAsString('BusOrder_ID'));
               mOTRowBO.SetFieldValueAsString('BusTransaction_ID',mRowBO.GetFieldValueAsString('BusTransaction_ID'));
               mOTRowBO.SetFieldValueAsString('BusProject_ID',mRowBO.GetFieldValueAsString('BusProject_ID'));
             end;
             mOTBO.save;
             mUserXLink := mOS.CreateObject(Class_UserXLink);
                try
                  mUserXLink.New;
                  mUserXLink.Prefill;
                  mUserXLink.SetFieldValueAsString('SourceCLSID', Class_ReceiptCard);
                  mUserXLink.SetFieldValueAsString('Source_ID', mBO.OID);
                  mUserXLink.SetFieldValueAsString('DestinationCLSID', Class_OutgoingTransformation);
                  mUserXLink.SetFieldValueAsString('Destination_ID', mOTBO.OID);
                  mUserXLink.SetFieldValueAsBoolean('DisplayAsSystem', True);
                  mUserXLink.Save;
                finally
                  mUserXLink.Free;
                end;
                mInputParams := TNxParameters.Create;
                mParam :=  mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                mParam.AsString := '2LC0000101';
                mImportMan := NxCreateDocumentImportManager(mSite.BaseObjectSpace, Class_OutgoingTransformation, Class_IncomingTransformation);
                try
                  mTotalKoef:=100;
                  mImportMan.AddInputDocument(mOTBO.OID);
                  mImportMan.LoadParams(mInputParams);
                  mImportMan.Execute;
                  mImportMan.CheckOutputDocument;
                  if Assigned(mImportMan.OutputDocument) then begin
                    mITBO:=TNxHeaderBusinessObject(mImportMan.OutputDocument);
                    mITBO.SetFieldValueAsString('DocQueue_ID', '2LC0000101'); // musi byt...
                    mITBO.SetFieldValueAsString('Firm_ID', mOTBO.GetFieldValueAsString('Firm_ID'));
                    mITBO.SetFieldValueAsInteger('AutoFillRowsPriceTransCoef',0);
                    mITRows:=mitbo.GetLoadedCollectionMonikerForFieldCode(mITBO.GetFieldCode('Rows'));
                    mITRows.DeleteAll;
                    mITRowBO:=mITRows.AddNewObject;
                    mITRowBO.Prefill;
                    mITRowBO.SetFieldValueAsString('Store_ID',mRowBO.GetFieldValueAsString('Store_ID'));
                    mITRowBO.SetFieldValueAsString('StoreCard_ID',mPLMPLBO.GetFieldValueAsString('Storecard_ID'));
                    mITRowBO.SetFieldValueAsFloat('Quantity',mRowBO.GetFieldValueAsFloat('Quantity'));
                    mITRowBO.SetFieldValueAsFloat('PercentPriceTransformationCoef',100);
                    mITRowBO.SetFieldValueAsString('Division_ID',mRowBO.GetFieldValueAsString('Division_ID'));
                    mITRowBO.SetFieldValueAsString('BusOrder_ID',mRowBO.GetFieldValueAsString('BusOrder_ID'));
                    mITRowBO.SetFieldValueAsString('BusTransaction_ID',mRowBO.GetFieldValueAsString('BusTransaction_ID'));
                    mITRowBO.SetFieldValueAsString('BusProject_ID',mRowBO.GetFieldValueAsString('BusProject_ID'));
                    mITBO.save;
                    mUserXLink := mOS.CreateObject(Class_UserXLink);
                    try
                      mUserXLink.New;
                      mUserXLink.Prefill;
                      mUserXLink.SetFieldValueAsString('SourceCLSID', Class_ReceiptCard);
                      mUserXLink.SetFieldValueAsString('Source_ID', mBO.OID);
                      mUserXLink.SetFieldValueAsString('DestinationCLSID', Class_IncomingTransformation);
                      mUserXLink.SetFieldValueAsString('Destination_ID', mITBO.OID);
                      mUserXLink.SetFieldValueAsBoolean('DisplayAsSystem', True);
                      mUserXLink.Save;
                    finally
                      mUserXLink.Free;
                    end;
                    mITBO.Free;
                  end;
                finally


                end;
         finally
           mOTBO.free;
           mPLMPLBO.free;
         end;
       end;
       mList.free;
       NxShowSimpleMessage('Přeměny byly vytvořeny.',mSite);
     end;
   Except
     NxShowSimpleMessage('Něco se nepovedlo:'+#1310+ExceptionMessage,mSite);
   end;
 end;
end;

begin
end.