uses
  'eu.abra.PostProviders.uConst',
  'eu.abra.PostProviders.uIniFile',
  'eu.abra.PostProviders.uProgressForm',
  'eu.abra.PostProviders.uWSFunc',
  'eu.abra.PostProviders.uLanguage',
  'eu.abra.PostProviders.uCustomScript';




//Provede tisk PDF dokumentů připojených k dokladům
function PrintDocumentLabel(const AOS : TNxCustomObjectSpace; const AIDs : TStringList; const APostProviderBO: TNxCustomBusinessObject; const aPrintType: integer; APrinterName:String=''):Boolean;
var i: integer;
    mList, mTmpIDs: TStringList;
    mBODocumentCon, mBOPDM: TNxCustomBusinessObject;
    mFileName, mPrinterName: string;
    mDataSet :  TMemoryDataset;
begin
  mFileName := '';
  mList := nil;
  mTmpIDs := nil;
  mBODocumentCon := nil;
  mBODocumentCon := AOS.CreateObject(Class_DocumentContent);
  mList := TStringList.Create();
  mTmpIDs := TStringList.Create();
  mDataSet := TMemoryDataset.Create(nil);
  mBOPDM := AOS.CreateObject(Class_PDMIssuedDoc);
  try
    for i := 0 to AIDs.Count - 1 do
    begin
      mTmpIDs.Add(QuotedStr(AIDs[i]));
    end;
    aOS.SQLSelect2('select distinct dc.id as Document_ID, pd.id as PDMDoc_ID,pd.postnumber from relations a ' +
                  ' join documentcontents dc on a.rightside_id = dc.parent_id'+
                  ' left join documents doc on doc.id = dc.parent_id '+
                  ' join pdmIssuedDocs pd on pd.id = a.LEFTSIDE_ID '+
                  ' where a.rel_def = ' + IntToStr(cRelDefDocument)+
                  ' and doc.X_PD_DPD_PrintType = ' + IntToStr(aPrintType)+
                  ' and a.LEFTSIDE_ID in ('+ mTmpIDs.CommaText + ') order by pd.postnumber ',mDataSet);
    if mDataSet.Active then
      mDataSet.First;
    while not mDataSet.Eof do
    begin
      mBOPDM.Load(mDataSet.FieldByName('PDMDoc_ID').AsString,nil);
      mBODocumentCon.Load(mDataSet.FieldByName('Document_ID').AsString,nil);

      mFileName := SaveDocumentContentTMPFile(AOS, mBODocumentCon);
      mPrinterName := APrinterName;
      if mPrinterName = '' then
        mPrinterName := RunScript_PrintHook(AOS, ObjToInt(mBOPDM), cScriptGetPrinterNameHook);
      OutputDebugString('Tiskárna získaná z háčku: '+ mPrinterName);
      OutputDebugString('Dočasný soubor: '+ mFileName);

      if mPrinterName = '' then
      begin
        if aPrintType = 1 then
          mPrinterName := NxTrim( GetExtrasSetings('PrintLabel','PrinterName',''), '"')
        else
          mPrinterName := NxTrim( GetExtrasSetings('Print','PrinterName',''), '"')
        //Spuštění skriptu pro získání názvu. Pokud není, pak zůstane původní
      end;


      if aPrintType = 1 then
      begin
        if GetExtrasSetings('PDFXCview','Enabled','N') = 'A' then
          DoPrintXChange(mPrinterName , mFileName, GetExtrasSetings('PDFXCview','Path','xx') )
        else
        begin
          OutputDebugString('ShellAPI.PrintFile '+'"'+NxTrim( GetExtrasSetings('PrintLabel','PrinterName',''), '"')+'"' +' ; ' +mFileName);
          ShellAPI.PrintFile(mFileName ,'"'+NxTrim( GetExtrasSetings('PrintLabel','PrinterName',''), '"')+'"');
        end;

      end
      else
      begin
        if GetExtrasSetings('PDFXCview','Enabled','N') = 'A' then
          DoPrintXChange( mPrinterName, mFileName, GetExtrasSetings('PDFXCview','Path','xx') )
        else
        begin
          ShellAPI.PrintFile(mFileName,'"'+NxTrim (GetExtrasSetings('Print','PrinterName',''),'"')+'"');
          OutputDebugString('ShellAPI.PrintFile '+'"'+NxTrim (GetExtrasSetings('Print','PrinterName',''),'"')+'"' +' ; ' +mFileName);
        end;
      end;

      mDataSet.Next;
    end;



  finally
    mBOPDM.Free;
    mDataSet.free;
    if mList <> nil then
      mList.Free;
    if mBODocumentCon <> nil then
      mBODocumentCon.Free;
    if mTmpIDs <> nil then
      mTmpIDs.Free;
  end;
end;




//řeší dohledání v rámci problému s redirectem
function DoPrintXChange(const APrinterName:String;const AFileName:String; PathToPDFXCahnge: String = 'S:\ABRA-APPS\PDFXCview\PDFXCview.exe'):String;
var  mList : TStringList;
    i:integer;
    mPrinters : TPrinter;
    mPar1,mPar2,mSettingFile, mResPrinterName:String;

