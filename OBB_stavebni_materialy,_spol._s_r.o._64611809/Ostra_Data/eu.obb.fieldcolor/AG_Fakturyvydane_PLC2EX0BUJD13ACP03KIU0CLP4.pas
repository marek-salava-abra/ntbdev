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

   if AColumn.Name = 'colUnitPrice3' then
//   if AColumn.Name = 'colStore_ID' then
   begin
      mDataSetRows:= AColumn.Grid.DataSource.DataSet;
      if mDataSetRows.FieldByName('RowType').AsInteger = 3 then
      begin
        if not(NxIsEmptyOID(mDataSetRows.FieldByName('StoreCard_ID').AsString)) then begin
        mPriceList:=TStringList.Create;
        mList:=TStringList.Create;
        mSQL1:='Select sp2.amount/sp2.unitrate from storeprices sp left join storeprices2 sp2 on sp.id=sp2.parent_id where sp.storecard_id=''%s'' and sp.pricelist_id=''1000000101'' ';
        mSQL2:='Select unitrate from storeUnits where Parent_id=''%s'' and code=''%s'' ';
        mDataSetRows.Site.BaseObjectSpace.SQLSelect(Format(mSQL1,[mDataSetRows.FieldByName('StoreCard_ID').AsString]),mPricelist);
        mDataSetRows.Site.BaseObjectSpace.SQLSelect(Format(mSQL2,[mDataSetRows.FieldByName('StoreCard_ID').AsString,mDataSetRows.FieldByName('Qunit').AsString]),mList);
        mprice:=0;
        if (mPriceList.count>0) and (mlist.count>0)  then mPrice:=StrToFloat(mPriceList.Strings[0])*StrToFloat(mList.Strings[0]);
        if mprice>0 then begin
        if  ((mDataSetRows.FieldByName('UnitPrice').AsFloat-mPrice)>0.09) or ((mDataSetRows.FieldByName('UnitPrice').AsFloat-mPrice)<-0.09) then
                  ABckColor:=clRed;
        end;
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
 mList:TStringList;
 mText:string;
begin
    mGrdRows:= TMultiGrid(NxFindChildControl(Self, 'grdRows'));

    mGrdRows.OnGetBackgroundColor:= @SetBackgroundColor;
end;

begin
end.