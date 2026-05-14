  procedure EDITSLExecuteItem(Sender: Tcomponent; Index: integer);
 var
xSite: TDynSiteForm;
mDBGrid : TDBGrid;
mTabList: TTabSheet;
mBookmark : TBookmarkList;
mr:TStringList;
mbo:TNxCustomBusinessObject;
mBO_ml,mBONew_ML:TNxCustomBusinessObject;
mRows_ML,mRows_Source_ML: TNxCustomBusinessMonikerCollection;
 i,mI_ML:integer;
 mrow:TNxCustomBusinessObject;
 m_pocet,m_objednano:double;
 mI_Result:integer;
 mBO_target : TNxCustomBusinessObject;
  mMon : TNxCustomBusinessMonikerCollection;
  mBO_source : TNxCustomBusinessObject;
  mMon_source : TNxCustomBusinessMonikerCollection;
  mID_source_BO:string;  mOLE: Variant;
  mAgenda: Variant;
  mSresult:string;
  mID_ML:string;
 begin
    xSite := TComponent(Sender).DynSite;
    mTabList := TTabSheet(NxFindChildControl(xSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    mOLE := GetAbraOLEApplication;

    mAgenda := mOLE.GetAgenda('5H5Q1YT0BNE45EFK3SPKR4AD4S'); // agenda clsid&#xD;
    mID_source_BO := mAgenda.SingleSelect2('', '');  // QueryAll&#xD;
    if  nxisemptyoid(mID_source_BO) then begin
         NxShowSimpleMessage('Není zadán zdroj pro naplnění vybraných ML, operace bude přerušena',nil);
    end else begin
        mBO_source:= xsite.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
          mr:=tstringlist.Create;
          try
             xsite.BaseObjectSpace.sqlselect('select id from ServiceAssemblyForms2 where parent_id=' + quotedstr(mID_source_BO) + ' and ItemType=1',mr);
             if mr.count>0 then begin


                      if mBookmark.count=0 then begin

                                                    mBO_target:= TDynSiteForm(xSite).CurrentObject;
                                                    try
                                                        mSresult:=NewImportRowML(mr,mBO_target,index);
                                                        mID_ML:=mBO_target.oid;
                                                    finally
                                                        mbo_ml.free;
                                                    end;

                          end else begin
                              for mI_ML:= 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
                                 mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(mI_ML));
                                 mBO_target:= TDynSiteForm(xSite).CurrentObject;
                                                  try
                                                      mBO_ML:= mbo;
                                                      mSresult:=NewImportRowML(mr,mBO_target,index);
                                                      mID_ML:=mBO_target.oid;
                                                  finally
                                                      mbo_ml.free;
                                                  end;
                              end;
                         end;




             end;
          finally
             mr.free;
          end;
     end;


 if mBookmark.count=0 then begin
      mdbgrid.Refresh;
      xsite.RefreshData;
      xsite.ActiveDataSet.RefreshAndRestoreLastSelectedItem;
      xsite.ActiveDataSet.seekid(mID_ML);

   end else begin
         //mI_Result:=Mformx(xsite,'Upozornění.','Je označeno více záznamů!', 'Ponechat výběr','','','Zrušit výběr');
                      for mI_ML := 0 to mBookmark.Count- 1 do begin
                          mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(mI_ML));
                          mBO:= TDynSiteForm(xSite).CurrentObject;
                          //xsite.ActiveDataSet.SeekID(mbo.OID);
                          mdbgrid.SelectRows_1(mbo.oid);
                      end;
   end;


 end;




 function NewImportRowML(mr: TStringList;mBO_target: TNxCustomBusinessObject;index:integer): string;
var
  i, mPosIndex: integer;
  mMon_target: TNxCustomBusinessMonikerCollection;
  mRow, mNewRow: TNxCustomBusinessObject;
  mList: TStringList;
  mText: string;
