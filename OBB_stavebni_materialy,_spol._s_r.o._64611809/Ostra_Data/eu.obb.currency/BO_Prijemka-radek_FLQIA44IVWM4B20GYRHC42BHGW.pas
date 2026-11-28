{
Umožňuje ovlivnit validaci.
}
procedure Validate_Hook(Self: TNxCustomBusinessObject; var AResult: Boolean);
var
 mUser:TNxCustomBusinessObject;
 mPrice:extended;
begin
  mUser:=self.ObjectSpace.CreateObject(Class_SecurityUser);
  muser.load(NxGetActualUserID_1(self),nil);
  mPrice:=GetPrice(self.ObjectSpace,self.GetFieldValueAsString('StoreCard_ID'),self.GetFieldValueAsString('Store_ID'));
  if (mPrice>0) and NxIsEmptyOID(self.GetFieldValueAsString('ProvideRow_ID')) then begin
  mPrice:=mprice*self.GetFieldValueAsFloat('StoreCard_ID.MainUnitRate');
    if not(muser.GetFieldValueAsBoolean('U_CenyZahranicni')) then begin
      if (self.GetFieldValueAsFloat('LocalTAmount')/self.GetFieldValueAsFloat('Quantity'))>(2*mPrice) then begin
      //if ((self.GetFieldValueAsFloat('LocalTAmount')/self.GetFieldValueAsFloat('Quantity'))*self.GetFieldValueAsFloat('UnitRate'))>(2*mPrice) then begin
        self.AddValidateError(self.GetFieldCode('StoreCard_ID'),'Skladová cena na řádku je příliš vysoká. Pravděpodobně se jedná o špatně nastavenou měnu či špatně použitou kartu. Kontaktujte Terezu Bartošovou či Ivanu Schwarzovou');
        AResult:=false;
      end;
    end;
    if (muser.GetFieldValueAsBoolean('U_CenyZahranicni')) then begin
     if (self.GetFieldValueAsFloat('LocalTAmount')/self.GetFieldValueAsFloat('Quantity'))>(2*mPrice) then begin
     // if ((self.GetFieldValueAsFloat('LocalTAmount')/self.GetFieldValueAsFloat('Quantity'))*self.GetFieldValueAsFloat('UnitRate'))>(2*mPrice) then begin
        NxShowSimpleMessage('Skladová cena na řádku je příliš vysoká. Pravděpodobně se jedná o špatně nastavenou měnu či špatně použitou kartu. Kontaktujte Terezu Bartošovou či Ivanu Schwarzovou)',nil);
        //self.AddValidateError(self.GetFieldCode('StoreCard_ID'),'Skladová cena na řádku je příliš vysoká. Pravděpodobně se jedná o špatně nastavenou měnu či špatně použitou kartu. Kontaktujte Terezu Bartošovoi či Ivanu Schwarzovou)');
        AResult:=true;
      end;
    end;
  end;
  mUser.free;
end;

function GetPrice(AOS : TNxCustomObjectSpace; AStoreCard_ID, aStore_ID : string) : Extended;
const
  cSQL = 'SELECT averagestoreprice FROM StoreSubCards WHERE StoreCard_ID=''%s'' and Store_ID=''%s'' ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [AStoreCard_ID,aStore_ID]), mList);
    if mList.Count > 0 then
      Result := StrToFloat(mList.Strings[0])
      else Result:=0;
  finally
    mList.Free;
  end;
end;

begin
end.