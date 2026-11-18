uses  '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse';

     Var
mTyp_obchodu:string;
mfilter:string;
  mXMLHead : TNxScriptingXMLWrapper;
  mSite : TSiteForm;
  mDoklad : string;
  i,ii : integer;
  mres,mres1,mr2: TStringList;
  mID: String;
  aaaaa: string;
  x:integer;
  aa:Double;
  mrResult:string;
  mfirm,mfirm_office: TNxCustomBusinessObject;
  mrow: TNxCustomBusinessObject;
  mbusorder: TNxCustomBusinessObject;
  maddress: TNxCustomBusinessObject;
  mBO_SP: TNxCustomBusinessObject;
  mID_Store,mID_StoreCard,mIDdoklad,mID_odberatel, mID_dodavatel, mID_Docqueue, mID_BusOrder, mID_VatCountry,mID_Country, mID_Currency,mID_Vatrate,mID_Row: string;
  aresult:Boolean;
  mexistuje:string;
  oprava : boolean;
  mMon : TNxCustomBusinessMonikerCollection;
   mForm : TForm;
  mBtn : TButton;
  mLbl : TLabel;
  mEdtIC, mEdtDIC,mEdtName,mEdtStreet,mEdtCity,mEdtPostCode,mEdtCountry : TEdit;
  cbSrcUnits, cbDstUnits, cbStores, cbDivisions : TEdit;
  mP1, mP2, mP3 : TPanel;
  mI_modalresult:integer;
  mS_code:string;
  mList,mRowList:TStringList;
  mtext:string;
  mID_kost_symbol,mID_payment,mID_delivery:string;
  mCountryName:string;
  mtoESL:boolean;
  mBO_Storecard:TNxCustomBusinessObject;
  mMonUnits:TNxCustomBusinessMonikerCollection;



  procedure AppendBatches(Sender: TComponent;index:integer);
var

  zadej:string;
  mfilename:string;
  mdir,mfile,mpathTarget:string;
  mr:TStringList;
  mresult:boolean;
  mMon,mMonBatches:TNxCustomBusinessMonikerCollection;
  mbo,mBORow,mBOBatch:TNxCustomBusinessObject;
  i,j:integer;
  mNeedQty,mFilledQty,mQuantity:double;
  mResults:tstringlist;
  mexist:double;
  mSQL:string;
  mb:Boolean;
begin
 mSite := NxFindSiteForm(TComponent(Sender));
