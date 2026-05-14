


{
  ProductReceptionRowIns
}
function ProductReceptionRowIns(Self: TNxWebServicesHelper;Params: TStringDynArray):String;

  function GetManufacturedItem(ABO : TNxCustomBusinessObject; AStoreCard_ID : TNxOID) : TNxCustomBusinessObject;
  var
    mItems : TNxCustomBusinessMonikerCollection;
    i : integer;
  begin
    NxScriptingLog.EnterSection('eu.abra.Qx/templateImpl.ProductReceptionRowIns.GetManufacturedItems', logDebug);
    Result := nil;
    try
      mItems := ABO.GetLoadedCollectionMonikerForFieldCode(ABO.GetFieldCode('PLMManufacturedItems'));
      for i := 0 to mItems.Count - 1 do begin
        if mItems.BusinessObject[i].GetFieldValueAsString('StoreCard_ID') = AStoreCard_ID then begin
          result := mItems.BusinessObject[i];
          NxScriptingLog.WriteEvent(logDebug, 'mam vysledek');
          exit;
        end
      end;
      NxScriptingLog.WriteEvent(logDebug, 'Nebyla nalezena vyrabena polozka');
    finally
      NxScriptingLog.LeaveSection('eu.abra.Qx/templateImpl.ProductReceptionRowIns.GetManufacturedItems' , logDebug);
    end;
  end;


  function GetFinishedProduct(AJobOrderBO : TNxCustomBusinessObject; AManufacturedItem_ID : string; AQuantity : double; AEnableCreateFinishedProduct : boolean; AStoreBatch_ID : string; APLMWorker_ID : string = '') : TStringList;
  // vrati seznam dokoncenych vzrobku, ktere je mozno pouzit, struktura: ID hlavicky:ID radku

    function CreateNewFinishedProduct(AFinishedProductBO: TNxCustomBusinessObject; ANewQuantity : double; AWorker_ID : string; AStoreBatch_ID : string) : TNxCustomBusinessObject;
    var
      mFP, mFPSN : TNxCustomBusinessObject;
      mPLMOperation : TNxCustomBusinessObject;
      s : string;
      i : integer;
      mDate : TDateTime;
      mFPRows : TNxCustomBusinessMonikerCollection;
    begin
      NxScriptingLog.EnterSection('eu.abra.Qx/templateImpl.ProductReceptionRowIns.GetFinishedProduct.CreateNewFinishedProduct', logDebug);
      try
        Result := nil;
        mFPSN := nil;
        mFPRows := AFinishedProductBO.GetCollectionMonikerForFieldCode(AFinishedProductBO.GetFieldCode('Rows'));
        mFP := mFPRows.AddNewObject;
        mFP.SetFieldValueAsString('ManufacturedItem_ID', AManufacturedItem_ID);
        mFP.SetFieldValueAsFloat('Quantity', ANewQuantity);
        mFP.SetFieldValueAsFloat('UnitRate',  mFP.GetFieldValueAsFloat('ManufacturedItem_ID.UnitRate'));
        mFP.SetFieldValueAsString('Qunit', mFP.GetFieldValueAsString('ManufacturedItem_ID.QUnit'));

        if mFP.GetFieldValueAsInteger('ManufacturedItem_ID.StoreCard_ID.Category') = 2 then begin
          mFPSN := Self.ObjectSpace.CreateObject(Class_PLMJobOrdersSN);
          mFPSN.New;
          mFPSN.Prefill;
          mFPSN.SetFieldValueAsString('Parent_ID', AManufacturedItem_ID);
          mFPSN.SetFieldValueAsString('StoreBatch_ID', AStoreBatch_ID);
          mFP.SetFieldValueAsString('JobOrdersSN_ID', mFPSN.OID);
        end;

        mPLMOperation := Self.ObjectSpace.CreateObject(Class_PLMOperation);
        try
          mPLMOperation.New;
          mPLMOperation.Prefill;
          s := SearchFinishRoutine_ID(Self.ObjectSpace, AManufacturedItem_ID);
          if (NxIsEmptyOID(s)) then RaiseException('Nenalezena ukončující operace');
          mPLMOperation.SetFieldValueAsString('JobOrdersRoutines_ID', s);
          mDate := now();
          mPLMOperation.SetFieldValueAsDateTime('StartedAt$DATE', mDate);
          mPLMOperation.SetFieldValueAsDateTime('FinishedAt$DATE', mDate);
          mPLMOperation.SetFieldValueAsFloat('UnitQuantity', ANewQuantity);
          mPLMOperation.SetFieldValueAsBoolean('OperationResult', true);
          mPLMOperation.SetFieldValueAsString('PerformedBy_ID', AWorker_ID);
          mPLMOperation.SetFieldValueAsString('FinishedProductRow_ID', mFP.OID);

          NxScriptingLog.WriteEvent(logDebug, 'CreateNewFinishedProduct 3.0');
          Self.ObjectSpace.StartTransaction(taReadCommited);
          try
            s := mFP.OID;
            if Assigned(mFPSN) then
              mFPSN.Save;
            AFinishedProductBO.save;
            mPLMOperation.Save;
            Self.ObjectSpace.Commit;
            NxScriptingLog.WriteEvent(logDebug, 'CreateNewFinishedProduct - Novy dokonceny vyrobek.. commit');
            mFPRows := AFinishedProductBO.GetLoadedCollectionMonikerForFieldCode(AFinishedProductBO.GetFieldCode('Rows'));
            for i := 0 to mFPRows.Count - 1 do begin
              if ( mFPRows.BusinessObject[i].OID = s ) then begin
                Result := mFPRows.BusinessObject(i);
                exit;
              end;
            end;
            NxScriptingLog.WriteEvent(logDebug, 'Novy dokonceny vyrobek.. problem!!!');
          except
            Self.ObjectSpace.RollBack;
            RaiseException(ExceptionMessage);
          end;
        finally
          mPLMOperation.Free;
          if Assigned(mFPSN) then
            mFPSN.Free;
        end;
      finally
        NxScriptingLog.LeaveSection('eu.abra.Qx/templateImpl.ProductReceptionRowIns.GetFinishedProduct.CreateNewFinishedProduct' , logDebug);
      end;
    end;


    function GetFinishedProducts(AManufacturedItem_ID : string) : TObjectList;
    const
      SQL = 'SELECT A.Parent_ID FROM PLMFinishedProducts2 A WHERE A.ManufacturedItem_ID=''%s'' AND A.StoreDoc2_ID is null group by A.Parent_ID';
    var
      L : TStringList;
      i : integer;
      mBO : TNxCustomBusinessObject;
    begin
      NxScriptingLog.EnterSection('eu.abra.Qx/templateImpl.ProductReceptionRowIns.GetFinishedProduct.GetFinishedProducts', logDebug);
      try
        result := TObjectList.Create(False); // potencialni memory leak
        L := TStringList.Create;
        try
          Self.ObjectSpace.SQLSelect(Format(SQL, [AManufacturedItem_ID]), L);

          for i := 0 to L.Count - 1 do begin
            mBO := Self.ObjectSpace.CreateObject(Class_PLMFinishedProduct);
            mBO.load(l.Strings[i], nil);
            result.add(mBO);
          end;
        finally
          L.Free;
        end;
      finally
        NxScriptingLog.LeaveSection('eu.abra.Qx/templateImpl.ProductReceptionRowIns.GetFinishedProduct.GetFinishedProducts', logDebug);
      end;
    end;

  var
    mFinishedProducts : TObjectList;
    i, j : integer;
    mSumQuantity : double;
    mFP, mHead, mRow : TNxCustomBusinessObject;
    mFree : boolean;
    mRows : TNxCustomBusinessMonikerCollection;
  begin
    NxScriptingLog.EnterSection('eu.abra.Qx/templateImpl.ProductReceptionRowIns.GetFinishedProduct', logDebug);
    try
      mFinishedProducts := GetFinishedProducts(AManufacturedItem_ID);
      try
        NxScriptingLog.WriteEventFmt(logDebug, 'Bylo nalezeno %d radku dokoncenych vyrobku, hledany pocet %f', [mFinishedProducts.count, AQuantity]);
        mSumQuantity := 0.0;
        result := TStringList.Create;
        mFP := nil;
        mHead := nil;
        for i := 0 to mFinishedProducts.count - 1 do begin // projdu vsechny dokoncene vyrobky, ktere nemaji prijem na sklad
          mHead := TNxCustomBusinessObject(mFinishedProducts.Items[i]);
          mRows := mHead.GetLoadedCollectionMonikerForFieldCode(mHead.GetFieldCode('Rows'));
          for j := 0 to mRows.Count - 1 do begin
            mRow := mRows.BusinessObject[j];
            NxScriptingLog.WriteEventFmt(logDebug, 'Iteruji - Dokonceny vyrobek %s, pocet = %f, pozadovany pocet=%f', [mHead.DisplayName, mRow.GetFieldValueAsFloat('Quantity'), AQuantity]);
            if (not NxIsEmptyOID(mRow.GetFieldValueAsString('StoreDoc2_ID')) )then
              continue;

            mSumQuantity := mSumQuantity + mRow.GetFieldValueAsFloat('Quantity');
            if mRow.GetFieldValueAsFloat('Quantity') = AQuantity then begin
              NxScriptingLog.WriteEventFmt(logDebug, 'Mnozstvi odpovida(1) nalezen dokonceny vyrobek %s s pocem %f', [mRow.DisplayName, mRow.GetFieldValueAsFloat('Quantity')]);
              result.add(format('%s:%s', [mHead.OID, mRow.OID]));
              exit;
            end;

            if mRow.GetFieldValueAsFloat('Quantity') > AQuantity then begin
              NxScriptingLog.WriteEventFmt(logDebug, 'Dokonceny vyrobek %s, pocet = %f, pozadovany pocet=%f', [mHead.DisplayName, mRow.GetFieldValueAsFloat('Quantity'), AQuantity]);
              if not Assigned(mFP) then
                mFP := mRow;
              if mRow.GetFieldValueAsFloat('Quantity') < mFP.GetFieldValueAsFloat('Quantity') then
                mFP := mRow;
            end;
          end; // END FOR Rows
        end; // END FOR

        if Assigned(mFP) then begin
          result.add(format('%s:%s', [mRow.GetFieldValueAsString('Parent_ID'), mRow.OID]));
          NxScriptingLog.WriteEventFmt(logDebug, 'Mnozstvi je vetsi(2) nalezen dokonceny vyrobek %s s pocem %f', [mFP.GetFieldValueAsString('Parent_ID.DisplayName'),  mFP.GetFieldValueAsFloat('Quantity')]);
          exit;
        end;

        if mSumQuantity < AQuantity then begin
          if not AEnableCreateFinishedProduct then
            RaiseException('Neni k dispozici pozadovane mnozstvi vyrobku.');
          if not Assigned(mHead) then begin
            mHead := Self.ObjectSpace.CreateObject(Class_PLMFinishedProduct);
            mHead.New;
            mHead.Prefill;
            mHead.SetFieldValueAsString('JobOrder_ID', AJobOrderBO.OID);
            mFinishedProducts.add(mHead); // nova hlavicka FinishedProduct, je potreba ji vlozit do seznamu aby byl objekt radne uvolnen
          end;
          mFP := CreateNewFinishedProduct(mHead, AQuantity - mSumQuantity, APLMWorker_ID, AStoreBatch_ID);
          NxScriptingLog.WriteEvent(logDebug, 'Dokonceno vytvareni noveho PLMFinishedProductRow');
          NxScriptingLog.WriteEvent(logDebug, 'mFP=' + NxIIfStr( Assigned(mFP), 'not null', 'null') );
          if mSumQuantity > 0 then
            mFP := nil; // bude vice radku pro prijem
        end;
        if Assigned(mFP) then begin
          NxScriptingLog.WriteEvent(logDebug, 'Mnozstvi je vetsi(2b) nalezen dokonceny vyrobek');
          NxScriptingLog.WriteEventFmt(logDebug, 'Mnozstvi je vetsi(2b) nalezen dokonceny vyrobek %s s pocem %f', [mFP.GetFieldValueAsString('Parent_ID.DisplayName'),  mFP.GetFieldValueAsFloat('Quantity')]);
          result.add(format('%s:%s', [mFP.GetFieldValueAsString('Parent_ID'), mFP.OID]));
          exit;
        end;
        mSumQuantity := 0.0;
        NxScriptingLog.WriteEvent(logDebug, 'Priprava na 3...');
        for i := 0 to mFinishedProducts.count - 1 do begin
          mHead := TNxCustomBusinessObject(mFinishedProducts.Items[i]);
          mRows := mHead.GetLoadedCollectionMonikerForFieldCode(mHead.GetFieldCode('Rows'));
          for j := 0 to mRows.Count - 1 do begin
            mRow := mRows.BusinessObject[j];
            if not NxIsEmptyOID(mRow.GetFieldValueAsString('StoreDoc2_ID')) then
              continue;
            mSumQuantity := mSumQuantity + mRow.GetFieldValueAsFloat('Quantity');
            NxScriptingLog.WriteEventFmt(logDebug, 'Bude vice radku v PHV(3) nalezen dokonceny %s vyrobek s pocem %f', [mHead.DisplayName, mRow.GetFieldValueAsFloat('Quantity')]);
            result.add(format('%s:%s', [mHead.OID, mRow.OID]));
            if mSumQuantity >= AQuantity then
              exit;
          end;
        end;
      finally
        { verze 15.01, revize
        // pokud je zde chyba bude to zrat pamet > memory leak
        // odstranim z kolekce ty radky, ktere se neredavani ve vystupu a zrusim pomocnou kolekci, kolekce NEVLASTNI objekty v ni
        for i := 0 to mFinishedProducts.count -1 do begin
          mFree := True;
          for j := 0 to result.count -1 do begin
            if TNxCustomBusinessObject(mFinishedProducts.Items[i]).OID = TNxCustomBusinessObject(result.Items[j]).OID then
              mFree := False;
          end;
          if mFree then
            TNxCustomBusinessObject(mFinishedProducts.Items[i]).Free;
        end;
        }
        for i := 0 to mFinishedProducts.count -1 do begin
          TNxCustomBusinessObject(mFinishedProducts.Items[i]).Free;
        end;
        mFinishedProducts.Free;
      end;
    finally
      NxScriptingLog.LeaveSection('eu.abra.Qx/templateImpl.ProductReceptionRowIns.GetFinishedProduct', logDebug);
    end;
  end;

