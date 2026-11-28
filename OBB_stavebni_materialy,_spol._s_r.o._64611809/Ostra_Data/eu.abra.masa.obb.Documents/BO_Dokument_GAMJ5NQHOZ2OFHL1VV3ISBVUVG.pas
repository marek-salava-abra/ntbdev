{
Vyvolává se před fyzickým vymazáním vlastního objektu z databáze.
}
procedure BeforeDelete_Hook(Self: TNxCustomBusinessObject);
var
 mContent:TNxCustomBusinessObject;
 mDocContents:TNxCustomBusinessMonikerCollection;
 i:integer;
 mFileName:string;
begin
  try
    mDocContents:=Self.GetLoadedCollectionMonikerForFieldCode(Self.GetFieldCode('Contents'));
    mFileName:=mDocContents.BusinessObject[0].GetFieldValueAsString('PathAndFileName');
    DeleteFile(mFileName);
  except

  end;
end;

begin
end.