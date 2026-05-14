uses 'eu.abra.alec.Lipoelastic.PLMImports.fce';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Import TPV';
  mAction.Items.Add('Import TPV');
  //mAction.Items.Add('Klonovat TPV');
  //mAction.Caption := 'Import kus. z CSV';
 // mAction.Hint := 'Naimportuje kusovník ze souboru ve formátu CSV';
  mAction.Category := 'tabList';
  mAction.OnExecuteItem := @ImportPLMRoutine;
end;


procedure ImportPLMRoutine(sender:TComponent; Index: integer);
var
  mBO, mRow, mROBO, mROBONew: TNxCustomBusinessObject;
  mOS: TNxCustomObjectSpace;
  mRows: TNxCustomBusinessMonikerCollection;
  mSite: TSiteForm;
  mOpenDialog: TOpenDialog;
  mExcel, objWorkbook, mXLS: Variant;
  mExcelFileName: String;
  mFileName, mPLMStoreCard_ID, mPLMStoreCardName, mPLMStoreCardCode, mPLMType, mCode, mName, mTAC, mTBC, mTACUnit, mNewCard: string;
  mWorkPlace, mWorkPlace_ID, mStoreCard_ID, mDescription, mQUnit, mTPV_ID, mFinish, mTPVBO_ID, mRoutine_ID, mSelectedSCName, mSkippedCard: string;
  mFinishBool: boolean;
  mTACUnitInt, mTimeCoef, mPos: integer;
  mParams: TNxParameters;
  i, j, k: integer;
  mSelectedList, mAllowedSCList, mErrLog: TStringList;
  mOpenRolSite: TOpenRolSite;
