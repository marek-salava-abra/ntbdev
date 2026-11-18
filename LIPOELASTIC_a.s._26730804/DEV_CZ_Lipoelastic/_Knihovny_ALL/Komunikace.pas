 function iPrintDocument(Obj:TNxCustomBusinessObject;ReportID:string):string;
var
        FName:string;
        mbo: TNxCustomBusinessObject;
        mDynCLSID:string;
        mPrintList:tstringlist;
        aName,mFileName:string;
        mr:TStringList;
begin
        mPrintList := TStringList.Create;
          try
             mr:=tstringlist.create;
             try
                 obj.ObjectSpace.SQLSelect('select DataSource from Reports where ID=' + QuotedStr(ReportID),mr);
                 if mr.count>0 then begin
                    mDynCLSID:=mr.strings[0];
                 end else begin
                    mDynCLSID := Obj.DefaultDynSourceID;
                 end;
             finally
                 mr.free;
             end;

             mPrintList.Add(Obj.OID);
             AName := Obj.GetFieldValueAsString('Docqueue_ID.CODE') +'-' + inttostr(Obj.GetFieldValueAsInteger('Ordnumber'))  +'-' + Obj.GetFieldValueAsString('Period_id.CODE')+'.pdf' ;
             try
                CFxReportManager.PrintByIDs(NxCreateContext(obj.ObjectSpace),mPrintList,mDynCLSID, ReportID, rtofile, pekPDF,NxGetTempDir,aname);
                mFileName:=NxGetTempDir+'\'+aname;
                result:=mFileName;
              except
              end;
          finally
              mPrintList.free;
          end;
end;




 function iPrintDocumentOLE(Obj:TNxCustomBusinessObject;ADynCLSID:string;ReportID:string;Acontext:TNxContext;mprintlist:TStrings;AName:string):string;
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
                        FName:=aname;
                        mCommand.Print(ReportID,8,NxGetTempDir,FName);
       //         end;
             //   NxPrintByIDs(Acontext, mPrintList, mDynCLSID, ReportID, rtofile, pekpdf, NxGetTempDir, FName) ;


                result:=NxGetTempDir+FName;
        finally

        end;
end;


  function iSendMail(AOS : TNxCustomObjectSpace; const ASubject : string; const ABody : string; ATo : string;mS_CopyEmail:string;mS_BccEmail:string; AFrom : string ;afilename:string;mDivision_ID:string;mBO_source:TNxCustomBusinessObject):string;
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
      {  if not nxisemptyoid(mbo_source.GetFieldValueAsString('Firm_ID')) then begin
             mBO.SetFieldValueAsString('Firm_ID',mbo_source.GetFieldValueAsString('Firm_ID'));
             mBO.SetFieldValueAsString('FirmOffice_ID',mbo_source.GetFieldValueAsString('FirmOffice_ID'));
             mBO.SetFieldValueAsString('Person_ID',mbo_source.GetFieldValueAsString('Person_ID'));
        end;}
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

    if (afilename <> '') then begin
          mAttachments := mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Attachments'));
          TNxEmailSent(mbo).AttachFile(afilename);

    end;



    mbo.save;
   // NxShowSimpleMessage('Vytvořen email: ' + mbo.oid,nil);
    result:=mbo.oid;
 //   mSite.ShowDynForm('KJAGOM3EAOI45GTB45MXJQTD0S', Nil, Nil, False, 'DoEdit;'+mbo.oid);

       // NxShowSimpleMessage('Saved',nil)
    finally
       mbo.free;
    end;
end;






 function iSendMailx(AOS : TNxCustomObjectSpace; const ASubject : string; const ABody : string; ATo : string;mS_CopyEmail:string;mS_BccEmail:string; AFrom : string;afilename:string;mDivision_ID:string;mBO_source:TNxCustomBusinessObject):string;
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
        if not nxisemptyoid(mbo_source.GetFieldValueAsString('Firm_ID')) then begin
             mBO.SetFieldValueAsString('Firm_ID',mbo_source.GetFieldValueAsString('Firm_ID'));
             mBO.SetFieldValueAsString('FirmOffice_ID',mbo_source.GetFieldValueAsString('FirmOffice_ID'));
             mBO.SetFieldValueAsString('Person_ID',mbo_source.GetFieldValueAsString('Person_ID'));
        end;
    mBO.SetFieldValueAsString('Subject', ASubject);
    mBO.SetFieldValueAsInteger('BodySavedAs', 1);
    mBO.SetFieldValueAsString('Body', ABody);

    mBO.SetFieldValueAsInteger('SentState', 1);
    mBO.SetFieldValueAsString('Division_ID', mDivision_ID);
    mSL := TStringList.Create;
    try
      NxTokenToStrings(ATO, ';', mSL);
      //msl:=FNParsestring(Ato,';')
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

    if (afilename <> '') then begin
          mAttachments := mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Attachments'));
          TNxEmailSent(mbo).AttachFile(afilename);

    end;



    mbo.save;
   // NxShowSimpleMessage('Vytvořen email: ' + mbo.oid,nil);
    result:=mbo.oid;
 //   mSite.ShowDynForm('KJAGOM3EAOI45GTB45MXJQTD0S', Nil, Nil, False, 'DoEdit;'+mbo.oid);

       // NxShowSimpleMessage('Saved',nil)
    finally
       mbo.free;
    end;
