uses
  'eu.abra.PostProviders.uLicence',
  'eu.abra.PostProviders.uConst',
  'eu.abra.PostProviders.uDocTypeFunc',
  'eu.abra.PostProviders.uProgressForm',
  'eu.abra.PostProviders.uMemoMessage',
  'eu.abra.PostProviders.uOutPutPackages',
  'eu.abra.PostProviders.uBalikobotFunc',
  'eu.abra.PostProviders.uImportManager',
  'eu.abra.PostProviders.uLanguage';

procedure ExInitSite_Hook(Self: TSiteForm);
var
  mMultiAction: TMultiAction;
begin
  mMultiAction := Self.GetNewMultiAction;
  if Assigned(mMultiAction) then begin
    mMultiAction.Name := 'actPackages';
    mMultiAction.ShowControl := True;
    mMultiAction.ShowMenuItem := True;
    mMultiAction.Category := 'tabList';
    mMultiAction.Caption := lng_btn_Package;
    mMultiAction.ShortCut := TextToShortCut('CTRL+B');
    mMultiAction.Items.Add( lng_btn_Package0 );
    mMultiAction.Items.Add( lng_btn_Package1);
    mMultiAction.Items.Add( lng_btn_Package2 );
    mMultiAction.Items.Add( lng_btn_Package3 );
    mMultiAction.OnExecuteItem := @actOpenPackagesOnExecuteItem;
    mMultiAction.OnUpdate := @actPackagesOnUpdate;
  end;


  mMultiAction := Self.GetNewMultiAction;
  if Assigned(mMultiAction) then begin
    mMultiAction.Name := 'actPackagesFast';
    mMultiAction.ShowControl := True;
    mMultiAction.ShowMenuItem := True;
    mMultiAction.Category := 'tabList';
    mMultiAction.Caption := lng_btn_PackageFast;
    mMultiAction.Items.Add(lng_btn_PackageFast0);
    //mMultiAction.Items.Add(lng_btn_PackageFast1);
    mMultiAction.Hint := lng_btnHint_PackageFast1;
    //mMultiAction.ShortCut := TextToShortCut('CTRL+B');
    mMultiAction.OnExecuteItem := @actOpenPackagesOnExecuteItemFast;
    mMultiAction.OnUpdate := @actPackagesOnUpdate;
  end;


  mMultiAction := Self.GetNewMultiAction;
  if Assigned(mMultiAction) then begin
    mMultiAction.Name := 'actPackages_B2A';
    mMultiAction.ShowControl := True;
    mMultiAction.ShowMenuItem := True;
    mMultiAction.Category := 'tabList';
    mMultiAction.Caption := lng_btn_Package_Collection;
    mMultiAction.Items.Add( lng_btn_Package_B2A);
    mMultiAction.Items.Add( lng_btn_Package_B2C);
    mMultiAction.OnExecuteItem := @actOpenPackagesOnExecuteItemB2A;
    mMultiAction.OnUpdate := @actPackagesOnUpdate;
  end;


  mMultiAction := Self.GetNewMultiAction;
  if Assigned(mMultiAction) then begin
    mMultiAction.Name := 'actCheckPackage';
    mMultiAction.ShowControl := False;
    mMultiAction.ShowMenuItem := True;
    mMultiAction.Category := 'tabList';
    mMultiAction.Caption := lng_btn_PackageValidation;
    mMultiAction.Items.Add(lng_btn_PackageValidation);
    mMultiAction.Hint := lng_btnHint_PackageValidation ;
    //mMultiAction.ShortCut := TextToShortCut('CTRL+B');
    mMultiAction.OnExecuteItem := @actCheckPackageOnExecuteItem;
    mMultiAction.OnUpdate := @actPackagesOnUpdate;
  end;


end;

{
otevre agendu baliku z OP, DL a FV
}
procedure actOpenPackagesOnExecuteItem(Sender: TControl; Index: integer);
var
  s: string;
  mSite: TSiteForm;
  mP: TNxParameters;
  mContext : TNxContext;
  mList: TStringList;
