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


  function GetCheck(Sender: TComponent;xSite:TSiteForm;mLabel:string;mLabelOK:string;mLabelStorno:string) : Boolean;
var
  mForm : TForm;
  mBtn : TButton;
  mlb2 : TLabel;
  mEdtSrc:TDateEdit;
begin
        try
              mForm := TForm.Create(xSite);            // formulář
                mForm.BorderIcons := [biSystemMenu];
                mForm.Width := 200;  // sirka
                mForm.Height := 100; // vyska
                mForm.Caption := mlabel;
                  mBtn := TButton.Create(mForm);            // tlačítko OK
                        mBtn.Width := 80;
                        mBtn.Height := 25;
                        mBtn.Caption := mLabelOK;
                        mBtn.ModalResult := mrOk;
                        mBtn.Cancel := False;
                        mBtn.Default := True;
                        mBtn.Left :=  mForm.Width - 2*(mBtn.Width+2) - 20;
                        mBtn.Top := mForm.Height - mBtn.Height - 40;
                        mBtn.Name := 'btnOK';
                        mForm.InsertControl(mBtn);
                    mBtn := TButton.Create(mForm);          // tlačítko storno
                        mBtn.Width := 80;
                        mBtn.Height := 25;
                        mBtn.Caption := mLabelStorno;
                        mBtn.ModalResult := mrCancel;
                        mBtn.Cancel := True;
                        mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;;
                        mBtn.Top := mForm.Height - mBtn.Height - 40;
                        mBtn.Name := 'btnCancel';
                        mForm.InsertControl(mBtn);

           if mForm.ShowModal(xSite) = mrOK then begin
                result:=true;
           end else begin
                result:=false;
           end;
        finally;
          mForm.Free;
        end;
end;





    procedure FVExecuteItemwithnull(Sender: TAction; Index: integer);
var
 mresult:Boolean;
 mtext:string;
 mbo:TNxCustomBusinessObject;
 mSite: TSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 self:TNxCustomBusinessObject;
 i,ii:integer;
  mr,mIDs_MLRow:TStringList;
   mForm: TDynSiteForm;
   mMon: TNxCustomBusinessMonikerCollection;
   mRow, mNewRow,mbo1: TNxCustomBusinessObject;
   mdate:Double;
