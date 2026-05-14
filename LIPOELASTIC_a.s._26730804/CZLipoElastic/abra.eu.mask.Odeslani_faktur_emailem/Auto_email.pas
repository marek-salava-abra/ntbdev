
     const
//cSQLIssuedInvoices = 'SELECT A.ID FROM IssuedInvoices A LEFT JOIN Firms F ON F.ID=A.Firm_ID LEFT JOIN FirmOffices FO ON FO.ID=A.FirmOffice_ID  WHERE (A.docdate$date>%S) and (A.docdate$date<=%S) and ((FO.ElectronicAddress_ID is not null) and (F.ElectronicAddress_ID is not null)) order by FO.ElectronicAddress_ID,F.ElectronicAddress_ID desc' ;
// Vybrat vše co nebylo odesláno. Dále v kódu omezení na 30 dní zpátky, ať náhodou nepošleme celou databázi
// 9.9.2019 - Upraveno tak, aby dnešek neodesílal (VK)
cSQLIssuedInvoices = 'SELECT A.ID FROM IssuedInvoices A LEFT JOIN Firms F ON F.ID=A.Firm_ID LEFT JOIN FirmOffices FO ON FO.ID=A.FirmOffice_ID  WHERE (A.X_SendEmail$Date<>36527) and (A.docdate$date>%S) and (A.docdate$date<=%S) and (A.X_SendEmail$Date<A.Docdate$Date) and ((FO.ElectronicAddress_ID is not null) or (F.ElectronicAddress_ID is not null)) order by a.VarSymbol' ;
cSQLIssuedInvoicesxxx = 'SELECT A.ID FROM IssuedInvoices A LEFT JOIN Firms F ON F.ID=A.Firm_ID LEFT JOIN FirmOffices FO ON FO.ID=A.FirmOffice_ID  WHERE (A.docdate$date>%S) and (A.docdate$date<=%S) and (X_SendEmail$Date>1000) and ((FO.ElectronicAddress_ID is not null) or (F.ElectronicAddress_ID is not null)) order by a.VarSymbol' ;

mSQL_dotaz='select %s from %s where clsid=%s and code=%s';



{cSQLIssuedInvoices1 = 'SELECT A.ID FROM ' +
                'IssuedInvoices A ' +                                                           if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].localtamount') and (index=2)) then
                                                                    mRow.SetFieldValueAsFloat('localTamount',NxIBStrToFloat('0'+mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].localtamount'))); //text bude  ...

                                                                    if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].LocalTAmountWithoutVAT') and (index=2)) then
                                                                    mRow.SetFieldValueAsFloat('LocalTAmountWithoutVAT',NxIBStrToFloat('0'+ mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].LocalTAmountWithoutVAT')));

                                                                    if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].TAmount') and (index=2)) then
                                                                    mRow.SetFieldValueAsfloat('TAmount',NxIBStrToFloat('0'+mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].TAmount')));

                                                                         NxShowSimpleMessage(NxFloatToIBStr(mRow.getFieldValueAsfloat('TAmount')),nil) ;

                                                                    if not(ErrtElementString(mXMLHead ,'AbraDocument.Rows.Row['+inttostr(i)+'].TAmountWithoutVAT') and (index=2)) then
                                                                    mRow.SetFieldValueAsfloat('TAmountWithoutVAT',NxIBStrToFloat('0'+mXMLHead.getElementAsString('AbraDocument.Rows.Row['+inttostr(i)+'].TAmountWithoutVAT')));

                'LEFT JOIN Firms F ON F.ID=A.Firm_ID ' +
                'WHERE (F.X_Hromadna_fakturace is null) and (A.X_Datum_odeslani<3) ';

 }

 procedure Zpracovani_dokladu(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String;mIIs:tstringlist;mShowMsg:boolean);
