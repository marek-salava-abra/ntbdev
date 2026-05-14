procedure CreateEmail(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mDivisionList, mIDIList:TStringList;
 i,j:Integer;
 mDivisionBO:TNxCustomBusinessObject;
 mTO, mFileName:string;
begin
  mDivisionList:=TStringList.Create;
  OS.SQLSelect('Select distinct(IDI2.Division_ID) from IssuedDInvoices A left join issueddinvoices2 idi2 on idi2.parent_id=a.id '+
               'WHERE (((A.Amount>=0) and (A.PaidAmount <=0)) or ((A.Amount <0) and (A.PaidAmount >=0))) ',mDivisionList);
  if mDivisionList.count>0 then begin
   for i:=0 to mDivisionList.Count-1 do begin
     mIDIList:=TStringList.create;
     mDivisionBO:=OS.CreateObject(Class_Division);
     mDivisionBO.Load(mDivisionList.Strings[i],nil);
     mTO:=mDivisionBO.GetFieldValueAsString('Address_ID.Email');
     if not(NxIsValidEMail(mTO,false)) then mTO:='gajdos@spedos.cz';
     mFileName:='Stredisko_'+mDivisionBO.GetFieldValueAsString('Code')+'.pdf';
     OS.SQLSelect('Select distinct(A.ID) from IssuedDInvoices A left join issueddinvoices2 idi2 on idi2.parent_id=a.id '+
                   'WHERE (((A.Amount>=0) and (A.PaidAmount <=0)) or ((A.Amount <0) and (A.PaidAmount >=0))) and idi2.division_id='+QuotedStr(mDivisionBO.OID),mIDIList);
     CFxReportManager.PrintByIDs(NxCreateContext(OS), mIDIList, GetDynSource(OS,'U300000001'), 'U300000001', rtoFile, pekPDF, NxGetTempDir, mFileName);
     SendInternalMail(OS, mTO,'',
                               'Nezaplacené zálohové listy '+mDivisionBO.DisplayName,'',
                               NxGetTempDir+'\'+mFileName,'',mDivisionBO.OID,'', '');
     mDivisionBO.free;
     mIDIList.free;

   end;
  end;
  Success := True;
  LogInfoStr := '';
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

procedure SendInternalMail(AOS:TNxCustomObjectSpace; ATo:String; ACC:String; ASubject:String; ABody:String; AAtachement:String; AFirm_ID:String; ADivision_ID:String; ABusOrder_ID:String; AReplyTo:string;);
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
     mMailBO.SetFieldValueAsString('Division_ID',ADivision_ID);
     mMailBO.SetFieldValueAsString('BusOrder_ID',ABusOrder_ID);
     mMailBO.SetFieldValueAsString('ReplyTo',AReplyTo);
     mMRecipients:=mMailBO.GetLoadedCollectionMonikerForFieldCode(mMailBO.GetFieldCode('Recipients'));

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




     mMailBO.Save;
     mMailBO.free;

  end;
end;

begin
end.