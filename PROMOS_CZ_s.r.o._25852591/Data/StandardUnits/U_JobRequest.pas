(*uses
  'StandardUnits.U_GetId';

////////////////////////////////////////////////////////////////////////////////
//vytvorim pozadavek ke zpracovani
procedure JobRequest_CreateAndSave(OS: TNxCustomObjectSpace; QueueObject_ID, QueueJobType_ID, OriginalRecordBOCLSID, OriginalRecord_ID, Note, Parameters, Report: string);
var
  JobRequest: TNxCustomBusinessObject;
begin
  JobRequest:= OS.CreateObject(class_JobRequest);
  try
    JobRequest.ExplicitTransaction:= OS.InTransaction;
    JobRequest.New;
    JobRequest.Prefill;
    JobRequest.SetFieldValueAsString('QueueObject_ID', QueueObject_ID); //agenda
    JobRequest.SetFieldValueAsString('QueueJobType_ID', QueueJobType_ID);  //akce

    //připojím dokument
    JobRequest.SetFieldValueAsString('OriginalRecordBOCLSID', OriginalRecordBOCLSID);
    JobRequest.SetFieldValueAsString('OriginalRecord_ID', OriginalRecord_ID);

    //texty
    JobRequest.SetFieldValueAsString('Parameters', Parameters);
    JobRequest.SetFieldValueAsString('Report', Report);
    JobRequest.SetFieldValueAsString('Note', Note);

    JobRequest.Save;
  finally
    JobRequest.free;
    JobRequest := nil;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//Test existence pozadavku pro konkreni BO
//-Status_IDs : seznam stavu, ktere prohledavam. ID id odelene carkou. Pokud je prazdne, stav nekontroluji
function JobRequest_ExistForBO(OS: TNxCustomObjectSpace; QueueObject_ID, QueueJobType_ID: TNxOID; CLSID: string; BO_ID: TNxOID; Status_IDs: string = ''): Boolean;
var
  sql: string;
  sl: TStringList;
  sqlWhere_Status: string;
begin
  if(Status_IDs = '')then
    sqlWhere_Status:= ''
  else
    sqlWhere_Status:= ' and Status_ID in ('+StringToQuotedList(Status_IDs)+') ';

  sl:= TStringList.Create;
  try
    sql:=
      'select id from JobRequests '+
      'where QueueObject_ID='+QuotedStr(QueueObject_ID)+' and QueueJobType_ID='+QuotedStr(QueueJobType_ID)+
      ' and OriginalRecordBOCLSID='+QuotedStr(CLSID)+' and OriginalRecord_ID='+QuotedStr(BO_ID)+
      sqlWhere_Status
    ;
    OS.SQLSelect(sql, sl);
    result:= sl.Count > 0;
  finally
    sl.Free;
    sl := nil;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//vytvoreni pozadavku na zpracovani predaneho typu
//aCreateIfExists = vytvoti novy i kdyz jiz existuje pro datny Doc
procedure JobRequest_Create_ForBO(Doc: TNxCustomBusinessObject; JR_QueueObject_ID, JR_QueueJobType_ID: TNxOID; aCreateIfExists: boolean);
begin
  //kontrola, ze jeste neexistuje
  if(not aCreateIfExists) and
    (JobRequest_ExistForBO(Doc.ObjectSpace, JR_QueueObject_ID, JR_QueueJobType_ID, Doc.GetFieldValueAsString('ClassID'), Doc.OID))
  then exit;

  //vytvorim pozadavek
  JobRequest_CreateAndSave(Doc.ObjectSpace, JR_QueueObject_ID, JR_QueueJobType_ID,
    Doc.GetFieldValueAsString('ClassID'), Doc.OID, '','',''
  );
end;
////////////////////////////////////////////////////////////////////////////////
*)
begin
end.