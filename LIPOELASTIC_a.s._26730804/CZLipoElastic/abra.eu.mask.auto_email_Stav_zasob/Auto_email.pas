     const
mSQL = 'SELECT SSC.ID FROM StoreSubCards SSC left join StoreCards SC on sc.id=SSC.StoreCard_id WHERE (ssc.quantity > 0 ) and (sc.X_Obchodni_pripad = ''1V00000101'')' ;
mSQL_dotaz='select %s from %s where clsid=%s and code=%s';



{cSQLIssuedInvoices1 = 'SELECT A.ID FROM ' +
                'IssuedInvoices A ' +
                'LEFT JOIN Firms F ON F.ID=A.Firm_ID ' +
                'WHERE (F.X_Hromadna_fakturace is null) and (A.X_Datum_odeslani<3) ';

 }






procedure Odeslani_dokladu_auto(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
  mIssuedInvoice : TNxCustomBusinessObject;
  mIIs : TStringList;
  mPrintList:TStringList;
  i : integer;
  emailTo : string;
  asubject,ABody,ATo,AFrom:string;
  mBO_Vzor: TNxCustomBusinessObject;
  zkratka:string;
  blat_from,blat_to, Blat_subject,Blat_body, Blat_File:string;
  aname:string;
  msestava:string;
  mpocet:integer;
    mS_to,mS_SMTP,mS_User,mS_pasword,mS_CopyEmail,ms_Email:string;
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
    mOld_Blat_to :string;
begin
//  NxScriptingLog.EnterSection('abra.eu.mask.nazaplaceno1/Nezaplaceno1.Odeslani_dokladu_auto()', logNotice);
        mIIs := TStringList.Create;
        try
          mOld_Blat_to:=':';
          //mB_result:=InputQuery('AA','AA',format(cSQLIssuedInvoices,[NxFloatToIBStr(Int(Now())),NxFloatToIBStr(Int(Now())+1)])) ;
          OS.SQLSelect(mSQL, mIIs);




                                         mBO_Universal:=mIssuedInvoice.ObjectSpace.CreateObject('4J5FINKNYNDL3C5P00CA141B44');
                                         try
                                         mBO_Universal.load('1200000101',nil);

                                                    mS_to:='martin.skacel@abra.eu';
                                                   m_Context.free;
                                                      try  // smtp
                                                        mr1:=TStringList.create;
                                                        mIssuedInvoice.ObjectSpace.SQLSelect(format(mSQL_dotaz,['name','defrolldata',quotedstr('CD1AQKBI01J4D0BAA13PP3QDDC'),quotedstr('SMTP')]),mr1);
                                                        if mr1.Count=1 then mS_SMTP:=mr1.Strings[0];
                                                      finally
                                                        mr1.free;
                                                      end;
                                                      try  // uživatel
                                                        mr1:=TStringList.create;
                                                        mIssuedInvoice.ObjectSpace.SQLSelect(format(mSQL_dotaz,['name','defrolldata',quotedstr('CD1AQKBI01J4D0BAA13PP3QDDC'),quotedstr('USER')]),mr1);
                                                        if mr1.Count=1 then mS_User:=mr1.Strings[0];
                                                      finally
                                                        mr1.free;
                                                      end;
                                                      try  // heslo
                                                        mr1:=TStringList.create;
                                                        mIssuedInvoice.ObjectSpace.SQLSelect(format(mSQL_dotaz,['name','defrolldata',quotedstr('CD1AQKBI01J4D0BAA13PP3QDDC'),quotedstr('Pasword')]),mr1);
                                                        if mr1.Count=1 then mS_pasword:=mr1.Strings[0];
                                                      finally
                                                        mr1.free;
                                                      end;
                                                      try  // port
                                                        mr1:=TStringList.create;
                                                        mIssuedInvoice.ObjectSpace.SQLSelect(format(mSQL_dotaz,['name','defrolldata',quotedstr('CD1AQKBI01J4D0BAA13PP3QDDC'),quotedstr('Port')]),mr1);
                                                        if mr1.Count=1 then mS_Port:=strtoint(mr1.Strings[0]);
                                                      finally
                                                        mr1.free;
                                                      end;
                                                        if mS_Email='' then begin
                                                              try  // odchozi_email
                                                              mr1:=TStringList.create;
                                                              mIssuedInvoice.ObjectSpace.SQLSelect(format(mSQL_dotaz,['name','defrolldata',quotedstr('CD1AQKBI01J4D0BAA13PP3QDDC'),quotedstr('Email_from')]),mr1);
                                                              if mr1.Count=1 then mS_Email_from:=mr1.Strings[0];
                                                            finally
                                                              mr1.free;
                                                            end;
                                                         end;
                                                      try  // kopie emailu
                                                        mr1:=TStringList.create;
                                                        mIssuedInvoice.ObjectSpace.SQLSelect(format(mSQL_dotaz,['name','defrolldata',quotedstr('CD1AQKBI01J4D0BAA13PP3QDDC'),quotedstr('Copy_email')]),mr1);
                                                        if mr1.Count=1 then mS_CopyEmail:=mr1.Strings[0];

                                                      finally
                                                        mr1.free;
                                                      end;
                                         finally
                                              mBO_Universal.free;
                                         end;














                                  Blat_to:='martin.skacel@abra.eu';
                                  mS_CopyEmail:='martin.skacel@abra.eu';
                                  // ************************************
                                  //mstorecard_id:= mstorecard.GetFieldValueAsString('ID');
                                  //Blat_to:=mFirm_ID ;
                                  Blat_subject:='Přehled ' ;
                                  Blat_body:=     'Přehled';
                                 //  NxShowSimpleMessage('mam asponprvní doklad',nil);




                                  AName := 'Přehled.pdf' ;
                                  mSestava:='2720000101';
                                  NxScriptingLog.WriteEvent(logDebug, 'Bude se tisknout ...');

                                  AName := 'Priloha.pdf' ;
                                  CFxReportManager.PrintByIDs(NxCreateContext(OS),mIIs,'GAWVAN4GFNDL342T01C0CX3FCC', mSestava, rtofile, pekPDF,NxGetTempDir,aname);
                                  Blat_File:=NxGetTempDir+'\'+aname;
                                  CFxInternet.SMTPSendMailWithMoreFiles(1,mS_User,mS_pasword, mS_SMTP,mS_Port,mS_Email_from,blat_to,mS_CopyEmail,'' ,Blat_subject, Blat_body,2, Blat_File);






        finally
          mIIs.Free;
        end;
      Success := True;

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