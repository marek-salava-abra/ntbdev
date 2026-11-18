uses  '_Knihovny_ALL.Progress',
       '_Knihovny_ALL.XML',
       'abra.eu.Hromadny_dobropisPR.Libs',
      '_Knihovny_ALL.Parse',
      'Synchronizace.API' ,
      'Synchronizace.Query_DefrollData';






const

mTable='DefRollData';
mApiTable='TMP';
var
mQuery:string;


var
     mBookmark : TBookmarkList;
     index:integer;



function CreateAllDocFromWorkListImportv1(msite:tSiteform;mCLSIDInput:string;mCLSIDOuput:string;mAgenda:string;mDocqueue_ID:string;mFirm_id:string;mDivision_ID:string;mStore_ID:string;mDocList:tstringlist;mRowList:tstringlist;index:integer;mbatchlist:tstringlist;mBatchworklist:tstringlist):string;
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
  mBOVratka,mDefRoll,mBillOfDeliveryRowBO,mDocRowBatch,mRowBO:TNxCustomBusinessObject;
  mpocet:double;
  mRowPocet:double;
  mxpomoc:double;
  mOdebraniSluzeb:true;
  mduvod:string;
  mSluzby:string;
  mSDuvod:string;
  mbankAccount_ID:string;
begin
  mOS := msite.BaseObjectSpace;
  try
      msave:=false;
       mImportMan := NxCreateDocumentImportManager(mOS, Class_IssuedInvoice, Class_IssuedCreditNote);
      mInputParams := TNxParameters.Create;
      try


                //NxShowSimpleMessage(mRowList.Text,nil);   // *** smazat ***
        //mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedRows');
        //mParam.AsString := mRowList.Text;


        //mParam := mInputParams.GetOrCreateParam(dtBoolean, 'DoNotImportRowTypeText');
        //mParam.AsBoolean := True;
        mParam := mInputParams.GetOrCreateParam(dtBoolean, 'DoNotImportChargesSerialNumbers');
        mParam.AsBoolean := True;


        mParam := mInputParams.GetOrCreateParam(dtString, 'DocQueue_ID');
        if index<>1 then begin
            mParam.AsString := mDocqueue_ID_DFV;
        end else begin
            mParam.AsString := '1B10000101';
        end;

        mParam := mInputParams.GetOrCreateParam(dtString, 'StoreDocQueue_ID');
        mParam.AsString := mDocqueue_ID_VRDL;

         for mIDoc:=0 to mDocList.count-1 do begin
            if mShowDebug then NxShowSimpleMessage('Dokladů ' + inttostr(mdoclist.count)  + ' - ' + mdoclist.Strings[0],nil);
                 if mIDoc=0 then begin
                      mParam := mInputParams.GetOrCreateParam(dtString, 'SelectedHeader');
                      mParam.AsString := mDocList.strings[mIDoc];
                 end;

             mImportMan.AddInputDocument(mDocList.Strings[mIDoc]);
        end;

        mImportMan.LoadParams(mInputParams);

        mImportMan.Execute;

        mImportMan.AfterExecuteFromOLE;
        mfirm_ID:= mImportMan.InputDocuments[0].getFieldValueAsString('Firm_ID');

        if index<>1 then begin
            mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', mDocqueue_ID_DFV ); // musi byt...          '2781000101'
        end else begin
            mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', '1B10000101' ); // musi byt...          '2781000101'

        end;






          mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID', mfirm_ID);
          mImportMan.OutputDocument.SetFieldValueAsDateTime('Docdate$date', TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsDateTime('X_ABRADate'));
          mImportMan.OutputDocument.SetFieldValueAsString('StoreDocQueue_ID', mDocqueue_ID_VRDL); // musi byt...
          //NxShowSimpleMessage('CC',nil);
          mImportMan.OutputDocument.SetFieldValueAsinteger('Acknowledge',0); // musi byt...
        //  mImportMan.OutputDocument.SetFieldValueAsString('ReasonDescription', 'Vraceni'); // musi byt...
       // NxShowSimpleMessage('dd',nil);




        if Assigned(mImportMan.OutputDocument) then begin
                 mRowsOutput := mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
                       for xx:=0 to mRowsOutput.Count-1 do begin
                           mRowsOutput.BusinessObject[xx].SetFieldValueAsBoolean('X_MArkForDelete',True);
                       end;


                        if mShowDebug then NxShowSimpleMessage('Importovano radků ' + inttostr(mRowsOutput.count),nil);
                        for xx:=0 to mRowsOutput.Count-1 do begin
                                    mRowBO:=mRowsOutput.BusinessObject[xx];
                                    mrowpocet:=0;
                                 mFind:=false;
                                 for xxx:=0 to mBatchworklist.Count-1 do begin


                                   if (mRowsOutput.BusinessObject[xx].GetFieldValueAsString('RSource_ID')=copy(mBatchworklist.Strings[xxx],21,10))  then begin
                                      if mShowDebug then NxShowSimpleMessage('Nalezeno:  ' + mRowsOutput.BusinessObject[xx].GetFieldValueAsString('RSource_ID')+' = ' + mRowList.Strings[xxx],nil);
                                       if (trim(copy(mBatchworklist.Strings[xxx],81,10))='') or (trim(copy(mBatchworklist.Strings[xxx],81,10))='0000000000') then begin
                                          mRowBO.SetFieldValueAsstring('Store_ID',mCstore_ID);
                                       end else begin
                                          mRowBO.SetFieldValueAsstring('Store_ID',copy(mBatchworklist.Strings[xxx],81,10)) ;
                                       end;


                                             mpocet:=0  ;
                                             mpocet:=  NxIBStrToFloat(copy(trim(mBatchworklist.Strings[xxx]),101,10));
                                             mrowpocet:=mrowpocet + mpocet;
                                            // NxShowSimpleMessage(NxFloatToIBStr(mRowBO.getFieldValueAsFloat('Quantity')) + ' / ' + NxFloatToIBStr(mpocet),nil);
                                             mRowsOutput.BusinessObject[xx].SetFieldValueAsstring('X_bname',copy(mBatchworklist.Strings[xxx],91,10));



                                             //try
                                             //  mxpomoc:=0;
                                             //  mxpomoc:=  mOS.SQLSelectFirstAsExtended('Select max(SSC.quantity) from StoreSubCards SSC where SSC.Store_ID=' + quotedstr(mRowBO.GetFieldValueAsstring('Store_ID'))
                                             //                                  + ' AND SSC.StoreCard_ID=' + quotedstr(mRowBO.GetFieldValueAsstring('StoreCard_ID')) ) ;
                                             //  if mxpomoc<mpocet then begin
                                             //         mpocet:=0;
                                             //  end;

                                             //finally

                                             //end;
                                             mRowsOutput.BusinessObject[xx].SetFieldValueAsFloat('Quantity',mrowpocet);

                                             if mrowpocet=0 then begin
                                                 //  mRowBO.Markfordelete;
                                             end else begin
                                                   msave:=true;
                                             end;

                                        mRowsOutput.BusinessObject[xx].SetFieldValueAsBoolean('X_MArkForDelete',False);

                                      mbankAccount_ID:='';
                                      try
                                          mbankAccount_ID:= mos.SQLSelectFirstAsstring('select X_PL_Nazev from DefRollData WHERE (Hidden = ''N'' ) AND (CLSID = ''45D1XVW5EY24JBXTOE01EHYRSG'' ) AND (id= '
                                                                        + quotedstr(mRowsOutput.BusinessObject[xx].GetFieldValueAsString('X_bname')) + ')');

                                          if mbankAccount_ID<>'' then begin
                                             mImportMan.OutputDocument.SetFieldValueAsString('FirmBankAccount_ID', mbankAccount_ID);
                                          end;

                                      finally

                                      end;





                                      mduvod:='RZDO300101';

                                      try
                                          mduvod:= mos.SQLSelectFirstAsstring('select X_ParamValue from DefRollData WHERE (Hidden = ''N'' ) AND (CLSID = ''45D1XVW5EY24JBXTOE01EHYRSG'' ) AND (id= '
                                                                        + quotedstr(mRowsOutput.BusinessObject[xx].GetFieldValueAsString('X_bname')) + ')');

                                      finally

                                      end;




                                                mRowsOutput.BusinessObject[xx].SetFieldValueAsstring('X_Duvod_Vraceni',mduvod);
                                                if mSDuvod<>'' then begin
                                                        if not NxIsEmptyOID(mRowsOutput.BusinessObject[xx].getFieldValueAsstring('X_Duvod_Vraceni')) then begin
                                                           mSDuvod:= mRowsOutput.BusinessObject[xx].getFieldValueAsstring('X_Duvod_Vraceni.Name')
                                                        end;
                                                end;

                                            mRowsOutput.BusinessObject[xx].SetFieldValueAsBoolean('X_MArkForDelete',False);
                                      mRowsOutput.BusinessObject[xx].validate;
//                                       msave:=true;
                                       mFind:=true;
                                       //NxShowSimpleMessage('Ponechání zboží ' + mRowsOutput.BusinessObject[xx].getFieldValueAsString('StoreCard_ID.Name'),nil);



                                   end;


                             end;

                        end;

   end;

             // zkontroluje , zda odebírá i zboží
             mOdebraniSluzeb:=False;
             mSluzby:='A';
             mRowsOutput := mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
             for xx:=0 to mRowsOutput.Count-1 do begin
                 if mRowsOutput.BusinessObject[xx].GetFieldValueAsBoolean('X_MarkForDelete') then begin
                    if (copy(mRowsOutput.BusinessObject[xx].getFieldValueAsString('StoreCard_ID.StoreCardCategory_ID.code'),1,2)<>'Px') then begin
                       mRowsOutput.BusinessObject[xx].MarkForDelete;
                       //NxShowSimpleMessage('Odebírám zboží ' + mRowsOutput.BusinessObject[xx].getFieldValueAsString('StoreCard_ID.Name'),nil);
                       mOdebraniSluzeb:=True;
                       mSluzby:='N';
                    end else begin
                          // mRowsOutput.BusinessObject[xx].SetFieldValueAsinteger('ESLStatus',1);
                          //                      mRowsOutput.BusinessObject[xx].SetFieldValueAsBoolean('ToIntrastat',True);
                          //                       mRowsOutput.BusinessObject[xx].SetFieldValueAsstring('VATIndex_ID','1T00000000');
                          //                       mRowsOutput.BusinessObject[xx].SetFieldValueAsstring('X_Duvod_Vraceni','TZX1100101');

                         if mSluzby='N' then begin
                               //NxShowSimpleMessage('XX_'+copy(mRowsOutput.BusinessObject[xx].getFieldValueAsString('StoreCard_ID.StoreCardCategory_ID.code'),1,2)+'_XX' ,nil);
                               //mRowsOutput.BusinessObject[xx].MarkForDelete;
                         end;
                    end;
                 end;
             end;


         // pokud odebere zboží , odstraní i službové řádky
         mRowsOutput := mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
         if false then begin
            for xx:=0 to mRowsOutput.Count-1 do begin
                 if mRowsOutput.BusinessObject[xx].GetFieldValueAsBoolean('X_MarkForDelete') then begin
                    if (copy(mRowsOutput.BusinessObject[xx].getFieldValueAsString('StoreCard_ID.StoreCardCategory_ID.code'),1,2)='Px') then begin


                    end;
                 end;
             end;
              NxShowSimpleMessage('Odebírám služby ' ,nil);
         end;














         if msave then begin

                                     //mImportMan.OutputDocument.SetFieldValueAsString('Country_ID','00000CZ000');
                                     //if true then begin

                                      mImportMan.OutputDocument.ClearValidateErrors;
                                    if true then begin
                                    // if Not  mImportMan.OutputDocument.Validate() then begin
                                     //         mValidateList := TStringList.Create;
                                     //             try
                                     //                mImportMan.OutputDocument.GetValidateErrors(mValidateList);
                                     //                mText := mValidateList.Text;
                                     //                NxToken(mText, '=');
                                     //                MessageDlg('Automaticky vytvořený doklad nelze uložit z těchto důvodů:' + #13#10 + mText,
                                     //
                                     //                mtWarning, [mbOK], 0);
                                     //              finally
                                     //                mValidateList.Free;
                                     //              end;
                                     //              //NxShowSimpleMessage('Chyba',nil);
                                    //               TDynSiteForm.ShowDynFormWithNewDocument('T1C2EX0BUJD13ACP03KIU0CLP4', TDynSiteForm(mSite).SiteContext, mImportMan.OutputDocument);
                                    //               result:='Chyba :' + mtext;
                                    // end else begin
                                    try
                                        mImportMan.OutputDocument.Save;


                                           //if mShowDebug then
//                                           NxShowSimpleMessage('Byl vytvořen doklad ' + mImportMan.OutputDocument.DisplayName,nil);
                                           result:=mImportMan.OutputDocument.oid;

                                         // NxShowSimpleMessage('Bpo exitu ' + mImportMan.OutputDocument.DisplayName,nil);

                                          mvratka:=tstringlist.create;

                                          try
                                          mRowsOutput := mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
                                                      //NxShowSimpleMessage('Importovano radků ' + inttostr(mRowsOutput.count),nil);
                                                      //for xxx:=0 to mRowList.Count-1 do begin
                                                            for xx:=0 to mRowsOutput.Count-1 do begin
                                                                 try
                                                                     mi:=mos.SQLExecute('Update DefRollData set X_CZ_Nazev=' + quotedstr(mRowsOutput.BusinessObject[xx].oid) + ' WHERE (Hidden = ''N'' ) AND (CLSID = ''45D1XVW5EY24JBXTOE01EHYRSG'' ) AND (id= '
                                                                        + quotedstr(mRowsOutput.BusinessObject[xx].GetFieldValueAsString('X_bname')) + ')');


                                                                 finally

                                                                 end;

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


                                                      //mImportMan.OutputDocument.Delete;


                                                      // dobropis smazán , uvolněny šarže


                                             if mVratka.count>0 then begin
                                                mBOVratka:=msite.BaseObjectSpace.CreateObject('1T0I5SAOS3DL3ACU03KIU0CLP4');
                                                   mDefRoll:= msite.BaseObjectSpace.CreateObject('45D1XVW5EY24JBXTOE01EHYRSG');
                                                   try
                                                        for i:=0 to mVratka.count-1 do begin   // doklad
                                                            if (mVratka.Strings[i])<>'0000000000' then begin
                                                            try
                                                            mBOVratka.load(mVratka.Strings[i],nil);
                                                                  mRows := mBOVratka.GetLoadedCollectionMonikerForFieldCode(mBOVratka.GetFieldCode('Rows'));
                                                                      for xx:=0 to mrows.count-1 do begin   // řádek
                                                                           mRowBO:=mRows.BusinessObject[xx];
                                                                           if mRowBO.GetFieldValueAsinteger('rowtype')=3 then begin   // skladový řádek
                                                                              //mpocet:=0;
                                                                              //mpocet:= NxIBStrToFloat(TBusRollSiteForm(msite).BaseObjectSpace.SQLSelectFirstAsString('select max(quantity) from IssuedCreditNotes2 where ProvideRow_ID=' + quotedstr(mRowBO.oid)));
                                                                              //if  mpocet<> mRowBO.GetFieldValueAsinteger('quantity') then begin
                                                                              //     mRowBO.SetFieldValueAsFloat('quantity',mpocet);   // skladový řádek
                                                                              //end;

                                                                                   if mRowBO.GetFieldValueAsinteger('StoreCard_ID.category')=2 then begin
                                                                                          mpocet:=0;

                                                                                          mMonBatches :=  mRowBO.GetLoadedCollectionMonikerForFieldCode(mRowBO.GetFieldCode('DocRowBatches'));
                                                                                              mFind:=false;
                                                                                         for yyy:=0 to mbatchworklist.count-1 do begin
                                                                                                  for xxx := 0 to mMonBatches.Count - 1 do begin
                                                                                                            if  (mMonBatches.BusinessObject[xxx].GetFieldValueAsstring('Parent_ID.RDocumentRow_ID')= copy(mbatchworklist.strings[yyy],51,10)) and
                                                                                                                 (mMonBatches.BusinessObject[xxx].GetFieldValueAsstring('StoreBatch_ID')= copy(mbatchworklist.strings[yyy],71,10)) then begin
                                                                                                                 // správná doklad a správná šarže
                                                                                                                   mFind:=true;
                                                                                                                 mDefRoll.load(copy(mbatchworklist.strings[yyy],91,10),nil);
                                                                                                                      mpocet:=0;
                                                                                                                      mpocet:=mMonBatches.BusinessObject[xxx].GetFieldValueAsFloat('Quantity')+ NxIBStrToFloat(copy(trim(mbatchworklist.strings[yyy]),101,10));
                                                                                                                      //if mDefRoll.GetFieldValueAsFloat('X_vychystano')<=mMonBatches.BusinessObject[xxx].getFieldValueAsFloat('Quantity') then begin
                                                                                                                          //mMonBatches.BusinessObject[xxx].setFieldValueAsFloat('Quantity',mDefRoll.GetFieldValueAsFloat('X_vychystano'));

                                                                                                                          mMonBatches.BusinessObject[xxx].setFieldValueAsFloat('Quantity',mpocet);
                                                                                                                          //mDefRoll.GetFieldValueAsFloat('X_vychystano'));
                                                                                                                          if not NxIsBlank(mDefRoll.GetFieldValueAsString('X_Store_ID')) then
                                                                                                                          //mrows.BusinessObject[xx].SetFieldValueAsString('Store_ID',mDefRoll.GetFieldValueAsString('X_Store_ID'));
                                                                                                                         // mrows.BusinessObject[xx].setFieldValueAsFloat('Quantity',(mrows.BusinessObject[xx].getFieldValueAsFloat('Quantity')-mpocet));

                                                                                                                         mDefRoll.setFieldValueAsFloat('X_dodano',mDefRoll.getFieldValueAsFloat('X_dodano') + mMonBatches.BusinessObject[xxx].getFieldValueAsFloat('Quantity'));
                                                                                                                         mDefRoll.setFieldValueAsstring('X_SK_Nazev',mRowBO.oid);


                                                                                                                         mDefRoll.SetFieldValueAsString('X_EN_nazev',mMonBatches.BusinessObject[xxx].OID);
                                                                                                                      //   NxShowSimpleMessage('Defrool save', nil);
                                                                                                                         mDefRoll.save;
                                                                                                                       //end else begin
                                                                                                                       //  mpocet:=0;
                                                                                                                      //mpocet:=mMonBatches.BusinessObject[xxx].GetFieldValueAsFloat('Quantity')+ NxIBStrToFloat(copy(trim(mbatchworklist.strings[yyy]),101,10));
                                                                                                                      //   mMonBatches.BusinessObject[xxx].setFieldValueAsFloat('Quantity',mpocet);
                                                                                                                          //mrows.BusinessObject[xx].setFieldValueAsFloat('Quantity',(mrows.BusinessObject[xx].getFieldValueAsFloat('Quantity')-mpocet));
                                                                                                                      //    if not NxIsBlank(mDefRoll.GetFieldValueAsString('X_Store_ID')) then
                                                                                                                          //mrows.BusinessObject[xx].SetFieldValueAsString('Store_ID',mDefRoll.GetFieldValueAsString('X_Store_ID'));
                                                                                                                      //    mDefRoll.SetFieldValueAsString('X_EN_nazev',mMonBatches.BusinessObject[xxx].OID);
                                                                                                                      //    mDefRoll.setFieldValueAsFloat('X_dodano',mMonBatches.BusinessObject[xxx].getFieldValueAsFloat('Quantity'));
                                                                                                                        //  NxShowSimpleMessage('Defrool save', nil);
                                                                                                                     //     mDefRoll.save;

                                                                                                                     // end;
                                                                                                            end;
                                                                                                  end;
                                                                                             if not mFind then begin
                                                                                                if  (mRowBO.GetFieldValueAsstring('RDocumentRow_ID')= copy(mbatchworklist.strings[yyy],51,10)) then begin
                                                                                                            mDocRowBatch:= mMonBatches.AddNewObject;
                                                                                                                    mDocRowBatch.SetFieldValueAsString('StoreBatch_ID', copy(mbatchworklist.strings[yyy],71,10)) ;
                                                                                                                    //mDocRowBatch.SetFieldValueAsFloat('Quantity', mDS.FieldByName('ToReturn').AsFloat);

                                                                                                                    mDefRoll.load(copy(mbatchworklist.strings[yyy],91,10),nil);


                                                                                                                         // if mDefRoll.GetFieldValueAsFloat('X_vychystano')<=mDocRowBatch.getFieldValueAsFloat('Quantity') then begin
                                                                                                                              //mMonBatches.BusinessObject[xxx].setFieldValueAsFloat('Quantity',mDefRoll.GetFieldValueAsFloat('X_vychystano'));
                                                                                                                              mpocet:=0;
                                                                                                                                 mpocet:=NxIBStrToFloat(copy(trim(mbatchworklist.strings[yyy]),101,10));
                                                                                                                              mDocRowBatch.setFieldValueAsFloat('Quantity',mpocet);
                                                                                                                              //if not NxIsBlank(mDefRoll.GetFieldValueAsString('X_Store_ID')) then
                                                                                                                              //mrows.BusinessObject[xx].SetFieldValueAsString('Store_ID',mDefRoll.GetFieldValueAsString('X_Store_ID'));
                                                                                                                             // mrows.BusinessObject[xx].setFieldValueAsFloat('Quantity',(mrows.BusinessObject[xx].getFieldValueAsFloat('Quantity')-mpocet));
                                                                                                                             mDefRoll.setFieldValueAsFloat('X_dodano',mDefRoll.getFieldValueAsFloat('X_dodano') + mDocRowBatch.getFieldValueAsFloat('Quantity'));
                                                                                                                             mDefRoll.SetFieldValueAsString('X_EN_nazev',mDocRowBatch.OID);
                                                                                                                             mDefRoll.setFieldValueAsstring('X_SK_Nazev',mRowBO.oid);
                                                                                                                             //NxShowSimpleMessage('Defrool save new', nil);
                                                                                                                             mDefRoll.save;
                                                                                                                           //end else begin
                                                                                                                             //mMonBatches.BusinessObject[xxx].setFieldValueAsFloat('Quantity',mDefRoll.GetFieldValueAsFloat('X_vychystano'));
                                                                                                                             // mpocet:=0;
                                                                                                                              //mpocet:=mDocRowBatch.GetFieldValueAsFloat('Quantity')+ NxIBStrToFloat(copy(trim(mbatchworklist.strings[yyy]),101,10));
                                                                                                                              //mrows.BusinessObject[xx].setFieldValueAsFloat('Quantity',mpocet);
                                                                                                                              //if not NxIsBlank(mDefRoll.GetFieldValueAsString('X_Store_ID')) then
                                                                                                                              //mrows.BusinessObject[xx].SetFieldValueAsString('Store_ID',mDefRoll.GetFieldValueAsString('X_Store_ID'));
                                                                                                                              //mDefRoll.SetFieldValueAsString('X_EN_nazev',mDocRowBatch.OID);
                                                                                                                              //mDefRoll.setFieldValueAsFloat('X_dodano',mDocRowBatch.getFieldValueAsFloat('Quantity'));
                                                                                                                              //NxShowSimpleMessage('Defrool save new 2', nil);
                                                                                                                              //mDefRoll.save;
                                                                                                                          //end;
                                                                                                end;
                                                                                             end;
                                                                                             mfind:=false;
                                                                                         end;

                                                                                   end;


                                                                           end;
                                                                         mRowBO.validate;
                                                                      end;
                                                              mBOVratka.SetFieldValueAsString('Description',mSDuvod);
                                                              mImportMan.OutputDocument.SetFieldValueAsString('ReasonDescription', mSDuvod); // musi byt...


                                                            //mBOVratka.ClearValidateErrors;
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
                                                                               //TDynSiteForm.ShowDynFormWithNewDocument('BL0I5SAOS3DL3ACU03KIU0CLP4', TBusRollSiteForm(mSite).SiteContext, mBOVratka);
                                                                               //result:='Chyba';
                                                                        end else begin
                                                                             mBOVratka.save;
                                                                             //NxShowSimpleMessage('Doklad uložen',nil);
                                                                             //result:=mImportMan.OutputDocument.oid;

                                                                       end;
                                                                  finally

                                                                  end;
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
                                       finally
                                      //  mImportMan.Free;
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
   //result:='ok';
