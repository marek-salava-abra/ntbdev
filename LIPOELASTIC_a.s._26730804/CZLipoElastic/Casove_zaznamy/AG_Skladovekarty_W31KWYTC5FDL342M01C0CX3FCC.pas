procedure TimeOnExec(Sender: TComponent;index:integer);       // přidělení objectspace a zadání zdrojového souboru
var
    mBO: TNxCustomBusinessObject;
    i : integer;
  mSite: TSiteForm;
  mbookmark:TBookmarkList;
  mdbgrid:TDBGrid;
  mString:string;
  ActivityArea_ID,ActivityType_ID,ActQueue_ID:string;
begin
    ActivityArea_ID :='1300000101';
    ActivityType_ID:='1600000101';
    ActQueue_ID:='3700000101';
    if Sender is TComponent then begin
          mSite := NxFindSiteForm(Sender);
          if Assigned(mSite) and (mSite is TBusRollSiteForm) then begin
               mbo:= TBusRollSiteForm(mSite).CurrentObject;
                    try

                            if mBookmark.count=0 then begin
                                        mBO := TBusRollSiteForm(mSite).CurrentObject;
                                        NewActivity(msite, TBusRollSiteForm(mSite).CurrentObject.OID,'',ActivityArea_ID,ActivityType_ID,ActQueue_ID);
                                        //mString:= create_activity(msite, TBusRollSiteForm(mSite).CurrentObject.OID,'',ActivityArea_ID,ActivityType_ID,ActQueue_ID);
                            end else begin
                               for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
                                        mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                                              mBO := TBusRollSiteForm(mSite).CurrentObject;
                                               NewActivity(msite, TBusRollSiteForm(mSite).CurrentObject.OID,'',ActivityArea_ID,ActivityType_ID,ActQueue_ID);
                                              //mString:= create_activity(msite, TBusRollSiteForm(mSite).CurrentObject.OID,'',ActivityArea_ID,ActivityType_ID,ActQueue_ID);
                                end;
                            end;
                   finally
                   end;
                 TBusRollSiteForm(msite).DataSet.RefreshCurrentItemMode;
                 TBusRollSiteForm(mSite).RefreshData;




            end;
    end;
end;



