uses
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_FuncJSON',
  'REST_SkladTerm_Special.U_StandardHooks',
  'StandardUnits.U_GetId';

procedure printRow(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mUser_Id, mModule, mDocType: String;
  json: TJSONSuperObject;
begin
  json := nil;
  LogWriteSectionStart('printRow');

  mUser_Id := getHeaderValue(ARequest, 'UserID');
  mModule := getHeaderValue(ARequest,'ModuleCode');
  mDocType := getHeaderValue(ARequest, 'DocumentType');

  json := TJSONSuperObject.ParseString(REST_ByteUTF82String(ARequest.Content.Content), True);
  try
    Self.ObjectSpace.StartTransaction(taReadCommited);
    try
      PrintRowFunction(Self.ObjectSpace, mModule, mDocType, mUser_Id, json);

      HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, PlainResponse(''));
      Self.ObjectSpace.Commit;
      LogWriteSectionEnd;
    except
      ErrREST(ARequest, AResponse, HTTP_SC_NotFound, ExceptionMessage);
      Self.ObjectSpace.RollBack;
      LogWriteSectionEnd;
    end;
  finally
    json.Free;
  end;
end;

procedure putLabelDefinitions(Self: TNxWebServicesHelper; ARequest: TNxHTTPRequest;
  AResponse: TNxHTTPResponse; slPath: TStringList);
var
  mLabelDefinitions: TMemTable;
  json, jsonIn: TJSONSuperObject;
  mSC: TNxCustomBusinessObject;
  mUser_Id, mModule, mDocType, mStoreCard_ID, mLabelDefinitions_IDs, mSql, mLabel, mNewLabel,
   mFieldName: String;
  mLeftPos, mRightPos: Integer;
begin
  json := nil;
  jsonIn := nil;

  if (slPath.Count = 2) then
  begin
    mStoreCard_ID := slPath.Strings[1];
  end else
  begin
    ErrREST(ARequest, AResponse, HTTP_SC_BadRequest, getString('error_wrong_parameters_count'));
    exit;
  end;

  LogWriteSectionStart('getLabelDefinitions');

  mUser_Id := getHeaderValue(ARequest, 'UserID');
  mModule := getHeaderValue(ARequest,'ModuleCode');
  mDocType := getHeaderValue(ARequest, 'DocumentType');

  jsonIn := TJSONSuperObject.ParseString(REST_ByteUTF82String(ARequest.Content.Content), True);
  mLabelDefinitions := TMemTable.Create(nil);
  try
    mSql :=
      'select' + nxCrLf +
      '  X_LabelDefinition' + nxCrLf +
      'from StoreCards SC' + nxCrLf +
      'where' + nxCrLf +
      '  SC.ID = ' + QuotedStr(mStoreCard_ID);
    mLabelDefinitions_IDs := SQLSelectStr(Self.ObjectSpace, mSql);

    if mLabelDefinitions_IDs = '' then
    begin
      RaiseException('Pro tento artikl nebyla nalezena žádná definice štítku');
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
    Self.ObjectSpace.SQLSelect2(mSql, mLabelDefinitions);

    if mLabelDefinitions.Active then
    begin
      mSC := Self.ObjectSpace.CreateObject(Class_StoreCard);
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
          mNewLabel := PrintLabelCustomReplace(Self.ObjectSpace, mModule, mDocType, mUser_ID, mStoreCard_ID, mLabelDefinitions.FieldByName('ID').AsString,
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

    HTTPResponse(AResponse, HTTP_SC_OK, ContentType_JSON, json.AsJson(false, true));
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