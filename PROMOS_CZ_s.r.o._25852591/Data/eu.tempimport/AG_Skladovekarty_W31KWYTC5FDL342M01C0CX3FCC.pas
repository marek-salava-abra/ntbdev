procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImportWP';
  mAction.Caption := 'WPWP';
  mAction.Hint := 'Naimportuje EAN z XLS (pozor jen z prvního listu)';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImportData;
end;

Procedure ImportData(sender:TComponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mList:TStringList;
 mBO, mPriceBO, mPriceRowBO, mUnitBO:TNxCustomBusinessObject;
 mUnits, mPriceRows:TNxCustomBusinessMonikerCollection;
 mOpenDlg:TOpenDialog;
 i,j,k:integer;
 mTempstr, mCode, mName, mEan, mPriceEUR, mWeigth, mStoreCard_ID, mPrice_ID, mPriceRow_ID:string;
begin
  mSite:=TComponent(sender).BusRollSite;
  mOS:=mSite.BaseObjectSpace;
  //GetData(msite, k,l,m);
  if True then begin
    mOpenDlg := TOpenDialog.Create(Sender);
    mOpenDlg.Title := 'Import z WP';
      mOpenDlg.Filter := 'Soubory aplikace CSV (*.csv)| *.csv';
      if mOpenDlg.Execute then begin
        try
          mList:=TStringList.create;
          mList.LoadFromFile(mOpenDlg.FileName);
          for i:=1 to mlist.count-1 do begin
            mTempStr:=mList.Strings[i];
            mCode:=NxTrapStrTrim(mTempstr,';');
            mName:=NxTrapStrTrim(mTempstr,';');
            mEan:=NxTrapStrTrim(mTempstr,';');
            mWeigth:=NxTrapStrTrim(mTempstr,';');
            mPriceEUR:=NxTrapStrTrim(mTempstr,';');
            mStoreCard_ID:=mOS.SQLSelectFirstAsString('Select id from storecards where code='+QuotedStr(mCode)+' and hidden=''N'' ','');
            if not(NxIsEmptyOID(mStoreCard_ID)) then begin
              mBO:=mOS.CreateObject(Class_StoreCard);
              mBO.Load(mStoreCard_ID,nil);
              mUnits:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('StoreUnits'));
              for j:=0 to mUnits.count-1 do begin
                mUnitBO:=mUnits.BusinessObject[j];
                if mUnitBO.GetFieldValueAsString('Code')=mbo.GetFieldValueAsString('MainUnitCode') then begin
                  if NxIsBlank(mUnitBO.GetFieldValueAsString('EAN')) then mUnitBO.SetFieldValueAsString('EAN',mEan);
                  mUnitBO.SetFieldValueAsFloat('Weight',NxIBStrToFloat(mWeigth));
                  mUnitBO.SetFieldValueAsInteger('WeightUnit',0);
                end;
              end;
              mbo.save;
              mPrice_ID:=mOS.SQLSelectFirstAsString( 'SELECT first 1 '#13#10 +
                                          '    sp2.Parent_ID'#13#10 +
                                          'FROM PriceListValidities plv'#13#10 +
                                          'JOIN StorePrices sp '#13#10 +
                                          '    ON sp.PriceListValidity_ID = plv.ID'#13#10 +
                                          'JOIN StorePrices2 sp2 '#13#10 +
                                          '    ON sp2.Parent_ID = sp.ID'#13#10 +
                                          'WHERE plv.Parent_ID = ''1000000101'''#13#10 +
                                          '  AND sp.StoreCard_ID = '+QuotedStr(mbo.oid)+' '#13#10 +
                                          '  AND sp2.Price_ID = ''1100000101'''#13#10 +
                                          '  AND plv.ValidFromDate$Date <= (CURRENT_DATE - DATE ''1899-12-30'') + 1 '#13#10 +
                                          'ORDER BY plv.ValidFromDate$Date DESC','');
              if not(NxIsEmptyOID(mPrice_ID)) then begin
                mPriceBO:=mOS.CreateObject(Class_StorePrice);
                mPriceBO.load(mPrice_ID,nil);
                mPriceRows:=mPriceBO.GetLoadedCollectionMonikerForFieldCode(mPriceBO.GetFieldCode('Rows'));
                mPriceRow_ID:=mOS.SQLSelectFirstAsString('Select id from storeprices2 where price_id=''1100000101'' and parent_id='+QuotedStr(mPrice_ID),'');
                if NxIsEmptyOID(mPriceRow_ID) then begin
                  mPriceRowBO:=mPriceRows.AddNewObject;
                  mPriceRowBO.Prefill;
                  mPriceRowBO.SetFieldValueAsFloat('Amount',NxIBStrToFloat(mPriceEUR));
                  mPriceRowBO.SetFieldValueAsString('Price_ID','1100000101');
                  mPriceRowBO.SetFieldValueAsString('QUnit',mBO.GetFieldValueAsString('MainUnitCode'));
                end else begin
                for j:=0 to mPriceRows.count-1 do begin
                  mPriceRowBO:=mPriceRows.BusinessObject[j];
                  if mPriceRowBO.GetFieldValueAsString('Price_ID')='1100000101' then mPriceRowBO.SetFieldValueAsFloat('Amount',NxIBStrToFloat(mPriceEUR));
                end;
                end;
                mPriceBO.save;
                mpricebo.free;
              end;
              mbo.free;
            end;
          end;
        except

        end;
      end;
  end;
end;

begin
end.