begin
  mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    try
      mIDs_MLRow:=TStringList.create;
          try
                  if mBookmark.count=0 then begin                 // pro aktuální záznam
                     mBO1 := TDynSiteForm(mSite).CurrentObject;

                       if mbo1.GetFieldValueAsInteger('GuarantyRepair')<>2 then begin
                         mr:=TStringList.create;
                          if ((mbo1.getFieldValueAsstring('ServiceDocState_ID')='9300000101') or (mbo1.getFieldValueAsstring('ServiceDocState_ID')='D102000000')) then begin

                         try
                                mbo1.ObjectSpace.SQLSelect('select SA2.id from ServiceAssemblyForms2 SA2 left join ServiceAssemblyForms sa on SA.ID=sa2.Parent_ID where sa2.ToInvoiceType=0 and sa2.IsInvoiced=0 and sa.AssemblyState=3 and sa.ServiceDocument_ID=' + quotedstr(mbo1.OID)
                                + ' And ((SA.X_State=' + quotedstr('6XQ1000101') + ') or (SA.X_State=' + quotedstr('AXQ1000101') + ') or (SA.X_State=' + quotedstr('3JS1000101')+'))',mr);
                                for ii := 0 to mr.Count-1 do begin // projdu vsechny oznacene zaznamy
                                     mIDs_MLRow.Add(mr.Strings[ii]);
                                end;
                         finally
                             mr.free;
                         end;

                         end else begin
                             NxShowSimpleMessage('Servisní list není ve fakturovatelném stavu',nil);
                         end;
                        end else begin
                                        mbo1.setFieldValueAsstring('ServiceDocState_ID','9100000101');
                                        mbo1.save;
                        end;
                  end else begin
                          for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy           // pro ozbačené záznamy
                                  mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));

                                  mBO1 := TDynSiteForm(mSite).CurrentObject;
                                  try
                                    if ( (mbo1.getFieldValueAsstring('ServiceDocState_ID')='D102000000')) then begin

                                        if mbo1.GetFieldValueAsInteger('GuarantyRepair')<>2 then begin
                                          mr:=TStringList.create;
                                          try

                                              mbo1.ObjectSpace.SQLSelect('select SA2.id from ServiceAssemblyForms2 SA2 left join ServiceAssemblyForms sa on SA.ID=sa2.Parent_ID where sa2.ToInvoiceType=0 and sa2.IsInvoiced=0 and sa.ServiceDocument_ID=' + quotedstr(mbo1.OID),mr);
                                                for ii := 0 to mr.Count-1 do begin // plnění řádku dokladu
                                                     mIDs_MLRow.Add(mr.Strings[ii]);
                                                end;
                                          finally
                                             mr.free;
                                             //mbo1.free;
                                          end;
                                        end else begin
                                        mbo1.setFieldValueAsstring('ServiceDocState_ID','9100000101');
                                        mbo1.save;
                                      end;
                                    end else begin
                                        NxShowSimpleMessage('Servisní list není ve fakturovatelném stavu',nil);
                                    end;
                                  finally
                                         mbo1.free;
                                  end;
                          end;
                  end;
              finally

              end;

          if mIDs_MLRow.Count>0 then begin

          mtext:='Ano';
          mresult:=GetCheck(Sender,mSite,'Způsob fakturace','Přenesená ','Bez přenes.') ;

         // InputQuery('Jedna se o přenesenou danovou povinost','Pokud se jedná o přenesou povinost, klikni na tlačítko OK','',nil);
              mdate:=0;


                try
                mbo:= TDynSiteForm(mSite).CurrentObject.ObjectSpace.CreateObject('O3BDOKTWEFD13ACM03KIU0CLP4');
                mBO.New;
                mBO.Prefill;
                mBO.SetFieldValueAsString('Docqueue_ID', '8D00000101');
                //mHeaderBO.SetFieldValueAsString('Description', 'Reklamace_dokladu:');
                mBO.SetFieldValueAsString('Firm_ID', TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('PayerFirm_ID'));

                mBO.SetFieldValueAsString('Description',
                  TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_ID.Code') + '-'+
                  inttostr(TDynSiteForm(mSite).CurrentObject.GetFieldValueAsInteger('ordnumber')) +'/'+
                  TDynSiteForm(mSite).CurrentObject.GetFieldValueAsstring('Period_ID.Code')) ;



              if TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_ID.Code')='SL01' then mBustrasaction_ID:='D370000101';    // 47
              if TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_ID.Code')='SL02' then mBustrasaction_ID:='';
              if TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_ID.Code')='SL03' then mBustrasaction_ID:='';
              if TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_ID.Code')='SL04' then mBustrasaction_ID:='B370000101';    // 48
              if TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_ID.Code')='SL05' then mBustrasaction_ID:='C370000101';    // 46
              if TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_ID.Code')='SL06' then mBustrasaction_ID:='D370000101';    // 47
              if TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_ID.Code')='SL07' then mBustrasaction_ID:='3870000101';    // 51
              if TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_ID.Code')='SL08' then mBustrasaction_ID:='3870000101';    // 51
              if TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_ID.Code')='SL09' then mBustrasaction_ID:='C370000101';
              if TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_ID.Code')='SL10' then mBustrasaction_ID:='C370000101';
              if TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_ID.Code')='SL11' then mBustrasaction_ID:='3870000101';    // 51




                mBO.SetFieldValueAsString('FirmOffice_ID', TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('PayerFirmOffice_ID'));
                mBO.SetFieldValueAsString('Person_ID', TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('payerPerson_ID'));
                mBO.SetFieldValueAsString('PaymentType_ID', TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_PaymenType_ID'));
                mBO.SetFieldValueAsBoolean('IsRowDiscount',true);
                mBO.SetFieldValueAsBoolean('IsReverseChargeDeclared',mresult);

                              try
                              mMon := mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('ROWS'));

                                  mRow:= mbo.ObjectSpace.CreateObject('T3S00IN35IV4D0M3AQ0Y10CDFC');
                                  for i := 0 to mIDs_MLRow.Count-1 do begin
                                                try
                                                  mRow.Load(mIDs_MLRow.Strings[i],nil);
                                                  if mRow.GetFieldValueAsDateTime('X_konec_prace')>mdate then  mdate:=mRow.GetFieldValueAsDateTime('X_konec_prace');
                                                  //if mRow.GetFieldValueAsFloat('UnitPriceWithoutVAT')>0 then begin
                                                          mNewRow := mMon.AddNewObject;

                                                          mNewRow.SetFieldValueAsInteger('RowType', 2);
                                                          if mRow.GetFieldValueAsInteger('itemtype')=0 then begin
                                                             mNewRow.SetFieldValueAsString('Text',mRow.GetFieldValueAsString('Text'));
                                                             if Trim(mRow.GetFieldValueAsString('Text'))='' then mRow.GetFieldValueAsString('Storecard_ID.NAme');
                                                             mNewRow.SetFieldValueAsFLoat('Quantity', mRow.GetFieldValueAsFloat('WorkHoursReal'));
                                                             if (mRow.GetFieldValueAsstring('Text')= 'Paušál doprava') or (mRow.GetFieldValueAsstring('Text')= 'Doprava km') then
                                                                    mNewRow.SetFieldValueAsString('BusTransaction_ID','4870000101')
                                                              else begin
                                                                   mNewRow.SetFieldValueAsString('BusTransaction_ID',mBustrasaction_ID);
                                                              end;

                                                           end;


                                                           if mRow.GetFieldValueAsInteger('itemtype')=1 then begin
                                                                  mNewRow.SetFieldValueAsString('Text',mRow.GetFieldValueAsString('Storecard_ID.Code') + ' - ' +mRow.GetFieldValueAsString('Storecard_ID.Name'));
                                                                  mNewRow.SetFieldValueAsFLoat('Quantity', mRow.GetFieldValueAsFloat('Quantity'));
                                                              if NxIsEmptyOID(mRow.GetFieldValueAsString('Parent_ID.ServiceDocument_ID.ServicedObject_ID.BusTransaction_ID')) then begin
                                                                 mNewRow.SetFieldValueAsString('BusTransaction_ID','');
                                                              end else begin
                                                                 mNewRow.SetFieldValueAsString('BusTransaction_ID',mRow.GetFieldValueAsString('Parent_ID.ServiceDocument_ID.ServicedObject_ID.BusTransaction_ID'));
                                                              end;
                                                           end;

                                                           if mRow.GetFieldValueAsInteger('itemtype')>1 then begin
                                                              mNewRow.SetFieldValueAsString('BusTransaction_ID',mBustrasaction_ID);
                                                           end;

                                                          mNewRow.SetFieldValueAsString('QUnit', mRow.GetFieldValueAsString('QUnit'));
                                                          mNewRow.SetFieldValueAsString('VATRate_ID', mRow.GetFieldValueAsString('VATRate_ID'));

                                                          mNewRow.SetFieldValueAsFLoat('UnitPrice', mRow.GetFieldValueAsFloat('UnitPriceWithoutVAT'));
                                                          mNewRow.SetFieldValueAsFLoat('RowDiscount', mRow.GetFieldValueAsFloat('X_radkova_sleva'));
                                                          mNewRow.SetFieldValueAsString('Division_ID',mRow.GetFieldValueAsString('Parent_ID.ServiceDocument_ID.Division_ID'));
                                                          mNewRow.SetFieldValueAsString('BusOrder_ID',mRow.GetFieldValueAsString('Parent_ID.ServiceDocument_ID.BusOrder_ID'));

                                                          mNewRow.SetFieldValueAsString('X_parent_ID', mRow.GetFieldValueAsString('ID'));







                                                        if mRow.GetFieldValueAsInteger('itemtype')=2 then mNewRow.SetFieldValueAsString('Text',mRow.GetFieldValueAsString('Text'));


                                                        if mRow.GetFieldValueAsInteger('itemtype')=3 then begin
                                                            mNewRow.SetFieldValueAsString('Text',mRow.GetFieldValueAsString('Text'));
                                                            mNewRow.SetFieldValueAsFloat('Quantity',1);
                                                        end;

                                                        if mRow.GetFieldValueAsInteger('itemtype')=4 then begin
                                                            mNewRow.SetFieldValueAsString('Text',mRow.GetFieldValueAsString('Text'));
                                                            if mRow.GetFieldValueAsfloat('Quantity')>0 then begin
                                                                mNewRow.SetFieldValueAsfloat('Quantity',mRow.GetFieldValueAsfloat('Quantity'));
                                                            end else begin
                                                                mNewRow.SetFieldValueAsfloat('Quantity',1);
                                                            end;

                                                        end;
                                                          if mresult then begin
                                                              mNewRow.SetFieldValueAsInteger('VATMode',1);
                                                              mNewRow.SetFieldValueAsString('DRCArticle_ID', '1100000000');
                                                              mNewRow.SetFieldValueAsFloat('DRCQuantity', mRow.GetFieldValueAsFloat('Quantity'));
                                                          end;
                                                          mNewRow.free;
                                                  //end else begin
                                                  //end;
                                                  finally
                                                  end;
                                  end;

                                  if mdate=0 then mdate:=mrow.GetFieldValueAsDateTime('Parent_ID.EndDate$DATE');
                                             mBO.SetFieldValueAsDateTime('DocDate$DATE',mdate);
                                             mBO.SetFieldValueAsDateTime('VATDate$DATE',mdate);
                              finally
                                  mrow.free;

                              end;
                //    mMon.Free;

                  //NxScriptingLog.WriteEvent(logDebug, 'pred zavolanim TDynSiteForm.TDynSiteForm');

                 TDynSiteForm.ShowDynFormWithNewDocument('PLC2EX0BUJD13ACP03KIU0CLP4', TDynSiteForm(mSite).SiteContext, mBO);
                // NxScriptingLog.WriteEvent(logDebug, 'po zavolanim TDynSiteForm.TDynSiteForm');
              finally
              //  NxScriptingLog.WriteEvent(logDebug, 'uvolneni BO faktury');
              //NxShowSimpleMessage('uvolneni BO faktury', mSite);
                  mbo.Free;
              end;
           end;
        finally
         // NxScriptingLog.WriteEvent(logDebug, 'uvolneni TStringlist');
            mIDs_MLRow.free;
        end;


       // NxScriptingLog.WriteEvent(logDebug, 'pred TDynSiteForm.RefreshData');
        TDynSiteForm(mSite).RefreshData;
      //TDynSiteForm.RefreshData;
    //  NxScriptingLog.WriteEvent(logDebug, 'po TDynSiteForm.RefreshData');

