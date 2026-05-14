
{
Vyvolá se, když se nezdaří hledání skladové karty.
}
{
Vyvolá se při hledání skladové karty.
}




{
Vyvolá se, když se nezdaří hledání firmy. Na gastro kasách nelze použít)
}
procedure AfterSearchFirmError_Hook(AContext: TNxContext; aDocument: TNxCustomBusinessObject; var aHookFirm_OID: TNxOID; aInput: string);
var
  mQ, mObrat, mObratPP : TStringList;
  mStoreCardList, mPosDocList: TStringList;
  mParam:TNxParameters;
  mFirm_ID, mStoreCard_ID: string;
  mFirm, mPosDocBO, mPersonBO:TNxCustomBusinessObject;
  i,j:Integer;
  mList, mList2:TStringList;
  mMessage, mDateText, mdateValidity:String;
  mObratValue, mLimit, mDate, mFirmLimit:Extended;
  mCountLimit:Boolean;
begin
  mFirm_ID:='';
  mDateText:='';
  mdateValidity:='';
  try
    if (Copy(aInput, 1, 7) = '2900000') then begin
      //NxShowSimpleMessage('jsem tu',nil);
      mObratValue:=0;
      mQ := TStringList.Create;
      mParam:=TNxParameters.Create;
      try
       if NxIsEmptyOID(mFirm_ID) then begin
           mq.Clear;
           aDocument.ObjectSpace.SQLSelect(Format('select fp.parent_id from firmpersons fp left join addresses a on a.id=fp.address_id where a.phonenumber2=''%s'' ',[aInput]),mq);
           if mQ.Count > 0 then mFirm_id := mQ.Strings[0];
        end;
        mFirm:=aDocument.ObjectSpace.CreateObject(Class_Firm);
        mFirm.Load(mFirm_ID,nil);
        mList2:=TStringList.Create;
        aDocument.ObjectSpace.SqlSelect(format('Select fp.Person_ID from firmpersons fp left join addresses a on a.id=fp.address_id where a.phonenumber2=''%s'' ',[aInput]),mlist2);
        mPersonBO:=aDocument.ObjectSpace.CreateObject(Class_Person);
        mPersonBO.load(mList2.strings[0],nil);
        if not(mfirm.GetFieldValueAsBoolean('U_kontrola_provedena')) then NxShowSimpleMessage('Prosím, zkontrolujte nebo vložte telefonní číslo, email a DIČ (u firem)',nil);
        if (mFirm.GetFieldValueAsString('DealerCategory_ID.Code')='100') or
           (mFirm.GetFieldValueAsString('DealerCategory_ID.Code')='101') Or
           (mFirm.GetFieldValueAsString('DealerCategory_ID.Code')='3') or
           (mFirm.GetFieldValueAsString('DealerCategory_ID.Code')='102') then begin
        if NxIsBlank(mfirm.GetFieldValueAsString('OrgIdentNumber')) then
        mFirmLimit:=mFirm.GetFieldValueAsFloat('DealerCategory_ID.U_limit_bezIC')
        else
        mFirmLimit:=mFirm.GetFieldValueAsFloat('DealerCategory_ID.U_limit_IC');
        mObrat:=TStringList.create;
        mObratPP:=TStringList.Create;
        aDocument.ObjectSpace.SQLSelect(Format('select sum(amount) from posdocuments where firm_id in (SELECT ID FROM Firms WHERE ID=''%s'' OR Firm_ID=''%s'') and docdate$date>''%s'' ',[mFirm_ID, mFirm_ID, inttostr(Trunc(Date-365))]),mObrat);
        aDocument.ObjectSpace.SQLSelect(Format('select sum(amount) from CashReceived where firm_id in (SELECT ID FROM Firms WHERE ID=''%s'' OR Firm_ID=''%s'') and docdate$date>''%s'' ',[mFirm_ID, mFirm_ID, inttostr(Trunc(Date-365))]),mObratPP);
        if mObrat.count>0 then mObratValue:= StrToFloat(mobrat.Strings[0]);
        if mObratPP.count>0 then begin
         mdateValidity:='Pozor existuje PPZ, zkontrolovat termín sestavou';
         mObratValue := mObratValue + StrToFloat(mobratPP.Strings[0]);
        end;
        if (mObrat.count+mobratPP.Count)>0 then begin
          mCountLimit:=True;
          mLimit:=0;
          mDate:=0;
          mPosDocList:=TStringList.Create;
          aDocument.ObjectSpace.SQLSelect(Format('select ID from posdocuments where firm_id in (SELECT ID FROM Firms WHERE ID=''%s'' OR Firm_ID=''%s'') and docdate$date>''%s'' order by docdate$date desc',[mFirm_ID, mFirm_ID, inttostr(Trunc(Date-365))]),mPosDocList);
          for j:=0 to mPosDocList.count-1 do begin
             if mCountLimit then begin
              mPosDocBO:=aDocument.ObjectSpace.CreateObject(Class_POSDocument);
              mPosDocBO.Load(mPosDocList.Strings[j],nil);
              mLimit:=mLimit+mPosDocBO.GetFieldValueAsFloat('Amount');
              if mLimit>mFirmLimit then begin
                 mCountLimit:=false;
                 mDate:=mPosDocBO.GetFieldValueAsDateTime('DocDate$Date');

              end;
             end;
          end;
        end;
         if mdate>0 then mdatetext:='Tato sleva platí do:'+FormatDateTime('d.m.yyyy',mDate+365);
         if mFirm.GetFieldValueAsBoolean('U_pevna_VIP') then mDateText:='Tato sleva je permanentní';

        mMessage:=mfirm.DisplayName+chr(10)+Chr(13)+mPersonBO.DisplayName+chr(10)+Chr(13)+'Obrat firmy za posledních 365 dní s DPH:    '+FormatFloat('0.00,', mObratValue)+' Kč'+chr(10)+Chr(13)+chr(10)+Chr(13)+
                  'Platné slevové skupiny: '+chr(10)+Chr(13)+'____________________________________________________________'+chr(10)+Chr(13)+
                  mFirm.GetFieldValueAsString('DealerCategory_ID.Name')+chr(10)+Chr(13)+chr(10)+Chr(13)+chr(10)+Chr(13)+mDateText+chr(10)+Chr(13)+mdateValidity;

        NxShowSimpleMessage(mMessage,nil);

        mFirm.Free;
       end;
        aHookFirm_OID:=mFirm_ID;
        aDocument.SetFieldValueAsString('Firm_ID',mFirm_ID);
        aDocument.SetFieldValueAsBoolean('U_FromVIP',true);
      finally
        mQ.Free;
      end;
    end;
  except
  end;
