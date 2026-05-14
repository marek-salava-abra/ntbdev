uses 'eu.abra.roeh.Logio.Requests',
      'eu.abra.roeh.SunnexSklOpt.QRFunc';

function GetCreateIssuedOrdersSannex(aBOSubCard:TNxCustomBusinessObject):Boolean;
var
  Str : TStringList;
  mMin,mQuant: Extended;
  mSQL : string;
begin
  Result := true;
{  mMin := aBOSubCard.GetFieldValueAsFloat('X_Min') + aBOSubCard.GetFieldValueAsFloat('X_KorekceMin');
//  mQuant := aBOSubCard.GetFieldValueAsFloat('Quantity');
 // mQuant := mQuant + IntOrdersSubCardSunnex(aBOSubCard.ObjectSpace,aBOSubCard.GetFieldValueAsString('ID'));
 // mQuant := mQuant - IntForecastSunnex(aBOSubCard.ObjectSpace,aBOSubCard.GetFieldValueAsString('ID'));

 // Result := mMin >= mQuant;
 Result := mMin <= GetClearQuantitySunnex(aBOSubCard);// je-li zásoba na minimu nebo pod tak objednáme  }
end;

procedure CreateRequestsSannex(Self: TSiteForm);
var
  mGrid: TDBGrid;
  mOS: TNxCustomObjectSpace;
  mStrList,mStrReq:TStringList;
  N : integer;
  mBOSubCard,mBoOrdersRequest,mBoMainSupplier :  TNxCustomBusinessObject;
  P :TNxParameters;
  mPar : TNxParameter;
  mRollShare :Boolean;
  mQuantity: Extended;
begin

// je potoeba do budoucana zvážit zda systém nemá hledat objednávky vydané nebo rueni udilané požadavky a nijak je zohlednit poi novém objednávání
  mOS := TSiteForm(Self).BaseObjectSpace;
 // ovioíme, že pracujeme se sdílenými eíselníky - jinak poistupovat k hl. dodavateli
 // - neřešíme mRollShare := UpperCase(GetParamValue(mOS,'ROLLSHARE')) = 'ANO';
  mRollShare := false;
  mStrList := TStringList.Create;
  mStrReq  := TStringList.Create;
  try
    mStrReq.Clear;
    mGrid := TDBGrid(NxFindChildControl(TWinControl(NxFindChildControl(TSiteForm(Self).GetSiteAppForm, 'pnList')), 'grdList'));
    if Assigned(mGrid) then
      begin
        OutputDebugString('Je napojen grid');
        mGrid.FillListFromSelectedRows_1(mStrList);
      end else
        RaiseException('Není k dispozici grid označených požadavků'); // ošetouje vyvolání výjimky
// Nikterá z označených karet nemá hlavního dodavatele

    if not GetValidSupplier(Self.SiteContext,mStrList) then Exit;
    for N := 0 to mStrList.Count - 1 do begin
       mBOSubCard := mOS.CreateObject(Class_StoreSubCard);
       try
         mBOSubCard.Load(mStrList[N],nil);
         mQuantity :=GetQuantity(mBOSubCard);
         if mQuantity <= 0 then begin
            ShowMessage('Skladová karta: '+ mBOSubCard.GetFieldValueAsString('StoreCard_ID.Name') + 'nabízí objednat 0  - to je nepřípustné')
         end else begin
         if  GetCreateIssuedOrdersSannex(mBOSubCard) then begin
         //Objednávky vytvooené doíve nestaeí - jdeme objednávat
            mBoOrdersRequest := mOS.CreateObject(Class_OrdersGeneration);
            try
              mBoOrdersRequest.New;
              mBoOrdersRequest.Prefill;
              if mBOSubCard.GetFieldValueAsString('StoreCard_Id.X_PrefStore_ID') = '0000000000' then
                mBoOrdersRequest.SetFieldValueAsString('Store_ID','1700000101')
              else
                mBoOrdersRequest.SetFieldValueAsString('Store_ID',mBOSubCard.GetFieldValueAsString('StoreCard_Id.X_PrefStore_ID'));
              mBoOrdersRequest.SetFieldValueAsString('StoreCard_ID',mBOSubCard.GetFieldValueAsString('StoreCard_Id'));
              mBoOrdersRequest.SetFieldValueAsString('Firm_ID',NxEvalObjectExprAsString(mBOSubCard,'StoreCard_ID.MainSupplier_ID.Firm_ID'));
             if mRollShare then begin
             RaiseException('Není dooešeno objednávání poi sdílených eíselnících - volba dodavatele');//nutno poladit sdílené eíselníky
              GetSahareDod(mOS,mBOSubCard.GetFieldValueAsString('StoreCard_ID'));
             end else begin
               mBoOrdersRequest.SetFieldValueAsString('QUnit',NxEvalObjectExprAsString(mBOSubCard,'StoreCard_ID.MainSupplier_ID.QUnit'));
             end;
              mBoOrdersRequest.SetFieldValueAsDateTime('RequestedDelivery$DATE',Date + NxEvalObjectExprAsInteger(mBOSubCard,'StoreCard_ID.MainSupplier_ID.DeliveryTime'));
              mBoOrdersRequest.SetFieldValueAsFloat('Quantity',mQuantity);
             if mBOSubCard.GetFieldValueAsString('Store_ID.X_BusOrder_ID') <> '0000000000' then
               mBoOrdersRequest.SetFieldValueAsString('BusOrder_ID',mBOSubCard.GetFieldValueAsString('Store_ID.X_BusOrder_ID'));
             if mBOSubCard.GetFieldValueAsString('Store_ID.X_BusTransaction_ID') <> '0000000000' then
               mBoOrdersRequest.SetFieldValueAsString('BusTransaction_ID',mBOSubCard.GetFieldValueAsString('Store_ID.X_BusTransaction_ID'));
             if mBoOrdersRequest.GetFieldValueAsString('Store_ID.X_BusProject_ID') <> '0000000000' then
               mBoOrdersRequest.SetFieldValueAsString('BusProject_ID',mBOSubCard.GetFieldValueAsString('Store_ID.X_BusProject_ID'));
              mBoOrdersRequest.Save;
              mStrReq.Add(mBoOrdersRequest.OID);
       finally
         mBoOrdersRequest.Free;
       end;
     end;//if mQuantity <= 0
// Již není potoeba aktualizovat datum poslední objednávky
//           mBOSubCard.SetFieldValueAsDateTime('X_LastDay',Date);
//           mBOSubCard.Save;
         end;
       finally
         mBOSubCard.Free;
       end;
    end;
    if mStrReq.Count > 0 then begin
      P := TNxParameters.Create;
      try
        P.NewFromDataType(dtString, '_SelectionCaption', pkUnknown).AsString := 'Novi vytvooené požadavky';
        mPar := P.NewFromDataType(dtList, '_DefaultSelection', pkUnknown) ; //mPar je typu TNxParameter
        mPar := mPar.AsList.NewFromDataType(dtList, 'CONDITIONS', pkUnknown) ;
        mPar := mPar.AsList.NewFromDataType(dtList, 'ID', pkUnknown) ;
        mPar.AsList.NewFromDataType(dtInteger, 'USEDKIND', pkUnknown).AsInteger := 3; //3 = ckList
        mPar.AsList.NewFromDataType(dtString, 'VALUELIST', pkUnknown).AsString := NxStringsToCkListStr(mStrReq);
        ShowDynForm('SF5MZPEK3JE1342X01C0CX3FCC', TSiteForm(Self).SiteContext, P, nil, True);
      finally
        P.Free;
      end;
    end;
  finally
    mStrList.Free;
    mStrReq.Free;
  end;
end;

begin
end.