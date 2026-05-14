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
   mRowBO:TNxCustomBusinessObject;
begin

   //if AColumn.Name = 'colUnitPrice3' then
//   if AColumn.Name = 'colStore_ID' then
  // begin
      mDataSetRows:= AColumn.Grid.DataSource.DataSet;
      if mDataSetRows.FieldByName('RowType').AsInteger = 3 then
      begin
        mPriceList:=TStringList.Create;
        mSQL1:='Select id from issuedorders2  where storecard_id=''%s'' and parent_id=''%s'' ';
        mDataSetRows.Site.BaseObjectSpace.SQLSelect(Format(mSQL1,[mDataSetRows.FieldByName('StoreCard_ID').AsString,mDataSetRows.FieldByName('Parent_ID').AsString]),mPricelist);
       if mPriceList.count>0 then begin
        mRowBO:=mDataSetRows.Site.BaseObjectSpace.CreateObject(Class_IssuedOrderRow);
        //NxShowSimpleMessage(mDataSetRows.FieldByName('Parent_ID').AsString,nil);
        mrowbo.Load(mPriceList.strings[0],nil);
        //if mPriceList.count>0 then mPrice:=StrToFloat(mPriceList.Strings[0])*mDataSetRows.FieldByName('UnitRate').AsFloat;
        if  (mRowBO.GetFieldValueAsFloat('DeliveredUnitQuantity')>=mRowBO.GetFieldValueAsFloat('UnitQuantity')) then
                  ABckColor:=clMoneyGreen;
        if  (mRowBO.GetFieldValueAsFloat('DeliveredUnitQuantity')<mRowBO.GetFieldValueAsFloat('UnitQuantity')) and (mRowBO.GetFieldValueAsFloat('DeliveredUnitQuantity')>0) then
                  ABckColor:=clYellow;//ColorToRGB(220,208,192);
        mrowbo.free;
        end;
        mPriceList.free;
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