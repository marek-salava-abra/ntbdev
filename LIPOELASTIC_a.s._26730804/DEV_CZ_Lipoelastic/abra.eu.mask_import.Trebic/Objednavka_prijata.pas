uses 'abra.eu.mask_import.Trebic.lib';

procedure ZpracujSouborZFronty (OS: TNxCustomObjectSpace; var ProcessContinue: Boolean; Directory: string; FileName: string;msite:TDynSiteForm);
begin
  ProcessContinue := ImportFile2(OS, Directory + '\' + FileName,Directory,filename,msite,False,false,0);
end;




function ImportFile2(OS: TNxCustomObjectSpace; AFileName: string;directory: string;filename: string;msite:TDynSiteForm;rucne:boolean;chyba:boolean;index:Integer) : Boolean;
var
mID_Docqueue_iD,mID_Store_iD:string;
mObchodniPripad,mdivision_id:string;
mstore_id:string;
mBustransaction_ID:string;
mfind_string:string;
mr,mx,mrsa,mxax:tstringlist;
mStoreCard_ID:string;
mBO_adress,mBO_Sarze,mBO_PohybSarze:TNxCustomBusinessObject;
mAdress_id:string;
mi_result:integer;
mMon:TNxCustomBusinessMonikerCollection;
mstorecard_text:string;
mbo_docqueue:TNxCustomBusinessObject;
mQunit:string;
mPacName:string;
mabraqunit:string;
mTyp_Eshopu,MID_SARZE:string;
begin
    if not FileExists(AFileName) then begin
      Result := False;
      exit;
    end else begin

    try
      mXMLHead := TNxScriptingXMLWrapper.Create;
        mXMLHead.loadFromFile(AFileName);


        mexistuje:='';
      if mXMLHead.getElementAsString('ABRADocument.ExternalNumber')<>'' then begin
            if not(ErrtElementString(mXMLHead ,'ABRADocument.ExternalNumber') and (index=2)) then
                mexistuje:=getIDfromfield(os,'ID','ReceivedOrders','ExternalNumber',mXMLHead.getElementAsString('ABRADocument.ExternalNumber'),'','');
      end;
          mID_Division:='1300000101';
          mID_Docqueue_ID:= '1U10000101';
          mID_odberatel:= '7F26300101';
          mstore_id:='1M00000101';
        mHead := TNxHeaderBusinessObject(OS.CreateObject('01CPMINJW3DL342X01C0CX3FCC'));
        try
                if ((nxisemptyoid(mexistuje)) or ( msite.CompanyCache.GetUserID='SUPER00000')) then begin
                      if ((msite.CompanyCache.GetUserID='SUPER00000') and (rucne)) then NxShowSimpleMessage('Doklad již existuje - prosím zmažte',nil);
                      mHead.New;
                      mHead.Prefill;
                      //if rucne and chyba then NxShowSimpleMessage('Novy',nil);
                      mHead.SetFieldValueAsString('DocQueue_ID', mID_Docqueue_ID);
                      mHead.SetFieldValueAsString('Firm_ID', mID_odberatel);
                      if not(ErrtElementString(mXMLHead ,'ABRADocument.ExternalNumber') and (index=2)) then
                              mHead.SetFieldValueAsString('ExternalNumber',mXMLHead.getElementAsString('ABRADocument.ExternalNumber'));
                      //if msite.CompanyCache.GetUserID='SUPER00000' then NxShowSimpleMessage('Hlavička v pořádku',nil);



                       for i := 0 to mXMLHead.getElementsCountInArray('AbraDocument.Rows.Row') - 1 do begin
                                          mRow := mHead.Rows.AddNewObject;
                                          mRow.Prefill;
                                          mStoreCard_ID:='';
                                          mstorecard_text:='';

                                            mRow.SetFieldValueAsInteger('PosIndex',i);
                                                    mRow.SetFieldValueAsInteger('RowType',3);

                                                    mRow.SetFieldValueAsString('Store_ID',mstore_id);


                                                    mStoreCard_ID:='';
                                                        mstorecard_text:='';
                                                         if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.EAN') and (index=2)) then begin
                                                                if (mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.EAN')<>'') then begin
                                                                         mr:=tstringlist.create;
                                                                          try
                                                                              msite.BaseObjectSpace.SQLSelect(format('select sc.id||su.code from STOREEANS SE left join StoreUnits SU on SU.id=se.Parent_id left join Storecards SC on sc.id=su.parent_id where ((se.EAN=%s ) or (sc.EAN=%s )) and (sc.hidden=%s)',
                                                                              [quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.EAN')),quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.EAN')),QuotedStr('N')]),mr);

                                                        //NxShowSimpleMessage('Hledání skladové karty v počtu ' + inttostr(mr.count),nil);
                                                                                   if mr.count=0 then begin
                                                                                       //mstorecard_text:=mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.Ean') + ' - ' + mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Commodity.Name');

                                                                                       mStoreCard_ID:='3NQ1000101';
                                                                                       mQunit:='ks';
                                                                                   end else begin
                                                                                       mStoreCard_ID:=copy(

                                                                                        ReplaceStr(mr.Strings[0],'"',''),1,10);
                                                                                       mQunit:=copy(ReplaceStr(mr.Strings[0],'"',''),11,5);

                                                                                      // nxShowSimpleMessage(copy(mr.Strings[0],1,10),nil);

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
                                                          if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].Quantity') and (index=2)) then
                                                                mRow.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Quantity'))); //text bude  ...
                                                          //mRow.SetFieldValueAsstring('QUnit',mQunit);




                                                        // mabraqunit :='';
                                                        // mr:=tstringlist.create;
                                                        // try
                                                        //      msite.BaseObjectSpace.SQLSelect('SELECT ID FROM DefRollData A WHERE A.CLSID = ''TE4DZNKNND34R3SQOPGPEE1TU4'' and code=' + quotedstr(mQunit),mr) ;
                                                        //      if mr.count>0 then begin
                                                        //         mAbraQunit:=copy(mr.Strings[0],1,10);
                                                        //      end;
                                                        // finally
                                                        //    mr.free;
                                                        // end;

                                                mRow.SetFieldValueAsString('Division_ID',mID_Division); //text bude  ...


                                                if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].X_ProvideRow_ID') and (index=2)) then
                                                      mRow.SetFieldValueAsString('X_ProvideRow_ID',mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].X_ProvideRow_ID'));


                                                     //    mr:=tstringlist.create;
                                                     //    try
                                                     //         msite.BaseObjectSpace.SQLSelect('SELECT ID FROM Vatrates A WHERE a.Tariff=' + quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].VATRate')),mr) ;
                                                     //         if mr.count>0 then begin
                                                     //            mRow.SetFieldValueAsString('VatRate_ID',copy(mr.Strings[0],1,10));
                                                     //            NxShowSimpleMessage(copy(mr.Strings[0],1,10),nil);
                                                     //         end;
                                                     //    finally
                                                     //       mr.free;
                                                     //    end;



                                                           if not NxIsEmptyOID((mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))) then begin
                                                                             mBustransaction_ID:=(mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'));
                                                                             mRow.SetFieldValueAsString('BusTransaction_id',mBustransaction_ID );
                                                           end;


                                                            // šarže
                                                            for ii := 0 to mXMLHead.getElementsCountInArray('AbraDocument.Rows.Row.Batches.Batch') - 1 do begin
                                                                          mr:=tstringlist.create;
                                                                           // dohledání pohybu šarže
                                                                           try
                                                                                msite.BaseObjectSpace.SQLSelect('SELECT a.ID FROM DefRollData A left join StoreBatches b on b.id=a.X_Batches where b.name=' + quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].name')) + ' and A.CLSID = ' +
                                                                                quotedstr('SLARSB0H4CK4T32XPZTP33J3XS') + ' and a.X_Parent2_ID=' + quotedstr(mrow.oid),mr) ;
                                                                                if mr.count>0 then begin
                                                                                  // NxShowSimpleMessage('Pohyb Šarže nalezen',nil);
                                                                                  // NxShowSimpleMessage(copy(mr.Strings[0],1,10),nil);

                                                                                end else begin
                                                                                       // dohledání šarže
                                                                                           mx:=tstringlist.create;
                                                                                           try
                                                                                                msite.BaseObjectSpace.SQLSelect('SELECT ID FROM StoreBatches A WHERE name=' + quotedstr(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].name')),mx);
                                                                                                if mx.count=0 then begin
                                                                                                    //NxShowSimpleMessage(copy(mx.Strings[0],1,10),nil);
                                                                                                    // založení šarže
                                                                                                     mBO_Sarze:=msite.BaseObjectSpace.CreateObject('C32QXZWCTVDL342W01C0CX3FCC');
                                                                                                     try
                                                                                                           mID_Sarze:='';
                                                                                                           mBO_Sarze.new;
                                                                                                           mBO_Sarze.Prefill;
                                                                                                           mBO_Sarze.SetFieldValueAsString('StoreCard_ID',mStoreCard_ID);
                                                                                                           mBO_Sarze.SetFieldValueAsString('Name',mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].name'));
                                                                                                           mBO_Sarze.SetFieldValueAsString('Specification',mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].Specification'));
                                                                                                           mBO_Sarze.SetFieldValueAsBoolean('SerialNumber',False);
                                                                                                           //mBO_Sarze.SetFieldValueAsDateTime('ProductionDate$DATE',now) ;
                                                                                                           //mBO_Sarze.SetFieldValueAsDateTime('ExpirationDate$Date',NxIncDate(Now,mBO_Sarze.GetFieldValueAsInteger('StoreCard_ID.ExpirationDue'),0,0)) ;   //1096

                                                                                                           mBO_Sarze.Save;
                                                                                                           mID_Sarze:=mBO_Sarze.oid;
                                                                                                     finally
                                                                                                          mBO_Sarze.free;
                                                                                                     end;









                                                                                                end;
                                                                                           finally
                                                                                              mx.free;
                                                                                           end;
                                                                                          // založení pohybu šarže

                                                                                           mBO_PohybSarze:=msite.BaseObjectSpace.CreateObject('SLARSB0H4CK4T32XPZTP33J3XS');
                                                                                           try
                                                                                                  mBO_PohybSarze.new;
                                                                                                  mBO_PohybSarze.Prefill;
                                                                                                  mBO_PohybSarze.SetFieldValueAsFloat('X_quantity',NxIBStrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].quantity')));
                                                                                                  mBO_PohybSarze.SetFieldValueAsstring('Code',mhead.OID);
                                                                                                  mBO_PohybSarze.SetFieldValueAsstring('X_Parent_ID',mrow.OID);
                                                                                                  mBO_PohybSarze.SetFieldValueAsstring('X_Parent2_ID',mStoreCard_ID);
                                                                                                  mBO_PohybSarze.SetFieldValueAsstring('X_Batches',mID_Sarze);
                                                                                                  mBO_PohybSarze.SetFieldValueAsstring('Name', copy(mrow.GetFieldValueAsString('Storecard_ID.name') + mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].name'),1,40));
                                                                                                  //mBO_PohybSarze.SetFieldValueAsstring('Code',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.Code'));


                                                                                                  if mBO_PohybSarze.getFieldValueAsFloat('X_quantity')>0 then mBO_PohybSarze.save;
                                                                                                  //NxShowSimpleMessage('pohyb šarže',nil);
                                                                                           finally
                                                                                               mBO_PohybSarze.free;
                                                                                           end;
                                                                                end;
                                                                           finally
                                                                              mr.free;
                                                                           end;



                                                                    //NxShowSimpleMessage(
                                                                    //mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Batches.Batch['+inttostr(ii)+'].name'),
                                                                    //nil);

                                                            end;


                       end;    // cyklus řádků








                              if rucne then begin
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
                                         mSite.ShowDynFormWithNewDocument('O2XDU14IW3DL342X01C0CX3FCC', mSite.SiteContext, mhead);
                                         mhead.refresh;
                                        msite.ActiveDataSet.RefreshCurrentItemMode;
                              end else begin
                                        mhead.Save;
                                        mhead.refresh;
                                        msite.ActiveDataSet.RefreshCurrentItemMode;
                                        if rucne then NxShowSimpleMessage('Objednávka ' + mhead.GetFieldValueAsstring('Docqueue_ID.code') + '-' + inttostr(mhead.GetFieldValueAsinteger('Ordnumber')) + '/' +
                                                 mhead.GetFieldValueAsstring('Period_ID.code') + ' byla vytvořena',nil);
                                        result:=nxcopyfile(AFileName,Directory + '\Zpracovane\' + FileName);

                                        if result then begin
                                            DeleteFile(AFileName);
                                            if rucne and result and chyba then begin
                                                   NxShowSimpleMessage('Soubor ' + afilename + ' byl přesunut do zpracovaných',nil);
                                            end;
                                        end;
                              end;





                    end else begin
                        if rucne then NxShowSimpleMessage('Doklad již existuje',nil);
                    end;
                end;
            finally
                 mhead.free;
            end;
     finally
      mXMLHead.Free;
     end;
    Result := True;

end;
end;



begin
end.