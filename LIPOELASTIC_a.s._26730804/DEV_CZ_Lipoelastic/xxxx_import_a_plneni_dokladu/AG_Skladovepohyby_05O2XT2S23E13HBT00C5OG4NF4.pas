uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse';
const
    mFilter='*.xml';

  Var
  mSite : TSiteForm;

  i,ii : integer;
  mID: String;
  x:integer;
  mrResult:string;
  mrow: TNxCustomBusinessObject;
  mMon : TNxCustomBusinessMonikerCollection;
  mList,mRowList:TStringList;
  mtext:string;
  mXMLHead : TNxScriptingXMLWrapper;
  mr:tstringlist;
  os:TNxCustomObjectSpace;
  mWorkList:TStringList;

function ZpracujImport(msite:TDynSiteForm;index:integer;mWorkList:tstringlist):string;
var
mHead:TNxHeaderBusinessObject;
   mBO_Row:TNxCustomBusinessObject;
   mRow:TNxCustomBusinessObject;
   mbo:TNxCustomBusinessObject;
   mMonBatches,mMonSoutceBatches:TNxCustomBusinessMonikerCollection;
   mRowDocRowBatches:TNxCustomBusinessObject;
   i,ii:integer;
   mForm: TDynSiteForm;
   mtext:string;
   mB_Result:boolean;
   mi:integer;
   mValidateList:tstringlist;
   mStorecard_ID,mStoreBatch_ID,mStore_ID,mDivision_ID,mBusOrder_ID,mBusTransaction_ID,mBusProject_ID:string;
   mQuantity:double;
