uses '_Knihovny_ALL.Parse',
     '_Knihovny_ALL.Komunikace',
     '_Knihovny_ALL.Parse',
     'NxApiProp.Prop';


function POST_APIAPPNxJSONImportManager(AContext: TNxContext; InputString: String; APath: String): string;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
  mstring:string;
  mr:tstringlist;
  i,x,y,mIRows,mIBatchs,mri: integer;
  iJSONDocuments,iJSONRows,iJSONBatches:integer;
  mQuery:string;
  mInputDocumentClsid,mOutputDocumentClsid,mDocqueue_ID:string;
  AInput,AOutput,mDocument:TJSONSuperObject;
  mInputDocuments:tstringlist;
  mFindDoc,mFindRow:boolean;
  mParams, mP : TNxParameters;
  mPar : TNxParameter;
  mManager : TNxDocumentImportManager ;
  mRow,mbo, mRow_OP, mOP,mOutputDocument,mBatch,mBO_PohybSarze : TNxCustomBusinessObject;
  mRows, mRows_OP,mRowsOutput,mMonBatches : TNxCustomBusinessMonikerCollection;
  mValidateList,mSelectedRows,mrx:tstringlist;
  mText,mSelectedHeader:string;
  mImportMan: TNxDocumentImportManager;
  mFind:boolean;
  mJSONDocuments,mJSONRows,mJSONBatches: TJSONSuperObjectArray;
  mJSONWork,mJSONDocument,mJSONRow,mJSONBatch,mJSONParameter:TJSONSuperObject;
  mDocuments,mStoreDocQueue_ID:string;
  mImportdocuments,mImportRows,mImportBatches,mOtherRows,mOtherBatches,mNotSaveRows,mNotsaveBatches:TStringList;
  mStore_ID,mFirm_ID,mDivision_ID:string;
  mpomocpocet,mUseQuantity:double;
  mPomocSarze,mUseSarze:double;
  mpocet:double;
  mDocInputDocument:string;
  mDebug,mWithPrices:boolean;
  mi:integer;
  mUser,mUser_ID:string;
  mMsgUser,mMsgUser_ID:string;
  mEmail,mMesager:string;
  mSales:boolean;
  mFile:string;
  mDocrowbatchList,mPrintList:TStringList;
  mPomocMnozstvi:double;
  mlist:tstringlist;
  mdescription:string;
  mOtherAbra:string;
  mAllDocument:Boolean;
  Result_String:string;
  mFirmOffice_ID:string;
  mImport,mOnlyImport:boolean;
  mID_Sarze:string;
  mParseValue,mParseValueBatch:tstringlist;
  mTMPString,mxTarget:string;
  aname,blat_File,mxid:string;
  mDynCLSID:string;
  mStringParameter:string;
  mJsonString:string;
begin
     mJsonString:='';
     mStringParameter:='';
      mJSONWork:=TJSONSuperObject.create;
      AInput:=TJSONSuperObject.create;
      mJSONParameter:=TJSONSuperObject.create;
      mJSONWork:=TJSONSuperObject.ParseString(InputString,true);
      //ainput:=InputString;
      AOutput:=TJSONSuperObject.create;
   if UpperCase(mJSONWork.S['DocumentType'])<>'' then begin
               if trim(mJSONWork.A['AbraDocuments'].O[0].S['DocNumber'])<>'' then begin

                           if (AnsiPos('-', mJSONWork.A['AbraDocuments'].O[0].S['DocNumber'])>0) and (AnsiPos('/', mJSONWork.A['AbraDocuments'].O[0].S['DocNumber'])>0) then begin
                                      case UpperCase(mJSONWork.S['DocumentType']) of
                                        'RO' :begin
                                              mOutputDocumentClsid:='01CPMINJW3DL342X01C0CX3FCC';
                                                    mStringParameter:= AContext.SQLSelectFirstAsString('Select X_API_OP from DocQUEUES where code=' + quotedstr(trim(copy(mJSONWork.A['AbraDocuments'].O[0].S['DocNumber'],1,AnsiPos('-', mJSONWork.A['AbraDocuments'].O[0].S['DocNumber'])-1))));

                                              end;
                                        'IO' :begin
                                              mOutputDocumentClsid:='CDMK5QAWZZDL342X01C0CX3FCC';
                                                  mStringParameter:= AContext.SQLSelectFirstAsString('Select X_API_OV from DocQUEUES where code=' + quotedstr(trim(copy(mJSONWork.A['AbraDocuments'].O[0].S['DocNumber'],1,AnsiPos('-', mJSONWork.A['AbraDocuments'].O[0].S['DocNumber'])-1))));
                                              end;
                                        '03' :begin
                                              mOutputDocumentClsid:='';
                                                  mStringParameter:= AContext.SQLSelectFirstAsString('Select X_API_FV from DocQUEUES where code=' + quotedstr(trim(copy(mJSONWork.A['AbraDocuments'].O[0].S['DocNumber'],1,AnsiPos('-', mJSONWork.A['AbraDocuments'].O[0].S['DocNumber'])-1))));
                                              end;
                                        '20' :begin
                                              mOutputDocumentClsid:='E03ZNUMDTCC4PDAUIEY1MBTJC0';
                                                  mStringParameter:= AContext.SQLSelectFirstAsString('Select X_API_PR from DocQUEUES where code=' + quotedstr(trim(copy(mJSONWork.A['AbraDocuments'].O[0].S['DocNumber'],1,AnsiPos('-', mJSONWork.A['AbraDocuments'].O[0].S['DocNumber'])-1))));
                                              end;
                                        '21' :begin
                                              mOutputDocumentClsid:='050I5SAOS3DL3ACU03KIU0CLP4';
                                                  mStringParameter:= AContext.SQLSelectFirstAsString('Select X_API_DL from DocQUEUES where code=' + quotedstr(trim(copy(mJSONWork.A['AbraDocuments'].O[0].S['DocNumber'],1,AnsiPos('-', mJSONWork.A['AbraDocuments'].O[0].S['DocNumber'])-1))));
                                              end;

                                        '23' :begin
                                              mOutputDocumentClsid:='0P0I5SAOS3DL3ACU03KIU0CLP4';
                                                  mStringParameter:= AContext.SQLSelectFirstAsString('Select X_API_FV from DocQUEUES where code=' + quotedstr(trim(copy(mJSONWork.A['AbraDocuments'].O[0].S['DocNumber'],1,AnsiPos('-', mJSONWork.A['AbraDocuments'].O[0].S['DocNumber'])-1))));
                                              end;
                                         '': begin
                                              mOutputDocumentClsid:='';
                                          End;

                                     end;
                           end else begin
                                   AOutput.S['State']:=  '400 - Nekorektní číslo zdrojového dokladu ';
                                   AOutput.S['Error']:= ' Neuvedeny importní parametry';
                                   AOutput.S['SendDocument']:=NxSearchReplace(mJSONWork.A['AbraDocuments'].O[0].S['DocNumber'],'_','/',[srCase,srAll]);
                                   result:=AOutput.AsString;
                                   exit;
                           end;

                     if trim(mStringParameter)='' then begin
                          AOutput.S['State']:=  '400 ';
                          AOutput.S['Error']:= ' Neuvedeny importní parametry';
                          AOutput.S['SendDocument']:=NxSearchReplace(mJSONWork.A['AbraDocuments'].O[0].S['DocNumber'],'_','/',[srCase,srAll]);
                          result:=AOutput.AsString;
                          exit;
                      end else begin
                          mJsonString:=Copy(mStringParameter,1,Length(mStringParameter)-1) +','+ Copy(trim(mJSONWork.AsString),2,Length(trim(mJSONWork.AsString))-1);
                          AInput:= TJSONSuperObject.ParseString(mJsonString, True);

                          //result:=mJsonString;
                          //result:=AInput.AsString;
//
                          //exit;
                     end;
               end;

      try




      mDebug:=False;
      mUser_ID:='';
      mMsgUser_ID:='';
      mDocInputDocument:='';






         mInputDocumentClsid:='';
         try
         mInputDocumentClsid:=AInput.S['InputClsid'];
         finally

         end;
         mOutputDocumentClsid:='';
         try
         mOutputDocumentClsid:=AInput.S['OutputClsid'];
         finally
         end;


         mr:=TStringList.create;
                try
                     if trim(AInput.A['AbraDocuments'].O[0].S['DocNumber'])<>'' then begin
                             case mOutputDocumentClsid of
                                  '01CPMINJW3DL342X01C0CX3FCC': begin
                                           AContext.GetObjectSpace.SQLSelect('select DQ.Code ||'+QuotedStr('-')+ '|| CAST(A.OrdNumber AS VARCHAR(10)) || '+QuotedStr('/')+ ' || P.Code,a.DocDate$DATE,SU.LoginName,a.id from Receivedorders A join Periods P on p.id=a.Period_ID join Docqueues DQ on DQ.id=A.Docqueue_ID join SecurityUsers SU on SU.ID=a.Createdby_ID where X_ExternalDocument=' + quotedstr(NxSearchReplace(AInput.A['AbraDocuments'].O[0].S['DocNumber'],'_','/',[srCase,srAll]))
                                           ,mr);
                                       end;

                                  'CDMK5QAWZZDL342X01C0CX3FCC': begin
                                           AContext.GetObjectSpace.SQLSelect('select DQ.Code || '+QuotedStr('-')+ ' || CAST(A.OrdNumber AS VARCHAR(10)) || '+QuotedStr('/')+ ' || P.Code,a.DocDate$DATE,SU.LoginName,a.id from Issuedorders A join Periods P on p.id=a.Period_ID join Docqueues DQ on DQ.id=A.Docqueue_ID join SecurityUsers SU on SU.ID=a.Createdby_ID where X_ExternalDocument=' + quotedstr(NxSearchReplace(AInput.A['AbraDocuments'].O[0].S['DocNumber'],'_','/',[srCase,srAll]))
                                           ,mr);
                                       end;

                                  'E03ZNUMDTCC4PDAUIEY1MBTJC0': begin
                                           AContext.GetObjectSpace.SQLSelect('select DQ.Code || '+QuotedStr('-')+ ' || CAST(A.OrdNumber AS VARCHAR(10)) || '+QuotedStr('/')+ ' || P.Code,a.DocDate$DATE,SU.LoginName,a.id from Storedocuments A join Periods P on p.id=a.Period_ID join Docqueues DQ on DQ.id=A.Docqueue_ID join SecurityUsers SU on SU.ID=a.Createdby_ID where X_ExternalDocument=' + quotedstr(NxSearchReplace(AInput.A['AbraDocuments'].O[0].S['DocNumber'],'_','/',[srCase,srAll])) + ' and A.DocumentType='+quotedstr('20')
                                           ,mr);
                                       end;

                                  '050I5SAOS3DL3ACU03KIU0CLP4': begin
                                  //         AContext.GetObjectSpace.SQLSelect('select DQ.Code || '+QuotedStr('-')+ ' || CAST(A.OrdNumber AS VARCHAR(10)) || '+QuotedStr('/')+ ' || P.Code,a.DocDate$DATE,SU.LoginName,a.id from Storedocuments A join Periods P on p.id=a.Period_ID join Docqueues DQ on DQ.id=A.Docqueue_ID join SecurityUsers SU on SU.ID=a.Createdby_ID where X_ExternalDocument=' + quotedstr(NxSearchReplace(AInput.A['AbraDocuments'].O[0].S['DocNumber'],'_','/',[srCase,srAll])) + ' and A.DocumentType='+quotedstr('21')
                                  //         ,mr);
                                       end;


                                  '0P0I5SAOS3DL3ACU03KIU0CLP4': begin
                                           AContext.GetObjectSpace.SQLSelect('select DQ.Code || '+QuotedStr('-')+ ' || CAST(A.OrdNumber AS VARCHAR(10)) || '+QuotedStr('/')+ ' || P.Code,a.DocDate$DATE,SU.LoginName,a.id from Storedocuments A join Periods P on p.id=a.Period_ID join Docqueues DQ on DQ.id=A.Docqueue_ID join SecurityUsers SU on SU.ID=a.Createdby_ID where X_ExternalDocument=' + quotedstr(NxSearchReplace(AInput.A['AbraDocuments'].O[0].S['DocNumber'],'_','/',[srCase,srAll])) + ' and A.DocumentType='+quotedstr('22')
                                           ,mr);
                                       end;

                             end;
                      end;
                     if mr.count>0 then begin
                         AOutput.S['State']:= '200';
                         mTMPString:=mr.Strings[0];
                         mTMPString:=NxSearchReplace(mTMPString,'"','',[srCase,srAll]);
                         mParseValue:=tstringlist;
                         try
                            mParseValue:=FNParsevalue(mTMPString,';') ;
                            if mParseValue.count>2 then begin
                                 AOutput.S['Error']:= mParseValue.strings[1];
                                 AOutput.S['SendDocument']:=NxSearchReplace(AInput.A['AbraDocuments'].O[0].S['DocNumber'],'_','/',[srCase,srAll]);
                                   AOutput.S['Created_by']:=mParseValue.strings[2];
                                   AOutput.S['ID']:=mParseValue.strings[3];
                                   AOutput.S['New']:=mParseValue.strings[0];;
                                   AOutput.S['Source']:=mDocInputDocument;
                                   AOutput.S['Import']:=inttostr(0) ;
                                   AOutput.S['Other']:=inttostr(0);
                                   AOutput.S['Imp_batch']:=inttostr(0);
                                   AOutput.S['Oth_batch']:=inttostr(0);
                                   AOutput.S['NotSave']:=inttostr(0) ;
                                   AOutput.S['NotSave_batch']:=inttostr(0);
                                   result:=AOutput.AsString;
                                   exit;
                            end;
                         finally
                             mParseValue.free;
                         end;

                     end;
                finally
                    mr.free;
                end;




            ;



         mAllDocument:=false;
         try
              if uppercase(AInput.S['ImportAllDocument'])='TRUE' then mAllDocument:=True else mAllDocument:=false;
         finally

         end;

         mDebug:=False;
         try
               if uppercase(AInput.S['Debug'])='TRUE' then mDebug:=True else mDebug:=false;
         finally
         end;

         mImport:=True;
         try
              if trim(uppercase(AInput.S['Import']))='TRUE' then mImport:=True else mImport:=false;
         finally

         end;

         mOnlyImport:=false;
         try
                if trim(uppercase(AInput.S['OnlyImport']))='TRUE' then mOnlyImport:=True else mOnlyImport:=false;
         finally
         end;

         mWithPrices:=True;
         try
                 if uppercase(AInput.S['WithPrices'])='TRUE' then mWithPrices:=True else mWithPrices:=false;
         finally

         end;





        mDocQueue_ID:='';
        if trim(AInput.S['DocQueue_Code'])<>'' then begin
                mr:=TStringList.create;
                try
                     AContext.GetObjectSpace.SQLSelect('select id from Docqueues where code=' + quotedstr(AInput.S['DocQueue_Code']) + ' and hidden=' + quotedstr('N') ,mr);
                     if mr.count>0 then begin
                         mDocQueue_ID:=mr.Strings[0];
                     end;
                finally
                    mr.free;
                end;
        end;

        mStoreDocQueue_ID:='';
        if trim(AInput.S['StoreDocQueue_code'])<>'' then begin
              mr:=TStringList.create;
              try
                   AContext.GetObjectSpace.SQLSelect('select id from Docqueues where code=' + quotedstr(AInput.S['StoreDocQueue_code']) + ' and hidden=' + quotedstr('N') ,mr);
                   if mr.count>0 then begin
                       mStoreDocQueue_ID:=mr.Strings[0];
                   end;
              finally
                  mr.free;
              end;
        end;

        mFirm_ID:='';
        if trim(AInput.S['Firm_Name'])<>'' then begin
                mr:=TStringList.create;
                try
                     AContext.GetObjectSpace.SQLSelect('select id from firms where name=' + quotedstr(AInput.S['Firm_Name']) + ' and hidden=' + quotedstr('N')
                                                     + ' and Firm_id is null',mr);
                     if mr.count>0 then begin
                         mFirm_ID:=mr.Strings[0];
                     end;
                finally
                    mr.free;
                end;
        end;




        mStore_ID:='';
        if trim(AInput.S['Store_Code'])<>'' then begin
                mr:=TStringList.create;
                try
                     AContext.GetObjectSpace.SQLSelect('select id from Stores where code=' + quotedstr(AInput.S['Store_Code']) + ' and hidden=' + quotedstr('N') ,mr);
                     if mr.count>0 then begin
                         mStore_ID:=mr.Strings[0];
                     end;
                finally
                    mr.free;
                end;
        end;


        mDivision_ID:='';
        if trim(AInput.S['Division_Code'])<>'' then begin
                mr:=TStringList.create;
                try
                     AContext.GetObjectSpace.SQLSelect('select id from Divisions where code=' + quotedstr(AInput.S['Division_Code']) + ' and hidden=' + quotedstr('N') ,mr);
                     if mr.count>0 then begin
                         mDivision_ID:=mr.Strings[0];
                     end;
                finally
                    mr.free;
                end;
        end;

        mUser_ID:='';
        if trim(AInput.S['User'])<>'' then begin
                mr:=TStringList.create;
                try
                     AContext.GetObjectSpace.SQLSelect('select id from SecurityUsers where LoginName=' + quotedstr(AInput.S['User']) ,mr);
                     if mr.count>0 then begin
                         mUser_ID:=mr.Strings[0];
                       //  if mUser_ID='SUPER00000' then  mUser_ID:='';
                     end;
                finally
                    mr.free;
                end;
        end;




       mMsgUser:='';
       if trim(AInput.S['Msg'])<>'' then begin
              mr:=TStringList.create;
              try
                   AContext.GetObjectSpace.SQLSelect('select id from SecurityUsers where LoginName=' + quotedstr(AInput.S['Msg']) ,mr);
                   if mr.count>0 then begin
                       mMsgUser_ID:=mr.Strings[0];
                   end;
              finally
                  mr.free;
              end;
        end;


  finally

  end;



  mImportdocuments:=TStringList.create;
  mImportRows:=TStringList.create;
  mOtherRows:=TStringList.create;
  mOtherBatches:=TStringList.create;
  mImportBatches:=TStringList.create;
  mSelectedRows:=TstringList.Create;
  mNotSaveRows:=TstringList.Create;
  mNotsaveBatches:=TstringList.Create;

  try



      if true then begin    //// AInput.A['AbraDocuments'].Length>0 then begin                // v poli jSON jsou uvedeny doklady

          for iJSONDocuments := 0 to AInput.A['AbraDocuments'].Length - 1 do begin  // cyklus dokladu
                      if AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].Length>0 then begin
                             for iJSONRows := 0 to AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].Length - 1 do begin  // cyklus řádku dokladu
                                mpomocpocet:=NxIBStrToFloat(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['WorkQuantity']);
                                mr:=tstringlist.create;
                                try
                                    if ((mInputDocumentClsid='01CPMINJW3DL342X01C0CX3FCC') and (mOutputDocumentClsid<>'CDMK5QAWZZDL342X01C0CX3FCC')) then begin
                                            if (mInputDocumentClsid=mOutputDocumentClsid) or not(mImport) then begin
                                                  AContext.GetObjectSpace.SQLSelect('Select id from ReceivedOrders where id is null',mr);
                                            end else begin
                                                  AContext.GetObjectSpace.SQLSelect('Select ro.id,ro2.id,ro2.Store_ID,ro2.Storecard_id,ro2.X_Providerow_ID,X_specifikace_id, X_ExternalSpecification , Division_ID, BusOrder_ID, Bustransaction_id,BusProject_ID, (ro2.quantity-ro2.DeliveredQuantity)'     //,(io2.quantity-io2.DeliveredQuantity)
                                                                      + ' from ReceivedOrders2 ro2 left join ReceivedOrders ro on ro.id=ro2.parent_id '
                                                                      + ' where ro2.X_providerow_ID=' + quotedstr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_ProvideRow_ID'])
                                                                      + ' and ro2.Storecard_ID=' + quotedstr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['StoreCard_ID'])
                                                                      + ' and ro.Closed=' + quotedstr('N')
//                                                                      + ' and ro.IsAvailableForDelivery=' + quotedstr('A')
                                                                      + ' and ro2.quantity>ro2.DeliveredQuantity'
                                                                       ,mr);
                                             end;
                                     end;
                                    // z op do ov
                                    if ((mInputDocumentClsid='01CPMINJW3DL342X01C0CX3FCC') and (mOutputDocumentClsid='CDMK5QAWZZDL342X01C0CX3FCC')) then begin
                                            if (mInputDocumentClsid=mOutputDocumentClsid) or not(mImport) then begin
                                                  AContext.GetObjectSpace.SQLSelect('Select id from ReceivedOrders where id is null',mr);
                                            end else begin
                                                  AContext.GetObjectSpace.SQLSelect('Select ro.id,ro2.id,ro2.Store_ID,ro2.StoreCard_ID,ro2.X_Providerow_ID, ro2.X_specifikace_id, ro2.X_ExternalSpecification , ro2.Division_ID, ro2.BusOrder_ID, ro2.Bustransaction_id,ro2.BusProject_ID,(ro2.quantity-ro2.DeliveredQuantity)'     //,(io2.quantity-io2.DeliveredQuantity)
                                                                      + ' from ReceivedOrders2 ro2 left join ReceivedOrders ro on ro.id=ro2.parent_id '
                                                                      + ' where ro2.X_providerow_ID=' + quotedstr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_ProvideRow_ID'])
                                                                      + ' and ro2.StoreCard_ID=' + quotedstr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['StoreCard_ID'])
                                                                      + ' and ro.Closed=' + quotedstr('N')
//                                                                      + ' and ro.IsAvailableForDelivery=' + quotedstr('A')
                                                                      + ' and (not exists (select * from ReceivedOrdersToIssuedOrders Y where Y.Source_ID = ro2.ID) )'
                                                                      + ' and ro2.quantity>ro2.DeliveredQuantity'
                                                                       ,mr);
                                             end;
                                     end;

                                     if mInputDocumentClsid='CDMK5QAWZZDL342X01C0CX3FCC' then begin

                                                {if mdebug then Result_string:=Result_string+ chr(10) + chr(13) +  'SQL' + ' : ' +'Select io.id,io2.id,io2.Store_ID,IO2.StoreCard_ID,io2.X_Providerow_ID,(io2.quantity-io2.DeliveredQuantity)'     //,(io2.quantity-io2.DeliveredQuantity)
                                                                      + ' from issuedorders2 io2 left join Issuedorders IO on io.id=io2.parent_id '
                                                                      + ' where io2.X_providerow_ID=' + quotedstr(mJSONRow.S['X_Providerow_ID'])
                                                                      + ' and io2.StoreCard_ID=' + quotedstr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['StoreCard_ID'])
                                                                      + ' and io.Closed=' + quotedstr('N')
//                                                                      + ' and io.IsAvailableForDelivery=' + quotedstr('A')
                                                                       + ' and io2.quantity>io2.DeliveredQuantity';  }

                                             if (mInputDocumentClsid=mOutputDocumentClsid) or not(mImport) then begin
                                                     AContext.GetObjectSpace.SQLSelect('Select id from Issuedorders where id is null',mr);
                                             end else begin

                                                     AContext.GetObjectSpace.SQLSelect('Select io.id,io2.id,io2.Store_ID,IO2.StoreCard_ID,io2.X_Providerow_ID, io2.X_specifikace_id, io2.X_ExternalSpecification , io2.Division_ID, io2.BusOrder_ID, io2.Bustransaction_id,io2.BusProject_ID, (io2.quantity-io2.DeliveredQuantity)'     //,(io2.quantity-io2.DeliveredQuantity)
                                                                      + ' from issuedorders2 io2 left join Issuedorders IO on io.id=io2.parent_id '
                                                                      + ' where io2.X_providerow_ID=' + quotedstr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_ProvideRow_ID'])
                                                                      + ' and io2.Storecard_ID=' + quotedstr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['StoreCard_ID'])
                                                                      + ' and io.Closed=' + quotedstr('N')
