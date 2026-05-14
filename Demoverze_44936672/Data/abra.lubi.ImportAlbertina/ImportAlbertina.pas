uses
  'abra.lubi.ImportAlbertina.Books';
  
const
  cKeyName = 'Last_ImportAlbertina';

var
  //Proměnné formuláře
  fForm: TForm;

  fContext: TNxContext;
  fObjectSpace: TNxCustomObjectSpace;

  fSite: TSiteForm;

  mlblFirm, mlblPerson, mlblInfo: TLabel;
  mbtnImportAll, mbtnActualizeAll, mbtnActualizeSelected, mbtnFirm, mbtnPerson, mbtnTest: TButton;
  medFileFirms, medFilePersons: TEdit;
  mchkInfo: TCheckBox;
  
  fPersonsStructure, fRowList: TStringList;
  fLastICO: string;

Procedure ImportAlbertina(AOS: TNxCustomObjectSpace; ASite: TSiteForm; ARowList: TStringList);
var
  i: integer;
  mList: TStringList;
begin
  fSite := ASite;
  fObjectSpace := AOS;
  //fContext := ASite.SiteContext;
  if ActualizeCategoryItem then begin
    fRowList := ARowList;
    fPersonsStructure := TStringList.Create;
    try
      fPersonsStructure.Sorted := True;
      ShowDebugMessage('ImportAlbertina');
      // lubi validace filenamu
      //SetValueToStorage(cKeyName, mICO, NxCreateContext(fObjectSpace));
      fForm := MakeForm;
      fLastICO := GetValueFromStorage(cKeyName, NxCreateContext(fObjectSpace));
      if fLastICO <> '' then begin
        mlblInfo.Caption := mlblInfo.Caption + fLastICO;
        mchkInfo.Visible := True;
        mlblInfo.Visible := True;
      end
      else begin
        mchkInfo.Visible := False;
        mlblInfo.Visible := False;
      end;
      fForm.ShowModal;
    finally
      for i := 0 to fPersonsStructure.Count -1 do begin
        mList := TStringList(fPersonsStructure.Objects(i));
        mList.Free;
      end;
      fPersonsStructure.Free;
    end;
  end;
end;

// nactu si strukturu osob - vyznamne to urychli dohledavani osob k firmam, nebudu muset vubec jiz pouzivat dataset
procedure LoadPersonsStructure(var APersonsStructure: TStringList; AICOList: TStringList);
var
  mDBF: TDbf;
  mICO, mLine: string;
  mValueList: TStringList;
  mIndex, i: integer;
  mProgressForm: TForm;
  mProgressBar: TProgressBar;
  mProgressLabel: TLabel;
begin
  ShowDebugMessage('LoadPersonsStructure - start');
  mDBF := TDBF.Create(nil);
  try
    mDBF.TableName := medFilePersons.Text;
    mDBF.Open;
    if Assigned(AICOList) then begin
      // Filtrace pro ICO
      mProgressForm := CreateProgressInfo(fForm, mDBF.RecordCount, Format('Cachování tabulky osob. Položka: 0 z %s', [IntToStr(AICOList.Count)]));
      mProgressForm.Show;
      try
        mProgressBar := TProgressBar(NxFindChildControl(mProgressForm, 'pgInfoBar'));
        mProgressLabel := TLabel(NxFindChildControl(mProgressForm, 'lblInfoLabel'));
        for i := 0 to AICOList.Count - 1 do begin
          mDBF.Filtered := False;
          mDBF.Filter := Format('ICO = "%s"', [AICOList.Strings[i]]);
          mDBF.Filtered := True;
          //ShowDebugMessage('Filter: ' + mDBF.Filter);
          mDBF.First;
          while not mDBF.Eof do begin
            mLine := '';
            //ShowDebugMessage('RecNo: ' + IntToStr(mDBF.RecNo));
            mProgressLabel.Caption := Format('Cachování tabulky osob. Položka: %s z %s', [IntToStr(i+1), IntToStr(AICOList.Count)]);
            mProgressBar.Position := mDBF.RecNo;
            mProgressForm.Refresh;
            Application.ProcessMessages;
            mICO := mDBF.FieldByName('ICO').AsString;
            //ShowDebugMessage('ICO: ' + mICO);
            //OSOBA75,FUNKCE,POHLAVI,TITPRED,TITZA,JMENO,PRIJMENI,VOKATIV
            mIndex := APersonsStructure.IndexOf(mICO);
            if mIndex = -1 then begin
              mLine := mDBF.FieldByName('OSOBA75').AsString;
              mLine := mLine + '**' + mDBF.FieldByName('FUNKCE').AsString;
              mLine := mLine + '**' + mDBF.FieldByName('POHLAVI').AsString;
              mLine := mLine + '**' + mDBF.FieldByName('TITPRED').AsString;
              mLine := mLine + '**' + mDBF.FieldByName('TITZA').AsString;
              mLine := mLine + '**' + mDBF.FieldByName('JMENO').AsString;
              mLine := mLine + '**' + mDBF.FieldByName('PRIJMENI').AsString;
              mLine := mLine + '**' + mDBF.FieldByName('VOKATIV').AsString;
              //ShowDebugMessage('ICO nenalezeno - nova struktura');
              //ShowDebugMessage('mLine: ' + mLine);
              mValueList := TStringList.Create;
              mValueList.Add(mLine);
              APersonsStructure.AddObject(mICO, mValueList);
            end
            else begin
              mLine := mDBF.FieldByName('OSOBA75').AsString;
              mLine := mLine + '**' + mDBF.FieldByName('FUNKCE').AsString;
              mLine := mLine + '**' + mDBF.FieldByName('POHLAVI').AsString;
              mLine := mLine + '**' + mDBF.FieldByName('TITPRED').AsString;
              mLine := mLine + '**' + mDBF.FieldByName('TITZA').AsString;
              mLine := mLine + '**' + mDBF.FieldByName('JMENO').AsString;
              mLine := mLine + '**' + mDBF.FieldByName('PRIJMENI').AsString;
              mLine := mLine + '**' + mDBF.FieldByName('VOKATIV').AsString;
              //ShowDebugMessage('ICO nalezeno - pridavam do struktury');
              //ShowDebugMessage('Strucure count pred: ' + IntToStr(mValueList.Count));
              //ShowDebugMessage('mLine: ' + mLine);
              mValueList := TStringList(APersonsStructure.Objects(mIndex));
              mValueList.Add(mLine);
              // LUBi pak vyhodit jen pro testy
              //mValueList := TStringList(APersonsStructure.Objects(mIndex));
              //ShowDebugMessage('Strucure count PO: ' + IntToStr(mValueList.Count));
            end;
            mDBF.Next;
          end;
        end;
      finally
        mProgressForm.Close;
        mProgressForm.Free;
      end;
    end
    else begin
      mDBF.First;
      mProgressForm := CreateProgressInfo(fForm, mDBF.RecordCount, Format('Cachování tabulky osob. Položka: 0 z %s', [IntToStr(mDBF.RecordCount)]));
      mProgressForm.Show;
      try
        mProgressBar := TProgressBar(NxFindChildControl(mProgressForm, 'pgInfoBar'));
        mProgressLabel := TLabel(NxFindChildControl(mProgressForm, 'lblInfoLabel'));
        while not mDBF.Eof do begin
          mLine := '';
          //ShowDebugMessage('RecNo: ' + IntToStr(mDBF.RecNo));
          mProgressLabel.Caption := Format('Cachování tabulky osob. Položka: %s z %s', [IntToStr(mDBF.RecNo), IntToStr(mDBF.RecordCount)]);
          mProgressBar.Position := mDBF.RecNo;
          mProgressForm.Refresh;
          Application.ProcessMessages;
          mICO := mDBF.FieldByName('ICO').AsString;
          //ShowDebugMessage('ICO: ' + mICO);
          //OSOBA75,FUNKCE,POHLAVI,TITPRED,TITZA,JMENO,PRIJMENI,VOKATIV
          mIndex := APersonsStructure.IndexOf(mICO);
          if mIndex = -1 then begin
            mLine := mDBF.FieldByName('OSOBA75').AsString;
            mLine := mLine + '**' + mDBF.FieldByName('FUNKCE').AsString;
            mLine := mLine + '**' + mDBF.FieldByName('POHLAVI').AsString;
            mLine := mLine + '**' + mDBF.FieldByName('TITPRED').AsString;
            mLine := mLine + '**' + mDBF.FieldByName('TITZA').AsString;
            mLine := mLine + '**' + mDBF.FieldByName('JMENO').AsString;
            mLine := mLine + '**' + mDBF.FieldByName('PRIJMENI').AsString;
            mLine := mLine + '**' + mDBF.FieldByName('VOKATIV').AsString;
            //ShowDebugMessage('ICO nenalezeno - nova struktura');
            mValueList := TStringList.Create;
            mValueList.Add(mLine);
            APersonsStructure.AddObject(mICO, mValueList);
          end
          else begin
            mLine := mDBF.FieldByName('OSOBA75').AsString;
            mLine := mLine + '**' + mDBF.FieldByName('FUNKCE').AsString;
            mLine := mLine + '**' + mDBF.FieldByName('POHLAVI').AsString;
            mLine := mLine + '**' + mDBF.FieldByName('TITPRED').AsString;
            mLine := mLine + '**' + mDBF.FieldByName('TITZA').AsString;
            mLine := mLine + '**' + mDBF.FieldByName('JMENO').AsString;
            mLine := mLine + '**' + mDBF.FieldByName('PRIJMENI').AsString;
            mLine := mLine + '**' + mDBF.FieldByName('VOKATIV').AsString;
            //ShowDebugMessage('ICO nalezeno - pridavam do struktury');
            //ShowDebugMessage('Strucure count pred: ' + IntToStr(mValueList.Count));
            mValueList := TStringList(APersonsStructure.Objects(mIndex));
            mValueList.Add(mLine);
            // LUBi pak vyhodit jen pro testy
            //mValueList := TStringList(APersonsStructure.Objects(mIndex));
            //ShowDebugMessage('Strucure count PO: ' + IntToStr(mValueList.Count));
          end;
          mDBF.Next;
        end;
      finally
        mProgressForm.Close;
        mProgressForm.Free;
      end;
    end;
  finally
    mDBF.Free;
  end;
  ShowDebugMessage('LoadPersonsStructure - finish');
