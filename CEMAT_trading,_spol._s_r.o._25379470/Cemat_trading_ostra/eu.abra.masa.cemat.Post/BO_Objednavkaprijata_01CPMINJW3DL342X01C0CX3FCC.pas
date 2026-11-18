{
Vyvolává se po fyzickém vymazání vlastního objektu z databáze.
}
procedure AfterDelete_Hook(Self: TNxCustomBusinessObject);
var
 mString, mURL:string;
 mWinHTTP: Variant;
 mJSON:TJSONSuperObject;
begin
  if true then begin
       mString:=self.oid;
       if self.GetFieldValueAsBoolean('U_servis_zakazka') then mString:=mString+'&sop=1' else mString:=mString+'&sop=0';
       mURL:='https://crm-cemat.coripo.cloud/acm_abra_delete_op.php?ID='+mString;
       mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
       mWinHTTP.Open('POST', mURL);
       mWinHTTP.Send('');
       if NxGetActualUserID_1(self)='SUPER00000' then NxShowSimpleMessage(mWinHTTP.ResponseText,nil);
   end;
end;



{
Vyvolává se po uložení vlastních dat objektu do databáze.
}
procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mBool:Boolean;
 mString, mURL:string;
 mWinHTTP: Variant;
 mJSON:TJSONSuperObject;
begin
 self.GetOriginalValue_3('U_Servis_zakazka',mBool);
 if not(mBool=self.GetFieldValueAsBoolean('U_Servis_Zakazka')) then begin
       mString:=self.oid;
       if self.GetFieldValueAsBoolean('U_servis_zakazka') then mString:=mString+'&sop=1' else mString:=mString+'&sop=0';
       mURL:='https://crm-cemat.coripo.cloud/acm_abra_delete_op.php?ID='+mString;
       mWinHTTP:= CreateOleObject('WinHttp.WinHttpRequest.5.1');
       mWinHTTP.Open('POST', mURL);
       mWinHTTP.Send('');
       if NxGetActualUserID_1(self)='SUPER00000' then NxShowSimpleMessage(mWinHTTP.ResponseText,nil);
 end;
end;

begin
end.