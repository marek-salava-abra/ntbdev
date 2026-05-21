uses '.const';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mMAction: TMultiAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImportMollie';
  mAction.Caption := 'Import Mollie';
  mAction.Hint := 'Import data from CSV file Mollie';
  mAction.Category := 'tabDetail';
  mAction.OnUpdate := @OnUpdate;
  mAction.OnExecute := @ImportData;

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actImportXLSBS';
  mAction.Caption := 'Bank Statement XLS';
  mAction.Hint := 'Import data from XLS file';
  mAction.Category := 'tabDetail';
  mAction.OnUpdate := @OnUpdate;
  mAction.OnExecute := @ImportDataXLS;

  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Name := 'actMatchPayment';
  mMAction.Caption := 'MatchPayment - Invoice';
  mMAction.Items.Add('MatchPayment - Invoice');
  mMAction.Items.Add('MatchPayment - Deposit');
  mMAction.Hint := 'Try to match payment';
  mMAction.Category := 'tabDetail';
  mMAction.OnUpdate := @OnUpdate;
  mMAction.OnExecuteItem := @MatchPayment;
  mMAction.ShortCut := VK_F6;

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actSplitRow';
  mAction.Caption := 'Split row';
  mAction.Hint := 'Split row in 2 rows';
  mAction.Category := 'tabDetail';
  mAction.OnUpdate := @OnUpdate;
  mAction.OnExecute := @SplitRow;

end;

procedure OnUpdate(Sender: TObject);
var
  mSite: TDynSiteForm;
begin
  mSite := TDynSiteForm(TComponent(Sender).Site);
  TBasicAction(Sender).Enabled := mSite.Edit;
end;

Procedure MatchPayment(Sender:TComponent; Index:integer);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mGrdRows: TMultiGrid;
 mDataset: TNxCustomObjectDataSet;
 mControl:TControl;
 mRow, mNewRow, mObj, mPDocument: TNxCustomBusinessObject;
 mSelected, mFilter, mOLE, mSelectSite: Variant;
 mIDs:TStringList;
 i:integer;
 mBreakDown:Boolean;
 mDocID:string;
 mAmount,mDocsSumAmount:Extended;
 mRows:TNxCustomBusinessMonikerCollection;
