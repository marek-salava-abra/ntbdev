uses 'eu.spedos.Suppliers.ParseData', 'eu.spedos.Suppliers.Progress';

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Import dodavatelů';
  mAction.Items.Add('Nový import');
  mAction.Items.Add('Aktualizace hlavních dodavatelů ze souboru');
  mAction.Items.Add('Aktualizace označených dle IČ');
  mAction.Hint := 'Provede import z csv';
  //mAction.Hint := 'Provede aktualizace proti firmám';
  mAction.Category := 'tabList';
  mAction.OnExecuteItem := @ImportData;

end;

procedure ImportData(sender:Tcomponent; index:integer);
var
 mSite:TsiteForm;
 mOS:TNxCustomObjectSpace;
 mSMBO, mSMMasterBO, mbankBO, mUnitBO, mSubBO, mStoreCardBO:TNxCustomBusinessObject;
 mPLRows:TNxCustomBusinessMonikerCollection;
 mPLRow:TNxCustomBusinessObject;
 mList:TStringList;
 mopenDLG:TOpenDialog;
 mParams, mParRow : TNxParameters;
 i, j, k:integer;
 mMaster_ID:String;
 mNew:Boolean;
 mGRows : TMultiGrid;
 mFinalDate, mBaseDate:extended;
 mStoreCard_ID, mFirm_ID, mSupplier_ID, mStore_ID, mStoreSubCard_ID:string;
 mCode, mName,mFirmName, mICO, mDIC, mTempStr, mHlavni, mSpecification:string;
