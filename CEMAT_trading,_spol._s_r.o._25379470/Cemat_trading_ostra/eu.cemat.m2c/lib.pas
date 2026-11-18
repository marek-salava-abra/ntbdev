Uses 'eu.cemat.m2c.const';

function InsertActivity(Self: TNxWebServicesHelper;XMLString: String):String;
Var
 mOS:TNxCustomObjectSpace;
 mXMLHead:TNxScriptingXMLWrapper;
 aResult:String;
 i:Integer;
 mList, mOutputList:TStringList;
 mActivity:TNxCustomBusinessObject;
 mFileName:String;
 mBytes: TBytes;
begin
 Aresult:='';
 Result:='';
 mOS:=self.ObjectSpace;
 mXMLHead := TNxScriptingXMLWrapper.Create;
 mXMLHead.loadFromBytes(DecodeBase64(XMLString));
 mList:=TstringList.Create;
    for i:=0 to mXMLHead.getElementsCountInArray('Actvity')-1 do begin
        try
        mActivity:=mOS.CreateObject(Class_CRMActivity);
        mActivity.New;
        mActivity.Prefill;
        mActivity.SetFieldValueAsString('ActivityArea_ID',mXMLHead.getElementAsString('Actvity['+IntToStr(i)+'].ActivityArea_ID'));
        mActivity.SetFieldValueAsString('ActivityType_ID',mXMLHead.getElementAsString('Actvity['+IntToStr(i)+'].ActivityType_ID'));
        mActivity.SetFieldValueAsString('ActQueue_ID',mXMLHead.getElementAsString('Actvity['+IntToStr(i)+'].ActQueue_ID'));
        mActivity.SetFieldValueAsString('Division_ID',mXMLHead.getElementAsString('Actvity['+IntToStr(i)+'].Division_ID'));
        mActivity.SetFieldValueAsString('Firm_ID',mXMLHead.getElementAsString('Actvity['+IntToStr(i)+'].Firm_ID'));
        mActivity.SetFieldValueAsString('FirmOffice_ID',mXMLHead.getElementAsString('Actvity['+IntToStr(i)+'].DeliveryAddress_ID'));
        mActivity.SetFieldValueAsString('Subject',mXMLHead.getElementAsString('Actvity['+IntToStr(i)+'].Subject'));
        mActivity.SetFieldValueAsString('Person_ID',mXMLHead.getElementAsString('Actvity['+IntToStr(i)+'].Person_ID'));
        mActivity.SetFieldValueAsString('SolverUser_ID',mXMLHead.getElementAsString('Actvity['+IntToStr(i)+'].SolverUser_ID'));
        mActivity.SetFieldValueAsString('SolverRole_ID',mXMLHead.getElementAsString('Actvity['+IntToStr(i)+'].SolverRole_ID'));
        mActivity.SetFieldValueAsInteger('Status', mXMLHead.getElementAsInteger('Actvity['+IntToStr(i)+'].Status'));
        mActivity.SetFieldValueAsInteger('Priority', mXMLHead.getElementAsInteger('Actvity['+IntToStr(i)+'].Priority'));
        mActivity.SetFieldValueAsString('Description',mXMLHead.getElementAsString('Actvity['+IntToStr(i)+'].Description'));
        mActivity.SetFieldValueAsString('Answer',mXMLHead.getElementAsString('Actvity['+IntToStr(i)+'].Answer'));
        mActivity.SetFieldValueAsDateTime('RealStart$DATE',mXMLHead.getElementAsDateTime('Actvity['+IntToStr(i)+'].RealStart'));
        mActivity.SetFieldValueAsDateTime('RealEnd$DATE',mXMLHead.getElementAsDateTime('Actvity['+IntToStr(i)+'].RealEnd'));
        mActivity.SetFieldValueAsDateTime('SheduledStart$DATE',mXMLHead.getElementAsDateTime('Actvity['+IntToStr(i)+'].ScheduledStart'));
        mActivity.SetFieldValueAsDateTime('SheduledEnd$DATE',mXMLHead.getElementAsDateTime('Actvity['+IntToStr(i)+'].ScheduledEnd'));
        mActivity.save;
        mList.Add(mActivity.OID);
        mActivity.Free;
        Except
        end;
    end;
    if mList.count>0 then begin
       NxExportByIDs(NxCreateContext(mos),mList,conDynSource9,conExportID9,0,'',conFileName9);
       mFileName:=conFileName9;
        if FileExists(mFileName) then begin
          mOutputList:=TStringList.Create;
          mOutputList.Clear;
          mOutputList.LoadFromFile(mFileName);
          mBytes := TEncoding.Unicode.GetBytes(mOutputList.Text);
          Result:=EncodeBase64(mBytes);
        end;
       DeleteFile(mFileName);
    end;

