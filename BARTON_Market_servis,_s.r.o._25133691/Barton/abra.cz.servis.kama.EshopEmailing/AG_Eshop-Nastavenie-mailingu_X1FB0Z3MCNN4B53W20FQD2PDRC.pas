uses 'abra.cz.servis.kama.EshopEmailing.common';

const cTemplate =
  '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">' + #13#10 +
    '<HTML><HEAD><TITLE>email</TITLE>' + #13#10 +
    '<META content="text/html; charset=windows-1250" http-equiv=Content-Type>' + #13#10 +
    '<META name=GENERATOR content="MSHTML 11.00.10570.1001"></HEAD>' + #13#10 +
    '<BODY bgColor=#ffffff>' + #13#10 +
    '<P><FONT color=#000000 face=Arial>' + #13#10 +
    '<!--ACTUAL_DATETIME//--> </br> </br>' + #13#10 +
    'Nová objednávka č. <!--DOC_NUMBER//--></br>' + #13#10 +
    '</FONT></P></BODY></HTML>';


procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction3: TAction;
  mAction2: TMultiAction;
begin
  mAction := self.GetNewAction;
  mAction.Name := 'actInsetTemplate';
  mAction.Caption := 'Vložit template';
  mAction.Hint := 'Vloží do obsahu emailu vzorový html kód';
  mAction.Category := 'tabDetail';
  mAction.OnExecute := @InsertTemplate;
  mAction.OnUpdate := @ActionUpdate;

  mAction2 := self.GetNewMultiAction;
  mAction2.Name := 'actLoadSaveDef';
  mAction2.Caption := 'Uložit do souboru';
  mAction2.Hint := 'Práce s definicemi v souborech';
  mAction2.Category := 'tabList';
  mAction2.Items.Add('Uložit do souboru');
  mAction2.Items.Add('Otevřít ze souboru');
  mAction2.OnExecuteItem := @LoadSaveDef;
  mAction2.OnUpdate := @MultiActionUpdate;

  mAction := self.GetNewAction;
  mAction.Name := 'actShowPreview';
  mAction.Caption := 'Náhled v prohlížeči';
  mAction.Hint := 'Zobrazí náhled v prohlížeči';
  mAction.Category := 'tabList;tabDetail';
  mAction.OnExecute := @ShowPreview;
  mAction.OnUpdate := @ActionUpdate3;
end;


procedure InsertTemplate(Sender: TObject);
var mSite: TBusRollSiteForm;
begin
  if Sender is TComponent then begin
    mSite := TComponent(Sender).BusRollSite;
    if Assigned(mSite) then begin
      mSite.CurrentObject.SetFieldValueAsString('X_EmailBody', cTemplate);
      mSite.DataSet.Resync(0);
      mSite.DataSet.RefreshCurrentItem;
    end;
  end;
end;

procedure ShowPreview(Sender: TObject);
var mSite: TBusRollSiteForm;
  mStr: TStrings;
  mFileName, mID, mCLSID: string;
  mEmailBody, mEmailRows: string;
  mAction, mOldAction: Integer;
  mSendObj: TNxCustomBusinessObject;
