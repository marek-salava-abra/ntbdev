uses 'eu.abra.skm.importPL.parsePCS', 'eu.abra.skm.importPL.fce', 'eu.abra.skm.importPL.parseVARI',
     'eu.abra.skm.importPL.progress';


procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Import Vari';
  mAction.Items.Add('Nový import');
  mAction.Items.Add('Revize');
  mAction.Hint := 'Provede import z Varicadu';
  mAction.Category := 'tabList';
  mAction.OnExecuteItem := @ImportVari;
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Import PCS';
  mAction.Items.Add('Nový import');
  mAction.Items.Add('Revize');
  mAction.Hint := 'Provede import z PCSchematic';
  mAction.Category := 'tabList';
  mAction.OnExecuteItem := @ImportPCS;
  //mAction.OnUpdate := @ImportTXT_OnUpdate;
end;


procedure ImportPCS(sender:Tcomponent; index:integer);
var
 mSite:TsiteForm;
 mOS:TNxCustomObjectSpace;
 mPieceListBO, mSCBO, mSupplierBO:TNxCustomBusinessObject;
 mPLRows:TNxCustomBusinessMonikerCollection;
 mPLRow:TNxCustomBusinessObject;
 mList:TStringList;
 mopenDLG:TOpenDialog;
 mParams, mParRow : TNxParameters;
 i, j, k:integer;
 mStoreCard_id, mProductCard_ID, mPiecelist_ID, mCode, mFileName, mRest, mSupplier_ID:String;