end;






     procedure CreateDocumentImportV1(Sender: TAction; Index: integer);
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
  mBatchWorklist,mReturnList:tstringlist;
  mFilter:string;
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
if index=1 then begin
  mDocqueue_ID:='1B10000101';
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
    mReturnList:=TStringList.create;
    try
                      if mBookmark.count=0 then begin
                       if index=5 then begin
                                    TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsFloat('X_dodano',0);
                                    TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_EN_NAZEV','');
                                    TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_CZ_Nazev','');
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

                                                   if (index=0) or (index=1) then begin
                                                       mstring:='';
                                                       mstring:= CreateAllDocFromWorkListImportv1(msite,'01CPMINJW3DL342X01C0CX3FCC','CDMK5QAWZZDL342X01C0CX3FCC',mAgenda,mDocqueue_ID,mFirm_id,mDivision_ID,mStore_ID,mDocList,mRowList,index,mbatchlist,mbatchworklist);
                                                       //if Length(mstring)=10 then begin
                                                             mReturnList.add(mstring);
                                                       //end;
                                                   end;






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
                                if (index=0) or (index=1) then begin
                                    mstring:='';
                                    mstring:= CreateAllDocFromWorkListImportv1(msite,'01CPMINJW3DL342X01C0CX3FCC','CDMK5QAWZZDL342X01C0CX3FCC',mAgenda,mDocqueue_ID,mFirm_id,mDivision_ID,mStore_ID,mDocList,mRowList,index,mbatchlist,mbatchworklist);
                                    if Length(mstring)=10 then begin
                                          mReturnList.add(mstring);
                                    end;
                                end;
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

    try
      mFilter:= '';
                                                         for i:= 0 to mReturnList.Count - 1 do begin
                                                            mFilter:= mFilter + Format('''%s'',', [mReturnList[i]]);

                                                          end;
                                                           if mFilter <> '' then begin
                                                                mFilter:= copy(mFilter, 1, Length(mFilter) - 1);

                                                            end;
                                                        //NxShowSimpleMessage(mfilter,nil);
                                                     // msite.ShowSite('PLC2EX0BUJD13ACP03KIU0CLP4',true,'FilterByUserDynSQLCondition;A.ID in (' + mFilter + ') ');
                                                      ShowSelectedDynForm(msite, mReturnList, 'T1C2EX0BUJD13ACP03KIU0CLP4','Nově vytvořené dobropisy' );

      finally
            NxShowSimpleMessage('Dokončeno', nil);
      end;
mReturnList.free;
end;



procedure Dobropis_eshop(Sender: TAction; Index: integer);
var

  zadej:string;
  msite:TSiteForm;
  mfilter:String;
  mDBGrid : TDBGrid;
 mTabList: TTabSheet;
    mid :string;
    moddelovac:string;
    mOLE, mRoll, mOResult: Variant;
    mOLE1, mRoll1, mOResult1: Variant;
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
  mBO_Temp,mBODocRowBatch:TNxCustomBusinessObject;
  mstringline:string;
  mCountField:integer;
  mstring:string;
  mvalue:TStringList;
  mr,mImportFile:tstringlist;
  mSarze:string;
  mInputString:string;
  mpocet:integer;
  mOldstorecard:string;

 L ,mx: TStringList;
 mPars:TNxParameters;
 mPar:TNxParameter;
 mr2:TStringList;
 mStrings:string;
  mids1:tstringlist;
  mids: TStringList;
  mB:boolean;
  mSelected ,_ss:Variant;
 mBoolean:boolean;
 x:integer;
 mUcet:string;
 mDuvod:string;
 mdatamatrix:string;
 mBOFirmBankaccount:TNxCustomBusinessObject;
 mFirmBankaccount_ID:String;
 mExternalNumber:string;
begin
    mOldstorecard:='Identifikace položky';
    mpocet:=1;
    mSite := NxFindSiteForm(Sender);
        mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu

    mBO_Temp:= msite.BaseObjectSpace.CreateObject('45D1XVW5EY24JBXTOE01EHYRSG');
    mBODocRowBatch:= msite.BaseObjectSpace.CreateObject('K3TH0HR5TZDL342W01C0CX3FCC');
          if index=0 then begin
                  mstring:='';

                  while InputQuery(mOldstorecard, inttostr(mpocet) + ' Šarže' , mstring) do begin
                        //NxShowSimpleMessage(mstring,nil);
                        if mstring<>'' then begin
                               msarze:='';
                               if Length(mstring)>25 then begin
                                          mdatamatrix:='';
                                           mdatamatrix:= DatamatrixDecodeBatches(TBusRollSiteForm(msite).BaseObjectSpace,mstring);
                                                  //NxShowSimpleMessage(mdatamatrix,nil);
                                                  mbatch_ID:='';
                                                  mStoreCard_ID:='';
                                                  mquantity:=0;

                                               //if mdatamatrix<>'' then begin
                                                         mvalue:=tstringlist.create;
                                                               try
                                                                    mvalue:= fnParsevalue(mdatamatrix,';');
                                                                      if mvalue.count>0 then begin

                                                                            if mvalue.count>1 then  mbatch_ID:=mvalue.Strings[2];
                                                                                    //NxShowSimpleMessage(mbatch_ID,nil);
                                                                       end else begin
                                                                           //NxShowSimpleMessage( mstring,nil);

                                                                           mstring:=copy(mstring,23,10);

                                                                       end;
                                                                      // NxShowSimpleMessage(mStoreCard_ID + ' - ' +  mbatch_ID + ' -' + NxFloatToIBStr(mquantity) ,nil);
                                                                finally
                                                                 //  mvalue.free;
                                                                end;
                                               // end;


                               end else begin
                                   mSarze:=mstring;
                               end;


                                   //if ((mSarze<>'') or (mbatch_ID<>'')) then begin
                                         mFirm_ID:='';


                                 mExternalNumber:='';
                                 if InputQuery('Identifikace dokladu' ,'doklad', mExternalNumber)  then begin










                                    //     mRSql:=tstringlist.create;
                                    //     try
                                    //
                                    //            if mbatch_ID='' then begin
                                    //                msite.BaseObjectSpace.SQLSelect('SELECT distinct sd.Firm_ID FROM DocRowBatches DRB join StoreBatches SB on SB.id=DRB.StoreBatch_ID JOIN StoreDocuments2 SD2 ON SD2.ID=DRB.Parent_ID JOIN StoreDocuments SD ON SD.ID=SD2.Parent_ID  '
                                    //                                        + ' WHERE (SD.DocQueue_ID IN (SELECT ID FROM  DocQueues WHERE DocumentType IN (''21'',''23'')) ) AND  '
                                    //                                         + '(sb.name = ' + QuotedStr(mSarze) + ' )',mRSql);
                                    //            end else begin
                                    //                msite.BaseObjectSpace.SQLSelect('SELECT distinct sd.Firm_ID FROM DocRowBatches DRB join StoreBatches SB on SB.id=DRB.StoreBatch_ID JOIN StoreDocuments2 SD2 ON SD2.ID=DRB.Parent_ID JOIN StoreDocuments SD ON SD.ID=SD2.Parent_ID  '
                                    //                                        + ' WHERE (SD.DocQueue_ID IN (SELECT ID FROM  DocQueues WHERE DocumentType IN (''21'',''23'')) ) AND  '
                                    //                                         + '(sb.id = ' + QuotedStr(mbatch_ID) + ' )',mRSql);
                                    //                                          //NxShowSimpleMessage(mbatch_ID,nil);
                                    //            end;
                                    //               //NxShowSimpleMessage(inttostr( mRSql.count),nil);
                                    //            if mRSql.count>1 then begin
                                    //
                                    //                             mOLE := GetAbraOLEApplication;
                                    //                                  mroll := mOLE.GetAgenda('N1C2EX0BUJD13ACP03KIU0CLP4');
                                    //                                  mSelected := mOLE.CreateStrings;
                                    //                                  for i := 0 to mRSql.Count - 1 do begin
                                    //                                         mSelected.Add(mRSql.Strings[i]);
                                    //                                  end;
                                    //                                  if mRSql.Count>1 then begin
                                    //                                          mfirm_id:= mroll.SingleSelectFromSelected2(mSelected, 'Firma:','');
                                    //                                  end;
                                    //
                                    //             end;
                                    //      finally
                                    //          mRSql.free;
                                    //      end;






                                     //mOLE := GetAbraOLEApplication;
                                      //      mroll := mOLE.GetAgenda('N1C2EX0BUJD13ACP03KIU0CLP4');
                                      //      _ss := mOLE.CreateStrings;
                                      //
                                      //         mfirm_id := mroll.SingleSelectFromSelected2(_ss, 'Vyber odběratele', '');


                                             mRSql:=tstringlist.create;
                                             try

                                                   if index=0 then begin
                                                             if mfirm_ID<>'' then begin
                                                                if mbatch_ID='' then begin
                                                                        msite.BaseObjectSpace.SQLSelect('SELECT DRB.id FROM DocRowBatches DRB join StoreBatches SB on SB.id=DRB.StoreBatch_ID JOIN StoreDocuments2 SD2 ON SD2.ID=DRB.Parent_ID JOIN StoreDocuments SD ON SD.ID=SD2.Parent_ID  '
                                                                            + ' WHERE (SD.DocQueue_ID IN (SELECT ID FROM  DocQueues WHERE DocumentType IN (''21'',''23'')) ) AND  '
                                                                              + '(sb.name = ' + QuotedStr(mSarze) + ' ) AND (SD.FIRM_ID= ' + QuotedStr(mfirm_ID) + ' )',mRSql);
                                                                end else begin
                                                                         msite.BaseObjectSpace.SQLSelect('SELECT DRB.id FROM DocRowBatches DRB join StoreBatches SB on SB.id=DRB.StoreBatch_ID JOIN StoreDocuments2 SD2 ON SD2.ID=DRB.Parent_ID JOIN StoreDocuments SD ON SD.ID=SD2.Parent_ID  '
                                                                            + ' WHERE (SD.DocQueue_ID IN (SELECT ID FROM  DocQueues WHERE DocumentType IN (''21'',''23'')) ) AND  '
                                                                              + '(sb.id = ' + QuotedStr(mbatch_ID) + ' ) AND (SD.FIRM_ID= ' + QuotedStr(mfirm_ID) + ' )',mRSql);
                                                                end;
                                                              end else begin

                                                               //msite.BaseObjectSpace.SQLSelect('SELECT DRB.id FROM DocRowBatches DRB join StoreBatches SB on SB.id=DRB.StoreBatch_ID JOIN StoreDocuments2 SD2 ON SD2.ID=DRB.Parent_ID JOIN StoreDocuments SD ON SD.ID=SD2.Parent_ID join receivedorders RO on SD2.Provide_ID=RO.id '
                                                               //             + ' WHERE (SD.DocQueue_ID IN (SELECT ID FROM  DocQueues WHERE DocumentType IN (''21'',''23'')) ) AND  '
                                                               //               + '(sb.name = ' + QuotedStr(mSarze) + ' ) AND (RO.ExternalNumber= ' + QuotedStr(mExternalNumber) + ' )',mRSql);

                                                                msite.BaseObjectSpace.SQLSelect('SELECT DRB.id FROM DocRowBatches DRB join StoreBatches SB on SB.id=DRB.StoreBatch_ID JOIN StoreDocuments2 SD2 ON SD2.ID=DRB.Parent_ID JOIN StoreDocuments SD ON SD.ID=SD2.Parent_ID join IssuedInvoices2 II2 on II2.Provide_ID=SD.id join IssuedInvoices II on II2.Parent_ID=II.id '
                                                                            + ' WHERE (SD.DocQueue_ID IN (SELECT ID FROM  DocQueues WHERE DocumentType IN (''21'',''23'')) ) AND  '
                                                                              + '(sb.name = ' + QuotedStr(mSarze) + ' ) AND ((II.VarSymbol= ' + QuotedStr(mExternalNumber) + ') or (II.ExternalNumber=' + QuotedStr(mExternalNumber) + '))',mRSql);


                                                              end;
                                                   end;


                                                       if mRSql.count=0 then begin
                                                             NxShowSimpleMessage('Pro šarži není možné dohledat pohyb ',nil);
                                                             exit;
                                                       end else begin
                                                             if mRSql.count>1 then begin

                                                                 mOLE := GetAbraOLEApplication;
                                                                      mroll := mOLE.GetAgenda('S1X0KZC0NJE13C5U00CA141B44');
                                                                      mSelected := mOLE.CreateStrings;
                                                                      for i := 0 to mRSql.Count - 1 do begin
                                                                             mSelected.Add(mRSql.Strings[i]);
                                                                      end;
                                                                      if mRSql.Count>1 then begin
                                                                              mstring:= mroll.SingleSelectFromSelected2(mSelected, 'Pohyb šarže:','');
                                                                               if mstring<>'' then begin
                                                                                         mBODocRowBatch.Load(mstring,nil);
                                                                               end;
                                                                      end;
                                                             end else begin
                                                                  mBODocRowBatch.load(mRSql.Strings[0],nil);
                                                             end;

                                                               mBO_Temp.new;
                                                                           mBO_Temp.Prefill;




                                                                               mBO_Temp.SetFieldValueAsfloat('X_ABRADate', trunc(now()));
                                                                               mBO_Temp.SetFieldValueAsString('Code', mBODocRowBatch.GetFieldValueAsString('Parent_ID.StoreCard_ID'));
                                                                               mBO_Temp.SetFieldValueAsString('X_Batches',mBODocRowBatch.GetFieldValueAsString('StoreBatch_ID'));
                                                                               mBO_Temp.SetFieldValueAsString('Name',mBO_Temp.getFieldValueAsString('X_Batches.Name'));
                                                                                mBO_Temp.SetFieldValueAsString('X_firm_ID',mBODocRowBatch.GetFieldValueAsString('Parent_ID.Parent_ID.Firm_ID'));
                                                                                mBO_Temp.SetFieldValueAsString('X_Store_ID',mBODocRowBatch.GetFieldValueAsString('Parent_ID.Store_ID'));

                                                                                mBO_Temp.SetFieldValueAsString('X_storeCard_ID',mBODocRowBatch.GetFieldValueAsString('Parent_ID.StoreCard_ID'));
                                                                                mBO_Temp.SetFieldValueAsString('Code', mBO_Temp.getFieldValueAsString('X_Batches.Name'));
                                                                                mBO_Temp.SetFieldValueAsfloat('X_quantity',1);
                                                                                mBO_Temp.SetFieldValueAsString('X_parent_id',mBODocRowBatch.GetFieldValueAsString('Parent_ID.Parent_ID.ID'));
                                                                                 mBO_Temp.SetFieldValueAsString('X_parent2_id',mBODocRowBatch.GetFieldValueAsstring('Parent_ID'));
                                                                                 mBO_Temp.SetFieldValueAsString('X_DEVENOLUX',mBODocRowBatch.GetFieldValueAsString('Parent_ID.Parent_ID'));
                                                                                 mBO_Temp.SetFieldValueAsString('X_MX_NAZEV',mBODocRowBatch.GetFieldValueAsstring('Parent_ID'));
                                                                                 mBO_Temp.SetFieldValueAsString('X_DE_NAZEV',mBODocRowBatch.oid);
                                                                                 mBO_Temp.SetFieldValueAsFloat('X_vychystano',mBODocRowBatch.GetFieldValueAsFloat('Quantity'));
                                                                                 //mBO_Temp.SetFieldValueAsString('X_CreatedBy_ID',TSiteForm(msite).CompanyCache.GetUserID);
                                                                                 mBO_Temp.SetFieldValueAsString('X_PM_State','1050000101');

                                                                                 mOLE := GetAbraOLEApplication;
                                                                                 _ss := mOLE.CreateStrings;
                                                                                 mroll := mOLE.GetAgenda('NRKHJQ0YOLR4RG1OQ102NPQROG');
                                                                                 mduvod:= mroll.SingleSelectFromSelected2(_ss, 'Důvod vrácení:', '');
                                                                                 mBO_Temp.SetFieldValueAsstring('X_ParamValue',mduvod);

                                                                                 mUcet:='';
                                                                                 InputQuery('', '' + ' Bankovní účet' , mucet);

                                                                                 mFirmBankaccount_ID:='';
                                                                                 mFirmBankaccount_ID:=msite.BaseObjectSpace.SQLSelectFirstAsString('Select id from FirmBankAccounts where BankAccount=' + QuotedStr(trim(mucet)) + ' AND parent_ID=' + QuotedStr(mBO_Temp.GetFieldValueAsString('X_firm_ID')));

                                                                                 if  mFirmBankaccount_ID='' then begin
                                                                                         mBOFirmBankaccount:=msite.BaseObjectSpace.CreateObject('WQC02QYERNCL35CH000ILPWJF4');
                                                                                         try
                                                                                                      mBOFirmBankaccount.new;
                                                                                                      mBOFirmBankaccount.prefill;
                                                                                                      mBOFirmBankaccount.SetFieldValueAsString('Parent_ID',mBO_Temp.GetFieldValueAsString('X_firm_ID'));
                                                                                                      mBOFirmBankaccount.SetFieldValueAsString('BankAccount',mucet);
                                                                                                      mBOFirmBankaccount.SetFieldValueAsString('Name',mucet);

                                                                                                      mBOFirmBankaccount.save;
                                                                                                      mFirmBankaccount_ID:= mBOFirmBankaccount.oid;
                                                                                         finally
                                                                                            mBOFirmBankaccount.free;
                                                                                         end;
                                                                                 end;

                                                                                 mBO_Temp.SetFieldValueAsString('X_PL_Nazev',mFirmBankaccount_ID);
                                                                                 mBO_Temp.SetFieldValueAsString('X_ParamValue',mduvod);

                                                                              //   if index=0 then begin
                                                                                         mstring:='';
                                                                                         mstring:= msite.BaseObjectSpace.SQLSelectFirstAsString('select ii2.parent_ID||ii2.ID from issuedinvoices2 ii2 where ii2.Providerow_ID=' + QuotedStr(mBO_Temp.GetFieldValueAsstring('X_MX_NAZEV')));
                                                                                                if mstring<>'' then begin
                                                                                                                                    //NxShowSimpleMessage(mstring,nil);
                                                                                                                                    mBO_Temp.SetFieldValueAsString('X_Parent_ID',copy(mstring,1,10));
                                                                                                                                    //NxShowSimpleMessage(copy(mstring,11,10),nil);
                                                                                                                                    mBO_Temp.SetFieldValueAsString('X_Parent2_ID',copy(mstring,11,10));
                                                                                               end;
                                                                             //     end;




                                                                                 mBO_Temp.save;


                                                       end;
                                              finally
                                                    mrsql.free;
                                              end;
                                              end;
                                   // end;
                        end;
                        TBusRollSiteForm(msite).DataSet.RefreshCurrentItem;
                  mstring:='';
                  msite.Refresh;
     TBusRollSiteForm(msite).RefreshData;

                  end;
            end;

 //    msite.Refresh;
 //    TBusRollSiteForm(msite).RefreshData;

end;









procedure Import_Sarze(Sender: TAction; Index: integer);
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
  mBO_Temp,mBODocRowBatch:TNxCustomBusinessObject;
  mstringline:string;
  mCountField:integer;
  mstring:string;
  mvalue:TStringList;
  mr,mImportFile:tstringlist;
  mSarze:string;
  mInputString:string;
  mpocet:integer;
  mOldstorecard:string;

 L ,mx: TStringList;
 mPars:TNxParameters;
 mPar:TNxParameter;
 mr2:TStringList;
 mStrings:string;
  mids1:tstringlist;
  mids: TStringList;
  mB:boolean;
  mSelected ,_ss:Variant;
 mBoolean:boolean;
 x:integer;

begin
    mOldstorecard:='Identifikace položky';
    mpocet:=1;
    mSite := NxFindSiteForm(Sender);
        mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu

    mBO_Temp:= msite.BaseObjectSpace.CreateObject('45D1XVW5EY24JBXTOE01EHYRSG');
    mBODocRowBatch:= msite.BaseObjectSpace.CreateObject('K3TH0HR5TZDL342W01C0CX3FCC');
          if index=0 then begin
                  mstring:='';
                  msarze:='';
                  while InputQuery(mOldstorecard, inttostr(mpocet) + ' Šarže' , mstring) do begin
                       // NxShowSimpleMessage(mstring,nil);
                        if mstring<>'' then begin
                               mSarze:=mstring;
                                   if mstring<>'' then begin
                                             mRSql:=tstringlist.create;
                                             try

                                                   if index=0 then begin
                                                                        msite.BaseObjectSpace.SQLSelect('SELECT DRB.id FROM DocRowBatches DRB join StoreBatches SB on SB.id=DRB.StoreBatch_ID JOIN StoreDocuments2 SD2 ON SD2.ID=DRB.Parent_ID JOIN StoreDocuments SD ON SD.ID=SD2.Parent_ID  '
                                                                            + ' WHERE (SD.DocQueue_ID IN (SELECT ID FROM  DocQueues WHERE DocumentType IN (''20'',''22'')) ) AND  '
                                                                              + '(sb.name = ' + QuotedStr(mstring) + ' )',mRSql);
                                                   end;

                                                   if index=1 then begin
                                                                        msite.BaseObjectSpace.SQLSelect('SELECT DRB.id FROM DocRowBatches DRB join StoreBatches SB on SB.id=DRB.StoreBatch_ID JOIN StoreDocuments2 SD2 ON SD2.ID=DRB.Parent_ID JOIN StoreDocuments SD ON SD.ID=SD2.Parent_ID  '
                                                                            + ' WHERE (SD.DocQueue_ID IN (SELECT ID FROM  DocQueues WHERE DocumentType IN (''21'',''23'')) ) AND  '
                                                                              + '(sb.name = ' + QuotedStr(mstring) + ' )',mRSql);
                                                   end;
                                                    { if index=1 then begin
                                                                        msite.BaseObjectSpace.SQLSelect('SELECT a.id FROM DocRowBatches A JOIN StoreDocuments2 SD2 ON SD2.ID=A.Parent_ID JOIN StoreDocuments SD ON SD.ID=SD2.Parent_ID  '
                                                                            + ' WHERE (SD.DocQueue_ID IN (SELECT ID FROM  DocQueues WHERE DocumentType IN (''23'')) ) AND '
//                                                                              (sd.docdate$date=' + NxFloatToIBStr(mbo.GetFieldValueAsDateTime('X_ABRADate')) + ') AND'
                                                                              + '(A.StoreBatch_ID = ' + QuotedStr(mbo.GetFieldValueAsString('X_Batches')) + ' )',mr2);
                                                                      end;
                                                                      if index=2 then begin
                                                                        msite.BaseObjectSpace.SQLSelect('SELECT a.id FROM DocRowBatches A JOIN StoreDocuments2 SD2 ON SD2.ID=A.Parent_ID JOIN StoreDocuments SD ON SD.ID=SD2.Parent_ID  '
                                                                            + ' WHERE (SD.DocQueue_ID IN (SELECT ID FROM  DocQueues WHERE DocumentType IN (''20'',''30'')) ) AND  '
                                                                              + '(A.StoreBatch_ID = ' + QuotedStr(mbo.GetFieldValueAsString('X_Batches')) + ' )',mr2);
                                                                      end;}

                                                       if mRSql.count=0 then begin
                                                             NxShowSimpleMessage('Pro šarži není možné dohledat pohyb ',nil);
                                                             exit;
                                                       end else begin
                                                             if mRSql.count>1 then begin

                                                                 mOLE := GetAbraOLEApplication;
                                                                      mroll := mOLE.GetAgenda('S1X0KZC0NJE13C5U00CA141B44');
                                                                      mSelected := mOLE.CreateStrings;
                                                                      for i := 0 to mRSql.Count - 1 do begin
                                                                             mSelected.Add(mRSql.Strings[i]);
                                                                      end;
                                                                      if mRSql.Count>1 then begin
                                                                              mstring:= mroll.SingleSelectFromSelected2(mSelected, 'Pohyb šarže:','');
                                                                               if mstring<>'' then begin
                                                                                         mBODocRowBatch.Load(mstring,nil);
                                                                               end;
                                                                      end;
                                                             end else begin
                                                                  mBODocRowBatch.load(mRSql.Strings[0],nil);
                                                             end;

                                                               mBO_Temp.new;
                                                                           mBO_Temp.Prefill;




                                                                               mBO_Temp.SetFieldValueAsfloat('X_ABRADate', trunc(now()));
                                                                               mBO_Temp.SetFieldValueAsString('Code', mBODocRowBatch.GetFieldValueAsString('Parent_ID.StoreCard_ID'));
                                                                               mBO_Temp.SetFieldValueAsString('Name',mstring);
                                                                                mBO_Temp.SetFieldValueAsString('X_firm_ID',mBODocRowBatch.GetFieldValueAsString('Parent_ID.Parent_ID.Firm_ID'));
                                                                                mBO_Temp.SetFieldValueAsString('X_Store_ID',mBODocRowBatch.GetFieldValueAsString('Parent_ID.Store_ID'));
                                                                                mBO_Temp.SetFieldValueAsString('X_Batches',mBODocRowBatch.GetFieldValueAsString('StoreBatch_ID'));
                                                                                mBO_Temp.SetFieldValueAsString('X_storeCard_ID',mBODocRowBatch.GetFieldValueAsString('Parent_ID.StoreCard_ID'));
                                                                                mBO_Temp.SetFieldValueAsString('Code', mBO_Temp.getFieldValueAsString('X_Batches.Name'));
                                                                                mBO_Temp.SetFieldValueAsfloat('X_quantity',1);
                                                                                mBO_Temp.SetFieldValueAsString('X_parent_id',mBODocRowBatch.GetFieldValueAsString('Parent_ID.Parent_ID.ID'));
                                                                                 mBO_Temp.SetFieldValueAsString('X_parent2_id',mBODocRowBatch.GetFieldValueAsstring('Parent_ID'));
                                                                                 mBO_Temp.SetFieldValueAsString('X_DEVENOLUX',mBODocRowBatch.GetFieldValueAsString('Parent_ID.Parent_ID'));
                                                                                 mBO_Temp.SetFieldValueAsString('X_MX_NAZEV',mBODocRowBatch.GetFieldValueAsstring('Parent_ID'));
                                                                                 mBO_Temp.SetFieldValueAsString('X_DE_NAZEV',mBODocRowBatch.oid);
                                                                                 mBO_Temp.SetFieldValueAsFloat('X_vychystano',mBODocRowBatch.GetFieldValueAsFloat('Quantity'));
                                                                                 //mBO_Temp.SetFieldValueAsString('X_CreatedBy_ID',TDynSiteForm(msite).CompanyCache.GetUserID);
                                                                                 mBO_Temp.SetFieldValueAsString('X_PM_State','1050000101');

                                                                                 if index=1 then begin
                                                                                         mstring:='';
                                                                                         mstring:= msite.BaseObjectSpace.SQLSelectFirstAsString('select ii2.parent_ID,ii2.ID from issuedinvoices2 ii2 where ii2.Providerow_ID=' + QuotedStr(mBODocRowBatch.GetFieldValueAsstring('Parent_ID')));
                                                                                                if mstring<>'' then begin
                                                                                                                                    mBO_Temp.SetFieldValueAsString('X_Parent_ID',copy(mstring,1,10));
                                                                                                                                    mBO_Temp.SetFieldValueAsString('X_Parent2_ID',copy(mstring,12,10));
                                                                                                end;
                                                                                  end;
                                                                                 mBO_Temp.save;


                                                       end;
                                              finally
                                                    mrsql.free;
                                              end;
                                    end;
                        end;
                        TBusRollSiteForm(msite).DataSet.RefreshCurrentItem;
                  mstring:='';
                  end;
            end;

     msite.Refresh;
     TBusRollSiteForm(msite).RefreshData;

end;








































function CreateListROWFromDatamatrix(mSite:Tsiteform;mCLSDI:String;):TStringList;
begin

end;



function CreateDocsFromListRows(mSite:Tsiteform;mCLSDI:String;mDocqueue_ID:string;mDocdate:TDateTime;mList:tStringList;mVisual:boolean;mAgenda:string):string;  // vytvoří doklady z list seznamu firma;sc;šarže;množstvi
var
   mBO_Document:TNxHeaderBusinessObject;
mRowDocBatchTarget:TNxCustomBusinessObject;
 x,i:integer;
   mB_Result:boolean;
   mi:integer;
   mr,:tstringlist;
  mRow,mMonbatch: TNxCustomBusinessObject;
  mValidateList:tstringlist;
  mRowsOutput:TNxCustomBusinessMonikerCollection;
  mMonBatches:TNxCustomBusinessMonikerCollection;
mListError,mWorkList,mBatchList:tstringlist;
  mRows,mBatches:TNxCustomBusinessMonikerCollection;
  mOLE, mRoll, mOResult: Variant;
  _ss:Variant;
  mText:string;
  mDocument_ID:string;
begin
if mlist.Count>0 then begin
    mBO_Document:=TNxHeaderBusinessObject(mSite.BaseObjectSpace.CreateObject(mCLSDI));
    try
      for i:=0 to mlist.count-1 do begin
          if i=0 then begin
              // novy doklad   - první záznam
                      mBO_Document.new;
                      mBO_Document.prefill;
                      mBO_Document.SetFieldValueAsString('DocQueue_ID', mDocqueue_ID ); // musi byt...          '2781000101'
                      mBO_Document.SetFieldValueAsString('Firm_ID', copy(mList.Strings[i],1,10));
                      if mDocdate<>0 then mBO_Document.SetFieldValueAsDateTime('Docdate$date', mDocdate);
                      mRowsOutput := mBO_Document.GetLoadedCollectionMonikerForFieldCode(mBO_Document.GetFieldCode('Rows'));
          end else begin
                    if copy(mList.Strings[i],1,10)<>copy(mList.Strings[i-1],1,10) then begin // jiný doklad - uložení a založení nového záznamu
                          //uložení dokladu
                          mBO_Document.ClearValidateErrors;

                                            if mVisual then begin
                                                    if Not mBO_Document.Validate() then begin
                                                          mValidateList := TStringList.Create;
                                                                try
                                                                   mBO_Document.GetValidateErrors(mValidateList);
                                                                   mText := mValidateList.Text;
                                                                   NxToken(mText, '=');
                                                                   MessageDlg('Automaticky vytvořeny doklad nelze uložit z těchto důvodů:' + #13#10 + mText,

                                                                   mtWarning, [mbOK], 0);
                                                                 finally
                                                                   mValidateList.Free;
                                                                 end;
                                                          if mAgenda<>'' then begin
                                                              TDynSiteForm.ShowDynFormWithNewDocument(mAgenda, TBusRollSiteForm(msite).SiteContext, mBO_Document);
                                                          end;

                                                    end else begin
                                                         if mAgenda<>'' then begin
                                                             TDynSiteForm.ShowDynFormWithNewDocument(mAgenda, TBusRollSiteForm(msite).SiteContext, mBO_Document);
                                                         end else begin
                                                             mBO_Document.Save ;
                                                         end;
                                                                                                                               //;
                                                    end;
                                            end else begin
                                               if mAgenda<>'' then begin
                                                             TDynSiteForm.ShowDynFormWithNewDocument(mAgenda, TBusRollSiteForm(msite).SiteContext, mBO_Document);
                                                         end else begin
                                                             mBO_Document.Save ;
                                                         end;
                                            end;
                          //NxShowSimpleMessage('uložení průběžné',nil);
                          // novy doklad

                            mBO_Document.new;
                            mBO_Document.prefill;
                            mBO_Document.SetFieldValueAsString('DocQueue_ID', mDocqueue_ID_PRVY ); // musi byt...          '2781000101'
                            mBO_Document.SetFieldValueAsString('Firm_ID', copy(mList.Strings[i],1,10));
                            //mBO_Document.SetFieldValueAsDateTime('Docdate$date', TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsDateTime('X_ABRADate'));
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
                               if mclsdi='E03ZNUMDTCC4PDAUIEY1MBTJC0' then begin     // PR
                                    mMonBatches :=  mRow.GetLoadedCollectionMonikerForFieldCode(mRow.GetFieldCode('DocRowBatches'));
                               end;
                               if mclsdi='050I5SAOS3DL3ACU03KIU0CLP4' then begin     // DL
                                    mMonBatches :=  mRow.GetLoadedCollectionMonikerForFieldCode(mRow.GetFieldCode('DocRowBatches'));
                               end;
                               if mclsdi='0P0I5SAOS3DL3ACU03KIU0CLP4' then begin     // PRV
                                    mMonBatches :=  mRow.GetLoadedCollectionMonikerForFieldCode(mRow.GetFieldCode('DocRowBatches'));
                               end;
                               if mclsdi='E32A1GVWPYY4BJZFV5NFSRAODW' then begin     // Záměna výdej
                                    mMonBatches :=  mRow.GetLoadedCollectionMonikerForFieldCode(mRow.GetFieldCode('DocRowBatches'));
                               end;
                               if mclsdi='P3TSZXYDJB44Z3350NYZWO102K' then begin     // Přeměna výdej
                                    mMonBatches :=  mRow.GetLoadedCollectionMonikerForFieldCode(mRow.GetFieldCode('DocRowBatches'));
                               end;


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
                              if mRow.GetFieldValueAsinteger('StoreCard_ID.category')=2 then begin
                                     if mclsdi='E03ZNUMDTCC4PDAUIEY1MBTJC0' then begin     // PR
                                          mMonBatches :=  mRow.GetLoadedCollectionMonikerForFieldCode(mRow.GetFieldCode('DocRowBatches'));
                                     end;
                                     if mclsdi='050I5SAOS3DL3ACU03KIU0CLP4' then begin     // DL
                                          mMonBatches :=  mRow.GetLoadedCollectionMonikerForFieldCode(mRow.GetFieldCode('DocRowBatches'));
                                     end;
                                     if mclsdi='0P0I5SAOS3DL3ACU03KIU0CLP4' then begin     // PRV
                                          mMonBatches :=  mRow.GetLoadedCollectionMonikerForFieldCode(mRow.GetFieldCode('DocRowBatches'));
                                     end;
                                     if mclsdi='E32A1GVWPYY4BJZFV5NFSRAODW' then begin     // Záměna výdej
                                          mMonBatches :=  mRow.GetLoadedCollectionMonikerForFieldCode(mRow.GetFieldCode('DocRowBatches'));
                                     end;
                                     if mclsdi='P3TSZXYDJB44Z3350NYZWO102K' then begin     // Přeměna výdej
                                          mMonBatches :=  mRow.GetLoadedCollectionMonikerForFieldCode(mRow.GetFieldCode('DocRowBatches'));
                                     end;
                               end;

                        end;
                  end else begin
                    // oprava řádku
                       mRow.SetFieldValueAsFloat('Quantity', mRow.getFieldValueAsFloat('Quantity') + NxIBStrToFloat(copy(mList.Strings[i],41,10)))  ;
                  end;
              end;


              if i=0 then begin
                  if (mclsdi='E03ZNUMDTCC4PDAUIEY1MBTJC0') or (mclsdi='050I5SAOS3DL3ACU03KIU0CLP4') or (mclsdi='0P0I5SAOS3DL3ACU03KIU0CLP4') or (mclsdi='E32A1GVWPYY4BJZFV5NFSRAODW') or (mclsdi='P3TSZXYDJB44Z3350NYZWO102K') then begin  // skladové doklady
                               mMonbatch:=mMonBatches.AddNewObject;
                               mMonbatch.Prefill;
                               mMonbatch.setFieldValueAsString('StoreBatch_ID',copy(mList.Strings[i],31,10))  ;
                               mMonbatch.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(mList.Strings[i],41,10)))  ;
                  end;
              end else begin
                  if copy(mList.Strings[i-1],1,40)<>copy(mList.Strings[i],1,40) then begin // jiný řádek
                        // nová šarže
                  if (mclsdi='E03ZNUMDTCC4PDAUIEY1MBTJC0') or (mclsdi='050I5SAOS3DL3ACU03KIU0CLP4') or (mclsdi='0P0I5SAOS3DL3ACU03KIU0CLP4') or (mclsdi='E32A1GVWPYY4BJZFV5NFSRAODW') or (mclsdi='P3TSZXYDJB44Z3350NYZWO102K') then begin  // skladové doklady
                            mMonbatch:=mMonBatches.AddNewObject;
                               mMonbatch.Prefill;
                               mMonbatch.setFieldValueAsString('StoreBatch_ID',copy(mList.Strings[i],31,10))  ;
                               mMonbatch.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(mList.Strings[i],41,10)))  ;
                         end;
                  end else begin
                        // oprava šarže
                  if (mclsdi='E03ZNUMDTCC4PDAUIEY1MBTJC0') or (mclsdi='050I5SAOS3DL3ACU03KIU0CLP4') or (mclsdi='0P0I5SAOS3DL3ACU03KIU0CLP4') or (mclsdi='E32A1GVWPYY4BJZFV5NFSRAODW') or (mclsdi='P3TSZXYDJB44Z3350NYZWO102K') then begin  // skladové doklady
                               mMonbatch.SetFieldValueAsFloat('Quantity', mMonbatch.getFieldValueAsFloat('Quantity') + NxIBStrToFloat(copy(mList.Strings[i],41,10)))  ;
                         end;
                  end;
              end;



      end;
                                          if mVisual then begin
                                                    if Not mBO_Document.Validate() then begin
                                                          mValidateList := TStringList.Create;
                                                                try
                                                                   mBO_Document.GetValidateErrors(mValidateList);
                                                                   mText := mValidateList.Text;
                                                                   NxToken(mText, '=');
                                                                   MessageDlg('Automaticky vytvořeny doklad nelze uložit z těchto důvodů:' + #13#10 + mText,

                                                                   mtWarning, [mbOK], 0);
                                                                 finally
                                                                   mValidateList.Free;
                                                                 end;
                                                          if mAgenda<>'' then begin
                                                              TDynSiteForm.ShowDynFormWithNewDocument(mAgenda, TBusRollSiteForm(msite).SiteContext, mBO_Document);
                                                          end;

                                                    end else begin
                                                         if mAgenda<>'' then begin
                                                             TDynSiteForm.ShowDynFormWithNewDocument(mAgenda, TBusRollSiteForm(msite).SiteContext, mBO_Document);
                                                         end else begin
                                                             mBO_Document.Save ;
                                                         end;
                                                                                                                               //;
                                                    end;
                                            end else begin
                                               if mAgenda<>'' then begin
                                                             TDynSiteForm.ShowDynFormWithNewDocument(mAgenda, TBusRollSiteForm(msite).SiteContext, mBO_Document);
                                                         end else begin
                                                             mBO_Document.Save ;
                                                         end;
                                            end;

finally
    mBO_Document.free;
end;

 end;
end;


procedure CreateDocumentDL(Sender: TAction; Index: integer);
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
  mInputParams,xx: TNxParameters;
  mParam,xy: TNxParameter;
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
  mDocument_ID:string;
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
    mBO_Document:=msite.BaseObjectSpace.CreateObject('050I5SAOS3DL3ACU03KIU0CLP4');
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
                      mBO_Document.SetFieldValueAsString('DocQueue_ID', mDocqueue_ID_DL ); // musi byt...          '2781000101'
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
                                             TDynSiteForm.ShowDynFormWithNewDocument('B50I5SAOS3DL3ACU03KIU0CLP4', TBusRollSiteForm(msite).SiteContext, mBO_Document);

                                      end else begin
                                           TDynSiteForm.ShowDynFormWithNewDocument('B50I5SAOS3DL3ACU03KIU0CLP4', TBusRollSiteForm(msite).SiteContext, mBO_Document);

                                                                                                                 //mBO_Document.Save;
                                      end;
                    //NxShowSimpleMessage('uložení průběžné',nil);
                    // novy doklad

                      mBO_Document.new;
                      mBO_Document.prefill;
                      mBO_Document.SetFieldValueAsString('DocQueue_ID', mDocqueue_ID_PRVY ); // musi byt...          '2781000101'
                      mBO_Document.SetFieldValueAsString('Firm_ID', copy(mList.Strings[i],1,10));
                      //mBO_Document.SetFieldValueAsDateTime('Docdate$date', TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsDateTime('X_ABRADate'));
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
                                      if not mBO_Document.Validate() then begin //Not mBO_Document.Validate() then begin
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
                                             mBO_Document.Save;
                                             TDynSiteForm.ShowDynFormWithNewDocument('B50I5SAOS3DL3ACU03KIU0CLP4', TBusRollSiteForm(msite).SiteContext, mBO_Document);
                                            mDocument_ID:=mBO_Document.oid;
                                      end else begin
                                           TDynSiteForm.ShowDynFormWithNewDocument('B50I5SAOS3DL3ACU03KIU0CLP4', TBusRollSiteForm(msite).SiteContext, mBO_Document);

                                           //mBO_Document.Save;
                                           mDocument_ID:=mBO_Document.oid;
                                           //NxShowSimpleMessage('Byl vytvořen doklad :' + mbo.GetFieldValueAsString('Displayname'),nil);
                                      end;

                //NxShowSimpleMessage('uložení poslední',nil);
                //mBO_Document.Save;
    end;


   finally
          mlist.free;
       //   mBO_Document.free;
   end;











end;













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






 function BarCode_document(xSite:TSiteForm;mCLSID_DOC:string;
                          mTop:integer;mLeft:integer;mWith:integer;mHeight:integer;mLabel:string;
                          mID_doklad:string;mButton1,mbutton2,mbutton3,mbutton4:string):string;
var
      mForm : TForm;
      mBtn : TButton;
      mLbl : TLabel;
      mBarCodeEdt : TEdit;
      i:integer;
      xresult:Variant;
      //mSCEdt:TRollComboEdit;
      mSCEdt:TEdit;
      ABarCode,mbarcode:string;
      mi_resulta:integer;
      mBatch_id,mStorecard_id,m_umisteni,mjednotka:string;
      mr,mr1:tstringlist;
      mBO,mSSC:TNxCustomBusinessObject;
      mi_SQL:integer;
      mStrins_id,mS_doklady:string;
      mMemNote:TMemo;
begin
      Result :='' ;
      i:=1;
      ABarCode := '.';
      mBarCode:='';
     mStrins_id:='';
     mS_doklady:='';
     mID_doklad:='';
      mi_resulta:=0;
      while mi_resulta<>10 do begin

            try
           mForm := TForm.Create(xsite);
           if True then mForm.Color := clBtnFace else mForm.Color:= clRed ;
                                  mForm.Caption := mLabel;mForm.FormStyle := fsStayOnTop;mForm.BorderStyle := bsDialog;
                                  if mTop>=0 then begin
                                    mForm.Top:= mTop;
                                    mForm.Left:= mLeft;
                                  end else begin
                                    mform.Position := poScreenCenter;
                                  end;

                                  mForm.Width := mWith;mForm.Height := mHeight;mForm.Scaled := False;
                                   mMemNote := CreateMemo('ChMemNote','Položky', 10, 20, 600,800, 80, '', mForm,true,true,True,round(180/24), [fsNormal],255);



                                 mBtn := TButton.Create(mForm);mBtn.Width := 75;mBtn.Height := 40;mBtn.Caption := mbutton2;mBtn.ModalResult := 10;mBtn.Cancel := True;mBtn.Left := mForm.Width - (mBtn.Width+2) - 20;mBtn.Top := mForm.Height - mBtn.Height - 60;mBtn.Name := 'btnCancel';mForm.InsertControl(mBtn);

                                 mi_resulta:= mForm.ShowModal(xsite);   // změna položky
                                 result:= mMemNote.Text;
                                 if mi_resulta<>10 then begin

                                end else begin
                                mi_resulta:=10;
                               end;
      finally
        mform.Free;
      end;
      end;


end;


             function CreateMemo(AName, ACaption: string;
  ALeft, ATop, AWidth, AHeight: Integer; ALblWidth: Integer; ADefaultValue: string; AParent: TWinControl;
  AEditToNewLine: Boolean = False; AVisibled,AEnabled:boolean; AFontSize: Integer; AFontStyles: TFontStyles;AFontColor:TColor): TMemo;
var
mLbl: TLabel;
mFont: TFont;
begin
  mLbl:= TLabel.Create(AParent);
  mLbl.Parent:= AParent;
  mLbl.Top:= ATop + 5;
  mLbl.Left:= ALeft;
  mLbl.AutoSize:= False;
  if AName <> '' then
    mLbl.Name:= 'lbl_' + AName;
  if ALblWidth > -1 then
  begin
    mLbl.Width:= ALblWidth
  end else
  begin
    mLbl.AutoSize:= True;
    ALblWidth:= mLbl.Width + 10;
  end;
  mLbl.Caption:= ACaption;

  Result:= TMemo.Create(AParent);
  Result.Parent:= AParent;
  if not AEditToNewLine then
  begin
    Result.Top:= ATop;
    Result.Left:= ALeft + ALblWidth;
    Result.Width:= AWidth - ALblWidth;
  end else
  begin
    mLbl.Top:= ATop;
    Result.Top:= ATop + mLbl.Height + 2;
    Result.Width:= AWidth;
    Result.Left:= ALeft;
  end;
  Result.Height := AHeight;
  if AName <> '' then
    Result.Name:= 'ed_' + AName;
  Result.enabled:=AEnabled ;
  Result.Visible:=AVisibled;
  mFont := Result.Font;
    //mfont.:=left;
  if AFontSize >= 0 then begin
     mFont.Size := AFontSize;
     mFont.Style := AFontStyles;
  end;
  Result.Text:= ADefaultValue;
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
  mstring:string;
  mvalue:TStringList;
  mr,mImportFile:tstringlist;
  mdatamatrix:string;
  mInputString:string;
  mpocet:integer;
  mOldstorecard:string;
begin
    mOldstorecard:='Identifikace položky';
    mpocet:=1;
    mSite := NxFindSiteForm(Sender);
        mTabList := TTabSheet(NxFindChildControl(mSite.MainPanel, 'tabList'));
    if mTabList = nil then
        RaiseException('tabList nenalezen');
    mDBGrid := TDBGrid(NxFindChildControl(mTabList, 'grdList'));
    if mDBGrid = nil then
        RaiseException('DBGrid nenalezen');
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu


    mBO_Temp:= msite.BaseObjectSpace.CreateObject('45D1XVW5EY24JBXTOE01EHYRSG');

  mOLE := GetAbraOLEApplication;
                            mroll := mOLE.GetAgenda('N1C2EX0BUJD13ACP03KIU0CLP4');
                            _ss := mOLE.CreateStrings;

                               mfirm_id := mroll.SingleSelectFromSelected2(_ss, 'Vyber odběratele', '');
//mfirm_id:='~S0000007H';
          if index=0 then begin
                  mstring:='';
                  mdatamatrix:='';
                  while InputQuery(mOldstorecard, inttostr(mpocet) + ' datamatrix' , mstring) do begin
                       // NxShowSimpleMessage(mstring,nil);
                        if mstring<>'' then begin
                               mdatamatrix:=mstring;
                               mstring:= DatamatrixDecodeBatches(TBusRollSiteForm(msite).BaseObjectSpace,mstring);

                                      mbatch_ID:='';
                                      mStoreCard_ID:='';
                                      mquantity:=0;
                                     // NxShowSimpleMessage(mStorecard_ID + ' - ' + mbatch_ID,nil);
                                   if mstring<>'' then begin
                                             mvalue:=tstringlist.create;
                                                   try
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
                                                          // NxShowSimpleMessage(mStoreCard_ID + ' - ' +  mbatch_ID + ' -' + NxFloatToIBStr(mquantity) ,nil);
                                                    finally
                                                     //  mvalue.free;
                                                    end;
                                    end else begin
                                      mbatch_ID:='';
                                      mStoreCard_ID:='';
                                      mquantity:=1;

                                    end;


                                     mRSql:= tstringlist.Create;   // ***** dohledání již existujícího záznamu
                                                try
                                                    msite.BaseObjectSpace.SQLSelect('SELECT A.id FROM DefRollData A WHERE (A.Hidden = ''N'' ) AND (A.CLSID = ''45D1XVW5EY24JBXTOE01EHYRSG'' ) AND ((A.X_Firm_ID = '
                                                                 + quotedstr(mFirm_ID) + ' OR A.X_Firm_ID IN (SELECT ID FROM Firms WHERE Firm_ID = '
                                                                 + quotedstr(mFirm_ID) + ')))  AND a.X_ABRADate=' +inttostr(trunc(now()))  + ' AND ((A.X_Batches = ' + quotedstr(mbatch_ID) + ') and (A.X_Storecard_ID = ' + quotedstr(mStoreCard_ID) + ')) ' ,mRSql);

                                                    if mRSql.count=0 then begin
                                                           msite.BaseObjectSpace.SQLSelect('SELECT A.id FROM DefRollData A WHERE (A.Hidden = ''N'' ) AND (A.CLSID = ''45D1XVW5EY24JBXTOE01EHYRSG'' ) AND ((A.X_Firm_ID = '
                                                                 + quotedstr(mFirm_ID) + ' OR A.X_Firm_ID IN (SELECT ID FROM Firms WHERE Firm_ID = '
                                                                 + quotedstr(mFirm_ID) + ')))  AND a.X_ABRADate=' +inttostr(trunc(now()))  + ' AND ((A.Name = ' + quotedstr(mstring) + ') and (A.X_Storecard_ID = ' + quotedstr(mStoreCard_ID) + ')) ' ,mRSql);

                                                    end;

                                                   if mRSql.count>0 then begin
                                                        mBO_Temp.load(mRSql.strings[0],nil);
                                                             mOldstorecard:='Poslední: ' + mBO_Temp.getFieldValueAsstring('X_Storecard.Displayname');

                                                               mBO_Temp.SetFieldValueAsfloat('X_quantity',mBO_Temp.getFieldValueAsfloat('X_quantity') + mquantity);
                                                               mpocet:=mpocet+ 1;
                                                           mBO_Temp.save;
                                                   end else begin
                                                                 mBO_Temp.new;
                                                                 mBO_Temp.Prefill;
                                                                     mBO_Temp.SetFieldValueAsfloat('X_ABRADate', trunc(now()));
                                                                     mBO_Temp.SetFieldValueAsString('Code', mStoreCard_ID);
                                                                     mBO_Temp.SetFieldValueAsString('Name',mdatamatrix);
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
                                                                          mBO_Temp.SetFieldValueAsString('Code', mBO_Temp.getFieldValueAsString('X_Batches.Name'));
                                                                     end else begin
                                                                         mBO_Temp.SetFieldValueAsString('X_storeCard_ID',mStorecard_ID);
                                                                     end;

                                                                     if mBO_Temp.getFieldValueAsString('X_Batches.Name')='0' then begin
                                                                          mBO_Temp.SetFieldValueAsString('X_Batches','');
                                                                          mBO_Temp.SetFieldValueAsString('X_storeCard_ID','');
                                                                          mBO_Temp.SetFieldValueAsString('Code', '');
                                                                     end;

                                                                  mOldstorecard:='Poslední: ' + mBO_Temp.getFieldValueAsstring('X_Storecard.Displayname');
                                                                  mBO_Temp.SetFieldValueAsfloat('X_quantity',mquantity);
                                                                  mpocet:=mpocet+ 1;
                                                                  mBO_Temp.save;

                                                   end;
                                               finally
                                                  // mRSql.free;
                                               end;

                        end;
                        TBusRollSiteForm(msite).DataSet.RefreshCurrentItem;
                  mstring:='';
                  end;
            end;
            if index=1 then begin
                mImportFile:=TStringList.create;
                         ParsevalueRow(BarCode_document(mSite,'05CPMINJW3DL342X01C0CX3FCC',0,0,720,960, 'Obsah ','Datamatrix : ','','Pokračovat','',''), chr(10),mImportFile);
                         ProgressInit(msite, 'Načítání dat ' + '', 100);
                          for i:=0 to mImportFile.Count-1 do begin   // načtení souboru

                                        ProgressSetPos(1+NxFloor((i/mImportFile.Count)*99), inttostr(i) +' z '+inttostr(mImportFile.Count));
                                        mstringline:= mImportFile.strings[i];
                                        if trim(mstringline)<>'' then begin
                                            mStoreCard_ID:='';
                                             mBatch_ID:='';
                                             mQuantity:=0;
                                             mInputString:='';
                                            mvalue:=tstringlist.create;
                                            try

                                                mstring:= DatamatrixDecodeBatches(TBusRollSiteForm(msite).BaseObjectSpace,mstringline);
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
                                              finally
                                             //      mvalue.free;
                                              end;



                                               mRSql:= tstringlist.Create;   // ***** dohledání již existujícího záznamu
                                                          try
                                                              msite.BaseObjectSpace.SQLSelect('SELECT A.id FROM DefRollData A WHERE (A.Hidden = ''N'' ) AND (A.CLSID = ''45D1XVW5EY24JBXTOE01EHYRSG'' ) AND ((A.X_Firm_ID = '
                                                                           + quotedstr(mFirm_ID) + ' OR A.X_Firm_ID IN (SELECT ID FROM Firms WHERE Firm_ID = '
                                                                           + quotedstr(mFirm_ID) + ')))  AND a.X_ABRADate=' +inttostr(trunc(now()))  + ' AND ((A.X_Batches = ' + quotedstr(mbatch_ID) + ') and (A.X_Storecard_ID = ' + quotedstr(mStoreCard_ID) + ')) ' ,mRSql);

                                                              if mRSql.count=0 then begin
                                                                     msite.BaseObjectSpace.SQLSelect('SELECT A.id FROM DefRollData A WHERE (A.Hidden = ''N'' ) AND (A.CLSID = ''45D1XVW5EY24JBXTOE01EHYRSG'' ) AND ((A.X_Firm_ID = '
                                                                           + quotedstr(mFirm_ID) + ' OR A.X_Firm_ID IN (SELECT ID FROM Firms WHERE Firm_ID = '
                                                                           + quotedstr(mFirm_ID) + ')))  AND a.X_ABRADate=' +inttostr(trunc(now()))  + ' AND ((A.Name = ' + quotedstr(mstring) + ') and (A.X_Storecard_ID = ' + quotedstr(mStoreCard_ID) + ')) ' ,mRSql);

                                                              end;

                                                             if mRSql.count>0 then begin
                                                                  mBO_Temp.load(mRSql.strings[0],nil);


                                                                         mBO_Temp.SetFieldValueAsfloat('X_quantity',mBO_Temp.getFieldValueAsfloat('X_quantity') + mquantity);
                                                                     mBO_Temp.SetFieldValueAsstring('X_WorkstationName',mstringline);
                                                                     if nxisblank(mBO_Temp.getFieldValueAsstring('Name')) then  mBO_Temp.SetFieldValueAsstring('Name',mstringline);
                                                                     mBO_Temp.SetFieldValueAsString('X_CreatedBy_ID',TRollSiteForm(msite).CompanyCache.GetUserID);
                                                                     mBO_Temp.save;
                                                             end else begin
                                                                           mBO_Temp.new;
                                                                           mBO_Temp.Prefill;
                                                                               mBO_Temp.SetFieldValueAsfloat('X_ABRADate', trunc(now()));
                                                                               mBO_Temp.SetFieldValueAsString('Code', mStoreCard_ID);
                                                                               mBO_Temp.SetFieldValueAsString('Name',mdatamatrix);
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
                                                                                    mBO_Temp.SetFieldValueAsString('Code', mBO_Temp.getFieldValueAsString('X_Batches.Name'));
                                                                               end else begin
                                                                                   mBO_Temp.SetFieldValueAsString('X_storeCard_ID',mStorecard_ID);
                                                                               end;

                                                                               if mBO_Temp.getFieldValueAsString('X_Batches.Name')='0' then begin
                                                                                    mBO_Temp.SetFieldValueAsString('X_Batches','');
                                                                                    mBO_Temp.SetFieldValueAsString('X_storeCard_ID','');
                                                                                    mBO_Temp.SetFieldValueAsString('Code', '');
                                                                               end;


                                                                            mBO_Temp.SetFieldValueAsfloat('X_quantity',mquantity);
                                                                            if nxisblank(mBO_Temp.getFieldValueAsstring('Name')) then  mBO_Temp.SetFieldValueAsstring('Name',mstringline);
                                                                            mBO_Temp.SetFieldValueAsstring('X_WorkstationName',mstringline);
                                                                            mBO_Temp.SetFieldValueAsString('X_CreatedBy_ID',TRollSiteForm(msite).CompanyCache.GetUserID);

                                                                            mBO_Temp.save;

                                                             end;
                                                         finally
                                                            // mRSql.free;
                                                         end;
                                        end;
                          end;
                          ProgressDispose()   ;
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


                                                                                      mvalue:=tstringlist.create;
                                                                                             try
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
                                                                                                    // NxShowSimpleMessage(mStoreCard_ID + ' - ' +  mbatch_ID + ' -' + NxFloatToIBStr(mquantity) ,nil);
                                                                                              finally
                                                                                               //  mvalue.free;
                                                                                              end;

                                                                                       TBusRollSiteForm(msite).CurrentObject.setFieldValueAsString('X_batches', mbatch_ID);
                                                                                              TBusRollSiteForm(msite).CurrentObject.setFieldValueAsString('X_Storecard_ID', mStoreCard_ID);
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

                                                                                mvalue:=tstringlist.create;
                                                                                             try
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
                                                                                                    // NxShowSimpleMessage(mStoreCard_ID + ' - ' +  mbatch_ID + ' -' + NxFloatToIBStr(mquantity) ,nil);
                                                                                              finally
                                                                                               //  mvalue.free;
                                                                                              end;




                                                                                               TBusRollSiteForm(msite).CurrentObject.setFieldValueAsString('X_batches', mbatch_ID);
                                                                                              TBusRollSiteForm(msite).CurrentObject.setFieldValueAsString('X_Storecard_ID', mStoreCard_ID);
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

procedure CreateDocumentPrevod1(Sender: TAction; Index: integer);
var
mSite: TSiteForm;
begin
mSite := NxFindSiteForm(Sender);
    CreateDocumentPrevod(Sender,1);

 CorrectFirmStore(msite,'3010000101','5131000101');
 // ********************dohledání dokladu
    testnew(mSite,2);
 // **********************vratka příjemek
   CreateDocumentImport(msite,2);
   // ******************odeslání do CZ abry
  Synchronizace(mSite,0);
  msite.Refresh;
end;


procedure CreateDocumentEshop(Sender: TAction; Index: integer);
var

  zadej:string;
  msite:TSiteForm;
  mfilter:String;
  mDBGrid : TDBGrid;
 mTabList: TTabSheet;
    mid :string;
    moddelovac:string;
    mOLE, mRoll, mOResult: Variant;
    mOLE1, mRoll1, mOResult1: Variant;
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
  mBO_Temp,mBOPohyb:TNxCustomBusinessObject;
  mstringline:string;
  mCountField:integer;
  _ss:Variant;
  mstring:string;
  mvalue:TStringList;
  mr,mr2,mImportFile:tstringlist;
  mdatamatrix:string;
  mInputString:string;
  mpocet:integer;
  mOldstorecard:string;
  mSelected:Variant;
  mduvod:string;
begin
mSite := NxFindSiteForm(Sender);
    mbo_temp:=TBusRollSiteForm(msite).BaseObjectSpace.CreateObject('45D1XVW5EY24JBXTOE01EHYRSG');
                  mstring:='';
                  mdatamatrix:='';
                  while InputQuery(mOldstorecard, inttostr(mpocet) + ' datamatrix' , mstring) do begin
                       // NxShowSimpleMessage(mstring,nil);
                        if mstring<>'' then begin
                               mdatamatrix:=mstring;
                               mstring:= DatamatrixDecodeBatches(TBusRollSiteForm(msite).BaseObjectSpace,mstring);

                                      mbatch_ID:='';
                                      mStoreCard_ID:='';
                                      mquantity:=0;
                                     // NxShowSimpleMessage(mStorecard_ID + ' - ' + mbatch_ID,nil);
                                   if mstring<>'' then begin
                                             mvalue:=tstringlist.create;
                                                   try
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
                                                          // NxShowSimpleMessage(mStoreCard_ID + ' - ' +  mbatch_ID + ' -' + NxFloatToIBStr(mquantity) ,nil);
                                                    finally
                                                     //  mvalue.free;
                                                    end;
                                    end else begin
                                      mbatch_ID:='';
                                      mStoreCard_ID:='';
                                      mquantity:=1;

                                    end;


                                     mRSql:= tstringlist.Create;   // ***** dohledání již existujícího záznamu
                                                try
                                                    msite.BaseObjectSpace.SQLSelect('SELECT A.id FROM DefRollData A WHERE (A.Hidden = ''N'' ) AND (A.CLSID = ''45D1XVW5EY24JBXTOE01EHYRSG'' ) AND ((A.X_Firm_ID = '
                                                                 + quotedstr(mFirm_ID) + ' OR A.X_Firm_ID IN (SELECT ID FROM Firms WHERE Firm_ID = '
                                                                 + quotedstr(mFirm_ID) + ')))  AND a.X_ABRADate=' +inttostr(trunc(now()))  + ' AND ((A.X_Batches = ' + quotedstr(mbatch_ID) + ') and (A.X_Storecard_ID = ' + quotedstr(mStoreCard_ID) + ')) ' ,mRSql);

                                                    if mRSql.count=0 then begin
                                                           msite.BaseObjectSpace.SQLSelect('SELECT A.id FROM DefRollData A WHERE (A.Hidden = ''N'' ) AND (A.CLSID = ''45D1XVW5EY24JBXTOE01EHYRSG'' ) AND ((A.X_Firm_ID = '
                                                                 + quotedstr(mFirm_ID) + ' OR A.X_Firm_ID IN (SELECT ID FROM Firms WHERE Firm_ID = '
                                                                 + quotedstr(mFirm_ID) + ')))  AND a.X_ABRADate=' +inttostr(trunc(now()))  + ' AND ((A.Name = ' + quotedstr(mstring) + ') and (A.X_Storecard_ID = ' + quotedstr(mStoreCard_ID) + ')) ' ,mRSql);

                                                    end;

                                                   if mRSql.count>0 then begin
                                                        mBO_Temp.load(mRSql.strings[0],nil);
                                                             mOldstorecard:='Poslední: ' + mBO_Temp.getFieldValueAsstring('X_Storecard.Displayname');

                                                               mBO_Temp.SetFieldValueAsfloat('X_quantity',mBO_Temp.getFieldValueAsfloat('X_quantity') + mquantity);
                                                               mpocet:=mpocet+ 1;
                                                           mBO_Temp.save;
                                                   end else begin

                                                                 mBO_Temp.new;
                                                                 mBO_Temp.Prefill;
                                                                     mBO_Temp.SetFieldValueAsfloat('X_ABRADate', trunc(now()));
                                                                     mBO_Temp.SetFieldValueAsString('Code', mStoreCard_ID);
                                                                     mBO_Temp.SetFieldValueAsString('Name',mdatamatrix);
                                                                                mBO_Temp.SetFieldValueAsString('X_Store_ID',mCstore_ID);

                                                                     if  mBatch_ID<>'' then begin
                                                                          mBO_Temp.SetFieldValueAsString('X_Batches',mbatch_ID);
                                                                          mBO_Temp.SetFieldValueAsString('X_storeCard_ID',mStoreCard_ID);
                                                                          mBO_Temp.SetFieldValueAsString('Code', mBO_Temp.getFieldValueAsString('X_Batches.Name'));
                                                                     end else begin
                                                                         mBO_Temp.SetFieldValueAsString('X_storeCard_ID',mStorecard_ID);
                                                                     end;

                                                                     if mBO_Temp.getFieldValueAsString('X_Batches.Name')='0' then begin
                                                                          mBO_Temp.SetFieldValueAsString('X_Batches','');
                                                                          mBO_Temp.SetFieldValueAsString('X_storeCard_ID','');
                                                                          mBO_Temp.SetFieldValueAsString('Code', '');
                                                                     end;

                                                                  mOldstorecard:='Poslední: ' + mBO_Temp.getFieldValueAsstring('X_Storecard_ID.Displayname');
                                                                  mBO_Temp.SetFieldValueAsfloat('X_quantity',mquantity);
                                                                  mpocet:=mpocet+ 1;









                                                                     if true then begin

                    //ProgressSetPos(1+NxFloor(x/mBookmark.Count*99), inttostr(x) +' z '+inttostr(mBookmark.Count));





                                                mOLE := GetAbraOLEApplication;
                                                            mroll := mOLE.GetAgenda('S1X0KZC0NJE13C5U00CA141B44');
                                                            mSelected := mOLE.CreateStrings;



                                                            mr2:=TStringList.create;
                                                                  try
                                                                     if index=0 then begin
                                                                        mBO_Temp.ObjectSpace.SQLSelect('SELECT a.id FROM DocRowBatches A JOIN StoreDocuments2 SD2 ON SD2.ID=A.Parent_ID JOIN StoreDocuments SD ON SD.ID=SD2.Parent_ID  '
                                                                            + ' WHERE (SD.DocQueue_ID IN (SELECT ID FROM  DocQueues WHERE DocumentType IN (''21'',''23'')) ) AND  '
                                                                              + '(A.StoreBatch_ID = ' + QuotedStr(mBO_Temp.GetFieldValueAsString('X_Batches')) + ' )',mr2);
                                                                      end;
                                                                      if index=1 then begin
                                                                        mBO_Temp.ObjectSpace.SQLSelect('SELECT a.id FROM DocRowBatches A JOIN StoreDocuments2 SD2 ON SD2.ID=A.Parent_ID JOIN StoreDocuments SD ON SD.ID=SD2.Parent_ID  '
                                                                            + ' WHERE (SD.DocQueue_ID IN (SELECT ID FROM  DocQueues WHERE DocumentType IN (''23'')) ) AND '
//                                                                              (sd.docdate$date=' + NxFloatToIBStr(mBO_Temp.GetFieldValueAsDateTime('X_ABRADate')) + ') AND'
                                                                              + '(A.StoreBatch_ID = ' + QuotedStr(mBO_Temp.GetFieldValueAsString('X_Batches')) + ' )',mr2);
                                                                      end;
                                                                      if index=2 then begin
                                                                        mBO_Temp.ObjectSpace.SQLSelect('SELECT a.id FROM DocRowBatches A JOIN StoreDocuments2 SD2 ON SD2.ID=A.Parent_ID JOIN StoreDocuments SD ON SD.ID=SD2.Parent_ID  '
                                                                            + ' WHERE (SD.DocQueue_ID IN (SELECT ID FROM  DocQueues WHERE DocumentType IN (''20'',''30'')) ) AND  '
                                                                              + '(A.StoreBatch_ID = ' + QuotedStr(mBO_Temp.GetFieldValueAsString('X_Batches')) + ' )',mr2);
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
                                                                          mstring:= mroll.SingleSelectFromSelected2(mSelected, 'Pohyb šarže: +' + mBO_Temp.GetFieldValueAsString('X_batches.name')  + ' v množství ' + NxFloatToIBStr(mBO_Temp.GetFieldValueAsFloat('X_quantity')), '');
                                                                      end;
                                                                  end;


                                                                  finally
                                                                      mr2.free;
                                                                  end;
                                                               //mstring:='';


                                                           if mstring<>'' then begin
                                                               mBOPohyb:=mBO_Temp.ObjectSpace.CreateObject('K3TH0HR5TZDL342W01C0CX3FCC');
                                                               try
                                                                     mBOPohyb.Load(mstring,nil);

                                                                       if index=0 then begin
                                                                             mr2:=TStringList.create;
                                                                             try
                                                                                 mBO_Temp.ObjectSpace.SQLSelect('Select ii2.parent_id from IssuedInvoices2 ii2 where ii2.ProvideRow_ID=' + quotedstr(mBOPohyb.GetFieldValueAsstring('Parent_ID')) ,mr2);
                                                                                 if mr2.count>0 then begin
                                                                                       mBO_Temp.SetFieldValueAsString('X_parent_ID',mr2.Strings[0]);
                                                                                 end;
                                                                             finally
                                                                                 mr2.free;
                                                                             end;

                                                                             mr2:=TStringList.create;
                                                                             try
                                                                                 mBO_Temp.ObjectSpace.SQLSelect('Select ii2.id from IssuedInvoices2 ii2 where ii2.ProvideRow_ID=' + quotedstr(mBOPohyb.GetFieldValueAsstring('Parent_ID')) ,mr2);
                                                                                 if mr2.count>0 then begin
                                                                                      mBO_Temp.SetFieldValueAsString('X_parent2_id',mr2.Strings[0]);
                                                                                 end;
                                                                             finally
                                                                                 mr2.free;
                                                                             end;
                                                                                 mBO_Temp.SetFieldValueAsString('X_Firm_ID',mBOPohyb.GetFieldValueAsString('Parent_ID.Parent_ID.Firm_ID'));
                                                                                 mBO_Temp.SetFieldValueAsString('X_DEVENOLUX',mBOPohyb.GetFieldValueAsString('Parent_ID.Parent_ID'));
                                                                                 mBO_Temp.SetFieldValueAsString('X_MX_NAZEV',mBOPohyb.GetFieldValueAsstring('Parent_ID'));
                                                                                 mBO_Temp.SetFieldValueAsString('X_DE_NAZEV',mBOPohyb.oid);
                                                                                 mBO_Temp.SetFieldValueAsFloat('X_vychystano',mBOPohyb.GetFieldValueAsFloat('Quantity'));
                                                                                 mBO_Temp.SetFieldValueAsString('X_PM_State','1050000101');




                                                                         mOLE1 := GetAbraOLEApplication;
                                                                                mroll1 := mOLE1.GetAgenda('45D1XVW5EY24JBXTOE01EHYRSG');

                                                                                 mduvod:= mroll1.SingleSelectFromSelected2('', 'Důvod vrácení: +' + mBO_Temp.GetFieldValueAsString('X_batches.name')  + ' v množství ' + NxFloatToIBStr(mBO_Temp.GetFieldValueAsFloat('X_quantity')), '');
                                                                                      mBO_Temp.SetFieldValueAsstring('X_ParamValue',mduvod);
                                                                                 mBO_Temp.save;
                                                                       end;
                                                                       if index=1 then begin
                                                                             mBO_Temp.SetFieldValueAsString('X_Firm_ID',mBOPohyb.GetFieldValueAsString('Parent_ID.Parent_id.Firm_ID'));
                                                                             mBO_Temp.SetFieldValueAsString('X_EN_NAZEV',mBOPohyb.oid);
                                                                             mBO_Temp.save;
                                                                       end;
                                                                        if index=2 then begin
                                                                             mBO_Temp.SetFieldValueAsString('X_Firm_ID',mBOPohyb.GetFieldValueAsString('Parent_ID.Parent_ID.Firm_ID'));
                                                                             mBO_Temp.SetFieldValueAsString('X_EN_NAZEV',mBOPohyb.oid);
                                                                             mBO_Temp.save;
                                                                             TBusRollSiteForm(mSite).RefreshData;
                                                                             TBusRollSiteForm(mSite).DataSet.SeekID(mBO_Temp.OID);
                                                                       end;
                                                               finally
                                                                   mBOPohyb.free;
                                                               end;
                                                         end;

                                                       end;





























                                                                  mBO_Temp.save;

                                                   end;
                                               finally
                                                  // mRSql.free;
                                               end;

                        end;
                  mstring:='';
                  end;


















   // testnew(mSite,0);
   // CreateDocumentImport(msite,0);

   // CorrectFirmStore(msite,'3010000101','5131000101');

 // dohledání dokladu
   // testnew(mSite,2);
 // vratka příjemek
   //CreateDocumentImport(msite,2);
   // odeslání do CZ abry
//  Synchronizace(mSite,0);
end;











procedure CorrectFirmStore(msite:TSiteForm;AFirm_ID:string;AStore_ID:string);             //3010000101          //5131000101
var
x:integer;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
begin


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
    mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu


    ProgressInit(msite, 'Načtení řádků ' + '', 100);
    if mBookmark.count=0 then begin

           // firma
           TBusRollSiteForm(msite).CurrentObject.SetFieldValueAsstring('X_Firm_ID',AFirm_ID) ;
           TBusRollSiteForm(msite).CurrentObject.SetFieldValueAsString('X_Store_ID',AStore_ID);
           TBusRollSiteForm(msite).CurrentObject.save;
    end else begin
        for x := 0 to mBookmark.Count- 1 do begin
                  mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(x));
                  ProgressSetPos(1+NxFloor(x/mBookmark.Count*99), inttostr(x) +' z '+inttostr(mBookmark.Count));
                  TBusRollSiteForm(msite).CurrentObject.SetFieldValueAsstring('X_Firm_ID',AFirm_ID) ;
           TBusRollSiteForm(msite).CurrentObject.SetFieldValueAsString('X_Store_ID',AStore_ID);
                  TBusRollSiteForm(msite).CurrentObject.save;
        end;
    end;
   ProgressDispose()   ;
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
  mInputParams,xx: TNxParameters;
  mParam,xy: TNxParameter;
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
  mDocument_ID:string;
begin
   mDocument_ID:='';
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
                      if index=0 then mBO_Document.SetFieldValueAsString('DocQueue_ID', 'I7N1000101' ); // musi byt...          '2781000101'
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
                                      if Not mBO_Document.Validate() then begin
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
                                            if index=1 then begin
                                                 TDynSiteForm.ShowDynFormWithNewDocument('BD0I5SAOS3DL3ACU03KIU0CLP4', TBusRollSiteForm(msite).SiteContext, mBO_Document);
                                                 exit;
                                            end;

                                      end else begin
                                             if index=0 then TDynSiteForm.ShowDynFormWithNewDocument('B10I5SAOS3DL3ACU03KIU0CLP4', TBusRollSiteForm(msite).SiteContext, mBO_Document);
                                            if index=1 then begin
                                                  mBO_Document.Save;
                                                 //TDynSiteForm.ShowDynFormWithNewDocument('BD0I5SAOS3DL3ACU03KIU0CLP4', TBusRollSiteForm(msite).SiteContext, mBO_Document);
                                            end;
                                           //mBO_Document.Save;
                                      end;
                    //NxShowSimpleMessage('uložení průběžné',nil);
                    // novy doklad

                      mBO_Document.new;
                      mBO_Document.prefill;
                      if index=0 then mBO_Document.SetFieldValueAsString('DocQueue_ID', 'I7N1000101' ); // musi byt...          '2781000101'
                      //mBO_Document.SetFieldValueAsString('IncomingTransferStore', mCstore_ID);
                      if index=1 then begin
                            mBO_Document.SetFieldValueAsString('DocQueue_ID', mDocqueue_ID_PRVY ); // musi byt...          '2781000101'
                            mBO_Document.SetFieldValueAsString('IncomingTransferStore', mCstore_ID);
                            ///********//********
                      end;
                      mBO_Document.SetFieldValueAsString('Firm_ID', copy(mList.Strings[i],1,10));
                      //mBO_Document.SetFieldValueAsDateTime('Docdate$date', TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsDateTime('X_ABRADate'));

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
                                      if not mBO_Document.Validate() then begin //Not mBO_Document.Validate() then begin
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

                                              //mBO_Document.Save;
                                              if index=0 then TDynSiteForm.ShowDynFormWithNewDocument('B10I5SAOS3DL3ACU03KIU0CLP4', TBusRollSiteForm(msite).SiteContext, mBO_Document);
                                             if index=1 then begin
                                                  TDynSiteForm.ShowDynFormWithNewDocument('BD0I5SAOS3DL3ACU03KIU0CLP4', TBusRollSiteForm(msite).SiteContext, mBO_Document);
                                                  exit;
                                             end;
//mBO_Document.Save;
                                             //TDynSiteForm.ShowDynFormWithNewDocument('BD0I5SAOS3DL3ACU03KIU0CLP4', TBusRollSiteForm(msite).SiteContext, mBO_Document);
                                            //mDocument_ID:=mBO_Document.oid;
                                      end else begin
                                             if index=0 then TDynSiteForm.ShowDynFormWithNewDocument('B10I5SAOS3DL3ACU03KIU0CLP4', TBusRollSiteForm(msite).SiteContext, mBO_Document);
                                            if index=1 then begin
                                                 mBO_Document.Save;
                                                 //TDynSiteForm.ShowDynFormWithNewDocument('BD0I5SAOS3DL3ACU03KIU0CLP4', TBusRollSiteForm(msite).SiteContext, mBO_Document);
                                                  mDocument_ID:=mBO_Document.oid;
                                            end;



                                           //NxShowSimpleMessage('Byl vytvořen doklad :' + mbo.GetFieldValueAsString('Displayname'),nil);
                                      end;

                //NxShowSimpleMessage('uložení poslední',nil);
                //mBO_Document.Save;
    end;


   finally
          mlist.free;
       //   mBO_Document.free;
   end;





   if (index=1) and (mDocument_ID<>'') then begin
   mImportMan := NxCreateDocumentImportManager(msite.baseobjectspace, '0P0I5SAOS3DL3ACU03KIU0CLP4', '1D0I5SAOS3DL3ACU03KIU0CLP4');
                                         mImportMan.AddInputDocument(mDocument_ID);
                                            xx := TNxParameters.Create;
                                            try
                                            xx.GetOrCreateParam(dtString, 'DocQueue_ID', pkInput).AsString := '2010000101' ;
                                              xx.GetOrCreateParam(dtString, 'Store_ID', pkInput).AsString := '5131000101' ;
                                              mImportMan.LoadParams(xx);
                                              mImportMan.Execute;
                                              mImportMan.outputdocument.ClearValidateErrors;
                                                   // if true then begin
                                                  if Not mImportMan.outputdocument.Validate() then begin
                                                        mList := TStringList.Create;
                                                        try
                                                           mImportMan.outputdocument.GetValidateErrors(mList);
                                                           mText := mList.Text;
                                                           NxToken(mText, '=');
                                                           MessageDlg('Automaticky vytvořenou převodku nelze uložit z těchto důvodů:' + #13#10 + mText,

                                                           mtWarning, [mbOK], 0);
                                                         finally
                                                           mList.Free;
                                                         end;
                                                         TDynSiteForm(mSite).ShowDynFormWithNewDocument('BH0I5SAOS3DL3ACU03KIU0CLP4', mSite.SiteContext,  mImportMan.outputdocument);
                                                         // mImportMan.outputdocument.save;
                                                  end else begin
                                                       mImportMan.outputdocument.save;
                                                  end;
                                            finally
                                               xx.Free;
                                                mImportMan.free;
                                            end;

  end;


end;



function GetOrCreateAPI(mBO:TNxCustomBusinessObject;xsite: TRollSiteForm;mICount:integer): string;
var
  mQueryID:string;
  mID:string;
  mNewQueryID:string;
  mSQL:string;
  i,ii,iii:integer;
  mTarget:string;
  mr1:tstringlist;
  astring:string;
  mr:TStringList;
  mString:string;
  mNewQuery:string;
  mboolean:boolean;
begin
 result:='';
   mTargetList:=tstringlist.create;
    TRY
     //     mTargetList:=CreateTargetList;

    //for i:=0 to mTargetList.count-1 do begin // ****cyklus pro jednotlicá spojení
                mTarget:=mTargetAPI ;
          //if copy(mBO.GetFieldValueAsString('X_synchronizace_ID'),i+1,1)='1' then begin
          if mTarget<>msource then begin
                     mQuery:='{}';

                     IF mManual then BEGIN                   // **** ruční vykopírování údajů
                            mQuery:=GetQueryDefroll(mBO,i,mQuery);

                            mquery:=mquery +'}';
                    end;

                    //  NxShowSimpleMessage(mQuery,nil) ;
                      // *** dohledání záznamu v cílové databázi
                        mQueryID:='{'
                              + ' "class": "' + mApiTable +'",'
                              +' "select": ["ID",],'
                              + ' "where": " id = ' + QuotedStr(mBO.OID)
                              +' " '
                              +'}';
                              mString:= APICallRest(mBO,'Post',mtarget,'/query','',mQueryID,true);


                             if (copy(mString,1,3)='200') or (copy(mString,1,3)='201') then begin
//                                    NxShowSimpleMessage('Dohledán ' + copy(mString,15,10),nil);
//                                    if copy(mString,9,2)='ID' then begin      // záznam namezen
                                             mID:= copy(mString,15,10);
                                             //NxShowSimpleMessage('doklad ' + mDoc_ID,nil);
                                             mIKUprave:=mIKUprave + 1;
//                                    end;
                              end else begin
                                        //NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                                        iSendmsgy(xsite.BaseObjectSpace,
                                                 ' API Error ' + mtable ,     // popis
                                                  mString  + '      Post'+mtarget+'/query'+''+mQueryID,                          // tělo
                                                  mToMSG ,                      // komu
                                                  xsite.SiteContext.GetCompanyCache.GetUserID); // kdo
                                        mID:='';
                                        //exit;
                              end;

                        IF mid='' THEN BEGIN


                                mNewQueryID:= GetNewQuery(mBO,i,mTable);


                                 if (xSite.CompanyCache.GetUserID='SUPER00000') and (mICount=0) then
                                                                mboolean:=InputQuery('API','Post 1 doklad',mtarget+'/script/Synchronizace/API/NewValueWithID' + Chr(10) + chr(10) +mNewQueryID);



                                 mString:=ApiCallNewValue(mBO,'POST',mtarget+'/script/Synchronizace/API/NewValueWithID',mNewQueryID, true);


                                 if (copy(mString,1,3)='201') or (copy(mString,1,3)='200') or (copy(mString,1,3)='204')then begin
                                    mINovych:=mINovych+1;

                                    //NxShowSimpleMessage('vytvořena SC ',nil);
                                    //if copy(mString,9,2)='ID' then begin      // záznam namezen
                                    //         mID:= copy(mString,15,10);
                                             //NxShowSimpleMessage('doklad ' + mDoc_ID,nil);
                                    //end;
                                  end else begin
                                            //NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                                            iSendmsgy(xsite.BaseObjectSpace,
                                                 ' API Error ' + 'Storecards + ',     // popis
                                                  mString  + '      POST' +mtarget+'/script/Synchronizace/API/NewValueWithID'+mNewQueryID,                          // tělo
                                                  mToMSG ,                      // komu
                                                  xsite.SiteContext.GetCompanyCache.GetUserID); // kdo
                                  //          mID:='';
                                            //exit;
                                  end;


                                mid:= mBO.oid;

                         end;






                              if (xSite.CompanyCache.GetUserID='SUPER00000') and (mICount=0) then
                                                                mboolean:=InputQuery('API','Post 1 doklad',mtarget+'/'+mApiTable+'/' + mid + Chr(10) + chr(10) + mQuery);



                              mString:= APICallRest(mBO,'PUT',mtarget,'/' + mApiTable,'/' + mid ,mQuery,true);  // načtení záznamu

                              if (copy(mString,1,3)='201') or (copy(mString,1,3)='200') or (copy(mString,1,3)='204')then begin
                                //NxShowSimpleMessage('Aktualizace max ' + mtarget+mApiTable+'/' + mid  + '    ' + mQuery,nil);
                                //if copy(mString,9,2)='ID' then begin      // záznam namezen
                                         mID:= copy(mString,15,10);
                                         //NxShowSimpleMessage('doklad ' + mDoc_ID,nil);
                                         result:=mbo.oid;
                                         mIUpravenych:=mIUpravenych+1;
                                //end;
                              end else begin
                                        //NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                                        iSendmsgy(xsite.BaseObjectSpace,
                                                 ' API Error ' + mApiTable,     // popis
                                                  mString  + '      PUT' +mtarget+'/' + mApiTable+'/' + mid +mQuery,                          // tělo
                                                  mToMSG ,                      // komu
                                                  xsite.SiteContext.GetCompanyCache.GetUserID); // kdo
                                        mID:='';
                                        //exit;
                              end;

                  end;
              //    end;
    finally
   //   mTargetList.free;
    end;
end;










 procedure Synchronizace(mSite:TSiteForm;index:integer);
var
  mDBGrid : TDBGrid;
 mTabList: TTabSheet;
  mBookmark : TBookmarkList;
  mIBookmark:integer;
  mICount:integer;
  mID:string;

begin
  mINovych:=0;
  mIKuprave:=0;
  mIUpravenych:=0;

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
                      mBookmark := mDBGrid.SelectedRows; // *** v mBookmark jsou id označených záznamu
                      mIBookmark:=0;
                      if mBookmark.count>0 then begin
                           mIBookmark:=mBookmark.count-1;
                           ProgressInit(msite, 'Zpracování dat ' + '', 100);
                      end;
                      for mICount:=0 to mIBookmark do begin
                          if mBookmark.count>0 then begin
                               mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(mICount));
                               ProgressSetPos(1+NxFloor(mICount/mBookmark.Count*99), inttostr(mICount) +' z '+inttostr(mBookmark.Count));
                          end;
                           // ******** zpracování dat
                          mid:=GetOrCreateAPI(TBusRollSiteForm(mSite).CurrentObject,TBusRollSiteForm(mSite),mICount);

                      end;
                      if mBookmark.count>0 then  ProgressDispose()   ;
                end;
            end;
    end;

     if mINovych+mIKuprave+mIUpravenych>0 then begin
         NxShowSimpleMessage('Počet nových záznamů: ' + inttostr(mINovych)  ,nil);
     end;

end;









function CreateAllDocFromWorkList(msite:tSiteform;mCLSIDOutput:string;mAgenda:string;mDocqueue_ID:string;mFirm_id:string;mDivision_ID:string;mStore_ID:string;mDocList:tstringlist;mRowList:tstringlist;index:integer;mbatchlist:TStringList;mBatchWorkList:tstringlist):string;
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
  mBO_Document,mBOVratka,mDefRoll,mBillOfDeliveryRowBO:TNxCustomBusinessObject;
  mpocet:double;
  mMonbatch:TNxCustomBusinessObject;
  mboolean:Boolean;
begin
  mOS := msite.BaseObjectSpace;
  try
   mBO_Document:=mOS.CreateObject(mCLSIDOutput);


        mBO_Document.SetFieldValueAsString('DocQueue_ID', mDocqueue_ID_VRPR ); // musi byt...          '2781000101'
          mBO_Document.SetFieldValueAsString('Firm_ID', TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsstring('X_Firm_ID'));

          mBO_Document.SetFieldValueAsDateTime('Docdate$date', TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsDateTime('X_ABRADate'));

                 mRowsOutput := mBO_Document.GetLoadedCollectionMonikerForFieldCode(mBO_Document.GetFieldCode('Rows'));

                 mRow:=mRowsOutput.AddNewObject;
                 mRow.Prefill;

                                   for xxx:=0 to mBatchWorkList.Count-1 do begin
                                       mRow.SetFieldValueAsInteger('RowType',3)  ;

                                             mRow.SetFieldValueAsstring('Store_ID',mCStore_ID);

                                       mRow.SetFieldValueAsString('Storecard_ID',copy(mBatchWorkList.Strings[xxx],31,10))  ;
                                       NxShowSimpleMessage(copy(mBatchWorkList.Strings[xxx],31,10),nil);
                                       mRow.SetFieldValueAsString('Division_ID',mDivision_ID)  ;
                                       mRow.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(mBatchWorkList.Strings[xxx],101,10)))  ;

                                       //mRowsOutput.BusinessObject[xx].SetFieldValueAsFloat('quantity',1);

                                       if mRow.GetFieldValueAsinteger('StoreCard_ID.category')=2 then begin
                                                                                          mpocet:=0;
                                                                                               mxx:=tstringlist.create;



                                                                                          mMonBatches :=  mRow.GetLoadedCollectionMonikerForFieldCode(mRow.GetFieldCode('DocRowBatches'));
                                                                                             mMonbatch:=mMonBatches.AddNewObject;
                                                                                             mMonbatch.Prefill;
                                                                                             mMonbatch.setFieldValueAsString('StoreBatch_ID',copy(mBatchWorkList.Strings[xxx],71,10));
                                                                                             mMonbatch.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(mBatchWorkList.Strings[xxx],101,10)));
                                       end;
                                   end;


         if msave then begin
              //mBO_Document.CheckOutputDocument;
                            // NxShowSimpleMessage('Ukladani',nil);
                            mBO_Document.ClearValidateErrors;
                                      if Not mBO_Document.Validate() then begin
                                            mValidateList := TStringList.Create;
                                            try
                                               mBO_Document.GetValidateErrors(mValidateList);
                                               mText := mValidateList.Text;
                                               NxToken(mText, '=');
                                               MessageDlg('Automaticky vytvořeny doklad nelze uložit z těchto důvodů:' + #13#10 + mText,

                                               mtWarning, [mbOK], 0);
                                             finally
                                               mValidateList.Free;
                                             end;
                                             //NxShowSimpleMessage('Chyba',nil);
                                             TDynSiteForm.ShowDynFormWithNewDocument('BD0I5SAOS3DL3ACU03KIU0CLP4', TBusRollSiteForm(msite).SiteContext, mBO_Document);
                                             result:='Chyba';
                                      end else begin
                                          // TDynSiteForm.ShowDynFormWithNewDocument('NN20CW0TDQSODH2FPC5IVSYIKW', TBusRollSiteForm(mSite).SiteContext, mImportMan.OutputDocument);
                                           mBO_Document.Save;
                                           //NxShowSimpleMessage('Doklad uložen',nil);
                                           result:=mBO_Document.oid;
                                          //NxShowSimpleMessage('Byl vytvořen doklad',nil);


                                      end;

                      end else begin
                          result:='Bez řádků , neuloženo';
                      end;
         //result:=mImportMan.OutputDocument.oid;
   finally
          mBO_Document.free;
   end;
   result:='ok';
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
   mFirm_ID:='3010000101';
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
                                       if false then
                                       //if copy(mBatchWorkList.Strings[xxx],81,10)<>'0000000000' then
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



  procedure ShowDocument1(Sender: TAction; Index: integer);
  var
  mSite: TSiteForm;
  begin
      mSite := NxFindSiteForm(Sender);
      ShowDocument(mSite, Index);
  end;




procedure ShowDocument(mSite:TSiteForm; Index: integer);
var
 mbo:TNxCustomBusinessObject;
 L ,mx: TStringList;
 mid:string;
 mPars:TNxParameters;
 mPar:TNxParameter;
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
 mr:tstringlist;
begin
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

                                   if index>2 then begin
                                           mStrings:='';


                                           if (index=3) then mStrings:=msite.BaseObjectSpace.SQLSelectFirstAsString('Select sd.id from docrowbatches DRB join storedocuments2 sd2 on sd2.id=drb.parent_ID join storedocuments SD on sd.id=sd2.parent_ID where drb.id=' + QuotedStr(mbo.GetFieldValueAsString('X_DE_NAZEV')));
                                           if (index=4) then mStrings:=msite.BaseObjectSpace.SQLSelectFirstAsString('Select sd.id from docrowbatches DRB join storedocuments2 sd2 on sd2.id=drb.parent_ID join storedocuments SD on sd.id=sd2.parent_ID where drb.id=' + QuotedStr(mbo.GetFieldValueAsString('X_EN_NAZEV')));
                                           if (index=5) then mStrings:=msite.BaseObjectSpace.SQLSelectFirstAsString('Select sd.id from docrowbatches DRB join storedocuments2 sd2 on sd2.id=drb.parent_ID join storedocuments SD on sd.id=sd2.parent_ID where drb.id=' + QuotedStr(mbo.GetFieldValueAsString('X_EN_NAZEV')));
                                   end;


                                   for ii:=0 to mr2.count-1 do begin
                                           if index=0 then if mr2.strings[ii]=mbo.GetFieldValueAsString('X_Parent_ID') then mfind:=true;  // fv
                                           if index=1 then if mr2.strings[ii]=mbo.GetFieldValueAsString('X_DE_NAZEV') then mfind:=true;  // X_DE_NAZEV zdrojový pohyb šarže
                                           if index=2 then if mr2.strings[ii]=mbo.GetFieldValueAsString('X_EN_NAZEV') then mfind:=true;  // cílový pohyb šarže X_EN_NAZEV
                                           if index>2 then begin
                                                            if mr2.strings[ii]=mStrings then mfind:=true;
                                           end;


                                   end;

                                   if (index=0) and (not mfind)  then mr2.Add(mbo.GetFieldValueAsString('X_Parent_ID'));
                                   if (index=1) and (not mfind)  then mr2.Add(mbo.GetFieldValueAsString('X_DE_NAZEV'));
                                   if (index=2) and (not mfind)  then mr2.Add(mbo.GetFieldValueAsString('X_EN_NAZEV'));
                                   if (index>2) and (not mfind)  then mr2.Add(mstrings);

                   end;


//      mstring:= mroll.SingleSelectFromSelected2(mSelected, 'Doklady: ', '');
                                                   mFilter:= '';
                                                         for i:= 0 to mr2.Count - 1 do begin
                                                            mFilter:= mFilter + Format('''%s'',', [mr2[i]]);

                                                          end;
                                                           if mFilter <> '' then begin
                                                                mFilter:= copy(mFilter, 1, Length(mFilter) - 1);

                                                            end;
                                                       // NxShowSimpleMessage(mfilter,nil);
                                                     // msite.ShowSite('PLC2EX0BUJD13ACP03KIU0CLP4',true,'FilterByUserDynSQLCondition;A.ID in (' + mFilter + ') ');
                                                    if index=0 then  ShowSelectedDynForm(msite, mr2, 'PLC2EX0BUJD13ACP03KIU0CLP4','Fv k dobropisování' );
                                                    if index=1 then  ShowSelectedDynForm(msite, mr2, 'S1X0KZC0NJE13C5U00CA141B44','Vstupní pohyby' );
                                                    if index=2 then  ShowSelectedDynForm(msite, mr2, 'S1X0KZC0NJE13C5U00CA141B44','Výstupní pohyby' );
                                                    if index=3 then  ShowSelectedDynForm(msite, mr2, 'B50I5SAOS3DL3ACU03KIU0CLP4','Vstupní pohyby' );
                                                    if index=4 then  ShowSelectedDynForm(msite, mr2, 'NN20CW0TDQSODH2FPC5IVSYIKW','Vytvořené doklady' );
                                                    if index=5 then  ShowSelectedDynForm(msite, mr2, 'BL0I5SAOS3DL3ACU03KIU0CLP4','Vytvořené doklady' );




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


  procedure testnew1(Sender: TAction; Index: integer);
  var
  mSite: TSiteForm;
  begin
      mSite := NxFindSiteForm(Sender);
      testnew(mSite, Index);
  end;



// procedure testnew(Sender: TAction; Index: integer);
 procedure testnew(mSite: TSiteForm; Index: integer);
var
 mbo:TNxCustomBusinessObject;
 mDBGrid : TDBGrid;
 mTabList: TTabSheet;
 x,i:integer;
 mtext:string;
 mpocet:double;
 mTMPBO:TNxCustomBusinessObject;
 mr:tstringlist;
 mFirm_id,mStore_ID:string;
begin



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
                                      mpocet:=FindStoreBatchFV(msite,mTMPBO,mpocet,index);
                                      if mShowDebug then NxShowSimpleMessage('po dobropisech zvývá ' + NxFloatToIBStr(mpocet),nil);
                                 end;
                             end;



                  end;


                   if (index=4) then begin
                             mr:=tstringlist.create;
                             try
                                 mSite.BaseObjectSpace.SQLSelect('Select Store_ID from StoreSubBatches where StoreBatch_ID=' + QuotedStr(mTMPBO.getFieldValueAsstring('X_batches')) + ' and Quantity<>0 and StoreCard_ID=' + QuotedStr(mTMPBO.getFieldValueAsstring('X_StoreCard_ID')) + ' and Store_ID<>' + QuotedStr('5131000101') ,mr);
                                 if mr.count>0 then begin
                                     mTMPBO.setFieldValueAsstring('X_Store_ID',mr.Strings[0]);
                                     mTMPBO.save;
                                 end;
                             finally
                                 mr.free;
                             end;
                  end;


                   if (index=99) then begin
                             if not nxisemptyoid(mTMPBO.getFieldValueAsstring('X_batches')) then begin
                                 if mpocet>0 then begin
                                      mpocet:=FindStoreBatchFV(msite,mTMPBO,mpocet,index);
                                      if mShowDebug then NxShowSimpleMessage('po dobropisech zvývá ' + NxFloatToIBStr(mpocet),nil);
                                 end;
                             end;



                  end;



                  if (index=2) then begin
                             if not nxisemptyoid(mTMPBO.getFieldValueAsstring('X_batches')) then begin
                                 if mpocet>0 then begin
                                      mpocet:=FindStoreBatchFV(msite,mTMPBO,mpocet,index);
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
                                          mpocet:=FindStoreBatchFV(msite,mTMPBO,mpocet,index);
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

                  if (index=4) then begin
                             mr:=tstringlist.create;
                             try
                                 mSite.BaseObjectSpace.SQLSelect('Select Store_ID from StoreSubBatches where StoreBatch_ID=' + QuotedStr(mTMPBO.getFieldValueAsstring('X_batches')) + ' and Quantity<>0 and StoreCard_ID=' + QuotedStr(mTMPBO.getFieldValueAsstring('X_StoreCard_ID')) + ' and Store_ID<>' + QuotedStr('5131000101') ,mr);
                                 if mr.count>0 then begin
                                     mTMPBO.setFieldValueAsstring('X_Store_ID',mr.Strings[0]);
                                     mTMPBO.save;
                                 end;
                             finally
                                 mr.free;
                             end;
                  end;


                  if (index=99) then begin
                             if not nxisemptyoid(mTMPBO.getFieldValueAsstring('X_batches')) then begin
                                   if mpocet>0 then begin
                                        mpocet:=FindStoreBatchFV(msite,mTMPBO,mpocet,index);
                                        if mShowDebug then NxShowSimpleMessage('po dobropisech zvývá ' + NxFloatToIBStr(mpocet),nil);
                                   end;
                             end;



                  end;


                  if (index=2) then begin
                             if not nxisemptyoid(mTMPBO.getFieldValueAsstring('X_batches')) then begin
                                   if mpocet>0 then begin
                                        mpocet:=FindStoreBatchFV(msite,mTMPBO,mpocet,index);
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















function FindStoreBatchFV(msite:tSiteform;mTMPBO:TNxCustomBusinessObject;mquantity:double;index:integer):double;
 var
 i,x:integer;
 mtext:string;
   mB_Result:boolean;
   mi:integer;
   mr,mx:tstringlist;
   mVolne,mNaDokladu,mNaVratce:double;
   msave:Boolean;
   mQuantityTemp,mQuantityVratka,mQuantityDoc, mQuantityPomoc, mQuantitySource:double;
   mBoolean:boolean;
   maPocet:double;
   mbonew:TNxCustomBusinessObject;
   xFirm_id:string;
    mFirm_id,mStore_ID:string;
begin
mr:=tstringlist.create;
try
    mQuantityPomoc:=0;
    mQuantityPomoc:= mquantity;
        if index=0 then begin


  mTMPBO.ObjectSpace.SQLSelect('select ii2.parent_ID,ii2.id,sd.id,sd2.id,drb.id,(DRB.Quantity-DRBn.Quantity)'
                                      +' from docrowbatches DRB'
                                      +' join storedocuments2 sd2 on sd2.id=drb.parent_ID'
                                      + ' join storedocuments sd on sd.id=Sd2.parent_ID'
                                      +' join Firms F on f.id=sd.Firm_ID '
                                      + ' left join storedocuments2 sd2x on  sd2x.RDocumentRow_ID=sd2.id'
                                      + ' left join docrowbatches DRBn on sd2x.id=drbn.parent_ID and drb.StoreBatch_ID=drbn.StoreBatch_ID'
                                      + ' left join issuedinvoices2 ii2 on sd2.id=ii2.Providerow_ID'
                                      + ' where'
                                      +' (F.ID='+quotedstr(mTMPBO.GetFieldValueAsString('X_Firm_ID'))+
                                                                                    ' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+quotedstr(mTMPBO.GetFieldValueAsString('X_Firm_ID'))+')) )'
                                      + ' and drb.StoreBatch_ID='+ quotedstr(mTMPBO.GetFieldValueAsString('X_Batches'))
                                      + ' and sd.documenttype='+ quotedstr('21')
                                      + ' and exists (select 1 from storedocuments2 sd2x left join docrowbatches DRBn on sd2x.id=drbn.parent_ID and drb.StoreBatch_ID=drbn.StoreBatch_ID where sd2x.RDocumentRow_ID=sd2.id)'
                               +' union '
                                     +' select ii2.parent_ID,ii2.id,sd.id,sd2.id,drb.id,(DRB.Quantity-0)'
                                     +'  from docrowbatches DRB '
                                     +'  join storedocuments2 sd2 on sd2.id=drb.parent_ID'
                                     +'  join storedocuments sd on sd.id=Sd2.parent_ID'
                                     +' join Firms F on f.id=sd.Firm_ID '
                                     +'  left join issuedinvoices2 ii2 on sd2.id=ii2.Providerow_ID'
                                     +'  where '
                                     +' (F.ID='+quotedstr(mTMPBO.GetFieldValueAsString('X_Firm_ID'))+
                                                                                    ' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+quotedstr(mTMPBO.GetFieldValueAsString('X_Firm_ID'))+')) )'
                                      +' and not exists (select 1 from storedocuments2 sd2x left join docrowbatches DRBn on sd2x.id=drbn.parent_ID and drb.StoreBatch_ID=drbn.StoreBatch_ID where sd2x.RDocumentRow_ID=sd2.id)'
                                     +' and  drb.StoreBatch_ID='+ quotedstr(mTMPBO.GetFieldValueAsString('X_Batches'))
                                     +'   and sd.documenttype='+ quotedstr('21')
                                     ,mr) ;


    end;
    if index=2 then begin
         xFirm_ID:='3010000101';
         mstore_ID:='';
         mTMPBO.ObjectSpace.SQLSelect('select sd.id as a,sd2.id as b,sd.id,sd2.id,drb.id,(DRB.Quantity-DRBn.Quantity)'
                                      +' from docrowbatches DRB'
                                      +' join storedocuments2 sd2 on sd2.id=drb.parent_ID'
                                      + ' join storedocuments sd on sd.id=Sd2.parent_ID'
                                      +' join Firms F on f.id=sd.Firm_ID '
                                      + ' left join StoreSubCards ssc on ssc.Storecard_ID=sd2.Storecard_ID and ssc.Store_ID=sd2.Store_ID'
                                      + ' left join storedocuments2 sd2x on  sd2x.RDocumentRow_ID=sd2.id'

                                      + ' left join docrowbatches DRBn on sd2x.id=drbn.parent_ID and drb.StoreBatch_ID=drbn.StoreBatch_ID'
                                      //+ ' left join receivedinvoices2 ii2 on sd2.id=ii2.Providerow_ID'
                                      + ' where'
                                      +' (F.ID='+quotedstr(xFirm_ID)+
                                                                                    ' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+quotedstr(xFirm_ID)+')) )'
                                      + ' and drb.StoreBatch_ID='+ quotedstr(mTMPBO.GetFieldValueAsString('X_Batches'))
                                      + ' and sd.documenttype='+ quotedstr('20')
                                     // + ' and ssc.quantity>0 '
                                      + ' and exists (select 1 from storedocuments2 sd2x left join docrowbatches DRBn on sd2x.id=drbn.parent_ID and drb.StoreBatch_ID=drbn.StoreBatch_ID where sd2x.RDocumentRow_ID=sd2.id)'
                               +' union '
                                     +' select sd.id as a,sd2.id as b,sd.id,sd2.id,drb.id,(DRB.Quantity-0)'
                                     +'  from docrowbatches DRB '
                                     +'  join storedocuments2 sd2 on sd2.id=drb.parent_ID'
                                     +'  join storedocuments sd on sd.id=Sd2.parent_ID'
                                     +' join Firms F on f.id=sd.Firm_ID '
                                     + ' left join StoreSubCards ssc on ssc.Storecard_ID=sd2.Storecard_ID and ssc.Store_ID=sd2.Store_ID'
                                     //+'  left join receivedinvoices2 ii2 on sd2.id=ii2.Providerow_ID'
                                     +'  where '
                                     +' (F.ID='+quotedstr(xFirm_ID)+
                                                                                    ' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+quotedstr(xFirm_ID)+')) )'
                                      +' and not exists (select 1 from storedocuments2 sd2x left join docrowbatches DRBn on sd2x.id=drbn.parent_ID and drb.StoreBatch_ID=drbn.StoreBatch_ID where sd2x.RDocumentRow_ID=sd2.id)'
                                     +' and  drb.StoreBatch_ID='+ quotedstr(mTMPBO.GetFieldValueAsString('X_Batches'))
                                     +'   and sd.documenttype='+ quotedstr('20')
                                   //  + ' and ssc.quantity>0 '
                                     ,mr) ;


    end;

    if index=4 then begin
          xFirm_ID:='3010000101';
          mTMPBO.ObjectSpace.SQLSelect('select sd.id as a,sd2.id as b,sd.id,sd2.id,drb.id,(DRB.Quantity-DRBn.Quantity)'
                                      +' from docrowbatches DRB'
                                      +' join storedocuments2 sd2 on sd2.id=drb.parent_ID'
                                      + ' join storedocuments sd on sd.id=Sd2.parent_ID'
                                      +' join Firms F on f.id=sd.Firm_ID '
                                      + ' left join StoreSubCards ssc on ssc.Storecard_ID=sd2.Storecard_ID and ssc.Store_ID=sd2.Store_ID'
                                      + ' left join storedocuments2 sd2x on  sd2x.RDocumentRow_ID=sd2.id'

                                      + ' left join docrowbatches DRBn on sd2x.id=drbn.parent_ID and drb.StoreBatch_ID=drbn.StoreBatch_ID'
                                      //+ ' left join receivedinvoices2 ii2 on sd2.id=ii2.Providerow_ID'
                                      + ' where'
                                      +' (F.ID='+quotedstr(xFirm_ID)+
                                                                                    ' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+quotedstr(xFirm_ID)+')) )'
                                      + ' and drb.StoreBatch_ID='+ quotedstr(mTMPBO.GetFieldValueAsString('X_Batches'))
                                      + ' and sd.documenttype='+ quotedstr('20')
                                     // + ' and ssc.quantity>0 '
                                      + ' and exists (select 1 from storedocuments2 sd2x left join docrowbatches DRBn on sd2x.id=drbn.parent_ID and drb.StoreBatch_ID=drbn.StoreBatch_ID where sd2x.RDocumentRow_ID=sd2.id)'
                               +' union '
                                     +' select sd.id as a,sd2.id as b,sd.id,sd2.id,drb.id,(DRB.Quantity-0)'
                                     +'  from docrowbatches DRB '
                                     +'  join storedocuments2 sd2 on sd2.id=drb.parent_ID'
                                     +'  join storedocuments sd on sd.id=Sd2.parent_ID'
                                     +' join Firms F on f.id=sd.Firm_ID '
                                     + ' left join StoreSubCards ssc on ssc.Storecard_ID=sd2.Storecard_ID and ssc.Store_ID=sd2.Store_ID'
                                     //+'  left join receivedinvoices2 ii2 on sd2.id=ii2.Providerow_ID'
                                     +'  where '
                                     +' (F.ID='+quotedstr(xFirm_ID)+
                                                                                    ' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+quotedstr(xFirm_ID)+')) )'
                                      +' and not exists (select 1 from storedocuments2 sd2x left join docrowbatches DRBn on sd2x.id=drbn.parent_ID and drb.StoreBatch_ID=drbn.StoreBatch_ID where sd2x.RDocumentRow_ID=sd2.id)'
                                     +' and  drb.StoreBatch_ID='+ quotedstr(mTMPBO.GetFieldValueAsString('X_Batches'))
                                     +'   and sd.documenttype='+ quotedstr('20')
                                   //  + ' and ssc.quantity>0 '
                                     ,mr) ;


    end;




                                           //  NxShowSimpleMessage(copy(mr.Strings[i],1,10),nil);
                                           //  NxShowSimpleMessage(copy(mr.Strings[i],12,10),nil);
                                           //  NxShowSimpleMessage(copy(mr.Strings[i],23,10),nil);
                                           //  NxShowSimpleMessage(copy(mr.Strings[i],34,10),nil);
                                            // NxShowSimpleMessage(copy(mr.Strings[i],45,10),nil);
                                            // NxShowSimpleMessage(copy(mr.Strings[i],56,10),nil);


                                      for i:=0 to mr.count-1 do begin
                                            if mShowDebug then NxShowSimpleMessage(mr.Strings[i],nil);

                                            mQuantityDoc:=NxIBStrToFloat(copy(mr.Strings[i],56,10));

                                             if mShowDebug then NxShowSimpleMessage(' Množství na zdrojovém pohybu šarže' + NxFloatToIBStr(mQuantityDoc),nil);
                                             if mShowDebug then NxShowSimpleMessage(' je potřeba vrátit pomoc k vrácení' + NxFloatToIBStr(mQuantityPomoc),nil);

                                                              if mQuantityPomoc>0  then begin

                                                                    mQuantityVratka:=0;

                                                                         //   ***** v temp již použito
                                                                         mQuantityTemp:=0;
                                                                         mx:=tstringlist.create;
                                                                         try
                                                                               msite.BaseObjectSpace.SQLSelect('select sum(x.X_vychystano) FROM DefRollData X WHERE X.CLSID = ' + QuotedStr('45D1XVW5EY24JBXTOE01EHYRSG') + ' AND x.X_DE_NAZEV=' +
                                                                                                               quotedstr(copy(mr.Strings[0],45,10)) + ' and x.hidden=' + quotedstr('N') ,mx);
                                                                                        if mx.count>0 then mQuantityTemp:=NxIBStrToFloat(mx.Strings[0]) else mQuantityTemp:=0;
                                                                                      if mShowDebug then nxShowSimpleMessage('z ' + copy(mr.Strings[0],56,10) + ' použito na temp  ' +  NxFloatToIBStr(mQuantityTemp),nil);
                                                                         finally
                                                                             mx.free;
                                                                         end;



                                                                                     if mQuantityDoc-mQuantityVratka-mQuantityTemp>0 then begin    /// je možné čerpat


                                                                                               if mQuantityPomoc>(mQuantityDoc-mQuantityVratka-mQuantityTemp) then begin
                                                                                                     mTMPBO.SetFieldValueAsFloat('X_vychystano',mQuantityDoc-mQuantityVratka-mQuantityTemp);

                                                                                                     if mShowDebug then nxShowSimpleMessage(' je potřeba  ' +  NxFloatToIBStr(mQuantitySource) +  ' na dokladu  ' +  NxFloatToIBStr(mQuantityDoc)+ ' vráceno ' +  NxFloatToIBStr(mQuantityVratka) +' použito na temp  ' +  NxFloatToIBStr(mQuantityTemp)  +chr(13) +
                                                                                                           ' bude použito ' +  NxFloatToIBStr(mQuantityDoc-mQuantityVratka-mQuantityTemp) ,nil);

                                                                                                           mbonew:=TBusRollSiteForm(mSite).BaseObjectSpace.CreateObject('45D1XVW5EY24JBXTOE01EHYRSG');
                                                                                                                        mbonew.new;
                                                                                                                        mbonew.prefill;
                                                                                                                            mbonew.SetFieldValueAsString('Code',mTMPBO.GetFieldValueAsString('Code'));



                                                                                                                            mbonew.SetFieldValueAsString('X_Parent_ID',copy(mr.Strings[i],1,10));
                                                                                                                            mbonew.SetFieldValueAsString('X_Parent2_ID',copy(mr.Strings[i],12,10));


                                                                                                                            mbonew.SetFieldValueAsString('X_DEVENOLUX',copy(mr.Strings[i],23,10));
                                                                                                                            mbonew.SetFieldValueAsString('X_MX_NAZEV',copy(mr.Strings[i],34,10));
                                                                                                                            mbonew.SetFieldValueAsString('X_DE_NAZEV',copy(mr.Strings[i],45,10));
                                                                                                                            mbonew.SetFieldValueAsFloat('X_Quantity',mQuantityDoc-mQuantityVratka-mQuantityTemp);
                                                                                                                            mbonew.SetFieldValueAsString('Name',mTMPBO.GetFieldValueAsString('name'));
                                                                                                                            mbonew.SetFieldValueAsString('X_firm_ID',mTMPBO.GetFieldValueAsString('X_Firm_ID'));
                                                                                                                            mbonew.SetFieldValueAsString('X_Store_ID',mTMPBO.GetFieldValueAsString('X_Store_ID'));
                                                                                                                            mbonew.SetFieldValueAsString('X_Storecard_ID',mTMPBO.GetFieldValueAsString('X_Storecard_ID'));
                                                                                                                            mbonew.SetFieldValueAsString('X_Batches',mTMPBO.GetFieldValueAsString('X_Batches'));
                                                                                                                            mbonew.SetFieldValueAsFloat('X_quantity',mQuantityDoc-mQuantityVratka-mQuantityTemp);
                                                                                                                            mbonew.SetFieldValueAsDateTime('X_ABRADate',mTMPBO.GetFieldValueAsDateTime('X_ABRADate'));

                                                                                                                            mbonew.SetFieldValueAsString('X_Store_ID',mTMPBO.GetFieldValueAsString('X_Store_ID'));
                                                                                                                            mbonew.SetFieldValueAsString('X_CreatedBy_ID',mTMPBO.GetFieldValueAsString('X_CreatedBy_ID'));

                                                                                                                            mbonew.SetFieldValueAsFloat('X_vychystano',mQuantityDoc-mQuantityVratka-mQuantityTemp);
                                                                                                                            mbonew.SetFieldValueAsString('X_PM_State','1050000101');

                                                                                                                            //mTMPBO.SetFieldValueAsString('X_PM_State','2020000101');
                                                                                                                        mbonew.save;
                                                                                                                                  mQuantityPomoc:=mQuantityPomoc-(mQuantityDoc-mQuantityVratka-mQuantityTemp);
                                                                                                                                    mTMPBO.SetFieldValueAsFloat('X_Quantity',mQuantityPomoc);
                                                                                                                                    mTMPBO.SetFieldValueAsFloat('X_vychystano',0);
                                                                                                                                    mTMPBO.SetFieldValueAsString('X_Parent2_ID','');
                                                                                                                                    mTMPBO.SetFieldValueAsString('X_Parent_ID','');

                                                                                                                                    mTMPBO.SetFieldValueAsString('X_DEVENOLUX','');
                                                                                                                                    mTMPBO.SetFieldValueAsString('X_MX_NAZEV','');
                                                                                                                                    mTMPBO.SetFieldValueAsString('X_DE_NAZEV','');
                                                                                                                                    mTMPBO.SetFieldValueAsString('X_PM_State','2020000101');
                                                                                                                                    mTMPBO.save;
                                                                                                                                    //  NxShowSimpleMessage(copy(mr.Strings[i],1,10),nil);
                                           //  NxShowSimpleMessage(copy(mr.Strings[i],12,10),nil);
                                           //  NxShowSimpleMessage(copy(mr.Strings[i],23,10),nil);
                                           //  NxShowSimpleMessage(copy(mr.Strings[i],34,10),nil);
                                            // NxShowSimpleMessage(copy(mr.Strings[i],45,10),nil);
                                            // NxShowSimpleMessage(copy(mr.Strings[i],56,10),nil);



                                                                                               end else begin
                                                                                                          mTMPBO.SetFieldValueAsString('X_Parent_ID',copy(mr.Strings[i],1,10));
                                                                                                          mTMPBO.SetFieldValueAsString('X_Parent2_ID',copy(mr.Strings[i],12,10));
                                                                                                          mTMPBO.SetFieldValueAsString('X_Devenolux',copy(mr.Strings[i],1,10));   // skladový doklad
                                                                                                          mTMPBO.SetFieldValueAsString('X_DEVENOLUX',copy(mr.Strings[i],23,10));
                                                                                                          mTMPBO.SetFieldValueAsString('X_MX_NAZEV',copy(mr.Strings[i],34,10));
                                                                                                          mTMPBO.SetFieldValueAsString('X_DE_NAZEV',copy(mr.Strings[i],45,10));
                                                                                                          mTMPBO.SetFieldValueAsFloat('X_Quantity',mQuantityPomoc);
                                                                                                          mTMPBO.SetFieldValueAsString('X_firm_ID',mTMPBO.GetFieldValueAsString('X_Firm_ID'));
                                                                                                          mTMPBO.SetFieldValueAsFloat('X_vychystano',mQuantityDoc-mQuantityVratka-mQuantityTemp);
                                                                                                          mTMPBO.SetFieldValueAsString('X_PM_State','1050000101');




                                                                                                    mTMPBO.SetFieldValueAsFloat('X_vychystano',mQuantityPomoc);
                                                                                                      if mShowDebug then nxShowSimpleMessage(' je potřeba  ' +  NxFloatToIBStr(mQuantitySource) +  ' na dokladu  ' +  NxFloatToIBStr(mQuantityDoc)+ ' vráceno ' +  NxFloatToIBStr(mQuantityVratka) +' použito na temp  ' +  NxFloatToIBStr(mQuantityTemp)  +chr(13) +
                                                                                                           ' bude použito ' +  NxFloatToIBStr(mQuantityPomoc) ,nil);
                                                                                                     mQuantityPomoc:=mQuantityPomoc-(mQuantityPomoc);
                                                                                                     mTMPBO.save;
                                                                                               end;


                                                                                               // if index=0 then mTMPBO.SetFieldValueAsString('X_CLSID','O3BDOKTWEFD13ACM03KIU0CLP4');




                                                                                     end else begin
                                                                                           if mShowDebug then nxShowSimpleMessage(' je potřeba  ' +  NxFloatToIBStr(mQuantitySource) +  ' na dokladu  ' +  NxFloatToIBStr(mQuantityDoc)+ ' vráceno ' +  NxFloatToIBStr(mQuantityVratka) +' použito na temp  ' +  NxFloatToIBStr(mQuantityTemp)  +chr(13) +
                                                                                                           ' nelze použít ' ,nil);

                                                                                     end;
                                                              end;

                                            //   náásledný doklad
                                      end;
                                       // mTMPBO.SetFieldValueAsFloat('X_Quantity',mQuantityPomoc);
                                       // mTMPBO.save;
                                        result:=mQuantityPomoc;
                              finally

                                 mr.free;
                              end;
                              result:=mQuantityPomoc;
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
                                                               mImportMan.OutputDocument.SetFieldValueAsString('ReasonDescription','Reklamace' + FormatDateTime('YYYY/MM',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsDateTime('X_ABRADate')));
                                                               mImportMan.OutputDocument.SetFieldValueAsString('Description','Reklamace' + FormatDateTime('YYYY/MM',TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsDateTime('X_ABRADate')));

                                                               mImportMan.OutputDocument.SetFieldValueAsString('IntrastatDeliveryTerm_ID','3001000000')  ;
                                                               mImportMan.OutputDocument.SetFieldValueAsString('IntrastatTransportationType_ID','4000000000')  ;
                                                               mImportMan.OutputDocument.SetFieldValueAsString('IntrastatTransactionType_ID','6001000000')  ;


