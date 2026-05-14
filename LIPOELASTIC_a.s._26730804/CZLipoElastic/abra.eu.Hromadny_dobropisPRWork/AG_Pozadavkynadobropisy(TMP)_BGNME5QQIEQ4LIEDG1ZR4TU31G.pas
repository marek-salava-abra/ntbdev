 uses  '_Knihovny_ALL.Progress',
       '_Knihovny_ALL.XML',
       'abra.eu.Hromadny_dobropisPR.Libs',
      '_Knihovny_ALL.Parse';


var
     mBookmark : TBookmarkList;
     index:integer;







     procedure ShowFV(Sender: TAction; Index: integer);
var
 mbo:TNxCustomBusinessObject;
 L ,mx: TStringList;
 mid:string;
 mPars:TNxParameters;
 mPar:TNxParameter;
 msite:TSiteForm;
 mr2:TStringList;
 mMon : TNxCustomBusinessMonikerCollection;
 mStrings:string;
 i,ii:integer;
   mOLE, mRoll,mAgenda, mOResult: Variant;
  mids1:tstringlist;
  mids: TStringList;
  mB:boolean;
  mSelected ,_ss:Variant;
 mstring:string;
 mBoolean:boolean;
 mBOPohyb:TNxCustomBusinessObject;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 x:integer;
 mfind:Boolean;
 mFilter:string;
begin
 msite:=TComponent(sender).BusRollSite;
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
        mr2:=tstringlist.create;


                   for x := 0 to mBookmark.Count- 1 do begin
                    mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(x));

                          mbo:= TBusRollSiteForm(mSite).CurrentObject;                      //ProgressSetPos(1+NxFloor(x/mBookmark.Count*99), inttostr(x) +' z '+inttostr(mBookmark.Count));
                                   mfind:=false;
                                   for ii:=0 to mr2.count-1 do begin
                                           if mr2.strings[ii]=mbo.GetFieldValueAsString('X_Parent_ID') then mfind:=true;

                                   end;

                                   if not mfind  then mr2.Add(mbo.GetFieldValueAsString('X_Parent_ID'));

                   end;


