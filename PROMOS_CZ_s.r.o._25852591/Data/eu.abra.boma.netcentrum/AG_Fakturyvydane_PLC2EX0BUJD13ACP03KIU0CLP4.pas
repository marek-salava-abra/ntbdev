uses 'eu.abra.boma.netcentrum.common';
procedure execMakeISDOC(Sender: TBasicAction);
var
  mList: TStringList;
  i: Integer;
  mBO: TNxCustomBusinessObject;
begin
  mList:= TStringList.Create;
  try
    Sender.Site.List.GetSelectedId(mList);
    for i:=0 to mList.Count -1 do
    begin
      mBO := Sender.Site.GetFakeBusinessObject;
      try
        mBO.Load(mList[i],nil);
        if mBO.GetFieldValueAsString('Firm_ID')=cFirm_ID then begin
          if True then begin
            MakeISDOCII_NC(mBO.ObjectSpace,mBO.OID);
          end;
          mBO.SetFieldValueAsString('X_MailAddress','NetCentrum@aftersave.eu');
        end;
        if mBO.GetFieldValueAsString('Firm_ID')=cFirmTS_ID then begin
          if True then begin
            MakeISDOCII_TS(mBO.ObjectSpace,mBO.OID);
          end;
          mBO.SetFieldValueAsString('X_MailAddress','technistore@aftersave.eu');
        end;
      finally
        mBO.Free;
      end;
    end;
  finally
    mList.Free;
  end;
end;

{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
begin
  if NxGetActualUserID(Self.BaseObjectSpace) in ['2000000201','1100000201'] then
  begin
    with Self.GetNewAction do
    begin
      Name := 'actMakeISDOC';
      Caption := 'ISDOC pro B2C';
      Category := 'tabList';
      OnExecute := @execMakeISDOC;
    end;
  end;
end;

begin
end.