begin
 mSite:=TComponent(sender).DynSite;
 mOS:=mSite.BaseObjectSpace;
 try
   mControl:= mSite.FindChildControl('tabRows.grdRows');
   mDataset := TNxRowsObjectDataSet(TMultiGrid(mControl).DataSource.DataSet);
   if (not Assigned(mDataset.CurrentObject)) then RaiseException('None row of bank statement is selected');
   mRow := mDataset.CurrentObject;
    try
      if (not NxIsEmptyOID(mRow.GetFieldValueAsString('BankStatementRow_ID'))) then
        RaiseException('Funkci nelze použít uvnitř rozpadu');
      mOLE := GetAbraOLEApplication;
      mFilter := GetAbraOLEStrings;
      mSelected := GetAbraOLEStrings;
      if Index=0 then mSelectSite := mOLE.GetAgenda(Site_IssuedInvoices);
      if Index=1 then mSelectSite := mOLE.GetAgenda(Site_IssuedDepositInvoices);
      if not(NxIsEmptyOID(mRow.GetFieldValueAsString('Firm_ID'))) then begin
        mIDs:=TStringList.create;
        mOS.SQLSelect('Select id from issuedinvoices where paidamount<>amount and firm_id='+QuotedStr(mRow.GetFieldValueAsString('Firm_ID')) +' order by docdate$date',mIDs);
        try
          //for i:=0 to mIDs.count-1 do mFilter.add(mIDs.strings[i]);
        finally
         mIDs.free;
        end;
      end;
      if mSelectSite.MultiSelectFromSelected(mFilter, '', mSelected) then begin
         mDataSet.DisableControls;
         if (mSelected.Count > 0) then begin

          // Vybrán 1 doklad s odpovídající nebo vyšší cenou - jednoduché párování k řádku BV
          mBreakDown := false;
          if (mSelected.Count = 1) then begin
            //CommonLog('PaymentMatching', 'Vybrán 1 doklad');
            mDocID := mSelected.Strings[0];
            if index=0 then mPDocument := mOS.CreateObject(Class_IssuedInvoice);
            if index=1 then mPDocument := mOS.CreateObject(Class_IssuedDepositInvoice);
            try
              mPDocument.Load(mDocID, nil);
              mAmount := mPDocument.GetFieldValueAsFloat('Amount') - mPDocument.GetFieldValueAsFloat('PaidAmount');
              //CommonLog('PaymentMatching', 'Amount = '+ FloatToStr(mAmount));
              if mAmount >= mRow.GetFieldValueAsFloat('Amount') then begin
                //CommonLog('PaymentMatching', 'Souhlasí částka - páruji přesně bez rozpadu');
                if index=0 then mRow.SetFieldValueAsString('PDocumentType', '03');
                if index=1 then mRow.SetFieldValueAsString('PDocumentType', '10');
                mRow.SetFieldValueAsString('PDocument_ID', mDocID);
                mRow.SetFieldValueAsFloat('PAmount', mRow.GetFieldValueAsFloat('Amount'));
                mDataset.RefreshCurrentItem;
              // v případě přeplatku jdeme na rozpad
              end else begin
                mBreakDown := true;
              end;
            finally
              mPDocument.Free;
            end;
          end;


          // Vybráno více dokladů nebo částka jednoho je menší (přeplatek) -> rozpad řádku BV
          if (mSelected.Count > 1) or (mBreakDown) then begin
            //CommonLog('PaymentMatching', 'Vybráno více dokladů nebo je přeplatek jednoho > rozpad');
            mRow.SetFieldValueAsString('PDocument_ID', '');
            mRow.SetFieldValueAsString('PDocumentType', '');
            mRow.SetFieldValueAsBoolean('IsMultiPaymentRow', true);

            mDocsSumAmount := 0;
            i := 0;
            while i < mSelected.Count do begin
              mDocID := mSelected.Strings[i];
              if index=0 then mPDocument := mOS.CreateObject(Class_IssuedInvoice);
              if index=1 then mPDocument := mOS.CreateObject(Class_IssuedDepositInvoice);
              try
                mPDocument.Load(mDocID, nil);
                //CommonLog('PaymentMatching', mPDocument.DisplayName);
                // částka řádku rozpadu = nezaplacená částka placeného dokladu
                if index=0 then mAmount := mPDocument.GetFieldValueAsFloat('Amount') - mPDocument.GetFieldValueAsFloat('PaidAmount');// - mPDocument.GetFieldValueAsFloat('CreditAmount');
                if index=1 then mAmount := mPDocument.GetFieldValueAsFloat('Amount') - mPDocument.GetFieldValueAsFloat('PaidAmount');
                //CommonLog('PaymentMatching', 'Částka k rozpadu (nezaplaceno z PDocument) = ' + FloatToStr(mAmount));
                mDocsSumAmount := mDocsSumAmount + mAmount;
                //CommonLog('PaymentMatching', 'mDocsSumAmount = ' + FloatToStr(mDocsSumAmount));
                //CommonLog('PaymentMatching', 'Původní Row Amount = ' + FloatToStr(mRow.GetFieldValueAsFloat('Amount')));

                // v případě přesahu přes částku původního řádku se částka poníží a doklad je uhrazen částečně. Další doklady už nepřidávat.
                if (mDocsSumAmount > mRow.GetFieldValueAsFloat('Amount')) then begin
                  //CommonLog('PaymentMatching', 'Ponížení mAmount o přesah '+FloatToStr(mDocsSumAmount - mRow.GetFieldValueAsFloat('Amount')));
                  mAmount := mAmount - (mDocsSumAmount - mRow.GetFieldValueAsFloat('Amount'));
                  i := mSelected.Count;
                  //CommonLog('PaymentMatching', 'Nepokračovat');
                end;

                //CommonLog('PaymentMatching', 'Přidávám řádek '+FloatToStr(mAmount));
                mNewRow := mDataset.CreateBusinessObject;
                mNewRow.Prefill;
                mNewRow.SetFieldValueAsString('BankStatementRow_ID', mRow.OID);
                mNewRow.SetFieldValueAsBoolean('Credit', mRow.GetFieldValueAsBoolean('Credit'));
                mNewRow.SetFieldValueAsDateTime('DocDate$DATE', mRow.GetFieldValueAsDateTime('DocDate$DATE'));
                mNewRow.SetFieldValueAsString('Currency_ID', mRow.GetFieldValueAsString('Currency_ID'));
                mNewRow.SetFieldValueAsString('VarSymbol', mRow.GetFieldValueAsString('VarSymbol'));
                mNewRow.SetFieldValueAsString('Text', mRow.GetFieldValueAsString('Text'));
                mNewRow.SetFieldValueAsString('Division_ID', mRow.GetFieldValueAsString('Division_ID'));
                mNewRow.SetFieldValueAsFloat('Amount', mAmount);
                mNewRow.SetFieldValueAsFloat('PAmount', mAmount);
                if index=0 then mNewRow.SetFieldValueAsString('PDocumentType', '03');
                if index=1 then mNewRow.SetFieldValueAsString('PDocumentType', '10');
                mNewRow.SetFieldValueAsString('PDocument_ID', mDocID);

              finally
                mPDocument.Free;
              end;
              Inc(i);
            end;

            // Pokud není vyčerpána celá částka řádku, přidat řádek bez předpisu.
            // Pokud je částka řádku menší, vyvolat chybu
            if mRow.GetFieldValueAsFloat('Amount') > mDocsSumAmount then begin
              mAmount := mRow.GetFieldValueAsFloat('Amount') - mDocsSumAmount;
              //CommonLog('PaymentMatching', 'Částka původního řádku není vyčerpána - přidávám volný řádek rozpadu '+FloatToStr(mAmount));
              //mNewRow := mRows.AddNewObject;
              mNewRow := mDataset.CreateBusinessObject;
              mNewRow.Prefill;
              mNewRow.SetFieldValueAsBoolean('Credit', mRow.GetFieldValueAsBoolean('Credit'));
              mNewRow.SetFieldValueAsDateTime('DocDate$DATE', mRow.GetFieldValueAsDateTime('DocDate$DATE'));
              mNewRow.SetFieldValueAsString('Currency_ID', mRow.GetFieldValueAsString('Currency_ID'));
              mNewRow.SetFieldValueAsString('VarSymbol', mRow.GetFieldValueAsString('VarSymbol'));
              mNewRow.SetFieldValueAsString('Text', mRow.GetFieldValueAsString('Text'));
              mNewRow.SetFieldValueAsString('Division_ID', mRow.GetFieldValueAsString('Division_ID'));
              mNewRow.SetFieldValueAsString('BankStatementRow_ID', mRow.OID);
              mNewRow.SetFieldValueAsFloat('Amount', mAmount);
              mNewRow.SetFieldValueAsFloat('PAmount', mAmount);
              mNewRow.SetFieldValueAsString('PDocument_ID', '');
              mNewRow.SetFieldValueAsString('PDocumentType', '');
            end;


            TButton(mSite.FindChildControl('btnDetailRows')).Click;
          end;

        end; // mList.Count
       TDynSiteForm(mSite).ActiveDataSet.UpdateFields; //Aby se o změně dozvěděl hlavičkový dataset
       mDataSet.EnableControls;
      end;
    finally

    end;
 except

 end;
