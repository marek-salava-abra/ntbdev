uses 'eu.obb.checkcreditbezdv.common';

procedure beforeDeleteds(ADataSet: TNxDataDataSet);
var
  mBO, mUser: TNxCustomBusinessObject;
  mFirm_ID: TNxOID;
  mContainer: TNxObjectContainer;
  mDL, mFP, mFV, mZL,mDV, mCredit, mDL2, mDLRow, mAvStorePrice:Extended;
  mResult, mList: TStringList;
  mHead, mRow: TNxCustomBusinessObject;
  mRows: TNxCustomBusinessMonikerCollection;
  mParams: TNxParameters;
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
                mDLRow:=mAvStorePrice*(mRow.GetFieldValueAsFloat('Quantity')/mRow.GetFieldValueAsFloat('UnitRate'));

                mDL2:=mDL2+mDLRow;
              end;
             //NxShowSimpleMessage(FormatFloat(',0.00',mDL2),nil);
              mParams.ParamByName('dl2').AsFloat := mDL2;
              showParamValues(mParams);
            end;
          finally
            mList.Free;
          end;
        end else begin //aktualizujeme dle zadané změny

          mAvStorePrice:=0;
          mAvStorePrice:=GetAvPrice(ADataSet.Site.BaseObjectSpace,mBO.GetFieldValueAsString('StoreCard_ID'),mBO.GetFieldValueAsString('Store_ID'));
          mOrigQty := 0; //mažeme
          if mParams.ParamExist(mBO.OID) then
          begin
            mOrigUnit := mParams.ParamByName(mBO.OID).AsList.ParamByName('Quantity').AsFloat;
            OutputDebugString(format('orig: %n, new: %n', [mOrigUnit, mOrigQty]));
            mDLRow:=mAvStorePrice*(mOrigQty - mOrigUnit);
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
                mDLRow:=mAvStorePrice*(mRow.GetFieldValueAsFloat('Quantity')/mRow.GetFieldValueAsFloat('UnitRate'));

                mDL2:=mDL2+mDLRow;
              end;
             //NxShowSimpleMessage(FormatFloat(',0.00',mDL2),nil);
              mParams.ParamByName('dl2').AsFloat := mDL2;
              showParamValues(mParams);
            end;
          finally
            mList.Free;
          end;
        end else begin //aktualizujeme dle zadané změny
          mNewQty := mBO.GetFieldValueAsFloat('UnitQuantity');
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
          //je stejná skladová karta?
          if not(mRowParam.ParamByName('StoreCard_ID').AsString = mBO.GetFieldValueAsString('StoreCard_ID')) then
          begin
            //musíme původní hodnotu odečíst
            mAvStorePrice:=0;
            mAvStorePrice:=GetAvPrice(ADataSet.Site.BaseObjectSpace,mRowParam.ParamByName('StoreCard_ID').AsString,mBO.GetFieldValueAsString('Store_ID'));
            mDL2 := mDL2 - (mAvStorePrice * (mRowParam.ParamByName('Quantity').AsFloat));
            //a přidat novou hodnotu
            mAvStorePrice:=0;
            mAvStorePrice:=GetAvPrice(ADataSet.Site.BaseObjectSpace,mBO.GetFieldValueAsString('StoreCard_ID'),mBO.GetFieldValueAsString('Store_ID'));
            mDL2 := mDL2 + (mAvStorePrice * mNewQty);
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
            mRowParam.ParamByName('Quantity').AsFloat := mNewQty;
          end;
          mParams.ParamByName('dl2').AsFloat := mDL2;

        end;
        OutputDebugString('BOMA: máme po výpočtech');
        showParamValues(mParams);
          if mBO.GetFieldValueAsFloat('Parent_ID.localamount')>10 then
          begin
            if ((mFV + mBO.GetFieldValueAsFloat('Parent_ID.localamount')-mDV-mFP-mZL+(Max_1(mDL-mdl2,0)*1.1))>mCredit*1.2) then
            begin
              NxShowMessage('Překročen kredit', 'Tímto řádkem překračujete povolený kredit pro firmu '+mBO.GetFieldValueAsString('Parent_id.Firm_id.Name')+Chr(10)+Chr(13)+
              'Kredit          '+FormatFloat(',0.00',mCredit)+Chr(10)+Chr(13)+
              'FV včetně této  '+FormatFloat(',0.00',mFV + mBO.GetFieldValueAsFloat('Parent_ID.localamount'))+Chr(10)+Chr(13)+
              'FV bez této     '+FormatFloat(',0.00',mFV)+Chr(10)+Chr(13)+
              'FP              '+FormatFloat(',0.00',mfP)+Chr(10)+Chr(13)+
              'DV              '+FormatFloat(',0.00',mDV)+Chr(10)+Chr(13)+
              'ZL              '+FormatFloat(',0.00',mZL)+Chr(10)+Chr(13)+
              'DL cca          '+FormatFloat(',0.00',Max_1(mDL-mdl2,0))+Chr(10)+Chr(13)+Chr(10)+Chr(13)+
              'Aktuální řádek smažte. Pokud zadáte další řádky, doklad se neuloží.',mdStop, False, ADataSet.Site.GetSiteAppForm);
            end;
            //AResult:=False;
          end;

        mContainer.UpdateObject(mBO.GetFieldValueAsString('Parent_ID.ClassID') + mBO.GetFieldValueAsString('Parent_ID'),mParams);
      finally
        mBO.Free;
      end;
    end;
  end else OutputDebugString('bomaContainer neexistuje');
end;

begin
end.