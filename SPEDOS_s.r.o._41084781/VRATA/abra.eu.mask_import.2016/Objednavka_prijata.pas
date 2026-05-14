uses 'abra.eu.mask_import.2016.lib';

procedure ZpracujSouborZFronty (OS: TNxCustomObjectSpace; var ProcessContinue: Boolean; Directory: string; FileName: string;msite:TDynSiteForm);
begin
  ProcessContinue := ImportFile2(OS, Directory + '\' + FileName,Directory,filename,msite,False,false);
end;




function ImportFile2(OS: TNxCustomObjectSpace; AFileName: string;directory: string;filename: string;msite:TDynSiteForm;rucne:boolean;chyba:boolean) : Boolean;
var
mID_Docqueue_iD,mID_Store_iD:string;
mObchodniPripad,mdivision_id:string;
mstore_id:string;
mBustransaction_ID:string;
mfind_string:string;
mr:tstringlist;
mBusOrder_ID:string;
mBusProject_ID,mFirm_id:string;
mStext:string;
begin

    if not FileExists(AFileName) then begin
      Result := False;
      exit;
    end;

    try
      mXMLHead := TNxScriptingXMLWrapper.Create;
        mXMLHead.loadFromFile(AFileName);





        //mDoklad := mXMLHead.getElementAsString('ABRADocument');

        //mXMLHead.getElementAsString('ABRADocument.Customer');

       mObchodniPripad:='';
       mdivision_id:='';

       mtoESL:=False;
       mID_odberatel:='';
       mID_dodavatel:='';
       mID_Docqueue:='';
       mID_BusOrder:='';
       mID_Division:='';
       mID_Country:='';
        mID_VatCountry:='';
       mID_Currency:='';
       mID_row:='';
       mexistuje:='';
       mTyp_obchodu:='';
       oprava:=false;
       mID_kost_symbol:='';
       mID_payment:='';
       mID_delivery:='';
       mCountryName:='';
       mstore_id:='';
       mBustransaction_ID:='';
       mBusOrder_ID:='';
       mBusProject_ID:='';


       mID_Docqueue_ID:='9100000101';
        mID_Division:='2000000101';


 //     mexistuje:=getIDfromfield(os,'ID','ReceivedOrders','ExternalNumber',mXMLHead.getElementAsString('ABRADocument.ExternalNumber'),'','');

//      mID_Division:=getIDfromfield(os,'ID','Divisions','Code',mXMLHead.getElementAsString('ABRADocument.Division'),'Hidden','N');
//      mID_Country:=getIDfromfield(os,'ID','Countries','Code',mXMLHead.getElementAsString('ABRADocument.CountryCode'),'Hidden','N');
      mfirm_id:=getIDfromfield(os,'ID','Firms','Name',mXMLHead.getElementAsString('AbraDocument.Supplier.Name'),'Hidden','N');

      mID_Currency:=getIDfromfield(os,'ID','Currencies','Code',mXMLHead.getElementAsString('ABRADocument.CurrencyCode'),'Hidden','N');


        mHead := TNxHeaderBusinessObject(OS.CreateObject('42HE04FZGJD13ACM03KIU0CLP4'));
        try
                      mHead.New;
                      mHead.Prefill;
                              mHead.SetFieldValueAsString('DocQueue_ID', mID_Docqueue_ID);
                              mhead.SetFieldValueAsString('Firm_ID',mfirm_id);
                              //mhead.SetFieldValueAsBoolean('PricesWithVAT',NxStrToBool(mXMLHead.getElementAsString('ABRADocument.PricesWithVAT')));
                              //mhead.SetFieldValueAsString('TransportationType_ID',mID_delivery);



                              mHead.SetFieldValueAsInteger('Tradetype',strtoint(mXMLHead.getElementAsString('ABRADocument.TradeType')));
                              mID_VATcountry:=getIDfromfield(os,'ID','Countries','Code',mXMLHead.getElementAsString('ABRADocument.CountryCode'),'Hidden','N');

                              if mID_VATCountry<>'' then mHead.SetFieldValueAsString('VATCountry_ID',mID_VATCountry) ;
                              if mID_Country<>'' then mHead.SetFieldValueAsString('Country_id', mID_Country);
                              mHead.SetFieldValueAsString('ExternalNumber',mXMLHead.getElementAsString('ABRADocument.ExternalNumber'));
                              mHead.SetFieldValueAsString('VarSymbol',mXMLHead.getElementAsString('ABRADocument.VarSymbol'));
                              mHead.SetFieldValueAsBoolean('VATDocument',True);
                              mHead.SetFieldValueAsString('Description', mXMLHead.getElementAsString('ABRADocument.Description'));
                              //mHead.SetFieldValueAsFloat('VATRounding', strtofloat(mXMLHead.getElementAsString('ABRADocument.VATRounding')));
                              //;
                              //mHead.SetFieldValueAsFloat('TotalRounding',strtofloat(mXMLHead.getElementAsString('ABRADocument.TotalRounding')));

                              mHead.SetFieldValueAsString('Currency_ID', mID_Currency);

                              mHead.SetFieldValueasdatetime('DueDate$date',StrToDate(mXMLHead.getElementAsString('ABRADocument.DueDate')));
                              mHead.SetFieldValueasdatetime('VATDate$date',StrToDate(mXMLHead.getElementAsString('ABRADocument.VATDate')));

                              if mXMLHead.getElementAsString('ABRADocument.IsReverseChargeDeclared')='A' then mHead.SetFieldValueasboolean('IsReverseChargeDeclared',True) else mHead.SetFieldValueasboolean('IsReverseChargeDeclared',false);










                             // if mID_payment<>'' then mhead.SetFieldValueAsString('PaymentType_ID',mID_payment);
                              //if mID_delivery<>'' then mhead.SetFieldValueAsString('TransportationType_ID',mID_delivery);





                              for i := 0 to mXMLHead.getElementsCountInArray('AbraDocument.Rows.Row') - 1 do begin
                                       mBusOrder_ID:=getIDfromfield(os,'ID','BusOrders','Code',mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].BusOrder_ID.BusOrder_code'),'Hidden','N');
                                       mBustransaction_ID:=getIDfromfield(os,'ID','BusTransactions','Code',mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Bustransaction_ID.BusTransaction_code'),'Hidden','N');
                                       mBusProject_ID:=getIDfromfield(os,'ID','BusProjects','Code',mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].BusProject_ID.BusProject_code'),'Hidden','N');



                                          mRow := mHead.Rows.AddNewObject;
                                             mRow.Prefill;
                                                    mRow.SetFieldValueAsInteger('PosIndex',strtoint(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Posindex'))+1);
                                                    mRow.SetFieldValueAsInteger('VATMode',strtoint(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].VATMode')));
                                                    mRow.SetFieldValueAsstring('DRCArticle_ID',mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].VATMode.DRCArticle_ID'));

                                                    //mRow.SetFieldValueAsInteger('RowType',3);
                                                    //mRow.SetFieldValueAsString('Store_ID',mstore_id);
                                                   if Trim(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].text'))='' then begin
                                                       mRow.SetFieldValueAsString('Text',mStext) ;
                                                    end else begin
                                                        mRow.SetFieldValueAsString('Text',mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].text')) ;
                                                        mStext:=mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].text');
                                                    end;
                                                    //mRow.SetFieldValueAsFloat('Quantity',StrToFloat(mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].Quantity'))); //text bude  ...
                                                    mRow.SetFieldValueAsString('Division_ID','2000000101'); //text bude  ...
                                                    //mRow.SetFieldValueAsstring('VATRate_ID ',mXMLHead.getElementAsstring('AbraDocument.Rows.Row['+inttostr(i)+'].Vatrate'));

                                                //    mRow.SetFieldValueAsfloat('VATRate',21.00);
                                                    mRow.SetFieldValueAsstring('VATRate_ID','02100X0000');

                                                    mRow.SetFieldValueAsFloat('TAmountWithoutVAT',NxIBStrToFloat('0'+mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].TAmountWithoutVAT'))); //text bude  ...
                                                    mRow.SetFieldValueAsFloat('TAmount',NxIBStrToFloat('0'+mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].TAmount'))); //text bude  ...

                                              mRow.SetFieldValueAsstring('BusProject_id',mBusProject_ID);
                                             mRow.SetFieldValueAsstring('BusOrder_id',mBusOrder_ID);
                                             mRow.SetFieldValueAsstring('BusTransaction_id',mBustransaction_ID);
                                             mRow.SetFieldValueAsstring('ExpenseType_ID','Z100000101');
                                  end;


                                //  mHead.SetFieldValueAsInteger('VATRounding',(-33554175)) ;
                                //  mHead.SetFieldValueAsInteger('TotalRounding',(-33554175)) ;




                                         mSite.ShowDynFormWithNewDocument('PPC2EX0BUJD13ACP03KIU0CLP4', mSite.SiteContext, mhead);

                              result:=nxcopyfile(AFileName,Directory + '\Zpracovane\' + FileName);
                              if result then begin
                                  DeleteFile(AFileName);
                                  if result then begin
                                         NxShowSimpleMessage('Soubor ' + afilename + ' byl přesunut do zpracovaných',nil);
                                  end;
                              end;

                finally        // existuje
              mhead.free;
              //mrow.free;
        end;    // existuje
     finally
      mXMLHead.Free;
     end;
    Result := True;


end;



begin
end.