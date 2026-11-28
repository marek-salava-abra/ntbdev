Uses 'eu.obb.printdoc.fce';

procedure InitSite_Hook(Self: TSiteForm);
var
  mBut, mBut2: TBasicAction;
  mUser:TNxCustomBusinessObject;
begin
  if not Assigned(Self.BaseObjectSpace) then
    exit;


    mBut:= Self.GetNewAction;
    mBut.ShowControl := True;
    mBut.ShowMenuItem := True;
    mBut.Caption := 'FOFR Email';
    mBut.Hint := 'Vytvoří email s fakturou k odeslání';
    mBut.Category := 'tabList';
    mBut.OnExecute := @EmailDoc;

end;

Procedure EmailDoc (sender:Tcomponent);
var
 mSite:TSiteForm;
 mList:tstringList;
 i:integer;
 mFileName, mTempDir, mEmail, mAccount_ID, mExtNumber:string;
 mPrintDoc:TStringList;
 mBO, mUser:TNxCustomBusinessObject;
 mOS:TNxCustomObjectSpace;
 mParams,mTemplates:TNxParameters;
begin
 mSite:=TComponent(sender).dynsite;
 mBO:=TDynSiteForm(mSite).CurrentObject;
 if Assigned(mbo) then begin
  mUser:=mbo.ObjectSpace.CreateObject(Class_SecurityUser);
  mUser.Load(NxGetActualUserID_1(mbo),nil);
  mAccount_ID:=GetAccount_ID(mbo.ObjectSpace,mUser.GetFieldValueAsString('Address_ID.Email'));
  mEmail:=NxEvalObjectExprAsString(mbo,'NxGetDefaultEmail('+Quotedstr(mbo.GetFieldValueAsString('Firm_ID'))+','+Quotedstr(mbo.GetFieldValueAsString('FirmOffice_ID'))+','+Quotedstr(mbo.GetFieldValueAsString('Person_ID'))+')');
  mPrintDoc:=TStringList.Create;
  mPrintDoc.Add(mBO.OID);
  mTempDir:=NxGetTempDir;
  mFileName:=NxSearchReplace(mbo.DisplayName,'/','-',[srAll]);
  CFxReportManager.PrintByIDs(NxCreateContext_1(mBO), mPrintDoc,'40SBPEINEFD13ACM03KIU0CLP4','1650000101', rtoFile, pekPDF, mTempDir, mFileName + '.pdf');
  mExtNumber:=mbo.GetFieldValueAsString('U_ExtNumber');
  if NxIsBlank(mExtNumber) then mExtNumber:=GetRONumber(mBO.ObjectSpace, mbo.oid);
  mPrintDoc.free;
      //NxShowSimpleMessage('AAA',msite);
      //NxShowSimpleMessage(,msite);
           mParams := TNxParameters.Create;
            try
                mTemplates := mParams.NewFromDataType(dtList, 'TemplateParams').AsList;
                mTemplates.NewFromDataType(dtString, 'Subject').AsString := 'Faktura vydaná: '+mbo.displayName+' VS: '+mbo.GetFieldValueAsString('VarSymbol')+
                      ' Vaše objednávka číslo: '+ ' '+mExtNumber;
                mTemplates.NewFromDataType(dtString, 'Firm_ID').AsString := mBo.GetFieldValueAsString('Firm_ID');
                mTemplates.NewFromDataType(dtString, 'U_FileName').AsString := mTempDir+'\'+mFileName + '.pdf';
                mTemplates.NewFromDataType(dtString, 'U_recepient').AsString := mEmail;
                mTemplates.NewFromDataType(dtString, 'EmailAccount_ID').AsString := mAccount_ID;
                mSite.ShowDynForm('KJAGOM3EAOI45GTB45MXJQTD0S', mParams, Nil, False, 'DoNewOnlyWithoutPrompt');
            finally
                mParams.Free;
            end;

      DeleteFile(mTempDir+'\'+mFileName + '.pdf');
  end;

end;

function GetAccount_ID(var AOS : TNxCustomObjectSpace;var aEmail : string) : string;
const
  cSQL = 'SELECT ID FROM EmailAccounts WHERE AccountAddress=''%s'' and Hidden=''N''';
var
  mList : TStringList;
begin
  Result := '';
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aEmail]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;

function GetRONumber(var AOS : TNxCustomObjectSpace;var  Invoice_ID : string) : string;
const
  cSQL2 = 'select ro.externalnumber from receivedorders ro left join storedocuments2 sd2 on sd2.provide_ID=ro.id left join issuedinvoices2 ii2 on ii2.providerow_id=sd2.id where ii2.parent_id=''%s'' ';
var
  mList : TStringList;
begin
  Result := '';
  mList := TStringList.Create;
  //NxShowSimpleMessage(Format(cSQL2, [Invoice_ID]),nil);
  try
    AOS.SQLSelect(Format(cSQL2, [Invoice_ID]), mList);
    if mList.Count > 0 then begin
       Result := mList.Strings[0];
      // NxShowSimpleMessage(Result,nil);
    end;
  finally
    mList.Free;
  end;
end;

begin
end.