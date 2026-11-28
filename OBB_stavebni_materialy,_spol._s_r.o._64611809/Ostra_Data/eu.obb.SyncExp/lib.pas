Const
 conSQL1='Select id from storecards where  hidden= ''N'' and Createdat$Date>%s ';
 conExportID1='#000000201';
 conDynSource1='OGQQA2C25JDL342N01C0CX3FCC';
 conFileName1='c:\data_exchange\StoreCards.xml';


 conSQL4='Select id from storecards where hidden= ''N'' ';
 conExportID4='#000000202';
 conDynSource4='OGQQA2C25JDL342N01C0CX3FCC';
 conFileName4='c:\data_exchange\storeQuantity.csv';

procedure ExportDeus (OS: TNxCustomObjectSpace;  var Success: Boolean; var LogInfoStr: String);
var
 mIDsList:TStringList;
 mContext:TNxContext;
 mZIP:TZipFile;
 mFileName1, mFileName4:string;
begin
   mIDsList:=TStringList.Create;
   mContext:=NxCreateContext(OS);
   OS.SQLSelect(format(conSQL1,[IntToStr(Trunc(date-2))]), mIDsList);
   mFileName1:=NxGetTempDir+'SC.xml';
   CFxReportManager.ExportByIDs(mContext,mIDsList,conDynSource1,conExportID1,0,'',mfileName1);
   NxCopyFile(mFileName1,conFileName1);
   mIDsList.Clear;
   {OS.SQLSelect(conSQL4, mIDsList);
   mFileName4:=NxGetTempDir+'SQ.csv';
   CFxReportManager.ExportByIDs(mContext,mIDsList,conDynSource4,conExportID4,0,'',mfilename4);
   NxCopyFile(mFileName4,conFileName4);
   mIDsList.Clear;  }
  Success := True;
  LogInfoStr := '';
end;

Procedure ExportQuantityDeus(OS: TNxCustomObjectSpace;  var Success: Boolean; var LogInfoStr: String);
var
 mIDsList, mSaveList, mCodeList, mQuantityList:TStringList;
 i:integer;
begin
 mIDsList:=TstringList.create;
 mCodeList:=TStringList.Create;
 mQuantityList:=TStringList.Create;
 mSAvelist:=tstringlist.Create;
 OS.SQLSelect('select SC.ID||'+Quotedstr(';')+'||SC.code COLLATE Czech_CI_AS||'+Quotedstr(';')+'||SC.Name COLLATE Czech_CI_AS||'+Quotedstr(';')+'||S.Code COLLATE Czech_CI_AS||'+Quotedstr(';')+'||S.Name COLLATE Czech_CI_AS||'+Quotedstr(';')+'||cast((ssc.quantity-ssc.X_OrderedQuantity) as varchar) from storesubcards ssc '+
              'left join storecards sc on sc.id=ssc.storecard_id '+
              'left join stores s on s.id=ssc.store_id where sc.X_EshopExport=''A'' and s.id in (''1000000101'',''3000000101'',''5000000101'',''1200000101'',''7000000101'',''A000000101'',''C000000101'',''#000000001'',''E000000101'',''#000000201'',''G000000101'') ',mIDsList);
 if mIDsList.count>0 then begin
   for i:=0 to mIDsList.count-1 do begin
      mSaveList.add(NxSearchReplace(mIDsList.strings[i],'"','',[srAll]))
   end;
   {for i:=0 to mIDsList.Count-1 do begin
     OS.SQLSelect(format('select code from StoreCards  where id=''%s'' ',[mIDsList.strings[i]]),mCodeList);
     OS.SQLSelect(format('select sum(quantity) from StoreSubCards  where StoreCard_id=''%s'' and store_id in (''1000000101'',''3000000101'',''5000000101'',''1200000101'',''7000000101'',''A000000101'',''C000000101'',''#000000001'',''E000000101'',''G000000101'') ',[mIDsList.strings[i]]),mQuantityList);
     mSaveList.Add(mCodeList.strings[0]+';'+mQuantityList.Strings[0]);
     mCodeList.Clear;
     mQuantityList.clear;
   end;}
   mSaveList.SaveToFile(confilename4);
 end;
end;

begin
end.