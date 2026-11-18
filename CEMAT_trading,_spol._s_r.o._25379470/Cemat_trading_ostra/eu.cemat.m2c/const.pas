const
// konstanty pro objednavky


// konstanty pro export


 conSQL0='Select id from storemenu where hidden= ''N'' ';
 conExportID0='1S00000101';
 conDynSource0='C1PBCWYCQVDL342W01C0CX3FCC';
 conFileName0='C:\ABRAG3\mForce\storemenu.xml';

 conSQL1='Select id from storecards where hidden= ''N'' ';
 conSQL1d='Select id from storecards where hidden= ''N'' and (correctedat$date>=%s or createdat$date>=%s) ';
 conExportID1='2N00000101';
 conDynSource1='OGQQA2C25JDL342N01C0CX3FCC';
 conFileName1='C:\ABRAG3\mForce\StoreCards.xml';

 conSQL2='Select id from firms where hidden= ''N'' ';
 conSQL2d='Select id from firms where hidden= ''N'' and (correctedat$date>=%s or createdat$date>=%s) ';
 conExportID2='1N00000101';
 conDynSource2='W0DR1FTE3JD13ACL03KIU0CLP4';
 conFileName2='C:\ABRAG3\mForce\firm.xml';

 conSQL3='Select id from stores where hidden= ''N'' ';
 conExportID3='2S00000101';
 conDynSource3='OJXQ3K0T5JDL3CL100C4RHECN0';
 conFileName3='C:\ABRAG3\mForce\stores.xml';

 conSQL4='Select id from storeSubcards where Store_ID IN (''2000000101'',''3000000101'',''1300000101'',''1B00000101'')';
 conExportID4='3S00000101';
 conDynSource4='G0XYJHQFQVDL342W01C0CX3FCC';
 conFileName4='C:\ABRAG3\mForce\storeQuantity.xml';

 conSQL5='Select id from securityusers ';
 conExportID5='6S00000101';
 conDynSource5='O2RORR1WHRE13DQC01C0CX3F40';
 conFileName5='C:\ABRAG3\mForce\users.xml';

 conSQL6='Select id from securityroles ';
 conExportID6='5S00000101';
 conDynSource6='AAR54JGG5OX4Z30DH4YXJOEKOG';
 conFileName6='C:\ABRAG3\mForce\roles.xml';

 conSQL7='Select id from IssuedOrders ';
 conSQL7d='Select id from IssuedOrders where (correctedat$date>=%s or createdat$date>=%s) ';
 conExportID7='7S00000101';
 conDynSource7='W0NZQGROZZDL342X01C0CX3FCC';
 conFileName7='C:\ABRAG3\mForce\issuedorders.xml';

 conSQL8='Select id from issuedinvoices ';
 conSQL8d='Select id from issuedinvoices where (correctedat$date>=%s or createdat$date>=%s) ';
 conExportID8='1O00000101';
 conDynSource8='40SBPEINEFD13ACM03KIU0CLP4';
 conFileName8='C:\ABRAG3\mForce\issuedinvoices.xml';

 conSQL9='Select id from crmacTIVITIES ';
 conSQL9d='Select id from crmacTIVITIES where (correctedat$date>=%s or createdat$date>=%s) ';
 conExportID9='8S00000101';
 conDynSource9='YAQO3JZE02Y4L1PJGSXVJE41A4';
 conFileName9='C:\ABRAG3\mForce\activities.xml';

 conSQL10='Select id from ReceivedOrders ';
 conSQL10d='Select id from ReceivedOrders where (correctedat$date>=%s or createdat$date>=%s) ';
 conExportID10='1P00000101';
 conDynSource10='40V53DORW3DL342X01C0CX3FCC';
 conFileName10='C:\ABRAG3\mForce\ReceivedOrders.xml';

 conSQL11='Select id from IssuedOffers ';
 conSQL11d='Select id from IssuedOffers where (correctedat$date>=%s or createdat$date>=%s) ';
 conExportID11='9S00000101';
 conDynSource11='K4IIDRU05OBOTINVOHN4KVXZGO';
 conFileName11='C:\ABRAG3\mForce\IssuedOffers.xml';

 conSQL12='Select id from Divisions where hidden= ''N'' ';
 conExportID12='AS00000101';
 conDynSource12='K3SMLY4BEZD135SA02K2CQM5AW';
 conFileName12='C:\ABRAG3\mForce\Divisions.xml';

 conSQL13='Select id from CRMACTIVITYAREAS where hidden= ''N'' ';
 conExportID13='BS00000101';
 conDynSource13='OTGVOTSIHL0O3BC3EGC2GWDRBG';
 conFileName13='C:\ABRAG3\mForce\ACtivityAreas.xml';

 conSQL14='Select id from CRMACTIVITYTYPES where hidden= ''N'' ';
 conExportID14='CS00000101';
 conDynSource14='0PHOQ3ECKGF4VIHQG44ZVH5PBG';
 conFileName14='C:\ABRAG3\mForce\ActivityTypes.xml';

 conSQL15='Select id from CRMACTIVITYQUEUES where hidden= ''N'' ';
 conExportID15='DS00000101';
 conDynSource15='DWWFHVBSZ1V43EHPMVJLA5RUTG';
 conFileName15='C:\ABRAG3\mForce\ActivityQueues.xml';

 conSQL16='Select id from issuedinvoices ';
 conSQL16d='Select a.id from issuedinvoices A where (EXISTS (SELECT 1 FROM PaymentsForDocument_VIEW PFD   WHERE (PFD.DocDate$DATE >= %s) and (PFD.DocDate$DATE < %s) and PFD.PDocumentType = ''03'' and PFD.PDocument_ID = A.ID))  ';
 conExportID16='1Y00000101';
 conDynSource16='40SBPEINEFD13ACM03KIU0CLP4';
 conFileName16='C:\ABRAG3\mForce\issuedinvoicesp.xml';

 conSQL17='Select id from storeSubcards where x_dateofchange>=%s and Store_ID IN (''2000000101'',''3000000101'',''1300000101'',''1B00000101'')';
 conExportID17='3S00000101';
 conDynSource17='G0XYJHQFQVDL342W01C0CX3FCC';
 conFileName17='C:\ABRAG3\mForce\storeQuantity.xml';

 conSQL18='Select id from BusOrders where hidden= ''N'' ';
 conExportID18='1Z00000101';
 conDynSource18='1FY41UEONTT4F30CRPRCNKEFPW';
 conFileName18='C:\ABRAG3\mForce\BusOrders.xml';

 conSQL19='Select id from BusOrders where hidden= ''N'' ';
 conExportID19='1Z00000101';
 conDynSource19='H50BB3SY0PU4FDK22I0ATCHJXS';
 conFileName19='C:\ABRAG3\mForce\BusTransactions.xml';

 conSQL20='Select id from documenttypes ';
 conSQL20d='Select sd2.id from StoreDocuments sd left join storedocuments2 sd2 on sd2.parent_id=sd.id where sd.documenttype=''21'' and sd2.providerow_id is not null and (sd.correctedat$date>=%s or sd.createdat$date>=%s) ';
 conExportID20='1110000101';
 conDynSource20='WBFDIVPW1ZE13HBT00C5OG4NF4';
 conFileName20='C:\ABRAG3\mForce\DeliveredQuantity.xml';

 conSQL21='Select sd2.id from StoreDocuments2 sd2 left join storedocuments sd on sd.id=sd2.parent_id where sd.createdat$date>%s ';
 conExportID21='1310000101';
 conDynSource21='WBFDIVPW1ZE13HBT00C5OG4NF4';
 conFileName21='C:\ABRAG3\mForce\StoreMovements.xml';

begin
end.