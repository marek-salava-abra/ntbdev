function FirmName(AReportHelper:TNxQRScriptHelper;Doc_ID:String):String;
var
 mOPRow:TNxCustomBusinessObject;
begin
 mOPRow:=AReportHelper.ObjectSpace.CreateObject(Class_ReceivedOrderRow);
 mOPRow.load(doc_id,nil);
 Result:=mOPRow.GetFieldValueAsString('Parent_ID.Firm_ID.Name');
 moprow.free;
end;
{OtherUnit}

function FVVarSymbol(AReportHelper:TNxQRScriptHelper;ID:String;Documenttype:String):String;
var
 mFV:TNxCustomBusinessObject;

begin
    if Documenttype='03' then begin
       mFV:=AReportHelper.ObjectSpace.CreateObject(Class_IssuedInvoice);
       mFV.Load(id,nil);
       Result:=mfv.GetFieldValueAsString('VarSymbol');
       mfv.free;
    end;
    if Documenttype='60' then begin
       mFV:=AReportHelper.ObjectSpace.CreateObject(Class_IssuedCreditNote);
       mFV.Load(id,nil);
       Result:=mfv.GetFieldValueAsString('VarSymbol');
       mfv.free;
    end;
end;

function FVVarSymbolOSP(AReportHelper:TNxQRScriptHelper;ID:String;mCLSID:String):String;
var
 mFV:TNxCustomBusinessObject;

begin
  result:='';
  try
       mFV:=AReportHelper.ObjectSpace.CreateObject(mCLSID);
       mFV.Load(id,nil);
       Result:=mfv.GetFieldValueAsString('VarSymbol');
       mfv.free;
  Except
   Result:='';
  end;
end;




function VRQuantity (AReportHelper:TNxQRScriptHelper;ID:String;):Extended;
var
 mBO:TNxCustomBusinessObject;
 mList:TStringList;
begin
 mlist:=TStringList.Create;
 AReportHelper.ObjectSpace.SQLSelect(format('Select sum(quantity/unitrate) from storedocuments2 where rdocumentrow_id=''%s'' ',[ID]),mList);
 Result:=NxIBStrToFloat(mlist.strings[0]);
 mlist.Free;
end;

function DZVNumber(AReportHelper:TNxQRScriptHelper;Doc_ID:String):String;
var
 mDZV:TNxCustomBusinessObject;
 mSQL1,mSQL2:string;
 mList, mlist2:tstringList;
begin
   mList:=TStringList.Create;
   mSQL1:='Select PDocumentType from IssuedDepositUsages where DepositDocument_ID=''%s'' ';
   AReportHelper.ObjectSpace.SQLSelect(format(mSQL1,[Doc_ID]),mList);
   if mlist.Count>0 then begin
      if mList.strings[0]='62' then begin
         mlist2:=TStringList.create;
         mSQL2:= 'Select PDocument_ID from IssuedDepositUsages where DepositDocument_ID=''%s'' ';
         AReportHelper.ObjectSpace.SQLSelect(format(mSQL2,[Doc_ID]),mList2);
         mDZV:=AReportHelper.ObjectSpace.CreateObject(Class_VATIssuedDepositInvoice);
         mdzv.Load(mlist2.strings[0],nil);
         Result:=mDZV.DisplayName;
         mDZV.free;
         mlist2.free;
      end;
      if mList.strings[0]='03' then begin
         mlist2:=TStringList.create;
         mSQL2:= 'Select PDocument_ID from IssuedDepositUsages where DepositDocument_ID=''%s'' ';
         AReportHelper.ObjectSpace.SQLSelect(format(mSQL2,[Doc_ID]),mList2);
         mDZV:=AReportHelper.ObjectSpace.CreateObject(Class_IssuedInvoice);
         mdzv.Load(mlist2.strings[0],nil);
         Result:=mDZV.DisplayName;
         mDZV.free;
         mlist2.free;
      end;
   end;
   mlist.free;