var
  anameISDOC:string;
  cSQLCmd : string;
  mIssuedInvoice : TNxCustomBusinessObject;
  mPrintList:TStringList;
  i : integer;
  emailTo : string;
  asubject,ABody,ATo,AFrom:string;
  mBO_Vzor: TNxCustomBusinessObject;
  zkratka:string;
  blat_from,blat_to, Blat_subject,Blat_body, Blat_FileIsdoc:string;
  Blat_File:tstringlist;
  aname,anameIdoc:string;
  msestava:string;
  cDocId:string;
  mpocet:integer;
    mS_to,mS_SMTP,mS_User,mS_pasword,mS_CopyEmail,mS_BccEmail,ms_Email:string;
    MBO_text,mBO_Country,mBO_Universal:TNxCustomBusinessObject;
    mS_text:string;
    mS_port:Integer;
    mS_Email_from:string;
    mS_body:string;
    mS_docnumber:string;
    mR1,mr:TStringList;
    M_Context:tnxcontext;
    mS_zapati:string;
    mID_country:string;
    mB_result:boolean;
    mi:integer;
    mBoolean:Boolean;
    mZaznamu,mEmailu:integer ;
    mNameFile:string;
    mdivision_ID:string;
    mXID:string;
begin
//  NxScriptingLog.EnterSection('abra.eu.mask.nazaplaceno1/Nezaplaceno1.Odeslani_dokladu_auto()', logNotice);
  try
      LogInfoStr := '';
      mpocet:=0;
      mEmailu:=0;
      cDocId := '';

      try

          //    OS.SQLSelect(format(cSQLIssuedInvoicesxxx,[NxFloatToIBStr(Int(Now()-1)),NxFloatToIBStr(Int(Now())),NxFloatToIBStr(Int(Now()))]), mIIs);

          mZaznamu:=mIIs.Count;

          //NxShowSimpleMessage(inttostr(miis.count),nil);

          NxScriptingLog.WriteEventFmt(logDebug, 'Vraceno %d radku z dotazu "%s"', [mIIs.Count, cSQLIssuedInvoices]);
          LogInfoStr:= LogInfoStr + chr(13) + 'Vraceno ' + IntToStr(mIIs.Count) + ' řádků z dotazu :'+chr(13)+cSQLCmd;

          for i := 0 to mIIs.count-1 do begin
            mboolean:=true;
            cDocId := mIIs.Strings[i];
            if (mEmailu<10000)  and (mIIs.Count>0) then begin
                mIssuedInvoice := OS.CreateObject(Class_IssuedInvoice);
                try

                            mIssuedInvoice.load(mIIs.Strings[i], nil) ;

                            mS_Email_from:='';
                            mS_docnumber:=mIssuedInvoice.GetFieldValueAsString('VarSymbol');
                            m_Context:=NxCreateContext(mIssuedInvoice.ObjectSpace);
                            mID_country:='';
                            mBO_Country:=OS.CreateObject('4J5FINKNYNDL3C5P00CA141B44');
                            try
                              mr:=TStringList.Create;

                              try
                                OS.SQLSelect('Select id from countries where code =' + quotedstr(uppercase(mIssuedInvoice.GetFieldValueAsString('Firm_ID.ResidenceAddress_ID.CountryCode'))),mr);
                                if mr.count>0 then begin
                                  mID_country:=mr.strings[0] ;
                                  mBO_Country.load(mID_country,nil);
                                end;
                              finally
                                mr.free;
                              end;

                              mBO_Universal:=OS.CreateObject('4J5FINKNYNDL3C5P00CA141B44');
                              try
                                mBO_Universal.load('1200000101',nil);
                                Blat_File:=tstringlist.create;
                                mS_to:=mIssuedInvoice.GetFieldValueAsString('Firm_ID.ElectronicAddress_ID.EMail') ;
                                m_Context.free;

                                try  // smtp
                                  mr1:=TStringList.create;
                                  OS.SQLSelect(format(mSQL_dotaz,['name','defrolldata',quotedstr('CD1AQKBI01J4D0BAA13PP3QDDC'),quotedstr('SMTP')]),mr1);
                                  if mr1.Count=1 then mS_SMTP:=mr1.Strings[0];
                                finally
                                  mr1.free;
                                end;

                                try  // uživatel
                                  mr1:=TStringList.create;
                                  OS.SQLSelect(format(mSQL_dotaz,['name','defrolldata',quotedstr('CD1AQKBI01J4D0BAA13PP3QDDC'),quotedstr('USER')]),mr1);
                                  if mr1.Count=1 then mS_User:=mr1.Strings[0];
                                finally
                                  mr1.free;
                                end;

                                try  // heslo
                                  mr1:=TStringList.create;
                                  OS.SQLSelect(format(mSQL_dotaz,['name','defrolldata',quotedstr('CD1AQKBI01J4D0BAA13PP3QDDC'),quotedstr('Pasword')]),mr1);
                                  if mr1.Count=1 then mS_pasword:=mr1.Strings[0];
                                finally
                                  mr1.free;
                                end;

                                try  // port
                                  mr1:=TStringList.create;
                                  OS.SQLSelect(format(mSQL_dotaz,['name','defrolldata',quotedstr('CD1AQKBI01J4D0BAA13PP3QDDC'),quotedstr('Port')]),mr1);
                                  if mr1.Count=1 then mS_Port:=strtoint(mr1.Strings[0]);
                                finally
                                  mr1.free;
                                end;

                                if mS_Email='' then begin
                                    try  // odchozi_email
                                        mr1:=TStringList.create;
                                        mIssuedInvoice.ObjectSpace.SQLSelect(format(mSQL_dotaz,['name','defrolldata',quotedstr('CD1AQKBI01J4D0BAA13PP3QDDC'),quotedstr('Email_II')]),mr1);
                                        if mr1.Count=1 then mS_Email_from:=mr1.Strings[0];
                                    finally
                                      mr1.free;
                                    end;
                                end;

                                try  // kopie emailu
                                   mr1:=TStringList.create;
                                   OS.SQLSelect(format(mSQL_dotaz,['name','defrolldata',quotedstr('CD1AQKBI01J4D0BAA13PP3QDDC'),quotedstr('Copy_email')]),mr1);
                                   if mr1.Count=1 then mS_CopyEmail:=mr1.Strings[0];
                                finally
                                   mr1.free;
                                end;

                                mS_BccEmail:='';
                                try  // Blank kopie emailu
                                   mr1:=TStringList.create;
                                   OS.SQLSelect(format(mSQL_dotaz,['name','defrolldata',quotedstr('CD1AQKBI01J4D0BAA13PP3QDDC'),quotedstr('BCC_email')]),mr1);
                                   if mr1.Count=1 then mS_BccEmail:=mr1.Strings[0];
                                finally
                                   mr1.free;
                                end;

                                mS_text:='';
                                ms_body:='';

                                if mID_country<>'' then begin
                                    if mBO_Country.GetFieldValueAsString('X_Subj_END')<>'' then begin
                                          mS_text:=format(mBO_Country.GetFieldValueAsString('X_Subj_END'),[mIssuedInvoice.GetFieldValueAsString('Varsymbol')]);
                                    end;
                                    if mBO_Country.GetFieldValueAsString('X_Body_END')<>'' then begin
                                         mS_body:=format(mBO_Country.GetFieldValueAsString('X_Body_END'),[mIssuedInvoice.GetFieldValueAsString('Varsymbol'),'www.lipoelastic.cz']) ;
                                    end;
                                end;

                                if mS_text='' then begin
                                   if mBO_Universal.GetFieldValueAsString('X_Subj_END')<>'' then begin
                                       mS_text:=format(mBO_Universal.GetFieldValueAsString('X_Subj_END'),[mIssuedInvoice.GetFieldValueAsString('Varsymbol')]);
                                   end;
                                end;

                                if mS_body='' then begin
                                    if mBO_Universal.GetFieldValueAsString('X_Body_END')<>'' then begin
                                        mS_body:=format(mBO_Universal.GetFieldValueAsString('X_Body_END'),[mIssuedInvoice.GetFieldValueAsString('Varsymbol'),'www.lipoelastic.cz']) ;
                                    end;
                                end;
                              finally
                                   mBO_Universal.free;
                              end;

                              mS_CopyEmail:=mS_CopyEmail;

                              Blat_subject:= mS_text;
                              Blat_body:= mS_body;
                              mdivision_ID:='1000000101';
                              Blat_to := '';

                              if Blat_to= '' then Blat_to := mIssuedInvoice.GetFieldValueAsString('FirmOffice_ID.ElectronicAddress_ID.EMail');
                              if Blat_to= '' then Blat_to := mIssuedInvoice.GetFieldValueAsString('Firm_id.ElectronicAddress_ID.EMail');

                              if Blat_to<>'' then begin
                                  mPrintList := TStringList.Create;
                                  try
                                     mPrintList.Add(mIssuedInvoice.OID);
                                     AName := mIssuedInvoice.GetFieldValueAsString('Varsymbol')+'.pdf' ;
                                     //mSestava:='17J0000101' -- změna sestavy faktury;
                                     mSestava:='3W07000101';

                                     NxScriptingLog.WriteEvent(logDebug, 'Bude se tisknout ...');

                                     //blat_file := iPrintDocument(mIssuedInvoice,'',msestava,NxCreateContext_1(mIssuedInvoice),mPrintList, AName);
                                     //NxShowSimpleMessage(NxGetTempDir+' pocet'+inttostr(mprintlist.Count)+' id sest:'+ msestava,nil);

                                     AName := mIssuedInvoice.GetFieldValueAsString('Varsymbol')+'.pdf' ;
                                     try
                                        CFxReportManager.PrintByIDs(NxCreateContext(OS),mPrintList,'4BPBVBHBDXY4HEZ0YEG5E1UVQ4', mSestava, rtofile, pekPDF,NxGetTempDir,aname);
                                        Blat_File.Add(NxGetTempDir+'\'+aname);
                                        //NxShowSimpleMessage(Blat_File,nil);
                                      except
                                            LogInfoStr:= LogInfoStr + chr(13) + ExceptionMessage + ' Chyba - Nevytvoření souboru,  ';
                                           //mi:=os.SQLExecute('UPDATE IssuedInvoices set X_SendEmail$Date=36527 WHERE id=' + quotedstr(mIssuedInvoice.oid));
                                      end;


                                        // NxScriptingLog.WriteEventFmt(logDebug, 'byl vytisten PDF dokument ''%s''', [blat_File]);
                                        try

                                          if copy(mIssuedInvoice.GetFieldValueAsString('Firm_ID.X_Stitek_parametr'),7,1)='1' then begin
                                            //   isdoc
                                            //if mShowMsg then NxShowSimpleMessage(NxGetTempDir+anameISDOC,nil);
                                            anameISDOC := NxGetTempDir + mIssuedInvoice.GetFieldValueAsString('Varsymbol')+'.isdoc' ;
                                            //\\CZVS0006\export\Stav_Skladu.xml
                                            CFxReportManager.B2BExportByIDs(NxCreateContext(OS),mPrintList,'40SBPEINEFD13ACM03KIU0CLP4', '2310000101', 2, '',anameISDOC);

                                            Blat_File.Add(anameISDOC);
                                             NxScriptingLog.WriteEvent(logDebug, 'Vytvořen soubor ISDOC ...');
                                             LogInfoStr:= LogInfoStr + chr(13) + ExceptionMessage + ' Vytvořen soubor ISDOC ...  ';
                                          end;
                                        except
                                            LogInfoStr:= LogInfoStr + chr(13) + ExceptionMessage + ' Chyba - Nevytvoření ISDOC souboru,  ';
                                           //mi:=os.SQLExecute('UPDATE IssuedInvoices set X_SendEmail$Date=36527 WHERE id=' + quotedstr(mIssuedInvoice.oid));
                                        end;




                                        try

                                                //iSendMail(os, Blat_subject, Blat_body, blat_to, '3130000101', Blat_File);
                                                //Blat_File:=NxGetTempDir+aname;

                                                mxid:='';
                                                mxid:=iSendMailx(os, Blat_subject, Blat_body, blat_to, mS_CopyEmail,'archiv@lipoelastic.com','2140000101', Blat_File,mDivision_ID,mIssuedInvoice);
                                                if mxid<>'' then begin
                                                        mi:=os.SQLExecute('update issuedinvoices set x_SendEmail$Date=' +NxFloatToIBStr(Now) + ', X_Email_ID=' + QuotedStr(mxid) + ' where id=' + quotedstr(mIssuedInvoice.oid));
                                                end else begin
                                                        LogInfoStr:= LogInfoStr + chr(13) + ExceptionMessage + ' Chyba - Nezapsání datumu,  ';
                                                        mi:=os.SQLExecute('UPDATE IssuedInvoices set X_SendEmail$Date=36527 WHERE id=' + quotedstr(mIssuedInvoice.oid));
                                                end;


                                            mEmailu:=mEmailu+1;
                                        except
                                            LogInfoStr:= LogInfoStr + chr(13) + ExceptionMessage + ' Chyba - Neodeslání emailu,  ';
                                            //mi:=os.SQLExecute('UPDATE IssuedInvoices set X_SendEmail$Date=36527 WHERE id=' + quotedstr(mIssuedInvoice.oid));
                                        end;
                                      //except
                                      //      LogInfoStr:= LogInfoStr + chr(13) + mS_docnumber +' - Chyba na dokladu , v cyklu na počtu ' + inttostr(mpocet) + ' na dokladu ' + mIIs.Strings[i] + ' Firma ' + mIssuedInvoice.GetFieldValueAsString('Firm_id.Name') +  ' nevytvořil soubor';
                                      //      //mi:=os.SQLExecute('UPDATE IssuedInvoices set X_SendEmail$Date=36527 WHERE id=' + quotedstr(mIssuedInvoice.oid));
                                      //end;
                                  finally
                                      mPrintList.free;
                                  end;
                              end else begin
                                LogInfoStr:= LogInfoStr + chr(13) + mS_docnumber +' - Nemá email, neposílám';
                                 mi:=os.SQLExecute('UPDATE IssuedInvoices set X_SendEmail$Date=36527 WHERE id=' + quotedstr(mIssuedInvoice.oid));
                              end;
                              mpocet:=mpocet+1;
                            finally
                                 mBO_Country.free;
                            end;


                    finally
                          LogInfoStr:= LogInfoStr + chr(13) + mS_docnumber +' - Ukončení zpracování , v cyklu na počtu ' + inttostr(mpocet) + ' na dokladu ' +mIIs.Strings[i];
                    end;
                    Blat_File.free;
            end;
          end;
      finally


      end;

 //     mi:=os.SQLExecute(format('UPDATE IssuedInvoices set X_SendEmail$Date=36527 WHERE (docdate$date<=%S) and X_SendEmail$Date<100',[NxFloatToIBStr(Int(Now()-1))])) ;

      Success := True;
      LogInfoStr:= LogInfoStr + chr(13) + 'Odesláno ' + IntToStr(mEmailu)+ ' emailů z '+IntToStr(mZaznamu)+' vystavených';

  except
     Success := False;
     LogInfoStr:= 'Odesláno ' + IntToStr(mEmailu)+ ' emailů z '+IntToStr(mZaznamu)+' vystavených' + chr(13)+ 'Problematický záznam ID "' + cDocId + '"' + chr(13) + ExceptionMessage;
//      LogInfoStr := format('Odesláno %i emailů z vystavených %j', [IntToStr(mEmailu), IntToStr(mZaznamu)]) + ExceptionMessage;
     NxScriptingLog.WriteEventFmt(logError, 'abra.eu.mask.nazaplaceno1/Nezaplaceno1.Odeslani_dokladu_auto(), Chyba:: %s', [ExceptionMessage]);
  end;
  mpocet:=0;
 if mShowMsg then NxShowSimpleMessage(LogInfoStr,nil);
end;




 function AttachFile(AOS: TNxCustomObjectSpace; const AFileName: string; var AAttachmentColl: TNxCustomBusinessMonikerCollection): string;
var
  mFS: TFileStream;
  mAttach, mContent: TNxCustomBusinessObject;
  mMon: TNxBusinessMoniker;
begin
  Result := '';
  if FileExists(AFileName) then begin
    mFS := TFileStream.Create(AFileName, fmOpenRead);
    try
      mAttach := AAttachmentColl.AddNewObject;
      mAttach.SetFieldValueAsString('FileName', ExtractFileName(AFileName));
      mAttach.SetFieldValueAsInteger('FileSize', mFS.Size);
      mMon := mAttach.GetMonikerForFieldCode(mAttach.GetFieldCode('Content_ID'));
      if NxIsEmptyOID(mMon.OID) then begin
        mContent := AOS.CreateObject(Class_EmailSentAttachContent);
        mContent.New;
        mContent.Prefill;
        mMon.BindToObject(mContent);
      end;
      mContent := mAttach.GetMonikerForFieldCode(mAttach.GetFieldCode('Content_ID')).BusinessObject;
      TNxCustomBlob(mContent).BlobData.CopyFrom(mFS, mFS.Size);
      Result := mAttach.OID;
    finally
      mFS.Free;
    end;
  end
  else
    RaiseException('Neexistuje příloha pro email datove schranky: ' + AFileName);
end;



 function iSendMail(AOS : TNxCustomObjectSpace; const ASubject : string; const ABody : string; ATo : string; AFrom : string = '';afilename:string):string;
var
  mBO, mRecipient : TNxCustomBusinessObject;
  mAttachmentColl: TNxCustomBusinessMonikerCollection ;
  mSL : TStringList;
  i : integer;
begin
  result:='';
  mBO := AOS.CreateObject('5C1HWDQDR3J4NAAYZRO5PWHLWK');
  try
    mBO.New;
    mBO.Prefill;
    if not NxIsBlank(AFrom) then
      mBO.SetFieldValueAsString('EmailAccount_ID','1000000101');
    mBO.SetFieldValueAsString('Subject', ASubject);
    mBO.SetFieldValueAsInteger('BodySavedAs', 1);
    mBO.SetFieldValueAsString('Body', ABody);

    mBO.SetFieldValueAsInteger('SentState', 0);
    mBO.SetFieldValueAsString('Division_ID', '1000000101');
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



      //  mAttachmentColl := mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Attachments'));
      //  AttachFile(AOS, afilename, mAttachmentColl);


 mBO.Save;
 result:=mbo.OID;
  finally
    mBO.Free;
  end;
end;




procedure Odeslani_dokladu_auto(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
  anameISDOC:string;
  cSQLCmd : string;
  mIssuedInvoice : TNxCustomBusinessObject;
  mIIs : TStringList;
  mPrintList:TStringList;
  i : integer;
  emailTo : string;
  asubject,ABody,ATo,AFrom:string;
  mBO_Vzor: TNxCustomBusinessObject;
  zkratka:string;
  blat_from,blat_to, Blat_subject,Blat_body, Blat_FileIsdoc:string;
  Blat_File:tstringlist;
  aname,anameIdoc:string;
  msestava:string;
  cDocId:string;
  mpocet:integer;
    mS_to,mS_SMTP,mS_User,mS_pasword,mS_CopyEmail,mS_BccEmail,ms_Email:string;
    MBO_text,mBO_Country,mBO_Universal:TNxCustomBusinessObject;
    mS_text:string;
    mS_port:Integer;
    mS_Email_from:string;
    mS_body:string;
    mS_docnumber:string;
    mR1,mr:TStringList;
    M_Context:tnxcontext;
    mS_zapati:string;
    mID_country:string;
    mB_result:boolean;
    mi:integer;
    mBoolean:Boolean;
    mZaznamu,mEmailu:integer ;
    mNameFile:string;
    mdivision_ID:string;
    mXID:string;
begin
//  NxScriptingLog.EnterSection('abra.eu.mask.nazaplaceno1/Nezaplaceno1.Odeslani_dokladu_auto()', logNotice);

      LogInfoStr := '';
      mpocet:=0;
      mEmailu:=0;
      mIIs := TStringList.Create;
      cDocId := '';

      try

          //mB_result:=InputQuery('AA','AA',format(cSQLIssuedInvoices,[NxFloatToIBStr(Int(Now())),NxFloatToIBStr(Int(Now())+1)])) ;
          //OS.SQLSelect(format(cSQLIssuedInvoices,[NxFloatToIBStr(Int(Now()-1)),NxFloatToIBStr(Int(Now()))]), mIIs);
          // Výše zmiňované omezení na 30 dní zpět, dále upraveno, aby dnešek neodesílal
          cSQLCmd := format(cSQLIssuedInvoices,[NxFloatToIBStr(Int(Now()-30)),NxFloatToIBStr(Int(Now()-1))]);
          OS.SQLSelect(cSQLCmd, mIIs);

          Zpracovani_dokladu(OS,Success,LogInfoStr,mIIs,False);

      finally


         mIIs.Free;
      end;

  mpocet:=0;

end;


 function iSendMailx(AOS : TNxCustomObjectSpace; const ASubject : string; const ABody : string; ATo : string;mS_CopyEmail:string;mS_BccEmail:string; AFrom : string = '';afilename:TStringList;mDivision_ID:string;mBO_source:TNxCustomBusinessObject):string;
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
        mRecipient.SetFieldValueAsString('email', 'archiv@lipoelastic.com');
//        mRecipient.SetFieldValueAsString('email', mSL.Strings[i]);
  //    end;
  //  finally
  //    mSL.Free;
  //  end;
    if afilename.count>0 then begin
           mAttachments := mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Attachments'));
           for i := 0 to afilename.Count - 1 do begin
                if (afilename.Strings[i] <> '') then begin
                      TNxEmailSent(mbo).AttachFile(afilename.Strings[i]);
                end;
           end;
    end;



    mbo.save;
    result:=mbo.oid;
 //   mSite.ShowDynForm('KJAGOM3EAOI45GTB45MXJQTD0S', Nil, Nil, False, 'DoEdit;'+mbo.oid);

       // NxShowSimpleMessage('Saved',nil)
    finally
       mbo.free;
    end;
end;




 function iPrintDocument(Obj:TNxCustomBusinessObject;ADynCLSID:string;ReportID:string;Acontext:TNxContext;mprintlist:TStrings;AName:string):string;
var
        mOLEApp: Variant;
        mCommand: Variant;
        mCond: Variant;
        FName:string;
        mbo: TNxCustomBusinessObject;
        mDynCLSID:string;
begin
        if  NxIsBlank(ADynCLSID) then begin
            mDynCLSID := Obj.DefaultDynSourceID;
        end else begin
            mDynCLSID:=ADynCLSID;
        end;
        try
                mOLEApp := GetAbraOLEApplication;
                        mCommand := mOLEApp.CreateCustomCommand(mDynCLSID);  // ZL
                        mCond := mCommand.ConstraintByID('ID');
                        mCond.UsedKind := 1;
                        mCond.Value := QuotedStr(Obj.OID);
                mCommand.Execute;
        finally
        end;
       try
       // if not (mCommand.RowSets[0].EOF) then
       //         begin
                        FName:=GetFileNameBOLog(Obj,aname);
                        mCommand.Print(ReportID,8,NxGetTempDir,FName);
       //         end;
             //   NxPrintByIDs(Acontext, mPrintList, mDynCLSID, ReportID, rtofile, pekpdf, NxGetTempDir, FName) ;


                result:=NxGetTempDir+FName;
        finally

        end;
end;

function GetFileNameBOLog(mBO:TNxCustomBusinessObject;aname:string):string;
var s:string;
begin
        s:=aname;
        s:=NxRemoveDiacritics(s);
                while pos('.',s)>0 do delete(s,pos('.',s),1);
                while pos('/',s)>0 do delete(s,pos('/',s),1);
                while pos('-',s)>0 do delete(s,pos('-',s),1);
                while pos(':',s)>0 do delete(s,pos(':',s),1);
                while pos(',',s)>0 do delete(s,pos(',',s),1);
                while pos(' ',s)>0 do delete(s,pos(' ',s),1);
                while pos('"',s)>0 do delete(s,pos('"',s),1);
                result:=s+'.pdf';
end;


begin
end.