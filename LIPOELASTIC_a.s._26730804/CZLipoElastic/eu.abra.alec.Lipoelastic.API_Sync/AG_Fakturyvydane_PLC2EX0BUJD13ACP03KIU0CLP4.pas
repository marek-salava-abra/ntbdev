uses '.API', '.lib';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actSendOVoverAPI';
  mAction.Caption := '##Synchronizovat do SK##';
  mAction.Items.Add('Synchronizovat do SK');
  mAction.Items.Add('Synchronizovat do DE');
  mAction.Items.Add('Synchronizovat do AT');
  mAction.Hint := 'Odešle fakturu do patřičné země';
  mAction.Category := 'tabList';
  mAction.OnExecuteItem := @SendOverAPI;
end;



procedure SendOverAPI(Sender:TComponent;Index:integer);
var
  mSite: tSiteForm;
  mOS: TNxCustomObjectSpace;
  mHeaderJSON, mRowJSON, mBatchJSON, mResultJSON: TJSONSuperObject;
  mBO, mRowBO, mBODRowBO: TNxCustomBusinessObject;
  i,j, k: integer;
  mRows, mBatchRows: TNxCustomBusinessMonikerCollection;
  mMessage, mErrorMessage, mStoreBatch_ID:string;
  mList:TStringList;
