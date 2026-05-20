////////////////////////////////////////////////////////////////////////////////
//Pomocí procedury vytvoříme vazbu
procedure Relation_CreateAndSave(cObj: TNxCustomObjectSpace;ARelDef : integer; ALeftSide_ID: string; ARightSide_ID: TNxOID; ANumValue: integer = 0);
var
  mRelace: TNxCustomBusinessObject;
begin
  mRelace := cObj.CreateObject(Class_Relation);
  if Assigned(mRelace) then begin
    try
      mRelace.ExplicitTransaction:= cObj.InTransaction;
      mRelace.New;
      mRelace.Prefill;
      mRelace.SetFieldValueAsInteger('REL_DEF'     , ARelDef);
      mRelace.SetFieldValueAsString ('LEFTSIDE_ID' , ALeftSide_ID);
      mRelace.SetFieldValueAsString ('RIGHTSIDE_ID', ARightSide_ID);
      mRelace.SetFieldValueAsFloat  ('NUMVALUE'    , ANumValue);
      mRelace.Save;
    finally;
      mRelace.free;
    end;
  end
end;
////////////////////////////////////////////////////////////////////////////////

//KUBA - POZOR: logika konstant je obracena.
//Priklad: rtBillOfDelivery_PDMIssuedDoc
//-pripojeni vydejky k odeslane poste
//leva strana: odeslana posta
//prava strana: vydejka

const
  // Zadne z konstant jiz nemenit id !!!
  // Groupy od nuly
  rgAccounting = 0;
  rgSourceGroup = 1;
  rgBalance = 2;
  rgAccountingCurrency = 3;
  rgDocs = 4;
  rgGathering = 5;
  rgGatheringCurrency = 6;
  rgCRMActivityDocs = 7; // lubi
  rgPDMIssuedDocs = 8;
  rgPDMReceivedDocs = 9;
  rgSoftLinks = 10;
  rgGatheringExchangeDiff = 11;
  rgCorrectionRowLinks = 12;
// FLORES Start
  rgIssuedInvoicesDocs = 100;
  rgReceivedInvoicesDocs = 101;
  rgOtherIncomesDocs = 102;
  rgOtherExpensesDocs = 103;
  rgReceivedOrdersDocs = 104;
  rgIssuedOrdersDocs = 105;
  rgBillsOfDeliveryDocs = 106;
  rgReceiptCardsDocs = 107;
  rgOutgoingTransfersDocs = 108;
  rgIncomingTransfersDocs = 109;
  rgInventoryShortFallsDocs = 110;
  rgInventoryOverplusesDocs = 111;
  rgDistributionsDocs = 112;
  rgConsignmentReportsDocs = 113;
  rgRemovalListsDocs = 114;
  rgShippingListsDocs = 115;
  rgCustomsDeclarationsDocs = 116;
  rgWageNoticesDocs = 117;
  rgCashReceivedDocs = 118;
  rgCashPaidDocs = 119;
// FLORES Stop

  rtUnknown = -1;
  // Zauc. do deniku
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
  rtPOSCashNotAccountedPaid_BookEntry = 53;
  rtPLMBalanceInProcessProduce_BookEntry = 54;
  rtPLMFinishedProduct_BookEntry = 55;

// FLORES Start
  rtPRFJobOrderAggregateOperation_BookEntry = 70;
  rtPRFJobOrder_BookEntry = 71;
// FLORES Stop

  AccountingCurrencyConst = 100;

  // hodnota vazby v cizi mene - totez co vazby od 0 do 100, ale + AccountingCurrencyConst

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
  rtPOSCashNotAccountedPaid_SourceGroup = 256;
  rtPLMBalanceInProcessProduce_SourceGroup = 257;
  rtPLMFinishedProduct_SourceGroup = 258;

// FLORES Start
  rtPRFJobOrderAggregateOperation_SourceGroup = 270;
  rtPRFJobOrderRoutine_SourceGroup = 271;
  rtPRFJobOrder_SourceGroup = 272;
  rtDistributionPlan_SourceGroup = 273;
  rtDistribution_SourceGroup = 274;
  rtConsignmentReport_SourceGroup = 275;
  rtRemovalList_SourceGroup = 276;
  rtShippingList_SourceGroup = 277;
// FLORES Stop

  // Závěrkové kurzové rozdíly
  rtBalance_Balance = 400;

  // Doklady s Dokumenty
  rtIssuedInvoice_Doc = 600;
  rtReceivedInvoice_Doc = 601;
  rtInternalDocument_Doc = 602;
  rtOtherIncome_Doc = 603;
  rtOtherExpense_Doc = 604;
  rtIssuedCreditNote_Doc = 605;
  rtReceivedCreditNote_Doc = 606;
  rtCashReceived_Doc = 607;
  rtCashPaid_Doc = 608;
  rtRefundedCashReceived_Doc = 609;
  rtRefundedCashPaid_Doc = 610;
  rtBankStatement_Doc = 611;
  rtCustomsDeclaration_Doc = 612;
  rtExchangeDifference_Doc = 613;
  rtReceivedDepositInvoice_Doc = 614;
  rtIssuedDepositInvoice_Doc = 615;
  rtBalanceExchangeDifference_Doc = 616;
  rtBankAccountExchangeDifference_Doc = 617;
  rtCashDeskExchangeDifference_Doc = 618;
  rtReceiptCard_Doc = 619;
  rtBillOfDelivery_Doc = 620;
  rtOutgoingTransfer_Doc = 621;
  rtRefundedBillOfDelivery_Doc = 622;
  rtIncomingTransfer_Doc = 623;
  rtInventoryOverplus_Doc = 624;
  rtInventoryShortFall_Doc = 625;
