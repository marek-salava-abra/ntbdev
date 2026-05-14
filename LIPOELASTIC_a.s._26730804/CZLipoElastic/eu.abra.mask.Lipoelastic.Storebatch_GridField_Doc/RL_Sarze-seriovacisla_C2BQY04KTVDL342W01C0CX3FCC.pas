
procedure InFilter_Hook(Self: TNxBusinessRoll; AParams: TNxParameters; ARowCookie: integer; var AResult: Boolean);
var
  mName, mPart: string;
  i : integer;
  mList : TStringList;
begin
  if AParams.ParamExist('FilterStoreBatch') then begin
    mName := Self.Package.GetKeyByName('StoreCard_ID', ARowCookie);
    mPart := AParams.ParamAsString('FilterStoreBatch', '');
    AResult := (mName=mPart);
  end;
end;

begin
end.