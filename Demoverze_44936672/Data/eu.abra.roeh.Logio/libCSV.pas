uses  'eu.abra.roeh.Logio.ConstVar';

function GetColumIndex(const cFieldName:string;Str:String;const cEval:char;var Uvoz:Boolean):Integer;
var
  N,M : integer;
  S: String;
begin
  N := 0;
  Str := UpperCase(Trim(Str));
  while Length(Str)>0 do begin
    Uvoz := Str[1] = cUvoz;
    if Uvoz then Delete(Str,1,1);
    if Uvoz then S := Copy(Str,1,Pos(cUvoz,Str)-1)
      else begin
        S := Copy(Str,1,Pos(cEvaluator,Str)-1);
       if Length(S) = 0 then S := Str;
      end;
    M := Length(S);
    Delete(Str,1,M);
    if Pos(cUvoz + cEvaluator,Str)= 1 then Delete(Str,1,2);
    if Pos(cEvaluator,Str)= 1 then Delete(Str,1,1);
    Inc(N);
    if cFieldName = S then Break;
  end;
  if cFieldName = S then Result := N
    else Result := 0;
end;

function GetColum(const cIndex:Integer;Str:String;const cEval:char):string;
var
  N,M : integer;
  Uvoz : Boolean;
  S: String;
//  mShow:Boolean;
//  mStr:tStringList;
begin
  N := 0;
  Result := '';
{  if cIndex = 47 then begin
    showmessage('ahoj');
    mShoW := true;
    mStr:= TStringList.Create;
  end else mShow := false;}
  while (Length(Str)>0) and (cIndex<>N) do begin
    Uvoz := Str[1] = cUvoz;
    if Uvoz then Delete(Str,1,1);
    if Uvoz then M:=Pos(cUvoz + cEvaluator,Str)+1
      else M:=Pos(cEvaluator,Str);
    if M = 0 then M:= Length(Str);
    //demo
 //   S:= Copy(Str,1,M);
 //   if mShoW then mStr.Add(S);
    
    inc(N);
    if N= cIndex then begin
      S:= Copy(Str,1,M);
      if Length(S) = 0 then S := Str;
    if N= cIndex then Break;
    end;
    Delete(Str,1,M);
    {if mShow then ShowMessage(IntToStr(N)+':' + Str);}
  end; //while
  if cEvaluator=S[Length(S)] then begin
    if Uvoz then Delete(S,M-1,2)
      else Delete(S,M,1);
  end;
  if N=cIndex then Result := S
    else Result := '';
{if mShoW then begin
  mStr.SaveToFile('c:\aaa\xx.txt');
  mStr.Free;
end;}

end;

begin
end.