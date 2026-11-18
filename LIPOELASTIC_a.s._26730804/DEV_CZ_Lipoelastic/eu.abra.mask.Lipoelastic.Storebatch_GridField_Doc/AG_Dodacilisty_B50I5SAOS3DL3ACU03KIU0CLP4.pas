procedure _InitSelf_PostHook(Self: TSiteForm);
var
  mMG: TMultiGrid;
  mFieldDef: TFieldDef;
  i, mLayout, mLine, mOrder: Integer;
  mMGCol, mMGColJednotka,mMGColVychystano,mMGColDeliveredQuantity: TNxMultiGridColumn;
  mMGColRoll: TNxMultiGridObjectRollColumn;
  b: Boolean;

  procedure iPreparePosition(ALayout, ALine, ARequestPosition: Integer);
  var
    ii: Integer;
  begin
    for ii:=mMG.ColumnCount-1 downto 0 do
      if (mMG.Columns[ii].Layout = ALayout) and (mMG.Columns[ii].Line = ALine) and
        (mMG.Columns[ii].Order >= ARequestPosition) then
        mMG.Columns[ii].Order := mMG.Columns[ii].Order + 1;
  end;

begin
  mMG := TMultiGrid(NxFindChildControl(Self.GetSiteAppForm, 'grdRows'));
  if Assigned(mMG) then begin
    b := True;
    for i:=mMG.ColumnCount-1 downto 0 do
      if mMG.Columns[i].FieldName = 'X_specifikace_id' then
        b := False;
        if b then begin
          mFieldDef := TFieldDef.Create(mMG.DataSource.DataSet.FieldDefs, 'X_specifikace_id', ftWideString, 0, False, 049);
          with mFieldDef.CreateField(mMG.DataSource.DataSet, nil, 'X_specifikace_id', False) do begin
            ReadOnly:= False;
            FieldName:= 'X_specifikace_id';
            FieldKind:= fkData;
          end;
      iPreparePosition(3, 0, 85);
      mMGColRoll:= (TNxMultiGridObjectRollColumn.Create(mMG.Owner));
      mMGColRoll.FieldName := 'X_specifikace_id';
      mMGColRoll.Caption := '#Specifikace';
      mMGColRoll.ReadOnly := False;
      mMGColRoll.Kind := ckText;
      mMGColRoll.Elastic := false;
      mMGColRoll.Width := 70;
      mMGColRoll.Layout := 3;
      mMGColRoll.Line := 0;
      mMGColRoll.Order := 85;
      mMGColRoll.Kind := ckUser;
      mMGColRoll.ClassID:=('IBGRYEM5IROOPEEER2TDCGTCKC');
      mMGColRoll.TextField:='Name';
      mMG.AddColumn(mMGColRoll);
    end;
    if Assigned(mMG) then begin
        b := True;
        for i:=mMG.ColumnCount-1 downto 0 do
          if mMG.Columns[i].FieldName = 'X_ExternalSpecification' then
                  b := False;
              if b then begin
                mFieldDef := TFieldDef.Create(mMG.DataSource.DataSet.FieldDefs, 'X_ExternalSpecification', ftWideString, 0, False, 050);
                with mFieldDef.CreateField(mMG.DataSource.DataSet, nil, 'X_ExternalSpecification', False) do begin
                  ReadOnly:= False;
                  FieldName:= 'X_ExternalSpecification';
                  FieldKind:= fkData;
                end;
                iPreparePosition(3, 0, 54);
                mMGColJednotka:= TNxMultiGridColumn.Create(mMG.Owner);
                mMGColJednotka.FieldName := 'X_ExternalSpecification';
                mMGColJednotka.Caption := '#Specifikace';
                mMGColJednotka.ReadOnly := False;
                mMGColJednotka.Kind := ckText;
                mMGColJednotka.Elastic := false;
                mMGColJednotka.Width := 70;
                mMGColJednotka.Layout := 3;
                mMGColJednotka.Line := 0;
                mMGColJednotka.Order := 80;
                mMG.AddColumn(mMGColJednotka);
              end;


    end;
 end;
end;


procedure mMG_OnGetCellFontProps(Sender : TObject; var AActColumn: TNxMultiGridCustomColumn; var AFont : TFont);
begin
  if ((AActColumn.FieldName = 'DealerDiscount') or (AActColumn.FieldName = 'X_ExternalSpecification')) then begin
    AFont.Style := [fsBold];
    AFont.Color := clRed;
  end
  else
    AFont.Style := 0;
end;

begin
end.