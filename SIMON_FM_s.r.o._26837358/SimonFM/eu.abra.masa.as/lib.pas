procedure RemoveNew(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mLogs, mList:TStringList;
 i:integer;
 mBO, mHistoryBO:TNxCustomBusinessObject;
begin
  mList:=TStringList.Create;
  mLogs:=TStringList.Create;
  mLogs.Add(DateTimeToStr(Now)+' Začátek');
  OS.SQLSelect('SELECT first 10 h1.id'#13#10 +
                'FROM historydata h1'#13#10 +
                'WHERE h1.fieldcode = 900020 '#13#10 +
                '  AND h1.clsid = ''C3V5QDVZ5BDL342M01C0CX3FCC'''#13#10 +
                '  AND h1.stringfieldvalue = ''A'''#13#10 +
                #13#10 +
                '  AND h1.validfrom$date <= '+NxFloatToIBStr(Date-60) +
                '  AND NOT EXISTS ('#13#10 +
                '      SELECT 1 '#13#10 +
                '      FROM historydata h2'#13#10 +
                '      WHERE h2.fieldcode = h1.fieldcode'#13#10 +
                '        AND h2.clsid = h1.clsid'#13#10 +
                '        AND h2.id = h1.id'#13#10 +
                '        AND h2.stringfieldvalue = ''N'''#13#10 +
                '        AND h2.validfrom$date > h1.validfrom$date'#13#10 +
                '  )', mList);
  if mList.count>0 then begin
    mLogs.Add('SELECT first 10 h1.id'#13#10 +
                'FROM historydata h1'#13#10 +
                'WHERE h1.fieldcode = 900020 '#13#10 +
                '  AND h1.clsid = ''C3V5QDVZ5BDL342M01C0CX3FCC'''#13#10 +
                '  AND h1.stringfieldvalue = ''A'''#13#10 +
                #13#10 +
                '  AND h1.validfrom$date <= '+NxFloatToIBStr(Date-60) +
                '  AND NOT EXISTS ('#13#10 +
                '      SELECT 1 '#13#10 +
                '      FROM historydata h2'#13#10 +
                '      WHERE h2.fieldcode = h1.fieldcode'#13#10 +
                '        AND h2.clsid = h1.clsid'#13#10 +
                '        AND h2.id = h1.id'#13#10 +
                '        AND h2.stringfieldvalue = ''N'''#13#10 +
                '        AND h2.validfrom$date > h1.validfrom$date'#13#10 +
                '  )');
    mLogs.Add(DateTimeToStr(Now)+' Počet karet: '+IntToStr(mList.count));

    for i:=0 to mList.count-1 do begin
       mBO:=OS.CreateObject(Class_StoreCard);
       mBO.Load(mlist.Strings[i],nil);
       mbo.DateOfChange:=Date;
       mBO.SetFieldValueAsBoolean('X_NES_New',false);
       //mBo.SetFieldValueAsString('CustomsTariffNumber','3');
       mLogs.add(DateTimeToStr(Now)+' displayname '+mbo.DisplayName);
       mBO.save;
       if mBO.GetFieldValueAsBoolean('X_NES_New') then mLogs.Add(DateTimeToStr(Now)+' Ano') else mLogs.Add(DateTimeToStr(Now)+' Ne');
       mbo.free;

    end;

  end;
  mLogs.Add(DateTimeToStr(Now)+' Konec');
  Success := True;
  LogInfoStr := ''+NxCrLf+mLogs.text;
end;

begin
end.