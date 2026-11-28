uses '.const', '.dlg';

// zavolá formulář, formulář bude mít firmy jen s datovou schránkou
// validace na id datové schránky
// počet poukázek 500 a 1000
// celkem hodnota odměny
// po stisku ok X*500+Y*1000= hodnota odměny
// pokud ne sorry nerovná se znovu na začátek
// oznámení o částce na FV po splatnosti dialog ANO/Ne na pokračování
// vytvoří pokladní doklad

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TAction;
  mUser:TNxCustomBusinessObject;
begin
  mUser:=Self.BaseObjectSpace.CreateObject(Class_SecurityUser);
  mUser.load(NxGetActualUserID(self.BaseObjectSpace),nil);
  if mUser.GetFieldValueAsBoolean('X_Alza') then begin
    mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := 'Vydej ALZU';
    mAction.Hint := 'Vydá Alza kupóny';
    mAction.Category := 'tabList';
    mAction.OnExecute := @SellAlza;

    mAction := Self.GetNewAction;
    mAction.ShowControl := True;
    mAction.ShowMenuItem := True;
    mAction.Caption := 'Odešli ALZU';
    mAction.Hint := 'Odešle Alza kupóny';
    mAction.Category := 'tabList';
    mAction.OnExecute := @SendAlza;
  end;
end;

