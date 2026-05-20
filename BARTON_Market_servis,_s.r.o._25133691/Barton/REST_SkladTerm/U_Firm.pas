uses
  'REST_SkladTerm.U_Func',
  'REST_SkladTerm.U_FuncJSON',
  'REST_SkladTerm.U_Translation',
  'REST_SkladTerm_Special.U_StandardHooks';

// pro volani z funkci
procedure FirmInfo(AOS: TNxCustomObjectSpace; AResult: TMemTable; AModule, ADocType, AUser_ID, ABarcode: String);
var
  mSql: String;
begin
  // hlavicka firmy
  LogWriteSectionStart('FirmInfo');
  mSql :=
    'select' + nxCrLf +
    '  F.ID as "ID",' + nxCrLf +
    '  F.Code as "Code",' + nxCrLf +
    '  ' + get_FirmInfo_NameField(AOS, AModule, ADocType, AUser_ID) + ' as "Name"' + nxCrLf +
    'from Firms F' + nxCrLf +
    'where' + nxCrLf +
    '  F.ID = ' + QuotedStr(ABarcode);

  AOS.SQLSelect2(mSql, AResult);
  LogWriteSectionEnd;
end;

procedure get_FirmInfo(AOS: TNxCustomObjectSpace; APath, AResponse: TStringList);
var
  mFirm_ID, mSql, mAuxFieldsSelect: String;
  dtHeader, mAuxFieldsDataset: TMemTable;
  json, jsonAuxFields: TJSONSuperObject;
begin
  LogWriteSectionStart('get_FirmInfo');
  try
    json := nil;
    jsonAuxFields := nil;
    if (APath.Count = 2) then
    begin
      mFirm_ID := APath.Strings[1];
    end else
    begin
      SetPlainResponse(AResponse, getString('wrong_parameters_count'), HTTP_SC_BadRequest);
      exit;
    end;

    dtHeader := TMemTable.Create(nil);
    try
      // hlavicka firmy
      FirmInfo(AOS, dtHeader, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, mFirm_ID);

      if dtHeader.Active then
      begin
        dtHeader.First;
        LogWriteSectionStart('JSON');
        json := REST_jsonCreate_FromDataSetRow(dtHeader, nil, nil);
        LogWriteSectionEnd;

        LogWriteSectionStart('get_FirmInfo_AuxFields');
        mAuxFieldsDataset := TMemTable.Create(nil);
        try
          mAuxFieldsSelect := get_FirmInfo_AuxFields(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID);
          if mAuxFieldsSelect <> '' then
          begin
            mSql :=
              'select' + nxCrLf +
              '  ' + mAuxFieldsSelect + nxCrLf +
              'from Firms F' + nxCrLf +
              'where' + nxCrLf +
              '  F.ID = ' + QuotedStr(mFirm_ID);
            AOS.SQLSelect2(mSql, mAuxFieldsDataset);
            jsonAuxFields := REST_jsonCreate_FromDataSetRow(mAuxFieldsDataset, nil, nil);
            json.O['auxFields'] := jsonAuxFields;
          end;
        finally
          mAuxFieldsDataset.Free;
          LogWriteSectionEnd;
        end;

       SetResponse(AResponse, json.AsJson(false, true));
      end
      else begin
        SetPlainResponse(AResponse, Format(getString('firm_not_found'), [mFirm_ID]), HTTP_SC_NotFound);
      end;
    finally
      dtHeader.Free;
      if Assigned(json) then
        json.Free;
      if Assigned(jsonAuxFields) then
        jsonAuxFields.Free;
    end;
  finally
    LogWriteSectionEnd;
  end;
end;

function listFirms(AOS: TNxCustomObjectSpace; ASearch: String): String;
var
  mSql: String;
begin
  LogWriteSectionStart('listFirms');
  try
    mSql :=
      'select ' + FIRST_TOP(100) + NxCrLf +
      '  F.ID as "ID",' + NxCrLf +
      '  F.Code as "Code",' + NxCrLf +
      '  ' + listFirms_NameField(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID) + ' as "Name"' + NxCrLf +
      'from Firms F' + NxCrLf +
      'where' + NxCrLf +
      '  F.Hidden = ''N''' + NxCrLf +
      '  and Firm_ID is null' + NxCrLf;

    mSql := mSql +
      listFirms_Search(AOS, gSkladTermModule, gSkladTermDocType, gSkladTermUser_ID, ASearch);

    mSql := mSql + ' order by F.Code ';
    mSql := mSql + ' ' + FIRST_TOP_ORACLE(100);

    Result := mSql;
  finally
    LogWriteSectionEnd;
  end;
end;

begin
end.