{procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
 mStream:TMemoryStream;
 mBO:TNxCustomBusinessObject;
mS_User:string;
begin
 if osNew in self.State then begin
  mS_User:='';
  mBO:=self.ObjectSpace.CreateObject(Class_PLMJobOrder);
  mbo.Load(self.OID,nil);
    NxScriptingLog.WriteEvent(logInfo,mBO.GetFieldValueAsString('U_id_vyrobku')+' '+mBO.DisplayName+#13#10+
                                      self.GetFieldValueAsString('U_id_vyrobku')+' '+self.DisplayName) ;
     mStream := TMemoryStream.Create;
     //if self.GetFieldValueAsFloat('Quantity')=0 then begin
     CFxInternet.HTTPPostBinary('https://sod.spedos.cz/api/api.abra-vyroba.php?',
      'user=aBra&password=skS8f-sxR&ID_montaz_vyrobky=' + mBO.GetFieldValueAsString('U_id_vyrobku') +
      '&cislo_vyrobniho_prikazu='+ self.DisplayName+
      '&abra_user='+mS_User,mStream);
     //end;
     mStream.Free;
     mbo.free;
  end;
end;  }


begin
end.