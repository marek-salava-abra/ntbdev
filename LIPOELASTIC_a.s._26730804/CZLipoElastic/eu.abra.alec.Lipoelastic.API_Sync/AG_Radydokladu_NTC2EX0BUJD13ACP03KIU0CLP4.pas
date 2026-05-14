uses '.lib', '.const';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actSetParams';
  mAction.Caption := '## Nastavení parametrů řad dokladů ##';
  mAction.Items.Add('Nastavení řady dokladů SK OP');
  mAction.Items.Add('Nastavení střediska');
  mAction.Items.Add('Nastavení skladu');
  mAction.Items.Add('Nastavení řady dokladů SK OV');
  mAction.Items.Add('Nastavení řady dokladů SK příjemek');
  mAction.Items.add('Nastavení řady dokladů faktur přijatých');
  mAction.Items.add('Nastavení řady dokladů SK dobropisů faktur přijatých');
  mAction.Items.Add('Vyčistí parametry');
  mAction.Category := 'tabList';
  mAction.OnExecuteItem := @SetParamsForDQ;
end;

Procedure SetParamsForDQ(Sender:TComponent;index:integer);
var
 mSite:TSiteForm;
 mBO:TNxCustomBusinessObject;
 i,j, mCountryIndex:integer;
 mJSON:TJSONSuperObject;
 mJSONArray:TJSONSuperObjectArray;
 mCode, mString:String;
 mList:TStringList;
