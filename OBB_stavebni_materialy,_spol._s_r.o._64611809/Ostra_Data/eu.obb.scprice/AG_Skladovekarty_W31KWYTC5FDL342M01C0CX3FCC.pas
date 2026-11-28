procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  if NxGetActualUserID(self.BaseObjectSpace)='7000000101' then begin
    mAction := Self.GetNewMultiAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := 'Import cen';
    mAction.Items.Add('Import cen');
    mAction.Items.Add('Import cen - Bramac');
    mAction.Hint := 'Provede import z csv';
    mAction.Category := 'tabList';
    mAction.OnExecuteItem := @ImportData;
  end;
end;

// Obsluha tlačítka pro otevření výběru souboru (hledá TEdit podle typu)
procedure BrowseClick(Sender: TObject);
var
  mDlg: TOpenDialog;
  mForm: TForm;
  mEdit: TEdit;
  i: integer;
begin
  mForm := TForm(TButton(Sender).Owner);
  mEdit := nil;

  for i := 0 to mForm.ComponentCount - 1 do begin
    if mForm.Components[i] is TEdit then begin
      mEdit := TEdit(mForm.Components[i]);
      break;
    end;
  end;

  mDlg := TOpenDialog.Create(mForm);
  try
    mDlg.Filter := 'Soubory CSV (*.csv)|*.csv';
    if mDlg.Execute then
      if mEdit <> nil then
        mEdit.Text := mDlg.FileName;
  finally
    mDlg.Free;
  end;
end;

// Validace a potvrzení formuláře při kliknutí na OK (hledá podle typu)
procedure OkClick(Sender: TObject);
var
  mForm: TForm;
  mCB: TRollComboEdit;
  mEdit: TEdit;
  i: integer;
begin
  mForm := TForm(TButton(Sender).Owner);
  mCB := nil;
  mEdit := nil;

  for i := 0 to mForm.ComponentCount - 1 do begin
    if mForm.Components[i] is TRollComboEdit then
      mCB := TRollComboEdit(mForm.Components[i])
    else if mForm.Components[i] is TEdit then
      mEdit := TEdit(mForm.Components[i]);
  end;

  // Kontrola výrobce
  if (mCB = nil) or (NxIsEmptyOID(mCB.DataText)) then begin
    MessageDlg('Vyberte prosím výrobce.', mtWarning, [mbOK], 0);
    Exit;
  end;

  // Kontrola CSV souboru
  if (mEdit = nil) or (Trim(mEdit.Text) = '') then begin
    MessageDlg('Vyberte prosím soubor CSV.', mtWarning, [mbOK], 0);
    Exit;
  end;

  // Pokud je vše vyplněno, povolíme zavření formuláře s výsledkem OK
  mForm.ModalResult := 1;
end;

procedure ImportData(sender: Tcomponent; index: integer);
var
  mSite: TSiteForm;
  mOS: TNxCustomObjectSpace;
  mList, mProducerList, mNotFoundList, mImportedList, mNotImportedList: TStringList;
  aProducer_ID, aFileName: String;
  i, j, k, m:integer;
  mCode, mQUnit_ID, mUnit, mStoreCard_ID, mTempStr, mStorePrice_ID, mPriceList_ID, mPrice_ID,mPricelistName, mString:string;
  mPrice, mUnitRate:extended;
  mPriceBO, mPriceRowBO, mStoreCardBO:TNxCustomBusinessObject;
  mPriceRows:TNxCustomBusinessMonikerCollection;
  mSaveDlg:TFileSaveDialog;
  mopenDLG:TOpenDialog;
