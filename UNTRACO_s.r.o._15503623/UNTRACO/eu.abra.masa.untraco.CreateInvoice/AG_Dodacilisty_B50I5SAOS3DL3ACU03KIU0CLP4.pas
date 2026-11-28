procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := '## Vyfakturuj ##';
  mAction.Hint := 'Vytvoří nové faktury z dodacího listu';
  mAction.Category := 'tabList';
  mAction.OnExecute := @CreateInvoice;
end;

Procedure CreateInvoice(Sender:TComponent);
var
  mSite:TSiteForm;
  mInvoiceList, mRowList, mFilteredRows, mVariants:TStringList;
  mBO:TNxCustomBusinessObject;
  mInvoiceDocQueue_ID, mReceivedOrder_ID, mFirmOffice_ID:String;
  mOS:TNxCustomObjectSpace;
  mImportManager: TNxDocumentImportManager;
  mInputParams: TNxParameters;
  mParam: TNxParameter;
  i, v: Integer;
  mCurrentVariant: string;
begin
  mSite:=TComponent(Sender).DynSite;
  mBO:=TDynSiteForm(mSite).CurrentObject;
  if Assigned(mBO) then begin
    if mBO.GetFieldValueAsBoolean('IsAvailableForDelivery') and mbo.GetFieldValueAsBoolean('Firm_ID.U_SUKL_II') then begin
      if NxMessageBox('Potvrzení', 'Přejete si vyfakturovat '+mBO.DisplayName+'?', mdConfirm, mdbYesNo, 1, nil, False, mSite) = mrYes then begin
        mInvoiceDocQueue_ID:='4000000101';
        if GetDocQueue_ID(mSite, mInvoiceDocQueue_ID) then begin
          if NxIsEmptyOID(mInvoiceDocQueue_ID) then begin
            NxShowSimpleMessage('Nebyla vybrána řada dokladů.', msite);
            exit;
          end else begin
            mInvoiceList:=TStringList.Create;
            mRowList:=TStringList.Create;
            mRowList.NameValueSeparator := '=';
            mOS:=mBO.ObjectSpace;

            // SENIOR NOTE: Spojili jsme ID a Variantu přes || '=' ||, čímž TStringList získá strukturu Name=Value
            mOS.SQLSelect('SELECT CAST(TRIM(sd2.id || ''='' || '#13#10 +
                          '  (CASE '#13#10 +
                          '    WHEN b.X_NoCompensation = ''A'' AND (ud.STRINGFIELDVALUE = '''' OR ud.STRINGFIELDVALUE IS NULL) THEN ''A_EMPTY'''#13#10 +
                          '    WHEN b.X_NoCompensation = ''A'' AND ud.STRINGFIELDVALUE <> '''' THEN ''A_NOTEMPTY'''#13#10 +
                          '    '#13#10 +
                          '    WHEN b.X_NoCompensation = ''N'' AND (ud.STRINGFIELDVALUE = '''' OR ud.STRINGFIELDVALUE IS NULL) THEN ''N_EMPTY'''#13#10 +
                          '    WHEN b.X_NoCompensation = ''N'' AND ud.STRINGFIELDVALUE <> '''' THEN ''N_NOTEMPTY'''#13#10 +
                          '    '#13#10 +
                          '    ELSE ''UNKNOWN'''#13#10 +
                          '   END)) AS VARCHAR(50)) as Varianta '#13#10 +
                          'FROM StoreDocuments2 sd2'#13#10 +
                          'JOIN StoreCards b ON sd2.StoreCard_ID = b.ID'#13#10 +
                          'LEFT JOIN USERDATA ud ON ud.ID = b.ID '#13#10 +
                          '  AND ud.FIELDCODE = 2000212 '#13#10 +
                          '  AND ud.CLSID = ''C3V5QDVZ5BDL342M01C0CX3FCC'''#13#10 +
                          'WHERE sd2.Parent_ID = '+QuotedStr(mBO.OID)+' AND b.Hidden = ''N'' and sd2.Quantity>sd2.DeliveredQuantity', mRowList);

            mReceivedOrder_ID:=mOS.SQLSelectFirstAsString('Select distinct(provide_id) from StoreDocuments2 where parent_id='+QuotedStr(mBO.OID),'');

            if mRowList.Count > 0 then begin
              // Definice variant, které budeme postupně zpracovávat
              mVariants := TStringList.Create;
              mVariants.Add('A_EMPTY');
              mVariants.Add('A_NOTEMPTY');
              mVariants.Add('N_EMPTY');
              mVariants.Add('N_NOTEMPTY');

              mFilteredRows := TStringList.Create;
              try
                // Zjištění FirmOffice_ID před cyklem, ať se neptáme DB pokaždé
                if not(NxIsEmptyOID(mReceivedOrder_ID)) then
                  mFirmOffice_ID:=mOS.SQLSelectFirstAsString('Select FirmOffice_ID from receivedorders where id='+QuotedStr(mReceivedOrder_ID),'')
                else
                  mFirmOffice_ID:=mOS.SQLSelectFirstAsString('Select FirmOffice_ID from StoreDocuments where id='+QuotedStr(mBO.OID),'');

                // Hlavní cyklus přes jednotlivé varianty
                for v := 0 to mVariants.Count - 1 do begin
                  mCurrentVariant := mVariants[v];
                  mFilteredRows.Clear;

                  // Vyzobeme z mRowList pouze ID patřící do aktuální varianty
                  for i := 0 to mRowList.Count - 1 do begin
                    if mRowList.Values[mRowList.Names[i]] = mCurrentVariant then
                      mFilteredRows.Add(mRowList.Names[i]);
                  end;

                  // Pokud pro tuto variantu existují řádky, spustíme import samostatné faktury
                  if mFilteredRows.Count > 0 then begin
                    mInputParams := TNxParameters.Create;
                    try
                      mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                      mParam.AsString := mInvoiceDocQueue_ID;

                      mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
                      if not(NxIsEmptyOID(mReceivedOrder_ID)) then
                        mParam.AsString := mReceivedOrder_ID
                      else
                        mParam.AsString := mBO.OID;

                      mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows');
                      mParam.AsString := mFilteredRows.Text; // Pouze profiltrované řádky

                      mImportManager := NxCreateDocumentImportManager(mOS, Class_BillOfDelivery, Class_IssuedInvoice);
                      try
                        mImportManager.AddInputDocument(mBO.OID);
                        mImportManager.LoadParams(mInputParams);
                        mImportManager.Execute;
                        mImportManager.CheckOutputDocument;
                        mImportManager.OutputDocument.SetFieldValueAsString('DocQueue_ID', mInvoiceDocQueue_ID);
                        mImportManager.OutputDocument.SetFieldValueAsString('Description', mBO.DisplayName);
                        {if mCurrentVariant='A_NOTEMPTY' then
                         mImportManager.OutputDocument.SetFieldValueAsString('Description', mBO.DisplayName+', NIC');
                        if mCurrentVariant='N_NOTEMPTY' then
                         mImportManager.OutputDocument.SetFieldValueAsString('Description', mBO.DisplayName+', M, MP');
                        if mCurrentVariant='N_EMPTY' then
                         mImportManager.OutputDocument.SetFieldValueAsString('Description', mBO.DisplayName+', N, NP');}
                        if not(NxIsEmptyOID(mFirmOffice_ID)) then
                          mImportManager.OutputDocument.SetFieldValueAsString('FirmOffice_ID', mFirmOffice_ID);

                        mImportManager.OutputDocument.Save;
                        mInvoiceList.Add(QuotedStr(mImportManager.OutputDocument.OID));
                      finally
                        mImportManager.Free;
                      end;
                    finally
                      mInputParams.Free; // Vyčištění parametrů v každém cyklu
                    end;
                  end;
                end;
              finally
                mVariants.Free;
                mFilteredRows.Free;
              end;
            end;

            // Úklid seznamů z SQL
            mRowList.Free;
            if mInvoiceList.Count > 0 then
              TDynSiteForm(mSite).ShowSite(Site_IssuedInvoices,true,'QueryByUserDynSQLCondition;A.ID in ('+mInvoiceList.DelimitedText+')');
            mInvoiceList.Free;
          end;
        end;
      end;
    end else begin
      NxShowSimpleMessage('Dodací list '+mBO.DisplayName+' není čerpatelný, nebo firma nemá rozpad faktury', mSite);
    end;
  end;
