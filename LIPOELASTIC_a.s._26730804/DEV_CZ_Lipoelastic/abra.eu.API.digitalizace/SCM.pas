procedure Davkove_Batch(ARow: TNxCustomBusinessObject);
var
mBONew,mBOSource:TNxCustomBusinessObject;
mPOmocPocet:double;
begin
     //NxShowSimpleMessage('AAA ' + ARow.GetFieldValueAsstring('Storecard_ID'),nil);
      // *** // rozdělení dávkově
              NxShowSimpleMessage(inttostr(ARow.GetFieldValueAsInteger('Storecard_ID.X_davka_sici')),nil);

      if arow.GetFieldValueAsFloat('Quantity')>ARow.GetFieldValueAsInteger('Storecard_ID.X_davka_sici')  then begin
                  mPOmocPocet:= arow.GetFieldValueAsFloat('Quantity');

                  mBOSource:=ARow.ObjectSpace.CreateObject('IVJSI1K34CJORFG1QBJOMTSVAG');
                 // mBOSource.load(arow.GetFieldValueAsString('Parent_ID'),nil);
                  mBONew:=ARow.ObjectSpace.CreateObject('IVJSI1K34CJORFG1QBJOMTSVAG');


                  try
                      while mPOmocPocet>0 do begin


                          if mPOmocPocet > ARow.GetFieldValueAsInteger('Storecard_ID.X_davka_sici') then begin
                                     arow.SetFieldValueAsFloat('Quantity',ARow.GetFieldValueAsinteger('Storecard_ID.X_davka_sici')) ;
                                     mBONew:=mBOSource.Clone;
                                            NxShowSimpleMessage('Založení nového ' + mBOSource.oid,nil);

                                     mBONew.save;
                                     NxShowSimpleMessage('Uložení nového ' + mBOSource.oid,nil);



                                     mPOmocPocet:=(arow.GetFieldValueAsFloat('Quantity')- ARow.GetFieldValueAsinteger('Storecard_ID.X_davka_sici'));
                          end else begin
                              arow.SetFieldValueAsFloat('Quantity',mPOmocPocet);
                              mPOmocPocet:=(arow.GetFieldValueAsFloat('Quantity')- ARow.GetFieldValueAsinteger('Storecard_ID.X_davka_sici'));
                              NxShowSimpleMessage('upravení aktuálního ' + mBOSource.oid,nil);

                          end;
                      end;
                  finally
                      mBONew.free;
                  end;
      end;

end;


begin
end.