//
                                                                       mRowsOutput := mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));

                                                                       for i:=0 to mRowsOutput.count-1 do begin
                                                                           // if mRowsOutput.BusinessObject[i].GetFieldValueAsString('ProvideRowDisplayName')='Bez čísla' then begin
                                                                                  mRowsOutput.BusinessObject[i].MarkForDelete;
                                                                           // end;
                                                                       end;





                                                                       mImportMan.OutputDocument.ClearValidateErrors;
                                                                                      if false then begin // Not mImportMan.OutputDocument.Validate() then begin
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


                              if index=3 then begin
                                                 if ((not NxIsEmptyOID(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches'))) and
                                                    (TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsinteger('X_Storecard_ID.Category')=2)) then
                                                   mSite.BaseObjectSpace.SQLSelect('SELECT  sd.id||sd2.id||CAST(sd2.quantity AS VARCHAR(10)) '+
                                                                                         '  FROM  Storedocuments2 SD2 '+
                                                                                         '       join Storedocuments SD  ON sd.ID=sd2.parent_ID '+

                                                                                          '      join Firms F on f.id=sd.Firm_ID '+
                                                                                          '      WHERE SD.DocumentType=' + quotedstr('20') + ' and (F.ID=' +quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID')) + ' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+')) ) and  (SD2.Storecard_ID = '+ quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Storecard_ID')) +')  '+
                                                                                          '      and (not exists (SELECT 1 FROM Docrowbatches where Parent_ID=SD2.ID )) ' +
                                                                                          '     order by sd2.quantity desc ',mr) ;







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
                                                                        if index=3 then TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_CLSID','E03ZNUMDTCC4PDAUIEY1MBTJC0');
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


                              if index=3 then begin
                                                  if ((not NxIsEmptyOID(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Batches'))) and
                                                    (TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsinteger('X_Storecard_ID.Category')=2)) then
                                                   mSite.BaseObjectSpace.SQLSelect('SELECT  sd.id||sd2.id||CAST(sd2.quantity AS VARCHAR(10)) '+
                                                                                         '  FROM  Storedocuments2 SD2 '+
                                                                                         '       join Storedocuments SD  ON sd.ID=sd2.parent_ID '+

                                                                                          '      join Firms F on f.id=sd.Firm_ID '+
                                                                                          '      WHERE SD.DocumentType=' + quotedstr('20') + ' and (F.ID=' +quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID')) + ' OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='+quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Firm_ID'))+')) ) and  (SD2.Storecard_ID = '+ quotedstr(TBusRollSiteForm(mSite).CurrentObject.GetFieldValueAsString('X_Storecard_ID')) +')  '+
                                                                                          '      and (not exists (SELECT 1 FROM Docrowbatches where Parent_ID=SD2.ID )) ' +
                                                                                          '     order by sd2.quantity desc ',mr) ;



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
                                                                        if index=3 then TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_CLSID','E03ZNUMDTCC4PDAUIEY1MBTJC0');
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
                           // msite.Refresh;

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
  mBOVratka,mDefRoll,mBillOfDeliveryRowBO:TNxCustomBusinessObject;
  mpocet:double;
begin
  mOS := msite.BaseObjectSpace;
  try
       mInputParams := TNxParameters.Create;
       mImportMan := NxCreateDocumentImportManager(mOS, 'O3BDOKTWEFD13ACM03KIU0CLP4', 'W402MSU3BBDL3ACR03KIU0CLP4');
      try
        //for mIDoc:=0 to mDocList.count-1 do begin
            if mShowDebug then NxShowSimpleMessage('Dokladů ' + inttostr(mdoclist.count)  + ' - ' + mdoclist.Strings[0],nil);
             mImportMan.AddInputDocument(mDocList.Strings[0]);
        //end;

        mImportMan.LoadParams(mInputParams);

        //NxShowSimpleMessage('AA',nil);
        mImportMan.Execute;
        //NxShowSimpleMessage('bb',nil);
        mImportMan.OutputDocument.SetFieldValueAsString('DocQueue_ID', mDocqueue_ID_DFV ); // musi byt...          '2781000101'
          mImportMan.OutputDocument.SetFieldValueAsString('Firm_ID', mfirm_ID);
          mImportMan.OutputDocument.SetFieldValueAsDateTime('Docdate$date', TBusRollSiteForm(msite).CurrentObject.GetFieldValueAsDateTime('X_ABRADate'));
          mImportMan.OutputDocument.SetFieldValueAsString('StoreDocQueue_ID', mDocqueue_ID_VRDL); // musi byt...
          //NxShowSimpleMessage('CC',nil);
          mImportMan.OutputDocument.SetFieldValueAsinteger('Acknowledge',0); // musi byt...
          mImportMan.OutputDocument.SetFieldValueAsString('ReasonDescription', 'Jiné'); // musi byt...
          mImportMan.OutputDocument.SetFieldValueAsString('Description', 'Vraceni z ' + mImportMan.OutputDocument.GetFieldValueAsString('Firm_ID.Name') + ' z data ' + FormatDateTime('DD.MM.YYYY',mImportMan.OutputDocument.GetFieldValueAsDateTime('Docdate$date') ));
       // NxShowSimpleMessage('dd',nil);





                                   mImportMan.OutputDocument.SetFieldValueAsString('IntrastatDeliveryTerm_ID','3001000000')  ;
                                   mImportMan.OutputDocument.SetFieldValueAsString('IntrastatTransportationType_ID','2000000000')  ;
                                   mImportMan.OutputDocument.SetFieldValueAsString('IntrastatTransactionType_ID','6001000000')  ;


        if Assigned(mImportMan.OutputDocument) then begin
                 mRowsOutput := mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));


                        if mShowDebug then NxShowSimpleMessage('Importovano radků ' + inttostr(mRowsOutput.count),nil);
                        for xx:=0 to mRowsOutput.Count-1 do begin
                              mRowsOutput.BusinessObject[xx].SetFieldValueAsBoolean('X_MArkForDelete',true);
                        end;
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
                                        mRowsOutput.BusinessObject[xx].SetFieldValueAsstring('X_bname',copy(mBatchworklist.Strings[xxx],91,10));
                                       if mRowsOutput.BusinessObject[xx].getFieldValueAsFloat('quantity')<>0
                                              then mRowsOutput.BusinessObject[xx].SetFieldValueAsBoolean('X_MArkForDelete',false);
                                       //mRowsOutput.BusinessObject[xx].SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(mRowList.Strings[xxx],51,10)));
                                      // mRowsOutput.BusinessObject[xx].SetFieldValueAsstring('Store_ID','2G10000101');




                                       msave:=true;
                                       mFind:=true;
                                   end;
                             end;
                            // if not mFind then mxList.add(mRowList.Strings[xxx]);

                        end;
                        msave:=false;
                       for xx:=0 to mRowsOutput.Count-1 do begin
                              if mRowsOutput.BusinessObject[xx].GetFieldValueAsBoolean('X_MarkForDelete') then begin
                                    mRowsOutput.BusinessObject[xx].MarkForDelete;
                              end else begin
                                  msave:=true;
                                    mRowsOutput.BusinessObject[xx].SetFieldValueAsinteger('ESLStatus',1);
                                                mRowsOutput.BusinessObject[xx].SetFieldValueAsBoolean('ToIntrastat',True);
                                                 mRowsOutput.BusinessObject[xx].SetFieldValueAsstring('VATIndex_ID','1T00000000');
                                                 mRowsOutput.BusinessObject[xx].SetFieldValueAsstring('X_Duvod_Vraceni','TZX1100101');






                              end;
                       end;
                  // mRowsOutput := mImportMan.OutputDocument.GetLoadedCollectionMonikerForFieldCode(mImportMan.OutputDocument.GetFieldCode('Rows'));
                if mShowDebug then  NxShowSimpleMessage('K ulození radků  ' + inttostr(mRowsOutput.count),nil);

   end;



         if msave then begin
        // if true then begin
              mImportMan.CheckOutputDocument;
                             //NxShowSimpleMessage('Ukladani',nil);
                            mImportMan.OutputDocument.ClearValidateErrors;
                                     // if false then begin
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
                                            // if mShowDebug then NxShowSimpleMessage('Chyba',nil);
                                             try
                                                 //TDynSiteForm(msite).ShowDynFormWithNewDocument('T1C2EX0BUJD13ACP03KIU0CLP4',  TDynSiteForm(mSite).SiteContext, mImportMan.OutputDocument);
                                             finally

                                             end;
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
                                                                  try
                                                                     mi:=mos.SQLExecute('Update DefRollData set X_CZ_Nazev=' + quotedstr(mRowsOutput.BusinessObject[xx].oid) + ' WHERE (Hidden = ''N'' ) AND (CLSID = ''45D1XVW5EY24JBXTOE01EHYRSG'' ) AND (id= '
                                                                        + quotedstr(mRowsOutput.BusinessObject[xx].GetFieldValueAsString('X_bname')) + ')');


                                                                 finally

                                                                 end;
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
                                                      mImportMan.OutputDocument.Delete;


                                                      // dobropis smazán , uvolněny šarže


                                             if mVratka.count>0 then begin
                                                mBOVratka:=msite.BaseObjectSpace.CreateObject('1T0I5SAOS3DL3ACU03KIU0CLP4');
                                                   mDefRoll:= msite.BaseObjectSpace.CreateObject('45D1XVW5EY24JBXTOE01EHYRSG');
                                                   try
                                                        for i:=0 to mVratka.count-1 do begin   // doklad
                                                            //NxShowSimpleMessage(inttostr(mVratka.count),nil);
                                                            NxShowSimpleMessage(mVratka.Strings[i],nil);
                                                            mBOVratka.load(mVratka.Strings[i],nil);
                                                                  mRows := mBOVratka.GetLoadedCollectionMonikerForFieldCode(mBOVratka.GetFieldCode('Rows'));
                                                                      for xx:=0 to mrows.count-1 do begin   // řádek
                                                                           if mrows.BusinessObject[xx].GetFieldValueAsinteger('rowtype')=3 then begin   // skladový řádek

                                                                                   if mrows.BusinessObject[xx].GetFieldValueAsinteger('StoreCard_ID.category')=2 then begin
                                                                                          mpocet:=0;

                                                                                          mMonBatches :=  mrows.BusinessObject[xx].GetLoadedCollectionMonikerForFieldCode(mrows.BusinessObject[xx].GetFieldCode('DocRowBatches'));
                                                                                              for xxx := 0 to mMonBatches.Count - 1 do begin


                                                                                                  for yyy:=0 to mbatchworklist.count-1 do begin

                                                                                                    if  (mMonBatches.BusinessObject[xxx].GetFieldValueAsstring('Parent_ID.RDocumentRow_ID')= copy(mbatchworklist.strings[yyy],51,10)) and
                                                                                                         (mMonBatches.BusinessObject[xxx].GetFieldValueAsstring('StoreBatch_ID')= copy(mbatchworklist.strings[yyy],71,10)) then begin
                                                                                                         // správná doklad a správná šarže

                                                                                                         mDefRoll.load(copy(mbatchworklist.strings[yyy],91,10),nil);
                                                                                                              mpocet:=mMonBatches.BusinessObject[xxx].GetFieldValueAsFloat('Quantity')-mDefRoll.GetFieldValueAsFloat('X_vychystano');
                                                                                                              if mDefRoll.GetFieldValueAsFloat('X_vychystano')<=mMonBatches.BusinessObject[xxx].getFieldValueAsFloat('Quantity') then begin
                                                                                                                  //mMonBatches.BusinessObject[xxx].setFieldValueAsFloat('Quantity',mDefRoll.GetFieldValueAsFloat('X_vychystano'));
                                                                                                                  mMonBatches.BusinessObject[xxx].setFieldValueAsFloat('X_Quantity',mDefRoll.GetFieldValueAsFloat('X_vychystano'));
                                                                                                                  if not NxIsBlank(mDefRoll.GetFieldValueAsString('X_Store_ID')) then
                                                                                                                  mrows.BusinessObject[xx].SetFieldValueAsString('Store_ID',mDefRoll.GetFieldValueAsString('X_Store_ID'));
                                                                                                                 // mrows.BusinessObject[xx].setFieldValueAsFloat('Quantity',(mrows.BusinessObject[xx].getFieldValueAsFloat('Quantity')-mpocet));
                                                                                                                 mDefRoll.setFieldValueAsFloat('X_dodano',mDefRoll.getFieldValueAsFloat('X_dodano') + mMonBatches.BusinessObject[xxx].getFieldValueAsFloat('Quantity'));
                                                                                                                 mDefRoll.SetFieldValueAsString('X_EN_nazev',mMonBatches.BusinessObject[xxx].OID);
                                                                                                                 mDefRoll.save;
                                                                                                               end else begin
                                                                                                                 //mMonBatches.BusinessObject[xxx].setFieldValueAsFloat('Quantity',mDefRoll.GetFieldValueAsFloat('X_vychystano'));
                                                                                                                  //mrows.BusinessObject[xx].setFieldValueAsFloat('Quantity',(mrows.BusinessObject[xx].getFieldValueAsFloat('Quantity')-mpocet));
                                                                                                                  if not NxIsBlank(mDefRoll.GetFieldValueAsString('X_Store_ID')) then
                                                                                                                  mrows.BusinessObject[xx].SetFieldValueAsString('Store_ID',mDefRoll.GetFieldValueAsString('X_Store_ID'));
                                                                                                                  mDefRoll.SetFieldValueAsString('X_EN_nazev',mMonBatches.BusinessObject[xxx].OID);
                                                                                                                  mDefRoll.setFieldValueAsFloat('X_dodano',mMonBatches.BusinessObject[xxx].getFieldValueAsFloat('Quantity'));
                                                                                                                  mDefRoll.save;

                                                                                                              end;

                                                                                                    end;
                                                                                                  end;
                                                                                              end;

                                                                                   end;
                                                                           end;
                                                                      end;
                                                              mBOVratka.SetFieldValueAsString('Description','Reklamace ' + FormatDateTime('MM', now()) + '/' +  FormatDateTime('YYYY', now()) + );


                                                               for xx:=0 to mrows.count-1 do begin   // řádek
                                                                  if mrows.BusinessObject[xx].GetFieldValueAsinteger('rowtype')=3 then begin   // skladový řádek
                                                                      if mrows.BusinessObject[xx].GetFieldValueAsinteger('StoreCard_ID.category')=2 then begin
                                                                             mpocet:=0;
                                                                             mMonBatches :=  mrows.BusinessObject[xx].GetLoadedCollectionMonikerForFieldCode( mrows.BusinessObject[xx].GetFieldCode('DocRowBatches'));
                                                                                  for xxx := 0 to mMonBatches.Count - 1 do begin
                                                                                      if mMonBatches.BusinessObject[xxx].getFieldValueAsFloat('X_Quantity')>0 then begin
                                                                                         mMonBatches.BusinessObject[xxx].setFieldValueAsFloat('Quantity',mMonBatches.BusinessObject[xxx].getFieldValueAsFloat('X_Quantity'));
                                                                                         mpocet:=mpocet+mMonBatches.BusinessObject[xxx].getFieldValueAsFloat('X_Quantity');
                                                                                      end else mMonBatches.BusinessObject[xxx].MarkForDelete;
                                                                                  end;
                                                                                  mrows.BusinessObject[xx].setFieldValueAsFloat('Quantity',mpocet);
                                                                                  if mrows.BusinessObject[xx].getFieldValueAsFloat('Quantity')= 0 then mrows.BusinessObject[xx].MarkForDelete;
                                                                      end;
                                                                  end;
                                                                  if mrows.BusinessObject[xx].GetFieldValueAsFloat('Quantity')=0 then mrows.BusinessObject[xx].MarkForDelete;
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
                                                                               TDynSiteForm(msite).ShowDynFormWithNewDocument('BL0I5SAOS3DL3ACU03KIU0CLP4', TDynSiteForm(mSite).SiteContext, mBOVratka);
                                                                               result:='Chyba';
                                                                        end else begin
                                                                             mBOVratka.save;
                                                                             //NxShowSimpleMessage('Doklad uložen',nil);
                                                                             result:=mImportMan.OutputDocument.oid;
                                                                            //NxShowSimpleMessage('Byl vytvořen doklad',nil);
                                                                            mRowsOutput := mBOVratka.GetLoadedCollectionMonikerForFieldCode(mBOVratka.GetFieldCode('Rows'));
                                                                            if mRowsOutput.Count=0 then mBOVratka.delete;
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
end;




