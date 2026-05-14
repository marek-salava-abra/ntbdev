
const cMainFilePath = 'C:\ABRA\ABBY\';
      cFilesFilter = '*.pdf';
      cReportII_ID = '3W07000101';


      cSQLSelectIssuedInvoiceByBillOfDelivery =  'select distinct II.id as ID   '+
                                                  'from ISSUEDINVOICES2 II2 '+
                                                  'join ISSUEDINVOICES II on II.ID = II2.PARENT_ID '+
                                                  'join STOREDOCUMENTS2 SD2 on SD2.ID = II2.PROVIDEROW_ID '+
                                                  'where SD2.parent_id = ''%s'' ';
      cSQLSelectIssuedInvoiceByReceivedOrder =  'select distinct II.id as ID   '+
                                                  'from ISSUEDINVOICES2 II2 '+
                                                  'join ISSUEDINVOICES II on II.ID = II2.PARENT_ID '+
                                                  'join STOREDOCUMENTS2 SD2 on SD2.ID = II2.PROVIDEROW_ID '+
                                                  'join STOREDOCUMENTS SD on SD.ID = SD2.Parent_id and SD.DocumentType = ''21'' '+
                                                  'join ReceivedOrders2 RO2 on RO2.ID = SD2.PROVIDEROW_ID '+
                                                  'where RO2.parent_id = ''%s'' ';

{GetIssuedInvoiceFromPDMDocumentID
Vratí ID faktury pokud existuje}
function GetIssuedInvoiceFromPDMDocumentID(AOS:TNxCustomObjectSpace;SourceDocType:String;SourceDocID:String):String;
begin
  Result:= '';
  if not CFxOID.IsEmptyOrFull(SourceDocID) then
  begin
    case SourceDocType of
    '03':Result:= SourceDocID;
    '21':Result:= AOS.SQLSelectFirstAsString( Format(cSQLSelectIssuedInvoiceByBillOfDelivery,[SourceDocID]) ,'');
    'RO':Result:= AOS.SQLSelectFirstAsString( Format(cSQLSelectIssuedInvoiceByReceivedOrder,[SourceDocID]) ,'');
    end;
  end;

end;

function QRGetIssuedInvoiceFromPDMDocumentID(AReportHelper:TNxQRScriptHelper;SourceDocType:String;SourceDocID:String):String;
begin
  Result := GetIssuedInvoiceFromPDMDocumentID(AReportHelper.ObjectSpace, SourceDocType, SourceDocID);
end;


function QRReportToBase64(AReportHelper:TNxQRScriptHelper;DocType:String;DocID:String):String;
begin
  Result := ReportToBase64(AReportHelper.ObjectSpace,DocType,DocID);
end;


{ReportToBase64}
function ReportToBase64(AOS:TNxCustomObjectSpace;DocType:String;DocID:String):String;
var mFileName :String;
    mStream:TMemoryStream;
begin
  Result := '';
  if not CFxOID.IsEmptyOrFull(DocID) then
    Result := PrintReportToBase64(AOS, cReportII_ID, DocID);
end;

function PrintReportToBase64(AOS: TNxCustomObjectSpace; AreportID:String; ADoc:String;):String;
var mBO:TNxCustomBusinessObject;
    mReport: CFxReportManager;
    mList : TStringList;
    mByte :TBytes;
begin
  Result := '';
  mBO:= AOS.CreateObject(Class_Report);
  mReport := CFxReportManager.Create;
  mList := TStringList.Create;
  try
    mBO.Load(AreportID,nil);
    mList.Clear;
    mList.add(ADoc);
    mByte := mReport.PrintByIDsToBytes(NxCreateContext(AOS) ,mList,mBO.GetFieldValueAsString('DataSource'),mBO.OID, pekPDF);
    Result :='{'+ EncodeBase64( mByte ) + '}';
  finally
    mBO.Free;
    mReport.Free;
    mList.Free;
  end;
end;

(* Klasika, bez nové Fce

{ReportToBase64}
function _ReportToBase64(AOS:TNxCustomObjectSpace;DocType:String;DocID:String):String;
var mFileName :String;
    mStream:TMemoryStream;
begin
  Result := '';
  if not CFxOID.IsEmptyOrFull(DocID) then
  begin

    //NxEvalObjectExprAsString(AOS,'NxMakeAndGetExportFolder(''B2B-Export'') + CfxDateToStr(NxNow(), ''YYYYMMDD-hhmmss'', '''')+ ''- B2B.csv''');
    mFileName := '';
    mFileName := NxEvalParametersExprAsString(AOS, nil,  'NxMakeAndGetExportFolder(''BB-Export'') ' ) +DocType+DocID+'.pdf';
    OutputDebugString(mFileName);
    try
      PrintReport(AOS, cReportII_ID, DocID, rtoFile, ExtractFilePath(mFileName),ExtractFileName(mFileName) );
      if FileExists(mFileName) then
      begin
        mStream := TMemoryStream.Create();
        try
          mStream.LoadFromFile(mFileName);
          Result := EncodeBase64(mStream.GetBytes);

        finally
          mStream.Free;
        end;
      end;
    finally
      if FileExists(mFileName) then
        DeleteFile(mFileName);
    end;

  end;

end;

procedure PrintReport(AOS: TNxCustomObjectSpace; AreportID:String; ADoc:String; APrintType:Integer; AFolderPath,AFileName:String = '');
var mBO:TNxCustomBusinessObject;
    mReport: CFxReportManager;
    mList : TStringList;
begin
  mBO:= AOS.CreateObject(Class_Report);
  mReport := CFxReportManager.Create;
  mList := TStringList.Create;
  try
    mBO.Load(AreportID,nil);
    mList.Clear;
    mList.add(ADoc);


    mReport.PrintByIDs(NxCreateContext(AOS) ,mList,mBO.GetFieldValueAsString('DataSource'),mBO.OID, APrintType,pekPDF,AFolderPath,AFileName);
  finally
    mBO.Free;
    mReport.Free;
    mList.Free;
  end;
end;
*)



begin
end.