var
  T : TDateTime;
  mParams : TStringList;
  i, j : integer;
  s, mQUnit : string;
  mJobOrder_ID, mStoreCard_ID : TNxOID;
  mQuantity : double;
  mProductReceptionBO : TNxHeaderBusinessObject;
  mJobOrderBO, mManufacturedItem, {mProduct,} mNewProduct, mProductReceptionRowBO, mDocBatchBO : TNxCustomBusinessObject;
  mProducts : TObjectList;
  mFinishedProductList : TStringList;
  mWorker_ID, mStoreBatch_ID : string;
  mEnableCreateFinishedProduct : boolean;


  mFinishedProductBO, mFinishedProductRowBO : TNxCustomBusinessObject;
  mFinishedProductRows : TNxCustomBusinessMonikerCollection;
  mHead_ID, mRow_ID : string;
begin
  NxScriptingLog.EnterSection('eu.abra.Qx/templateImpl.ProductReceptionRowIns', logNotice);
  try
    T := now;
    try
      mEnableCreateFinishedProduct := False; // povoluje vygenerovani dokonceneho vyrobku v pripade nedostatecneho mnozstvi
      mParams := TStringList.Create;
      try
      {


2015-01-19 21:48:11.391 DEBUG - SProductReceptionRowWorker - param>StoreCard_ID=LO30000101
2015-01-19 21:48:11.391 DEBUG - SProductReceptionRowWorker - param>JobOrder_ID=1QS2000101
2015-01-19 21:48:11.391 DEBUG - SProductReceptionRowWorker - param>Quantity=10.0
2015-01-19 21:48:11.391 DEBUG - SProductReceptionRowWorker - param>StoreBatch_ID=
2015-01-19 21:48:11.391 DEBUG - SProductReceptionRowWorker - param>PerformedBy_ID=2100000101
2015-01-19 21:48:11.392 DEBUG - SProductReceptionRowWorker - param>EnableCreateFinishedProduct=True
2015-01-19 21:48:11.392 DEBUG - SProductReceptionRowWorker - param>UnitCode=ks

      }
        //NxScriptingLog.WriteEventAndData_1(logDebug, 'Params', NxFillStringArrayToString(Params));
        for i := 0 to Length(Params) - 1 do begin
          mParams.Add(Params[i]);
          NxScriptingLog.WriteEvent(logDebug, 'Param >> '+ Params[i]);
        end;
        //NxScriptingLog.WriteEventAndData_1(logDebug, 'Params', mParams.Text); // toto nejak rozbije zapis v logu

        mJobOrder_ID := mParams.Values('JobOrder_ID');
        mStoreCard_ID := mParams.Values('StoreCard_ID');
        mWorker_ID := mParams.Values('PerformedBy_ID');
        mStoreBatch_ID := mParams.Values('StoreBatch_ID');
        s := mParams.Values('EnableCreateFinishedProduct');
        if ( not NxIsBlank(s) ) then
          mEnableCreateFinishedProduct := (UpperCase(s)='TRUE') or (UpperCase(s)='A') or (UpperCase(s)='YES') or (UpperCase(s)='Y');
        s := mParams.Values('Quantity');
        mQuantity := NxIBStrToFloat(s);
        mQUnit := mParams.Values('UnitCode');

        NxScriptingLog.WriteEventFmt(logDebug, 'Zpracovam - JobOrder_ID=%s, StoreCard_ID=%s, Quantity=%f, QUnit=%s', [mJobOrder_ID, mStoreCard_ID, mQuantity, mQUnit]);

        mJobOrderBO := self.ObjectSpace.CreateObject(Class_PLMJobOrder);
        try
          mJobOrderBO.Load(mJobOrder_ID, nil);
          if mJobOrderBO.GetFieldValueAsString('StoreCard_ID') <> mStoreCard_ID then
            RaiseException('Vyráběná položka neodpovídá zadané skladové kartě');

          mManufacturedItem := GetManufacturedItem(mJobOrderBO, mStoreCard_ID);

          if not Assigned(mManufacturedItem) then
            RaiseException(Format('pro vyrobni prikaz %s nebyla nalezena vyrabena vyrabena polozka StoreCard_ID=%s', [mJobOrderBO.DisplayName, mStoreCard_ID]));

          NxScriptingLog.WriteEventFmt(logDebug,'pro vyrobni prikay %s byla nalezena vyrabena vyrabena polozka StoreCard_ID=%s', [mJobOrderBO.DisplayName, mStoreCard_ID]);

          mFinishedProductList := GetFinishedProduct(mJobOrderBO, mManufacturedItem.OID, mQuantity, mEnableCreateFinishedProduct, mStoreBatch_ID, mWorker_ID);
          try
            if mFinishedProductList.count = 0 then
              RaiseException('Zadny dokonceny vyrobek k dispozici');

            mProductReceptionBO := TNxHeaderBusinessObject(Self.ObjectSpace.CreateObject(Class_ProductReception));
            try
              mNewProduct := nil;