//                                                                      + ' and io.IsAvailableForDelivery=' + quotedstr('A')
                                                                      + ' and io2.quantity>io2.DeliveredQuantity'

                                                                       ,mr);
                                              end;
                                     end;


                                     if ((mInputDocumentClsid<>'01CPMINJW3DL342X01C0CX3FCC') and (mInputDocumentClsid<>'CDMK5QAWZZDL342X01C0CX3FCC')) then begin
                                               if (mInputDocumentClsid=mOutputDocumentClsid) or not(mImport) then begin
                                                  AContext.GetObjectSpace.SQLSelect('Select id from StoreDocuments where id is null',mr);
                                               end else begin
                                                        if AInput.S['DocumentType']='' then
                                                              AContext.GetObjectSpace.SQLSelect('Select sd.id,sd2.id,sd2.Store_ID,sd2.StoreCard_ID,sd2.X_Providerow_ID, sd2.X_specifikace_id, sd2.X_ExternalSpecification , sd2.Division_ID, sd2.BusOrder_ID, sd2.Bustransaction_id,sd2.BusProject_ID,(sd2.quantity-sd2.DeliveredQuantity)'     //,(io2.quantity-io2.DeliveredQuantity)
                                                                      + ' from StoreDocuments2 io2 left join StoreDocuments IO on sd.id=sd.parent_id '
                                                                      + ' where sd2.X_providerow_ID=' + quotedstr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_ProvideRow_ID'])
                                                                      + ' and sd2.StoreCard_ID=' + quotedstr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['StoreCard_ID'])
                                                                      + ' and sd.Closed=' + quotedstr('N')
//                                                                      + ' and io.IsAvailableForDelivery=' + quotedstr('A')
                                                                      + ' and sd2.quantity>io2.DeliveredQuantity'
                                                                       ,mr);
                                                       if AInput.S['DocumentType']<>'' then
                                                              AContext.GetObjectSpace.SQLSelect('Select sd.id,sd2.id,sd2.Store_ID,sd2.StoreCard_ID,sd2.X_Providerow_ID,sd2.X_specifikace_id, sd2.X_ExternalSpecification , sd2.Division_ID, sd2.BusOrder_ID, sd2.Bustransaction_id,sd2.BusProject_ID,(sd2.quantity-sd2.DeliveredQuantity)'     //,(io2.quantity-io2.DeliveredQuantity)
                                                                      + ' from StoreDocuments2 io2 left join StoreDocuments IO on sd.id=sd.parent_id '
                                                                      + ' where sd2.X_providerow_ID=' + quotedstr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_ProvideRow_ID'])
                                                                      + ' and sd2.Storecard_ID=' + quotedstr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['StoreCard_ID'])
                                                                      + ' and sd.Closed=' + quotedstr('N')
                                                                      + ' and sd.DocumentType=' + quotedstr(AInput.S['DocumentType'])
//                                                                      + ' and io.IsAvailableForDelivery=' + quotedstr('A')
                                                                      + ' and sd2.quantity>io2.DeliveredQuantity'
                                                                       ,mr);
                                               end;
                                      end;

                                   //  if mdebug then Result_string:=Result_string+ chr(10) + chr(13) +  'Nalezeno' + ' : ' +inttostr(mr.count);

                                    if mr.count> 0 then begin
                                         for mri:=0 to mr.count-1 do begin
                                             mParseValue:=tstringlist.create;
                                             try
                                             mParseValue:=FNParsevalue(mr.Strings[mri],';');
                                                 if mpomocpocet>0 then begin
                                                           //if mpomocpocet>=NxIBStrToFloat(copy(mr.Strings[mri],56,10))  then begin
                                                           if false then begin // mpomocpocet>=NxIBStrToFloat(mParseValue.Strings[11])  then begin
                                                                          mUseQuantity:=0;
                                                                         // mUseQuantity:=NxIBStrToFloat(copy(mr.Strings[mri],56,10));
                                                                          mUseQuantity:=NxIBStrToFloat(mParseValue.Strings[11]);
                                                                          mImportRows.add(mParseValue.Strings[0]
                                                                                         +';' + mParseValue.Strings[1]
                                                                                         +';' + mParseValue.Strings[2]
                                                                                         +';' + mParseValue.Strings[3]
                                                                                         +';' + mParseValue.Strings[4]
                                                                                         +';' + mParseValue.Strings[5]
                                                                                         +';' + mParseValue.Strings[6]
                                                                                         +';' + mParseValue.Strings[7]
                                                                                         +';' + mParseValue.Strings[8]
                                                                                         +';' + mParseValue.Strings[9]
                                                                                         +';' + mParseValue.Strings[10]
                                                                                         +';' + NxFloatToIBStr(mUseQuantity)
                                                                                         +';' + (AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['ID'])
                                                                                         );

                                                                          mpomocpocet:=mpomocpocet-mUseQuantity;
                                                           end else begin
                                                                          mUseQuantity:=0;
                                                                          mUseQuantity:=mPomocPocet;
                                                                          mImportRows.add(mParseValue.Strings[0]
                                                                                         +';' + mParseValue.Strings[1]
                                                                                         +';' + mParseValue.Strings[2]
                                                                                         +';' + mParseValue.Strings[3]
                                                                                         +';' + mParseValue.Strings[4]
                                                                                         +';' + mParseValue.Strings[5]
                                                                                         +';' + mParseValue.Strings[6]
                                                                                         +';' + mParseValue.Strings[7]
                                                                                         +';' + mParseValue.Strings[8]
                                                                                         +';' + mParseValue.Strings[9]
                                                                                         +';' + mParseValue.Strings[10]
                                                                                         +';' + (NxFloatToIBStr(mpomocpocet))
                                                                                         +';' + (AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['ID'])
                                                                                         );
                                                                          mpomocpocet:=mpomocpocet-mpomocpocet;
                                                           end;

                                                       try
                                                       if trim(uppercase(AInput.S['ImportBatches']))='TRUE' then begin
                                                       //   if mdebug then Result_string:=Result_string+ chr(10) + chr(13) +  'Počet' + ' : ' +NxFloatToIBStr(mUseQuantity);

                                                           if AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].Length>0 then begin
                                                               for iJSONBatches := 0 to AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].Length - 1 do begin  // cyklus řádku dokladu
                                                                  mPomocSarze:=NxIBStrToFloat(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['WorkQuantity']);
                                                                   //if mdebug then Result_string:=Result_string+ chr(10) + 'Šarže.' +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['StoreBatch'] + ', Množství:' +  mJSONBatch.S['WorkQuantity'];
                                                                  mrx:=tstringlist.create;
                                                                  try
                                                                       //if mdebug then Result_string:=Result_string + chr(10) +  'Select id from StoreBatches where Name=' + quotedstr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['StoreBatch']) + ' and StoreCard_ID=' + QuotedStr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['StoreCard_ID']) + ' and hidden=' + quotedstr('N');
                                                                       AContext.GetObjectSpace.SQLSelect('Select id from StoreBatches where Name=' + quotedstr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['StoreBatch']) + ' and StoreCard_ID=' + QuotedStr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['StoreCard_ID']) + ' and hidden=' + quotedstr('N'),mrx);
                                                                       if mrx.count> 0 then begin

                                                                          if mUseQuantity>=mPomocSarze then begin
                                                                              if AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['WorkQuantity']>0 then begin
                                                                                     mImportBatches.add(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_ProvideRow_ID'] + ';' +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['StoreCard_ID']  + ';' + mrx.Strings[0] +';'+ NxRight(('0000000000' + NxFloatToIBStr(mPomocSarze)),10) +';'+  NxRight('00000000000000000000' +NxFloatToIBStr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['TotalPrice']/ AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['WorkQuantity']),10 ));
                                                                              end else begin
                                                                                     mImportBatches.add(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_ProvideRow_ID'] + ';' +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['StoreCard_ID']  + ';' + mrx.Strings[0] +';'+ NxRight(('0000000000' + NxFloatToIBStr(mPomocSarze)),10) +';'+  NxRight('00000000000000000000' +NxFloatToIBStr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['TotalPrice'] div AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['WorkQuantity']),10 ));
                                                                              end;
                                                                             //if mdebug then Result_string:=Result_string + chr(10) +  ' rows sarze' + AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_Providerow_ID'] + ';' +(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['StoreCard_ID']  + ';' + mrx.Strings[0] +';'+ NxRight(('0000000000' + NxFloatToIBStr(mPomocSarze)),10) +';'+  NxRight('0000000000' +NxFloatToIBStr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['TotalPrice'] div AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['WorkQuantity']),10 ));
                                                                          end else begin
                                                                              if AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['WorkQuantity']>0 then begin
                                                                                   mImportBatches.add(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_ProvideRow_ID'] + ';' +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['StoreCard_ID']  + ';' + mrx.Strings[0] +';'+NxRight(('0000000000' + NxFloatToIBStr(mUseQuantity)),10)+';'+  NxRight('00000000000000000000' + NxFloatToIBStr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['TotalPrice'] / AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['WorkQuantity']),10 ));
                                                                              end else begin
                                                                                   mImportBatches.add(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_ProvideRow_ID'] + ';' +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['StoreCard_ID']  + ';' + mrx.Strings[0] +';'+NxRight(('0000000000' + NxFloatToIBStr(mUseQuantity)),10)+';'+  NxRight('00000000000000000000' + NxFloatToIBStr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['TotalPrice'] div AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['WorkQuantity']),10 ));
                                                                              end;
                                                                             // if mdebug then Result_string:=Result_string + chr(10) +  ' import rows sarze' + (AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_ProvideRow_ID'] + ';' +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['StoreCard_ID']  + ';' + mrx.Strings[0] +';'+NxRight(('0000000000' + NxFloatToIBStr(mUseQuantity)),10)+';'+  NxRight('0000000000' + NxFloatToIBStr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['TotalPrice'] div AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['WorkQuantity']),10 ));
                                                                          end;


                                                                           //if mdebug then Result_string:=Result_string+ chr(10) +  'import Podklad batches ' + ' : ' +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_ProvideRow_ID'] + ';' +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['StoreCard_ID']  + ';' + mrx.Strings[0] +';'+NxFloatToIBStr(mPomocSarze) + ';'

                                                                       end else begin
                                                                          // *** založení šarže *******

                                                                          mBatch:=AContext.GetObjectSpace.CreateObject('C32QXZWCTVDL342W01C0CX3FCC');
                                                                                         try
                                                                                               mID_Sarze:='';
                                                                                               mBatch.new;
                                                                                               mBatch.Prefill;
                                                                                               mBatch.SetFieldValueAsString('StoreCard_ID',AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['StoreCard_ID']);
                                                                                               mBatch.SetFieldValueAsString('X_parent_ID',mBatch.getFieldValueAsString('StoreCard_ID.X_parent_ID'));
                                                                                               mBatch.SetFieldValueAsString('Name',AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['StoreBatch']);
                                                                                               mBatch.SetFieldValueAsDateTime('X_CreatedDate$date',Now);
                                                                                               mBatch.Save;
                                                                                               mID_Sarze:=mBatch.oid;
                                                                                         finally
                                                                                              mBatch.free;
                                                                                         end;
                                                                                 mImportBatches.add(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_ProvideRow_ID'] + ';' +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['StoreCard_ID']  + ';' + mID_Sarze +';'+NxRight(('0000000000' + NxFloatToIBStr(mUseQuantity)),10)+';'+  NxRight('00000000000000000000' + NxFloatToIBStr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['TotalPrice'] / AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['WorkQuantity']),10 ));
                                                                          //  if mdebug then Result_string:=Result_string + chr(10) + 'import Založit šarži.' +';'+mJSONBatch.S['Name'] + ', Množství:' +  AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['WorkQuantity'];
                                                                       end;

                                                                  finally
                                                                      mrx.free;
                                                                  end;
                                                               end;
                                                          end;
                                                          end ;
                                                          finally
                                                          end;
                                                  end;
                                            finally
                                                mParseValue.free;
                                            end;
                                         end;
                                         if (mpomocpocet>0)  then begin                          // není možné čerpat
                                                if mOnlyImport then begin
                                                     mNotSaveRows.add('0000000000' + ';'                  // doklad
                                                                    //+AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['id']+ ';'
                                                                    +'0000000000' + ';'
                                                                    +mStore_ID+ ';'
                                                                    +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['StoreCard_ID']+ ';'
                                                                    +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_ProvideRow_ID']+ ';'

                                                                    +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_specifikace_id']+ ';'
                                                                    +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_ExternalSpecification']+ ';'
                                                                    +''+ ';'
                                                                    +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['BusOrder_ID_Code']+ ';'
                                                                    +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Bustransaction_id_Code']+ ';'
                                                                    +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['BusProject_ID_Code']+ ';'
                                                                    +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['WorkQuantity']
                                                                    +';' + (AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['ID'])
                                                                                         );


                                                                    if AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].Length>0 then begin
                                                                                   for iJSONBatches := 0 to AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].Length - 1 do begin  // cyklus řádku dokladu
                                                                                                    mNotsaveBatches.add(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_ProvideRow_ID'] + ';' +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['StoreCard_ID'] + ';' + mrx.Strings[0] +';'+NxRight('0000000000' + AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['WorkQuantity'],10)+';'+  NxRight('00000000000000000000' + NxFloatToIBStr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['TotalPrice'] / AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['WorkQuantity']),10 ));
                                                                                   end;
                                                                    end;
                                                end else begin

                                                     mOtherRows.add('0000000000' + ';'                  // doklad
                                                        +'0000000000' + ';'
                                                        + mstore_ID + ';'
                                                        +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['StoreCard_ID']+ ';'
                                                        +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_ProvideRow_ID'] + ';'                //io2.X_ProvideRow_ID
                                                                    +''+ ';'
                                                                    +''+ ';'
                                                                    +''+ ';'
                                                                    +''+ ';'
                                                                    +''+ ';'
                                                                    +''+ ';'
                                                        +NxFloatToIBStr(mpomocpocet)
                                                        +';' + (AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['ID'])
                                                                                         );

                                                        //********

                                                           //if mdebug then Result_string:=Result_string  + chr(10) + ' other rows dohledáno provide_ID' + ('0000000000' + ';' +'0000000000' + ';' + AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Store_ID']
                                                           //+';'+AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Storecard_ID']+';'+ AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_Providerow_ID']+ ';' + NxFloatToIBStr(mpomocpocet)) ;

                                                        try
                                                        if trim(uppercase(AInput.S['ImportBatches']))='TRUE' then begin
                                                              if AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].Length>0 then begin
                                                                   for iJSONBatches := 0 to AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].Length - 1 do begin  // cyklus řádku dokladu
                                                                      mrx:=tstringlist.create;
                                                                      try
                                                                           AContext.GetObjectSpace.SQLSelect('Select id from StoreBatches where name=' + quotedstr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['StoreBatch']) + ' and Storecard_ID=' + QuotedStr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['StoreCard_ID'])+ ' and hidden=' + quotedstr('N'),mrx);
                                                                           if mrx.count> 0 then begin
                                                                                if AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['WorkQuantity']>0 then begin
                                                                                     mOtherBatches.add(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_ProvideRow_ID'] + ';' +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['StoreCard_ID'] + ';' + mrx.Strings[0] +';'+NxRight('0000000000' + AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['WorkQuantity'],10)+';'+  NxRight('00000000000000000000' + NxFloatToIBStr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['TotalPrice'] / AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['WorkQuantity']),10));
                                                                                 end else begin
                                                                                     mOtherBatches.add(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_ProvideRow_ID'] + ';' +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['StoreCard_ID'] + ';' + mrx.Strings[0] +';'+NxRight('0000000000' + AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['WorkQuantity'],10)+';'+  NxRight('00000000000000000000' + NxFloatToIBStr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['TotalPrice'] div AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['WorkQuantity']),10));
                                                                                 end;
                                                                             //   if mdebug then Result_string:=Result_string  + chr(10) + ' other rows sarze' + (AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_ProvideRow_ID'] + ';' +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['StoreCard_ID'] + ';' + mrx.Strings[0] +';'+NxRight('0000000000' + AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['WorkQuantity'],10)+';'+  NxRight('0000000000' + NxFloatToIBStr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['TotalPrice'] div AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['WorkQuantity']),10));
                                                                           end else begin
                                                                               // *** založení šarže *******
                                                                                       mBatch:=AContext.GetObjectSpace.CreateObject('C32QXZWCTVDL342W01C0CX3FCC');
                                                                                               try
                                                                                                     mID_Sarze:='';
                                                                                                     mBatch.new;
                                                                                                     mBatch.Prefill;
                                                                                                     mBatch.SetFieldValueAsString('StoreCard_ID',AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['StoreCard_ID']);
                                                                                                     mBatch.SetFieldValueAsString('X_parent_ID',mBatch.getFieldValueAsString('StoreCard_ID.X_parent_ID'));
                                                                                                     mBatch.SetFieldValueAsString('Name',AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['StoreBatch']);
                                                                                                     mBatch.SetFieldValueAsDateTime('X_CreatedDate$date',Now);
                                                                                                     mBatch.Save;
                                                                                                     mID_Sarze:=mBatch.oid;
                                                                                               finally
                                                                                                    mBatch.free;
                                                                                               end;
                                                                                       mOtherBatches.add(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_ProvideRow_ID'] + ';' +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['StoreCard_ID'] + ';' + mID_Sarze +';'+NxRight('0000000000' + AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['WorkQuantity'],10)+';'+  NxRight('00000000000000000000' + NxFloatToIBStr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['TotalPrice'] / AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['WorkQuantity']),10));
                                                                            //    if mdebug then Result_string:=Result_string + chr(10) + 'other Založit šarži.' +';'+AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['StoreBatch'] + AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['WorkQuantity'];
                                                                           end;

                                                                      finally
                                                                          mrx.free;
                                                                      end;
                                                                      AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].free;

                                                                   end;
                                                              end;
                                                          end;
                                                        finally

                                                        end;
                                              end;
                                         end;
                                    end else begin
                                      if mOnlyImport then begin
                                         mNotSaveRows.add('0000000000' + ';'                  // doklad
                                                        //+AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['id']+ ';'
                                                        +'0000000000' + ';'
                                                        +mStore_ID+ ';'
                                                        +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['StoreCard_ID']+ ';'
                                                        +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_ProvideRow_ID']+ ';'
                                                                    +''+ ';'
                                                                    +''+ ';'
                                                                    +''+ ';'
                                                                    +''+ ';'
                                                                    +''+ ';'
                                                                    +''+ ';'
                                                                    +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['WorkQuantity']
                                                                    +';' + (AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['ID'])
                                                                                         );

                                                        try

                                                        if trim(uppercase(AInput.S['ImportBatches']))='TRUE' then begin
                                                              if AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].Length>0 then begin
                                                                             for iJSONBatches := 0 to AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].Length - 1 do begin  // cyklus řádku dokladu
                                                                                              mNotsaveBatches.add(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_ProvideRow_ID'] + ';' +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['StoreCard_ID'] + ';' + mrx.Strings[0] +';'+NxRight('0000000000' + AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['WorkQuantity'],10)+';'+  NxRight('00000000000000000000' + NxFloatToIBStr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['TotalPrice'] / AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['WorkQuantity']),10 ));
                                                                             end;
                                                              end;
                                                        end;
                                                        finally

                                                        end;
                                      end else begin
                                         mOtherRows.add('0000000000' + ';'                  // doklad
                                                        //+AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['id']+ ';'
                                                        +'0000000000' + ';'
                                                        +mStore_ID+ ';'
                                                        +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['StoreCard_ID']+ ';'
                                                        +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_ProvideRow_ID']+ ';'
                                                                    +''+ ';'
                                                                    +''+ ';'
                                                                    +''+ ';'
                                                                    +''+ ';'
                                                                    +''+ ';'
                                                                    +''+ ';'
                                                                    +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['WorkQuantity']
                                                                     +';' + (AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['ID']));



                                                       // if mdebug then Result_string:=Result_string  + chr(10) + ' other rows nedohledáno provide_ID' + ('0000000000' + ';' +'0000000000' + ';' + AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['Store_ID']
                                                       //    +';'+AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['StoreCard_ID']+';'+ AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_ProvideRow_ID']+ ';' + NxFloatToIBStr(mpomocpocet)) ;

                                        try
                                        if trim(uppercase(AInput.S['ImportBatches']))='TRUE' then begin
                                              if AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].Length>0 then begin
                                                   for iJSONBatches := 0 to AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].Length - 1 do begin  // cyklus řádku dokladu
                                                      mrx:=tstringlist.create;
                                                      try
                                                           AContext.GetObjectSpace.SQLSelect('Select id from StoreBatches where name=' + quotedstr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['StoreBatch']) + ' and StoreCard_ID=' + QuotedStr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['StoreCard_ID']),mrx);
                                                           if mrx.count> 0 then begin
                                                                if AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['WorkQuantity']>0 then begin
                                                                    mOtherBatches.add(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_ProvideRow_ID'] + ';' +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['StoreCard_ID'] + ';' + mrx.Strings[0] +';'+NxRight('0000000000' + AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['WorkQuantity'],10)+';'+  NxRight('00000000000000000000' + NxFloatToIBStr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['TotalPrice'] / AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['WorkQuantity']),10 ));
                                                                end else begin
                                                                    mOtherBatches.add(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_ProvideRow_ID'] + ';' +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['StoreCard_ID'] + ';' + mrx.Strings[0] +';'+NxRight('0000000000' + AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['WorkQuantity'],10)+';'+  NxRight('00000000000000000000' + NxFloatToIBStr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['TotalPrice'] div AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['WorkQuantity']),10 ));
                                                                end;
                                                                //if mdebug then Result_string:=Result_string + chr(10) + ' bez importu rows sarze' + (AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_ProvideRow_ID'] + ';' +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['StoreCard_ID'] + ';' + mrx.Strings[0] +';'+NxRight('0000000000' + AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['WorkQuantity'],10)+';'+  NxRight('0000000000' + NxFloatToIBStr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['TotalPrice'] div AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['WorkQuantity']),10 ));
                                                           end else begin
                                                                // *** založení šarže *******
                                                                mBatch:=AContext.GetObjectSpace.CreateObject('C32QXZWCTVDL342W01C0CX3FCC');
                                                                                               try
                                                                                                     mID_Sarze:='';
                                                                                                     mBatch.new;
                                                                                                     mBatch.Prefill;
                                                                                                     mBatch.SetFieldValueAsString('StoreCard_ID',AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['StoreCard_ID']);
                                                                                                     mBatch.SetFieldValueAsString('X_parent_ID',mBatch.getFieldValueAsString('StoreCard_ID.X_parent_ID'));
                                                                                                     mBatch.SetFieldValueAsString('Name',AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['StoreBatch']);
                                                                                                     mBatch.SetFieldValueAsDateTime('X_CreatedDate$date',Now);
                                                                                                     mBatch.Save;
                                                                                                     mID_Sarze:=mBatch.oid;
                                                                                               finally
                                                                                                    mBatch.free;
                                                                                               end;

                                                                mOtherBatches.add(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['X_ProvideRow_ID'] + ';' +AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].S['StoreCard_ID'] + ';' + mID_Sarze +';'+NxRight('0000000000' + AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['WorkQuantity'],10)+';'+  NxRight('00000000000000000000' + NxFloatToIBStr(AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['TotalPrice'] / AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].D['WorkQuantity']),10));

                                                                //if mdebug then Result_string:=Result_string + chr(10) + 'bez importu Založit šarži.' +';'+AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['Name'] + AInput.A['AbraDocuments'].O[iJSONDocuments].A['Rows'].O[iJSONRows].A['DocRowBatches'].O[iJSONBatches].S['WorkQuantity'];
                                                           end;

                                                      finally
                                                          mrx.free;
                                                      end;


                                                   end;
                                              end;
                                          end;
                                        finally

                                        end;
                                      end;
                                    end;
                                finally
                                    mr.free;
                                end;





                             end;
                      end;
          end;
      end;

      //AOutput.S['SSSS']:='aaa';
     {  mImportdocuments:=TstringList.Create;
              try
                 if AInput.A['InputDocuments'].Length>0 then begin
                  for i := 0 to AInput.A['InputDocuments'].Length - 1 do begin
                         mImportdocuments.Add(AInput.A['InputDocuments'].S[i]);
                  end;
                 end;
              finally
              end;

               mSelectedHeader:=AInput.S['SelectedHeader'];
      }

              try
                  if mImportRows.count>0 then begin

                      for i:=0 to mImportRows.count-1 do begin

                          mfind:=false;   // dohledání Dokladu
                          for x:=0 to mImportdocuments.count-1 do begin
                              if  mImportdocuments.Strings[x]=copy(mImportRows.Strings[i],1,10) then mfind:=true;
                          end;
                          if not mFind then mImportdocuments.add(copy(mImportRows.Strings[i],1,10)) ;


                          mfind:=false;   // dohledání řádku
                          for x:=0 to mSelectedRows.count-1 do begin
                              if  mSelectedRows.Strings[x]=copy(mImportRows.Strings[i],12,10) then mfind:=true;
                          end;
                          if not mFind then mSelectedRows.add(copy(mImportRows.Strings[i],12,10));
                      end;
                  end;
              finally

              end;




