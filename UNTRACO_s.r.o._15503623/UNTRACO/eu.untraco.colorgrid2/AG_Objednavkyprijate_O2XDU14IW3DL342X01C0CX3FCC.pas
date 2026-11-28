function RGBToColor(const R, G, B: Byte): Integer;
begin
	  Result := R or (G shl 8) or (B shl 16);
end;

Procedure SetBackgroundColor(Sender : TObject; AColumn: TNxMultiGridCustomColumn; const AIndex: Integer; const AMultiSelect: Boolean; const ASelectedActiveRow: Boolean; var ABckColor: TColor);
Var
   mDataSetList: TDataSet;
   mDataSetRows: TDataSet;
   ColorS, mSQL1, mSQL2: String;
   Color: Integer;
   mSite: TSiteForm;
   mGrdList: TMultiGrid;
   mPriceList, mList: TStringList;
   mPrice:Extended;
begin

   //if AColumn.Name = 'colUnitPrice3' then
//   if AColumn.Name = 'colStore_ID' then
  // begin
      mDataSetRows:= AColumn.Grid.DataSource.DataSet;
      if true then
      //if mDataSetRows.FieldByName('RowType').AsInteger = 3 then
      begin
        mPriceList:=TStringList.Create;
        mList:=TStringList.Create;
        mSQL2:='Select sum(ssc.quantity/su.unitrate) from storesubcards ssc left join storecards sc on sc.id=ssc.storecard_id left join storeunits su on su.parent_id=sc.id where ssc.storecard_id=''%s'' and ssc.store_id=''%s'' and su.code=sc.mainunitcode ';
        mDataSetRows.Site.BaseObjectSpace.SQLSelect(Format(mSQL2,[mDataSetRows.FieldByName('StoreCard_ID').AsString,mDataSetRows.FieldByName('Store_ID').AsString]),mList);
        if (NxIBStrToFloat(mlist.Strings[0])<mDataSetRows.FieldByName('UnitQuantity').AsFloat) and (mDataSetRows.FieldByName('RowType').AsInteger = 3) then  ABckColor:=RGBToColor(102,204,255);

      end;
   ///end;
end;

{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var mGrdRows: TMultiGrid;
 i:Integer;
 mText:string;
begin
    mGrdRows:= TMultiGrid(NxFindChildControl(Self, 'grdRows'));
    mGrdRows.OnGetBackgroundColor:= @SetBackgroundColor;
end;

begin
end.