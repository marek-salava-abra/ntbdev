uses 'eu.abra.imports.progress', 'eu.abra.imports.fce';

Procedure ImportFile(aFileName:String;AOS:TNxCustomObjectSpace; mSite:TSiteForm);
var
 mXMLHead:TNxScriptingXMLWrapper;
 i,j,k,m:integer;
 mStoreCard, mUnit,mSMBO,mStorePrice, mEAN:TNxCustomBusinessObject;
 mUnits,mStorePrices, mEANS:TNxCustomBusinessMonikerCollection;
 mStoreCard_ID, mStorePrice_ID:String;
 mAdd:Boolean;
 mPrice:Extended;
begin
  mXMLHead := TNxScriptingXMLWrapper.Create;
  mXMLHead.loadFromFile(aFilename);
  if mXMLHead.getElementsCountInArray('StoreCard')=0 then begin
    NxShowSimpleMessage('Chybný soubor'+ inttostr(mXMLHead.getElementsCountInArray('StoreCard')),mSite);
    exit;
  end;
  ProgressInit(mSite, 'Import karet...', mXMLHead.getElementsCountInArray('StoreCard'));
  for i:=0 to mXMLHead.getElementsCountInArray('StoreCard')-1 do begin
   mSTorecard_ID:=GetStoreCard_ID(AOS,mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].code'));
   //mStoreCard_ID:='';
   {if not(NxIsEmptyOID(mStoreCard_ID)) then begin
            mStoreCard:=aos.CreateObject(Class_StoreCard);
            mStoreCard.load(mStoreCard_ID,nil);
            mStoreCard.SetFieldValueAsString('Producer_ID','3NA4000101');
            mStoreCard.SetFieldValueAsBoolean('U_MinPriceValidate',true);
            if mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].StoreAssortmentGroup_Code')='A' then mStoreCard.SetFieldValueAsFloat('U_ProcentoMax',30);
            if mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].StoreAssortmentGroup_Code')='B' then mStoreCard.SetFieldValueAsFloat('U_ProcentoMax',24);
            if mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].StoreAssortmentGroup_Code')='C' then mStoreCard.SetFieldValueAsFloat('U_ProcentoMax',18);
            //if NxIsBlank(mStoreCard.GetFieldValueAsString('EAN')) then begin
            for k:=0 to mXMLHead.getElementsCountInArray('StoreCard['+inttostr(i)+'].Units.Unit')-1 do begin
              if not(NxIsBlank(mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].Units.Unit['+inttostr(k)+'].EAN'))) then begin
                  mUnits:=mStoreCard.GetloadedCollectionMonikerForFieldCode(mStoreCard.GetFieldCode('StoreUnits'));
                   for m:=0 to mUnits.count-1 do begin
                     mUnit:=mUnits.BusinessObject[m];
                     if munit.GetFieldValueAsString('Code')=mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].Units.Unit['+inttostr(k)+'].Code') then
                        mUnit.SetFieldValueAsString('EAN',mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].Units.Unit['+inttostr(k)+'].EAN'));
                   end;
              end;
            end;
            if mStoreCard.NeedSave then mStoreCard.save;
            mstorecard.Free;
            mStorePrice_ID:=GetPrice_ID(aoS, mStoreCard_ID,'1000000101');
            if not(NxIsEmptyOID(mStorePrice_ID)) then begin
             mSMBO:=aos.CreateObject(Class_StorePrice);
             mSMBO.Load(mStorePrice_ID,nil);
             mUnits:=mSMBO.GetLoadedCollectionMonikerForFieldCode(mSMBO.GetFieldCode('PriceRows'));
             for m:=0 to mUnits.count-1 do begin
             mUnit:=mUnits.BusinessObject[m];
             if mUnit.GetFieldValueAsString('Price_ID')='1000000101' then begin
                if mUnit.GetFieldValueAsString('Qunit')=mSMBO.GetFieldValueAsString('StoreCard_id.MainUnitCode') then begin
                  mprice:=NxIBStrToFloat(mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].DPC'));
                  mPrice:=((100+mSMBO.GetFieldValueAsFloat('StoreCard_ID.VatRate'))*mPrice)/100;
                  mprice:=NxRoundByValue(mprice, ctUp,1);
                  mprice:= mPrice*(100/((100+mSMBO.GetFieldValueAsFloat('StoreCard_ID.VatRate'))));
                  mUnit.SetFieldValueAsFloat('Amount',mPrice);
                  mUnit.save;
                end;
              end;
             end;

             msmbo.save;
             mSMBO.Free;
        end;
   end; }
     if NxIsEmptyOID(mStoreCard_ID) then begin
     mStoreCard:=aos.CreateObject(Class_StoreCard);
     mStoreCard.New;
     mStoreCard.Prefill;
     mStoreCard.SetFieldValueAsInteger('Category',mXMLHead.getElementAsInteger('StoreCard['+inttostr(i)+'].Category'));
     mStoreCard.SetFieldValueAsString('Code',mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].code'));
     mStoreCard.SetFieldValueAsString('Name',mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].Name'));
     mStoreCard.SetFieldValueAsString('Producer_ID','3NA4000101');

     mSToreCard.SetFieldValueAsString('StoreCardCategory_ID',GetstoreCardCategory_ID(AOS,mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].Category_code')));
    // mSToreCard.SetFieldValueAsString('StoreMenuItem_ID',GetstoreMenuItem_ID(AOS,mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].StoreMenu')));
     mStoreCard.SetFieldValueAsString('VatRate_ID',mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].VatRate'));
     mStoreCard.SetFieldValueAsBoolean('U_MinPriceValidate',true);
     if mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].StoreAssortmentGroup_Code')='A' then mStoreCard.SetFieldValueAsFloat('U_ProcentoMax',30);
     if mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].StoreAssortmentGroup_Code')='B' then mStoreCard.SetFieldValueAsFloat('U_ProcentoMax',24);
     if mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].StoreAssortmentGroup_Code')='C' then mStoreCard.SetFieldValueAsFloat('U_ProcentoMax',18);
            if NxIsBlank(mStoreCard.GetFieldValueAsString('EAN')) then begin

     mUnits:=mStoreCard.GetloadedCollectionMonikerForFieldCode(mStoreCard.GetFieldCode('StoreUnits'));
     munits.BusinessObject[0].MarkForDelete;
     for k:=0 to mXMLHead.getElementsCountInArray('StoreCard['+inttostr(i)+'].Units.Unit')-1 do begin
         mUnit:=mUnits.AddNewObject;
         munit.SetFieldValueAsString('Code',mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].Units.Unit['+inttostr(k)+'].code'));
         munit.SetFieldValueAsString('EAN',mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].Units.Unit['+inttostr(k)+'].EAN'));
         munit.SetFieldValueAsFloat('UnitRate',mXMLHead.getElementAsfloat('StoreCard['+inttostr(i)+'].Units.Unit['+inttostr(k)+'].UnitRate'));
         munit.SetFieldValueAsFloat('Weight',mXMLHead.getElementAsfloat('StoreCard['+inttostr(i)+'].Units.Unit['+inttostr(k)+'].Weight'));
         munit.SetFieldValueAsFloat('WeightUnit',mXMLHead.getElementAsfloat('StoreCard['+inttostr(i)+'].Units.Unit['+inttostr(k)+'].WeightUnit'));
         munit.SetFieldValueAsFloat('Depth',mXMLHead.getElementAsfloat('StoreCard['+inttostr(i)+'].Units.Unit['+inttostr(k)+'].Depth'));
         munit.SetFieldValueAsFloat('Height',mXMLHead.getElementAsfloat('StoreCard['+inttostr(i)+'].Units.Unit['+inttostr(k)+'].height'));
         munit.SetFieldValueAsFloat('Width',mXMLHead.getElementAsfloat('StoreCard['+inttostr(i)+'].Units.Unit['+inttostr(k)+'].Width'));
         munit.SetFieldValueAsFloat('SizeUnit',mXMLHead.getElementAsfloat('StoreCard['+inttostr(i)+'].Units.Unit['+inttostr(k)+'].SizeUnit'));
     end;

     mStoreCard.SetFieldValueAsString('MainUnitCode',mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].MainUnitCode'));
     mStoreCard.save;
     mStoreCard_ID:=mStoreCard.OID;
     mstorecard.free;

             mSMBO:=AOS.CreateObject(Class_StorePrice);
             mSMBO.New;
             mSMBO.SetFieldValueAsString('StoreCard_id',mStoreCard_ID);
             msmbo.SetFieldValueAsString('PriceList_ID','1000000101');
             mStorePrices:=mSMBO.GetCollectionMonikerForFieldCode(mSMBO.GetFieldCode('PriceRows'));
             if NxIBStrToFloat(mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].DPC'))>0 then begin
               mStorePrice:=mStorePrices.AddNewObject;
               mStorePrice.SetFieldValueAsString('Price_ID','1000000101');
               mStorePrice.SetFieldValueAsString('Qunit', mSMBO.GetFieldValueAsString('StoreCard_id.MainUnitCode'));
               mStorePrice.SetFieldValueAsFloat('UnitRate',1);
               mprice:=NxIBStrToFloat(mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].DPC'));
                  mPrice:=((100+mSMBO.GetFieldValueAsFloat('StoreCard_ID.VatRate'))*mPrice)/100;
                  mprice:=NxRoundByValue(mprice, ctUp,1);
                  mprice:= mPrice*(100/((100+mSMBO.GetFieldValueAsFloat('StoreCard_ID.VatRate'))));

               mStorePrice.SetFieldValueAsFloat('Amount',mPrice);
             end;

             msmbo.save;
             mSMBO.Free;
     end;
     end;
     ProgressSetPos(i+1);
  end;
    ProgressDispose();

