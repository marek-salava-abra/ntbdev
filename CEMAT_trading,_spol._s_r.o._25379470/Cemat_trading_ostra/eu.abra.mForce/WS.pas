uses 'eu.abra.mforce.fce';

function GetOrders(Self: TNxWebServicesHelper;Worker_ID: String;Status_ID: TStringDynArray):String; 
Var
 mFileName, mSQL:STring;
 moutputlist, mResultList:TStringList;
 mContext:TNxContext;
 mOS:TNxCustomObjectSpace;
 mStatuses:String;
 mStatus:String;
 i:integer;
begin
 Result:='';
 mOS:=self.ObjectSpace;
 mResultList:=TStringList.Create;
 mOutputList:=TStringList.Create;
 mContext := NxCreateContext(mOS);
 for i:= 0 to Length(Status_ID) - 1 do begin
   mStatus:= Status_ID[i];
   if (i = 0) then mStatuses:= QuotedStr(mStatus)
         else mStatuses:=mstatuses+','+QuotedStr(mStatus);
 
 end;
  mSQL:='Select ro.id from receivedorders ro left join receivedorders2 ro2 on ro2.parent_id=ro.id where ro2.X_lisar1=''%s'' and ro.X_status in (%s) group by ro.id';
  mFileName:='c:\AbraG3\htdocs\Orders.xml';
  mos.SQLSelect(Format(mSQL,[Worker_ID, mStatuses]),mResultList);
  if mResultList.count>0 then begin
       CFxReportManager.ExportByIDs(mContext,mResultList,'40V53DORW3DL342X01C0CX3FCC','1C00000101',0,'',mFileName);
        if FileExists(mFileName) then begin
        mOutputList.Clear;
          mOutputList.LoadFromFile(mFileName);
          Result:=EncodeBase64(TEncoding.Unicode.GetBytes(mOutputList.text));
        end;
  end;
  if mResultList.Count=0 then begin
     mOutputList.Clear;
     mOutputList.LoadFromFile('c:\AbraG3\htdocs\NoOrders.xml');
     Result:=EncodeBase64(TEncoding.Unicode.GetBytes(mOutputList.text));
  
  
  end;
  DeleteFile(mFileName);
  mContext.Free;
  mResultList.Free;
  mOutputList.Free;

end;



function GetStatuses(Self: TNxWebServicesHelper):String; 
var
  mObjectSpace: TNxCustomObjectSpace;
  mIDsList, mOutputList: TStringList;
  mSQL,mExportID, mDynSource, mFileName: String;
  mContext: TNxContext;



begin
  Result:='';
  mIDsList:=TStringList.Create;
  mOutputList:=TStringList.Create;
  mObjectSpace := Self.ObjectSpace;
  mContext := NxCreateContext(mObjectSpace);
        msql:='select id from defrolldata where clsid=''U0FCEIJNJBDOP3BCFCVUWZ3ADS'' and hidden=''N'' and code like ''m%''';
      mExportID:='1F00000101';
      mFileName:='c:\AbraG3\htdocs\Statuses.xml';
      mDynSource:='EUKJM42OC5SOL4553ORHUQ3RQS';

    mObjectSpace.SQLSelect(mSQL, mIDsList);
  if mIDsList.count>0 then begin
       CFxReportManager.ExportByIDs(mContext,mIDsList,mDynSource,mExportID,0,'',mFileName);
        if FileExists(mFileName) then begin
        mOutputList.Clear;
          mOutputList.LoadFromFile(mFileName);
          Result:=EncodeBase64(TEncoding.Unicode.GetBytes(mOutputList.text));
        end;
  end;
  DeleteFile(mFileName);
  mContext.Free;
  mIDsList.Free;
  mOutputList.Free;

end;


function GetWorkers(Self: TNxWebServicesHelper):String;
var
  mObjectSpace: TNxCustomObjectSpace;
  mIDsList, mOutputList: TStringList;
  mSQL,mExportID, mDynSource, mFileName: String;
  mContext: TNxContext;



