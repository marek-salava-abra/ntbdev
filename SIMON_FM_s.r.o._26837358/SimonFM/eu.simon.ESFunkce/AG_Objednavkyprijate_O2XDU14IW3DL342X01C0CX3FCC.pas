uses 'eu.simon.ESFunkce.mail';

procedure InitSite_Hook(Self: TSiteForm);
var
  mAction, mAction2: TBasicAction;
begin
  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actMailZLV';
  mAction.Caption := 'Odešle ZLVE';
  mAction.Hint := 'tlačítko odešle případný ZLV';
  mAction.Category := 'tabList';
  mAction.OnExecute := @MailZLV;

  mAction := Self.GetNewAction;
  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Name := 'actMailDZVE';
  mAction.Caption := 'Odešle DZVE';
  mAction.Hint := 'tlačítko odešle případný DZVE';
  mAction.Category := 'tabList';
  mAction.OnExecute := @MailDZVE;
end;

Procedure MailDZVE(sender:TComponent);
var
 mSite:TSiteForm;
 mZLV_ID, mDZV_ID:string;
 mBO, mZLVBO:TNxCustomBusinessObject;
 mOS:TNxCustomObjectSpace;
 mList, mFileList:TStringList;
 mTextBO:TNxCustomBusinessObject;
 mBody, mSubject, mFileName,  mTO, mFileName2, mAccount_id:string;

