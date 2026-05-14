uses
  'StandardUnits.U_GetId';

function Request_Start(AOS: TNxCustomObjectSpace; ARequestID, AScenarioType: String): Integer;
begin
  if NxIsBlank(ARequestID) then
  begin
    Result := 0;
    exit;
  end;
  Result := SQLSelectInt(AOS, 'select State from REST_Requests where Request_ID = ' + QuotedStr(ARequestID));
  if Result = 0 then
  begin
    // MSSQL se neumi poprat s dolarem v nazvu, takze musim dat sloupec do uvozovek. FB a Oraclu se ale zase nelibi uvozovky
    // (protoze pak se ocekava presny nazev sloupce
    if DB_TYPE in [0, 2, 3, 4] then
    begin
      AOS.SQLExecute('insert into REST_Requests (Request_ID, State, ScenarioType, Start$DATE, End$DATE) values (' +
        QuotedStr(ARequestID) + ', 1, ' + QuotedStr(AScenarioType) + ', ' + NxFloatToIBStr(Now) + ', 0)');
    end
    else
    begin
      AOS.SQLExecute('insert into REST_Requests (Request_ID, State, ScenarioType, "Start$DATE", "End$DATE") values (' +
        QuotedStr(ARequestID) + ', 1, ' + QuotedStr(AScenarioType) + ', ' + NxFloatToIBStr(Now) + ', 0)');
    end;
  end;
end;

procedure Request_Finish(AOS: TNxCustomObjectSpace; ARequestID: String);
begin
  // MSSQL se neumi poprat s dolarem v nazvu, takze musim dat sloupec do uvozovek. FB se ale zase nelibi uvozovky
  // (protoze pak se ocekava presny nazev sloupce
  if DB_TYPE in [0, 2, 3, 4] then
  begin
    AOS.SQLExecute('update REST_Requests set State = 2, End$DATE = ' + NxFloatToIBStr(Now) + ' ' +
      'where Request_ID = ' + QuotedStr(ARequestID));
  end
  else
  begin
    AOS.SQLExecute('update REST_Requests set State = 2, "End$DATE" = ' + NxFloatToIBStr(Now) + ' ' +
      'where Request_ID = ' + QuotedStr(ARequestID));
  end;
end;

procedure Request_Cancel(AOS: TNxCustomObjectSpace; ARequestID: String);
begin
  AOS.SQLExecute('delete from REST_Requests ' +
    'where Request_ID = ' + QuotedStr(ARequestID));
end;

begin
end.