//  rtReceivedDepositUsage_Doc = 626;
//  rtIssuedDepositUsage_Doc = 627;
  rtCreditNoteAcknowledge_Doc = 628;
//  rtBookEntry_Doc = 629;
  rtDevBug_Doc = 630;
  rtDevDoc_Doc = 631;
  rtIssuedOrder_Doc = 632;
  rtReceivedOrder_Doc = 633;
  rtPaymentOrder_Doc = 634;
  rtPenaltyInvoice_Doc = 635;
  rtPaymentReminder_Doc = 636;
//  rtRepeatedBankPayment_Doc = 635;
  rtAssetCard_Doc = 637;
  rtAssetPutToEvidence_Doc = 638;
  rtAssetValueChange_Doc = 639;
  rtAssetDiscard_Doc = 640;
  rtAssetReceipt_Doc = 641;
  rtAssetSmallCard_Doc = 642;
  rtAssetLeasingCard_Doc = 643;
  rtNotRealizedExchangeDifference_Doc = 644;
  rtEmployee_Doc = 645;
  rtWorkingRelation_Doc = 646;
  rtProductReception_Doc = 647;
  rtMaterialDistribution_Doc = 648;
  rtRefundedMaterialDistribution_Doc = 649;
  rtFirm_Doc = 650;
  rtPerson_Doc = 651;
  rtStoreCard_Doc = 652;
  rtSickBenefit_Doc = 653;
  rtWageClosingBook_Doc = 654;
  rtPLMRoutine_Doc = 655;
  rtPLMPieceList_Doc = 656;
  rtPLMProduceRequest_Doc = 657;
  rtPLMJobOrder_Doc = 658;
  rtPLMProduceService_Doc = 659;
  rtPLMJobOrdersNotice_Doc = 660;
  rtPLMCooperation_Doc = 661;
  rtReverseChargeDeclaration_Doc = 662;
  rtVATIssuedDepositInvoice_Doc = 663;
  rtVATIssuedDepositCreditNote_Doc = 664;
  rtVATReceivedDepositInvoice_Doc = 665;
  rtVATReceivedDepositCreditNote_Doc = 666;
  rtPLMOperation_Doc = 667;
  rtPDMIssuedDoc_Doc = 668;
  rtPDMReceivedDoc_Doc = 669;
  rtStoreBatches_Doc = 670;
  rtAbsences_Doc = 671;
  rtCRMActivities_Doc = 672;
  rtRefundedReceiptCard_Doc = 673;
  rtOtherRecord_Doc = 674;
  rtIssuedOffer_Doc = 675;
  rtLogStoreInput_Doc = 676;
  rtLogStoreOutput_Doc = 677;
  rtLogStoreTransfer_Doc = 678;
  rtBusOrder_Doc = 679;
  rtBusTransaction_Doc = 680;
  rtBusProject_Doc = 681;
  rtWorkingInjury_Doc = 682;
  rtServicedObjects_Doc = 683;
  rtServiceDocument_Doc = 684;
  rtServiceAssemblyForm_Doc = 685;
  rtCDConfrim_Doc = 686;
  rtServicedObjectType_Doc = 687;
  rtCompensation_Doc = 688;
  rtOutgoingSubstitution_Doc = 768;
  rtIncomingSubstitution_Doc = 769;
  rtOutgoingTransformation_Doc = 770;
  rtIncomingTransformation_Doc = 771;
// FLORES Start
  rtPMEvent_Doc = 800;
  rtPRFJobOrderRoutine_Doc = 801;
  rtPRFJobOrder_Doc = 802;
  rtPRFVariant_Doc = 803;
  rtIssuedDemands_Doc = 804;
  rtConsignmentReport_Doc = 805;
  rtRemovalList_Doc = 806;
  rtShippingList_Doc = 807;
  rtFirmOffice_Doc = 808;
  rtOfferedItem_Doc = 809;
  rtWageNotice_Doc = 810;
  rtTRMDriver_Doc = 811;
  rtTRMCar_Doc = 812;
  rtPRFWorkshopSchedule_Doc = 813;
  rtPRFRoutine_Doc = 814;
  rtPRFGang_Doc = 815;
  rtPRFModel_Doc = 816;
