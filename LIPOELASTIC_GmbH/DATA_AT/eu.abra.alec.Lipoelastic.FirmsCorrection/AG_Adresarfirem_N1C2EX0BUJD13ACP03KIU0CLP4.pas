procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImportFirmsXLSX';
  mAction.Caption := '## Correct firms (XLSX) ##';
  mAction.Items.Add('Correct firms (XLSX)');
  mAction.Items.Add('Correct firm offices (XLSX)');
  mAction.Category := 'tabList';
  mAction.OnExecuteItem := @CorrectionSwitch;
end;

procedure CorrectionSwitch(Sender: TComponent; AIndex: integer);
begin
  case AIndex of
    0: CorrectionFirmsImport_XLSX(Sender);
    1: CorrectionFirmOfficesImport_XLSX(Sender);
  end;
end;


procedure CorrectionFirmsImport_XLSX(Sender: TComponent);
var
  mSite: TSiteForm;
  mOS: TNxCustomObjectSpace;
  mBO: TNxCustomBusinessObject;
  i, mRowCount: integer;
  mExcel, mWorkbook, mWorksheet, mUsedRange: Variant;
  mFileName, mFirm_ID, mLog: string;
  mExactID, mCode, mName, mAddressLine1, mAddressLine2, mPostCode, mCity, mCountryCode, mEmail, mFax, mPhone, mVATNumber, mLastName, mFirstName : string;
begin
  mSite:= Sender.Site;
  mOS:= mSite.BaseObjectSpace;

  mLog:= '';

  if not SelectImportFile(mSite, mFileName) then exit;

  try
    try
      mExcel:= CreateOleObject('Excel.Application');
    except
      NxShowSimpleMessage('Excel application is not installed!', nil);
      exit;
    end;

    try
      mExcel.Visible:= false;
      mWorkbook:= mExcel.Workbooks.Open(mFileName);
      try
        mWorksheet := mWorkbook.Worksheets[1];
        mUsedRange := mWorksheet.UsedRange;
        mRowCount := mUsedRange.Rows.Count;

        WaitWin.StartProgress('Processing', 'Processing', mRowCount);

        for i:= 2 to mRowCount do
        begin
          WaitWin.StepIt;

          mExactID      := Trim(VarToStr(mUsedRange.Cells[i, 1].Value));
          mCode         := Trim(VarToStr(mUsedRange.Cells[i, 2].Value));
          mName         := Trim(VarToStr(mUsedRange.Cells[i, 3].Value));
          mAddressLine1 := Trim(VarToStr(mUsedRange.Cells[i, 4].Value));
          mAddressLine2 := Trim(VarToStr(mUsedRange.Cells[i, 5].Value));
          mPostCode     := Trim(VarToStr(mUsedRange.Cells[i, 6].Value));
          mCity         := Trim(VarToStr(mUsedRange.Cells[i, 7].Value));
          mCountryCode  := Trim(VarToStr(mUsedRange.Cells[i, 8].Value));
          mEmail        := Trim(VarToStr(mUsedRange.Cells[i, 9].Value));
          mFax          := Trim(VarToStr(mUsedRange.Cells[i,10].Value));
          mPhone        := Trim(VarToStr(mUsedRange.Cells[i,11].Value));
          mVATNumber    := Trim(VarToStr(mUsedRange.Cells[i,12].Value));

          mLastName     := Trim(VarToStr(mUsedRange.Cells[i,13].Value));
          mFirstName    := Trim(VarToStr(mUsedRange.Cells[i,14].Value));


          mFirm_ID:= GetFirm_ID(mOS, mExactID);
          if NxIsEmptyOID(mFirm_ID) then
          begin
            mLog:= mlog + IntToStr(i) + ' - '+mExactID + ' - Not found' + nxCrLf;
            continue;
          end;

          mBO:= mOS.CreateObject(Class_Firm);
          try
            mBO.Load(mFirm_ID, nil);
            if mCode <> 'NULL'          then mBO.SetFieldValueAsString('Code', NxLeft(mCode, 20));
            if mName <> 'NULL'          then mBO.SetFieldValueAsString('Name', NxLeft(mName, 220));
            if mVATNumber <> 'NULL'     then mBO.SetFieldValueAsString('VATIdentNumber', NxLeft(mVATNumber, 20));

            if mAddressLine1 <> 'NULL'  then mBO.SetFieldValueAsString('ResidenceAddress_ID.Street', NxLeft(mAddressLine1, 60));
            if mAddressLine2 <> 'NULL'  then mBO.SetFieldValueAsString('ResidenceAddress_ID.X_AddressLine_2', NxLeft(mAddressLine2, 250));
            if mPostCode <> 'NULL'      then mBO.SetFieldValueAsString('ResidenceAddress_ID.PostCode', NxLeft(mPostCode, 10));
            if mCity <> 'NULL'          then mBO.SetFieldValueAsString('ResidenceAddress_ID.City', NxLeft(mCity, 60));
            if mCountryCode <> 'NULL'   then mBO.SetFieldValueAsString('ResidenceAddress_ID.CountryCode', NxLeft(mCountryCode, 3));
            if mEmail <> 'NULL'         then mBO.SetFieldValueAsString('ResidenceAddress_ID.EMail', NxLeft(mEmail, 320));
            if mFax <> 'NULL'           then mBO.SetFieldValueAsString('ResidenceAddress_ID.FaxNumber', NxLeft(mFax, 30));
            if mPhone <> 'NULL'         then mBO.SetFieldValueAsString('ResidenceAddress_ID.PhoneNumber1', NxLeft(mPhone, 60));
            if (mLastName = 'NULL') or (mLastName = '.') then mLastName:= '';
            if (mFirstName = 'NULL') or (mFirstName = '.') then mFirstName:= '';
            mBO.SetFieldValueAsString('ResidenceAddress_ID.Recipient', Trim(NxLeft(mLastName + ' ' + mFirstName, 60)));

            mBO.Save;
          finally
            mBO.Free;
          end;
        end;
      finally
        if not VarIsEmpty(mWorkbook) then
          mWorkbook.Close;
        mWorkbook:= nil;
        WaitWin.Stop;
      end;
    except
      mLog:= mLog + IntToStr(i) + ' ' + mExactID + nxCrLf + ExceptionMessage + nxCrLf;
      NxShowSimpleMessage(ExceptionMessage, nil);
    end;

  finally
    if not NxIsBlank(mLog) then
      NxShowEditorSite(msite.SiteContext, mLog, True);
    if not VarIsEmpty(mExcel) then
      mExcel.Quit;
    mExcel := nil;
    mWorksheet:= nil;
  end;
