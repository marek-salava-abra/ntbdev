uses 'eu.import.eshop.ParseData';

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Import XLS';
  mAction.Items.Add('Nový import fréza');
  mAction.Items.Add('Nový import pouzdra');
  mAction.Items.Add('Nový import vrtáky');
  mAction.Items.Add('Nový import závitníky');
  mAction.Items.Add('Nový import din');
  mAction.Items.Add('Nový import sklíčidla');
  mAction.Items.Add('Nový import čelisti');
  //mAction.Items.Add('Revize');
  mAction.Hint := 'Provede import CSV';
  mAction.Category := 'tabList';
  mAction.OnExecuteItem := @ImportData;

end;

procedure ImportData(sender:Tcomponent; index:integer);
var
 mSite:TsiteForm;
 mOS:TNxCustomObjectSpace;
 mSCBO:TNxCustomBusinessObject;
 mPLRows:TNxCustomBusinessMonikerCollection;
 mPLRow:TNxCustomBusinessObject;
 mList:TStringList;
 mopenDLG:TOpenDialog;
 mParams, mParRow : TNxParameters;
 i, j, k:integer;
 mlevel1, mlevel2, mlevel3, mLevel4, mLevel5, mParent_ID, mID:String;
 mNew:Boolean;
 mGRows : TMultiGrid;
