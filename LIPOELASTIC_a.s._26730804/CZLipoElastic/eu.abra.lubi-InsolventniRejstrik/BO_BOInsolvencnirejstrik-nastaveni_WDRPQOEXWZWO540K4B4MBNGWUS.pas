uses
  'eu.abra.lubi-InsolventniRejstrik.commons';

{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
  mCode, mData: string;
begin
  mCode := Self.GetFieldValueAsString('Code');
  if (mCode = 'NEVYRIZENA') or
  (mCode = 'OBZIVLA') or
  (mCode = 'VYRIZENA') or
  (mCode = 'MORATORIUM') or
  (mCode = 'NEVYR-POST') or
  (mCode = 'KONKURS') or
  (mCode = 'K-PO ZRUŠ.') or
  (mCode = 'ÚPADEK') or
  (mCode = 'REORGANIZ') or
  (mCode = 'ODDLUŽENÍ') or
  (mCode = 'PRAVOMOCNA') or
  (mCode = 'ODSKRTNUTA') then begin
    mData := Self.GetFieldValueAsString('U_Data');
    if not((mData = cStav0) or (mData = cStav1) or (mData = cStav2)) then begin
      AResult := False;
      Self.AddValidateError(0, Format('U této položky jsou povoleny jen tyto hodnoty: "%s", "%s", "%s".', [cStav0, cStav1, cStav2]));
    end;
  end;
end;

begin
end.