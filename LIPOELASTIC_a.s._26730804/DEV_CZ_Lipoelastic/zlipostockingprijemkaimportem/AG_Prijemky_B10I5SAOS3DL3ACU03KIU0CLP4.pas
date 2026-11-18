uses '_Knihovny_ALL.head';

Var
mTyp_obchodu:string;
  mXMLHead : TNxScriptingXMLWrapper;
  mSite : TDynSiteForm;
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
  mbusorder,mbustransaction,mbusproject,mbankacount: TNxCustomBusinessObject;
  maddress: TNxCustomBusinessObject;
  mhead: TNxHeaderBusinessObject;
  mID_Store,mID_StoreCard,mIDdoklad,mID_odberatel, mID_dodavatel, mID_Docqueue, mID_BusOrder,mID_Division, mID_VatCountry,mID_Country, mID_Currency,mID_Vatrate,mID_Row: string;
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

const
    mFilter='*.xml';


    Function ErrtElementString(mXMLHead : TNxScriptingXMLWrapper;mElement:string):boolean;
var
mstring:string;
begin
result:=true;
    try
          mstring:=mXMLHead.getElementAsString(mElement);
          result:=false;
    except
          result:=true;
    end;
end;



    function ImportFile20(OS: TNxCustomObjectSpace; AFileName: string;directory: string;filename: string;msite:TDynSiteForm;rucne:boolean;chyba:boolean;index:Integer) : Boolean;
var
mID_Docqueue_iD,mID_Store_iD:string;
mObchodniPripad,mdivision_id:string;
mstore_id:string;
mBustransaction_ID:string;
mfind_string:string;
mr,mx,mrsa,mxax:tstringlist;
mStoreCard_ID:string;
mBO_adress,mBO_Sarze,mRowDocRowBatches,mBOIssuedOrderRow:TNxCustomBusinessObject;
mAdress_id:string;
mi_result:integer;
mMon,mMonBatches:TNxCustomBusinessMonikerCollection;
mstorecard_text:string;
mbo_docqueue:TNxCustomBusinessObject;
mQunit:string;
mPacName:string;
mabraqunit:string;
mTyp_Eshopu,MID_SARZE:string;
mi:double;
mInteger:Integer;
mWorkList:Tstringlist;
mSelectedRows,mDocLists:Tstringlist;
x:integer;
mFind:Boolean;
  mImportMan: TNxDocumentImportManager;
  mOS: TNxCustomObjectSpace;
  mInputParams: TNxParameters;
  mParam: TNxParameter;
  mCollRows: TNxCustomBusinessMonikerCollection;
  xx,xxx: integer;
  mList: TStringList;
  mRow: TNxCustomBusinessObject;
  mtext:string;
  mValidateList:tstringlist;
  mRowsOutput:TNxCustomBusinessMonikerCollection;
  msave:boolean;
  mIDoc:integer;
  mpomoc1,mpomoc2,mpomoc3,mpomoc4:string;
