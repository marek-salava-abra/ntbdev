Var
    mSite: TSiteForm;
    mDBGrid : TDBGrid;
    mTabList: TTabSheet;
    mCustomBusinessObject: TNxCustomBusinessObject;

    mHeaderBusinessObject : TNxHeaderBusinessObject;
    i : integer;
    mResult:Boolean;
    mBookmarkList:TBookmarkList ;
    aid:string;

function GetDate(Sender: TComponent;xSite:TSiteForm;mtitle:string;mlabel:string) : Date;
var
  mForm : TForm;
  mBtn : TButton;
  mlb2 : TLabel;
  mEdtSrc:TDateEdit;
begin
        try
              mForm := TForm.Create(xSite);            // formulář
                mForm.BorderIcons := [biSystemMenu];
                mForm.Width := 240;  // sirka
                mForm.Height := 100; // vyska
                mForm.Caption := mtitle;
                    mLb2 := TLabel.Create(mForm);         // položka řada
                    mLb2.Caption := mlabel;
                    mLb2.Left := 30;
                    mLb2.Top := 10;
                    mLb2.Name := 'lblDocQueues';
                    mForm.InsertControl(mLb2);
                        mEdtSrc := TDateEdit.Create(mForm);
                        mEdtSrc.Left := 100;
                        mEdtSrc.Top := 10;
                        mEdtSrc.Width := 100;
                        mEdtSrc.Name := 'edtDate';
                        mEdtSrc.Date:= date;
                        mForm.InsertControl(mEdtSrc);
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
                result:=mEdtSrc.Date;
           end;
        finally;
          mForm.Free;
        end;
end;