begin
  mSite := TComponent(sender).BusRollSite;
  mOS := mSite.BaseObjectSpace;
  if index = 0 then begin
    aProducer_ID := '';
    aFileName := '';
    mPriceList_ID:='1000000101';
    mPrice_ID := '1100000101';
    mPricelistName:='';
    if GetImportParameters(mSite, aProducer_ID, aFileName) then begin
      try
        mPricelistName:=mOS.SQLSelectFirstAsString('Select name from defrolldata where id='+QuotedStr(aProducer_ID),'');
        mList := TStringList.Create;
        mImportedList :=TStringList.create;
        mNotFoundList := TStringList.create;
        mList.LoadFromFile(aFileName);
        k:=mList.Count;
        mProducerList:=TStringList.Create;
        mOS.SQLSelect('Select id from storecards where hidden=''N'' and X_PricelistNameOBB='+QuotedStr(aProducer_ID), mProducerList);
        WaitWin.StartProgress('Nuluji hodnoty, čekejte, prosím ...', '', mProducerList.Count);
        mStoreCardBO:=mOS.CreateObject(Class_StoreCard);
        for i:=1 to mProducerList.count-1 do begin
           mStoreCardBO.Load(mProducerList.Strings[i],nil);
           mStoreCardBO.SetFieldValueAsInteger('U_PriceImportResult',0);
           mStoreCardBO.save;
           WaitWin.ChangeText(IntToStr(1+i) + ' / ' + IntToStr(mProducerList.Count));
           WaitWin.StepIt;
        end;
        WaitWin.Stop;
        mStoreCardBO.Free;
        WaitWin.StartProgress('Čekejte, prosím ...', '', k);
        mStoreCardBO:=mOS.CreateObject(Class_StoreCard);
        for i:=1 to mList.count-1 do begin
           mTempStr:=mList.Strings[i];
           mCode:=NxTrapStrTrim(mTempStr,';');
           mPrice:=NxIBStrToFloat(NxTrapStrTrim(mTempStr,';'));
           mUnit:=NxTrapStrTrim(mTempStr,';');
           mStoreCard_ID:=mOS.SQLSelectFirstAsString('Select sc.id from storecards sc join suppliers sp on sp.storecard_id=sc.id where '+
            'sc.X_PricelistNameOBB='+QuotedStr(aProducer_ID)+' and sp.externalnumber='+Quotedstr(mcode),'');
           if not(NxIsEmptyOID(mStoreCard_ID)) then
            begin
              mStoreCardBO.Load(mStoreCard_ID,nil);
              mQUnit_ID:=mOS.SQLSelectFirstAsString('Select id from storeunits where parent_id='+QuotedStr(mStoreCard_ID)+' and code='+QuotedStr(mUnit),'');
              mStorePrice_ID:=mOS.SQLSelectFirstAsString('SELECT ID FROM StorePrices WHERE StoreCard_ID='+QuotedStr(mStoreCard_ID)+' and Pricelist_ID='+QuotedStr(mPriceList_ID),'');
              //NxShowSimpleMessage(mQUnit_ID+' '+mStoreCardBO.DisplayName, mSite);
              if NxIsEmptyOID(mQUnit_ID) then begin
                mStoreCardBO.SetFieldValueAsInteger('U_PriceImportResult',3);
                mStoreCardBO.save;
              end else begin
                mImportedList.Add(mStoreCard_ID);
                mStoreCardBO.SetFieldValueAsInteger('U_PriceImportResult',1);
                mStoreCardBO.save;
                mUnitRate:=mOS.SQLSelectFirstAsExtended('Select unitrate from storeunits where id='+QuotedStr(mQUnit_ID),1);
                munitRate:= 1/mUnitRate;
                if NxIsEmptyOID(mStorePrice_ID)  then begin
                   mPriceBO:=mos.CreateObject(Class_StorePrice);
                   mPriceBO.New;
                   mPriceBO.SetFieldValueAsString('StoreCard_id',mStoreCard_ID);
                   mPriceBO.SetFieldValueAsString('PriceList_ID',mPriceList_ID);
                   mPriceRows:=mPriceBO.GetCollectionMonikerForFieldCode(mPriceBO.GetFieldCode('PriceRows'));
                   mPriceRowBO:=mPriceRows.AddNewObject;
                   mPriceRowBO.SetFieldValueAsString('Price_ID',mPrice_ID);
                   mPriceRowBO.SetFieldValueAsString('Qunit', mPriceBO.GetFieldValueAsString('StoreCard_id.MainUnitCode'));
                   mPriceRowBO.SetFieldValueAsFloat('UnitRate',1);
                   mPriceRowBO.SetFieldValueAsFloat('Amount',mUnitRate*mPrice);
                   mPriceBO.save;
                   mPriceBO.Free;
                end else begin
                   mPriceBO:=mos.CreateObject(Class_StorePrice);
                   mPriceBO.Load(mStorePrice_ID,nil);
                   mPriceRows:=mPriceBO.GetLoadedCollectionMonikerForFieldCode(mPriceBO.GetFieldCode('PriceRows'));
                    for m:=0 to mPriceRows.count-1 do begin
                    mPriceRowBO:=mPriceRows.BusinessObject[m];
                     if mPriceRowBO.GetFieldValueAsString('Price_ID')='1100000101' then begin
                       if mPriceRowBO.GetFieldValueAsString('Qunit')=mPriceBO.GetFieldValueAsString('StoreCard_id.MainUnitCode') then begin
                        mPriceRowBO.SetFieldValueAsFloat('Amount',mUnitRate*mPrice);
                       end;
                     end;
                    end;
                   mPriceBO.save;
                   mPriceBO.Free;
                end;
              end;
           end else begin
             mNotFoundList.Add(mcode+';'+NxFloatToIBStr(mPrice)+';'+mUnit);
           end;
           WaitWin.ChangeText(IntToStr(1+i) + ' / ' + IntToStr(mList.Count));
           WaitWin.StepIt;
        end;
        WaitWin.Stop;
        mStoreCardBO.Free;
        if mImportedList.count>=0 then begin
          mNotImportedList:=TStringList.Create;
          mStoreCardBO:=mOS.CreateObject(Class_StoreCard);
          WaitWin.StartProgress('Nastavuji nenalezené, čekejte, prosím ...', '', mProducerList.Count);
          for i:=0 to mProducerList.count-1 do begin
            if mImportedList.IndexOf(mProducerList.strings[i])<0 then begin
                mNotImportedList.add(mProducerList.strings[i]);
                mStoreCardBO.Load(mProducerList.Strings[i],nil);
                mStoreCardBO.SetFieldValueAsInteger('U_PriceImportResult',2);
                mStoreCardBO.save;
             end;
            WaitWin.ChangeText(IntToStr(1+i) + ' / ' + IntToStr(mProducerList.Count));
            WaitWin.StepIt;
          end;
          WaitWin.Stop;
          mStoreCardBO.free;
          if mNotImportedList.count>0 then begin
           mString:='A.X_PricelistNameOBB='+QuotedStr(aProducer_ID)+' and (exists (SELECT 1 FROM USERDATA WHERE FIELDCODE=2000042 AND CLSID=''C3V5QDVZ5BDL342M01C0CX3FCC'' AND ID = A.ID AND ((STRINGFIELDVALUE = ''2''  OR STRINGFIELDVALUE = ''3'')))) ';
           NxShowSimpleMessage('Budou zobrazeny nenalezené  karty podle kódu nebo jednotky '+mPricelistName, mSite);
           mSite.ShowSite(Site_StoreCards,True,'FilterByUserDynSQLCondition;'+mString+';Nepřeceněné karty '+mPricelistName);
          end;
        end;
          {if mNotFoundList.count>0 then begin
             NxShowSimpleMessage('Nebyly nalezeny tyto karty, uložíme do CSV', mSite);
             mSaveDlg := TFileSaveDialog.Create(mSite);
             mSaveDlg.Filter := 'CSV soubory (*.csv)|*.csv|Všechny soubory (*.*)|*.*';
             mSaveDlg.DefaultExtension := 'csv';
             mSaveDlg.FileName := 'nenalezeno_'+mPricelistName+'_result.csv';
             mSaveDlg.DefaultFolder:=GetEnvironmentVariable('USERPROFILE') + '\Documents';
             if mSaveDlg.Execute then begin
              mNotFoundList.SaveToFile(mSaveDlg.FileName);
              ShellAPI.Execute('open','explorer.exe','/select,"' + mSaveDlg.FileName + '"',ExtractFileDir(mSaveDlg.FileName));
             end;
           end; }
      finally
        mList.Free;
        mImportedList.free;
        mNotFoundList.free;
      end;
    end;
  end;
  if index = 1 then begin
    aProducer_ID := '';
    aFileName := '';
    mPriceList_ID:='1000000101';
    mPrice_ID := '1100000101';
    mPricelistName:='';
    aProducer_ID:='~000003S01';
    //if GetImportParameters(mSite, aProducer_ID, aFileName) then begin
    mOpenDlg := TOpenDialog.Create(Sender);
    mopenDLG.Filter := 'CSV soubory (*.csv)|*.csv|Všechny soubory (*.*)|*.*';
     if mOpenDlg.Execute then begin
      try
        mPricelistName:=mOS.SQLSelectFirstAsString('Select name from defrolldata where id='+QuotedStr(aProducer_ID),'');
        mList := TStringList.Create;
        mImportedList :=TStringList.create;
        mNotFoundList := TStringList.create;
        mList.LoadFromFile(mOpenDlg.FileName);
        k:=mList.Count;
        mProducerList:=TStringList.Create;
        mOS.SQLSelect('Select id from storecards where hidden=''N'' and X_PricelistNameOBB='+QuotedStr(aProducer_ID), mProducerList);
        WaitWin.StartProgress('Nuluji hodnoty, čekejte, prosím ...', '', mProducerList.Count);
        mStoreCardBO:=mOS.CreateObject(Class_StoreCard);
        for i:=1 to mProducerList.count-1 do begin
           mStoreCardBO.Load(mProducerList.Strings[i],nil);
           mStoreCardBO.SetFieldValueAsInteger('U_PriceImportResult',0);
           mStoreCardBO.save;
           WaitWin.ChangeText(IntToStr(1+i) + ' / ' + IntToStr(mProducerList.Count));
           WaitWin.StepIt;
        end;
        WaitWin.Stop;
        mStoreCardBO.Free;
        WaitWin.StartProgress('Čekejte, prosím ...', '', k);
        mStoreCardBO:=mOS.CreateObject(Class_StoreCard);
        for i:=1 to mList.count-1 do begin
          if (Odd(i)) then begin
           mTempStr:=mList.Strings[i];
           mCode:=NxTrapStrTrim(mTempStr,';');
           mPrice:=NxIBStrToFloat(NxTrapStrTrim(mTempStr,';'))/100;
           mUnit:=NxSearchReplace(NxTrapStrTrim(mTempStr,';'),'1','',[srAll]);
           mStoreCard_ID:=mOS.SQLSelectFirstAsString('Select sc.id from storecards sc join suppliers sp on sp.storecard_id=sc.id where '+
            'sc.X_PricelistNameOBB='+QuotedStr(aProducer_ID)+' and sp.externalnumber='+Quotedstr(mcode),'');
           if not(NxIsEmptyOID(mStoreCard_ID)) then
            begin
              mStoreCardBO.Load(mStoreCard_ID,nil);
              mQUnit_ID:=mOS.SQLSelectFirstAsString('Select id from storeunits where parent_id='+QuotedStr(mStoreCard_ID)+' and code='+QuotedStr(mUnit),'');
              mStorePrice_ID:=mOS.SQLSelectFirstAsString('SELECT ID FROM StorePrices WHERE StoreCard_ID='+QuotedStr(mStoreCard_ID)+' and Pricelist_ID='+QuotedStr(mPriceList_ID),'');
              //NxShowSimpleMessage(mQUnit_ID+' '+mStoreCardBO.DisplayName, mSite);
              if NxIsEmptyOID(mQUnit_ID) then begin
                mStoreCardBO.SetFieldValueAsInteger('U_PriceImportResult',3);
                mStoreCardBO.save;
              end else begin
                mImportedList.Add(mStoreCard_ID);
                mStoreCardBO.SetFieldValueAsInteger('U_PriceImportResult',1);
                mStoreCardBO.save;
                mUnitRate:=mOS.SQLSelectFirstAsExtended('Select unitrate from storeunits where id='+QuotedStr(mQUnit_ID),1);
                munitRate:= 1/mUnitRate;
                if NxIsEmptyOID(mStorePrice_ID)  then begin
                   mPriceBO:=mos.CreateObject(Class_StorePrice);
                   mPriceBO.New;
                   mPriceBO.SetFieldValueAsString('StoreCard_id',mStoreCard_ID);
                   mPriceBO.SetFieldValueAsString('PriceList_ID',mPriceList_ID);
                   mPriceRows:=mPriceBO.GetCollectionMonikerForFieldCode(mPriceBO.GetFieldCode('PriceRows'));
                   mPriceRowBO:=mPriceRows.AddNewObject;
                   mPriceRowBO.SetFieldValueAsString('Price_ID',mPrice_ID);
                   mPriceRowBO.SetFieldValueAsString('Qunit', mPriceBO.GetFieldValueAsString('StoreCard_id.MainUnitCode'));
                   mPriceRowBO.SetFieldValueAsFloat('UnitRate',1);
                   mPriceRowBO.SetFieldValueAsFloat('Amount',mUnitRate*mPrice);
                   mPriceBO.save;
                   mPriceBO.Free;
                end else begin
                   mPriceBO:=mos.CreateObject(Class_StorePrice);
                   mPriceBO.Load(mStorePrice_ID,nil);
                   mPriceRows:=mPriceBO.GetLoadedCollectionMonikerForFieldCode(mPriceBO.GetFieldCode('PriceRows'));
                    for m:=0 to mPriceRows.count-1 do begin
                    mPriceRowBO:=mPriceRows.BusinessObject[m];
                     if mPriceRowBO.GetFieldValueAsString('Price_ID')='1100000101' then begin
                       if mPriceRowBO.GetFieldValueAsString('Qunit')=mPriceBO.GetFieldValueAsString('StoreCard_id.MainUnitCode') then begin
                        mPriceRowBO.SetFieldValueAsFloat('Amount',mUnitRate*mPrice);
                       end;
                     end;
                    end;
                   mPriceBO.save;
                   mPriceBO.Free;
                end;
              end;
           end else begin
             mNotFoundList.Add(mcode+';'+NxFloatToIBStr(mPrice)+';'+mUnit);
           end;
           WaitWin.ChangeText(IntToStr(1+i) + ' / ' + IntToStr(mList.Count));
           WaitWin.StepIt;
          end;
        end;
        WaitWin.Stop;
        mStoreCardBO.Free;
        if mImportedList.count>=0 then begin
          mNotImportedList:=TStringList.Create;
          mStoreCardBO:=mOS.CreateObject(Class_StoreCard);
          WaitWin.StartProgress('Nastavuji nenalezené, čekejte, prosím ...', '', mProducerList.Count);
          for i:=0 to mProducerList.count-1 do begin
            if mImportedList.IndexOf(mProducerList.strings[i])<0 then begin
                mStoreCardBO.Load(mProducerList.Strings[i],nil);
                mStoreCardBO.SetFieldValueAsInteger('U_PriceImportResult',2);
                if mNotImportedList.count=0 then
                mNotImportedList.Add('a.id='+QuotedStr(mProducerList.Strings[i]))
                 else
                mNotImportedList.Add(' or a.id='+QuotedStr(mProducerList.Strings[i]));
                mStoreCardBO.save;
             end;
            WaitWin.ChangeText(IntToStr(1+i) + ' / ' + IntToStr(mProducerList.Count));
            WaitWin.StepIt;
          end;
          WaitWin.Stop;
          mStoreCardBO.free;
          if mNotImportedList.count>0 then begin
           mString:='A.X_PricelistNameOBB='+QuotedStr(aProducer_ID)+' and (exists (SELECT 1 FROM USERDATA WHERE FIELDCODE=2000042 AND CLSID=''C3V5QDVZ5BDL342M01C0CX3FCC'' AND ID = A.ID AND ((STRINGFIELDVALUE = ''2''  OR STRINGFIELDVALUE = ''3'')))) ';
           NxShowSimpleMessage('Budou zobrazeny nenalezené  karty podle kódu nebo jednotky '+mPricelistName, mSite);
           mSite.ShowSite(Site_StoreCards,True,'FilterByUserDynSQLCondition;'+mString+';Nepřeceněné karty '+mPricelistName);
          end;
        end;
          {if mNotFoundList.count>0 then begin
             NxShowSimpleMessage('Nebyly nalezeny tyto karty, uložíme do CSV', mSite);
             mSaveDlg := TFileSaveDialog.Create(mSite);
             mSaveDlg.Filter := 'CSV soubory (*.csv)|*.csv|Všechny soubory (*.*)|*.*';
             mSaveDlg.DefaultExtension := 'csv';
             mSaveDlg.FileName := 'nenalezeno_'+mPricelistName+'_result.csv';
             mSaveDlg.DefaultFolder:=GetEnvironmentVariable('USERPROFILE') + '\Documents';
             if mSaveDlg.Execute then begin
              mNotFoundList.SaveToFile(mSaveDlg.FileName);
              ShellAPI.Execute('open','explorer.exe','/select,"' + mSaveDlg.FileName + '"',ExtractFileDir(mSaveDlg.FileName));
             end;
           end; }
      finally
        mList.Free;
        mImportedList.free;
        mNotFoundList.free;
      end;
    end;
  end;
