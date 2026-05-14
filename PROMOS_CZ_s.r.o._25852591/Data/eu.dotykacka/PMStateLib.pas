procedure ChangePMState (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList:tstringlist;
 mBO:TNxCustomBusinessObject;
 i:integer;
begin
  mList:=tstringlist.Create;
  os.SQLSelect('SELECT a.id FROM StoreDocuments A LEFT JOIN SYS$StoreDocuments3 SD3 ON SD3.StoreDocument_ID=A.ID '+
               'WHERE A.DocumentType=''21'' AND (((''N'' = ''A'') AND ((A.Finished = ''N'') AND (A.IsAvailableForDelivery = ''A''))) OR ((''N'' = ''N'') AND ((A.Finished = ''A'') OR (A.IsAvailAbleForDelivery = ''N''))) )  '+
               ' AND (A.PMState_ID = ''2000000001'' ) ',mList);
  if mlist.count>0 then begin
   for i:=0 to mlist.count-1 do begin
    mBO:=OS.CreateObject(Class_BillOfDelivery);
    mBO.Load(mlist.strings[i],nil);
    mbo.PMChangeState('SDDEF00000');
    mbo.free;
   end;
  end;
  Success := True;
  LogInfoStr := '';
end;

begin
end.