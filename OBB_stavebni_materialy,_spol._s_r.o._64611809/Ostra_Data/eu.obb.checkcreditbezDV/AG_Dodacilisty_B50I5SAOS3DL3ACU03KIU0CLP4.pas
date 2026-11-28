uses 'eu.obb.checkcreditbezDV.common';

procedure _CanSaveNow_Hook(Self: TDynSiteForm; var ACanSaveNow: Boolean);
var
  mContainer: TNxObjectContainer;
  mParams: TNxParameters;
  mBO: TNxCustomBusinessObject;
  mText: String;
  i: Integer;
  mCurrentDL: Extended;
begin
  OutputDebugString('_CanSaveNow_Hook');
  mCurrentDL := 0;
  mContainer := getContainer(Self);
  mBO := Self.CurrentObject;
  try
    try
      mParams := TNxParameters(mContainer.GetObject(mBO.CLSID + mBO.OID));
    except
      mParams := TNxParameters.Create;   //necháme, kdybychom opravovali stejný dokald, tak ať se nevytváří, ale pro jistotu nulujeme. Destrouy je s destroyem agendy
      mContainer.AddObject(mBO.CLSID + mBO.OID,mParams);
      fillCreditForFirm(mParams,mBO);
    end;
    if CFxFloat.IsZero2(mParams.ParamByName('dl2').AsFloat) then
    begin
      for i:=0 to TNxHeaderBusinessObject(mBO).Rows.Count -1 do
        if not(osMarkForDelete in TNxHeaderBusinessObject(mBO).Rows.BusinessObject[i].State) then
          mCurrentDL := mCurrentDL + TNxHeaderBusinessObject(mBO).Rows.BusinessObject[i].GetFieldValueAsFloat('LocalTAmount');
      mParams.ParamByName('dl2').AsFloat := mCurrentDL;
    end;
    if canProcessBO(
          mParams.ParamByName('fv').AsFloat,
          mParams.ParamByName('fp').AsFloat,
          mParams.ParamByName('dv').AsFloat,
          mParams.ParamByName('zl').AsFloat,
          mParams.ParamByName('dl').AsFloat,
          mParams.ParamByName('dl2').AsFloat,
          mParams.ParamByName('credit').AsFloat,
          0) then
    begin
      mText := 'Doklad nelze uložit z důvodu přečerpání kreditu:' + #13#10;
      for i:=0 to mParams.Count -1 do
      begin
        if NxIsEmptyOID(mParams.Params[i].Name) then
          mText := mText + mParams.Params[i].Name + ': ' + mParams.Params[i].AsString + #13#10;
      end;
      ACanSaveNow := False;
      NxShowMessage('Kredit', mText, mdStop, True, Self.GetSiteAppForm);
    end;
  finally
    mBO.Free;
  end;
end;

procedure beforeDeleteds(ADataSet: TNxDataDataSet);
var
  mBO, mUser: TNxCustomBusinessObject;
  mFirm_ID: TNxOID;
  mContainer: TNxObjectContainer;
  mDL, mFP, mFV, mZL,mDV, mCredit, mDL2, mDLRow, mAvStorePrice:Extended;
  mResult, mList: TStringList;
  mHead, mRow: TNxCustomBusinessObject;
  mRows: TNxCustomBusinessMonikerCollection;
  mParams, mRowParam: TNxParameters;
  i:integer;
  mOrigQty, mOrigUnit: Extended;
