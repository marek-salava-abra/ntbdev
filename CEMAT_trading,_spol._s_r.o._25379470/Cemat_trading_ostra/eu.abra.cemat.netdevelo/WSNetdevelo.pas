function GetFirmPRice(Self: TNxWebServicesHelper;Firm_ID: String;StoreCard_ID: String;Qunit:string):Extended;
Const
  cPrice = '1000000101';
  cCurrency = '0000CZK000';
Var
 mOLE:Variant;
 mEval:String;
begin
 Result:=0;
  mOLE:=GetAbraOLEApplication;
    mEval := 'NxRoundByValue(NxGetStoreCardUnitPriceDef(' + QuotedStr(Firm_ID) + ',' + QuotedStr('') + ','
       + QuotedStr(StoreCard_ID) + ','
       + QuotedStr(cPrice) + ','
       + QuotedStr(Qunit) + ',' + 'false,'
       + QuotedStr(cCurrency)
       + ', NxNow()),1,0.01)';
    //NxGetStoreCardUnitPriceDef(Firm_ID, Store_ID, StoreCard_ID, PriceDefinition_ID,
    // StoreUnit_ID.Code, False, NxGetCompanyCurrencyID, Date)
    Result :=  strtofloat(mOLE.Evaluate(mEval));

 
end;

function SetStatus(Self: TNxWebServicesHelper;ROHEAD_ID: String):String;
Var
mReceivedOrder: TNxCustomBusinessObject;
begin
  Result:='Nic';
   if not(NxIsEmptyOID(ROHEAD_ID)) then begin
   mReceivedOrder:=self.ObjectSpace.CreateObject(Class_ReceivedOrder);
   mReceivedOrder.Load(ROHEAD_ID,nil);
   mReceivedOrder.SetFieldValueAsString('X_status','1A00000101');
   mReceivedOrder.Save;
   mReceivedOrder.Free;

   end;
end;

function GetStatus(Self: TNxWebServicesHelper;DateOfChange: TDateTime):TStringDynArray; 
const
  cSQL = 'select RO.ExternalNumber as externalNumber, DD.Code as status, RO.X_package_no as balik from ReceivedOrders ro left join defrolldata dd  on ro.x_status=dd.id '+
         ' where '+
         ' dd.clsid=''U0FCEIJNJBDOP3BCFCVUWZ3ADS''  and ro.CorrectedAt$DATE>=%d and ro.x_status is not null and ro.docqueue_ID=''1U00000101'' ';


  cRowFormatData = 'DATA|%s|%s|%s';
  cRowFormatError = 'ERR|%s';
var
  mR : TMemoryDataset;
  mDateInt: Integer;
begin
  NxScriptingLog.EnterSection('Status', logNotice);
    OutputDebugString(cSQL);
  try
    mDateInt:=DaysBetween(StrToDate('1.1.1900'),DateOfChange)+2;
    try
      SetLength(Result, 1);
      Result[0] := Format(cRowFormatError, ['Nenalezen žádný záznam']);
      mR := TMemoryDataset.Create(nil);
      try
        Self.ObjectSpace.SQLSelect2(format(cSQL,[mDateint]), mR);
        if not mR.EOF then begin
          SetLength(Result, 0);
          mR.First;
          while not mR.EOF do begin
            SetLength(Result, Length(Result) + 1);
            Result[Length(Result)-1] := format(cRowFormatData , [mR.FieldByName('externalnumber').AsString,
                                                                 mR.FieldByName('status').AsString,
                                                                 mR.FieldByName('balik').AsString]);
            mR.Next;
          end;
        end;
      finally
        mR.Free;
      end;
    except
      SetLength(Result, 1);
      Result[0] := 'ERR|' + ExceptionMessage;
    end;
  finally
    NxScriptingLog.LeaveSection('status', logNotice);
  end;
end;

function GenerateROHEAD(Self: TNxWebServicesHelper;Firm_ID: String;FirmOffice_ID: String;Person_ID: String;Payment_type: String;Transport_type: String;
                        ExternalNumber: String;Date: TDateTime;dodaci_firma:String; ulice:string;mesto:string;psc:string;telefon:string; poznamka:string):String;
Var
mReceivedOrder: TNxCustomBusinessObject;

