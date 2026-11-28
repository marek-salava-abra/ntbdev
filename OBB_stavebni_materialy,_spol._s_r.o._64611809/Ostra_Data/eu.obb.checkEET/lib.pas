procedure CheckEET (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList:TStringList;

begin
  mList:=TStringList.Create;
  OS.SQLSelect(Format('select id from EETTurnovers where not(turnoverstate=2) and TurnoverDateTime$DATE=%s ',[IntToStr(Trunc(Date))]),mList);
  //OS.SQLSelect(Format('select id from EETTurnovers where not(turnoverstate=2) and TurnoverDateTime$DATE=%s ',[IntToStr(Trunc(42755))]),mList);
  if mList.Count>0 then begin
    CFxReportManager.PrintByIDs(NxCreateContext(OS),mlist,'YGN2HJZSP2BO3CLP5DNU0YOAAC','7J10000001',rtoFile,pekPDF,NxGetTempDir,'NeodeslaneTrzbyEET.pdf');
    SendInternalMail(OS,'ondrej.slosar@obb.cz;martina.kucerova@obb.cz','','',
                        'Nalezeny neodeslané tržby EET! Připojena příloha','' ,NxGetTempDir+'\NeodeslaneTrzbyEET.pdf',
                        'AAA1000000','4100000101','',1);
  end;
  if mList.Count=0 then begin
      SendInternalMail(OS,'ondrej.slosar@obb.cz;martina.kucerova@obb.cz','','',
                        'Kontrola EET dnes nenašla neodeslané tržby','' ,'',
                        'AAA1000000','4100000101','',1);

  end;
  Success := True;
  LogInfoStr := '';
end;
procedure SendInternalMail(AOS:TNxCustomObjectSpace; ATo:String; ACC:String; ABCC:String;
                           ASubject:String; ABody:String; AAtachement:String; AFirm_ID:String; ADivision_ID:String; ABusOrder_ID:String; aBodySavedAs:Integer);
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
     mMailBO.SetFieldValueAsString('BodySavedAs',IntToStr(aBodySavedAs));
     mMailbo.SetFieldValueAsInteger('SentState',1);
     mMailBO.SetFieldValueAsString('Body',ABody);
     mMailBO.SetFieldValueAsString('Firm_ID',AFirm_ID);
     mMailBO.SetFieldValueAsString('Division_ID',ADivision_ID);
     mMailBO.SetFieldValueAsString('BusOrder_ID',ABusOrder_ID);
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



     mMailBO.Save;
     mMailBO.free;

  end;
end;

begin
end.