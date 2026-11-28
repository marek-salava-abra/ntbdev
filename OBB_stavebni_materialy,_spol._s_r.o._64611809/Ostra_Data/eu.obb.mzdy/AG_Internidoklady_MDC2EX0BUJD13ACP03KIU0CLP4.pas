uses 'eu.obb.mzdy.ParseData', 'eu.obb.mzdy.Progress';

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
  mBAction:TBasicAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Import mezd';
  mAction.Items.Add('Stary import');
  mAction.Items.Add('Import VEMA');
  //mAction.Items.Add('Revize');
  mAction.Hint := 'Provede import z csv';
  mAction.Category := 'tabDetail';
  mAction.OnExecuteItem := @ImportData;

  mBAction:= Self.GetNewAction;
  mBAction.ShowControl := True;
  mBAction.ShowMenuItem := True;
  mBAction.Name := 'actImportCepro';
  mBAction.Caption := 'Import ČEPRO';
  mBAction.Category := 'tabDetail';
  mBAction.OnExecute := @ImportCepro;

end;

procedure ImportData(sender:Tcomponent; index:integer);
var
 mSite:TsiteForm;
 mOS:TNxCustomObjectSpace;
 mSMBO, mFirmBO, mbankBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mRow:TNxCustomBusinessObject;
 mList:TStringList;
 mopenDLG:TOpenDialog;
 mParams, mParRow : TNxParameters;
 i, j, k:integer;
 mFirm_ID, mDivisionMDCode, mDivisionDCode:String;
 mNew:Boolean;
 mBO:TNxCustomBusinessObject;
 mGRows : TMultiGrid;
 {Neco,jmeno, prijmeni,cislo,text,castka,mds,mda,ds,da,nic,btmd,btd,smd,sd,mducet,ducet}
begin
 mSite:=TComponent(sender).DynSite;
 mOS:=msite.BaseObjectSpace;
  if index=0 then begin
  mOpenDlg := TOpenDialog.Create(Sender);
  try
    if mOpenDlg.Execute then begin
      try
        mList := TStringList.Create;
        mList.LoadFromFile(mOpenDlg.FileName);
        mParams := ParseData(mlist);
        mBO := TDynSiteForm(mSite).CurrentObject;
        mRows:=mbo.GetCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows'));
        mGRows :=  TMultiGrid(TWinControl(msite.FindChildControl('tabRows')).FindChildControl('grdRows'));
        j:=TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Count;
        try
           ProgressInit(mSite, 'Import mezd...', j);
           for i := 0 to j - 1 do begin
           mParRow := TNxParameters(TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Params(i));
            mRow:=mRows.AddNewObject;
            mRow.SetFieldValueAsString('DebitAccount_ID',GetAccount_ID(mOS,NxSearchReplace(mParRow.ParamByName('mds').AsString,'"','',[srAll])+NxSearchReplace(mParRow.ParamByName('mda').AsString,'"','',[srAll])));
            mRow.SetFieldValueAsString('CreditAccount_ID',GetAccount_ID(mOS,NxSearchReplace(mParRow.ParamByName('ds').AsString,'"','',[srAll])+NxSearchReplace(mParRow.ParamByName('da').AsString,'"','',[srAll])));
            mRow.SetFieldValueAsString('DebitDivision_ID',GetDivision_ID(mos,NxSearchReplace(mParRow.ParamByName('sd').AsString,'"','',[srAll])));
            mRow.SetFieldValueAsString('CreditDivision_ID',GetDivision_ID(mos,NxSearchReplace(mParRow.ParamByName('sd').AsString,'"','',[srAll])));
            mRow.SetFieldValueAsString('Text', NxSearchReplace(mParRow.ParamByName('Jmeno').AsString,'"','',[srAll])+' '+
            NxSearchReplace(mParRow.ParamByName('prijmeni').AsString,'"','',[srAll])+' '+
            NxSearchReplace(mParRow.ParamByName('Text').AsString,'"','',[srAll]));
            //if i<5 then NxShowSimpleMessage(NxSearchReplace(mParRow.ParamByName('prijmeni').AsString,'"','',[srAll])+ ' '+ mParRow.ParamByName('prijmeni').AsString, mSite);
            mRow.SetFieldValueAsFloat('TAmount',NxIBStrToFloat(mParRow.ParamByName('castka').asstring));
            mRow.SetFieldValueAsFloat('LocalTAmount',NxIBStrToFloat(mParRow.ParamByName('castka').asstring));
          end;
          ProgressDispose();
        finally
         if Assigned(mGRows) then
            mGRows.DataSource.DataSet.Refresh;
        end;
      finally
      end;
    end;
  finally
  end;
  end;
  if index=1 then begin
  mOpenDlg := TOpenDialog.Create(Sender);
  try
    if mOpenDlg.Execute then begin
       try
        mList := TStringList.Create;
        mList.LoadFromFile(mOpenDlg.FileName);
        mParams := ParseData2(mlist);
        mBO := TDynSiteForm(mSite).CurrentObject;
        mRows:=mbo.GetCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows'));
        mGRows :=  TMultiGrid(TWinControl(msite.FindChildControl('tabRows')).FindChildControl('grdRows'));
        j:=TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Count;
        try
           ProgressInit(mSite, 'Import mezd...', j);
           for i := 3 to j - 1 do begin
           mParRow := TNxParameters(TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Params(i));
            mRow:=mRows.AddNewObject;
            mRow.SetFieldValueAsString('DebitAccount_ID',GetAccount_ID(mOS,NxSearchReplace(mParRow.ParamByName('ucmd').AsString,'"','',[srAll])));
            mRow.SetFieldValueAsString('CreditAccount_ID',GetAccount_ID(mOS,NxSearchReplace(mParRow.ParamByName('ucdal').AsString,'"','',[srAll])));
            mDivisionMDCode:=AnsiLeftStr(NxSearchReplace(mParRow.ParamByName('naklm').AsString,'"','',[srAll])+'0',2);
            mRow.SetFieldValueAsString('DebitDivision_ID',GetDivision_ID(mos,mDivisionMDCode));
            mDivisionDCode:=AnsiLeftStr(NxSearchReplace(mParRow.ParamByName('nakld').AsString,'"','',[srAll])+'0',2);
            mRow.SetFieldValueAsString('CreditDivision_ID',GetDivision_ID(mos,mDivisionDCode));
            mRow.SetFieldValueAsString('Text', NxSearchReplace(mParRow.ParamByName('poznamka').AsString,'"','',[srAll]));
            mRow.SetFieldValueAsFloat('TAmount',NxIBStrToFloat(mParRow.ParamByName('mdkcs').asstring));
            mRow.SetFieldValueAsFloat('LocalTAmount',NxIBStrToFloat(mParRow.ParamByName('mdkcs').asstring));
          end;
          ProgressDispose();
        finally
         if Assigned(mGRows) then
            mGRows.DataSource.DataSet.Refresh;
        end;
      finally
      end;
     end;
   finally
  end;
  end;
