procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
const
cZnak = '.';
Var
  mBMS1, mBMS2, mBMS3, mBMS4, mBMS5, mBMS6 : String;
  mNewCode : String;
  x : Integer;

begin
  if not(NxGetActualUserID_1(Self) in ['18N0000101','18W0000101']) then begin
     if ((NxLeft(Self.GetFieldValueAsString('Specification'),2)<>'* '))then
     begin

       mBMS1 := Self.GetFieldValueAsString('X_BMS_skupina_ID.Code');
       mBMS2 := Self.GetFieldValueAsString('X_BMS_material_ID.Code');
       mBMS3 := Self.GetFieldValueAsString('X_BMS_PovrchUprava_ID.Code');
       mBMS4 := NxRight('000'+IntToStr(Self.GetFieldValueAsInteger ('X_PRUMER')),3);
       mBMS5 := NxRight('000'+IntToStr(Self.GetFieldValueAsInteger('X_DELKA')),3);
       mBMS6 := Self.GetFieldValueAsString('X_BMS_obal_ID.Code');
      { TEST:
       mBMS1 := '1607';
       mBMS2 := '11';
       mBMS3 := '01';
       mBMS4 := 025;
       mBMS5 := 010;
       mBMS6 := '00';
       }
       mNewCode:= (mBMS1 + cZnak + mBMS2 + cZnak + mBMS3 + cZnak + mBMS4 + cZnak + mBMS5 + cZnak + mBMS6)

     end else
     begin
       mNewCode:= '';
     end;

    if ((NxLeft(Self.GetFieldValueAsString('Specification'),2)<>'*  ') and (Self.GetFieldValueAsString('Specification') = '')) then
    begin
      Self.SetFieldValueAsString('Specification', mNewCode);
      ShowMessage('Zapisuji novou hodnotu Specifikace: '+ mNewCode, nil);
    end;

    if ((NxLeft(Self.GetFieldValueAsString('Specification'),2)<>'* ') and (Self.GetFieldValueAsString('Specification') <> '') and (Self.GetFieldValueAsString('Specification') <> mNewCode)) then
    begin

    if NxMessageBox('Byla zjištěna nesprávná hodnota Specifikace', 'Chcete zapsat správnou hodnotu Specifikace '+ mNewCode+' ?',
      mdConfirm, mdbYesNo, 0, 0, False, Nil) = mrYes then begin
      AResult := True;
      Self.SetFieldValueAsString('Specification', mNewCode)
      end else
      begin
      AResult := False;
      Self.AddValidateError(x,'Skladová karta nemůže být uložena. Upravte vlastnosti skladové karty!');
      end;
    end;
   end;
end;

begin
end.
