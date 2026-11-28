const
// konstanty pro objednavky
 cDocqueue_ID='J410000101'; //OPE
 cStore_ID='6200000101';    //01
 cDivision_ID='1000000101'; //000
 
// konstanty pro export
 conSQL0='Select id from storemenu where hidden= ''N'' ';
 conExportID0='M200000101';
 conDynSource0='C1PBCWYCQVDL342W01C0CX3FCC';
 conFileName0='C:\eshop\storemenu.xml';

 conSQL1='Select id from storecards where  hidden= ''N'' ';
 conSQL1d='Select id from storecards where hidden= ''N'' and (correctedat$date>=%s or createdat$date>=%s) ';
 conExportID1='N200000101';
 conDynSource1='OGQQA2C25JDL342N01C0CX3FCC';
 conFileName1='C:\eshop\StoreCards.xml';

 conSQL2='Select id from firms where hidden= ''N'' ';
 conSQL2d='Select id from firms where hidden= ''N'' and (correctedat$date>=%s or createdat$date>=%s) ';
 conExportID2='J200000101';
 conDynSource2='W0DR1FTE3JD13ACL03KIU0CLP4';
 conFileName2='C:\eshop\firm.xml';

 conSQL3='Select id from StoreAssortmentGroups where hidden= ''N'' ';
 conExportID3='I200000101';
 conDynSource3='K2YEKCB43GM4X3SBRM5ZUU0PNW';
 conFileName3='C:\eshop\storeassortment.xml';
 
 conSQL4='Select id from storecards where hidden= ''N'' ';
 conExportID4='O200000101';
 conDynSource4='OGQQA2C25JDL342N01C0CX3FCC';
 conFileName4='C:\eshop\StoreCardsQuantity.xml';
 

 
 conSQL6='Select id from pricelists where hidden= ''N'' ';
 conExportID6='K200000101';
 conDynSource6='WBZSRQS0AZE1342Y01C0CX3FCC';
 conFileName6='C:\eshop\storeprices.xml';
 
 conSQL7='Select id from actionpricelists where hidden= ''N'' ';
 conExportID7='L200000101';
 conDynSource7='LFE4AI3GSCL4DHC4LQ04IMNRCG';
 conFileName7='c:\eshop\actionstoreprices.xml';
 
 conSQL8='Select id from transportaTIONTYPES where hidden= ''N'' ';
 conExportID8='IB00000101';
 conDynSource8='O1DP5VNYGZE13C5T00CA141B44';
 conFileName8='c:\eshop\Transporttypes.xml';
 
 conSQL9='Select id from paymenttYPES where hidden= ''N'' ';
 conExportID9='JB00000101';
 conDynSource9='O5DP5VNYGZE13C5T00CA141B44';
 conFileName9='c:\eshop\paymenttYPES.xml';

 conSQL10='Select id from Defrolldata where clsid=''JKU1KJLVNEWOTHTGOP1QHCSLBC'' and hidden= ''N'' ';
 conExportID10='IC00000101';
 conDynSource10='MFFALAZSFTSOHC1EFOHLZMZSUS';
 conFileName10='c:\eshop\ORderStates.xml';

 conSQL11='Select ID FROM USERDATA WHERE FIELDCODE=2000003 AND CLSID=''01CPMINJW3DL342X01C0CX3FCC''  AND STRINGFIELDVALUE like ''%101'' ';
 conSQL11d='Select r.id from ReceivedOrders r where r.id in (SELECT ID FROM USERDATA WHERE FIELDCODE=2000003 AND CLSID=''01CPMINJW3DL342X01C0CX3FCC'' '+
           '  AND STRINGFIELDVALUE like ''_______101'') and (r.correctedat$date>=%s or r.createdat$date>=%s) ';
 conExportID11='IE00000101';
 conDynSource11='40V53DORW3DL342X01C0CX3FCC';
 conFileName11='C:\eshop\OrdersState.xml';


begin
end.