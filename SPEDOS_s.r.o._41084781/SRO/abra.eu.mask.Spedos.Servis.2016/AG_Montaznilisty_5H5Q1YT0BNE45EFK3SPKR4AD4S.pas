  uses 'abra.eu.mask.Spedos.Servis.2016_funkce.const',
       'abra.eu.mask.Spedos.Servis.2016_funkce.funkce';


var
xSite: TDynSiteForm;
mDBGrid : TDBGrid;
mTabList: TTabSheet;
mBookmark : TBookmarkList;
mbo,mBO_SL,mBONew_SL:TNxCustomBusinessObject;
mBO_SecurityRole:TNxCustomBusinessObject;
mBO_BusProject:TNxCustomBusinessObject;
mBO_ml,mbo_ml1,mBONew_ML:TNxCustomBusinessObject;
mRows_ML,mRows_ML1: TNxCustomBusinessMonikerCollection;
mOLE_SP, mRoll_SP, mOResult_SP: Variant;
mOLE_SL, mRoll_SL, mOResult_SL: Variant;
mOLE_SML, mRoll_SML, mOResult_SML: Variant;
mOLE_ML, mRoll_ML, mOResult_ML: Variant;
mOLE_WorkerRole, mRoll_WorkerRole, mOResult_WorkerRole: Variant;
mIDs_SP,mIDs_SL,mIDs_ML,mIDs_MLRow,mIDs_WorkerRole,mIDs_Storecard:tstringlist;
mID_SP,mID_SL,mID_ML,mID_MLRow:string;
mID_WorkerRole,mID_Store,mID_StoreCard,mid_workSpace:string;
mI_SP,mI_SL,mI_ML,mI_MLRow:integer;
mML_State_ID,mOrigML_State_ID :string;
mD_ML_start,mD_ML_End,mD_SL_start,mD_SL_End,mD_CRM_start,mD_CRM_End:double;



procedure iFillDocqueue(AOS : TNxCustomObjectSpace; AList : Tstrings;aname:string);
  const
    cSQL = 'SELECT Name FROM DocQueues WHERE Hidden=''N'' and DocumentType=''%s'' ORDER BY Name';
  begin
    AOS.SQLSelect(format(cSQL,[aname]), AList);
//    NxShowSimpleMessage(format(cSQL,[aname]),nil);
  end;

  procedure iFillDocqueue_code(AOS : TNxCustomObjectSpace; AList : Tstrings;aname:string;aCode:string);
  const
    cSQL = 'SELECT Name FROM DocQueues WHERE Hidden=''N'' and DocumentType=''%s'' and substring(Code from 1 for 2)=''%s'' ORDER BY Name';
  begin
    AOS.SQLSelect(format(cSQL,[aname,copy(acode,1,2)]), AList);
//    NxShowSimpleMessage(format(cSQL,[aname]),nil);
  end;


procedure iFillDivision(AOS : TNxCustomObjectSpace; AList : Tstrings;aname:string);
  const
    cSQL = 'SELECT Name FROM Divisions WHERE Hidden=''N'' and substring(name from 7 for 18)=''%s'' ORDER BY Name';
  begin
    AOS.SQLSelect(format(cSQL,[aname]), AList);
//    NxShowSimpleMessage(format(cSQL,[aname]),nil);
  end;


{
Vyvolává se po provedení metody CloseQuery. Pomocí tohoto háčku je možné ovlivnit, zda je možné agendu/formulář zavřít.
}
procedure FormCloseQuery_Hook(Self: TSiteForm; var CanClose: Boolean);
begin

end;

procedure FormCreate_Hook(Self: TSiteForm);
var
  mAList: TActionList;
  i: integer;
  mAction: TBasicAction;
  mC,mcc: TControl;
begin
  mAList := Self.GetMainActionList;
  for i := 0 to mAList.ActionCount-1 do begin
    mAction := mALIst.Actions[i];
    // Zcela odstranime funkci Opravit
    if (mAction.Name = 'actFind') then begin
      mAction.Visible := False;
    end;
    if (mAction.Name = 'actRefresh') then begin
      mAction.Visible := False;
    end;
    if (mAction.Name = 'actFindNext') then begin
      mAction.Visible := False;
    end;
    if (mAction.Name = 'actMaterialOutStock') then begin
      mAction.Visible := False;
    end;
    if (mAction.Name = 'actCooperations') then begin
      mAction.Visible := False;
    end;
    if (mAction.Name = 'actStateChange') then begin
      mAction.Visible := False;
    end;

 //   if (mAction.Name = 'actServiceDocument') then begin
 //     mAction.Visible := False;
 //   end;

 //   if (mAction.Name = 'actRefresh') then begin
 //     mAction.Visible := False;
 //   end;

  end;

 mC := Self.MainPanel.FindChildControl('rgdisplaymodeofrows');
 if Assigned(mC) then begin
     TRadioGroup(mC).Visible:= false;
 end;
mC := Self.MainPanel.FindChildControl('rgrowsgridfooter');
 if Assigned(mC) then begin
     TRadioGroup(mC).Visible:= false;
 end;

//mC := Self.MainPanel.FindChildControl('rgrowsgridfooter');
// if Assigned(mC) then begin
//     TRadioGroup(mC).Visible:= false;
// end;
end;






procedure _CanEdit_Hook(Self: TDynSiteForm; var ACanEdit: Boolean);
begin
  if (self.SiteContext.GetCompanyCache.GetUserID='SUPER00000') or (self.SiteContext.GetCompanyCache.GetUserID='2510000101')  or (self.SiteContext.GetCompanyCache.GetUserID='2U10000101') then begin
      //NxShowSimpleMessage('Pozor, chystáte se opravovat již uzavřený SL',nil)
  end else begin
      ACanEdit:=not (TDynSiteForm(self).CurrentObject.GetFieldValueAsInteger('ServiceDocument_ID.ServiceDocState_ID.PosIndex')>=50);
      if not ACanEdit then NxShowSimpleMessage('Doklad je již fakturován',nil);
  end;
end;


function iGetCodeByName(AOS : TNxCustomObjectSpace; const ATableName : string; ACode : string) : TNxOID;
const
  cSQL = 'SELECT Code FROM %s WHERE Name=''%s'' AND Hidden=''N''';
var
  mR : TStrings;
begin
  Result := '';
  mR := TStringlist.Create;
  try
    AOS.SQLSelect(Format(cSQL, [ATableName, ACode]), mR);
    if mR.Count > 0 then
      Result := mR.strings[0];
  finally
    mR.Free;
  end;
end;

function iGetIDByName(AOS : TNxCustomObjectSpace; const ATableName : string; ACode : string) : TNxOID;
const
  cSQL = 'SELECT ID FROM %s WHERE Name=''%s'' AND Hidden=''N''';
var
  mR : TStrings;
begin
  Result := '';
  mR := TStringlist.Create;
  try
    AOS.SQLSelect(Format(cSQL, [ATableName, ACode]), mR);
    if mR.Count > 0 then
      Result := mR.strings[0];
  finally
    mR.Free;
  end;
end;


procedure SendSLExecuteItem(Sender: Tcomponent; Index: integer);
var
mForm: TForm;
i:integer;
mr:tstringlist;
mresult:boolean;
mdate:date;
mDateinput:boolean;
mResult_mat:boolean;
mBO_MLNew:TNxCustomBusinessObject;
mrta:tstringlist;
mBookmark:TBookmarkList;
mr1:TStringList;
mi:integer;
mskupina:string;
mstate:string;
begin
    xSite := TComponent(Sender).DynSite;

    mTabList := TTabSheet(NxFindChildControl(xSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu

    if mBookmark.count=0 then begin              // běžná fakturace
        mBO:=TDynSiteForm(xSite).CurrentObject;
        if index=0 then begin
              mstate:='6XQ1000101';
              mBO_ML:=xSite.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                        try
                            mBO_ML:= mbo;
                                 mr1:=tstringlist.create;
                                    try
                                        mbo.ObjectSpace.SQLSelect('select id from ServiceAssemblyForms where ServiceDocument_ID=' + QuotedStr(mBO_ML.GetFieldValueAsString('ServiceDocument_ID')) +
                                        ' and x_state<>' + quotedstr('38S1000101')+ '  and x_state<>'+ quotedstr('6XQ1000101')
                                        + '  and x_state<>'+ quotedstr('AXQ1000101')
                                        + '  and x_state<>'+ quotedstr('3AU1000101')+ '  and x_state<>'+ quotedstr('8XQ1000101')+ '  and x_state<>'+ quotedstr('9XQ1000101')
                ,mr1) ;
                                        if mr1.count=0 then begin

                                                      if mresult then begin
                                                           mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set X_skupina=' + mskupina + ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                                           if mstate='6XQ1000101' then begin
                                                                mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' + QuotedStr('D102000000') + ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                                               // mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_State=' + quotedstr('8XQ1000101') + ' where ServiceDocument_ID=' + QuotedStr(mBO_ML.GetFieldValueAsString('ServiceDocument_ID')) +
                                                               //       ' and x_state<>'+ quotedstr('3Q22000101'));
                                                                mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceAssemblyForms set AssemblyState=3 where ServiceDocument_ID=' + QuotedStr(mBO_ML.GetFieldValueAsString('ServiceDocument_ID')) +
                                                                      ' and x_state<>'+ quotedstr('3Q22000101'));
                                                           end else begin
                                                                   mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' + QuotedStr('9300000101') + ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                                           end;
                                                      end;
                                        end else begin
                                           NxShowSimpleMessage('Existují neukončené ML. Nejdříve je ukončete',nil)
                                        end
                                    finally
                                        mr1.free;
                                    end;
                                //mBO_ML.save ;
                                mID_ML:=mbo_ml.oid;
                         finally
                           mBO_ML.free;
                         end;





        end;
        if index=1 then begin
             mstate:='3JS1000101';
             mBO_ML:=xSite.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                        try
                            mBO_ML:= mbo;
                                 mr1:=tstringlist.create;
                                    try
                                        mbo.ObjectSpace.SQLSelect('select id from ServiceAssemblyForms where ServiceDocument_ID=' + QuotedStr(mBO_ML.GetFieldValueAsString('ServiceDocument_ID')) +
                                        ' and x_state<>' + quotedstr('38S1000101')
                                        + '  and x_state<>'+ quotedstr('AXQ1000101')+ '  and x_state<>'+ quotedstr('3JS1000101')+ '  and x_state<>'+ quotedstr('3VW1000101')
                                        + '  and x_state<>'+ quotedstr('3AU1000101')+ '  and x_state<>'+ quotedstr('8XQ1000101')+ '  and x_state<>'+ quotedstr('9XQ1000101')
                ,mr1) ;
                                        if mr1.count=0 then begin

                                                      if mresult then begin
                                                           mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set X_skupina=' + mskupina + ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                                           if mstate='3JS1000101' then begin
                                                                mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' + QuotedStr('D102000000') + ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                                               // mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_State=' + quotedstr('8XQ1000101') + ' where ServiceDocument_ID=' + QuotedStr(mBO_ML.GetFieldValueAsString('ServiceDocument_ID')) +
                                                               //       ' and x_state<>'+ quotedstr('3Q22000101'));
                                                                mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceAssemblyForms set AssemblyState=3 where ServiceDocument_ID=' + QuotedStr(mBO_ML.GetFieldValueAsString('ServiceDocument_ID')) +
                                                                      ' and x_state<>'+ quotedstr('3Q22000101'));
                                                                      mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' + QuotedStr('9200000101') + ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                                           end else begin
                                                                   mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' + QuotedStr('9300000101') + ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                                           end;
                                                      end;
                                        end else begin
                                           NxShowSimpleMessage('Existují neukončené ML. Nejdříve je ukončete',nil)
                                        end
                                    finally
                                        mr1.free;
                                    end;
                                //mBO_ML.save ;
                                mID_ML:=mbo_ml.oid;
                         finally
                           mBO_ML.free;
                         end;



        end;
        if index=2 then begin
             mstate:='3AU1000101';
             mBO_ML:=xSite.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                        try
                            mBO_ML:= mbo;
                                 mr1:=tstringlist.create;
                                    try
                                        mbo.ObjectSpace.SQLSelect('select id from ServiceAssemblyForms where ServiceDocument_ID=' + QuotedStr(mBO_ML.GetFieldValueAsString('ServiceDocument_ID')) +
                                        ' and x_state<>' + quotedstr('38S1000101')+ '  and x_state<>'+ quotedstr('6XQ1000101')
                                        + '  and x_state<>'+ quotedstr('AXQ1000101')+ '  and x_state<>'+ quotedstr('3JS1000101')+ '  and x_state<>'+ quotedstr('3VW1000101')
                                        + '  and x_state<>'+ quotedstr('3AU1000101')+ '  and x_state<>'+ quotedstr('8XQ1000101')+ '  and x_state<>'+ quotedstr('9XQ1000101')
                ,mr1) ;
                                        if mr1.count=0 then begin

                                                      if mresult then begin
                                                           mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set X_skupina=' + mskupina + ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                                           if mstate='3AU1000101' then begin
                                                                //mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' + QuotedStr('D102000000') + ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                                                //mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceAssemblyForms set XState=' + quotedstr('3AU1000101') + ' where ServiceDocument_ID=' + QuotedStr(mBO_ML.GetFieldValueAsString('ServiceDocument_ID')) +
                                                                //      ' and x_state<>'+ quotedstr('3Q22000101'));
                                                                mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceAssemblyForms set AssemblyState=3 where ServiceDocument_ID=' + QuotedStr(mBO_ML.GetFieldValueAsString('ServiceDocument_ID')) +
                                                                      ' and x_state<>'+ quotedstr('3Q22000101'));
                                                           end else begin
                                                                   mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' + QuotedStr('9100000101') + ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                                           end;
                                                      end;
                                        end else begin
                                           NxShowSimpleMessage('Existují neukončené ML. Nejdříve je ukončete',nil)
                                        end
                                    finally
                                        mr1.free;
                                    end;
                                //mBO_ML.save ;
                                mID_ML:=mbo_ml.oid;
                         finally
                           mBO_ML.free;
                         end;


        end;
    end else begin
        for mI_ML:= 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
           mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(mI_ML));
           mBO_ML:= TDynSiteForm(xSite).CurrentObject;

        end;
    end;



end;





procedure NEWSLExecuteItem(Sender: Tcomponent; Index: integer);
var
mDamageDescription:string;
mForm: TForm;
i:integer;
mr:tstringlist;
mresult:boolean;
mdate:date;
mDateinput,mResult_mat:boolean;
mBO_MLNew:TNxCustomBusinessObject;
mrta:tstringlist;
mOLE_DV, mRoll_DV, mOResult_DV,mOLE_DQ, mRoll_DQ, mOResult_DQ,mOLE_WR, mRoll_WR, mOResult_WR: Variant;
mD_ML_start,mD_ML_End,mD_SL_start,mD_SL_End,mD_CRM_start,mD_CRM_End,mF_pausal_prace,mF_pausal_Vyjezd,mF_prace,mF_km,mFSazba_hod_den,mFDoprava_km,mF_doprava_pausal,mFSazba_hod:double;
   mF_doba,mF_Prace_od,mF_Prace_do,mF_Prac_doba_zac,mF_Prac_doba_kon:double;        // jen časová část
   mFSazba_Prace_pausal,mFSazba_Prace,mFSazba_Mimo,mFSazba_Vikend,mFSazba_Svatek,mFSazba_Doprava_km,mFSazba_Doprava_pausal,mFPriplatek3H:double;
   mF_Mnozstvi_Prace_pausal,F_Mnozstvi_Prace,mF_Mnozstvi_mimo,mF_Mnozstvi_vikend,mF_Mnozstvi_svatek,mF_Mnozstvi_Doprava_km,mF_Mnozstvi_Doprava_pausal:double;
  mstore_id:string;
   mDateFrom,mDateto,mDatezac,mDatekon,mPRzac,mPRkon:Double;
  msleva:double;
 mF_svatek,mF_vikend,mF_mimo,mFS_svatek,mFS_vikend,mFS_mimo,mFS_prace:double;
  mrole_id:string;
 mDnu:integer;
 mOpakovani:integer;
 mBO_ML_ROW:TNxCustomBusinessObject;
 mStore:string;
  mForm1 : TForm;
  mBtn : TButton;
  mKonecDAte:TDateTimeEdit;
  mKonecTime:TTimeEdit;
  mL_Technik,mL_Technik1,mL1_C_Protokol,mL1_pohotovost,mL1_C_Chyby,mL_technik_value,mL_technik1_value:TLabel;
  mL_operation,mL1_operation:TLabel ;
  mEd1_pohotovost:TCheckBox;
  mEd1_C_chyby,mEd1_C_protokol:tedit;
  mEd1_quantity,mEd_quantity,mEd_Unitprice,mEd_quantity1,mEd_Unitprice1,mEd_quantity2,mEd_Unitprice2,mEd_quantity3,mEd_Unitprice3,mEd_quantity4,mEd_Unitprice4,mEd_quantity5,mEd_Unitprice5,mEd_quantity6,mEd_Unitprice6,mEd_quantity7,mEd_Unitprice7,mEd_quantity8,mEd_Unitprice8,mEd_quantity9,mEd_Unitprice9,mEd_quantity10,mEd_Unitprice10,mED1_P_Cyklu:TEdit;
  mquantity:double;
  mWorkHoursReal:Double;
  mkorekce:Double;
  mpocet_km:Double;
  mLabel1,mLabel2,mLblm,mLbl1,mLbl2,mLbl0,mLbl3,mLabel3 ,mL1_P_Cyklu: TLabel;
  mEdtDAte:TDateEdit;
    mEdtDAte1:TTimeEdit;
    mID_WorkerRole:string;
    mEdtSrc:TEdit;
    mBO_BusProject:TNxCustomBusinessObject;
    mI_WorkerRole:integer;
    ID_result:string;
    mkoeficient,mkoeficient_korekce:Double;
    mrGT:TStringList;
   mRows_MLNew:TNxCustomBusinessMonikerCollection;
   mIDs_DQ,mIDs_DV:tstringlist;