end;

Procedure ImportDataXLS(Sender:TComponent);
Var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mList:TStringList;
 i,j,startPos,endPos:integer;
 mOpenDlg:TOpenDialog;
 mControl: TControl;
 mDataset: TNxRowsObjectDataSet;
 mRow:TNxCustomBusinessObject;
 mTempStr:string;
 mDate, mPayment_method, mCurrency, mAmount, mStatus, mID, mDescription, mConsumer_name:string;
 mConsumer_bank_account, mConsumer_BIC, mSettlement_currency, mSettlement_amount, mSettlement_reference, mAmount_refunded:string;
 mVarSymbol, mTransactionID, mLang, mText, mFirm_ID:string;
 mExcel, mWB, mSheet: Variant;
begin
  mSite:=TComponent(sender).DynSite;
  mOS:=mSite.BaseObjectSpace;
  mLang:=AbraVersion.UserLanguage;
  mList:=tstringlist.create;
  mOpenDlg := TOpenDialog.Create(Sender);
  mOpenDlg.Title := 'Import XLS';
  mOpenDlg.Filter := 'Excel files (*.xls, *.xlsx)| *.xls;*.xlsx';
  if mOpenDlg.Execute then begin
      try
        mControl:= mSite.FindChildControl('tabRows.grdRows');
        mDataset := TNxRowsObjectDataSet(TMultiGrid(mControl).DataSource.DataSet);
        if Assigned(mDataset) then begin
          mDataSet.DisableControls;
          mExcel := CreateOleObject('Excel.Application');
          mWB := mExcel.Workbooks.Open(mOpenDlg.FileName);
          mSheet := mWB.Sheets[1];
          i:=5;
          j:=mSheet.UsedRange.Rows.Count+1;
          WaitWin.StartProgress('Please, wait ...', '', j);
          while i<j  do begin
           WaitWin.ChangeText(IntToStr(i) + ' / ' + IntToStr(j));
            mAmount:=VarToStr(mSheet.Cells[i, 11]);
            //NxShowSimpleMessage(mAmount,mSite);
            mDate:=VarToStr(mSheet.Cells[i, 5]);
            if not(NxIsBlank(VarToStr(mSheet.Cells[i, 7]))) then
              mFirm_ID:=mOS.SQLSelectFirstAsString('Select f.id from firms f left join firmbankaccounts fb on f.id=fb.parent_id where f.firm_id is null and f.hidden=''N'' and fb.BankAccount='+Quotedstr(VarToStr(mSheet.Cells[i, 7])),'');
            mTransactionID:=AnsiLeftStr(VarToStr(mSheet.Cells[i, 13]),30);
            mVarSymbol:='';
            if NxIsNumeric(NxTrim(VarToStr(mSheet.Cells[i, 15]),' ')) then mVarSymbol:=NxTrim(VarToStr(mSheet.Cells[i, 15]),' ');
            mText:=NxTrim(VarToStr(mSheet.Cells[i, 6])+' '+VarToStr(mSheet.Cells[i, 13])+' '+VarToStr(mSheet.Cells[i, 15]),' ');
            if NxIBStrToFloat(mAmount)>0 then begin
               mRow := mDataSet.CreateBusinessObject;
               mRow.Prefill;
               mRow.SetFieldValueAsBoolean('Credit',true);
               mRow.SetFieldValueAsFloat('Amount',NxIBStrToFloat(mAmount));
               mRow.SetFieldValueAsString('VarSymbol',mVarSymbol);
               mRow.SetFieldValueAsString('Division_ID',cDivision_ID);
               mrow.SetFieldValueAsDateTime('DocDate$DATE',StrToDate(mDate));
               mRow.SetFieldValueAsString('X_TransactionID',mTransactionID);
               if NxIsEmptyOID(mrow.GetFieldValueAsString('Firm_ID')) and not(NxIsEmptyOID(mFirm_ID)) then
                mRow.SetFieldValueAsString('Firm_ID',mFirm_ID);
               mRow.SetFieldValueAsString('Text', mText);
               if NxIsEmptyOID(mrow.GetFieldValueAsString('Firm_ID')) then mrow.SetFieldValueAsString('Firm_ID',cFirm_ID);
             end;
             if NxIBStrToFloat(mAmount)<0 then begin
               mRow := mDataSet.CreateBusinessObject;
               mRow.Prefill;
               mRow.SetFieldValueAsBoolean('Credit',false);
               mRow.SetFieldValueAsFloat('Amount',-NxIBStrToFloat(mAmount));
               mRow.SetFieldValueAsString('Division_ID',cDivision_ID);
               mRow.SetFieldValueAsString('VarSymbol',mVarSymbol);
               mrow.SetFieldValueAsDateTime('DocDate$DATE',StrToDate(mDate));
               mRow.SetFieldValueAsString('Division_ID',cDivision_ID);
               mRow.SetFieldValueAsString('X_TransactionID',mTransactionID);
               if NxIsEmptyOID(mrow.GetFieldValueAsString('Firm_ID')) and not(NxIsEmptyOID(mFirm_ID)) then
                mRow.SetFieldValueAsString('Firm_ID',mFirm_ID);
               mRow.SetFieldValueAsString('Text', mText);
               if NxIsEmptyOID(mrow.GetFieldValueAsString('Firm_ID')) then mrow.SetFieldValueAsString('Firm_ID',cFirm_ID);
             end;


           Inc(i);
           WaitWin.StepIt;
          end;
         WaitWin.Stop;
         mWB.close;
        end;
        TDynSiteForm(mSite).ActiveDataSet.UpdateFields; //Aby se o změně dozvěděl hlavičkový dataset
        mDataset.RefreshAndRestoreLastSelectedItem;
        mDataSet.EnableControls;
      except
        NxShowSimpleMessage(ExceptionMessage,mSite);
        WaitWin.Stop;
      end;
  end;
