procedure UpdatePatches(AOS : TNxCustomObjectSpace; APackage_ID : string);
var
  mPkg : TNxCustomBusinessObject;
begin
  if NxIsEmptyOID(APackage_ID) then
    exit;
  mPkg := AOS.CreateObject('YGVSTABUU0Q432KCDJE3QQW0PW');
  try
    if mPkg.Test(APackage_ID) then begin
      mPkg.Load(APackage_ID, nil);
      mPkg.SetFieldValueAsBoolean('U_Delivered', True);
      mPkg.Save;
    end;
  finally
    mPkg.Free;
  end;
end;


begin
end.