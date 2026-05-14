
{GetStoreAccountID}

function GetStoreAccountID(AReportHelper:TNxQRScriptHelper;Store_ID:String;StoreCardCategory_ID:String):String;
begin
  {NxShowSimpleMessage('Select X_StoreAccount_ID from defrolldata where '+
                  'clsid='+Quotedstr('2TIIQXNXIXK4B5CZUIZ20K2W10')+' and X_rel_def='+QuotedStr('01')+' and X_parent_ID='+QuotedStr(StoreCardCategory_ID)+
                  ' and X_Store_ID='+QuotedStr(Store_ID),nil);  }
  Result:=AReportHelper.ObjectSpace.SQLSelectFirstAsString('Select X_StoreAccount_ID from defrolldata where '+
                  'clsid='+Quotedstr('2TIIQXNXIXK4B5CZUIZ20K2W10')+' and X_rel_def='+QuotedStr('01')+' and X_parent_ID='+QuotedStr(StoreCardCategory_ID)+
                  ' and X_Store_ID='+QuotedStr(Store_ID),'');
end;

function GetPurchaseAccountID(AReportHelper:TNxQRScriptHelper;Store_ID:String;StoreCardCategory_ID:String):String;
begin
  Result:=AReportHelper.ObjectSpace.SQLSelectFirstAsString('Select X_PurchaseAccount_ID from defrolldata where '+
                  'clsid='+Quotedstr('2TIIQXNXIXK4B5CZUIZ20K2W10')+' and X_rel_def='+QuotedStr('01')+' and X_parent_ID='+QuotedStr(StoreCardCategory_ID)+
                  ' and X_Store_ID='+QuotedStr(Store_ID),'');
end;

function GetCostAccountID(AReportHelper:TNxQRScriptHelper;AccRegion_ID:String;StoreCardCategory_ID:String;BillOfDeliveryRow_ID:string):String;
var
 mInvoiceRow_ID:string;
 mAccount_ID:string;
 mAccountBO:TNxCustomBusinessObject;
begin
  if not(StoreCardCategory_ID in ['~00000000A','~00000000G','~00000000I']) then begin
   Result:=AReportHelper.ObjectSpace.SQLSelectFirstAsString('Select X_CostAccount_ID from defrolldata where '+
                  'clsid='+Quotedstr('2TIIQXNXIXK4B5CZUIZ20K2W10')+' and X_rel_def='+QuotedStr('02')+' and X_parent_ID='+QuotedStr(StoreCardCategory_ID)+
                  ' and X_AccRegion_ID='+QuotedStr(AccRegion_ID),'');
  end else begin
    mInvoiceRow_ID:=AReportHelper.ObjectSpace.SQLSelectFirstAsString('Select id from issuedinvoices2 where providerow_id='+QuotedStr(BillOfDeliveryRow_ID),'');
    if NxIsEmptyOID(mInvoiceRow_ID) then
    mInvoiceRow_ID:=AReportHelper.ObjectSpace.SQLSelectFirstAsString('Select id from issuedcreditnotes2 where providerow_id='+QuotedStr(BillOfDeliveryRow_ID),'');
    if not(NxIsEmptyOID(mInvoiceRow_ID)) then begin
     Result:=AReportHelper.ObjectSpace.SQLSelectFirstAsString('Select X_CostAccount_ID from defrolldata where '+
                    'clsid='+Quotedstr('2TIIQXNXIXK4B5CZUIZ20K2W10')+' and X_rel_def='+QuotedStr('02')+' and X_parent_ID='+QuotedStr(StoreCardCategory_ID)+
                    ' and X_AccRegion_ID='+QuotedStr(AccRegion_ID),'');
    end else begin
      mAccount_ID:=AReportHelper.ObjectSpace.SQLSelectFirstAsString('Select X_CostAccount_ID from defrolldata where '+
                    'clsid='+Quotedstr('2TIIQXNXIXK4B5CZUIZ20K2W10')+' and X_rel_def='+QuotedStr('02')+' and X_parent_ID='+QuotedStr(StoreCardCategory_ID)+
                    ' and X_AccRegion_ID='+QuotedStr(AccRegion_ID),'');
      try
       mAccountBO:=AReportHelper.ObjectSpace.CreateObject(Class_Account);
       mAccountBO.Load(mAccount_ID,nil);
       //NxShowSimpleMessage('Select id from accounts where code='+QuotedStr('501'+AnsirightStr(mAccountBO.GetFieldValueAsString('Code'),5)),nil);
       mAccount_ID:=AReportHelper.ObjectSpace.SQLSelectFirstAsString('Select id from accounts where code='+QuotedStr('501'+AnsiRightStr(mAccountBO.GetFieldValueAsString('Code'),5)),'');
       Result:=mAccount_ID;
       mAccountBO.free;
      except
        Result:='';
      end;
    end;
  end;
end;

function GetGainAccountID(AReportHelper:TNxQRScriptHelper;AccRegion_ID:String;StoreCardCategory_ID:String):String;
begin
  Result:=AReportHelper.ObjectSpace.SQLSelectFirstAsString('Select X_GainAccount_ID from defrolldata where '+
                  'clsid='+Quotedstr('2TIIQXNXIXK4B5CZUIZ20K2W10')+' and X_rel_def='+QuotedStr('02')+' and X_parent_ID='+QuotedStr(StoreCardCategory_ID)+
                  ' and X_AccRegion_ID='+QuotedStr(AccRegion_ID),'');
end;

begin
end.