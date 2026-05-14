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
mInventoryOverPlusBO: TNxCustomHeaderBusinessObject;
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
        mInventoryOverPlusBO:= TNxCustomHeaderBusinessObject(TDynSiteForm(mSite).CurrentObject);
        if Assigned(mInventoryOverPlusBO) then begin
          mRows:=mInventoryOverPlusBO.Collections(mInventoryOverPlusBO.GetFieldCode('Rows'));
          for i := 0 to (mrows.Count-1) do begin
            // Vytvorime klon aktuálního objektu

            try
              // Klon ulozime
             //ShowMessage(IntToStr(mRows.BusinessObject[i].GetFieldValueAsInteger('Posindex')));
             if mrows.BusinessObject[i].GetFieldValueAsInteger('RowType')=3 then begin
             mStoreCardBO:=mrows.BusinessObject[i].GetMonikerForFieldCode(mrows.BusinessObject[i].GetFieldCode('StoreCard_id')).BusinessObject;
             mInventoryOverPlusRowBO:=mrows.BusinessObject[i];
             mprice:=scrPurchasePrice(mInventoryOverPlusBO.ObjectSpace, mInventoryOverPlusRowBO.GetFieldValueAsString('Store_ID'),mInventoryOverPlusRowBO.GetFieldValueAsString('StoreCard_ID'));
             mInventoryOverPlusRowBO.SetFieldValueAsFloat('UnitPrice',mPrice);
             
             
             
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
  cSQL = 'SELECT averagestoreprice  FROM storesubcards WHERE Store_ID=''%s'' and StoreCard_ID=''%s''';
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