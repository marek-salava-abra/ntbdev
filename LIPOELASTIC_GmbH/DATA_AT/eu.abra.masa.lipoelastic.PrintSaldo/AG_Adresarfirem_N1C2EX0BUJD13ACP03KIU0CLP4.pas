procedure InitSite_Hook(Self: TSiteForm);
var
  mBut, mBut2: TBasicAction;

begin
  if not Assigned(Self.BaseObjectSpace) then
    exit;
  mBut:= Self.GetNewAction;
  mBut.ShowControl := True;
  mBut.ShowMenuItem := True;
  mBut.Name:='actShowDocs';
  mBut.Caption := '##Invoices/Payments##';
  mBut.Category := 'tabList';
  mBut.OnExecute := @ShowDocs;

end;

procedure ShowDocs(sender:TComponent);
var
 mSite:TSiteForm;
 mList:TstringList;
 mOS:TNxCustomObjectSpace;
 mBO, mUser:TNxCustomBusinessObject;
begin
  mSite:=TComponent(sender).BusRollSite;
  mBO:=TBusRollSiteForm(mSite).CurrentObject;
   if Assigned(mBO) then begin
    mList:=TStringList.Create;
    mOS:=mbo.ObjectSpace;
    mlist.Add(mBO.OID);
       CFxReportManager.PrintByIDs(NxCreateContext_1(mBO),mList,'U2K5FY3HNAHO5BRQ5O0YMQ0TGO','~000000806',rtoPreview,pekPDF,'','');
    mList.free;
   end;
end;

begin
end.