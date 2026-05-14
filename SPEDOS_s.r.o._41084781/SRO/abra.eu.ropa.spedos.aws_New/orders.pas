
uses 'abra.eu.ropa.spedos.aws_New.lib';

var
  mBusOrder_ID:string;
    xbusorder_ID:string;
    ybusorder_ID:string;

const
  cDebug = True;

  cHeadDescription = ['ExternalID', 'DocQueue_ID', 'DocDate', 'Description', 'TradeType', 'Country_ID', 'Currency_ID', 'CurrRate', 'RefCurrRate',  'ConstSymbol_ID',  'PaymentType_ID', 'TransportationType_ID', 'BankAccount_ID', 'ExternalNumber', 'Confirmed', 'Closed'];
  cRowDescription = ['RowType', 'Text', 'Store_Code', 'StoreCard_Code', 'Quantity', 'QUnit', 'UnitPrice', 'BusOrder_Code', 'BusOrder_Name', 'BusTransaction_Code', 'Division_ID', 'BusOrder_Code1', 'BusOrder_Name1'];
  cFirmDescription = ['OrgIdentNumber', 'Code', 'Name', 'VATIdentNumber'];
  cAddressDescription = ['Street', 'City', 'PostCode'];
  cSeparator = '|';
  
  // tyto hodnoty se bez konverzi prenesou z parametru do hlavicky dokladu
  cAutoFillItems = ['DocQueue_ID', 'Firm_ID', 'Description', 'Country_ID', 'Currency_ID', 'ConstSymbol_ID', 'PaymentType_ID', 'TransportationType_ID', 'BankAccount_ID', 'ExternalNumber'];
  cSQL = 'SELECT ID FROM BusOrders WHERE Code like ''%s'' and Hidden=''N''';



function NewOrder(Self: TNxWebServicesHelper; Head: String; Rows: TStringDynArray;Firm: String; FirmResidence: String):String;
var
  mDoc, mDocRows, mDocRow : TNxParameters;
  i : integer;
  mStr : string;
  mSList : TStrings;
  mOrder, mOrderRow,mbo3 : TNxCustomBusinessObject;
  mRows : TNxCustomBusinessMonikerCollection;
  m_busorder_ID:string;
  mList : TStringList;
  aresult: string;