end;

Procedure ImportData(Sender:TComponent);
Var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mList:TStringList;
 i,startPos,endPos:integer;
 mOpenDlg:TOpenDialog;
 mControl: TControl;
 mDataset: TNxRowsObjectDataSet;
 mRow:TNxCustomBusinessObject;
 mTempStr:string;
 mDate, mPayment_method, mCurrency, mAmount, mStatus, mID, mDescription, mConsumer_name:string;
 mConsumer_bank_account, mConsumer_BIC, mSettlement_currency, mSettlement_amount, mSettlement_reference, mAmount_refunded:string;
 mVarSymbol, mTransactionID, mLang:string;
begin
  mSite:=TComponent(sender).DynSite;
  mOS:=mSite.BaseObjectSpace;
  mLang:=AbraVersion.UserLanguage;
  mList:=tstringlist.create;
  mOpenDlg := TOpenDialog.Create(Sender);
  if mOpenDlg.Execute then begin
    mList.LoadFromFile(mOpenDlg.FileName);
    if mList.Count>0 then begin
     mControl:= mSite.FindChildControl('tabRows.grdRows');
     mDataset := TNxRowsObjectDataSet(TMultiGrid(mControl).DataSource.DataSet);
     if Assigned(mDataset) then begin
      mDataSet.DisableControls;
       WaitWin.StartProgress('Please, wait ...', '', mList.Count);
        for i:=1 to mlist.count-1 do begin
            mTransactionID:='';
            mVarSymbol:='';
            mTempStr:=NxSearchReplace(mlist.Strings[i],'"','',[srAll]);
            mDate:=NxTrapStr(mTempStr,',');
            mPayment_method:=NxTrapStr(mTempStr,',');
            mCurrency:=NxTrapStr(mTempStr,',');
            mAmount:=NxTrapStr(mTempStr,',');
            mStatus:=NxTrapStr(mTempStr,',');
            mID:=NxTrapStr(mTempStr,',');
            mDescription:=NxTrapStr(mTempStr,',');
            mConsumer_name:=NxTrapStr(mTempStr,',');
            mConsumer_bank_account:=NxTrapStr(mTempStr,',');
            mConsumer_BIC:=NxTrapStr(mTempStr,',');
            mSettlement_currency:=NxTrapStr(mTempStr,',');
            mSettlement_amount:=NxTrapStr(mTempStr,',');
            mSettlement_reference:=NxTrapStr(mTempStr,',');
            mAmount_refunded:=NxTrapStr(mTempStr,',');
            startPos := Pos('tr_', mDescription);
            if (startPos > 0) and (Length(mDescription) >= startPos + 23) then
             begin    mtransactionId := Copy(mDescription, startPos, 24);
            end;
            startPos:=Pos('Bestellung ',mDescription);
            if (startPos>0) then begin
              startPos := startPos + Length('Bestellung ');
              endPos := startPos;
              while (endPos <= Length(mDescription)) and (mDescription[endPos] in ['0'..'9']) do Inc(endPos);
              mVarSymbol:= Copy(mDescription, startPos, endPos - startPos);
            end;
            startPos:=Pos(' - Payment', mDescription);
            if startPos>0 then begin
              endPos := startPos-1;
              startPos := endPos;
              while (startPos > 0) and (mDescription[startPos] in ['0'..'9']) do Dec(startPos);
              Inc(startPos);
              mVarSymbol:= Copy(mDescription, startPos, endPos - startPos);
            end;
            if (Pos('tr_',mID)>0) or (Pos('re_',mID)>0) then mTransactionID:=mID;
             if NxIBStrToFloat(mAmount)>0 then begin
               mRow := mDataSet.CreateBusinessObject;
               mRow.Prefill;
               mRow.SetFieldValueAsBoolean('Credit',true);
               mRow.SetFieldValueAsFloat('Amount',NxIBStrToFloat(mAmount));
               mRow.SetFieldValueAsString('VarSymbol',mVarSymbol);
               mRow.SetFieldValueAsString('Division_ID',cDivision_ID);
               mrow.SetFieldValueAsDateTime('DocDate$DATE',iiCompileDate(mDate));
               mRow.SetFieldValueAsString('X_TransactionID',mTransactionID);
               mRow.SetFieldValueAsString('Text', mConsumer_name);
               if NxIsEmptyOID(mrow.GetFieldValueAsString('Firm_ID')) then mrow.SetFieldValueAsString('Firm_ID',cFirm_ID);
             end;
             if NxIBStrToFloat(mAmount)<0 then begin
               mRow := mDataSet.CreateBusinessObject;
               mRow.Prefill;
               mRow.SetFieldValueAsBoolean('Credit',false);
               mRow.SetFieldValueAsFloat('Amount',-NxIBStrToFloat(mAmount));
               mRow.SetFieldValueAsString('Division_ID',cDivision_ID);
               mRow.SetFieldValueAsString('VarSymbol',mVarSymbol);
               mrow.SetFieldValueAsDateTime('DocDate$DATE',iiCompileDate(mDate));
               mRow.SetFieldValueAsString('Division_ID',cDivision_ID);
               mRow.SetFieldValueAsString('X_TransactionID',mTransactionID);
               mRow.SetFieldValueAsString('Text', mConsumer_name);
               if NxIsEmptyOID(mrow.GetFieldValueAsString('Firm_ID')) then mrow.SetFieldValueAsString('Firm_ID',cFirm_ID);
             end;

           WaitWin.ChangeText(IntToStr(1+i) + ' / ' + IntToStr(mList.Count));
           WaitWin.StepIt;
        end;
       WaitWin.Stop;
       TDynSiteForm(mSite).ActiveDataSet.UpdateFields; //Aby se o změně dozvěděl hlavičkový dataset
       mDataset.RefreshAndRestoreLastSelectedItem;
       mDataSet.EnableControls;
      end;
       NxShowSimpleMessage('Inserted '+IntToStr(mlist.count-1)+' rows.',mSite);
      end;
   end;
