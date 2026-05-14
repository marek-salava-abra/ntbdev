uses '_Knihovny_ALL.head', '_Knihovny_ALL.Progress','_Knihovny_ALL.Parse',
'abra.eu.mask_import.2018.Objednavka_prijata';

const
    mFilter='*.csv';






function ImportFileX2(OS: TNxCustomObjectSpace; AFileName: string;directory: string;filename: string;msite:TDynSiteForm;rucne:boolean;chyba:boolean;index:Integer) : Boolean;
var
mhead:TNxHeaderBusinessObject;
mID_Docqueue_iD,mID_Store_iD:string;
mObchodniPripad,mdivision_id:string;
mstore_id:string;
mBustransaction_ID:string;
mfind_string:string;
mr,mrsa,mxax:tstringlist;
mStoreCard_ID:string;
mBO_adress:TNxCustomBusinessObject;
mAdress_id:string;
mi_result:integer;
mMon,mBAtches:TNxCustomBusinessMonikerCollection;
mstorecard_text:string;
mbo_docqueue,mbatch:TNxCustomBusinessObject;
mQunit:string;
mPacName:string;
mabraqunit:string;
mTyp_Eshopu:string;
mUnicodeName,mUnicodeCity,mUnicodeStreet,mUnicodeLocation,mUnicodeFullName:string;
mCode: integer;
mBusOrder_ID,mBusProject_ID,mbo_id:string;
mTariff: String;
mShowError:boolean;
mrx:tstringlist;
mpocet:double;
mError:boolean;
mImportFile:TStringList;
    mid :string;
    moddelovac:string;
    mOLE, mRoll, mOResult: Variant;
  mGrid: TdbGrid;
  mControl: TControl;
  mDataSource: TDataSource;
  mDataset: TNxRowsObjectDataSet;
    _ss:Variant;
    mfirm_id:string;
    mstringline:string;
  mCountField:integer;
  mfieldValue,mRSql:tstringlist;
  mbatch_ID:string;
  mquantity:double;
  mBatchquantity:double;
  mlist:tstringlist;
  mFirmOffice_id:string;
begin

