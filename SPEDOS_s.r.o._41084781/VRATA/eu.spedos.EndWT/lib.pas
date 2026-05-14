procedure  EndOperation(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mListOperations, mListWorkLogs:TStringList;
 i,j:integer;
 mPLMOperation, mWLWorkLog:TNxCustomBusinessObject;
 mOPList, mWLList:TStringList;
 mDuration:Extended;
begin
  j:=0;
  mListOperations:=TStringList.Create;
  os.SQLSelect(Format('Select id from plmoperations where finishedat$date=0 and startedat$date>%s ',[IntToStr(Trunc(Date))]),mListOperations);
  if mListOperations.Count>0 then begin
   mWLList:=TStringList.create;
   mOPList:=TStringList.Create;
   for i:=0 to mListOperations.Count-1 do begin
     mPLMOperation:=os.CreateObject(Class_PLMOperation);
     mPLMOperation.Load(mListOperations.Strings[i],nil);
     mOPList.Add(mPLMOperation.GetFieldValueAsString('PerformedBy_ID.Person_ID.PersonalNumber')+' '+mPLMOperation.GetFieldValueAsString('PerformedBy_ID.Person_ID.LastName'));
     mListWorkLogs:=TStringList.Create;
     os.SQLSelect(Format('Select wl.id from wlworklogs wl left join wlworkers w on w.id=wl.worker_id where w.person_id=''%s'' and wl.EndDate$DATE>%s ',[mPLMOperation.GetFieldValueAsString('PerformedBy_ID.Person_ID'), IntToStr(Trunc(Date))]), mListWorkLogs);
     if mListWorkLogs.Count>0 then begin
       mWLWorkLog:=OS.CreateObject(Class_WLWorkLog);
       mWLWorkLog.Load(mListWorkLogs.Strings[0],nil);
       mPLMOperation.SetFieldValueAsDateTime('FinishedAt$DATE',mWLWorkLog.GetFieldValueAsDateTime('EndDate$DATE')-(1/144));
       mDuration:=(mPLMOperation.GetFieldValueAsDateTime('FinishedAt$Date')-mPLMOperation.GetFieldValueAsDateTime('StartedAt$DATE'))*24;
       if mDuration>0 then
       mPLMOperation.SetFieldValueAsFloat('Duration',mDuration) else mPLMOperation.SetFieldValueAsFloat('Duration',0);
       mWLList.Add(mWLWorkLog.GetFieldValueAsString('Worker_ID.Person_ID.PersonalNumber')+' '+mWLWorkLog.GetFieldValueAsString('Worker_ID.Person_ID.LastName'));
       mWLWorkLog.free;
       mPLMOperation.save;
       j:=j+1;
     end;
     mListWorkLogs.free;
     mPLMOperation.free;
   end;
  end;
  Success := True;
  LogInfoStr := 'Neukončených pracovních lístků bylo '+IntToStr(mListOperations.count)+#13#10+#13#10+mOPList.Text+' v docházce jsem našel '+IntToStr(j)+#13#10+#13#10+mWLList.Text;
end;

begin
end.