end;

function UpdateFirm(Self: TNxWebServicesHelper;XMLString: String):String;
begin
end;

function UpdatePerson(Self: TNxWebServicesHelper;XMLString: String):String;
begin
end;

function UpdateActivity(Self: TNxWebServicesHelper;XMLString: String):String;
Var
 mOS:TNxCustomObjectSpace;
 mXMLHead:TNxScriptingXMLWrapper;
 aResult:String;
 i:Integer;
 mList, mOutputList:TStringList;
 mActivity:TNxCustomBusinessObject;
 mFileName:String;
 mBytes: TBytes;
begin
 Aresult:='';
 Result:='';
 mOS:=self.ObjectSpace;
 mXMLHead := TNxScriptingXMLWrapper.Create;
 mXMLHead.loadFromBytes(DecodeBase64(XMLString));
 mList:=TstringList.Create;
    for i:=0 to mXMLHead.getElementsCountInArray('Actvity')-1 do begin
       if not(NxIsEmptyOID(mXMLHead.getElementAsString('Actvity['+IntToStr(i)+'].ABRA_ID'))) then begin
        try
        mActivity:=mOS.CreateObject(Class_CRMActivity);
        mActivity.Load(mXMLHead.getElementAsString('Actvity['+IntToStr(i)+'].ABRA_ID'),nil);
        mActivity.SetFieldValueAsString('ActivityArea_ID',mXMLHead.getElementAsString('Actvity['+IntToStr(i)+'].ActivityArea_ID'));
        mActivity.SetFieldValueAsString('ActivityType_ID',mXMLHead.getElementAsString('Actvity['+IntToStr(i)+'].ActivityType_ID'));
        mActivity.SetFieldValueAsString('ActQueue_ID',mXMLHead.getElementAsString('Actvity['+IntToStr(i)+'].ActQueue_ID'));
        mActivity.SetFieldValueAsString('Division_ID',mXMLHead.getElementAsString('Actvity['+IntToStr(i)+'].Division_ID'));
        mActivity.SetFieldValueAsString('Firm_ID',mXMLHead.getElementAsString('Actvity['+IntToStr(i)+'].Firm_ID'));
        mActivity.SetFieldValueAsString('FirmOffice_ID',mXMLHead.getElementAsString('Actvity['+IntToStr(i)+'].DeliveryAddress_ID'));
        mActivity.SetFieldValueAsString('Subject',mXMLHead.getElementAsString('Actvity['+IntToStr(i)+'].Subject'));
        mActivity.SetFieldValueAsString('Person_ID',mXMLHead.getElementAsString('Actvity['+IntToStr(i)+'].Person_ID'));
        mActivity.SetFieldValueAsString('SolverUser_ID',mXMLHead.getElementAsString('Actvity['+IntToStr(i)+'].SolverUser_ID'));
        mActivity.SetFieldValueAsString('SolverRole_ID',mXMLHead.getElementAsString('Actvity['+IntToStr(i)+'].SolverRole_ID'));
        mActivity.SetFieldValueAsInteger('Status', mXMLHead.getElementAsInteger('Actvity['+IntToStr(i)+'].Status'));
        mActivity.SetFieldValueAsInteger('Priority', mXMLHead.getElementAsInteger('Actvity['+IntToStr(i)+'].Priority'));
        mActivity.SetFieldValueAsString('Description',mXMLHead.getElementAsString('Actvity['+IntToStr(i)+'].Description'));
        mActivity.SetFieldValueAsString('Answer',mXMLHead.getElementAsString('Actvity['+IntToStr(i)+'].Answer'));
        mActivity.SetFieldValueAsDateTime('RealStart$DATE',mXMLHead.getElementAsDateTime('Actvity['+IntToStr(i)+'].RealStart'));
        mActivity.SetFieldValueAsDateTime('RealEnd$DATE',mXMLHead.getElementAsDateTime('Actvity['+IntToStr(i)+'].RealEnd'));
        mActivity.SetFieldValueAsDateTime('SheduledStart$DATE',mXMLHead.getElementAsDateTime('Actvity['+IntToStr(i)+'].ScheduledStart'));
        mActivity.SetFieldValueAsDateTime('SheduledEnd$DATE',mXMLHead.getElementAsDateTime('Actvity['+IntToStr(i)+'].ScheduledEnd'));
        mActivity.save;
        mList.Add(mActivity.OID);
        mActivity.Free;
        except
         Result:=EncodeBase64(TEncoding.Unicode.GetBytes(ExceptionMessage));
        end;
       end;
    end;
    if mList.count>0 then begin
       NxExportByIDs(NxCreateContext(mos),mList,conDynSource9,conExportID9,0,'',conFileName9);
       mFileName:=conFileName9;
        if FileExists(mFileName) then begin
          mOutputList:=TStringList.Create;
          mOutputList.Clear;
          mOutputList.LoadFromFile(mFileName);
          mBytes := TEncoding.Unicode.GetBytes(mOutputList.Text);
          Result:=EncodeBase64(mBytes);
        end;
       DeleteFile(mFileName);
    end;

