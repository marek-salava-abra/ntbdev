




{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mPrintList:TStringList;
 mRows:TNxCustomBusinessMonikerCollection;
 i:integer;
 mDQCode, mFileName, mTo:string;
begin
  if osNew in self.State then begin
    mDQCode:='';
    mRows:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('Rows'));
    for i:=0 to mrows.Count-1 do begin
       if NxIsBlank(mDQCode) then mDQCode:=GetDQCode(self.ObjectSpace,mRows.BusinessObject[i].GetFieldValueAsString('Provide_ID'));
    end;
    if mDQCode='OPND' then begin
      if self.GetFieldValueAsString('Firm_ID.OrgIdentNumber')='05665817' then mTO:='ndservis@spedos.cz;vinklarkova@spedos.cz';
      if self.GetFieldValueAsString('Firm_ID.OrgIdentNumber')='31708587' then mTO:='ndsk@spedos.cz;vinklarkova@spedos.cz';
      mPrintList:=TStringList.create;
      mPrintList.Add(self.OID);
      mFileName:=NxSearchReplace(self.DisplayName,'/','-',[srall])+'.pdf';
      CFxReportManager.PrintByIDs(NxCreateContext_1(self), mPrintList, GetDynSource(self.ObjectSpace,'ML00000101'), 'ML00000101', rtoFile, pekPDF, NxGetTempDir, mFileName);
      SendInternalMail(self.ObjectSpace, mTO,'',
                               'Nový DL '+self.DisplayName,'',
                               NxGetTempDir+'\'+mFileName,self.GetFieldValueAsString('Firm_ID'),mrows.BusinessObject[0].GetFieldValueAsString('Division_ID'),mrows.BusinessObject[0].GetFieldValueAsString('BusOrder_ID'), '');
    end;
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

function GetDQCode (AOS : TNxCustomObjectSpace; AValue : string) : String;
const
  cSQL = 'SELECT dq.code FROM ReceivedOrders ro left join docqueues dq on dq.id=ro.docqueue_id WHERE ro.ID=''%s'' ';
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