procedure AfterSetFieldValue_Hook(Self: TNxCustomBusinessObject; AFieldCode: Integer; AValue: TNxParameter; AOriginalValue: TNxParameter);
var
 mPrice:Extended;
begin
  if (AFieldCode=self.GetFieldCode('U_marze')) and (self.GetFieldValueAsFloat('U_marze')>0) then begin
    mPrice:= GetLastPrice(self.ObjectSpace,self.GetFieldValueAsString('Store_ID'),self.GetFieldValueAsString('StoreCard_ID'));
    self.SetFieldValueAsFloat('UnitPrice',mPrice*((self.GetFieldValueAsFloat('U_marze')/100)+1));
  end;
end;


function GetLastPrice(AOS : TNxCustomObjectSpace; AStore : string; AStoreCard : string) : Extended;
  const
    cSQL = 'SELECT averagestoreprice from storesubcards where  Store_ID=''%s'' and StoreCard_ID=''%s'' ';

  Var
    mR : TStrings;
  begin
    Result := 0;
    mR := TStringlist.Create;
    try
      AOS.SQLSelect(Format(cSQL, [AStore, AStoreCard]), mR);
      if mR.Count > 0 then
        Result := StrToFloat(mR.strings[0]);
    finally
      mR.Free;
    end;
  end;

begin
end.