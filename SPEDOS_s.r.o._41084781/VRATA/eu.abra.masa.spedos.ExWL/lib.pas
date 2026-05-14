procedure ExportData(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
Var
 mList, mSaveList:TStringList;
 i:integer;
 mWLBO:TNxCustomBusinessObject;
begin
  mList:=TStringList.create;
  mSaveList:=TStringList.create;
  OS.SQLSelect(format('Select a.id from wlworklogs a left join wlworkers w on a.worker_id=w.id where a.begindate$date>%s and w.X_ADS=''A'' ',[inttostr(trunc(date-7))]),mList);
  if mList.count>0 then begin
    for i:=0 to mlist.count-1 do begin
      mWLBO:=OS.CreateObject(Class_WLWorkLog);
      mWLBO.Load(mlist.strings[i],nil);
      mSaveList.add(mWLBO.OID+';'+
                    mWLBO.GetFieldValueAsString('Worker_ID.ExternalID')+';'+
                    DateTimeToStr(mWLBO.GetFieldValueAsDateTime('BeginDate$DATE'))+';'+
                    DateTimeToStr(mWLBO.GetFieldValueAsDateTime('EndDate$DATE')));
    end;
  end;
  if mSaveList.count>0 then mSaveList.SaveToFile('C:\exchange\dochazka.csv');
  Success := True;
  LogInfoStr := '';
end;

begin
end.