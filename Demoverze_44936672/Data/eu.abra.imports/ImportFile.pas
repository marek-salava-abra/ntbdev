uses 'eu.abra.imports.progress', 'eu.abra.imports.fce';

Procedure ImportFile(aFileName:String;AOS:TNxCustomObjectSpace; mSite:TSiteForm);
var
 mXMLHead:TNxScriptingXMLWrapper;
 i,j,k:integer;
 mStoreCard, mUnit:TNxCustomBusinessObject;
 mUnits:TNxCustomBusinessMonikerCollection;
 mStoreCard_ID:String;
begin
  mXMLHead := TNxScriptingXMLWrapper.Create;
  mXMLHead.loadFromFile(aFilename);
  if mXMLHead.getElementsCountInArray('StoreCard')=0 then begin
    NxShowSimpleMessage('Chybný soubor',mSite);
    exit;
  end;
  ProgressInit(mSite, 'Import karet...', mXMLHead.getElementsCountInArray('StoreCard'));
  for i:=0 to mXMLHead.getElementsCountInArray('StoreCard')-1 do begin
   mSTorecard_ID:=GetStoreCard_ID(AOS,mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].code'));
   if NxIsEmptyOID(mStoreCard_ID) then begin
     mStoreCard:=aos.CreateObject(Class_StoreCard);
     mStoreCard.New;
     mStoreCard.Prefill;
     mStoreCard.SetFieldValueAsInteger('Category',mXMLHead.getElementAsInteger('StoreCard['+inttostr(i)+'].Category'));
     mStoreCard.SetFieldValueAsString('Code',mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].code'));
     mStoreCard.SetFieldValueAsString('Name',mXMLHead.getElementAsString('StoreCard['+inttostr(i)+'].Name'));
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
     mstorecard.free;
     end;
     ProgressSetPos(i+1);
  end;
    ProgressDispose();

end;

begin
end.