begin
  mSite:= TComponent(sender).Site;
  mOS:= mSite.BaseObjectSpace;
  if index = 0 then
  begin
    mOpenDialog := TOpenDialog.Create(mSite);
    try
      mExcel := CreateOleObject('Excel.Application');
    except
      NxShowSimpleMessage('Není nainstalovaný Microsoft Excel.', mSite);
      mOpenDialog.Free;
      exit;
    end;
    mOpenDialog.Filter := 'Soubor importu (*.xls,*.xlsx)|*.XLS;*.xlsx';
    //OpenDialog.Options := [ofAllowMultiSelect];

    if mOpenDialog.Execute then
    begin
      try
        mExcelFileName := mOpenDialog.FileName;
        objWorkbook:= mExcel.WorkBooks.Open(mExcelFileName);
        mXLS:= mExcel.ActiveWorkbook.WorkSheets[1];
        ProgressInit(mSite, 'Import kusovníku...', mXLS.UsedRange.Rows.Count);
        mErrLog:= TStringList.Create;
        mNewCard:= '';
        mPLMStoreCardCode:= '';

        for i:= 2 to mXLS.UsedRange.Rows.Count do
        begin
          if NxIsBlank(VarToStr(mXLS.Cells[i,1])) then continue;
          mNewCard:=      mXLS.Cells[i, 2];
          mPos:=          StrToInt(VarToStr(mXLS.Cells[i, 3]));
          mName:=         VarToStr(mXLS.Cells[i, 4]);
          mDescription:=  VarToStr(mXLS.Cells[i, 5]);
          mTAC:=          VarToStr(mXLS.Cells[i, 6]);
          mWorkPlace:=    VarToStr(mXLS.Cells[i, 8]);
          mFinish:=       VarToStr(mXLS.Cells[i, 10]);


          if mNewCard = mSkippedCard then continue;

          if mFinish = 'Ano' then mFinishBool:= True else mFinishBool:= False;
          mTACUnit:= 'min'; //je dáno fixně

          case mTACUnit of
            's': begin
              mTACUnitInt:= 0;
              mTimeCoef:= 1;
            end;
            'min': begin
                mTACUnitInt:= 1;
                mTimeCoef:= 60;
            end;
            'h': begin
                mTACUnitInt:= 2;
                mTimeCoef:= 3600;
            end;
          end;

          if (mPLMStoreCardCode <> mNewCard) then
          begin
            mPLMStoreCardCode:= mNewCard;
            mPLMStoreCard_ID:=  mOS.SQLSelectFirstAsString(
              ' SELECT ID FROM StoreCards '+
              ' WHERE Hidden = ''N'' '+
                cSQL_X_Aktivni+
              ' AND IsProduct = ''A'' '+
              ' AND Code = '+QuotedStr(Trim(mPLMStoreCardCode)));
            mTPV_ID:= mOS.SQLSelectFirstAsString('SELECT ID FROM PLMRoutines WHERE StoreCard_ID = '+QuotedStr(mPLMStoreCard_ID));

            if NxIsEmptyOID(mPLMStoreCard_ID) then
            begin
              mErrLog.Add('Řádek: '+IntToStr(i)+' - skladová karta '+mPLMStoreCardCode+' nenalezena, nebo nemá příznak "výrobek". Řádek přeskočen.'+nxCrLf);
              mSkippedCard:= mPLMStoreCardCode;
              continue;
            end;

            mBO:= mOS.CreateObject(Class_PLMRoutine);
            try
              if NxIsEmptyOID(mTPV_ID) then begin
                mBO.New;
                mBO.Prefill;
              end else begin
                mBO.Load(mTPV_ID, nil);
              end;
              mBO.SetFieldValueAsString('StoreCard_ID', mPLMStoreCard_ID);
              mBO.SetFieldValueAsString('Name', mBO.GetFieldValueAsString('StoreCard_ID.Name'));
              mBO.SetFieldValueAsString('RoutineType_ID', '1000000101');    //Kdyžtak změnit za konkrétní     U - univerzální
              mBO.SetFieldValueAsString('QUnit', mBO.GetFieldValueAsString('StoreCard_ID.MainUnitCode'));
              mRows:= mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
              if mRows.Count > 0 then begin
                for j:= 0 to mRows.Count -1 do begin
                  mRows.BusinessObject[j].MarkForDelete;
                end;
              end;
            except
              mErrLog.Add('Řádek '+IntToStr(i)+' - '+mPLMStoreCardCode+ ' - Chyba: '+ExceptionMessage);
              mBO.Free;
              mBO:= nil;
              mPLMStoreCardCode:= '';
              continue;
            end;
          end;
          try
            mWorkPlace:= NxSearchReplace(mWorkPlace, #13, '', [srAll]);
            mWorkPlace:= NxSearchReplace(mWorkPlace, #10, '', [srAll]);
            mWorkPlace:= NxSearchReplace(mWorkPlace, #9, '', [srAll]);
            mWorkPlace:= NxSearchReplace(mWorkPlace, '"', '', [srAll]);
            if NxRight(mWorkPlace, 1) = ' ' then mWorkPlace:= NxLeft(mWorkPlace, Length(mWorkPlace) -1);

            mWorkPlace_ID:= mOS.SQLSelectFirstAsString('SELECT ID FROM PLMWorkPlaces WHERE Hidden = ''N'' AND Code = '+QuotedStr(NxLeft(mWorkPlace, 30)));
            if NxIsEmptyOID(mWorkPlace_ID) then NxShowSimpleMessage(mWorkPlace, mSite);

            mRow:= mRows.AddNewObject;
            mRow.Prefill;
            mRow.SetFieldValueAsInteger('PosIndex', mPos);
            mRow.SetFieldValueAsString('Title', mName);
            mRow.SetFieldValueAsString('Note', mDescription);
            if NxIBStrToFloat(mTAC) > 0 then mRow.SetFieldValueAsFloat('TAC', NxIBStrToFloat(mTAC)*mTimeCoef);
            if NxIBStrToFloat(mTBC) > 0 then mRow.SetFieldValueAsFloat('TBC', NxIBStrToFloat(mTBC)*mTimeCoef);
            mRow.SetFieldValueAsBoolean('Batch', True);
            mRow.SetFieldValueAsBoolean('Finished', mFinishBool);
            mRow.SetFieldValueAsInteger('TACUnit', 1);
            mRow.SetFieldValueAsString('SalaryClass_ID', '1000000101');   // sazba 0,-
            mRow.SetFieldValueAsString('WorkPlace_ID', mWorkPlace_ID);
            //NxShowSimpleMessage(mname, mSite);
            if (VarToStr(mXLS.Cells[i+1, 2]) <> mPLMStoreCardCode) and (i <= mXLS.UsedRange.Rows.Count) then begin
              mTPVBO_ID:= mBO.OID;
              mBO.Save;
              //NxShowSimpleMessage('mBO.saved', mSite);
              mBO.Free;
              mBO:= nil;
              mPLMStoreCardCode:= '';
            end;
            ProgressSetPos(i);
          except
            mErrLog.Add('Řádek: '+IntToStr(i)+' - skladová karta '+mPLMStoreCardCode+' '+ExceptionMessage);
            mBO.Free;
            mBO:= nil;
            mPLMStoreCardCode:= '';
            continue;
          end;

           {
            mPLMStoreCardCode:= mNewCard;
            if Assigned(mBO) then begin
              mTPVBO_ID:= mBO.OID;
              try
                mBO.Save;
                mBO.Free;
              except
                mErrLog.Add('Řádek '+IntToStr(i)+' - '+mPLMStoreCardCode+ ' - Chyba: '+ExceptionMessage);
                mBO.Free;
                mBO:= nil;
                mPLMStoreCardCode:= '';
                continue;
              end;
            end;

            mPLMStoreCard_ID:=  mOS.SQLSelectFirstAsString('SELECT ID FROM StoreCards WHERE Hidden = ''N'' AND IsProduct = ''A'' AND Code = '+QuotedStr(Trim(mPLMStoreCardCode)));
            mTPV_ID:= mOS.SQLSelectFirstAsString('SELECT ID FROM PLMRoutines WHERE StoreCard_ID = '+QuotedStr(mPLMStoreCard_ID));

            if NxIsEmptyOID(mPLMStoreCard_ID) then
            begin
              mErrLog.Add('Řádek: '+IntToStr(i)+' - skladová karta '+mPLMStoreCardCode+' nenalezena, nebo nemá příznak "výrobek". Řádek přeskočen.'+nxCrLf);
              //NxShowSimpleMessage('Skladová karta s kódem '+mPLMStoreCardCode+' nenalezena, nebo nemá příznak "Výrobek". Ukončuji.', mSite);
              continue;
            end;

            mBO:= mOS.CreateObject(Class_PLMRoutine);
            try
              if NxIsEmptyOID(mTPV_ID) then begin
                mBO.New;
                mBO.Prefill;
              end else begin
                mBO.Load(mTPV_ID, nil);
              end;
              mBO.SetFieldValueAsString('StoreCard_ID', mPLMStoreCard_ID);
              mBO.SetFieldValueAsString('Name', mBO.GetFieldValueAsString('StoreCard_ID.Name'));
              mBO.SetFieldValueAsString('RoutineType_ID', '1000000101');    //Kdyžtak změnit za konkrétní
              mBO.SetFieldValueAsString('QUnit', mBO.GetFieldValueAsString('StoreCard_ID.MainUnitCode'));
              mRows:= mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
              }
              {
              if mRows.Count > 0 then
              begin
                for j:= 0 to mRows.Count -1 do
                begin
                  mRows.BusinessObject[j].MarkForDelete;
                end;
              end;
            except
              mErrLog.Add('Řádek: '+IntToStr(i)+' - skladová karta '+mPLMStoreCardCode+' '+ExceptionMessage);
              mBO.Free;
              mBO:= nil;
              mPLMStoreCardCode:= '';
              continue;
            end;
          end;
          }
          {
          if i = mXLS.UsedRange.Rows.Count then
          begin
            mBO.Save;
            mBO.Free;
            mBO:= nil;
          end; }
        end;
      finally
        ProgressDispose();
        mOpenDialog:= nil;
        mOpenDialog.Free;
        mExcel.Workbooks.Close;
        mExcel.quit;
        mExcel:= nil;
        TDynSiteForm(mSite).RefreshData;
        TDynSiteForm(mSite).ActiveDataSet.SeekID(mTPVBO_ID);
      end;
    end;
  end;
  if index = 1 then
  begin
    mRoutine_ID:= TDynSiteForm(mSite).CurrentObject.OID;
    if not(NxIsEmptyOID(mRoutine_ID)) then
    begin
      try
        mSelectedList:= nil;
        mSelectedList:= TStringList.create;
        mAllowedSCList:= TStringList.create;
        mOS.SQLSelect(
        ' SELECT SC.ID FROM StoreCards SC '+
        ' WHERE SC.IsProduct = ''A'' '+
          cSQL_X_Aktivni+
        ' AND Hidden = ''N'' '+
        ' AND SC.ID NOT IN (SELECT RO.StoreCard_ID FROM PLMRoutines RO)', mAllowedSCList);
        mParams := TNxParameters.Create;
        mParams.NewFromDataType(dtString, '_Allowed').AsString := mAllowedSCList.Text; // Omezeno na vybrané ID záznamů
        mOpenRolSite := TOpenRolSite.Create(mSite.SiteContext, Roll_StoreCards);
        mOpenRolSite.ParentForm := mSite.GetSiteAppForm;
        mOpenRolSite.MultiChoice := True;
        mOpenRolSite.Detailed := False;
        mOpenRolSite.AdditionalParams := mParams;
        mOpenRolSite.Open;
        mOpenRolSite.SelectedList;

        mParams.Free;
        if mOpenRolSite.SelectedList.Count > 0 then begin
          if NxMessageBox('Dotaz', 'Přejete si naklonovat vybraný technologický postup do vybraných skladových karet ('+IntToStr(mOpenRolSite.SelectedList.Count)+')?'+#10#13+
          '', mdConfirm, mdbYesNo, 0, 0, False, Nil)=mrYes then
          begin
            mROBO:= mOS.CreateObject(Class_PLMRoutine);
            mROBO.Load(mRoutine_ID, nil);
            for k:= 0 to mOpenRolSite.SelectedList.Count -1 do
            begin
              mSelectedSCName:= mOS.SQLSelectFirstAsString(' SELECT Name FROM StoreCards WHERE ID = '+QuotedStr(mOpenRolSite.SelectedList[k]));
              mROBONew:= mROBO.Clone;
              mROBONew.SetFieldValueAsString('StoreCard_ID', mOpenRolSite.SelectedList[k]);
              mROBONew.SetFieldValueAsString('Name', mSelectedSCName);
              mROBONew.Save;
              mROBONew.Free;
            end;
            mROBO.Free;
          end;
        end;
      except
        NxShowSimpleMessage('Technologický postup se nepodařilo vytvořit. Chyba: '+ExceptionMessage, mSite);
        mROBO.Free;
        mROBONew.Free;
        mAllowedSCList.Free;
        //mSelectedList.Free;
        mOpenRolSite.Free;
        exit;
      end;
      //mSelectedList.Free;
      mAllowedSCList.Free;
      mOpenRolSite.Free;
      TDynSiteForm(mSite).RefreshData;
      TDynSiteForm(mSite).ActiveDataSet.SeekID(mRoutine_ID);
    end;
  end;
  if mErrLog.Count > 0 then begin
    NxShowEditorSite(NxCreateContext(mOS), mErrLog.text, true);
  end;
end;


begin
end.