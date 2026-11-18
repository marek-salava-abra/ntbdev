{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mKGCena:Extended;

begin
 mKGCena:=GetKGcena(self.ObjectSpace,self.GetFieldValueAsDateTime('Parent_ID.DocDate$Date'));
  self.SetFieldValueAsFloat('X_LP',
       self.GetFieldValueAsFloat('StoreCard_ID.StoreMenuItem_ID.X_Nasobnost')*
       self.GetFieldValueAsFloat('Weight')*mKGCena);
end;

//select first 1 x_price from defrolldata where clsid='0MLW20M1ODEO3GU1SGUPOSRFRC' and x_date>%s order by x_date
function GetKGCena(AOS : TNxCustomObjectSpace; aDate: TDate) : Extended;
const
  cSQL = 'select first 1 x_price from defrolldata where clsid=''0MLW20M1ODEO3GU1SGUPOSRFRC'' and x_date>=%s order by x_date';
var
  mList : TStringList;
begin
  Result := 0;
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [IntToStr(trunc(aDate))]), mList);
    if mList.Count > 0 then Result := NxIBStrToFloat(mList.Strings[0]);
  finally
    mList.Free;
  end;
end;

begin
end.