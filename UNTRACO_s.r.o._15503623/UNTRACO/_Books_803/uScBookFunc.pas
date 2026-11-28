uses
  '_Books_803.uScFunc', '_Books_803.uScOLEFunc';

const
  rtIssuedInvoice_BookEntry = 0;
  rtReceivedInvoice_BookEntry = 1;
  rtInternalDocument_BookEntry = 2;
  rtOtherIncome_BookEntry = 3;
  rtOtherExpense_BookEntry = 4;
  rtIssuedCreditNote_BookEntry = 5;
  rtReceivedCreditNote_BookEntry = 6;
  rtCashReceived_BookEntry = 7;
  rtCashPaid_BookEntry = 8;
  rtRefundedCashReceived_BookEntry = 9;
  rtRefundedCashPaid_BookEntry = 10;
  rtBankStatement_BookEntry = 11;
  rtCustomsDeclaration_BookEntry = 12;
  rtExchangeDifference_BookEntry = 13;
  rtReceivedDepositInvoice_BookEntry = 14; //Nezauctovava se, ale je to potreba
  rtIssuedDepositInvoice_BookEntry = 15; //Nezauctovava se, ale je to potreba
  rtBalanceExchangeDifference_BookEntry = 16;
  rtBankAccountExchangeDifference_BookEntry = 17;
  rtCashDeskExchangeDifference_BookEntry = 18;
  rtReceiptCard_BookEntry = 19;
  rtBillOfDelivery_BookEntry = 20;
  rtOutgoingTransfer_BookEntry = 21;
  rtRefundedBillOfDelivery_BookEntry = 22;
  rtIncomingTransfer_BookEntry = 23;
  rtInventoryOverplus_BookEntry = 24;
  rtInventoryShortFall_BookEntry = 25;
  rtReceivedDepositUsage_BookEntry = 26;
  rtIssuedDepositUsage_BookEntry = 27;
  rtCreditNoteAcknowledge_BookEntry = 29;
  rtPOSSummaredDocument_BookEntry = 30;
  rtAssetPutToEvidence_BookEntry = 31;
  rtAssetValueChange_BookEntry = 32;
  rtAssetDiscard_BookEntry = 33;
  rtAssetDepreciation_BookEntry = 34;
  rtCompensation_BookEntry = 35;
  rtPenaltyInvoice_BookEntry = 36;
  rtNotRealizedExchangeDifference_BookEntry = 37;
  rtProductReception_BookEntry = 38;
  rtMaterialDistribution_BookEntry = 39;
  rtRefundedMaterialDistribution_BookEntry = 40;
  rtPOSCashPaid_BookEntry = 41;
  rtPOSCashReceived_BookEntry = 42;
  rtWageClosingBook_BookEntry = 43;
  rtPLMAggregateWorkTicket_BookEntry = 44;
  rtPLMCooperation_BookEntry = 45;
  rtReverseChargeDeclaration_BookEntry = 46;
  rtVATIssuedDepositInvoice_BookEntry = 47;
  rtVATIssuedDepositCreditNote_BookEntry = 48;
  rtVATReceivedDepositInvoice_BookEntry = 49;
  rtVATReceivedDepositCreditNote_BookEntry = 50;
  rtRefundedReceiptCard_BookEntry = 51;
  
  // Parent do tabulky SSkupin
  rtIssuedInvoice_SourceGroup = 200;
  rtReceivedInvoice_SourceGroup = 201;
  rtInternalDocument_SourceGroup = 202;
  rtBookEntry_SourceGroup = 203;
  rtOtherIncome_SourceGroup = 204;
  rtOtherExpense_SourceGroup = 205;
  rtIssuedCreditNote_SourceGroup = 206;
  rtReceivedCreditNote_SourceGroup = 207;
  rtCashReceived_SourceGroup = 208;
  rtCashPaid_SourceGroup = 209;
  rtRefundedCashReceived_SourceGroup = 210;
  rtRefundedCashPaid_SourceGroup = 211;
  rtBankStatement_SourceGroup = 212;
  rtCustomsDeclaration_SourceGroup = 213;
  rtExchangeDifference_SourceGroup = 214;
  rtReceivedDepositInvoice_SourceGroup  = 215;
  rtIssuedDepositInvoice_SourceGroup = 216;
  rtBalanceExchangeDifference_SourceGroup = 217;
  rtBankAccountExchangeDifference_SourceGroup = 218;
  rtCashDeskExchangeDifference_SourceGroup = 219;
  rtReceiptCard_SourceGroup = 220;
  rtBillOfDelivery_SourceGroup = 221;
  rtOutgoingTransfer_SourceGroup = 222;
  rtRefundedBillOfDelivery_SourceGroup = 223;
  rtIncomingTransfer_SourceGroup = 224;
  rtInventoryOverplus_SourceGroup = 225;
  rtInventoryShortFall_SourceGroup = 226;
  rtReceivedDepositUsage_SourceGroup = 227; //Uz se nepouziva - je deklarovano pouze pro update
  rtIssuedDepositUsage_SourceGroup = 228; //Uz se nepouziva - je deklarovano pouze pro update
  rtCreditNoteAcknowledge_SourceGroup = 230;
  rtPOSSummaredDocument_SourceGroup = 231;
  rtAssetPutToEvidence_SourceGroup = 232;
  rtAssetValueChange_SourceGroup = 233;
  rtAssetDiscard_SourceGroup = 234;
  rtAssetDepreciation_SourceGroup =235;
  rtCompensation_SourceGroup = 236;
  rtPenaltyInvoice_SourceGroup = 237;
  rtNotRealizedExchangeDifference_SourceGroup = 238;
  rtProductReception_SourceGroup = 239;
  rtMaterialDistribution_SourceGroup = 240;
  rtRefundedMaterialDistribution_SourceGroup = 241;
  rtPOSCashPaid_SourceGroup = 242;
  rtPOSCashReceived_SourceGroup = 243;
  rtAssetReceipt_SourceGroup = 244;
  rtWageClosingBook_SourceGroup = 245;
  rtProductionTask_SourceGroup = 246;
  rtPLMCooperation_SourceGroup = 247;
  rtPLMAggregateWorkTicket_SourceGroup = 248;
  rtReverseChargeDeclaration_SourceGroup = 249;
  rtVATIssuedDepositInvoice_SourceGroup = 250;
  rtVATIssuedDepositCreditNote_SourceGroup = 251;
  rtVATReceivedDepositInvoice_SourceGroup = 252;
  rtVATReceivedDepositCreditNote_SourceGroup = 253;
  rtRefundedReceiptCard_SourceGroup = 254;