begin
  mSite:=TComponent(Sender).DynSite;
  mOS:= mSite.BaseObjectSpace;
  mList:=TStringList.Create;
  TDynSiteForm(mSite).List.GetSelectedId(mList);
  if mlist.Count>0 then begin
    mErrorMessage:='';
    WaitWin.StartProgress('Přenáším do ciziny ...', '', mList.Count);
    for j:=0 to mList.count-1 do begin
      mBO:= mOS.CreateObject(Class_IssuedInvoice);
      try
        mBO.Load(mList.strings[j],nil);
        if Assigned(mBO) then begin
          if NxIsBlank(mBO.GetFieldValueAsString('DocQueue_ID.U_SK_ReceivedInvoiceCode')) and (Index=0) then begin
               NxShowSimpleMessage('Řada dokladů '+#13#10+
                                mbo.GetFieldValueAsString('DocQueue_ID.Code')+' - '+mbo.GetFieldValueAsString('DocQueue_ID.Name')+#13#10+
                                'nemá nastaveny parametry pro odeslání na Slovensko. Ukončuji.',mSite);
            exit;
          end;
          if NxIsBlank(mBO.GetFieldValueAsString('DocQueue_ID.U_DE_ReceivedInvoiceCode')) and (Index=1) then begin
               NxShowSimpleMessage('Řada dokladů '+#13#10+
                                mbo.GetFieldValueAsString('DocQueue_ID.Code')+' - '+mbo.GetFieldValueAsString('DocQueue_ID.Name')+#13#10+
                                'nemá nastaveny parametry pro odeslání do Německa. Ukončuji.',mSite);
            exit;
          end;
          if NxIsBlank(mBO.GetFieldValueAsString('DocQueue_ID.U_AT_ReceivedInvoiceCode')) and (Index=2) then begin
                NxShowSimpleMessage('Řada dokladů '+#13#10+
                                mbo.GetFieldValueAsString('DocQueue_ID.Code')+' - '+mbo.GetFieldValueAsString('DocQueue_ID.Name')+#13#10+
                                'nemá nastaveny parametry pro odeslání do Rakouska. Ukončuji.',mSite);
            exit;
          end;

          try
            if Not(NxIsBlank(mBO.GetFieldValueAsString('U_ReceivedInvoice_SK'))) then begin
              if (NxSearch(mBO.GetFieldValueAsString('U_ReceivedInvoice_SK'),'-',[srall],0)>0)
                and (NxSearch(mBO.GetFieldValueAsString('U_ReceivedInvoice_SK'),'/',[srall],0)>0) then
              begin
                mErrorMessage:=mErrorMessage+#13#10+'Odeslání '+mBO.DisplayName+' již bylo provedeno. Nelze odeslat znovu.';
                exit;
              end;
            end else begin
              mHeaderJSON:=TJSONSuperObject.Create;
              mHeaderJSON.S['DocumentName']:= mBO.DisplayName;
              mHeaderJSON.S['DocumentID']:= mBO.OID;
              if Index=0 then mHeaderJSON.S['DocQueueCode']:=mBO.GetFieldValueAsString('DocQueue_ID.U_SK_ReceivedInvoiceCode');
              if Index=1 then mHeaderJSON.S['DocQueueCode']:=mBO.GetFieldValueAsString('DocQueue_ID.U_DE_ReceivedInvoiceCode');
              if Index=2 then mHeaderJSON.S['DocQueueCode']:=mBO.GetFieldValueAsString('DocQueue_ID.U_AT_ReceivedInvoiceCode');
              mHeaderJSON.S['VarSymbol']:=mBO.GetFieldValueAsString('VarSymbol');
              mHeaderJSON.DT8601['DocDate$DATE']:= mBO.GetFieldValueAsDateTime('DocDate$DATE');
              mHeaderJSON.DT8601['DueDate$DATE']:= mBO.GetFieldValueAsDateTime('DueDate$DATE');
              mHeaderJSON.DT8601['VATDate$DATE']:= mBO.GetFieldValueAsDateTime('VATDate$DATE');
              mHeaderJSON.S['IssuerFirmName']:= mSite.SiteContext.GetCompanyCache.CompanyName;
              mHeaderJSON.S['IssuerOrgIdentNumber']:= mSite.SiteContext.GetCompanyCache.OrgIdentNumber;
              mHeaderJSON.S['IssuerVATIdentNumber']:= mSite.SiteContext.GetCompanyCache.VATIdentNumber;
              mHeaderJSON.S['Description']:=mBO.GetFieldValueAsString('Description');
              mHeaderJSON.S['BankAccount']:= mBO.GetFieldValueAsString('BankAccount_ID.BankAccount');
              mHeaderJSON.S['PaymentTypeCode']:= mBO.GetFieldValueAsString('PaymentType_ID.Code');
              mHeaderJSON.B['VATDocument']:= mBO.GetFieldValueAsBoolean('VATDocument');
              mHeaderJSON.B['PricesWithVAT']:= mBO.GetFieldValueAsBoolean('PricesWithVAT');
              mHeaderJSON.I['TradeType']:= mBO.GetFieldValueAsInteger('TradeType');
              mHeaderJSON.S['VATCountryCode']:= mBO.GetFieldValueAsString('VATCountry_ID.Code');
              mHeaderJSON.S['CountryCode']:= mBO.GetFieldValueAsString('Country_ID.Code');
              mHeaderJSON.S['CurrencyCode']:= mBO.GetFieldValueAsString('Currency_ID.Code');
              mHeaderJSON.D['CurrRate']:= mBO.GetFieldValueAsFloat('CurrRate');
              mHeaderJSON.D['RefCurrRate']:= mBO.GetFieldValueAsFloat('RefCurrRate');
              mHeaderJSON.D['Amount']:= mBO.GetFieldValueAsFloat('Amount');

              mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
              mHeaderJSON.O['Rows'] := mHeaderJSON.CreateJSONArray;
              for i:=0 to mRows.count-1 do begin
                mRowBO:=mRows.BusinessObject[i];
                mRowJSON:=TJSONSuperObject.Create;
                mrowJSON.I['RowType']:=mRowBO.GetFieldValueAsInteger('RowType');
                if index=0 then mRowJSON.S['StoreCode']:=mBO.GetFieldValueAsString('DocQueue_ID.U_SK_StoreCode');
                if index=1 then mRowJSON.S['StoreCode']:=mBO.GetFieldValueAsString('DocQueue_ID.U_DE_StoreCode');
                if index=2 then mRowJSON.S['StoreCode']:=mBO.GetFieldValueAsString('DocQueue_ID.U_AT_StoreCode');
                if not(NxIsEmptyOID(mRowBO.GetFieldValueAsString('StoreCard_ID'))) then
                  mRowJSON.S['StoreCardCode']:=mRowBO.GetFieldValueAsString('StoreCard_ID.Code')
                else
                  mRowJSON.S['StoreCardCode']:='';
                mRowJSON.D['Quantity']:=mRowBO.GetFieldValueAsFloat('Quantity');
                if Index=0 then mRowJSON.S['DivisionCode']:=mBO.GetFieldValueAsString('DocQueue_ID.U_SK_DivisionCode');
                if Index=1 then mRowJSON.S['DivisionCode']:=mBO.GetFieldValueAsString('DocQueue_ID.U_DE_DivisionCode');
                if Index=2 then mRowJSON.S['DivisionCode']:=mBO.GetFieldValueAsString('DocQueue_ID.U_AT_DivisionCode');
                mRowJSON.S['Text']:=mRowBO.GetFieldValueAsString('Text');
                mRowJSON.S['QUnit']:=mRowBO.GetFieldValueAsString('Qunit');
                mRowJSON.S['Row_ID']:=mRowBO.OID;
                mRowJSON.D['UnitPrice']:= mRowBO.GetFieldValueAsFloat('UnitPrice');
                mRowJSON.D['TAmount']:= mRowBO.GetFieldValueAsDateTime('TAmount');
                mRowJSON.D['TAmountWithoutVAT']:= mRowBO.GetFieldValueAsDateTime('TAmountWithoutVAT');
                mRowJSON.D['VATRate']:= mRowBO.GetFieldValueAsFloat('VATRate_ID.Tariff');
                mRowJSON.S['BODRowID']:=mRowBO.GetFieldValueAsString('ProvideRow_ID');
                mRowJSON.S['IORowID']:=mOS.SQLSelectFirstAsString('Select RO2.X_ProvideRow_ID from storeDocuments2 sd2 left join receivedorders2 ro2 on ro2.id=sd2.ProvideRow_ID where sd2.id='+
                                                                    QuotedStr(mRowBO.GetFieldValueAsString('ProvideRow_ID')),'');
                mRowJSON.O['StoreBatches'] := mRowJSON.CreateJSONArray;
                if not(NxIsEmptyOID(mRowBO.GetFieldValueAsString('ProvideRow_ID'))) then begin
                  mBODRowBO:= mOS.CreateObject(Class_BillOfDeliveryRow);
                  try
                    mBODRowBO.Load(mRowBO.GetFieldValueAsString('ProvideRow_ID'), nil);
                    mBatchRows:= mBODRowBO.GetLoadedCollectionMonikerForFieldCode(mBODRowBO.GetFieldCode('DocRowBatches'));
                    for k:= 0 to mBatchRows.Count -1 do begin
                      mBatchJSON:= TJSONSuperObject.Create;
                      mBatchJSON.S['Name']:= mBatchRows.BusinessObject[k].GetFieldValueAsString('StoreBatch_ID.Name');
                      mBatchJSON.S['Note']:= mBatchRows.BusinessObject[k].GetFieldValueAsString('StoreBatch_ID.Note');
                      mBatchJSON.S['Specification']:= mBatchRows.BusinessObject[k].GetFieldValueAsString('StoreBatch_ID.Specification');
                      mBatchJSON.DT8601['ExpirationDate$DATE']:= mBatchRows.BusinessObject[k].GetFieldValueAsDateTime('StoreBatch_ID.ExpirationDate$DATE');
                      mBatchJSON.D['Quantity']:= mBatchRows.BusinessObject[k].GetFieldValueAsFloat('Quantity');
                      mBatchJSON.S['QUnit']:= mBatchRows.BusinessObject[k].GetFieldValueAsString('QUnit');

                      mRowJSON.A['StoreBatches'].Add(mBatchJSON);
                    end;
                  finally
                    mBODRowBO.Free;
                  end;
                end;
                mHeaderJSON.A['Rows'].Add(mRowJSON);
              end;
              mResultJSON:= TJSONSuperObject.Create;
              mResultJSON:= API_POST(mHeaderJSON, 'InvoiceQueue',True,Index);
              if NxGetActualUserID(mOS)='4PU1000101' then NxShowSimpleMessage(mResultJSON.AsString,mSite);
              if not(NxIsEmptyOID(mResultJSON.S['id'])) then begin
                mBO.SetFieldValueAsString('U_ReceivedInvoice_SK', mBO.GetFieldValueAsString('DocQueue_ID.U_SK_ReceivedInvoiceCode')+'-XXX/'+mBO.GetFieldValueAsString('Period_ID.Code'));
                //mBO.SetFieldValueAsBoolean('Issued',true);
                //mBO.SetFieldValueAsDateTime('X_SendDate$Date',Now);
              end else begin
                mErrorMessage:=mErrorMessage +#13#10+ mBO.DisplayName + ' - doklad se nepodařilo synchronizovat.';
              end;

              if mBO.NeedSave then begin
                mBO.save;
              end;

              TDynSiteForm(mSite).RefreshData;
              TDynSiteForm(mSite).ActiveDataSet.SeekID(mBO.OID);

            end;
          except
            NxShowSimpleMessage(ExceptionMessage,mSite);
            WaitWin.Stop;
          end;
        end;
      finally
        mBO.Free;
        WaitWin.Stop;
      end;
      WaitWin.ChangeText(IntToStr(1+j) + ' / ' + IntToStr(mlist.Count));
      WaitWin.StepIt;
    end;
    TDynSiteForm(mSite).RefreshData;
    if not(NxIsBlank(mErrorMessage)) then
      NxShowSimpleMessage(mErrorMessage,mSite)
    else
      NxShowSimpleMessage('Odeslání faktur ke zpracování proběhlo úspěšně.', mSite);
    //mSite.ShowSite(Site_IssuedOrders,true,'QueryByUserDynSQLCondition;A.ID in ('+mlist.DelimitedText+')');
  end;
