function RGBToColor(const R, G, B: Byte): Integer;
begin
	  Result := R or (G shl 8) or (B shl 16);
end;

procedure My_OnGetBackgroundColor(Sender : TObject; AColumn: TNxMultiGridCustomColumn; const AIndex: Integer; const AMultiSelect: Boolean; const ASelectedActiveRow: Boolean; var ABckColor: TColor);
var
   mFieldData: String;
   mDataSetRows: TDataSet;
   mCount:integer;
   mQuantity, mOtherQuantity, mOrderedQuantity:extended;
   mRowBO:TNxCustomBusinessObject;
   mIO_ID:string;
begin
   mDataSetRows:= AColumn.Grid.DataSource.DataSet;
   mRowBO:=TNxRowsObjectDataSet(mDataSetRows).ActiveObject;

     if (mDataSetRows.FieldByName('RowType').AsInteger = 3) and not(NxIsEmptyOID(mDataSetRows.FieldByName('StoreCard_ID').AsString))
      and not(NxIsEmptyOID(mDataSetRows.FieldByName('Store_ID').AsString)) then begin
      if (mRowBO.GetFieldValueAsString('Parent_ID.DocQueue_ID.Code') in ['OPES']) and not(mRowBO.GetFieldValueAsBoolean('Parent_ID.Closed')) and not(TDynSiteForm(TComponent(Sender).DynSite).edit) then begin
          mOtherQuantity:=0;
          mOrderedQuantity:=0;
          mQuantity:=AColumn.Grid.DataSource.DynSite.BaseObjectSpace.SQLSelectFirstAsExtended('Select sum(quantity) from storesubcards where storecard_id='+QuotedStr(mDataSetRows.FieldByName('StoreCard_ID').AsString)
                              +' and store_id='+QuotedStr(mDataSetRows.FieldByName('Store_ID').AsString),0);   //přičíst množství v příjmu
          mOrderedQuantity:=mRowBO.ObjectSpace.SQLSelectFirstAsExtended('Select sum(io2.quantity) from issuedorders2 io2 left join issuedorders io on io2.parent_id=io.id where io2.storecard_id='
                                                                          +QuotedStr(mDataSetRows.FieldByName('StoreCard_ID').AsString)+
                                                                        ' and io2.store_id='+QuotedStr(mDataSetRows.FieldByName('Store_ID').AsString)+
                                                                        ' and io.closed=''N'' and io.issued=''A'' ',0);
          if mRowBO.GetFieldValueAsString('Store_ID')='4P00000101' then
            mOtherQuantity:=mRowBO.ObjectSpace.SQLSelectFirstAsExtended('Select sum(quantity) from storesubcards where storecard_id='+QuotedStr(mDataSetRows.FieldByName('StoreCard_ID').AsString)
                              +' and store_id in ('+QuotedStr('1L00000101')+','+QuotedStr('1E00000101')+','+QuotedStr('2D00000101')+')',0);
          if mRowBO.GetFieldValueAsString('Store_ID')='1L00000101' then
            mOtherQuantity:=mRowBO.ObjectSpace.SQLSelectFirstAsExtended('Select sum(quantity) from storesubcards where storecard_id='+QuotedStr(mDataSetRows.FieldByName('StoreCard_ID').AsString)
                              +' and store_id in ('+QuotedStr('4P00000101')+','+QuotedStr('1E00000101')+','+QuotedStr('2D00000101')+')',0);
          if mQuantity<mRowBO.GetFieldValueAsFloat('Quantity') then ABckColor:=RGBToColor(255,102,102);
          if (mQuantity<mRowBO.GetFieldValueAsFloat('Quantity')) and (mOrderedQuantity>=mRowBO.GetFieldValueAsFloat('Quantity')) then ABckColor:=RGBToColor(255,179,102);
          if (mQuantity<mRowBO.GetFieldValueAsFloat('Quantity')) and (mOtherQuantity>0) and not(mOrderedQuantity>=mRowBO.GetFieldValueAsFloat('Quantity')) then ABckColor:=RGBToColor(102,255,255);

     end;
     if (mRowBO.GetFieldValueAsString('Parent_ID.DocQueue_ID.Code') in ['OPV']) and not(mRowBO.GetFieldValueAsBoolean('Parent_ID.Closed')) and not(TDynSiteForm(TComponent(Sender).DynSite).edit) then begin
          mOtherQuantity:=0;
          mOrderedQuantity:=0;
          mQuantity:=AColumn.Grid.DataSource.DynSite.BaseObjectSpace.SQLSelectFirstAsExtended('Select sum(quantity) from storesubcards where storecard_id='+QuotedStr(mDataSetRows.FieldByName('StoreCard_ID').AsString)
                              +' and store_id='+QuotedStr(mDataSetRows.FieldByName('Store_ID').AsString),0);
          if mQuantity<mRowBO.GetFieldValueAsFloat('Quantity') then begin
           ABckColor:=RGBToColor(255,102,102);
           mOtherQuantity:=mRowBO.ObjectSpace.SQLSelectFirstAsExtended('Select sum(quantity) from storesubcards where storecard_id='+QuotedStr(mDataSetRows.FieldByName('StoreCard_ID').AsString)
                              +' and store_id in ('+QuotedStr('1L00000101')+','+QuotedStr('1E00000101')+','+QuotedStr('2D00000101')+')',0);
           mOrderedQuantity:=mRowBO.ObjectSpace.SQLSelectFirstAsExtended('Select sum(io2.quantity) from issuedorders2 io2 left join issuedorders io on io.id=io2.parent_id where io2.storecard_id='
                                                                          +QuotedStr(mDataSetRows.FieldByName('StoreCard_ID').AsString)+
                                                                        ' and io2.store_id='+QuotedStr(mDataSetRows.FieldByName('Store_ID').AsString)+
                                                                        ' and io.closed=''N'' ',0);
           if (mQuantity<mRowBO.GetFieldValueAsFloat('Quantity')) and (mOtherQuantity>0) and not(mOrderedQuantity>=mRowBO.GetFieldValueAsFloat('Quantity')) then ABckColor:=RGBToColor(102,255,255)
           else
           if (mQuantity<mRowBO.GetFieldValueAsFloat('Quantity')) and (mOrderedQuantity>=mRowBO.GetFieldValueAsFloat('Quantity')) then begin
              ABckColor:=RGBToColor(255,179,102);
           end;
          end;
          {zakomentováno dne 05.09.2025

          if mQuantity<mRowBO.GetFieldValueAsFloat('Quantity') then begin
            ABckColor:=RGBToColor(255,102,102);
            mOrderedQuantity:=mRowBO.ObjectSpace.SQLSelectFirstAsExtended('Select sum(io2.quantity) from issuedorders2 io2 left join issuedorders io on io.id=io2.parent_id where io2.storecard_id='
                                                                          +QuotedStr(mDataSetRows.FieldByName('StoreCard_ID').AsString)+
                                                                        ' and io2.store_id='+QuotedStr(mDataSetRows.FieldByName('Store_ID').AsString)+
                                                                        ' and io.closed=''N'' and io.issued=''A'' ',0);
            if (mQuantity<mRowBO.GetFieldValueAsFloat('Quantity')) and (mOrderedQuantity>=mRowBO.GetFieldValueAsFloat('Quantity')) then begin
              ABckColor:=RGBToColor(255,179,102);
              if mRowBO.GetFieldValueAsString('Store_ID')='4P00000101' then
               mOtherQuantity:=mRowBO.ObjectSpace.SQLSelectFirstAsExtended('Select sum(quantity) from storesubcards where storecard_id='+QuotedStr(mDataSetRows.FieldByName('StoreCard_ID').AsString)
                              +' and store_id in ('+QuotedStr('1L00000101')+','+QuotedStr('1E00000101')+','+QuotedStr('2D00000101')+')',0);
              if (mQuantity<mRowBO.GetFieldValueAsFloat('Quantity')) and (mOtherQuantity>0) and not(mOrderedQuantity>=mRowBO.GetFieldValueAsFloat('Quantity')) then ABckColor:=RGBToColor(102,255,255);

            end;
          end; }
     end;
   end;
end;




{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
   grdRows: TMultiGrid;
   mFieldDef: TFieldDef;
   mField: TFIeld;
   mDataSet: TDataSet;
   mCol: TNxMultiGridColumn;
   i: Integer;
begin
   grdRows:= TMultiGrid(Self.FindChildControl('grdRows'));
   if Assigned(grdRows) then
   begin
     if not(TDynSiteForm(self).Edit) then
      grdRows.OnGetBackgroundColor:= @My_OnGetBackgroundColor;
   end;
end;

begin
end.