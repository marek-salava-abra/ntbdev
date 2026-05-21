const
  cISSUED_INVOICE_DYNSOURCE = '40SBPEINEFD13ACM03KIU0CLP4';
  cPRINT_REPORT_ID = '~000000002';
  cEXPORT_REPORT_ID = '~000000301';

{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction:= Self.GetNewAction;
  mAction.Name:= 'actPrintPDFWithXML';
  mAction.Caption:= '## Print PDF+XML ##';
  mAction.Category:= 'tabList';
  mAction.OnExecute:= @PrintPDFWithXML;
end;


procedure PrintPDFWithXML(Sender: TComponent);
var
  mSite: TSiteForm;
  mOS: TNxCustomObjectSpace;
  mBO: TNxCustomBusinessObject;
  mPDF: TPDFDocument;
  mPDFAttachment: TPDFFileAttachment;
  mStreamPDF, mStreamXML: TMemoryStream;
  mList: TStringList;
  mBytesPDF, mBytesXML: TBytes;
  mIndex: Integer;
  mSaveDialog: TSaveDialog;
  mFileName, mFilePath: string;
begin
  mSite:= Sender.Site;
  mOS:= mSite.BaseObjectSpace;

  mFileName:= '';
  mFilePath:= '';

  mBO:= TDynSiteForm(mSite).CurrentObject;
  mList:= TStringList.Create;
  mStreamPDF:= TMemoryStream.Create;
  mStreamXML:= TMemoryStream.Create;
  mPDF:= TPDFDocument.Create(nil);
  //mPDFAttachment:= TPDFFileAttachment.Create;
  try
    mList.Add(mBO.OID);
    mFileName:= NxSearchReplace(mBO.DisplayName, '/', '-', [srAll]) + ' - ' + mBO.GetFieldValueAsString('VarSymbol');

    mBytesPDF:= CFxReportManager.PrintByIDsToBytes(mSite.SiteContext, mList, cISSUED_INVOICE_DYNSOURCE, cPRINT_REPORT_ID, pekPDF, '');
    mStreamPDF.SetBytes(mBytesPDF);

    mBytesXML:= CFxReportManager.ExportByIDsToBytes(mSite.SiteContext, mList, cISSUED_INVOICE_DYNSOURCE, cEXPORT_REPORT_ID);
    mStreamXML.SetBytes(mBytesXML);

    mPDF.Open(mStreamPDF);

    mIndex:= mPDF.AddAttachedFile;

    mPDF.AttachedFiles[mIndex].LoadFromStream(mStreamXML);
    mPDF.AttachedFiles[mIndex].FileName:= mFileName + '.xml';
    mPDF.AttachedFiles[mIndex].Description:= 'Invoice';
    //mPDF.AttachedFiles[mIndex].SubType:= 'application/xml';
    mPDF.AttachedFiles[mIndex].SubType:= 'data';

    mPDF.Close(True);


    mSaveDialog:= TSaveDialog.Create(nil);
    try
      mSaveDialog.Filter := 'Files (*.pdf)|*.PDF|Files (*.pdf)|*.PDF';
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
    //mPDFAttachment.Free;
    mList.Free;
    mBO.Free;
  end;
end;

begin
end.