end;

Procedure ImportFile2(aFileName:String;AOS:TNxCustomObjectSpace; mSite:TSiteForm);
var
 mXMLHead:TNxScriptingXMLWrapper;
 i,j,k:integer;
 mStoreCard, mUnit,mSMBO,mStorePrice:TNxCustomBusinessObject;
 mUnits,mStorePrices:TNxCustomBusinessMonikerCollection;
 mStoreCard_ID:String;
 mPrice:Extended;
begin
  mXMLHead := TNxScriptingXMLWrapper.Create;
  mXMLHead.loadFromFile(aFilename);
  if mXMLHead.getElementsCountInArray('StoreCard')=0 then begin
    NxShowSimpleMessage('Chybný soubor',mSite);
    exit;
  end;
  ProgressInit(mSite, 'Import karet...', mXMLHead.getElementsCountInArray('StoreCard'));
  for i:=0 to mXMLHead.getElementsCountInArray('StoreCard')-1 do begin
   //mSTorecard_ID:=GetStoreCard_ID(AOS,mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].code'));
   mStoreCard_ID:='';
   if NxIsEmptyOID(mStoreCard_ID) then begin
     mStoreCard:=aos.CreateObject(Class_StoreCard);
     mStoreCard.New;
     mStoreCard.Prefill;
     mStoreCard.SetFieldValueAsInteger('Category',mXMLHead.getElementAsInteger('StoreCard['+inttostr(i)+'].Category'));
     mStoreCard.SetFieldValueAsString('Code',mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].code'));
     mStoreCard.SetFieldValueAsString('Name',mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].Name'));
     mStoreCard.SetFieldValueAsString('Specification','BAR');
     mStoreCard.SetFieldValueAsString('StoreMenuItem_ID','3FZ1000101');
     mSToreCard.SetFieldValueAsString('StoreCardCategory_ID',GetstoreCardCategory_ID(AOS,mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].Category_code')));
     mStoreCard.SetFieldValueAsString('VatRate_ID',mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].VatRate'));
     mUnits:=mStoreCard.GetloadedCollectionMonikerForFieldCode(mStoreCard.GetFieldCode('StoreUnits'));
     munits.BusinessObject[0].MarkForDelete;
     for k:=0 to mXMLHead.getElementsCountInArray('StoreCard['+inttostr(i)+'].Units.Unit')-1 do begin
         mUnit:=mUnits.AddNewObject;
         munit.SetFieldValueAsString('Code',mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].Units.Unit['+inttostr(k)+'].code'));
         munit.SetFieldValueAsString('EAN',mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].Units.Unit['+inttostr(k)+'].EAN'));
         munit.SetFieldValueAsFloat('UnitRate',mXMLHead.getElementAsfloat('StoreCard['+inttostr(i)+'].Units.Unit['+inttostr(k)+'].UnitRate'));
         munit.SetFieldValueAsFloat('Weight',mXMLHead.getElementAsfloat('StoreCard['+inttostr(i)+'].Units.Unit['+inttostr(k)+'].Weight'));
         munit.SetFieldValueAsFloat('WeightUnit',mXMLHead.getElementAsfloat('StoreCard['+inttostr(i)+'].Units.Unit['+inttostr(k)+'].WeightUnit'));
         munit.SetFieldValueAsFloat('Depth',mXMLHead.getElementAsfloat('StoreCard['+inttostr(i)+'].Units.Unit['+inttostr(k)+'].Depth'));
         munit.SetFieldValueAsFloat('Height',mXMLHead.getElementAsfloat('StoreCard['+inttostr(i)+'].Units.Unit['+inttostr(k)+'].height'));
         munit.SetFieldValueAsFloat('Width',mXMLHead.getElementAsfloat('StoreCard['+inttostr(i)+'].Units.Unit['+inttostr(k)+'].Width'));
         munit.SetFieldValueAsFloat('SizeUnit',mXMLHead.getElementAsfloat('StoreCard['+inttostr(i)+'].Units.Unit['+inttostr(k)+'].SizeUnit'));
     end;

     mStoreCard.SetFieldValueAsString('MainUnitCode',mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].MainUnitCode'));
     mStoreCard.save;
     mStoreCard_ID:=mStoreCard.OID;
     mstorecard.free;

             mSMBO:=AOS.CreateObject(Class_StorePrice);
             mSMBO.New;
             mSMBO.SetFieldValueAsString('StoreCard_id',mStoreCard_ID);
             msmbo.SetFieldValueAsString('PriceList_ID','1000000101');
             mStorePrices:=mSMBO.GetCollectionMonikerForFieldCode(mSMBO.GetFieldCode('PriceRows'));
             for k:=0 to mXMLHead.getElementsCountInArray('StoreCard['+inttostr(i)+'].Units.Unit')-1 do begin
               if NxIBStrToFloat(mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].DPC'))>0 then begin
                 mStorePrice:=mStorePrices.AddNewObject;
                 mStorePrice.SetFieldValueAsString('Price_ID','1000000101');
                 mStorePrice.SetFieldValueAsString('Qunit', mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].Units.Unit['+inttostr(k)+'].code'));
                 mStorePrice.SetFieldValueAsFloat('UnitRate',mXMLHead.getElementAsfloat('StoreCard['+inttostr(i)+'].Units.Unit['+inttostr(k)+'].UnitRate'));
                  mprice:=NxIBStrToFloat(mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].DPC'));
                   // mPrice:=((100+mSMBO.GetFieldValueAsFloat('StoreCard_ID.VatRate'))*mPrice)/100;
                   // mprice:=NxRoundByValue(mprice, ctUp,1);
                   // mprice:= mPrice*(100/((100+mSMBO.GetFieldValueAsFloat('StoreCard_ID.VatRate'))));

                 mStorePrice.SetFieldValueAsFloat('Amount',mPrice);
               end;
             end;
             msmbo.save;
             mSMBO.Free;
     end;
     ProgressSetPos(i+1);
  end;
    ProgressDispose();

end;

begin
end.