end;

function ZLVNumber(AReportHelper:TNxQRScriptHelper;Doc_ID:String):String;
var
 mDZV:TNxCustomBusinessObject;
 mSQL1,mSQL2:string;
 mList, mlist2:tstringList;
begin
   mList:=TStringList.Create;
   mSQL1:='Select DepositDocument_ID from IssuedDepositUsages where PDocument_ID=''%s'' ';
   AReportHelper.ObjectSpace.SQLSelect(format(mSQL1,[Doc_ID]),mList);
   if mlist.Count>0 then begin
         mDZV:=AReportHelper.ObjectSpace.CreateObject(Class_IssuedDepositInvoice);
         mdzv.Load(mList.strings[0],nil);
         Result:=mDZV.DisplayName;
         mDZV.free;

   end;
   mlist.free;
end;

function FVNumber(AReportHelper:TNxQRScriptHelper;StoreDocument2_ID:String):String;
var
 mFV:TNxCustomBusinessObject;
 mList:Tstringlist;
begin
       mList:=TStringList.create;
       AReportHelper.ObjectSpace.SQLSelect(format ('Select parent_ID from issuedinvoices2 where ProvideRow_ID=''%s'' ',[StoreDocument2_ID]),mList);
       Result:='';
       if mlist.Count>0 then begin
       mFV:=AReportHelper.ObjectSpace.CreateObject(Class_IssuedInvoice);
       mFV.Load(mlist.Strings[0],nil);
       Result:=mfv.DisplayName;
       mfv.free;
       end;

end;

function CRNumber(AReportHelper:TNxQRScriptHelper;StoreDocument2_ID:String):String;
var
 mFV:TNxCustomBusinessObject;
 mList:Tstringlist;
begin
       mList:=TStringList.create;
       AReportHelper.ObjectSpace.SQLSelect(format ('Select parent_ID from CashReceived2 where ProvideRow_ID=''%s'' ',[StoreDocument2_ID]),mList);
       Result:='';
       if mlist.Count>0 then begin
       mFV:=AReportHelper.ObjectSpace.CreateObject(Class_CashReceived);
       mFV.Load(mlist.Strings[0],nil);
       Result:=mfv.DisplayName;
       mfv.free;
       end;

end;

function DVNumber(AReportHelper:TNxQRScriptHelper;StoreDocument2_ID:String):String;
var
 mFV:TNxCustomBusinessObject;
 mList:Tstringlist;
begin
       mList:=TStringList.create;
       AReportHelper.ObjectSpace.SQLSelect(format ('Select parent_ID from IssuedCreditNotes2 where ProvideRow_ID=''%s'' ',[StoreDocument2_ID]),mList);
       Result:='';
       if mlist.Count>0 then begin
       mFV:=AReportHelper.ObjectSpace.CreateObject(Class_IssuedCreditNote);
       mFV.Load(mlist.Strings[0],nil);
       Result:=mfv.DisplayName;
       mfv.free;
       end;

end;

function DLNumber(AReportHelper:TNxQRScriptHelper;StoreDocument2_ID:String):String;
var
 mFV:TNxCustomBusinessObject;
 mList:Tstringlist;
begin
       mList:=TStringList.create;
       AReportHelper.ObjectSpace.SQLSelect(format ('Select ID from StoreDocuments where ID=''%s'' and documenttype=''21'' ',[StoreDocument2_ID]),mList);
       Result:='';
       if mlist.Count>0 then begin
       mFV:=AReportHelper.ObjectSpace.CreateObject(Class_BillOfDelivery);
       mFV.Load(mlist.Strings[0],nil);
       Result:=mfv.DisplayName;
       mfv.free;
       end;

end;

function GetRZ(AReportHelper:TNxQRScriptHelper;aGPS_ID:String):String;
var
 mDestCLSID, mDest_ID:string;
 mBO:TNxCustomBusinessObject;
