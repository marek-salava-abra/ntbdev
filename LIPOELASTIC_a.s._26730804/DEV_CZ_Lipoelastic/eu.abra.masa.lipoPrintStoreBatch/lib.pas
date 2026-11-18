function POST_PrintBatch(AContext: TNXContext; AInput: TJSONSuperObject; APath: String): TJSONSuperObject;
var
 mStoreBatch_ID, mPrinterName, mReport_ID:string;
 mPrintList:TStringList;
begin
  Result := TJSONSuperObject.Create;
  mReport_ID:=AInput.S['Report_ID'];
  mPrinterName:=AInput.S['PrinterName'];
  mStoreBatch_ID:=AContext.SQLSelectFirstAsString('Select id from StoreBatches where name='+Quotedstr(AInput.S['StoreBatch']),'');
  if not(NxIsEmptyOID(mStoreBatch_ID)) then begin
    try
      mPrintList:=TStringList.create;
      mPrintlist.add(mStoreBatch_ID);
      CFxReportManager.PrintByIDs(AContext,mPrintList,GetDynSource(AContext.GetObjectSpace,mReport_ID),mReport_ID,rtoPrint,pekPDF,mPrinterName,'');
      mPrintList.free;
      Result.S['Result']:='Ok';
    except
      Result.S['Result']:='Error';
    end;
  end else begin
    Result.S['Result']:='NotFound';
  end;
end;


function GetDynSource (AOS : TNxCustomObjectSpace; AValue : string) : String;

const
  cSQL = 'SELECT DataSource FROM Reports WHERE ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [ AValue]), mList);
    if mList.Count > 0 then
      Result := (mList.Strings[0]);
  finally
    mList.Free;
  end;
end;

begin
end.