procedure CreateDocumentImport1(Sender: TAction; Index: integer);
var
mSite: TSiteForm;
begin
  mSite := NxFindSiteForm(Sender);
  CreateDocumentImport(msite,Index);
end;




procedure CreateDocumentImport(msite:TSiteForm; Index: integer);
var
 mbo,mRowDocBatchTarget:TNxCustomBusinessObject;

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
if index=4 then begin
  mDocqueue_ID:=mDocqueue_ID_PRVY;;
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
                                    TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_CZ_Nazev','');
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
                                                   if index=2 then mstring:= CreateAllDocFromWorkListImportpr(msite,'E03ZNUMDTCC4PDAUIEY1MBTJC0','3OKSI2XXYK2OB2JRPZ3U4UXTGK',mAgenda,mDocqueue_ID,mFirm_id,mDivision_ID,mCstore_ID,mDocList,mRowList,index,mbatchlist,mBatchWorkList);
                                                   if index=4 then mstring:= CreateAllDocFromWorkList(msite,'0P0I5SAOS3DL3ACU03KIU0CLP4',mAgenda,mDocqueue_ID,mFirm_id,mDivision_ID,mStore_ID,mDocList,mRowList,index,mbatchlist,mBatchWorkList);



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
                                if index=2 then mstring:= CreateAllDocFromWorkListImportPR(msite,'E03ZNUMDTCC4PDAUIEY1MBTJC0','3OKSI2XXYK2OB2JRPZ3U4UXTGK',mAgenda,mDocqueue_ID,mFirm_id,mDivision_ID,mCstore_ID,mDocList,mRowList,index,mbatchlist,mBatchWorkList);
                                if index=4 then mstring:= CreateAllDocFromWorkList(msite,'0P0I5SAOS3DL3ACU03KIU0CLP4',mAgenda,mDocqueue_ID,mFirm_id,mDivision_ID,mStore_ID,mDocList,mRowList,index,mbatchlist,mBatchWorkList);




                    // mhead.save;

        finally
          mWorkList.free;
          mDocList.free;
          mRowList.free;
          mbatchlist.free;
          mbatchworklist.free;
        end;
