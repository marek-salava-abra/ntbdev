uses 'eu.spedos.GeneratePOZVYP.progress', 'eu.spedos.GeneratePOZVYP.fce', 'eu.spedos.GeneratePOZVYP.POZP';




procedure GenVyp (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);

var
 mPlmJobOrder_ID:String;
 mProduceRequestList, mVypList, mTempList:tstringlist;
 i,x,y,z:integer;
 mJobOrder, mJobOrder2, mStoreBatchBO, mPQBO:TNxCustomBusinessObject;
 mOutPutItems, mPLMJobOrdersSNs:TNxCustomBusinessMonikerCollection;
 mString, mMessage:string;
 mStream:TMemoryStream;
begin
 // NxScriptingLog.EnterSection('GenerujiVYP', logInfo);
   mTempList:=TStringList.Create;
   mString:='';
   mMessage:='';
    { mProduceRequestList:=tstringlist.Create;
     OS.SQLSelect(format('Select pq.id from plmproducerequests pq left join plmreqnodes nod on nod.parent_id=pq.id '+
                       ' where pq.docdate$date>%s and pq.JobOrder_ID is null and pq.docqueue_id=''%s'' and  nod.master_id is not null group by pq.id having max(nod.issue)>0  ',[IntToStr(trunc(Date-10)),'1F10000101']),mProduceRequestList);
      if mProduceRequestList.Count>0 then begin
         for z:=0 to mProduceRequestList.count-1 do begin
            mPQBO:=OS.CreateObject(Class_PLMProduceRequest);
            mPQBO.Load(mProduceRequestList.strings[z],nil);
            mMessage:=mMessage+#13#10+mPQBO.DisplayName;
            CalculateDataForPOZ(mPQBO);
            mpqbo.Free;
         end;
      end;
    mProduceRequestList.free; }

   mProduceRequestList:=tstringlist.Create;
   mVypList:=tstringlist.create;
   OS.SQLSelect(format('Select pq.id from plmproducerequests pq left join plmreqnodes nod on nod.parent_id=pq.id '+
                       ' where pq.docdate$date>%s and pq.JobOrder_ID is null and pq.docqueue_id=''%s'' and  nod.master_id is not null group by pq.id having max(nod.issue)=0  ',[IntToStr(trunc(Date-10)),'1F10000101']),mProduceRequestList);
  // NxScriptingLog.WriteEvent(logInfo, 'Dotaz ' + format('Select id from plmproducerequests where docdate$date=%s and JobOrder_ID is null and docqueue_id=''%s'' ',[IntToStr(trunc(Date)),'1F10000101']));
  if mProduceRequestList.Count>0 then begin


    for z:=0 to mProduceRequestList.Count-1 do begin
                 mPLMJobOrder_ID:=Createjoborder2(OS,mProduceRequestList.strings[z]);
                 // NxScriptingLog.WriteEvent(logInfo, 'jsem po vytvoreni VYP');
                  mPQBO:=OS.CreateObject(Class_PLMProduceRequest);
                  mPQBO.Load(mProduceRequestList.strings[z],nil);
                  mMessage:=mMessage+#13#10+mPQBO.DisplayName+mPQBO.GetFieldValueAsString('JobOrder_ID');
                  mPlmJobOrder_ID:=mPQBO.GetFieldValueAsString('JobOrder_ID');
                  if not(NxIsEmptyOID(mPLMJobOrder_ID)) then begin
                   mVypList.Clear;
                   mJobOrder:=OS.CreateObject(Class_PLMJobOrder);
                   mjoborder.Load(mPLMJobOrder_ID,nil);
                   mTempList.Add(mJobOrder.OID);
                   mjoborder.SetFieldValueAsDateTime('ReleasedAt$DATE',date);
                   mString:=mJobOrder.GetFieldValueAsString('X_group');
                    mOutPutItems:=mJobOrder.GetLoadedCollectionMonikerForFieldCode(mJobOrder.GetFieldCode('OutPuts'));
                    for x:=0 to mOutPutItems.count-1 do begin
                      mPLMJobOrdersSNs:=mOutPutItems.BusinessObject[x].GetLoadedCollectionMonikerForFieldCode(mOutPutItems.BusinessObject[x].GetFieldCode('PLMJobOrdersSN'));
                      if mPLMJobOrdersSNs.Count>0 then begin
                         for y:=0 to mPLMJobOrdersSNs.count-1 do begin
                           if not(NxIsEmptyOID(mPLMJobOrdersSNs.BusinessObject[y].GetFieldValueAsString('StoreBatch_ID'))) then begin
                              mStoreBatchBO:=OS.CreateObject(Class_StoreBatch);
                              mStoreBatchBO.Load(mPLMJobOrdersSNs.BusinessObject[y].GetFieldValueAsString('StoreBatch_ID'),nil);
                              mStoreBatchBO.SetFieldValueAsString('Name',mJobOrder.GetFieldValueAsString('U_vyrobni_cislo'));
                              mstorebatchbo.save;
                              mStoreBatchBO.free;


                           end;
                           //NxShowSimpleMessage('mám '+mPLMJobOrdersSNs.BusinessObject[y].GetFieldValueAsString('StoreBatch_ID.name'),mSite);
                         end;
                      end;
                    end;
                   mJobOrder.save;
                   mMessage:=mMessage+#13#10+mJobOrder.DisplayName;
                    os.SQLSelect('select id from plmjoborders where X_group='+QuotedStr(mJobOrder.GetFieldValueAsString('X_Group')),mVypList);
                   mjoborder.free;
                 end;
                 mPQBO.free;
             //   NxScriptingLog.WriteEvent(logInfo, 'Cesta k datum existuje '+BoolToStr(DirectoryExists('c:\vyroba_data\vrata\out\'),True));
                if mVypList.Count>0 then begin
                 mMessage:=mMessage+#13#10+'c:\vyroba_data\vrata\out\'+mString+'.csv';
                 CFxReportManager.ExportByIDs(NxCreateContext(OS),mVypList,'JPGQAKK24CK4F4U5IKVZDJEQL4','1L00000101',rtoFile,'','c:\vyroba_data\vrata\out\'+mString+'.csv');
                 //NxCopyFile('c:\logy\export\'+mString+'.csv','\\192.168.0.80\abradata\vyroba_data\vrata\out\'+mstring+'.csv');
                end;

    end;
   end;
  if mTempList.count>0 then begin
   for i:=0 to mTempList.Count-1 do begin

    mJobOrder2:=OS.CreateObject(Class_PLMJobOrder);
    mjoborder2.Load(mTempList.strings[i],nil);
    mMessage:=mMessage+#13#10+'Postuji '+mJobOrder2.DisplayName;
    NxScriptingLog.WriteEvent(logInfo,mJobOrder2.GetFieldValueAsString('U_id_vyrobku')+' '+mJobOrder2.DisplayName) ;
                                     mStream := TMemoryStream.Create;
                   if not(NxIsBlank(mJobOrder2.GetFieldValueAsString('U_ID_vyrobku'))) then
                   CFxInternet.HTTPPostBinary('https://sod.spedos.cz/api/api.abra-vyroba.php?',
                                              'user=aBra&password=skS8f-sxR&ID_montaz_vyrobky=' + mJobOrder2.GetFieldValueAsString('U_id_vyrobku') +
                                              '&cislo_vyrobniho_prikazu='+ mJobOrder2.DisplayName+
                                              '&abra_user=',mStream);
                                             //end;
                                             mStream.Free;
    mjoborder2.free;
   end;
  end;
  Success := True;
  LogInfoStr:= mMessage;
 // NxScriptingLog.LeaveSection('GenerujiVYP', logInfo);
end;

begin
end.