//      mstring:= mroll.SingleSelectFromSelected2(mSelected, 'Doklady: ', '');
                                                   mFilter:= '';
                                                         for i:= 0 to mr2.Count - 1 do begin
                                                            mFilter:= mFilter + Format('''%s'',', [mr2[i]]);

                                                          end;
                                                           if mFilter <> '' then begin
                                                                mFilter:= copy(mFilter, 1, Length(mFilter) - 1);

                                                            end;
                                                        NxShowSimpleMessage(mfilter,nil);
                                                     // msite.ShowSite('PLC2EX0BUJD13ACP03KIU0CLP4',true,'FilterByUserDynSQLCondition;A.ID in (' + mFilter + ') ');
                                                      ShowSelectedDynForm(msite, mr2, 'PLC2EX0BUJD13ACP03KIU0CLP4','aa' );




end;



 procedure ShowSelectedDynForm(AForm: TSiteForm; AOIDs: TStrings; AFormCLSID: string; ASelCaption: string);
var
  mPars: TNxParameters;
  mParameter: TNxParameter;
begin
  if AOIDs.Count> 0 then begin
    mPars := TNxParameters.Create;
    try
      mPars.NewFromDataType(dtString, '_SelectionCaption', pkUnknown).AsString := ASelCaption;
      mParameter := mPars.NewFromDataType(dtList, '_DefaultSelection', pkUnknown);
      mParameter := mParameter.AsList.NewFromDataType(dtList, 'CONDITIONS', pkUnknown) ;
      mParameter := mParameter.AsList.NewFromDataType(dtList, 'ID', pkUnknown);
      mParameter.AsList.NewFromDataType(dtInteger, 'USEDKIND', pkUnknown).AsInteger := 3;
      mParameter.AsList.NewFromDataType(dtString, 'VALUELIST', pkUnknown).AsString := NxStringsTockListStr(AOIDs);
      AForm.ShowDynForm(AFormCLSID, mPars, nil, True, '');

    finally
      mPars.Free;
    end;
  end ;
end ;
















    function ParsevalueLightx(AData : string; ASeparator: string):TStringList;
// rozdělení hodnot pro import
var
    mStr, mToken : string;
    mPos, i : integer;
    mList:tstringlist;
begin
    mStr := AData;
    mlist:=tstringlist.create;

    try
        while AnsiPos(ASeparator,mStr)>0 do  begin
            mPos := AnsiPos(ASeparator, mStr);
            if mPos = 0 then mPos := Length(mStr) + 1;
                mList.Add(NxLeft(mStr, mPos - 1));
                mStr := copy(mStr, mPos + 1, Length(mStr) - mPos);

        end;
        mList.Add(mStr);
        result:=mlist;
   finally
       mlist.free;
   end;
end;






     procedure Import_ctecka(Sender: TAction; Index: integer);
var

  zadej:string;
  msite:TSiteForm;
  mfilter:String;
  mDBGrid : TDBGrid;
 mTabList: TTabSheet;
    mid :string;
    moddelovac:string;
    mOLE, mRoll, mOResult: Variant;
  mGrid: TdbGrid;
  mControl: TControl;
  mDataSource: TDataSource;
  mDataset: TNxRowsObjectDataSet;
  mStorecard_ID,mBatch_ID,mFirm_ID:string;
  mList:tstringlist;
  mQuantity:double;
  iRow,iBatch,i:Integer;
  mRSql:tstringlist;
  mWorkList:Tstringlist;
  mXMLHead : TNxScriptingXMLWrapper;
  mfieldValue:tstringlist;
  mBO_Temp:TNxCustomBusinessObject;
  mstringline:string;
  mCountField:integer;
  _ss:Variant;
  mstring,mstringx:string;
  mvalue:TStringList;
  mr:tstringlist;
  gs01,gs10,gs17:string;
begin
    mSite := NxFindSiteForm(Sender);
        mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu


    mBO_Temp:= msite.BaseObjectSpace.CreateObject('45D1XVW5EY24JBXTOE01EHYRSG');

//  mOLE := GetAbraOLEApplication;
//                            mroll := mOLE.GetAgenda('N1C2EX0BUJD13ACP03KIU0CLP4');
//                            _ss := mOLE.CreateStrings;

//                               mfirm_id := mroll.SingleSelectFromSelected2(_ss, 'Vyber odběratele', '');
mfirm_id:='JHYE800101';
                  mstringx:='';
                  while InputQuery('Identifikace položky', 'Datamatrix' , mstringx) do begin
                       // NxShowSimpleMessage(mstring,nil);
                        if mstringx<>'' then begin
                              mQuantity:=1;


                              mvalue:=tstringlist;
                                   try
                                      mvalue:= fnParsevalue(GS_DecodeDatamatrix(msite.BaseObjectSpace,mstringx),';');
                                      if mvalue.count>1 then begin
                                          gs01:=mvalue.Strings[1];
                                          gs10:=mvalue.Strings[0];
                                          gs17:=mvalue.Strings[2];
                                          //mquantity:=NxIBStrToFloat(mvalue.Strings[3]);
                                      end;
                                   finally
                                      mvalue.free;
                                   end;

                                   mvalue:=tstringlist;
                                   try
                                   mvalue:= fnParsevalue(ID_from_GS_DecodeDatamatrix(msite.BaseObjectSpace,gs01,gs10,mquantity),';') ;
                                   if mvalue.count>1 then begin
                                        if mvalue.Strings[0]='0000000000' then mBatch_ID:='' else mBatch_ID:=mvalue.Strings[0];
                                        if mvalue.Strings[1]='0000000000' then mStoreCard_ID:='' else mStoreCard_ID:=mvalue.Strings[1];
                                        if NxIBStrToFloat(mvalue.Strings[2])=0 then mquantity:=1 else mquantity:=NxIBStrToFloat(mvalue.Strings[2]);
                                      end;

                                   finally
                                       mvalue.free;
                                   end;




                                     mRSql:= tstringlist.Create;   // ***** dohledání již existujícího záznamu
                                                try
                                                    msite.BaseObjectSpace.SQLSelect('SELECT A.id FROM DefRollData A WHERE (A.Hidden = ''N'' ) AND (A.CLSID = ''45D1XVW5EY24JBXTOE01EHYRSG'' ) AND ((A.X_Firm_ID = '
                                                                 + quotedstr(mFirm_ID) + ' OR A.X_Firm_ID IN (SELECT ID FROM Firms WHERE Firm_ID = '
                                                                 + quotedstr(mFirm_ID) + ')))  AND a.X_ABRADate=' +inttostr(trunc(now()))  + ' AND ((A.X_Batches = ' + quotedstr(mbatch_ID) + ') and (A.X_storeCard_ID = ' + quotedstr(mStorecard_ID) + ')) ' ,mRSql);

                                                    if mRSql.count=0 then begin
                                                           msite.BaseObjectSpace.SQLSelect('SELECT A.id FROM DefRollData A WHERE (A.Hidden = ''N'' ) AND (A.CLSID = ''45D1XVW5EY24JBXTOE01EHYRSG'' ) AND ((A.X_Firm_ID = '
                                                                 + quotedstr(mFirm_ID) + ' OR A.X_Firm_ID IN (SELECT ID FROM Firms WHERE Firm_ID = '
                                                                 + quotedstr(mFirm_ID) + ')))  AND a.X_ABRADate=' +inttostr(trunc(now()))  + ' AND ((A.Name = ' + quotedstr(mstringx) + ') and (A.Name = ' + quotedstr(mstringx) + ')) ' ,mRSql);

                                                    end;

                                                   if mRSql.count>0 then begin
                                                        mBO_Temp.load(mRSql.strings[0],nil);


                                                               mBO_Temp.SetFieldValueAsfloat('X_quantity',mBO_Temp.getFieldValueAsfloat('X_quantity') + mquantity);
                                                           mBO_Temp.save;
                                                           TBusRollSiteForm(msite).DataSet.RefreshCurrentItem;
                                                   end else begin
                                                                 mBO_Temp.new;
                                                                 mBO_Temp.Prefill;
                                                                     mBO_Temp.SetFieldValueAsString('X_CreatedBy_ID', msite.CompanyCache.GetUserID);
                                                                     mBO_Temp.SetFieldValueAsfloat('X_ABRADate', trunc(now()));
                                                                     mBO_Temp.SetFieldValueAsString('Code', mStoreCard_ID);
                                                                     mBO_Temp.SetFieldValueAsString('Name',mstringx);
                                                                      mBO_Temp.SetFieldValueAsString('X_firm_ID',mFirm_ID);
                                                                      if False then begin
                                                                          mBO_Temp.SetFieldValueAsString('X_Store_ID',mCstore_ID);
                                                                      end else begin
                                                                          mr:=tstringlist.create;
                                                                          try
                                                                             mSite.BaseObjectSpace.SQLSelect('select id from stores where X_Firm_ID=' + QuotedStr(mBO_Temp.getFieldValueAsString('X_firm_ID')),mr);
                                                                             if mr.count>0 then begin
                                                                                mBO_Temp.SetFieldValueAsString('X_Store_ID',mr.Strings[0]);
                                                                             end else begin
                                                                                mBO_Temp.SetFieldValueAsString('X_Store_ID',mCstore_ID);
                                                                             end;
                                                                          finally
                                                                                 mr.free;
                                                                          end;

                                                                      end;


                                                                     if  mBatch_ID<>'' then begin
                                                                          mBO_Temp.SetFieldValueAsString('X_Batches',mbatch_ID);
                                                                          mBO_Temp.SetFieldValueAsString('X_storeCard_ID',mStoreCard_ID);
                                                                     end else begin
                                                                         mBO_Temp.SetFieldValueAsString('X_storeCard_ID',mStorecard_ID);
                                                                     end;

                                                                     if mBO_Temp.getFieldValueAsString('X_Batches.Name')='0' then begin
                                                                          mBO_Temp.SetFieldValueAsString('X_Batches','');
                                                                          mBO_Temp.SetFieldValueAsString('X_storeCard_ID','');
                                                                          NxShowSimpleMessage('odmazaní',nil);
                                                                     end;


                                                                  mBO_Temp.SetFieldValueAsfloat('X_quantity',mquantity);
                                                                  mBO_Temp.save;
                                                                  TBusRollSiteForm(msite).DataSet.RefreshCurrentItem;

                                                   end;
                                               finally
                                                  // mRSql.free;
                                               end;

                        end;

                  mstring:='';
                  end;
     msite.Refresh;
     TBusRollSiteForm(msite).RefreshData;

end;






procedure findsc(Sender: TAction; Index: integer);
     var
 mbo:TNxCustomBusinessObject;
 mSite: TSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 x,i:integer;
 mtext:string;
 mpocet:double;
 mTMPBO:TNxCustomBusinessObject;
 mr:tstringlist;
 mstring:string;
  mStorecard_ID,mBatch_ID,mFirm_ID:string;
  mQuantity:double;
  mRSql:tstringlist;
  mfieldValue:tstringlist;
  mstringline:string;
  mvalue:TStringList;
begin
   mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');


         mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu

 //   ProgressInit(msite, 'Hledání souborů ' + '', 100);
    if mBookmark.count=0 then begin
            mstring:='';
            mstring:=NxSearchReplace(TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsString('Name'),';','',[srCase,srAll]);
            mstring:=NxSearchReplace(mstring,'"','',[srCase,srAll]);
           // NxShowSimpleMessage(mstring,nil);
           if mstring<>'' then begin
                        if index=0 then begin
                             mr:=TStringList.create;
                             try
                                  msite.BaseObjectSpace.sqlselect('select id from Storebatches where name=' + quotedstr(mstring),mr);
                                  if mr.count>0 then begin
                                           TBusRollSiteForm(msite).CurrentObject.setFieldValueAsString('X_batches', mr.Strings[0]);
                                           TBusRollSiteForm(msite).CurrentObject.setFieldValueAsString('X_Storecard_ID', TBusRollSiteForm(msite).CurrentObject.getFieldValueAsString('X_batches.Storecard_ID'));
                                           TBusRollSiteForm(msite).CurrentObject.save;
                                           //  NxShowSimpleMessage('Ulozeni',nil);
                                  end;

                             finally
                                 mr.free;
                             end;
                        end;

                        if index=1 then begin
                                           mr:=TStringList.create;
                                           try
                                                msite.BaseObjectSpace.sqlselect('select id from Storecards where ean=' + quotedstr(mstring),mr);
                                                if mr.count>0 then begin
                                                         //TBusRollSiteForm(msite).CurrentObject.setFieldValueAsString('X_batches', mr.Strings[0]);
                                                         TBusRollSiteForm(msite).CurrentObject.setFieldValueAsString('X_Storecard_ID', mr.Strings[0]);
                                                         TBusRollSiteForm(msite).CurrentObject.save;
                                                       //   NxShowSimpleMessage('Ulozeni',nil);
                                                end;

                                           finally
                                               mr.free;
                                           end;
                        end;

                         if index=2 then begin
                                           mstring:='';
                                            mstring:=NxSearchReplace(TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsString('Name'),';','',[srCase,srAll]);
                                            mstring:=NxSearchReplace(mstring,'"','',[srCase,srAll]);
                                           mstring:= DatamatrixDecodeBatches(TBusRollSiteForm(msite).BaseObjectSpace,mstring);
                                                                        mbatch_ID:='';
                                                                        mStoreCard_ID:='';
                                                                        mquantity:=0;



                                               if mstring<>'' then begin
                                                        mvalue:= Parsevaluelightx(mstring,';');
                                                          if mvalue.count>0 then begin
                                                                if mvalue.count>0 then  mStoreCard_ID:=mvalue.Strings[1];
                                                                if mvalue.count>1 then  mbatch_ID:=mvalue.Strings[2];
                                                                if mvalue.count>2 then mquantity:=NxIBStrToFloat(mvalue.Strings[3]) else mquantity:=1 ;
                                                           end else begin
                                                               //NxShowSimpleMessage( mstring,nil);
                                                               mStoreCard_ID:=copy(mstring,12,10);
                                                               mbatch_ID:=copy(mstring,23,10);
                                                               if NxIsNumeric((trim(copy(mstring,34,5)))) then
                                                                   mquantity:=NxIBStrToFloat(trim(copy(mstring,34,10)))
                                                                else mquantity:=1 ;
                                                           end;

                                                                                               TBusRollSiteForm(msite).CurrentObject.setFieldValueAsString('X_batches', mbatch_ID);
                                                                                               TBusRollSiteForm(msite).CurrentObject.setFieldValueAsString('X_Storecard_ID', mStoreCard_ID);

                                                           if TBusRollSiteForm(msite).CurrentObject.getFieldValueAsString('X_Firm_ID')= 'JJHF800101' then begin
                                                                         TBusRollSiteForm(msite).CurrentObject.setFieldValueAsString('X_Store_ID', '1030000101');
                                                           end;





                                                          TBusRollSiteForm(msite).CurrentObject.save;







                                                end;

                 end;

                       if index=3 then begin
                                           mstring:='';

                                            mstring:=NxSearchReplace(TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsString('Name'),';','',[srCase,srAll]);
                                            mstring:=NxSearchReplace(mstring,'"','',[srCase,srAll]);
                                            mstring:=copy(mstring,3,13);

                                            mr:=TStringList.create;
                                                     try
                                                          mBatch_ID:='';
                                                          msite.BaseObjectSpace.sqlselect('select id from Storebatches where name=' + quotedstr(mstring),mr);
                                                          if mr.count>0 then begin
                                                                   TBusRollSiteForm(msite).CurrentObject.setFieldValueAsString('X_batches', mr.Strings[0]);
                                                                   TBusRollSiteForm(msite).CurrentObject.setFieldValueAsString('X_Storecard_ID', TBusRollSiteForm(msite).CurrentObject.getFieldValueAsString('X_batches.Storecard_ID'));
                                                                   TBusRollSiteForm(msite).CurrentObject.save;
                                                                    mBatch_ID:=mr.Strings[0];
                                                                   //  NxShowSimpleMessage('Ulozeni',nil);
                                                          end;

                                                     finally
                                                         mr.free;
                                                     end;
                                           if mBatch_ID='' then begin
                                                     mr:=TStringList.create;
                                                     try
                                                          msite.BaseObjectSpace.sqlselect('select id from Storecards where ean=' + quotedstr(mstring),mr);
                                                          if mr.count>0 then begin
                                                                   //TBusRollSiteForm(msite).CurrentObject.setFieldValueAsString('X_batches', mr.Strings[0]);
                                                                   TBusRollSiteForm(msite).CurrentObject.setFieldValueAsString('X_Storecard_ID', mr.Strings[0]);
                                                                   TBusRollSiteForm(msite).CurrentObject.save;
                                                                 //   NxShowSimpleMessage('Ulozeni',nil);
                                                          end;

                                                     finally
                                                         mr.free;
                                                     end;
                                            end;

                 end;



                 end;
    end else begin
        for x := 0 to mBookmark.Count- 1 do begin
                          mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(x));
                        //  ProgressSetPos(1+NxFloor(x/mBookmark.Count*99), inttostr(x) +' z '+inttostr(mBookmark.Count));
                         mstring:='';

                              mstring:=NxSearchReplace(TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsString('Name'),';','',[srCase,srAll]);
                              mstring:=NxSearchReplace(mstring,'"','',[srCase,srAll]);
                        if mstring<>'' then begin
                        if index=0 then begin
                               mr:=TStringList.create;
                               try
                                    msite.BaseObjectSpace.sqlselect('select id from Storebatches where name=' + quotedstr(mstring),mr);
                                    if mr.count>0 then begin
                                             TBusRollSiteForm(msite).CurrentObject.setFieldValueAsString('X_batches', mr.Strings[0]);
                                             TBusRollSiteForm(msite).CurrentObject.setFieldValueAsString('X_Storecard_ID', TBusRollSiteForm(msite).CurrentObject.getFieldValueAsString('X_batches.Storecard_ID'));
                                             TBusRollSiteForm(msite).CurrentObject.save;
                                           //   NxShowSimpleMessage('Ulozeni',nil);
                                    end;

                               finally
                                   mr.free;
                               end;
                          end;

                          if index=1 then begin
                               mr:=TStringList.create;
                               try
                                    msite.BaseObjectSpace.sqlselect('select id from Storecards where ean=' + quotedstr(mstring),mr);
                                    if mr.count>0 then begin
                                             //TBusRollSiteForm(msite).CurrentObject.setFieldValueAsString('X_batches', mr.Strings[0]);
                                             TBusRollSiteForm(msite).CurrentObject.setFieldValueAsString('X_Storecard_ID', mr.Strings[0]);
                                             TBusRollSiteForm(msite).CurrentObject.save;
                                           //   NxShowSimpleMessage('Ulozeni',nil);
                                    end;

                               finally
                                   mr.free;
                               end;
                          end;



                           if index=2 then begin
                                           mstring:='';
                                            mstring:=NxSearchReplace(TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsString('Name'),';','',[srCase,srAll]);
                                            mstring:=NxSearchReplace(mstring,'"','',[srCase,srAll]);
                                           mstring:= DatamatrixDecodeBatches(TBusRollSiteForm(msite).BaseObjectSpace,mstring);
                                                                        mbatch_ID:='';
                                                                        mStoreCard_ID:='';
                                                                        mquantity:=0;



                                               if mstring<>'' then begin

                                                                               mvalue:= Parsevaluelightx(mstring,';');
                                                          if mvalue.count>0 then begin
                                                                if mvalue.count>0 then  mStoreCard_ID:=mvalue.Strings[1];
                                                                if mvalue.count>1 then  mbatch_ID:=mvalue.Strings[2];
                                                                if mvalue.count>2 then mquantity:=NxIBStrToFloat(mvalue.Strings[3]) else mquantity:=1 ;
                                                           end else begin
                                                               //NxShowSimpleMessage( mstring,nil);
                                                               mStoreCard_ID:=copy(mstring,12,10);
                                                               mbatch_ID:=copy(mstring,23,10);
                                                               if NxIsNumeric((trim(copy(mstring,34,5)))) then
                                                                   mquantity:=NxIBStrToFloat(trim(copy(mstring,34,10)))
                                                                else mquantity:=1 ;
                                                           end;

                                                                            TBusRollSiteForm(msite).CurrentObject.setFieldValueAsString('X_batches', mbatch_ID);
                                                                                              TBusRollSiteForm(msite).CurrentObject.setFieldValueAsString('X_Storecard_ID', mStoreCard_ID);

                                                              if TBusRollSiteForm(msite).CurrentObject.getFieldValueAsString('X_Firm_ID')= 'JJHF800101' then begin
                                                                         TBusRollSiteForm(msite).CurrentObject.setFieldValueAsString('X_Store_ID', '1030000101');
                                                           end;


                                                                                              TBusRollSiteForm(msite).CurrentObject.save;





                                                end;

                                    end;




                                    if index=3 then begin
                                           mstring:='';

                                            mstring:=NxSearchReplace(TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsString('Name'),';','',[srCase,srAll]);
                                            mstring:=NxSearchReplace(mstring,'"','',[srCase,srAll]);
                                            mstring:=copy(mstring,3,13);

                                            mr:=TStringList.create;
                                                     try
                                                          mBatch_ID:='';
                                                          msite.BaseObjectSpace.sqlselect('select id from Storebatches where name=' + quotedstr(mstring),mr);
                                                          if mr.count>0 then begin
                                                                   TBusRollSiteForm(msite).CurrentObject.setFieldValueAsString('X_batches', mr.Strings[0]);
                                                                   TBusRollSiteForm(msite).CurrentObject.setFieldValueAsString('X_Storecard_ID', TBusRollSiteForm(msite).CurrentObject.getFieldValueAsString('X_batches.Storecard_ID'));
                                                                   TBusRollSiteForm(msite).CurrentObject.save;
                                                                    mBatch_ID:=mr.Strings[0];
                                                                   //  NxShowSimpleMessage('Ulozeni',nil);
                                                          end;

                                                     finally
                                                         mr.free;
                                                     end;
                                           if mBatch_ID='' then begin
                                                     mr:=TStringList.create;
                                                     try
                                                          msite.BaseObjectSpace.sqlselect('select id from Storecards where ean=' + quotedstr(mstring),mr);
                                                          if mr.count>0 then begin
                                                                   //TBusRollSiteForm(msite).CurrentObject.setFieldValueAsString('X_batches', mr.Strings[0]);
                                                                   TBusRollSiteForm(msite).CurrentObject.setFieldValueAsString('X_Storecard_ID', mr.Strings[0]);
                                                                   TBusRollSiteForm(msite).CurrentObject.save;
                                                                 //   NxShowSimpleMessage('Ulozeni',nil);
                                                          end;

                                                     finally
                                                         mr.free;
                                                     end;
                                            end;

                 end;




                        end;


        end;

    end;
end;



function CreateAllDocFromWorkListImportPR(msite:tSiteform;mCLSIDInput:string;mCLSIDOuput:string;mAgenda:string;mDocqueue_ID:string;mFirm_id:string;mDivision_ID:string;mStore_ID:string;mDocList:tstringlist;mRowList:tstringlist;index:integer;mbatchlist:TStringList;mBatchWorkList:tstringlist):string;
var
  mImportMan: TNxDocumentImportManager;
  mOS: TNxCustomObjectSpace;
  mInputParams: TNxParameters;
  mParam: TNxParameter;
  mCollRows: TNxCustomBusinessMonikerCollection;
  x,xx,xxx,y: integer;
  mList,mxx: TStringList;
  mRow: TNxCustomBusinessObject;
  mtext:string;
  mValidateList:tstringlist;
  mRowsOutput,mRows,mMonBatches:TNxCustomBusinessMonikerCollection;
  msave,mFind:boolean;
  mIDoc:integer;
  mVratka,mr:TStringList;
  mi:integer;
  msearch:boolean;
  i:integer;
  mBOVratka,mDefRoll,mBillOfDeliveryRowBO:TNxCustomBusinessObject;
  mpocet:double;
  mMonbatch:TNxCustomBusinessObject;
  mboolean:Boolean;
begin
  mOS := msite.BaseObjectSpace;
  try
       mInputParams := TNxParameters.Create;
       mImportMan := NxCreateDocumentImportManager(mOS, 'E03ZNUMDTCC4PDAUIEY1MBTJC0', '3OKSI2XXYK2OB2JRPZ3U4UXTGK');
      try


        //for mIDoc:=0 to mDocList.count-1 do begin
         //    NxShowSimpleMessage('Dokladů ' + inttostr(mDocList.count)  + ' - ' + mDocList.Strings[0] + ' Řádků  ' + inttostr(mRowList.count)  + ' - ' + mRowList.Strings[0] + ' Šarží  ' + inttostr(mBatchWorkList.count)  + ' - ' + mBatchWorkList.Strings[0],nil);
             mImportMan.AddInputDocument(mDocList.Strings[0]);
        //end;
        mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader'); // musi se z nejake hlavicky prebirat hlavickova data
                      mParam.AsString := mDocList.Strings[0];

        mParam := mInputParams.GetOrCreateParam(dtBoolean, 'ImportBatches');
                          mParam.AsBoolean := True;


        mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                          mParam.AsString := mDocqueue_ID_VRPR;


        mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows'); // jen povolene radky
        mParam.AsString := mRowList.Text;






        mImportMan.LoadParams(mInputParams);

        mImportMan.Execute;
        mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', mDocqueue_ID_VRPR ); // musi byt...          '2781000101'
          mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID', '3010000101');
          mImportMan.OutputDocument.SetFieldValueAsDateTime('Docdate$date', TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsDateTime('X_ABRADate'));



        if Assigned(mImportMan.OutputDocument) then begin
                 mRowsOutput := mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));


                        //NxShowSimpleMessage('Importovano radků ' + inttostr(mRowsOutput.count),nil);
                        for xx:=0 to mRowsOutput.Count-1 do begin
                              mRowsOutput.BusinessObject[xx].SetFieldValueAsBoolean('X_MArkForDelete',true);
                              mMonBatches :=  mRowsOutput.BusinessObject[xx].GetLoadedCollectionMonikerForFieldCode( mRowsOutput.BusinessObject[xx].GetFieldCode('DocRowBatches'));
                                     for xxx := 0 to mMonBatches.Count - 1 do begin
                                                  mMonBatches.BusinessObject[xxx].SetFieldValueAsBoolean('X_MArkForDelete',true);
                                     end;
                        end;
                        msave:=false;


                              for xx:=0 to mRowsOutput.Count-1 do begin
                                   mFind:=false;
                                   for xxx:=0 to mBatchWorkList.Count-1 do begin

                               //    NxShowSimpleMessage(mRowsOutput.BusinessObject[xx].GetFieldValueAsString('RDocumentRow_ID')+' = ' + copy(mBatchWorkList.Strings[xxx],51,10),nil);
                                   if mRowsOutput.BusinessObject[xx].GetFieldValueAsString('RDocumentRow_ID')=copy(mBatchWorkList.Strings[xxx],51,10) then begin
                                      mRowsOutput.BusinessObject[xx].SetFieldValueAsBoolean('X_MArkForDelete',false);
                                      // NxShowSimpleMessage('Nalezeno',nil);
                                       if copy(mBatchWorkList.Strings[xxx],81,10)<>'0000000000' then
                                             mRowsOutput.BusinessObject[xx].SetFieldValueAsstring('Store_ID',copy(mBatchWorkList.Strings[xxx],81,10))
                                       else
                                             mRowsOutput.BusinessObject[xx].SetFieldValueAsstring('Store_ID',mCStore_ID);

                                       //mRowsOutput.BusinessObject[xx].SetFieldValueAsFloat('quantity',1);

                                       if mRowsOutput.BusinessObject[xx].GetFieldValueAsinteger('StoreCard_ID.category')=2 then begin
                                                                                          mpocet:=0;
                                                                                               mxx:=tstringlist.create;



                                                                                          mMonBatches :=  mRowsOutput.BusinessObject[xx].GetLoadedCollectionMonikerForFieldCode( mRowsOutput.BusinessObject[xx].GetFieldCode('DocRowBatches'));
                                                                                             for y := 0 to mMonBatches.Count - 1 do begin

                                                                                                         if mMonBatches.BusinessObject[y].getFieldValueAsString('StoreBatch_ID')= copy(mBatchWorkList.Strings[xxx],71,10) then begin
                                                                                                             mMonBatches.BusinessObject[y].SetFieldValueAsBoolean('X_MArkForDelete',false);
                                                                                                             if NxIBStrToFloat(copy(mBatchWorkList.Strings[xxx],101,10))>0 then begin
                                                                                                                 // NxShowSimpleMessage('Nalezeno ' + (copy(mBatchWorkList.Strings[y],11,10)),nil);




                                                                                                                      mDefRoll:= msite.BaseObjectSpace.CreateObject('45D1XVW5EY24JBXTOE01EHYRSG');

                                                                                                                      try


                                                                                                                                mDefRoll.load(copy(mBatchWorkList.Strings[xxx],91,10),nil);



                                                                                                                                   mMonBatches.BusinessObject[y].setFieldValueAsFloat('X_Quantity',mMonBatches.BusinessObject[y].getFieldValueAsFloat('X_Quantity') + mDefRoll.GetFieldValueAsFloat('X_vychystano'));

                                                                                                                                   //mMonBatches.BusinessObject[xxx].setFieldValueAsFloat('Quantity', mMonBatches.BusinessObject[y].getFieldValueAsFloat('Quantity')+ mDefRoll.GetFieldValueAsFloat('X_vychystano'));
                                                                                                                                   //mRowsOutput.BusinessObject[xx].setFieldValueAsFloat('Quantity', mMonBatches.BusinessObject[y].getFieldValueAsFloat('Quantity')+ mDefRoll.GetFieldValueAsFloat('X_vychystano'));
                                                                                                                                   mDefRoll.setFieldValueAsFloat('X_dodano',mDefRoll.getFieldValueAsFloat('X_dodano') + mDefRoll.GetFieldValueAsFloat('X_vychystano'));
                                                                                                                                   mDefRoll.SetFieldValueAsString('X_EN_nazev',mMonBatches.BusinessObject[y].GetFieldValueAsString('ID'));


                                                                                                                                   //mMonBatches.BusinessObject[xxx].setFieldValueAsFloat('Quantity',mDefRoll.GetFieldValueAsFloat('X_vychystano'));
                                                                                                                                    //mrows.BusinessObject[xx].setFieldValueAsFloat('Quantity',(mrows.BusinessObject[xx].getFieldValueAsFloat('Quantity')-mpocet));
                                                                                                                                    //if not NxIsBlank(mDefRoll.GetFieldValueAsString('X_Store_ID')) then
                                                                                                                                    //mRowsOutput.BusinessObject[xx].SetFieldValueAsString('Store_ID',mDefRoll.GetFieldValueAsString('X_Store_ID'));


                                                                                                                                    //NxShowSimpleMessage('Save temp',nil);
                                                                                                                                    mDefRoll.save;


                                                                                                                      finally

                                                                                                                          mDefRoll.free;
                                                                                                                      end;




                                                                                                                  //mMonBatches.BusinessObject[xxx].setFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(mbatchlist.Strings[y],11,10)));
                                                                                                                  //mRowsOutput.BusinessObject[xx].setFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(mbatchlist.Strings[y],11,10)));
                                                                                                             end;

                                                                                                   end;


                                                                                              end;

                                                                                            //  mMonbatch:=mMonBatches.AddNewObject;
                                                                                            //        mMonbatch.SetFieldValueAsString('StoreBatch_ID','J600000S01');
                                                                                   end;


                                       mFind:=true;
                                   end;
                             end;


                        end;
             msave:=false;

//    mRowsOutput := mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
    for xx:=0 to mRowsOutput.count-1 do begin   // řádek
                                                                  if mRowsOutput.BusinessObject[xx].GetFieldValueAsinteger('rowtype')=3 then begin   // skladový řádek
                                                                      if mRowsOutput.BusinessObject[xx].GetFieldValueAsinteger('StoreCard_ID.category')=2 then begin
                                                                             mpocet:=0;
                                                                             mMonBatches :=  mRowsOutput.BusinessObject[xx].GetLoadedCollectionMonikerForFieldCode( mRowsOutput.BusinessObject[xx].GetFieldCode('DocRowBatches'));
                                                                                  for xxx := 0 to mMonBatches.Count - 1 do begin
                                                                                      mMonBatches.BusinessObject[xxx].setFieldValueAsFloat('Quantity',mMonBatches.BusinessObject[xxx].getFieldValueAsFloat('X_Quantity'));
                                                                                      mpocet:=mpocet+mMonBatches.BusinessObject[xxx].getFieldValueAsFloat('X_Quantity');
                                                                                      if (mMonBatches.BusinessObject[xxx].getFieldValueAsFloat('X_Quantity')=0)
                                                                                      //or mMonBatches.BusinessObject[xxx].GetFieldValueAsBoolean('X_Markfordelete')
                                                                                      then begin
                                                                                            mMonBatches.BusinessObject[xxx].MarkForDelete;
                                                                                      end else begin
                                                                                          msave:=true;
                                                                                      end;
                                                                                  end;
                                                                                  mRowsOutput.BusinessObject[xx].setFieldValueAsFloat('Quantity',mpocet);
                                                                                  if (mRowsOutput.BusinessObject[xx].getFieldValueAsFloat('Quantity')= 0)
                                                                                  // or (mRowsOutput.BusinessObject[xx].GetFieldValueAsBoolean('X_markfordelete'))
                                                                                  then begin
                                                                                       mRowsOutput.BusinessObject[xx].MarkForDelete;
                                                                                  end else begin
                                                                                      msave:=true;
                                                                                  end;
                                                                      end;
                                                                  end;
                                                                  //if (mRowsOutput.BusinessObject[xx].GetFieldValueAsFloat('Quantity')=0)
                                                                  //      or (mRowsOutput.BusinessObject[xx].GetFieldValueAsBoolean('X_markfordelete')) then mRowsOutput.BusinessObject[xx].MarkForDelete;
                                                               end;


   end;

      msave:=true;

         if msave then begin
              mImportMan.CheckOutputDocument;
                            // NxShowSimpleMessage('Ukladani',nil);
                            mImportMan.OutputDocument.ClearValidateErrors;
                                      if Not mImportMan.OutputDocument.Validate() then begin
                                            mValidateList := TStringList.Create;
                                            try
                                               mImportMan.OutputDocument.GetValidateErrors(mValidateList);
                                               mText := mValidateList.Text;
                                               NxToken(mText, '=');
                                               MessageDlg('Automaticky vytvořendoklad nelze uložit z těchto důvodů:' + #13#10 + mText,

                                               mtWarning, [mbOK], 0);
                                             finally
                                               mValidateList.Free;
                                             end;
                                             //NxShowSimpleMessage('Chyba',nil);
                                             TDynSiteForm.ShowDynFormWithNewDocument('NN20CW0TDQSODH2FPC5IVSYIKW', TBusRollSiteForm(msite).SiteContext, mImportMan.OutputDocument);
                                             result:='Chyba';
                                      end else begin
                                          // TDynSiteForm.ShowDynFormWithNewDocument('NN20CW0TDQSODH2FPC5IVSYIKW', TBusRollSiteForm(mSite).SiteContext, mImportMan.OutputDocument);
                                           mImportMan.OutputDocument.Save;
                                           //NxShowSimpleMessage('Doklad uložen',nil);
                                           result:=mImportMan.OutputDocument.oid;
                                          //NxShowSimpleMessage('Byl vytvořen doklad',nil);


                                      end;

                      end else begin
                          result:='Bez řádků , neuloženo';
                      end;
         //result:=mImportMan.OutputDocument.oid;
      finally
        mImportMan.Free;
      end;
    finally
      mInputParams.Free;
      //mValidateList.Free;
    end;
   result:='ok';
end;




     procedure ShowSelectedDynForm1(AForm: TSiteForm; AOIDs: TStrings; AFormCLSID: string; ASelCaption: string);
var
  mPars: TNxParameters;
  mParameter: TNxParameter;
begin
  if AOIDs.Count> 0 then begin
    mPars := TNxParameters.Create;
    try
      mPars.NewFromDataType(dtString, '_SelectionCaption', pkUnknown).AsString := ASelCaption;
      mParameter := mPars.NewFromDataType(dtList, '_DefaultSelection', pkUnknown);
      mParameter := mParameter.AsList.NewFromDataType(dtList, 'CONDITIONS', pkUnknown) ;
      mParameter := mParameter.AsList.NewFromDataType(dtList, 'ID', pkUnknown);
      mParameter.AsList.NewFromDataType(dtInteger, 'USEDKIND', pkUnknown).AsInteger := 3;
      mParameter.AsList.NewFromDataType(dtString, 'VALUELIST', pkUnknown).AsString := NxStringsTockListStr(AOIDs);
      AForm.ShowDynForm(AFormCLSID, mPars, nil, True, '');
    finally
      mPars.Free;
    end;
  end ;
end ;









procedure Rucne(Sender: TAction; Index: integer);
var
 mbo:TNxCustomBusinessObject;
 mSite: TSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 x,i:integer;
 mtext:string;
 mpocet:double;
 mbonew:TNxCustomBusinessObject;
 mOLE, mRoll, mOResult: Variant;
begin
   mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
     mtext:=InputBox('Zadej zdrohový doklad','ID Dokladu',mtext);



       {

     mOLE:= GetAbraOLEApplication;
        mOResult:= mOLE.CreateStrings;
        mRoll:= mOLE.GetAgenda('S1X0KZC0NJE13C5U00CA141B44', 0);
                          if not mRoll.MultiSelectDialog(False, mOResult) then Exit;
                                mids1:= TStringList.Create;
                                try
                                  mids1.Text:= mOResult.Text;

        }



     mpocet:=NxIBStrToFloat(copy(mtext,51,10));
     if mpocet<>TBusRollSiteForm(msite).CurrentObject.getFieldValueAsFloat('X_Quantity') then begin

     mbonew:=TBusRollSiteForm(mSite).CurrentObject;
     mbonew.new;
     mbonew.prefill;
     mbonew.SetFieldValueAsString('X_CreatedBy_ID', msite.CompanyCache.GetUserID);

        mbonew.SetFieldValueAsString('Code',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('Code'));
                                               TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_parent_ID',copy(mtext,1,10));
                                               TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_parent2_id',copy(mtext,11,10));
                                               TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_DEVENOLUX',copy(mtext,21,10));
                                               TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_MX_NAZEV',copy(mtext,31,10));
                                               TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_DE_NAZEV',copy(mtext,41,10));
                                               TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_vychystano',NxIBStrToFloat(copy(mtext,51,10)));
                                               TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_PM_State','1050000101');

                                               mpocet:=TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsFloat('X_quantity') -TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsFloat('X_vychystano');
                                                mbonew.SetFieldValueAsString('Name',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('name'));
                                                mbonew.SetFieldValueAsString('X_firm_ID',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'));
                                                mbonew.SetFieldValueAsString('X_Storecard_ID',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Storecard_ID'));
                                                mbonew.SetFieldValueAsString('X_Batches',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches'));
                                                mbonew.SetFieldValueAsFloat('X_quantity',mpocet);
                                                mbonew.SetFieldValueAsDateTime('X_ABRADate',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsDateTime('X_ABRADate'));
                                                mbonew.SetFieldValueAsFloat('X_vychystano',mpocet);
                                                mbonew.SetFieldValueAsString('X_PM_State','2020000101');
                                                mbonew.SetFieldValueAsString('X_CLSID','O3BDOKTWEFD13ACM03KIU0CLP4');

                                                mbonew.save;


      TBusRollSiteForm(msite).CurrentObject.SetFieldValueAsFloat('X_Quantity',(TBusRollSiteForm(msite).CurrentObject.getFieldValueAsFloat('X_Quantity') -mpocet)) ;
      TBusRollSiteForm(msite).CurrentObject.save;

     end else begin
        TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_parent_ID',copy(mtext,1,10));
           TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_parent2_id',copy(mtext,11,10));
           TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_DEVENOLUX',copy(mtext,21,10));
           TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_MX_NAZEV',copy(mtext,31,10));
           TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_DE_NAZEV',copy(mtext,41,10));
           TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_vychystano',NxIBStrToFloat(copy(mtext,51,10)));
           TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_PM_State','1050000101');
           mpocet:=TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsFloat('X_quantity') -TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsFloat('X_vychystano');




     TBusRollSiteForm(msite).CurrentObject.save;
     end;



  TBusRollSiteForm(mSite).DataSet.RefreshCurrentItem;

end;






 procedure testnew(Sender: TAction; Index: integer);
var
 mbo:TNxCustomBusinessObject;
 mSite: TSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 x,i:integer;
 mtext:string;
 mpocet:double;
 mTMPBO:TNxCustomBusinessObject;
 mr:tstringlist;
begin
   mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');


         mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu

    ProgressInit(msite, 'Hledání souborů ' + '', 100);
    if mBookmark.count=0 then begin
            if index=5 then begin
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_Parent_ID','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_Parent2_ID','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_vychystano',0);
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_dodano',0);
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_PM_State','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_CLSID','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_EN_NAZEV','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_DE_NAZEV','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_DEVENOLUX','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_MX_NAZEV','');
                  TBusRollSiteForm(mSite).CurrentObject.save;
                  //TBusRollSiteForm(mSite).DataSet.RefreshCurrentItem;
           end else begin
                 mTMPBO:=TBusRollSiteForm(mSite).CurrentObject;
                  mpocet:=TBusRollSiteForm(msite).CurrentObject.getFieldValueAsFloat('X_Quantity') ;
                 if (index=0) then begin
                             if not nxisemptyoid(mTMPBO.getFieldValueAsstring('X_batches')) then begin
                                 if mpocet>0 then begin
                                      mpocet:=FindStoreBatchFV(msite.BaseObjectSpace,mTMPBO,mpocet,index);
                                      if mShowDebug then NxShowSimpleMessage('po dobropisech zvývá ' + NxFloatToIBStr(mpocet),nil);
                                 end;
                             end;



                  end;




                  if (index=2) then begin
                             if not nxisemptyoid(mTMPBO.getFieldValueAsstring('X_batches')) then begin
                                 if mpocet>0 then begin
                                      mpocet:=FindStoreBatchFV(msite.BaseObjectSpace,mTMPBO,mpocet,index);
                                      if mShowDebug then NxShowSimpleMessage('po dobropisech zvývá ' + NxFloatToIBStr(mpocet),nil);
                                 end;
                              end;



                  end;
            end;
    end else begin
        for x := 0 to mBookmark.Count- 1 do begin
                          mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(x));
                          ProgressSetPos(1+NxFloor(x/mBookmark.Count*99), inttostr(x) +' z '+inttostr(mBookmark.Count));
          if index=5 then begin
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_Parent_ID','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_Parent2_ID','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_vychystano',0);
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_dodano',0);
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_PM_State','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_CLSID','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_EN_NAZEV','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_DE_NAZEV','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_DEVENOLUX','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_MX_NAZEV','');

                  TBusRollSiteForm(mSite).CurrentObject.save;
                  //TBusRollSiteForm(mSite).DataSet.RefreshCurrentItem;
           end else begin
                 mTMPBO:=TBusRollSiteForm(mSite).CurrentObject;
                  mpocet:=mTMPBO.getFieldValueAsFloat('X_Quantity') ;
                 if (index=0) then begin
                          if not nxisemptyoid(mTMPBO.getFieldValueAsstring('X_batches')) then begin

                                     if mpocet>0 then begin
                                          mpocet:=FindStoreBatchFV(msite.BaseObjectSpace,mTMPBO,mpocet,index);
                                          if mShowDebug then NxShowSimpleMessage('po dobropisech zvývá ' + NxFloatToIBStr(mpocet),nil);
                                     end;

                                  //   if mpocet>0 then begin
                                  //        mpocet:=FindStoreBatchDL(msite,mTMPBO,mpocet,index);
                                  //        if mShowDebug then NxShowSimpleMessage('po vratkách zvývá ' + NxFloatToIBStr(mpocet),nil);
                                  //   end;

                                     if mpocet>0 then begin
                                            if mTMPBO.getfieldvalueasstring('X_Parent_ID')<>'' then begin
                                              //  novyzaznam(msite,mTMPBO,mpocet);
                                            end;
                                      end;
                           end;

                  end;


                  if (index=2) then begin
                             if not nxisemptyoid(mTMPBO.getFieldValueAsstring('X_batches')) then begin
                                   if mpocet>0 then begin
                                        mpocet:=FindStoreBatchFV(msite.BaseObjectSpace,mTMPBO,mpocet,index);
                                        if mShowDebug then NxShowSimpleMessage('po dobropisech zvývá ' + NxFloatToIBStr(mpocet),nil);
                                   end;
                             end;



                  end;
            end;
        end;
        //**** korekce



      end;

ProgressDispose()   ;
end;





procedure _SaveObject_PreHook(Self: TBusRollSiteForm; AObject: TNxCustomBusinessObject);
begin
   if NxIsEmptyOID(AObject.getFieldValueAsString('X_storeCard_ID')) then begin
     if not nxisemptyoid(AObject.getFieldValueAsString('X_Batches')) then begin
           AObject.setFieldValueAsString('X_storeCard_ID',AObject.getFieldValueAsString('X_Batches.Storecard_ID'));
     end;
   end;
end;



 procedure Correct(Sender: TAction; Index: integer);
var
 mbo:TNxCustomBusinessObject;
 mSite: TSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 x,i:integer;
 mtext:string;
 mpocet:double;
 mTMPBO,mbonew:TNxCustomBusinessObject;
 mr:tstringlist;
begin
   mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');


         mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu

    ProgressInit(msite, 'Hledání souborů ' + '', 100);
    if mBookmark.count=0 then begin

          mr:=tstringlist.create;
                           try
                              msite.BaseObjectSpace.SQLSelect('select sum(quantity) from DocRowBatches where id=' + QuotedStr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsstring('X_EN_NAZEV')),mr);
                              if mr.count>0 then begin


                                    if NxIBStrToFloat(mr.Strings[0])<> TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsFloat('X_Quantity') then begin
                                        if TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsstring('X_EN_NAZEV') <>'' then begin

                                                      mpocet:=TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsFloat('X_Quantity')-NxIBStrToFloat(mr.Strings[0]);

                                                       TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_Quantity',(TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsFloat('X_Quantity') - mpocet))   ;
                                                       TBusRollSiteForm(mSite).CurrentObject.save;

                                                       mbonew:=TBusRollSiteForm(mSite).BaseObjectSpace.CreateObject('45D1XVW5EY24JBXTOE01EHYRSG');

                                                            try
                                                            mbonew.new;
                                                                 mbonew.prefill;
                                                                    mbonew.SetFieldValueAsString('X_CreatedBy_ID', msite.CompanyCache.GetUserID);
                                                                    mbonew.SetFieldValueAsString('Code',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('Code'));
                                                                    mbonew.SetFieldValueAsString('Name',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('name'));
                                                                    mbonew.SetFieldValueAsString('X_firm_ID',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'));
                                                                    mbonew.SetFieldValueAsString('X_Storecard_ID',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Storecard_ID'));
                                                                    mbonew.SetFieldValueAsString('X_Batches',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches'));

                                                                    mbonew.SetFieldValueAsDateTime('X_ABRADate',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsDateTime('X_ABRADate'));
                                                                    mbonew.SetFieldValueAsString('X_PM_State','2020000101');
                                                                    mbonew.SetFieldValueAsFloat('X_quantity',mpocet);
                                                                    mbonew.save;
                                                                  //  NxShowSimpleMessage(NxFloatToIBStr(mpocet),nil);
                                                            finally
                                                                mbonew.free;
                                                            end;
                                        end else begin
                                                     TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_parent_ID','');
                                                     TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_parent2_id','');
                                                     TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_DE_NAZEV','');
                                                     TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_DEVENOLUX','');
                                                     TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_MX_NAZEV','');
                                                     TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_vychystano',0);
                                                     TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_PM_State','');
                                                     TBusRollSiteForm(mSite).CurrentObject.save ;
                                        end;

                                    end;
                               end;
                           finally
                               mr.free;
                           end;

    end else begin
        for x := 0 to mBookmark.Count- 1 do begin
                          mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(x));
                          ProgressSetPos(1+NxFloor(x/mBookmark.Count*99), inttostr(x) +' z '+inttostr(mBookmark.Count));

                             mr:=tstringlist.create;
                           try
                              msite.BaseObjectSpace.SQLSelect('select sum(quantity) from DocRowBatches where id=' + QuotedStr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsstring('X_EN_NAZEV')),mr);
                              if mr.count>0 then begin


                                    if NxIBStrToFloat(mr.Strings[0])<> TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsFloat('X_Quantity') then begin
                                        if TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsstring('X_EN_NAZEV') <>'' then begin

                                                      mpocet:=TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsFloat('X_Quantity')-NxIBStrToFloat(mr.Strings[0]);

                                                       TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_Quantity',(TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsFloat('X_Quantity') - mpocet))   ;
                                                       TBusRollSiteForm(mSite).CurrentObject.save;

                                                       mbonew:=TBusRollSiteForm(mSite).BaseObjectSpace.CreateObject('45D1XVW5EY24JBXTOE01EHYRSG');

                                                            try
                                                            mbonew.new;
                                                                 mbonew.prefill;
                                                                    mbonew.SetFieldValueAsString('Code',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('Code'));
                                                                    mbonew.SetFieldValueAsString('Name',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('name'));
                                                                    mbonew.SetFieldValueAsString('X_firm_ID',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'));
                                                                    mbonew.SetFieldValueAsString('X_Storecard_ID',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Storecard_ID'));
                                                                    mbonew.SetFieldValueAsString('X_Batches',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches'));

                                                                    mbonew.SetFieldValueAsDateTime('X_ABRADate',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsDateTime('X_ABRADate'));
                                                                    mbonew.SetFieldValueAsString('X_PM_State','2020000101');
                                                                    mbonew.SetFieldValueAsFloat('X_quantity',mpocet);
                                                                    mbonew.save;
                                                                    //NxShowSimpleMessage(NxFloatToIBStr(mpocet),nil);
                                                            finally
                                                                mbonew.free;
                                                            end;
                                        end else begin
                                                     TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_parent_ID','');
                                                     TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_parent2_id','');
                                                     TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_DE_NAZEV','');
                                                     TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_DEVENOLUX','');
                                                     TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_MX_NAZEV','');
                                                     TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_vychystano',0);
                                                     TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_PM_State','');
                                                     TBusRollSiteForm(mSite).CurrentObject.save ;
                                        end;

                                    end;
                               end;
                           finally
                               mr.free;
                           end;
        end;
        //**** korekce


      end;

ProgressDispose()   ;
end;


















procedure DobropisAllInOne(Sender: TAction; Index: integer);
var
 mbo:TNxCustomBusinessObject;
 mSite: TSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 x,i:integer;
   mForm: TSiteForm;
   mtext:string;
   mB_Result:boolean;
   mi:integer;
   mr,mx,mpomoclist:tstringlist;
   mVolne,mNaDokladu,mNaVratce,mquantity:double;
   mbonew:TNxCustomBusinessObject;
   mImportMan,mImportMan2: TNxDocumentImportManager;
  mOS: TNxCustomObjectSpace;
  mInputParams,mInputParams2: TNxParameters;
  mParam,mParam2: TNxParameter;
  mCollRows: TNxCustomBusinessMonikerCollection;
  xx,xxx: integer;
  mList: TStringList;
  mRow: TNxCustomBusinessObject;

  mValidateList:tstringlist;
  mRowsOutput:TNxCustomBusinessMonikerCollection;
  msave,mFind:boolean;

  mMonBatches:TNxCustomBusinessMonikerCollection;
  mSelectedRows:TStrings;
mListError:tstringlist;
  mpocetdokladu:integer;
  mListNoBatches:tstringlist;
   mstringlist,mxlist,mxxx:tstringlist;
  mnote:string;
  mSTR:string;
  mFaktura,mvratka:tstringlist;
  msearch:Boolean;
  msvratka:string;
begin
   mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    mFaktura:=TStringList.create;
    mvratka:=TStringList.create;




    //mB_Result:=InputQuery('Zadaj parametry', 'Změna ', mtext);
    ProgressInit(msite, 'Načtení souboru ' + '', 100);

                      if mBookmark.count=0 then begin



                      end else begin
                           for x := 0 to mBookmark.Count- 1 do begin
                                            mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(x));
                                            ProgressSetPos(1+NxFloor(x/mBookmark.Count*99), inttostr(x) +' z '+inttostr(mBookmark.Count));
                                            //if x=0 then begin
                                                  //mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader'); // musi se z nejake hlavicky prebirat hlavickova data

                                                   msearch:=false;
                                                                                 for i:=0 to mFaktura.count-1 do begin
                                                                                        if copy(mFaktura.strings[i],1,10)=TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Parent_ID') then msearch:=true;
                                                                                 end;
                                                                                 if not msearch then begin

                                                                                       mFaktura.add(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Parent_ID') + NxFloatToIBStr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsDateTime('X_ABRADate')));

                                                                                 end;

                                                    msearch:=false;

                                                                                 mSVratka:='';
                                                                                 mSVratka:=mSite.BaseObjectSpace.SQLSelectFirstAsString('Select sd.id from docrowbatches DRB join storedocuments2 sd2 on sd2.id=drb.parent_ID join storedocuments SD on sd.id=sd2.parent_ID where drb.id=' + quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_EN_NAZEV')));

                                                                                 for i:=0 to mvratka.count-1 do begin
                                                                                        if copy(mvratka.strings[i],1,10)=mSVratka then msearch:=true;
                                                                                 end;
                                                                                 if not msearch then begin

                                                                                       mvratka.add(mSVratka + NxFloatToIBStr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsDateTime('X_ABRADate')));

                                                                                 end;





//                                                  mParam.AsString := TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Parent_ID');
                                            //end;

                           end;
                      end;

                  ProgressDispose()   ;
                                  mFaktura.sort;
                                      mImportMan := NxCreateDocumentImportManager(TBusRollSiteForm(mSite).BaseObjectSpace, 'O3BDOKTWEFD13ACM03KIU0CLP4', 'W402MSU3BBDL3ACR03KIU0CLP4');

                                      mInputParams := TNxParameters.Create;
                                                        mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                                                            mParam.AsString := mDocqueue_ID_DFV;
                                                        mParam := mInputParams.GetOrCreateParam(dtString, 'StoreDocQueue_ID');
                                                            mParam.AsString := mDocqueue_ID_VRDL;
                                                        mParam := mInputParams.GetOrCreateParam(dtBoolean, 'DoNotImportRowTypeText');
                                                            mParam.AsBoolean := True;
                                                        mParam := mInputParams.GetOrCreateParam(dtBoolean, 'DoNotImportChargesSerialNumbers');
                                                            mParam.AsBoolean := True;
                                                        mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows');
                                                            mParam.AsString := '';



                                   for x := 0 to mFaktura.Count- 1 do begin
                                                   mImportMan.AddInputDocument(copy(mFaktura.strings[x],1,10));
                                   end;

                                   mImportMan.LoadParams(mInputParams);
                                   //mImportMan.AddInputDocument(copy(mFaktura.strings[x],1,10));
                                   mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader'); // musi se z nejake hlavicky prebirat hlavickova data
                                   mParam.AsString := copy(mFaktura.strings[0],1,10);

                                                                        mImportMan.Execute;
                                                                       // mImportMan.CheckOutputDocument;




                                                               mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID','2781000101');
                                                               mImportMan.OutputDocument.SetFieldValueAsDateTime('DocDate$Date', TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsDateTime('X_ABRADate'));
                                                               mImportMan.OutputDocument.SetFieldValueAsInteger('Acknowledge',1) ;
                                                               mImportMan.OutputDocument.SetFieldValueAsString('ReasonDescription','Vrácení ' + FormatDateTime('YYYY/MM',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsDateTime('X_ABRADate')));
                                                               mImportMan.OutputDocument.SetFieldValueAsString('Description','Vrácení ' + FormatDateTime('YYYY/MM',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsDateTime('X_ABRADate')));

                                                               if  mImportMan.OutputDocument.getFieldValueAsString('Firm_ID.NAme')='LIPOELASTIC s.r.o.' then begin
                                                                        mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID','2B10000101');
                                                                        mImportMan.OutputDocument.SetFieldValueAsString('ReasonDescription','Vrácení zboží ' + FormatDateTime('YYYY/MM',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsDateTime('X_ABRADate')));
                                                                        mImportMan.OutputDocument.SetFieldValueAsString('Description','Vrácení zboží' + FormatDateTime('YYYY/MM',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsDateTime('X_ABRADate')));
                                                               end;

                                                               mImportMan.OutputDocument.SetFieldValueAsString('IntrastatDeliveryTerm_ID','3001000000')  ;
                                                               mImportMan.OutputDocument.SetFieldValueAsString('IntrastatTransportationType_ID','4000000000')  ;
                                                               mImportMan.OutputDocument.SetFieldValueAsString('IntrastatTransactionType_ID','6001000000')  ;


//
                                                                       mRowsOutput := mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));

                                                                       for i:=0 to mRowsOutput.count-1 do begin

                                                                            if (trim(mRowsOutput.BusinessObject[i].GetFieldValueAsString('ProvideRowDisplayName'))='Bez čísla') or (trim(mRowsOutput.BusinessObject[i].GetFieldValueAsString('ProvideRowDisplayName'))='') then begin

                                                                                  mRowsOutput.BusinessObject[i].MarkForDelete;

                                                                            end else begin
                                                                                 //NxShowSimpleMessage(mRowsOutput.BusinessObject[i].GetFieldValueAsString('ProvideRowDisplayName'),nil) ;
                                                                            end;
                                                                       end;




                                                                     {

                                                                      for x := 0 to mvratka.Count- 1 do begin
                                                                           mImportMan2 := NxCreateDocumentImportManager(TBusRollSiteForm(mSite).BaseObjectSpace, '1T0I5SAOS3DL3ACU03KIU0CLP4', 'W402MSU3BBDL3ACR03KIU0CLP4');
                                                                           mImportMan2.OutputDocument:=mImportMan.OutputDocument;

                                                                           mInputParams2 := TNxParameters.Create;
                                                                            //    mParam2 := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                                                                            //        mParam2.AsString := mDocqueue_ID_DFV;
                                                                            //    mParam2 := mInputParams.GetOrCreateParam(dtString, 'StoreDocQueue_ID');
                                                                            //        mParam2.AsString := mDocqueue_ID_VRDL;
                                                                            //    mParam2 := mInputParams.GetOrCreateParam(dtBoolean, 'DoNotImportRowTypeText');
                                                                            //        mParam2.AsBoolean := True;
                                                                            //    mParam2 := mInputParams.GetOrCreateParam(dtBoolean, 'DoNotImportChargesSerialNumbers');
                                                                            //        mParam2.AsBoolean := True;




                                                                             for x := 0 to mvratka.Count- 1 do begin
                                                                                             mImportMan2.AddInputDocument(copy(mvratka.strings[x],1,10));
                                                                             end;

                                                           mImportMan2.LoadParams(mInputParams2);
                                                           //mImportMan2.AddInputDocument(copy(mFaktura.strings[x],1,10));
                                                           //mParam2 := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader'); // musi se z nejake hlavicky prebirat hlavickova data
                                                           //mParam2.AsString := copy(mFaktura.strings[0],1,10);

                                                                                                mImportMan2.Execute;


                                                                      end;     }










                                                                       mImportMan.OutputDocument.ClearValidateErrors;
                                                                                      if true then begin // Not mImportMan.OutputDocument.Validate() then begin
                                                                                            mValidateList := TStringList.Create;
                                                                                            try
                                                                                               mImportMan.OutputDocument.GetValidateErrors(mValidateList);
                                                                                               mText := mValidateList.Text;
                                                                                               NxToken(mText, '=');
                                                                                               MessageDlg('Automaticky vytvořendoklad nelze uložit z těchto důvodů:' + #13#10 + mText,

                                                                                               mtWarning, [mbOK], 0);
                                                                                             finally
                                                                                               mValidateList.Free;
                                                                                             end;
                                                                                             //NxShowSimpleMessage('Chyba',nil);
                                                                                             TDynSiteForm.ShowDynFormWithNewDocument('T1C2EX0BUJD13ACP03KIU0CLP4', TBusRollSiteForm(msite).SiteContext, mImportMan.OutputDocument);
                                                                                      end else begin
                                                                                           TDynSiteForm.ShowDynFormWithNewDocument('T1C2EX0BUJD13ACP03KIU0CLP4', TBusRollSiteForm(msite).SiteContext, mImportMan.OutputDocument);
                                                                                           //mImportMan.OutputDocument.Save;
                                                                                           //NxShowSimpleMessage('Doklad uložen',nil);
                                                                                          //NxShowSimpleMessage('Byl vytvořen doklad',nil);

                                                                                      end;

             //finally
                mInputParams.free;
                mImportMan.free;
           //  end;


       mFaktura.free;
       mvratka.free;
       TBusRollSiteForm(mSite).RefreshData;
       TBusRollSiteForm(mSite).Refresh;
end;











procedure Dobropis(Sender: TAction; Index: integer);
var
 mbo:TNxCustomBusinessObject;
 mSite: TSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 x,i:integer;
   mForm: TSiteForm;
   mtext:string;
   mB_Result:boolean;
   mi:integer;
   mr,mx,mpomoclist:tstringlist;
   mVolne,mNaDokladu,mNaVratce,mquantity:double;
   mbonew:TNxCustomBusinessObject;
   mImportMan: TNxDocumentImportManager;
  mOS: TNxCustomObjectSpace;
  mInputParams: TNxParameters;
  mParam: TNxParameter;
  mCollRows: TNxCustomBusinessMonikerCollection;
  xx,xxx: integer;
  mList: TStringList;
  mRow: TNxCustomBusinessObject;

  mValidateList:tstringlist;
  mRowsOutput:TNxCustomBusinessMonikerCollection;
  msave,mFind:boolean;

  mMonBatches:TNxCustomBusinessMonikerCollection;
  mSelectedRows:TStrings;
mListError:tstringlist;
  mpocetdokladu:integer;
  mListNoBatches:tstringlist;
   mstringlist,mxlist,mxxx:tstringlist;
  mnote:string;
  mSTR:string;
  mFaktura:tstringlist;
  msearch:Boolean;
begin
   mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    mFaktura:=TStringList.create;




    //mB_Result:=InputQuery('Zadaj parametry', 'Změna ', mtext);
    ProgressInit(msite, 'Načtení souboru ' + '', 100);

                      if mBookmark.count=0 then begin



                      end else begin
                           for x := 0 to mBookmark.Count- 1 do begin
                                            mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(x));
                                            ProgressSetPos(1+NxFloor(x/mBookmark.Count*99), inttostr(x) +' z '+inttostr(mBookmark.Count));
                                            //if x=0 then begin
                                                  //mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader'); // musi se z nejake hlavicky prebirat hlavickova data

                                                   msearch:=false;
                                                                                 for i:=0 to mFaktura.count-1 do begin
                                                                                        if copy(mFaktura.strings[i],1,10)=TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Parent_ID') then msearch:=true;
                                                                                 end;
                                                                                 if not msearch then begin

                                                                                       mFaktura.add(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Parent_ID') + NxFloatToIBStr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsDateTime('X_ABRADate')));

                                                                                 end;






//                                                  mParam.AsString := TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Parent_ID');
                                            //end;

                           end;
                      end;

                  ProgressDispose()   ;







    mFaktura.sort;
         for x := 0 to mFaktura.Count- 1 do begin

                          mInputParams := TNxParameters.Create;
                          mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                              mParam.AsString := mDocqueue_ID_DFV;
                          mParam := mInputParams.GetOrCreateParam(dtString, 'StoreDocQueue_ID');
                              mParam.AsString := mDocqueue_ID_VRDL;
                          mParam := mInputParams.GetOrCreateParam(dtBoolean, 'DoNotImportRowTypeText');
                              mParam.AsBoolean := True;
                          mParam := mInputParams.GetOrCreateParam(dtBoolean, 'DoNotImportChargesSerialNumbers');
                              mParam.AsBoolean := True;
                         // mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader'); // musi se z nejake hlavicky prebirat hlavickova data
                        //      mParam.AsString := copy(mFaktura.strings[x],1,10);


                      mImportMan := NxCreateDocumentImportManager(TBusRollSiteForm(mSite).BaseObjectSpace, 'O3BDOKTWEFD13ACM03KIU0CLP4', 'W402MSU3BBDL3ACR03KIU0CLP4');
                      try
                         mImportMan.AddInputDocument(copy(mFaktura.strings[x],1,10));
                                   mImportMan.LoadParams(mInputParams);
                                   //mImportMan.AddInputDocument(copy(mFaktura.strings[x],1,10));
                                   mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader'); // musi se z nejake hlavicky prebirat hlavickova data
                                   mParam.AsString := copy(mFaktura.strings[x],1,10);

                                                                        mImportMan.Execute;
                                                                       // mImportMan.CheckOutputDocument;




                                                               mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID','2781000101');
                                                               mImportMan.OutputDocument.SetFieldValueAsDateTime('DocDate$Date', TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsDateTime('X_ABRADate'));
                                                               mImportMan.OutputDocument.SetFieldValueAsInteger('Acknowledge',1) ;
                                                               mImportMan.OutputDocument.SetFieldValueAsString('ReasonDescription','Vrácení ' + FormatDateTime('YYYY/MM',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsDateTime('X_ABRADate')));
                                                               mImportMan.OutputDocument.SetFieldValueAsString('Description','Vrácení ' + FormatDateTime('YYYY/MM',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsDateTime('X_ABRADate')));

                                                               if  mImportMan.OutputDocument.getFieldValueAsString('Firm_ID.NAme')='LIPOELASTIC s.r.o.' then begin
                                                                        mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID','2B10000101');
                                                                        mImportMan.OutputDocument.SetFieldValueAsString('ReasonDescription','Vrácení zboží ' + FormatDateTime('YYYY/MM',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsDateTime('X_ABRADate')));
                                                                        mImportMan.OutputDocument.SetFieldValueAsString('Description','Vrácení zboží' + FormatDateTime('YYYY/MM',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsDateTime('X_ABRADate')));
                                                               end;

                                                               mImportMan.OutputDocument.SetFieldValueAsString('IntrastatDeliveryTerm_ID','3001000000')  ;
                                                               mImportMan.OutputDocument.SetFieldValueAsString('IntrastatTransportationType_ID','4000000000')  ;
                                                               mImportMan.OutputDocument.SetFieldValueAsString('IntrastatTransactionType_ID','6001000000')  ;


//
                                                                       mRowsOutput := mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));

                                                                       for i:=0 to mRowsOutput.count-1 do begin

                                                                            //if mRowsOutput.BusinessObject[i].GetFieldValueAsString('ProvideRowDisplayName')='Bez čísla' then begin
                                                                            //
                                                                           //       mRowsOutput.BusinessObject[i].MarkForDelete;
                                                                            //end else begin
                                                                            //     NxShowSimpleMessage(mRowsOutput.BusinessObject[i].GetFieldValueAsString('ProvideRowDisplayName'),nil) ;
                                                                            //end;
                                                                       end;





                                                                       mImportMan.OutputDocument.ClearValidateErrors;
                                                                                      if true then begin // Not mImportMan.OutputDocument.Validate() then begin
                                                                                            mValidateList := TStringList.Create;
                                                                                            try
                                                                                               mImportMan.OutputDocument.GetValidateErrors(mValidateList);
                                                                                               mText := mValidateList.Text;
                                                                                               NxToken(mText, '=');
                                                                                               MessageDlg('Automaticky vytvořendoklad nelze uložit z těchto důvodů:' + #13#10 + mText,

                                                                                               mtWarning, [mbOK], 0);
                                                                                             finally
                                                                                               mValidateList.Free;
                                                                                             end;
                                                                                             //NxShowSimpleMessage('Chyba',nil);
                                                                                             TDynSiteForm.ShowDynFormWithNewDocument('T1C2EX0BUJD13ACP03KIU0CLP4', TBusRollSiteForm(msite).SiteContext, mImportMan.OutputDocument);
                                                                                      end else begin
                                                                                           TDynSiteForm.ShowDynFormWithNewDocument('T1C2EX0BUJD13ACP03KIU0CLP4', TBusRollSiteForm(msite).SiteContext, mImportMan.OutputDocument);
                                                                                           //mImportMan.OutputDocument.Save;
                                                                                           //NxShowSimpleMessage('Doklad uložen',nil);
                                                                                          //NxShowSimpleMessage('Byl vytvořen doklad',nil);

                                                                                      end;

             finally
                mInputParams.free;
                mImportMan.free;
             end;
         end;

       mFaktura.free;
       TBusRollSiteForm(mSite).RefreshData;
       TBusRollSiteForm(mSite).Refresh;
end;








     procedure CheckDocumentSC(Sender: TAction; Index: integer);
var
 mbo,mboNew:TNxCustomBusinessObject;
 mSite: TSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 x,i:integer;
   mForm: TBusRollSiteForm;
   mtext:string;
   mB_Result:boolean;
   mi:integer;
   mr,mx:tstringlist;
   mVolne,mNaDokladu,mNaVratce,mquantity:double;
   msave:Boolean;
   mQuantityTemp,mQuantityVratka,mQuantityDoc, mQuantityPomoc, mQuantitySource:double;
   mBoolean:boolean;
begin
  msite:=TComponent(Sender).Site;
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    mbo:= TBusRollSiteForm(mSite).CurrentObject;
    //mB_Result:=InputQuery('Zadaj parametry', 'Změna ', mtext);

    ProgressInit(msite, 'Hledání souborů ' + '', 100);
    if mBookmark.count=0 then begin
           if index=5 then begin
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_Parent_ID','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_Parent2_ID','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_vychystano',0);
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_dodano',0);
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_PM_State','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_CLSID','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_EN_NAZEV','');

                  TBusRollSiteForm(mSite).CurrentObject.save;
                  TBusRollSiteForm(mSite).DataSet.RefreshCurrentItem;
           end else begin
                              mQuantitySource:=0;
                              mQuantitySource:= TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsFloat('X_Quantity');
                              mQuantityPomoc:=mQuantitySource-TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsFloat('X_vychystano');
                              mr:=TStringList.create;
                              try

                              if index=0 then begin
//                                                 if ((not NxIsEmptyOID(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches'))) and
//                                                    (TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsinteger('X_Storecard_ID.Category')=2)) then


                                                   mSite.BaseObjectSpace.SQLSelect('SELECT  ii.id||ii2.id||CAST(ii2.quantity AS VARCHAR(10)) '+
                                                                                         '  FROM  Storedocuments2 SD2 '+
                                                                                         '       join Storedocuments SD  ON sd.ID=sd2.parent_ID '+
                                                                                          '      left join IssuedInvoices2 ii2  on ii2.Providerow_ID=sd2.id '+
                                                                                          '      join IssuedInvoices ii  ON ii2.Parent_ID=ii.ID '+
                                                                                          '      join Firms F on f.id=ii.Firm_ID '+
                                                                                          '      WHERE SD.DocumentType=' + quotedstr('21') + ' and (F.ID=' +quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID')) + ' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+')) ) and  (SD2.Storecard_ID = '+ quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Storecard_ID')) +')  '+
                                                                                          '      and (not exists (SELECT 1 FROM Docrowbatches where Parent_ID=SD2.ID )) ' +
                                                                                          '     order by ii2.quantity desc ',mr) ;
                              end;

                              if index=1 then begin
//                                                 if ((not NxIsEmptyOID(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches'))) and
//                                                    (TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsinteger('X_Storecard_ID.Category')=2)) then
                                                   mSite.BaseObjectSpace.SQLSelect('SELECT  sd.id||sd2.id||CAST(sd2.quantity AS VARCHAR(10)) '+
                                                                                    ' FROM StoreDocuments2 sd2  '+
                                                                                    ' join StoreDocuments sd ON sd2.Parent_ID=sd.ID '+
                                                                                    ' join Firms F on f.id=SD.Firm_ID ' +
                                                                                    ' left join DocRowBatches DRB on DRB.Parent_ID= ii2.ProvideRow_ID' +
                                                                                    ' WHERE (F.ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+
                                                                                    ' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+')) )'+
                                                                                    ' and  (SD.Storecard_ID = '+ quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Storecard_ID')) +
                                                                                    ' and sd.DocumentType= ' + quotedstr('20') + ') order by sd2.quantity desc',mr) ;

                              end;


                              if index=4 then begin
                                                 if ((not NxIsEmptyOID(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches'))) and
                                                    (TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsinteger('X_Storecard_ID.Category')=2)) then
                                                   mSite.BaseObjectSpace.SQLSelect('SELECT  sd.id||sd2.id||CAST(sd2.quantity AS VARCHAR(10)) '+
                                                                                         '  FROM  Storedocuments2 SD2 '+
                                                                                         '       join Storedocuments SD  ON sd.ID=sd2.parent_ID '+

                                                                                          '      join Firms F on f.id=sd.Firm_ID '+
                                                                                          '      WHERE SD.DocumentType=' + quotedstr('21') + ' and (F.ID=' +quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID')) + ' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+')) ) and  (SD2.Storecard_ID = '+ quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Storecard_ID')) +')  '+
                                                                                          '      and (not exists (SELECT 1 FROM Docrowbatches where Parent_ID=SD2.ID )) ' +
                                                                                          '     order by sd2.quantity desc ',mr) ;







                              end;



                                    if mShowDebug then  NxShowSimpleMessage('Počet nálezů ' +  inttostr(mr.count),nil);
                                    for i:=0 to mr.count-1 do begin
                                            if mShowDebug then NxShowSimpleMessage(mr.Strings[i],nil);

                                            mQuantityDoc:=NxIBStrToFloat(copy(mr.Strings[0],21,10));
                                             if mShowDebug then NxShowSimpleMessage(' Množství ' + NxFloatToIBStr(mQuantityDoc),nil);
                                             if mShowDebug then NxShowSimpleMessage(' mQuantity pomoc ' + NxFloatToIBStr(mQuantityPomoc),nil);

                                      if mQuantityPomoc>0  then begin

                                            mQuantityVratka:=0;
                                            try
                                            if index=0 then begin
                                            // ******** již vráceno

                                                          mx:=tstringlist.create;
                                                           try
                                                                 msite.BaseObjectSpace.SQLSelect('select sum(x.quantity) from IssuedCreditNotes2 x where x.RSource_ID=' + QuotedStr(copy(mr.Strings[0],11,10)),mx);
                                                                 if mx.count>0 then mQuantityVratka:=NxIBStrToFloat(mx.Strings[0]) else mQuantityVratka:=0;
                                                                 if mShowDebug then nxShowSimpleMessage('z ' + copy(mr.Strings[0],21,10) + ' vráceno ' +  NxFloatToIBStr(mQuantityVratka),nil);

                                                           finally
                                                               mx.free;
                                                           end;
                                             end;
                                             finally

                                             end;
                                                 //   ***** v temp již použito
                                                 mx:=tstringlist.create;
                                                 try
                                                       msite.BaseObjectSpace.SQLSelect('select sum(x.X_quantity) FROM DefRollData X WHERE X.CLSID = ' + QuotedStr('45D1XVW5EY24JBXTOE01EHYRSG') + ' AND x.X_parent2_id=' +
                                                                                       quotedstr(copy(mr.Strings[0],11,10)),mx);
                                                                if mx.count>0 then mQuantityTemp:=NxIBStrToFloat(mx.Strings[0]) else mQuantityTemp:=0;
                                                              if mShowDebug then nxShowSimpleMessage('z ' + copy(mr.Strings[0],21,10) + ' použito na temp  ' +  NxFloatToIBStr(mQuantityTemp),nil);
                                                 finally
                                                     mx.free;
                                                 end;



                                                             if mQuantityDoc-mQuantityVratka-mQuantityTemp>0 then begin    /// je možné čerpat
                                                                             TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_parent_ID',copy(mr.Strings[i],1,10));
                                                                             TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_parent2_id',copy(mr.Strings[i],11,10));
                                                                       if mQuantityPomoc>(mQuantityDoc-mQuantityVratka-mQuantityTemp) then begin
                                                                             TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_vychystano',mQuantityDoc-mQuantityVratka-mQuantityTemp);

                                                                             if mShowDebug then nxShowSimpleMessage(' je potřeba  ' +  NxFloatToIBStr(mQuantitySource) +  ' na dokladu  ' +  NxFloatToIBStr(mQuantityDoc)+ ' vráceno ' +  NxFloatToIBStr(mQuantityVratka) +' použito na temp  ' +  NxFloatToIBStr(mQuantityTemp)  +chr(13) +
                                                                                   ' bude použito ' +  NxFloatToIBStr(mQuantityDoc-mQuantityVratka-mQuantityTemp) ,nil);
                                                                                   mQuantityPomoc:=mQuantityPomoc-(mQuantityDoc-mQuantityVratka-mQuantityTemp);
                                                                       end else begin
                                                                             TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_vychystano',mQuantityPomoc);
                                                                              if mShowDebug then nxShowSimpleMessage(' je potřeba  ' +  NxFloatToIBStr(mQuantitySource) +  ' na dokladu  ' +  NxFloatToIBStr(mQuantityDoc)+ ' vráceno ' +  NxFloatToIBStr(mQuantityVratka) +' použito na temp  ' +  NxFloatToIBStr(mQuantityTemp)  +chr(13) +
                                                                                   ' bude použito ' +  NxFloatToIBStr(mQuantityPomoc) ,nil);
                                                                             mQuantityPomoc:=mQuantityPomoc-(mQuantityPomoc);
                                                                       end;

                                                                        TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_PM_State','2050000101');
                                                                        if index=0 then TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_CLSID','O3BDOKTWEFD13ACM03KIU0CLP4');
                                                                        if index=1 then TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_CLSID','42HE04FZGJD13ACM03KIU0CLP4');
                                                                        if index=4 then TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_CLSID','050I5SAOS3DL3ACU03KIU0CLP4');
                                                                        TBusRollSiteForm(mSite).CurrentObject.save;

                                                             end else begin
                                                                   if mShowDebug then nxShowSimpleMessage(' je potřeba  ' +  NxFloatToIBStr(mQuantitySource) +  ' na dokladu  ' +  NxFloatToIBStr(mQuantityDoc)+ ' vráceno ' +  NxFloatToIBStr(mQuantityVratka) +' použito na temp  ' +  NxFloatToIBStr(mQuantityTemp)  +chr(13) +
                                                                                   ' nelze použít ' ,nil);
                                                                                   TBusRollSiteForm(mSite).CurrentObject.save;
                                                             end;
                                     end;
                                    end;
                                      if mQuantityPomoc>0 then begin
                                        if NxIsEmptyOID(TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_parent2_id')) then begin
                                                 if mShowDebug then NxShowSimpleMessage('nedohledáno',nil);
                                                 TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_PM_State','3020000101');
                                                 TBusRollSiteForm(mSite).CurrentObject.save;
                                                 TBusRollSiteForm(mSite).DataSet.RefreshCurrentItem;
                                        end else begin

                                        end;
                                    end;
                              finally

                                 mr.free;
                              end;
                            TBusRollSiteForm(mSite).DataSet.RefreshCurrentItem;
                            msite.Refresh;

         end
    end else begin
         for x := 0 to mBookmark.Count- 1 do begin
                          mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(x));
                          ProgressSetPos(1+NxFloor(x/mBookmark.Count*99), inttostr(x) +' z '+inttostr(mBookmark.Count));
                     if index=5 then begin
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_Parent_ID','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_Parent2_ID','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_vychystano',0);
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_dodano',0);
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_PM_State','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_CLSID','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_EN_NAZEV','');

                  TBusRollSiteForm(mSite).CurrentObject.save;
                  TBusRollSiteForm(mSite).DataSet.RefreshCurrentItem;
           end else begin
                              mQuantitySource:=0;
                              mQuantitySource:= TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsFloat('X_Quantity');
                              mQuantityPomoc:=mQuantitySource-TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsFloat('X_vychystano');
                              mr:=TStringList.create;
                              try

                              if index=0 then begin
                                                 mSite.BaseObjectSpace.SQLSelect('SELECT  ii.id||ii2.id||CAST(ii2.quantity AS VARCHAR(10)) '+
                                                                                         '  FROM  Storedocuments2 SD2 '+
                                                                                         '       join Storedocuments SD  ON sd.ID=sd2.parent_ID '+
                                                                                          '      left join IssuedInvoices2 ii2  on ii2.Providerow_ID=sd2.id '+
                                                                                          '      join IssuedInvoices ii  ON ii2.Parent_ID=ii.ID '+
                                                                                          '      join Firms F on f.id=ii.Firm_ID '+
                                                                                          '      WHERE SD.DocumentType=' + quotedstr('21') + ' and (F.ID=' +quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID')) + ' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+')) ) and  (SD2.Storecard_ID = '+ quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Storecard_ID')) +')  '+
                                                                                          '      and (not exists (SELECT 1 FROM Docrowbatches where Parent_ID=SD2.ID )) ' +
                                                                                          '     order by ii2.quantity desc ',mr) ;



                              end;

                              if index=1 then begin
//                                                 if ((not NxIsEmptyOID(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches'))) and
//                                                    (TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsinteger('X_Storecard_ID.Category')=2)) then
                                                   mSite.BaseObjectSpace.SQLSelect('SELECT  sd.id||sd2.id||CAST(sd2.quantity AS VARCHAR(10)) '+
                                                                                    ' FROM StoreDocuments2 sd2  '+
                                                                                    ' join StoreDocuments sd ON sd2.Parent_ID=sd.ID '+
                                                                                    ' join Firms F on f.id=SD.Firm_ID ' +
                                                                                    ' left join DocRowBatches DRB on DRB.Parent_ID= ii2.ProvideRow_ID' +
                                                                                    ' WHERE (F.ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+
                                                                                    ' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+')) )'+
                                                                                    ' and  (SD.Storecard_ID = '+ quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Storecard_ID')) +
                                                                                    ' and sd.DocumentType= ' + quotedstr('20') + ') order by sd2.quantity desc',mr) ;

                              end;


                              if index=4 then begin
                                                  if ((not NxIsEmptyOID(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches'))) and
                                                    (TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsinteger('X_Storecard_ID.Category')=2)) then
                                                   mSite.BaseObjectSpace.SQLSelect('SELECT  sd.id||sd2.id||CAST(sd2.quantity AS VARCHAR(10)) '+
                                                                                         '  FROM  Storedocuments2 SD2 '+
                                                                                         '       join Storedocuments SD  ON sd.ID=sd2.parent_ID '+

                                                                                          '      join Firms F on f.id=sd.Firm_ID '+
                                                                                          '      WHERE SD.DocumentType=' + quotedstr('21') + ' and (F.ID=' +quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID')) + ' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+')) ) and  (SD2.Storecard_ID = '+ quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Storecard_ID')) +')  '+
                                                                                          '      and (not exists (SELECT 1 FROM Docrowbatches where Parent_ID=SD2.ID )) ' +
                                                                                          '     order by sd2.quantity desc ',mr) ;



                              end;



                                    if mShowDebug then  NxShowSimpleMessage('Počet nálezů ' +  inttostr(mr.count),nil);
                                    for i:=0 to mr.count-1 do begin
                                            if mShowDebug then NxShowSimpleMessage(mr.Strings[i],nil);

                                            mQuantityDoc:=NxIBStrToFloat(copy(mr.Strings[0],21,10));
                                             if mShowDebug then NxShowSimpleMessage(' Množství ' + NxFloatToIBStr(mQuantityDoc),nil);
                                             if mShowDebug then NxShowSimpleMessage(' mQuantity pomoc ' + NxFloatToIBStr(mQuantityPomoc),nil);

                                      if mQuantityPomoc>0  then begin

                                            mQuantityVratka:=0;
                                            try
                                            if index=0 then begin
                                            // ******** již vráceno

                                                          mx:=tstringlist.create;
                                                           try
                                                                 msite.BaseObjectSpace.SQLSelect('select sum(x.quantity) from IssuedCreditNotes2 x where x.RSource_ID=' + QuotedStr(copy(mr.Strings[0],11,10)),mx);
                                                                 if mx.count>0 then mQuantityVratka:=NxIBStrToFloat(mx.Strings[0]) else mQuantityVratka:=0;
                                                                 if mShowDebug then nxShowSimpleMessage('z ' + copy(mr.Strings[0],21,10) + ' vráceno ' +  NxFloatToIBStr(mQuantityVratka),nil);

                                                           finally
                                                               mx.free;
                                                           end;
                                             end;
                                             finally

                                             end;
                                                 //   ***** v temp již použito
                                                 mx:=tstringlist.create;
                                                 try
                                                       msite.BaseObjectSpace.SQLSelect('select sum(x.X_quantity) FROM DefRollData X WHERE X.CLSID = ' + QuotedStr('45D1XVW5EY24JBXTOE01EHYRSG') + ' AND x.X_parent2_id=' +
                                                                                       quotedstr(copy(mr.Strings[0],11,10)),mx);
                                                                if mx.count>0 then mQuantityTemp:=NxIBStrToFloat(mx.Strings[0]) else mQuantityTemp:=0;
                                                              if mShowDebug then nxShowSimpleMessage('z ' + copy(mr.Strings[0],21,10) + ' použito na temp  ' +  NxFloatToIBStr(mQuantityTemp),nil);
                                                 finally
                                                     mx.free;
                                                 end;



                                                             if mQuantityDoc-mQuantityVratka-mQuantityTemp>0 then begin    /// je možné čerpat
                                                                             TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_parent_ID',copy(mr.Strings[i],1,10));
                                                                             TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_parent2_id',copy(mr.Strings[i],11,10));
                                                                       if mQuantityPomoc>(mQuantityDoc-mQuantityVratka-mQuantityTemp) then begin
                                                                             TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_vychystano',mQuantityDoc-mQuantityVratka-mQuantityTemp);

                                                                             if mShowDebug then nxShowSimpleMessage(' je potřeba  ' +  NxFloatToIBStr(mQuantitySource) +  ' na dokladu  ' +  NxFloatToIBStr(mQuantityDoc)+ ' vráceno ' +  NxFloatToIBStr(mQuantityVratka) +' použito na temp  ' +  NxFloatToIBStr(mQuantityTemp)  +chr(13) +
                                                                                   ' bude použito ' +  NxFloatToIBStr(mQuantityDoc-mQuantityVratka-mQuantityTemp) ,nil);
                                                                                   mQuantityPomoc:=mQuantityPomoc-(mQuantityDoc-mQuantityVratka-mQuantityTemp);
                                                                       end else begin
                                                                             TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_vychystano',mQuantityPomoc);
                                                                              if mShowDebug then nxShowSimpleMessage(' je potřeba  ' +  NxFloatToIBStr(mQuantitySource) +  ' na dokladu  ' +  NxFloatToIBStr(mQuantityDoc)+ ' vráceno ' +  NxFloatToIBStr(mQuantityVratka) +' použito na temp  ' +  NxFloatToIBStr(mQuantityTemp)  +chr(13) +
                                                                                   ' bude použito ' +  NxFloatToIBStr(mQuantityPomoc) ,nil);
                                                                             mQuantityPomoc:=mQuantityPomoc-(mQuantityPomoc);
                                                                       end;

                                                                        TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_PM_State','2050000101');
                                                                        if index=0 then TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_CLSID','O3BDOKTWEFD13ACM03KIU0CLP4');
                                                                        if index=1 then TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_CLSID','42HE04FZGJD13ACM03KIU0CLP4');
                                                                        if index=4 then TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_CLSID','050I5SAOS3DL3ACU03KIU0CLP4');
                                                                        TBusRollSiteForm(mSite).CurrentObject.save;

                                                             end else begin
                                                                   if mShowDebug then nxShowSimpleMessage(' je potřeba  ' +  NxFloatToIBStr(mQuantitySource) +  ' na dokladu  ' +  NxFloatToIBStr(mQuantityDoc)+ ' vráceno ' +  NxFloatToIBStr(mQuantityVratka) +' použito na temp  ' +  NxFloatToIBStr(mQuantityTemp)  +chr(13) +
                                                                                   ' nelze použít ' ,nil);
                                                                                   TBusRollSiteForm(mSite).CurrentObject.save;
                                                             end;
                                     end;
                                    end;
                                      if mQuantityPomoc>0 then begin
                                        if NxIsEmptyOID(TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_parent2_id')) then begin
                                                 if mShowDebug then NxShowSimpleMessage('nedohledáno',nil);
                                                 TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_PM_State','3020000101');
                                                 TBusRollSiteForm(mSite).CurrentObject.save;
                                                 TBusRollSiteForm(mSite).DataSet.RefreshCurrentItem;
                                        end else begin

                                        end;
                                    end;
                              finally

                                 mr.free;
                              end;
                            TBusRollSiteForm(mSite).DataSet.RefreshCurrentItem;
                            msite.Refresh;

         end



         end;

    end;


ProgressDispose()   ;



end;



function CreateAllDocFromWorkListImport(msite:tSiteform;mCLSIDInput:string;mCLSIDOuput:string;mAgenda:string;mDocqueue_ID:string;mFirm_id:string;mDivision_ID:string;mStore_ID:string;mDocList:tstringlist;mRowList:tstringlist;index:integer;mbatchlist:tstringlist;mBatchworklist:tstringlist):string;
var
  mImportMan: TNxDocumentImportManager;
  mOS: TNxCustomObjectSpace;
  mInputParams: TNxParameters;
  mParam: TNxParameter;
  mCollRows: TNxCustomBusinessMonikerCollection;
  x,xx,xxx: integer;
  mList: TStringList;
  mRow: TNxCustomBusinessObject;
  mtext:string;
  mValidateList:tstringlist;
  mRowsOutput,mRows,mMonBatches:TNxCustomBusinessMonikerCollection;
  msave,mFind:boolean;
  mIDoc:integer;
  mVratka,mr:TStringList;
  mi:integer;
  msearch:boolean;
  i,yyy:integer;
  mBOVratka,mDefRoll,mBillOfDeliveryRowBO,mDocRowBatch:TNxCustomBusinessObject;
  mpocet:double;
begin
  mOS := msite.BaseObjectSpace;
  try
       mInputParams := TNxParameters.Create;
       mImportMan := NxCreateDocumentImportManager(mOS, 'O3BDOKTWEFD13ACM03KIU0CLP4', 'W402MSU3BBDL3ACR03KIU0CLP4');
      try
        for mIDoc:=0 to mDocList.count-1 do begin
            //if mShowDebug then NxShowSimpleMessage('Dokladů ' + inttostr(mdoclist.count)  + ' - ' + mdoclist.Strings[0],nil);
             mImportMan.AddInputDocument(mDocList.Strings[mIDoc]);
        end;
//        NxShowSimpleMessage(mRowList.Text,nil);   // *** smazat ***
        //mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows');
        //mParam.AsString := mRowList.Text;


        mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
        mParam.AsString := mDocqueue_ID_DFV;
        //mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
        //mParam.AsString := mDocList.strings[0];
        //mParam := mInputParams.GetOrCreateParam(dtString, 'StoreDocQueue_ID');
        //mParam.AsString := mDocqueue_ID_VRDL;
        //mParam := mInputParams.GetOrCreateParam(dtBoolean, 'DoNotImportRowTypeText');
        //mParam.AsBoolean := True;
        //mParam := mInputParams.GetOrCreateParam(dtBoolean, 'DoNotImportChargesSerialNumbers');
        //mParam.AsBoolean := True;

        mImportMan.LoadParams(mInputParams);

        mImportMan.Execute;

        mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', mDocqueue_ID_DFV ); // musi byt...          '2781000101'
          mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID', mfirm_ID);
          mImportMan.OutputDocument.SetFieldValueAsDateTime('Docdate$date', TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsDateTime('X_ABRADate'));
          //mImportMan.OutputDocument.SetFieldValueAsString('StoreDocQueue_ID', mDocqueue_ID_VRDL); // musi byt...
          mImportMan.OutputDocument.SetFieldValueAsinteger('Acknowledge',0); // musi byt...
          mImportMan.OutputDocument.SetFieldValueAsString('ReasonDescription', 'Vraceni'); // musi byt...



        if Assigned(mImportMan.OutputDocument) then begin
                 mRowsOutput := mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));


                        if mShowDebug then NxShowSimpleMessage('Importovano radků ' + inttostr(mRowsOutput.count),nil);
                        msave:=false;

                        for xx:=0 to mRowsOutput.Count-1 do begin

                              mFind:=false;
                                 for xxx:=0 to mBatchworklist.Count-1 do begin

                                   //NxShowSimpleMessage(mRowsOutput.BusinessObject[xx].GetFieldValueAsString('RSource_ID')+' = ' + mRowList.Strings[xxx],nil);
                                   if mRowsOutput.BusinessObject[xx].GetFieldValueAsString('RSource_ID')=copy(mBatchworklist.Strings[xxx],21,10) then begin
                                      if mShowDebug then NxShowSimpleMessage('Nalezeno:  ' + mRowsOutput.BusinessObject[xx].GetFieldValueAsString('RSource_ID')+' = ' + mRowList.Strings[xxx],nil);
                                       if (trim(copy(mBatchworklist.Strings[xxx],81,10))='') or (trim(copy(mBatchworklist.Strings[xxx],81,10))='0000000000') then begin
                                          mRowsOutput.BusinessObject[xx].SetFieldValueAsstring('Store_ID',mCstore_ID);
                                       end else begin
                                          mRowsOutput.BusinessObject[xx].SetFieldValueAsstring('Store_ID',copy(mBatchworklist.Strings[xxx],81,10)) ;
                                       end;
                                       //mRowsOutput.BusinessObject[xx].SetFieldValueAsstring('Store_ID',mstore_ID);
                                       //if mRowsOutput.BusinessObject[xx].getFieldValueAsFloat('quantity')<>0
                                       //       then mRowsOutput.BusinessObject[xx].SetFieldValueAsBoolean('X_MArkForDelete',false);
                                       //NxShowSimpleMessage(     NxFloatToIBStr  (NxIBStrToFloat(    copy(mBatchworklist.Strings[xxx],101,10))),nil);        // *** smazat  ***
                                       try
                                        //   if mRowsOutput.BusinessObject[xx].getFieldValueAsFloat('Quantity')<>1 then
                                           mRowsOutput.BusinessObject[xx].SetFieldValueAsFloat('Quantity',NxIBStrToFloat(trim(copy(mBatchworklist.Strings[xxx],101,10))));
                                       finally

                                       end;
                                      // mRowsOutput.BusinessObject[xx].SetFieldValueAsstring('Store_ID','2G10000101');




                                       msave:=true;
                                       mFind:=true;
                                   end;
                             end;
                            // if not mFind then mxList.add(mRowList.Strings[xxx]);

                        end;
                        msave:=false;

                  // mRowsOutput := mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
                if mShowDebug then  NxShowSimpleMessage('K ulození radků  ' + inttostr(mRowsOutput.count),nil);

   end;

         if mRowsOutput.count >0 then msave:=true;

         if msave then begin
                            mImportMan.OutputDocument.ClearValidateErrors;
                                     // if false then begin
                                      if Not mImportMan.OutputDocument.Validate() then begin
                                            mValidateList := TStringList.Create;
                                            try
                                               mImportMan.OutputDocument.GetValidateErrors(mValidateList);
                                               mText := mValidateList.Text;
                                               NxToken(mText, '=');
                                               MessageDlg('Automaticky vytvořený doklad nelze uložit z těchto důvodů:' + #13#10 + mText,

                                               mtWarning, [mbOK], 0);
                                             finally
                                               mValidateList.Free;
                                             end;
                                             TDynSiteForm.ShowDynFormWithNewDocument('T1C2EX0BUJD13ACP03KIU0CLP4', TDynSiteForm.SiteContext, mImportMan.OutputDocument);
                                             result:='Chyba';
                                      end else begin
                                           mImportMan.OutputDocument.Save;
                                           if mShowDebug then NxShowSimpleMessage('Byl vytvořen doklad ' + mImportMan.OutputDocument.DisplayName,nil);
                                           result:=mImportMan.OutputDocument.oid;










                                          mvratka:=tstringlist.create;

                                          try
                                          mRowsOutput := mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
                                                      //NxShowSimpleMessage('Importovano radků ' + inttostr(mRowsOutput.count),nil);
                                                      //for xxx:=0 to mRowList.Count-1 do begin
                                                            for xx:=0 to mRowsOutput.Count-1 do begin
                                                                 //if mRowsOutput.BusinessObject[xx].GetFieldValueAsString('RSource_ID')=mRowList.Strings[xxx] then begin
                                                                                 msearch:=false;
                                                                                 for i:=0 to mvratka.count-1 do begin
                                                                                        if mvratka.strings[i]=mRowsOutput.BusinessObject[xx].GetFieldValueAsString('Provide_ID') then msearch:=true;
                                                                                 end;
                                                                                 if not msearch then mvratka.add(mRowsOutput.BusinessObject[xx].GetFieldValueAsString('Provide_ID'));
                                                                 //end;
                                                            end;
//                                                           if not mFind then mxList.add(mRowList.Strings[xxx]);

                                                      //end;
                                                     // mImportMan.OutputDocument.Delete;




                                                      // dobropis smazán , uvolněny šarže


                                             if mVratka.count>0 then begin
                                                mBOVratka:=msite.BaseObjectSpace.CreateObject('1T0I5SAOS3DL3ACU03KIU0CLP4');
                                                   mDefRoll:= msite.BaseObjectSpace.CreateObject('45D1XVW5EY24JBXTOE01EHYRSG');
                                                   try
                                                        for i:=0 to mVratka.count-1 do begin   // doklad
                                                            mBOVratka.load(mVratka.Strings[i],nil);
                                                                  mRows := mBOVratka.GetLoadedCollectionMonikerForFieldCode(mBOVratka.GetFieldCode('Rows'));
                                                                      for xx:=0 to mrows.count-1 do begin   // řádek
                                                                           if mrows.BusinessObject[xx].GetFieldValueAsinteger('rowtype')=3 then begin   // skladový řádek

                                                                                   if mrows.BusinessObject[xx].GetFieldValueAsinteger('StoreCard_ID.category')=2 then begin
                                                                                          mpocet:=0;

                                                                                          mMonBatches :=  mrows.BusinessObject[xx].GetLoadedCollectionMonikerForFieldCode(mrows.BusinessObject[xx].GetFieldCode('DocRowBatches'));


                                                                                         mFind:=false;
                                                                                         for yyy:=0 to mbatchworklist.count-1 do begin
                                                                                                  for xxx := 0 to mMonBatches.Count - 1 do begin
                                                                                                    if  (mMonBatches.BusinessObject[xxx].GetFieldValueAsstring('Parent_ID.RDocumentRow_ID')= copy(mbatchworklist.strings[yyy],51,10)) and
                                                                                                         (mMonBatches.BusinessObject[xxx].GetFieldValueAsstring('StoreBatch_ID')= copy(mbatchworklist.strings[yyy],71,10)) then begin
                                                                                                         // správná doklad a správná šarže
                                                                                                           mFind:=true;
                                                                                                         mDefRoll.load(copy(mbatchworklist.strings[yyy],91,10),nil);
                                                                                                              mpocet:=mMonBatches.BusinessObject[xxx].GetFieldValueAsFloat('Quantity')-mDefRoll.GetFieldValueAsFloat('X_vychystano');
                                                                                                              if mDefRoll.GetFieldValueAsFloat('X_vychystano')<=mMonBatches.BusinessObject[xxx].getFieldValueAsFloat('Quantity') then begin
                                                                                                                  //mMonBatches.BusinessObject[xxx].setFieldValueAsFloat('Quantity',mDefRoll.GetFieldValueAsFloat('X_vychystano'));
                                                                                                                  mMonBatches.BusinessObject[xxx].setFieldValueAsFloat('X_Quantity',mDefRoll.GetFieldValueAsFloat('X_vychystano'));
                                                                                                                  if not NxIsBlank(mDefRoll.GetFieldValueAsString('X_Store_ID')) then
                                                                                                                  //mrows.BusinessObject[xx].SetFieldValueAsString('Store_ID',mDefRoll.GetFieldValueAsString('X_Store_ID'));
                                                                                                                 // mrows.BusinessObject[xx].setFieldValueAsFloat('Quantity',(mrows.BusinessObject[xx].getFieldValueAsFloat('Quantity')-mpocet));
                                                                                                                 mDefRoll.setFieldValueAsFloat('X_dodano',mDefRoll.getFieldValueAsFloat('X_dodano') + mMonBatches.BusinessObject[xxx].getFieldValueAsFloat('Quantity'));
                                                                                                                 mDefRoll.SetFieldValueAsString('X_EN_nazev',mMonBatches.BusinessObject[xxx].OID);
                                                                                                                 //NxShowSimpleMessage('Defrool save', nil);
                                                                                                                 mDefRoll.save;
                                                                                                               end else begin
                                                                                                                 //mMonBatches.BusinessObject[xxx].setFieldValueAsFloat('Quantity',mDefRoll.GetFieldValueAsFloat('X_vychystano'));
                                                                                                                  //mrows.BusinessObject[xx].setFieldValueAsFloat('Quantity',(mrows.BusinessObject[xx].getFieldValueAsFloat('Quantity')-mpocet));
                                                                                                                  if not NxIsBlank(mDefRoll.GetFieldValueAsString('X_Store_ID')) then
                                                                                                                  //mrows.BusinessObject[xx].SetFieldValueAsString('Store_ID',mDefRoll.GetFieldValueAsString('X_Store_ID'));
                                                                                                                  mDefRoll.SetFieldValueAsString('X_EN_nazev',mMonBatches.BusinessObject[xxx].OID);
                                                                                                                  mDefRoll.setFieldValueAsFloat('X_dodano',mMonBatches.BusinessObject[xxx].getFieldValueAsFloat('Quantity'));
                                                                                                                  //NxShowSimpleMessage('Defrool save', nil);
                                                                                                                  mDefRoll.save;

                                                                                                              end;
                                                                                                    end;


                                                                                                  end;
                                                                                             if not mFind then begin
                                                                                                mDocRowBatch:= mMonBatches.AddNewObject;
                                                                                                        mDocRowBatch.SetFieldValueAsString('StoreBatch_ID', copy(mbatchworklist.strings[yyy],71,10)) ;
                                                                                                        //mDocRowBatch.SetFieldValueAsFloat('Quantity', mDS.FieldByName('ToReturn').AsFloat);

                                                                                                        mDefRoll.load(copy(mbatchworklist.strings[yyy],91,10),nil);
                                                                                                              mpocet:=mDocRowBatch.GetFieldValueAsFloat('Quantity')-mDefRoll.GetFieldValueAsFloat('X_vychystano');

                                                                                                              if mDefRoll.GetFieldValueAsFloat('X_vychystano')<=mDocRowBatch.getFieldValueAsFloat('Quantity') then begin
                                                                                                                  //mMonBatches.BusinessObject[xxx].setFieldValueAsFloat('Quantity',mDefRoll.GetFieldValueAsFloat('X_vychystano'));
                                                                                                                  mDocRowBatch.setFieldValueAsFloat('Quantity',mDefRoll.GetFieldValueAsFloat('X_vychystano'));
                                                                                                                  if not NxIsBlank(mDefRoll.GetFieldValueAsString('X_Store_ID')) then
                                                                                                                  //mrows.BusinessObject[xx].SetFieldValueAsString('Store_ID',mDefRoll.GetFieldValueAsString('X_Store_ID'));
                                                                                                                 // mrows.BusinessObject[xx].setFieldValueAsFloat('Quantity',(mrows.BusinessObject[xx].getFieldValueAsFloat('Quantity')-mpocet));
                                                                                                                 mDefRoll.setFieldValueAsFloat('X_dodano',mDefRoll.getFieldValueAsFloat('X_dodano') + mDocRowBatch.getFieldValueAsFloat('Quantity'));
                                                                                                                 mDefRoll.SetFieldValueAsString('X_EN_nazev',mDocRowBatch.OID);
                                                                                                                 //NxShowSimpleMessage('Defrool save', nil);
                                                                                                                 mDefRoll.save;
                                                                                                               end else begin
                                                                                                                 //mMonBatches.BusinessObject[xxx].setFieldValueAsFloat('Quantity',mDefRoll.GetFieldValueAsFloat('X_vychystano'));
                                                                                                                  //mrows.BusinessObject[xx].setFieldValueAsFloat('Quantity',(mrows.BusinessObject[xx].getFieldValueAsFloat('Quantity')-mpocet));
                                                                                                                  if not NxIsBlank(mDefRoll.GetFieldValueAsString('X_Store_ID')) then
                                                                                                                  //mrows.BusinessObject[xx].SetFieldValueAsString('Store_ID',mDefRoll.GetFieldValueAsString('X_Store_ID'));
                                                                                                                  mDefRoll.SetFieldValueAsString('X_EN_nazev',mDocRowBatch.OID);
                                                                                                                  mDefRoll.setFieldValueAsFloat('X_dodano',mDocRowBatch.getFieldValueAsFloat('Quantity'));
                                                                                                                  //NxShowSimpleMessage('Defrool save', nil);
                                                                                                                  mDefRoll.save;

                                                                                                              end;
                                                                                             end;
                                                                                             mfind:=false;
                                                                                         end;

                                                                                   end;
                                                                           end;
                                                                      end;
                                                              mBOVratka.SetFieldValueAsString('Description','Vraceni ' + FormatDateTime('MM', now()) + '/' +  FormatDateTime('YYYY', now()) + );


                                                               for xx:=0 to mrows.count-1 do begin   // řádek
                                                                  if mrows.BusinessObject[xx].GetFieldValueAsinteger('rowtype')=3 then begin   // skladový řádek
                                                                      if mrows.BusinessObject[xx].GetFieldValueAsinteger('StoreCard_ID.category')=2 then begin
                                                                             mpocet:=0;
                                                                             mMonBatches :=  mrows.BusinessObject[xx].GetLoadedCollectionMonikerForFieldCode( mrows.BusinessObject[xx].GetFieldCode('DocRowBatches'));
                                                                                  for xxx := 0 to mMonBatches.Count - 1 do begin
                                                                                      if mMonBatches.BusinessObject[xxx].getFieldValueAsFloat('X_Quantity')>0 then begin
                                                                                         mMonBatches.BusinessObject[xxx].setFieldValueAsFloat('Quantity',mMonBatches.BusinessObject[xxx].getFieldValueAsFloat('X_Quantity'));
                                                                                         mpocet:=mpocet+mMonBatches.BusinessObject[xxx].getFieldValueAsFloat('X_Quantity');
                                                                                      //end else begin mMonBatches.BusinessObject[xxx].MarkForDelete;
                                                                                      end;
                                                                                  end;
                                                                                  //mrows.BusinessObject[xx].setFieldValueAsFloat('Quantity',mpocet);
                                                                                 // if mrows.BusinessObject[xx].getFieldValueAsFloat('Quantity')= 0 then mrows.BusinessObject[xx].MarkForDelete;
                                                                      end;
                                                                  end;
                                                               //   if mrows.BusinessObject[xx].GetFieldValueAsFloat('Quantity')=0 then mrows.BusinessObject[xx].MarkForDelete;
                                                               end;
                                                            mBOVratka.ClearValidateErrors;
                                                                        if Not mBOVratka.Validate() then begin
                                                                              mValidateList := TStringList.Create;
                                                                              try
                                                                                 mBOVratka.GetValidateErrors(mValidateList);
                                                                                 mText := mValidateList.Text;
                                                                                 NxToken(mText, '=');
                                                                                 MessageDlg('Automaticky vytvořený doklad nelze uložit z těchto důvodů:' + #13#10 + mText,

                                                                                 mtWarning, [mbOK], 0);
                                                                               finally
                                                                                 mValidateList.Free;
                                                                               end;
                                                                               //NxShowSimpleMessage('Chyba',nil);
                                                                               TDynSiteForm.ShowDynFormWithNewDocument('BL0I5SAOS3DL3ACU03KIU0CLP4', TDynSiteForm(mSite).SiteContext, mBOVratka);
                                                                               result:='Chyba';
                                                                        end else begin
                                                                             mBOVratka.save;
                                                                             //NxShowSimpleMessage('Doklad uložen',nil);
                                                                             result:=mImportMan.OutputDocument.oid;
                                                                            //NxShowSimpleMessage('Byl vytvořen doklad',nil);
                                                                            mRowsOutput := mBOVratka.GetLoadedCollectionMonikerForFieldCode(mBOVratka.GetFieldCode('Rows'));
                                                                         //   if mRowsOutput.Count=0 then mBOVratka.delete;
                                                                       end;
                                                        end;

                                                   finally
                                                       mBOVratka.free;
                                                       mDefRoll.free;

                                              end;
                                                   end;
                                          finally
                                             mvratka.free;
                                          end;


                                      end;

                      end else begin
                          result:='Bez řádků , neuloženo';
                      end;
         //result:=mImportMan.OutputDocument.oid;
      finally
        mImportMan.Free;
      end;
    finally
      mInputParams.Free;
      //mValidateList.Free;
    end;
   result:='ok';
   msite.Refresh;
end;




procedure CreateDocumentImport(Sender: TAction; Index: integer);
var
 mbo,mRowDocBatchTarget:TNxCustomBusinessObject;
 mSite: TSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 x,i:integer;
   mForm: TBusRollSiteForm;
   mtext:string;
   mB_Result:boolean;
   mi:integer;
   mr,mx,mpomoclist:tstringlist;
   mVolne,mNaDokladu,mNaVratce,mquantity:double;
   mbonew:TNxCustomBusinessObject;
   mImportMan: TNxDocumentImportManager;
  mOS: TNxCustomObjectSpace;
  mInputParams: TNxParameters;
  mParam: TNxParameter;
  mCollRows: TNxCustomBusinessMonikerCollection;
  iSource,iTarget: integer;
  mList: TStringList;
  mRow: TNxCustomBusinessObject;
  mValidateList:tstringlist;
  mRowsOutput:TNxCustomBusinessMonikerCollection;
  msave,mFind:boolean;
  mMonBatches:TNxCustomBusinessMonikerCollection;
  mSelectedRows:TStrings;
mListError,mWorkList,mBatchList:tstringlist;
  mListNoBatches:tstringlist;
   mstringlist,mxlist:tstringlist;
  mnote:string;
  mSTR:string;
  mCLSID:string;
  mpocetdokladu, mpocetradku,mpocetsarzi:integer;
  mIWorklist,mIšarže:integer;
  mHead:TNxHeaderBusinessObject;
  mRows,mBatches:TNxCustomBusinessMonikerCollection;
  mDocqueue_ID,mStore_ID,mFirm_id,mDivision_ID:string;
  mDocList,mRowList:TStringList;
  mAgenda:string;
  msearch:boolean;
  mString:string;
  mTempWorkList,mTempRowslist:tstringlist;
  mBatchWorklist:tstringlist;
begin

  mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu

if index=0 then begin
  mDocqueue_ID:=mDocqueue_ID_DFV;
end;
if index=2 then begin
  mDocqueue_ID:=mDocqueue_ID_VRPR;;
end;
  mFirm_id:=TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_Firm_ID');
  mDivision_ID:=mCDivision_ID;
  mStore_ID:=mCStore_ID;
    //mB_Result:=InputQuery('Zadaj parametry', 'Změna ', mtext);
    ProgressInit(msite, 'Načtení souboru ' + '', 100);

    mWorkList:=tstringlist.create;
    mDocList:=TStringList.create;
    mRowList:=TStringList.create;
    mBatchList:=TStringList.create;
    mBatchWorklist:=TStringList.create;
    try
                      if mBookmark.count=0 then begin
                       if index=5 then begin
                                    TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_dodano',0);
                                    TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_EN_NAZEV','');
                                    TBusRollSiteForm(mSite).CurrentObject.save;
                                    TBusRollSiteForm(mSite).DataSet.RefreshCurrentItem;
                        end else begin
                                                                  mWorkList.add(TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_Firm_ID') +       //              1-10
                                                                                 TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_parent_id') +    //  ii.id      11-20
                                                                                 TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_parent2_id') +   // ii2.id      21-30
                                                                                 TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_StoreCard_ID') + //  sc.id      31-40

                                                                                 TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_Devenolux') + //  sd.id      41-50
                                                                                 TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_MX_NAZEV') +      // sd2.id      51-60
                                                                                 TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_DE_NAZEV') +      // drb.id      61-70

                                                                                 TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_Batches') +      //   b.id      71-80
                                                                                 TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_Store_ID') +     // ?           81-90
                                                                                 TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('ID') +             // a.id        91-100
                                                                                 NxFloatToIBStr(TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsFloat('X_vychystano'))); // quantity  101


                                                                                 msearch:=false;
                                                                                 for i:=0 to mDocList.count-1 do begin
                                                                                        if mdoclist.strings[i]=TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_parent_id') then msearch:=true;
                                                                                 end;
                                                                                 if not msearch then mdoclist.add(TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_parent_id'));


                                                                                 msearch:=false;
                                                                                 for i:=0 to mRowList.count-1 do begin
                                                                                        if mRowList.strings[i]=TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_parent2_id') then msearch:=true;
                                                                                 end;
                                                                                 if not msearch then begin
                                                                                //     mRowList.add(TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_parent2_id'));
                                                                                //     mbatchlist.add(TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_parent2_id')+TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_Batches') +TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('id')+NxFloatToIBStr(TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsFloat('X_vychystano')) );

                                                                                     mBatchWorkList.add(TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_Firm_ID') +       //              1-10
                                                                                         TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_parent_id') +    //  ii.id      11-20
                                                                                         TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_parent2_id') +   // ii2.id      21-30
                                                                                         TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_StoreCard_ID') + //  sc.id      31-40

                                                                                         TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_Devenolux') + //  sd.id      41-50
                                                                                         TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_MX_NAZEV') +      // sd2.id      51-60
                                                                                         TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_DE_NAZEV') +      // drb.id      61-70

                                                                                         TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_Batches') +      //   b.id      71-80
                                                                                         TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_Store_ID') +     // ?           81-90
                                                                                         TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('ID') +             // a.id        91-100
                                                                                         NxFloatToIBStr(TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsFloat('X_vychystano'))); // quantity  101

                                                                                 end;

                       end;
                      end else begin
                           for x := 0 to mBookmark.Count- 1 do begin
                                            mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(x));
                                            ProgressSetPos(1+NxFloor(x/mBookmark.Count*99), inttostr(x) +' z '+inttostr(mBookmark.Count));
                                   if index=5 then begin
                                       TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_dodano',0);
                                       TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_EN_NAZEV','');
                                       TBusRollSiteForm(mSite).CurrentObject.save;
                                       TBusRollSiteForm(mSite).DataSet.RefreshCurrentItem;
                                   end else begin
                                                          mWorkList.add(TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_Firm_ID') +       //              1-10
                                                                                 TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_parent_id') +    //  ii.id      11-20
                                                                                 TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_parent2_id') +   // ii2.id      21-30
                                                                                 TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_StoreCard_ID') + //  sc.id      31-40

                                                                                 TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_Devenolux') + //  sd.id      41-50
                                                                                 TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_MX_NAZEV') +      // sd2.id      51-60
                                                                                 TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_DE_NAZEV') +      // drb.id      61-70

                                                                                 TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_Batches') +      //   b.id      71-80
                                                                                 TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_Store_ID') +     // ?           81-90
                                                                                 TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('ID') +             // a.id        91-100
                                                                                 NxFloatToIBStr(TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsFloat('X_vychystano'))); // quantity  101

                                                                                 msearch:=false;
                                                                                 for i:=0 to mDocList.count-1 do begin
                                                                                        if mdoclist.strings[i]=TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_parent_id') then msearch:=true;
                                                                                 end;
                                                                                 if not msearch then mdoclist.add(TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_parent_id'));


                                                                                 msearch:=false;
                                                                                 for i:=0 to mRowList.count-1 do begin
                                                                                        if mRowList.strings[i]=TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_parent2_id') then msearch:=true;
                                                                                 end;

                                                                                 if not msearch then begin
                                                                                     mRowList.add(TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_parent2_id'));
                                                                                     mbatchlist.add(TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_parent2_id')+TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_Batches') +TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('id')+NxFloatToIBStr(TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsFloat('X_vychystano')) );

                                                                                     mBatchWorkList.add(TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_Firm_ID') +       //              1-10
                                                                                           TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_parent_id') +    //  ii.id      11-20
                                                                                           TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_parent2_id') +   // ii2.id      21-30
                                                                                           TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_StoreCard_ID') + //  sc.id      31-40

                                                                                           TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_Devenolux') + //  sd.id      41-50
                                                                                           TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_MX_NAZEV') +      // sd2.id      51-60
                                                                                           TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_DE_NAZEV') +      // drb.id      61-70

                                                                                           TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_Batches') +      //   b.id      71-80
                                                                                           TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_Store_ID') +     // ?           81-90
                                                                                           TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('ID') +             // a.id        91-100
                                                                                           NxFloatToIBStr(TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsFloat('X_vychystano'))); // quantity  101

                                                                                 end;



                                   end;
                           end;

                  end;
                  ProgressDispose()   ;



                 mWorkList.Sort;
                  ProgressInit(msite, 'Zpracování dat', 100);


               //   mDocList
                mDocList.free;
                mRowList.free;
                mBatchList.free;
                mBatchWorklist.free;

                mDocList:=TStringList.create;
                mRowList:=TStringList.create;
                mBatchList:=TStringList.create;
                mBatchWorklist:=TStringList.create;

               //   mRowList

                  for mIWorklist:=0 to mWorkList.count-1 do begin
                      ProgressSetPos(1+NxFloor(mIWorklist/(mWorkList.count)*99), inttostr(mIWorklist) +' z '+inttostr(mWorkList.count));



                     if mIWorklist=0 then begin    // první záznam
                                     msearch:=false;
                                         mdoclist.add(copy(mWorkList.Strings[mIWorklist],11,10));
                                         mRowList.add(copy(mWorkList.Strings[mIWorklist],21,10));
                                         mbatchlist.add(copy(mWorkList.Strings[mIWorklist],21,10)+copy(mWorkList.Strings[mIWorklist],71,10) +copy(mWorkList.Strings[mIWorklist],91,10)+(copy(mWorkList.Strings[mIWorklist],101,10)) );
                                         mbatchworklist.add(mWorkList.Strings[mIWorklist]); // quantity  101


                                   mpocetdokladu:=mpocetdokladu+1;



                     end else begin            // kromě prvního záznamu
                                              if copy(mWorkList.Strings[mIWorklist-1],1,20)=copy(mWorkList.Strings[mIWorklist],1,20) then begin   // stejny doklad

                                                    if copy(mWorkList.Strings[mIWorklist-1],1,30)=copy(mWorkList.Strings[mIWorklist],1,30) then begin    // stejný řádek
                                                          mpocetradku:=mpocetradku+1;
                                                          if copy(mWorkList.Strings[mIWorklist-1],1,70)=copy(mWorkList.Strings[mIWorklist],1,70) then begin   // stejná šarže doklad
                                                                // dohledání šarže a navýšení
                                                                    //mRowList.add(copy(mWorkList.Strings[mIWorklist],21,10) );
                                                                    mbatchlist.add(copy(mWorkList.Strings[mIWorklist],21,10)+copy(mWorkList.Strings[mIWorklist],41,10) +copy(mWorkList.Strings[mIWorklist],61,10)+copy(mWorkList.Strings[mIWorklist],71,10) );
                                                                    mbatchworklist.add(mWorkList.Strings[mIWorklist]);
                                                                    mpocetsarzi:=mpocetsarzi+1

                                                          end else begin    // rozdílná šarže
                                                               //mRowList.add(copy(mWorkList.Strings[mIWorklist],21,10));
                                                               mbatchlist.add(copy(mWorkList.Strings[mIWorklist],21,10)+copy(mWorkList.Strings[mIWorklist],41,10) +copy(mWorkList.Strings[mIWorklist],61,10)+copy(mWorkList.Strings[mIWorklist],71,10) );
                                                               mbatchworklist.add(mWorkList.Strings[mIWorklist]);
                                                                    mpocetsarzi:=mpocetsarzi+1


                                                                // založení šarže
                                                          end;
                                                    end else begin    // rozdílný řádek
                                                         // založení řádku
                                                                                                  mRowList.add(copy(mWorkList.Strings[mIWorklist],21,10));
                                                                                                  mbatchlist.add(copy(mWorkList.Strings[mIWorklist],21,10)+copy(mWorkList.Strings[mIWorklist],41,10) +copy(mWorkList.Strings[mIWorklist],61,10)+copy(mWorkList.Strings[mIWorklist],71,10) );
                                                                                                  mbatchworklist.add(mWorkList.Strings[mIWorklist]);
                                                                                                  mpocetradku:=mpocetradku+1;

                                                    end;
                                              end else begin   // rozdílný doklad
                                                   // uložení dokladu
                                                  if mShowDebug then NxShowSimpleMessage(inttostr(mpocetradku),nil);

                                                    mpocetdokladu:=mDocList.count;
                                                   mpocetradku:=mRowList.count;
                                                   mpocetSarzi:=mRowList.count;

                                                  if mShowDebug  then NxShowSimpleMessage('Dokladů : ' + inttostr(mpocetdokladu) + ',' + chr(13)+
                                                                          'řádků : ' + inttostr(mpocetradku) + ',' + chr(13)+
                                                                          'šarží : ' + inttostr(mpocetsarzi) + ',' + chr(13),
                                                                          nil);

                                                   if index=0 then mstring:= CreateAllDocFromWorkListImport(msite,'01CPMINJW3DL342X01C0CX3FCC','CDMK5QAWZZDL342X01C0CX3FCC',mAgenda,mDocqueue_ID,mFirm_id,mDivision_ID,mStore_ID,mDocList,mRowList,index,mbatchlist,mbatchworklist);
                                                   if index=2 then mstring:= CreateAllDocFromWorkListImportpr(msite,'E03ZNUMDTCC4PDAUIEY1MBTJC0','3OKSI2XXYK2OB2JRPZ3U4UXTGK',mAgenda,mDocqueue_ID,mFirm_id,mDivision_ID,mStore_ID,mDocList,mRowList,index,mbatchlist,mBatchWorkList);




                                                       mpocetradku:=mpocetradku+1;

                                                       mDocList.free;
                                                       mRowList.free;
                                                       mbatchlist.free;
                                                       mbatchworklist.free;
                                                       mDocList:=TStringList.Create;
                                                       mRowList:=TStringList.Create;
                                                       mbatchlist:=TStringList.Create;
                                                       mbatchworklist:=TStringList.Create;

                                                               mdoclist.add(copy(mWorkList.Strings[mIWorklist],11,10));
                                                               mRowList.add(copy(mWorkList.Strings[mIWorklist],21,10));
                                                               mbatchlist.add(copy(mWorkList.Strings[mIWorklist],21,10)+copy(mWorkList.Strings[mIWorklist],41,10) + copy(mWorkList.Strings[mIWorklist],61,10) +copy(mWorkList.Strings[mIWorklist],71,10) );
                                                               mbatchworklist.add(mWorkList.Strings[mIWorklist]);


                                                   //založení nového dokladu
                                                          mpocetdokladu:=mpocetdokladu+1;
                                                   // založení nového řádku
                                                                mpocetradku:=mpocetradku+1;
                                              end;
                     end;


                  end;
                  // uložení posledního dokladu

                  // odeslani do importmanaegra;        }

                       ProgressDispose();

                        mpocetdokladu:=mDocList.count;
                   mpocetradku:=mRowList.count;
                   mpocetSarzi:=mRowList.count;

                        if mShowDebug then begin  NxShowSimpleMessage('Dokladů : ' + inttostr(mpocetdokladu) + ',' + chr(13)+
                                      'řádků : ' + inttostr(mpocetradku) + ',' + chr(13)+
                                      'šarží : ' + inttostr(mpocetsarzi) + ',' + chr(13),
                                      nil);
                        end;
                                if index=0 then mstring:= CreateAllDocFromWorkListImport(msite,'01CPMINJW3DL342X01C0CX3FCC','CDMK5QAWZZDL342X01C0CX3FCC',mAgenda,mDocqueue_ID,mFirm_id,mDivision_ID,mStore_ID,mDocList,mRowList,index,mbatchlist,mbatchworklist);
                                if index=2 then mstring:= CreateAllDocFromWorkListImportPR(msite,'E03ZNUMDTCC4PDAUIEY1MBTJC0','3OKSI2XXYK2OB2JRPZ3U4UXTGK',mAgenda,mDocqueue_ID,mFirm_id,mDivision_ID,mStore_ID,mDocList,mRowList,index,mbatchlist,mBatchWorkList);





                    // mhead.save;

        finally
          mWorkList.free;
          mDocList.free;
          mRowList.free;
          mbatchlist.free;
          mbatchworklist.free;
        end;
TBusRollSiteForm(mSite).RefreshData;
TBusRollSiteForm(mSite).Refresh;

NxShowSimpleMessage('Dokončeno', nil);
end;






{
Vyvolává se po provedení metody CloseQuery. Pomocí tohoto háčku je možné ovlivnit, zda je možné agendu/formulář zavřít.
}
procedure FormCloseQuery_Hook(Self: TSiteForm; var CanClose: Boolean);
begin

end;

procedure CheckDocumentBatch(Sender: TAction; Index: integer);
var
 mbo,mboNew:TNxCustomBusinessObject;
 mSite: TSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 x,i:integer;
   mForm: TBusRollSiteForm;
   mtext:string;
   mB_Result:boolean;
   mi:integer;
   mr,mx:tstringlist;
   mVolne,mNaDokladu,mNaVratce,mquantity:double;
   msave:Boolean;
   mQuantityTemp,mQuantityVratka,mQuantityDoc, mQuantityPomoc, mQuantitySource:double;
   mBoolean:boolean;
   maPocet:double;
begin
  msite:=TComponent(Sender).Site;
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    mbo:= TBusRollSiteForm(mSite).CurrentObject;
    //mB_Result:=InputQuery('Zadaj parametry', 'Změna ', mtext);

    ProgressInit(msite, 'Hledání souborů ' + '', 100);
    if mBookmark.count=0 then begin
           if index=5 then begin
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_Parent_ID','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_Parent2_ID','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_vychystano',0);
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_dodano',0);
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_PM_State','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_CLSID','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_EN_NAZEV','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_DE_NAZEV','');

                  TBusRollSiteForm(mSite).CurrentObject.save;
                  TBusRollSiteForm(mSite).DataSet.RefreshCurrentItem;
           end else begin
                              mQuantitySource:=0;
                              mQuantitySource:= TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsFloat('X_Quantity');
                              mQuantityPomoc:=mQuantitySource-TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsFloat('X_vychystano');
                              mr:=TStringList.create;
                              try

                              if index=0 then begin
                                                 if ((not NxIsEmptyOID(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches'))) and
                                                    (TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsinteger('X_Storecard_ID.Category')=2)) then begin
                                                   mSite.BaseObjectSpace.SQLSelect('SELECT  ii.id||ii2.id||drb.id||CAST(drb.quantity AS VARCHAR(10)) '+
                                                                                    ' FROM StoreBatches B  join DocRowBatches DRB on b.id=DRB.StoreBatch_ID '+
                                                                                    ' join IssuedInvoices2 ii2 on DRB.Parent_ID=ii2.ProvideRow_ID '+
                                                                                    ' join IssuedInvoices ii ON ii2.Parent_ID=ii.ID '+
                                                                                    ' join Firms F on f.id=ii.Firm_ID ' +
                                                                                    ' WHERE (F.ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+
                                                                                    ' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+')) )'+
                                                                                    ' and  (b.id = '+ quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches')) +
                                                                                    ') order by ii2.quantity desc',mr) ;

                                                  end else begin
                                                           if ((NxIsEmptyOID(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches'))))  then
                                                             mSite.BaseObjectSpace.SQLSelect('SELECT  ii.id||ii2.id||ii2.id||CAST(ii2.quantity AS VARCHAR(10)) '+
                                                                                              ' FROM IssuedInvoices2 ii2 '+
                                                                                              ' join IssuedInvoices ii ON ii2.Parent_ID=ii.ID '+
                                                                                              ' join Firms F on f.id=ii.Firm_ID ' +
                                                                                              ' WHERE (F.ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+
                                                                                              ' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+')) )'+
                                                                                              ' and  (II2.Storecard_ID = '+ quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Storecard_ID')) +
                                                                                              ') and (not exists (SELECT 1 FROM Docrowbatches DRB where DRB.Parent_ID=ii2.ProvideRow_ID )) ' +
                                                                                              ' order by ii2.quantity desc',mr) ;
                                                  end;

                              end;
                              if mShowDebug then
                              mboolean:=InputQuery('','','SELECT  ii.id||ii2.id||drb.id||CAST(drb.quantity AS VARCHAR(10)) '+
                                                                                    ' FROM StoreBatches B  join DocRowBatches DRB on b.id=DRB.StoreBatch_ID '+
                                                                                    ' join IssuedInvoices2 ii2 on DRB.Parent_ID=ii2.ProvideRow_ID '+
                                                                                    ' join IssuedInvoices ii ON ii2.Parent_ID=ii.ID '+
                                                                                    ' join Firms F on f.id=ii.Firm_ID ' +
                                                                                    ' WHERE (F.ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+
                                                                                    ' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+')) )'+
                                                                                    ' and  (b.id = '+ quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches')) +
                                                                                    ') order by ii2.quantity desc') ;
                              if index=1 then begin
                                                 if ((not NxIsEmptyOID(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches'))) and
                                                    (TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsinteger('X_Storecard_ID.Category')=2)) then
                                                   mSite.BaseObjectSpace.SQLSelect('SELECT  sd.id||sd2.id||drb.id||CAST(drb.quantity AS VARCHAR(10)) '+
                                                                                    ' FROM StoreBatches B  join DocRowBatches DRB on b.id=DRB.StoreBatch_ID '+
                                                                                    ' join StoreDocuments2 sd2 on DRB.Parent_ID=sd2.ID '+
                                                                                    ' join StoreDocuments sd ON sd2.Parent_ID=sd.ID '+
                                                                                    ' join Firms F on f.id=SD.Firm_ID ' +
                                                                                    ' WHERE (F.ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+
                                                                                    ' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+')) )'+
                                                                                    ' and  (b.id = '+ quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches')) +
                                                                                    ' and sd.DocumentType= ' + quotedstr('20') + ') order by sd2.quantity desc',mr) ;

                                                 if ((NxIsEmptyOID(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches'))) and
                                                    (TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsinteger('X_Storecard_ID.Category')<>2)) then
                                                   mSite.BaseObjectSpace.SQLSelect('SELECT  sd.id||sd2.id||sd2.id||CAST(sd2.quantity AS VARCHAR(10)) '+
                                                                                    ' FROM StoreDocuments2 sd2 '+
                                                                                    ' join StoreDocuments sd ON sd2.Parent_ID=sd.ID '+
                                                                                    ' join Firms F on f.id=SD.Firm_ID ' +
                                                                                    ' WHERE (F.ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+
                                                                                    ' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+')) )'+
                                                                                    ' and  (sd2.Storecard_ID = '+ quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Storecard_ID')) +
                                                                                    ') order by sd2.quantity desc',mr) ;

                              end;


                              if index=4 then begin
                                                 if ((not NxIsEmptyOID(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches'))) and
                                                    (TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsinteger('X_Storecard_ID.Category')=2)) then
                                                   mSite.BaseObjectSpace.SQLSelect('SELECT  sd.id||sd2.id||DRB.id||CAST(drb.quantity AS VARCHAR(10)) '+
                                                                                    ' FROM StoreBatches B  join DocRowBatches DRB on b.id=DRB.StoreBatch_ID '+
                                                                                    ' join StoreDocuments2 sd2 on DRB.Parent_ID=sd2.ID '+
                                                                                    ' join StoreDocuments sd ON sd2.Parent_ID=sd.ID '+
                                                                                    ' join Firms F on f.id=sd.Firm_ID ' +
                                                                                    ' WHERE (F.ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+
                                                                                    ' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+')) )'+
                                                                                    ' and  (b.id = '+ quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches')) +
                                                                                    ' and sd.DocumentType= ' + quotedstr('21') + ') order by sd2.quantity desc',mr) ;

                                                 if ((NxIsEmptyOID(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches'))) and
                                                    (TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsinteger('X_Storecard_ID.Category')<>2)) then
                                                   mSite.BaseObjectSpace.SQLSelect('SELECT  sd.id||sd2.id||sd2.id||CAST(sd2.quantity AS VARCHAR(10)) '+
                                                                                    ' FROM StoreDocuments2 sd2 '+
                                                                                    ' join StoreDocuments sd ON sd2.Parent_ID=sd.ID '+
                                                                                    ' join Firms F on f.id=SD.Firm_ID ' +
                                                                                    ' WHERE (F.ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+
                                                                                    ' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+')) )'+
                                                                                    ' and  (sd2.Storecard_ID = '+ quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Storecard_ID')) +
                                                                                    ') order by sd2.quantity desc',mr) ;

                              end;



                                   // if mShowDebug then  NxShowSimpleMessage('Počet nálezů ' +  inttostr(mr.count),nil);
                                    for i:=0 to mr.count-1 do begin
                                            if mShowDebug then NxShowSimpleMessage(mr.Strings[i],nil);

                                            mQuantityDoc:=NxIBStrToFloat(copy(mr.Strings[0],31,10));

                                             if mShowDebug then NxShowSimpleMessage(' Množství na zdrojovém pohybu šarže' + NxFloatToIBStr(mQuantityDoc),nil);
                                             if mShowDebug then NxShowSimpleMessage(' je potřeba vrátit pomoc k vrácení' + NxFloatToIBStr(mQuantityPomoc),nil);

                                      if mQuantityPomoc>0  then begin

                                            mQuantityVratka:=0;
                                            try
                                            if index=0 then begin
                                            // ******** již vráceno

                                                          mx:=tstringlist.create;
                                                           try
                                                                // msite.BaseObjectSpace.SQLSelect('select sum(x.quantity) from IssuedCreditNotes2 x where x.RSource_ID=' + QuotedStr(copy(mr.Strings[i],11,10)),mx);
                                                                msite.BaseObjectSpace.SQLSelect('select sum(drb.quantity)  from issuedinvoices2 ii2 left join storedocuments2 SD2 on sd2.id=ii2.ProvideRow_ID left join storedocuments2 nSD2 on nsd2.RdocumentRow_ID=sd2.id left join docrowbatches DRB on drb.Parent_ID=nsd2.id '
                                                                + ' where ii2.id=' + QuotedStr(copy(mr.Strings[i],11,10))   + ' and drb.StoreBatch_ID=' + quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches')),mx);
                                                                 if mx.count>0 then mQuantityVratka:=NxIBStrToFloat(mx.Strings[0]) else mQuantityVratka:=0;
                                                                 if mShowDebug then nxShowSimpleMessage('z ' + copy(mr.Strings[i],31,10) + ' vráceno ' +  NxFloatToIBStr(mQuantityVratka),nil);

                                                           finally
                                                               mx.free;
                                                           end;
                                             end;
                                             finally

                                             end;
                                                 //   ***** v temp již použito
                                                 mx:=tstringlist.create;
                                                 try
                                                       msite.BaseObjectSpace.SQLSelect('select sum(x.X_vychystano) FROM DefRollData X WHERE X.CLSID = ' + QuotedStr('45D1XVW5EY24JBXTOE01EHYRSG') + ' AND x.X_DE_NAZEV=' +
                                                                                       quotedstr(copy(mr.Strings[0],21,10)) ,mx);
                                                                if mx.count>0 then mQuantityTemp:=NxIBStrToFloat(mx.Strings[0]) else mQuantityTemp:=0;
                                                              if mShowDebug then nxShowSimpleMessage('z ' + copy(mr.Strings[0],31,10) + ' použito na temp  ' +  NxFloatToIBStr(mQuantityTemp),nil);
                                                 finally
                                                     mx.free;
                                                 end;



                                                             if mQuantityDoc-mQuantityVratka-mQuantityTemp>0 then begin    /// je možné čerpat
                                                                             TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_parent_ID',copy(mr.Strings[i],1,10));
                                                                             TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_parent2_id',copy(mr.Strings[i],11,10));
                                                                             if copy(mr.Strings[i],11,10)<> copy(mr.Strings[i],21,10) then
                                                                                    TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_DE_NAZEV',copy(mr.Strings[i],21,10));
                                                                       if mQuantityPomoc>(mQuantityDoc-mQuantityVratka-mQuantityTemp) then begin
                                                                             TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_vychystano',mQuantityDoc-mQuantityVratka-mQuantityTemp);

                                                                             if mShowDebug then nxShowSimpleMessage(' je potřeba  ' +  NxFloatToIBStr(mQuantitySource) +  ' na dokladu  ' +  NxFloatToIBStr(mQuantityDoc)+ ' vráceno ' +  NxFloatToIBStr(mQuantityVratka) +' použito na temp  ' +  NxFloatToIBStr(mQuantityTemp)  +chr(13) +
                                                                                   ' bude použito ' +  NxFloatToIBStr(mQuantityDoc-mQuantityVratka-mQuantityTemp) ,nil);
                                                                                   mQuantityPomoc:=mQuantityPomoc-(mQuantityDoc-mQuantityVratka-mQuantityTemp);
                                                                       end else begin
                                                                             TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_vychystano',mQuantityPomoc);
                                                                              if mShowDebug then nxShowSimpleMessage(' je potřeba  ' +  NxFloatToIBStr(mQuantitySource) +  ' na dokladu  ' +  NxFloatToIBStr(mQuantityDoc)+ ' vráceno ' +  NxFloatToIBStr(mQuantityVratka) +' použito na temp  ' +  NxFloatToIBStr(mQuantityTemp)  +chr(13) +
                                                                                   ' bude použito ' +  NxFloatToIBStr(mQuantityPomoc) ,nil);
                                                                             mQuantityPomoc:=mQuantityPomoc-(mQuantityPomoc);
                                                                       end;

                                                                        TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_PM_State','1050000101');
                                                                        if index=0 then TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_CLSID','O3BDOKTWEFD13ACM03KIU0CLP4');
                                                                        if index=1 then TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_CLSID','42HE04FZGJD13ACM03KIU0CLP4');
                                                                        if index=4 then TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_CLSID','050I5SAOS3DL3ACU03KIU0CLP4');
                                                                        TBusRollSiteForm(mSite).CurrentObject.save;

                                                             end else begin
                                                                   if mShowDebug then nxShowSimpleMessage(' je potřeba  ' +  NxFloatToIBStr(mQuantitySource) +  ' na dokladu  ' +  NxFloatToIBStr(mQuantityDoc)+ ' vráceno ' +  NxFloatToIBStr(mQuantityVratka) +' použito na temp  ' +  NxFloatToIBStr(mQuantityTemp)  +chr(13) +
                                                                                   ' nelze použít ' ,nil);
                                                                                   TBusRollSiteForm(mSite).CurrentObject.save;
                                                             end;
                                     end;


                                    end;



                                      if mQuantityPomoc>0 then begin
                                        if NxIsEmptyOID(TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_parent2_id')) then begin
                                                 if mShowDebug then NxShowSimpleMessage('nedohledáno',nil);
                                                 TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_PM_State','3020000101');
                                                 TBusRollSiteForm(mSite).CurrentObject.save;
                                                 TBusRollSiteForm(mSite).DataSet.RefreshCurrentItem;
                                        end else begin
                                            mbonew:=msite.BaseObjectSpace.CreateObject('45D1XVW5EY24JBXTOE01EHYRSG');
                                            try
                                            mboNew.new;
                                                mboNew.Prefill;
                                                if mShowDebug then   NxShowSimpleMessage('Založen na zbytek',nil);
                                                mbonew.SetFieldValueAsString('X_CreatedBy_ID', msite.CompanyCache.GetUserID);
                                                mbonew.SetFieldValueAsString('Code',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('Code'));
                                                mbonew.SetFieldValueAsString('Name',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('name'));
                                                mbonew.SetFieldValueAsString('X_firm_ID',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'));
                                                mbonew.SetFieldValueAsString('X_Storecard_ID',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Storecard_ID'));
                                                mbonew.SetFieldValueAsString('X_Batches',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches'));
                                                mbonew.SetFieldValueAsFloat('X_quantity',mQuantityPomoc);
                                                mbonew.SetFieldValueAsDateTime('X_ABRADate',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsDateTime('X_ABRADate'));
                                                mbonew.SetFieldValueAsFloat('X_vychystano',mQuantityPomoc);
                                                mbonew.SetFieldValueAsString('X_PM_State','2020000101');
                                                if index=0 then mbonew.SetFieldValueAsString('X_CLSID','O3BDOKTWEFD13ACM03KIU0CLP4');
                                                if index=1 then mbonew.SetFieldValueAsString('X_CLSID','42HE04FZGJD13ACM03KIU0CLP4');
                                                if index=4 then mbonew.SetFieldValueAsString('X_CLSID','050I5SAOS3DL3ACU03KIU0CLP4');
                                                //NxShowSimpleMessage('Příprava uložení zbtku',nil);
                                                mbonew.save;
                                                mapocet:= TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsFloat('X_quantity')-mQuantityPomoc;
                                                TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_quantity',mapocet);
                                                TBusRollSiteForm(mSite).CurrentObject.save;

                                                if mShowDebug then  NxShowSimpleMessage('Zbytek Uložen',nil);
                                                mQuantityPomoc:=mQuantityPomoc-mQuantityPomoc;
                                             finally
                                                mbonew.free;
                                             end;
                                        end;
                                    end;
                              finally

                                 mr.free;
                              end;
                            TBusRollSiteForm(mSite).DataSet.RefreshCurrentItem;
                            msite.Refresh;

         end
    end else begin
         for x := 0 to mBookmark.Count- 1 do begin
                          mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(x));
                          ProgressSetPos(1+NxFloor(x/mBookmark.Count*99), inttostr(x) +' z '+inttostr(mBookmark.Count));
                  if index=5 then begin
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_Parent_ID','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_Parent2_ID','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_vychystano',0);
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_dodano',0);
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_PM_State','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_CLSID','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_EN_NAZEV','');
                  TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_DE_NAZEV','');

                  TBusRollSiteForm(mSite).CurrentObject.save;
                  TBusRollSiteForm(mSite).DataSet.RefreshCurrentItem;
           end else begin
                              mQuantitySource:=0;
                              mQuantitySource:= TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsFloat('X_Quantity');
                              mQuantityPomoc:=mQuantitySource-TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsFloat('X_vychystano');
                              mr:=TStringList.create;
                              try

                              if index=0 then begin
                                                 if ((not NxIsEmptyOID(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches'))) and
                                                    (TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsinteger('X_Storecard_ID.Category')=2)) then begin
                                                   mSite.BaseObjectSpace.SQLSelect('SELECT  ii.id||ii2.id||drb.id||CAST(drb.quantity AS VARCHAR(10)) '+
                                                                                    ' FROM StoreBatches B  join DocRowBatches DRB on b.id=DRB.StoreBatch_ID '+
                                                                                    ' join IssuedInvoices2 ii2 on DRB.Parent_ID=ii2.ProvideRow_ID '+
                                                                                    ' join IssuedInvoices ii ON ii2.Parent_ID=ii.ID '+
                                                                                    ' join Firms F on f.id=ii.Firm_ID ' +
                                                                                    ' WHERE (F.ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+
                                                                                    ' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+')) )'+
                                                                                    ' and  (b.id = '+ quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches')) +
                                                                                    ') order by ii2.quantity desc',mr) ;

                                                  end else begin
                                                           if ((NxIsEmptyOID(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches'))))  then
                                                             mSite.BaseObjectSpace.SQLSelect('SELECT  ii.id||ii2.id||ii2.id||CAST(ii2.quantity AS VARCHAR(10)) '+
                                                                                              ' FROM IssuedInvoices2 ii2 '+
                                                                                              ' join IssuedInvoices ii ON ii2.Parent_ID=ii.ID '+
                                                                                              ' join Firms F on f.id=ii.Firm_ID ' +
                                                                                              ' WHERE (F.ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+
                                                                                              ' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+')) )'+
                                                                                              ' and  (II2.Storecard_ID = '+ quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Storecard_ID')) +
                                                                                              ') and (not exists (SELECT 1 FROM Docrowbatches DRB where DRB.Parent_ID=ii2.ProvideRow_ID )) ' +
                                                                                              ' order by ii2.quantity desc',mr) ;
                                                  end;

                              end;
                              if mShowDebug then
                              mboolean:=InputQuery('','','SELECT  ii.id||ii2.id||drb.id||CAST(drb.quantity AS VARCHAR(10)) '+
                                                                                    ' FROM StoreBatches B  join DocRowBatches DRB on b.id=DRB.StoreBatch_ID '+
                                                                                    ' join IssuedInvoices2 ii2 on DRB.Parent_ID=ii2.ProvideRow_ID '+
                                                                                    ' join IssuedInvoices ii ON ii2.Parent_ID=ii.ID '+
                                                                                    ' join Firms F on f.id=ii.Firm_ID ' +
                                                                                    ' WHERE (F.ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+
                                                                                    ' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+')) )'+
                                                                                    ' and  (b.id = '+ quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches')) +
                                                                                    ') order by ii2.quantity desc') ;
                              if index=1 then begin
                                                 if ((not NxIsEmptyOID(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches'))) and
                                                    (TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsinteger('X_Storecard_ID.Category')=2)) then
                                                   mSite.BaseObjectSpace.SQLSelect('SELECT  sd.id||sd2.id||drb.id||CAST(drb.quantity AS VARCHAR(10)) '+
                                                                                    ' FROM StoreBatches B  join DocRowBatches DRB on b.id=DRB.StoreBatch_ID '+
                                                                                    ' join StoreDocuments2 sd2 on DRB.Parent_ID=sd2.ID '+
                                                                                    ' join StoreDocuments sd ON sd2.Parent_ID=sd.ID '+
                                                                                    ' join Firms F on f.id=SD.Firm_ID ' +
                                                                                    ' WHERE (F.ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+
                                                                                    ' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+')) )'+
                                                                                    ' and  (b.id = '+ quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches')) +
                                                                                    ' and sd.DocumentType= ' + quotedstr('20') + ') order by sd2.quantity desc',mr) ;

                                                 if ((NxIsEmptyOID(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches'))) and
                                                    (TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsinteger('X_Storecard_ID.Category')<>2)) then
                                                   mSite.BaseObjectSpace.SQLSelect('SELECT  sd.id||sd2.id||sd2.id||CAST(sd2.quantity AS VARCHAR(10)) '+
                                                                                    ' FROM StoreDocuments2 sd2 '+
                                                                                    ' join StoreDocuments sd ON sd2.Parent_ID=sd.ID '+
                                                                                    ' join Firms F on f.id=SD.Firm_ID ' +
                                                                                    ' WHERE (F.ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+
                                                                                    ' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+')) )'+
                                                                                    ' and  (sd2.Storecard_ID = '+ quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Storecard_ID')) +
                                                                                    ') order by sd2.quantity desc',mr) ;

                              end;


                              if index=4 then begin
                                                 if ((not NxIsEmptyOID(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches'))) and
                                                    (TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsinteger('X_Storecard_ID.Category')=2)) then
                                                   mSite.BaseObjectSpace.SQLSelect('SELECT  sd.id||sd2.id||DRB.id||CAST(drb.quantity AS VARCHAR(10)) '+
                                                                                    ' FROM StoreBatches B  join DocRowBatches DRB on b.id=DRB.StoreBatch_ID '+
                                                                                    ' join StoreDocuments2 sd2 on DRB.Parent_ID=sd2.ID '+
                                                                                    ' join StoreDocuments sd ON sd2.Parent_ID=sd.ID '+
                                                                                    ' join Firms F on f.id=sd.Firm_ID ' +
                                                                                    ' WHERE (F.ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+
                                                                                    ' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+')) )'+
                                                                                    ' and  (b.id = '+ quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches')) +
                                                                                    ' and sd.DocumentType= ' + quotedstr('21') + ') order by sd2.quantity desc',mr) ;

                                                 if ((NxIsEmptyOID(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches'))) and
                                                    (TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsinteger('X_Storecard_ID.Category')<>2)) then
                                                   mSite.BaseObjectSpace.SQLSelect('SELECT  sd.id||sd2.id||sd2.id||CAST(sd2.quantity AS VARCHAR(10)) '+
                                                                                    ' FROM StoreDocuments2 sd2 '+
                                                                                    ' join StoreDocuments sd ON sd2.Parent_ID=sd.ID '+
                                                                                    ' join Firms F on f.id=SD.Firm_ID ' +
                                                                                    ' WHERE (F.ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+
                                                                                    ' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+')) )'+
                                                                                    ' and  (sd2.Storecard_ID = '+ quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Storecard_ID')) +
                                                                                    ') order by sd2.quantity desc',mr) ;

                              end;



                                   // if mShowDebug then  NxShowSimpleMessage('Počet nálezů ' +  inttostr(mr.count),nil);
                                    for i:=0 to mr.count-1 do begin
                                            if mShowDebug then NxShowSimpleMessage(mr.Strings[i],nil);

                                            mQuantityDoc:=NxIBStrToFloat(copy(mr.Strings[0],31,10));

                                             if mShowDebug then NxShowSimpleMessage(' Množství na zdrojovém pohybu šarže' + NxFloatToIBStr(mQuantityDoc),nil);
                                             if mShowDebug then NxShowSimpleMessage(' je potřeba vrátit pomoc k vrácení' + NxFloatToIBStr(mQuantityPomoc),nil);

                                      if mQuantityPomoc>0  then begin

                                            mQuantityVratka:=0;
                                            try
                                            if index=0 then begin
                                            // ******** již vráceno

                                                          mx:=tstringlist.create;
                                                           try
                                                                // msite.BaseObjectSpace.SQLSelect('select sum(x.quantity) from IssuedCreditNotes2 x where x.RSource_ID=' + QuotedStr(copy(mr.Strings[i],11,10)),mx);
                                                                msite.BaseObjectSpace.SQLSelect('select sum(drb.quantity)  from issuedinvoices2 ii2 left join storedocuments2 SD2 on sd2.id=ii2.ProvideRow_ID left join storedocuments2 nSD2 on nsd2.RdocumentRow_ID=sd2.id left join docrowbatches DRB on drb.Parent_ID=nsd2.id '
                                                                + ' where ii2.id=' + QuotedStr(copy(mr.Strings[i],11,10))   + ' and drb.StoreBatch_ID=' + quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches')),mx);
                                                                 if mx.count>0 then mQuantityVratka:=NxIBStrToFloat(mx.Strings[0]) else mQuantityVratka:=0;
                                                                 if mShowDebug then nxShowSimpleMessage('z ' + copy(mr.Strings[i],31,10) + ' vráceno ' +  NxFloatToIBStr(mQuantityVratka),nil);

                                                           finally
                                                               mx.free;
                                                           end;
                                             end;
                                             finally

                                             end;
                                                 //   ***** v temp již použito
                                                 mx:=tstringlist.create;
                                                 try
                                                       msite.BaseObjectSpace.SQLSelect('select sum(x.X_vychystano) FROM DefRollData X WHERE X.CLSID = ' + QuotedStr('45D1XVW5EY24JBXTOE01EHYRSG') + ' AND x.X_DE_NAZEV=' +
                                                                                       quotedstr(copy(mr.Strings[0],21,10)) ,mx);
                                                                if mx.count>0 then mQuantityTemp:=NxIBStrToFloat(mx.Strings[0]) else mQuantityTemp:=0;
                                                              if mShowDebug then nxShowSimpleMessage('z ' + copy(mr.Strings[0],31,10) + ' použito na temp  ' +  NxFloatToIBStr(mQuantityTemp),nil);
                                                 finally
                                                     mx.free;
                                                 end;



                                                             if mQuantityDoc-mQuantityVratka-mQuantityTemp>0 then begin    /// je možné čerpat
                                                                             TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_parent_ID',copy(mr.Strings[i],1,10));
                                                                             TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_parent2_id',copy(mr.Strings[i],11,10));
                                                                             if copy(mr.Strings[i],11,10)<> copy(mr.Strings[i],21,10) then
                                                                                    TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_DE_NAZEV',copy(mr.Strings[i],21,10));
                                                                       if mQuantityPomoc>(mQuantityDoc-mQuantityVratka-mQuantityTemp) then begin
                                                                             TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_vychystano',mQuantityDoc-mQuantityVratka-mQuantityTemp);

                                                                             if mShowDebug then nxShowSimpleMessage(' je potřeba  ' +  NxFloatToIBStr(mQuantitySource) +  ' na dokladu  ' +  NxFloatToIBStr(mQuantityDoc)+ ' vráceno ' +  NxFloatToIBStr(mQuantityVratka) +' použito na temp  ' +  NxFloatToIBStr(mQuantityTemp)  +chr(13) +
                                                                                   ' bude použito ' +  NxFloatToIBStr(mQuantityDoc-mQuantityVratka-mQuantityTemp) ,nil);
                                                                                   mQuantityPomoc:=mQuantityPomoc-(mQuantityDoc-mQuantityVratka-mQuantityTemp);
                                                                       end else begin
                                                                             TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_vychystano',mQuantityPomoc);
                                                                              if mShowDebug then nxShowSimpleMessage(' je potřeba  ' +  NxFloatToIBStr(mQuantitySource) +  ' na dokladu  ' +  NxFloatToIBStr(mQuantityDoc)+ ' vráceno ' +  NxFloatToIBStr(mQuantityVratka) +' použito na temp  ' +  NxFloatToIBStr(mQuantityTemp)  +chr(13) +
                                                                                   ' bude použito ' +  NxFloatToIBStr(mQuantityPomoc) ,nil);
                                                                             mQuantityPomoc:=mQuantityPomoc-(mQuantityPomoc);
                                                                       end;

                                                                        TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_PM_State','1050000101');
                                                                        if index=0 then TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_CLSID','O3BDOKTWEFD13ACM03KIU0CLP4');
                                                                        if index=1 then TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_CLSID','42HE04FZGJD13ACM03KIU0CLP4');
                                                                        if index=4 then TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_CLSID','050I5SAOS3DL3ACU03KIU0CLP4');
                                                                        TBusRollSiteForm(mSite).CurrentObject.save;

                                                             end else begin
                                                                   if mShowDebug then nxShowSimpleMessage(' je potřeba  ' +  NxFloatToIBStr(mQuantitySource) +  ' na dokladu  ' +  NxFloatToIBStr(mQuantityDoc)+ ' vráceno ' +  NxFloatToIBStr(mQuantityVratka) +' použito na temp  ' +  NxFloatToIBStr(mQuantityTemp)  +chr(13) +
                                                                                   ' nelze použít ' ,nil);
                                                                                   TBusRollSiteForm(mSite).CurrentObject.save;
                                                             end;
                                     end;


                                    end;



                                      if mQuantityPomoc>0 then begin
                                        if NxIsEmptyOID(TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsString('X_parent2_id')) then begin
                                                 if mShowDebug then NxShowSimpleMessage('nedohledáno',nil);
                                                 TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_PM_State','3020000101');
                                                 TBusRollSiteForm(mSite).CurrentObject.save;
                                                 TBusRollSiteForm(mSite).DataSet.RefreshCurrentItem;
                                        end else begin
                                            mbonew:=msite.BaseObjectSpace.CreateObject('45D1XVW5EY24JBXTOE01EHYRSG');
                                            try
                                            mboNew.new;
                                                mboNew.Prefill;
                                                if mShowDebug then   NxShowSimpleMessage('Založen na zbytek',nil);
                                                mbonew.SetFieldValueAsString('X_CreatedBy_ID', msite.CompanyCache.GetUserID);
                                                mbonew.SetFieldValueAsString('Code',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('Code'));
                                                mbonew.SetFieldValueAsString('Name',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('name'));
                                                mbonew.SetFieldValueAsString('X_firm_ID',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'));
                                                mbonew.SetFieldValueAsString('X_Storecard_ID',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Storecard_ID'));
                                                mbonew.SetFieldValueAsString('X_Batches',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches'));
                                                mbonew.SetFieldValueAsDateTime('X_ABRADate',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsDateTime('X_ABRADate'));
                                                mbonew.SetFieldValueAsFloat('X_quantity',mQuantityPomoc);
                                                mbonew.SetFieldValueAsFloat('X_vychystano',mQuantityPomoc);
                                                mbonew.SetFieldValueAsString('X_PM_State','2020000101');
                                                if index=0 then mbonew.SetFieldValueAsString('X_CLSID','O3BDOKTWEFD13ACM03KIU0CLP4');
                                                if index=1 then mbonew.SetFieldValueAsString('X_CLSID','42HE04FZGJD13ACM03KIU0CLP4');
                                                if index=4 then mbonew.SetFieldValueAsString('X_CLSID','050I5SAOS3DL3ACU03KIU0CLP4');
                                                //NxShowSimpleMessage('Příprava uložení zbtku',nil);
                                                mbonew.save;
                                                mapocet:= TBusRollSiteForm(mSite).CurrentObject.getFieldValueAsFloat('X_quantity')-mQuantityPomoc;
                                                TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_quantity',mapocet);
                                                TBusRollSiteForm(mSite).CurrentObject.save;

                                                if mShowDebug then  NxShowSimpleMessage('Zbytek Uložen',nil);
                                                mQuantityPomoc:=mQuantityPomoc-mQuantityPomoc;
                                             finally
                                                mbonew.free;
                                             end;
                                        end;
                                    end;
                              finally

                                 mr.free;
                              end;
                            TBusRollSiteForm(mSite).DataSet.RefreshCurrentItem;
                            msite.Refresh;

         end ;
              end;
       end;
ProgressDispose()   ;



end;






function ZpracujImport(OS: TNxCustomObjectSpace; AFileName: string;directory: string;filename: string;msite:TSiteForm;rucne:boolean;chyba:boolean;index:integer;ASaveFile:string;Savedirectory:string;savefilename:string) : Boolean;
var
    mImportFile:TStringList;
    mid :string;
    moddelovac:string;
    mOLE, mRoll, mOResult: Variant;
  mGrid: TdbGrid;
  mControl: TControl;
  mDataSource: TDataSource;
  mDataset: TNxRowsObjectDataSet;
  mStorecard_ID,mBatch_ID,mFirm_ID:string;
  mList:tstringlist;
  mQuantity:double;
  iRow,iBatch,i:Integer;
  mRSql:tstringlist;
  mWorkList:Tstringlist;
  mXMLHead : TNxScriptingXMLWrapper;
  mfieldValue:tstringlist;
  mBO_Temp:TNxCustomBusinessObject;
  mstringline:string;
  mCountField:integer;
  _ss:Variant;
  mstring:string;
  mvalue:TStringList;
begin
   //NxShowSimpleMessage('ddd',nil);
  mBO_Temp:= os.CreateObject('45D1XVW5EY24JBXTOE01EHYRSG');

  mOLE := GetAbraOLEApplication;
                            mroll := mOLE.GetAgenda('N1C2EX0BUJD13ACP03KIU0CLP4');
                            _ss := mOLE.CreateStrings;

                               mfirm_id := mroll.SingleSelectFromSelected2(_ss, 'Vyber odběratele', '');




//  :='8FCG300101';

    mWorkList:=TStringList.create;
    try
        //  NxShowSimpleMessage('eee',nil);
          if not FileExists(AFileName) then begin   // soubor nenalezen
            //NxShowSimpleMessage('Soubor nenalezen, přerušuji import',nil);
            Result := False;
            exit;
          end;
                  //NxShowSimpleMessage(inttostr(index),nil);
                 //NxShowSimpleMessage('ffff',nil);
                             if index=3 then begin   // ***** import z xml
                              // mBO_Temp:=msite.BaseObjectSpace.CreateObject('45D1XVW5EY24JBXTOE01EHYRSG');
                                      mImportFile:=TStringList.create;
                                      mImportFile.LoadFromFile(AFileName);
                                        // NxShowSimpleMessage(inttostr(index),nil);
                                         ProgressInit(msite, 'Načtení souboru ' + AFileName, 100);
                                             i := 0;
                                               for i:=0 to mImportFile.Count-1 do begin   // načtení souboru
                                                                 ProgressSetPos(1+NxFloor((i/mImportFile.Count)*99), inttostr(i) +' z '+inttostr(mImportFile.Count));

                                                                 mstringline:= mImportFile.strings[i];

                                                                 mstring:= DatamatrixDecodeBatches(TBusRollSiteForm(msite).BaseObjectSpace,mstringline);
                                                                        mbatch_ID:='';
                                                                        mStoreCard_ID:='';
                                                                        mquantity:=0;

                                                                     if mstring<>'' then begin

                                                                              mvalue:= Parsevaluelightx(mstring,';');
                                                          if mvalue.count>0 then begin
                                                                if mvalue.count>0 then  mStoreCard_ID:=mvalue.Strings[1];
                                                                if mvalue.count>1 then  mbatch_ID:=mvalue.Strings[2];
                                                                if mvalue.count>2 then mquantity:=NxIBStrToFloat(mvalue.Strings[3]) else mquantity:=1 ;
                                                           end else begin
                                                               //NxShowSimpleMessage( mstring,nil);
                                                               mStoreCard_ID:=copy(mstring,12,10);
                                                               mbatch_ID:=copy(mstring,23,10);
                                                               if NxIsNumeric((trim(copy(mstring,34,5)))) then
                                                                   mquantity:=NxIBStrToFloat(trim(copy(mstring,34,10)))
                                                                else mquantity:=1 ;
                                                           end;
                                                                      end else begin
                                                                         mbatch_ID:='';
                                                                        mStoreCard_ID:='';
                                                                        mquantity:=1;

                                                                      end;






                                                                               mRSql:= tstringlist.Create;   // ***** dohledání již existujícího záznamu
                                                                                          try
                                                                                             os.SQLSelect('SELECT A.id FROM DefRollData A WHERE (A.Hidden = ''N'' ) AND (A.CLSID = ''45D1XVW5EY24JBXTOE01EHYRSG'' ) AND ((A.X_Firm_ID = '
                                                                                                           + quotedstr(mFirm_ID) + ' OR A.X_Firm_ID IN (SELECT ID FROM Firms WHERE Firm_ID = '
                                                                                                           + quotedstr(mFirm_ID) + ')))  AND a.X_ABRADate=' +inttostr(trunc(now()))  + ' AND ((A.X_Batches = ' + quotedstr(mbatch_ID) + ') and (A.Name = ' + quotedstr(mImportFile.strings[i]) + ')) ' ,mRSql);
                                                                                             if mRSql.count>0 then begin
                                                                                                  mBO_Temp.load(mRSql.strings[0],nil);


                                                                                                         mBO_Temp.SetFieldValueAsfloat('X_quantity',mBO_Temp.getFieldValueAsfloat('X_quantity') + mquantity);
                                                                                                     mBO_Temp.save;
                                                                                             end else begin





                                                                                                           mBO_Temp.new;
                                                                                                           mBO_Temp.Prefill;
                                                                                                               mBO_Temp.SetFieldValueAsString('X_CreatedBy_ID', msite.CompanyCache.GetUserID);
                                                                                                               mBO_Temp.SetFieldValueAsfloat('X_ABRADate', trunc(now()));
                                                                                                               mBO_Temp.SetFieldValueAsString('Code', mStoreCard_ID);
                                                                                                               mBO_Temp.SetFieldValueAsString('Name',mImportFile.strings[i]);
                                                                                                                mBO_Temp.SetFieldValueAsString('X_firm_ID',mFirm_ID);
                                                                                                                mBO_Temp.SetFieldValueAsString('X_Store_ID',mCstore_ID);



                                                                                                               if  mBatch_ID<>'' then begin
                                                                                                                    mBO_Temp.SetFieldValueAsString('X_Batches',mbatch_ID);
                                                                                                                    mBO_Temp.SetFieldValueAsString('X_storeCard_ID',mStoreCard_ID);
                                                                                                               end else begin
                                                                                                                   mBO_Temp.SetFieldValueAsString('X_storeCard_ID',mStorecard_ID);
                                                                                                               end;

                                                                                                               if mBO_Temp.getFieldValueAsString('X_Batches.Name')='0' then begin
                                                                                                                    mBO_Temp.SetFieldValueAsString('X_Batches','');
                                                                                                                    mBO_Temp.SetFieldValueAsString('X_storeCard_ID','');
                                                                                                               end;


                                                                                                            mBO_Temp.SetFieldValueAsfloat('X_quantity',mquantity);
                                                                                                            mBO_Temp.save;
                                                                                       //TBusRollSiteForm(msite).DataSet.RefreshCurrentItem;





                                                                                             end;
                                                                                          finally
                                                                                              mRSql.free;
                                                                                          end ;



                                               end;
                              ProgressDispose();
                              end;



                          if index=2 then begin   // ***** import z xml
                          //if true then begin
                               mXMLHead := TNxScriptingXMLWrapper.Create;
                               //NxShowSimpleMessage('OK',nil);
                               try
                                   mXMLHead.loadFromFile(AFileName);
                                       ProgressInit(msite, 'Načtení souboru ' + AFileName, 100);
                                       for iRow := 0 to mXMLHead.getElementsCountInArray('Doc.Row') - 1 do begin
                                              ProgressSetPos(1+NxFloor(iRow/mXMLHead.getElementsCountInArray('Doc.Row')*99), inttostr(iRow) +' z '+inttostr(mXMLHead.getElementsCountInArray('Doc.Row')));
                                            for iBatch := 0 to mXMLHead.getElementsCountInArray('Doc.Row['+inttostr(iRow)+'].batch') - 1 do begin
                                                  mBatch_ID:='';
                                                  mStorecard_ID:='';
                                                  if trim(mXMLHead.getElementAsString('Doc.Row['+inttostr(iRow)+'].batch['+inttostr(iBatch)+'].name'))<>'' then begin
                                                            mRSql:= tstringlist.Create;   // ***** dohledání šarže
                                                            try
                                                               os.SQLSelect('SELECT sb.id||SB.StoreCard_ID from StoreBatches SB WHERE sb.hidden= ' + quotedstr('N') + ' AND sb.name = ' + quotedstr(mXMLHead.getElementAsString('Doc.Row['+inttostr(iRow)+'].batch['+inttostr(iBatch)+'].name')),mRSql);
                                                               if mRSql.count>0 then begin
                                                                    mBatch_ID:=copy(mRSql.Strings[0],1,10);
                                                                    mStorecard_ID:=copy(mRSql.Strings[0],11,10);
                                                               end;
                                                            finally
                                                                mRSql.free;
                                                            end ;
                                                  end;

                                                  if mBatch_ID='' then begin
                                                          if trim(mXMLHead.getElementAsString('Doc.Row['+inttostr(iRow)+'].EAN'))<>'' then begin
                                                                    mRSql:= tstringlist.Create;   // ***** dohledání šarže
                                                                    try
                                                                       os.SQLSelect('SELECT id from Storecards SC WHERE sc.hidden= ' + quotedstr('N') + ' AND sC.EAN = ' + quotedstr(mXMLHead.getElementAsString('Doc.Row['+inttostr(iRow)+'].EAN')),mRSql);
                                                                       if mRSql.count>0 then mStorecard_ID:=mRSql.Strings[0];
                                                                    finally
                                                                        mRSql.free;
                                                                    end ;
                                                          end;
                                                   end;

                                                  mquantity:=NxIBStrToFloat(mXMLHead.getElementAsString('Doc.Row['+inttostr(iRow)+'].batch['+inttostr(iBatch)+'].quantity'));
                                                  if mQuantity>0 then begin
                                                     mBO_Temp.new;
                                                     mBO_Temp.Prefill;
                                                         mBO_Temp.SetFieldValueAsString('X_CreatedBy_ID', msite.CompanyCache.GetUserID);
                                                         mBO_Temp.SetFieldValueAsfloat('X_ABRADate', trunc(now()));
                                                         mBO_Temp.SetFieldValueAsString('Code', copy(mXMLHead.getElementAsString('Doc.Row['+inttostr(iRow)+'].batch['+inttostr(iBatch)+'].EAN'),1,15));
                                                         mBO_Temp.SetFieldValueAsString('Name',mXMLHead.getElementAsString('Doc.Row['+inttostr(iRow)+'].name'));
                                                         mBO_Temp.SetFieldValueAsString('X_firm_ID',mFirm_ID);
                                                         mBO_Temp.SetFieldValueAsString('X_storeCard_ID',mStorecard_ID);
                                                         mBO_Temp.SetFieldValueAsString('X_Batches',mBatch_ID);
                                                         mBO_Temp.SetFieldValueAsfloat('X_quantity',mquantity);
                                                         mBO_Temp.SetFieldValueAsString('X_Store_ID',mCstore_ID);
                                                         mBO_Temp.save;

                                                  end;
                                            end;
                                       end;
                                   finally
                                      ProgressDispose();
                                      mXMLHead.free;
                                      //mImportFile.free ;
                                   end;
                          end;   // konex xml





                          if (index=0) or (index=1) then begin
                          //NxShowSimpleMessage(inttostr(index),nil);
                               try
                                   // mBO_Temp:=msite.BaseObjectSpace.CreateObject('45D1XVW5EY24JBXTOE01EHYRSG');
                                      mImportFile:=TStringList.create;
                                      mImportFile.LoadFromFile(AFileName);
                                        // NxShowSimpleMessage(inttostr(index),nil);
                                         ProgressInit(msite, 'Načtení souboru ' + AFileName, 100);
                                             i := 0;
                                               for i:=0 to mImportFile.Count-1 do begin   // načtení souboru
                                                                 ProgressSetPos(1+NxFloor((i/mImportFile.Count)*99), inttostr(i) +' z '+inttostr(mImportFile.Count));

                                                                 mstringline:= mImportFile.strings[i];
                                                                 mCountField:=0;

                                                                 if index=1 then mCountField :=2;//NxCharCount(',',mstringline);
                                                                 if index=0 then mCountField :=2;//NxCharCount(';',mstringline);

                                                                 mfieldValue:= TStringList.Create;
                                                                 try

                                                                        if index=1 then Parsevalue(mstringline,',',mstringline,mfieldValue,2);
                                                                        if index=0 then Parsevalue(mstringline,';',mstringline,mfieldValue,2);



                                                                               //NxShowSimpleMessage(inttostr(mCountField),nil);
                                                                                        mbatch_ID:='';
                                                                                        mStoreCard_ID:='';

                                                                                   mRSql:= tstringlist.Create;   // ***** dohledání šarže
                                                                                          try
                                                                                             os.SQLSelect('SELECT sb.id from StoreBatches SB WHERE sb.hidden= ' + quotedstr('N') + ' AND sb.name = ' + quotedstr(mfieldValue.Strings[0]),mRSql);
                                                                                             if mRSql.count>0 then begin
                                                                                                  mBatch_ID:=mRSql.Strings[0];
                                                                                                  //NxShowSimpleMessage(mfieldValue.Strings[0] + '      ' + mfieldValue.Strings[1],nil);
                                                                                                  mquantity:=NxIBStrToFloat(mfieldValue.Strings[1])  ;
                                                                                             end;
                                                                                          finally
                                                                                              mRSql.free;
                                                                                          end ;


                                                                               mRSql:= tstringlist.Create;   // ***** dohledání již existujícího záznamu
                                                                                          try
                                                                                             os.SQLSelect('SELECT A.id FROM DefRollData A WHERE (A.Hidden = ''N'' ) AND (A.CLSID = ''45D1XVW5EY24JBXTOE01EHYRSG'' ) AND ((A.X_Firm_ID = '
                                                                                                           + quotedstr(mFirm_ID) + ' OR A.X_Firm_ID IN (SELECT ID FROM Firms WHERE Firm_ID = '
                                                                                                           + quotedstr(mFirm_ID) + '))) AND (A.X_Batches = ' + quotedstr(mBatch_ID) + ') AND a.X_ABRADate=' +inttostr(trunc(now())) ,mRSql);
                                                                                             if mRSql.count>0 then begin
                                                                                                  mBO_Temp.load(mRSql.strings[0],nil);
                                                                                                        mquantity:=NxIBStrToFloat(mfieldValue.Strings[1])  ;

                                                                                                         mBO_Temp.SetFieldValueAsfloat('X_quantity',mBO_Temp.getFieldValueAsfloat('X_quantity') + mquantity);
                                                                                                     mBO_Temp.save;
                                                                                             end else begin



                                                                                             mquantity:=NxIBStrToFloat(mfieldValue.Strings[1])  ;

                                                                                                           mBO_Temp.new;
                                                                                                           mBO_Temp.Prefill;
                                                                                                               mBO_Temp.SetFieldValueAsString('X_CreatedBy_ID', msite.CompanyCache.GetUserID);
                                                                                                               mBO_Temp.SetFieldValueAsfloat('X_ABRADate', trunc(now()));
                                                                                                               mBO_Temp.SetFieldValueAsString('Code', copy(mfieldValue.Strings[1],1,10));
                                                                                                               mBO_Temp.SetFieldValueAsString('Name',mfieldValue.Strings[0]);
                                                                                                                mBO_Temp.SetFieldValueAsString('X_firm_ID',mFirm_ID);
                                                                                                                mBO_Temp.SetFieldValueAsString('X_Store_ID',mCstore_ID);
                                                                                                               if  mBatch_ID<>'' then begin
                                                                                                                    mBO_Temp.SetFieldValueAsString('X_Batches',mBatch_ID);
                                                                                                                    mBO_Temp.SetFieldValueAsString('X_storeCard_ID',mBO_Temp.getFieldValueAsString('X_Batches.Storecard_ID'));
                                                                                                               end else begin
                                                                                                                   mBO_Temp.SetFieldValueAsString('X_storeCard_ID',mStorecard_ID);
                                                                                                               end;



                                                                                                            mBO_Temp.SetFieldValueAsfloat('X_quantity',mquantity);
                                                                                                            mBO_Temp.save;
                                                                                       //TBusRollSiteForm(msite).DataSet.RefreshCurrentItem;





                                                                                             end;
                                                                                          finally
                                                                                              mRSql.free;
                                                                                          end ;

                                                                             {   if mCountField>1 then begin
                                                                                        if mBatch_ID='' then begin
                                                                                                if trim(mfieldValue.Strings[0])<>'' then begin
                                                                                                          mRSql:= tstringlist.Create;   // ***** dohledání šarže
                                                                                                          try
                                                                                                             os.SQLSelect('SELECT id from Storecards SC WHERE sc.hidden= ' + quotedstr('N') + ' AND sC.EAN = ' + quotedstr(mfieldValue.Strings[0]),mRSql);
                                                                                                             if mRSql.count>0 then mStorecard_ID:=mRSql.Strings[0];
                                                                                                          finally
                                                                                                              mRSql.free;
                                                                                                          end ;
                                                                                                end;
                                                                                         end;
                                                                                end else begin

                                                                                end;        }
                                                                                 // NxShowSimpleMessage( mBatch_ID + ' - ' + mStorecard_ID,nil);

                                                                 finally
                                                                        mfieldValue.free;
                                                                 end;

                                               end;
                                               ProgressDispose();

                                     finally
                                       mImportFile.free ;
                                     end;
                               end;


     finally
         mWorkList.free;
     end;
     msite.Refresh;
     TBusRollSiteForm(msite).RefreshData;

end;



//procedure _CanSaveNow_Hook(Self: TDynSiteForm; var ACanSaveNow: Boolean);
//begin
//  if (Self.CompanyCache.GetUserID= '1600000101') or (Self.CompanyCache.GetUserID ='6K00000101') or (Self.CompanyCache.GetUserID ='2K00000101') or (Self.CompanyCache.GetUserID ='3K00000101') or (Self.CompanyCache.GetUserID='SUPER00000') then begin
//      ACanSaveNow:=false;
//  end;
//end;





procedure Import_souboru(Sender: TAction; Index: integer);
var

  zadej:string;
  mfilename,mSavefile:string;
  mdir,mfile,msavedir,msave:string;
  msaveFileName:string;
  msite:TSiteForm;
  mfilter:String;
  mDBGrid : TDBGrid;
 mTabList: TTabSheet;
begin
  mdir:='';
  mfile:='';
  msavedir:='';
  msavefile:='';
 // NxShowSimpleMessage('AAA',nil);
    mSite := NxFindSiteForm(Sender);
        mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
   //NxShowSimpleMessage('bbb',nil);





   if PromptForFileName(mFileName, mfilter, '', 'Soubory k importu', mdir, False) then begin
          mdir:=copy(mfilename,0,NxCharPosR('\',mfilename));
          mFile:=copy(mfilename,1+NxCharPosR('\',mfilename),Length(mfilename));
   end;
 // NxShowSimpleMessage('ccc',nil);
  //ImportFile(TDynSiteForm(mSite).CurrentObject.ObjectSpace, mfilename, mdir,mfile);
 ZpracujImport(msite.baseobjectspace, mfilename, mdir,mfile,msite,true,false,index,msavefile,msavedir,msavefile);


end;




procedure CreateDocumentPrevod(Sender: TAction; Index: integer);
var
 mbo,mRowDocBatchTarget:TNxCustomBusinessObject;
 mSite: TSiteForm;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 x,i:integer;
   mForm: TBusRollSiteForm;
   mtext:string;
   mB_Result:boolean;
   mi:integer;
   mr,mx,mpomoclist:tstringlist;
   mVolne,mNaDokladu,mNaVratce,mquantity:double;
   mbonew:TNxCustomBusinessObject;
   mImportMan: TNxDocumentImportManager;
  mOS: TNxCustomObjectSpace;
  mInputParams: TNxParameters;
  mParam: TNxParameter;
  mCollRows: TNxCustomBusinessMonikerCollection;
  iSource,iTarget: integer;
  mList: TStringList;
  mRow,mBO_Document,mMonbatch: TNxCustomBusinessObject;
  mValidateList:tstringlist;
  mRowsOutput:TNxCustomBusinessMonikerCollection;
  msave,mFind:boolean;
  mMonBatches:TNxCustomBusinessMonikerCollection;
  mSelectedRows:TStrings;
mListError,mWorkList,mBatchList:tstringlist;
  mListNoBatches:tstringlist;
   mstringlist,mxlist:tstringlist;
  mnote:string;
  mSTR:string;
  mCLSID:string;
  mpocetdokladu, mpocetradku,mpocetsarzi:integer;
  mIWorklist,mIšarže:integer;
  mHead:TNxHeaderBusinessObject;
  mRows,mBatches:TNxCustomBusinessMonikerCollection;
  mDocqueue_ID,mStore_ID,mFirm_id,mDivision_ID:string;
  mDocList,mRowList:TStringList;
  mAgenda:string;
  msearch:boolean;
  mString:string;
  mTempWorkList,mTempRowslist:tstringlist;
  mBatchWorklist:tstringlist;
  mOLE, mRoll, mOResult: Variant;
  _ss:Variant;
  mpomoc:string;
begin

  mSite := NxFindSiteForm(Sender);
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');

    // mOLE := GetAbraOLEApplication;
    //                        mroll := mOLE.GetAgenda('OFZO2K155FDL3CL100C4RHECN0');
    //                        _ss := mOLE.CreateStrings;
    //
    //                           mStore_ID := mroll.SingleSelectFromSelected2(_ss, 'Vyber sklad', '');
    mList:=tstringlist.create;
    try
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
    if index=0 then mBO_Document:=msite.BaseObjectSpace.CreateObject('E03ZNUMDTCC4PDAUIEY1MBTJC0');
    if index=1 then mBO_Document:=msite.BaseObjectSpace.CreateObject('0P0I5SAOS3DL3ACU03KIU0CLP4');
    ProgressInit(msite, 'Načtení řádků ' + '', 100);
    mtext:='';
    if mBookmark.count=0 then begin
           mtext:='';
           // firma
           if NxIsEmptyOID(TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsstring('X_Firm_ID')) then mtext:=mtext + '0000000000'
           else mtext:=mtext + TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsstring('X_Firm_ID');
           // sklad
           if NxIsBlank(TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsString('X_Store_ID')) then mtext:=mtext + '0000000000'
           else mtext:=mtext + TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsString('X_Store_ID');
           // skladová karta
           if NxIsEmptyOID(TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsString('X_Storecard_ID')) then mtext:=mtext + '0000000000'
           else mtext:=mtext + TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsString('X_Storecard_ID');
           // šarže
           if NxIsEmptyOID(TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsString('X_Batches')) then mtext:=mtext + '0000000000'
           else mtext:=mtext + TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsString('X_Batches');
           mtext:=mtext + NxFloatToIBStr(TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsFloat('X_Quantity'));

           mList.add(mtext);
    end else begin
        for x := 0 to mBookmark.Count- 1 do begin
                  mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(x));
                  ProgressSetPos(1+NxFloor(x/mBookmark.Count*99), inttostr(x) +' z '+inttostr(mBookmark.Count));
               mtext:='';
                  // firma
                   if NxIsEmptyOID(TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsstring('X_Firm_ID')) then mtext:=mtext + '0000000000'
                   else mtext:=mtext + TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsstring('X_Firm_ID');
                   // sklad
                   if NxIsBlank(TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsString('X_Store_ID')) then mtext:=mtext + '0000000000'
                   else mtext:=mtext + TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsString('X_Store_ID');
                   // skladová karta
                   if NxIsEmptyOID(TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsString('X_Storecard_ID')) then mtext:=mtext + '0000000000'
                   else mtext:=mtext + TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsString('X_Storecard_ID');
                   // šarže
                   if NxIsEmptyOID(TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsString('X_Batches')) then mtext:=mtext + '0000000000'
                   else mtext:=mtext + TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsString('X_Batches');
                   mtext:=mtext + NxFloatToIBStr(TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsFloat('X_Quantity'));

                   mList.add(mtext);
        end;
    end;
   ProgressDispose()   ;
  mList.sort;
  {

      for i:=0 to mlist.count-1 do begin
         mpomoc:=mpomoc + chr(10) + mList.Strings[i] ;
      end ;

  NxShowSimpleMessage(inttostr(mlist.count) + chr(10) + mpomoc,nil);}
  if mlist.Count>0 then begin

      for i:=0 to mlist.count-1 do begin
          if i=0 then begin
              // novy doklad
                      mBO_Document.new;
                      mBO_Document.prefill;
                      if index=0 then mBO_Document.SetFieldValueAsString('DocQueue_ID', '1910000101' ); // musi byt...          '2781000101'
                      if index=1 then begin
                            mBO_Document.SetFieldValueAsString('DocQueue_ID', mDocqueue_ID_PRVY ); // musi byt...          '2781000101'
                            mBO_Document.SetFieldValueAsString('IncomingTransferStore', mCstore_ID);
                      end;
                      mBO_Document.SetFieldValueAsString('Firm_ID', copy(mList.Strings[i],1,10));
                      //mBO_Document.SetFieldValueAsDateTime('Docdate$date', TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsDateTime('X_ABRADate'));

                      mRowsOutput := mBO_Document.GetLoadedCollectionMonikerForFieldCode(mBO_Document.GetFieldCode('Rows'));
          end else begin
               //NxShowSimpleMessage(copy(mList.Strings[i],1,10) + '  /  '  +copy(mList.Strings[i-1],1,10),nil);
              if copy(mList.Strings[i],1,10)<>copy(mList.Strings[i-1],1,10) then begin // jiný doklad
                    //uložení dokladu
                    mBO_Document.ClearValidateErrors;
                                      if true then begin //Not mBO_Document.Validate() then begin
                                            mValidateList := TStringList.Create;
                                            try
                                               mBO_Document.GetValidateErrors(mValidateList);
                                               mText := mValidateList.Text;
                                               NxToken(mText, '=');
                                               //MessageDlg('Automaticky vytvořeny doklad nelze uložit z těchto důvodů:' + #13#10 + mText,

                                               //mtWarning, [mbOK], 0);
                                             finally
                                               mValidateList.Free;
                                             end;
                                             if index=0 then TDynSiteForm.ShowDynFormWithNewDocument('B10I5SAOS3DL3ACU03KIU0CLP4', TBusRollSiteForm(msite).SiteContext, mBO_Document);
                                             if index=1 then TDynSiteForm.ShowDynFormWithNewDocument('BD0I5SAOS3DL3ACU03KIU0CLP4', TBusRollSiteForm(msite).SiteContext, mBO_Document);

                                      end else begin
                                           mBO_Document.Save;
                                      end;
                    //NxShowSimpleMessage('uložení průběžné',nil);
                    // novy doklad

                      mBO_Document.new;
                      mBO_Document.prefill;
                      mBO_Document.SetFieldValueAsString('DocQueue_ID', mDocqueue_ID_PRVY ); // musi byt...          '2781000101'
                      mBO_Document.SetFieldValueAsString('Firm_ID', copy(mList.Strings[i],1,10));
                      //mBO_Document.SetFieldValueAsDateTime('Docdate$date', TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsDateTime('X_ABRADate'));
                      if index=1 then mBO_Document.SetFieldValueAsString('IncomingTransferStore', mCstore_ID);
                      mRowsOutput := mBO_Document.GetLoadedCollectionMonikerForFieldCode(mBO_Document.GetFieldCode('Rows'));
              end;
          end;

              if i=0 then begin
                   mRow:=mRowsOutput.AddNewObject;
                        mRow.Prefill;
                        mRow.SetFieldValueAsInteger('RowType',3)  ;
                        mRow.SetFieldValueAsstring('Store_ID',copy(mList.Strings[i],11,10));
                        mRow.SetFieldValueAsString('Storecard_ID',copy(mList.Strings[i],21,10))  ;
                        mRow.SetFieldValueAsString('Division_ID',mCDivision_ID)  ;
                        mRow.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(mList.Strings[i],41,10)))  ;
                        if mRow.GetFieldValueAsinteger('StoreCard_ID.category')=2 then begin
                               mMonBatches :=  mRow.GetLoadedCollectionMonikerForFieldCode(mRow.GetFieldCode('DocRowBatches'));
                        end;
              end else begin
                  if copy(mList.Strings[i-1],1,30)<>copy(mList.Strings[i],1,30) then begin // jiný řádek
                        // novy řádek
                        mRow:=mRowsOutput.AddNewObject;
                        mRow.Prefill;
                        mRow.SetFieldValueAsInteger('RowType',3)  ;
                        mRow.SetFieldValueAsstring('Store_ID',copy(mList.Strings[i],11,10));
                        mRow.SetFieldValueAsString('Storecard_ID',copy(mList.Strings[i],21,10))  ;
                        mRow.SetFieldValueAsString('Division_ID',mCDivision_ID)  ;
                        mRow.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(mList.Strings[i],41,10)))  ;
                        if mRow.GetFieldValueAsinteger('StoreCard_ID.category')=2 then begin
                               mMonBatches :=  mRow.GetLoadedCollectionMonikerForFieldCode(mRow.GetFieldCode('DocRowBatches'));
                        end;
                  end else begin
                    // oprava řádku
                       mRow.SetFieldValueAsFloat('Quantity', mRow.getFieldValueAsFloat('Quantity') + NxIBStrToFloat(copy(mList.Strings[i],41,10)))  ;
                  end;
              end;


              if i=0 then begin
                               mMonbatch:=mMonBatches.AddNewObject;
                               mMonbatch.Prefill;
                               mMonbatch.setFieldValueAsString('StoreBatch_ID',copy(mList.Strings[i],31,10))  ;
                               mMonbatch.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(mList.Strings[i],41,10)))  ;
              end else begin
                  if copy(mList.Strings[i-1],1,40)<>copy(mList.Strings[i],1,40) then begin // jiný řádek
                        // nová šarže
                        mMonbatch:=mMonBatches.AddNewObject;
                               mMonbatch.Prefill;
                               mMonbatch.setFieldValueAsString('StoreBatch_ID',copy(mList.Strings[i],31,10))  ;
                               mMonbatch.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(mList.Strings[i],41,10)))  ;
                  end else begin
                        // oprava šarže
                        mMonbatch.SetFieldValueAsFloat('Quantity', mMonbatch.getFieldValueAsFloat('Quantity') + NxIBStrToFloat(copy(mList.Strings[i],41,10)))  ;
                  end;
              end;



      end;
                          //uložení dokladu
                    mBO_Document.ClearValidateErrors;
                                      if true then begin //Not mBO_Document.Validate() then begin
                                            mValidateList := TStringList.Create;
                                            try
                                               mBO_Document.GetValidateErrors(mValidateList);
                                               mText := mValidateList.Text;
                                               NxToken(mText, '=');
                                               //MessageDlg('Automaticky vytvořeny doklad nelze uložit z těchto důvodů:' + #13#10 + mText,

                                               //mtWarning, [mbOK], 0);
                                             finally
                                               mValidateList.Free;
                                             end;
                                              if index=0 then TDynSiteForm.ShowDynFormWithNewDocument('B10I5SAOS3DL3ACU03KIU0CLP4', TBusRollSiteForm(msite).SiteContext, mBO_Document);
                                             if index=1 then TDynSiteForm.ShowDynFormWithNewDocument('BD0I5SAOS3DL3ACU03KIU0CLP4', TBusRollSiteForm(msite).SiteContext, mBO_Document);


                                      end else begin
                                           mBO_Document.Save;
                                      end;

                //NxShowSimpleMessage('uložení poslední',nil);
                //mBO_Document.Save;
    end;


   finally
          mlist.free;
       //   mBO_Document.free;
   end;


end;











procedure InitSite_Hook(Self: TSiteForm);

var
mAction: TAction;
  mMAction: TMultiAction;
begin
//if (NxGetActualUserID(self.BaseObjectSpace)='SUPER00000') or (NxGetActualUserID(self.BaseObjectSpace)='1Z10000101') then begin
  mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := 'Import ze souboru';
  mmAction.Hint := 'Import ze souboru "Batch,Quantity"';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('CSV - oddělovač ";"');
  mMAction.Items.Add('CSV - oddělovač ","');
  mMAction.Items.Add('XML');
  mMAction.Items.Add('CSV - datamatrix');
  mmAction.OnExecuteItem:= @Import_souboru;




    mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := 'Dohledání dokladu';
  mmAction.Hint := 'Dohledání dokladu ';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('Dohledání dokladu pomocí šarže');
  mMAction.Items.Add('   ');  //mMAction.Items.Add('Dohledání dokladu pomocí SC');
  mMAction.Items.Add('   '); //mMAction.Items.Add('Dohledání příjemky pomocí šarže');
  mMAction.Items.Add('');
  mMAction.Items.Add('');
  mMAction.Items.Add('Vyčisti data');
  mmAction.OnExecuteItem:= @testnew;



 // mmAction := Self.GetNewMultiAction;
 // mmAction.ShowControl := True;
 // mmAction.ShowMenuItem := True;
 // mmAction.Caption := 'Ruční dohledání dokladu';
 // mmAction.Hint := 'Ruční dohledání dokladu';
 // mmAction.Category := 'tabList';
 // mMAction.Items.Add('Pohyb šarže');
 // mMAction.Items.Add('Pohyb skladové karty');

//  mmAction.OnExecuteItem:= @rucne;

      mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := 'Vytvoření vratek pomocí šarže';
  mmAction.Hint := 'Vytvoření vratek pomocí šarže';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('Vratky DL');
  mMAction.Items.Add('');
   mMAction.Items.Add('Vratky PR');
  mMAction.Items.Add('');
  mMAction.Items.Add('');
  mMAction.Items.Add('Vymaž data');
  mmAction.OnExecuteItem:= @CreateDocumentImport;

         mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := 'Převodka výdej';
  mmAction.Hint := 'Převodka  výdej';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('Příjemka');
  mMAction.Items.Add('Převodka');
    mmAction.OnExecuteItem:= @CreateDocumentPrevod;




  mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := 'Vstup ze čtečky';
  mmAction.Hint := 'Vstup ze čtečky';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('Datamatrix');
  mmAction.OnExecuteItem:= @Import_ctecka;





//end ;



  mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := 'Dobropis kumulovany';
  mmAction.Hint := 'Dobropis kumulovany';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('Dobropis kumulovany');
  mmAction.OnExecuteItem:= @DobropisAllInOne;



  mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := 'Opravný daňový doklad';
  mmAction.Hint := 'Vytvoření podkladů pro dobropisy';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('Příprava dobropisů');
  mmAction.OnExecuteItem:= @Dobropis;

   mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Dohledání pohybu';
  mMAction.Hint := 'Dohledání pohybu';
  mMAction.Category := 'tablist,tabdetail';
  mMAction.OnExecuteItem := @ShowDocExecuteItem;

  mMAction.Items.Add('Prodejní pohyb šarže');
  mMAction.Items.Add('Vratka - pohyb šarže');





   mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := 'Dohledání SC a batch';
  mmAction.Hint := 'Dohledání batch ';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('Dohledání  pomocí šarže');
  mMAction.Items.Add('Dohledání  pomocí sc');
  mMAction.Items.Add('Dohledání  pomocí datamatrix');
  mMAction.Items.Add('odtraní počáteční 01 na začátku');

  mmAction.OnExecuteItem:= @findsc;






    mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Dohledání pohybu bez firmy';
  mMAction.Hint := 'Dohledání pohybu bez firmy';
  mMAction.Category := 'tablist,tabdetail';
  mMAction.Items.Add('Prodejní pohyb šarže');
  mMAction.Items.Add('Vratka - pohyb šarže');
  mMAction.Items.Add('Příjemka - pohyb šarže');

  mMAction.OnExecuteItem := @ShowDocExecuteItemNoneFirm;


mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Zobraz FV';
  mMAction.Hint := 'Zobraz FV';
  mMAction.Category := 'tablist,tabdetail';
  mMAction.Items.Add('Zobraz FV');

  mMAction.OnExecuteItem := @ShowFV;





end;




procedure ShowDocExecuteItemNoneFirm(Sender: TAction; Index: integer);
var
 mbo:TNxCustomBusinessObject;
 L ,mx: TStringList;
 mid:string;
 mPars:TNxParameters;
 mPar:TNxParameter;
 msite:TBusRollSiteForm;
 mr2:TStringList;
 mMon : TNxCustomBusinessMonikerCollection;
 mStrings:string;
 i:integer;
   mOLE, mRoll,mAgenda, mOResult: Variant;
  mids1:tstringlist;
  mids: TStringList;
  mB:boolean;
  mSelected ,_ss:Variant;
 mstring:string;
 mBoolean:boolean;
 mBOPohyb:TNxCustomBusinessObject;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 x:integer;
begin
 msite:=TComponent(sender).BusRollSite;
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu

    //mB_Result:=InputQuery('Zadaj parametry', 'Změna ', mtext);

    //ProgressInit(msite, 'Hledání souborů ' + '', 100);
    if mBookmark.count<>0 then for x := 0 to mBookmark.Count- 1 do begin
    if mBookmark.count<>0 then  mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(x));

    mbo:= TBusRollSiteForm(mSite).CurrentObject;                      //ProgressSetPos(1+NxFloor(x/mBookmark.Count*99), inttostr(x) +' z '+inttostr(mBookmark.Count));





  mOLE := GetAbraOLEApplication;
                                                            mroll := mOLE.GetAgenda('S1X0KZC0NJE13C5U00CA141B44');
                                                            mSelected := mOLE.CreateStrings;



                                                            mr2:=TStringList.create;
                                                                  try
                                                                     if index=0 then begin
                                                                        mbo.ObjectSpace.SQLSelect('SELECT a.id FROM DocRowBatches A JOIN StoreDocuments2 SD2 ON SD2.ID=A.Parent_ID JOIN StoreDocuments SD ON SD.ID=SD2.Parent_ID  '
                                                                            + ' WHERE (SD.DocQueue_ID IN (SELECT ID FROM  DocQueues WHERE DocumentType IN (''21'',''23'')) )  AND '
                                                                              + '(A.StoreBatch_ID = ' + QuotedStr(mbo.GetFieldValueAsString('X_Batches')) + ' )',mr2);
                                                                      end;
                                                                      if index=1 then begin
                                                                        mbo.ObjectSpace.SQLSelect('SELECT a.id FROM DocRowBatches A JOIN StoreDocuments2 SD2 ON SD2.ID=A.Parent_ID JOIN StoreDocuments SD ON SD.ID=SD2.Parent_ID  '
                                                                            + ' WHERE (SD.DocQueue_ID IN (SELECT ID FROM  DocQueues WHERE DocumentType IN (''23'')) ) AND ((F.ID='
                                                                             + QuotedStr(mbo.GetFieldValueAsString('X_firm_ID')) + ') OR ((F.Firm_ID IS NOT NULL) AND '
//                                                                              (sd.docdate$date=' + NxFloatToIBStr(mbo.GetFieldValueAsDateTime('X_ABRADate')) + ') AND'
                                                                              + '(A.StoreBatch_ID = ' + QuotedStr(mbo.GetFieldValueAsString('X_Batches')) + ' )',mr2);
                                                                      end;
                                                                      if index=2 then begin
                                                                        mbo.ObjectSpace.SQLSelect('SELECT a.id FROM DocRowBatches A JOIN StoreDocuments2 SD2 ON SD2.ID=A.Parent_ID JOIN StoreDocuments SD ON SD.ID=SD2.Parent_ID   '
                                                                            + ' WHERE (SD.DocQueue_ID IN (SELECT ID FROM  DocQueues WHERE DocumentType IN (''20'',''30'')) ) AND  '
                                                                              + '(A.StoreBatch_ID = ' + QuotedStr(mbo.GetFieldValueAsString('X_Batches')) + ' )',mr2);
                                                                      end;



                                                                        // NxShowSimpleMessage(inttostr(mr2.count),nil);
                                                                         if mr2.count=0 then begin
                                                                             NxShowSimpleMessage('Pro šarži nebyl dohledán pohyb ', nil);

//                                                                             exit;
                                                                         end;
                                                                         for i := 0 to mr2.Count - 1 do begin
                                                                             mSelected.Add(mr2.Strings[i]);
                                                                         end;
                                                                  if mr2.Count>0 then begin
                                                                     if mr2.Count=1 then begin
                                                                         mstring:=mr2.Strings[0]; //NxShowSimpleMessage('Zobrazení pohybů',nil);
                                                                      end else begin
                                                                          mstring:= mroll.SingleSelectFromSelected2(mSelected, 'Pohyb šarže: +' + mbo.GetFieldValueAsString('X_batches.name')  + ' v množství ' + NxFloatToIBStr(mbo.GetFieldValueAsFloat('X_quantity')), '');
                                                                      end;
                                                                  end;


                                                                  finally
                                                                      mr2.free;
                                                                  end;



                                                           if mstring<>'' then begin
                                                               mBOPohyb:=mbo.ObjectSpace.CreateObject('K3TH0HR5TZDL342W01C0CX3FCC');
                                                               try
                                                                     mBOPohyb.Load(mstring,nil);
                                                                       if index=0 then begin
                                                                             mr2:=TStringList.create;
                                                                             try
                                                                                 mbo.ObjectSpace.SQLSelect('Select ii2.parent_id from IssuedInvoices2 ii2 where ii2.ProvideRow_ID=' + quotedstr(mBOPohyb.GetFieldValueAsstring('Parent_ID')) ,mr2);
                                                                                 if mr2.count>0 then begin
                                                                                       TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_parent_ID',mr2.Strings[0]);
                                                                                 end;
                                                                             finally
                                                                                 mr2.free;
                                                                             end;

                                                                             mr2:=TStringList.create;
                                                                             try
                                                                                 mbo.ObjectSpace.SQLSelect('Select ii2.id from IssuedInvoices2 ii2 where ii2.ProvideRow_ID=' + quotedstr(mBOPohyb.GetFieldValueAsstring('Parent_ID')) ,mr2);
                                                                                 if mr2.count>0 then begin
                                                                                      TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_parent2_id',mr2.Strings[0]);
                                                                                 end;
                                                                             finally
                                                                                 mr2.free;
                                                                             end;
                                                                                 TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_Firm_ID',mBOPohyb.GetFieldValueAsString('Parent_ID.Parent_ID.Firm_ID'));
                                                                                 TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_DEVENOLUX',mBOPohyb.GetFieldValueAsString('Parent_ID.Parent_ID'));
                                                                                 TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_MX_NAZEV',mBOPohyb.GetFieldValueAsstring('Parent_ID'));
                                                                                 TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_DE_NAZEV',mBOPohyb.oid);
                                                                                 TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_vychystano',mBOPohyb.GetFieldValueAsFloat('Quantity'));
                                                                                 TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_PM_State','1050000101');
                                                                                 TBusRollSiteForm(mSite).CurrentObject.save;
                                                                       end;
                                                                       if index=1 then begin
                                                                             TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_Firm_ID',mBOPohyb.GetFieldValueAsString('Parent_ID.parent_id.Firm_ID'));
                                                                             TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_EN_NAZEV',mBOPohyb.oid);
                                                                             TBusRollSiteForm(mSite).CurrentObject.save;
                                                                       end;
                                                                       if index=2 then begin
                                                                             TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_Firm_ID',mBOPohyb.GetFieldValueAsString('Parent_ID.Parent_ID.Firm_ID'));
                                                                             TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_EN_NAZEV',mBOPohyb.oid);
                                                                             TBusRollSiteForm(mSite).CurrentObject.save;
                                                                       end;
                                                               finally
                                                                   mBOPohyb.free;
                                                               end;
                                                         end;



    if mBookmark.count<>0 then end;













     if mBookmark.count=0 then  begin

    mbo:= TBusRollSiteForm(mSite).CurrentObject;                      //ProgressSetPos(1+NxFloor(x/mBookmark.Count*99), inttostr(x) +' z '+inttostr(mBookmark.Count));





  mOLE := GetAbraOLEApplication;
                                                            mroll := mOLE.GetAgenda('S1X0KZC0NJE13C5U00CA141B44');
                                                            mSelected := mOLE.CreateStrings;



                                                            mr2:=TStringList.create;
                                                                  try
                                                                     if index=0 then begin
                                                                        mbo.ObjectSpace.SQLSelect('SELECT a.id FROM DocRowBatches A JOIN StoreDocuments2 SD2 ON SD2.ID=A.Parent_ID JOIN StoreDocuments SD ON SD.ID=SD2.Parent_ID  '
                                                                            + ' WHERE (SD.DocQueue_ID IN (SELECT ID FROM  DocQueues WHERE DocumentType IN (''21'',''23'')) ) AND  '
                                                                              + '(A.StoreBatch_ID = ' + QuotedStr(mbo.GetFieldValueAsString('X_Batches')) + ' )',mr2);
                                                                      end;
                                                                      if index=1 then begin
                                                                        mbo.ObjectSpace.SQLSelect('SELECT a.id FROM DocRowBatches A JOIN StoreDocuments2 SD2 ON SD2.ID=A.Parent_ID JOIN StoreDocuments SD ON SD.ID=SD2.Parent_ID  '
                                                                            + ' WHERE (SD.DocQueue_ID IN (SELECT ID FROM  DocQueues WHERE DocumentType IN (''23'')) ) AND '
//                                                                              (sd.docdate$date=' + NxFloatToIBStr(mbo.GetFieldValueAsDateTime('X_ABRADate')) + ') AND'
                                                                              + '(A.StoreBatch_ID = ' + QuotedStr(mbo.GetFieldValueAsString('X_Batches')) + ' )',mr2);
                                                                      end;
                                                                      if index=2 then begin
                                                                        mbo.ObjectSpace.SQLSelect('SELECT a.id FROM DocRowBatches A JOIN StoreDocuments2 SD2 ON SD2.ID=A.Parent_ID JOIN StoreDocuments SD ON SD.ID=SD2.Parent_ID  '
                                                                            + ' WHERE (SD.DocQueue_ID IN (SELECT ID FROM  DocQueues WHERE DocumentType IN (''20'',''30'')) ) AND  '
                                                                              + '(A.StoreBatch_ID = ' + QuotedStr(mbo.GetFieldValueAsString('X_Batches')) + ' )',mr2);
                                                                      end;


                                                                       // NxShowSimpleMessage(inttostr(mr2.count),nil);
                                                                         if mr2.count=0 then begin
                                                                             //NxShowSimpleMessage('Pro šarži nebyl dohledán pohyb ', nil);

//                                                                             exit;
                                                                         end;
                                                                         for i := 0 to mr2.Count - 1 do begin
                                                                             mSelected.Add(mr2.Strings[i]);
                                                                         end;
                                                                  if mr2.Count>0 then begin
                                                                      if mr2.Count=1 then begin
                                                                         mstring:=mr2.Strings[0]; //NxShowSimpleMessage('Zobrazení pohybů',nil);
                                                                      end else begin
                                                                          mstring:= mroll.SingleSelectFromSelected2(mSelected, 'Pohyb šarže: +' + mbo.GetFieldValueAsString('X_batches.name')  + ' v množství ' + NxFloatToIBStr(mbo.GetFieldValueAsFloat('X_quantity')), '');
                                                                      end;
                                                                  end;


                                                                  finally
                                                                      mr2.free;
                                                                  end;
                                                               //mstring:='';


                                                           if mstring<>'' then begin
                                                               mBOPohyb:=mbo.ObjectSpace.CreateObject('K3TH0HR5TZDL342W01C0CX3FCC');
                                                               try
                                                                     mBOPohyb.Load(mstring,nil);
                                                                       if index=0 then begin
                                                                             mr2:=TStringList.create;
                                                                             try
                                                                                 mbo.ObjectSpace.SQLSelect('Select ii2.parent_id from IssuedInvoices2 ii2 where ii2.ProvideRow_ID=' + quotedstr(mBOPohyb.GetFieldValueAsstring('Parent_ID')) ,mr2);
                                                                                 if mr2.count>0 then begin
                                                                                       TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_parent_ID',mr2.Strings[0]);
                                                                                 end;
                                                                             finally
                                                                                 mr2.free;
                                                                             end;

                                                                             mr2:=TStringList.create;
                                                                             try
                                                                                 mbo.ObjectSpace.SQLSelect('Select ii2.id from IssuedInvoices2 ii2 where ii2.ProvideRow_ID=' + quotedstr(mBOPohyb.GetFieldValueAsstring('Parent_ID')) ,mr2);
                                                                                 if mr2.count>0 then begin
                                                                                      TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_parent2_id',mr2.Strings[0]);
                                                                                 end;
                                                                             finally
                                                                                 mr2.free;
                                                                             end;
                                                                                 TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_Firm_ID',mBOPohyb.GetFieldValueAsString('Parent_ID.Parent_ID.Firm_ID'));
                                                                                 TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_DEVENOLUX',mBOPohyb.GetFieldValueAsString('Parent_ID.Parent_ID'));
                                                                                 TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_MX_NAZEV',mBOPohyb.GetFieldValueAsstring('Parent_ID'));
                                                                                 TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_DE_NAZEV',mBOPohyb.oid);
                                                                                 TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_vychystano',mBOPohyb.GetFieldValueAsFloat('Quantity'));
                                                                                 TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_PM_State','1050000101');
                                                                                 TBusRollSiteForm(mSite).CurrentObject.save;
                                                                       end;
                                                                       if index=1 then begin
                                                                             TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_Firm_ID',mBOPohyb.GetFieldValueAsString('Parent_ID.Parent_id.Firm_ID'));
                                                                             TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_EN_NAZEV',mBOPohyb.oid);
                                                                             TBusRollSiteForm(mSite).CurrentObject.save;
                                                                       end;
                                                                        if index=2 then begin
                                                                             TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_Firm_ID',mBOPohyb.GetFieldValueAsString('Parent_ID.Parent_ID.Firm_ID'));
                                                                             TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_EN_NAZEV',mBOPohyb.oid);
                                                                             TBusRollSiteForm(mSite).CurrentObject.save;
                                                                       end;
                                                               finally
                                                                   mBOPohyb.free;
                                                               end;
                                                         end;



    end;







end;



 procedure ShowDocExecuteItem(Sender: TAction; Index: integer);
var
 mbo:TNxCustomBusinessObject;
 L ,mx: TStringList;
 mid:string;
 mPars:TNxParameters;
 mPar:TNxParameter;
 msite:TBusRollSiteForm;
 mr2:TStringList;
 mMon : TNxCustomBusinessMonikerCollection;
 mStrings:string;
 i:integer;
   mOLE, mRoll,mAgenda, mOResult: Variant;
  mids1:tstringlist;
  mids: TStringList;
  mB:boolean;
  mSelected ,_ss:Variant;
 mstring:string;
 mBoolean:boolean;
 mBOPohyb:TNxCustomBusinessObject;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 x:integer;
begin
 msite:=TComponent(sender).BusRollSite;
    mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu

    //mB_Result:=InputQuery('Zadaj parametry', 'Změna ', mtext);

    //ProgressInit(msite, 'Hledání souborů ' + '', 100);
    if mBookmark.count<>0 then for x := 0 to mBookmark.Count- 1 do begin
    if mBookmark.count<>0 then  mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(x));

    mbo:= TBusRollSiteForm(mSite).CurrentObject;                      //ProgressSetPos(1+NxFloor(x/mBookmark.Count*99), inttostr(x) +' z '+inttostr(mBookmark.Count));





  mOLE := GetAbraOLEApplication;
                                                            mroll := mOLE.GetAgenda('S1X0KZC0NJE13C5U00CA141B44');
                                                            mSelected := mOLE.CreateStrings;



                                                            mr2:=TStringList.create;
                                                                  try
                                                                     if index=0 then begin
                                                                        mbo.ObjectSpace.SQLSelect('SELECT a.id FROM DocRowBatches A JOIN StoreDocuments2 SD2 ON SD2.ID=A.Parent_ID JOIN StoreDocuments SD ON SD.ID=SD2.Parent_ID JOIN Firms F ON F.ID=SD.Firm_ID '
                                                                            + ' WHERE (SD.DocQueue_ID IN (SELECT ID FROM  DocQueues WHERE DocumentType IN (''21'',''23'')) ) AND ((F.ID='
                                                                             + QuotedStr(mbo.GetFieldValueAsString('X_firm_ID')) + ') OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='
                                                                              + QuotedStr(mbo.GetFieldValueAsString('X_firm_ID')) + '))) AND  '
                                                                              + '(A.StoreBatch_ID = ' + QuotedStr(mbo.GetFieldValueAsString('X_Batches')) + ' )',mr2);
                                                                      end;
                                                                      if index=1 then begin
                                                                        mbo.ObjectSpace.SQLSelect('SELECT a.id FROM DocRowBatches A JOIN StoreDocuments2 SD2 ON SD2.ID=A.Parent_ID JOIN StoreDocuments SD ON SD.ID=SD2.Parent_ID JOIN Firms F ON F.ID=SD.Firm_ID '
                                                                            + ' WHERE (SD.DocQueue_ID IN (SELECT ID FROM  DocQueues WHERE DocumentType IN (''23'')) ) AND ((F.ID='
                                                                             + QuotedStr(mbo.GetFieldValueAsString('X_firm_ID')) + ') OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='
                                                                              + QuotedStr(mbo.GetFieldValueAsString('X_firm_ID')) + '))) AND '
//                                                                              (sd.docdate$date=' + NxFloatToIBStr(mbo.GetFieldValueAsDateTime('X_ABRADate')) + ') AND'
                                                                              + '(A.StoreBatch_ID = ' + QuotedStr(mbo.GetFieldValueAsString('X_Batches')) + ' )',mr2);
                                                                      end;
                                                                         if mr2.count=0 then begin
                                                                             //NxShowSimpleMessage('Pro šarži nebyl dohledán pohyb ', nil);

//                                                                             exit;
                                                                         end;
                                                                         for i := 0 to mr2.Count - 1 do begin
                                                                             mSelected.Add(mr2.Strings[i]);
                                                                         end;
                                                                  finally
                                                                      mr2.free;
                                                                  end;
                                                               mstring:='';
                                                               if mr2.Count>0 then begin
                                                                    mstring:= mroll.SingleSelectFromSelected2(mSelected, 'Pohyb šarže: +' + mbo.GetFieldValueAsString('X_batches.name')  + ' v množství ' + NxFloatToIBStr(mbo.GetFieldValueAsFloat('X_quantity')), '');
                                                               end;

                                                           if mstring<>'' then begin
                                                               mBOPohyb:=mbo.ObjectSpace.CreateObject('K3TH0HR5TZDL342W01C0CX3FCC');
                                                               try
                                                                     mBOPohyb.Load(mstring,nil);
                                                                       if index=0 then begin
                                                                             mr2:=TStringList.create;
                                                                             try
                                                                                 mbo.ObjectSpace.SQLSelect('Select ii2.parent_id from IssuedInvoices2 ii2 where ii2.ProvideRow_ID=' + quotedstr(mBOPohyb.GetFieldValueAsstring('Parent_ID')) ,mr2);
                                                                                 if mr2.count>0 then begin
                                                                                       TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_parent_ID',mr2.Strings[0]);
                                                                                 end;
                                                                             finally
                                                                                 mr2.free;
                                                                             end;

                                                                             mr2:=TStringList.create;
                                                                             try
                                                                                 mbo.ObjectSpace.SQLSelect('Select ii2.id from IssuedInvoices2 ii2 where ii2.ProvideRow_ID=' + quotedstr(mBOPohyb.GetFieldValueAsstring('Parent_ID')) ,mr2);
                                                                                 if mr2.count>0 then begin
                                                                                      TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_parent2_id',mr2.Strings[0]);
                                                                                 end;
                                                                             finally
                                                                                 mr2.free;
                                                                             end;

                                                                                 TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_DEVENOLUX',mBOPohyb.GetFieldValueAsString('Parent_ID.Parent_ID'));
                                                                                 TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_MX_NAZEV',mBOPohyb.GetFieldValueAsstring('Parent_ID'));
                                                                                 TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_DE_NAZEV',mBOPohyb.oid);
                                                                                 TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_vychystano',mBOPohyb.GetFieldValueAsFloat('Quantity'));
                                                                                 TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_PM_State','1050000101');
                                                                                 TBusRollSiteForm(mSite).CurrentObject.save;
                                                                       end;
                                                                       if index=1 then begin
                                                                             TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_EN_NAZEV',mBOPohyb.oid);
                                                                             TBusRollSiteForm(mSite).CurrentObject.save;
                                                                       end;
                                                               finally
                                                                   mBOPohyb.free;
                                                               end;
                                                         end;



    if mBookmark.count<>0 then end;













     if mBookmark.count=0 then  begin

    mbo:= TBusRollSiteForm(mSite).CurrentObject;                      //ProgressSetPos(1+NxFloor(x/mBookmark.Count*99), inttostr(x) +' z '+inttostr(mBookmark.Count));





  mOLE := GetAbraOLEApplication;
                                                            mroll := mOLE.GetAgenda('S1X0KZC0NJE13C5U00CA141B44');
                                                            mSelected := mOLE.CreateStrings;



                                                            mr2:=TStringList.create;
                                                                  try
                                                                     if index=0 then begin
                                                                        mbo.ObjectSpace.SQLSelect('SELECT a.id FROM DocRowBatches A JOIN StoreDocuments2 SD2 ON SD2.ID=A.Parent_ID JOIN StoreDocuments SD ON SD.ID=SD2.Parent_ID JOIN Firms F ON F.ID=SD.Firm_ID '
                                                                            + ' WHERE (SD.DocQueue_ID IN (SELECT ID FROM  DocQueues WHERE DocumentType IN (''21'',''23'')) ) AND ((F.ID='
                                                                             + QuotedStr(mbo.GetFieldValueAsString('X_firm_ID')) + ') OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='
                                                                              + QuotedStr(mbo.GetFieldValueAsString('X_firm_ID')) + '))) AND  '
                                                                              + '(A.StoreBatch_ID = ' + QuotedStr(mbo.GetFieldValueAsString('X_Batches')) + ' )',mr2);
                                                                      end;
                                                                      if index=1 then begin
                                                                        mbo.ObjectSpace.SQLSelect('SELECT a.id FROM DocRowBatches A JOIN StoreDocuments2 SD2 ON SD2.ID=A.Parent_ID JOIN StoreDocuments SD ON SD.ID=SD2.Parent_ID JOIN Firms F ON F.ID=SD.Firm_ID '
                                                                            + ' WHERE (SD.DocQueue_ID IN (SELECT ID FROM  DocQueues WHERE DocumentType IN (''23'')) ) AND ((F.ID='
                                                                             + QuotedStr(mbo.GetFieldValueAsString('X_firm_ID')) + ') OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='
                                                                              + QuotedStr(mbo.GetFieldValueAsString('X_firm_ID')) + '))) AND '
//                                                                              (sd.docdate$date=' + NxFloatToIBStr(mbo.GetFieldValueAsDateTime('X_ABRADate')) + ') AND'
                                                                              + '(A.StoreBatch_ID = ' + QuotedStr(mbo.GetFieldValueAsString('X_Batches')) + ' )',mr2);
                                                                      end;
                                                                         if mr2.count=0 then begin
                                                                             //NxShowSimpleMessage('Pro šarži nebyl dohledán pohyb ', nil);

//                                                                             exit;
                                                                         end;
                                                                         for i := 0 to mr2.Count - 1 do begin
                                                                             mSelected.Add(mr2.Strings[i]);
                                                                         end;
                                                                  finally
                                                                      mr2.free;
                                                                  end;
                                                               mstring:='';
                                                               if mr2.Count>0 then begin
                                                                    mstring:= mroll.SingleSelectFromSelected2(mSelected, 'Pohyb šarže: +' + mbo.GetFieldValueAsString('X_batches.name')  + ' v množství ' + NxFloatToIBStr(mbo.GetFieldValueAsFloat('X_quantity')), '');
                                                               end;

                                                           if mstring<>'' then begin
                                                               mBOPohyb:=mbo.ObjectSpace.CreateObject('K3TH0HR5TZDL342W01C0CX3FCC');
                                                               try
                                                                     mBOPohyb.Load(mstring,nil);
                                                                       if index=0 then begin
                                                                             mr2:=TStringList.create;
                                                                             try
                                                                                 mbo.ObjectSpace.SQLSelect('Select ii2.parent_id from IssuedInvoices2 ii2 where ii2.ProvideRow_ID=' + quotedstr(mBOPohyb.GetFieldValueAsstring('Parent_ID')) ,mr2);
                                                                                 if mr2.count>0 then begin
                                                                                       TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_parent_ID',mr2.Strings[0]);
                                                                                 end;
                                                                             finally
                                                                                 mr2.free;
                                                                             end;

                                                                             mr2:=TStringList.create;
                                                                             try
                                                                                 mbo.ObjectSpace.SQLSelect('Select ii2.id from IssuedInvoices2 ii2 where ii2.ProvideRow_ID=' + quotedstr(mBOPohyb.GetFieldValueAsstring('Parent_ID')) ,mr2);
                                                                                 if mr2.count>0 then begin
                                                                                      TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_parent2_id',mr2.Strings[0]);
                                                                                 end;
                                                                             finally
                                                                                 mr2.free;
                                                                             end;

                                                                                 TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_DEVENOLUX',mBOPohyb.GetFieldValueAsString('Parent_ID.Parent_ID'));
                                                                                 TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_MX_NAZEV',mBOPohyb.GetFieldValueAsstring('Parent_ID'));
                                                                                 TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_DE_NAZEV',mBOPohyb.oid);
                                                                                 TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_vychystano',mBOPohyb.GetFieldValueAsFloat('Quantity'));
                                                                                 TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_PM_State','1050000101');
                                                                                 TBusRollSiteForm(mSite).CurrentObject.save;
                                                                       end;
                                                                       if index=1 then begin
                                                                             TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_EN_NAZEV',mBOPohyb.oid);
                                                                             TBusRollSiteForm(mSite).CurrentObject.save;
                                                                       end;
                                                               finally
                                                                   mBOPohyb.free;
                                                               end;
                                                         end;



    end;







end;





begin
end.