const
// konstanty pro objednavky
 cDocqueue_ID='1W10000101'; //OPE
 cStore_ID='1L00000101';    //01
 cDivision_ID='1400000101'; //000
 cBusTransction='1900000101'; //99
// konstanty pro export
 conSQL0='Select id from storemenu where hidden= ''N'' ';
 conExportID0='2T00000101';
 conDynSource0='C1PBCWYCQVDL342W01C0CX3FCC';
 conFileName0='d:\wamp\www\images\storemenu.xml';

 conSQL1='Select id from storecards where  hidden= ''N'' and X_ESCard=''A'' ';
 conSQL1d='Select id from storecards where hidden= ''N'' and (correctedat$date>=%s or createdat$date>=%s) and X_ESCard=''A'' ';
 conExportID1='4250000101';
 conDynSource1='2K3MZAL0Z1L4ZGUYUU1CSTSQNS';
 conFileName1='d:\wamp\www\images\StoreCards.xml';

 conSQL2='Select id from firms where hidden= ''N'' ';
 conSQL2d='Select id from firms where hidden= ''N'' and (correctedat$date>=%s or createdat$date>=%s) ';
 conExportID2='1X10000101';
 conDynSource2='W0DR1FTE3JD13ACL03KIU0CLP4';
 conFileName2='d:\wamp\www\images\firm.xml';

 conSQL3='Select id from StoreAssortmentGroups where hidden= ''N'' ';
 conExportID3='2100000101';
 conDynSource3='K2YEKCB43GM4X3SBRM5ZUU0PNW';
 conFileName3='d:\wamp\www\images\storeassortment.xml';
 
 conSQL4='Select a.id from storecards a where (exists (SELECT 1 FROM USERDATA WHERE FIELDCODE=2000017 AND CLSID='+Quotedstr('C3V5QDVZ5BDL342M01C0CX3FCC')+' AND ID = A.ID AND (STRINGFIELDVALUE LIKE '+Quotedstr('A')+'))) and a.hidden= ''N'' ';
 conExportID4='2W00000101';
 conDynSource4='OGQQA2C25JDL342N01C0CX3FCC';
 conFileName4='d:\wamp\www\images\StoreCardsQuantity.xml';
 
 conSQL5='Select id from storebatches where x_eshop=''A'' and hidden= ''N'' ';
 conExportID5='1300000101';
 conDynSource5='O1YGCLIJUNDL342X01C0CX3FCC';
 conFileName5='d:\wamp\www\images\colors.xml';
 
 conSQL6='Select id from pricelists where hidden= ''N'' ';
 conExportID6='2X10000101';
 conDynSource6='WBZSRQS0AZE1342Y01C0CX3FCC';
 conFileName6='d:\wamp\www\images\storeprices.xml';
 
 conSQL7='Select id from actionpricelists where hidden= ''N'' ';
 conExportID7='1500000101';
 conDynSource7='LFE4AI3GSCL4DHC4LQ04IMNRCG';
 conFileName7='d:\wamp\www\images\actionstoreprices.xml';
 
 conSQL8='Select id from transportaTIONTYPES where hidden= ''N'' ';
 conExportID8='2X00000101';
 conDynSource8='O1DP5VNYGZE13C5T00CA141B44';
 conFileName8='d:\wamp\www\images\Transporttypes.xml';
 
 conSQL9='Select id from paymenttYPES where hidden= ''N'' ';
 conExportID9='3X00000101';
 conDynSource9='O5DP5VNYGZE13C5T00CA141B44';
 conFileName9='d:\wamp\www\images\paymenttYPES.xml';

 conSQL10='Select id from defrolldata where CLSID = ''PKVPDHXNS3L4DE0DC0XUE1FP2K'' and hidden= ''N'' ';
 conExportID10='2010000101';
 conDynSource10='2UX3RWOPXVIOTHOBAALMPQOUVG';
 conFileName10='d:\wamp\www\images\OrderStates.xml';

 conSQL11='Select id from defrolldata where CLSID = ''OD4JP4GMMNRO5DTOIFTDVCLISC'' and hidden= ''N'' ';
 conExportID11='3260000101';
 conDynSource11='A5M5ZAWNG3243HCL2ETWFAQJV4';
 conFileName11='d:\wamp\www\images\ParamGroups.xml';


function GetExpSource (AOS : TNxCustomObjectSpace; AValue : string) : String;

const
  cSQL = 'SELECT DataSource FROM Exports WHERE ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [ AValue]), mList);
    if mList.Count > 0 then
      Result := (mList.Strings[0]);
  finally
    mList.Free;
  end;
end;

begin
end.