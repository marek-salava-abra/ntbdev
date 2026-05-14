uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse',
      'Synchronizace.API',
      'Synchronizace_dokladu_na_SK.API' ;

function NewDL(ABO: TNxCustomBusinessObject): string;
var
  mpoz: TNxCustomBusinessObject;
  i,ii, mPosIndex: integer;
  mMon: TNxCustomBusinessMonikerCollection;
  mRow, mNewRow,mDocBatchRowSource,mDocBatchRow: TNxCustomBusinessObject;
  mList,mr: TStringList;
  mText: string;
  mPocetDokladu,mPocetVyrobku:double;
begin
  result := '';
  mPocetDokladu:=0;
  mPocetVyrobku:=0;









end;

procedure NewPOZExecute(Sender: TObject; index: Integer);
var
  mSite: TSiteForm;
  mDBGrid : TDBGrid;
  mTabList: TTabSheet;
  mi:integer;
  mBookmark : TBookmarkList;
  mIBookmark:integer;
  mICount,i:integer;
  mRow,mPOZ, mBO_source,mBO,mBO_Target,mNewRow: TNxCustomBusinessObject;
  mID: string;
  mPocetDokladu,mPocetVyrobku:double;
  mMon,mMonTarget:TNxCustomBusinessMonikerCollection;
  mList,mr: TStringList;
  mText: string;
  mQuery:string;
  mstring,mdocnumber:string;
  mb:boolean;
  aname,Blat_File:string;
  mxid:string;
  mdelete:Boolean;
  xi:integer;
  mUlozdoklad:boolean;
begin
  mPocetDokladu:=0;
  mPocetVyrobku:=0;
  xi:=0;
if Sender is TComponent then mSite := TComponent(Sender).Site;

