procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'VYPR';
  mAction.Items.Add('Nový VYPR');
  mAction.Items.Add('Nový VYPR akt. měsíc');
  //mAction.Items.Add('Revize');
  mAction.Hint := 'Provede generování VYPR na následný měsíc';
  mAction.Category := 'tabList';
  mAction.OnExecuteItem := @GeneratePOZR;

end;

procedure GeneratePOZR (Sender:TComponent; Index:Integer);
var
 mList:TStringList;
 mPLMPQBO, mPLMPQBOOrig, mJOBO:TNxCustomBusinessObject;
 i:Integer;
 mMessage, mJobOrder_ID:string;
 mSite:TSiteForm;
 OS:TNxCustomObjectSpace;
begin
  mSite:=TComponent(Sender).DynSite;
  OS:=msite.BaseObjectSpace;
  mList:=TStringList.Create;
  try
    if Index=0 then
    OS.SQLSelect(format('select p.id from plmworkers p where p.X_GenerateVYP=''A'' and p.hidden=''N'' and p.id not in (SELECT A.X_PLMWorker_ID FROM ' +
                        'PLMJobOrders A WHERE (A.DocQueue_ID = ''2L50000101'' ) AND (A.PlanedStartAt$Date >= %s and A.PlanedStartAt$Date < %s ))  ',[IntToStr(Trunc(1+EndOfTheMonth(Date))),IntToStr(Trunc(2+EndOfTheMonth(Date)))]),mList);
    if Index=1 then
    OS.SQLSelect(format('select p.id from plmworkers p where p.X_GenerateVYP=''A'' and p.hidden=''N'' and p.id not in (SELECT A.X_PLMWorker_ID FROM ' +
                        'PLMJobOrders A WHERE (A.DocQueue_ID = ''2L50000101'' ) AND (A.PlanedStartAt$Date >= %s and A.PlanedStartAt$Date < %s ))  ',[IntToStr(Trunc(FirstOfCurrentMonth(Date))),IntToStr(Trunc(1+FirstOfCurrentMonth(Date)))]),mList);
    if mList.count>0 then begin
      for i:=0 to mlist.Count-1 do begin
        mPLMPQBOOrig:=os.CreateObject(Class_PLMProduceRequest);
        mPLMPQBOOrig.Load('59RV300101',nil);
        mPLMPQBO:=mPLMPQBOOrig.Clone;
        if Index=0 then mPLMPQBO.SetFieldValueAsDateTime('DocDate$Date',1+EndOfTheMonth(Date));
        if Index=1 then mPLMPQBO.SetFieldValueAsDateTime('DocDate$Date',FirstOfCurrentMonth(Date));
        //mPLMPQBO.SetFieldValueAsDateTime('DocDate$Date',44197);
        mPLMPQBO.SetFieldValueAsString('Period_ID',GetPeriodID(OS, mPLMPQBO.GetFieldValueAsDateTime('DocDate$Date')));
        mPLMPQBO.SetFieldValueAsString('X_PLMWorker_ID',mlist.strings[i]);
        mPLMPQBO.SetFieldValueAsString('Division_ID',mPLMPQBO.GetFieldValueAsString('X_PLMWorker_ID.Division_ID'));
        mPLMPQBO.SetFieldValueAsDateTime('PlanedStartAt$DATE',mPLMPQBO.GetFieldValueAsDateTime('DocDate$Date'));
        mPLMPQBO.SetFieldValueAsDateTime('Schedule$DATE',EndOfTheMonth(mPLMPQBO.GetFieldValueAsDateTime('DocDate$Date')));
        if AnsiLeftStr(mPLMPQBO.GetFieldValueAsString('Division_ID.Code'),1)='9' then mPLMPQBO.SetFieldValueAsString('Store_ID','2600000101');
        mPLMPQBO.save;
        CreateJobOrder2(os,mPLMPQBO.oid);
        mPLMPQBO.free;
        mPLMPQBOOrig.Free;
      end;
    end;
  except
    mMessage:=ExceptionMessage;
  end;
end;


function CreateJobOrder2(AOS: TNxCustomObjectSpace; AID: string): string;
var
  mOleApp: Variant;
  mGenReqObject: Variant;
  mDts: TDataset;
  mSQL, mPeriod_ID: string;
  aWarning, aError:string;
  mObject:TNxCustomBusinessObject;
  mHeaderObject:TNxHeaderBusinessObject;
begin
  result := '';
  mObject:=aOS.CreateObject(Class_PLMProduceRequest);
  mObject.Load(AID,nil);
  mHeaderObject:=TNxHeaderBusinessObject(mObject);
  //vytvoření VYP
if true then begin
    mSQL := Format('Select P1.DocQueueForJO_ID, P1.TariffForJO_ID, P2.DocQueueForAWT_ID, P2.AccPresetDef_ID ' +
      ' from PLMPQParams P1 JOIN PLMJOSetParsQueues P2 ON P2.DocQueue_ID=P1.DocQueueForJO_ID where P1.DocQueue_ID=' +
      ' (Select max(DocQueue_ID) from PLMProduceRequests where id=%s)', [QuotedStr(AID)]);
    mDts := TMemoryDataset.Create(nil);
    try
      AOS.SQLSelect2(mSQL, mDts);
      if mDts.Active then begin
        mPeriod_ID := GetPeriodID(AOS, Date);
        //mGenReqObject := mOleApp.CreateObject('@PLMProduceRequest');
          TNxPLMProduceRequest(mHeaderObject).GenerateJobOrder(mDts.FieldByName('DocQueueForJO_ID').AsString,
          mPeriod_ID, mDts.FieldByName('TariffForJO_ID').AsString, mDts.FieldByName('DocQueueForAWT_ID').AsString,
          mDts.FieldByName('AccPresetDef_ID').AsString,aWarning,aError);
          result := mHeaderObject.GetFieldValueAsString('JobOrder_ID');
      end;
    finally
      mDts.free;
      mOleApp := nil;
      mGenReqObject := nil;
    end;
  end;
end;

function FirstOfCurrentMonth(aDate:TDateTime):TDateTime;
var
 Year, Month, Day : word;
begin
  DecodeDate(aDate,Year,Month,Day);
  Result := EncodeDate(Year,Month,1);
end;

function GetPeriodID(AOS: TNxCustomObjectSpace; ADate: TDate): string;
var
  mSQL: string;
  mStr: TStrings;
begin
  result := '0000000000';
  mSQL := Format('SELECT RPeriod_ID FROM GetFirstPeriodByDates(%s, %s, %s)', [FloatToStr(Date), FloatToStr(Date), QuotedStr('0000000000')]);
  mStr := TStringList.Create;
  try
    AOS.SQLSelect(mSQL, mStr);
    if mStr.Count > 0 then
      result := mStr.Strings[0];
  finally
    mStr.Free;
  end;
end;

begin
end.