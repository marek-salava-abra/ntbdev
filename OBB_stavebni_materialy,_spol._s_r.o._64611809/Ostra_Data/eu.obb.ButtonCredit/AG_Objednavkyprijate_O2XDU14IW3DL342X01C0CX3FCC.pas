procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TAction;
  i : integer;
begin

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Dotaz na kredit';
  mAction.Hint := 'Zjistí, jestli lze OP vyfakturovat, či vystavit DL';
  mAction.Category := 'tabList';
  mAction.OnExecute := @CheckCredit;
    //mAction.OnUpdate := @ImportOnUpdate;

end;


Procedure CheckCredit(sender:TComponent);
var
 mSite:TSiteForm;
 mBO: TNxCustomBusinessObject;
  mDL, mFP, mFV, mZL, mCredit, mOP, mOP2, mFOP, mDLFOP, mFVFromOP:Extended;
  mUser:TNxCustomBusinessObject;
  mRows:TNxCustomBusinessMonikerCollection;
 //suma řádků z této konkrétní OP, které nejsou vyfakturované+suma klasická jako u kreditu, ponížená hodnotu DL z této konkrétní OP*1.1
 i:integer;
begin
  mSite:=TComponent(sender).DynSite;
  mBO := TDynSiteForm(msite).CurrentObject;
  if mbo.GetFieldValueAsBoolean('Closed') then begin
     NxShowSimpleMessage('Doklad neobsahuje čerpatelné řádky.',mSite);
     exit;
  end;
  mUser := mbo.ObjectSpace.CreateObject(Class_SecurityUser);
  mOP :=0;
  mFOP:=0;
  mFVFromOP:=0;
  try
    mUser.Load(NxGetActualUserID_1(mBO),nil);
    //if true or not(mUser.GetFieldValueAsBoolean('U_CreditOver')) then
    //begin
      //NxShowSimpleMessage('Kontrola kreditu',nil);
      mRows:=mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows'));
      for i:=0 to mRows.Count-1 do begin
        if mRows.BusinessObject[i].GetFieldValueAsFloat('DeliveredQuantity')<mRows.BusinessObject[i].GetFieldValueAsFloat('Quantity') then begin
          mOP:=mOP+(mRows.BusinessObject[i].GetFieldValueAsFloat('LocalTAmount')/mRows.BusinessObject[i].GetFieldValueAsFloat('Quantity'))*(mRows.BusinessObject[i].GetFieldValueAsFloat('Quantity')-mRows.BusinessObject[i].GetFieldValueAsFloat('DeliveredQuantity'));
        end;
      end;
      for i:=0 to mRows.Count-1 do begin
        if mRows.BusinessObject[i].GetFieldValueAsFloat('DeliveredQuantity')>0 then begin
          mFOP:=mFOP+(mRows.BusinessObject[i].GetFieldValueAsFloat('LocalTAmount')/mRows.BusinessObject[i].GetFieldValueAsFloat('Quantity'))*(mRows.BusinessObject[i].GetFieldValueAsFloat('DeliveredQuantity'));
        end;
      end;
      mCredit:=mBO.GetFieldValueAsFloat('Firm_ID.Credit');
      mZL :=GetSumZL(mBO.ObjectSpace, mBO.GetFieldValueAsString('Firm_ID'));
      mFV :=GetSumFV(mBO.ObjectSpace, mBO.GetFieldValueAsString('Firm_ID'));
      mFP :=GetSumFP(mBO.ObjectSpace, mBO.GetFieldValueAsString('Firm_ID'));
      mDL :=GetSumDL(mBO.ObjectSpace, mBO.GetFieldValueAsString('Firm_ID'));
      mOP2:=GetSumOP(mbo.objectspace, mbo.GetFieldValueAsString('Firm_ID'),mbo.oid);
      mDLFOP:=GetSumDLFromOP(mbo.objectspace, mbo.GetFieldValueAsString('Firm_ID'),mbo.oid);
      mFVFromOP:=GetSumFVFromOP(mbo.ObjectSpace,mbo.oid);
      if ((mFV+mOP+(mFOP-mFVFromOP)+mDLFOP-mFP-mZL+(mDL*1.1))>mCredit*1.2) then
      begin
        NxShowSimpleMessage('Doklad (všechny čerpatelné řádky) nelze vyfakturovat. Došlo by k překročení povoleného kreditu včetně tolerance pro firmu '+mBO.GetFieldValueAsString('Firm_id.Name')+Chr(10)+Chr(13)+
        'Nastavený kredit firmy    '+FormatFloat(',0.00',mCredit)+Chr(10)+Chr(13)+
        'FV         '+FormatFloat(',0.00',mFV)+Chr(10)+Chr(13)+
        'FP         '+FormatFloat(',0.00',mfP)+Chr(10)+Chr(13)+
        'ZL         '+FormatFloat(',0.00',mZL)+Chr(10)+Chr(13)+
        'Hodnota čerpatelných řádků z této OP      '+FormatFloat(',0.00',mOP)+Chr(10)+Chr(13)+
        'Vyastavené a nefakturované DL z této OP     '+FormatFloat(',0.00',mFOP-mFVFromOP)+Chr(10)+Chr(13)+
        'Ostatní čerpatelné OP      '+FormatFloat(',0.00',mOP2)+Chr(10)+Chr(13)+
        'Ostatní nefakturované DL z jiných OP      '+FormatFloat(',0.00',mDLFOP)+Chr(10)+Chr(13)+
        'ostatní nefakturované DL vytvořen bez OP  '+FormatFloat(',0.00',mDL)+Chr(10)+Chr(13)+Chr(10)+Chr(13)+
        ''+Chr(10)+Chr(13)+
        'Chybějící kredit cca       '+formatfloat(',0.00',((mFV+mOP+(mFOP-mFVFromOP)+mDLFOP-mFP-mZL+(mDL*1.1))-(mcredit*1.2)))+#13#10+
        'KONTAKTUJTE PŘÍSLUŠNÉHO OBCHODNÍHO ZÁSTUPCE PRO VYŘEŠENÍ OTÁZKY KREDITU',mSite);
      end
         else begin
      NxShowSimpleMessage('Kredit OK. Doklad lze vyfakturovat.',mSite);

      end;
   // end;
  finally
   mUser.Free;
   mBO.Free;
  end;