// FLORES Stop

  //Vazby mezi dokladem pořízení majetku a dokladem ze kterého se pořízení čerpá.
  rtAssetReceipt_ReceivedInvoice = 1000;
  rtAssetReceipt_CashPaid = 1001;
  rtAssetReceipt_OtherExpense = 1002;
  rtAssetReceipt_CustomsDeclarations = 1009;
  rtAssetReceipt_VATReceivedDInvoice = 1019;
  //
  rtAssetValueChange_ReceivedInvoice = 1003;
  rtAssetValueChange_CashPaid = 1004;
  rtAssetValueChange_OtherExpense = 1005;
  rtAssetValueChange_CustomsDeclarations = 1010;
  rtAssetValueChange_VATReceivedDInvoice = 1020;
// FLORES Start
  rtAssetValueChange_BillOfDelivery = 1050;
  //Výroba PRF
  rtPRFJobOrderRoutine_IssuedOrder = 1051;
//  rtPRFJobOrder_OutgoingTransfer = 1052;
//  rtPRFJobOrder_IncomingTransfer = 1053;
// FLORES Stop
  // Skladová příjemka
  rtReceiptCard_ReceivedInvoice = 1011;
  rtReceiptCard_CashPaid = 1012;
  rtReceiptCard_OtherExpense = 1013;
  rtReceiptCard_CustomsDeclarations = 1014;
  rtReceiptCard_VATReceivedDInvoice = 1021;
  // Kooperace
  rtPLMCooperation_ReceivedInvoice = 1015;
  rtPLMCooperation_CashPaid = 1016;
  rtPLMCooperation_OtherExpense = 1017;
  rtPLMCooperation_CustomsDeclarations = 1018;
  rtPLMCooperation_VATReceivedDInvoice = 1022;
  // Vratka skl. prijemky
  rtRefundedReceiptCard_ReceivedInvoice = 1030;
  rtRefundedReceiptCard_ReceivedCreditNote = 1031;
  rtRefundedReceiptCard_CashPaid = 1032;
  rtRefundedReceiptCard_RefundedCashPaid = 1033;
  rtRefundedReceiptCard_OtherExpense = 1034;
  //


  GatheringCurrencyConst = 100; // hodnota vazby v cizi mene - totez co vazby od 0 do 99, ale + GatheringCurrencyConst
  GatheringExchangeDiffConst = 1000; // vazba kurzovního rozdílu - totez co vazby od 0 do 99, vazba je v lok. měně

  // Doklady k aktivitam
  rtIssuedInvoice_CRMActivityDoc = 1200;
  rtReceivedInvoice_CRMActivityDoc = 1201;
  rtInternalDocument_CRMActivityDoc = 1202;
  rtOtherExpense_CRMActivityDoc = 1203;
  rtOtherIncome_CRMActivityDoc = 1204;
  rtDepreciation_CRMActivityDoc = 1205;
  rtPutToEvidence_CRMActivityDoc = 1206;
  rtAssetReceipt_CRMActivityDoc = 1207;
  rtBankStatement_CRMActivityDoc = 1209;
  rtPaymentOrder_CRMActivityDoc = 1210;
  rtCashPaid_CRMActivityDoc = 1212;
  rtCashReceived_CRMActivityDoc = 1213;
  rtRefundedCashPaid_CRMActivityDoc = 1214;
  rtRefundedCashReceived_CRMActivityDoc = 1215;
  rtDevBugs_CRMActivityDoc = 1216;
  rtDevDocs_CRMActivityDoc = 1217;
  rtBalanceExchangeDifference_CRMActivityDoc = 1218;
  rtCustomsDeclaration_CRMActivityDoc = 1219;
  rtExchangeDifference_CRMActivityDoc = 1220;
  rtNotRealizedExchangeDifference_CRMActivityDoc = 1221;
  rtCompensation_CRMActivityDoc = 1222;
  rtCreditNotesAcknowledges_CRMActivityDoc = 1223;
  rtIssuedDepositInvoice_CRMActivityDoc = 1224;
  rtPenaltyInvoice_CRMActivityDoc = 1225;
  rtPaymentReminder_CRMActivityDoc = 1226;
  rtReceivedCreditNote_CRMActivityDoc = 1227;
  rtReceivedDepositInvoice_CRMActivityDoc = 1228;
  rtDocuments_CRMActivityDoc = 1229;
  rtIssuedOrders_CRMActivityDoc = 1230;
  rtReceivedOrders_CRMActivityDoc = 1231;
  rtPosCashPaid_CRMActivityDoc = 1233;
  rtPosCashReceived_CRMActivityDoc = 1234;
  rtPosReceipts_CRMActivityDoc = 1236;
  rtPOSSummaredDocuments_CRMActivityDoc = 1237;
  rtBillOfDelivery_CRMActivityDoc = 1238;
  rtIncomingTransfer_CRMActivityDoc = 1239;
  rtInventoryOverplus_CRMActivityDoc = 1240;
  rtInventoryShortFall_CRMActivityDoc = 1241;
  rtMaterialDistribution_CRMActivityDoc = 1242;
  rtOutgoingTransfer_CRMActivityDoc = 1243;
  rtProductReception_CRMActivityDoc = 1244;
  rtReceiptCard_CRMActivityDoc = 1245;
  rtRefundedBillOfDelivery_CRMActivityDoc = 1246;
  rtRefundedMaterialDistribution_CRMActivityDoc = 1247;
  rtAbsence_CRMActivityDoc = 1248;
  rtAnnualClearing_CRMActivityDoc = 1249;
  rtWageClosing_CRMActivityDoc = 1250;
  rtWageListsCommon_CRMActivityDoc = 1251;
  rtWageListsPartial_CRMActivityDoc = 1252;
  rtAssetValueChange_CRMActivityDoc = 1253;
  rtAssetDiscard_CRMActivityDoc = 1254;
  rtIssuedCreditNote_CRMActivityDoc = 1255;
  rtLoanSchedule_CRMActivityDoc = 1256;
  rtPLMJobOrder_CRMActivityDoc = 1257;
  rtPLMProduceRequest_CRMActivityDoc = 1258;
  rtPLMCooperation_CRMActivityDoc = 1259;
  rtPLMAggregateWorkTicket_CRMActivityDoc = 1260;
  rtSickBenefit_CRMActivityDoc = 1261;
  rtReverseChargeDeclaration_CRMActivityDoc = 1262;
  rtVATIssuedDepositInvoice_CRMActivityDoc = 1263;
  rtVATIssuedDepositCreditNote_CRMActivityDoc = 1264;
  rtVATReceivedDepositInvoice_CRMActivityDoc = 1265;
  rtVATReceivedDepositCreditNote_CRMActivityDoc = 1266;
  rtRefundedReceiptCard_CRMActivityDoc = 1267;
  rtPDMIssuedDoc_CRMActivityDoc = 1268;
  rtPDMReceivedDoc_CRMActivityDoc = 1269;
  rtIssuedOffers_CRMActivityDoc = 1270;
  rtEmailsReceived_CRMActivityDoc = 1271;
  rtEmailsSent_CRMActivityDoc = 1272;
  rtPOSCashNotAccountedPaid_CRMActivityDoc = 1273;
