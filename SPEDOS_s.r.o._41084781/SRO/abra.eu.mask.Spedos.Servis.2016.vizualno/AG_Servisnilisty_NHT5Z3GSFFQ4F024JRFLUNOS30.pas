

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAList: TActionList;
  i: integer;
  mAction: TBasicAction;
  mC: TControl;
begin
  mAList := Self.GetMainActionList;
  for i := 0 to mAList.ActionCount-1 do begin
    mAction := mALIst.Actions[i];
    // Zcela odstranime funkci Opravit
    if (mAction.Name = 'actFind') then begin
      mAction.Visible := False;
    end;
    if (mAction.Name = 'actFindNext') then begin
      mAction.Visible := False;
    end;
    if (mAction.Name = 'actCooperations') then begin
      mAction.Visible := False;
    end;
        if (mAction.Name = 'actGiveBackToClient') then begin
      mAction.Visible := False;
    end;
     if (mAction.Name = 'actGroupInvoicing') then begin
      mAction.Visible := False;
    end;
         if (mAction.Name = 'actClone') then begin
      mAction.Visible := False;
    end;
       if (mAction.Name = 'actStateChange') then begin
      mAction.Visible := False;
    end;
  end;

 // mC := Self.MainPanel.FindChildControl('rgdisplaymodeofrows');
 // if Assigned(mC) then begin
 //   TRadioGroup(mC).Visible:= false;
 // end;

end;












procedure _InitSelf_PostHook(Self: TSiteForm);

var
  mDBG: TDBGrid;
  mDTform:TForm;
  mDataSet: TDataset;
  mFieldDef : TFieldDef;
  mField: TField;
begin
  mDBG := TDBGrid(NxFindChildControl(Self.GetSiteAppForm, 'grdAssemblyForms'));
  if Assigned(mDBG) then begin
      mDataSet:= TDBGrid(mDBG).DataSource.DataSet;
      if assigned(mDataSet) then begin
            mDataSet.FieldDefs.Add('X_Protokol_prefix',ftWideString,0);
            mDataSet.FieldDefs.Add('X_Protokol',ftWideString,0);

            mDataSet.FieldDefs.Add('X_State',ftWideString,0);
            mDataSet.FieldDefs.Add('X_Pocet_cyklu', ftInteger, 0);
            mDataSet.FieldDefs.Add('X_Opravovana_cast_ID',ftWideString,0);
            mDataSet.FieldDefs.Add('X_Typ_poruchy_ID',ftWideString,0);
            mDataSet.FieldDefs.Add('X_Pricina_poruchy_ID',ftWideString,0);



                 // X_Protokol_prefix
              mFieldDef:= TFieldDef.Create(mDataSet.FieldDefs, 'X_Protokol_prefix', ftWideString, 0, True, 100001);
              with mFieldDef.CreateField(mDataSet, nil, 'X_Protokol_prefix', False) do begin
                  FieldKind:= fkData;
                  FieldName:= 'X_Protokol_prefix';
              end;
              with mDBG.Columns.Add do begin
                Expanded := False;
                FieldName := 'X_Protokol_prefix';
                ReadOnly := False;
                Title.Caption := 'Typ protokolu';
                Width := 20;
                Visible := True;
              end;

              // X_Protokol
              mFieldDef:= TFieldDef.Create(mDataSet.FieldDefs, 'X_Protokol', ftWideString, 0, True, 100002);
              with mFieldDef.CreateField(mDataSet, nil, 'X_Protokol', False) do
              begin
                FieldKind:= fkData;
                FieldName:= 'X_Protokol';
              end;
              with mDBG.Columns.Add do begin
              Expanded := False;
              FieldName := 'X_Protokol';
              ReadOnly := False;
              Title.Caption := 'Protokol';
              Width := 50;
              Visible := True;
              end;
                      // X_State
              mFieldDef:= TFieldDef.Create(mDataSet.FieldDefs, 'X_State', ftWideString, 0, True, 100003);
              with mFieldDef.CreateField(mDataSet, nil, 'X_State', False) do
              begin
                FieldKind:= fkData;
                FieldName:= 'X_State';
              end;
              with mDBG.Columns.Add do begin
              Expanded := False;
              FieldName := 'X_State';
              ReadOnly := False;
              Title.Caption := 'X_State';
              Width := 100;
              Visible := True;
              end;

               // X_Pocet_cyklu
              mFieldDef:= TFieldDef.Create(mDataSet.FieldDefs, 'X_Pocet_cyklu', ftInteger, 0, True, 100004);
              with mFieldDef.CreateField(mDataSet, nil, 'X_Pocet_cyklu', False) do
              begin
                FieldKind:= fkData;
                FieldName:= 'X_Pocet_cyklu';
              end;
              with mDBG.Columns.Add do begin
              Expanded := False;
              FieldName := 'X_Pocet_cyklu';
              ReadOnly := False;
              Title.Caption := 'Počet cyklů';
              Width := 100;
              Visible := True;
            end;


             // X_Opravovana_cast_ID
              mFieldDef:= TFieldDef.Create(mDataSet.FieldDefs, 'X_Opravovana_cast_ID', ftWideString, 0, True, 100005);
              with mFieldDef.CreateField(mDataSet, nil, 'X_Opravovana_cast_ID', False) do
              begin
                FieldKind:= fkData;
                FieldName:= 'X_Opravovana_cast_ID';
              end;
              with mDBG.Columns.Add do begin
              Expanded := False;
              FieldName := 'X_Opravovana_cast_ID';
              ReadOnly := False;
              Title.Caption := 'Opravovaná část';
              Width := 100;
              Visible := True;
              end;

                   // X_Typ_poruchy_ID
              mFieldDef:= TFieldDef.Create(mDataSet.FieldDefs, 'X_Typ_poruchy_ID', ftWideString, 0, True, 100006);
              with mFieldDef.CreateField(mDataSet, nil, 'X_Typ_poruchy_ID', False) do
              begin
                FieldKind:= fkData;
                FieldName:= 'X_Typ_poruchy_ID';
              end;
              with mDBG.Columns.Add do begin
              Expanded := False;
              FieldName := 'X_Typ_poruchy_ID';
              ReadOnly := False;
              Title.Caption := 'Typ poruchy';
              Width := 100;
              Visible := True;
              end;

                   // X_Opravovana_cast_ID
              mFieldDef:= TFieldDef.Create(mDataSet.FieldDefs, 'X_Pricina_poruchy_ID', ftWideString, 0, True, 100007);
              with mFieldDef.CreateField(mDataSet, nil, 'X_Pricina_poruchy_ID', False) do
              begin
                FieldKind:= fkData;
                FieldName:= 'X_Pricina_poruchy_ID';
              end;
              with mDBG.Columns.Add do begin
              Expanded := False;
              FieldName := 'X_Pricina_poruchy_ID';
              ReadOnly := False;
              Title.Caption := 'Příčina poruchy';
              Width := 100;
              Visible := True;
              end;



   end;
   end;

 //   mDBG.Refresh;
end;




begin
end.