if mImportRows.count>0 then begin

  mImportMan := NxCreateDocumentImportManager(AContext.GetObjectSpace, mInputDocumentClsid, mOutputDocumentClsid);
  mParams := TNxParameters.Create();
end;

             if mImportdocuments.count>0 then begin     // import dokladu

                                      try
                                         if mImportdocuments.count>0 then begin
                                            for i:=0 to mImportdocuments.count-1 do begin
                                                mImportMan.AddInputDocument(mImportdocuments.Strings[i]);
                                                mDocInputDocument:=mDocInputDocument + mImportMan.InputDocuments[i].DisplayName;
                                                if i<>mImportdocuments.count-1 then mDocInputDocument:=mDocInputDocument + ', ' ;
                                            end;
                                          end;

                                         if trim(mSelectedHeader)='' then begin
                                             if mInputDocuments.count>1 then mParams.GetOrCreateParam(dtString, 'SelectedHeader').AsString := mImportdocuments.Strings[0];
                                         end else begin
                                             mParams.GetOrCreateParam(dtString, 'SelectedHeader').AsString := AInput.S['SelectedHeader'];
                                         end;

                                         if mDocQueue_ID<>'' then mParams.GetOrCreateParam(dtString, 'DocQueue_ID').AsString := mDocQueue_ID;


                                         if not mAllDocument then begin
                                                if mSelectedRows.count>0 then begin
                                                    mParams.GetOrCreateParam(dtString, 'SelectedRows').AsString := mSelectedRows.Text;

                                                end;
                                               // AOutput.S['Debug_text']:=inttostr(mSelectedRows.count);
                                         end;

                                    //      mParams.GetOrCreateParam(dtBoolean, 'ImportBatches').AsBoolean := True;

                                    if mSelectedRows.count>0 then begin
                                         try
                                                     mImportMan.LoadParams(mParams);
                                                     mImportMan.Execute;
                                                     AOutput.S['Zdroj']:='Import';
                                                     mOutputDocument:=mImportMan.OutputDocument;
            //                                         mOutputDocument.SetFieldValueAsDateTime('DocDate$Date', NxIBStrToFloat(AInput.A['AbraDocuments'].O[iJSONDocuments].S['DocDate']));
                                                     if mOutputDocument.getfieldvalueasstring('X_ExternalDocument')='' then begin
                                                          mOutputDocument.setfieldvalueasstring('X_ExternalDocument',mJSONDocument.S['DocNumber']);
                                                     end;
                                                      mOutputDocument.setfieldvalueasstring('X_Identifikace',AInput.A['AbraDocuments'].O[iJSONDocuments].S['Identifikace']);
                                                      if mFirm_ID<>'' then begin
                                                           mOutputDocument.SetFieldValueAsString('Firm_ID',mFirm_ID);
                                                      end else begin
                                                           mOutputDocument.setfieldvalueasstring('Firm_ID',mImportMan.InputDocuments[0].GetFieldValueAsString('Firm_ID'));
                                                           mOutputDocument.setfieldvalueasstring('FirmOffice_ID',mImportMan.InputDocuments[0].GetFieldValueAsString('FirmOffice_ID'));
                                                      end;
                                                      if mAllDocument then begin
                                                        if  mOutputDocumentClsid='050I5SAOS3DL3ACU03KIU0CLP4' then begin         // dodací list
                                                             mOutputDocument.setfieldvalueasstring('Firm_ID',mImportMan.InputDocuments[0].GetFieldValueAsString('Firm_ID'));
                                                             mOutputDocument.setfieldvalueasstring('FirmOffice_ID',mImportMan.InputDocuments[0].GetFieldValueAsString('FirmOffice_ID'));
                                                        end;
                                                      end;
                                                      if (mOutputDocumentClsid='E03ZNUMDTCC4PDAUIEY1MBTJC0') then begin   //  *** příjemka u položky
                                                                 mOutputDocument.setfieldvalueasstring('U_EXT_cislo',NxSearchReplace(AInput.A['AbraDocuments'].O[iJSONDocuments].S['DocNumber'],'_','/',[srCase,srAll]));
                                                      end;


                                                     mOutputDocument.SetFieldValueAsString('Description',copy((mImportMan.InputDocuments[0].GetFieldValueAsString('Description') ),1,50));

                                                     if mOutputDocumentClsid='E03ZNUMDTCC4PDAUIEY1MBTJC0' then
                                                                          mOutputDocument.SetFieldValueAsString('U_popis', mImportMan.InputDocument.GetFieldValueAsString('Description'));

                                                     if (mOutputDocumentClsid='01CPMINJW3DL342X01C0CX3FCC') or (mOutputDocumentClsid='CDMK5QAWZZDL342X01C0CX3FCC') then begin
                                                          if (trim(mOutputDocument.getfieldvalueasstring('ExternalNumber'))='') and (AInput.A['AbraDocuments'].O[iJSONDocuments].S['DocNumber']<>'') then begin
                                                               mOutputDocument.setfieldvalueasstring('ExternalNumber',NxSearchReplace(AInput.A['AbraDocuments'].O[iJSONDocuments].S['DocNumber'],'_','/',[srCase,srAll]));
                                                          end;
                                                          if mOutputDocument.getfieldvalueasstring('X_ExternalDocument')='' then begin
                                                               mOutputDocument.setfieldvalueasstring('X_ExternalDocument',NxSearchReplace(AInput.A['AbraDocuments'].O[iJSONDocuments].S['DocNumber'],'_','/',[srCase,srAll]));
                                                          end;
                                                      end;

                                         except
                                              // mOutputDocument:=AContext.GetObjectSpace.CreateObject(mOutputDocumentClsid);
                                              //  mOutputDocument.new;
                                              //  mOutputDocument.prefill;
                                              //  mOutputDocument.setfieldvalueasstring('Docqueue_ID',mDocqueue_ID);
//                                                mOutputDocument.SetFieldValueAsDateTime('DocDate$Date', NxIBStrToFloat(AInput.A['AbraDocuments'].O[iJSONDocuments].S['DocDate']));
                                                AOutput.S['Zdroj']:='None_New';

                                                //mOutputDocument.setFieldValueAsInteger('Tradetype',StrToInt(AInput.A['AbraDocuments'].O[iJSONDocuments].S['TradeType']));


                                                if mFirm_ID<>'' then mOutputDocument.setfieldvalueasstring('Firm_ID',mFirm_ID);

                                                if (mOutputDocumentClsid='E03ZNUMDTCC4PDAUIEY1MBTJC0') then begin   //  *** příjemka u položky
                                                     mOutputDocument.setfieldvalueasstring('U_EXT_cislo',NxSearchReplace(AInput.A['AbraDocuments'].O[iJSONDocuments].S['DocNumber'],'_','/',[srCase,srAll]));
                                                end;


                                                if mOutputDocument.getfieldvalueasstring('X_ExternalDocument')='' then begin
                                                      mOutputDocument.setfieldvalueasstring('X_ExternalDocument',NxSearchReplace(AInput.A['AbraDocuments'].O[iJSONDocuments].S['DocNumber'],'_','/',[srCase,srAll]));

                                                end;
                                                try
                                                 //if mOutputDocument.getfieldvalueasstring('ExternalNumber')='' then begin
                                                      //mOutputDocument.setfieldvalueasstring('ExternalNumber',NxSearchReplace(AInput.A['AbraDocuments'].O[iJSONDocuments].S['DocNumber'],'_','/',[srCase,srAll]));
                                                //end;
                                                finally

                                                end;

                                                    //mOutputDocument.SetFieldValueAsString('Description',NxSearchReplace(AInput.A['AbraDocuments'].O[iJSONDocuments].S['Description'],'_','/',[srCase,srAll]));
                                                    //mOutputDocument.SetFieldValueAsString('X_Identifikace',NxSearchReplace(AInput.A['AbraDocuments'].O[iJSONDocuments].S['X_Identifikace'],'_','/',[srCase,srAll]));

                                                    //if mOutputDocumentClsid='E03ZNUMDTCC4PDAUIEY1MBTJC0' then
                                                    //          mOutputDocument.SetFieldValueAsString('U_popis',NxSearchReplace(AInput.A['AbraDocuments'].O[iJSONDocuments].S['Description'],'_','/',[srCase,srAll]));


                                         end;
                                         mRowsOutput := mOutputDocument.GetLoadedCollectionMonikerForFieldCode(mOutputDocument.GetFieldCode('Rows'));
                                         for mIRows:=0 to mRowsOutput.Count-1 do begin
                                              AOutput.S['yyyy']:=inttostr(mSelectedRows.count) + '+++++++++++++++++++++++++++++';
                                              if mStore_ID='' then mStore_ID:=mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('Store_ID');
                                              if mDivision_ID='' then mDivision_ID:=mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('Division_ID');
                                              if ((mOutputDocumentClsid='01CPMINJW3DL342X01C0CX3FCC' ))  then begin // op
                                                  // smazat původní pohyby šarží
                                                  mi:=AContext.GetObjectSpace.SQLExecute('delete FROM DefRollData where CLSID=' + quotedstr('SLARSB0H4CK4T32XPZTP33J3XS') + ' and code='+quotedstr(mOutputDocument.oid));
                                              end;

                                              if ((mOutputDocumentClsid='CDMK5QAWZZDL342X01C0CX3FCC' ))  then begin  // ov
                                                  // smazat původní pohyby šarží
                                                   mi:=AContext.GetObjectSpace.SQLExecute('delete FROM DefRollData where CLSID=' + quotedstr('EC2R2HSFK5UOZ5MYVJWJOHUC4S') + ' and code='+quotedstr(mOutputDocument.oid));
                                              end;

                                              if ((mOutputDocumentClsid<>'01CPMINJW3DL342X01C0CX3FCC' ) and  (mOutputDocumentClsid<>'CDMK5QAWZZDL342X01C0CX3FCC' )) then begin  // sd
                                                    // smazat původní pohyby šarží
                                                    mMonBatches :=  mRowsOutput.BusinessObject[mIRows].GetLoadedCollectionMonikerForFieldCode( mRowsOutput.BusinessObject[mIRows].GetFieldCode('DocRowBatches'));
                                                    if mMonBatches.count>0 then begin
                                                          for mIBatchs := 0 to mMonBatches.Count - 1 do begin
                                                              mMonBatches.BusinessObject[mIBatchs].MarkForDelete;
                                                          end;
                                                    end;
                                              end;
                                                  // odmazání neimportovaných řádků . xxxxxxx
                                              if not mAllDocument then begin
                                                      mfind:=false;   // dohledání řádku
                                                  for i:=0 to mImportRows.count-1 do begin
                                                             if (mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('X_ProvideRow_ID')=copy(mImportRows.strings[i],45,10))  and (not NxIsEmptyOID(mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('X_ProvideRow_ID'))) then begin
                                                                  mfind:=true;
                                                             end;
                                                  end;
                                                 // if not mFind then mRowsOutput.BusinessObject[mIRows].MarkForDelete;
                                              End;
                                         end;



                                         mRowsOutput := mOutputDocument.GetLoadedCollectionMonikerForFieldCode(mOutputDocument.GetFieldCode('Rows'));
                                         for mIRows:=0 to mRowsOutput.Count-1 do begin
                                                for i:=0 to mImportRows.count-1 do begin
                                                       AOutput.S['Helptmp03']:=mImportRows.strings[i];
                                                      mParseValue:=tstringlist.create;
                                                      try
                                                      mParseValue:=FNParsevalue(mImportRows.strings[i],';');
                                                            AOutput.S['Helptmp01']:='01';
                                                            if (mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('X_ProvideRow_ID')=mParseValue.strings[4]) and (not NxIsEmptyOID(mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('X_ProvideRow_ID'))) then begin
                                                                   AOutput.S['Helptmp02']:='02';
                                                                   if mdebug then Result_string:=Result_string+ chr(10) + chr(13) +  'Počet' + ' : ' + (copy(mImportRows.strings[i],56,10));
                                                                   //mRowsOutput.BusinessObject[mIRows].setFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(mImportRows.strings[i],56,10)));
                                                                   mRowsOutput.BusinessObject[mIRows].setFieldValueAsFloat('Quantity',NxIBStrToFloat(mParseValue.strings[11]));
                                                                   //if ((mOutputDocumentClsid<>'CDMK5QAWZZDL342X01C0CX3FCC') and (mOutputDocumentClsid<>'01CPMINJW3DL342X01C0CX3FCC')) then begin   // stredocuments
                                                                   //     mRowsOutput.BusinessObject[mIRows].setFieldValueAsstring('X_StoreDocuments2_ID',mParseValue.strings[12]);
                                                                   //end;

                                                                  // if mdebug then Result_string:=Result_string + chr(10) +'  Množství zadávané  na řádku importem  :' + IntToStr(mRowsOutput.BusinessObject[mIRows].getFieldValueAsinteger('Posindex')) + ' / ' + NxFloatToIBStr(mRowsOutput.BusinessObject[mIRows].getFieldValueAsfloat('Quantity'));
                                                                     // if mDebug then  Result_string:=  Result_string + copy(mImportBatches.Strings[mIBatchs],1,10) + '   '+ copy(mImportBatches.Strings[mIBatchs],12,10) + '    '+copy(mImportBatches.Strings[mIBatchs],23,10);

                                                                          if (UpperCase(AInput.S['ImportBatches'])='TRUE') and (mImportBatches.count>0) then begin
                                                                          if mRowsOutput.BusinessObject[mIRows].GetFieldValueAsinteger('StoreCard_ID.category')=2 then begin
                                                                                 AOutput.S['Helptmp03']:='03';
                                                                                 if mOutputDocumentClsid='01CPMINJW3DL342X01C0CX3FCC' then begin   // op
                                                                                 // op
                                                                                      mPomocMnozstvi:=0;
                                                                                      for mIBatchs := 0 to mImportBatches.Count - 1 do begin
                                                                                            if copy(mImportBatches.Strings[mIBatchs],1,10)=mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('X_ProvideRow_ID') then begin
                                                                                                  mBO_PohybSarze:=AContext.GetObjectSpace.CreateObject('SLARSB0H4CK4T32XPZTP33J3XS');
                                                                                                     try
                                                                                                            mBO_PohybSarze.new;
                                                                                                            mBO_PohybSarze.Prefill;
                                                                                                            if mWithPrices then mRowsOutput.BusinessObject[mIRows].setFieldValueAsFloat('Unitprice',NxIBStrToFloat(copy(mImportBatches.Strings[mIBatchs],46,10)));
                                                                                                            mBO_PohybSarze.SetFieldValueAsFloat('X_quantity',NxIBStrToFloat(copy(mImportBatches.Strings[mIBatchs],34,10)));
                                                                                                            mPomocMnozstvi:=mPomocMnozstvi + NxIBStrToFloat(copy(mImportBatches.Strings[mIBatchs],34,10));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('Code',mOutputDocument.OID);
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Parent_ID',mRowsOutput.BusinessObject[mIRows].OID);
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Firm_ID',mOutputDocument.GetFieldValueAsString('Firm_ID'));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Parent2_ID',mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('Storecard_ID'));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Batches',copy(mImportBatches.Strings[mIBatchs],24,10));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('Name', copy(mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('Storecard_ID.name'),1,40));
                                                                                                            //mBO_PohybSarze.SetFieldValueAsstring('Code',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.Code'));
                                                                                                            mBO_PohybSarze.save;
                                                                                                     finally
                                                                                                         mBO_PohybSarze.free;
                                                                                                     end;
                                                                                            end;
                                                                                      end;
                                                                                      if mPomocMnozstvi<>0 then mRowsOutput.BusinessObject[mIRows].setFieldValueAsFloat('Quantity',mPomocMnozstvi );
                                                                                      if mdebug then Result_string:=Result_string + chr(10) + '  Pomoc množství  :' +NxFloatToIBStr(mPomocMnozstvi);
                                                                                 end;
                                                                                 if mOutputDocumentClsid='CDMK5QAWZZDL342X01C0CX3FCC' then begin   // ov
                                                                                 //      ov
                                                                                   mPomocMnozstvi:=0;
                                                                                   for mIBatchs := 0 to mImportBatches.Count - 1 do begin
                                                                                        AOutput.S['Helptmpbatch']:='batch';
                                                                                        if copy(mImportBatches.Strings[mIBatchs],1,10)=mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('X_ProvideRow_ID') then begin
                                                                                              mBO_PohybSarze:=AContext.GetObjectSpace.CreateObject('EC2R2HSFK5UOZ5MYVJWJOHUC4S');
                                                                                                     try
                                                                                                            mBO_PohybSarze.new;
                                                                                                            mBO_PohybSarze.Prefill;
                                                                                                            if mWithPrices then mRowsOutput.BusinessObject[mIRows].setFieldValueAsFloat('Unitprice',NxIBStrToFloat(copy(mImportBatches.Strings[mIBatchs],46,10)));
                                                                                                            mBO_PohybSarze.SetFieldValueAsFloat('X_quantity',NxIBStrToFloat(copy(mImportBatches.Strings[mIBatchs],34,10)));
                                                                                                            mPomocMnozstvi:= mPomocMnozstvi + NxIBStrToFloat(copy(mImportBatches.Strings[mIBatchs],34,10));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('Code',mOutputDocument.OID);
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Parent_ID',mRowsOutput.BusinessObject[mIRows].OID);
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Firm_ID',mOutputDocument.GetFieldValueAsString('Firm_ID'));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Parent2_ID',mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('Storecard_ID'));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Batches',copy(mImportBatches.Strings[mIBatchs],23,10));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('Name', copy(mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('Storecard_ID.name'),1,40));
                                                                                                            //mBO_PohybSarze.SetFieldValueAsstring('Code',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.Code'));
                                                                                                            mBO_PohybSarze.save
                                                                                                     finally
                                                                                                         mBO_PohybSarze.free;
                                                                                                     end;
                                                                                        end;
                                                                                  end;
                                                                                   if mPomocMnozstvi<>0 then mRowsOutput.BusinessObject[mIRows].setFieldValueAsFloat('Quantity',mPomocMnozstvi);
                                                                                 //  if mdebug then Result_string:=Result_string + chr(10) + '  Pomoc množství  :' +NxFloatToIBStr(mPomocMnozstvi);
                                                                                 end;

                                                                                 if ((mOutputDocumentClsid<>'CDMK5QAWZZDL342X01C0CX3FCC') and (mOutputDocumentClsid<>'01CPMINJW3DL342X01C0CX3FCC')) then begin   // stredocuments

                                                                                      mMonBatches :=  mRowsOutput.BusinessObject[mIRows].GetLoadedCollectionMonikerForFieldCode( mRowsOutput.BusinessObject[mIRows].GetFieldCode('DocRowBatches'));

                                                                                          mPomocMnozstvi:=0;
                                                                                          for mIBatchs := 0 to mImportBatches.Count - 1 do begin

                                                                                               if copy(mImportBatches.Strings[mIBatchs],1,10)=mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('X_ProvideRow_ID') then begin
                                                                                                   //Result_string:= Result_string +  copy(mImportBatches.Strings[mIBatchs],1,10) + '   '+ copy(mImportBatches.Strings[mIBatchs],12,10) + '    '+copy(mImportBatches.Strings[mIBatchs],23,10);
                                                                                                   mBatch:=mMonBatches.AddNewObject;
                                                                                                   mBatch.Prefill;
                                                                                                   if mWithPrices then mRowsOutput.BusinessObject[mIRows].setFieldValueAsFloat('Unitprice',NxIBStrToFloat(copy(mImportBatches.Strings[mIBatchs],46,10)));
                                                                                                   mBatch.SetFieldValueAsString('StoreBatch_ID',copy(mImportBatches.Strings[mIBatchs],23,10));
                                                                                                   mBatch.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(mImportBatches.Strings[mIBatchs],34,10)));

                                                                                                   mPomocMnozstvi:=mPomocMnozstvi +NxIBStrToFloat(copy(mImportBatches.Strings[mIBatchs],34,10));
                                                                                                   mBatch.SetFieldValueAsString('Qunit',mRowsOutput.BusinessObject[mIRows].GetFieldValueAsstring('Qunit'));

                                                                                                  if mWithPrices then begin
                                                                                                     if mdebug then Result_string:=Result_string + '  Unitprice :' + (copy(mImportBatches.Strings[mIBatchs],46,10));
                                                                                                     if mdebug then Result_string:=Result_string + '  X_quantity' + (copy(mImportBatches.Strings[mIBatchs],34,10)) + chr(10);
                                                                                                  end;

                                                                                               end;

                                                                                          end;
                                                                                          if mPomocMnozstvi<>0 then mRowsOutput.BusinessObject[mIRows].setFieldValueAsFloat('Quantity',mPomocMnozstvi);
                                                                                          if mdebug then AOutput.S['Pomoc množství']:= NxFloatToIBStr(mPomocMnozstvi);
                                                                                 end;
                                                                           end;
                                                                          end;
                                                            end;
                                                      finally
                                                           mParseValue.free;
                                                      end;

                                                end;
                                         end;
                                     end;
                                   finally
                                       //mParams.free;
                                      // mImportMan.free;
                                   end;



             end else begin
                                mOutputDocument:=AContext.GetObjectSpace.CreateObject(mOutputDocumentClsid);
                                mOutputDocument.new;
                                mOutputDocument.prefill;
                                mOutputDocument.setfieldvalueasstring('Docqueue_ID',mDocqueue_ID);
                                //mOutputDocument.setFieldValueAsInteger('Tradetype',StrToInt(AInput.A['AbraDocuments'].O[iJSONDocuments].S['TradeType']));
                                if mFirm_ID<>'' then  mOutputDocument.setfieldvalueasstring('Firm_ID',mFirm_ID);
                                 try
                                      mOutputDocument.setfieldvalueasstring('X_Identifikace',AInput.A['AbraDocuments'].O[iJSONDocuments].S['Identifikace']);
                                 finally
                                 end;