end;

Function GetDocQueue_ID(var ASite : TSiteform; var aDocQueue_ID:String):Boolean;
var
    mLabel, mCBCCDocQueue: TLabel;
    mAllowed:TStringList;
    mButOk, mButCancel : TButton;
    mResult, mCount : integer;
    mForm : TForm;
    mCBDocQueue:TRollComboEdit;
    mED:TEdit;
 begin
 if ASite <> nil then begin
    mAllowed:=TStringList.Create;
    ASite.BaseObjectSpace.SQLSelect('Select id from DocQueues where DocumentType='+QuotedStr('03')+' and hidden=''N'' ',mAllowed);
    Result:=False;
    mCount:=0;
    mForm:= TForm.Create(ASite);
    mForm.Width:= 510;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Info:';
    mForm.OnCloseQuery:= @OnFormCloseAction;


    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Řada dokladu:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mCBCCDocQueue:= TLabel.Create(mForm);
    mCBCCDocQueue.Parent:= mForm;
    mCBCCDocQueue.Left:= 236;
    mCBCCDocQueue.Top:= (mCount*25)+12;
    mCBCCDocQueue.Width:= 255;

    mCBDocQueue:= TRollComboEdit.Create(mForm);
    mCBDocQueue.Parent:= mForm;
    mCBDocQueue.ClassID:= Roll_DocQueues;
    mCBDocQueue.Complete:= True;
    mCBDocQueue.Prefilling:= pmNone;
    mCBDocQueue.TextField:= 'Code';  // položka podle které se bude vyhledávat
    mCBDocQueue.Top:= (mCount*25)+10;
    mCBDocQueue.Left:= 140;
    mCBDocQueue.Width:= 80;
    mCBDocQueue.Parameters.Clear;
    mCBDocQueue.Parameters.Add('_Allowed='+mAllowed.DelimitedText);
    mCBDocQueue.ConnectedControl:= mCBCCDocQueue;
    mCBDocQueue.ConnectedControlField:= 'Name';
    mCBDocQueue.DataText:=aDocQueue_ID;
    if not NxIsEmptyOID(aDocQueue_ID) then mCBDocQueue.Refresh;


    mCount:= mCount+1;

    mButOk:= TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Default:= true;
    mButOk.Caption := 'OK';
    mButOk.Top := (mCount*25)+20;
    mButOk.Left := 252;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.ModalResult := 1;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Zrušit';
    mButCancel.Top := (mCount*25)+20;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;
    mForm.Height:= (mCount*25)+95;

    mResult := mForm.ShowModal(ASite);
    if mResult = 1 then begin
         aDocQueue_ID:=mCBDocQueue.DataText;
         Result:=True;
     end;
    mAllowed.free;
    mForm.free;
  end;
end;

procedure OnFormCloseAction(Sender: TObject; var Action: TCloseAction);
begin
  if Action = caHide then TForm(Sender).ModalResult := mrCancel;
end;

begin
end.