begin
  Result:='';
  mDest_ID:=AReportHelper.ObjectSpace.SQLSelectFirstAsString('Select destination_id from userxlinks where source_id='+QuotedStr(aGPS_ID)+' and sourceclsid='+QuotedStr('BJRBFOTJUOD4T4JPQJZ0AF5YYK'),'');
  if not(NxIsEmptyOID(mDest_ID)) then begin
    mBO:=AReportHelper.ObjectSpace.CreateObject('A0K4JBLYQ5GONHAZFMQBAQ2NMW');
    mbo.Load(mDest_ID,nil);
    Result:=mbo.GetFieldValueAsString('RegPlate');
    mbo.free;
  end;
end;


function WPNumber(AReportHelper:TNxQRScriptHelper;StoreDocument2_ID:String):String;
var
 mFV:TNxCustomBusinessObject;
 mList:Tstringlist;
begin
       mList:=TStringList.create;
       AReportHelper.ObjectSpace.SQLSelect(format ('Select parent_ID from RefundedCashReceived2 where ProvideRow_ID=''%s'' ',[StoreDocument2_ID]),mList);
       Result:='';
       if mlist.Count>0 then begin
       mFV:=AReportHelper.ObjectSpace.CreateObject(Class_RefundedCashReceived);
       mFV.Load(mlist.Strings[0],nil);
       Result:=mfv.DisplayName;
       mfv.free;
       end;

end;

function BusTransaction(AReportHelper:TNxQRScriptHelper;StoreDocument2_ID:String):String;
var
 mFV:TNxCustomBusinessObject;
 mList:Tstringlist;
begin
       mList:=TStringList.create;
       AReportHelper.ObjectSpace.SQLSelect(format ('Select BusTransaction_ID from CashReceived2 where ProvideRow_ID=''%s'' ',[StoreDocument2_ID]),mList);
       Result:='';
       if mlist.Count>0 then begin
       mFV:=AReportHelper.ObjectSpace.CreateObject(Class_BusTransaction);
       mFV.Load(mlist.Strings[0],nil);
       Result:=mfv.DisplayName;
       mfv.free;
       end;
       if mList.count=0 then begin
       AReportHelper.ObjectSpace.SQLSelect(format ('Select BusTransaction_ID from issuedinvoices2 where ProvideRow_ID=''%s'' ',[StoreDocument2_ID]),mList);
       if mList.count>0 then begin
       mFV:=AReportHelper.ObjectSpace.CreateObject(Class_BusTransaction);
       mFV.Load(mlist.Strings[0],nil);
       Result:=mfv.DisplayName;
       mfv.free;
       end;
       end;

end;




{IIPDP}

function II_PDP(AReportHelper:TNxQRScriptHelper;DocQueue_ID:String;Ordnumber:Integer;Period_ID:String;DocumentType:String):Boolean;
var
 mList:TStringList;
 mFV:TNxCustomBusinessObject;
begin
  Result:=false;
  if DocumentType='03' then begin
    mList:=TStringList.Create;
    AReportHelper.ObjectSpace.SQLSelect(format('Select id from issuedinvoices where docqueue_id=''%s'' and ordnumber=%s and period_id=''%s'' ',[DocQueue_ID,IntToStr(Ordnumber),Period_ID]),mList);
    if mList.Count>0 then begin
     mfv:=AReportHelper.ObjectSpace.CreateObject(Class_IssuedInvoice);
     mFV.load(mlist.strings[0],nil);
     if (mFV.GetFieldValueAsInteger('TradeType')=1) and mfv.GetFieldValueAsBoolean('IsReverseChargeDeclared') then Result:=True;
    end;
  end;
end;

function NCUser(AReportHelper:TNxQRScriptHelper;User_ID:String):Boolean;
var
 mUser:TNxCustomBusinessObject;