//  if Sender is TAction then mSite := NxFindSiteForm(Sender);

    if not Assigned(mSite) then begin
         NxMessageBox('Chyba', 'Agenda nebyla dohledána', mdConfirm, mdbOkCancel, 0, 0, true, nil) ;
         nxbeep(btfailure);
         exit;
    end else begin
        mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
            if mTabList = nil then begin
                  RaiseException('tabList nenalezen');
                  NxMessageBox('Chyba', 'abList nenalezen', mdConfirm, mdbOkCancel, 0, 0, true, nil) ;
                  nxbeep(btfailure);
                  exit;
            end else begin
            mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
                if mDBGrid = nil then begin
                      RaiseException('DBGrid nenalezen');
                      NxMessageBox('Chyba', 'DBGrid nenalezen', mdConfirm, mdbOkCancel, 0, 0, true, nil) ;
                      nxbeep(btfailure);
                      exit;
                end else begin

                mdelete:=false;






                mr:=TStringList.create;
                try
                     msite.BaseObjectSpace.SQLSelect('select distinct io.id from IssuedOrders2 io2 join IssuedOrders IO on io.id=io2.parent_ID where store_id=' + QuotedStr(mStoreCalc_ID),mr);
                     if mr.count>0 then begin


                        xi:=NxMessageBox('Pozor', 'na OV je na kalkulačním skladu pohyb , přejete si vyprázdnit :', mdConfirm, mdbOkCancel, 0, 0, true, nil) ;   //1,2
                        //mb:=InputQuery('Pozor' ,'Na OV je na kalkulačním skladu pohyb , přejete si vyprázdnit','');
                         if xi=1 then begin
                             ProgressInit(msite, 'Mazání OV ' + '', 100);
                             mBO:=msite.BaseObjectSpace.CreateObject('CDMK5QAWZZDL342X01C0CX3FCC');
                                try
                                       for i:=0 to mr.count-1 do begin
                                           ProgressSetPos(1+NxFloor(i/mr.Count*99), inttostr(i) +' z '+inttostr(mr.Count));
                                           mbo.load(mr.Strings[i],nil);
                                           mbo.Delete;
                                           mdelete:=True;

                                       end;
                                 finally
                                     ProgressDispose()   ;
                                     mbo.free;
                                 end;


                         end;
                     end;
                finally

                    mr.free;
                end;

                mr:=TStringList.create;
                try
                     msite.BaseObjectSpace.SQLSelect('select id from PLMProduceRequests where store_id=' + QuotedStr(mStoreCalc_ID),mr);
                     if mr.count>0 then begin
                         xi:=NxMessageBox('Pozor', 'Na Požadavcích je na kalkulačním skladu pohyb , přejete si vyprázdnit', mdConfirm, mdbOkCancel, 0, 0, true, nil) ;   //1,2
                         // mb:=InputQuery('Pozor' ,'Na Požadavcích je na kalkulačním skladu pohyb , přejete si vyprázdnit','');
                         if xi=1 then begin
                             ProgressInit(msite, 'Mazání OV ' + '', 100);
                              mBO:=msite.BaseObjectSpace.CreateObject('IVJSI1K34CJORFG1QBJOMTSVAG');
                                   try
                                       for i:=0 to mr.count-1 do begin
                                           ProgressSetPos(1+NxFloor(i/mr.Count*99), inttostr(i) +' z '+inttostr(mr.Count));
                                           mbo.load(mr.Strings[i],nil);
                                           mbo.Delete;
                                            mdelete:=True;
                                       end;
                                    finally
                                         ProgressDispose()   ;
                                         mbo.free;
                                    end;
                         end;
                     end;
                finally
                    mr.free;
                end;





                      mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
                      mIBookmark:=0;
                      if mBookmark.count>0 then begin
                           mIBookmark:=mBookmark.count-1;

                      end;
                      for mICount:=0 to mIBookmark do begin
                        mulozdoklad:=false;
                          if mBookmark.count>0 then begin
                               mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(mICount));


                          end;


                          mbo_source:=TDynSiteForm(msite).CurrentObject;
                          if index=0 then begin
                            mbo_Target:=TDynSiteForm(msite).BaseObjectSpace.CreateObject('CDMK5QAWZZDL342X01C0CX3FCC');
                            mBO_Target.new;
                            mBO_Target.Prefill;
                            mBO_Target.SetFieldValueAsString('DocQueue_ID','1640000101');
                            mBO_Target.SetFieldValueAsString('Firm_ID', mbo_source.GetFieldValueAsString('Firm_ID'));
                            mBO_Target.SetFieldValueAsString('Description', copy(mBO_source.DisplayName + ', ' +  mbo_source.GetFieldValueAsString('Description'),1,50));
                            mBO_Target.SetFieldValueAsBoolean('Confirmed', True);
                            mMonTarget := mBO_Target.GetLoadedCollectionMonikerForFieldCode(mBO_Target.GetFieldCode('ROWS'));
                          end;
                          if index=1 then begin
                            mbo_Target:=TDynSiteForm(msite).BaseObjectSpace.CreateObject('CDMK5QAWZZDL342X01C0CX3FCC');
                            mBO_Target.new;
                            mBO_Target.Prefill;
                            mBO_Target.SetFieldValueAsString('DocQueue_ID','7400000101');
                            mBO_Target.SetFieldValueAsString('Firm_ID', mbo_source.GetFieldValueAsString('Firm_ID'));
                            mBO_Target.SetFieldValueAsString('Description', copy(mBO_source.DisplayName + ', ' +  mbo_source.GetFieldValueAsString('Description'),1,50));
                            mBO_Target.SetFieldValueAsBoolean('Confirmed', True);
                            mMonTarget := mBO_Target.GetLoadedCollectionMonikerForFieldCode(mBO_Target.GetFieldCode('ROWS'));
                          end;
                          mMon := mbo_source.GetLoadedCollectionMonikerForFieldCode(mbo_source.GetFieldCode('ROWS'));

                                       ProgressInit(msite, 'Zpracování dat ' + '', 100);
                                        for i := 0 to mMon.Count-1 do begin
                                          mRow := mMon.BusinessObject[i];
                                              //NxShowSimpleMessage(Trim(UpperCase(mRow.GetFieldValueAsString('StoreCard_ID.MainSupplier_ID.Firm_ID.ResidenceAddress_ID.CountryCode'))),nil);
                                             ProgressSetPos(1+NxFloor(i/mMon.Count*99), inttostr(i) +' z '+inttostr(mMon.Count));
                                             //if i <5 then
                                             //NxShowSimpleMessage(mRow.GetFieldValueAsString('StoreCard_ID.MainSupplier_ID.Firm_ID'),nil) ;

                                             if index=0 then begin


                                                           if (Trim(UpperCase(mRow.GetFieldValueAsString('StoreCard_ID.MainSupplier_ID.Firm_ID.ResidenceAddress_ID.CountryCode')))='CZ') then begin

                                                                         if mrow.GetFieldValueAsBoolean('Storecard_ID.ISproduct') then begin

                                                                                 mpoz := TDynSiteForm(msite).BaseObjectSpace.CreateObject('IVJSI1K34CJORFG1QBJOMTSVAG');
                                                                                        try
                                                                                          mPOZ.New;
                                                                                          mPOZ.Prefill;
                                                                                          mPOZ.SetFieldValueAsString('DocQueue_ID','4712000101');
                                                                                          mPOZ.SetFieldValueAsString('Firm_ID', mbo_source.GetFieldValueAsString('Firm_ID'));
                                                                                          mPOZ.SetFieldValueAsString('Division_ID', mRow.GetFieldValueAsString('Division_ID'));
                                                                                          mPOZ.SetFieldValueAsString('Store_ID', mStoreCalc_ID);
                                                                                          mPOZ.SetFieldValueAsString('StoreCard_ID', mRow.GetFieldValueAsString('StoreCard_ID'));
                                                                                          mPOZ.SetFieldValueAsFloat('Quantity', mRow.GetFieldValueAsfloat('Quantity'));
                                                                                          mPOZ.SetFieldValueAsFloat('CorrectedQuantity', mRow.GetFieldValueAsfloat('Quantity'));
                                                                                        // mPOZ.SetFieldValueAsString('CorrectedUnitQuantity', mRow.GetFieldValueAsString('QUnit'));



                                                                                          mPOZ.SetFieldValueAsString('BusOrder_ID', mRow.GetFieldValueAsString('BusOrder_ID'));
                                                                                          mPOZ.SetFieldValueAsString('BusProject_ID', mRow.GetFieldValueAsString('BusProject_ID'));
                                                                                          mPOZ.SetFieldValueAsString('BusTransaction_ID', mRow.GetFieldValueAsString('BusTransaction_ID'));

                                                                                          mPOZ.ClearValidateErrors;

                                                                                                          if Not mPOZ.Validate() then begin
                                                                                                            mList := TStringList.Create;
                                                                                                            try
                                                                                                              mPOZ.GetValidateErrors(mList);
                                                                                                              mText := mList.Text;
                                                                                                              NxToken(mText, '=');
                                                                                                              MessageDlg('Automaticky vytvořeny POZ nelze uložit z těchto důvodů:' + #13#10 + mText,
                                                                                                                mtWarning, [mbOK], 0);
                                                                                                            finally
                                                                                                              mList.Free;
                                                                                                            end;
                                                                                                          end else begin
                                                                                                            mPOZ.Save;


                                                                                                            mPocetDokladu:=mPocetDokladu+1;
                                                                                                            mPocetVyrobku:=mPocetVyrobku+mPOZ.getFieldValueAsFloat('Quantity');
                                                                                                          end;
                                                                                        finally
                                                                                              mPOZ.Free;
                                                                                        end;


                                                                       end else begin
                                                                         NxShowSimpleMessage('Položka ' + mrow.GetFieldValueAsString('Storecard_ID.displayname') + ' není označena jako výrobek a nebude s ní pracováno ',nil);
                                                                       end;
                                                           end else begin   // ov na nevyráběné položky
                                                                    if not NxIsEmptyOID(mRow.GetFieldValueAsString('StoreCard_ID.MainSupplier_ID.Firm_ID')) then
                                                                        mBO_Target.SetFieldValueAsString('Firm_ID', mRow.GetFieldValueAsString('StoreCard_ID.MainSupplier_ID.Firm_ID'));
                                                                    mNewRow := mMonTarget.AddNewObject;
                                                                          mNewRow.SetFieldValueAsInteger('RowType', mRow.GetFieldValueAsInteger('RowType'));
                                                                          mNewRow.SetFieldValueAsString('Store_ID', '41Y0000101');
                                                                          mNewRow.SetFieldValueAsString('StoreCard_ID', mRow.GetFieldValueAsString('StoreCard_ID'));
                                                                          mNewRow.SetFieldValueAsString('QUnit', mRow.GetFieldValueAsString('QUnit'));
                                                                          mNewRow.SetFieldValueAsFLoat('UnitRate', mRow.GetFieldValueAsFloat('UnitRate'));
                                                                          mNewRow.SetFieldValueAsFLoat('Quantity', mRow.GetFieldValueAsFloat('Quantity'));
                                                                          mNewRow.SetFieldValueAsString('Text', mRow.GetFieldValueAsString('Text'));
                                                                          mNewRow.SetFieldValueAsString('Division_ID', mRow.GetFieldValueAsString('Division_ID'));
                                                                          mNewRow.SetFieldValueAsString('BusOrder_ID', mRow.GetFieldValueAsString('BusOrder_ID'));
                                                                          mNewRow.SetFieldValueAsString('BusTransaction_ID', mRow.GetFieldValueAsString('BusTransaction_ID'));

                                                                          mNewRow.SetFieldValueAsString('X_ExternalSpecification', mRow.GetFieldValueAsString('X_ExternalSpecification'));
                                                                          mNewRow.SetFieldValueAsString('X_Specifikace_ID', mRow.GetFieldValueAsString('X_Specifikace_ID'));
                                                                          mNewRow.SetFieldValueAsString('U_Specifikace_ID', mRow.GetFieldValueAsString('U_Specifikace_ID'));
                                                                          mPocetVyrobku:=mPocetVyrobku+mNewRow.getFieldValueAsFloat('Quantity');
                                                                         mUlozdoklad:=true;
                                                           end;


                                                  end;

                                              if index=1 then begin

                                                                         if mrow.GetFieldValueAsBoolean('Storecard_ID.ISproduct') then begin

                                                                                 mpoz := TDynSiteForm(msite).BaseObjectSpace.CreateObject('IVJSI1K34CJORFG1QBJOMTSVAG');
                                                                                        try
                                                                                          mPOZ.New;
                                                                                          mPOZ.Prefill;
                                                                                          mPOZ.SetFieldValueAsString('DocQueue_ID','4712000101');
                                                                                          mPOZ.SetFieldValueAsString('Firm_ID', mbo_source.GetFieldValueAsString('Firm_ID'));
                                                                                          mPOZ.SetFieldValueAsString('Division_ID', mRow.GetFieldValueAsString('Division_ID'));
                                                                                          mPOZ.SetFieldValueAsString('Store_ID', mStoreCalc_ID);
                                                                                          mPOZ.SetFieldValueAsString('StoreCard_ID', mRow.GetFieldValueAsString('StoreCard_ID'));
                                                                                          mPOZ.SetFieldValueAsFloat('Quantity', mRow.GetFieldValueAsfloat('Quantity'));
                                                                                          mPOZ.SetFieldValueAsFloat('CorrectedQuantity', mRow.GetFieldValueAsfloat('Quantity'));
                                                                                        // mPOZ.SetFieldValueAsString('CorrectedUnitQuantity', mRow.GetFieldValueAsString('QUnit'));



                                                                                          mPOZ.SetFieldValueAsString('BusOrder_ID', mRow.GetFieldValueAsString('BusOrder_ID'));
                                                                                          mPOZ.SetFieldValueAsString('BusProject_ID', mRow.GetFieldValueAsString('BusProject_ID'));
                                                                                          mPOZ.SetFieldValueAsString('BusTransaction_ID', mRow.GetFieldValueAsString('BusTransaction_ID'));

                                                                                          mPOZ.ClearValidateErrors;

                                                                                                          if Not mPOZ.Validate() then begin
                                                                                                            mList := TStringList.Create;
                                                                                                            try
                                                                                                              mPOZ.GetValidateErrors(mList);
                                                                                                              mText := mList.Text;
                                                                                                              NxToken(mText, '=');
                                                                                                              MessageDlg('Automaticky vytvořeny POZ nelze uložit z těchto důvodů:' + #13#10 + mText,
                                                                                                                mtWarning, [mbOK], 0);
                                                                                                            finally
                                                                                                              mList.Free;
                                                                                                            end;
                                                                                                          end else begin
                                                                                                            mPOZ.Save;


                                                                                                            mPocetDokladu:=mPocetDokladu+1;
                                                                                                            mPocetVyrobku:=mPocetVyrobku+mPOZ.getFieldValueAsFloat('Quantity');
                                                                                                          end;
                                                                                        finally
                                                                                              mPOZ.Free;
                                                                                        end;



                                                                       end else begin
                                                                         NxShowSimpleMessage('Položka ' + mrow.GetFieldValueAsString('Storecard_ID.displayname') + ' není označena jako výrobek a nebude s ní pracováno ',nil);
                                                                       end;

                                                                       if not NxIsEmptyOID(mRow.GetFieldValueAsString('StoreCard_ID.MainSupplier_ID.Firm_ID')) then
                                                                        //mBO_Target.SetFieldValueAsString('DocQueue_ID','1640000101');
                                                                         mBO_Target.SetFieldValueAsString('Firm_ID', mRow.GetFieldValueAsString('StoreCard_ID.MainSupplier_ID.Firm_ID'));
                                                                    mNewRow := mMonTarget.AddNewObject;
                                                                          mNewRow.SetFieldValueAsInteger('RowType', mRow.GetFieldValueAsInteger('RowType'));
                                                                          mNewRow.SetFieldValueAsString('Store_ID', '51A1000101');
                                                                          mNewRow.SetFieldValueAsString('StoreCard_ID', mRow.GetFieldValueAsString('StoreCard_ID'));
                                                                          mNewRow.SetFieldValueAsString('QUnit', mRow.GetFieldValueAsString('QUnit'));
                                                                          mNewRow.SetFieldValueAsFLoat('UnitRate', mRow.GetFieldValueAsFloat('UnitRate'));
                                                                          mNewRow.SetFieldValueAsFLoat('Quantity', mRow.GetFieldValueAsFloat('Quantity'));
                                                                          mNewRow.SetFieldValueAsString('Text', mRow.GetFieldValueAsString('Text'));
                                                                          mNewRow.SetFieldValueAsString('Division_ID', mRow.GetFieldValueAsString('Division_ID'));
                                                                          mNewRow.SetFieldValueAsString('BusOrder_ID', mRow.GetFieldValueAsString('BusOrder_ID'));
                                                                          mNewRow.SetFieldValueAsString('BusTransaction_ID', mRow.GetFieldValueAsString('BusTransaction_ID'));

                                                                          mNewRow.SetFieldValueAsString('X_ExternalSpecification', mRow.GetFieldValueAsString('X_ExternalSpecification'));
                                                                          mNewRow.SetFieldValueAsString('X_Specifikace_ID', mRow.GetFieldValueAsString('X_Specifikace_ID'));
                                                                          mNewRow.SetFieldValueAsString('U_Specifikace_ID', mRow.GetFieldValueAsString('U_Specifikace_ID'));
                                                                         mUlozdoklad:=true;


                                                  end;

                                        end;



                                       ProgressDispose() ;

                     if index=1 then begin
                         if mUlozdoklad then begin
