const
  // Stavy dokladu
  ReceiptCard_Status_ID_K_Vyskladneni                   = '2010000101';
  //příjemka

  BillOfDelivery_Status_ID_K_Vyskladneni                = '2010000101';
  //dodací list

  RefundedBillOfDelivery_Status_ID_K_Vyskladneni        = '';
  // Vratka výdejky (Vratka dodacího listu)

  RefundedReceiptCard_Status_ID_K_Vyskladneni           = '';

  OutgoingTransfer_Status_ID_K_Vyskladneni              = '2010000101';
  // Převodka výdej

  IncomingTransfer_Status_ID_K_Vyskladneni              = '2010000101';
  // Převodka příjem

  ShippingList_Status_ID_K_Vyskladneni                  = '';
  // Expediční list

  RemovalList_Status_ID_K_Vyskladneni                   = '';
  // Vyskladňovací list

  JobOrder_Status_ID_K_Vyskladneni                      = '';
  // Výrobní příkaz

  MaterialDistribution_Status_ID_K_Vyskladneni          = '2010000101';
  // Výdej materiálu do výroby

  ProductReception_Status_ID_K_Vyskladneni              = '2010000101';
  // Příjem hotových výrobků

  RefundedMaterialDistribution_Status_ID_K_Vyskladneni  = '';
  // Vrácení materiálu z výroby

  ReceivedOrder_Status_ID_K_Vyskladneni                 = '';
  // Objednávka přijatá

  IssuedOrder_Status_ID_K_Vyskladneni                   = '';
  // Objednávka vydaná

  OutgoingSubstitution_Status_ID_K_Vyskladneni          = '';
  // Záměna výdej

  IncomingSubstitution_Status_ID_K_Vyskladneni          = '';
  // Záměna příjem

  OutgoingTransformation_Status_ID_K_Vyskladneni        = '';
  // Přeměna výdej

  IncomingTransformation_Status_ID_K_Vyskladneni        = '';
  // Přeměna příjem

  WorkshopSchedule_Status_ID_K_Vyskladneni              = '';
  // Dílenský plán


  // Přechody mezi stavy
  ReceiptCard_SwitchRule_ID_Zahajeni                    = 'P000000101';
  ReceiptCard_SwitchRule_ID_Preruseni                   = '5010000101';
  ReceiptCard_SwitchRule_ID_Ukonceni                    = '4010000101';
  ReceiptCard_SwitchRule_ID_Oddeleni                    = '5040000101';
  ReceiptCard_SwitchRule_ID_Vytvoreni                   = 'O000000101';

  BillOfDelivery_SwitchRule_ID_Zahajeni                 = '3000000101';
  BillOfDelivery_SwitchRule_ID_Preruseni                = 'J000000101';
  BillOfDelivery_SwitchRule_ID_Ukonceni                 = '5000000101';
  BillOfDelivery_SwitchRule_ID_Oddeleni                 = '1040000101';
  BillOfDelivery_SwitchRule_ID_Vytvoreni                = 'L000000101';

  RefundedBillOfDelivery_SwitchRule_ID_Zahajeni         = '';
  RefundedBillOfDelivery_SwitchRule_ID_Preruseni        = '';
  RefundedBillOfDelivery_SwitchRule_ID_Ukonceni         = '';
  RefundedBillOfDelivery_SwitchRule_ID_Oddeleni         = '';
  RefundedBillOfDelivery_SwitchRule_ID_Vytvoreni        = '';

  RefundedReceiptCard_SwitchRule_ID_Zahajeni            = '';
  RefundedReceiptCard_SwitchRule_ID_Preruseni           = '';
  RefundedReceiptCard_SwitchRule_ID_Ukonceni            = '';
  RefundedReceiptCard_SwitchRule_ID_Oddeleni            = '';
  RefundedReceiptCard_SwitchRule_ID_Vytvoreni           = '';

  // Převodka výdej
  OutgoingTransfer_SwitchRule_ID_Zahajeni               = '8060000101';
  OutgoingTransfer_SwitchRule_ID_Preruseni              = 'F060000101';
  OutgoingTransfer_SwitchRule_ID_Ukonceni               = 'E060000101';
  OutgoingTransfer_SwitchRule_ID_Oddeleni               = '9060000101';
  OutgoingTransfer_SwitchRule_ID_Vytvoreni              = '7060000101';

  // Převodka příjem
  IncomingTransfer_SwitchRule_ID_Zahajeni               = 'R040000101';
  IncomingTransfer_SwitchRule_ID_Preruseni              = 'Y040000101';
  IncomingTransfer_SwitchRule_ID_Ukonceni               = 'X040000101';
  IncomingTransfer_SwitchRule_ID_Oddeleni               = 'Q040000101';
  IncomingTransfer_SwitchRule_ID_Vytvoreni              = 'V040000101';

  JobOrder_SwitchRule_ID_Zahajeni                       = '';
  JobOrder_SwitchRule_ID_Preruseni                      = '';
  JobOrder_SwitchRule_ID_Ukonceni                       = '';

  ShippingList_SwitchRule_ID_Zahajeni                   = '';
  ShippingList_SwitchRule_ID_Preruseni                  = '';
  ShippingList_SwitchRule_ID_Ukonceni                   = '';
  ShippingList_SwitchRule_ID_Oddeleni                   = '';
  ShippingList_SwitchRule_ID_Vytvoreni                  = '';

  RemovalList_SwitchRule_ID_Zahajeni                    = '';
  RemovalList_SwitchRule_ID_Preruseni                   = '';
  RemovalList_SwitchRule_ID_Ukonceni                    = '';
  RemovalList_SwitchRule_ID_Oddeleni                    = '';
  RemovalList_SwitchRule_ID_Vytvoreni                   = '';

  MaterialDistribution_SwitchRule_ID_Zahajeni           = 'H040000101';
  MaterialDistribution_SwitchRule_ID_Preruseni          = 'K040000101';
  MaterialDistribution_SwitchRule_ID_Ukonceni           = 'L040000101';
  MaterialDistribution_SwitchRule_ID_Oddeleni           = '5050000101';
  MaterialDistribution_SwitchRule_ID_Vytvoreni          = 'J040000101';

  ProductReception_SwitchRule_ID_Zahajeni               = 'C040000101';
  ProductReception_SwitchRule_ID_Preruseni              = 'D040000101';
  ProductReception_SwitchRule_ID_Ukonceni               = 'E040000101';
  ProductReception_SwitchRule_ID_Vytvoreni              = 'F040000101';

  RefundedMaterialDistribution_SwitchRule_ID_Zahajeni   = '';
  RefundedMaterialDistribution_SwitchRule_ID_Preruseni  = '';
  RefundedMaterialDistribution_SwitchRule_ID_Ukonceni   = '';
  RefundedMaterialDistribution_SwitchRule_ID_Vytvoreni  = '';

  ReceivedOrder_SwitchRule_ID_Vytvoreni                 = '';

  IssuedOrder_SwitchRule_ID_Zahajeni                    = '';
  IssuedOrder_SwitchRule_ID_Preruseni                   = '';
  IssuedOrder_SwitchRule_ID_Ukonceni                    = '';
  IssuedOrder_SwitchRule_ID_Oddeleni                    = '';
  IssuedOrder_SwitchRule_ID_Vytvoreni                   = '';

  WorkshopSchedule_SwitchRule_ID_Zahajeni               = '';
  WorkshopSchedule_SwitchRule_ID_Preruseni              = '';
  WorkshopSchedule_SwitchRule_ID_Ukonceni               = '';
  WorkshopSchedule_SwitchRule_ID_Vytvoreni              = '';

  OutgoingSubstitution_SwitchRule_ID_Zahajeni           = '';
  OutgoingSubstitution_SwitchRule_ID_Preruseni          = '';
  OutgoingSubstitution_SwitchRule_ID_Ukonceni           = '';
  OutgoingSubstitution_SwitchRule_ID_Oddeleni           = '';
  OutgoingSubstitution_SwitchRule_ID_Vytvoreni          = '';

  IncomingSubstitution_SwitchRule_ID_Zahajeni           = '';
  IncomingSubstitution_SwitchRule_ID_Preruseni          = '';
  IncomingSubstitution_SwitchRule_ID_Ukonceni           = '';
  IncomingSubstitution_SwitchRule_ID_Oddeleni           = '';
  IncomingSubstitution_SwitchRule_ID_Vytvoreni          = '';

  OutgoingTransformation_SwitchRule_ID_Zahajeni         = '';
  OutgoingTransformation_SwitchRule_ID_Preruseni        = '';
  OutgoingTransformation_SwitchRule_ID_Ukonceni         = '';
  OutgoingTransformation_SwitchRule_ID_Oddeleni         = '';
  OutgoingTransformation_SwitchRule_ID_Vytvoreni        = '';

  IncomingTransformation_SwitchRule_ID_Zahajeni         = '';
  IncomingTransformation_SwitchRule_ID_Preruseni        = '';
  IncomingTransformation_SwitchRule_ID_Ukonceni         = '';
  IncomingTransformation_SwitchRule_ID_Oddeleni         = '';
  IncomingTransformation_SwitchRule_ID_Vytvoreni        = '';

  Report_ID_Stitky                                      = '1230000101';
  PrinterName                                           = 'ZEBRA_ZD421';

begin
end.