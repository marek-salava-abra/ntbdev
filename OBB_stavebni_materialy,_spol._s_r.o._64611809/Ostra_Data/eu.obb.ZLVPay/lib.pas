procedure ZLVPay(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList:TStringList;
 i:integer;
 mIDI:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
 mCopy, mCarbonCopy:string;
begin
  mList:=TStringList.Create;
  os.SQLSelect(Format('SELECT A.ID FROM IssuedDInvoices A left join periods p on p.id=a.period_id WHERE p.closing=''N'' and A.X_Email=''N'' and A.X_Paid=''A'' and '+
               '(EXISTS (SELECT 1 FROM PaymentsForDocument_VIEW PFD   WHERE (PFD.DocDate$DATE >= %s) '+
               ' and PFD.PDocumentType = '+Quotedstr('10')+'  and PFD.PDocument_ID = A.ID))',[IntToStr(Trunc(Date-14))]),mList);
  for i:=0 to mlist.count-1 do begin
      mIDI:=OS.CreateObject(Class_IssuedDepositInvoice);
      mIDI.load(mlist.strings[i],nil);
      mCopy:='';
      mCarbonCopy:='';
      mRows:=midi.GetLoadedCollectionMonikerForFieldCode(midi.GetFieldCode('Rows'));
      if NxIsValidEMail(midi.GetFieldValueAsString('Firm_ID.X_bustransaction_ID.U_email'),false) then mCopy:=midi.GetFieldValueAsString('Firm_ID.X_bustransaction_ID.U_email');
      if NxIsValidEMail(mrows.BusinessObject[0].GetFieldValueAsString('Division_ID.Address_id.email'),false) then mCarbonCopy:= mrows.BusinessObject[0].GetFieldValueAsString('Division_ID.Address_id.email');
      if mIDI.GetFieldValueAsFloat('PaidAmount')>=mIDI.GetFieldValueAsFloat('Amount') then begin
        SendInternalMail(OS, 'ondrej.slosar@obb.cz',
                             mCopy,
                             mCarbonCopy,
                             'Plně uhrazený zálohový list '+mIDI.DisplayName+' pro firmu '+midi.GetFieldValueAsString('Firm_ID.Name'),
                             'Byl zaplacen zálohový list na částku '+FormatFloat('0.00,',mIDI.GetFieldValueAsFloat('Amount'))+' '+mIDI.GetFieldValueAsString('Currency_ID.code')+'Daňový doklad (DZV) bude vystaven automaticky a bude zaslán emailem.',
                             '',
                             Midi.GetFieldValueAsString('Firm_ID'),
                             mrows.BusinessObject[0].GetFieldValueAsString('Division_ID'),
                             '');
        midi.SetFieldValueAsBoolean('X_Email',True);
      end else begin
        SendInternalMail(OS, 'ondrej.slosar@obb.cz',
                             mCopy,
                             mCarbonCopy,
                             'Částečně uhrazený zálohový list '+mIDI.DisplayName+' pro firmu '+midi.GetFieldValueAsString('Firm_ID.Name'),
                             'Byl částečně zaplacen zálohový list na částku '+FormatFloat('0.00,',mIDI.GetFieldValueAsFloat('Amount'))+' '+mIDI.GetFieldValueAsString('Currency_ID.code')+'. Uhrazená částka je '+FormatFloat('0.00,',mIDI.GetFieldValueAsFloat('PaidAmount'))+' '+mIDI.GetFieldValueAsString('Currency_ID.code')+ 'Protože nebyla uhrazena celá částka zálhové listu, musí být daňový doklad (DZV) vystaven ručně účetními' ,
                             '',
                             Midi.GetFieldValueAsString('Firm_ID'),
                             mrows.BusinessObject[0].GetFieldValueAsString('Division_ID'),
                             '');
        midi.SetFieldValueAsBoolean('X_Email',False);
        Midi.SetFieldValueAsBoolean('X_Paid',false);
      end;
      midi.save;
      midi.free;

  end;

  Success := True;
  LogInfoStr := mlist.DelimitedText;
end;


procedure SendInternalMail(AOS:TNxCustomObjectSpace; ATo:String; ACC:String; ABCC:String; ASubject:String; ABody:String; AAtachement:String; AFirm_ID:String; ADivision_ID:String; ABusTransaction_ID:String);
Var
  mMailBO:TNxCustomBusinessObject;
  mMRecipients:TNxCustomBusinessMonikerCollection;
  mMailRecipient:TNxCustomBusinessObject;
begin
  if not(ato='') then begin
     mMailBO:=AOS.CreateObject('5C1HWDQDR3J4NAAYZRO5PWHLWK');
     mMailBO.New;
     mMailBO.Prefill;
     mMailBO.SetFieldValueAsString('EmailAccount_ID','3000000101');
     mMailBO.SetFieldValueAsString('Subject',ASubject);
     mMailbo.SetFieldValueAsInteger('SentState',1);
     mMailBO.SetFieldValueAsString('Body',ABody);
     mMailBO.SetFieldValueAsString('Firm_ID',AFirm_ID);
     mMailBO.SetFieldValueAsString('Division_ID',ADivision_ID);
     mMailBO.SetFieldValueAsString('BusTransaction_ID',ABusTransaction_ID);
     mMailBO.SetFieldValueAsBoolean('X_dont_delete',False);
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
      if FileExists(AAtachement) then TNxEmailSent(mMailBO).AttachFile(AAtachement);

     end;




     mMailBO.Save;
     mMailBO.free;

  end;
end;

begin
end.