//TBusRollSiteForm(mSite).RefreshData;
//TBusRollSiteForm(mSite).Refresh;

//NxShowSimpleMessage('Dokončeno', nil);
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


                              if index=3 then begin
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
                                                                        if index=3 then TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_CLSID','E03ZNUMDTCC4PDAUIEY1MBTJC0');
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
                                                if index=3 then mbonew.SetFieldValueAsString('X_CLSID','E03ZNUMDTCC4PDAUIEY1MBTJC0');
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

                              if index=3 then begin
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
                                                                        if index=3 then TBusRollSiteForm(mSite).CurrentObject.SetFieldValueAsString('X_CLSID','E03ZNUMDTCC4PDAUIEY1MBTJC0');
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
                                                if index=3 then mbonew.SetFieldValueAsString('X_CLSID','E03ZNUMDTCC4PDAUIEY1MBTJC0');
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
  mr:tstringlist;
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

                                                                                mvalue:=tstringlist.create;
                                                                                             try
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
                                                                                                    // NxShowSimpleMessage(mStoreCard_ID + ' - ' +  mbatch_ID + ' -' + NxFloatToIBStr(mquantity) ,nil);
                                                                                              finally
                                                                                               //  mvalue.free;
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
                                                                                                               mBO_Temp.SetFieldValueAsfloat('X_ABRADate', trunc(now()));
                                                                                                               mBO_Temp.SetFieldValueAsString('Code', mStoreCard_ID);
                                                                                                               mBO_Temp.SetFieldValueAsString('Name',mImportFile.strings[i]);
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