begin
  Result := '';
  try
    mDoc := TNxParameters.Create;
    try
      ParseData(mDoc, cHeadDescription, cSeparator, Head);
      mDocRows := TNxParameters(mDoc.GetOrCreateParam(dtList, 'rows', pkInput));
      for i := 0 to Length(Rows) - 1 do begin
        mDocRow := TNxParameters(mDocRows.GetOrCreateParam(dtList, IntToStr(i), pkInput));
        ParseData(mDocRow, cRowDescription, cSeparator, Rows[i]);
        mDocRow.GetOrCreateParam(dtString, 'VATRate', pkInput).AsString := '21';
      end;
      ParseData(TNxParameters(mDoc.GetOrCreateParam(dtList, 'Firm', pkInput)), cFirmDescription, cSeparator, Firm);
      ParseData(TNxParameters(mDoc.GetOrCreateParam(dtList, 'FirmResidence', pkInput)), cAddressDescription, cSeparator, FirmResidence);
      
      iCheckValues(Self.ObjectSpace, mDoc);

      if cDebug then begin
        mStr := MakeTempFileName;
        mDoc.SaveToFile(Format('%saws%s.bin.log', [NxGetTempDir, mStr]));
        mSList := TStringList.Create;
        try
          mSList.Text := mDoc.Text;
          mSList.SaveToFile(Format('%saws%s.log', [NxGetTempDir, mStr]));
        finally
          mSList.Free;
        end;
      end;

      if not NxIsEmptyOID(mDoc.ParamByName('ID').AsString) then begin
        Result := mDoc.ParamByName('ID').AsString;
        exit;
      end;

      // vlastni vytvoreni objednavky
      mOrder := Self.ObjectSpace.CreateObject('01CPMINJW3DL342X01C0CX3FCC'); //ReceivedOrder
      mOrder.New;
      mOrder.Prefill;
      mOrder.SetFieldValueAsInteger('TradeType', StrToInt(mDoc.ParamByName('TradeType').AsString));
      for i := 0 to Length(cAutoFillItems) - 1 do
        mOrder.SetFieldValueAsString(cAutoFillItems[i], mDoc.ParamByName(cAutoFillItems[i]).AsString);
      mOrder.SetFieldValueAsDateTime('DocDate$DATE', StrToDate(mDoc.ParamByName('DocDate').AsString));
      if mOrder.GetFieldValueAsString('Currency_ID') <> Self.Context.GetCompanyCache.CurrencyID then begin
        mOrder.SetFieldValueAsFloat('CurrRate', NxIBStrToFloat(mDoc.ParamByName('CurrRate').AsString));
        mOrder.SetFieldValueAsFloat('RefCurrRate', NxIBStrToFloat(mDoc.ParamByName('RefCurrRate').AsString));
      end;
      mOrder.SetFieldValueAsBoolean('Confirmed', mDoc.ParamByName('Confirmed').AsString='A');
      mOrder.SetFieldValueAsBoolean('Closed', mDoc.ParamByName('Closed').AsString='A');
      mOrder.SetFieldValueAsInteger('X_ExternalID', StrToInt(mDoc.ParamByName('ExternalID').AsString));
      mOrder.SetFieldValueAsString('X_Protokol_No', mDoc.ParamByName('ExternalNumber').AsString);
      mRows := mOrder.GetCollectionMonikerForFieldCode(mOrder.GetFieldCode('Rows'));

      for i := 0 to TNxParameters(mDoc.ParamByName('rows')).Count - 1 do begin
        mDocRow := TNxParameters(TNxParameters(mDoc.ParamByName('rows')).Params[i]);
        mOrderRow := mRows.AddNewObject;
        mOrderRow.Prefill;
        mOrderRow.SetFieldValueAsInteger('RowType', StrToInt(mDocRow.ParamByName('RowType').AsString));
        if mOrderRow.GetFieldValueAsInteger('RowType') = 3 then begin
          mOrderRow.SetFieldValueAsString('Store_ID', mDocRow.ParamByName('Store_ID').AsString);
          mOrderRow.SetFieldValueAsString('StoreCard_ID', mDocRow.ParamByName('StoreCard_ID').AsString);
        end else
          mOrderRow.SetFieldValueAsString('Text', mDocRow.ParamByName('Text').AsString);
        if mOrderRow.GetFieldValueAsInteger('RowType') >= 2 then begin
          mOrderRow.SetFieldValueAsFloat('Quantity', NxIBStrToFloat(mDocRow.ParamByName('Quantity').AsString));
          mOrderRow.SetFieldValueAsString('QUnit', mDocRow.ParamByName('QUnit').AsString);
          mOrderRow.SetFieldValueAsFloat('UnitPrice', NxIBStrToFloat(mDocRow.ParamByName('UnitPrice').AsString));
        end;
        if mOrderRow.GetFieldValueAsInteger('RowType') >= 1 then begin
          mOrderRow.SetFieldValueAsFloat('VATRate', NxIBStrToFloat(mDocRow.ParamByName('VATRate').AsString));
          mOrderRow.SetFieldValueAsString('VATRate_ID', mDocRow.ParamByName('VATRate_ID').AsString);
        end;


    
    


    //nadřazená zakázka
        if mDocRow.ParamByName('BusOrder_Code1').AsString<>'' then begin
            mList:= TStringList.Create;
            //mList := TStringList;
            try
                mOrder.ObjectSpace.SQLSelect(Format(cSQL, [mDocRow.ParamByName('BusOrder_Code1').AsString]), mList);
                if mList.Count > 0 then begin
                    ybusorder_ID:= mList.Strings[0]
                end else begin
                    mBO3 := mOrder.ObjectSpace.CreateObject('K2WTYL304VD13ACL03KIU0CLP4'); // Zakázka
                    try
                        mBO3.New;
                        mBO3.Prefill;
                        mBO3.SetFieldValueAsString('Code', mDocRow.ParamByName('BusOrder_Code1').AsString);
                        mBO3.SetFieldValueAsString('Name', mDocRow.ParamByName('BusOrder_Name1').AsString);
                        ybusorder_ID:=mBO3.OID;
                        mBO3.Save;
                    finally;
                        mBO3.free;
                    end;

                end;
            finally;
                mList.Free;
            end;
        end;






    // výrobní číslo dvěří
        if mDocRow.ParamByName('BusOrder_Code').AsString<>'' then begin
            mList:= TStringList.Create;
            try
                mOrder.ObjectSpace.SQLSelect(Format(cSQL, [mDocRow.ParamByName('BusOrder_Code').AsString]), mList);
                if mList.Count > 0 then begin
                    xbusorder_ID:= mList.Strings[0]
                end else begin
                    mBO3 := mOrder.ObjectSpace.CreateObject('K2WTYL304VD13ACL03KIU0CLP4'); // Zakázka
                    try
                        mBO3.New;
                        mBO3.Prefill;
                        mBO3.SetFieldValueAsString('Code', mDocRow.ParamByName('BusOrder_Code').AsString);
                        mBO3.SetFieldValueAsString('Name', mDocRow.ParamByName('BusOrder_Name').AsString);
                        mBO3.SetFieldValueAsString('Parent_ID', ybusorder_ID);
                        xbusorder_ID:=mBO3.OID;
                        mBO3.Save;
                    finally;
                        mBO3.free;
                    end;

                end;
            finally;
                mList.Free;
            end;
        end;








        
        mOrderRow.SetFieldValueAsString('Division_ID', mDocRow.ParamByName('Division_ID').AsString);
        mOrderRow.SetFieldValueAsString('BusOrder_ID', xbusorder_ID);
        
        mOrderRow.SetFieldValueAsString('BusTransaction_ID', mDocRow.ParamByName('BusTransaction_ID').AsString);
      end;
      
      
      mOrder.Save;
      Result := mOrder.OID;
    finally
      mDoc.Free;
    end;
   except
     Result := Format('ERR|%s', [ExceptionMessage]);
   end;
