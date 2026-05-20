procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
  mAction2: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := False;
  mAction.Caption := 'Da&lší';
  mAction.Hint := 'Další nový záznam s předvyplněním hodnot.';
  mAction.Category := 'tabDetail';
  mAction.OnExecuteItem := @NextNew;
  mAction.OnUpdate := @NextNewEnable;

  mAction2 := Self.GetNewMultiAction;
  mAction2.ShowControl := True;
  mAction2.ShowMenuItem := False;
  mAction2.Caption := 'Nový hromadně';
  mAction2.Items.Add('Vybrat jednu skl.kartu a k ní připojit více skl.karet jako příslušenství');
  mAction2.Items.Add('Vybrat jednu skl.kartu přislušenství a tu připojit více skladovým kartám.');
  mAction2.Hint := 'Hromadné zadání příslušenství.';
  mAction2.Category := 'tabList';
  mAction2.OnExecuteItem := @NewMulti;
end;

procedure NextNew(Sender: TObject);
var
  mForm: TForm;
  mBtnClone: TButton;
  mBtnSave: TButton;
  mDataSet: TNxPackageDataSet;
  mSite: TSiteForm;
begin
  mSite := TComponent(Sender).Site;
  mForm := mSite.FindParentForm;
  mBtnSave := TButton(mForm.FindChildControl('CactSave'));
  mBtnClone := TButton(mForm.FindChildControl('CactClone'));
  if Assigned(mBtnClone) and Assigned(mBtnSave) then begin
    mBtnSave.Click;
    mBtnClone.Click;
  end else begin
    ShowMessage('Nenalezeno CactSave nebo CactClone.');
  end;
end;


procedure NextNewEnable(Sender: TObject);
var
  mBtnNew: TComboButton;
  mForm: TForm;
  mSite: TSiteForm;
begin
  if Sender is TComponent then begin
    mSite := TComponent(Sender).Site;
    mForm := mSite.FindParentForm;
    mBtnNew := TComboButton(mform.FindChildControl('CactNew'));
    if Assigned(mBtnNew) then begin
      if mBtnNew.Enabled = False then begin
        TMultiAction(Sender).Enabled := True;
      end else begin
        TMultiAction(Sender).Enabled := False;
      end;
    end;
  end;
end;


procedure NewMulti(Sender: TObject; AIndex: integer);
var
  I: Integer;
  mBo, mBoLoad: TNxCustomBusinessObject;
  mGx: Variant;
  mList: Variant;
  mMainSC_ID: String;
  mRoll: Variant;
  mSiteForm: TBusRollSiteForm;
  mStringList: TStringList;