procedure InitSite_Hook(Self: TSiteForm);

var
mAction: TAction;
  mMAction: TMultiAction;
begin
//if (NxGetActualUserID(self.BaseObjectSpace)='SUPER00000') or (NxGetActualUserID(self.BaseObjectSpace)='1Z10000101') then begin
  mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := '0- Import ze souboru';
  mmAction.Hint := '0- Import ze souboru "Batch,Quantity"';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('0- CSV - oddělovač ";"');
  mMAction.Items.Add('0- CSV - oddělovač ","');
  mMAction.Items.Add('XML');
  mMAction.Items.Add('CSV - datamatrix');
  mmAction.OnExecuteItem:= @Import_souboru;


  mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := '1 - Vstup ze čtečky';
  mmAction.Hint := 'Vstup ze čtečky - datamatrix';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('Datamatrix');
  mMAction.Items.Add('Datamatrix hromadně');
  mmAction.OnExecuteItem:= @Import_ctecka;



    mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := '2 - Dohledání dokladu';
  mmAction.Hint := 'Dohledání skladového dokladu k šarži';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('Dohledání dodacího listu pomocí šarže');
  mMAction.Items.Add('   ');  //mMAction.Items.Add('Dohledání dokladu pomocí SC');
  mMAction.Items.Add('Dohledání příjemky pomocí šarže   '); //mMAction.Items.Add('Dohledání příjemky pomocí šarže');
  mMAction.Items.Add('');
  mMAction.Items.Add('Skladu');
  mMAction.Items.Add('Vyčisti data');
  mmAction.OnExecuteItem:= @testnew1;



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
  mmAction.Caption := '3 - Vytvoření dobropisu a vratek';
  mmAction.Hint := 'Vytvoření dobropisu a vratek pomocí šarže';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('Dobropis DVE a vratky VXD');
  mMAction.Items.Add('Dobropis DVT a vratky VXD');
  mMAction.Items.Add('Vratky PR');
  mMAction.Items.Add('');
  mMAction.Items.Add('');
  mMAction.Items.Add('Vymaž data');
  mmAction.OnExecuteItem:= @CreateDocumentImportv1;


 {     mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := 'Vytvoření vratek pomocí šarže';
  mmAction.Hint := 'Vytvoření opravného skladového dokladu na základe dohledaného skladového dokladu pomocí šarže';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('Vratky DL');
  mMAction.Items.Add('');
   mMAction.Items.Add('Vratky PR');
  mMAction.Items.Add('');
  mMAction.Items.Add('Převodka výdej');
  mMAction.Items.Add('Vymaž data');
  mmAction.OnExecuteItem:= @CreateDocumentImport1;
  }


          mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := 'Převodka výdej';
  mmAction.Hint := 'Převodka výdej - převodka bez uvedení prodejního dokladu';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('Příjemka');
  mMAction.Items.Add('Převodka');
    mmAction.OnExecuteItem:= @CreateDocumentPrevod;


  {mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := 'Převodka komplet';
  mmAction.Hint := 'Převodka komplet - Převedení položky z uvedeného skladu na sklad hlavní , dohledání nákupního skladového dokladu / vytvoření opravného skladového dokladu a synchronizace do české Abry';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('Převodka komplet');
      mmAction.OnExecuteItem:= @CreateDocumentPrevod1;

  }




   mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := 'Spotřeba komplet';
  mmAction.Hint := 'Spotřeba - Skladový doklad z konsignačního skladu ';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('Spotřeba');
  mmAction.OnExecuteItem:= @CreateDocumentDL;


  {mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := 'Eshop komplet';
  mmAction.Hint := 'Dohledání prodejního skladového dokladu /vytvoření opravného skladového dokladu, dohledání nákupního skladového dokladu /vytvoření opravného skladového dokladu a synchronizace do české Abry';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('Eshop komplet');
    mmAction.OnExecuteItem:= @CreateDocumentEshop;
  }
 {mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := 'Vratka komplet';
  mmAction.Hint := 'Dohledání DL/Vratka DL, dohledání PR/vratka PR, odeslání CZ';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('Vratka komplet');
    mmAction.OnExecuteItem:= @CreateDocumentPrevod;

  }
