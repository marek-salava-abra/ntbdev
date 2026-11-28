{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mAmount:Extended;
begin
  if not(self.GetFieldValueAsString('Firm_ID.Code') in ['07777','00001']) then begin
  mAmount:=GetAmount(Self.ObjectSpace,self.GetFieldValueAsString('Firm_ID'),inttostr(Trunc(Date)));
  if (self.GetFieldValueAsFloat('LocalAmount')+mAmount)>270000 then begin
   self.AddValidateError(self.GetFieldCode('Firm_ID'),'Touto platbou překročíte zákonný hotovostní denní limit pro firmu '+chr(13)+chr(10)+self.GetFieldValueAsString('Firm_ID.Name')+chr(13)+chr(10)+
   'Možná částka platby je '+NxFormatNumeric('0.00',Min(trunc(270000),trunc(self.GetFieldValueAsFloat('LocalAmount')-mAmount)),nil));
   AResult:=False;
  end;
  end;
end;

function GetAmount(AOS : TNxCustomObjectSpace; aCode, adate : string) : Extended;
const
  cSQL = 'SELECT sum(LocalAmount) FROM CashReceived WHERE Firm_ID=''%s'' and X_PayByCard=''N'' and docdate$date=%s ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode, adate]), mList);
    if mList.Count > 0 then
      Result := StrToFloat(mList.Strings[0])
      else Result:=0
  finally
    mList.Free;
  end;
end;

begin
end.