{
Vyvolava se po provedení inicializace agendy/formulare. V tento okamzik je jiz na formulari dostupny SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction:= Self.GetNewAction;
  mAction.Caption:= '##Import účtů (CSV)##';
  mAction.Name:= 'actAccImport';
  mAction.Category:= 'tablist';
  mAction.OnExecute:= @actAccImport;
end;

procedure actAccImport(Sender: TComponent);
var
  mSite: TSiteForm;
  mBO: TNxCustomBusinessObject;
  mOS: TNxCustomObjectSpace;
  mList: TStringList;
  mOpenDlg: TOpenDialog;
  mTempStr, mGroup1, mGroup2, mGroup3, mCode, mNamePart1, mNamePart2, mName, mAccountTypeNaklad, mAccountTypeVynos, mAccount_ID, mAktivni: string;
  mDanovy, mKratkodoby, mDoNakladu, mDoVynosu, mFileName, mAccountType: string;
  mIsCostForProjectControl, mIsIncomplete, mIsRevenueForProjectControl, mPrintToAcumulatedStatement, mShort, mTaxable, mTransferable: Boolean;
  i, mAccountTypeIndex: integer;
begin
  mSite:= TComponent(Sender).BusRollSite;
  mOS:= mSite.BaseObjectSpace;
  mList:= TStringList.Create;

  mOpenDlg := TOpenDialog.Create(Sender);
  mOpenDlg.Filter := 'Soubor importu (*.CSV,*.csv)|*.CSV;*.csv';
  //mOpenDlg.Options := [ofAllowMultiSelect];
  if mOpenDlg.Execute then mFileName := mOpenDlg.FileName else Exit;

  try
    mList.LoadFromFile(mOpenDlg.FileName);
    OutputDebugString('file otevren');
    //if mList.Count>0 then begin

    WaitWin.StartProgress('Čekejte, prosím ...', '', mList.Count);

    for i:= 1 to mList.Count -1 do
    begin
      mTempStr:= mlist.Strings[i];
      mGroup1:= CdTokenEx(mTempStr, ';');
      mGroup2:= CdTokenEx(mTempStr, ';');
      mGroup3:= CdTokenEx(mTempStr, ';');
      mCode:= mGroup1+mGroup2+mGroup3;
      mNamePart1:= CdTokenEx(mTempStr, ';');
      mNamePart2:= CdTokenEx(mTempStr, ';');
      mName:= CdTokenEx(mTempStr, ';');
      mAccountTypeNaklad:= CdTokenEx(mTempStr, ';');
      mAccountTypeVynos:= CdTokenEx(mTempStr, ';');
      mDanovy:= CdTokenEx(mTempStr, ';');
      mKratkodoby:= CdTokenEx(mTempStr, ';');
      mDoNakladu:= CdTokenEx(mTempStr, ';');
      mDoVynosu:= CdTokenEx(mTempStr, ';');
      mAktivni:= CdTokenEx(mTempStr, ';');

      if not(NxIsBlank(mDanovy)) then mTaxable:= true else mTaxable:= false;
      if not(NxIsBlank(mKratkodoby)) then mShort:= true else mShort:= false;
      if not(NxIsBlank(mDoNakladu)) then mIsCostForProjectControl:= true else mIsCostForProjectControl:= false;
      if not(NxIsBlank(mDoVynosu)) then mIsRevenueForProjectControl:= true else mIsRevenueForProjectControl:= false;

      if not(NxIsBlank(mAccountTypeNaklad)) then begin
        mAccountTypeIndex:= 2;
        mAccountType:= 'C';
      end;
      if not(NxIsBlank(mAccountTypeVynos)) then begin
        mAccountTypeIndex:= 3;
        mAccountType:= 'G';
      end;
      if not(NxIsBlank(mAktivni)) then begin
        mAccountTypeIndex:= 0;
        mAccountType:= 'A';
      end;

      mAccount_ID:= mOS.SQLSelectFirstAsString(' SELECT ID FROM Accounts WHERE Hidden =''N'' AND Code ='+QuotedStr(mCode));


      mBO:= mOS.CreateObject(Class_Account);
      try
        if NxIsEmptyOID(mAccount_ID) then
        begin
          mBO.New;
          mBO.Prefill;
        end else
        begin
          mBO.Load(mAccount_ID, nil);
        end;
        mBO.SetFieldValueAsString('Code', mCode);
        mBO.SetFieldValueAsString('Name', mNamePart1);
        mBO.SetFieldValueAsInteger('AccountTypeIndex', mAccountTypeIndex);
        mBO.SetFieldValueAsString('AccountType', mAccountType);
        mBO.SetFieldValueAsBoolean('Taxable', mTaxable);
        mBO.SetFieldValueAsBoolean('Short', mShort);
        if not(NxIsBlank(mDoNakladu)) then mBO.SetFieldValueAsBoolean('IsCostForProjectControl', mIsCostForProjectControl);
        if not(NxIsBlank(mDoVynosu)) then mBO.SetFieldValueAsBoolean('IsRevenueForProjectControl', mIsRevenueForProjectControl);
        mBO.SetFieldValueAsBoolean('X_Selected', true);
        mBO.Save;
      finally
        mBO.Free;
      end;
      WaitWin.ChangeText(IntToStr(i) + ' / ' + IntToStr(mList.Count));
      WaitWin.StepIt;
    end;
    WaitWin.Stop;
  finally
    mList.Free;
  end;
end;

Function CdTokenEx(var AStr: string; const ASeparators: string): string;
var
  i: Integer;
begin
  i := NxCharPos(ASeparators, AStr);
  if i > 0 then begin
    Result := Copy(AStr, 1, i-1);
    Delete(AStr, 1, i-1);
    Delete(AStr, 1, Length(ASeparators));
  end
  else
  begin
    Result := AStr;
    AStr := '';
  end;
  Result := NxTrim(Result, '"');
  Result := NxTrim(Result, '''');
end;

function GetOrCreateStoreMenuItem(AOS: TNxCustomObjectSpace; AList: TStringList; AIndex: Integer;): string;
var
  mID, mParent_ID: string;
begin
  if AIndex = 0 then begin
    mID:= AOS.SQLSelectFirstAsString('SELECT ID FROM StoreMenu WHERE Hidden=''N'' AND Text='+QuotedStr(AList[AIndex]));
    if NxIsEmptyOID(mID) then mID:= CreateNewStoreMenuItem(AOS, AList[AIndex], '');
    Result:= mID;
    exit;
  end else begin
    if (AIndex - 1) >=0 then
    begin
      mParent_ID:= AOS.SQLSelectFirstAsString('SELECT ID FROM StoreMenu WHERE Hidden=''N'' AND Text='+QuotedStr(AList[AIndex -1]));
      if NxIsEmptyOID(mParent_ID) then begin
        mParent_ID:= GetOrCreateStoreMenuItem(AOS, AList, AIndex -1);
      end;
    end else
    begin
      mParent_ID:='';
    end;
    mID:= AOS.SQLSelectFirstAsString(' SELECT ID FROM StoreMenu WHERE Hidden=''N'' AND Text='+QuotedStr(AList[AIndex])+' AND Parent_ID='+QuotedStr(mParent_ID));
    if NxIsEmptyOID(mID) then mID:= CreateNewStoreMenuItem(AOS, AList[AIndex], mParent_ID);
    Result:= mID;
  end;
end;

function CreateNewStoreMenuItem(AOS: TNxCustomObjectSpace; AText, AParent_ID: string): string;
var
  mSMBO: TNxCustomBusinessObject;
begin
  mSMBO:= AOS.CreateObject(Class_StoreMenuItem);
  try
    mSMBO.New;
    mSMBO.Prefill;
    mSMBO.SetFieldValueAsString('Text', AText);
    if not(NxIsEmptyOID(AParent_ID)) then mSMBO.SetFieldValueAsString('Parent_ID', AParent_ID);
    mSMBO.Save;
    Result:= mSMBO.OID;
  finally
    mSMBO.Free;
  end;
end;



begin
end.