//      if not TDynSiteForm(mSite).Edit then begin
//        ShowMessage('Akce importu je přístupná jen v editaci dokladu.');
//        Exit;
//      end else begin

                     mbo:=TDynSiteForm(msite).CurrentObject;
                      ProgressInit(msite, 'Doplnění šarží ' , 100);
                     try
                          mMon := mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('ROWS'));

                                      for j:= 0 to mMon.count -1 do begin
                                           ProgressSetPos(1+NxFloor(j/mMon.count), inttostr(j) +' z '+inttostr(mMon.count));
                                                                        mexist:=0;
                                                                          mBORow:=mMon.BusinessObject[j];
                                                                          if (mBORow.GetFieldValueAsInteger('RowType')=3) then begin
                                                                            if (mBORow.GetFieldValueAsInteger('StoreCard_ID.Category')=2) then begin
                                                                             // NxShowSimpleMessage('kolik?: ' + mSQL,nil) ;
                                                                                  mNeedQty:=mBORow.GetFieldValueAsFloat('Quantity');
                                                                                  mr:=TStringList.Create;
                                                                                     try

                                                                                            msite.baseobjectspace.SQLSelect('Select sum(quantity) from docrowbatches where Parent_ID=' + quotedstr(mBORow.oid),mr);
                                                                                            if mr.count>0 then begin
                                                                                                  mexist:=NxIBStrToFloat(mr.Strings[0]);
                                                                                            end else begin
                                                                                                  mexist:=0;
                                                                                            end;
                                                                                     finally
                                                                                          mr.free;
                                                                                     end;

                                                                                    if mexist<> mNeedQty then begin
                                                                                                  mNeedQty:=mNeedQty-mexist;
                                                                                                  mFilledQty:=0;
                                                                                                   mResults:=TStringList.Create;
                                                                                                   try

                                                                                                          if index=0 then begin
                                                                                                                mSQL:='select sb.id || ''='' || sb2.quantity  from storecards sc ' +
                                                                                                                           'join storesubcards sc2 on sc.id=sc2.storecard_id ' +
                                                                                                                           'join storebatches sb on sc.id=sb.storecard_id ' +
                                                                                                                           'join storesubbatches sb2 on sb2.storebatch_id=sb.id ' +
                                                                                                                           'where sc2.storecard_id=''%s'' and sc2.store_id=''%s'' and sb2.quantity>0 order by sb2.quantity desc' ;
                                                                                                                 msite.baseobjectspace.SQLSelect(Format(mSQL,[mBORow.GetFieldValueAsString('StoreCard_ID'),mBORow.GetFieldValueAsString('Store_ID')]),mResults);
                                                                                                            end;

                                                                                                           if index=1 then begin
                                                                                                                mSQL:='select drb.StoreBatch_ID || ''=''  || DRB.Quantity  from storebatches SB ' +
                                                                                                                       'left join DocRowBatches DRB on drb.StoreBatch_ID=sb.id ' +
                                                                                                                       'left join StoreDocuments2 sd2 on sd2.id=drb.parent_ID ' +
                                                                                                                       'left join StoreDocuments sd on sd.id=sd2.parent_ID ' +
                                                                                                                       'where sb.storecard_id=''%s'' and (sd.DocumentType=''%s'' and sd.Firm_ID=''%s'') order by sd2.quantity desc' ;

                                                                                                              //mb:=InputQuery('AA','BB',(Format(mSQL,[mBORow.GetFieldValueAsString('StoreCard_ID'),'21',mBORow.GetFieldValueAsString('Parent_ID.Firm_ID')] )));
                                                                                                                msite.baseobjectspace.SQLSelect(Format(mSQL,[mBORow.GetFieldValueAsString('StoreCard_ID'),'21',mBORow.GetFieldValueAsString('Parent_ID.Firm_ID')]),mResults);
                                                                                                            end;

                                                                                                          if mResults.Count>0 then begin
                                                                                                                for i:= 0 to mResults.Count-1 do begin
                                                                                                                    mBOBatch:=mBORow.GetLoadedCollectionMonikerForFieldCode(mBORow.GetFieldCode('DocRowBatches')).AddNewObject;
                                                                                                                    mBOBatch.SetFieldValueAsString('StoreBatch_ID',mResults.Names[i]); //ID šarže
                                                                                                                    mQuantity:=NxIBStrToFloat(mResults.ValueFromIndex[i]); //množství na šarži
                                                                                                                    if mQuantity >= mNeedQty then begin
                                                                                                                      mBOBatch.SetFieldValueAsFloat('Quantity',mNeedQty);
                                                                                                                      mNeedQty := 0;
                                                                                                                    end else begin
                                                                                                                      mBOBatch.SetFieldValueAsFloat('Quantity',mQuantity);
                                                                                                                      mNeedQty := mNeedQty - mQuantity;
                                                                                                                    end;
                                                                                                                    if mNeedQty<=0 then break;
                                                                                                                end;
                                                                                                          end;
                                                                                                   finally
                                                                                                      mResults.free;
                                                                                                   end;

                                                                                    end;
                                                                            // NxShowSimpleMessage('quantity' + mSQL,nil) ;
                                                                            end;



                                            end;
                                      end;

                     finally
                           ProgressDispose();
                     end;




end;





  function CreateDocImport(OS: TNxCustomObjectSpace; AFileName: string;directory: string;filename: string;msite:TSiteForm;rucne:boolean;chyba:boolean;index:integer) : Boolean;
