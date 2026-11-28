procedure AfterFillOutputRowFromInputRow_Hook(Self: TNxDocumentImportManager; AnInputRow: TNxCustomBusinessObject; aOutputRow: TNxCustomBusinessObject);
var
    mS_source:string;
begin
    mS_source:=AnInputRow.GetMonikerForFieldCode(AnInputRow.GetFieldCode('Parent_ID')).BusinessObject.GetFieldValueAsString('X_VarSymbol')  ;
    aOutputRow.GetMonikerForFieldCode(aOutputRow.GetFieldCode('Parent_ID')).BusinessObject.setFieldValueAsString('Varsymbol',mS_source)  ;
end;

begin
end.