end;

procedure OnFormCloseAction(Sender: TObject; var Action: TCloseAction);
begin
  if Action = caHide then TForm(Sender).ModalResult := mrCancel;
end;

Function GetImportParameters(var ASite: TSiteForm; var aUserProducer_ID: string; var aFileName: string): Boolean;
var
  mLabel, mCbCCUserProducer, mLabelFile: TLabel;
  mButOk, mButCancel, mBtnBrowse: TButton;
  mResult, mCount: integer;
  mForm: TForm;
  mOS: TNxCustomObjectSpace;
  mCBUserProducer: TRollComboEdit;
  mEditFile: TEdit;
begin
  if ASite <> nil then begin
    mOS := ASite.BaseObjectSpace;
    Result := False;
    mCount := 0;

    mForm := TForm.Create(ASite);
    mForm.Width := 550;
    mForm.Position := poScreenCenter;
    mForm.Caption := 'Údaje pro import cen:';
    mForm.OnCloseQuery := @OnFormCloseAction;

    // --- Řádek 0: Výrobce ---
    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Výrobce:';
    mLabel.Top := (mCount * 25) + 12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mCbCCUserProducer := TLabel.Create(mForm);
    mCbCCUserProducer.Parent := mForm;
    mCbCCUserProducer.Left := 236;
    mCbCCUserProducer.Top := (mCount * 25) + 12;
    mCbCCUserProducer.Width := 255;

    mCBUserProducer := TRollComboEdit.Create(mForm);
    mCBUserProducer.Parent := mForm;
    // .Name záměrně nenastavujeme, aby se nepropisovalo do textu
    mCBUserProducer.ClassID := '3OAYSIWTZF4OHCUZXX53M3RQRO';
    mCBUserProducer.Complete := True;
    mCBUserProducer.Prefilling := pmNone;
    mCBUserProducer.TextField := 'Code';
    mCBUserProducer.Top := (mCount * 25) + 10;
    mCBUserProducer.Left := 140;
    mCBUserProducer.Width := 80;
    if not(NxIsEmptyOID(aUserProducer_ID)) then begin
      mCBUserProducer.DataText := aUserProducer_ID;
      mCBUserProducer.Refresh;
    end;
    mCBUserProducer.ConnectedControl := mCbCCUserProducer;
    mCBUserProducer.ConnectedControlField := 'Name';

    mCount := mCount + 1;

    // --- Řádek 1: Soubor CSV ---
    mLabelFile := TLabel.Create(mForm);
    mLabelFile.Parent := mForm;
    mLabelFile.Caption := 'Soubor CSV:';
    mLabelFile.Top := (mCount * 25) + 12;
    mLabelFile.Left := 17;
    mLabelFile.Height := 13;
    mLabelFile.Width := 100;
    mLabelFile.Font.Size := 10;

    mEditFile := TEdit.Create(mForm);
    mEditFile.Parent := mForm;
    // .Name záměrně nenastavujeme
    mEditFile.Left := 140;
    mEditFile.Top := (mCount * 25) + 10;
    mEditFile.Width := 295;
    mEditFile.Text := aFileName;

    mBtnBrowse := TButton.Create(mForm);
    mBtnBrowse.Parent := mForm;
    mBtnBrowse.Caption := '...';
    mBtnBrowse.Left := 440;
    mBtnBrowse.Top := (mCount * 25) + 9;
    mBtnBrowse.Width := 40;
    mBtnBrowse.Height := 24;
    mBtnBrowse.OnClick := @BrowseClick;

    mCount := mCount + 1;

    // --- Tlačítka OK / Zrušit ---
    mButOk := TButton.Create(mForm);
    mButOk.Parent := mForm;
    mButOk.Caption := 'OK';
    mButOk.Default := True;
    mButOk.Top := (mCount * 25) + 20;
    mButOk.Left := 292;
    mButOk.Height := 24;
    mButOk.Width := 62;
    mButOk.OnClick := @OkClick;

    mButCancel := TButton.Create(mForm);
    mButCancel.Parent := mForm;
    mButCancel.Caption := 'Zrušit';
    mButCancel.Top := (mCount * 25) + 20;
    mButCancel.Left := 360;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;

    mForm.Height := (mCount * 25) + 95;

    mResult := mForm.ShowModal(ASite);
    if mResult = 1 then begin
      Result := True;
      aUserProducer_ID := mCBUserProducer.DataText;
      aFileName := mEditFile.Text;
    end;
    mForm.Free;
  end;
end;

begin
end.