end;



procedure iCheckValues(AOS : TNxCustomObjectSpace; ADoc : TNxParameters);
var
  mBO, mBO2, mBO3 : TNxCustomBusinessObject;
  mRows, mRow : TNxParameters;
  i : integer;
  mBusOrder_ID1: string;
begin
  if not Assigned(ADoc) then
    RaiseException('Chybně imporovány parametry.');

  if NxIsBlank(ADoc.ParamByName('ExternalID').AsString) or not NxIsNumeric(ADoc.ParamByName('ExternalID').AsString) then
    RaiseException(Format('Není vyplněno externí číslo (ExternalID), nebo hodnota ''%s'' není číslo.', [ADoc.ParamByName('ExternalID').AsString]));

  ADoc.GetOrCreateParam(dtString, 'ID', pkInputOutput).AsString := GetOrderByExternalID_ID(AOS, ADoc.ParamByName('ExternalID').AsString);
  

  if ADoc.ParamByName('Country_ID').AsString = '00000CZ000' then
    ADoc.GetOrCreateParam(dtInteger, 'TradeType', pkInputOutput).AsInteger := 1 // Tuzemsko
  else begin
    if not IsMemberEU(AOS, ADoc.ParamByName('Country_ID').AsString, StrToDate(ADoc.ParamByName('Date').AsString)) then
      ADoc.GetOrCreateParam(dtInteger, 'TradeType', pkInputOutput).AsInteger := 3 // Mimo EU
    else begin
      ADoc.GetOrCreateParam(dtInteger, 'TradeType', pkInputOutput).AsInteger := 2; // V ramci EU, Platci DPH
    end;
  end;


  ADoc.GetOrCreateParam(dtString, 'Firm_ID', pkInput).AsString := iiGetFirm_ID(AOS, 'OrgIdentNumber', TNxParameters(ADoc.ParamByName('Firm')).ParamByName('OrgIdentNumber').AsString);
  if NxIsEmptyOID(ADoc.ParamByName('Firm_ID').AsString) then begin
    mBO := AOS.CreateObject('4K3EXM5PQBCL35CH000ILPWJF4'); // Firm
    try
      mBO.New;
      mBO.Prefill;
      mBO.SetFieldValueAsString('Name', TNxParameters(ADoc.ParamByName('Firm')).ParamByName('Name').AsString);
      if not NxIsBlank(TNxParameters(ADoc.ParamByName('Firm')).ParamByName('Code').AsString) then
        mBO.SetFieldValueAsString('Code', TNxParameters(ADoc.ParamByName('Firm')).ParamByName('Code').AsString);
      mBO.SetFieldValueAsString('OrgIdentNumber', TNxParameters(ADoc.ParamByName('Firm')).ParamByName('OrgIdentNumber').AsString);
      mBO.SetFieldValueAsString('VATIdentNumber', TNxParameters(ADoc.ParamByName('Firm')).ParamByName('VATIdentNumber').AsString);
      mBO2 := mBO.GetMonikerForFieldCode(mBO.GetFieldCode('ResidenceAddress_ID')).BusinessObject;
      mBO2.SetFieldValueAsString('Street', TNxParameters(ADoc.ParamByName('FirmResidence')).ParamByName('Street').AsString);
      mBO2.SetFieldValueAsString('City', TNxParameters(ADoc.ParamByName('FirmResidence')).ParamByName('City').AsString);
      mBO2.SetFieldValueAsString('PostCode', TNxParameters(ADoc.ParamByName('FirmResidence')).ParamByName('PostCode').AsString);
      ADoc.ParamByName('Firm_ID').AsString := mBO.OID;
      mBO.Save;
    finally
      mBO.Free;
    end;
  end;
  
   mBusOrder_ID1:='';
  for i := 0 to TNxParameters(ADoc.ParamByName('Rows')).Count - 1 do begin
    mRow := TNxParameters(TNxParameters(ADoc.ParamByName('Rows')).Params[i]);
    mRow.GetOrCreateParam(dtString, 'VATRate_ID', pkInput).AsString := GetVATRate_ID(AOS, NxIBStrToFloat('0'+mRow.ParamByName('VATRate').AsString));
    mRow.GetOrCreateParam(dtString, 'BusTransaction_ID', pkInput).AsString := iiGetBusTransaction_ID(AOS, mRow.ParamByName('BusTransaction_Code').AsString);
    mRow.GetOrCreateParam(dtString, 'BusOrder_ID', pkInput).AsString := iiGetBusOrder_ID(AOS, mRow.ParamByName('BusOrder_Code').AsString);
    mRow.GetOrCreateParam(dtString, 'BusOrder_ID1', pkInput).AsString := iiGetBusOrder_ID1(AOS, mRow.ParamByName('BusOrder_Code1').AsString);
    mRow.GetOrCreateParam(dtString, 'Store_ID', pkInput).AsString := iiGetStore_ID(AOS, mRow.ParamByName('Store_Code').AsString);
    mRow.GetOrCreateParam(dtString, 'StoreCard_ID', pkInput).AsString := iiGetStoreCard_ID(AOS, mRow.ParamByName('StoreCard_Code').AsString);

    //nadřazená zakázka
    if NxIsEmptyOID(mRow.ParamByName('BusOrder_ID1').AsString) then begin
       mBusOrder_ID:='';
       mBO3 := AOS.CreateObject('K2WTYL304VD13ACL03KIU0CLP4'); // Zakázka
        try
            mBO3.New;
            mBO3.Prefill;
            mBO3.SetFieldValueAsString('Code', mRow.ParamByName('BusOrder_Code1').AsString);
            mBO3.SetFieldValueAsString('Name', mRow.ParamByName('BusOrder_Name1').AsString);
            mRow.ParamByName('BusOrder_ID').AsString := mBO.OID;
            mBusOrder_ID1:=mBO3.OID;
            mBO3.Save;
        finally
            mBO3.free;
        end;
    end else begin
        mBusOrder_ID1:= mRow.ParamByName('BusOrder_ID1').AsString;
    end;


    // výrobní číslo dvěří
    if NxIsEmptyOID(mRow.ParamByName('BusOrder_ID').AsString) then begin
      mBO := AOS.CreateObject('K2WTYL304VD13ACL03KIU0CLP4'); // Zakázka výrobní číslo
      try
        mBO.New;
        mBO.Prefill;
        mBO.SetFieldValueAsString('Code', mRow.ParamByName('BusOrder_Code').AsString);
        mBO.SetFieldValueAsString('Name', mRow.ParamByName('BusOrder_Name').AsString);
        if mBusOrder_ID1<>'' then begin
            mbo.SetFieldValueAsString('Parent_ID',mBusOrder_ID1);
        end else begin
            mBO.SetFieldValueAsString('Parent_ID', iiGetBusOrder_ID(AOS, mRow.ParamByName('BusOrder_Code1').AsString));
        end;
        
        
        mBusOrder_ID:=mBO.OID;
        mBO.Save;
      finally
        mBO.Free;
      end;
    end;
  end;
  

