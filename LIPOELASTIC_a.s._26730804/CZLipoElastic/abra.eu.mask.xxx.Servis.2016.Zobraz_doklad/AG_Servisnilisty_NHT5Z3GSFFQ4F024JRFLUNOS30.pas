  uses 'abra.eu.mask.xxx.Servis.2016.Zobraz_doklad.lib';

Var
mbo_CRM_activities:TNxCustomBusinessObject;
mbo_ServiceAssembyForms:TNxCustomBusinessObject;
mbo_ServiceDocuments:TNxCustomBusinessObject;
mbo_ServiceAssembyFormRows:TNxCustomBusinessObject;
mr:tstringlist;
mID:string;
mtext:string;

 procedure InitSite_Hook(Self: TSiteForm);
var
mAction: TAction;
  mMAction: TMultiAction;
  mUserFilter: Boolean;
  mUser: TNxCustomBusinessObject;
begin
//  mUserFilter:=false;
//  mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');            // přihlášený uživatel
//  try
//      mUser.Load(Self.CompanyCache.GetUserID, nil);
//            if mUser.GetFieldValueAsString('Name')='Supervisor' then mUserFilter:= true;
//  finally
//    mUser.Free;
//  end;


    mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Připojené doklady';
  mMAction.Hint := 'Doklady servisu';
  mMAction.Category := 'tablist,tabdetail';
  mMAction.OnExecuteItem := @ShowDocExecuteItem;
  mMAction.Items.Add('Montážní list');
  mMAction.Items.Add('Servisní list');
  mMAction.Items.Add('Servisovaný předmět');
  mMAction.Items.Add('');
  mMAction.Items.Add('Cenová nabídka');
  mMAction.Items.Add('Objednávky dispečera');
  mMAction.Items.Add('Objednávky logistika');
  mMAction.Items.Add('Vyskladnění zboží');
  mMAction.Items.Add('Faktury vydané');
  mMAction.Items.Add('Příjemka');
  mMAction.Items.Add('Převodka výdej');
end;


 procedure ShowDocExecuteItem(Sender: Tcomponent; Index: integer);
var
 L : TStringList;
 mid:string;
 mPars:TNxParameters;
 mPar:TNxParameter;
 msite:TDynSiteForm;
 mr2,mrx:TStringList;
 mMon : TNxCustomBusinessMonikerCollection;
 mStrings:string;
 i,ii:integer;
 mtext:string;