begin
    if not FileExists(AFileName) then begin
      Result := False;
      exit;
    end else begin

    try
      mXMLHead := TNxScriptingXMLWrapper.Create;
        mXMLHead.loadFromFile(AFileName);

        mSelectedRows:=TStringList.create;
        mDocLists:=TStringList.create;
         for i := 0 to mXMLHead.getElementsCountInArray('AbraDocument.Rows.Row') - 1 do begin
             if (mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].X_ProvideRow_ID'))<>'' then begin
                  mr:=tstringlist.create;
                  try
                     mi:=os.SQLExecute('update issuedorders2 set store_id=' + quotedstr('2Z00000101') + ' where id=' + quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].X_ProvideRow_ID'))) ;
                     os.SQLSelect('select Parent_ID from issuedorders2 where id=' + quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].X_ProvideRow_ID')),mr) ;
                     if mr.count>0 then begin

                          mFind:=false;
                          for x:=0 to mDocLists.Count-1 do begin
                              if mDocLists.Strings[x]=mr.Strings[0] then mFind:=true;
                          end;
                          if not mFind then mDocLists.add(mr.Strings[0]);
                          mSelectedRows.add(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].X_ProvideRow_ID'));
                     end;
                  finally
                      mr.free;
                  end;
             end;

         end;


         mID_Division:='1300000101';
          mID_Docqueue_ID:= '6A10000101';
          mID_odberatel:= 'DFW6400101';
          //mstore_id:='1M00000101';

             // NxShowSimpleMessage('Doklad' + inttostr(mDocLists.count),nil);
             // NxShowSimpleMessage('Rádek' + inttostr(mSelectedRows.count),nil);

                //  mOS := msite.BaseObjectSpace;
                  try
                    mInputParams := TNxParameters.Create;
                      if mID_Docqueue_ID<>'' then begin
                          mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
                          mParam.AsString := mID_Docqueue_ID;
                      end;
                      if mID_odberatel<>'' then begin
                          mParam := mInputParams.GetOrCreateParam(dtString, 'Firm_ID');
                          mParam.AsString := mID_odberatel;
                      end;
                      if mSelectedRows.count>0 then begin
                           mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows'); // jen povolene radky
                           mParam.AsString := mSelectedRows.Text;
                      end;

                      mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader'); // musi se z nejake hlavicky prebirat hlavickova data
                      mParam.AsString := mDocLists.Strings[0];


                      mImportMan := NxCreateDocumentImportManager(OS, 'CDMK5QAWZZDL342X01C0CX3FCC', 'E03ZNUMDTCC4PDAUIEY1MBTJC0');
                      try

                        for mIDoc:=0 to mDocLists.count-1 do begin
                             mImportMan.AddInputDocument(mDocLists.Strings[mIDoc]);
                        end;

                        mImportMan.LoadParams(mInputParams);
                        mImportMan.Execute;
                        mImportMan.CheckOutputDocument;


                        mHead:=TnxHeaderBusinessObject(mImportMan.OutputDocument);
                        mRowsOutput := mHead.GetLoadedCollectionMonikerForFieldCode(mHead.GetFieldCode('Rows'));

                       for i := 0 to mXMLHead.getElementsCountInArray('AbraDocument.Rows.Row') - 1 do begin
                                mFind:=false;
                              for ii := 0 to mRowsOutput.Count - 1 do begin
                                   //mRowsOutput.BusinessObject[ii].setFieldValueAsString('Store_ID','2Z00000101');
                                   if mRowsOutput.BusinessObject[ii].GetFieldValueAsString('ProvideRow_ID')=mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].X_ProvideRow_ID') then begin
                                        mFind:=true;
                                               //if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Quantity') and (index=2)) then
                                                                mRowsOutput.BusinessObject[ii].setFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Quantity'))); //text bude  ...


                                                 // šarže
                                                            mMonBatches := mRowsOutput.BusinessObject[ii].GetLoadedCollectionMonikerForFieldCode(mRowsOutput.BusinessObject[ii].GetFieldCode('DocRowBatches'));
                                                            //mRowsOutput.BusinessObject[ii].SetFieldValueAsString('Store_ID','1M00000101');
                                                            for ii := 0 to mXMLHead.getElementsCountInArray('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch') - 1 do begin
                                                                    //if mXMLHead.getElementsCountInArray('AbraDocument.Rows.Row.Batches.Batch')>0 then begin
                                                                    //NxShowSimpleMessage('Sarze ' + mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].name'),nil);
                                                                    if mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].name')<>'' then begin
                                                                          mr:=tstringlist.create;
                                                                           // dohledání pohybu šarže
                                                                           try
                                                                                msite.BaseObjectSpace.SQLSelect('SELECT b.ID FROM StoreBatches b where b.name=' + quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].name')) +
                                                                                                                ' and b.hidden=' + quotedstr('N') ,mr) ;
                                                                                mRowDocRowBatches := mMonBatches.AddNewObject;
                                                                                if mr.count=0 then begin
                                                                                              mRowDocRowBatches.Prefill;
                                                                                              //mRowDocRowBatches.SetFieldValueAsInteger('PosIndex',II);
                                                                                              mRowDocRowBatches.SetFieldValueAsBoolean('NewBatch',True);
                                                                                              //mRowDocRowBatches.SetFieldValueAsString('StoreBatch_ID ',mID_Sarze);
                                                                                              mRowDocRowBatches.SetFieldValueAsString('NewBatchComment','');
                                                                                              mRowDocRowBatches.SetFieldValueAsString('NewBatchName',mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].name'));
                                                                                              mRowDocRowBatches.SetFieldValueAsString('NewBatchSpecification',mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].Specification'));
                                                                                              mRowDocRowBatches.SetFieldValueAsDateTime('NewBatchExpirationDate$DATE',now);
                                                                                              mRowDocRowBatches.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].quantity')));
                                                                                end else begin
                                                                                       mID_Sarze:=mr.Strings[0];
                                                                                             mRowDocRowBatches.Prefill;
                                                                                            //mRowDocRowBatches.SetFieldValueAsInteger('PosIndex',II);
                                                                                            mRowDocRowBatches.SetFieldValueAsBoolean('NewBatch',False);
                                                                                            mRowDocRowBatches.SetFieldValueAsString('StoreBatch_ID',mID_Sarze);
                                                                                            mRowDocRowBatches.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].quantity')));
                                                                                end;

                                                                           finally
                                                                              mr.free;
                                                                           end;
                                                                    end;
                                                            //  end;
                                                          //    end;
                                                             end;   // konec batches

                                   end;
                              end;



                                   if not mFind then begin
                                      mRow := mHead.Rows.AddNewObject;
                                          mRow.Prefill;
                                          mStoreCard_ID:='';
                                          mstorecard_text:='';
                                          mRow.SetFieldValueAsString('Store_ID','1M00000101');
                                                    mStoreCard_ID:='';
                                                        mstorecard_text:='';
                                                         if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.EAN') and (index=2)) then begin
                                                                if (mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.EAN')<>'') then begin
                                                                         mr:=tstringlist.create;
                                                                          try
                                                                              msite.BaseObjectSpace.SQLSelect(format('select sc.id||su.code from STOREEANS SE left join StoreUnits SU on SU.id=se.Parent_id left join Storecards SC on sc.id=su.parent_id where ((se.EAN=%s ) or (sc.EAN=%s )) and (sc.hidden=%s)',
                                                                              [quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.EAN')),quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.EAN')),QuotedStr('N')]),mr);

                                                                                   if mr.count=0 then begin
                                                                                       //mstorecard_text:=mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.Ean') + ' - ' + mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.Name');
                                                                                       mStoreCard_ID:='3NQ1000101';
                                                                                       mQunit:='ks';
                                                                                   end else begin
                                                                                       mStoreCard_ID:=copy(
                                                                                        ReplaceStr(mr.Strings[0],'"',''),1,10);
                                                                                       mQunit:=copy(ReplaceStr(mr.Strings[0],'"',''),11,5);
                                                                                   end;
                                                                           finally
                                                                                mr.free;
                                                                           end;
                                                                 end else begin
                                                                      mStoreCard_ID:='3NQ1000101';
                                                                      mQunit:='ks';

                                                                 end;
                                                         end;
                                                         mRow.SetFieldValueAsString('Storecard_ID',mStoreCard_ID);
                                                          if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Quantity') and (index=2)) then begin
                                                                mRow.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Quantity'))); //text bude  ...
                                                                mRow.SetFieldValueAsString('Store_ID','1M00000101');
                                                                mRow.SetFieldValueAsString('Division_ID',mID_Division); //text bude  ...
                                                          end;
                                                  if not NxIsEmptyOID((mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))) then begin
                                                                             mBustransaction_ID:=(mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'));
                                                                             mRow.SetFieldValueAsString('BusTransaction_id',mBustransaction_ID );
                                                  end;

                                                  // šarže
                                                            mMonBatches := mrow.GetLoadedCollectionMonikerForFieldCode(mrow.GetFieldCode('DocRowBatches'));

                                                            for ii := 0 to mXMLHead.getElementsCountInArray('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch') - 1 do begin
                                                                    //if mXMLHead.getElementsCountInArray('AbraDocument.Rows.Row.Batches.Batch')>0 then begin
                                                                    //NxShowSimpleMessage('Sarze ' + mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].name'),nil);
                                                                    if mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].name')<>'' then begin
                                                                          mr:=tstringlist.create;
                                                                           // dohledání pohybu šarže
                                                                           try
                                                                                msite.BaseObjectSpace.SQLSelect('SELECT b.ID FROM StoreBatches b where b.name=' + quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].name')) +
                                                                                                                ' and b.hidden=' + quotedstr('N') ,mr) ;
                                                                                mRowDocRowBatches := mMonBatches.AddNewObject;
                                                                                if mr.count=0 then begin
                                                                                              mRowDocRowBatches.Prefill;
                                                                                              mRowDocRowBatches.SetFieldValueAsBoolean('NewBatch',True);
                                                                                              //mRowDocRowBatches.SetFieldValueAsString('StoreBatch_ID ',mID_Sarze);
                                                                                              mRowDocRowBatches.SetFieldValueAsString('NewBatchComment','');
                                                                                              mRowDocRowBatches.SetFieldValueAsString('NewBatchName',mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].name'));
                                                                                              mRowDocRowBatches.SetFieldValueAsString('NewBatchSpecification',mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].Specification'));
                                                                                              mRowDocRowBatches.SetFieldValueAsDateTime('NewBatchExpirationDate$DATE',now);
                                                                                              mRowDocRowBatches.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].quantity')));

                                                                                end else begin
                                                                                       mID_Sarze:=mr.Strings[0];
                                                                                            mRowDocRowBatches.Prefill;
                                                                                            mRowDocRowBatches.SetFieldValueAsBoolean('NewBatch',False);
                                                                                            mRowDocRowBatches.SetFieldValueAsString('StoreBatch_ID',mID_Sarze);
                                                                                            mRowDocRowBatches.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].quantity')));
                                                                                end;

                                                                           finally
                                                                              mr.free;
                                                                           end;
                                                                    end;
                                                             end;   // konec batches

                                   end;


















                       end;


                       mhead.SetFieldValueAsString('Description',FileName);


                                              if true then begin
                                                  mhead.ClearValidateErrors;
                                                   // if true then begin
                                                  if Not mhead.Validate() then begin
                                                        mList := TStringList.Create;
                                                        try
                                                           mhead.GetValidateErrors(mList);
                                                           mText := mList.Text;
                                                           NxToken(mText, '=');
                                                           MessageDlg('Automaticky vytvořenou příjemku nelze uložit z těchto důvodů:' + #13#10 + mText,

                                                           mtWarning, [mbOK], 0);
                                                         finally
                                                           mList.Free;
                                                         end;
                                                         mSite.ShowDynFormWithNewDocument('B10I5SAOS3DL3ACU03KIU0CLP4', mSite.SiteContext, mhead);
                                                         //mhead.refresh;
                                                        //msite.ActiveDataSet.RefreshCurrentItemMode;
                                                  end else begin
                                                        mhead.Save;
                                                        mhead.refresh;
                                                        msite.ActiveDataSet.RefreshCurrentItemMode;
                                                        if rucne then NxShowSimpleMessage('Prijemka ' + mhead.GetFieldValueAsstring('Docqueue_ID.code') + '-' + inttostr(mhead.GetFieldValueAsinteger('Ordnumber')) + '/' +
                                                                 mhead.GetFieldValueAsstring('Period_ID.code') + ' byla vytvořena',nil);
                                                        result:=nxcopyfile(AFileName,Directory + '\Zpracovane\' + FileName);

                                                        if result then begin
                                                            DeleteFile(AFileName);
                                                            if rucne and result and chyba then begin
                                                                   NxShowSimpleMessage('Soubor ' + afilename + ' byl přesunut do zpracovaných',nil);
                                                            end;
                                                        end;
                                                  end;
                                              end;

                      finally
                        mImportMan.Free;
                      end;
                    finally
                      mInputParams.Free;
                    end;

        finally
            mXMLHead.free;
        end;
   end;

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
begin
  mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Import z LIPOSTOCKING , SKLAD TE';
          mMAction.Caption := 'Import z LIPOSTOCKING , SKLAD TE';
          mMAction.Items.Add('Import z LIPOSTOCKING , SKLAD TE');
          mMAction.Items.Add('Import z LIPOSTOCKING , SKLAD TE2 ');
          if (Self.CompanyCache.GetUserID='1Z10000101')
            or (Self.CompanyCache.GetUserID='1H00000101')
            or (Self.CompanyCache.GetUserID='2W00000101')
            or (Self.CompanyCache.GetUserID='SUPER00000')
            or (Self.CompanyCache.GetUserID='3500000101')
            then begin
            mMAction.Items.Add('Ignorace chyb');
           end;
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec;

end;

procedure OnExec(Sender: TComponent;index:integer);
var

  zadej:string;
  mfilename:string;
  mdir,mfile:string;
begin
  //mSite := NxFinddySiteForm(Sender);
  msite:=TComponent(Sender).DynSite;
   if PromptForFileName(mFileName, mfilter, '', 'Soubor ESHOP TOP', mdir, False) then begin
    mdir:=copy(mfilename,0,NxCharPosR('\',mfilename));
    mFile:=copy(mfilename,1+NxCharPosR('\',mfilename),Length(mfilename));
   end;
  //ImportFile(TDynSiteForm(mSite).CurrentObject.ObjectSpace, mfilename, mdir,mfile);
  if index=0 then ImportFile20(TDynSiteForm(mSite).BaseObjectSpace, mfilename, mdir,mfile,msite,true,false,index);
  if index=1 then begin
      ShowMessage(Format('Bude importován soubor %s%s', [mdir,mfile]));
      ImportFile20(TDynSiteForm(mSite).BaseObjectSpace, mfilename, mdir,mfile,msite,true,true,index);

  end;

  if index=2 then begin
      ShowMessage(Format('Bude importován soubor %s%s, chyby budou ignorovány', [mdir,mfile]));
      ImportFile20(TDynSiteForm(mSite).BaseObjectSpace, mfilename, mdir,mfile,msite,true,true,index);

  end;
  //TDynSiteForm(mSite).Refreshdata;
  msite.activedataset.RefreshCurrentItem;
end;






begin
end.