begin
  mContainer := getContainer(ADataSet.Site);
  if not(Assigned(ADataSet.CurrentItem)) then exit; //volá se při hromdném přidání, když ještě žádný řádek neexistuje. Asi je to tím prefillem
  OutputDebugString('BOMA: procedure beforeDeleteds - ' + ADataSet.CurrentItem.GetDisplayName);
  if Assigned(mContainer) then
  begin
    mUser := TNxCustomBusinessObject(mContainer.GetObject('currentUser'));
    if not(mUser.GetFieldValueAsBoolean('U_CreditOver')) then
    begin
      mBO := TNxCustomObjectDataSet(ADataSet).CurrentObject;
      try
        try
          mParams := TNxParameters(mContainer.GetObject(mBO.GetFieldValueAsString('Parent_ID.ClassID') + mBO.GetFieldValueAsString('Parent_ID')));
        except
          mParams := TNxParameters.Create;
          mContainer.AddObject(mBO.GetFieldValueAsString('Parent_ID.ClassID') + mBO.GetFieldValueAsString('Parent_ID'),mParams);
          fillCreditForFirm(mParams,TNxRowBusinessObject(mBO).Header.BusinessObject);
        end;

        mDL2 := mParams.ParamByName('dl2').AsFloat;  //na tomto dokladu
        showParamValues(mParams);
        if CFxFloat.IsZero2(mDL2) then //není ještě uložen, napočteme
        begin
          mHead:= TNxRowBusinessObject(mBO).Header.BusinessObject;
          mRows:= mHead.GetLoadedCollectionMonikerForFieldCode(mHead.GetFieldCode('Rows'));
          mList:=TStringList.Create;
          try
            for i:=0 to mRows.Count-1 do
            begin
              mRow := mRows.BusinessObject[i];
              if not(osMarkForDelete in mRow.State) then
              begin
                mAvStorePrice:=0;
                mAvStorePrice:=GetAvPrice(ADataSet.Site.BaseObjectSpace,mrow.GetFieldValueAsString('StoreCard_ID'),mrow.GetFieldValueAsString('Store_ID'));
                mDLRow:=mAvStorePrice*(mRow.GetFieldValueAsFloat('Quantity'));

                mDL2:=mDL2+mDLRow;
                if mParams.ParamExist(mBO.OID) then
                begin
                  mRowParam := mParams.ParamByName(mBO.OID).AsList;
                  mOrigQty := mRowParam.ParamByName('Quantity').AsFloat;
                end else begin
                  mRowParam := mParams.GetOrCreateParam(dtList,mBO.OID, pkInputOutput).AsList;
                  mRowParam.GetOrCreateParam(dtFloat, 'Quantity', pkInputOutput).AsFloat := mRow.GetFieldValueAsFloat('Quantity');
                  mRowParam.GetOrCreateParam(dtString, 'StoreCard_ID', pkInputOutput).AsString := mBO.GetFieldValueAsString('StoreCard_ID');
                  mOrigQty := 0;
                end;
              end;
             //NxShowSimpleMessage(FormatFloat(',0.00',mDL2),nil);
              mParams.ParamByName('dl2').AsFloat := mDL2;
              OutputDebugString('beforeDeleteds - po novém napočtení DL2');
              showParamValues(mParams);
            end;
          finally
            mList.Free;
          end;
        end else begin //aktualizujeme dle zadané změny

          mAvStorePrice:=0;
          mAvStorePrice:=GetAvPrice(ADataSet.Site.BaseObjectSpace,mBO.GetFieldValueAsString('StoreCard_ID'),mBO.GetFieldValueAsString('Store_ID'));
          mOrigQty := 0; //mažeme
          if mParams.ParamExist(mBO.OID) then //asi se to volá 2x při hromadném mazání
          begin
            mOrigUnit := mParams.ParamByName(mBO.OID).AsList.ParamByName('Quantity').AsFloat;
            OutputDebugString(format('orig: %n, new: %n', [mOrigUnit, mOrigQty]));
            mDLRow:=mAvStorePrice*(mOrigQty - mOrigUnit); //0-Orig => cena bude záporná
            mDL2:=mDL2+mDLRow;
            mParams.DeleteByName(mBO.OID);
            mParams.ParamByName('dl2').AsFloat := mDL2;
            OutputDebugString('BOMA: po vymazání');
            showParamValues(mParams);
          end;
        end;
        mContainer.UpdateObject(mBO.GetFieldValueAsString('Parent_ID.ClassID') + mBO.GetFieldValueAsString('Parent_ID'),mParams);
      finally
        mBO.Free;
      end;
    end;
  end else OutputDebugString('bomaContainer neexistuje');
end;

procedure beforePostds(ADataSet: TNxDataDataSet);
var
  mBO, mUser: TNxCustomBusinessObject;
  mFirm_ID: TNxOID;
  mContainer: TNxObjectContainer;
  mDL, mFP, mFV, mZL,mDV, mCredit, mDL2, mDLRow, mAvStorePrice:Extended;
  mResult, mList: TStringList;
  mHead, mRow: TNxCustomBusinessObject;
  mRows: TNxCustomBusinessMonikerCollection;
  mParams, mRowParam: TNxParameters;
  i:integer;
  mOrigQty, mNewQty: Extended;
