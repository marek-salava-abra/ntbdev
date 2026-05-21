
procedure My_OnGetBackgroundColor(Sender : TObject; AColumn: TNxMultiGridCustomColumn; const AIndex: Integer; const AMultiSelect: Boolean; const ASelectedActiveRow: Boolean; var ABckColor: TColor);
var
   mFieldData: String;
begin
   if Copy(AColumn.Name,1,22) = 'StoreSubBatchQuantity_' then
   begin
      mFieldData:= AColumn.Grid.DataSource.DataSet.FieldByName('StoreSubBatchQuantity').AsString;
      mFieldData:= NxSearchReplace(mFieldData,' ','',[srAll]);
      mFieldData:= NxSearchReplace(mFieldData,' ','',[srAll]);  // Nějaký divný znak z té masky :-( , není to mezera...
      if mFieldData <> '' then begin
        if AColumn.Grid.DataSource.DataSet.FieldByName('UnitQuantity').AsFloat <= NxIBStrToFloat(mFieldData) then
        begin
          ABckColor:= clMoneyGreen;  // Podbarvím, co je skladem
        end;
      end;
   end;
end;

procedure My_OnGetColumnReadOnly(Sender: TNxMultiGridCustomColumn; var AReadOnly: Boolean);
begin
   if Copy(Sender.Name, 0, 21) = 'StoreSubBatchQuantity' then AReadOnly:= True;
end;

procedure My_OnCalcFields(DataSet: TDataSet);
var
   mSQL: String;
   mFieldData: Double;
begin

   OutputDebugString(DataSet.FieldList.Text); // => výpis názvu položek ;-)
   try
   if (Not(NxIsEmptyOID(DataSet.FieldByName('StoreBatch_ID').AsString))) {and (Not(NxIsEmptyOID(DataSet.FieldByName('StoreBatch_ID.StoreCard_ID').AsString)))} then
   begin
      mSQL:= ' Select SSB.Quantity '+
             ' From StoreSubBatches SSB '+
             ' JOIN StoreBatches SB ON SB.ID = SSB.StoreBatch_ID '+
             ' Where SB.ID = '+QuotedStr(DataSet.FieldByName('StoreBatch_ID').AsString);

      mFieldData:= DataSet.Owner.Site.BaseObjectSpace.SQLSelectFirstAsExtended(mSQL, 0);
      DataSet.FieldByName('StoreSubBatchQuantity').AsString:= NxFormatNumeric('0.,00', mFieldData);
   end
   else
   begin
      DataSet.FieldByName('StoreSubBatchQuantity').AsString:= NxFormatNumeric('0.,00',0);
   end;
   except
    NxShowSimpleMessage(ExceptionMessage, nil);
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
   grdReqRows:= TMultiGrid(Self.FindChildControl('grdDocRowBatch'));
   if Assigned(grdReqRows) then
   begin
      grdReqRows.OnGetColumnReadOnly:= @My_OnGetColumnReadOnly;
      grdReqRows.OnGetBackgroundColor:= @My_OnGetBackgroundColor;
// Výpočtový sloupec
      mDataSet:= grdReqRows.DataSource.DataSet;
      mDataSet.OnCalcFields:= @My_OnCalcFields;

      mFieldDef:= TFieldDef.Create(mDataSet.FieldDefs, 'StoreSubBatchQuantity', ftString, 15, False, 300001);
      with mFieldDef.CreateField(mDataSet, nil, 'StoreSubBatchQuantity', False) do
      begin
         FieldKind:= fkCalculated;
         FieldName:= 'StoreSubBatchQuantity';
         Alignment:= taRightJustify;
      end;

      For i:= 0 to 3 do
      begin
         mCol := TNxMultiGridColumn.Create(grdReqRows);
         mCol.Layout:= i;
         mCol.Line:= 0;
         mCol.Order := 6;
         mCol.FieldName := 'StoreSubBatchQuantity';
         mCol.Caption := 'On store';
         mCol.Name := 'StoreSubBatchQuantity_'+IntToStr(i);
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