// FLORES Start
  rtPRFWorkshopSchedules_CRMActivityDoc           = 1274;
  rtPRFJobOrderAggregateOperations_CRMActivityDoc = 1275;
  rtPRFJobOrders_CRMActivityDoc                   = 1276;
  rtPRFLogs_CRMActivityDoc                        = 1277;
  rtDistributionPlans_CRMActivityDoc              = 1278;
  rtDistributions_CRMActivityDoc                  = 1279;
  rtConsignmentReports_CRMActivityDoc             = 1280;
  rtRemovalLists_CRMActivityDoc                   = 1281;
  rtShippingLists_CRMActivityDoc                  = 1282;
  rtCustomsDeclarations_CRMActivityDoc            = 1283;
  rtCRMActivities_CRMActivityDoc                  = 1284;
// FLORES Stop

  //Doklady k Odeslané poště
  rtIssuedInvoice_PDMIssuedDoc = 1400;
  rtReceivedInvoice_PDMIssuedDoc = 1401;
  rtInternalDocument_PDMIssuedDoc = 1402;
  rtOtherExpense_PDMIssuedDoc = 1403;
  rtOtherIncome_PDMIssuedDoc = 1404;
  rtDepreciation_PDMIssuedDoc = 1405;
  rtPutToEvidence_PDMIssuedDoc = 1406;
  rtAssetReceipt_PDMIssuedDoc = 1407;
  rtBankStatement_PDMIssuedDoc = 1409;
  rtPaymentOrder_PDMIssuedDoc = 1410;
  rtCashPaid_PDMIssuedDoc = 1412;
  rtCashReceived_PDMIssuedDoc = 1413;
  rtRefundedCashPaid_PDMIssuedDoc = 1414;
  rtRefundedCashReceived_PDMIssuedDoc = 1415;
  rtDevBugs_PDMIssuedDoc = 1416;
  rtDevDocs_PDMIssuedDoc = 1417;
  rtBalanceExchangeDifference_PDMIssuedDoc = 1418;
  rtCustomsDeclaration_PDMIssuedDoc = 1419;
  rtExchangeDifference_PDMIssuedDoc = 1420;
  rtNotRealizedExchangeDifference_PDMIssuedDoc = 1421;
  rtCompensation_PDMIssuedDoc = 1422;
  rtCreditNotesAcknowledges_PDMIssuedDoc = 1423;
  rtIssuedDepositInvoice_PDMIssuedDoc = 1424;
  rtPenaltyInvoice_PDMIssuedDoc = 1425;
  rtPaymentReminder_PDMIssuedDoc = 1426;
  rtReceivedCreditNote_PDMIssuedDoc = 1427;
  rtReceivedDepositInvoice_PDMIssuedDoc = 1428;
  rtDocuments_PDMIssuedDoc = 1429;
  rtIssuedOrders_PDMIssuedDoc = 1430;
  rtReceivedOrders_PDMIssuedDoc = 1431;
  rtPosCashPaid_PDMIssuedDoc = 1433;
  rtPosCashReceived_PDMIssuedDoc = 1434;
  rtPosReceipts_PDMIssuedDoc = 1436;
  rtPOSSummaredDocuments_PDMIssuedDoc = 1437;
  rtBillOfDelivery_PDMIssuedDoc = 1438;
  rtIncomingTransfer_PDMIssuedDoc = 1439;
  rtInventoryOverplus_PDMIssuedDoc = 1440;
  rtInventoryShortFall_PDMIssuedDoc = 1441;
  rtMaterialDistribution_PDMIssuedDoc = 1442;
  rtOutgoingTransfer_PDMIssuedDoc = 1443;
  rtProductReception_PDMIssuedDoc = 1444;
  rtReceiptCard_PDMIssuedDoc = 1445;
  rtRefundedBillOfDelivery_PDMIssuedDoc = 1446;
  rtRefundedMaterialDistribution_PDMIssuedDoc = 1447;
  rtAbsence_PDMIssuedDoc = 1448;
  rtAnnualClearing_PDMIssuedDoc = 1449;
  rtWageClosing_PDMIssuedDoc = 1450;
  rtWageListsCommon_PDMIssuedDoc = 1451;
  rtWageListsPartial_PDMIssuedDoc = 1452;
  rtAssetValueChange_PDMIssuedDoc = 1453;
  rtAssetDiscard_PDMIssuedDoc = 1454;
  rtIssuedCreditNote_PDMIssuedDoc = 1455;
  rtLoanSchedule_PDMIssuedDoc = 1456;
  rtPLMJobOrder_PDMIssuedDoc = 1457;
  rtPLMProduceRequest_PDMIssuedDoc = 1458;
  rtPLMCooperation_PDMIssuedDoc = 1459;
  rtPLMAggregateWorkTicket_PDMIssuedDoc = 1460;
  rtSickBenefit_PDMIssuedDoc = 1461;
  rtReverseChargeDeclaration_PDMIssuedDoc = 1462;
  rtVATIssuedDepositInvoice_PDMIssuedDoc = 1463;
  rtVATIssuedDepositCreditNote_PDMIssuedDoc = 1464;
  rtVATReceivedDepositInvoice_PDMIssuedDoc = 1465;
  rtVATReceivedDepositCreditNote_PDMIssuedDoc = 1466;
  rtCRMActivity_PDMIssuedDoc = 1467;
  rtRefundedReceiptCard_PDMIssuedDoc = 1468;
  rtIssuedOffers_PDMIssuedDoc = 1469;
  rtPosCashNotAccountedPaid_PDMIssuedDoc = 1470;
