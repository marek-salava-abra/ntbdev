uses 'abra.eu.mask.Spedos.Servis.2015.Stav_zasob.const',
       'abra.eu.mask.Spedos.Servis.2015.Stav_zasob.funkce';
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

procedure StorecardExecuteItem(Sender: TMultiAction; Index: integer);
var
 mSite: TDynSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 mresult:string;
 mtext:string;
 mbo,mbo_document,mRow:TNxCustomBusinessObject;
 i,ii:integer;
 mMon: TNxCustomBusinessMonikerCollection;
 mr:TStringList;
 mstorecard_id:string;
 mquantity:string;
 mQunit:string;
begin

mSite := TComponent(Sender).DynSite;
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then RaiseException('DBGrid nenalezen');
        mBO:= TDynSiteForm(mSite).CurrentObject;

        if (mbo.GetFieldValueAsString('Storecard_ID')='4XN1000101') and (not NxIsEmptyOID(mbo.GetFieldValueAsString('X_parent_ID'))) then begin
            mstorecard_id := iSelectStorecard(mSite.GetAbraOLEApplication);
            // montážní list
            mquantity:='0';
            mr:=TStringList.create;
            try
              mbo.ObjectSpace.SQLSelect('Select MainUnitCode from Storecards where id=' + quotedstr(mstorecard_id),mr);
                if mr.count>0 then mQunit:=mr.Strings[0];
            finally
              mr.free;
            end;


            mquantity:=FloatToStr(mbo.GetFieldValueAsFloat('Quantity')*mbo.GetFieldValueAsFloat('UnitRate'));
            aaa:=InputQuery('Náhrada karty dle popisu: ',
                                 Trim(copy(mbo.GetFieldValueAsString('X_description'),1,100))+' z množství '+FloatToStr(mbo.GetFieldValueAsFloat('Quantity')*mbo.GetFieldValueAsFloat('UnitRate'))+ ' ' +mbo.GetFieldValueAsString('Qunit') + ' na množství v '+ mQunit,mquantity);



            mr:=TStringList.create;
            try
                mbo.ObjectSpace.SQLSelect('Select Parent_ID||ID from ServiceAssemblyForms2 where id=' + quotedstr(mbo.GetFieldValueAsString('X_parent_ID')),mr);
                if mr.Count>0 then begin
                    for  i:=0 to mr.Count-1 do begin

                      mbo_document:=mbo.ObjectSpace.CreateObject('I3CRLLN3XYVO30ZDQ2WB4CRZW0');
                          try
                              mbo_document.Load(copy(mr.Strings[0],1,10),nil);
                              mMon := mbo_document.GetLoadedCollectionMonikerForFieldCode(mbo_document.GetFieldCode('ROWS'));
                                    for i := 0 to mMon.Count-1 do begin
                                        mRow := mMon.BusinessObject[i];
                                        if mRow.GetFieldValueAsstring('ID')=mbo.GetFieldValueAsString('X_parent_ID') then begin
                                              mRow.SetFieldValueAsstring('Storecard_ID',mstorecard_id);
                                              mRow.SetFieldValueAsFloat('Quantity',strtofloat(mquantity));
                                              mRow.SetFieldValueAsFloat('Unitrate',strtofloat(mquantity));
                                              //NxShowSimpleMessage('Nahrazení v montážním listu: ' + mr.Strings[0],msite);
                                        end;
                                    end;
                               mbo_document.save;
                          finally
                             mbo_document.free;
                          end;
                    end;
                end;
            finally
               mr.free;
            end;

            // Objednávka vydaná
            mr:=TStringList.create;
            try
                mbo.ObjectSpace.SQLSelect('Select Parent_ID||ID from IssuedOrders2 where X_parent_id=' + quotedstr(mbo.GetFieldValueAsString('X_parent_ID')),mr);
                if mr.Count>0 then begin
                    for  i:=0 to mr.Count-1 do begin

                      mbo_document:=mbo.ObjectSpace.CreateObject('CDMK5QAWZZDL342X01C0CX3FCC');
                          try
                              mbo_document.Load(copy(mr.Strings[i],1,10),nil);
                              mMon := mbo_document.GetLoadedCollectionMonikerForFieldCode(mbo_document.GetFieldCode('ROWS'));
                                    for ii := 0 to mMon.Count-1 do begin
                                        mRow := mMon.BusinessObject[ii];
                                        if mRow.GetFieldValueAsstring('X_parent_ID')=mbo.GetFieldValueAsString('X_parent_ID') then begin
                                              mRow.SetFieldValueAsstring('Storecard_ID',mstorecard_id);
                                              mRow.SetFieldValueAsFloat('Quantity',strtofloat(mquantity));
                                              mRow.SetFieldValueAsFloat('Unitrate',1);
                                              //NxShowSimpleMessage('Nahrazení v Objednávce: ' + mr.Strings[0],msite);
                                        end;
                                    end;
                               mbo_document.save;
                          finally
                             mbo_document.free;
                          end;
                    end;
                end;
            finally
               mr.free;
            end;


            // Skladové doklady
            mr:=TStringList.create;
            try
                mbo.ObjectSpace.SQLSelect('Select SD2.Parent_ID||SD2.ID||SD.documenttype from StoreDocuments2 SD2 left join StoreDocuments SD on sd.id=sd2.parent_id where sd2.id=' + quotedstr(mbo.GetFieldValueAsString('X_parent_ID')),mr);
                if mr.Count>0 then begin
                    for  i:=0 to mr.Count-1 do begin
                        if copy(mr.Strings[0],21,2)='20' then begin  // příjemka
                        mbo_document:=mbo.ObjectSpace.CreateObject('E03ZNUMDTCC4PDAUIEY1MBTJC0');
                            try
                                mbo_document.Load(copy(mr.Strings[0],1,10),nil);
                                mMon := mbo_document.GetLoadedCollectionMonikerForFieldCode(mbo_document.GetFieldCode('ROWS'));
                                      for i := 0 to mMon.Count-1 do begin
                                          mRow := mMon.BusinessObject[i];
                                          if mRow.GetFieldValueAsstring('X_parent_ID')=mbo.GetFieldValueAsString('X_parent_ID') then begin
                                              mRow.SetFieldValueAsstring('Storecard_ID',mstorecard_id);
                                              mRow.SetFieldValueAsFloat('Quantity',strtofloat(mquantity));
                                              mRow.SetFieldValueAsFloat('Unitrate',1);
                                                //NxShowSimpleMessage('Nahrazení v příjemce: ' + mr.Strings[0],msite);
                                          end;
                                      end;
                                 mbo_document.save;
                            finally
                               mbo_document.free;
                            end;
                        end;

                        if copy(mr.Strings[0],21,2)='21' then begin  // Dodací list
                        mbo_document:=mbo.ObjectSpace.CreateObject('050I5SAOS3DL3ACU03KIU0CLP4');
                            try
                                mbo_document.Load(copy(mr.Strings[0],1,10),nil);
                                mMon := mbo_document.GetLoadedCollectionMonikerForFieldCode(mbo_document.GetFieldCode('ROWS'));
                                      for i := 0 to mMon.Count-1 do begin
                                          mRow := mMon.BusinessObject[i];
                                          if mRow.GetFieldValueAsstring('X_parent_ID')=mbo.GetFieldValueAsString('X_parent_ID') then begin
                                              mRow.SetFieldValueAsstring('Storecard_ID',mstorecard_id);
                                              mRow.SetFieldValueAsFloat('Quantity',strtofloat(mquantity));
                                              mRow.SetFieldValueAsFloat('Unitrate',1);
                                                //NxShowSimpleMessage('Nahrazení v příjemce: ' + mr.Strings[0],msite);
                                          end;
                                      end;
                                 mbo_document.save;
                            finally
                               mbo_document.free;
                            end;
                        end;

       {                 if copy(mr.Strings[0],21,2)='22' then begin  // Převodka výdej
                        mbo_document:=mbo.ObjectSpace.CreateObject('0P0I5SAOS3DL3ACU03KIU0CLP4');
                            try
                                mbo_document.Load(copy(mr.Strings[0],1,10),nil);
                                mMon := mbo_document.GetLoadedCollectionMonikerForFieldCode(mbo_document.GetFieldCode('ROWS'));
                                      for i := 0 to mMon.Count-1 do begin
                                          mRow := mMon.BusinessObject[i];
                                          if mRow.GetFieldValueAsstring('ID')=mbo.GetFieldValueAsString('X_parent_ID') then begin
                                              mRow.SetFieldValueAsstring('Storecard_ID',mstorecard_id);
                                              mRow.SetFieldValueAsFloat('Quantity',strtofloat(mquantity));
                                              mRow.SetFieldValueAsFloat('Unitrate',1);
                                               // NxShowSimpleMessage('Nahrazení v převodce výdej: ' + mr.Strings[0],msite);
                                          end;
                                      end;
                                 mbo_document.save;
                            finally
                               mbo_document.free;
                            end;
                        end;

                        if copy(mr.Strings[0],21,2)='23' then begin  // Převodka příjem
                        mbo_document:=mbo.ObjectSpace.CreateObject('1D0I5SAOS3DL3ACU03KIU0CLP4');
                            try
                                mbo_document.Load(copy(mr.Strings[0],1,10),nil);
                                mMon := mbo_document.GetLoadedCollectionMonikerForFieldCode(mbo_document.GetFieldCode('ROWS'));
                                      for i := 0 to mMon.Count-1 do begin
                                          mRow := mMon.BusinessObject[i];
                                          if mRow.GetFieldValueAsstring('ID')=mbo.GetFieldValueAsString('X_parent_ID') then begin
                                              mRow.SetFieldValueAsstring('Storecard_ID',mstorecard_id);
                                              mRow.SetFieldValueAsFloat('Quantity',strtofloat(mquantity));
                                              mRow.SetFieldValueAsFloat('Unitrate',1);
                                              //  NxShowSimpleMessage('Nahrazení v převodka příjem: ' + mr.Strings[0],msite);
                                          end;
                                      end;
                                 mbo_document.save;
                            finally
                               mbo_document.free;
                            end;
                        end;
                                       }
                    end;
                end;
            finally
               mr.free;
            end;


        end else begin
            if NxIsEmptyOID(mbo.GetFieldValueAsString('X_parent_ID')) then begin
                 NxShowSimpleMessage('Pohyb není korektně zadán servisem',msite);
            end else begin
                NxShowSimpleMessage('Funkce je dostupná pouze pro kartu "Materiál - dospecifikovat"',msite);
            end;
        End;
    //TDynSiteForm(mSite).RefreshData;