begin
  mContainer := getContainer(ADataSet.Site);
  if not(Assigned(ADataSet.CurrentItem)) then exit; //volá se při hromdném přidání, když ještě žádný řádek neexistuje. Asi je to tím prefillem
  OutputDebugString('BOMA: procedure beforePostds - ' + ADataSet.CurrentItem.GetDisplayName);
  if Assigned(mContainer) then
  begin
    mUser := TNxCustomBusinessObject(mContainer.GetObject('currentUser'));
    if not(mUser.GetFieldValueAsBoolean('U_CreditOver')) then
    begin
      mBO := TNxCustomObjectDataSet(ADataSet).CurrentObject;
      try
        try
          mParams := TNxParameters(mContainer.GetObject(mBO.GetFieldValueAsString('Parent_ID.ClassID') + mBO.GetFieldValueAsString('Parent_ID')));
        except
          mParams := TNxParameters.Create;
          mContainer.AddObject(mBO.GetFieldValueAsString('Parent_ID.ClassID') + mBO.GetFieldValueAsString('Parent_ID'),mParams);
          fillCreditForFirm(mParams,TNxRowBusinessObject(mBO).Header.BusinessObject);
        end;

        mCredit:= mParams.ParamByName('credit').AsFloat;
        mZL := mParams.ParamByName('zl').AsFloat;
        mFV := mParams.ParamByName('fv').AsFloat;
        mDV := mParams.ParamByName('dv').AsFloat;
        mFP := mParams.ParamByName('fp').AsFloat;
        mDL := mParams.ParamByName('dl').AsFloat;  //čerpatelný
        mDL2 := mParams.ParamByName('dl2').AsFloat;  //na tomto dokladu
        showParamValues(mParams);
        if CFxFloat.IsZero2(mDL2) then //není ještě uložen, napočteme vše znova
        begin
          mHead:= TNxRowBusinessObject(mBO).Header.BusinessObject;
          mRows:= mHead.GetLoadedCollectionMonikerForFieldCode(mHead.GetFieldCode('Rows'));
          mList:=TStringList.Create;
          try
            for i:=0 to mRows.Count-1 do
            begin
              mRow := mRows.BusinessObject[i];
              if not(osMarkForDelete in mRow.State) then
              begin
                mAvStorePrice:=0;
                mAvStorePrice:=GetAvPrice(ADataSet.Site.BaseObjectSpace,mrow.GetFieldValueAsString('StoreCard_ID'),mrow.GetFieldValueAsString('Store_ID'));
                mDLRow:=mAvStorePrice*(mRow.GetFieldValueAsFloat('Quantity'){/mRow.GetFieldValueAsFloat('UnitRate')});
                OutputDebugString(Format('mAvStorePrice: %n ;Quantity: %n; UnitRate: %n',[mAvStorePrice, mRow.GetFieldValueAsFloat('Quantity'), mRow.GetFieldValueAsFloat('UnitRate')]));
                mDL2:=mDL2+mDLRow;
                if mParams.ParamExist(mBO.OID) then
                begin
                  mRowParam := mParams.ParamByName(mBO.OID).AsList;
                  mOrigQty := mRowParam.ParamByName('Quantity').AsFloat;
                end else begin
                  mRowParam := mParams.GetOrCreateParam(dtList,mBO.OID, pkInputOutput).AsList;
                  mRowParam.GetOrCreateParam(dtFloat, 'Quantity', pkInputOutput).AsFloat := mRow.GetFieldValueAsFloat('Quantity');
                  mRowParam.GetOrCreateParam(dtString, 'StoreCard_ID', pkInputOutput).AsString := mBO.GetFieldValueAsString('StoreCard_ID');
                  mOrigQty := 0;
                end;
              end;
             //NxShowSimpleMessage(FormatFloat(',0.00',mDL2),nil);
              mParams.ParamByName('dl2').AsFloat := mDL2;
              OutputDebugString('beforePostds - po novém napočtení DL2');
              showParamValues(mParams);
            end;
          finally
            mList.Free;
          end;
        end else begin //aktualizujeme dle zadané změny
          mNewQty := mBO.GetFieldValueAsFloat('Quantity');
          //je to nová položka?
          if mParams.ParamExist(mBO.OID) then
          begin
            mRowParam := mParams.ParamByName(mBO.OID).AsList;
            mOrigQty := mRowParam.ParamByName('Quantity').AsFloat;
          end else begin
            mRowParam := mParams.GetOrCreateParam(dtList,mBO.OID, pkInputOutput).AsList;
            mRowParam.GetOrCreateParam(dtFloat, 'Quantity', pkInputOutput).AsFloat := 0;
            mRowParam.GetOrCreateParam(dtString, 'StoreCard_ID', pkInputOutput).AsString := mBO.GetFieldValueAsString('StoreCard_ID');
            mOrigQty := 0;
          end;
          if osMarkForDelete in mBO.State then
          begin
            //je to položka k vymazání?
            mAvStorePrice:=0;
            mAvStorePrice:=GetAvPrice(ADataSet.Site.BaseObjectSpace,mBO.GetFieldValueAsString('StoreCard_ID'),mBO.GetFieldValueAsString('Store_ID'));
            OutputDebugString('mazání položky: ' + NxFloatToIBStr(mAvStorePrice * mNewQty));
            mDL2:=mDL2 - (mAvStorePrice * mNewQty);
            OutputDebugString('mazání položky DL2: ' + NxFloatToIBStr(mDL2));
          end else begin
            //je stejná skladová karta?
            if not(mRowParam.ParamByName('StoreCard_ID').AsString = mBO.GetFieldValueAsString('StoreCard_ID')) then
            begin
              //musíme původní hodnotu odečíst
              mAvStorePrice:=0;
              mAvStorePrice:=GetAvPrice(ADataSet.Site.BaseObjectSpace,mRowParam.ParamByName('StoreCard_ID').AsString,mBO.GetFieldValueAsString('Store_ID'));
              mDL2 := mDL2 - (mAvStorePrice * (mRowParam.ParamByName('Quantity').AsFloat));
              OutputDebugString('změna položky DL2: ' + NxFloatToIBStr(mDL2));
              //a přidat novou hodnotu
              mAvStorePrice:=0;
              mAvStorePrice:=GetAvPrice(ADataSet.Site.BaseObjectSpace,mBO.GetFieldValueAsString('StoreCard_ID'),mBO.GetFieldValueAsString('Store_ID'));
              mDL2 := mDL2 + (mAvStorePrice * mNewQty);
              OutputDebugString('změna položky DL2: ' + NxFloatToIBStr(mDL2));
              mRowParam.ParamByName('StoreCard_ID').AsString := mBO.GetFieldValueAsString('StoreCard_ID');
              mRowParam.ParamByName('Quantity').AsFloat := mNewQty;
              mOrigQty := mNewQty; //dál už nic neměníme
            end;
            if not(CFxFloat.Equal6(mOrigQty, mNewQty)) then
            begin //změnilo se množství
              OutputDebugString(format('orig: %n, new: %n', [mOrigQty, mNewQty]));
              mAvStorePrice:=0;
              mAvStorePrice:=GetAvPrice(ADataSet.Site.BaseObjectSpace,mBO.GetFieldValueAsString('StoreCard_ID'),mBO.GetFieldValueAsString('Store_ID'));
              mDL2:=mDL2 + (mAvStorePrice*(mNewQty - mOrigQty));
              OutputDebugString('změna množství DL2: ' + NxFloatToIBStr(mDL2));
              mRowParam.ParamByName('Quantity').AsFloat := mNewQty;
            end;
          end;
          mParams.ParamByName('dl2').AsFloat := mDL2;

        end;
        OutputDebugString('BOMA: máme po výpočtech');
        showParamValues(mParams);
        if canProcessBO(mfv, mfp, mdv, mzl, mdl, mdl2, mcredit, 0) then
        begin
          NxShowMessage('Překročen kredit', 'Tímto řádkem překračujete povolený kredit pro firmu '+mBO.GetFieldValueAsString('Parent_id.Firm_id.Name')+Chr(10)+Chr(13)+
          'Kredit  '+FormatFloat(',0.00',mCredit)+Chr(10)+Chr(13)+
          'FV      '+FormatFloat(',0.00',mFV + mBO.GetFieldValueAsFloat('Parent_ID.localamount'))+Chr(10)+Chr(13)+
          'FP      '+FormatFloat(',0.00',mfP)+Chr(10)+Chr(13)+
          'DV      '+FormatFloat(',0.00',mDV)+Chr(10)+Chr(13)+
          'ZL      '+FormatFloat(',0.00',mZL)+Chr(10)+Chr(13)+
          'DL cca  '+FormatFloat(',0.00',Max_1(mDL+mdl2,0))+Chr(10)+Chr(13)+Chr(10)+Chr(13)+
          'Aktuální řádek smažte. Pokud zadáte další řádky, doklad se neuloží.',mdStop, False, ADataSet.Site.GetSiteAppForm);
        end;

        mContainer.UpdateObject(mBO.GetFieldValueAsString('Parent_ID.ClassID') + mBO.GetFieldValueAsString('Parent_ID'),mParams);
      finally
        mBO.Free;
      end;
    end;
  end else OutputDebugString('bomaContainer neexistuje');