begin
 mSite:=TComponent(sender).DynSite;
 mOS:=msite.BaseObjectSpace;
 if index=0 then begin
  mOpenDlg := TOpenDialog.Create(Sender);
  try
    if mOpenDlg.Execute then begin
      try
        mList := TStringList.Create;
        mList.LoadFromFile(mOpenDlg.FileName);
        mFileName:=mopenDLG.FileName;
        mRest:=NxTokenR(mFileName,'\');
        mcode:=NxToken(mRest,'.');
        mProductCard_ID:=GetStoreCard_ID(mOS,mCode);
        if not(NxIsEmptyOID(mProductCard_ID)) then mPiecelist_ID:=GetPiecelist_ID(mos, mProductCard_ID);
        if not(NxIsEmptyOID(mPiecelist_ID)) then begin
          NxShowSimpleMessage('Tato karta' +mcode+' již má kusovník. Proveďte jeho aktualizaci.', mSite);
          exit;

        end;
        if NxIsEmptyOID(mProductCard_ID) then begin
             mSCBO:=mos.CreateObject(Class_StoreCard);
             mscbo.New;
             mscbo.Prefill;
             mscbo.SetFieldValueAsString('Name','výrobek');
             mscbo.SetFieldValueAsString('Code',mCode);
             mscbo.SetFieldValueAsString('VatRate_ID','02100X0000');
             mSCBO.SetFieldValueAsString('StoreCardCategory_ID','4000000101');
             mscbo.SetFieldValueAsBoolean('IsProduct',True);

             mscbo.save;
             mProductCard_ID:=mSCBO.OID;
             mscbo.free;
        end;
        mPieceListBO:=mOS.CreateObject(Class_PLMPieceList);
        mPieceListBO.New;
        mpiecelistbo.Prefill;
        mpiecelistbo.SetFieldValueAsString('StoreCard_ID', mProductCard_ID);
        mPLRows:=mPieceListBO.GetCollectionMonikerForFieldCode(mPieceListBO.GetFieldCode('Rows'));
        mParams := ParseData(mlist);
        j:=TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Count;
        ProgressInit(mSite, 'Import kusovníku...', j);
        try
           for i := 6 to j - 1 do begin

           mParRow := TNxParameters(TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Params(i));
           mStoreCard_id:='';
           mStoreCard_id:=GetStoreCard_ID(mOS,NxTrim(mParRow.ParamByName('kod').AsString,'"'));
           if NxIsEmptyOID(mStoreCard_id) then begin
             mSCBO:=mos.CreateObject(Class_StoreCard);
             mscbo.New;
             mscbo.Prefill;
             mscbo.SetFieldValueAsString('Name',NxTrim(mParRow.ParamByName('nazev').AsString,'"'));
             mscbo.SetFieldValueAsString('Code',NxTrim(mParRow.ParamByName('kod').AsString,'"'));
             mscbo.SetFieldValueAsString('VatRate_ID','02100X0000');
             mSCBO.SetFieldValueAsString('StoreCardCategory_ID','2000000101');
             mSCBO.SetFieldValueAsString('Producer_ID',GetFirm_ID(mos,NxTrim(mParRow.ParamByName('vyrobce').AsString,'"')));
             mscbo.save;
             mStoreCard_id:=mSCBO.OID;

             mSupplier_ID:=GetFirm_ID(mos,NxTrim(mParRow.ParamByName('dodavatel').AsString,'"'));
             if not(NxIsEmptyOID(mSupplier_ID)) then begin
                mSupplierBO:=mos.CreateObject(Class_Supplier);
                mSupplierBO.new;
                mSupplierBO.Prefill;
                mSupplierBO.SetFieldValueAsString('StoreCard_ID', mStoreCard_id);
                mSupplierBO.SetFieldValueAsString('Firm_ID',mSupplier_ID);
                mSupplierbo.SetFieldValueAsString('Qunit', mSCBO.GetFieldValueAsString('MainUnitCode'));
                mSupplierBO.SetFieldValueAsString('ExternalNumber',NxTrim(mParRow.ParamByName('objcislo').AsString,'"'));
                mSupplierBO.save;
                mSupplierBO.free;
             end;
             mSCBO.free;
           end;
           mPLRow:=mPLRows.AddNewObject;
           mPLRow.Prefill;
           mPLRow.SetFieldValueAsString('StoreCard_ID', mStoreCard_id);
           mPLRow.SetFieldValueAsFloat('Quantity',mParRow.ParamByName('mnozstvi').AsFloat);
           mPLRow.SetFieldValueAsString('SupposedStore_ID','1000000101');
           mPLRow.SetFieldValueAsString('Note',NxTrim(mParRow.ParamByName('pozice').AsString,'"'));
           ProgressSetPos(i+1);
          end;
          ProgressDispose();
         finally

         end;
      mPieceListBO.save;
      TDynSiteForm(mSite).RefreshData;
      TDynSiteForm(mSite).ActiveDataSet.SeekID(mPieceListBO.OID);
      NxShowSimpleMessage('Hotovo', msite);
      finally

      end;
    end;
  finally
  end;
 end;
 if index=1 then begin

 end;
end;

procedure ImportVari(sender:Tcomponent; index:integer);
var
 mSite:TsiteForm;
 mOS:TNxCustomObjectSpace;
 mPieceListBO, mSCBO, mSupplierBO:TNxCustomBusinessObject;
 mPLRows:TNxCustomBusinessMonikerCollection;
 mPLRow:TNxCustomBusinessObject;
 mList:TStringList;
 mopenDLG:TOpenDialog;
 mParams, mParRow : TNxParameters;
 i, j, k:integer;
 mStoreCard_id, mProductCard_ID, mPiecelist_ID, mCode, mFileName, mRest, mSupplier_ID:String;
begin
 mSite:=TComponent(sender).DynSite;
 mOS:=msite.BaseObjectSpace;
 if index=0 then begin
  mOpenDlg := TOpenDialog.Create(Sender);
  try
    if mOpenDlg.Execute then begin
      try
        mList := TStringList.Create;
        mList.LoadFromFile(mOpenDlg.FileName);
        mParams := ParseDataVari(mlist);
        mFileName:=mopenDLG.FileName;
        mRest:=NxTokenR(mFileName,'\');
        mcode:=NxToken(mRest,'.');
        mProductCard_ID:=GetStoreCard_ID(mOS,mCode);
        if not(NxIsEmptyOID(mProductCard_ID)) then mPiecelist_ID:=GetPiecelist_ID(mos, mProductCard_ID);
        if not(NxIsEmptyOID(mPiecelist_ID)) then begin
          NxShowSimpleMessage('Tato karta' +mcode+' již má kusovník. Proveďte jeho aktualizaci.', mSite);
          exit;

        end;
        if NxIsEmptyOID(mProductCard_ID) then begin
             mSCBO:=mos.CreateObject(Class_StoreCard);
             mscbo.New;
             mscbo.Prefill;
             mParRow := TNxParameters(TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Params(0));
             mscbo.SetFieldValueAsString('Name',NxTrim(mParRow.ParamByName('nazev').AsString,'"'));
             mscbo.SetFieldValueAsString('Code',mCode);
             mscbo.SetFieldValueAsString('VatRate_ID','02100X0000');
             mSCBO.SetFieldValueAsString('StoreCardCategory_ID','4000000101');
             mSCBO.SetFieldValueAsString('ForeignName',NxTrim(mParRow.ParamByName('cvyk').AsString,'"'));
             mscbo.SetFieldValueAsBoolean('IsProduct',True);

             mscbo.save;
             mProductCard_ID:=mSCBO.OID;
             mscbo.free;
        end;
        mPieceListBO:=mOS.CreateObject(Class_PLMPieceList);
        mPieceListBO.New;
        mpiecelistbo.Prefill;
        mpiecelistbo.SetFieldValueAsString('StoreCard_ID', mProductCard_ID);
        mPLRows:=mPieceListBO.GetCollectionMonikerForFieldCode(mPieceListBO.GetFieldCode('Rows'));
        j:=TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Count;
        ProgressInit(mSite, 'Import kusovníku...', j);
        try
           for i := 1 to j - 1 do begin

           mParRow := TNxParameters(TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Params(i));
           if  mParRow.ParamByNameCap('pozice').AsInteger>0 then begin
           mStoreCard_id:='';
           if not(NxIsBlank(NxTrim(mParRow.ParamByName('kod').AsString,'"')))then mStoreCard_id:=GetStoreCard_ID(mOS,NxTrim(mParRow.ParamByName('kod').AsString,'"'));
           if NxIsEmptyOID(mStoreCard_id) then mStoreCard_id:=GetStoreCardName_ID(mOS,NxTrim(mParRow.ParamByName('nazev').AsString,'"'));
           if NxIsEmptyOID(mStoreCard_id) then begin
             mSCBO:=mos.CreateObject(Class_StoreCard);
             mscbo.New;
             mscbo.Prefill;
             mscbo.SetFieldValueAsString('Name',NxTrim(mParRow.ParamByName('nazev').AsString,'"'));
             mscbo.SetFieldValueAsString('Code',NxTrim(mParRow.ParamByName('kod').AsString,'"'));
             mscbo.SetFieldValueAsString('VatRate_ID','02100X0000');
             mSCBO.SetFieldValueAsString('StoreCardCategory_ID','2000000101');
             mscbo.SetFieldValueAsString('Specification',NxTrim(mParRow.ParamByName('norma').AsString,'"'));
             mscbo.SetFieldValueAsString('Specification2',NxTrim(mParRow.ParamByName('material').AsString,'"'));
             mSCBO.SetFieldValueAsString('ForeignName',NxTrim(mParRow.ParamByName('cvyk').AsString,'"'));
             mSCBO.SetFieldValueAsString('Producer_ID',GetFirm_ID(mos,NxTrim(mParRow.ParamByName('vyrobce').AsString,'"')));
             if not(NxIsBlank(mSCBO.GetFieldValueAsString('ForeignName'))) then mscbo.SetFieldValueAsBoolean('IsProduct',True);
             mscbo.save;
             mStoreCard_id:=mSCBO.OID;

             mSupplier_ID:=GetFirm_ID(mos,NxTrim(mParRow.ParamByName('dodavatel').AsString,'"'));
             if not(NxIsEmptyOID(mSupplier_ID)) then begin
                mSupplierBO:=mos.CreateObject(Class_Supplier);
                mSupplierBO.new;
                mSupplierBO.Prefill;
                mSupplierBO.SetFieldValueAsString('StoreCard_ID', mStoreCard_id);
                mSupplierBO.SetFieldValueAsString('Firm_ID',mSupplier_ID);
                mSupplierbo.SetFieldValueAsString('Qunit', mSCBO.GetFieldValueAsString('MainUnitCode'));
                mSupplierBO.SetFieldValueAsString('ExternalNumber',NxTrim(mParRow.ParamByName('objcislo').AsString,'"'));
                mSupplierBO.save;
                mSupplierBO.free;
             end;
             mSCBO.free;
           end;
           mPLRow:=mPLRows.AddNewObject;
           mPLRow.Prefill;
           //NxShowSimpleMessage(mParRow.ParamByName('mnozstvi').AsString+ ' cislo'+FloatToStr(StrToFloat(mParRow.ParamByName('mnozstvi').AsString)),msite);
           mplrow.SetFieldValueAsInteger('PosIndex', mParRow.ParamByNameCap('pozice').AsInteger);
           mPLRow.SetFieldValueAsString('StoreCard_ID', mStoreCard_id);
           mPLRow.SetFieldValueAsFloat('Quantity',StrToFloat(mParRow.ParamByName('mnozstvi').AsString));
           mPLRow.SetFieldValueAsString('SupposedStore_ID','1000000101');
           mPLRow.SetFieldValueAsString('Note',NxTrim(mParRow.ParamByName('priznak').AsString,'"')+' '+NxTrim(mParRow.ParamByName('poznamka').AsString,'"'));
           end;
           ProgressSetPos(i+1);
          end;
          ProgressDispose();
         finally

         end;
      mPieceListBO.save;
      TDynSiteForm(mSite).RefreshData;
      TDynSiteForm(mSite).ActiveDataSet.SeekID(mPieceListBO.OID);
      NxShowSimpleMessage('Hotovo', msite);
      finally

      end;
    end;
  finally
  end;
 end;
 if index=1 then begin

 end;
end;

begin
end.