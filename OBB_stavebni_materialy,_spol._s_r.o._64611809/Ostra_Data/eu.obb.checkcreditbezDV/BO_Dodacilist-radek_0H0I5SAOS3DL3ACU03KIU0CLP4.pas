{
Umožňuje ovlivnit validaci.
}
{procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mDL, mFP, mFV, mZL, mCredit, mCurrentDL:Extended;
 mUser:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mHeader:TNxCustomBusinessObject;
 i:Integer;
begin
  NxScriptingLog.WriteEvent(logInfo, 'Validate_HOOK_DL check credit: ' + self.oid);
  if osNew in self.state then begin
  if not(self.GetFieldValueAsBoolean('U_FromIIOrCR')) then begin
  mUser:=self.ObjectSpace.CreateObject(Class_SecurityUser);
  mUser.Load(NxGetActualUserID_1(self),nil);
  if not(mUser.GetFieldValueAsBoolean('U_CreditOver')) then begin


  mCurrentDL:=0;
  mCredit:=self.GetFieldValueAsFloat('Parent_ID.Firm_ID.Credit');
  mZL :=GetSumZL(self.ObjectSpace, self.GetFieldValueAsString('Parent_ID.Firm_ID'));
  mFV :=GetSumFV(self.ObjectSpace, self.GetFieldValueAsString('Parent_ID.Firm_ID'));
  mFP :=GetSumFP(self.ObjectSpace, self.GetFieldValueAsString('Parent_ID.Firm_ID'));
  mDL :=GetSumDL(self.ObjectSpace, self.GetFieldValueAsString('Parent_ID.Firm_ID'));
  mHeader:=self.GetMonikerForFieldCode(self.GetFieldCode('Parent_ID')).BusinessObject;
  mRows:=mHeader.GetLoadedCollectionMonikerForFieldCode(mHeader.GetFieldCode('Rows'));
  for i:=0 to mRows.count-1 do begin
    mCurrentDL:=mCurrentDL+mrows.BusinessObject[i].GetFieldValueAsFloat('TAmount');

  end;
  //NxShowSimpleMessage(FloatToStr(mCurrentDL),nil);
  if ((mFV-mFP- mZL+(mDL+mCurrentDL)*1.1))>(mCredit*1.2) then begin
   self.AddValidateError(self.GetFieldCode('Quantity'),'Tímto řádkem překračujete povolený kredit pro firmu '+self.GetFieldValueAsString('Parent_id.Firm_id.Name')+Chr(10)+Chr(13)+
   'Kredit  '+FormatFloat(',0.00',mCredit)+Chr(10)+Chr(13)+
   'FV      '+FormatFloat(',0.00',mFV)+Chr(10)+Chr(13)+
   'FP      '+FormatFloat(',0.00',mfP)+Chr(10)+Chr(13)+
   'DL cca  '+FormatFloat(',0.00',mDL+mCurrentDL)+Chr(10)+Chr(13)+Chr(10)+Chr(13)+
   'Aktuální řádek smažte a uložte doklad.');

    AResult:=False;
   end;
  end;
 end;
 end;
 NxScriptingLog.WriteEvent(logInfo, 'Validate_HOOK_DL check credit konec: ' + self.oid);
end;
}
function GetSumZL(AOS : TNxCustomObjectSpace; aFirm_ID : string) : Extended;
const
  cSQL = 'SELECT sum(ii.LocalPaidAmount-ii.LocalUsedAmount) from IssuedDInvoices ii join firms f on f.id=ii.firm_ID where (F.ID=''%s'' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID=''%s''))) ';
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
  cSQL = 'SELECT sum(ii.LocalAmount-ii.localpaidamount-ii.LocalCreditAmount) from issuedinvoices  ii join firms f on f.id=ii.firm_ID where (F.ID=''%s'' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID=''%s''))) ';
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
  cSQL = 'SELECT sum(ri.LocalAmount-ri.localpaidamount-ri.LocalCreditAmount) from receivedinvoices ri join firms f on f.id=ri.firm_ID where (F.ID=''%s'' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID=''%s'')))  ';
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
  cSQL = 'SELECT sum(SD2.LocalTAmount) from StoreDocuments sd join firms f on f.id=sd.firm_id left join StoreDocuments2 sd2 on SD2.parent_id=sd.id where sd.IsAvailableForDelivery=''A'' and sd.documenttype=''21'' and (F.ID=''%s'' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID=''%s''))) ';
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

begin
end.