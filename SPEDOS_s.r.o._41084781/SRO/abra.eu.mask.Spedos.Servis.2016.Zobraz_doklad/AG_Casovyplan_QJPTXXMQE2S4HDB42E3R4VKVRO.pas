  uses 'abra.eu.mask.Spedos.Servis.2016.Zobraz_doklad.lib';

Var
mbo_CRM_activities:TNxCustomBusinessObject;
mbo_ServiceAssembyForms:TNxCustomBusinessObject;
mbo_ServiceAssembyFormRows:TNxCustomBusinessObject;
mr:tstringlist;
mID:string;
mtext:string;



procedure ShowMLExecuteItem(Sender: Tcomponent; Index: integer);
var
 mSite:TsiteForm;
 mList, mList2:TStringList;
 mParams: TNxParameters;
  mParam: TNxParameter;
  mcaption:string;
  mr:TStringList;
  m_workSpace_id:string;
begin
  mSite := TComponent(Sender).Site;
  mr:=TStringList.create;
  try
   msite.BaseObjectSpace.SQLSelect('select X_workSpace_id from SecurityUsers where id=' + quotedstr(msite.SiteContext.GetCompanyCache.GetUserID),mr);
     if mr.count>0 then begin
         m_workSpace_id:=mr.Strings[0];
     end;
  finally
      mr.free;
  end;


  mList :=TStringList.create;
  mList2 := TstringList.Create;
  if Assigned(msite) then begin
      msite.List.GetSelectedId(mList);
      // bez technika
         msite.BaseObjectSpace.SQLSelect('select distinct H.id from ServiceAssemblyForms H left join ServiceAssemblyForms2 R on r.parent_id=H.id left join CRMActivities CRM on crm.X_parent_head=h.id where crm.id=' + quotedstr(mlist.Strings[0]),mlist2);
         mcaption:='Aktuální ML ';
      if mlist2.Count>0 then begin
        mParams := TNxParameters.Create;
       try
        mParams.NewFromDataType(dtString, '_SelectionCaption', pkUnknown).AsString := mcaption;
        mParam := mParams.NewFromDataType(dtList, '_DefaultSelection', pkUnknown) ;
        mParam := mParam.AsList.NewFromDataType(dtList, 'CONDITIONS', pkUnknown) ;
        mParam := mParam.AsList.NewFromDataType(dtList, 'ID', pkUnknown) ;
        mParam.AsList.NewFromDataType(dtInteger, 'USEDKIND', pkUnknown).AsInteger := 3; //3 = ckList&#xD;
        mParam.AsList.NewFromDataType(dtString, 'VALUELIST', pkUnknown).AsString := NxStringsToCkListStr(mList2);
        ShowDynForm('5H5Q1YT0BNE45EFK3SPKR4AD4S',msite.SiteContext, mParams, nil, true);
       finally
        mParams.free;
       end;


      end;
 end;
end;




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

  {
    mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Připojené doklady';
  mMAction.Hint := 'Doklady servisu';
  mMAction.Category := 'tabmain';
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
                                          }
     mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Servisní list';
  mMAction.Hint := 'Servisní list';
  mMAction.Category := 'tabmain';
  mMAction.OnExecuteItem := @ShowSLExecuteItem;
  mMAction.Items.Add('Servisní list');

     mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Montážní list';
  mMAction.Hint := 'Montážní list';
  mMAction.Category := 'tabmain';
  mMAction.OnExecuteItem := @ShowMLExecuteItem;
  mMAction.Items.Add('Montážní list');

end;



{
Vyvolává se po nastavení výchozích vlastností formuláře.
}
procedure SetDefaultProperties_Hook(Self: TSiteForm);
begin

end;

{
Vyvolává se při ukládání vlastností formuláře.
}
procedure SavingProperties_Hook(Self: TSiteForm; AParams: TNxParameters);
begin

end;

 procedure ShowDocExecuteItem(Sender: Tcomponent; Index: integer);
var
 L : TStringList;
 mid:string;
 mParams: TNxParameters;
  mParam: TNxParameter;
  mcaption:string;
 msite:TSiteForm;
 mr2:TStringList;
 mMon : TNxCustomBusinessMonikerCollection;
 mStrings:string;
 i:integer;
