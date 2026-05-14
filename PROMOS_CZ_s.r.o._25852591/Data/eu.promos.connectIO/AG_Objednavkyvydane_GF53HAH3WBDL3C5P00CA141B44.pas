procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction, mAction2: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := '# Sloučení OV #';
  mAction.Items.Add('Provede sloučení OV');
  mAction.Hint := 'Sloučí vybranou OV do OV, na které stojíte';
  mAction.Category := 'tabList';
  mAction.OnExecuteItem := @ConnectInvoice;
end;

Procedure ConnectInvoice(Sender: TComponent;index:integer);
var
 mSite:TSiteForm;
 mOLEApp, mAgenda, mSelected: Variant;
 mIssuedOrder_ID,mSelected_ID:string;
 mOrderBO, mBO, mOrigRowBO, mImportRowBO:TNxCustomBusinessObject;
 mOrigRows, mImportRows:TNxCustomBusinessMonikerCollection;
 i:integer;
 mList:TStringList;
 mDeletedBOName:String;
begin
  mSite:=TComponent(Sender).DynSite;
  mBO:=TDynSiteForm(mSite).CurrentObject;
    if Assigned(mBO) then begin
    mOLEApp := GetAbraOLEApplication;
    mSelected := GetAbraOLEStrings;
    mAgenda := mOLEApp.GetAgenda('GF53HAH3WBDL3C5P00CA141B44');
    mSelected_ID := mAgenda.SingleSelect2('', '');
            if mSelected_ID <> '' then begin
              mIssuedOrder_ID :=  mSelected_ID;
            end;
              if not(NxIsEmptyOID(mIssuedOrder_ID)) then begin
                 mOrderBO:=msite.BaseObjectSpace.CreateObject(Class_IssuedOrder);
                 mOrderBO.Load(mIssuedOrder_ID,nil);
                 if NxMessageBox('Dotaz','Přejete si zkopírovat řádky z '+mOrderBO.DisplayName+' do '+mbo.displayname+'?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
                    if not(mbo.GetFieldValueAsInteger('TradeType')=mOrderBO.GetFieldValueAsInteger('TradeType')) then begin
                      NxShowSimpleMessage('Doklady nemají stejný typ obchodu. Ukončuji.',mSite);
                      exit;
                    end;
                    if not(mbo.GetFieldValueAsString('Currency_ID')=mOrderBO.GetFieldValueAsString('Currency_ID')) then begin
                      NxShowSimpleMessage('Doklady nemají stejnou měnu. Ukončuji.',mSite);
                      exit;
                    end;
                    if not(mbo.GetFieldValueAsString('Firm_ID')=mOrderBO.GetFieldValueAsString('Firm_ID')) then begin
                      NxShowSimpleMessage('Doklady nemají stejnou firmu. Ukončuji.',mSite);
                      exit;
                    end;
                    mOrigRows:=mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Rows'));
                    mImportRows:=mOrderBO.GetLoadedCollectionMonikerForFieldCode(mOrderBO.GetFieldCode('Rows'));
                    for i:=0 to mImportRows.count-1 do begin
                      mImportRowBO:=mImportRows.BusinessObject[i];
                      mOrigRowBO:=mOrigRows.AddNewObject;
                      mOrigRowBo.SetFieldValueAsInteger('RowType',mImportRowBO.GetFieldValueAsInteger('RowType'));
                      mOrigRowBo.SetFieldValueAsString('Store_ID',mImportRowBO.GetFieldValueAsString('Store_ID'));
                      mOrigRowBo.SetFieldValueAsString('StoreCard_ID',mImportRowBO.GetFieldValueAsString('StoreCard_ID'));
                      mOrigRowBo.SetFieldValueAsString('Division_ID',mImportRowBO.GetFieldValueAsString('Division_ID'));
                      mOrigRowBo.SetFieldValueAsString('Text',mImportRowBO.GetFieldValueAsString('Text'));
                      mOrigRowBo.SetFieldValueAsString('BusOrder_ID',mImportRowBO.GetFieldValueAsString('BusOrder_ID'));
                      mOrigRowBo.SetFieldValueAsString('BusTransaction_ID',mImportRowBO.GetFieldValueAsString('BusTransaction_ID'));
                      mOrigRowBo.SetFieldValueAsString('BusProject_ID',mImportRowBO.GetFieldValueAsString('BusProject_ID'));
                      mOrigRowBO.SetFieldvalueasFloat('VatRate',mImportRowBO.GetFieldvalueasFloat('VatRate'));
                      mOrigRowBo.SetFieldValueAsString('VatRate_ID',mImportRowBO.GetFieldValueAsString('VatRate_ID'));
                      mOrigRowBo.SetFieldValueAsString('Qunit',mImportRowBO.GetFieldValueAsString('Qunit'));
                      mOrigRowBO.SetFieldvalueasFloat('Quantity',mImportRowBO.GetFieldvalueasFloat('Quantity'));
                      mOrigRowBO.SetFieldvalueasFloat('UnitPrice',mImportRowBO.GetFieldvalueasFloat('UnitPrice'));
                      morigrowbo.SetFieldValueAsDateTime('DeliveryDate$Date',mImportRowBO.GetFieldValueAsDateTime('DeliveryDate$Date'));
                    end;
                    try
                     mbo.save;
                     mDeletedBOName:=mOrderBO.DisplayName;
                     mOrderBO.delete;
                     TDynSiteForm(mSite).RefreshData;
                     NxShowSimpleMessage('Vložil jsem řádky a smazal objednávku '+mDeletedBOName+'.',mSite);
                     TDynSiteForm(mSite).ActiveDataSet.SeekID(mBO.OID);
                     mbo.free;
                    except
                      NxShowSimpleMessage(ExceptionMessage,msite);
                    end;

                 end;
              end;
   end;

end;



begin
end.