end;







procedure FVExecuteItem(Sender: TMultiAction; Index: integer);
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


//   mOLE:= GetAbraOLEApplication;
//  mOResult:= mOLE.CreateStrings;
//  mRoll:= mOLE.GetRoll('VTVTSC4TZ4S4FBPHST3IVZYOF4', 0);

//  if not mRoll.multiselectdialog(False, mOResult) then Exit;
//        mids:= TStringList.Create;
//        try
//          mids.Text:= mOResult.Text;
//        finally
//        end;



    try
   mstore_ID:='';
   mstav_skladu:=true;
   mcislo:=0;
        mBO_source:= TDynSiteForm(mSite).CurrentObject.ObjectSpace.CreateObject('CDMK5QAWZZDL342X01C0CX3FCC');
        try
             try
                  mlist:=TStringList.create;
                  mRow := TDynSiteForm(mSite).CurrentObject.ObjectSpace.CreateObject('05CPMINJW3DL342X01C0CX3FCC');
                     if index=0 then begin
                       if mBookmark.count=0 then begin

                            mBO_source.Load(TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('parent_ID'),nil);
                                        mMon := mBO_source.GetLoadedCollectionMonikerForFieldCode(mBO_source.GetFieldCode('ROWS'));

                                     for i := 0 to mMon.Count-1 do begin
                                             mRow := mMon.BusinessObject[i];
                                             mPosIndex := mRow.GetFieldValueAsInteger('PosIndex');
                                              if mRow.GetFieldValueAsfloat('Quantity') - mRow.GetFieldValueAsfloat('DeliveredQuantity')>0 then begin
                                                 if (mRow.GetFieldValueAsstring('Store_ID')<>mstore_ID) and (mstore_ID<>'') then mstav_skladu:=false;
                                                   mstore_ID:=(mRow.GetFieldValueAsstring('Store_ID'));
                                                 mList.Add(mRow.OID);

                                              end;
                                      end;

                        end else begin
                            { for ii := 0 to mbookmark.Count-1 do begin
                                  mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(ii));
                                  mBO_source.Load(TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('parent_ID'),nil);
                                        mMon := mBO_source.GetLoadedCollectionMonikerForFieldCode(mBO_source.GetFieldCode('ROWS'));
                                         for i := 0 to mMon.Count-1 do begin
                                              mRow := mMon.BusinessObject[i];
                                              mPosIndex := mRow.GetFieldValueAsInteger('PosIndex');
                                              if mRow.GetFieldValueAsfloat('Quantity') -mRow.GetFieldValueAsfloat('DeliveredQuantity')>0 then begin
                                                  //if not mlist.Find(mRow,(NxPadL(IntToStr(mPosIndex), 6, '0'))) then begin
                                                      mList.AddObject(NxPadL(IntToStr(mPosIndex), 6, '0'), mRow);
                                                  //end;
                                              end;
                                         end;


                             end;}
                         NxShowSimpleMessage('Pro výdej více dokladů není fukce podporována. Použijte převod označených položek',nil);
                        end;

                     end;

                     if index=1 then begin
                       if mBookmark.count=0 then begin
                            mBO_source.Load(TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('parent_ID'),nil);
                                        mMon := mBO_source.GetLoadedCollectionMonikerForFieldCode(mBO_source.GetFieldCode('ROWS'));

                                     for i := 0 to mMon.Count-1 do begin
                                             mRow := mMon.BusinessObject[i];
                                             mPosIndex := mRow.GetFieldValueAsInteger('PosIndex');
                                              if (mRow.GetFieldValueAsfloat('Quantity') -mRow.GetFieldValueAsfloat('DeliveredQuantity')>0) and (mrow.oid=TDynSiteForm(mSite).CurrentObject.OID) then begin
                                                   if (mRow.GetFieldValueAsstring('Store_ID')<>mstore_ID) and (mstore_ID<>'') then mstav_skladu:=false;
                                                   mstore_ID:=(mRow.GetFieldValueAsstring('Store_ID'));
                                                     mList.Add(mRow.OID);
                                              end;
                                      end;
                        end else begin
                             for ii := 0 to mbookmark.Count-1 do begin
                                  mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(ii));
                                  mBO_source.Load(TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('parent_ID'),nil);
                                       //NxShowSimpleMessage(TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('parent_ID'),nil);
                                        mMon := mBO_source.GetLoadedCollectionMonikerForFieldCode(mBO_source.GetFieldCode('ROWS'));
                                         for i := 0 to mMon.Count-1 do begin
                                              mRow := mMon.BusinessObject[i];
                                              mPosIndex := mRow.GetFieldValueAsInteger('PosIndex');
                                              if mRow.oid=TDynSiteForm(mSite).CurrentObject.OID then begin

                                                    if (mRow.GetFieldValueAsfloat('Quantity') -mRow.GetFieldValueAsfloat('DeliveredQuantity')>0) and (mrow.oid=TDynSiteForm(mSite).CurrentObject.OID) then begin
                                                        //if not mlist.Find(mRow,(NxPadL(IntToStr(mPosIndex), 6, '0'))) then begin
                                                        mcislo:=mcislo+1;

                                                              mList.Add(mRow.OID);
                                                                if (mRow.GetFieldValueAsstring('Store_ID')<>mstore_ID) and (mstore_ID<>'') then mstav_skladu:=false;
                                                   mstore_ID:=(mRow.GetFieldValueAsstring('Store_ID'));
                                                        //end;
                                                    end;
                                              end;
                                         end;

                             end;
                        end;

                     end;

                     if index=2 then begin
                           if mBookmark.count=0 then begin
                           mr:=TStringList.create;
                           try
                               mBO_source.ObjectSpace.SQLSelect('select sa2.parent_id from ServiceAssemblyForms2 SA2 where sa2.id=' + quotedstr(TDynSiteForm(mSite).CurrentObject.OID),mr);
                               if mr.count>0 then begin
                                  mID:=mr.Strings[0];
                               end;
                           finally
                               mr.free;
                           end;

                           mr:=TStringList.create;
                           try
                               mBO_source.ObjectSpace.SQLSelect('select io2.id from issuedorders2 io2 left join ServiceAssemblyForms2 SA2 on sa2.id=io2.X_parent_ID where sa2.parent_id='+  quotedstr(mid),mr);



                                     for i := 0 to mr.Count-1 do begin
                                             mRow := TDynSiteForm(mSite).CurrentObject.ObjectSpace.CreateObject('CHMK5QAWZZDL342X01C0CX3FCC');
                                                 mrow.Load(mr.Strings[i],nil);
                                                     mPosIndex := mRow.GetFieldValueAsInteger('PosIndex');
                                                      if mRow.GetFieldValueAsfloat('Quantity') - mRow.GetFieldValueAsfloat('DeliveredQuantity')>0 then begin
                                                         if (mRow.GetFieldValueAsstring('Store_ID')<>mstore_ID) and (mstore_ID<>'') then mstav_skladu:=false;
                                                           mstore_ID:=(mRow.GetFieldValueAsstring('Store_ID'));
                                                         mList.Add(mRow.OID);

                                                      end;
                                      end;
                           finally
                               mr.free;
                           end;
                        end else begin

                         NxShowSimpleMessage('Pro výdej více ml není fukce podporována. Použijte převod označených položek',nil);
                        end;

                     end;



                     mrow.free;

                   try
                           mRow := TDynSiteForm(mSite).CurrentObject.ObjectSpace.CreateObject('CHMK5QAWZZDL342X01C0CX3FCC');

                           if mlist.count>0 then begin
                               if mstav_skladu=true then begin
                                mList.Sort;
                                        mBO_target := TDynSiteForm(mSite).CurrentObject.ObjectSpace.CreateObject('0P0I5SAOS3DL3ACU03KIU0CLP4');
                                            mBO_target.New;
                                            mBO_target.Prefill;
                                            mBO_target.SetFieldValueAsString('Firm_ID', 'CXC0000101');
                                            mBO_target.SetFieldValueAsString('DocQueue_ID', '7F00000101');
                                           // mBO_target.SetFieldValueAsString('X_doprava', mids.Text);
                                        mMon := mBO_target.GetLoadedCollectionMonikerForFieldCode(mBO_target.GetFieldCode('ROWS'));
                                        for i := 0 to mList.Count-1 do begin
                                              mRow.Load(mList.Strings[i],nil);
                                                // dohrání rozdílů
                                                        mNewRow := mMon.AddNewObject;
                                                        mNewRow.SetFieldValueAsInteger('RowType', mRow.GetFieldValueAsInteger('RowType'));
                                                        mNewRow.SetFieldValueAsString('Store_ID', 'M000000101');
                                                        mNewRow.SetFieldValueAsString('StoreCard_ID', mRow.GetFieldValueAsString('StoreCard_ID'));
                                                        mNewRow.SetFieldValueAsString('QUnit', mRow.GetFieldValueAsString('QUnit'));
                                                        mNewRow.SetFieldValueAsFLoat('UnitRate', mRow.GetFieldValueAsFloat('UnitRate'));
                                                        mNewRow.SetFieldValueAsFLoat('Quantity', mRow.GetFieldValueAsFloat('Quantity'));
                                                        mNewRow.SetFieldValueAsString('Text', mRow.GetFieldValueAsString('Text'));
                                                        mNewRow.SetFieldValueAsString('Division_ID', mRow.GetFieldValueAsString('Division_ID'));
                                                        mNewRow.SetFieldValueAsString('BusOrder_ID', mRow.GetFieldValueAsString('BusOrder_ID'));
                                                        mNewRow.SetFieldValueAsString('BusTransaction_ID', mRow.GetFieldValueAsString('BusTransaction_ID'));
                                                        mNewRow.SetFieldValueAsString('X_parent_ID', mRow.GetFieldValueAsString('X_parent_ID'));

                                        end;
                                        mBO_target.SetFieldValueAsString('Description', mRow.GetFieldValueAsString('Parent_ID.Description'));
                                        mBO_target.SetFieldValueAsString('IncomingTransferStore',mRow.GetFieldValueAsString('Store_ID'));
                                        mBO_target.SetFieldValueAsString('IncomingTransferStore',mRow.GetFieldValueAsString('Store_ID'));
                                        TDynSiteForm.ShowDynFormWithNewDocument('BD0I5SAOS3DL3ACU03KIU0CLP4', mForm.SiteContext, mBO_target);
                                        mBO_target.free;
                                  end else begin
                                      NxShowSimpleMessage('Není možné převádět jedním dokladem na více skladů',nil);
                                  end;
                           end else begin

                                 NxShowSimpleMessage('Není žádná položka přo převod',nil);
                           end;
                        finally
                            mRow.free;
                        end;
                  finally

            end;
      finally

      end;
    finally
      mBO_source.free;
                      mlist.free;
    end;
   TDynSiteForm(mSite).RefreshData;
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
  mMAction.Caption := 'Převod na sklad technika';
  mMAction.Hint := 'Vytvoří převodku na sklad technika';
  mMAction.Category := 'tabList';
  mMAction.OnExecuteItem := @FVExecuteItem;
  mMAction.Items.Add('Převod celého dokladu');
  mMAction.Items.Add('Převod jen vybraných položek');
  mMAction.Items.Add('Převod možných položek dle ML');

  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Dospecifikování karty';
  mMAction.Hint := 'Nahradí kartu na neuzavřených skladových a servisních dokaldech';
  mMAction.Category := 'tabList';
  mMAction.OnExecuteItem := @StorecardExecuteItem;
  mMAction.Items.Add('Nahrazení skladové karty');

end;


begin
end.