end;






    procedure FVEditItem(Sender: TAction; Index: integer);
var
 mresult:Boolean;
 mtext:string;
 mImportMan:TNxDocumentImportManager;
 mbo:TNxCustomBusinessObject;
 mSite: TDynSiteForm;
  mDBGrid : TDBGrid;
    mTabList: TTabSheet;
  self:TNxCustomBusinessObject;
  i,ii:integer;
  mr,mIDs_MLRow:TStringList;
   mForm: TDynSiteForm;
   mMon: TNxCustomBusinessMonikerCollection;
   mRow, mNewRow,mbo1: TNxCustomBusinessObject;
   mdate:Double;
begin
    mSite := TComponent(Sender).DynSite;
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu

    try
            mBO1 := TDynSiteForm(mSite).CurrentObject;
            if mBookmark.count=0 then begin
                mbo1.SetFieldValueAsstring('ServiceDocState_ID','A102000000');
                mbo1.Save;
            end else begin
               for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
                        mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                        mBO1 := TDynSiteForm(mSite).CurrentObject;
                        mbo1.SetFieldValueAsstring('ServiceDocState_ID','A102000000');
                        mbo1.Save;
                end;
            end;
   finally
     mbo1.free;
   end;
 TDynSiteForm(mSite).RefreshData;
end;



      procedure FVExecuteItemlog(Sender: TAction; Index: integer);
var
 mresult:Boolean;
 mtext:string;
 mbo,mbo1:TNxCustomBusinessObject;
 mSite: TSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 self:TNxCustomBusinessObject;
 i,ii:integer;
  mr,mIDs_MLRow:TStringList;
   mForm: TDynSiteForm;
   mMon: TNxCustomBusinessMonikerCollection;
   mRow, mNewRow: TNxCustomBusinessObject;
   mdate:Double;
   mQuantity:double;