end;



procedure iSendmsg(AOS : TNxCustomObjectSpace; ABO:TNxCustomBusinessObject;mCLSID:string; const ASubject : string; const ABody : string; ATo : string; AFrom : string = '');
 var
 mBO, mRecipient, mLink : TNxCustomBusinessObject;
  mSL : TStringList;
  i : integer;
 begin
// aBO:= aos.CreateObject('C3V5QDVZ5BDL342M01C0CX3FCC');
// try
//    abo.load(moid,nil);
        mBO := AOS.CreateObject('33XZARXR1BM4L55MOX54NTRBWG');
            try
                mBO.New;
                mBO.Prefill;
                    mBO.SetFieldValueAsString('SenderUser_ID',AFrom);
                    mBO.SetFieldValueAsString('MsgSubject', ASubject);
                    mBO.SetFieldValueAsString('MsgBody', ABody);
                    mBO.SetFieldValueAsDateTime('validtodate$date',now()+14);
                    mBO.SetFieldValueAsBoolean('DeleteAfterDeletingByAll',True);
                    mBO.SetFieldValueAsBoolean('ConfirmReading',False);
                    mSL := TStringList.Create;
                    try
                        NxTokenToStrings(ATO, ';', mSL);
                        for i := 0 to mSL.Count - 1 do begin
                            mRecipient := mBO.GetCollectionMonikerForFieldCode(mBO.GetFieldCode('Recipients')).AddNewObject;
                            mRecipient.SetFieldValueAsInteger('RecipientType', 0);
                            mRecipient.SetFieldValueAsString('SecurityUser_ID', Ato);
                        end;
                    finally
                        mSL.Free;
                    end;
//                    try

//                        for i := 0 to mSL.Count - 1 do begin
                            if mCLSID<>'' then begin
                                    mLink := mBO.GetCollectionMonikerForFieldCode(mBO.GetFieldCode('Links')).AddNewObject;
                                    mLink.prefill;
                                    mLink.SetFieldValueAsInteger('LinkType', 0);
                                    mLink.SetFieldValueAsString('Title', 'Doklad' + abo.DisplayName);
                                    mLink.SetFieldValueAsString('Link', mCLSID + abo.oid);

                            end;
  //                      end;
//                    finally
//                        mSL.Free;
                    //end;


                mBO.Save;
            finally
                mBO.Free;
            end;
//finally
//        abo.free;
//end;
end;


procedure iSendmsgy(AOS : TNxCustomObjectSpace;const ASubject : string;const ABody : string; ATo : string; AFrom : string = '');
 var
 mBO, mRecipient, mLink : TNxCustomBusinessObject;
  mSL : TStringList;
  i : integer;
 begin
// aBO:= aos.CreateObject('C3V5QDVZ5BDL342M01C0CX3FCC');
// try
//    abo.load(moid,nil);
        mBO := AOS.CreateObject('33XZARXR1BM4L55MOX54NTRBWG');
            try
                mBO.New;
                mBO.Prefill;
                    mBO.SetFieldValueAsString('SenderUser_ID',AFrom);
                    mBO.SetFieldValueAsString('MsgSubject', ASubject);
                    mBO.SetFieldValueAsString('MsgBody', ABody);
                    mBO.SetFieldValueAsDateTime('validtodate$date',now()+14);
                    mBO.SetFieldValueAsBoolean('DeleteAfterDeletingByAll',True);
                    mBO.SetFieldValueAsBoolean('ConfirmReading',False);
                    mSL := TStringList.Create;
                    try
                        NxTokenToStrings(ATO, ';', mSL);
                        for i := 0 to mSL.Count - 1 do begin
                            mRecipient := mBO.GetCollectionMonikerForFieldCode(mBO.GetFieldCode('Recipients')).AddNewObject;
                            mRecipient.SetFieldValueAsInteger('RecipientType', 0);
                            mRecipient.SetFieldValueAsString('SecurityUser_ID', Ato);
                        end;
                    finally
                        mSL.Free;
                    end;
//                    try

//                        for i := 0 to mSL.Count - 1 do begin
                         //   if mCLSID<>'' then begin
                         //           mLink := mBO.GetCollectionMonikerForFieldCode(mBO.GetFieldCode('Links')).AddNewObject;
                         //           mLink.prefill;
                         //           mLink.SetFieldValueAsInteger('LinkType', 0);
                         //           mLink.SetFieldValueAsString('Title', 'Doklad' + abo.DisplayName);
                         //           mLink.SetFieldValueAsString('Link', mCLSID + abo.oid);

                         //   end;
  //                      end;
//                    finally
//                        mSL.Free;
                    //end;


                mBO.Save;
            finally
                mBO.Free;
            end;
//finally
//        abo.free;
//end;
end;


begin
end.