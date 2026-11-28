var

 mBO:TNxCustomBusinessObject;
function RGBToColor(const R, G, B: Byte): Integer;
begin
	  Result := R or (G shl 8) or (B shl 16);
end;

Procedure SetCellFontProps  (Sender : TObject; var AActColumn: TNxMultiGridCustomColumn; var AFont : TFont);
  begin
    AFont.Color:= RGBToColor(0,0,0);
  end;

Procedure SetBackgroundColor(Sender : TObject; AColumn: TNxMultiGridCustomColumn; const AIndex: Integer; const AMultiSelect: Boolean;
 const ASelectedActiveRow: Boolean; var ABckColor: TColor);
Var
   mDataSetList: TDataSet;
   mDataSetRows: TDataSet;
   ColorS, mSQL1, mSQL2: String;
   Color, mCnt: Integer;
   mSite: TSiteForm;
   mGrdList: TMultiGrid;
   mPriceList, mQuantityList: TStringList;
   mPrice, mQuantity:Extended;
   mDataset: TNxRowsObjectDataSet;
begin

   //if AColumn.Name = 'colUnitPrice3' then
//   if AColumn.Name = 'colStore_ID' then
  // begin
      mDataset := TNxRowsObjectDataSet(AColumn.Grid.DataSource.DataSet);
      mBO:=mDataset.ActiveObject;
     if Assigned(mBO) then begin
      mCnt:=AColumn.Grid.DataSource.BusRollSite.BaseObjectSpace.SQLSelectFirstAsInteger('Select count(id) from FirmAssortmentDiscounts where StoreAssortmentGroup_ID='+
           QuotedStr(mBO.GetFieldValueAsString('StoreAssortmentGroup_ID'))+' and parent_ID='+QuotedStr(mBO.GetFieldValueAsString('Parent_ID')),0);

      begin

        if mCnt>1 then ABckColor:=RGBToColor(255,255,204);

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
    mGrdRows:= TMultiGrid(NxFindChildControl(Self, 'grdAssortmentDiscounts'));
    mGrdRows.OnGetBackgroundColor:= @SetBackgroundColor;
    //mGrdRows.OnGetCellFontProps:= @SetCellFontProps;
    mBO:=TBusRollSiteForm(Self).CurrentObject;
end;

begin
end.