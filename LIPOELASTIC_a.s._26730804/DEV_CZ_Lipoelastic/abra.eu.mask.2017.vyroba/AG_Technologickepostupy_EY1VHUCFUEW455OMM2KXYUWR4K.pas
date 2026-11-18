{procedure _InitSelf_PostHook(Self: TSiteForm);
var
  mMG: TMultiGrid;
  mFieldDef: TFieldDef;
  i, mLayout, mLine, mOrder: Integer;
  mMGCol, mMGColJednotka,mMGColVychystano,mMGColDeliveredQuantity,mMGColTAmountWithoutVAT,mMGColRowDiscount,mMGColTAmount: TNxMultiGridColumn;
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
      if mMG.Columns[i].FieldName = 'X_Operation_ID' then
        b := False;
        if b then begin
          mFieldDef := TFieldDef.Create(mMG.DataSource.DataSet.FieldDefs, 'X_Operation_ID', ftWideString, 0, False, 049);
          with mFieldDef.CreateField(mMG.DataSource.DataSet, nil, 'X_Operation_ID', False) do begin
            ReadOnly:= False;
            FieldName:= 'X_Operation_ID';
            FieldKind:= fkData;
          end;
      iPreparePosition(1, 0, 9);
      mMGColRoll:= (TNxMultiGridObjectRollColumn.Create(mMG.Owner));
      mMGColRoll.FieldName := 'X_Operation_ID';
      mMGColRoll.Caption := '#Operation_ID';
      mMGColRoll.ReadOnly := False;
      mMGColRoll.Kind := ckText;
      mMGColRoll.Elastic := false;
      mMGColRoll.Width := 70;
      mMGColRoll.Layout := 1;
      mMGColRoll.Line := 1;
      mMGColRoll.Order := 9;
      mMGColRoll.Kind := ckUser;
      mMGColRoll.ClassID:=('0GU00KYDU4B4J44OOHBN30NGYO');
      mMGColRoll.TextField:='Name';
      mMG.AddColumn(mMGColRoll);
    end;
    if Assigned(mMG) then begin
        b := True;
        for i:=mMG.ColumnCount-1 downto 0 do
          if mMG.Columns[i].FieldName = 'X_Operation_ID' then
                  b := False;
              if b then begin
                mFieldDef := TFieldDef.Create(mMG.DataSource.DataSet.FieldDefs, 'X_Operation_ID', ftWideString, 0, False, 050);
                with mFieldDef.CreateField(mMG.DataSource.DataSet, nil, 'X_Operation_ID', False) do begin
                  ReadOnly:= False;
                  FieldName:= 'X_Operation_ID';
                  FieldKind:= fkData;
                end;
                iPreparePosition(1, 1, 8);
                mMGColJednotka:= TNxMultiGridColumn.Create(mMG.Owner);
                mMGColJednotka.FieldName := 'X_Operation_ID';
                mMGColJednotka.Caption := '#X_Operation_ID';
                mMGColJednotka.ReadOnly := False;
                mMGColJednotka.Kind := ckText;
                mMGColJednotka.Elastic := false;
                mMGColJednotka.Width := 70;
                mMGColJednotka.Layout := 3;
                mMGColJednotka.Line := 1;
                mMGColJednotka.Order := 80;
                mMG.AddColumn(mMGColJednotka);
          end;


    end;





 end;
end;

      }


begin
end.





