{
Pomocí tohoto háčku je možné filtrovat data číselníku - vyvolá se před načtením stránky a umožňuje přidat podmínky do SQL použitého pro načtení dat.
Parametr AParams zpřístupňuje parametry číselníku. AParams je jen pro čtení, případné změny se v kódu nijak nepoužijí.
Parametr ADSQL umožňuje deklarovat podmínky, které se přidají do SQL.
}
procedure OnSelectSQL_Hook(Self: TNxBusinessRoll; AParams: TNxParameters; ADSQL: TRollDynamicSQL; AKind: TRollOnSelectSQLKind);
var
 mString:string;
 i:integer;
begin
  if (NxGetActualUserID(Self.ObjectSpace)='~000001Z03') and (CFxNxRuntime.NxGetEnvironmentType=reRuntimeExe) then begin
   mString:='';
   for i := 0 to AParams.Count - 1 do begin
      mString:=AnsiUpperCase(AParams.Params[I].Name)+'='+AParams.Params[i].AsString;
   end;
   //CFxLog.SaveLog(NxCreateContext(self.ObjectSpace),'LS','OnSQL Novák',mString+NxCrLf+NxCrLf+inttostr(AKind),ltScripting,Now);
   ADSQL.Where.Add('A.ID='+QuotedStr('3000000101'));

  end;
end;

begin
end.