procedure OnExec(Sender: TComponent;index:integer;);       // přidělení objectspace a zadání zdrojového souboru
var
mr,mrFV:tstringlist;
mdateDLod,mdateDLdo,mdateFV:TDateTime;
mMon:TNxCustomBusinessMonikerCollection;
mNewRow,msource_DL,msource_FV:TNxCustomBusinessObject;
mBusOrder_id,mOldBusorder_id:string;
mDLValue,mFVvalue,mDLQuantity,mFVQuantity,mSUMDLValue:double;
begin
        mSite := NxFindSiteForm(Sender);
        mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
        if mTabList = nil then RaiseException('tabList nenalezen');
        mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
        if mDBGrid = nil then RaiseException('DBGrid nenalezen');

        mCustomBusinessObject:= TDynSiteForm(msite).CurrentObject;
        mdateDLod:=int(GetDate(Sender,mSite,'Zadej datum', 'Dl od'));
        mdateDLdo:=int(GetDate(Sender,mSite,'Zadej datum', 'Dl do'));
        mdateFV:=int(GetDate(Sender,mSite,'Zadej rozhodné datum ', 'Faktury do '));
        try

        mFVvalue:=0;
        mDLValue:=0;
        mCustomBusinessObject.New;
        mCustomBusinessObject.Prefill;
        mCustomBusinessObject.SetFieldValueAsString('DocQueue_ID','2400000101');
        mCustomBusinessObject.SetFieldValueAsDateTime('docdate$date',mdateFV);
        mCustomBusinessObject.SetFieldValueAsString('Firm_ID','AG21000101');
        mCustomBusinessObject.SetFieldValueAsString('Description','NV k datu :' + FormatDateTime('dd.MM.YYYY',mdateFV) );



        mMon := mCustomBusinessObject.GetLoadedCollectionMonikerForFieldCode(mCustomBusinessObject.GetFieldCode('ROWS'));

        mr:=TStringList.create;
        try
             msite.BaseObjectSpace.SQLSelect('SELECT A.ID||A.BusOrder_ID FROM StoreDocuments2 A JOIN StoreDocuments SD ON SD.ID=A.Parent_ID LEFT JOIN DocQueues DQ ON DQ.ID=SD.DocQueue_ID ' +
                    ' WHERE A.RowType=3 AND (SD.DocumentType = ''21'') AND (SD.DocQueue_ID IN (''2R00000101'',''P100000101'') ) AND (SD.DocDate$DATE >= ' + NxFloatToIBStr(mdateDLod) + ' and SD.DocDate$DATE < ' + NxFloatToIBStr(mdateDLdo) + ' ) AND ' +
                    ' (NOT (sd.ID=''B943000101'' OR ((sd.Firm_ID IS NOT NULL) AND (sd.Firm_ID=''B943000101'')))) AND (NOT (A.Division_ID in (''D000000101'',''1I00000101''))) order by a.BusOrder_ID',mr);
                    if mr.count>0 then begin

                         for i:=0 to mr.count-1 do begin
                               msource_DL:=mSite.BaseObjectSpace.CreateObject('0H0I5SAOS3DL3ACU03KIU0CLP4');
                                    try
                                         msource_DL.load(copy(mr.Strings[i],1,10),nil);

                                        if i<>mr.count-1 then begin  // preb2h



                                                        mDLQuantity:=mDLQuantity+(msource_DL.GetFieldValueAsFloat('Quantity')/msource_DL.GetFieldValueAsFloat('UnitRate'));
                                                        mDLValue:=msource_DL.GetFieldValueAsFloat('TAmount')/mDLQuantity;

                                                                mrfv:=TStringList.create;
                                                                try
                                                                      msite.BaseObjectSpace.SQLSelect('SELECT sum(a.Quantity/a.unitrate) FROM IssuedInvoices2 A left join IssuedInvoices II on ii.id=a.parent_ID WHERE A.ProvideRow_ID=' + QuotedStr(copy(mr.Strings[i],1,10)) + ' and ii.docdate$date<=' + NxFloatToIBStr(mdateFV) ,mrfv);
                                                                      if mrfv.Count>0 then begin
                                                                             mFVQuantity:=NxIBStrToFloat(mrfv.Strings[0]);

                                                                      end

                                                                finally
                                                                     mrfv.free;
                                                                end;
                                              if mDLQuantity<>mFVQuantity then mSUMDLValue:=mSUMDLValue + ((mDLQuantity-mFVQuantity)* mDLValue);

                                              if (copy(mr.Strings[i],11,10)<>copy(mr.Strings[i+1],11,10)) and (mSUMDLValue<>0) then begin //zápis
                                                         if mSUMDLValue>20000 then begin
                                                                  mNewRow := mMon.AddNewObject;
                                                                  mNewRow.SetFieldValueAsString('CreditAccount_ID', '3B40000101');
                                                                  mNewRow.SetFieldValueAsString('DebitAccount_ID', '4300000101');
                                                                  mNewRow.SetFieldValueAsFloat('TAmount', mSUMDLValue);
                                                                  mNewRow.SetFieldValueAsFloat('LocalTAmount', mSUMDLValue);

                                                                  mNewRow.SetFieldValueAsString('Text', 'Přírůstek NV k ' + msource_DL.GetFieldValueAsString('parent_ID.Docqueue_ID.Code') + ' - ' + inttostr(msource_DL.GetFieldValueAsinteger('parent_id.ordnumber')) + '/' +
                                                                    msource_DL.GetFieldValueAsString('parent_id.Period_ID.Code') );

                                                                  mNewRow.SetFieldValueAsString('DebitBusOrder_ID', copy(mr.Strings[i],11,10));
                                                                  mNewRow.SetFieldValueAsString('DebitBusProject_ID', msource_DL.GetFieldValueAsString('BusProject_ID'));
                                                                  mNewRow.SetFieldValueAsString('DebitBusTransaction_ID', msource_DL.GetFieldValueAsString('BusTransaction_ID'));
                                                                  mNewRow.SetFieldValueAsString('DebitDivision_ID', '2000000101');

                                                                  mNewRow.SetFieldValueAsString('CreditBusOrder_ID', copy(mr.Strings[i],11,10));
                                                                  mNewRow.SetFieldValueAsString('CreditBusProject_ID', msource_DL.GetFieldValueAsString('BusProject_ID'));
                                                                  mNewRow.SetFieldValueAsString('CreditBusTransaction_ID', msource_DL.GetFieldValueAsString('BusTransaction_ID'));
                                                                  mNewRow.SetFieldValueAsString('CreditDivision_ID', '2000000101');

                                                         end;
                                                                  mDLValue:=0;
                                                                  mDLQuantity:=0;
                                                                  mFVValue:=0;
                                                                  mFVQuantity:=0;
                                                                  mSUMDLValue:=0;


                                               end;


                             end else begin    // poslední y8ynam
                                      if mSUMDLValue>20000 then begin

                                        mNewRow := mMon.AddNewObject;
                                                                  mNewRow.SetFieldValueAsString('CreditAccount_ID', '3B40000101');
                                                                  mNewRow.SetFieldValueAsString('DebitAccount_ID', '4300000101');
                                                                  mNewRow.SetFieldValueAsFloat('TAmount', mSUMDLValue);
                                                                  mNewRow.SetFieldValueAsFloat('LocalTAmount', mSUMDLValue);

                                                                  mNewRow.SetFieldValueAsString('Text', 'Přírůstek NV k ' + msource_DL.GetFieldValueAsString('parent_ID.Docqueue_ID.Code') + ' - ' + inttostr(msource_DL.GetFieldValueAsinteger('parent_id.ordnumber')) + '/' +
                                                                    msource_DL.GetFieldValueAsString('parent_id.Period_ID.Code') );

                                                                  mNewRow.SetFieldValueAsString('DebitBusOrder_ID', copy(mr.Strings[i],11,10));
                                                                mNewRow.SetFieldValueAsString('DebitBusProject_ID', msource_DL.GetFieldValueAsString('BusProject_ID'));
                                                                  mNewRow.SetFieldValueAsString('DebitBusTransaction_ID', msource_DL.GetFieldValueAsString('BusTransaction_ID'));
                                                                   mNewRow.SetFieldValueAsString('DebitDivision_ID', '2000000101');

                                                                  mNewRow.SetFieldValueAsString('CreditBusOrder_ID', copy(mr.Strings[i],11,10));
                                                              mNewRow.SetFieldValueAsString('CreditBusProject_ID', msource_DL.GetFieldValueAsString('BusProject_ID'));
                                                                  mNewRow.SetFieldValueAsString('CreditBusTransaction_ID', msource_DL.GetFieldValueAsString('BusTransaction_ID'));
                                                                        mNewRow.SetFieldValueAsString('CreditDivision_ID', '2000000101');


                                  end;
                                                                  mDLValue:=0;
                                                                  mDLQuantity:=0;
                                                                  mFVValue:=0;
                                                                  mFVQuantity:=0;
                                                                  mSUMDLValue:=0;
                             end;

                             finally
                                        msource_DL.free;
                                    end;
                         end;










                 end;

        finally
           mr.free;
        end;


                            mCustomBusinessObject.save;
        finally
               mCustomBusinessObject.free;
        end;
        mDBGrid.Refresh;
        mDBGrid.DataSource.DataSet.Refresh;
end;




procedure InitSite_Hook(Self: TSiteForm);
var
  mAction: TBasicAction;
  mMAction: TMultiAction;
  mCAction: TBasicAction;
  mAList: TActionList;
  i : integer;
  mUserFilter:Boolean;
  mUserFilterTL:string;
  muser:TNxCustomBusinessObject;
begin
   mUserFilter:=true;
    mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');
    try
      mUser.Load(Self.CompanyCache.GetUserID, nil);
            mUserFilter:= true; //mUser.GetFieldValueAsBoolean('X_archiv');



          mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Vytvoření nedokončené výroby';
          mMAction.Caption := 'Přírůstek nedokončené výroby';
          mMAction.Items.Add('Přírůstek nedokončené výroby');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec;


     finally
      mUser.Free;
     end;

end;



begin
end.