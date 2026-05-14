procedure SetConfirmed (OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
begin
  os.SQLExecute('update issuedorders set confirmed=''A'' where closed=''A'' and confirmed=''N'' and docdate$date>45100 ');
  Success := True;
  LogInfoStr := '';
end;

begin
end.