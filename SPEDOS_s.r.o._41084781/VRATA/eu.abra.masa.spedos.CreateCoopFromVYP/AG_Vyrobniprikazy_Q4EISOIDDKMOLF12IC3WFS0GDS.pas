uses '.fce';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction:TBasicAction;
  mMAction:TMultiAction;
begin
  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Hint := '1. volba Vygeneruje kooperace na pozice v kusovníku označené K'+#13#10+
                   '2. volba vygeneruje karty na kooperace a vloží do kusovníku';
  mMAction.Caption := '##Generovat KOO##';
  mMAction.Items.Add('##Kooperace s odebráním materiálu##');
  mMAction.Items.Add('##Kooperace na služby##');
  mMAction.Category := 'tabList';
  mMAction.OnExecuteItem := @CreateCoop;
end;

procedure CreateCoop(sender:TComponent; index:integer);
var
 mSite:TSiteForm;
 mVYPList, mRelationList:TStringList;
 i,j,k,l,z:integer;
 mVYPBO, mInputBO, mOutputBO, mStoreCardBO, mFirmBO, mOrderBO, mOrderRowBO, mUserXLink:TNxCustomBusinessObject;
 mInputs,mOutputs, mOrderRows, mNodes, mJORoutines, mRows:TNxCustomBusinessMonikerCollection;
 mOS:TNxCustomObjectSpace;
 mFinished:Boolean;
 mFirm_ID, mPhase_ID, mStore_ID, mDivision_ID, mBusOrder_ID, mBusTransaction_ID, mIntrastatComodity_ID, mCountry_ID:string;
 mStoreCard_ID, mOrder_ID, mMaster_ID, mPhaseCode, mType:string;
