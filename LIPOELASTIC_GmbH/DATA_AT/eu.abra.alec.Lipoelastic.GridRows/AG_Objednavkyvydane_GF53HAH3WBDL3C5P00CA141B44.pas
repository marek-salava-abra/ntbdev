procedure My_OnGetBackgroundColor(Sender : TObject; AColumn: TNxMultiGridCustomColumn; const AIndex: Integer; const AMultiSelect: Boolean; const ASelectedActiveRow: Boolean; var ABckColor: TColor);
var
   mDelivered, mQuantity: Double;
begin
   if Copy(AColumn.Name, 1, 15) = 'colUnitQuantity' then
   begin
      if Assigned(AColumn.Grid.DataSource.DataSet) then
      begin
         mDelivered:= AColumn.Grid.DataSource.DataSet.FieldByName('DeliveredQuantity').AsFloat;
         mQuantity := AColumn.Grid.DataSource.DataSet.FieldByName('UnitQuantity').AsFloat;

         if mDelivered <= 0 then
            ABckColor := clRed
         else if mDelivered < mQuantity then
            ABckColor := clOrange               // částečně dodáno
         else
            ABckColor := clMoneyGreen;          // kompletně dodáno
      end;
   end;
end;

{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
   grdReqRows: TMultiGrid;
   i: Integer;
   mDeliveredCol: TNxMultiGridCustomColumn;
   mDebugStr: String;
begin
   grdReqRows := TMultiGrid(Self.FindChildControl('grdRows'));
   if Assigned(grdReqRows) then
   begin
      grdReqRows.OnGetBackgroundColor := @My_OnGetBackgroundColor;

      // Debug: Output all column names
      {
      mDebugStr := 'Column Names: ';
      for i := 0 to grdReqRows.ColumnCount - 1 do
      begin
         mDebugStr := mDebugStr + grdReqRows.Columns[i].Name + ' (Layout: ' +
                     IntToStr(grdReqRows.Columns[i].Layout) + ', Line: ' +
                     IntToStr(grdReqRows.Columns[i].Line) + ') | ';
      end;
      OutputDebugString((mDebugStr));
      }

      // Move DeliveredQuantity to Line 0 on Layout 3
      mDeliveredCol := grdReqRows.ColumnByName('colDeliveredQuantityStr3');
      if Assigned(mDeliveredCol) then
      begin
        mDeliveredCol.Line := 0;
        mDeliveredCol.Order := 10;
      end;

      grdreqrows.columnbyname('colUnitQuantity3').Order := 11;
      grdreqrows.columnbyname('colQUnit3').Order:= 12;
      grdreqrows.columnbyname('colUnitPrice3').Order:= 13;
      grdreqrows.columnbyname('colTotalPrice3').Order:= 14;
      grdreqrows.columnbyname('colAccount_ID3').Order:= 15;
      grdreqrows.columnbyname('colVATRate3b').Order:= 16;
      grdreqrows.columnbyname('colVATRate3a').Order:= 17;
      grdreqrows.columnbyname('colVATIndex3').Order:= 18;
      grdreqrows.columnbyname('colRowDiscount3').Order:= 19;

      for i:=0 to grdReqRows.ColumnCount - 1 do
      begin
        if grdReqRows.Columns[i].Caption = 'Počet' then
          grdReqRows.Columns[i].Caption:= 'Quantity';
      end;
   end;
end;

begin
end.