// FLORES Start
  rtDistributionPlan_PDMIssuedDoc = 1471;
  rtDistribution_PDMIssuedDoc = 1472;
  rtConsignmentReport_PDMIssuedDoc = 1473;
  rtRemovalList_PDMIssuedDoc = 1474;
  rtShippingList_PDMIssuedDoc = 1475;
// FLORES Stop

  //Doklady k Poště došlé
  rtIssuedInvoice_PDMReceivedDoc = 1500;
  rtReceivedInvoice_PDMReceivedDoc = 1501;
  rtInternalDocument_PDMReceivedDoc = 1502;
  rtOtherExpense_PDMReceivedDoc = 1503;
  rtOtherIncome_PDMReceivedDoc = 1504;
  rtDepreciation_PDMReceivedDoc = 1505;
  rtPutToEvidence_PDMReceivedDoc = 1506;
  rtAssetReceipt_PDMReceivedDoc = 1507;
  rtBankStatement_PDMReceivedDoc = 1509;
  rtPaymentOrder_PDMReceivedDoc = 1510;
  rtCashPaid_PDMReceivedDoc = 1512;
  rtCashReceived_PDMReceivedDoc = 1513;
  rtRefundedCashPaid_PDMReceivedDoc = 1514;
  rtRefundedCashReceived_PDMReceivedDoc = 1515;
  rtDevBugs_PDMReceivedDoc = 1516;
  rtDevDocs_PDMReceivedDoc = 1517;
  rtBalanceExchangeDifference_PDMReceivedDoc = 1518;
  rtCustomsDeclaration_PDMReceivedDoc = 1519;
  rtExchangeDifference_PDMReceivedDoc = 1520;
  rtNotRealizedExchangeDifference_PDMReceivedDoc = 1521;
  rtCompensation_PDMReceivedDoc = 1522;
  rtCreditNotesAcknowledges_PDMReceivedDoc = 1523;
  rtIssuedDepositInvoice_PDMReceivedDoc = 1524;
  rtPenaltyInvoice_PDMReceivedDoc = 1525;
  rtPaymentReminder_PDMReceivedDoc = 1526;
  rtReceivedCreditNote_PDMReceivedDoc = 1527;
  rtReceivedDepositInvoice_PDMReceivedDoc = 1528;
  rtDocuments_PDMReceivedDoc = 1529;
  rtIssuedOrders_PDMReceivedDoc = 1530;
  rtReceivedOrders_PDMReceivedDoc = 1531;
  rtPosCashPaid_PDMReceivedDoc = 1533;
  rtPosCashReceived_PDMReceivedDoc = 1534;
  rtPosReceipts_PDMReceivedDoc = 1536;
  rtPOSSummaredDocuments_PDMReceivedDoc = 1537;
  rtBillOfDelivery_PDMReceivedDoc = 1538;
  rtIncomingTransfer_PDMReceivedDoc = 1539;
  rtInventoryOverplus_PDMReceivedDoc = 1540;
  rtInventoryShortFall_PDMReceivedDoc = 1541;
  rtMaterialDistribution_PDMReceivedDoc = 1542;
  rtOutgoingTransfer_PDMReceivedDoc = 1543;
  rtProductReception_PDMReceivedDoc = 1544;
  rtReceiptCard_PDMReceivedDoc = 1545;
  rtRefundedBillOfDelivery_PDMReceivedDoc = 1546;
  rtRefundedMaterialDistribution_PDMReceivedDoc = 1547;
  rtAbsence_PDMReceivedDoc = 1548;
  rtAnnualClearing_PDMReceivedDoc = 1549;
  rtWageClosing_PDMReceivedDoc = 1550;
  rtWageListsCommon_PDMReceivedDoc = 1551;
  rtWageListsPartial_PDMReceivedDoc = 1552;
  rtAssetValueChange_PDMReceivedDoc = 1553;
  rtAssetDiscard_PDMReceivedDoc = 1554;
  rtIssuedCreditNote_PDMReceivedDoc = 1555;
  rtLoanSchedule_PDMReceivedDoc = 1556;
  rtPLMJobOrder_PDMReceivedDoc = 1557;
  rtPLMProduceRequest_PDMReceivedDoc = 1558;
  rtPLMCooperation_PDMReceivedDoc = 1559;
  rtPLMAggregateWorkTicket_PDMReceivedDoc = 1560;
  rtSickBenefit_PDMReceivedDoc = 1561;
  rtReverseChargeDeclaration_PDMReceivedDoc = 1562;
  rtVATIssuedDepositInvoice_PDMReceivedDoc = 1563;
  rtVATIssuedDepositCreditNote_PDMReceivedDoc = 1564;
  rtVATReceivedDepositInvoice_PDMReceivedDoc = 1565;
  rtVATReceivedDepositCreditNote_PDMReceivedDoc = 1566;
  rtCRMActivity_PDMReceivedDoc = 1567;
  rtRefundedReceiptCard_PDMReceivedDoc = 1568;
  rtIssuedOffers_PDMReceivedDoc = 1569;
  rtPOSCashNotAccountedPaid_PDMReceivedDoc = 1570;