var
    oprava : boolean;
    mImportFile:TStringList;
    mTargetFile,mrx:TStringList;
    mRowList:TStringList;
    mFieldHead,mFieldConst,mFieldLabel,mFieldType,mFieldLenght,mfieldValue,mFieldTable,mFieldCLSID,mFieldField,mFieldCreate,mFieldBo:TStringList;
    mDoc,mDocHead : TNxParameters;
    mStr : string;
    mSList : TStrings;
    Head: String;
    Rows: TStringDynArray;
    pozice:integer;
    zapis:boolean;
    mid :string;
    mtable:string;
    id1,id2,id3,id4,id5,id6,id7,id8,id9:string;
    mExist_ID:string;
    mUserFields:Boolean;
    aa:string;
    mstart:integer;
    mstav:string;
    mStav_ID:string;
    pocet_new,pocet_upd,pocet_err:integer;
    mresult:Boolean;
    mr,mr1,mr_head:TStringList;
    mCustomBusinessObject:TNxCustomBusinessObject;
    mzacatek:boolean;
    moddelovac:string;
    mstartparam:integer;
    mBO_DF,mBO1_DF,mBO_BusOrder:TNxCustomBusinessObject;
    mean,mStoreCard_ID:string;
    mquantity:double;
    mOLEStorecard, mRollStorecard, mOResultStorecard: Variant;
    mOLEBusOrder, mRollBusOrder, mOResultBusOrder: Variant;
   midsStore,midsStorecard:TStringList;
   midsBusOrder:TStringList;
  mGrid: TdbGrid;
  mControl: TControl;
  mDataSource: TDataSource;
  mDataset: TNxRowsObjectDataSet;
  mid_Storecard,mid_BusOrder:string;
  mRows,mBOMoniker:TNxCustomBusinessMonikerCollection;
  mNewRow:TNxCustomBusinessObject;
  mscname:string;
  mskladnik,mprevzal:string;
  xresult:Boolean;
  mForm : TForm;
  mBtn : TButton;
  mLbl : TLabel;
  mCedAccountingType:TRollComboEdit ;
  mCedAccountingType2:TRollComboEdit ;
  mCedAccountingType3:TRollComboEdit ;
  mCbCc:TComboBevel;
  mCb:TRollComboEdit;
  mLabel1,mLabel2,mLabel3:TLabel;
  mTEdit1,mTEdit2,mTEdit3:TEdit;
  mID_FIRM,mID_person,mID_division:string;
  Mpoz1,mpoz2,mpoz3:string;
  cbPerson: TComboBox;//TRollComboEdit;
  mRow,  mStoreCard,mdocrowbatches : TNxCustomBusinessObject;
  mCnts,mBO_Moniker,mRowsOutput : TNxCustomBusinessMonikerCollection;
  i,iii, j ,ix: integer;
  mids_storeunits:TStringList;
  mstorecontainer,mRowDocRowBatches:TNxCustomBusinessObject;
  mlist,mlist2:TStringList;
  mFirm_ID,mBatch_ID:string;
  mpos:integer;
  mToken:string;
  mChangeBatch,max:TStringList;
  mShowProgres:Boolean;
  mline:string;
  mPrubezneQuantity,mpomocQuantity:double;
  mImportMan: TNxDocumentImportManager;
  mParams: TNxParameters;
  mParam: TNxParameter;
  mSave:boolean;
  mvraceno:double;
  mMonBatches:TNxCustomBusinessMonikerCollection;
  mSelectedRows:String;
  mlist1:tstringlist;
  mb:Boolean;
  mID_Docqueue_ID,mstore_id:string;
  mhead: TNxHeaderBusinessObject;
  mWorkList:tstringlist;
  mCLSBO:string;
  magenda:string;
