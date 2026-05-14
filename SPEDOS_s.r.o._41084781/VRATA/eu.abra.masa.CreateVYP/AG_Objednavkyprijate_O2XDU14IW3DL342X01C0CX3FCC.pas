procedure InitSite_Hook(Self: TSiteForm);

var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.Name := 'actCreateVYP';
  mAction.Caption := 'Vytvoření dokumentů do VYP';
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Category := 'tablist';
  mAction.Hint := 'Vygeneruje doklady VYP';
  mAction.OnExecute := @CreateVYP;
end;

procedure CreateVYP(sender:tcomponent);
var
 mOrderList,mRORowList,mPLMPQList, mTempList, mStoreCardList:TStringList;
 mSite:TSiteForm;
 i,j:integer;
 mPOZDoc_ID, mOrderString:string;
 mOS:TNxCustomObjectSpace;
 mImportMan: TNxDocumentImportManager;
 mInputParams: TNxParameters;
 mParam: TNxParameter;
begin
 mSite:=TComponent(sender).DynSite;
 mOS:=mSite.BaseObjectSpace;
 mOrderList:=TStringList.Create;
 mRORowList:=TStringList.Create;
 mPLMPQList:=TStringList.Create;
 mStoreCardList:=TStringList.Create;
 mPOZDoc_ID:='1L20000101';
 TDynSiteForm(mSite).List.GetSelectedId(mOrderList);
 if mOrderList.count>0 then begin
             for i:=0 to mOrderList.count-1 do begin
               if i=0 then mOrderString:=QuotedStr(mOrderList.strings[i]) else mOrderString:=mOrderString+','+QuotedStr(mOrderList.strings[i]);
             end;
             mOS.SQLSelect('Select sc.id from receivedorders2 ro2 left join storecards sc on ro2.storecard_id=sc.id where sc.isproduct='+QuotedStr('A')+' and ro2.rowtype=3 and ro2.parent_id in ('+mOrderString+') group by sc.id',mStoreCardList);

             for i:=0 to mStoreCardList.count-1 do begin
               mRORowList:=TStringList.create;
                 mOS.SQLSelect('Select ro2.id from receivedorders2 ro2 left join storecards sc on ro2.storecard_id=sc.id where sc.id='+QuotedStr(mStoreCardList.Strings[i])+' and ro2.rowtype=3 and ro2.parent_id in ('+mOrderString+')',mRORowList);


                 mInputParams := TNxParameters.Create;
                 mParam :=  mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                 mParam.AsString := mPOZDOC_ID;
                 mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows'); // jen povolene radky&#xD;
                 mParam.AsString := mRORowList.Text;
                 mParam := mInputParams.GetOrCreateParam(dtInteger, 'MultiOutputGroupingKind');
                 mParam.AsInteger := 1;
                 mImportMan := NxCreateDocumentImportManager(mOS, Class_ReceivedOrder, Class_PLMProduceRequest);
                 mImportMan.AddInputDocuments(mOrderList);
                 mImportMan.LoadParams(mInputParams);
                 mImportMan.Execute;
                 mImportMan.OutputDocument.SetFieldValueAsString('Store_ID','1500000101');
                 mImportMan.OutputDocument.SetFieldValueAsFloat('CorrectedQuantity',mImportMan.OutputDocument.GetFieldValueAsFloat('Quantity'));
                 mImportMan.OutputDocument.SetFieldValueAsDateTime('Schedule$DATE',date+0.25);
                 mimportman.OutputDocument.SetFieldValueAsDateTime('PlanedStartAt$DATE',date+0.25);
                 mImportMan.OutputDocument.save;
                 mPLMPQList.Add(mImportMan.OutputDocument.OID);
                 mImportMan.free;
               mRORowList.free;
             end;

 end;
end;

begin
end.