end;




function iiGetFirm_ID(AOS : TNxCustomObjectSpace; AFieldName : string; AValue : string) : string;
const
  cSQL = 'SELECT ID FROM Firms WHERE %s like ''%s'' and Hidden=''N'' AND Firm_ID is null';
var
  mList : TStringList;
begin
  Result := '';
  mList:= TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [AFieldName, AValue]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function iiGetBusTransaction_ID(AOS : TNxCustomObjectSpace; AValue : string) : string;
const
  cSQL = 'SELECT ID FROM BusTransactions WHERE Code like ''%s'' and Hidden=''N''';
var
  mList : TStringList;
begin
  Result := '';
  mList:= TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [AValue]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;


function iiGetBusOrder_ID(AOS : TNxCustomObjectSpace; AValue : string) : string;
const
  cSQL = 'SELECT ID FROM BusOrders WHERE Code like ''%s'' and Hidden=''N''';
var
  mList : TStringList;
begin
  Result := '';
  mList:= TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [AValue]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

// dohledání nadřazené
function iiGetBusOrder_ID1(AOS : TNxCustomObjectSpace; AValue : string) : string;
const
  cSQL = 'SELECT ID FROM BusOrders WHERE Code like ''%s'' and Hidden=''N''';
var
  mList : TStringList;
