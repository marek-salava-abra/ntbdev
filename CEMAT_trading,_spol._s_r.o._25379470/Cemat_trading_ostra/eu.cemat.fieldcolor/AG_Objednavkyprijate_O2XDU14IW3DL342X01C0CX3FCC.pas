Procedure SetBackgroundColor(Sender : TObject; AColumn: TNxMultiGridCustomColumn; const AIndex: Integer; const AMultiSelect: Boolean; const ASelectedActiveRow: Boolean; var ABckColor: TColor);
Var
   mDataSetList: TDataSet;
   mDataSetRows: TDataSet;
   ColorS, mSQL1: String;
   Color: Integer;
   mSite: TSiteForm;
   mGrdList: TMultiGrid;
   mPriceList: TStringList;
   mPrice:Extended;
begin

   if AColumn.Name = 'colUnitPrice3' then
//   if AColumn.Name = 'colStore_ID' then
   begin
      mDataSetRows:= AColumn.Grid.DataSource.DataSet;
      if mDataSetRows.FieldByName('RowType').AsInteger = 3 then
      begin
        mPriceList:=TStringList.Create;
        mSQL1:='Select sp2.amount/sp2.unitrate from storeprices sp left join storeprices2 sp2 on sp.id=sp2.parent_id where sp.storecard_id=''%s'' and sp.pricelist_id=''1J00000101'' ';
        mDataSetRows.Site.BaseObjectSpace.SQLSelect(Format(mSQL1,[mDataSetRows.FieldByName('StoreCard_ID').AsString]),mPricelist);
        mprice:=0;
        if mPriceList.count>0 then mPrice:=StrToFloat(mPriceList.Strings[0])*mDataSetRows.FieldByName('UnitRate').AsFloat;
        if mprice>0 then begin
        if  (mDataSetRows.FieldByName('UnitPrice').AsFloat=mPrice) then
                  ABckColor:=clRed;
        end;
      end;
   end;
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