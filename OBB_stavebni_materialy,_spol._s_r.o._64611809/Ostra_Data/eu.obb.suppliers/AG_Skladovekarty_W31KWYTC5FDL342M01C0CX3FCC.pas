uses 'eu.obb.suppliers.ParseData', 'eu.obb.suppliers.Progress';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  if NxGetActualUserID(self.BaseObjectSpace) in ['7000000101','SUPER00000'] then begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Import dodavatelů';
  mAction.Items.Add('Import dodavatelů');
  mAction.Items.Add('Odebrání dodavatelů');
  mAction.Hint := 'Provede import z csv';
  mAction.Category := 'tabList';
  mAction.OnExecuteItem := @ImportData;

  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Import VELUX';
  mAction.Items.Add('Nový import');
  //mAction.Items.Add('Revize');
  mAction.Hint := 'Provede import z csv';
  mAction.Category := 'tabList';
  mAction.OnExecuteItem := @Velux;
  end;
end;

procedure ImportData(sender:Tcomponent; index:integer);
var
 mSite:TsiteForm;
 mOS:TNxCustomObjectSpace;
 mSMBO, mFirmBO, mbankBO, mSupplierBO, mSCBO:TNxCustomBusinessObject;
 mUnits:TNxCustomBusinessMonikerCollection;
 mUnit:TNxCustomBusinessObject;
 mList, mErrorList, mSupList:TStringList;
 mopenDLG:TOpenDialog;
 mParams, mParRow : TNxParameters;
 i, j, k:integer;
 mStoreCard_ID, mSupplier_ID, mFirm_ID:String;
 mNew:Boolean;
 mGRows : TMultiGrid;
 mSaveDlg:TFileSaveDialog;
 {'code','name','date','price','quantity','odpis','stredisko','SN'}
