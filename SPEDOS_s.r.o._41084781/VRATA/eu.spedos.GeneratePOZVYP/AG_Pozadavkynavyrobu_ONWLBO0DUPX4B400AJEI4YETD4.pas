uses 'eu.spedos.GeneratePOZVYP.progress', 'eu.spedos.GeneratePOZVYP.fce', 'eu.spedos.GeneratePOZVYP.const';

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Nahrej data';
  mAction.Hint := 'Nahraje data výroby';
  mAction.Category := 'tabList';
  mAction.OnExecute := @CreatePOZ;

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Email';
  mAction.Hint := 'Nahraje data výroby';
  mAction.Category := 'tabList';
  mAction.OnExecute := @email;
end;

Procedure Email(sender:tcomponent);
var
 mSite:TSiteForm;
begin
 try
  mSite:=TComponent(sender).dynsite;
  //CFxInternet.SMSendMailWithMoreFiles(csOpenSSL,cMailLogin,cMailPassword,cMailSMTP,465,cMailFrom,'gajdos@spedos.cz','','','Chyba mailu 465','Nepovedlo se poslat mail ',commAsText,'');
 Except
  NxShowSimpleMessage(ExceptionMessage,mSite);
 end;
end;


Procedure CreatePOZ(OS: TNxCustomObjectSpace; sender:TComponent);
var
 mSite:TSiteForm;
 mOS: TNxCustomObjectSpace;
 mOpenDlg:TOpenDialog;
 mXMLHead:TNxScriptingXMLWrapper;
 i,j,k,l,m, n, x, y, mOR, mRowPosindex :integer;
 mProductCard_ID, mBusOrder_ID, mStoreCard_ID:String;
 mSMBO, mOutputRow, mInputRow, mRowBO, mProductRow, mOperationRow, mStoreCardBO, mUnitBO, mJobOrder, mStoreBatchBO:TNxCustomBusinessObject;
 mRows, mInputs, mOutputs,mOperationRows, mUnits, mOutPutItems, mPLMJobOrdersSNs:TNxCustomBusinessMonikerCollection;
 mRelation:TNxCustomBusinessObject;
 mOrder_ID,mPLMJobOrder_ID, mTO, mFirm_ID, mNewSerial, mWorkPlace_ID, mProduceRequest_ID, mPozice2_ID:string;
 mVYPList, mProduceRequestList:TStringList;
 awaring,aerror:string;
 mText, mDivision_ID, mRowBusOrder_ID, mRowQunit, mRowBusTransaction_ID, mPozice_OD,  mVatRate_ID, mDRCArticle_ID, mRow_ID :string;
 mRowQuantity, mRowUnitPrice, mDiscount:Extended;
 mOrder, mOrderRow, mNewOrderRow:TNxCustomBusinessObject;
 mOrderRows:TNxCustomBusinessMonikerCollection;
 mVATMode:integer;
 mLocalAmountWithoutVAT, mAmountWithoutVAT, mLocalAmount, mAmount,mRowTotalPrice:Extended;
 mJSON:TJSONSuperObject;
 mWinHTTP: Variant;
 mTempBO,mOrigSCBO, mCloneCardBO:TNxCustomBusinessObject;
 mClonedProductCard_ID, aWarr, aErr,mOrderStoreCard_ID:string;
begin
 mSite:=TComponent(sender).DynSite;
 mVYPList:=TStringList.Create;
 mOS:=msite.BaseObjectSpace;
