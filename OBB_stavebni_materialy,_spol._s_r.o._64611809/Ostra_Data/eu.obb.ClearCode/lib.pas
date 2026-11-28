procedure ClearSpaces (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList:TStringList;
 mBO:TNxCustomBusinessObject;
 i, j:Integer;
begin
  mList:=TStringList.Create;
  OS.SQLSelect('Select id from Suppliers',mList);
  if mList.count>0 then begin
     mBO:=Os.CreateObject(Class_Supplier);
     for i:=0 to mlist.Count-1 do begin
       mBO.Load(mlist.Strings[i],nil);
       if NxRight(mbo.GetFieldValueAsString('ExternalNumber'),1)=' ' then j:=j+1;
       mbo.SetFieldValueAsString('ExternalNumber',TrimRight(mbo.GetFieldValueAsString('ExternalNumber')));
       mbo.SetFieldValueAsString('ExternalNumber',NxSearchReplace(mbo.GetFieldValueAsString('ExternalNumber'),Chr(13),'',[srAll]));
       mbo.SetFieldValueAsString('ExternalNumber',NxSearchReplace(mbo.GetFieldValueAsString('ExternalNumber'),Chr(10),'',[srAll]));
       if mBO.NeedSave then mbo.save;
     end;
     mbo.free;
  end;
  Success := True;
  LogInfoStr := 'Opravil jsem '+IntToStr(j)+ ' záznamů';
  mList.free;
end;

begin
end.