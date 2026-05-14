uses '.progress', '.fce', '.const', '.POZP';

procedure SpedosCheckFile(OS: TNxCustomObjectSpace; var ProcessContinue: Boolean; Directory: string; FileName: string);
var
 mSite:TSiteForm;
 mOS: TNxCustomObjectSpace;
 mOpenDlg:TOpenDialog;
 mXMLHead:TNxScriptingXMLWrapper;
 i,j,k,l,m, n, x, y, z, mOR, mRowPosindex :integer;
 mProductCard_ID, mBusOrder_ID, mStoreCard_ID:String;
 mSMBO, mOutputRow, mInputRow, mRowBO, mProductRow, mOperationRow, mStoreCardBO, mUnitBO, mJobOrder, mStoreBatchBO, mStoreCardNDBO:TNxCustomBusinessObject;
 mRows, mInputs, mOutputs,mOperationRows, mUnits, mOutPutItems, mPLMJobOrdersSNs:TNxCustomBusinessMonikerCollection;
 mRelation:TNxCustomBusinessObject;
 mOrder_ID,mPLMJobOrder_ID, mProduceRequest_ID, mWorkPlace_ID, mOrderStoreCard_ID:string;
 mVYPList, mProduceRequestList:TStringList;
 awaring,aerror:string;
 mTO:string;
 mText, mDivision_ID, mRowBusOrder_ID, mRowQunit, mRowBusTransaction_ID, mPozice_OD, mPozice2_ID, mVatRate_ID, mDRCArticle_ID, mFirm_ID :string;
 mRowQuantity, mRowUnitPrice, mDiscount:Extended;
 mOrder, mOrderRow, mNewOrderRow:TNxCustomBusinessObject;
 mOrderRows:TNxCustomBusinessMonikerCollection;
 mVATMode:integer;
 mNewSerial:string;
 mLocalAmountWithoutVAT, mAmountWithoutVAT, mLocalAmount, mAmount:Extended;
