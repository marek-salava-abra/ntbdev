procedure ChangeState (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList:TStringList;
 mBO:TNxCustomBusinessObject;
 i:integer;
 mMessage:string;
begin
 try
  mList:=TStringList.Create;
  os.SQLSelect(format('SELECT ID FROM ReceivedOrders A '+
                      'WHERE (exists (SELECT 1 FROM USERDATA WHERE FIELDCODE=2000010 AND CLSID=''01CPMINJW3DL342X01C0CX3FCC'' AND ID = A.ID AND (  ( STRINGFIELDVALUE = ''0'' ) '+
                      ')) OR not exists(SELECT 1 FROM USERDATA WHERE FIELDCODE=2000010 AND CLSID=''01CPMINJW3DL342X01C0CX3FCC'' AND ID = A.ID)) AND (exists (SELECT 1 FROM USERDATA WHERE FIELDCODE=2000031 AND CLSID=''01CPMINJW3DL342X01C0CX3FCC'' AND ID = A.ID AND '+
                      '(CAST(STRINGFIELDVALUE AS NUMERIC(18,10)) < %s ))) ',[NxSearchReplace(FloatToStr(Now),',','.',[srall])]),mlist);
  for i:=0 to mlist.count-1 do begin
     mbo:=os.CreateObject(Class_ReceivedOrder);
     mbo.Load(mlist.strings[i],nil);
     if mbo.GetFieldValueAsDateTime('U_Datum_fakturace')>10 then begin
       mbo.SetFieldValueAsInteger('U_stav',2);
       mbo.save;
       mbo.free;
     end;


  end;
  Success := True;
  mMessage := format('SELECT ID FROM ReceivedOrders A '+
                      'WHERE (exists (SELECT 1 FROM USERDATA WHERE FIELDCODE=2000010 AND CLSID=''01CPMINJW3DL342X01C0CX3FCC'' AND ID = A.ID AND (  ( STRINGFIELDVALUE = ''0'' ) '+
                      ')) OR not exists(SELECT 1 FROM USERDATA WHERE FIELDCODE=2000010 AND CLSID=''01CPMINJW3DL342X01C0CX3FCC'' AND ID = A.ID)) AND (exists (SELECT 1 FROM USERDATA WHERE FIELDCODE=2000031 AND CLSID=''01CPMINJW3DL342X01C0CX3FCC'' AND ID = A.ID AND '+
                      '(CAST(STRINGFIELDVALUE AS NUMERIC(18,10)) < %s ))) ',[NxSearchReplace(FloatToStr(Now),',','.',[srall])]);
  LogInfoStr:=mMessage;
  except

   LogInfoStr:=ExceptionMessage+#13#10+mMessage;
  end;

end;

begin
end.