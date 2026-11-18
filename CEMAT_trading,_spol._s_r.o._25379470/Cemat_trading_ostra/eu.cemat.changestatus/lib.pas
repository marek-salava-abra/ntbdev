procedure ChangeRO(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList:TStringList;
 i:integer;
 mIDI:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
begin
  mList:=TStringList.Create;
  os.SQLSelect(Format('SELECT ID FROM ReceivedOrders A WHERE '+
                      ' (exists (SELECT 1 FROM USERDATA WHERE FIELDCODE=2000010 AND CLSID='+Quotedstr('01CPMINJW3DL342X01C0CX3FCC')+' AND ID = A.ID AND (  ( STRINGFIELDVALUE = '+quotedstr('0')+' )'+
                      '))) AND (exists (SELECT 1 FROM USERDATA WHERE FIELDCODE=2000031 AND CLSID='+Quotedstr('01CPMINJW3DL342X01C0CX3FCC')+' AND ID = A.ID AND (CAST(STRINGFIELDVALUE AS NUMERIC(18,10)) < %s)))',[NxSearchReplace(FloatToStr(Now),',','.',[srall])]),mList);
  for i:=0 to mlist.count-1 do begin
     { mIDI:=OS.CreateObject(Class_ReceivedOrder);
      mIDI.load(mlist.strings[i],nil);

      midi.SetFieldValueAsInteger('U_stav',2);
      midi.save;
      midi.free; }

  end;

  Success := True;
  LogInfoStr := NxSearchReplace(FloatToStr(Now),',','.',[srall])+' '+ mlist.DelimitedText;
end;

begin
end.