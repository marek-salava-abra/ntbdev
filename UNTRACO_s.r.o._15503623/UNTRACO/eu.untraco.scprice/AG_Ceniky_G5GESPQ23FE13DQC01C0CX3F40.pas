uses 'eu.untraco.scprice.ParseData', 'eu.untraco.scprice.Progress';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Import cen';
  mAction.Items.Add('Nový import');
  //mAction.Items.Add('Nový import s doplněním karty');
  //mAction.Items.Add('Import dle dodavatelského kódu');
  //mAction.Items.Add('Revize');
  mAction.Hint := 'Provede import z csv do aktuálního ceníkuv (struktura kód;popis;cena)';
  mAction.Category := 'tabList';
  mAction.OnExecuteItem := @ImportData;
end;

procedure ImportData(sender:Tcomponent; index:integer);
var
 mSite:TsiteForm;
 mOS:TNxCustomObjectSpace;
 mSMBO, mFirmBO, mbankBO, mSCBO:TNxCustomBusinessObject;
 mUnits:TNxCustomBusinessMonikerCollection;
 mUnit, mPriceList:TNxCustomBusinessObject;
 mList:TStringList;
 mopenDLG:TOpenDialog;
 mParams, mParRow : TNxParameters;
 i, j, k, m:integer;
 mStoreCard_ID, mStorePrice_ID, mPriceList_ID, mPLValidity_ID, mLatestPLValidity_ID:String;
 mNew:Boolean;
 mGRows : TMultiGrid;
 mStoreCardList, mImportedList, mNotImportedList, mSaveList:TStringList;
 {'code','name','date','price','quantity','odpis','stredisko','SN'}
