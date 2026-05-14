const
cSQLIssuedOrders = 'SELECT a.firm_id||A.ID FROM ' +
                           'IssuedOrders A ' +
                           'LEFT JOIN Firms F ON F.ID=A.Firm_ID ' +
                           'WHERE  ((A.X_odeslani$date ) <= ' + IntToStr(Round(now())) +  ' ) ' +
                           ' and ((F.X_Hromadna_objednavka<>' + quotedstr('') + ') and (A.X_Odeslano=0 ))' +
                           ' ORDER BY A.Firm_id  ' ;
msqlemail= 'SELECT email FROM Addresses WHERE (ID= ''%s'') ' ;









procedure SendInternalMail(AOS:TNxCustomObjectSpace; ATo:String; ACC:String; ASubject:String; ABody:String; AAtachement, aAtachement2:String; AFirm_ID:String; ADivision_ID:String; ABusOrder_ID:String; AReplyTo:string;);
Var
  mMailBO:TNxCustomBusinessObject;
  mMRecipients:TNxCustomBusinessMonikerCollection;
  mMailRecipient:TNxCustomBusinessObject;
begin
  if not(ato='') then begin
     mMailBO:=AOS.CreateObject('5C1HWDQDR3J4NAAYZRO5PWHLWK');
     mMailBO.New;
     mMailBO.Prefill;
     mMailBO.SetFieldValueAsString('EmailAccount_ID','2100000101');
     mMailBO.SetFieldValueAsString('Subject',ASubject);
     mMailbo.SetFieldValueAsInteger('SentState',1);
     mMailBO.SetFieldValueAsInteger('BodySavedAs',1);
     mMailBO.SetFieldValueAsString('Body',ABody);
     mMailBO.SetFieldValueAsString('Firm_ID',AFirm_ID);
     if not(NxIsEmptyOID(ADivision_ID))then mMailBO.SetFieldValueAsString('Division_ID',ADivision_ID);
     mMailBO.SetFieldValueAsString('BusOrder_ID',ABusOrder_ID);
     mMailBO.SetFieldValueAsString('ReplyTo',AReplyTo);
     mMRecipients:=mMailBO.GetCollectionMonikerForFieldCode(mMailBO.GetFieldCode('Recipients'));

     mMailRecipient:=mMRecipients.AddNewObject;
     mMailRecipient.SetFieldValueAsString('Email',ATo);
     mMailRecipient.SetFieldValueAsInteger('EmailType',0);
     if not(acc='') then begin
     mMailRecipient:=mMRecipients.AddNewObject;
     mMailRecipient.SetFieldValueAsString('Email',ACC);
     mMailRecipient.SetFieldValueAsInteger('EmailType',1);
     end;
     if not(AAtachement='') then begin
      if FileExists(AAtachement) then TNxEmailSent(mMailBO).AttachFile(AAtachement);

     end;
     if not(AAtachement2='') then begin
      if FileExists(AAtachement2) then TNxEmailSent(mMailBO).AttachFile(AAtachement2);

     end;




     mMailBO.Save;
     mMailBO.free;

  end;
end;






procedure Odeslani_dokladu_auto(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);

var
   mIssuedOrder : TNxCustomBusinessObject;
  mIIs, mPrintList,mr : TStringList;
  i : integer;
  emailTo : string;
  asubject,ABody,ATo,AFrom:string;
  mBO_Vzor: TNxCustomBusinessObject;
  zkratka:string;
  blat_from,blat_to, Blat_subject,Blat_body, Blat_File:string;
  aname:string;
  msestava:string;
  blat_to_prew:string;
  memail,aa:string;
  mi:integer;
  mboolean:Boolean;
begin

//  NxScriptingLog.EnterSection('abra.eu.mask.nazaplaceno1/Nezaplaceno1.Odeslani_dokladu_auto()', logNotice);

  try

    try
//      LogInfoStr := '';
      try

        mIIs := TStringList.Create;
        try
//         InputQuery('AAA','SSS', cSQLIssuedOrders);
          OS.SQLSelect(cSQLIssuedOrders, mIIs);
//          NxShowSimpleMessage('Vraceno ' + inttostr(mIIs.Count) + ' řádků',nil);



