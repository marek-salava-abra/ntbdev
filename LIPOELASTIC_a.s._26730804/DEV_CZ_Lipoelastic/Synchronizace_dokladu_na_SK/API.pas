uses 'Synchronizace.API';












function xAPI_GetOrCreateOVDocRowBatch(mSite:TSiteForm;mApiTArget:string;mDoc_ID:string;mRowBO:TNxCustomBusinessObject;mBatch_ID:String;mquantity:double;index:integer):string;
var
mQueryID:string;
mNewQueryID :string;
mString :string;
mDisplayName:string;
mFirm_ID:string;
mRow_ID:string;
mDocRowBatch_ID:string;
mCLSIDDoc:string;
mCLSIDDocRow:string;
mCLSIDRowBatch:string;
begin
result:='';
mCLSIDDoc:='';
mCLSIDDocRow:='';
mCLSIDRowBatch:='';
mCLSIDDoc:='4K3EXM5PQBCL35CH000ILPWJF4';
mCLSIDDocRow:='CHMK5QAWZZDL342X01C0CX3FCC';
mCLSIDRowBatch:='EC2R2HSFK5UOZ5MYVJWJOHUC4S' ;

         if mBatch_ID<>'' then begin
                  mfirm_ID:='';
 //                 mQueryID:='{ "class": "' + mCLSIDDoc +'", "select": ["Firm_ID",], "where": " ID = ' + QuotedStr(mDoc_ID) +'" }';
 //                  mString:=APICallRest(mRowBO,'Post',mApiTArget,'query','',mQueryID,True);
 //                  //NxShowSimpleMessage('řádek cílového dokladu' + mstring,nil);
 //                  if (copy(mString,1,3)='200')  then begin      // korektní odpověď
 //                         if copy(mString,10,2)='ID' then begin      // záznam namezen
 //                                  mFirm_ID:= copy(mString,15,10);
 //                         end;
 //                  end;

                   mDisplayName:=APICallRest(mRowBO,'GET',mApiTArget,'issuedorders/' + mDoc_ID + '?select=displayname','','',True);
//                   mDisplayName:=APICallRest(mRowBO,'GET',mTargetAPI + '/','Receivedorders/SSY8J00101/?select=displayname','','',True);
//NxShowSimpleMessage(mDisplayName,nil);
                   mDisplayName:=copy(mDisplayName,19,20);
//NxShowSimpleMessage(mDisplayName,nil);


                  // řádek v cílovém dokladu
                  mQueryID:='{ "class": "' + mCLSIDDocRow +'", "select": ["ID",], "where": " X_ProvideRow_ID = ' + QuotedStr(mRowBO.GetFieldValueAsString('X_ProvideRow_ID')) +' and Storecard_ID=' +  QuotedStr(mRowBO.GetFieldValueAsString('Storecard_ID')) +' and Parent_ID=' +  QuotedStr(mDoc_ID)+'" }';
                   mString:=APICallRest(mRowBO,'Post',mApiTArget,'query','',mQueryID,True);
                   //NxShowSimpleMessage('řádek cílového dokladu' + mstring,nil);
                   if (copy(mString,1,3)='200')  then begin      // korektní odpověď
                          if copy(mString,10,2)='ID' then begin      // záznam namezen
                                   mRow_ID:= copy(mString,15,10);
                                         //NxShowSimpleMessage('ID řádek cílového dokladu' + mRow_ID,nil);
                                         //NxShowSimpleMessage('existující pohyb šarže v cíli'  +  mid,nil);
                                         mQueryID:='{ "class": "' + 'mCLSIDRowBatch' +'", "select": ["ID",], "where": " X_Parent_ID = ' + QuotedStr(mRow_ID) +' and X_batches=' +  QuotedStr(mBatch_ID)+' and Code=' +  QuotedStr(mDoc_ID) + '" }';
                                         mString:=APICallRest(mRowBO,'Post',mApiTArget,'query','',mQueryID,True);
                                         //NxShowSimpleMessage('řádek pohybu šarže' + mstring,nil);
                                                      if (copy(mString,1,3)='200')  then begin      // korektní odpověď
                                                            if copy(mString,10,2)='ID' then begin      // záznam namezen
                                                                  mDocRowBatch_ID:= copy(mString,15,10);
                                                                  result:=mDocRowBatch_ID;
                                                            end else begin
                                                                  mNewQueryID:='{'
                                                                               +'               "Code": "' + mDoc_ID + '", '
                                                                               +'               "X_Parent_ID": "' + mRow_ID + '", '
//                                                                               +'               "X_Firm_ID": "' + mfirm_id + '", '
                                                                               +'               "X_Parent2_ID": "' + mRowBO.GetFieldValueAsString('Storecard_ID') + '", '
                                                                               +'               "X_Storecard_ID": "' + mRowBO.GetFieldValueAsString('Storecard_ID') + '", '
                                                                               +'               "X_Batches": "' + mBatch_ID + '", '