mRow,mNewRow, mbo1,mbo_ml_target_row,mOrderRow,mNewRows: TNxCustomBusinessObject;
mMon : TNxCustomBusinessMonikerCollection;
mWorkerRole_ID:string;
mPosIndex,mpocet,mpocet1,mI_MLRow:Integer;
mRow_Pomoc:TNxCustomBusinessObject;
mList_pomoc:tstringlist;
mi,i01,ii,mhour,mmin,msek,mmsek:integer;
mpausal,mpausal_oprava:double;
mCRMresult:Boolean;
mID_DV,mID_DQ:string;
cbDocqueues,cbDivisions: TComboBox;//TRollComboEdit;
mcode:string;
mxpomoc:double;
muser:TNxCustomBusinessObject;
mServiceType_ID:string;
mB_pokracovat:boolean;
begin
   mB_pokracovat:=false;
    xSite := TComponent(Sender).DynSite;
      mID_WorkerRole:='';
   mID_WorkerRole:='';
   mID_StoreCard:='';
   mid_workSpace:='';
   mD_SL_start:= (date) + EncodeTime(7,0,0,0);
   mD_SL_End:=(date) + encodetime(15,30,0,0);


    mTabList := TTabSheet(NxFindChildControl(xSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');




 //   if not assigned(xsite.CurrentObject) then begin
 //       mBO:=TDynSiteForm(xSite).BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
 //       mbo.load('K0U2000101',nil);
 //   end else begin
 //       mBO:=TDynSiteForm(xSite).BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
        mBO:=TDynSiteForm(xSite).CurrentObject;
 //   end;



    if index=0 then begin
              if (xsite.SiteContext.GetCompanyCache.GetLoginID='1410000101') then begin
                  mD_SL_start:= GetDate(Sender,xSite) ;
                  mD_SL_start:= trunc(mD_SL_start) + EncodeTime(7,0,0,0);
                  mD_SL_End:=trunc(mD_SL_start) + encodetime(15,30,0,0);
              end;


                                  mForm := TForm.Create(xsite);
                                  mForm.Caption := 'Zadejte údaje SL';
                                  mForm.FormStyle := fsStayOnTop;
                                  mForm.BorderStyle := bsDialog;
                                  mForm.Width := 550;
                                  mForm.Height := 170;
                                  mForm.Scaled := False;
                                  mform.Position := poScreenCenter;

                                  mLabel3 := TLabel.Create(mForm);
                                  mLabel3.Parent := mForm;
                                  mLabel3.Caption := 'Typ servisu :';
                                  mLabel3.Top := 10;
                                  mLabel3.Left := 10;
                                  mLabel3.Height := 13;


                                    cbDocqueues := TComboBox.Create(mForm);
                                    cbDocqueues.Left := 100;
                                    cbDocqueues.Top := 10;
                                    cbDocqueues.Width := 200;
                                    cbDocqueues.Name := 'cbDocqueue';
                                    cbDocqueues.Text := '';
                                    mForm.InsertControl(cbDocqueues);
                                    iFillDocqueue_code(xsite.BaseObjectSpace,cbDocqueues.Items,'SL','SL');
                                     if cbDocqueues.Items.Count >= 0 then begin
                                      cbDocqueues.ItemIndex := 0;
                                    end;

                                    if (xSite.CompanyCache.GetUserID='1810000101') or (xSite.CompanyCache.GetUserID='2020000101') or (xSite.CompanyCache.GetUserID='SUPER00000') then begin

                                                mLabel2 := TLabel.Create(mForm);
                                              mLabel2.Parent := mForm;
                                              mLabel2.Caption := 'Středisko :';
                                              mLabel2.Top := 40;
                                              mLabel2.Left := 10;
                                              mLabel2.Height := 13;

                                                cbDIvisions := TComboBox.Create(mForm);
                                                cbDIvisions.Left := 100;
                                                cbDIvisions.Top := 40;
                                                cbDIvisions.Width := 200;
                                                cbDIvisions.Name := 'cbDivision';
                                                cbDIvisions.Text := '';
                                                mForm.InsertControl(cbDivisions);
                                                   iFillDivision(xsite.BaseObjectSpace, cbDivisions.Items,'Servisní středisko');
                                                 if cbDIvisions.Items.Count >= 0 then begin
                                                  cbDivisions.ItemIndex := 0;
                                                end;








                                       end;

                                       mL_operation:= TLabel.Create(mForm);
                                                mL_operation.Parent := mForm;
                                                mL_operation.Caption := 'Poškození :';
                                                mL_operation.Top := 70;
                                                mL_operation.Left := 10;
                                                mL_operation.Height := 150;
                                                mL_operation.Width := 80;
                                                mEd_quantity := TEdit.Create(mForm);
                                                mEd_quantity.Left := 100;
                                                mEd_quantity.Top := 60;
                                                mEd_quantity.Width := 430;
                                                mEd_quantity.Name := 'mEd_quantity';
                                                mEd_quantity.Text:='';
                                                mForm.InsertControl(mEd_quantity);

                                mBtn := TButton.Create(mForm);
                                mBtn.Width := 75;
                                mBtn.Height := 25;
                                mBtn.Caption := 'OK';
                                mBtn.ModalResult := mrOk;
                                mBtn.Cancel := False;
                                mBtn.Default := True;
                                mBtn.Left :=  mForm.Width - 2*(mBtn.Width+2) - 20;
                                mBtn.Top := mForm.Height - mBtn.Height - 40;
                                mBtn.Name := 'btnOK';
                                mForm.InsertControl(mBtn);

                                mBtn := TButton.Create(mForm);
                                mBtn.Width := 75;
                                mBtn.Height := 25;
                                mBtn.Caption := 'Storno';
                                mBtn.ModalResult := mrCancel;
                                mBtn.Cancel := True;
                                mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;;
                                mBtn.Top := mForm.Height - mBtn.Height - 40;
                                mBtn.Name := 'btnCancel';
                                mForm.InsertControl(mBtn);

                                try
                                    if mForm.ShowModal(xSite) = mrOK then begin
                                         mB_pokracovat:=true;
                                         mDamageDescription:=mEd_quantity.Text;
                                         mID_DQ:=iGetIDByName(xsite.BaseObjectSpace,'Docqueues', ReplaceStr(cbDocqueues.Text,'"','')) ;
                                        //NxShowSimpleMessage( mID_DQ,nil);

                                        if (xsite.CompanyCache.GetUserID='1810000101') or (xsite.CompanyCache.GetUserID='2020000101') then begin
                                            mID_DV:=iGetIDByName(xsite.BaseObjectSpace,'Divisions', ReplaceStr(cbDivisions.Text,'"','')) ;
                                            mcode:=iGetcodeByName(xsite.BaseObjectSpace,'Divisions', ReplaceStr(cbDivisions.Text,'"','')) ;
                                        end else begin
                                            mUser := xsite.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');            // přihlášený uživatel
                                                  try
                                                      mUser.Load(xsite.CompanyCache.GetUserID, nil);
                                                            mID_DV:= mUser.GetFieldValueAsString('X_division_ID');
                                                            mcode:=mUser.GetFieldValueAsString('X_division_ID.code');

                                                  finally
                                                    mUser.Free;
                                                  end;
                                        end;
                                        //NxShowSimpleMessage( mID_DV,nil);
                                   end;
                                   finally

                                   end    ;
                                   mform.free;
                                  if not mB_pokracovat  then exit;


                  mOLE_SP:= GetAbraOLEApplication;
                  mOResult_SP:= mOLE_SP.CreateStrings;
                  mRoll_SP:= mOLE_SP.GetRoll('5315B3YAPMNOB0FIRUCLXSJ52O', 0);   // sp
                                    if not mRoll_SP.MultiSelectDialog(True, mOResult_SP) then Exit;
                                    mIDs_SP:= TStringList.Create;
                                    mIDs_WorkerRole:=TStringList.create;
                                    mIDs_Storecard:=TStringList.create;
                                    try
                                    mIDs_SP.Text:= mOResult_SP.Text;
                                        mdateinput:=true;
                                        mResult_mat:=true;
                                        mOLE_WorkerRole:= GetAbraOLEApplication;
                                              mOResult_WorkerRole:= mOLE_WorkerRole.CreateStrings;
                                                      mRoll_WorkerRole:= mOLE_WorkerRole.GetRoll('0FKKTBSSQKB4B3RLYBSJFFAFUW', 0);   // sp
                                                       if mRoll_WorkerRole.MultiSelectDialog(True, mOResult_WorkerRole) then mIDs_WorkerRole.Text:= mOResult_WorkerRole.Text;

                                        mIDs_SP.Text:= mOResult_SP.Text;



                                       // if nxisblank(mid_workSpace) then begin
                                            mr:=TStringList.Create;
                                            try
                                               xsite.BaseObjectSpace.SQLSelect('select id from ServiceWorkSpaces where code=' + QuotedStr(mcode),mr);
                                                        if mr.count>0 then mid_workSpace:=mr.Strings[0];
                                            finally
                                                mr.free;
                                            end;
                                        // end;

                                         //if nxisblank(mid_workerRole) then begin
                                            if  mIDs_WorkerRole.count>0 then begin
                                                mid_workerRole:=mIDs_WorkerRole.Strings[0];
                                            end else begin
                                                  mr:=TStringList.Create;
                                                  try
                                                    xsite.BaseObjectSpace.SQLSelect('select id from SecurityRoles where ShortName=' + QuotedStr(mcode),mr);
                                                    if mr.count>0 then begin
                                                        mid_workerRole:=mr.Strings[0] ;
                                                    end;
                                                  finally
                                                      mr.free;
                                                  end;
                                            end;
                                          //end;





                                        for mI_SP:=0 to mIDs_SP.count-1 do begin                  // cyklus SP

                                                      mID_SP:=mIDs_SP.Strings(mI_SP);
                                                      // vytvoření nového servisního listu
                                                      mServiceType_ID:='2300000101';
                                                      mID_SL:=Novy_SL(xsite,mID_SP,mD_SL_start,mD_SL_end,mID_DQ,mID_DV,mDamageDescription,mServiceType_ID);

                                                      mbo_SL:=xsite.BaseObjectSpace.CreateObject('BCHF52UGXCO4H5MIAQVY5P3ZOC');
                                                      try
                                                                   mbo_sl.Load(mID_SL,nil) ;  // použití již existujícího SL
                                                                     mIDs_ML:=tstringlist.create;
                                                                     try
                                                                              xsite.BaseObjectSpace.SQLSelect('select id from ServiceAssemblyForms where ServiceDocument_ID='+quotedstr(mID_SL),mIDs_ML);
                                                                              if mIDs_ML.count>0 then begin
                                                                                   mID_ML:=mIDs_ML.Strings[0];           // použití již existujícího ML
                                                                              end else begin

                                                                                    // založení nového ML
                                                                                    //mID_ML:=Novy_ML(mBO_SL,mid_workSpace,mid_workerRole,mD_SL_start,mD_SL_end);

                                                                                    mBO_ML:=xsite.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                                                                                    try
                                                                                       mBO_ML.new;
                                                                                       mBO_ML.Prefill;
                                                                                       mBO_ML.SetFieldValueAsDateTime('StartDate$DATE',mD_SL_start);
                                                                                       mBO_ML.SetFieldValueAsDateTime('EndDate$DATE',mD_SL_End);
                                                                                       mBO_ML.SetFieldValueAsDateTime('X_CreatedDate$DATE',date);
                                                                                       mBO_ML.SetFieldValueAsString('ServiceDocument_ID',mID_SL);
                                                                                       mBO_ML.SetFieldValueAsstring('X_State','35W1000101');
                                                                                       mBO_ML.SetFieldValueAsstring('X_ServicedObject_ID',mBO_SL.GetFieldValueAsString('ServicedObject_ID'));
                                                                                       mBO_ML.SetFieldValueAsstring('X_id_zakaznika_id',mBO_SL.GetFieldValueAsString('X_id_zakaznika_id'));
                                                                                       mBO_ML.SetFieldValueAsInteger('AssemblyState',0);

                                                                                       mBO_ML.SetFieldValueAsString('ServiceWorkSpace_ID',mid_workSpace);
                                                                                       mBO_ML.SetFieldValueAsString('ResponsibleRole_ID',mid_workerRole);
                                                                                      mBO_ML.SetFieldValueAsstring('X_State','3XQ1000101');

                                                                                      mBO_ML.SetFieldValueAsinteger('AssemblyState',0);

                                                                                      mBO_ML.SetFieldValueAsstring('X_Docqueue_ID',mBO_SL.GetFieldValueAsString('Docqueue_ID'));
                                                                                      mBO_ML.SetFieldValueAsInteger('X_Ordnumber',mBO_SL.GetFieldValueAsInteger('Ordnumber'));
                                                                                      mBO_ML.SetFieldValueAsstring('X_Period_ID',mBO_SL.GetFieldValueAsString('Period_ID'));
                                                                                      // zadání technika
                                                                                       if mIDs_WorkerRole.Count>0 then begin

                                                                                                    mF_prace_Od:=mD_SL_start;
                                                                                                    mF_prace_Do:=mD_SL_End;
                                                                                                    mF_doba:= 1 ;
                                                                                                    if mDateinput then begin         // opakující se doba
                                                                                                                mDateinput:=false;
                                                                                                                mForm := TForm.Create(xSite);
                                                                                                                mForm.Caption := 'Zadejte údaje';mForm.FormStyle := fsStayOnTop;mForm.BorderStyle := bsDialog;mForm.Width := 550;mForm.Scaled := False;mform.Position := poScreenCenter;
                                                                                                                mLbl2 := TLabel.Create(mForm);  mLbl2.Caption := 'Konec :';mLbl2.Left := 10;mLbl2.Top := 40;mLbl2.Name := 'lbldate';mForm.InsertControl(mLbl2);mEdtDAte := TDateEdit.Create(mForm);mEdtDAte.Left := 100;mEdtDAte.Top := 40;mEdtDAte.Width := 100;mEdtDAte.Name := 'edtDate';mEdtDAte.Date:=trunc(mD_SL_End);mForm.InsertControl(mEdtDAte);
                                                                                                                //mEdtDAte1 := TTimeEdit.Create(mForm);mEdtDAte1.Left := 210;mEdtDAte1.Top := 40;mEdtDAte1.Width := 100;mEdtDAte1.Name := 'edtDate1';mEdtDAte1.Time:=frac(mD_SL_End);mForm.InsertControl(mEdtDAte1);
                                                                                                                mLbl3 := TLabel.Create(mForm); mLbl3.Caption := 'Doba :';mLbl3.Left := 10;mLbl3.Top := 70;mLbl3.Name := 'lblDoba';mForm.InsertControl(mLbl3);mEdtSrc := TEdit.Create(mForm);mEdtSrc.Left := 100;mEdtSrc.Top := 70;mEdtSrc.Width := 100;mEdtSrc.Name := 'edtdoba';mEdtSrc.Text:=NxFloatToIBStr(mf_doba);mForm.InsertControl(mEdtSrc);
                                                                                                                mBtn := TButton.Create(mForm);mBtn.Width := 75; mBtn.Height := 25;mBtn.Caption := 'OK';mBtn.ModalResult := mrOk;mBtn.Cancel := False;mBtn.Default := True;mBtn.Left :=  mForm.Width - 2*(mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 40;mBtn.Name := 'btnOK';mForm.InsertControl(mBtn);
                                                                                                                mBtn := TButton.Create(mForm);mBtn.Width := 75;mBtn.Height := 25;mBtn.Caption := 'Storno';mBtn.ModalResult := mrCancel;mBtn.Cancel := True;mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 40;mBtn.Name := 'btnCancel';mForm.InsertControl(mBtn);
                                                                                                                if mForm.ShowModal(xSite) = mrOK then begin
                                                                                                                                mB_pokracovat:=true;
                                                                                                                                mF_doba:=NxIBStrToFloat(mEdtSrc.Text);
                                                                                                                                mD_ML_End:=mEdtDAte.Date+ encodetime(15,30,0,0);
                                                                                                                                /// *************************************************





                                                                                                                                mD_ML_start:=mD_ML_End - EncodeTime(trunc(mF_doba),trunc(frac(trunc(mF_doba)*60)),0,0);
                                                                                                                                mBO_ML.SetFieldValueAsDateTime('StartDate$DATE',mD_ML_start);
                                                                                                                                mBO_ML.SetFieldValueAsDateTime('EndDate$DATE',mD_ML_End);
                                                                                                                                if  not NxIsEmptyOID(mBO_ML.GetFieldValueAsString('ServiceDocument_ID.BusProject_ID')) then begin
                                                                                                                                        mF_pausal_prace:=0;mF_pausal_Vyjezd:=0;mFSazba_mimo:=0;mFSazba_vikend:=0;mFSazba_svatek:=0;mFDoprava_km:=0;mF_Prac_doba_zac:=0;mF_Prac_doba_kon:=0;
                                                                                                                                        // ceny z projektu
                                                                                                                                        try
                                                                                                                                                mBO_BusProject:=xsite.BaseObjectSpace.CreateObject('QOKMKIQUJF34L3DUICTBWEDQJC');
                                                                                                                                                if mBO_ML.GetFieldValueAsInteger('ServiceDocument_ID.ServicedObject_ID.X_Fakturacni_oblast')=0 then begin
                                                                                                                                                    NxShowSimpleMessage('Pozor, předmět není přiřazen do fakturační oblasti, ceny nemusí odpovídat, bude použit formát pro Čechy',nil);
                                                                                                                                                    mBO_BusProject.load('2130000101',nil);                                                                                    // max cena=čechy
                                                                                                                                                end;
                                                                                                                                                if mBO_ML.GetFieldValueAsInteger('ServiceDocument_ID.ServicedObject_ID.X_Fakturacni_oblast')=1 then begin     // čechy
                                                                                                                                                      mBO_BusProject.load('2130000101',nil);
                                                                                                                                                end;
                                                                                                                                                if mBO_ML.GetFieldValueAsInteger('ServiceDocument_ID.ServicedObject_ID.X_Fakturacni_oblast')=2 then begin      // morava
                                                                                                                                                      mBO_BusProject.load('3130000101',nil);
                                                                                                                                                end;
                                                                                                                                                mFSazba_prace:=mBO_BusProject.GetFieldValueAsFloat('X_Sazba_bezna');
                                                                                                                                                mF_pausal_prace:=mBO_BusProject.GetFieldValueAsFloat('X_Prevence_pausal');
                                                                                                                                                mF_pausal_Vyjezd:=mBO_BusProject.GetFieldValueAsFloat('X_Najezdni_pausal');
                                                                                                                                                if mF_pausal_Vyjezd=0 then  mFDoprava_km:=mBO_BusProject.GetFieldValueAsFloat('X_Sazba_bezna');
                                                                                                                                        finally
                                                                                                                                        mBO_BusProject.free;
                                                                                                                                        end;

                                                                                                                                end;
                                                                                                               end else begin
                                                                                                               mB_pokracovat:=false;
                                                                                                               end;
                                                                                                     end;   //opakující se doba;
                                                                                                     msleva:= mBO_ML.GetFieldValueAsInteger('ServiceDocument_ID.X_Discount_sluzby');
                                                                                                     {  try
                                                                                                          mrgt:=tstringlist.create;
                                                                                                          xsite.BaseObjectSpace.SQLSelect(format('select count(id) from ServiceAssemblyForms2 where parent_ID=%s and (itemtype=4 and text=%s) or (itemtype=0 and Storecard_ID=%s) ',[quotedstr(mbo_ml.OID),quotedstr('Práce - evidenční pro mzdy'),quotedstr('92E0000101')]),mrgt);
                                                                                                          if strtoint(mrgt.Strings[0])>0 then begin
                                                                                                             mkoeficient:=trunc(100/(strtoint(mrgt.Strings[0])+1));
                                                                                                             mkoeficient_korekce:=100-((strtoint(mrgt.Strings[0])+1)*mkoeficient);
                                                                                                          end else begin
                                                                                                             mkoeficient:=100;
                                                                                                             mkoeficient_korekce:=0;
                                                                                                          end;
                                                                                                       finally
                                                                                                          mr.free;
                                                                                                       end; }
                                                                                                       mRows_ML := mBO_ML.GetCollectionMonikerForFieldCode(mBO_ML.GetFieldCode('Rows'));
                                                                                                       if (mIDs_workerRole.count>0) and (mB_pokracovat) then begin
                                                                                                            for mI_WorkerRole:=0 to mIDs_workerRole.count-1 do begin
                                                                                                                  mID_WorkerRole:=mIDs_WorkerRole.Strings[mI_WorkerRole];
                                                                                                                { mr:=tstringlist.create;
                                                                                                                          try
                                                                                                                              xsite.BaseObjectSpace.SQLSelect('select min(SheduledStart$Date) from CRMActivities where SolverRole_ID='+ quotedstr(mID_WorkerRole) + ' and SheduledStart$Date>' + inttostr(trunc(mD_ML_End)) + ' and SheduledStart$Date<=' + inttostr((trunc(mD_ML_End)+1)) , mr);
                                                                                                                              if mr.count>0 then begin
                                                                                                                                   if frac(NxIBStrToFloat(mr.Strings[0]))<EncodeTime(5,0,0,0) then begin

                                                                                                                                   end else begin
                                                                                                                                      mD_ML_End:=trunc(mD_ML_End) + frac(NxIBStrToFloat(mr.Strings[0]));
                                                                                                                                   end;
                                                                                                                              end;
                                                                                                                          finally
                                                                                                                             mr.free;
                                                                                                                          end;
                                                                                                                   }
                                                                                                                        mD_ML_End:=trunc(mD_ML_End) +encodetime(15,30,0,0);
                                                                                                                       mBO_ML_ROW := mRows_ml.AddNewObject;
                                                                                                                                      mBO_ML_ROW.SetFieldValueAsinteger('itemtype',0);          // 0 práce , 1 skladová karta
                                                                                                                                      //mOrderRow.SetFieldValueAsString('serviceworkcategory_id','');
                                                                                                                                      mBO_ML_ROW.SetFieldValueAsString('WorkerRole_ID',mID_WorkerRole);
                                                                                                                                      mBO_ML_ROW.SetFieldValueAsString('X_WorkerRole_ID',mID_WorkerRole);
                                                                                                                                      mBO_ML_ROW.SetFieldValueAsString('X_Osoba',mBO_ML_ROW.GetFieldValueAsstring('WorkerRole_ID.Name'));
                                                                                                                                      mBO_ML_ROW.SetFieldValueAsString('Text','Práce');
                                                                                                                                      mBO_ML_ROW.SetFieldValueAsString('Store_id','2000000101');
                                                                                                                                      mBO_ML_ROW.SetFieldValueAsString('StoreCard_id','2ZI1000101');
                                                                                                                                      mBO_ML_ROW.SetFieldValueAsfloat('WorkHoursPlanned',mF_doba);
                                                                                                                                      mBO_ML_ROW.SetFieldValueAsfloat('X_konec_prace',mD_ML_End);
                                                                                                                                      mBO_ML_ROW.SetFieldValueAsfloat('X_Radkova_sleva',msleva);
                                                                                                                                      mdateto:=mD_ML_End;
                                                                                                                                             mD_ML_start:=mD_ML_End - EncodeTime(trunc(mF_doba),trunc(frac(trunc(mF_doba)*60)),0,0);

                                                                                                                                             mCRMresult:=NxCRM(0,mBO_ML_ROW,mID_WorkerRole,mD_ML_start,mD_ML_End,'','');
                                                                                                                                             if not mCRMresult then NxShowSimpleMessage('Při vytváření aktivity došlo k chybě',nil);
                                                                                                                                      mBO_ML_ROW.SetFieldValueAsfloat('X_Koeficient',100/mIDs_workerRole.count);
                                                                                                                                      mkoeficient_korekce:=0;
                                                                                                                                      if mFSazba_hod<>0 then mBO_ML_ROW.SetFieldValueAsfloat('UnitPriceWithoutVAT',mFSazba_hod);
                                                                                                                                      mBO_ML_ROW.SetFieldValueAsinteger('ToInvoiceType',0);
                                                                                                                  if mI_WorkerRole=0 then mkoeficient_korekce:=0
                                                                                                            end;
                                                                                                       mBO_ML.SetFieldValueAsstring('X_State','4U12000101');
                                                                                                       mBO_ML.SetFieldValueAsinteger('AssemblyState',1);
                                                                                                       mBO_ML.SetFieldValueAsstring('X_Monter1_ID',mID_WorkerRole);
                                                                                                mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' +QuotedStr(mBO_ML.getFieldValueAsString('X_state.X_field1'))+ ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                                                                                       end;


                                                                                                          // rozpočet fakturace
                                                                                                       if (trunc(mBO_ml.GetFieldValueAsDateTime('EndDate$DATE'))<date) and (mB_pokracovat) then begin
                                                                                                              if mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='1A20000101' then mBO_ML.SetFieldValueAsString('X_protokol_prefix','S');
                                                                                                              if mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='5B20000101' then mBO_ML.SetFieldValueAsString('X_protokol_prefix','S');
                                                                                                              if mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='4B20000101' then mBO_ML.SetFieldValueAsString('X_protokol_prefix','P');
                                                                                                              if mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='6B20000101' then mBO_ML.SetFieldValueAsString('X_protokol_prefix','P');
                                                                                                              if mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='7B20000101' then mBO_ML.SetFieldValueAsString('X_protokol_prefix','B');
                                                                                                              if mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='8B20000101' then mBO_ML.SetFieldValueAsString('X_protokol_prefix','B');
                                                                                                              if mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='9B20000101' then mBO_ML.SetFieldValueAsString('X_protokol_prefix','F');
                                                                                                              if mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='AB20000101' then mBO_ML.SetFieldValueAsString('X_protokol_prefix','F');
                                                                                                               if true then begin  // není fakturován
                                                                                                                        mF_pausal_prace:=0;mF_pausal_Vyjezd:=0;mFSazba_prace:=0;mFSazba_mimo:=0;mFSazba_vikend:=0;mFSazba_svatek:=0;mFDoprava_km:=0;mFPriplatek3H:=0;mPRzac:=0;mPRkon:=0;


                                                                                                                               // ceny z projektu

                                                                                                                                 if not NxIsEmptyOID(mBO_ML.GetFieldValueAsString('ServiceDocument_ID.BusProject_ID')) then begin
                                                                                                                                        mBO_BusProject:=mBO_ML.ObjectSpace.CreateObject('QOKMKIQUJF34L3DUICTBWEDQJC');
                                                                                                                                       try
                                                                                                                                         mBO_BusProject.load(mBO_ML.GetFieldValueAsString('ServiceDocument_ID.BusProject_ID'),nil);
                                                                                                                                          if (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_id')='4B20000101') Or
                                                                                                                                           (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_id')='6B20000101') Or
                                                                                                                                           (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_id')='7B20000101') or
                                                                                                                                           (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_id')='8B20000101') or
                                                                                                                                           (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_id')='9B20000101') or
                                                                                                                                           (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_id')='AB20000101')
                                                                                                                                          then begin
                                                                                                                                                  if(mBO_BusProject.GetFieldValueAsFloat('X_Prevence_pausal')>0) then mF_pausal_prace:=mBO_BusProject.GetFieldValueAsFloat('X_Prevence_pausal');
                                                                                                                                          end;
                                                                                                                                          if(mBO_BusProject.GetFieldValueAsFloat('X_Najezdni_pausal')>0) then mF_pausal_Vyjezd:=mBO_BusProject.GetFieldValueAsFloat('X_Najezdni_pausal');
                                                                                                                                          if(mBO_BusProject.GetFieldValueAsFloat('X_Sazba_bezna')>0) then mFSazba_prace:=mBO_BusProject.GetFieldValueAsFloat('X_Sazba_bezna');
                                                                                                                                          if(mBO_BusProject.GetFieldValueAsFloat('X_Sazba_mimo_pd')>0) then mFSazba_mimo:=mBO_BusProject.GetFieldValueAsFloat('X_Sazba_mimo_pd');
                                                                                                                                          if(mBO_BusProject.GetFieldValueAsFloat('X_sazba_vikend')>0) then mFSazba_vikend:=mBO_BusProject.GetFieldValueAsFloat('X_sazba_vikend');
                                                                                                                                          if(mBO_BusProject.GetFieldValueAsFloat('X_sazba_vikend')>0) then mFSazba_svatek:=mBO_BusProject.GetFieldValueAsFloat('X_sazba_vikend');
                                                                                                                                          if(mBO_BusProject.GetFieldValueAsFloat('X_Najezdni_pausal')>0) then  mFSazba_Doprava_pausal:=mBO_BusProject.GetFieldValueAsFloat('X_Najezdni_pausal');
                                                                                                                                          mFSazba_Doprava_km:=0;
                                                                                                                                          if mF_pausal_Vyjezd=0 then begin
                                                                                                                                              if(mBO_BusProject.GetFieldValueAsFloat('X_Sazba_km')>0) then mFSazba_Doprava_km:=mBO_BusProject.GetFieldValueAsFloat('X_Sazba_km');
                                                                                                                                          end;
                                                                                                                                          if(mBO_BusProject.GetFieldValueAsFloat('X_Pr_OD')>0) then mPRzac:=mBO_BusProject.GetFieldValueAsFloat('X_PR_od');
                                                                                                                                          if(mBO_BusProject.GetFieldValueAsFloat('X_Pr_DO')>0) then mPRkon:=mBO_BusProject.GetFieldValueAsFloat('X_PR_do');
                                                                                                                                          if(mBO_BusProject.GetFieldValueAsFloat('X_Priplatek3hod')>0) then mFPriplatek3H:=mBO_BusProject.GetFieldValueAsFloat('X_Priplatek3hod');
                                                                                                                                    finally
                                                                                                                                      mBO_BusProject.free;
                                                                                                                                    end;

                                                                                                                               end ;
                                                                                                                               //if NxIsEmptyOID(mBO_ML.GetFieldValueAsString('ServiceDocument_ID.BusProject_ID')) then begin
                                                                                                                                      try
                                                                                                                                        // ceny z fakturační oblasti
                                                                                                                                        mBO_BusProject:=mBO_ML.ObjectSpace.CreateObject('QOKMKIQUJF34L3DUICTBWEDQJC');
                                                                                                                                        if mBO_ML.GetFieldValueAsInteger('ServiceDocument_ID.ServicedObject_ID.X_Fakturacni_oblast')=0 then begin
                                                                                                                                            NxShowSimpleMessage('Pozor, předmět není přiřazen do fakturační oblasti, ceny nemusí odpovídat, bude použit formát pro Čechy',nil);
                                                                                                                                            mBO_BusProject.load('2130000101',nil);                                                                                    // max cena=čechy
                                                                                                                                        end;
                                                                                                                                        if mBO_ML.GetFieldValueAsInteger('ServiceDocument_ID.ServicedObject_ID.X_Fakturacni_oblast')=1 then begin     // čechy
                                                                                                                                            mBO_BusProject.load('2130000101',nil);
                                                                                                                                        end;
                                                                                                                                        if mBO_ML.GetFieldValueAsInteger('ServiceDocument_ID.ServicedObject_ID.X_Fakturacni_oblast')=2 then begin      // morava
                                                                                                                                            mBO_BusProject.load('3130000101',nil);
                                                                                                                                        end;

                                                                                                                                        if mFSazba_prace=0 then if(mBO_BusProject.GetFieldValueAsFloat('X_Sazba_bezna')>0) then mFSazba_prace:=mBO_BusProject.GetFieldValueAsFloat('X_Sazba_bezna');
                                                                                                                                        if mFSazba_mimo=0 then if(mBO_BusProject.GetFieldValueAsFloat('X_Sazba_mimo_pd')>0) then mFSazba_mimo:=mBO_BusProject.GetFieldValueAsFloat('X_Sazba_mimo_pd');
                                                                                                                                        if mFSazba_vikend=0 then if(mBO_BusProject.GetFieldValueAsFloat('X_sazba_vikend')>0) then mFSazba_vikend:=mBO_BusProject.GetFieldValueAsFloat('X_sazba_vikend');
                                                                                                                                        if mFSazba_svatek=0 then if(mBO_BusProject.GetFieldValueAsFloat('X_sazba_vikend')>0) then mFSazba_svatek:=mBO_BusProject.GetFieldValueAsFloat('X_sazba_vikend');

                                                                                                                                        if mFSazba_Doprava_pausal=0 then if(mBO_BusProject.GetFieldValueAsFloat('X_Najezdni_pausal')>0) then mFSazba_Doprava_pausal:=mBO_BusProject.GetFieldValueAsFloat('X_Najezdni_pausal');
                                                                                                                                        if mFSazba_Doprava_pausal=0 then begin
                                                                                                                                            if mFSazba_Doprava_km=0 then if(mBO_BusProject.GetFieldValueAsFloat('X_Sazba_km')>0) then mFSazba_Doprava_km:=mBO_BusProject.GetFieldValueAsFloat('X_Sazba_km');
                                                                                                                                        end;



                                                                                                                                        if mPRzac=0 then if(mBO_BusProject.GetFieldValueAsFloat('X_Pr_OD')>0) then mPRzac:=mBO_BusProject.GetFieldValueAsFloat('X_PR_od');
                                                                                                                                        if mPRkon=0 then if(mBO_BusProject.GetFieldValueAsFloat('X_Pr_DO')>0) then mPRkon:=mBO_BusProject.GetFieldValueAsFloat('X_PR_do');
                                                                                                                                        if mFPriplatek3H=0 then mFPriplatek3H:=mBO_BusProject.GetFieldValueAsFloat('X_Priplatek3hod');

                                                                                                                                     finally
                                                                                                                                          mBO_BusProject.free;
                                                                                                                                     end;
                                                              //end;

                                                                                                                            if (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='AB20000101') or (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='4B20000101') or (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='8B20000101') or (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='9B20000101')  or (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_ID')='6B20000101') or (mBO_ML.GetFieldValueAsString('ServiceDocument_ID.Docqueue_id')='7B20000101') then begin
                                                                                                                                   //mrta:=tstringlist.create;
                                                                                                                                   //try
                                                                                                                                   //           mBO_ML.ObjectSpace.SQLSelect('select id from ServiceAssemblyForms2 where ItemType=0 and ((storecard_ID='+ QuotedStr('2ZI1000101')+
                                                                                                                                   //           ') or (storecard_ID='+ QuotedStr('11J1000101')+')) and (parent_id=' + quotedstr(mBO_ML.oid)+ ')',mrta);
                                                                                                                                   //        if mrta.count>0 then mpocet1:=mrta.count;
                                                                                                                                   //finally
                                                                                                                                   //     mrta.free;
                                                                                                                                   //end;

                                                                                                                                   if (mIDs_WorkerRole.count>0) and mB_pokracovat then begin
                                                                                                                                        mForm1 := TForm.Create(xSite);mForm1.Caption := 'Rozpočtení paušálu';mForm1.FormStyle := fsStayOnTop;mForm1.BorderStyle := bsDialog;
                                                                                                                                                mForm1.Width := 1350;mForm1.Height := 100;mForm1.Scaled := False;mform1.Position := poScreenCenter;
                                                                                                                                                mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := 'Počet tech.:';mL_Technik.Top := 12;mL_Technik.Left := 10;mL_Technik.Height := 13;
                                                                                                                                                mL_technik_value:= TLabel.Create(mForm1);mL_technik_value.Parent := mForm1;mL_technik_value.Caption := inttostr(mIDs_WorkerRole.count);mL_technik_value.Top := 12;mL_technik_value.Left := 80;mL_technik_value.Height := 13;mL_technik_value.Width := 50;
                                                                                                                                                mL_technik_value:= TLabel.Create(mForm1);mL_technik_value.Parent := mForm1;mL_technik_value.Caption := ('Konec práce');mL_technik_value.Top := 10;mL_technik_value.Left := 150;mL_technik_value.Height := 13;mL_technik_value.Width := 50;
                                                                                                                                                mKonecDAte := TDateTimeEdit.Create(mForm1);mKonecDAte.Left := 250;mKonecDAte.Top := 10;mKonecDAte.Width := 80;mKonecDAte.Name := 'mKonecDAte';mKonecDAte.DateTime:= mBO_ML.GetFieldValueAsDateTime('EndDate$DATE');mKonecDAte.Enabled:=true;mForm1.InsertControl(mKonecDAte);
                                                                                                                                                mKonecTime := TTimeEdit.Create(mForm1);mKonecTime.Left := 330;mKonecTime.Top := 10;mKonecTime.Width := 80;mKonecTime.Name := 'mKonecTime';mKonecTime.Time:= mBO_ML.GetFieldValueAsDateTime('EndDate$DATE');mKonecTime.Enabled:= True;
                                                                                                                                                mForm1.InsertControl(mKonecTime);
                                                                                                                                                mL_operation:= TLabel.Create(mForm1);mL_operation.Parent := mForm1;mL_operation.Caption := 'Cena :';mL_operation.Top := 10;mL_operation.Left := 450;mL_operation.Height := 150;mL_operation.Width := 80;
                                                                                                                                                mEd_quantity := TEdit.Create(mForm1);mEd_quantity.Left := 500;mEd_quantity.Top := 10;mEd_quantity.Width := 100;mEd_quantity.Name := 'mEd_quantity';mEd_quantity.Text:=NxFloatToIBStr(mF_pausal_prace);mForm1.InsertControl(mEd_quantity);
                                                                                                                                                mL1_operation:= TLabel.Create(mForm1); mL1_operation.Parent := mForm1;mL1_operation.Caption := 'Doprava :';mL1_operation.Top := 10; mL1_operation.Left := 550;mL1_operation.Height := 13;mL1_operation.Width := 150;
                                                                                                                                                mEd1_quantity := TEdit.Create(mForm1);mEd1_quantity.Left := 660;mEd1_quantity.Top := 10;mEd1_quantity.Width := 100;mEd1_quantity.Name := 'mEd1_quantity';mEd1_quantity.Text:='0';mForm1.InsertControl(mEd1_quantity);
                                                                                                                                                mL1_C_protokol:= TLabel.Create(mForm1);
                                                                                                                                                mL1_C_protokol.Parent := mForm1; mL1_C_protokol.Caption := 'Protokol :' + mBO_ML.getFieldValueAsString('X_protokol_prefix');mL1_C_protokol.Top := 14;mL1_C_protokol.Left := 800;mL1_C_protokol.Height := 13;mL1_C_protokol.Width := 60;
                                                                                                                                                mEd1_C_protokol := TEdit.Create(mForm1);mEd1_C_protokol.Left := 880;mEd1_C_protokol.Top := 10;mEd1_C_protokol.Width := 100;mEd1_C_protokol.Name := 'mEd1_C_protokol';mEd1_C_protokol.Text:=mBO_ML.GetFieldValueAsString('X_Protokol');mForm1.InsertControl(mEd1_C_protokol);
                                                                                                                                                mL1_C_chyby:= TLabel.Create(mForm1);mL1_C_chyby.Parent := mForm1;mL1_C_chyby.Caption := 'Závada :';mL1_C_chyby.Top := 14;mL1_C_chyby.Left := 1000;mL1_C_chyby.Height := 13;mL1_C_chyby.Width := 50;
                                                                                                                                                mEd1_C_chyby := TEdit.Create(mForm1);mEd1_C_chyby.Left := 1070;mEd1_C_chyby.Top := 10; mEd1_C_chyby.Width := 100;mEd1_C_chyby.Name := 'mEd1_C_chyby';mEd1_C_chyby.Text:=mBO_ML.GetFieldValueAsString('X_zavada_code');mForm1.InsertControl(mEd1_C_chyby);
                                                                                                                                                mL1_P_Cyklu:= TLabel.Create(mForm1);mL1_P_Cyklu.Parent := mForm1;mL1_P_Cyklu.Caption := 'Cyklů :';mL1_P_Cyklu.Top := 14;mL1_P_Cyklu.Left := 1190;mL1_P_Cyklu.Height := 13;mL1_P_Cyklu.Width := 50;
                                                                                                                                                mEd1_P_Cyklu := TEdit.Create(mForm1);mEd1_P_Cyklu.Left := 1250; mEd1_P_Cyklu.Top := 10;mEd1_P_Cyklu.Width := 80;mEd1_P_Cyklu.Name := 'mEd1_P_Cyklu';mEd1_P_Cyklu.Text:=inttostr(mBO_ML.GetFieldValueAsInteger('X_Pocet_cyklu'));mForm1.InsertControl(mEd1_P_Cyklu);
                                                                                                                                                mBtn := TButton.Create(mForm1);mBtn.Width := 75;mBtn.Height := 25;mBtn.Caption := 'OK';mBtn.ModalResult := mrOk;mBtn.Cancel := False;mBtn.Default := True;mBtn.Left :=  mForm1.Width - 2*(mBtn.Width+2) - 20;mBtn.Top := mForm1.Height - mBtn.Height - 40;mBtn.Name := 'btnOK';mForm1.InsertControl(mBtn);
                                                                                                                                                mBtn := TButton.Create(mForm1);mBtn.Width := 75;mBtn.Height := 25;mBtn.Caption := 'Storno';mBtn.ModalResult := mrCancel;mBtn.Cancel := True;mBtn.Left := mForm1.Width - (mBtn.Width+2) - 20;mBtn.Top := mForm1.Height - mBtn.Height - 40;mBtn.Name := 'btnCancel';mForm1.InsertControl(mBtn);

                                                                                                                                                   if mForm1.ShowModal(xSite) = mrOK then begin
                                                                                                                                                             mB_pokracovat:=true;
                                                                                                                                                             mpausal:=trunc(100/mIDs_WorkerRole.count)*0.01;
                                                                                                                                                             mpausal_oprava:=1-(mIDs_WorkerRole.count*mpausal);
                                                                                                                                                             mBO_ML.SetFieldValueAsString('X_zavada_code',mEd1_C_chyby.Text);
                                                                                                                                                                 mBO_ML.SetFieldValueAsString('X_Protokol',mEd1_C_protokol.Text);
                                                                                                                                                                 mBO_ML.SetFieldValueAsInteger('X_Pocet_cyklu',StrToInt(mEd1_P_Cyklu.Text));
                                                                                                                                                       mList_pomoc:= TStringList.Create;
                                                                                                                                                       try
                                                                                                                                                               for mI_MLRow := 0 to mRows_ML.Count - 1 do begin
                                                                                                                                                                    if (mRows_ML.BusinessObject[mI_MLRow].GetFieldValueAsinteger('itemtype')=0) and (mRows_ML.BusinessObject[mI_MLRow].GetFieldValueAsinteger('ToInvoiceType') =0 )then begin
                                                                                                                                                                          mWorkerRole_ID:=mRows_ML.BusinessObject[mI_MLRow].GetFieldValueAsString('X_WorkerRole_ID');

                                                                                                                                                                        if (mRows_ML.BusinessObject[mI_MLRow].GetFieldValueAsString('Storecard_ID')='11J1000101') or
                                                                                                                                                                              (mRows_ML.BusinessObject[mI_MLRow].GetFieldValueAsString('Storecard_ID')='2ZI1000101') then begin

                                                                                                                                                                              mList_pomoc.AddObject(mRows_ML.BusinessObject[mI_MLRow].OID, mRows_ML.BusinessObject[mI_MLRow]);
                                                                                                                                                                              mWorkHoursReal:=mpausal+mpausal_oprava ;
                                                                                                                                                                              mpocet_km:=NxIBStrToFloat(mEd1_quantity.text) ;
                                                                                                                                                                              mDateto:=trunc(mKonecDAte.DateTime) + frac((mKonecTime.Time));
                                                                                                                                                                              mstore:=mRows_ML.BusinessObject[mI_MLRow].GetFieldValueAsString('Store_id');
                                                                                                                                                                              mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('WorkHoursReal',mWorkHoursReal);
                                                                                                                                                                              mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('WorkHoursPlanned',mWorkHoursReal);
                                                                                                                                                                              mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('Quantity',mWorkHoursReal);
                                                                                                                                                                              mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('QuantityDelivered',mWorkHoursReal);
                                                                                                                                                                              mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsDateTime('X_konec_prace',mDateto);
                                                                                                                                                                              mPosIndex := mRows_ML.BusinessObject[mI_MLRow].GetFieldValueAsInteger('PosIndex');
                                                                                                                                                                              mquantity:=mWorkHoursReal;
                                                                                                                                                                              //mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('WorkHoursReal',1);
                                                                                                                                                                              mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsinteger('itemtype',4);
                                                                                                                                                                              mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsinteger('ToInvoiceType',1);
                                                                                                                                                                              mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsString('Text','Práce - evidenční pro mzdy');
                                                                                                                                                                              mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('WorkHoursPlanned',mWorkHoursReal);
                                                                                                                                                                              mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('Quantity',mWorkHoursReal);
                                                                                                                                                                              mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('QuantityDelivered',mWorkHoursReal);
                                                                                                                                                                              mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsString('Qunit','ks');
                                                                                                                                                                              //mRows_ML.BusinessObject[i].SetFieldValueAsinteger('IsInvoiced',1);
                                                                                                                                                                              mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsBoolean('X_storno',true);
                                                                                                                                                                              mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('UnitPriceWithVAT',0);
                                                                                                                                                                              mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('UnitPriceWithoutVAT',0);
                                                                                                                                                                              mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsString('WorkerRole_ID',mWorkerRole_ID);
                                                                                                                                                                        end;

                                                                                                                                                                    end;
                                                                                                                                                               end;
                                                                                                                                                               for i01 := 0 to mList_pomoc.Count-1 do begin
                                                                                                                                                                    mRow_Pomoc := TNxCustomBusinessObject(mList_pomoc.Objects[i01]);
                                                                                                                                                                    mWorkerRole_ID:=mRow_Pomoc.GetFieldValueAsString('WorkerRole_ID');

                                                                                                                                                                                      mNewRow := mRows_ML.AddNewObject;
                                                                                                                                                                                      mNewRow.SetFieldValueAsInteger('itemtype',0);          // 0 práce , 1 skladová karta
                                                                                                                                                                                      //mNewRow.SetFieldValueAsString('serviceworkcategory_id','');
                                                                                                                                                                                      mNewRow.SetFieldValueAsString('WorkerRole_ID',mWorkerRole_ID);
                                                                                                                                                                                      mNewRow.SetFieldValueAsString('X_WorkerRole_ID',mWorkerRole_ID);
                                                                                                                                                                                      mNewRow.SetFieldValueAsString('X_Osoba',mNewRow.GetFieldValueAsString('X_WorkerRole_ID.Name'));
                                                                                                                                                                                      mNewRow.SetFieldValueAsString('Text','Paušál práce');
                                                                                                                                                                                      mNewRow.SetFieldValueAsString('Store_id',mStore);
                                                                                                                                                                                      mNewRow.SetFieldValueAsString('StoreCard_id','1ZI1000101');
                                                                                                                                                                                      mNewRow.SetFieldValueAsfloat('WorkHoursPlanned',mpausal+mpausal_oprava);
                                                                                                                                                                                      mNewRow.SetFieldValueAsfloat('WorkHoursReal',mpausal+mpausal_oprava);
                                                                                                                                                                                      mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',NxIBStrToFloat(mEd_quantity.Text));
                                                                                                                                                                                      mNewRow.SetFieldValueAsfloat('X_radkova_sleva',0);
                                                                                                                                                                                      mNewRow.SetFieldValueAsDateTime('X_konec_prace',mDateto);
                                                                                                                                                                                      mpausal_oprava:=0;


                                                                                                                                                               End;
                                                                                                                                                         finally
                                                                                                                                                             mList_pomoc.free;
                                                                                                                                                         end;
                                                                                                                                                   end else begin
                                                                                                                                                   mB_pokracovat:=false;
                                                                                                                                                   end;
                                                                                                                                          end;
                                                                                                                                   //end;  //počet















                                                                                                                                 //paušál

                                                                                                                            end else begin

                                                                                                                                        mList_pomoc:= TStringList.Create;
                                                                                                                                        try
                                                                                                                                            for mI_MLRow:=0 to mRows_ML.count-1 do begin

                                                                                                                                                 if ((mRows_ML.BusinessObject[mI_MLRow].GetFieldValueAsinteger('itemtype')=0) and (mRows_ML.BusinessObject[mI_MLRow].GetFieldValueAsinteger('ToInvoiceType') =0 ) and ((mRows_ML.BusinessObject[mI_MLRow].GetFieldValueAsString('Storecard_ID')='11J1000101') or
                                                                                                                                                        (mRows_ML.BusinessObject[mI_MLRow].GetFieldValueAsString('Storecard_ID')='2ZI1000101'))) and mB_pokracovat then begin
                                                                                                                                                         mList_pomoc.AddObject(mRows_ML.BusinessObject[mI_MLRow].OID, mRows_ML.BusinessObject[mI_MLRow]);
                                                                                                                                                               mquantity:=mRows_ML.BusinessObject[mI_MLRow].getFieldValueAsFloat('WorkHoursReal');
                                                                                                                                                               mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsString('X_workerRole_id',mRows_ML.BusinessObject[mI_MLRow].getFieldValueAsString('WorkerRole_id'));
                                                                                                                                                               mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('WorkHoursPlanned',mquantity);
                                                                                                                                                               mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('Quantity',mquantity);
                                                                                                                                                               mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('QuantityDelivered',mquantity);
                                                                                                                                                               mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsinteger('itemtype',4);
                                                                                                                                                               mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsinteger('ToInvoiceType',1);
                                                                                                                                                               mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsString('Text','Práce - evidenční pro mzdy');
                                                                                                                                                               mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('WorkHoursPlanned',mquantity);
                                                                                                                                                               mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('Quantity',mquantity);
                                                                                                                                                               mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('QuantityDelivered',mquantity);
                                                                                                                                                               mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsString('Qunit','hod');

                                                                                                                                                               mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsBoolean('X_storno',true);
                                                                                                                                                               mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('UnitPriceWithVAT',0);
                                                                                                                                                               mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsFloat('UnitPriceWithoutVAT',0);
                                                                                                                                                               mRows_ML.BusinessObject[mI_MLRow].SetFieldValueAsDateTime('X_konec_prace',mDateto);

                                                                                                                                               end;

                                                                                                                                            end;
                                                                                                                                            for i01 := 0 to mList_pomoc.Count-1 do begin
                                                                                                                                                mRow_Pomoc := TNxCustomBusinessObject(mList_pomoc.Objects[i01]);
                                                                                                                                                mWorkerRole_ID:=mRow_Pomoc.GetFieldValueAsString('WorkerRole_ID');
                                                                                                                                                mBO_SecurityRole:=xSite.BaseObjectSpace.CreateObject('QRDGQ1DV2CU4D3TOUMORZ0LWIW');

                                                                                                                                                if mPRzac=0 then mPRzac:=EncodeTime(7,0,0,0);
                                                                                                                                                if mPRkon=0 then mPRkon:=EncodeTime(15,30,0,0);



                                                                                                                                                                      mForm1 := TForm.Create(xSite);
                                                                                                                                                                      try

                                                                                                                                                                          mForm1.Caption := 'Evidence pro mzdy';mForm1.FormStyle := fsStayOnTop;mForm1.BorderStyle := bsDialog;mForm1.Width := 1350;mForm1.Height := 100;mForm1.Scaled := False;mform1.Position := poScreenCenter;
                                                                                                                                                                              mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := 'Technik :';mL_Technik.Top := 14;mL_Technik.Left := 10;mL_Technik.Height := 13;
                                                                                                                                                                              mL_technik_value:= TLabel.Create(mForm1);mL_technik_value.Parent := mForm1;mL_technik_value.Caption := mRow_Pomoc.GetFieldValueAsString('X_WorkerRole_ID.Name');mL_technik_value.Top := 14;mL_technik_value.Left := 80;mL_technik_value.Height := 13;mL_technik_value.Width := 120;
                                                                                                                                                                              mL_technik1_value:= TLabel.Create(mForm1);mL_technik1_value.Parent := mForm1;mL_technik1_value.Caption := ('Konec práce');mL_technik1_value.Top := 14;mL_technik1_value.Left := 200;mL_technik1_value.Height := 13;mL_technik1_value.Width := 200;
                                                                                                                                                                              mKonecDAte := TDatetimeEdit.Create(mForm1);mKonecDAte.Left := 300;mKonecDAte.Top := 10;mKonecDAte.Width := 80;mKonecDAte.Name := 'mKonecDAte';mKonecDAte.DateTime:= trunc(mdateto); mKonecDAte.Enabled:=true;mForm1.InsertControl(mKonecDAte);
                                                                                                                                                                              mKonecTime := TTimeEdit.Create(mForm1);mKonecTime.Left := 380;mKonecTime.Top := 10;mKonecTime.Width := 80;mKonecTime.Name := 'mKonecTime';mKonecTime.Time:= frac(mDateto); mKonecTime.Enabled:= True;mForm1.InsertControl(mKonecTime);
                                                                                                                                                                              mL_operation:= TLabel.Create(mForm1);mL_operation.Parent := mForm1;mL_operation.Caption := 'Doba práce :';mL_operation.Top := 14;mL_operation.Left := 480;mL_operation.Height := 13;mL_operation.Width := 120;
                                                                                                                                                                              mEd_quantity := TEdit.Create(mForm1);mEd_quantity.Left := 570;mEd_quantity.Top := 10;mEd_quantity.Width := 30;mEd_quantity.Name := 'mEd_quantity'; mEd_quantity.Text:=NxFloatToIBStr(mF_doba);mForm1.InsertControl(mEd_quantity);
                                                                                                                                                                              mL1_operation:= TLabel.Create(mForm1); mL1_operation.Parent := mForm1;mL1_operation.Caption := 'Doprava :';mL1_operation.Top := 14;mL1_operation.Left := 630;mL1_operation.Height := 13;mL1_operation.Width := 80;
                                                                                                                                                                              mEd1_quantity := TEdit.Create(mForm1);mEd1_quantity.Left := 680;mEd1_quantity.Top := 10;mEd1_quantity.Width := 50;mEd1_quantity.Name := 'mEd1_quantity';mEd1_quantity.Text:=NxFloatToIBStr(mRow_Pomoc.GetFieldValueAsFloat('Quantity'));mForm1.InsertControl(mEd1_quantity);
                                                                                                                                                                              mEd1_Pohotovost := TCheckBox.Create(mForm1);mEd1_Pohotovost.Left := 750;mEd1_Pohotovost.Top := 12;mEd1_Pohotovost.Width := 100;mEd1_Pohotovost.Name := 'mEd1_Pohotovost';mEd1_pohotovost.Caption:='Pohotovost';if mRow_Pomoc.GetFieldValueAsBoolean('X_Pohotovost')= true then mEd1_Pohotovost.State:=1;if mRow_Pomoc.GetFieldValueAsBoolean('X_Pohotovost')= false then mEd1_Pohotovost.State:=0;mForm1.InsertControl(mEd1_Pohotovost);
                                                                                                                                                                              mL1_C_protokol:= TLabel.Create(mForm1);mL1_C_protokol.Parent := mForm1;mL1_C_protokol.Caption := 'Protokol :' + mBO_ML.getFieldValueAsString('X_protokol_prefix');mL1_C_protokol.Top := 14;mL1_C_protokol.Left := 840;mL1_C_protokol.Height := 13;mL1_C_protokol.Width := 60;
                                                                                                                                                                              mEd1_C_protokol := TEdit.Create(mForm1);mEd1_C_protokol.Left := 900;mEd1_C_protokol.Top := 10;mEd1_C_protokol.Width := 100;mEd1_C_protokol.Name := 'mEd1_C_protokol';mEd1_C_protokol.Text:=mBO_ML.GetFieldValueAsString('X_Protokol');mForm1.InsertControl(mEd1_C_protokol);
                                                                                                                                                                              mL1_C_chyby:= TLabel.Create(mForm1);mL1_C_chyby.Parent := mForm1;mL1_C_chyby.Caption := 'Závada :';mL1_C_chyby.Top := 14;mL1_C_chyby.Left := 1020;mL1_C_chyby.Height := 13;mL1_C_chyby.Width := 50;
                                                                                                                                                                              mEd1_C_chyby := TEdit.Create(mForm1);mEd1_C_chyby.Left := 1070;mEd1_C_chyby.Top := 10;mEd1_C_chyby.Width := 100;mEd1_C_chyby.Name := 'mEd1_C_chyby';mEd1_C_chyby.Text:=mBO_ML.GetFieldValueAsString('X_zavada_code');mForm1.InsertControl(mEd1_C_chyby);
                                                                                                                                                                              mL1_P_Cyklu:= TLabel.Create(mForm1);mL1_P_Cyklu.Parent := mForm1;mL1_P_Cyklu.Caption := 'Cyklů :';mL1_P_Cyklu.Top := 14;mL1_P_Cyklu.Left := 1190;mL1_P_Cyklu.Height := 13;mL1_P_Cyklu.Width := 50;
                                                                                                                                                                              mEd1_P_Cyklu := TEdit.Create(mForm1);mEd1_P_Cyklu.Left := 1250;mEd1_P_Cyklu.Top := 10;mEd1_P_Cyklu.Width := 80;mEd1_P_Cyklu.Name := 'mEd1_P_Cyklu';mEd1_P_Cyklu.Text:=inttostr(mBO_ML.GetFieldValueAsInteger('X_Pocet_cyklu'));mForm1.InsertControl(mEd1_P_Cyklu);
                                                                                                                                                                          mBtn := TButton.Create(mForm1);mBtn.Width := 75;mBtn.Height := 25;mBtn.Caption := 'OK';mBtn.ModalResult := mrOk;mBtn.Cancel := False;mBtn.Default := True;mBtn.Left :=  mForm1.Width - 2*(mBtn.Width+2) - 20;mBtn.Top := mForm1.Height - mBtn.Height - 40;mBtn.Name := 'btnOK';mForm1.InsertControl(mBtn);
                                                                                                                                                                          mBtn := TButton.Create(mForm1);mBtn.Width := 75;mBtn.Height := 25;mBtn.Caption := 'Storno';mBtn.ModalResult := mrCancel; mBtn.Cancel := True;mBtn.Left := mForm1.Width - (mBtn.Width+2) - 20; mBtn.Top := mForm1.Height - mBtn.Height - 40;mBtn.Name := 'btnCancel';mForm1.InsertControl(mBtn);
                                                                                                                                                                               if mForm1.ShowModal(xSite) = mrOK then begin
                                                                                                                                                                                       mB_pokracovat:=true;
                                                                                                                                                                                       mD_ML_End:=trunc(mKonecDAte.DateTime)+mKonectime.Time;
                                                                                                                                                                                       mDateto:=trunc(mKonecDAte.DateTime)+mKonectime.Time;

                                                                                                                                                                                       if mEd1_Pohotovost.State=0 then mRow_Pomoc.setFieldValueAsBoolean('X_Pohotovost',false);
                                                                                                                                                                                       if mEd1_Pohotovost.State=1 then mRow_Pomoc.setFieldValueAsBoolean('X_Pohotovost',True);
                                                                                                                                                                                       mBO_ML.SetFieldValueAsString('X_zavada_code',mEd1_C_chyby.Text);
                                                                                                                                                                                       mBO_ML.SetFieldValueAsString('X_Protokol',mEd1_C_protokol.Text);
                                                                                                                                                                                       mBO_ML.SetFieldValueAsInteger('X_Pocet_cyklu',StrToInt(mEd1_P_Cyklu.Text));


                                                                                                                                                                                       mWorkHoursReal:=NxIBStrToFloat(mEd_quantity.text) ;
                                                                                                                                                                                       mpocet_km:=NxIBStrToFloat(mEd1_quantity.text) ;
                                                                                                                                                                                       mDateto:=trunc(mKonecDAte.DateTime) + frac((mKonecTime.Time));
                                                                                                                                                                                       mRow_Pomoc.SetFieldValueAsFloat('WorkHoursReal',mWorkHoursReal);
                                                                                                                                                                                       mRow_Pomoc.SetFieldValueAsDateTime('X_konec_prace',mD_ML_End);

                                                                                                                                                                               end else begin
                                                                                                                                                                                  mB_pokracovat:=false;
                                                                                                                                                                               end;

                                                                                                                                                                      finally
                                                                                                                                                                          mForm1.Free;
                                                                                                                                                                      end;
                                                                                                                                                                      msleva:=mRow_Pomoc.getFieldValueAsinteger('X_radkova_sleva');
                                                                                                                                                                      if ((mRow_Pomoc.getFieldValueAsFloat('WorkHoursReal')<=0) and (mWorkHoursReal<>0)) and (not mB_pokracovat) then begin
                                                                                                                                                                           if mB_pokracovat then nxShowSimpleMessage('Operace byla přerušena',nil) else  nxShowSimpleMessage('Není zadaná reálně odpracovaná doba, nelze pokračovat',nil);
                                                                                                                                                                      end else begin
                                                                                                                                                                            mstore:=mRow_Pomoc.getFieldValueAsString('Store_id');

                                                                                                                                                                               mDatefrom:=mDateto - EncodeTime(trunc(mF_doba),trunc(frac(trunc(mF_doba)*60)),0,0);
                                                                                                                                                                                  if mB_pokracovat then begin // není záruka
                                                                                                                                                                                              mF_svatek:=0;mF_vikend:=0;mF_mimo:=0;mF_prace:=0;mFS_svatek:=0;mFS_vikend:=0;mFS_mimo:=0;mFS_prace:=0;mDateZac:=frac(mPRzac);mDateKon:=frac(mPRkon);
                                                                                                                                                                                            if trunc(mDateto)=trunc(mDatefrom) then begin          // jednodenní operace
                                                                                                                                                                                                 mF_svatek:=Svatek(mBO_ML.ObjectSpace,mDatefrom,mDateto);
                                                                                                                                                                                                      if mF_svatek=0 then begin
                                                                                                                                                                                                          mF_vikend:=vikend(mBO_ML.ObjectSpace,mDatefrom,mDateto);
                                                                                                                                                                                                             if mF_vikend=0 then begin
                                                                                                                                                                                                               mF_Mimo:=Mimo(mBO_ML.ObjectSpace,frac(mDatefrom),frac(mDateto),frac(mDateZac),frac(mDateKon));
                                                                                                                                                                                                               mF_Prace:=Pracovni_doba(mBO_ML.ObjectSpace,frac(mDatefrom),frac(mDateto),frac(mDateZac),frac(mDateKon));
                                                                                                                                                                                                             end;
                                                                                                                                                                                                      end;
                                                                                                                                                                                                  mFS_svatek:=mFS_svatek+mF_svatek;
                                                                                                                                                                                                  mFS_vikend:=mFS_vikend+mF_vikend;
                                                                                                                                                                                                  mFS_Mimo:=mFS_Mimo+mF_Mimo;
                                                                                                                                                                                                  mFS_Prace:=mFS_Prace+mF_Prace;// jednodenní práce
                                                                                                                                                                                            end else begin
                                                                                                                                                                                                mDnu:=trunc(mDateto)-trunc(mDatefrom) ;
                                                                                                                                                                                                for II:=0 to mDnu do begin
                                                                                                                                                                                                   if (trunc(mDateFrom)+ii=trunc(mDatefrom)) or (trunc(mDateFrom)+ii=trunc(mDateto)) then begin       // necelý den
                                                                                                                                                                                                       if (trunc(mDateFrom)+ii=trunc(mDatefrom)) then begin  // první den
                                                                                                                                                                                                            //if ladit then NxShowSimpleMessage('První den',nil);
                                                                                                                                                                                                            mF_svatek:=Svatek(mBO_ML.ObjectSpace,mDatefrom,mDateto);
                                                                                                                                                                                                            if mF_svatek=0 then begin
                                                                                                                                                                                                                  mF_vikend:=vikend(mBO_ML.ObjectSpace,mDatefrom,trunc(mdatefrom)+1);
                                                                                                                                                                                                                  if mF_vikend=0 then begin
                                                                                                                                                                                                                        mF_Mimo:=Mimo(mBO_ML.ObjectSpace,frac(mDatefrom),1,frac(mDateZac),frac(mDateKon));
                                                                                                                                                                                                                        mF_Prace:=Pracovni_doba(mBO_ML.ObjectSpace,frac(mDatefrom),1,frac(mDateZac),frac(mDateKon));
                                                                                                                                                                                                                  end;
                                                                                                                                                                                                            end;
                                                                                                                                                                                                       end;
                                                                                                                                                                                                       if (trunc(mDateFrom)+ii=trunc(mDateto)) then begin    // poslední den
                                                                                                                                                                                                            mF_svatek:=Svatek(mBO_ML.ObjectSpace,trunc(mDateto),mDateto);
                                                                                                                                                                                                            //if ladit then NxShowSimpleMessage('Poslední den',nil);
                                                                                                                                                                                                            if mF_svatek=0 then begin
                                                                                                                                                                                                                  mF_vikend:=vikend(mBO_ML.ObjectSpace,trunc(mDateto),mDateto);
                                                                                                                                                                                                                  if mF_vikend=0 then begin
                                                                                                                                                                                                                        mF_Mimo:=Mimo(mBO_ML.ObjectSpace,0,frac(mDateto),frac(mDateZac),frac(mDateKon));
                                                                                                                                                                                                                        mF_Prace:=Pracovni_doba(mBO_ML.ObjectSpace,0,frac(mDateto),frac(mDateZac),frac(mDateKon));
                                                                                                                                                                                                                  end;
                                                                                                                                                                                                            end;
                                                                                                                                                                                                       end;
                                                                                                                                                                                                   end else begin    // celý den
                                                                                                                                                                                                      mF_svatek:=Svatek(mBO_ML.ObjectSpace,trunc(mDatefrom)+ii,trunc(mDatefrom)+1+ii);
                                                                                                                                                                                                            if mF_svatek=0 then begin
                                                                                                                                                                                                                  mF_vikend:=vikend(mBO_ML.ObjectSpace,trunc(mDatefrom)+ii,trunc(mDatefrom)+1+ii);
                                                                                                                                                                                                                  if mF_vikend=0 then begin
                                                                                                                                                                                                                       // if ladit then NxShowSimpleMessage('Celý den',nil);
                                                                                                                                                                                                                        mF_Mimo:=Mimo(mBO_ML.ObjectSpace,trunc(mDatefrom)+ii,trunc(mDatefrom)+1+ii,frac(mDateZac),frac(mDateKon));
                                                                                                                                                                                                                        mF_Prace:=Pracovni_doba(mBO_ML.ObjectSpace,trunc(mDatefrom)+ii,trunc(mDatefrom)+1+ii,frac(mDateZac),frac(mDateKon));
                                                                                                                                                                                                                  end;
                                                                                                                                                                                                            end;
                                                                                                                                                                                                      end;
                                                                                                                                                                                                  mFS_svatek:=mFS_svatek+mF_svatek;
                                                                                                                                                                                                  mFS_vikend:=mFS_vikend+mF_vikend;
                                                                                                                                                                                                  mFS_Mimo:=mFS_Mimo+mF_Mimo;
                                                                                                                                                                                                  mFS_Prace:=mFS_Prace+mF_Prace;


                                                                                                                                                                                                end;
                                                                                                                                                                                            end;
                                                                                                                                                                                            mkorekce:=0;
                                                                                                                                                                                            mFS_Prace:=NxIBStrToFloat(FormatDateTime('H',mFS_Prace)) + (NxIBStrToFloat(FormatDateTime('N',mFS_Prace))*(100/60));
                                                                                                                                                                                            mFS_Mimo:=NxIBStrToFloat(FormatDateTime('H',mFS_Mimo))+ (NxIBStrToFloat(FormatDateTime('N',mFS_Mimo))*(100/60));
                                                                                                                                                                                            if mfs_mimo<0 then begin
                                                                                                                                                                                               mFS_Prace:=mFS_Prace+mFS_Mimo;
                                                                                                                                                                                               mFS_Prace:=NxIBStrToFloat(FormatDateTime('H',mFS_Prace)) + (NxIBStrToFloat(FormatDateTime('N',mFS_Prace))*(100/60));
                                                                                                                                                                                               mFS_Mimo:=0;
                                                                                                                                                                                               end else begin
                                                                                                                                                                                               mFS_Mimo:=NxIBStrToFloat(FormatDateTime('H',mFS_Mimo))+ (NxIBStrToFloat(FormatDateTime('N',mFS_Mimo))*(100/60));
                                                                                                                                                                                            end;
                                                                                                                                                                                            mFS_svatek:=NxIBStrToFloat(FormatDateTime('H',mFS_svatek))+ (NxIBStrToFloat(FormatDateTime('N',mFS_svatek))*(100/60));
                                                                                                                                                                                            mFS_vikend:=NxIBStrToFloat(FormatDateTime('H',mF_vikend))+ (NxIBStrToFloat(FormatDateTime('N',mF_vikend))*(100/60));



                                                                                                                                                                                            if mWorkHoursReal<>(mFS_svatek+mFS_vikend +mFS_Mimo+mFS_Prace) then begin
                                                                                                                                                                                                    mkorekce:=mWorkHoursReal-(mFS_svatek+mFS_vikend+mFS_Mimo+mFS_Prace) ;
                                                                                                                                                                                                    if mFS_vikend+mFS_svatek>0 then begin
                                                                                                                                                                                                       mFS_vikend:=(mFS_vikend+mkorekce);
                                                                                                                                                                                                       mkorekce:=0;
                                                                                                                                                                                                    end;
                                                                                                                                                                                                    if mFS_Mimo>0 then begin
                                                                                                                                                                                                       mFS_Mimo:=(mFS_Mimo+mkorekce);
                                                                                                                                                                                                       mkorekce:=0;
                                                                                                                                                                                                    end else begin
                                                                                                                                                                                                           mFS_Prace:=mWorkHoursReal-(mFS_svatek+mFS_vikend+mFS_Mimo)
                                                                                                                                                                                                    end;
                                                                                                                                                                                            end;
                                                                                                                                                                                            mForm1 := TForm.Create(xSite);
                                                                                                                                                                                             try
                                                                                                                                                                                                  mForm1.Caption := 'Rozpočtení práce pro fakturaci';mForm1.FormStyle := fsStayOnTop;mForm1.BorderStyle := bsDialog;mForm1.Width := 450; mForm1.Height := 450;mForm1.Scaled := False;mForm1.Position := poScreenCenter;
                                                                                                                                                                                                  mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := 'Technik :';mL_Technik.Top := 12;mL_Technik.Left := 10;mL_Technik.Height := 13;
                                                                                                                                                                                                  mL_technik_value:= TLabel.Create(mForm1);mL_technik_value.Parent := mForm1;mL_technik_value.Caption := mRow_Pomoc.GetFieldValueAsString('X_WorkerRole_ID.Name');mL_technik_value.Top := 12;mL_technik_value.Left := 80;mL_technik_value.Height := 13;mL_technik_value.Width := 200;
                                                                                                                                                                                                  mL_technik_value:= TLabel.Create(mForm1);mL_technik_value.Parent := mForm1; mL_technik_value.Caption := ('Konec práce');mL_technik_value.Top := 10;mL_technik_value.Left := 150;mL_technik_value.Height := 13;mL_technik_value.Width := 200;
                                                                                                                                                                                                  mKonecDAte := TDateTimeEdit.Create(mForm1);mKonecDAte.Left := 230;mKonecDAte.Top := 10;mKonecDAte.Width := 80;mKonecDAte.Name := 'mKonecDAte';mKonecDAte.DateTime:= mDateto;mKonecDAte.Enabled:=false;mForm1.InsertControl(mKonecDAte);
                                                                                                                                                                                                  mKonecTime := TTimeEdit.Create(mForm1);mKonecTime.Left := 330;mKonecTime.Top := 10;mKonecTime.Width := 80;mKonecTime.Name := 'mKonecTime';mKonecTime.Time:= mDateto;mKonecTime.Enabled:= False;mForm1.InsertControl(mKonecTime);

                                                                                                                                                                                                   if true then begin
                                                                                                                                                                                                       mL_operation:= TLabel.Create(mForm1);mL_operation.Parent := mForm1;mL_operation.Caption := 'Práce paušál :';mL_operation.Top := 42;mL_operation.Left := 10;mL_operation.Height := 13;mL_operation.Width := 320;
                                                                                                                                                                                                       mEd_quantity := TEdit.Create(mForm1);mEd_quantity.Left := 150;mEd_quantity.Top := 42;mEd_quantity.Width := 80;mEd_quantity.Name := 'mEd_quantity';if mF_pausal_prace<>0 then mEd_quantity.Text:='0' else mEd_quantity.Text:='0' ;mForm1.InsertControl(mEd_quantity);
                                                                                                                                                                                                       mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1; mL_Technik.Caption := 'ks';mL_Technik.Top := 42;mL_Technik.Left := 240 ;mL_Technik.Height := 13;
                                                                                                                                                                                                       mEd_Unitprice:= TEdit.Create(mForm1);mEd_Unitprice.Left := 280;mEd_Unitprice.Top := 40;mEd_Unitprice.Width := 80;mEd_Unitprice.Name := 'mEd_Unitprice';mEd_Unitprice.Text:=NxFloatToIBStr(mF_pausal_prace);mForm1.InsertControl(mEd_Unitprice);
                                                                                                                                                                                                       mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := '  kč/j';mL_Technik.Top := 42;mL_Technik.Left := 360;mL_Technik.Height := 13;
                                                                                                                                                                                                   end;
                                                                                                                                                                                                   mxpomoc:=0;
                                                                                                                                                                                                   if mF_pausal_Vyjezd<>0 then begin
                                                                                                                                                                                                       mxpomoc:=1;
                                                                                                                                                                                                   end;
                                                                                                                                                                                                           if true then begin
                                                                                                                                                                                                               mL_operation:= TLabel.Create(mForm1);mL_operation.Parent := mForm1;mL_operation.Caption := 'Doprava paušál :';mL_operation.Top := 72;mL_operation.Left := 10;mL_operation.Height := 13;mL_operation.Width := 320;
                                                                                                                                                                                                               mEd_quantity1 := TEdit.Create(mForm1);mEd_quantity1.Left := 150;mEd_quantity1.Top := 70;mEd_quantity1.Width := 80;mEd_quantity1.Name := 'mEd_quantity1';mEd_quantity1.Text:=NxFloatToIBStr(mxpomoc) ;mForm1.InsertControl(mEd_quantity1);mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := 'ks';mL_Technik.Top := 72; mL_Technik.Left := 240 ;mL_Technik.Height := 13;
                                                                                                                                                                                                               mEd_Unitprice1:= TEdit.Create(mForm1);mEd_Unitprice1.Left := 280;mEd_Unitprice1.Top := 70;mEd_Unitprice1.Width := 80;mEd_Unitprice1.Name := 'mEd_Unitprice1';mEd_Unitprice1.Text:=NxFloatToIBStr(mF_pausal_Vyjezd);mForm1.InsertControl(mEd_Unitprice1);
                                                                                                                                                                                                               mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := '  kč/j';mL_Technik.Top := 72;mL_Technik.Left := 360;mL_Technik.Height := 13;
                                                                                                                                                                                                           end;

                                                                                                                                                                                       {            if false then begin
                                                                                                                                                                                                       mL_operation:= TLabel.Create(mForm1);mL_operation.Parent := mForm1;mL_operation.Caption := 'Pracovní doba :';mL_operation.Top := 102;mL_operation.Left := 10;mL_operation.Height := 13;mL_operation.Width := 320;
                                                                                                                                                                                                       mEd_quantity2 := TEdit.Create(mForm1);mEd_quantity2.Left := 150; mEd_quantity2.Top := 100;mEd_quantity2.Width := 80;mEd_quantity2.Name := 'mEd_quantity2';mEd_quantity2.Text:=NxFloatToIBStr(mf_doba);mForm1.InsertControl(mEd_quantity2);
                                                                                                                                                                                                       mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := 'ks';mL_Technik.Top := 102;mL_Technik.Left := 240 ;mL_Technik.Height := 13;
                                                                                                                                                                                                       mEd_Unitprice2:= TEdit.Create(mForm1);mEd_Unitprice2.Left := 280;mEd_Unitprice2.Top := 100;mEd_Unitprice2.Width := 80;mEd_Unitprice2.Name := 'mEd_Unitprice2';mEd_Unitprice2.Text:=NxFloatToIBStr(mf_doba);mForm1.InsertControl(mEd_Unitprice2);
                                                                                                                                                                                                       mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := '  kč/j';mL_Technik.Top := 102;mL_Technik.Left := 360;mL_Technik.Height := 13;
                                                                                                                                                                                                   end;
                                                                                                                                                                                       }
                                                                                                                                                                                                   if true then begin
                                                                                                                                                                                                       mL_operation:= TLabel.Create(mForm1);mL_operation.Parent := mForm1;mL_operation.Caption := 'Pracovní doba :';mL_operation.Top := 132;mL_operation.Left := 10;mL_operation.Height := 13;mL_operation.Width := 320;
                                                                                                                                                                                                       mEd_quantity3 := TEdit.Create(mForm1);mEd_quantity3.Left := 150;mEd_quantity3.Top := 130;mEd_quantity3.Width := 80; mEd_quantity3.Name := 'mFS_prace';mEd_quantity3.Text:=NxFloatToIBStr(mFS_Prace);
                                                                                                                                                                                                       mForm1.InsertControl(mEd_quantity3);mL_Technik:= TLabel.Create(mForm1); mL_Technik.Parent := mForm1;mL_Technik.Caption := 'hod';mL_Technik.Top := 132;mL_Technik.Left := 240 ; mL_Technik.Height := 13;
                                                                                                                                                                                                       mEd_Unitprice3:= TEdit.Create(mForm1);mEd_Unitprice3.Left := 280;mEd_Unitprice3.Top := 130;mEd_Unitprice3.Width := 80; mEd_Unitprice3.Name := 'mEd_Unitprice3';mEd_Unitprice3.Text:=NxFloatToIBStr(mFSazba_Prace);mForm1.InsertControl(mEd_Unitprice3);
                                                                                                                                                                                                       mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := '  kč/j';mL_Technik.Top := 132;mL_Technik.Left := 360;mL_Technik.Height := 13;
                                                                                                                                                                                                   end;

                                                                                                                                                                                                   if true then begin
                                                                                                                                                                                                        mL_operation:= TLabel.Create(mForm1); mL_operation.Parent := mForm1;mL_operation.Caption := 'Mimo pracovní dobu :'; mL_operation.Top := 162;mL_operation.Left := 10;mL_operation.Height := 13;mL_operation.Width := 320;
                                                                                                                                                                                                        mEd_quantity4 := TEdit.Create(mForm1);mEd_quantity4.Left := 150;mEd_quantity4.Top := 160;mEd_quantity4.Width := 80;mEd_quantity4.Name := 'mEd_quantity4'; mEd_quantity4.Text:=NxFloatToIBStr(mFS_mimo);mForm1.InsertControl(mEd_quantity4);
                                                                                                                                                                                                        mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := 'hod';mL_Technik.Top := 162;mL_Technik.Left := 240 ;mL_Technik.Height := 13;
                                                                                                                                                                                                        mEd_Unitprice4:= TEdit.Create(mForm1);mEd_Unitprice4.Left := 280;mEd_Unitprice4.Top := 160;mEd_Unitprice4.Width := 80;mEd_Unitprice4.Name := 'mEd_Unitprice4';mEd_Unitprice4.Text:=NxFloatToIBStr(mFSazba_Mimo);mForm1.InsertControl(mEd_Unitprice4);
                                                                                                                                                                                                        mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := '  kč/j';mL_Technik.Top := 162;mL_Technik.Left := 360;mL_Technik.Height := 13;
                                                                                                                                                                                                   end;

                                                                                                                                                                                                   if true then begin
                                                                                                                                                                                                        mL_operation:= TLabel.Create(mForm1);mL_operation.Parent := mForm1;mL_operation.Caption := 'Víkend + Svátek :';mL_operation.Top := 192;mL_operation.Left := 10;mL_operation.Height := 13;mL_operation.Width := 320;
                                                                                                                                                                                                        mEd_quantity5 := TEdit.Create(mForm1);mEd_quantity5.Left := 150;mEd_quantity5.Top := 190;mEd_quantity5.Width := 80;mEd_quantity5.Name := 'mEd_quantity5';mEd_quantity5.Text:=NxFloatToIBStr(mFS_Vikend);mForm1.InsertControl(mEd_quantity5);
                                                                                                                                                                                                        mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := 'hod';mL_Technik.Top := 192;mL_Technik.Left := 240 ;mL_Technik.Height := 13;
                                                                                                                                                                                                        mEd_Unitprice5:= TEdit.Create(mForm1);mEd_Unitprice5.Left := 280;mEd_Unitprice5.Top := 190;mEd_Unitprice5.Width := 80;mEd_Unitprice5.Name := 'mEd_Unitprice5';mEd_Unitprice5.Text:=NxFloatToIBStr(mFSazba_Vikend);mForm1.InsertControl(mEd_Unitprice5);
                                                                                                                                                                                                        mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := '  kč/j';mL_Technik.Top := 192;mL_Technik.Left := 360;mL_Technik.Height := 13;
                                                                                                                                                                                                   end;

                                                                                                                                                                                                   if false then begin
                                                                                                                                                                                                        mL_operation:= TLabel.Create(mForm1);mL_operation.Parent := mForm1;mL_operation.Caption := 'Práce paušál :';mL_operation.Top := 222;mL_operation.Left := 10;mL_operation.Height := 13;mL_operation.Width := 320;
                                                                                                                                                                                                        mEd_quantity6 := TEdit.Create(mForm1);mEd_quantity6.Left := 150;mEd_quantity6.Top := 220;mEd_quantity6.Width := 80;mEd_quantity6.Name := 'mEd_quantity6';mEd_quantity6.Text:=NxFloatToIBStr(mf_doba);mForm1.InsertControl(mEd_quantity6);
                                                                                                                                                                                                        mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := 'ks';mL_Technik.Top := 222;mL_Technik.Left := 240 ;mL_Technik.Height := 13;
                                                                                                                                                                                                        mEd_Unitprice6:= TEdit.Create(mForm1);mEd_Unitprice6.Left := 280;mEd_Unitprice6.Top := 220;mEd_Unitprice6.Width := 80;mEd_Unitprice6.Name := 'mEd_Unitprice6';mEd_Unitprice6.Text:=NxFloatToIBStr(mf_doba);mForm1.InsertControl(mEd_Unitprice6);
                                                                                                                                                                                                        mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := '  kč/j';mL_Technik.Top := 222;mL_Technik.Left := 360;mL_Technik.Height := 13;
                                                                                                                                                                                                   end;

                                                                                                                                                                                                   if true then begin
                                                                                                                                                                                                        mL_operation:= TLabel.Create(mForm1);mL_operation.Parent := mForm1;mL_operation.Caption := 'Doprava km :';mL_operation.Top := 252;mL_operation.Left := 10;mL_operation.Height := 13;mL_operation.Width := 320;
                                                                                                                                                                                                        mEd_quantity7 := TEdit.Create(mForm1);mEd_quantity7.Left := 150;mEd_quantity7.Top := 250;mEd_quantity7.Width := 80;mEd_quantity7.Name := 'mEd_quantity7';mEd_quantity7.Text:=NxFloatToIBStr(mpocet_km);mForm1.InsertControl(mEd_quantity7);
                                                                                                                                                                                                        mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := 'km';mL_Technik.Top := 252;mL_Technik.Left := 240 ;mL_Technik.Height := 13;
                                                                                                                                                                                                        mEd_Unitprice7:= TEdit.Create(mForm1);mEd_Unitprice7.Left := 280;mEd_Unitprice7.Top := 250;mEd_Unitprice7.Width := 80;mEd_Unitprice7.Name := 'mEd_Unitprice7';mEd_Unitprice7.Text:=NxFloatToIBStr(mFSazba_Doprava_km);mForm1.InsertControl(mEd_Unitprice7);
                                                                                                                                                                                                        mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := '  kč/km';mL_Technik.Top := 252;mL_Technik.Left := 360;mL_Technik.Height := 13;
                                                                                                                                                                                                   end;

                                                                                                                                                                                                   if false then begin
                                                                                                                                                                                                        mL_operation:= TLabel.Create(mForm1);mL_operation.Parent := mForm1;mL_operation.Caption := 'Práce paušál :';mL_operation.Top := 282;mL_operation.Left := 10;mL_operation.Height := 13;mL_operation.Width := 320;
                                                                                                                                                                                                        mEd_quantity8 := TEdit.Create(mForm1);mEd_quantity8.Left := 150;mEd_quantity8.Top := 280;mEd_quantity8.Width := 80;mEd_quantity8.Name := 'mEd_quantity8';mEd_quantity8.Text:=NxFloatToIBStr(mf_doba);mForm1.InsertControl(mEd_quantity8);
                                                                                                                                                                                                        mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := 'ks';mL_Technik.Top := 282;mL_Technik.Left := 240 ;mL_Technik.Height := 13;
                                                                                                                                                                                                        mEd_Unitprice8:= TEdit.Create(mForm1);mEd_Unitprice8.Left := 280;mEd_Unitprice8.Top := 280;mEd_Unitprice8.Width := 80;mEd_Unitprice8.Name := 'mEd_Unitprice8';mEd_Unitprice8.Text:=NxFloatToIBStr(mf_doba);mForm1.InsertControl(mEd_Unitprice8);
                                                                                                                                                                                                        mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := '  kč/j';mL_Technik.Top := 282;mL_Technik.Left := 360;mL_Technik.Height := 13;
                                                                                                                                                                                                   end;

                                                                                                                                                                                                   if true then begin
                                                                                                                                                                                                        mL_operation:= TLabel.Create(mForm1);mL_operation.Parent := mForm1;mL_operation.Caption := 'Výjezd do 3 hodin :';mL_operation.Top := 312;mL_operation.Left := 10;mL_operation.Height := 13; mL_operation.Width := 320;
                                                                                                                                                                                                        mEd_quantity9 := TEdit.Create(mForm1);mEd_quantity9.Left := 150;mEd_quantity9.Top := 310;mEd_quantity9.Width := 80;mEd_quantity9.Name := 'mEd_quantity9';mEd_quantity9.Text:=NxFloatToIBStr(0);mForm1.InsertControl(mEd_quantity9);
                                                                                                                                                                                                        mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := 'ks';mL_Technik.Top := 312;mL_Technik.Left := 240 ;mL_Technik.Height := 13;
                                                                                                                                                                                                        mEd_Unitprice9:= TEdit.Create(mForm1);mEd_Unitprice9.Left := 280;mEd_Unitprice9.Top := 310;mEd_Unitprice9.Width := 80;mEd_Unitprice9.Name := 'mEd_Unitprice9';mEd_Unitprice9.Text:=NxFloatToIBStr(mFPriplatek3H);mForm1.InsertControl(mEd_Unitprice9);
                                                                                                                                                                                                        mL_Technik:= TLabel.Create(mForm1);mL_Technik.Parent := mForm1;mL_Technik.Caption := '  kč/j';mL_Technik.Top := 312;mL_Technik.Left := 360;mL_Technik.Height := 13;
                                                                                                                                                                                                   end;
                                                                                                                                                                                                  mBtn := TButton.Create(mForm1);mBtn.Width := 75;mBtn.Height := 25;mBtn.Caption := 'OK';mBtn.ModalResult := mrOk;mBtn.Cancel := False;mBtn.Default := True;mBtn.Left :=  mForm1.Width - 2*(mBtn.Width+2) - 20;mBtn.Top := mForm1.Height - mBtn.Height - 40;mBtn.Name := 'btnOK';mForm1.InsertControl(mBtn);
                                                                                                                                                                                                  mBtn := TButton.Create(mForm1);mBtn.Width := 75;mBtn.Height := 25;mBtn.Caption := 'Storno';mBtn.ModalResult := mrCancel;mBtn.Cancel := True;mBtn.Left := mForm1.Width - (mBtn.Width+2) - 20;mBtn.Top := mForm1.Height - mBtn.Height - 40;mBtn.Name := 'btnCancel';mForm1.InsertControl(mBtn);
                                                                                                                                                                                                  mBtn := TButton.Create(mForm1);mBtn.Width := 75;mBtn.Height := 25;mBtn.Caption := 'Nefakturovat';mBtn.ModalResult := mrCancel;mBtn.Cancel := True;mBtn.Left := 20;mBtn.Top := mForm1.Height - mBtn.Height - 40;mBtn.Name := 'btnIgnore';mForm1.InsertControl(mBtn);



                                                                                                                                                                                                  if (mForm1.ShowModal(xSite) = mrOK) or (mForm1.ShowModal(xSite) = mrIgnore) then begin
                                                                                                                                                                                                      mB_pokracovat:=true;
                                                                                                                                                                                                          if mForm1.ShowModal(xSite) = mrOK then begin
                                                                                                                                                                                                                mB_pokracovat:=true;
                                                                                                                                                                                                                if NxIBStrToFloat(mEd_quantity.text)>0 then begin
                                                                                                                                                                                                                            mNewRow := mRows_ML.AddNewObject;mNewRow.SetFieldValueAsInteger('Posindex',i+55);mNewRow.SetFieldValueAsInteger('itemtype',0);mNewRow.SetFieldValueAsString('WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('X_WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('Text','Paušál práce');mNewRow.SetFieldValueAsString('Store_id',mStore);mNewRow.SetFieldValueAsString('StoreCard_id','1ZI1000101');mNewRow.SetFieldValueAsfloat('WorkHoursPlanned',NxIBStrToFloat(mEd_quantity.text));mNewRow.SetFieldValueAsfloat('WorkHoursReal',NxIBStrToFloat(mEd_quantity.text));mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',NxIBStrToFloat(mEd_Unitprice.Text));mNewRow.SetFieldValueAsfloat('X_radkova_sleva',0);mNewRow.SetFieldValueAsDateTime('X_konec_prace',mDateto);
                                                                                                                                                                                                                            mNewRow.SetFieldValueAsBoolean('X_Pohotovost',mRow_Pomoc.getFieldValueAsBoolean('X_Pohotovost'));//mNewRow.Save;mNewRow.free;
                                                                                                                                                                                                                        end;
                                                                                                                                                                                                                        if NxIBStrToFloat(mEd_quantity1.text)>0 then begin
                                                                                                                                                                                                                            mNewRow := mRows_ML.AddNewObject;mNewRow.SetFieldValueAsInteger('Posindex',i+60);mNewRow.SetFieldValueAsInteger('itemtype',0);mNewRow.SetFieldValueAsString('WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('X_WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('Text','Paušál doprava');mNewRow.SetFieldValueAsString('Store_id',mStore);mNewRow.SetFieldValueAsBoolean('X_Pohotovost',mRow_Pomoc.getFieldValueAsBoolean('X_Pohotovost'));mNewRow.SetFieldValueAsString('StoreCard_id','1FD1000101');mNewRow.SetFieldValueAsfloat('WorkHoursPlanned',NxIBStrToFloat(mEd_quantity1.text));mNewRow.SetFieldValueAsfloat('WorkHoursReal',NxIBStrToFloat(mEd_quantity1.text));mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',NxIBStrToFloat(mEd_Unitprice1.Text));mNewRow.SetFieldValueAsfloat('X_radkova_sleva',0);
                                                                                                                                                                                                                            mNewRow.SetFieldValueAsDateTime('X_konec_prace',mDateto);//mNewRow.Save;mNewRow.free;
                                                                                                                                                                                                                        end;

                                                                                                                                                                                                                        if NxIBStrToFloat(mEd_quantity.Text)=0 then begin
                                                                                                                                                                                                                                  if NxIBStrToFloat(mEd_quantity3.text)>0 then begin
                                                                                                                                                                                                                                          mNewRow := mRows_ML.AddNewObject; mNewRow.SetFieldValueAsInteger('Posindex',i+65);mNewRow.SetFieldValueAsInteger('itemtype',0); mNewRow.SetFieldValueAsString('WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('X_WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('Text','Práce Pracovní doba');mNewRow.SetFieldValueAsString('Store_id',mStore);mNewRow.SetFieldValueAsString('StoreCard_id','17T0000101');mNewRow.SetFieldValueAsBoolean('X_Pohotovost',mRow_Pomoc.getFieldValueAsBoolean('X_Pohotovost'));mNewRow.SetFieldValueAsfloat('WorkHoursPlanned',NxIBStrToFloat(mEd_quantity3.text));mNewRow.SetFieldValueAsfloat('WorkHoursReal',NxIBStrToFloat(mEd_quantity3.text));mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',NxIBStrToFloat(mEd_Unitprice3.Text));mNewRow.SetFieldValueAsfloat('X_radkova_sleva',msleva);
                                                                                                                                                                                                                                          mNewRow.SetFieldValueAsDateTime('X_konec_prace',mDateto);//mNewRow.Save;mNewRow.free;
                                                                                                                                                                                                                                      end;
                                                                                                                                                                                                                                      if NxIBStrToFloat(mEd_quantity4.text)>0 then begin
                                                                                                                                                                                                                                          mNewRow := mRows_ML.AddNewObject;mNewRow.SetFieldValueAsInteger('Posindex',i+70);mNewRow.SetFieldValueAsInteger('itemtype',0); mNewRow.SetFieldValueAsString('WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('X_WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('Text','Práce mimo pracovní dobu');mNewRow.SetFieldValueAsString('Store_id',mStore);mNewRow.SetFieldValueAsString('StoreCard_id','17T0000101');mNewRow.SetFieldValueAsBoolean('X_Pohotovost',mRow_Pomoc.getFieldValueAsBoolean('X_Pohotovost'));mNewRow.SetFieldValueAsfloat('WorkHoursPlanned',NxIBStrToFloat(mEd_quantity4.text));mNewRow.SetFieldValueAsfloat('WorkHoursReal',NxIBStrToFloat(mEd_quantity4.text));mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',NxIBStrToFloat(mEd_Unitprice4.Text));mNewRow.SetFieldValueAsfloat('X_radkova_sleva',msleva);
                                                                                                                                                                                                                                          mNewRow.SetFieldValueAsDateTime('X_konec_prace',mDateto);//mNewRow.Save;mNewRow.free;
                                                                                                                                                                                                                                      end;
                                                                                                                                                                                                                                      if NxIBStrToFloat(mEd_quantity5.text)>0 then begin
                                                                                                                                                                                                                                          mNewRow := mRows_ML.AddNewObject;mNewRow.SetFieldValueAsInteger('itemtype',0);  mNewRow.SetFieldValueAsInteger('Posindex',i+75);mNewRow.SetFieldValueAsString('WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('X_WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('Text','Práce o víkendu+ svátek');mNewRow.SetFieldValueAsString('Store_id',mStore); mNewRow.SetFieldValueAsString('StoreCard_id','17T0000101');mNewRow.SetFieldValueAsfloat('WorkHoursPlanned',NxIBStrToFloat(mEd_quantity5.text));mNewRow.SetFieldValueAsfloat('WorkHoursReal',NxIBStrToFloat(mEd_quantity5.text));mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',NxIBStrToFloat(mEd_Unitprice5.Text));mNewRow.SetFieldValueAsfloat('X_radkova_sleva',msleva); mNewRow.SetFieldValueAsBoolean('X_Pohotovost',mRow_Pomoc.getFieldValueAsBoolean('X_Pohotovost'));
                                                                                                                                                                                                                                          mNewRow.SetFieldValueAsDateTime('X_konec_prace',mDateto);//mNewRow.Save;mNewRow.free;
                                                                                                                                                                                                                                      end;
                                                                                                                                                                                                                        end;
                                                                                                                                                                                                                        if NxIBStrToFloat(mEd_quantity7.text)>0 then begin
                                                                                                                                                                                                                            mNewRow := mRows_ML.AddNewObject;mNewRow.SetFieldValueAsInteger('itemtype',0); mNewRow.SetFieldValueAsInteger('Posindex',i+80);mNewRow.SetFieldValueAsString('WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('X_WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('Store_id',mStore); mNewRow.SetFieldValueAsString('StoreCard_id','54W0000101');mNewRow.SetFieldValueAsfloat('WorkHoursPlanned',NxIBStrToFloat(mEd_quantity7.text));mNewRow.SetFieldValueAsfloat('WorkHoursReal',NxIBStrToFloat(mEd_quantity7.text));mNewRow.SetFieldValueAsfloat('X_radkova_sleva',0);mNewRow.SetFieldValueAsBoolean('X_Pohotovost',mRow_Pomoc.getFieldValueAsBoolean('X_Pohotovost'));if NxIBStrToFloat(mEd_quantity1.text)=0 then begin mNewRow.SetFieldValueAsString('Text','Doprava km');
                                                                                                                                                                                                                            mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',NxIBStrToFloat(mEd_Unitprice7.Text));end else begin mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',0);mNewRow.SetFieldValueAsString('Text','Doprava km (evidenční)');mNewRow.SetFieldValueAsfloat('ToInvoiceType',1);end;mNewRow.SetFieldValueAsDateTime('X_konec_prace',mDateto);
                                                                                                                                                                                                                            //mNewRow.Save;mNewRow.free;
                                                                                                                                                                                                                        end;
                                                                                                                                                                                                                        if NxIBStrToFloat(mEd_quantity9.text)>0 then begin
                                                                                                                                                                                                                            mNewRow := mRows_ML.AddNewObject;mNewRow.SetFieldValueAsInteger('Posindex',i+85);mNewRow.SetFieldValueAsInteger('itemtype',4); mNewRow.SetFieldValueAsString('WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('X_WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsBoolean('X_Pohotovost',mRow_Pomoc.getFieldValueAsBoolean('X_Pohotovost'));mNewRow.SetFieldValueAsfloat('Quantity',NxIBStrToFloat(mEd_quantity9.text));mNewRow.SetFieldValueAsfloat('X_radkova_sleva',0);if NxIBStrToFloat(mEd_quantity9.text)=0 then begin mNewRow.SetFieldValueAsString('Text','Výjezd příplatek');mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',NxIBStrToFloat(mEd_Unitprice9.Text));mNewRow.SetFieldValueAsfloat('ToInvoiceType',1);end else begin
                                                                                                                                                                                                                            mNewRow.SetFieldValueAsString('Text','Výjezd příplatek');
                                                                                                                                                                                                                            mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',NxIBStrToFloat(mEd_Unitprice9.Text));mNewRow.SetFieldValueAsfloat('ToInvoiceType',0);end;mNewRow.SetFieldValueAsDateTime('X_konec_prace',mDateto);
                                                                                                                                                                                                                            //mNewRow.Save;mNewRow.free;
                                                                                                                                                                                                                        end;
                                                                                                                                                                                                          end else begin
                                                                                                                                                                                                             mB_pokracovat:=false;

                                                                                                                                                                                                          end; // tlačítko ok
                                                                                                                                                                                                     end;
                                                                                                                                                                                          finally
                                                                                                                                                                                              mForm1.free;
                                                                                                                                                                                          end;
                                                                                                                                                                           end else begin         // záruka
                                                                                                                                                                           {mNewRow := mRows_ML.AddNewObject;mNewRow.SetFieldValueAsFloat('WorkHoursReal',0);mNewRow.SetFieldValueAsinteger('itemtype',4);mNewRow.SetFieldValueAsString('WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('X_WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsinteger('ToInvoiceType',1);mNewRow.SetFieldValueAsString('Text','Práce - evidenční pro mzdy');mNewRow.SetFieldValueAsFloat('Quantity',mquantity);mNewRow.SetFieldValueAsString('Qunit','hod');mNewRow.SetFieldValueAsFloat('QuantityDelivered',mquantity);mNewRow.SetFieldValueAsBoolean('X_storno',true);mNewRow.SetFieldValueAsFloat('UnitPriceWithVAT',0);mNewRow.SetFieldValueAsFloat('UnitPriceWithoutVAT',0);mNewRow.SetFieldValueAsString('Store_id',mRow_Pomoc.GetFieldValueAsString('Store_id'));mNewRow.SetFieldValueAsString('StoreCard_id',mRow_Pomoc.GetFieldValueAsString('StoreCard_id'));mNewRow.SetFieldValueAsfloat('WorkHoursPlanned',mpocet_km);mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',0);mNewRow.SetFieldValueAsDateTime('X_konec_prace',mDateto);mNewRow.Save;mNewRow.free;


                                                                                                                                                                                                                if (mpocet_km)>0 then begin
                                                                                                                                                                                                                    mNewRow := mRows_ML.AddNewObject;mNewRow.SetFieldValueAsInteger('itemtype',0); mNewRow.SetFieldValueAsString('WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('X_WorkerRole_ID',mRow_Pomoc.getFieldValueAsString('X_WorkerRole_id'));mNewRow.SetFieldValueAsString('Store_id',mStore);mNewRow.SetFieldValueAsString('StoreCard_id','54W0000101');mNewRow.SetFieldValueAsfloat('WorkHoursPlanned',mpocet_km);mNewRow.SetFieldValueAsfloat('WorkHoursReal',mpocet_km);mNewRow.SetFieldValueAsfloat('UnitPriceWithoutVAT',0);mNewRow.SetFieldValueAsString('Text','Doprava km (evidenční)');mNewRow.SetFieldValueAsfloat('ToInvoiceType',1);mNewRow.SetFieldValueAsDateTime('X_konec_prace',mDateto);mNewRow.free;
                                                                                                                                                                                                                end; }
                                                                                                                                                                           end;                   // záruka


                                                                                                                                                                      end;   // zadání odpracované doby



                                                                                                                                            end;  // end for list

                                                                                                                                        finally
                                                                                                                                            mList_pomoc.free;
                                                                                                                                        end;
                                                                                                                             end;   //paušál
                                                                                                                       if mB_pokracovat then begin
                                                                                                                          mBO_ML.SetFieldValueAsstring('X_State','3Q22000101');
                                                                                                                          mBO_ML.SetFieldValueAsinteger('AssemblyState',1);
                                                                                                                          mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' +QuotedStr(mBO_ML.getFieldValueAsString('X_state.X_field1'))+ ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                                                                                                       end;
                                                                                                                       end ;  // není fakturován

                                                                                                        end; // datum pro fakturaci

                                                                                       end;   // není zadán technik


                                                                                       // zadání materiálu
                                                                                      // if (mIDs_Storecard.count=0) and mResult_mat then begin
                                                                                      //            mResult_mat:=GetCheck(Sender,xSite,'Chcete zadat materiál','Zadat materiál','Pokračovat') ;
                                                                                      //            if mResult_mat then begin
                                                                                      //
                                                                                      //            mBO_ML.SetFieldValueAsstring('X_State','45W1000101');
                                                                                      //            mBO_ML.SetFieldValueAsinteger('AssemblyState',1);
                                                                                      //            end;
                                                                                      // end;


                                                                                   mID_ML:=mBO_ML.oid;
                                                                                   if mB_pokracovat then begin
                                                                                       mBO_ML.Save;
                                                                                   end else begin
                                                                                       mBO_ML.Save;
                                                                                       //NxShowSimpleMessage('Operace byla přerušena',xSite);
                                                                                   end;
                                                                                   mBO_ML.Refresh;
                                                                                   finally
                                                                                      mBO_ML.free;
                                                                                   end;
                                                                               end;

                                                                     finally
                                                                              mIDs_ML.free;
                                                                     end;
                                                      finally
                                                         mbo_SL.free;
                                                      end;
                                        end;          // pro více SP
                                    finally
                                       mIDs_Storecard.Free;
                                       mIDs_SP.free;
                                       mIDs_WorkerRole.Free;
                                    end;
                                    mdbgrid.Refresh;
                                    xsite.RefreshData;
                                    xsite.ActiveDataSet.seekid(mID_ML);
                                    xsite.ActiveDataSet.RefreshAndRestoreLastSelectedItem;
                                    //mBO_ML.Load(mid_ml,nil);
                                    //try
                                    //    mbo_ml.Save;
                                    //    mbo_ml.Refresh;
                                    //    mdbgrid.Refresh;
                                    //xsite.RefreshData;
                                    //xsite.ActiveDataSet.seekid(mID_ML);
                                    //xsite.ActiveDataSet.RefreshAndRestoreLastSelectedItem;
                                    //finally
                                    //
                                    //end;



        end;
  {      if index=1 then begin
                mD_SL_start:= date ;
                mD_SL_End:=mD_SL_start+1;
                try
                mBONew_SL:=xsite.BaseObjectSpace.CreateObject('BCHF52UGXCO4H5MIAQVY5P3ZOC');
                      mBONew_SL.New;
                      mBONew_SL.Prefill;
                      mboNew_SL.SetFieldValueAsDateTime('DocDate$DATE',mD_SL_start);
                      mboNew_SL.SetFieldValueAsDateTime('PromisedDeadLine$DATE', mD_SL_End);
                      mboNew_SL.SetFieldValueAsstring('Division_ID',mboNew_SL.getFieldValueAsstring('CreatedBy_ID.X_division_ID'));


                      xSite.ShowDynFormWithNewDocument('NHT5Z3GSFFQ4F024JRFLUNOS30', xSite.SiteContext, mBONew_SL);
                      mID_SL:=mBONew_SL.oid;

                      finally
                         mBONew_SL.free;
                      end;


        end;  }


            if index=1 then begin
                    mD_SL_start:= GetDate(Sender,xSite) ;
                    mD_SL_End:=mD_SL_start+1;
                //  montážní list
                      mbo_SL:=mBO.ObjectSpace.CreateObject('BCHF52UGXCO4H5MIAQVY5P3ZOC');
                           try
                                mbo_sl.Load(mbo.GetFieldValueAsString('ServiceDocument_ID'),nil) ;  // použití již existujícího SL

                                     if nxisblank(mid_workSpace) then begin
                                            mr:=TStringList.Create;
                                            try
                                               mbo.objectspace.SQLSelect('select id from ServiceWorkSpaces where code=' + QuotedStr(mbo.GetFieldValueAsString('Servicedocument_ID.Division_ID.code')),mr);
                                                        if mr.count>0 then mid_workSpace:=mr.Strings[0];
                                            finally
                                                mr.free;
                                            end;
                                         end;

                                         if nxisblank(mid_workerRole) then begin
                                            mr:=TStringList.Create;
                                            try
                                              mbo.ObjectSpace.SQLSelect('select id from SecurityRoles where ShortName=' + QuotedStr(mbo.GetFieldValueAsString('Servicedocument_ID.Division_ID.code')),mr);
                                              if mr.count>0 then begin
                                                  mid_workerRole:=mr.Strings[0]
                                              end;
                                            finally
                                                mr.free;
                                            end;
                                          end;
                                          // založení nového ML


                                          mID_ML:=Novy_ML(mBO_SL,mid_workSpace,mid_workerRole,mD_SL_start,mD_SL_End);
                               finally
                                  mbo_sl.free;
                               end;


     mdbgrid.Refresh;
     xsite.RefreshData;
     xsite.ActiveDataSet.seekid(mID_ML);
     xsite.ActiveDataSet.RefreshAndRestoreLastSelectedItem;
     //TDynSiteForm(xsite).ActiveDataSet.RefreshCurrentItem;
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

  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Občerstvit';
  mMAction.Hint := 'Občerstvit';
  mMAction.Category := 'tabList';
  mMAction.OnExecuteItem := @mRefresh;
  mMAction.Items.Add('Občerstvit');


  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Servisní list - průvodce';
  mMAction.Hint := 'Nový Servisní list';
  mMAction.Category := 'tabList';
  mMAction.OnExecuteItem := @NEWSLExecuteItem;
  mMAction.Items.Add('Nový servisní list - zrychleně');
  mMAction.Items.Add('Nový montážní list');

   mMAction1 := Self.GetNewMultiAction;
  mMAction1.ShowControl := True;
  mMAction1.ShowMenuItem := True;
  mMAction1.Caption := 'Editace dokladu';
  mMAction1.Hint := 'Práce s dokladem';
  mMAction1.Category := 'tabList';
  mMAction1.OnExecuteItem := @EDITSLExecuteItem;
  mMAction1.Items.Add('Zadání technika');
  mMAction1.Items.Add('Rozpočet fakturace');
  mMAction1.Items.Add('Zadání materiálu');
  mMAction1.Items.Add('Přidání textového řádku');
  mMAction1.Items.Add('Cenová nabídka');
  mMAction1.Items.Add('Objednání materiálu');
  mMAction1.Items.Add('Vyskladnění materiálu');
  mMAction1.Items.Add('Stav ML');
  mMAction1.Items.Add('');
  mMAction1.Items.Add('Doplnění čísla objednávky');
  mMAction1.Items.Add('Odeslání k fakturaci');
  mMAction1.Items.Add('');
  mMAction1.Items.Add('Změna záruky');
  mMAction1.Items.Add('Doplnění závady');
  mMAction1.Items.Add('Zajištění subdodávky');
  //mMAction1.Items.Add('Typ platby');
  mMAction1.Items.Add('Posun termínu servisu');


   mMAction1 := Self.GetNewMultiAction;
  mMAction1.ShowControl := True;
  mMAction1.ShowMenuItem := True;
  mMAction1.Caption := 'Připojení protokolu';
  mMAction1.Hint := 'Připojení protokolu';
  mMAction1.Category := 'tabList';
  mMAction1.OnExecuteItem := @ProtokolExecuteItem;
  mMAction1.Items.Add('Protokol Spedos');
  mMAction1.Items.Add('Protokol Zákazník');
  mMAction1.Items.Add('Objednávka');
  mMAction1.Items.Add('Ostatní');

 if mUserFilter then begin
  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Ukončení servisu';
  mMAction.Hint := 'Odeslání k fakuraci';
  mMAction.Category := 'tabList';
  mMAction.OnExecuteItem := @SendSLExecuteItem;
  mMAction.Items.Add('Fakturovat');
  mMAction.Items.Add('Fakturace_logistika');
  mMAction.Items.Add('Vyřešeno v záruce');
end;



  mMAction1 := Self.GetNewMultiAction;
  mMAction1.ShowControl := True;
  mMAction1.ShowMenuItem := True;
  mMAction1.Caption := 'Servisní funkce';
  mMAction1.Hint := 'Servisní funkce';
  mMAction1.Category := 'tabList';
  mMAction1.OnExecuteItem := @ServisMLExecuteItem;
  mMAction1.Items.Add('Uvolnění podkladů mezd');
  mMAction1.Items.Add('Zrušení vyskladnění materiálu');
  mMAction1.Items.Add('Uvolnění fakturace');


//  mMAction1.Items.Add('Doplnění skladových karet');
//  mMAction1.Items.Add('Hromadná změna materiálu');


  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
//  mAction.Name := 'actNew_rekl';
  mAction.Caption := 'Reklamace';
  mAction.Hint := 'Provede reklamaci aktuálního řádku';
  mAction.Category := 'tabDetail';
  // Nastavime udalost, ktera se vykona pri spusteni teto akce
  mAction.OnExecute := @New_reklOnExecute;
  //mAction.OnUpdate := @btnOnUpdate;
  //mAction.ShortCut := TextToShortCut('Ctrl+Z');
  //mAction.ShortCutCtrlNumber := True;


end;


 procedure New_reklOnExecute(Sender: Tcomponent;index:integer);
var
  mSite: TDynSiteForm;
  mGrid: TdbGrid;
  mControl: TControl;
  mDataSource: TDataSource;
  mDataset: TNxRowsObjectDataSet;
  mForm: TForm;
  mObjectSpace: TNxCustomObjectSpace;
  mr:Tstringlist;
begin
  if Sender is TComponent then begin
    try
      mSite := TComponent(Sender).DynSite;
      if not TDynSiteForm(mSite).Edit then begin
        ShowMessage('Akce reklamace je přístupná jen v editaci dokladu.');
        Exit;
      end;
      mObjectSpace := mSite.BaseObjectSpace;
      mForm:= NxGetSiteAppForm(mSite);
      mControl:= NxFindChildControl(mForm, 'tabDetail');
      mControl := NxFindChildControl(TWinControl(mControl), 'grdServiceAssemblyRows');
      mGrid := TdbGrid(mControl);
      mDataSource := mGrid.DataSource;
      mDataset := TNxRowsObjectDataSet(mDataSource.DataSet);
      if Assigned(mDataset) then begin
        // hodnoty z datasetu
        {if not Assigned(mDataset.ActiveItem) then begin
          ShowMessage('Akci rozpadu je možné spustit jen pokud existuje řádek pro rozpad.');
          Exit;
        end;
        }
        if mDataset.FieldByName('Itemtype').AsInteger <> 1 then begin
          ShowMessage('Akci rozpadu je možné spustit jen pro řádek typu material.');
          Exit;
        end;
        mr:=TStringList.create;
        try
           mObjectSpace.SQLSelect('select sum(sd2.quantity) from storedocuments2 SD2 left join storedocuments SD on SD.id=sd2.parent_id where sd2.X_parent_id=' + quotedstr(mDataset.CurrentObject.OID) + 'and sd.DocumentType=' + quotedstr('20')+ ' and sd.DocQueue_ID=' + quotedstr('4I10000101'),mr);
           if NxIBStrToFloat(mr.Strings[0])<mDataset.CurrentObject.GetFieldValueAsFloat('Quantity') then begin
               New_rekl(mObjectSpace, TDynSiteForm(mSite), mDataset);
           end else begin
               NxShowSimpleMessage('Na aktuální řádek dokladu již existuje reklamační protokol. Doklad není možné vystavit.',msite);
           end ;

        finally
           mr.free;
        end;
      end;
    except
      ShowMessage('V průběhu rozpadu řádků ML došlo k chybě: ' + ExceptionMessage);
    end;
  end;
end;



 procedure mrefresh(Sender: Tcomponent; Index: integer);
begin
xSite := TComponent(Sender).DynSite;
    mBO:=TDynSiteForm(xSite).CurrentObject;
    mTabList := TTabSheet(NxFindChildControl(xSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
    mBO_ML:= TDynSiteForm(xSite).CurrentObject;
    mID_ML:=mbo_ml.oid;
    mdbgrid.Refresh;
     xsite.RefreshData;
     xsite.ActiveDataSet.seekid(mID_ML);
     xsite.ActiveDataSet.RefreshAndRestoreLastSelectedItem;
end;

procedure ServisMLExecuteItem(Sender: Tcomponent; Index: integer);
Var
shodnota:string;
i:integer;
mhodnota:double;
mresult:boolean;
mr:tstringlist;
mkoeficient,mkorekce:double;
mpocet:integer;
begin
    mID_WorkerRole:='';
    mID_WorkerRole:='';
    mID_StoreCard:='';
    mid_workSpace:='';
    mD_SL_start:= (date) + EncodeTime(7,0,0,0);
    mD_SL_End:=(date) + encodetime(15,30,0,0);

    xSite := TComponent(Sender).DynSite;
    mBO:=TDynSiteForm(xSite).CurrentObject;
    mTabList := TTabSheet(NxFindChildControl(xSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu

  if index=0 then begin
      mhodnota:=0;
      shodnota:='0';
      mresult:=InputQuery('Smazání podkladu pro práci nutno ručně smazat i fakturační řádky','pro editaci zadejte hodnotu',shodnota);
      mhodnota:=StrToFloat(shodnota);
  end;

    if mBookmark.count=0 then begin
           mBO_ML:= TDynSiteForm(xSite).CurrentObject;
           mid_ML:=mBO_ml.oid;
           mRows_ML:= mBO_ML.GetLoadedCollectionMonikerForFieldCode(mBO_ML.GetFieldCode('ROWS'));
           if index=0 then begin
                    try
                        for i := 0 to mRows_ML.Count-1 do begin

                          if ((mRows_ML.BusinessObject[i].getFieldValueAsInteger('itemtype')= 4) and (mRows_ML.BusinessObject[i].getFieldValueAsstring('Text')= 'Práce - evidenční pro mzdy')) or
                             ((mRows_ML.BusinessObject[i].getFieldValueAsInteger('itemtype')= 0) and (mRows_ML.BusinessObject[i].getFieldValueAsstring('Text')= 'Paušál práce')) or
                             ((mRows_ML.BusinessObject[i].getFieldValueAsInteger('itemtype')= 0) and (mRows_ML.BusinessObject[i].getFieldValueAsstring('Text')= 'Práce - evidenční pro mzdy')) then begin
                                      if mresult then begin
                                           if mhodnota=0 then begin
                                              mRows_ML.BusinessObject[i].setFieldValueAsFloat('QuantityDelivered',0);
                                               mRows_ML.BusinessObject[i].MarkForDelete;
                                            end else begin
                                              mRows_ML.BusinessObject[i].setFieldValueAsFloat('Quantity',mhodnota);
                                                mRows_ML.BusinessObject[i].setFieldValueAsFloat('Quantity',mhodnota);
                                               mRows_ML.BusinessObject[i].setFieldValueAsFloat('WorkHoursPlanned',mhodnota);
                                               mRows_ML.BusinessObject[i].setFieldValueAsFloat('WorkHoursReal',mhodnota);
                                              // mRows_ML.BusinessObject[i].Save;
                                          end;
                                      end;
                               end;
                      end;
                      //mMon.SaveAll;
                      mBO_ml.Save;
                      mBO_ml.Refresh;
                      TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject.Refresh;
                    finally
                    end;
                     mBO_ml:= TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject;
                     mr:=TStringList.create;
                     mBO_ml.ObjectSpace.SQLSelect('select id from ServiceAssemblyForms2 where storecard_ID=' + quotedstr('2ZI1000101'),mr);

                     if mr.Count>0 then begin
                          mkoeficient:=100/mr.Count;
                              if mkoeficient*mr.Count<>100 then begin
                                      mkorekce:=100-mkoeficient*mr.Count;
                              end;
                              mRows_ML:= mBO_ml.GetLoadedCollectionMonikerForFieldCode(mBO_ml.GetFieldCode('ROWS'));
                              try
                                for i := 0 to mRows_ML.Count-1 do begin
                                    if mRows_ML.BusinessObject[i].GetFieldValueAsString('Storecard_ID')= '2ZI1000101' then begin
                                        mRows_ML.BusinessObject[i].setFieldValueAsFloat('X_koeficient',mkoeficient+mkorekce);
                                        mkorekce:=0;
                                        mRows_ML.BusinessObject[i].Save;
                                    end;
                                end;
                                //mMon.SaveAll;
                                mBO_ml.Save;
                                mBO_ml.Refresh;
                              finally
                              end;
                      end ;
                  end;
                  if index=1 then begin
                      mpocet:=(-1);
                        for i := 0 to mRows_ML.Count-1 do begin
                            try
                                if mRows_ML.BusinessObject[i].getFieldValueAsInteger('itemtype')= 1 then begin
                                        mhodnota:=0;
                                        mr:=TStringList.create;
                                           try
                                            mBO_ml.ObjectSpace.SQLSelect('select sum(sd2.quantity) from Storedocuments2 SD2 left join Storedocuments SD on sd.id=SD2.parent_ID where SD.DocumentType=' + quotedstr('21') +
                                                               ' and SD2.X_Parent_ID=' + quotedstr(mRows_ML.BusinessObject[i].getFieldValueAsstring('ID')) ,mr);
                                                  if mr.Count>=0 then begin
                                                            mRows_ML.BusinessObject[i].setFieldValueAsFloat('QuantityDelivered',nxibstrtofloat(mr.Strings[0]));
                                                            mRows_ML.BusinessObject[i].Save;
                                                  end;
                                            finally
                                               mr.free;
                                            end;

                                end;
                            finally
                            end;
                             end;
                               mBO_ml.Save;
                            end;


                           if index=2 then begin
                              mpocet:=(-1);
                              for i := 0 to mRows_ML.Count-1 do begin
                              mpocet:=mpocet+1;
                               try
                                 mr:=TStringList.create;
                                           try
                                            mBO_ml.ObjectSpace.SQLSelect('select sum(ii2.quantity-iic.quantity) from Issuedinvoices2 II2 left join IssuedCreditNotes2 IIC on iic.RSource_ID=ii2.id where' +
                                                               ' ii2.X_Parent_ID=' + quotedstr(mRows_ML.BusinessObject[i].getFieldValueAsstring('ID')) ,mr);
                                                  if StrToInt(mr.Strings[0])=0 then begin
                                                         if mRows_ML.BusinessObject[i].getFieldValueAsinteger('IsInvoiced')=1 then begin
                                                             mRows_ML.BusinessObject[i].SetFieldValueAsString('InvoicingDocType','');
                                                             mRows_ML.BusinessObject[i].SetFieldValueAsString('InvoicingDoc_ID','');
                                                             mRows_ML.BusinessObject[i].SetFieldValueAsinteger('IsInvoiced',0);
                                                             mRows_ML.BusinessObject[i].Save;
                                                         end;
                                                  end;
                                            finally
                                               mr.free;
                                            end;

                              finally
                              end;
                             end;

                            mBO_ml.SetFieldValueAsString('X_State','6XQ1000101');

                            mbo_ml.Save;
                            NxShowSimpleMessage('Proběhlo uvolnění '+ inttostr(mpocet) +' položek, které můžete znovu fakturovat',nil);
                      end;


    end else begin
        for mI_ML:= 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
           mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(mI_ML));
           mBO_ML:= TDynSiteForm(xSite).CurrentObject;
           mRows_ML:= mBO_ML.GetLoadedCollectionMonikerForFieldCode(mBO_ML.GetFieldCode('ROWS'));
           if index=0 then begin
                    try
                        for i := 0 to mRows_ML.Count-1 do begin

                          if ((mRows_ML.BusinessObject[i].getFieldValueAsInteger('itemtype')= 4) and (mRows_ML.BusinessObject[i].getFieldValueAsstring('Text')= 'Práce - evidenční pro mzdy')) or
                             ((mRows_ML.BusinessObject[i].getFieldValueAsInteger('itemtype')= 0) and (mRows_ML.BusinessObject[i].getFieldValueAsstring('Text')= 'Paušál práce')) or
                             ((mRows_ML.BusinessObject[i].getFieldValueAsInteger('itemtype')= 0) and (mRows_ML.BusinessObject[i].getFieldValueAsstring('Text')= 'Paušál práce')) then begin
                                      if mresult then begin
                                           if mhodnota=0 then begin
                                              mRows_ML.BusinessObject[i].setFieldValueAsFloat('QuantityDelivered',0);
                                               mRows_ML.BusinessObject[i].MarkForDelete;
                                            end else begin
                                              mRows_ML.BusinessObject[i].setFieldValueAsFloat('Quantity',mhodnota);
                                                mRows_ML.BusinessObject[i].setFieldValueAsFloat('Quantity',mhodnota);
                                               mRows_ML.BusinessObject[i].setFieldValueAsFloat('WorkHoursPlanned',mhodnota);
                                               mRows_ML.BusinessObject[i].setFieldValueAsFloat('WorkHoursReal',mhodnota);
                                               mRows_ML.BusinessObject[i].Save;
                                          end;
                                      end;
                               end;

                      end;
                      //mMon.SaveAll;
                      mBO_ml.Save;
                      mBO_ml.Refresh;
                    finally
                    end;
                     mBO_ml:= TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject;
                     mr:=TStringList.create;
                     mBO_ml.ObjectSpace.SQLSelect('select id from ServiceAssemblyForms2 where storecard_ID=' + quotedstr('2ZI1000101'),mr);

                     if mr.Count>0 then begin
                          mkoeficient:=100/mr.Count;
                              if mkoeficient*mr.Count<>100 then begin
                                      mkorekce:=100-mkoeficient*mr.Count;
                              end;
                              mRows_ML:= mBO_ml.GetLoadedCollectionMonikerForFieldCode(mBO_ml.GetFieldCode('ROWS'));
                              try
                                for i := 0 to mRows_ML.Count-1 do begin
                                    if mRows_ML.BusinessObject[i].GetFieldValueAsString('Storecard_ID')= '2ZI1000101' then begin
                                        mRows_ML.BusinessObject[i].setFieldValueAsFloat('X_koeficient',mkoeficient+mkorekce);
                                        mkorekce:=0;
                                        mRows_ML.BusinessObject[i].Save;
                                    end;
                                end;
                                //mMon.SaveAll;
                                mBO_ml.Save;
                                mBO_ml.Refresh;
                              finally
                              end;
                      end ;
                  end;
                  if index=1 then begin
                      mpocet:=(-1);
                        for i := 0 to mRows_ML.Count-1 do begin
                            try
                                if mRows_ML.BusinessObject[i].getFieldValueAsInteger('itemtype')= 1 then begin
                                        mhodnota:=0;
                                        mr:=TStringList.create;
                                           try
                                            mBO_ml.ObjectSpace.SQLSelect('select sum(sd2.quantity) from Storedocuments2 SD2 left join Storedocuments SD on sd.id=SD2.parent_ID where SD.DocumentType=' + quotedstr('21') +
                                                               ' and SD2.X_Parent_ID=' + quotedstr(mRows_ML.BusinessObject[i].getFieldValueAsstring('ID')) ,mr);
                                                  if mr.Count>=0 then begin
                                                            mRows_ML.BusinessObject[i].setFieldValueAsFloat('QuantityDelivered',nxibstrtofloat(mr.Strings[0]));
                                                            mRows_ML.BusinessObject[i].Save;
                                                  end;
                                            finally
                                               mr.free;
                                            end;

                                end;
                            finally
                            end;
                             end;
                               mBO_ml.Save;
                            end;


                           if index=2 then begin
                              mpocet:=(-1);
                              for i := 0 to mRows_ML.Count-1 do begin
                              mpocet:=mpocet+1;
                               try
                                 mr:=TStringList.create;
                                           try
                                            mBO_ml.ObjectSpace.SQLSelect('select sum(ii2.quantity) from Issuedinvoices2 II2 where' +
                                                               ' ii2.X_Parent_ID=' + quotedstr(mRows_ML.BusinessObject[i].getFieldValueAsstring('ID')) ,mr);
                                                  if mr.Count=0 then begin
                                                         if mRows_ML.BusinessObject[i].getFieldValueAsinteger('IsInvoiced')=1 then begin
                                                             mRows_ML.BusinessObject[i].SetFieldValueAsString('InvoicingDocType','');
                                                             mRows_ML.BusinessObject[i].SetFieldValueAsString('InvoicingDoc_ID','');
                                                             mRows_ML.BusinessObject[i].SetFieldValueAsinteger('IsInvoiced',0);
                                                             mRows_ML.BusinessObject[i].Save;
                                                         end;
                                                  end;
                                            finally
                                               mr.free;
                                            end;
;
                              finally
                              end;
                             end;

                            mBO_ml.SetFieldValueAsString('X_State','6XQ1000101');

                            mbo_ml.Save;
                            NxShowSimpleMessage('Proběhlo uvolnění '+ inttostr(mpocet) +' položek, které můžete znovu fakturovat',nil);
                      end;








        end;
        mid_ML:=mBO_ml.oid;
    end;

   mdbgrid.Refresh;
     xsite.RefreshData;
     xsite.ActiveDataSet.seekid(mID_ML);
     xsite.ActiveDataSet.RefreshAndRestoreLastSelectedItem;

end;



procedure ProtokolExecuteItem(Sender: Tcomponent; Index: integer);
var
mForm: TForm;
i:integer;
mr:tstringlist;
mresult:boolean;
mdate:date;
mDateinput:boolean;
mResult_mat:boolean;
mBO_MLNew:TNxCustomBusinessObject;
mrta:tstringlist;
mdir,mtargetdir,mfilename,mfilter,mfile:string;
aresult:boolean;
mi:integer;
mpotvrzeni:boolean;
constStoragePath,constNewDirStr:string;
begin

    xSite := TComponent(Sender).DynSite;
    mBO:=TDynSiteForm(xSite).CurrentObject;
    mTabList := TTabSheet(NxFindChildControl(xSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');


    mdir:=Trim(mbo.GetFieldValueAsString('ServiceWorkSpace_ID.X_Directory'));

{
  mFileList:=tstringlist.create;
  NxGetFileList(mDirectory, mFileList, '*.xml');
          ShowDebugMessage('ImportFromXML, mFileList.Count: ' + IntToStr(mFileList.Count));
          for i := 0 to mFileList.Count - 1 do begin&
            mFile := mFileList.Strings(i);
            mFileName := mDirectory + '\' + mFileList.Strings(i);
            ShowDebugMessage('ImportFromXML: ' + mFileName);
            ShowDebugMessage('ImportFromXML: oteviram xml');
            mXMLDoc := Null;
            mXMLDoc := CreateXMLDocument(mFileName, mMessage);
          end;
 }
//    NxShowSimpleMessage(mdir,nil);
    if PromptForFileName(mFileName, mfilter, '', 'Importovaný protokol spedos', mdir, False) then begin
        mdir:=copy(mfilename,0,NxCharPosR('\',mfilename));
        mFile:=copy(mfilename,1+NxCharPosR('\',mfilename),Length(mfilename));
//        ShowMessage(Format('Bude importován soubor %s %s', [mdir,mfile,]));
    end;

    //ImportFile(TDynSiteForm(mSite).CurrentObject.ObjectSpace, mfilename, mdir,mfile);

  constStoragePath:= '\\192.168.0.36\abra\Servis';
  constNewDirStr:= '%s\%s';

                        if DirectoryExists(Format('%s', [constStoragePath]))  then begin   // uloziste je pristupne
                                mResult:=DirectoryExists(Format('%s\%s', [constStoragePath, mBO.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID')]));
                                if  not mresult then begin    // servisovaný objekt
                                        mResult:=NxCreateDir(Format('%s\%s', [constStoragePath, mBO.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID')]));
                                        //ShowMessage(Format('%s\%s', [constStoragePath, mBO.GetFieldValueAsString('ServicedObject_ID')]));

                                end;
                                mResult:=DirectoryExists(Format('%s\%s\%s', [constStoragePath, mBO.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID'),'Servisni listy']));
                                if not mresult then begin    // servisní list
                                        mResult:=NxCreateDir(Format('%s\%s\%s', [constStoragePath, mBO.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID'),'Servisni listy']));
                                        //ShowMessage(Format('%s\%s\%s', [constStoragePath, mBO.GetFieldValueAsString('ServicedObject_ID'),'Servisni listy']));

                                end;
                                mResult:=DirectoryExists(Format('%s\%s\%s\%s', [constStoragePath, mBO.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID'),'Servisni listy',mBO.GetFieldValueAsString('ID')]));
                                if not mresult then begin    // servisní list
                                        mResult:=NxCreateDir(Format('%s\%s\%s\%s', [constStoragePath, mBO.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID'),'Servisni listy',mBO.GetFieldValueAsString('ServiceDocument_ID')]));
                                end;
                                mResult:=DirectoryExists(Format('%s\%s\%s\%s\%s', [constStoragePath, mBO.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID'),'Servisni listy',mBO.GetFieldValueAsString('ServiceDocument_ID'),'ML']));
                                if not mresult then begin    // servisní list
                                        mResult:=NxCreateDir(Format('%s\%s\%s\%s\%s', [constStoragePath, mBO.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID'),'Servisni listy',mBO.GetFieldValueAsString('ServiceDocument_ID'),'ML']));
                                end ;

                                mResult:=DirectoryExists(Format('%s\%s\%s\%s\%s\%s', [constStoragePath, mBO.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID'),'Servisni listy',mBO.GetFieldValueAsString('ServiceDocument_ID'),'ML',mBO.oid]));
                                if not mresult then begin    // servisní list
                                        mResult:=NxCreateDir(Format('%s\%s\%s\%s\%s\%s', [constStoragePath, mBO.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID'),'Servisni listy',mBO.GetFieldValueAsString('ServiceDocument_ID'),'ML',mBO.oid]));
                                end ;


                    end;


   mtargetdir:=(Format('%s\%s\%s\%s\%s\%s', ['\\192.168.0.36\abra\Servis', mbo.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID'),'Servisni listy',mbo.GetFieldValueAsString('ServiceDocument_ID'),'ML',mbo.oid]));

   aResult := True;
   aresult:=nxcopyfile(mfilename,mtargetdir+'\' + mFile);
   if Aresult= true then begin
       if index=0 then  mi:=xsite.BaseObjectSpace.SQLExecute('update ServiceAssemblyForms set X_Spedos_formular=' + quotedstr(mfile) + ' where id=' + quotedstr(mbo.oid)) ;
       if index=1 then  mi:=xsite.BaseObjectSpace.SQLExecute('update ServiceAssemblyForms set X_Zakaznik_formular=' + quotedstr(mfile) + ' where id=' + quotedstr(mbo.oid)) ;
       if index=2 then  mi:=xsite.BaseObjectSpace.SQLExecute('update ServiceAssemblyForms set X_objednavka_formular=' + quotedstr(mfile) + ' where id=' + quotedstr(mbo.oid)) ;





       aresult:=DeleteFile(mFileName);
       if not aresult then NxShowSimpleMessage('Doklad ' + quotedstr(mfilename)  + ' nemohl být automatickys smazán, prosím smažte jej ručně',nil);
   end else begin
       NxShowSimpleMessage('Doklad ' + quotedstr(mfilename)  + ' nemohl být automaticky zkopírován, prosím zkopírujtea následně smažte jej ručně',nil);
   end;

end;





procedure _SaveChanges_PreHook(Self: TDynSiteForm);
var
mfile:string;
mi:integer;
begin

end;

{
Vyvolává se před tiskem/exportem. Pomocí tohoto háčku je možné ovlivnit parametry, které obdrží samotná funkce tisk/export.
}
procedure BeforePrint_Hook(Self: TSiteForm; APrintID: string; AParams: TNxParameters);
begin

end;

  procedure EDITSLExecuteItem(Sender: Tcomponent; Index: integer);
 var
 mfile:string;
 mresult:boolean;
 mdateinput:boolean;
 mResult_mat:boolean;
 mstav:string;
 smresult:string;
 mdate:double;
 mstate:string;
 morigstate:string;
 mr:tstringlist;
 mskupina:string;
 mi:integer;
 mr1,mr2:TStringList;
 mtext:string;
 mrxx:TStringList;
 ii:integer;
 mpotvrzeni:string;
 mr_sum:tstringlist;
 mID_zakaznika:string;
 mOrigposState:Integer;
 i:integer;
 mrow:TNxCustomBusinessObject;
 m_pocet,m_objednano:double;
 mI_Result:integer;
 mOLE_Zarizeni, mRoll_Zarizeni, mOResult_Zarizeni: Variant;
 mOLE_Vyrobce, mRoll_Vyrobce, mOResult_Vyrobce: Variant;
 mOLE_Typ_zarizeni, mRoll_Typ_zarizeni, mOResult_Typ_zarizeni: Variant;
 mOLE_BusOrder, mRoll_BusOrder, mOResult_BusOrder: Variant;
 mids_Zarizeni,mids_Vyrobce,mids_Typ_zarizeni,mids_BusOrder:TStrings;
 mid_Zarizeni,mid_Vyrobce,mid_Typ_zarizeni,mid_BusOrder,mid_busTransaction:String;
 mbo_SP,mbo_sl:TNxCustomBusinessObject;
 mresult_ID:string;
 mForm:TForm;
 mBtn : TButton;
  mlb2,mlb3 : TLabel;
  mEdtSrc:TDateEdit;
  mEdt1:TEdit;
  mposun:double;
 begin
 mid_Zarizeni:='';
 mid_Vyrobce:='';
 mid_Typ_zarizeni:='';
 mid_BusOrder:='';
 mID_WorkerRole:='';
 mposun:=0;

    mID_WorkerRole:='';
    mID_StoreCard:='';
    mid_workSpace:='';
    mD_SL_start:= (date) + EncodeTime(7,0,0,0);
    mD_SL_End:=(date) + encodetime(15,30,0,0);
    xSite := TComponent(Sender).DynSite;
    mBO:=TDynSiteForm(xSite).CurrentObject;
    mTabList := TTabSheet(NxFindChildControl(xSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    mIDs_MLRow:=tstringlist.Create;
    if index=0 then begin
    mdateinput:=true;
          mResult_mat:=true;
          mIDs_WorkerRole:=TStringList.Create;
                mOLE_WorkerRole:= GetAbraOLEApplication;
                mOResult_WorkerRole:= mOLE_WorkerRole.CreateStrings;
                mRoll_WorkerRole:= mOLE_WorkerRole.GetRoll('0FKKTBSSQKB4B3RLYBSJFFAFUW', 0);   // sp
                if mRoll_WorkerRole.MultiSelectDialog(True, mOResult_WorkerRole) then mIDs_WorkerRole.Text:= mOResult_WorkerRole.Text;
    end;
    if index=7 then begin
        mstate:=iGetState(xSite);
    end;


    if index=10 then begin
       mr:=tstringlist.create;
           try
               if (mBookmark.count=0) and (mbo.GetFieldValueAsInteger('ServiceDocument_ID.X_skupina')>0) then begin
                  mskupina:=inttostr(mbo.GetFieldValueAsInteger('ServiceDocument_ID.X_skupina'));
               end else begin
                  xsite.BaseObjectSpace.sqlselect('Select max(X_skupina) from ServiceDocuments',mr);
                    if mr.count>0 then mskupina:=inttostr(strtoint(mr.strings[0])+1) else mskupina:='1';
                   mresult:=InputQuery('Odeslání k fakturaci - fakturační skupina', 'Automatická nová skupina, nebo zadej číslo existující :',mskupina);
               end;
           finally
               mr.free;
           end;
    end;

    if index=15 then begin
          try
                            mForm := TForm.Create(xSite);            // formulář
                              mForm.BorderIcons := [biSystemMenu];
                              mForm.Width := 240;  // sirka
                              mForm.Height := 130; // vyska
                              mForm.Caption := 'Zadej datum servisu';
                                  mLb2 := TLabel.Create(mForm);         // položka řada
                                  mLb2.Caption := 'Zadej datum:';
                                  mLb2.Left := 30;
                                  mLb2.Top := 10;
                                  mLb2.Name := 'lblDocQueues';
                                  mForm.InsertControl(mLb2);
                                      mEdtSrc := TDateEdit.Create(mForm);
                                      mEdtSrc.Left := 100;
                                      mEdtSrc.Top := 10;
                                      mEdtSrc.Width := 100;
                                      mEdtSrc.Name := 'edtDate';
                                      mEdtSrc.Date:= mBO.GetFieldValueAsDateTime('EndDate$DATE');
                                      mForm.InsertControl(mEdtSrc);
                                  mLb3 := TLabel.Create(mForm);         // položka řada
                                  mLb3.Caption := 'Posun:';
                                  mLb3.Left := 30;
                                  mLb3.Top := 30;
                                  mLb3.Name := 'lblposun';
                                      mEdt1 := TEdit.Create(mForm);
                                      mEdt1.Left := 100;
                                      mEdt1.Top := 30;
                                      mEdt1.Width := 100;
                                      mEdt1.Name := 'edtInt';
                                      mEdt1.Text:= '0';
                                      mForm.InsertControl(mEdt1);
                                mBtn := TButton.Create(mForm);            // tlačítko OK
                                      mBtn.Width := 75;
                                      mBtn.Height := 25;
                                      mBtn.Caption := 'OK';
                                      mBtn.ModalResult := mrOk;
                                      mBtn.Cancel := False;
                                      mBtn.Default := True;
                                      mBtn.Left :=  mForm.Width - 2*(mBtn.Width+2) - 20;
                                      mBtn.Top := mForm.Height - mBtn.Height - 40;
                                      mBtn.Name := 'btnOK';
                                      mForm.InsertControl(mBtn);
                                  mBtn := TButton.Create(mForm);          // tlačítko storno
                                      mBtn.Width := 75;
                                      mBtn.Height := 25;
                                      mBtn.Caption := 'Storno';
                                      mBtn.ModalResult := mrCancel;
                                      mBtn.Cancel := True;
                                      mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;;
                                      mBtn.Top := mForm.Height - mBtn.Height - 40;
                                      mBtn.Name := 'btnCancel';
                                      mForm.InsertControl(mBtn);

                         if mForm.ShowModal(xSite) = mrOK then begin
                                 mposun:=((trunc(mEdtSrc.Date)-trunc(mBO.GetFieldValueAsDateTime('EndDate$DATE'))) + NxIBStrToFloat(mEdt1.Text));
                         end;
                      finally;
                        mForm.Free;
                      end;
    end;




    if mBookmark.count=0 then begin
            mOrigML_State_ID:=mbo.GetFieldValueAsString('X_state');
            if nxstrtoint(mbo.GetFieldValueAsstring('ServiceDocument_ID.ServiceDocState_ID.posindex'))<20 then begin
                        if index=0 then begin  //mMAction1.Items.Add('Zadání technika');
                              mBO_ML:=xSite.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                              try
                                  mBO_ML:= mbo;
                                  mRows_ML := mBO_ML.GetCollectionMonikerForFieldCode(mBO_ML.GetFieldCode('Rows'));
                                  mresult:=GetTechnik(xSite,mbo_ml,mRows_ML,mIDs_WorkerRole,mDateinput);
                                  if not mresult then begin
                                      NxShowSimpleMessage('Při zadání technika došlo k chybě:',nil);
                                  end else begin
                                      mBO_ML.SetFieldValueAsString('X_state','4U12000101');
                                      mBO_ML.SetFieldValueAsinteger('AssemblyState',trunc(NxIBStrToFloat(mBO_ML.getFieldValueAsString('X_state.X_field2'))));

                                   end;
                                  mBO_ml.save;
                                     mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' +QuotedStr(mBO_ML.getFieldValueAsString('X_state.X_field1'))+ ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;

                                  mID_ML:=mbo_ml.oid;
                              finally
                                  mbo_ml.free;
                              end;
                        end;
                        if index=1 then begin  //mMAction1.Items.Add('Rozpočet fakturace');
                              mBO_ML:=xSite.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                              try
                                  mBO_ML:= mbo;
                                  mRows_ML := mBO_ML.GetCollectionMonikerForFieldCode(mBO_ML.GetFieldCode('Rows'));
                                  mresult:=Fakturacni_ceny(mBO_ML,xSite,mRows_ML,mstav);
                                  if not mresult then begin
                                      NxShowSimpleMessage('Při rozpočtu fakturace došlo k chybě:',nil);
                                  end else begin
                                      mBO_ML.SetFieldValueAsString('X_state','3Q22000101');
                                      mBO_ML.SetFieldValueAsinteger('AssemblyState',trunc(NxIBStrToFloat(mBO_ML.getFieldValueAsString('X_state.X_field2'))));
                                       if nxisblank(mBO_ML.getFieldValueAsString('X_Spedos_formular')) and
                                             not nxisblank(trim(mBO_ML.getFieldValueAsString('X_Protokol')))
                                          then begin
                                              mfile:='';
                                                       mfile:=autocopy_protocol(mBO_ML);
                                                       if mfile='' then begin
                                                           mfile:=manualcopy_protocol(mBO_ML);
                                                       end;
                                                       if mfile<>'' then begin
                                                          mBO_ML.SetFieldValueAsString('X_Spedos_formular',mfile);
                                                          //TDynSiteForm(self).ActiveDataSet.RefreshCurrentItem;
                                                        end;
                                           end;



                                      mBO_ml.save;
                                      mID_ML:=mbo_ml.oid;
                                      mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' +QuotedStr(mBO_ML.getFieldValueAsString('X_state.X_field1'))+ ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                  end;

                              finally
                                  mbo_ml.free;
                              end;

                        end;
                        if index=2 then begin  //mMAction1.Items.Add('Zadání materiálu');
                           mBO_ML:=xSite.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                              try
                                  mBO_ML:= mbo;
                                  mRows_ML := mBO_ML.GetCollectionMonikerForFieldCode(mBO_ML.GetFieldCode('Rows'));
                                  mresult:=NEWMaterial(mBO_ml,xsite,mRows_ml);
                                  if not mresult then begin
                                    NxShowSimpleMessage('Při zadávání materiálu došlo k chybě:',nil);
                                  end else begin
                                      mBO_ML.SetFieldValueAsString('X_state','45W1000101');
                                      mBO_ML.SetFieldValueAsinteger('AssemblyState',trunc(NxIBStrToFloat(mBO_ML.getFieldValueAsString('X_state.X_field2'))));
                                   end;
                                  mBO_ml.save;
                                     mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_State=' + quotedstr('45W1000101') + ', AssemblyState=1 where id=' + QuotedStr(mBO_ML.oid));
                                     mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' +QuotedStr(mBO_ML.getFieldValueAsString('X_state.X_field1'))+ ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;

                                  mID_ML:=mbo_ml.oid;
                              finally
                                  mbo_ml.free;
                              end;


                        end;
                        if index=3 then begin  //mMAction1.Items.Add('textu');
                        mBO_ML:=xSite.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                              try
                                  mBO_ML:= mbo;
                                  mRows_ML := mBO_ML.GetCollectionMonikerForFieldCode(mBO_ML.GetFieldCode('Rows'));
                                  mresult:=NEWtext(mBO_ml,xsite,mRows_ml);
                                  if not mresult then begin
                                    NxShowSimpleMessage('Při zadávání textu došlo k chybě:',nil);
                                  end else begin
                                   end;
                                  mBO_ml.save;
                                 mID_ML:=mbo_ml.oid;
                              finally
                                  mbo_ml.free;
                              end;
                        end;
                        if index=4 then begin  //mMAction1.Items.Add('Cenová nabídka');
                             mBO_ML:=xSite.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                              try
                                  mBO_ML:= mbo;
                                  mRows_ML := mBO_ML.GetCollectionMonikerForFieldCode(mBO_ML.GetFieldCode('Rows'));
                                     mrxx:=TStringList.create;
                                     try
                                            mBO_ML.ObjectSpace.SQLSelect('select SA2.id from ServiceAssemblyForms2 SA2 left join ServiceAssemblyForms sa on SA.ID=sa2.Parent_ID where sa2.ToInvoiceType=0 and sa2.IsInvoiced=0 and sa.id=' + quotedstr(mBO_ML.OID)+' order by PosIndex',mrxx);
                                            for ii := 0 to mrxx.Count-1 do begin // projdu vsechny oznacene zaznamy
                                                 mIDs_MLRow.Add(mrxx.Strings[ii]);
                                            end;
                                     finally
                                         //mbo1.free;   nesmi byt jedna se o CurrentObject~~
                                         mrxx.free;
                                     end;



                                  smresult:=CNExecuteItem(mBO_ML,xSite,mRows_ml,mIDs_MLRow);
                                  if smresult='' then begin
                                      NxShowSimpleMessage('Při cenové nabídce došlo k chybě:',nil);
                                  end else begin

                                      mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_State=' + quotedstr('4XQ1000101') + ', AssemblyState=1 where id=' + QuotedStr(mBO_ML.oid));
                                      mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' +QuotedStr('9000000101')+ ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;

                                  end;
                                   mID_ML:=mbo_ml.oid;
                              finally
                                  mbo_ml.free;
                              end;
                        end;
                        if index=5 then begin  //mMAction1.Items.Add('Zajištění materiálu');
                             mBO_ML:=xSite.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                              try
                                  mdate:=getdate2(xsite);
                                  mBO_ML:= mbo;
                                  mRows_ML := mBO_ML.GetCollectionMonikerForFieldCode(mBO_ML.GetFieldCode('Rows'));
                                  smresult:=zajisteni_zasob(xSite,mBO_ML,mDate);
                                  //if smresult='' then NxShowSimpleMessage('Při cenové nabídce došlo k chybě:',nil);

                                      //mBO_ml.save;
                                      //mBO_ml.Refresh;

                                  mBO_ml.Refresh;
                                  mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_Stav_objednani=1 where id=' + QuotedStr(mBO_ML.oid));
                                  mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_State=' + quotedstr('3IS1000101') + ', AssemblyState=1 where id=' + QuotedStr(mBO_ML.oid));
                                  mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' +QuotedStr('A102000000')+ ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                  mID_ML:=mbo_ml.oid;
                                  xsite.RefreshData;
                              finally
                                  mbo_ml.free;
                              end;
                        end;
                        if index=6 then begin  //mMAction1.Items.Add('Vyskladnění materiálu');
                         mBO_ML:=xSite.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                              try
                                  mdate:=getdate2(xsite);
                                  mBO_ML:= mbo;
                                  mRows_ML := mBO_ML.GetCollectionMonikerForFieldCode(mBO_ML.GetFieldCode('Rows'));
                                { if nxisemptyoid(mBO_ML.GetFieldValueAsString('ServiceDocument_ID.BusOrder_ID')) then begin         // zakázka
                                            mIDs_BusOrder:=TStringList.create;
                                            mOLE_BusOrder:= GetAbraOLEApplication;
                                            mOResult_BusOrder:= mOLE_BusOrder.CreateStrings;
                                            mRoll_BusOrder:= mOLE_BusOrder.GetRoll('03OXHKRF4VD13ACL03KIU0CLP4', 0);
                                            if mRoll_BusOrder.MultiSelectDialog(True, mOResult_BusOrder) then begin
                                                mIDs_BusOrder.Text:= mOResult_BusOrder.Text;
                                                mID_BusOrder:= mIDs_BusOrder.Strings[0];

                                            end;

                                            mids_BusOrder.free;
                                  end;

                                  if nxisemptyoid(mBO_ML.GetFieldValueAsString('ServiceDocument_ID.BusTransaction_ID')) then begin     // obchodní případ
                                      if nxisemptyoid(mBO_ML.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID.X_Zarizeni_ID')) then begin  // Zarizeni
                                            mIDs_Zarizeni:=TStringList.create;
                                            mOLE_Zarizeni:= GetAbraOLEApplication;
                                            mOResult_Zarizeni:= mOLE_Zarizeni.CreateStrings;
                                            mRoll_Zarizeni:= mOLE_Zarizeni.GetRoll('44XM2OZD0UA4PEPGQ5KLM5EH30', 0);
                                            if mRoll_Zarizeni.MultiSelectDialog(True, mOResult_Zarizeni) then begin
                                                mIDs_Zarizeni.Text:= mOResult_Zarizeni.Text;
                                                mID_Zarizeni:= mIDs_Zarizeni.Strings[0];

                                            end;

                                            mids_Zarizeni.free;
                                      end;
                                      if nxisemptyoid(mBO_ML.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID.X_Vyrobce_ID')) then begin  // Vyrobce
                                            mIDs_Vyrobce:=TStringList.create;
                                            mOLE_Vyrobce:= GetAbraOLEApplication;
                                            mOResult_Vyrobce:= mOLE_Vyrobce.CreateStrings;
                                            mRoll_Vyrobce:= mOLE_Vyrobce.GetRoll('JQFREQ2PSRR4JCMPNFHSFR4CUW', 0);
                                            if mRoll_Vyrobce.MultiSelectDialog(True, mOResult_Vyrobce) then begin
                                               mIDs_Vyrobce.Text:= mOResult_Vyrobce.Text;
                                               mID_Vyrobce:= mIDs_Vyrobce.Strings[0];
                                            end;
                                            mids_Vyrobce.free;
                                      end;
                                      if nxisemptyoid(mBO_ML.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID.X_Typ_zarizeni_ID')) then begin  // Typ_zarizeni
                                            mIDs_Typ_zarizeni:=TStringList.create;
                                            mOLE_Typ_zarizeni:= GetAbraOLEApplication;
                                            mOResult_Typ_zarizeni:= mOLE_Typ_zarizeni.CreateStrings;
                                            mRoll_Typ_zarizeni:= mOLE_Typ_zarizeni.GetRoll('LXSSZYZN4ZIO5D10RO0VEVY2NO', 0);
                                            if mRoll_Typ_zarizeni.MultiSelectDialog(True, mOResult_Typ_zarizeni) then begin
                                               mIDs_Typ_zarizeni.Text:= mOResult_Typ_zarizeni.Text;
                                              mID_Typ_zarizeni:= mIDs_Typ_zarizeni.Strings[0];
                                            end;
                                            mids_Typ_zarizeni.free;
                                      end;

                                  end;

                                  if (mID_BusOrder<>'') or (mid_Zarizeni<>'')  then begin
                                         mbo_SP:=xsite.BaseObjectSpace.CreateObject('OWHN2TMXL2COJJ3LKNBV4OVSTC');
                                            try
                                               mbo_SP.Load(mBO_ML.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID'),nil);
                                                    if mid_BusOrder<>'' then mBO_SP.SetFieldValueAsString('BusOrder_ID',mid_BusOrder);
                                                    if mid_Zarizeni<>'' then mBO_SP.SetFieldValueAsString('X_Zarizeni_ID',mid_Zarizeni);
                                                    if mid_Vyrobce<>'' then mBO_SP.SetFieldValueAsString('X_Vyrobce_ID',mid_Vyrobce);
                                                    if mid_Typ_zarizeni<>'' then mBO_SP.SetFieldValueAsString('X_Typ_zarizeni_ID',mid_Typ_zarizeni);
                                               mbo_SP.save;
                                               mbo_SP.Refresh;
                                               mid_bustransaction:=mBO_SP.getFieldValueAsString('Bustransaction_ID');
                                            finally
                                               mbo_SP.free;
                                            end;
                                  end;

                                  if mID_BusOrder<>''  then begin
                                         mbo_SL:=xsite.BaseObjectSpace.CreateObject('BCHF52UGXCO4H5MIAQVY5P3ZOC');
                                            try
                                               mbo_sl.Load(mBO_ML.GetFieldValueAsString('ServiceDocument_ID'),nil);
                                                    if mid_BusOrder<>'' then mBO_SL.SetFieldValueAsString('BusOrder_ID',mid_BusOrder);
                                                    if nxisemptyoid(mBO_SL.getFieldValueAsString('BusTransaction_ID')) then begin
                                                       mBO_SL.SetFieldValueAsString('BusTransaction_ID',mid_bustransaction);
                                                    end;
                                               mbo_sl.save;
                                               mbo_sl.Refresh;
                                            finally
                                               mbo_sl.free;
                                            end;
                                  end;

                                  if not nxisemptyoid(mBO_ML.GetFieldValueAsString('ServiceDocument_ID.BusTransaction_ID')) then begin  }
                                       smresult:=Vyskladneni_zasob(xSite,mBO_ML,mdate);
                                       mBO_ml.SetFieldValueAsString('X_State','3Q22000101');
                                       mBO_ml.Save;
                                       mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_State=' + quotedstr('3Q22000101') + ', AssemblyState=1 where id=' + QuotedStr(mBO_ML.oid));
                                       mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' +QuotedStr('A102000000')+ ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                  //end else begin
                                  //    NxShowSimpleMessage('Není uveden obchodní případ, není požné pokračovat',nil);
                                  //end;
                                  //       mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_State=' + quotedstr('3Q22000101') + ', AssemblyState=1 where id=' + QuotedStr(mBO_ML.oid));

                                  //mBO_ML.SetFieldValueAsString('X_state','');
                                  //    mBO_ML.SetFieldValueAsinteger('AssemblyState',trunc(NxIBStrToFloat(mBO_ML.getFieldValueAsString('X_state.X_field2'))));
                                  //mBO_ml.save;

                                 mID_ML:=mbo_ml.oid;
                              finally
                                  mbo_ml.free;
                              end;
                        end;
                        if index=7 then begin  //mMAction1.Items.Add('Stav ML');
                        mBO_ML:=xSite.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                              try
                                  mpotvrzeni:='ANO';
                                  mBO_ML:= mbo;
                                  mRows_ML := mBO_ML.GetCollectionMonikerForFieldCode(mBO_ML.GetFieldCode('Rows'));
                                  mOrigState:=mBO_ML.GetFieldValueAsstring('X_State');
                                  mOrigposState:=strtoint(mBO_ML.GetFieldValueAsstring('X_State.code'));
                                  mBO_ML.SetFieldValueAsstring('X_State',mstate);

                                  if mstate<>'' then begin

                                      if (mstate='6XQ1000101') or (mstate='AXQ1000101') or  then begin
                                                  // ** není vydán všechen materiál
                                                  mr:=TStringList.create;
                                                  try
                                                     xsite.BaseObjectSpace.SQLSelect('Select sum(Quantity-QuantityDelivered) from ServiceAssemblyForms2 where ItemType =1 and x_storno=' + quotedstr('N') + 'and parent_id=' + quotedstr(mBO_ml.OID),mr);
                                                     if NxIBStrToFloat(mr.Strings[0])<>0 then begin
                                                        mpotvrzeni:=InputBox('Není vydán všechen materiál. ','Přesto pokračovat? ',mpotvrzeni, xsite);
                                                        //mstav_rozprac:=copy(mstav_rozprac,1,3)+'A'+copy(mstav_rozprac,5,4)  ;

                                                     end;
                                                  finally
                                                     mr.free;
                                                  end;
                                                  // na ML není uvedena žádná práce
                                                  mr1:=TStringList.create;
                                                  try
                                                     xsite.BaseObjectSpace.SQLSelect('Select count(id) from ServiceAssemblyForms2 where (ItemType =4 and text=' + quotedstr('Práce - evidenční pro mzdy') + ')  or (ItemType =0 and storecard_id=' + quotedstr('2ZI1000101') +' )and parent_id=' + quotedstr(mbo.OID),mr1);
                                                     if (mpotvrzeni='ANO') and (NxIBStrToFloat(mr1.Strings[0])=0) then begin
                                                        mpotvrzeni:=InputBox('Není zadána žádná práce. ','Přesto pokračovat? ',mpotvrzeni, xsite);
                                                        //mstav_rozprac:=copy(mstav_rozprac,1,1)+'A'+copy(mstav_rozprac,3,6)  ;
                                                     end;
                                                  finally
                                                     mr1.free;
                                                  end;
                                                  // ** není rozpočítaná všechna práce
                                                  mr2:=TStringList.create;
                                                  try
                                                     xsite.BaseObjectSpace.SQLSelect('Select count(id) from ServiceAssemblyForms2 where ItemType =0 and storecard_id=' + quotedstr('2ZI1000101') + 'and parent_id=' + quotedstr(mbo.OID),mr2);
                                                     if (mpotvrzeni='ANO') and (NxIBStrToFloat(mr2.Strings[0])<>0) then begin
                                                        mpotvrzeni:=InputBox('Není rozpočítaná práce žádná práce. ','Přesto pokračovat? ',mpotvrzeni, xsite);
                                                        //mstav_rozprac:=copy(mstav_rozprac,1,2)+'A'+copy(mstav_rozprac,4,5)  ;
                                                     end;
                                                  finally
                                                     mr2.free;
                                                  end;
                                                  if UpperCase(Trim(mpotvrzeni))='ANO' then begin
                                                    //mbo.setFieldValueAsstring('X_State',mstate);
                                                    //mbo.SetFieldValueAsInteger('AssemblyState',StrToInt(mbo.getFieldValueAsstring('X_State.X_Field2')));
                                                    if not nxisblank(copy(mbo_ML.GetFieldValueAsString('serviceDocument_id.ServicedObject_id.X_Ukonceni'),1,100)) then begin
                                                          NxShowSimpleMessage('Upozornění: '+ trim(copy(mbo_ML.GetFieldValueAsString('serviceDocument_id.ServicedObject_id.X_Ukonceni'),1,254)),nil);
                                                    end;
                                                  end;
                                                  if UpperCase(Trim(mpotvrzeni))='ANO' then begin
                                                     mBO_ML.SetFieldValueAsDateTime('X_ClosedDate$DATE',date);
                                                     if mstate='6XQ1000101' then begin
                                                         if mbo_ml.GetFieldValueAsString('ServiceDocument_ID.X_objednani')='' then begin
                                                                mBO_ML.SetFieldValueAsstring('X_State','7XQ1000101');
                                                                mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' +QuotedStr('A400000101')+ ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                                         end else begin
                                                                mBO_ML.SetFieldValueAsstring('X_State',mstate);
                                                         end;
                                                     end else begin
                                                         mBO_ML.SetFieldValueAsstring('X_State',mstate);
                                                     end;;
                                                   end;

                                                    if NxIsNumeric(mBO_ML.getFieldValueAsString('X_state.X_field2')) then mBO_ML.SetFieldValueAsinteger('AssemblyState',trunc(NxIBStrToFloat(mBO_ML.getFieldValueAsString('X_state.X_field2'))));
                                                     mBO_ML.save;
                                                     mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set X_VatDate=' +NxFloatToIBStr(mBO_ML.getFieldValueAsDateTime('EndDate$DATE'))+ ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                                  end else begin
                                                      mBO_ML.SetFieldValueAsstring('X_State',mstate);
                                                      mpotvrzeni:='A';
                                                      if NxIsNumeric(mBO_ML.getFieldValueAsString('X_state.X_field2')) then mBO_ML.SetFieldValueAsinteger('AssemblyState',trunc(NxIBStrToFloat(mBO_ML.getFieldValueAsString('X_state.X_field2'))));
                                                      mBO_ML.save;
                                                  end;


                                                  mID_ML:=mbo_ml.oid;
                                                    mr:=TStringList.create;
                                                    try


                                                          xsite.BaseObjectSpace.SQLSelect('select id from ServiceAssemblyForms where ServiceDocument_ID=' + QuotedStr(mBO_ML.GetFieldValueAsString('ServiceDocument_ID')) +
                                                              ' and x_state<>' + quotedstr('38S1000101')+ '  and x_state<>'+ quotedstr('6XQ1000101')
                                                              + '  and x_state<>'+ quotedstr('AXQ1000101')+ '  and x_state<>'+ quotedstr('3JS1000101')+ '  and x_state<>'+ quotedstr('3VW1000101')
                                                              + '  and x_state<>'+ quotedstr('3AU1000101')+ '  and x_state<>'+ quotedstr('8XQ1000101')+ '  and x_state<>'+ quotedstr('9XQ1000101')
                                                          ,mr) ;


                                                              if mr.count<1 then begin
                                                                  if not NxIsBlank(mBO_ML.getFieldValueAsString('X_state.X_field1')) then mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' +QuotedStr(mBO_ML.getFieldValueAsString('X_state.X_field1'))+ ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                                              end;
                                                    finally
                                                        mr.free;
                                                    end;
                                     end;

                                     if (mstate='3JS1000101') then begin
                                         mr:=TStringList.create;
                                                    try


                                                          xsite.BaseObjectSpace.SQLSelect('select id from ServiceAssemblyForms where ServiceDocument_ID=' + QuotedStr(mBO_ML.GetFieldValueAsString('ServiceDocument_ID')) +
                                                              ' and x_state<>' + quotedstr('38S1000101')+ '  and x_state<>'+ quotedstr('6XQ1000101')
                                                              + '  and x_state<>'+ quotedstr('AXQ1000101')+ '  and x_state<>'+ quotedstr('3JS1000101')+ '  and x_state<>'+ quotedstr('3VW1000101')
                                                              + '  and x_state<>'+ quotedstr('3AU1000101')+ '  and x_state<>'+ quotedstr('8XQ1000101')+ '  and x_state<>'+ quotedstr('9XQ1000101')
                                                          ,mr) ;


                                                              if mr.count<1 then begin
                                                                 mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' +QuotedStr('9200000101')+ ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                                              end;
                                                    finally
                                                        mr.free;
                                                    end;

                                     end;

                                    if (mstate='38S1000101') then begin
                                         mr:=TStringList.create;
                                                    try
                                                         mBO_ML.save;
                                                         mID_ML:=mbo_ml.oid;

                                                          xsite.BaseObjectSpace.SQLSelect('select id from ServiceAssemblyForms where ServiceDocument_ID=' + QuotedStr(mBO_ML.GetFieldValueAsString('ServiceDocument_ID')) +
                                                              ' and x_state<>' + quotedstr('38S1000101')+ '  and x_state<>'+ quotedstr('4XQ1000101')

                                                          ,mr) ;


                                                              if mr.count<1 then begin
                                                                 mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' +QuotedStr('9600000101')+ ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                                              end;
                                                    finally
                                                        mr.free;
                                                    end;
                                     end;




                             finally
                               mBO_ML.free;
                             end;
                        end;
                        if index=8 then begin  //mMAction1.Items.Add('');
                        end;
            end;
                        if index=9 then begin  //mMAction1.Items.Add('Doplnění čísla objednávky');
                            //mID_ML:=mBO.oid;
                            mBO_ML:=xSite.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                              try
                                  mBO_ML:= mbo;
                                  mID_ML:=mBO.oid;
                                       mtext:=mbo_ml.GetFieldValueAsString('ServiceDocument_ID.X_objednani');
                                       mresult:=InputQuery('Číslo objednávky', 'Objednávka zákazníka :',mtext);

                                        if (mtext<>'') and mresult then begin
                                              mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set X_objednani=' + quotedstr(mtext) + ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                        end;

                                         if (mBO_ML.getFieldValueAsstring('X_State')='7XQ1000101') and (mtext<>'') then begin
                                           mBO_ML.SetFieldValueAsstring('X_State','6XQ1000101');
                                             if (mresult)  then  begin
                                                  mBO_ML.save;
                                                  mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' +QuotedStr('C102000000') + ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                                   //mBO_ML.SetFieldValueAsinteger('AssemblyState',3);

                                             end;

                                             if (mBO_ML.getFieldValueAsstring('X_State')='7XQ1000101') and (mtext='') then begin
                                                   if mresult then begin
                                                       mBO_ML.SetFieldValueAsstring('X_State','6XQ1000101');
                                                       mBO_ML.save;
                                                       mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' +QuotedStr('A400000101') + ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;

                                                   end;
                                             end;
                                         end;

                              finally
                                  mbo_ml.free;
                              end;

                        end;

            if index=10 then begin  //mMAction1.Items.Add('Odeslání k fakturaci');
                mBO_ML:=xSite.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                  try
                      mBO_ML:= mbo;
                           mr1:=tstringlist.create;
                              try
                                  mbo.ObjectSpace.SQLSelect('select id from ServiceAssemblyForms where ServiceDocument_ID=' + QuotedStr(mBO_ML.GetFieldValueAsString('ServiceDocument_ID')) +
                                  ' and x_state<>' + quotedstr('38S1000101')+ '  and x_state<>'+ quotedstr('6XQ1000101') + '  and x_state<>'+ quotedstr('7XQ1000101')
                                  + '  and x_state<>'+ quotedstr('AXQ1000101')+ '  and x_state<>'+ quotedstr('3JS1000101')+ '  and x_state<>'+ quotedstr('3VW1000101')
                                  + '  and x_state<>'+ quotedstr('3AU1000101')+ '  and x_state<>'+ quotedstr('8XQ1000101')+ '  and x_state<>'+ quotedstr('9XQ1000101')
          ,mr1) ;
                                  if mr1.count=0 then begin

                                                if true  then begin
                                                     if mbo.GetFieldValueAsInteger('ServiceDocument_ID.X_skupina')=0 then begin
                                                        mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set X_skupina=' + mskupina + ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                                     end;
                                                                mr_sum:=TStringList.create;
                                                                try
                                                                 xsite.BaseObjectSpace.SQLSelect('select trunc(sum((SA2.UnitPriceWithoutVAT*SA2.Quantity) -(SA2.UnitPriceWithoutVAT*SA2.Quantity*0.01*SA2.X_radkova_sleva) ))  from ServiceAssemblyForms2 SA2 '
                                                                                                +
                                                                                                ' left join ServiceAssemblyForms SA on sa.id=SA2.Parent_ID left join ServiceDocuments SD on SD.id=SA.ServiceDocument_ID'

                                                                                                +' where SA2.itemtype=1 and SA2.ToInvoiceType=0 and sd.GuarantyRepair<>2 and SD.ID=' + quotedstr(mbo.GetFieldValueAsString('ServiceDocument_ID')),mr_sum);
                                                                 if NxIBStrToFloat(mr_sum.strings[0])<>0 then

                                                                       mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set TotalMaterial=' +(mr_sum.strings[0]) + ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;

                                                                finally
                                                                    mr_sum.Free;
                                                                end;

                                                                  mr_sum:=TStringList.create;
                                                                try
                                                                 xsite.BaseObjectSpace.SQLSelect('select trunc(sum((SA2.UnitPriceWithoutVAT*SA2.WorkHoursReal) -(SA2.UnitPriceWithoutVAT*SA2.WorkHoursReal*0.01*SA2.X_radkova_sleva)) )  from ServiceAssemblyForms2 SA2 '
                                                                                                +
                                                                                                ' left join ServiceAssemblyForms SA on sa.id=SA2.Parent_ID left join ServiceDocuments SD on SD.id=SA.ServiceDocument_ID'

                                                                                                +' where SA2.itemtype=0 and SA2.ToInvoiceType=0 and sd.GuarantyRepair<>2 and SD.ID=' + quotedstr(mbo.GetFieldValueAsString('ServiceDocument_ID')),mr_sum);
                                                                 if NxIBStrToFloat(mr_sum.strings[0])<>0 then
                                                                 mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set TotalWork=' +mr_sum.strings[0] + ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;

                                                                 //mbo.SetFieldValueAsFloat('TotalWork',StrToFloat(mr_sum.strings[0]));

                                                                finally
                                                                    mr_sum.Free;
                                                                end;

                                                                 mr_sum:=TStringList.create;
                                                                try
                                                                 xsite.BaseObjectSpace.SQLSelect('select trunc(sum((SA2.UnitPriceWithoutVAT*sa2.quantity) -(SA2.UnitPriceWithoutVAT*sa2.quantity*0.01*SA2.X_radkova_sleva)) )  from ServiceAssemblyForms2 SA2 '
                                                                                                +
                                                                                                ' left join ServiceAssemblyForms SA on sa.id=SA2.Parent_ID left join ServiceDocuments SD on SD.id=SA.ServiceDocument_ID'

                                                                                                +' where SA2.itemtype>1 and SA2.ToInvoiceType=0 and sd.GuarantyRepair<>2 and SD.ID=' + quotedstr(mbo.GetFieldValueAsString('ServiceDocument_ID')),mr_sum);
                                                                 if NxIBStrToFloat(mr_sum.strings[0])<>0 then
                                                                 mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set TotalOther=' + mr_sum.strings[0] + ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;

                                                                //  mbo.SetFieldValueAsFloat('',StrToFloat(mr_sum.strings[0]));

                                                                finally
                                                                    mr_sum.Free;
                                                                end;

                                                                mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set TotalAmount=(TotalMaterial+TotalWork+TotalOther) where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;






                                                     if mstate='6XQ1000101' then begin
                                                          mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' + QuotedStr('D102000000') + ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                                         // mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_State=' + quotedstr('8XQ1000101') + ' where ServiceDocument_ID=' + QuotedStr(mBO_ML.GetFieldValueAsString('ServiceDocument_ID')) +
                                                         //       ' and x_state<>'+ quotedstr('3Q22000101'));
                                                          mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceAssemblyForms set AssemblyState=3 where ServiceDocument_ID=' + QuotedStr(mBO_ML.GetFieldValueAsString('ServiceDocument_ID')) +
                                                                ' and x_state<>'+ quotedstr('3Q22000101'));

                                                     end else begin
                                                             mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' + QuotedStr('D102000000') + ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;

                                                     end;
                                                end;




                                  end else begin
                                     NxShowSimpleMessage('Existují neukončené ML. Nejdříve je ukončete',nil)

                                  end
                              finally
                                  mr1.free;
                              end;


                          //mBO_ML.save ;
                          mID_ML:=mbo_ml.oid;
                   finally
                     mBO_ML.free;
                   end;
            end;
            if index=11 then begin  //mMAction1.Items.Add('');
            end;

            if index=12 then begin  //mMAction1.Items.Add('Změna záruky');
                if nxstrtoint(mbo.GetFieldValueAsstring('ServiceDocument_ID.ServiceDocState_ID.posindex'))<20 then begin
                    mBO_ML:=xSite.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                          try

                              mBO_ML:= mbo;
                              if mBO_ML.GetFieldValueAsInteger('ServiceDocument_ID.GuarantyRepair')=2 then begin
                                    mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set GuarantyRepair=3 where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                    NxShowSimpleMessage('Proběhla změna na placenou opravu',nil);
                              end else begin
                                    mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set GuarantyRepair=2 where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                    NxShowSimpleMessage('Proběhla změna na garanční opravu',nil);
                              end;
                             mBO_ML.save ;
                          mID_ML:=mbo_ml.oid;
                           finally
                             mBO_ML.free;
                           end;
                    end;
            end;
             if index=13 then begin  //mMAction1.Items.Add('Změna závady');
                if nxstrtoint(mbo.GetFieldValueAsstring('ServiceDocument_ID.ServiceDocState_ID.posindex'))<20 then begin
                    mBO_ML:=xSite.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                          try
                          mskupina:=copy(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID.DamageDescription'),1,254);
                          mresult:=InputQuery('Zadejte závadu', 'Závada: ',mskupina);
                              mBO_ML:= mbo;
                              if mresult then begin
                                    mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set DamageDescription='+ quotedstr(mskupina) + ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                              end;
                             mBO_ML.save ;
                          mID_ML:=mbo_ml.oid;
                           finally
                             mBO_ML.free;
                           end;
                    end;
            end;
      {      if index=15 then begin  //mMAction1.Items.Add('Typ platby');
               if nxstrtoint(mbo.GetFieldValueAsstring('ServiceDocument_ID.ServiceDocState_ID.posindex'))<20 then begin
                          mstate:=iGetPayment_ID(xSite);
                              if mresult then begin
                                    mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set X_PaymenType_ID='+ quotedstr(mstate) + ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                              end;
                          mID_ML:=mbo.oid;
                    end;


            end; }
            if index=14 then begin  //mMAction1.Items.Add('Zajištění subdodávky');
               mBO_ML:=xSite.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                  try
                      mdate:=getdate2(xsite);
                      mBO_ML:= mbo;
                    {  if nxisemptyoid(mBO_ML.GetFieldValueAsString('ServiceDocument_ID.BusOrder_ID')) then begin         // zakázka
                                            mIDs_BusOrder:=TStringList.create;
                                            mOLE_BusOrder:= GetAbraOLEApplication;
                                            mOResult_BusOrder:= mOLE_BusOrder.CreateStrings;
                                            mRoll_BusOrder:= mOLE_BusOrder.GetRoll('03OXHKRF4VD13ACL03KIU0CLP4', 0);
                                            if mRoll_BusOrder.MultiSelectDialog(True, mOResult_BusOrder) then begin
                                                mIDs_BusOrder.Text:= mOResult_BusOrder.Text;
                                                mID_BusOrder:= mIDs_BusOrder.Strings[0];

                                            end;

                                            mids_BusOrder.free;
                                  end;

                                  if nxisemptyoid(mBO_ML.GetFieldValueAsString('ServiceDocument_ID.BusTransaction_ID')) then begin     // obchodní případ
                                      if nxisemptyoid(mBO_ML.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID.X_Zarizeni_ID')) then begin  // Zarizeni
                                            mIDs_Zarizeni:=TStringList.create;
                                            mOLE_Zarizeni:= GetAbraOLEApplication;
                                            mOResult_Zarizeni:= mOLE_Zarizeni.CreateStrings;
                                            mRoll_Zarizeni:= mOLE_Zarizeni.GetRoll('44XM2OZD0UA4PEPGQ5KLM5EH30', 0);
                                            if mRoll_Zarizeni.MultiSelectDialog(True, mOResult_Zarizeni) then begin
                                                mIDs_Zarizeni.Text:= mOResult_Zarizeni.Text;
                                                mID_Zarizeni:= mIDs_Zarizeni.Strings[0];

                                            end;

                                            mids_Zarizeni.free;
                                      end;
                                      if nxisemptyoid(mBO_ML.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID.X_Vyrobce_ID')) then begin  // Vyrobce
                                            mIDs_Vyrobce:=TStringList.create;
                                            mOLE_Vyrobce:= GetAbraOLEApplication;
                                            mOResult_Vyrobce:= mOLE_Vyrobce.CreateStrings;
                                            mRoll_Vyrobce:= mOLE_Vyrobce.GetRoll('JQFREQ2PSRR4JCMPNFHSFR4CUW', 0);
                                            if mRoll_Vyrobce.MultiSelectDialog(True, mOResult_Vyrobce) then begin
                                               mIDs_Vyrobce.Text:= mOResult_Vyrobce.Text;
                                               mID_Vyrobce:= mIDs_Vyrobce.Strings[0];
                                            end;
                                            mids_Vyrobce.free;
                                      end;
                                      if nxisemptyoid(mBO_ML.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID.X_Typ_zarizeni_ID')) then begin  // Typ_zarizeni
                                            mIDs_Typ_zarizeni:=TStringList.create;
                                            mOLE_Typ_zarizeni:= GetAbraOLEApplication;
                                            mOResult_Typ_zarizeni:= mOLE_Typ_zarizeni.CreateStrings;
                                            mRoll_Typ_zarizeni:= mOLE_Typ_zarizeni.GetRoll('LXSSZYZN4ZIO5D10RO0VEVY2NO', 0);
                                            if mRoll_Typ_zarizeni.MultiSelectDialog(True, mOResult_Typ_zarizeni) then begin
                                               mIDs_Typ_zarizeni.Text:= mOResult_Typ_zarizeni.Text;
                                              mID_Typ_zarizeni:= mIDs_Typ_zarizeni.Strings[0];
                                            end;
                                            mids_Typ_zarizeni.free;
                                      end;

                                  end;

                                  if (mID_BusOrder<>'') or (mid_Zarizeni<>'')  then begin
                                         mbo_SP:=xsite.BaseObjectSpace.CreateObject('OWHN2TMXL2COJJ3LKNBV4OVSTC');
                                            try
                                               mbo_SP.Load(mBO_ML.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID'),nil);
                                                    if mid_BusOrder<>'' then mBO_SP.SetFieldValueAsString('BusOrder_ID',mid_BusOrder);
                                                    if mid_Zarizeni<>'' then mBO_SP.SetFieldValueAsString('X_Zarizeni_ID',mid_Zarizeni);
                                                    if mid_Vyrobce<>'' then mBO_SP.SetFieldValueAsString('X_Vyrobce_ID',mid_Vyrobce);
                                                    if mid_Typ_zarizeni<>'' then mBO_SP.SetFieldValueAsString('X_Typ_zarizeni_ID',mid_Typ_zarizeni);
                                               mbo_SP.save;
                                               mbo_SP.Refresh;
                                               mid_bustransaction:=mBO_SP.getFieldValueAsString('Bustransaction_ID');
                                            finally
                                               mbo_SP.free;
                                            end;
                                  end;

                                  if mID_BusOrder<>''  then begin
                                         mbo_SL:=xsite.BaseObjectSpace.CreateObject('BCHF52UGXCO4H5MIAQVY5P3ZOC');
                                            try
                                               mbo_sl.Load(mBO_ML.GetFieldValueAsString('ServiceDocument_ID'),nil);
                                                    if mid_BusOrder<>'' then mBO_SL.SetFieldValueAsString('BusOrder_ID',mid_BusOrder);
                                                    if nxisemptyoid(mBO_SL.getFieldValueAsString('BusTransaction_ID')) then begin
                                                       mBO_SL.SetFieldValueAsString('BusTransaction_ID',mid_bustransaction);
                                                    end;
                                               mbo_sl.save;
                                               mbo_sl.Refresh;
                                            finally
                                               mbo_sl.free;
                                            end;
                                  end;

                                  if not nxisemptyoid(mBO_ML.GetFieldValueAsString('ServiceDocument_ID.BusTransaction_ID')) then begin    }
                                       smresult:=zajisteni_subdodavky(xSite,mBO_ML,mDate);
                                  //end else begin
                                  //    NxShowSimpleMessage('Není uveden obchodní případ, není požné pokračovat',nil);
                                  //end;


                      mID_ML:=mbo_ml.oid;
                      xsite.RefreshData;
                 finally
                    mbo_ml.free;
                 end;
            end;
            mi:=xsite.BaseObjectSpace.SQLExecute('update SERVICEASSEMBLYFORMS2 SA2 set Sa2.x_koeficient=100/(select count(id) from SERVICEASSEMBLYFORMS2 where parent_id=sa2.parent_ID and (itemtype=4 and text='+quotedstr('Práce - evidenční pro mzdy') + '))  where (sa2.itemtype=4) and (select count(id) from SERVICEASSEMBLYFORMS2 where itemtype=4 and parent_id=sa2.parent_ID and text='+quotedstr('Práce - evidenční pro mzdy') + ')<>0 and Sa2.parent_ID='
            +quotedstr(mID_ML)) ;
            if index =15 then begin     // posunutí termínu servisu
               mBO_ML:=xSite.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                   try
                      mBO_ML:= mbo;
                      if True then begin
                      //mi:=xsite.BaseObjectSpace.SQLExecute('update ServiceAssemblyForms2 set X_Konec_prace =' + QuotedStr('') + ' where parent.ID=' + quotedstr(mbo.oid));
                          if mposun<>0 then begin

                              mBO_ML.setFieldValueAsDateTime('StartDate$DATE',mBO_ML.getFieldValueAsDateTime('StartDate$DATE')+mposun);
                              mBO_ML.setFieldValueAsDateTime('EndDate$DATE',mBO_ML.getFieldValueAsDateTime('EndDate$DATE')+mposun);
                              mBO_ML.save;
                              mi:=xsite.BaseObjectSpace.SQLExecute('update ServiceAssemblyForms2 set X_konec_prace=' + NxFloatToIBStr(mBO_ML.getFieldValueAsDateTime('EndDate$DATE')) +
                                ' where parent_id='+quotedstr(mBO_ML.oid) );
                              mi:=xsite.BaseObjectSpace.SQLExecute('update CRMActivities set SheduledStart$Date=' + NxFloatToIBStr(mBO_ML.getFieldValueAsDateTime('StartDate$DATE'))+
                                ',SheduledEnd$Date=' + NxFloatToIBStr(mBO_ML.getFieldValueAsDateTime('EndDate$DATE'))+
                                ',RealStart$Date=' + NxFloatToIBStr(mBO_ML.getFieldValueAsDateTime('StartDate$DATE'))+
                                ',RealEnd$Date=' + NxFloatToIBStr(mBO_ML.getFieldValueAsDateTime('EndDate$DATE'))+
                               ' where X_parent_head='+quotedstr(mBO_ML.oid) );

                         end;
                    end;
                  finally
                      mbo_ml.free;
                  end;
            end;
    end else begin
        for mI_ML:= 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
           mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(mI_ML));
           mBO:= TDynSiteForm(xSite).CurrentObject;
           if nxstrtoint(mbo.GetFieldValueAsstring('ServiceDocument_ID.ServiceDocState_ID.posindex'))<20 then begin
                     //*******


                      if index=0 then begin  //mMAction1.Items.Add('Zadání technika');
                            mBO_ML:=xSite.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                            try
                                mBO_ML:= mbo;
                                mRows_ML := mBO_ML.GetCollectionMonikerForFieldCode(mBO_ML.GetFieldCode('Rows'));
                                mresult:=GetTechnik(xSite,mbo_ml,mRows_ML,mIDs_WorkerRole,mDateinput);
                                if not mresult then begin
                                    NxShowSimpleMessage('Při zadání technika došlo k chybě:',nil);
                                end else begin
                                    mBO_ML.SetFieldValueAsString('X_state','4U12000101');
                                    mBO_ML.SetFieldValueAsinteger('AssemblyState',trunc(NxIBStrToFloat(mBO_ML.getFieldValueAsString('X_state.X_field2'))));

                                 end;
                                mBO_ml.save;
                                   mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' +QuotedStr(mBO_ML.getFieldValueAsString('X_state.X_field1'))+ ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;

                                mID_ML:=mbo_ml.oid;
                            finally
                                mbo_ml.free;
                            end;
                      end;
                      if index=1 then begin  //mMAction1.Items.Add('Rozpočet fakturace');
                            mBO_ML:=xSite.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                            try
                                mBO_ML:= mbo;
                                mRows_ML := mBO_ML.GetCollectionMonikerForFieldCode(mBO_ML.GetFieldCode('Rows'));
                                mresult:=Fakturacni_ceny(mBO_ML,xSite,mRows_ML,mstav);
                                if not mresult then begin
                                    NxShowSimpleMessage('Při rozpočtu fakturace došlo k chybě:',nil);
                                end else begin
                                     if nxisblank(mBO_ML.getFieldValueAsString('X_Spedos_formular')) and
                                             not nxisblank(trim(mBO_ML.getFieldValueAsString('X_Protokol')))
                                          then begin
                                              mfile:='';
                                                       mfile:=autocopy_protocol(mBO_ML);
                                                       if mfile='' then begin
                                                           mfile:=manualcopy_protocol(mBO_ML);
                                                       end;
                                                       if mfile<>'' then begin
                                                          mBO_ML.SetFieldValueAsString('X_Spedos_formular',mfile);
                                                          //TDynSiteForm(self).ActiveDataSet.RefreshCurrentItem;
                                                        end;
                                     end;
                                           mBO_ML.SetFieldValueAsString('X_state','3Q22000101');
                                    mBO_ML.SetFieldValueAsinteger('AssemblyState',trunc(NxIBStrToFloat(mBO_ML.getFieldValueAsString('X_state.X_field2'))));
                                end;
                                mBO_ml.save;
                                mID_ML:=mbo_ml.oid;
                                    mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' +QuotedStr(mBO_ML.getFieldValueAsString('X_state.X_field1'))+ ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;

                            finally
                                mbo_ml.free;
                            end;

                      end;
                      if index=2 then begin  //mMAction1.Items.Add('Zadání materiálu');
                         mBO_ML:=xSite.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                            try
                                mBO_ML:= mbo;
                                mRows_ML := mBO_ML.GetCollectionMonikerForFieldCode(mBO_ML.GetFieldCode('Rows'));
                                mresult:=NEWMaterial(mBO_ml,xsite,mRows_ml);
                                if not mresult then begin
                                  NxShowSimpleMessage('Při zadávání materiálu došlo k chybě:',nil);
                                end else begin
                                    mBO_ML.SetFieldValueAsString('X_state','45W1000101');
                                    mBO_ML.SetFieldValueAsinteger('AssemblyState',trunc(NxIBStrToFloat(mBO_ML.getFieldValueAsString('X_state.X_field2'))));
                                 end;
                                mBO_ml.save;
                                     mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_State=' + quotedstr('45W1000101') + ', AssemblyState=1 where id=' + QuotedStr(mBO_ML.oid));
                                     mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' +QuotedStr(mBO_ML.getFieldValueAsString('X_state.X_field1'))+ ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                mID_ML:=mbo_ml.oid;
                            finally
                                mbo_ml.free;
                            end;


                      end;
                      if index=3 then begin  //text
                      mBO_ML:=xSite.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                              try
                                  mBO_ML:= mbo;
                                  mRows_ML := mBO_ML.GetCollectionMonikerForFieldCode(mBO_ML.GetFieldCode('Rows'));
                                  mresult:=NEWtext(mBO_ml,xsite,mRows_ml);
                                  if not mresult then begin
                                    NxShowSimpleMessage('Při zadávání textu došlo k chybě:',nil);
                                  end else begin
                                   end;
                                  mBO_ml.save;
                                 mID_ML:=mbo_ml.oid;
                              finally
                                  mbo_ml.free;
                              end;
                      end;
                      if index=4 then begin  //mMAction1.Items.Add('Cenová nabídka');
                           mBO_ML:=xSite.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                            try
                                mBO_ML:= mbo;
                                mRows_ML := mBO_ML.GetCollectionMonikerForFieldCode(mBO_ML.GetFieldCode('Rows'));
                                 mrxx:=TStringList.create;
                                   try
                                          mBO_ML.ObjectSpace.SQLSelect('select SA2.id from ServiceAssemblyForms2 SA2 left join ServiceAssemblyForms sa on SA.ID=sa2.Parent_ID where sa2.ToInvoiceType=0 and sa2.IsInvoiced=0 and sa.id=' + quotedstr(mBO_ML.OID)+' order by PosIndex',mrxx);
                                          for ii := 0 to mrxx.Count-1 do begin // projdu vsechny oznacene zaznamy
                                               if not NxIsEmptyOID(mrxx.Strings[ii]) then mIDs_MLRow.Add(mrxx.Strings[ii]);
                                          end;
                                   finally
                                       //mbo1.free;   nesmi byt jedna se o CurrentObject~~
                                       mrxx.free;
                                   end;






                              //  if smresult='' then begin
                              //      NxShowSimpleMessage('Při cenové nabídce došlo k chybě:',nil);
                              //  end else begin

                              //     mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_State=' + quotedstr('4XQ1000101') + ', AssemblyState=1 where id=' + QuotedStr(mBO_ML.oid));
                              //      mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' +QuotedStr('9000000101')+ ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;

                              //  end;
                                      mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_State=' + quotedstr('4XQ1000101') + ', AssemblyState=1 where id=' + QuotedStr(mBO_ML.oid));
                                      mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' +QuotedStr('9000000101')+ ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;

                                 mID_ML:=mbo_ml.oid;
                            finally
                                mbo_ml.free;
                            end;
                      end;
                      if index=5 then begin  //mMAction1.Items.Add('Zajištění materiálu');
                           mBO_ML:=xSite.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                            try
                                mdate:=getdate2(xsite);
                                mBO_ML:= mbo;
                                mRows_ML := mBO_ML.GetCollectionMonikerForFieldCode(mBO_ML.GetFieldCode('Rows'));
                                smresult:=zajisteni_zasob(xSite,mBO_ML,mDate);
                                //if smresult='' then NxShowSimpleMessage('Při cenové nabídce došlo k chybě:',nil);
                                     mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_State=' + quotedstr('3IS1000101') + ', AssemblyState=1 where id=' + QuotedStr(mBO_ML.oid));

                                  mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_Stav_objednani=1 where id=' + QuotedStr(mBO_ML.oid));
                                  mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_State=' + quotedstr('3IS1000101') + ', AssemblyState=1 where id=' + QuotedStr(mBO_ML.oid));
                                  mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' +QuotedStr('A102000000')+ ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;

                                mBO_ml.save;
                                mBO_ml.save;
                                mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' +QuotedStr(mBO_ML.getFieldValueAsString('X_state.X_field1'))+ ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;

                                mID_ML:=mbo_ml.oid;
                            finally
                                mbo_ml.free;
                            end;
                      end;
                      if index=6 then begin  //mMAction1.Items.Add('Vyskladnění materiálu');
                       mBO_ML:=xSite.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                            try
                                mdate:=getdate2(xsite);
                                mBO_ML:= mbo;
                                                if xsite.CompanyCache.GetUserID='SUPER00000' then begin              //kontrola obchodního případu
                                                          if mpotvrzeni='Ano' then begin      // kontrola OP
                                                                    if nxisemptyoid(mbo_ML.GetFieldValueAsString('serviceDocument_id.ServicedObject_id.Bustransaction_ID')) then begin
                                                                         NxShowSimpleMessage('Není uveden obchodní případ, je nutné jej specifikovat',nil);
                                                                         mresult_ID:=GetBusTransaction_ID(mbo);
                                                                         if mresult_ID<>'' then begin
                                                                             mI:=xSite.BaseObjectSpace.SQLExecute('Update serviceDocuments set BusTransaction_ID=' + quotedstr(mresult_ID) + ' where serviceDocument_id=' + quotedstr(mbo_ML.GetFieldValueAsString('serviceDocument_id')))
                                                                         end;
                                                                    end;

                                                          end;
                                                end;

                                 // if not nxisemptyoid(mBO_ML.GetFieldValueAsString('ServiceDocument_ID.BusTransaction_ID')) then begin
                                       smresult:=Vyskladneni_zasob(xSite,mBO_ML,mdate);
                                       mBO_ml.SetFieldValueAsString('X_State','3Q22000101');
                                       mBO_ml.Save;
                                       mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_State=' + quotedstr('3Q22000101') + ', AssemblyState=1 where id=' + QuotedStr(mBO_ML.oid));
                                       mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' +QuotedStr('A102000000')+ ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                 // end else begin
                                 //     NxShowSimpleMessage('Není uveden obchodní případ, není požné pokračovat',nil);
                                 // end;
                                  mID_ML:=mbo_ml.oid;
                            finally
                                mbo_ml.free;
                            end;
                      end;
                      if index=7 then begin  //mMAction1.Items.Add('Stav ML');
                      mBO_ML:=xSite.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                            try
                               mpotvrzeni:='ANO';
                                mBO_ML:= mbo;
                                mRows_ML := mBO_ML.GetCollectionMonikerForFieldCode(mBO_ML.GetFieldCode('Rows'));
                                mOrigState:=mBO_ML.GetFieldValueAsstring('X_State');

                                if mstate<>'' then begin

                                      if (mstate='6XQ1000101') or (mstate='AXQ1000101') then begin



                                                  // ** není vydán všechen materiál
                                                  mr:=TStringList.create;
                                                  try
                                                     xsite.BaseObjectSpace.SQLSelect('Select sum(Quantity-QuantityDelivered) from ServiceAssemblyForms2 where ItemType =1 and x_storno=' + quotedstr('N') + 'and parent_id=' + quotedstr(mBO_ml.OID),mr);
                                                     if strtoint(mr.Strings[0])<>0 then begin
                                                        mpotvrzeni:=InputBox('Není vydán všechen materiál. ','Přesto pokračovat? ',mpotvrzeni, xsite);
                                                        //mstav_rozprac:=copy(mstav_rozprac,1,3)+'A'+copy(mstav_rozprac,5,4)  ;

                                                     end;
                                                  finally
                                                     mr.free;
                                                  end;
                                                  // na ML není uvedena žádná práce
                                                  mr1:=TStringList.create;
                                                  try
                                                     xsite.BaseObjectSpace.SQLSelect('Select count(id) from ServiceAssemblyForms2 where (ItemType =4 and text=' + quotedstr('Práce - evidenční pro mzdy') + ')  or (ItemType =0 and storecard_id=' + quotedstr('2ZI1000101') +' )and parent_id=' + quotedstr(mbo.OID),mr1);
                                                     if (mpotvrzeni='ANO') and (strtoint(mr1.Strings[0])=0) then begin
                                                        mpotvrzeni:=InputBox('Není zadána žádná práce. ','Přesto pokračovat? ',mpotvrzeni, xsite);
                                                        //mstav_rozprac:=copy(mstav_rozprac,1,1)+'A'+copy(mstav_rozprac,3,6)  ;
                                                     end;
                                                  finally
                                                     mr1.free;
                                                  end;
                                                  // ** není rozpočítaná všechna práce
                                                  mr2:=TStringList.create;
                                                  try
                                                     xsite.BaseObjectSpace.SQLSelect('Select count(id) from ServiceAssemblyForms2 where ItemType =0 and storecard_id=' + quotedstr('2ZI1000101') + 'and parent_id=' + quotedstr(mbo.OID),mr2);
                                                     if (mpotvrzeni='ANO') and (strtoint(mr2.Strings[0])<>0) then begin
                                                        mpotvrzeni:=InputBox('Není rozpočítaná práce žádná práce. ','Přesto pokračovat? ',mpotvrzeni, xsite);
                                                        //mstav_rozprac:=copy(mstav_rozprac,1,2)+'A'+copy(mstav_rozprac,4,5)  ;
                                                     end;
                                                  finally
                                                     mr2.free;
                                                  end;
                                                 end;

                                                if UpperCase(Trim(mpotvrzeni))='ANO' then begin
                                                    //mbo.setFieldValueAsstring('X_State',mstate);
                                                    //mbo.SetFieldValueAsInteger('AssemblyState',StrToInt(mbo.getFieldValueAsstring('X_State.X_Field2')));
                                                    if not nxisblank(copy(mbo_ML.GetFieldValueAsString('serviceDocument_id.ServicedObject_id.X_Ukonceni'),1,100)) then begin
                                                        NxShowSimpleMessage('Upozornění: '+ trim(copy(mbo.GetFieldValueAsString('serviceDocument_id.ServicedObject_id.X_Ukonceni'),1,254)),nil);
                                                    end;


                                                end;

                                               if xsite.CompanyCache.GetUserID='SUPER00000' then begin              //kontrola obchodního případu
                                                          if mpotvrzeni='Ano' then begin      // kontrola OP
                                                                    if nxisemptyoid(mbo_ML.GetFieldValueAsString('serviceDocument_id.ServicedObject_id.Bustransaction_ID')) then begin
                                                                         NxShowSimpleMessage('Není uveden obchodní případ, je nutné jej specifikovat',nil);
                                                                         mresult_ID:=GetBusTransaction_ID(mbo);
                                                                         if mresult_ID<>'' then begin
                                                                             mI:=xSite.BaseObjectSpace.SQLExecute('Update serviceDocuments set BusTransaction_ID=' + quotedstr(mresult_ID) + ' where serviceDocument_id=' + quotedstr(mbo_ML.GetFieldValueAsString('serviceDocument_id')))
                                                                         end;
                                                                    end;

                                                          end;
                                                end;












                                                 if UpperCase(Trim(mpotvrzeni))='ANO' then begin
                                                     mBO_ML.SetFieldValueAsDateTime('X_ClosedDate$DATE',date);
                                                     if mstate='6XQ1000101' then begin
                                                         if mbo_ml.GetFieldValueAsString('ServiceDocument_ID.X_objednani')='' then begin
                                                                mBO_ML.SetFieldValueAsstring('X_State','7XQ1000101');
                                                                mBO_ML.SetFieldValueAsinteger('AssemblyState',3);
                                                         end else begin
                                                                mBO_ML.SetFieldValueAsstring('X_State',mstate);
                                                         end;
                                                     end else begin
                                                         mBO_ML.SetFieldValueAsstring('X_State',mstate);
                                                     end;


                                                     mBO_ML.save;
                                                     mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set X_VatDate=' +NxFloatToIBStr(mBO_ML.getFieldValueAsDateTime('EndDate$DATE'))+ ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                      end else begin
                                          mBO_ML.SetFieldValueAsstring('X_State',mstate);
                                          mpotvrzeni:='A';
                                          mBO_ML.SetFieldValueAsinteger('AssemblyState',trunc(NxIBStrToFloat(mBO_ML.getFieldValueAsString('X_state.X_field2'))));
                                          mBO_ML.save;
                                      end;
                                      if (mstate='3JS1000101') then begin
                                         mr:=TStringList.create;
                                                    try


                                                          xsite.BaseObjectSpace.SQLSelect('select id from ServiceAssemblyForms where ServiceDocument_ID=' + QuotedStr(mBO_ML.GetFieldValueAsString('ServiceDocument_ID')) +
                                                              ' and x_state<>' + quotedstr('38S1000101')+ '  and x_state<>'+ quotedstr('6XQ1000101')
                                                              + '  and x_state<>'+ quotedstr('AXQ1000101')+ '  and x_state<>'+ quotedstr('3JS1000101')+ '  and x_state<>'+ quotedstr('3VW1000101')
                                                              + '  and x_state<>'+ quotedstr('3AU1000101')+ '  and x_state<>'+ quotedstr('8XQ1000101')+ '  and x_state<>'+ quotedstr('9XQ1000101')
                                                          ,mr) ;


                                                              if mr.count<1 then begin
                                                                 mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' +QuotedStr('9200000101')+ ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                                              end;
                                                    finally
                                                        mr.free;
                                                    end;
                                     end;


                                      mID_ML:=mbo_ml.oid;
                                        mr:=TStringList.create;
                                        try


                                              xsite.BaseObjectSpace.SQLSelect('select id from ServiceAssemblyForms where ServiceDocument_ID=' + QuotedStr(mBO_ML.GetFieldValueAsString('ServiceDocument_ID')) +
                                                  ' and x_state<>' + quotedstr('38S1000101')+ '  and x_state<>'+ quotedstr('6XQ1000101')
                                                  + '  and x_state<>'+ quotedstr('AXQ1000101')+ '  and x_state<>'+ quotedstr('3JS1000101')+ '  and x_state<>'+ quotedstr('3VW1000101')
                                                  + '  and x_state<>'+ quotedstr('3AU1000101')+ '  and x_state<>'+ quotedstr('8XQ1000101')+ '  and x_state<>'+ quotedstr('9XQ1000101')
                                              ,mr) ;


                                                  if mr.count<1 then begin
                                                      mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' +QuotedStr(mBO_ML.getFieldValueAsString('X_state.X_field1'))+ ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                                  end;
                                        finally
                                            mr.free;
                                        end;
                                        if (mstate='38S1000101') then begin
                                         mr:=TStringList.create;
                                                    try
                                                         mBO_ML.save;
                                                         mID_ML:=mbo_ml.oid;

                                                          xsite.BaseObjectSpace.SQLSelect('select id from ServiceAssemblyForms where ServiceDocument_ID=' + QuotedStr(mBO_ML.GetFieldValueAsString('ServiceDocument_ID')) +
                                                              ' and x_state<>' + quotedstr('38S1000101')+ '  and x_state<>'+ quotedstr('4XQ1000101')

                                                          ,mr) ;


                                                              if mr.count<1 then begin
                                                                 mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' +QuotedStr('9600000101')+ ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                                              end;
                                                    finally
                                                        mr.free;
                                                    end;
                                     end;




                                     end;

                             finally
                               mBO_ML.free;
                             end;
                      end;
                      if index=8 then begin  //mMAction1.Items.Add('');
                      end;
             end;
                      if index=9 then begin  //mMAction1.Items.Add('Doplnění čísla objednávky');
                          mID_ML:=mBO.oid;
                          mBO_ML:=xSite.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                            try
                                mBO_ML:= mbo;
                                     mtext:=mtext+mbo_ml.GetFieldValueAsString('ServiceDocument_ID.X_objednani');
                                     mresult:=InputQuery('Číslo objednávky', 'Objednávka zákazníka :',mtext);
                                      if (mtext<>'') then begin
                                              mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set X_objednani=' + quotedstr(mtext) + ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                        end;

                                         if (mBO_ML.getFieldValueAsstring('X_State')='7XQ1000101') and (mtext<>'') then begin
                                           mBO_ML.SetFieldValueAsstring('X_State','6XQ1000101');
                                             if (mresult)  then  begin
                                                  mBO_ML.save;
                                                  mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' +QuotedStr('C102000000') + ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                                   //mBO_ML.SetFieldValueAsinteger('AssemblyState',3);

                                             end;

                                             if (mBO_ML.getFieldValueAsstring('X_State')='7XQ1000101') and (mtext='') then begin
                                                   if mresult then begin
                                                       mBO_ML.SetFieldValueAsstring('X_State','6XQ1000101');
                                                       mBO_ML.save;
                                                       mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' +QuotedStr('A400000101') + ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;

                                                   end;
                                             end;
                                         end;
                            finally
                                mbo_ml.free;
                            end;

                      end;

            if index=10 then begin  //mMAction1.Items.Add('Odeslání k fakturaci');
                mBO_ML:=xSite.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                  try
                      mBO_ML:= mbo;
                                                                        if xsite.CompanyCache.GetUserID='SUPER00000' then begin              //kontrola obchodního případu
                                                          if mpotvrzeni='Ano' then begin      // kontrola OP
                                                                    if nxisemptyoid(mbo_ML.GetFieldValueAsString('serviceDocument_id.ServicedObject_id.Bustransaction_ID')) then begin
                                                                         NxShowSimpleMessage('Není uveden obchodní případ, je nutné jej specifikovat',nil);
                                                                         mresult_ID:=GetBusTransaction_ID(mbo);
                                                                         if mresult_ID<>'' then begin
                                                                             mI:=xSite.BaseObjectSpace.SQLExecute('Update serviceDocuments set BusTransaction_ID=' + quotedstr(mresult_ID) + ' where serviceDocument_id=' + quotedstr(mbo_ML.GetFieldValueAsString('serviceDocument_id')))
                                                                         end;
                                                                    end;

                                                          end;
                                                end;



                           mr1:=tstringlist.create;
                              try
                                  mbo.ObjectSpace.SQLSelect('select id from ServiceAssemblyForms where ServiceDocument_ID=' + QuotedStr(mBO_ML.GetFieldValueAsString('ServiceDocument_ID')) +
                                  ' and x_state<>' + quotedstr('38S1000101')+ '  and x_state<>'+ quotedstr('6XQ1000101')
                                  + '  and x_state<>'+ quotedstr('AXQ1000101')+ '  and x_state<>'+ quotedstr('3JS1000101')+ '  and x_state<>'+ quotedstr('3VW1000101')
                                  + '  and x_state<>'+ quotedstr('3AU1000101')+ '  and x_state<>'+ quotedstr('8XQ1000101')+ '  and x_state<>'+ quotedstr('9XQ1000101')
          ,mr1) ;
                                  if mr1.count=0 then begin

                                                if mresult then begin
                                                if mbo.GetFieldValueAsInteger('ServiceDocument_ID.X_skupina')=0 then begin
                                                        mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set X_skupina=' + mskupina + ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                                end;
                                                                mr_sum:=TStringList.create;
                                                                try
                                                                 xsite.BaseObjectSpace.SQLSelect('select trunc(sum((SA2.UnitPriceWithoutVAT*SA2.Quantity) -(SA2.UnitPriceWithoutVAT*SA2.Quantity*0.01*SA2.X_radkova_sleva) ))  from ServiceAssemblyForms2 SA2 '
                                                                                                +
                                                                                                ' left join ServiceAssemblyForms SA on sa.id=SA2.Parent_ID left join ServiceDocuments SD on SD.id=SA.ServiceDocument_ID'

                                                                                                +' where SA2.itemtype=1 and SA2.ToInvoiceType=0 and sd.GuarantyRepair<>2 and SD.ID=' + quotedstr(mbo.GetFieldValueAsString('ServiceDocument_ID')),mr_sum);
                                                                 if NxIBStrToFloat(mr_sum.strings[0])<>0 then

                                                                       mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set TotalMaterial=' +(mr_sum.strings[0]) + ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;

                                                                finally
                                                                    mr_sum.Free;
                                                                end;

                                                                  mr_sum:=TStringList.create;
                                                                try
                                                                 xsite.BaseObjectSpace.SQLSelect('select trunc(sum((SA2.UnitPriceWithoutVAT*SA2.WorkHoursReal) -(SA2.UnitPriceWithoutVAT*SA2.WorkHoursReal*0.01*SA2.X_radkova_sleva)) )  from ServiceAssemblyForms2 SA2 '
                                                                                                +
                                                                                                ' left join ServiceAssemblyForms SA on sa.id=SA2.Parent_ID left join ServiceDocuments SD on SD.id=SA.ServiceDocument_ID'

                                                                                                +' where SA2.itemtype=0 and SA2.ToInvoiceType=0 and sd.GuarantyRepair<>2 and SD.ID=' + quotedstr(mbo.GetFieldValueAsString('ServiceDocument_ID')),mr_sum);
                                                                 if NxIBStrToFloat(mr_sum.strings[0])<>0 then
                                                                 mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set TotalWork=' +mr_sum.strings[0] + ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;

                                                                 //mbo.SetFieldValueAsFloat('TotalWork',StrToFloat(mr_sum.strings[0]));

                                                                finally
                                                                    mr_sum.Free;
                                                                end;

                                                                 mr_sum:=TStringList.create;
                                                                try
                                                                 xsite.BaseObjectSpace.SQLSelect('select trunc(sum((SA2.UnitPriceWithoutVAT*sa2.quantity) -(SA2.UnitPriceWithoutVAT*sa2.quantity*0.01*SA2.X_radkova_sleva)) )  from ServiceAssemblyForms2 SA2 '
                                                                                                +
                                                                                                ' left join ServiceAssemblyForms SA on sa.id=SA2.Parent_ID left join ServiceDocuments SD on SD.id=SA.ServiceDocument_ID'

                                                                                                +' where SA2.itemtype>1 and SA2.ToInvoiceType=0 and sd.GuarantyRepair<>2 and SD.ID=' + quotedstr(mbo.GetFieldValueAsString('ServiceDocument_ID')),mr_sum);
                                                                 if NxIBStrToFloat(mr_sum.strings[0])<>0 then
                                                                 mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set TotalOther=' + mr_sum.strings[0] + ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;

                                                                //  mbo.SetFieldValueAsFloat('',StrToFloat(mr_sum.strings[0]));

                                                                finally
                                                                    mr_sum.Free;
                                                                end;

                                                                mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set TotalAmount=(TotalMaterial+TotalWork+TotalOther) where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;





                                                     if mstate='6XQ1000101' then begin
                                                          mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' + QuotedStr('D102000000') + ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                                         // mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_State=' + quotedstr('8XQ1000101') + ' where ServiceDocument_ID=' + QuotedStr(mBO_ML.GetFieldValueAsString('ServiceDocument_ID')) +
                                                         //       ' and x_state<>'+ quotedstr('3Q22000101'));
                                                          mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceAssemblyForms set AssemblyState=3 where ServiceDocument_ID=' + QuotedStr(mBO_ML.GetFieldValueAsString('ServiceDocument_ID')) +
                                                                ' and x_state<>'+ quotedstr('3Q22000101'));

                                                     end else begin
                                                             mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' + QuotedStr('D102000000') + ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;

                                                     end;
                                                end;




                                  end else begin
                                     NxShowSimpleMessage('Existují neukončené ML. Nejdříve je ukončete',nil)

                                  end
                              finally
                                  mr1.free;
                              end;


                          //mBO_ML.save ;
                          mID_ML:=mbo_ml.oid;
                   finally
                     mBO_ML.free;
                   end;
            end;
            if index=11 then begin  //mMAction1.Items.Add('');
            end;
            if nxstrtoint(mbo.GetFieldValueAsstring('ServiceDocument_ID.ServiceDocState_ID.posindex'))<20 then begin
                  if index=12 then begin  //mMAction1.Items.Add('Změna záruky');
                          mBO_ML:=xSite.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                                try

                                    mBO_ML:= mbo;
                                    if mBO_ML.GetFieldValueAsInteger('ServiceDocument_ID.GuarantyRepair')=2 then begin
                                          mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set GuarantyRepair=3 where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                          NxShowSimpleMessage('Proběhla změna na placenou opravu',nil);
                                    end else begin
                                          mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set GuarantyRepair=2 where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                                          NxShowSimpleMessage('Proběhla změna na garanční opravu',nil);
                                    end;
                                   mBO_ML.save ;
                                mID_ML:=mbo_ml.oid;
                                 finally
                                   mBO_ML.free;
                                 end;
                  end;
            end;
             if index=13 then begin  //mMAction1.Items.Add('Změna závady');
                if nxstrtoint(mbo.GetFieldValueAsstring('ServiceDocument_ID.ServiceDocState_ID.posindex'))<20 then begin
                      mBO_ML:=xSite.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                      mBO_ML:= mbo;
                          try
                          mskupina:=mBO_ML.GetFieldValueAsString('ServiceDocument_ID.DamageDescription');
                          mresult:=InputQuery('Zadejte závadu', 'Závada: ',mskupina);
                              if mresult then begin
                                    mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set DamageDescription='+ QuotedStr(mskupina) + ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                              end;
                             mBO_ML.save ;
                          mID_ML:=mbo_ml.oid;
                           finally
                             mBO_ML.free;
                           end;
                end;
            end;

            if index=14 then begin  //mMAction1.Items.Add('Zajištění subdodávky');
               mBO_ML:=xSite.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                  try
                      mdate:=getdate2(xsite);
                      mBO_ML:= mbo;
                     { if nxisemptyoid(mBO_ML.GetFieldValueAsString('ServiceDocument_ID.BusOrder_ID')) then begin         // zakázka
                                            mIDs_BusOrder:=TStringList.create;
                                            mOLE_BusOrder:= GetAbraOLEApplication;
                                            mOResult_BusOrder:= mOLE_BusOrder.CreateStrings;
                                            mRoll_BusOrder:= mOLE_BusOrder.GetRoll('03OXHKRF4VD13ACL03KIU0CLP4', 0);
                                            if mRoll_BusOrder.MultiSelectDialog(True, mOResult_BusOrder) then begin
                                                mIDs_BusOrder.Text:= mOResult_BusOrder.Text;
                                                mID_BusOrder:= mIDs_BusOrder.Strings[0];

                                            end;

                                            mids_BusOrder.free;
                                  end;

                                  if nxisemptyoid(mBO_ML.GetFieldValueAsString('ServiceDocument_ID.BusTransaction_ID')) then begin     // obchodní případ
                                      if nxisemptyoid(mBO_ML.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID.X_Zarizeni_ID')) then begin  // Zarizeni
                                            mIDs_Zarizeni:=TStringList.create;
                                            mOLE_Zarizeni:= GetAbraOLEApplication;
                                            mOResult_Zarizeni:= mOLE_Zarizeni.CreateStrings;
                                            mRoll_Zarizeni:= mOLE_Zarizeni.GetRoll('44XM2OZD0UA4PEPGQ5KLM5EH30', 0);
                                            if mRoll_Zarizeni.MultiSelectDialog(True, mOResult_Zarizeni) then begin
                                                mIDs_Zarizeni.Text:= mOResult_Zarizeni.Text;
                                                mID_Zarizeni:= mIDs_Zarizeni.Strings[0];

                                            end;

                                            mids_Zarizeni.free;
                                      end;
                                      if nxisemptyoid(mBO_ML.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID.X_Vyrobce_ID')) then begin  // Vyrobce
                                            mIDs_Vyrobce:=TStringList.create;
                                            mOLE_Vyrobce:= GetAbraOLEApplication;
                                            mOResult_Vyrobce:= mOLE_Vyrobce.CreateStrings;
                                            mRoll_Vyrobce:= mOLE_Vyrobce.GetRoll('JQFREQ2PSRR4JCMPNFHSFR4CUW', 0);
                                            if mRoll_Vyrobce.MultiSelectDialog(True, mOResult_Vyrobce) then begin
                                               mIDs_Vyrobce.Text:= mOResult_Vyrobce.Text;
                                               mID_Vyrobce:= mIDs_Vyrobce.Strings[0];
                                            end;
                                            mids_Vyrobce.free;
                                      end;
                                      if nxisemptyoid(mBO_ML.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID.X_Typ_zarizeni_ID')) then begin  // Typ_zarizeni
                                            mIDs_Typ_zarizeni:=TStringList.create;
                                            mOLE_Typ_zarizeni:= GetAbraOLEApplication;
                                            mOResult_Typ_zarizeni:= mOLE_Typ_zarizeni.CreateStrings;
                                            mRoll_Typ_zarizeni:= mOLE_Typ_zarizeni.GetRoll('LXSSZYZN4ZIO5D10RO0VEVY2NO', 0);
                                            if mRoll_Typ_zarizeni.MultiSelectDialog(True, mOResult_Typ_zarizeni) then begin
                                               mIDs_Typ_zarizeni.Text:= mOResult_Typ_zarizeni.Text;
                                              mID_Typ_zarizeni:= mIDs_Typ_zarizeni.Strings[0];
                                            end;
                                            mids_Typ_zarizeni.free;
                                      end;

                                  end;

                                  if (mID_BusOrder<>'') or (mid_Zarizeni<>'')  then begin
                                         mbo_SP:=xsite.BaseObjectSpace.CreateObject('OWHN2TMXL2COJJ3LKNBV4OVSTC');
                                            try
                                               mbo_SP.Load(mBO_ML.GetFieldValueAsString('ServiceDocument_ID.ServicedObject_ID'),nil);
                                                    if mid_BusOrder<>'' then mBO_SP.SetFieldValueAsString('BusOrder_ID',mid_BusOrder);
                                                    if mid_Zarizeni<>'' then mBO_SP.SetFieldValueAsString('X_Zarizeni_ID',mid_Zarizeni);
                                                    if mid_Vyrobce<>'' then mBO_SP.SetFieldValueAsString('X_Vyrobce_ID',mid_Vyrobce);
                                                    if mid_Typ_zarizeni<>'' then mBO_SP.SetFieldValueAsString('X_Typ_zarizeni_ID',mid_Typ_zarizeni);
                                               mbo_SP.save;
                                               mbo_SP.Refresh;
                                               mid_bustransaction:=mBO_SP.getFieldValueAsString('Bustransaction_ID');
                                            finally
                                               mbo_SP.free;
                                            end;
                                  end;

                                  if mID_BusOrder<>''  then begin
                                         mbo_SL:=xsite.BaseObjectSpace.CreateObject('BCHF52UGXCO4H5MIAQVY5P3ZOC');
                                            try
                                               mbo_sl.Load(mBO_ML.GetFieldValueAsString('ServiceDocument_ID'),nil);
                                                    if mid_BusOrder<>'' then mBO_SL.SetFieldValueAsString('BusOrder_ID',mid_BusOrder);
                                                    if nxisemptyoid(mBO_SL.getFieldValueAsString('BusTransaction_ID')) then begin
                                                       mBO_SL.SetFieldValueAsString('BusTransaction_ID',mid_bustransaction);
                                                    end;
                                               mbo_sl.save;
                                               mbo_sl.Refresh;
                                            finally
                                               mbo_sl.free;
                                            end;
                                  end;

                                  if not nxisemptyoid(mBO_ML.GetFieldValueAsString('ServiceDocument_ID.BusTransaction_ID')) then begin    }
                                       smresult:=zajisteni_subdodavky(xSite,mBO_ML,mDate);
                              //    end else begin
                              //        NxShowSimpleMessage('Není uveden obchodní případ, není požné pokračovat',nil );
                             //     end;






                      mID_ML:=mbo_ml.oid;
                      xsite.RefreshData;
                 finally
                    mbo_ml.free;
                 end;
            end;
      {              if index=15 then begin  //mMAction1.Items.Add('Typ platby');
               if nxstrtoint(mbo.GetFieldValueAsstring('ServiceDocument_ID.ServiceDocState_ID.posindex'))<20 then begin
                          mstate:=iGetPayment_ID(xSite);
                              if mresult then begin
                                    mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set X_PaymenType_ID='+ quotedstr(mstate) + ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                              end;
                          mID_ML:=mbo.oid;
                    end;


            end;  }
   // *******
            if index =15 then begin     // posunutí termínu servisu
               mBO_ML:=xSite.BaseObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                   try
                      mBO_ML:= mbo;
                      if true then begin
                      //mi:=xsite.BaseObjectSpace.SQLExecute('update ServiceAssemblyForms2 set X_Konec_prace =' + QuotedStr('') + ' where parent.ID=' + quotedstr(mbo.oid));
                          if mposun<>0 then begin

                              mBO_ML.setFieldValueAsDateTime('StartDate$DATE',mBO_ML.getFieldValueAsDateTime('StartDate$DATE')+mposun);
                              mBO_ML.setFieldValueAsDateTime('EndDate$DATE',mBO_ML.getFieldValueAsDateTime('EndDate$DATE')+mposun);
                              mBO_ML.save;
                              mi:=xsite.BaseObjectSpace.SQLExecute('update ServiceAssemblyForms2 set X_konec_prace=' + NxFloatToIBStr(mBO_ML.getFieldValueAsDateTime('EndDate$DATE')) +
                                ' where parent_id='+quotedstr(mBO_ML.oid) );
                              mi:=xsite.BaseObjectSpace.SQLExecute('update CRMActivities set SheduledStart$Date=' + NxFloatToIBStr(mBO_ML.getFieldValueAsDateTime('StartDate$DATE'))+
                                ',SheduledEnd$Date=' + NxFloatToIBStr(mBO_ML.getFieldValueAsDateTime('EndDate$DATE'))+
                                ',RealStart$Date=' + NxFloatToIBStr(mBO_ML.getFieldValueAsDateTime('StartDate$DATE'))+
                                ',RealEnd$Date=' + NxFloatToIBStr(mBO_ML.getFieldValueAsDateTime('EndDate$DATE'))+
                               ' where X_parent_head='+quotedstr(mBO_ML.oid) );



                              //mBO_ML.save;
                         end;
                    end;
                  finally
                      mbo_ml.free;
                  end;
            end;

        end;
            if index=4 then begin
                smresult:=CNExecuteItem(mBO_ML,xSite,mRows_ml,mIDs_MLRow);
                if smresult='' then begin
                      NxShowSimpleMessage('Při cenové nabídce došlo k chybě:',nil);
                end else begin
                      mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_State=' + quotedstr('4XQ1000101') + ', AssemblyState=1 where id=' + QuotedStr(mBO_ML.oid));
                      mi:=xsite.BaseObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' +QuotedStr('9000000101')+ ' where id=' +quotedstr(mBO_ML.GetFieldValueAsstring('ServiceDocument_ID'))) ;
                end;
            end;

            mi:=xsite.BaseObjectSpace.SQLExecute('update SERVICEASSEMBLYFORMS2 SA2 set Sa2.x_koeficient=100/(select count(id) from SERVICEASSEMBLYFORMS2 where parent_id=sa2.parent_ID and (itemtype=4 and text='+quotedstr('Práce - evidenční pro mzdy') + '))  where (sa2.itemtype=4) and (select count(id) from SERVICEASSEMBLYFORMS2 where itemtype=4 and parent_id=sa2.parent_ID and text='+quotedstr('Práce - evidenční pro mzdy') + ')<>0 and Sa2.parent_ID='
            +quotedstr(mID_ML))

    end;

    if index=0 then mIDs_WorkerRole.free;
    mIDs_MLRow.free;
   if mBookmark.count=0 then begin
      //mdbgrid.Refresh;
      //xsite.RefreshData;
      //xsite.ActiveDataSet.RefreshAndRestoreLastSelectedItem;
      //xsite.ActiveDataSet.seekid(mID_ML);
      TDynSiteForm(xsite).ActiveDataSet.RefreshCurrentItem;
   end else begin
         mI_Result:=Mformx(xsite,'Upozornění.','Je označeno více záznamů!', 'Ponechat výběr','','','Zrušit výběr');
                 if (mI_Result=1)  then begin
                      for mI_ML := 0 to mBookmark.Count- 1 do begin
                          mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(mI_ML));
                          mBO:= TDynSiteForm(xSite).CurrentObject;
                          //xsite.ActiveDataSet.SeekID(mbo.OID);
                          //mdbgrid.SelectRows_1(mbo.oid);
                      end;
                 end;
                 if (mI_Result=5) then begin
                        TDynSiteForm(xsite).ActiveDataSet.RefreshCurrentItem;
                        //mdbgrid.Refresh;
                        //xsite.RefreshData;
                        //xsite.ActiveDataSet.RefreshAndRestoreLastSelectedItem;
                        //xsite.ActiveDataSet.seekid(mID_ML);
                 end;
   end;






 end;


 function NXCHANGEDOCQueue(mBO_SL:TNxCustomBusinessObject;xsite: TDynSiteForm):boolean;
var
  mID,mID_SO:string;
  mr,mIDs_DQ:tstringlist;
  i, mPosIndex: integer;
  mList: TStringList;
  mText: string;
  mParams : TNxParameters;
  mNumber,mNumberOriginal:string;
  mLastNumber:integer;
  mi:integer;
  mprefix:string;
  mXX : string;
  mOLE_DQ, mRoll_DQ, mOResult_DQ: Variant;
begin
  mNumberOriginal:=mBO_SL.GetFieldValueAsString('Docqueue_ID.CODE') + '-' + inttostr(mBO_SL.GetFieldValueAsInteger('Ordnumber')) +'/'+mBO_SL.GetFieldValueAsString('Period_ID.CODE') ;
      mOLE_DQ:= GetAbraOLEApplication;
                  mOResult_DQ:= mOLE_DQ.CreateStrings;
                  mRoll_DQ:= mOLE_DQ.GetRoll('W2XNBCJK3ZD13ACL03KIU0CLP4', 0);   // sp
                                    mRoll_DQ.Params.Add('FilterDocumentType=SL') ;
                                    if not mRoll_DQ.MultiSelectDialog(True, mOResult_DQ) then Exit;
                                    mIDs_DQ:= TStringList.Create;
                                    try
                                    mIDs_DQ.Text:= mOResult_DQ.Text;
                                    mID_SO:= mIDs_DQ.Strings[0];
                                    finally
                                       mIDs_DQ.Free;
                                    end;

      //mXX := '0000000000';
     // mRollDQ := AOLE.GetRoll('W2XNBCJK3ZD13ACL03KIU0CLP4', 0);
     // mRollDQ.Params.Add('FilterDocumentType=SL');
    //  ResultDQ := mRollDQ.SelectDialog2(true, mXX);

           mNumberOriginal:=mBO_SL.GetFieldValueAsString('Docqueue_ID.CODE') + '-' + inttostr(mBO_SL.GetFieldValueAsInteger('Ordnumber')) +'/'+mBO_SL.GetFieldValueAsString('Period_ID.CODE') ;
          //  mr:=tstringlist.create;
          //       try
          //       mBO_SL.ObjectSpace.SQLSelect('Select max(lastnumber) from DocQueues2 where period_ID=' + QuotedStr(mBO_SL.GetFieldValueAsString('Period_ID')) + ' and DocQueue_ID=' + QuotedStr(mID_SO),mr);
          //          if mr.count>0 then begin
          //             i:=strtoint(mr.Strings[0])+5 ;
          //             end else begin
          //             i:=1;
          //          end;
          //      finally
          //          mr.free;
          //      end;
          //      mi:=mBO_SL.ObjectSpace.SQLExecute('update DocQueues2 set LastNumber=' + inttostr(i) + ' where period_ID=' + QuotedStr(mBO_SL.GetFieldValueAsString('Period_ID')) + ' and DocQueue_ID=' + QuotedStr(mID_SO));
          //      mi:=mBO_SL.ObjectSpace.SQLExecute('Update ServiceDocuments set Docqueue_ID=' + quotedstr(mID_SO) + ',ordnumber=' + inttostr(i) + ' where id=' +quotedstr(mBO_SL.OID)) ;

                mBO_SL.Refresh;
                mBO_SL.SetFieldValueAsInteger('Ordnumber',0) ;
                mBO_SL.SetFieldValueAsstrinG('DocQueue_ID',mID_SO) ;

                mprefix:='';
                if mBO_SL.GetFieldValueAsString('Docqueue_ID')='1A20000101' then mprefix:='S';
                if mBO_SL.GetFieldValueAsString('Docqueue_ID')='5B20000101' then mprefix:='S';
                if mBO_SL.GetFieldValueAsString('Docqueue_ID')='4B20000101' then mprefix:='P';
                if mBO_SL.GetFieldValueAsString('Docqueue_ID')='6B20000101' then mprefix:='P';
                if mBO_SL.GetFieldValueAsString('Docqueue_ID')='7B20000101' then mprefix:='B';
                if mBO_SL.GetFieldValueAsString('Docqueue_ID')='8B20000101' then mprefix:='B';
                if mBO_SL.GetFieldValueAsString('Docqueue_ID')='9B20000101' then mprefix:='F';
                if mBO_SL.GetFieldValueAsString('Docqueue_ID')='AB20000101' then mprefix:='F';
          //      mi:=mBO_SL.ObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_Protokol_prefix=' + quotedstr(mprefix) + ' where ServiceDocument_ID=' +quotedstr(mBO_SL.OID)) ;


          mbo_sl.save;
          mNumber:=mBO_SL.GetFieldValueAsString('Docqueue_ID.CODE') + '-' + inttostr(mBO_SL.GetFieldValueAsInteger('Ordnumber')) +'/'+mBO_SL.GetFieldValueAsString('Period_ID.CODE') ;
        NxShowSimpleMessage('Proběhla změna dokladu z ' + mNumberOriginal + ' na ' + mNumber,nil);
end;



procedure NXCHANGESP(Sender: TComponent;index:integer);
var mSite : TSiteForm;
  mBO_source : TNxCustomBusinessObject;
  mID,mID_SO:string;
  mr:Tstringlist;
  i, mPosIndex: integer;
  mList: TStringList;
  mText: string;
  result:string;
mParams : TNxParameters;
mSP,mSPOriginal:string;
mSP_project,mSP_ProjectOriginal:string;
mLastNumber:integer;
 mi:integer;
begin
    mSite := NxFindSiteForm(Sender);

                 mOLE_SP:= GetAbraOLEApplication;
                  mOResult_SP:= mOLE_SP.CreateStrings;
                  mRoll_SP:= mOLE_SP.GetRoll('5315B3YAPMNOB0FIRUCLXSJ52O', 0);   // sp
                                    if not mRoll_SP.MultiSelectDialog(True, mOResult_SP) then Exit;
                                    mIDs_SP:= TStringList.Create;
                                    try
                                        mIDs_SP.Text:= mOResult_SP.Text;


                                          mID_SO := mIDs_SP.Strings[0];
                                    finally
                                       mIDs_SP.free;
                                    end;

      try


          mBO_source:=TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject;

              mSPOriginal:=mBO_source.GetFieldValueAsString('servicedocument_ID.ServicedObject_ID');

              mSP_ProjectOriginal:=mBO_source.GetFieldValueAsString('servicedocument_ID.ServicedObject_ID.BusProject_ID');

         mi:=mBO_source.ObjectSpace.SQLExecute('Update ServiceDocuments set ServicedObject_ID=' + quotedstr(mID_SO)+ ' where id=' +quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID'))) ;
         mBO_source:=TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject;
         mi:=mBO_source.ObjectSpace.SQLExecute('Update ServiceDocuments set ServicedObjectIDCode=' + quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID.ServicedObject_ID.code'))+ ' where id=' +quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID'))) ;
         mi:=mBO_source.ObjectSpace.SQLExecute('Update ServiceDocuments set ServicedObjectText=' + quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID.ServicedObject_ID.Name'))+ ' where id=' +quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID'))) ;
         mi:=mBO_source.ObjectSpace.SQLExecute('Update ServiceDocuments set OutdoorPlaceDescription=' + quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID.ServicedObject_ID.OutdoorPlaceDescription'))+ ' where id=' +quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID'))) ;
       if not nxisemptyoid(mBO_source.GetFieldValueAsString('servicedocument_ID.ServicedObject_ID.Firm_ID')) then mi:=mBO_source.ObjectSpace.SQLExecute('Update ServiceDocuments set Firm_ID=' + quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID.ServicedObject_ID.Firm_ID'))+ ' where id=' +quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID'))) ;
       if not nxisemptyoid(mBO_source.GetFieldValueAsString('servicedocument_ID.ServicedObject_ID.FirmOffice_ID')) then mi:=mBO_source.ObjectSpace.SQLExecute('Update ServiceDocuments set FirmOffice_ID=' + quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID.ServicedObject_ID.FirmOffice_ID'))+ ' where id=' +quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID'))) ;
       if not nxisemptyoid(mBO_source.GetFieldValueAsString('servicedocument_ID.ServicedObject_ID.Person_ID')) then mi:=mBO_source.ObjectSpace.SQLExecute('Update ServiceDocuments set Person_ID=' + quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID.ServicedObject_ID.Person_ID'))+ ' where id=' +quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID'))) ;
       //if nxisemptyoid() then mi:=mBO_source.ObjectSpace.SQLExecute('Update ServiceDocuments set PayerFirm_ID=' + quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID.ServicedObject_ID.PayerFirm_ID'))+ ' where id=' +quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID'))) ;
       //if nxisemptyoid() then mi:=mBO_source.ObjectSpace.SQLExecute('Update ServiceDocuments set PayerFirmOffice_ID=' + quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID.ServicedObject_ID.PayerFirmOffice_ID'))+ ' where id=' +quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID'))) ;
       //if nxisemptyoid() then mi:=mBO_source.ObjectSpace.SQLExecute('Update ServiceDocuments set PayerPerson_ID=' + quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID.ServicedObject_ID.PayerPerson_ID'))+ ' where id=' +quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID'))) ;
       //if nxisemptyoid() then mi:=mBO_source.ObjectSpace.SQLExecute('Update ServiceDocuments set X_id_zakaznika_id=' + quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID.ServicedObject_ID.X_id_zakaznika_id'))+ ' where id=' +quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID'))) ;
       //if nxisemptyoid() then mi:=mBO_source.ObjectSpace.SQLExecute('Update ServiceDocuments set BusProject_ID=' + quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID.ServicedObject_ID.BusProject_ID'))+ ' where id=' +quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID'))) ;
       //if nxisemptyoid() then mi:=mBO_source.ObjectSpace.SQLExecute('Update ServiceDocuments set BusTransaction_ID=' + quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID.ServicedObject_ID.BusTransaction_ID'))+ ' where id=' +quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID'))) ;
       //if nxisemptyoid() then mi:=mBO_source.ObjectSpace.SQLExecute('Update ServiceDocuments set BusOrder_ID=' + quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID.ServicedObject_ID.BusOrder_ID'))+ ' where id=' +quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID'))) ;

       mBO_source:=TDynSiteForm(NxFindSiteForm(Sender)).CurrentObject;
       mi:=mBO_source.ObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_ServicedObject_ID=' + quotedstr(mID_SO)+ ' where ServiceDocument_ID=' +quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID'))) ;
       mi:=mBO_source.ObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_id_zakaznika_id=' + quotedstr(mBO_source.GetFieldValueAsString('X_id_zakaznika_id'))+ ' where ServiceDocument_ID=' +quotedstr(mBO_source.GetFieldValueAsString('servicedocument_ID'))) ;





             if mBO_source.getFieldValueAsString('servicedocument_ID.BusOrder_ID')<>mSP_ProjectOriginal then begin
                 NxShowSimpleMessage('Nové zařízení není pod stejnou smlouvu, prosím zkontrolujte ceny a proveďte občerstvení.',msite);
              end;
      finally

      end;

end;


 {

                                                            try
          mID_SO_SL:=mOResult_SP;
          mID_SO:=mID_SO_SL.Strings[0];
              mSPOriginal:=mBO_SL.GetFieldValueAsString('ServicedObject_ID');
              mSP_ProjectOriginal:=mBO_SL.GetFieldValueAsString('ServicedObject_ID.BusProject_ID');
              mi:=mBO_SL.ObjectSpace.SQLExecute('Update ServiceDocuments set ServicedObject_ID=' + quotedstr(mID_SO)+ ' where id=' +quotedstr(mBO_SL.OID)) ;
              mi:=mBO_SL.ObjectSpace.SQLExecute('Update ServiceDocuments set ServicedObjectIDCode=' + quotedstr(mBO_SL.GetFieldValueAsString('ServicedObject_ID.code'))+ ' where id=' +quotedstr(mBO_SL.OID)) ;
              mi:=mBO_SL.ObjectSpace.SQLExecute('Update ServiceDocuments set ServicedObjectText=' + quotedstr(mBO_SL.GetFieldValueAsString('ServicedObject_ID.Name'))+ ' where id=' +quotedstr(mBO_SL.OID)) ;
              mi:=mBO_SL.ObjectSpace.SQLExecute('Update ServiceDocuments set OutdoorPlaceDescription=' + quotedstr(mBO_SL.GetFieldValueAsString('ServicedObject_ID.OutdoorPlaceDescription'))+ ' where id=' +quotedstr(MBO_SL.OID)) ;
              //if not NxIsEmptyOID(mBO_SL.GetFieldValueAsString('ServicedObject_ID.Firm_ID')) then
              mi:=MBO_SL.ObjectSpace.SQLExecute('Update ServiceDocuments set Firm_ID=' + quotedstr(MBO_SL.GetFieldValueAsString('ServicedObject_ID.Firm_ID'))+ ' where id=' +quotedstr(MBO_SL.OID)) ;
              //if not NxIsEmptyOID(mBO_SL.GetFieldValueAsString('ServicedObject_ID.FirmOffice_ID')) then
              mi:=MBO_SL.ObjectSpace.SQLExecute('Update ServiceDocuments set FirmOffice_ID=' + quotedstr(MBO_SL.GetFieldValueAsString('ServicedObject_ID.FirmOffice_ID'))+ ' where id=' +quotedstr(MBO_SL.OID)) ;
              //if not NxIsEmptyOID(mBO_SL.GetFieldValueAsString('ServicedObject_ID.Person_ID')) then
              mi:=MBO_SL.ObjectSpace.SQLExecute('Update ServiceDocuments set Person_ID=' + quotedstr(MBO_SL.GetFieldValueAsString('ServicedObject_ID.Person_ID'))+ ' where id=' +quotedstr(MBO_SL.OID)) ;
              //if not NxIsEmptyOID(mBO_SL.GetFieldValueAsString('ServicedObject_ID.PayerFirm_ID')) then
              mi:=MBO_SL.ObjectSpace.SQLExecute('Update ServiceDocuments set PayerFirm_ID=' + quotedstr(MBO_SL.GetFieldValueAsString('ServicedObject_ID.PayerFirm_ID'))+ ' where id=' +quotedstr(MBO_SL.OID)) ;
              //if not NxIsEmptyOID(mBO_SL.GetFieldValueAsString('ServicedObject_ID.PayerFirmOffice_ID')) then
              mi:=MBO_SL.ObjectSpace.SQLExecute('Update ServiceDocuments set PayerFirmOffice_ID=' + quotedstr(MBO_SL.GetFieldValueAsString('ServicedObject_ID.PayerFirmOffice_ID'))+ ' where id=' +quotedstr(MBO_SL.OID)) ;
              //if not NxIsEmptyOID(mBO_SL.GetFieldValueAsString('ServicedObject_ID.PayerPerson_ID')) then
              mi:=MBO_SL.ObjectSpace.SQLExecute('Update ServiceDocuments set PayerPerson_ID=' + quotedstr(MBO_SL.GetFieldValueAsString('ServicedObject_ID.PayerPerson_ID'))+ ' where id=' +quotedstr(MBO_SL.OID)) ;
              //if not NxIsEmptyOID(mBO_SL.GetFieldValueAsString('ServicedObject_ID.X_id_zakaznika_id')) then
              mi:=MBO_SL.ObjectSpace.SQLExecute('Update ServiceDocuments set X_id_zakaznika_id=' + quotedstr(MBO_SL.GetFieldValueAsString('ServicedObject_ID.X_id_zakaznika_id'))+ ' where id=' +quotedstr(MBO_SL.OID)) ;
              //if not NxIsEmptyOID(mBO_SL.GetFieldValueAsString('ServicedObject_ID.BusProject_ID')) then
              mi:=MBO_SL.ObjectSpace.SQLExecute('Update ServiceDocuments set BusProject_ID=' + quotedstr(MBO_SL.GetFieldValueAsString('ServicedObject_ID.BusProject_ID'))+ ' where id=' +quotedstr(MBO_SL.OID)) ;
              //if not NxIsEmptyOID(mBO_SL.GetFieldValueAsString('ServicedObject_ID.BusTransaction_ID')) then
              mi:=MBO_SL.ObjectSpace.SQLExecute('Update ServiceDocuments set BusTransaction_ID=' + quotedstr(MBO_SL.GetFieldValueAsString('ServicedObject_ID.BusTransaction_ID'))+ ' where id=' +quotedstr(MBO_SL.OID)) ;
              //if not NxIsEmptyOID(mBO_SL.GetFieldValueAsString('ServicedObject_ID.BusOrder_ID')) then
              mi:=MBO_SL.ObjectSpace.SQLExecute('Update ServiceDocuments set BusOrder_ID=' + quotedstr(MBO_SL.GetFieldValueAsString('ServicedObject_ID.BusOrder_ID'))+ ' where id=' +quotedstr(MBO_SL.OID)) ;

              mi:=mBO_SL.ObjectSpace.SQLExecute('Update ServiceAssemblyForms set X_ServicedObject_ID=' + quotedstr(mID_SO)+ ' where ServiceDocument_ID=' +quotedstr(mBO_SL.OID)) ;
           MBO_SL.save;
      finally
          mIDs_SP.free;
      end;

end;
             }



begin
end.