{
Vyvolává se po vyplnění hlavičky výstupního dokladu importovacím managerem
}
procedure AfterFillOptputHeader_Hook(Self: TNxDocumentImportManager);
var
 mList:TStringList;
begin
  mList := TStringList.Create();
  Self.GetParamNames(mList);
  ShowMessage( mList.Text );
end;

begin
end.