//nejsou tady zohledněny všechny možné případy
function GetBookEntryByDocumentType(ASourceDocumetType: String): Integer;
begin
  if ASourceDocumetType = '00' then
    Result := rtInternalDocument_BookEntry
  else
  if ASourceDocumetType = '01' then
    Result := rtOtherIncome_BookEntry
  else
  if ASourceDocumetType = '02' then
    Result := rtOtherExpense_BookEntry
  else
  if ASourceDocumetType = '03' then
    Result := rtIssuedInvoice_BookEntry
  else
  if ASourceDocumetType = '04' then
    Result := rtReceivedInvoice_BookEntry
  else
  if ASourceDocumetType = '05' then
    Result := rtCashReceived_BookEntry
  else
  if ASourceDocumetType = '06' then
    Result := rtCashPaid_BookEntry
  else
  if ASourceDocumetType = '07' then
    Result := rtRefundedCashReceived_BookEntry
  else
  if ASourceDocumetType = '08' then
    Result := rtRefundedCashPaid_BookEntry
  else
  if ASourceDocumetType = '09' then
    Result := rtBankStatement_BookEntry
  else
  if ASourceDocumetType = '10' then
    Result := rtIssuedDepositInvoice_BookEntry
  else
  if ASourceDocumetType = '11' then
    Result := rtReceivedDepositInvoice_BookEntry
  else
  if ASourceDocumetType = '12' then
    Result := rtCustomsDeclaration_BookEntry
  else
  if ASourceDocumetType = '13' then
    Result := rtExchangeDifference_BookEntry
  else
  if ASourceDocumetType = '14' then
    Result := rtNotRealizedExchangeDifference_BookEntry
  else
  if ASourceDocumetType = '15' then
    Result := rtBalanceExchangeDifference_BookEntry
  else
  if ASourceDocumetType = '16' then
    Result := rtBankAccountExchangeDifference_BookEntry
  else
  if ASourceDocumetType = '19' then
    Result := rtCashDeskExchangeDifference_BookEntry
  else
  if ASourceDocumetType = '60' then
    Result := rtIssuedCreditNote_BookEntry
  else
  if ASourceDocumetType = '61' then
    Result := rtReceivedCreditNote_BookEntry
  else
  if ASourceDocumetType = 'RC' then
    Result := rtReverseChargeDeclaration_BookEntry
  else
    Result := -1;
