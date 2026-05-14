{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mDate:Extended;
 mOrder_ID, mInvoice_ID, mBody, mSubject, mTO, fName:string;
 mCurrBO, mTextBO, mIIBO:TNxCustomBusinessObject;
 mInvoiceList:TStringList;
begin
  //jana.novotna@naradi-simon.cz
  if self.GetFieldValueAsString('DocQueue_ID')='8RC0000101' then begin
    self.GetOriginalValue_1('X_LP_DeliveredAt',mDate);
    if (mdate=0) and (self.GetFieldValueAsDateTime('X_LP_DeliveredAt')>0) then begin
      mOrder_ID:=self.ObjectSpace.SQLSelectFirstAsString('Select max(provide_id) from storedocuments2 where parent_id='+QuotedStr(self.OID),'');
      mInvoice_ID:=self.ObjectSpace.SQLSelectFirstAsString('select max(parent_id) from issuedinvoices2 where provide_id='+QuotedStr(self.OID),'');
      if not(NxIsEmptyOID(mOrder_ID)) and not(NxIsEmptyOID(mInvoice_ID)) then begin
       //mBody:='Objednávka byla doručena dne '+DateTimeToStr(self.GetFieldValueAsDateTime('X_LP_DeliveredAt'))+' Přepravce '+self.GetFieldValueAsString('TransportationType_ID.Name');
       mInvoiceList:=TStringList.create;
       mInvoiceList.Add(mInvoice_ID);
       mIIBO:=self.ObjectSpace.CreateObject(Class_IssuedInvoice);
       mIIBO.Load(mInvoice_ID,nil);
       mCurrBO:=self.ObjectSpace.CreateObject(Class_ReceivedOrder);
       mCurrBO.Load(mOrder_ID,nil);
       mTextBO:=self.ObjectSpace.CreateObject('DCHDUXZ0S3RO1DVWDVB0PD51U0');
       mTextBO.Load('LTUB000101',nil);
       mSubject:=mTextBO.GetFieldValueAsString('X_Subject');
       mBody:=mTextBO.GetFieldValueAsString('X_Note');
       mSubject:=NxSearchReplace(mSubject, '#CISOBJ#',    mCurrBO.DisplayName,[srAll]);
       mBody:=NxSearchReplace(mBody, '#CISOBJ#',    mCurrBO.DisplayName,[srAll]);
       mTO:=mCurrBO.GetFieldValueAsString('FirmOffice_ID.Address_ID.Email');
       fname:=NxSearchReplace(mIIBO.DisplayName,'/','-',[srall])+'.pdf';
       CFxReportManager.PrintByIDs(NxCreateContext_1(Self),mInvoiceList,GetDynSource(self.ObjectSpace,'4N70000101'),'4N70000101',rtoFile,pekPDF,NxGetTempDir,fName);
       SendInternalMail(Self.ObjectSpace,mto,
                           '','',
                           mSubject,mBody,NxGetTempdir+'\'+fName,'', mCurrBO.GetFieldValueAsString('Firm_ID'),
                           '1400000101','','1300000101',mCurrBO.OID,mCurrBO.GetFieldValueAsString('U_OrderState_ID'));
       if FileExists(NxGetTempdir+'\'+fName) then DeleteFile(NxGetTempdir+'\'+fName);
       //neposílat novotné odeslat fakturu
       mCurrBO.free;
       mIIBO.free;
      end;
    end;
  end;
end;


procedure SendInternalMail(AOS:TNxCustomObjectSpace; ATo:String; ACC:String; ABCC:String;
                           ASubject:String; ABody:String; AAtachement,AAtachement2:String; AFirm_ID:String; ADivision_ID:String; ABusTransaction_ID:String; aAccount_ID, aOrder_ID, aOrderState_ID:string);
Var
  mMailBO,mUserXLink:TNxCustomBusinessObject;
  mMRecipients:TNxCustomBusinessMonikerCollection;
  mMailRecipient:TNxCustomBusinessObject;
begin
  if not(ato='') then begin
     mMailBO:=AOS.CreateObject('5C1HWDQDR3J4NAAYZRO5PWHLWK');
     mMailBO.New;
     mMailBO.Prefill;
     mMailBO.SetFieldValueAsString('EmailAccount_ID',aAccount_ID);
     mMailBO.SetFieldValueAsString('Subject',ASubject);
     mMailBO.SetFieldValueAsInteger('BodySavedAs',1);
     mMailbo.SetFieldValueAsInteger('SentState',1);
     mMailBO.SetFieldValueAsString('Body',ABody);
     mMailBO.SetFieldValueAsString('Firm_ID',AFirm_ID);
     mMailBO.SetFieldValueAsString('Division_ID',ADivision_ID);
     mMailBO.SetFieldValueAsString('BusTransaction_ID',ABusTransaction_ID);
     mMailBO.SetFieldValueAsString('X_ReceivedOrderID',aOrder_ID);
     mMailBO.SetFieldValueAsString('X_OrderState_ID',aOrderState_ID);
     mMRecipients:=mMailBO.GetCollectionMonikerForFieldCode(mMailBO.GetFieldCode('Recipients'));

     mMailRecipient:=mMRecipients.AddNewObject;
     mMailRecipient.SetFieldValueAsString('Email',ATo);
     mMailRecipient.SetFieldValueAsInteger('EmailType',0);
     if not(acc='') then begin
     mMailRecipient:=mMRecipients.AddNewObject;
     mMailRecipient.SetFieldValueAsString('Email',ACC);
     mMailRecipient.SetFieldValueAsInteger('EmailType',1);
     end;
     if not(ABCC='') then begin
     mMailRecipient:=mMRecipients.AddNewObject;
     mMailRecipient.SetFieldValueAsString('Email',ABCC);
     mMailRecipient.SetFieldValueAsInteger('EmailType',2);
     end;

     if not(AAtachement='') then begin
      TNxEmailSent(mMailBO).AttachFile(AAtachement);
     end;
     if not(AAtachement2='') then begin
      TNxEmailSent(mMailBO).AttachFile(AAtachement2);

     end;
     mMailBO.Save;
     mUserXLink := aOS.CreateObject(Class_UserXLink);
      try
        mUserXLink.New;
        mUserXLink.Prefill;
        mUserXLink.SetFieldValueAsString('SourceCLSID', Class_ReceivedOrder);
        mUserXLink.SetFieldValueAsString('Source_ID', aOrder_ID);
        mUserXLink.SetFieldValueAsString('DestinationCLSID', Class_EmailSent);
        mUserXLink.SetFieldValueAsString('Destination_ID', mMailBO.OID);
        mUserXLink.SetFieldValueAsBoolean('DisplayAsSystem', True);
        mUserXLink.SetFieldValueAsString('Description',ASubject);
        mUserXLink.Save;
      finally
        mUserXLink.Free;
      end;
     mMailBO.free;

  end;
end;



function GetDynSource (AOS : TNxCustomObjectSpace; AValue : string) : String;

const
  cSQL = 'SELECT DataSource FROM Reports WHERE ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [ AValue]), mList);
    if mList.Count > 0 then
      Result := (mList.Strings[0]);
  finally
    mList.Free;
  end;
end;

begin
end.