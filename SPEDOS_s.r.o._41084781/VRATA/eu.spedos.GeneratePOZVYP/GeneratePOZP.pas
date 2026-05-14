uses 'eu.spedos.GeneratePOZVYP.progress', 'eu.spedos.GeneratePOZVYP.fce', 'eu.spedos.GeneratePOZVYP.POZP';




procedure GenPOZP(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);

var
 mPlmJobOrder_ID:String;
 mProduceRequestList, mVypList, mTempList:tstringlist;
 i,x,y,z:integer;
 mJobOrder, mJobOrder2, mStoreBatchBO, mPQBO:TNxCustomBusinessObject;
 mOutPutItems, mPLMJobOrdersSNs:TNxCustomBusinessMonikerCollection;
 mString, mMessage:string;
 mStream:TMemoryStream;
begin
 NxScriptingLog.EnterSection('GenerujiPOZP', logInfo);
 mTempList:=TStringList.Create;
   mString:='';
   mMessage:='';
     mProduceRequestList:=tstringlist.Create;
     OS.SQLSelect(format('Select pq.id from plmproducerequests pq left join plmreqnodes nod on nod.parent_id=pq.id '+
                       ' where pq.docdate$date>%s and pq.JobOrder_ID is null and pq.docqueue_id=''%s'' and  nod.master_id is not null group by pq.id having max(nod.issue)>0  ',[IntToStr(trunc(Date-10)),'1F10000101']),mProduceRequestList);
       NxScriptingLog.WriteEvent(logInfo,'Počet POZ pro POZP '+IntToStr(mProduceRequestList.count));
      if mProduceRequestList.Count>0 then begin
         for z:=0 to mProduceRequestList.count-1 do begin
            mPQBO:=OS.CreateObject(Class_PLMProduceRequest);
            mPQBO.Load(mProduceRequestList.strings[z],nil);
            NxScriptingLog.WriteEvent(logInfo,'jdeme na POZ '+mPQBO.DisplayName);
            mMessage:=mMessage+#13#10+mPQBO.DisplayName;
            CalculateDataForPOZ(mPQBO);
            mpqbo.Free;
         end;
      end;
    mProduceRequestList.free;

    mProduceRequestList:=tstringlist.Create;
     OS.SQLSelect(format('Select pq.id from plmproducerequests pq left join plmreqnodes nod on nod.parent_id=pq.id '+
                       ' where pq.docdate$date>%s and pq.JobOrder_ID is null and pq.docqueue_id=''%s'' and  nod.master_id is not null group by pq.id having max(nod.issue)>0  ',[IntToStr(trunc(Date-10)),'1L20000101']),mProduceRequestList);
       NxScriptingLog.WriteEvent(logInfo,'Počet POZP pro POZP '+IntToStr(mProduceRequestList.count));
      if mProduceRequestList.Count>0 then begin
         for z:=0 to mProduceRequestList.count-1 do begin
            mPQBO:=OS.CreateObject(Class_PLMProduceRequest);
            mPQBO.Load(mProduceRequestList.strings[z],nil);
            NxScriptingLog.WriteEvent(logInfo,'jdeme na POZ '+mPQBO.DisplayName);
            mMessage:=mMessage+#13#10+mPQBO.DisplayName;
            CalculateDataForPOZ(mPQBO);
            mpqbo.Free;
         end;
      end;
    mProduceRequestList.free;


  LogInfoStr:= mMessage;
  NxScriptingLog.LeaveSection('GenerujiPOZP', logInfo);
end;

begin
end.