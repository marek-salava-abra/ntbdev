
Var
mbo:TNxCustomBusinessObject;
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
  mMAction.Caption := 'Dohledání pohybu';
  mMAction.Hint := 'Dohledání pohybu';
  mMAction.Category := 'tablist,tabdetail';
  mMAction.OnExecuteItem := @ShowDocExecuteItem;

  mMAction.Items.Add('Prodejní pohyb šarže');
  mMAction.Items.Add('Vratka - pohyb šarže');

end;


 procedure ShowDocExecuteItem(Sender: TAction; Index: integer);
var
 L ,mx: TStringList;
 mid:string;
 mPars:TNxParameters;
 mPar:TNxParameter;
 msite:TBusRollSiteForm;
 mr2:TStringList;
 mMon : TNxCustomBusinessMonikerCollection;
 mStrings:string;
 i:integer;
   mOLE, mRoll,mAgenda, mOResult: Variant;
  mids1:tstringlist;
  mids: TStringList;
  mB:boolean;
  mSelected ,_ss:Variant;
 mstring:string;
 mBoolean:boolean;
 mBOPohyb:TNxCustomBusinessObject;
begin
  mSite := TComponent(sender).BusRollSite;
 mbo:=TBusRollSiteForm(mSite).CurrentObject;

  mOLE := GetAbraOLEApplication;
                                                            mroll := mOLE.GetAgenda('S1X0KZC0NJE13C5U00CA141B44');
                                                            mSelected := mOLE.CreateStrings;



                                                            mr2:=TStringList.create;
                                                                  try
                                                                        mbo.ObjectSpace.SQLSelect('SELECT a.id FROM DocRowBatches A JOIN StoreDocuments2 SD2 ON SD2.ID=A.Parent_ID JOIN StoreDocuments SD ON SD.ID=SD2.Parent_ID JOIN Firms F ON F.ID=SD.Firm_ID '
                                                                            + ' WHERE (SD.DocQueue_ID IN (SELECT ID FROM  DocQueues WHERE DocumentType IN (''21'',''23'')) ) AND ((F.ID='
                                                                             + QuotedStr(mbo.GetFieldValueAsString('X_firm_ID')) + ') OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='
                                                                              + QuotedStr(mbo.GetFieldValueAsString('X_firm_ID')) + '))) AND  '
                                                                              + '(A.StoreBatch_ID = ' + QuotedStr(mbo.GetFieldValueAsString('X_Batches')) + ' )',mr2);
                                                                         for i := 0 to mr2.Count - 1 do begin
                                                                             mSelected.Add(mr2.Strings[i]);
                                                                         end;
                                                                  finally
                                                                      mr2.free;
                                                                  end;

                                                               mstring:= mroll.SingleSelectFromSelected2(mSelected, 'Firma ' + mbo.GetFieldValueAsString('X_Firm_ID.name')  + ' , pohyb šarže: +' + mbo.GetFieldValueAsString('X_batches.name') , '');

                                                           if mstring<>'' then begin
                                                               mBOPohyb:=mbo.ObjectSpace.CreateObject('K3TH0HR5TZDL342W01C0CX3FCC');
                                                               try
                                                                     mBOPohyb.Load(mstring,nil);
                                                                       if index=0 then begin
                                                                             mr2:=TStringList.create;
                                                                             try
                                                                                 mbo.ObjectSpace.SQLSelect('Select ii2.parent_id from IssuedInvoices2 ii2 where ii2.ProvideRow_ID=' + quotedstr(mBOPohyb.GetFieldValueAsstring('Parent_ID')) ,mr2);
                                                                                 if mr2.count>0 then begin
                                                                                       TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_parent_ID',mr2.Strings[0]);
                                                                                 end;
                                                                             finally
                                                                                 mr2.free;
                                                                             end;

                                                                             mr2:=TStringList.create;
                                                                             try
                                                                                 mbo.ObjectSpace.SQLSelect('Select ii2.id from IssuedInvoices2 ii2 where ii2.ProvideRow_ID=' + quotedstr(mBOPohyb.GetFieldValueAsstring('Parent_ID')) ,mr2);
                                                                                 if mr2.count>0 then begin
                                                                                      TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_parent2_id',mr2.Strings[0]);
                                                                                 end;
                                                                             finally
                                                                                 mr2.free;
                                                                             end;

                                                                                 TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_DEVENOLUX',mBOPohyb.GetFieldValueAsString('Parent_ID.Parent_ID'));
                                                                                 TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_MX_NAZEV',mBOPohyb.GetFieldValueAsstring('Parent_ID'));
                                                                                 TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_DE_NAZEV',mBOPohyb.oid);
                                                                                 TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_vychystano',mBOPohyb.GetFieldValueAsFloat('Quantity'));
                                                                                 TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_PM_State','1050000101');
                                                                                 TBusRollSiteForm(mSite).CurrentObject.save;
                                                                       end;
                                                                       if index=1 then begin
                                                                             TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_EN_NAZEV',mBOPohyb.oid);
                                                                             TBusRollSiteForm(mSite).CurrentObject.save;
                                                                       end;
                                                               finally
                                                                   mBOPohyb.free;
                                                               end;
                                                         end;




end;

begin
end.