begin
       mUser:=AReportHelper.ObjectSpace.CreateObject(Class_SecurityUser);
       mUser.Load(User_ID,nil);
       Result:=mUser.GetFieldValueAsBoolean('U_SeePrints');
       mUser.free;
end;


function DueDateFromID(AReportHelper:TNxQRScriptHelper;ID:String;Documenttype:String):Extended;
var
 mFV:TNxCustomBusinessObject;

begin
    if Documenttype='03' then begin
       mFV:=AReportHelper.ObjectSpace.CreateObject(Class_IssuedInvoice);
       mFV.Load(id,nil);
       Result:=mfv.GetFieldValueAsDateTime('DueDate$Date');
       mfv.free;
    end;
    if Documenttype='04' then begin
       mFV:=AReportHelper.ObjectSpace.CreateObject(Class_ReceivedInvoice);
       mFV.Load(id,nil);
       Result:=mfv.GetFieldValueAsDateTime('DueDate$Date');
       mfv.free;
    end;
end;

function UnpaidAmount(AReportHelper:TNxQRScriptHelper;Firm_ID:String):Extended;
var
 mList1, mList2:TStringList;
 {NxSqlSelect('Select sum(II.localamount-ii.localpaidamount) from issuedinvoices ii where ii.firm_id='+NxQuotedstr(ID)+' and ii.localpaidamount<ii.localamount and ii.duedate$date<'+NxDateToFloat(date))-
NxSqlSelect('Select sum(II.localamount-ii.localpaidamount) from issuedcreditnotes ii where ii.firm_id='+NxQuotedstr(ID)+' and ii.localpaidamount<ii.localamount and ii.duedate$date<'+NxDateToFloat(date)) }
begin
  Result:=0;
  mlist1:=TStringList.create;
  mlist2:=TStringList.create;
    AReportHelper.ObjectSpace.SQLSelect(format ('Select sum(II.localamount-ii.localpaidamount) from issuedinvoices ii where ii.firm_id=''%s'' and ii.duedate$date<%s ',[Firm_ID,IntToStr(Trunc(Date))]),mList1);
    AReportHelper.ObjectSpace.SQLSelect(format ('Select sum(II.localamount-ii.localpaidamount) from issuedcreditnotes ii where ii.firm_id=''%s'' and ii.duedate$date<%s ',[Firm_ID,IntToStr(Trunc(Date))]),mList2);
    if mlist1.count>0 then Result:=StrToFloat(mlist1.strings[0]);
    if mlist1.count>0 then Result:=Result+StrToFloat(mlist2.strings[0]);
  mlist1.free;
  mlist2.free;

end;


{SCValue}

function SCValue(AReportHelper:TNxQRScriptHelper;mStoreCardCode:String):Extended;
var
 mBO:TNxCustomBusinessObject;
 mList:TStringList;
begin
  Result:=1;
  mList:=tstringList.Create;
  if not(NxIsBlank(mStoreCardCode)) then begin
     AReportHelper.ObjectSpace.SQLSelect(format('Select id from storecards where code=''%s'' and hidden=''N'' ',[mStoreCardCode]),mList);
     mBO:=AReportHelper.ObjectSpace.CreateObject(class_storecard);
     mbo.load(mlist.strings[0],nil);
     Result:=mbo.GetFieldValueAsFloat('U_spotrebapolozky');
     mbo.free;
  end;
end;

function TransferStore(AReportHelper:TNxQRScriptHelper;ID:String;):String;
var
 mTR, mStore:TNxCustomBusinessObject;

begin
    mTR:=AReportHelper.ObjectSpace.CreateObject(Class_OutgoingTransferRow);
    mTR.Load(ID,nil);
    mStore:=AReportHelper.objectspace.CreateObject(class_store);
    mstore.Load(mtr.GetFieldValueAsString('Store_ID'),nil);
    Result:=mstore.DisplayName;

end;

