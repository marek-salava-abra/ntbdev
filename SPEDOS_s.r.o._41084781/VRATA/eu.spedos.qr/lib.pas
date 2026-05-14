

function TimeToStr(AReportHelper:TNxQRScriptHelper;DateDiff:Extended):String;
begin
  DateTimeToString(Result,'hh:mm:ss',DateDiff);
end;


function PPrice(AReportHelper:TNxQRScriptHelper;StoreDocument2_ID:String):Extended;
var
 mBO:TNxCustomBusinessObject;
 mOCA, mTA:Extended;
begin
  Result:=0;
  if not(NxIsEmptyOID(StoreDocument2_ID)) then begin
    mOCA:=0;
    mTA:=0;
    mBO:=AReportHelper.ObjectSpace.CreateObject(Class_ReceiptCardRow);
    mBO.Load(StoreDocument2_ID,nil);
    if mbo.GetFieldValueAsBoolean('AdditionalCosts_ID.OtherCostIsLocal') and not(mbo.GetFieldValueAsString('Parent_ID.Currency_ID.Code')='CZK') then
     mOCA:=mBO.GetFieldvalueasFloat('AdditionalCosts_ID.OtherCostAmount')/mbo.GetFieldValueAsFloat('Parent_ID.CurrRate')
    else
     mOCA:=mBO.GetFieldvalueasFloat('AdditionalCosts_ID.OtherCostAmount');
    if mbo.GetFieldValueAsBoolean('AdditionalCosts_ID.TransportationIsLocal') and not(mbo.GetFieldValueAsString('Parent_ID.Currency_ID.Code')='CZK') then
     mOCA:=mBO.GetFieldvalueasFloat('AdditionalCosts_ID.TransportationAmount')/mbo.GetFieldValueAsFloat('Parent_ID.CurrRate')
    else
     mOCA:=mBO.GetFieldvalueasFloat('AdditionalCosts_ID.TransportationAmount');
    Result:=(mBO.GetFieldValueAsFloat('LocalTamount')-(mOCA+mTA))/(mbo.GetFieldValueAsFloat('Quantity')/mbo.GetFieldValueAsFloat('UnitRate'));
    mbo.free;
  end;
end;

function PPrice2(AReportHelper:TNxQRScriptHelper;StoreDocument2_ID:String):Extended;
var
 mBO:TNxCustomBusinessObject;
 mOCA, mTA:Extended;
begin
  Result:=0;
  if not(NxIsEmptyOID(StoreDocument2_ID)) then begin
    mOCA:=0;
    mTA:=0;
    mBO:=AReportHelper.ObjectSpace.CreateObject(Class_ReceiptCardRow);
    mBO.Load(StoreDocument2_ID,nil);
    {if mbo.GetFieldValueAsBoolean('AdditionalCosts_ID.OtherCostIsLocal') and not(mbo.GetFieldValueAsString('Parent_ID.Currency_ID.Code')='CZK') then
     mOCA:=mBO.GetFieldvalueasFloat('AdditionalCosts_ID.OtherCostAmount')/mbo.GetFieldValueAsFloat('Parent_ID.CurrRate')
    else
     mOCA:=mBO.GetFieldvalueasFloat('AdditionalCosts_ID.OtherCostAmount');
    if mbo.GetFieldValueAsBoolean('AdditionalCosts_ID.TransportationIsLocal') and not(mbo.GetFieldValueAsString('Parent_ID.Currency_ID.Code')='CZK') then
     mOCA:=mBO.GetFieldvalueasFloat('AdditionalCosts_ID.TransportationAmount')/mbo.GetFieldValueAsFloat('Parent_ID.CurrRate')
    else
     mOCA:=mBO.GetFieldvalueasFloat('AdditionalCosts_ID.TransportationAmount'); }
    Result:=(mBO.GetFieldValueAsFloat('LocalTamount')-(mOCA+mTA))/(mbo.GetFieldValueAsFloat('Quantity')/mbo.GetFieldValueAsFloat('UnitRate'));
    mbo.free;
  end;
end;

function PPriceCurCode(AReportHelper:TNxQRScriptHelper;StoreDocument2_ID:String):String;
var
 mBO:TNxCustomBusinessObject;
begin
  Result:='';
  if not(NxIsEmptyOID(StoreDocument2_ID)) then begin
    mBO:=AReportHelper.ObjectSpace.CreateObject(Class_ReceiptCardRow);
    mBO.Load(StoreDocument2_ID,nil);
    Result:=mbo.GetFieldValueAsString('Parent_ID.Currency_ID.code');
    mbo.free;
  end;
end;

function ACS(AReportHelper:TNxQRScriptHelper;StoreDocument_ID:String):String;
var
 mBO:TNxCustomBusinessObject;
begin
  Result:='';
  if not(NxIsEmptyOID(StoreDocument_ID)) then begin
    mBO:=AReportHelper.ObjectSpace.CreateObject(Class_ReceiptCard);
    mBO.Load(StoreDocument_ID,nil);
    Result:=mbo.GetFieldValueAsString('AdditionalCostsSum');
    mbo.free;
  end;
end;


function VarSymbol(AReportHelper:TNxQRScriptHelper;DQCode:String;OrdNumber:Integer;PCode:String;DocumentType:String):String;
var
 mList:TStringList;
 mBO:TNxCustomBusinessObject;
begin
  Result:='';
  mList:=TStringList.create;
  if DocumentType='04' then begin
   AReportHelper.ObjectSpace.SQLSelect(format('Select a.id from receivedinvoices a left join periods p on p.id=a.period_id left join docqueues dq on dq.id=a.docqueue_id where dq.code=''%s'' and a.ordnumber=%s and p.code=''%s'' ',[DQCode,IntToStr(OrdNumber),PCode]),mList);
   if mList.count>0 then begin
     mBO:=AReportHelper.ObjectSpace.CreateObject(Class_ReceivedInvoice);
     mBO.Load(mlist.strings[0],nil);
     Result:=mbo.GetFieldValueAsString('VarSymbol');
     mbo.free;
   end;
  end;
  if DocumentType='03' then begin
   AReportHelper.ObjectSpace.SQLSelect(format('Select a.id from issuedinvoices a left join periods p on p.id=a.period_id left join docqueues dq on dq.id=a.docqueue_id where dq.code=''%s'' and a.ordnumber=%s and p.code=''%s'' ',[DQCode,IntToStr(OrdNumber),PCode]),mList);
   if mList.count>0 then begin
     mBO:=AReportHelper.ObjectSpace.CreateObject(Class_IssuedInvoice);
     mBO.Load(mlist.strings[0],nil);
     Result:=mbo.GetFieldValueAsString('VarSymbol');
     mbo.free;
   end;
  end;
  mList.free;
end;

begin
end.