uses  'eu.abra.roeh.Logio.Func',
     'eu.abra.roeh.Logio.QRFunc';


function GetCreateIssuedOrders(aBOSubCard:TNxCustomBusinessObject):Boolean;
var
  Str : TStringList;
  mMin,mQuant: Extended;
  mSQL,mS : string;
begin
  Result := true;
  mMin := aBOSubCard.GetFieldValueAsFloat('X_Min') + aBOSubCard.GetFieldValueAsFloat('X_KorekceMin');
  mQuant := aBOSubCard.GetFieldValueAsFloat('Quantity');
  mQuant := mQuant + IntOrdersSubCard(aBOSubCard.ObjectSpace,aBOSubCard.GetFieldValueAsString('ID'));
  mQuant := mQuant - IntForecastOrder(aBOSubCard.ObjectSpace,aBOSubCard.OID);//IntForecast(aBOSubCard.ObjectSpace,aBOSubCard.OID);
  mQuant := mQuant - IntReceivedOrdersSubCard(aBOSubCard.ObjectSpace,aBOSubCard.GetFieldValueAsString('Store_ID'),aBOSubCard.GetFieldValueAsString('StoreCard_ID'));
  Result := mMin >= mQuant;
  if not Result then begin
     mS := GetParamValue(aBOSubCard.ObjectSpace,'MINLIMIT');
     if Trim(mS) <> '' then begin
      Result := mQuant< aBOSubCard.GetFieldValueAsFloat(mS);
    end;
  end
 
 //Result := mMin <= GetClearQuantity(aBOSubCard);// je-li zásoba na minimu nebo pod tak objednáme
end;
function GetValidSupplier(mContext: TNxContext;mStrList: TStringList; AParent:TSiteForm):Boolean;
Var
  mSQL : string;
  mStr : TStringList;
  mFilter : string;
  i : integer;