//          NxScriptingLog.WriteEventFmt(logDebug, 'Vraceno %d radku z dotazu "%s"', [mIIs.Count, cSQLIssuedInvoices]);
          mPrintList := TStringList.Create;
          mIssuedOrder := OS.CreateObject('CDMK5QAWZZDL342X01C0CX3FCC');
                //NxShowSimpleMessage('ccc',nil);
          for i := 0 to mIIs.count-1 do begin
//                 NxShowSimpleMessage('dd',nil);
           memail:='';
            mIssuedOrder.load(copy(mIIs.Strings[i],11,10), nil) ;

            memail:= mIssuedOrder.GetFieldValueAsString('Firm_ID.X_Hromadna_objednavka');

                         Blat_to := mIssuedOrder.GetFieldValueAsString('Firm_ID.X_Hromadna_objednavka');
                     //          nxShowSimpleMessage('fff',nil);
                               mPrintList.add( mIssuedOrder.OID);
              Blat_subject:= 'Objednávky Spedos Vrata ';
              Blat_body:=     'Vážený Dodavateli,'#13#10' '#13#10   +
                              'V příloze Vám posíláme objednávku.'#13#10' '#13#10' '+
                              'Prosím o potvrzení objednávky na emailovou adresu uvedenou v levém dolní části dokladu nejpozději do 2 dnů.'#13#10' '+
                              'Objednávka je generována našim systémem, na tento email neodpovídejte.'#13#10' '+
                              'S pozdravem'#13#10' '#13#10' '+
                              'Spedos Vrata a.s., Hranická 771, 757 01, Valašské Meziříčí'#13#10' '#13#10' '+
                              '----------------------------------------------'#13#10' '+
                  			      'Dear supplier / business partner,'#13#10' '#13#10   +
                              'please see our new order in the attachment.'#13#10' '#13#10' '+
                              'The order is generated automatically by our system, please do not reply to this email.'#13#10' '#13#10' '+
                  			      'Please send your order confirmation to the email address mentioned in the order within 3 days '#13#10' '+
                              'Best Regards,'#13#10' '#13#10' '+
                              'Spedos Vrata a.s., Hranická 771, 757 01, Valašské Meziříčí'#13#10' '#13#10' '+
                              '----------------------------------------------'#13#10' ';
                              AName := 'Objednávka ' + mIssuedOrder.GetFieldValueAsString('Firm_ID.Name')+'.pdf' ;
                             mSestava:='3R00000101';
                            // blat_to:='martin.skacel@abra.eu';

                             CFxReportManager.PrintByIDs(NxCreateContext(OS),mPrintList,'W0NZQGROZZDL342X01C0CX3FCC', mSestava, rtofile, pekPDF,NxGetTempDir,aname);
                             Blat_File:=NxGetTempDir+'\'+aname;
                             //CFxInternet.SMTPSendMailWithMoreFiles(1,'objednavky.vrata','MKzpv561vrata', 'posta.spedos.cz',587,'objednavky.vrata@spedos.cz',blat_to,'mojtekova@spedos.cz','' ,Blat_subject, Blat_body,2, Blat_File);
                             SendInternalMail(os, blat_to,'mojtekova@spedos.cz', Blat_subject,Blat_body,Blat_File,'','','','','');

                              mPrintList.Clear;


                     //                 NxShowSimpleMessage('ggg',nil);
                                mi:=os.SQLExecute('update IssuedOrders set x_odeslano=' + IntToStr(Round(now())) + ' where id=' + quotedstr(mIssuedOrder.OID)) ;


          end;
        finally
          mIIs.Free;
          mPrintList.free;
        end;
      finally
      //    NxScriptingLog.LeaveSection('Hromadna_validace/Zruseni_rezervace.CloseOrders()', logDebug);
      end;
      Success := True;
      //LogInfoStr := '';
    except
      Success := False;
 //     LogInfoStr := ExceptionMessage;
//      NxScriptingLog.WriteEventFmt(logError, 'abra.eu.mask.nazaplaceno1/Nezaplaceno1.Odeslani_dokladu_auto(), Chyba:: %s', [ExceptionMessage]);
    end;
  finally
//    NxScriptingLog.LeaveSection('abra.eu.mask.nazaplaceno1/Nezaplaceno1.Odeslani_dokladu_auto()', logNotice);
  end;
end;


begin
end.