end;

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
  cSQL = 'SELECT sum(LocalAmount-localpaidamount-LocalCreditAmount+localPaidCreditamount) from issuedinvoices where firm_id=''%s'' ';
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

function GetSumFP(AOS : TNxCustomObjectSpace; aFirm_ID : string) : Extended;
const
  cSQL = 'SELECT sum(LocalAmount-localpaidamount-LocalCreditAmount+localPaidCreditamount) from receivedinvoices where firm_id=''%s'' ';
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
  cSQL = 'SELECT sum(SD2.LocalTAmount) from StoreDocuments sd left join StoreDocuments2 sd2 on SD2.parent_id=sd.id where sd.IsAvailableForDelivery=''A'' and sd.documenttype=''21'' and sd.firm_id=''%s'' and sd2.provide_id is Null ';
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

function GetSumDLFromOP(AOS : TNxCustomObjectSpace; aFirm_ID, aRO_ID : string) : Extended;
const
  cSQL = 'SELECT sum((RO2.LocalTAmount/RO2.quantity)*(sd2.quantity-sd2.deliveredquantity)) from StoreDocuments sd left join StoreDocuments2 sd2 on SD2.parent_id=sd.id left join receivedorders2 ro2 on ro2.id=sd2.providerow_id where sd.IsAvailableForDelivery=''A'' and sd.documenttype=''21'' and sd.firm_id=''%s'' and not(sd2.provide_id=''%s'') ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aFirm_ID, aRO_ID]), mList);
    if mList.Count > 0 then
      Result := StrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;

function GetSumFVFromOP(AOS : TNxCustomObjectSpace;  aRO_ID : string) : Extended;
const
  cSQL = 'SELECT sum(II2.LocalTAmount) from StoreDocuments2 sd2 left join issuedinvoices2 ii2 on SD2.id=ii2.providerow_id where sd2.provide_id=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [ aRO_ID]), mList);
    if mList.Count > 0 then
      Result := StrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;


function GetSumOP(AOS : TNxCustomObjectSpace; aFirm_ID, aRO_ID : string) : Extended;
const
  cSQL = 'SELECT sum(ro2.localtamount) from receivedOrders ro left join receivedOrders2 ro2 on ro2.parent_id=ro.id where ro.firm_id=''%s'' and ro2.DeliveredQuantity=0 and not (ro.id=''%s'') ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aFirm_ID, aRO_ID]), mList);
    if mList.Count > 0 then
      Result := StrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;



begin
end.