end;


function GetMovements(Self: TNxWebServicesHelper;DateFrom: Extended):String;
var
  mObjectSpace: TNxCustomObjectSpace;
  mIDsList, mOutputList: TStringList;
  mSQL,mExportID, mDynSource, mFileName: String;
  mContext: TNxContext;
  mCreatedDate,mCorrectedDate:Extended;
  mBytes: TBytes;
  mDate:string;
begin
  Result:=EncodeBase64(TEncoding.Unicode.GetBytes('<?xml version="1.0" encoding="UTF-8"?><Empty></Empty>'));
  mIDsList:=TStringList.Create;
  mOutputList:=TStringList.Create;
  mObjectSpace := Self.ObjectSpace;
  mDate:=NxSearchReplace(FloatToStr(DateFrom),',','.',[srAll]);
  mContext := NxCreateContext(mObjectSpace);
      msql:=format(conSQL21,[mdate]);
      mExportID:=conExportID21;
      mFileName:=conFileName21;
      mDynSource:=conDynSource21;



  mObjectSpace.SQLSelect(mSQL, mIDsList);
  if mIDsList.count>0 then begin
       NxExportByIDs(mContext,mIDsList,mDynSource,mExportID,0,'',mFileName);
        if FileExists(mFileName) then begin
        mOutputList.Clear;
          mOutputList.LoadFromFile(mFileName);
          mBytes := TEncoding.Unicode.GetBytes(mOutputList.Text);
          //Result:=EncodeBase64(mBytes);
          Result:=EncodeBase64(getfiletobytes(mFileName));
        end;
  end;
  DeleteFile(mFileName);
  mContext.Free;
  mIDsList.Free;
  mOutputList.Free;

end;


function GetExport(Self: TNxWebServicesHelper;ExportType: Integer;DayOffset: Integer):String;
var
  mObjectSpace: TNxCustomObjectSpace;
  mIDsList, mOutputList: TStringList;
  mSQL,mExportID, mDynSource, mFileName: String;
  mContext: TNxContext;
  mCreatedDate,mCorrectedDate:Extended;
  mBytes: TBytes;