//                                                                               +'               "Name": "' + copy(mDisplayName +' - ' + mRowBO.GetFieldValueAsString('Storecard_ID.Name'),1,40) + '", '
                                                                               +'               "X_quantity": "' + NxFloatToIBStr(mquantity) + '", '
                                                                               +'}';


                                                                                   mString:= APICallRest(mRowBO,'post',mApiTArget,'PohybOV','' ,mNewQueryID,True);
                                                                                 //NxShowSimpleMessage('vytoření pohybu šarže' + mstring,nil);
                                                                                 if (copy(mString,1,3)='201') then begin   // stav založení
                                                                                              mQueryID:='{ "class": "' + mCLSIDRowBatch +'", "select": ["ID",], "where": " X_Parent_ID = ' + QuotedStr(mRow_ID) +' and X_batches=' +  QuotedStr(mBatch_ID) + '" }';

                                                                                              mString:= copy(APICallRest(mRowBO,'Post',mApiTArget,'query','',mQueryID,false),9,10);
                                                                                              if copy(mString,10,2)='ID' then result:= copy(mString,15,10);
                                                                                  end else begin
                                                                                        NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                                                                                        result:='';
                                                                                        exit;
                                                                                  end;
                                                            end;
                                                      end else begin
                                                          NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                                                          result:='';
                                                          exit;
                                                      end;
                          end;
                   end else begin
                        NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                        result:='';
                        exit;
                   end;
         end;


end;


function xAPI_GetOrCreateOPDocRowBatch(mSite:TSiteForm;mApiTArget:string;mDoc_ID:string;mRowBO:TNxCustomBusinessObject;mBatch_ID:String;mquantity:double;index:integer):string;
var
mQueryID:string;
mNewQueryID :string;
mString :string;
mDisplayName:string;
mFirm_ID:string;
mRow_ID:string;
mDocRowBatch_ID:string;
mCLSIDDoc:string;
mCLSIDDocRow:string;
mCLSIDRowBatch:string;
begin
result:='';
mCLSIDDoc:='';
mCLSIDDocRow:='';
mCLSIDRowBatch:='';
mCLSIDDoc:='01CPMINJW3DL342X01C0CX3FCC';
mCLSIDDocRow:='05CPMINJW3DL342X01C0CX3FCC';
mCLSIDRowBatch:='SLARSB0H4CK4T32XPZTP33J3XS' ;



         if mBatch_ID<>'' then begin
  //                mfirm_ID:='';
  //                mQueryID:='{ "class": "' + mCLSIDDoc +'", "select": ["Firm_ID",], "where": " ID = ' + QuotedStr(mDoc_ID) +'" }';
  //                 mString:=APICallRest(mRowBO,'Post',mApiTArget,'query','',mQueryID,True);
  //                 //NxShowSimpleMessage('řádek cílového dokladu' + mstring,nil);
  //                 if (copy(mString,1,3)='200')  then begin      // korektní odpověď
  //                        if copy(mString,10,2)='ID' then begin      // záznam namezen
  //                                 mFirm_ID:= copy(mString,15,10);
  //                        end;
  //                 end;

//try
//                   mDisplayName:=APICallRest(mRowBO,'GET',mApiTArget,'ReceivedOrders/' + mDoc_ID+ '?select=displayname','','',True);
//                   mDisplayName:=APICallRest(mRowBO,'GET',mTargetAPI + '/','Receivedorders/SSY8J00101/?select=displayname','','',True);
//=DocQueue_ID.Code || '-' || OrdNumber || '/' || Period_ID.Code+as+DisplayName

//                   mDisplayName:=copy(mDisplayName,23,20);
//                   mDisplayName:=copy(mDisplayName,23, AnsiPos('"', mDisplayName));




//NxShowSimpleMessage(mDisplayName,nil);
//NxShowSimpleMessage(mDisplayName,nil);
//finally

