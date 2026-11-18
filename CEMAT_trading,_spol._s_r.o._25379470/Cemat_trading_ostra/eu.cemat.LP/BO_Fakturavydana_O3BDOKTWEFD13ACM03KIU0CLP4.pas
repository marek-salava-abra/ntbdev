{
Vyvolává se před fyzickým uložením vlastních dat objektu do databáze.
}
procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
var
 mrows:TNxCustomBusinessMonikerCollection;
 i:integer;
 mKGCena:Extended;
begin
  if self.GetFieldValueAsBoolean('U_temp') then begin
     mKGCena:=GetKGcena(self.ObjectSpace,self.GetFieldValueAsDateTime('DocDate$Date'));
     mrows:=self.GetLoadedCollectionMonikerForFieldCode(self.GetFieldCode('rows'));
     for i:=0 to mrows.Count-1 do begin
       mrows.BusinessObject[i].SetFieldValueAsFloat('X_LP',
       mrows.BusinessObject[i].GetFieldValueAsFloat('StoreCard_ID.StoreMenuItem_ID.X_Nasobnost')*
       mrows.BusinessObject[i].GetFieldValueAsFloat('Weight')*mKGCena);
     end;
  end;
end;

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