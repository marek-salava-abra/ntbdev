
const
  cSettingsCode = ' EKOKOM-ID';
  Class_EKOKOM = '3DROIEGQRFMOH4ZT4I53BZCXKO';


{
  Vytvoří tlačítko a menu
}
procedure CreateAction(Self: TSiteForm; title: string; hint: string; handler: Pointer;
  const multiItems : array of string = ['']);
var
  mAction: TBasicAction;
  i : Integer;
begin
  if multiItems[0] <> '' then
    mAction := Self.GetNewMultiAction()
  else
    mAction := Self.GetNewAction();

  mAction.ShowControl := True;
  mAction.ShowMenuItem := True;
  mAction.Caption := title;
  mAction.Hint := hint;
  mAction.Category := 'tabDetail, tabList';

  if multiItems[0] <> '' then
    TMultiAction(mAction).OnExecuteItem := handler
  else
    mAction.OnExecute := handler;

  if multiItems[0] <> '' then
  begin
    for i := 0 to Length(multiItems) -1 do
      TMultiAction(mAction).Items.Add(multiItems[i]);
  end;
end;

{
}
function GetDataScalar(objectspace : TNxCustomObjectSpace; mSql : string; mDefault : string = '') : string;
var
  sql : TStringList;
begin
  Result:= mDefault;
  sql:= TStringList.Create;
  objectspace.SQLSelect(mSql,sql);
  if (sql.Count > 0) then
  begin
    sql.Text := sql[0];
    sql.Delimiter := ',';
    Result:= StringReplace(sql[0],'"','',[rfReplaceAll]);
  end;
  sql.Free;
end;

begin
end.