uses 'eu.promos.workflow.fce';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TAction;
  i : integer;
begin

  {mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Částečné vyskladnění';
  mAction.ShortCut := TextToShortCut('Ctrl+D'); //16450;
  mAction.Hint := 'rozpadne objednávku na dvě ';
  mAction.Category := 'tabList';
  mAction.OnExecute := @CreateSplOrder;
    //mAction.OnUpdate := @ImportOnUpdate;}

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Částečný DL';
  mAction.ShortCut := TextToShortCut('Ctrl+D'); //16450;
  mAction.Hint := 'Vytvoří DL na skladové položky';
  mAction.Category := 'tabList';
  mAction.OnExecute := @CreateDL;

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Přepočítat OP';
  mAction.Hint := 'Přepočítá objednávky mimo plán';
  mAction.Category := 'tabList';
  mAction.OnExecute := @Recalculate;

end;

Procedure Recalculate(Sender:TComponent);
var
 mSite:TSiteForm;
 mOS:TNxCustomObjectSpace;
 mBO:TNxCustomBusinessObject;
 mList:TStringList;
 i:integer;
begin
  mList:=TStringList.create;
  mSite:=TComponent(sender).DynSite;
  mOS:=TDynSiteForm(mSite).BaseObjectSpace;
  mos.SQLSelect('Select id from receivedorders where closed=''N'' and pmstate_id in (''6000000101'',''5000000101'',''3010000101'') order by createdat$date',mList);
  if mlist.Count>0 then begin
     for i:=0 to mlist.count-1 do begin
       mBO:=mOS.CreateObject(Class_ReceivedOrder);
       mBO.Load(mlist.strings[i],nil);
       mBO.Save;
       mBO.Free;
     end;
  end;
  NxShowSimpleMessage('Přepočteno',mSite);
end;

Procedure CreateDL(Sender:TComponent);
var
 mBO:TNxCustomBusinessObject;
 mSite:TSiteForm;
 mImportMan:TNxDocumentImportManager;
 mInputParams:TNxParameters;
 mParam:TNxParameter;
 mRows:TNxCustomBusinessMonikerCollection;
begin
  mSite:=TComponent(Sender).DynSite;
  mBO:=TDynSiteForm(mSite).CurrentObject;
  if Assigned(mBO) then begin
                     try
                      mInputParams := TNxParameters.Create;
                      mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                      mParam.AsString := 'M000000101';
                      mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
                      mParam.AsString := mBO.OID;
                      mParam := mInputParams.GetOrCreateParam(dtInteger, 'StoreQuantityKind');
                      mParam.AsInteger := 1;
                      mImportMan:=NxCreateDocumentImportManager(mbo.ObjectSpace,Class_ReceivedOrder,Class_BillOfDelivery);
                      mImportMan.AddInputDocument(mbo.OID);
                      mImportMan.LoadParams(mInputParams);
                      mImportMan.Execute;
                      mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', 'M000000101');
                      mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID',mBO.GetFieldValueAsString('Firm_ID'));
                      mImportMan.OutputDocument.SetFieldValueAsString('FirmOffice_ID',mBO.GetFieldValueAsString('FirmOffice_ID'));
                      mRows:=mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
                      if mrows.CountOfNotDeleted>0 then begin

                        mImportMan.OutputDocument.Save;
                        //mbo.SetFieldValueAsString('PMState_ID','3010000101');
                        //mbo.save;
                      end;
                      finally

                      end;
                      TDynSiteForm(mSite).ActiveDataSet.RefreshCurrentItem;
                      TDynSiteForm(mSite).RefreshData;
                      if Assigned(mImportMan.OutputDocument) then NxShowSimpleMessage('Založil jsem '+mImportMan.OutputDocument.DisplayName,nil) else NxShowSimpleMessage('Doklad by neměl žádný řádek.',nil);

  end;
end;

Procedure CreateSplOrder(sender:tcomponent);
var
 mSite:TSiteForm;
 mBO, mNewBO, mRowBO, mNewRowBO:TNxCustomBusinessObject;
 mRows, mNewRows:TNxCustomBusinessMonikerCollection;
 i,j:integer;
 mAvailableQuantity,mOrderedQuantity: Extended;
begin
 mSite:=TComponent(sender).DynSite;
 mBO:=TDynSiteForm(mSite).CurrentObject;
 if Assigned(mBO) then begin
   if mBO.GetFieldValueAsString('PMState_ID')='6000000101' then begin
     if NxMessageBox('Dotaz','Provést částečné vyskladnění na  '+mbo.DisplayName+'?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
        mNewBO:=mBO.Clone;
        mNewBo.SetFieldValueAsString('Firm_ID',mBO.GetFieldValueAsString('Firm_ID'));
        mNewBo.SetFieldValueAsString('Address_ID',mBO.GetFieldValueAsString('Address_ID'));
        mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
        mNewRows:=mNewBO.GetLoadedCollectionMonikerForFieldCode(mNewBO.GetFieldCode('Rows'));
        for i:=0 to mRows.Count-1 do begin
          mRowBO:=mRows.BusinessObject[i];
           if mRowBO.GetFieldValueAsInteger('RowType')=3 then begin
              mAvailableQuantity:=GetAvailableQuantity(mbo.ObjectSpace,mRowBO.GetFieldValueAsString('Store_ID'), mRowBO.GetFieldValueAsString('StoreCard_ID'));
              mOrderedQuantity:=GetOrderedQuantity(mbo.ObjectSpace,mRowBO.GetFieldValueAsString('StoreCard_ID'), mRowBO.OID,mRowBO.GetFieldValueAsString('Store_ID'), mbo.GetFieldValueAsDateTime('CreatedAt$DATE'));
              if (mAvailableQuantity-mOrderedQuantity-mRowBO.GetFieldValueAsFloat('Quantity'))<0 then begin
                if (mAvailableQuantity-mOrderedQuantity)>0 then mRowBO.SetFieldValueAsFloat('Quantity',(mAvailableQuantity-mOrderedQuantity));
                if (mAvailableQuantity-mOrderedQuantity)<=0 then mRowBO.MarkForDelete;
              end;
           end;
        end;
        for j:=0 to mNewRows.Count-1 do begin
          mNewRowBO:=mNewRows.BusinessObject[j];
           if mNewRowBO.GetFieldValueAsInteger('RowType')=3 then begin
              mAvailableQuantity:=GetAvailableQuantity(mbo.ObjectSpace,mNewRowBO.GetFieldValueAsString('Store_ID'), mNewRowBO.GetFieldValueAsString('StoreCard_ID'));
              mOrderedQuantity:=GetOrderedQuantity(mbo.ObjectSpace,mNewRowBO.GetFieldValueAsString('StoreCard_ID'), mNewRowBO.OID,mNewRowBO.GetFieldValueAsString('Store_ID'), mNewBO.GetFieldValueAsDateTime('CreatedAt$DATE'));
              if (mAvailableQuantity-mOrderedQuantity)>mNewRowBO.GetFieldValueAsFloat('Quantity') then mNewRowBO.MarkForDelete;
              if (mAvailableQuantity-mOrderedQuantity)<mNewRowBO.GetFieldValueAsFloat('Quantity') then mNewRowBO.SetFieldValueAsFloat('Quantity',mNewRowBO.GetFieldValueAsFloat('Quantity')-(mAvailableQuantity-mOrderedQuantity));
           end;
        end;
       mBO.save;
       mNewBO.save;
       TDynSiteForm(mSite).RefreshData;
     end;
   end;
 end;
end;

begin
end.