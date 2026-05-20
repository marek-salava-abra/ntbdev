function GetStoreCard_ID(AOS : TNxCustomObjectSpace; AValue : string) : string;
const
  cSQL = 'SELECT ID FROM StoreCards WHERE Code=''%s'' and Hidden=''N''';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [AValue]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;
function GetFirm_ID(AOS : TNxCustomObjectSpace; AValue : string) : string;
const
  cSQL = 'SELECT ID FROM Firms WHERE OrgIdentNumber like ''%s'' and firm_id is null and Hidden=''N''';
var
  mList : TStringList;
begin
  mList := TStringList.create;
  try
    AOS.SQLSelect(Format(cSQL, [AValue]), mList);
    Result:='';
    if mList.Count > 0 then
      Result := mList.Strings[0]
  finally
    mList.Free;
  end;
end;


procedure OnFormCloseAction(Sender: TObject; var Action: TCloseAction);
begin
  if Action = caHide then TForm(Sender).ModalResult := mrCancel;
end;

begin
end.