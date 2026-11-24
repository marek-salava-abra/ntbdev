
procedure DTAdd(ACodes, AEnglish: TStringList; ACode, AName: string);
begin
  ACodes.Add(ACode);
  AEnglish.Add(AName);
end;

procedure DTBuildMap(ACodes, AEnglish: TStringList);
begin
  DTAdd(ACodes, AEnglish, '00', 'Internal documents');//OK
  DTAdd(ACodes, AEnglish, '01', 'Other incomes');//OK
  DTAdd(ACodes, AEnglish, '02', 'Other expenses');//OK
  DTAdd(ACodes, AEnglish, '03', 'Invoices out');//OK
  DTAdd(ACodes, AEnglish, '04', 'Invoices in');//OK
  DTAdd(ACodes, AEnglish, '05', 'Cash receipts');//OK
  DTAdd(ACodes, AEnglish, '06', 'Cash payments');//OK
  DTAdd(ACodes, AEnglish, '07', 'Cash receipt returns');//OK
  DTAdd(ACodes, AEnglish, '08', 'Cash payment returns');//OK
  DTAdd(ACodes, AEnglish, '09', 'Bank statements');//OK
  DTAdd(ACodes, AEnglish, '10', 'Deposit bills Out');//OK
  DTAdd(ACodes, AEnglish, '11', 'Deposit bills In');//OK
  //DTAdd(ACodes, AEnglish, '12', 'Single administrative documents');
  DTAdd(ACodes, AEnglish, '13', 'Exchange rate differences');//OK
  DTAdd(ACodes, AEnglish, '14', 'Tax-deductible unrealised FX diff.');//OK  
  DTAdd(ACodes, AEnglish, '15', 'Active and Passive FX differences');//OK
  DTAdd(ACodes, AEnglish, '16', 'Bank account exchange rate differences');//OK
  //DTAdd(ACodes, AEnglish, '17', 'Penalty invoices');
  DTAdd(ACodes, AEnglish, '18', 'Payment orders');//OK
  DTAdd(ACodes, AEnglish, '19', 'Cash register exchange rate differences');//OK
  DTAdd(ACodes, AEnglish, '20', 'Receipt cards');//OK
  DTAdd(ACodes, AEnglish, '21', 'Delivery notes');//OK
  DTAdd(ACodes, AEnglish, '22', 'Bills of transfer - Out');//OK
  DTAdd(ACodes, AEnglish, '23', 'Delivery returns');//OK
  DTAdd(ACodes, AEnglish, '24', 'Bills of transfer - In');//OK
  DTAdd(ACodes, AEnglish, '25', 'Inventory surpluses');//OK
  DTAdd(ACodes, AEnglish, '26', 'Inventory shortfalls');//OK
  DTAdd(ACodes, AEnglish, '27', 'Material issuances to production');//OK
  DTAdd(ACodes, AEnglish, '28', 'Finished product receipts');//OK
  DTAdd(ACodes, AEnglish, '29', 'Material returns from production');//OK
  DTAdd(ACodes, AEnglish, '30', 'Receipt card returns');//OK
  DTAdd(ACodes, AEnglish, '31', 'Stocking in positions');//OK
  DTAdd(ACodes, AEnglish, '32', 'Stocking out of positions');//OK
  DTAdd(ACodes, AEnglish, '33', 'Transfers between positions');//OK
  DTAdd(ACodes, AEnglish, '41', 'Individual payroll records');
  //DTAdd(ACodes, AEnglish, '42', 'Summary payroll records');
  //DTAdd(ACodes, AEnglish, '43', 'Sickness benefits');
  //DTAdd(ACodes, AEnglish, '44', 'Absences');
  //DTAdd(ACodes, AEnglish, '45', 'Annual payroll reconciliation');
  //DTAdd(ACodes, AEnglish, '46', 'Payroll closings');
  //DTAdd(ACodes, AEnglish, '47', 'Payroll payment instructions');
  //DTAdd(ACodes, AEnglish, '48', 'Occupational accidents');
  DTAdd(ACodes, AEnglish, '60', 'Credit notes for invoices out');//OK
  DTAdd(ACodes, AEnglish, '61', 'Credit notes for invoices in');//OK
  DTAdd(ACodes, AEnglish, '62', 'Tax deposit bills Out');//OK
  DTAdd(ACodes, AEnglish, '63', 'Credit notes for tax deposit bills Out');//OK
  DTAdd(ACodes, AEnglish, '64', 'Tax deposit bills In');//OK
  DTAdd(ACodes, AEnglish, '65', 'Credit notes for tax deposit bills In');//OK
  //DTAdd(ACodes, AEnglish, '70', 'Fixed asset recognition');
  //DTAdd(ACodes, AEnglish, '71', 'Fixed asset depreciation');
  //DTAdd(ACodes, AEnglish, '72', 'Fixed asset disposals');
  //DTAdd(ACodes, AEnglish, '73', 'Asset acquisition cost adjustments');
  //DTAdd(ACodes, AEnglish, '74', 'Asset inventory');
  //DTAdd(ACodes, AEnglish, '76', 'Asset acquisitions');
  //DTAdd(ACodes, AEnglish, 'AL', 'Assembly sheets');
  DTAdd(ACodes, AEnglish, 'CA', 'Credit notes for invoices out acknowledgements');//OK
  DTAdd(ACodes, AEnglish, 'CM', 'Reciprocal credits');//OK
  //DTAdd(ACodes, AEnglish, 'CO', 'Subcontracting');
  //DTAdd(ACodes, AEnglish, 'CP', 'POS cash withdrawals');
  //DTAdd(ACodes, AEnglish, 'CR', 'POS cash deposits');
  //DTAdd(ACodes, AEnglish, 'DD', 'Development documentation');
  //DTAdd(ACodes, AEnglish, 'ER', 'Development requests');
  //DTAdd(ACodes, AEnglish, 'GL', 'Food production sheets');
  DTAdd(ACodes, AEnglish, 'IF', 'Offers out');//OK
  DTAdd(ACodes, AEnglish, 'IO', 'Orders out');//OK
  //DTAdd(ACodes, AEnglish, 'JO', 'Production orders');
  //DTAdd(ACodes, AEnglish, 'LR', 'Instalment schedule reminders');
  //DTAdd(ACodes, AEnglish, 'LS', 'Instalment schedules');
  DTAdd(ACodes, AEnglish, 'OR', 'Order out requisitions');//OK
  DTAdd(ACodes, AEnglish, 'PC', 'Mail closings');//OK
  //DTAdd(ACodes, AEnglish, 'PD', 'POS receipts');
  //DTAdd(ACodes, AEnglish, 'PQ', 'Production requests');
  //DTAdd(ACodes, AEnglish, 'PR', 'Sales takings');
  //DTAdd(ACodes, AEnglish, 'PS', 'Summary receipts');
  DTAdd(ACodes, AEnglish, 'RC', 'Reverse charge documents');//OK
  DTAdd(ACodes, AEnglish, 'RO', 'Orders in');//OK
  DTAdd(ACodes, AEnglish, 'RP', 'Payment reminders');//OK
  //DTAdd(ACodes, AEnglish, 'U0', 'Sales advance payment request imports');
  //DTAdd(ACodes, AEnglish, 'U1', 'Purchase advance payment request imports');
  //DTAdd(ACodes, AEnglish, 'WT', 'Summary work tickets');
  //DTAdd(ACodes, AEnglish, 'CU', 'Meal units');
  //DTAdd(ACodes, AEnglish, 'PM', 'POS stock reconciliation sheets');
  //DTAdd(ACodes, AEnglish, 'DS', 'Purchase enquiry sheets');
  //DTAdd(ACodes, AEnglish, 'ID', 'Requests for quotation');
  //DTAdd(ACodes, AEnglish, 'EW', 'Work centre exceptions');
  DTAdd(ACodes, AEnglish, 'DO', 'Documents');//OK
  DTAdd(ACodes, AEnglish, 'P0', 'Sent mail');//OK
  DTAdd(ACodes, AEnglish, 'P1', 'Incoming mail');//OK
  //DTAdd(ACodes, AEnglish, 'PH', 'Sales shift');
  //DTAdd(ACodes, AEnglish, 'CN', 'Unposted POS cash withdrawals');
  //DTAdd(ACodes, AEnglish, 'CT', 'Unposted POS cash deposits');
  DTAdd(ACodes, AEnglish, 'MI', 'Main inventory protocols');//OK
  DTAdd(ACodes, AEnglish, 'PI', 'Partial inventory protocols');//OK
  //DTAdd(ACodes, AEnglish, 'BP', 'Work in progress adjustments');
  //DTAdd(ACodes, AEnglish, 'FP', 'Finished products');
  DTAdd(ACodes, AEnglish, 'CC', 'Customs export confirmations');//OK
  DTAdd(ACodes, AEnglish, 'PO', 'Payment order lines');//OK
  DTAdd(ACodes, AEnglish, '36', 'Replacements - issuances');//OK
  DTAdd(ACodes, AEnglish, '37', 'Replacements - receipts');//OK
  DTAdd(ACodes, AEnglish, '38', 'Changes - issuances');//OK
  DTAdd(ACodes, AEnglish, '39', 'Changes - receipts');//OK  
  DTAdd(ACodes, AEnglish, 'CS', 'Contracts');//OK
  //DTAdd(ACodes, AEnglish, 'GR', 'GDPR requests');
  DTAdd(ACodes, AEnglish, 'PL', 'Picking lists');//OK
  DTAdd(ACodes, AEnglish, 'EL', 'Dispatch notes');//OK
  DTAdd(ACodes, AEnglish, 'GI', 'General contracts - sale');//OK
  DTAdd(ACodes, AEnglish, 'GO', 'General contracts - purchase');//OK
  DTAdd(ACodes, AEnglish, 'LO', 'Logs');//OK
  DTAdd(ACodes, AEnglish, 'CG', 'Campaigns');//OK
  DTAdd(ACodes, AEnglish, 'OE', 'Sent emails');//OK
  DTAdd(ACodes, AEnglish, 'DE', 'Delivered emails');//OK
  DTAdd(ACodes, AEnglish, 'DC', 'Requests on expenses approval');//OK
  DTAdd(ACodes, AEnglish, 'DA', 'Approved expenses');//OK
  //DTAdd(ACodes, AEnglish, 'SL', 'Service sheets');
  //DTAdd(ACodes, AEnglish, 'MO', 'Installation sheets');
  //DTAdd(ACodes, AEnglish, 'ZZ', 'User-defined documents');