//                               NxShowSimpleMessage('AAA' + inttostr(mMonTarget.count),nil);

                               if mBO_Target.GetFieldValueAsString('DocQueue_ID')<>'7400000101' then begin
                                      mBO_Target.save;
                               end else begin
                                  //NxShowSimpleMessage('Doklad OV neuložen', nil);
                                  //mBO_Target.save;
                               end;
                     end;
                     end;
                     if index=0 then begin

                      // ***  odeslání api
                        if mUlozdoklad then begin
//                               NxShowSimpleMessage('AAA' + inttostr(mMonTarget.count),nil);
                               if mBO_Target.GetFieldValueAsString('DocQueue_ID')<>'7400000101' then begin
                                  mBO_Target.save;
                               end else begin
                                    mBO_Target:= mbo_source;
                               end;
//                               NxShowSimpleMessage('AAA',nil);
                               mPocetDokladu:=mPocetDokladu+1;
                                  if mBO_Target.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode')<>'CZ' then begin

                                          // vytvoření dokladu

                                                       mQuery:=GetDocQuery(mBO_Target,'4722000101','3010000101','','7131000101','5O10000101','RO')  ;
                                                 mstring:='';
                                                //mb:=InputQuery('Kontrola API','POST',mTargetDocumentAPI+'ReceivedOrders?select=displayname'+mQuery) ;
                                                 mString:= APICallRest(mBO_Target,'POST',mTargetDocumentAPI,'ReceivedOrders','?select=id,displayname',mQuery,true);  // odeslání OV
                                          mdocnumber:=mdocnumber + ', ' + copy(mString,41,15);


                                                if (copy(mString,1,3)='201') then begin
                                                      //NxShowSimpleMessage('doklad ' + copy(mString,14,10),nil);
                                                      //if copy(mString,9,2)='ID' then begin      // záznam namezen
                                                               mdocnumber:= copy(mString,14,10);
                                                                        if mBsentemail then begin
                                                                                mPrintList := TStringList.Create;
                                                                                try
                                                                                   mPrintList.Add(mBO_Target.OID);
                                                                                   AName := mBO_Target.GetFieldValueAsString('Docqueue_ID.CODE') +'-' + inttostr(mBO_Target.GetFieldValueAsInteger('Ordnumber'))  +'-' + mBO_Target.GetFieldValueAsString('Period_id.CODE')+'.pdf' ;
                                                                                   try
                                                                                      CFxReportManager.PrintByIDs(NxCreateContext(mBO_Target.ObjectSpace),mPrintList,'W0NZQGROZZDL342X01C0CX3FCC', '2NI0000101', rtofile, pekPDF,NxGetTempDir,aname);
                                                                                      Blat_File:=NxGetTempDir+'\'+aname;
                                                                                      try

                                                                                              Blat_File:=NxGetTempDir+aname;
                                                                                              mxid:='';
                                                                                              //     mxid:=iSendMailx(self.ObjectSpace, 'Objednávka: ' + self.DisplayName , 'Právě Vám byla odeslána objednávka ze společnosti LIPOELASTIC a.s. s číslem: ' +  self.DisplayName, 'kondrickova@lipoelastic.sk;zorlikova@lipoelastic.sk', '','','3130000101', Blat_File,'1N00000101',self);
                                                                                              mxid:=iSendMailx(mbo_source.ObjectSpace, 'Objednávka: ' + mbo_source.DisplayName , 'Právě Vám byla odeslána objednávka ze společnosti LIPOELASTIC a.s. s číslem: ' +  mbo_source.DisplayName, 'kondrickova@lipoelastic.sk;zorlikova@lipoelastic.sk;msklacel@lipoelastic.com', '','','3130000101', Blat_File,'1N00000101',mbo_source);

                                                                                      except
                                                                                      end;
                                                                                    except
                                                                                    end;
                                                                                finally
                                                                                    mPrintList.free;
                                                                                end;
                                                                        end;





                                                        //mID:=iSendMail(TDynSiteForm(msite).BaseObjectSpace, 'Byla synchronizována nová objenávka', 'Objednávka: ' + self.DisplayName , 'mskacel@lipoelastic.com;mskacel@lipoelastic.com', '','','2140000101', '' ,'1000000101','');

                                                               //NxShowSimpleMessage('doklad ' + mDoc_ID,nil);
                                                      //end;
                                                end else begin
                                                          NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                                                          //exit;
                                                end;
                                    end;

                                  end;
                        end;
                    end;
                     // if mBookmark.count>0 then     ;
                     //mBO_source.SetFieldValueAsDateTime('X_SendDate$Date', Now);
                     mBO_source.save;
                end;
            end;
    end;

     NxShowSimpleMessage('Bylo vytvořeno ' + NxFloatToIBStr(mPocetDokladu) + ' dokladů , a zajištěno :' +  NxFloatToIBStr(mPocetVyrobku) + ' jednotek' , msite);




end;

  procedure FormCreate_Hook(Self: TSiteForm);
var
  mAction: TMultiAction;
begin
  mAction := Self.GetNewMultiAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := False;
  mAction.Caption := 'Požadavek na výrobu';
  mAction.Items.Add('Požadavek na výrobu');
  mAction.Items.Add('Přímá výroba');
  //mAction.Items.Add('Jen POZ');
  //mAction.Items.Add('Smazání POZ');
  mAction.Hint := 'Zajištění LIPOELASTIC';
  mAction.Category := 'tabList';
  mAction.OnExecuteItem := @NewPOZExecute;
end;






begin
end.