uses
  'StandardUnits.U_GetId';

////////////////////////////////////////////////////////////////////////////////
//vrati jmeno pro soubor slocene z nazvu BO a cisla dokladu (DisplayName)
function FileName_ForDocument(Doc: TNxCustomBusinessObject; Extension: string): string;
begin
  //nazev dokladu + cislo dokladu
  result:= Doc.DisplayTypeName+' '+ReplaceStr(Doc.DisplayName,'/','-');
  if(Extension <> '')then
    result:= result+'.'+Extension;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//vytiskne PDF nad predanym dokladem a ulozi jej do BusinesObjectu
//BO_Class - objekt, ktery obsahuje property BlobData (Class_EmailSentAttachContent, Class_DocumentData, Class_MsgAttachContent)
function PrintDocumentPDF2BusinesObject(BO: TNxCustomBusinessObject; BO_Class, Report_ID, DynSource_ID: string; var Size: integer): TNxOID;
var
  mData  : TNxCustomBusinessObject;
  Context: TNxContext;
  mSL_ID: TStringList;
begin
  if(DynSource_ID = '')then
    DynSource_ID:= getDynSource_ID(BO.ObjectSpace, Report_ID);

  //ulozim sestavu do objektu Data
  mSL_ID:= TStringList.Create;
  Context:= NxCreateContext(BO.ObjectSpace);
  mData := BO.ObjectSpace.CreateObject(BO_Class);
  try
    mSL_ID.Text:= BO.OID;
    mData.ExplicitTransaction:= BO.ObjectSpace.InTransaction;
    mData.New;
    mData.Prefill;
    mData.SetFieldValueAsBytes('BlobData',
      CFxReportManager.PrintByIDsToBytes(Context, mSL_ID, DynSource_ID, Report_ID, pekPDF)
    );
    mData.Save;
    result := mData.GetFieldValueAsString('ID');
    Size:= Length(mData.GetFieldValueAsBytes('BlobData'));
  finally
    mSL_ID.free;
    Context.free;
    mdata.free;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//vytiskne PDF nad seznamem predanych dokladu a ulozi jej do BusinesObjectu
//BO_Class - objekt, ktery obsahuje property BlobData (Class_EmailSentAttachContent, Class_DocumentData, Class_MsgAttachContent)
function PrintDocumentsPDF2BusinesObject(OS: TNxCustomObjectSpace; Doc_IDs: TStringList; BO_Class, Report_ID, DynSource_ID: string; var Size: integer): TNxOID;
var
  mData  : TNxCustomBusinessObject;
  Context: TNxContext;
begin
  if(DynSource_ID = '')then
    DynSource_ID:= getDynSource_ID(OS, Report_ID);

  //ulozim sestavu do objektu Data
  mData := OS.CreateObject(BO_Class);
  Context:= NxCreateContext(OS);
  try
    mData.ExplicitTransaction:= OS.InTransaction;
    mData.New;
    mData.Prefill;
    mData.SetFieldValueAsBytes('BlobData',
      CFxReportManager.PrintByIDsToBytes(Context, Doc_IDs, DynSource_ID, Report_ID, pekPDF)
    );
    mData.Save;
    result := mData.GetFieldValueAsString('ID');
    Size:= Length(mData.GetFieldValueAsBytes('BlobData'));
  finally
    Context.free;
    mdata.free;
  end;
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//Z tiskove sestavy zjisti DynSQL
function PrintReport_GetDynSQL(OS: TNxCustomObjectSpace; Report_ID: string): string;
begin
  if(NxIsEmptyOID(Report_ID))then RaiseException('PrintReport_GetDynSQL: Report_ID je prázdné.');
  result:= getFieldFromId(OS, 'Reports', Report_ID, 'DataSource');
  if(result = '')then RaiseException('PrintReport_GetDynSQL: DynSQL je prázdné.');
end;
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//vrati DynSource_ID pro konkretni report
function getDynSource_ID(OS: TNxCustomObjectSpace; Report_ID: string): string;
begin
  result:= getFieldFromId(OS, 'Reports', Report_ID, 'DataSource');
end;
////////////////////////////////////////////////////////////////////////////////

begin
end.