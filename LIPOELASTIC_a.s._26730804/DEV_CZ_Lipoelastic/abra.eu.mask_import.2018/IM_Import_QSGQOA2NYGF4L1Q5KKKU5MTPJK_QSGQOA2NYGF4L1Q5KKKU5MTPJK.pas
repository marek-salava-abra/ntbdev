{
Vyvolává se po vyplnění hlavičky výstupního dokladu importovacím managerem
}
procedure AfterFillOptputHeader_Hook(Self: TNxDocumentImportManager);
begin
     try
     self.OutputDocument.SetFieldValueAsString('U_Dodpod_mesto_zf', self.InputDocument.getFieldValueAsString('U_Dodpod_mesto'));
     self.OutputDocument.SetFieldValueAsString('U_Dodaci_podminky_zf',self.InputDocument.getFieldValueAsString('U_Dodaci_podminky'));
     if not nxisblank(self.InputDocument.getFieldValueAsString('X_voucher')) then begin
         self.OutputDocument.SetFieldValueAsString('X_voucher',self.InputDocument.getFieldValueAsString('X_voucher'));
     end;
     except

     end;
end;

procedure AfterFillOutputRowFromInputRow_Hook(Self: TNxDocumentImportManager; AnInputRow: TNxCustomBusinessObject; aOutputRow: TNxCustomBusinessObject);
var
    mS_source:string;
begin
    mS_source:=AnInputRow.GetMonikerForFieldCode(AnInputRow.GetFieldCode('Parent_ID')).BusinessObject.GetFieldValueAsString('X_varsymbol')  ;
    if (trim(mS_source)<>'') and (mS_source <> '0') then begin
          aOutputRow.GetMonikerForFieldCode(aOutputRow.GetFieldCode('Parent_ID')).BusinessObject.setFieldValueAsString('Varsymbol',mS_source)  ;
    end else begin
          aOutputRow.GetMonikerForFieldCode(aOutputRow.GetFieldCode('Parent_ID')).BusinessObject.setFieldValueAsString('Varsymbol','')  ;
    end;

end;

begin
end.