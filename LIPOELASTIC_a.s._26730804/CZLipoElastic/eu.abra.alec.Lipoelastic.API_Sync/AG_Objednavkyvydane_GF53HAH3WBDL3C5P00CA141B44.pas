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
  mAction.Hint := 'Odešle objednávku na Slovensko';
  mAction.Category := 'tabList';
  mAction.OnExecute := @SendOverAPI;
end;

procedure SendOverAPI(Sender:TComponent);
var
  mSite: tSiteForm;
  mHeaderJSON, mRowJSON, mResultJSON, mPLJSON: TJSONSuperObject;
  mPLJSONArray:TJSONSuperObjectArray;
  mBO, mRowBO: TNxCustomBusinessObject;
  i,j,k: integer;
  mRows: TNxCustomBusinessMonikerCollection;
  mMessage, mErrorMessage:String;
  mList, mNotFoundPLStoreCards, mNotFoundIDs:TStringList;
  mPLStoreCard_ID:string;
begin
  mSite:=TComponent(Sender).DynSite;
  mList:=TStringList.Create;
  TDynSiteForm(mSite).List.GetSelectedId(mList);
  if mlist.Count>0 then begin
   mErrorMessage:='';
   WaitWin.StartProgress('Přenáším na Slovensko ...', '', mList.Count);
   for j:=0 to mList.count-1 do begin
      mBO:=msite.BaseObjectSpace.CreateObject(Class_IssuedOrder);
      mBO.Load(mList.strings[j],nil);
      if Assigned(mBO) then begin



     try
      if Not(NxIsBlank(mBO.GetFieldValueAsString('X_ExternalDocument'))) then begin
       if (NxSearch(mBO.GetFieldValueAsString('X_ExternalDocument'),'-',[srall],0)>0) and
          (NxSearch(mBO.GetFieldValueAsString('X_ExternalDocument'),'/',[srall],0)>0) then begin
          NxShowSimpleMessage('Odeslání již bylo provedeno. Nelze odeslat znovu.',mSite);
          WaitWin.Stop;
          exit;
       end;
      end;

      if not (mBO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode')='SK') then begin
         NxShowSimpleMessage('Sídlo firmy není na Slovensku.',msite);
         WaitWin.Stop;
         exit;
      end;

      if NxIsBlank(mBO.GetFieldValueAsString('DocQueue_ID.U_SK_StoreCode')) or
        NxIsBlank(mBO.GetFieldValueAsString('DocQueue_ID.U_SK_DivisionCode')) or
        NxIsBlank(mBO.GetFieldValueAsString('DocQueue_ID.U_SK_ReceivedOrderCode')) then begin
        NxShowSimpleMessage('Řada dokladů '+#13#10+
                            mbo.GetFieldValueAsString('DocQueue_ID.Code')+' - '+mbo.GetFieldValueAsString('DocQueue_ID.Name')+#13#10+
                            'nemá nastaveny parametry pro odeslání na Slovensko. Ukončuji.',mSite);
        WaitWin.Stop;
        exit;
      end else begin
        mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
        if mBO.GetFieldValueAsString('DocQueue_ID.Code')='OVMPI' then begin
          mNotFoundPLStoreCards:=TStringList.Create;
          mNotFoundIDs:=TStringList.Create;
          mNotFoundPLStoreCards.clear;
          mNotFoundIDs.Clear;
          for i:=0 to mRows.count-1 do begin
           mRowBO:=mRows.BusinessObject[i];
             if (mRowBO.GetFieldValueAsInteger('RowType')=3) and not(NxIsEmptyOID(mRowBO.GetFieldValueAsString('X_PL_StoreCard_ID'))) then begin
               mPLJSON:=API_GET(cUrl+'storecards?select=id&where=code eq '+QuotedStr(mRowBO.GetFieldValueAsString('X_PL_StoreCard_ID.code')));
               mPLJSONArray:=mPLJSON.AsArray;
               k:=mPLJSONArray.Length;
               if k=1 then mPLStoreCard_ID:=mPLJSONArray.O[0].S['id'] else mPLStoreCard_ID:='';
               if NxIsEmptyOID(mPLStoreCard_ID) then begin
                if mNotFoundPLStoreCards.IndexOf(mRowBO.GetFieldValueAsString('X_PL_StoreCard_ID.code'))=-1 then
                 mNotFoundPLStoreCards.Add(mRowBO.GetFieldValueAsString('X_PL_StoreCard_ID.code'));
                if mNotFoundIDs.IndexOf(mRowBO.GetFieldValueAsString('X_PL_StoreCard_ID'))=-1 then
                 mNotFoundIDs.Add(QuotedStr(mRowBO.GetFieldValueAsString('X_PL_StoreCard_ID')));
               end;
             end;
          end;
          if mNotFoundPLStoreCards.count>0 then begin
            WaitWin.Stop;
            NxShowSimpleMessage('Nebyly nalezeny tyto karty etiket '+#13#10+#13#10+mNotFoundPLStoreCards.Text+#13#10+#13#10+'Kontaktujte odpovědnou osobu',mSite);
            if NxMessageBox('Synchronizace', 'Přejete si zobrazit nenalezené karty etiket?', mdConfirm, mdbYesNo, mrNo, nil, false, mSite) = mrYes then
             mSite.ShowSite(Site_StoreCards, true, 'FilterByUserDynSQLCondition;A.ID in ('+mNotFoundIDs.DelimitedText+')');
            exit;
          end;
        end;
        mHeaderJSON:=TJSONSuperObject.Create;
        mHeaderJSON.S['DocQueueCode']:=mBO.GetFieldValueAsString('DocQueue_ID.U_SK_ReceivedOrderCode');
        mHeaderJSON.S['IODocQueueCode']:=mBO.GetFieldValueAsString('DocQueue_ID.U_SK_IssuedOrderCode');
        mHeaderJSON.S['ExternalNumber']:=mBO.GetFieldValueAsString('ExternalNumber');       //9.7.2024 ALEC bylo dohodnuto, že se přenáší ext. num do ext.num a displayname do x_externalDocument
        mHeaderJSON.S['X_ExternalDocument']:= mBO.DisplayName;
        mHeaderJSON.S['Description']:=mBO.GetFieldValueAsString('Description');
        mHeaderJSON.S['IssuedOrder_ID']:=mBO.OID;
        mHeaderJSON.DT8601['DeliveryDate']:=mBO.GetFieldValueAsDateTime('X_Datum_Dodani');
        mHeaderJSON.O['Rows'] := mHeaderJSON.CreateJSONArray;
        for i:=0 to mRows.count-1 do begin
          mRowBO:=mRows.BusinessObject[i];
          mRowJSON:=TJSONSuperObject.Create;
          mrowJSON.I['RowType']:=mRowBO.GetFieldValueAsInteger('RowType');
          mRowJSON.S['StoreCode']:=mBO.GetFieldValueAsString('DocQueue_ID.U_SK_StoreCode');
          if not(NxIsEmptyOID(mRowBO.GetFieldValueAsString('StoreCard_ID'))) then
            mRowJSON.S['StoreCardCode']:=mRowBO.GetFieldValueAsString('StoreCard_ID.Code') else
            mRowJSON.S['StoreCardCode']:='';
          mRowJSON.D['Quantity']:=mRowBO.GetFieldValueAsFloat('Quantity');
          mRowJSON.S['DivisionCode']:=mBO.GetFieldValueAsString('DocQueue_ID.U_SK_DivisionCode');
          mRowJSON.S['Text']:=mRowBO.GetFieldValueAsString('Text');
          mRowJSON.S['QUnit']:=mRowBO.GetFieldValueAsString('Qunit');
          mRowJSON.S['Row_ID']:=mRowBO.OID;
          if not(NxIsEmptyOID(mRowBO.GetFieldValueAsString('X_PL_StoreCard_ID'))) then
           mRowJSON.S['PLStoreCardCode']:=mRowBO.GetFieldValueAsString('X_PL_StoreCard_ID.Code') else
           mRowJSON.S['PLStoreCardCode']:='';
          mHeaderJSON.A['Rows'].Add(mRowJSON);
        end;
        mResultJSON:= TJSONSuperObject.Create;
        mResultJSON:= API_POST(mHeaderJSON, 'IssuedOrders');
        if not(NxIsEmptyOID(mResultJSON.S['ID'])) then begin
         mBO.SetFieldValueAsString('X_ExternalDocument',mResultJSON.S['Code']);
         mBO.SetFieldValueAsBoolean('Issued',true);
         mBO.SetFieldValueAsDateTime('X_SendDate$Date',Now);
        end;
        if not(NxIsBlank(mResultJSON.S['IODisplayName'])) then mMessage:='. Dále vznikla objednávka vydaná pro výrobu  s číslem '+mResultJSON.S['IODisplayName'];
        if NxIsEmptyOID(mResultJSON.S['ID']) then begin
          //ABO.SetFieldValueAsDateTime('X_SynchronizationDate$Date',0);
           mErrorMessage:=mErrorMessage+#13#10+mResultJSON.S['Code'] + ' - doklad se nepodařilo synchronizovat.'
          //NxShowSimpleMessage(mResultJSON.S['Code'] + ' - doklad se nepodařilo synchronizovat.', mSite);
        end;
        if mBO.NeedSave then begin
          mBO.save;
          TDynSiteForm(mSite).RefreshData;
          TDynSiteForm(mSite).ActiveDataSet.SeekID(mBO.OID);
          if NxIsValidEMail(mbo.GetFieldValueAsString('Firmoffice_ID.Address_ID.Email'),False) then
          SendInternalMail(mSite.BaseObjectSpace,mbo.GetFieldValueAsString('FirmOffice_ID.Address_ID.Email'),'Nová objednávka '+mBO.GetFieldValueAsString('X_ExternalDocument'),
             'Ve slovenské abře vznikla nová objednávka číslo '+mBO.GetFieldValueAsString('X_ExternalDocument')+' z české objednávky '+mbo.DisplayName+mMessage,'1100000101', mBO.OID, mbo.CLSID);
          //NxShowSimpleMessage('Objednávka byla přenesena na Slovensko, přidělené číslo '+mBO.GetFieldValueAsString('ExternalNumber')+mMessage,mSite);
          mBO.free;
        end;
       end;
        except
          WaitWin.Stop;
        end;
     end;
     WaitWin.ChangeText(IntToStr(1+j) + ' / ' + IntToStr(mlist.Count));
     WaitWin.StepIt;
     end;
    WaitWin.Stop;
  end;
end;

procedure _CanDelete_Hook(Self: TDynSiteForm; var ACanDelete: Boolean);
begin
 if not(osNew in self.CurrentObject.State) then begin
   if Not(NxIsBlank(self.CurrentObject.GetFieldValueAsString('X_ExternalDocument'))) then begin
      if (NxSearch(self.CurrentObject.GetFieldValueAsString('X_ExternalDocument'),'-',[srall],0)>0) and
         (NxSearch(self.CurrentObject.GetFieldValueAsString('X_ExternalDocument'),'/',[srall],0)>0) then begin
           ACanDelete:=false;
           NxShowSimpleMessage('Vymazání zamítnuto.Objednávka byla odeslána na Slovensko, vymažte napřed doklad na Slovensku.',Self);
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
                        NxShowSimpleMessage('Položka byla synchronizována, opravujte jen hodnoty neovlivnující synchronizaci.',Self);
           end else begin
                    ACanEdit:=false;
                    NxShowSimpleMessage('Oprava zamítnuta.Objednávka byla odeslána na Slovensko, vymažte napřed doklad na Slovensku.',Self);
           end;
      end;
   end;
 end;
end;


begin
end.