begin
 mSite:=TComponent(sender).BusRollSite;
 mOS:=msite.BaseObjectSpace;
  if index=6 then begin
  mOpenDlg := TOpenDialog.Create(Sender);
  try
    if mOpenDlg.Execute then begin
      try
        mList := TStringList.Create;
        mList.LoadFromFile(mOpenDlg.FileName);
        mParams := ParseDataCelisti(mlist);
        j:=TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Count;
        try
           for i := 1 to j - 1 do begin
           mParRow := TNxParameters(TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Params(i));
           mID:=GetStoreCardEAN_ID(MOS,mParRow.ParamByName('ean').AsString);
           {''code','name','quantity','ean','prumer','Up_R_E','F','Up_R_G',' Up_R_H',' Up_R_L','Up_R_J',
             ' Up_R_K','N',' Up_R_O',' Up_R_P',' Up_R_R',' Up_R_S',' Up_R_T','typ_up',
              'trid_pres','Poc_cel.','E_H7','F_0,2','G','H','J','K','L','N','O','R','S','T','U','CSN''}

            if not(NxIsEmptyOID(mID)) then begin
              mSCBO:=mos.CreateObject(class_storecard);
              mSCBO.Load(mID,nil);
              mscbo.SetFieldValueAsString('Name', mParRow.ParamByName('Name').AsString);
              mscbo.SetFieldValueAsFloat('U_AES_SC2_F_PRUMSKLICIDLA_CZ', mParRow.ParamByName('prumer').AsFloat);
              mscbo.SetFieldValueAsString('U_AES_SC2_UPROZSAHE_CZ', mParRow.ParamByName('Up_R_E').AsString);
              mscbo.SetFieldValueAsInteger('U_AES_SC2_UPROZSAHF_CZ', mParRow.ParamByName('F').AsInteger);
              mscbo.SetFieldValueAsString('U_AES_SC2_UPROZSAHG_CZ', mParRow.ParamByName('Up_R_G').AsString);
              mscbo.SetFieldValueAsString('U_AES_SC2_UPROZSAHH_CZ', mParRow.ParamByName('Up_R_H').AsString);
              mscbo.SetFieldValueAsString('U_AES_SC2_UPROZSAHL_CZ', mParRow.ParamByName('Up_R_L').AsString);
              mscbo.SetFieldValueAsString('U_AES_SC2_UPROZSAHJ_CZ', mParRow.ParamByName('Up_R_J').AsString);
              mscbo.SetFieldValueAsString('U_AES_SC2_UPROZSAHK_CZ', mParRow.ParamByName('Up_R_K').AsString);
              mscbo.SetFieldValueAsString('U_AES_SC2_UPROZSAHN_CZ', mParRow.ParamByName('R_N').AsString);
              mscbo.SetFieldValueAsString('U_AES_SC2_UPROZSAHO_CZ', mParRow.ParamByName('Up_R_O').AsString);
              mscbo.SetFieldValueAsString('U_AES_SC2_UPROZSAHP_CZ', mParRow.ParamByName('Up_R_P').AsString);
              mscbo.SetFieldValueAsString('U_AES_SC2_UPROZSAHR_CZ', mParRow.ParamByName('Up_R_R').AsString);
              mscbo.SetFieldValueAsString('U_AES_SC2_UPROZSAHS_CZ', mParRow.ParamByName('Up_R_S').AsString);
              mscbo.SetFieldValueAsString('U_AES_SC2_UPROZSAHT_CZ', mParRow.ParamByName('Up_R_T').AsString);
              mscbo.SetFieldValueAsString('U_AES_SC2_TYPUPINANI_CZ', mParRow.ParamByName('typ_up').AsString);
              mscbo.SetFieldValueAsString('U_AES_SC2_TRPRESNOSTI_CZ', mParRow.ParamByName('trid_pres').AsString);
              mscbo.SetFieldValueAsInteger('U_AES_SC2_F_POCCELISTI_CZ', mParRow.ParamByName('Poc_cel').AsInteger);
              mscbo.SetFieldValueAsInteger('U_AES_SC2_EH7_CZ', mParRow.ParamByName('E_H7').AsInteger);
              mscbo.SetFieldValueAsInteger('U_AES_SC2_F02_CZ', mParRow.ParamByName('F_02').AsInteger);
              mscbo.SetFieldValueAsString('U_AES_SC2_GMM_CZ', mParRow.ParamByName('G').AsString);
              mscbo.SetFieldValueAsFloat('U_AES_SC2_HMM_CZ', mParRow.ParamByName('H').AsFloat);
              mscbo.SetFieldValueAsFloat('U_AES_SC2_JMM_CZ', mParRow.ParamByName('J').AsFloat);
              mscbo.SetFieldValueAsFloat('U_AES_SC2_KMM_CZ', mParRow.ParamByName('K').AsFloat);
              mscbo.SetFieldValueAsFloat('U_AES_SC2_LMM_CZ', mParRow.ParamByName('L').AsFloat);
              mscbo.SetFieldValueAsFloat('U_AES_SC2_NMM_CZ', mParRow.ParamByName('N').AsFloat);
              mscbo.SetFieldValueAsFloat('U_AES_SC2_OMM_CZ', mParRow.ParamByName('O').AsFloat);
              mscbo.SetFieldValueAsFloat('U_AES_SC2_RMM_CZ', mParRow.ParamByName('R').AsFloat);
              mscbo.SetFieldValueAsFloat('U_AES_SC2_SMM_CZ', mParRow.ParamByName('S').AsFloat);
              mscbo.SetFieldValueAsFloat('U_AES_SC2_TMM_CZ', mParRow.ParamByName('T').AsFloat);
              mscbo.SetFieldValueAsFloat('U_AES_SC2_UMM_CZ', mParRow.ParamByName('U').AsFloat);
              mscbo.SetFieldValueAsFloat('U_AES_SC2_EMM_CZ', mParRow.ParamByName('E').AsFloat);
              mscbo.SetFieldValueAsFloat('U_AES_SC2_MMM_CZ', mParRow.ParamByName('M').AsFloat);
              mscbo.SetFieldValueAsString('U_AES_SC2_F_NORMA_CZ', mParRow.ParamByName('CSN').AsString);
              mSCBO.save;
              mscbo.Free;
            end;
           end;
        finally
        end;
      finally
      end;
    end;
  finally
  end;
  end;
 if index=5 then begin
  mOpenDlg := TOpenDialog.Create(Sender);
  try
    if mOpenDlg.Execute then begin
      try
        mList := TStringList.Create;
        mList.LoadFromFile(mOpenDlg.FileName);
        mParams := ParseDatasklicidla(mlist);
        j:=TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Count;
        try
           for i := 1 to j - 1 do begin
           mParRow := TNxParameters(TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Params(i));
           mID:=GetStoreCard_ID(MOS,mParRow.ParamByName('Code').AsString);
           {''code','name','quantity','ean','prumer','Up_R_E','F','Up_R_G',' Up_R_H',' Up_R_L','Up_R_J',
             ' Up_R_K','N',' Up_R_O',' Up_R_P',' Up_R_R',' Up_R_S',' Up_R_T','typ_up',
              'trid_pres','Poc_cel.','E_H7','F_0,2','G','H','J','K','L','N','O','R','S','T','U','CSN''}

            if not(NxIsEmptyOID(mID)) then begin
              mSCBO:=mos.CreateObject(class_storecard);
              mSCBO.Load(mID,nil);
              mscbo.SetFieldValueAsString('Name', mParRow.ParamByName('Name').AsString);
              mscbo.SetFieldValueAsFloat('U_AES_SC2_F_PRUMSKLICIDLA_CZ', mParRow.ParamByName('prumer').AsFloat);
              mscbo.SetFieldValueAsString('U_AES_SC2_UPROZSAHE_CZ', mParRow.ParamByName('Up_R_E').AsString);
              mscbo.SetFieldValueAsInteger('U_AES_SC2_UPROZSAHF_CZ', mParRow.ParamByName('F').AsInteger);
              mscbo.SetFieldValueAsString('U_AES_SC2_UPROZSAHG_CZ', mParRow.ParamByName('Up_R_G').AsString);
              mscbo.SetFieldValueAsString('U_AES_SC2_UPROZSAHH_CZ', mParRow.ParamByName('Up_R_H').AsString);
              mscbo.SetFieldValueAsString('U_AES_SC2_UPROZSAHL_CZ', mParRow.ParamByName('Up_R_L').AsString);
              mscbo.SetFieldValueAsString('U_AES_SC2_UPROZSAHJ_CZ', mParRow.ParamByName('Up_R_J').AsString);
              mscbo.SetFieldValueAsString('U_AES_SC2_UPROZSAHK_CZ', mParRow.ParamByName('Up_R_K').AsString);
              mscbo.SetFieldValueAsString('U_AES_SC2_UPROZSAHN_CZ', mParRow.ParamByName('R_N').AsString);
              mscbo.SetFieldValueAsString('U_AES_SC2_UPROZSAHO_CZ', mParRow.ParamByName('Up_R_O').AsString);
              mscbo.SetFieldValueAsString('U_AES_SC2_UPROZSAHP_CZ', mParRow.ParamByName('Up_R_P').AsString);
              mscbo.SetFieldValueAsString('U_AES_SC2_UPROZSAHR_CZ', mParRow.ParamByName('Up_R_R').AsString);
              mscbo.SetFieldValueAsString('U_AES_SC2_UPROZSAHS_CZ', mParRow.ParamByName('Up_R_S').AsString);
              mscbo.SetFieldValueAsString('U_AES_SC2_UPROZSAHT_CZ', mParRow.ParamByName('Up_R_T').AsString);
              mscbo.SetFieldValueAsString('U_AES_SC2_TYPUPINANI_CZ', mParRow.ParamByName('typ_up').AsString);
              mscbo.SetFieldValueAsString('U_AES_SC2_TRPRESNOSTI_CZ', mParRow.ParamByName('trid_pres').AsString);
              mscbo.SetFieldValueAsInteger('U_AES_SC2_F_POCCELISTI_CZ', mParRow.ParamByName('Poc_cel').AsInteger);
              mscbo.SetFieldValueAsInteger('U_AES_SC2_EH7_CZ', mParRow.ParamByName('E_H7').AsInteger);
              mscbo.SetFieldValueAsInteger('U_AES_SC2_F02_CZ', mParRow.ParamByName('F_02').AsInteger);
              mscbo.SetFieldValueAsString('U_AES_SC2_GMM_CZ', mParRow.ParamByName('G').AsString);
              mscbo.SetFieldValueAsFloat('U_AES_SC2_HMM_CZ', mParRow.ParamByName('H').AsFloat);
              mscbo.SetFieldValueAsFloat('U_AES_SC2_JMM_CZ', mParRow.ParamByName('J').AsFloat);
              mscbo.SetFieldValueAsFloat('U_AES_SC2_KMM_CZ', mParRow.ParamByName('K').AsFloat);
              mscbo.SetFieldValueAsFloat('U_AES_SC2_LMM_CZ', mParRow.ParamByName('L').AsFloat);
              mscbo.SetFieldValueAsFloat('U_AES_SC2_NMM_CZ', mParRow.ParamByName('N').AsFloat);
              mscbo.SetFieldValueAsFloat('U_AES_SC2_OMM_CZ', mParRow.ParamByName('O').AsFloat);
              mscbo.SetFieldValueAsFloat('U_AES_SC2_RMM_CZ', mParRow.ParamByName('R').AsFloat);
              mscbo.SetFieldValueAsFloat('U_AES_SC2_SMM_CZ', mParRow.ParamByName('S').AsFloat);
              mscbo.SetFieldValueAsFloat('U_AES_SC2_TMM_CZ', mParRow.ParamByName('T').AsFloat);
              mscbo.SetFieldValueAsFloat('U_AES_SC2_UMM_CZ', mParRow.ParamByName('U').AsFloat);
              mscbo.SetFieldValueAsString('U_AES_SC2_F_NORMA_CZ', mParRow.ParamByName('CSN').AsString);
              mSCBO.save;
              mscbo.Free;
            end;
           end;
        finally
        end;
      finally
      end;
    end;
  finally
  end;
  end;
 if index=3 then begin
  mOpenDlg := TOpenDialog.Create(Sender);
  try
    if mOpenDlg.Execute then begin
      try
        mList := TStringList.Create;
        mList.LoadFromFile(mOpenDlg.FileName);
        mParams := ParseData4(mlist);
        j:=TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Count;
        try
           for i := 1 to j - 1 do begin
           mParRow := TNxParameters(TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Params(i));
           mID:=GetStoreCard_ID(MOS,mParRow.ParamByName('Code').AsString);
           {'code','name','quantity','qunit','ean','rez_kuzel','dsize','psize','l1size',
  'l2size','d2size','asize','zsize','material', 'DIN', 'katcislo'}

            if not(NxIsEmptyOID(mID)) then begin
              mSCBO:=mos.CreateObject(class_storecard);
              mSCBO.Load(mID,nil);
              mscbo.SetFieldValueAsString('Name', mParRow.ParamByName('Name').AsString);
              mscbo.SetFieldValueAsString('U_AES_SC2_REZKUZEL_CZ', mParRow.ParamByName('rez_kuzel').AsString);
              mscbo.SetFieldValueAsString('U_AES_SC2_F_D1_CZ', mParRow.ParamByName('dsize').AsString);
              mscbo.SetFieldValueAsfloat('U_AES_SC2_P_CZ', mParRow.ParamByName('psize').AsFloat);
              mscbo.SetFieldValueAsfloat('U_AES_SC2_ZL1_CZ', mParRow.ParamByName('l1size').AsFloat);
              mscbo.SetFieldValueAsfloat('U_AES_SC2_ZL2_CZ', mParRow.ParamByName('l2size').AsFloat);
              mscbo.SetFieldValueAsfloat('U_AES_SC2_D2_CZ', mParRow.ParamByName('d2size').AsFloat);
              mscbo.SetFieldValueAsfloat('U_AES_SC2_A_CZ', mParRow.ParamByName('asize').AsFloat);
              mscbo.SetFieldValueAsInteger('U_AES_SC2_Z_CZ', mParRow.ParamByName('zsize').AsInteger);
              mscbo.SetFieldValueAsInteger('U_AES_SC2_DIN_CZ', mParRow.ParamByName('din').AsInteger);
              mscbo.SetFieldValueAsInteger('U_AES_SC2_F_KATCISLO_CZ', mParRow.ParamByName('katcislo').AsInteger);
              mscbo.SetFieldValueAsInteger('U_AES_SC2_ZAVITL_CZ', mParRow.ParamByName('l235').AsInteger);
              mscbo.SetFieldValueAsString('U_AES_SC2_F_ZZB_CZ', mParRow.ParamByName('z').asstring);
              mSCBO.SetFieldValueAsInteger('U_AES_SC2_N_CZ', mParRow.ParamByName('n').AsInteger);
              mSCBO.save;
              mscbo.Free;
            end;
           end;
        finally
        end;
      finally
      end;
    end;
  finally
  end;
  end;
   if index=4 then begin
  mOpenDlg := TOpenDialog.Create(Sender);
  try
    if mOpenDlg.Execute then begin
      try
        mList := TStringList.Create;
        mList.LoadFromFile(mOpenDlg.FileName);
        mParams := ParseData4(mlist);
        j:=TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Count;
        try
           for i := 1 to j - 1 do begin
           mParRow := TNxParameters(TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Params(i));
           mID:=GetStoreCard_ID(MOS,mParRow.ParamByName('Code').AsString);
           {'code','name','quantity','qunit','ean','rez_kuzel','dsize','psize','l1size',
  'l2size','d2size','asize','zsize','material', 'DIN', 'katcislo'}

            if not(NxIsEmptyOID(mID)) then begin
              mSCBO:=mos.CreateObject(class_storecard);
              mSCBO.Load(mID,nil);
              mSCBO.SetFieldValueAsInteger('U_AES_SC2_DIN_CZ', mParRow.ParamByName('din').AsInteger);
              mSCBO.save;
              mscbo.Free;
            end;
           end;
        finally
        end;
      finally
      end;
    end;
  finally
  end;
  end;
  if index=0 then begin
  mOpenDlg := TOpenDialog.Create(Sender);
  try
    if mOpenDlg.Execute then begin
      try
        mList := TStringList.Create;
        mList.LoadFromFile(mOpenDlg.FileName);
        mParams := ParseData(mlist);
        j:=TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Count;
        try
           for i := 1 to j - 1 do begin
           mParRow := TNxParameters(TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Params(i));
           mID:=GetStoreCard_ID(MOS,mParRow.ParamByName('Code').AsString);
            if not(NxIsEmptyOID(mID)) then begin
              mSCBO:=mos.CreateObject(class_storecard);
              mSCBO.Load(mID,nil);
              mscbo.SetFieldValueAsString('Name', mParRow.ParamByName('Name').AsString);
              mSCBO.GetLoadedCollectionMonikerForFieldCode(mSCBO.GetFieldCode('StoreUnits')).BusinessObject[0].SetFieldValueAsFloat('Weight',mParRow.ParamByName('weight').AsFloat);
              mSCBO.GetLoadedCollectionMonikerForFieldCode(mSCBO.GetFieldCode('StoreUnits')).BusinessObject[0].SetFieldValueAsInteger('WeightUnit',1);
              mscbo.SetFieldValueAsFloat('U_AES_SC2_F_PRUMVRTAK_CZ', mParRow.ParamByName('prumer').AsFloat);
              mscbo.SetFieldValueAsInteger('U_AES_SC2_F_PRUMUPPRVEK_CZ', mParRow.ParamByName('prumer2').AsInteger);
              mscbo.SetFieldValueAsString('U_AES_SC2_F_MATERIAL_CZ', mParRow.ParamByName('material').AsString);
              mscbo.SetFieldValueAsString('U_AES_SC2_POVRCHUPRAVA_CZ', mParRow.ParamByName('povrch').AsString);
              mscbo.SetFieldValueAsString('U_AES_SC2_POUZITI_CZ', mParRow.ParamByName('pouziti').AsString);
              mscbo.SetFieldValueAsINteger('U_AES_SC2_CELDELVRTAK_CZ', mParRow.ParamByName('delkad').AsInteger);
              mscbo.SetFieldValueAsINteger('U_AES_SC2_CELDELBRITU_CZ', mParRow.ParamByName('delkab').AsInteger);
              //mscbo.SetFieldValueAsString('U_AES_SC2_TOLERANCE_CZ', mParRow.ParamByName('tolerance').AsString);
              mscbo.SetFieldValueAsInteger('U_AES_SC2_F_NORMA_CZ', mParRow.ParamByName('norma').AsInteger);
              mscbo.SetFieldValueAsInteger('U_AES_SC2_DIN_CZ', mParRow.ParamByName('din').AsInteger);
              mscbo.SetFieldValueAsInteger('U_AES_SC2_POCZUBU_CZ', mParRow.ParamByName('zuby').AsInteger);
              mscbo.SetFieldValueAsString('U_AES_SC2_F_UPNNASTROJ_CZ','0000000001');
              mSCBO.save;
              mscbo.Free;
            end;
           end;
        finally
        end;
      finally
      end;
    end;
  finally
  end;
  end;
   if index=1 then begin
  mOpenDlg := TOpenDialog.Create(Sender);
  try
    if mOpenDlg.Execute then begin
      try
        mList := TStringList.Create;
        mList.LoadFromFile(mOpenDlg.FileName);
        mParams := ParseDataPouzdra(mlist);
        j:=TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Count;
        try
           for i := 1 to j - 1 do begin
           mParRow := TNxParameters(TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Params(i));
           mID:=GetStoreCard_ID(MOS,mParRow.ParamByName('Code').AsString);
            if not(NxIsEmptyOID(mID)) then begin
              mSCBO:=mos.CreateObject(class_storecard);
              mSCBO.Load(mID,nil);
              mscbo.SetFieldValueAsString('Name', mParRow.ParamByName('Name').AsString);
              mSCBO.GetLoadedCollectionMonikerForFieldCode(mSCBO.GetFieldCode('StoreUnits')).BusinessObject[0].SetFieldValueAsFloat('Weight',mParRow.ParamByName('weight').AsFloat);
              mSCBO.GetLoadedCollectionMonikerForFieldCode(mSCBO.GetFieldCode('StoreUnits')).BusinessObject[0].SetFieldValueAsInteger('WeightUnit',1);
              mscbo.SetFieldValueAsFloat('U_AES_SC2_F_PRUMVNITR_CZ', mParRow.ParamByName('prumer2').AsFloat);
              mscbo.SetFieldValueAsFloat('U_AES_SC2_F_PRUMVENK_CZ', mParRow.ParamByName('prumer3').AsFloat);
              mscbo.SetFieldValueAsInteger('U_AES_SC2_F_PRUMUPPRVEK_CZ', mParRow.ParamByName('prumer').AsInteger);
              //mscbo.SetFieldValueAsString('U_AES_SC2_F_MATERIAL_CZ', mParRow.ParamByName('material').AsString);
              //mscbo.SetFieldValueAsString('U_AES_SC2_POVRCHUPRAVA_CZ', mParRow.ParamByName('povrch').AsString);
              mscbo.SetFieldValueAsString('U_AES_SC2_POUZITI_CZ', mParRow.ParamByName('pouziti').AsString);
              mscbo.SetFieldValueAsINteger('U_AES_SC2_CELDELVRTAK_CZ', mParRow.ParamByName('delkad').AsInteger);
              mscbo.SetFieldValueAsINteger('U_AES_SC2_CELDELBRITU_CZ', mParRow.ParamByName('delkab').AsInteger);
              //mscbo.SetFieldValueAsString('U_AES_SC2_TOLERANCE_CZ', mParRow.ParamByName('tolerance').AsString);
              mscbo.SetFieldValueAsInteger('U_AES_SC2_F_NORMA_CZ', mParRow.ParamByName('norma').AsInteger);
              mscbo.SetFieldValueAsInteger('U_AES_SC2_DIN_CZ', mParRow.ParamByName('din').AsInteger);
              mscbo.SetFieldValueAsInteger('U_AES_SC2_F_MK1MORSEKUZ_CZ', mParRow.ParamByName('morse1').AsInteger);
              mscbo.SetFieldValueAsInteger('U_AES_SC2_F_MK2MORSEKUZ_CZ', mParRow.ParamByName('morse2').AsInteger);
              //mscbo.SetFieldValueAsString('U_AES_SC2_F_UPNNASTROJ_CZ','0000000001');
              mSCBO.save;
              mscbo.Free;
            end;
           end;
        finally
        end;
      finally
      end;
    end;
  finally
  end;
  end;
  if index=2 then begin
  mOpenDlg := TOpenDialog.Create(Sender);
  try
    if mOpenDlg.Execute then begin
      try
        mList := TStringList.Create;
        mList.LoadFromFile(mOpenDlg.FileName);
        mParams := ParseDatavrtaky(mlist);
        j:=TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Count;
        try
          {'dsize','Lsize','l2size',
  'uhel','uhel2','material','povrch','morse','tvar', 'Norma', 'DIN', 'upnuti'];}
           for i := 1 to j - 1 do begin
           mParRow := TNxParameters(TNxParameters(mParams.GetOrCreateParam(dtList, 'rows', pkInput)).Params(i));
           mID:=GetStoreCard_ID(MOS,mParRow.ParamByName('Code').AsString);
            if not(NxIsEmptyOID(mID)) then begin
              mSCBO:=mos.CreateObject(class_storecard);
              mSCBO.Load(mID,nil);
              mscbo.SetFieldValueAsString('Name', mParRow.ParamByName('Name').AsString);
              mSCBO.GetLoadedCollectionMonikerForFieldCode(mSCBO.GetFieldCode('StoreUnits')).BusinessObject[0].SetFieldValueAsFloat('Weight',mParRow.ParamByName('weight').AsFloat);
              mSCBO.GetLoadedCollectionMonikerForFieldCode(mSCBO.GetFieldCode('StoreUnits')).BusinessObject[0].SetFieldValueAsInteger('WeightUnit',1);
              mscbo.SetFieldValueAsFloat('U_AES_SC2_F_PRUMVRTAK_CZ', mParRow.ParamByName('dsize').AsFloat);
              mscbo.SetFieldValueAsInteger('U_AES_SC2_F_PRUMUPPRVEK_CZ', mParRow.ParamByName('prumer2').AsInteger);
              mscbo.SetFieldValueAsString('U_AES_SC2_F_MATERIAL_CZ', mParRow.ParamByName('material').AsString);
              mscbo.SetFieldValueAsString('U_AES_SC2_POVRCHUPRAVA_CZ', mParRow.ParamByName('povrch').AsString);
              mscbo.SetFieldValueAsString('U_AES_SC2_POUZITI_CZ', mParRow.ParamByName('pouziti').AsString);
              mscbo.SetFieldValueAsINteger('U_AES_SC2_CELDELVRTAK_CZ', mParRow.ParamByName('lsize').AsInteger);
              mscbo.SetFieldValueAsINteger('U_AES_SC2_CELDELBRITU_CZ', mParRow.ParamByName('l2size').AsInteger);
              mscbo.SetFieldValueAsString('U_AES_SC2_UHELSROUBOV_CZ', mParRow.ParamByName('uhel').AsString);
              mscbo.SetFieldValueAsINteger('U_AES_SC2_UHELSPICKY_CZ', mParRow.ParamByName('uhel2').AsInteger);
              mscbo.SetFieldValueAsINteger('U_AES_SC2_F_MORSE_CZ', mParRow.ParamByName('morse').AsInteger);
              mscbo.SetFieldValueAsString('U_AES_SC2_ZPUSOSTRENI_CZ', ansileftstr(mParRow.ParamByName('tvar').AsString,50));
              mscbo.SetFieldValueAsString('U_AES_SC2_ZPUSVYROBY_CZ', mParRow.ParamByName('vyroba').AsString);
              mscbo.SetFieldValueAsInteger('U_AES_SC2_F_NORMA_CZ', mParRow.ParamByName('norma').AsInteger);
              mscbo.SetFieldValueAsInteger('U_AES_SC2_F_DIN_CZ', mParRow.ParamByName('din').AsInteger);
              mscbo.SetFieldValueAsString('U_AES_SC2_F_DINTEXT_CZ', mParRow.ParamByName('Din_text').AsString);
              mscbo.SetFieldValueAsInteger('U_AES_SC2_POCZUBU_CZ', mParRow.ParamByName('zuby').AsInteger);
              mscbo.SetFieldValueAsString('U_AES_SC2_F_UPNNASTROJ_CZ','0010000000'); //válcová stopka
              mSCBO.save;
              mscbo.Free;
            end;
           end;
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