procedure FormCreate_Hook(Self: TSiteForm);
var
  mMAction: TMultiAction;
begin
  // Tlacitko pro zobrazeni pohybu&#xD;
  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Ocenit doklad';
  mMAction.Hint := 'Ocení ';
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
i, mPos: integer;
mSite: TSiteForm;
begin
  if Sender is TComponent then begin
    mSite := TComponent(Sender).DynSite;
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
             if mInventoryOverPlusRowBO.GetFieldValueAsFloat('Totalprice')=0 then begin
             mprice:=scrPurchasePrice(mInventoryOverPlusBO.ObjectSpace, 'C000000101',mInventoryOverPlusRowBO.GetFieldValueAsString('StoreCard_ID'));
             if mprice>0 then mInventoryOverPlusRowBO.SetFieldValueAsFloat('UnitPrice',mPrice*mInventoryOverPlusRowBO.GetFieldValueAsFloat('Unitrate'));



             end;




             end;

            finally


            end;
          end;
        end;
      end;
    end;
    if mInventoryOverPlusBO.NeedSave then mInventoryOverPlusBO.save;
    NxShowMessage('Info','Byly doplněny nákupní ceny na řádky s nulou',mdInformation,false,mSite);
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