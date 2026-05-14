uses '_Knihovny_ALL.head', '_Knihovny_ALL.Progress','_Knihovny_ALL.Parse',
'abra.eu.mask_import.2018.Objednavka_prijata';

const
    mFilter='*.xml';






function ImportFileX2(OS: TNxCustomObjectSpace; AFileName: string;directory: string;filename: string;msite:TDynSiteForm;rucne:boolean;chyba:boolean;index:Integer;mUser_id:string) : Boolean;
var
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
begin
mError:=false;
mShowError:=false ;
    if not FileExists(AFileName) then begin
      Result := False;
      exit;
    end else begin

    try
      mXMLHead := TNxScriptingXMLWrapper.Create;
        mXMLHead.loadFromFile(AFileName);
      ProgressInit(msite, 'Načtení souboru ' + '', 100);

        mHead := TNxHeaderBusinessObject(OS.CreateObject('050I5SAOS3DL3ACU03KIU0CLP4'));
        try
                      mHead.New;
                     mHead.Prefill;
                              mHead.SetFieldValueAsString('DocQueue_ID', '7A10000101');

                              //if not(ErrtElementString(mXMLHead ,'Doc') and (index=3)) then
                              //mHead.SetFieldValueAsString('ExternalNumber',mXMLHead.getElementAsString('ABRADocument.ExternalNumber'));

                              for i := 0 to mXMLHead.getElementsCountInArray('Doc.Row') - 1 do begin
                               ProgressSetPos(1+NxFloor(i/mXMLHead.getElementsCountInArray('Doc.Row')*99), inttostr(i) +' z '+inttostr(mXMLHead.getElementsCountInArray('Doc.Row')));

                                    mRow := mHead.Rows.AddNewObject;
                                             mRow.Prefill;
                                             mRow.SetFieldValueAsInteger('RowType',3);
                                                       mr:=TStringList.create;
                                                       try
                                                           os.SQLSelect('Select id from stores where code=' + quotedstr(mXMLHead.getElementAsString('Doc.Row[' + inttostr(i) +'].Storecode')),mr);
                                                           if mr.count>0 then begin
                                                                 mRow.SetFieldValueAsstring('Store_ID',mr.strings[0]);
                                                           end;
                                                       finally
                                                          mr.free;
                                                       end;

                                                       mr:=TStringList.create;
                                                       try
                                                           os.SQLSelect('Select id from Storecards where EAN=' + quotedstr(mXMLHead.getElementAsString('Doc.Row[' + inttostr(i) +'].Ean')),mr);
                                                           if mr.count>0 then begin
                                                                 mRow.SetFieldValueAsstring('StoreCard_ID',mr.strings[0]);
                                                           end else begin
                                                               mRow.SetFieldValueAsstring('StoreCard_ID','3NQ1000101');
                                                               mError:=true;
                                                           end;
                                                       finally
                                                          mr.free;
                                                       end;
                                                       mRow.SetFieldValueAsstring('Division_ID','1N00000101');
                                                       mpocet:=0 ;




                                                                    mBAtches:=mRow.GetLoadedCollectionMonikerForFieldCode(mRow.GetFieldCode('DocRowBatches'));
                                                                               for ii:=0 to (mXMLHead.getElementsCountInArray('Doc.Row[' + inttostr(i) +'].batch')) -1 do begin
                                                                                       mBAtch:=mBAtches.AddNewObject;

                                                                                             mBAtch.Prefill;
                                                                                                       mr:=TStringList.create;
                                                                                                       try
                                                                                                           os.SQLSelect('Select id from Storebatches where Name=' + quotedstr(mXMLHead.getElementAsString('Doc.Row[' + inttostr(i) +'].batch['+ inttostr(ii) +'].Name')),mr);
                                                                                                           if mr.count>0 then begin
                                                                                                                 mBAtch.SetFieldValueAsstring('StoreBatch_ID',mr.strings[0]);
                                                                                                           end else begin
                                                                                                               mError:=true;
                                                                                                           end;
                                                                                                       finally
                                                                                                          mr.free;
                                                                                                       end;

                                                                                                       mBAtch.SetFieldValueAsfloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('Doc.Row[' + inttostr(i) +'].batch['+ inttostr(ii) +'].quantity')));
                                                                                                       mpocet:=mpocet+NxIBStrToFloat(mXMLHead.getElementAsString('Doc.Row[' + inttostr(i) +'].batch['+ inttostr(ii) +'].quantity'));
                                                                                end;





                                                                  mRow.SetFieldValueAsfloat('Quantity',mpocet);



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

                              end;
                             ProgressDispose()   ;
                             if mError then  NxShowSimpleMessage('Při importu došlo k chybám , prosím zkontrolujte', nil);
                              //if rucne then begin
                                //  mhead.ClearValidateErrors;
                                //  if Not mhead.Validate() then begin
                                //        mList := TStringList.Create;
                                //        try
                                //           mhead.GetValidateErrors(mList);
                                //           mText := mList.Text;
                                //           NxToken(mText, '=');
                                //           MessageDlg('Automaticky vytvořenou objednávku nelze uložit z těchto důvodů:' + #13#10 + mText,
                                //
                               //            mtWarning, [mbOK], 0);
                               //          finally
                               //            mList.Free;
                               //          end;
                                         mSite.ShowDynFormWithNewDocument('B50I5SAOS3DL3ACU03KIU0CLP4', mSite.SiteContext, mhead);

                                //  end else begin



                                //        mhead.Save;

                                //        if (rucne) and (index<>1) then NxShowSimpleMessage('Objednávka ' + mhead.GetFieldValueAsstring('Docqueue_ID.code') + '-' + inttostr(mhead.GetFieldValueAsinteger('Ordnumber')) + '/' +
                                //                                                mhead.GetFieldValueAsstring('Period_ID.code') + ' byla vytvořena',nil);
                                //  end;

                              //end;

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
     finally
      mXMLHead.Free;
     end;
    Result := True;

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
          mMAction.Hint := 'Import DL z XML';
          mMAction.Caption := 'Import DL ';
          mMAction.Items.Add('Import DL ');
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
   if index<>1 then begin
       if PromptForFileName(mFileName, mfilter, '', 'Soubor Soubor pro import', mdir, False) then begin
          mdir:=copy(mfilename,0,NxCharPosR('\',mfilename));
          mFile:=copy(mfilename,1+NxCharPosR('\',mfilename),Length(mfilename));
        end;
   end;
  //ImportFile(TDynSiteForm(mSite).CurrentObject.ObjectSpace, mfilename, mdir,mfile);
  if index=0 then ImportFilex2(TDynSiteForm(mSite).BaseObjectSpace, mfilename, mdir,mfile,msite,true,false,index,TDynSiteForm(msite).CompanyCache.GetUserID);
  if index=1 then begin
        mFileList:=TStringList.create;
        try
                mdir:= '\\CZVS0006\Import\Hromadne';
                NxGetFileList(mdir,mfilelist,'*.xml',true);
                     ProgressInit(msite, 'Načtení souboru ' + '', 100);
                                for i:=0 to mFileList.count-1 do begin
                                     ProgressSetPos(1+NxFloor(i/mfilelist.Count*99), inttostr(i) +' z '+inttostr(mfilelist.Count));

                                     mFile:=copy(mFileList.Strings[i],1+NxCharPosR('\',mFileList.Strings[i]),Length(mFileList.Strings[i]))+'.xml';
                                     mfilename:=mdir+'\' + mfile;
                                     //NxShowSimpleMessage(mfilename + ' - '+ mdir+' - ' +mfile,nil);
                                     ImportFilex2(TDynSiteForm(mSite).BaseObjectSpace, mfilename, mdir,mfile,msite,true,false,index,TDynSiteForm(msite).CompanyCache.GetUserID);
                                end;
                     ProgressDispose()   ;
        finally
            mFileList.free;

        end;

    end;




  if index=2 then begin
      ShowMessage(Format('Bude importován soubor %s%s', [mdir,mfile]));
      ImportFile2(TDynSiteForm(mSite).BaseObjectSpace, mfilename, mdir,mfile,msite,true,true,index,TDynSiteForm(msite).CompanyCache.GetUserID);

  end;

  if index=3 then begin
      ShowMessage(Format('Bude importován soubor %s%s, chyby budou ignorovány', [mdir,mfile]));
      ImportFile2(TDynSiteForm(mSite).BaseObjectSpace, mfilename, mdir,mfile,msite,true,true,index,TDynSiteForm(msite).CompanyCache.GetUserID);

  end;
  if index=4 then begin
      ShowMessage(Format('Bude importován soubor %s%s, chyby budou ignorovány', [mdir,mfile]));
      ImportFile2(TDynSiteForm(mSite).BaseObjectSpace, mfilename, mdir,mfile,msite,true,true,index,TDynSiteForm(msite).CompanyCache.GetUserID);

  end;
  TDynSiteForm(mSite).Refreshdata;
end;





begin
end.