begin
  Result := '';
  mList:= TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [AValue]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;




function iiGetStoreCard_ID(AOS : TNxCustomObjectSpace; AValue : string) : string;
begin
  Result := iiGet_ID(AOS, 'StoreCards', 'Code', AValue);
end;

function iiGetStore_ID(AOS : TNxCustomObjectSpace; AValue : string) : string;
begin
  Result := iiGet_ID(AOS, 'Stores', 'Code', AValue);
end;


function iiGet_ID(AOS : TNxCustomObjectSpace; const ATableName : string; const AFieldName : string; const AValue : string) : string;
const
  cSQL = 'SELECT ID FROM %s WHERE %s like ''%s'' and Hidden=''N''';
var
  mList : TStringList;
begin
  Result := '';
  mList:= TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [ATableName, AFieldName, AValue]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;



function GetOrderByExternalID_ID(AOS : TNxCustomObjectSpace; AExternalID : string) : string;
var
  mR : TStrings;
const
  cSQL = 'SELECT A.ID FROM ReceivedOrders A WHERE A.X_ExternalID=''%s''';
begin
  Result := '0000000000';
  mR := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [AExternalID]), mR);
    if mR.Count = 1 then
      Result := mR.strings[0];
  finally
    mR.Free;
  end;
end;



begin
end.