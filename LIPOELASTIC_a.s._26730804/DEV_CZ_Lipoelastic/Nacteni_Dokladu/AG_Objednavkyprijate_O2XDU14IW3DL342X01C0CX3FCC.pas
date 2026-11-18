uses '_Knihovny_ALL.head', '_Knihovny_ALL.Progress','_Knihovny_ALL.Parse',
'abra.eu.mask_import.2018.Objednavka_prijata' ,'Nacteni_Dokladu.lib'
;

const
    mFilter='*.csv';

function FnParsePotvrzeniBTC(OS:TNxCustomObjectSpace;msite:TSiteForm;mHead:TNxHeaderBusinessObject):TNxHeaderBusinessObject;
var
mImportFile:tstringlist;
i:integer;
mstringline:string;
mvalue,mvalue2:TStringList;
mBproduct:boolean;
mSGroup:boolean;
mString:string;
mEU:string;
mIProdukt:integer;
mstorecard_ID:string;
mBusProject_ID,mBustransaction_ID,mBusOrder_ID,mstore_id:string;
mIRadku:integer;
mIKusu:Double;
mIcena:Double;
mpomocprice:double;
mRow:TNxCustomBusinessObject;
  mOLE, mRoll,mAgenda, mOResult: Variant;
begin
  mIKusu:=0;
  mIcena:=0;
  mImportFile:=TStringList.create;
                              mImportFile:=fnParsevalue(BarCode_document(mSite,'05CPMINJW3DL342X01C0CX3FCC',0,0,720,960, 'Obsah potvrzení','Položky : ','','Pokračovat','',''), chr(10));
                              ProgressInit(msite, 'Načítání dat ' + '', 100);

                              for i:=0 to mImportFile.Count-1 do begin   // načtení souboru
                                        mvalue:=tstringlist.create;
                                        mvalue2:=tstringlist.create;
                                        ProgressSetPos(1+NxFloor((i/mImportFile.Count)*99), inttostr(i) +' z '+inttostr(mImportFile.Count));
                                        mstringline:=  NxSearchReplace(mImportFile.strings[i],chr(39),'',[srCase,srAll]);

                                        if trim(mstringline)<>'' then begin
                                           try
                                            mvalue:=fnParsevalue(mstringline, chr(09));
                                                 if not mBproduct then begin
                                                       if true then begin

                                                                  if copy(trim(mstringline),1,14)='Objednávka č.:' then
                                                                          begin
                                                                               //NxShowSimpleMessage(mvalue.Strings[1],nil);
                                                                               mHead.SetFieldValueAsString('ExternalNumber',copy(trim(mstringline),15,50));
                                                                               mHead.SetFieldValueAsInteger('X_VarSymbol', strtoint(copy(trim(mstringline),15,50)));
                                                                          end;
                                                                   if copy(trim(mstringline),1,10)='Objednáno:' then
                                                                          begin
                                                                               mHead.SetFieldValueAsDateTime('Docdate$date', StrToDate(
                                                                               copy(mImportFile.strings[i],12,2) + '.' +
                                                                               copy(mImportFile.strings[i],15,2) + '.' +
                                                                               copy(mImportFile.strings[i],18,4)
                                                                               ));

                                                                          end;
                                                                    //'Order status:':
                                                                    //      begin
                                                                    //           if trim(mImportFile.strings[i+1])='Confirmed' then mHead.SetFieldValueAsBoolean('Confirmed',True) else mHead.SetFieldValueAsBoolean('Confirmed',False)  ;
                                                                    //      end;
                                                                    if copy(trim(mstringline),1,16)='Fakturační údaje' then

                                                                          begin
                                                                                mstring:='';
                                                                               mstring:=os.SQLSelectFirstAsString('Select id from Firms where Name=' + quotedstr(trim(mImportFile.strings[i+1])) + ' and hidden=' + quotedstr('N') + ' and firm_id is null');
                                                                               if mstring<>'' then begin
                                                                                    mHead.SetFieldValueAsstring('Firm_ID',mString);
                                                                                         if not NxIsEmptyOID(mHead.getFieldValueAsString('Firm_ID.Currency_ID')) then begin
                                                                                            mHead.SetFieldValueAsString('Currency_ID',mHead.getFieldValueAsString('Firm_ID.Currency_ID'));
                                                                                         end;

                                                                                       if UpperCase(mHead.getFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode'))='CZ' then begin
                                                                                               mHead.SetFieldValueAsInteger('TradeType',1);
                                                                                       end else begin
                                                                                          mEU:='';
                                                                                          mEU:= mSite.BaseObjectSpace.SQLSelectFirstAsString('Select id FROM Countries WHERE Hidden = ' + quotedstr('N') + '  AND X_EU_Member LIKE ' + quotedstr('A') + ' AND Code = ' + quotedstr(UpperCase(mHead.getFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode')))  );
                                                                                           if mEU<>'' then begin
                                                                                                  mHead.SetFieldValueAsInteger('TradeType',2);
                                                                                                  mHead.SetFieldValueAsstring('Country_ID',mEU);
                                                                                           end else begin
                                                                                                   mHead.SetFieldValueAsInteger('TradeType',3);
                                                                                                   mEU:= mSite.BaseObjectSpace.SQLSelectFirstAsString('Select id FROM Countries WHERE Hidden = ' + quotedstr('N') + ' AND Code = ' + quotedstr(UpperCase(mHead.getFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode')))  );
                                                                                                   mHead.SetFieldValueAsstring('Country_ID',mEU);
                                                                                           end;
                                                                                       end;
                                                                                      mstore_id:='1120000101';

                                                                               end;
                                                                          end;
                                                                     if trim(mstringline)='Položky' then //'Price':
                                                                          begin
                                                                                mBproduct:=True;
                                                                                //i:= i+3;
                                                                          end;
                                                                     if copy(mstringline,1,6)='Celkem:' then begin
                                                                          mBProduct:=False;
                                                                          mpomocprice:=0;
                                                                          mpomocprice:= NxIBStrToFloat(copy(trim(copy(mImportFile.strings[i],9,20)),1,NxCharPosR(' ', trim(copy(mImportFile.strings[i],9,20)))));
                                                                                       if mpomocprice=mIKusu then begin
                                                                                                  NxShowSimpleMessage('Počet kusů odpovídá ' + NxFloatToIBStr(mIKusu),nil);
                                                                                       end else begin
                                                                                                  NxShowSimpleMessage('Nesprávný počet kusů ' + NxFloatToIBStr(mpomocprice) + '/' + NxFloatToIBStr(mIKusu),nil);
                                                                                                  NxShowSimpleMessage( NxFloatToIBStr(NxIBStrToFloat(copy(mImportFile.strings[i],9,20))),nil);
                                                                                       end;

                                                                      end;

                                                       end;

                                                 end else begin
                                                     // je produkt
                                                              if trim(mstringline)='Mezisoučet' then
                                                                          begin
                                                                                mBproduct:=False;
                                                                          end;


                                                              mvalue2:=fnParsevalue(mImportFile.strings[i+1], chr(09));
                                                              if mvalue.count>=2 then begin

                                                                        //NxShowSimpleMessage(,nil);

                                                                       mstorecard_ID:='';
                                                                       mstorecard_ID:=TDynSiteForm(msite).BaseObjectSpace.SQLSelectFirstAsString('Select id from storecards where EAN=' + quotedstr(NxSearchReplace(trim(mvalue.Strings[0]),chr(39),'',[srCase,srAll])));
                                                                       //NxShowSimpleMessage(mImportFile.strings[i],nil);

                                                                       if (mstorecard_ID<>'') and (NxSearchReplace(trim(mvalue.Strings[0]),chr(39),'',[srCase,srAll])<>'') then begin
                                                                              mvalue2:=fnParsevalue(mImportFile.strings[i+1], chr(09));
                                                                                  //NxShowSimpleMessage(inttostr(mvalue2.count),nil);
                                                                              mRow := mHead.Rows.AddNewObject;


                                                                              mRow.Prefill;
                                                                              //mRow.SetFieldValueAsInteger('PosIndex',i);
                                                                              mRow.SetFieldValueAsInteger('RowType',3);
                                                                              mRow.SetFieldValueAsString('Store_ID',mstore_id);
                                                                              //NxShowSimpleMessage(mStoreCard_ID,nil);
                                                                              mRow.SetFieldValueAsString('Storecard_ID',mStoreCard_ID);


                                                                              //mRow.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(trim(mvalue.Strings[4]),1,AnsiPos(' ', trim(mvalue.Strings[4]))))) ;
                                                                              //NxShowSimpleMessage( 'množství ' + (copy(trim(mvalue.Strings[1]),1,AnsiPos(' ', trim(mvalue.Strings[1])))),nil);
                                                                              if mvalue2.count>1 then begin
                                                                                  mRow.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(mvalue2.Strings[1]));

                                                                                  mpomocprice:= NxIBStrToFloat(NxSearchReplace(copy(trim(mvalue2.Strings[0]),1,NxCharPosR(' ', trim(mvalue2.Strings[0]))),' ','',[srCase,srAll]));
                                                                                  mRow.SetFieldValueAsFloat('Unitprice',mpomocprice) ;
                                                                                  //NxShowSimpleMessage(NxFloatToIBStr(mpomocprice) ,nil);

                                                                                  //NxShowSimpleMessage(copy(trim(mvalue2.Strings[1]),1,AnsiPos(' ', trim(mvalue2.Strings[1]))),nil);
                                                                                  //NxShowSimpleMessage(copy(trim(mvalue2.Strings[0]),1,AnsiPos(' ', trim(mvalue2.Strings[0]))),nil);
                                                                              end;

                                                                              //mRow.SetFieldValueAsFloat('Quantity',1) ;
                                                                              mIRadku:=mIRadku+1;
                                                                              mIKusu:=mIKusu +mRow.getFieldValueAsFloat('Quantity');
                                                                              mpomocprice:=0;




                                                                              //mRow.SetFieldValueAsString('Division_ID',mDivision_ID); //text bude  ...

                                                                              if not NxIsEmptyOID((mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))) then begin
                                                                                         mBustransaction_ID:=(mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'));
                                                                                         mRow.SetFieldValueAsString('BusTransaction_id',mBustransaction_ID );
                                                                              end;
                                                                              if NxIsEmptyOID(mRow.GetFieldValueAsString('BusOrder_id')) then begin
                                                                                  mBusOrder_ID:=GetBusOrder_ID(mRow);
                                                                                  if not nxisblank(mBusOrder_ID) then mRow.SetFieldValueAsString('BusOrder_id',mBusOrder_ID);
                                                                                  end;
                                                                                  if NxIsEmptyOID(mRow.GetFieldValueAsString('BusProject_id')) then begin
                                                                                      mBusProject_ID:=GetProject_ID(mRow);
                                                                                      if not nxisblank(mBusProject_ID) then mRow.SetFieldValueAsString('BusProject_id',mBusProject_ID);
                                                                                  end;
                                                                            i:=i+1;
                                                                        end;
                                                              end;

                                                 end;
                                          finally

                                          end;


                                        end;




                              end;
                            //  NxShowSimpleMessage(inttostr(mImportFile.count),nil) ;






  result:=mhead;
end;






function FnParsePotvBTBxlsPolozky(OS:TNxCustomObjectSpace;msite:TSiteForm;mHead:TNxHeaderBusinessObject):TNxHeaderBusinessObject;
var
mImportFile:tstringlist;
i:integer;
mstringline:string;
mvalue:TStringList;
mBproduct:boolean;
mSGroup:boolean;
mString:string;
mEU:string;
mIProdukt:integer;
mstorecard_ID:string;
mBusProject_ID,mBustransaction_ID,mBusOrder_ID,mstore_id:string;
mIRadku:integer;
mIKusu:Double;
mIcena:Double;
mpomocprice:double;
mRow:TNxCustomBusinessObject;
begin
  mIKusu:=0;
  mIcena:=0;
  mImportFile:=TStringList.create;
                              mImportFile:=fnParsevalue(BarCode_document(mSite,'05CPMINJW3DL342X01C0CX3FCC',0,0,720,960, 'Obsah potvrzení','Položky : ','','Pokračovat','',''), chr(10));
                              ProgressInit(msite, 'Načítání dat ' + '', 100);

                              for i:=0 to mImportFile.Count-1 do begin   // načtení souboru
                                        mvalue:=tstringlist.create;
                                        ProgressSetPos(1+NxFloor((i/mImportFile.Count)*99), inttostr(i) +' z '+inttostr(mImportFile.Count));
                                        mstringline:=  NxSearchReplace(mImportFile.strings[i],chr(39),'',[srCase,srAll]);

                                        if trim(mstringline)<>'' then begin
                                           try
                                            mvalue:=fnParsevalue(mstringline, chr(09));
                                                { if not mBproduct then begin
                                                       if mvalue.count>1 then begin
                                                              case trim(mvalue.Strings[0]) of
                                                                   'Order number:':
                                                                          begin
                                                                               //NxShowSimpleMessage(mvalue.Strings[1],nil);
                                                                               mHead.SetFieldValueAsString('ExternalNumber',(trim(NxSearchReplace(mvalue.strings[1],chr(39),'',[srCase,srAll]))));
                                                                               mHead.SetFieldValueAsInteger('X_VarSymbol', strtoint(trim(NxSearchReplace(mvalue.strings[1],chr(39),'',[srCase,srAll]))));
                                                                          end;
                                                                    'Order date:':
                                                                          begin
                                                                               mHead.SetFieldValueAsDateTime('Docdate$date', StrToDate(
                                                                               copy(mvalue.strings[1],9,2) + '.' +
                                                                               copy(mvalue.strings[1],6,2) + '.' +
                                                                               copy(mvalue.strings[1],1,4)
                                                                               ));
                                                                          end;

                                                              end;
                                                       end else begin
                                                              case trim(mstringline) of
                                                                   'Order number:':
                                                                          begin
                                                                               //NxShowSimpleMessage(mvalue.Strings[1],nil);
                                                                               mHead.SetFieldValueAsString('ExternalNumber',(trim(NxSearchReplace(mImportFile.strings[i+1],chr(39),'',[srCase,srAll]))));
                                                                               mHead.SetFieldValueAsInteger('X_VarSymbol', strtoint(trim(NxSearchReplace(mImportFile.strings[i+1],chr(39),'',[srCase,srAll]))));
                                                                          end;
                                                                    'Order date:':
                                                                          begin
                                                                               mHead.SetFieldValueAsDateTime('Docdate$date', StrToDate(
                                                                               copy(mImportFile.strings[i+1],9,2) + '.' +
                                                                               copy(mImportFile.strings[i+1],6,2) + '.' +
                                                                               copy(mImportFile.strings[i+1],1,4)
                                                                               ));

                                                                          end;
                                                                    'Order status:':
                                                                          begin
                                                                               if trim(mImportFile.strings[i+1])='Confirmed' then mHead.SetFieldValueAsBoolean('Confirmed',True) else mHead.SetFieldValueAsBoolean('Confirmed',False)  ;
                                                                          end;
                                                                    'Company:':
                                                                          begin
                                                                                mstring:='';
                                                                               mstring:=os.SQLSelectFirstAsString('Select id from Firms where Name=' + quotedstr(trim(mImportFile.strings[i+1])) + ' and hidden=' + quotedstr('N') + ' and firm_id is null');
                                                                               if mstring<>'' then begin
                                                                                    mHead.SetFieldValueAsstring('Firm_ID',mString);
                                                                                         if not NxIsEmptyOID(mHead.getFieldValueAsString('Firm_ID.Currency_ID')) then begin
                                                                                            mHead.SetFieldValueAsString('Currency_ID',mHead.getFieldValueAsString('Firm_ID.Currency_ID'));
                                                                                         end;

                                                                                       if UpperCase(mHead.getFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode'))='CZ' then begin
                                                                                               mHead.SetFieldValueAsInteger('TradeType',1);
                                                                                       end else begin
                                                                                          mEU:='';
                                                                                          mEU:= mSite.BaseObjectSpace.SQLSelectFirstAsString('Select id FROM Countries WHERE Hidden = ' + quotedstr('N') + '  AND X_EU_Member LIKE ' + quotedstr('A') + ' AND Code = ' + quotedstr(UpperCase(mHead.getFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode')))  );
                                                                                           if mEU<>'' then begin
                                                                                                  mHead.SetFieldValueAsInteger('TradeType',2);
                                                                                                  mHead.SetFieldValueAsstring('Country_ID',mEU);
                                                                                           end else begin
                                                                                                   mHead.SetFieldValueAsInteger('TradeType',3);
                                                                                                   mEU:= mSite.BaseObjectSpace.SQLSelectFirstAsString('Select id FROM Countries WHERE Hidden = ' + quotedstr('N') + ' AND Code = ' + quotedstr(UpperCase(mHead.getFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode')))  );
                                                                                                   mHead.SetFieldValueAsstring('Country_ID',mEU);
                                                                                           end;
                                                                                       end;
                                                                                      mstore_id:='1120000101';

                                                                               end;
                                                                          end;
                                                                     'Price':
                                                                          begin
                                                                                mBproduct:=True;
                                                                                mIProdukt:= i+2;
                                                                          end;

                                                                      'Product name	Catalogue number	Quantity	Price:':
                                                                          begin
                                                                                mBproduct:=True;
                                                                                mIProdukt:= i+2;
                                                                          end;

                                                                     'Subtotal:':
                                                                          begin

                                                                               mpomocprice:= NxIBStrToFloat(NxSearchReplace(copy(trim(mImportFile.strings[i+1]),1,NxCharPosR(' ', trim(mImportFile.strings[i+1]))),' ','',[srCase,srAll]));
                                                                               if Abs(mIcena-mpomocprice)<0.01 then begin
                                                                                          NxShowSimpleMessage('Cena po importu odpovídá ' + NxFloatToIBStr(mIcena),nil);
                                                                               end else begin
                                                                                          NxShowSimpleMessage('Nesprávná cena ' + NxFloatToIBStr(Abs(mIcena-mpomocprice)),nil);

                                                                               end;
                                                                          end;
                                                                      'Shipping :':
                                                                          begin
                                                                               mRow := mHead.Rows.AddNewObject;
                                                                                              mRow.Prefill;
                                                                                              mRow.SetFieldValueAsInteger('RowType',3);
                                                                                              mRow.SetFieldValueAsString('Store_ID',mstore_id);
                                                                                              mRow.SetFieldValueAsString('Storecard_ID','3PC0000101');
                                                                                              mRow.SetFieldValueAsFloat('Quantity',1) ;

                                                                                              mpomocprice:=0;
                                                                                              mpomocprice:= NxIBStrToFloat(copy(trim(mImportFile.strings[i+1]),1,AnsiPos(' ', trim(trim(mImportFile.strings[i+1])))));
                                                                                              mRow.SetFieldValueAsFloat('Unitprice',mpomocprice) ;
                                                                                              //mRow.SetFieldValueAsString('Division_ID',mDivision_ID); //text bude  ...

                                                                          end;
                                                                          'Order note':
                                                                          begin
                                                                               if i<>mImportFile.Count-1 then begin
                                                                                  mHead.SetFieldValueAsString('X_poznamka',(trim(NxSearchReplace(mImportFile.strings[i+1],chr(39),'',[srCase,srAll]))));
                                                                               end;
                                                                          end;

                                                              end;
                                                       end;

                                                 end else begin
                                                     // je produkt

                                                              if copy(mstringline,1,6)='Total:' then begin
                                                                  mBProduct:=False;
                                                                  mpomocprice:=0;
                                                                  mpomocprice:= NxIBStrToFloat(copy(trim(copy(mImportFile.strings[i],7,20)),1,NxCharPosR(' ', trim(copy(mImportFile.strings[i],7,20)))));
                                                                               if mpomocprice=mIKusu then begin
                                                                                          NxShowSimpleMessage('Počet kusů odpovídá ' + NxFloatToIBStr(mIKusu),nil);
                                                                               end else begin
                                                                                          NxShowSimpleMessage('Nesprávný počet kusů ' + NxFloatToIBStr(mpomocprice) + '/' + NxFloatToIBStr(mIKusu),nil);
                                                                                          NxShowSimpleMessage( NxFloatToIBStr(NxIBStrToFloat(copy(mImportFile.strings[i],7,20))),nil);
                                                                               end;

                                                              end;


                                                            }



                                                              if mvalue.count>=2 then begin
                                                                        //       NxShowSimpleMessage(mvalue.strings[0],nil);
                                                                        //NxShowSimpleMessage(,nil);
                                                                        //NxShowSimpleMessage(copy(trim(mvalue.Strings[2]),1,AnsiPos(' ',trim(mvalue.Strings[2]))),nil);
                                                                       mstorecard_ID:='';
                                                                       mstorecard_ID:=TDynSiteForm(msite).BaseObjectSpace.SQLSelectFirstAsString('Select id from storecards where EAN=' + quotedstr(NxSearchReplace(mvalue.Strings[0],chr(39),'',[srCase,srAll])));
                                                                       //mstorecard_ID:=TDynSiteForm(msite).BaseObjectSpace.SQLSelectFirstAsString('Select id from storecards where EAN=' + quotedstr(NxSearchReplace(mvalue.Strings[1],chr(39),'',[srCase,srAll])));


                                                                       if mstorecard_ID<>'' then begin
                                                                              mRow := mHead.Rows.AddNewObject;

                                                                              mRow.Prefill;
                                                                              //mRow.SetFieldValueAsInteger('PosIndex',i);
                                                                              mRow.SetFieldValueAsInteger('RowType',3);
                                                                              mRow.SetFieldValueAsString('Store_ID','1120000101');
                                                                              mRow.SetFieldValueAsString('Division_ID','1N00000101');
                                                                              //NxShowSimpleMessage(mStoreCard_ID,nil);
                                                                              mRow.SetFieldValueAsString('Storecard_ID',mStoreCard_ID);


                                                                              //mRow.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(trim(mvalue.Strings[1]),1,AnsiPos(' ', trim(mvalue.Strings[1]))))) ;
                                                                              mRow.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(trim(mvalue.Strings[1]),1,AnsiPos(' ', trim(mvalue.Strings[1]))))) ;
                                                                              //NxShowSimpleMessage( 'množství ' + (copy(trim(mvalue.Strings[1]),1,AnsiPos(' ', trim(mvalue.Strings[1])))),nil);

                                                                              //mRow.SetFieldValueAsFloat('Quantity',1) ;
                                                                              mIRadku:=mIRadku+1;
                                                                              mIKusu:=mIKusu +mRow.getFieldValueAsFloat('Quantity');
                                                                              mpomocprice:=0;


                                                                              //NxShowSimpleMessage('cena' + (copy(trim(mvalue.Strings[2]),1,AnsiPos(' ', trim(mvalue.Strings[2])))),nil);
                                                                              mpomocprice:= NxIBStrToFloat(copy(trim(mvalue.Strings[2]),1,AnsiPos(' ', trim(mvalue.Strings[2]))))/mRow.getFieldValueAsFloat('Quantity');;

                                                                              //mpomocprice:=1;
                                                                              mRow.SetFieldValueAsFloat('Unitprice',mpomocprice) ;
                                                                              mRow.SetFieldValueAsString('Division_ID',mDivision_ID); //text bude  ...

                                                                              if not NxIsEmptyOID((mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))) then begin
                                                                                         mBustransaction_ID:=(mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'));
                                                                                         mRow.SetFieldValueAsString('BusTransaction_id',mBustransaction_ID );
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




                                                 end;
                                          finally
                                           mvalue.free;
                                          end;


                                        end;


                              end;






  result:=mhead;
end;










function FnParsePotvrzeniBTB(OS:TNxCustomObjectSpace;msite:TSiteForm;mHead:TNxHeaderBusinessObject):TNxHeaderBusinessObject;
var
mImportFile:tstringlist;
i:integer;
mstringline:string;
mvalue:TStringList;
mBproduct:boolean;
mSGroup:boolean;
mString:string;
mEU:string;
mIProdukt:integer;
mstorecard_ID:string;
mBusProject_ID,mBustransaction_ID,mBusOrder_ID,mstore_id:string;
mIRadku:integer;
mIKusu:Double;
mIcena:Double;
mpomocprice:double;
mRow:TNxCustomBusinessObject;
 mOLE, mRoll, mOResult,_SS: Variant;
begin
  mIKusu:=0;
  mIcena:=0;
  mImportFile:=TStringList.create;
                              mImportFile:=fnParsevalue(BarCode_document(mSite,'05CPMINJW3DL342X01C0CX3FCC',0,0,720,960, 'Obsah potvrzení','Položky : ','','Pokračovat','',''), chr(10));
                              ProgressInit(msite, 'Načítání dat ' + '', 100);

                              for i:=0 to mImportFile.Count-1 do begin   // načtení souboru
                                        mvalue:=tstringlist.create;
                                        ProgressSetPos(1+NxFloor((i/mImportFile.Count)*99), inttostr(i) +' z '+inttostr(mImportFile.Count));
                                        mstringline:=  NxSearchReplace(mImportFile.strings[i],chr(39),'',[srCase,srAll]);

                                        if trim(mstringline)<>'' then begin
                                           try
                                            mvalue:=fnParsevalue(mstringline, chr(09));
                                                 if not mBproduct then begin
                                                       if mvalue.count>1 then begin
                                                              case trim(mvalue.Strings[0]) of
                                                                   'Company:':
                                                                          begin
                                                                                mstring:='';
                                                                               mstring:=os.SQLSelectFirstAsString('Select id from Firms where Name=' + quotedstr(trim(mImportFile.strings[i+1])) + ' and hidden=' + quotedstr('N') + ' and firm_id is null');
                                                                               if mstring<>'' then begin
                                                                                    mHead.SetFieldValueAsstring('Firm_ID',mString);
                                                                               end else begin
                                                                                     mOLE := GetAbraOLEApplication;
                                                                                            mroll := mOLE.GetAgenda('N1C2EX0BUJD13ACP03KIU0CLP4');
                                                                                            _ss := mOLE.CreateStrings;
                                                                                               mString := mroll.SingleSelectFromSelected2(_ss, 'Vyber odběratele', '');
                                                                                               if mstring<>'' then begin
                                                                                                      mHead.SetFieldValueAsstring('Firm_ID',mString);
                                                                                               end else begin
                                                                                                      NxShowSimpleMessage('Bez uvedené firmy nelze pokračovat', nil);
                                                                                                      exit;
                                                                                               end;

                                                                               end;
                                                                               if not NxIsEmptyOID(mHead.getFieldValueAsString('Firm_ID.Currency_ID')) then begin
                                                                                        mHead.SetFieldValueAsString('Currency_ID',mHead.getFieldValueAsString('Firm_ID.Currency_ID'));
                                                                               end;

                                                                               if UpperCase(mHead.getFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode'))='CZ' then begin
                                                                                       mHead.SetFieldValueAsInteger('TradeType',1);
                                                                               end else begin
                                                                                  mEU:='';
                                                                                  mEU:= mSite.BaseObjectSpace.SQLSelectFirstAsString('Select id FROM Countries WHERE Hidden = ' + quotedstr('N') + '  AND X_EU_Member LIKE ' + quotedstr('A') + ' AND Code = ' + quotedstr(UpperCase(mHead.getFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode')))  );
                                                                                   if mEU<>'' then begin
                                                                                          mHead.SetFieldValueAsInteger('TradeType',2);
                                                                                          mHead.SetFieldValueAsstring('Country_ID',mEU);
                                                                                   end else begin
                                                                                           mHead.SetFieldValueAsInteger('TradeType',3);
                                                                                           mEU:= mSite.BaseObjectSpace.SQLSelectFirstAsString('Select id FROM Countries WHERE Hidden = ' + quotedstr('N') + ' AND Code = ' + quotedstr(UpperCase(mHead.getFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode')))  );
                                                                                           mHead.SetFieldValueAsstring('Country_ID',mEU);
                                                                                   end;
                                                                               end;
                                                                               mstore_id:='1120000101';
                                                                          end;

                                                                   'Order number:':
                                                                          begin
                                                                               //NxShowSimpleMessage(mvalue.Strings[1],nil);
                                                                               mHead.SetFieldValueAsString('ExternalNumber',(trim(NxSearchReplace(mvalue.strings[1],chr(39),'',[srCase,srAll]))));
                                                                               mHead.SetFieldValueAsInteger('X_VarSymbol', strtoint(trim(NxSearchReplace(mvalue.strings[1],chr(39),'',[srCase,srAll]))));
                                                                          end;
                                                                    'Order date:':
                                                                          begin
                                                                               mHead.SetFieldValueAsDateTime('Docdate$date', StrToDate(
                                                                               copy(mvalue.strings[1],9,2) + '.' +
                                                                               copy(mvalue.strings[1],6,2) + '.' +
                                                                               copy(mvalue.strings[1],1,4)
                                                                               ));
                                                                          end;
                                                                     'Order status:':
                                                                          begin
                                                                               if trim(mImportFile.strings[i+1])='Confirmed' then mHead.SetFieldValueAsBoolean('Confirmed',True) else mHead.SetFieldValueAsBoolean('Confirmed',False)  ;
                                                                          end;
                                                                     'Price':
                                                                          begin
                                                                                mBproduct:=True;
                                                                                //mIProdukt:= i+2;
                                                                          end;
                                                                     'Product name	Catalogue number	Quantity	Price:':
                                                                          begin
                                                                                mBproduct:=True;
                                                                                //mIProdukt:= i+2;
                                                                          end;
                                                                      'Product name	Catalogue number	Quantity	Price	':
                                                                          begin
                                                                                NxShowSimpleMessage('AAA',nil);
                                                                                mBproduct:=True;
                                                                                //mIProdukt:= i+2;
                                                                          end;
                                                                        'Order items':
                                                                          begin
                                                                                //NxShowSimpleMessage('ccc',nil);
                                                                                mBproduct:=True;
                                                                               // mIProdukt:= i+2;
                                                                          end;
                                                                     {'Subtotal:':
                                                                          begin

                                                                               mpomocprice:= NxIBStrToFloat(NxSearchReplace(copy(trim(mImportFile.strings[i+1]),1,NxCharPosR(' ', trim(mImportFile.strings[i+1]))),' ','',[srCase,srAll]));
                                                                               if Abs(mIcena-mpomocprice)<0.01 then begin
                                                                                          NxShowSimpleMessage('Cena po importu odpovídá ' + NxFloatToIBStr(mIcena),nil);
                                                                               end else begin
                                                                                          NxShowSimpleMessage('Nesprávná cena ' + NxFloatToIBStr(Abs(mIcena-mpomocprice)),nil);

                                                                               end;
                                                                          end;
                                                                      'Shipping :':
                                                                          begin
                                                                               mRow := mHead.Rows.AddNewObject;
                                                                                              mRow.Prefill;
                                                                                              mRow.SetFieldValueAsInteger('RowType',3);
                                                                                              mRow.SetFieldValueAsString('Store_ID',mstore_id);
                                                                                              mRow.SetFieldValueAsString('Storecard_ID','3PC0000101');
                                                                                              mRow.SetFieldValueAsFloat('Quantity',1) ;

                                                                                              mpomocprice:=0;
                                                                                              mpomocprice:= NxIBStrToFloat(copy(trim(mImportFile.strings[i+1]),1,AnsiPos(' ', trim(trim(mImportFile.strings[i+1])))));
                                                                                              mRow.SetFieldValueAsFloat('Unitprice',mpomocprice) ;
                                                                                              //mRow.SetFieldValueAsString('Division_ID',mDivision_ID); //text bude  ...

                                                                          end;
                                                                          'Order note':
                                                                          begin
                                                                               if i<>mImportFile.Count-1 then begin
                                                                                  mHead.SetFieldValueAsString('X_poznamka',(trim(NxSearchReplace(mImportFile.strings[i+1],chr(39),'',[srCase,srAll]))));
                                                                               end;
                                                                          end;
                                                                                }

                                                              end;
                                                       end else begin
                                                              case trim(mstringline) of
                                                                   'Company:':
                                                                          begin
                                                                                mstring:='';
                                                                               mstring:=os.SQLSelectFirstAsString('Select id from Firms where Name=' + quotedstr(trim(mImportFile.strings[i+1])) + ' and hidden=' + quotedstr('N') + ' and firm_id is null');
                                                                               if mstring<>'' then begin
                                                                                    mHead.SetFieldValueAsstring('Firm_ID',mString);
                                                                               end else begin
                                                                                     mOLE := GetAbraOLEApplication;
                                                                                            mroll := mOLE.GetAgenda('N1C2EX0BUJD13ACP03KIU0CLP4');
                                                                                            _ss := mOLE.CreateStrings;
                                                                                               mString := mroll.SingleSelectFromSelected2(_ss, 'Vyber odběratele', '');
                                                                                               if mstring<>'' then begin
                                                                                                      mHead.SetFieldValueAsstring('Firm_ID',mString);
                                                                                               end else begin
                                                                                                      NxShowSimpleMessage('Bez uvedené firmy nelze pokračovat', nil);
                                                                                                      exit;
                                                                                               end;

                                                                               end;
                                                                               if not NxIsEmptyOID(mHead.getFieldValueAsString('Firm_ID.Currency_ID')) then begin
                                                                                        mHead.SetFieldValueAsString('Currency_ID',mHead.getFieldValueAsString('Firm_ID.Currency_ID'));
                                                                               end;

                                                                               if UpperCase(mHead.getFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode'))='CZ' then begin
                                                                                       mHead.SetFieldValueAsInteger('TradeType',1);
                                                                               end else begin
                                                                                  mEU:='';
                                                                                  mEU:= mSite.BaseObjectSpace.SQLSelectFirstAsString('Select id FROM Countries WHERE Hidden = ' + quotedstr('N') + '  AND X_EU_Member LIKE ' + quotedstr('A') + ' AND Code = ' + quotedstr(UpperCase(mHead.getFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode')))  );
                                                                                   if mEU<>'' then begin
                                                                                          mHead.SetFieldValueAsInteger('TradeType',2);
                                                                                          mHead.SetFieldValueAsstring('Country_ID',mEU);
                                                                                   end else begin
                                                                                           mHead.SetFieldValueAsInteger('TradeType',3);
                                                                                           mEU:= mSite.BaseObjectSpace.SQLSelectFirstAsString('Select id FROM Countries WHERE Hidden = ' + quotedstr('N') + ' AND Code = ' + quotedstr(UpperCase(mHead.getFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode')))  );
                                                                                           mHead.SetFieldValueAsstring('Country_ID',mEU);
                                                                                   end;
                                                                               end;
                                                                               mstore_id:='1120000101';
                                                                          end;



                                                                   'Order number:':
                                                                          begin
                                                                               //NxShowSimpleMessage(mvalue.Strings[1],nil);
                                                                               mHead.SetFieldValueAsString('ExternalNumber',(trim(NxSearchReplace(mImportFile.strings[i+1],chr(39),'',[srCase,srAll]))));
                                                                               mHead.SetFieldValueAsInteger('X_VarSymbol', strtoint(trim(NxSearchReplace(mImportFile.strings[i+1],chr(39),'',[srCase,srAll]))));
                                                                          end;
                                                                    'Order date:':
                                                                          begin
                                                                               mHead.SetFieldValueAsDateTime('Docdate$date', StrToDate(
                                                                               copy(mImportFile.strings[i+1],9,2) + '.' +
                                                                               copy(mImportFile.strings[i+1],6,2) + '.' +
                                                                               copy(mImportFile.strings[i+1],1,4)
                                                                               ));

                                                                          end;
                                                                    'Order status:':
                                                                          begin
                                                                               if trim(mImportFile.strings[i+1])='Confirmed' then mHead.SetFieldValueAsBoolean('Confirmed',True) else mHead.SetFieldValueAsBoolean('Confirmed',False)  ;
                                                                          end;

                                                                     'Price':
                                                                          begin
                                                                                mBproduct:=True;
                                                                                //mIProdukt:= i+2;
                                                                          end;
                                                                     'Product name	Catalogue number	Quantity	Price:':
                                                                          begin
                                                                                mBproduct:=True;
                                                                                //mIProdukt:= i+2;
                                                                          end;
                                                                      'Product name	Catalogue number	Quantity	Price':
                                                                          begin
                                                                                NxShowSimpleMessage('BBB',nil);
                                                                                mBproduct:=True;
                                                                               // mIProdukt:= i+2;
                                                                          end;

                                                                       'Order items':
                                                                          begin
                                                                                //NxShowSimpleMessage('ccc',nil);
                                                                                mBproduct:=True;
                                                                               // mIProdukt:= i+2;
                                                                          end;

                                                                     'Subtotal:':
                                                                          begin

                                                                               mpomocprice:= NxIBStrToFloat(NxSearchReplace(copy(trim(mImportFile.strings[i+1]),1,NxCharPosR(' ', trim(mImportFile.strings[i+1]))),' ','',[srCase,srAll]));
                                                                               if Abs(mIcena-mpomocprice)<0.01 then begin
                                                                                          NxShowSimpleMessage('Cena po importu odpovídá ' + NxFloatToIBStr(mIcena),nil);
                                                                               end else begin
                                                                                          NxShowSimpleMessage('Nesprávná cena ' + NxFloatToIBStr(Abs(mIcena-mpomocprice)),nil);

                                                                               end;
                                                                          end;
                                                                      'Shipping :':
                                                                          begin
                                                                               mRow := mHead.Rows.AddNewObject;
                                                                                              mRow.Prefill;
                                                                                              mRow.SetFieldValueAsInteger('RowType',3);
                                                                                              mRow.SetFieldValueAsString('Store_ID',mstore_id);
                                                                                              mRow.SetFieldValueAsString('Storecard_ID','3PC0000101');
                                                                                              mRow.SetFieldValueAsFloat('Quantity',1) ;

                                                                                              mpomocprice:=0;
                                                                                              mpomocprice:= NxIBStrToFloat(copy(trim(mImportFile.strings[i+1]),1,AnsiPos(' ', trim(trim(mImportFile.strings[i+1])))));
                                                                                              mRow.SetFieldValueAsFloat('Unitprice',mpomocprice) ;
                                                                                              //mRow.SetFieldValueAsString('Division_ID',mDivision_ID); //text bude  ...

                                                                          end;
                                                                          'Order note':
                                                                          begin
                                                                               if i<>mImportFile.Count-1 then begin
                                                                                  mHead.SetFieldValueAsString('X_poznamka',(trim(NxSearchReplace(mImportFile.strings[i+1],chr(39),'',[srCase,srAll]))));
                                                                               end;
                                                                          end;

                                                              end;
                                                       end;

                                                 end else begin
                                                     // je produkt

                                                              if copy(mstringline,1,6)='Total:' then begin
                                                                  mBProduct:=False;
                                                                  mpomocprice:=0;
                                                                  mpomocprice:= NxIBStrToFloat(copy(trim(copy(mImportFile.strings[i],7,20)),1,NxCharPosR(' ', trim(copy(mImportFile.strings[i],7,20)))));
                                                                               if mpomocprice=mIKusu then begin
                                                                                          NxShowSimpleMessage('Počet kusů odpovídá ' + NxFloatToIBStr(mIKusu),nil);
                                                                               end else begin
                                                                                          NxShowSimpleMessage('Nesprávný počet kusů ' + NxFloatToIBStr(mpomocprice) + '/' + NxFloatToIBStr(mIKusu),nil);
                                                                                          NxShowSimpleMessage( NxFloatToIBStr(NxIBStrToFloat(copy(mImportFile.strings[i],7,20))),nil);
                                                                               end;

                                                              end;






                                                              if mvalue.count>3 then begin
                                                                        //       NxShowSimpleMessage(mvalue.strings[0],nil);
                                                                        //NxShowSimpleMessage(,nil);
                                                                        //NxShowSimpleMessage(copy(trim(mvalue.Strings[2]),1,AnsiPos(' ',trim(mvalue.Strings[2]))),nil);
                                                                       mstorecard_ID:='';
                                                                       mstorecard_ID:=TDynSiteForm(msite).BaseObjectSpace.SQLSelectFirstAsString('Select id from storecards where EAN=' + quotedstr(NxSearchReplace(mvalue.Strings[0],chr(39),'',[srCase,srAll])));
                                                                       //mstorecard_ID:=TDynSiteForm(msite).BaseObjectSpace.SQLSelectFirstAsString('Select id from storecards where EAN=' + quotedstr(NxSearchReplace(mvalue.Strings[1],chr(39),'',[srCase,srAll])));


                                                                       if mstorecard_ID<>'' then begin
                                                                              mRow := mHead.Rows.AddNewObject;

                                                                              mRow.Prefill;
                                                                              //mRow.SetFieldValueAsInteger('PosIndex',i);
                                                                              mRow.SetFieldValueAsInteger('RowType',3);
                                                                              mRow.SetFieldValueAsString('Store_ID',mstore_id);
                                                                              //NxShowSimpleMessage(mStoreCard_ID,nil);
                                                                              mRow.SetFieldValueAsString('Storecard_ID',mStoreCard_ID);


                                                                              //mRow.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(trim(mvalue.Strings[1]),1,AnsiPos(' ', trim(mvalue.Strings[1]))))) ;
                                                                              mRow.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(trim(mvalue.Strings[1]),1,AnsiPos(' ', trim(mvalue.Strings[1]))))) ;
                                                                              //NxShowSimpleMessage( 'množství ' + (copy(trim(mvalue.Strings[1]),1,AnsiPos(' ', trim(mvalue.Strings[1])))),nil);

                                                                              //mRow.SetFieldValueAsFloat('Quantity',1) ;
                                                                              mIRadku:=mIRadku+1;
                                                                              mIKusu:=mIKusu +mRow.getFieldValueAsFloat('Quantity');
                                                                              mpomocprice:=0;


                                                                              //NxShowSimpleMessage('cena' + (copy(trim(mvalue.Strings[2]),1,AnsiPos(' ', trim(mvalue.Strings[2])))),nil);
                                                                              mpomocprice:= NxIBStrToFloat(copy(trim(mvalue.Strings[3]),1,AnsiPos(' ', trim(mvalue.Strings[3]))))/mRow.getFieldValueAsFloat('Quantity');;

                                                                              //mpomocprice:=1;
                                                                              mRow.SetFieldValueAsFloat('Unitprice',mpomocprice) ;
                                                                              mRow.SetFieldValueAsString('Division_ID',mDivision_ID); //text bude  ...

                                                                              if not NxIsEmptyOID((mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))) then begin
                                                                                         mBustransaction_ID:=(mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'));
                                                                                         mRow.SetFieldValueAsString('BusTransaction_id',mBustransaction_ID );
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



                                                              end else begin
                                                                 if mvalue.count=3 then begin
                                                                          //       NxShowSimpleMessage(mvalue.strings[0],nil);
                                                                        //NxShowSimpleMessage(,nil);
                                                                        //NxShowSimpleMessage(copy(trim(mvalue.Strings[2]),1,AnsiPos(' ',trim(mvalue.Strings[2]))),nil);
                                                                       mstorecard_ID:='';
                                                                       mstorecard_ID:=TDynSiteForm(msite).BaseObjectSpace.SQLSelectFirstAsString('Select id from storecards where EAN=' + quotedstr(NxSearchReplace(mvalue.Strings[0],chr(39),'',[srCase,srAll])));
                                                                       //mstorecard_ID:=TDynSiteForm(msite).BaseObjectSpace.SQLSelectFirstAsString('Select id from storecards where EAN=' + quotedstr(NxSearchReplace(mvalue.Strings[1],chr(39),'',[srCase,srAll])));


                                                                       if mstorecard_ID<>'' then begin
                                                                              mRow := mHead.Rows.AddNewObject;

                                                                              mRow.Prefill;
                                                                              //mRow.SetFieldValueAsInteger('PosIndex',i);
                                                                              mRow.SetFieldValueAsInteger('RowType',3);
                                                                              mRow.SetFieldValueAsString('Store_ID',mstore_id);
                                                                              //NxShowSimpleMessage(mStoreCard_ID,nil);
                                                                              mRow.SetFieldValueAsString('Storecard_ID',mStoreCard_ID);


                                                                              //mRow.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(trim(mvalue.Strings[1]),1,AnsiPos(' ', trim(mvalue.Strings[1]))))) ;
                                                                              mRow.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(trim(mvalue.Strings[1]),1,AnsiPos(' ', trim(mvalue.Strings[1]))))) ;
                                                                              //NxShowSimpleMessage( 'množství ' + (copy(trim(mvalue.Strings[1]),1,AnsiPos(' ', trim(mvalue.Strings[1])))),nil);

                                                                              //mRow.SetFieldValueAsFloat('Quantity',1) ;
                                                                              mIRadku:=mIRadku+1;
                                                                              mIKusu:=mIKusu +mRow.getFieldValueAsFloat('Quantity');
                                                                              mpomocprice:=0;


                                                                              //NxShowSimpleMessage('cena' + (copy(trim(mvalue.Strings[2]),1,AnsiPos(' ', trim(mvalue.Strings[2])))),nil);
                                                                              mpomocprice:= NxIBStrToFloat(copy(trim(mvalue.Strings[2]),1,AnsiPos(' ', trim(mvalue.Strings[2]))))/mRow.getFieldValueAsFloat('Quantity');;

                                                                              //mpomocprice:=1;
                                                                              mRow.SetFieldValueAsFloat('Unitprice',mpomocprice) ;
                                                                              mRow.SetFieldValueAsString('Division_ID',mDivision_ID); //text bude  ...

                                                                              if not NxIsEmptyOID((mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))) then begin
                                                                                         mBustransaction_ID:=(mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'));
                                                                                         mRow.SetFieldValueAsString('BusTransaction_id',mBustransaction_ID );
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





                                                                 end else begin




                                                                           if i=mIProdukt then begin
                                                                                       //    NxShowSimpleMessage(trim(mImportFile.strings[i]),nil);
                                                                                       mstorecard_ID:='';
                                                                                       mstorecard_ID:=OS.SQLSelectFirstAsString('Select id from storecards where EAN=' + quotedstr(trim(mImportFile.strings[i])));
                                                                                       //NxShowSimpleMessage(mstorecard_ID,nil);

                                                                                       if mstorecard_ID<>'' then begin
                                                                                              mRow := mHead.Rows.AddNewObject;

                                                                                              mRow.Prefill;
                                                                                              //mRow.SetFieldValueAsInteger('PosIndex',i);
                                                                                              mRow.SetFieldValueAsInteger('RowType',3);
                                                                                              mRow.SetFieldValueAsString('Store_ID',mstore_id);
                                                                                              //NxShowSimpleMessage(mStoreCard_ID,nil);
                                                                                              mRow.SetFieldValueAsString('Storecard_ID',mStoreCard_ID);


                                                                                              mRow.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(trim(mImportFile.strings[i+1]),1,AnsiPos(' ', trim(trim(mImportFile.strings[i+1])))))) ;
                                                                                              //NxShowSimpleMessage( 'množství ' + (copy(trim(mvalue.Strings[1]),1,AnsiPos(' ', trim(mvalue.Strings[1])))),nil);

                                                                                              //mRow.SetFieldValueAsFloat('Quantity',1) ;
                                                                                              mIRadku:=mIRadku+1;
                                                                                              mIKusu:=mIKusu +mRow.getFieldValueAsFloat('Quantity');
                                                                                              mpomocprice:=0;


                                                                                              //NxShowSimpleMessage('cena' + (copy(trim(mvalue.Strings[2]),1,AnsiPos(' ', trim(mvalue.Strings[2])))),nil);
                                                                                              mpomocprice:= NxIBStrToFloat(copy(trim(mImportFile.strings[i+2]),1,AnsiPos(' ', trim(trim(mImportFile.strings[i+2])))))/mRow.getFieldValueAsFloat('Quantity');

                                                                                              //mpomocprice:=1;
                                                                                              mRow.SetFieldValueAsFloat('Unitprice',mpomocprice) ;
                                                                                              //mRow.SetFieldValueAsString('Division_ID',mDivision_ID); //text bude  ...
                                                                                              mIcena:=micena+(mRow.getFieldValueAsFloat('Unitprice') * mRow.getFieldValueAsFloat('Quantity')) ;

                                                                                              //mIcena:=micena+NxRound(NxIBStrToFloat(copy(trim(mImportFile.strings[i+2]),1,AnsiPos(' ', trim(trim(mImportFile.strings[i+2]))))),0.01) ;


                                                                                        end;
                                                                                 mIProdukt:=mIProdukt+4;
                                                                           end;
                                                                     end;
                                                              end;


                                                        {      if not NxIsEmptyOID((mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))) then begin
                                                                         mBustransaction_ID:=(mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'));
                                                                         mRow.SetFieldValueAsString('BusTransaction_id',mBustransaction_ID );
                                                              end;
                                                              if NxIsEmptyOID(mRow.GetFieldValueAsString('BusOrder_id')) then begin
                                                                  mBusOrder_ID:=GetBusOrder_ID(mRow);
                                                                  if not nxisblank(mBusOrder_ID) then mRow.SetFieldValueAsString('BusOrder_id',mBusOrder_ID);
                                                                  end;
                                                                  if NxIsEmptyOID(mRow.GetFieldValueAsString('BusProject_id')) then begin
                                                                      mBusProject_ID:=GetProject_ID(mRow);
                                                                      if not nxisblank(mBusProject_ID) then mRow.SetFieldValueAsString('BusProject_id',mBusProject_ID);
                                                                  end;

                                                         }






                                                 end;
                                          finally

                                          end;


                                        end;



                                      {
                                      //  NxShowSimpleMessage(NxSearchReplace(mImportFile.strings[i],chr(39),'',[srCase,srAll]),nil);
                                       // if trim(mstringline)<>'' then begin
                                          try
                                            mvalue:=fnParsevalue(mstringline, chr(09));

                                          finally

                                          end;
                                         //    NxShowSimpleMessage(inttostr(mvalue.count),nil);

                                            if not mBproduct then begin
                                                   if mvalue.count>=0 then begin
                                                          case trim(mvalue.Strings[0]) of
                                                              'Order number:': begin
                                                                     //NxShowSimpleMessage(mvalue.Strings[1],nil);
                                                                     mHead.SetFieldValueAsString('ExternalNumber',(trim(NxSearchReplace(mvalue.strings[1],chr(39),'',[srCase,srAll]))));
                                                                     mHead.SetFieldValueAsInteger('X_VarSymbol', strtoint(trim(NxSearchReplace(mvalue.strings[1],chr(39),'',[srCase,srAll]))));

                                                                            end;
                                                              'Order date:': begin
                                                                     //NxShowSimpleMessage(datetostr(StrToDate(copy(mvalue.Strings[1],9,2) + '.'+copy(mvalue.Strings[1],6,2) + '.'+copy(mvalue.Strings[1],1,4))),nil);
                                                                     mHead.SetFieldValueAsDateTime('DocDate$Date',StrToDate(copy(mvalue.Strings[1],9,2) + '.'+copy(mvalue.Strings[1],6,2) + '.'+copy(mvalue.Strings[1],1,4)));
                                                                          end;
                                                              'Company:': begin
                                                                   mFirm_ID:='';
                                                                     mstring:=trim(mvalue.Strings[1]);
                                                                   mFirm_ID:= mSite.BaseObjectSpace.SQLSelectFirstAsString('Select id from Firms where name = ' + quotedstr(mstring) + ' and hidden=' + quotedstr('N') + ' and Firm_ID is null');
                                                                                      if not NxIsBlank(mFirm_ID) then begin
                                                                                           NxShowSimpleMessage(mFirm_ID,nil);
                                                                                      end else begin
                                                                                             mOLE := GetAbraOLEApplication;
                                                                                                  mroll := mOLE.GetAgenda('N1C2EX0BUJD13ACP03KIU0CLP4');
                                                                                                  _ss := mOLE.CreateStrings;
                                                                                             mFirm_ID:= mroll.SingleSelectFromSelected2(_ss, 'Firma nedohledána - vyber ' + mvalue.Strings[1], '');
                                                                                      end;

                                                                                       mHead.SetFieldValueAsString('Firm_ID',mFirm_ID);


                                                                                        if not NxIsEmptyOID(mHead.getFieldValueAsString('Firm_ID.Currency_ID')) then begin
                                                                                          //  mHead.SetFieldValueAsString('Currency_ID',mHead.getFieldValueAsString('Firm_ID.Currency_ID'));
                                                                                         end;

                                                                                        if UpperCase(mHead.getFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode'))='CZ' then begin
                                                                                               mHead.SetFieldValueAsInteger('TradeType',1);
                                                                                       end else begin
                                                                                          mEU:='';
                                                                                          mEU:= mSite.BaseObjectSpace.SQLSelectFirstAsString('Select id FROM Countries WHERE Hidden = ' + quotedstr('N') + '  AND X_EU_Member LIKE ' + quotedstr('A') + ' AND Code = ' + quotedstr(UpperCase(mHead.getFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode')))  );
                                                                                           if mEU<>'' then begin
                                                                                                  mHead.SetFieldValueAsInteger('TradeType',2);
                                                                                                  mHead.SetFieldValueAsstring('Country_ID',mEU);
                                                                                           end else begin
                                                                                                   mHead.SetFieldValueAsInteger('TradeType',3);
                                                                                                   mEU:= mSite.BaseObjectSpace.SQLSelectFirstAsString('Select id FROM Countries WHERE Hidden = ' + quotedstr('N') + ' AND Code = ' + quotedstr(UpperCase(mHead.getFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode')))  );
                                                                                                   mHead.SetFieldValueAsstring('Country_ID',mEU);
                                                                                           end;
                                                                                       end;


                                                                            end;
                                                              'Product name': begin
                                                                                 mBProduct:=true;
                                                                            end;
                                                         end;
                                                   end;
                                            end else begin
                                            // je produkt
                                                 //NxShowSimpleMessage(mvalue.strings[0],nil);
                                                  if copy(mstringline,1,6)='Total:' then begin
                                                      mBProduct:=False;
                                                  end;
                                                 if mvalue.count>=2 then begin
                                                            //NxShowSimpleMessage(mvalue.strings[0],nil);
                                                            //NxShowSimpleMessage(,nil);
                                                            //NxShowSimpleMessage(copy(trim(mvalue.Strings[2]),1,AnsiPos(' ',trim(mvalue.Strings[2]))),nil);
                                                           mstorecard_ID:='';
                                                           mstorecard_ID:=TDynSiteForm(msite).BaseObjectSpace.SQLSelectFirstAsString('Select id from storecards where EAN=' + quotedstr(NxSearchReplace(mvalue.Strings[0],chr(39),'',[srCase,srAll])));


                                                           if mstorecard_ID<>'' then begin
                                                                  mRow := mHead.Rows.AddNewObject;

                                                                  mRow.Prefill;
                                                                  //mRow.SetFieldValueAsInteger('PosIndex',i);
                                                                  mRow.SetFieldValueAsInteger('RowType',3);
                                                                  mRow.SetFieldValueAsString('Store_ID',mstore_id);
                                                                  //NxShowSimpleMessage(mStoreCard_ID,nil);
                                                                  mRow.SetFieldValueAsString('Storecard_ID',mStoreCard_ID);


                                                                  mRow.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(trim(mvalue.Strings[1]),1,AnsiPos(' ', trim(mvalue.Strings[1]))))) ;
                                                                  //NxShowSimpleMessage( 'množství ' + (copy(trim(mvalue.Strings[1]),1,AnsiPos(' ', trim(mvalue.Strings[1])))),nil);

                                                                  //mRow.SetFieldValueAsFloat('Quantity',1) ;
                                                                  mIRadku:=mIRadku+1;
                                                                  mIKusu:=mIKusu +mRow.getFieldValueAsFloat('Quantity');
                                                                  mpomocprice:=0;


                                                                  //NxShowSimpleMessage('cena' + (copy(trim(mvalue.Strings[2]),1,AnsiPos(' ', trim(mvalue.Strings[2])))),nil);
                                                                  mpomocprice:= NxIBStrToFloat(copy(trim(mvalue.Strings[2]),1,AnsiPos(' ', trim(mvalue.Strings[2]))))/mRow.getFieldValueAsFloat('Quantity');;

                                                                  //mpomocprice:=1;
                                                                  mRow.SetFieldValueAsFloat('Unitprice',mpomocprice) ;
                                                                  mRow.SetFieldValueAsString('Division_ID',mDivision_ID); //text bude  ...

                                                                  if not NxIsEmptyOID((mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))) then begin
                                                                             mBustransaction_ID:=(mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'));
                                                                             mRow.SetFieldValueAsString('BusTransaction_id',mBustransaction_ID );
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



                                                     end;






                                           // end;



                                        end;}
                              end;
                            //  NxShowSimpleMessage(inttostr(mImportFile.count),nil) ;






  result:=mhead;
end;

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
  mBO_PohybSarze:TNxCustomBusinessObject;
  mstring:string;
  mvalue:tstringlist;
  mBoolean:Boolean;
  mStoreBatch_ID:string;
  gs01,gs10,gs17:string;
begin

//NxShowSimpleMessage('Aa',nil);
    if not FileExists(AFileName) then begin
      Result := False;
      exit;
    end;
    mlist:=tstringlist.create;
    try
           if ((index=2) or (index= 3) or (index= 6)) then begin
               mOLE := GetAbraOLEApplication;
               mroll := mOLE.GetAgenda('OFZO2K155FDL3CL100C4RHECN0');
               _ss := mOLE.CreateStrings;
               mstore_ID:= mroll.SingleSelectFromSelected2(_ss, 'Vyber sklad', '');
          //NxShowSimpleMessage('bb',nil);

               mImportFile:=TStringList.create;
               mImportFile.LoadFromFile(AFileName);

               for i:=0 to mImportFile.Count-1 do begin   // načtení souboru
                      //ProgressSetPos(1+NxFloor((i/mImportFile.Count)*99), inttostr(i) +' z '+inttostr(mImportFile.Count));
                      mstringline:= mImportFile.strings[i];
                      if trim(mstringline)<>'' then begin
                          mstring:='';
                          if index=6 then begin
                              mstring:= DecodeBatches(TDynSiteForm(msite).BaseObjectSpace,mstringline);
                          end else begin
                              mvalue:=tstringlist;
                                                     try
                                                        mvalue:= fnParsevalue(GS_DecodeDatamatrix(msite.BaseObjectSpace,mstringline),';');
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
                                                     mvalue:= fnParsevalue(ID_from_GS_DecodeDatamatrix(msite.BaseObjectSpace,gs01,gs10,mquantity),';') ;
                                                     if mvalue.count>1 then begin
                                                          if mvalue.Strings[0]='0000000000' then mBatch_ID:='' else mBatch_ID:=mvalue.Strings[0];
                                                          if mvalue.Strings[1]='0000000000' then mStoreCard_ID:='' else mStoreCard_ID:=mvalue.Strings[1];
                                                          if NxIBStrToFloat(mvalue.Strings[2])=0 then mquantity:=1 else mquantity:=NxIBStrToFloat(mvalue.Strings[2]);
                                                          mstring:='0000000000' + ';' +  mStorecard_ID + ';' + mStoreBatch_ID+';' + NxFloatToIBStr(mQuantity);
                                                     end else begin
                                                          mstring:='';
                                                     end;

                                                     finally
                                                         mvalue.free;
                                                     end;


                          end;
                         if (mstring)<>'' then begin
                               mlist.add(mstring)  ;
                         end else begin
                              //if i<>0 then begin
                              //    //mlist.add('XXXXX' + mstringline)  ;
                              //    NxShowSimpleMessage('pro položku ' + mstringline + ' nebylo možné dohledat šarži',nil);
                              ///end;
                              mBoolean:=InputQuery('Nebylo možé dekodovat záznam' , mstringline,mstringline);
                                   if mBoolean then begin
                                        //mstring:= DatamatrixDecodeBatches(TDynSiteForm(msite).BaseObjectSpace,mstringline);



                                                     mvalue:=tstringlist;
                                                     try
                                                        mvalue:= fnParsevalue(GS_DecodeDatamatrix(msite.BaseObjectSpace,mstringline),';');
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
                                                     mvalue:= fnParsevalue(ID_from_GS_DecodeDatamatrix(msite.BaseObjectSpace,gs01,gs10,mquantity),';') ;
                                                     if mvalue.count>1 then begin
                                                          if mvalue.Strings[0]='0000000000' then mBatch_ID:='' else mBatch_ID:=mvalue.Strings[0];
                                                          if mvalue.Strings[1]='0000000000' then mStoreCard_ID:='' else mStoreCard_ID:=mvalue.Strings[1];
                                                          if NxIBStrToFloat(mvalue.Strings[2])=0 then mquantity:=1 else mquantity:=NxIBStrToFloat(mvalue.Strings[2]);
                                                          mstring:='0000000000' + ';' +  mStorecard_ID + ';' + mStoreBatch_ID+';' + NxFloatToIBStr(mQuantity);
                                                     end else begin
                                                          mstring:='';
                                                     end;

                                                     finally
                                                         mvalue.free;
                                                     end;

                                        if (mstring)<>'' then begin
                                              mlist.add(mstring)  ;
                                        end else begin
                                            NxShowSimpleMessage('Ani oprava se nepodařila , prosím zadejte ručně',nil);
                                        end;
                                   end else begin
                                        NxShowSimpleMessage('Položka bude při importu ignorována , prosím doplňte ručn',nil);
                                   end;
                          end;
                      end;
               end;
           end;

            if index=5 then begin
              try
                  mXMLHead := TNxScriptingXMLWrapper.Create;
                  mXMLHead.loadFromFile(AFileName);
                  ProgressInit(msite, 'Načtení souboru ' + '', 100);
                  for i := 0 to mXMLHead.getElementsCountInArray('Doc.Row') - 1 do begin
                      mr:=TStringList.create;
                         try
                             os.SQLSelect('Select id from stores where code=' + quotedstr(mXMLHead.getElementAsString('Doc.Row[' + inttostr(i) +'].Storecode')),mr);
                             if mr.count>0 then begin
                                   mstore_id:=mr.strings[0];
                             end;
                         finally
                            mr.free;
                         end;

                          mr:=TStringList.create;
                         try
                             os.SQLSelect('Select id from Storecards where EAN=' + quotedstr(mXMLHead.getElementAsString('Doc.Row[' + inttostr(i) +'].Ean')),mr);
                             mStoreCard_ID:='';
                             if mr.count>0 then begin
                                   mStoreCard_ID:=mr.strings[0];
                             end else begin
                                 mStoreCard_ID:='3NQ1000101';
                                 mError:=true;
                             end;
                         finally
                            mr.free;
                         end;

                         for ii:=0 to (mXMLHead.getElementsCountInArray('Doc.Row[' + inttostr(i) +'].batch')) -1 do begin
                            mStoreBatch_ID:='';
                            mQuantity:=0;
                            mr:=TStringList.create;
                                 try
                                     os.SQLSelect('Select id from Storebatches where Name=' + quotedstr(mXMLHead.getElementAsString('Doc.Row[' + inttostr(i) +'].batch['+ inttostr(ii) +'].Name')),mr);
                                     if mr.count>0 then begin
                                           mStoreBatch_ID:=mr.strings[0];
                                     end else begin
                                         mError:=true;
                                     end;
                                 finally
                                    mr.free;
                                 end;
                            mQuantity:=NxIBStrToFloat(mXMLHead.getElementAsString('Doc.Row[' + inttostr(i) +'].batch['+ inttostr(ii) +'].quantity'));

                            mstring:='';
                            mstring:='0000000000' + ';' +  mStorecard_ID + ';' + mStoreBatch_ID+';' + NxFloatToIBStr(mQuantity);
                            if mstring<>'' then mlist.add(mstring)  ;
                         end;
                  end;


                  finally
                      ProgressDispose()   ;
                      mXMLHead.free;
                  end;
              END;    // INDEX 5 XML





          if index<> 6 then begin
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

                //NxShowSimpleMessage('cc',nil);
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
           end;
//NxShowSimpleMessage('dd',nil);



      mlist.Sort;

      NxShowSimpleMessage('počet položek' + inttostr(mlist.count) , nil);
 mHead := TNxHeaderBusinessObject(OS.CreateObject('01CPMINJW3DL342X01C0CX3FCC'));                                       //   dl         050I5SAOS3DL3ACU03KIU0CLP4
 if ((index=2) OR (index= 5) OR (index= 6)) then mBO_PohybSarze:=msite.BaseObjectSpace.CreateObject('SLARSB0H4CK4T32XPZTP33J3XS');
        try
                     mHead.New;
                     mHead.Prefill;
                              mHead.SetFieldValueAsString('DocQueue_ID', '1W20000101');                   // dl
                              if index<> 6 then begin
                                   mHead.SetFieldValueAsString('Firm_ID', mfirm_id);
                                   mHead.SetFieldValueAsString('FirmOffice_ID', mFirmOffice_id);
                              end;

                            mquantity:=0;
                             mBatchquantity:=0;
                            for i:=0 to mlist.count-1 do begin

                               mvalue:=tstringlist.create;
                               try

                                    Parsevalue(mlist.strings[i],';',mlist.strings[i],mvalue,4);


                                    //NxShowSimpleMessage('Položka ' + inttostr(i) , nil);

                                    if i=0 then begin                                   // první záznam



                                              mRow := mHead.Rows.AddNewObject;
                                                           mRow.Prefill;
                                                           mquantity:=NxIBStrToFloat(mvalue.Strings[3]);
                                                           mRow.SetFieldValueAsInteger('RowType',3);
                                                           mRow.SetFieldValueAsString('Store_ID',mstore_id);
                                                           mRow.SetFieldValueAsString('StoreCard_ID',mvalue.Strings[1]);
                                                           mRow.SetFieldValueAsstring('Division_ID','1N00000101');
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
                                                              if ((index=2) or (index=5) or (index=6)) then begin

                                                                              mBO_PohybSarze.new;
                                                                              mBO_PohybSarze.Prefill;
                                                                              mBatchquantity:= NxIBStrToFloat(mvalue.Strings[3]);
                                                                              mBO_PohybSarze.SetFieldValueAsstring('Code',mhead.OID);
                                                                              mBO_PohybSarze.SetFieldValueAsstring('X_Parent_ID',mRow.OID);
                                                                              mBO_PohybSarze.SetFieldValueAsstring('X_Firm_ID',mfirm_id);
                                                                              mBO_PohybSarze.SetFieldValueAsstring('X_Parent2_ID',mRow.GetFieldValueAsString('Storecard_ID'));
                                                                              //NxShowSimpleMessage (copy(mlist.Strings[i-1],23,10),nil);
                                                                              mBO_PohybSarze.SetFieldValueAsstring('X_Batches',mvalue.Strings[2]);
                                                                              mBO_PohybSarze.SetFieldValueAsstring('Name', copy(mRow.GetFieldValueAsString('Storecard_ID.name'),1,30));
                                                               end;

                                    end else begin   // následné záznamy
                                                 if copy(mlist.Strings[i],1,22)<>copy(mlist.Strings[i-1],1,22) then begin // novy pohyb sc
                                                        mRow.SetFieldValueAsFloat('Quantity',mquantity);   // uložení množství do řádku
                                                        if ((index=2) or (index=5) or (index=6)) then begin
                                                            mBO_PohybSarze.SetFieldValueAsfloat('X_quantity',mBatchquantity)  ;
                                                            if (mBO_PohybSarze.getFieldValueAsFloat('X_quantity')>0) and (not NxIsEmptyOID(mBO_PohybSarze.getFieldValueAsstring('X_Batches'))) then  mBO_PohybSarze.save;
                                                        end;


                                                        mRow := mHead.Rows.AddNewObject;
                                                           mRow.Prefill;     // nová skladová karta
                                                           mquantity:=NxIBStrToFloat(mvalue.Strings[3]);
                                                           mRow.SetFieldValueAsInteger('RowType',3);
                                                           mRow.SetFieldValueAsString('Store_ID',mstore_id);
                                                           mRow.SetFieldValueAsString('StoreCard_ID',mvalue.Strings[1]);
                                                           mRow.SetFieldValueAsstring('Division_ID','1N00000101');
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
                                                              if ((index=2) or (index=5) or (index=6)) then begin
                                                                              mBO_PohybSarze.new;
                                                                              mBO_PohybSarze.Prefill;
                                                                              mBatchquantity:= NxIBStrToFloat(mvalue.Strings[3]);
                                                                              mBO_PohybSarze.SetFieldValueAsstring('Code',mhead.OID);
                                                                              mBO_PohybSarze.SetFieldValueAsstring('X_Parent_ID',mRow.OID);
                                                                              mBO_PohybSarze.SetFieldValueAsstring('X_Firm_ID',mfirm_id);
                                                                              mBO_PohybSarze.SetFieldValueAsstring('X_Parent2_ID',mRow.GetFieldValueAsString('Storecard_ID'));
                                                                              mBO_PohybSarze.SetFieldValueAsstring('X_Batches',mvalue.Strings[2]);
                                                                              mBO_PohybSarze.SetFieldValueAsstring('Name', copy(mRow.GetFieldValueAsString('Storecard_ID.name'),1,30));
                                                              end;

                                                 end else begin  // stejná skladová karta
                                                            mquantity:=mquantity + NxIBStrToFloat(mvalue.Strings[3]);
                                                                  if copy(mlist.Strings[i],1,33)<>copy(mlist.Strings[i-1],1,33) then begin // rozdílná šarže
                                                                             if ((index=2) or (index=5) or (index=6)) then begin
                                                                                mBO_PohybSarze.SetFieldValueAsfloat('X_quantity',mBatchquantity)  ;
                                                                                //xxx
                                                                                if (mBO_PohybSarze.getFieldValueAsFloat('X_quantity')>0) and (not NxIsEmptyOID(mBO_PohybSarze.getFieldValueAsstring('X_Batches'))) then  mBO_PohybSarze.save;

                                                                                    mBO_PohybSarze.new;
                                                                                    mBO_PohybSarze.Prefill;
                                                                                    mBatchquantity:= NxIBStrToFloat(mvalue.Strings[3]);
                                                                                    mBO_PohybSarze.SetFieldValueAsstring('Code',mhead.OID);
                                                                                    mBO_PohybSarze.SetFieldValueAsstring('X_Parent_ID',mRow.OID);
                                                                                    mBO_PohybSarze.SetFieldValueAsstring('X_Firm_ID',mfirm_id);
                                                                                    mBO_PohybSarze.SetFieldValueAsstring('X_Parent2_ID',mRow.GetFieldValueAsString('Storecard_ID'));
                                                                                    mBO_PohybSarze.SetFieldValueAsstring('X_Batches',mvalue.Strings[2]);
                                                                                    mBO_PohybSarze.SetFieldValueAsstring('Name', copy(mRow.GetFieldValueAsString('Storecard_ID.name'),1,30));
                                                                                    mBatchquantity:=NxIBStrToFloat(mvalue.Strings[3]);
                                                                                end;
                                                                 end else begin   // stejná šarže
                                                                     if ((index=2) or (index=5) or (index=6)) then mBatchquantity:=mBatchquantity+NxIBStrToFloat(mvalue.Strings[3]);
                                                                 end;

                                                 end;


                                    end;
                               finally
                                   mvalue.free;
                               end;
                            end;

                            mRow.SetFieldValueAsFloat('Quantity',mquantity);   // uložení na konci dokladu
                            if ((index=2) or (index=5) or (index=6)) then begin
                                 mBO_PohybSarze.SetFieldValueAsfloat('X_quantity',mBatchquantity)  ;
                                 if (mBO_PohybSarze.getFieldValueAsFloat('X_quantity')>0) and (not NxIsEmptyOID(mBO_PohybSarze.getFieldValueAsstring('X_Batches'))) then  mBO_PohybSarze.save;
                            end;



                             //ProgressDispose()   ;
                                  //NxShowSimpleMessage('AAA',nil);
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
                                         mSite.ShowDynFormWithNewDocument('O2XDU14IW3DL342X01C0CX3FCC', mSite.SiteContext, mhead);             //                       B50I5SAOS3DL3ACU03KIU0CLP4

                                  end else begin
                                        //mhead.Save;
                                        //mSite.ShowDynFormWithNewDocument('O2XDU14IW3DL342X01C0CX3FCC', mSite.SiteContext, mhead);
                                        //NxShowSimpleMessage('Objednávka přijatá ' + mhead.GetFieldValueAsString('displayname')  ,nil);               //         B50I5SAOS3DL3ACU03KIU0CLP4
                                        mhead.save;
                                        //mSite.ShowDynFormWithNewDocument('O2XDU14IW3DL342X01C0CX3FCC', mSite.SiteContext, mhead);

                                  end;



            finally
                 mhead.free;
                if (index=2) or (index=6) then  mBO_PohybSarze.free;
            end;
    Result := True;
 finally
     mlist.free;
 end;
end;

function CorrectBatch(OS: TNxCustomObjectSpace;msite:TDynSiteForm;index:Integer;MBO:TNxCustomBusinessObject) : Boolean;
var
    i,ii,aa:integer;
    mMon:TNxCustomBusinessMonikerCollection;
    mr, mr1:tstringlist;
    mBO_OPDocRowBatches:TNxCustomBusinessObject;
    mOLE, mRoll,mAgenda, mOResult: Variant;
    mr2,mx:TStringList;
    mSelected ,_ss:Variant;
    mstring:string;
begin
     mBO_OPDocRowBatches:=os.CreateObject('SLARSB0H4CK4T32XPZTP33J3XS');
     try
     mMon := mbo.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('ROWS'));
                             for i := 0 to mMon.Count - 1 do begin

                                  mr:=TStringList.create ;
                                  try
                                     os.sqlselect('SELECT a.id FROM DefRollData A WHERE (A.Hidden = ' + quotedstr('N') + ' ) AND (A.CLSID = ' + quotedstr('SLARSB0H4CK4T32XPZTP33J3XS') + ' ) AND (Upper(A.X_Parent_ID)=' + quotedstr(mMon.BusinessObject[i].oid) + ')'
                                                  ,mr);
                                     if mr.count>0 then begin
                                         for ii:=0 to mr.count-1 do begin
                                              mBO_OPDocRowBatches.load(mr.Strings[ii],nil);
                                                  mr1:=tstringlist.create;
                                                  try
                                                               os.sqlselect('select sum(quantity) from StoreSubBatches where Store_ID='+ quotedstr(mMon.BusinessObject[i].GetFieldValueAsString('Store_ID')) + ' and StoreBatch_ID=' + QuotedStr(mBO_OPDocRowBatches.GetFieldValueAsString('X_Batches')),mr1) ;
                                                               //NxShowSimpleMessage(NxFloatToIBStr(mBO_OPDocRowBatches.GetFieldValueAsFloat('X_quantity')) + ' / ' + mr1.Strings[0] , nil);
                                                               if NxIBStrToFloat(mr1.Strings[0])<mBO_OPDocRowBatches.GetFieldValueAsFloat('X_quantity') then begin
                                                                   // není dostatek na šarži  = záměna
                                                                   //NxShowSimpleMessage(NxFloatToIBStr(mBO_OPDocRowBatches.GetFieldValueAsFloat('X_quantity')) + ' / ' + mr1.Strings[0] , nil);

                                                                   mOLE := GetAbraOLEApplication;
                                                                   mroll := mOLE.GetAgenda('A1TAS3OJNGU4HE5WCEMWHOQDFO');
                                                                   mSelected := mOLE.CreateStrings;
                                                                   mr2:=TStringList.create;
                                                                      try
                                                                            os.SQLSelect('SELECT ssb.id FROM StoreSubBatches SSB where ssb.Store_ID=' + quotedstr(mMon.BusinessObject[i].GetFieldValueAsString('Store_ID'))
                                                                                                      + ' and (ssb.StoreCard_ID='+ quotedstr(mBO_OPDocRowBatches.GetFieldValueAsString('X_Batches.StoreCard_ID')) + ') and (ssb.quantity>0)  and (ssb.id<>' + quotedstr(mBO_OPDocRowBatches.GetFieldValueAsString('X_Batches')) + ')' ,mr2);
                                                                             for aa := 0 to mr2.Count - 1 do begin
                                                                                 mSelected.Add(mr2.Strings[aa]);
                                                                             end;
                                                                          if mr2.count>0 then begin
                                                                                mstring:= mroll.SingleSelectFromSelected2(mSelected, 'Náhrada šarže: ' + mBO_OPDocRowBatches.GetFieldValueAsString('X_Batches.name') + ' - , ' +mBO_OPDocRowBatches.GetFieldValueAsString('X_Batches.Storecard_ID.displayname')  , '');

                                                                                if mstring<>'' then begin
                                                                                     mx:= tstringlist.create;
                                                                                     try
                                                                                            os.SQLSelect('SELECT ssb.StoreBatch_ID FROM StoreSubBatches SSB where ssb.ID=' + quotedstr(mstring) ,mx);
                                                                                               //NxShowSimpleMessage('náhrada šarže ' +mBO_OPDocRowBatches.GetFieldValueAsString('X_Batches') + ' za  ' + mx.Strings[0],nil);
                                                                                                 mBO_OPDocRowBatches.setFieldValueAsString('X_Batches',mx.Strings[0]) ;
                                                                                                 mBO_OPDocRowBatches.save;
                                                                                     finally
                                                                                          mx.free;
                                                                                     end;
                                                                                end;
                                                                          end else begin
                                                                                 NxShowSimpleMessage('Pro položku ' +mBO_OPDocRowBatches.GetFieldValueAsString('X_Batches.Storecard_ID.displayname') + ' nejsou na skladě k dispozici žádné šarže-',nil);
                                                                          end;
                                                                      finally
                                                                          mr2.free;
                                                                      end;




                                                               end else begin
                                                                   // je dostatek pro šarži
                                                               end;


                                                  finally
                                                      mr1.free;
                                                  end;
//                                              NxShowSimpleMessage( mBO_OPDocRowBatches.OID,nil);
                                              // kontrola , zda šarže je možná
                                         end;

                                     end;

                                  finally
                                      mr.free;
                                  end;

                             end;
      finally
        mBO_OPDocRowBatches.free;
      end;
end;






procedure InsertDoc(Sender: TComponent;index:integer);
var
  mSite: TSiteForm;
  mControl: TControl;
  mDataset: TNxRowsObjectDataSet;
  mRow: TNxCustomBusinessObject;
  mvalue:TStringList;
  mStoreCard_ID, mBatch_ID,mstring,mInputString:string;
  mQuantity:double;
  mboolean:Boolean;
  mGRows:TMultiGrid;
  mList:TStringList;
  mfind,mFindBatch:boolean;
  mImportFile:tstringlist;
  mstringline:string;
  mMon: TNxCustomBusinessMonikerCollection;
  mStore_ID,mDivision_ID,mBusProject_id,mBusOrder_ID,mAdress_ID:string;
  mHead:TNxHeaderBusinessObject;
  mIDs_dDocument:string;
  mIRadku , mIKusu,mIsarzi:double;
  mr:tstringlist;
  mQuantityBatch:double;
  mBO_PohybSarze:TNxCustomBusinessObject;
  mi:integer;
  mpomocprice:double;
  mBProduct:boolean;
  mOLE, mRoll, mOResult: Variant;
  _ss:Variant;
  mfirm_id,mFirmOffice_id:string  ;
  zadej:string;
  mfilename:string;
  mdir,mfile:string;
  mFileList:tstringlist;
  mEU:string;
  gs01,gs10,gs17:string;
begin
    if ((index>1) and (index<>7) and (index<>8)) then begin
     if ((index<4) or (index=6)) then begin
        if PromptForFileName(mFileName, '*.csv', '', 'Soubory SP', '', False) then begin
                      mdir:=copy(mfilename,0,NxCharPosR('\',mfilename));
                      mFile:=copy(mfilename,1+NxCharPosR('\',mfilename),Length(mfilename));
        end;
        ImportFilex2(TDynSiteForm(mSite).BaseObjectSpace, mfilename, mdir,mfile,TDynSiteForm(mSite),true,false,index);
     end;

     if index=4 then begin
        mBoolean:=CorrectBatch(TDynSiteForm(mSite).BaseObjectSpace,TDynSiteForm(mSite),index,TDynSiteForm(mSite).CurrentObject);
     end;

     if index=5 then begin
        if PromptForFileName(mFileName, '*.XML', '', 'Soubory SP', '', False) then begin
                      mdir:=copy(mfilename,0,NxCharPosR('\',mfilename));
                      mFile:=copy(mfilename,1+NxCharPosR('\',mfilename),Length(mfilename));
        end;
        ImportFilex2(TDynSiteForm(mSite).BaseObjectSpace, mfilename, mdir,mfile,TDynSiteForm(mSite),true,false,index);
     end;
    end else begin




    mIRadku:=0;
    mIKusu:=0;
    mIsarzi:=0;

    mAdress_ID:='';
    mSite := NxFindSiteForm(Sender);
    mHead:=TNxHeaderBusinessObject(msite.BaseObjectSpace.CreateObject('01CPMINJW3DL342X01C0CX3FCC'));
    mHead.new;
    mhead.Prefill;
    if (index=1)  then begin
        mHead.setFieldValueAsString('Docqueue_ID','2S00000101');
        mHead.setFieldValueAsString('Address_id','FSR4000101');
        mStore_ID:='1120000101';
     //   if index=8 then begin
     //             mHead.setFieldValueAsString('Firm_id','CJTK800101');
     //             mStore_ID:='1120000101';
                  //mDivision_ID:='1120000101';
     //   end;

    end;
    if index=7 then begin
        mHead.setFieldValueAsString('Docqueue_ID','2S00000101');
        mHead.setFieldValueAsString('Address_id','FSR4000101');
        mStore_ID:='1120000101';
    end;
    try
    if index=0 then begin
                  mHead.setFieldValueAsString('Docqueue_ID','1W20000101');
                  mHead.setFieldValueAsString('Address_id','FSR4000101');
                  mOLE := GetAbraOLEApplication;
                  mroll := mOLE.GetAgenda('OFZO2K155FDL3CL100C4RHECN0');
                  _ss := mOLE.CreateStrings;

                 mstore_ID:= mroll.SingleSelectFromSelected2(_ss, 'Vyber sklad', '');


                mr:=tstringlist.create;
                try
                     msite.BaseObjectSpace.SQLSelect('Select X_Firm_ID from Stores where id=' + quotedstr(mstore_id),mr);
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
                     msite.BaseObjectSpace.SQLSelect('Select id from FirmOffices where X_Store_ID=' + quotedstr(mstore_id) + ' and Parent_ID=' + quotedstr(mfirm_id) ,mr);
                     if mr.count>0 then begin
                         mFirmOffice_id:=mr.Strings[0];
                     end else begin
                         mFirmOffice_id:='';
                     end;
                finally
                   mr.free;
                end;
                mHead.SetFieldValueAsString('Firm_ID', mfirm_id);
                mHead.SetFieldValueAsString('FirmOffice_ID', mFirmOffice_id);
     end;






    mDivision_ID:='1N00000101';
    mBusProject_id:='';
    mBusOrder_ID:='';
    //NxShowSimpleMessage(inttostr(index),nil);





            If index=1 then begin
                    mBProduct:=false;
                    mHead:= FnParsePotvrzeniBTB(mSite.BaseObjectSpace,msite,mHead);




                 //NxShowSimpleMessage('Doklad importován ' + inttostr(mHead.Rows.Count) + ' řádků ', nil);
                 if  mhead.CLSID='01CPMINJW3DL342X01C0CX3FCC' then TDynSiteForm(mSite).ShowDynFormWithNewDocument('O2XDU14IW3DL342X01C0CX3FCC', mSite.SiteContext, mhead);    //op
            end;

          //  if index=8 then
          //          mBProduct:=false;
          //          mHead:= FnParsePotvBTBxlsPolozky(mSite.BaseObjectSpace,msite,mHead);
          //          if  mhead.CLSID='01CPMINJW3DL342X01C0CX3FCC' then TDynSiteForm(mSite).ShowDynFormWithNewDocument('O2XDU14IW3DL342X01C0CX3FCC', mSite.SiteContext, mhead);    //op

             If index=7 then begin
                    mBProduct:=false;
                    mHead:= FnParsePotvrzeniBTC(mSite.BaseObjectSpace,msite,mHead);




                 //NxShowSimpleMessage('Doklad importován ' + inttostr(mHead.Rows.Count) + ' řádků ', nil);
                 if  mhead.CLSID='01CPMINJW3DL342X01C0CX3FCC' then TDynSiteForm(mSite).ShowDynFormWithNewDocument('O2XDU14IW3DL342X01C0CX3FCC', mSite.SiteContext, mhead);    //op
            end;

            if index=0 then begin
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

                                                mvalue:=tstringlist;
                                                     try
                                                        mvalue:= fnParsevalue(GS_DecodeDatamatrix(msite.BaseObjectSpace,mstringline),';');
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
                                                     mvalue:= fnParsevalue(ID_from_GS_DecodeDatamatrix(msite.BaseObjectSpace,gs01,gs10,mquantity),';') ;
                                                     if mvalue.count>1 then begin
                                                          if mvalue.Strings[0]='0000000000' then mBatch_ID:='' else mBatch_ID:=mvalue.Strings[0];
                                                          if mvalue.Strings[1]='0000000000' then mStoreCard_ID:='' else mStoreCard_ID:=mvalue.Strings[1];
                                                          if NxIBStrToFloat(mvalue.Strings[2])=0 then mquantity:=1 else mquantity:=NxIBStrToFloat(mvalue.Strings[2]);
                                                          mstring:='0000000000' + ';' +  mStoreCard_ID + ';' + mBatch_ID+';' + NxFloatToIBStr(mQuantity);
                                                     end else begin
                                                          mstring:='';
                                                     end;

                                                     finally
                                                         mvalue.free;
                                                     end;

                                                if mstringline<>mstring then begin
                                                   Parsevaluerow(mstring, ';',mvalue);
                                                   //NxShowSimpleMessage(mstring + '   ' + inttostr(mvalue.count),nil);
                                                   if mvalue.Count>0 then mStoreCard_ID:=mvalue.Strings[1];
                                                   if mvalue.Count>1 then mBatch_ID:=mvalue.Strings[2];
                                                   if mvalue.Count>2 then  mQuantity:=NxIBStrToFloat(mvalue.Strings[3]) else mQuantity:=1;
                                                end;

                                              finally
                                                  // mvalue.free;
                                              end;

                                if mStoreCard_ID<>'' then begin
                                        mMon := mHead.GetLoadedCollectionMonikerForFieldCode(mHead.GetFieldCode('ROWS'));
                                        mFind:=False;
                                        for ii := 0 to mMon.Count - 1 do begin
                                                 if mMon.BusinessObject[ii].getFieldValueAsstring('Storecard_ID')= mStoreCard_ID then begin
                                                                          mMon.BusinessObject[ii].SetFieldValueAsFloat('Quantity',(mMon.BusinessObject[ii].GetFieldValueAsFloat('Quantity') + mQuantity));
                                                                           //mDataSet.FieldByName('Quantity').AsFloat:=(mDataSet.FieldByName('Quantity').AsFloat + mqauntity);
                                                                           mIRadku:=mIRadku+1;
                                                                           mIKusu:=mIKusu +mRow.getFieldValueAsFloat('Quantity');
                                                                           mFind:=True;

                                                                           if mBatch_ID<>'' then begin


                                                                                 mfindbatch:=false;


                                                                                 try
                                                                                     if ((mhead.CLSID<>'01CPMINJW3DL342X01C0CX3FCC') and (mhead.CLSID<>'CDMK5QAWZZDL342X01C0CX3FCC')) then begin
                                                                                         // skladový doklad

                                                                                     end;
                                                                                     if (mhead.CLSID='01CPMINJW3DL342X01C0CX3FCC') then begin
                                                                                          // OP
                                                                                           mr:= tstringlist.create;
                                                                                             try
                                                                                                 msite.BaseObjectSpace.SQLSelect('Select a.id,a.X_quantity from DefRollData A WHERE A.CLSID = ' + quotedstr('SLARSB0H4CK4T32XPZTP33J3XS') +
                                                                                                        ' AND (A.X_parent_id =' + QuotedStr(mMon.BusinessObject[ii].OID) + ') AND  (A.X_Batches =' + QuotedStr(mBatch_ID) + ')' ,mr);
                                                                                                        if mr.count>0 then begin
                                                                                                              mfindbatch:=true;
                                                                                                              mQuantityBatch:=NxIBStrToFloat(trim(copy(mr.Strings[0],12,20))) + mQuantity;
                                                                                                              mi:=msite.BaseObjectSpace.SQLExecute('update DefRollData set X_quantity=' + NxFloatToIBStr(mQuantityBatch) +  ' WHERE CLSID = ' + quotedstr('SLARSB0H4CK4T32XPZTP33J3XS') +
                                                                                                                  ' AND (id =' + QuotedStr(copy(mr.strings[0],1,10)) + ')') ;
                                                                                                        end else begin
                                                                                                              mBO_PohybSarze:=msite.BaseObjectSpace.CreateObject('SLARSB0H4CK4T32XPZTP33J3XS');
                                                                                                                     try
                                                                                                                            mBO_PohybSarze.new;
                                                                                                                            mBO_PohybSarze.Prefill;
                                                                                                                            mBO_PohybSarze.SetFieldValueAsFloat('X_quantity',mQuantity);
                                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('Code',mHead.OID);
                                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Parent_ID',mMon.BusinessObject[ii].OID);
                                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Firm_ID',mHead.GetFieldValueAsString('Firm_ID'));
                                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Parent2_ID',mStoreCard_ID);
                                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Batches',mBatch_ID);
                                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('Name',
                                                                                                                            copy(mMon.BusinessObject[ii].GetFieldValueAsString('Storecard_ID.name'),1,40));
                                                                                                                            //mBO_PohybSarze.SetFieldValueAsstring('Code',mMon.BusinessObject[ii].GetFieldValueAsString('Storecard_ID.Code'));
                                                                                                                             if mBO_PohybSarze.GetFieldValueAsstring('X_Batches.NAme')<>'0' then mBO_PohybSarze.save;
                                                                                                                     finally
                                                                                                                         mBO_PohybSarze.free;
                                                                                                                     end;
                                                                                                        end;
                                                                                              finally
                                                                                                  mr.free;
                                                                                              end;
                                                                                     end;
                                                                                     if (mhead.CLSID='CDMK5QAWZZDL342X01C0CX3FCC') then begin
                                                                                          // OV
                                                                                          mr:= tstringlist.create;
                                                                                             try
                                                                                                 msite.BaseObjectSpace.SQLSelect('Select a.id,a.X_quantity from DefRollData A WHERE A.CLSID = ' + quotedstr('EC2R2HSFK5UOZ5MYVJWJOHUC4S') +
                                                                                                        ' AND (A.X_parent_id =' + QuotedStr(mMon.BusinessObject[ii].OID) + ') AND  (A.X_Batches =' + QuotedStr(mBatch_ID) + ')' ,mr);
                                                                                                        if mr.count>0 then begin
                                                                                                              mfindbatch:=true;
                                                                                                              mQuantityBatch:=NxIBStrToFloat(trim(copy(mr.Strings[0],12,20))) + mQuantity;
                                                                                                              mi:=msite.BaseObjectSpace.SQLExecute('update DefRollData set X_quantity=' + NxFloatToIBStr(mQuantityBatch) +  ' WHERE CLSID = ' + quotedstr('EC2R2HSFK5UOZ5MYVJWJOHUC4S') +
                                                                                                                  ' AND (id =' + QuotedStr(copy(mr.strings[0],1,10)) + ')') ;
                                                                                                        end else begin
                                                                                                              mBO_PohybSarze:=msite.BaseObjectSpace.CreateObject('EC2R2HSFK5UOZ5MYVJWJOHUC4S');
                                                                                                                     try
                                                                                                                            mBO_PohybSarze.new;
                                                                                                                            mBO_PohybSarze.Prefill;
                                                                                                                            mBO_PohybSarze.SetFieldValueAsFloat('X_quantity',mQuantity);
                                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('Code',mHead.OID);
                                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Parent_ID',mMon.BusinessObject[ii].OID);
                                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Firm_ID',mHead.GetFieldValueAsString('Firm_ID'));
                                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Parent2_ID',mStoreCard_ID);
                                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('X_Batches',mBatch_ID);
                                                                                                                            mBO_PohybSarze.SetFieldValueAsstring('Name',
                                                                                                                            copy(mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.name'),1,40));
                                                                                                                            //mBO_PohybSarze.SetFieldValueAsstring('Code',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.Code'));
                                                                                                                             if mBO_PohybSarze.GetFieldValueAsstring('X_Batches.Name')<>'0' then mBO_PohybSarze.save;
                                                                                                                     finally
                                                                                                                         mBO_PohybSarze.free;
                                                                                                                     end;
                                                                                                        end;
                                                                                              finally
                                                                                                  mr.free;
                                                                                              end;

                                                                                     end;
                                                                                 finally

                                                                                 end;
                                                                  end;

                                                  end;
                                        end;
                                        if not mFind then begin
                                                      mRow := mHead.Rows.AddNewObject;
                                                      mRow.Prefill;
                                                      //mRow.SetFieldValueAsInteger('PosIndex',i);
                                                      mRow.SetFieldValueAsInteger('RowType',3);
                                                      mRow.SetFieldValueAsString('Store_ID',mstore_id);
                                                      mRow.SetFieldValueAsString('Storecard_ID',mStoreCard_ID);
                                                      mRow.SetFieldValueAsFloat('Quantity', mQuantity);
                                                      mIRadku:=mIRadku+1;
                                                      mIKusu:=mIKusu +mRow.getFieldValueAsFloat('Quantity');
                                                       //text bude  ...

                                                      if not NxIsEmptyOID((mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))) then begin
                                                                 mBustransaction_ID:=(mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'));
                                                                 mRow.SetFieldValueAsString('BusTransaction_id',mBustransaction_ID );
                                                      end;
                                                     {        //MASA zakomentováno 23.12.2025
                                                        mRow.SetFieldValueAsString('Division_ID',mDivision_ID);
                                                        mBusOrder_ID:=GetBusOrder_ID(mRow);
                                                        mRow.SetFieldValueAsString('BusOrder_id',mBusOrder_ID);
                                                        mBusProject_ID:=GetProject_ID(mRow);
                                                        mRow.SetFieldValueAsString('BusProject_id',mBusProject_ID);
                                                      end; }



                                                      if ((mhead.CLSID='01CPMINJW3DL342X01C0CX3FCC') or (mhead.CLSID='CDMK5QAWZZDL342X01C0CX3FCC')) then begin
                                                          if (mhead.CLSID='01CPMINJW3DL342X01C0CX3FCC') then mBO_PohybSarze:=msite.BaseObjectSpace.CreateObject('SLARSB0H4CK4T32XPZTP33J3XS');
                                                          if (mhead.CLSID='CDMK5QAWZZDL342X01C0CX3FCC') then mBO_PohybSarze:=msite.BaseObjectSpace.CreateObject('EC2R2HSFK5UOZ5MYVJWJOHUC4S');
                                                                                                               try
                                                                                                                      mBO_PohybSarze.new;
                                                                                                                      mBO_PohybSarze.Prefill;
                                                                                                                      mBO_PohybSarze.SetFieldValueAsFloat('X_quantity',mQuantity);

                                                                                                                      mBO_PohybSarze.SetFieldValueAsstring('Code',mHead.OID);
                                                                                                                      mBO_PohybSarze.SetFieldValueAsstring('X_Parent_ID',mRow.OID);
                                                                                                                      mBO_PohybSarze.SetFieldValueAsstring('X_Firm_ID',mHead.GetFieldValueAsString('Firm_ID'));
                                                                                                                      mBO_PohybSarze.SetFieldValueAsstring('X_Parent2_ID',mStoreCard_ID);
                                                                                                                      mBO_PohybSarze.SetFieldValueAsstring('X_Batches',mBatch_ID);
                                                                                                                      mBO_PohybSarze.SetFieldValueAsstring('Name',
                                                                                                                      copy(mRow.GetFieldValueAsString('Storecard_ID.name'),1,40));
                                                                                                                      //mBO_PohybSarze.SetFieldValueAsstring('Code',mMon.BusinessObject[i].GetFieldValueAsString('Storecard_ID.Code'));

                                                                                                                      if mBO_PohybSarze.GetFieldValueAsstring('X_Batches.Name')<>'0' then mBO_PohybSarze.save;

                                                                                                               finally
                                                                                                                   mBO_PohybSarze.free;
                                                                                                               end;
                                                       end;

                                        end;
                                end;


                                         end;
                          end;
            //if  mhead.CLSID='01CPMINJW3DL342X01C0CX3FCC' then TDynSiteForm(mSite).ShowDynFormWithNewDocument('O2XDU14IW3DL342X01C0CX3FCC', mSite.SiteContext, mhead);    //op

            end;

            If ((index=2) or (index=3) )then begin
                    mImportFile:=TStringList.create;
                              ParsevalueRow(BarCode_document(mSite,'05CPMINJW3DL342X01C0CX3FCC',0,0,720,960, 'Obsah potvrzení','Položky : ','','Pokračovat','',''), chr(10),mImportFile);
                              ProgressInit(msite, 'Načítání dat ' + '', 100);
                              for i:=0 to mImportFile.Count-1 do begin   // načtení souboru

                                        ProgressSetPos(1+NxFloor((i/mImportFile.Count)*99), inttostr(i) +' z '+inttostr(mImportFile.Count));
                                        mstringline:= mImportFile.strings[i];
                                        if trim(mstringline)<>'' then begin
                                            mvalue:=tstringlist.create;
                                               try
                                                   //NxShowSimpleMessage(mImportFile.strings[i],nil);
                                                   ParsevalueRow(mstringline, chr(09),mvalue);
                                                     if mvalue.count<6 then begin
                                                         for ii:=mvalue.count to 6 do begin
                                                             mvalue.Add('0');
                                                         end;
                                                     end;

                                                     if mvalue.count>=5 then begin
                                                            //NxShowSimpleMessage(mvalue.strings[0],nil);
                                                            //NxShowSimpleMessage(,nil);
                                                            //NxShowSimpleMessage(copy(trim(mvalue.Strings[2]),1,AnsiPos(' ',trim(mvalue.Strings[2]))),nil);
                                                           mstorecard_ID:='';
                                                           mstorecard_ID:=TDynSiteForm(msite).BaseObjectSpace.SQLSelectFirstAsString('Select id from storecards where EAN=' + quotedstr(mvalue.Strings[2]));


                                                           if mstorecard_ID<>'' then begin
                                                                  mfind:=false;
                                                                  if (index=2) and (trim(mvalue.Strings[4])<>'') and (trim(mvalue.Strings[4])<>'0') then mfind:=true ;
                                                                  if (index=3) and (trim(mvalue.Strings[5])<>'') and (trim(mvalue.Strings[5])<>'0') then mfind:=true ;

                                                                  if mfind then begin
                                                                                mRow := mHead.Rows.AddNewObject;
                                                                                mRow.Prefill;
                                                                                //mRow.SetFieldValueAsInteger('PosIndex',i);
                                                                                mRow.SetFieldValueAsInteger('RowType',3);
                                                                                mRow.SetFieldValueAsString('Store_ID',mstore_id);
                                                                                mRow.SetFieldValueAsString('Storecard_ID',mStoreCard_ID);

                                                                                //mRow.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(copy(trim(mvalue.Strings[1]),1,AnsiPos(' ',trim(mvalue.Strings[1]))))) ;
                                                                                // debug

                                                                                if index=2 then begin
                                                                                     mRow.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(trim(mvalue.Strings[4]))) ;
                                                                                end;
                                                                                if (index=3) and (NxIBStrToFloat(trim(mvalue.Strings[5]))>0) then begin
                                                                                      mRow.SetFieldValueAsFloat('Quantity',NxIBStrToFloat(trim(mvalue.Strings[5]))) ;
                                                                                end;
                                                                                mIRadku:=mIRadku+1;
                                                                                mIKusu:=mIKusu +mRow.getFieldValueAsFloat('Quantity');

                                                                                //mRow.SetFieldValueAsFloat('Unitprice',NxIBStrToFloat(copy(trim(mvalue.Strings[2]),1,AnsiPos(' ',trim(mvalue.Strings[2]))))/NxIBStrToFloat(copy(trim(mvalue.Strings[1]),1,AnsiPos(' ',trim(mvalue.Strings[1]))))) ;
                                                                                mRow.SetFieldValueAsString('Division_ID',mDivision_ID); //text bude  ...

                                                                                if not NxIsEmptyOID((mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'))) then begin
                                                                                           mBustransaction_ID:=(mRow.GetFieldValueAsString('StoreCard_id.X_BusTransaction_ID'));
                                                                                           mRow.SetFieldValueAsString('BusTransaction_id',mBustransaction_ID );
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
                                                           end;

                                                     end;


                                                finally
                                                    mvalue.free;
                                                end;
                                        end;
                              end;
              end;

                    ProgressDispose()   ;
             if (index<>1) and (index<>7) then begin
               if ((mIRadku>0) ) then begin
                           NxShowSimpleMessage('Import proběhl' + chr(10) +
                                               'naplněno ' + NxFloatToIBStr(mIRadku) + ' položek ' + chr(10) +
                                               'v poctu ' + NxFloatToIBStr(mIKusu) + ' jednotek ' ,nil);

                       if  mhead.CLSID='01CPMINJW3DL342X01C0CX3FCC' then TDynSiteForm(mSite).ShowDynFormWithNewDocument('O2XDU14IW3DL342X01C0CX3FCC', mSite.SiteContext, mhead);    //op
                       if  mhead.CLSID='CDMK5QAWZZDL342X01C0CX3FCC' then TDynSiteForm(mSite).ShowDynFormWithNewDocument('GF53HAH3WBDL3C5P00CA141B44', mSite.SiteContext, mhead);    // ov
                       if  mhead.CLSID='E03ZNUMDTCC4PDAUIEY1MBTJC0' then TDynSiteForm(mSite).ShowDynFormWithNewDocument('B10I5SAOS3DL3ACU03KIU0CLP4', mSite.SiteContext, mhead);    // PR
                       if  mhead.CLSID='050I5SAOS3DL3ACU03KIU0CLP4' then TDynSiteForm(mSite).ShowDynFormWithNewDocument('B50I5SAOS3DL3ACU03KIU0CLP4', mSite.SiteContext, mhead);    // DL
                       if  mhead.CLSID='0P0I5SAOS3DL3ACU03KIU0CLP4' then TDynSiteForm(mSite).ShowDynFormWithNewDocument('BD0I5SAOS3DL3ACU03KIU0CLP4', mSite.SiteContext, mhead);    // PRV
                end else begin
                     NxShowSimpleMessage('Nejsou žádné řádky k importu', nil);
                end;
                TDynSiteForm(mSite).ActiveDataSet.RefreshAndRestoreLastSelectedItem;
                mhead.free;
             end;
  finally

  end;

  end;

msite.Refresh;
end;





{
Přidání řádku do rozeditovaného dokladu
}
procedure InsertRow(Sender: TComponent;index:integer);
var
  mSite: TSiteForm;
  mControl: TControl;
  mDataset: TNxRowsObjectDataSet;
  mRow: TNxCustomBusinessObject;
  mvalue:TStringList;
  mStoreCard_ID, mBatch_ID,mstring,mInputString:string;
  mQuantity:double;
  mboolean:Boolean;
  mGRows:TMultiGrid;
  mList:TStringList;
  mfind:boolean;
  mImportFile:tstringlist;
  mstringline:string;
  mstore_ID:string;
  gs01,gs10,gs17:string;
  mBProduct:boolean;
  mhead:TNxCustomBusinessObject;
  mEU:string;
  mpomocprice,mIcena:double;
  mIProdukt:integer;
begin
  mbproduct:=false;
  try
    mSite := NxFindSiteForm(Sender);
    mControl:= mSite.FindChildControl('tabRows.grdRows');
    mDataset := TNxRowsObjectDataSet(TMultiGrid(mControl).DataSource.DataSet);
    mboolean:=True;
    mstore_ID:='2100000101';
    if Assigned(mDataset) then begin
                  if index=0  then begin

                     mhead:= TDynSiteForm(msite).CurrentObject;
                        mImportFile:=TStringList.create;
                              mImportFile:=fnParsevalue(BarCode_document(mSite,'05CPMINJW3DL342X01C0CX3FCC',0,0,720,960, 'Obsah potvrzení','Položky : ','','Pokračovat','',''), chr(10));
                              ProgressInit(msite, 'Načítání dat ' + '', 100);

                              for i:=0 to mImportFile.Count-1 do begin   // načtení souboru
                                        mvalue:=tstringlist.create;
                                        ProgressSetPos(1+NxFloor((i/mImportFile.Count)*99), inttostr(i) +' z '+inttostr(mImportFile.Count));
                                        mstringline:=  NxSearchReplace(mImportFile.strings[i],chr(39),'',[srCase,srAll]);
                                        try
                                                    if trim(mstringline)<>'' then begin

                                                        mvalue:=fnParsevalue(mstringline, chr(09));



                                                   if not mBproduct then begin
                                                       if mvalue.count>1 then begin
                                                              case trim(mvalue.Strings[0]) of
                                                                   'Order number:':
                                                                          begin
                                                                               //NxShowSimpleMessage(mvalue.Strings[1],nil);
                                                                               mHead.SetFieldValueAsString('ExternalNumber',(trim(NxSearchReplace(mvalue.strings[1],chr(39),'',[srCase,srAll]))));
                                                                               mHead.SetFieldValueAsInteger('X_VarSymbol', strtoint(trim(NxSearchReplace(mvalue.strings[1],chr(39),'',[srCase,srAll]))));
                                                                          end;
                                                                    'Objednávka č.:':
                                                                          begin
                                                                               //NxShowSimpleMessage(mvalue.Strings[1],nil);
                                                                               mHead.SetFieldValueAsString('ExternalNumber',(trim(NxSearchReplace(mvalue.strings[1],chr(39),'',[srCase,srAll]))));
                                                                               mHead.SetFieldValueAsInteger('X_VarSymbol', strtoint(trim(NxSearchReplace(mvalue.strings[1],chr(39),'',[srCase,srAll]))));
                                                                          end;

                                                                    'Order date:':
                                                                          begin
                                                                               mHead.SetFieldValueAsDateTime('Docdate$date', StrToDate(
                                                                               copy(mvalue.strings[1],9,2) + '.' +
                                                                               copy(mvalue.strings[1],6,2) + '.' +
                                                                               copy(mvalue.strings[1],1,4)
                                                                               ));
                                                                          end;
                                                                     'Objednáno:':
                                                                          begin
                                                                               mHead.SetFieldValueAsDateTime('Docdate$date', StrToDate(
                                                                               copy(mvalue.strings[1],9,2) + '.' +
                                                                               copy(mvalue.strings[1],6,2) + '.' +
                                                                               copy(mvalue.strings[1],1,4)
                                                                               ));
                                                                          end;
                                                                     'Order status:':
                                                                          begin
                                                                               if trim(mImportFile.strings[i+1])='Confirmed' then mHead.SetFieldValueAsBoolean('Confirmed',True) else mHead.SetFieldValueAsBoolean('Confirmed',False)  ;
                                                                          end;
                                                                    'Company:':
                                                                          begin
                                                                                mstring:='';
                                                                               mstring:=msite.BaseObjectSpace.SQLSelectFirstAsString('Select id from Firms where Name=' + quotedstr(trim(mvalue.strings[1])) + ' and hidden=' + quotedstr('N') + ' and firm_id is null');
                                                                               if mstring<>'' then begin
                                                                                    mHead.SetFieldValueAsstring('Firm_ID',mString);
                                                                                         if not NxIsEmptyOID(mHead.getFieldValueAsString('Firm_ID.Currency_ID')) then begin
                                                                                            mHead.SetFieldValueAsString('Currency_ID',mHead.getFieldValueAsString('Firm_ID.Currency_ID'));
                                                                                         end;

                                                                                       if UpperCase(mHead.getFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode'))='CZ' then begin
                                                                                               mHead.SetFieldValueAsInteger('TradeType',1);
                                                                                       end else begin
                                                                                          mEU:='';
                                                                                          mEU:= mSite.BaseObjectSpace.SQLSelectFirstAsString('Select id FROM Countries WHERE Hidden = ' + quotedstr('N') + '  AND X_EU_Member LIKE ' + quotedstr('A') + ' AND Code = ' + quotedstr(UpperCase(mHead.getFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode')))  );
                                                                                           if mEU<>'' then begin
                                                                                                  mHead.SetFieldValueAsInteger('TradeType',2);
                                                                                                  mHead.SetFieldValueAsstring('Country_ID',mEU);
                                                                                           end else begin
                                                                                                   mHead.SetFieldValueAsInteger('TradeType',3);
                                                                                                   mEU:= mSite.BaseObjectSpace.SQLSelectFirstAsString('Select id FROM Countries WHERE Hidden = ' + quotedstr('N') + ' AND Code = ' + quotedstr(UpperCase(mHead.getFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode')))  );
                                                                                                   mHead.SetFieldValueAsstring('Country_ID',mEU);
                                                                                           end;
                                                                                       end;
                                                                                      mstore_id:='1120000101';

                                                                               end;
                                                                             end;
                                                                          'Fakturační údaje:':
                                                                          begin
                                                                                mstring:='';
                                                                               mstring:=msite.BaseObjectSpace.SQLSelectFirstAsString('Select id from Firms where Name=' + quotedstr(trim(mvalue.strings[1])) + ' and hidden=' + quotedstr('N') + ' and firm_id is null');
                                                                               if mstring<>'' then begin
                                                                                    mHead.SetFieldValueAsstring('Firm_ID',mString);
                                                                                         if not NxIsEmptyOID(mHead.getFieldValueAsString('Firm_ID.Currency_ID')) then begin
                                                                                            mHead.SetFieldValueAsString('Currency_ID',mHead.getFieldValueAsString('Firm_ID.Currency_ID'));
                                                                                         end;

                                                                                       if UpperCase(mHead.getFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode'))='CZ' then begin
                                                                                               mHead.SetFieldValueAsInteger('TradeType',1);
                                                                                       end else begin
                                                                                          mEU:='';
                                                                                          mEU:= mSite.BaseObjectSpace.SQLSelectFirstAsString('Select id FROM Countries WHERE Hidden = ' + quotedstr('N') + '  AND X_EU_Member LIKE ' + quotedstr('A') + ' AND Code = ' + quotedstr(UpperCase(mHead.getFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode')))  );
                                                                                           if mEU<>'' then begin
                                                                                                  mHead.SetFieldValueAsInteger('TradeType',2);
                                                                                                  mHead.SetFieldValueAsstring('Country_ID',mEU);
                                                                                           end else begin
                                                                                                   mHead.SetFieldValueAsInteger('TradeType',3);
                                                                                                   mEU:= mSite.BaseObjectSpace.SQLSelectFirstAsString('Select id FROM Countries WHERE Hidden = ' + quotedstr('N') + ' AND Code = ' + quotedstr(UpperCase(mHead.getFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode')))  );
                                                                                                   mHead.SetFieldValueAsstring('Country_ID',mEU);
                                                                                           end;
                                                                                       end;
                                                                                      mstore_id:='1120000101';

                                                                               end;
                                                                          end;

                                                                        'Product name':
                                                                          begin
                                                                                mBproduct:=True;
                                                                          end;

                                                                          'Položky':
                                                                          begin
                                                                                mBproduct:=True;
                                                                          end;

                                                                        'Subtotal:':
                                                                          begin
                                                                              mBproduct:=False;
                                                                               mpomocprice:= NxIBStrToFloat(NxSearchReplace(copy(trim(mvalue.strings[1]),1,NxCharPosR(' ', trim(mvalue.strings[1]))),' ','',[srCase,srAll]));
                                                                               if Abs(mIcena-mpomocprice)<0.01 then begin
                                                                                          NxShowSimpleMessage('Cena po importu odpovídá ' + NxFloatToIBStr(mIcena),nil);
                                                                               end else begin
                                                                                          NxShowSimpleMessage('Nesprávná cena ' + NxFloatToIBStr(Abs(mIcena-mpomocprice)),nil);

                                                                               end;
                                                                          end;
                                                                          'Celkem:':
                                                                          begin
                                                                              mBproduct:=False;
                                                                               mpomocprice:= NxIBStrToFloat(NxSearchReplace(copy(trim(mvalue.strings[1]),1,NxCharPosR(' ', trim(mvalue.strings[1]))),' ','',[srCase,srAll]));
                                                                               if Abs(mIcena-mpomocprice)<0.01 then begin
                                                                                          NxShowSimpleMessage('Cena po importu odpovídá ' + NxFloatToIBStr(mIcena),nil);
                                                                               end else begin
                                                                                          NxShowSimpleMessage('Nesprávná cena ' + NxFloatToIBStr(Abs(mIcena-mpomocprice)),nil);

                                                                               end;
                                                                          end;
                                                                      'Shipping :':
                                                                          begin
                                                                                 mDataSet.DisableControls;
                                                                                              mRow := mDataSet.CreateBusinessObject;
                                                                                              mRow.Prefill;
                                                                                              mRow.SetFieldValueAsInteger('RowType',3);
                                                                                              //mRow.SetFieldValueAsInteger('PosIndex',1);
                                                                                              mRow.SetFieldValueAsString('Store_Id',mstore_id);
                                                                                              //mRow.SetFieldValueAsString('Division_ID','2100000101');
                                                                                              mRow.SetFieldValueAsString('Storecard_Id','3PC0000101');
                                                                                              mRow.SetFieldValueAsFloat('Quantity', 1) ;
                                                                                              mpomocprice:=0;
                                                                                              mpomocprice:= NxIBStrToFloat(copy(trim(mvalue.strings[1]),1,AnsiPos(' ', trim(trim(mvalue.strings[1])))));

                                                                                              mRow.SetFieldValueAsFloat('Unitprice', mpomocprice) ;
                                                                                              mRow.SetFieldValueAsString('Division_ID','1N00000101');


                                                                                               TDynSiteForm(mSite).ActiveDataSet.UpdateFields; //Aby se o změně dozvěděl hlavičkový dataset
                                                                                               mDataset.RefreshAndRestoreLastSelectedItem;
                                                                                               mDataSet.EnableControls;

                                                                          end;
                                                                          'Doprava :':
                                                                          begin
                                                                                 mDataSet.DisableControls;
                                                                                              mRow := mDataSet.CreateBusinessObject;
                                                                                              mRow.Prefill;
                                                                                              mRow.SetFieldValueAsInteger('RowType',3);
                                                                                              //mRow.SetFieldValueAsInteger('PosIndex',1);
                                                                                              mRow.SetFieldValueAsString('Store_Id',mstore_id);
                                                                                              //mRow.SetFieldValueAsString('Division_ID','2100000101');
                                                                                              mRow.SetFieldValueAsString('Storecard_Id','3PC0000101');
                                                                                              mRow.SetFieldValueAsFloat('Quantity', 1) ;
                                                                                              mpomocprice:=0;
                                                                                              mpomocprice:= NxIBStrToFloat(copy(trim(mvalue.strings[1]),1,AnsiPos(' ', trim(trim(mvalue.strings[1])))));

                                                                                              mRow.SetFieldValueAsFloat('Unitprice', mpomocprice) ;
                                                                                              mRow.SetFieldValueAsString('Division_ID','1N00000101');


                                                                                               TDynSiteForm(mSite).ActiveDataSet.UpdateFields; //Aby se o změně dozvěděl hlavičkový dataset
                                                                                               mDataset.RefreshAndRestoreLastSelectedItem;
                                                                                               mDataSet.EnableControls;

                                                                          end;

                                                                          'Order note':
                                                                          begin
                                                                               if i<>mImportFile.Count-1 then begin
                                                                                  mHead.SetFieldValueAsString('X_poznamka',(trim(NxSearchReplace(mvalue.strings[1],chr(39),'',[srCase,srAll]))));
                                                                               end;
                                                                          end;
                                                                          'Poznámka':
                                                                          begin
                                                                               if i<>mImportFile.Count-1 then begin
                                                                                  mHead.SetFieldValueAsString('X_poznamka',(trim(NxSearchReplace(mvalue.strings[1],chr(39),'',[srCase,srAll]))));
                                                                               end;
                                                                          end;
                                                              end;
                                                       end else begin
                                                              case trim(mstringline) of
                                                                   'Order number:':
                                                                          begin
                                                                               //NxShowSimpleMessage(mvalue.Strings[1],nil);
                                                                               mHead.SetFieldValueAsString('ExternalNumber',(trim(NxSearchReplace(mImportFile.strings[i+1],chr(39),'',[srCase,srAll]))));
                                                                               mHead.SetFieldValueAsInteger('X_VarSymbol', strtoint(trim(NxSearchReplace(mImportFile.strings[i+1],chr(39),'',[srCase,srAll]))));
                                                                          end;

                                                                          'Objednávka č.:':
                                                                          begin
                                                                               //NxShowSimpleMessage(mvalue.Strings[1],nil);
                                                                               mHead.SetFieldValueAsString('ExternalNumber',(trim(NxSearchReplace(mImportFile.strings[i+1],chr(39),'',[srCase,srAll]))));
                                                                               mHead.SetFieldValueAsInteger('X_VarSymbol', strtoint(trim(NxSearchReplace(mImportFile.strings[i+1],chr(39),'',[srCase,srAll]))));
                                                                          end;

                                                                    'Order date:':
                                                                          begin
                                                                               mHead.SetFieldValueAsDateTime('Docdate$date', StrToDate(
                                                                               copy(mImportFile.strings[i+1],9,2) + '.' +
                                                                               copy(mImportFile.strings[i+1],6,2) + '.' +
                                                                               copy(mImportFile.strings[i+1],1,4)
                                                                               ));

                                                                          end;

                                                                          'Objednáno:':
                                                                          begin
                                                                               mHead.SetFieldValueAsDateTime('Docdate$date', StrToDate(
                                                                               copy(mImportFile.strings[i+1],9,2) + '.' +
                                                                               copy(mImportFile.strings[i+1],6,2) + '.' +
                                                                               copy(mImportFile.strings[i+1],1,4)
                                                                               ));

                                                                          end;


                                                                    'Order status:':
                                                                          begin
                                                                               if trim(mImportFile.strings[i+1])='Confirmed' then mHead.SetFieldValueAsBoolean('Confirmed',True) else mHead.SetFieldValueAsBoolean('Confirmed',False)  ;
                                                                          end;

                                                                          'stav:':
                                                                          begin
                                                                               if trim(mImportFile.strings[i+1])='Confirmed' then mHead.SetFieldValueAsBoolean('Confirmed',True) else mHead.SetFieldValueAsBoolean('Confirmed',False)  ;
                                                                          end;

                                                                    'Company:':
                                                                          begin
                                                                                mstring:='';
                                                                               mstring:=msite.BaseObjectSpace.SQLSelectFirstAsString('Select id from Firms where Name=' + quotedstr(trim(mImportFile.strings[i+1])) + ' and hidden=' + quotedstr('N') + ' and firm_id is null');
                                                                               if mstring<>'' then begin
                                                                                    mHead.SetFieldValueAsstring('Firm_ID',mString);
                                                                                         if not NxIsEmptyOID(mHead.getFieldValueAsString('Firm_ID.Currency_ID')) then begin
                                                                                            mHead.SetFieldValueAsString('Currency_ID',mHead.getFieldValueAsString('Firm_ID.Currency_ID'));
                                                                                         end;

                                                                                       if UpperCase(mHead.getFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode'))='CZ' then begin
                                                                                               mHead.SetFieldValueAsInteger('TradeType',1);
                                                                                       end else begin
                                                                                          mEU:='';
                                                                                          mEU:= mSite.BaseObjectSpace.SQLSelectFirstAsString('Select id FROM Countries WHERE Hidden = ' + quotedstr('N') + '  AND X_EU_Member LIKE ' + quotedstr('A') + ' AND Code = ' + quotedstr(UpperCase(mHead.getFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode')))  );
                                                                                           if mEU<>'' then begin
                                                                                                  mHead.SetFieldValueAsInteger('TradeType',2);
                                                                                                  mHead.SetFieldValueAsstring('Country_ID',mEU);
                                                                                           end else begin
                                                                                                   mHead.SetFieldValueAsInteger('TradeType',3);
                                                                                                   mEU:= mSite.BaseObjectSpace.SQLSelectFirstAsString('Select id FROM Countries WHERE Hidden = ' + quotedstr('N') + ' AND Code = ' + quotedstr(UpperCase(mHead.getFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode')))  );
                                                                                                   mHead.SetFieldValueAsstring('Country_ID',mEU);
                                                                                           end;
                                                                                       end;
                                                                                      mstore_id:='1120000101';

                                                                               end;
                                                                          end;

                                                                          'Fakturační údaje:':
                                                                          begin
                                                                                mstring:='';
                                                                               mstring:=msite.BaseObjectSpace.SQLSelectFirstAsString('Select id from Firms where Name=' + quotedstr(trim(mImportFile.strings[i+1])) + ' and hidden=' + quotedstr('N') + ' and firm_id is null');
                                                                               if mstring<>'' then begin
                                                                                    mHead.SetFieldValueAsstring('Firm_ID',mString);
                                                                                         if not NxIsEmptyOID(mHead.getFieldValueAsString('Firm_ID.Currency_ID')) then begin
                                                                                            mHead.SetFieldValueAsString('Currency_ID',mHead.getFieldValueAsString('Firm_ID.Currency_ID'));
                                                                                         end;

                                                                                       if UpperCase(mHead.getFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode'))='CZ' then begin
                                                                                               mHead.SetFieldValueAsInteger('TradeType',1);
                                                                                       end else begin
                                                                                          mEU:='';
                                                                                          mEU:= mSite.BaseObjectSpace.SQLSelectFirstAsString('Select id FROM Countries WHERE Hidden = ' + quotedstr('N') + '  AND X_EU_Member LIKE ' + quotedstr('A') + ' AND Code = ' + quotedstr(UpperCase(mHead.getFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode')))  );
                                                                                           if mEU<>'' then begin
                                                                                                  mHead.SetFieldValueAsInteger('TradeType',2);
                                                                                                  mHead.SetFieldValueAsstring('Country_ID',mEU);
                                                                                           end else begin
                                                                                                   mHead.SetFieldValueAsInteger('TradeType',3);
                                                                                                   mEU:= mSite.BaseObjectSpace.SQLSelectFirstAsString('Select id FROM Countries WHERE Hidden = ' + quotedstr('N') + ' AND Code = ' + quotedstr(UpperCase(mHead.getFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode')))  );
                                                                                                   mHead.SetFieldValueAsstring('Country_ID',mEU);
                                                                                           end;
                                                                                       end;
                                                                                      mstore_id:='1120000101';

                                                                               end;
                                                                          end;

                                                                     'Price':
                                                                          begin
                                                                                mBproduct:=True;
                                                                                mIProdukt:= i+2;
                                                                          end;

                                                                      'Položky':
                                                                          begin
                                                                                mBproduct:=True;
                                                                                mIProdukt:= i+2;
                                                                          end;


                                                                      'Product name	Catalogue number	Quantity	Price:':
                                                                          begin
                                                                                mBproduct:=True;
                                                                                mIProdukt:= i+2;
                                                                          end;

                                                                     'Subtotal:':
                                                                          begin

                                                                               mpomocprice:= NxIBStrToFloat(NxSearchReplace(copy(trim(mImportFile.strings[i+1]),1,NxCharPosR(' ', trim(mImportFile.strings[i+1]))),' ','',[srCase,srAll]));
                                                                               if Abs(mIcena-mpomocprice)<0.01 then begin
                                                                                          NxShowSimpleMessage('Cena po importu odpovídá ' + NxFloatToIBStr(mIcena),nil);
                                                                               end else begin
                                                                                          NxShowSimpleMessage('Nesprávná cena ' + NxFloatToIBStr(Abs(mIcena-mpomocprice)),nil);

                                                                               end;
                                                                          end;

                                                                          'Celkem:':
                                                                          begin

                                                                               mpomocprice:= NxIBStrToFloat(NxSearchReplace(copy(trim(mImportFile.strings[i+1]),1,NxCharPosR(' ', trim(mImportFile.strings[i+1]))),' ','',[srCase,srAll]));
                                                                               if Abs(mIcena-mpomocprice)<0.01 then begin
                                                                                          NxShowSimpleMessage('Cena po importu odpovídá ' + NxFloatToIBStr(mIcena),nil);
                                                                               end else begin
                                                                                          NxShowSimpleMessage('Nesprávná cena ' + NxFloatToIBStr(Abs(mIcena-mpomocprice)),nil);

                                                                               end;
                                                                          end;

                                                                      'Shipping :':
                                                                          begin
                                                                                mDataSet.DisableControls;
                                                                                              mRow := mDataSet.CreateBusinessObject;
                                                                                              mRow.Prefill;
                                                                                              mRow.SetFieldValueAsInteger('RowType',3);
                                                                                              //mRow.SetFieldValueAsInteger('PosIndex',1);
                                                                                              mRow.SetFieldValueAsString('Store_Id',mstore_id);
                                                                                              //mRow.SetFieldValueAsString('Division_ID','2100000101');
                                                                                              mRow.SetFieldValueAsString('Storecard_Id','3PC0000101');
                                                                                              mRow.SetFieldValueAsFloat('Quantity', 1) ;
                                                                                              mpomocprice:=0;
                                                                                              mpomocprice:= NxIBStrToFloat(copy(trim(mImportFile.strings[i+1]),1,AnsiPos(' ', trim(trim(mImportFile.strings[i+1])))));

                                                                                              mRow.SetFieldValueAsFloat('Unitprice', mpomocprice) ;
                                                                                              mRow.SetFieldValueAsString('Division_ID','1N00000101');


                                                                                               TDynSiteForm(mSite).ActiveDataSet.UpdateFields; //Aby se o změně dozvěděl hlavičkový dataset
                                                                                               mDataset.RefreshAndRestoreLastSelectedItem;
                                                                                               mDataSet.EnableControls;


                                                                          end;

                                                                          'Doprava :':
                                                                          begin
                                                                                mDataSet.DisableControls;
                                                                                              mRow := mDataSet.CreateBusinessObject;
                                                                                              mRow.Prefill;
                                                                                              mRow.SetFieldValueAsInteger('RowType',3);
                                                                                              //mRow.SetFieldValueAsInteger('PosIndex',1);
                                                                                              mRow.SetFieldValueAsString('Store_Id',mstore_id);
                                                                                              //mRow.SetFieldValueAsString('Division_ID','2100000101');
                                                                                              mRow.SetFieldValueAsString('Storecard_Id','3PC0000101');
                                                                                              mRow.SetFieldValueAsFloat('Quantity', 1) ;
                                                                                              mpomocprice:=0;
                                                                                              mpomocprice:= NxIBStrToFloat(copy(trim(mImportFile.strings[i+1]),1,AnsiPos(' ', trim(trim(mImportFile.strings[i+1])))));

                                                                                              mRow.SetFieldValueAsFloat('Unitprice', mpomocprice) ;
                                                                                              mRow.SetFieldValueAsString('Division_ID','1N00000101');


                                                                                               TDynSiteForm(mSite).ActiveDataSet.UpdateFields; //Aby se o změně dozvěděl hlavičkový dataset
                                                                                               mDataset.RefreshAndRestoreLastSelectedItem;
                                                                                               mDataSet.EnableControls;


                                                                          end;

                                                                          'Order note':
                                                                          begin
                                                                               if i<>mImportFile.Count-1 then begin
                                                                                  mHead.SetFieldValueAsString('X_poznamka',(trim(NxSearchReplace(mImportFile.strings[i+1],chr(39),'',[srCase,srAll]))));
                                                                               end;
                                                                          end;
                                                                          'Poznamka':
                                                                          begin
                                                                               if i<>mImportFile.Count-1 then begin
                                                                                  mHead.SetFieldValueAsString('X_poznamka',(trim(NxSearchReplace(mImportFile.strings[i+1],chr(39),'',[srCase,srAll]))));
                                                                               end;
                                                                          end;

                                                              end;
                                                       end;

                                                   end else begin

                                                              if trim(mstringline)='Mezisoučet' then
                                                                          begin
                                                                                mBproduct:=False;
                                                                          end;


                                                               //NxShowSimpleMessage(mImportFile.strings[i],nil);
                                                                 if mvalue.count>=3 then begin
                                                                        //NxShowSimpleMessage(mvalue.strings[0],nil);
                                                                        //NxShowSimpleMessage(,nil);
                                                                        //NxShowSimpleMessage(copy(trim(mvalue.Strings[2]),1,AnsiPos(' ',trim(mvalue.Strings[2]))),nil);
                                                                       mstorecard_ID:='';
                                                                       mstorecard_ID:=TDynSiteForm(msite).BaseObjectSpace.SQLSelectFirstAsString('Select id from storecards where EAN=' + quotedstr(mvalue.Strings[0]));


                                                                       if mstorecard_ID<>'' then begin

                                                                              mDataSet.DisableControls;
                                                                                              mRow := mDataSet.CreateBusinessObject;
                                                                                              mRow.Prefill;
                                                                                              mRow.SetFieldValueAsInteger('RowType',3);
                                                                                              //mRow.SetFieldValueAsInteger('PosIndex',1);
                                                                                              mRow.SetFieldValueAsString('Store_Id','1120000101');
                                                                                              //mRow.SetFieldValueAsString('Division_ID','2100000101');
                                                                                              mRow.SetFieldValueAsString('Storecard_Id',mStoreCard_ID);
                                                                                              mRow.SetFieldValueAsFloat('Quantity', NxIBStrToFloat(copy(trim(mvalue.Strings[1]),1,AnsiPos(' ',trim(mvalue.Strings[1]))))) ;
                                                                                              mRow.SetFieldValueAsFloat('Unitprice', NxIBStrToFloat(copy(trim(mvalue.Strings[2]),1,AnsiPos(' ',trim(mvalue.Strings[2]))))/NxIBStrToFloat(copy(trim(mvalue.Strings[1]),1,AnsiPos(' ',trim(mvalue.Strings[1]))))) ;
                                                                                              mRow.SetFieldValueAsString('Division_ID','1N00000101');


                                                                                               TDynSiteForm(mSite).ActiveDataSet.UpdateFields; //Aby se o změně dozvěděl hlavičkový dataset
                                                                                               mDataset.RefreshAndRestoreLastSelectedItem;
                                                                                               mDataSet.EnableControls;
                                                                         end;
                                                                 if copy(trim(mImportFile.strings[i+1]),1,6)='Total:' then begin
                                                                     mBProduct:=False;
                                                                 end;

                                                                 end;
                                                           end


                                                    end;

                                        finally
                                            mvalue.free;
                                        end;
                              end;

                  // TDynSiteForm(msite).CurrentObject.setFieldValueAsString('X_Poznam_exp_ext','')    ;

                   end;




                  if index=1  then begin
                      while mboolean do begin
                          // vstup a idetifikace kodu
                             mStoreCard_ID:='';
                             mBatch_ID:='';
                             mQuantity:=0;
                             mInputString:='';
                             mvalue:=tstringlist.create;
                                try
                                          mboolean:=InputQuery('Identifikace ', 'Datamatrix:',mInputString) ;
                                          if mboolean then begin
                                              //  mstring:= DatamatrixDecodeBatches(TDynSiteForm(msite).BaseObjectSpace,mInputString);
                                                mvalue:=tstringlist;
                                                     try
                                                        mvalue:= fnParsevalue(GS_DecodeDatamatrix(msite.BaseObjectSpace,mInputString),';');
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
                                                     mvalue:= fnParsevalue(ID_from_GS_DecodeDatamatrix(msite.BaseObjectSpace,gs01,gs10,mquantity),';') ;
                                                     if mvalue.count>1 then begin
                                                          if mvalue.Strings[0]='0000000000' then mBatch_ID:='' else mBatch_ID:=mvalue.Strings[0];
                                                          if mvalue.Strings[1]='0000000000' then mStoreCard_ID:='' else mStoreCard_ID:=mvalue.Strings[1];
                                                          if NxIBStrToFloat(mvalue.Strings[2])=0 then mquantity:=1 else mquantity:=NxIBStrToFloat(mvalue.Strings[2]);
                                                          mstring:='0000000000' + ';' +  mStorecard_ID + ';' + mBatch_ID+';' + NxFloatToIBStr(mQuantity);
                                                     end else begin
                                                          mstring:='';
                                                     end;

                                                     finally
                                                         mvalue.free;
                                                     end;



                                                if mInputString<>mstring then begin
                                                    mvalue:=fnParsevalue(mstring,';');
                                                    mStoreCard_ID:=mvalue.Strings[1];
                                                    mBatch_ID:=mvalue.Strings[2];
                                                    mQuantity:=NxIBStrToFloat(mvalue.Strings[3]);
                                                end;
                                          end;

                                finally
                                     mvalue.free;
                                end;

                                if mStoreCard_ID<>'' then begin
                                                  if mDataSet.Active then begin
                                                              mDataSet.First;
                                                              mFind:=False;
                                                              while not mDataSet.Eof do begin
                                                                    //dohledání , zda již je položka
                                                                    if mDataSet.FieldByName('Storecard_ID').AsString= mStoreCard_ID then begin
                                                                          mdataset.CurrentObject.SetFieldValueAsFloat('Quantity',(mdataset.CurrentObject.getFieldValueAsFloat('Quantity') + mQuantity));
                                                                           //mDataSet.FieldByName('Quantity').AsFloat:=(mDataSet.FieldByName('Quantity').AsFloat + mqauntity);
                                                                           mFind:=True;
                                                                           TDynSiteForm(mSite).ActiveDataSet.UpdateFields;
                                                                           mDataset.RefreshAndRestoreLastSelectedItem;
                                                                    end;
                                                                    mDataSet.Next;

                                                              end;
                                                  end;

                                                              if not mFind then begin
                                                                            mDataSet.DisableControls;
                                                                            mRow := mDataSet.CreateBusinessObject;
                                                                            mRow.Prefill;
                                                                            mRow.SetFieldValueAsInteger('RowType',3);
                                                                            //mRow.SetFieldValueAsInteger('PosIndex',1);
                                                                            mRow.SetFieldValueAsString('Store_Id',mstore_ID);
                                                                            //mRow.SetFieldValueAsString('Division_ID','2100000101');



                                                                             mRow.SetFieldValueAsString('Storecard_Id',mStoreCard_ID);
                                                                             mRow.SetFieldValueAsFloat('Quantity', mQuantity);

                                                                             TDynSiteForm(mSite).ActiveDataSet.UpdateFields; //Aby se o změně dozvěděl hlavičkový dataset
                                                                             mDataset.RefreshAndRestoreLastSelectedItem;
                                                                             mDataSet.EnableControls;
                                                              end;
                              end;


                      end;


                   end;

    end;
  finally

  end;
end;

{
Vyvolává se po vytvoření instance formuláře.
}
procedure FormCreate_Hook(Self: TSiteForm);
var
  mMAction: TMultiAction;
begin
  //  if self.CompanyCache.GetUserID='SUPER00000' then begin
          mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Čtečka';
          mMAction.Caption := 'Doplnění řádků';
          mMAction.Items.Add('Natažení řádků z potvrzení eshop');
          mMAction.Items.Add('Datamatrix');
          mMAction.Category := 'tabDetail';
          mMAction.OnExecuteItem := @InsertRow;
 //   end;

  mMAction := Self.GetNewMultiAction;
          mMAction.ShowControl := True;
          mMAction.ShowMenuItem := True;
          mMAction.Hint := 'Čtečka';
          mMAction.Caption := 'Vytvoření dokladu';
          mMAction.Items.Add('Import z datamatrix ');
          mMAction.Items.Add('Import z potvrzení B2B');
          mMAction.Items.Add('Import OP spotřeba šarže ');
          mMAction.Items.Add('Import OP spotřeba EAN ');
          mMAction.Items.Add('Nahrad problémové EAN ');
          mMAction.Items.Add('Import spotřeby XML ');
          mMAction.Items.Add('Import inventury šarže,množství ');
          mMAction.Items.Add('Import z potvrzení B2C');
          mMAction.Items.Add('Import z potvrzení B2B jen položky XLS');


          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @InsertDoc;
end;



begin
end.