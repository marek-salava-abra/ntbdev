uses '.API', '.lib';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actSendOVoverAPI';
  mAction.Caption := '##Synchronizovat do SK##';
  mAction.Hint := 'Odešle dobropis faktury do SK';
  mAction.Category := 'tabList';
  mAction.OnExecute := @SendOverAPI;
end;


procedure SendOverAPI(Sender:TComponent);
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
    WaitWin.StartProgress('Přenáším do SK ...', '', mList.Count);
    for j:=0 to mList.count-1 do begin
      mBO:= mOS.CreateObject(Class_IssuedCreditNote);
      try
        mBO.Load(mList.strings[j],nil);
        if Assigned(mBO) then begin
          if NxIsBlank(mBO.GetFieldValueAsString('DocQueue_ID.U_SK_ReceivedCreditNoteCode')) then begin
             NxShowSimpleMessage('Řada dokladů '+#13#10+
                                mbo.GetFieldValueAsString('DocQueue_ID.Code')+' - '+mbo.GetFieldValueAsString('DocQueue_ID.Name')+#13#10+
                                'nemá nastaveny parametry pro odeslání do SK. Ukončuji.',mSite);
            exit;
          end;

          try
            if Not(NxIsBlank(mBO.GetFieldValueAsString('U_ReceivedCreditNote_SK'))) then begin
              if (NxSearch(mBO.GetFieldValueAsString('U_ReceivedCreditNote_SK'),'-',[srall],0)>0)
                and (NxSearch(mBO.GetFieldValueAsString('U_ReceivedCreditNote_SK'),'/',[srall],0)>0) then
              begin
                mErrorMessage:=mErrorMessage+#13#10+'Odeslání '+mBO.DisplayName+' již bylo provedeno. Nelze odeslat znovu.';
                exit;
              end;
            end else begin
              mHeaderJSON:=TJSONSuperObject.Create;
              mHeaderJSON.S['DocumentName']:= mBO.DisplayName;
              mHeaderJSON.S['DocumentID']:= mBO.OID;
              mHeaderJSON.S['DocQueueCode']:=mBO.GetFieldValueAsString('DocQueue_ID.U_SK_ReceivedCreditNoteCode');
              mHeaderJSON.S['VarSymbol']:=mBO.GetFieldValueAsString('VarSymbol');
              mHeaderJSON.S['InvoiceVarSymbol']:=mbo.GetFieldValueAsString('Source_ID.VarSymbol');
              mHeaderJSON.DT8601['DocDate$DATE']:= mBO.GetFieldValueAsDateTime('DocDate$DATE');
              mHeaderJSON.DT8601['DueDate$DATE']:= mBO.GetFieldValueAsDateTime('DueDate$DATE');
              mHeaderJSON.DT8601['VATDate$DATE']:= mBO.GetFieldValueAsDateTime('VATDate$DATE');
              mHeaderJSON.S['IssuerFirmName']:= mSite.SiteContext.GetCompanyCache.CompanyName;
              mHeaderJSON.S['IssuerOrgIdentNumber']:= mSite.SiteContext.GetCompanyCache.OrgIdentNumber;
              mHeaderJSON.S['IssuerVATIdentNumber']:= mSite.SiteContext.GetCompanyCache.VATIdentNumber;
              mHeaderJSON.S['Description']:=mBO.GetFieldValueAsString('Description');
              mHeaderJSON.S['PaymentTypeCode']:= mBO.GetFieldValueAsString('PaymentType_ID.Code');
              mHeaderJSON.B['VATDocument']:= mBO.GetFieldValueAsBoolean('VATDocument');
              mHeaderJSON.B['PricesWithVAT']:= mBO.GetFieldValueAsBoolean('PricesWithVAT');
              mHeaderJSON.I['TradeType']:= mBO.GetFieldValueAsInteger('TradeType');
              mHeaderJSON.S['VATCountryCode']:= mBO.GetFieldValueAsString('VATCountry_ID.Code');
              mHeaderJSON.S['CountryCode']:= mBO.GetFieldValueAsString('Country_ID.Code');
              mHeaderJSON.S['CurrencyCode']:= mBO.GetFieldValueAsString('Currency_ID.Code');
              mHeaderJSON.D['CurrRate']:= mBO.GetFieldValueAsFloat('CurrRate');
              mHeaderJSON.D['RefCurrRate']:= mBO.GetFieldValueAsFloat('RefCurrRate');

              mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
              mHeaderJSON.O['Rows'] := mHeaderJSON.CreateJSONArray;
              for i:=0 to mRows.count-1 do begin
                mRowBO:=mRows.BusinessObject[i];
                mRowJSON:=TJSONSuperObject.Create;
                mrowJSON.I['RowType']:=mRowBO.GetFieldValueAsInteger('RowType');
                mRowJSON.S['StoreCode']:=mBO.GetFieldValueAsString('DocQueue_ID.U_SK_StoreCode');
                if not(NxIsEmptyOID(mRowBO.GetFieldValueAsString('StoreCard_ID'))) then begin
                  mRowJSON.S['StoreCardCode']:=mRowBO.GetFieldValueAsString('StoreCard_ID.Code');
                  mRowJSON.S['InvoiceRowText']:='Skladová karta - '+mRowBO.GetFieldValueAsString('StoreCard_ID.Code')+' '+mRowBO.GetFieldValueAsString('StoreCard_ID.Name');
                end else begin
                  mRowJSON.S['StoreCardCode']:='';
                  mRowJSON.S['InvoiceRowText']:='';
                end;
                mRowJSON.D['Quantity']:=mRowBO.GetFieldValueAsFloat('Quantity');
                mRowJSON.S['DivisionCode']:=mBO.GetFieldValueAsString('DocQueue_ID.U_SK_DivisionCode');
                mRowJSON.S['Text']:=mRowBO.GetFieldValueAsString('Text');
                mRowJSON.S['QUnit']:=mRowBO.GetFieldValueAsString('Qunit');
                mRowJSON.S['Row_ID']:=mRowBO.OID;
                mRowJSON.D['UnitPrice']:= mRowBO.GetFieldValueAsFloat('UnitPrice');
                mRowJSON.D['TAmount']:= mRowBO.GetFieldValueAsDateTime('TAmount');
                mRowJSON.D['TAmountWithoutVAT']:= mRowBO.GetFieldValueAsDateTime('TAmountWithoutVAT');
                mRowJSON.D['VATRate']:= mRowBO.GetFieldValueAsFloat('VATRate_ID.Tariff');
                mRowJSON.S['VRRowID']:=mRowBO.GetFieldValueAsString('ProvideRow_ID');

                {mRowJSON.O['StoreBatches'] := mRowJSON.CreateJSONArray;
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
                end; }
                mHeaderJSON.A['Rows'].Add(mRowJSON);
              end;
              mHeaderJSON.SaveToFile('c:\abragen\'+mbo.oid+'.json');
              {mResultJSON:= TJSONSuperObject.Create;
              mResultJSON:= API_POST(mHeaderJSON, 'IssuedCreditNotes');
              if not(NxIsEmptyOID(mResultJSON.S['id'])) then begin
                mBO.SetFieldValueAsString('U_ReceivedCreditNote_SK', mBO.GetFieldValueAsString('DocQueue_ID.U_SK_ReceivedCreditNoteCode')+'-XXX/'+mBO.GetFieldValueAsString('Period_ID.Code'));
                //mBO.SetFieldValueAsBoolean('Issued',true);
                //mBO.SetFieldValueAsDateTime('X_SendDate$Date',Now);
              end else begin
                mErrorMessage:=mErrorMessage +#13#10+ mBO.DisplayName + ' - doklad se nepodařilo synchronizovat.';
              end;

              if mBO.NeedSave then begin
                mBO.save;
              end; }

              TDynSiteForm(mSite).RefreshData;
              TDynSiteForm(mSite).ActiveDataSet.SeekID(mBO.OID);

          //
          //    if NxIsValidEMail(mbo.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Email'),False) then
          //    SendInternalMail(mSite.BaseObjectSpace,mbo.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Email'),'Nová objednávka '+mBO.GetFieldValueAsString('X_ExternalDocument'),
          //       'Ve české abře vznikla nová objednávka číslo '+mBO.GetFieldValueAsString('X_ExternalDocument')+' ze slovenské objednávky '+mbo.DisplayName+mMessage,'#300000001', mBO.OID, mbo.CLSID);
          //    //NxShowSimpleMessage('Objednávka byla přenesena do ČR, přidělené číslo '+mBO.GetFieldValueAsString('ExternalNumber')+mMessage,mSite);
          //    mBO.free;
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
    if not(NxIsBlank(mErrorMessage)) then NxShowSimpleMessage(mErrorMessage,mSite);
    //mSite.ShowSite(Site_IssuedOrders,true,'QueryByUserDynSQLCondition;A.ID in ('+mlist.DelimitedText+')');
  end;
end;

begin
end.