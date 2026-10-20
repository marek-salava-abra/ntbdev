procedure InvoiceDefect(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList, mLogs, mRRList, mITList:TStringList;
 i,j:integer;
 mDateFrom, mDateTo, mDate, mKoef, mStorePrice, mUnitPrice:Extended;
 mSQL,mBODDocQueue_ID, mCountry_ID, mIIDocQueue_ID, mBOD_ID:string;
 mImportMan:TNxDocumentImportManager;
 mInputParams:TNxParameters;
 mParam:TNxParameter;
 mITBO, mRowBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
begin
  mBODDocQueue_ID:='AA10000101';
  mIIDocQueue_ID:='~000000B01';
  mLogs:=TStringList.Create;
  mDate:=Date;
  if true then begin
  //if DayOfTheMonth(mDate)=3 then begin
    mLogs.Add('________________________________________________');
    mLogs.Add(DateTimeToStr(now)+'  začátek');
    mDateFrom:=StartOfTheMonth(mDate);
    mDateTo:=StartOftheMonth(NxIncMonth(mDate,1));
    mSQL:='Select distinct(X_ReturnReason_ID) from storedocuments where documenttype=''24'' and X_ReturnReason_ID is not null and docdate$date>='+
          NxFloatToIBStr(mDateFrom)+' and docdate$date<'+NxFloatToIBStr(mDateTo);
    mLogs.add(DateTimeToStr(Now)+' den v měsíci '+IntToStr(DayOfTheMonth(mDate)));
    mLogs.add(DateTimeToStr(Now)+' '+mSQL);
    mRRList:=TStringList.Create;
    OS.SQLSelect(mSQL,mRRList);
    if mRRList.count>0 then begin
      for i:=0 to mRRList.count-1 do begin
        mITList:=TStringList.Create;
        OS.SQLSelect('Select id from storedocuments where documenttype=''24'' and X_ReturnReason_ID is not null and docdate$date>='+
          NxFloatToIBStr(mDateFrom)+' and docdate$date<'+NxFloatToIBStr(mDateTo)+' and X_ReturnReason_ID='+QuotedStr(mRRList.strings[i]),mITList);
        try
          mITBO:=OS.CreateObject(Class_IncomingTransfer);
          mITBO.load(mITList.Strings[0],nil);
          mKoef:=mITBO.GetFieldValueAsFloat('X_ReturnReason_ID.X_NumericValue');
          mCountry_ID:=OS.SQLSelectFirstAsString('Select id from countries where code='+QuotedStr(mITBO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode')),'');
          mInputParams := TNxParameters.Create;
          mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
          mParam.AsString := mBODDocQueue_ID;
          mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
          mParam.AsString := mITList.strings[0];
          mImportMan:=NxCreateDocumentImportManager(OS,Class_IncomingTransfer,Class_BillOfDelivery);
          //mImportMan.AddInputDocument(mInvoiceBO.OID);
          mImportMan.AddInputDocuments(mITList);
          mImportMan.LoadParams(mInputParams);
          mImportMan.Execute;
          mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID',mITBO.GetFieldValueAsString('Firm_ID'));
          mImportMan.OutputDocument.SetFieldValueAsString('Description',mITBO.GetFieldValueAsString('X_ReturnReason_ID.Name'));
          if not(NxIsEmptyOID(mCountry_ID)) then
           mImportMan.OutputDocument.SetFieldValueAsString('Country_ID', mCountry_ID);
          mImportMan.OutputDocument.save;
          mLogs.Add(DateTimeToStr(now)+'  '+mImportMan.OutputDocument.DisplayName);
          mBOD_ID:=mImportMan.OutputDocument.OID;
          mImportMan.free;
          mInputParams.free;
          if mKoef>0 then begin
            mInputParams := TNxParameters.Create;
            mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
            mParam.AsString := mIIDocQueue_ID;
            mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
            mParam.AsString := mBOD_ID;
            mImportMan:=NxCreateDocumentImportManager(OS,Class_BillOfDelivery, Class_IssuedInvoice);
            mImportMan.AddInputDocument(mBOD_ID);
            mImportMan.LoadParams(mInputParams);
            mImportMan.Execute;
            mRows:=mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
            for j:=0 to mRows.count-1 do begin
              mRowBO:=mRows.BusinessObject[j];
              mStorePrice:=OS.SQLSelectFirstAsExtended('Select LocalTAmount/quantity from storedocuments2 where id='+QuotedStr(mRowBO.GetFieldValueAsString('ProvideRow_ID')),0);
              mUnitPrice:=(mKoef*mStorePrice)/mImportMan.OutputDocument.GetFieldValueAsFloat('CurrRate');
              if mRowBO.GetFieldValueAsFloat('UnitPrice')=0 then
               mRowBO.SetFieldValueAsFloat('UnitPrice', mUnitPrice);
            end;
            mImportMan.OutputDocument.save;
            mLogs.Add(DateTimeToStr(now)+'  '+mImportMan.OutputDocument.DisplayName);
          end;
          mITBO.free;
        except
         mLogs.Add(DateTimeToStr(now)+'  '+ExceptionMessage);
        end;
      end;
    end;
    mLogs.Add(DateTimeToStr(now)+'  konec');
    mLogs.Add('________________________________________________');
  end;
  Success := True;
  LogInfoStr := 'Výsledek úlohy '+NxCrlf+mLogs.Text;
end;

begin
end.