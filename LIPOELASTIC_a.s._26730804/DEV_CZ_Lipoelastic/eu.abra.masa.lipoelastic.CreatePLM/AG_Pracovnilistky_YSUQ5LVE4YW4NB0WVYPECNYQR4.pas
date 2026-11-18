procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actCreateTariffMD';
  mAction.Caption := '## Opakovaný odpis režie ##';
  mAction.Hint := 'Vygeneruje výrobu z celé objednávky';
  mAction.Category := 'tabList';
  mAction.OnExecute := @CreateTariffMD;
end;

Procedure CreateTariffMD(sender:TComponent);
var
 mSite:TSiteForm;
 mList, mStoreSubBatchList:TStringList;
 i, j, k, x, z:integer;
 mBO, mVYPBO, mRowBO, mDRBBO:TNxCustomBusinessObject;
 mOS:TNxCustomObjectSpace;
 mJSON:TJSONSuperObject;
 mVYP_ID:String;
 mImportMan: TNxDocumentImportManager;
 mInputParams: TNxParameters;
 mParam: TNxParameter;
 mRows, mDocRowBatches:TNxCustomBusinessMonikerCollection;
 mMarkForDelete:Boolean;
 mRestQuantity, mAvailableQuantity, mSBQuantity:Extended;
begin
 mSite:=TComponent(sender).DynSite;
 mOS:=TDynSiteForm(mSite).BaseObjectSpace;
 mList:=TStringList.Create;
 TDynSiteForm(mSite).List.GetSelectedId(mList);
 if mList.Count>0 then begin
   if NxMessageBox('Potvrzení', 'Vygenerovat režijní VMV pro '+IntToStr(mlist.count)+' pracovních lístků?', mdConfirm, mdbYesNo, 1, nil, False, msite) = mrYes then begin
    WaitWin.StartProgress('Vytvářím VMV ...', '', mList.Count);
    for i:=0 to mlist.count-1 do begin
      mBO:=mOS.CreateObject(Class_PLMOperation);
      mBO.Load(mList.strings[i],nil);
      if mBO.GetFieldValueAsBoolean('X_CreateTariffMD') and not(mBO.GetFieldValueAsBoolean('X_TariffMDCreated')) then begin
       mVYP_ID:=mBO.GetFieldValueAsString('JobOrdersRoutines_ID.Parent_ID.Owner_ID.Parent_ID');
       mJSON:=TJSONSuperObject.ParseString(mbo.GetFieldValueAsString('X_TariffMDList'),True);
       if mJSON.A['materials'].Length>0 then begin
          try
              mVYPBO:=mOS.CreateObject(Class_PLMJobOrder);
              mVYPBO.Load(mVYP_ID,nil);
              mInputParams := TNxParameters.Create;
              mParam :=  mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
              mParam.AsString := 'V300000101';
              mParam :=  mInputParams.GetOrCreateParam(dtString, 'Firm_ID');
              mParam.AsString := mVYPBO.GetFieldValueAsString('Firm_ID');
              mParam :=  mInputParams.GetOrCreateParam(dtInteger, 'MethodOfMD');
              mParam.AsInteger := 0;
              mImportMan := NxCreateDocumentImportManager(mVYPBO.ObjectSpace, Class_PLMJobOrder, Class_MaterialDistribution);
              mImportMan.AddInputDocument(mVYPBO.OID);
              mImportMan.LoadParams(mInputParams);
              mImportMan.Execute;
              mRows:=mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
                for z:=0 to mRows.count-1 do begin
                  mRowBO:=mrows.BusinessObject[z];
                  mMarkForDelete:=True;
                  for x:= 0 to mJSON.A['materials'].Length -1 do begin
                    if mMarkForDelete then begin
                      if mJSON.A['materials'].O[x].S['StoreCard_ID']=mRowBO.GetFieldValueAsString('StoreCard_ID') then begin
                       if mJSON.A['materials'].O[x].D['Quantity']>0 then begin
                        mMarkForDelete:=false;
                        mRowBO.SetFieldValueAsString('Store_ID',mJSON.A['materials'].O[x].S['Store_ID']);
                        mRowBO.SetFieldValueAsFloat('Quantity',mJSON.A['materials'].O[x].D['Quantity']);
                        if mRowBO.GetFieldValueAsInteger('StoreCard_ID.Category')=2 then begin
                          mDocRowBatches:=mRowBO.GetLoadedCollectionMonikerForFieldCode(mRowBO.GetFieldCode('DocRowBatches'));
                          mRestQuantity:=mJSON.A['materials'].O[x].D['Quantity'];
                          mStoreSubBatchList:=TStringList.Create;
                          mOS.SQLSelect('select sb.id from storebatches sb '+
                                        'left join storesubbatches ssb on sb.id=ssb.storebatch_id '+
                                        'where sb.storecard_id='+QuotedStr(mJSON.A['materials'].O[x].S['StoreCard_ID'])+
                                        ' and ssb.quantity>0 and ssb.store_id='+QuotedStr(mJSON.A['materials'].O[x].S['Store_ID'])+
                                        ' order by sb.ExpirationDate$Date, sb.name ',mStoreSubBatchList);
                          if mStoreSubBatchList.count>0 then begin
                            for k:=0 to mStoreSubBatchList.count-1 do begin
                              if mRestQuantity>0 then begin
                                mSBQuantity:=mOS.SQLSelectFirstAsExtended('Select quantity from storesubbatches where storebatch_id='+
                                                              QuotedStr(mStoreSubBatchList.Strings[k])+' and store_id='+
                                                              QuotedStr(mJSON.A['materials'].O[x].S['Store_ID']),0);
                                mDRBBO:=mDocRowBatches.AddNewObject;
                                mDRBBO.Prefill;
                                mdrbbo.SetFieldValueAsBoolean('NewBatch',False);
                                mDRBBO.SetFieldValueAsString('StoreBatch_ID',mStoreSubBatchList.Strings[k]);
                                if mSBQuantity<mRestQuantity then
                                  mDRBBO.SetFieldValueAsFloat('Quantity',mSBQuantity) else
                                  mDRBBO.SetFieldValueAsFloat('Quantity',mRestQuantity);
                                mRestQuantity:=mRestQuantity-mSBQuantity;
                              end;
                            end;
                          end;
                        end;
                       end;
                      end;
                    end;
                  end;
                 if mMarkForDelete then mRowBO.MarkForDelete;
              end;
            mImportMan.OutputDocument.save;
            mBO.SetFieldValueAsBoolean('X_TariffMDCreated',True);
            except

            end;
       end;
      end;
      if mBO.NeedSave then mBO.save;
      mBO.Free;
       WaitWin.ChangeText(IntToStr(1+i) + ' / ' + IntToStr(mlist.Count));
      WaitWin.StepIt;
    end;
   WaitWin.Stop;
   TDynSiteForm(mSite).RefreshData;
  end;
 end;
end;

begin
end.