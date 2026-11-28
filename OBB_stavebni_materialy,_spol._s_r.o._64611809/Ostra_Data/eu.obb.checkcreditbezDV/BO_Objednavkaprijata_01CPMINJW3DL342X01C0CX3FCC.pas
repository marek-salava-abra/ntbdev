{
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mDL, mFP, mFV, mZL, mCredit:Extended;
 mUser:TNxCustomBusinessObject;
begin
  if osNew in self.State then begin
  mUser:=self.ObjectSpace.CreateObject(Class_SecurityUser);
  mUser.Load(NxGetActualUserID_1(self),nil);
  if not(mUser.GetFieldValueAsBoolean('U_CreditOver')) then begin
  //NxShowSimpleMessage('Kontrola kreditu',nil);
  mCredit:=self.GetFieldValueAsFloat('Firm_ID.Credit');
  mZL:=GetSumZL(self.ObjectSpace, self.GetFieldValueAsString('Firm_ID'));
  mFV :=GetSumFV(self.ObjectSpace, self.GetFieldValueAsString('Firm_ID'));
  mFP :=GetSumFP(self.ObjectSpace, self.GetFieldValueAsString('Firm_ID'));
  mDL :=GetSumDL(self.ObjectSpace, self.GetFieldValueAsString('Firm_ID'));
  if ((mFV+self.GetFieldValueAsFloat('localamount')-mFP-mZL+(mDL*1.1))>mCredit*1.2) then begin
   NxShowSimpleMessage('Tímto dokladem dojde k překročení povoleného kreditu včetně tolerance pro firmu '+self.GetFieldValueAsString('Firm_id.Name')+Chr(10)+Chr(13)+
   'Kredit  '+FormatFloat(',0.00',mCredit)+Chr(10)+Chr(13)+
   'FV      '+FormatFloat(',0.00',mFV)+Chr(10)+Chr(13)+
   'FP      '+FormatFloat(',0.00',mfP)+Chr(10)+Chr(13)+
   'ZL      '+FormatFloat(',0.00',mZL)+Chr(10)+Chr(13)+
   'DL cca  '+FormatFloat(',0.00',mDL)+Chr(10)+Chr(13)+Chr(10)+Chr(13)+
   'Doklad se uloží, ale DO VYROVNÁNÍ POHLEDÁVEK NEOBJEDNÁVEJTE A NEDODÁVEJTE ZBOŽÍ.'+Chr(10)+Chr(13)+
   'KONTAKTUJTE PŘÍSLUŠNÉHO OBCHODNÍHO ZÁSTUPCE PRO VYŘEŠENÍ OTÁZKY KREDITU',nil);

   AResult:=True;
  end;
 end;
 end;
end;
}

function GetSumZL(AOS : TNxCustomObjectSpace; aFirm_ID : string) : Extended;
const
  cSQL = 'SELECT sum(LocalPaidAmount-LocalUsedAmount) from IssuedDInvoices where firm_id=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aFirm_ID]), mList);
    if mList.Count > 0 then
      Result := StrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;

function GetSumFV(AOS : TNxCustomObjectSpace; aFirm_ID : string) : Extended;
const
  cSQL = 'SELECT sum(LocalAmount-localpaidamount-LocalCreditAmount) from issuedinvoices where firm_id=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aFirm_ID]), mList);
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
  cSQL = 'SELECT sum(LocalAmount-localpaidamount-LocalCreditAmount) from issuedinvoices where firm_id=''%s'' and not (id=''%s'') ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aFirm_ID, aID]), mList);
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
  cSQL = 'SELECT sum(LocalAmount-localpaidamount-LocalCreditAmount) from receivedinvoices where firm_id=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aFirm_ID]), mList);
    if mList.Count > 0 then
      Result := StrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;

function GetSumDL(AOS : TNxCustomObjectSpace; aFirm_ID : string) : Extended;
const
  cSQL = 'SELECT sum(SD2.LocalTAmount) from StoreDocuments sd left join StoreDocuments2 sd2 on SD2.parent_id=sd.id where sd.IsAvailableForDelivery=''A'' and sd.documenttype=''21'' and sd.firm_id=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aFirm_ID]), mList);
    if mList.Count > 0 then
      Result := StrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;

begin
end.