end;

procedure btnStornoClick(Sender: TObject);
var
  mForm: TForm;
begin
  mForm := TForm(TButton(Sender).Owner);
  mForm.Close;
end;

procedure mbtnImportAllClick(Sender: TObject);
var
  mDBF: TDbf;
  //mTest: tstringList;
  mProgressForm: TForm;
  mProgressBar: TProgressBar;
  mProgressLabel: TLabel;
begin
  ShowDebugMessage('mbtnImportAllClick start');
  {mTest := TStringList.Create;
  try
  // LUBI u techto testu zjisteno, ze jsou v tabulkach osoby duplicitni !!!!!
  mTest.Add('43541534');
  mTest.Add('25576968');
  mTest.Add('43774750');
  mTest.Add('25213164');
  mTest.Add('40766217');
  LoadPersonsStructure(fPersonsStructure, mTest);
  finally
    mTest.Free;
  end;
  }
  LoadPersonsStructure(fPersonsStructure, nil);
  mDBF := TDBF.Create(nil);
  try
    mDBF.TableName := medFileFirms.Text;
    mDBF.Open;
    UpdateFirmData(mDBF);
    mDBF.First;
    mProgressForm := CreateProgressInfo(fForm, mDBF.RecordCount, Format('Import všech firem. Položka: 0 z %s', [IntToStr(mDBF.RecordCount)]));
    mProgressForm.Show;
    try
      mProgressBar := TProgressBar(NxFindChildControl(mProgressForm, 'pgInfoBar'));
      mProgressLabel := TLabel(NxFindChildControl(mProgressForm, 'lblInfoLabel'));
      while not mDBF.Eof do begin
        //ShowDebugMessage('RecNo: ' + IntToStr(mDBF.RecNo));
        mProgressLabel.Caption := Format('Import všech firem. Položka: %s z %s', [IntToStr(mDBF.RecNo), IntToStr(mDBF.RecordCount)]);
        mProgressBar.Position := mDBF.RecNo;
        mProgressForm.Refresh;
        Application.ProcessMessages;
        CreateOrActualize(mDBF, True, True);
        mDBF.Next;
      end;
      if mDBF.Eof then
        SetValueToStorage(cKeyName, '', NxCreateContext(fObjectSpace));
    finally
      mProgressForm.Close;
      mProgressForm.Free;
    end;
  finally
    mDBF.Free;
  end;
  fForm.Close;
  ShowDebugMessage('CloseForm Finish');
end;

// Import jen novych - spatne se jemenuje
procedure mbtnActualizeAllClick(Sender: TObject);
var
  mDBF: TDbf;
  //mTest: tstringList;
  mProgressForm: TForm;
  mProgressBar: TProgressBar;
  mProgressLabel: TLabel;
begin
  ShowDebugMessage('mbtnActualizeSelectedClick start');
  LoadPersonsStructure(fPersonsStructure, nil);
  mDBF := TDBF.Create(nil);
  try
    mDBF.TableName := medFileFirms.Text;
    mDBF.Open;
    UpdateFirmData(mDBF);
    mDBF.First;
    mProgressForm := CreateProgressInfo(fForm, mDBF.RecordCount, Format('Import jen nových. Položka: 0 z %s', [IntToStr(mDBF.RecordCount)]));
    mProgressForm.Show;
    try
      mProgressBar := TProgressBar(NxFindChildControl(mProgressForm, 'pgInfoBar'));
      mProgressLabel := TLabel(NxFindChildControl(mProgressForm, 'lblInfoLabel'));
      while not mDBF.Eof do begin
        //ShowDebugMessage('RecNo: ' + IntToStr(mDBF.RecNo));
        mProgressLabel.Caption := Format('Import jen nových. Položka: %s z %s', [IntToStr(mDBF.RecNo), IntToStr(mDBF.RecordCount)]);
        mProgressBar.Position := mDBF.RecNo;
        mProgressForm.Refresh;
        Application.ProcessMessages;
        CreateOrActualize(mDBF, True, False);
        mDBF.Next;
      end;
      if mDBF.Eof then
        SetValueToStorage(cKeyName, '', NxCreateContext(fObjectSpace));
    finally
      mProgressForm.Close;
      mProgressForm.Free;
    end;
  finally
    mDBF.Free;
  end;
  fForm.Close;
  ShowDebugMessage('CloseForm Finish');