{
Vyvoláva sa po vykonaní inicializácie agendy/formulára. V tomto okamihu je už na formulári dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
 muser:TNxCustomBusinessObject;
  mMAction: TMultiAction;
  mCAction: TBasicAction;
  mAList: TActionList;
  i : integer;
  mUserFilter:Boolean;
  mUserFilterTL:string;
begin
    mUserFilter:=true;
    mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');
    try
      mUser.Load(Self.CompanyCache.GetUserID, nil);
            mUserFilter:= mUser.GetFieldValueAsBoolean('X_ChangeStoreCtaegory');

    finally
      mUser.Free;
    end;
        if mUserFilter then begin
          mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Časový záznam';
          mMAction.Caption := 'Vytvoření časového záznamu';
          mMAction.Category := 'tabList';
          mMAction.Items.Add('Reklamace');
          mMAction.Items.Add('Registrace');
          mMAction.Items.Add('Neshoda');
          mMAction.OnExecuteItem := @TimeOnExec;


      end;
end;







 procedure NewActivity(msite: TSiteForm; mStorecard_ID:string;mStoreBatch_ID:string;ActivityArea_ID:string;ActivityType_ID:string;ActQueue_ID:string) ;
var
//  mSiteForm: TBusRollSiteForm;
  mParams, mTemplates: TNxParameters;
  mBO: TNxCustomBusinessObject;
begin
  //mSiteForm := Sender.BusRollSite;
  mParams := TNxParameters.Create;
  try
    mTemplates := mParams.NewFromDataType(dtList, 'TemplateParams').AsList;
    mBO := TBusRollSiteForm(msite).CurrentObject;
    try
      if Assigned(mBO) then begin
        mTemplates.NewFromDataType(dtString, 'Firm_ID').AsString := '7F26300101';
        //mTemplates.NewFromDataType(dtString, 'FirmOffice_ID').AsString := mBO.GetFieldValueAsString('ID');
        //mTemplates.NewFromDataType(dtString, 'Person_ID').AsString := mBO.GetFieldValueAsString('ID');
        mTemplates.NewFromDataType(dtString, 'X_storecard_ID').AsString := mBO.GetFieldValueAsString('ID');

        mTemplates.NewFromDataType(dtString, 'ActivityArea_ID').AsString := ActivityArea_ID;
        mTemplates.NewFromDataType(dtString, 'ActivityType_ID').AsString := ActivityType_ID;
        mTemplates.NewFromDataType(dtString, 'ActQueue_ID').AsString := ActQueue_ID;
        mTemplates.NewFromDataType(dtString, 'X_StoreCard_ID').AsString := mStorecard_ID;
        mTemplates.NewFromDataType(dtString, 'X_StoreBatch_ID').AsString := mStoreBatch_ID;

        mTemplates.NewFromDataType(dtString, 'StoreAssortmentGroup_ID').AsString := mStorecard_ID;
        mTemplates.NewFromDataType(dtString, 'X_StoreBatch_ID').AsString := mStoreBatch_ID;


        mTemplates.NewFromDataType(dtString, 'ActivityProcess_ID').AsString := '2100000101';
        mTemplates.NewFromDataType(dtString, 'Status').AsInteger := 0;

        mTemplates.NewFromDataType(dtDateTime, 'SheduledStart$DATE').AsDateTime := Now;
        mTemplates.NewFromDataType(dtDateTime, 'SheduledEnd$DATE').AsDateTime := Now +1;

        mTemplates.NewFromDataType(dtDateTime, 'RealStart$DATE').AsDateTime := 0.01;
        mTemplates.NewFromDataType(dtDateTime, 'RealEnd$DATE').AsDateTime := 0.1;





        mTemplates.NewFromDataType(dtString, 'Subject').AsString :=  Format('Reklamace %s', [mBO.GetFieldValueAsString('Code') + mBO.GetFieldValueAsString('Name') ]);
       // mTemplates.NewFromDataType(dtString, 'Description').AsString :=  mStr;



      end;
      mTemplates.NewFromDataType(dtString, 'Description').AsString := 'Ukazka ...';
      msite.ShowDynForm('OYC0P3TDDY1ORIJO2SKTP2KZKG', mParams, Nil, False, 'DoNewOnly');
    finally
      mBO.Free;
    end;
  finally
    mParams.Free;
  end;
end;




















Function create_activity(msite: TSiteForm; mStorecard_ID:string;mStoreBatch_ID:string;ActivityArea_ID:string;ActivityType_ID:string;ActQueue_ID:string) : string;
var
  mBO, mA: TNxCustomBusinessObject;
  mStr, mCurrency: String;
  mMon: TNxBusinessMoniker;
begin
    try
    // Dotaz
   // if NxMessageBox('Dotaz', 'Přejete si automaticky vytvořit novou aktivitu?',
   //   mdConfirm, mdbYesNo, 0, 0, False, Nil)=mrYes then begin
      // Vytvorime novou instanci business objektu Aktivita
      mA := msite.BaseObjectSpace.CreateObject('AVV1JYV5AVNOZHQCK0D4CJFUCS');
      try
        // Nastaveni do stavu novy
        mA.New;
        // Predvyplnenni vychozimi hodnotami
        mA.Prefill;
        // Nastaveni polozek aktivity (je to "natvrdo")
        mA.SetFieldValueAsString('ActivityArea_ID', ActivityArea_ID);
        mA.SetFieldValueAsString('ActivityType_ID', ActivityType_ID);
        mA.SetFieldValueAsString('ActQueue_ID', ActQueue_ID);
        mA.SetFieldValueAsString('X_StoreCard_ID', mStorecard_ID);
        mA.SetFieldValueAsString('X_StoreBatch_ID', mStoreBatch_ID);
        mA.SetFieldValueAsString('Subject', Format('Skladová karta %s', ['SSSSS']));
        //mA.SetFieldValueAsString('Firm_ID', '7F26300101');
        // Zjisteni monikeru (odkazu) na menu

          // Nastaveni obsahu polozky Popis
          mA.SetFieldValueAsString('Description', mStr);
          // Ulozeni objektu
          TDynSiteForm(msite).ShowDynFormWithNewDocument('OYC0P3TDDY1ORIJO2SKTP2KZKG', mSite.SiteContext, mA);

         // mA.Save;
      finally
      //  mA.Free;
      end;
//    end;
  finally

  end;
end;

begin
end.