begin
  if not TestLicence(cIsVisual, s) then exit;
  mSite := Sender.Site;
  mList := TStringList.Create;
  try
    if Index in [0,1,3] then begin
      mP := TNxParameters.Create;
      try
        if Index in [3] then begin
          mSite.FillListWithSelectedRows(mList);
          //Přpojí další označené doklady
          mList.Delete(mList.IndexOf(TDynSiteForm(mSite).CurrentObject.OID));
          OutputDebugString('Sloučené podání. Dodaná ID: '+mList.CommaText);
          mP.NewFromDataType(dtString, NxGetActualUserID(mSite.BaseObjectSpace) + cRelationWithIDs).AsString :=mList.CommaText;
        end;
        mP.NewFromDataType(dtInteger, NxGetActualUserID(mSite.BaseObjectSpace)+cPackages_Site).AsInteger := ObjToInt(mSite);
        mP.NewFromDataType(dtString, NxGetActualUserID(mSite.BaseObjectSpace) + cLastSite).AsString := GetDocumentTypeFromSiteCLSID(mSite.GetSiteCLSID);
        mP.NewFromDataType(dtInteger, NxGetActualUserID(mSite.BaseObjectSpace) + cServiceType).AsInteger := cBBServiceType_ADD;
        //otevřu balíky
        //mSite.ShowDynForm('TMQVRRRTOOLOB0F53Q5THY4XC4', mP, nil, (Index = 1), '');
        mContext := NxCreateContext(mSite.CompanyCache.GetCompanyObjectSpace);
        ShowDynForm('TMQVRRRTOOLOB0F53Q5THY4XC4', mContext, mP, nil, (Index = 1), '');
        DoneAndSelect(TDynSiteForm(mSite));
      finally
        mP.Free;
      end;
    end else if Index = 2 then begin
      ShowPackages(mSite);
    end;
  finally
    mList.Free;
  end;
end;

procedure actOpenPackagesOnExecuteItemB2A(Sender: TControl; Index: integer);
var
  s: string;
  mSite: TSiteForm;
  mP: TNxParameters;
  mContext : TNxContext;
begin
  if not TestLicence(cIsVisual, s) then exit;
  mSite := Sender.Site;
    mP := TNxParameters.Create;
    try
      mP.NewFromDataType(dtInteger, NxGetActualUserID(mSite.BaseObjectSpace)+cPackages_Site).AsInteger := ObjToInt(mSite);
      mP.NewFromDataType(dtString, NxGetActualUserID(mSite.BaseObjectSpace) + cLastSite).AsString := GetDocumentTypeFromSiteCLSID(mSite.GetSiteCLSID);

      case Index of
        0: mP.NewFromDataType(dtInteger, NxGetActualUserID(mSite.BaseObjectSpace) + cServiceType).AsInteger := cBBServiceType_B2A;
        1: mP.NewFromDataType(dtInteger, NxGetActualUserID(mSite.BaseObjectSpace) + cServiceType).AsInteger := cBBServiceType_B2C;
      end;
      //otevřu balíky
      //mSite.ShowDynForm('TMQVRRRTOOLOB0F53Q5THY4XC4', mP, nil, (Index = 1), '');
      mContext := NxCreateContext(mSite.CompanyCache.GetCompanyObjectSpace);
      ShowDynForm('TMQVRRRTOOLOB0F53Q5THY4XC4', mContext, mP, nil, (Index = 1), '');
      DoneAndSelect(TDynSiteForm(mSite));
    finally
      mP.Free;
    end;
end;




{
Rychle vytvoření balíku - Přes ImportManager
}
procedure actOpenPackagesOnExecuteItemFast(Sender: TControl; Index: integer);
var
  s: string;
  mSite: TSiteForm;
  mContext : TNxContext;
  mBO: TNxCustomBusinessObject;
  mListID,mListError,mListTmp :TStringList;
  i: Integer;
  mMemo: TForm;
begin
  if not TestLicence(cIsVisual, s) then exit;
  mSite := Sender.Site;
  if not Assigned( mSite) then exit;
  mBO := nil;
  mListID := TStringList.Create;
  mListError := TStringList.Create;
  mListTmp := TStringList.Create;
  mListError.clear();
  try
  case Index of
    0:
    begin
      mBO := TDynSiteForm(mSite).CurrentObject;
      try
        mListID.add(mBO.OID);
        StartAutoCreatePackage(mSite, mListID, mBO, cOnePeaceWithConectedListDoc );
      finally
        if mBO <> nil then
        mBO.free;
        end;
    end;
    1: begin

      mSite.List.GetSelectedId(mListID);
      for i:= 0 to mListID.Count -1 do
      begin
        mBO := nil;
        try
          try
            mBO := TDynSiteForm(mSite).BaseObjectSpace.CreateObject( GetBOCLSID( GetDocumentTypeFromSiteCLSID(mSite.GetSiteCLSID)) );
            mListTmp.Clear;
            mBO.load(mListID[i],nil);
            mListTmp.add(mBo.oid);
            StartAutoCreatePackage(mSite, mListTmp, mBO, cWithOneParcelPerDoc );
          except
            mListError.add( ExceptionMessage);
          end;
        finally
          if mBO <> nil then
            mBO.Free;
        end;
      end;
    end;
  end;
    //


  if mListError.Count > 0 then
  begin
    mMemo := CreateMemoMessage(mSite, lng_msg_UnfinishedPackage +cCrLf+mListError.Text);
    try
      mMemo.ShowModal(mSite);
    finally
      mMemo.Free;
    end;
  end;

  DoneAndSelect(TDynSiteForm(mSite));

  finally
    mListError.free;
    mListID.Free;
    mListTmp.Free;
  end;

