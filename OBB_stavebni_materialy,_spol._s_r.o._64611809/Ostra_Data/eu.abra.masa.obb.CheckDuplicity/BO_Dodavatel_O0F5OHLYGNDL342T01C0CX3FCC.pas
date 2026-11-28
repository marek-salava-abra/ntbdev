

{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mCount:integer;
 mPriceList_ID:string;
begin
 if CFxNxRuntime.NxGetEnvironmentType=reRuntimeExe then begin
  if not(NxIsBlank(self.GetFieldValueAsString('ExternalNumber'))) then begin
    if not(self.GetFieldValueAsString('ExternalNumber') in ['0000', '00000']) then begin
      mPriceList_ID:=self.GetFieldValueAsString('StoreCard_ID.X_PricelistNameOBB');
      if not(NxIsEmptyOID(mPriceList_ID)) then
       mCount:=self.ObjectSpace.SQLSelectFirstAsInteger('Select count(sp.id) from suppliers sp left join storecards sc on sc.id=sp.storecard_id'+
                                                        ' where sp.ExternalNumber='+QuotedStr(self.GetFieldValueAsString('ExternalNumber'))+
                                                        ' and not(sp.id='+QuotedStr(self.oid)+') and sc.hidden=''N'' and sc.X_PricelistNameOBB='+QuotedStr(mPriceList_ID),0)
       else
       mCount:=self.ObjectSpace.SQLSelectFirstAsInteger('Select count(id) from suppliers where ExternalNumber='+QuotedStr(self.GetFieldValueAsString('ExternalNumber'))+
                                                       ' and not id='+QuotedStr(self.oid),0);
      if mCount>0 then begin
        self.AddValidateError(self.GetFieldCode('ExternalNumber'),'Pozor duplicitní kód dodavatele, nemůžu uložit.');
        AResult:=false;
      end;
   end;
  end;
 end;
end;

begin
end.