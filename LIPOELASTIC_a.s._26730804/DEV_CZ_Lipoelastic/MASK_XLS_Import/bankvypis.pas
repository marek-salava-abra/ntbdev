 uses 'abra.eu.mask_import_pay.pay',
     '_Knihovny_ALL.Progress',
      '_Knihovny_ALL.Parse';
//, 'EU.Aabra.Mask.Validace.lib';



procedure SaveAttachements (mBO:TNxCustomBusinessObject; var Success: Boolean; var LogInfoStr: String);
var
 mList:TstringList;
 mCol:TNxCustomBusinessMonikerCollection;
 i,j, k:Integer;
begin
          mCol:=mBO.GetLoadedCollectionMonikerForFieldCode(mbo.GetFieldCode('Attachments'));
          if mCol.count>0 then begin
           for j:=0 to mCol.count-1 do begin
            //mCol.BusinessObject[j].MarkForDelete;
            NxShowSimpleMessage(mCol.BusinessObject[j].GetFieldValueAsString('FileName'),nil);
           end;
          end;
         mbo.save;
         mbo.free;
  Success := True;
//  LogInfoStr := 'Smazal jsem '+inttostr(k)+' příloh ze dne ' +FormatDateTime('d.m.yyyy',StrToFloat(mDateString));
end;

















procedure ZpracujSouborZFronty (OS: TNxCustomObjectSpace; var ProcessContinue: Boolean; Directory: string; FileName: string;msite:TDynSiteForm);
var
mOutputDocument:TNxCustomBusinessObject;
mresult:boolean;
begin
  mresult := ImportBank(OS, Directory + '\' + FileName,Directory,filename,msite,False,false,0);
end;



function ImportBank(OS: TNxCustomObjectSpace; AFileName: string;directory: string;filename: string;msite:TDynSiteForm;rucne:boolean;chyba:boolean;index:Integer) : Boolean;
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
    mTypFile:string;
begin

    if not FileExists(AFileName) then begin   // soubor nenalezen
      Result := False;
      exit;
    end;

try
 mShowProgres:=rucne;
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

                                                                                                              mfieldValue:= TStringList.Create;
                                                                                                              try
                                                                                                                 mfieldValue:= fnParsevalue(mline,',');




                                                                                                                  if NxIBStrToFloat(mfieldValue.strings[3])<>0 then begin


                                                                                                                      //NxShowSimpleMessage(msstring,nil);

                                                                                                                       mdatum:='';
                                                                                                                              mdatum:=(NxSearchReplace(mfieldValue.Strings[0], '"', '', [srAll]));
                                                                                                                              try
                                                                                                                              mRow := mMon.AddNewObject;
                                                                                                                                      mRow.Prefill;


                                                                                                                                    if NxIsNumeric(copy(mdatum,7,4)) then begin
                                                                                                                                        mRow.SetFieldValueAsDateTime('DocDate$DATE',NxEncodeDate(StrToInt(copy(mdatum,7,4)),strtoint(copy(mdatum,4,2)),strtoint(copy(mdatum,1,2))));
                                                                                                                                    end else begin
                                                                                                                                        mRow.SetFieldValueAsDateTime('DocDate$DATE',NxEncodeDate(StrToInt(copy(mdatum,1,4)),strtoint(copy(mdatum,6,2)),strtoint(copy(mdatum,9,2))));
                                                                                                                                    end;

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
                                                                                                                                                     if NxIBStrToFloat(mfieldValue.strings[3])>0 then begin
                                                                                                                                                                 os.sqlselect('SELECT A.ID FROM IssuedDInvoices A WHERE A.VarSymbol= ' + quotedstr(mRow.getFieldValueAsString('VarSymbol')),mr);

                                                                                                                                                                    if mr.count=0 then begin
                                                                                                                                                                             os.sqlselect('SELECT A.ID FROM IssuedInvoices A WHERE A.VarSymbol= ' + quotedstr(mRow.getFieldValueAsString('VarSymbol')),mr);
                                                                                                                                                                             if mr.count= 0 then begin
                                                                                                                                                                                    os.sqlselect('SELECT A.ID FROM IssuedCreditNotes A WHERE A.VarSymbol= ' + quotedstr(mRow.getFieldValueAsString('VarSymbol')),mr) ;
                                                                                                                                                                                    if mr.count= 0 then begin
                                                                                                                                                                                           os.sqlselect('SELECT A.ID FROM OtherIncomes A WHERE A.VarSymbol= ' + quotedstr(mRow.getFieldValueAsString('VarSymbol')),mr) ;
                                                                                                                                                                                           if mr.count>0 then mTypFile:='';
                                                                                                                                                                                    end else mTypFile:='';

                                                                                                                                                                             end else mTypFile:='';

                                                                                                                                                                    end else mTypFile:='';


                                                                                                                                                                        if mr.count=1 then begin
                                                                                                                                                                            mRow.SetFieldValueAsString('PDocumentType','10');
                                                                                                                                                                            mRow.SetFieldValueAsString('PDocument_ID',mr.Strings[0]);
                                                                                                                                                                            //mRow.SetFieldValueAsFloat('PAmount',mcastka);
                                                                                                                                                                        end;
                                                                                                                                                     end;
                                                                                                                                                  finally   ;
                                                                                                                                                      mr.free;
                                                                                                                                                  end;
                                                                                                                                        end;
                                                                                                                              finally

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





begin
end.

