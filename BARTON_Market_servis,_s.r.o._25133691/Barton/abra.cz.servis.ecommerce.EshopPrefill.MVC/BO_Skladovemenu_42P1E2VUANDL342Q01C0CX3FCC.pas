uses
  'abra.cz.servis.ecommerce.EshopPrefill.MVC.Common';

procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
begin
  // Predvypplneni CS nazvu pro eshop dle nazvu menu
  if Self.GetFieldValueAsString('X_Text') = '' then begin
    Self.SetFieldValueAsString('X_Text', Self.GetFieldValueAsString('Text'));
  end;

  // Predvypplneni CS URL nazvu pro eshop dle nazvu menu
  if Self.GetFieldValueAsString('X_UrlText') = '' then begin
    Self.SetFieldValueAsString('X_UrlText', Self.GetFieldValueAsString('Text'));
  end;
end;

procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
  mOrigBoolVal: Boolean;
begin
  try
    // Pokud dojde ke zmene priznaku pro zobrazeni na eshopu, tak se zalozi folder
    Self.GetOriginalValue_3(C_SmKeyField, mOrigBoolVal);
    if (mOrigBoolVal = False) and (Self.GetFieldValueAsBoolean(C_SmKeyField) = True) then begin
      CallCreateSmFolder(Self, False);
    end;
  finally
    mOrigBoolVal := nil;
  end;
end;


begin
end.