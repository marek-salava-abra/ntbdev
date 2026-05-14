var
    mFSazba_hod_den,mFDoprava_km,mF_doprava_pausal,mFSazba_hod:double;
    mBO_BusProject:TNxCustomBusinessObject;
    mF_pausal_prace,mF_pausal_Vyjezd,mF_prace,mF_km:double;
    // doby + termíny
    mF_doba:double;
    mRows : TNxCustomBusinessMonikerCollection;
    result:boolean;
    mresult:boolean;
      mBookmark : TBookmarkList;
    mBustrasaction_ID:string;





    procedure FVExecuteItem(Sender: TAction; Index: integer);
var
 mresult:Boolean;
 mtext:string;
 mbo:TNxCustomBusinessObject;
 mSite: TSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 self,mBO_BV:TNxCustomBusinessObject;
 i,ii:integer;
  mr,mIDs_MLRow:TStringList;
   mForm: TDynSiteForm;
   mMon: TNxCustomBusinessMonikerCollection;
   mRow, mNewRow,mbo1: TNxCustomBusinessObject;
   mdate:Double;
   mr2:tstringlist;
   mi:integer;
begin
  mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
    mBO_BV:=msite.BaseObjectSpace.CreateObject('O3SCO4S1BRD13FY1010DELDFKK');
    try
            mBO_BV.new;
            mBO_BV.Prefill;
             if index=0 then begin
                mBO_BV.SetFieldValueAsString('BankAccount_ID','3100000101');
                mBO_BV.SetFieldValueAsString('DocQueue_ID','1K10000101');
            end;

            if index=1 then begin
                mBO_BV.SetFieldValueAsString('BankAccount_ID','5300000101');
                mBO_BV.SetFieldValueAsString('DocQueue_ID','4J20000101');
            end;


            mMon := mBO_BV.GetLoadedCollectionMonikerForFieldCode(mBO_BV.GetFieldCode('ROWS'));


            mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
                  try
                          if mBookmark.count=0 then begin                 // pro aktuální záznam
                             mBO := TDynSiteForm(mSite).CurrentObject;
                                     mNewRow := mMon.AddNewObject;
                                              mNewRow.Prefill;
                                              mNewRow.SetFieldValueAsBoolean('Credit', False);
                                              mNewRow.SetFieldValueAsString('VarSymbol', TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('VarSymbol'));
                                              mNewRow.SetFieldValueAsString('PDocumentType','04');
                                              mNewRow.SetFieldValueAsString('PDocument_ID',TDynSiteForm(mSite).CurrentObject.oid);
                                              mNewRow.SetFieldValueAsString('Firm_ID',TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('firm_ID'));
                                              //mNewRow.SetFieldValueAsFloat('PAmount',TDynSiteForm(mSite).CurrentObject.GetFieldValueAsFloat('NotPaidAmount'));
                                              //mNewRow.SetFieldValueAsFloat('LocalPAmount',TDynSiteForm(mSite).CurrentObject.GetFieldValueAsFloat('LocalNotPaidAmount'));

                          end else begin
                                  for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy           // pro ozbačené záznamy
                                          mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));

                                          mBO := TDynSiteForm(mSite).CurrentObject;
                                          mNewRow := mMon.AddNewObject;
                                              mNewRow.Prefill;
                                              mNewRow.SetFieldValueAsBoolean('Credit', False);
                                              mNewRow.SetFieldValueAsString('VarSymbol', TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('VarSymbol'));
                                              mNewRow.SetFieldValueAsString('PDocumentType','04');
                                              mNewRow.SetFieldValueAsString('PDocument_ID',TDynSiteForm(mSite).CurrentObject.oid);
                                              mNewRow.SetFieldValueAsString('Firm_ID',TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('firm_ID'));
                                              //mNewRow.SetFieldValueAsFloat('PAmount',TDynSiteForm(mSite).CurrentObject.GetFieldValueAsFloat('NotPaidAmount'));
                                              //mNewRow.SetFieldValueAsFloat('LocalPAmount',TDynSiteForm(mSite).CurrentObject.GetFieldValueAsFloat('LocalNotPaidAmount'));



                                  end;
                          end;
                      finally

                      end;

    mBO_BV.save;
    finally
       mbo_bv.free;
    end;
end;







procedure InitSite_Hook(Self: TSiteForm);
var
mAction: TAction;
  mMAction: TMultiAction;
  mUserFilter: Boolean;
  mUser: TNxCustomBusinessObject;
begin
  mUserFilter:=false;
  mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');            // přihlášený uživatel
  try
      mUser.Load(Self.CompanyCache.GetUserID, nil);
            if mUser.GetFieldValueAsString('Name')='Supervisor' then mUserFilter:= true;
  finally
    mUser.Free;
  end;


   mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Platba BV';
  mMAction.Hint := 'Platba BV';
  mMAction.Category := 'tabList';
//  mMAction.OnUpdate := @FVOnExekute;
  mMAction.OnExecuteItem := @FVOnExekute;
  mMAction.Items.Add('Platba CZ');
  mMAction.Items.Add('Platba Eur');


end;

procedure FVOnExekute(Sender: TAction;index:integer;);
begin
FVExecuteItem(sender,index);

end ;



begin
end.