end;



{
Rychlá validace balíku - Přes ImportManager
}
procedure actCheckPackageOnExecuteItem(Sender: TControl; Index: integer);
var
  s: string;
  mSite: TSiteForm;
  mContext : TNxContext;
  mBO: TNxCustomBusinessObject;
  mListID,mListError,mListTmp :TStringList;
  i: Integer;
  mMemo: TForm;
begin
  if not TestLicence(cIsVisual, s) then exit;
  mSite := Sender.Site;
  if not Assigned( mSite) then exit;
  mBO := nil;
  mListID := TStringList.Create;
  mListError := TStringList.Create;
  mListTmp := TStringList.Create;
  mListError.clear();
  try
  case Index of
    0:
    begin
      mBO := TDynSiteForm(mSite).CurrentObject;
      try
        mListID.add(mBO.OID);
        StartCheckPackage(mSite, mListID, mBO, cOnePeaceWithConectedListDoc );
      finally
        if mBO <> nil then
        mBO.free;
        end;
    end;
  end;
    //


  if mListError.Count > 0 then
  begin
    mMemo := CreateMemoMessage(mSite, lng_msg_ValidationResult+cCrLf+mListError.Text);
    try
      mMemo.ShowModal(mSite);
    finally
      mMemo.Free;
    end;
  end;

  DoneAndSelect(TDynSiteForm(mSite));

  finally
    mListError.free;
    mListID.Free;
    mListTmp.Free;
  end;
end;


//zobrazi existujici baliky
procedure ShowPackages(const ASite: TSiteForm);
var
  mOS : TNxCustomObjectSpace;
  mID: TNxOID;
  mIDs: TStringList;
  mStation_ID, mSQL, sqlCondition, mTmp, mSQLGetPackages, mDocumentType: string;
  i: integer;
begin
  mOS := ASite.BaseObjectSpace;
  mIDs := TStringList.Create;
  try
    mDocumentType := GetDocumentTypeFromSiteCLSID(ASite.GetSiteCLSID);
    mSQLGetPackages := GetSQLPackages(mDocumentType);
    ASite.List.GetSelectedId(mIDs);
    mStation_ID := StringsToSelDat(mOS, mIDs);
    try
      mSQL := Format(mSQLGetPackages, [QuotedStr(mStation_ID), '']);
      mIDs.Clear;
      mOS.SQLSelect(mSQL, mIDs);
    finally
      ClearSelDat(mOS, mStation_ID);
    end;
    if (mIDs.Count > 0) then begin
      for i:= 0 to mIDs.Count-1 do begin
        mTmp := mIDs[i];
        mID := NxTrapStr(mTmp, ';');
        mIDs[i] := QuotedStr(mID);
      end;
      sqlCondition := 'a.id in ('+mIDs.CommaText+')';
      ASite.ShowDynForm(Site_PDMIssuedDocs, Nil,Nil, False,
                       'QueryByUserDynSQLCondition;'+sqlCondition+lng_QueryTit_RecordForDocument);
    end else
      NxShowSimpleMessage(lng_msg_NoRecordsFound, ASite);
  finally
    mIDs.Free;
  end;
end;

//export baliku z agendy odeslané posty
//Kontrola,že uživatel nevybral více skladů, dopravců nebo setting s jiným API Usrem.
procedure actExportPackagesOnExecuteItem(Sender: TControl; Index: integer);
var
  s: string;
  mSite: TSiteForm;
  mIDs: TStringList;
  mOS: TNxCustomObjectSpace;
  mMemo: TForm;
