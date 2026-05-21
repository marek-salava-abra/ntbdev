uses '.fce';

{
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction:TAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImpXML';
  mAction.Caption := '##Import XML##';
  mAction.Hint := 'Naimportuje XML data';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportXML;
end;}


Procedure ImportXML(Sender:TComponent);
var
 mSite:TSiteForm;
 mOpenDlg: TOpenDialog;
 mOS:TNxCustomObjectSpace;
 i,j,k,mCount:integer;
 mXMLHead:TNxScriptingXMLWrapper;
 mBO, mRowBO, mFirmBO, mFPersonBO:TNxCustomBusinessObject;
 mStreet, mCity, mPostCode, mFirmOffice_ID, mOrder_ID, mStore_ID:string;
 mCodeEan, mSCName,mStoreCard_ID,mVATName:string;
 mRows, mFPersons:TNxCustomBusinessMonikerCollection;
 mQuantity:extended;
 mSQLStreet,mSQLPostCode, mSQLCity, mStoreCode:string;
 mContactFirstName, mContactLastName, mContactEmail: string;
 mPerson_ID, mFPerson_ID, mPayCode, mTransCode, mPayment_ID, mTrans_ID,mStoreName: string;
begin
 mSite:=TComponent(Sender).DynSite;
 mOS:=mSite.BaseObjectSpace;
 mOpenDlg:=TOpenDialog.Create(sender);
 mOpenDlg.Title := 'Import z XML';
 mOpenDlg.Filter := 'Soubory XML (*.xml)| *.xml';
 mOpenDlg.Options := [ofAllowMultiSelect];
 if mOpenDlg.Execute then begin
  try
    mCount:=mOpenDlg.Files.Count;
    WaitWin.StartProgress('Čekejte, prosím ...', '', mCount);
      for i:=0 to mOpenDlg.Files.Count-1 do begin
       mXMLHead:=TNxScriptingXMLWrapper.Create;
       mXMLHead.loadFromFile(mOpenDlg.Files[i]);
       for j:=0 to mXMLHead.getElementsCountInArray('SalesOrders.SalesOrder')-1 do begin
        mOrder_ID:=mOS.SQLSelectFirstAsString('Select id from receivedorders where externalNumber='+QuotedStr(mXMLHead.getAttributeValue('SalesOrders.SalesOrder['+IntToStr(j)+']','salesordernumber')),'');
        if NxIsEmptyOID(mOrder_ID) then begin
         mBO:=mOS.CreateObject(Class_ReceivedOrder);
         mBO.New;
         mBO.Prefill;
         mBO.SetFieldValueAsString('DocQueue_ID','~000000001');
         if ElementExists(mXMLHead,'SalesOrders.SalesOrder['+IntToStr(j)+'].Description') then begin
          mbo.SetFieldValueAsString('Description',AnsiLeftStr(mXMLHead.getElementAsString('SalesOrders.SalesOrder['+IntToStr(j)+'].Description'),50));
          mbo.SetFieldValueAsString('X_Description_Exact',AnsiLeftStr(mXMLHead.getElementAsString('SalesOrders.SalesOrder['+IntToStr(j)+'].Description'),100));
         end;
         mbo.SetFieldValueAsDateTime('DocDate$Date',mCompileDate(mXMLHead.getElementAsString('SalesOrders.SalesOrder['+IntToStr(j)+'].OrderDate')));
         mBO.SetFieldValueAsString('Period_ID',GetPeriodID(mOS,mBO.GetFieldValueAsDateTime('DocDate$Date')));
         mBO.SetFieldValueAsString('ExternalNumber',mXMLHead.getAttributeValue('SalesOrders.SalesOrder['+IntToStr(j)+']','salesordernumber'));
         mBO.SetFieldValueAsString('X_YourRef_Exact',mXMLHead.getElementAsString('SalesOrders.SalesOrder['+IntToStr(j)+'].YourRef'));
         mbo.SetFieldValueAsString('Firm_ID', GetOrCreateFirm(mOS,
                                                              mXMLHead.getAttributeValue('SalesOrders.SalesOrder['+IntToStr(j)+'].OrderedBy','ID'),
                                                              mXMLHead.getAttributeValue('SalesOrders.SalesOrder['+IntToStr(j)+'].OrderedBy','code'),
                                                              mXMLHead.getElementAsString('SalesOrders.SalesOrder['+IntToStr(j)+'].OrderedBy.Name')));
         mStreet:='';
         mPostCode:='';
         mCity:='';
         if ElementExists(mXMLHead,'SalesOrders.SalesOrder['+IntToStr(j)+'].DeliveryAddress.AddressLine1')
           then mstreet:=mXMLHead.getElementAsString('SalesOrders.SalesOrder['+IntToStr(j)+'].DeliveryAddress.AddressLine1');
         if ElementExists(mXMLHead,'SalesOrders.SalesOrder['+IntToStr(j)+'].DeliveryAddress.PostalCode')
           then mPostCode:=AnsiLeftStr(mXMLHead.getElementAsString('SalesOrders.SalesOrder['+IntToStr(j)+'].DeliveryAddress.PostalCode'),10);
         if ElementExists(mXMLHead,'SalesOrders.SalesOrder['+IntToStr(j)+'].DeliveryAddress.City')
           then mCity:=mXMLHead.getElementAsString('SalesOrders.SalesOrder['+IntToStr(j)+'].DeliveryAddress.City');
         if not(NxIsBlank(mCity+mPostCode+mStreet)) then begin
           mSQLStreet:='';
           mSQLCity:='';
           mSQLPostCode:='';
           if not(NxIsBlank(mStreet)) then mSQLStreet:=' and a.street like N'+QuotedStr(mStreet);
           if not(NxIsBlank(mCity)) then mSQLCity:=' and a.city like N'+QuotedStr(mCity);
           if not(NxIsBlank(mPostCode)) then mSQLPostCode:=' and a.postcode like N'+QuotedStr(mPostCode);
           mFirmOffice_ID:=mOS.SQLSelectFirstAsString('Select fo.id from firmoffices fo left join addresses a on fo.address_id=a.id where fo.parent_id='+QuotedStr(mbo.GetFieldValueAsString('Firm_ID'))
                                              +mSQLStreet+mSQLCity+mSQLPostCode,'');

           if NxIsEmptyOID(mFirmOffice_ID) then begin
             mFirmOffice_ID:=GetOrCreateFirmOffice(mOS, mbo.GetFieldValueAsString('Firm_ID'), mStreet,mPostCode, mCity);
             //NxShowSimpleMessage('Select fo.id from firmoffices fo left join addresses a on fo.address_id=a.id where fo.parent_id='+QuotedStr(mbo.GetFieldValueAsString('Firm_ID'))+
             //                                 mSQLStreet+mSQLCity+mSQLPostCode,msite);
             mFirmOffice_ID:=mOS.SQLSelectFirstAsString('Select fo.id from firmoffices fo left join addresses a on fo.address_id=a.id where fo.parent_id='+QuotedStr(mbo.GetFieldValueAsString('Firm_ID'))+
                                              mSQLStreet+mSQLCity+mSQLPostCode,'');
           end;
           mBO.SetFieldValueAsString('FirmOffice_ID', mFirmOffice_id);
         end;
         mVATName:='';
         if ElementExists(mXMLHead,'SalesOrders.SalesOrder['+IntToStr(j)+'].SalesOrderLine[0].UnitPrice.VAT.Description') then
          mVATName:=mXMLHead.getElementAsString('SalesOrders.SalesOrder['+IntToStr(j)+'].SalesOrderLine['+IntToStr(0)+'].UnitPrice.VAT.Description');
         if mVATName='B2B - DE - Umsatzsteuer 0%' then begin
           mBO.SetFieldValueAsInteger('TradeType',2);
           mBO.SetFieldValueAsString('Country_ID','00000DE000');
         end;
         if mVATName='B2B DE Umsatzsteuer 20%' then begin
           mBO.SetFieldValueAsInteger('TradeType',4);
           mBO.SetFieldValueAsString('Country_ID','00000DE000');
         end;
         if mVATName='B2C DE Umsatzsteuer 19%' then begin
           mBO.SetFieldValueAsInteger('TradeType',7);
           mBO.SetFieldValueAsString('Country_ID','00000DE000');
         end;
         mStoreCode:=mXMLHead.getAttributeValue('SalesOrders.SalesOrder['+IntToStr(j)+'].Warehouse','code');
         mStore_ID:=mOS.SQLSelectFirstAsString('Select id from stores where code='+QuotedStr(mStoreCode),'');
         mPayCode:=mXMLHead.getAttributeValue('SalesOrders.SalesOrder['+IntToStr(j)+'].PaymentCondition','code');
         mPayment_ID:=mOS.SQLSelectFirstAsString('Select id from paymenttypes where code='+QuotedStr(mPayCode),'');
         mTransCode:=mXMLHead.getAttributeValue('SalesOrders.SalesOrder['+IntToStr(j)+'].ShippingMethod','code');
         mTrans_ID:=mOS.SQLSelectFirstAsString('Select id from transportationtypes where code='+QuotedStr(mTransCode),'');
         if not(NxIsEmptyOID(mPayment_ID)) then mBO.SetFieldValueAsString('PaymentType_ID',mPayment_ID);
         if not(NxIsEmptyOID(mTrans_ID)) then mBO.SetFieldValueAsString('TransportationType_ID',mTrans_ID);
         mStoreName:=AnsiLeftStr(mXMLHead.getElementAsString('SalesOrders.SalesOrder['+IntToStr(j)+'].Warehouse.Description'),30);
         if NxIsEmptyOID(mStore_ID) then mStore_ID:=mOS.SQLSelectFirstAsString('Select id from stores where name like '+QuotedStr(mStoreName+'%'),'');
         mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows'));
         mContactFirstName := AnsiLeftStr(mXMLHead.getElementAsString('SalesOrders.SalesOrder['+IntToStr(j)+'].InvoiceAccountContact.FirstName'),20);
         mContactLastName  := AnsiLeftStr(mXMLHead.getElementAsString('SalesOrders.SalesOrder['+IntToStr(j)+'].InvoiceAccountContact.LastName'),30);
         mContactEmail     := mXMLHead.getElementAsString('SalesOrders.SalesOrder['+IntToStr(j)+'].InvoiceAccountContact.Email');
         mPerson_ID:='';
         if not(NxIsBlank(mContactLastName+mContactFirstName+mContactEmail)) then
          mPerson_ID := GetOrCreatePerson(mOS, mContactFirstName, mContactLastName, mContactEmail);
         if not(NxIsEmptyOID(mPerson_ID)) then begin
           mFPerson_ID:=mOS.SQLSelectFirstAsString('Select id from firmpersons where parent_id='+QuotedStr(mbo.GetFieldValueAsString('Firm_ID'))+' and person_id='+QuotedStr(mPerson_ID),'');
           if NxIsEmptyOID(mFPerson_ID) then begin
              mFirmBO:=mOS.CreateObject(class_firm);
              mFirmBO.load(mbo.GetFieldValueAsString('Firm_ID'),nil);
              mFPersons:=mFirmBO.GetLoadedCollectionMonikerForFieldCode(mFirmBO.GetFieldCode('FirmPersons'));
              mFPersonBO:=mFPersons.AddNewObject;
              mFPersonBO.SetFieldValueAsString('Person_ID',mPerson_ID);
              mFPersonBO.SetFieldValueAsString('Address_ID.Email',mContactEmail);
              mFirmBO.save;
              mfirmbo.free;
           end;
           mbo.SetFieldValueAsString('Person_ID',mPerson_ID);
         end;
          for k:=0 to mXMLHead.getElementsCountInArray('SalesOrders.SalesOrder['+IntToStr(j)+'].SalesOrderLine')-1 do begin
            mCodeEan:=mXMLHead.getAttributeValue('SalesOrders.SalesOrder['+IntToStr(j)+'].SalesOrderLine['+IntToStr(k)+'].Item','code');
            mSCName:= mXMLHead.getElementAsString('SalesOrders.SalesOrder['+IntToStr(j)+'].SalesOrderLine['+IntToStr(k)+'].Item.Description');
            mStoreCard_ID:=GetorCreateStoreCard(mOS, mCodeEan,mSCName);
            mRowBO:=mRows.AddNewObject;
            mRowBO.Prefill;
            mRowBO.SetFieldValueAsInteger('RowType',3);
            mRowBO.SetFieldValueAsString('Store_ID',mStore_ID);
            mRowBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
            mQuantity:=NxIBStrToFloat(mXMLHead.getElementAsString('SalesOrders.SalesOrder['+IntToStr(j)+'].SalesOrderLine['+IntToStr(k)+'].Quantity'));
            if mQuantity>0 then
             mRowBo.SetFieldValueAsFloat('Quantity',mQuantity);
            if mQuantity<0 then begin
              mRowBo.SetFieldValueAsFloat('Quantity',-mQuantity);
              mRowBo.SetFieldValueAsFloat('X_OrigQuantity',mQuantity);
            end;
            mRowBo.SetFieldValueAsFloat('UnitPrice',NxIBStrToFloat(mXMLHead.getElementAsString('SalesOrders.SalesOrder['+IntToStr(j)+'].SalesOrderLine['+IntToStr(k)+'].UnitPrice.Value')));
            mRowBO.SetFieldValueAsString('Division_ID','1000000101');
          end;
         mbo.save;
         mBO.free;
        end;
       end;
       mXMLHead.free;
       WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(mCount));
       WaitWin.StepIt;
      end;
      WaitWin.Stop;
     except
      WaitWin.Stop;
      NxShowSimpleMessage(ExceptionMessage,mSite);
  end;
 end;