begin
  mBustrasaction_ID:='';
  mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    try
      mIDs_MLRow:=TStringList.create;
          try
                  if mBookmark.count=0 then begin                 // pro aktuální záznam
                     mBO1 := TDynSiteForm(mSite).CurrentObject;
                        if ((mbo1.getFieldValueAsstring('ServiceDocState_ID')='9200000101')) then begin

                               mr:=TStringList.create;
                               try
                                      mbo1.ObjectSpace.SQLSelect('select SA2.id from ServiceAssemblyForms2 SA2 left join ServiceAssemblyForms sa on SA.ID=sa2.Parent_ID where sa2.ToInvoiceType=0 and sa2.IsInvoiced=0 and sa.ServiceDocument_ID=' + quotedstr(mbo1.OID)                                + ' And ((SA.X_State=' + quotedstr('6XQ1000101') + ') or (SA.X_State=' + quotedstr('AXQ1000101') + ') or (SA.X_State=' + quotedstr('3JS1000101')+'))',mr);

                                      for ii := 0 to mr.Count-1 do begin // projdu vsechny oznacene zaznamy
                                           mIDs_MLRow.Add(mr.Strings[ii]);
                                      end;
                               finally
                                   mr.free;
                               end;
                        end else begin
                               NxShowSimpleMessage('Servisní list není ve fakturovatelném stavu',nil);
                        end;

                 end else begin
                          for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy           // pro ozbačené záznamy
                                  mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));

                                  mBO1 := TDynSiteForm(mSite).CurrentObject;
                                  try
                                     if (mbo1.getFieldValueAsstring('ServiceDocState_ID')='9200000101') then begin
                                          mr:=TStringList.create;
                                          try
                                             mbo1.ObjectSpace.SQLSelect('select SA2.id from ServiceAssemblyForms2 SA2 left join ServiceAssemblyForms sa on SA.ID=sa2.Parent_ID where sa2.ToInvoiceType=0 and sa2.IsInvoiced=0 and sa.ServiceDocument_ID=' + quotedstr(mbo1.OID)                                + ' And ((SA.X_State=' + quotedstr('6XQ1000101') + ') or (SA.X_State=' + quotedstr('AXQ1000101') + ') or (SA.X_State=' + quotedstr('3JS1000101')+'))',mr);

                                                for ii := 0 to mr.Count-1 do begin // plnění řádku dokladu
                                                     mIDs_MLRow.Add(mr.Strings[ii]);
                                                end;
                                          finally
                                             mr.free;
                                             //mbo1.free;
                                          end;
                                    end else begin
                                        NxShowSimpleMessage('Servisní list není ve fakturovatelném stavu',nil);
                                    end;
                                  finally
                                         mbo1.free;
                                  end;
                          end;
                  end;
              finally

              end;

          if mIDs_MLRow.Count>0 then begin

                try
                mbo:= TDynSiteForm(mSite).CurrentObject.ObjectSpace.CreateObject('O3BDOKTWEFD13ACM03KIU0CLP4');
                mBO.New;
                mBO.Prefill;
                mBO.SetFieldValueAsString('Docqueue_ID', '7D00000101');
                //mHeaderBO.SetFieldValueAsString('Description', 'Reklamace_dokladu:');
                mBO.SetFieldValueAsString('Firm_ID', TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('PayerFirm_ID'));

                mBO.SetFieldValueAsString('Description',
                  TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_ID.Code') + '-'+
                  inttostr(TDynSiteForm(mSite).CurrentObject.GetFieldValueAsInteger('ordnumber')) +'/'+
                  TDynSiteForm(mSite).CurrentObject.GetFieldValueAsstring('Period_ID.Code')) ;



              if TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_ID.Code')='SL01' then mBustrasaction_ID:='D370000101';    // 47
              if TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_ID.Code')='SL02' then mBustrasaction_ID:='';
              if TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_ID.Code')='SL03' then mBustrasaction_ID:='';
              if TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_ID.Code')='SL04' then mBustrasaction_ID:='B370000101';    // 48
              if TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_ID.Code')='SL05' then mBustrasaction_ID:='C370000101';    // 46
              if TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_ID.Code')='SL06' then mBustrasaction_ID:='D370000101';    // 47
              if TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_ID.Code')='SL07' then mBustrasaction_ID:='3870000101';    // 51
              if TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_ID.Code')='SL08' then mBustrasaction_ID:='3870000101';    // 51
              if TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_ID.Code')='SL09' then mBustrasaction_ID:='C370000101';
              if TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_ID.Code')='SL10' then mBustrasaction_ID:='C370000101';
              if TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_ID.Code')='SL11' then mBustrasaction_ID:='3870000101';    // 51


          mBO.SetFieldValueAsString('FirmOffice_ID', TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('PayerFirmOffice_ID'));
                mBO.SetFieldValueAsString('Person_ID', TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('payerPerson_ID'));
                mBO.SetFieldValueAsString('PaymentType_ID', TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_PaymenType_ID'));
                mBO.SetFieldValueAsBoolean('IsRowDiscount',true);

                              try
                              mMon := mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('ROWS'));

                                  mRow:= mbo.ObjectSpace.CreateObject('T3S00IN35IV4D0M3AQ0Y10CDFC');
                                  for i := 0 to mIDs_MLRow.Count-1 do begin
                                                try
                                                  mRow.Load(mIDs_MLRow.Strings[i],nil);
                                                  mquantity:=0;

                                                  if mRow.GetFieldValueAsFloat('UnitPriceWithoutVAT')>0 then begin
                                                          mNewRow := mMon.AddNewObject;
                                                          mQuantity:=mRow.GetFieldValueAsFloat('QuantityDelivered');
                                                          if mQuantity=0 then mQuantity:=mRow.GetFieldValueAsFloat('Quantity');
                                                          if mQuantity=0 then mQuantity:=mRow.GetFieldValueAsFloat('WorkHoursReal');
                                                          if mQuantity=0 then mQuantity:=mRow.GetFieldValueAsFloat('WorkHoursplaned');
                                                          if mQuantity=0 then mQuantity:=1;

                                                          if ((mRow.GetFieldValueAsInteger('itemtype')=0) or (mRow.GetFieldValueAsInteger('itemtype')=4)) then begin
                                                             mNewRow.SetFieldValueAsInteger('RowType', 2);
                                                             mNewRow.SetFieldValueAsString('Text',mRow.GetFieldValueAsString('Text'));
                                                             if Trim(mRow.GetFieldValueAsString('Text'))='' then mRow.GetFieldValueAsString('Storecard_ID.NAme');

                                                             mNewRow.SetFieldValueAsFLoat('Quantity', mQuantity);
                                                             mNewRow.SetFieldValueAsString('BusTransaction_ID',mBustrasaction_ID);    // 47
                                                             if (mRow.GetFieldValueAsstring('Text')= 'Paušál doprava') or (mRow.GetFieldValueAsstring('Text')= 'Doprava km') then mNewRow.SetFieldValueAsString('BusTransaction_ID','4870000101') ;
                                                          end;




                                                           if mRow.GetFieldValueAsInteger('itemtype')=1 then begin
                                                                mNewRow.SetFieldValueAsInteger('RowType', 3);
                                                                mNewRow.SetFieldValueAsString('Store_ID','M000000101');
                                                                mNewRow.SetFieldValueAsString('Storecard_ID',mRow.GetFieldValueAsString('Storecard_ID'));
                                                              if NxIsEmptyOID(mRow.GetFieldValueAsString('Parent_ID.ServiceDocument_ID.ServicedObject_ID.BusTransaction_ID')) then begin
                                                                 mNewRow.SetFieldValueAsString('BusTransaction_ID','');
                                                              end else begin
                                                                 mNewRow.SetFieldValueAsString('BusTransaction_ID',mRow.GetFieldValueAsString('Parent_ID.ServiceDocument_ID.ServicedObject_ID.BusTransaction_ID'));
                                                              end;
                                                              mNewRow.SetFieldValueAsFLoat('Quantity', mQuantity);

                                                           end;

                                                             if mRow.GetFieldValueAsInteger('itemtype')>1 then begin
                                                              mNewRow.SetFieldValueAsString('BusTransaction_ID',mBustrasaction_ID);
                                                           end;



                                                          mNewRow.SetFieldValueAsString('QUnit', mRow.GetFieldValueAsString('QUnit'));
                                                          mNewRow.SetFieldValueAsString('VATRate_ID', mRow.GetFieldValueAsString('VATRate_ID'));

                                                          mNewRow.SetFieldValueAsFLoat('UnitPrice', mRow.GetFieldValueAsFloat('UnitPriceWithoutVAT'));
                                                          if mRow.GetFieldValueAsFloat('Quantity')>0 then begin
                                                             mNewRow.SetFieldValueAsFLoat('TotalPrice', mRow.GetFieldValueAsFloat('UnitPriceWithoutVAT') *mRow.GetFieldValueAsFloat('Quantity') );
                                                          end else begin
                                                             mNewRow.SetFieldValueAsFLoat('TotalPrice', mRow.GetFieldValueAsFloat('UnitPriceWithoutVAT'));
                                                          end;

                                                          mNewRow.SetFieldValueAsFLoat('RowDiscount', mRow.GetFieldValueAsFloat('X_radkova_sleva'));
                                                          mNewRow.SetFieldValueAsString('Division_ID',mRow.GetFieldValueAsString('Parent_ID.ServiceDocument_ID.Division_ID'));
                                                          mNewRow.SetFieldValueAsString('BusOrder_ID',mRow.GetFieldValueAsString('Parent_ID.ServiceDocument_ID.BusOrder_ID'));

                                                          mNewRow.SetFieldValueAsString('X_parent_ID', mRow.GetFieldValueAsString('ID'));

                                                          if mRow.GetFieldValueAsInteger('itemtype')=2 then mNewRow.SetFieldValueAsString('Text',mRow.GetFieldValueAsString('Text'));
                                                          if mRow.GetFieldValueAsInteger('itemtype')=3 then mNewRow.SetFieldValueAsString('Text',mRow.GetFieldValueAsString('Text'));
                                                          if mRow.GetFieldValueAsInteger('itemtype')=4 then mNewRow.SetFieldValueAsString('Text',mRow.GetFieldValueAsString('Text'));

                                                        mNewRow.free;
                                                  end;
                                                  finally
                                                  end;
                                  end;

                              finally
                                  mrow.free;

                              end;
                //    mMon.Free;

                  //NxScriptingLog.WriteEvent(logDebug, 'pred zavolanim TDynSiteForm.TDynSiteForm');

                 TDynSiteForm.ShowDynFormWithNewDocument('PLC2EX0BUJD13ACP03KIU0CLP4', TDynSiteForm(mSite).SiteContext, mBO);
                // NxScriptingLog.WriteEvent(logDebug, 'po zavolanim TDynSiteForm.TDynSiteForm');
              finally
              //  NxScriptingLog.WriteEvent(logDebug, 'uvolneni BO faktury');
              //NxShowSimpleMessage('uvolneni BO faktury', mSite);
                  mbo.Free;
              end;
           end;
        finally
         // NxScriptingLog.WriteEvent(logDebug, 'uvolneni TStringlist');
            mIDs_MLRow.free;
        end;


       // NxScriptingLog.WriteEvent(logDebug, 'pred TDynSiteForm.RefreshData');
        TDynSiteForm(mSite).RefreshData;
      //TDynSiteForm.RefreshData;
    //  NxScriptingLog.WriteEvent(logDebug, 'po TDynSiteForm.RefreshData');