//end;

                  // řádek v cílovém dokladu
                  mQueryID:='{ "class": "' + mCLSIDDocRow +'", "select": ["ID",], "where": " posindex=' + inttostr(mRowBO.GetFieldValueAsinteger('Posindex')) +' and Storecard_ID=' +  QuotedStr(mRowBO.GetFieldValueAsString('Storecard_ID')) +' and Parent_ID=' +  QuotedStr(mDoc_ID)+'" }';
                 // mstring:= inputbox('OP - řádek v cílovém dokladu','POST',mApiTArget+'query'+'' + '       ' + mQueryID)    ;
                   mString:=APICallRest(mRowBO,'Post',mApiTArget,'query','',mQueryID,True);


                  // NxShowSimpleMessage('řádek cílového dokladu' + mstring,nil);
                  // if (copy(mString,1,3)='200')  then begin      // korektní odpověď
                  if true then begin
                          //if copy(mString,10,2)='ID' then begin      // záznam namezen
                          if true then begin
                                   mRow_ID:= copy(mString,15,10);
                                         //NxShowSimpleMessage('ID řádek cílového dokladu' + mRow_ID,nil);
                                    //     NxShowSimpleMessage('existující pohyb na řádku OP v cíli - '  +  mRow_ID,nil);
                                         mQueryID:='{ "class": "' + mCLSIDRowBatch +'", "select": ["ID",], "where": " X_Parent_ID = ' + QuotedStr(mRow_ID) +' and X_batches=' +  QuotedStr(mBatch_ID)+' and Code=' +  QuotedStr(mDoc_ID) + '" }';

                                        // mstring:= inputbox('Pohyb šarže OP existující -','POST',mApiTArget+'query'+'' + '       ' + mQueryID)    ;
                                         mString:=APICallRest(mRowBO,'Post',mApiTArget,'query','',mQueryID,True);
                                         //NxShowSimpleMessage('řádek pohybu šarže' + mstring,nil);
                                                      if (copy(mString,1,3)='200')  then begin      // korektní odpověď
                                                            if copy(mString,10,2)='ID' then begin      // záznam namezen
                                                                  mDocRowBatch_ID:= copy(mString,15,10);
                                                                  result:=mDocRowBatch_ID;
                                                                 // NxShowSimpleMessage('Pohyb dohledán',nil);
                                                            end else begin
                                                                  mNewQueryID:='{'
                                                                               +'               "Code": "' + mDoc_ID + '", '
                                                                               +'               "X_Parent_ID": "' + mRow_ID + '", '
                                                                               +'               "X_Firm_ID": "' + mfirm_id + '", '
                                                                               +'               "X_Parent2_ID": "' + mRowBO.GetFieldValueAsString('Storecard_ID') + '", '
                                                                               +'               "X_Storecard_ID": "' + mRowBO.GetFieldValueAsString('Storecard_ID') + '", '
                                                                               +'               "X_Batches": "' + mBatch_ID + '", '
                                                                               +'               "Name": "' + copy(mDisplayName +' - ' + mRowBO.GetFieldValueAsString('Storecard_ID.Name'),1,40) + '", '
                                                                               +'               "X_quantity": "' + NxFloatToIBStr(mquantity) + '", '
                                                                               +'}';


                                                                                 //   mstring:= inputbox('Založení pohybu šarže -','POST',mApiTArget+'Pohyby_sarzi_OP'+'' + '       ' + mNewQueryID)    ;
                                                                                   mString:= APICallRest(mRowBO,'post',mApiTArget,'Pohyby_sarzi_OP','' ,mNewQueryID,True);


                                                                                 //NxShowSimpleMessage('vytoření pohybu šarže' + mstring,nil);
                                                                                 if (copy(mString,1,3)='201') then begin   // stav založení
                                                                                              mQueryID:='{ "class": "' + mCLSIDRowBatch +'", "select": ["ID",], "where": " X_Parent_ID = ' + QuotedStr(mRow_ID) +' and X_batches=' +  QuotedStr(mBatch_ID) + '" }';
                                                                                            //  NxShowSimpleMessage('pohyb založen',nil);

                                                                                              mString:= copy(APICallRest(mRowBO,'Post',mApiTArget,'query','',mQueryID,false),9,10);
                                                                                              //if copy(mString,10,2)='ID' then
                                                                                              result:= copy(mString,15,10);
                                                                                           //   NxShowSimpleMessage('pohyb oběřen',nil);
                                                                                  end else begin
                                                                                        NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                                                                                        result:='';
                                                                                        exit;
                                                                                  end;
                                                            end;
                                                      end else begin
                                                          NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                                                          result:='';
                                                          exit;
                                                      end;
                          end;
                   end else begin
                        NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                        result:='';
                        exit;
                   end;
         end;


end;










 // post dotaz API pmocí JSON



 // post dotaz API pmocí JSON









// post dotaz API pmocí JSON


function xAPI_GetOrCreateBatch(mSite:TSiteForm;mApiTArget:string;mBatch_ID:String):string;
var
mQueryID:string;
mNewQueryID :string;
mString :string;
mBatchBO:TNxCustomBusinessObject;