Procedure SellAlza(Sender:TComponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mFirm_ID:string;
 mCount500, mCount1000, mTotal:Extended;
 mStoreCount500, mStoreCount1000:Extended;
 mCashBO, mBODBO, mBODRowBO, mDRBBO:TNxCustomBusinessObject;
 mRows, mDRBRows:TNxCustomBusinessMonikerCollection;
 i:integer;
 mBatchList:TStringList;
 mInputParams:TNxParameters;
 mParam:TNxParameter;
 mImportMan:TNxDocumentImportManager;
begin
 mSite:=TComponent(Sender).DynSite;
 mOS:=TDynSiteForm(mSite).BaseObjectSpace;
 if Assigned(mSite) then begin
   mFirm_ID:='';
   mCount500:=0;
   mCount1000:=0;
   mTotal:=0;
   mStoreCount500:=mOS.SQLSelectFirstAsExtended('Select sum(Quantity) from storesubcards where storecard_id='+QuotedStr(cAlza500),0);
   mStoreCount1000:=mOS.SQLSelectFirstAsExtended('Select sum(Quantity) from storesubcards where storecard_id='+QuotedStr(cAlza1000),0);
   if GetDataForCashReceived(mSite, mFirm_ID, mCount500, mCount1000, mTotal,mOS) then begin
     if NxIsEmptyOID(mFirm_ID) then begin
       NxShowSimpleMessage('Nebyla vybrána firma, ukončuji.',mSite);
       exit;
     end;
     if not(((mCount500*500)+(mCount1000*1000))=mTotal) then begin
       NxShowSimpleMessage('Součet hodnot poukazů se nerovná celkové částce, ukončuji.',mSite);
       exit;
     end;
     if (mCount500>mStoreCount500) or (mCount1000>mStoreCount1000) then begin
      NxShowSimpleMessage('Nedostatečný počet šeků skladem.'+#13#10+#13#10+
                          'Hodnota 500       Požadováno:   '+FloatToStr(mCount500)+'     Skladem:     '+FloatToStr(mStoreCount500)+#13#10+
                          'Hodnota 1000      Požadováno:   '+FloatToStr(mCount1000)+'     Skladem:     '+FloatToStr(mStoreCount1000)+#13#10+#13#10+
                          'Ukončuji.',msite);
      exit;
     end;
     mBODBO:=mOS.CreateObject(Class_BillOfDelivery);
     mBODBO.new;
     mBODBO.prefill;
     mBODBO.SetFieldValueAsString('DocQueue_ID',cStoreDocQueue_ID);
     mBODBO.SetFieldValueAsString('Firm_ID',mFirm_ID);
     mRows:=mBODBO.GetLoadedCollectionMonikerForFieldCode(mBODBO.GetFieldCode('Rows'));
     for i:=0 to mRows.count-1 do mRows.BusinessObject[i].MarkForDelete;
     if mCount500>0 then begin
       mBatchList:=TStringList.Create;
       mOS.SQLSelect('Select sb.id from storebatches sb left join storesubbatches ssb on sb.id=ssb.storebatch_id where ssb.quantity>0 and sb.storecard_id='+QuotedStr(cAlza500)+' order by sb.ExpirationDate$Date', mBatchList);
       mBODRowBO:=mRows.AddNewObject;
       mBODRowBO.Prefill;
       mBODRowBO.SetFieldValueAsInteger('RowType',3);
       mBODRowBO.SetFieldValueAsString('Store_ID',cStore_ID);
       mBODRowBO.SetFieldValueAsString('StoreCard_ID',cAlza500);
       mBODRowBO.SetFieldValueAsFloat('Quantity',mCount500);
       mBODRowBO.SetFieldValueAsString('Division_ID',cDivision_ID);
       mBODRowBO.SetFieldValueAsString('BusTransaction_ID', cBusTransaction_ID);
       mDRBRows:=mBODRowBO.GetLoadedCollectionMonikerForFieldCode(mBODRowBO.GetFieldCode('DocRowBatches'));
       for i:=0 to Trunc(mCount500)-1 do begin
         mDRBBO:=mDRBRows.AddNewObject;
         mDRBBO.Prefill;
         mDRBBO.SetFieldValueAsString('StoreBatch_ID',mBatchList.strings[i]);
       end;
       mBatchList.free;
     end;
     if mCount1000>0 then begin
       mBatchList:=TStringList.Create;
       mOS.SQLSelect('Select sb.id from storebatches sb left join storesubbatches ssb on sb.id=ssb.storebatch_id where ssb.quantity>0 and sb.storecard_id='+QuotedStr(cAlza1000)+' order by sb.ExpirationDate$Date', mBatchList);
       mBODRowBO:=mRows.AddNewObject;
       mBODRowBO.Prefill;
       mBODRowBO.SetFieldValueAsInteger('RowType',3);
       mBODRowBO.SetFieldValueAsString('Store_ID',cStore_ID);
       mBODRowBO.SetFieldValueAsString('StoreCard_ID',cAlza1000);
       mBODRowBO.SetFieldValueAsFloat('Quantity',mCount1000);
       mBODRowBO.SetFieldValueAsString('Division_ID',cDivision_ID);
       mBODRowBO.SetFieldValueAsString('BusTransaction_ID', cBusTransaction_ID);
       mDRBRows:=mBODRowBO.GetLoadedCollectionMonikerForFieldCode(mBODRowBO.GetFieldCode('DocRowBatches'));
       for i:=0 to Trunc(mCount1000)-1 do begin
         mDRBBO:=mDRBRows.AddNewObject;
         mDRBBO.Prefill;
         mDRBBO.SetFieldValueAsString('StoreBatch_ID',mBatchList.strings[i]);
       end;
       mBatchList.Free;
     end;
     mBODBO.save;
                mInputParams := TNxParameters.Create;
                mParam := mInputParams.GetOrCreateParam(dtString, 'CashDesk_ID');
                mParam.AsString := cCashDesk_ID;
                mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                mParam.AsString := cDocQueue_ID;
                mImportMan := NxCreateDocumentImportManager(mOS, Class_BillOfDelivery, Class_CashReceived);
                mImportMan.AddInputDocument(mBODBO.OID);
                mImportMan.LoadParams(mInputParams);
                mImportMan.Execute;
                mImportMan.CheckOutputDocument;
                if Assigned(mImportMan.OutputDocument) then begin
                      mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', cDocQueue_ID); // musi byt...
                      mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID',mFirm_ID);
                      mImportMan.OutputDocument.SetFieldValueAsBoolean('PricesWithVAT',True);
                      mRows:=mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
                      for i:=0 to mRows.count-1 do begin
                        if mRows.BusinessObject[i].GetFieldValueAsInteger('RowType')=3 then begin
                          if mRows.BusinessObject[i].GetFieldValueAsString('StoreCard_ID')=cAlza500 then
                              mRows.BusinessObject[i].SetFieldValueAsFloat('UnitPrice',-500);
                          if mRows.BusinessObject[i].GetFieldValueAsString('StoreCard_ID')=cAlza1000 then
                              mRows.BusinessObject[i].SetFieldValueAsFloat('UnitPrice',-1000);
                        end;
                      end;
                      mImportMan.OutputDocument.Save;
                      mSite.ShowSite(Site_CashReceived, True, 'QueryByUserDynSQLCondition;A.ID = '+QuotedStr(mImportMan.OutputDocument.OID));
                end;
                mImportMan.Free;
                mInputParams.Free;



   end;
 end;
end;

Procedure SendAlza(Sender:TComponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mBO:TNxCustomBusinessObject;
 mTO, mMailName, mFileName, mfilename2:string;
 mList:TStringList;
begin
 mSite:=TComponent(Sender).DynSite;
 mOS:=TDynSiteForm(mSite).BaseObjectSpace;
 mBO:=TDynSiteForm(mSite).CurrentObject;
 if Assigned(mBO) then begin
   if NxMessageBox('Dotaz',' Přejete si odeslat '+mBO.DisplayName+'?' , mdConfirm, mdbYesNo, 0, 0, False, msite) = mrYes then begin
      mList:=TStringList.Create;
      mList.Add(mbo.OID);
      mTO:=mBO.GetFieldValueAsString('Firm_ID.ElectronicAddress_ID.Databox');
      mFileName:=cFileName;
      mFileName2:=NxSearchReplace(mbo.DisplayName,'/','-',[srAll])+'.pdf';
      CFxReportManager.PrintByIDs(NxCreateContext(mOS),mList,GetDynSource(mOS,cReport_ID),cReport_ID,rtoFile,pekPDF,NxGetTempDir,mFileName);
      CFxReportManager.PrintByIDs(NxCreateContext(mOS),mList,GetDynSource(mOS,cCashReport_ID),cCashReport_ID,rtoFile,pekPDF,NxGetTempDir,mFileName2);
      mMailName:=SendInternalMail(mOS,mTO,'Zasíláme Vám poukazy ALZA z akce OBB Šekobbraní',NxGetTempDir+mFileName,NxGetTempDir+mFileName2,mbo.GetFieldValueAsString('Firm_ID'),mbo.GetFieldValueAsString('CashDesk_ID.Division_ID'),'');
      NxShowSimpleMessage('Vytvořil jsem mail '+mMailName,mSite);
   end;
 end;
end;


Function SendInternalMail(AOS:TNxCustomObjectSpace; ATo:String; ASubject:String; AAtachement, AAtachement2:String; AFirm_ID:String; ADivision_ID:String; ABusTransaction_ID:String): string;
Var
  mMailBO:TNxCustomBusinessObject;
  mMRecipients:TNxCustomBusinessMonikerCollection;
  mMailRecipient:TNxCustomBusinessObject;
  mContext: TNxContext;
  mOS: TNxCustomObjectSpace;
  i:integer;
begin
  Result:='';
  mContext:=NxCreateNotLoggedContext(AOS);
  mContext.LogOn('Josef Novák','XDQcJZwc2SKRfZ1epob8');
  mOS:= mContext.GetObjectSpace;
  if not(ato='') then begin
   try
     mMailBO:=mOS.CreateObject('5C1HWDQDR3J4NAAYZRO5PWHLWK');
     mMailBO.New;
     mMailBO.Prefill;
     mMailBO.SetFieldValueAsString('EmailAccount_ID',cEmailAccount_ID);
     mMailBO.SetFieldValueAsString('Subject',ASubject);
     mMailbo.SetFieldValueAsInteger('SentState',1);
     mMailBO.SetFieldValueAsString('Firm_ID',AFirm_ID);
     mMailBO.SetFieldValueAsString('Division_ID',ADivision_ID);
     mMailBO.SetFieldValueAsString('BusTransaction_ID',ABusTransaction_ID);
     mMailBO.SetFieldValueAsBoolean('X_dont_delete',true);
     mMailBO.SetFieldValueAsInteger('DataBoxMessSent_ID.DmType',2);
     mMailBO.SetFieldValueAsBoolean('DataBoxMessSent_ID.PersonalDelivery',true);
     mMRecipients:=mMailBO.GetLoadedCollectionMonikerForFieldCode(mMailBO.GetFieldCode('Recipients'));
     for i:=0 to mMRecipients.count-1 do mMRecipients.BusinessObject[i].MarkForDelete;
     mMailRecipient:=mMRecipients.AddNewObject;
     mMailRecipient.SetFieldValueAsString('Email',ATo);

     if not(AAtachement='') then begin
      if FileExists(AAtachement) then TNxEmailSent(mMailBO).AttachFile(AAtachement);

     end;
     if not(AAtachement2='') then begin
      if FileExists(AAtachement2) then TNxEmailSent(mMailBO).AttachFile(AAtachement2);

     end;

     mMailBO.Save;
     Result:=mMailBO.DisplayName;
     mMailBO.free;
   except
     Result:='Nepovedlo se vytvořit datovou zprávu. '+ExceptionMessage;
   end;
  end;
end;

function GetDynSource (AOS : TNxCustomObjectSpace; AValue : string) : String;

const
  cSQL = 'SELECT DataSource FROM Reports WHERE ID=''%s'' ';
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