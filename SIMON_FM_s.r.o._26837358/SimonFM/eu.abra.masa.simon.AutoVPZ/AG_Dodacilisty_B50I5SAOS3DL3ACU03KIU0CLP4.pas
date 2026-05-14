const
  cLogStoreDocQueue_ID = '7RE0000101';
  cStoreGateWay_ID = '1000000101';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin

  mAction2 := Self.GetNewAction;
  mAction2.ShowControl := True;
  mAction2.ShowMenuItem := True;
  mAction2.Name := 'act12CreateLog';
  mAction2.Caption := 'Polohování DLES';
  mAction2.Hint := 'Polohuje doklad';
  mAction2.Category := 'tabList';
  mAction2.OnExecute := @CreateLog2;

  mAction2 := Self.GetNewAction;
  mAction2.ShowControl := True;
  mAction2.ShowMenuItem := True;
  mAction2.Name := 'act13CreateLog';
  mAction2.Caption := 'Polohování DLES 2';
  mAction2.Hint := 'Polohuje doklad';
  mAction2.Category := 'tabList';
  mAction2.OnExecute := @CreateLog3;
end;

procedure CreateLog3(Sender: TObject);
var
 mManager: Variant;
 mOLEApp:Variant;
 mBO: TNxCustomBusinessObject;
 mSite : TSiteForm;
begin
 mOLEApp:=GetAbraOLEApplication;
 mSite:=TComponent(Sender).DynSite;
 mBO:=TDynSiteForm(mSite).CurrentObject;
 NxShowSimpleMessage(mbo.DisplayName,mSite);
 mManager := mOLEApp.CreateDocumentImportManager('@BillOfDelivery', '@LogStoreOutput');
 mManager.SetParam('StoreGateWay_ID','1000000101');
 mManager.SetParam('SelectedHeader', mBO.OID);
 mManager.SetParam('DocQueue_ID', '2R00000101');
 mManager.SetParam('AutoPrefillPosition',true);
 mManager.SetParam('PrefillType',0);
 mManager.Execute;
 mManager.ShowWizard;
end;

procedure CreateLog2(Sender: TObject);

var mSite : TSiteForm;
    mList : TStringList;
    mPosRow, mBO : TNxCustomBusinessObject;
    mImportMan:TNxDocumentImportManager;
    mAbraOLE,mObject:Variant;
    mRows, mPosRows: TNxCustomBusinessMonikerCollection;
    i : integer;
    mInputParams : TNxParameters;
    mParam: TNxParameter;
    mOS: TNxCustomObjectSpace;
begin
  try
    mList := TStringList.Create;
    mSite := NxFindSiteForm(TComponent(Sender));
    mOS:=   mSite.BaseObjectSpace;
    if Assigned(mSite) then begin
      TDynSiteForm(mSite).FillListWithSelectedRows(mList);
      if NxMessageBox('Dotaz', 'Přejete si dodací list napolohovat z výchozích pozic?', mdConfirm, mdbYesNo, 0, 0, False, Nil)=mrYes then begin
        try
          for i := 0 to (mList.Count - 1) do begin
            mInputParams := TNxParameters.Create;
            mParam := mInputParams.GetOrCreateParam(dtString, 'StoreGateWay_ID');
            mParam.AsString := cStoreGateWay_ID;
            mParam := mInputParams.GetOrCreateParam(dtString,'DocQueue_ID');
            mParam.AsString := cLogStoreDocQueue_ID;
            mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
            mParam.AsString := mlist.Strings[0];
            mParam := mInputParams.GetOrCreateParam(dtBoolean, 'AutoPrefillPosition');
            mParam.AsBoolean := True;
            mParam := mInputParams.GetOrCreateParam(dtInteger, 'PrefillType');
            mParam.AsInteger := 0;
            mImportMan := NxCreateDocumentImportManager(mOS, Class_BillOfDelivery, Class_LogStoreOutput);
            mImportMan.AddInputDocument(mlist.Strings[0]);
            mImportMan.LoadParams(mInputParams);
            //mImportMan.Execute;
            mImportMan.ExecuteWizard(mSite);
            mImportMan.OutputDocument.Save;
            mImportMan.free;
            OutputDebugString('After save: '+ mImportMan.OutputDocument.OID);
           end;
           TDynSiteForm(mSite).RefreshData;
        except
          ShowMessage('Nepodařilo se napolohovat: '+ExceptionMessage);
        end;
      end;
    end;
  finally
    ShowMessage('Hotovo');
  end;
end;


begin
end.