begin
 mSite:=TComponent(sender).DynSite;
 mOS:=msite.BaseObjectSpace;
 mBO:=TDynSiteForm(mSite).CurrentObject;
 if Assigned(mbo) then begin
   mZLV_ID:=GetZLV_ID(mOS,mBO.OID);
   if not(NxIsEmptyOID(mZLV_ID)) then begin
      mDZV_ID:=GetDZV_ID(mOS, mZLV_ID);
      mAccount_id:='1300000101';
      mList:=TStringList.create;
      mFileList:=TStringList.Create;
      //NxShowSimpleMessage(mDZV_ID,mSite);
      mZLVBO:=mOS.CreateObject(Class_VATIssuedDepositInvoice);
      mZLVBO.Load(mDZV_ID,nil);
      mTO:=mZLVBO.GetFieldValueAsString('FirmOffice_ID.Address_ID.Email');
      //mTO:='marek.salava@abra.eu';
      mSubject:='Daňový zálohový list #CISLO# k přijaté objednávce #CISOB# ';
      mBody:=('Vážený zákazníku,'+#13#10+
                                       'přijali jsme platbu Vaší objednávky a v příloze e-mailu zasíláme daňový doklad k přijaté záloze.'+#13#10+
                                       'Zboží bude odesláno v nejbližším možném termínu.'+#13#10+
                                       'Děkujeme za Váš nákup, s pozdravem e-shop Nářadí-Simon.cz');
      mSubject:=NxSearchReplace(mSubject,'#CISLO#',mZLVBO.DisplayName,[srAll]);
      mSubject:=NxSearchReplace(mSubject,'#CISOB#',mBO.GetFieldValueAsString('ExternalNumber'),[srAll]);
      mBody:=NxSearchReplace(mBody,'#CISOBJ#',mBO.GetFieldValueAsString('ExternalNumber'),[srAll]);
      mBody:=NxSearchReplace(mBody,'#CISLOFAKTURY#',mZLVBO.DisplayName,[srAll]);
      mBody:=NxSearchReplace(mBody,'#VARSYMBOL#',mZLVBO.GetFieldValueAsString('VarSymbol'),[srall]);
      mBody:=NxSearchReplace(mBody,'#DATUMVYSTAVENI#',FormatDateTime('d.m.yyyy',mZLVBO.GetFieldValueAsdateTime('DocDate$Date')),[srall]);
      mBody:=NxSearchReplace(mBody,'#DATUMSPLATNOSTI#',FormatDateTime('d.m.yyyy',mZLVBO.GetFieldValueAsdateTime('DueDate$Date')),[srall]);
      mBody:=NxSearchReplace(mBody,'#CASTKA#',FormatFloat('0.00,',mZLVBO.GetFieldValueAsFloat('amount')),[srall]);
      mBody:=NxSearchReplace(mBody,'#TEMP#','',[srall]);
      //mZLVBO.Load(mZLV_ID,nil);
      mlist.Add(mZLVBO.OID);
      mFileName:=NxSearchReplace(mZLVBO.DisplayName,'/','-',[srAll]);
      mFileName2:=NxSearchReplace(mBO.DisplayName,'/','-',[srAll]);
      CFxReportManager.PrintByIDs(NxCreateContext_1(mZLVBO), mList, GetDynSource(mOS,'3280000101'), '3280000101', rtoFile, pekPDF, NxGetTempDir, mFileName + '.pdf');
      mList.Clear;
      mlist.Add(mBO.OID);
      CFxReportManager.PrintByIDs(NxCreateContext_1(mBO), mList, '40V53DORW3DL342X01C0CX3FCC', '4VD0000101', rtoFile, pekPDF, NxGetTempDir, mFileName2 + '.pdf');
      SendInternalMail(mOS, mTO,'','',
                         mSubject,mBody,
                         NxGetTempDir+'\'+ mFileName + '.pdf',NxGetTempDir+'\'+ mFileName2 + '.pdf',mZLVBO.GetFieldValueAsString('Firm_ID'),
                         mZLVBO.GetLoadedCollectionMonikerForFieldCode(mZLVBO.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('Division_ID'),
                         mZLVBO.GetLoadedCollectionMonikerForFieldCode(mZLVBO.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('BusTransaction_ID'), mAccount_ID, mBO.OID);
      DeleteFile(NxGetTempDir+'\'+ mFileName + '.pdf');
      DeleteFile(NxGetTempDir+'\'+ mFileName2 + '.pdf');
      mlist.Free;
      NxShowSimpleMessage('Odesláno.',msite);
   end;
 end;
end;


Procedure MailZLV(sender:TComponent);
var
 mSite:TSiteForm;
 mZLV_ID:string;
 mBO, mZLVBO:TNxCustomBusinessObject;
 mOS:TNxCustomObjectSpace;
 mList, mFileList:TStringList;
 mTextBO:TNxCustomBusinessObject;
 mBody, mSubject, mFileName,  mTO, mFileName2, mAccount_id:string;
begin
 mSite:=TComponent(sender).DynSite;
 mOS:=msite.BaseObjectSpace;
 mBO:=TDynSiteForm(mSite).CurrentObject;
 if Assigned(mbo) then begin
   mZLV_ID:=GetZLV_ID(mOS,mBO.OID);
   if not(NxIsEmptyOID(mZLV_ID)) then begin
      mAccount_id:='1300000101';
      mList:=TStringList.create;
      mFileList:=TStringList.Create;
      mZLVBO:=mOS.CreateObject(Class_IssuedDepositInvoice);
      mZLVBO.Load(mZLV_ID,nil);
      mTO:=mZLVBO.GetFieldValueAsString('FirmOffice_ID.Address_ID.Email');
      //mTO:='marek.salava@abra.eu';
      mSubject:='Zálohový list #CISLO# k přijaté objednávce #CISOB# ';
      mBody:=mbo.GetFieldValueAsString('U_ORDERSTATE_ID.X_Note');
      mSubject:=NxSearchReplace(mSubject,'#CISLO#',mZLVBO.DisplayName,[srAll]);
      mSubject:=NxSearchReplace(mSubject,'#CISOB#',mBO.GetFieldValueAsString('ExternalNumber'),[srAll]);
      mBody:=NxSearchReplace(mBody,'#CISOBJ#',mBO.GetFieldValueAsString('ExternalNumber'),[srAll]);
      mBody:=NxSearchReplace(mBody,'#CISLOFAKTURY#',mZLVBO.DisplayName,[srAll]);
      mBody:=NxSearchReplace(mBody,'#VARSYMBOL#',mZLVBO.GetFieldValueAsString('VarSymbol'),[srall]);
      mBody:=NxSearchReplace(mBody,'#DATUMVYSTAVENI#',FormatDateTime('d.m.yyyy',mZLVBO.GetFieldValueAsdateTime('DocDate$Date')),[srall]);
      mBody:=NxSearchReplace(mBody,'#DATUMSPLATNOSTI#',FormatDateTime('d.m.yyyy',mZLVBO.GetFieldValueAsdateTime('DueDate$Date')),[srall]);
      mBody:=NxSearchReplace(mBody,'#CASTKA#',FormatFloat('0.00,',mZLVBO.GetFieldValueAsFloat('amount')),[srall]);
      mBody:=NxSearchReplace(mBody,'#TEMP#','',[srall]);
      mZLVBO.Load(mZLV_ID,nil);
      mlist.Add(mZLVBO.OID);
      mFileName:=NxSearchReplace(mZLVBO.DisplayName,'/','-',[srAll]);
      mFileName2:=NxSearchReplace(mBO.DisplayName,'/','-',[srAll]);
      CFxReportManager.PrintByIDs(NxCreateContext_1(mZLVBO), mList, 'S4STXJVRM3DL35J301C0CX3F40', '3O70000101', rtoFile, pekPDF, NxGetTempDir, mFileName + '.pdf');
      mList.Clear;
      mlist.Add(mBO.OID);
      CFxReportManager.PrintByIDs(NxCreateContext_1(mBO), mList, '40V53DORW3DL342X01C0CX3FCC', '4VD0000101', rtoFile, pekPDF, NxGetTempDir, mFileName2 + '.pdf');
      SendInternalMail(mOS, mTO,'','',
                         mSubject,mBody,
                         NxGetTempDir+'\'+ mFileName + '.pdf',NxGetTempDir+'\'+ mFileName2 + '.pdf',mZLVBO.GetFieldValueAsString('Firm_ID'),
                         mZLVBO.GetLoadedCollectionMonikerForFieldCode(mZLVBO.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('Division_ID'),
                         mZLVBO.GetLoadedCollectionMonikerForFieldCode(mZLVBO.GetFieldCode('Rows')).BusinessObject[0].GetFieldValueAsString('BusTransaction_ID'), mAccount_ID, mBO.OID);
      DeleteFile(NxGetTempDir+'\'+ mFileName + '.pdf');
      DeleteFile(NxGetTempDir+'\'+ mFileName2 + '.pdf');
      mlist.Free;
      NxShowSimpleMessage('Odesláno.',msite);
   end;
 end;
end;

begin
end.