//                                 mOutputDocument.SetFieldValueAsDateTime('DocDate$Date', NxIBStrToFloat(AInput.A['AbraDocuments'].O[iJSONDocuments].S['DocDate']));
                                                if mFirm_ID<>'' then mOutputDocument.setfieldvalueasstring('Firm_ID',mFirm_ID);

                                                if (mOutputDocumentClsid='E03ZNUMDTCC4PDAUIEY1MBTJC0') then begin   //  *** příjemka u položky
                                                     mOutputDocument.setfieldvalueasstring('U_EXT_cislo',NxSearchReplace(AInput.A['AbraDocuments'].O[iJSONDocuments].S['DocNumber'],'_','/',[srCase,srAll]));
                                                end;


                                                //if mOutputDocument.getfieldvalueasstring('X_ExternalDocument')='' then begin
                                                //      mOutputDocument.setfieldvalueasstring('X_ExternalDocument',NxSearchReplace(AInput.A['AbraDocuments'].O[iJSONDocuments].S['DocNumber'],'_','/',[srCase,srAll]));

                                                //end;
                                                try
                                                 if ((mOutputDocumentClsid='CDMK5QAWZZDL342X01C0CX3FCC') or (mOutputDocumentClsid='01CPMINJW3DL342X01C0CX3FCC')) then begin   // stredocuments
                                                     if mOutputDocument.getfieldvalueasstring('ExternalNumber')='' then begin
                                                          mOutputDocument.setfieldvalueasstring('ExternalNumber',NxSearchReplace(AInput.A['AbraDocuments'].O[iJSONDocuments].S['DocNumber'],'_','/',[srCase,srAll]));
                                                     end;
                                                end;
                                                finally

                                                end;

                                                    mOutputDocument.SetFieldValueAsString('Description',NxSearchReplace(AInput.A['AbraDocuments'].O[iJSONDocuments].S['Description'],'_','/',[srCase,srAll]));

                                               mOutputDocument.SetFieldValueAsString('X_ExternalDocument', NxSearchReplace(AInput.A['AbraDocuments'].O[iJSONDocuments].S['DocNumber'],'_','/',[srCase,srAll]));


                                                    if mOutputDocumentClsid='E03ZNUMDTCC4PDAUIEY1MBTJC0' then
                                                              mOutputDocument.SetFieldValueAsString('U_popis',NxSearchReplace(AInput.A['AbraDocuments'].O[iJSONDocuments].S['Description'],'_','/',[srCase,srAll]));





                                mRowsOutput := mOutputDocument.GetLoadedCollectionMonikerForFieldCode(mOutputDocument.GetFieldCode('Rows'));
           end;


           if mdebug then begin
               Result_string:=Result_string +  'Externí číslo: ' + AInput.A['AbraDocuments'].O[iJSONDocuments].S['DocNumber'] + chr(10);
               Result_string:=Result_string +  'Řada dokladu: ' + mOutputDocument.GetFieldValueAsString('Docqueue_ID.CODE') + chr(10);
               Result_string:=Result_string +  'Firma: ' + mOutputDocument.GetFieldValueAsString('Firm_ID.Name') + chr(10);


           end;


           if mOtherRows.count>0 then begin
                for i:=0 to mOtherRows.count-1 do begin
                     mParseValue:=tstringlist.create;
                     try
                     mParseValue:=FNParsevalue(mOtherRows.strings[i],';');
                            mRow := mRowsOutput.AddNewObject;
                            mrow.Prefill;
                            if mOutputDocumentClsid<>'E03ZNUMDTCC4PDAUIEY1MBTJC0' then mrow.SetFieldValueAsInteger('Rowtype',3);
                            mrow.SetFieldValueAsString('Store_ID',mstore_ID);
                            mrow.SetFieldValueAsString('StoreCard_ID',mParseValue.strings[3]);
                            mrow.SetFieldValueAsString('X_Providerow_ID',mParseValue.strings[4]);
                            mrow.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mParseValue.strings[11]));

                            mrow.SetFieldValueAsString('X_specifikace_id',mParseValue.strings[5]);
                            mrow.SetFieldValueAsString('X_ExternalSpecification',mParseValue.strings[6]);

                            //if mdebug then Result_string:=Result_string + chr(10) +'  Množství zadávané  na řádku  :' + IntToStr(mrow.getFieldValueAsinteger('Posindex')) + ' / ' + NxFloatToIBStr(mrow.getFieldValueAsfloat('Quantity'));
                            //mrow.SetFieldValueAsString('Qunit',mrow.GetFieldValueAsString('Storecard_ID.MainUnitCode'));
                            mrow.SetFieldValueAsString('Qunit','ks');
                            mrow.SetFieldValueAsString('Division_ID',mDivision_ID);
                            if ((mOutputDocumentClsid<>'01CPMINJW3DL342X01C0CX3FCC') AND (mOutputDocumentClsid<>'CDMK5QAWZZDL342X01C0CX3FCC')) then begin   // stredocuments
                                                                                      mrow.setFieldValueAsstring('X_StoreDocuments2_ID',mParseValue.strings[12]);
                            end;
                           // if mdebug then  Result_string:=Result_string + chr(10) + chr(13) + ' Otherrows vkládání do dokladu podklad  ' +(mOtherRows.strings[i]);


                          //if mdebug then  Result_string:=Result_string + '"other rows vkládání do dokladu parseRows " +"'             + mstore_ID + ', ' + copy(mOtherRows.strings[i],34,10) + ', ' + (copy(mOtherRows.strings[i],56,10))  +'"' + chr(10);







                            try           // šarže
                            if (UpperCase(AInput.S['ImportBatches'])='TRUE') and (mOtherBatches.count>0) then begin

                            if mrow.GetFieldValueAsinteger('StoreCard_ID.category')=2 then begin
                                                                                 if mOutputDocumentClsid='01CPMINJW3DL342X01C0CX3FCC' then begin   // op
                                                                                      mPomocMnozstvi:=0;
                                                                                      for mIBatchs := 0 to mOtherBatches.Count - 1 do begin

                                                                                                 if (copy(mOtherBatches.Strings[mIBatchs],1,10)=mrow.GetFieldValueAsString('X_Providerow_ID')) then begin
                                                                                                              //
                                                                                                  mBO_PohybSarze:=AContext.GetObjectSpace.CreateObject('SLARSB0H4CK4T32XPZTP33J3XS');
                                                                                                     try
                                                                                                            mBO_PohybSarze.new;
                                                                                                            mBO_PohybSarze.Prefill;
                                                                                                            if mWithPrices then mrow.setFieldValueAsFloat('Unitprice',NxIBStrToFloat(copy(mOtherBatches.Strings[mIBatchs],46,10)));
                                                                                                            mBO_PohybSarze.SetFieldValueAsFloat('X_quantity',NxIBStrToFloat(copy(mOtherBatches.Strings[mIBatchs],34,10)));
                                                                                                            mPomocMnozstvi:=mPomocMnozstvi + NxIBStrToFloat(copy(mOtherBatches.Strings[mIBatchs],34,10));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('Code',mOutputDocument.OID);
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Parent_ID',mrow.OID);
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Firm_ID',mOutputDocument.GetFieldValueAsString('Firm_ID'));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Parent2_ID',mrow.GetFieldValueAsString('Storecard_ID'));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Batches',copy(mOtherBatches.Strings[mIBatchs],23,10));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('Name', copy(mrow.GetFieldValueAsString('Storecard_ID.name'),1,40));
                                                                                                            //mBO_PohybSarze.SetFieldValueAsstring('Code',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.Code'));
                                                                                                            if mdebug then Result_string:=Result_string + ' Šarže' + copy(mOtherBatches.Strings[mIBatchs],23,10)+ chr(10) + 'unitprice :  ' +  (copy(mOtherBatches.Strings[mIBatchs],46,10)) + ' quantity: ' + copy(mOtherBatches.Strings[mIBatchs],46,10);

                                                                                                            if not mdebug then mBO_PohybSarze.save;


                                                                                                     finally
                                                                                                         mBO_PohybSarze.free;
                                                                                                     end;
                                                                                                end;
                                                                                      end;
                                                                                      if mPomocMnozstvi<>0 then mrow.SetFieldValueAsFloat('Quantity',mPomocMnozstvi );
                                                                                 end;
                                                                                 if mOutputDocumentClsid='CDMK5QAWZZDL342X01C0CX3FCC' then begin   // ov
                                                                                        mPomocMnozstvi:=0;

                                                                                        for mIBatchs := 0 to mOtherBatches.Count - 1 do begin
                                                                                                // if mdebug then Result_string:=Result_string + ' Šarže' + mOtherBatches.Strings[mIBatchs] + chr(10);
                                                                                                 if (copy(mOtherBatches.Strings[mIBatchs],1,10)=mrow.GetFieldValueAsString('X_Providerow_ID')) then begin

                                                                                                      mBO_PohybSarze:=AContext.GetObjectSpace.CreateObject('EC2R2HSFK5UOZ5MYVJWJOHUC4S');
                                                                                                     try

                                                                                                            mBO_PohybSarze.new;
                                                                                                            mBO_PohybSarze.Prefill;
                                                                                                            if mWithPrices then mrow.setFieldValueAsFloat('Unitprice',NxIBStrToFloat(copy(mOtherBatches.Strings[mIBatchs],46,10)));
                                                                                                            mBO_PohybSarze.SetFieldValueAsFloat('X_quantity',NxIBStrToFloat(copy(mOtherBatches.Strings[mIBatchs],34,10)));
                                                                                                            mPomocMnozstvi:=mPomocMnozstvi + NxIBStrToFloat(copy(mOtherBatches.Strings[mIBatchs],34,10));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('Code',mOutputDocument.OID);
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Parent_ID',mrow.OID);
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Firm_ID',mOutputDocument.GetFieldValueAsString('Firm_ID'));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Parent2_ID',mrow.GetFieldValueAsString('Storecard_ID'));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Batches',copy(mOtherBatches.Strings[mIBatchs],23,10));
                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('Name', copy(mrow.GetFieldValueAsString('Storecard_ID.name'),1,40));
                                                                                                            //mBO_PohybSarze.SetFieldValueAsstring('Code',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.Code'));
                                                                                                            if not mdebug then mBO_PohybSarze.save;

                                                                                                     finally
                                                                                                         mBO_PohybSarze.free;
                                                                                                     end;
                                                                                                end;
                                                                                        end;
                                                                                        if mPomocMnozstvi<>0 then mrow.SetFieldValueAsFloat('Quantity',mPomocMnozstvi );
                                                                                 end;



                                                                                 if ((mOutputDocumentClsid<>'01CPMINJW3DL342X01C0CX3FCC') AND (mOutputDocumentClsid<>'CDMK5QAWZZDL342X01C0CX3FCC')) then begin   // stredocuments
                                                                                      //AOutput.S['_aaa01']:='*************************';
                                                                                      mrow.setFieldValueAsstring('X_StoreDocuments2_ID',mParseValue.strings[12]);
                                                                                      mMonBatches :=  mrow.GetLoadedCollectionMonikerForFieldCode(mrow.GetFieldCode('DocRowBatches'));
                                                                                         mPomocMnozstvi:=0;
                                                                                          for mIBatchs := 0 to mOtherBatches.Count - 1 do begin
                                                                                          //AOutput.S['_bb']:=(copy(mOtherBatches.Strings[mIBatchs],1,10)+' - ' + mrow.GetFieldValueAsString('X_ProvideRow_ID'));

                                                                                             if  not nxisblank(mrow.GetFieldValueAsString('X_ProvideRow_ID')) then begin
                                                                                               if (copy(mOtherBatches.Strings[mIBatchs],1,10)=mrow.GetFieldValueAsString('X_ProvideRow_ID')) then begin
                                                                                                   //AOutput.S['_cc']:='*************************';
                                                                                                   mBatch:=mMonBatches.AddNewObject;
                                                                                                   mBatch.Prefill;
                                                                                                   //AOutput.S['batch']:=mOtherBatches.Strings[mIBatchs];
                                                                                                   mBatch.SetFieldValueAsString('StoreBatch_ID',copy(mOtherBatches.Strings[mIBatchs],23,10));
                                                                                                   mBatch.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(mOtherBatches.Strings[mIBatchs],34,10)));
                                                                                                   mPomocMnozstvi:=mPomocMnozstvi + NxIBStrToFloat(copy(mOtherBatches.Strings[mIBatchs],34,10));
