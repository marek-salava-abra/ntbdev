function GetAvailableQuantity(AOS : TNxCustomObjectSpace; aStore_ID, aStoreCard_ID : string) : Extended;
const
  cSQL = 'SELECT Sum(Quantity-Bookedquantity) FROM StoreSubCards WHERE Store_ID=''%s'' and StoreCard_ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aStore_ID, aStoreCard_ID]), mList);
    if mList.Count > 0 then
      Result := NxIBStrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;
function GetQuantity(AOS : TNxCustomObjectSpace; aStore_ID, aStoreCard_ID : string) : Extended;
const
  cSQL = 'SELECT Sum(Quantity) FROM StoreSubCards WHERE Store_ID=''%s'' and StoreCard_ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aStore_ID, aStoreCard_ID]), mList);
    if mList.Count > 0 then
      Result := NxIBStrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;

function GetOrderedQuantity(AOS : TNxCustomObjectSpace; aStoreCard_ID, ARow_ID, aStore_ID : string; ADate: Extended) : Extended;
const
  DecimalSeparator= '.';
  cSQL = 'SELECT SUM(Quantity-deliveredQuantity) FROM ReceivedOrders2 RO2 LEFT JOIN ReceivedOrders RO ON RO.ID = RO2.Parent_ID '+
          'WHERE RO.Confirmed = ''A'' and RO.Closed = ''N'' and RO2.StoreCard_ID = ''%s'' and RO2.ID <> ''%s'' and RO2.Store_ID = ''%s'' and CreatedAt$Date < %s  ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aStoreCard_ID, ARow_ID, aStore_ID ,NxFloatToIBStr(ADate)]), mList);
    if mList.Count > 0 then
      Result := NxIBStrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;

function CreateTransfer(var AOS:TNxCustomObjectSpace; var aOrderBO:TNxCustomBusinessObject;
           var aList:TStringList;var aDocQueue_ID, aDestStore_ID, aDivision_ID:string;):String;
var
 mOTBO, mOTRowBO, mUserXLink, mTempBO:TNxCustomBusinessObject;
 i,j:Integer;
 mRelation_ID:string;
 mRows:TNxCustomBusinessMonikerCollection;
 mStore_ID, mStoreCard_ID, mTempStr, mITPMState_ID:string;
 mQuantity:Extended;
 mOTList:TStringList;
 mMessage:string;