end;

procedure AfterSearchStoreCard_Hook(AContext: TNxContext; aDocument: TNxCustomBusinessObject; var aAbort: boolean; var aUseHookStoreUnit: boolean; var aHookStoreUnit_OID: TNxOID);
Var
 mStoreCardList: TStringList;
mFirm_ID, mStoreCard_ID: string;
  mStoreCardBO:TNxCustomBusinessObject;
  mMessage:Boolean;
begin
 if not(NxIsEmptyOID(aHookStoreUnit_OID)) then begin
    mStoreCardList:=TStringList.create;
    mMessage:=true;
    try
     aDocument.ObjectSpace.SQLSelect(Format('Select parent_id from StoreUnits where id=''%s'' ',[aHookStoreUnit_OID]),mStoreCardList);
     if mStoreCardList.count>0 then mStoreCard_ID:=mStoreCardList.strings[0];
       mStoreCardBO:=aDocument.ObjectSpace.CreateObject(Class_StoreCard);
       mStoreCardBO.load(mStoreCard_ID,nil);

       if ((mStoreCardBO.GetFieldValueAsString('DealerDiscount_ID')='1900000101')
          or (mStoreCardBO.GetFieldValueAsString('DealerDiscount_ID')='1700000101')
          or (mStoreCardBO.GetFieldValueAsString('DealerDiscount_ID')='1800000101')
          or (mStoreCardBO.GetFieldValueAsString('DealerDiscount_ID')='3500000101')
          or (mStoreCardBO.GetFieldValueAsString('DealerDiscount_ID')='4500000101')
          or (mStoreCardBO.GetFieldValueAsString('DealerDiscount_ID')='5500000101')) and mMessage




       then begin
         NxShowSimpleMessage('Pozor, karta je již v akční slevě',nil);
         mMessage:=False;
       end;
       mStoreCardBO.Free;
    finally
    mStoreCardList.free;
    end;
 end;