end;

Procedure SplitRow(Sender:TComponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mControl: TControl;
 mDataset: TNxRowsObjectDataSet;
 mFirm_ID:string;
 mAmount, mOrigAmount:Extended;
 mOrigRow, mNewRow:TNxCustomBusinessObject;
begin
  mSite:=TComponent(sender).DynSite;
  mOS:=mSite.BaseObjectSpace;
  try
        mControl:= mSite.FindChildControl('tabRows.grdRows');
        mDataset := TNxRowsObjectDataSet(TMultiGrid(mControl).DataSource.DataSet);
        if Assigned(mDataset) then begin
          mDataSet.DisableControls;
          if GetDataForSplitRow(mSite,mFirm_ID,mAmount) then begin
            //NxShowSimpleMessage(FloatToStr(mDataset.CurrentObject.GetFieldValueAsFloat('PAmount')),msite);
            mOrigAmount:=mDataset.CurrentObject.GetFieldValueAsFloat('Amount');
            if (mAmount<mOrigAmount) and (mAmount>0) then begin
              mOrigRow:=mDataset.CurrentObject;
              mNewRow:=mDataset.CreateBusinessObject;
              mNewRow.SetFieldValueAsBoolean('Credit',mOrigRow.GetFieldValueAsBoolean('Credit'));
              mNewRow.SetFieldValueAsInteger('PosIndex', mOrigRow.GetFieldValueAsInteger('Posindex'));
              mNEwRow.SetFieldValueAsFloat('Amount',mAmount);
              mNewRow.SetFieldValueAsString('Firm_ID',mFirm_ID);
              mNewRow.SetFieldValueAsString('Division_ID',mOrigRow.GetFieldValueAsString('Division_ID'));
              mNewRow.SetFieldValueAsDateTime('DocDate$DATE', mOrigRow.GetFieldValueAsDateTime('DocDate$DATE'));
              mOrigRow.SetFieldValueAsFloat('Amount',mOrigAmount-mAmount);
            end;
          end;
          TDynSiteForm(mSite).ActiveDataSet.UpdateFields; //Aby se o změně dozvěděl hlavičkový dataset
          mDataset.RefreshAndRestoreLastSelectedItem;
          mDataSet.EnableControls;
        end;
  except
    NxShowSimpleMessage(ExceptionMessage,mSite);
  end;
end;

Function GetDataForSplitRow(var ASite : TSiteform; var aFirm_ID:String; var aAmount:Extended):Boolean;
var
    mLabel, mCbCCFirm: TLabel;
    mAllowed:TStringList;
    mButOk, mButCancel : TButton;
    mResult, mCount : integer;
    mForm : TForm;
    mCBFirm:TRollComboEdit;
    mNumEd:TNumEdit;
 begin
 if ASite <> nil then begin
    mAllowed:=TStringList.Create;
    Result:=False;
    mCount:=0;
    mForm:= TForm.Create(ASite);
    mForm.Width:= 510;
    mForm.Position:=poScreenCenter;
    mForm.Caption := 'Data for split row:';
    mForm.OnCloseQuery:= @OnFormCloseAction;

    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Firm:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mCbCCFirm:= TLabel.Create(mForm);
    mCbCCFirm.Parent:= mForm;
    mCbCCFirm.Left:= 236;
    mCbCCFirm.Top:= (mCount*25)+12;
    mCbCCFirm.Width:= 255;

    mCBFirm:= TRollComboEdit.Create(mForm);
    mCBFirm.Parent:= mForm;
    mCBFirm.ClassID:= Roll_Firms;
    mCBFirm.Complete:= True;
    mCBFirm.Prefilling:= pmNone;
    mCBFirm.TextField:= 'Code';  // položka podle které se bude vyhledávat
    mCBFirm.Top:= (mCount*25)+10;
    mCBFirm.Left:= 140;
    mCBFirm.Width:= 80;
    mCBFirm.ConnectedControl:= mCbCCFirm;
    mCBFirm.ConnectedControlField:= 'Name';

    mCount:= mCount+1;

    mLabel := TLabel.Create(mForm);
    mLabel.Parent := mForm;
    mLabel.Caption := 'Amount:';
    mLabel.Top := (mCount*25)+12;
    mLabel.Left := 17;
    mLabel.Height := 13;
    mLabel.Width := 100;
    mLabel.Font.Size := 10;

    mNumEd := TNumEdit.Create(mForm);
    mNumEd.Left := 140;
    mNumEd.Top := (mCount*25)+10;
    mNumEd.Width := 80;
    mNumEd.Value := aAmount;
    mNumEd.DecimalPlaces := 2;
    mNumEd.Parent := mForm;

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
    mButCancel.Caption := 'Cancel';
    mButCancel.Top := (mCount*25)+20;
    mButCancel.Left := 320;
    mButCancel.Height := 24;
    mButCancel.Width := 62;
    mButCancel.ModalResult := 2;
    mForm.Height:= (mCount*25)+95;

    mResult := mForm.ShowModal(ASite);
    if mResult = 1 then begin
         aFirm_ID:=mCBFirm.DataText;
         aAmount:=mNumEd.Value;
         Result:=True;
     end;
    mForm.free;
  end;
end;

procedure OnFormCloseAction(Sender: TObject; var Action: TCloseAction);
begin
  if Action = caHide then TForm(Sender).ModalResult := mrCancel;
end;

function iiCompileDate(const AText : string) : TDate;
var
  mYear, mMonth, mDay, a : string;
begin
  a := AText;
  mYear := NxToken(a, '-');
  mMonth  := NxToken(a, '-');
  mDay  := NxToken(a, ' ');
  a := Format('%s.%s.%s', [mDay, mMonth, mYear]);
  Result := StrToDate(a);
end;

procedure _InitSelf_PostHook(Self: TSiteForm);
var
  mMG: TMultiGrid;
  mFieldDef: TFieldDef;
  i, mLayout, mLine, mOrder: Integer;
  mMGCol: TNxMultiGridBooleanColumn;
  b: Boolean;

  procedure iPreparePosition(ALayout, ALine, ARequestPosition: Integer);
  var
    ii: Integer;
  begin
    for ii:=mMG.ColumnCount-1 downto 0 do
      if (mMG.Columns[ii].Layout = ALayout) and (mMG.Columns[ii].Line = ALine) and
        (mMG.Columns[ii].Order >= ARequestPosition) then
        mMG.Columns[ii].Order := mMG.Columns[ii].Order + 1;
  end;

begin
  mMG := TMultiGrid(NxFindChildControl(Self.GetSiteAppForm, 'grdRows'));
  if Assigned(mMG) then begin
    b := True;
    for i:=mMG.ColumnCount-1 downto 0 do
      if mMG.Columns[i].FieldName = 'X_TransactionID' then
        b := False;
    if b then begin
      mFieldDef := TFieldDef.Create(mMG.DataSource.DataSet.FieldDefs, 'X_TransactionID', ftWideString, 0, False, 301);
      with mFieldDef.CreateField(mMG.DataSource.DataSet, nil, 'X_TransactionID', False) do begin
        ReadOnly:= true;
        FieldName:= 'X_TransactionID';
        FieldKind:= fkData;
      end;
      iPreparePosition(0, 1, 15);
      mMGCol := TNxMultiGridBooleanColumn.Create(mMG.Owner);
      mMGCol.FieldName := 'X_TransactionID';
      mMGCol.Caption := 'Molie';
      mMGCol.ReadOnly := False;
      mMGCol.Kind := ckText;
      mMGCol.Elastic := True;
      mMGCol.Width := 160;
      mMGCol.Layout := 0;
      mMGCol.Line := 1;
      mMGCol.Order := 15;
      mMG.AddColumn(mMGCol);
    end;
  end;
end;



begin
end.