begin
  Result:='';
  mIDsList:=TStringList.Create;
  mOutputList:=TStringList.Create;
  mObjectSpace := Self.ObjectSpace;
  mContext := NxCreateContext(mObjectSpace);
        msql:='select id from defrolldata where clsid=''DAZQPMWSTFG4H4HRVX5WUYQGNO'' and hidden=''N'' ';
      mExportID:='1E00000101';
      mFileName:='c:\AbraG3\htdocs\workers.xml';
      mDynSource:='E21H3CNZP4ZO1EQTM0TEDISD5G';

    mObjectSpace.SQLSelect(mSQL, mIDsList);
  if mIDsList.count>0 then begin
       CFxReportManager.ExportByIDs(mContext,mIDsList,mDynSource,mExportID,0,'',mFileName);
        if FileExists(mFileName) then begin
        mOutputList.Clear;
          mOutputList.LoadFromFile(mFileName);
          Result:=EncodeBase64(TEncoding.Unicode.GetBytes(mOutputList.text));
        end;
  end;
  DeleteFile(mFileName);
  mContext.Free;
  mIDsList.Free;
  mOutputList.Free;

end;


function GetOrder(Self: TNxWebServicesHelper;Order_ID: String):String;
Var
 mFileName, mSQL:STring;
 moutputlist, mResultList:TStringList;
 mContext:TNxContext;
 mOS:TNxCustomObjectSpace;
 mStatuses:String;
 mStatus:String;
 i:integer;
begin
 mOS:=self.ObjectSpace;
 mResultList:=TStringList.Create;
 mOutputList:=TStringList.Create;
 mContext := NxCreateContext(mOS);
  mSQL:='Select ro.id from receivedorders ro where id=''%s''';
  mFileName:='c:\AbraG3\htdocs\Orders.xml';
  mos.SQLSelect(Format(mSQL,[Order_ID]),mResultList);
  //mResultList.Add((Order_ID));
  if mResultList.count>0 then begin
       NxExportByIDs(mContext,mResultList,'40V53DORW3DL342X01C0CX3FCC','1C00000101',0,'',mFileName);
        if FileExists(mFileName) then begin
        mOutputList.Clear;
          mOutputList.LoadFromFile(mFileName);
          Result:=EncodeBase64(TEncoding.Unicode.GetBytes(mOutputList.text));
        end;
  end;
  DeleteFile(mFileName);
  mContext.Free;
  mResultList.Free;
  mOutputList.Free;

end;

function UpdateOrder(Self: TNxWebServicesHelper;XMLString: String):String;
Var
 mXMLinput:TBytes;
 mXMLHead : TNxScriptingXMLWrapper;
 mReceivedOrderBO, mReceivedOrderRowBO: TNxCustomBusinessObject;
 mFirm, mFirmOffice, mStoreCard, mFirmPerson, mPerson: TNxCustomBusinessObject;
 mRows, mColl : TNxCustomBusinessMonikerCollection;
 mOS: TNxCustomObjectSpace;
 mFirm_ID, mFirmOffice_ID, mStoreCard_ID, mQuantity, mPrice, mPerson_ID, mSQL, mOrder_ID, mDivision_id,mStore_ID, mLisar_ID: String;
 mBusOrder_ID, mBusTransaction_ID, mBusProject_ID:String;
 mQuantityDouble, mPriceDouble :Double;
 mList, mResultList:TStringList;
 i,j,k : integer;
 AResult, mFirmOfficeName, mFileName:String;
 mObjectSpace: TNxCustomObjectSpace;
 mContext: TNxContext;
 mOutputList: TStringList;
 mBool:Boolean;

