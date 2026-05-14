
{
Vyvolá se, když se nezdaří hledání skladové karty.
}
procedure AfterSearchStoreCardError_Hook(AContext: TNxContext; aDocument: TNxCustomBusinessObject; var aHookStoreUnit_OID: TNxOID; aInput: string);
var
  mQ : TStringList;
mStoreCardList: TStringList;
mFirm_ID, mStoreCard_ID: string;
  mStoreCardBO:TNxCustomBusinessObject;
begin
  try
    mFirm_ID:='';

  except
    NxScriptingLog.WriteEvent(logError, 'AfterSearchStoreCardError_Hook: ' + ExceptionMessage);
  end;
if not(NxIsEmptyOID(aHookStoreUnit_OID)) then begin
    mStoreCardList:=TStringList.create;
    try
     aDocument.ObjectSpace.SQLSelect(Format('Select parent_id from StoreUnits where id=''%s'' ',[aHookStoreUnit_OID]),mStoreCardList);
     if mStoreCardList.count>0 then mStoreCard_ID:=mStoreCardList.strings[0];
       mStoreCardBO:=aDocument.ObjectSpace.CreateObject(Class_StoreCard);
       mStoreCardBO.load(mStoreCard_ID,nil);
       if (mStoreCardBO.GetFieldValueAsString('DealerDiscount_ID')='1900000101')
          or (mStoreCardBO.GetFieldValueAsString('DealerDiscount_ID')='1700000101')
          or (mStoreCardBO.GetFieldValueAsString('DealerDiscount_ID')='1800000101')
          or (mStoreCardBO.GetFieldValueAsString('DealerDiscount_ID')='3500000101')
          or (mStoreCardBO.GetFieldValueAsString('DealerDiscount_ID')='4500000101')
          or (mStoreCardBO.GetFieldValueAsString('DealerDiscount_ID')='5500000101')




       then begin
         NxShowSimpleMessage('Pozor, karta je již v akční slevě',nil);
       end;
    finally
    mStoreCardList.free;
    end;
 end;
end;

procedure AfterSearchFirmError_Hook(AContext: TNxContext; aDocument: TNxCustomBusinessObject; var aHookFirm_OID: TNxOID; aInput: string);
var
  mQ : TStringList;
  mStoreCardList: TStringList;
  mParam:TNxParameters;
  mFirm_ID, mStoreCard_ID: string;
  mFirm:TNxCustomBusinessObject;
  i:Integer;
  mList:TStringList;
begin
  mFirm_ID:='';
  try
    if (Copy(aInput, 1, 7) = '2900000') then begin
      mQ := TStringList.Create;
      mParam:=TNxParameters.Create;
      try
       if NxIsEmptyOID(mFirm_ID) then begin
           mq.Clear;
           aDocument.ObjectSpace.SQLSelect(Format('select fp.parent_id from firmpersons fp left join addresses a on a.id=fp.address_id where a.phonenumber2=''%s'' ',[aInput]),mq);
           if mQ.Count > 0 then mFirm_id := mQ.Strings[0];
        end;
        aHookFirm_OID:=mFirm_ID;
        aDocument.SetFieldValueAsBoolean('U_FromVIP',true);
      finally
        mQ.Free;
      end;
    end;
  except
  end;
end;

begin
end.