//              mOldProduct := nil;
              mProductReceptionBO.New;
              mProductReceptionBO.Prefill;
              mProductReceptionBO.SetFieldValueAsString('DocQueue_ID', getProductReceptionDocQueue(mJobOrderBO) );
              mProductReceptionBO.SetFieldValueAsString('Firm_ID', mJobOrderBO.GetFieldValueAsString('Firm_ID'));


              mProducts := TObjectList.Create();
              try

              for i := 0 to mFinishedProductList.count - 1 do begin
                mHead_ID := copy(mFinishedProductList.Strings[i], 1, 10);
                mRow_ID := copy(mFinishedProductList.Strings[i], 12, 10);

                // pokud jsem jiz pouzil objekt FinishedProduct tak jej staci vytahnout z cache, jinak nacist z DB
                mFinishedProductBO := nil;
                for j := 0 to mProducts.Count - 1 do begin
                  if (TNxCustomBusinessObject(mProducts.Items(j)).OID = mHead_ID) then begin
                    mFinishedProductBO := TNxCustomBusinessObject(mProducts.Items(j));
                  end;
                end;
                if (mFinishedProductBO = nil ) then begin
                  // nactu z DB a ulozim do cache
                  mFinishedProductBO := Self.ObjectSpace.CreateObject(Class_PLMFinishedProduct);
                  mFinishedProductBO.Load(mHead_ID, nil);
                  mProducts.Add(mFinishedProductBO);
                end;

                // naleznu radek FinishedProduct
                mFinishedProductRowBO := nil;
                mFinishedProductRows := mFinishedProductBO.GetLoadedCollectionMonikerForFieldCode(mFinishedProductBO.GetFieldCode('Rows'));
                for j := 0 to mFinishedProductRows.Count - 1 do begin
                  mFinishedProductRowBO := mFinishedProductRows.BusinessObject(j);
                  if (mFinishedProductRowBO.OID = mRow_ID) then begin
                    break;
                  end else
                    mFinishedProductRowBO := nil;
                end;

                if not Assigned(mFinishedProductRowBO) then // toto nesmi nikdy nastat, pokud nastane je chyba nekde ve vyhledani dokonceneho vyrobku
                  RaiseException(format('Nenalezen radek dokonceneho vyrobku (HeadID=%s, RowID=%s)!!', [mHead_ID, mRow_ID]));

                NxScriptingLog.WriteEventFmt(logDebug, 'Zpracovavam radek=%d FinishedMaterial s Quantity=%f', [i, mFinishedProductRowBO.GetFieldValueAsFloat('Quantity')]);
                if mQuantity > 0 then begin
                  mProductReceptionRowBO := mProductReceptionBO.Rows.AddNewObject;
                  mProductReceptionRowBO.SetFieldValueAsInteger('RowType', 3);
                  mProductReceptionRowBO.SetFieldValueAsString('Store_ID', mJobOrderBO.GetFieldValueAsString('Store_ID'));
                  mProductReceptionRowBO.SetFieldValueAsString('Division_ID', mJobOrderBO.GetFieldValueAsString('Division_ID'));
                  mProductReceptionRowBO.SetFieldValueAsString('StoreCard_ID', mJobOrderBO.GetFieldValueAsString('StoreCard_ID'));
                  mProductReceptionRowBO.SetFieldValueAsString('ProductionTask_ID', mJobOrderBO.GetFieldValueAsString('ProductionTask_ID'));
                  if not NxIsEmptyOID(mFinishedProductRowBO.GetFieldValueAsString('JobOrdersSN_ID')) then begin
                    mDocBatchBO := mProductReceptionRowBO.GetCollectionMonikerForFieldCode(mProductReceptionRowBO.GetFieldCode('DocRowBatches')).AddNewObject;
                    mDocBatchBO.SetFieldValueAsString('StoreBatch_ID', mFinishedProductRowBO.GetFieldValueAsString('JobOrdersSN_ID.StoreBatch_ID'));
                    mDocBatchBO.CopyFieldValueFrom(mFinishedProductRowBO, 'Quantity');
                    mDocBatchBO.CopyFieldValueFrom(mFinishedProductRowBO, 'QUnit');
                    mDocBatchBO.CopyFieldValueFrom(mFinishedProductRowBO, 'UnitRate');
                  end;
                  if mFinishedProductRowBO.GetFieldValueAsFloat('Quantity') = mQuantity then begin
                    mProductReceptionRowBO.SetFieldValueAsFloat('Quantity', mQuantity);
                    mProductReceptionRowBO.SetFieldValueAsFloat('AdditionalCosts_ID.OtherCostAmount',mQuantity*mJobOrderBO.GetFieldValueAsFloat('PriceForReceipt'));
                    mQuantity := mQuantity - mFinishedProductRowBO.GetFieldValueAsFloat('Quantity');
                    NxScriptingLog.WriteEventFmt(logDebug, '(if 1) Pocet na PHV bude %f, (Dokoncene vyrobky=%f, jeste chybjejici pocet=%f)',
                                                 [mProductReceptionRowBO.GetFieldValueAsFloat('Quantity'),
                                                  mFinishedProductRowBO.GetFieldValueAsFloat('Quantity'), mQuantity]);

                  end else if mFinishedProductRowBO.GetFieldValueAsFloat('Quantity') < mQuantity then begin
                    mProductReceptionRowBO.SetFieldValueAsFloat('Quantity', mFinishedProductRowBO.GetFieldValueAsFloat('Quantity'));
                    mProductReceptionRowBO.SetFieldValueAsFloat('AdditionalCosts_ID.OtherCostAmount', mFinishedProductRowBO.GetFieldValueAsFloat('Quantity')*mJobOrderBO.GetFieldValueAsFloat('PriceForReceipt'));
                    mQuantity := mQuantity - mFinishedProductRowBO.GetFieldValueAsFloat('Quantity');
                    NxScriptingLog.WriteEventFmt(logDebug, '(if 2) Pocet na PHV bude %f, (Dokoncene vyrobky=%f, jeste chybjejici pocet=%f)',
                                                 [mProductReceptionRowBO.GetFieldValueAsFloat('Quantity'),
                                                  mFinishedProductRowBO.GetFieldValueAsFloat('Quantity'), mQuantity]);

                  end else begin // mProduct.GetFieldValueAsFloat('Quantity') > mQuantity
                    mProductReceptionRowBO.SetFieldValueAsFloat('Quantity', mQuantity);
                    mProductReceptionRowBO.SetFieldValueAsFloat('AdditionalCosts_ID.OtherCostAmount',mQuantity*mJobOrderBO.GetFieldValueAsFloat('PriceForReceipt'));
                    NxScriptingLog.WriteEventFmt(logDebug, '(if 3) Pocet na PHV bude %f, (Dokoncene vyrobky=%f, jeste chybjejici pocet=%f)',
                                                 [mProductReceptionRowBO.GetFieldValueAsFloat('Quantity'),
                                                  mFinishedProductRowBO.GetFieldValueAsFloat('Quantity'), mQuantity]);
                    // vytvorim novy radek se zbyvajicim mnozstvim
                    //mNewProduct.New;
                    mNewProduct := mFinishedProductRows.AddNewObject;
                    mNewProduct.CopyFieldValueFrom(mFinishedProductRowBO, 'CheckedAt$DATE');
                    mNewProduct.CopyFieldValueFrom(mFinishedProductRowBO, 'CheckedBy_ID');
                    mNewProduct.CopyFieldValueFrom(mFinishedProductRowBO, 'ManufacturedItem_ID');
                    mNewProduct.CopyFieldValueFrom(mFinishedProductRowBO, 'UnitRate');
                    mNewProduct.CopyFieldValueFrom(mFinishedProductRowBO, 'ProductionDate$DATE');
                    mNewProduct.SetFieldValueAsFloat('Quantity', mFinishedProductRowBO.GetFieldValueAsFloat('Quantity')-mQuantity);
                    mNewProduct.CopyFieldValueFrom(mFinishedProductRowBO, 'Qunit');
                  end;
                  NxScriptingLog.WriteEvent(logDebug, 'doplnim vazby na radek PLMFinishedProduct');
                  mFinishedProductRowBO.SetFieldValueAsString('StoreDoc2_ID', mProductReceptionRowBO.OID);
                  mFinishedProductRowBO.SetFieldValueAsString('ReceivedBy_ID', NxGetActualUserID_1(mProductReceptionBO));
                  mFinishedProductRowBO.SetFieldValueAsDateTime('ReceivedAt$DATE', mProductReceptionBO.GetFieldValueAsDateTime('DocDate$DATE'));
                  mFinishedProductRowBO.SetFieldValueAsFloat('UnitQuantity', mProductReceptionRowBO.GetFieldValueAsFloat('Quantity'));
                  NxScriptingLog.WriteEvent(logDebug, 'konec doplneni');
                end;
              end;

              self.ObjectSpace.StartTransaction(taReadCommited);
              try
                NxScriptingLog.WriteEvent(logDebug, 'Transakce zahajena, ukladam..');
                mProductReceptionBO.save;
                NxScriptingLog.WriteEvent(logDebug, 'Transakce zahajena, ukladam.. po mProductReceptionBO.save');

                for i := 0 to mProducts.count - 1 do begin
                  NxScriptingLog.WriteEvent(logDebug, 'Product' + TNxCustomBusinessObject( mProducts.Items[i]).OID);
                  TNxCustomBusinessObject( mProducts.Items[i]).Save;
                end;

{                if Assigned(mNewProduct) then begin // verze 15.01, neni potreba resit, ulozim hlavicku FinishedProduct
                  NxScriptingLog.WriteEvent(logDebug, 'ukladam novy dokonceny vyrobek');
                  mNewProduct.save;
                end;
}
                NxScriptingLog.WriteEvent(logDebug, 'Transakce zahajena, bude commit...');
                self.ObjectSpace.Commit;
                NxScriptingLog.WriteEvent(logDebug, 'Transakce dokoncena, uraa!');
              except
                self.ObjectSpace.RollBack;
                NxScriptingLog.WriteEvent(logError, 'Rollback: ' + ExceptionMessage);
                RaiseException(ExceptionMessage);
              end;

              result := mProductReceptionBO.DisplayName;

              finally
                mProducts.Free;
              end;


            finally
              mProductReceptionBO.Free;
            end;
          finally
            mFinishedProductList.Free;
          end;


        finally
          mJobOrderBO.Free;
        end;
      finally
        mParams.Free;
      end;
    except
      Result := 'ERR|' + ExceptionMessage;
      NxScriptingLog.WriteEvent(logError, ExceptionMessage);
    end;
  finally
    NxScriptingLog.LeaveSection_1('eu.abra.Qx/templateImpl.ProductReceptionRowIns (%d ms)', [MilliSecondsBetween(now, T)], logNotice);
  end;