begin
  if Sender is TComponent then begin
    mSite := TComponent(Sender).BusRollSite;
    if Assigned(mSite) then begin
      mAction := TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsInteger('X_SystemAction');
      if mAction <> mOldAction then
        GetObject(mAction, mID, mCLSID);
      mStr := TStringList.Create;
      try
        if not NxIsEmptyOID(mID) then begin
          mSendObj := mSite.BaseObjectSpace.CreateObject(mCLSID);
          try
            mSendObj.Load(mID, nil);
            mEmailBody := TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_EmailBody');
            mEmailRows := TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_EmailRows');
            ProcessText(mEmailBody, mEmailRows, mSendObj, 'email@firma.cz', '', TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_ExternalScript'));
            mStr.Text := mEmailBody;
            mFileName := NxAddSlash(NxGetTempDir) + 'test.html';
            mStr.SaveToFile(mFileName);
          finally
            mSendObj.Free;
          end;
          mOldAction := mAction;
          NxOpenBrowser(mFileName, nil);
        end else begin
          mStr.Text := TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_EmailBody');
          mStr.Text := NxSearchReplace(mStr.Text, '<!--ROWS//-->', TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_EmailRows'), [srAll]);
          mFileName := NxAddSlash(NxGetTempDir) + 'test.html';
          mStr.SaveToFile(mFileName);
          NxOpenBrowser(mFileName, nil);
        end;
      finally
        mStr.Free;
      end;
    end;
  end;
end;

procedure GetObject(AAction: integer; var AID: string; var ACLSID: string);
begin
  case AAction of
    0: begin
        ACLSID := Class_Person; AID := GetIDFromVisualRoll(Roll_Persons) end;
    1: begin
        ACLSID := Class_ReceivedOrder; AID := GetIDFromVisualAgenda(Site_ReceivedOrders) end;
    2: begin
        ACLSID := Class_ReceivedOrder; AID := GetIDFromVisualAgenda(Site_ReceivedOrders) end;
    3: begin
        ACLSID := Class_ReceivedOrder; AID := GetIDFromVisualAgenda(Site_ReceivedOrders) end;
    4: begin
        ACLSID := Class_ReceivedOrder; AID := GetIDFromVisualAgenda(Site_ReceivedOrders) end;
    5: begin
        ACLSID := Class_IssuedDepositInvoice; AID := GetIDFromVisualAgenda(Site_IssuedDepositInvoices) end;
    6: begin
        ACLSID := Class_ReceivedOrder; AID := GetIDFromVisualAgenda(Site_ReceivedOrders) end;
    7: begin
        ACLSID := Class_OtherIncome; AID := GetIDFromVisualAgenda(Site_OtherIncomes) end;
    8: begin
        ACLSID := Class_IssuedInvoice; AID := GetIDFromVisualAgenda(Site_IssuedInvoices) end;
    9: begin
        ACLSID := Class_CashReceived; AID := GetIDFromVisualAgenda(Site_CashReceived) end;
    10: begin
        ACLSID := Class_BillOfDelivery; AID := GetIDFromVisualAgenda(Site_BillOfDeliveries) end;
    11: begin
        ACLSID := Class_IssuedOffer; AID := GetIDFromVisualAgenda(Site_IssuedOffers) end;
    12: begin
        ACLSID := Class_IssuedOffer; AID := GetIDFromVisualAgenda(Site_IssuedOffers) end;
    13: begin
        ACLSID := Class_CRMActivity; AID := GetIDFromVisualAgenda(Site_CRMActivities) end;
    14: begin
        ACLSID := Class_ReceivedOrder; AID := GetIDFromVisualAgenda(Site_ReceivedOrders) end;
    15: begin
        ACLSID := Class_IssuedOrder; AID := GetIDFromVisualAgenda(Site_IssuedOrders) end;
    16: begin
        ACLSID := Class_VATIssuedDepositInvoice; AID := GetIDFromVisualAgenda(Site_VATIssuedDepositInvoice) end;
    17: begin
        ACLSID := Class_IssuedCreditNote; AID := GetIDFromVisualAgenda(Site_IssuedCreditNotes) end;
    18: begin
        ACLSID := Class_PDMIssuedDoc; AID := GetIDFromVisualAgenda(Site_PDMIssuedDocs) end;
    19: begin
        ACLSID := Class_PDMIssuedDoc; AID := GetIDFromVisualAgenda(Site_PDMIssuedDocs) end;
    20: begin
        ACLSID := Class_IssuedDepositInvoice; AID := GetIDFromVisualAgenda(Site_IssuedDepositInvoices) end;
    21: begin
        ACLSID := Class_BillOfDelivery; AID := GetIDFromVisualAgenda(Site_BillOfDeliveries) end;
  end;
end;

function GetIDFromVisualRoll(RollCLSID: string): string;
var
  mRoll, mOLE: Variant;
begin
  result := '';
  mOLE := GetAbraOLEApplication;
  try
    mRoll := mOLE.GetRoll(RollCLSID, 1);
    result := mRoll.SelectDialog2(True, result);
  finally
    mOLE := nil;
    mRoll := nil;
  end;
end;

//vracÝ ID z vizuelnÝ agendy

function GetIDFromVisualAgenda(AgendaCLSID: string): string;
var
  mAgenda, mOLE: Variant;
  mID: string;
  mB: Boolean;
begin
  mID := '';
  mOLE := GetAbraOLEApplication;
  try
    mAgenda := mOLE.GetAgenda(AgendaCLSID);
    mID := mAgenda.SingleSelect2('', mID);
    Result := mID;
  finally
    mOLE := nil;
    mAgenda := nil;
  end;
end;

procedure LoadSaveDef(Sender: TObject; Index: Integer);
begin
  if Index = 0 then
    SaveToFile(Sender);
  if Index = 1 then
    LoadFromFile(Sender);
end;

procedure LoadFromFile(Sender: TObject);
var mSite: TBusRollSiteForm;
  mBO: TNxCustomBusinessObject;
  mFile: TStrings;
  mOpenDlg: TOpenDialog;
begin
  mSite := TComponent(Sender).BusRollSite;
  mFile := TstringList.Create;
  mOpenDlg := TOpenDialog.Create(mSite);
  try
    mFile.Clear;
    mOpenDlg.Filter := 'Emailing settings|*.ems';
    mOpenDlg.DefaultExt := 'ems';
    if mOpenDlg.Execute then begin
      mFile.LoadFromFile(mOpenDlg.FileName);
      RemoveDeprecated(mFile);
      NxSetCustomBusinessObjectFromBOText([mFile.Text], mSite.BaseObjectSpace);
      mSite.RefreshData;
    end;
  finally
    mFile.Free;
    mOpenDlg.free;
  end;
end;

procedure SaveToFile(Sender: TObject);
var mSite: TBusRollSiteForm;
  mBO: TNxCustomBusinessObject;
  mText: string;
  mFile: TStrings;
  mSaveDlg: TSaveDialog;
  mInd: Integer;
begin
  mSite := TComponent(Sender).BusRollSite;
  mBO := mSite.CurrentObject;
  if Assigned(mBO) then begin
    mFile := TStringList.Create;
    mSaveDlg := TSaveDialog.Create(mSite);
    try
      mSaveDlg.Options := [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing];
      mSaveDlg.FileName := mBO.GetFieldValueAsString('Name');
      mSaveDlg.Filter := 'Emailing settings|*.ems';
      mSaveDlg.DefaultExt := 'ems';

      if mSaveDlg.Execute then begin
        mFile.Text := NxGetCustomBusinessObjectAsBOText(mBO);
        mInd := mFile.IndexOfName('ID');
        mFile.ValueFromIndex[mInd] := 'XXXXXXXXXX';
        RemoveDeprecated(mFile);
        mFile.SaveToFile(mSaveDlg.FileName);
      end;
    finally
      mFile.free;
      mSaveDlg.free;
    end;
  end;
end;

procedure RemoveDeprecated(var AFile: TStrings);
var mRes: TStrings;
  i, j, k, l: Integer;
begin
  mRes := TStringList.Create;
  try
    mRes.Add(AFile.Strings(AFile.IndexOfName('ID')));
    mRes.Add(AFile.Strings(AFile.IndexOfName('ClassID')));
    mRes.Add(AFile.Strings(AFile.IndexOfName('Code')));
    mRes.Add(AFile.Strings(AFile.IndexOfName('Name')));
    mRes.Add(AFile.Strings(AFile.IndexOfName('CLSID')));
    mRes.Add(AFile.Strings(AFile.IndexOfName('X_OwnVariableField')));
    mRes.Add(AFile.Strings(AFile.IndexOfName('X_AttachementFormat')));
    mRes.Add(AFile.Strings(AFile.IndexOfName('X_OfferState_ID')));
    mRes.Add(AFile.Strings(AFile.IndexOfName('X_SystemAction')));
    mRes.Add(AFile.Strings(AFile.IndexOfName('X_EmailAddressCopy')));
    mRes.Add(AFile.Strings(AFile.IndexOfName('X_EmailSubject')));
    mRes.Add(AFile.Strings(AFile.IndexOfName('X_UsedDocQueue_ID')));
    mRes.Add(AFile.Strings(AFile.IndexOfName('X_OwnEmailAccount_ID')));
    mRes.Add(AFile.Strings(AFile.IndexOfName('X_UsedCountry_ID')));
    mRes.Add(AFile.Strings(AFile.IndexOfName('X_ActivityProcess_ID')));
    mRes.Add(AFile.Strings(AFile.IndexOfName('X_UsedActQueue_ID')));
    mRes.Add(AFile.Strings(AFile.IndexOfName('X_EmailFormat')));
    mRes.Add(AFile.Strings(AFile.IndexOfName('X_EmailSendTime')));
    mRes.Add(AFile.Strings(AFile.IndexOfName('X_HiddenEmailAddressCopy')));
    mRes.Add(AFile.Strings(AFile.IndexOfName('X_AttachReport_ID')));
    mRes.Add(AFile.Strings(AFile.IndexOfName('X_EshopID')));
    mRes.Add(AFile.Strings(AFile.IndexOfName('X_UserFieldName')));
    mRes.Add(AFile.Strings(AFile.IndexOfName('X_SendCopyBusOrderEmail')));
    mRes.Add(AFile.Strings(AFile.IndexOfName('X_SendCopyBusTransactionEmail')));
    mRes.Add(AFile.Strings(AFile.IndexOfName('X_SendCopyBusProjectEmail')));
    mRes.Add(AFile.Strings(AFile.IndexOfName('X_SendCopyStoreEmail')));
    mRes.Add(AFile.Strings(AFile.IndexOfName('X_EmailBody')));
    mRes.Add(AFile.Strings(AFile.IndexOfName('X_ExternalScript')));
    j := AFile.IndexOfName('X_EmailBody') + 1;
    while AFile.Names[j] = '' do begin
      mRes.Add(AFile.Strings[j]);
      inc(j);
    end;
    mRes.Add(AFile.Strings(AFile.IndexOfName('X_EmailRows')));
    l := AFile.IndexOfName('X_EmailRows') + 1;
    while AFile.Names[l] = '' do begin
      mRes.Add(AFile.Strings[l]);
      inc(l);
    end;
    mRes.Add(AFile.Strings(AFile.IndexOfName('X_AttachFiles')));
    k := AFile.IndexOfName('X_AttachFiles') + 1;
    while AFile.Names[k] = '' do begin
      mRes.Add(AFile.Strings[k]);
      inc(k);
    end;
    mRes.Add(AFile.Strings(AFile.IndexOfName('X_SendSMS')));
    mRes.Add(AFile.Strings(AFile.IndexOfName('X_SMSMessage')));
    i := AFile.IndexOfName('X_SMSMessage') + 1;
    while AFile.Names[i] = '' do begin
      mRes.Add(AFile.Strings[i]);
      inc(i);
    end;
    mRes.Add(AFile.Strings(AFile.IndexOfName('X_SMSPassword')));
    mRes.Add(AFile.Strings(AFile.IndexOfName('X_SMSUserName')));

    AFile.Clear;
    AFile.AddStrings(mRes);
  finally
    mRes.free;
  end;
end;

procedure MultiActionUpdate(Sender: TObject);
var
  mSite: TBusRollSiteForm;
begin
  if Sender is TComponent then begin
    mSite := TComponent(Sender).BusRollSite;
    if Assigned(mSite) then begin
      TMultiAction(Sender).Enabled := not mSite.Edit;
    end;
  end;
end;

procedure ActionUpdate(Sender: TObject);
var
  mSite: TBusRollSiteForm;
begin
  if Sender is TComponent then begin
    mSite := TComponent(Sender).BusRollSite;
    if Assigned(mSite) then begin
      TAction(Sender).Enabled := mSite.Edit
        and Assigned(mSite.CurrentObject);
    end;
  end;
end;

procedure ActionUpdate3(Sender: TObject);
var
  mSite: TBusRollSiteForm;
begin
  if Sender is TComponent then begin
    mSite := TComponent(Sender).BusRollSite;
    if Assigned(mSite) then begin
      Assigned(mSite.CurrentObject);
    end;
  end;
end;

begin
end.