function OtherUnit(AReportHelper:TNxQRScriptHelper;Parent_ID:String;Code:String;Quantity:Extended):String;
var
 mList:TstringList;
 mUnit:TNxCustomBusinessObject;
 mQuantity, mMainUnitRate:Extended;
 i, j:Integer;
begin
  Result:='';
  j:=0;
  mMainUnitRate:=1;
  mList:=TstringList.Create;
  AReportHelper.ObjectSpace.SQLSelect(format('Select id from storeunits where parent_id=''%s'' ',[Parent_ID]),mList);
  if mList.Count>0 then begin
    for i:=0 to mlist.Count-1 do begin
      mUnit:=AReportHelper.ObjectSpace.CreateObject(Class_StoreUnit);
      mUnit.Load(mlist.Strings[i],nil);

      if not(mUnit.GetFieldValueAsString('Code')=Code) then begin
         if j=0 then Result:=NxFormatNumeric('0.000',mMainUnitRate*(Quantity/munit.GetFieldValueAsFloat('UnitRate')),AReportHelper.ObjectSpace)+ ' '+mUnit.GetFieldValueAsString('Code');
         if (j>0) then Result:=Result+' / '+ NxFormatNumeric('0.000',mMainUnitRate*(Quantity/munit.GetFieldValueAsFloat('UnitRate')),AReportHelper.ObjectSpace)+ ' '+mUnit.GetFieldValueAsString('Code');

         j:=j+1;
      end;
      mUnit.Free;
     end;
    if not(NxIsBlank(Result)) then Result:='('+Trim(Result)+')';
  end;
end;


function GetIONumber(AReportHelper:TNxQRScriptHelper;Doc_ID:String;):String;
Var
 mOV:TNxCustomBusinessObject;
 mSQL:String;
 mList, mList2, mNumList:TStringList;
 i:integer;
begin
 if not(NxIsEmptyOID(Doc_ID)) then begin
   mSQL:='select provide_id from storedocuments2 where parent_id=''%s'' ';
   mList:=TStringList.Create;
   mList2:=TStringList.Create;
   mNumlist:=TStringList.Create;
   mlist.Duplicates:=dupAccept;
   AReportHelper.ObjectSpace.SQLSelect(Format(mSQL,[Doc_ID]),mList);
   Result:='';
   if mlist.Count>0 then begin
   for i:=0 to mlist.count-1 do begin
      if mlist2.IndexOf(mlist.strings[i])<0 then mlist2.Add(mlist.strings[i]);
   end;
   for i:=0 to mList2.count-1 do begin
    if not(NxIsEmptyOID(mlist2.strings[i])) then begin
     mOV:=AReportHelper.objectspace.CreateObject(Class_IssuedOrder);
     mOV.load(mlist2.strings[i],nil);
     mNumList.Add(mov.DisplayName);
     mOV.free;
    end;
   end;
   Result:=mNumList.DelimitedText;
   end;
 end;
end;

function GetRONumber(AReportHelper:TNxQRScriptHelper;Doc_ID:String;):String;
Var
 mOV:TNxCustomBusinessObject;
 mSQL:String;
 mList, mList2, mNumList:TStringList;
 i:integer;
begin
 if not(NxIsEmptyOID(Doc_ID)) then begin
   mSQL:='select provide_id from storedocuments2 where id=''%s'' ';
   mList:=TStringList.Create;
   mList2:=TStringList.Create;
   mNumlist:=TStringList.Create;
   mlist.Duplicates:=dupAccept;
   AReportHelper.ObjectSpace.SQLSelect(Format(mSQL,[Doc_ID]),mList);
   Result:='';
   if mlist.Count>0 then begin
   for i:=0 to mlist.count-1 do begin
      if mlist2.IndexOf(mlist.strings[i])<0 then mlist2.Add(mlist.strings[i]);
   end;
   for i:=0 to mList2.count-1 do begin
    if not(NxIsEmptyOID(mlist2.strings[i])) then begin
     mOV:=AReportHelper.objectspace.CreateObject(Class_ReceivedOrder);
     mOV.load(mlist2.strings[i],nil);
     mNumList.Add(mov.DisplayName);
     mOV.free;
    end;
   end;
   Result:=mNumList.DelimitedText;
   end;
 end;
