uses 'eu.abra.mavy.libs.common', 'eu.abra.mavy.LabelPrinter.API.fce', 'eu.abra.mavy.LabelPrinter.API.consts.consts', 'eu.abra.mavy.LabelPrinter.API.SendToLabelPrinter';

{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  if CheckLicence(Self.SiteContext) then begin
    mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Name := 'actSendLP';
    mAction.Caption := 'Odeslat do LP';
    mAction.Hint := 'Odeslání zásilek do Label Printer';
    mAction.Category := 'tabList';
    mAction.OnExecute := @MassSendPackages;

    mAction2 := Self.GetNewAction;
    mAction2.ShowControl := True;
    mAction2.ShowMenuItem := True;
    mAction2.Name := 'actImport';
    mAction2.Caption := 'LabelPrinter Import';
    mAction2.Hint := 'Import dat zásilek z LabelPrinter';
    mAction2.Category := 'tabList';
    mAction2.OnExecute := @MassUpdateState;
  end;
end;
procedure MassSendPackages(Sender: TObject);
var
  mList, mDocsList: TStrings;
  i: integer;
  mObject, mSourceBO: TNxCustomBusinessObject;
  mLabelPrinter_ID, mStateCode,mMessage,mBarcode,mOID, mState_ID: string;
  mOS: TNxCustomObjectSpace;
  mSite: TDynSiteForm;
  mJSON1: TJSONSuperObject;
  mError: Boolean;
begin
  mSite := TComponent(Sender).DynSite;
  mOS := mSite.SiteContext.GetObjectSpace;
  mList := TStringList.Create;
  mDocsList := TStringList.Create;
  mError:= False;
  try
    mSite.FillListWithSelectedRows(mList);
    for i := 0 to mList.Count - 1 do begin
      mObject := mOS.CreateObject(Class_PDMIssuedDoc);
      try
        mObject.Load(mList.Strings[i], nil);
        mSourceBO:= mOS.CreateObject(mObject.GetFieldValueAsString('X_LP_SourceCLSID'));
        mSourceBO.Load(mObject.GetFieldValueAsString('X_LP_Source_ID'),nil);
        SendPackage(mOS, mObject,mSourceBO, mJSON1, mError,mStateCode,mMessage,mBarcode,mLabelPrinter_ID);
        if not mError then begin
          mState_ID:= SQLSingleSelect(mOS, 'SELECT ID FROM DefRollData WHERE Code = '+ mStateCode + ' and CLSID = ''VB0Q5JB0CRD4V4HES4OTTIYVIK''');
          if not NxIsEmptyOID(mState_ID) then mObject.SetFieldValueAsString('X_LP_State_ID', mState_ID);
          mObject.SetFieldValueAsString('X_LP_Error_message', mMessage);
          mObject.SetFieldValueAsString('X_LP_Barcode', mBarcode);
          mObject.SetFieldValueAsString('X_LP_ExternalID', mLabelPrinter_ID);
          mObject.Save;
          mDocsList.Add(mObject.OID);
        end;
      except
        ShowMessage('CHYBA MassSendPackages: ' +ExceptionMessage);
        mObject.Free;
      end;
    end;
    ShowMessage('Počet odeslaných balíků do Label Printer: ' + IntToStr(mDocsList.Count) + '.');
  finally
    mList.Free;
    mSourceBO.Free;
    mDocsList.Free;
    TDynSiteForm(mSite).RefreshData;
  end;
end;

procedure MassUpdateState(Sender: TObject);
var
  mSite: TSiteForm;
  mOS: TNxCustomObjectSpace;
  mLogInfoStr : string;
  mList: TStringList;
begin
  if Sender is TComponent then begin
    try
      mLogInfoStr:= '';
      mList:= TstringList.Create;
      mSite := TComponent(Sender).Site;
      mOS := mSite.SiteContext.GetObjectSpace;
      mSite.FillListWithSelectedRows(mList);
      Try
        ImportFromLP(mOS,mList,mLogInfoStr);
        if not NxIsBlank(mLogInfoStr) then
          ShowMessage(mLogInfoStr)
        else
          ShowMessage('Hotovo - žádné záznamy nebyly změněny.');
      except
        ShowMessage('Nastala neočekáváná chyba při hromadném zpracování dat z LP: ' + mLogInfoStr + #13#10 + ExceptionMessage);
      end;
    finally
      mList.Free;
    end;
    TDynSiteForm(mSite).RefreshData;
  end;
end;



begin
end.