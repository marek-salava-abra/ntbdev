uses 'eu.promos.extcodename.progress', 'eu.promos.extcodename.lib';

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mMAction: TMultiAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Import dod. kódů';
  mAction.Hint := 'Importuje kódy dodavatele';
  mAction.Category := 'tabList';
  mAction.OnExecute := @ImpSupplier;

end;

Procedure ImpSupplier(Sender:TComponent);
var
  mSite : TSiteForm;
  mOpenDlg : TOpenDialog;
  mList : TStringList;
  mBO, mStoreCardBO : TNxCustomBusinessObject;
  i,j: integer;
  mOS:TNxCustomObjectSpace;
  mStoreCard_ID, mSupplier_ID, mFirm_ID:string;
  mDialog:Boolean;
  mCode, mExtCode, mExtName:string;
begin
  mSite:=TComponent(Sender).BusRollSite;
  mOpenDlg:=TOpenDialog.Create(Sender);
  mOpenDlg.Filter := 'Soubor s daty (*.csv)| *.csv';
  mOS:= msite.BaseObjectSpace;
  if mOpenDlg.Execute then begin
      mDialog:=false;
      mFirm_ID:='';
      mList:=tstringlist.Create;
      mList.LoadFromFile(mOpenDlg.FileName);
      GetDAta(msite, mFirm_ID, mDialog);
      if NxIsEmptyOID(mFirm_ID) then begin
        NxShowSimpleMessage('Nebyla vybrána firma.', mSite);
        exit;
      end;
      if (mList.count>2) and mDialog then begin
        ProgressInit(mSite, 'Import dod. kódů...', mList.Count);
            for i:=1 to mList.Count-1 do begin
            mCode:=NxTrapStr(mlist.strings[i],';');
            mExtCode:=NxTrapStr(mlist.strings[i],';');
            mExtName:=NxTrapStr(mlist.strings[i],';');
            mStoreCard_ID:=GetSToreCard_ID(mOS, mCode);
            if not(NxIsEmptyOID(mStoreCard_ID)) then begin
               mStoreCardBO:=mOS.CreateObject(Class_StoreCard);
               mStoreCardBO.Load(mStoreCard_ID,nil);
               mSupplier_ID:=GetSupplier_ID(mOS, mStoreCard_ID, mFirm_ID);
               if NxIsEmptyOID(mSupplier_ID) then begin
                 mBO:=mOS.CreateObject(Class_Supplier);
                 mBO.New;
                 mbo.prefill;
                 mbo.SetFieldValueAsString('Firm_ID',mFirm_ID);
                 mBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
                 mBO.SetFieldValueAsString('ExternalNumber', mExtCode);
                 mBO.SetFieldValueAsString('Name',mExtName);
                 mBO.SetFieldValueAsString('Qunit',mStoreCardBO.GetFieldValueAsString('MainUnitCode'));
                 mbo.save;
                 mbo.free;
               end else begin
                 mBO:=mOS.CreateObject(Class_Supplier);
                 mBO.Load(mSupplier_ID,nil);
                 mBO.SetFieldValueAsString('ExternalNumber', mExtCode);
                 mBO.SetFieldValueAsString('Name',mExtName);
                 mbo.save;
                 mbo.free;
               end;
              mStoreCardBO.Free;
            end;
            ProgressSetPos(i+1);
            end;
        ProgressDispose();

      end;

  end;
end;


begin
end.