end;


function getProductReceptionDocQueue(AJobOrderBO : TNxCustomBusinessObject) : string;
const
  SQL = 'select Q.ID from StoresDocQueues A ' +
        '  JOIN DocQueues Q ON Q.ID=A.DocQueue_ID ' +
        '  WHERE Q.DocumentType=''28'' AND A.Store_ID=''%s''';
var
  L : TStringList;
begin
  L := TStringList.Create;
  try
    AJobOrderBO.ObjectSpace.SQLSelect( Format( SQL, [AJobOrderBO.GetFieldValueAsString('Store_ID')]), L);
    if L.Count > 0 then
      Result := L.Strings[0];
  finally
    L.Free;
  end;
end;




{
  Definuje webovou službu:
    string 	QPartialInvProtocolRowIns(TStringDynArray Params)
}
function PartialInvProtocolRowIns(Self: TNxWebServicesHelper;Params: TStringDynArray):String;

  function iGetOrCreateMainInvProtocolRow_ID(AOS : TNxCustomObjectSpace; AMainInvProtocol_ID : TNxOID; AStoreCard_ID : string;
                                             ACreateNew : Boolean) : TNxOID;
  const
    cSQL = 'SELECT B.ID FROM MainInvProtocolRows B ' +
           ' LEFT JOIN MainInvProtocols A ON A.ID=B.Parent_ID ' +
           ' WHERE A.ID=''%s'' AND B.StoreCard_ID=''%s'' ';
  var
    L : TStringList;
    mMainProtocolRowBO : TNxCustomBusinessObject;
  begin
    Result := '';
    L := TStringList.Create;
    try
      AOS.SQLSelect(format(cSQL, [AMainInvProtocol_ID, AStoreCard_ID]), L);
      if L.Count > 0 then begin
        Result := L.Strings[0];
        exit;
      end;
    finally
      L.Free;
    end;
    if ACreateNew then begin
      mMainProtocolRowBO := AOS.CreateObject(Class_MainInvProtocolRow);
      try
        mMainProtocolRowBO.New;
        mMainProtocolRowBO.SetFieldValueAsString('Parent_ID', AMainInvProtocol_ID);
        mMainProtocolRowBO.SetFieldValueAsString('StoreCard_ID', AStoreCard_ID);
        mMainProtocolRowBO.Save;
        Result := mMainProtocolRowBO.OID;
      finally
        mMainProtocolRowBO.Free;
      end;
    end;
  end;


var
  T : TDateTime;
  mParams : TStringList;
  i : integer;
  mPartialInvProtocol, mRowBO : TNxCustomBusinessObject;
  mMainInvProtocolRow_ID, mStoreCard_ID : string;
  mQuantity : double;
begin

  NxScriptingLog.EnterSection('eu.abra.Qx/templateImpl.PartialInvProtocolRowIns', logNotice);
  try
    T := now;
    try
      mParams := TStringList.Create;
      try
        for i := 0 to Length(Params) - 1 do
          mParams.Add(Params[i]);
        NxScriptingLog.WriteEventAndData_1(logDebug, 'Params', mParams.Text);

        mPartialInvProtocol := Self.ObjectSpace.CreateObject(Class_PartialInvProtocol);
        try
          mPartialInvProtocol.Load(mParams.Values['Parent_ID'], nil);
          mStoreCard_ID := mParams.Values['StoreCard_ID'];

          mMainInvProtocolRow_ID := iGetOrCreateMainInvProtocolRow_ID(Self.ObjectSpace, mPartialInvProtocol.GetFieldValueAsString('MainProtocol_ID'),
                                       mStoreCard_ID, mPartialInvProtocol.GetFieldValueAsBoolean('AddRows'));
          mQuantity := iFloat(mParams.Values['Quantity']);

          if mQuantity > 0 then begin
            mRowBO := mPartialInvProtocol.ObjectSpace.CreateObject(Class_PartialInvProtocolRow);
            mRowBO.New;
            mRowBO.Prefill;
            mRowBO.SetFieldValueAsString('Parent_ID', mPartialInvProtocol.OID);
            mRowBO.SetFieldValueAsString('MIPRow_ID', mMainInvProtocolRow_ID);
            mRowBO.SetFieldValueAsFloat('RealQuantity', mQuantity);
            //mRowBO.SetFieldValueAsString('qUnit', mQUnit);
            mRowBO.Save;
          end;
          Result := mPartialInvProtocol.DisplayName;
        finally
          mPartialInvProtocol.Free;
        end;
      finally
        mParams.Free;
      end;
    except
      Result := 'ERR|' + ExceptionMessage;
      NxScriptingLog.WriteEvent(logError, ExceptionMessage);
    end;
  finally
    NxScriptingLog.LeaveSection_1('eu.abra.Qx/templateImpl.PartialInvProtocolRowIns (%d ms)', [MilliSecondsBetween(now, T)], logNotice);
  end;
end;




{
  Definuje webovou službu:
    string 	QBillOfDeliveryIns(TStringDynArray Head, TStringDynArray RowDesc, TStringDynArray Rows)
}
function BillOfDeliveryInsert(Self: TNxWebServicesHelper;Head: TStringDynArray;RowDesc: TStringDynArray;Rows: TStringDynArray):String;

  function validateHead(AOS : TNxCustomObjectSpace; AHead : TStringList; var AErrMsg : string) : boolean;
  const
    resErrHeadFieldNotFound = 'Hlavička neobsahuje pole ''%s''';
    resErrHeadFieldNodValid = 'Pole %s neobsahuje validní hodnotu (%s)';
  var
    mS : string;
    mBO : TNxCustomBusinessObject;
  begin
    mS := AHead.Values('BillOfDeliveryDocQueue_ID');
    if NxIsBlank(mS) then begin
      AErrMsg := Format(resErrHeadFieldNotFound, ['BillOfDeliveryDocQueue_ID']);
      Result := false;
      exit;
    end;
    mBO := AOS.CreateObject(Class_DocQueue);
    try
      if not mBO.Test(mS) then begin
        AErrMsg := Format(resErrHeadFieldNodValid, ['BillOfDeliveryDocQueue_ID', mS]);
        result := false;
        exit;
      end;
    finally
      mBO.Free;
    end;
    mS := AHead.Values('VATDocumentType');
    if NxIsBlank(mS) then begin
      AErrMsg := Format(resErrHeadFieldNotFound, ['VATDocumentType']);
      Result := false;
      exit;
    end;
    if Pos(mS, 'NONE,IssuedInvoice,CashReceived') = 0 then begin
        AErrMsg := Format(resErrHeadFieldNodValid, ['VATDocumentType', mS]);
        result := false;
        exit;
    end;
    mS := AHead.Values('VATDocQueue_ID');
    if (upperCase(AHead.Values('VATDocumentType')) <> 'NONE') AND NxIsBlank(mS) then begin
      AErrMsg := Format(resErrHeadFieldNotFound, ['VATDocQueue_ID']);
      Result := false;
      exit;
    end;
    mS := AHead.Values('PrefillDivision_ID');
    if NxIsBlank(mS) then begin
      AErrMsg := Format(resErrHeadFieldNotFound, ['PrefillDivision_ID']);
      Result := false;
      exit;
    end;
    Result := True;
  end;

  function validateRowDesc(AOS : TNxCustomObjectSpace; ARowDesc : TStringList; var AErrMsg : string) : boolean;
  const
    resErrHeadFieldNotFound = 'Popisovač řádku neobsahuje pole ''%s''';
  var
    mS : string;
  begin
    if ARowDesc.IndexOf('ReceivedOrder_ID') < 0 then begin
      AErrMsg := Format(resErrHeadFieldNotFound, ['ReceivedOrder_ID']);
      Result := false;
      exit;
    end;
    if ARowDesc.IndexOf('ReceivedOrderRow_ID') < 0 then begin
      AErrMsg := Format(resErrHeadFieldNotFound, ['ReceivedOrderRow_ID']);
      Result := false;
      exit;
    end;
    if ARowDesc.IndexOf('StoreCard_ID') < 0 then begin
      AErrMsg := Format(resErrHeadFieldNotFound, ['StoreCard_ID']);
      Result := false;
      exit;
    end;

    if ARowDesc.IndexOf('QUnit') < 0 then begin
      AErrMsg := Format(resErrHeadFieldNotFound, ['QUnit']);
      Result := false;
      exit;
    end;
    if ARowDesc.IndexOf('UnitRate') < 0 then begin
      AErrMsg := Format(resErrHeadFieldNotFound, ['UnitRate']);
      Result := false;
      exit;
    end;
    if ARowDesc.IndexOf('UnitQuantity') < 0 then begin
      AErrMsg := Format(resErrHeadFieldNotFound, ['UnitQuantity']);
      Result := false;
      exit;
    end;
    Result := true;
  end;


var
  mHead, mRowDesc, mRowItem : TStringList;
  mRowsTxt : string;
  mRows : TList;
  i, j : integer;
  mErrMsg : string;
  mImportStatus : integer;
  mIsImported : boolean;