begin
 mVYPList:=TStringList.Create;
 mProduceRequestList:=TStringList.Create;
 mOS:=OS;
  try
    if true then begin
      try
        mXMLHead:=TNxScriptingXMLWrapper.create;
        mXMLHead.loadFromFile(Directory+'\'+FileName);
        j:=mXMLHead.getElementsCountInArray('item');
        l:=mXMLHead.getElementAsInteger('item['+IntToStr(0)+'].pocet');
        for m:=1 to l do begin
         for i:=0 to j-1 do begin
            if i=0 then begin
               mSMBO:=mOS.CreateObject(Class_PLMProduceRequest);
               mSMBO.new;
               mSMBO.Prefill;
               mStoreCardNDBO:=mos.CreateObject(Class_StoreCard);
               mStoreCardNDBO.new;
               mStoreCardNDBO.prefill;
               mStoreCardNDBO.SetFieldValueAsString('Code',mXMLHead.getElementAsString('item['+IntToStr(i)+'].karta_vyrobku'));
               mStoreCardNDBO.SetFieldValueAsString('Name',mXMLHead.getElementAsString('item['+IntToStr(i)+'].nazev_vyrobku'));
               mStoreCardNDBO.SetFieldValueAsInteger('Category',1);
               mStoreCardNDBO.SetFieldValueAsString('StoreCardCategory_ID','6200000101');
               mStoreCardNDBO.SetFieldValueAsString('VatRate_ID','02100X0000');
               mStoreCardNDBO.SetFieldValueAsBoolean('IsProduct',true);
               mStoreCardNDBO.SetFieldValueAsDateTime('AuthorizedAt$DATE',date); //Doplnil Gajdoš 14.7.2023
               mStoreCardNDBO.Save;
               mProductCard_ID:=mStoreCardNDBO.OID;
               mStoreCardNDBO.Free;
               mTO:= mXMLHead.getElementAsString('item['+IntToStr(i)+'].email');
               if NxIsEmptyOID(mProductCard_ID) then begin
                  {if (NxIsValidEMail(mto,false)) then
                  CFxInternet.SMSendMailWithMoreFiles(csOpenSSL,cMailLogin,cMailPassword,cMailSMTP,465,cMailFrom,mto,'','','Chyba importu','Nepovedlo se dohledat kartu výrobku '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].karta_vyrobku')+'. Výrobní číslo '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].vyrobni_cislo'),commAsText,'') else
                  CFxInternet.SMSendMailWithMoreFiles(csOpenSSL,cMailLogin,cMailPassword,cMailSMTP,465,cMailFrom,cEmail,'','','Chyba importu','Nepovedlo se dohledat kartu výrobku '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].karta_vyrobku')+'. Výrobní číslo '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].vyrobni_cislo'),commAsText,'');}
                  if NxIsValidEMail(mto,false) then
                  SendInternalMail(OS,mto,'','Chyba importu','Nepovedlo se dohledat kartu výrobku '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].karta_vyrobku')+'. Výrobní číslo '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].vyrobni_cislo'),'','','','','','') else
                  SendInternalMail(OS,cEmail,'','Chyba importu','Nepovedlo se dohledat kartu výrobku '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].karta_vyrobku')+'. Výrobní číslo '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].vyrobni_cislo'),'','','','','','');

                 //ProgressDispose();
                 exit;
               end;
               msmbo.SetFieldValueAsString('DocQueue_ID','1F10000101');
               mSMBO.SetFieldValueAsString('StoreCard_ID',mProductCard_ID);
               mSMBO.SetFieldValueAsString('Firm_ID','AG21000101');
               mSMBO.SetFieldValueAsFloat('Quantity',1);
               msmbo.SetFieldValueAsFloat('CorrectedQuantity',1);
               msmbo.SetFieldValueAsString('Division_ID',GetDivision_ID(mOS,mXMLHead.getElementAsString('item['+IntToStr(i)+'].stredisko')));

               mSMBO.SetFieldValueAsString('Store_ID',cProduceStore);
               if msmbo.GetFieldValueAsString('Division_ID')='1I00000101' then mSMBO.SetFieldValueAsString('Store_ID','2600000101');
               if not(NxIsEmptyOID(mSMBO.GetFieldValueAsString('StoreCard_ID.X_Store_ID'))) then mSMBO.SetFieldValueAsString('Store_ID',mSMBO.GetFieldValueAsString('StoreCard_ID.X_Store_ID'));
               msmbo.SetFieldValueAsString('U_vyrobni_cislo',GetSN(mOS,mXMLHead.getElementAsString('item['+IntToStr(i)+'].vyrobni_cislo'),m-1));
               if UpperCase(AnsiRightStr(mXMLHead.getElementAsString('item['+IntToStr(i)+'].vyrobni_cislo'),1))='X' then begin
                // NxShowSimpleMessage('Nepovedlo se dohledat kartu výrobku '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].karta_vyrobku')+'.',mSite);
                  {if (NxIsValidEMail(mto,false)) then
                  CFxInternet.SMSendMailWithMoreFiles(csOpenSSL,cMailLogin,cMailPassword,cMailSMTP,465,cMailFrom,mto,'','','Chyba importu','Nepovedlo se dohledat výrobní číslo '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].karta_vyrobku')+'. Výrobní číslo '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].vyrobni_cislo'),commAsText,'') else
                  CFxInternet.SMSendMailWithMoreFiles(csOpenSSL,cMailLogin,cMailPassword,cMailSMTP,465,cMailFrom,cEmail,'','','Chyba importu','Nepovedlo se dohledat výrobní číslo '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].karta_vyrobku')+'. Výrobní číslo '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].vyrobni_cislo'),commAsText,'');}
                  if NxIsValidEMail(mto,false) then
                  SendInternalMail(OS,mto,'','Chyba importu','Nepovedlo se dohledat výrobní číslo '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].karta_vyrobku')+'. Výrobní číslo '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].vyrobni_cislo'),'','','','','','') else
                  SendInternalMail(OS,cEmail,'','Chyba importu','Nepovedlo se dohledat výrobní číslo '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].karta_vyrobku')+'. Výrobní číslo '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].vyrobni_cislo'),'','','','','','');
                 //ProgressDispose();
                 exit;
               end;
               msmbo.SetFieldValueAsString('U_ID_vyrobku',GetIDV(mOS,mXMLHead.getElementAsString('item['+IntToStr(i)+'].id_vyrobku'),m-1));
               mSMBO.SetFieldValueAsString('X_group',mXMLHead.getElementAsString('item['+IntToStr(i)+'].vyrobni_cislo'));
               msmbo.SetFieldValueAsString('U_ID_Pozice',mXMLHead.getElementAsString('item['+IntToStr(i)+'].id_pozice'));
               mTO:= mXMLHead.getElementAsString('item['+IntToStr(i)+'].email');
               mSMBO.SetFieldValueAsDateTime('Schedule$DATE',mXMLHead.getElementAsDateTime('item['+IntToStr(i)+'].datum_vyroby'));
               mSMBO.SetFieldValueAsDateTime('PlanedStartAt$DATE',mXMLHead.getElementAsDateTime('item['+IntToStr(i)+'].datum_vyroby')-14);
               mRows:=mSMBO.GetLoadedCollectionMonikerForFieldCode(mSMBO.GetFieldCode('Rows'));
               mOutputs:=msmbo.GetLoadedCollectionMonikerForFieldCode(msmbo.GetFieldCode('OutPuts'));
               mInputs:=msmbo.GetLoadedCollectionMonikerForFieldCode(msmbo.GetFieldCode('Inputs'));
               mrows.BusinessObject[0].SetFieldValueAsString('StoreCard_ID',mProductCard_ID);
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
                        {if (NxIsValidEMail(mto,false)) then
                          CFxInternet.SMSendMailWithMoreFiles(csOpenSSL,cMailLogin,cMailPassword,cMailSMTP,465,cMailFrom,mto,'','','Chyba importu pracoviště','Nepovedlo se dohledat pracoviště '+mXMLHead.getElementAsString('item['+IntToStr(0)+'].Works.work.pracoviste_kod['+IntToStr(k)+']')+' na pozici '+inttostr(i)+'. Výrobní číslo '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].vyrobni_cislo'),commAsText,'') else
                          CFxInternet.SMSendMailWithMoreFiles(csOpenSSL,cMailLogin,cMailPassword,cMailSMTP,465,cMailFrom,cEmail,'','','Chyba importu poracoviště','Nepovedlo se dohledat pracoviště '+mXMLHead.getElementAsString('item['+IntToStr(0)+'].Works.work.pracoviste_kod['+IntToStr(k)+']')+' na pozici '+inttostr(i)+'. Výrobní číslo '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].vyrobni_cislo'),commAsText,'');}
                         if NxIsValidEMail(mto,false) then
                          SendInternalMail(OS,mto,'','Chyba importu pracoviště','Nepovedlo se dohledat pracoviště '+mXMLHead.getElementAsString('item['+IntToStr(0)+'].Works.work.pracoviste_kod['+IntToStr(k)+']')+' na pozici '+inttostr(i)+'. Výrobní číslo '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].vyrobni_cislo'),'','','','','','') else
                          SendInternalMail(OS,cEmail,'','Chyba importu pracoviště','Nepovedlo se dohledat pracoviště '+mXMLHead.getElementAsString('item['+IntToStr(0)+'].Works.work.pracoviste_kod['+IntToStr(k)+']')+' na pozici '+inttostr(i)+'. Výrobní číslo '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].vyrobni_cislo'),'','','','','','');
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
                 {if (NxIsValidEMail(mto,false)) then
                  CFxInternet.SMSendMailWithMoreFiles(csOpenSSL,cMailLogin,cMailPassword,cMailSMTP,465,cMailFrom,mto,'','','Chyba importu materiál','Nepovedlo se dohledat kartu materiálu '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].Stock.mater_karta')+' na pozici '+inttostr(i)+' s množstvím '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].Stock.Mnozstvi')+'.',commAsText,'') else
                  CFxInternet.SMSendMailWithMoreFiles(csOpenSSL,cMailLogin,cMailPassword,cMailSMTP,465,cMailFrom,cEmail,'','','Chyba importu materiál','Nepovedlo se dohledat kartu materiálu '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].Stock.mater_karta')+' na pozici '+inttostr(i)+' s množstvím '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].Stock.Mnozstvi')+'.',commAsText,'');}
                 if NxIsValidEMail(mto,false) then
                          SendInternalMail(OS,mto,'','Chyba importu materiál','Nepovedlo se dohledat kartu materiálu '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].Stock.mater_karta')+' na pozici '+inttostr(i)+' s množstvím '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].Stock.Mnozstvi')+'.','','','','','','') else
                          SendInternalMail(OS,cEmail,'','Chyba importu materiál','Nepovedlo se dohledat kartu materiálu '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].Stock.mater_karta')+' na pozici '+inttostr(i)+' s množstvím '+mXMLHead.getElementAsString('item['+IntToStr(i)+'].Stock.Mnozstvi')+'.','','','','','','');

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



            end;
          end;
       end;
      finally
      end;
     end;
   finally

   end;

   ProcessContinue := True;
   //NxShowSimpleMessage('nahrál jsem poz',nil);
end;

begin
end.