function POST_PrintDocument(AContext: TNXContext; AInput: TJSONSuperObject; APath: String): TJSONSuperObject;
var
  mPrintList:TStringList;
  mDynSource: string;
begin
  Result:= TJSONSuperObject.create;
  mPrintList:=TStringList.Create;
  try
    try
      mPrintList.Add(AInput.S['documentId']);
      if Printer.Printers.IndexOf(AInput.S['printerName']) = -1 then begin
        Result.S['status']:='error';
        Result.S['errorMessage']:= 'Nenalezela tiskárna s názvem '+AInput.S['printerName'];
        exit;
      end;
      mDynSource:= GetDynSource(AContext.GetObjectSpace,AInput.S['reportId']);
      if NxIsBlank(mDynSource) then begin
        Result.S['status']:='error';
        Result.S['errorMessage']:= 'Nenalezela tisková sestava s ID '+AInput.S['reportId'];
        exit;
      end;
      CFxReportManager.PrintByIDs(NxCreateContext(AContext.GetObjectSpace),mPrintList, mDynSource,AInput.S['reportId'],rtoPrint,pekPDF,AInput.S['printerName'], '');
      Result.S['status']:='ok';
      Result.S['errorMessage']:= '';
    except
      Result.S['status']:='error';
      Result.S['errorMessage']:= ExceptionMessage;
    end;
  finally
    mPrintList.Free;
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
    AOS.SQLSelect(Format(cSQL, [AValue]), mList);
    if mList.Count > 0 then
      Result := (mList.Strings[0]);
  finally
    mList.Free;
  end;
end;


begin
end.