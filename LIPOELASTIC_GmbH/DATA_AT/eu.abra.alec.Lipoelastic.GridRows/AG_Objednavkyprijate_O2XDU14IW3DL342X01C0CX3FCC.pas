
procedure My_OnGetBackgroundColor(Sender : TObject; AColumn: TNxMultiGridCustomColumn; const AIndex: Integer; const AMultiSelect: Boolean; const ASelectedActiveRow: Boolean; var ABckColor: TColor);
var
   mFieldData: String;
   mOrdersQuantity: Extended;
begin
   if Copy(AColumn.Name,1,13) = 'CurrentStock_' then
   begin
      mFieldData:= AColumn.Grid.DataSource.DataSet.FieldByName('CurrentStock').AsString;
      mFieldData:= NxSearchReplace(mFieldData,' ','',[srAll]);
      mFieldData:= NxSearchReplace(mFieldData,' ','',[srAll]);  // Nějaký divný znak z té masky :-( , není to mezera...
      if mFieldData <> '' then begin
        mOrdersQuantity:= NxIBStrToFloat(AColumn.Grid.DataSource.DataSet.FieldByName('OrdersQuantity').AsString);

        if NxIBStrToFloat(mFieldData) <= 0 then
          ABckColor:= clOrange
        else
        begin
          if mOrdersQuantity <= NxIBStrToFloat(mFieldData) then
          begin
            ABckColor:= clMoneyGreen;  // Podbarvím, co je skladem
          end
          else
          begin
             ABckColor:= clOrange;
          end;
        end;
      end;
   end;
end;

procedure My_OnGetColumnReadOnly(Sender: TNxMultiGridCustomColumn; var AReadOnly: Boolean);
begin
   if Copy(Sender.Name, 0, 12) = 'CurrentStock' then AReadOnly:= True;
end;

procedure My_OnCalcFields(DataSet: TDataSet);
var
   mSQL, mStoreCard_ID, mStore_ID, mParent_ID: String;
   mFieldData, mQuantity, mDeliveredQuantity: Double;
begin
  mStoreCard_ID:= '';
  mStore_ID:= '';

   //OutputDebugString(DataSet.FieldList.Text); // => výpis názvu položek ;-)
  try
    DataSet.FieldByName('CurrentStock').AsString:= NxFormatNumeric('0.,00',0);
    DataSet.FieldByName('OrdersQuantity').AsString:= NxFormatNumeric('0.,00',0);
    DataSet.FieldByName('OrdersOutQuantity').AsString:= NxFormatNumeric('0.,00',0);
    mStoreCard_ID:= DataSet.FieldByName('StoreCard_ID').AsString;
    mStore_ID:= DataSet.FieldByName('Store_ID').AsString;
    mParent_ID:= DataSet.FieldByName('Parent_ID').AsString;
    mQuantity:= DataSet.FieldByName('UnitQuantity').AsFloat;
    mDeliveredQuantity:= DataSet.FieldByName('DeliveredQuantity').AsFloat;

    if (Not(NxIsEmptyOID(mStoreCard_ID))) and (Not(NxIsEmptyOID(mStore_ID))) then
    begin
      mSQL:= Format(
        ' Select SSC.Quantity '+
        ' From StoreSubCards SSC '+
        ' Where SSC.StoreCard_ID = ''%s'' '+
        ' AND SSC.Store_ID = ''%s'' ',
        [mStoreCard_ID, mStore_ID]);

      mFieldData:= DataSet.Site.BaseObjectSpace.SQLSelectFirstAsExtended(mSQL, 0);

      DataSet.FieldByName('CurrentStock').AsString:= NxFormatNumeric('0.,00', mFieldData);

      mSQL:= Format(
        ' SELECT SUM(RO2.Quantity - RO2.DeliveredQuantity) '+
        ' FROM ReceivedOrders RO '+
        ' JOIN ReceivedOrders2 RO2 ON RO.ID = RO2.Parent_ID '+
        ' WHERE RO2.StoreCard_ID = ''%s'' '+
        ' AND RO2.Store_ID = ''%s'' ' +
        ' AND RO.Closed = ''N'' '+
        //' AND RO.Confirmed = ''A'' '+
        ' AND RO2.Parent_ID <> ''%s'' ',
        [mStoreCard_ID, mStore_ID, mParent_ID]);

      mFieldData:= DataSet.Site.BaseObjectSpace.SQLSelectFirstAsExtended(mSQL, 0);
      mFieldData:= mFieldData + mQuantity - mDeliveredQuantity;

      DataSet.FieldByName('OrdersQuantity').AsString:= NxFormatNumeric('0.,00', mFieldData);

      mSQL:= Format(
        ' SELECT SUM(IO2.Quantity - IO2.DeliveredQuantity) '+
        ' FROM IssuedOrders IO '+
        ' JOIN IssuedOrders2 IO2 ON IO.ID = IO2.Parent_ID '+
        ' WHERE IO2.StoreCard_ID = ''%s'' '+
        ' AND IO2.Store_ID = ''%s'' ' +
        ' AND IO.Closed = ''N'' '+
        ' AND IO.Confirmed = ''A'' ',
        [mStoreCard_ID, mStore_ID]);

      mFieldData:= DataSet.Site.BaseObjectSpace.SQLSelectFirstAsExtended(mSQL, 0);

      DataSet.FieldByName('OrdersOutQuantity').AsString:= NxFormatNumeric('0.,00', mFieldData);
   end;

   except
    //NxShowSimpleMessage(ExceptionMessage, nil);
   end;
