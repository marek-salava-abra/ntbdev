uses 'abra.eu.mask_import.LipoElasticjenpr.Prijemka',
     'Synchronizace.API',
          '_Knihovny_ALL.head',
          '_Knihovny_ALL.head','_Knihovny_ALL.head', '_Knihovny_ALL.Progress','_Knihovny_ALL.Parse';


const
    mFilter='*.xml';


{
Vyvolává se po provedení metody Show na dané agendě. Tato událost se volá i při přepínání agend.
}
procedure FormShow_Hook(Self: TSiteForm);
begin

end;

  function ImportFile3(OS: TNxCustomObjectSpace; AFileName: string;directory: string;filename: string;msite:TDynSiteForm;rucne:boolean;chyba:boolean;index:Integer) : Boolean;
var
mID_Docqueue_iD,mID_Store_iD:string;
mObchodniPripad,mdivision_id:string;
mstore_id:string;
mBustransaction_ID:string;
mfind_string:string;
mr,mx,mrsa,mxax:tstringlist;
mStoreCard_ID:string;
mBO_adress,mbo,mBO_Sarze,mBO_PohybSarze,mdocrowbatches:TNxCustomBusinessObject;
mAdress_id:string;
mi_result:integer;
mMon,mBO_MonikerBatches:TNxCustomBusinessMonikerCollection;
mstorecard_text:string;
mbo_docqueue:TNxCustomBusinessObject;
mQunit:string;
mPacName:string;
mabraqunit:string;
mTyp_Eshopu,MID_SARZE:string;
mdocument:string;
mi:integer;
mcena:double;
begin
  if index=1 then begin

    if not FileExists(AFileName) then begin
      Result := False;
      //exit;
    end else begin
    mID_Division:='5O10000101';
    try
      mXMLHead := TNxScriptingXMLWrapper.Create;
        mXMLHead.loadFromFile(AFileName);


        mexistuje:='';


        mbo := TDynSiteForm(msite).CurrentObject;
        try

                        mMon := mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('ROWS'));
                             for ii := 0 to mMon.Count - 1 do begin
                                    for i := 0 to mXMLHead.getElementsCountInArray('AbraDocument.Rows.Row') - 1 do begin
                                                       if true then begin //mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.SupplierCode')<>'' then begin
                                                          //if i=1 then NxShowSimpleMessage(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].UnitPriceWithoutVat'),nil);
                                                          if mMon.BusinessObject[ii].getFieldValueAsstring('Storecard_ID.EAN')= mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.EAN') then begin
                                                                      //NxShowSimpleMessage(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].UnitPriceWithoutVat'),nil);
                                                                     //mi:=msite.BaseObjectSpace.SQLExecute('Update storedocuments2 set unitprice=' +mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].UnitPrice')+ ' , totalprice=' +mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Tamount')+ 'where id=' + QuotedStr(mMon.BusinessObject[ii].oid)) ;


                                                                        //mMon.BusinessObject[ii].SetFieldValueAsFloat('UnitPrice',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].UnitPrice')))  ;
                                                                      //  if mMon.BusinessObject[ii].getFieldValueAsstring('Store_ID.code')='S999' then begin
                                                                      //      mMon.BusinessObject[ii].SetFieldValueAsFloat('UnitPrice',mMon.BusinessObject[ii].GetFieldValueAsFloat('Storecard_ID.X_cena_skladova_SK'))  ;
                                                                      //  end else begin
                                                                             mcena:=0;
                                                                             mcena:=NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].TAmountWithoutVAT'));
                                                                             mMon.BusinessObject[ii].SetFieldValueAsFloat('UnitPrice',0)  ;
                                                                             mMon.BusinessObject[ii].SetFieldValueAsFloat('TotalPrice',mcena)  ;
                                                                             mMon.BusinessObject[ii].SetFieldValueAsFloat('UnitPrice',(mcena/mMon.BusinessObject[ii].getFieldValueAsFloat('Quantity')))  ;
                                                                             //NxShowSimpleMessage(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].TAmountWithoutVAT'),nil);
                                                                     //   end;
                                                                        //mMon.BusinessObject[ii].SetFieldValueAsFloat('Tamount',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].TAmountWithoutVAT')))  ;
                                                          end;
                                                        end;






                                    end;
                              end;


                mbo.Save;
                 NxShowSimpleMessage('Uloženo', nil);





            finally
                // mbo.free;
            end;
     finally
      mXMLHead.Free;
     end;
    Result := True;
   end;
 end;

 if index=2 then begin


    if not FileExists(AFileName) then begin
      NxShowSimpleMessage('Soubor neexistuje , přerušuji', nil);
      Result := False;
      //exit;
    end else begin

              try
                mXMLHead := TNxScriptingXMLWrapper.Create;
                  mXMLHead.loadFromFile(AFileName);


                  mexistuje:='';



                  mbo := TDynSiteForm(msite).CurrentObject;

                                  mMon := mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('ROWS'));
                                       for ii := 0 to mMon.Count - 1 do begin
                                             for i := 0 to mXMLHead.getElementsCountInArray('AbraDocument.Rows.Row') - 1 do begin
                                                   if mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].X_ProvideRow_ID')=mMon.BusinessObject[ii].GetFieldValueAsString('X_ProvideRow_ID') then begin
                                                          mMon.BusinessObject[ii].SetFieldValueAsstring('X_StoreDocuments2_ID',(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].X_StoreDocuments2_ID'))); //text bude  ...

                                                                                       //       NxShowSimpleMessage(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(ii)+'].TAmountWithoutVAT'),nil);
                                                                                       mMon.BusinessObject[ii].SetFieldValueAsFloat('UnitPrice',(NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].TAmountWithoutVAT'))/mMon.BusinessObject[ii].getFieldValueAsFloat('Quantity')))  ;
                                                                             //NxShowSimpleMessage(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].TAmountWithoutVAT'),nil);  ;
                                                                                       mMon.BusinessObject[ii].SetFieldValueAsFloat('TotalPrice',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].TAmountWithoutVAT')))  ;
                                                   end;
                                              end;
                                        end;


                          mbo.Save;
                           NxShowSimpleMessage('Uloženo', nil);
              finally
                mXMLHead.Free;
               end;
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
          mMAction.Hint := 'Import z LIPA';
          mMAction.Caption := 'Import z Lipoelastik SK výroba';
          mMAction.Items.Add('Import z Lipoelastik');
          mMAction.Items.Add('Aktualizace cen z XML');
          mMAction.Items.Add('Aktualizace Výrobvních cen z SK');
          mMAction.Items.Add('Hromadný import');
          //mMAction.Items.Add('Výpis chyb');
          //if (Self.CompanyCache.GetUserID='1Z10000101')
          //  or (Self.CompanyCache.GetUserID='1H00000101')
          //  or (Self.CompanyCache.GetUserID='2W00000101')
          //  or (Self.CompanyCache.GetUserID='SUPER00000')
          //  or (Self.CompanyCache.GetUserID='3500000101')
          //  then begin
          //  mMAction.Items.Add('Ignorace chyb');
          // end;
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

  if index<>3 then begin   mdir:='';
               if PromptForFileName(mFileName, mfilter, '', 'Soubor z Lipoelastik', '\\CZVS0006\Import\DL', False) then begin
                mdir:=copy(mfilename,0,NxCharPosR('\',mfilename));
                mFile:=copy(mfilename,1+NxCharPosR('\',mfilename),Length(mfilename));
               end;
         if (index=0) or (index=1) then begin
               if index=0 then ImportFile2(TDynSiteForm(mSite).BaseObjectSpace, mfilename, mdir,mfile,msite,true,false,index);
               if index=1 then ImportFile3(TDynSiteForm(mSite).BaseObjectSpace, mfilename, mdir,mfile,msite,true,false,index);
         end;

        //ImportFile(TDynSiteForm(mSite).CurrentObject.ObjectSpace, mfilename, mdir,mfile);
        if index=2 then ImportFile3(TDynSiteForm(mSite).BaseObjectSpace, mfilename, mdir,mfile,msite,true,false,index);
        end;

  if index=3 then begin
        mFileList:=TStringList.create;
        try
                mdir:= '\\CZVS0006\Import\DL\Hromadne';
                NxGetFileList(mdir,mfilelist,'*.xml',true);
                     ProgressInit(msite, 'Načtení souboru ' + '', 100);
                                for i:=0 to mFileList.count-1 do begin
                                     ProgressSetPos(1+NxFloor(i/mfilelist.Count*99), inttostr(i) +' z '+inttostr(mfilelist.Count));

                                     mFile:=copy(mFileList.Strings[i],1+NxCharPosR('\',mFileList.Strings[i]),Length(mFileList.Strings[i]))+'.xml';
                                     mfilename:=mdir+'\' + mfile;
                                     //NxShowSimpleMessage(mfilename + ' - '+ mdir+' - ' +mfile,nil);
                                     ImportFile2(TDynSiteForm(mSite).BaseObjectSpace, mfilename, mdir,mfile,msite,true,false,index);
                                end;
                     ProgressDispose()   ;
        finally
            mFileList.free;

        end;
  end;



  //TDynSiteForm(mSite).Refreshdata;
  msite.activedataset.RefreshCurrentItem;
  msite.activedataset.RefreshAndRestoreLastSelectedItem;
end;





procedure NewBOUpdate(Sender: TObject);
var
  mSite: TDynSiteForm;
  mObj: TNxCustomBusinessObject;
begin
  //OutputDebugString('Jsem v OnUpdate.');
  //OutputDebugString('Sender je '+Sender.ClassName+'.');
  // Zjistime, zda je Sender typu TComponent
  if Sender is TComponent then begin
    //OutputDebugString('Sender je TComponent.');
    // Vyhledame SiteForm (TSiteForm) na kterem je dana akce
    mSite := TComponent(Sender).DynSite;
    if Assigned(mSite) then begin
      //OutputDebugString('Nalezen nadřízený SiteForm.');

      // akce je k dispozici pouze v pripade, ze je v datasetu nejaky zaznam
      // a v pripade, ze neni zahajena editace
      mObj := mSite.CurrentObject;
      try
        TAction(Sender).Enabled := not mSite.Edit and Assigned(mObj);
      finally
        mObj.Free;
      end;
    end;
  end;
end;





begin
end.