//                                                                                                          mBatch.SetFieldValueAsString('Qunit',mRow.GetFieldValueAsString('Storecard_ID.MainUnitCode'));
                                                                                                          mBatch.SetFieldValueAsString('Qunit','ks');
                                                                                                   if mWithPrices then mrow.setFieldValueAsFloat('Unitprice',NxIBStrToFloat(copy(mOtherBatches.Strings[mIBatchs],46,10)));

                                                                                               end;
                                                                                             end;
                                                                                          end;
                                                                                          if mPomocMnozstvi<>0 then begin
                                                                                               mrow.SetFieldValueAsFloat('Quantity',mPomocMnozstvi );

                                                                                         end;
                                                                                 end;
                                                                           end;
                                                                           end;
                              finally

                            end;  // šarže
                     finally
                           mParseValue.free;
                     end;
                end;        // endfor
           end;   //endif

                mOutputDocument.SetFieldValueAsString('DocQueue_ID',mDocQueue_ID);
                if mFirm_ID<>'' then begin
                     mOutputDocument.SetFieldValueAsString('Firm_ID',mFirm_ID);
                end else begin
                  if mImportRows.count>0 then begin
                     mOutputDocument.setfieldvalueasstring('Firm_ID',mImportMan.InputDocuments[0].GetFieldValueAsString('Firm_ID'));
                     mOutputDocument.setfieldvalueasstring('FirmOffice_ID',mImportMan.InputDocuments[0].GetFieldValueAsString('FirmOffice_ID'));
                  end;

                end;
                if mAllDocument then begin

                                            if  mOutputDocumentClsid='050I5SAOS3DL3ACU03KIU0CLP4' then begin
                                                 if mOtherRows.count=0 then begin
                                                      mOutputDocument.setfieldvalueasstring('Firm_ID',mImportMan.InputDocuments[0].GetFieldValueAsString('Firm_ID'));
                                                      mOutputDocument.setfieldvalueasstring('FirmOffice_ID',mImportMan.InputDocuments[0].GetFieldValueAsString('FirmOffice_ID'));
                                                      if not nxisemptyoid(mImportMan.InputDocuments[0].GetFieldValueAsString('X_Delivery_adress_id')) then
                                                           mOutputDocument.setfieldvalueasstring('X_Delivery_adress_id',mImportMan.InputDocuments[0].GetFieldValueAsString('X_Delivery_adress_id'));
                                                      mOutputDocument.setfieldvalueasstring('TransportationType_ID',mImportMan.InputDocuments[0].GetFieldValueAsString('TransportationType_ID'));


                                                 end;
                                            end;
                end;


               // mRowsOutput := mOutputDocument.GetLoadedCollectionMonikerForFieldCode(mOutputDocument.GetFieldCode('Rows'));
                if mUser_ID<>'' then mOutputDocument.SetFieldValueAsString('CreatedBy_ID',mUser_ID);


                mOutputDocument.SetFieldValueAsString('X_ExternalDocument', NxSearchReplace(AInput.A['AbraDocuments'].O[iJSONDocuments].S['DocNumber'],'_','/',[srCase,srAll]));
                if (false) and ( mOutputDocument.GetFieldValueAsString('Firm_ID.Name')='LIPOELASTIC a.s.') then begin
                        mOutputDocument.setFieldValueAsInteger('Tradetype',2) ;
                        mOutputDocument.setFieldValueAsString('Country_ID','00000CZ000');
                end;








      if not mdebug then begin
            if true then begin
            //if mRowsOutput.Count>0 then begin
                 if mWithPrices then begin
                 //****kontrola cen
                     mxTarget:='';
                     if NxIsEmptyOID(mOutputDocument.GetFieldValueAsString('Firm_ID.X_API_Conect_ID')) then begin
                              NxShowSimpleMessage(' Firma ' + mOutputDocument.GetFieldValueAsString('Firm_ID.Name') + ' nemá uvedenou API adresu , není možné pokračovat', nil);
                     end else begin
                              mxTarget:=mOutputDocument.GetFieldValueAsString('Firm_ID.X_API_Conect_ID.X_CLSID');
                     end;
                                 for mIRows := 0 to mRowsOutput.Count - 1 do begin
                                     if not NxIsEmptyOID(mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('X_Providerow_ID')) then begin
                                                  mQuery:='{' + chr(10);
                                                        mQuery:=mQuery + '"X_ProvideRow_ID":"' + mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('X_Providerow_ID') + '",' +chr(10);
                                                        mQuery:=mQuery + '"Storecard_ID":"' + mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('StoreCard_ID') + '",' +chr(10);
                                                        mQuery:=mQuery + '"Firm_Name":"' + mRowsOutput.BusinessObject[mIRows].GetFieldValueAsString('Parent_id.Firm_id.Name') + '",' +chr(10);
                                                        //mQuery:=mQuery + '"X_Storedocument_ID":"' + '' + '",' +chr(10);

                                                  mQuery:=mQuery + '}' + chr(10);
                                                  mString:=APICallString(AContext.GetObjectSpace,'POST',mxtarget+'/script/NxApiLib/lib/APINxStorePrice',mQuery, true);
                                                  if NxIBStrToFloat(mstring)<>0 then begin
                                                     if NxIBStrToFloat(mstring)<>mRowsOutput.BusinessObject[mIRows].GetFieldValueAsFloat('Unitprice') then begin
                                                           // mXresult:=mXresult +  mCustomBusinessObject.displayname + ' - ' + mRowsOutput.BusinessObject[i].GetFieldValueAsString('Storecard_id.Displayname') + ' z ' + NxFloatToIBStr(mRowsOutput.BusinessObject[i].GetFieldValueAsFloat('Unitprice')) + ' na ' + mString +chr(10) +chr(13);
                                                            mRowsOutput.BusinessObject[mIRows].SetFieldValueAsFloat('Unitprice',NxIBStrToFloat(mstring));
                                                            //NxShowSimpleMessage('Změna ceny pro ' + mMon.BusinessObject[i].GetFieldValueAsString('StoreCard_ID.DisplayName') + ' z ' + NxFloatToIBStr(mMon.BusinessObject[i].GetFieldValueAsFloat('Unitprice')) +' na ' + NxFloatToIBStr(NxIBStrToFloat(mstring)) ,nil);
                                                     end;
                                                  end;
                                      end;
                                  end;
                 end;

                 mOutputDocument.ClearValidateErrors;
                  if Not mOutputDocument.Validate() then begin
                     mList := TStringList.Create;
                      try
                        mOutputDocument.GetValidateErrors(mList);
                        mText := mList.Text;
                        NxToken(mText, '=');
                                   AOutput.S['State']:='400';
                                   AOutput.S['SendDocument']:=NxSearchReplace(AInput.A['AbraDocuments'].O[iJSONDocuments].S['DocNumber'],'_','/',[srCase,srAll]);
                                   AOutput.S['Created_by']:=mUser_ID;
                                   AOutput.S['ID']:='';
                                   AOutput.S['New']:='';
                                   AOutput.S['Error']:= mText ;
                                   AOutput.S['Source']:=mDocInputDocument;
                                   AOutput.S['Import']:=inttostr(mImportRows.count) ;
                                   AOutput.S['Other']:=inttostr(mOtherRows.count);
                                   AOutput.S['Imp_batch']:=inttostr(mImportBatches.count);
                                   AOutput.S['Oth_batch']:=inttostr(mOtherBatches.count);
                                   AOutput.S['NotSave']:=inttostr(mNotSaveRows.count) ;
                                   AOutput.S['NotSave_batch']:=inttostr(mNotsaveBatches.count);
                                   AOutput.S['xxx']:= NxFloatToIBStr(mRowsOutput.BusinessObject[0].GetFieldValueAsFloat('Quantity'));


                      finally
                        mList.Free;
                      end;


                  end else begin
                      mOutputDocument.Save ;

            //     Result_string:=mOutputDocument.oid  +';'+ mOutputDocument.DisplayName   ;


                           if not NxIsBlank(AInput.S['Msg']) then begin
                                      iSendmsg(AContext.GetObjectSpace, mOutputDocument , mOutputDocumentClsid,
                                                                      mOutputDocument.DisplayName  + '-  byl vytvořen novy doklad ',     // popis
                                                                      ' Byl vytvořen novy doklad s číslem: ' + mOutputDocument.DisplayName ,                          // tělo
                                                                      mMsgUser_ID ,                      // komu
                                                                      mOutputDocument.getFieldValueAsString('CreatedBy_ID')); // kdo
                           end;


                           if not NxIsBlank(AInput.S['Email']) then begin
                                if not NxIsBlank(AInput.S['Report_ID']) then begin






                                mPrintList := TStringList.Create;
                                      try
                                         mPrintList.Add(mOutputDocument.OID);
                                         AName := mOutputDocument.GetFieldValueAsString('Docqueue_ID.CODE') +'-' + inttostr(mOutputDocument.GetFieldValueAsInteger('Ordnumber'))  +'-' + mOutputDocument.GetFieldValueAsString('Period_id.CODE')+'.pdf' ;

                                             mr:=tstringlist.create;
                                             try
                                                 mOutputDocument.ObjectSpace.SQLSelect('select DataSource from Reports where ID=' + QuotedStr(AInput.S['Report_ID']),mr);
                                                 if mr.count>0 then begin
                                                    mDynCLSID:=mr.strings[0];
                                                 end else begin
                                                    mDynCLSID := mOutputDocument.DefaultDynSourceID;
                                                 end;
                                             finally
                                                 mr.free;
                                             end;

                                         try
                                            CFxReportManager.PrintByIDs(NxCreateContext(mOutputDocument.ObjectSpace),mPrintList,mDynCLSID, AInput.S['Report_ID'], rtofile, pekPDF,NxGetTempDir,aname);
                                            mFile:=NxGetTempDir+'\'+aname;
                                            try

                                                    mFile:=NxGetTempDir+aname;
                                            except
                                            end;
                                          except
                                          end;
                                      finally
                                          mPrintList.free;
                                      end;

                                      //mFile:=iPrintDocument(mOutputDocument,AInput.S['ReportID'])
                                end else begin
                                      mFile:='';
                                end;

                                //AOutput.S['DebugSent']:='sestava vytvářena' + mfile;

                                //mstring:=iSendMailx(AContext.GetObjectSpace, 'Doklad: ' + mOutputDocument.DisplayName , 'Právě Vám byla odeslán doklad s číslem: ' +  mOutputDocument.DisplayName , AInput.S['Email'], '','','1100000101', mFile,mDivision_ID,mOutputDocument);
                                mstring:=SendMail_BO(AContext.GetObjectSpace, 'Doklad: ' + mOutputDocument.DisplayName , 'Právě Vám byla odeslán doklad s číslem: ' +  mOutputDocument.DisplayName , AInput.S['Email'], '','','1100000101', mFile,mDivision_ID,mOutputDocument);



                           end;


                               {   Result_string:='{';

                                Result_string:=Result_string + '"Created_by" :"' + mUser_ID+ '",' + chr(10);
                                Result_string:=Result_string + '"DocQueue_ID" :"' + mDocQueue_ID+ '",' + chr(10);


                                  Result_string:=Result_string + '"ID" :"' + mOutputDocument.oid+ '",' + chr(10);
                                  Result_string:=Result_string + '"New" :"' + mOutputDocument.DisplayName+ '",' + chr(10) ;
                                  Result_string:=Result_string + '"Source" :"' + mDocInputDocument + '",' + chr(10) ;
                                Result_string:=Result_string + '"Import" :"' + inttostr(mImportRows.count) + '",' + chr(10);
                                Result_string:=Result_string + '"Other" :"' + inttostr(mOtherRows.count) + '",' + chr(10);
                                Result_string:=Result_string + '"Imp. batch" :"' + inttostr(mImportBatches.count) + '",' + chr(10);
                                Result_string:=Result_string + '"Oth. batch" :"' + inttostr(mOtherBatches.count) + '",' + chr(10);
                            Result_string:=Result_string + '}

                                   AOutput.S['State']:='201';
                                   AOutput.S['SendDocument']:=NxSearchReplace(AInput.A['AbraDocuments'].O[iJSONDocuments].S['DocNumber'],'_','/',[srCase,srAll]);
                                   AOutput.S['Created_by']:=mUser_ID;
                                   AOutput.S['ID']:= mOutputDocument.oid;
                                   AOutput.S['New']:= mOutputDocument.DisplayName;
                                   AOutput.S['Error']:= '' ;
                                   AOutput.S['Source']:=mDocInputDocument;
                                   AOutput.S['Import']:=inttostr(mImportRows.count) ;
                                   AOutput.S['Other']:=inttostr(mOtherRows.count);
                                   AOutput.S['Imp_batch']:=inttostr(mImportBatches.count);
                                   AOutput.S['Oth_batch']:=inttostr(mOtherBatches.count);
                                   AOutput.S['NotSave']:=inttostr(mNotSaveRows.count) ;
                                   AOutput.S['NotSave_batch']:=inttostr(mNotsaveBatches.count);

                  end ;
            end else begin

                                            {
                                            Result_string:=Result_string + '"Created_by" :"' + mUser_ID+ '",' + chr(10);
                                            Result_string:=Result_string + '"DocQueue_ID" :"' + mDocQueue_ID+ '",' + chr(10);


                                              Result_string:=Result_string + '"ID" :"' + '### CHYBA ###' + '",' + chr(10);
                                              Result_string:=Result_string + '"New" :"' + '### Doklad nebyl vytvořen ### '+ '" neobsahuje řádky, je prázdný,' + chr(10) ;
                                              Result_string:=Result_string + '"Source" :"' + mDocInputDocument + '",' + chr(10) ;
                                            Result_string:=Result_string + '"Import" :"' + inttostr(mImportRows.count) + '",' + chr(10);
                                            Result_string:=Result_string + '"Other" :"' + inttostr(mOtherRows.count) + '",' + chr(10);
                                            Result_string:=Result_string + '"Imp. batch" :"' + inttostr(mImportBatches.count) + '",' + chr(10);
                                            Result_string:=Result_string + '"Oth. batch" :"' + inttostr(mOtherBatches.count) + '",' + chr(10);
                                Result_string:=Result_string + '}

                                   AOutput.S['State']:='400';
                                   AOutput.S['SendDocument']:=NxSearchReplace(AInput.A['AbraDocuments'].O[iJSONDocuments].S['DocNumber'],'_','/',[srCase,srAll]);
                                   AOutput.S['Created_by']:=mUser_ID;
                                   AOutput.S['ID']:='';
                                   AOutput.S['New']:='';
                                   AOutput.S['Error']:= 'Doklad neobsahuje žádný řádek' ;
                                   AOutput.S['Source']:=mDocInputDocument;
                                   AOutput.S['Import']:=inttostr(mImportRows.count) ;
                                   AOutput.S['Other']:=inttostr(mOtherRows.count);
                                   AOutput.S['Imp_batch']:=inttostr(mImportBatches.count);
                                   AOutput.S['Oth_batch']:=inttostr(mOtherBatches.count);
                                   AOutput.S['NotSave']:=inttostr(mNotSaveRows.count) ;
                                   AOutput.S['NotSave_batch']:=inttostr(mNotsaveBatches.count);



            end;
      end;

   result:=AOutput.AsString;
   //result:=AOutput;

  finally
          mImportdocuments.free;
          mImportRows.free;
          mOtherRows.free;
          mOtherBatches.free;
          mImportBatches.free;
          mSelectedRows.free;
          mNotSaveRows.free;
          mNotsaveBatches.free;
          AOutput.free;
          mJSONWork.free;
  end;

 end;

end;

















function POST_APINxGetDOC(AContext: TNxContext; Abody: TJSONSuperObject; APath: String): TJSONSuperObject;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
  mr,mx:tstringlist;
  i,iRow,iBatch,ii,j : integer;
  mJSON,AInput,mJSONHeads,mJSONRow,mJSONBatch,ARows,ABatches,mParameter:TJSONSuperObject;
  mJSONArray: TJSONSuperObjectArray;
  mi:integer;
  mBOHead,mBORows,mBOBatches:TNxCustomBusinessObject;
  mID,mString,mQuery:string;
  mMonRows,mMonBatches:TNxCustomBusinessMonikerCollection;
  mID_Period_ID, mOrdnumber,mID_Docqueue_ID,  mID_Doc, mDocumentType:string;
  mImport:boolean;
  mStringList,mxA:tstringlist;
  mStrings:string;
  iDocument:integer;
  mBatchesList,mBatchValue:tstringlist;
  mIBatch:integer;
  mResult_DocType,mResult_DocQueue,mResult_Documents:string;
  mPocetDokladu:integer;
  mUserBO:TNxCustomBusinessObject;
  mPrice:Double;
begin

   mResult_DocType:='';
   mResult_DocQueue:='';
   mResult_Documents:='';
   mPocetDokladu:=0;


      AInput:=TJSONSuperObject.create;
      AInput:= Abody;
      mJSON:=TJSONSuperObject.create;
      mParameter:=TJSONSuperObject.create;
      mStringList:=tstringlist.create;
      mImport:=false;
      try
          mImport:=NxStringToBool(Abody.S['Import']);
      finally
      end;

      mDocumentType:='';
      try
          mDocumentType:=Trim(UpperCase(Abody.S['DocType']));
      finally
      end;

      mStringList:=fnParsevalue(Abody.S['Input_Document'],';')  ;
     mPocetDokladu:= mStringList.count;
      for iDocument:=0 to mStringList.count-1 do begin;
                        if (AnsiPos('-', mStringList.Strings[iDocument])>0) and (AnsiPos('/', mStringList.Strings[iDocument])>0) then begin
                               mr:=tstringlist.create;
                               try
                                    if mDocumentType='' then AContext.SQLSelect('Select DocumentType from DocQUEUES where code=' + quotedstr(trim(copy(mStringList.Strings[iDocument],1,AnsiPos('-', mStringList.Strings[iDocument])-1))),mr);
                                    if mDocumentType<>'' then AContext.SQLSelect('Select DocumentType from DocQUEUES where code=' + quotedstr(trim(copy(mStringList.Strings[iDocument],1,AnsiPos('-', mStringList.Strings[iDocument])-1))) + ' and DocumentType=' + quotedstr('mDocumentType'),mr);

                                    if mr.count=1 then begin
                                          if (uppercase(mDocumentType)=Uppercase(mr.Strings[0])) or (trim(uppercase(mDocumentType))='')  then begin
                                                 mDocumentType:=mr.Strings[0]
                                          end else begin
                                               mResult_DocType:= 'Položky si neodpovídají';
                                          end;

                                    end else begin
                                          if mr.count=0 then begin
                                               mResult_DocQueue:=  'Nedohledána řada';
                                          end else begin
                                              mResult_DocQueue:= 'Více stejných řad';
                                          end
                                    end;

                               finally
                                    mr.free;
                               end;
                        end;

                        mr:=tstringlist.create;
                        try
                                 if mDocumentType='RO' then begin
                                              mBOHead:=AContext.GetObjectSpace.CreateObject('01CPMINJW3DL342X01C0CX3FCC');

                                              AContext.GetObjectSpace.SQLSelect('SELECT head.ID FROM Receivedorders Head join DocQUEUES DQ on dq.ID=Head.DocQUEUE_ID join Periods P on p.id=Head.Period_ID where (head.id=' + quotedstr(
                                                                               mStringList.Strings[iDocument])
                                                                                  + ')or ((DQ.code=' + quotedstr(
                                                                                trim(copy(mStringList.Strings[iDocument],1,AnsiPos('-', mStringList.Strings[iDocument])-1))
                                                                                  ) +' ) and (head.ordnumber=' + quotedstr(
                                                                                trim(copy(mStringList.Strings[iDocument],AnsiPos('-', mStringList.Strings[iDocument])+1,(AnsiPos('/', mStringList.Strings[iDocument]))-AnsiPos('-', mStringList.Strings[iDocument])-1))
                                                                                  ) + ') and (p.code=' + quotedstr(
                                                                                trim(copy(mStringList.Strings[iDocument],AnsiPos('/', mStringList.Strings[iDocument])+1,20))
                                                                                  )+')) or (head.Externalnumber=' + quotedstr(mStringList.Strings[iDocument]) +
                                                                                  ')'
                                                                                  //or (head.X_Varsymbol=' + quotedstr(Abody.S['Input_Document']) +')'
                                                                                  ,mr);
                                          end;
                                    if mDocumentType='IO' then begin
                                              mBOHead:=AContext.GetObjectSpace.CreateObject('CDMK5QAWZZDL342X01C0CX3FCC');

                                              AContext.GetObjectSpace.SQLSelect('SELECT head.ID FROM Issuedorders Head join DocQUEUES DQ on dq.ID=Head.DocQUEUE_ID join Periods P on p.id=Head.Period_ID where (head.id=' + quotedstr(
                                                                               mStringList.Strings[iDocument])
                                                                                  + ')or ((DQ.code=' + quotedstr(
                                                                                trim(copy(mStringList.Strings[iDocument],1,AnsiPos('-', mStringList.Strings[iDocument])-1))
                                                                                  ) +' ) and (head.ordnumber=' + quotedstr(
                                                                                trim(copy(mStringList.Strings[iDocument],AnsiPos('-', mStringList.Strings[iDocument])+1,(AnsiPos('/', mStringList.Strings[iDocument]))-AnsiPos('-', mStringList.Strings[iDocument])-1))
                                                                                  ) + ') and (p.code=' + quotedstr(
                                                                                trim(copy(mStringList.Strings[iDocument],AnsiPos('/', mStringList.Strings[iDocument])+1,20))
                                                                                  )+')) or (head.Externalnumber=' + quotedstr(mStringList.Strings[iDocument]) +
                                                                                  ')'
                                                                                  //or (head.X_Varsymbol=' + quotedstr(Abody.S['Input_Document']) +')'
                                                                                  ,mr);
                                          end;



                                    if mDocumentType='20' then begin
                                              mBOHead:=AContext.GetObjectSpace.CreateObject('E03ZNUMDTCC4PDAUIEY1MBTJC0');

                                              AContext.GetObjectSpace.SQLSelect('SELECT head.ID FROM Storedocuments Head join DocQUEUES DQ on dq.ID=Head.DocQUEUE_ID join Periods P on p.id=Head.Period_ID where (head.id=' + quotedstr(
                                                                               mStringList.Strings[iDocument])
                                                                                  + ')or ((DQ.code=' + quotedstr(
                                                                                trim(copy(mStringList.Strings[iDocument],1,AnsiPos('-', mStringList.Strings[iDocument])-1))
                                                                                  ) +' ) and (head.ordnumber=' + quotedstr(
                                                                                trim(copy(mStringList.Strings[iDocument],AnsiPos('-', mStringList.Strings[iDocument])+1,(AnsiPos('/', mStringList.Strings[iDocument]))-AnsiPos('-', mStringList.Strings[iDocument])-1))
                                                                                  ) + ') and (p.code=' + quotedstr(
                                                                                trim(copy(mStringList.Strings[iDocument],AnsiPos('/', mStringList.Strings[iDocument])+1,20))
                                                                                  )+')) '
                                                                                  //or (head.X_Varsymbol=' + quotedstr(Abody.S['Input_Document']) +')'
                                                                                  ,mr);
                                    end;



                                   if mDocumentType='21' then begin
                                              mBOHead:=AContext.GetObjectSpace.CreateObject('050I5SAOS3DL3ACU03KIU0CLP4');

                                               AContext.GetObjectSpace.SQLSelect('SELECT head.ID FROM Storedocuments Head join DocQUEUES DQ on dq.ID=Head.DocQUEUE_ID join Periods P on p.id=Head.Period_ID where (head.id=' + quotedstr(
                                                                               mStringList.Strings[iDocument])
                                                                                  + ')or ((DQ.code=' + quotedstr(
                                                                                trim(copy(mStringList.Strings[iDocument],1,AnsiPos('-', mStringList.Strings[iDocument])-1))
                                                                                  ) +' ) and (head.ordnumber=' + quotedstr(
                                                                                trim(copy(mStringList.Strings[iDocument],AnsiPos('-', mStringList.Strings[iDocument])+1,(AnsiPos('/', mStringList.Strings[iDocument]))-AnsiPos('-', mStringList.Strings[iDocument])-1))
                                                                                  ) + ') and (p.code=' + quotedstr(
                                                                                trim(copy(mStringList.Strings[iDocument],AnsiPos('/', mStringList.Strings[iDocument])+1,20))
                                                                                  )+')) '
                                                                                  //or (head.X_Varsymbol=' + quotedstr(Abody.S['Input_Document']) +')'
                                                                                  ,mr);
                                    end;









                                         if mr.count=0 then mResult_Documents:= 'nedohledano';
                                         if mr.count>1 then mResult_Documents:= 'dohledano vice';

                                         if mr.count=1 then begin



                                                 mResult_DocType:=mDocumentType;
                                                 mResult_Documents:= 'Dohledáno_OK';



                                                              mBOHead.load(mr.Strings[0],nil);

                                                     if iDocument=0 then begin

                                                             if mImport then begin
                                                                    if mDocumentType='RO' then begin
                                                                            if (trim(mBOHead.GetFieldValueAsString('DocQueue_ID.X_API_OP'))='') or
                                                                               (trim(mBOHead.GetFieldValueAsString('DocQueue_ID.X_API_OP'))='{}') then begin
                                                                                mJSON.S['_Result_Documents']:= 'Není možné synchronizovat - nejsou parametry';
                                                                                result:=mJSON;
                                                                                exit;
                                                                            end else begin
                                                                                mJSON := TJSONSuperObject.ParseString(mBOHead.GetFieldValueAsString('DocQueue_ID.X_API_OP'), True);
                                                                            end;
                                                                      end;

                                                                    if mDocumentType='IO' then begin
                                                                            if (trim(mBOHead.GetFieldValueAsString('DocQueue_ID.X_API_OV'))='') or
                                                                               (trim(mBOHead.GetFieldValueAsString('DocQueue_ID.X_API_OV'))='{}') then begin
                                                                                mJSON.S['_Result_Documents']:= 'Není možné synchronizovat - nejsou parametry';
                                                                                result:=mJSON;
                                                                                exit;
                                                                            end else begin
                                                                                mJSON := TJSONSuperObject.ParseString(mBOHead.GetFieldValueAsString('DocQueue_ID.X_API_OV'), True);
                                                                            end;
                                                                      end;

                                                                      if mDocumentType='20' then begin
                                                                            if (trim(mBOHead.GetFieldValueAsString('DocQueue_ID.X_API_PR'))='') or
                                                                               (trim(mBOHead.GetFieldValueAsString('DocQueue_ID.X_API_PR'))='{}') then begin
                                                                                mJSON.S['_Result_Documents']:= 'Není možné synchronizovat - nejsou parametry';
                                                                                result:=mJSON;
                                                                                exit;
                                                                            end else begin
                                                                                mJSON := TJSONSuperObject.ParseString(mBOHead.GetFieldValueAsString('DocQueue_ID.X_API_PR'), True);
                                                                            end;
                                                                      end;

                                                                      if mDocumentType='21' then begin
                                                                             if (trim(mBOHead.GetFieldValueAsString('DocQueue_ID.X_API_PR'))='') or
                                                                               (trim(mBOHead.GetFieldValueAsString('DocQueue_ID.X_API_PR'))='{}') then begin
                                                                                mJSON.S['_Result_Documents']:= 'Není možné synchronizovat - nejsou parametry';
                                                                                result:=mJSON;
                                                                                exit;
                                                                            end else begin
                                                                                mJSON := TJSONSuperObject.ParseString(mBOHead.GetFieldValueAsString('DocQueue_ID.X_API_PR'), True);
                                                                            end;

                                                                            //if (trim(mBOHead.GetFieldValueAsString('DocQueue_ID.X_API_DL'))='') or
                                                                            //   (trim(mBOHead.GetFieldValueAsString('DocQueue_ID.X_API_DL'))='{}') then begin
                                                                            //    mJSON.S['_Result_Documents']:= 'Není možné synchronizovat - nejsou parametry';
                                                                            //    result:=mJSON;
                                                                            //    exit;
                                                                            //end else begin
                                                                            //    mJSON := TJSONSuperObject.ParseString(mBOHead.GetFieldValueAsString('DocQueue_ID.X_API_DL'), True);
                                                                            //end;
                                                                      end;

                                                                      if mDocumentType='03' then begin
                                                                            if (trim(mBOHead.GetFieldValueAsString('DocQueue_ID.X_API_FP'))='') or
                                                                               (trim(mBOHead.GetFieldValueAsString('DocQueue_ID.X_API_FP'))='{}') then begin
                                                                                mJSON.S['_Result_Documents']:= 'Není možné synchronizovat - nejsou parametry';
                                                                                result:=mJSON;
                                                                                exit;
                                                                            end else begin
                                                                                mJSON := TJSONSuperObject.ParseString(mBOHead.GetFieldValueAsString('DocQueue_ID.X_API_FP'), True);
                                                                            end;
                                                                      end;

                                                                      if mDocumentType='04' then begin
                                                                            if (trim(mBOHead.GetFieldValueAsString('DocQueue_ID.X_API_FV'))='') or
                                                                               (trim(mBOHead.GetFieldValueAsString('DocQueue_ID.X_API_FV'))='{}') then begin
                                                                                mJSON.S['_Result_Documents']:= 'Není možné synchronizovat - nejsou parametry';
                                                                                result:=mJSON;
                                                                                exit;
                                                                            end else begin
                                                                                mJSON := TJSONSuperObject.ParseString(mBOHead.GetFieldValueAsString('DocQueue_ID.X_API_FV'), True);
                                                                            end;
                                                                      end;


                                                                      mUserBO:= AContext.GetObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');
                                                                      try
                                                                            mUserBO.load(AContext.GetCompanyCache.GetUserID,nil);
                                                                            mJSON.S['User']:= 'Supervisor';//mUserBO.GetFieldValueAsString('LoginName');
                                                                      finally
                                                                            mUserBO.free;
                                                                      end;

                                                                      mJSON.S['SelectedRows']:= '';
                                                                      mJSON.S['InputDocuments']:= '';
                                                                      mJSON.S['SelectedHeader']:= '';

                                                                      if trim(UpperCase(mJSON.S['Firm_Name']))= 'FIRM_ID.NAME' then
                                                                           mJSON.S['Firm_Name']:= mBOHead.GetFieldValueAsString('Firm_ID.Name');
                                                                      //else mJSON.S['Firm_Name']:= 'LIPOELASTIC s.r.o.';

                                                                      //result:=mParameter;
                                                                      //exit ;
                                                             end;
                                                             mJSON.O['AbraDocuments'] := mJSON.CreateJSONArray;
                                                      end;
                                                      //mJSON.O['AbraDocuments'] := mJSON.CreateJSONArray;

                                                       mJSONHeads:=TJSONSuperObject.Create;
                                                       mJSONHeads.S['ID']:= mr.Strings[0];
                                                       mJSONHeads.S['DocType']:= mDocumentType;
                                                       mJSONHeads.S['User']:= '';
                                                       mJSONHeads.S['DocNumber']:=mBOHead.GetFieldValueAsString('DisplayName');
                                                     //  mJSONHeads.I['TradeType']:=mBOHead.GetFieldValueAsInteger('TradeType');
                                                     //  mJSONHeads.S['Firm']:= mBOHead.GetFieldValueAsString('Firm_ID.Name');
                                                       mJSONHeads.S['Firma']:= mBOHead.GetFieldValueAsString('Firm_ID.Name');
                                                       mJSONHeads.S['Provozovna']:= mBOHead.GetFieldValueAsString('FirmOffice_ID.Name');

                                                        mJSONHeads.S['Description']:= mBOHead.GetFieldValueAsString('Description');

                                                       if mImport then begin
                                                             mJSONHeads.S['Docqueue_ID']:= mBOHead.GetFieldValueAsString('Docqueue_ID');
                                                            //**** mJSONHeads.S['X_Poznam_exp']:= mBOHead.GetFieldValueAsString('X_Poznam_exp_ext');
                                                            //**** mJSONHeads.S['X_Poznam_exp_ext']:= mBOHead.GetFieldValueAsString('X_Poznam_exp');
                                                             //***** mJSONHeads.S['Firm_ID']:= mBOHead.GetFieldValueAsString('Firm_ID');
                                                             mJSONHeads.S['TradeType']:= IntToStr(mBOHead.GetFieldValueAsInteger('tradetype'));
//                                                             mJSONHeads.S['Country_ID']:= mBOHead.GetFieldValueAsString('00000SK000');
                                                            // mJSONHeads.S['IntrastatDeliveryTerm_ID']:= mBOHead.GetFieldValueAsString('3001000000');
                                                            //mJSONHeads.S['IntrastatTransactionType_ID']:= mBOHead.GetFieldValueAsString('0101000000');
                                                            // mJSONHeads.S['IntrastatTransportationType_ID']:= mBOHead.GetFieldValueAsString('2000000000');

                                                                            if mDocumentType='RO' then begin
                                                                                  //******* mJSONHeads.S['X_Termin_dodani']:= FormatDateTime('YYYY-MM-DD',mBOHead.GetFieldValueAsDateTime('X_datum_dodani'));
                                                                            end;
                                                                            if mDocumentType='OV' then begin
                                                                                  //*******mJSONHeads.S['X_datum_dodani']:= FormatDateTime('YYYY-MM-DD',mBOHead.GetFieldValueAsDateTime('X_datum_dodani'));
                                                                            end;

                                                                           if NxIsBlank(mBOHead.GetFieldValueAsString('X_ExternalDocument')) or (trim(mBOHead.GetFieldValueAsString('X_ExternalDocument'))='0') then begin
                                                                                mJSONHeads.S['X_ExternalDocument']:= mBOHead.DisplayName;

                                                                                mJSONHeads.S['X_ExternalDocument']:= mBOHead.GetFieldValueAsString('X_ExternalDocument');
                                                                            end;

                                                                            if ((mDocumentType='IO') or  (mDocumentType='RO')) then begin
                                                                                 mJSONHeads.S['Confirmed']:= 'True';
                                                                                 mJSONHeads.S['Currency_ID']:= mBOHead.GetFieldValueAsString('Currency_ID');
                                                                                 try
                                                                                         if NxIsBlank(mBOHead.GetFieldValueAsString('X_Identifikace'))  then begin
                                                                                            mJSONHeads.S['X_Identifikace']:= mBOHead.GetFieldValueAsString('Firm_ID.Name');
                                                                                         end else begin
                                                                                            mJSONHeads.S['X_Identifikace']:= mBOHead.GetFieldValueAsString('Currency_ID');
                                                                                         end;

                                                                                         if NxIsBlank(mBOHead.GetFieldValueAsString('ExternalNumber'))  then begin
                                                                                            mJSONHeads.S['ExternalNumber']:= mBOHead.DisplayName;
                                                                                         end else begin
                                                                                            mJSONHeads.S['ExternalNumber']:= mBOHead.GetFieldValueAsString('ExternalNumber');
                                                                                         end;
                                                                                 finally
                                                                                 end;
                                                                            end;
                                                                            //mQuery:=mQuery +'"DocumentDiscount":" ' + NxFloatToIBStr(Self.GetFieldValueAsFloat('DocumentDiscount')) + '", '                  ;
                                                                            try
                                                                             mJSONHeads.S['Description']:= mBOHead.GetFieldValueAsString('Description');
                                                                            finally end;
                                                                            try
                                                                            //*****    mJSONHeads.S['X_poznamka']:= mBOHead.GetFieldValueAsString('X_poznamka');
                                                                            finally end;
                                                       end;


                                                        if ((mBOHead.CLSID='01CPMINJW3DL342X01C0CX3FCC') or (mBOHead.CLSID='CDMK5QAWZZDL342X01C0CX3FCC')) then begin
                                                              // mJSONHeads.S['CurrencyCode']:= mBOHead.GetFieldValueAsString('CurrencyCode');
                                                              //  mJSONHeads.S['CountryCode']:= mBOHead.GetFieldValueAsString('CountryCode');
                                                              //  mJSONHeads.S['DeliveryType']:= mBOHead.GetFieldValueAsString('DeliveryType');
                                                              //  mJSONHeads.S['PaymentType']:= mBOHead.GetFieldValueAsString('PaymentType');

                                                               mJSONHeads.S['ExternalNumber']:= mBOHead.GetFieldValueAsString('ExternalNumber');
                                                                       //*********mJSONHeads.S['X_poznamka']:= mBOHead.GetFieldValueAsString('X_poznamka');
                                                                       mJSONHeads.S['Currency_ID']:= mBOHead.GetFieldValueAsString('Currency_ID');
                                                         end else begin
                                                                      mJSONHeads.S['Currency_ID']:= '0000EUR000';
                                                                      mJSONHeads.S['CurrencyCode']:= 'EUR';
                                                         end;
                                                                mMonRows := mBOHead.GetLoadedCollectionMonikerForFieldCode(mBOHead.GetFieldCode('ROWS'));
                                                                                   // řádky
                                                                                mJSONHeads.O['Rows'] := mJSONHeads.CreateJSONArray;
                                                                                for iRow := 0 to mMonRows.Count - 1 do begin
                                                                                    mJSONRow:=TJSONSuperObject.Create;
                                                                                        mJSONRow.I['PosIndex']:=mMonRows.BusinessObject[iRow].GetFieldValueAsInteger('PosIndex');
                                                                                        //*****mJSONRow.S['Sklad']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('Store_ID.Code');
                                                                                        mJSONRow.S['ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('ID');
                                                                                        mJSONRow.S['StoreCard_EAN']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('Storecard_ID.EAN');
                                                                                        mJSONRow.S['StoreCard_Name']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('Storecard_ID.Name');
                                                                                        mJSONRow.D['Quantity']:=mMonRows.BusinessObject[iRow].GetFieldValueAsFloat('Quantity');
                                                                                        mJSONRow.D['WorkQuantity']:=0;
                                                                                        mJSONRow.D['DeliveredQuantity']:=mMonRows.BusinessObject[iRow].GetFieldValueAsFloat('DeliveredQuantity');
                                                                                       //**** mJSONRow.S['DeliveryDate$DATE']:=FormatDateTime('YYYY-MM-DD',mMonRows.BusinessObject[i].GetFieldValueAsDateTime('DeliveryDate$DATE'));
                                                                                        mJSONRow.S['QUnit']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('QUnit');
                                                                                        mJSONRow.S['X_ProvideRow_ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('X_Providerow_ID');
                                                                                        mJSONRow.S['StoreCard_ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('Storecard_ID');
                                                                                        mJSONRow.S['Store_Code']:= mMonRows.BusinessObject[iRow].GetFieldValueAsString('Store_ID.Code') ;

                                                                                        if mMonRows.BusinessObject[iRow].GetFieldValueAsinteger('Storecard_ID.Category')=0 then begin
                                                                                                mJSONRow.O['DocRowBatches'] := mJSONRow.CreateJSONArray;
                                                                                                mJSONBatch:=TJSONSuperObject.Create;
                                                                                                                      //mJSONBatch.S['Posindex']:=inttostr(0);
                                                                                                                      //mJSONBatch.S['StoreBatch']:='';
                                                                                                                      //mJSONBatch.D['Quantity']:=0
                                                                                                                      //mJSONBatch.S['QUnit']:='';
                                                                                                                 mJSONRow.A['DocRowBatches'].Add(mJSONBatch);
                                                                                        end;


                                                                                        if mImport then begin
                                                                                            mJSONRow.I['RowType']:=mMonRows.BusinessObject[iRow].GetFieldValueAsInteger('RowType');
                                                                                            mJSONRow.S['Text']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('Text');
                                                                                            //**** mJSONRow.S['BusOrder_ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('BusOrder_ID');
                                                                                            mJSONRow.S['BusOrder_Code']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('BusOrder_ID.Code');
                                                                                           //**** mJSONRow.S['BusTransaction_ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('BusTransaction_ID');
                                                                                            mJSONRow.S['BusTransaction_Code']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('BusTransaction_ID.Code');
                                                                                            //**** mJSONRow.S['BusProject_ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('BusProject_ID');
                                                                                            mJSONRow.S['BusProject_Code']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('BusProject_ID.Code');
                                                                                            mJSONRow.S['X_ProvideRow_ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('X_Providerow_ID');
                                                                                            mJSONRow.S['X_Specifikace_ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('X_specifikace_id');
                                                                                            mJSONRow.S['X_ExternalSpecification']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('X_ExternalSpecification');
                                                                                            mJSONRow.S['StoreCard_ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('Storecard_ID');
                                                                                            mJSONRow.S['Store_ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('Store_ID');
                                                                                            //**** mJSON.S['Division_Code']:= mMonRows.BusinessObject[iRow].GetFieldValueAsString('Division_ID.Code');

                                                                                            //mJSON.S['Store_Code']:= mMonRows.BusinessObject[iRow].GetFieldValueAsString('Store_ID.Code') ;
                                                                                            if uppercase(mJSON.S['WithPrices'])='TRUE' then begin
                                                                                                    // **     ceny      *****
                                                                                                    mprice:=0;
                                                                                                    mxa:=tstringlist.create;
                                                                                                       // z faktury
                                                                                                             try
                                                                                                                 if mDocumentType='21' then AContext.GetObjectSpace.SQLSelect('select ii2.TAmount/ii2.quantity from issuedinvoices2 ii2 join issuedinvoices ii on ii.id=ii2.parent_ID where Providerow_ID =' + QuotedStr(mMonRows.BusinessObject[iRow].GetFieldValueAsString('X_Providerow_ID')),mxa);

                                                                                                                 if mxa.count>0 then begin
                                                                                                                      mprice:=NxIBStrToFloat(mxa.Strings[0]);
                                                                                                                 end else begin
                                                                                                                 end;
                                                                                                             finally
                                                                                                                 mxa.free;
                                                                                                             end;
                                                                                                       if mprice=0 then begin
                                                                                                             // z cenníku
                                                                                                                  mprice:=NxEvalObjectExprAsFloatDef(mBOHead,'NxGetStoreCardUnitPriceDef('+Quotedstr(mBOHead.GetFieldValueAsString('Firm_ID'))+', '
                                                                                                                                  +Quotedstr(mMonRows.BusinessObject[iRow].GetFieldValueAsString('Store_ID'))+', '
                                                                                                                                  +QuotedStr(mMonRows.BusinessObject[iRow].GetFieldValueAsString('Storecard_ID')) + ','
                                                                                                                                  +Quotedstr(mBOHead.GetFieldValueAsString('Firm_ID.Price_ID'))+', '
                                                                                                                                  +Quotedstr(mMonRows.BusinessObject[iRow].GetFieldValueAsString('Qunit'))+',False,'
                                                                                                                                  +QuotedStr(mBOHead.GetFieldValueAsString('Firm_ID.Price_ID.Currency_ID'))+','
                                                                                                                                  +inttostr(trunc(Date))+')',0);
                                                                                                       end;
                                                                                                       if mprice<>0 then begin
                                                                                                                mJSONRow.S['UnitPrice']:=NxFloatToIBStr(mprice);
                                                                                                                mJSONRow.S['TotalPrice']:=NxFloatToIBStr(mprice*mMonRows.BusinessObject[iRow].GetFieldValueAsFloat('Quantity'));
                                                                                                                mJSONRow.S['TAmount']:=NxFloatToIBStr(mprice*mMonRows.BusinessObject[iRow].GetFieldValueAsFloat('Quantity'));
                                                                                                                //mJSONRow.S['Tamountwithoutvat']:=NxFloatToIBStr(mprice*mMonRows.BusinessObject[iRow].GetFieldValueAsFloat('Quantity'));
                                                                                                       end;
                                                                                            end;
                                                                                        end;
                                                                                            if ((mBOHead.CLSID<>'01CPMINJW3DL342X01C0CX3FCC') and (mBOHead.CLSID<>'CDMK5QAWZZDL342X01C0CX3FCC')) then begin
                                                       //                                          mJSONRow.S['X_Storedocuments2_ID']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('X_Storedocuments2_ID');
                                                       //                                         // ****** šarže na skladových dokladech
                                                                                                 mMonBatches := mMonRows.BusinessObject[iRow].GetLoadedCollectionMonikerForFieldCode(mMonRows.BusinessObject[iRow].GetFieldCode('DocRowBatches'));
                                                                                                          mJSONRow.O['DocRowBatches'] := mJSONRow.CreateJSONArray;
                                                                                                              for iBatch := 0 to mMonBatches.Count - 1 do begin
                                                                                                                  mJSONBatch:=TJSONSuperObject.Create;
                                                                                                                      mJSONBatch.S['Posindex']:=inttostr(mMonBatches.BusinessObject[iBatch].GetFieldValueAsInteger('Posindex'));
                                                                                                                      mJSONBatch.S['ID']:=mMonBatches.BusinessObject[iBatch].OID;
                                                                                                                      mJSONBatch.S['StoreBatch']:=mMonBatches.BusinessObject[iBatch].GetFieldValueAsString('StoreBatch_id.Name');
                                                                                                                      mJSONBatch.D['Quantity']:=mMonBatches.BusinessObject[iBatch].GetFieldValueAsFloat('Quantity');
                                                                                                                      mJSONBatch.D['WorkQuantity']:=0;
                                                                                                                      mJSONBatch.D['DeliveredQuantity']:=0;
                                                                                                                      mJSONBatch.S['QUnit']:=mMonBatches.BusinessObject[iBatch].GetFieldValueAsString('QUnit');
                                                                                                                 mJSONRow.A['DocRowBatches'].Add(mJSONBatch);
                                                                                                              end;
                                                                                            end else begin
                                                                                                 // šarže z objednávek
                                                                                                         mJSONRow.O['DocRowBatches'] := mJSONRow.CreateJSONArray;
                                                                                                              mBatchesList:=tstringlist.create;
                                                                                                              try
                                                                                                              // ro
                                                                                                              if (mBOHead.CLSID='01CPMINJW3DL342X01C0CX3FCC') then begin
                                                                                                                      AContext.SQLSelect('SELECT A.ID,B.Name,A.X_quantity FROM DefRollData A join StoreBatches B on b.id =a.X_Batches WHERE (A.Hidden = ' + quotedstr('N') + ' ) AND (A.CLSID = ' + quotedstr('EC2R2HSFK5UOZ5MYVJWJOHUC4S')
                                                                                                                            + ' ) AND (a.X_parent_ID=' + quotedstr(mMonRows.BusinessObject[iRow].OID) + ')',mBatchesList)   ;
                                                                                                              end;
                                                                                                              // io
                                                                                                              if (mBOHead.CLSID='CDMK5QAWZZDL342X01C0CX3FCC') then begin
                                                                                                                      AContext.SQLSelect('SELECT A.ID,B.Name,A.X_quantity FROM DefRollData A join StoreBatches B on b.id =a.X_Batches WHERE (A.Hidden = ' + quotedstr('N') + ' ) AND (A.CLSID = ' + quotedstr('EC2R2HSFK5UOZ5MYVJWJOHUC4S')
                                                                                                                            + ' ) AND (a.X_parent_ID=' + quotedstr(mMonRows.BusinessObject[iRow].OID) + ')',mBatchesList)  ;
                                                                                                              end;
                                                                                                                      if mBatchesList.count>0 then begin
                                                                                                                              for iBatch := 0 to mBatchesList.Count - 1 do begin
                                                                                                                                  mJSONBatch:=TJSONSuperObject.Create;
                                                                                                                                         mJSONBatch.S['Posindex']:=inttostr(iBatch+1);
                                                                                                                                         mBatchValue:=TStringList.create;
                                                                                                                                         mBatchValue:=fnParsevalue(mBatchesList.Strings[mIBatch],';');
                                                                                                                                         try
                                                                                                                                              if mBatchValue.count>0 then mJSONBatch.S['ID']:=mBatchValue.Strings[0];
                                                                                                                                              if mBatchValue.count>1 then mJSONBatch.S['StoreBatch']:=mBatchValue.Strings[1];
                                                                                                                                              if mBatchValue.count>2 then mJSONBatch.D['Quantity']:=NxIBStrToFloat(mBatchValue.Strings[2]);
                                                                                                                                              if mBatchValue.count>2 then mJSONBatch.D['DeliveredQuantity']:=0;
                                                                                                                                              mJSONBatch.D['WorkQuantity']:=0;
                                                                                                                                              mJSONBatch.S['QUnit']:=mMonRows.BusinessObject[iRow].GetFieldValueAsString('QUnit');
                                                                                                                                         finally
                                                                                                                                             mBatchValue.free;
                                                                                                                                         end;
                                                                                                                                 mJSONRow.A['DocRowBatches'].Add(mJSONBatch);
                                                                                                                              end;
                                                                                                                      end;
                                                                                                              finally
                                                                                                                  mBatchesList.free;
                                                                                                              end;

                                                                                            end;




                                                                                        mJSONHeads.A['Rows'].Add(mJSONRow);
                                                                                end;
                                                                     //   mJSON.A['AbraDocuments'].Add(mJSONHeads);

                                         end;









                        finally
                            mr.free;
                        end;
                           mJSON.A['AbraDocuments'].Add(mJSONHeads);

        end;    // konec cyklu dokladu


       mStringList.free;

       //mJSON.S['_Result_DocType']:=mResult_DocType;
       //mJSON.S['_Result_DocQueue']:=mResult_DocQueue;
       //mJSON.S['_Result_Documents']:=mResult_Documents;
       //mJSON.I['_Result_PocetDokladu']:=mPocetDokladu;
       result:=mJSON;
end;








function POST_APINxArabia(AContext: TNxContext; Abody: TJSONSuperObject; APath: String): TJSONSuperObject;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
  mr,mx:tstringlist;
  i,ii : integer;
  AOutPut,AInput,ABatch:TJSONSuperObject;
  mJSONArray: TJSONSuperObjectArray;
  mi:integer;
  mBO_Batch:TNxCustomBusinessObject;
  mID,mString:string;
  mStorecard_ID,mBatch_ID:string;
  mPrintList:tstringlist;
  mBytes:TBytes;
  mbo:TNxCustomBusinessObject;
  mOpenRolSite: TOpenRolSite;
//  mBO: TNxHeaderBusinessObject;
mbatchHelp:string;
begin
      AInput:=TJSONSuperObject.create;
      AInput:= Abody;
      mBatch_ID:='';
      mStorecard_ID:='';
      mstring:='';
      AOutPut:=TJSONSuperObject.create;
              if not nxisblank(AInput.S['DATAMATRIX']) then begin
                     mstring:= DatamatrixDecodeBatches(AContext.GetObjectSpace,AInput.S['DATAMATRIX']);
                      //AOutPut.S['String'] := mstring;
                      mStorecard_ID:=copy(mstring,12,10);
                    //  AOutPut.S['mStorecard_ID'] := copy(mstring,12,10);
                      mBatch_ID:= copy(mstring,23,10);
                    //  AOutPut.S['mBatch_ID'] := copy(mstring,23,10);
              end else begin
                       mr:=TStringList.create;
                        mbatchHelp:=AInput.S['BATCH'];
                        try
                          if Length(mbatchHelp)>16 then begin
                                   mbatchHelp:= copy(mbatchHelp,1,12);
                          end;
                          if Length(mbatchHelp)<12 then begin
                                   mbatchHelp:= NxRight('000000000000' + mbatchHelp,12);
                          end;


                          AContext.GetObjectSpace.SQLSelect('SELECT sc.id,SB.ID COLLATE Czech_CS_AS from StoreBatches SB left join Storecards SC on sb.Storecard_id=sc.id  Where SC.EAN=' + Quotedstr(AInput.S['EAN'])
                                            + ' and (( SB.Name=' + Quotedstr(AInput.S['BATCH']) + ') or ( SB.Name=' + Quotedstr(mbatchHelp)+'))'
                            ,mr);
                                IF mr.count>0 then begin
                                    mStorecard_ID:=copy(mr.Strings[0],1,10);
                                    mBatch_ID:=copy(mr.Strings[0],12,10);
                                    AOutPut.S['mStorecard_ID'] := copy(mr.Strings[0],1,10);
                                    AOutPut.S['mBatch_ID'] := copy(mr.Strings[0],12,10);
                                   // if AInput.S['print']='A' then begin


                                       //   gOpenRolSite.ParentForm := TComponent(Sender).Site.GetSiteAppForm;
                                          //gOpenRolSite.AfterClose := @TestAfterCloseRolSite;
                                       //   gOpenRolSite.MultiChoice := True;
                                       //   gOpenRolSite.Open;
                                                //mBO := TNxHeaderBusinessObject(TComponent(Sender).Site.BaseObjectSpace.CreateObject(Class_IssuedInvoice));
                                                //try
                                      //              gOpenRolSite.ParentForm := TComponent(Sender).Site.GetSiteAppForm;
                                          //gOpenRolSite.AfterClose := @TestAfterCloseRolSite;
                                      //    gOpenRolSite.MultiChoice := True;
                                      //    gOpenRolSite.;


                                     //           AOutPut.S['mBatch_ID'] := copy(mr.Strings[0],12,10);

                                                {  mBO.load(mBatch_ID,nul);
                                                  mBO.Prefill;
                                                  mBO.SetFieldValueAsString('Description', '*** test OpenDynSite ***');
                                                  gOpenDynSite.NewDoc := mBO;
                                                  gOpenDynSite.AfterClose:= @TestAfterCloseDynSite;
                                                  gOpenDynSite.Open;}

                                     //     finallz

                                     //     end;

                                    //  mbo:=AContext.GetObjectSpace.CreateObject('C32QXZWCTVDL342W01C0CX3FCC');
                                    //    try
                                    //        mbo.load(copy(mr.Strings[0],12,10),nil);
                                    //        mbo.setFieldValueAsString('X_Helpfield', (mbo.getFieldValueAsString('X_Helpfield') + '.'));
                                    //        mbo.save;
                                    //         AOutPut.S['Print'] := 'OK';
                                    //    finally
                                    //        mbo.free;
                                    //    end;
                                    //end;

                                    mPrintList:=TStringList.create;
                                    try
                                        mPrintList.add(copy(mr.Strings[0],12,10)) ;
                                        if AInput.S['print']='A' then begin
                                            CFxReportManager.PrintByIDs(Acontext, mPrintList, 'O1YGCLIJUNDL342X01C0CX3FCC', '~00000000L', rtoPrint, pekHTML,'Citizen','') ;
                                        end;
                                       //TBytes:=CFxReportManager.PrintByIDsToBytes(Acontext, mPrintList, 'O1YGCLIJUNDL342X01C0CX3FCC', '~00000000L',  pekPDF) ;
                                        //AOutPut.S['mFileBase64'] := EncodeBase64( TBytes );
                                    finally
                                        mPrintList.free;
                                    end;




                                  //  AOutPut.S['ExtFile'] := '\\CZVS0006\abrag3\tmp' + 'test.pdf';

                                end;
                         finally
                             mr.free;
                         end;
              end;


              mr:=TStringList.create;
                        try
                     //     AOutPut.S['xxx'] := 'SELECT SB.ID COLLATE Czech_CS_AS from StoreBatches SB left join Storecards SC on sb.Storecard_id=sc.id  Where SC.id=' + Quotedstr(mStorecard_ID);

                          if AInput.S['AllItems']='A' then begin
                              AContext.GetObjectSpace.SQLSelect('SELECT SB.ID COLLATE Czech_CS_AS from StoreBatches SB left join Storecards SC on sb.Storecard_id=sc.id  Where SC.id=' + Quotedstr(mStorecard_ID)
                                  ,mr);
                          end else begin
                              AContext.GetObjectSpace.SQLSelect('SELECT SB.ID COLLATE Czech_CS_AS from StoreBatches SB left join Storecards SC on sb.Storecard_id=sc.id  Where SC.id=' + Quotedstr(mStorecard_ID) + ' and Sb.id=' + Quotedstr(mBatch_ID)
                                  ,mr);
                          end;
                                IF mr.count>0 then begin

                                             mBO_Batch:=AContext.GetObjectSpace.CreateObject('C32QXZWCTVDL342W01C0CX3FCC');
                                             try
                                                 if mr.count>0 then begin
                                                    for ii := 0 to mr.Count - 1 do begin
                                                          mBO_Batch.load(mr.Strings[ii]);
                                                               if ii=0 then begin
                                                                     AOutPut.S['Name'] := mBO_Batch.GetFieldValueAsString('Storecard_ID.Name');
                                                                     AOutPut.S['EAN'] := mBO_Batch.GetFieldValueAsString('Storecard_ID.EAN');
                                                                      AOutPut.S['id'] := mBO_Batch.GetFieldValueAsString('Storecard_ID');
                                                                     AOutPut.O['BATCHES']:=AOutPut.CreateJSONArray;
                                                               end;

                                                              ABatch:=TJSONSuperObject.create;
                                                              ABatch.S['Nazev']:=mBO_Batch.GetFieldValueAsString('StoreCard_ID.X_Name_SA');
                                                              ABatch.S['Batch']:=mBO_Batch.GetFieldValueAsString('Name');
                                                              ABatch.S['EANcode']:=mBO_Batch.GetFieldValueAsString('Storecard_ID.EAN');
                                                              ABatch.S['EANtext']:=mBO_Batch.GetFieldValueAsString('Storecard_ID.EAN');
                                                              ABatch.S['Specifikace']:=mBO_Batch.GetFieldValueAsString('StoreCard_ID.Specification2');
                                                              ABatch.S['Material1']:=mBO_Batch.GetFieldValueAsString('X_MAT1.X_NL_Nazev');
                                                              ABatch.S['Material2']:=mBO_Batch.GetFieldValueAsString('X_MAT2.X_NL_Nazev');
                                                              ABatch.S['Material3']:=mBO_Batch.GetFieldValueAsString('X_MAT3.X_NL_Nazev');
                                                              ABatch.S['Material4']:=mBO_Batch.GetFieldValueAsString('X_MAT4.X_NL_Nazev');
                                                              ABatch.S['Material5']:=mBO_Batch.GetFieldValueAsString('X_MAT5.X_NL_Nazev');
                                                              ABatch.S['CisloMat1']:=mBO_Batch.GetFieldValueAsString('X_MAT1_PROC');
                                                              ABatch.S['CisloMat2']:=mBO_Batch.GetFieldValueAsString('X_MAT2_PROC');
                                                              ABatch.S['CisloMat3']:=mBO_Batch.GetFieldValueAsString('X_MAT3_PROC');
                                                              ABatch.S['CisloMat4']:=mBO_Batch.GetFieldValueAsString('X_MAT4_PROC');
                                                              ABatch.S['CisloMat5']:=mBO_Batch.GetFieldValueAsString('X_MAT5_PROC');
                                                              ABatch.S['MadeIn']:='صنع في جمهورية التشيك';




                                                              AOutPut.A['BATCHES'].Add(ABatch);
                                                    end;
                                                 end;
                                             finally
                                                 mBO_Batch.free;
                                             end;
                            end else begin
                                AOutPut.S['Status'] := 'Nedohledáno';
                            end;
                        finally
                            mr.free;
                        end;
                    result:=AOutPut;

end;







function NXInserRowFromDatamatrix(os:TNxCustomObjectSpace;mhead:TNxHeaderBusinessObject;mVisual:boolean; mDatamatrix:string;mStore_id:string;mDivision_ID:string;mBusOrder_ID,mBusProject_ID,mBusTransaction_ID:string):string;
var
mRow,mRowBatch:TNxCustomBusinessObject;
mMonRows,mMonBatches:TNxCustomBusinessMonikerCollection;
mIDatamatrixList,mIMonRows,mIMonBatches:integer;
mDatamatrixList:tstringlist;
mStoreCard_ID,mBatch_ID,mInputString,mstring:string;
mQuantity:double;
mvalue,mBatchList:Tstringlist;
mFindRow,mFindBatch:boolean;
mstringline:string;
mQuantityBatch,mpomoc:double;
begin

                      mDatamatrixList:=TStringList.create;
                         mDatamatrixList:=FNParsevalue(mDatamatrix, chr(10));
                        // if mVisual then ProgressInit(msite, 'Načítání dat ' + '', 100);
                          for mIDatamatrixList:=0 to mDatamatrixList.Count-1 do begin   // načtení souboru

                           // if mVisual then ProgressSetPos(1+NxFloor((mIDatamatrixList/mDatamatrixList.Count)*99), inttostr(mIDatamatrixList) +' z '+inttostr(mDatamatrixList.Count));
                            mstringline:= mDatamatrixList.strings[mIDatamatrixList];
                                if trim(mstringline)<>'' then begin
                                    mStoreCard_ID:='';
                                     mBatch_ID:='';
                                     mQuantity:=0;
                                     mInputString:='';
                                    mvalue:=tstringlist.create;
                                    try

                                        mstring:= DatamatrixDecodeBatches(os,mstringline);
                                        mvalue:=FNParsevalue(mstring,';');

                                        mStoreCard_ID:=mvalue.Strings[1];
                                        mBatch_ID:=mvalue.Strings[2];
                                        mQuantity:=NxIBStrToFloat(mvalue.Strings[3]);


                                      finally
                                           mvalue.free;
                                      end;


                                    if mStoreCard_ID<>'' then begin
                                            mMonRows := mHead.GetLoadedCollectionMonikerForFieldCode(mHead.GetFieldCode('ROWS'));
                                            mFindrow:=False;
                                            for mIMonRows := 0 to mMonRows.Count - 1 do begin
                                                     if mMonRows.BusinessObject[mIMonRows].getFieldValueAsstring('Storecard_ID')= mStoreCard_ID then begin
                                                                              mRow:= mMonRows.BusinessObject[mIMonRows];
                                                                              mMonRows.BusinessObject[mIMonRows].SetFieldValueAsFloat('Quantity',(mMonRows.BusinessObject[mIMonRows].GetFieldValueAsFloat('Quantity') + mQuantity));
                                                                               //mDataSet.FieldByName('Quantity').AsFloat:=(mDataSet.FieldByName('Quantity').AsFloat + mqauntity);
                                                                               mFindRow:=True;




                                                      end;
                                            end;
                                            if not mFindRow then begin
                                                          mRow := mHead.Rows.AddNewObject;
                                                          mRow.Prefill;
                                                          //mRow.SetFieldValueAsInteger('PosIndex',i);
                                                          mRow.SetFieldValueAsInteger('RowType',3);
                                                          mRow.SetFieldValueAsString('Store_ID',mstore_id);
                                                          mRow.SetFieldValueAsString('Storecard_ID',mStoreCard_ID);
                                                          mRow.SetFieldValueAsFloat('Quantity', mQuantity);
                                                          //mIRadku:=mIRadku+1;
                                                          //mIKusu:=mIKusu +mRow.getFieldValueAsFloat('Quantity');

                                                          mRow.SetFieldValueAsString('Division_ID',mDivision_ID); //text bude  ...

                                                          if mBusTransaction_ID<>'' then begin
                                                               mRow.SetFieldValueAsString('BusTransaction_id',mBustransaction_ID )
                                                          end else begin
                                                               if not NxIsEmptyOID((mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))) then begin
                                                                      mBustransaction_ID:=(mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'));
                                                                      mRow.SetFieldValueAsString('BusTransaction_id',mBustransaction_ID );
                                                               end;
                                                          end;

                                                          if mBusOrder_ID<>'' then begin
                                                               mRow.SetFieldValueAsString('BusOrder_ID',mBusOrder_ID )
                                                          end else begin
                                                              //mBusOrder_ID:=GetBusOrder_ID(mRow);
                                                              mRow.SetFieldValueAsString('BusOrder_id',mBusOrder_ID);
                                                          end;


                                                          if mBusProject_ID<>'' then begin
                                                               mRow.SetFieldValueAsString('BusProject_ID',mBusProject_ID )
                                                          end else begin
                                                              //mBusProject_ID:=GetProject_ID(mRow);
                                                              mRow.SetFieldValueAsString('BusProject_id',mBusProject_ID);
                                                          end;
                                            end;


                                            // skladové doklady
                                                          if ((mhead.CLSID<>'01CPMINJW3DL342X01C0CX3FCC') and (mhead.CLSID<>'CDMK5QAWZZDL342X01C0CX3FCC')) then begin
                                                                 mMonBatches:=mMonRows.BusinessObject[mIMonRows].GetLoadedCollectionMonikerForFieldCode(mMonRows.BusinessObject[mIMonRows].GetFieldCode('DocRowBatches'));
                                                                      mFindBatch:=false;
                                                                      for mIMonBatches:=0 to mMonBatches.count-1 do begin
                                                                           if mMonBatches.BusinessObject[mIMonBatches].GetFieldValueAsString('StoreBatch_ID')= mBatch_ID then begin
                                                                                mQuantityBatch:= mMonBatches.BusinessObject[mIMonBatches].GetFieldValueAsFloat('Quantity') + mQuantity;
                                                                                mMonBatches.BusinessObject[mIMonBatches].SetFieldValueAsFloat('Quantity',mQuantityBatch);
                                                                                mFindBatch:=true;
                                                                           end;
                                                                      end;
                                                                      If not mFindBatch then begin
                                                                      mRowBatch:= mMonBatches.AddNewObject;
                                                                          mRowBatch.Prefill;
                                                                                      mRowBatch.setFieldValueAsString('StoreBatch_ID',mBatch_ID);
                                                                                      mRowBatch.SetFieldValueAsFloat('Quantity',mQuantity);
                                                                                      mRowBatch.setFieldValueAsString('Qunit',mMonRows.BusinessObject[mIMonRows].getFieldValueAsstring('Qunit'));
                                                                      end;
                                                           end;




                                                          // objednávky
                                                          if ((mhead.CLSID='01CPMINJW3DL342X01C0CX3FCC') or (mhead.CLSID='CDMK5QAWZZDL342X01C0CX3FCC')) then begin
                                                             mBatchList:=TStringList.create;



                                                              if (mhead.CLSID='01CPMINJW3DL342X01C0CX3FCC') then begin
                                                                    mRowBatch:=os.CreateObject('SLARSB0H4CK4T32XPZTP33J3XS');
                                                                    os.SQLSelect('SELECT a.id FROM DefRollData A where A.CLSID=' + quotedstr('SLARSB0H4CK4T32XPZTP33J3XS') +
                                                                           ' and a.X_parent_ID='+quotedstr(mRow.OID) +' and A.X_Batches=' + quotedstr(mBatch_ID) ,mBatchList);
                                                                       if mBatchList.count>0 then begin
                                                                           mRowBatch.load(mBatchList.Strings[0],nil);
                                                                           mpomoc:=0;
                                                                           mpomoc:= (mRowBatch.GetFieldValueAsFloat('X_Quantity') + mQuantity);
                                                                           mRowBatch.SetFieldValueAsFloat('X_Quantity',mpomoc);
                                                                           mRowBatch.save;
                                                                           mFindBatch:=true;
                                                                       end else begin
                                                                           mFindBatch:=false;
                                                                       end;



                                                              end;
                                                              if (mhead.CLSID='CDMK5QAWZZDL342X01C0CX3FCC') then begin
                                                                    mRowBatch:=os.CreateObject('EC2R2HSFK5UOZ5MYVJWJOHUC4S');
                                                                    os.SQLSelect('SELECT a.id FROM DefRollData A where A.CLSID=' + quotedstr('EC2R2HSFK5UOZ5MYVJWJOHUC4S') +
                                                                          ' and a.X_parent_ID='+quotedstr(mRow.OID) + ' and A.X_Batches=' + quotedstr(mBatch_ID) ,mBatchList);
                                                                       if mBatchList.count>0 then begin
                                                                           mRowBatch.load(mBatchList.Strings[0],nil);
                                                                           mpomoc:=0;
                                                                           mpomoc:= (mRowBatch.GetFieldValueAsFloat('X_Quantity') + mQuantity);
                                                                           mRowBatch.SetFieldValueAsFloat('X_Quantity',mpomoc);
                                                                           mRowBatch.save;
                                                                           mFindBatch:=true;
                                                                       end else begin
                                                                           mFindBatch:=false;
                                                                       end;
                                                              end;


                                                               if not mFindBatch then begin

                                                                         try
                                                                                mRowBatch.new;
                                                                                mRowBatch.Prefill;
                                                                                mRowBatch.SetFieldValueAsFloat('X_quantity',mQuantity);

                                                                                mRowBatch.SetFieldValueAsstring('Code',mHead.OID);
                                                                                mRowBatch.SetFieldValueAsstring('X_Parent_ID',mRow.OID);
                                                                                mRowBatch.SetFieldValueAsstring('X_Firm_ID',mHead.GetFieldValueAsString('Firm_ID'));
                                                                                mRowBatch.SetFieldValueAsstring('X_Parent2_ID',mStoreCard_ID);
                                                                                mRowBatch.SetFieldValueAsstring('X_Batches',mBatch_ID);
                                                                                mRowBatch.SetFieldValueAsstring('Name',
                                                                                copy(mRow.GetFieldValueAsString('Storecard_ID.name'),1,40));
                                                                                //mBO_PohybSarze.SetFieldValueAsstring('Code',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.Code'));

                                                                                if mRowBatch.GetFieldValueAsstring('X_Batches.Name')<>'0' then mRowBatch.save;

                                                                         finally
                                                                             mRowBatch.free;
                                                                         end;
                                                               end;
                                                               mBatchList.free;
                                                          end;




                                    end;


                                             end;
                                            end;




end;




function POST_APINxSpotreba(AContext: TNxContext; ABody: string; APath: String): string;
var
  os: TNxCustomObjectSpace;
  mr:tstringlist;
  i,x,y,mIRows,mIBatchs,mri: integer;
  mInputDocumentClsid,mOutputDocumentClsid,mDocqueue_ID:string;
  AInput:TJSONSuperObject;
  mOutputDocument:TNxHeaderBusinessObject;
  mRow,mBatch,mBOReport : TNxCustomBusinessObject;
  mRows,mMonBatches: TNxCustomBusinessMonikerCollection;
  mValidateList:tstringlist;
  mStore_ID,mFirm_ID,mDivision_ID,mOffice_ID,mPerson_ID,mBusOrder_ID,mBusProject_ID,mBustransaction_ID,mReport_ID:string;
  mText:string;
  mi:integer;
  mUser,mUser_ID:string;
  mMsgUser,mMsgUser_ID:string;
  mEmail,mMesager:string;
  mdatamatrix:string;
   mReport: CFxReportManager;
    mList : TStringList;
    mByte :TBytes;
    mFile:string;
    mstring:string;
begin
  os:=AContext.GetObjectSpace;

      mUser_ID:='';
      mMsgUser_ID:='';
      mStore_ID:='';
      mFirm_ID:='';
      mDivision_ID:='';
      mOffice_ID:='';
      mPerson_ID:='';
      mBusOrder_ID:='';
      mBusProject_ID:='';
      mBustransaction_ID:='';
      mReport_ID:='';

      AInput:=TJSONSuperObject.create;

      try
      AInput:= TJSONSuperObject.ParseString(ABody,true);
            //mOutputDocumentClsid:= AInput.S['input_document_clsid'];
            mOutputDocumentClsid:= AInput.S['output_document_clsid'];
            if AInput.S['DocQueue_Code']<>'' then mDocqueue_ID:= os.SQLSelectFirstAsString('Select id from Docqueues where code=' + quotedstr(AInput.S['DocQueue_Code']) + ' AND hidden=' +QuotedStr('N'));
            if AInput.S['Store_Code']<>'' then mStore_ID:= os.SQLSelectFirstAsString('Select id from Stores where code=' + quotedstr(trim(AInput.S['Store_Code'])) + ' AND hidden=' +QuotedStr('N'));

            if AInput.S['Firm_Name']<>'' then mFirm_ID:= os.SQLSelectFirstAsString('Select id from Firms where Name=' + quotedstr(trim(AInput.S['Firm_Name'])) + ' AND hidden=' +QuotedStr('N')+ ' and Firm_ID is null');
            if AInput.S['Firm_Office']<>'' then mOffice_ID:= os.SQLSelectFirstAsString('Select id from FirmOffices where Name=' + quotedstr(trim(AInput.S['Firm_Office'])) + ' AND hidden=' +QuotedStr('N'));

            if AInput.S['Division_Code']<>'' then mDivision_ID:= os.SQLSelectFirstAsString('Select id from Divisions where code=' + quotedstr(trim(AInput.S['Division_Code'])) + ' AND hidden=' +QuotedStr('N'));
            if AInput.S['BusOrder_Code']<>'' then mBusOrder_ID:= os.SQLSelectFirstAsString('Select id from BusOrders where code=' + quotedstr(trim(AInput.S['BusOrder_Code'])) + ' AND hidden=' +QuotedStr('N'));
            if AInput.S['BusProject_Code']<>'' then mBusProject_ID:= os.SQLSelectFirstAsString('Select id from BusProjects where code=' + quotedstr(trim(AInput.S['BusProject_Code'])) + ' AND hidden='+ QuotedStr('N'));
            if AInput.S['BusTransaction_Code']<>'' Then mBustransaction_ID:= os.SQLSelectFirstAsString('Select id from BusTransactions where code=' + quotedstr(trim(AInput.S['BusTransaction_Code'])) + ' AND hidden=' +QuotedStr('N'));

            if AInput.S['User']<>'' then mUser_ID:= os.SQLSelectFirstAsString('Select id from SecurityUsers where LoginName=' + quotedstr(trim(AInput.S['User'])) + ' AND Locked=' +QuotedStr('N'));
            if AInput.S['Msg']<>''  then mMsgUser_ID:= os.SQLSelectFirstAsString('Select id from SecurityUsers where LoginName=' + quotedstr(trim(AInput.S['Msg'])) + ' AND Locked=' +QuotedStr('N'));


            mEmail:= AInput.S['Email'];
            mReport_ID:= AInput.S['ReportID'];
            mdatamatrix:= AInput.S['DatamatrixGroup'];


            mOutputDocument:=TNxHeaderBusinessObject(AContext.GetObjectSpace.CreateObject(mOutputDocumentClsid)) ;
            mOutputDocument.new;
            mOutputDocument.prefill;

            if mDocqueue_ID<>'' then mOutputDocument.SetFieldValueAsString('Docqueue_ID',mDocqueue_ID);
            if mStore_ID<>'' then begin
                    if mFirm_ID='' then begin
                            mtext:= os.SQLSelectFirstAsString('Select X_Firm_ID from Stores where ID=' + quotedstr(mStore_ID)  + ' AND hidden=' +QuotedStr('N'));
                            if mtext<>'' then begin
                                if mFirm_ID='' then mFirm_ID:=mText;
                            end;
                    end;
                    if mOffice_ID='' then begin
                            mtext:= os.SQLSelectFirstAsString('Select id from FirmOffices where X_Store_ID=' + quotedstr(mStore_ID)  + ' AND Parent_ID=' + quotedstr(mFirm_ID) + ' AND hidden=' +QuotedStr('N'));
                            if mtext<>'' then begin
                                mOffice_ID:=copy(mtext,1,10);
                                if mFirm_ID='' then mFirm_ID:=copy(mtext,12,10);
                            end;
                    end;



                  //mOutputDocument.SetFieldValueAsString('Store_ID',mStore_ID);
            end;

            if mFirm_ID<>'' then mOutputDocument.SetFieldValueAsString('Firm_ID',mFirm_ID);
            if mOffice_ID<>'' then mOutputDocument.SetFieldValueAsString('FirmOffice_ID',mOffice_ID);

            if AInput.S['Firm_Person']<>'' then
              mPerson_ID:= os.SQLSelectFirstAsString('Select p.id from Persons P join FirmPersons FP on FP.person_ID=P.id where P.Lastname=' + quotedstr(trim(AInput.S['Firm_Person'])) + ' AND P.hidden=' +QuotedStr('N') + ' and fp.Parent_ID=' + quotedstr(mFirm_ID));


            if mPerson_ID<>'' then mOutputDocument.SetFieldValueAsString('Person_ID',mPerson_ID);

            //if mDivision_ID<>'' mOutputDocument.SetFieldValueAsString('','');
            //if mBusOrder_ID<>'' mOutputDocument.SetFieldValueAsString('','');
            //if mBusProject_ID<>'' mOutputDocument.SetFieldValueAsString('','');
            //if mBustransaction_ID<>'' mOutputDocument.SetFieldValueAsString('','');




            mText:=NXInserRowFromDatamatrix(os,mOutputDocument,false,mDatamatrix,mStore_id,mDivision_ID,mBusOrder_ID,mBusProject_ID,mBusTransaction_ID);



            Result:='{';

        //   if mRowsOutput.Count>0 then begin

                 mOutputDocument.SetFieldValueAsString('CreatedBy_ID',mUser_ID);
                 mOutputDocument.ClearValidateErrors;
                  if Not mOutputDocument.Validate() then begin
                     mValidateList := TStringList.Create;
                      try
                        mOutputDocument.GetValidateErrors(mValidateList);
                        mText := mValidateList.Text;
                        NxToken(mText, '=');

                                            Result:=Result + '"State" :"' + '400'+ '",' + chr(10);

                                            Result:=Result + '"Title" :"' + '### CHYBA - Doklad nebyl vytvořen ###'+ '",' + chr(10);

                                              Result:=Result + '"description: " :"' + mText+ '",' + chr(10) ;
                                        Result:=Result + '}'  ;
                      finally
                        mValidateList.Free;
                      end;


                  end else begin
                      mOutputDocument.Save ;
                          Result:=Result + '"State" :"' + '201'+ '",' + chr(10);

                                            Result:=Result + '"title" :"' + 'Doklad ' + mOutputDocument.DisplayName + ' byl vytvořen '+ '",' + chr(10);
                                            Result:=Result + '"description" :"' + mStore_ID + '",' + chr(10);

                                        Result:=Result + '}'  ;



                           if not NxIsBlank(AInput.S['Msg']) then begin
                                      iSendmsg(AContext.GetObjectSpace, mOutputDocument , mOutputDocumentClsid,
                                                                      mOutputDocument.DisplayName  + '-  byl vytvořen novy doklad ',     // popis
                                                                      ' Byl vytvořen novy doklad s číslem: ' + mOutputDocument.DisplayName ,                          // tělo
                                                                      mMsgUser_ID ,                      // komu
                                                                      mOutputDocument.getFieldValueAsString('CreatedBy_ID')); // kdo
                           end;


                           if not NxIsBlank(AInput.S['Email']) then begin
                                if not NxIsBlank(AInput.S['ReportID']) then mFile:=iPrintDocument(mOutputDocument,AInput.S['ReportID']) else mFile:='';

                                mstring:=iSendMail(AContext.GetObjectSpace, 'Doklad: ' + mOutputDocument.DisplayName , 'Právě Vám byla odeslán doklad s číslem: '
                                +  mOutputDocument.DisplayName , AInput.S['Email'], '','','1100000101', mFile,mDivision_ID,mOutputDocument);
                           end;





                  end ;



  //    end;





                         if (AInput.S['ResultDocPdf']='A') and (trim(AInput.S['ReportID'])<>'') then begin
                                mBOReport:= os.CreateObject(Class_Report);
                                mReport := CFxReportManager.Create;
                                mList := TStringList.Create;
                                try
                                  mBOReport.Load(trim(AInput.S['ReportID']),nil);
                                  mList.Clear;
                                  mList.add(mOutputDocument.oid);
                                  mByte := mReport.PrintByIDsToBytes(NxCreateContext(os) ,mList,mBOReport.GetFieldValueAsString('DataSource'),AInput.S['ReportID'], pekPDF);
                                  Result := '{' + chr(10);
                                  Result:=Result + EncodeBase64( mByte ) + chr(10)  ;
                                  Result:=Result + '}';
                                finally
                                  mBOReport.Free;
                                  mReport.Free;
                                  mList.Free;
                                end;
                        end;




   finally
          AInput.free;
      end;
end;




function POST_APINxArabiaDatamatrix(AContext: TNxContext; Abody: TJSONSuperObject; APath: String): TJSONSuperObject;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
  mr,mx:tstringlist;
  i,ii : integer;
  AOutPut,AInput,ABatch:TJSONSuperObject;
  mJSONArray: TJSONSuperObjectArray;
  mi:integer;
  mBO_Batch:TNxCustomBusinessObject;
  mID,mString:string;
  mStorecard_ID,mBatch_ID:string;
  mPrintList:tstringlist;
  mBytes:TBytes;
  mbo:TNxCustomBusinessObject;
  mOpenRolSite: TOpenRolSite;
  mvalue:tstringlist;
//  mBO: TNxHeaderBusinessObject;
gs01,gs10,gs17:string;
mquantity:double;
begin
      AInput:=TJSONSuperObject.create;
      AInput:= Abody;
      mBatch_ID:='';
      mStorecard_ID:='';
      mstring:='';
      AOutPut:=TJSONSuperObject.create;
              if not nxisblank(AInput.S['DATAMATRIX']) then begin
                 mquantity:=1;

                  //   mstring:= DatamatrixDecodeBatches(AContext.GetObjectSpace,AInput.S['DATAMATRIX']);

                      mvalue:=tstringlist;
                                   try
                                      mvalue:= fnParsevalue(GS_DecodeDatamatrix(AContext.GetObjectSpace,AInput.S['DATAMATRIX']),';');
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
                                   mvalue:= fnParsevalue(ID_from_GS_DecodeDatamatrix(AContext.GetObjectSpace,gs01,gs10,mquantity),';') ;
                                   if mvalue.count>1 then begin
                                        if mvalue.Strings[0]='0000000000' then mBatch_ID:='' else mBatch_ID:=mvalue.Strings[0];
                                        if mvalue.Strings[1]='0000000000' then mStoreCard_ID:='' else mStoreCard_ID:=mvalue.Strings[1];
                                        if NxIBStrToFloat(mvalue.Strings[2])=0 then mquantity:=1 else mquantity:=NxIBStrToFloat(mvalue.Strings[2]);
                                      end;

                                   finally
                                       mvalue.free;
                                   end;



              end else begin
                       mr:=TStringList.create;
                        try
                          AContext.GetObjectSpace.SQLSelect('SELECT sc.id,SB.ID COLLATE Czech_CS_AS from StoreBatches SB left join Storecards SC on sb.Storecard_id=sc.id  Where SC.EAN=' + Quotedstr(AInput.S['EAN']) + ' and SB.Name=' + Quotedstr(AInput.S['BATCH'])
                            ,mr);
                                IF mr.count>0 then begin
                                    mStorecard_ID:=copy(mr.Strings[0],1,10);
                                    mBatch_ID:=copy(mr.Strings[0],12,10);
                                    AOutPut.S['mStorecard_ID'] := copy(mr.Strings[0],1,10);
                                    AOutPut.S['mBatch_ID'] := copy(mr.Strings[0],12,10);
                                   // if AInput.S['print']='A' then begin


                                       //   gOpenRolSite.ParentForm := TComponent(Sender).Site.GetSiteAppForm;
                                          //gOpenRolSite.AfterClose := @TestAfterCloseRolSite;
                                       //   gOpenRolSite.MultiChoice := True;
                                       //   gOpenRolSite.Open;
                                                //mBO := TNxHeaderBusinessObject(TComponent(Sender).Site.BaseObjectSpace.CreateObject(Class_IssuedInvoice));
                                                //try
                                      //              gOpenRolSite.ParentForm := TComponent(Sender).Site.GetSiteAppForm;
                                          //gOpenRolSite.AfterClose := @TestAfterCloseRolSite;
                                      //    gOpenRolSite.MultiChoice := True;
                                      //    gOpenRolSite.;


                                     //           AOutPut.S['mBatch_ID'] := copy(mr.Strings[0],12,10);

                                                {  mBO.load(mBatch_ID,nul);
                                                  mBO.Prefill;
                                                  mBO.SetFieldValueAsString('Description', '*** test OpenDynSite ***');
                                                  gOpenDynSite.NewDoc := mBO;
                                                  gOpenDynSite.AfterClose:= @TestAfterCloseDynSite;
                                                  gOpenDynSite.Open;}

                                     //     finallz

                                     //     end;

                                    //  mbo:=AContext.GetObjectSpace.CreateObject('C32QXZWCTVDL342W01C0CX3FCC');
                                    //    try
                                    //        mbo.load(copy(mr.Strings[0],12,10),nil);
                                    //        mbo.setFieldValueAsString('X_Helpfield', (mbo.getFieldValueAsString('X_Helpfield') + '.'));
                                    //        mbo.save;
                                    //         AOutPut.S['Print'] := 'OK';
                                    //    finally
                                    //        mbo.free;
                                    //    end;
                                    //end;

                                    mPrintList:=TStringList.create;
                                    try
                                        mPrintList.add(copy(mr.Strings[0],12,10)) ;
                                        if AInput.S['print']='A' then begin
                                            CFxReportManager.PrintByIDs(Acontext, mPrintList, 'O1YGCLIJUNDL342X01C0CX3FCC', '~00000000L', rtoPrint, pekHTML,'Citizen','') ;
                                        end;
                                       //TBytes:=CFxReportManager.PrintByIDsToBytes(Acontext, mPrintList, 'O1YGCLIJUNDL342X01C0CX3FCC', '~00000000L',  pekPDF) ;
                                        //AOutPut.S['mFileBase64'] := EncodeBase64( TBytes );
                                    finally
                                        mPrintList.free;
                                    end;




                                  //  AOutPut.S['ExtFile'] := '\\CZVS0006\abrag3\tmp' + 'test.pdf';

                                end;
                         finally
                             mr.free;
                         end;
              end;


              mr:=TStringList.create;
                        try
                     //     AOutPut.S['xxx'] := 'SELECT SB.ID COLLATE Czech_CS_AS from StoreBatches SB left join Storecards SC on sb.Storecard_id=sc.id  Where SC.id=' + Quotedstr(mStorecard_ID);

                          if AInput.S['AllItems']='A' then begin
                              AContext.GetObjectSpace.SQLSelect('SELECT SB.ID COLLATE Czech_CS_AS from StoreBatches SB left join Storecards SC on sb.Storecard_id=sc.id  Where SC.id=' + Quotedstr(mStorecard_ID)
                                  ,mr);
                          end else begin
                              AContext.GetObjectSpace.SQLSelect('SELECT SB.ID COLLATE Czech_CS_AS from StoreBatches SB left join Storecards SC on sb.Storecard_id=sc.id  Where SC.id=' + Quotedstr(mStorecard_ID) + ' and Sb.id=' + Quotedstr(mBatch_ID)
                                  ,mr);
                          end;
                                IF mr.count>0 then begin

                                             mBO_Batch:=AContext.GetObjectSpace.CreateObject('C32QXZWCTVDL342W01C0CX3FCC');
                                             try
                                                 if mr.count>0 then begin
                                                    for ii := 0 to mr.Count - 1 do begin
                                                          mBO_Batch.load(mr.Strings[ii]);
                                                               if ii=0 then begin
                                                                     AOutPut.S['Name'] := mBO_Batch.GetFieldValueAsString('Storecard_ID.Name');
                                                                     AOutPut.S['EAN'] := mBO_Batch.GetFieldValueAsString('Storecard_ID.EAN');
                                                                      AOutPut.S['id'] := mBO_Batch.GetFieldValueAsString('Storecard_ID');
                                                                     AOutPut.O['BATCHES']:=AOutPut.CreateJSONArray;
                                                               end;

                                                              ABatch:=TJSONSuperObject.create;
                                                              ABatch.S['Nazev']:=mBO_Batch.GetFieldValueAsString('StoreCard_ID.X_Name_SA');
                                                              ABatch.S['Batch']:=mBO_Batch.GetFieldValueAsString('Name');
                                                              ABatch.S['EANcode']:=mBO_Batch.GetFieldValueAsString('Storecard_ID.EAN');
                                                              ABatch.S['EANtext']:=mBO_Batch.GetFieldValueAsString('Storecard_ID.EAN');
                                                              ABatch.S['Specifikace']:=mBO_Batch.GetFieldValueAsString('StoreCard_ID.Specification2');
                                                              ABatch.S['Material1']:=mBO_Batch.GetFieldValueAsString('X_MAT1.X_NL_Nazev');
                                                              ABatch.S['Material2']:=mBO_Batch.GetFieldValueAsString('X_MAT2.X_NL_Nazev');
                                                              ABatch.S['Material3']:=mBO_Batch.GetFieldValueAsString('X_MAT3.X_NL_Nazev');
                                                              ABatch.S['Material4']:=mBO_Batch.GetFieldValueAsString('X_MAT4.X_NL_Nazev');
                                                              ABatch.S['Material5']:=mBO_Batch.GetFieldValueAsString('X_MAT5.X_NL_Nazev');
                                                              ABatch.S['CisloMat1']:=mBO_Batch.GetFieldValueAsString('X_MAT1_PROC');
                                                              ABatch.S['CisloMat2']:=mBO_Batch.GetFieldValueAsString('X_MAT2_PROC');
                                                              ABatch.S['CisloMat3']:=mBO_Batch.GetFieldValueAsString('X_MAT3_PROC');
                                                              ABatch.S['CisloMat4']:=mBO_Batch.GetFieldValueAsString('X_MAT4_PROC');
                                                              ABatch.S['CisloMat5']:=mBO_Batch.GetFieldValueAsString('X_MAT5_PROC');
                                                              ABatch.S['MadeIn']:='صنع في جمهورية التشيك';




                                                              AOutPut.A['BATCHES'].Add(ABatch);
                                                    end;
                                                 end;
                                             finally
                                                 mBO_Batch.free;
                                             end;
                            end else begin
                                AOutPut.S['Status'] := 'Nedohledáno';
                            end;
                        finally
                            mr.free;
                        end;
                    result:=AOutPut;

end;





function POST_APINxLogin(AContext: TNxContext; Abody: TJSONSuperObject; APath: String): TJSONSuperObject;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
  mr,mx:tstringlist;
  i,ii : integer;
  AOutPut,AInput:TJSONSuperObject;
  mJSONArray: TJSONSuperObjectArray;
  mi:integer;
  mBO_User:TNxCustomBusinessObject;
  mID,mString:string;
begin
      AInput:=TJSONSuperObject.create;
      AInput:= Abody;

      AOutPut:=TJSONSuperObject.create;
                        mr:=TStringList.create;
                        try
                            AContext.GetObjectSpace.SQLSelect('SELECT SU.ID COLLATE Czech_CS_AS from SecurityUsers SU Where SU.X_AppPasw=' + Quotedstr(AInput.S['Code']) + ' and SU.Name=' +  Quotedstr(AInput.S['Name']) ,mr);
                            if mr.count=1 then begin
                               mBO_User:=AContext.GetObjectSpace.CreateObject('22AHIVDVAVE13C5S00CA141B44');
                               try
                                   mBO_User.load(mr.Strings[0]);
                                       AOutPut.S['Name'] := mBO_User.GetFieldValueAsString('Name');
                                       AOutPut.S['User_ID'] := mBO_User.OID;
                                       AOutPut.S['PLMUser_ID'] := AContext.GetObjectSpace.SQLSelectFirstAsString('SELECT A.ID FROM PLMWorkers A WHERE (A.SecurityUser_ID=' + QuotedStr(mBO_User.OID) + ') AND (A.Hidden = ' + quotedstr('N') + ' ) ');
                                       AOutPut.O['Modules'] := AOutPut.CreateJSONArray;
                                            mx:=TStringList.create;
                                            try
                                                  AContext.GetObjectSpace.SQLSelect('SELECT sr.Name from SecurityUserRoleLinks SURL JOIN SecurityRoles SR on SR.id=SURL.Role_ID and SR.Parent_ID=' + quotedstr('~000000003') + ' Where SURL.User_ID=' + Quotedstr(mr.strings[0]),mx);
                                                  if mx.count>0 then begin
                                                        for ii := 0 to mx.Count - 1 do begin
                                                            mString:=NxSearchReplace(mx.Strings[ii],'"','',[srCase,srAll]);
                                                            AOutPut.A['Modules'].S[ii] := mString;
                                                        end;
                                                  end;
                                            finally
                                                mx.free;
                                            end;
                                      { AOutPut.O['Competenses'] := AOutPut.CreateJSONArray;
                                            mx:=TStringList.create;
                                            try
                                                  AContext.GetObjectSpace.SQLSelect('SELECT sr.Name from SecurityUserRoleLinks SURL JOIN SecurityRoles SR on SR.id=SURL.Role_ID and SR.Parent_ID=' + quotedstr('~000000003') + ' Where SURL.User_ID=' + Quotedstr(mr.strings[0]),mx);
                                                  if mx.count>0 then begin
                                                        AOutPut.S['PriorityModul'] := NxSearchReplace(mx.Strings[0],'"','',[srCase,srAll]);
                                                        for ii := 0 to mx.Count - 1 do begin
                                                             mString:=NxSearchReplace(mx.Strings[ii],'"','',[srCase,srAll]);
                                                                  AOutPut.A['Competenses'].S[ii] := mString
                                                        end;
                                                  end;
                                            finally
                                                mx.free;
                                            end; }

                               finally
                                   mBO_User.free;
                               end;


                            end else begin
                                if mr.count>1 then   AOutPut.S['Status'] := 'Duplicita, nelze přihlásit';
                                if mr.count=0 then   AOutPut.S['Status'] := 'Nedohledáno';
                            end;
                        finally
                            mr.free;
                        end;
                    result:=AOutPut;
end;







function POST_APINxGetJobOrder(AContext: TNxContext; Abody: TJSONSuperObject; APath: String): TJSONSuperObject;
var
  mWinHTTP: Variant;
  AOS: TNxCustomObjectSpace;
  mr,mx:tstringlist;
  i,ii,j : integer;
  mJSON,AInput,mJSONOperations,AMaterial,ACompetences,APictures:TJSONSuperObject;
  mJSONArray: TJSONSuperObjectArray;
  mi:integer;
  mBOJobOrder,mBOPLMReqRoutines:TNxCustomBusinessObject;
  mID,mString,mQuery:string;
  mMon:TNxCustomBusinessMonikerCollection;
begin
      AInput:=TJSONSuperObject.create;
      AInput:= Abody;

      mJSON:=TJSONSuperObject.create;
                               mBOJobOrder:=AContext.GetObjectSpace.CreateObject('HTI3OTLGNRPO32EEISEPC0XZ0K');

                               try

                                               mr:=tstringlist.create;
                                                  try
                                                        if (AnsiPos('-', AInput.S['Input_Document'])>0) and (AnsiPos('/', AInput.S['Input_Document'])>0) then begin
                                                                AContext.GetObjectSpace.SQLSelect('SELECT head.ID FROM PLMJobOrders Head join DocQUEUES DQ on dq.ID=Head.DocQUEUE_ID join Periods P on p.id=Head.Period_ID where ((DQ.code=' + quotedstr(
                                                                                trim(copy(AInput.S['Input_Document'],1,AnsiPos('-', AInput.S['Input_Document'])-1))
                                                                                  ) +' ) and (head.ordnumber=' + quotedstr(
                                                                                trim(copy(AInput.S['Input_Document'],AnsiPos('-', AInput.S['Input_Document'])+1,(AnsiPos('/', AInput.S['Input_Document']))-AnsiPos('-', AInput.S['Input_Document'])-1))
                                                                                  ) + ') and (p.code=' + quotedstr(
                                                                                trim(copy(AInput.S['Input_Document'],AnsiPos('/', AInput.S['Input_Document'])+1,20))
                                                                                  )+'))'

                                                                                  ,mr);
                                                        end else begin
                                                            AContext.GetObjectSpace.SQLSelect('SELECT head.ID FROM PLMJobOrders Head join DocQUEUES DQ on dq.ID=Head.DocQUEUE_ID join Periods P on p.id=Head.Period_ID where (head.id='
                                                            + quotedstr(AInput.S['Input_Document']) + ')',mr);

                                                        end;


                                                  if mr.count=0 then mJSON.S['Document']:= 'nedohledano';
                                                  if mr.count>1 then  mJSON.S['Document']:='dohledano vice';
                                                  if mr.count=1 then begin
                                                              mID:='';
                                                              mID:=mr.Strings[0];
                                                              mBOJobOrder.load(mID,nil);








                                                                       mJSON.S['Document']:=mBOJobOrder.GetFieldValueAsString('DisplayName');
                                                                       mJSON.S['ID']:=mBOJobOrder.oid;

                                                                            mx:=TStringList.create;
                                                                            try
                                                                                  AContext.GetObjectSpace.SQLSelect('SELECT PLMRQ.id FROM PLMJobOrders A join PLMJONodes NT on nt.parent_id=a.id         JOIN PLMJOOutputItems ROI ON ROI.Owner_ID = NT.ID  JOIN PLMJobOrdersRoutines PLMRQ on PLMRQ.Parent_ID = roi.ID '
                                                                                                                    +' WHERE  a.id=' + quotedstr(mID) ,mx);
                                                                                  mboPLMReqRoutines:=AContext.GetObjectSpace.CreateObject('HRKADG42X2H4BJ2RL5KUAUG3PK');
                                                                                        if mx.count>0 then begin
                                                                                              mJSON.O['Operations'] := mJSON.CreateJSONArray;
                                                                                              for ii := 0 to mx.Count - 1 do begin
                                                                                                   mboPLMReqRoutines.load(mx.Strings[ii],nil);
                                                                                                   mJSONOperations:=TJSONSuperObject.Create;
                                                                                                   mJSONOperations.S['Title']:=mboPLMReqRoutines.GetFieldValueAsString('Title');
                                                                                                   mJSONOperations.S['Note']:=mboPLMReqRoutines.GetFieldValueAsString('Note');
                                                                                                   mJSONOperations.S['Pracoviste']:=mboPLMReqRoutines.GetFieldValueAsString('WorkPlace_ID.Name');
                                                                                                   mJSONOperations.D['Norma']:=mboPLMReqRoutines.GetFieldValueAsfloat('TAC');
                                                                                                   mJSONOperations.D['Realizovano']:=mboPLMReqRoutines.GetFieldValueAsfloat('RealizedTime');
                                                                                                   mJSONOperations.D['Zbyva']:=mboPLMReqRoutines.GetFieldValueAsfloat('MissedTime');



                                                                                                        mJSONOperations.O['Materials']:=mJSONOperations.CreateJSONArray;
                                                                                                             mMon := mboPLMReqRoutines.GetLoadedCollectionMonikerForFieldCode(mboPLMReqRoutines.GetFieldCode('Materials'));
                                                                                                              for j:=0 to mMon.count-1 do begin
                                                                                                                  AMaterial:=TJSONSuperObject.create;
                                                                                                                  AMaterial.S['StoreCard_ID']:=mMon.BusinessObject[j].GetFieldValueAsString('Storecard_ID.Name');
                                                                                                                  AMaterial.D['Quantity']:=mMon.BusinessObject[j].GetFieldValueAsFloat('Quantity');
                                                                                                                  AMaterial.D['Vychystano']:=0;
                                                                                                                  AMaterial.D['Skladem']:=0;
                                                                                                                  mJSONOperations.A['Materials'].Add(AMaterial);
                                                                                                              end;
                                                                                                        // mJSONOperations.O['Pictures']:=mJSONOperations.CreateJSONArray;
                                                                                                        //     mMon := mboPLMReqRoutines.GetLoadedCollectionMonikerForFieldCode(mboPLMReqRoutines.GetFieldCode('PLMReqRoutinesPictures'));
                                                                                                        //      for j:=0 to mMon.count-1 do begin
                                                                                                        //          APictures:=TJSONSuperObject.create;
                                                                                                        //          APictures.S['Picture']:=mMon.BusinessObject[j].GetFieldValueAsString('PLMPicture_ID.Picture_ID.BlobData');
                                                                                                        //          mJSONOperations.A['Pictures'].Add(APictures);
                                                                                                        //      end;
                                                                                                          mJSONOperations.O['Competences']:=mJSONOperations.CreateJSONArray;
                                                                                                             mMon := mboPLMReqRoutines.GetLoadedCollectionMonikerForFieldCode(mboPLMReqRoutines.GetFieldCode('Competences'));
                                                                                                              for j:=0 to mMon.count-1 do begin
                                                                                                                  ACompetences:=TJSONSuperObject.create;
                                                                                                                  ACompetences.S['Competence']:=mMon.BusinessObject[j].GetFieldValueAsString('Competence_ID.Name');
                                                                                                                  mJSONOperations.A['Competences'].Add(ACompetences);
                                                                                                              end;


                                                                                                 mJSON.A['Operations'].Add(mJSONOperations);
                                                                                              end;
                                                                                         end;
                                                                            finally
                                                                                mx.free;
                                                                            end;


                                                  end;
                                         finally
                                              mr.free;
                                         end;
                               finally
                                   mBOJobOrder.free;
                               end;

                    result:=mJSON;
end;



function GetHTTP(var WinHttpRequest: Variant): Boolean;
begin
  try
    if not VarIsType(WinHttpRequest, varDispatch) then begin
      WinHttpRequest := CreateOleObject('WinHttp.WinHttpRequest.5.1');
    end;
    Result:=True;
  except
    Result := False;
    OutputDebugString(ExceptionMessage);
    WinHttpRequest := nil;
  end;
end;


      function SendMail_BO(AOS : TNxCustomObjectSpace; const ASubject : string; const ABody : string; ATo : string;mS_CopyEmail:string;mS_BccEmail:string; AFrom : string = '';afilename:string;mDivision_ID:string;mBO_source:TNxCustomBusinessObject):string;
var
  mbo,mRecipient : TNxCustomBusinessObject;
  mAttachmentColl: TNxCustomBusinessMonikerCollection ;
  mSL : TStringList;
  i : integer;
  mAttachments: TNxCustomBusinessMonikerCollection;
begin
  result:='';
  mBO := AOS.CreateObject('5C1HWDQDR3J4NAAYZRO5PWHLWK');
  try
    mBO.New;
    mBO.Prefill;
    if not NxIsBlank(AFrom) then
      mBO.SetFieldValueAsString('EmailAccount_ID',AFrom);
        mBO.SetFieldValueAsString('Firm_ID',mbo_source.GetFieldValueAsString('Firm_ID'));
        mBO.SetFieldValueAsString('FirmOffice_ID',mbo_source.GetFieldValueAsString('FirmOffice_ID'));
        mBO.SetFieldValueAsString('Person_ID',mbo_source.GetFieldValueAsString('Person_ID'));
    mBO.SetFieldValueAsString('Subject', ASubject);
    mBO.SetFieldValueAsInteger('BodySavedAs', 1);
    mBO.SetFieldValueAsString('Body', ABody);

    mBO.SetFieldValueAsInteger('SentState', 1);
    mBO.SetFieldValueAsString('Division_ID', mDivision_ID);
    mSL := TStringList.Create;
    try
      NxTokenToStrings(ATO, ';', mSL);
      for i := 0 to mSL.Count - 1 do begin
        mRecipient := mBO.GetCollectionMonikerForFieldCode(mBO.GetFieldCode('Recipients')).AddNewObject;
        mRecipient.SetFieldValueAsInteger('EmailType', 0);
        mRecipient.SetFieldValueAsString('email', mSL.Strings[i]);
      end;
    finally
      mSL.Free;
    end;

    //mSL := TStringList.Create;
    //try
      //NxTokenToStrings(mS_CopyEmail, ';', mSL);
      //for i := 0 to mSL.Count - 1 do begin
    //    mRecipient := mBO.GetCollectionMonikerForFieldCode(mBO.GetFieldCode('Recipients')).AddNewObject;
    //    mRecipient.SetFieldValueAsInteger('EmailType', 1);
    //    mRecipient.SetFieldValueAsString('email', 'archiv@lipoelastic.com');
        //mRecipient.SetFieldValueAsString('email', mSL.Strings[i]);
      //end;
    //finally
    //  mSL.Free;
    //end;

  // mSL := TStringList.Create;
  //  try
  //    NxTokenToStrings(mS_BccEmail, ';', mSL);
  //    for i := 0 to mSL.Count - 1 do begin
        mRecipient := mBO.GetCollectionMonikerForFieldCode(mBO.GetFieldCode('Recipients')).AddNewObject;
        mRecipient.SetFieldValueAsInteger('EmailType', 2);
        mRecipient.SetFieldValueAsString('email', 'mskacel@lipoelastic.com');
//        mRecipient.SetFieldValueAsString('email', mSL.Strings[i]);
  //    end;
  //  finally
  //    mSL.Free;
  //  end;

    if (afilename <> '') then begin
          mAttachments := mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Attachments'));
          TNxEmailSent(mbo).AttachFile(afilename);

    end;



    mbo.save;
   // NxShowSimpleMessage('Vytvořen email: ' + mbo.oid,nil);
    result:=mbo.oid;
 //   mSite.ShowDynForm('KJAGOM3EAOI45GTB45MXJQTD0S', Nil, Nil, False, 'DoEdit;'+mbo.oid);

       // NxShowSimpleMessage('Saved',nil)
    finally
       mbo.free;
    end;
end;



function APICallString(os: TNxCustomObjectSpace; mTyp: string;mUrl: string;mstring:string;mStatus:Boolean):string;
var
  mWinHTTP: Variant;
begin
  try
         if GetHTTP(mWinHTTP) then begin
              mWinHTTP.Open(mTyp, mUrl );
             // NxShowSimpleMessage(mUrl + ' - ' + mJSON, nil);
              mWinHTTP.SetRequestHeader('Authorization', 'Basic QVBJX1N5bmNocm9uaXphY2U6YzNsdVkyaHliMjVwZW1GalpRPT0=');  //    mWinHTTP.SetRequestHeader('Content-Type', 'application/json; charset=CP1250'); //'); //mWinHTTP.SetRequestHeader('Accept', 'application/json; charset=UTF-8');
              mWinHTTP.Send(mstring);
              if mStatus then begin
                    if copy(FloatToStr(mWinHTTP.Status),1,1)='2' then begin
                         result:= mWinHTTP.ResponseText
                    end else begin
                        result:= mWinHTTP.ResponseText ;
                    end;
              end else begin
              result:= mWinHTTP.ResponseText ;
              end;

        end;
      finally
      end;

end;




begin
end.