begin
 Aresult:='';
 Result:='';
 mOS:=self.ObjectSpace;
 mXMLHead := TNxScriptingXMLWrapper.Create;
 mXMLinput:=DecodeBase64((XMLString));
 mList:=TStringList.Create;
 mOutputList:=TStringList.Create;
 mResultList:=Tstringlist.create;
 mContext := NxCreateContext(mOS);

 //ShowMessage(mXMLInput);
 mXMLHead.loadFromBytes(DecodeBase64(XMLString));
    for i:=0 to mXMLHead.getElementsCountInArray('order')-1 do begin
      mReceivedOrderBO:=mOS.CreateObject(Class_ReceivedOrder);
      mReceivedOrderBO.Load(mXMLHead.getElementAsString('order['+inttostr(i)+'].ABRA_ID'),nil);
      mLisar_ID:=scrGetLisar_ID(mOS,mReceivedOrderBO.OID);
      mStore_ID:=scrGetStore_ID(mOS, mLisar_ID);

      {mSQL:='Select ro.id from receivedorders ro where id=''%s''';
      mFileName:='c:\AbraG3\htdocs\Orders.xml';
      mos.SQLSelect(Format(mSQL,[mReceivedOrderBO.OID]),mResultList);}
      mResultList.Add(mReceivedOrderBO.OID);
      if not(mReceivedOrderBO.GetFieldValueAsString('X_status')=mXMLHead.getElementAsString('order['+inttostr(i)+'].Status_ID')) then
             mReceivedOrderBO.SetFieldValueAsString('X_status', mXMLHead.getElementAsString('order['+inttostr(i)+'].Status_ID'));
    
     for j:=0 to  mXMLHead.getElementsCountInArray('order['+inttostr(i)+'].OrderRows.OrderRow')-1 do begin
           mRows:=mReceivedOrderBO.GetLoadedCollectionMonikerForFieldCode(mReceivedOrderBO.getfieldcode('Rows'));
           for k:=0 to mRows.Count-1 do begin
              if mrows.BusinessObject[k].OID=mXMLHead.getElementAsString('order['+inttostr(i)+'].OrderRows.OrderRow['+inttostr(j)+'].ABRA_ID') then begin
              mrows.BusinessObject[k].SetFieldValueAsDateTime('DeliveryDate$Date',mXMLHead.getElementAsDateTime('order['+inttostr(i)+'].OrderRows.OrderRow['+inttostr(j)+'].DeliveryDate'));
              mDivision_id:=mrows.BusinessObject[k].GetFieldValueAsString('Division_ID');
              mBusOrder_ID:=mrows.BusinessObject[k].GetFieldValueAsString('BusOrder_ID');
              mBusTransaction_ID:=mrows.BusinessObject[k].GetFieldValueAsString('BusTransaction_ID');
              mBusProject_ID:=mrows.BusinessObject[k].GetFieldValueAsString('BusProject_ID');
              if not(mrows.BusinessObject[k].GetFieldValueAsFloat('Quantity')=(mXMLHead.getElementAsFloat('order['+inttostr(i)+'].OrderRows.OrderRow['+inttostr(j)+'].Quantity')))
               and ((mXMLHead.getElementAsFloat('order['+inttostr(i)+'].OrderRows.OrderRow['+inttostr(j)+'].Quantity'))>0)
              then begin
                  mrows.BusinessObject[k].SetFieldValueAsFloat('X_OriginalQuantity', mRows.BusinessObject[k].GetFieldValueAsFloat('Quantity'));
                  mrows.BusinessObject[k].SetFieldValueAsFloat('Quantity',mXMLHead.getElementAsFloat('order['+inttostr(i)+'].OrderRows.OrderRow['+inttostr(j)+'].Quantity'));
              end;
              mrows.BusinessObject[k].Save;
              if (mXMLHead.getElementAsFloat('order['+inttostr(i)+'].OrderRows.OrderRow['+inttostr(j)+'].Quantity'))=0 then mrows.BusinessObject[k].MarkForDelete;
              end;
           end;
     end;
     for j:=0 to  mXMLHead.getElementsCountInArray('order['+inttostr(i)+'].OrderRows.OrderRow')-1 do begin
          if (mXMLHead.getElementAsString('order['+inttostr(i)+'].OrderRows.OrderRow['+inttostr(j)+'].ABRA_ID')='0000000000') or (mXMLHead.getElementAsString('order['+inttostr(i)+'].OrderRows.OrderRow['+inttostr(j)+'].ABRA_ID')='0') then begin
             mRows:=mReceivedOrderBO.GetLoadedCollectionMonikerForFieldCode(mReceivedOrderBO.getfieldcode('Rows'));
             mReceivedOrderRowBO:=mRows.AddNewObject;
             mReceivedOrderRowBO.Prefill;
             mReceivedOrderRowBO.SetFieldValueAsInteger('RowType',3);
             mReceivedOrderRowBO.SetFieldValueAsString('Store_ID',mStore_ID);
             mReceivedOrderRowBO.SetFieldValueAsString('StoreCard_ID',mXMLHead.getElementAsString('order['+inttostr(i)+'].OrderRows.OrderRow['+inttostr(j)+'].Abra_StoreCard_ID'));
             mReceivedOrderRowBO.SetFieldValueAsFloat('Quantity',mXMLHead.getElementAsFloat('order['+inttostr(i)+'].OrderRows.OrderRow['+inttostr(j)+'].Quantity'));
             mReceivedOrderRowBO.SetFieldValueAsString('Division_ID', mDivision_ID);
             mReceivedOrderRowBO.SetFieldValueAsString('BusOrder_ID', mBusOrder_ID);
             mReceivedOrderRowBO.SetFieldValueAsString('BusTransaction_ID', mBusTransaction_ID);
             mReceivedOrderRowBO.SetFieldValueAsString('BusProject_ID', mBusProject_ID);
             mReceivedOrderRowBO.SetFieldValueAsString('X_Lisar1', mLisar_ID);
          end;
     end;
    mReceivedOrderBO.Save;
    mReceivedOrderBO.Free;
    end;
    if mResultList.count>0 then begin
       mFileName:='c:\AbraG3\htdocs\Orders.xml';
       CFxReportManager.ExportByIDs(mContext,mResultList,'40V53DORW3DL342X01C0CX3FCC','1C00000101',0,'',mFileName);
        if FileExists(mFileName) then begin
        mOutputList.Clear;
          mOutputList.LoadFromFile(mFileName);
          //Result:=(mOutputList.text);
          Result:=EncodeBase64(TEncoding.Unicode.GetBytes(mOutputList.text));
        end;
  end;
  DeleteFile(mFileName);
  mContext.Free;
  mResultList.Free;
  mOutputList.Free;