begin
  NxScriptingLog.EnterSection('BillOfDeliveryInsert', logNotice);
  try
    try
      mHead := TStringList.Create;
      try
        for i := 0 to Length(Head) - 1 do
          mHead.Add(Head[i]);
        NxScriptingLog.WriteEventAndData_1(logDebug, 'Head', mHead.Text);
        if not validateHead(Self.ObjectSpace, mHead, mErrMsg) then begin
          Result := 'ERR|' + mErrMsg;
          exit;
        end;
        mRowDesc := TStringList.Create;
        try
          for i := 0 to Length(RowDesc) - 1 do
            mRowDesc.add(RowDesc[i]);
          NxScriptingLog.WriteEventAndData_1(logDebug, 'RowDesc', mRowDesc.Text);
          if not validateRowDesc(Self.ObjectSpace, mRowDesc, mErrMsg) then begin
            Result := 'ERR|' + mErrMsg;
            exit;
          end;

          mRows := TObjectList.Create;
          try
            mRowsTxt := '';
            mIsImported := True;
            for i := 0 to Length(Rows) - 1 do begin
              if NxIsBlank(Rows[i]) then continue;
              mRowItem := TStringList.Create;
              NxTrapStrToStrings(Rows[i], '|', mRowItem);
              if mRowItem.Count > mRowDesc.Count then
                RaiseException(Format('Řádek ''%s'' má více položek, než určuje popisovač řádku.', [Rows[i]]));
              for j := 0 to mRowItem.Count - 1 do
                mRowItem.Strings[j] := mRowDesc.Strings[j] + '=' + mRowItem.Strings[j];
              for j := 0 to mRowItem.Count - 1 do
                mRowsTxt := mRowsTxt + mRowItem.Strings[j] + ';';
              mIsImported := mIsImported AND not NxIsEmptyOID(mRowItem.Values('ReceivedOrder_ID')) AND not NxIsEmptyOID(mRowItem.Values('ReceivedOrderRow_ID'));
              mRowsTxt := mRowsTxt +#13#10;
              mRows.Add(mRowItem);
            end;
            NxScriptingLog.WriteEventAndData_1(logDebug, 'Rows count:' + IntToStr(Length(Rows)), mRowsTxt);

            mImportStatus := 0; //vsechny radku musi byt
                                //  A) importovany z objednavky (1)
                                //  B) neimportovany z objednavky (2)
                                // (0) je vychozi kodnota nastavena bude na prvnim radku
            for i := 0 to mRows.count - 1 do begin
              if i = 0 then begin
                if NxIsEmptyOID(TStringList(mRows.Items[i]).Values('ReceivedOrderRow_ID')) then
                  mImportStatus := 2
                else
                  mImportStatus := 1;
              end else begin
                if (NxIsEmptyOID(TStringList(mRows.Items[i]).Values('ReceivedOrderRow_ID')) and (mImportStatus <> 2)) OR
                   (not NxIsEmptyOID(TStringList(mRows.Items[i]).Values('ReceivedOrderRow_ID')) and (mImportStatus <> 1)) then
                  RaiseException(Format('Řádek ''%s'' má rozdílné nastavení pole ''ReceivedOrderRow_ID'' než první řádek.', [IntToStr(i)]))
              end
            end;

            if Length(Rows) = 0 then
              RaiseException('Doklad není možné uložit, neobsahuje žádné řádky.');
            if mIsImported then
              Result := CreateBillOfDeliverdyFromOrders(Self.ObjectSpace, mHead, mRows)
            else
              Result := CreateBillOfDeliveryWithoutOrder(Self.ObjectSpace, mHead, mRows);

          finally
            mRows.Free;
          end;
        finally
          mRowDesc.Free;
        end;
      finally
        mHead.Free;
      end;
    except
      Result := 'ERR|' + ExceptionMessage;
      NxScriptingLog.WriteEvent(logError, ExceptionMessage);
    end;

  finally
    NxScriptingLog.LeaveSection('BillOfDeliveryInsert', logNotice);
  end;
end;


function CreateBillOfDeliverdyFromOrders(AOS : TNxCustomObjectSpace; AHead : TStringList; ARows : TList) : string;
  function getImportDocuments(ARows :TList ) : TstringList;
  var
    i : integer;
    s : string;
  begin
    Result := TStringList.Create;
    Result.sorted := true;
    for i := 0 to ARows.Count - 1 do begin
      s := TStringList(ARows.Items(i)).Values('ReceivedOrder_ID');
      if not NxIsBlank(s) then
        if Result.IndexOf(s)< 0 then
           Result.Add(s);
    end;
  end;
var
  mOID : TNxOID;
  mIM : TNxDocumentImportManager;
  mImportedRows, mS : string;
  i, j : integer;
  x : TNxParameters;
  mHead : TNxHeaderBusinessObject;
  mSList : TStringList;
  mVATDocQueue_ID, mCashDesk_ID : string;
  mr:tstringlist;
  mBO:TNxCustomBusinessObject;
  mPomocny_sklad:string;
  mDL_DocQueue_ID:string;
  mPRV_DocQueue_ID:string;
  mFV_DocQueue_ID:string;

