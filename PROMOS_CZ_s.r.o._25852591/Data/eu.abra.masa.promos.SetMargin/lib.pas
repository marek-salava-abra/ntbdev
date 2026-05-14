procedure CheckAndSetMargin(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList,mLogs:TStringList;
 i:integer;
 mPrice, mStorePrice, mMargin:Extended;
 mBO:TNxCustomBusinessObject;
begin
  //provede kontrolu marže proti průmerná skladová cena proti aktuální ceně prodejní
  mList:=TStringList.Create;
  mLogs:=TStringList.Create;
  mLogs.Add('__________________________________________');
  mLogs.Add(DateTimeToStr(Now)+' Začátek operace');
  OS.SQLSelect('Select sc.id from storecards sc left join StoreAssortmentGroups SAG on SAG.id=sc.StoreAssortmentGroup_ID where sag.ToleranceMinus>0',mList);
  mLogs.Add(DateTimeToStr(Now)+' Počet skladových karet '+IntToStr(mList.count));
  for i:=0 to mList.count-1 do begin
    mBO:=OS.CreateObject(Class_StoreCard);
    mBO.Load(mList.strings[i],nil);
    mPrice:=NxEvalObjectExprAsFloatDef(mBO,'NxGetStoreCardUnitPriceDef('+Quotedstr('')+', '+Quotedstr('')+', ' +
                                       QuotedStr(mbo.oid) + ','+Quotedstr('1000000101')+', '+Quotedstr(mbo.GetFieldValueAsString('MainUnitCode'))+',false,'+
                                       QuotedStr('0000CZK000')+','+inttostr(trunc(Date))+')',0);
    mStorePrice:=OS.SQLSelectFirstAsExtended('Select averagestoreprice from storesubcards where store_id='+QuotedStr('1000000101')+
                                             'and storecard_id='+QuotedStr(mBO.OID),0);
    mMargin:=0;
    if (mPrice>0) and (mStorePrice>0) then mMargin:=100*((mPrice-mStorePrice)/mprice);
    if mMargin < mbo.GetFieldValueAsFloat('StoreAssortmentGroup_ID.ToleranceMinus') then
      OS.SQLExecute('update storecards set X_ASMarginPercent='+NxFloatToIBStr(mMargin)+', X_MarginInTolerance=''N'' where id='+QuotedStr(mBO.OID))
     else
      OS.SQLExecute('update storecards set X_ASMarginPercent='+NxFloatToIBStr(mMargin)+', X_MarginInTolerance=''A'' where id='+QuotedStr(mBO.OID));
    mLogs.Add(DateTimeToStr(Now)+' '+mBO.DisplayName+'  '+FloatToStr(mPrice)+'   '+FloatToStr(mStorePrice)+'   '+FloatToStr(mMargin));
    mBO.free;
  end;
  mLogs.Add('__________________________________________');
  mLogs.Add(DateTimeToStr(Now)+' Konec operace');
  Success := True;
  LogInfoStr := 'Výsledek operace '+nxCrLf+mLogs.text;
  mLogs.free;
end;

begin
end.