begin
  if not TestLicence(cIsVisual, s) then exit;
  mSite := Sender.Site;
  mOS := mSite.BaseObjectSpace;
  try
    mIDs := TStringList.Create;
    gLog := TNxCustomLog.Create(Balikobot_LogName);
    try
      mSite.List.GetSelectedID(mIDs);
      if ( (GetCountProvider(mOS, mIDs) = 1) and (GetCountProviderModul(mOS, mIDs) = 1) and (GetCountSetting(mOS, mIDs) = 1) ) then
      begin
        if (GetProvider(mOS, mIDs[0]) = cDriverBalikobot) then begin
          if  (GetCountStore(mOS, mIDs) = 1) then
            ExportPackages(mSite,mSite.BaseObjectSpace, mIDs, GetProvider(mOS, mIDs[0]), Index)
          else
            NxShowSimpleMessage(lng_msg_ToManyStores, mSite);
        end else begin
          ExportPackages(mSite,mSite.BaseObjectSpace, mIDs, GetProvider(mOS, mIDs[0]), Index);
        end;
      end
      else
        NxShowSimpleMessage(lng_msg_ToManyProviders, mSite);
    finally
      FreeLog;
      mIDs.Free;
    end;
    DoneAndSelect(TDynSiteForm(mSite));
  except
    mMemo := CreateMemoMessage(mSite, lng_msg_Stop +cCrLf+ExceptionMessage);
    try
      mMemo.ShowModal(mSite);
    finally
      mMemo.Free;
    end;
  end;
end;

//export baliku z agendy odeslané posty
procedure actOrderPostProviderOnExecuteItem(Sender: TControl; Index: integer);
var
  s: string;
  mSite: TSiteForm;
  mIDs: TStringList;
  mOS: TNxCustomObjectSpace;
  mMemo, mFormOrder: TForm;
const cSQLSelOrderPackages = 'select a.id pdmissueddocs a where a.X_pd_Store_ID = %s and a.PostProvider_ID = %s and a.x_pd_satus = 2';
begin
  if not TestLicence(cIsVisual, s) then exit;
  mSite := Sender.Site;
  mOS := mSite.BaseObjectSpace;
  try
    mIDs := TStringList.Create;
    try
      case Index of
        0:
        begin
          mSite.List.GetSelectedID(mIDs);
          if ( (GetCountProvider(mOS, mIDs) = 1) and (GetCountProviderModul(mOS, mIDs) = 1) and (GetCountSetting(mOS, mIDs) = 1) ) then
          begin
            if (GetProvider(mOS, mIDs[0]) = cDriverBalikobot) then
            begin
              if  (GetCountStore(mOS, mIDs) = 1) then
                DoOrderPostProvider(mOS, mIDs, GetProvider(mOS, mIDs[0]), Index)
              else
                NxShowSimpleMessage( lng_msg_ToManyStores, mSite);
            end
            else
              DoOrderPostProvider(mOS, mIDs, GetProvider(mOS, mIDs[0]), Index);
          end
          else
            NxShowSimpleMessage(lng_msg_ToManyProviders, mSite);
        end;
      end;
    finally
      mIDs.Free;
    end;
  except
    mMemo := CreateMemoMessage(mSite, lng_msg_Stop+cCrLf+ExceptionMessage);
    try
      mMemo.ShowModal(mSite);
    finally
      mMemo.Free;
    end;
  end;
end;



//smazání baliku na serveru
procedure actDropPackagesOnExecuteItem(Sender: TControl; Index: integer);
var
  s: string;
  mSite: TSiteForm;
  mIDs: TStringList;
  mOS: TNxCustomObjectSpace;
  mMemo: TForm;
begin
  if not TestLicence(cIsVisual, s) then exit;
  mSite := Sender.Site;
  mOS := mSite.BaseObjectSpace;
  try
    mIDs := TStringList.Create;
    gLog := TNxCustomLog.Create(Balikobot_LogName);
    try
      mSite.List.GetSelectedID(mIDs);
      if ( (GetCountProvider(mOS, mIDs) = 1) and (GetCountProviderModul(mOS, mIDs) = 1) and (GetCountSetting(mOS, mIDs) = 1) ) then
      begin
        if (GetProvider(mOS, mIDs[0]) = cDriverBalikobot) then begin
          if  (GetCountStore(mOS, mIDs) = 1) then
            DoDropPackage(mOS, mIDs[0], GetProvider(mOS, mIDs[0]), Index)
          else
            NxShowSimpleMessage(lng_msg_ToManyStores, mSite);
        end else begin
          DoDropPackage(mOS, mIDs[0], GetProvider(mOS, mIDs[0]), Index);
        end;
      end
      else
        NxShowSimpleMessage(lng_msg_ToManyProviders, mSite);
    finally
      FreeLog;
      mIDs.Free;
    end;
  except
    mMemo := CreateMemoMessage(mSite,lng_msg_Stop +cCrLf+ExceptionMessage);
    try
      mMemo.ShowModal(mSite);
    finally
      mMemo.Free;
    end;
  end;