begin
  mMessage:='';
  //doplnit kontrolu na Vyřízené a nepočítat s nima
  mRelation_ID:=AOS.SQLSelectFirstAsString('Select sd.id from storedocuments sd left join userxlinks x on sd.id=x.Destination_ID '+
                                           ' where sd.docqueue_id='+QuotedStr(aDocQueue_ID)+' and x.Source_id='+QuotedStr(aOrderBO.OID)+
                                           ' and x.SourceCLSID='+QuotedStr(Class_ReceivedOrder)+
                                           ' and not(sd.pmstate_id='+QuotedStr('SDDEF00000')+')'+
                                           ' and x.DestinationCLSID='+QuotedStr(Class_OutgoingTransfer),'');
  mMessage:=mMessage+#13#10+' prvni zjištění ID vazby '+mRelation_ID;
  // při PVES provést ještě kontrolu na provedení Převodky příjem na 01-vo, pokud není provedena, nedělat novou převodku
  if NxIsEmptyOID(mRelation_ID) then begin
     mOTList:=TStringList.Create;
     AOS.SQLSelect('Select sd.id from storedocuments sd left join userxlinks x on sd.id=x.Destination_ID '+
                                           ' where sd.docqueue_id='+QuotedStr(aDocQueue_ID)+' and x.Source_id='+QuotedStr(aOrderBO.OID)+
                                           ' and x.SourceCLSID='+QuotedStr(Class_ReceivedOrder)+
                                           ' and (sd.pmstate_id='+QuotedStr('SDDEF00000')+')'+
                                           ' and x.DestinationCLSID='+QuotedStr(Class_OutgoingTransfer),mOTList);
     if mOTList.Count>0 then begin
        mMessage:=mMessage+#13#10+' máme seznam OT: '+mOTList.DelimitedText;
        for j:=0 to mOTList.Count-1 do begin
          mITPMState_ID:=AOS.SQLSelectFirstAsString('select distinct(sd.pmstate_id) from storedocuments2 sd2 left join storedocuments sd on sd.id=sd2.parent_id where sd2.provide_id='+
                                     QuotedStr(mOTList.Strings[j]),'');
          if not(mITPMState_ID='SDDEF00000') then mRelation_ID:=mOTList.Strings[j];
          mMessage:=mMessage+#13#10+' nastavení ID vazby '+mRelation_ID;
        end;
     end;
  end;
  if NxIsEmptyOID(mRelation_ID) then begin
      mOTBO:=aos.CreateObject(Class_OutgoingTransfer);
      mOTBO.New;
      mOTBO.prefill;
      mOTBO.SetFieldValueAsString('DocQueue_ID',aDocQueue_ID);
      mOTBO.SetFieldValueAsString('Firm_ID',aOrderBO.GetFieldValueAsString('Firm_ID'));
      mOTBO.SetFieldValueAsString('Description',aOrderBO.DisplayName);
      mOTBO.SetFieldValueAsString('U_DestinationStore',aDestStore_ID);
      mRows:=mOTBO.GetLoadedCollectionMonikerForFieldCode(mOTBO.GetFieldCode('Rows'));
      for i:=0 to aList.count-1 do begin
        mTempStr:=aList.Strings[i];
        mStore_ID:=NxTrapStrTrim(mTempStr,';');
        mStoreCard_ID:=NxTrapStrTrim(mTempStr,';');
        mQuantity:=NxIBStrToFloat(NxTrapStrTrim(mTempStr,';'));
        mOTRowBO:=mRows.AddNewObject;
        mOTRowBO.Prefill;
        mOTRowBO.SetFieldValueAsInteger('RowType',3);
        mOTRowBO.SetFieldValueAsString('Store_ID',mStore_ID);
        mOTRowBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
        mOTRowBO.SetFieldValueAsString('Division_ID',aDivision_ID);
        mOTRowBO.SetFieldValueAsFloat('Quantity',mQuantity);
      end;
      mOTBO.save;
      mUserXLink := AOS.CreateObject(Class_UserXLink);
      try
        mUserXLink.New;
        mUserXLink.Prefill;
        mUserXLink.SetFieldValueAsString('SourceCLSID', Class_ReceivedOrder);
        mUserXLink.SetFieldValueAsString('Source_ID', aOrderBO.OID);
        mUserXLink.SetFieldValueAsString('DestinationCLSID', Class_OutgoingTransfer);
        mUserXLink.SetFieldValueAsString('Destination_ID', mOTBO.OID);
        mUserXLink.SetFieldValueAsBoolean('DisplayAsSystem', True);
        mUserXLink.SetFieldValueAsString('Description','Převodka pro objednávku '+aOrderBO.DisplayName);
        mUserXLink.Save;
      finally
        mUserXLink.Free;
      end;
    mMessage:=mMessage+#13#10+'Nová '+mOTBO.DisplayName;
    if not (osSaving in aOrderBO.InternalState) then aOrderBO.PMChangeState('8060000101');
    //doplnit zapsání položky nevytvářet převodku
    mTempBO:=AOS.CreateObject(Class_ReceivedOrder);
    mTempBO.Load(aOrderBO.OID,nil);
    mTempBO.SetFieldValueAsBoolean('U_NotCreateTransfer',true);
    mTempBO.save;
  end else begin
    mOTBO:=aos.CreateObject(Class_OutgoingTransfer);
    mOTBO.Load(mRelation_ID);
    mMessage:=mMessage+#13#10+'Již použitá nevyřízená '+mOTBO.DisplayName;
    if not (osSaving in aOrderBO.InternalState) then aOrderBO.PMChangeState('8060000101');
  end;
  Result:=mMessage;
end;

begin
end.