end;


procedure CorrectionFirmOfficesImport_XLSX(Sender: TComponent);
var
  mSite: TSiteForm;
  mOS: TNxCustomObjectSpace;
  mFO: TNxCustomBusinessMonikerCollection;
  mBO, mFOBO: TNxCustomBusinessObject;
  mOldFirm, mNewFirm: TNxFirm;
  i, j, mRowCount: integer;
  mExcel, mWorkbook, mWorksheet, mUsedRange: Variant;
  mFileName, mFirm_ID, mLog: string;
  mExactID, mExactAddressID, mCode, mName, mAddressLine1, mAddressLine2, mPostCode, mCity, mCountryCode, mEmail, mFax, mPhone, mVATNumber, mLastName, mFirstName : string;
  mFirmCode, mFirmName:string;
begin
  mSite:= Sender.Site;
  mOS:= mSite.BaseObjectSpace;

  mLog:= '';

  if not SelectImportFile(mSite, mFileName) then exit;

  try
    try
      mExcel:= CreateOleObject('Excel.Application');
    except
      NxShowSimpleMessage('Excel application is not installed!', nil);
      exit;
    end;

    try
      mExcel.Visible:= false;
      mWorkbook:= mExcel.Workbooks.Open(mFileName);
      try
        mWorksheet := mWorkbook.Worksheets[1];
        mUsedRange := mWorksheet.UsedRange;
        mRowCount := mUsedRange.Rows.Count;

        WaitWin.StartProgress('Processing', 'Processing', mRowCount);

        for i:= 2 to mRowCount do
        begin
          WaitWin.StepIt;

          mFirmCode       := SanitizeStringValue(Trim(VarToStr(mUsedRange.Cells[i, 1].Value)));
          mFirmName       := SanitizeStringValue(Trim(VarToStr(mUsedRange.Cells[i, 2].Value)));
          mVATNumber      := SanitizeStringValue(Trim(VarToStr(mUsedRange.Cells[i, 3].Value)));
          mExactID        := SanitizeStringValue(Trim(VarToStr(mUsedRange.Cells[i, 4].Value)));
          mExactAddressID := SanitizeStringValue(Trim(VarToStr(mUsedRange.Cells[i, 5].Value)));
          mAddressLine1   := SanitizeStringValue(Trim(VarToStr(mUsedRange.Cells[i, 6].Value)));
          mAddressLine2   := SanitizeStringValue(Trim(VarToStr(mUsedRange.Cells[i, 7].Value)));
          mCity           := SanitizeStringValue(Trim(VarToStr(mUsedRange.Cells[i, 8].Value)));
          mCountryCode    := SanitizeStringValue(Trim(VarToStr(mUsedRange.Cells[i, 9].Value)));
          mPostCode       := SanitizeStringValue(Trim(VarToStr(mUsedRange.Cells[i,10].Value)));
          mEmail          := SanitizeStringValue(Trim(VarToStr(mUsedRange.Cells[i,13].Value)));
          mPhone          := SanitizeStringValue(Trim(VarToStr(mUsedRange.Cells[i,15].Value)));
          mLastName       := SanitizeStringValue(Trim(VarToStr(mUsedRange.Cells[i,16].Value)));
          mFirstName      := SanitizeStringValue(Trim(VarToStr(mUsedRange.Cells[i,17].Value)));

          mFirm_ID:= GetFirm_ID(mOS, mExactID);
          if NxIsEmptyOID(mFirm_ID) then
          begin
            mLog:= mlog + IntToStr(i) + ' - '+mExactID + ' - Not found' + nxCrLf;
            continue;
          end;

          mOldFirm:= TNxFirm(mOS.CreateObject(Class_Firm));
          try
            mOldFirm.Load(mFirm_ID, nil);

            mNewFirm:= mOldFirm.MajorCorrection;

            mFO:= mNewFirm.GetLoadedCollectionMonikerForFieldCode(mNewFirm.GetFieldCode('FirmOffices'));

            for j:= 0 to mFO.Count -1 do
            begin
              mFOBO:= mFO.BusinessObject[j];
              if mFOBO.GetFieldValueAsBoolean('SynchronizeAddress') then continue;
              if not NxIsBlank(mFOBO.GetFieldValueAsString('X_ID_Exact')) then continue;

              //mFOBO.SetFieldValueAsBoolean('Hidden', True);
              mFOBO.MarkForDelete;
            end;

            for j:= 0 to mFO.Count -1 do
            begin
              mFOBO:= mFO.AddNewObject;
              mFOBO.Prefill;

              //if (mFOBO.GetFieldValueAsString('Address_ID.Street') = mAddressLine1) and (mFOBO.GetFieldValueAsString('Address_ID.City') = mCity) then
              //begin
              mFOBO.SetFieldValueAsString('Name', NxLeft(mAddressLine1 + ' - ' + mCity, 220));
              mFOBO.SetFieldValueAsString('Address_ID.Street', NxLeft(mAddressLine1, 60));
              mFOBO.SetFieldValueAsString('Address_ID.X_AddressLine_2', NxLeft(mAddressLine2, 250));
              mFOBO.SetFieldValueAsString('Address_ID.PostCode', NxLeft(mPostCode, 10));
              mFOBO.SetFieldValueAsString('Address_ID.City', NxLeft(mCity, 60));
              mFOBO.SetFieldValueAsString('Address_ID.CountryCode', NxLeft(mCountryCode, 3));
              mFOBO.SetFieldValueAsString('Address_ID.EMail', NxLeft(mEmail, 320));
              mFOBO.SetFieldValueAsString('Address_ID.PhoneNumber1', NxLeft(mPhone, 60));
              mFOBO.SetFieldValueAsString('Address_ID.Recipient', Trim(NxLeft(mLastName + ' ' + mFirstName, 60)));
              mFOBO.SetFieldValueAsString('X_ID_Exact', mExactAddressID);

              //end else
              //begin
              //  mFOBO.SetFieldValueAsBoolean('Hidden', True);
              //end;
            end;

            mNewFirm.Save;

            exit;

          finally
            mNewFirm.Free;
            mOldFirm.Free;
          end;
        end;
      finally
        if not VarIsEmpty(mWorkbook) then
          mWorkbook.Close;
        mWorkbook:= nil;
        WaitWin.Stop;
      end;
    except
      mLog:= mLog + IntToStr(i) + ' ' + mExactID + nxCrLf + ExceptionMessage + nxCrLf;
      NxShowSimpleMessage(ExceptionMessage, nil);
    end;

  finally
    if not NxIsBlank(mLog) then
      NxShowEditorSite(msite.SiteContext, mLog, True);
    if not VarIsEmpty(mExcel) then
      mExcel.Quit;
    mExcel := nil;
    mWorksheet:= nil;
  end;
