


procedure SetLowLimit (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
const
 cSQLOut = 'SELECT SUM(sd2.Quantity/sd2.unitrate) FROM StoreDocuments2 sd2 ' +
         'LEFT JOIN StoreDocuments sd ON sd.id = sd2.parent_id ' +
         'WHERE sd2.storecard_id = ''%s'' ' +
         'AND sd2.store_id = ''%s'' AND (sd.documenttype = ''21'' or sd.documenttype = ''22'') ' +
         'AND sd.docdate$date >= %s';
 cSQLIn = 'SELECT SUM(-1*(sd2.Quantity/sd2.unitrate)) FROM StoreDocuments2 sd2 ' +
         'LEFT JOIN StoreDocuments sd ON sd.id = sd2.parent_id ' +
         'WHERE sd2.storecard_id = ''%s'' ' +
         'AND sd2.store_id = ''%s'' AND (sd.documenttype = ''23'') ' +
         'AND sd.docdate$date >= %s';

var
 mSClist, mStoreList, mLogs, mExportCSV:TStringList;
 i,j:integer;
 mQuantityOut, mQuantityIn, mKarton, mUnitRate:Extended;
 mHorizontalSplitter:string;
 mSSCBO, mStoreBO:TNxCustomBusinessObject;

begin
  mHorizontalSplitter:=GetHorizontalSplitter(50);
  mLogs:=TStringList.Create;
  mSClist:=TStringList.Create;
  mStoreList:=TStringList.Create;
  mExportCSV:=TStringList.Create;
  OS.SQLSelect('select id from stores where hidden=''N'' and X_DaysBefore>0 and X_DaysLowLimit>0',mStoreList);
  mLogs.add(mHorizontalSplitter);
  mLogs.add(DateTimeToStr(Now)+' začátek');
  mlogs.add(mHorizontalSplitter);
  mExportCSV.add('kód;název;spotřeba 365;denní;v kartonu;spodní limit;horní limit');
  if mStoreList.count>0 then begin
    mStoreBO:=OS.CreateObject(Class_Store);
    mLogs.add(DateTimeToStr(Now)+' Počet skladů s nastavenými údaji: '+IntToStr(mStoreList.count));
    for i:=0 to mStoreList.count-1 do begin
      mStoreBO.load(mStoreList.Strings[i],nil);
      mLogs.add(mHorizontalSplitter);
      mlogs.Add(DateTimeToStr(now)+' sklad: '+mStoreBO.GetFieldValueAsString('Name'));
      mLogs.add(mHorizontalSplitter);
      mSClist.Clear;
      mLogs.add(DateTimeToStr(Now)+' vyčistíme spodní a horní limity');
      OS.SQLExecute('Update storesubcards set lowlimitquantity=0, highlimitquantity=0 where store_id='+QuotedStr(mStoreBO.OID));
      mLogs.add(DateTimeToStr(Now)+' konec čištění');
      OS.SQLSelect('Select id from storesubcards where store_id='+QuotedStr(mStoreBO.OID), mSClist);
      if mSClist.count>0 then begin
        mLogs.add(mHorizontalSplitter);
        mLogs.add(DateTimeToStr(Now)+' Počet karet: '+IntToStr(mSClist.count));
        mLogs.add(mHorizontalSplitter);
        mSSCBO:=OS.CreateObject(Class_StoreSubCard);
        for j:=0 to mSClist.Count-1 do begin
          mSSCBO.Load(mSClist.strings[j],nil);
          mQuantityOut:=OS.SQLSelectFirstAsExtended(format(cSQLOut,[mSSCBO.GetFieldValueAsString('StoreCard_ID'),mStoreBO.OID,NxFloatToIBStr(date-mStoreBO.GetFieldValueAsInteger('X_DaysBefore'))]),0);
          mQuantityIn:=OS.SQLSelectFirstAsExtended(format(cSQLIn,[mSSCBO.GetFieldValueAsString('StoreCard_ID'),mStoreBO.OID,NxFloatToIBStr(date-mStoreBO.GetFieldValueAsInteger('X_DaysBefore'))]),0);
          mKarton:=NxIBStrToFloat(NxEvalObjectExprAsString(mSSCBO,'NxStoreUnitValueByCode('+Quotedstr(mSSCBO.GetFieldValueAsString('StoreCard_ID'))+
                                                   ','+Quotedstr('krt')+','+QuotedStr('UnitRate')+')'))/mSSCBO.GetFieldValueAsFloat('StoreCard_ID.MainUnitRate');
          mUnitRate:=mSSCBO.GetFieldValueAsFloat('StoreCard_ID.MainUnitRate');
          mLogs.add(mSSCBO.GetFieldValueAsString('StoreCard_ID.code')+chr(9)+FloatToStr((mQuantityIn+mQuantityOut))+chr(9)+FloatToStr(mKarton));
          mExportCSV.add(mSSCBO.GetFieldValueAsString('StoreCard_ID.code')+';'+
                         mSSCBO.GetFieldValueAsString('StoreCard_ID.Name')+';'+
                         FloatToStr(mUnitRate*(mQuantityIn+mQuantityOut))+';'+
                         FloatToStr(mUnitRate*(mQuantityIn+mQuantityOut)/mStoreBO.GetFieldValueAsInteger('X_daysBefore'))+';'+
                         FloatToStr(mKarton)+';'+
                         FloatToStr(NxRoundByValue((mUnitRate*(mQuantityIn+mQuantityOut)/mStoreBO.GetFieldValueAsInteger('X_daysBefore'))*mStoreBO.GetFieldValueAsInteger('X_DaysLowLimit'),ctUp,1))+';'+
                         FloatToStr(NxRoundByValue((mUnitRate*(mQuantityIn+mQuantityOut)/mStoreBO.GetFieldValueAsInteger('X_daysBefore'))*mStoreBO.GetFieldValueAsInteger('X_DaysHighLimit'),ctUp,1)));
          if NxRoundByValue(((mQuantityIn+mQuantityOut)/mStoreBO.GetFieldValueAsInteger('X_daysBefore'))*mStoreBO.GetFieldValueAsInteger('X_DaysLowLimit'),ctUp,1)>0 then begin
           mSSCBO.SetFieldValueAsFloat('LowLimitQuantity',NxRoundByValue((mUnitRate*(mQuantityIn+mQuantityOut)/mStoreBO.GetFieldValueAsInteger('X_daysBefore'))*mStoreBO.GetFieldValueAsInteger('X_DaysLowLimit'),ctUp,1));
           mSSCBO.SetFieldValueAsFloat('HighLimitQuantity',NxRoundByValue((mUnitRate*(mQuantityIn+mQuantityOut)/mStoreBO.GetFieldValueAsInteger('X_daysBefore'))*mStoreBO.GetFieldValueAsInteger('X_DaysHighLimit'),ctUp,1));
           mSSCBO.save;
          end;
        end;
        mSSCBO.free;
      end;
    end;
    mStoreBO.free;
  end;
  mLogs.add(mHorizontalSplitter);
  mLogs.add(DateTimeToStr(Now)+' začátek');
  mlogs.add(mHorizontalSplitter);
  mExportCSV.savetofile('c:\server\abra\AbraG2\sklad_8.csv');
  Success := True;
  LogInfoStr := ''+nxCrLf+mLogs.Text;
  mLogs.free;
  mSClist.free;
  mStoreList.free;
end;

function GetHorizontalSplitter(aLength: Integer): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to aLength do
    Result := Result + '─';
end;

begin
end.