//end ;
 {

  mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := 'Opravný daňový doklad';
  mmAction.Hint := 'Vytvoření podkladů pro dobropisy';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('Příprava dobropisů vydaných ');
  mMAction.Items.Add('Příprava dobropisů Přijatých ');
  mmAction.OnExecuteItem:= @Dobropis;
}
   mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Items.Add('Prodejní pohyb šarže');
  mMAction.Items.Add('Vratka - pohyb šarže');
  mMAction.Items.Add('Příjemka - pohyb šarže');


  mMAction.Caption := 'Dohledání pohybu pro firmu';
  mMAction.Hint := 'Dohledání pohybu - výběr z pohybu šarže pro danou firmu ';
  mMAction.Category := 'tablist,tabdetail';
  mMAction.OnExecuteItem := @ShowDocExecuteItem;

  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Dohledání pohybu bez firmy';
  mMAction.Hint := 'Dohledání pohybu - výběr z pohybu šarže pro všechny firmy ';
  mMAction.Category := 'tablist,tabdetail';
  mMAction.Items.Add('Prodejní pohyb šarže');
  mMAction.Items.Add('Vratka - pohyb šarže');
  mMAction.Items.Add('Příjemka - pohyb šarže');

  mMAction.OnExecuteItem := @ShowDocExecuteItemNoneFirm;


   mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := 'Dohledání SC a batch';
  mmAction.Hint := 'Dohledání a specifikace položky(zboží)  podle ';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('Dohledání  pomocí šarže');
  mMAction.Items.Add('Dohledání  pomocí sc');
  mMAction.Items.Add('Dohledání  pomocí datamatrix');
  mMAction.Items.Add('odtraní počáteční 01 na začátku');

  mmAction.OnExecuteItem:= @findsc;



{

  mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := 'Vstup šarže';
  mmAction.Hint := 'Vstup šarže';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('Šarze nákup');
  mMAction.Items.Add('Šarze Prodej');
  mmAction.OnExecuteItem:= @Import_Sarze;
}

  mMAction := Self.GetNewMultiAction;
  mMAction.ShowControl := True;
  mMAction.ShowMenuItem := True;
  mMAction.Caption := 'Zobraz doklad';
  mMAction.Hint := 'Zobraz doklady';
  mMAction.Category := 'tablist,tabdetail';
  mMAction.Items.Add('Zobraz DL');
  mMAction.Items.Add('Zobraz FV');
  mMAction.Items.Add('Zobraz Dobropis FV');
  mMAction.Items.Add('Zobraz Vratky DL');
  mMAction.Items.Add('Zobraz Pohyb šarže vstup');
  mMAction.Items.Add('Zobraz Pohyb šarže výstup');
  mMAction.OnExecuteItem := @ShowFV;

{ mmAction := Self.GetNewMultiAction;
  mmAction.ShowControl := True;
  mmAction.ShowMenuItem := True;
  mmAction.Caption := 'Dobropis Eshop';
  mmAction.Hint := 'Dobropis Eshop';
  mmAction.Category := 'tabList';
  mMAction.Items.Add('Dobropis Eshop');
  mmAction.OnExecuteItem:= @Dobropis_eshop;

 }
end;


 procedure ShowDocExecuteItem(Sender: TAction; Index: integer);
var
 mbo,mBONew:TNxCustomBusinessObject;
 L ,mx: TStringList;
 mid:string;
 mPars:TNxParameters;
 mPar:TNxParameter;
 msite:TBusRollSiteForm;
 mr2,mr3:TStringList;
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
 mVycerpano,mPripraveno,mPomoc:double;
 mQuantity:double;
 mopakovani:integer;
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
    mopakovani:=1;
    if mBookmark.count<>0 then mopakovani:=mBookmark.Count ;

    for x := 0 to mopakovani-1 do begin
    if mBookmark.count<>0 then  mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(x));

         mbo:= TBusRollSiteForm(mSite).CurrentObject;                      //ProgressSetPos(1+NxFloor(x/mBookmark.Count*99), inttostr(x) +' z '+inttostr(mBookmark.Count));





          mOLE := GetAbraOLEApplication;
                mroll := mOLE.GetAgenda('S1X0KZC0NJE13C5U00CA141B44');
                mSelected := mOLE.CreateStrings;



                                                            mr2:=TStringList.create;
                                                                  try
                                                                     if index=0 then begin

                                                                        mbo.ObjectSpace.SQLSelect('SELECT a.id FROM DocRowBatches A JOIN StoreDocuments2 SD2 ON SD2.ID=A.Parent_ID JOIN StoreDocuments SD ON SD.ID=SD2.Parent_ID JOIN Firms F ON F.ID=SD.Firm_ID '
                                                                            + ' WHERE (SD.DocQueue_ID IN (SELECT ID FROM  DocQueues WHERE DocumentType IN (''21'')) ) AND ((F.ID='
                                                                             + QuotedStr(mbo.GetFieldValueAsString('X_firm_ID')) + ') OR (F.Firm_ID='
                                                                              + QuotedStr(mbo.GetFieldValueAsString('X_firm_ID')) + ')) AND  '
                                                                              + '(A.StoreBatch_ID = ' + QuotedStr(mbo.GetFieldValueAsString('X_Batches')) + ' )'


                                                                           { ' and (sd.docdate$date>=' + (Date-(DateDiff)) + ') '


                                                                            + ' AND (SD2.quantity>((select sum(drb.quantity) from docrowbatches drb join storedocuments2 SDRR on SDR.id=drb.parent_ID where SDR.RDocumentRow_ID=SD2.id and drb.StoreBatch_ID=A.StoreBatch_ID))  '
                                                                            +
                                                                            ' + (SELECT sum(DF.X_quantity) FROM DefRollData DF WHERE (Hidden = ' +QuotedStr('N') + ' ) AND (CLSID = '+QuotedStr('45D1XVW5EY24JBXTOE01EHYRSG')+
                                                                            ' ) AND (DF.X_DE_NAZEV=sd2.id ) and (DF.X_SK_Nazev= ' + quotedstr('') + ' ))))'    }

                                                                               ,mr2);







                                                                      end;
                                                                      if index=1 then begin
                                                                        mbo.ObjectSpace.SQLSelect('SELECT a.id FROM DocRowBatches A JOIN StoreDocuments2 SD2 ON SD2.ID=A.Parent_ID JOIN StoreDocuments SD ON SD.ID=SD2.Parent_ID JOIN Firms F ON F.ID=SD.Firm_ID '
                                                                            + ' WHERE (SD.DocQueue_ID IN (SELECT ID FROM  DocQueues WHERE DocumentType IN (''23'')) ) AND ((F.ID='
                                                                             + QuotedStr(mbo.GetFieldValueAsString('X_firm_ID')) + ') OR ( (F.Firm_ID='
                                                                              + QuotedStr(mbo.GetFieldValueAsString('X_firm_ID')) + '))) AND '
//                                                                              (sd.docdate$date=' + NxFloatToIBStr(mbo.GetFieldValueAsDateTime('X_ABRADate')) + ') AND'
                                                                              + '(A.StoreBatch_ID = ' + QuotedStr(mbo.GetFieldValueAsString('X_Batches')) + ' )'


                                                                           {
                                                                            + ' AND (a.quantity>((select sum(drb.quantity) from docrowbatches drb join storedocuments2 sd2 on sd2.id=drb.parent_ID where sd2.RDocumentRow_ID='
                                                                            + QuotedStr(mbo.GetFieldValueAsString('Parent_ID')) + ' and drb.StoreBatch_ID=' + QuotedStr(mbo.GetFieldValueAsString('X_Batches'))+' ) '
                                                                            +
                                                                            ' + (SELECT sum(X_quantity) FROM DefRollData WHERE (Hidden = ' +QuotedStr('N') + ' ) AND (CLSID = '+QuotedStr('45D1XVW5EY24JBXTOE01EHYRSG')+
                                                                            ' ) AND (X_DE_NAZEV=sd2.id ) and (X_SK_Nazev= ' + quotedstr('') + ' ))))'  }

                                                                               ,mr2);
                                                                      end;
                                                                      if index=2 then begin
                                                                        mbo.ObjectSpace.SQLSelect('SELECT a.id FROM DocRowBatches A JOIN StoreDocuments2 SD2 ON SD2.ID=A.Parent_ID JOIN StoreDocuments SD ON SD.ID=SD2.Parent_ID JOIN Firms F ON F.ID=SD.Firm_ID '
                                                                            + ' WHERE (SD.DocQueue_ID IN (SELECT ID FROM  DocQueues WHERE DocumentType IN (''20'')) ) AND ((F.ID='
                                                                             + QuotedStr(mbo.GetFieldValueAsString('X_firm_ID')) + ') OR ((F.Firm_ID IS NOT NULL) AND (F.Firm_ID='
                                                                              + QuotedStr(mbo.GetFieldValueAsString('X_firm_ID')) + '))) AND  '
                                                                              + '(A.StoreBatch_ID = ' + QuotedStr(mbo.GetFieldValueAsString('X_Batches')) + ' )'


                                                                           {
                                                                            + ' AND (SD2.quantity>((select sum(drb.quantity) from docrowbatches drb join storedocuments2 sd2 on sd2.id=drb.parent_ID where sd2.RDocumentRow_ID='
                                                                            + QuotedStr(mbo.GetFieldValueAsString('Parent_ID')) + ' and drb.StoreBatch_ID=' + QuotedStr(mbo.GetFieldValueAsString('X_Batches'))+' ) '
                                                                            +
                                                                            ' + (SELECT sum(X_quantity) FROM DefRollData WHERE (Hidden = ' +QuotedStr('N') + ' ) AND (CLSID = '+QuotedStr('45D1XVW5EY24JBXTOE01EHYRSG')+
                                                                            ' ) AND (X_DE_NAZEV=sd2.id )  and (X_SK_Nazev= ' + quotedstr('') + ' ))))'  }

                                                                               ,mr2);
                                                                      end;




                                                                             // NxShowSimpleMessage(inttostr(mr2.count),nil);
                                                                         if mr2.count=0 then begin
                                                                             NxShowSimpleMessage('Pro šarži nebyl dohledán pohyb ', nil);

//                                                                             exit;
                                                                         end;


                                                                         mquantity:=0;
                                                                         mquantity:=mbo.GetFieldValueAsFloat('X_quantity');
                                                                         for i := 0 to mr2.Count - 1 do begin
                                                                             mSelected.Add(mr2.Strings[i]);
                                                                         end;


                                                                          while mquantity>0 do begin


                                                                                      if mr2.Count>0 then begin
                                                                                         //if mr2.Count=1 then begin
                                                                                         //    mstring:=mr2.Strings[0]; //NxShowSimpleMessage('Zobrazení pohybů',nil);
                                                                                         // end else begin
                                                                                              mstring:= mroll.SingleSelectFromSelected2(mSelected, 'Pohyb šarže: +' + mbo.GetFieldValueAsString('X_batches.name')  + ' v množství ' + NxFloatToIBStr(mquantity), '');
                                                                                         // end;
                                                                                      end;





                                                                                       if mstring='' then begin
                                                                                               mquantity:=mquantity-mquantity;

                                                                                       end else begin

                                                                                                     mBOPohyb:=mbo.ObjectSpace.CreateObject('K3TH0HR5TZDL342W01C0CX3FCC');
                                                                                                         try
                                                                                                               mBOPohyb.Load(mstring,nil);
                                                                                                                 if index=0 then begin


                                                                                                                       mVycerpano:=0;
                                                                                                                       mVycerpano:=  NxIBStrToFloat(mbo.ObjectSpace.SQLSelectFirstAsString('select sum(drb.quantity) from docrowbatches drb join storedocuments2 sd2 on sd2.id=drb.parent_ID where sd2.RDocumentRow_ID='
                                                                                                                                   + quotedstr(mBOPohyb.GetFieldValueAsString('Parent_ID')) + ' and drb.StoreBatch_ID=' + quotedstr(mbo.GetFieldValueAsString('X_batches'))));
                                                                                                                       mPripraveno:=0;
                                                                                                                       mPripraveno:= NxIBStrToFloat(mbo.ObjectSpace.SQLSelectFirstAsString('SELECT sum(X_quantity) FROM DefRollData WHERE (Hidden = ' +quotedstr('N') + ' ) AND (CLSID = '+quotedstr('45D1XVW5EY24JBXTOE01EHYRSG')+ ' ) AND (X_DE_NAZEV='+ quotedstr(mbopohyb.GetFieldValueAsString('ID'))
                                                                                                                                    +  ')  and (X_SK_Nazev= ' + quotedstr('') + ')'));

                                                                                                                       mpomoc:=0;
                                                                                                                           mpomoc:= (mBOPohyb.GetFieldValueAsFloat('Quantity') - mVycerpano - mPripraveno);

                                                                                                                        if mShowDebug then NxShowSimpleMessage('Požadováno ' + NxFloatToIBStr(mquantity)
                                                                                                                                                             + 'mPripraveno ' + NxFloatToIBStr(mPripraveno)
                                                                                                                                                             + 'mVycerpano ' + NxFloatToIBStr(mVycerpano)

                                                                                                                                                              + 'K dispozici ' + NxFloatToIBStr(mpomoc)

                                                                                                                          ,nil);








                                                                                                                           if mquantity<= mpomoc then begin
                                                                                                                                if mShowDebug then NxShowSimpleMessage('Akceptováno množství',nil);
                                                                                                                                mr3:=TStringList.create;
                                                                                                                                     try
                                                                                                                                         mbo.ObjectSpace.SQLSelect('Select ii2.parent_id from IssuedInvoices2 ii2 where ii2.ProvideRow_ID=' + quotedstr(mBOPohyb.GetFieldValueAsstring('Parent_ID')) ,mr3);
                                                                                                                                         if mr3.count>0 then begin
                                                                                                                                               mbo.SetFieldValueAsString('X_parent_ID',mr3.Strings[0]);
                                                                                                                                         end;
                                                                                                                                     finally
                                                                                                                                         mr3.free;
                                                                                                                                     end;

                                                                                                                                     mr3:=TStringList.create;
                                                                                                                                     try
                                                                                                                                         mbo.ObjectSpace.SQLSelect('Select ii2.id from IssuedInvoices2 ii2 where ii2.ProvideRow_ID=' + quotedstr(mBOPohyb.GetFieldValueAsstring('Parent_ID')) ,mr3);
                                                                                                                                         if mr2.count>0 then begin
                                                                                                                                              mbo.SetFieldValueAsString('X_parent2_id',mr3.Strings[0]);
                                                                                                                                         end;
                                                                                                                                     finally
                                                                                                                                         mr3.free;
                                                                                                                                     end;


                                                                                                                                mbo.SetFieldValueAsFloat('X_vychystano',mquantity);
                                                                                                                                mbo.SetFieldValueAsString('X_PM_State','1050000101');
                                                                                                                                mbo.SetFieldValueAsString('X_DEVENOLUX',mBOPohyb.GetFieldValueAsString('Parent_ID.Parent_ID'));
                                                                                                                                mbo.SetFieldValueAsString('X_MX_NAZEV',mBOPohyb.GetFieldValueAsstring('Parent_ID'));
                                                                                                                                mbo.SetFieldValueAsString('X_DE_NAZEV',mBOPohyb.oid);
                                                                                                                                mbo.save;
                                                                                                                                mquantity:=mquantity-mquantity;
                                                                                                                              //  mSelected.remove(mstring);



                                                                                                                           end else begin






                                                                                                                             if mShowDebug then NxShowSimpleMessage('Překročeno množství',nil);
                                                                                                                                mbonew:=mbo.ObjectSpace.CreateObject('45D1XVW5EY24JBXTOE01EHYRSG');
                                                                                                                                          try
                                                                                                                                           mbonew.new;
                                                                                                                                           mbonew.prefill;
                                                                                                                                              mbonew.SetFieldValueAsString('Code',mbo.GetFieldValueAsString('Code'));

                                                                                                                                                  mbonew.SetFieldValueAsString('Name',mbo.GetFieldValueAsString('name'));
                                                                                                                                                  mbonew.SetFieldValueAsString('X_firm_ID',mbo.GetFieldValueAsString('X_Firm_ID'));
                                                                                                                                                  mbonew.SetFieldValueAsString('X_Storecard_ID',mbo.GetFieldValueAsString('X_Storecard_ID'));
                                                                                                                                                  mbonew.SetFieldValueAsDateTime('X_ABRADate',mbo.GetFieldValueAsDateTime('X_ABRADate'));
                                                                                                                                                  mbonew.SetFieldValueAsString('X_Store_ID',mbo.GetFieldValueAsString('X_Store_ID'));
                                                                                                                                                  mbonew.SetFieldValueAsString('X_CreatedBy_ID',mbo.GetFieldValueAsString('X_CreatedBy_ID'));
                                                                                                                                                  mbonew.SetFieldValueAsString('X_Batches',mbo.GetFieldValueAsString('X_Batches'));






                                                                                                                                                  mbonew.SetFieldValueAsString('X_PM_State','1050000101');
                                                                                                                                                  mbonew.SetFieldValueAsString('X_CLSID','O3BDOKTWEFD13ACM03KIU0CLP4');
                                                                                                                                                  mbonew.SetFieldValueAsString('X_PM_State','1050000101');
                                                                                                                                                  mbonew.SetFieldValueAsString('X_DEVENOLUX',mBOPohyb.GetFieldValueAsString('Parent_ID.Parent_ID'));
                                                                                                                                                  mbonew.SetFieldValueAsString('X_MX_NAZEV',mBOPohyb.GetFieldValueAsstring('Parent_ID'));
                                                                                                                                                  mbonew.SetFieldValueAsString('X_DE_NAZEV',mBOPohyb.oid);

                                                                                                                                                  mbonew.SetFieldValueAsFloat('X_quantity',mpomoc);


                                                                                                                                                  mr3:=TStringList.create;
                                                                                                                                                         try
                                                                                                                                                             mbo.ObjectSpace.SQLSelect('Select ii2.parent_id from IssuedInvoices2 ii2 where ii2.ProvideRow_ID=' + quotedstr(mBOPohyb.GetFieldValueAsstring('Parent_ID')) ,mr3);
                                                                                                                                                             if mr3.count>0 then begin
                                                                                                                                                                   mbonew.SetFieldValueAsString('X_parent_ID',mr3.Strings[0]);
                                                                                                                                                             end;
                                                                                                                                                         finally
                                                                                                                                                             mr3.free;
                                                                                                                                                         end;

                                                                                                                                                         mr3:=TStringList.create;
                                                                                                                                                         try
                                                                                                                                                             mbo.ObjectSpace.SQLSelect('Select ii2.id from IssuedInvoices2 ii2 where ii2.ProvideRow_ID=' + quotedstr(mBOPohyb.GetFieldValueAsstring('Parent_ID')) ,mr3);
                                                                                                                                                             if mr2.count>0 then begin
                                                                                                                                                                  mbonew.SetFieldValueAsString('X_parent2_id',mr3.Strings[0]);
                                                                                                                                                             end;
                                                                                                                                                         finally
                                                                                                                                                             mr3.free;
                                                                                                                                                         end;


                                                                                                                                                  mbonew.SetFieldValueAsFloat('X_vychystano',mpomoc);
                                                                                                                                                  if mShowDebug then NxShowSimpleMessage('na novy bude použito' + NxFloatToIBStr(mpomoc),nil);
                                                                                                                                                  //  mSelected.remove(mstring);

                                                                                                                                              if mpomoc>0 then mbonew.save ;

                                                                                                                                                  mquantity:=mquantity-mpomoc;


                                                                                                                                                     if mShowDebug then NxShowSimpleMessage('Upraveno z' + NxFloatToIBStr(mbo.getFieldValueAsfloat('X_quantity'))
                                                                                                                                                                                          + 'na' + NxFloatToIBStr(mquantity)
                                                                                                                                                         ,nil);
                                                                                                                                                     mbo.SetFieldValueAsfloat('X_quantity',(mquantity))       ;
                                                                                                                                                     mbo.SetFieldValueAsFloat('X_vychystano',mquantity);
                                                                                                                                                     mbo.SetFieldValueAsString('X_PM_State','2020000101');
                                                                                                                                                     mbo.SetFieldValueAsString('X_parent_ID','');
                                                                                                                                                     mbo.SetFieldValueAsString('X_parent2_id','');
                                                                                                                                                     mbo.SetFieldValueAsString('X_DEVENOLUX','');
                                                                                                                                                     mbo.SetFieldValueAsString('X_MX_NAZEV','');
                                                                                                                                                     mbo.SetFieldValueAsString('X_DE_NAZEV','');
                                                                                                                                                     mbo.SetFieldValueAsFloat('X_vychystano',0);
                                                                                                                                                  mbo.save;
                                                                                                                                               if mShowDebug then NxShowSimpleMessage('Upraven původní',nil);

                                                                                                                                                     mbo.Refresh;
                                                                                                                                                   if mShowDebug then  NxShowSimpleMessage('Bylo uložen puvodni',nil);
                                                                                                                                            finally
                                                                                                                                                 mbonew.free;
                                                                                                                                            end;




                                                                                                                           end;
                                                                                                                 end;
                                                                                                                 if index=1 then begin
                                                                                                                       mbo.SetFieldValueAsString('X_DEVENOLUX',mBOPohyb.GetFieldValueAsString('Parent_ID.Parent_ID'));
                                                                                                                           mbo.SetFieldValueAsString('X_MX_NAZEV',mBOPohyb.GetFieldValueAsstring('Parent_ID'));
                                                                                                                           mbo.SetFieldValueAsString('X_DE_NAZEV',mBOPohyb.oid);
                                                                                                                           mbo.SetFieldValueAsFloat('X_vychystano',mBOPohyb.GetFieldValueAsFloat('Quantity'));
                                                                                                                           mbo.SetFieldValueAsString('X_PM_State','1050000101');
                                                                                                                           mbo.save;
                                                                                                                 end;
                                                                                                                 if index=2 then begin
                                                                                                                       mbo.SetFieldValueAsString('X_DEVENOLUX',mBOPohyb.GetFieldValueAsString('Parent_ID.Parent_ID'));
                                                                                                                           mbo.SetFieldValueAsString('X_MX_NAZEV',mBOPohyb.GetFieldValueAsstring('Parent_ID'));
                                                                                                                           mbo.SetFieldValueAsString('X_DE_NAZEV',mBOPohyb.oid);
                                                                                                                           mbo.SetFieldValueAsFloat('X_vychystano',mBOPohyb.GetFieldValueAsFloat('Quantity'));
                                                                                                                           mbo.SetFieldValueAsString('X_PM_State','1050000101');
                                                                                                                           mbo.save;
                                                                                                                 end;
                                                                                                         finally
                                                                                                             mBOPohyb.free;
                                                                                                         end;


                                                                                       end;





                                                                           end;






                                                                  finally
                                                                      mr2.free;
                                                                  end;








 end;

