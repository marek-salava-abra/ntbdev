{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mStoreAssortmentGroup_ID: String;
 mStoreAssortmentGroupBO:TNxCustomBusinessObject;
begin
  if NxIsEmptyOID(self.GetFieldValueAsString('StoreAssortmentGroup_ID')) then begin
    mStoreAssortmentGroup_ID:=scrStorecardAssort_ID(self.ObjectSpace,self.GetFieldValueAsString('Code'));
    if not(NxIsEmptyOID(mStoreAssortmentGroup_ID)) then self.SetFieldValueAsString('StoreAssortmentGroup_ID',mStoreAssortmentGroup_ID);
    if NxIsEmptyOID(mStoreAssortmentGroup_ID) then begin
       mStoreAssortmentGroupBO:=self.ObjectSpace.CreateObject(Class_StoreAssortmentGroup);
       mStoreAssortmentGroupBO.new;
       mStoreAssortmentGroupBO.SetFieldValueAsString('Code', self.GetFieldValueAsString('Code'));
       mStoreAssortmentGroupBO.SetFieldValueAsString('Name', AnsiLeftStr(self.GetFieldValueAsString('Name'),30));
       mStoreAssortmentGroupBO.save;
       self.SetFieldValueAsString('StoreAssortmentGroup_ID',mStoreAssortmentGroupBO.OID);
       mStoreAssortmentGroupBO.Free;


    end;
  end;
end;


function scrStorecardAssort_ID(AOS : TNxCustomObjectSpace; AOrderRow_ID : string) : string;
const
  cSQL = 'SELECT ID FROM storeassortMENTGROUPS where code=''%s'' and hidden=''N'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    Result:='';
    AOS.SQLSelect(Format(cSQL, [AOrderRow_ID]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;


begin
end.