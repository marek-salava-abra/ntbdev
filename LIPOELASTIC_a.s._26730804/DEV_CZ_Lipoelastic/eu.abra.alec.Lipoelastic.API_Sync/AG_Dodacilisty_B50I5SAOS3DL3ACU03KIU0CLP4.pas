uses '.API', '.lib';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mMultiAction: TMultiAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actSendBODOverAPI';
  mAction.Caption := '##Synchronizovat do SK##';
  mAction.Hint := 'Odešle dodací list na Slovensko';
  mAction.Category := 'tabList';
  mAction.OnExecute := @MarkedForSync;

  mMultiAction := Self.GetNewMultiAction;
  mMultiAction.ShowControl := True;
  mMultiAction.ShowMenuItem := True;
  mMultiAction.Name := 'actSendBODOverAPI_Sales';
  mMultiAction.Caption := '##Synch. obchod do SK##';
  mMultiAction.Items.Add('##Synch. obchod do SK##');
  mMultiAction.Items.Add('##Synch. převody do SK##');
  mMultiAction.Hint := 'Odešle dodací list pro obchodní objednávku na Slovensko';
  mMultiAction.Category := 'tabList';
  mMultiAction.OnExecuteItem := @MarkedForSync_Sales;
end;

procedure MarkedForSync(Sender: TComponent);
var
  mSite: TSiteForm;
  mOS: TNxCustomObjectSpace;
  mBO, mRowBO: TNxCustomBusinessObject;
  mList, mListToShow: TStringList;
  i,j: Integer;
  mRows:TNxCustomBusinessMonikerCollection;
  mSync:Boolean;