begin
  mSite:=TComponent(Sender).BusRollSite;
  mBO:=TBusRollSiteForm(mSite).CurrentObject;
  if Assigned(mBO) then begin
   mCountryIndex:=0;
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
      mBO.SetFieldValueAsString('U_SK_ReceivedOrderCode',mCode);
      mbo.save;
      TBusRollSiteForm(mSite).RefreshData;
      TBusRollSiteForm(mSite).DataSet.SeekID(mBO.OID);
      mbo.free;
    end;
   end;
   if index=1 then begin
     if GetCountryIndex(mSite, mCountryIndex) then begin
        mJSON:=TJSONSuperObject.Create;
        mJSONArray:=TJSONSuperObjectArray.Create;
        if mCountryIndex=0 then mJSON:=API_GET(cURL+'divisions?select=code,name',0);
        if mCountryIndex=1 then mJSON:=API_GET(cURLDE+'divisions?select=code,name',1);
        if mCountryIndex=2 then mJSON:=API_GET(cURLAT+'divisions?select=code,name',2);
        mJSONArray:=mJSON.AsArray;
        j:=mJSONArray.Length;
        mList:=TStringList.Create;
        for i:=0 to mJSONArray.Length-1 do begin
           mList.add(mJSONArray.O[i].S['code']+' - '+mJSONArray.O[i].S['name']);
        end;
        if ValueDialog(msite,mlist,mString,'středisko') then begin
          mCode:=NxTrapStrTrim(mString,'-');
          if mCountryIndex=0 then mBO.SetFieldValueAsString('U_SK_DivisionCode',mCode);
          if mCountryIndex=1 then mBO.SetFieldValueAsString('U_DE_DivisionCode',mCode);
          if mCountryIndex=2 then mBO.SetFieldValueAsString('U_AT_DivisionCode',mCode);
          mbo.save;
          TBusRollSiteForm(mSite).RefreshData;
          TBusRollSiteForm(mSite).DataSet.SeekID(mBO.OID);
          mbo.free;
        end;
      end;
   end;
   if index=2 then begin
     if GetCountryIndex(mSite, mCountryIndex) then begin
        mJSON:=TJSONSuperObject.Create;
        mJSONArray:=TJSONSuperObjectArray.Create;
        if mCountryIndex=0 then mJSON:=API_GET(cURL+'stores?select=code,name',0);
        if mCountryIndex=1 then mJSON:=API_GET(cURLDE+'stores?select=code,name',1);
        if mCountryIndex=2 then mJSON:=API_GET(cURLAT+'stores?select=code,name',2);
        mJSONArray:=mJSON.AsArray;
        j:=mJSONArray.Length;
        mList:=TStringList.Create;
        for i:=0 to mJSONArray.Length-1 do begin
           mList.add(mJSONArray.O[i].S['code']+' - '+mJSONArray.O[i].S['name']);
        end;
        if ValueDialog(msite,mlist,mString,'sklad') then begin
          mCode:=NxTrapStrTrim(mString,'-');
          if mCountryIndex=0 then mBO.SetFieldValueAsString('U_SK_StoreCode',mCode);
          if mCountryIndex=1 then mBO.SetFieldValueAsString('U_DE_StoreCode',mCode);
          if mCountryIndex=2 then mBO.SetFieldValueAsString('U_AT_StoreCode',mCode);
          mbo.save;
          TBusRollSiteForm(mSite).RefreshData;
          TBusRollSiteForm(mSite).DataSet.SeekID(mBO.OID);
          mbo.free;
        end;
     end;
   end;
   if index=3 then begin
    if not(mbo.GetFieldValueAsString('DocumentType')='RO') then begin
     NxShowSimpleMessage('Řada dokladů'+#13#10+mbo.DisplayName+#13#10+'není řadou objednávek přijatých, ukončuji.',mSite);
     exit;
    end;
    mJSON:=TJSONSuperObject.Create;
    mJSONArray:=TJSONSuperObjectArray.Create;
    mJSON:=API_GET(cURL+'docqueues?select=code,name&where=DocumentType eq '+Quotedstr('IO'));
    mJSONArray:=mJSON.AsArray;
    j:=mJSONArray.Length;
    mList:=TStringList.Create;
    for i:=0 to mJSONArray.Length-1 do begin
       mList.add(mJSONArray.O[i].S['code']+' - '+mJSONArray.O[i].S['name']);
    end;
    if ValueDialog(msite,mlist,mString,'řadu dokladů') then begin
      mCode:=NxTrapStrTrim(mString,'-');
      mBO.SetFieldValueAsString('U_SK_IssuedOrderCode',mCode);
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
      mBO.SetFieldValueAsString('U_SK_ReceiptCardCode',mCode);
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
    if GetCountryIndex(mSite, mCountryIndex) then begin
      mJSON:=TJSONSuperObject.Create;
      mJSONArray:=TJSONSuperObjectArray.Create;
      if mCountryIndex=0 then mJSON:=API_GET(cURL+'docqueues?select=code,name&where=DocumentType eq '+Quotedstr('04'),0);
      if mCountryIndex=1 then mJSON:=API_GET(cURLDE+'docqueues?select=code,name&where=DocumentType eq '+Quotedstr('04'),1);
      if mCountryIndex=2 then mJSON:=API_GET(cURLAT+'docqueues?select=code,name&where=DocumentType eq '+Quotedstr('04'),2);
      mJSONArray:=mJSON.AsArray;
      mList:=TStringList.Create;
      for i:=0 to mJSONArray.Length-1 do begin
         mList.add(mJSONArray.O[i].S['code']+' - '+mJSONArray.O[i].S['name']);
      end;
      if ValueDialog(msite,mlist,mString,'řadu dokladů faktur přijatých') then begin
        mCode:=NxTrapStrTrim(mString,'-');
        if mCountryIndex=0 then mBO.SetFieldValueAsString('U_SK_ReceivedInvoiceCode',mCode);

        if mCountryIndex=2 then mBO.SetFieldValueAsString('U_AT_ReceivedInvoiceCode',mCode);
        mbo.save;
        TBusRollSiteForm(mSite).RefreshData;
        TBusRollSiteForm(mSite).DataSet.SeekID(mBO.OID);
        mbo.free;
      end;
    end;
   end;
  if index=6 then begin
    if not(mbo.GetFieldValueAsString('DocumentType')='60') then begin
     NxShowSimpleMessage('Řada dokladů'+#13#10+mbo.DisplayName+#13#10+'není řadou dobropisů faktur vydaných, ukončuji.',mSite);
     exit;
    end;
    mJSON:=TJSONSuperObject.Create;
    mJSONArray:=TJSONSuperObjectArray.Create;
    mJSON:=API_GET(cURL+'docqueues?select=code,name&where=DocumentType eq '+Quotedstr('61'));
    mJSONArray:=mJSON.AsArray;
    mList:=TStringList.Create;
    for i:=0 to mJSONArray.Length-1 do begin
       mList.add(mJSONArray.O[i].S['code']+' - '+mJSONArray.O[i].S['name']);
    end;
    if ValueDialog(msite,mlist,mString,'řadu dokladů dobropisů faktur přijatých') then begin
      mCode:=NxTrapStrTrim(mString,'-');
      mBO.SetFieldValueAsString('U_SK_ReceivedCreditNoteCode',mCode);
      mbo.save;
      TBusRollSiteForm(mSite).RefreshData;
      TBusRollSiteForm(mSite).DataSet.SeekID(mBO.OID);
      mbo.free;
    end;
   end;
   if index=7 then begin
    if GetCountryIndex(mSite, mCountryIndex) then begin
     if mCountryIndex=0 then begin
       mBO.SetFieldValueAsString('U_SK_ReceivedOrderCode','');
       mBO.SetFieldValueAsString('U_SK_IssuedOrderCode','');
       mBO.SetFieldValueAsString('U_SK_DivisionCode','');
       mBO.SetFieldValueAsString('U_SK_StoreCode','');
       mBO.SetFieldValueAsString('U_SK_ReceiptCardCode','');
       mBO.SetFieldValueAsString('U_SK_ReceivedInvoiceCode','');
       mBO.SetFieldValueAsString('U_SK_ReceivedCreditNoteCode','');
     end;
     if mCountryIndex=1 then begin
       mBO.SetFieldValueAsString('U_DE_DivisionCode','');
       mBO.SetFieldValueAsString('U_DE_StoreCode','');
       mBO.SetFieldValueAsString('U_DE_ReceivedInvoiceCode','');
     end;
     if mCountryIndex=2 then begin
       mBO.SetFieldValueAsString('U_AT_DivisionCode','');
       mBO.SetFieldValueAsString('U_AT_StoreCode','');
       mBO.SetFieldValueAsString('U_AT_ReceivedInvoiceCode','');
     end;
     mbo.save;
    end;
     TBusRollSiteForm(mSite).RefreshData;
     TBusRollSiteForm(mSite).DataSet.SeekID(mBO.OID);
     mbo.free;
   end;
  end;
end;

begin
end.