begin
    mCLSBO:='E03ZNUMDTCC4PDAUIEY1MBTJC0';
    magenda:='B10I5SAOS3DL3ACU03KIU0CLP4';
    mShowProgres:=true;
    mList:=tstringlist.create;

    if not FileExists(AFileName) then begin   // soubor nenalezen
      NxShowSimpleMessage('Soubor nedeohledán',nil);
      Result := False;
      exit;
    end;
    mWorkList:=tstringlist.create;

    mID_Division:='1N00000101';
    mID_Docqueue_ID:= '1B00000101';
    mID_odberatel:=TDynSiteForm(msite).CurrentObject.GetFieldValueAsString('Firm_ID');

    mstore_id:='4B30000101';

    if (index=0) or (index=1) then begin
                           mXMLHead := TNxScriptingXMLWrapper.Create;
                               try
                                   mXMLHead.loadFromFile(AFileName);
                                       if mShowProgres then ProgressInit(msite, 'Načtení souboru ' + FileName, 100);


                                       for i := 0 to mXMLHead.getElementsCountInArray('Doc.Row') - 1 do begin
                                            if mShowProgres then ProgressSetPos(1+NxFloor(i/mXMLHead.getElementsCountInArray('Doc.Row')*99), inttostr(i) +' z '+inttostr(mXMLHead.getElementsCountInArray('Doc.Row')));
                                          for ii := 0 to mXMLHead.getElementsCountInArray('Doc.Row['+inttostr(i)+'].batch') - 1 do begin

                                                    mbatch_ID:='0000000000';
                                                    mStoreCard_ID:='0000000000';
                                                  if mXMLHead.getElementAsString('Doc.Row['+inttostr(i)+'].batch['+inttostr(ii)+'].name')<>'' then begin
                                                          mr:= tstringlist.Create;   // ***** dohledání šarže
                                                          try
                                                             os.SQLSelect('SELECT id||StoreCard_ID from StoreBatches SB WHERE sb.name = ' + quotedstr(mXMLHead.getElementAsString('Doc.Row['+inttostr(i)+'].batch['+inttostr(ii)+'].name')),mr);
                                                             if mr.count>0 then begin
                                                                  mbatch_ID:=copy(mr.Strings[0],1,10);
                                                                  mStoreCard_ID:=copy(mr.Strings[0],11,10);
                                                             end else begin
                                                                  mbatch_ID:='0000000000';
                                                                  mStoreCard_ID:='0000000000';
                                                             end;
                                                          finally
                                                              mr.free;
                                                          end ;
                                                          mquantity:=NxIBStrToFloat(mXMLHead.getElementAsString('Doc.Row['+inttostr(i)+'].batch['+inttostr(ii)+'].quantity'));
                                                    end;

                                                    if mStoreCard_ID='' then begin ;
                                                        mr:= tstringlist.Create;   // ***** dohledání šarže
                                                          try
                                                             os.SQLSelect('SELECT sc.id from StoreCards SC WHERE sc.EAN = ' + quotedstr(mXMLHead.getElementAsString('Doc.Row['+inttostr(i)+'].ean')),mr);
                                                             if mr.count>0 then begin
                                                                        mStoreCard_ID:=mr.Strings[0];
                                                             end else begin
                                                                  mStoreCard_ID:='0000000000';
                                                             end;
                                                          finally
                                                              mr.free;
                                                          end ;
                                                          mquantity:=NxIBStrToFloat(mXMLHead.getElementAsString('Doc.Row['+inttostr(i)+'].batch['+inttostr(ii)+'].quantity'));

                                                    end;
                                                 if (mStoreCard_ID)<>'' then begin
                                                      mWorkList.add(mStoreCard_ID+mbatch_ID+NxFloatToIBStr(mquantity));
                                                end;
                                          end;   //ii
                                end;   // i
                               finally
                                   mXMLHead.free;
                               end;

    End;

   if (index=2) or (index=3) then begin
      mImportFile := TStringList.Create;
      mList:=tstringlist.create;
      mImportFile.LoadFromFile(AFileName);
            if mImportFile.Count>0 then begin
                if mShowProgres then ProgressInit(msite, 'Načtení souboru ' + AFileName, 100);
                  i := 1;
                  for i:=2 to mImportFile.Count-1 do begin   // načtení souboru
                              if mShowProgres then ProgressSetPos(1+NxFloor((i/mImportFile.Count)*99), inttostr(i) +' z '+inttostr(mImportFile.Count));
                                    mLine := mImportFile.strings[i];
                                            mfieldValue:= TStringList.Create;
                                            try
                                                Parsevalue(mline,';',mline,mfieldValue,3);
                                                          mbatch_ID:='0000000000';
                                                          mStoreCard_ID:='0000000000';


                                                          if index=2 then begin
                                                                  if mfieldValue.Strings[0]<>'' then begin
                                                                          mr:= tstringlist.Create;   // ***** dohledání šarže
                                                                          try
                                                                             os.SQLSelect('SELECT id||StoreCard_ID from StoreBatches SB WHERE sb.name = ' + quotedstr(mfieldValue.Strings[0]),mr);
                                                                             if mr.count>0 then begin
                                                                                  mbatch_ID:=copy(mr.Strings[0],1,10);
                                                                                  mStoreCard_ID:=copy(mr.Strings[0],11,10);
                                                                                  mquantity:=NxIBStrToFloat(mfieldValue.Strings[1]);
                                                                             end else begin
                                                                                  mbatch_ID:='0000000000';
                                                                                  mStoreCard_ID:='0000000000';
                                                                             end;
                                                                          finally
                                                                              mr.free;
                                                                          end ;

                                                                    end;
                                                            end;
                                                            //NxShowSimpleMessage(mfieldValue.Strings[0] +'-' + mStoreCard_ID,nil);
                                                            if mStoreCard_ID='0000000000' then begin ;
                                                                mr:= tstringlist.Create;   // ***** dohledání šarže
                                                                  try
                                                                     if index=2 then os.SQLSelect('SELECT sc.id from StoreCards SC WHERE sc.EAN = ' + quotedstr(mfieldValue.Strings[1]),mr);
                                                                     if index=3 then os.SQLSelect('SELECT sc.id from StoreCards SC WHERE sc.EAN = ' + quotedstr(mfieldValue.Strings[0]),mr);
                                                                     if mr.count>0 then begin
                                                                                mStoreCard_ID:=mr.Strings[0];
                                                                     end else begin
                                                                          mStoreCard_ID:='0000000000';
                                                                     end;
                                                                  finally
                                                                      mr.free;
                                                                  end ;
                                                                  if index=2 then mquantity:=NxIBStrToFloat(mfieldValue.Strings[1]);
                                                                  if index=3 then mquantity:=NxIBStrToFloat(mfieldValue.Strings[2]);

                                                            end;

                                                if (mStoreCard_ID)<>'' then begin
                                                      mWorkList.add(mStoreCard_ID+mbatch_ID+NxFloatToIBStr(mquantity));
                                                end;
                                            finally
                                                mfieldValue.free;
                                            end;
                  End;
            END;
   end;
        if mShowProgres then ProgressDispose();
      mWorkList.Sort;
     // NxShowSimpleMessage(inttostr(mWorkList.count),nil);
     // NxShowSimpleMessage(mWorkList.Strings[5],nil);


      if mShowProgres then ProgressInit(msite, 'Zpracování dat ' + AFileName, 100);
   if mWorkList.count>0 then begin
              mHead := TNxHeaderBusinessObject(OS.CreateObject(mCLSBO));
                      mHead.New;
                      mHead.Prefill;
                      if rucne and chyba then NxShowSimpleMessage('Novy',nil);
                      mHead.SetFieldValueAsString('DocQueue_ID', mID_Docqueue_ID);
                      mHead.SetFieldValueAsString('Firm_ID', mID_odberatel);

                                   mstorecard_ID:=copy(mWorkList.Strings[0],1,10);
                                   mbatch_ID:=copy(mWorkList.Strings[0],11,10);
                                   mquantity:=NxIBStrToFloat(copy(mWorkList.Strings[0],21,10));

                                    mRow := mHead.Rows.AddNewObject;                                                     // prrvní řádek
                                    mRow.Prefill;
                                    mRow.SetFieldValueAsString('Store_ID',mstore_id);
                                    if mStoreCard_ID<>'0000000000' then mRow.SetFieldValueAsString('Storecard_ID',mStoreCard_ID) else mRow.SetFieldValueAsString('Storecard_ID','3NQ1000101');
                                    mRow.SetFieldValueAsFloat('Quantity',mquantity)  ;
                                    mRow.SetFieldValueAsString('Division_ID',mID_Division);

                                         if (mRow.getFieldValueAsinteger('Storecard_ID.Category')=1) or (mRow.getFieldValueAsinteger('Storecard_ID.Category')=2) then begin
                                                    if mbatch_ID<>'0000000000' then begin     // ******** šarže
                                                      mMonBatches := mrow.GetLoadedCollectionMonikerForFieldCode(mrow.GetFieldCode('DocRowBatches'));
                                                                                mRowDocRowBatches := mMonBatches.AddNewObject;
                                                                                mRowDocRowBatches.Prefill;
                                                                                            //mRowDocRowBatches.SetFieldValueAsInteger('PosIndex',II);
                                                                                            mRowDocRowBatches.SetFieldValueAsBoolean('NewBatch',False);
                                                                                            mRowDocRowBatches.SetFieldValueAsString('StoreBatch_ID',mbatch_ID);
                                                                                            mRowDocRowBatches.SetFieldValueAsFloat('Quantity',mquantity);
                                                   end;
                                         end;







                            for i:=1 to mWorkList.count-1 do begin
                                   if mShowProgres then ProgressSetPos(1+NxFloor((i/mWorkList.Count)*99), inttostr(i) +' z '+inttostr(mWorkList.Count));

                                   mstorecard_ID:=copy(mWorkList.Strings[i],1,10);
                                   mbatch_ID:=copy(mWorkList.Strings[i],11,10);
                                   mquantity:=NxIBStrToFloat(copy(mWorkList.Strings[i],21,10));



                                      if copy(mWorkList.Strings[i],1,10)<>copy(mWorkList.Strings[i-1],1,10) then begin
                                            mRow := mHead.Rows.AddNewObject;                                                     // ***** řádky
                                            mRow.Prefill;
                                            mRow.SetFieldValueAsString('Store_ID',mstore_id);
                                            if mStoreCard_ID<>'0000000000' then mRow.SetFieldValueAsString('Storecard_ID',mStoreCard_ID) else mRow.SetFieldValueAsString('Storecard_ID','3NQ1000101');
                                            mRow.SetFieldValueAsFloat('Quantity',mquantity)  ;
                                            mRow.SetFieldValueAsString('Division_ID',mID_Division);
                                      end else begin
                                            mRow.SetFieldValueAsFloat('Quantity',(mRow.getFieldValueAsFloat('Quantity') + mquantity))  ;
                                      end;



                                   if (mRow.getFieldValueAsinteger('Storecard_ID.Category')=1) or (mRow.getFieldValueAsinteger('Storecard_ID.Category')=2) then begin
                                      if mbatch_ID<>'0000000000' then begin     // ******** šarže
                                           mMonBatches := mrow.GetLoadedCollectionMonikerForFieldCode(mrow.GetFieldCode('DocRowBatches'));
                                                mRowDocRowBatches := mMonBatches.AddNewObject;
                                                mRowDocRowBatches.Prefill;
                                                //mRowDocRowBatches.SetFieldValueAsInteger('PosIndex',II);
                                                mRowDocRowBatches.SetFieldValueAsBoolean('NewBatch',False);
                                                mRowDocRowBatches.SetFieldValueAsString('StoreBatch_ID',mbatch_ID);
                                                mRowDocRowBatches.SetFieldValueAsFloat('Quantity',mquantity);
                                       end;
                                   end;
                            end;


                            if mShowProgres then ProgressDispose();
                            // ******* ukládání dokladu
                                  mhead.ClearValidateErrors;
                                  if Not mhead.Validate() then begin

                                        mList := TStringList.Create;
                                        try
                                           mhead.GetValidateErrors(mList);
                                           mText := mList.Text;
                                           NxToken(mText, '=');
                                           //MessageDlg('Automaticky vytvořendoklad nelze uložit z těchto důvodů:' + #13#10 + mText,

                                           //mtWarning, [mbOK], 0);
                                         finally
                                           mList.Free;
                                         end;
                                         TDynSiteForm(msite).ShowDynFormWithNewDocument(mAgenda, mSite.SiteContext, mHead);
                                         mhead.free;
                                  end else begin
                                      mHead.save ;
                                      NxShowSimpleMessage('Byl vytvořen doklad',nil);
                                      mhead.free;
                                  end;



   end;   // ***** vytváření dokladu