end;


procedure FVGroupExecuteItem(Sender: TAction; Index: integer);
var
 mresult:Boolean;
 mtext:string;
 mImportMan:TNxDocumentImportManager;
 mbo:TNxCustomBusinessObject;
 xSite: TDynSiteForm;
  mDBGrid : TDBGrid;
    mTabList: TTabSheet;
  self:TNxCustomBusinessObject;
  i,ii:integer;
  mr,mr1,mIDs_MLRow:TStringList;
   mForm: TDynSiteForm;
   mMon: TNxCustomBusinessMonikerCollection;
   mRow, mNewRow,mbo1: TNxCustomBusinessObject;
   mdate:Double;
   mBustrasaction_ID:string;
   mskupina:string;
begin
xSite := TComponent(Sender).DynSite;
    mTabList := TTabSheet(NxFindChildControl(xSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
     mr:=tstringlist.create;
           try
                xsite.BaseObjectSpace.sqlselect('Select max(X_skupina) from ServiceDocuments',mr);
                 if mr.count>0 then mskupina:=inttostr(strtoint(mr.strings[0])+1) else mskupina:='1';
                 mresult:=InputQuery('Odeslání k fakturaci - fakturační skupina', 'Automatická nová skupina, nebo zadej číslo existující :',mskupina);

           finally
               mr.free;
           end;
           if mBookmark.count=0 then begin                 // pro aktuální záznam
                      try
                         mBO1 := TDynSiteForm(xSite).CurrentObject;
                         mbo1.SetFieldValueAsinteger('X_skupina',strtoint(mskupina));
                         mbo1.save;
                      finally

                      end;
           end else begin
                          for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy           // pro ozbačené záznamy
                                  mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                                  try
                                  mBO1 := TDynSiteForm(xSite).CurrentObject;
                                  mbo1.SetFieldValueAsinteger('X_skupina',strtoint(mskupina));
                                  mbo1.save;
                                  finally
                                  end;
                          end;
           end;

end;


procedure FVShowExecuteItem(Sender: TAction; Index: integer);
var
 mresult:Boolean;
 mtext:string;
 mImportMan:TNxDocumentImportManager;
 mbo:TNxCustomBusinessObject;
 mSite: TDynSiteForm;
  mDBGrid : TDBGrid;
    mTabList: TTabSheet;
  self:TNxCustomBusinessObject;
  i,ii:integer;
  mr,mr1,mIDs_MLRow:TStringList;
   mForm: TDynSiteForm;
   mMon: TNxCustomBusinessMonikerCollection;
   mRow, mNewRow,mbo1: TNxCustomBusinessObject;
   mdate:Double;
   mBustrasaction_ID:string;

begin
    mSite := TComponent(Sender).DynSite;
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    try
      mIDs_MLRow:=TStringList.create;
          try
                  if mBookmark.count=0 then begin                 // pro aktuální záznam
                      try
                         mBO1 := TDynSiteForm(mSite).CurrentObject;
                         mr:=TStringList.create;
                         if ((mbo1.getFieldValueAsstring('ServiceDocState_ID')='D102000000')) then begin

                                  if mbo1.GetFieldValueAsInteger('GuarantyRepair')<>2 then begin
                                          mbo1.ObjectSpace.SQLSelect('select ii2.id from ServiceAssemblyForms2 SA2 left join ServiceAssemblyForms sa on SA.ID=sa2.Parent_ID left join issuedinvoices2 II2 on II2.X_parent_ID=SA2.id where sa.ServiceDocument_ID=' + quotedstr(mbo1.OID),mr);
                                          for ii := 0 to mr.Count-1 do begin // projdu vsechny oznacene zaznamy
                                               mIDs_MLRow.Add(mr.Strings[ii]);
                                          end;
                                  end else begin
                                                  mbo1.setFieldValueAsstring('ServiceDocState_ID','9100000101');
                                                  mbo1.save;
                                            end;
                         end else begin
                             NxShowSimpleMessage('Servisní list není ve fakturovatelném stavu',nil);
                         end;
                      finally
                         mbo1.free;
                         mr.free;
                      end;
                  end else begin
                          for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy           // pro ozbačené záznamy
                                  mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                                  mBO1 := TDynSiteForm(mSite).CurrentObject;

                                      if ((mbo1.getFieldValueAsstring('ServiceDocState_ID')='D102000000')) then begin
                                           if mbo1.GetFieldValueAsInteger('GuarantyRepair')<>2 then begin
                                                  try

                                                    mr:=TStringList.create;
                                                    mbo1.ObjectSpace.SQLSelect('select ii2.id from ServiceAssemblyForms2 SA2 left join ServiceAssemblyForms sa on SA.ID=sa2.Parent_ID left join issuedinvoices2 II2 on II2.X_parent_ID=SA2.id where sa.ServiceDocument_ID=' + quotedstr(mbo1.OID),mr);
                                                        for ii := 0 to mr.Count-1 do begin // plnění řádku dokladu
                                                             mIDs_MLRow.Add(mr.Strings[ii]);
                                                        end;
                                                  finally
                                                     mr.free;

                                                  end;


                                            end else begin
                                                  mbo1.setFieldValueAsstring('ServiceDocState_ID','9100000101');
                                                  mbo1.save;
                                            end;
                                        end else begin
                                            NxShowSimpleMessage('Servisní list není ve fakturovatelném stavu',nil);
                                        end;
                                  mbo1.free;
                          end;
                  end;


                  mIDs_MLRow.Sort;
                  if mIDs_MLRow.Count>0 then begin
                        for ii := 0 to mIDs_MLRow.Count-1 do begin // projdu vsechny oznacene zaznamy
                          if II<mIDs_MLRow.Count-1 then begin
                              if mIDs_MLRow.Strings[ii]<>mIDs_MLRow.Strings[ii+1] then begin
                                  try
                                     mBO1 := TDynSiteForm(mSite).CurrentObject.ObjectSpace.CreateObject('O3BDOKTWEFD13ACM03KIU0CLP4');
                                     mbo1.load(mIDs_MLRow.Strings[ii],nil);
                                     TDynSiteForm.ShowDynFormWithNewDocument('PLC2EX0BUJD13ACP03KIU0CLP4', TDynSiteForm(mSite).SiteContext, mBO1);
                                  finally
                                     mBO1.free;
                                  end
                              end;
                          end else begin
                                  try
                                     mBO1 := TDynSiteForm(mSite).CurrentObject.ObjectSpace.CreateObject('O3BDOKTWEFD13ACM03KIU0CLP4');
                                     mbo1.load(mIDs_MLRow.Strings[ii],nil);
                                     TDynSiteForm.ShowDynFormWithNewDocument('PLC2EX0BUJD13ACP03KIU0CLP4', TDynSiteForm(mSite).SiteContext, mBO1);
                                  finally
                                     mBO1.free;
                                  end
                          end;
                        end;
                  end else begin
                      NxShowSimpleMessage('Není dohledána žádná faktura',nil)
                  end;

              finally

              end;

      finally
        mIDs_MLRow.free;
      end;
       TDynSiteForm.RefreshData ;
end;


procedure FVExecuteItem(Sender: TAction; Index: integer);
var
 mresult:Boolean;
 mtext:string;
 mbo:TNxCustomBusinessObject;
 mSite: TSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 self:TNxCustomBusinessObject;
 i,ii:integer;
  mr,mIDs_MLRow:TStringList;
   mForm: TDynSiteForm;
   mMon: TNxCustomBusinessMonikerCollection;
   mRow, mNewRow,mbo1: TNxCustomBusinessObject;
   mdate:Double;
   mi:integer;
begin
  mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    try
      mIDs_MLRow:=TStringList.create;
          try
                  if mBookmark.count=0 then begin                 // pro aktuální záznam
                     mBO1 := TDynSiteForm(mSite).CurrentObject;
                       if mbo1.GetFieldValueAsInteger('GuarantyRepair')<>2 then begin
                         mr:=TStringList.create;
                          if ((mbo1.getFieldValueAsstring('ServiceDocState_ID')='9300000101') or (mbo1.getFieldValueAsstring('ServiceDocState_ID')='D102000000')) then begin

                         try
                                mbo1.ObjectSpace.SQLSelect('select SA2.id from ServiceAssemblyForms2 SA2 left join ServiceAssemblyForms sa on SA.ID=sa2.Parent_ID where sa2.ToInvoiceType=0 and sa2.IsInvoiced=0 and sa.AssemblyState=3 and sa.ServiceDocument_ID=' + quotedstr(mbo1.OID)
                                                                + ' And ((SA.X_State=' + quotedstr('6XQ1000101') + ') or (SA.X_State=' + quotedstr('AXQ1000101') + ') or (SA.X_State=' + quotedstr('3JS1000101')+'))',mr);

                                for ii := 0 to mr.Count-1 do begin // projdu vsechny oznacene zaznamy
                                     mIDs_MLRow.Add(mr.Strings[ii]);
                                end;
                         finally
                             mr.free;
                         end;

                         end else begin
                             NxShowSimpleMessage('Servisní list není ve fakturovatelném stavu',nil);
                         end;
                        end else begin
                                        mbo1.setFieldValueAsstring('ServiceDocState_ID','9100000101');
                                        mbo1.save;
                        end;
                  end else begin
                          for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy           // pro ozbačené záznamy
                                  mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));

                                  mBO1 := TDynSiteForm(mSite).CurrentObject;
                                  try
                                    if ((mbo1.getFieldValueAsstring('ServiceDocState_ID')='D102000000')) then begin

                                        if mbo1.GetFieldValueAsInteger('GuarantyRepair')<>2 then begin
                                          mr:=TStringList.create;
                                          try

                                              mbo1.ObjectSpace.SQLSelect('select SA2.id from ServiceAssemblyForms2 SA2 left join ServiceAssemblyForms sa on SA.ID=sa2.Parent_ID where sa2.ToInvoiceType=0 and sa2.IsInvoiced=0 and sa.ServiceDocument_ID=' + quotedstr(mbo1.OID)                                + ' And ((SA.X_State=' + quotedstr('6XQ1000101') + ') or (SA.X_State=' + quotedstr('AXQ1000101') + ') or (SA.X_State=' + quotedstr('3JS1000101')+'))',mr);

                                                for ii := 0 to mr.Count-1 do begin // plnění řádku dokladu
                                                     mIDs_MLRow.Add(mr.Strings[ii]);
                                                end;
                                          finally
                                             mr.free;
                                             //mbo1.free;
                                          end;
                                        end else begin
                                            mi:=mbo1.ObjectSpace.SQLExecute('Update ServiceDocuments set ServiceDocState_ID=' + quotedstr('9100000101') + ' where id=' +quotedstr(mbo1.oid));

                                            // mbo1.setFieldValueAsstring('ServiceDocState_ID','');
                                            // mbo1.save;
                                      end;
                                    end else begin
                                        NxShowSimpleMessage('Servisní list není ve fakturovatelném stavu',nil);
                                    end;
                                  finally
                                         mbo1.free;
                                  end;
                          end;
                  end;
              finally

              end;

          if mIDs_MLRow.Count>0 then begin

          mtext:='Ano';
                    mresult:=GetCheck(Sender,mSite,'Způsob fakturace','Přenesená','Bez přenes.') ;
              mdate:=0;


                try
                mbo:= TDynSiteForm(mSite).CurrentObject.ObjectSpace.CreateObject('O3BDOKTWEFD13ACM03KIU0CLP4');
                mBO.New;
                mBO.Prefill;
                mBO.SetFieldValueAsString('Docqueue_ID', '8D00000101');
                //mHeaderBO.SetFieldValueAsString('Description', 'Reklamace_dokladu:');
                mBO.SetFieldValueAsString('Firm_ID', TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('PayerFirm_ID'));

                mBO.SetFieldValueAsString('Description',
                  TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_ID.Code') + '-'+
                  inttostr(TDynSiteForm(mSite).CurrentObject.GetFieldValueAsInteger('ordnumber')) +'/'+
                  TDynSiteForm(mSite).CurrentObject.GetFieldValueAsstring('Period_ID.Code')) ;



              if TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_ID.Code')='SL01' then mBustrasaction_ID:='D370000101';    // 47
              if TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_ID.Code')='SL02' then mBustrasaction_ID:='';
              if TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_ID.Code')='SL03' then mBustrasaction_ID:='';
              if TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_ID.Code')='SL04' then mBustrasaction_ID:='B370000101';    // 48
              if TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_ID.Code')='SL05' then mBustrasaction_ID:='C370000101';    // 46
              if TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_ID.Code')='SL06' then mBustrasaction_ID:='D370000101';    // 47
              if TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_ID.Code')='SL07' then mBustrasaction_ID:='3870000101';    // 51
              if TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_ID.Code')='SL08' then mBustrasaction_ID:='3870000101';    // 51
              if TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_ID.Code')='SL09' then mBustrasaction_ID:='C370000101';
              if TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_ID.Code')='SL10' then mBustrasaction_ID:='C370000101';
              if TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Docqueue_ID.Code')='SL11' then mBustrasaction_ID:='3870000101';    // 51




                mBO.SetFieldValueAsString('FirmOffice_ID', TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('PayerFirmOffice_ID'));
                mBO.SetFieldValueAsString('Person_ID', TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('payerPerson_ID'));
                mBO.SetFieldValueAsString('PaymentType_ID', TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_PaymenType_ID'));
                mBO.SetFieldValueAsBoolean('IsRowDiscount',true);
                mBO.SetFieldValueAsBoolean('IsReverseChargeDeclared',mresult);

                              try
                              mMon := mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('ROWS'));

                                  mRow:= mbo.ObjectSpace.CreateObject('T3S00IN35IV4D0M3AQ0Y10CDFC');
                                  for i := 0 to mIDs_MLRow.Count-1 do begin
                                                try
                                                  mRow.Load(mIDs_MLRow.Strings[i],nil);
                                                  if mRow.GetFieldValueAsDateTime('X_konec_prace')>mdate then  mdate:=mRow.GetFieldValueAsDateTime('X_konec_prace');
                                                  if mRow.GetFieldValueAsFloat('UnitPriceWithoutVAT')>0 then begin
                                                          mNewRow := mMon.AddNewObject;

                                                          mNewRow.SetFieldValueAsInteger('RowType', 2);
                                                          if mRow.GetFieldValueAsInteger('itemtype')=0 then begin
                                                             mNewRow.SetFieldValueAsString('Text',mRow.GetFieldValueAsString('Text'));
                                                             if Trim(mRow.GetFieldValueAsString('Text'))='' then mRow.GetFieldValueAsString('Storecard_ID.NAme');
                                                             mNewRow.SetFieldValueAsFLoat('Quantity', mRow.GetFieldValueAsFloat('WorkHoursReal'));
                                                             if (mRow.GetFieldValueAsstring('Text')= 'Paušál doprava') or (mRow.GetFieldValueAsstring('Text')= 'Doprava km') then
                                                                    mNewRow.SetFieldValueAsString('BusTransaction_ID','4870000101')
                                                              else begin
                                                                   mNewRow.SetFieldValueAsString('BusTransaction_ID',mBustrasaction_ID);
                                                              end;

                                                           end;


                                                           if mRow.GetFieldValueAsInteger('itemtype')=1 then begin
                                                                  mNewRow.SetFieldValueAsString('Text',mRow.GetFieldValueAsString('Storecard_ID.Code') + ' - ' +mRow.GetFieldValueAsString('Storecard_ID.Name'));
                                                                  mNewRow.SetFieldValueAsFLoat('Quantity', mRow.GetFieldValueAsFloat('Quantity'));
                                                              if NxIsEmptyOID(mRow.GetFieldValueAsString('Parent_ID.ServiceDocument_ID.ServicedObject_ID.BusTransaction_ID')) then begin
                                                                 mNewRow.SetFieldValueAsString('BusTransaction_ID','');
                                                              end else begin
                                                                 mNewRow.SetFieldValueAsString('BusTransaction_ID',mRow.GetFieldValueAsString('Parent_ID.ServiceDocument_ID.ServicedObject_ID.BusTransaction_ID'));
                                                              end;
                                                           end;

                                                            if mRow.GetFieldValueAsInteger('itemtype')>1 then begin
                                                              mNewRow.SetFieldValueAsString('BusTransaction_ID',mBustrasaction_ID);
                                                           end;

                                                          mNewRow.SetFieldValueAsString('QUnit', mRow.GetFieldValueAsString('QUnit'));
                                                          mNewRow.SetFieldValueAsString('VATRate_ID', mRow.GetFieldValueAsString('VATRate_ID'));

                                                          mNewRow.SetFieldValueAsFLoat('UnitPrice', mRow.GetFieldValueAsFloat('UnitPriceWithoutVAT'));
                                                          if (mRow.GetFieldValueAsInteger('itemtype')<>0) then begin
                                                                  if (mRow.GetFieldValueAsInteger('itemtype')<>4) then begin
                                                                     //mNewRow.SetFieldValueAsFLoat('TotalPrice', mRow.GetFieldValueAsFloat('UnitPriceWithoutVAT') *mRow.GetFieldValueAsFloat('Quantity') );
                                                                     //mNewRow.SetFieldValueAsFLoat('Tamount', mRow.GetFieldValueAsFloat('UnitPriceWithoutVAT') *mRow.GetFieldValueAsFloat('Quantity') );
                                                                  end else begin
                                                                     //mNewRow.SetFieldValueAsFLoat('TotalPrice', mRow.GetFieldValueAsFloat('UnitPriceWithoutVAT'));
                                                                     //mNewRow.SetFieldValueAsFLoat('Tamount', mRow.GetFieldValueAsFloat('UnitPriceWithoutVAT'));
                                                                  end;
                                                          end;
                                                          mNewRow.SetFieldValueAsFLoat('RowDiscount', mRow.GetFieldValueAsFloat('X_radkova_sleva'));
                                                          mNewRow.SetFieldValueAsString('Division_ID',mRow.GetFieldValueAsString('Parent_ID.ServiceDocument_ID.Division_ID'));
                                                          mNewRow.SetFieldValueAsString('BusOrder_ID',mRow.GetFieldValueAsString('Parent_ID.ServiceDocument_ID.BusOrder_ID'));

                                                          mNewRow.SetFieldValueAsString('X_parent_ID', mRow.GetFieldValueAsString('ID'));







                                                        if mRow.GetFieldValueAsInteger('itemtype')=2 then mNewRow.SetFieldValueAsString('Text',mRow.GetFieldValueAsString('Text'));


                                                        if mRow.GetFieldValueAsInteger('itemtype')=3 then begin
                                                            mNewRow.SetFieldValueAsString('Text',mRow.GetFieldValueAsString('Text'));
                                                            mNewRow.SetFieldValueAsFloat('Quantity',1);
                                                        end;

                                                        if mRow.GetFieldValueAsInteger('itemtype')=4 then begin
                                                            mNewRow.SetFieldValueAsString('Text',mRow.GetFieldValueAsString('Text'));
                                                            if mRow.GetFieldValueAsfloat('Quantity')>0 then begin
                                                                mNewRow.SetFieldValueAsfloat('Quantity',mRow.GetFieldValueAsfloat('Quantity'));
                                                            end else begin
                                                                mNewRow.SetFieldValueAsfloat('Quantity',1);
                                                            end;

                                                        end;
                                                          if mresult then begin
                                                              mNewRow.SetFieldValueAsInteger('VATMode',1);
                                                              mNewRow.SetFieldValueAsString('DRCArticle_ID', '1100000000');
                                                              mNewRow.SetFieldValueAsFloat('DRCQuantity', mRow.GetFieldValueAsFloat('Quantity'));
                                                          end;
                                                          mNewRow.free;
                                                  end else begin
                                                  end;
                                                  finally
                                                  end;
                                  end;

                                  if mdate=0 then mdate:=mrow.GetFieldValueAsDateTime('Parent_ID.EndDate$DATE');
                                             mBO.SetFieldValueAsDateTime('DocDate$DATE',mdate);
                                             mBO.SetFieldValueAsDateTime('VATDate$DATE',mdate);
                              finally
                                  mrow.free;

                              end;
                //    mMon.Free;

                  //NxScriptingLog.WriteEvent(logDebug, 'pred zavolanim TDynSiteForm.TDynSiteForm');

                 TDynSiteForm.ShowDynFormWithNewDocument('PLC2EX0BUJD13ACP03KIU0CLP4', TDynSiteForm(mSite).SiteContext, mBO);
                // NxScriptingLog.WriteEvent(logDebug, 'po zavolanim TDynSiteForm.TDynSiteForm');
              finally
              //  NxScriptingLog.WriteEvent(logDebug, 'uvolneni BO faktury');
              //NxShowSimpleMessage('uvolneni BO faktury', mSite);
                  mbo.Free;
              end;
           end;
        finally
         // NxScriptingLog.WriteEvent(logDebug, 'uvolneni TStringlist');
            mIDs_MLRow.free;
        end;


       // NxScriptingLog.WriteEvent(logDebug, 'pred TDynSiteForm.RefreshData');
        TDynSiteForm(mSite).RefreshData;
      //TDynSiteForm.RefreshData;
    //  NxScriptingLog.WriteEvent(logDebug, 'po TDynSiteForm.RefreshData');

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
{  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Fakturace / záruka';
  mAction.Hint := 'Vytvoří fakturu vydanou';
  mAction.Category := 'tabList';
  mAction.OnExecute:= @FVExecuteItem;

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Fakturace / záruka i nulové';
  mAction.Hint := 'Vytvoří fakturu vydanou';
  mAction.Category := 'tabList';
  mAction.OnExecute:= @FVExecuteItemwithnull;


  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Fakturace -logistika';
  mAction.Hint := 'Vytvoří fakturu vydanou';
  mAction.Category := 'tabList';
  mAction.OnExecute:= @FVExecuteItemLOG;


//  mAction := Self.GetNewAction;
//  mAction.ShowControl := True;
//  mAction.ShowMenuItem := True;
//  mAction.Caption := 'Zobraz fakturu';
//  mAction.Hint := 'Zobrazí vystavenou fakturu';
//  mAction.Category := 'tabList';
//  mAction.OnExecute := @FVShowExecuteItem;

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := 'Povolit znovu fakturovat';
  mAction.Hint := 'Částečná fakturace';
  mAction.Category := 'tabList';
  mAction.OnExecute := @FVeditItem;  }

   mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Fakturace';
  mMAction.Hint := 'Operace dispečera servisu';
  mMAction.Category := 'tabList';
//  mMAction.OnUpdate := @FVOnExekute;
  mMAction.OnExecuteItem := @FVOnExekute;
  mMAction.Items.Add('Fakturace/záruka');
  mMAction.Items.Add('Fakturace/záruka i nulové');
  mMAction.Items.Add('Fakturace logistika');
  mMAction.Items.Add('Znovupovolení fakturace');
  mMAction.Items.Add('Fakturační skupina');

end;

procedure FVOnExekute(Sender: TAction;index:integer;);
begin
if index=0 then FVExecuteItem(sender,index);
if index=1 then FVExecuteItemwithnull(sender,index);
if index=2 then FVExecuteItemLOG(sender,index);
if index=3 then FVeditItem(sender,index);
if index=4 then FVGroupExecuteItem(sender,index);

end ;



begin
end.