procedure InitSite_Hook(Self: TSiteForm);
var
  mBut, mBut2: TBasicAction;

begin
  if not Assigned(Self.BaseObjectSpace) then
    exit;

mBut:= Self.GetNewAction;
mBut.ShowControl := True;
mBut.ShowMenuItem := True;
mBut.Caption := 'Vytisknout dlužné FV';
mBut.Hint := 'Vytiskne sestavu neuhrazených faktur pro označenou firmu';
mBut.Category := 'tabList';
mBut.OnExecute := @PrintFV;

end;

procedure PrintFV(sender:TComponent);
var
 mSite:TSiteForm;
 mList:TstringList;
 mOS:TNxCustomObjectSpace;
 mBO:TNxCustomBusinessObject;
 mContext:TNxContext;
begin
  mSite:=TComponent(sender).BusRollSite;
  mBO:=TBusRollSiteForm(mSite).CurrentObject;
   if Assigned(mBO) then begin
   if (mbo.GetFieldValueAsBoolean('U_netisknoutFV')) then NxShowSimpleMessage('Nemáte právo tisknout neuhrazené FV pro firmu ' +mbo.GetFieldValueAsString('Name'),mSite);
   if not(mbo.GetFieldValueAsBoolean('U_netisknoutFV')) then begin
    mList:=TStringList.Create;
    mOS:=mbo.ObjectSpace;
    mos.SQLSelect(format('select ii.id from issuedinvoices ii /*left*/ join firms f on f.id=ii.firm_id where not((ii.Amount + ii.PaidCreditAmount - ii.PaidAmount -  ii.CreditAmount)=0) and (F.ID=''%s'' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID=''%s'')))',[mbo.OID,mbo.OID]),mlist);
    //NxShowSimpleMessage(format('select ii.id from issuedinvoices ii /*left*/ join firms  f on f.id=ii.firm_id where not((ii.Amount + ii.PaidCreditAmount - ii.PaidAmount -  ii.CreditAmount)=0) and (F.ID=''%s'' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID=''%s'')))',[mbo.OID,mbo.OID]),mSite);
    if mlist.Count>0 then begin
        mContext:=NxCreateNotLoggedContext_1(mBO);
        mContext.LogOn('Josef Novák','XDQcJZwc2SKRfZ1epob8');
         CFxReportManager.PrintByIDs(mContext,mList,'40SBPEINEFD13ACM03KIU0CLP4','1620000101',rtoPreview,pekPDF,'','');
        mContext.free;

    end else begin
     NxShowSimpleMessage('Firma '+mbo.GetFieldValueAsString('Name')+' nemá neuhrazené doklady.', mSite);
    end;
    end;
   end;
end;


begin
end.