end;
//Doplnit importmanagera na provedení příjmu na sklad který ma lisař uvedený jako zdrojový


function CreateTransfer(Self: TNxWebServicesHelper;XMLString: String;Worker_ID: String):String;
Var
 mXMLinput:string;
 mXMLHead : TNxScriptingXMLWrapper;
 moutputlist, mResultList, mList:TStringList;
 mContext:TNxContext;
 mOS:TNxCustomObjectSpace;
 mStore_ID:String;
 mFileName:String;
 i,j: Integer;
 mOutgoingTransfer, mOutgoingTransferRow, mWorker:TNxCustomBusinessObject;
 mRows: TNxCustomBusinessMonikerCollection;
 mInputParams: TNxParameters;
 mImportMan: TNxDocumentImportManager;
 mOT_ID, mStore_ID2, mDocQueue_ID:String;
 mParam: TNxParameter;
begin
 Result:='<?xml version="1.0" encoding="UTF-8"?>';
 mOS:=self.ObjectSpace;
 mXMLHead := TNxScriptingXMLWrapper.Create;
 //mXMLinput:=DecodeBase64(XMLString);
 mList:=TStringList.Create;
 mOutputList:=TStringList.Create;
 mResultList:=Tstringlist.create;
 mContext := NxCreateContext(mOS);
 mXMLHead.loadFromBytes(DecodeBase64(XMLString));
 for i:=0 to mXMLHead.getElementsCountInArray('Rows')-1 do begin

 mOutgoingTransfer:=mOS.CreateObject(Class_OutgoingTransfer);
 mOutgoingTransfer.New;
 mOutgoingTransfer.Prefill;
 mOutgoingTransfer.SetFieldValueAsString('DocQueue_ID','2H10000101');
 mRows:=mOutgoingTransfer.GetCollectionMonikerForFieldCode(mOutgoingTransfer.GetFieldCode('Rows'));
    for j:=0 to mXMLHead.getElementsCountInArray('Rows['+inttostr(i)+'].Row')-1 do begin

             mStore_ID:=scrGetStore_ID(mOS, Worker_ID);
             mOutgoingTransferRow:=mRows.AddNewObject;
             mOutgoingTransferRow.Prefill;
             mOutgoingTransferRow.SetFieldValueAsInteger('RowType',3);
             mOutgoingTransferRow.SetFieldValueAsString('Store_ID',mStore_ID);
             mOutgoingTransferRow.SetFieldValueAsString('StoreCard_ID',mXMLHead.getElementAsString('Rows['+inttostr(i)+'].Row['+inttostr(j)+'].Abra_StoreCard_ID'));
             mOutgoingTransferRow.SetFieldValueAsFloat('Quantity',mXMLHead.getElementAsFloat('Rows['+inttostr(i)+'].Row['+inttostr(j)+'].Quantity'));
             mOutgoingTransferRow.SetFieldValueAsString('Division_ID', '1000000101');


    end;
     mOutgoingTransfer.Save;
     mOT_ID:=mOutgoingTransfer.OID;
     // zacatek DocImport
      try
    mInputParams := TNxParameters.Create;
    mStore_ID2:=scrGetStore_ID2(mOS, Worker_ID);
    mWorker:=mos.CreateObject('DAZQPMWSTFG4H4HRVX5WUYQGNO');
    mWorker.Load(Worker_ID,nil);
    mDocQueue_ID:=mWorker.GetFieldValueAsString('U_DocQueue_ID');
    mWorker.Free;
    try

      //ShowMessage(mReceiptCard.DisplayName);
      mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
      mParam.AsString := mDocQueue_ID;
      mParam := mInputParams.GetOrCreateParam(dtString, 'Store_ID');
      mParam.AsString := mStore_ID2;

      mImportMan := NxCreateDocumentImportManager(mOS, Class_OutgoingTransfer,Class_IncomingTransfer);
      try
        mImportMan.AddInputDocument(mOT_ID);
        mImportMan.LoadParams(mInputParams);
        mImportMan.Execute;
        mImportMan.CheckOutputDocument;
        if Assigned(mImportMan.OutputDocument) then begin
          mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', mDocQueue_ID); // musi byt...
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


     //konec Docimport
     moutputlist.add(mOutgoingTransfer.OID);
    mOutgoingTransfer.Free;
    end;
    if moutputlist.count>0 then begin
       mFileName:='c:\AbraG3\htdocs\Transfer.xml';
       CFxReportManager.ExportByIDs(mContext,moutputlist,'0PDOXDMCSZDL3FUD00C5OG4NF4','1G00000101',0,'',mFileName);
        if FileExists(mFileName) then begin
        mOutputList.Clear;
          mOutputList.LoadFromFile(mFileName);
          //Result:=(mOutputList.text);
          Result:=EncodeBase64(TEncoding.Unicode.GetBytes(mOutputList.text));
        end;
  end;
  DeleteFile(mFileName);
  mContext.Free;
  mResultList.Free;
  mOutputList.Free;
 
 