end;

function GetPPPayByCard(AReportHelper:TNxQRScriptHelper;DocNumber:String;):Boolean;
Var
 mPP:TNxCustomBusinessObject;
 mSQL:String;
 mList: TStringList;
 mDQCode, mOrdNumber, mPeriodCode, mDocument_ID:sTring;
begin
  Result:=False;
  try
    mDocument_ID:='';
    mDQCode:='';
    mOrdNumber:='';
    mPeriodCode:='';
    mDQCode:=NxToken(DocNumber,'-');
    mOrdNumber:=NxToken(DocNumber,'/');
    mPeriodCode:=DocNumber;
    mList:=TStringList.Create;
    AReportHelper.ObjectSpace.SQLSelect(format('Select sd.id from cashreceived sd /*left*/ join periods p on p.id=sd.period_id /*left*/ join docqueues dq on dq.id=sd.docqueue_id where dq.code=''%s'' and p.code=''%s'' and sd.ordnumber=%s',[UpperCase(mDQCode),mPeriodCode,mOrdNumber]),mList);
    if mList.count>0 then mDocument_ID:=mList.Strings[0];
    if not(NxIsEmptyOID(mDocument_ID)) then begin
     mPP:=AReportHelper.objectspace.CreateObject(Class_CashReceived);
     mPP.load(mDocument_ID,nil);
     Result:=mpp.GetFieldValueAsBoolean('X_PayByCard');
     mpp.free;
    end;
    finally
    mlist.Free;
    end;


end;


function SCAction(AReportHelper:TNxQRScriptHelper;StoreCard_ID:String):Boolean;
var
 mStoreCard:TNxCustomBusinessObject;

begin
       mStoreCard:=AReportHelper.ObjectSpace.CreateObject(Class_StoreCard);
       mStoreCard.Load(StoreCard_ID,nil);
       Result:=mStoreCard.GetFieldValueAsBoolean('U_akce2');
       mStoreCard.free;
end;


function SCActionBonusOZ(AReportHelper:TNxQRScriptHelper;StoreCard_ID:String):Boolean;
var
 mStoreCard:TNxCustomBusinessObject;

begin
       mStoreCard:=AReportHelper.ObjectSpace.CreateObject(Class_StoreCard);
       mStoreCard.Load(StoreCard_ID,nil);
       Result:=mStoreCard.GetFieldValueAsBoolean('U_BonusOZ');
       mStoreCard.free;
end;

function SCActionSlevaSeky(AReportHelper:TNxQRScriptHelper;StoreCard_ID:String):Extended;
var
 mStoreCard:TNxCustomBusinessObject;

begin
       mStoreCard:=AReportHelper.ObjectSpace.CreateObject(Class_StoreCard);
       mStoreCard.Load(StoreCard_ID,nil);
       Result:=mStoreCard.GetFieldValueAsFloat('U_slevaseky');
       mStoreCard.free;
end;

function FVAction(AReportHelper:TNxQRScriptHelper;DocQueue_ID,Period_ID:String; OrdNumber:Integer):Extended;
var
 mFV:TNxCustomBusinessObject;
 mList:TStringList;
begin
    Result:=0;
     mList:=TStringList.create;

       AReportHelper.ObjectSpace.SQLSelect(Format('select id from issuedinvoices where docqueue_id=''%s'' and period_id=''%s'' and ordnumber=%s ',[DocQueue_ID,Period_ID,IntToStr(Ordnumber)]),mlist);
       if mlist.count>0 then begin
       mFV:=AReportHelper.ObjectSpace.CreateObject(Class_IssuedInvoice);
       mFV.Load(mList.strings[0],nil);
       Result:=mFV.GetFieldValueAsdatetime('Duedate$Date')-mfv.GetFieldValueAsdatetime('DocDate$date');
       mFV.free;
       end;