// FLORES Start
  rtDistributionPlan_PDMReceivedDoc = 1571;
  rtDistribution_PDMReceivedDoc = 1572;
  rtConsignmentReport_PDMReceivedDoc = 1573;
  rtRemovalList_PDMReceivedDoc = 1574;
  rtShippingList_PDMReceivedDoc = 1575;
// FLORES Stop

  // SoftVazby
  // Pozor !!! Cislovat ob jednu, protoze registrace je dvojitá, viz. NxRegisterSoftLinkRelation().
  rtIncomingTransferToBillOfDelivery_SoftLink = 1600;
  rtReceiptCardToIssuedInvoice_SoftLink = 1602;
  rtReceiptCardToCashReceived_SoftLink = 1604;
  rtReceiptCardToBillOfDelivery_SoftLink = 1606;
  rtReceivedOrderToIssuedOrder_SoftLink = 1608;
  rtBillOfDeliveryToSPMAssemblyList_SoftLink = 1610;
  rtReceivedOrderToSPMAssemblyList_SoftLink = 1612;
  rtSPMAssemblyListToIssuedInvoice_SoftLink = 1614;
  rtIssuedDepositInvoiceToBillOfDelivery_SoftLink = 1616;
  rtBillOfDeliveryToGPMAssemblyList_SoftLink = 1618;
  rtReceivedOrderToPLMProduceRequest_SoftLink = 1620;
  rtReceivedOrderToGPMAssemblyList_SoftLink = 1622;
  rtGPMAssemblyListToIssuedInvoice_SoftLink = 1624;
  rtIssuedOrderToReceivedInvoice_SoftLink = 1626;
  rtIssuedOrderToCashPaid_SoftLink = 1628;
  rtIssuedOrderToOtherExpense_SoftLink = 1630;
  rtDemandSheetToIssuedOrder_SoftLink = 1632;
  rtIssuedDemandToIssuedOrder_SoftLink = 1634;
  rtSPMAssemblyListToIssuedOrder_SoftLink = 1636;
  rtGPMAssemblyListToIssuedOrder_SoftLink = 1638;
  rtSPMAssemblyListToReceiptCard_SoftLink = 1640;
  rtGPMAssemblyListToReceiptCard_SoftLink = 1642;
  rtSPMAssemblyListToInventoryOverplus_SoftLink = 1644;
  rtGPMAssemblyListToInventoryOverplus_SoftLink = 1646;
  rtReceiptCardToOutgoingTransfer_SoftLink = 1648;
  rtProductReceptionToBillOfDelivery_SoftLink = 1650;
  rtBillOfDeliveryToGPMCateringUnit_SoftLink = 1652;
  rtRefundedBillOfDeliveryToGPMCateringUnit_SoftLink = 1654;

  rtDocumentToReceivedDepositInvoice_SoftLink = 1656;
  rtDocumentToVATReceivedDepositInvoice_SoftLink = 1658;
  rtDocumentToVATReceivedDepositCreditNote_SoftLink = 1660;
  rtDocumentToReceivedInvoice_SoftLink = 1662;
  rtDocumentToReceiptCard_SoftLink = 1664;
  rtDocumentToReceivedCreditNote_SoftLink = 1666;
  rtDocumentToRefundedReceiptCard_SoftLink = 1668;

  rtDocumentToIssuedInvoice_SoftLink = 1670;
  rtDocumentToIssuedCreditNote_SoftLink = 1672;
  rtDocumentToIssuedDepositInvoice_SoftLink = 1674;
  rtDocumentToVATIssuedDepositInvoice_SoftLink = 1676;
  rtDocumentToVATIssuedDepositCreditNote_SoftLink = 1678;

  rtPOSDocumentToPOSMirror_SoftLink = 1680;
  rtDocumentToIssuedOrder_SoftLink = 1682;
  rtMaterialDistributionToGPMCateringUnit_SoftLink = 1684;

  rtDocumentToEmailSent_SoftLink = 1686;
  // Vazba kompletačního listu a převodky příjem
  rtSPMAssemblyListToIncomingTransfer_SoftLink = 1688;
  // Vazba kompletačního listu a převodky výdej
  rtSPMAssemblyListToOutgoingTransfer_SoftLink = 1690;
  // Vazba výrobního listu gastrovýroby a převodky příjem
  rtGPMAssemblyListToIncomingTransfer_SoftLink = 1692;
  // Vazba výrobního listu gastrovýroby a převodky výdej
  rtGPMAssemblyListToOutgoingTransfer_SoftLink = 1694;