begin
 {mSite := TComponent(Sender).Site;
    L := TStringList.Create();
        try

            Sender.Site.List.GetSelectedID(L);
            if Length(trim(l.Text))=10 then begin

                     mr:=tstringlist.create;
                     try
                                     msite.BaseObjectSpace.SQLSelect('select distinct H.ID from ServiceAssemblyForms H left join ServiceAssemblyForms2 R on r.parent_id=H.id left join CRMActivities CRM on crm.X_parent_head=h.id where crm.id=' + quotedstr(l.Strings[0]),mr);

                                     if mr.count>0 then begin
                                          mbo_ServiceAssembyForms:=msite.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                                          mbo_ServiceAssembyForms.load(mr.Strings[0],nil);
                                            if mr.count>0 then begin
                                                mStrings:='(';
                                               for i:=0 to mr.count-1 do begin
                                                          if i>0 then mStrings:= mStrings + ',';
                                                          mStrings:= mStrings + quotedstr(mr.Strings[i]);

                                                end;
                                                mStrings:= mStrings +')';
                                             end;
                                     end;

                                   mr2:=TStringList.create;
                        {           try
                                        if index=0 then  msite.BaseObjectSpace.SQLSelect('select distinct H.ID from ServiceAssemblyForms H left join ServiceAssemblyForms2 R on r.parent_id=H.id left join CRMActivities CRM on crm.X_parent_head=h.id where crm.id=' + quotedstr(l.Strings[0]),mr2);
                                        if index=1 then   msite.BaseObjectSpace.SQLSelect('select distinct H.ServiceDocument_ID from ServiceAssemblyForms H left join ServiceAssemblyForms2 R on r.parent_id=H.id left join CRMActivities CRM on crm.X_parent_head=h.id where crm.id=' + quotedstr(l.Strings[0]),mr2);
                                        if index=2 then   msite.BaseObjectSpace.SQLSelect('select distinct H.X_ServicedObject_ID from ServiceAssemblyForms H left join ServiceAssemblyForms2 R on r.parent_id=H.id left join CRMActivities CRM on crm.X_parent_head=h.id where crm.id=' + quotedstr(l.Strings[0]),mr2);
                                        //if index=3 then  mbo_ServiceAssembyForms.ObjectSpace.SQLSelect('select distinct H.id from issuedinvoices H left join issuedinvoices2 R on r.parent_id=H.id where r.X_parent_id=' + quotedstr(mbo_CRM_activities.GetFieldValueAsString('X_parent_ID')),mr2);
                                        if index=4 then  msite.BaseObjectSpace.SQLSelect('select distinct H.id from IssuedOffers H left join IssuedOffers2 R on r.parent_id=H.id left join CRMActivities CRM on crm.X_parent_head=h.id where crm.id=' + quotedstr(l.Strings[0]),mr2);
                                        if index=5 then  msite.BaseObjectSpace.SQLSelect('select distinct H.id from IssuedOrders H left join IssuedOrders2 R on r.parent_id=H.id left join CRMActivities CRM on crm.X_parent_head=h.id where crm.id=' + quotedstr(l.Strings[0] + ' AND ((H.docqueue_Id= ' + quotedstr('1Q10000101') + ') or(H.docqueue_Id= ' + quotedstr('2G20000101') +')) and r.X_parent_id in ' + (mStrings),mr2);
                                        if index=6 then  msite.BaseObjectSpace.SQLSelect('select distinct H.id from IssuedOrders H left join IssuedOrders2 R on r.parent_id=H.id left join CRMActivities CRM on crm.X_parent_head=h.id where crm.id=' + quotedstr(l.Strings[0] + ' AND H.docqueue_Id<> ' + quotedstr('1Q10000101') + ' and r.X_parent_id in ' + (mStrings),mr2);
                                        if index=7 then  msite.BaseObjectSpace.SQLSelect('select distinct H.id from StoreDocuments H left join StoreDocuments2 R on r.parent_id=H.id left join CRMActivities CRM on crm.X_parent_head=h.id where crm.id=' + quotedstr(l.Strings[0] + ' AND DocumentType=' + quotedstr('21') ,mr2);
                                        if index=8 then  msite.BaseObjectSpace.SQLSelect('select distinct H.id from issuedinvoices H left join issuedinvoices2 R on r.parent_id=H.id left join CRMActivities CRM on crm.X_parent_head=h.id where crm.id=' + quotedstr(l.Strings[0]),mr2);
                                        if index=9 then  msite.BaseObjectSpace.SQLSelect('select distinct H.id from StoreDocuments H left join StoreDocuments2 R on r.parent_id=H.id left join CRMActivities CRM on crm.X_parent_head=h.id where crm.id=' + quotedstr(l.Strings[0]) + ' AND  H.DocumentType=' + quotedstr('20'),mr2);
                                        if index=10 then  msite.BaseObjectSpace.SQLSelect('select distinct H.id from StoreDocuments H left join StoreDocuments2 R on r.parent_id=H.id where DocumentType=' + quotedstr('22') + ' and r.X_parent_id in ' + (mStrings),mr2);



                                        mcaption:='Připojené doklady k '
                                         + mbo_ServiceAssembyForms.GetFieldValueAsString('ServiceDocument_ID.DocQueue_ID.code') + '-' +
                                          inttostr(mbo_ServiceAssembyForms.GetFieldValueAsinteger('ServiceDocument_ID.ordnumber')) + '/' +
                                          mbo_ServiceAssembyForms.GetFieldValueAsString('ServiceDocument_ID.Period_id.code') + '-' +
                                          inttostr(mbo_ServiceAssembyForms.GetFieldValueAsInteger('ordnumber'))  ;

                                        if mr2.count>0 then begin
                                           mParams := TNxParameters.Create;
                                                try
                                              mParams.NewFromDataType(dtString, '_SelectionCaption', pkUnknown).AsString := mcaption;
                                              mParam := mParams.NewFromDataType(dtList, '_DefaultSelection', pkUnknown) ;
                                              mParam := mParam.AsList.NewFromDataType(dtList, 'CONDITIONS', pkUnknown) ;
                                              mParam := mParam.AsList.NewFromDataType(dtList, 'ID', pkUnknown) ;
                                              mParam.AsList.NewFromDataType(dtInteger, 'USEDKIND', pkUnknown).AsInteger := 3; //3 = ckList&#xD;
                                              mParam.AsList.NewFromDataType(dtString, 'VALUELIST', pkUnknown).AsString := NxStringsToCkListStr(mr2);




                                           if index=0 then ShowDynForm('5H5Q1YT0BNE45EFK3SPKR4AD4S',msite.SiteContext, mParams, nil, true);
                                           if index=1 then ShowDynForm('NHT5Z3GSFFQ4F024JRFLUNOS30',msite.SiteContext, mParams, nil, true);
                                           if index=2 then msite.ShowSite('2PFD3PM4JRR4V1SDHPQO0MKND4',true,'FilterByUserDynsqlCondition;a.id='+Quotedstr(mr2.strings[0])+';Omezeni');
                                            if index=4 then ShowDynForm('O1C4ERBIVNIOT4WASH5MYY14CK',msite.SiteContext, mParams, nil, true);
                                           if index=5 then ShowDynForm('GF53HAH3WBDL3C5P00CA141B44',msite.SiteContext, mParams, nil, true);
                                           if index=6 then ShowDynForm('GF53HAH3WBDL3C5P00CA141B44',msite.SiteContext, mParams, nil, true);
                                           if index=7 then ShowDynForm('B50I5SAOS3DL3ACU03KIU0CLP4',msite.SiteContext, mParams, nil, true);
                                           if index=8 then ShowDynForm('PLC2EX0BUJD13ACP03KIU0CLP4',msite.SiteContext, mParams, nil, true);
                                           if index=9 then ShowDynForm('B10I5SAOS3DL3ACU03KIU0CLP4',msite.SiteContext, mParams, nil, true);
                                           if index=10 then ShowDynForm('BD0I5SAOS3DL3ACU03KIU0CLP4',msite.SiteContext, mParams, nil, true);

                                            finally
                                            mParams.free;
                                           end;

                                       end else begin
                                            NxShowSimpleMessage('Pro aktivitu  ještě nebyl vytvořen aktuální doklad.',nil);
                                        end;

                                   finally
                                      mr2.free;
                                   end;

                          finally
                             mr.free;
                          end;


                          //  finally
                          //       mr.free;
                          //  end;


            end else begin
                    NxShowSimpleMessage('Není vybrána pouze jedna zdojová aktivita',nil);
            end;
        finally
            L.Free;
        end;      }
end;



procedure ShowSLExecuteItem(Sender:Tcomponent; Index: integer);
var
 mSite:TsiteForm;
 mList, mList2:TStringList;
 mParams: TNxParameters;
  mParam: TNxParameter;
  mcaption:string;
  mr:TStringList;
  m_workSpace_id:string;
begin
  mSite := TComponent(Sender).Site;
  mr:=TStringList.create;
  try
   msite.BaseObjectSpace.SQLSelect('select X_workSpace_id from SecurityUsers where id=' + quotedstr(msite.SiteContext.GetCompanyCache.GetUserID),mr);
     if mr.count>0 then begin
         m_workSpace_id:=mr.Strings[0];
     end;
  finally
      mr.free;
  end;


  mList :=TStringList.create;
  mList2 := TstringList.Create;
  if Assigned(msite) then begin
      msite.List.GetSelectedId(mList);
      // bez technika
         msite.BaseObjectSpace.SQLSelect('select distinct H.ServiceDocument_ID from ServiceAssemblyForms H left join ServiceAssemblyForms2 R on r.parent_id=H.id left join CRMActivities CRM on crm.X_parent_head=h.id where crm.id=' + quotedstr(mlist.Strings[0]),mlist2);
         mcaption:='Aktuální SL ';
      if mlist2.Count>0 then begin
        mParams := TNxParameters.Create;
       try
        mParams.NewFromDataType(dtString, '_SelectionCaption', pkUnknown).AsString := mcaption;
        mParam := mParams.NewFromDataType(dtList, '_DefaultSelection', pkUnknown) ;
        mParam := mParam.AsList.NewFromDataType(dtList, 'CONDITIONS', pkUnknown) ;
        mParam := mParam.AsList.NewFromDataType(dtList, 'ID', pkUnknown) ;
        mParam.AsList.NewFromDataType(dtInteger, 'USEDKIND', pkUnknown).AsInteger := 3; //3 = ckList&#xD;
        mParam.AsList.NewFromDataType(dtString, 'VALUELIST', pkUnknown).AsString := NxStringsToCkListStr(mList2);
        ShowDynForm('NHT5Z3GSFFQ4F024JRFLUNOS30',msite.SiteContext, mParams, nil, true);
       finally
        mParams.free;
       end;


      end;
 end;
end;





begin
end.