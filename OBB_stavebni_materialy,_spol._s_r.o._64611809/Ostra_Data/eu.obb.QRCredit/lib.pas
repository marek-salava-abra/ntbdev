
{GetCredit}

function GetCredit(AReportHelper:TNxQRScriptHelper;Firm_ID:String):Extended;
var
 mBO:TNxCustomBusinessObject;
 mDL:Extended;
 mCredit, mZL, mFV, mFP, mICN:Extended;
begin
 Result:=0;
 mCredit:=0;
 mBO:=AReportHelper.ObjectSpace.CreateObject(Class_Firm); //BOMA 15-02-2019: úprava tak jak by to mělo správně být
 try
   if mBO.Test(Firm_ID) then
   begin
     mbo.Load(Firm_ID,nil);
     mCredit:=mbo.GetFieldValueAsFloat('Credit');
     mZL:=GetSumZL(AReportHelper.ObjectSpace,Firm_ID);
     mFV :=GetSumFV(AReportHelper.ObjectSpace, Firm_ID);
     mFP :=GetSumFP(AReportHelper.ObjectSpace, Firm_ID);
     mDL:=GetSumBOD(AReportHelper.ObjectSpace,Firm_ID);
     mICN:=GetSumICN(AReportHelper.ObjectSpace,Firm_ID);
     Result:=mcredit-mZL-mFV+mICN+mFP-(mdl*1.1);
   end;
 finally
   mBO.Free;
 end;
end;
function GetSumBOD(AOS : TNxCustomObjectSpace; var aFirm_ID : string) : Extended;
const
  cSQL = 'select sum(SD2.tamount) from storedocuments sd left join storedocuments2 sd2 on sd.id=sd2.parent_id where sd.documenttype=''21'' and sd.IsAvailableForDelivery=''A'' and sd.firm_id=''%s'' ';
var
  mR : TStrings;
begin
  Result := 0;
  mR := TStringlist.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aFirm_ID]), mR);
    if mR.Count > 0 then
      Result := StrToFloat(mR.strings[0]);
  finally
    mR.Free;
  end;
end;

function GetSumZL(AOS : TNxCustomObjectSpace; aFirm_ID : string) : Extended;
const
  cSQL = 'SELECT sum(ii.LocalPaidAmount-ii.LocalUsedAmount) from IssuedDInvoices ii /*left*/ join firms  f on f.id=ii.firm_ID where (F.ID=''%s'' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID=''%s''))) ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aFirm_ID, aFirm_ID]), mList);
    if mList.Count > 0 then
      Result := StrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;

function GetSumFV(AOS : TNxCustomObjectSpace; aFirm_ID : string) : Extended;
const
  cSQL = 'SELECT sum(ii.LocalAmount-ii.localpaidamount) from issuedinvoices  ii /*left*/ join firms  f on f.id=ii.firm_ID where (F.ID=''%s'' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID=''%s''))) ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aFirm_ID,aFirm_ID]), mList);
    //NxShowSimpleMessage(Format(cSQL, [aFirm_ID]),nil);
    if mList.Count > 0 then
      Result := StrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;

function GetSumICN(AOS : TNxCustomObjectSpace; aFirm_ID : string) : Extended;
const
  cSQL = 'SELECT sum(ii.LocalAmount-ii.localpaidamount) from IssuedCreditNotes  ii /*left*/ join firms  f on f.id=ii.firm_ID where (F.ID=''%s'' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID=''%s''))) ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aFirm_ID,aFirm_ID]), mList);
    //NxShowSimpleMessage(Format(cSQL, [aFirm_ID]),nil);
    if mList.Count > 0 then
      Result := StrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;

function GetSumFP(AOS : TNxCustomObjectSpace; aFirm_ID : string) : Extended;
const
  cSQL = 'SELECT sum(ri.LocalAmount-ri.localpaidamount-ri.LocalCreditAmount) from receivedinvoices ri /*left*/ join firms  f on f.id=ri.firm_ID where (F.ID=''%s'' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID=''%s''))) and ( (  ( ((RI.Amount>=0) and ((RI.PaidAmount<=0) and ((RI.Amount + RI.PaidCreditAmount - RI.PaidAmount -  RI.CreditAmount) > 0))) or ((RI.Amount <0) and ((RI.PaidAmount>=0) and ((RI.Amount + RI.PaidCreditAmount - RI.PaidAmount -  RI.CreditAmount) < 0))) )  OR  ( ((RI.Amount>=0) and ((RI.PaidAmount >0) and ((RI.Amount + RI.PaidCreditAmount - RI.PaidAmount -  RI.CreditAmount) > 0))) or ((RI.Amount <0) and ((RI.PaidAmount <0) and ((RI.Amount + RI.PaidCreditAmount - RI.PaidAmount -  RI.CreditAmount) < 0))) )  OR  ( ((RI.Amount>=0) and ((RI.Amount + RI.PaidCreditAmount - RI.PaidAmount -  RI.CreditAmount) < 0)) or ((RI.Amount <0) and ((RI.Amount + RI.PaidCreditAmount - RI.PaidAmount -  RI.CreditAmount) > 0)) ) )) ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aFirm_ID, aFirm_ID]), mList);
    if mList.Count > 0 then
      Result := StrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;

function GetSumDL(AOS : TNxCustomObjectSpace; aFirm_ID : string) : Extended;
const
  cSQL = 'SELECT sum(SD2.LocalTAmount) from StoreDocuments sd left join StoreDocuments2 sd2 on SD2.parent_id=sd.id /*left*/ join firms  f on f.id=sd.firm_id  where sd.IsAvailableForDelivery=''A'' and sd.documenttype=''21'' and (F.ID=''%s'' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID=''%s''))) ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aFirm_ID, aFirm_ID]), mList);
    if mList.Count > 0 then
      Result := StrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;

function GetSumDL2(AOS : TNxCustomObjectSpace; aDocRow_ID : string) : Extended;
const
  cSQL = 'SELECT (SD2.LocalTAmount) from StoreDocuments2 sd2 where sd2.id=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aDocRow_ID]), mList);
    if mList.Count > 0 then
      Result := StrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;

{
Vyvolává se bezprostředně před provedením softvalidace objektu.

procedure
begin
 NxScriptingLog.WriteEvent(logInfo, 'BeforeSoftValidate: ' + self.oid);
end; }

function GEtAvPrice(AOS : TNxCustomObjectSpace; aStoreCard_ID, aStore_ID : string) : Extended;
const
  cSQL = 'SELECT averagestoreprice from storesubcards where StoreCard_ID=''%s'' and store_id=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aStoreCard_ID, astore_id]), mList);
    if mList.Count > 0 then
      Result := StrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;

begin
end.