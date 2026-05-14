procedure FormCreate_Hook(Self: TSiteForm);
var
  mMAction: TMultiAction;
begin
  // Tlacitko pro zobrazeni pohybu&#xD;
  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Ocenit INP';
  mMAction.Hint := 'Ocenit INP';
  mMAction.Category := 'tabList';
  mMAction.OnExecuteItem := @ChangeRowType;
  mMAction.Items.Add('Ocenit INP');
end;

procedure ChangeRowType(Sender: TObject; AIndex: integer);
var
mInventoryOverPlusBO: TNxCustomBusinessObject;
mInventoryOverPlusRowBO, mStoreCardBO: TNxCustomBusinessObject;
mRows: TNxCustomBusinessMonikerCollection;
mText, mVatRate_ID,mDivision_ID, mQunit: String;
mQuantity, mPrice, mVAT: Double;
mOLE : Variant;
  mEval : string;
i, mPos: integer;
mSite: TSiteForm;
begin
  if Sender is TComponent then begin
    mSite := NxFindSiteForm(TComponent(Sender));
    if Assigned(mSite) then begin
      if mSite is TDynSiteForm then begin
        mInventoryOverPlusBO:= (TDynSiteForm(mSite).CurrentObject);
        if Assigned(mInventoryOverPlusBO) then begin
          mRows:=mInventoryOverPlusBO.GetLoadedCollectionMonikerForFieldCode(mInventoryOverPlusBO.GetFieldCode('Rows'));
          for i := 0 to (mrows.Count-1) do begin
            // Vytvorime klon aktuálního objektu
            mInventoryOverPlusRowBO:=mRows.BusinessObject[i];
            try
              // Klon ulozime
             //ShowMessage(IntToStr(mRows.BusinessObject[i].GetFieldValueAsInteger('Posindex')));
             if mrows.BusinessObject[i].GetFieldValueAsInteger('RowType')=3 then begin
              //mInventoryOverPlusRowBO.setFieldValueAsFloat('UnitPrice',0);
              //mInventoryOverPlusRowBO.setFieldValueAsFloat('Totalprice',0);
             mStoreCardBO:=mrows.BusinessObject[i].GetMonikerForFieldCode(mrows.BusinessObject[i].GetFieldCode('StoreCard_id')).BusinessObject;
             mInventoryOverPlusRowBO:=mrows.BusinessObject[i];
             if mInventoryOverPlusRowBO.GetFieldValueAsFloat('Totalprice')=0 then begin
              mOLE:=GetAbraOLEApplication;
              mEval := 'NxRoundByValue(NxGetStoreCardUnitPriceDef(' + QuotedStr('') + ',' + QuotedStr('') + ','
              + QuotedStr(mInventoryOverPlusRowBO.GetFieldValueAsString('StoreCard_ID')) + ','
              + QuotedStr('1000000101') + ','
              + QuotedStr(mInventoryOverPlusRowBO.GetFieldValueAsString('QUnit')) + ',' + 'false,'
               + QuotedStr(mInventoryOverPlusRowBO.GetFieldValueAsString('Parent_ID.Currency_ID'))
               + ', NxNow()),1,0.01)';
    //NxGetStoreCardUnitPriceDef(Firm_ID, Store_ID, StoreCard_ID, PriceDefinition_ID,
    // StoreUnit_ID.Code, False, NxGetCompanyCurrencyID, Date)
             //mPrice :=  strtofloat(mOLE.Evaluate(mEval));
             //if mInventoryOverPlusRowBO.GetFieldValueAsfloat('StoreCard_ID.U_marze')>0 then mprice:=mprice/mInventoryOverPlusRowBO.GetFieldValueAsfloat('StoreCard_ID.U_marze');
             mprice:=scrPurchasePrice(mInventoryOverPlusBO.ObjectSpace, mInventoryOverPlusRowBO.GetFieldValueAsString('Store_ID'),mInventoryOverPlusRowBO.GetFieldValueAsString('StoreCard_ID'));
             mInventoryOverPlusRowBO.SetFieldValueAsFloat('UnitPrice',mPrice);
             
             
             
             end;

                
                

             end;
             
            finally


            end;
          end;
        end;
      end;
    end;
    mInventoryOverPlusBO.save;
    ShowMessage('Byly doplněny nákupní ceny na řádky s nulou');
  end;
end;
function scrPurchasePrice(AOS : TNxCustomObjectSpace; AStore_ID : string; AStoreCard_ID:string) : Double;
const
  cSQL = 'SELECT PurchasePrice*PurchaseCurrRate  FROM storesubcards WHERE Store_ID=''%s'' and StoreCard_ID=''%s''';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:=0;
    AOS.SQLSelect(Format(cSQL, [AStore_ID,AStoreCard_ID]), mList);
    if mList.Count > 0 then
      Result := StrToFloat(mList.Strings[0]);
  finally
    mList.Free;
  end;
end;


begin
end.