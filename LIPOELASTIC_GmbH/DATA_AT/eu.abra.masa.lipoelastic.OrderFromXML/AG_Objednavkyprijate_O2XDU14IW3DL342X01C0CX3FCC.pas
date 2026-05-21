procedure InitSite_Hook(Self: TSiteForm);
var
  mAction:TAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImportXML';
  mAction.Caption := '##Import XML order##';
  mAction.Hint := 'Naimportuje XML data';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportXML;
end;

Procedure ImportXML(Sender:TComponent);
var
 mSite:TSiteForm;
 mOpenDlg: TOpenDialog;
 mOS:TNxCustomObjectSpace;
 i,j,k,mCount:integer;
 mXMLHead:TNxScriptingXMLWrapper;
 mBO, mRowBO:TNxCustomBusinessObject;
 mStreet, mCity, mPostCode, mFirmOffice_ID, mOrder_ID, mStore_ID, mCountryCode, mRecipient:string;
 mCodeEan,mStoreCard_ID:string;
 mRows:TNxCustomBusinessMonikerCollection;
 mQuantity:extended;
 mSQLStreet,mSQLPostCode, mSQLCity, mSQLCountryCode, mSQLRecipient:string;
 mOrderList:TStringList;
begin
 mSite:=TComponent(Sender).DynSite;
 mOS:=mSite.BaseObjectSpace;
 mOpenDlg:=TOpenDialog.Create(sender);
 mOpenDlg.Title := 'Import from XML';
 mOpenDlg.Filter := 'Files XML (*.xml)| *.xml';
 mOpenDlg.Options := [ofAllowMultiSelect];
 if mOpenDlg.Execute then begin
  try
    mCount:=mOpenDlg.Files.Count;
    mOrderList:=TStringList.create;
    WaitWin.StartProgress('Please, wait ...', '', mCount);
      for i:=0 to mOpenDlg.Files.Count-1 do begin
       mXMLHead:=TNxScriptingXMLWrapper.Create;
       mXMLHead.loadFromFile(mOpenDlg.Files[i]);
       for j:=0 to mXMLHead.getElementsCountInArray('SalesOrders.SalesOrder')-1 do begin
        mOrder_ID:=mOS.SQLSelectFirstAsString('Select id from receivedorders where externalNumber='+QuotedStr(mXMLHead.getElementAsString('SalesOrders.SalesOrder['+IntToStr(j)+'].YourRef')),'');
        if NxIsEmptyOID(mOrder_ID) then begin
         mBO:=mOS.CreateObject(Class_ReceivedOrder);
         mBO.New;
         mBO.Prefill;
         mBO.SetFieldValueAsString('DocQueue_ID','~000000002');
         mbo.SetFieldValueAsString('Firm_ID', mos.SQLSelectFirstAsString('select id from firms where code='+
                                              Quotedstr(mXMLHead.getAttributeValue('SalesOrders.SalesOrder['+IntToStr(j)+'].OrderedBy','code'))+
                                              ' and firm_id is null and hidden='+QuotedStr('N')));
         if AnsiLeftStr(mBO.GetFieldValueAsString('Firm_ID.VatIdentNumber'),2)='DE' then begin

         end;
         mBO.SetFieldValueAsString('ExternalNumber',mXMLHead.getElementAsString('SalesOrders.SalesOrder['+IntToStr(j)+'].YourRef'));
         mStreet:='';
         mPostCode:='';
         mCity:='';
         if ElementExists(mXMLHead,'SalesOrders.SalesOrder['+IntToStr(j)+'].DeliveryAddress.AddressLine1')
           then mstreet:=mXMLHead.getElementAsString('SalesOrders.SalesOrder['+IntToStr(j)+'].DeliveryAddress.AddressLine1');
         if ElementExists(mXMLHead,'SalesOrders.SalesOrder['+IntToStr(j)+'].DeliveryAddress.PostalCode')
           then mPostCode:=AnsiLeftStr(mXMLHead.getElementAsString('SalesOrders.SalesOrder['+IntToStr(j)+'].DeliveryAddress.PostalCode'),10);
         if ElementExists(mXMLHead,'SalesOrders.SalesOrder['+IntToStr(j)+'].DeliveryAddress.City')
           then mCity:=mXMLHead.getElementAsString('SalesOrders.SalesOrder['+IntToStr(j)+'].DeliveryAddress.City');
         if ElementExists(mXMLHead,'SalesOrders.SalesOrder['+IntToStr(j)+'].DeliverTo.Name')
           then mRecipient:=mXMLHead.getElementAsString('SalesOrders.SalesOrder['+IntToStr(j)+'].DeliverTo.Name');
         if ElementExists(mXMLHead,'SalesOrders.SalesOrder['+IntToStr(j)+'].DeliveryAddress.Country')
           then mCountryCode:=mXMLHead.getAttributeValue('SalesOrders.SalesOrder['+IntToStr(j)+'].DeliveryAddress.Country','code');
         if NxIsBlank(mCountryCode) then begin mCountryCode:='AT';

         end;
         // Aktuálně se používá jen pro import DE B2B objednávek s doručením v AT
         mBO.SetFieldValueAsInteger('TradeType',1);
         mBO.SetFieldValueAsString('Country_ID','00000AT000');

         if not(NxIsBlank(mCity+mPostCode+mStreet+mCountryCode+mRecipient)) then begin
           mSQLStreet:='';
           mSQLCity:='';
           mSQLPostCode:='';
           mSQLCountryCode:='';
           mSQLRecipient:='';
           if not(NxIsBlank(mStreet)) then mSQLStreet:=' and a.street like N'+QuotedStr(mStreet);
           if not(NxIsBlank(mCity)) then mSQLCity:=' and a.city like N'+QuotedStr(mCity);
           if not(NxIsBlank(mPostCode)) then mSQLPostCode:=' and a.postcode like N'+QuotedStr(mPostCode);
           if not(NxIsBlank(mCountryCode)) then mSQLCountryCode:=' and a.countrycode like N'+QuotedStr(mCountryCode);
           if not(NxIsBlank(mRecipient)) then mSQLRecipient:=' and a.recipient like N'+QuotedStr(mRecipient);
           mFirmOffice_ID:=mOS.SQLSelectFirstAsString('Select fo.id from firmoffices fo left join addresses a on fo.address_id=a.id where fo.parent_id='+QuotedStr(mbo.GetFieldValueAsString('Firm_ID'))
                                              +mSQLStreet+mSQLCity+mSQLPostCode+mSQLRecipient+mSQLCountryCode,'');

           if NxIsEmptyOID(mFirmOffice_ID) then begin
             mFirmOffice_ID:=GetOrCreateFirmOffice(mOS, mbo.GetFieldValueAsString('Firm_ID'), mStreet,mPostCode, mCity, mCountryCode, mRecipient);
             mFirmOffice_ID:=mOS.SQLSelectFirstAsString('Select fo.id from firmoffices fo left join addresses a on fo.address_id=a.id where fo.parent_id='+QuotedStr(mbo.GetFieldValueAsString('Firm_ID'))+
                                              mSQLStreet+mSQLCity+mSQLPostCode+mSQLRecipient+mSQLCountryCode,'');
           end;
           mBO.SetFieldValueAsString('FirmOffice_ID', mFirmOffice_id);
         end;

         mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows'));
         for k:=0 to mXMLHead.getElementsCountInArray('SalesOrders.SalesOrder['+IntToStr(j)+'].SalesOrderLine')-1 do begin
            mCodeEan:=mXMLHead.getAttributeValue('SalesOrders.SalesOrder['+IntToStr(j)+'].SalesOrderLine['+IntToStr(k)+'].Item','code');
            mStoreCard_ID:=GetStoreCard(mOS, mCodeEan);
            mRowBO:=mRows.AddNewObject;
            mRowBO.Prefill;
            mRowBO.SetFieldValueAsInteger('RowType',3);
            mRowBO.SetFieldValueAsString('Store_ID','~00000011Y');
            mRowBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
            mQuantity:=NxIBStrToFloat(mXMLHead.getElementAsString('SalesOrders.SalesOrder['+IntToStr(j)+'].SalesOrderLine['+IntToStr(k)+'].Quantity'));
            if mQuantity>0 then
             mRowBo.SetFieldValueAsFloat('Quantity',mQuantity);
            mRowBO.SetFieldValueAsString('Division_ID','1000000101');
            mRowBO.SetFieldValueAsString('VATRate_ID','~000000001');
            // Zadání od Ezgi, objednávky s YHF mají mít 0 % dph
          end;
         mbo.save;
         mOrderList.add(QuotedStr(mBO.oid));
         mBO.free;
        end;
       end;
       mXMLHead.free;
       WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(mCount));
       WaitWin.StepIt;
      end;
      WaitWin.Stop;
      if mOrderList.count>0 then
       msite.ShowSite(Site_ReceivedOrders,true,'QueryByUserDynSQLCondition;A.ID in ('+mOrderList.CommaText+');New orders');
     except
      WaitWin.Stop;
      NxShowSimpleMessage(ExceptionMessage,mSite);
  end;
 end;