begin
  mSettingFile :='';
  if not FileExists(PathToPDFXCahnge) then
    RaiseException(lng_msg_internalError1+PathToPDFXCahnge);
  mList := TStringList.Create();
  try
    mResPrinterName := NxTrim(APrinterName,'"');
    if UpperCase(GetExtrasSetings('PDFXCview','RDPPrint','N')) = 'A' then
    begin
      mResPrinterName := '';
      mPrinters := Printer;
      mList.Text := mPrinters.Printers.Text;
      OutputDebugString(mList.Text);
      Result := '';
      for i:= 0 to mList.Count -1 do
      begin
        OutputDebugString('--- '+mList[i] + ' = ' +NxTrim(APrinterName,'"'));
        if ContainsText(mList[i],NxTrim(APrinterName,'"')) then
        begin
          mResPrinterName := NxTrim(mList[i],'"');
          OutputDebugString('+++ '+mResPrinterName);
        end;
      end;
    end;

     if UpperCase(GetExtrasSetings('PDFXCview','ShowUI','N')) = 'A' then
      mPar1:=' '+'"'+AFileName+'" '
     else
      mPar1:=' /printto:default=no "'+mResPrinterName+'" "'+AFileName+'" ';

     if (Trim(GetExtrasSetings('PDFXCview','SettingFile','')) <> '') then
     begin
      mSettingFile :='';
      mSettingFile := NxTrim(GetExtrasSetings('PDFXCview','SettingFile',''),'"');
      if not FileExists(mSettingFile) then
        RaiseException(lng_msg_internalError2+mSettingFile);
      mPar2:=' /importp "'+mSettingFile+'" ';
     end
     else
      mPar2:='';

    OutputDebugString('ABRA RUN CMD: '+PathToPDFXCahnge+mPar1+mPar2);
    if NxExecFile(PathToPDFXCahnge+mPar1+mPar2,false,true) then
      OutputDebugString('NxExecFile OK');

    (*OutputDebugString(PathToPDFXCahnge+' /printto:default=no "'+mResPrinterName+'" "'+AFileName+'" /importp "'+ExtractFilePath(PathToPDFXCahnge)+'Settings.dat');
    if NxExecFile(PathToPDFXCahnge+' /printto:default=no "'+mResPrinterName+'" "'+AFileName+'" /importp "'+ExtractFilePath(PathToPDFXCahnge)+'Settings.dat',false,true) then
      OutputDebugString(PathToPDFXCahnge+' /printto:default=no "'+mResPrinterName+'" "'+AFileName+'" /importp "'+ExtractFilePath(PathToPDFXCahnge)+'Settings.dat');
    *)
  finally
    mList.Free;
  end;
end;



//podle class_document dohledá blobbada a uloží do temp file. Vrací cestu k tomuto temp file.
function SaveDocumentContentTMPFile(const AOS : TNxCustomObjectSpace; const ABO: TNxCustomBusinessObject):string;
var mBOContent, mBOData : TNxCustomBusinessObject;
    mFileName: String;
    mStream: TMemoryStream;
    i: integer;
begin
  Result := '';
  mFileName := '';
  mStream := nil;
  try
    if not NxCreateTempFile(mFileName) then
      RaiseException(lng_msg_CantCreateExportFile);
    mStream := TMemoryStream.Create();
    mBOData := ABO.GetMonikerForFieldCode(ABO.GetFieldCode('DATA_ID')).BusinessObject;
    if not Assigned(mBOData) then
      RaiseException(lng_msg_internalError3);
    mStream.SetBytes(mBOData.GetFieldValueAsBytes('BLOBDATA'));
    if mStream.Size <= 0 then
      RaiseException(lng_msg_internalError3);

    if not RenameFile(mFileName,NxTrimL(NxTrimR(mFileName,'\'),'.') + '.pdf') then
      RaiseException(lng_msg_internalError4);
    mFileName := NxTrimL(NxTrimR(mFileName,'\'),'.') + '.pdf';
    mStream.SaveToFile(mFileName);
    Result := mFileName;
  finally
    if mStream <> nil then
      mStream.Free;

  end;
end;




//zjistí existenci připojeného dokumentu. Plní CreateIDs pokud obsahuje záznam. znamená to, že doklad nemá přílohu k PDM odeslané poště
procedure GetExistIDsDocumentRawDataLabel(const AOS : TNxCustomObjectSpace; const AIDs : TStringList; var CreateIDs : TStringList; const APostProviderBO: TNxCustomBusinessObject);
var i: integer;
    mTmpIDs: TStringList;
begin
  mTmpIDs := nil;
  mTmpIDs := TStringList.Create();
  try
    for i := 0 to AIDs.Count - 1 do
    begin
      mTmpIDs.Add(AIDs[i]);
    end;
    aOS.SQLSelect('select a.id from pdmissueddocs a where a.X_PD_RawData = '''' '+
                  ' and a.id in (' +mTmpIDs.CommaText+')', CreateIDs);
  finally
    if mTmpIDs <> nil then
      mTmpIDs.Free;
  end;
end;



procedure OdstranQuoted(var AIDs:TStringList);
var i:Integer;
begin
  for i := 0 to AIDs.Count -1 do
  begin
    AIDs[i] :=NxTrim(AIDs[i],'''');
  end;
end;


function GetPrintTypeByIndex(const aWhat:Integer):Integer;
begin
  case aWhat of
  0: Result := 1;
  1: Result := 2;
  end;
end;


begin
end.