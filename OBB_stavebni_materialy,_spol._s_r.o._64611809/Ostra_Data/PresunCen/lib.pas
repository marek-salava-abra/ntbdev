procedure SetPriceChange(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mStoreCardList, mLogs:TStringList;
 i:integer;
 mStoreCardBO, mDCLBo:TNxCustomBusinessObject;
 mPrice_ID, mDCL_ID:string;
begin
  mStoreCardList:=TStringList.Create;
  mLogs:=TStringList.Create;
  mDCLBo:=OS.CreateObject(Class_DataChangesLog);
  mStoreCardBO:=OS.CreateObject(Class_StoreCard);
  //mStoreCardList.add('4GJ0000101');
  OS.SQLSelect('Select id from storecards where hidden=''N'' ', mStoreCardList);
  for i:=0 to mStoreCardList.count-1 do begin
    mPrice_ID:=OS.SQLSelectFirstAsString('select sp.id from storeprices sp where sp.storecard_id='+QuotedStr(mStoreCardList.Strings[i])+' and sp.Pricelist_ID=''1000000101'' ','');
    if not(NxIsEmptyOID(mPrice_ID)) then begin
      mDCL_ID:=OS.SQLSelectFirstAsString('select top 1 ID from datachangeslogs where CLSID = ''GDYLVQXQ3FE13DQC01C0CX3F40'' and Obj_ID = '+QuotedStr(mPrice_ID)+' order by servercreatedat$date desc ','');
      if not(NxIsEmptyOID(mDCL_ID)) then begin
        mDCLBo.load(mDCL_ID,nil);
        mStoreCardBO.Load(mStoreCardList.strings[i],nil);
        mStoreCardBO.SetFieldValueAsString('U_PriceChangeName', AnsiLeftStr(mDCLBo.GetFieldValueAsString('CreatedBy_ID.LoginName'),20));
        mStoreCardBo.SetFieldValueAsDateTime('U_PriceChangeDate', mDCLBo.GetFieldValueAsDateTime('ServerCreatedAt$DATE'));
        mStoreCardBO.save;
        mLogs.Add(mStoreCardBO.DisplayName);
      end;
    end;
  end;
  mDCLBo.free;
  Success := True;
  LogInfoStr := ''+NxCrLf+mLogs.text;
end;

begin
end.