end;


function SanitizeStringValue(AValue: string): string;
begin
  Result:= AValue;
  if AValue = 'NULL' then
    Result:= '';

  if AValue = '.' then
    Result:= '';
end;


function GetFirm_ID(AOS: TNxCustomObjectSpace; AExternalID:string;):string;
begin
  Result:= '';
  Result:= AOS.SQLSelectFirstAsString(Format('SELECT ID FROM Firms WHERE Hidden = ''N'' AND X_ID_EXACT = ''%s''', ['{' + AExternalID + '}']));
end;




function SelectImportFile(ASite: TSiteForm; var AFileName: string):Boolean;
var
  mOpenDialog: TOpenDialog;
begin
  Result:= False;
  AFileName:= '';

  mOpenDialog:= TOpenDialog.Create(ASite);
  try
    mOpenDialog.Filter := 'Soubor importu (*.xlsx)|*.xlsx';
    if not mOpenDialog.Execute(ASite) then exit;

    AFileName:= mOpenDialog.FileName;
    Result:= True;
  finally
    mOpenDialog.Free;
  end;
end;



procedure LoadXLSXToList(const AFileName: string; ADataSet: TDataset);
var
  mExcel, mWorkbook, mWorksheet, mUsedRange: Variant;
  mRowCount, i: Integer;
  mCode, mQty: string;