end;

function ElementExists(mXMLHead : TNxScriptingXMLWrapper; AName: string): Boolean;
begin
  try
    if mXMLHead.getElementAsString(AName)<>'' then Result:= True;
  except
    Result:= False;
  end;
end;

Function GetOrCreateFirmOffice(var aOS:TNxCustomObjectSpace;var mFirm_ID, eStreet, ePostCode, eCity, eCountryCode, eRecipient:string):string;
var
 mFirmOffice_ID:string;
 mBO, mFirmOfficeBO:TNxCustomBusinessObject;
 mFirmOffices:TNxCustomBusinessMonikerCollection;
begin
    mBO:=aOS.CreateObject(Class_Firm);
   mBO.Load(mFirm_ID);
   mFirmOffices:=mBO.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('FirmOffices'));
   mFirmOfficeBO:=mFirmOffices.AddNewObject;
   mFirmOfficeBO.SetFieldValueAsString('Name','Betriebsstätte '+eStreet);
   mFirmOfficeBO.SetFieldValueAsBoolean('SynchronizeAddress',False);
   mFirmOfficeBO.SetFieldValueAsString('Address_ID.Street',eStreet);
   mFirmOfficeBO.SetFieldValueAsString('Address_ID.PostCode',ePostCode);
   mFirmOfficeBO.SetFieldValueAsString('Address_ID.City',eCity);
   mFirmOfficeBO.SetFieldValueAsString('Address_ID.CountryCode',eCountryCode);
   mFirmOfficeBO.SetFieldValueAsString('Address_ID.Recipient',eRecipient);
   if eCountryCode='AT' then mFirmOfficeBO.SetFieldValueAsString('Address_ID.Country','Austria');
   if eCountryCode='DE' then mFirmOfficeBO.SetFieldValueAsString('Address_ID.Country','Germany');
   mbo.save;
   mFirmOffice_ID:=mFirmOfficeBO.OID;
   mbo.free;
 Result:=mFirmOffice_ID;
