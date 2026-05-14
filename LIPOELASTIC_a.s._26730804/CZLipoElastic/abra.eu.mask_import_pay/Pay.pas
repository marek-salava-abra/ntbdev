uses 'abra.eu.mask_import_pay.lib';





function iExtractDate(AString: String): TDateTime;
  begin
    Result := EncodeDate(StrToInt(Copy(AString,7,4)),StrToInt(Copy(AString,4,2)),StrToInt(Copy(AString,1,2)));
  end;

  function iExtractDateeu(AString: String): TDateTime;
  begin
    Result := EncodeDate(StrToInt(Copy(AString,1,4)),StrToInt(Copy(AString,6,2)),StrToInt(Copy(AString,9,2)));
  end;


function ImportFilePayPal(OS: TNxCustomObjectSpace; AFileName: string;directory: string;filename: string;msite:TDynSiteForm;rucne:boolean;chyba:boolean;index:Integer) : Boolean;
var

    mImportFile:TStringList;
    mFieldHead,mFieldConst,mFieldLabel,mFieldType,mFieldLenght,mfieldValue,mFieldTable,mFieldCLSID,mFieldField,mFieldCreate,mFieldBo:TStringList;
     mr,mList:TStringList;
    mbo,mrow:TNxCustomBusinessObject;
     mhead:TNxHeaderBusinessObject;
    mMon:TNxCustomBusinessMonikerCollection;
    mline:string;
    mText:string;
    mdivision,mBusOrder, mBustransaction, mBusproject:string;
    mpocet:double;
    mcastka:double;
begin

    if not FileExists(AFileName) then begin   // soubor nenalezen
      Result := False;
      exit;
    end;

try
mHead := TNxHeaderBusinessObject(OS.CreateObject('O3SCO4S1BRD13FY1010DELDFKK'));
        mHead.New;
        mHead.Prefill;
        if index=0 then begin
            mhead.SetFieldValueAsString('Docqueue_ID','1230000101');
            mhead.SetFieldValueAsString('BankAccount_ID' ,'1G00000101');
        end;
        if index=1 then begin
            mhead.SetFieldValueAsString('Docqueue_ID','1430000101');
            mhead.SetFieldValueAsString('BankAccount_ID' ,'1H00000101');
        end;

    mImportFile := TStringList.Create;

            mImportFile.LoadFromFile(AFileName);
            if mImportFile.Count >1 then begin
                 i := 1;
                 while i < mImportFile.Count do begin

                              if copy(mImportFile.strings[i],1,1)<>'' then begin
                                          mLine := mImportFile.strings[i];
                                          //NxTokenToStrings(mLine, ';', mLineCols);
                                          mLine :=NxSearchReplace(NxSearchReplace(mLine, '"', '', [srAll]), ';', '";"', [srAll]) +';';
                                            mLine := NxSearchReplace(mLine, chr(9), ';', [srAll]);

                                            mfieldValue:= TStringList.Create;
                                            try
                                                Parsevaluex(mline,';',mline,mfieldValue,30);
                                                if NxIBStrToFloat(mfieldValue.Strings[7])<>0 then begin

                                                     mcastka:=NxIBStrToFloat(mfieldValue.Strings[7]);
                                                      if ((index=0) and (mfieldValue.Strings[6]='EUR')) or
                                                         ((index=1) and (mfieldValue.Strings[6]='GBP'))
                                                       then begin
                                                          mRow := mHead.Rows.AddNewObject;
                                                                    mRow.Prefill;

                                                                    mRow.SetFieldValueAsboolean('Credit',mcastka>=0);

//                                                                    mRow.SetFieldValueAsDateTime('DocDate$DATE',iExtractDateeu(mfieldValue.Strings[0]));
                                                                    mRow.SetFieldValueAsDateTime('DocDate$DATE',iExtractDate(mfieldValue.Strings[0]));
                                                                    mRow.SetFieldValueAsString('Text',copy(mfieldValue.Strings[15],1,35));
                                                                    if mfieldValue.Strings[6]='EUR' then mRow.SetFieldValueAsString('Currency_ID','0000EUR000');


                                                                           if mcastka>0 then mRow.SetFieldValueAsFloat('Amount', mcastka) else mRow.SetFieldValueAsFloat('Amount', (-1) *mcastka);


                                                                    mr:=tstringlist.create;
                                                                    try
                                                                       os.sqlselect('SELECT A.ID FROM IssuedDInvoices A WHERE A.VarSymbol= ' + quotedstr(copy(mfieldValue.Strings[29],1,10)),mr);

                                                                    if mr.count=1 then begin
                                                                        mRow.SetFieldValueAsString('PDocumentType','10');
                                                                        mRow.SetFieldValueAsString('PDocument_ID',mr.Strings[0]);
                                                                        mRow.SetFieldValueAsFloat('PAmount',mcastka);
                                                                    end;
                                                                    finally
                                                                        mr.free;
                                                                    end;
                                                                   mdivision:=mRow.getFieldValueAsString('Division_ID');
                                                                   mBusOrder:=mRow.getFieldValueAsString('BusOrder_ID');
                                                                   mBustransaction:=mRow.getFieldValueAsString('Bustransaction_ID');
                                                                   mBusproject:=mRow.getFieldValueAsString('Busproject_ID');
                                                          end;
                                                  end;

                                                    // mRow.SetFieldValueAsFloat('TAmount','');
                                                  if NxIBStrToFloat(mfieldValue.Strings[8])<>0 then begin
                                                          if ((index=0) and (mfieldValue.Strings[6]='EUR')) or
                                                                ((index=1) and (mfieldValue.Strings[6]='GBP'))
                                                                then begin
                                                          mRow := mHead.Rows.AddNewObject;
                                                            mRow.Prefill;

                                                            mRow.SetFieldValueAsboolean('Credit',NxIBStrToFloat(mfieldValue.Strings[8])>0);
                                                            if NxIBStrToFloat(mfieldValue.Strings[8])>0 then mRow.SetFieldValueAsFloat('Amount', NxIBStrToFloat(mfieldValue.Strings[8])) else mRow.SetFieldValueAsFloat('Amount', (-1) *NxIBStrToFloat(mfieldValue.Strings[8]));

//                                                            mRow.SetFieldValueAsDateTime('DocDate$DATE',iExtractDateeu(mfieldValue.Strings[0]));
                                                            mRow.SetFieldValueAsDateTime('DocDate$DATE',iExtractDate(mfieldValue.Strings[0]));
                                                            mRow.SetFieldValueAsString('Text','Poplatek ' + copy(mfieldValue.Strings[15],1,35));
                                                            if mfieldValue.Strings[6]='EUR' then mRow.SetFieldValueAsString('Currency_ID','0000EUR000');

                                                            mRow.SetFieldValueAsString('AccPresetDef_ID','W101000000') ;
                                                           // mRow.SetFieldValueAsFloat('TAmount','');

                                                           mRow.setFieldValueAsString('Division_ID',mdivision);
                                                           mRow.setFieldValueAsString('BusOrder_ID',mBusOrder);
                                                           mRow.setFieldValueAsString('Bustransaction_ID',mBustransaction);
                                                           mRow.setFieldValueAsString('Busproject_ID',mBusproject);
                                                        end;
        //                                                    mRow.SetFieldValueAsString('Division_ID','1000000101'); //text bude  ...
                                                   end;

                                            finally
                                                    mfieldValue.free;
                                            end;

                               end;
                      Inc(i, 1);
                    end;

                end;

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
                                  end;

end;






begin
end.