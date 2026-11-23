procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
  mBODList: TStringList;
  mRows: TNxCustomBusinessMonikerCollection;
  mRowBO, mBO, mOrderBO: TNxCustomBusinessObject;
  i: integer;
  mOtherStore: boolean;
  mPrintForm_ID, mOrder_ID, mDefaultPrinter, mPrinterName, mAllPrinter: string;
  mInvList, mIIList, mQueryList: TStringList;
  mImportMan: TNxDocumentImportManager;
  mInputParams: TNxParameters;
  mParam: TNxParameter;
  mPrinterExists: Boolean;
  mInvoiceCreated: Boolean;
begin
  mInvoiceCreated := false;

  if (Self.GetFieldValueAsString('PMState_ID') = 'SDDEF00000') then begin
    if CFxNxRuntime.NxGetEnvironmentType = reWebServices then begin
      mDefaultPrinter := 'HP_M521_Promos';
      mPrinterExists := false;
      Printer.PrinterIndex := -1;
      mPrinterName := Printer.Printers[Printer.PrinterIndex];

      for i := 0 to Printer.Printers.Count - 1 do begin
        mAllPrinter := mAllPrinter + ', ' + Printer.Printers[i];
        if not(mPrinterExists) and (Printer.Printers[i] = mDefaultPrinter) then
          mPrinterExists := true;
      end;

      mInvList := TStringList.Create;
      Self.ObjectSpace.SQLSelect('SELECT id FROM issuedinvoices2 WHERE Provide_ID = ' + QuotedStr(Self.OID), mInvList);

      if mInvList.Count = 0 then begin
        mIIList := TStringList.Create;
        mQueryList := TStringList.Create;
        Self.ObjectSpace.SQLSelect('SELECT Provide_ID FROM StoreDocuments2 WHERE Parent_ID = ' + QuotedStr(Self.OID) + ' AND Provide_ID IS NOT NULL', mQueryList);

        if mQueryList.Count > 0 then
          mOrder_ID := mQueryList.Strings[0];

        if not(NxIsEmptyOID(mOrder_ID)) then begin
          mOrderBO := Self.ObjectSpace.CreateObject(Class_ReceivedOrder);
          mOrderBO.Load(mOrder_ID, nil);

          if mOrderBO.GetFieldValueAsString('DocQueue_ID.code') = 'OPP' then begin
            mInputParams := TNxParameters.Create;
            mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
            if morderbo.getfieldvalueasinteger('TradeType') = 2 then
              mParam.AsString := '1800000101'
            else      
            mParam.AsString := '4000000101';

            if not(NxIsEmptyOID(mOrder_ID)) then begin
              mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
              mParam.AsString := mOrder_ID;
            end else begin
              mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
              mParam.AsString := Self.OID;
            end;

            mImportMan := NxCreateDocumentImportManager(Self.ObjectSpace, Class_BillOfDelivery, Class_IssuedInvoice);
            mImportMan.AddInputDocument(Self.OID);
            mImportMan.LoadParams(mInputParams);
            mImportMan.Execute;
            if morderbo.getfieldvalueasinteger('TradeType') = 2 then
              mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', '1800000101')
            else
            mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', '4000000101');
            mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID', Self.GetFieldValueAsString('Firm_ID'));
            mImportMan.OutputDocument.SetFieldValueAsString('FirmOffice_ID', Self.GetFieldValueAsString('FirmOffice_ID'));
            mImportMan.OutputDocument.SetFieldValueAsString('CreatedBy_ID', Self.GetFieldValueAsString('CorrectedBy_ID'));
            mImportMan.OutputDocument.Save;

            mIIList.Add(mImportMan.OutputDocument.OID);
            mInvoiceCreated := true;

            try
              if mPrinterExists then begin
                CFxReportManager.PrintByIDs(NxCreateContext(Self.ObjectSpace), mIIList, GetDynSource(Self.ObjectSpace, '6LH0000101'), '6LH0000101', rtoPrint, pekPDF, mDefaultPrinter, '');
                NxScriptingLog.WriteEvent(logInfo, 'doklad se vytiskl');
              end else begin
                NxScriptingLog.WriteEvent(logInfo, 'Nenašel jsem tiskárnu ' + mDefaultPrinter);
              end;
            except
              NxScriptingLog.WriteEvent(logInfo, 'Vyjímka' + #13 + #13 + ExceptionMessage);
            end;

            NxScriptingLog.WriteEvent(logInfo, 'Po tisku faktury');
          end;
        end;
      end;

      if not mInvoiceCreated then begin
        mBODList := TStringList.Create;
        mBODList.Add(Self.OID);
        mPrintForm_ID := Self.GetFieldValueAsString('Firm_ID.X_FormDL_ID');
        if not(NxIsEmptyOID(mPrintForm_ID)) then begin
          CFxReportManager.PrintByIDs(NxCreateContext(Self.ObjectSpace), mBODList, '05DOXDMCSZDL3FUD00C5OG4NF4', mPrintForm_ID, rtoPrint, pekPDF, mDefaultPrinter, '');
          CFxReportManager.PrintByIDs(NxCreateContext(Self.ObjectSpace), mBODList, '05DOXDMCSZDL3FUD00C5OG4NF4', mPrintForm_ID, rtoPrint, pekPDF, mDefaultPrinter, '');
        end;

        mBODList.Free;
      end;
    end;
  end;

  if not(NxGetActualUserID_1(Self) in ['1730000101', 'SUPER00000']) then begin
    mBO := Self.ObjectSpace.CreateObject(Class_BillOfDelivery);
    mBO.Load(Self.OID, nil);

    if mBO.GetFieldValueAsString('Docqueue_id.Code') in ['DLR', 'DLZ', 'DLD'] then begin
      if mBO.GetFieldValueAsString('PMState_ID') = '2000000001' then begin
        if not (osSaving in mBO.InternalState) then
          mBO.PMChangeState('SDDEF00000');
      end;
    end;
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