end;


function GetStoreCard(var aOS:TNxCustomObjectSpace; var aCode:string;):string;
var
 mBO, mVATrateBO:TNxCustomBusinessObject;
 mStoreCard_ID:string;
 mUnits, mVATRates:TNxCustomBusinessMonikerCollection;
begin
 if NxIsNumeric(aCode) and (Length(aCode)=13) then begin
   mStoreCard_ID:=aOS.SQLSelectFirstAsString('SELECT  A.id FROM StoreCards A WHERE (((A.EAN LIKE N'+QuotedStr(aCode)+' ESCAPE '+QuotedStr('~')+') OR '+
                                             '(A.ID IN (SELECT SU.Parent_ID FROM StoreEANs SE JOIN StoreUnits SU ON SE.Parent_Id = SU.Id '+
                                             'WHERE SU.Parent_ID = A.ID AND SE.Ean LIKE N'+QuotedStr(aCode)+' ESCAPE '+QuotedStr('~')+')))) AND A.Hidden = '+Quotedstr('N'),'');
 end
  else mStoreCard_ID:=aOS.SQLSelectFirstAsString('Select id from storecards where code='+QuotedStr(aCode)+' and hidden='+QuotedStr('N'),'');

 Result:=mStoreCard_ID;
end;

begin
end.