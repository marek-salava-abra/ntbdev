procedure SearchCars (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList, mList2:tStringlist;
 mDateString,mMessage:String;
 mBO:TNxCustomBusinessObject;
 i,j:Integer;
begin
  mList:=TStringList.Create;
  mList2:=Tstringlist.create;
  mDateString:=IntToStr(trunc(Now+30));
  OS.SQLSelect(Format('Select id from trmcars where TechCert$Date=%s ',[mDateString]),mList);
  //OutputDebugString(Format('Select id from trmcars where TechCert$Date=%s ',[mDateString]));
  if mList.count>0 then begin
   for i:=0 to mlist.count-1 do begin
     mBO:=OS.CreateObject(Class_TRMCar);
     mbo.Load(mlist.strings[i],nil);
     mList2.add(mbo.GetFieldValueAsString('RegPlate')+' '+mbo.GetFieldValueAsString('Name')+' '+mbo.GetFieldValueAsString('Brand')+' '+mbo.GetFieldValueAsString('U_modelName')+' '+'Datum platnosti STK: '+FormatDateTime('d.m.yyyy',mbo.GetFieldValueAsDateTime('TechCert$Date')));
     //OutputDebugString(mbo.GetFieldValueAsString('RegPlate')+' '+mbo.GetFieldValueAsString('Name')+' '+mbo.GetFieldValueAsString('Brand')+' '+FormatDateTime('d.m.yyyy',mbo.GetFieldValueAsDateTime('manufact$Date')));
   end;
  end;
  for j:=0 to mList2.count-1 do begin
     mMessage:=mMessage+#13#10+NxSearchReplace(mList2.strings[j],'"','',[srall]);
  end;
   if mList2.count>0 then SendInternalMail(OS, 'ondrej.slosar@obb.cz','patrik.astr@obb.cz','test@obb.cz',
                         'Kontrola platnosti STK','U následujících vozidel bude za 30 dní končit platnost STK: '+#13#10+mMessage,
                         '','','4100000101','');
  Success := True;
  LogInfoStr := ''+Format('Select id from trmcars where TechCert$Date=%s ',[mDateString]);
end;

procedure SearchCarsDZ (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mList, mList2:tStringlist;
 mDateString,mMessage:String;
 mBO:TNxCustomBusinessObject;
 i,j:Integer;
begin
  mList:=TStringList.Create;
  mList2:=Tstringlist.create;
  mDateString:=IntToStr(trunc(Now+30));
 OS.SQLSelect(Format('SELECT  a.id FROM TRMCars A WHERE (A.Hidden = '+Quotedstr('N')+' ) AND '+
                     '(exists (SELECT 1 FROM USERDATA WHERE FIELDCODE=2000027 AND CLSID='+Quotedstr('A0K4JBLYQ5GONHAZFMQBAQ2NMW')+' AND ID = A.ID AND (CAST(STRINGFIELDVALUE AS NUMERIC(18,10)) = %s))) ',[mDateString]),mList);
  if mList.count>0 then begin
   for i:=0 to mlist.count-1 do begin
     mBO:=OS.CreateObject(Class_TRMCar);
     mbo.Load(mlist.strings[i],nil);
     mList2.add(mbo.GetFieldValueAsString('RegPlate')+' '+mbo.GetFieldValueAsString('Name')+' '+mbo.GetFieldValueAsString('Brand')+' '+mbo.GetFieldValueAsString('U_modelName')+' '+'Datum platnosti DZ: '+FormatDateTime('d.m.yyyy',mbo.GetFieldValueAsDateTime('U_dalnicniZ')));
     //OutputDebugString(mbo.GetFieldValueAsString('RegPlate')+' '+mbo.GetFieldValueAsString('Name')+' '+mbo.GetFieldValueAsString('Brand')+' '+FormatDateTime('d.m.yyyy',mbo.GetFieldValueAsDateTime('manufact$Date')));
   end;
  end;
  for j:=0 to mList2.count-1 do begin
     mMessage:=mMessage+#13#10+NxSearchReplace(mList2.strings[j],'"','',[srall]);
  end;
   if mList2.count>0 then SendInternalMail(OS, 'patrik.astr@obb.cz','automat@obb.cz','test@obb.cz',
                         'Kontrola platnosti dálniční známky','U následujících vozidel bude za 30 dní končit platnost dálniční známky '+#13#10+mMessage,
                         '','','4100000101','');
  Success := True;
  LogInfoStr := ''+Format('SELECT  a.id FROM TRMCars A WHERE (A.Hidden = '+Quotedstr('N')+' ) AND '+
                     '(exists (SELECT 1 FROM USERDATA WHERE FIELDCODE=2000027 AND CLSID='+Quotedstr('A0K4JBLYQ5GONHAZFMQBAQ2NMW')+' AND ID = A.ID AND (CAST(STRINGFIELDVALUE AS NUMERIC(18,10)) = %s))) ',[mDateString]);
end;


procedure SendInternalMail(AOS:TNxCustomObjectSpace; ATo:String; ACC:String; ABCC:String; ASubject:String; ABody:String; AAtachement:String; AFirm_ID:String; ADivision_ID:String; ABusTransaction_ID:String);
Var
  mMailBO:TNxCustomBusinessObject;
  mMRecipients:TNxCustomBusinessMonikerCollection;
  mMailRecipient:TNxCustomBusinessObject;
begin
  if NxIsValidEMail(ATo,false) then begin
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