end;

procedure AfterSearchStoreCardError_Hook(AContext: TNxContext; aDocument: TNxCustomBusinessObject; var aHookStoreUnit_OID: TNxOID; aInput: string);
var
  mQ : TStringList;
  mStoreCardList: TStringList;
  mParam:TNxParameters;
mFirm_ID, mStoreCard_ID: string;
  mStoreCardBO:TNxCustomBusinessObject;
begin
 mFirm_ID:='';
  try
    if (Copy(aInput, 1, 7) = '2900000') then begin
      mQ := TStringList.Create;
      mParam:=TNxParameters.Create;
      try
       //Select D1.X_Firm_ID from defrolldata D2 left join defrolldata d1 on D2.ID=D1.X_VIP_CARD_ID where D2.X_CardNumber=%s
       // aDocument.ObjectSpace.SQLSelect(Format('SELECT f.ID FROM Firms f WHERE f.hidden=''N'' and F.Firm_id is null and (F.X_DiscountCode=''%s'' or F.X_DiscountCode1=''%s'' or F.X_DiscountCode2=''%s'' or F.X_DiscountCode3=''%s'') ', [aInput, aInput,aInput, aInput])
       //                                 , mQ);

        if NxIsEmptyOID(mFirm_ID) then begin
           mq.Clear;
           aDocument.ObjectSpace.SQLSelect(Format('select fp.parent_id from firmpersons fp left join addresses a on a.id=fp.address_id where a.phonenumber2=''%s'' ',[aInput]),mq);
           if mQ.Count > 0 then mFirm_id := mQ.Strings[0];
        end;
        //aDocument.SetFieldValueAsString('Firm_id',mFirm_ID);
        //NxPOSDocRecalculatePrice2(aDocument,mParam);
      finally
        mQ.Free;
      end;
      aHookStoreUnit_OID  := 'ABORT'
    end;
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




{
Volá se před zpracováním příkazové řádky.
}
{
Vyvolá se po nastavení firmy.
}
procedure AfterSetFirm_Hook(AContext: TNxContext; aDocument: TNxCustomBusinessObject);
begin
  //NxShowSimpleMessage('Jsem tu',nil);

end;

{procedure BeforeAnalyzeInputRow_Hook(AContext: TNxContext; aDocument: TNxCustomBusinessObject; aMode: byte; aInputRow: string);
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
    if (Copy(aInputRow, 1, 7) = '2900000') then begin
      mQ := TStringList.Create;
      mParam:=TNxParameters.Create;
      try
       if NxIsEmptyOID(mFirm_ID) then begin
           mq.Clear;
           aDocument.ObjectSpace.SQLSelect(Format('Select D1.X_Firm_ID from defrolldata D2 left join defrolldata d1 on D2.ID=D1.X_VIP_CARD_ID where D2.X_CardNumber=''%s'' ',[aInputRow]),mq);
           if mQ.Count > 0 then mFirm_id := mQ.Strings[0];
        end;
        aDocument.SetFieldValueAsString('Firm_id',mFirm_ID);
        //aDocument.SetFieldValueAsBoolean('IsDiscount',True);
        //NxPOSRecalculatePrice(aDocument.ObjectSpace,aDocument.OID,mParam);
        //NxPOSDocRecalculatePrice2(aDocument,mParam);
        //NxPOSRecalculatePrice(aDocument.ObjectSpace,aDocument.OID,mParam);
        NxPOSStateAmountsByRecalculatePrice(aDocument.ObjectSpace,aDocument.OID,mParam,True);
        mFirm:=aDocument.ObjectSpace.CreateObject(Class_Firm);
        if not(NxIsEmptyOID(mFirm_ID)) then begin
          mFirm.Load(mFirm_ID,nil);
          aInputRow:='/'+mFirm.GetFieldValueAsString('Code');

        end;
        if NxIsEmptyOID(mFirm_ID) then aInputRow:='';
      finally
        mQ.Free;
      end;
      aInputRow:= ''
    end;
  except
  end;
end;  }



begin
end.