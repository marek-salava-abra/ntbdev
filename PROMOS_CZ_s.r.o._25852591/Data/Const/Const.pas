const
  // Stavy dokladu
  ReceiptCard_Status_ID_K_Vyskladneni                   = '2000000001';

  BillOfDelivery_Status_ID_K_Vyskladneni                = '2000000001';

  RefundedBillOfDelivery_Status_ID_K_Vyskladneni        = '2000000001';

  RefundedReceiptCard_Status_ID_K_Vyskladneni           = '2000000001';

  OutgoingTransfer_Status_ID_K_Vyskladneni              = '2000000001';

  IncomingTransfer_Status_ID_K_Vyskladneni              = '';

  ShippingList_Status_ID_K_Vyskladneni                  = '';

  RemovalList_Status_ID_K_Vyskladneni                   = '';

  JobOrder_Status_ID_K_Vyskladneni                      = '';

  MaterialDistribution_Status_ID_K_Vyskladneni          = '';

  ProductReception_Status_ID_K_Vyskladneni              = '';

  RefundedMaterialDistribution_Status_ID_K_Vyskladneni  = '';

  ReceivedOrder_Status_ID_K_Vyskladneni                 = '';

  IssuedOrder_Status_ID_K_Vyskladneni                   = '';

  OutgoingSubstitution_Status_ID_K_Vyskladneni          = '';

  IncomingSubstitution_Status_ID_K_Vyskladneni          = '';

  OutgoingTransformation_Status_ID_K_Vyskladneni        = '';

  IncomingTransformation_Status_ID_K_Vyskladneni        = '';

  WorkshopSchedule_Status_ID_K_Vyskladneni              = '';


  // Přechody mezi stavy
  ReceiptCard_SwitchRule_ID_Zahajeni                    = 'I010000101';
  ReceiptCard_SwitchRule_ID_Preruseni                   = 'J010000101';
  ReceiptCard_SwitchRule_ID_Oddeleni                    = '';
  ReceiptCard_SwitchRule_ID_Ukonceni                    = 'W010000101';
  ReceiptCard_SwitchRule_ID_Vytvoreni                   = 'G010000101';

  BillOfDelivery_SwitchRule_ID_Zahajeni                 = 'B010000101';
  BillOfDelivery_SwitchRule_ID_Preruseni                = 'E010000101';
  BillOfDelivery_SwitchRule_ID_Oddeleni                 = 'E010000101';
  BillOfDelivery_SwitchRule_ID_Ukonceni                 = 'M010000101';
  BillOfDelivery_SwitchRule_ID_Vytvoreni                = '2010000101';

  RefundedBillOfDelivery_SwitchRule_ID_Zahajeni         = 'EV60000101';
  RefundedBillOfDelivery_SwitchRule_ID_Preruseni        = 'FV60000101';
  RefundedBillOfDelivery_SwitchRule_ID_Oddeleni         = 'FV60000101';
  RefundedBillOfDelivery_SwitchRule_ID_Ukonceni         = 'GV60000101';
  RefundedBillOfDelivery_SwitchRule_ID_Vytvoreni        = '';

  RefundedReceiptCard_SwitchRule_ID_Zahajeni            = '';
  RefundedReceiptCard_SwitchRule_ID_Preruseni           = '';
  RefundedReceiptCard_SwitchRule_ID_Ukonceni            = '';
  RefundedReceiptCard_SwitchRule_ID_Oddeleni            = '';
  RefundedReceiptCard_SwitchRule_ID_Vytvoreni           = '';

  OutgoingTransfer_SwitchRule_ID_Zahajeni               = '1040000101';
  OutgoingTransfer_SwitchRule_ID_Preruseni              = '5040000101';
  OutgoingTransfer_SwitchRule_ID_Oddeleni               = '';
  OutgoingTransfer_SwitchRule_ID_Ukonceni               = '2040000101';
  OutgoingTransfer_SwitchRule_ID_Vytvoreni              = 'X010000101';

  IncomingTransfer_SwitchRule_ID_Zahajeni               = '';
  IncomingTransfer_SwitchRule_ID_Preruseni              = '';
  IncomingTransfer_SwitchRule_ID_Ukonceni               = '';
  IncomingTransfer_SwitchRule_ID_Oddeleni               = '';
  IncomingTransfer_SwitchRule_ID_Vytvoreni              = 'Y010000101';

  JobOrder_SwitchRule_ID_Zahajeni                       = '';
  JobOrder_SwitchRule_ID_Preruseni                      = '';
  JobOrder_SwitchRule_ID_Ukonceni                       = '';
  JobOrder_SwitchRule_ID_Oddeleni                       = '';

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

  MaterialDistribution_SwitchRule_ID_Zahajeni           = '';
  MaterialDistribution_SwitchRule_ID_Preruseni          = '';
  MaterialDistribution_SwitchRule_ID_Ukonceni           = '';
  MaterialDistribution_SwitchRule_ID_Oddeleni           = '';
  MaterialDistribution_SwitchRule_ID_Vytvoreni          = '';

  ProductReception_SwitchRule_ID_Zahajeni               = '';
  ProductReception_SwitchRule_ID_Preruseni              = '';
  ProductReception_SwitchRule_ID_Ukonceni               = '';
  ProductReception_SwitchRule_ID_Vytvoreni              = '';

  RefundedMaterialDistribution_SwitchRule_ID_Zahajeni   = '';
  RefundedMaterialDistribution_SwitchRule_ID_Preruseni  = '';
  RefundedMaterialDistribution_SwitchRule_ID_Ukonceni   = '';
  RefundedMaterialDistribution_SwitchRule_ID_Vytvoreni  = '';

  ReceivedOrder_SwitchRule_ID_Vytvoreni                 = '';

  IssuedOrder_SwitchRule_ID_Zahajeni                    = '';
  IssuedOrder_SwitchRule_ID_Preruseni                   = '';
  IssuedOrder_SwitchRule_ID_Ukonceni                    = '';
  IssuedOrder_SwitchRule_ID_Oddeleni                    = '';
  
  IssuedOrder_SwitchRule_ID_Oddeleni2                   = '';
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

begin
end.