// mOS:=OS;
 mOpenDlg := TOpenDialog.Create(Sender);
 mopenDLG.Filter :=  'Soubory s daty (*.xml)|*.xml';
  try
    if mOpenDlg.Execute then begin
      try
        mXMLHead:=TNxScriptingXMLWrapper.create;
        mXMLHead.loadFromFile(mOpenDlg.FileName);
        j:=mXMLHead.getElementsCountInArray('item');
        l:=mXMLHead.getElementAsInteger('item['+IntToStr(0)+'].pocet');
        for m:=1 to l do begin
        //ProgressInit(mSite, 'Import požadavku '+inttostr(m)+'...', j);
         for i:=0 to j-1 do begin
            //první položka
            if i=0 then begin
               mSMBO:=mOS.CreateObject(Class_PLMProduceRequest);
               mSMBO.new;
               mSMBO.Prefill;
               mProductCard_ID:=GetStoreCard_ID(mOS,mXMLHead.getElementAsString('item['+IntToStr(i)+'].karta_vyrobku'));
               mBusOrder_ID:=GetBusOrder_ID(mOS,mXMLHead.getElementAsString('item['+IntToStr(i)+'].zak_cislo'));
               //NxShowSimpleMessage(msmbo.GetFieldValueAsString('Firm_ID')+' po prefillu',nil);
               mTO:= mXMLHead.getElementAsString('item['+IntToStr(i)+'].email');
               mSMBO.SetFieldValueAsString('X_Pozice_OD',GetPosition_ID(mOS,mXMLHead.getElementAsString('item['+IntToStr(i)+'].id_pozice')));
               //začátek kontroly na obdv
               mRow_ID:=GetOBDVRow_ID(mOS,mProductCard_ID,mBusOrder_ID,mSMBO.GetFieldValueAsString('X_Pozice_OD'));
               if NxIsEmptyOID(mrow_ID) then begin
                // NxShowSimpleMessage('Nepovedlo se dohledat kartu výrobku '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].karta_vyrobku')+'.',mSite);
                  if (NxIsValidEMail(mto,false)) then
           //Gajdos  CFxInternet.SMTPSendMailWithMoreFiles(csOpenSSL,cMailLogin,cMailPassword,cMailSMTP,25,cMailFrom,mto,'','','Chyba importu','Nepovedlo se dohledat kartu výrobku '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].karta_vyrobku')+' na OBDV a pozici '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].id_pozice')+'. Výrobní číslo '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].vyrobni_cislo'),commAsText,'') else
                  SendInternalMail(OS,mto,'','Chyba importu','Nepovedlo se dohledat kartu výrobku '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].karta_vyrobku')+' na OBDV a pozici '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].id_pozice')+'. Výrobní číslo '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].vyrobni_cislo'),'','','','','','') else
           //Gajdos  CFxInternet.SMTPSendMailWithMoreFiles(csOpenSSL,cMailLogin,cMailPassword,cMailSMTP,25,cMailFrom,cEmail,'','','Chyba importu','Nepovedlo se dohledat kartu výrobku '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].karta_vyrobku')+' na OBDV a pozici '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].id_pozice')+'. Výrobní číslo '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].vyrobni_cislo'),commAsText,'');
                SendInternalMail(OS,mto,'','Chyba importu','Nepovedlo se dohledat kartu výrobku '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].karta_vyrobku')+' na OBDV a pozici '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].id_pozice')+'. Výrobní číslo '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].vyrobni_cislo'),'','','','','','');
                 //ProgressDispose();
                 exit;
               end;

               //konec kontroly na obdv
               if NxIsEmptyOID(mProductCard_ID) then begin
                // NxShowSimpleMessage('Nepovedlo se dohledat kartu výrobku '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].karta_vyrobku')+'.',mSite);
                  if (NxIsValidEMail(mto,false)) then
           //Gajdos  CFxInternet.SMTPSendMailWithMoreFiles(csOpenSSL,cMailLogin,cMailPassword,cMailSMTP,25,cMailFrom,mto,'','','Chyba importu','Nepovedlo se dohledat kartu výrobku '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].karta_vyrobku')+'. Výrobní číslo '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].vyrobni_cislo'),commAsText,'') else
                  SendInternalMail(OS,mto,'','Chyba importu','Nepovedlo se dohledat kartu výrobku '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].karta_vyrobku')+'. Výrobní číslo '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].vyrobni_cislo'),'','','','','','') else
           //Gajdos  CFxInternet.SMTPSendMailWithMoreFiles(csOpenSSL,cMailLogin,cMailPassword,cMailSMTP,25,cMailFrom,cEmail,'','','Chyba importu','Nepovedlo se dohledat kartu výrobku '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].karta_vyrobku')+'. Výrobní číslo '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].vyrobni_cislo'),commAsText,'');
                  SendInternalMail(OS,mto,'','Chyba importu','Nepovedlo se dohledat kartu výrobku '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].karta_vyrobku')+'. Výrobní číslo '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].vyrobni_cislo'),'','','','','','');
                 //ProgressDispose();
                 exit;
               end;
               mClonedProductCard_ID:='';
               mClonedProductCard_ID:=GetStoreCard_ID(mOS,mXMLHead.getElementAsString('item['+IntToStr(i)+'].karta_vyrobku')+' - '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].zak_cislo'));
               if NxIsEmptyOID(mClonedProductCard_ID) then begin
                  mOrigSCBO:=mos.CreateObject(Class_StoreCard);
                  mOrigSCBO.Load(mProductCard_ID,nil);
                  mCloneCardBO:=mOrigSCBO.Clone;
                  mCloneCardBO.SetFieldValueAsString('Code', mXMLHead.getElementAsString('item['+IntToStr(i)+'].karta_vyrobku')+' - '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].zak_cislo'));
                  mCloneCardBO.SetFieldValueAsString('X_MasterStoreCard_ID',mProductCard_ID);
                  mCloneCardBO.save;
                  mClonedProductCard_ID:=mCloneCardBO.OID;
               end;
               msmbo.SetFieldValueAsString('DocQueue_ID','1F10000101');
               mSMBO.SetFieldValueAsString('StoreCard_ID',mClonedProductCard_ID);
               mSMbo.SetFieldValueAsString('BusOrder_ID',mBusOrder_ID);
               if not(NxIsEmptyOID(mSMBO.GetFieldValueAsString('BusOrder_ID.Firm_ID'))) then
               mSMBO.SetFieldValueAsString('Firm_ID',mSMBO.GetFieldValueAsString('BusOrder_ID.Firm_ID'));
               //NxShowSimpleMessage(msmbo.GetFieldValueAsString('Firm_ID')+' po busorder',nil);
               mSMBO.SetFieldValueAsFloat('Quantity',1);
               msmbo.SetFieldValueAsFloat('CorrectedQuantity',1);
               msmbo.SetFieldValueAsString('Division_ID',GetDivision_ID(mOS,mXMLHead.getElementAsString('item['+IntToStr(i)+'].stredisko')));

               //if not(NxIsEmptyOID(mSMBO.GetFieldValueAsString('StoreCard_ID.X_Store_ID'))) then mSMBO.SetFieldValueAsString('Store_ID',mSMBO.GetFieldValueAsString('StoreCard_ID.X_Store_ID')) else
               mSMBO.SetFieldValueAsString('Store_ID',cProduceStore);
               if msmbo.GetFieldValueAsString('Division_ID')='1I00000101' then mSMBO.SetFieldValueAsString('Store_ID','2600000101');
               if not(NxIsEmptyOID(mSMBO.GetFieldValueAsString('StoreCard_ID.X_Store_ID'))) then mSMBO.SetFieldValueAsString('Store_ID',mSMBO.GetFieldValueAsString('StoreCard_ID.X_Store_ID'));
               msmbo.SetFieldValueAsString('U_vyrobni_cislo',GetSN(mOS,mXMLHead.getElementAsString('item['+IntToStr(i)+'].vyrobni_cislo'),m-1));
               if UpperCase(AnsiRightStr(mXMLHead.getElementAsString('item['+IntToStr(i)+'].vyrobni_cislo'),1))='X' then begin
                // NxShowSimpleMessage('Nepovedlo se dohledat kartu výrobku '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].karta_vyrobku')+'.',mSite);
                  if (NxIsValidEMail(mto,false)) then
           //Gajdos  CFxInternet.SMTPSendMailWithMoreFiles(csOpenSSL,cMailLogin,cMailPassword,cMailSMTP,25,cMailFrom,mto,'','','Chyba importu','Nepovedlo se dohledat výrobní číslo '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].karta_vyrobku')+'. Výrobní číslo '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].vyrobni_cislo'),commAsText,'') else
                  SendInternalMail(OS,mto,'','Chyba importu','Nepovedlo se dohledat výrobní číslo '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].karta_vyrobku')+'. Výrobní číslo '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].vyrobni_cislo'),'','','','','','') else
           //Gajdos  CFxInternet.SMTPSendMailWithMoreFiles(csOpenSSL,cMailLogin,cMailPassword,cMailSMTP,25,cMailFrom,cEmail,'','','Chyba importu','Nepovedlo se dohledat výrobní číslo '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].karta_vyrobku')+'. Výrobní číslo '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].vyrobni_cislo'),commAsText,'');
                  SendInternalMail(OS,mto,'','Chyba importu','Nepovedlo se dohledat výrobní číslo '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].karta_vyrobku')+'. Výrobní číslo '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].vyrobni_cislo'),'','','','','','');
                 //ProgressDispose();
                 exit;
               end;
               msmbo.SetFieldValueAsString('U_ID_vyrobku',GetIDVyrobkuOD(mOS,msmbo.GetFieldValueAsString('U_vyrobni_cislo')));
               mSMBO.SetFieldValueAsString('X_group',mXMLHead.getElementAsString('item['+IntToStr(i)+'].vyrobni_cislo'));
               msmbo.SetFieldValueAsString('U_ID_Pozice',mXMLHead.getElementAsString('item['+IntToStr(i)+'].id_pozice'));
               mTO:= mXMLHead.getElementAsString('item['+IntToStr(i)+'].email');

               if not(NxIsEmptyOID(msmbo.GetFieldValueAsString('X_pozice_OD'))) then begin
                mFirm_ID:=GetFirm_ID(mOS, mSMBO.GetFieldValueAsString('X_Pozice_OD'),mSMBO.GetFieldValueAsString('StoreCard_ID'));
                if not(NxIsEmptyOID(mFirm_ID)) then msmbo.SetFieldValueAsString('Firm_ID',mFirm_ID);
               end;
               //NxShowSimpleMessage(msmbo.GetFieldValueAsString('Firm_ID')+' po pozici',nil);
               mSMBO.SetFieldValueAsDateTime('Schedule$DATE',mXMLHead.getElementAsDateTime('item['+IntToStr(i)+'].datum_vyroby'));
               mSMBO.SetFieldValueAsDateTime('PlanedStartAt$DATE',mXMLHead.getElementAsDateTime('item['+IntToStr(i)+'].datum_vyroby')-14);
               // generování SČ 16.9.2021 MASAMASA
              { mNewSerial:=GetNewSerial(mOS,mSMBO.GetFieldValueAsString('U_id_vyrobku'),mSMBO.GetFieldValueAsString('X_Pozice_OD'));
               if not(NxIsBlank(mNewSerial)) then begin
                if not(mSMBO.GetFieldValueAsString('U_vyrobni_cislo')=mNewSerial) then msmbo.SetFieldValueAsString('U_vyrobni_cislo',mNewSerial);
               end; }
               if GetCountSerial(mOS,mSMBO.GetFieldValueAsString('U_vyrobni_cislo'))>0 then begin
                // NxShowSimpleMessage('Nepovedlo se dohledat kartu výrobku '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].karta_vyrobku')+'.',mSite);
                  if (NxIsValidEMail(mto,false)) then
           //Gajdos CFxInternet.SMTPSendMailWithMoreFiles(csOpenSSL,cMailLogin,cMailPassword,cMailSMTP,25,cMailFrom,mto,'','','Chyba importu','Existuje POZ s výrobním číslem '+msmbo.GetFieldValueAsString('U_vyrobni_cislo'),commAsText,'') else
                  SendInternalMail(OS,mto,'','Chyba importu','Existuje POZ s výrobním číslem '+msmbo.GetFieldValueAsString('U_vyrobni_cislo'),'','','','','','') else
           //Gajdos CFxInternet.SMTPSendMailWithMoreFiles(csOpenSSL,cMailLogin,cMailPassword,cMailSMTP,25,cMailFrom,cEmail,'','','Chyba importu','Existuje POZ s výrobním číslem '+msmbo.GetFieldValueAsString('U_vyrobni_cislo'),commAsText,'');
                  SendInternalMail(OS,mto,'','Chyba importu','Existuje POZ s výrobním číslem '+msmbo.GetFieldValueAsString('U_vyrobni_cislo'),'','','','','','');
                 //ProgressDispose();
                 exit;
               end;
               mRows:=mSMBO.GetLoadedCollectionMonikerForFieldCode(mSMBO.GetFieldCode('Rows'));
               mOutputs:=msmbo.GetLoadedCollectionMonikerForFieldCode(msmbo.GetFieldCode('OutPuts'));
               mInputs:=msmbo.GetLoadedCollectionMonikerForFieldCode(msmbo.GetFieldCode('Inputs'));
               mrows.BusinessObject[0].SetFieldValueAsString('StoreCard_ID',mClonedProductCard_ID);
               for k:=0 to mrows.count-1 do begin
               mProductRow:=mRows.BusinessObject[k];
                if k=0 then begin
                 mInputs:=mProductRow.GetLoadedCollectionMonikerForFieldCode(mProductRow.GetFieldCode('Rows'));
                 if mInputs.count>0 then begin
                  for n:=0 to mInputs.count-1 do begin
                    mInputs.BusinessObject[n].MarkForDelete;
                  end;
                 end;
                end;

               end;
               mOutputRow:=mOutputs.BusinessObject[0];
               mOutputRow.SetFieldValueAsString('RoutineType_ID','2000000101');
               mOperationRows:=mOutputRow.GetLoadedCollectionMonikerForFieldCode(mOutputRow.GetFieldCode('PLMReqRoutines'));
               for k:=0 to mOperationRows.count-1 do begin
                 mOperationRows.BusinessObject[k].MarkForDelete;
               end;
               for k:=0 to mXMLHead.getElementsCountInArray('item['+IntToStr(0)+'].Works.work.pracoviste_kod')-1 do begin
                  if mXMLHead.getElementAsFloat('item['+IntToStr(0)+'].Works.work.pracoviste_cas['+IntToStr(k)+']')>0 then begin
                     mWorkPlace_ID:=GetWorkPlace_ID(mOS,mXMLHead.getElementAsString('item['+IntToStr(0)+'].Works.work.pracoviste_kod['+IntToStr(k)+']'));
                      if NxIsEmptyOID(mWorkPlace_ID) then begin
                        if (NxIsValidEMail(mto,false)) then
                      //Gajdos CFxInternet.SMTPSendMailWithMoreFiles(csOpenSSL,cMailLogin,cMailPassword,cMailSMTP,25,cMailFrom,mto,'','','Chyba importu pracoviště','Nepovedlo se dohledat pracoviště '+mXMLHead.getElementAsString('item['+IntToStr(0)+'].Works.work.pracoviste_kod['+IntToStr(k)+']')+' na pozici '+inttostr(i)+'. Výrobní číslo '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].vyrobni_cislo'),commAsText,'') else
                          SendInternalMail(OS,mto,'','Chyba importu pracoviště','Nepovedlo se dohledat pracoviště '+mXMLHead.getElementAsString('item['+IntToStr(0)+'].Works.work.pracoviste_kod['+IntToStr(k)+']')+' na pozici '+inttostr(i)+'. Výrobní číslo '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].vyrobni_cislo'),'','','','','','') else
                      //Gajdos CFxInternet.SMTPSendMailWithMoreFiles(csOpenSSL,cMailLogin,cMailPassword,cMailSMTP,25,cMailFrom,cEmail,'','','Chyba importu poracoviště','Nepovedlo se dohledat pracoviště '+mXMLHead.getElementAsString('item['+IntToStr(0)+'].Works.work.pracoviste_kod['+IntToStr(k)+']')+' na pozici '+inttostr(i)+'. Výrobní číslo '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].vyrobni_cislo'),commAsText,'');
                          SendInternalMail(OS,mto,'','Chyba importu pracoviště','Nepovedlo se dohledat pracoviště '+mXMLHead.getElementAsString('item['+IntToStr(0)+'].Works.work.pracoviste_kod['+IntToStr(k)+']')+' na pozici '+inttostr(i)+'. Výrobní číslo '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].vyrobni_cislo'),'','','','','','');
                          exit;

                      end;

                     mOperationRow:=mOperationRows.AddNewObject;
                     mOperationRow.Prefill;
                     mOperationRow.SetFieldValueAsString('Title',mXMLHead.getElementAsString('item['+IntToStr(0)+'].Works.work.pracoviste_nazev['+IntToStr(k)+']'));
                     mOperationRow.SetFieldValueAsString('WorkPlace_ID', mWorkPlace_ID);
                     mOperationRow.SetFieldValueAsString('Phase_ID', GetPhase_ID(mOS,mXMLHead.getElementAsString('item['+IntToStr(0)+'].Works.work.etapa['+IntToStr(k)+']')));
                     mOperationRow.SetFieldValueAsString('SalaryClass_ID',cSallaryClass_ID);
                     mOperationRow.SetFieldValueAsFloat('TAC',60*mXMLHead.getElementAsFloat('item['+IntToStr(0)+'].Works.work.pracoviste_cas['+IntToStr(k)+']'));
                     mOperationRow.SetFieldValueAsFloat('X_pocet_baliku',NxIbStrToFloat(mXMLHead.getElementAsString('item['+IntToStr(0)+'].Works.work.balik['+IntToStr(k)+']')));
                     mOperationRow.SetFieldValueAsInteger('TACUnit',1);
                     mOperationRow.SetFieldValueAsString('Note',mSMBO.GetFieldValueAsString('U_vyrobni_cislo'));
                     mOperationRow.SetFieldValueAsBoolean('Batch',true);
                     //vklad konstantni operace

                  end;
               end;
               mOperationRow:=mOperationRows.AddNewObject;
               mOperationRow.Prefill;
               mOperationRow.SetFieldValueAsString('Title','Finální kontrola');
               mOperationRow.SetFieldValueAsString('WorkPlace_ID', cWorkPlace_ID);
               mOperationRow.SetFieldValueAsString('Phase_ID', cPhase_ID);
               mOperationRow.SetFieldValueAsString('SalaryClass_ID',cSallaryClass_ID);
               mOperationRow.SetFieldValueAsFloat('TAC',0);
               mOperationRow.SetFieldValueAsInteger('TACUnit',0);
               mOperationRow.SetFieldValueAsBoolean('Batch',False);
               mOperationRow.SetFieldValueAsBoolean('Finished',true);
               mOperationRow.SetFieldValueAsString('Note',mSMBO.GetFieldValueAsString('U_vyrobni_cislo'));
            end;
            //vnitřek
            if i>0 then begin
              if ElementExist(mXMLHead,'item['+IntToStr(i)+'].Stock.mater_karta')
                 and ElementExist(mXMLHead,'item['+IntToStr(i)+'].Stock.sklad')
                 and ElementExist(mXMLHead,'item['+IntToStr(i)+'].Stock.etapa')
                 and ElementExist(mXMLHead,'item['+IntToStr(i)+'].Stock.mnozstvi') then begin
              if (mXMLHead.getElementAsFloat('item['+IntToStr(i)+'].Stock.Mnozstvi')>0)  then begin
              if not((mXMLHead.getElementAsString('item['+IntToStr(i)+'].Stock.mater_karta')='') or (mXMLHead.getElementAsString('item['+IntToStr(i)+'].Stock.mater_karta')='0')) then begin
               mStoreCard_ID:=GetStoreCard_ID(mOS,mXMLHead.getElementAsString('item['+IntToStr(i)+'].Stock.mater_karta'));
               if NxIsEmptyOID(mStoreCard_ID) then begin
                 if (NxIsValidEMail(mto,false)) then
              //Gajdos CFxInternet.SMTPSendMailWithMoreFiles(csOpenSSL,cMailLogin,cMailPassword,cMailSMTP,25,cMailFrom,mto,'','','Chyba importu materiál','Nepovedlo se dohledat kartu materiálu '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].Stock.mater_karta')+' na pozici '+inttostr(i)+' s množstvím '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].Stock.Mnozstvi')+'. Výrobní číslo '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].vyrobni_cislo'),commAsText,'') else
                  SendInternalMail(OS,mto,'','Chyba importu materiál','Nepovedlo se dohledat kartu materiálu '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].Stock.mater_karta')+' na pozici '+inttostr(i)+' s množstvím '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].Stock.Mnozstvi')+'. Výrobní číslo '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].vyrobni_cislo'),'','','','','','') else
              //Gajdos CFxInternet.SMTPSendMailWithMoreFiles(csOpenSSL,cMailLogin,cMailPassword,cMailSMTP,25,cMailFrom,cEmail,'','','Chyba importu materiál','Nepovedlo se dohledat kartu materiálu '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].Stock.mater_karta')+' na pozici '+inttostr(i)+' s množstvím '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].Stock.Mnozstvi')+'. Výrobní číslo '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].vyrobni_cislo'),commAsText,'');
                  SendInternalMail(OS,mto,'','Chyba importumateriál','Nepovedlo se dohledat kartu materiálu '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].Stock.mater_karta')+' na pozici '+inttostr(i)+' s množstvím '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].Stock.Mnozstvi')+'. Výrobní číslo '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].vyrobni_cislo'),'','','','','','');

                 //if mXMLHead.getElementAsString('item['+IntToStr(i)+'].Stock.mater_karta')='0' then NxShowSimpleMessage('je tam 0',msite);
                 //NxShowSimpleMessage('Nepovedlo se dohledat kartu materiálu '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].Stock.mater_karta')+' na pozici '+inttostr(i)+' s množstvím '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].Stock.Mnozstvi')+'.',mSite);
                 //ProgressDispose();
                 exit;
               end;
               if not(NxIsEmptyOID(mStoreCard_ID)) then begin
               mInputRow:=mInputs.AddNewObject;
               mInputRow.Prefill;
               mInputRow.SetFieldValueAsString('InputItem_ID.RealStoreCard_ID',mStoreCard_ID);
               mInputRow.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
               mInputRow.SetFieldValueAsString('InputItem_ID.SupposedStore_ID',GetStore_ID(mOS,mXMLHead.getElementAsString('item['+IntToStr(i)+'].Stock.Sklad')));
               mInputRow.SetFieldValueAsString('InputItem_ID.Phase_ID',GetPhase_ID(mOS,mXMLHead.getElementAsString('item['+IntToStr(i)+'].Stock.etapa')));
               minputrow.SetFieldValueAsFloat('InputItem_ID.UnitQuantity',mXMLHead.getElementAsFloat('item['+IntToStr(i)+'].Stock.Mnozstvi'));
               //NxScriptingLog.WriteEvent(logInfo,'vložím obchodní případ '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].Stock.obch_pripad')+' materiál '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].Stock.mater_karta'));
               mInputRow.SetFieldValueAsString('InputItem_ID.U_BusTransaction_ID',GetBT_ID(mOS,mXMLHead.getElementAsString('item['+IntToStr(i)+'].Stock.obch_pripad')));
               if i=1 then mSMBO.SetFieldValueAsString('BusTransaction_ID',GetBT_ID(mOS,mXMLHead.getElementAsString('item['+IntToStr(i)+'].Stock.obch_pripad')));
               if mXMLHead.getElementAsString('item['+IntToStr(i)+'].Stock.vydej')='V' then mInputRow.SetFieldValueAsInteger('Issue',1);
               end;
              end;
             end;
             end;
            end;
            //po poslední položce
            if i=j-1 then begin
              // NxShowSimpleMessage(msmbo.GetFieldValueAsString('Firm_ID')+' před uložením',nil);
               msmbo.save;

               mProduceRequest_ID:=msmbo.OID;
               //CalculateDataForPOZ(mSMBO);
               try
                 TNxPLMProduceRequest(mSMBO).Calculate(aWarr,aErr);
                 mJSON:= TJSONSuperObject.CreateNew;
                 mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
                 mWinHTTP.Open('POST','https://sod.spedos.cz/api/api.abra-get-zakazka.php?cis_zak='+ mSMBO.GetFieldValueAsString('BusOrder_ID.Code')+'&Rodneico='+ GetICO(mSMBO.ObjectSpace));
                 mWinHTTP.SetRequestHeader('Authorization','Basic YUJyYTpza1M4Zi1zeFI=');
                 mWinHTTP.Send();
                 mJSON := TJSONSuperObject.ParseString(mWinHTTP.ResponseText, True);
                 if mJSON.D['cena']>0 then begin
                   mTempBO:=mOS.CreateObject(Class_BusOrder);
                   mTempBO.load(mSMBO.GetFieldValueAsString('BusOrder_ID'),nil);
                   mTempBO.SetFieldValueAsFloat('X_CalculatedPrice', mJSON.D['cena']);
                   mTempBO.save;
                   mTempBO.free;
                 end;
               Except

               end;
               try
                 //mOrder_ID:=GetOrder_ID(mOS, mSMBO.GetFieldValueAsString('X_Pozice_OD'),mSMBO.GetFieldValueAsString('StoreCard_ID'));
                 //dohledávání podle originální karty, je v původní objednávce
                 mOrder_ID:=GetOrder_ID(mOS, mSMBO.GetFieldValueAsString('X_Pozice_OD'),mProductCard_ID);
                 mPozice2_ID:=mSMBO.GetFieldValueAsString('X_Pozice_OD');
                 msmbo.Free;
                 if not(NxIsEmptyOID(mOrder_ID)) then begin
                 mRelation:=mOS.CreateObject(Class_Relation);
                 mRelation.new;
                 mrelation.SetFieldValueAsString('LeftSide_ID',mOrder_ID);
                 mrelation.SetFieldValueAsString('RightSide_ID',mProduceRequest_ID);
                 mrelation.SetFieldValueAsInteger('Rel_Def',1620);
                 mrelation.save;
                 mrelation.free;
                 mRelation:=mOS.CreateObject(Class_Relation);
                 mRelation.new;
                 mrelation.SetFieldValueAsString('LeftSide_ID',mProduceRequest_ID);
                 mrelation.SetFieldValueAsString('RightSide_ID',mOrder_ID);
                 mrelation.SetFieldValueAsInteger('Rel_Def',1621);
                 mrelation.save;
                 mrelation.free;
                 //povolení vazeb na OBDV a zdvojkovaní skladových řádku 5.2.2020
                 Try
                   mOrder:=mOS.CreateObject(Class_ReceivedOrder);
                   mOrder.Load(mOrder_ID,nil);
                   mOrderRows:=mOrder.GetLoadedCollectionMonikerForFieldCode(mOrder.GetFieldCode('Rows'));
                    for mOR:=0 to mOrderRows.count-1 do begin
                      mDivision_ID:='';
                      mText:='';
                      mRowBusOrder_ID:='';
                      mRowQunit:='';
                      mRowBusTransaction_ID:='';
                      mRowQuantity:=0;
                      mRowUnitPrice:=0;
                      mPozice_OD:='';
                      mRowPosindex:=0;
                      mVatRate_ID:='';
                      mDRCArticle_ID:='';
                      mVATMode:=0;
                      mDiscount:=0;
                      mOrderRow:=mOrderRows.BusinessObject[mOR];
                      NxScriptingLog.EnterSection('CorrRows',logInfo);
                      if mOrderRow.GetFieldValueAsInteger('RowType')=3 then begin
                         NxScriptingLog.WriteEvent(logInfo,'jsem na skladovém řádku '+mOrderRow.GetFieldValueAsString('StoreCard_ID.Code')+' '+mOrderRow.GetFieldValueAsString('StoreCard_ID.name')+' '+mOrderRow.oid);
                        //sklad 773 a nesmí být obchodní případ 48  pokud je sklad 773 změnit, ale když bude 48 tak neměnit
                         //záměna výrobku na OBDV
                           if (mOrderRow.GetFieldValueAsString('X_Pozice_OD')=mPozice2_ID) and (mOrderRow.GetFieldValueAsBoolean('StoreCard_ID.IsProduct'))
                            and ((mOrderRow.GetFieldValueAsString('Store_ID.Code')='773') or (mOrderRow.GetFieldValueAsString('Store_ID.Code')='901')) then begin
                               mRowUnitPrice:=mOrderRow.GetFieldValueAsFloat('UnitPrice');
                               mOrderRow.SetFieldValueAsString('StoreCard_ID',mClonedProductCard_ID);
                               mOrderRow.SetFieldValueAsFloat('UnitPrice',mRowUnitPrice);
                            end;
                         //konez záměny
                         if (mOrderRow.GetFieldValueAsString('X_Pozice_OD')=mPozice2_ID) and not(mOrderRow.GetFieldValueAsBoolean('StoreCard_ID.IsProduct'))
                            and ((mOrderRow.GetFieldValueAsString('Store_ID.Code')='773') or (mOrderRow.GetFieldValueAsString('Store_ID.Code')='901')) then begin
                            NxScriptingLog.WriteEvent(loginfo,'jsem po podmínce na sklad');
                            if not((mOrderRow.GetFieldValueAsString('BusTransaction_ID.Code')='48') or (mOrderRow.GetFieldValueAsString('BusTransaction_ID.Code')='52') or (mOrderRow.GetFieldValueAsString('BusTransaction_ID.Code')='44') or (mOrderRow.GetFieldValueAsString('BusTransaction_ID.Code')='36') or (mOrderRow.GetFieldValueAsString('BusTransaction_ID.Code')='99') or NxIsEmptyOID(mOrderRow.GetFieldValueAsString('BusTransaction_ID'))) then begin
                            NxScriptingLog.WriteEvent(logInfo,'jdeme zaměňovat');
                            mRowPosindex:=mOrderRow.GetFieldValueAsInteger('PosIndex');
                            mText:=mOrderRow.GetFieldValueAsString('StoreCard_ID.Name');
                            mRowQuantity:=mOrderRow.GetFieldValueAsFloat('Quantity');
                            mRowQunit:=mOrderRow.GetFieldValueAsString('Qunit');
                            mRowUnitPrice:=mOrderRow.GetFieldValueAsFloat('UnitPrice');
                            mRowTotalPrice:=mOrderRow.GetFieldValueAsFloat('TotalPrice');
                            mVatRate_ID:=mOrderRow.GetFieldValueAsString('VatRate_ID');
                            mDivision_ID:=mOrderRow.GetFieldValueAsString('Division_ID');
                            mRowBusOrder_ID:=mOrderRow.GetFieldValueAsString('BusOrder_ID');
                            mRowBusTransaction_ID:=mOrderRow.GetFieldValueAsString('BusTransaction_ID');
                            mPozice_OD:=mOrderRow.GetFieldValueAsString('X_Pozice_OD');
                            mDRCArticle_ID:=mOrderRow.GetFieldValueAsString('DRCArticle_ID');
                            mVATMode:=mOrderRow.GetFieldValueAsInteger('VATMode');
                            mDiscount:=mOrderRow.GetFieldValueAsFloat('RowDiscount');
                            mOrderStoreCard_ID:=mOrderRow.GetFieldValueAsString('StoreCard_ID');
                            mOrderRow.MarkForDelete;
                            //mOrder.save;
                            NxScriptingLog.WriteEvent(logInfo,'po smazání '+FloatToStr(mOrder.GetFieldValueAsFloat('Amount')));
                            mNewOrderRow:=mOrderRows.AddNewObject;
                            mNewOrderRow.SetFieldValueAsInteger('RowType',2);
                            mNewOrderRow.SetFieldValueAsInteger('Posindex',mRowPosindex);
                            mNewOrderRow.SetFieldValueAsInteger('VATMode', mVATMode);
                            mNewOrderRow.SetFieldValueAsString('Text',mText);
                            mNewOrderRow.SetFieldValueAsFloat('Quantity',mRowQuantity);
                            mNewOrderRow.SetFieldValueAsString('Qunit',mRowQunit);
                            mNewOrderRow.SetFieldValueAsFloat('UnitPrice',mRowUnitPrice);
                            if mRowUnitPrice=0 then mNewOrderRow.SetFieldValueAsFloat('TotalPrice',mRowTotalPrice);
                            mNewOrderRow.SetFieldValueAsString('VatRate_ID',mVatRate_ID);
                            mNewOrderRow.SetFieldValueAsString('Division_ID',mDivision_ID);
                            mNewOrderRow.SetFieldValueAsString('BusOrder_ID',mRowBusOrder_ID);
                            mNewOrderRow.SetFieldValueAsString('BusTransaction_ID',mRowBusTransaction_ID);
                            mNewOrderRow.SetFieldValueAsString('X_pozice_OD',mPozice_OD);
                            mNewOrderRow.SetFieldValueAsString('DRCArticle_ID', mDRCArticle_ID);
                            mNewOrderRow.SetFieldValueAsFloat('RowDiscount', mDiscount);
                            mNewOrderRow.SetFieldValueAsString('X_StoreCard_ID',mOrderStoreCard_ID);
                            NxScriptingLog.WriteEvent(logInfo,'před uložením');
                            //mOrder.Save;
                            NxScriptingLog.WriteEvent(logInfo,'po přidání' +FloatToStr(mOrder.GetFieldValueAsFloat('Amount')));
                           end;
                         end;
                      end;
                   end;
                   mOrder.save;
                   morder.Free;
                   {mOrder:=mOS.CreateObject(Class_ReceivedOrder);
                   NxScriptingLog.WriteEvent(logInfo,'ceny Amount:'+FloatToStr(mAmount)+#13#10+
                                                     'amountWVat: '+FloatToStr(mAmountWithoutVAT)+#13#10+
                                                     'mLocalAmount :'+FloatToStr(mLocalAmount));
                   morder.Load(mOrder_ID,nil);
                   mAmount:=GetAmount(mOS,morder.OID);
                   mAmountWithoutVAT:=GetAmountWithoutVAT(mOS, morder.OID);
                   mLocalAmount:=GetLocalAmount(mOS, morder.OID);
                   mLocalAmountWithoutVAT:=GetLocalAmountWithoutVAT(mOS,morder.OID);
                   morder.SetFieldValueAsFloat('Amount',mAmount+morder.GetFieldValueAsFloat('RoundingAmount'));
                   morder.SetFieldValueAsFloat('AmountWithoutVAT',mAmountWithoutVAT);
                   morder.SetFieldValueAsFloat('LocalAmountWithoutVAT',mLocalAmountWithoutVAT);
                   morder.SetFieldValueAsFloat('LocalAmount',mLocalAmount+morder.GetFieldValueAsFloat('LocalRoundingAmount'));
                   mOrder.Save;
                   morder.free;
                   NxScriptingLog.LeaveSection('CorrRows',logInfo);  }
                 finally

                 end;

                 //konec povolení OBDV ze dne 5.2.2020

                 end;



                 {mPLMJobOrder_ID:=Createjoborder2(mOS,mProduceRequest_ID);
                  if not(NxIsEmptyOID(mPLMJobOrder_ID)) then begin
                   mJobOrder:=mOS.CreateObject(Class_PLMJobOrder);
                   mjoborder.Load(mPLMJobOrder_ID,nil);
                   mjoborder.SetFieldValueAsDateTime('ReleasedAt$DATE',date);
                    mOutPutItems:=mJobOrder.GetLoadedCollectionMonikerForFieldCode(mJobOrder.GetFieldCode('OutPuts'));
                    for x:=0 to mOutPutItems.count-1 do begin
                      mPLMJobOrdersSNs:=mOutPutItems.BusinessObject[x].GetLoadedCollectionMonikerForFieldCode(mOutPutItems.BusinessObject[x].GetFieldCode('PLMJobOrdersSN'));
                      if mPLMJobOrdersSNs.Count>0 then begin
                         for y:=0 to mPLMJobOrdersSNs.count-1 do begin
                           if not(NxIsEmptyOID(mPLMJobOrdersSNs.BusinessObject[y].GetFieldValueAsString('StoreBatch_ID'))) then begin
                              mStoreBatchBO:=mOS.CreateObject(Class_StoreBatch);
                              mStoreBatchBO.Load(mPLMJobOrdersSNs.BusinessObject[y].GetFieldValueAsString('StoreBatch_ID'),nil);
                              mStoreBatchBO.SetFieldValueAsString('Name',mJobOrder.GetFieldValueAsString('U_vyrobni_cislo'));
                              mstorebatchbo.save;
                              mStoreBatchBO.free;


                           end;
                           //NxShowSimpleMessage('mám '+mPLMJobOrdersSNs.BusinessObject[y].GetFieldValueAsString('StoreBatch_ID.name'),mSite);
                         end;
                      end;
                    end;
                   mJobOrder.save;
                   mjoborder.free;
                 end;
                 mProduceRequestList.Add(mProduceRequest_ID);
                 mVYPList.add(mPLMJobOrder_ID); }
               finally

               end;

            end;
          end;
       end;




      finally
        //NxShowSimpleMessage(mVYPList.DelimitedText,mSite);
        TDynSiteForm(mSite).RefreshData;
        TDynSiteForm(mSite).ActiveDataSet.SeekID(mSMBO.oid);
      end;
     end;
   finally

   end;

end;


begin
end.