begin
 mSite:=TComponent(sender).BusRollSite;
 mOS:=msite.BaseObjectSpace;
 if index=0 then begin
  try
      try
        mOS:=msite.BaseObjectSpace;
        mOpenDlg := TOpenDialog.Create(Sender);
        mopenDLG.Filter :=  'Soubory s daty (*.csv)|*.csv';
        if mOpenDlg.Execute then begin
         mList:=TStringList.create;
         mlist.LoadFromFile(mopenDLG.FileName);
         mParams := ParseData(mlist);
         j:=mList.Count;
              try
                 ProgressInit(mSite, 'importuji dodavatele...', j);
                 for i := 1 to j - 1 do begin
                 mParRow := TNxParameters(TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Params(i));
                 mStoreCard_ID:=GetStoreCard_ID(mOS,mParRow.ParamByName('kod').AsString);
                 if not(NxIsEmptyOID(mStoreCard_ID)) then begin
                   mFirm_ID:=GetFirm_ID(mOS,mParRow.ParamByName('ico').AsString);
                   if not(NxIsEmptyOID(mFirm_ID)) then begin
                     mSupplier_ID:=GetSupplier_ID(mOS, mStoreCard_ID,mFirm_ID);
                      if NxIsEmptyOID(mSupplier_ID) then begin
                       mSMBO:=mos.CreateObject(Class_Supplier);
                       mSMBO.New;
                       mSMBO.Prefill;
                       mSMBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
                       mSMBO.SetFieldValueAsString('Firm_ID',mFirm_ID);
                       msmbo.SetFieldValueAsString('ExternalNumber',AnsiLeftStr(mParRow.ParamByName('ext_code').AsString,40));
                       msmbo.SetFieldValueAsString('Name',AnsiLeftStr(mParRow.ParamByName('ext_name').AsString,100));
                       mSMBO.SetFieldValueAsString('Qunit',mSMBO.GetFieldValueAsString('StoreCard_ID.MainUnitCode'));
                       msmbo.SetFieldValueAsInteger('DeliveryTime',trunc(NxIBStrToFloat(mParRow.ParamByName('doba_dodani').AsString)));
                       mSMBO.SetFieldValueAsFloat('MinimalQuantity',NxIBStrToFloat(mParRow.ParamByName('min_mno').AsString));
                       mSMBO.SetFieldValueAsFloat('Packing',NxIBStrToFloat(mParRow.ParamByName('baleni').AsString));
                       mSMBO.save;
                       mSMBO.free;
                      end;
                      if not(NxIsEmptyOID(mSupplier_ID)) then begin
                       mSMBO:=mos.CreateObject(Class_Supplier);
                       mSMBO.Load(mSupplier_ID,nil);
                       msmbo.SetFieldValueAsString('ExternalNumber',AnsiLeftStr(mParRow.ParamByName('ext_code').AsString,40));
                       msmbo.SetFieldValueAsString('Name',AnsiLeftStr(mParRow.ParamByName('ext_name').AsString,100));
                       mSMBO.SetFieldValueAsString('Qunit',mSMBO.GetFieldValueAsString('StoreCard_ID.MainUnitCode'));
                       msmbo.SetFieldValueAsInteger('DeliveryTime',trunc(NxIBStrToFloat(mParRow.ParamByName('doba_dodani').AsString)));
                       mSMBO.SetFieldValueAsFloat('MinimalQuantity',NxIBStrToFloat(mParRow.ParamByName('min_mno').AsString));
                       mSMBO.SetFieldValueAsFloat('Packing',NxIBStrToFloat(mParRow.ParamByName('baleni').AsString));
                       mSMBO.save;
                       mSMBO.free;
                      end;
                   end;
                   mStore_ID:=GetStore_ID(mOS,mParRow.ParamByName('sklad').AsString);
                   mStoreSubCard_ID:=GetStoreSubCard_ID(mOS, mStoreCard_ID,mStore_ID);
                   if not(NxIsEmptyOID(mStoreSubCard_ID)) then begin
                      mSubBO:=mOS.CreateObject(Class_StoreSubCard);
                      mSubBO.Load(mStoreSubCard_ID,nil);
                      mSubBO.SetFieldValueAsFloat('LowLimitQuantity',NxIBStrToFloat(mParRow.ParamByName('spod_limit').AsString));
                      mSubBO.save;
                      mSubBO.free;
                   end;
                 end;
                 ProgressSetPos(i+1);
                 end;



              finally
                ProgressDispose();

              end;
          end;
      finally
      end;
  finally
  end;
 end;
 if index=1 then begin
  try
      try
        mOS:=msite.BaseObjectSpace;
        mOpenDlg := TOpenDialog.Create(Sender);
        mopenDLG.Filter :=  'Soubory s daty (*.csv)|*.csv';
        if mOpenDlg.Execute then begin
         mList:=TStringList.create;
         mlist.LoadFromFile(mopenDLG.FileName);
         //mParams := ParseData(mlist);
         j:=mList.Count;
              try
                 ProgressInit(mSite, 'importuji hlavní dodavatele...', j);
                 for i := 1 to j - 1 do begin
                  mTempStr:=mList.Strings[i];
                  mStoreCard_ID:=NxTrapStr(mTempStr,';');
                  mSupplier_ID:=NxTrapStr(mTempStr,';');
                  mCode:=NxTrapStr(mTempStr,';');
                  mName:=NxTrapStr(mTempStr,';');
                  mSpecification:=NxTrapStr(mTempStr,';');
                  mFirmName:=NxTrapStr(mTempStr,';');
                  mICO:=NxTrapStr(mTempStr,';');
                  mDIC:=NxTrapStr(mTempStr,';');
                  mHlavni:=UpperCase(NxTrapStr(mTempStr,';'));
                  if not(NxIsEmptyOID(mStoreCard_ID)) and not(NxIsEmptyOID(mSupplier_ID)) then begin
                   if mHlavni='ANO' then begin
                     mSMBO:=mOS.CreateObject(Class_Supplier);
                     mSMBO.Load(mSupplier_ID,nil);
                     if not(NxIsBlank(mICO)) then begin
                       mFirm_ID:=GetFirm_ID(mOS, mICO);
                        if not(NxIsEmptyOID(mFirm_ID)) then begin
                          msmbo.SetFieldValueAsString('Firm_ID',mFirm_ID);
                          msmbo.save;
                        end;
                     end;
                     if not(NxIsBlank(mDIC)) then begin
                       mFirm_ID:=GetFirm2_ID(mOS, mDIC);
                        if not(NxIsEmptyOID(mFirm_ID)) then begin
                          msmbo.SetFieldValueAsString('Firm_ID',mFirm_ID);
                          msmbo.save;
                        end;
                     end;
                     mSMBO.free;
                     mStoreCardBO:=mOS.CreateObject(Class_StoreCard);
                     mStoreCardBO.Load(mStoreCard_ID,nil);
                     mStoreCardBO.SetFieldValueAsString('MainSupplier_ID', mSupplier_ID);
                     mStoreCardBO.SetFieldValueAsString('Specification', AnsiLeftStr(mSpecification,30));
                     mStoreCardBO.save;
                     mStoreCardBO.free;
                   end;
                  end;
                 ProgressSetPos(i+1);
                 end;



              finally
                ProgressDispose();

              end;
          end;
      finally
      end;
  finally
  end;
 end;
 if index=2 then begin
   mList:=TStringList.create;
   TBusRollSiteForm(mSite).List.GetSelectedId(mList);
   if mlist.Count>0 then begin
     try
                 ProgressInit(mSite, 'aktualizuji dodavatele...', mlist.Count);
                 for i := 0 to mList.count - 1 do begin
                   mStoreCardBO:=mOS.CreateObject(Class_StoreCard);
                   mStoreCardBO.load(mlist.strings[i],nil);
                    if not(NxIsEmptyOID(mStoreCardBO.GetFieldValueAsString('MainSupplier_ID'))) then begin
                      mSMBO:=mOS.CreateObject(Class_Supplier);
                      mSMBO.Load(mStoreCardBO.GetFieldValueAsString('MainSupplier_ID'),nil);
                      if not(NxIsBlank(mSMBO.GetFieldValueAsString('Firm_ID.OrgIdentNumber'))) then begin
                        mFirm_ID:=GetFirm_ID(mOS, mSMBO.GetFieldValueAsString('Firm_ID.OrgIdentNumber'));
                        if not(NxIsEmptyOID(mFirm_ID)) then begin
                          msmbo.SetFieldValueAsString('Firm_ID',mFirm_ID);
                          msmbo.save;
                        end;
                      end;
                      msmbo.free;


                    end;
                   mStoreCardBO.free;
                 ProgressSetPos(i+1);
                 end;



              finally
                ProgressDispose();

              end;
   end;
 end;
end;


begin
end.