end;


procedure _CanDelete_Hook(Self: TDynSiteForm; var ACanDelete: Boolean);
begin
 if not(osNew in self.CurrentObject.State) then begin
   if Not(NxIsBlank(self.CurrentObject.GetFieldValueAsString('U_ReceivedInvoice_SK'))) then begin
      if (NxSearch(self.CurrentObject.GetFieldValueAsString('U_ReceivedInvoice_SK'),'-',[srall],0)>0) and
         (NxSearch(self.CurrentObject.GetFieldValueAsString('U_ReceivedInvoice_SK'),'/',[srall],0)>0) then begin
               ACanDelete:=false;
               NxShowSimpleMessage('Vymazání zamítnuto.Faktura byla odeslána do SK, vymažte napřed doklad na Slovensku.',Self);
      end;
   end;
 end;
end;

procedure _CanEdit_Hook(Self: TDynSiteForm; var ACanEdit: Boolean);
begin
  if not(osNew in self.CurrentObject.State) and (CFxNxRuntime.NxGetEnvironmentType = reRuntimeExe) then begin
    if Not(NxIsBlank(self.CurrentObject.GetFieldValueAsString('U_ReceivedInvoice_SK'))) then begin
      if (NxSearch(self.CurrentObject.GetFieldValueAsString('U_ReceivedInvoice_SK'),'-',[srall],0)>0)
        and (NxSearch(self.CurrentObject.GetFieldValueAsString('U_ReceivedInvoice_SK'),'/',[srall],0)>0) then
      begin
        if (self.CompanyCache.GetUserID='SUPER00000') or (self.CompanyCache.GetUserID='~000000E01') then begin    //ABRA_SK_SYNC
          NxShowSimpleMessage('Faktura byla odeslána do ČR, opravujte jen hodnoty neovlivnující synchronizaci.',Self);
        end else begin
          ACanEdit:=false;
          NxShowSimpleMessage('Oprava zamítnuta.Faktura byla odeslána do SK, vymažte napřed doklad na Slovensku.',Self);
        end;
      end;
    end;
  end;
end;


begin
end.