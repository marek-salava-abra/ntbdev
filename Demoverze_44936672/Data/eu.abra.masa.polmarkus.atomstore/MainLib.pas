uses '.const', '.fce';


procedure GetOrderFromAPI(OS: TNxCustomObjectSpace; var Success: Boolean; var LogInfoStr: String);
var
 mToken:string;
begin
  mToken:='';
  mToken:=GetActualToken(OS);
  Success := True;
  LogInfoStr := ''+mToken;
end;

begin
end.