end;

function FVActionPaid(AReportHelper:TNxQRScriptHelper;DocQueue_ID,Period_ID:String; OrdNumber:Integer):Extended;
var
 mFV:TNxCustomBusinessObject;
 mList:TStringList;
begin
    Result:=0;
     mList:=TStringList.create;

       AReportHelper.ObjectSpace.SQLSelect(Format('select id from issuedinvoices where docqueue_id=''%s'' and period_id=''%s'' and ordnumber=%s ',[DocQueue_ID,Period_ID,IntToStr(Ordnumber)]),mlist);
       if mlist.count>0 then begin
       mFV:=AReportHelper.ObjectSpace.CreateObject(Class_IssuedInvoice);
       mFV.Load(mList.strings[0],nil);
       Result:=mFV.GetFieldValueAsFloat('PaidAmount');
       mFV.free;
       end;
end;

function FVAmount(AReportHelper:TNxQRScriptHelper;DocQueue_ID,Period_ID:String; OrdNumber:Integer):Extended;
var
 mFV:TNxCustomBusinessObject;
 mList:TStringList;
begin
    Result:=0;
     mList:=TStringList.create;

       AReportHelper.ObjectSpace.SQLSelect(Format('select id from issuedinvoices where docqueue_id=''%s'' and period_id=''%s'' and ordnumber=%s ',[DocQueue_ID,Period_ID,IntToStr(Ordnumber)]),mlist);
       if mlist.count>0 then begin
       mFV:=AReportHelper.ObjectSpace.CreateObject(Class_IssuedInvoice);
       mFV.Load(mList.strings[0],nil);
       Result:=mFV.GetFieldValueAsFloat('Amount');
       mFV.free;
       end;
end;

{mPrice:=NxEvalObjectExprAsFloatDef(mBO,'NxGetStoreCardUnitPriceDef('+Quotedstr(mFirm_ID)+', '+Quotedstr(mStore_id)+', ' + QuotedStr(mStoreCard_ID) + ','+Quotedstr(mPrice_ID)+', '+Quotedstr('ks')+',false,'+QuotedStr(mCurrency_ID)+','+inttostr(trunc(Date))+')',0);}
function SCActionPrice(AReportHelper:TNxQRScriptHelper;StoreCard_ID, Qunit:String; mDate:Extended):Extended;
var
 mStoreCard:TNxCustomBusinessObject;

begin
  mStoreCard:=AReportHelper.ObjectSpace.CreateObject(Class_StoreCard);
  mStoreCard.Load(StoreCard_ID,nil);
  Result:=0;
  if NxEvalObjectExprAsFloatDef(mStoreCard,'NxGetStoreCardUnitPriceDef('+Quotedstr('')+', '+Quotedstr('')+', ' + QuotedStr(StoreCard_ID) + ','+Quotedstr('1100000101')+', '+Quotedstr(Qunit)+',false,'+QuotedStr('0000CZK000')+','+inttostr(trunc(mDate))+')',0)>0 then
   Result:=NxEvalObjectExprAsFloatDef(mStoreCard,'NxGetStoreCardUnitPriceDef('+Quotedstr('')+', '+Quotedstr('')+', ' + QuotedStr(StoreCard_ID) + ','+Quotedstr('1100000101')+', '+Quotedstr(Qunit)+',false,'+QuotedStr('0000CZK000')+','+inttostr(trunc(mDate))+')',0);
  mStoreCard.free;
end;