end;


Function GetOrCreatePerson(var aOS:TNxCustomObjectSpace; var FirstName, LastName, Email: string): string;
var
    mPerson_ID: string;
    mBO: TNxCustomBusinessObject;
begin
    mPerson_ID := aOS.SQLSelectFirstAsString(
        'select p.id from persons p join addresses a on p.address_id=a.id where p.hidden=''N'' and p.firstname=' + QuotedStr(FirstName) +
        ' and p.lastname=' + QuotedStr(LastName) + ' and a.email=' + QuotedStr(Email), '');
    if NxIsEmptyOID(mPerson_ID) then
    begin
        mBO := aOS.CreateObject(Class_Person);
        mBO.New;
        mBO.Prefill;
        mBO.SetFieldValueAsString('FirstName', FirstName);
        mBO.SetFieldValueAsString('LastName', LastName);
        mBO.SetFieldValueAsString('Address_ID.Email', Email);
        mBO.Save;
        mPerson_ID := mBO.OID;
        mBO.Free;
    end;
    Result := mPerson_ID;
end;

Function GetOrCreateStoreCard(var aOS:TNxCustomObjectSpace; var aCode, aName:string;):string;
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
  else mStoreCard_ID:=aOS.SQLSelectFirstAsString('Select id from storecards where code='+QuotedStr(aCode)+' and name like N'+QuotedStr(aName)+' and hidden='+QuotedStr('N'),'');
 if NxIsEmptyOID(mStoreCard_ID) then begin
   mBO:=aOS.CreateObject(Class_StoreCard);
   mbo.new;
   mbo.prefill;
   mBO.SetFieldValueAsString('Code',aCode);
   mBO.SetFieldValueAsString('Name',aName);
   mBO.SetFieldValueAsString('Specification','IMPORT_XML');
   mBO.SetFieldValueAsString('StoreCardCategory_ID','6000000101');
   mBO.SetFieldValueAsString('VATRate_ID', '02000XAT00');
   mUnits:=mBO.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('StoreUnits'));
   mVATRates:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('VATRates'));
   mUnits.BusinessObject[0].SetFieldValueAsString('Code','stk');
   if NxIsNumeric(aCode) and (Length(aCode)=13) then begin
    mBO.SetFieldValueAsInteger('Category',2);
    mUnits.BusinessObject[0].SetFieldValueAsString('EAN',aCode);
   end;
   mBO.SetFieldValueAsString('MainUnitcode','stk');
   mVATrateBO:=mVATRates.AddNewObject;
   mVATrateBO.prefill;
   mvatratebo.SetFieldValueAsString('Country_ID','00000DE000');
   mVATrateBO.SetFieldValueAsString('VatRate_ID','01900XDE00');
   mbo.save;
   mStoreCard_ID:=mBO.OID;
   mbo.free;
 end;
 Result:=mStoreCard_ID;
end;

Function GetOrCreateFirm(var aOS:TNxCustomObjectSpace; var EID, eCode, eName:string;):string;
var
 mBO:TNxCustomBusinessObject;
 mFirm_ID:string;
begin
 mFirm_ID:=aOS.SQLSelectFirstAsString('Select id from firms where hidden=''N'' and Firm_ID is null and X_ID_Exact='+QuotedStr(EID),'');
 if NxIsEmptyOID(mFirm_ID) then begin
   mBO:=aOS.CreateObject(Class_Firm);
   mBO.New;
   mBO.Prefill;
   mbo.SetFieldValueAsString('Code', eCode);
   mBO.SetFieldValueAsString('Name', eName);
   mBO.SetFieldValueAsString('X_ID_Exact', EID);
   mbo.save;
   mFirm_ID:=mbo.OID;
   mbo.free;
 end;
 Result:=mFirm_ID;
end;

Function GetOrCreateFirmOffice(var aOS:TNxCustomObjectSpace;var mFirm_ID, eStreet, ePostCode, eCity:string):string;
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
   mbo.save;
   mFirmOffice_ID:=mFirmOfficeBO.OID;
   mbo.free;
 Result:=mFirmOffice_ID;
end;

begin
end.