begin

      if index=0 then mHead := TNxHeaderBusinessObject(mSite.BaseObjectSpace.CreateObject('E03ZNUMDTCC4PDAUIEY1MBTJC0'));
     if index=1 then mHead := TNxHeaderBusinessObject(mSite.BaseObjectSpace.CreateObject('050I5SAOS3DL3ACU03KIU0CLP4'));
     if index=2 then mHead := TNxHeaderBusinessObject(mSite.BaseObjectSpace.CreateObject('0P0I5SAOS3DL3ACU03KIU0CLP4'));

    try
      mHead.New;
      mHead.Prefill;
     if index=0 then mHead.SetFieldValueAsString('DocQueue_ID', '7700000101');
     if index=1 then mHead.SetFieldValueAsString('DocQueue_ID', '8700000101');
     if index=2 then mHead.SetFieldValueAsString('DocQueue_ID', '9700000101');
            mBO_Row := TDynSiteForm(mSite).CurrentObject;
            mHead.SetFieldValueAsString('Firm_ID', TDynSiteForm(mSite).CurrentObject.GetFieldValueAsString('Parent_id.Firm_ID'));

            for i:=0 to mWorkList.count-1 do begin





                        mStorecard_ID:=copy(mWorkList.Strings[i],1,10);
                        mStoreBatch_ID:=copy(mWorkList.Strings[i],12,10);
                        mStore_ID:=copy(mWorkList.Strings[i],23,10);
                        mDivision_ID:=copy(mWorkList.Strings[i],34,10);
                        mBusOrder_ID:=copy(mWorkList.Strings[i],45,10);
                        mBusTransaction_ID:=copy(mWorkList.Strings[i],56,10);
                        mBusProject_ID:=copy(mWorkList.Strings[i],67,10);
                        mQuantity:=NxIBStrToFloat(copy(mWorkList.Strings[i],78,10));

            {
            NxShowSimpleMessage(mStorecard_ID,nil);
            NxShowSimpleMessage(mStoreBatch_ID,nil);
            NxShowSimpleMessage(mStore_ID,nil);
            NxShowSimpleMessage(mBusOrder_ID,nil);
            NxShowSimpleMessage(mBusTransaction_ID,nil);
            NxShowSimpleMessage(mBusProject_ID,nil);
            NxShowSimpleMessage(NxFloatToIBStr(mQuantity),nil);
             }

                        mRow := mhead.Rows.AddNewObject;
                        mRow.Prefill;
                        mRow.SetFieldValueAsInteger('RowType',3);
                        //if mStorecard_ID<>'0000000000' then
                        mRow.SetFieldValueAsString('Store_ID',mStore_ID);
                        //else mRow.SetFieldValueAsString('Store_ID',TDynSiteForm(msite).CurrentObject.GetFieldValueAsString('Store_ID')) ;
                        //if mStorecard_ID<>'0000000000' then
                        mRow.SetFieldValueAsString('Storecard_ID',mStorecard_ID);
                        //else mRow.SetFieldValueAsString('Storecard_ID',TDynSiteForm(msite).CurrentObject.GetFieldValueAsString('Storecard_ID')) ;
                        mRow.SetFieldValueAsFloat('Quantity',mQuantity);
                        //if mDivision_ID<>'0000000000' then
                        mRow.SetFieldValueAsString('Division_ID',mDivision_ID);
                        //else mRow.SetFieldValueAsString('Division_ID',TDynSiteForm(msite).CurrentObject.GetFieldValueAsString('Division_ID')) ;
                        //if mBusOrder_ID<>'0000000000' then
                        //mRow.SetFieldValueAsString('BusOrder_ID',mBusOrder_ID);
                        //else mRow.SetFieldValueAsString('BusOrder_ID',TDynSiteForm(msite).CurrentObject.GetFieldValueAsString('BusOrder_ID')) ;
                        //if mBusTransaction_ID<>'0000000000' then
                        //mRow.SetFieldValueAsString('BusTransaction_ID',mBusTransaction_ID);
                        //else mRow.SetFieldValueAsString('BusTransaction_ID',TDynSiteForm(msite).CurrentObject.GetFieldValueAsString('BusTransaction_ID')) ;
                        //if mBusProject_ID<>'0000000000' then
                        //mRow.SetFieldValueAsString('BusProject_ID',mBusProject_ID);
                        //else mRow.SetFieldValueAsString('BusProject_ID',TDynSiteForm(msite).CurrentObject.GetFieldValueAsString('BusProject_ID')) ;


                        if (mRow.getFieldValueAsinteger('Storecard_ID.Category')=1) or (mRow.getFieldValueAsinteger('Storecard_ID.Category')=2) then begin    // pokud se jedná o šarže
                           if mStoreBatch_ID<>'0000000000' then begin
                               mMonBatches := mrow.GetLoadedCollectionMonikerForFieldCode(mrow.GetFieldCode('DocRowBatches'));

                                            mMonBatches := mrow.GetLoadedCollectionMonikerForFieldCode(mrow.GetFieldCode('DocRowBatches'));
                                                    mRowDocRowBatches := mMonBatches.AddNewObject;
                                                    mRowDocRowBatches.Prefill;
                                                    mRowDocRowBatches.SetFieldValueAsBoolean('NewBatch',False);
                                                    mRowDocRowBatches.SetFieldValueAsString('StoreBatch_ID',mStoreBatch_ID);
                                                    mRowDocRowBatches.SetFieldValueAsFloat('Quantity',mQuantity);

                           end;

                         end;
            end;

                  // * *********** ukládáni souboru
                  mHead.ClearValidateErrors;
                  if NOT mHead.Validate() then begin
                        mValidateList := TStringList.Create;
                        try
                           mHead.GetValidateErrors(mValidateList);
                           mText := mValidateList.Text;
                           NxToken(mText, '=');
                           MessageDlg('Automaticky vytvořený doklad nelze uložit z těchto důvodů:' + #13#10 + mText,

                           mtWarning, [mbOK], 0);
                         finally
                           mValidateList.Free;
                         end;
                         //NxShowSimpleMessage('Chyba',nil);


                         if index =0 then TDynSiteForm(msite).ShowDynFormWithNewDocument('B10I5SAOS3DL3ACU03KIU0CLP4', TDynSiteForm(mSite).SiteContext, mHead);
                         if index =1 then TDynSiteForm(msite).ShowDynFormWithNewDocument('B50I5SAOS3DL3ACU03KIU0CLP4', TDynSiteForm(mSite).SiteContext, mHead);
                         if index =2 then TDynSiteForm(msite).ShowDynFormWithNewDocument('BD0I5SAOS3DL3ACU03KIU0CLP4', TDynSiteForm(mSite).SiteContext, mHead);
                        // result:='Chyba';
                  end else begin
                       mHead.Save;
                       result:=mhead.oid;
                   end;

  finally
      mhead.free;
  end;