end;

//nejsou tady zohledněny všechny možné případy
function GetTableByDocumentType(ASourceDocumetType: String): String;
begin
  if ASourceDocumetType = '00' then
    Result := 'InternalDocuments'
  else
  if ASourceDocumetType = '01' then
    Result := 'OtherIncomes'
  else
  if ASourceDocumetType = '02' then
    Result := 'OtherExpenses'
  else
  if ASourceDocumetType = '03' then
    Result := 'IssuedInvoices'
  else
  if ASourceDocumetType = '04' then
    Result := 'ReceivedInvoices'
  else
  if ASourceDocumetType = '05' then
    Result := 'CashReceived'
  else
  if ASourceDocumetType = '06' then
    Result := 'CashPaid'
  else
  if ASourceDocumetType = '07' then
    Result := 'RefundedCashReceived'
  else
  if ASourceDocumetType = '08' then
    Result := 'RefundedCashPaid'
  else
  if ASourceDocumetType = '09' then
    Result := 'BankStatements'
  else
  if ASourceDocumetType = '10' then
    Result := 'IssuedDInvoices'
  else
  if ASourceDocumetType = '11' then
    Result := 'ReceivedDInvoices'
  else
  if ASourceDocumetType = '12' then
    Result := 'CustomsDeclarations'
  else
  if ASourceDocumetType = '13' then
    Result := 'ExchangeDifferences'
  else
  if ASourceDocumetType = '14' then
    Result := 'NotRealizedExDiffs'
  else
  if ASourceDocumetType = '15' then
    Result := 'BalanceExchangeDifferences'
  else
  if ASourceDocumetType = '16' then
    Result := 'BankExchangeDifferences'
  else
  if ASourceDocumetType = '19' then
    Result := 'CashDeskExchangeDifferences'
  else
  if ASourceDocumetType = '60' then
    Result := 'IssuedCreditNotes'
  else
  if ASourceDocumetType = '61' then
    Result := 'ReceivedCreditNotes'
  else
  if ASourceDocumetType = 'RC' then
    Result := 'ReverseChargeDeclarations'
  else
    Result := '';
end;

function GetSideRelation(AOS: TNxCustomObjectSpace; AGetLeftSide:Boolean; ASide_ID: String; ARelDef: Integer): String;
var
  mBookEntry: Integer;
  ss: TStringList;
  i: Integer;
  mSourceSide, mTargetSide: String;
