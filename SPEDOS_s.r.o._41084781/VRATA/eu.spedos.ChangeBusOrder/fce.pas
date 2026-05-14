function GetSerialNumber_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT ID FROM StoreBatches WHERE name=''%s'' and hidden=''N''  ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:='';
  finally
    mList.Free;
  end;
end;

function GetSSB_ID(AOS : TNxCustomObjectSpace; aStoreBatch_ID, aStore_ID : string) : string;
const
  cSQL = 'SELECT ID FROM StoreSubBatches WHERE StoreBatch_ID=''%s'' and Store_ID=''%s''  ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aStoreBatch_ID, aStore_ID]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:='';
  finally
    mList.Free;
  end;
end;

function GetICO(AOS : TNxCustomObjectSpace) : string;
const
  cSQL = 'SELECT OrgIdentNumber FROM GlobData ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(cSQL, mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:='';
  finally
    mList.Free;
  end;
end;

function GetJobOrder_ID(AOS : TNxCustomObjectSpace; aCode : string) : string;
const
  cSQL = 'SELECT A.id FROM PLMJobOrders A '+
         'JOIN StoreCards SC ON SC.ID=A.StoreCard_ID '+
         'WHERE (exists (SELECT 1 FROM USERDATA WHERE FIELDCODE=2000001 AND CLSID=''HTI3OTLGNRPO32EEISEPC0XZ0K'' AND ID = A.ID AND (STRINGFIELDVALUE=''%s''))) ';
var
  mList : TStringList;
begin
  mList := TStringList.Create;
  try
    AOS.SQLSelect(Format(cSQL, [aCode]), mList);
    if mList.Count > 0 then
      Result := mList.Strings[0]
      else Result:='';
  finally
    mList.Free;
  end;
end;

begin
end.