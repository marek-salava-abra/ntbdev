
{
hele na oplátku.... potřebuji do multigridu požadavku na výrobu dostat stav skladu pro StoreCard_ID a SupposedStore_ID
}

procedure My_OnGetBackgroundColor(Sender : TObject; AColumn: TNxMultiGridCustomColumn; const AIndex: Integer; const AMultiSelect: Boolean; const ASelectedActiveRow: Boolean; var ABckColor: TColor);
var
   mFieldData: String;
begin
   if Copy(AColumn.Name,1,21) = 'StoreSubCardQuantity_' then
   begin
      mFieldData:= AColumn.Grid.DataSource.DataSet.FieldByName('StoreSubCardQuantity').AsString;
      mFieldData:= NxSearchReplace(mFieldData,' ','',[srAll]);
      mFieldData:= NxSearchReplace(mFieldData,' ','',[srAll]);  // Nějaký divný znak z té masky (NBSP - non braking space):-( , není to mezera...
      if AColumn.Grid.DataSource.DataSet.FieldByName('InputItem_ID.Quantity').AsFloat <= NxIBStrToFloat(mFieldData) then     //strtofloat
      begin
         ABckColor:= clMoneyGreen;  // Podbarvím, co je skladem
      end;
   end;
end;

procedure My_OnGetColumnReadOnly(Sender: TNxMultiGridCustomColumn; var AReadOnly: Boolean);
begin
   if Sender.Name = 'StoreSubCardQuantity' then AReadOnly:= True;
end;

procedure My_OnCalcFields(DataSet: TDataSet);
var
   mSQL: String;
   mFieldData: Double;
begin
 //  OutputDebugString(DataSet.FieldList.Text);  => výpis názvu položek ;-)

   if (Not(NxIsEmptyOID(DataSet.FieldByName('InputItem_ID.SupposedStore_ID').AsString))) and (Not(NxIsEmptyOID(DataSet.FieldByName('InputItem_ID.RealStoreCard_ID').AsString))) then
   begin
      mSQL:= 'Select Quantity '+
             'From StoreSubCards '+
             'Where StoreCard_ID = '+QuotedStr(DataSet.FieldByName('InputItem_ID.RealStoreCard_ID').AsString)+' and '+
             'Store_ID = '+QuotedStr(DataSet.FieldByName('InputItem_ID.SupposedStore_ID').AsString);
      mFieldData:= DataSet.Site.BaseObjectSpace.SQLSelectFirstAsExtended(mSQL,0);

      DataSet.FieldByName('StoreSubCardQuantity').AsString:= NxFormatNumeric('0.,00',mFieldData);
   end
   else
   begin
      DataSet.FieldByName('StoreSubCardQuantity').AsString:= NxFormatNumeric('0.,000',0);
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
begin
   grdReqRows:= TMultiGrid(Self.FindChildControl('grdReqRows'));
   if Assigned(grdReqRows) then
   begin
      grdReqRows.OnGetColumnReadOnly:= @My_OnGetColumnReadOnly;
      grdReqRows.OnGetBackgroundColor:= @My_OnGetBackgroundColor;
// Výpočtový sloupec
      mDataSet:= grdReqRows.DataSource.DataSet;
      mDataSet.OnCalcFields:= @My_OnCalcFields;

      mFieldDef:= TFieldDef.Create(mDataSet.FieldDefs, 'StoreSubCardQuantity', ftString, 15, False, 300001);
      with mFieldDef.CreateField(mDataSet, nil, 'StoreSubCardQuantity', False) do
      begin
         FieldKind:= fkCalculated;
         FieldName:= 'StoreSubCardQuantity';
         Alignment:= taRightJustify;
      end;

      For i:= 0 to 3 do
      begin
         mCol := TNxMultiGridColumn.Create(grdReqRows);
         mCol.Layout:= i;
         mCol.Line:= 0;
         mCol.Order := 6;
         mCol.FieldName := 'StoreSubCardQuantity';
         mCol.Caption := 'Skladem';
         mCol.Name := 'StoreSubCardQuantity_'+IntToStr(i);
         mCol.Width := 80;
         mCol.Elastic:= False;
         grdReqRows.InsertColumn(mCol);
      end;

   end;
end;

begin
end.