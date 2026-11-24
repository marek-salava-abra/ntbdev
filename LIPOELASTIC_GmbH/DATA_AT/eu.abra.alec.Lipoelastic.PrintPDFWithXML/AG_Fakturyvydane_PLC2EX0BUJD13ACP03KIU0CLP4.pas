uses
  '.QR';

const
  cISSUED_INVOICE_DYNSOURCE = '40SBPEINEFD13ACM03KIU0CLP4';
  cPRINT_REPORT_ID = '~000000002';

{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction:= Self.GetNewAction;
  mAction.Name:= 'actPrintPDFWithXML';
  mAction.Caption:= 'PDF + ebInterface XML (Entwurf)';
  mAction.Category:= 'tabList';
  mAction.OnExecute:= @PrintPDFWithXML;
  mAction:= Self.GetNewAction;
  mAction.Name:= 'actExportEbInterfaceXML';
  mAction.Caption:= 'ebInterface XML (Entwurf)';
  mAction.Category:= 'tabList';
  mAction.OnExecute:= @ExportEbInterfaceXML;
end;

procedure ExportEbInterfaceXML(Sender: TComponent);
var
  mSite: TSiteForm;
  mBO: TNxCustomBusinessObject;
  mStream: TMemoryStream;
  mSaveDialog: TSaveDialog;
begin
  mSite:= Sender.Site;
  mBO:= TDynSiteForm(mSite).CurrentObject;
  if not Assigned(mBO) then RaiseException('ebInterface: select an issued invoice.');
  mStream:= TMemoryStream.Create;
  try
    mStream.SetBytes(BuildEbInterfaceXML(mBO));
    mSaveDialog:= TSaveDialog.Create(nil);
    try
      mSaveDialog.Filter:= 'ebInterface XML (*.xml)|*.xml';
      mSaveDialog.DefaultExt:= 'xml';
      mSaveDialog.FileName:= NxSearchReplace(mBO.DisplayName, '/', '-', [srAll]) + '.xml';
      if mSaveDialog.Execute then mStream.SaveToFile(mSaveDialog.FileName);
    finally
      mSaveDialog.Free;
    end;
  finally
    mStream.Free;
    // CurrentObject belongs to the agenda; do not free it here.
  end;
end;

procedure PrintPDFWithXML(Sender: TComponent);
var
  mSite: TSiteForm;
  mBO: TNxCustomBusinessObject;
  mPDF: TPDFDocument;
  mStreamPDF, mStreamXML: TMemoryStream;
  mList: TStringList;
  mBytesPDF, mBytesXML: TBytes;
  mIndex: Integer;
  mSaveDialog: TSaveDialog;
  mFileName: string;
begin
  mSite:= Sender.Site;
  mBO:= TDynSiteForm(mSite).CurrentObject;
  if not Assigned(mBO) then RaiseException('ebInterface: select an issued invoice.');
  mList:= TStringList.Create;
  mStreamPDF:= TMemoryStream.Create;
  mStreamXML:= TMemoryStream.Create;
  mPDF:= TPDFDocument.Create(nil);
  try
    mList.Add(mBO.OID);
    mFileName:= NxSearchReplace(mBO.DisplayName, '/', '-', [srAll]) + ' - ' + mBO.GetFieldValueAsString('VarSymbol');

    // Build directly from the invoice. No AEF dependency and no PDF inside XML.
    mBytesXML:= BuildEbInterfaceXML(mBO);
    mStreamXML.SetBytes(mBytesXML);
    mBytesPDF:= CFxReportManager.PrintByIDsToBytes(mSite.SiteContext, mList, cISSUED_INVOICE_DYNSOURCE, cPRINT_REPORT_ID, pekPDF, '');
    mStreamPDF.SetBytes(mBytesPDF);

    mPDF.Open(mStreamPDF);

    mIndex:= mPDF.AddAttachedFile;

    mPDF.AttachedFiles[mIndex].LoadFromStream(mStreamXML);
    mPDF.AttachedFiles[mIndex].FileName:= mFileName + '.xml';
    mPDF.AttachedFiles[mIndex].Description:= 'ebInterface 6.1 draft';
    mPDF.AttachedFiles[mIndex].SubType:= 'application/xml';

    mPDF.Close(True);


    mSaveDialog:= TSaveDialog.Create(nil);
    try
      mSaveDialog.Filter := 'PDF (*.pdf)|*.pdf';
      mSaveDialog.DefaultExt := 'pdf';
      mSaveDialog.FileName := mFileName + '.pdf';

      if mSaveDialog.Execute then
      begin
        mStreamPDF.SaveToFile(mSaveDialog.FileName);
      end;
    finally
      mSaveDialog.Free;
    end;
  finally
    mStreamPDF.Free;
    mStreamXML.Free;
    mPDF.Free;
    mList.Free;
    mBO.Free;
  end;
end;

begin
end.