end;

function GetStoreKeepers(Self: TNxWebServicesHelper):String;
var
  mObjectSpace: TNxCustomObjectSpace;
  mIDsList, mOutputList: TStringList;
  mSQL,mExportID, mDynSource, mFileName: String;
  mContext: TNxContext;



begin
  Result:='';
  mIDsList:=TStringList.Create;
  mOutputList:=TStringList.Create;
  mObjectSpace := Self.ObjectSpace;
  mContext := NxCreateContext(mObjectSpace);
        msql:='select id from defrolldata where clsid=''QOXKO4CXPDOOZHUXXSWW1KBVGK'' and hidden=''N'' ';
      mExportID:='1H00000101';
      mFileName:='c:\AbraG3\htdocs\StoreKeepers.xml';
      mDynSource:='NIFCPO3PRZL434SFZDDNGWI2LG';

    mObjectSpace.SQLSelect(mSQL, mIDsList);
  if mIDsList.count>0 then begin
       NxExportByIDs(mContext,mIDsList,mDynSource,mExportID,0,'',mFileName);
        if FileExists(mFileName) then begin
        mOutputList.Clear;
          mOutputList.LoadFromFile(mFileName);
          Result:=EncodeBase64(TEncoding.Unicode.GetBytes(mOutputList.text));
        end;
  end;
  DeleteFile(mFileName);
  mContext.Free;
  mIDsList.Free;
  mOutputList.Free;

end;

function GetCars(Self: TNxWebServicesHelper):String;
var
  mObjectSpace: TNxCustomObjectSpace;
  mIDsList, mOutputList: TStringList;
  mSQL,mExportID, mDynSource, mFileName: String;
  mContext: TNxContext;



begin
  Result:='';
  mIDsList:=TStringList.Create;
  mOutputList:=TStringList.Create;
  mObjectSpace := Self.ObjectSpace;
  mContext := NxCreateContext(mObjectSpace);
        msql:='select id from defrolldata where clsid=''TEMKSRG0EJZO1CTF3ZHOY50GYG'' and hidden=''N''';
      mExportID:='2H00000101';
      mFileName:='c:\AbraG3\htdocs\Cars.xml';
      mDynSource:='FW3W34LV4SM4FIIRRTSL4W4ZEG';

    mObjectSpace.SQLSelect(mSQL, mIDsList);
  if mIDsList.count>0 then begin
       NxExportByIDs(mContext,mIDsList,mDynSource,mExportID,0,'',mFileName);
        if FileExists(mFileName) then begin
        mOutputList.Clear;
          mOutputList.LoadFromFile(mFileName);
          Result:=EncodeBase64(TEncoding.Unicode.GetBytes(mOutputList.text));
        end;
  end;
  DeleteFile(mFileName);
  mContext.Free;
  mIDsList.Free;
  mOutputList.Free;

end;




begin
end.