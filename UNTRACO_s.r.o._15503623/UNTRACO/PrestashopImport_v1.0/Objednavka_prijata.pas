uses 'PrestashopImport_v1.0.fce';
procedure ZpracujSouborZFronty (OS: TNxCustomObjectSpace; var ProcessContinue: Boolean; Directory: string; FileName: string);
begin
  ProcessContinue := ImportFile(OS, Directory + '\' + FileName,Directory,filename);
end;


function ImportFile(OS: TNxCustomObjectSpace; AFileName: string;directory: string;filename: string) : Boolean;
var
  mXMLHead : TNxScriptingXMLWrapper;
  //mDoklad : string;
  i,ii,o,a : integer;
  mres,mres1: TStringList;
  mID: String;
  aaaaa: string;
  saved: integer;
  x:integer;
  aa:Double;
  mfirm: TNxCustomBusinessObject;
  mstorecard: TNxCustomObjectSpace;
  mrow: TNxCustomBusinessObject;
  mbusorder: TNxCustomBusinessObject;
  maddress: TNxCustomBusinessObject;
  mhead: TNxHeaderBusinessObject;
  mFirm_ID, mOrder_ID, mIDdoklad,mID_Store,mID_StoreCard,mID_PaymentType,mID_TransportationType, mID_IncomeType,  mID_odberatel, mID_dodavatel, mID_Docqueue, mID_BusOrder,mID_Division, mID_Country, mID_Currency,mID_Vatrate,mID_Row: string;
  aresult:Boolean;
  mexistuje:string;
  oprava : boolean;
  mMon : TNxCustomBusinessMonikerCollection;
  mS_code:string;
begin

  try
    if not FileExists(AFileName) then begin
      Result := False;
      exit;
    end;
 mXMLHead := TNxScriptingXMLWrapper.Create;
 mXMLHead.loadFromFile(AFileName);
 mID_odberatel:='';
 mID_dodavatel:='';
 mID_Docqueue:= scrGetParam(OS,'X_DocQueue_ID');                //ID řady dokladů pro objednávky z eshopu
 mID_IncomeType:='1100000101 ';   //ID typu příjmu
 mID_Vatrate:= '02100X0000';       //ID DPH sazby
 mID_BusOrder:='';
 mID_Division:=scrGetParam(OS,'X_Division_ID');                 //ID střediska pro předvyplnění na řádcích objednávky
 mID_Store:= scrGetParam(OS,'X_Store_ID');                      //ID Skladu ze kterého se budou čerpat zásoby
 mID_StoreCard:='';
 mID_Country:='';
 mID_Currency:='';
 mID_row:='';
 mexistuje:='';



// Zjištění, zda dokument již existuje

mRes := TStringList.Create;

saved:=0 ;
for o := 0 to mXMLHead.getElementsCountInArray('AbraDocument') - 1 do begin
 oprava:=false;
 mOrder_ID:= scrOrder_ID(OS,'X_VarSymbol',mXMLHead.getElementAsString('ABRADocument['+inttostr(o)+'].REFERENCE'),mID_Docqueue);

 if NxIsEmptyOID(mOrder_ID) then begin
        mFirm_ID:='';
        //mFirmOffice_ID:='';
        mHead := TNxHeaderBusinessObject(OS.CreateObject('01CPMINJW3DL342X01C0CX3FCC'));
        mHead.New;
        mHead.Prefill;
        mHead.SetFieldValueAsString('DocQueue_ID', mID_DocQueue);
        //hledání firmy, případné založení nové firmy
        if not(NxIsBlank(Trim(mXMLHead.getElementAsString('ABRADocument['+inttostr(o)+'].CUSTOMER.COMPANY')))) then mFirm_ID:=scrFirm_ID(OS,'Name', Trim(mXMLHead.getElementAsString('ABRADocument['+inttostr(o)+'].CUSTOMER.COMPANY')));
        if NxIsEmptyOID(mfirm_id) then scrFirm_ID(OS,'OrgIdentNumber', Trim(mXMLHead.getElementAsString('ABRADocument['+inttostr(o)+'].CUSTOMER.ID_NUMBER')));
        if NxIsEmptyOID(mfirm_id) then scrFirm_ID(OS,'VatIdentNumber', Trim(mXMLHead.getElementAsString('ABRADocument['+inttostr(o)+'].CUSTOMER.VAT_NUMBER')));
        if NxIsEmptyOID(mfirm_id) then mFirm_ID:= scrFirm_ID(OS,'Name', Trim(mXMLHead.getElementAsString('ABRADocument['+inttostr(o)+'].CUSTOMER.FIRSTNAME')+' '+mXMLHead.getElementAsString('ABRADocument['+inttostr(o)+'].CUSTOMER.LASTNAME')));
        if NxIsEmptyOID(mFirm_ID) then begin
                mFirm:= OS.CreateObject('4K3EXM5PQBCL35CH000ILPWJF4');
                mFirm.New;
                mFirm.Prefill;
                if not(NxIsBlank(Trim(mXMLHead.getElementAsString('ABRADocument['+inttostr(o)+'].CUSTOMER.COMPANY')))) then mFirm.SetFieldValueAsString('name',Trim(mXMLHead.getElementAsString('ABRADocument['+inttostr(o)+'].CUSTOMER.COMPANY')));
                if (NxIsBlank(Trim(mXMLHead.getElementAsString('ABRADocument['+inttostr(o)+'].CUSTOMER.COMPANY')))) then mFirm.SetFieldValueAsString('Name',Trim(mXMLHead.getElementAsString('ABRADocument['+inttostr(o)+'].CUSTOMER.FIRSTNAME')+' '+mXMLHead.getElementAsString('ABRADocument['+inttostr(o)+'].CUSTOMER.LASTNAME')));
                mFirm.SetFieldValueAsString('VatIdentNumber',Trim(mXMLHead.getElementAsString('ABRADocument['+inttostr(o)+'].CUSTOMER.VAT_NUMBER')));
                mFirm.SetFieldValueAsString('OrgIdentNumber',Trim(mXMLHead.getElementAsString('ABRADocument['+inttostr(o)+'].CUSTOMER.ID_NUMBER')));
                mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('PostCode',copy(mXMLHead.getElementAsString('ABRADocument['+inttostr(o)+'].CUSTOMER.POSTCODE'),1,9));
                mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('Street',copy(mXMLHead.getElementAsString('ABRADocument['+inttostr(o)+'].CUSTOMER.ADDRESS1'),1,60));
                mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('City',copy(mXMLHead.getElementAsString('ABRADocument['+inttostr(o)+'].CUSTOMER.CITY'),1,60));
                mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('PhoneNumber1',copy(mXMLHead.getElementAsString('ABRADocument['+inttostr(o)+'].CUSTOMER.PHONE_MOBILE'),1,30));
                mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('PhoneNumber2',copy(mXMLHead.getElementAsString('ABRADocument['+inttostr(o)+'].CUSTOMER.PHONE'),1,30));
                mFirm.GetMonikerForFieldCode(mFirm.GetFieldCode('ResidenceAddress_ID')).BusinessObject.SetFieldValueAsString('EMail',copy(mXMLHead.getElementAsString('ABRADocument['+inttostr(o)+'].CUSTOMER.EMAIL'),1,100));
                mFirm.Save;
                mFirm_ID:=mFirm.OID;
                mFirm.Free;
        end;
        mHead.SetFieldValueAsString('Firm_ID',mFirm_ID);
        mHead.SetFieldValueAsDateTime('DocDate$DATE', CFxDate.StrToDateEx(mXMLHead.getElementAsString('ABRADocument['+inttostr(o)+'].DATE_ADD'),'yyyy-mm-dd','-'));
        mHead.SetFieldValueAsString('X_VarSymbol',mXMLHead.getElementAsString('ABRADocument['+inttostr(o)+'].REFERENCE'));
        mHead.SetFieldValueAsBoolean('PricesWithVAT', true);
        mID_TransportationType:= scrTransportationType_ID(OS, 'X_Carrier_ID', mXMLHead.getElementAsString('ABRADocument['+inttostr(o)+'].ID_CARRIER'));
        if not NxIsBlank(mID_TransportationType)then
                mHead.SetFieldValueAsString('TransportationType_ID',mID_TransportationType);
        mID_PaymentType:= scrPaymentType_ID(OS, 'X_Payment', trim(mXMLHead.getElementAsString('ABRADocument['+inttostr(o)+'].PAYMENT')));
        if not NxIsBlank(mID_PaymentType)then
                mHead.SetFieldValueAsString('PaymentType_ID',mID_PaymentType);

        for i := 0 to mXMLHead.getElementsCountInArray('AbraDocument['+inttostr(o)+'].Rows.Row') - 1 do begin
                mRow := mHead.Rows.AddNewObject;
                if mXMLHead.getElementAsString('AbraDocument['+inttostr(o)+'].Rows.Row['+inttostr(i)+'].ROW_TYPE')='1' then begin
                        mRow.SetFieldValueAsInteger('RowType',1);
                        mRow.SetFieldValueAsString('Division_ID', mID_Division);
                        mRow.SetFieldValueAsString('Text',mXMLHead.getElementAsString('AbraDocument['+inttostr(o)+'].Rows.Row['+inttostr(i)+'].TEXT'));
                        mRow.SetFieldValueAsFloat('TotalPrice',NxStrToFloat(mXMLHead.getElementAsString('AbraDocument['+inttostr(o)+'].Rows.Row['+inttostr(i)+'].SHIPPING'),'.'));
                        mRow.SetFieldValueAsString('VATRate_ID',mID_Vatrate);
                end;
                if mXMLHead.getElementAsString('AbraDocument['+inttostr(o)+'].Rows.Row['+inttostr(i)+'].ROW_TYPE')='3' then begin
                        mRow.SetFieldValueAsInteger('RowType',3);
                        mRow.SetFieldValueAsString('Store_ID', mID_Store);
                        mID_StoreCard:= scrStoreCard_ID(OS, 'Code', mXMLHead.getElementAsString('AbraDocument['+inttostr(o)+'].Rows.Row['+inttostr(i)+'].REFERENCE'));
                        mRow.SetFieldValueAsString('Storecard_ID', mID_StoreCard);
                        mRow.SetFieldValueAsFloat('Quantity',StrToFloat(mXMLHead.getElementAsString('AbraDocument['+inttostr(o)+'].Rows.Row['+inttostr(i)+'].PRODUCT_QUANTITY')));
                        mRow.SetFieldValueAsString('Division_ID', mID_Division);
                        mRow.SetFieldValueAsFloat('UnitPrice',NxStrToFloat(mXMLHead.getElementAsString('AbraDocument['+inttostr(o)+'].Rows.Row['+inttostr(i)+'].UNIT_PRICE'),'.'));
                        mRow.SetFieldValueAsString('VATRate_ID',mID_Vatrate);
                       // mRow.SetFieldValueAsString('IncomeType_ID',mID_IncomeType);
                       //mRow.free;
                end;
        end;
        mhead.Save;
        saved:= saved + 1;
        mhead.free;
 End;

end;
Result:= True;


finally
 ShowMessage('Uloženo objednávek: '+inttostr(saved)+' z '+inttostr(mXMLHead.getElementsCountInArray('AbraDocument')));
end;
end;

begin
end.