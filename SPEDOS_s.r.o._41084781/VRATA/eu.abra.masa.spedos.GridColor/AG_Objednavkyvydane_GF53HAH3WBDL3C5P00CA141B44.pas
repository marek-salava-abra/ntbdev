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
   mRowBO, mObj:TNxCustomBusinessObject;
   mDataset: TNxRowsObjectDataSet;
begin
      mDataSet:= TNxRowsObjectDataSet(AColumn.Grid.DataSource.DataSet);
      mObj := mDataSet.ActiveObject;
      if Assigned(mObj) then begin
      if mObj.GetFieldValueAsInteger('RowType') = 3 then
      begin
        mPriceList:=TStringList.Create;
        mSQL1:='Select MinimalQuantity from Suppliers  where storecard_id=''%s'' and Firm_ID=''%s'' ';
        mobj.ObjectSpace.SQLSelect(Format(mSQL1,[mobj.GetFieldValueAsString('StoreCard_ID'),mobj.GetFieldValueAsString('Parent_ID.Firm_ID')]),mPricelist);
          if mPriceList.count>0 then begin
           //NxShowSimpleMessage('su tu',nil);
           if  (NxIBStrToFloat(mPriceList.strings[0])>mOBJ.GetFieldValueAsFloat('Quantity')) then
                  ABckColor:= RGBToColor(255, 163, 26) ;

          end;
        mPriceList.free;
      end;
     end;
end;

function RGBToColor(const R, G, B: Byte): Integer;
begin
	  Result := R or (G shl 8) or (B shl 16);
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