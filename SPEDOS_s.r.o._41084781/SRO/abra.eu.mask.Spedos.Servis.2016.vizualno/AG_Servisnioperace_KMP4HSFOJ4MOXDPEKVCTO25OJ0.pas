

procedure _InitSelf_PostHook(Self: TSiteForm);

var
  mDBG: TDBGrid;
  mDTform:TForm;
  mDataSet: TDataset;
  mFieldDef : TFieldDef;
  mField: TField;
begin
  mDBG := TDBGrid(NxFindChildControl(Self.GetSiteAppForm, 'grdRows'));
  if Assigned(mDBG) then begin
      mDataSet:= TDBGrid(mDBG).DataSource.DataSet;
      if assigned(mDataSet) then begin
              mDataSet.FieldDefs.Add('X_Volba',ftBoolean,0);


              // Pohotovost
              mFieldDef:= TFieldDef.Create(mDataSet.FieldDefs, 'X_Volby', ftBoolean, 0, True, 300008);
              with mFieldDef.CreateField(mDataSet, nil, 'X_Volby', False) do
              begin
                FieldKind:= fkData;
                FieldName:= 'X_Volby';
              end;
              with mDBG.Columns.Add do begin
              Expanded := False;
              FieldName := 'X_Volby';
              ReadOnly := False;
              Title.Caption := 'Volba';
              Width := 50;
              Visible := True;
            end;

            mDataSet.FieldDefs.Add('X_Volitelna',ftBoolean,0);


              // Pohotovost
              mFieldDef:= TFieldDef.Create(mDataSet.FieldDefs, 'X_Volitelna', ftBoolean, 0, True, 300009);
              with mFieldDef.CreateField(mDataSet, nil, 'X_Volitelna', False) do
              begin
                FieldKind:= fkData;
                FieldName:= 'X_Volitelna';
              end;
              with mDBG.Columns.Add do begin
              Expanded := False;
              FieldName := 'X_Volitelna';
              ReadOnly := False;
              Title.Caption := 'Volitelná';
              Width := 50;
              Visible := True;
            end;


        end;

    {          if assigned(mDataSet) then begin
              mDataSet.FieldDefs.Add('Storecard_id.code',ftString,0);


              // Pohotovost
              mFieldDef:= TFieldDef.Create(mDataSet.FieldDefs, 'Storecard_id.code', ftString, 0, True, 300008);
              with mFieldDef.CreateField(mDataSet, nil, 'Storecard_id.code', False) do
              begin
                FieldKind:= fkData;
                FieldName:= 'Storecard_id.code';
              end;
              with mDBG.Columns.Add do begin
              Expanded := False;
              FieldName := 'Storecard_id.code';
              ReadOnly := False;
              Title.Caption := 'Kód skladové karty';
              Width := 50;
              Visible := True;
            end;
        end;   }
   end;
    mDBG.Refresh;
end;






begin
end.