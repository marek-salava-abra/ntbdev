uses '.lib','.API';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actSetParams';
  mAction.Caption := '## Nastavení parametrů řad OV ##';
  mAction.Items.Add('Nastavení řady dokladů OP');
  mAction.Items.Add('Nastavení střediska');
  mAction.Items.Add('Nastavení skladu');
  //mAction.Items.Add('Nastavení řady dokladů OV');
  //mAction.Items.add('Nastavení řady dokladů příjemek');
  //mAction.Items.add('Nastavení řady dokladů faktur přijatých');
  mAction.Items.Add('Vyčistit parametry');
  mAction.Category := 'tabList';
  mAction.OnExecuteItem := @SetParamsForDQ;
end;

Procedure SetParamsForDQ(Sender:TComponent;index:integer);
var
 mSite:TSiteForm;
 mBO:TNxCustomBusinessObject;
 i,j:integer;
 mJSON:TJSONSuperObject;
 mJSONArray:TJSONSuperObjectArray;
 mCode, mString:String;
 mList:TStringList;
begin
  mSite:=TComponent(Sender).BusRollSite;
  mBO:=TBusRollSiteForm(mSite).CurrentObject;
  if Assigned(mBO) then begin
   if index=0 then begin
    if not(mbo.GetFieldValueAsString('DocumentType')='IO') then begin
     NxShowSimpleMessage('Řada dokladů'+#13#10+mbo.DisplayName+#13#10+'není řadou objednávek vydaných, ukončuji.',mSite);
     exit;
    end;
    mJSON:=TJSONSuperObject.Create;
    mJSONArray:=TJSONSuperObjectArray.Create;
    mJSON:=API_GET(cURL+'docqueues?select=code,name&where=DocumentType eq '+Quotedstr('RO'));
    mJSONArray:=mJSON.AsArray;
    j:=mJSONArray.Length;
    mList:=TStringList.Create;
    for i:=0 to mJSONArray.Length-1 do begin
       mList.add(mJSONArray.O[i].S['code']+' - '+mJSONArray.O[i].S['name']);
    end;
    if ValueDialog(msite,mlist,mString,'řadu dokladů') then begin
      mCode:=NxTrapStrTrim(mString,'-');
      mBO.SetFieldValueAsString('U_CZ_ReceivedOrderCode',mCode);
      mbo.save;
      TBusRollSiteForm(mSite).RefreshData;
      TBusRollSiteForm(mSite).DataSet.SeekID(mBO.OID);
      mbo.free;
    end;
   end;
   if index=1 then begin
    mJSON:=TJSONSuperObject.Create;
    mJSONArray:=TJSONSuperObjectArray.Create;
    mJSON:=API_GET(cURL+'divisions?select=code,name');
    mJSONArray:=mJSON.AsArray;
    j:=mJSONArray.Length;
    mList:=TStringList.Create;
    for i:=0 to mJSONArray.Length-1 do begin
       mList.add(mJSONArray.O[i].S['code']+' - '+mJSONArray.O[i].S['name']);
    end;
    if ValueDialog(msite,mlist,mString,'středisko') then begin
      mCode:=NxTrapStrTrim(mString,'-');
      mBO.SetFieldValueAsString('U_CZ_DivisionCode',mCode);
      mbo.save;
      TBusRollSiteForm(mSite).RefreshData;
      TBusRollSiteForm(mSite).DataSet.SeekID(mBO.OID);
      mbo.free;
    end;
   end;
   if index=2 then begin
    mJSON:=TJSONSuperObject.Create;
    mJSONArray:=TJSONSuperObjectArray.Create;
    mJSON:=API_GET(cURL+'stores?select=code,name');
    mJSONArray:=mJSON.AsArray;
    j:=mJSONArray.Length;
    mList:=TStringList.Create;
    for i:=0 to mJSONArray.Length-1 do begin
       mList.add(mJSONArray.O[i].S['code']+' - '+mJSONArray.O[i].S['name']);
    end;
    if ValueDialog(msite,mlist,mString,'sklad') then begin
      mCode:=NxTrapStrTrim(mString,'-');
      mBO.SetFieldValueAsString('U_CZ_StoreCode',mCode);
      mbo.save;
      TBusRollSiteForm(mSite).RefreshData;
      TBusRollSiteForm(mSite).DataSet.SeekID(mBO.OID);
      mbo.free;
    end;
   end;
   {if index=3 then begin
    mJSON:=TJSONSuperObject.Create;
    mJSONArray:=TJSONSuperObjectArray.Create;
    mJSON:=API_GET(cURL+'docqueues?select=code,name&where=DocumentType eq '+Quotedstr('IO'));
    mJSONArray:=mJSON.AsArray;
    j:=mJSONArray.Length;
    mList:=TStringList.Create;
    for i:=0 to mJSONArray.Length-1 do begin
       mList.add(mJSONArray.O[i].S['code']+' - '+mJSONArray.O[i].S['name']);
    end;
    if ValueDialog(msite,mlist,mString,'řadu dokladů OV') then begin
      mCode:=NxTrapStrTrim(mString,'-');
      mBO.SetFieldValueAsString('U_CZ_IssuedOrderCode',mCode);
      mbo.save;
      TBusRollSiteForm(mSite).RefreshData;
      TBusRollSiteForm(mSite).DataSet.SeekID(mBO.OID);
      mbo.free;
    end;
   end;
   if index=4 then begin
    if not(mbo.GetFieldValueAsString('DocumentType')='21') then begin
     NxShowSimpleMessage('Řada dokladů'+#13#10+mbo.DisplayName+#13#10+'není řadou dodacích listů, ukončuji.',mSite);
     exit;
    end;
    mJSON:=TJSONSuperObject.Create;
    mJSONArray:=TJSONSuperObjectArray.Create;
    mJSON:=API_GET(cURL+'docqueues?select=code,name&where=DocumentType eq '+Quotedstr('20'));
    mJSONArray:=mJSON.AsArray;
    mList:=TStringList.Create;
    for i:=0 to mJSONArray.Length-1 do begin
       mList.add(mJSONArray.O[i].S['code']+' - '+mJSONArray.O[i].S['name']);
    end;
    if ValueDialog(msite,mlist,mString,'řadu dokladů příjemek') then begin
      mCode:=NxTrapStrTrim(mString,'-');
      mBO.SetFieldValueAsString('U_CZ_ReceiptCardCode',mCode);
      mbo.save;
      TBusRollSiteForm(mSite).RefreshData;
      TBusRollSiteForm(mSite).DataSet.SeekID(mBO.OID);
      mbo.free;
    end;
   end;
   if index=5 then begin
    if not(mbo.GetFieldValueAsString('DocumentType')='03') then begin
     NxShowSimpleMessage('Řada dokladů'+#13#10+mbo.DisplayName+#13#10+'není řadou faktur vydaných, ukončuji.',mSite);
     exit;
    end;
    mJSON:=TJSONSuperObject.Create;
    mJSONArray:=TJSONSuperObjectArray.Create;
    mJSON:=API_GET(cURL+'docqueues?select=code,name&where=DocumentType eq '+Quotedstr('04'));
    mJSONArray:=mJSON.AsArray;
    mList:=TStringList.Create;
    for i:=0 to mJSONArray.Length-1 do begin
       mList.add(mJSONArray.O[i].S['code']+' - '+mJSONArray.O[i].S['name']);
    end;
    if ValueDialog(msite,mlist,mString,'řadu dokladů faktur přijatých') then begin
      mCode:=NxTrapStrTrim(mString,'-');
      mBO.SetFieldValueAsString('U_CZ_ReceivedInvoiceCode',mCode);
      mbo.save;
      TBusRollSiteForm(mSite).RefreshData;
      TBusRollSiteForm(mSite).DataSet.SeekID(mBO.OID);
      mbo.free;
    end;
   end;
   if index=6 then begin }
   if index=3 then begin
     mBO.SetFieldValueAsString('U_CZ_ReceivedOrderCode','');
     //mBO.SetFieldValueAsString('U_CZ_IssuedOrderCode','');
     mBO.SetFieldValueAsString('U_CZ_DivisionCode','');
     mBO.SetFieldValueAsString('U_CZ_StoreCode','');
     //mBO.SetFieldValueAsString('U_CZ_ReceiptCardCode','');
     //mBO.SetFieldValueAsString('U_CZ_ReceivedInvoiceCode','');
     mbo.save;
     TBusRollSiteForm(mSite).RefreshData;
     TBusRollSiteForm(mSite).DataSet.SeekID(mBO.OID);
     mbo.free;
   end;
  end;
end;

begin
end.