//NxShowSimpleMessage('Aa',nil);
    if not FileExists(AFileName) then begin
      Result := False;
      exit;
    end;


  mOLE := GetAbraOLEApplication;
    mroll := mOLE.GetAgenda('OFZO2K155FDL3CL100C4RHECN0');
    _ss := mOLE.CreateStrings;

   mstore_ID:= mroll.SingleSelectFromSelected2(_ss, 'Vyber sklad', '');
                                      mImportFile:=TStringList.create;
                                      mImportFile.LoadFromFile(AFileName);

  mr:=tstringlist.create;
  try
       os.SQLSelect('Select X_Firm_ID from Stores where id=' + quotedstr(mstore_id),mr);
       if mr.count>0 then begin
           mfirm_id:=mr.Strings[0];
       end else begin
           mfirm_id:='';
       end;
  finally
     mr.free;
  end;

  mr:=tstringlist.create;
  try
       os.SQLSelect('Select id from FirmOffices where X_Store_ID=' + quotedstr(mstore_id) + ' and Parent_ID=' + quotedstr(mfirm_id) ,mr);
       if mr.count>0 then begin
           mFirmOffice_id:=mr.Strings[0];
       end else begin
           mFirmOffice_id:='';
       end;
  finally
     mr.free;
  end;



 mlist:=tstringlist.create;
      for i:=1 to mImportFile.Count-1 do begin   // načtení souboru
            //ProgressSetPos(1+NxFloor((i/mImportFile.Count)*99), inttostr(i) +' z '+inttostr(mImportFile.Count));

            mstringline:= mImportFile.strings[i];
           // mCountField:=0;
           // mCountField :=4;//NxCharCount(',',mstringline);


            mfieldValue:= TStringList.Create;
            try
                Parsevalue(mstringline,';',mstringline,mfieldValue,4);
                mbatch_ID:='';
                mStoreCard_ID:='';
                 mRSql:= tstringlist.Create;   // ***** dohledání šarže
                        try
                           os.SQLSelect('SELECT sb.id||sb.Storecard_ID from StoreBatches SB WHERE sb.hidden= ' + quotedstr('N') + ' AND sb.name = ' + quotedstr(mfieldValue.Strings[1]),mRSql);
                           if mRSql.count>0 then begin
                                mBatch_ID:=copy(mRSql.Strings[0],1,10);
                                mStoreCard_ID:=copy(mRSql.Strings[0],11,10);
                           end;
                        finally
                            mRSql.free;
                        end ;
            finally
                  mfieldValue.free;
            end;
           mlist.add('0000000000'+mStoreCard_ID+mBatch_ID+'1')
      end;

      mlist.Sort;

 mHead := TNxHeaderBusinessObject(OS.CreateObject('E03ZNUMDTCC4PDAUIEY1MBTJC0'));                                       //   dl         050I5SAOS3DL3ACU03KIU0CLP4
        try
                      mHead.New;
                     mHead.Prefill;
                              mHead.SetFieldValueAsString('DocQueue_ID', '7700000101');                   // dl
                              mHead.SetFieldValueAsString('Firm_ID', mfirm_id);
                              mHead.SetFieldValueAsString('FirmOffice_ID', mFirmOffice_id);

                            mquantity:=0;
                             mBatchquantity:=0;
                            for i:=0 to mlist.count-1 do begin
                                        // NxShowSimpleMessage(inttostr(index),nil);
                                         //ProgressInit(msite, 'Zpracování ' + AFileName, 100);

                                          if i=0 then begin
                                              mquantity:=1;
                                              mBatchquantity:=1;
                                          end else begin
                                              if copy(mlist.Strings[i],1,20)<>copy(mlist.Strings[i-1],1,20) then begin // novy řádek
                                                      mRow := mHead.Rows.AddNewObject;
                                                           mRow.Prefill;
                                                           mRow.SetFieldValueAsInteger('RowType',3);
                                                           mRow.SetFieldValueAsString('Store_ID',mstore_id);
                                                           mRow.SetFieldValueAsString('StoreCard_ID',copy(mlist.Strings[i-1],11,10));
                                                           mRow.SetFieldValueAsstring('Division_ID','1N00000101');
                                                           mRow.SetFieldValueAsFloat('Quantity',mquantity);

                                                            if NxIsEmptyOID(mRow.GetFieldValueAsString('BusTransaction_id')) then begin
                                                                if not NxIsEmptyOID((mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))) then begin
                                                                             mBustransaction_ID:=(mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'));
                                                                             mRow.SetFieldValueAsString('BusTransaction_id',mBustransaction_ID );
                                                                end;
                                                            end;
                                                            if NxIsEmptyOID(mRow.GetFieldValueAsString('BusOrder_id')) then begin
                                                                      mBusOrder_ID:=GetBusOrder_ID(mRow);
                                                                      if not nxisblank(mBusOrder_ID) then mRow.SetFieldValueAsString('BusOrder_id',mBusOrder_ID);
                                                            end;
                                                            if NxIsEmptyOID(mRow.GetFieldValueAsString('BusProject_id')) then begin
                                                                mBusProject_ID:=GetProject_ID(mRow);
                                                                if not nxisblank(mBusProject_ID) then mRow.SetFieldValueAsString('BusProject_id',mBusProject_ID);
                                                            end;
                                                              mBAtches:=mRow.GetLoadedCollectionMonikerForFieldCode(mRow.GetFieldCode('DocRowBatches'));
                                                                         mBAtch:=mBAtches.AddNewObject;
                                                                               mBAtch.Prefill;
                                                                               mBAtch.SetFieldValueAsstring('StoreBatch_ID',copy(mlist.Strings[i-1],21,10));
                                                                               mBAtch.SetFieldValueAsfloat('Quantity',mBatchquantity);


                                                      mquantity:=1;
                                                      mBatchquantity:=1;
                                              end else begin   // stejný řádek
                                                       mquantity:=mquantity + 1;

                                                       if copy(mlist.Strings[i],21,10)<>copy(mlist.Strings[i-1],21,10) then begin // nová šarže
                                                              mBAtches:=mRow.GetLoadedCollectionMonikerForFieldCode(mRow.GetFieldCode('DocRowBatches'));
                                                                         mBAtch:=mBAtches.AddNewObject;
                                                                               mBAtch.Prefill;
                                                                               mBAtch.SetFieldValueAsstring('StoreBatch_ID',copy(mlist.Strings[i-1],21,10));
                                                                               mBAtch.SetFieldValueAsfloat('Quantity',mBatchquantity);
                                                            mBatchquantity:=1;
                                                       end else begin   // stejná šarže
                                                           mBatchquantity:=mBatchquantity+1;

                                                       end;
                                              end;
                                          end;
                              end;

                              // konec      dokladu
                               mRow := mHead.Rows.AddNewObject;
                                                           mRow.Prefill;
                                                           mRow.SetFieldValueAsInteger('RowType',3);
                                                           mRow.SetFieldValueAsString('Store_ID',mstore_ID);
                                                           mRow.SetFieldValueAsString('StoreCard_ID',copy(mlist.Strings[mlist.count-1],11,10));
                                                           mRow.SetFieldValueAsstring('Division_ID','1N00000101');
                                                           mRow.SetFieldValueAsFloat('Quantity',mquantity);
                                                            if NxIsEmptyOID(mRow.GetFieldValueAsString('BusTransaction_id')) then begin
                                                                if not NxIsEmptyOID((mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))) then begin
                                                                             mBustransaction_ID:=(mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'));
                                                                             mRow.SetFieldValueAsString('BusTransaction_id',mBustransaction_ID );
                                                                end;
                                                            end;
                                                            if NxIsEmptyOID(mRow.GetFieldValueAsString('BusOrder_id')) then begin
                                                                      mBusOrder_ID:=GetBusOrder_ID(mRow);
                                                                      if not nxisblank(mBusOrder_ID) then mRow.SetFieldValueAsString('BusOrder_id',mBusOrder_ID);
                                                            end;
                                                            if NxIsEmptyOID(mRow.GetFieldValueAsString('BusProject_id')) then begin
                                                                mBusProject_ID:=GetProject_ID(mRow);
                                                                if not nxisblank(mBusProject_ID) then mRow.SetFieldValueAsString('BusProject_id',mBusProject_ID);
                                                            end;

                                                            mBAtches:=mRow.GetLoadedCollectionMonikerForFieldCode(mRow.GetFieldCode('DocRowBatches'));
                                                                         mBAtch:=mBAtches.AddNewObject;
                                                                               mBAtch.Prefill;
                                                                               mBAtch.SetFieldValueAsstring('StoreBatch_ID',copy(mlist.Strings[mlist.count-1],21,10));
                                                                               mBAtch.SetFieldValueAsfloat('Quantity',mBatchquantity);
                             //ProgressDispose()   ;
                                  mhead.ClearValidateErrors;
                                  if Not mhead.Validate() then begin
                                        mList := TStringList.Create;
                                        try
                                           mhead.GetValidateErrors(mList);
                                           mText := mList.Text;
                                           NxToken(mText, '=');
                                           MessageDlg('Automaticky vytvořenou objednávku nelze uložit z těchto důvodů:' + #13#10 + mText,

                                           mtWarning, [mbOK], 0);
                                         finally
                                           mList.Free;
                                         end;
                                         mSite.ShowDynFormWithNewDocument('B10I5SAOS3DL3ACU03KIU0CLP4', mSite.SiteContext, mhead);             //                       B50I5SAOS3DL3ACU03KIU0CLP4

                                  end else begin
                                        //mhead.Save;
                                        NxShowSimpleMessage('Dodací list ' + mhead.GetFieldValueAsString('displayname')  ,nil);               //         B50I5SAOS3DL3ACU03KIU0CLP4
                                        mSite.ShowDynFormWithNewDocument('B10I5SAOS3DL3ACU03KIU0CLP4', mSite.SiteContext, mhead);

                                  end;


                           {
                              if index=1 then begin
                                   result:=nxcopyfile(AFileName,'\\CZVS0006\Import\Zpracovane\' + FileName);
                                   //NxShowSimpleMessage('Přesun  ' + AFileName + '  - '   + '\\CZVS0006\Import\Zpracovane\' + FileName ,nil);
                              end else begin
                                   result:=nxcopyfile(AFileName,'\\CZVS0006\Import\Zpracovane\' + FileName);
                              end;
                              if result then begin
                                  //NxShowSimpleMessage('mazaání',nil);
                                  DeleteFile(AFileName);
                                  if rucne and result and chyba then begin
                                         NxShowSimpleMessage('Soubor ' + afilename + ' byl přesunut do zpracovaných',nil);
                                  end;
                              end; }
            finally
                 mhead.free;
            end;
    Result := True;

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
          mMAction.Hint := 'Import DL z CSV';
          mMAction.Caption := 'Import z CSV ';
          mMAction.Items.Add('Import z CSV ');
          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec;




end;

procedure OnExec(Sender: TComponent;index:integer);
var

  zadej:string;
  mfilename:string;
  mdir,mfile:string;
  mFileList:tstringlist;
begin
  //mSite := NxFinddySiteForm(Sender);
  msite:=TComponent(Sender).DynSite;

  if PromptForFileName(mFileName, mfilter, '', 'Soubory SP', '', False) then begin
                      mdir:=copy(mfilename,0,NxCharPosR('\',mfilename));
                      mFile:=copy(mfilename,1+NxCharPosR('\',mfilename),Length(mfilename));
  end;

  ImportFilex2(TDynSiteForm(mSite).BaseObjectSpace, mfilename, mdir,mfile,msite,true,false,index);


  TDynSiteForm(mSite).Refreshdata;
end;





begin
end.