end;

procedure mbtnActualizeSelectedClick(Sender: TObject);
var
  mDBF: TDbf;
  mProgressForm: TForm;
  mProgressBar: TProgressBar;
  mProgressLabel: TLabel;
  mICOList: TStringList;
  mICO, mSQL: string;
  i: integer;
begin
  ShowDebugMessage('mbtnActualizeSelectedClick start');
  mICOList := TStringList.Create;
  try
    for i := 0 to fRowList.Count - 1 do begin
      mSQL := 'select OrgIdentNumber from Firms where ID = ''%s''';
      mSQL := Format(mSQL, [fRowList.Strings[i]]);
      mICO := GetFirstRecordFromSQL(fObjectSpace, mSQL);
      if mICO <> '' then
        mICOList.Add(mICO);
    end;
    ShowDebugMessage('ICOList: ' + mICOList.Text);
    LoadPersonsStructure(fPersonsStructure, nil{mICOList}); // zafiltrovane // LUBI filtrovani zruseno kvuli pomalosti
    mDBF := TDBF.Create(nil);
    try
      mDBF.TableName := medFileFirms.Text;
      mDBF.Open;
      UpdateFirmData(mDBF);
      mDBF.First;
      mProgressForm := CreateProgressInfo(fForm, mDBF.RecordCount, Format('Aktualizace označených. Položka: 0 z %s', [IntToStr(mICOList.Count)]));
      mProgressForm.Show;
      try
        mProgressBar := TProgressBar(NxFindChildControl(mProgressForm, 'pgInfoBar'));
        mProgressLabel := TLabel(NxFindChildControl(mProgressForm, 'lblInfoLabel'));
        i := 0;
        while not mDBF.Eof do begin
          mICO := mDBF.FieldByName('ICO').AsString;
          if mICOList.IndexOf(mICO) <> - 1 then begin
            //ShowDebugMessage('ICO v DBF nalezeno: ' + mICO);
            Inc(i);
            mProgressLabel.Caption := Format('Aktualizace označených. Položka: %s z %s', [IntToStr(i), IntToStr(mICOList.Count)]);
            mProgressBar.Position := mDBF.RecNo;
            mProgressForm.Refresh;
            Application.ProcessMessages;
            CreateOrActualize(mDBF, False, True);
          end;
          mDBF.Next;
        end;
        if mDBF.Eof then
          SetValueToStorage(cKeyName, '', NxCreateContext(fObjectSpace));
      finally
        mProgressForm.Close;
        mProgressForm.Free;
      end;
    finally
      mDBF.Free;
    end;
  finally
    mICOList.Free;
  end;
  fForm.Close;
  ShowDebugMessage('CloseForm Finish');
end;

procedure UpdateFirmData(var ADBF: TDBF);
var
  mICO: string;
begin
  if mchkInfo.Checked then begin
    if fLastICO <> '' then begin
      while not ADBF.Eof do begin
        mICO := ADBF.FieldByName('ICO').AsString;
        if mICO <> fLastICO then begin
          ShowDebugMessage('Odstraneno ICO: ' + mICO);
          ADBF.Delete;
        end
        else begin
          ShowDebugMessage('Odstraneno ICO: ' + mICO);
          ADBF.Delete;
          Break;
        end;
      end;
      SetValueToStorage(cKeyName, '', NxCreateContext(fObjectSpace));
    end;
  end
  else
    SetValueToStorage(cKeyName, '', NxCreateContext(fObjectSpace));
end;

procedure CreateOrActualize(ADBF: TDBF; ACreateNew, AActualize: Boolean);
var
  mFirmObj, mAddressObj, mFirmNaces: TNxCustomBusinessObject;
  mSQL, mICO, mFirmOID, mBoolRes, mZJmeni: string;
  mNewFirm, mDoIt: Boolean;
  mMoniker: TNxBusinessMoniker;
  mNACEOID, mFirmNacesOID, mOwnershipTypeOID, mCompanyLegalStatusOID, mEmployeeCountCategoryOID, mFinancialCategoryOID: string;
  mCategoryMetadataOID, mCategoryUpdateMode, mCategoryItemOID, mObratCategoryOID, mObrat: string;