msite.Refresh;
end;







//procedure ShowDocExecuteItemNoneFirm(msite:TSiteForm; Index: integer);
procedure ShowDocExecuteItemNoneFirm(Sender: TAction; Index: integer);
var
 mbo,mBONew:TNxCustomBusinessObject;
 L ,mx: TStringList;
 mid:string;
 mPars:TNxParameters;
 mPar:TNxParameter;
 msite:TBusRollSiteForm;
 mr2,mr3:TStringList;
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
 mVycerpano,mPripraveno,mPomoc:double;
 mQuantity:double;
 mopakovani:integer;
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
    mopakovani:=1;
    if mBookmark.count<>0 then mopakovani:=mBookmark.Count ;

    for x := 0 to mopakovani-1 do begin
    if mBookmark.count<>0 then  mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(x));

         mbo:= TBusRollSiteForm(mSite).CurrentObject;                      //ProgressSetPos(1+NxFloor(x/mBookmark.Count*99), inttostr(x) +' z '+inttostr(mBookmark.Count));





          mOLE := GetAbraOLEApplication;
                mroll := mOLE.GetAgenda('S1X0KZC0NJE13C5U00CA141B44');
                mSelected := mOLE.CreateStrings;



                                                            mr2:=TStringList.create;
                                                                  try
                                                                     if index=0 then begin

                                                                        mbo.ObjectSpace.SQLSelect('SELECT a.id FROM DocRowBatches A JOIN StoreDocuments2 SD2 ON SD2.ID=A.Parent_ID JOIN StoreDocuments SD ON SD.ID=SD2.Parent_ID JOIN Firms F ON F.ID=SD.Firm_ID '
                                                                            + ' WHERE (SD.DocQueue_ID IN (SELECT ID FROM  DocQueues WHERE DocumentType IN (''21'')) ) AND  '
                                                                              + '(A.StoreBatch_ID = ' + QuotedStr(mbo.GetFieldValueAsString('X_Batches')) + ' )'


                                                                           { ' and (sd.docdate$date>=' + (Date-(DateDiff)) + ') '


                                                                            + ' AND (SD2.quantity>((select sum(drb.quantity) from docrowbatches drb join storedocuments2 SDRR on SDR.id=drb.parent_ID where SDR.RDocumentRow_ID=SD2.id and drb.StoreBatch_ID=A.StoreBatch_ID))  '
                                                                            +
                                                                            ' + (SELECT sum(DF.X_quantity) FROM DefRollData DF WHERE (Hidden = ' +QuotedStr('N') + ' ) AND (CLSID = '+QuotedStr('45D1XVW5EY24JBXTOE01EHYRSG')+
                                                                            ' ) AND (DF.X_DE_NAZEV=sd2.id ) and (DF.X_SK_Nazev= ' + quotedstr('') + ' ))))'    }

                                                                               ,mr2);







                                                                      end;
                                                                      if index=1 then begin
                                                                        mbo.ObjectSpace.SQLSelect('SELECT a.id FROM DocRowBatches A JOIN StoreDocuments2 SD2 ON SD2.ID=A.Parent_ID JOIN StoreDocuments SD ON SD.ID=SD2.Parent_ID JOIN Firms F ON F.ID=SD.Firm_ID '
                                                                            + ' WHERE (SD.DocQueue_ID IN (SELECT ID FROM  DocQueues WHERE DocumentType IN (''23'')) ) AND '
//                                                                              (sd.docdate$date=' + NxFloatToIBStr(mbo.GetFieldValueAsDateTime('X_ABRADate')) + ') AND'
                                                                              + '(A.StoreBatch_ID = ' + QuotedStr(mbo.GetFieldValueAsString('X_Batches')) + ' )'


                                                                           {
                                                                            + ' AND (a.quantity>((select sum(drb.quantity) from docrowbatches drb join storedocuments2 sd2 on sd2.id=drb.parent_ID where sd2.RDocumentRow_ID='
                                                                            + QuotedStr(mbo.GetFieldValueAsString('Parent_ID')) + ' and drb.StoreBatch_ID=' + QuotedStr(mbo.GetFieldValueAsString('X_Batches'))+' ) '
                                                                            +
                                                                            ' + (SELECT sum(X_quantity) FROM DefRollData WHERE (Hidden = ' +QuotedStr('N') + ' ) AND (CLSID = '+QuotedStr('45D1XVW5EY24JBXTOE01EHYRSG')+
                                                                            ' ) AND (X_DE_NAZEV=sd2.id ) and (X_SK_Nazev= ' + quotedstr('') + ' ))))'  }

                                                                               ,mr2);
                                                                      end;
                                                                      if index=2 then begin
                                                                        mbo.ObjectSpace.SQLSelect('SELECT a.id FROM DocRowBatches A JOIN StoreDocuments2 SD2 ON SD2.ID=A.Parent_ID JOIN StoreDocuments SD ON SD.ID=SD2.Parent_ID JOIN Firms F ON F.ID=SD.Firm_ID '
                                                                            + ' WHERE (SD.DocQueue_ID IN (SELECT ID FROM  DocQueues WHERE DocumentType IN (''20'')) ) AND  '
                                                                              + '(A.StoreBatch_ID = ' + QuotedStr(mbo.GetFieldValueAsString('X_Batches')) + ' )'


                                                                           {
                                                                            + ' AND (SD2.quantity>((select sum(drb.quantity) from docrowbatches drb join storedocuments2 sd2 on sd2.id=drb.parent_ID where sd2.RDocumentRow_ID='
                                                                            + QuotedStr(mbo.GetFieldValueAsString('Parent_ID')) + ' and drb.StoreBatch_ID=' + QuotedStr(mbo.GetFieldValueAsString('X_Batches'))+' ) '
                                                                            +
                                                                            ' + (SELECT sum(X_quantity) FROM DefRollData WHERE (Hidden = ' +QuotedStr('N') + ' ) AND (CLSID = '+QuotedStr('45D1XVW5EY24JBXTOE01EHYRSG')+
                                                                            ' ) AND (X_DE_NAZEV=sd2.id )  and (X_SK_Nazev= ' + quotedstr('') + ' ))))'  }

                                                                               ,mr2);
                                                                      end;




                                                                             // NxShowSimpleMessage(inttostr(mr2.count),nil);
                                                                         if mr2.count=0 then begin
                                                                             NxShowSimpleMessage('Pro šarži nebyl dohledán pohyb ', nil);

//                                                                             exit;
                                                                         end;


                                                                         mquantity:=0;
                                                                         mquantity:=mbo.GetFieldValueAsFloat('X_quantity');
                                                                         for i := 0 to mr2.Count - 1 do begin
                                                                             mSelected.Add(mr2.Strings[i]);
                                                                         end;


                                                                          while mquantity>0 do begin


                                                                                      if mr2.Count>0 then begin
                                                                                         //if mr2.Count=1 then begin
                                                                                         //    mstring:=mr2.Strings[0]; //NxShowSimpleMessage('Zobrazení pohybů',nil);
                                                                                         // end else begin
                                                                                              mstring:= mroll.SingleSelectFromSelected2(mSelected, 'Pohyb šarže: +' + mbo.GetFieldValueAsString('X_batches.name')  + ' v množství ' + NxFloatToIBStr(mquantity), '');
                                                                                         // end;
                                                                                      end;





                                                                                       if mstring='' then begin
                                                                                               mquantity:=mquantity-mquantity;

                                                                                       end else begin

                                                                                                     mBOPohyb:=mbo.ObjectSpace.CreateObject('K3TH0HR5TZDL342W01C0CX3FCC');
                                                                                                         try
                                                                                                               mBOPohyb.Load(mstring,nil);
                                                                                                                 if index=0 then begin


                                                                                                                       mVycerpano:=0;
                                                                                                                       mVycerpano:=  NxIBStrToFloat(mbo.ObjectSpace.SQLSelectFirstAsString('select sum(drb.quantity) from docrowbatches drb join storedocuments2 sd2 on sd2.id=drb.parent_ID where sd2.RDocumentRow_ID='
                                                                                                                                   + quotedstr(mBOPohyb.GetFieldValueAsString('Parent_ID')) + ' and drb.StoreBatch_ID=' + quotedstr(mbo.GetFieldValueAsString('X_batches'))));
                                                                                                                       mPripraveno:=0;
                                                                                                                       mPripraveno:= NxIBStrToFloat(mbo.ObjectSpace.SQLSelectFirstAsString('SELECT sum(X_quantity) FROM DefRollData WHERE (Hidden = ' +quotedstr('N') + ' ) AND (CLSID = '+quotedstr('45D1XVW5EY24JBXTOE01EHYRSG')+ ' ) AND (X_DE_NAZEV='+ quotedstr(mbopohyb.GetFieldValueAsString('ID'))
                                                                                                                                    +  ')  and (X_SK_Nazev= ' + quotedstr('') + ')'));

                                                                                                                       mpomoc:=0;
                                                                                                                           mpomoc:= (mBOPohyb.GetFieldValueAsFloat('Quantity') - mVycerpano - mPripraveno);

                                                                                                                        if mShowDebug then NxShowSimpleMessage('Požadováno ' + NxFloatToIBStr(mquantity)
                                                                                                                                                             + 'mPripraveno ' + NxFloatToIBStr(mPripraveno)
                                                                                                                                                             + 'mVycerpano ' + NxFloatToIBStr(mVycerpano)

                                                                                                                                                              + 'K dispozici ' + NxFloatToIBStr(mpomoc)

                                                                                                                          ,nil);








                                                                                                                           if mquantity<= mpomoc then begin
                                                                                                                                if mShowDebug then NxShowSimpleMessage('Akceptováno množství',nil);
                                                                                                                                mr3:=TStringList.create;
                                                                                                                                     try
                                                                                                                                         mbo.ObjectSpace.SQLSelect('Select ii2.parent_id from IssuedInvoices2 ii2 where ii2.ProvideRow_ID=' + quotedstr(mBOPohyb.GetFieldValueAsstring('Parent_ID')) ,mr3);
                                                                                                                                         if mr3.count>0 then begin
                                                                                                                                               mbo.SetFieldValueAsString('X_parent_ID',mr3.Strings[0]);
                                                                                                                                         end;
                                                                                                                                     finally
                                                                                                                                         mr3.free;
                                                                                                                                     end;

                                                                                                                                     mr3:=TStringList.create;
                                                                                                                                     try
                                                                                                                                         mbo.ObjectSpace.SQLSelect('Select ii2.id from IssuedInvoices2 ii2 where ii2.ProvideRow_ID=' + quotedstr(mBOPohyb.GetFieldValueAsstring('Parent_ID')) ,mr3);
                                                                                                                                         if mr2.count>0 then begin
                                                                                                                                              mbo.SetFieldValueAsString('X_parent2_id',mr3.Strings[0]);
                                                                                                                                         end;
                                                                                                                                     finally
                                                                                                                                         mr3.free;
                                                                                                                                     end;


                                                                                                                                mbo.SetFieldValueAsFloat('X_vychystano',mquantity);
                                                                                                                                mbo.SetFieldValueAsString('X_PM_State','1050000101');
                                                                                                                                mbo.SetFieldValueAsString('X_DEVENOLUX',mBOPohyb.GetFieldValueAsString('Parent_ID.Parent_ID'));
                                                                                                                                mbo.SetFieldValueAsString('X_MX_NAZEV',mBOPohyb.GetFieldValueAsstring('Parent_ID'));
                                                                                                                                mbo.SetFieldValueAsString('X_DE_NAZEV',mBOPohyb.oid);
                                                                                                                                mbo.save;
                                                                                                                                mquantity:=mquantity-mquantity;
                                                                                                                              //  mSelected.remove(mstring);



                                                                                                                           end else begin






                                                                                                                             if mShowDebug then NxShowSimpleMessage('Překročeno množství',nil);
                                                                                                                                mbonew:=mbo.ObjectSpace.CreateObject('45D1XVW5EY24JBXTOE01EHYRSG');
                                                                                                                                          try
                                                                                                                                           mbonew.new;
                                                                                                                                           mbonew.prefill;
                                                                                                                                              mbonew.SetFieldValueAsString('Code',mbo.GetFieldValueAsString('Code'));

                                                                                                                                                  mbonew.SetFieldValueAsString('Name',mbo.GetFieldValueAsString('name'));
                                                                                                                                                  mbonew.SetFieldValueAsString('X_firm_ID',mbo.GetFieldValueAsString('X_Firm_ID'));
                                                                                                                                                  mbonew.SetFieldValueAsString('X_Storecard_ID',mbo.GetFieldValueAsString('X_Storecard_ID'));
                                                                                                                                                  mbonew.SetFieldValueAsDateTime('X_ABRADate',mbo.GetFieldValueAsDateTime('X_ABRADate'));
                                                                                                                                                  mbonew.SetFieldValueAsString('X_Store_ID',mbo.GetFieldValueAsString('X_Store_ID'));
                                                                                                                                                  mbonew.SetFieldValueAsString('X_CreatedBy_ID',mbo.GetFieldValueAsString('X_CreatedBy_ID'));
                                                                                                                                                  mbonew.SetFieldValueAsString('X_Batches',mbo.GetFieldValueAsString('X_Batches'));






                                                                                                                                                  mbonew.SetFieldValueAsString('X_PM_State','1050000101');
                                                                                                                                                  mbonew.SetFieldValueAsString('X_CLSID','O3BDOKTWEFD13ACM03KIU0CLP4');
                                                                                                                                                  mbonew.SetFieldValueAsString('X_PM_State','1050000101');
                                                                                                                                                  mbonew.SetFieldValueAsString('X_DEVENOLUX',mBOPohyb.GetFieldValueAsString('Parent_ID.Parent_ID'));
                                                                                                                                                  mbonew.SetFieldValueAsString('X_MX_NAZEV',mBOPohyb.GetFieldValueAsstring('Parent_ID'));
                                                                                                                                                  mbonew.SetFieldValueAsString('X_DE_NAZEV',mBOPohyb.oid);

                                                                                                                                                  mbonew.SetFieldValueAsFloat('X_quantity',mpomoc);


                                                                                                                                                  mr3:=TStringList.create;
                                                                                                                                                         try
                                                                                                                                                             mbo.ObjectSpace.SQLSelect('Select ii2.parent_id from IssuedInvoices2 ii2 where ii2.ProvideRow_ID=' + quotedstr(mBOPohyb.GetFieldValueAsstring('Parent_ID')) ,mr3);
                                                                                                                                                             if mr3.count>0 then begin
                                                                                                                                                                   mbonew.SetFieldValueAsString('X_parent_ID',mr3.Strings[0]);
                                                                                                                                                             end;
                                                                                                                                                         finally
                                                                                                                                                             mr3.free;
                                                                                                                                                         end;

                                                                                                                                                         mr3:=TStringList.create;
                                                                                                                                                         try
                                                                                                                                                             mbo.ObjectSpace.SQLSelect('Select ii2.id from IssuedInvoices2 ii2 where ii2.ProvideRow_ID=' + quotedstr(mBOPohyb.GetFieldValueAsstring('Parent_ID')) ,mr3);
                                                                                                                                                             if mr2.count>0 then begin
                                                                                                                                                                  mbonew.SetFieldValueAsString('X_parent2_id',mr3.Strings[0]);
                                                                                                                                                             end;
                                                                                                                                                         finally
                                                                                                                                                             mr3.free;
                                                                                                                                                         end;


                                                                                                                                                  mbonew.SetFieldValueAsFloat('X_vychystano',mpomoc);
                                                                                                                                                  if mShowDebug then NxShowSimpleMessage('na novy bude použito' + NxFloatToIBStr(mpomoc),nil);
                                                                                                                                                  //  mSelected.remove(mstring);

                                                                                                                                              if mpomoc>0 then mbonew.save ;

                                                                                                                                                  mquantity:=mquantity-mpomoc;


                                                                                                                                                     if mShowDebug then NxShowSimpleMessage('Upraveno z' + NxFloatToIBStr(mbo.getFieldValueAsfloat('X_quantity'))
                                                                                                                                                                                          + 'na' + NxFloatToIBStr(mquantity)
                                                                                                                                                         ,nil);
                                                                                                                                                     mbo.SetFieldValueAsfloat('X_quantity',(mquantity))       ;
                                                                                                                                                     mbo.SetFieldValueAsFloat('X_vychystano',mquantity);
                                                                                                                                                     mbo.SetFieldValueAsString('X_PM_State','2020000101');
                                                                                                                                                     mbo.SetFieldValueAsString('X_parent_ID','');
                                                                                                                                                     mbo.SetFieldValueAsString('X_parent2_id','');
                                                                                                                                                     mbo.SetFieldValueAsString('X_DEVENOLUX','');
                                                                                                                                                     mbo.SetFieldValueAsString('X_MX_NAZEV','');
                                                                                                                                                     mbo.SetFieldValueAsString('X_DE_NAZEV','');
                                                                                                                                                     mbo.SetFieldValueAsFloat('X_vychystano',0);
                                                                                                                                                  mbo.save;
                                                                                                                                               if mShowDebug then NxShowSimpleMessage('Upraven původní',nil);

                                                                                                                                                     mbo.Refresh;
                                                                                                                                                    if mShowDebug then NxShowSimpleMessage('Byl uložen puvodni',nil);
                                                                                                                                            finally
                                                                                                                                                 mbonew.free;
                                                                                                                                            end;




                                                                                                                           end;
                                                                                                                 end;
                                                                                                                 if index=1 then begin
                                                                                                                       mbo.SetFieldValueAsString('X_DEVENOLUX',mBOPohyb.GetFieldValueAsString('Parent_ID.Parent_ID'));
                                                                                                                           mbo.SetFieldValueAsString('X_MX_NAZEV',mBOPohyb.GetFieldValueAsstring('Parent_ID'));
                                                                                                                           mbo.SetFieldValueAsString('X_DE_NAZEV',mBOPohyb.oid);
                                                                                                                           mbo.SetFieldValueAsFloat('X_vychystano',mBOPohyb.GetFieldValueAsFloat('Quantity'));
                                                                                                                           mbo.SetFieldValueAsString('X_PM_State','1050000101');
                                                                                                                           mbo.save;
                                                                                                                 end;
                                                                                                                 if index=2 then begin
                                                                                                                       mbo.SetFieldValueAsString('X_DEVENOLUX',mBOPohyb.GetFieldValueAsString('Parent_ID.Parent_ID'));
                                                                                                                           mbo.SetFieldValueAsString('X_MX_NAZEV',mBOPohyb.GetFieldValueAsstring('Parent_ID'));
                                                                                                                           mbo.SetFieldValueAsString('X_DE_NAZEV',mBOPohyb.oid);
                                                                                                                           mbo.SetFieldValueAsFloat('X_vychystano',mBOPohyb.GetFieldValueAsFloat('Quantity'));
                                                                                                                           mbo.SetFieldValueAsString('X_PM_State','1050000101');
                                                                                                                           mbo.save;
                                                                                                                 end;
                                                                                                         finally
                                                                                                             mBOPohyb.free;
                                                                                                         end;


                                                                                       end;





                                                                           end;






                                                                  finally
                                                                      mr2.free;
                                                                  end;








 end;

msite.Refresh;





end;

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
 mdocID:string;
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
        try

                   for x := 0 to mBookmark.Count- 1 do begin
                    mDBGrid.DataSource.DataSet.GotoBookmark(mBookMark.items(x));

                          mbo:= TBusRollSiteForm(mSite).CurrentObject;                      //ProgressSetPos(1+NxFloor(x/mBookmark.Count*99), inttostr(x) +' z '+inttostr(mBookmark.Count));
                                   mfind:=false;



                                   for ii:=0 to mr2.count-1 do begin

                                         if index=0 then begin
                                                mdocid:='';
                                                mdocid:=mbo.GetFieldValueAsString('X_Devenolux');

                                                if mr2.strings[ii]=mdocid then mfind:=true;
                                         end;
                                         if index=1 then begin
                                                mdocid:='';
                                                mdocid:= mbo.GetFieldValueAsString('X_Parent_ID')  ;
                                                 if ii=0 then mr2.Add(mdocid);
                                                if mr2.strings[ii]=mdocid then mfind:=true;
                                         end;
                                         if index=2 then begin
                                                mdocid:='';
                                                mdocid:=msite.BaseObjectSpace.SQLSelectFirstAsString('Select Parent_ID from IssuedCreditNotes2 where id=' + quotedstr(mbo.GetFieldValueAsString('X_CZ_Nazev')));
                                                if ii=0 then mr2.Add(mdocid);
                                                if mr2.strings[ii]=mdocid then mfind:=true;
                                         end;
                                         if index=3 then begin
                                                mdocid:='';
                                                mdocid:=msite.BaseObjectSpace.SQLSelectFirstAsString('Select Parent_ID from Storedocuments2 where id=' + quotedstr(mbo.GetFieldValueAsString('X_SK_Nazev')));
                                                if ii=0 then mr2.Add(mdocid);
                                                if mr2.strings[ii]=mdocid then mfind:=true;
                                         end;
                                         if index=4 then begin
                                                mdocid:='';
                                                mdocid:=mbo.GetFieldValueAsString('X_DE_NAZEV');
                                                if ii=0 then mr2.Add(mdocid);
                                                if mr2.strings[ii]=mdocid then mfind:=true;
                                         end;
                                         if index=5 then begin
                                                mdocid:='';
                                                mdocid:=mbo.GetFieldValueAsString('X_EN_NAZEV');
                                                if ii=0 then mr2.Add(mdocid);
                                                if mr2.strings[ii]=mdocid then mfind:=true;
                                         end;


                                   end;
                                   if ii=0 then begin
                                       if index=0 then begin
                                                mdocid:='';
                                                mdocid:=mbo.GetFieldValueAsString('X_Devenolux');
                                       end;
                                        if index=1 then begin
                                                mdocid:='';
                                                mdocid:= mbo.GetFieldValueAsString('X_Parent_ID')  ;
                                         end;
                                          if index=2 then begin
                                                mdocid:='';
                                                mdocid:=msite.BaseObjectSpace.SQLSelectFirstAsString('Select Parent_ID from IssuedCreditNotes2 where id=' + quotedstr(mbo.GetFieldValueAsString('X_CZ_Nazev')));
                                        end;
                                          if index=3 then begin
                                                mdocid:='';
                                                mdocid:=msite.BaseObjectSpace.SQLSelectFirstAsString('Select Parent_ID from Storedocuments2 where id=' + quotedstr(mbo.GetFieldValueAsString('X_SK_Nazev')));
                                         end;
                                         if index=4 then begin
                                                mdocid:='';
                                                mdocid:=mbo.GetFieldValueAsString('X_DE_NAZEV');
                                         end;
                                         if index=5 then begin
                                                mdocid:='';
                                                mdocid:=mbo.GetFieldValueAsString('X_EN_NAZEV');
                                         end;
                                   end;
                                   if not mfind  then mr2.Add(mdocid);

                   end;
                   mr2.Sort;
                   if mr2.count>0 then begin
                         if index=0 then ShowSelectedDynForm(msite, mr2, 'B50I5SAOS3DL3ACU03KIU0CLP4','Použité doklady z TMP ' + inttostr(mr2.count)+ '_' +(mr2.strings[0]));
                         if index=1 then ShowSelectedDynForm(msite, mr2, 'PLC2EX0BUJD13ACP03KIU0CLP4','Použité doklady z TMP ' + inttostr(mr2.count)+ '_' +(mr2.strings[0]));
                         if index=2 then ShowSelectedDynForm(msite, mr2, 'T1C2EX0BUJD13ACP03KIU0CLP4','Použité doklady z TMP ' + inttostr(mr2.count)+ '_' +(mr2.strings[0]));
                         if index=3 then ShowSelectedDynForm(msite, mr2, 'BL0I5SAOS3DL3ACU03KIU0CLP4','Použité doklady z TMP ' + inttostr(mr2.count)+ '_' +(mr2.strings[0]));
                         if index=4 then ShowSelectedDynForm(msite, mr2, 'S1X0KZC0NJE13C5U00CA141B44','Použité doklady z TMP ' + inttostr(mr2.count)+ '_' +(mr2.strings[0]));
                         if index=5 then ShowSelectedDynForm(msite, mr2, 'S1X0KZC0NJE13C5U00CA141B44','Použité doklady z TMP ' + inttostr(mr2.count)+ '_' +(mr2.strings[0]));
                   end;

      finally
          mr2.free;
      end;

end;





begin
end.