begin
  Result := false;
  mSQl := 'Select a.id from StoreCards A inner join StoreSubCards SS on SS.StoreCard_ID = A.id where SS.id in ('+GedID(mStrList)+') and (A.id not in (';
  MSql := mSql + '    select ax.id from StoreCards Ax inner join StoreSubCards SS on SS.StoreCard_ID = Ax.id inner join SupplierS S on S.Id = Ax.MainSupplier_ID inner join Firms f on F.id = S.Firm_id where f.Hidden= ''N'' and  SS.id in ('+GedID(mStrList)+')))';

  mStr := TStringList.Create;
  try
    mContext.GetObjectSpace.SQLSelect (mSQL,mStr);
    Result := mStr.Count = 0;
    if not Result then begin
      ShowMessage('V některých skladových kartách chybí hlavní dodavatel!', AParent);
      Result := false;
      mFilter:= '';
      for i:= 0 to mStr.Count - 1 do
        mFilter:= mFilter + Format('''%s'',', [mStr[i]]);
      if mFilter <> '' then
        mFilter:= copy(mFilter, 1, Length(mFilter) - 1);
      NxShowSite('W31KWYTC5FDL342M01C0CX3FCC', mContext, nil, nil, 0, false, 'FilterByUserDynSQLCondition;A.ID in (' + mFilter + ') ');
    end;
  finally
    mStr.Free;
  end;
end;
procedure CreateRequests(Self: TSiteForm);
var
  mGrid: {TDBGrid}TDBGrid;
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
  mRollShare := UpperCase(GetParamValue(mOS,'ROLLSHARE')) = 'ANO';
  mStrList := TStringList.Create;
  mStrReq  := TStringList.Create;
  try
    mStrReq.Clear;
    mGrid := TDbGrid(Self.FindChildControl('pnList.grdList'));
    if Assigned(mGrid) then
      begin
        OutputDebugString('Je napojen grid');
        mGrid.FillListFromSelectedRows_1(mStrList);
      end else
        RaiseException('Není k dispozici grid oznaeených požadavku'); // ošetouje vyvolání výjimky
// Nikterá z oznaeených karet nemá hlavního dodavatele
    if not GetValidSupplier(Self.SiteContext,mStrList,Self) then Exit;

    for N := 0 to mStrList.Count - 1 do begin
       mBOSubCard := mOS.CreateObject(Class_StoreSubCard);
       try
         mBOSubCard.Load(mStrList[N],nil);
         mQuantity :=GetQuantity(mBOSubCard);
         if mQuantity <= 0 then begin
            ShowMessage('Skladová karta: '+ mBOSubCard.GetFieldValueAsString('StoreCard_ID.Name') + 'nabízí objednat 0  - to je nepřípustné', Self)
         end else begin
         if  GetCreateIssuedOrders(mBOSubCard) then begin
         //Objednávky vytvooené doíve nestaeí - jdeme objednávat
            mBoOrdersRequest := mOS.CreateObject(Class_OrdersGeneration);
            try
              mBoOrdersRequest.New;
              mBoOrdersRequest.Prefill;
              mBoOrdersRequest.SetFieldValueAsString('Store_ID',mBOSubCard.GetFieldValueAsString('Store_Id'));
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

function GetMaxQuantityCentralStorage(mOS: TNxCustomObjectSpace;const mStore_ID,mStoreCard_ID:string):Extended;
var
  mStr : TStringList;
begin
  Result := 0;
  mStr := TStringList.Create;
  Try
   mOS.SQLSelect('select s.Quantity from StoreSubCards s where s.Store_ID = '''+ mStore_ID +''' and s.StoreCard_ID = '''  + mStoreCard_ID + '''',mStr);
   if mStr.Count > 0 then Result := StrToFloat(mStr.Strings(0));
   if Result <0 then Result := 0;
  finally
    mStr.Free;
  end;
end;

procedure CreateOutgoingTransfer(Self: TSiteForm);
var
  mGrid: {TDBGrid}TDBGrid;
  mOS: TNxCustomObjectSpace;
  mStrList:TStringList;
  N : integer;
  mBOSubCard,mBo,mBO2 : TNxCustomBusinessObject;
  mRow:TNxCustomBusinessMonikerCollection;
//  P :TNxParameters;
//  mPar : TNxParameter;
  mErr:Boolean;
  mContext : TNxContext;
  mQuantity : Extended;
  mQuantRes : Boolean;
  mDok:Boolean;
  mMax : Extended;
  mField : string;
begin
  mOS := TSiteForm(Self).BaseObjectSpace;
  mErr := false;
  mQuantRes := false;
  mStrList := TStringList.Create;
  mDok := false;
  try
    mGrid := TDBGrid(Self.FindChildControl('pnList.grdList'));
    if Assigned(mGrid) then
      begin
        OutputDebugString('Je napojen grid');
        mGrid.FillListFromSelectedRows_1(mStrList);
      end else
        RaiseException('Není k dispozici grid označených požadavků'); // ošetřuje vyvolání výjimky
    mBo := mOS.CreateObject(Class_OutgoingTransfer);
    try
      mBO.New;
      mBO.Prefill;
//      mBO.SetFieldValueAsString('Description', 'XXXXX');
      mRow:= mBO.GetCollectionMonikerForFieldCode(mBO.GetFieldCode('ROWS'));
      for N := 0 to mStrList.Count - 1 do begin
         mBOSubCard := mOS.CreateObject(Class_StoreSubCard);
         try
           mBOSubCard.Load(mStrList[N],nil);
           if not mErr and (mBOSubCard.GetFieldValueAsString('Store_ID.X_DirectStore') = '0000000000') then begin
             ShowMessage('Ve výběru jsou skladové karty bez nastaveného nadřízeného skladu - nebudou do převodky zahrnuty', Self);
             mErr := true;
           end;
           mBO.SetFieldValueAsString('U_OutgoingStore_Id',mBOSubCard.GetFieldValueAsString('Store_ID'));
           if mBOSubCard.GetFieldValueAsString('Store_ID.X_DirectStore') <> '0000000000' then begin
             //Ještě ověříme, že zboží je na centrále
             mQuantity := GetMaxQuantityCentralStorage(mOS,mBOSubCard.GetFieldValueAsString('Store_ID.X_DirectStore'),mBOSubCard.GetFieldValueAsString('StoreCard_ID'));
             if mQuantity = 0 then mQuantRes := true
             else begin
               mBO2:= mRow.AddNewObject;
               mBO2.Prefill;
               mDok := true;
               mBO2.SetFieldValueAsString('Store_ID',mBOSubCard.GetFieldValueAsString('Store_ID.X_DirectStore'));
               mBO2.SetFieldValueAsString('StoreCard_ID',mBOSubCard.GetFieldValueAsString('StoreCard_ID'));
               mBO2.SetFieldValueAsString('Division_ID',mBOSubCard.GetFieldValueAsString('Store_ID.X_Division'));
               if mBOSubCard.GetFieldValueAsString('Store_ID.X_BusOrder_ID') <> '0000000000' then
                 mBO2.SetFieldValueAsString('BusOrder_ID',mBOSubCard.GetFieldValueAsString('Store_ID.X_BusOrder_ID'));
               if mBOSubCard.GetFieldValueAsString('Store_ID.X_BusTransaction_ID') <> '0000000000' then
                 mBO2.SetFieldValueAsString('BusTransaction_ID',mBOSubCard.GetFieldValueAsString('Store_ID.X_BusTransaction_ID'));
               if mBOSubCard.GetFieldValueAsString('Store_ID.X_BusProject_ID') <> '0000000000' then
                 mBO2.SetFieldValueAsString('BusProject_ID',mBOSubCard.GetFieldValueAsString('Store_ID.X_BusProject_ID'));

               //nejprve ošetřím, že jsem pod detekční hladinou - doplním do detekční hladiny
               mMax := mBOSubCard.GetFieldValueAsFloat('X_Min')- mBOSubCard.GetFieldValueAsFloat('Quantity');
               if mMax < 0  then mMax := 0;
               mMax := mMax + mBOSubCard.GetFieldValueAsFloat('X_Max');
               // Ošetřuje situaci, kdy obsluha na pobočkovém skladu chce minímlně dané množsví a není jasné ve které položce na dílčí kartě tuto informaci má
               mField := Trim(GetParamValue(mOS,'MINLIMIT'));
               if mField <> '' then
                 if mMax < (mBOSubCard.GetFieldValueAsFloat(mField)-mBOSubCard.GetFieldValueAsFloat('Quantity')) then mMax := mBOSubCard.GetFieldValueAsFloat(mField)-mBOSubCard.GetFieldValueAsFloat('Quantity');
                 // Ještě přičeteme obj. přijaté na pobořkový sklad
                 mMax := mMax  + mBOSubCard.GetFieldValueAsFloat('X_KorekceMax') + IntReceivedOrdersSubCard(mOS,mBOSubCard.GetFieldValueAsString('Store_ID'),mBOSubCard.GetFieldValueAsString('StoreCard_ID'));
               if mMax > mQuantity then begin
                 mBO2.SetFieldValueAsFloat('Quantity',mQuantity);
                 mQuantRes := true;
               end else
                 mBO2.SetFieldValueAsFloat('Quantity',mMax);
             end;
           end;
         finally
           mBOSubCard.Free;
         end;
      end;
      if mDok and mQuantRes then ShowMessage('Některé požadované položky nemají dostatečnou skladovou zásobu na centrále  - převodka byla redukována', Self);
      if mDok then begin // vznikne dokalad tak má cenu jej ukazovat
        mContext := NxCreateContext(Self.CompanyCache.GetCompanyObjectSpace); //toto zajistí že agenda, které se pošle takto vzniklý context se otev?e modáln?.
        TDynSiteForm.ShowDynFormWithNewDocument('BD0I5SAOS3DL3ACU03KIU0CLP4', mContext, mBO);
      end else ShowMessage('Převodka by neobsahovala ani jednu řádku. Nebude proto vytvořena.', Self);
    finally
      mBo.Free;
    end;
  finally
    mStrList.Free;
  end;
end;

begin
end.