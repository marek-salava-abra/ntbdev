procedure EndWT1030 (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList:TStringList;
 mOperBO:TNxCustomBusinessObject;
 i:integer;
begin
  mList:=TStringList.Create;
  os.SQLSelect('SELECT a.id FROM PLMOperations A '+
               'JOIN PLMJobOrdersRoutines JOR ON JOR.ID = A.JobOrdersRoutines_ID '+
               'JOIN PLMJOOutputItems MI ON MI.ID = JOR.Parent_ID '+
               'JOIN PLMJONodes N ON N.ID = MI.Owner_ID '+
               'JOIN PLMJobOrders JO ON JO.ID = N.Parent_ID '+
               'LEFT JOIN PLMWorkers W ON W.ID=A.PerformedBy_ID '+
               'WHERE (JO.DocQueue_ID = ''2L50000101'' ) and a.finishedat$date=0 and w.X_pauza=1',mList);
  if mList.count>0 then begin
   for i:=0 to mlist.count-1 do begin
     mOperBO:=os.CreateObject(Class_PLMOperation);
     mOperBO.Load(mList.strings[i],nil);
     mOperBO.SetFieldValueAsDateTime('finishedAt$Date',Now);
     mOperBo.SetFieldValueAsFloat('Duration', (mOperBO.GetFieldValueAsDateTime('FinishedAt$Date')-mOperbo.GetFieldValueAsDateTime('StartedAt$Date'))*24);
     moperbo.save;
     moperbo.Free;
   end;
  end;
  Success := True;
  LogInfoStr := '';
end;

procedure EndWT1045 (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList:TStringList;
 mOperBO:TNxCustomBusinessObject;
 i:integer;
begin
  mList:=TStringList.Create;
  os.SQLSelect('SELECT a.id FROM PLMOperations A '+
               'JOIN PLMJobOrdersRoutines JOR ON JOR.ID = A.JobOrdersRoutines_ID '+
               'JOIN PLMJOOutputItems MI ON MI.ID = JOR.Parent_ID '+
               'JOIN PLMJONodes N ON N.ID = MI.Owner_ID '+
               'JOIN PLMJobOrders JO ON JO.ID = N.Parent_ID '+
               'LEFT JOIN PLMWorkers W ON W.ID=A.PerformedBy_ID '+
               'WHERE (JO.DocQueue_ID = ''2L50000101'' ) and a.finishedat$date=0 and w.X_pauza=2',mList);
  if mList.count>0 then begin
   for i:=0 to mlist.count-1 do begin
     mOperBO:=os.CreateObject(Class_PLMOperation);
     mOperBO.Load(mList.strings[i],nil);
     mOperBO.SetFieldValueAsDateTime('finishedAt$Date',Now);
     mOperBo.SetFieldValueAsFloat('Duration', (mOperBO.GetFieldValueAsDateTime('FinishedAt$Date')-mOperbo.GetFieldValueAsDateTime('StartedAt$Date'))*24);
     moperbo.save;
     moperbo.Free;
   end;
  end;
  Success := True;
  LogInfoStr := '';
end;

procedure EndWT1100 (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList:TStringList;
 mOperBO:TNxCustomBusinessObject;
 i:integer;
begin
  mList:=TStringList.Create;
  os.SQLSelect('SELECT a.id FROM PLMOperations A '+
               'JOIN PLMJobOrdersRoutines JOR ON JOR.ID = A.JobOrdersRoutines_ID '+
               'JOIN PLMJOOutputItems MI ON MI.ID = JOR.Parent_ID '+
               'JOIN PLMJONodes N ON N.ID = MI.Owner_ID '+
               'JOIN PLMJobOrders JO ON JO.ID = N.Parent_ID '+
               'LEFT JOIN PLMWorkers W ON W.ID=A.PerformedBy_ID '+
               'WHERE (JO.DocQueue_ID = ''2L50000101'' ) and a.finishedat$date=0 and w.X_pauza=3',mList);
  if mList.count>0 then begin
   for i:=0 to mlist.count-1 do begin
     mOperBO:=os.CreateObject(Class_PLMOperation);
     mOperBO.Load(mList.strings[i],nil);
     mOperBO.SetFieldValueAsDateTime('finishedAt$Date',Now);
     mOperBo.SetFieldValueAsFloat('Duration', (mOperBO.GetFieldValueAsDateTime('FinishedAt$Date')-mOperbo.GetFieldValueAsDateTime('StartedAt$Date'))*24);
     moperbo.save;
     moperbo.Free;
   end;
  end;
  Success := True;
  LogInfoStr := '';
end;

procedure EndWT1115 (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList:TStringList;
 mOperBO:TNxCustomBusinessObject;
 i:integer;
begin
  mList:=TStringList.Create;
  os.SQLSelect('SELECT a.id FROM PLMOperations A '+
               'JOIN PLMJobOrdersRoutines JOR ON JOR.ID = A.JobOrdersRoutines_ID '+
               'JOIN PLMJOOutputItems MI ON MI.ID = JOR.Parent_ID '+
               'JOIN PLMJONodes N ON N.ID = MI.Owner_ID '+
               'JOIN PLMJobOrders JO ON JO.ID = N.Parent_ID '+
               'LEFT JOIN PLMWorkers W ON W.ID=A.PerformedBy_ID '+
               'WHERE (JO.DocQueue_ID = ''2L50000101'' ) and a.finishedat$date=0 and w.X_pauza=4',mList);
  if mList.count>0 then begin
   for i:=0 to mlist.count-1 do begin
     mOperBO:=os.CreateObject(Class_PLMOperation);
     mOperBO.Load(mList.strings[i],nil);
     mOperBO.SetFieldValueAsDateTime('finishedAt$Date',Now);
     mOperBo.SetFieldValueAsFloat('Duration', (mOperBO.GetFieldValueAsDateTime('FinishedAt$Date')-mOperbo.GetFieldValueAsDateTime('StartedAt$Date'))*24);
     moperbo.save;
     moperbo.Free;
   end;
  end;
  Success := True;
  LogInfoStr := '';
end;

procedure EndWT1130 (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList:TStringList;
 mOperBO:TNxCustomBusinessObject;
 i:integer;
begin
  mList:=TStringList.Create;
  os.SQLSelect('SELECT a.id FROM PLMOperations A '+
               'JOIN PLMJobOrdersRoutines JOR ON JOR.ID = A.JobOrdersRoutines_ID '+
               'JOIN PLMJOOutputItems MI ON MI.ID = JOR.Parent_ID '+
               'JOIN PLMJONodes N ON N.ID = MI.Owner_ID '+
               'JOIN PLMJobOrders JO ON JO.ID = N.Parent_ID '+
               'LEFT JOIN PLMWorkers W ON W.ID=A.PerformedBy_ID '+
               'WHERE (JO.DocQueue_ID = ''2L50000101'' ) and a.finishedat$date=0 and w.X_pauza=5',mList);
  if mList.count>0 then begin
   for i:=0 to mlist.count-1 do begin
     mOperBO:=os.CreateObject(Class_PLMOperation);
     mOperBO.Load(mList.strings[i],nil);
     mOperBO.SetFieldValueAsDateTime('finishedAt$Date',Now);
     mOperBo.SetFieldValueAsFloat('Duration', (mOperBO.GetFieldValueAsDateTime('FinishedAt$Date')-mOperbo.GetFieldValueAsDateTime('StartedAt$Date'))*24);
     moperbo.save;
     moperbo.Free;
   end;
  end;
  Success := True;
  LogInfoStr := '';
end;

begin
end.