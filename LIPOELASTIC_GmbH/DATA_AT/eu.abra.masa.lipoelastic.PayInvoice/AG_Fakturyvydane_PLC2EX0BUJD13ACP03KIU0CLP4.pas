procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actPaySelected';
  mAction.Caption := 'Pay Selected';
  mAction.Hint := 'Create Payment';
  mAction.Category := 'tabList';
  mAction.OnExecute := @PayDoc;
end;

Procedure PayDoc(Sender:TComponent);
var
 mSite:TSiteForm;
 mList:TStringList;
 i:integer;
 mIIBO, mOIBO, mOIRowBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mOS:TNxCustomObjectSpace;
begin
 mSite:=TComponent(Sender).DynSite;
 mList:=TStringList.Create;
 TDynSiteForm(mSite).List.GetSelectedId(mList);
 mOS:=TDynSiteForm(mSite).BaseObjectSpace;
 if mlist.count>0 then begin
    WaitWin.StartProgress('Please, wait ...', '', mList.Count);
    for i:=0 to mlist.count-1 do begin
            mIIBO:=mOS.CreateObject(Class_IssuedInvoice);
            mIIBO.Load(mlist.strings[i],nil);
            if not(0=(mIIBO.GetFieldValueAsFloat('Amount')-mIIBO.GetFieldValueAsFloat('PaidAmount'))) then begin
              mOIBO:=mOS.CreateObject(Class_OtherIncome);
              mOIBO.New;
              mOIBO.Prefill;
              mOIBO.SetFieldValueAsBoolean('VATDocument',false);
              mOIBO.SetFieldValueAsString('Firm_ID',mIIBO.GetFieldValueAsString('Firm_ID'));
              mOIBO.SetFieldValueAsString('Description', 'Payment '+mIIBO.DisplayName);
              mOIBO.SetFieldValueAsString('PDocumentType','03');
              mOIBO.SetFieldValueAsString('PDocument_ID',mIIBO.OID);
              mRows:=mOIBO.GetCollectionMonikerForFieldCode(mOIBO.GetFieldCode('Rows'));
               mOIRowBO:=mRows.AddNewObject;
               mOIRowBO.Prefill;
               //mOIRowBO.SetFieldValueAsInteger('RowType',1);
               mOIRowBO.SetFieldValueAsString('Text','Payment '+mIIBO.DisplayName);
               mOIRowBO.SetFieldValueAsFloat('TAmount',(mIIBO.GetFieldValueAsFloat('Amount')-mIIBO.GetFieldValueAsFloat('PaidAmount')));
               mOIRowBO.SetFieldValueAsString('Division_ID',mIIBO.GetLoadedCollectionMonikerForFieldCode(mIIBO.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('Division_ID'));
              mOIBO.Save;
              mOIBO.Free;
              mIIBO.Free;
            end;
    WaitWin.ChangeText(IntToStr(1+i) + ' / ' + IntToStr(mList.Count));
    WaitWin.StepIt;
   end;
  WaitWin.Stop;
 end;
end;

begin
end.