begin
  if AIndex = 0 then begin
    try
      mSiteForm := TComponent(Sender).BusRollSite;
      if Assigned(mSiteForm) then begin
        mGx := GetAbraOLEApplication;
        mMainSC_ID := '0000000000';
        mRoll := mGx.GetRoll('S3WZQKDB5FDL342M01C0CX3FCC', 3);
        mMainSC_ID := mRoll.SelectDialog2(True, mMainSC_ID);
        if (mMainSC_ID <> '0000000000') and (mMainSC_ID <> '') then begin
          mStringList := TStringList.Create;
          mSiteForm.BaseObjectSpace.SQLSelect('SELECT A.X_StoreCard2_ID' +
                                               ' FROM DefRollData A' +
                                               ' WHERE A.CLSID = ' + QuotedStr('2MV1EAYNMBW4RAH1W01CWIIWC0') +
                                                 ' AND A.X_StoreCard_ID = ' + QuotedStr(mMainSC_ID), mStringList);
          mRoll.Params.Add('_Excluded='+mMainSC_ID+';'+mStringList.CommaText);
          mList := GetAbraOLEStrings;
          if mRoll.MultiSelectDialog(True, mList) then begin
            mBoLoad := mSiteForm.BaseObjectSpace.CreateObject('C3V5QDVZ5BDL342M01C0CX3FCC');
            mBoLoad.Load(mMainSC_ID, nil);
            if NxMessageBox('Dotaz', 'Opravdu si přejete připojit ke skl.kartě "' + mBoLoad.GetFieldValueAsString('DisplayName') + '" ' + IntToStr(mList.Count) + ' skl.karet jako příslušenství ?' , mdConfirm, mdbYesNo, 1, [mdpSystemModal], False, nil) = 6 then begin
              if mList.Count > 0 then begin
                for I := 0 to (mList.Count - 1) do begin
                  mBo := mSiteForm.BaseObjectSpace.CreateObject('2MV1EAYNMBW4RAH1W01CWIIWC0');
                  mBo.New;
                  mBo.SetFieldValueAsString('X_StoreCard_ID', mMainSC_ID);
                  mBo.SetFieldValueAsString('X_StoreCard2_ID', mList.Strings[I]);
                  mBo.Save;
                end;
                mSiteForm.RefreshData;
              end;
            end;
          end;
        end;
      end;
    finally
      I := nil;
      mBo := nil;
      mBoLoad := nil;
      mGx := nil;
      mList := nil;
      mMainSC_ID := nil;
      mRoll := nil;
      mSiteForm := nil;
      mStringList := nil;
    end;
  end;
  
  if AIndex = 1 then begin
    try
      mSiteForm := TComponent(Sender).BusRollSite;
      if Assigned(mSiteForm) then begin
        mGx := GetAbraOLEApplication;
        mMainSC_ID := '0000000000';
        mRoll := mGx.GetRoll('S3WZQKDB5FDL342M01C0CX3FCC', 3);
        mMainSC_ID := mRoll.SelectDialog2(True, mMainSC_ID);
        if (mMainSC_ID <> '0000000000') and (mMainSC_ID <> '') then begin
          mStringList := TStringList.Create;
          mSiteForm.BaseObjectSpace.SQLSelect('SELECT A.X_StoreCard_ID' +
                                               ' FROM DefRollData A' +
                                               ' WHERE A.CLSID = ' + QuotedStr('2MV1EAYNMBW4RAH1W01CWIIWC0') +
                                                 ' AND A.X_StoreCard2_ID = ' + QuotedStr(mMainSC_ID), mStringList);
          mRoll.Params.Add('_Excluded='+mMainSC_ID+';'+mStringList.CommaText);
          mList := GetAbraOLEStrings;
          if mRoll.MultiSelectDialog(True, mList) then begin
            mBoLoad := mSiteForm.BaseObjectSpace.CreateObject('C3V5QDVZ5BDL342M01C0CX3FCC');
            mBoLoad.Load(mMainSC_ID, nil);
            if NxMessageBox('Dotaz', 'Opravdu si přejete připojit skl.kartu "' + mBoLoad.GetFieldValueAsString('DisplayName') + '" jako příslušenství k ' + IntToStr(mList.Count) + ' skl.kartám ?' , mdConfirm, mdbYesNo, 1, [mdpSystemModal], False, nil) = 6 then begin
              if mList.Count > 0 then begin
                for I := 0 to (mList.Count - 1) do begin
                  mBo := mSiteForm.BaseObjectSpace.CreateObject('2MV1EAYNMBW4RAH1W01CWIIWC0');
                  mBo.New;
                  mBo.SetFieldValueAsString('X_StoreCard2_ID', mMainSC_ID);
                  mBo.SetFieldValueAsString('X_StoreCard_ID', mList.Strings[I]);
                  mBo.Save;
                end;
                mSiteForm.RefreshData;
              end;
            end;
          end;
        end;
      end;
    finally
      I := nil;
      mBo := nil;
      mBoLoad := nil;
      mGx := nil;
      mList := nil;
      mMainSC_ID := nil;
      mRoll := nil;
      mSiteForm := nil;
      mStringList := nil;
    end;
  end;
  
  if AIndex = 2 then begin
    NxMessageBox('Nápověda k hromadnámu zadání',
      '1. V prvním nabídnutém seznamu skladových karet zvolíte jednu skl.kartu. V kontextu vybrané funkce se jedná o skl.kartu, ke které připojujete příslušenství nebo která je příslušenstvím. ' +CHR(13)+
      '2. V druhém nabídnutém seznamu skladových karet označíte karty, ke kterým má být připojena karta, vybraná v přecházejícím kroku.' +CHR(13)+
      '3. Pokud v potvrzovacím dialogu zovlíte ano, dojde k zápisu vybraných vazeb do číselníku přislušenství.', mdInformation, mdbOk, 1, [mdpSystemModal], False, nil);
  end;
  
end;


begin
end.