begin
  try
    try
      mExcel:= CreateOleObject('Excel.Application');
    except
      NxShowSimpleMessage('Excel application is not installed!', nil);
      exit;
    end;

    try
      mExcel.Visible:= false;
      mWorkbook:= mExcel.Workbooks.Open(AFileName);
      try
        mWorksheet := mWorkbook.Worksheets[1];
        mUsedRange := mWorksheet.UsedRange;
        mRowCount := mUsedRange.Rows.Count;

        for i:= 1 to mRowCount do
        begin
          mCode:= Trim(VarToStr(mUsedRange.Cells[i, 1].Value));
          mQty:= Trim(VarToStr(mUsedRange.Cells[i, 2].Value));

          //Nevím jestli budu dostávat sloupec s množstvím a nebo jen sloupec s datamatrixy
          if Trim(VarToStr(mUsedRange.Cells[i, 2].Value)) = '' then
            mQty:= '1';

          if (mQty = '') or (not NxIsNumeric(mQty)) then
            mQty:= '0';

          if (mCode <> '') and (mQty <> '') then
          begin
            ADataSet.Append;
            ADataSet.FieldByName('Barcode').AsString:= mCode;
            ADataSet.FieldByName('Quantity').AsFloat:= NxIBStrToFloat(mQty);
            ADataSet.Post;
          end;
        end;
      finally
        if not VarIsEmpty(mWorkbook) then
          mWorkbook.Close;
        mWorkbook:= nil;
      end;
    except
      NxShowSimpleMessage('Error while reading the file', nil);
      exit;
    end;
  finally
    if not VarIsEmpty(mExcel) then
      mExcel.Quit;
    mExcel := nil;
    mWorksheet:= nil;
  end;
end;

begin
end.