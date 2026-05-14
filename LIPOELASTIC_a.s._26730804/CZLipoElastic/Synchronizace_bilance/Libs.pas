uses '_Knihovny_ALL.Parse',
'_Knihovny_ALL.Progress',
'Synchronizace.API';



Function NewOV(msite:TSiteForm;mDocQueue_ID,mFirm_ID:string;msourcerows:tstringlist;mStore_ID,mDivision_ID:string):string;
var
  mi:integer;
  mICount,i:integer;
  mOV:TNxHeaderBusinessObject;
  mRow, mBO_source: TNxCustomBusinessObject;
  mID: string;
  mPocetDokladu,mPocetVyrobku:double;
  mMon:TNxCustomBusinessMonikerCollection;
  mList,mr,mvalue: TStringList;
  mText: string;
  mQuery:string;
  mstring,mdocnumber:string;
  mb:boolean;
  aname,Blat_File:string;
  mxid:string;
  mID_doc:string;
begin
                                      mOV := TNxHeaderBusinessObject(msite.BaseObjectSpace.CreateObject('CDMK5QAWZZDL342X01C0CX3FCC'));

                                                          try
                                                            mOV.New;
                                                            mOV.Prefill;
                                                            mOV.SetFieldValueAsString('DocQueue_ID',mDocQueue_ID);
                                                            mOV.SetFieldValueAsString('Firm_ID', mFirm_ID);
                                                            if mStore_ID='' then begin
                                                                if not NxIsEmptyOID(mov.GetFieldValueAsString('Firm_ID.Store_ID')) then begin
                                                                    mStore_ID:= mov.GetFieldValueAsString('Firm_ID.Store_ID');
                                                                end;
                                                            end;
                                                            mOV.SetFieldValueAsboolean('Confirmed',true);




                                        for i := 0 to msourcerows.Count-1 do begin

                                             mvalue:=tstringlist.create;
                                                try
                                                   Parsevalue(msourcerows.strings[i],';',msourcerows.strings[i],mvalue,5);


                                                          mRow := mOV.Rows.AddNewObject;
                                                          mRow.Prefill;
                                                          mRow.SetFieldValueAsInteger('RowType',3); //Typ radku je 1
                                                          if mstore_ID<>'' then begin
                                                                         mRow.SetFieldValueAsString('Store_ID', mStore_ID);
                                                            end else begin
                                                                        mRow.SetFieldValueAsString('Store_ID', mvalue.strings[3]);
                                                          end;
                                                           mRow.SetFieldValueAsString('StoreCard_ID', mvalue.strings[1]);
                                                          // NxShowSimpleMessage(mvalue.strings[2],nil);

                                                           // ********
                                                           mRow.SetFieldValueAsFloat('Quantity', NxIBStrToFloat(mvalue.strings[2]));
                                                           {
                                                           if mDivision_ID<>'' then begin
                                                                         mRow.SetFieldValueAsString('Division_ID', mDivision_ID);
                                                            end else begin
                                                                mRow.SetFieldValueAsString('Division_ID', mvalue.strings[6]);
                                                            end;
                                                            }
                                                            //mRow.SetFieldValueAsString('BusOrder_ID',(mvalue.strings[5]));
                                                            //mRow.SetFieldValueAsString('BusProject_ID', (mvalue.strings[6]));
                                                            //mRow.SetFieldValueAsString('BusTransaction_ID', (mvalue.strings[7]));


                                                  finally
                                                      mvalue.free;
                                                  end;




                                        end;



                         mOV.ClearValidateErrors;

                         if mOV.getFieldValueAsString('DocQueue_ID')='1640000101' then mOV.SetFieldValueAsboolean('Confirmed',false);
                         if mStore_ID=mStoreCalc_ID then mOV.SetFieldValueAsBoolean('Confirmed',false);
                                                                            if Not mOV.Validate() then begin
                                                                              mList := TStringList.Create;
                                                                              try
                                                                                mOV.GetValidateErrors(mList);
                                                                                mText := mList.Text;
                                                                                NxToken(mText, '=');
                                                                                MessageDlg('Automaticky vytvořeny OV nelze uložit z těchto důvodů:' + #13#10 + mText,
                                                                                  mtWarning, [mbOK], 0);
                                                                              finally
                                                                                mList.Free;
                                                                              end;
                                                                            end else begin
                                                                              mOV.Save;





                                                                              mMon := mOV.GetLoadedCollectionMonikerForFieldCode(mOV.GetFieldCode('ROWS'));
                                                                                    mList := TStringList.Create;
                                                                                    try
                                                                                      for i := 0 to mMon.Count-1 do begin
                                                                                        mRow := mMon.BusinessObject[i];
                                                                                         mtext := mRow.GetFieldValueAsstring('Storecard_ID.Name');
                                                                                        mList.AddObject(mtext, mRow);
                                                                                      end;
                                                                                      mList.Sort;
                                                                                      for i := 0 to mList.Count-1 do begin
                                                                                        mRow := TNxCustomBusinessObject(mList.Objects[i]);
                                                                                        mRow.SetFieldValueAsInteger('posindex',i);
                                                                                        mrow.Save;
                                                                                      end;

                                                                                    finally
                                                                                      mList.Free;
                                                                                    end;
                                                                                  mOV.save;




                                                                                  if mOV.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode')=mTargetCountry then begin

                                                                                        // vytvoření dokladu

                                                                                                     mQuery:=GetDocQuery(mOV,'4722000101','3010000101','','7131000101','5O10000101','RO')  ;
                                                                                               mstring:='';
                                                                                             // mb:=InputQuery('Kontrola API','POST',mTargetDocumentAPI+'ReceivedOrders?select=displayname'+mQuery) ;
                                                                                               mString:= APICallRest(mOV,'POST',mTargetDocumentAPI,'ReceivedOrders','?select=id,displayname',mQuery,true);  // odeslání OV
                                                                                        mdocnumber:=mdocnumber + ', ' + copy(mString,41,15);


                                                                                              if (copy(mString,1,3)='201') then begin
                                                                                                    //NxShowSimpleMessage('doklad ' + copy(mString,14,10),nil);
                                                                                                    //if copy(mString,9,2)='ID' then begin      // záznam namezen
                                                                                                             mID_doc:= copy(mString,14,10);


                                                                                                             if mBsentemail then begin
                                                                                                                        mPrintList := TStringList.Create;
                                                                                                                        try
                                                                                                                           mPrintList.Add(mbo_source.OID);
                                                                                                                           AName := mbo_source.GetFieldValueAsString('Docqueue_ID.CODE') +'-' + inttostr(mbo_source.GetFieldValueAsInteger('Ordnumber'))  +'-' + mbo_source.GetFieldValueAsString('Period_id.CODE')+'.pdf' ;
                                                                                                                           try
                                                                                                                              CFxReportManager.PrintByIDs(NxCreateContext(mbo_source.ObjectSpace),mPrintList,'W0NZQGROZZDL342X01C0CX3FCC', '2NI0000101', rtofile, pekPDF,NxGetTempDir,aname);
                                                                                                                              Blat_File:=NxGetTempDir+'\'+aname;
                                                                                                                              try

                                                                                                                                      Blat_File:=NxGetTempDir+aname;
                                                                                                                                      mxid:='';
                                                                    // test                                                                   mxid:=iSendMailx(self.ObjectSpace, 'Objednávka: ' + self.DisplayName , 'Právě Vám byla odeslána objednávka ze společnosti LIPOELASTIC a.s. s číslem: ' +  self.DisplayName, 'kondrickova@lipoelastic.sk;zorlikova@lipoelastic.sk', '','','3130000101', Blat_File,'1N00000101',self);
                                                                                                                                      mxid:=iSendMailx(mbo_source.ObjectSpace, 'Objednávka: ' + mbo_source.DisplayName , 'Právě Vám byla odeslána objednávka ze společnosti LIPOELASTIC a.s. s číslem: ' +  mbo_source.DisplayName, 'kondrickova@lipoelastic.sk;zorlikova@lipoelastic.sk;mskacel@lipoelastic.com', '','','3130000101', Blat_File,'1N00000101',mbo_source);

                                                                                                                              except
                                                                                                                              end;
                                                                                                                            except
                                                                                                                            end;
                                                                                                                        finally
                                                                                                                            mPrintList.free;
                                                                                                                        end;
                                                                                                                end;




















                                                                                                           //  NxShowSimpleMessage('Doklad ' + mdocnumber + ' byl synchronizován',nil);
                                                                                                    //end;
                                                                                              end else begin
                                                                                                        NxShowSimpleMessage('Chyba v přístupu k api' + mString,nil);
                                                                                                        //exit;
                                                                                              end;
                                                                                  end;









                                                                            end;




                        result:=mov.DisplayName;

                       finally
                          mov.free;
                       end;
