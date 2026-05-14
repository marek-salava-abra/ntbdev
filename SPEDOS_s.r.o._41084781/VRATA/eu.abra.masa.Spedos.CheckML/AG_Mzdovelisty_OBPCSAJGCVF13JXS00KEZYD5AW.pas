procedure _SaveChanges_PreHook(Self: TDynSiteForm);
var
 mCastka:Extended;
 mMonth:integer;
 mEmployee_ID, mWagePeriod_ID:string;
begin
  if Assigned(TDynSiteForm(Self).CurrentObject) then begin
    mMonth:=NxExtractMonth(TDynSiteForm(Self).CurrentObject.GetFieldValueAsDateTime('WagePeriod_ID.DateFrom$Date'));
    if mMonth=12 then mMonth:=1 else mMonth:=mMonth+1;
    mEmployee_ID:=TDynSiteForm(Self).CurrentObject.GetFieldValueAsString('Employee_ID');
    mWagePeriod_ID:=TDynSiteForm(Self).CurrentObject.GetFieldValueAsString('WagePeriod_ID');
    mCastka:=NxEvalObjectExprAsFloat(TDynSiteForm(Self).CurrentObject,'WageListCommonSumBack('+QuotedStr(mEmployee_id)+','+Quotedstr(mwageperiod_id)+','+Quotedstr('S_RetFundTaxExpense')+','+IntToStr(mMonth)+')');


    //if mCastka>49980 then begin
     // NxShowSimpleMessage('Částka důchodového překračuje částku 49 980'+#13#10+TDynSiteForm(Self).CurrentObject.DisplayName+'  měsíc: '+IntToStr(mMonth)+'  částka: '+FloatToStr(mCastka),Self);
    //end;
  end;
end;

begin
end.