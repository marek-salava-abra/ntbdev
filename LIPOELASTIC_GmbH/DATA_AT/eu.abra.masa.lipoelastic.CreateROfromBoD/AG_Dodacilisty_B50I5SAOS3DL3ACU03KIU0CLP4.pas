procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actCreateOrdersIN';
  mAction.Caption := '## Create Orders In ##';
  mAction.Hint := 'Create OrderIn';
  mAction.Category := 'tabList';
  mAction.OnExecute := @OrderIn;
end;

Procedure OrderIn(Sender:TComponent);
var
 mSite:TSiteForm;
 mList, mOTList, mLogs:TStringList;
 i,j:integer;
 mBODBO,mBODRowBO, mOTBO, mOTRowBO, mUserXLink:TNxCustomBusinessObject;
 mRows, mOTRows:TNxCustomBusinessMonikerCollection;
 mOS:TNxCustomObjectSpace;
begin
 mSite:=TComponent(Sender).DynSite;
 mList:=TStringList.Create;
 mLogs:=TStringList.Create;
 mOTList:=TStringList.Create;
 TDynSiteForm(mSite).List.GetSelectedId(mList);
 mOS:=TDynSiteForm(mSite).BaseObjectSpace;
 if mlist.count>0 then begin
    WaitWin.StartProgress('Please, wait ...', '', mList.Count);
    for i:=0 to mlist.count-1 do begin
     try
      mBODBO:=mOS.CreateObject(Class_BillOfDelivery);
      mBODBO.Load(mlist.strings[i],nil);
      mRows:=mBODBO.GetLoadedCollectionMonikerForFieldCode(mBODBO.GetFieldCode('Rows'));
      mOTBO:=mOS.CreateObject(Class_ReceivedOrder);
      mOTBO.new;
      mOTBO.prefill;
      mOTBO.SetFieldValueAsString('DocQueue_ID','~000000505');
      mOTBO.SetFieldValueAsString('Firm_ID',mBODBO.GetFieldValueAsString('Firm_ID'));
      mOTBO.SetFieldValueAsString('Description',mBODBO.DisplayName);
      mOTRows:=mOTBO.GetLoadedCollectionMonikerForFieldCode(mOTBO.GetFieldCode('Rows'));
      for j:=0 to mrows.Count-1 do begin
        mBODRowBO:=mRows.BusinessObject[j];
        mOTRowBO:=mOTRows.AddNewObject;
        mOTRowBO.prefill;
        mOTRowBO.SetFieldValueAsInteger('RowType',3);
        mOTRowBO.SetFieldValueAsString('Store_ID','~00000011Y');
        mOTRowBO.SetFieldValueAsString('StoreCard_ID',mBODRowBO.GetFieldValueAsString('StoreCard_ID'));
        mOTRowBO.SetFieldValueAsFloat('Quantity',mBODRowBO.GetFieldValueAsFloat('quantity'));
        mOTRowBO.SetFieldValueAsString('Qunit',mBODRowBO.GetFieldValueAsString('Qunit'));
        mOTRowBO.SetFieldValueAsString('Division_ID',mBODRowBO.GetFieldValueAsString('Division_ID'));
        mOTRowBO.SetFieldValueAsString('BusOrder_ID',mBODRowBO.GetFieldValueAsString('BusOrder_ID'));
        mOTRowBO.SetFieldValueAsString('BusTransaction_ID',mBODRowBO.GetFieldValueAsString('BusTransaction_ID'));
        mOTRowBO.SetFieldValueAsString('BusProject_ID',mBODRowBO.GetFieldValueAsString('BusProject_ID'));
      end;
      mOTBO.save;
      mUserXLink := mOS.CreateObject(Class_UserXLink);
      try
        mUserXLink.New;
        mUserXLink.Prefill;
        mUserXLink.SetFieldValueAsString('Source_ID', mOTBO.oid);
        mUserXLink.SetFieldValueAsString('SourceCLSID', Class_ReceivedOrder);
        mUserXLink.SetFieldValueAsString('DestinationCLSID', Class_BillOfDelivery);
        mUserXLink.SetFieldValueAsString('Destination_ID', mBODBO.OID);
        mUserXLink.SetFieldValueAsBoolean('DisplayAsSystem', True);
        mUserXLink.SetFieldValueAsString('Description',mBODBO.DisplayName+' --> '+mOTBO.DisplayName);
        mUserXLink.Save;
      finally
        mUserXLink.Free;
      end;
      mOTList.Add(QuotedStr(mOTBO.oid));
      mOTBO.free;
      mBODBO.free;
     except
       mLogs.add(mBODBO.DisplayName+' '+ExceptionMessage);
     end;
    WaitWin.ChangeText(IntToStr(1+i) + ' / ' + IntToStr(mList.Count));
    WaitWin.StepIt;
   end;
  WaitWin.Stop;
  if mLogs.count>0 then NxShowSimpleMessage(mlogs.text,msite);
  if mOTList.Count>0 then mSite.ShowSite(Site_ReceivedOrders,true,'QueryByUserDynSQLCondition;A.ID in ('+mOTList.DelimitedText+');New orders');

 end;
end;

begin
end.