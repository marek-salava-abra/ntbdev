procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
  mAdrBo: TNxCustomBusinessObject;
  mAdrMon: TNxBusinessMoniker;
begin
  try
    // Eshop  - pro vypocet postovneho je nutno urcit zemi
    mAdrMon := Self.GetMonikerForFieldCode(Self.GetFieldCode('ResidenceAddress_ID'));
    mAdrBo := mAdrMon.BusinessObject;
    if Assigned(mAdrBo) then begin
      if mAdrBo.GetFieldValueAsString('Country') = '' then begin
        mAdrBo.SetFieldValueAsString('Country', 'Česká republika');
        mAdrBo.SetFieldValueAsString('CountryCode', 'CZ');
      end;
    end;
  finally
    mAdrBo := nil;
    mAdrMon := nil;
  end;
end;


begin
end.