begin
  mSite:= Sender.Site;
  mOS:= mSite.BaseObjectSpace;
  mList:= TStringList.Create;
  mListToShow:= TStringList.Create;
  try
    TDynSiteForm(mSite).FillListWithSelectedRows(mList);
    if NxMessageBox('Synchronizace', 'Přejete si synchronizovat vybrané ('+IntToStr(mList.Count)+') doklady?', mdConfirm, mdbYesNo, mrNo, nil, false, mSite) = mrYes then begin
      for i:= 0 to mList.Count -1 do begin
        mBO:= mOS.CreateObject(Class_BillOfDelivery);
        try
          mBO.Load(mList[i], nil);
          if mBO.GetFieldValueAsString('PMState_ID') = cStateFinished then begin
            mSync:=True;
            mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
            for j:=0 to mRows.count-1 do begin
              mRowBO:=mRows.BusinessObject[j];
              if (mRowBO.GetFieldValueAsInteger('RowType')=3) and mSync then begin
                if NxIsEmptyOID(mRowBO.GetFieldValueAsString('ProvideRow_ID')) then mSync:=False;
              end;
            end;
            if mSync then begin
              mBO.PMChangeState(cStateToBeSynced);
              mListToShow.Add(QuotedStr(mBO.OID));
            end;
          end;
        finally
          mBO.Free;
        end;
      end;
    end;
    if mListToShow.count>0 then begin
      NxShowSimpleMessage('Doklady připraveny k synchronizaci. Nyní se otevře agenda zafiltrovaná za tyto doklady.'+#13#10+'Doklady musely mít 100% řádků provázaných s objednávkou', mSite);
      mSite.ShowSite(Site_BillOfDeliveries, true, 'QueryByUserDynSQLCondition;A.ID in ('+mListToShow.DelimitedText+')');
    end else begin
      NxShowMessage('Info okno','Žádný doklad nebyl ve stavu vyřízeno, nebo neměl 100% řádků provázaných s objednávkou.', mdError,true, mSite);
      //NxShowSimpleMessage('Žádný doklad nebyl ve stavu vyřízeno, nebo neměl 100% řádků provázaných s objednávkou.', mSite);
    end;
  finally
    TDynSiteForm(mSite).ActiveDataSet.RefreshCurrentItem;
    TDynSiteForm(mSite).RefreshData;
    mList.Free;
    mListToShow.Free;
  end;
end;




procedure SendOverAPI(Sender:TComponent);
var
  mSite: tSiteForm;
  mHeaderJSON, mRowJSON, mStoreBatchJSON, mResultJSON: TJSONSuperObject;
  mBO, mRowBO, mDocRowBatchBO: TNxCustomBusinessObject;
  i,j,k: integer;
  mRows, mDRBRows: TNxCustomBusinessMonikerCollection;
  mMessage, mProvideRow_ID:string;
  mOS:TNxCustomObjectSpace;
  mBODList, mResultList, mBODListQuoted:TStringList;

begin
  mSite:=TComponent(Sender).DynSite;
  mOS:=TDynSiteForm(mSite).BaseObjectSpace;
  mBODList:=TStringList.Create;
  mResultList:=TStringList.Create;
  TDynSiteForm(mSite).List.GetSelectedId(mBODList);
  if mBODList.count>0 then begin
    mBODListQuoted:=TStringList.Create;
    WaitWin.StartProgress('Přenáším do SK ...', '', mBODList.Count);
    for k:=0 to mBODList.count-1 do begin
      mBO:=mOS.CreateObject(Class_BillOfDelivery);
      mBO.load(mBODList.strings[k],nil);
      if Assigned(mBO) then begin
        try
          if NxIsBlank(mBO.GetFieldValueAsString('X_ExternalDocument')) then begin
            mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
            mHeaderJSON:=TJSONSuperObject.Create;
            mHeaderJSON.S['ExternalNumber']:=mBO.DisplayName;
            mHeaderJSON.S['Description']:=mBO.GetFieldValueAsString('Description');
            mHeaderJSON.S['BillOfDelivery_ID']:=mBO.OID;
            mHeaderJSON.S['SK_ReceiptCardCode']:=mbo.GetFieldValueAsString('DocQueue_ID.U_SK_ReceiptCardCode');
            mHeaderJSON.S['SK_StoreCode']:= mBO.GetFieldValueAsString('DocQueue_ID.U_SK_StoreCode');  //ALEC 23.10.2024
            mHeaderJSON.O['Rows'] := mHeaderJSON.CreateJSONArray;
            for i:=0 to mRows.count-1 do begin
              mRowBO:=mRows.BusinessObject[i];
              mRowJSON:=TJSONSuperObject.Create;
              mrowJSON.I['RowType']:=mRowBO.GetFieldValueAsInteger('RowType');
              if not(NxIsEmptyOID(mRowBO.GetFieldValueAsString('StoreCard_ID'))) then
                mRowJSON.S['StoreCardCode']:=mRowBO.GetFieldValueAsString('StoreCard_ID.Code')
              else
                mRowJSON.S['StoreCardCode']:='';
              mRowJSON.D['Quantity']:=mRowBO.GetFieldValueAsFloat('Quantity');
              mRowJSON.S['Text']:=mRowBO.GetFieldValueAsString('Text');
              mRowJSON.S['QUnit']:=mRowBO.GetFieldValueAsString('Qunit');
              mProvideRow_ID:=mOS.SQLSelectFirstAsString('Select X_ProvideRow_ID from receivedorders2 where id='+QuotedStr(mRowBO.GetFieldValueAsString('ProvideRow_ID')),'');
              mRowJSON.S['XProvideRowID']:=mProvideRow_ID;
              mRowJSON.S['BODRowID']:=mRowBO.OID;
              mRowJSON.O['DocRowBatches']:=mRowJSON.CreateJSONArray;
              mDRBRows:=mRowBO.GetLoadedCollectionMonikerForFieldCode(mRowBO.GetFieldCode('DocRowBatches'));
              if mDRBRows.count>0 then begin
                for j:=0 to mDRBRows.count-1 do begin
                  mStoreBatchJSON:=TJSONSuperObject.Create;
                  mDocRowBatchBO:=mDRBRows.BusinessObject[j];
                  mStoreBatchJSON.S['StoreBatchName']:=mDocRowBatchBO.GetFieldValueAsString('StoreBatch_ID.Name');
                  mStoreBatchJSON.D['Quantity']:=mDocRowBatchBO.GetFieldValueAsFloat('Quantity');
                  mStoreBatchJSON.DT8601['Expiry']:=mDocRowBatchBO.GetFieldValueAsDateTime('StoreBatch_ID.ExpirationDate$DATE');
                  mStoreBatchJSON.S['StoreBatchSpecification']:=mDocRowBatchBO.GetFieldValueAsString('StoreBatch_ID.Specification');
                  mRowJSON.A['DocRowBatches'].Add(mStoreBatchJSON);
                end;
              end;
              mHeaderJSON.A['Rows'].Add(mRowJSON);
            end;
            //mHeaderJSON.SaveToFile('C:\AbraGenSK\JSON\'+NxSearchReplace(mBO.DisplayName,'/','-',[srAll])+'.json');
            mResultJSON:= TJSONSuperObject.Create;
            mResultJSON:= API_POST(mHeaderJSON, 'BillsOfDelivery');
            //NxShowSimpleMessage(mResultJSON.AsString,mSite);
            if not(NxIsBlank(mResultJSON.S['DisplayName'])) then mBO.SetFieldValueAsString('X_ExternalDocument',mResultJSON.S['DisplayName']);
            if mBO.NeedSave then mBO.save;
            if mResultJSON.S['status']='error' then mResultList.Add(mbo.DisplayName+'  '+mResultJSON.S['statusMessage']);



          end;
        except
          mResultList.Add(mbo.DisplayName+'  '+ExceptionMessage);

          //TUHLE PRASÁRNU TADY DĚLÁM JEN PRO TO ABYCH MĚL JISTOTU, ŽE EXISTENCE DOKLADU V JINÉ ABŘE SE PROPÍŠE VŽDY I KDYŽ NASTANE CHYBA
          if NxIsBlank(mBO.GetFieldValueAsString('X_ExternalDocument')) and (not(NxIsBlank(mResultJSON.S['DisplayName']))) then begin
            mOS.SQLExecute('UPDATE StoreDocuments SET X_ExternalDocument = '+mResultJSON.S['DisplayName']+' WHERE ID ='+QuotedStr(mBO.OID));
          end;
        end;
      end;
      mbo.Free;
      WaitWin.ChangeText(IntToStr(k+1) + ' / ' + IntToStr(mBODList.count));
      WaitWin.StepIt;
    end;
    WaitWin.Stop;
    if mResultList.count>0 then begin
      for k:=0 to mResultList.count-1 do begin
        mMessage:=mMessage+#13#10+mResultList.Strings[k];
      end;
      NxShowSimpleMessage('Nepovedlo se přenést tyto DL '+mMessage,mSite);
    end;
    for i:=0 to mBODList.count-1 do begin
      mBODListQuoted.add(QuotedStr(mBODList.strings[i]));
    end;
    mSite.ShowSite(Site_BillOfDeliveries,true,'QueryByUserDynSQLCondition;A.ID in ('+mBODListQuoted.DelimitedText+')');
  end;
end;


procedure _CanDelete_Hook(Self: TDynSiteForm; var ACanDelete: Boolean);
var
  mExternalDoc: string;
begin
  if not(osNew in self.CurrentObject.State) then begin
    if Self.CurrentObject.GetFieldValueAsString('PMState_ID') in [cStateToBeSynced, cStateSyncOK, cStateSyncError] then begin
      ACanDelete:=false;
      NxShowSimpleMessage('Vymazání zamítnuto. Dodací list byl odeslán do ČR, vymažte napřed doklad v SK.',Self);
      exit;
    end;
    mExternalDoc:= self.CurrentObject.GetFieldValueAsString('X_ExternalDocument');
    if Not(NxIsBlank(mExternalDoc)) then begin
      if (NxSearch(mExternalDoc,'-',[srall],0)>0) and (NxSearch(mExternalDoc,'/',[srall],0)>0) then begin
        ACanDelete:=false;
        NxShowSimpleMessage('Vymazání zamítnuto. Dodací list byl odeslán do ČR, vymažte napřed doklad v SK.',Self);
      end;
    end;
  end;
end;

procedure _CanEdit_Hook(Self: TDynSiteForm; var ACanEdit: Boolean);
var
  mExternalDoc: string;
begin
  if not(osNew in self.CurrentObject.State) then begin
    if Self.CurrentObject.GetFieldValueAsString('PMState_ID') in [cStateToBeSynced, cStateSyncOK, cStateSyncError] then begin
      if (self.CompanyCache.GetUserID='SUPER00000') then begin
        NxShowSimpleMessage('Doklad byl odeslán do ČR, opravujte jen hodnoty neovlivnující synchronizaci.',Self);
      end else begin
        ACanEdit:=false;
        NxShowSimpleMessage('Oprava zamítnuta. Dodací list byl odeslán do SK, vymažte napřed doklad v SK.',Self);
        Exit;
      end;
    end;

    mExternalDoc:= self.CurrentObject.GetFieldValueAsString('X_ExternalDocument');
    if Not(NxIsBlank(mExternalDoc)) then begin
      if (NxSearch(mExternalDoc,'-',[srall],0)>0) and (NxSearch(mExternalDoc,'/',[srall],0)>0) then begin
        if (self.CompanyCache.GetUserID='SUPER00000') then begin
          NxShowSimpleMessage('Doklad byl odeslán do SK, opravujte jen hodnoty neovlivnující synchronizaci.',Self);
        end else begin
          ACanEdit:=false;
          NxShowSimpleMessage('Oprava zamítnuta. Dodací list byl odeslán do ČR, vymažte napřed doklad v SK.',Self);
        end;
      end;
    end;

  end;

end;


procedure MarkedForSync_Sales(Sender: TComponent; AIndex: integer);
var
  mSite: TSiteForm;
  mOS: TNxCustomObjectSpace;
  mBO, mRowBO: TNxCustomBusinessObject;
  mList, mListToShow: TStringList;
  i,j: Integer;
  mRows:TNxCustomBusinessMonikerCollection;
  mSync:Boolean;
begin
  mSite:= Sender.Site;
  mOS:= mSite.BaseObjectSpace;

  mList:= TStringList.Create;
  mListToShow:= TStringList.Create;
  try
    TDynSiteForm(mSite).FillListWithSelectedRows(mList);
    if NxMessageBox('Synchronizace', 'Přejete si synchronizovat vybrané ('+IntToStr(mList.Count)+') doklady?', mdConfirm, mdbYesNo, mrNo, nil, false, mSite) = mrYes then begin
      for i:= 0 to mList.Count -1 do begin
        mBO:= mOS.CreateObject(Class_BillOfDelivery);
        try
          mBO.Load(mList[i], nil);
          if mBO.GetFieldValueAsString('PMState_ID') = cStateFinished then begin
            mSync:=True;
            mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
            for j:=0 to mRows.count-1 do begin
              mRowBO:=mRows.BusinessObject[j];
              if (mRowBO.GetFieldValueAsInteger('RowType')=3) and mSync then begin
                if NxIsEmptyOID(mRowBO.GetFieldValueAsString('ProvideRow_ID')) then mSync:=False;
              end;
            end;
            if mSync then begin
              case AIndex of
                0: mBO.PMChangeState(cStateToBeSynced_Sales);
                1: mBO.PMChangeState(cStateToBeSynced_Transfers);
              end;
              mListToShow.Add(QuotedStr(mBO.OID));
            end;
          end;
        finally
          mBO.Free;
        end;
      end;
    end;
    if mListToShow.count>0 then begin
      NxShowSimpleMessage('Doklady připraveny k synchronizaci. Nyní se otevře agenda zafiltrovaná za tyto doklady.'+#13#10+'Doklady musely mít 100% řádků provázaných s objednávkou', mSite);
      mSite.ShowSite(Site_BillOfDeliveries, true, 'QueryByUserDynSQLCondition;A.ID in ('+mListToShow.DelimitedText+')');
    end else begin
      NxShowMessage('Info okno','Žádný doklad nebyl ve stavu vyřízeno, nebo neměl 100% řádků provázaných s objednávkou.', mdError,true, mSite);
      //NxShowSimpleMessage('Žádný doklad nebyl ve stavu vyřízeno, nebo neměl 100% řádků provázaných s objednávkou.', mSite);
    end;
  finally
    TDynSiteForm(mSite).ActiveDataSet.RefreshCurrentItem;
    TDynSiteForm(mSite).RefreshData;
    mList.Free;
    mListToShow.Free;
  end;
end;





{procedure _CanDelete_Hook(Self: TDynSiteForm; var ACanDelete: Boolean);
begin
 if not(osNew in self.CurrentObject.State) then begin
   if Not(NxIsBlank(self.CurrentObject.GetFieldValueAsString('X_ExternalDocument'))) then begin
      if (NxSearch(self.CurrentObject.GetFieldValueAsString('X_ExternalDocument'),'-',[srall],0)>0) and
         (NxSearch(self.CurrentObject.GetFieldValueAsString('X_ExternalDocument'),'/',[srall],0)>0) then begin
           ACanDelete:=false;
           NxShowSimpleMessage('Vymazání zamítnuto. Dodací list byl odeslán do SK, vymažte napřed doklad v SK.',Self);
      end;
   end;
 end;
end;

procedure _CanEdit_Hook(Self: TDynSiteForm; var ACanEdit: Boolean);
begin
 if not(osNew in self.CurrentObject.State) then begin
           if Not(NxIsBlank(self.CurrentObject.GetFieldValueAsString('X_ExternalDocument'))) then begin
              if (NxSearch(self.CurrentObject.GetFieldValueAsString('X_ExternalDocument'),'-',[srall],0)>0) and
                 (NxSearch(self.CurrentObject.GetFieldValueAsString('X_ExternalDocument'),'/',[srall],0)>0) then begin
                   if (self.CompanyCache.GetUserID='SUPER00000') then begin
                        NxShowSimpleMessage('Doklad byl odeslán do SK, opravujte jen hodnoty neovlivnující synchronizaci.',Self);
                    end else begin
                        ACanEdit:=false;
                        NxShowSimpleMessage('Oprava zamítnuta. Dodací list byl odeslán do SK, vymažte napřed doklad v SK.',Self);
                    end;
              end;
           end;
 end;
end; }

begin
end.