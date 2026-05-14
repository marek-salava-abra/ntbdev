uses 'eu.promos.inp.ParseData', 'eu.promos.inp.Progress';

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
 mSite:=TComponent(sender).DynSite;
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
           ProgressInit(mSite, 'Import množství...', j);
           for i := 0 to j - 1 do begin
            if NxIBStrToFloat(mXMLHead.getElementAsString('SeznamZasoba.Zasoba['+IntToStr(i)+'].StavZasoby.Zasoba'))>0 then begin
            mStoreCard_ID:=GetStoreCard_ID(mOS,mXMLHead.getElementAsString('SeznamZasoba.Zasoba['+IntToStr(i)+'].KmKarta.GUID'));
            if not(NxIsEmptyOID(mStoreCard_ID)) then begin
            mBO:=mOS.CreateObject(Class_InventoryOverplus);
            mbo.New;
            mBO.Prefill;
            mBO.SetFieldValueAsString('Firm_ID','1000000101');
            mbo.SetFieldValueAsString('Period_ID','1000000101');
            mbo.SetFieldValueAsDateTime('DocDate$Date',43465);
            mUnits:=mBO.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('rows'));
            mUnit:=mUnits.AddNewObject;
            mUnit.prefill;
            munit.SetFieldValueAsString('Store_ID','1000000101');
            munit.SetFieldValueAsString('Division_ID','1000000101');
            mUnit.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
            mUnit.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('SeznamZasoba.Zasoba['+IntToStr(i)+'].StavZasoby.Zasoba')));
            mUnit.SetFieldValueAsFloat('UnitPrice',NxIBStrToFloat(mXMLHead.getElementAsString('SeznamZasoba.Zasoba['+IntToStr(i)+'].Posl_N_Cen')));
            mbo.save;

            mbo.Free;


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