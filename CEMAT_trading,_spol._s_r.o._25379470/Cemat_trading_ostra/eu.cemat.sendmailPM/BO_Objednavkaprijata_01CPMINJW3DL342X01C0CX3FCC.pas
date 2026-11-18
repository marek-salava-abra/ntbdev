{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
var
mRows:TNxCustomBusinessMonikerCollection;
mRowBO:TNxCustomBusinessObject;
mMailList:TStringList;
i,j:integer;
begin
  if (self.GetFieldValueAsString('X_status')='1A00000101') and not(self.GetFieldValueAsBoolean('U_emailsent')) and (self.GetFieldValueAsString('DocQueue_ID')='1U00000101') then begin
    mrows:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('rows'));
    mMailList:=TStringList.create;
    for i:=0 to mrows.count-1 do begin

      mRowBO:=mrows.BusinessObject[i];
      if (mRowBO.GetFieldValueAsInteger('RowType')=3) and not(NxIsBlank(mRowBO.GetFieldValueAsString('StoreCard_ID.StoreAssortmentGroup_ID.U_email'))) then begin
      
      mMailList.Add(mRowBO.GetFieldValueAsString('StoreCard_ID.StoreAssortmentGroup_ID.U_email'));

      end;
    
    end;
    for j:=0 to mMailList.count-1 do begin
      //SMTPSendMailWithMoreFiles(csNone,'','','smtp.xlnet.cz',25,'abra@hotjet.cz',mto,'',self.DisplayName,mBody,NxGetTempDir+'\'+mfilename,commAsText,'');
      CFxInternet.SMTPSendMailWithMoreFiles(csOpenSSL,'cemat@mailcity.cz','csarmady184','mail.poda.cz',25,'abra@cemat.cz',mMailList.Strings[j],'','',self.DisplayName,self.DisplayName+' byla založena, prosíme o kontrolu',commAsText,'');
    end;
    self.SetFieldValueAsBoolean('U_emailsent',True);
  end;
end;

begin
end.