begin
 Result:='0000000000';
     mReceivedOrder:=self.ObjectSpace.CreateObject('01CPMINJW3DL342X01C0CX3FCC');
     mReceivedOrder.New;
     mReceivedOrder.Prefill;
     mReceivedOrder.SetFieldValueAsString('DocQueue_ID','1U00000101');
     mReceivedOrder.SetFieldValueAsString('Firm_ID',Firm_ID);
     if not(FirmOffice_ID='0') then mReceivedOrder.SetFieldValueAsString('FirmOffice_ID',FirmOffice_ID);
     mReceivedOrder.SetFieldValueAsString('Person_ID',Person_ID);
     mReceivedOrder.SetFieldValueAsString('ExternalNumber',ExternalNumber);
     mReceivedOrder.SetFieldValueAsString('PaymentType_ID',scrGetPayment_ID(self.ObjectSpace,'Code',Payment_type));
     mReceivedOrder.SetFieldValueAsString('TransportationType_ID',scrGetTransport_ID(self.ObjectSpace,'Code',Transport_type));
     mReceivedOrder.SetFieldValueAsInteger('DealerDiscountKind',0);
     mReceivedOrder.SetFieldValueAsDateTime('DocDate$date',Date);
     mReceivedOrder.SetFieldValueAsString('U_name',dodaci_firma);
     mReceivedOrder.SetFieldValueAsString('U_street',ulice);
     mreceivedorder.SetFieldValueAsString('U_city_postcode',mesto);
     mReceivedOrder.SetFieldValueAsString('U_postcode',psc);
     mReceivedOrder.SetFieldValueAsString('U_phone',telefon);
     mReceivedOrder.SetFieldValueAsString('U_note',poznamka);


     mReceivedOrder.Save;
     Result:=mReceivedOrder.OID;
     mReceivedOrder.Free;



end;




function AddRowRO(Self: TNxWebServicesHelper;StoreCard_Code: String;Quantity: Extended;UnitPrice: Extended;Parent_ID: String;RowType: Integer;RowText: String;OZ_ID: String):String;
Var
mReceivedOrder, mRORow: TNxCustomBusinessObject;
mRows: TNxCustomBusinessMonikerCollection;


begin
  Result:='Chyba';
  mReceivedOrder:=self.ObjectSpace.CreateObject('01CPMINJW3DL342X01C0CX3FCC');
  if not(NxIsEmptyOID(Parent_ID)) then begin
    mReceivedOrder.Load(Parent_ID,nil);
    mRows:= mReceivedOrder.GetLoadedCollectionMonikerForFieldCode(mReceivedOrder.GetFieldCode('Rows'));
    if RowType=3 then begin
    mRORow:= mRows.AddNewObject;
    mRORow.SetFieldValueAsInteger('RowType',3);
    mRORow.SetFieldValueAsString('Store_ID','1600000101');
    mRORow.SetFieldValueAsString('StoreCard_ID',StoreCard_Code);
    mRORow.SetFieldValueAsFloat('Quantity',Quantity);
    mROROW.SetFieldValueAsFloat('UnitPrice',UnitPrice);
    mRORow.SetFieldValueAsstring('Division_ID','1000000101');
    if not(NxIsEmptyOID(OZ_ID)) then mRORow.SetFieldValueAsString('BusOrder_ID',OZ_ID);
    end;
    if RowType=1 then begin
     mRORow:= mRows.AddNewObject;
    mRORow.SetFieldValueAsInteger('RowType',1);
    mRORow.SetFieldValueAsstring('Division_ID','1000000101');
    mRoRow.SetFieldValueAsFloat('TotalPrice',UnitPrice);
    mRORow.SetFieldValueAsFloat('VatRate',21);
    mRORow.SetFieldValueAsString('VatRAte_ID','02100X0000');
    mRORow.SetFieldValueAsString('Text',RowText);
    if not(NxIsEmptyOID(OZ_ID)) then mRORow.SetFieldValueAsString('BusOrder_ID',OZ_ID);
    
    end;
    if RowType=0 then begin
     mRORow:= mRows.AddNewObject;
    mRORow.SetFieldValueAsInteger('RowType',0);
    mRORow.SetFieldValueAsstring('Division_ID','1000000101');
    mRORow.SetFieldValueAsString('Text',RowText);
    if not(NxIsEmptyOID(OZ_ID)) then mRORow.SetFieldValueAsString('BusOrder_ID',OZ_ID);

    end;
    mReceivedOrder.Save;
    Result:='Vloženo';
    mReceivedOrder.Free;
  end;
end;





function GetStoreCard(Self: TNxWebServicesHelper;Code: String):TStringDynArray; 
begin
end;


function scrGetPayment_ID(AOS : TNxCustomObjectSpace; AFieldName : string; AValue : string) : string;
 const
  cSQL = 'SELECT ID FROM PaymentTypes WHERE %s like ''%s'' and Hidden=''N''';
 var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [AFieldName, AValue]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;



function scrGetTransport_ID(AOS : TNxCustomObjectSpace; AFieldName : string; AValue : string) : string;
const
  cSQL = 'SELECT ID FROM TransportationTypes WHERE %s like ''%s'' and Hidden=''N''';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [AFieldName, AValue]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;


begin
end.