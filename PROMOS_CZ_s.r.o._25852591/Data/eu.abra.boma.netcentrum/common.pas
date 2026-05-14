uses 'eu.abra.boma.netcentrum.consts',
      'eu.abra.boma.netcentrum.maildoc';

function MakeISDOCII_NC(OS:TNxCustomObjectSpace; var AOID: String): Boolean;
var
  mContext: TNxContext;
  mIDs: TStringList;
  mLogStr: TStringList;
  mText: String;
  i: Integer;
  mGen:String;
  mInternalOLE,mDocDriver:Variant;
begin
  mText:='';
  mLogStr:=TStringList.Create;
  try
    mContext:=NxCreateContext(OS);
    try
      mIDs:=TStringList.Create;
      try
        mIDs.Append(AOID);
        mGen:=NxSearchReplace(FloatToStr(Frac(Now)),',','',[srAll]);
        CFxReportManager.B2BExportByIDs(mContext,mIDs,'40SBPEINEFD13ACM03KIU0CLP4','1500000201',0,'','\\abraserver\SolidniObchod\ISDOC\'+mGen+'.isdoc');
        mInternalOLE:=GetAbraOLEApplication;
        mDocDriver:=mInternalOLE.CreateDocumentDriver;
        mDocDriver.NewDocument('4000000000');
        mDocDriver.AddContentFromFile('\\abraserver\SolidniObchod\ISDOC\'+mGen+'.isdoc');
        mDocDriver.SaveDocument;
        //mDocDriver.ProcessDocument;
        DeleteFile('\\abraserver\SolidniObchod\ISDOC\'+mGen+'.isdoc');
      finally
        mIDs.Free;
      end;
    finally
      mContext.Free;
    end;
  finally
    mLogStr.Free;
  end;
end;

function MakeISDOCII_TS(OS:TNxCustomObjectSpace; var AOID: String): Boolean;
var
  mContext: TNxContext;
  mIDs: TStringList;
  mLogStr: TStringList;
  mText: String;
  i: Integer;
  mGen:String;
  mInternalOLE,mDocDriver:Variant;
begin
  mText:='';
  mLogStr:=TStringList.Create;
  try
    mContext:=NxCreateContext(OS);
    try
      mIDs:=TStringList.Create;
      try
        mIDs.Append(AOID);
        mGen:=NxSearchReplace(FloatToStr(Frac(Now)),',','',[srAll]);
        CFxReportManager.B2BExportByIDs(mContext,mIDs,'40SBPEINEFD13ACM03KIU0CLP4','1600000201',0,'','\\ABRASERVER\Technistore\ISDOCs\\'+mGen+'.isdoc');
        mInternalOLE:=GetAbraOLEApplication;
        mDocDriver:=mInternalOLE.CreateDocumentDriver;
        mDocDriver.NewDocument('1200000201');
        mDocDriver.AddContentFromFile('\\ABRASERVER\Technistore\ISDOCs\'+mGen+'.isdoc');
        mDocDriver.SaveDocument;
        VytvorVazbu(AOID,mDocDriver.Document.OID,600,OS);
        VytvorVazbu(mDocDriver.Document.OID,AOID,1670,OS);
        //mDocDriver.ProcessDocument;
        DeleteFile('\\ABRASERVER\Technistore\ISDOCs\'+mGen+'.isdoc');
      finally
        mIDs.Free;
      end;
    finally
      mContext.Free;
    end;
  finally
    mLogStr.Free;
  end;
end;

procedure VytvorVazbu(LeftSide_ID, RightSide_ID: String; Rel_Def: Integer; aObjectSpace: TNxCustomObjectSpace);
var
  mBoRel: TNxCustomBusinessObject;
begin
  mBoRel := aObjectSpace.CreateObject(Class_Relation);
  try
    mBORel.New;
    mBORel.Prefill;
    mBoRel.SetFieldValueAsInteger('REL_DEF',Rel_Def);
    mBoRel.SetFieldValueAsString('LEFTSIDE_ID',LeftSide_ID);
    mBoRel.SetFieldValueAsString('RIGHTSIDE_ID',RightSide_ID);
    mBoRel.Save;
    OutputDebugString('Relation: ' + mBoRel.OID + ' - ' + IntToStr(Rel_Def) + ' - ' + LeftSide_ID + ' - ' + RightSide_ID);
  finally
    mBoRel.Free;
  end;
end;

function ImportOrder(OS:TNxCustomObjectSpace; mXML:Variant; var mErrs: TStringList; var mSave:Boolean):String;
var
  mXMLNode, mXMLNodeList, mXMLNode1, mXMLNodeZbozi: Variant;
  mBO, mRowBO, mRezervace, mBOBO: TNxCustomBusinessObject;
  i,j,k,l, mRowType: Integer;
  mPrice,mQuantity: Double;
  mTextval,mStoreCard, mBusOrder, mCurrency_ID: String;
  mCon: TNxContext;
begin
  mBusOrder:='';
  Result:='0000000000';
  try
    //mXML:= CreateOLEObject('Msxml2.DOMDocument');
    try
      //mXML.LoadXML(mReceivedOrder);
      mXMLNodeList := mXML.selectNodes('//RECEIVEDORDERS/RECEIVEDORDER');
        for i := 0 to mXMLNodeList.length - 1 do begin
          mBO:=OS.CreateObject('01CPMINJW3DL342X01C0CX3FCC');
          try
            mBO.New;
            mBO.Prefill;
            mBO.SetFieldValueAsString('DocQueue_ID',cOPN);
            mBO.SetFieldValueAsString('Firm_ID',cFirm_ID);
            mBO.SetFieldValueAsString('ConstSymbol_ID',cLocalConstSymbol);
            mBO.SetFieldValueAsBoolean('PricesWithVAT',True);
            mXMLNode1 := mXMLNodeList.item[i];
            if mXMLNode1.HasChildNodes then begin
              For j:=0 to mXMLNode1.ChildNodes.Length -1 do begin
                mXMLNode := mXMLNode1.ChildNodes.Item[j];
                case mXMLNode.BaseName of
                'ID': begin
                  mBusOrder:= GetIDForCode('N'+mXMLNode.Text,'BusOrders',OS,mErrs);
                  if (mXMLNode.Text='003') then begin
                    mBO.SetFieldValueAsString('Firm_ID',c004Firm_ID);
                    mBO.SetFieldValueAsString('DocQueue_ID',cOP);
                  end;
                  if (mXMLNode.Text='005') then
                  begin
                    mBO.SetFieldValueAsString('Firm_ID',c004Firm_ID);
                    mBO.SetFieldValueAsString('DocQueue_ID',cOP);
                    mBO.SetFieldValueAsInteger('TradeType',4);
                    mBO.SetFieldValueAsString('ConstSymbol_ID',cForeignConstSymbol);

                    mBO.SetFieldValueAsString('IntrastatDeliveryTerm_ID',cIntrastatDeliveryTerm_ID);
                    mBO.SetFieldValueAsString('IntrastatTransactionType_ID',cIntrastatTransactionType_ID);
                    mBO.SetFieldValueAsString('IntrastatTransportationType_ID',cIntrastatTransportationType_ID);
                  end;
                end;
                'PaymentType': mBO.SetFieldValueAsString('PaymentType_ID',GetIDForCode(mXMLNode.Text,'PaymentTypes',OS,mErrs));
                'TransportationType': mBO.SetFieldValueAsString('TransportationType_ID',GetIDForCode(mXMLNode.Text,'TransportationTypes',OS,mErrs));
                'ExtNumber' : mBO.SetFieldValueAsString('ExternalNumber',mXMLNode.Text);
                'DName' : mBO.SetFieldValueAsString('X_Web_DName',mXMLNode.Text);
                'DAddress' : mBO.SetFieldValueAsString('X_Web_DStreet',mXMLNode.Text);
                'DCity' : mBO.SetFieldValueAsString('X_Web_DCity',mXMLNode.Text);
                'DPostCode' : mBO.SetFieldValueAsString('X_Web_DPostCode',mXMLNode.Text);
                'DCountry' : mBO.SetFieldValueAsString('X_Web_DCountry',mXMLNode.Text);
                'IIName' : mBO.SetFieldValueAsString('X_Web_IIName',mXMLNode.Text);
                'IIAddress' : mBO.SetFieldValueAsString('X_Web_IIStreet',mXMLNode.Text);
                'IICity' : mBO.SetFieldValueAsString('X_Web_IICity',mXMLNode.Text);
                'IIPostCode' : mBO.SetFieldValueAsString('X_Web_IIPostCode',mXMLNode.Text);
                'IICountry' : mBO.SetFieldValueAsString('X_Web_IICountry',mXMLNode.Text);
                'Firm' : mBO.SetFieldValueAsString('X_Web_Firm',mXMLNode.Text);
                'DFirm' : mBO.SetFieldValueAsString('X_Web_DFirm',mXMLNode.Text);
                'OrgIdentNumber' : mBO.SetFieldValueAsString('X_Web_OrgIdentNumber',mXMLNode.Text);
                'VATNumber' : mBO.SetFieldValueAsString('X_Web_VATIdentNumber',mXMLNode.Text);
                'Email' : mBO.SetFieldValueAsString('X_Web_Email',mXMLNode.Text);
                'Telefon' : mBO.SetFieldValueAsString('X_Web_Phone',mXMLNode.Text);
                'Note' : begin
                    mBO.SetFieldValueAsString('X_Poznamka_web',mXMLNode.Text);
                    if Length(mXMLNode.Text)>0 then mBO.SetFieldValueAsBoolean('X_isPoznamka',True);
                  end;
                'ROWS' :
                  begin
                    mBOBO:=OS.CreateObject(Class_BusOrder);
                    try
                      if mBOBO.Test(mBusOrder) then begin
                        mBOBO.Load(mBusOrder,nil);
                        mCurrency_ID:=mBOBO.GetFieldValueAsString('X_Currency_ID');
                        if NxIsEmptyOID(mCurrency_ID) then RaiseException('Na zakázce není zvolena měna, neleze pokračovat!');
                        mBO.SetFieldValueAsString('Currency_ID',mCurrency_ID);
                        if not(mCurrency_ID=cCurrency_ID) then begin
                          {mBO.SetFieldValueAsInteger('TradeType',4);
                          mBO.SetFieldValueAsString('ConstSymbol_ID',cForeignConstSymbol);
                          mBO.SetFieldValueAsString('Country_ID',GetIDForCode(mBO.GetFieldValueAsString('X_Web_IICountry'),'Countries',OS,mErrs));}
                          mBO.SetFieldValueAsInteger('VATRounding',0);
                          mBO.SetFieldValueAsInteger('TotalRounding',0);
                          {mBO.SetFieldValueAsString('IntrastatDeliveryTerm_ID',cIntrastatDeliveryTerm_ID);
                          mBO.SetFieldValueAsString('IntrastatTransactionType_ID',cIntrastatTransactionType_ID);
                          mBO.SetFieldValueAsString('IntrastatTransportationType_ID',cIntrastatTransportationType_ID);}
                        end;
                      end;
                    finally
                      mBOBO.Free;
                    end;
                    if mXMLNode.HasChildNodes then begin
                           For k:=0 to mXMLNode.ChildNodes.Length -1 do begin
                            if mXMLNode.ChildNodes.Item[k].HasChildNodes then begin
                              for l:=0 to mXMLNode.ChildNodes.Item[k].ChildNodes.Length -1 do begin
                                if mXMLNode.ChildNodes.Item[k].ChildNodes.Item[l].BaseName='DeliveryPrice' then begin
                                  mPrice:=StrToFloat(NxSearchReplace(NxSearchReplace(NxSearchReplace(mXMLNode.ChildNodes.Item[k].ChildNodes.Item[l].Text,' ','',[srAll]),'.',',',[srAll]),Chr(13),'',[srAll]));
                                  mRowType:=1;
                                end;
                                if mXMLNode.ChildNodes.Item[k].ChildNodes.Item[l].BaseName='DeliveryDate' then mTextval:=NxSearchReplace(NxSearchReplace(NxSearchReplace(mXMLNode.ChildNodes.Item[k].ChildNodes.Item[l].Text,' ','',[srAll]),Chr(10),'',[srAll]),Chr(13),'',[srAll]);
                                if mXMLNode.ChildNodes.Item[k].ChildNodes.Item[l].BaseName='StoreCard' then begin
                                  mStoreCard:=NxSearchReplace(NxSearchReplace(NxSearchReplace(mXMLNode.ChildNodes.Item[k].ChildNodes.Item[l].Text,' ','',[srAll]),Chr(10),'',[srAll]),Chr(13),'',[srAll]);
                                  mStoreCard:=GetIDForCode(mStoreCard,'StoreCards',OS,mErrs);
                                  mRowType:=3;
                                end;
                                if mXMLNode.ChildNodes.Item[k].ChildNodes.Item[l].BaseName='Quantity' then mQuantity:=StrToFloat(NxSearchReplace(NxSearchReplace(NxSearchReplace(mXMLNode.ChildNodes.Item[k].ChildNodes.Item[l].Text,' ','',[srAll]),'.',',',[srAll]),Chr(13),'',[srAll]));
                                if mXMLNode.ChildNodes.Item[k].ChildNodes.Item[l].BaseName='UnitPrice' then mPrice:=StrToFloat(NxSearchReplace(NxSearchReplace(NxSearchReplace(mXMLNode.ChildNodes.Item[k].ChildNodes.Item[l].Text,' ','',[srAll]),'.',',',[srAll]),Chr(13),'',[srAll]));
                              end;
                            end;
                            mRowBO:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows')).AddNewObject;
                            mRowBO.SetFieldValueAsInteger('RowType',mRowType);
                            mRowBO.SetFieldValueAsString('Division_ID',cDivision_ID);
                            if not(NxIsEmptyOID(mBusOrder)) then mRowBO.SetFieldValueAsString('BusOrder_ID',mBusOrder);
                            if mRowType=1 then begin
                              mRowBO.SetFieldValueAsString('Text','Poštovné');
                              mRowBO.SetFieldValueAsFloat('TotalPrice',mPrice);
                              //mRowBO.SetFieldValueAsString('VATRate_ID',cVATRate);
                              mRowBO.SetFieldValueAsString('VATRate_ID',mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows')).FirstBusinessObject.GetFieldValueAsString('VatRate_ID'));
                              mRowBO.SetFieldValueAsString('BusProject_ID',cDopravneProj);
                              //mRowBO.SetFieldValueAsFloat('VATRate',20);
                            end;
                            if mRowType=3 then begin
                              mRowBO.SetFieldValueAsString('Store_ID',cStore_ID);
                              mRowBO.SetFieldValueAsString('StoreCard_ID',mStoreCard);
                              mRowBO.SetFieldValueAsFloat('Quantity',mQuantity);
                              mRowBO.SetFieldValueAsFloat('UnitPrice',mPrice);
                              if not (mTextval='') then mRowBO.SetFieldValueAsDateTime('DeliveryDate$DATE',getFormatedDate(mTextval))
                              else mRowBO.SetFieldValueAsDateTime('DeliveryDate$DATE',Today);
                              if mBO.GetFieldValueAsString('PaymentType_ID')=cPlatbaZalohy then begin
                                //vytvořit rezervace
                                mRezervace:=mRowBO.GetMonikerForFieldCode(mRowBO.GetFieldCode('Reservation_ID')).BusinessObject;
                                //mRezervace.SetFieldValueAsDateTime('DateTo$DATE',IncDay(mRowBO.GetFieldValueAsDateTime('DeliveryDate$DATE'),7));
                                mRezervace.SetFieldValueAsFloat('UnitReserved',mRowBO.GetFieldValueAsFloat('UnitQuantity'));
                                mBO.SetFieldValueAsInteger('X_STAV_DOKLADU',cZL);
                              end;
                              if mBO.GetFieldValueAsString('PaymentType_ID')=cKreditka then begin
                                //vytvořit rezervace
                                mRezervace:=mRowBO.GetMonikerForFieldCode(mRowBO.GetFieldCode('Reservation_ID')).BusinessObject;
                                //mRezervace.SetFieldValueAsDateTime('DateTo$DATE',IncDay(mRowBO.GetFieldValueAsDateTime('DeliveryDate$DATE'),7));
                                mRezervace.SetFieldValueAsFloat('UnitReserved',mRowBO.GetFieldValueAsFloat('UnitQuantity'));
                                mBO.SetFieldValueAsInteger('X_STAV_DOKLADU',cPayU);
                              end;
                            end;
                           end;
                         end;
                  end;
                end;
              end;
              if (Length(mBO.GetFieldValueAsString('X_Web_IICountry'))>0) and (mBO.GetFieldValueAsString('Firm_ID')=c004Firm_ID) then
                mBO.SetFieldValueAsString('Country_ID',GetIDForCode(NxLeft(mBO.GetFieldValueAsString('X_Web_IICountry'),2),'Countries',OS,mErrs));
            end;
            mBO.Save;
            mBO.Refresh;
            mCon:=NxCreateContext_1(mBO);
            try
              //if not(CreateAndSendByINI_DEP(mCon, mBO, 1, mTextval, mBO.GetFieldValueAsString('X_WEB_Email'))) then mBO.SetFieldValueAsString('X_SendMail_Note',mTextval);
            finally
              mCon.Free;
            end;
            if mBO.NeedSave then mBO.Save;
            mSave:=True;
            Result:=mBO.OID;
          finally
            mBO.Free;
          end;
        end;
    finally
    //  mXML:=nil;
    end;
  except
    mErrs.Append(ExceptionMessage);
    mSave:=False;
  end;
end;

function getFormatedDate(aString: String):Date;
var
  YYYY,MM,DD: Integer;
begin
  YYYY:=StrToInt(NxTrapStr(aString,'-'));
  MM:=StrToInt(NxTrapStr(aString,'-'));
  DD:=StrToInt(aString);
  Result:=NxEncodeDate(YYYY,MM,DD);
end;

Function GetIDForCode(ACode,ATable:String;AObjectSpace:TNxCustomObjectSpace;var mErrs:Tstringlist;):String;
var
  mSQL: String;
  mResult: TStringList;
begin
  mSQL:='Select ID From %s Where Code=''%s'' and Hidden=''N''';
  mSQL:=Format(mSQL,[ATable,ACode]);
  mResult:=TStringList.Create;
  try
    AObjectSpace.SQLSelect(mSQL,mResult);
    case mResult.Count of
      0: begin
           mErrs.Add('Kód: '+ ACode +' nebyl nenalezen!');
           Result:='';
         end;
      1: Result:=mResult[0];
      else begin
        Result:=mResult[0];
        mErrs.Add('Nalezeno více záznamů!');
      end;
    end;
  finally
    mResult.Free;
  end;
end;

function CanMakeBOD(var mBORO: TNxCustomBusinessObject):Boolean;
begin
  if mBORO.GetFieldValueAsInteger('X_Stav_Dokladu')>cNormal then
    Result:=False
  else begin
    //mBORO.SetFieldValueAsInteger('X_WEB_Stav_Dokladu',2);
    Result:=True;
  end;
end;
begin
end.
