const
  // Stavy dokladu
  ReceiptCard_Status_ID_K_Vyskladneni                   = '2000000001';
  ReceiptCard_Status_ID_K_Oddeleno                      = '';

  BillOfDelivery_Status_ID_K_Vyskladneni                = '2000000001';
  BillOfDelivery_Status_ID_K_Oddeleno                   = '';

  RefundedBillOfDelivery_Status_ID_K_Vyskladneni        = '';
  RefundedBillOfDelivery_Status_ID_K_Oddeleno           = '';

  OutgoingTransfer_Status_ID_K_Vyskladneni              = '2000000001';
  OutgoingTransfer_Status_ID_K_Oddeleno                 = '';

  IncomingTransfer_Status_ID_K_Vyskladneni              = '2000000001';
  IncomingTransfer_Status_ID_K_Oddeleno                 = '';

  ShippingList_Status_ID_K_Vyskladneni                  = '';
  ShippingList_Status_ID_K_Oddeleno                     = '';

  RemovalList_Status_ID_K_Vyskladneni                   = '';
  RemovalList_Status_ID_K_Oddeleno                      = '';

  JobOrder_Status_ID_K_Vyskladneni                      = '';

  MaterialDistribution_Status_ID_K_Vyskladneni          = '';
  MaterialDistribution_Status_ID_K_Oddeleno             = '';

  ProductReception_Status_ID_K_Vyskladneni              = '';

  RefundedMaterialDistribution_Status_ID_K_Vyskladneni  = '';

  ReceivedOrder_Status_ID_K_Vyskladneni                 = '';

  IssuedOrder_Status_ID_K_Vyskladneni                   = '';

  OutgoingSubstitution_Status_ID_K_Vyskladneni          = '';
  OutgoingSubstitution_Status_ID_K_Oddeleno             = '';

  IncomingSubstitution_Status_ID_K_Vyskladneni          = '';
  IncomingSubstitution_Status_ID_K_Oddeleno             = '';

  OutgoingTransformation_Status_ID_K_Vyskladneni        = '';
  OutgoingTransformation_Status_ID_K_Oddeleno           = '';

  IncomingTransformation_Status_ID_K_Vyskladneni        = '';
  IncomingTransformation_Status_ID_K_Oddeleno           = '';

  WorkshopSchedule_Status_ID_K_Vyskladneni           = '';


  // Přechody mezi stavy
  ReceiptCard_SwitchRule_ID_Zahajeni                    = '3020000101';
  ReceiptCard_SwitchRule_ID_Preruseni                   = '1030000101';
  ReceiptCard_SwitchRule_ID_Ukonceni                    = '5020000101';
  ReceiptCard_SwitchRule_ID_Vytvoreni                   = '4020000101';
  ReceiptCard_SwitchRule_ID_Oddeleni                   = '';

  BillOfDelivery_SwitchRule_ID_Zahajeni                 = '3050000101';
  BillOfDelivery_SwitchRule_ID_Preruseni                = '9050000101';
  BillOfDelivery_SwitchRule_ID_Ukonceni                 = '4050000101';
  BillOfDelivery_SwitchRule_ID_Vytvoreni                = '8050000101';
  BillOfDelivery_SwitchRule_ID_Oddeleni                = '';

  RefundedBillOfDelivery_SwitchRule_ID_Zahajeni         = 'EV60000101';
  RefundedBillOfDelivery_SwitchRule_ID_Preruseni        = 'FV60000101';
  RefundedBillOfDelivery_SwitchRule_ID_Ukonceni         = 'GV60000101';
  RefundedBillOfDelivery_SwitchRule_ID_Vytvoreni        = '';
  RefundedBillOfDelivery_SwitchRule_ID_Oddeleni        = '';

  OutgoingTransfer_SwitchRule_ID_Zahajeni               = '4040000101';
  OutgoingTransfer_SwitchRule_ID_Preruseni              = '5040000101';
  OutgoingTransfer_SwitchRule_ID_Ukonceni               = '6040000101';
  OutgoingTransfer_SwitchRule_ID_Vytvoreni              = 'C020000101';
  OutgoingTransfer_SwitchRule_ID_Oddeleni              = '';

  IncomingTransfer_SwitchRule_ID_Zahajeni               = '1040000101';
  IncomingTransfer_SwitchRule_ID_Preruseni              = '2040000101';
  IncomingTransfer_SwitchRule_ID_Ukonceni               = '3040000101';
  IncomingTransfer_SwitchRule_ID_Vytvoreni              = 'B020000101';
  IncomingTransfer_SwitchRule_ID_Oddeleni              = '';

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


  // Role
  Role_ID_Skladnik                                      = 'EC00000001';
begin
end.