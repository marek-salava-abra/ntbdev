{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 i:integer;
 mFirmoffices:TNxCustomBusinessMonikerCollection;
 mFOBO:TNxCustomBusinessObject;
 mURL:string;
 mWinHTTP: Variant;
begin
  if NxIsEmptyOID(self.GetFieldValueAsString('Firm_ID')) then begin
     mFirmoffices:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('FirmOffices'));
     //NxShowSimpleMessage(IntToStr(mFirmoffices.Count),nil);
     for i:=0 to mFirmoffices.CountOfNotDeleted-1 do begin
       mFOBO:=mFirmoffices.BusinessObject[i];
       mURL:='https://crm-cemat.coripo.cloud/acm_abra_update_office_abraid.php?Abra_ID='+mFOBO.OID+'&Crm_id='+mfobo.GetFieldValueAsString('U_u_crm_id_office')+'&Firm_ID='+self.OID;
       mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
       mWinHTTP.Open('POST', mURL);
       mWinHTTP.Send('');
       //if NxGetActualUserID_1(self)='SUPER00000' then NxShowSimpleMessage(mURL+#13#10+mWinHTTP.ResponseText,nil);

     end;
  end;
end;

begin
end.