end;


{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
   grdReqRows: TMultiGrid;
   mFieldDef: TFieldDef;
   mField: TFIeld;
   mDataSet: TDataSet;
   mCol: TNxMultiGridColumn;
   i: Integer;
   mTemp: string;
begin
   // ASite:= Self;
   grdReqRows:= TMultiGrid(Self.FindChildControl('grdRows'));
   if Assigned(grdReqRows) then
   begin
      grdReqRows.OnGetColumnReadOnly:= @My_OnGetColumnReadOnly;
      grdReqRows.OnGetBackgroundColor:= @My_OnGetBackgroundColor;



      for i:= 0 to grdReqRows.ColumnCount -1 do begin
        if VarToStr(grdReqRows.Columns[i].Name) in ['colUnitQuantity2', 'colUnitQuantity3'] then begin
          grdReqRows.Columns[i].Caption:= 'Quantity';
        end;
        //mTemp:= mTemp + nxCrLf + VarToStr(grdReqRows.Columns[i].Name);

      end;
      //NxShowSimpleMessage(mTemp, nil);




// Výpočtový sloupec
      mDataSet:= grdReqRows.DataSource.DataSet;
      mDataSet.OnCalcFields:= @My_OnCalcFields;

      mFieldDef:= TFieldDef.Create(mDataSet.FieldDefs, 'CurrentStock', ftString, 15, False, 300001);
      with mFieldDef.CreateField(mDataSet, nil, 'CurrentStock', False) do
      begin
         FieldKind:= fkCalculated;
         FieldName:= 'CurrentStock';
         Alignment:= taRightJustify;
      end;

      mFieldDef:= TFieldDef.Create(mDataSet.FieldDefs, 'OrdersQuantity', ftString, 15, False, 300002);
      with mFieldDef.CreateField(mDataSet, nil, 'OrdersQuantity', False) do
      begin
         FieldKind:= fkCalculated;
         FieldName:= 'OrdersQuantity';
         Alignment:= taRightJustify;
      end;

      mFieldDef:= TFieldDef.Create(mDataSet.FieldDefs, 'OrdersOutQuantity', ftString, 15, False, 300003);
      with mFieldDef.CreateField(mDataSet, nil, 'OrdersOutQuantity', False) do
      begin
         FieldKind:= fkCalculated;
         FieldName:= 'OrdersOutQuantity';
         Alignment:= taRightJustify;
      end;

      For i:= 0 to 3 do
      begin
         mCol := TNxMultiGridColumn.Create(grdReqRows);
         mCol.Layout:= i;
         mCol.Line:= 0;
         mCol.Order := 6;
         mCol.FieldName := 'CurrentStock';
         mCol.Caption := 'On store';
         mCol.Name := 'CurrentStock_'+IntToStr(i);
         mCol.Width := 80;
         mCol.Elastic:= False;
         grdReqRows.InsertColumn(mCol);

         mCol := TNxMultiGridColumn.Create(grdReqRows);
         mCol.Layout:= i;
         mCol.Line:= 0;
         mCol.Order := 7;
         mCol.FieldName := 'OrdersQuantity';
         mCol.Caption := 'Outgoing';
         mCol.Name := 'OrdersQuantity_'+IntToStr(i);
         mCol.Width := 80;
         mCol.Elastic:= False;
         grdReqRows.InsertColumn(mCol);

         mCol := TNxMultiGridColumn.Create(grdReqRows);
         mCol.Layout:= i;
         mCol.Line:= 0;
         mCol.Order := 8;
         mCol.FieldName := 'OrdersOutQuantity';
         mCol.Caption := 'Incoming';
         mCol.Name := 'OrdersOutQuantity_'+IntToStr(i);
         mCol.Width := 80;
         mCol.Elastic:= False;
         grdReqRows.InsertColumn(mCol);


      end;

   end;
end;

begin
end.

begin
end.