begin
 mSite:=TComponent(sender).BusRollSite;
 mOS:=msite.BaseObjectSpace;
 mPriceList:=TBusRollSiteForm(msite).CurrentObject;
  if index=2 then begin
  mOpenDlg := TOpenDialog.Create(Sender);
  try
    if mOpenDlg.Execute then begin
      try
        mList := TStringList.Create;
        mList.LoadFromFile(mOpenDlg.FileName);
        mParams := ParseData(mlist);
        j:=TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Count;
        try
           ProgressInit(mSite, 'Import cen...', j);
           for i := 1 to j - 1 do begin
           mParRow := TNxParameters(TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Params(i));
            mStoreCard_id:=GetSToreCard2_ID(mOS,NxSearchReplace(mParRow.ParamByName('Code').AsString,'"','',[srAll]));
            if not(NxIsEmptyOID(mStoreCard_ID)) then begin
            //mImportedList.Add(mStoreCard_ID);
            mPLValidity_ID:=GetPLValidity_ID(mOS, mStoreCard_ID,mpricelist.OID);
            mStorePrice_ID:=GetPrice_ID(mOS, mStoreCard_ID,mpricelist.OID, mPLValidity_ID);
            if NxIsEmptyOID(mStorePrice_ID) then begin
             mSMBO:=mos.CreateObject(Class_StorePrice);
             mSMBO.New;
             mSMBO.SetFieldValueAsString('StoreCard_id',mStoreCard_ID);
             msmbo.SetFieldValueAsString('PriceList_ID',mPriceList.OID);
             mSMBO.SetFieldValueAsString('PriceListValidity_ID',mPLValidity_ID);
             mUnits:=mSMBO.GetCollectionMonikerForFieldCode(mSMBO.GetFieldCode('PriceRows'));
             mUnit:=mUnits.AddNewObject;
             mUnit.SetFieldValueAsString('Price_ID','1000000101');
             mUnit.SetFieldValueAsString('Qunit', mSMBO.GetFieldValueAsString('StoreCard_id.MainUnitCode'));
             mUnit.SetFieldValueAsFloat('UnitRate',1);
             mUnit.SetFieldValueAsFloat('Amount',NxIBStrToFloat(NxSearchReplace(mParRow.ParamByName('price').AsString,'"','',[srAll])));
             msmbo.save;
             mSMBO.Free;


            end;
            if not(NxIsEmptyOID(mStorePrice_ID)) then begin
             mSMBO:=mos.CreateObject(Class_StorePrice);
             mSMBO.Load(mStorePrice_ID,nil);
             mUnits:=mSMBO.GetLoadedCollectionMonikerForFieldCode(mSMBO.GetFieldCode('PriceRows'));
            for m:=0 to mUnits.count-1 do begin
            mUnit:=mUnits.BusinessObject[m];
             //NxShowSimpleMessage(mUnit.GetFieldValueAsString('Price_ID'),mSite);
             if mUnit.GetFieldValueAsString('Price_ID')='1000000101' then begin
               //NxShowSimpleMessage(NxSearchReplace(mParRow.ParamByName('price').AsString,'"','',[srAll]),mSite);
               if mUnit.GetFieldValueAsString('Qunit')=mSMBO.GetFieldValueAsString('StoreCard_id.MainUnitCode') then begin
                mUnit.SetFieldValueAsFloat('Amount',NxIBStrToFloat(NxSearchReplace(mParRow.ParamByName('price').AsString,'"','',[srAll])));
                OutputDebugString(FloatToStr(mUnit.GetFieldValueAsFloat('Amount')));
                mUnit.save;
               end;
             end;
            end;
             msmbo.save;
             mSMBO.Free;
            end;
            end;
          ProgressSetPos(i+1);
          end;
          ProgressDispose();
        finally


        end;

      finally
      end;
    end;
  finally
  end;
  end;
  if index=0 then begin
  mOpenDlg := TOpenDialog.Create(Sender);
  try
    if mOpenDlg.Execute then begin
      try
        mList := TStringList.Create;
        mList.LoadFromFile(mOpenDlg.FileName);
        mParams := ParseData(mlist);
        j:=TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Count;
        try
           ProgressInit(mSite, 'Import cen...', j);
           for i := 1 to j - 1 do begin
           mParRow := TNxParameters(TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Params(i));
            mStoreCard_id:=GetSToreCard_ID(mOS,NxSearchReplace(mParRow.ParamByName('Code').AsString,'"','',[srAll]));
            OutputDebugString('Parametr: ' + mParRow.ParamByName('price').AsString);
            if not(NxIsEmptyOID(mStoreCard_ID)) then begin
            mPLValidity_ID:=GetPLValidity_ID(mOS, mStoreCard_ID,mpricelist.OID);
            mStorePrice_ID:=GetPrice_ID(mOS, mStoreCard_ID,mpricelist.OID, mPLValidity_ID);
            mLatestPLValidity_ID:= GetLatestPLValidity_ID(mOS, mPriceList.OID);
            OutputDebugString('val_ID: ' + mPLValidity_ID + ' | mStorePrice: '+ mStorePrice_ID+ ' | mLatestVal_ID: '+ mLatestPLValidity_ID);
            mStorePrice_ID:=GetPrice_ID(mOS, mStoreCard_ID,mpricelist.OID, mLatestPLValidity_ID);
            //NxShowSimpleMessage(mLatestPLValidity_ID+' '+mPLValidity_ID,mSite);
            if NxIsEmptyOID(mStorePrice_ID) and (not (mPLValidity_ID = mLatestPLValidity_ID)) then begin
              OutputDebugString('zakladani SP');
              mSMBO:=mos.CreateObject(Class_StorePrice);
              mSMBO.New;
              mSMBO.SetFieldValueAsString('StoreCard_id',mStoreCard_ID);
              msmbo.SetFieldValueAsString('PriceList_ID',mPriceList.OID);
              mSMBO.SetFieldValueAsString('PriceListValidity_ID',mLatestPLValidity_ID);
              mUnits:=mSMBO.GetCollectionMonikerForFieldCode(mSMBO.GetFieldCode('PriceRows'));
              mUnit:=mUnits.AddNewObject;
              mUnit.SetFieldValueAsString('Price_ID','1000000101');
              mUnit.SetFieldValueAsString('Qunit', mSMBO.GetFieldValueAsString('StoreCard_id.MainUnitCode'));
              mUnit.SetFieldValueAsFloat('UnitRate',1);
              mUnit.SetFieldValueAsFloat('Amount',NxIBStrToFloat(NxSearchReplace(mParRow.ParamByName('price').AsString,'"','',[srAll])));
              msmbo.save;
              mSMBO.Free;
            end else begin
             //if not(NxIsEmptyOID(mStorePrice_ID)) then begin
              OutputDebugString('update SP');
              mSMBO:=mos.CreateObject(Class_StorePrice);
              mSMBO.Load(mStorePrice_ID,nil);
              mUnits:=mSMBO.GetLoadedCollectionMonikerForFieldCode(mSMBO.GetFieldCode('PriceRows'));
              for m:=0 to mUnits.count-1 do begin
              mUnit:=mUnits.BusinessObject[m];
              //NxShowSimpleMessage(mUnit.GetFieldValueAsString('Price_ID'),mSite);
              if mUnit.GetFieldValueAsString('Price_ID')='1000000101' then begin
                //NxShowSimpleMessage(NxSearchReplace(mParRow.ParamByName('price').AsString,'"','',[srAll]),mSite);
                if mUnit.GetFieldValueAsString('Qunit')=mSMBO.GetFieldValueAsString('StoreCard_id.MainUnitCode') then begin
                mUnit.SetFieldValueAsFloat('Amount',NxIBStrToFloat(NxSearchReplace(mParRow.ParamByName('price').AsString,'"','',[srAll])));
                mUnit.save;
                end;
              end;
            end;
              msmbo.save;
              mSMBO.Free;
            end;
            end;
          ProgressSetPos(i+1);
          end;
          ProgressDispose();
        finally

        end;

      finally
      end;
    end;
  finally
  end;
  end;
  if index=1 then begin
  mOpenDlg := TOpenDialog.Create(Sender);
  try
    if mOpenDlg.Execute then begin
      try
        mList := TStringList.Create;
        mList.LoadFromFile(mOpenDlg.FileName);
        mParams := ParseData(mlist);
        j:=TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Count;
        try
           ProgressInit(mSite, 'Import cen...', j);
           for i := 1 to j - 1 do begin
           mParRow := TNxParameters(TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Params(i));
            mStoreCard_id:=GetSToreCard_ID(mOS,NxSearchReplace(mParRow.ParamByName('Code').AsString,'"','',[srAll]));
            if not(NxIsEmptyOID(mStoreCard_ID)) then begin
            mPLValidity_ID:=GetPLValidity_ID(mOS, mStoreCard_ID,mpricelist.OID);
            mStorePrice_ID:=GetPrice_ID(mOS, mStoreCard_ID,mpricelist.OID, mPLValidity_ID);
            if NxIsEmptyOID(mStorePrice_ID) then begin
             mSMBO:=mos.CreateObject(Class_StorePrice);
             mSMBO.New;
             mSMBO.SetFieldValueAsString('StoreCard_id',mStoreCard_ID);
             msmbo.SetFieldValueAsString('PriceList_ID',mPriceList.OID);
             mSMBO.SetFieldValueAsString('PriceListValidity_ID',mPLValidity_ID);
             mUnits:=mSMBO.GetCollectionMonikerForFieldCode(mSMBO.GetFieldCode('PriceRows'));
             mUnit:=mUnits.AddNewObject;
             mUnit.SetFieldValueAsString('Price_ID','1000000101');
             mUnit.SetFieldValueAsString('Qunit', mSMBO.GetFieldValueAsString('StoreCard_id.MainUnitCode'));
             mUnit.SetFieldValueAsFloat('UnitRate',1);
             mUnit.SetFieldValueAsFloat('Amount',NxIBStrToFloat(NxSearchReplace(mParRow.ParamByName('price').AsString,'"','',[srAll])));
             msmbo.save;
             mSMBO.Free;


            end;
            if not(NxIsEmptyOID(mStorePrice_ID)) then begin
             mSMBO:=mos.CreateObject(Class_StorePrice);
             mSMBO.Load(mStorePrice_ID,nil);
             mUnits:=mSMBO.GetLoadedCollectionMonikerForFieldCode(mSMBO.GetFieldCode('PriceRows'));
            for m:=0 to mUnits.count-1 do begin
            mUnit:=mUnits.BusinessObject[m];
             //NxShowSimpleMessage(mUnit.GetFieldValueAsString('Price_ID'),mSite);
             if mUnit.GetFieldValueAsString('Price_ID')='1000000101' then begin
               //NxShowSimpleMessage(NxSearchReplace(mParRow.ParamByName('price').AsString,'"','',[srAll]),mSite);
               if mUnit.GetFieldValueAsString('Qunit')=mSMBO.GetFieldValueAsString('StoreCard_id.MainUnitCode') then begin
                mUnit.SetFieldValueAsFloat('Amount',NxIBStrToFloat(NxSearchReplace(mParRow.ParamByName('price').AsString,'"','',[srAll])));
                mUnit.save;
               end;
             end;
            end;
             msmbo.save;
             mSMBO.Free;
            end;
            end;
          ProgressSetPos(i+1);
          end;
          ProgressDispose();
        finally


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