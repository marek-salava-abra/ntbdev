
{GetQuantity}

function GetQuantity(AReportHelper:TNxQRScriptHelper;aFirm_ID:String;aFirmOffice_ID:String;aDate:Extended;aStoreCard_ID:String; var aStore_ID:String):Extended;
Var
 mOS:TNxCustomObjectSpace;
 mInList, mOutList, mFOList:TstringList;
 mSqlInFO, mSQLInF, mSQLOutFO, mSQLOutF, mSQLFOName, mFOName:STring;
 mQuantityIn,mQuantityOut:Extended;
begin
  Result:=0;
  mQuantityOut:=0;
  mQuantityIn:=0;
  try
    aFirm_ID:=NxTrimApostrofes(aFirm_ID);
    aFirmOffice_ID:=NxTrimApostrofes(aFirmOffice_ID);
    aStore_ID:=NxTrimApostrofes(aStore_ID);
    mOS:=AReportHelper.ObjectSpace;
    mInList:=TStringList.Create;
    mOutList:=TStringList.Create;
    if not NxIsEmptyOID(aFirmOffice_ID) then begin
     mSQLFOName:='Select name from firmoffices where id=''%s'' ';
     mFOList:=TStringList.Create;
     mos.SQLSelect(Format(mSQLFOName,[aFirmOffice_ID]),mFOList);
     mFOName:=NxSearchReplace(mFOList.strings[0],'"','',[srAll]);
    end;

    mSQLInF:='Select sum(SD2.quantity/sd2.unitrate) from storedocuments sd left join storedocuments2 sd2 on SD2.parent_id=sd.ID where sd2.Store_ID=''%s'' and (sd.documenttype=''20'' or sd.documenttype=''23'') and sd.firm_id in (SELECT ID FROM Firms WHERE ID=''%s'' OR Firm_ID=''%s'') and sd.docdate$date<%s and sd2.storecard_ID=''%s'' ';
    mSQLInFO:='Select sum(SD2.quantity/sd2.unitrate) from storedocuments sd left join storedocuments2 sd2 on SD2.parent_id=sd.ID left join FirmOffices FO on FO.id=sd.firmoffice_ID where sd2.Store_ID=''%s'' and (sd.documenttype=''20'' or sd.documenttype=''23'') and sd.firm_id in (SELECT ID FROM Firms WHERE ID=''%s'' OR Firm_ID=''%s'') and sd.docdate$date<%s and sd2.storecard_ID=''%s'' and (sd.firmoffice_id=''%s'' or fo.name=''%s'') ';
    mSQLOutF:='Select sum(SD2.quantity/sd2.unitrate) from storedocuments sd left join storedocuments2 sd2 on SD2.parent_id=sd.ID where sd2.Store_ID=''%s'' and (sd.documenttype=''21'' or sd.documenttype=''30'') and sd.firm_id in (SELECT ID FROM Firms WHERE ID=''%s'' OR Firm_ID=''%s'') and sd.docdate$date<%s and sd2.storecard_ID=''%s'' ';
    mSQLOutFO:='Select sum(SD2.quantity/sd2.unitrate) from storedocuments sd left join storedocuments2 sd2 on SD2.parent_id=sd.ID left join FirmOffices FO on FO.id=sd.firmoffice_ID where sd2.Store_ID=''%s'' and (sd.documenttype=''21'' or sd.documenttype=''30'') and sd.firm_id in (SELECT ID FROM Firms WHERE ID=''%s'' OR Firm_ID=''%s'') and sd.docdate$date<%s and sd2.storecard_ID=''%s'' and (sd.firmoffice_id=''%s'' or fo.name=''%s'') ';
    //NxShowSimpleMessage(Format(mSqlInF,[aFirm_ID, aFirm_ID,FloatToStr(aDate),aStoreCard_ID, aFirmOffice_ID, mFOName]),nil);
    if NxIsEmptyOID(aFirmOffice_ID) then mOS.SQLSelect(Format(mSQLInF,[aStore_ID, aFirm_ID, aFirm_ID,FloatToStr(aDate),aStoreCard_ID]),mInList)
     else
    mOS.SQLSelect(Format(mSqlInFO,[aStore_ID, aFirm_ID, aFirm_ID,FloatToStr(aDate),aStoreCard_ID, aFirmOffice_ID, mFOName]),mInList);
    if NxIsEmptyOID(aFirmOffice_ID) then mOS.SQLSelect(Format(mSQLOutF,[aStore_ID, aFirm_ID, aFirm_ID,FloatToStr(aDate),aStoreCard_ID]),mOutList)
     else
    mOS.SQLSelect(Format(mSQLOutFO,[aStore_ID, aFirm_ID, aFirm_ID,FloatToStr(aDate),aStoreCard_ID,aFirmOffice_ID, mFOName]),mOutList);
    if mInList.Count>0 then mQuantityIn:= StrToFloat(mInList.strings[0]);
    if mInList.Count>0 then mQuantityOut:= StrToFloat(mOutList.strings[0]);
    Result:=mQuantityIn-mQuantityOut;
  finally
  end;
end;

begin
end.