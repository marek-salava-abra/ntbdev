uses 'abra.eu.mask_import_pay.pay',
     '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse';
//, 'EU.Aabra.Mask.Validace.lib';

const
    mFilter='*.xml';


   function ImportMollie(OS: TNxCustomObjectSpace; AFileName: string;directory: string;filename: string;msite:TDynSiteForm;rucne:boolean;chyba:boolean;index:Integer) : Boolean;
var

    mImportFile:TStringList;
    mFieldHead,mFieldConst,mFieldLabel,mFieldType,mFieldLenght,mfieldValue,mFieldTable,mFieldCLSID,mFieldField,mFieldCreate,mFieldBo:TStringList;
     mr,mList:TStringList;
    mbo,mrow:TNxCustomBusinessObject;
     mhead:TNxCustomBusinessObject;
    mMon:TNxCustomBusinessMonikerCollection;
    mline:string;
    mText:string;
    mdivision,mBusOrder, mBustransaction, mBusproject:string;
    mpocet:double;
    mcastka:double;
    msString:string;
    mBDialog:Boolean;
    ii:integer;
    mvarsymbol:string;
    mpoplatek:double;
    mDatum:double;
begin

    if not FileExists(AFileName) then begin   // soubor nenalezen
      Result := False;
      exit;
    end;

try
 mShowProgres:=true;
 mImportFile := TStringList.Create;
mImportFile.LoadFromFile(AFileName);

mpoplatek:=0;

