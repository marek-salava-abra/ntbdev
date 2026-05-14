
{GetData}

function GetData(AReportHelper:TNxQRScriptHelper;EncodedData:String):String;
var
 mList:TStringList;
 i:integer;
begin
  Result:='';
  try
    mList:=TStringList.create;
    mList.Text:=TEncoding.ASCII.GetString(DecodeBase64(EncodedData));
    {for i:=0 to mlist.count-1 do begin
     NxShowSimpleMessage(''+mlist.strings[i],nil);
    end; }
    if NxCharPos(' ',copy(mlist.strings[mList.count-1],0,10))>0 then exit;
    if NxCharPos(#39,copy(mlist.strings[mList.count-1],0,10))>0 then exit;
    if not(NxIsEmptyOID(copy(mlist.strings[mList.count-1],0,10))) then
    Result:=copy(mlist.strings[mList.count-1],0,10);
  except

  end;
end;

begin
end.