begin
  mICO := ADBF.FieldByName('ICO').AsString;
  // LUBI VRATIT!!!!
  if mICO <> '' then begin
  //if mICO = '27159302' then begin
    ShowDebugMessage('CreateOrActualize ICO: ' + mICO);
    mSQL := 'select ID from Firms where OrgIdentNumber = ''%s'' and Hidden = ''N'' and Firm_ID is null';
    mSQL := Format(mSQL, [mICO]);
    mFirmOID := GetFirstRecordFromSQL(fObjectSpace, mSQL);
    mNewFirm := NxIsEmptyOID(mFirmOID);
    mDoIt := True;
    if mNewFirm then
      mDoIt := ACreateNew
    else
      mDoIt := AActualize;
    {
    if mDoIt then begin
      if not NxIsEmptyOID(mFirmOID) then begin
        mSQL := 'select X_ImportAlbertina from Firms where ID = ''%s''';
        mSQL := Format(mSQL, [mFirmOID]);
        mBoolRes := GetFirstRecordFromSQL(fObjectSpace, mSQL);
        if mBoolRes = 'N' then
          mDoIt := False;
      end;
    end;
    }
    if mDoIt then begin
      mSQL := 'select ID from CategoryItems where Name = ''Import Albertina'' and Hidden = ''N''';
      mCategoryItemOID := GetFirstRecordFromSQL(fObjectSpace, mSQL);
      if not NxIsEmptyOID(mFirmOID) then begin
        if not NxIsEmptyOID(mCategoryItemOID) then begin
          mSQL := 'select ID from FirmCategoriesMetadata where Parent_ID = ''%s'' and CategoryItem_ID = ''%s''';
          mSQL := Format(mSQL, [mFirmOID, mCategoryItemOID]);
          mCategoryMetadataOID := GetFirstRecordFromSQL(fObjectSpace, mSQL);
          if not NxIsEmptyOID(mCategoryMetadataOID) then begin
            mSQL := 'select CategoryUpdateMode from FirmCategoriesMetadata where ID = ''%s''';
            mSQL := Format(mSQL, [mCategoryMetadataOID]);
            mCategoryUpdateMode := GetFirstRecordFromSQL(fObjectSpace, mSQL);
            ShowDebugMessage('CategoryUpdateMode: ' + mCategoryUpdateMode);
            // LUBI, ROEH a JIMA - zatim neresime - nastavovani kategorizacnich udaju neni vytazeno do vizualna, pote, az bude, nebudeme importovat pokud bude stav "změněno ručně"
            {
            if (mCategoryUpdateMode = '1') or (mCategoryUpdateMode = '2') then begin
              mDoIt := False;
              ShowDebugMessage('AKTUALIZACI NEPROVADIM - CategoryUpdateMode je jiny nez 0 nebo 3');
            end;
            }
          end;
        end;
      end;
      if mDoIt then begin
        // aktualizace nebo dohledani ciselniku
        // NACE jen dohledani
        mSQL := 'select ID from NACE where Code = ''%s'' and Hidden = ''N''';
        mSQL := Format(mSQL, [ADBF.FieldByName('NACE').AsString + '0']);  // dohledani podle nace plus nula na konec
        mNACEOID := GetFirstRecordFromSQL(fObjectSpace, mSQL);
        if NxIsEmptyOID(mNACEOID) then begin
          ShowDebugMessage('Nenalezen NACE: ' + ADBF.FieldByName('NACE').AsString + '0' + ' Pro ICO: ' + mICO);
        end;
        ShowDebugMessage('StartTransaction - start');
        fObjectSpace.StartTransaction(taReadCommited);
        ShowDebugMessage('StartTransaction - stop');
        try
          // OwnershipType_ID - typ vlastnictvi DRVLST - jen dohledavam, je v initdatech ok
          mSQL := 'select ID from OwnerShipTypes where Code = ''%s''';
          mSQL := Format(mSQL, [ADBF.FieldByName('DRVLST').AsString]);
          mOwnershipTypeOID := GetFirstRecordFromSQL(fObjectSpace, mSQL);
          // PRAVFOR - pravni forma Firms. LegalStatus_ID
          mSQL := 'select ID from CompanyLegalStatuses where Code = ''%s''';
          mSQL := Format(mSQL, [ADBF.FieldByName('PRAVFOR').AsString]);
          mCompanyLegalStatusOID := GetFirstRecordFromSQL(fObjectSpace, mSQL);
          //  POC_ZAM - Firms.EmployeeCount_ID  EmpoyeeCountCategory  pocet zamestnancu EmpoyeeCountCategories
          mSQL := 'select ID from EmployeeCountCategories where Code = ''%s''';
          mSQL := Format(mSQL, [ADBF.FieldByName('POC_ZAM').AsString + '0']);
          mEmployeeCountCategoryOID := GetFirstRecordFromSQL(fObjectSpace, mSQL);
          //  Z_JMENI - Firms.EquityCapital_ID zakladni kapital - pokud neni zakladam
          if ADBF.FieldByName('Z_JMENI').AsString <> '' then begin
            mZJmeni := NxSearchReplace(ADBF.FieldByName('Z_JMENI').AsString, ',', '.', [srAll]);
            mSQL := 'select ID from FinancialCategories where Minimum <= %s and Maximum >= %s';
            mSQL := Format(mSQL, [mZJmeni, mZJmeni]);
            mFinancialCategoryOID := GetFirstRecordFromSQL(fObjectSpace, mSQL);
          end
          else
            mFinancialCategoryOID := '';

          //  obrat - Turnover_ID  - FinancialCategory
          if ADBF.FieldByName('OBRAT').AsString <> '' then begin
            // aby sel StrToFloat - povolena carka
            mObrat := NxSearchReplace(ADBF.FieldByName('OBRAT').AsString, '.', ',', [srAll]);
            ShowDebugMessage('mObrat vstup: ' + mObrat);
            mObrat := FloatToStr(StrToFloat(mObrat) * 1000000); // v milionech
            // pro porovnani  - povoleny tecky
            mObrat := NxSearchReplace(mObrat, ',', '.', [srAll]);
            ShowDebugMessage('mObrat pro porovnani: ' + mObrat);
            mSQL := 'select ID from FinancialCategories where Minimum <= %s and Maximum >= %s';
            mSQL := Format(mSQL, [mObrat, mObrat]);
            mObratCategoryOID := GetFirstRecordFromSQL(fObjectSpace, mSQL);
          end
          else
            mObratCategoryOID := '';
          ShowDebugMessage('mObratCategoryOID: ' + mObratCategoryOID);

          if not mNewFirm then begin
            mFirmObj := nil;
            mFirmObj := fObjectSpace.CreateObject('4K3EXM5PQBCL35CH000ILPWJF4');
            ShowDebugMessage('mFirmObj - create ok');
            try
              ShowDebugMessage('1.load firm - start OID: ' + mFirmOID);
              mFirmObj.Load(mFirmOID, nil);
              ShowDebugMessage('1.load firm - ok');
              mFirmObj.Save;
              ShowDebugMessage('1.load firm save - ok');
            finally
              mFirmObj.Free;
            end;
          end;

          ShowDebugMessage('mFirmObj - create');
          mFirmObj := nil;
          mFirmObj := fObjectSpace.CreateObject('4K3EXM5PQBCL35CH000ILPWJF4');
          ShowDebugMessage('mFirmObj - create ok');
          try
            if mNewFirm then begin
              ShowDebugMessage('new firm - start');
              mFirmObj.New;
              mFirmObj.Prefill;
              mFirmObj.SetFieldValueAsString('OrgIdentNumber', mICO);
              ShowDebugMessage('new firm - ok');
            end
            else begin
              ShowDebugMessage('load firm - start OID: ' + mFirmOID);
              mFirmObj.Load(mFirmOID, nil);
              ShowDebugMessage('load firm - ok');
            end;
            mFirmObj.SetFieldValueAsBoolean('X_NoCreateFolder', True);
            ShowDebugMessage('set field na firm - ok');
            if mNewFirm then
              mFirmObj.SetFieldValueAsString('Name', Copy(ADBF.FieldByName('FIRMA').AsString, 1, 80))
            else
              if mFirmObj.GetFieldValueAsString('Name') = '' then
                mFirmObj.SetFieldValueAsString('Name', Copy(ADBF.FieldByName('FIRMA').AsString, 1, 80));
            if mNewFirm then
              mFirmObj.SetFieldValueAsString('WWWAddress', Copy(ADBF.FieldByName('HTTP').AsString, 1, 100))
            else
              if mFirmObj.GetFieldValueAsString('WWWAddress') = '' then
                mFirmObj.SetFieldValueAsString('WWWAddress', Copy(ADBF.FieldByName('HTTP').AsString, 1, 100));

            if not NxIsEmptyOID(mNACEOID) then begin
              if mNewFirm then
                mFirmObj.SetFieldValueAsString('MainNACECode_ID', mNACEOID)
              else
                if NxIsEmptyOID(mFirmObj.GetFieldValueAsString('MainNACECode_ID')) then
                  mFirmObj.SetFieldValueAsString('MainNACECode_ID', mNACEOID);
            end;
            if mNewFirm then
              mFirmObj.SetFieldValueAsString('OwnershipType_ID', mOwnershipTypeOID)
            else
              if NxIsEmptyOID(mFirmObj.GetFieldValueAsString('OwnershipType_ID')) then
                mFirmObj.SetFieldValueAsString('OwnershipType_ID', mOwnershipTypeOID);
            if mNewFirm then
              mFirmObj.SetFieldValueAsString('LegalStatus_ID', mCompanyLegalStatusOID)
            else
              if NxIsEmptyOID(mFirmObj.GetFieldValueAsString('LegalStatus_ID')) then
                mFirmObj.SetFieldValueAsString('LegalStatus_ID', mCompanyLegalStatusOID);
            if mNewFirm then
              mFirmObj.SetFieldValueAsString('EmployeeCount_ID', mEmployeeCountCategoryOID)
            else
              if NxIsEmptyOID(mFirmObj.GetFieldValueAsString('EmployeeCount_ID')) then
                mFirmObj.SetFieldValueAsString('EmployeeCount_ID', mEmployeeCountCategoryOID);
            if mNewFirm then
              mFirmObj.SetFieldValueAsString('EquityCapital_ID', mFinancialCategoryOID)
            else
              if NxIsEmptyOID(mFirmObj.GetFieldValueAsString('EquityCapital_ID')) then
                mFirmObj.SetFieldValueAsString('EquityCapital_ID', mFinancialCategoryOID);

            if mNewFirm then
              mFirmObj.SetFieldValueAsString('Turnover_ID', mObratCategoryOID)
            else
              if NxIsEmptyOID(mFirmObj.GetFieldValueAsString('Turnover_ID')) then
                mFirmObj.SetFieldValueAsString('Turnover_ID', mObratCategoryOID);

            // LUBI vratit !!!

            mMoniker := mFirmObj.GetMonikerForFieldCode(mFirmObj.GetFieldCode('ResidenceAddress_ID'));
            if not NxIsEmptyOID(mMoniker.OID) then begin
              mAddressObj := mMoniker.BusinessObject;
              if mNewFirm then
                mAddressObj.SetFieldValueAsString('City', Copy(ADBF.FieldByName('OBEC').AsString, 1, 30))
              else
                if mAddressObj.GetFieldValueAsString('City') = '' then
                  mAddressObj.SetFieldValueAsString('City', Copy(ADBF.FieldByName('OBEC').AsString, 1, 30));
              if mNewFirm then
                mAddressObj.SetFieldValueAsString('Street', Copy(ADBF.FieldByName('ULICE').AsString, 1, 30))
              else
                if mAddressObj.GetFieldValueAsString('Street') = '' then
                  mAddressObj.SetFieldValueAsString('Street', Copy(ADBF.FieldByName('ULICE').AsString, 1, 30));
              if mNewFirm then
                mAddressObj.SetFieldValueAsString('PostCode', Copy(ADBF.FieldByName('PSC').AsString, 1, 10))
              else
                if mAddressObj.GetFieldValueAsString('PostCode') = '' then
                  mAddressObj.SetFieldValueAsString('PostCode', Copy(ADBF.FieldByName('PSC').AsString, 1, 10));
              if mNewFirm then
                mAddressObj.SetFieldValueAsString('PhoneNumber1', Copy(ADBF.FieldByName('TEL').AsString, 1, 30))
              else begin
                //ShowDebugMessage('PhoneNumber1: ' + mAddressObj.GetFieldValueAsString('PhoneNumber1'));
                if mAddressObj.GetFieldValueAsString('PhoneNumber1') = '' then
                  mAddressObj.SetFieldValueAsString('PhoneNumber1', Copy(ADBF.FieldByName('TEL').AsString, 1, 30));
              end;
              if mNewFirm then
                mAddressObj.SetFieldValueAsString('FaxNumber', Copy(ADBF.FieldByName('FAX').AsString, 1, 30))
              else
                if mAddressObj.GetFieldValueAsString('FaxNumber') = '' then
                  mAddressObj.SetFieldValueAsString('FaxNumber', Copy(ADBF.FieldByName('FAX').AsString, 1, 30));
              if mNewFirm then
                mAddressObj.SetFieldValueAsString('EMail', CorrectEmail(Copy(ADBF.FieldByName('MAIL').AsString, 1, 100)))
              else
                if mAddressObj.GetFieldValueAsString('EMail') = '' then
                  mAddressObj.SetFieldValueAsString('EMail', CorrectEmail(Copy(ADBF.FieldByName('MAIL').AsString, 1, 100)));
              ShowDebugMessage('set field na address - ok');
            end;

            (*
            DATAKT -
            u aktualizovaných NACE kódů (FirmNACEs. ChangeDate$DATE)
        – u aktualizovaných kategorizačních údajů (CategoryMetadata.ChangeDate$DATE )
        – -přidáme novou položku do Firms – datum poslední aktualizace (ChangeDate$DATE)
            Z_JMENI - Firms.EquityCapital_ID
            aktualizace se řídí pravidly popsanými v ANA-
        15/07 u tabulky FirmNACEs v závislosti na
        položce NACEUpdateMode, aktualizuje se
        také označení hlavního (MainNACECode)

  Pro správné dohledání záznamu v tabulce CPOC_ZAM je třeba připojit na konci kódu jednu
  nulu a potom hledat v číselníku Abry (kodpol -> Code). Stejné pravidlo platí pro dohledání
  záznamu v tabulce COKEC5, která se později nahradí tabulkou CNACE5 a také pro číselník
  CDRVLST.
            *)
            ShowDebugMessage('save firm - start');
            mFirmObj.Save;
            ShowDebugMessage('save firm - finish');
            mFirmOID := mFirmObj.OID;
            // aktualizace propojeni NACE
            if not NxIsEmptyOID(mNACEOID) then begin
              mFirmNacesOID := FirmNacesOID(fObjectSpace, mNaceOID, mFirmOID);
              ShowDebugMessage('FirmNaces create - start');
              mFirmNaces := fObjectSpace.CreateObject('CQNCHW0PITU4NDUX4MPP340IJC');
              ShowDebugMessage('FirmNaces create - ok');
              try
                if NxIsEmptyOID(mFirmNacesOID) then begin
                  ShowDebugMessage('FirmNaces new - start');
                  mFirmNaces.New;
                  mFirmNaces.Prefill;
                  mFirmNaces.SetFieldValueAsString('Parent_ID', mFirmOID);
                  mFirmNaces.SetFieldValueAsString('Nace_ID', mNACEOID);
                  ShowDebugMessage('FirmNaces new - finish');
                end
                else begin
                  ShowDebugMessage('FirmNaces load - start');
                  mFirmNaces.Load(mFirmNacesOID, nil);
                  ShowDebugMessage('FirmNaces load - ok');
                end;
                if ADBF.FieldByName('DATAKT').AsString <> '' then
                  mFirmNaces.SetFieldValueAsDateTime('ChangeDate$DATE', StrToDate(ADBF.FieldByName('DATAKT').AsString));
                ShowDebugMessage('FirmNaces save - start');
                mFirmNaces.Save;
                ShowDebugMessage('FirmNaces save - ok');
              finally
                mFirmNaces.Free;
              end;
            end;
            CreateOrActualizePerson(ADBF, mFirmOID);
            if mNewFirm then begin
              mSQL := 'update Firms set X_ImportAlbertina = ''A'' where ID = ''%s''';
              mSQL := Format(mSQL, [mFirmOID]);
              fObjectSpace.SQLExecute(mSQL);
            end;
            mSQL := 'update Firms set X_NoCreateFolder = ''N'' where ID = ''%s''';
            mSQL := Format(mSQL, [mFirmOID]);
            fObjectSpace.SQLExecute(mSQL);
            // nastavit CategoryUpdateMode na 3
            mSQL := 'update FirmCategoriesMetadata set CategoryUpdateMode = 3 where Parent_ID = ''%s'' and CategoryItem_ID = ''%s''';
            mSQL := Format(mSQL, [mFirmOID, mCategoryItemOID]);
            fObjectSpace.SQLExecute(mSQL);
          finally
            mFirmObj.Free;
          end;
          ShowDebugMessage('Commit - start');
          fObjectSpace.Commit;
          ShowDebugMessage('Commit - finish');
          SetValueToStorage(cKeyName, mICO, NxCreateContext(fObjectSpace));
          //GetValueFromStorage(cKeyName, NxCreateContext(fObjectSpace));
        except
          ShowDebugMessage('RollBack - start');
          fObjectSpace.RollBack;
          ShowDebugMessage('RollBack - ok');
          RaiseException(ExceptionMessage);
        end;
      end;
    end;
  end;