mHead :=  TDynSiteForm(msite).BaseObjectSpace.CreateObject('O3SCO4S1BRD13FY1010DELDFKK');
mhead.new;
mhead.Prefill;
mhead.SetFieldValueAsString('Docqueue_ID','~000000703');
mhead.SetFieldValueAsString('BankAccount_ID','~000000101');



         if mShowProgres then ProgressInit(msite, 'Import ' + AFileName, 100);
         mMon := mHead.GetLoadedCollectionMonikerForFieldCode(mHead.GetFieldCode('ROWS'));

                                                if mImportFile.Count >1 then begin
                                                                                  ii := 1;

                                                                                   while ii < mImportFile.Count do begin

                                                                                           //     if copy(mImportFile.strings[ii],1,1)<>'' then begin

                                                                                      if mShowProgres then ProgressSetPos(1+NxFloor((ii/mImportFile.Count)*99), inttostr(ii) +' z '+inttostr(mImportFile.Count));
                                                                                                            mLine := mImportFile.strings[ii];
                                                                                                            //NxTokenToStrings(mLine, ';', mLineCols);


                                                                                                            //mLine :=NxSearchReplace(NxSearchReplace(mLine, '"', '', [srAll]), ';', '";"', [srAll]) +';';
                                                                                                              mLine := NxSearchReplace(mLine, chr(9), ',', [srAll]);
                                                                                                              mLine := NxSearchReplace(mLine, '"', '', [srAll]);
                                                                                                              mfieldValue:= TStringList.Create;
                                                                                                              try
                                                                                                                 mfieldValue:= fnParsevalue(mline,',');


                                                                                                                  if true then begin
                                                                                                                  //if (mfieldValue.strings[0])<>'' then begin
                                                                                                                          if NxIBStrToFloat(mfieldValue.strings[3])<>0 then begin
                                                                                                                              try
                                                                                                                                  mRow := mMon.AddNewObject;
                                                                                                                                     mRow.Prefill;


                                                                                                                              //NxShowSimpleMessage(msstring,nil);
                                                                                                                              if (mfieldValue.strings[0])<>'' then begin
                                                                                                                                    mdatum:=0;



                                                                                                                                            if NxIsNumeric(copy(mfieldValue.strings[0],7,4)) then begin
                                                                                                                                                mdatum:=NxEncodeDate(StrToInt(copy(mfieldValue.strings[0],7,4)),strtoint(copy(mfieldValue.strings[0],4,2)),strtoint(copy(mfieldValue.strings[0],1,2)));
                                                                                                                                            end else begin
                                                                                                                                                mdatum:=NxEncodeDate(StrToInt(copy(mfieldValue.strings[0],1,4)),strtoint(copy(mfieldValue.strings[0],6,2)),strtoint(copy(mfieldValue.strings[0],9,2)));
                                                                                                                                            end;
                                                                                                                              end;
                                                                                                                              mRow.SetFieldValueAsDateTime('DocDate$DATE',mdatum);

                                                                                                                                       mRow.SetFieldValueAsboolean('Credit',NxIBStrToFloat(mfieldValue.strings[3])>0);
                                                                                                                                      //mRow.SetFieldValueAsDateTime('DocDate$DATE',iExtractDate(mfieldValue.Strings[0]));
                                                                                                                                      mRow.SetFieldValueAsString('Text',copy((NxSearchReplace(mfieldValue.Strings[6], '"', '', [srAll])) + ' '+(NxSearchReplace(mfieldValue.Strings[7], '"', '', [srAll])) + ,1,35));
                                                                                                                                      if NxIsNumeric(copy(mRow.getFieldValueAsString('Text'),1,10)) then begin
                                                                                                                                            mRow.SetFieldValueAsString('VarSymbol',copy(mRow.getFieldValueAsString('Text'),1,10));
                                                                                                                                      end;
                                                                                                                                      mRow.SetFieldValueAsBoolean('IsMultiPaymentRow',false);


                                                                                                                                       //msString:= (NxSearchReplace(mfieldValue.Strings[12], '"', '', [srAll]));
                                                                                                                                       // msString:= (NxSearchReplace(msString, ' ', '', [srAll]));
                                                                                                                                       // msString:= (NxSearchReplace(msString, '+', '', [srAll]));

                                                                                                                                        mRow.SetFieldValueAsFloat('Amount', NxIBStrToFloat(mfieldValue.strings[3])) ;


                                                                                                                                   // mRow.SetFieldValueAsString('Division_ID', mMon.BusinessObject[i].getFieldValueAsString('Division_ID')) ;
                                                                                                                                   // mRow.SetFieldValueAsString('BusOrder_ID', mMon.BusinessObject[i].getFieldValueAsString('BusOrder_ID')) ;
                                                                                                                                   // mRow.SetFieldValueAsString('BusTransaction_ID', mMon.BusinessObject[i].getFieldValueAsString('BusTransaction_ID')) ;
                                                                                                                                   // mRow.SetFieldValueAsString('BusProject_ID', mMon.BusinessObject[i].getFieldValueAsString('BusProject_ID')) ;

                                                                                                                                               if NxIBStrToFloat(mRow.getFieldValueAsString('VarSymbol'))<>0 then begin
                                                                                                                                                     mr:=tstringlist.create;
                                                                                                                                                          try
                                                                                                                                                             msite.BaseObjectSpace.sqlselect('SELECT A.ID FROM IssuedDInvoices A WHERE A.VarSymbol= ' + quotedstr(mRow.getFieldValueAsString('VarSymbol')),mr);

                                                                                                                                                                    if mr.count=1 then begin
                                                                                                                                                                        mRow.SetFieldValueAsString('PDocumentType','10');
                                                                                                                                                                        mRow.SetFieldValueAsString('PDocument_ID',mr.Strings[0]);
                                                                                                                                                                        //mRow.SetFieldValueAsFloat('PAmount',mcastka);
                                                                                                                                                                    end;
                                                                                                                                                              finally   ;
                                                                                                                                                                  mr.free;
                                                                                                                                                              end;
                                                                                                                                                end;
                                                                                                                                      finally

                                                                                                                                      end;
                                                                                                                          end;
                                                                                                                  end;
                                                                                                              finally
                                                                                                                      mfieldValue.free;
                                                                                                              end;


                                                                                        Inc(ii, 1);
                                                                                      end;         //while

                  end;   // řádky dokladu
            if mShowProgres then ProgressDispose();
            beep;
 finally
     mImportFile.free;
 end;




            mhead.ClearValidateErrors;
                                  if Not mhead.Validate() then begin
                                        mList := TStringList.Create;
                                        try
                                           mhead.GetValidateErrors(mList);
                                           mText := mList.Text;
                                           NxToken(mText, '=');
                                           MessageDlg('Automaticky vytvořený doklad nelze uložit z těchto důvodů:' + #13#10 + mText,

                                           mtWarning, [mbOK], 0);
                                         finally
                                           mList.Free;
                                         end;
                                         mSite.ShowDynFormWithNewDocument('R1C2EX0BUJD13ACP03KIU0CLP4', mSite.SiteContext, mhead);

                                  end else begin


                                        mhead.Save;
                                         result:=nxcopyfile(filename,directory + '\Zpracovane\' + filename);

                                        if result then begin
                                            DeleteFile(filename);
                                            if rucne and result and chyba then begin
                                                   NxShowSimpleMessage('Soubor ' + filename + ' byl přesunut do zpracovaných',nil);
                                            end;
                                        end;
                                  end;

end;


function ImportNEWzasilkovna(OS: TNxCustomObjectSpace; AFileName: string;directory: string;filename: string;msite:TDynSiteForm;rucne:boolean;chyba:boolean;index:Integer) : Boolean;
var

    mImportFile:TStringList;
    mFieldHead,mFieldConst,mFieldLabel,mFieldType,mFieldLenght,mfieldValue,mFieldTable,mFieldCLSID,mFieldField,mFieldCreate,mFieldBo:TStringList;
     mr,mList:TStringList;
    mbo,mrow:TNxCustomBusinessObject;
     mhead:TNxCustomBusinessObject;
    mMon:TNxCustomBusinessMonikerCollection;
    mline:string;
    mText:string;
    mdivision,mBusOrder, mBustransaction, mBusproject:string;
    mpocet:double;
    mcastka:double;
    msString:string;
    mBDialog:Boolean;
    ii:integer;
    mvarsymbol:string;
    mpoplatek:double;
    mDatum:string;
begin

    // !!!!  Postaveno na CSV verze 9  !!!!

    if not FileExists(AFileName) then begin   // soubor nenalezen
      Result := False;
      exit;
    end;

try
  mShowProgres:=true;
  mImportFile := TStringList.Create;
  mImportFile.LoadFromFile(AFileName);

  mpoplatek:=0;

  mHead :=  TDynSiteForm(msite).BaseObjectSpace.CreateObject('O3SCO4S1BRD13FY1010DELDFKK');
  mhead.new;
  mhead.Prefill;
  mhead.SetFieldValueAsString('Docqueue_ID','27F1000101');
  mhead.SetFieldValueAsString('BankAccount_ID','2JJ0000101');


         if mShowProgres then ProgressInit(msite, 'Import ' + AFileName, 100);
         mMon := mHead.GetLoadedCollectionMonikerForFieldCode(mHead.GetFieldCode('ROWS'));

                              if mImportFile.Count >1 then begin
                                  ii := 1;
                                  while ii < mImportFile.Count do begin

                                    //     if copy(mImportFile.strings[ii],1,1)<>'' then begin
                                    if mShowProgres then ProgressSetPos(1+NxFloor((ii/mImportFile.Count)*99), inttostr(ii) +' z '+inttostr(mImportFile.Count));
                                          mLine := mImportFile.strings[ii];
                                          //NxTokenToStrings(mLine, ';', mLineCols);

                                          mLine :=NxSearchReplace(NxSearchReplace(mLine, '"', '', [srAll]), ';', '";"', [srAll]) +';';
                                          mLine := NxSearchReplace(mLine, chr(9), ';', [srAll]);

                                          mfieldValue:= TStringList.Create;
                                          try
                                               mfieldValue:= fnParsevalue(mline,';');

                                               msString:= (NxSearchReplace(mfieldValue.Strings[12], '"', '', [srAll]));
                                               msString:= (NxSearchReplace(msString, '+', '', [srAll]));
                                               msString:= (NxSearchReplace(msString, ' ', '', [srAll]));

                                               if Length(msstring)>6 then begin
                                                       //NxShowSimpleMessage(msstring,nil);
                                               end;

                                               mpoplatek:=mpoplatek + NxIBStrToFloat(NxSearchReplace(mfieldValue.Strings[10], '"', '', [srAll])) ;

                                               if NxIBStrToFloat(msString)<>0 then begin

                                                    //NxShowSimpleMessage(msstring,nil);

                                                    mRow := mMon.AddNewObject;
                                                    mRow.Prefill;

                                                    mdatum:='';
                                                    mdatum:=(NxSearchReplace(mfieldValue.Strings[3], '"', '', [srAll]));
                                                    if NxIsNumeric(copy(mdatum,7,4)) then begin
                                                        mRow.SetFieldValueAsDateTime('DocDate$DATE',NxEncodeDate(StrToInt(copy(mdatum,7,4)),strtoint(copy(mdatum,4,2)),strtoint(copy(mdatum,1,2))));
                                                    end else begin
                                                        mRow.SetFieldValueAsDateTime('DocDate$DATE',NxEncodeDate(StrToInt(copy(mdatum,1,4)),strtoint(copy(mdatum,6,2)),strtoint(copy(mdatum,9,2))));
                                                    end;

                                                    mRow.SetFieldValueAsboolean('Credit',mMon.BusinessObject[i].getFieldValueAsBoolean('Credit'));
                                                    //mRow.SetFieldValueAsDateTime('DocDate$DATE',iExtractDate(mfieldValue.Strings[0]));
                                                    mRow.SetFieldValueAsString('Text',copy((NxSearchReplace(mfieldValue.Strings[5], '"', '', [srAll])) + ' '+(NxSearchReplace(mfieldValue.Strings[6], '"', '', [srAll])) + ,1,35));


                                                    mvarsymbol:= NxFloatToIBStr(NxIBStrToFloat(NxSearchReplace(mfieldValue.Strings[4], '"', '', [srAll]))) ;
                                                    mRow.SetFieldValueAsString('VarSymbol',mvarsymbol);

                                                    mRow.SetFieldValueAsBoolean('IsMultiPaymentRow',false);


                                                    //msString:= (NxSearchReplace(mfieldValue.Strings[12], '"', '', [srAll]));
                                                    // msString:= (NxSearchReplace(msString, ' ', '', [srAll]));
                                                    // msString:= (NxSearchReplace(msString, '+', '', [srAll]));

                                                    mRow.SetFieldValueAsFloat('Amount', NxIBStrToFloat(msString)) ;

                                                    // mRow.SetFieldValueAsString('Division_ID', mMon.BusinessObject[i].getFieldValueAsString('Division_ID')) ;
                                                    // mRow.SetFieldValueAsString('BusOrder_ID', mMon.BusinessObject[i].getFieldValueAsString('BusOrder_ID')) ;
                                                    // mRow.SetFieldValueAsString('BusTransaction_ID', mMon.BusinessObject[i].getFieldValueAsString('BusTransaction_ID')) ;
                                                    // mRow.SetFieldValueAsString('BusProject_ID', mMon.BusinessObject[i].getFieldValueAsString('BusProject_ID')) ;

                                                     mr:=tstringlist.create;
                                                          try
                                                             msite.BaseObjectSpace.sqlselect('SELECT A.ID FROM IssuedDInvoices A WHERE A.VarSymbol= ' + quotedstr(mvarsymbol),mr);

                                                             if mr.count=1 then begin
                                                                 mRow.SetFieldValueAsString('PDocumentType','10');
                                                                 mRow.SetFieldValueAsString('PDocument_ID',mr.Strings[0]);
                                                                //mRow.SetFieldValueAsFloat('PAmount',mcastka);
                                                             end;
                                                          finally   ;
                                                              mr.free;
                                                          end;

                                                        end;
                                          finally
                                                      mfieldValue.free;
                                          end;


                                          Inc(ii, 1);
                                  end;         //while


                                  // poplatky
                                  if mpoplatek<>0 then begin
                                      mRow := mMon.AddNewObject;
                                      mRow.Prefill;
                                             mRow.SetFieldValueAsboolean('Credit',False);
                                            //mRow.SetFieldValueAsDateTime('DocDate$DATE',iExtractDate(mfieldValue.Strings[0]));
                                            mRow.SetFieldValueAsString('Text','poplatek');


                                            //mvarsymbol:= NxFloatToIBStr(NxIBStrToFloat(NxSearchReplace(mfieldValue.Strings[5], '"', '', [srAll]))) ;
                                            //mRow.SetFieldValueAsString('VarSymbol',mvarsymbol);

                                            mRow.SetFieldValueAsBoolean('IsMultiPaymentRow',false);


                                            // msString:= (NxSearchReplace(mfieldValue.Strings[12], '"', '', [srAll]));
                                            //  msString:= (NxSearchReplace(msString, ' ', '', [srAll]));
                                            //  msString:= (NxSearchReplace(msString, '+', '', [srAll]));
                                              mRow.SetFieldValueAsFloat('Amount', mpoplatek) ;

                                         // mRow.SetFieldValueAsString('Division_ID', mMon.BusinessObject[i].getFieldValueAsString('Division_ID')) ;
                                         // mRow.SetFieldValueAsString('BusOrder_ID', mMon.BusinessObject[i].getFieldValueAsString('BusOrder_ID')) ;
                                         // mRow.SetFieldValueAsString('BusTransaction_ID', mMon.BusinessObject[i].getFieldValueAsString('BusTransaction_ID')) ;
                                         // mRow.SetFieldValueAsString('BusProject_ID', mMon.BusinessObject[i].getFieldValueAsString('BusProject_ID')) ;

                                         //  mr:=tstringlist.create;
                                         //       try
                                         //          msite.BaseObjectSpace.sqlselect('SELECT A.ID FROM ReceivedInvoices A WHERE A.VarSymbol= ' + quotedstr(mvarsymbol),mr);
                                         //
                                         //                 if mr.count=1 then begin
                                         //                     mRow.SetFieldValueAsString('PDocumentType','10');
                                         //                     mRow.SetFieldValueAsString('PDocument_ID',mr.Strings[0]);
                                         //                     //mRow.SetFieldValueAsFloat('PAmount',mcastka);
                                         //                 end;
                                         //           finally   ;
                                         //               mr.free;
                                         //           end;

                                  end;
                  end;   // řádky dokladu
            if mShowProgres then ProgressDispose();
            beep;
 finally
     mImportFile.free;
 end;




            mhead.ClearValidateErrors;
                                  if Not mhead.Validate() then begin
                                        mList := TStringList.Create;
                                        try
                                           mhead.GetValidateErrors(mList);
                                           mText := mList.Text;
                                           NxToken(mText, '=');
                                           MessageDlg('Automaticky vytvořený doklad nelze uložit z těchto důvodů:' + #13#10 + mText,

                                           mtWarning, [mbOK], 0);
                                         finally
                                           mList.Free;
                                         end;
                                         mSite.ShowDynFormWithNewDocument('R1C2EX0BUJD13ACP03KIU0CLP4', mSite.SiteContext, mhead);

                                  end else begin


                                        mhead.Save;
                                         result:=nxcopyfile(filename,directory + '\Zpracovane\' + filename);

                                        if result then begin
                                            DeleteFile(filename);
                                            if rucne and result and chyba then begin
                                                   NxShowSimpleMessage('Soubor ' + filename + ' byl přesunut do zpracovaných',nil);
                                            end;
                                        end;
                                  end;

end;






{
Vyvolává se po provedení metody Show na dané agendě. Tato událost se volá i při přepínání agend.
}
procedure FormShow_Hook(Self: TSiteForm);
begin

end;

function ImportFileKBSmart(OS: TNxCustomObjectSpace; AFileName: string;directory: string;filename: string;msite:TDynSiteForm;rucne:boolean;chyba:boolean;index:Integer) : Boolean;
var

    mImportFile:TStringList;
    mFieldHead,mFieldConst,mFieldLabel,mFieldType,mFieldLenght,mfieldValue,mFieldTable,mFieldCLSID,mFieldField,mFieldCreate,mFieldBo:TStringList;
     mr,mList:TStringList;
    mbo,mrow:TNxCustomBusinessObject;
     mhead:TNxCustomBusinessObject;
    mMon:TNxCustomBusinessMonikerCollection;
    mline:string;
    mText:string;
    mdivision,mBusOrder, mBustransaction, mBusproject:string;
    mpocet:double;
    mcastka:double;
    msString:string;
    mBDialog:Boolean;
    ii:integer;
    mvarsymbol:string;
begin

    if not FileExists(AFileName) then begin   // soubor nenalezen
      Result := False;
      exit;
    end;

try
 mImportFile := TStringList.Create;
mImportFile.LoadFromFile(AFileName);

    if mShowProgres then ProgressInit(msite, 'Import ' + AFileName, 100);
mHead :=  TDynSiteForm(msite).CurrentObject;
         mMon := mHead.GetLoadedCollectionMonikerForFieldCode(mHead.GetFieldCode('ROWS'));

                  for i := 0 to mMon.Count-1 do begin
                        //NxShowSimpleMessage(copy(mMon.BusinessObject[i].GetFieldValueAsstring('Text'),10,14),nil);
                        //NxShowSimpleMessage(copy(mMon.BusinessObject[i].GetFieldValueAsstring('Text'),25,27),nil);
                        if copy(mMon.BusinessObject[i].GetFieldValueAsstring('Text'),10,14)='PLATEBNI KARTY' then begin
                              // msString:=InputBox('A','AAA', copy(mMon.BusinessObject[i].GetFieldValueAsstring('Text'),26,26));
                                     if copy(mMon.BusinessObject[i].GetFieldValueAsstring('Text'),26,26)='EC/MC - UHRADY OBCHODNIKUM' then begin
                                                if mImportFile.Count >1 then begin
                                                                                  ii := 11;
                                                                                   while ii < mImportFile.Count do begin

                                                                                           //     if copy(mImportFile.strings[ii],1,1)<>'' then begin
                                                                                                            mLine := mImportFile.strings[ii];
                                                                                                            //NxTokenToStrings(mLine, ';', mLineCols);


                                                                                                            mLine :=NxSearchReplace(NxSearchReplace(mLine, '"', '', [srAll]), ';', '";"', [srAll]) +';';
                                                                                                              mLine := NxSearchReplace(mLine, chr(9), ';', [srAll]);

                                                                                                              mfieldValue:= TStringList.Create;
                                                                                                              try
                                                                                                                  mfieldValue:=fnParsevalue(mline,';');

                                                                                                                       if NxSearchReplace(mfieldValue.Strings[3], '"', '', [srAll])='MC' then begin       //mc
                                                                                                                              mMon.BusinessObject[i].SetFieldValueAsBoolean('IsMultiPaymentRow',True);


                                                                                                                              mRow := mMon.AddNewObject;
                                                                                                                                      mRow.Prefill;
                                                                                                                               mRow.SetFieldValueAsboolean('Credit',mMon.BusinessObject[i].getFieldValueAsBoolean('Credit'));
                                                                                                                              //mRow.SetFieldValueAsDateTime('DocDate$DATE',iExtractDate(mfieldValue.Strings[0]));
                                                                                                                              mRow.SetFieldValueAsString('Text',copy(mfieldValue.Strings[16],1,35));


                                                                                                                              mvarsymbol:= NxFloatToIBStr(NxIBStrToFloat(NxSearchReplace(mfieldValue.Strings[28], '"', '', [srAll]))) ;
                                                                                                                              mRow.SetFieldValueAsString('VarSymbol',mvarsymbol);
                                                                                                                              mRow.SetFieldValueAsString('BankStatementRow_ID',mMon.BusinessObject[i].oid);
                                                                                                                              mRow.SetFieldValueAsBoolean('IsMultiPaymentRow',false);


                                                                                                                               msString:= (NxSearchReplace(mfieldValue.Strings[23], '"', '', [srAll]));
                                                                                                                               msString:= (NxSearchReplace(msString, '+', '', [srAll]));

                                                                                                                                mRow.SetFieldValueAsFloat('Amount', NxIBStrToFloat(msString)) ;

                                                                                                                           // mRow.SetFieldValueAsString('Division_ID', mMon.BusinessObject[i].getFieldValueAsString('Division_ID')) ;
                                                                                                                           // mRow.SetFieldValueAsString('BusOrder_ID', mMon.BusinessObject[i].getFieldValueAsString('BusOrder_ID')) ;
                                                                                                                           // mRow.SetFieldValueAsString('BusTransaction_ID', mMon.BusinessObject[i].getFieldValueAsString('BusTransaction_ID')) ;
                                                                                                                           // mRow.SetFieldValueAsString('BusProject_ID', mMon.BusinessObject[i].getFieldValueAsString('BusProject_ID')) ;

                                                                                                                                       mr:=tstringlist.create;
                                                                                                                                            try
                                                                                                                                               msite.BaseObjectSpace.sqlselect('SELECT A.ID FROM IssuedDInvoices A WHERE A.VarSymbol= ' + quotedstr(mvarsymbol),mr);

                                                                                                                                                      if mr.count=1 then begin
                                                                                                                                                          mRow.SetFieldValueAsString('PDocumentType','10');
                                                                                                                                                          mRow.SetFieldValueAsString('PDocument_ID',mr.Strings[0]);
                                                                                                                                                          //mRow.SetFieldValueAsFloat('PAmount',mcastka);
                                                                                                                                                      end;
                                                                                                                                                finally   ;
                                                                                                                                                    mr.free;
                                                                                                                                                end;

                                                                                                                       end;
                                                                                                              finally
                                                                                                                      mfieldValue.free;
                                                                                                              end;


                                                                                        Inc(ii, 1);
                                                                                      end;         //while

                                                end;



                                     end;

                                      if copy(mMon.BusinessObject[i].GetFieldValueAsstring('Text'),26,26)='VISA - UHRADY OBCHODNIKUM ' then begin
                                     //   NxShowSimpleMessage('Visa '  + copy(mMon.BusinessObject[i].GetFieldValueAsstring('Text'),25,26),nil);
                                           if mImportFile.Count >1 then begin
                                                                                  ii := 11;
                                                                                   while ii < mImportFile.Count do begin

                                                                                           //     if copy(mImportFile.strings[ii],1,1)<>'' then begin
                                                                                                            mLine := mImportFile.strings[ii];
                                                                                                            //NxTokenToStrings(mLine, ';', mLineCols);


                                                                                                            mLine :=NxSearchReplace(NxSearchReplace(mLine, '"', '', [srAll]), ';', '";"', [srAll]) +';';
                                                                                                              mLine := NxSearchReplace(mLine, chr(9), ';', [srAll]);

                                                                                                              mfieldValue:= TStringList.Create;
                                                                                                              try
                                                                                                                  mfieldValue:=fnParsevalue(mline,';');

                                                                                                                       if NxSearchReplace(mfieldValue.Strings[3], '"', '', [srAll])='VISA' then begin       //mc
                                                                                                                              mMon.BusinessObject[i].SetFieldValueAsBoolean('IsMultiPaymentRow',True);


                                                                                                                              mRow := mMon.AddNewObject;
                                                                                                                                      mRow.Prefill;
                                                                                                                              mRow.SetFieldValueAsboolean('Credit',mMon.BusinessObject[i].getFieldValueAsBoolean('Credit'));
                                                                                                                              mRow.SetFieldValueAsString('Text',copy(mfieldValue.Strings[16],1,35));


                                                                                                                              mvarsymbol:= NxFloatToIBStr(NxIBStrToFloat(NxSearchReplace(mfieldValue.Strings[28], '"', '', [srAll]))) ;
                                                                                                                              mRow.SetFieldValueAsString('VarSymbol',mvarsymbol);
                                                                                                                              mRow.SetFieldValueAsString('BankStatementRow_ID',mMon.BusinessObject[i].oid);
                                                                                                                              mRow.SetFieldValueAsBoolean('IsMultiPaymentRow',false);


                                                                                                                           msString:= Trim(NxSearchReplace(mfieldValue.Strings[23], '"', '', [srAll]));
                                                                                                                               msString:= trim(NxSearchReplace(msString, '+', '', [srAll]));
                                                                                                                           mRow.SetFieldValueAsFloat('Amount', NxIBStrToFloat(msString)) ;

                                                                                                                           // mRow.SetFieldValueAsString('Division_ID', mMon.BusinessObject[i].getFieldValueAsString('Division_ID')) ;
                                                                                                                           // mRow.SetFieldValueAsString('BusOrder_ID', mMon.BusinessObject[i].getFieldValueAsString('BusOrder_ID')) ;
                                                                                                                           // mRow.SetFieldValueAsString('BusTransaction_ID', mMon.BusinessObject[i].getFieldValueAsString('BusTransaction_ID')) ;
                                                                                                                           // mRow.SetFieldValueAsString('BusProject_ID', mMon.BusinessObject[i].getFieldValueAsString('BusProject_ID')) ;

                                                                                                                                       mr:=tstringlist.create;
                                                                                                                                            try
                                                                                                                                               msite.BaseObjectSpace.sqlselect('SELECT A.ID FROM IssuedDInvoices A WHERE A.VarSymbol= ' + quotedstr(mvarsymbol),mr);

                                                                                                                                                      if mr.count=1 then begin
                                                                                                                                                          mRow.SetFieldValueAsString('PDocumentType','10');
                                                                                                                                                          mRow.SetFieldValueAsString('PDocument_ID',mr.Strings[0]);
                                                                                                                                                          //mRow.SetFieldValueAsFloat('PAmount',mcastka);
                                                                                                                                                      end;
                                                                                                                                                finally   ;
                                                                                                                                                    mr.free;
                                                                                                                                                end;
                                                                                                                       end;
                                                                                                              finally
                                                                                                                      mfieldValue.free;
                                                                                                              end;


                                                                                        Inc(ii, 1);
                                                                                      end;         //while

                                                end;



                                      end;




                         end;

                  end;   // řádky dokladu

 finally
     mImportFile.free;
 end;

 mhead.Save;


           { mhead.ClearValidateErrors;
                                  if Not mhead.Validate() then begin
                                        mList := TStringList.Create;
                                        try
                                           mhead.GetValidateErrors(mList);
                                           mText := mList.Text;
                                           NxToken(mText, '=');
                                           MessageDlg('Automaticky vytvořený doklad nelze uložit z těchto důvodů:' + #13#10 + mText,

                                           mtWarning, [mbOK], 0);
                                         finally
                                           mList.Free;
                                         end;
                                         mSite.ShowDynFormWithNewDocument('R1C2EX0BUJD13ACP03KIU0CLP4', mSite.SiteContext, mhead);

                                  end else begin


                                        mhead.Save;
                                  end;
                         }
end;



function ImportNEWFileKBSmart(OS: TNxCustomObjectSpace; AFileName: string;directory: string;filename: string;msite:TDynSiteForm;rucne:boolean;chyba:boolean;index:Integer) : Boolean;
var

    mImportFile:TStringList;
    mFieldHead,mFieldConst,mFieldLabel,mFieldType,mFieldLenght,mfieldValue,mFieldTable,mFieldCLSID,mFieldField,mFieldCreate,mFieldBo:TStringList;
     mr,mList:TStringList;
    mbo,mrow:TNxCustomBusinessObject;
     mhead:TNxCustomBusinessObject;
    mMon:TNxCustomBusinessMonikerCollection;
    mline:string;
    mText:string;
    mdivision,mBusOrder, mBustransaction, mBusproject:string;
    mpocet:double;
    mcastka:double;
    msString:string;
    mBDialog:Boolean;
    ii:integer;
    mvarsymbol:string;
    mDivision_ID, mBusOrder_ID,mBusTransaction_ID,mBusProject_ID:string;
begin

    if not FileExists(AFileName) then begin   // soubor nenalezen
      Result := False;
      exit;
    end;

try
 mImportFile := TStringList.Create;
mImportFile.LoadFromFile(AFileName);

   if mShowProgres then ProgressInit(msite, 'Import ' + AFileName, 100);
mHead :=  TDynSiteForm(msite).BaseObjectSpace.CreateObject('O3SCO4S1BRD13FY1010DELDFKK');
mhead.new;
mhead.Prefill;
if mImportFile.strings[9] ='"MENA";"CZK";' then  begin
        mhead.SetFieldValueAsString('BankAccount_ID','2J90000101');
        //NxShowSimpleMessage(copy(mImportFile.strings[7],13,10),nil);
        mhead.SetFieldValueAsDateTime('DocDate$DATE',iExtractDate(copy(mImportFile.strings[7],13,10)));
        mhead.SetFieldValueAsString('DocQueue_ID','27R0000101');
        mhead.SetFieldValueAsString('ExternalNumber',copy(mImportFile.strings[8],26,5));

end;
if mImportFile.strings[9] ='"MENA";"EUR";' then  begin
        mhead.SetFieldValueAsString('BankAccount_ID','2JA0000101');
        //NxShowSimpleMessage(copy(mImportFile.strings[7],13,10),nil);
        mhead.SetFieldValueAsDateTime('DocDate$DATE',iExtractDate(copy(mImportFile.strings[7],13,10)));
        mhead.SetFieldValueAsString('DocQueue_ID','27S0000101');
        mhead.SetFieldValueAsString('ExternalNumber',copy(mImportFile.strings[8],26,5));
end;

mMon := mHead.GetLoadedCollectionMonikerForFieldCode(mHead.GetFieldCode('ROWS'));
if mImportFile.Count >1 then begin
                ii := 10;
                 while ii < mImportFile.Count do begin

                   if true then begin
                                          mLine := mImportFile.strings[ii];



                                            mLine := NxSearchReplace(mLine, '"', '', [srAll]);
                                            mLine := NxSearchReplace(mLine, chr(9), ';', [srAll]);

                                            //NxShowSimpleMessage(mline,nil);
                            if mShowProgres then ProgressSetPos(1+NxFloor((ii/mImportFile.Count)*99), inttostr(ii) +' z '+inttostr(mImportFile.Count));

                                   if ii >10 then begin
                                            mfieldValue:= TStringList.Create;
                                            try
                                                mfieldValue:=fnParsevalue(mline,';');

                                                mDivision_ID:='';
                                                mBusOrder_ID:='';
                                                mBusTransaction_ID:='';
                                                mBusTransaction_ID:='';
                                                mBusProject_ID:='';

                                                           mRow := mMon.AddNewObject;
                                                           mRow.Prefill;
                                                           mRow.SetFieldValueAsboolean('Credit',True);
                                                           mRow.SetFieldValueAsDateTime('DocDate$DATE',iExtractDate((NxSearchReplace(mfieldValue.Strings[0], '"', '', [srAll]))));     //iExtractDate((NxSearchReplace(mfieldValue.Strings[7], '"', '', [srAll]))));
                                                           mRow.SetFieldValueAsString('Text',copy(mfieldValue.Strings[4] + '-' + mfieldValue.Strings[6],1,35));


                                                            mvarsymbol:= NxFloatToIBStr(NxIBStrToFloat(NxSearchReplace(mfieldValue.Strings[7], ' ', '', [srAll]))) ;
                                                            mRow.SetFieldValueAsString('VarSymbol',mvarsymbol);
                                                            //mRow.SetFieldValueAsString('BankStatementRow_ID',mMon.BusinessObject[i].oid);
                                                            //mRow.SetFieldValueAsBoolean('IsMultiPaymentRow',false);


                                                             msString:= trim(NxSearchReplace((NxSearchReplace(mfieldValue.Strings[9], '"', '', [srAll])), ' ', '', [srAll]));
                                                              mRow.SetFieldValueAsFloat('Amount', NxIBStrToFloat(msString)) ;
                                                              mRow.SetFieldValueAsboolean('Credit',True);
                                                         // mRow.SetFieldValueAsString('Division_ID', mMon.BusinessObject[i].getFieldValueAsString('Division_ID')) ;
                                                         // mRow.SetFieldValueAsString('BusOrder_ID', mMon.BusinessObject[i].getFieldValueAsString('BusOrder_ID')) ;
                                                         // mRow.SetFieldValueAsString('BusTransaction_ID', mMon.BusinessObject[i].getFieldValueAsString('BusTransaction_ID')) ;
                                                         // mRow.SetFieldValueAsString('BusProject_ID', mMon.BusinessObject[i].getFieldValueAsString('BusProject_ID')) ;

                                                            if mRow.getFieldValueAsboolean('Credit') then begin
                                                                     mr:=tstringlist.create;
                                                                          try
                                                                             msite.BaseObjectSpace.sqlselect('SELECT A.ID FROM IssuedDInvoices A WHERE A.VarSymbol= ' + quotedstr(mvarsymbol),mr);

                                                                                    if mr.count=1 then begin
                                                                                        mRow.SetFieldValueAsString('PDocumentType','10');
                                                                                        mRow.SetFieldValueAsString('PDocument_ID',mr.Strings[0]);
                                                                                        //mRow.SetFieldValueAsFloat('PAmount',mcastka);
                                                                                    end;
                                                                              finally   ;
                                                                                  mr.free;
                                                                              end;
                                                             end else begin
                                                                 mr:=tstringlist.create;
                                                                          try
                                                                             msite.BaseObjectSpace.sqlselect('SELECT A.ID FROM IssuedCreditNotes A WHERE A.VarSymbol= ' + quotedstr(mvarsymbol),mr);

                                                                                    if mr.count=1 then begin
                                                                                        mRow.SetFieldValueAsString('PDocumentType','60');
                                                                                        mRow.SetFieldValueAsString('PDocument_ID',mr.Strings[0]);
                                                                                        //mRow.SetFieldValueAsFloat('PAmount',mcastka);
                                                                                    end;
                                                                              finally   ;
                                                                                  mr.free;
                                                                              end;
                                                             end;



                                                                            mDivision_ID:=mRow.getFieldValueAsString('Division_ID');
                                                                            mDivision_ID:='1N00000101';
                                                                            mRow.SetFieldValueAsString('Division_ID', mDivision_ID) ;
                                                                            mBusOrder_ID:=mRow.getFieldValueAsString('BusOrder_ID');
                                                                            mBusTransaction_ID:=mRow.getFieldValueAsString('BusTransaction_ID');
                                                                            mBusProject_ID:=mRow.getFieldValueAsString('BusProject_ID');



                                                    mRow := mMon.AddNewObject;
                                                           mRow.Prefill;
                                                         //  mRow.SetFieldValueAsDateTime('DocDate$DATE',iExtractDate((NxSearchReplace(mfieldValue.Strings[0], ' ', '', [srAll]))));

                                                           mRow.SetFieldValueAsboolean('Credit',false);
                                                            msString:= (NxSearchReplace(mfieldValue.Strings[12], ' ', '', [srAll]));
                                                            msString:= (NxSearchReplace(mfieldValue.Strings[12], '+', '', [srAll]));
                                                                   mRow.SetFieldValueAsFloat('Amount',  NxIBStrToFloat(msString)) ;






                                                           mRow.SetFieldValueAsString('Text',copy(mfieldValue.Strings[4] + '-' + mfieldValue.Strings[6],1,35));




                                                         mRow.SetFieldValueAsString('AccPresetDef_ID','3G50000101');
                                                         mRow.SetFieldValueAsString('Division_ID', mDivision_ID) ;
                                                         mRow.SetFieldValueAsString('BusOrder_ID', mBusOrder_ID) ;
                                                         mRow.SetFieldValueAsString('BusTransaction_ID', mBusTransaction_ID) ;
                                                         mRow.SetFieldValueAsString('BusProject_ID', mBusProject_ID) ;





                                            finally
                                                    mfieldValue.free;
                                            end;
                                   end;
                             end;
                      Inc(ii, 1);

                    end;         //while
              end;


 finally
     mImportFile.free;
 end;


                if mShowProgres then ProgressDispose();

            mhead.ClearValidateErrors;
                                  if Not mhead.Validate() then begin
                                        mList := TStringList.Create;
                                        try
                                           mhead.GetValidateErrors(mList);
                                           mText := mList.Text;
                                           NxToken(mText, '=');
                                           MessageDlg('Automaticky vytvořený doklad nelze uložit z těchto důvodů:' + #13#10 + mText,

                                           mtWarning, [mbOK], 0);
                                         finally
                                           mList.Free;
                                         end;
                                         mSite.ShowDynFormWithNewDocument('R1C2EX0BUJD13ACP03KIU0CLP4', mSite.SiteContext, mhead);

                                  end else begin


                                        mhead.Save;
                                        result:=nxcopyfile(afilename,directory + '\Zpracovane\' + afilename);

                                        if result then begin
                                            DeleteFile(afilename);
                                            if rucne and result and chyba then begin
                                                   NxShowSimpleMessage('Soubor ' + afilename + ' byl přesunut do zpracovaných',nil);
                                            end;
                                        end;
                                  end;

end;









function ImportFileKB(OS: TNxCustomObjectSpace; AFileName: string;directory: string;filename: string;msite:TDynSiteForm;rucne:boolean;chyba:boolean;index:Integer) : Boolean;
var

    mImportFile:TStringList;
    mFieldHead,mFieldConst,mFieldLabel,mFieldType,mFieldLenght,mfieldValue,mFieldTable,mFieldCLSID,mFieldField,mFieldCreate,mFieldBo:TStringList;
     mr,mList:TStringList;
    mbo,mrow:TNxCustomBusinessObject;
     mhead:TNxCustomBusinessObject;
    mMon:TNxCustomBusinessMonikerCollection;
    mline:string;
    mText:string;
    mdivision,mBusOrder, mBustransaction, mBusproject:string;
    mpocet:double;
    mcastka:double;
    msString:string;
    mBDialog:Boolean;
    ii:integer;
    mvarsymbol:string;
begin

    if not FileExists(AFileName) then begin   // soubor nenalezen
      Result := False;
      exit;
    end;

try
 mImportFile := TStringList.Create;
mImportFile.LoadFromFile(AFileName);


mHead :=  TDynSiteForm(msite).CurrentObject;
         mMon := mHead.GetLoadedCollectionMonikerForFieldCode(mHead.GetFieldCode('ROWS'));

                  for i := 0 to mMon.Count-1 do begin
                        //NxShowSimpleMessage(copy(mMon.BusinessObject[i].GetFieldValueAsstring('Text'),10,14),nil);
                        //NxShowSimpleMessage(copy(mMon.BusinessObject[i].GetFieldValueAsstring('Text'),25,27),nil);
                        if copy(mMon.BusinessObject[i].GetFieldValueAsstring('Text'),10,14)='PLATEBNI KARTY' then begin
                              // msString:=InputBox('A','AAA', copy(mMon.BusinessObject[i].GetFieldValueAsstring('Text'),26,26));
                                     if copy(mMon.BusinessObject[i].GetFieldValueAsstring('Text'),26,26)='EC/MC - UHRADY OBCHODNIKUM' then begin
                                                if mImportFile.Count >1 then begin
                                                                                  ii := 11;
                                                                                   while ii < mImportFile.Count do begin

                                                                                           //     if copy(mImportFile.strings[ii],1,1)<>'' then begin
                                                                                                            mLine := mImportFile.strings[ii];
                                                                                                            //NxTokenToStrings(mLine, ';', mLineCols);


                                                                                                            mLine :=NxSearchReplace(NxSearchReplace(mLine, '"', '', [srAll]), ';', '";"', [srAll]) +';';
                                                                                                              mLine := NxSearchReplace(mLine, chr(9), ';', [srAll]);

                                                                                                              mfieldValue:= TStringList.Create;
                                                                                                              try
                                                                                                                  mfieldValue:=fnParsevalue(mline,';');

                                                                                                                       if NxSearchReplace(mfieldValue.Strings[3], '"', '', [srAll])='MC' then begin       //mc
                                                                                                                              mMon.BusinessObject[i].SetFieldValueAsBoolean('IsMultiPaymentRow',True);


                                                                                                                              mRow := mMon.AddNewObject;
                                                                                                                                      mRow.Prefill;
                                                                                                                               mRow.SetFieldValueAsboolean('Credit',mMon.BusinessObject[i].getFieldValueAsBoolean('Credit'));
                                                                                                                              //mRow.SetFieldValueAsDateTime('DocDate$DATE',iExtractDate(mfieldValue.Strings[0]));
                                                                                                                              mRow.SetFieldValueAsString('Text',copy(mfieldValue.Strings[7],1,35));


                                                                                                                              mvarsymbol:= NxFloatToIBStr(NxIBStrToFloat(NxSearchReplace(mfieldValue.Strings[6], '"', '', [srAll]))) ;
                                                                                                                              mRow.SetFieldValueAsString('VarSymbol',mvarsymbol);
                                                                                                                              mRow.SetFieldValueAsString('BankStatementRow_ID',mMon.BusinessObject[i].oid);
                                                                                                                              mRow.SetFieldValueAsBoolean('IsMultiPaymentRow',false);


                                                                                                                               msString:= (NxSearchReplace(mfieldValue.Strings[10], '"', '', [srAll]));
                                                                                                                                msString:= (NxSearchReplace(msString, ' ', '', [srAll]));
                                                                                                                                msString:= (NxSearchReplace(msString, '+', '', [srAll]));
                                                                                                                                mRow.SetFieldValueAsFloat('Amount', NxIBStrToFloat(msString)) ;

                                                                                                                           // mRow.SetFieldValueAsString('Division_ID', mMon.BusinessObject[i].getFieldValueAsString('Division_ID')) ;
                                                                                                                           // mRow.SetFieldValueAsString('BusOrder_ID', mMon.BusinessObject[i].getFieldValueAsString('BusOrder_ID')) ;
                                                                                                                           // mRow.SetFieldValueAsString('BusTransaction_ID', mMon.BusinessObject[i].getFieldValueAsString('BusTransaction_ID')) ;
                                                                                                                           // mRow.SetFieldValueAsString('BusProject_ID', mMon.BusinessObject[i].getFieldValueAsString('BusProject_ID')) ;

                                                                                                                                       mr:=tstringlist.create;
                                                                                                                                            try
                                                                                                                                               msite.BaseObjectSpace.sqlselect('SELECT A.ID FROM IssuedDInvoices A WHERE A.VarSymbol= ' + quotedstr(mvarsymbol),mr);

                                                                                                                                                      if mr.count=1 then begin
                                                                                                                                                          mRow.SetFieldValueAsString('PDocumentType','10');
                                                                                                                                                          mRow.SetFieldValueAsString('PDocument_ID',mr.Strings[0]);
                                                                                                                                                          //mRow.SetFieldValueAsFloat('PAmount',mcastka);
                                                                                                                                                      end;
                                                                                                                                                finally   ;
                                                                                                                                                    mr.free;
                                                                                                                                                end;

                                                                                                                       end;
                                                                                                              finally
                                                                                                                      mfieldValue.free;
                                                                                                              end;


                                                                                        Inc(ii, 1);
                                                                                      end;         //while

                                                end;



                                     end;

                                      if copy(mMon.BusinessObject[i].GetFieldValueAsstring('Text'),26,26)='VISA - UHRADY OBCHODNIKUM ' then begin
                                     //   NxShowSimpleMessage('Visa '  + copy(mMon.BusinessObject[i].GetFieldValueAsstring('Text'),25,26),nil);
                                           if mImportFile.Count >1 then begin
                                                                                  ii := 11;
                                                                                   while ii < mImportFile.Count do begin

                                                                                           //     if copy(mImportFile.strings[ii],1,1)<>'' then begin
                                                                                                            mLine := mImportFile.strings[ii];
                                                                                                            //NxTokenToStrings(mLine, ';', mLineCols);


                                                                                                            mLine :=NxSearchReplace(NxSearchReplace(mLine, '"', '', [srAll]), ';', '";"', [srAll]) +';';
                                                                                                              mLine := NxSearchReplace(mLine, chr(9), ';', [srAll]);

                                                                                                              mfieldValue:= TStringList.Create;
                                                                                                              try
                                                                                                                  mfieldValue:=fnParsevalue(mline,';');

                                                                                                                       if NxSearchReplace(mfieldValue.Strings[3], '"', '', [srAll])='VISA' then begin       //mc
                                                                                                                              mMon.BusinessObject[i].SetFieldValueAsBoolean('IsMultiPaymentRow',True);


                                                                                                                              mRow := mMon.AddNewObject;
                                                                                                                                      mRow.Prefill;
                                                                                                                              mRow.SetFieldValueAsboolean('Credit',mMon.BusinessObject[i].getFieldValueAsBoolean('Credit'));
                                                                                                                              //NxSearchReplace(mfieldValue.Strings[4], '"', '', [srAll])<>'DEBETNÍ'

                                                                                                                              //mRow.SetFieldValueAsDateTime('DocDate$DATE',iExtractDate(mfieldValue.Strings[0]));
                                                                                                                              mRow.SetFieldValueAsString('Text',copy(mfieldValue.Strings[7],1,35));


                                                                                                                              mvarsymbol:= NxFloatToIBStr(NxIBStrToFloat(NxSearchReplace(mfieldValue.Strings[6], '"', '', [srAll]))) ;
                                                                                                                              mRow.SetFieldValueAsString('VarSymbol',mvarsymbol);
                                                                                                                              mRow.SetFieldValueAsString('BankStatementRow_ID',mMon.BusinessObject[i].oid);
                                                                                                                              mRow.SetFieldValueAsBoolean('IsMultiPaymentRow',false);


                                                                                                                               msString:= (NxSearchReplace(mfieldValue.Strings[10], '"', '', [srAll]));
                                                                                                                                msString:= (NxSearchReplace(msString, ' ', '', [srAll]));
                                                                                                                                msString:= (NxSearchReplace(msString, '+', '', [srAll]));
                                                                                                                                mRow.SetFieldValueAsFloat('Amount', NxIBStrToFloat(msString)) ;

                                                                                                                           // mRow.SetFieldValueAsString('Division_ID', mMon.BusinessObject[i].getFieldValueAsString('Division_ID')) ;
                                                                                                                           // mRow.SetFieldValueAsString('BusOrder_ID', mMon.BusinessObject[i].getFieldValueAsString('BusOrder_ID')) ;
                                                                                                                           // mRow.SetFieldValueAsString('BusTransaction_ID', mMon.BusinessObject[i].getFieldValueAsString('BusTransaction_ID')) ;
                                                                                                                           // mRow.SetFieldValueAsString('BusProject_ID', mMon.BusinessObject[i].getFieldValueAsString('BusProject_ID')) ;

                                                                                                                                       mr:=tstringlist.create;
                                                                                                                                            try
                                                                                                                                               msite.BaseObjectSpace.sqlselect('SELECT A.ID FROM IssuedDInvoices A WHERE A.VarSymbol= ' + quotedstr(mvarsymbol),mr);

                                                                                                                                                      if mr.count=1 then begin
                                                                                                                                                          mRow.SetFieldValueAsString('PDocumentType','10');
                                                                                                                                                          mRow.SetFieldValueAsString('PDocument_ID',mr.Strings[0]);
                                                                                                                                                          //mRow.SetFieldValueAsFloat('PAmount',mcastka);
                                                                                                                                                      end;
                                                                                                                                                finally   ;
                                                                                                                                                    mr.free;
                                                                                                                                                end;

                                                                                                                       end;
                                                                                                              finally
                                                                                                                      mfieldValue.free;
                                                                                                              end;


                                                                                        Inc(ii, 1);
                                                                                      end;         //while

                                                end;



                                      end;




                         end;

                  end;   // řádky dokladu

 finally
     mImportFile.free;
 end;

 mhead.Save;


           { mhead.ClearValidateErrors;
                                  if Not mhead.Validate() then begin
                                        mList := TStringList.Create;
                                        try
                                           mhead.GetValidateErrors(mList);
                                           mText := mList.Text;
                                           NxToken(mText, '=');
                                           MessageDlg('Automaticky vytvořený doklad nelze uložit z těchto důvodů:' + #13#10 + mText,

                                           mtWarning, [mbOK], 0);
                                         finally
                                           mList.Free;
                                         end;
                                         mSite.ShowDynFormWithNewDocument('R1C2EX0BUJD13ACP03KIU0CLP4', mSite.SiteContext, mhead);

                                  end else begin


                                        mhead.Save;
                                  end;
                         }
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
          mMAction.Hint := 'Avíza';
          mMAction.Caption := 'Avíza ';
          mMAction.Items.Add('Paypal EUR');
          mMAction.Items.Add('Paypal GBP');
          mMAction.Items.Add('KB');
          mMAction.Items.Add('KB SmartPay');
          mMAction.Items.Add('KB NEW AVIZO');
          mMAction.Items.Add('Zásilkovna');
          mMAction.Items.Add('Mollie');



          mMAction.Category := 'tabList';
          mMAction.OnExecuteItem := @OnExec;


end;

procedure OnExec(Sender: TComponent;index:integer);
var

  zadej:string;
  mfilename:string;
  mdir,mfile:string;
  msite:TDynSiteForm;
begin
  //mSite := NxFinddySiteForm(Sender);

  msite:=TComponent(Sender).DynSite;
   if PromptForFileName(mFileName, mfilter, '', 'Soubor plateb', mdir, False) then begin
    mdir:=copy(mfilename,0,NxCharPosR('\',mfilename));
    mFile:=copy(mfilename,1+NxCharPosR('\',mfilename),Length(mfilename));
   end;
  //ImportFile(TDynSiteForm(mSite).CurrentObject.ObjectSpace, mfilename, mdir,mfile);
  if (index=0) or (index=1) then begin
       ImportFilePayPal(msite.BaseObjectSpace, mfilename, mdir,mfile,msite,true,false,index);
  end;

  if index=2 then begin
      ShowMessage(Format('Bude importován soubor %s%s', [mdir,mfile]));
      ImportFileKB(msite.BaseObjectSpace, mfilename, mdir,mfile,msite,true,true,index);

  end;
  if index=3 then begin
      ShowMessage(Format('Bude importován soubor %s%s', [mdir,mfile]));
      ImportFileKBSmart(msite.BaseObjectSpace, mfilename, mdir,mfile,msite,true,true,index);

  end;
  if index=4 then begin
      ShowMessage(Format('Bude importován soubor %s%s', [mdir,mfile]));
      ImportNEWFileKBSmart(msite.BaseObjectSpace, mfilename, mdir,mfile,msite,true,true,index);

  end;

  if index=5 then begin
     // ShowMessage(Format('Bude importován soubor %s%s', [mdir,mfile]));
      ImportNEWzasilkovna(msite.BaseObjectSpace, mfilename, mdir,mfile,msite,true,true,index);

  end;
  if index=6 then begin
     // ShowMessage(Format('Bude importován soubor %s%s', [mdir,mfile]));
      Importmollie(msite.BaseObjectSpace, mfilename, mdir,mfile,msite,true,true,index);

  end;

  msite.ActiveDataSet.RefreshAndRestoreLastSelectedItem;
end;




begin
end.
