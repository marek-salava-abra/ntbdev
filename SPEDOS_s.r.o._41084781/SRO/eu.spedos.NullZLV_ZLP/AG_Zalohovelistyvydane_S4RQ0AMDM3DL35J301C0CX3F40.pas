procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
  mUser:TNxCustomBusinessObject;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Vynulováni ZLV';
  mAction.Items.Add('Nastaví hodnoty na nulové');
  mAction.Hint := 'změní hodnoty na dokladu';
  mAction.Category := 'tabList';
  mAction.OnExecuteItem := @NullDeposit;
end;

Procedure NullDeposit(Sender:TComponent; index:integer);
var
 mList:TStringList;
 mSite:TSiteForm;
 i:integer;
 mOS:TNxCustomObjectSpace;
 mBO:TNxCustomBusinessObject;
begin
 mSite:=TComponent(Sender).DynSite;
 mOS:=mSite.BaseObjectSpace;
 mList:=TStringList.Create;
 TDynSiteForm(mSite).List.GetSelectedId(mList);
 if NxMessageBox('Dotaz','Přejete si vynulovat '+IntToStr(mlist.count)+' záloh?' , mdConfirm, mdbYesNo, 0, 0, False, msite)= mrYes then begin
  for i:=0 to mList.count-1 do begin
     mBO:=mOS.CreateObject(Class_IssuedDepositInvoice);
     mBO.Load(mList.Strings[i],nil);
     if mbo.GetFieldValueAsFloat('PaidAmount')=0 then begin
       mOS.SQLExecute(format('update issueddinvoices set amount=0,localamount=0 where id=''%s'' ',[mBO.OID]));
       mOS.SQLExecute(format('update issueddinvoices2 set tamount=0,localtamount=0 where parent_id=''%s'' ',[mBO.OID]));
     end;
     mbo.Free;
  end;
 end;
 TDynSiteForm(mSite).RefreshData;
end;

begin
end.