end;

procedure CreateOrActualizePerson(ADBF: TDBF; AFirmOID: string);
var
  mIndex, i: integer;
  mValueList: TStringList;
  mLine, mSQL, mPersonOID, mPositionOID, mFirmPersonsOID, mICO: string;
  mOSOBA75, mFUNKCE, mPOHLAVI, mTITPRED, mTITZA, mJMENO, mPRIJMENI, mVOKATIV: string;
  mPerson, mPosition, mFirmPersons: TNxCustomBusinessObject;
  //mMoniker: TNxBusinessMoniker;
  mIsUpdate: Boolean;
begin
  mICO := ADBF.FieldByName('ICO').AsString;
  if mICO <> '' then begin
    // natahneme vsechny osoby pro ICO firmy z cache
    mIndex := fPersonsStructure.IndexOf(mICO);
    if mIndex <> -1 then begin
      mValueList := TStringList(fPersonsStructure.Objects(mIndex));
      for i := 0 to mValueList.Count - 1 do begin
        mLine := mValueList.Strings[i];
        mOSOBA75 := CdTokenEx(mLine, '**');
        mFUNKCE := CdTokenEx(mLine, '**');
        mPOHLAVI := CdTokenEx(mLine, '**');
        mTITPRED := CdTokenEx(mLine, '**');
        mTITZA := CdTokenEx(mLine, '**');
        mJMENO := CdTokenEx(mLine, '**');
        mPRIJMENI := CdTokenEx(mLine, '**');
        mVOKATIV := CdTokenEx(mLine, '**');
        if (mJMENO <> '') and (mPRIJMENI <> '') and (mFUNKCE <> '') then begin
          // aktualizovat obecne pracovni pozice na firmspersons CommonWorkPositions
          mSQL :=  'select A.Person_ID from FirmPersons A ' +
                   'left join Persons P on P.ID = A.Person_ID ' +
                   'where A.Parent_ID = ''%s'' and P.Hidden = ''N'' and Upper(Trim(P.LastName)) = ''%s'' and Upper(Trim(P.FirstName)) = ''%s''';
          mSQL := Format(mSQL, [AFirmOID, AnsiUpperCase(ReplaceApostrophes(mPRIJMENI)), AnsiUpperCase(ReplaceApostrophes(mJMENO))]);
          mPersonOID := GetFirstRecordFromSQL(fObjectSpace, mSQL);
          ShowDebugMessage('person create - start');
          mPerson := fObjectSpace.CreateObject('WEC02QYERNCL35CH000ILPWJF4');
          ShowDebugMessage('person create - ok');
          try
            if NxIsEmptyOID(mPersonOID) then begin
              ShowDebugMessage('person new - start');
              mIsUpdate := False;
              mPerson.New;
              mPerson.Prefill;
              ShowDebugMessage('person new - finish');
            end
            else begin
              ShowDebugMessage('person update - start');
              mIsUpdate := True;
              mPerson.Load(mPersonOID, nil);
              ShowDebugMessage('person update - ok');
            end;
            if not mIsUpdate then
              mPerson.SetFieldValueAsString('LastName', Copy(mPRIJMENI, 1, 30))
            else
              if mPerson.GetFieldValueAsString('LastName') = '' then
                mPerson.SetFieldValueAsString('LastName', Copy(mPRIJMENI, 1, 30));
            if not mIsUpdate then
              mPerson.SetFieldValueAsString('FirstName', Copy(mJMENO, 1, 20))
            else
              if mPerson.GetFieldValueAsString('FirstName') = '' then
                mPerson.SetFieldValueAsString('FirstName', Copy(mJMENO, 1, 20));
            if not mIsUpdate then begin
              if mPOHLAVI = 'M' then
                mPerson.SetFieldValueAsString('SalutationTitle', 'Vážený pane');
              if mPOHLAVI = 'F' then
                mPerson.SetFieldValueAsString('SalutationTitle', 'Vážená paní');
            end
            else begin
              if mPerson.GetFieldValueAsString('SalutationTitle') = '' then begin
                if mPOHLAVI = 'M' then
                  mPerson.SetFieldValueAsString('SalutationTitle', 'Vážený pane');
                if mPOHLAVI = 'F' then
                  mPerson.SetFieldValueAsString('SalutationTitle', 'Vážená paní');
              end;
            end;
            if not mIsUpdate then
              mPerson.SetFieldValueAsString('SalutationName', Copy(mVOKATIV, 1, 30))
            else
              if mPerson.GetFieldValueAsString('SalutationName') = '' then
                mPerson.SetFieldValueAsString('SalutationName', Copy(mVOKATIV, 1, 30));
            if not mIsUpdate then
              mPerson.SetFieldValueAsString('Title', Copy(mTITPRED, 1, 20))
            else
              if mPerson.GetFieldValueAsString('Title') = '' then
                mPerson.SetFieldValueAsString('Title', Copy(mTITPRED, 1, 20));
            if not mIsUpdate then
              mPerson.SetFieldValueAsBoolean('X_ImportAlbertina', True);
            ShowDebugMessage('person save - start');
            mPerson.Save;
            ShowDebugMessage('person save - ok');
            mPersonOID := mPerson.OID;
          finally
            mPerson.Free;
          end;
          // aktualizace CommonWorkPosition
          mSQL := 'select ID from CommonWorkPositions where Code = ''%s'' and Hidden = ''N''';
          mSQL := Format(mSQL, [mFUNKCE]);
          mPositionOID := GetFirstRecordFromSQL(fObjectSpace, mSQL);
          if NxIsEmptyOID(mPositionOID) then begin
            ShowDebugMessage('mPosition create - start');
            mPosition := fObjectSpace.CreateObject('2ZJ12WI0TVMOJIS1U0BDKICMD0');
            ShowDebugMessage('mPosition create - ok');
            try
              ShowDebugMessage('mPosition new - start');
              mPosition.New;
              mPosition.Prefill;
              mPosition.SetFieldValueAsString('Code', mFUNKCE);
              mPosition.SetFieldValueAsString('Name', mFUNKCE);
              mPosition.Save;
              ShowDebugMessage('mPosition new - ok po save ok');
              mPositionOID := mPosition.OID;
            finally
              mPosition.Free;
            end;
          end;
          mFirmPersonsOID := FirmForPersonOID(fObjectSpace, mPersonOID, AFirmOID);
          ShowDebugMessage('mFirmPersons create - start');
          mFirmPersons := fObjectSpace.CreateObject('JZ22ZRJ0NNU4B10XV5SWGOHYR4');
          ShowDebugMessage('mFirmPersons create - ok');
          try
            if NxIsEmptyOID(mFirmPersonsOID) then begin
              ShowDebugMessage('mFirmPersons new - start');
              mFirmPersons.New;
              mFirmPersons.Prefill;
              mFirmPersons.SetFieldValueAsString('Parent_ID', AFirmOID);
              mFirmPersons.SetFieldValueAsString('Person_ID', mPersonOID);
              ShowDebugMessage('mFirmPersons new - ok');
            end
            else begin
              ShowDebugMessage('mFirmPersons load - start');
              mFirmPersons.Load(mFirmPersonsOID, nil);
              ShowDebugMessage('mFirmPersons load - ok');
            end;
            //ShowDebugMessage('CommonWorkPosition_ID: ' + mPositionOID);
            if not mIsUpdate then
              mFirmPersons.SetFieldValueAsString('CommonWorkPosition_ID', mPositionOID)
            else
              if NxIsEmptyOID(mFirmPersons.GetFieldValueAsString('CommonWorkPosition_ID')) then
                mFirmPersons.SetFieldValueAsString('CommonWorkPosition_ID', mPositionOID);
            ShowDebugMessage('mFirmPersons save - start');
            mFirmPersons.Save;
            ShowDebugMessage('mFirmPersons save - ok');
          finally
            mFirmPersons.Free;
          end;
        end;
      end;
    end;
  end;
