Procedure SetBackgroundColor(Sender : TObject; AColumn: TNxMultiGridCustomColumn; const AIndex: Integer; const AMultiSelect: Boolean; const ASelectedActiveRow: Boolean; var ABckColor: TColor);
Var
   mDataSetList: TDataSet;
   mDataSetRows: TDataSet;
   ColorS, mSQL1, mSQL2: String;
   Color: Integer;
   mSite: TSiteForm;
   mGrdList: TMultiGrid;
   mParent_IDDQ:string;
   mQuantity:Extended;
begin
   if AColumn.Name = 'colStoreCard_ID' then
   begin
      mDataSetRows:= AColumn.Grid.DataSource.DataSet;

      if (mDataSetRows.FieldByName('RowType').AsInteger = 3) and (TNxRowsObjectDataSet(mDataSetRows).ActiveObject.GetFieldValueAsString('Parent_ID.DocQueue_ID')='1LA0000101') then
      begin
        if not(NxIsEmptyOID(mDataSetRows.FieldByName('StoreCard_ID').AsString)) then begin
        mQuantity:=mDataSetRows.Site.BaseObjectSpace.SQLSelectFirstAsExtended('Select quantity from storesubcards where storecard_id='+Quotedstr(mDataSetRows.FieldByName('StoreCard_ID').AsString)+
                                                                              ' and store_id='+Quotedstr(mDataSetRows.FieldByName('Store_ID').AsString),0);
        if mquantity<TNxRowsObjectDataSet(mDataSetRows).ActiveObject.GetFieldValueAsFloat('Quantity') then ABckColor:=clRed;
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