begin
result:='';
mBatchBO:=mSite.BaseObjectSpace.CreateObject('C32QXZWCTVDL342W01C0CX3FCC')   ;
      try
         if mBatch_ID<>'' then begin
             mBatchBo.load(mBatch_ID,nil);
                  mQueryID:='{ "class": "' + 'StoreBatches' +'", "select": ["ID",], "where": " Name = ' + QuotedStr(mBatchBo.GetFieldValueAsString('name')) +' and Storecard_ID=' +  QuotedStr(mBatchBo.GetFieldValueAsString('Storecard_ID')) + '" }';
                   mString:=APICallRest(mBatchBO,'Post',mApiTArget,'query','',mQueryID,True);
                   //NxShowSimpleMessage('AAA .' +copy(mString,10,2) +'.'+  copy(mString,15,10),nil);
                   if (copy(mString,1,3)='200')  then begin      // korektní odpověď
                          if copy(mString,10,2)='ID' then begin      // záznam namezen
                                   result:= copy(mString,15,10);


                           end else begin
            //                      NxShowSimpleMessage('Šarže v cíli nenalezena - zakládám' ,nil);
                                  // ********    založení šarže
                                       mNewQueryID:='{'
                                            +' "serialnumber": false, '
                                            +'               "storecard_id": "' + mBatchBo.GetFieldValueAsString('storecard_id') + '", '
                                            +'               "name": "' + mBatchBo.GetFieldValueAsString('name') + '", '
                                            +'               "specification": "' + mBatchBo.GetFieldValueAsString('specification') + '", '
                                            +'               "x_verze": "' + mBatchBo.GetFieldValueAsString('x_verze') + '", '
                                            +'               "ExpirationDate$DATE":"' +FormatDateTime('YYYY-MM-DD',mBatchBo.GetFieldValueAsDateTime('ExpirationDate$DATE')) +'", '
                                            +'               "productiondate$date":"' +FormatDateTime('YYYY-MM-DD',mBatchBo.GetFieldValueAsDateTime('productiondate$date')) +'", '

                                            +'               "X_parent_ID": "' + mBatchBo.GetFieldValueAsString('X_parent_ID') + '", '
                                            +'               "X_Specifikace_order": "' + mBatchBo.GetFieldValueAsString('X_Specifikace_order') + '", '
                                            +'               "X_MAT1": "' + mBatchBo.GetFieldValueAsString('X_MAT1') + '", '
                                            +'               "X_MAT2": "' + mBatchBo.GetFieldValueAsString('X_MAT2') + '", '
                                            +'               "X_MAT3": "' + mBatchBo.GetFieldValueAsString('X_MAT3') + '", '
                                            +'               "X_MAT4": "' + mBatchBo.GetFieldValueAsString('X_MAT4') + '", '
                                            +'               "X_MAT5": "' + mBatchBo.GetFieldValueAsString('X_MAT5') + '", '
                                            +'               "X_MAT1_PROC": "' + inttostr(mBatchBo.GetFieldValueAsInteger('X_MAT1_PROC')) + '", '
                                            +'               "X_MAT2_PROC": "' + inttostr(mBatchBo.GetFieldValueAsInteger('X_MAT2_PROC')) + '", '
                                            +'               "X_MAT3_PROC": "' + inttostr(mBatchBo.GetFieldValueAsInteger('X_MAT3_PROC')) + '", '
                                            +'               "X_MAT4_PROC": "' + inttostr(mBatchBo.GetFieldValueAsInteger('X_MAT4_PROC')) + '", '
                                            +'               "X_MAT5_PROC": "' + inttostr(mBatchBo.GetFieldValueAsInteger('X_MAT5_PROC')) + '", '
                                             +'}';

                                        // *** kontrola json
                                        //mstring:=                      inputbox('Šarže','POST' + '   ' +, mApiTArget+'StoreBatches'+ '        ' + mNewQueryID)    ;
                                        mString:= APICallRest(mBatchBO,'post',mApiTArget,'StoreBatches','' ,mNewQueryID,True);
                                        //NxShowSimpleMessage('Kontrola stavu založení šarže' + copy(mstring,1,3) , nil);
                                        if (copy(mString,1,3)='201') or (copy(mString,1,3)='200') then begin   // stav založení
                                                    mQueryID:='{ "class": "' + 'StoreBatches' +'", "select": ["ID",], "where": " Name = ' + QuotedStr(mBatchBo.GetFieldValueAsString('name')) +' and Storecard_ID=' +  QuotedStr(mBatchBo.GetFieldValueAsString('Storecard_ID')) + '" }';
                                                           mString:=APICallRest(mBatchBO,'Post',mApiTArget,'query','',mQueryID,True);
                                                           if (copy(mString,1,3)='200')  then begin      // korektní odpověď
                                                                  if copy(mString,10,2)='ID' then begin      // záznam namezen
                                                                           result:= copy(mString,15,10);
                                                                  end;
                                                           end;
                                        end else begin
                                                          NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                                                          result:='';
                                                          exit;
                                        end;
                            end;
                   end else begin
                        NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                        result:='';
                        exit;
                   end;
         end;
      finally
         mBatchBO.free;
      end;
       // NxShowSimpleMessage('Šarže v cíli '  +  result,nil);
end;

begin
end.