end;

function FirmForPersonOID(AObjectSpace: TNxCustomObjectSpace; APersonOID, AFirmOID: string): string;
var
  mSQL, mSQLRes: string;
begin
  Result := '';
  mSQL := 'select ID FROM FirmPersons FP ' +
          'where FP.Person_ID = ''%s'' and FP.Parent_ID = ''%s''';
  mSQL := Format(mSQL, [APersonOID, AFirmOID]);
  //ShowDebugMessage('SQL: ' + mSQL);
  mSQLRes := GetFirstRecordFromSQL(AObjectSpace, mSQL);
  //ShowDebugMessage('SQL Result: ' + mSQLRes);
  if not NxIsEmptyOID(mSQLRes) then
    Result := mSQLRes;
end;

function FirmNacesOID(AObjectSpace: TNxCustomObjectSpace; ANaceOID, AFirmOID: string): string;
var
  mSQL, mSQLRes: string;
begin
  Result := '';
  mSQL := 'select ID FROM FirmNaces FP ' +
          'where FP.Nace_ID = ''%s'' and FP.Parent_ID = ''%s''';
  mSQL := Format(mSQL, [ANaceOID, AFirmOID]);
  //ShowDebugMessage('SQL: ' + mSQL);
  mSQLRes := GetFirstRecordFromSQL(AObjectSpace, mSQL);
  //ShowDebugMessage('SQL Result: ' + mSQLRes);
  if not NxIsEmptyOID(mSQLRes) then
    Result := mSQLRes;