// FLORES Start
  // FLORES vazby v intervalu 1800 - 1999
  rtProductReceptionToPRFJobOrder_SoftLink = 1800;
  rtProductReceptionToPRFOperation_SoftLink = 1802;
  rtMaterialDistributionToPRFJobOrder_SoftLink = 1804;
  rtMaterialDistributionToPRFOperation_SoftLink = 1806;
  rtRefundedMaterialDistributionToPRFJobOrder_SoftLink = 1808;
  rtRefundedMaterialDistributionToPRFOperation_SoftLink = 1810;
  rtPRFJobOrderToIssuedOrder_SoftLink = 1812;
  rtPRFOperationToPRFJobOrderRoutine_SoftLink = 1814;    //nelze zobrazit v Xvazbach, nema documenttype
  rtPRFOperationToIssuedOrder_SoftLink = 1816;    //nelze zobrazit v Xvazbach, nema documenttype
  rtPRFOperationToIssuedOrderRow_SoftLink = 1818;    //nelze zobrazit v Xvazbach, nema documenttype
  rtIssuedOrderToOutgoingTransfer_SoftLink = 1820;
  rtBillOfDeliveryToConsignmentReport_SoftLink = 1822;
  rtReceiptCardToConsignmentReport_SoftLink = 1824;
// FLORES Stop


  // Dalsi skupina az 2000.

  // Skupina 2000..2099 je určena pro kurzový rozdíl Gathering vazeb

  // Vazby mezi korekcnim radkem
  rtIssuedInvoice_CorrectionRowLink = 2100;
  rtIssuedCreditNote_CorrectionRowLink = 2101;

//KUBA - nasledujici START cisla se pouzijou pro zjisteni cisla vazby z techto doklan na doklady definovane v nize definovanem poli.
//Na zjisteni cisla lze pouzit nize definovanou funkci Relation_getRelationNumber
// FLORES Start
  // pocatecni cisla vazeb pro zalozky Pripojene doklady
  // POZOR, nesmi se menit
  rtDataDocument_IssuedInvoice_StartNumber      = 10000;
  rtDataDocument_ReceivedInvoice_StartNumber    = 11000;
  rtDataDocument_OtherIncome_StartNumber        = 12000;
  rtDataDocument_OtherExpense_StartNumber       = 13000;
  rtDataDocument_ReceivedOrder_StartNumber      = 14000;
  rtDataDocument_IssuedOrder_StartNumber        = 15000;
  rtDataDocument_BillOfDelivery_StartNumber     = 16000;
  rtDataDocument_ReceiptCard_StartNumber        = 17000;
  rtDataDocument_OutgoingTransfer_StartNumber   = 18000;
  rtDataDocument_IncomingTransfer_StartNumber   = 19000;
  rtDataDocument_InventoryShortFall_StartNumber = 20000;
  rtDataDocument_InventoryOverplus_StartNumber  = 21000;
  rtDataDocument_Distribution_StartNumber       = 22000;
  rtDataDocument_ConsignmentReport_StartNumber  = 23000;
  rtDataDocument_RemovalList_StartNumber        = 24000;
  rtDataDocument_ShippingList_StartNumber       = 25000;
  rtDataDocument_CustomsDeclaration_StartNumber = 26000;
  rtDataDocument_WageNotice_StartNumber         = 27000;
  rtDataDocument_CashReceived_StartNumber       = 28000;
  rtDataDocument_CashPaid_StartNumber           = 29000;