begin
 mSite:=TComponent(sender).BusRollSite;
 mOS:=msite.BaseObjectSpace;
  if index=1 then begin
    mList:=TStringList.Create;
    TBusRollSiteForm(mSite).List.GetSelectedId(mList);
    if mlist.Count>0 then begin
      if NxMessageBox('Dotaz','Odebrat dodavatele z '+IntToStr(mList.count)+' karet?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
        ProgressInit(mSite, 'Odebírání dodavatelů...', mList.Count);
        mSupList:=TStringList.Create;
           for i := 0 to mList.Count - 1 do begin
            mSupList.clear;
            mOS.SQLSelect('Select id from suppliers where storecard_id='+QuotedStr(mList.Strings[i]),mSupList);
            if mSupList.count>0 then begin
              for j:=0 to mSupList.count-1 do begin
                mSupplierBO:=mOS.CreateObject(Class_Supplier);
                mSupplierBO.load(mSupList.strings[j],nil);
                mSupplierBO.delete;
              end;
            end;
           ProgressSetPos(i+1);
          end;
          ProgressDispose();
          NxShowSimpleMessage('Hotovo',mSite);
      end;
    end;
  end;
  if index=0 then begin
  mOpenDlg := TOpenDialog.Create(Sender);
  try
    if mOpenDlg.Execute then begin
      try
        mList := TStringList.Create;
        mErrorList := TStringList.Create;
        mList.LoadFromFile(mOpenDlg.FileName);
        mParams := ParseData(mlist);
        j:=TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Count;
        try
           ProgressInit(mSite, 'Import dodavatelů...', j);
           for i := 1 to j - 1 do begin
           mParRow := TNxParameters(TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Params(i));
            {['name','name2','sku','price','price2','description','description2','short_description','short_description2','ean','ean2']}
           try
            mStoreCard_id:=GetSToreCard_ID(mOS,NxSearchReplace(mParRow.ParamByName('Code').AsString,'"','',[srAll]));
            if not(NxIsEmptyOID(mStoreCard_ID)) then begin
              if NxIBStrToFloat(NxSearchReplace(mParRow.ParamByName('weight').AsString,'"','',[srAll]))>0 then begin
                //NxShowSimpleMessage('Mám Váhu',mSite);
                mSCBO:=mOS.CreateObject(Class_StoreCard);
                mSCBO.Load(mStoreCard_ID,nil);
                mUnits:=mSCBO.GetLoadedCollectionMonikerForFieldCode(mSCBO.GetFieldCode('StoreUnits'));
                 for j:=0 to mUnits.count-1 do begin
                   mUnit:=mUnits.BusinessObject[j];
                   if mUnit.GetFieldValueAsString('Code')=NxSearchReplace(mParRow.ParamByName('qunit').AsString,'"','',[srAll]) then begin
                      mUnit.SetFieldValueAsFloat('Weight',NxIBStrToFloat(NxSearchReplace(mParRow.ParamByName('weight').AsString,'"','',[srAll])));

                   end;
                 end;
                mscbo.save;
                mscbo.free;
              end;
            end;
            mFirm_ID:=GetFirm_ID(mOS,NxSearchReplace(mParRow.ParamByName('IC').AsString,'"','',[srAll]));
            mSupplier_ID:=GetSupplier_ID(mOS,mFirm_ID,mStoreCard_ID);
            if NxIsEmptyOID(mSupplier_ID) then begin
             mSMBO:=mos.CreateObject(Class_Supplier);
             mSMBO.New;
             mSMBO.prefill;
             {['Code','ic','name','number','qunit','bal','weight'];}
             mSMBO.SetFieldValueAsString('StoreCard_id',mStoreCard_ID);
             msmbo.SetFieldValueAsString('Firm_ID',mFirm_ID);
             msmbo.SetFieldValueAsString('Qunit',NxSearchReplace(mParRow.ParamByName('qunit').AsString,'"','',[srAll]));
             msmbo.SetFieldValueAsString('ExternalNumber',NxSearchReplace(mParRow.ParamByName('Number').AsString,'"','',[srAll]));
             msmbo.SetFieldValueAsString('Name',NxSearchReplace(mParRow.ParamByName('name').AsString,'"','',[srAll]));

             msmbo.save;
             mSMBO.Free;


            end else begin
             mSMBO:=mos.CreateObject(Class_Supplier);
             mSMBO.Load(mSupplier_ID,nil);
             msmbo.SetFieldValueAsString('ExternalNumber',NxSearchReplace(mParRow.ParamByName('Number').AsString,'"','',[srAll]));
             msmbo.SetFieldValueAsString('Name',NxSearchReplace(mParRow.ParamByName('name').AsString,'"','',[srAll]));
             msmbo.save;
             mSMBO.Free;
            end;
           except
             mErrorList.Add('Karta :'+NxSearchReplace(mParRow.ParamByName('Code').AsString,'"','',[srAll])+'; pozice: '+IntToStr(i)+';'+ExceptionMessage);
           end;
          ProgressSetPos(i+1);
          end;
          ProgressDispose();
        finally


        end;
      finally
      end;
    end;
  finally
  end;
      if mErrorList.count>0 then begin
             NxShowSimpleMessage('Byly nalezeny chyby, uložíme do TXT', mSite);
             mSaveDlg := TFileSaveDialog.Create(mSite);
             mSaveDlg.Filter := 'TXT soubory (*.txt)|*.csv|Všechny soubory (*.*)|*.*';
             mSaveDlg.DefaultExtension := 'txt';
             mSaveDlg.FileName := 'data.txt';
             mSaveDlg.DefaultFolder:=GetEnvironmentVariable('USERPROFILE') + '\Documents';
             if mSaveDlg.Execute then begin
              mErrorList.SaveToFile(mSaveDlg.FileName);
              ShellAPI.Execute('open','explorer.exe','/select,"' + mSaveDlg.FileName + '"',ExtractFileDir(mSaveDlg.FileName));
             end;
      end;
  end;
end;

procedure Velux(sender:Tcomponent; index:integer);
var
 mSite:TsiteForm;
 mOS:TNxCustomObjectSpace;
 mSMBO, mFirmBO, mbankBO, mSupplierBO, mSCBO:TNxCustomBusinessObject;
 mUnits:TNxCustomBusinessMonikerCollection;
 mUnit:TNxCustomBusinessObject;
 mList, mErrorList:TStringList;
 mopenDLG:TOpenDialog;
 mParams, mParRow : TNxParameters;
 i, j, k:integer;
 mStoreCard_ID, mCode, mID, mTempStr:String;
 mNew:Boolean;
 mGRows : TMultiGrid;
 {'code','name','date','price','quantity','odpis','stredisko','SN'}
begin
 mSite:=TComponent(sender).BusRollSite;
 mOS:=msite.BaseObjectSpace;
  if index=0 then begin
  mOpenDlg := TOpenDialog.Create(Sender);
  try
    if mOpenDlg.Execute then begin
      try
        mList := TStringList.Create;
        mErrorList := TStringList.Create;
        mList.LoadFromFile(mOpenDlg.FileName);
        j:=mList.Count;
        try
           ProgressInit(mSite, 'Import Velux...', j);
           for i := 1 to j - 1 do begin
            mTempStr:=mlist.Strings[i];
            mCode:=NxTrapStr(mTempStr,';');
            mID:=NxTrapStr(mTempStr,';');
            if mID in ['#000002L03', '#000002L04', '#000002L05', '#000002L06', '#000002L07', '#000002L08'] then begin
              mStoreCard_id:=GetSToreCard2_ID(mOS,mCode);
              if not(NxIsEmptyOID(mStoreCard_ID)) then begin
                  mSCBO:=mOS.CreateObject(Class_StoreCard);
                  mSCBO.Load(mStoreCard_ID,nil);
                  mSCBO.SetFieldValueAsString('X_VeluxPriceCategory_ID',mID);
                  mscbo.save;
                  mscbo.free;

              end;
            end;
          ProgressSetPos(i+1);
          end;
          ProgressDispose();
        finally


        end;
      finally
      end;
    end;
  finally
  end;
  end;

end;


begin
end.