end;

function canProcessBO(mFV, mFP, mDV, mZl, mDL, mDL2, mCredit, mDocAmount: Extended): Boolean;
begin
  OutputDebugString('canProcessBO : ' + FloatToStr(((mFV-mFP- mZL+(mDL+mDL2+mDocAmount)*1.1))) + ' ?> ' + FloatToStr((mCredit*1.2)));
  Result := (((mFV-mFP- mZL+(mDL+mDL2+mDocAmount)*1.1))>(mCredit*1.2));
end;

{
procedure _AfterEditRec_Hook(Self: TDynSiteForm);
var
  mContainer: TNxObjectContainer;
  mParams: TNxParameters;
  i: Integer;
  mBO, mRow: TNxCustomBusinessObject;
  mRows: TNxCustomBusinessMonikerCollection;
  mResult: TStringList;
  mFirm_ID: TNxOID;
begin
  mContainer := getContainer(Self);
  if Assigned(mContainer) then
  begin
    mBO := Self.CurrentObject;
    try
      try
        mParams := TNxParameters(mContainer.GetObject(mBO.CLSID + mBO.OID));
      except
        mParams := TNxParameters.Create;   //necháme, kdybychom opravovali stejnou FV, tak ať se nevytváří, ale pro jistotu nulujeme. Destrouy je s destroyem agendy
        mContainer.AddObject(mBO.CLSID + mBO.OID,mParams);
      end;
      mParams.GetOrCreateParam(dtFloat, 'zl', pkInputOutput).AsFloat := 0;
      mParams.GetOrCreateParam(dtFloat, 'fv', pkInputOutput).AsFloat := 0;
      mParams.GetOrCreateParam(dtFloat, 'dv', pkInputOutput).AsFloat := 0;
      mParams.GetOrCreateParam(dtFloat, 'fp', pkInputOutput).AsFloat := 0;
      mParams.GetOrCreateParam(dtFloat, 'dl', pkInputOutput).AsFloat := 0;
      mParams.GetOrCreateParam(dtFloat, 'dl2', pkInputOutput).AsFloat:= 0;
      mParams.GetOrCreateParam(dtFloat, 'credit', pkInputOutput).AsFloat := 0;

      mRows := mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
      for i:= 0 to mRows.Count -1 do
      begin
        mRow := mRows.BusinessObject[i];
        if mRow.GetFieldValueAsInteger('RowType') = 3 then
        begin
          mParams.GetOrCreateParam(dtList, mRow.OID, pkInputOutput);
          mParams.ParamByName(mRow.OID).AsList.GetOrCreateParam(dtFloat, 'Quantity', pkInputOutput).AsFloat := mRow.GetFieldValueAsFloat('UnitQuantity');
          mParams.ParamByName(mRow.OID).AsList.GetOrCreateParam(dtString, 'StoreCard_ID', pkInputOutput).AsString := mRow.GetFieldValueAsString('StoreCard_ID');
        end;
      end;
      mFirm_ID := mBO.GetFieldValueAsString('Firm_ID');
      OutputDebugString(Format(cSQL, [mBO.OID, mBO.OID, mFirm_ID, mFirm_ID]));
      mResult := TStringList.Create;
      try
        Self.BaseObjectSpace.SQLSelect(Format(cSQL, [mBO.OID, '0000000000', mFirm_ID, mFirm_ID]), mResult);
        OutputDebugString('SQLResult: ' + mResult[0]);
        mParams.ParamByName('zl').AsFloat := NxIBStrToFloat(NxTrapStr(mResult[0], ';'));
        mParams.ParamByName('fv').AsFloat := NxIBStrToFloat(NxTrapStr(mResult[0], ';'));
        mParams.ParamByName('dv').AsFloat := NxIBStrToFloat(NxTrapStr(mResult[0], ';'));
        mParams.ParamByName('fp').AsFloat := NxIBStrToFloat(NxTrapStr(mResult[0], ';'));
        mParams.ParamByName('dl').AsFloat := NxIBStrToFloat(NxTrapStr(mResult[0], ';'));
        mParams.ParamByName('dl2').AsFloat := NxIBStrToFloat(NxTrapStr(mResult[0], ';'));
        mParams.ParamByName('credit').AsFloat := mBO.GetFieldValueAsFloat('Firm_ID.Credit');
        mContainer.UpdateObject(mBO.CLSID + mBO.OID,mParams); //teoreticky nemusí být
      finally
        mResult.Free;
      end;
    finally
      mBO.Free;
    end;
  end else OutputDebugString('bomaContainer neexistuje');
end;
}
begin
end.