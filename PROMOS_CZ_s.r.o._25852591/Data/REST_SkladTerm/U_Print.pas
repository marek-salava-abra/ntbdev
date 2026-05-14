uses
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_FuncJSON',
  'REST_SkladTerm_Special.U_StandardHooks',
  'StandardUnits.U_GetId';

procedure printRow(AOS: TNxCustomObjectSpace; ABody: String; AResponse: TStringList);
var
  json: TJSONSuperObject;
begin
  json := nil;
  LogWriteSectionStart('printRow');

  json := TJSONSuperObject.ParseString(ABody, True);
  try
    AOS.StartTransaction(taReadCommited);
    try
      PrintRowFunction(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, json);

      SetResponse(AResponse, PlainResponse(''));
      AOS.Commit;
      LogWriteSectionEnd;
    except
      SetPlainResponse(AResponse, ExceptionMessage, HTTP_SC_NotFound);
      AOS.RollBack;
      LogWriteSectionEnd;
    end;
  finally
    json.Free;
  end;
end;

procedure putLabelDefinitions(AOS: TNxCustomObjectSpace; APath: TStringList; ABody: String; AResponse: TStringList);
var
  mLabelDefinitions: TMemTable;
  json, jsonIn: TJSONSuperObject;
  mSC: TNxCustomBusinessObject;
  mStoreCard_ID, mLabelDefinitions_IDs, mSql, mLabel, mNewLabel,
   mFieldName: String;
  mLeftPos, mRightPos: Integer;
begin
  json := nil;
  jsonIn := nil;

  if (APath.Count = 2) then
  begin
    mStoreCard_ID := APath.Strings[1];
  end else
  begin
    SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
    exit;
  end;

  LogWriteSectionStart('getLabelDefinitions');

  jsonIn := TJSONSuperObject.ParseString(ABody, True);
  mLabelDefinitions := TMemTable.Create(nil);
  try
    mSql :=
      'select' + nxCrLf +
      '  X_LabelDefinition' + nxCrLf +
      'from StoreCards SC' + nxCrLf +
      'where' + nxCrLf +
      '  SC.ID = ' + QuotedStr(mStoreCard_ID);
    mLabelDefinitions_IDs := SQLSelectStr(AOS, mSql);

    if mLabelDefinitions_IDs = '' then
    begin
      RaiseException(getString('error_no_definition_for_storacard'));
    end;

    mSql :=
      'select' + nxCrLf +
      '  DRD.ID as "ID",' + nxCrLf +
      '  DRD.Name as "name",' + nxCrLf +
      '  DRD.X_Definice as "definition"' + nxCrLf +
      'from DefRollData DRD' + nxCrLf +
      'where' + nxCrLf +
      '  DRD.ID in (''' + ReplaceStr(mLabelDefinitions_IDs, ';', ''',''') + ''')' + nxCrLf +
      'order by' + nxCrLf +
      '  DRD.Name';
    AOS.SQLSelect2(mSql, mLabelDefinitions);

    if mLabelDefinitions.Active then
    begin
      mSC := AOS.CreateObject(Class_StoreCard);
      try
        mSC.Load(mStoreCard_ID, nil);

        // projdu stitek a nahradim zastupne promenne promennymi z artiklu
        mLabelDefinitions.First;
        while not mLabelDefinitions.Eof do
        begin
          mLabel := mLabelDefinitions.FieldByName('definition').AsString;
          mNewLabel := '';

          mLeftPos := pos('[', mLabel);
          while pos('[', mLabel) > 0 do
          begin
            // najdu promenou
            mRightPos := pos(']', mLabel);
            mFieldName := copy(mLabel, mLeftPos + 1, mRightPos - mLeftPos - 1);

            // nahradim pole ve stitku
            if(mSC.HasField(mFieldName)) then
            begin
              // cast stitku od zacatku do promenne
              mNewLabel := mNewLabel + copy(mLabel, 1, mLeftPos - 1);
              // hodnota za promenou
              mNewLabel := mNewLabel + mSC.GetFieldValueAsString(mFieldName);
            end
            else
            begin
              // pokud na artiklu tento field neni, tak ve stitku necham promenou
              mNewLabel := mNewLabel + copy(mLabel, 1, mRightPos);
            end;

            // z puvodniho stitku smazu jiz zpracovanou cast
            mLabel := copy(mLabel, mRightPos + 1, Length(mLabel) - mRightPos);
            mLeftPos := pos('[', mLabel);
          end;

          // nahradim upravenym stitkem - navic dokopiruju konec stitku
          if mNewLabel <> '' then
          begin
            mNewLabel := mNewLabel + copy(mLabel, 1, Length(mLabel));
            mLabelDefinitions.Edit;
            mLabelDefinitions.FieldByName('definition').AsString := mNewLabel;
            mLabelDefinitions.Post;
          end;

          // vlastni nahrady promennych
          mNewLabel := PrintLabelCustomReplace(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mStoreCard_ID, mLabelDefinitions.FieldByName('ID').AsString,
            mLabelDefinitions.FieldByName('definition').AsString, jsonIn);
          mLabelDefinitions.Edit;
          mLabelDefinitions.FieldByName('definition').AsString := mNewLabel;
          mLabelDefinitions.Post;

          mLabelDefinitions.Next;
        end;
      finally
        mSC.Free;
      end;

      json := REST_jsonCreate_FromDataSet(mLabelDefinitions, nil, nil);
    end
    else begin
      json := TJSONSuperObject.CreateByDataType(jtArray);
    end;

    SetResponse(AResponse, json.AsJson(false, true));
  finally
    mLabelDefinitions.Free;
    if Assigned(json) then
      json.Free;
    if Assigned(jsonIn) then
      jsonIn.Free;
    LogWriteSectionEnd;
  end;
end;

begin
end.