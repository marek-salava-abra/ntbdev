uses 'eu.abra.masa.spedos.ExpediceND.fce';

procedure InitSite_Hook(Self: TSiteForm);
var
 mAction:TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Tvorba DL';
  mAction.ShortCut := TextToShortCut('Ctrl+B'); //16450;
  mAction.Hint := 'Tvorba dokladu';
  mAction.Category := 'tabList';
  mAction.OnExecute := @BarCodeOnExecute;

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Potvrzení termínů API';
  mAction.Hint := 'Odešle termíny přes API do objednavatele';
  mAction.Category := 'tabList';
  mAction.OnExecute := @APISendDate;
end;

Procedure APISendDate(sender:TComponent);
Var
 mSite:TSiteForm;
 mBO, mRowBO:TNxCustomBusinessObject;
 i:integer;
 mRows:TNxCustomBusinessMonikerCollection;
 mJSON, mJSON2, mResultJSON:TJSONSuperObject;
 mFileName:string;
 mPrintList:TStringList;
begin
 mSite:=TComponent(sender).DynSite;
 mBO:=TDynSiteForm(mSite).CurrentObject;
 if Assigned(mBO) then begin
    mJSON:=TJSONSuperObject.create;
    mJSON.S['Order']:=mBO.DisplayName;
    mRows:= mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
    mJSON.O['Rows'] := mJSON.CreateJSONArray;
    for i:=0 to mRows.count-1 do begin
      mRowBO:=mRows.BusinessObject[i];
      mJSON2:=TJSONSuperObject.Create;
      mJSON2.S['Row_ID']:=mRowBO.GetFieldValueAsString('X_ExtRow_ID');
      mJSON2.D['DeliveryDate']:=mRowBO.GetFieldValueAsDateTime('DeliveryDate$Date');
      mJSON.A['Rows'].Add(mJSON2);
    end;
    if mbo.GetFieldValueAsString('Firm_ID.OrgIdentNumber')='05665817' then mResultJSON:=API_POST(mJSON);
    if mbo.GetFieldValueAsString('Firm_ID.OrgIdentNumber')='31708587' then mResultJSON:=API_POSTSK(mJSON);
    if not(mbo.GetFieldValueAsString('Firm_ID.OrgIdentNumber') in ['05665817','31708587']) then begin
      mResultJSON:=TJSONSuperObject.Create;
      mResultJSON.S['Status']:='Error1';
    end;
    if mResultJSON.S['Status']='Error1' then
     NxShowSimpleMessage('Sychronizace se nepovedla.',mSite);
    if mResultJSON.S['Status']='OK' then begin
      mPrintList:=TStringList.create;
      mPrintList.Add(mbo.OID);
      mFileName:=NxSearchReplace(mbo.DisplayName,'/','-',[srall])+'.pdf';
      CFxReportManager.PrintByIDs(NxCreateContext_1(mbo), mPrintList, GetDynSource(mbo.ObjectSpace,'6OA3000101'), '6OA3000101', rtoFile, pekPDF, NxGetTempDir, mFileName);
      if mbo.GetFieldValueAsString('Firm_ID.OrgIdentNumber')='31708587' then  //Slovensko
      SendInternalMail(mbo.ObjectSpace, 'ndsk@spedos.cz','',
                               'Objednávka - změna termínů '+mbo.GetFieldValueAsString('ExternalNumber'),'',
                               NxGetTempDir+'\'+mFileName,mbo.GetFieldValueAsString('Firm_ID'),mrows.BusinessObject[0].GetFieldValueAsString('Division_ID'),mrows.BusinessObject[0].GetFieldValueAsString('BusOrder_ID'), '');

      if mbo.GetFieldValueAsString('Firm_ID.OrgIdentNumber')='05665817' then  //Servis
      SendInternalMail(mbo.ObjectSpace, 'ndservis@spedos.cz','',
                               'Objednávka - změna termínů '+mbo.GetFieldValueAsString('ExternalNumber'),'',
                               NxGetTempDir+'\'+mFileName,mbo.GetFieldValueAsString('Firm_ID'),mrows.BusinessObject[0].GetFieldValueAsString('Division_ID'),mrows.BusinessObject[0].GetFieldValueAsString('BusOrder_ID'), '');

      if mbo.GetFieldValueAsString('Firm_ID.OrgIdentNumber')='25905031' then  //K.B.K.
      SendInternalMail(mbo.ObjectSpace, 'maler@spedos.cz','',
                               'Objednávka - změna termínů '+mbo.GetFieldValueAsString('ExternalNumber'),'',
                               NxGetTempDir+'\'+mFileName,mbo.GetFieldValueAsString('Firm_ID'),mrows.BusinessObject[0].GetFieldValueAsString('Division_ID'),mrows.BusinessObject[0].GetFieldValueAsString('BusOrder_ID'), '');

     mBO.SetFieldValueAsDateTime('X_APIDate',Now);
     mbo.save;
     NxShowSimpleMessage('Sychronizace se povedla.',mSite);
    end;
 end;

end;

Procedure BarCodeOnExecute(sender:TComponent);
var
 mSite:TSiteForm;
 mPrintList:tstringlist;
 mBO:TNxCustomBusinessObject;
 mDQNumber:string;
 mOS:TNxCustomObjectSpace;
 mReceivedOrder_ID:string;
 mRows:TNxCustomBusinessMonikerCollection;
 i,j,k:integer;
 mBODDQ_ID, mBillOfDelivery_ID:string;
 mImportMan:TNxDocumentImportManager;
 mInputParams:TNxParameters;
 mParam:TNxParameter;
 mPrintParams:TNxParameters;
 mPocet:Extended;
begin
  mPrintParams:=GlobParams;
  mSite:=TComponent(sender).DynSite;
  mOS:=TDynSiteForm(mSite).BaseObjectSpace;
  if not BarCodeDialog(mDQNumber,mSite) then exit;
  mReceivedOrder_ID:=GetReceivedOrder_ID(mOS, mDQNumber);
  if NxIsEmptyOID(mReceivedOrder_ID) then begin
    NxShowSimpleMessage('Nepovedlo se dohledat objednávku náhradních dílů s externím číslem '+mDQNumber+'. Ukončuji.',mSite);
    exit;
  end;
  //NxShowSimpleMessage('Select parent_id from storedocuments2 where provide_id='+QuotedStr('mReceivedOrder_ID'),mSite);
  mBillOfDelivery_ID:=mos.SQLSelectFirstAsString('Select parent_id from storedocuments2 where provide_id='+QuotedStr(mReceivedOrder_ID),'');
  if not(NxIsEmptyOID(mReceivedOrder_ID)) and not(NxIsEmptyOID(mBillOfDelivery_ID)) then begin
     if not BalikDialog(mPocet,mSite) then begin
       NxShowSimpleMessage('Nebyl zadán počet balíků, počítám s 1 balíkem.',mSite);
       mPocet:=1;
     end;
     k:=Trunc(mPocet);
     mPrintParams.GetOrCreateParam(dtInteger,'pocet').AsInteger:=k;
     mPrintParams.GetOrCreateParam(dtInteger,'counter').AsInteger:=0;
     mPrintList:=TStringList.create;
                      mPrintList.Add(mBillOfDelivery_ID);
                      for j:=1 to k do begin
                      mPrintParams.GetOrCreateParam(dtInteger,'counter').AsInteger:=j;
                      //Náhled tisku
                      //CFxReportManager.PrintByIDs(NxCreateContext(mOS),mPrintList,GetDynSource(mOS,'2L52000101'),'2L52000101',rtoPreview,pekPDF,'','');
                      //Tisk balikove soupisky podle počtu balíků
                      CFxReportManager.PrintByIDs(NxCreateContext(mOS),mPrintList,GetDynSource(mOS,'5OA3000101'),'5OA3000101',rtoPrint,pekPDF,'Tisk_stitky', '');
                      end;
                      mPrintParams.GetOrCreateParam(dtInteger,'pocet').AsInteger:=1;
  end;
  if not(NxIsEmptyOID(mReceivedOrder_ID)) and (NxIsEmptyOID(mBillOfDelivery_ID)) then begin
     mBODDQ_ID:='';
     mBO:=mOS.CreateObject(Class_ReceivedOrder);
     mBO.Load(mReceivedOrder_ID);
     if not(mbo.GetFieldValueAsBoolean('IsAvailableForDelivery')) then begin
       NxShowSimpleMessage('Objednávka '+mbo.DisplayName+' není čerpatelná. Ukončuji.',mSite);
       exit;
     end;
     if not BalikDialog(mPocet,mSite) then begin
       NxShowSimpleMessage('Nebyl zadán počet balíků, počítám s 1 balíkem.',mSite);
       mPocet:=1;
     end;
     k:=Trunc(mPocet);
     mPrintParams.GetOrCreateParam(dtInteger,'pocet').AsInteger:=k;
     mPrintParams.GetOrCreateParam(dtInteger,'counter').AsInteger:=0;
     mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
     {for i:=0 to mRows.count-1 do begin
       if mRows.BusinessObject[i].GetFieldValueAsInteger('RowType')=3 then begin
         if NxIsEmptyOID(mBODDQ_ID) then begin
            if mRows.BusinessObject[i].GetFieldValueAsString('Store_ID.Code')='501' then mBODDQ_ID:='R000000101';
            if mRows.BusinessObject[i].GetFieldValueAsString('Store_ID.Code')='555' then mBODDQ_ID:='R000000101';
            if mRows.BusinessObject[i].GetFieldValueAsString('Store_ID.Code')='502' then mBODDQ_ID:='1S00000101';
         end;
       end;
     end;  }
     if mBO.GetFieldValueAsString('Firm_ID.OrgIdentNumber')='31708587' then mBODDQ_ID:='O100000101';  //Slovensko, dodák DLV (Gajdoš)
     if mBO.GetFieldValueAsString('Firm_ID.OrgIdentNumber')='05665817' then mBODDQ_ID:='5400000101';  //Servis, dodák DSV (Gajdoš)
     if mBO.GetFieldValueAsString('Firm_ID.OrgIdentNumber')='25905031' then mBODDQ_ID:='O100000101';  //K.B.K., dodák DLV (Gajdoš)
     try
     //                 mBODDQ_ID:='5400000101';        zapoznámkováno GAJDOŠ
                      mInputParams := TNxParameters.Create;
                      mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                      mParam.AsString := mBODDQ_ID;
                      mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
                      mParam.AsString := mBO.OID;
                      mImportMan:=NxCreateDocumentImportManager(mOS,Class_ReceivedOrder,Class_BillOfDelivery);
                      mImportMan.AddInputDocument(mBO.OID);
                      mImportMan.LoadParams(mInputParams);
                      mImportMan.Execute;
                      mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', mBODDQ_ID);
                      mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID',mBO.GetFieldValueAsString('Firm_ID'));
                      mImportMan.OutputDocument.SetFieldValueAsString('FirmOffice_ID',MBO.GetFieldValueAsString('FirmOffice_ID'));
                      mImportMan.OutputDocument.save;
                      mPrintList:=TStringList.create;
                      mPrintList.Add(mImportMan.OutputDocument.OID);
                      for j:=1 to k do begin
                      mPrintParams.GetOrCreateParam(dtInteger,'counter').AsInteger:=j;
                      //Náhled tisku
                      //CFxReportManager.PrintByIDs(NxCreateContext(mOS),mPrintList,GetDynSource(mOS,'2L52000101'),'2L52000101',rtoPreview,pekPDF,'','');
                      //Tisk balikove soupisky podle počtu balíků
                      CFxReportManager.PrintByIDs(NxCreateContext(mOS),mPrintList,GetDynSource(mOS,'5OA3000101'),'5OA3000101',rtoPrint,pekPDF,'Tisk_stitky', '');
                      end;
                      mPrintParams.GetOrCreateParam(dtInteger,'pocet').AsInteger:=1;
                      //Tisk dodacího listu
                      //CFxReportManager.PrintByIDs(NxCreateContext(mOS),mPrintList,GetDynSource(mOS,'ML00000101'),'ML00000101',rtoPrint,pekPDF,'Microsoft Print to PDF', '');

      mPrintParams.ClearData;

     except
       NxShowSimpleMessage('Něco se nepovedlo:'+#13#10+ExceptionMessage,mSite);
     end;
    TDynSiteForm(mSite).RefreshData;
  end;
end;


begin
end.