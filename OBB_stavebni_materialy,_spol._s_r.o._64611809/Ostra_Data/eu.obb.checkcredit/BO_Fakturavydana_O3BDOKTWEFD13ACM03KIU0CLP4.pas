procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);


var
 mDL, mFP, mFV, mZL, mCredit, mICN, mDL2, mDLRow, mAvStorePrice:Extended;
 mUser:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mHead, mrow: TNxCustomBusinessObject;
 i:integer;
 mList:TStringList;
begin
  NxScriptingLog.WriteEvent(logInfo, 'BeforeSoftValidate check credit: ' + self.oid);
  mDL:=0;
  mFP:=0;
  mFV:=0;
  mZL:=0;
  mDL2:=0;
  mICN:=0;
  mDLRow:=0;
  mUser:=self.ObjectSpace.CreateObject(Class_SecurityUser);
  mUser.Load(NxGetActualUserID_1(self),nil);
  if not(mUser.GetFieldValueAsBoolean('U_CreditOver')) then begin
  mCredit:=self.GetFieldValueAsFloat('Firm_ID.Credit');
  mZL:=GetSumZL(self.ObjectSpace, self.GetFieldValueAsString('Firm_ID'));
  mFV :=GetSumFV2(self.ObjectSpace, self.GetFieldValueAsString('Firm_ID'), self.oid);
  mFP :=GetSumFP(self.ObjectSpace, self.GetFieldValueAsString('Firm_ID'));
  mICN :=GetSumICN(self.ObjectSpace, self.GetFieldValueAsString('Firm_ID'));
  mDL :=GetSumDL(self.ObjectSpace, self.GetFieldValueAsString('Firm_ID'));
 // mhead:=self.GetMonikerForFieldCode(Self.GetFieldCode('Parent_ID')).BusinessObject;
  mrows:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows'));
  mList:=TStringList.create;
  for i:=0 to mRows.CountOfNotDeleted-1 do begin
     mrow:=mrows.BusinessObject[i];
     mDLRow:=GetSumDL2(self.ObjectSpace, mrow.GetFieldValueAsString('ProvideRow_ID'));
     if mDLRow=0 then begin
         mAvStorePrice:=0;
         mAvStorePrice:=GetAvPrice(self.ObjectSpace,mrow.GetFieldValueAsString('StoreCard_ID'),mrow.GetFieldValueAsString('Store_ID'));
         mDLRow:=mAvStorePrice*(mrow.GetFieldValueAsFloat('Quantity')/mrow.GetFieldValueAsFloat('UnitRate'));

     end;
     mDL2:=mDL2+mDLRow;
     //NxShowSimpleMessage(FormatFloat(',0.00',mDL2),nil);


  end;
   if self.GetFieldValueAsFloat('localamount')>10 then begin
   if ((mFV+self.GetFieldValueAsFloat('localamount')-mICN-mFP-mZL+(Max_1(mDL-mdl2,0)*1.1))>mCredit*1.2) then begin
   self.AddValidateError(self.GetFieldCode('Firm_ID'),'Validace'+Chr(10)+Chr(13)+'Překračujete povolený kredit pro firmu '+self.GetFieldValueAsString('Firm_id.Name')+Chr(10)+Chr(13)+
   'Kredit  '+FormatFloat(',0.00',mCredit)+Chr(10)+Chr(13)+
   'FV včetně této  '+FormatFloat(',0.00',mFV + Self.GetFieldValueAsFloat('localamount'))+Chr(10)+Chr(13)+
   'FV bez této     '+FormatFloat(',0.00',mFV)+Chr(10)+Chr(13)+

//   'FV      '+FormatFloat(',0.00',mFV+self.GetFieldValueAsFloat('localamount'))+Chr(10)+Chr(13)+
   'FP      '+FormatFloat(',0.00',mfP)+Chr(10)+Chr(13)+
   'DV      '+FormatFloat(',0.00',mICN)+Chr(10)+Chr(13)+
   'ZL      '+FormatFloat(',0.00',mZL)+Chr(10)+Chr(13)+
   'DL cca  '+FormatFloat(',0.00',Max_1(mDL-mdl2,0))+Chr(10)+Chr(13)+Chr(10)+Chr(13)+
   'Smažte řádky, které překračují kredit a uložte doklad.');

   AResult:=False;
   end;
  end;
 end;
 NxScriptingLog.WriteEvent(logInfo, 'Validate check credit_konec: ' + self.oid);
end;

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

function GetSumICN(AOS : TNxCustomObjectSpace; aFirm_ID : string) : Extended;
const
  cSQL = 'SELECT sum(ii.LocalAmount-ii.localpaidamount) from IssuedCreditNotes  ii join firms f on f.id=ii.firm_ID where (F.ID=''%s'' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID=''%s''))) ';
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

function GetSumFV(AOS : TNxCustomObjectSpace; aFirm_ID : string) : Extended;
const
  cSQL = 'SELECT sum(ii.LocalAmount-ii.localpaidamount) from issuedinvoices  ii join firms f on f.id=ii.firm_ID where (F.ID=''%s'' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID=''%s''))) ';
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

function GetSumFV2(AOS : TNxCustomObjectSpace; aFirm_ID, aID : string) : Extended;
const
  cSQL = 'SELECT sum(ii.LocalAmount-ii.localpaidamount) from issuedinvoices  ii join firms f on f.id=ii.firm_ID where (F.ID=''%s'' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID=''%s''))) and not (ii.id=''%s'') ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aFirm_ID,aFirm_ID, aID]), mList);
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
  cSQL = 'SELECT sum((ri.LocalAmount-ri.localpaidamount)-(ri.LocalCreditAmount-ri.LocalPaidCreditAmount)) from receivedinvoices ri join firms f on f.id=ri.firm_ID where (F.ID=''%s'' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID=''%s'')))  ';
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
  cSQL = 'SELECT sum(SD2.LocalTAmount) from StoreDocuments sd left join StoreDocuments2 sd2 on SD2.parent_id=sd.id join firms f on f.id=sd.firm_id  where sd.IsAvailableForDelivery=''A'' and sd.documenttype=''21'' and (F.ID=''%s'' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID=''%s''))) ';
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