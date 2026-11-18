procedure ClearReservation(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList:TStringList;
 i:integer;
 mIDI:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
begin
  mList:=TStringList.Create;
  os.SQLSelect(Format('SELECT a.ID FROM DefRollData A WHERE   A.CLSID = '+Quotedstr('11CZ0SV0RRW4PABA135VLXC3IO')+
                      ' AND (exists (SELECT ID FROM USERDATA WHERE FIELDCODE=2000008 AND CLSID='+Quotedstr('11CZ0SV0RRW4PABA135VLXC3IO')+
                      ' AND ID = A.ID AND CAST(STRINGFIELDVALUE AS NUMERIC(18,10)) >= 42736 AND CAST(STRINGFIELDVALUE AS NUMERIC(18,10)) < %s))',[NxSearchReplace(FloatToStr(Now),',','.',[srall])]),mList);
  for i:=0 to mlist.count-1 do begin
      mIDI:=OS.CreateObject('11CZ0SV0RRW4PABA135VLXC3IO');
      mIDI.load(mlist.strings[i],nil);

      midi.SetFieldValueAsDateTime('U_ReservedDateTo',0);
      midi.SetFieldValueAsDateTime('U_ReservedDateFrom',0);
      midi.save;
      midi.free;

  end;

  Success := True;
  LogInfoStr := NxSearchReplace(FloatToStr(Now),',','.',[srall])+' '+ mlist.DelimitedText;
end;

begin
end.