begin
 mSite := TComponent(sender).DynSite;

                              mbo_Servicedocuments:=TDynSiteForm(mSite).CurrentObject;
                              mbo_ServiceAssembyForms:=TDynSiteForm(mSite).CurrentObject.ObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                              mrx:=TStringList.create;
                              try
                              mbo_Servicedocuments.ObjectSpace.SQLSelect('select sa2.id from ServiceAssemblyForms sa left join ServiceAssemblyForms2 SA2 on sa2.parent_id=sa.id where sa.ServiceDocument_ID=' + quotedstr(mbo_ServiceDocuments.OID),mrx);
                                  if mrx.count>0 then begin
                                      mStrings:='(';
                                     for i:=0 to mrx.count-1 do begin
                                                if i>0 then mStrings:= mStrings + ',';
                                                mStrings:= mStrings + quotedstr(mrx.Strings[i]);

                                      end;
                                      mStrings:= mStrings +')';
                                    end;
                              finally
                                  mrx.free;
                              end;
                                           mr2:=TStringList.create;
                                           try
                                                if index=0 then  mbo_ServiceAssembyForms.ObjectSpace.SQLSelect('select distinct H.id from ServiceAssemblyForms H left join ServiceAssemblyForms2 R on r.parent_id=H.id where r.id=' + quotedstr(mbo_CRM_activities.GetFieldValueAsString('X_parent_ID')),mr2);
                                                if index=1 then  mbo_ServiceAssembyForms.ObjectSpace.SQLSelect('select distinct SD.id from ServiceDocuments SD where sd.id=' + quotedstr(mbo_ServiceAssembyForms.GetFieldValueAsString('ServiceDocument_ID')),mr2);
                                                if index=2 then  mbo_ServiceAssembyForms.ObjectSpace.SQLSelect('select distinct SO.id from ServicedObjects SO left join ServiceDocuments SD on sd.ServicedObject_ID=so.id where sd.id=' + quotedstr(mbo_ServiceAssembyForms.GetFieldValueAsString('ServiceDocument_ID')),mr2);
                                                //if index=3 then  mbo_ServiceAssembyForms.ObjectSpace.SQLSelect('select distinct H.id from issuedinvoices H left join issuedinvoices2 R on r.parent_id=H.id where r.X_parent_id=' + quotedstr(mbo_CRM_activities.GetFieldValueAsString('X_parent_ID')),mr2);
                                                if index=4 then  mbo_ServiceAssembyForms.ObjectSpace.SQLSelect('select distinct H.id from IssuedOffers H left join IssuedOffers2 R on r.parent_id=H.id where r.X_parent_id in' + (mStrings),mr2);
                                                if index=5 then  mbo_ServiceAssembyForms.ObjectSpace.SQLSelect('select distinct H.id from IssuedOrders H left join IssuedOrders2 R on r.parent_id=H.id where  ((H.docqueue_Id= ' + quotedstr('1Q10000101') + ') or(H.docqueue_Id= ' + quotedstr('2G20000101') +')) and r.X_parent_id in ' + (mStrings),mr2);
                                                if index=6 then  mbo_ServiceAssembyForms.ObjectSpace.SQLSelect('select distinct H.id from IssuedOrders H left join IssuedOrders2 R on r.parent_id=H.id where H.docqueue_Id<> ' + quotedstr('1Q10000101') + ' and r.X_parent_id in ' + (mStrings),mr2);
                                                if index=7 then  mbo_ServiceAssembyForms.ObjectSpace.SQLSelect('select distinct H.id from StoreDocuments H left join StoreDocuments2 R on r.parent_id=H.id where DocumentType=' + quotedstr('21') + ' and r.X_parent_id in ' + (mStrings),mr2);
                                                if index=8 then  mbo_ServiceAssembyForms.ObjectSpace.SQLSelect('select distinct H.id from issuedinvoices H left join issuedinvoices2 R on r.parent_id=H.id where r.X_parent_id in ' + (mStrings),mr2);
                                                if index=9 then  mbo_ServiceAssembyForms.ObjectSpace.SQLSelect('select distinct H.id from StoreDocuments H left join StoreDocuments2 R on r.parent_id=H.id where DocumentType=' + quotedstr('20') + ' and r.X_parent_id in ' + (mStrings),mr2);
                                                if index=10 then  mbo_ServiceAssembyForms.ObjectSpace.SQLSelect('select distinct H.id from StoreDocuments H left join StoreDocuments2 R on r.parent_id=H.id where DocumentType=' + quotedstr('22') + ' and r.X_parent_id in ' + (mStrings),mr2);



                                                mtext:='Připojené doklady k ' + mbo_ServiceAssembyForms.GetFieldValueAsString('ServiceDocument_ID.DocQueue_ID.code') + '-' +
                                                  inttostr(mbo_ServiceAssembyForms.GetFieldValueAsinteger('ServiceDocument_ID.ordnumber')) + '/' +
                                                  mbo_ServiceAssembyForms.GetFieldValueAsString('ServiceDocument_ID.Period_id.code') + '-' +
                                                  inttostr(mbo_ServiceAssembyForms.GetFieldValueAsInteger('ordnumber'))  ;

                                                if mr2.count>0 then begin
                                                   if index=0 then ShowSelectedDynForm(msite, mr2, '5H5Q1YT0BNE45EFK3SPKR4AD4S', mtext);// montážní
                                                   if index=1 then ShowSelectedDynForm(msite, mr2, 'NHT5Z3GSFFQ4F024JRFLUNOS30', mtext);// servisní
                                                   if index=2 then msite.ShowSite('2PFD3PM4JRR4V1SDHPQO0MKND4',true,'FilterByUserDynsqlCondition;a.id='+Quotedstr(mr2.strings[0])+';Omezeni');
                                                   //if index=3 then ShowSelectedDynForm(msite, mr2, '5H5Q1YT0BNE45EFK3SPKR4AD4S', mtext);
                                                   if index=4 then ShowSelectedDynForm(msite, mr2, 'O1C4ERBIVNIOT4WASH5MYY14CK', mtext);    // cenová nabídka
                                                   if index=5 then ShowSelectedDynForm(msite, mr2, 'GF53HAH3WBDL3C5P00CA141B44', mtext);    // objednávka
                                                   if index=6 then ShowSelectedDynForm(msite, mr2, 'GF53HAH3WBDL3C5P00CA141B44', mtext);    // objednávka
                                                   if index=7 then ShowSelectedDynForm(msite, mr2, 'B50I5SAOS3DL3ACU03KIU0CLP4', mtext);    // vyskladnění
                                                   if index=8 then ShowSelectedDynForm(msite, mr2, 'PLC2EX0BUJD13ACP03KIU0CLP4', mtext);    // faktury vydané
                                                   if index=9 then ShowSelectedDynForm(msite, mr2, 'B10I5SAOS3DL3ACU03KIU0CLP4', mtext);    // příjemky
                                                   if index=10 then ShowSelectedDynForm(msite, mr2, 'BD0I5SAOS3DL3ACU03KIU0CLP4',mtext);   // převodky výdek

                                               end else begin
                                                    NxShowSimpleMessage('Pro aktivitu  ještě nebyl vytvořen aktuální doklad.',nil);
                                                end;

                                           finally
                                              mr2.free;
                                           end;




end;

begin
end.