end;

procedure TranslateDocumentTypesEN(AOS: TNxCustomObjectSpace);
var
  mCodes, mEnglish: TStringList;
  mBO: TNxCustomBusinessObject;
  mID: string;
  i: Integer;
begin
  mCodes := TStringList.Create;
  mEnglish := TStringList.Create;
  try
    DTBuildMap(mCodes, mEnglish);
    AOS.StartTransaction(taReadCommited);
    try
      for i := 0 to mCodes.Count - 1 do
      begin
        mID := AOS.SQLSelectFirstAsString(
          'SELECT ID FROM DocumentTypes WHERE Code = '+QuotedStr(mCodes[i]));
        if NxIsEmptyOID(mID) then
          Continue;
        mBO := AOS.CreateObject(Class_DocumentType);
        try
          mBO.ExplicitTransaction := True;
          mBO.Load(mID, nil);
          if mBO.GetFieldValueAsString('Name') <> mEnglish[i] then
          begin
            mBO.SetFieldValueAsString('Name', mEnglish[i]);
            mBO.Save;
          end;
        finally
          mBO.Free;
        end;
      end;
      AOS.Commit;
    except
      AOS.RollBack;
      RaiseException(ExceptionMessage);
    end;
  finally
    mEnglish.Free;
    mCodes.Free;
  end;
end;

procedure TranslateDocumentTypesENClick(Sender: TObject);
var
  mSite: TSiteForm;
begin
  mSite := NxFindSiteForm(TComponent(Sender));
  if NxMessageBox('Překlad typů dokladů',
    'Chcete přeložit názvy typů dokladů do angličtiny?',
    mdConfirm, mdbYesNo, mrNo, 0, False, mSite.GetSiteAppForm) = mrYes then
    TranslateDocumentTypesEN(mSite.BaseObjectSpace);
end;

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TAction;
begin
  mAction := Self.GetNewAction;
  mAction.Name := 'actTranslateDocumentTypesEN';
  mAction.Caption := 'Přeložit do angličtiny';
  mAction.Hint := 'Přeloží názvy typů dokladů do angličtiny podle mapy';
  mAction.Category := 'tabList';
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.OnExecute := @TranslateDocumentTypesENClick;
end;

begin
end.