// FLORES Stop

  // ERR-2165/2010 Interval od 1000000 do 2000000 je rezervován pro externí použití.'

  //TOTO JE PRIKLAD PRO VAZBU  ShippingList->PDMIssuedDoc (odeslana poslta je na 79 pozici v poli (pocitano od nuly)
  //rtPDMIssuedDoc_ShippingList = 25079;

  //0..80
  fConnectedDocsRightClasses = [
    Class_IssuedInvoice,
    Class_ReceivedInvoice,
    Class_InternalDocument,
    Class_OtherExpense,
    Class_OtherIncome,
    Class_AssetDepreciation,
    Class_AssetPutToEvidence,
    Class_AssetReceipt,
    Class_BankStatement,
    Class_PaymentOrder,
    Class_CashPaid,
    Class_CashReceived,
    Class_RefundedCashPaid,
    Class_RefundedCashReceived,
    Class_DevBug,
    Class_DevDoc,
    Class_BalanceExchangeDifference,
    Class_CustomsDeclaration,
    Class_ExchangeDifference,
    Class_NotRealizedExchangeDifference,
    Class_Compensation,
    Class_CreditNoteAcknowledge,
    Class_IssuedDepositInvoice,
    Class_PenaltyInvoice,
    Class_PaymentReminder,
    Class_ReceivedCreditNote,
    Class_ReceivedDepositInvoice,
    Class_Document,
    Class_IssuedOrder,
    Class_ReceivedOrder,
    Class_PosCashPaid,
    Class_PosCashReceived,
    Class_PosReceipt,
    Class_POSSummaredDocument,
    Class_BillOfDelivery,
    Class_IncomingTransfer,
    Class_InventoryOverplus,
    Class_InventoryShortFall,
    Class_MaterialDistribution,
    Class_OutgoingTransfer,
    Class_ProductReception,
    Class_ReceiptCard,
    Class_RefundedBillOfDelivery,
    Class_RefundedMaterialDistribution,
    Class_Absence,
    Class_AnnualClearing,
    Class_WageClosingBook,
    Class_WageListCommon,
    Class_WageListPartial,
    Class_AssetValueChange,
    Class_AssetDiscard,
    Class_IssuedCreditNote,
    Class_LoanSchedule,
    Class_PLMJobOrder,
    Class_PLMProduceRequest,
    Class_PLMCooperation,
    Class_PLMAggregateWorkTicket,
    Class_SickBenefit,
    Class_ReverseChargeDeclaration,
    Class_VATIssuedDepositInvoice,
    Class_VATIssuedDepositCreditNote,
    Class_VATReceivedDepositInvoice,
    Class_VATReceivedDepositCreditNote,
    Class_CRMActivity,
    Class_RefundedReceiptCard,
    Class_IssuedOffer,
    Class_PosCashNotAccountedPaid{,
    // FLORES Start
    Class_OrdersReminder,
    Class_PRFWorkshopSchedule,
    Class_PRFJobOrderAggregateOperation,
    Class_PRFJobOrder,
    Class_PRFLog,
    Class_DistributionPlan,
    Class_Distribution,
    Class_ConsignmentReport,
    Class_RemovalList,
    Class_ShippingList,
    Class_CustomsDeclaration,
    Class_WageNotice,
    Class_PDMIssuedDoc,
    Class_PDMReceivedDoc}
  ];
// FLORES Stop


////////////////////////////////////////////////////////////////////////////////
//zjiskani cisla relace. Slouzi pro ty relace, ktere jsou definovany pomoci START ciala
//a poradi tridy v poli fConnectedDocsRightClasses
function Relation_getRelationNumber(StartNumber: integer; ToClass: TNxPackedGuid): integer;
var
  i: integer;
begin
  result:= 0;
  for i:= 0 to 80-1 do begin
    if(fConnectedDocsRightClasses[i] = ToClass)then begin
      result:= StartNumber+i;
      break;
    end;
  end;
  if(result=0)then
    RaiseException(Format('Nenalezeno číslo vazby StartNumber=%d, ToClass=%d', [StartNumber, ToClass]));
end;
////////////////////////////////////////////////////////////////////////////////

begin
end.