begin
  mPomocny_sklad:='';
  mDL_DocQueue_ID:='';
  mPRV_DocQueue_ID:='';
  mFV_DocQueue_ID:='';
  result := '';
  NxScriptingLog.EnterSection('CreateBillOfDeliverdyFromOrders', logInfo);
  try
    if (AHead.Values('VATDocumentType')= 'IssuedInvoice') then
      mIM := NxCreateDocumentImportManager(AOS, Class_ReceivedOrder, Class_IssuedInvoice)
    else if (AHead.Values('VATDocumentType')= 'CashReceived') then
      mIM := NxCreateDocumentImportManager(AOS, Class_ReceivedOrder, Class_CashReceived)
    else begin
          // **************
          mSList := getImportDocuments(ARows);
            if mSList.count>0 then begin
                mbo:=AOS.CreateObject(Class_ReceivedOrder);
                try
                   mbo.load(mSList.Strings[0],nil);
                        if NxIsEmptyOID(mbo.GetFieldValueAsString('X_cilovy_sklad')) then begin
                           mIM := NxCreateDocumentImportManager(AOS, Class_ReceivedOrder, Class_BillOfDelivery);

                        end else begin
                           mPomocny_sklad:=mbo.GetFieldValueAsString('X_cilovy_sklad') ;
                           mIM := NxCreateDocumentImportManager(AOS, Class_ReceivedOrder, Class_OutgoingTransfer);
                        end;
                        if not NxIsEmptyOID(mbo.GetFieldValueAsString('Docqueue_ID.X_delivery_id')) then mDL_DocQueue_ID:= mbo.GetFieldValueAsString('Docqueue_ID.X_delivery_id');
                        if not NxIsEmptyOID(mbo.GetFieldValueAsString('Docqueue_ID.X_prevodka_id')) then mPRV_DocQueue_ID:= mbo.GetFieldValueAsString('Docqueue_ID.X_prevodka_id');
                        if not NxIsEmptyOID(mbo.GetFieldValueAsString('Docqueue_ID.X_issuedinvoice_ID')) then mFV_DocQueue_ID:= mbo.GetFieldValueAsString('Docqueue_ID.X_issuedinvoice_ID');

                finally
                    mbo.free;
                end;

                /// ************
            end;




         end;
    try
      mSList := getImportDocuments(ARows);
      try
        for i := 0 to mSList.Count - 1 do begin
          mIM.AddInputDocument(mSList.Strings[i]);
        end;
      finally
        mSList.Free;
      end;

      iGetDocumentVariable(AOS, AHead, mVATDocQueue_ID, mCashDesk_ID);

      x := TNxParameters.Create;
      try
        if (AHead.Values('VATDocumentType')= 'CashReceived') then begin
          NxScriptingLog.WriteEvent(logDebug, 'nastavuji pokladu ' + mCashDesk_ID );
          x.GetOrCreateParam(dtString, 'CashDesk_ID', pkInput).AsString := mCashDesk_ID;
        end;
        if (AHead.Values('VATDocumentType')= 'IssuedInvoice') or (AHead.Values('VATDocumentType') = 'CashReceived') then begin
    // *************************************
          if mFV_DocQueue_ID<>'' then x.GetOrCreateParam(dtString, 'DocQueue_ID', pkInput).AsString := mFV_DocQueue_ID else x.GetOrCreateParam(dtString, 'DocQueue_ID', pkInput).AsString := mVATDocQueue_ID;

          if mDL_DocQueue_ID<>'' then x.GetOrCreateParam(dtString, 'StoreDocQueue_ID', pkInput).AsString := mDL_DocQueue_ID else x.GetOrCreateParam(dtString, 'StoreDocQueue_ID', pkInput).AsString := AHead.Values('BillOfDeliveryDocQueue_ID');
        end else
           if mPomocny_sklad='' then begin
               if mDL_DocQueue_ID<>''then  x.GetOrCreateParam(dtString, 'DocQueue_ID', pkInput).AsString := mDL_DocQueue_ID else x.GetOrCreateParam(dtString, 'DocQueue_ID', pkInput).AsString := AHead.Values('BillOfDeliveryDocQueue_ID');
           end else begin

               if mPRV_DocQueue_ID<>''then  x.GetOrCreateParam(dtString, 'DocQueue_ID', pkInput).AsString := mPRV_DocQueue_ID else x.GetOrCreateParam(dtString, 'DocQueue_ID', pkInput).AsString := AHead.Values('BillOfDeliveryDocQueue_ID');
           end;

     // ***************************************
        mImportedRows := '';
        for i := 0 to ARows.Count - 1 do
          mImportedRows := NxIIfStr(NxIsBlank(mImportedRows), '', mImportedRows+#13#10) + TStringList(ARows.Items[i]).Values('ReceivedOrderRow_ID');
        NxScriptingLog.WriteEvent(logDebug, 'SelectedRows=' + mImportedRows);
        x.GetOrCreateParam(dtString, 'SelectedRows', pkInput).AsString := mImportedRows;
        mIM.LoadParams(x);
      finally
        x.Free;
      end;
      mIM.SelectedHeader := mIM.InputDocuments[0];
      mIM.Execute;

      mHead := TNxHeaderBusinessObject(mIM.OutputDocument);

      if (AHead.Values('VATDocumentType')= 'CashReceived') then begin
        mHead.SetFieldValueAsString('CashDesk_ID', mCashDesk_ID);
        mHead.SetFieldValueAsString('DocQueue_ID', mVATDocQueue_ID);
      end;

      if (AHead.Values('VATDocumentType')= 'IssuedInvoice') or (AHead.Values('VATDocumentType') = 'CashReceived') then begin
        //NxScriptingLog.WriteEventFmt(logDebug, 'Nastavení řady skladových dokladů - %s', [AHead.Values('BillOfDeliveryDocQueue_ID')]);
        mHead.SetFieldValueAsString('StoreDocQueue_ID', AHead.Values('BillOfDeliveryDocQueue_ID'));
      end;

      if mPomocny_sklad<>'' then begin
          mHead.SetFieldValueAsString('IncomingTransferStore',mPomocny_sklad);

      end;
      if not NxIsEmptyOID(AHead.Values('CreatedBy_ID')) then
        mHead.SetFieldValueAsString('CreatedBy_ID', AHead.Values('CreatedBy_ID'));

      for i := 0 to mHead.Rows.Count - 1 do begin
        mOID := mHead.Rows.BusinessObject[i].GetFieldValueAsString('ProvideRow_ID');
        for j := 0 to ARows.Count - 1 do
          if mOID = TStringList(ARows.Items(j)).Values('ReceivedOrderRow_ID') then begin
            mHead.Rows.BusinessObject[i].SetFieldValueAsFloat('UnitQuantity', iFloat(TStringList(ARows.Items(j)).Values('UnitQuantity')));
            mHead.Rows.BusinessObject[i].SetFieldValueAsString('QUnit', TStringList(ARows.Items(j)).Values('Qunit'));
//            mHead.Rows.BusinessObject[i].SetFieldValueAsFloat('UnitRate', iFloat(TStringList(ARows.Items(j)).Values('UnitRate')));
//            mHead.Rows.BusinessObject[i].SetFieldValueAsFloat('UnitPrice', iFloat(TStringList(ARows.Items(j)).Values('UnitPrice')));
//            mHead.Rows.BusinessObject[i].SetFieldValueAsFloat('TotalPrice', iFloat(TStringList(ARows.Items(j)).Values('TotalPrice')));
            if (not NxIsEmptyOID(TStringList(ARows.Items(j)).Values('Division_ID'))) then
              mHead.Rows.BusinessObject[i].SetFieldValueAsString('Division_ID', '1N00000101');
            //if (not NxIsEmptyOID(TStringList(ARows.Items(j)).Values('BusOrder_ID'))) then
            //  mHead.Rows.BusinessObject[i].SetFieldValueAsString('BusOrder_ID', TStringList(ARows.Items(j)).Values('BusOrder_ID'));
            //if (not NxIsEmptyOID(TStringList(ARows.Items(j)).Values('BusTransaction_ID'))) then
            //  mHead.Rows.BusinessObject[i].SetFieldValueAsString('BusTransaction_ID', TStringList(ARows.Items(j)).Values('BusTransaction_ID'));
            //if (not NxIsEmptyOID(TStringList(ARows.Items(j)).Values('BusProject_ID'))) then
            //  mHead.Rows.BusinessObject[i].SetFieldValueAsString('BusProject_ID', TStringList(ARows.Items(j)).Values('BusProject_ID'));
//            if (not NxIsEmptyOID(TStringList(ARows.Items(j)).Values('Store_ID'))) then
//              mHead.Rows.BusinessObject[i].SetFieldValueAsString('Store_ID', TStringList(ARows.Items(j)).Values('Store_ID'));
            fillRowValues(mHead.Rows.BusinessObject[i], TStringList(ARows.Items(j)));
          end;
      end;
      mHead.Save;
      NxScriptingLog.WriteEventFmt(logDebug, 'Doklad uložen pod číslem "%s(%s)', [mHead.DisplayName, mHead.OID]);

      Result := 'Description=' + mHead.DisplayName + #13#10 + 'ID=' + mHead.OID + #13#10 +
                'DocumentType=' + mHead.GetMonikerForFieldCode(mHead.GetFieldCode('DocQueue_ID')).BusinessObject.GetFieldValueAsString('DocumentType');
    finally
      mIM.Free;
    end;
  finally
    NxScriptingLog.LeaveSection('CreateBillOfDeliverdyFromOrders', logInfo);
  end;
end;


procedure iGetDocumentVariable(AOS : TNxCustomObjectSpace; AHead : TStringList;
                                var AVATDocQueue_ID : string; var ACashDesk_ID : string);
var
  mUserBO : TNxCustomBusinessObject;
begin
  if not NxIsEmptyOID(AHead.Values('CreatedBy_ID')) then
    mUserBO := iGetSecurityUser(AOS, AHead.Values('CreatedBy_ID'))
  else
    mUserBO := nil;
  try
    if (AHead.Values('VATDocumentType')= 'IssuedInvoice') then begin
      if Assigned(mUserBO) then begin
        AVATDocQueue_ID := mUserBO.GetFieldValueAsString('U_DocQueue03_ID');
      end;
      if NxIsEmptyOID(AVATDocQueue_ID) then
        AVATDocQueue_ID := AHead.Values('VATDocQueue_ID');
    end else if (AHead.Values('VATDocumentType')= 'CashReceived') then begin
      if Assigned(mUserBO) then begin
        AVATDocQueue_ID := mUserBO.GetFieldValueAsString('U_DocQueue05_ID');
        ACashDesk_ID :=  mUserBO.GetFieldValueAsString('U_CashDesk_ID');
      end;
      if NxIsEmptyOID(AVATDocQueue_ID) then
        AVATDocQueue_ID := AHead.Values('VATDocQueue_ID');
      if NxIsEmptyOID(ACashDesk_ID) then
        ACashDesk_ID := AHead.Values('CashDesk_ID');
    end
  finally
    if Assigned(mUserBO) then
      mUserBO.Free;
    mUserBO := nil;
  end;
end;


function CreateBillOfDeliveryWithoutOrder(AOS : TNxCustomObjectSpace; AHead : TStringList; ARows : TList) : string;
var
  mOID : TNxOID;
  mS : string;
  i, j : integer;
  mHead : TNxHeaderBusinessObject;
  mRow : TNxCustomBusinessObject;
  mSList : TStringList;
  mVATDocQueue_ID, mCashDesk_ID : string;
begin
  result := '';
  NxScriptingLog.EnterSection('CreateBillOfDeliveryWithoutOrder', logInfo);
  try
    if (AHead.Values('VATDocumentType')= 'IssuedInvoice') then begin
      mHead := TNxHeaderBusinessObject(AOS.CreateObject(Class_IssuedInvoice));
    end else if (AHead.Values('VATDocumentType')= 'CashReceived') then begin
      mHead := TNxHeaderBusinessObject(AOS.CreateObject(Class_CashReceived));
    end else
      mHead := TNxHeaderBusinessObject(AOS.CreateObject(Class_BillOfDelivery));

    iGetDocumentVariable(AOS, AHead, mVATDocQueue_ID, mCashDesk_ID);
    try
      mHead.New;
      mHead.Prefill;
      if (AHead.Values('VATDocumentType')= 'CashReceived') then
        mHead.SetFieldValueAsString('CashDesk_ID', mCashDesk_ID);
      if (AHead.Values('VATDocumentType')= 'IssuedInvoice') or (AHead.Values('VATDocumentType')= 'CashReceived') then begin
        mHead.SetFieldValueAsString('DocQueue_ID', mVATDocQueue_ID);
        mHead.SetFieldValueAsString('StoreDocQueue_ID', AHead.Values('BillOfDeliveryDocQueue_ID'));
      end else
        mHead.SetFieldValueAsString('DocQueue_ID', AHead.Values('BillOfDeliveryDocQueue_ID'));

      mHead.SetFieldValueAsString('Firm_ID', AHead.Values('Firm_ID'));
      if not NxIsEmptyOID(AHead.Values('CreatedBy_ID')) then
        mHead.SetFieldValueAsString('CreatedBy_ID', AHead.Values('CreatedBy_ID'));

      for j := 0 to ARows.Count - 1 do begin
        mRow := mHead.Rows.AddNewObject;
        mRow.SetFieldValueAsInteger('RowType', 3);
        mRow.SetFieldValueAsString('Store_ID', TStringList(ARows.Items(j)).Values('Store_ID'));
        mRow.SetFieldValueAsString('StoreCard_ID', TStringList(ARows.Items(j)).Values('StoreCard_ID'));
        mRow.SetFieldValueAsFloat('UnitQuantity', iFloat(TStringList(ARows.Items(j)).Values('UnitQuantity')));
        mRow.SetFieldValueAsString('QUnit', TStringList(ARows.Items(j)).Values('Qunit'));
        mRow.SetFieldValueAsFloat('UnitRate', iFloat(TStringList(ARows.Items(j)).Values('UnitRate')));
//        mRow.SetFieldValueAsFloat('UnitPrice', iFloat(TStringList(ARows.Items(j)).Values('UnitPrice')));
//        mRow.SetFieldValueAsFloat('TotalPrice', iFloat(TStringList(ARows.Items(j)).Values('TotalPrice')));
        mRow.SetFieldValueAsString('Division_ID', AHead.Values('PrefillDivision_ID'));
        if (not NxIsEmptyOID(TStringList(ARows.Items(j)).Values('Division_ID'))) then
          mHead.Rows.BusinessObject[i].SetFieldValueAsString('Division_ID', TStringList(ARows.Items(j)).Values('Division_ID'));
        if (not NxIsEmptyOID(TStringList(ARows.Items(j)).Values('BusOrder_ID'))) then
          mRow.SetFieldValueAsString('BusOrder_ID', TStringList(ARows.Items(j)).Values('BusOrder_ID'));
        if (not NxIsEmptyOID(TStringList(ARows.Items(j)).Values('BusTransaction_ID'))) then
          mRow.SetFieldValueAsString('BusTransaction_ID', TStringList(ARows.Items(j)).Values('BusTransaction_ID'));
        if (not NxIsEmptyOID(TStringList(ARows.Items(j)).Values('BusProject_ID'))) then
          mRow.SetFieldValueAsString('BusProject_ID', TStringList(ARows.Items(j)).Values('BusProject_ID'));
        if (not NxIsEmptyOID(TStringList(ARows.Items(j)).Values('Store_ID'))) then
          mRow.SetFieldValueAsString('Store_ID', TStringList(ARows.Items(j)).Values('Store_ID'));
        fillRowValues(mRow, TStringList(ARows.Items(j)));
      end;
      mHead.Save;
      Result := 'Description=' + mHead.DisplayName + #13#10 + 'ID=' + mHead.OID + #13#10 +
                'DocumentType=' + mHead.GetMonikerForFieldCode(mHead.GetFieldCode('DocQueue_ID')).BusinessObject.GetFieldValueAsString('DocumentType');
      NxScriptingLog.WriteEventFmt(logDebug, 'Doklad uložen pod číslem "%s(%s)', [mHead.DisplayName, mHead.OID]);
    finally
      mHead.Free;
    end;
  finally
    NxScriptingLog.LeaveSection('CreateBillOfDeliveryWithoutOrder', logInfo);
  end;
end;










{
  Definuje webovou službu:
    string 	QReceiptCardIns(TStringDynArray Head, TStringDynArray RowDesc, TStringDynArray Rows)
}
function ReceiptCardInsert(Self: TNxWebServicesHelper;Head: TStringDynArray;RowDesc: TStringDynArray;Rows: TStringDynArray):String;

  function validateHead(AOS : TNxCustomObjectSpace; AHead : TStringList; var AErrMsg : string) : boolean;
  const
    resErrHeadFieldNotFound = 'Hlavička neobsahuje pole ''%s''';
    resErrHeadFieldNodValid = 'Pole %s neobsahuje validní hodnotu (%s)';
  var
    mS : string;
    mBO : TNxCustomBusinessObject;
  begin
    mS := AHead.Values('ReceiptCardDocQueue_ID');
    if NxIsBlank(mS) then begin
      AErrMsg := Format(resErrHeadFieldNotFound, ['ReceiptCardDocQueue_ID']);
      Result := false;
      exit;
    end;
    mBO := AOS.CreateObject(Class_DocQueue);
    try
      if not mBO.Test(mS) then begin
        AErrMsg := Format(resErrHeadFieldNodValid, ['ReceiptCardDocQueue_ID', mS]);
        result := false;
        exit;
      end;
    finally
      mBO.Free;
    end;
    Result := True;
  end;


  function validateRowDesc(AOS : TNxCustomObjectSpace; ARowDesc : TStringList; var AErrMsg : string) : boolean;
  const
    resErrHeadFieldNotFound = 'Popisovač řádku neobsahuje pole ''%s''';
  var
    mS : string;
  begin
    if ARowDesc.IndexOf('IssuedOrder_ID') < 0 then begin
      AErrMsg := Format(resErrHeadFieldNotFound, ['IssuedOrder_ID']);
      Result := false;
      exit;
    end;
    if ARowDesc.IndexOf('IssuedOrderRow_ID') < 0 then begin
      AErrMsg := Format(resErrHeadFieldNotFound, ['IssuedOrderRow_ID']);
      Result := false;
      exit;
    end;
    if ARowDesc.IndexOf('QUnit') < 0 then begin
      AErrMsg := Format(resErrHeadFieldNotFound, ['QUnit']);
      Result := false;
      exit;
    end;
    if ARowDesc.IndexOf('UnitRate') < 0 then begin
      AErrMsg := Format(resErrHeadFieldNotFound, ['UnitRate']);
      Result := false;
      exit;
    end;
    if ARowDesc.IndexOf('UnitQuantity') < 0 then begin
      AErrMsg := Format(resErrHeadFieldNotFound, ['UnitQuantity']);
      Result := false;
      exit;
    end;
    Result := true;
  end;

var
  mHead, mRowDesc, mRowItem : TStringList;
  mRowsTxt : string;
  mRows : TList;
  i, j : integer;
  mErrMsg : string;
  mImportStatus : integer;
  mIsImported : boolean;
begin
  NxScriptingLog.EnterSection('ReceiptCardInsert', logNotice);
  try
    try
      mHead := TStringList.Create;
      try
        for i := 0 to Length(Head) - 1 do
          mHead.Add(Head[i]);

        for i := 0 to mHead.Count - 1 do
          NxScriptingLog.WriteEvent(logDebug, 'mHead.row=' + mHead.Strings[i] );
        //NxScriptingLog.WriteEventAndData_1(logDebug, 'Head', mHead.CommaText);

        if not validateHead(Self.ObjectSpace, mHead, mErrMsg) then begin
          Result := 'ERR|' + mErrMsg;
          exit;
        end;
        mRowDesc := TStringList.Create;
        try
          for i := 0 to Length(RowDesc) - 1 do
            mRowDesc.add(RowDesc[i]);

          for i := 0 to mRowDesc.Count - 1 do
            NxScriptingLog.WriteEvent(logDebug, 'mRowDesc.row=' + mRowDesc.Strings[i] );
          //NxScriptingLog.WriteEventAndData_1(logDebug, 'RowDesc', mRowDesc.CommaText);

          if not validateRowDesc(Self.ObjectSpace, mRowDesc, mErrMsg) then begin
            Result := 'ERR|' + mErrMsg;
            exit;
          end;

          mRows := TObjectList.Create;
          try
            mRowsTxt := '';
            mIsImported := False;
            for i := 0 to Length(Rows) - 1 do begin
              if NxIsBlank(Rows[i]) then continue;
              mRowItem := TStringList.Create;
              NxTrapStrToStrings(Rows[i], '|', mRowItem);
              if mRowItem.Count > mRowDesc.Count then
                RaiseException(Format('Řádek ''%s'' má více položek, než určuje popisvač řádku.', [Rows[i]]));
              for j := 0 to mRowItem.Count - 1 do
                mRowItem.Strings[j] := mRowDesc.Strings[j] + '=' + mRowItem.Strings[j];
              for j := 0 to mRowItem.Count - 1 do
                mRowsTxt := mRowsTxt + mRowItem.Strings[j] + ';';
              mRowsTxt := mRowsTxt +#13#10;
              mIsImported := mIsImported OR (not NxIsEmptyOID(mRowItem.Values('IssuedOrder_ID')) AND not NxIsEmptyOID(mRowItem.Values('IssuedOrderRow_ID')));
              mRows.Add(mRowItem);
            end;
            NxScriptingLog.WriteEventAndData_1(logDebug, 'Rows count:' + IntToStr(Length(Rows)), mRowsTxt);

            if Length(Rows) = 0 then
              RaiseException('Doklad není možné uložit, neobsahuje žádné řádky.');

            if mIsImported then
              Result := CreateReceiptCardFromOrders(Self.ObjectSpace, mHead, mRows)
            else
              Result := CreateReceiptCardWithoutOrders(Self.ObjectSpace, mHead, mRows);

          finally
            mRows.Free;
          end;
        finally
          mRowDesc.Free;
        end;
      finally
        mHead.Free;
      end;
    except
      Result := 'ERR|' + ExceptionMessage;
      NxScriptingLog.WriteEvent(logError, ExceptionMessage);
    end;
  finally
    NxScriptingLog.LeaveSection('ReceiptCardInsert', logNotice);
  end;
end;

function CreateReceiptCardWithoutOrders(AOS : TNxCustomObjectSpace; AHead : TStringList; ARows : TList) : string;
var
  mOID : TNxOID;
  mS : string;
  j : integer;
  mHead : TNxHeaderBusinessObject;

  mSList : TStringList;
  mVATDocQueue_ID, mCashDesk_ID : string;
begin
  result := '';
  NxScriptingLog.EnterSection('CreateReceiptCardWithoutOrders', logInfo);
  try
    mHead := TNxHeaderBusinessObject(AOS.CreateObject(Class_ReceiptCard));

    try
      mHead.New;
      mHead.Prefill;
      mHead.SetFieldValueAsString('DocQueue_ID', AHead.Values('ReceiptCardDocQueue_ID'));

      mHead.SetFieldValueAsString('Firm_ID', AHead.Values('Firm_ID'));
      if not NxIsEmptyOID(AHead.Values('CreatedBy_ID')) then
        mHead.SetFieldValueAsString('CreatedBy_ID', AHead.Values('CreatedBy_ID'));

      for j := 0 to ARows.Count - 1 do begin
         ReceiptCardAppendNewRow(mHead, AHead, TStringList(ARows.Items(j)));
      end;
      mHead.Save;
      Result := 'Description=' + mHead.DisplayName + #13#10 + 'ID=' + mHead.OID + #13#10 +
                'DocumentType=' + mHead.GetMonikerForFieldCode(mHead.GetFieldCode('DocQueue_ID')).BusinessObject.GetFieldValueAsString('DocumentType');
      NxScriptingLog.WriteEventFmt(logDebug, 'Doklad uložen pod číslem "%s(%s)', [mHead.DisplayName, mHead.OID]);
    finally
      mHead.Free;
    end;
  finally
    NxScriptingLog.LeaveSection('CreateReceiptCardWithoutOrders', logInfo);
  end;
end;

procedure ReceiptCardAppendNewRow(AHeadBO : TNxHeaderBusinessObject; AHeadRowData : TStringList; ARowRawData : TStringList);
var
  mRow : TNxCustomBusinessObject;
begin
  mRow := AHeadBO.Rows.AddNewObject;
  mRow.SetFieldValueAsInteger('RowType', 3);
  mRow.SetFieldValueAsString('Store_ID', ARowRawData.Values('Store_ID'));
  mRow.SetFieldValueAsString('StoreCard_ID', ARowRawData.Values('StoreCard_ID'));
  mRow.SetFieldValueAsFloat('UnitQuantity', iFloat(ARowRawData.Values('UnitQuantity')));
  mRow.SetFieldValueAsString('QUnit', ARowRawData.Values('Qunit'));
  mRow.SetFieldValueAsFloat('UnitRate', iFloat(ARowRawData.Values('UnitRate')));
  //        mRow.SetFieldValueAsFloat('UnitPrice', iFloat(TStringList(ARows.Items(j)).Values('UnitPrice')));
  //        mRow.SetFieldValueAsFloat('TotalPrice', iFloat(TStringList(ARows.Items(j)).Values('TotalPrice')));
  mRow.SetFieldValueAsString('Division_ID', AHeadRowData.Values('PrefillDivision_ID'));
  if (not NxIsEmptyOID(ARowRawData.Values('Division_ID'))) then
    mRow.SetFieldValueAsString('Division_ID', ARowRawData.Values('Division_ID'));
  if (not NxIsEmptyOID(ARowRawData.Values('BusOrder_ID'))) then
    mRow.SetFieldValueAsString('BusOrder_ID', ARowRawData.Values('BusOrder_ID'));
  if (not NxIsEmptyOID(ARowRawData.Values('BusTransaction_ID'))) then
    mRow.SetFieldValueAsString('BusTransaction_ID', ARowRawData.Values('BusTransaction_ID'));
  if (not NxIsEmptyOID(ARowRawData.Values('BusProject_ID'))) then
    mRow.SetFieldValueAsString('BusProject_ID', ARowRawData.Values('BusProject_ID'));
  if (not NxIsEmptyOID(ARowRawData.Values('Store_ID'))) then
    mRow.SetFieldValueAsString('Store_ID', ARowRawData.Values('Store_ID'));
  fillRowValues(mRow, ARowRawData);
end;


function CreateReceiptCardFromOrders(AOS : TNxCustomObjectSpace; AHead : TStringList; ARows : TList) : string;
  function getImportDocuments(ARows :TList ) : TstringList;
  var
    i : integer;
    s : string;
  begin
    Result := TStringList.Create;
    Result.sorted := true;
    for i := 0 to ARows.Count - 1 do begin
      s := TStringList(ARows.Items(i)).Values('IssuedOrder_ID');
      if not NxIsBlank(s) then
        if Result.IndexOf(s)< 0 then
           Result.Add(s);
    end;
  end;

var
  mOID : TNxOID;
  mIM : TNxDocumentImportManager;
  mImportedRows, mS : string;
  i, j : integer;
  x : TNxParameters;
  mHead : TNxHeaderBusinessObject;
  mSList : TStringList;
begin
  result := '';
  NxScriptingLog.EnterSection('CreateReceiptCardFromOrders', logInfo);
  try
    mIM := NxCreateDocumentImportManager(AOS, Class_IssuedOrder, Class_ReceiptCard);
    try
      mSList := getImportDocuments(ARows);
      try
        for i := 0 to mSList.Count - 1 do begin
          mIM.AddInputDocument(mSList.Strings[i]);
        end;
      finally
        mSList.Free;
      end;

      x := TNxParameters.Create;
      try
        x.GetOrCreateParam(dtString, 'DocQueue_ID', pkInput).AsString := AHead.Values('ReceiptCardDocQueue_ID');
        x.GetOrCreateParam(dtInteger, 'StoreQuantityKind', pkInput).AsInteger := 0;
        mImportedRows := '';
        for i := 0 to ARows.Count - 1 do
          if not NxIsEmptyOID( TStringList(ARows.Items[i]).Values('IssuedOrderRow_ID') ) then
            mImportedRows := NxIIfStr(NxIsBlank(mImportedRows), '', mImportedRows+#13#10) + TStringList(ARows.Items[i]).Values('IssuedOrderRow_ID');
        NxScriptingLog.WriteEvent(logDebug, 'SelectedRows=' + mImportedRows);
        x.GetOrCreateParam(dtString, 'SelectedRows', pkInput).AsString := mImportedRows;
        mIM.LoadParams(x);
//        mIM.SaveParams(x);
//        x.SaveToFile('c:\im_params.dat');
      finally
        x.Free;
      end;
      mIM.SelectedHeader := mIM.InputDocuments[0];
      mIM.Execute;
      mHead := TNxHeaderBusinessObject(mIM.OutputDocument);

//      mHead.SetFieldValueAsString('Firm_ID', mIM.InputDocuments[0].GetFieldValueAsString('Firm_ID'));
      // opravim radky pochazejici z objednavky
      for i := 0 to mHead.Rows.Count - 1 do begin
        mOID := mHead.Rows.BusinessObject[i].GetFieldValueAsString('ProvideRow_ID');
        for j := 0 to ARows.Count - 1 do
          if mOID = TStringList(ARows.Items(j)).Values('IssuedOrderRow_ID') then begin
            mHead.Rows.BusinessObject[i].SetFieldValueAsFloat('UnitQuantity', iFloat(TStringList(ARows.Items(j)).Values('UnitQuantity')));
            mHead.Rows.BusinessObject[i].SetFieldValueAsString('QUnit', TStringList(ARows.Items(j)).Values('Qunit'));
            mHead.Rows.BusinessObject[i].SetFieldValueAsFloat('UnitRate', iFloat(TStringList(ARows.Items(j)).Values('UnitRate')));
            //mHead.Rows.BusinessObject[i].SetFieldValueAsFloat('UnitPrice', iFloat(TStringList(ARows.Items(j)).Values('UnitPrice')));
            //mHead.Rows.BusinessObject[i].SetFieldValueAsFloat('TotalPrice', iFloat(TStringList(ARows.Items(j)).Values('TotalPrice')));
            if (not NxIsEmptyOID(TStringList(ARows.Items(j)).Values('Division_ID'))) then
              mHead.Rows.BusinessObject[i].SetFieldValueAsString('Division_ID', TStringList(ARows.Items(j)).Values('Division_ID'));
            if (not NxIsEmptyOID(TStringList(ARows.Items(j)).Values('BusOrder_ID'))) then
              mHead.Rows.BusinessObject[i].SetFieldValueAsString('BusOrder_ID', TStringList(ARows.Items(j)).Values('BusOrder_ID'));
            if (not NxIsEmptyOID(TStringList(ARows.Items(j)).Values('BusTransaction_ID'))) then
              mHead.Rows.BusinessObject[i].SetFieldValueAsString('BusTransaction_ID', TStringList(ARows.Items(j)).Values('BusTransaction_ID'));
            if (not NxIsEmptyOID(TStringList(ARows.Items(j)).Values('BusProject_ID'))) then
              mHead.Rows.BusinessObject[i].SetFieldValueAsString('BusProject_ID', TStringList(ARows.Items(j)).Values('BusProject_ID'));
            if (not NxIsEmptyOID(TStringList(ARows.Items(j)).Values('Store_ID'))) then
              mHead.Rows.BusinessObject[i].SetFieldValueAsString('Store_ID', TStringList(ARows.Items(j)).Values('Store_ID'));
          end;
      end;

      // doplnim radky bez objednavek
      for i := 0 to ARows.Count - 1 do
        if NxIsEmptyOID( TStringList(ARows.Items[i]).Values('IssuedOrderRow_ID') ) then begin
          ReceiptCardAppendNewRow(mHead, AHead, TStringList(ARows.Items(j)));
        end;
      mHead.Save;
      Result := 'Description=' + mHead.DisplayName + #13#10 + 'ID=' + mHead.OID + #13#10 +
                'DocumentType=' + mHead.GetMonikerForFieldCode(mHead.GetFieldCode('DocQueue_ID')).BusinessObject.GetFieldValueAsString('DocumentType');
      NxScriptingLog.WriteEventFmt(logDebug, 'Doklad uložen pod číslem "%s(%s)', [mHead.DisplayName, mHead.OID]);

    finally
      mIM.Free;
    end;
  finally
    NxScriptingLog.LeaveSection('CreateReceiptCardFromOrders', logInfo);
  end;
end;






function iFloat(AValue : string) : double;
var
  mS : string;
begin
  mS := '0' + Trim(AValue);
  mS := NxSearchReplace(mS, ',', '.', [srAll]);
 Result := NxIBStrToFloat(mS);
end;

function iGetSecurityUser(AOS : TNxCustomObjectSpace; AOID : string) : TNxCustomBusinessObject;
begin
  Result := AOS.CreateObject(Class_SecurityUser);
  if Result.Test(AOID) then
    Result.Load(AOID, nil)
  else
    Result := nil;
end;



function SearchFinishRoutine_ID(AOS: TNxCustomObjectSpace; AManufacturedItem_ID : string) : TNxOID;
const
  SQL = 'SELECT A.ID FROM PLMJobOrdersRoutines A WHERE A.Parent_ID=''%s'' AND A.Finished=''A''';
var
  L : TStringList;
begin
  NxScriptingLog.EnterSection('eu.abra.Qx/templateImpl.SearchFinishRoutine_ID', logDebug);
  try
    Result := '';
    L := TStringList.Create;
    try
      AOS.SQLSelect(Format(SQL, [AManufacturedItem_ID]), L);
      if (L.Count = 1) then begin
        Result := L.Strings[0];
      end;
    finally
      L.Free;
    end;
  finally
    NxScriptingLog.LeaveSection('eu.abra.Qx/templateImpl.SearchFinishRoutine_ID', logDebug);
  end;
end;



{
  ***************  fillRowValues  ***************
}
procedure fillRowValues(ABO : TNxCustomBusinessObject; AValues : TStringList);
  function isForbiden(AFieldName : string) : boolean;
  const
    forbidenFields = ['RowType', 'Store_ID', 'StoreCard_ID', 'UnitQuantity', 'QUnit', 'UnitRate', 'Division_ID', 'BusOrder_ID', 'BusTransaction_ID', 'BusProject_ID'];
  var
    i : integer;
  begin
    for i := 0 to Length(forbidenFields) - 1 do begin
      if AnsiCompareStr(AFieldName, forbidenFields[i]) = 0 then begin
        result := true;
        exit;
      end;
    end;
    result := false;
  end;
var
  i : integer;
begin
  for i := 0 to AValues.Count - 1 do begin
    if not isForbiden(AValues.Names[i]) then begin
      if ABO.GetFieldCode(AValues.Names[i]) > 0 then
        ABO.SetFieldValueAsString(AValues.Names[i], AValues.Values[AValues.Names[i]]);
    end;
  end;
end;
{
  ***************  END fillRowValues  ***************
}




begin
end.