procedure GenerateIIfromOPV(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList, mLogs:TStringList;
 mSQL: String;
 i:integer;
 //email do kopie Marek.zizka a tvůrce
begin
  mList := TStringList.Create;
  mLogs := TStringList.Create;
  mSQL:= 'SELECT RO.ID'#13#10 +
    'FROM ReceivedOrders RO'#13#10 +
    'WHERE RO.DocQueue_ID = ''7RQ0000101'''#13#10 +
    '  AND RO.PMState_ID = ''2080000101'''#13#10 +
    '  AND RO.Revided_ID IS NULL'#13#10 +
    '  AND RO.X_BoolForAutoInvoice=''A'''#13#10 +
    '  AND EXISTS ('#13#10 +
    '    SELECT 1'#13#10 +
    '    FROM StoreDocuments2 SD2'#13#10 +
    '    JOIN StoreDocuments SD ON SD.ID = SD2.Parent_ID'#13#10 +
    '    WHERE SD2.Provide_ID = RO.ID'#13#10 +
    '      AND SD.DocumentType = ''21'''#13#10 +
    '      AND SD.DocQueue_ID IN (''1100000101'', ''U200000101'')'#13#10 +
    '      AND SD.Finished = ''N'''#13#10 +
    '      AND SD.IsAvailableForDelivery = ''A'''#13#10 +
    '  )';
  try
    OS.sqlselect(mSQL, mList);
    if mList.Count > 0 then begin
      
    end;
  finally
   Success := True;
   LogInfoStr := ''+nxcrlf+mlogs.Text;
  end; 
end;

begin
end.