begin
  Result := '';
  ss := TStringList.Create;
  try
    if AGetLeftSide then begin
      mSourceSide := 'RightSide_ID';
      mTargetSide := 'LeftSide_ID';
    end
    else begin
      mSourceSide := 'LeftSide_ID';
      mTargetSide := 'RightSide_ID';
    end;
    AOS.SQLSelect(
      'select R.' + mTargetSide + ' from Relations R ' +
      'where R.' + mSourceSide + ' = ''' + ASide_ID + ''' and ' +
      '  R.Rel_Def = ' + IntToStr(ARelDef), ss);
    if ss.Count > 0 then
      Result := ss[0];
  finally
    ss.Free;
  end;
end;

procedure SetSideRelation(AOS: TNxCustomObjectSpace; ASetLeftSide:Boolean; ASide_ID: String; ARelDef: Integer; AValueID: String);
var
  mBookEntry: Integer;
  mSourceSide, mTargetSide: String;
begin
  if ASetLeftSide then begin
    mSourceSide := 'RightSide_ID';
    mTargetSide := 'LeftSide_ID';
  end
  else begin
    mSourceSide := 'LeftSide_ID';
    mTargetSide := 'RightSide_ID';
  end;
  AOS.SQLExecute(
    'update Relations R set R.' + mTargetSide + ' = ''' + AValueID + '''' +
    'where R.' + mSourceSide + ' = ''' + ASide_ID + ''' and ' +
    '  R.Rel_Def = ' + IntToStr(ARelDef));
end;

//nejsou tady zohledněny všechny možné případy
//pro zálohové listy se dohledávají jejich platby
function GetSourceGroupFromDocID(AOS: TNxCustomObjectSpace; ADocumentType, ADocument_ID: string): String;
var
  mBookEntry: Integer;
  ss, ss2: TStringList;
  i: Integer;
  s: String;
begin
  Result := '';
  ss := TStringList.Create;
  ss2 := TStringList.Create;
  try
    mBookEntry := GetBookEntryByDocumentType(ADocumentType);
    if mBookEntry in [rtReceivedDepositInvoice_BookEntry, rtIssuedDepositInvoice_BookEntry] then begin
      AOS.SQLSelect(
        'select Document_ID || DocumentType from Payments where PDocument_ID = ''' + ADocument_ID + '''', ss);
    end
    else
      ss.Add(ADocument_ID + ADocumentType);
    for i:=0 to ss.Count-1 do begin
      ADocument_ID := Copy(ss[i], 1, 10);
      ADocumentType := Copy(ss[i], 11, 2);
      mBookEntry := GetBookEntryByDocumentType(ADocumentType);
      AOS.SQLSelect(
        'select first 1 GL.AccGroup_ID from GeneralLedger GL ' +
        '  join Relations R on R.LeftSide_ID = ''' + ADocument_ID + ''' and ' +
        '    ((R.Rel_Def = ' + IntToStr(mBookEntry) + ' and GL.Currency_ID = ''CZK'') or ' +
        '     (R.Rel_Def = ' + IntToStr(mBookEntry+100) + ' and GL.Currency_ID <> ''CZK'')) and ' +
        '    GL.ID = R.RightSide_ID', ss2);
      if ss2.Count > 0 then begin
        s := GetSideRelation(AOS, False, ss2[0], rtBookEntry_SourceGroup);
        if Pos(s, Result) = 0 then
          Result := Result + s
      end;
    end;
  finally
    ss2.Free;
    ss.Free;
  end;
end;

//nejsou tady zohledněny všechny možné případy
function CreateSourceGroup(AOS: TNxCustomObjectSpace; ASourceDocumentType, ASource_ID, ATargetDocumentType, ATarget_ID: String): Boolean;
var
  mSGI: TNxCustomBusinessObject;
  mSourceGroup_ID, mTargetGroup_ID: String;
  mSourceTable, mTargetTable: String;
  s: String;
begin
  Result := False;
  mSourceGroup_ID := GetSourceGroupFromDocID(AOS, ASourceDocumentType, ASource_ID);
  mTargetGroup_ID := GetSourceGroupFromDocID(AOS, ATargetDocumentType, ATarget_ID);
  mSourceTable := GetTableByDocumentType(ASourceDocumentType);
  mTargetTable := GetTableByDocumentType(ATargetDocumentType);
  if NxIsEmptyOID(mSourceGroup_ID) or NxIsEmptyOID(mTargetGroup_ID) then
    exit;
  while mTargetGroup_ID <> '' do begin
    s := Copy(mTargetGroup_ID, 1, 10);
    Delete(mTargetGroup_ID, 1, 10);
    mSGI := ObjectSpace.CreateObject('YUWBYZ00JHK433RSBDU5INTEMW');  //SourceGroupIdentical
    try
      mSGI.New;
      mSGI.Prefill;
      mSGI.SetFieldValueAsString('Source_ID', mSourceGroup_ID);
      mSGI.SetFieldValueAsString('Target_ID', s);
      mSGI.Save;
      Result := True;
    finally
      mSGI.Free;
    end;
  end;
end;

begin
end.