begin
  mSite:=TComponent(sender).DynSite;
  mVYPList:=TStringList.create;
  mVYPList.Clear;
  TDynSiteForm(mSite).List.GetSelectedId(mVYPList);
  mOS:=TDynSiteForm(mSite).BaseObjectSpace;
  if mVYPList.count>0 then begin
    try
      //kontrola ukončení VYP
       WaitWin.StartProgress('Kontrola ukončení ...', '', mVYPList.Count);
        For i:=0 to mVYPList.count-1 do begin
          mVYPBO:=mOS.CreateObject(Class_PLMJobOrder);
          mVYPBO.Load(mVYPList.strings[i],nil);
          if not(mFinished) then begin
            if mVYPBO.GetFieldValueAsDateTime('FinishedAt$DATE')>0 then mFinished:=True;
          end;
          WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(mVYPList.Count));
          WaitWin.StepIt;
        end;
       WaitWin.Stop;
       if mFinished then begin
         NxShowSimpleMessage('Označený seznam obsahuje ukončený výrobní příkaz. Ukončuji.',mSite);
         exit;
       end;
      //konec kontroly ukončení VYP
      if index=0 then begin
           GetCoopFirm(msite, mFirm_ID, mIntrastatComodity_ID);
           if not(NxIsEmptyOID(mFirm_ID)) then begin
             mFirmBO:=mOS.CreateObject(Class_Firm);
             mFirmBO.load(mFirm_ID,nil);
           end else begin
             NxShowSimpleMessage('Nebyla vybrána kooperační firma. Ukončuji.',mSite);
             exit;
           end;
          //tvorba skladových karet, záměna a objednání u firmy
          if NxMessageBox('Dotaz','Přejete si objednat kooperaci u '+mFirmBO.GetFieldValueAsString('Name')+'?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
              mRelationList:=TStringList.create;
              mOrderBO:=mOS.CreateObject(Class_IssuedOrder);
              mOrderBO.New;
              mOrderBO.Prefill;
              mOrderBO.SetFieldValueAsString('DocQueue_ID','B200000101');
              mOrderBO.SetFieldValueAsString('Firm_ID',mFirm_ID);
              mOrderRows:=mOrderBO.GetLoadedCollectionMonikerForFieldCode(mOrderBO.GetFieldCode('Rows'));
              WaitWin.StartProgress('Generuji kooperace ...', '', mVYPList.Count);
                For i:=0 to mVYPList.count-1 do begin
                  mPhase_ID:='';
                  mStore_ID:='';
                  mDivision_ID:='';
                  mBusOrder_ID:='';
                  mStoreCard_ID:='';
                  mVYPBO:=mOS.CreateObject(Class_PLMJobOrder);
                  mVYPBO.Load(mVYPList.strings[i],nil);
                  mInputs:=mVYPBO.GetLoadedCollectionMonikerForFieldCode(mVYPBO.GetFieldCode('Inputs'));
                  mOutputs:=mVYPBO.GetLoadedCollectionMonikerForFieldCode(mVYPBO.GetFieldCode('Outputs'));
                  mNodes:=mVYPBO.GetLoadedCollectionMonikerForFieldCode(mVYPBO.GetFieldCode('Nodes'));
                  mRows:=mVYPBO.GetLoadedCollectionMonikerForFieldCode(mVYPBO.GetFieldCode('Rows'));
                  for z:=0 to mRows.count-1 do begin
                     if NxIsEmptyOID(mrows.BusinessObject[z].GetFieldValueAsString('Master_ID')) then begin
                        mMaster_ID:=mrows.BusinessObject[z].oid;
                     end;
                  end;
                    for j:=0 to mInputs.Count-1 do begin
                      mInputBO:=mInputs.BusinessObject[j];
                      if mInputBO.GetFieldValueAsBoolean('Owner_ID.U_SpedosCoop') then begin
                        if NxIsEmptyOID(mPhase_ID) then mPhase_ID:=mInputBO.GetFieldValueAsString('Phase_ID');
                        if NxIsBlank(mPhaseCode) then mPhaseCode:=mInputBO.GetFieldValueAsString('Phase_ID.Code');
                        if NxIsEmptyOID(mStore_ID) then mStore_ID:=mInputBO.GetFieldValueAsString('SupposedStore_ID');
                        if NxIsEmptyOID(mDivision_ID) then mDivision_ID:=mVYPBO.GetFieldValueAsString('Division_ID');
                        if NxIsEmptyOID(mBusOrder_ID) then mBusOrder_ID:=mVYPBO.GetFieldValueAsString('BusOrder_ID');
                        if NxIsEmptyOID(mBusTransaction_ID) then mBusTransaction_ID:=mVYPBO.GetFieldValueAsString('BusTransaction_ID');
                      end;
                      //NxShowSimpleMessage('jsem na řádku '+IntToStr(mInputBO.GetFieldValueAsInteger('Owner_ID.PosIndex'))+#13#10+
                      //                    'hodnota kooperace '+BoolToStr(mInputBO.GetFieldValueAsBoolean('Owner_id.U_SpedosCoop'),true)+#13#10+
                      //                    'Etapa '+mPhase_ID+#13#10+
                      //                    'Sklad '+mStore_ID+#13#10+
                      //                    'displayname '+mInputBO.GetFieldValueAsString('RealStoreCard_ID.code'),mSite);
                    end;
                   //pokud získám etapu, tak je tam kooperace
                   if not(NxIsEmptyOID(mPhase_ID)) then begin
                       //zakládání skladové karty
                       mStoreCard_ID:=mOS.SQLSelectFirstAsString('Select id from storecards where hidden='+QuotedStr('N')+' and code='+QuotedStr(mVYPBO.GetFieldValueAsString('U_Vyrobni_cislo')+'-koop-'+mPhaseCode),'');
                       if NxIsEmptyOID(mStoreCard_ID) then begin
                         mStoreCardBO:=mOS.CreateObject(Class_StoreCard);
                         mStoreCardBO.New;
                         mStoreCardBO.prefill;
                         mStoreCardBO.SetFieldValueAsString('Code',mVYPBO.GetFieldValueAsString('U_Vyrobni_cislo')+'-koop-'+mPhaseCode);
                         mStoreCardBO.SetFieldValueAsString('Name','Kooperace etapy '+mPhaseCode+' pro výrobní číslo '+mVYPBO.GetFieldValueAsString('U_Vyrobni_cislo'));
                         mStoreCardBo.SetFieldValueAsString('StoreCardCategory_ID','2200000101');
                         mStoreCardBO.SetFieldValueAsString('VatRate_ID','02100X0000');
                         if not(NxIsEmptyOID(mIntrastatComodity_ID)) then begin
                           mStoreCardBO.SetFieldValueAsString('IntrastatCommodity_ID',mIntrastatComodity_ID);
                           mStoreCardBO.SetFieldValueAsFloat('IntrastatWeight',1);
                           mCountry_ID:=mOS.SQLSelectFirstAsString('Select id from countries where code='+QuotedStr(mOrderBO.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode')),'');
                           mStoreCardBO.SetFieldValueAsString('Country_ID',mCountry_ID);
                           if not(mCountry_ID='00000CZ000') then begin
                              mOrderBo.SetFieldValueAsInteger('TradeType',2);
                              mOrderBO.SetFieldValueAsString('Country_ID',mCountry_ID);
                              mOrderBO.SetFieldValueAsstring('IntrastatDeliveryTerm_ID','3001000000'); ;
                              mOrderBO.SetFieldValueAsstring('IntrastatTransactionType_ID','0101000000');
                              mOrderBO.SetFieldValueAsstring('IntrastatTransportationType_ID','2000000000');
                           end;
                         end;
                         mStoreCardBO.save;
                         mStoreCard_ID:=mStoreCardBO.OID;
                         mStoreCardBO.free;
                       end;
                       //konec zakládání
                       //odmazání kusovníku s příznakem
                        for j:=0 to mNodes.Count-1 do begin
                          if mNodes.BusinessObject[j].GetFieldValueAsBoolean('U_SpedosCoop') then mNodes.BusinessObject[j].MarkForDelete;
                        end;
                       //konec odmazání
                       //přidání kooperační karty do kusovníku
                         mInputBO:=mRows.AddNewObject;
                         mInputBO.Prefill;
                         mInputBO.SetFieldValueAsString('InputItem_ID.RealStoreCard_ID',mStoreCard_ID);
                         mInputBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
                         mInputBO.SetFieldValueAsString('Master_ID',mMaster_ID);
                         mInputBO.SetFieldValueAsBoolean('InputItem_ID.Replaceable',True);
                         mInputBO.SetFieldValueAsString('InputItem_ID.SupposedStore_ID',mStore_ID);
                         mInputBO.SetFieldValueAsString('InputItem_ID.Phase_ID','1100000101');
                         mInputBO.SetFieldValueAsFloat('InputItem_ID.UnitQuantity',1);
                       //konec přidání karty do kusovníku
                       //odmazání tech postupu se shodnou etapou
                        for j:=0 to mOutputs.count-1 do begin
                          mOutputBO:=mOutputs.BusinessObject[j];
                          mJORoutines:=mOutputBO.GetLoadedCollectionMonikerForFieldCode(mOutputBO.GetFieldCode('PLMJobOrdersRoutines'));
                          for k:=0 to mJORoutines.count-1 do begin
                            if mJORoutines.BusinessObject[k].GetFieldValueAsString('Phase_ID')=mPhase_ID then mJORoutines.BusinessObject[k].MarkForDelete;
                          end;
                        end;
                       //konec odmazání technologického postupu

                      if mVYPBO.NeedSave then begin
                       mVYPBO.save;
                       mRelationList.Add(mVYPBO.OID);
                       mOrderRowBO:=mOrderRows.AddNewObject;
                       mOrderRowBO.Prefill;
                       mOrderRowBO.SetFieldValueAsInteger('RowType',3);
                       mOrderRowBo.SetFieldValueAsString('Store_ID', mStore_ID);
                       mOrderRowBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
                       mOrderRowBO.SetFieldValueAsFloat('Quantity',mVYPBO.GetFieldValueAsFloat('Quantity'));
                       mOrderRowBO.SetFieldValueAsString('Division_ID',mDivision_ID);
                       mOrderRowBO.SetFieldValueAsString('BusOrder_ID',mBusOrder_ID);
                       mOrderRowBO.SetFieldValueAsString('BusTransaction_ID',mBusTransaction_ID);
                      end;
                  end;
                  WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(mVYPList.Count));
                  WaitWin.StepIt;
                end;
               WaitWin.Stop;
               //ukládání OOV a tvorba vazeb
               if mOrderRows.CountOfNotDeleted>0 then begin
                 mOrderBO.save;
                 mOrder_ID:=mOrderBO.OID;
                 for l:=0 to mRelationList.count-1 do begin
                    mUserXLink := mOS.CreateObject(Class_UserXLink);
                    try
                      mUserXLink.New;
                      mUserXLink.Prefill;
                      mUserXLink.SetFieldValueAsString('SourceCLSID', Class_IssuedOrder);
                      mUserXLink.SetFieldValueAsString('Source_ID', mOrder_ID);
                      mUserXLink.SetFieldValueAsString('DestinationCLSID', Class_PLMJobOrder);
                      mUserXLink.SetFieldValueAsString('Destination_ID', mRelationList.Strings[l]);
                      mUserXLink.SetFieldValueAsBoolean('DisplayAsSystem', True);
                      mUserXLink.Save;
                    finally
                      mUserXLink.Free;
                    end;
                 end;
                 mSite.ShowSite(Site_IssuedOrders, True, 'QueryByUserDynSQLCondition;A.ID='+QuotedStr(mOrder_ID));
               end;
          end;
       end;
      if index=1 then begin
           GetCoopData(msite, mFirm_ID, mStore_ID, mType);
           if NxIsEmptyOID(mStore_ID) then begin
             NxShowSimpleMessage('Nebyl zadán sklad. Ukončuji.',mSite);
             exit;
           end;
           if NxIsBlank(mType) then begin
             NxShowSimpleMessage('Nebyl zadán typ kooperace. Ukončuji.',mSite);
             exit;
           end;
           if not(NxIsEmptyOID(mFirm_ID)) then begin
             mFirmBO:=mOS.CreateObject(Class_Firm);
             mFirmBO.load(mFirm_ID,nil);
           end else begin
             NxShowSimpleMessage('Nebyla vybrána kooperační firma. Ukončuji.',mSite);
             exit;
           end;
          //tvorba skladových karet, záměna a objednání u firmy
          if NxMessageBox('Dotaz','Přejete si objednat kooperaci u '+mFirmBO.GetFieldValueAsString('Name')+'?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
              mRelationList:=TStringList.create;
              mOrderBO:=mOS.CreateObject(Class_IssuedOrder);
              mOrderBO.New;
              mOrderBO.Prefill;
              mOrderBO.SetFieldValueAsString('DocQueue_ID','B200000101');
              mOrderBO.SetFieldValueAsString('Firm_ID',mFirm_ID);
              mOrderRows:=mOrderBO.GetLoadedCollectionMonikerForFieldCode(mOrderBO.GetFieldCode('Rows'));
              WaitWin.StartProgress('Generuji kooperace ...', '', mVYPList.Count);
                For i:=0 to mVYPList.count-1 do begin
                  mDivision_ID:='';
                  mBusOrder_ID:='';
                  mStoreCard_ID:='';
                  mVYPBO:=mOS.CreateObject(Class_PLMJobOrder);
                  mVYPBO.Load(mVYPList.strings[i],nil);
                  mInputs:=mVYPBO.GetLoadedCollectionMonikerForFieldCode(mVYPBO.GetFieldCode('Inputs'));
                  mOutputs:=mVYPBO.GetLoadedCollectionMonikerForFieldCode(mVYPBO.GetFieldCode('Outputs'));
                  mNodes:=mVYPBO.GetLoadedCollectionMonikerForFieldCode(mVYPBO.GetFieldCode('Nodes'));
                  mRows:=mVYPBO.GetLoadedCollectionMonikerForFieldCode(mVYPBO.GetFieldCode('Rows'));
                  if NxIsEmptyOID(mDivision_ID) then mDivision_ID:=mVYPBO.GetFieldValueAsString('Division_ID');
                  if NxIsEmptyOID(mBusOrder_ID) then mBusOrder_ID:=mVYPBO.GetFieldValueAsString('BusOrder_ID');
                  if NxIsEmptyOID(mBusTransaction_ID) then mBusTransaction_ID:=mVYPBO.GetFieldValueAsString('BusTransaction_ID');
                  for z:=0 to mRows.count-1 do begin
                     if NxIsEmptyOID(mrows.BusinessObject[z].GetFieldValueAsString('Master_ID')) then begin
                        mMaster_ID:=mrows.BusinessObject[z].oid;
                     end;
                  end;
                  //zakládání skladové karty
                   mStoreCard_ID:=mOS.SQLSelectFirstAsString('Select id from storecards where hidden='+QuotedStr('N')+' and code='+QuotedStr(mVYPBO.GetFieldValueAsString('U_Vyrobni_cislo')+'-koop-'+mType),'');
                   if NxIsEmptyOID(mStoreCard_ID) then begin
                     mStoreCardBO:=mOS.CreateObject(Class_StoreCard);
                     mStoreCardBO.New;
                     mStoreCardBO.prefill;
                     mStoreCardBO.SetFieldValueAsString('Code',mVYPBO.GetFieldValueAsString('U_Vyrobni_cislo')+'-koop-'+mType);
                     mStoreCardBO.SetFieldValueAsString('Name','Kooperace '+mType+' pro výrobní číslo '+mVYPBO.GetFieldValueAsString('U_Vyrobni_cislo'));
                     mStoreCardBo.SetFieldValueAsString('StoreCardCategory_ID','3200000101');
                     mStoreCardBO.SetFieldValueAsString('VatRate_ID','02100X0000');
                     mStoreCardBO.save;
                     mStoreCard_ID:=mStoreCardBO.OID;
                     mStoreCardBO.free;
                   end;
                   //konec zakládání
                   //přidání kooperační karty do kusovníku
                   mInputBO:=mRows.AddNewObject;
                   mInputBO.Prefill;
                   mInputBO.SetFieldValueAsString('InputItem_ID.RealStoreCard_ID',mStoreCard_ID);
                   mInputBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
                   mInputBO.SetFieldValueAsString('Master_ID',mMaster_ID);
                   mInputBO.SetFieldValueAsBoolean('InputItem_ID.Replaceable',True);
                   mInputBO.SetFieldValueAsString('InputItem_ID.SupposedStore_ID',mStore_ID);
                   mInputBO.SetFieldValueAsString('InputItem_ID.Phase_ID','1100000101');
                   mInputBO.SetFieldValueAsFloat('InputItem_ID.UnitQuantity',1);
                 //konec přidání karty do kusovníku
                 if mVYPBO.NeedSave then begin
                   mVYPBO.save;
                   mRelationList.Add(mVYPBO.OID);
                   mOrderRowBO:=mOrderRows.AddNewObject;
                   mOrderRowBO.Prefill;
                   mOrderRowBO.SetFieldValueAsInteger('RowType',3);
                   mOrderRowBo.SetFieldValueAsString('Store_ID', mStore_ID);
                   mOrderRowBO.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
                   mOrderRowBO.SetFieldValueAsFloat('Quantity',mVYPBO.GetFieldValueAsFloat('Quantity'));
                   mOrderRowBO.SetFieldValueAsString('Division_ID',mDivision_ID);
                   mOrderRowBO.SetFieldValueAsString('BusOrder_ID',mBusOrder_ID);
                   mOrderRowBO.SetFieldValueAsString('BusTransaction_ID',mBusTransaction_ID);
                  end;
                  WaitWin.ChangeText(IntToStr(i+1) + ' / ' + IntToStr(mVYPList.Count));
                  WaitWin.StepIt;
                end;
               WaitWin.Stop;
               //ukládání OOV a tvorba vazeb
               if mOrderRows.CountOfNotDeleted>0 then begin
                 mOrderBO.save;
                 mOrder_ID:=mOrderBO.OID;
                 for l:=0 to mRelationList.count-1 do begin
                    mUserXLink := mOS.CreateObject(Class_UserXLink);
                    try
                      mUserXLink.New;
                      mUserXLink.Prefill;
                      mUserXLink.SetFieldValueAsString('SourceCLSID', Class_IssuedOrder);
                      mUserXLink.SetFieldValueAsString('Source_ID', mOrder_ID);
                      mUserXLink.SetFieldValueAsString('DestinationCLSID', Class_PLMJobOrder);
                      mUserXLink.SetFieldValueAsString('Destination_ID', mRelationList.Strings[l]);
                      mUserXLink.SetFieldValueAsBoolean('DisplayAsSystem', True);
                      mUserXLink.Save;
                    finally
                      mUserXLink.Free;
                    end;
                 end;
                 mSite.ShowSite(Site_IssuedOrders, True, 'QueryByUserDynSQLCondition;A.ID='+QuotedStr(mOrder_ID));
               end;
          end;
      end;
    except
      WaitWin.Stop;
      NxShowSimpleMessage('Něco se nepovedlo:'+#13#10+ExceptionMessage,mSite);
    end;
  end;
end;

procedure _InitSelf_PostHook(Self: TSiteForm);
var
  mMG: TMultiGrid;
  mFieldDef: TFieldDef;
  i, mLayout, mLine, mOrder: Integer;
  mMGCol: TNxMultiGridColumn;
  mMGCol2: TNxMultiGridBooleanColumn;
  mMGColRoll: TNxMultiGridObjectRollColumn;
  b: Boolean;

  procedure iPreparePosition(ALayout, ALine, ARequestPosition: Integer);
  var
    ii: Integer;
  begin
    for ii:=mMG.ColumnCount-1 downto 0 do
      if (mMG.Columns[ii].Layout = ALayout) and (mMG.Columns[ii].Line = ALine) and
        (mMG.Columns[ii].Order >= ARequestPosition) then
        mMG.Columns[ii].Order := mMG.Columns[ii].Order + 1;
  end;

begin
  mMG := TMultiGrid(NxFindChildControl(Self.GetSiteAppForm, 'grdJORows'));
  if Assigned(mMG) then begin
    b := True;
    for i:=mMG.ColumnCount-1 downto 0 do
      if mMG.Columns[i].FieldName = 'U_SpedosCoop' then
        b := False;
    if b then begin
      mFieldDef := TFieldDef.Create(mMG.DataSource.DataSet.FieldDefs, 'U_SpedosCoop', ftBoolean, 0, False, 320);
      with mFieldDef.CreateField(mMG.DataSource.DataSet, nil, 'U_SpedosCoop', False) do begin
        ReadOnly:= False;
        FieldName:= 'U_SpedosCoop';
        FieldKind:= fkData;
      end;
      iPreparePosition(0, 1, 17);
      mMGCol2 := TNxMultiGridBooleanColumn.Create(mMG.Owner);
      mMGCol2.FieldName := 'U_SpedosCoop';
      mMGCol2.Caption := 'Sped. koop';
      mMGCol2.ReadOnly := False;
      mMGCol2.Kind := ckCombo;
      mMGCol2.Elastic := True;
      mMGCol2.Width := 60;
      mMGCol2.Layout := 0;
      mMGCol2.Line := 1;
      mMGCol2.Order := 17;
      mMG.AddColumn(mMGCol2);
     end;
  end;
end;


begin
end.