end;



//procedure _CanSaveNow_Hook(Self: TDynSiteForm; var ACanSaveNow: Boolean);
//begin
//  if (Self.CompanyCache.GetUserID= '1600000101') or (Self.CompanyCache.GetUserID ='6K00000101') or (Self.CompanyCache.GetUserID ='2K00000101') or (Self.CompanyCache.GetUserID ='3K00000101') or (Self.CompanyCache.GetUserID='SUPER00000') then begin
//      ACanSaveNow:=false;
//  end;
//end;






procedure CreateDocImportFile(Sender: TComponent;index:integer);
var

  zadej:string;
  mfilename:string;
  mdir,mfile:string;
begin
  mdir:='';
  mfile:='';

 mSite := NxFindSiteForm(TComponent(Sender));
  //  mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
  //  if mTabList = nil then RaiseException('tabList nenalezen');
  //  mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
  //  if mDBGrid = nil then RaiseException('DBGrid nenalezen');
  //if (index=1) then begin
   if PromptForFileName(mFileName, mfilter, '', 'Soubory SP', mdir, False) then begin
    mdir:=copy(mfilename,0,NxCharPosR('\',mfilename));
    mFile:=copy(mfilename,1+NxCharPosR('\',mfilename),Length(mfilename));
   //end;
   end ;

  //ImportFile(TDynSiteForm(mSite).CurrentObject.ObjectSpace, mfilename, mdir,mfile);
 CreateDocImport(msite.baseobjectspace, mfilename, mdir,mfile,msite,true,false,index);
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
          mMAction.Hint := 'Import Denzo DL';
          mMAction.Caption := 'Externí import';
          mMAction.Items.Add('XML Šarže');
          mMAction.Items.Add('XML Skladové karty');
          mMAction.Items.Add('CSV - šarže');
          mMAction.Items.Add('CSV - skladové karty');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @CreateDocImportFile;



          mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Doplnění šarží';
          mMAction.Caption := 'Doplnění šarží ';
          mMAction.Items.Add('Doplnění šarží skladem');
          mMAction.Items.Add('Doplnění již dodaných šarží');
          mMAction.Category := 'tabDetail';
          mMAction.OnExecuteItem := @AppendBatches;

 // end;




end;





begin
end.
