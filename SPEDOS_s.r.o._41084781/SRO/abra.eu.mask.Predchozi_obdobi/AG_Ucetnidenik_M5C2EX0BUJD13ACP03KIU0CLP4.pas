
var
    mFSazba_hod_den,mFDoprava_km,mF_doprava_pausal,mFSazba_hod:double;
    mBO_BusProject:TNxCustomBusinessObject;
    mF_pausal_prace,mF_pausal_Vyjezd,mF_prace,mF_km:double;
    // doby + termíny
    mF_doba:double;
    mRows : TNxCustomBusinessMonikerCollection;
    result:boolean;
    mresult:boolean;
    aaa:Boolean;
      mBookmark : TBookmarkList;


procedure Pred_obdxecuteItem(Sender: TMultiAction; Index: integer);
var
 mresult:string;
 mtext:string;
 mImportMan:TNxDocumentImportManager;
 mbo:TNxCustomBusinessObject;
 mSite: TDynSiteForm;
  mDBGrid : TDBGrid;
    mTabList: TTabSheet;
  self:TNxCustomBusinessObject;
  i,ii:integer;
  mlist,mr,mIDs_OVRow:TStringList;
  mInputParams: TNxParameters;
  mParam: TNxParameter;
   mForm: TDynSiteForm;
   mMon,mMon_source: TNxCustomBusinessMonikerCollection;
   mBO_target,mBO_source,mRow, mNewRow,mbo1: TNxCustomBusinessObject;
   mdate:Double;
   mPosIndex:integer;
   mCislo:integer;
   mstav_skladu:boolean;
   mstore_ID:string;
   mID:string;
   mOLE, mRoll, mOResult: Variant;
   mids:TStringList;
begin

mSite := TComponent(Sender).DynSite;
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    mForm := TComponent(Sender).DynSite;
    mList := TStringList.Create;


    try
        mBO_target:= TDynSiteForm(mSite).CurrentObject.ObjectSpace.CreateObject('KEXFTIIK4ZD13ACL03KIU0CLP4');
                                            mBO_target.New;
                                            mBO_target.Prefill;
                                            //mBO_target.SetFieldValueAsString('Firm_ID', '2LL4000101');
                                            mBO_target.SetFieldValueAsString('DocQueue_ID', 'IM00000101');

                  mMon := mBO_target.GetLoadedCollectionMonikerForFieldCode(mBO_target.GetFieldCode('ROWS'));

                       if mBookmark.count=0 then begin

                                                        mNewRow := mMon.AddNewObject;
                                                        mNewRow.SetFieldValueAsString('DebitAccount_ID', TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('CreditAccount_ID'));
                                                        mNewRow.SetFieldValueAsString('DebitBusOrder_ID', TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('CreditBusOrder_ID'));
                                                        mNewRow.SetFieldValueAsString('DebitBusProject_ID', TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('CreditBusProject_ID'));
                                                        mNewRow.SetFieldValueAsString('DebitBusTransaction_ID', TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('CreditBusTransaction_ID'));
                                                        mNewRow.SetFieldValueAsString('DebitDivision_ID', TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('CreditDivision_ID'));
                                                        mNewRow.SetFieldValueAsString('CreditAccount_ID', TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('DebitAccount_ID'));
                                                        mNewRow.SetFieldValueAsString('CreditBusOrder_ID', TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('DebitBusOrder_ID'));
                                                        mNewRow.SetFieldValueAsString('CreditBusProject_ID', TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('DebitBusProject_ID'));
                                                        mNewRow.SetFieldValueAsString('CreditBusTransaction_ID', TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('DebitBusTransaction_ID'));
                                                        mNewRow.SetFieldValueAsString('CreditDivision_ID', TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('DebitDivision_ID'));
                                                        mNewRow.SetFieldValueAsFloat('LocalTAmount', TDynSiteForm(mSite).CurrentObject.GetFieldValueAsFloat('Amount'));
                                                        mNewRow.SetFieldValueAsFloat('TAmount', TDynSiteForm(mSite).CurrentObject.GetFieldValueAsFloat('AmountInCurrency'));
                                                        mNewRow.SetFieldValueAsString('Text', TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Text'));



                        end else begin
                             for i := 0 to mbookmark.Count-1 do begin
                                  mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));

                                  mNewRow := mMon.AddNewObject;
                                                        mNewRow.SetFieldValueAsString('DebitAccount_ID', TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('CreditAccount_ID'));
                                                        if copy(mNewRow.getFieldValueAsString('DebitAccount_ID.code'),1,2)<>'38' then  mNewRow.SetFieldValueAsString('DebitAccount_ID','');
                                                        mNewRow.SetFieldValueAsString('DebitBusOrder_ID', TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('CreditBusOrder_ID'));
                                                        mNewRow.SetFieldValueAsString('DebitBusProject_ID', TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('CreditBusProject_ID'));
                                                        mNewRow.SetFieldValueAsString('DebitBusTransaction_ID', TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('CreditBusTransaction_ID'));
                                                        mNewRow.SetFieldValueAsString('DebitDivision_ID', TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('CreditDivision_ID'));
                                                        mNewRow.SetFieldValueAsString('CreditAccount_ID', TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('DebitAccount_ID'));
                                                        if copy(mNewRow.getFieldValueAsString('CreditAccount_ID.code'),1,2)<>'38' then  mNewRow.SetFieldValueAsString('CreditAccount_ID','');
                                                        mNewRow.SetFieldValueAsString('CreditBusOrder_ID', TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('DebitBusOrder_ID'));
                                                        mNewRow.SetFieldValueAsString('CreditBusProject_ID', TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('DebitBusProject_ID'));
                                                        mNewRow.SetFieldValueAsString('CreditBusTransaction_ID', TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('DebitBusTransaction_ID'));
                                                        mNewRow.SetFieldValueAsString('CreditDivision_ID', TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('DebitDivision_ID'));
                                                       mNewRow.SetFieldValueAsFloat('LocalTAmount', TDynSiteForm(mSite).CurrentObject.GetFieldValueAsFloat('Amount'));
                                                        mNewRow.SetFieldValueAsFloat('TAmount', TDynSiteForm(mSite).CurrentObject.GetFieldValueAsFloat('AmountInCurrency'));
                                                        mNewRow.SetFieldValueAsString('Text', TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Text'));


                             end;
                        end;

                         TDynSiteForm.ShowDynFormWithNewDocument('MDC2EX0BUJD13ACP03KIU0CLP4', mForm.SiteContext, mBO_target);

    finally
       mBO_target.free;

    end;
   //TDynSiteForm(mSite).RefreshData;
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
  mMAction.Caption := 'Předchozí období';
  mMAction.Hint := 'Předchozí období';
  mMAction.Category := 'tabList';
  mMAction.OnExecuteItem := @Pred_obdxecuteItem;
  mMAction.Items.Add('Předchozí období');




end;


begin
end.