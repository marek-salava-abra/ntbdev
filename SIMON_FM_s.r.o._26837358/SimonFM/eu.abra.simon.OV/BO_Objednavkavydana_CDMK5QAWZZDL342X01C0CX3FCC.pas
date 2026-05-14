const cstDuplicita = 'Nasledující skladové karty jsou v objednávce použity duplicitně :'+#13#10+'%s';
{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var mRow: TStringList;
    I, J: Integer;
    mCollection: TNxCustomBusinessMonikerCollection;
    mBO: TNxCustomBusinessObject;
    S: string;
begin
  mRow:= TStringList.Create;
  try
    mRow.Sorted:= True;
    mCollection:= Self.GetLoadedCollectionMonikerForFieldCode(Self.GetFieldCode('Rows'));
    for I:= 0 to mCollection.Count - 1 do
    begin
      mBo:= mCollection.BusinessObject[I];
      if (mBO.GetFieldValueAsInteger('RowType') = 3) and (mbo.GetFieldValueAsString('Store_ID')='2D00000101') and
         not (osMarkForDelete in mBO.State) then
      begin
        if mRow.Find(mBO.GetFieldValueAsString('StoreCard_ID'), J) then
          mRow.Objects[J]:= TObject(2) else
          mRow.AddObject(mBO.GetFieldValueAsString('StoreCard_ID'), TObject(1));
      end;
    end;
    S:= '';
    mBo:= Self.ObjectSpace.CreateObject('C3V5QDVZ5BDL342M01C0CX3FCC');
    for I:= 0 to mRow.Count - 1 do
      if mRow.Objects[I] = TObject(2) then
      begin
        OutputDebugString(mRow[I]);
        mBo.Load(mRow[I], nil);
        S:= S + mBo.GetFieldValueAsString('Name') + #13#10;
      end;
    if S <> '' then
    begin
      Self.AddValidateErrorFmt(Self.GetFieldCode('Rows'), cstDuplicita, [S]);
      AResult:= False;
    end;
  finally
    mRow.Free;
  end;
end;

begin
end.