end;


function GetCeproReferenceID(AObjectSpace: TNxCustomObjectSpace;
  ATable, ACode, AFieldName: string): string;
begin
  Result := AObjectSpace.SQLSelectFirstAsString(
    'SELECT ID FROM ' + ATable + ' WHERE Code = ' + QuotedStr(ACode)
    + ' AND Hidden = ''N''', '');
  if NxIsEmptyOID(Result) then
    RaiseException(Format('%s s kódem %s nebyl nalezen.', [AFieldName, ACode]));
end;

procedure ImportCepro(Sender: TComponent);
const
  cDefaultDivisionCode = '40';
var
  mSite: TDynSiteForm;
  mObjectSpace: TNxCustomObjectSpace;
  mRow: TNxCustomBusinessObject;
  mRowsDataSet: TNxRowsObjectDataSet;
  mRowsGrid: TMultiGrid;
  mOpenDialog: TOpenDialog;
  mFileLines, mColumns, mImportLines: TStringList;
  mLineIndex: Integer;
  mEmptyLine: Boolean;
  mColumnIndex: Integer;
  mAmountText, mDebitDivisionCode, mCreditDivisionCode: string;
  mAmount: Extended;
begin
  mSite := TDynSiteForm(TComponent(Sender).DynSite);
  if not mSite.Edit then
    RaiseException('Pro import ČEPRO otevřete doklad k opravě.');

  mObjectSpace := mSite.BaseObjectSpace;
  mOpenDialog := TOpenDialog.Create(Sender);
  try
    mOpenDialog.Title := 'Import ČEPRO';
    mOpenDialog.Filter := 'Soubory CSV (*.csv)|*.csv';
    if not mOpenDialog.Execute then
      Exit;

    mFileLines := TStringList.Create;
    try
      mFileLines.LoadFromFile(mOpenDialog.FileName);
      if mFileLines.Count < 2 then
        Exit;

      mColumns := TStringList.Create;
      try
        mColumns.Delimiter := ';';
        mColumns.StrictDelimiter := True;
        mImportLines := TStringList.Create;
        try
          WaitWin.StartProgress('Import ČEPRO', '', mFileLines.Count - 1);
          try
            // Ověření CSV a převod kódů na ID před změnou dokladu.
            for mLineIndex := 1 to mFileLines.Count - 1 do begin
              WaitWin.ChangeText(Format('Kontrola řádku %d / %d', [mLineIndex, mFileLines.Count - 1]));
              WaitWin.StepIt;
              mColumns.DelimitedText := mFileLines.Strings[mLineIndex];
              mEmptyLine := True;
              for mColumnIndex := 0 to mColumns.Count - 1 do begin
                mColumns.Strings[mColumnIndex] := Trim(mColumns.Strings[mColumnIndex]);
                if mColumns.Strings[mColumnIndex] <> '' then
                  mEmptyLine := False;
              end;
              if mEmptyLine then
                Continue;
              if UpperCase(mColumns.Strings[0]) = 'CELKEM BEZ DPH' then
                Continue;

              try
                if mColumns.Count < 10 then
                  RaiseException('Očekává se alespoň 10 sloupců.');
                mAmountText := NxSearchReplace(mColumns.Strings[1], ',', '.', [srAll]);
                if mAmountText = '' then
                  RaiseException('Chybí částka ve sloupci 2.');
                mAmount := NxIBStrToFloat(mAmountText);
                mColumns.Strings[1] := FloatToStr(mAmount);

                mDebitDivisionCode := mColumns.Strings[3];
                if mDebitDivisionCode = '' then
                  mDebitDivisionCode := cDefaultDivisionCode;
                mCreditDivisionCode := mColumns.Strings[4];
                if mCreditDivisionCode = '' then
                  mCreditDivisionCode := cDefaultDivisionCode;
                mColumns.Strings[3] := GetCeproReferenceID(mObjectSpace, 'Divisions', mDebitDivisionCode, 'Středisko MD');
                mColumns.Strings[4] := GetCeproReferenceID(mObjectSpace, 'Divisions', mCreditDivisionCode, 'Středisko Dal');

                if mColumns.Strings[5] <> '' then
                  mColumns.Strings[5] := GetCeproReferenceID(mObjectSpace, 'BusTransactions', mColumns.Strings[5], 'Obchodní případ MD');
                if mColumns.Strings[6] <> '' then
                  mColumns.Strings[6] := GetCeproReferenceID(mObjectSpace, 'BusTransactions', mColumns.Strings[6], 'Obchodní případ Dal');

                mColumns.Strings[7] := GetCeproReferenceID(mObjectSpace, 'Accounts', mColumns.Strings[7], 'Účet MD');
                mColumns.Strings[8] := GetCeproReferenceID(mObjectSpace, 'Accounts', mColumns.Strings[8], 'Účet Dal');
                mImportLines.Add(mColumns.DelimitedText);
              except
                RaiseException(Format('Import ČEPRO, řádek CSV %d. %s', [mLineIndex + 1, ExceptionMessage]));
              end;
            end;

            if mImportLines.Count = 0 then
              Exit;
            WaitWin.ChangeText('Vkládám řádky do dokladu…');
            mRowsGrid := TMultiGrid(mSite.FindChildControl('tabRows.grdRows'));
            if not Assigned(mRowsGrid) then
              RaiseException('Mřížka řádků interního dokladu není dostupná.');
            if not Assigned(mRowsGrid.DataSource) then
              RaiseException('Zdroj dat řádků interního dokladu není dostupný.');
            mRowsDataSet := TNxRowsObjectDataSet(mRowsGrid.DataSource.DataSet);
            if not Assigned(mRowsDataSet) then
              RaiseException('Dataset řádků interního dokladu není dostupný.');

            mRowsDataSet.DisableControls;
            try
              for mLineIndex := 0 to mImportLines.Count - 1 do begin
                mColumns.DelimitedText := mImportLines.Strings[mLineIndex];
                mAmount := StrToFloat(mColumns.Strings[1]);
                mRow := mRowsDataSet.CreateBusinessObject;
                try
                  mRow.Prefill;
                  mRow.SetFieldValueAsString('DebitAccount_ID', mColumns.Strings[7]);
                  mRow.SetFieldValueAsString('CreditAccount_ID', mColumns.Strings[8]);
                  mRow.SetFieldValueAsString('DebitDivision_ID', mColumns.Strings[3]);
                  mRow.SetFieldValueAsString('CreditDivision_ID', mColumns.Strings[4]);
                  mRow.SetFieldValueAsString('DebitBusTransaction_ID', mColumns.Strings[5]);
                  mRow.SetFieldValueAsString('CreditBusTransaction_ID', mColumns.Strings[6]);
                  mRow.SetFieldValueAsString('Text', mColumns.Strings[9]);
                  mRow.SetFieldValueAsFloat('TAmount', mAmount);
                  mRow.SetFieldValueAsFloat('LocalTAmount', mAmount);
                finally
                  mRow.Free;
                end;
              end;
            finally
              try
                mSite.ActiveDataSet.UpdateFields;
                mRowsDataSet.RefreshAndRestoreLastSelectedItem;
              finally
                mRowsDataSet.EnableControls;
              end;
            end;
          finally
            WaitWin.Stop;
          end;
        finally
          mImportLines.Free;
        end;
      finally
        mColumns.Free;
      end;
    finally
      mFileLines.Free;
    end;
  finally
    mOpenDialog.Free;
  end;
end;

begin
end.