end;

procedure mbtnFirmClick(Sender: TObject);
var
  mOpenDlg: TNxOpenDialog;
begin
  mOpenDlg := TNxOpenDialog.Create(fSite);
  try
    mOpenDlg.Filter := '*.dbf|*.dbf';
    if mOpenDlg.Execute then begin
      medFileFirms.Text := mOpenDlg.FileName;
    end;
  finally
    mOpenDlg.Free;
  end;
end;

procedure mbtnPersonClick(Sender: TObject);
var
  mOpenDlg: TNxOpenDialog;
begin
  mOpenDlg := TNxOpenDialog.Create(fSite);
  try
    mOpenDlg.Filter := '*.dbf|*.dbf';
    if mOpenDlg.Execute then begin
      medFilePersons.Text := mOpenDlg.FileName;
    end;
  finally
    mOpenDlg.Free;
  end;
end;

function ActualizeCategoryItem: Boolean;
var
  mCategoryItem: TNxCustomBusinessObject;
  mSQL, mExtraOID, mCategoryItemOID, mGroupOID: string;
begin
  Result := True;
  // musi byt vytvorena boolean polozka X_ImportAlbertina u firmy
  mSQL := 'select ID from USERFIELDDEFS2 where FieldName = ''ImportAlbertina'' and ExtraField = ''A''';
  mExtraOID := GetFirstRecordFromSQL(fObjectSpace, mSQL);
  if NxIsEmptyOID(mExtraOID) then begin
    Result := False;
    ShowMessage('Musí být založena boolean extra položka "X_ImportAlbertina" pro firmu. Aplikace bude ukončena.');
  end
  else begin
    mSQL := 'select ID from CategoryItems where Name = ''Import Albertina'' and Hidden = ''N''';
    mCategoryItemOID := GetFirstRecordFromSQL(fObjectSpace, mSQL);
    if NxIsEmptyOID(mCategoryItemOID) then begin
      mSQL := 'select ID from CategoryItemGroups where Name = ''Interní''';
      mGroupOID := GetFirstRecordFromSQL(fObjectSpace, mSQL);
      if NxIsEmptyOID(mGroupOID) then begin
        Result := False;
        ShowMessage('Musí být založena položka Skupiny kategorizačních údajů s názvem "Interní" se vždy platnou podmínkou. Aplikace bude ukončena.');
      end
      else begin
        ShowDebugMessage('mCategoryItem - start');
        mCategoryItem := fObjectSpace.CreateObject('LNMN402BS2ROZIQC1IK1UQVOKW');
        try
          mCategoryItem.New;
          mCategoryItem.Prefill;
          mCategoryItem.SetFieldValueAsString('Name', 'Import Albertina');
          mCategoryItem.SetFieldValueAsInteger('ItemType', 0);
          mCategoryItem.SetFieldValueAsString('UserFieldDef2_ID', mExtraOID);
          mCategoryItem.SetFieldValueAsString('CategoryItemGroup_ID', mGroupOID);
          mCategoryItem.SetFieldValueAsString('FieldName', 'X_ImportAlbertina');
          mCategoryItem.SetFieldValueAsInteger('DataType', 3);
          mCategoryItem.SetFieldValueAsInteger('DataSize', 18);
          mCategoryItem.Save;
          ShowDebugMessage('mCategoryItem - finish ok');
        finally
          mCategoryItem.Free;
        end;
      end;
    end;
  end;
