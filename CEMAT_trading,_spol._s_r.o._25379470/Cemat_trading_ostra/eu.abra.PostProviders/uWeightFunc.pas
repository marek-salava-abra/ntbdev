uses
  'eu.abra.PostProviders.uConst';

//prevede hmotnost z jedne jednotky na druhou
function GetWeight(AOS: TNxCustomObjectSpace;const AWeight: Extended; const ASWeightUnit, ADWeightUnit:Integer): Extended;
const
  cExpr = 'NxWeight(%s, %s, %s)';
var
  mBO: TNxCustomBusinessObject;
begin
  Result:= 0;
  mBO:= AOS.CreateObject(Class_Division);
  try
    mBO.NewWithoutIdentity;
    Result := NxEvalObjectExprAsFloat(mBO, Format(cExpr, [CFxFloat.FloatToStr(AWeight, '.'), IntToStr(ASWeightUnit), IntToStr(ADWeightUnit)]));
  finally
    mBO.Free;
  end;
end;

//vrati textove hmotnostni jednotku
function GetWeightUnitStr(const AWeightUnit:Integer): string;
begin
  Result:= '';
  if (AWeightUnit = cUnitg) then
    Result := cUnitgStr
  else if (AWeightUnit = cUnitkg) then
    Result := cUnitkgStr
  else if (AWeightUnit = cUnitt) then
    Result := cUnittStr
  else
    RaiseException(lng_msg_internalError5);
end;

begin
end.