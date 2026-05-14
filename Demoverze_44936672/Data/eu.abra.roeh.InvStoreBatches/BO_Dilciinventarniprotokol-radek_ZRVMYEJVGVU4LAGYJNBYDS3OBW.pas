uses 'eu.abra.roeh.InvStoreBatches.Const',
     'eu.abra.roeh.InvStoreBatches.lib';
{
Umožňuje ovlivnit validaci.
}
{
Vyvolává se před fyzickým vymazáním vlastního objektu z databáze.
}
procedure _BeforeDelete_PreHook(Self: TNxCustomBusinessObject);
begin
  Self.ObjectSpace.SQLExecute('delete from Relations R where R.REL_DEF ='  +IntToStr(cRelNegaQuant)+' and R.LEFTSIDE_ID = '''+Self.OID+'''');
  if NxIBStrToFloat(GetFirstRecordFromSQL(self.ObjectSpace,Format(cSelSumRel,[Self.OID]))) <0 then
    RaiseException('Nelze smazat řádek, který se odkazuje na srovnávací řádek protokolu');
end;


{
Umožňuje ovlivnit validaci.
}

procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mQ : Extended;
begin
  if not aResult then Exit;
  mQ :=Abs(NxIBStrToFloat(GetFirstRecordFromSQL(self.ObjectSpace,Format(cSelSumRel,[Self.OID]))));
  if mQ=0 then Exit; // nešel by zadat ten rovnací
  if mQ>Self.GetFieldValueAsFloat('X_RealQuantity') then begin
   aResult := false;
   Self.AddValidateError(Self.GetFieldCode('X_RealQuantity'), 'Nelze snížit inventarizované množství pod vyrovnávací korekčí množství ' +FormatFloat('0.000',mQ)+ '!!! ');
  end;
end;

begin
end.