end;

//Vytvoří editační formulář
function MakeForm: TForm;
var
  mForm: TForm;
begin
  mForm := TForm.Create(Nil);
  try
    mForm.Top := 196;
    mForm.Left := 218;
    mForm.Width := 520;
    mForm.Height := 143;//410;
    mForm.Name := 'frmImportAlbertina';
    mForm.Caption := 'Import firem Albertina';
    //mForm.FormStyle := fsStayOnTop;
    mForm.BorderStyle := bsSizeable;
    mForm.Scaled := False;
    mForm.Position := poScreenCenter;
    //mForm.OnClose := @frmFormClose;

    mlblFirm := TLabel.Create(mForm);
    with mlblFirm do begin
      Parent := mForm;
      Name := 'lblFirm';
      Left := 8;
      Top := 22;
      Width := 99;
      Height := 13;
      Caption := 'Soubor importu firem:';
    end;
    
    mlblPerson := TLabel.Create(mForm);
    with mlblPerson do begin
      Parent := mForm;
      Name := 'lblPerson';
      Left := 8;
      Top := 46;
      Width := 100;
      Height := 13;
      Caption := 'Soubor importu osob:';
    end;

    medFileFirms := TEdit.Create(mForm);
    with medFileFirms do begin
      Parent := mForm;
      Name := 'edFileFirms';
      Left := 112;
      Top := 17;
      Width := 169;
      Height := 21;
      TabOrder := 0;
      Text := '';
    end;

    medFilePersons := TEdit.Create(mForm);
    with medFilePersons do begin
      Parent := mForm;
      Name := 'edFilePersons';
      Left := 112;
      Top := 41;
      Width := 169;
      Height := 21;
      TabOrder := 2;
      Text := '';
    end;

    mbtnFirm := TButton.Create(mForm);
    with mbtnFirm do begin
      Parent := mForm;
      Name := 'btnFirm';
      Left := 280;
      Top := 18;
      Width := 25;
      Height := 22;
      Caption := '...';
      Font.Style := [fsBold];
      TabOrder := 1;
    end;

    mbtnPerson := TButton.Create(mForm);
    with mbtnPerson do begin
      Parent := mForm;
      Name := 'btnPerson';
      Left := 280;
      Top := 42;
      Width := 25;
      Height := 22;
      Caption := '...';
      Font.Style := [fsBold];
      TabOrder := 3;
    end;

    mbtnImportAll := TButton.Create(mForm);
    with mbtnImportAll do begin
      Parent := mForm;
      Name := 'btnImportAll';
      Left := 336;
      Top := 8;
      Width := 161;
      Height := 25;
      Caption := 'Importovat a aktualizovat vše';
      TabOrder := 4;
    end;

    mbtnActualizeAll := TButton.Create(mForm);
    with mbtnActualizeAll do begin
      Parent := mForm;
      Name := 'btnActualizeAll';
      Left := 336;
      Top := 40;
      Width := 161;
      Height := 25;
      Caption := 'Import jen nových';
      TabOrder := 5;
    end;

    mbtnActualizeSelected := TButton.Create(mForm);
    with mbtnActualizeSelected do begin
      Parent := mForm;
      Name := 'btnActualizeSelected';
      Left := 336;
      Top := 72;
      Width := 161;
      Height := 25;
      Caption := 'Aktualizovat označené';
      TabOrder := 6;
    end;

    mlblInfo := TLabel.Create(mForm);
    with mlblInfo do begin
      Parent := mForm;
      Name := 'lblInfo';
      Left := 8;
      Top := 68;
      Width := 400;
      Height := 13;
      Caption := 'Poslední zpracované IČO: ';
    end;

    mchkInfo := TCheckBox.Create(mForm);
    with mchkInfo do begin
      Parent := mForm;
      Name := 'mchkInfo';
      Left := 8;
      Top := 87;
      Width := 300;
      Height := 13;
      Caption := 'Pokračovat od poslední zpracované firmy (jen stejný soubor)';
    end;

    mbtnTest := TButton.Create(mForm);
    with mbtnTest do begin
      Parent := mForm;
      Name := 'btnTest';
      Left := 136;
      Top := 72;
      Width := 161;
      Height := 25;
      Caption := 'Test';
      TabOrder := 10;
      Visible := False;
    end;

    mbtnImportAll.OnClick := @mbtnImportAllClick;
    mbtnActualizeAll.OnClick := @mbtnActualizeAllClick;
    mbtnActualizeSelected.OnClick := @mbtnActualizeSelectedClick;
    mbtnFirm.OnClick := @mbtnFirmClick;
    mbtnPerson.OnClick := @mbtnPersonClick;
    mbtnTest.OnClick := @mbtnTestClick;

    //Konec vytvoření formuláře
    Result := mForm;
  except
    //mForm.Free; LUBI vratit
  end;
end;

procedure mbtnTestClick(Sender: TObject);
var
  mDBF: TDbf;
  mValue, mRes, mSQL, mZJmeni: string;
begin
  ShowDebugMessage('mbtnTestClick start');
  // Test na vyskyt des.cark
  //LoadPersonsStructure(fPersonsStructure, nil);
  mDBF := TDBF.Create(nil);
  try
    mDBF.TableName := medFileFirms.Text;
    mDBF.Open;
    mDBF.First;
    while not mDBF.Eof do begin
      //CreateOrActualize(mDBF, True, True);
      mValue := mDBF.FieldByName('Z_JMENI').AsString;
      if NxSearch(mValue, ',', [srAll], 0) <> 0 then begin
        ShowMessage('Nalezena , v retezci: ' + mValue);
        ShowDebugMessage('Nalezena , v retezci: ' + mValue);
        mZJmeni := NxSearchReplace(mDBF.FieldByName('Z_JMENI').AsString, ',', '.', [srAll]);
        mSQL := 'select ID from FinancialCategories where Minimum <= %s and Maximum >= %s';
        mSQL := Format(mSQL, [mZJmeni, mZJmeni]);
        ShowDebugMessage('SQL: ' + mSQL);
        mRes := GetFirstRecordFromSQL(fObjectSpace, mSQL);
      end;
      if NxSearch(mValue, '.', [srAll], 0) <> 0 then begin
        ShowMessage('Nalezena . v retezci: ' + mValue);
        ShowDebugMessage('Nalezena . v retezci: ' + mValue);
      end;
      mDBF.Next;
    end;
  finally
    mDBF.Free; // LUBI doplnit vsude !!!!
  end;
  fForm.Close;
  ShowDebugMessage('CloseForm Finish');
end;

begin
end.