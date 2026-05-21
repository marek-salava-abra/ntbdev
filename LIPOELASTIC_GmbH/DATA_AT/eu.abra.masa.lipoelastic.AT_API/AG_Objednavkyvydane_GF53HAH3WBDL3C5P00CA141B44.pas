uses '.API', '.lib';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actSendOVoverAPI';
  mAction.Caption := '##Synchronize to CZ##';
  mAction.Hint := 'Send Order out to Czech Republic';
  mAction.Category := 'tabList';
  mAction.OnExecute := @SendOverAPI;
end;

procedure SendOverAPI(Sender:TComponent);
var
  mSite: tSiteForm;
  mHeaderJSON, mRowJSON, mResultJSON: TJSONSuperObject;
  mBO, mRowBO: TNxCustomBusinessObject;
  i,j: integer;
  mRows: TNxCustomBusinessMonikerCollection;
  mMessage, mErrorMessage:string;
  mList:TStringList;
begin
  mSite:=TComponent(Sender).DynSite;
  mList:=TStringList.Create;
  TDynSiteForm(mSite).List.GetSelectedId(mList);
  if mlist.Count>0 then begin
   mErrorMessage:='';
   WaitWin.StartProgress('Controling orders ...', '', mList.Count);
   for j:=0 to mList.count-1 do begin
      mBO:=msite.BaseObjectSpace.CreateObject(Class_IssuedOrder);
      mBO.Load(mList.strings[j],nil);
      if not(mBO.GetFieldValueAsBoolean('Confirmed')) then mErrorMessage:=mErrorMessage+nxCrLf+mBO.DisplayName;
      mbo.free;
      WaitWin.ChangeText(IntToStr(1+j) + ' / ' + IntToStr(mlist.Count));
     WaitWin.StepIt;
     end;
   WaitWin.Stop;
   if not(NxIsBlank(mErrorMessage)) then begin
     NxShowSimpleMessage('These orders are not confirmed:'+nxCrLf+mErrorMessage,mSite);
     mlist.Clear;
     exit;
   end;
   mErrorMessage:='';
   WaitWin.StartProgress('Synchronizing to CZ ...', '', mList.Count);
   for j:=0 to mList.count-1 do begin
      mBO:=msite.BaseObjectSpace.CreateObject(Class_IssuedOrder);
      mBO.Load(mList.strings[j],nil);
      if Assigned(mBO) then begin
          if NxIsBlank(mBO.GetFieldValueAsString('DocQueue_ID.U_CZ_StoreCode')) or
            NxIsBlank(mBO.GetFieldValueAsString('DocQueue_ID.U_CZ_DivisionCode')) or
            NxIsBlank(mBO.GetFieldValueAsString('DocQueue_ID.U_CZ_ReceivedOrderCode')) then begin
            NxShowSimpleMessage('Document serie '+#13#10+
                                mbo.GetFieldValueAsString('DocQueue_ID.Code')+' - '+mbo.GetFieldValueAsString('DocQueue_ID.Name')+#13#10+
                                'has not set up parameters for sending to Czech republic. Done.',mSite);
            exit;
          end;
        try
          if Not(NxIsBlank(mBO.GetFieldValueAsString('X_ExternalDocument'))) then begin
           if (NxSearch(mBO.GetFieldValueAsString('X_ExternalDocument'),'-',[srall],0)>0) and
              (NxSearch(mBO.GetFieldValueAsString('X_ExternalDocument'),'/',[srall],0)>0) then begin
              mErrorMessage:=mErrorMessage+#13#10+'Sending '+mBO.DisplayName+' was already done. Not possible to send again.';
              //exit;
           end;
          end else begin
            mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
            mHeaderJSON:=TJSONSuperObject.Create;
            mHeaderJSON.S['DocQueueCode']:=mBO.GetFieldValueAsString('DocQueue_ID.U_CZ_ReceivedOrderCode');
            mHeaderJSON.S['IODocQueueCode']:='';
            mHeaderJSON.S['CountryCode']:='AT';
            mHeaderJSON.S['ExternalNumber']:=mBO.DisplayName;
            mHeaderJSON.S['Description']:=mBO.GetFieldValueAsString('Description');
            mHeaderJSON.S['IssuedOrder_ID']:=mBO.OID;
            mHeaderJSON.DT8601['DeliveryDate']:=mBO.GetFieldValueAsDateTime('X_Datum_Dodani');
            mHeaderJSON.O['Rows'] := mHeaderJSON.CreateJSONArray;
            for i:=0 to mRows.count-1 do begin
              mRowBO:=mRows.BusinessObject[i];
              mRowJSON:=TJSONSuperObject.Create;
              mrowJSON.I['RowType']:=mRowBO.GetFieldValueAsInteger('RowType');
              mRowJSON.S['StoreCode']:=mBO.GetFieldValueAsString('DocQueue_ID.U_CZ_StoreCode');
              if not(NxIsEmptyOID(mRowBO.GetFieldValueAsString('StoreCard_ID'))) then
                mRowJSON.S['StoreCardCode']:=mRowBO.GetFieldValueAsString('StoreCard_ID.Code') else
                mRowJSON.S['StoreCardCode']:='';
              mRowJSON.D['Quantity']:=mRowBO.GetFieldValueAsFloat('Quantity');
              mRowJSON.S['DivisionCode']:=mBO.GetFieldValueAsString('DocQueue_ID.U_CZ_DivisionCode');
              mRowJSON.S['Text']:=mRowBO.GetFieldValueAsString('Text');
              mRowJSON.S['QUnit']:=mRowBO.GetFieldValueAsString('Qunit');
              mRowJSON.S['Row_ID']:=mRowBO.OID;
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
              mErrorMessage:=mErrorMessage+#13#10+mResultJSON.S['Code'] + ' - Order out - synchronization not succesfull.';
              //NxShowSimpleMessage(mResultJSON.S['Code'] + ' - doklad se nepodařilo synchronizovat.', mSite);
            end;
            if mBO.NeedSave then begin
              mBO.save;
              TDynSiteForm(mSite).RefreshData;
              TDynSiteForm(mSite).ActiveDataSet.SeekID(mBO.OID);
              //if NxIsValidEMail(mbo.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Email'),False) then
              //SendInternalMail(mSite.BaseObjectSpace,mbo.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.Email'),'Nová objednávka '+mBO.GetFieldValueAsString('X_ExternalDocument'),
              //   'Ve české abře vznikla nová objednávka číslo '+mBO.GetFieldValueAsString('X_ExternalDocument')+' ze slovenské objednávky '+mbo.DisplayName+mMessage,'#300000001', mBO.OID, mbo.CLSID);
              //NxShowSimpleMessage('Objednávka byla přenesena do ČR, přidělené číslo '+mBO.GetFieldValueAsString('ExternalNumber')+mMessage,mSite);
              mBO.free;
            end;
          end;
        except
          NxShowSimpleMessage(ExceptionMessage,mSite);
          WaitWin.Stop;
        end;
     end;
     WaitWin.ChangeText(IntToStr(1+j) + ' / ' + IntToStr(mlist.Count));
     WaitWin.StepIt;
     end;
    WaitWin.Stop;
    TDynSiteForm(mSite).RefreshData;
    if not(NxIsBlank(mErrorMessage)) then NxShowSimpleMessage(mErrorMessage,mSite);
    //mSite.ShowSite(Site_IssuedOrders,true,'QueryByUserDynSQLCondition;A.ID in ('+mlist.DelimitedText+')');
  end;
end;

procedure _CanDelete_Hook(Self: TDynSiteForm; var ACanDelete: Boolean);
begin
 if not(osNew in self.CurrentObject.State) then begin
   if Not(NxIsBlank(self.CurrentObject.GetFieldValueAsString('X_ExternalDocument'))) then begin
      if (NxSearch(self.CurrentObject.GetFieldValueAsString('X_ExternalDocument'),'-',[srall],0)>0) and
         (NxSearch(self.CurrentObject.GetFieldValueAsString('X_ExternalDocument'),'/',[srall],0)>0) then begin
               ACanDelete:=false;
               NxShowSimpleMessage('Deleting is not permited. Order out was sent to Czech republic, please delete order in Czech Abra.',Self);
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
                        NxShowSimpleMessage('Objednávka byla odeslána do ČR, opravujte jen hodnoty neovlivnující synchronizaci.',Self);
                    end else begin
                        ACanEdit:=false;
                        NxShowSimpleMessage('Editing is not permited. Order out was sent to Czech republic, please delete order in Czech Abra.',Self);
                   end;
              end;
           end;
 end;
end;


begin
end.

begin
end.