begin
  result := '';
  try


      mMon_target:= mBO_target.GetLoadedCollectionMonikerForFieldCode(mBO_target.GetFieldCode('ROWS'));
      for i := 0 to mr.Count-1 do begin
        mRow := mbo_target.ObjectSpace.CreateObject('T3S00IN35IV4D0M3AQ0Y10CDFC');
        mrow.load(mr.strings[i],nil) ;
        mNewRow := mMon_target.AddNewObject;
        mNewRow.SetFieldValueAsInteger('Itemtype', mRow.GetFieldValueAsInteger('Itemtype'));
        mNewRow.SetFieldValueAsInteger('ToInvoiceType', mRow.GetFieldValueAsInteger('ToInvoiceType'));
        mNewRow.SetFieldValueAsString('Store_ID', mRow.GetFieldValueAsString('Store_ID'));
        mNewRow.SetFieldValueAsString('StoreCard_ID', mRow.GetFieldValueAsString('StoreCard_ID'));
        mNewRow.SetFieldValueAsString('Text', mRow.GetFieldValueAsString('Text'));
        mNewRow.SetFieldValueAsString('QUnit', mRow.GetFieldValueAsString('QUnit'));
        mNewRow.SetFieldValueAsFLoat('UnitRate', mRow.GetFieldValueAsFloat('UnitRate'));
        mNewRow.SetFieldValueAsFLoat('Quantity', mRow.GetFieldValueAsFloat('Quantity'));

        mNewRow.SetFieldValueAsString('Workerrole_ID', mRow.GetFieldValueAsString('Workerrole_ID'));
        mNewRow.SetFieldValueAsString('X_Workerrole_ID', mRow.GetFieldValueAsString('X_Workerrole_ID'));
        mNewRow.SetFieldValueAsBoolean('X_storno1', mRow.GetFieldValueAsBoolean('X_storno1'));
        mNewRow.SetFieldValueAsBoolean('X_storno', mRow.GetFieldValueAsBoolean('X_storno'));
        mNewRow.SetFieldValueAsFLoat('X_radkova_sleva', mRow.GetFieldValueAsFloat('X_radkova_sleva'));
        mNewRow.SetFieldValueAsFLoat('UnitPriceWithoutVAT', mRow.GetFieldValueAsFloat('UnitPriceWithoutVAT'));
        mNewRow.SetFieldValueAsFLoat('UnitPriceWithVAT', mRow.GetFieldValueAsFloat('UnitPriceWithVAT'));

        mNewRow.SetFieldValueAsFLoat('TotalPriceWithoutVAT', mRow.GetFieldValueAsFloat('TotalPriceWithoutVAT'));
        mNewRow.SetFieldValueAsFLoat('TotalPriceWithVAT', mRow.GetFieldValueAsFloat('TotalPriceWithVAT'));


        mNewRow.SetFieldValueAsString('X_description', mRow.GetFieldValueAsstring('X_description'));

      end;
      mMon_target.SaveAll;
    mBO_target.ClearValidateErrors;
    if Not mBO_target.Validate() then begin
      mList := TStringList.Create;
      try
        mBO_target.GetValidateErrors(mList);
        mText := mList.Text;
        NxToken(mText, '=');
        MessageDlg('Import ML nelze uložit z těchto důvodů:' + #13#10 + mText,
          mtWarning, [mbOK], 0);
      finally
        mList.Free;
      end;
    end else begin
      mBO_target.Save;
      result := mBO_target.OID;
    end;
  finally
    mBO_target.Free;
  end;
end;


procedure InitSite_Hook(Self: TSiteForm);
var
mAction: TAction;
  mMAction,mMAction1: TMultiAction;
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

   mMAction1 := Self.GetNewMultiAction;
  mMAction1.ShowControl := True;
  mMAction1.ShowMenuItem := True;
  mMAction1.Caption := 'Import materiálu z ML';
  mMAction1.Hint := 'Import materiálu z ML';
  mMAction1.Category := 'tabList';
  mMAction1.OnExecuteItem := @EDITSLExecuteItem;
  mMAction1.Items.Add('Import materiálu z ML');



end;






begin
end.