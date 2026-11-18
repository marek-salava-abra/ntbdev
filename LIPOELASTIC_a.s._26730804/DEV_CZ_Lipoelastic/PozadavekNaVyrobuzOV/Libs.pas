uses '_Knihovny_ALL.Parse';

Function NewOV(msite:TSiteForm;mDocQueue_ID,mFirm_ID:string;msourcerows:tstringlist;mStore_ID,mDivision_ID:string):boolean;
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
begin
                                      mOV := TNxHeaderBusinessObject(msite.BaseObjectSpace.CreateObject('CDMK5QAWZZDL342X01C0CX3FCC'));

                                                          try
                                                            mOV.New;
                                                            mOV.Prefill;
                                                            mOV.SetFieldValueAsString('DocQueue_ID',mDocQueue_ID);
                                                            mOV.SetFieldValueAsString('Firm_ID', mFirm_ID);




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
                                                                mOV.SetFieldValueAsString('Store_ID', mvalue.strings[3]);
                                                          end;
                                                           mRow.SetFieldValueAsString('StoreCard_ID', mvalue.strings[1]);
                                                           mRow.SetFieldValueAsFloat('Quantity', NxIBStrToFloat(mvalue.strings[2]));

                                                           if mDivision_ID<>'' then begin
                                                                         mRow.SetFieldValueAsString('Division_ID', mDivision_ID);
                                                            end else begin
                                                                mRow.SetFieldValueAsString('Division_ID', mvalue.strings[6]);
                                                            end;
                                                            //mRow.SetFieldValueAsString('BusOrder_ID',(mvalue.strings[5]));
                                                            //mRow.SetFieldValueAsString('BusProject_ID', (mvalue.strings[6]));
                                                            //mRow.SetFieldValueAsString('BusTransaction_ID', (mvalue.strings[7]));
                                                            mOV.ClearValidateErrors;

                                                                            if Not mOV.Validate() then begin
                                                                              mList := TStringList.Create;
                                                                              try
                                                                                mOV.GetValidateErrors(mList);
                                                                                mText := mList.Text;
                                                                                NxToken(mText, '=');
                                                                                MessageDlg('Automaticky vytvořeny POZ nelze uložit z těchto důvodů:' + #13#10 + mText,
                                                                                  mtWarning, [mbOK], 0);
                                                                              finally
                                                                                mList.Free;
                                                                              end;
                                                                            end else begin
                                                                              mOV.Save;

                                                                            end;

                                                  finally
                                                      mvalue.free;
                                                  end;




                                        end;

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