end;


Function NewPOZ(msite:TSiteForm;mDocQueue_ID,mFirm_ID:string;msourcerows:tstringlist;mStore_ID,mDivision_ID:string):boolean;
var
  mi:integer;
  mICount,i:integer;
  mRow,mPOZ, mBO_source: TNxCustomBusinessObject;
  mID: string;
  mPocetDokladu,mPocetVyrobku:double;
  mMon:TNxCustomBusinessMonikerCollection;
  mList,mr,mvalue: TStringList;
  mText: string;
begin

                                        for i := 0 to msourcerows.Count-1 do begin

                                             mvalue:=tstringlist.create;
                                                try
                                                   Parsevalue(msourcerows.strings[i],';',msourcerows.strings[i],mvalue,5);
                                                   mpoz := TSiteForm(msite).BaseObjectSpace.CreateObject('IVJSI1K34CJORFG1QBJOMTSVAG');
                                                          try
                                                            mPOZ.New;
                                                            mPOZ.Prefill;
                                                            mPOZ.SetFieldValueAsString('DocQueue_ID',mDocQueue_ID);
                                                            mPOZ.SetFieldValueAsString('Firm_ID', mFirm_ID);

                                                            if mstore_ID<>'' then begin
                                                                         mPOZ.SetFieldValueAsString('Division_ID', mDivision_ID);
                                                            end else begin
                                                                mPOZ.SetFieldValueAsString('Division_ID', mvalue.strings[3]);
                                                            end;

                                                            if mstore_ID<>'' then begin
                                                                         mPOZ.SetFieldValueAsString('Store_ID', mStore_ID);
                                                            end else begin
                                                                mPOZ.SetFieldValueAsString('Store_ID', mvalue.strings[6]);
                                                            end;
                                                            //NxShowSimpleMessage(mvalue.strings[2],nil);
                                                            mPOZ.SetFieldValueAsString('StoreCard_ID', mvalue.strings[1]);
                                                            mPOZ.SetFieldValueAsFloat('Quantity', NxIBStrToFloat(mvalue.strings[2]));
                                                            mPOZ.SetFieldValueAsFloat('CorrectedQuantity', NxIBStrToFloat(mvalue.strings[2]));
                                                            //mPOZ.SetFieldValueAsString('BusOrder_ID',(mvalue.strings[5]));
                                                            //mPOZ.SetFieldValueAsString('BusProject_ID', (mvalue.strings[6]));
                                                            //mPOZ.SetFieldValueAsString('BusTransaction_ID', (mvalue.strings[7]));


                                                            if mPOZ.GetFieldValueAsBoolean('StoreCard_ID.isproduct')then begin
                                                                      mPOZ.ClearValidateErrors;

                                                                                      if Not mPOZ.Validate() then begin
                                                                                        mList := TStringList.Create;
                                                                                        try
                                                                                          mPOZ.GetValidateErrors(mList);
                                                                                          mText := mList.Text;
                                                                                          NxToken(mText, '=');
                                                                                          MessageDlg('Automaticky vytvořeny POZ nelze uložit z těchto důvodů:' + #13#10 + mText,
                                                                                            mtWarning, [mbOK], 0);
                                                                                        finally
                                                                                          mList.Free;
                                                                                        end;
                                                                                      end else begin
                                                                                        mPOZ.Save;

                                                                                      end;
                                                             end else begin
                                                                      NxShowSimpleMessage('Skladová karta ' + mPOZ.GetFieldValueAsString('StoreCard_ID.name') + ' není výrobkem ',nil)
                                                             end;
                                                          finally
                                                                mPOZ.Free;
                                                          end;
                                                  finally
                                                      mvalue.free;
                                                  end;




                                        end;


end;


begin
end.