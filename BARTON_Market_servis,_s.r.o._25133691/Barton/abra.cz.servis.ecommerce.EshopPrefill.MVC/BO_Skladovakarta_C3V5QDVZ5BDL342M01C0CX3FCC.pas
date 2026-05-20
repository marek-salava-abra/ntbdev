uses
  'abra.cz.servis.ecommerce.EshopPrefill.MVC.Common';

procedure BeforeSave_Hook(Self: TNxCustomBusinessObject);
var
  mEncoding: TEncoding;
begin
  mEncoding := TEncoding.Create;
  try
    // Vypleni paraovaci karty. Je nutne parovat i sam na sebe.
    if (Self.GetFieldValueAsString('X_Eshop_Group_SC_ID') = '') or (Self.GetFieldValueAsString('X_Eshop_Group_SC_ID') = '0000000000') then begin
      Self.SetFieldValueAsString('X_Eshop_Group_SC_ID', Self.OID);
    end;
    // Predvypplneni nazvu pro eshop dle nazvu karty
    if Self.GetFieldValueAsString('X_Eshop_Name') = '' then begin
      Self.SetFieldValueAsString('X_Eshop_Name', Self.GetFieldValueAsString('Name'));
    end;
    // Nazev adresare pro obrazky a dokumenty, default dle kodu
    if Self.GetFieldValueAsString('X_ImagesPath') = '' then begin
      Self.SetFieldValueAsString('X_ImagesPath', '\\SRV-BMS-ABRA\Abra_ESHOP_images\StoreCards\' + NxTrim(mEncoding.RemoveDiacritics(ReplaceChar(Self.GetFieldValueAsString('Code'),'-',0)),' '));
    end;
    if Self.GetFieldValueAsString('X_DocumentsPath') = '' then begin
      Self.SetFieldValueAsString('X_DocumentsPath', NxTrim(mEncoding.RemoveDiacritics(ReplaceChar(Self.GetFieldValueAsString('Code'),'-',0)),' '));
    end;
  finally
    mEncoding.Free;
  end;
end;

procedure AfterSave_Hook(Self: TNxCustomBusinessObject);
var
  mOrigBoolVal: Boolean;
begin
  try
    // Pokud dojde ke zmene priznaku pro zobrazeni na eshopu, tak se zalozi folder
    Self.GetOriginalValue_3(C_ScKeyField, mOrigBoolVal);
    if (mOrigBoolVal = False) and (Self.GetFieldValueAsBoolean(C_ScKeyField) = True) then begin
      CallCreateScFolder(Self, False);
    end;
  finally
    mOrigBoolVal := nil;
  end;
end;


procedure CanDelete_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
  mSqlData: TMemoryDataset;
begin
  mSqlData := TMemoryDataset.Create(nil);
  try
    Self.ObjectSpace.SQLSelect2('SELECT SC.X_Eshop_Group_SC_ID ' +
                                ' FROM StoreCards SC '+
                                ' WHERE SC.ID <> ' + QuotedStr(Self.OID) +
                                  ' AND SC.X_Eshop_Group_SC_ID = ' + QuotedStr(Self.OID), mSqlData);
    if mSqlData.RecordCount > 0 then begin
      Self.AddValidateError(0, 'Kartu není možné smazat, protože je použita pro e-shop jako párovací karta pro variantní zobrazení.');
      AResult := False;
    end;
  finally
    mSqlData.Free;
  end;
end;

begin
end.