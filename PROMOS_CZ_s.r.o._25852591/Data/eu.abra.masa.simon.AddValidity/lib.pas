procedure  Add(OS: TNxCustomObjectSpace;
  var Success: Boolean; var LogInfoStr: String);
var
 mBO, mRowBO:TNxCustomBusinessObject;
 mRows:TNxCustomBusinessMonikerCollection;
begin
  mBO:=OS.CreateObject(Class_PriceList);
  mBO.load('1000000101',nil);
  mRows:=mBO.GetLoadedCollectionMonikerForFieldCode(mBO.GetFieldCode('Rows'));
  mRowBO:=mRows.AddNewObject;
  mRowBo.SetFieldValueAsDateTime('ValidFromDate$DATE',date);
  mbo.save;
  Success := True;
  LogInfoStr := '';
end;

begin
end.