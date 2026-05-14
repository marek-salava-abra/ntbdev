procedure My_OnGetColumnReadOnly(Sender: TNxMultiGridCustomColumn; var AReadOnly: Boolean);
begin
   if (Sender.Name = 'IO_FirmName') then AReadOnly:= True;
end;

procedure My_OnCalcFields(DataSet: TDataSet);
var
   A,CurrRate: Double;
   mFirmName: String;
begin


  if DataSet.FieldByName('RowType').AsInteger = 3 then begin
    try
      mFirmName:=GetFirmName(DataSet.Site.BaseObjectSpace,TNxRowsObjectDataSet(DataSet).ActiveObject.OID);
      DataSet.FieldByName('IO_FirmName').AsString:= mFirmName;
    finally

    end;
  end;
end;

function GetFirmName(AOS : TNxCustomObjectSpace; aRow_ID: string) : String;
const
  cSQL = 'SELECT F.Name FROM ReceivedOrdersToIssuedOrders A  left JOIN ReceivedOrders RO ON RO.ID = A.SourceHeader_ID '+
         'left join firms f on f.id=Ro.firm_id '+
         ' WHERE A.Target_ID = ''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aRow_ID]), mList);
    //NxShowSimpleMessage(Format(cSQL, [aRow_ID]),nil);
    if mList.Count > 0 then
      Result := (mList.Strings[0])
      else Result:='';
  finally
    mList.Free;
  end;
end;

{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}

procedure InitSite_Hook(Self: TSiteForm);
var
   mFieldDef: TFieldDef;
   mField: TFIeld;
   mDataSet: TDataSet;
   grdRows: TMultiGrid;
   mCol: TNxMultiGridColumn;
   mColR: TNxMultiGridRollColumn;
   pnAssortmentDiscountsNav: TPanel;
   mColC: TNxMultiGridCustomColumn;
   i: Integer;
begin
   grdRows:= TMultiGrid(Self.FindChildControl('grdRows'));

   if Assigned(grdRows) then
   begin
    grdRows.OnGetColumnReadOnly:= @My_OnGetColumnReadOnly;

    // Výpočtový sloupec
    mDataSet:= grdRows.DataSource.DataSet;
    mDataSet.OnCalcFields:= @My_OnCalcFields;

        mFieldDef:= TFieldDef.Create(mDataSet.FieldDefs, 'IO_FirmName', ftString, 100, False, 300001);
    with mFieldDef.CreateField(mDataSet, nil, 'IO_FirmName', False) do
    begin
       FieldKind:= fkCalculated;
       FieldName:= 'IO_FirmName';
       //Alignment:= taRightJustify;
    end;

    mCol := TNxMultiGridColumn.Create(grdRows);
    mCol.Layout:= 3;
    mCol.Line:= 1;
    mCol.Order := 12;
    mCol.FieldName := 'IO_FirmName';
    mCol.Caption := 'pro firmu';
    mCol.Name := 'IO_FirmName';
    mCol.Width := 390;
    mCol.Elastic:= False;
    grdRows.InsertColumn(mCol);
   end;


   grdRows.ColumnByName('IO_FirmName').Order:= 12; // T. Sleva

end;

begin
end.