begin
  Result:=EncodeBase64(TEncoding.Unicode.GetBytes('<?xml version="1.0" encoding="UTF-8"?><Empty></Empty>'));
  mIDsList:=TStringList.Create;
  mOutputList:=TStringList.Create;
  mObjectSpace := Self.ObjectSpace;
  mContext := NxCreateContext(mObjectSpace);
   if ExportType=0 then begin
      msql:=conSQL0;
      mExportID:=conExportID0;
      mFileName:=conFileName0;
      mDynSource:=conDynSource0;

  end;
  if ExportType=1 then begin
      if DayOffset>0 then begin;
      mCorrectedDate:=Date-DayOffset;
      mCreatedDate:=Date-DayOffset;
      mSQL:= format(conSQL1d, [IntToStr(trunc(mCreatedDate)), IntToStr(trunc(mCorrectedDate))]);
      end;
      if DayOffset=0 then msql:=conSQL1;
      mExportID:=conExportID1;
      mFileName:=conFileName1;
      mDynSource:=conDynSource1;

  end;
  if ExportType=2 then begin
      if DayOffset>0 then begin;
      mCorrectedDate:=Date-DayOffset;
      mCreatedDate:=Date-DayOffset;
      mSQL:= format(conSQL2d, [IntToStr(trunc(mCreatedDate)), IntToStr(trunc(mCorrectedDate))]);
      end;
      if DayOffset=0 then msql:=conSQL2;
      mExportID:=conExportID2;
      mFileName:=conFileName2;
      mDynSource:=conDynSource2;

  end;
  if ExportType=3 then begin
      msql:=conSQL3;
      mExportID:=conExportID3;
      mFileName:=conFileName3;
      mDynSource:=conDynSource3;

  end;
  if ExportType=4 then begin
      msql:=conSQL4;
      mExportID:=conExportID4;
      mFileName:=conFileName4;
      mDynSource:=conDynSource4;

  end;
    if ExportType=5 then begin
      msql:=conSQL5;
      mExportID:=conExportID5;
      mFileName:=conFileName5;
      mDynSource:=conDynSource5;

  end;
  if ExportType=6 then begin
      msql:=conSQL6;
      mExportID:=conExportID6;
      mFileName:=conFileName6;
      mDynSource:=conDynSource6;

  end;
  if ExportType=7 then begin
      if DayOffset>0 then begin;
      mCorrectedDate:=Date-DayOffset;
      mCreatedDate:=Date-DayOffset;
      mSQL:= format(conSQL7d, [IntToStr(trunc(mCreatedDate)), IntToStr(trunc(mCorrectedDate))]);
      end;
      if DayOffset=0 then msql:=conSQL7;
      mExportID:=conExportID7;
      mFileName:=conFileName7;
      mDynSource:=conDynSource7;

  end;
  if ExportType=8 then begin
      if DayOffset>0 then begin;
      mCorrectedDate:=Date-DayOffset;
      mCreatedDate:=Date-DayOffset;
      mSQL:= format(conSQL8d, [IntToStr(trunc(mCreatedDate)), IntToStr(trunc(mCorrectedDate))]);
      end;
      if DayOffset=0 then msql:=conSQL8;
      mExportID:=conExportID8;
      mFileName:=conFileName8;
      mDynSource:=conDynSource8;

  end;

  if ExportType=9 then begin
      if DayOffset>0 then begin;
      mCorrectedDate:=Date-DayOffset;
      mCreatedDate:=Date-DayOffset;
      mSQL:= format(conSQL9d, [IntToStr(trunc(mCreatedDate)), IntToStr(trunc(mCorrectedDate))]);
      end;
      if DayOffset=0 then msql:=conSQL9;
      mExportID:=conExportID9;
      mFileName:=conFileName9;
      mDynSource:=conDynSource9;

  end;

  if ExportType=10 then begin
      if DayOffset>0 then begin;
      mCorrectedDate:=Date-DayOffset;
      mCreatedDate:=Date-DayOffset;
      mSQL:= format(conSQL10d, [IntToStr(trunc(mCreatedDate)), IntToStr(trunc(mCorrectedDate))]);
      end;
      if DayOffset=0 then msql:=conSQL10;
      mExportID:=conExportID10;
      mFileName:=conFileName10;
      mDynSource:=conDynSource10;

  end;

  if ExportType=11 then begin
      if DayOffset>0 then begin;
      mCorrectedDate:=Date-DayOffset;
      mCreatedDate:=Date-DayOffset;
      mSQL:= format(conSQL11d, [IntToStr(trunc(mCreatedDate)), IntToStr(trunc(mCorrectedDate))]);
      end;
      if DayOffset=0 then msql:=conSQL11;
      mExportID:=conExportID11;
      mFileName:=conFileName11;
      mDynSource:=conDynSource11;

  end;
  if ExportType=12 then begin
      msql:=conSQL12;
      mExportID:=conExportID12;
      mFileName:=conFileName12;
      mDynSource:=conDynSource12;

  end;
  if ExportType=13 then begin
      msql:=conSQL13;
      mExportID:=conExportID13;
      mFileName:=conFileName13;
      mDynSource:=conDynSource13;

  end;
  if ExportType=14 then begin
      msql:=conSQL14;
      mExportID:=conExportID14;
      mFileName:=conFileName14;
      mDynSource:=conDynSource14;

  end;
  if ExportType=15 then begin
      msql:=conSQL15;
      mExportID:=conExportID15;
      mFileName:=conFileName15;
      mDynSource:=conDynSource15;

  end;

  if ExportType=16 then begin
      mSQL:= format(conSQL16d, [IntToStr(trunc(date-DayOffset)), IntToStr(trunc(Date))]);
      mExportID:=conExportID16;
      mFileName:=conFileName16;
      mDynSource:=conDynSource16;

  end;

  if ExportType=17 then begin
      mSQL:= format(conSQL17, [IntToStr(trunc(date-DayOffset))]);
      mExportID:=conExportID17;
      mFileName:=conFileName17;
      mDynSource:=conDynSource17;

  end;

  if ExportType=18 then begin
      msql:=conSQL18;
      mExportID:=conExportID18;
      mFileName:=conFileName18;
      mDynSource:=conDynSource18;


  end;
  if ExportType=19 then begin
      msql:=conSQL19;
      mExportID:=conExportID19;
      mFileName:=conFileName19;
      mDynSource:=conDynSource19;

  end;

  if ExportType=20 then begin
      if DayOffset>0 then begin;
      mCorrectedDate:=Date-DayOffset;
      mCreatedDate:=Date-DayOffset;
      mSQL:= format(conSQL20d, [IntToStr(trunc(mCreatedDate)), IntToStr(trunc(mCorrectedDate))]);
      end;
      if DayOffset=0 then msql:=conSQL20;
      mExportID:=conExportID20;
      mFileName:=conFileName20;
      mDynSource:=conDynSource20;

  end;


  mObjectSpace.SQLSelect(mSQL, mIDsList);
  if mIDsList.count>0 then begin
       NxExportByIDs(mContext,mIDsList,mDynSource,mExportID,0,'',mFileName);
        if FileExists(mFileName) then begin
        mOutputList.Clear;
          mOutputList.LoadFromFile(mFileName);
          mBytes := TEncoding.Unicode.GetBytes(mOutputList.Text);
          //Result:=EncodeBase64(mBytes);
          Result:=EncodeBase64(getfiletobytes(mFileName));
        end;
  end;
  //DeleteFile(mFileName);
  mContext.Free;
  mIDsList.Free;
  mOutputList.Free;

end;


function GetFileToBytes(AFileName: String;): TBytes;
var
  mMS: TMemoryStream;
  mStr: string;
begin
  mMS := TMemoryStream.Create();
  try
    mMS.LoadFromFile(AFileName);
    Result := mMS.GetBytes;
  finally
    mMS.Free;
  end;
end;

begin
end.