function DQNote(AReportHelper:TNxQRScriptHelper;DocQueue_ID,Period_ID, StoreCard_ID, DocumentType:String; OrdNumber:Integer):String;
var
 mFV:TNxCustomBusinessObject;
 mList:TStringList;
begin
    Result:='';
      if DocumentType='03' then begin
       mList:=TStringList.create;
       AReportHelper.ObjectSpace.SQLSelect(Format('select ii2.id from issuedinvoices ii left join issuedinvoices2 ii2 on ii2.parent_id=ii.id where ii.docqueue_id=''%s'' and ii.period_id=''%s'' and ii.ordnumber=%s and ii2.storecard_id=''%s'' ',[DocQueue_ID,Period_ID,IntToStr(Ordnumber),StoreCard_ID]),mlist);
       if mlist.count>0 then begin
       mFV:=AReportHelper.ObjectSpace.CreateObject(Class_IssuedInvoiceRow);
       mFV.Load(mList.strings[0],nil);
       Result:=mFV.GetFieldValueAsString('U_poznamka');
       mFV.free;
       end;
     end;
     if DocumentType='05' then begin
       mList:=TStringList.create;
       AReportHelper.ObjectSpace.SQLSelect(Format('select ii2.id from CashReceived ii left join CashReceived2 ii2 on ii2.parent_id=ii.id where ii.docqueue_id=''%s'' and ii.period_id=''%s'' and ii.ordnumber=%s and ii2.storecard_id=''%s'' ',[DocQueue_ID,Period_ID,IntToStr(Ordnumber),StoreCard_ID]),mlist);
       if mlist.count>0 then begin
       mFV:=AReportHelper.ObjectSpace.CreateObject(Class_CashReceivedRow);
       mFV.Load(mList.strings[0],nil);
       Result:=mFV.GetFieldValueAsString('U_poznamka');
       mFV.free;
       end;
     end;
end;

function DQBusTransaction(AReportHelper:TNxQRScriptHelper;DocQueue_ID,Period_ID, StoreCard_ID, DocumentType:String; OrdNumber:Integer):String;
var
 mFV:TNxCustomBusinessObject;
 mList:TStringList;
begin
    Result:='';
      if DocumentType='03' then begin
       mList:=TStringList.create;
       AReportHelper.ObjectSpace.SQLSelect(Format('select ii2.id from issuedinvoices ii left join issuedinvoices2 ii2 on ii2.parent_id=ii.id where ii.docqueue_id=''%s'' and ii.period_id=''%s'' and ii.ordnumber=%s and ii2.storecard_id=''%s'' ',[DocQueue_ID,Period_ID,IntToStr(Ordnumber),StoreCard_ID]),mlist);
       if mlist.count>0 then begin
       mFV:=AReportHelper.ObjectSpace.CreateObject(Class_IssuedInvoiceRow);
       mFV.Load(mList.strings[0],nil);
       Result:=mFV.GetFieldValueAsString('BusTransaction_ID.Code')+' '+mFV.GetFieldValueAsString('BusTransaction_ID.Name');
       mFV.free;
       end;
     end;
     if DocumentType='05' then begin
       mList:=TStringList.create;
       AReportHelper.ObjectSpace.SQLSelect(Format('select ii2.id from CashReceived ii left join CashReceived2 ii2 on ii2.parent_id=ii.id where ii.docqueue_id=''%s'' and ii.period_id=''%s'' and ii.ordnumber=%s and ii2.storecard_id=''%s'' ',[DocQueue_ID,Period_ID,IntToStr(Ordnumber),StoreCard_ID]),mlist);
       if mlist.count>0 then begin
       mFV:=AReportHelper.ObjectSpace.CreateObject(Class_CashReceivedRow);
       mFV.Load(mList.strings[0],nil);
       Result:=mFV.GetFieldValueAsString('BusTransaction_ID.Code')+' '+mFV.GetFieldValueAsString('BusTransaction_ID.Name');
       mFV.free;
       end;
     end;
end;


begin
end.