end;

//tisk baliku z agendy odeslané posty
procedure actPrintPackagesOnExecuteItem(Sender: TControl; Index: integer);
var
  s: string;
  mSite: TSiteForm;
  mIDs: TStringList;
  mOS: TNxCustomObjectSpace;
  mMemo: TForm;
begin
  if not TestLicence(cIsVisual, s) then exit;
  mSite := Sender.Site;
  mOS := mSite.BaseObjectSpace;
  try
    mIDs := TStringList.Create;
    try
      mSite.List.GetSelectedID(mIDs);
      if (GetCountProvider(mOS, mIDs) = 1) then
        PrintPackages(mSite.BaseObjectSpace, mIDs, GetProvider(mOS, mIDs[0]), Index)
      else
        NxShowSimpleMessage(lng_msg_ToManyProviders, mSite);
    finally
      mIDs.Free;
    end;
  except
    mMemo := CreateMemoMessage(mSite,lng_msg_Stop+cCrLf+ExceptionMessage);
    try
      mMemo.ShowModal(mSite);
    finally
      mMemo.Free;
    end;
  end;
end;


//spolecne pro FV a odeslanou postu
procedure actPackagesOnUpdate(Sender: TObject);
var
  mSite: TSiteForm;
  mGrid: TMultiGrid;
begin
  if Sender is TComponent then begin
    mSite := TComponent(Sender).Site;
    mGrid := TMultiGrid(mSite.FindComponent('grdRows'));
    if Assigned(mSite) and Assigned(mGrid) then begin
      if mSite is TDynSiteForm then begin
        TBasicAction(Sender).Enabled := not TDynSiteForm(mSite).ActiveDataset.IsEmpty;
      end;
    end;
  end;
end;

//  Aktualizace stavu sledování zásilek z agendy odeslané pošty
procedure actActualizeTrackingStatusesOnExecuteItem(Sender: TControl; Index: integer);
var
  s, mErrorMessage: string;
  mSite: TSiteForm;
  mIDs, mNotFinishedIDs: TStringList;
  mOS: TNxCustomObjectSpace;
  mMemo: TForm;
  i: Integer;
  mDBGrid: TDBGrid;
begin
  if not TestLicence(cIsVisual, s) then exit;
  mSite := Sender.Site;
  mOS := mSite.BaseObjectSpace;
  try
    mIDs := TStringList.Create;
    try
      mSite.List.GetSelectedID(mIDs);
      ActualizeTrackingStatuses(mSite.BaseObjectSpace, mIDs, mErrorMessage);
      DoneAndSelect(TDynSiteForm(mSite));
    finally
      mIDs.Free;
    end;
  except
    mMemo := CreateMemoMessage(mSite, lng_msg_Stop+cCrLf+ExceptionMessage + cCrLf+ mErrorMessage);
    try
      mMemo.ShowModal(mSite);
    finally
      mMemo.Free;
    end;
  end;
end;

// Po dokončení akce refreshne, označí a ztuční záznamy
procedure DoneAndSelect(const ASite: TDynSiteForm);
var
  i: Integer;
begin
  if (TDBGrid(ASite.FindComponent('grdList')).SelectedRows.Count = 0) then
  begin
    HighlightCurrentRow(ASite);
  end
  else
  begin
    for i :=0 To TDBGrid(ASite.FindComponent('grdList')).SelectedRows.Count - 1 do
    begin
      TDBGrid(ASite.FindComponent('grdList')).DataSource.DataSet.GotoBookmark(TDBGrid(ASite.FindComponent('grdList')).SelectedRows.Items[i]);
      HighlightCurrentRow(Asite);
    end;
  end;
end;

procedure HighlightCurrentRow(const ASite: TDynSiteForm);
begin
  //ASite.ActiveDataSet.CurrentItem.Selected := True;
  ASite.ActiveDataSet.CurrentItem.Refresh;
  ASite.ActiveDataSet.UpdateFields;
  //TDBGrid(ASite.FindComponent('grdList')).SelectedRows.CurrentRowSelected := True;
end;


begin
end.