end;




procedure ImportFromFile(Sender: TComponent;index:integer);
var
  zadej:string;
  mfilename:string;
  mdir,mfile:string;
  mWorkList:TStringList;
  mImportFile:TStringList;
  mbatch_ID,mStoreCard_ID:string;
  mquantity:double;
begin
  mdir:='';
  mfile:='';

 mSite := NxFindSiteForm(TComponent(Sender));
   if PromptForFileName(mFileName, mfilter, '', 'Soubory SP', mdir, False) then begin
    mdir:=copy(mfilename,0,NxCharPosR('\',mfilename));
    mFile:=copy(mfilename,1+NxCharPosR('\',mfilename),Length(mfilename));
   end ;

  //ImportFile(TDynSiteForm(mSite).CurrentObject.ObjectSpace, mfilename, mdir,mfile);
// Import_FVDV(msite.baseobjectspace, mfilename, mdir,mfile,msite,true,false,index);
if not FileExists(mfilename) then begin   // soubor nenalezen
      NxShowSimpleMessage('Soubor nedeohledán',nil);
      exit;
    end;
  mWorkList:=tstringlist.create;
  try
     if RightStr(mfilename,4)='.xml' then begin
      NxShowSimpleMessage('XML',nil);
           mXMLHead := TNxScriptingXMLWrapper.Create;
           try
              mXMLHead.loadFromFile(mFileName);
                for i := 0 to mXMLHead.getElementsCountInArray('Doc.Row') - 1 do begin
                          ProgressSetPos(1+NxFloor(i/mXMLHead.getElementsCountInArray('Doc.Row')*99), inttostr(i) +' z '+inttostr(mXMLHead.getElementsCountInArray('Doc.Row')));
                          for ii := 0 to mXMLHead.getElementsCountInArray('Doc.Row['+inttostr(i)+'].batch') - 1 do begin

                                    mbatch_ID:='0000000000';
                                    mStoreCard_ID:='0000000000';
                                  if mXMLHead.getElementAsString('Doc.Row['+inttostr(i)+'].batch['+inttostr(ii)+'].name')<>'' then begin       // je uvedena šarže
                                          mr:= tstringlist.Create;   // ***** dohledání šarže
                                          try
                                             os.SQLSelect('SELECT id||StoreCard_ID from StoreBatches SB WHERE sb.hidden=' +quotedstr('N') + ' and sb.name = ' + quotedstr(mXMLHead.getElementAsString('Doc.Row['+inttostr(i)+'].batch['+inttostr(ii)+'].name')),mr);
                                             if mr.count>0 then begin
                                                  mbatch_ID:=copy(mr.Strings[0],1,10);
                                                  mStoreCard_ID:=copy(mr.Strings[0],11,10);
                                                  mquantity:=NxIBStrToFloat(mXMLHead.getElementAsString('Doc.Row['+inttostr(i)+'].batch['+inttostr(ii)+'].quantity'));
                                             end else begin
                                                  mbatch_ID:='0000000000';
                                                  mStoreCard_ID:='0000000000';
                                             end;
                                          finally
                                              mr.free;
                                          end ;

                                    end;

                                    if mStoreCard_ID='' then begin ;
                                        mr:= tstringlist.Create;   // ***** dohledání šarže
                                          try
                                             os.SQLSelect('SELECT sc.id from StoreCards SC WHERE sb.hidden=' +quotedstr('N') + ' and sc.EAN = ' + quotedstr(mXMLHead.getElementAsString('Doc.Row['+inttostr(i)+'].ean')),mr);
                                             if mr.count>0 then begin
                                                        mStoreCard_ID:=mr.Strings[0];
                                                        mquantity:=NxIBStrToFloat(mXMLHead.getElementAsString('Doc.Row['+inttostr(i)+'].batch['+inttostr(ii)+'].quantity'));
                                             end else begin
                                                  mStoreCard_ID:='0000000000';
                                             end;
                                          finally
                                              mr.free;
                                          end ;


                                    end;
                                 if (mStoreCard_ID)<>'' then begin
                                      mWorkList.add(mStoreCard_ID+';'+
                                                      mbatch_ID+';'+
                                                      '0000000000'+';'+
                                                      '0000000000'+';'+
                                                      '0000000000'+';'+
                                                      '0000000000'+';'+
                                                      '0000000000'+';'+
                                                     NxFloatToIBStr(mquantity));

                                end;
                          end;   //ii
                end;   // i

           finally
              mXMLHead.free;
           end;

     end;

  if RightStr(mfilename,4)='.csv' then begin
      NxShowSimpleMessage('csv',nil);

  end;

       NxShowSimpleMessage(inttostr(mWorkList.count),nil);


 finally
      mWorkList.free;
 end;
 msite.Refresh;

end;



{
Vyvolává se po provedení inicializace agendy/formuláře. V tento okamžik je již na formuláři dostupný SiteContext.
}
procedure InitSite_Hook(Self: TSiteForm);
 var
 mMAction: TMultiAction;
  mAction: TBasicAction;
  mAList: TActionList;
  i: integer;
  mAct: TBasicAction;
  mUser : TNxCustomBusinessObject;
begin

if not Assigned(Self.BaseObjectSpace) then
    exit;
  mUser := Self.BaseObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');
  mUser.Load(Self.CompanyCache.GetUserID, nil);
 // if copy(mUser.GetFieldValueAsstring('X_Parametr'),1,1)='1' then begin
           mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Nový doklad vyběrěm';
          mMAction.Caption := 'Novy doklad vyběrem';
          mMAction.Items.Add('Příjemka');
          mMAction.Items.Add('Dodací list');
          mMAction.Items.Add('Převodka výdej');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @ImportVyberem;

          mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Import from file';
          mMAction.Caption := 'import z souboru';
          mMAction.Items.Add('Příjemka');
          mMAction.Items.Add('Dodací list');
          mMAction.Items.Add('Převodka');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @ImportFromFile;


 // end;
end;





procedure ImportVyberem(Sender: TComponent;index:integer);
var
 mHead:TNxHeaderBusinessObject;
   mBO_Row:TNxCustomBusinessObject;
   mRow:TNxCustomBusinessObject;
   mbo:TNxCustomBusinessObject;
   mMonBatches,mMonSoutceBatches:TNxCustomBusinessMonikerCollection;
   mRowDocRowBatches:TNxCustomBusinessObject;
 mSite: TDynSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 i,ii:integer;
   mForm: TDynSiteForm;
   mtext:string;
   mB_Result:boolean;
   mi:integer;
   mValidateList:tstringlist;
   mBookmark:TBookmarkList;
   mWorkList:tstringlist;
   mDoc_id:string;
begin
 // mtext:='Description=' + quotedstr('');
  msite:=TComponent(Sender).DynSite;
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    //NxShowSimpleMessage('AA',nil);
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    mWorkList:=TStringList.create;
    //NxShowSimpleMessage('bb',nil);
    mbo:= TDynSiteForm(mSite).CurrentObject;
    //mB_Result:=InputQuery('Zadaj parametry', 'Změna ', mtext);

    ProgressInit(msite, 'Načtení Dat z řádků ' , 100);

                  //NxShowSimpleMessage('cc',nil);
                  if mBookmark.Count=0 then begin
                        NxShowSimpleMessage('dd',nil);
                        mRow := TDynSiteForm(mSite).CurrentObject;
                        if (mRow.getFieldValueAsinteger('Storecard_ID.Category')=0) or (mRow.getFieldValueAsinteger('Storecard_ID.Category')=4) then begin    // nejsou šarže
                                  mWorkList.add(mBO_Row.GetFieldValueAsString('Storecard_ID')+';'+
                                      '0000000000;'+
                                      mRow.GetFieldValueAsString('Store_ID')+';'+
                                      mRow.GetFieldValueAsString('Division_ID')+';'+
                                      mRow.GetFieldValueAsString('BusOrder_ID')+';'+
                                      mRow.GetFieldValueAsString('BusTransaction_ID')+';'+
                                      mRow.GetFieldValueAsString('BusProject_ID')+';'+
                                      NxFloatToIBStr(mRow.GetFieldValueAsFloat('Quantity')));
                                      //NxShowSimpleMessage('ee',nil);
                         end else begin            // ****** jsou šarže
                            mMonSoutceBatches := mRow.GetLoadedCollectionMonikerForFieldCode(mRow.GetFieldCode('DocRowBatches'));
                                for ii:=0 to mMonSoutceBatches.count-1 do begin
                                           //NxShowSimpleMessage('ff',nil);
                                      mWorkList.add(mRow.GetFieldValueAsString('Storecard_ID')+';'+
                                            mMonSoutceBatches.businessObject[ii].GetFieldValueAsString('StoreBatch_ID')+';'+
                                            mRow.GetFieldValueAsString('Store_ID')+';'+
                                            mRow.GetFieldValueAsString('Division_ID')+';'+
                                            mRow.GetFieldValueAsString('BusOrder_ID')+';'+
                                            mRow.GetFieldValueAsString('BusTransaction_ID')+';'+
                                            mRow.GetFieldValueAsString('BusProject_ID')+';'+
                                           NxFloatToIBStr(mMonSoutceBatches.businessObject[ii].GetFieldValueAsfloat('Quantity')));
                                end;
                         end;

                  end else begin
                          for i := 0 to mBookmark.Count-1 do begin // projdu vsechny oznacene zaznamy
                                  ProgressSetPos(1+NxFloor(i/mBookmark.Count*99), inttostr(i) +' z '+inttostr(mBookmark.Count));

                                  mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(i));
                                  mRow := TDynSiteForm(mSite).CurrentObject;
                        if (mRow.getFieldValueAsinteger('Storecard_ID.Category')=0) or (mRow.getFieldValueAsinteger('Storecard_ID.Category')=4) then begin    // nejsou šarže
                                  mWorkList.add(mBO_Row.GetFieldValueAsString('Storecard_ID')+';'+
                                      '0000000000;'+
                                      mRow.GetFieldValueAsString('Store_ID')+';'+
                                      mRow.GetFieldValueAsString('Division_ID')+';'+
                                      mRow.GetFieldValueAsString('BusOrder_ID')+';'+
                                      mRow.GetFieldValueAsString('BusTransaction_ID')+';'+
                                      mRow.GetFieldValueAsString('BusProject_ID')+';'+
                                      NxFloatToIBStr(mRow.GetFieldValueAsFloat('Quantity')));
                                      //NxShowSimpleMessage('ee',nil);
                         end else begin            // ****** jsou šarže
                            mMonSoutceBatches := mRow.GetLoadedCollectionMonikerForFieldCode(mRow.GetFieldCode('DocRowBatches'));
                                for ii:=0 to mMonSoutceBatches.count-1 do begin
                                  //         NxShowSimpleMessage('ff',nil);
                                      mWorkList.add(mRow.GetFieldValueAsString('Storecard_ID')+';'+
                                            mMonSoutceBatches.businessObject[ii].GetFieldValueAsString('StoreBatch_ID')+';'+
                                            mRow.GetFieldValueAsString('Store_ID')+';'+
                                            mRow.GetFieldValueAsString('Division_ID')+';'+
                                            mRow.GetFieldValueAsString('BusOrder_ID')+';'+
                                            mRow.GetFieldValueAsString('BusTransaction_ID')+';'+
                                            mRow.GetFieldValueAsString('BusProject_ID')+';'+
                                           NxFloatToIBStr(mMonSoutceBatches.businessObject[ii].GetFieldValueAsfloat('Quantity')));
                                end;
                         end;

                          end;
                  end;
              //    NxShowSimpleMessage('gg',nil);
  mdoc_id:=ZpracujImport(msite,index,mWorkList);



            mWorkList.free;
ProgressDispose() ;

end;




begin
end.




