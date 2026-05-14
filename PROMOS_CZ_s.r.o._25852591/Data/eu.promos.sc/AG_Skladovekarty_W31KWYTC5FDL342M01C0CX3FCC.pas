uses 'eu.promos.sc.ParseData', 'eu.promos.sc.Progress';

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Import dokladů z XML';
  mAction.Items.Add('Nový import');
  //mAction.Items.Add('Revize');
  mAction.Hint := 'Provede import z csv';
  mAction.Category := 'tabList';
  mAction.OnExecuteItem := @ImportData;

end;

procedure ImportData(sender:Tcomponent; index:integer);
var
 mSite:TsiteForm;
 mOS:TNxCustomObjectSpace;
 mBO, mFirm, mOtherIncomeBO, mPriceBO, mUnit:TNxCustomBusinessObject;
 mRows, mUnits:TNxCustomBusinessMonikerCollection;
 mRow:TNxCustomBusinessObject;
 mopenDLG:TOpenDialog;
 i, j, k:integer;
 mXMLHead: TNxScriptingXMLWrapper;
 mCountryCode, mCountry_ID, mFVDocQueue_ID, mFPDocQueue_ID, mFirm_ID, mDivision_ID, mOtherIncome_ID:String;
 mRI_ID,mII_ID,mCR_ID,mStoreCard_ID:String;
 mErrorList:TStringList;
 mStoreName:string;
begin
 mSite:=TComponent(sender).BusRollSite;
 mOS:=msite.BaseObjectSpace;
 if index=0 then begin
  mOpenDlg := TOpenDialog.Create(Sender);
  try
    if mOpenDlg.Execute then begin
      try
        mXMLHead := TNxScriptingXMLWrapper.Create;
        mXMLHead.loadFromFile(mopenDLG.FileName);
        mErrorList:=TStringList.Create;
        try
           j:=mXMLHead.getElementsCountInArray('SeznamZasoba.Zasoba');
           ProgressInit(mSite, 'Import skladových karet...', j);
           for i := 0 to j - 1 do begin
            mStoreCard_ID:=GetStoreCard_ID(mOS,mXMLHead.getElementAsString('SeznamZasoba.Zasoba['+IntToStr(i)+'].KmKarta.Katalog'));
            if nxisemptyoid(mstorecard_id) then begin
            mBO:=mOS.CreateObject(Class_StoreCard);
            mbo.New;
            mBO.Prefill;
            mBO.SetFieldValueAsString('Code',mXMLHead.getElementAsString('SeznamZasoba.Zasoba['+IntToStr(i)+'].KmKarta.Katalog'));
            mBO.SetFieldValueAsString('Name',mXMLHead.getElementAsString('SeznamZasoba.Zasoba['+IntToStr(i)+'].KmKarta.Popis'));
            mBO.SetFieldValueAsString('X_GUID',mXMLHead.getElementAsString('SeznamZasoba.Zasoba['+IntToStr(i)+'].KmKarta.GUID'));
            //if ElementExist(mXMLHead,('datasets.dataset0.rows.row['+IntToStr(i)+'].fields.kod')) then
            //mBO.SetFieldValueAsString('Specification',mXMLHead.getElementAsString('datasets.dataset0.rows.row['+IntToStr(i)+'].fields.kod'));

            //mBO.SetFieldValueAsString('StoreCardCategory_ID','2000000101');
            mBO.SetFieldValueAsString('StoreCardCategory_ID','1000000101');
            mBO.SetFieldValueAsString('VatRate_ID',GetVatRate_ID(mOS,mXMLHead.getElementAsString('SeznamZasoba.Zasoba['+IntToStr(i)+'].konfigurace.SDPH_prod')));
            mUnits:=mBO.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('StoreUnits'));
            mUnit:=mUnits.BusinessObject[0];
            mUnit.SetFieldValueAsString('Code',mXMLHead.getElementAsString('SeznamZasoba.Zasoba['+IntToStr(i)+'].KmKarta.MJ'));
            mbo.SetFieldValueAsString('MainUnitCode',mXMLHead.getElementAsString('SeznamZasoba.Zasoba['+IntToStr(i)+'].KmKarta.MJ'));
            mbo.save;
             mStoreCard_ID:=mBO.OID;
            mbo.Free;
           // end;


             if ElementExist(mXMLHead,('SeznamZasoba.Zasoba['+IntToStr(i)+'].PC[0].cena1.cena')) then begin
             mPriceBO:=mos.CreateObject(Class_StorePrice);
             mPriceBO.New;
             mPriceBO.SetFieldValueAsString('StoreCard_id',mStoreCard_ID);
             mPriceBO.SetFieldValueAsString('PriceList_ID','1000000101');
             mUnits:=mPriceBO.GetCollectionMonikerForFieldCode(mPriceBO.GetFieldCode('PriceRows'));

             mUnit:=mUnits.AddNewObject;
             mUnit.SetFieldValueAsString('Price_ID','1000000101');
             mUnit.SetFieldValueAsString('Qunit', mPriceBO.GetFieldValueAsString('StoreCard_id.MainUnitCode'));
             mUnit.SetFieldValueAsFloat('UnitRate',1);
             mUnit.SetFieldValueAsFloat('Amount',NxIBStrToFloat(mXMLHead.getElementAsString('SeznamZasoba.Zasoba['+IntToStr(i)+'].PC[0].cena1.cena')));
             mpricebo.save;
             mpricebo.free;
             end;


           end;
           ProgressSetPos(i+1);
           end;
        finally
          ProgressDispose();
        end;
      finally
      end;
    end;
   finally
   end;
  end;
end;
begin
end.